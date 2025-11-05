import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";
import { DynamoDBClient, QueryCommand, DeleteItemCommand } from "@aws-sdk/client-dynamodb";
import admin from "firebase-admin";

let firebaseInitialized = false;

export const handler = async (event) => {
    console.log("Incoming event:", JSON.stringify(event, null, 2));

    const { userId, sessionId, sessionName } = event;
    if (!userId || !sessionId) {
        return { statusCode: 400, body: "Missing userId or sessionId" };
    }

    // Load the Firebase service account JSON from Secrets Manager
    const secretName = process.env.FCM_SERVICE_ACCOUNT_SECRET || "neuro-fcm-service-account";
    const region = process.env.AWS_REGION || "eu-west-2";

    const secrets = new SecretsManagerClient({ region });
    const secretResponse = await secrets.send(
        new GetSecretValueCommand({ SecretId: secretName })
    );

    const secretString = secretResponse.SecretString || "";
    let serviceAccount;

    try {
        if (secretString.trim().startsWith("{")) {
            serviceAccount = JSON.parse(secretString);
        } else {
            serviceAccount = JSON.parse(Buffer.from(secretString, "base64").toString("utf8"));
        }
    } catch (err) {
        console.error("Failed to parse FCM service account secret:", err);
        throw err;
    }

    // Initialize Firebase Admin if not already done
    if (!firebaseInitialized) {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        firebaseInitialized = true;
        console.log("Firebase Admin initialized");
    }

    // Fetch device tokens for the user from DynamoDB
    const ddb = new DynamoDBClient({ region });
    const DEVICE_TABLE = process.env.DEVICE_TABLE;
    const USER_INDEX = "userIdIndex";

    const query = await ddb.send(
        new QueryCommand({
            TableName: DEVICE_TABLE,
            IndexName: USER_INDEX,
            KeyConditionExpression: "lastUserId = :u",
            ExpressionAttributeValues: {
                ":u": { S: userId },
            },
        })
    );

    const devices = query.Items || [];
    if (devices.length === 0) {
        console.log(`No registered devices found for user ${userId}`);
        return { statusCode: 200, body: "No devices to notify" };
    }

    console.log(`Found ${devices.length} devices for ${userId}`);

    // Prepare notification payload
    const payload = {
        notification: {
            title: "EEG Classifier Ready",
            body: `${sessionName || "Your EEG session"} has been processed successfully.`,
        },
        data: {
            type: "ClassifierReady",
            sessionId: sessionId.toString(),
            sessionName: sessionName || "",
        },
    };

    const results = [];
    for (const device of devices) {
        const token = device.token?.S;
        const deviceId = device.deviceId?.S;
        if (!token || !deviceId) continue;

        try {
            const response = await admin.messaging().sendToDevice(token, payload);

            const success = response?.results?.[0]?.messageId ? true : false;
            console.log(`📨 Sent to ${deviceId}: ${success ? "✅ success" : "⚠️ failure"}`);
            results.push({ deviceId, token, success });

            // Check if the token was invalid or unregistered
            const error = response?.results?.[0]?.error;
            if (error) {
                const errorCode = error.code || "";
                if (
                    errorCode === "messaging/registration-token-not-registered" ||
                    errorCode === "messaging/invalid-registration-token"
                ) {
                    console.log(`🗑 Removing invalid token for device ${deviceId}`);
                    await ddb.send(
                        new DeleteItemCommand({
                            TableName: DEVICE_TABLE,
                            Key: { deviceId: { S: deviceId } },
                        })
                    );
                } else {
                    console.warn(`⚠️ FCM send failed for ${deviceId}: ${errorCode}`);
                }
            }
        } catch (err) {
            console.error(`Error sending to ${deviceId}:`, err.message);
            results.push({ deviceId, token, success: false, error: err.message });
        }
    }

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Notifications processed",
            totalDevices: devices.length,
            results,
        }),
    };
};
