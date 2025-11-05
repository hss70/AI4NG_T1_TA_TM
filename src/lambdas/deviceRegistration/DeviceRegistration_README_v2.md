# 📱 Device Registration Service

This service manages device registration for mobile push notifications.  
It records which **user**, **device**, and **token** combinations are currently active so the Step Function–driven EEG pipeline can deliver notifications only to the correct user and device.

---

## 🧩 DynamoDB Table — `DeviceTokens`

| **Attribute** | **Type** | **Description** |
|----------------|-----------|-----------------|
| `deviceId` | `PK (string)` | Unique per app install / physical device. |
| `token` | `string` | FCM registration token from the mobile app. |
| `platform` | `string` | e.g. `android` or `ios`. |
| `lastUserId` | `string` | The user currently logged in on this device. |
| `lastUpdated` | `string (ISO8601)` | Timestamp of last registration. |
| `activeSessionId` *(optional)* | `string` | EEG session currently associated with this device. |
| `manufacturer` *(optional)* | `string` | Device manufacturer (e.g. Samsung, Apple). |
| `deviceModel` *(optional)* | `string` | Device model (e.g. Galaxy S21, iPhone 13). |
| `osVersion` *(optional)* | `string` | Device OS version string. |
| `appVersion` *(optional)* | `string` | App version string. |
| `buildNumber` *(optional)* | `string` | App build number. |
| `locale` *(optional)* | `string` | Device locale (e.g. en-US, es-ES). |

### 🔍 Global Secondary Index: `userIdIndex`
```yaml
GlobalSecondaryIndexes:
  - IndexName: userIdIndex
    KeySchema:
      - AttributeName: lastUserId
        KeyType: HASH
    Projection:
      ProjectionType: ALL
```

This index allows the notification Lambda to query all active devices for a specific user.

### 🕒 TTL (optional)
Enable TTL on `lastUpdated` (e.g. 90 days) to automatically clean up old devices.

---

## ⚙️ API Endpoints

### `POST /device/register` — Register Device

#### Request body
```json
{
  "deviceId": "android-uuid-1234",
  "userId": "alice@example.com",
  "token": "fcm_token_xyz",
  "platform": "android",
  "activeSessionId": "optional-session-id",
  "manufacturer": "Samsung",
  "deviceModel": "Galaxy S21",
  "osVersion": "Android 13",
  "appVersion": "1.2.3",
  "buildNumber": "build-456",
  "locale": "en-US"
}
```

#### Behavior
- Performs an **upsert** on the `DeviceTokens` table.
- Each new login or token refresh overwrites the existing device record.
- Ensures **only the most recently logged-in user** per device receives notifications.
- Only `deviceId`, `userId`, and `token` are required; all other fields are optional.

### `GET /device/register` — Retrieve Device Records

#### Query Parameters
- `?deviceId=xxx` — Get specific device record
- `?userId=xxx` — Get all devices for a user

#### Response Examples
**Single device:**
```json
{
  "device": {
    "deviceId": "android-uuid-1234",
    "token": "fcm_token_xyz",
    "platform": "android",
    "lastUserId": "alice@example.com",
    "lastUpdated": "2024-01-15T10:30:00.000Z",
    "manufacturer": "Samsung",
    "deviceModel": "Galaxy S21",
    "osVersion": "Android 13",
    "appVersion": "1.2.3",
    "buildNumber": "build-456",
    "locale": "en-US"
  }
}
```

**Multiple devices:**
```json
{
  "devices": [
    {
      "deviceId": "android-uuid-1234",
      "token": "fcm_token_xyz",
      "platform": "android",
      "lastUserId": "alice@example.com",
      "lastUpdated": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

---

## 🧠 Lambda Implementation — Node.js (AWS SDK v3)

```js
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({});
const TABLE_NAME = process.env.DEVICE_TABLE;

export const handler = async (event) => {
  try {
    const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    const { deviceId, userId, token, platform = "android", activeSessionId } = body;

    if (!deviceId || !userId || !token) {
      return { statusCode: 400, body: JSON.stringify({ error: "Missing required fields" }) };
    }

    const now = new Date().toISOString();
    const updateExpr = ["SET token = :t", "platform = :p", "lastUserId = :u", "lastUpdated = :ts"];
    const values = {
      ":t": { S: token },
      ":p": { S: platform },
      ":u": { S: userId },
      ":ts": { S: now }
    };

    if (activeSessionId) {
      updateExpr.push("activeSessionId = :sid");
      values[":sid"] = { S: activeSessionId };
    }

    await client.send(new UpdateItemCommand({
      TableName: TABLE_NAME,
      Key: { deviceId: { S: deviceId } },
      UpdateExpression: updateExpr.join(", "),
      ExpressionAttributeValues: values
    }));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Device registered successfully", deviceId, userId })
    };
  } catch (err) {
    console.error("Error registering device:", err);
    return { statusCode: 500, body: JSON.stringify({ error: "Internal Server Error" }) };
  }
};
```

### SAM Template snippet
```yaml
Resources:
  DeviceTokensTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub "${AppName}-DeviceTokens"
      AttributeDefinitions:
        - AttributeName: deviceId
          AttributeType: S
        - AttributeName: lastUserId
          AttributeType: S
      KeySchema:
        - AttributeName: deviceId
          KeyType: HASH
      BillingMode: PAY_PER_REQUEST
      GlobalSecondaryIndexes:
        - IndexName: userIdIndex
          KeySchema:
            - AttributeName: lastUserId
              KeyType: HASH
          Projection:
            ProjectionType: ALL

  RegisterDeviceFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: lambdas/register_device/
      Handler: index.handler
      Runtime: nodejs20.x
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref DeviceTokensTable
      Environment:
        Variables:
          DEVICE_TABLE: !Ref DeviceTokensTable
      Events:
        ApiEvent:
          Type: Api
          Properties:
            Path: /device/register
            Method: post
```

---

## 🧭 When to Register

### 🪪 1. On Login
After user authentication succeeds:
```csharp
var token = await FirebaseMessaging.Instance.GetToken();
await ApiClient.RegisterDevice(userId, deviceId, token);
```

### 🔁 2. On Token Refresh
Inside your `MyFirebaseMessagingService.OnNewToken()`:
```csharp
public override void OnNewToken(string token)
{
    ApiClient.RegisterDevice(CurrentUserId, DeviceId, token);
}
```

### 🚪 3. (Optional) On Logout
You may clear the mapping by sending:
```json
{ "deviceId": "android-uuid-1234", "userId": "", "token": "" }
```

---

## 📡 How Notifications Use It

1. The Step Function triggers the **`NotifyClassifierReady`** Lambda:
   ```json
   { "type": "ClassifierReady", "userId": "alice@example.com", "sessionId": "12345" }
   ```

2. The Lambda queries the GSI:
   ```js
   const devices = await client.send(new QueryCommand({
     TableName: TABLE_NAME,
     IndexName: "userIdIndex",
     KeyConditionExpression: "lastUserId = :u",
     ExpressionAttributeValues: { ":u": { S: userId } }
   }));
   ```

3. Each token in `devices.Items` receives the FCM notification.

---

## 🔀 Edge Cases

### 🧑‍🤝‍🧑 Multiple Users on One Device
- Each login overwrites `lastUserId` for that `deviceId`.
- Only the **most recent user** on that device receives notifications.
- Prevents accidental cross-user pushes.

### 📱 One User on Multiple Devices
- All devices registered under `lastUserId = "alice"` receive notifications.
- This covers phones, tablets, and emulators.

### 🧹 Token Rotation / Uninstall
- If FCM returns `NotRegistered` or `InvalidRegistration`, remove that record.
- TTL auto-cleans unused entries after inactivity.

---

## 🧪 Testing

### 🔧 Local test with `curl`

**Register device:**
```bash
curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/prod/device/register \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "emulator-001",
    "userId": "alice@example.com",
    "token": "test_fcm_token_123",
    "platform": "android",
    "manufacturer": "Samsung",
    "deviceModel": "Galaxy S21",
    "locale": "en-US"
  }'
```

**Get device by deviceId:**
```bash
curl "https://<api-id>.execute-api.<region>.amazonaws.com/prod/device/register?deviceId=emulator-001"
```

**Get devices by userId:**
```bash
curl "https://<api-id>.execute-api.<region>.amazonaws.com/prod/device/register?userId=alice@example.com"
```

Registration response:
```json
{
  "message": "Device registered successfully",
  "deviceId": "emulator-001",
  "userId": "alice@example.com"
}
```

---

## ✅ Summary

| Feature | Design |
|----------|--------|
| **Primary Key** | `deviceId` |
| **Lookup Index** | `lastUserId` (GSI) |
| **Per-device state** | Overwritten on login |
| **Per-user notifications** | Query GSI by `lastUserId` |
| **Edge cases handled** | Multi-user devices, multi-device users |
| **Cleanup** | TTL + invalid token removal |
| **Cold start** | Optimized via Node.js runtime |
