import { DynamoDBClient, UpdateItemCommand, GetItemCommand, QueryCommand } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";

const client = new DynamoDBClient({});
const TABLE_NAME = process.env.DEVICE_TABLE;

export const handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));
  console.log("Environment TABLE_NAME:", TABLE_NAME);
  
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  try {
    const method = event.httpMethod || event.requestContext?.http?.method;
    console.log("HTTP Method:", method);
    
    if (method === "POST") {
      return await handleRegister(event, headers);
    } else if (method === "GET") {
      return await handleGet(event, headers);
    } else {
      return {
        statusCode: 405,
        headers,
        body: JSON.stringify({ error: "Method not allowed" })
      };
    }
  } catch (err) {
    console.error("Handler Error:", err);
    console.error("Error stack:", err.stack);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: "Internal Server Error" })
    };
  }
};

const handleRegister = async (event, headers) => {
  try {
    console.log("Raw event.body:", event.body);
    const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    console.log("Parsed body:", body);
    
    const { 
      deviceId, userId, token, platform = "android", activeSessionId,
      manufacturer, deviceModel, osVersion, appVersion, buildNumber, locale
    } = body;

  if (!deviceId || !userId || !token) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ error: "Missing required fields: deviceId, userId, token" })
    };
  }

  const now = new Date().toISOString();
  const updateExpr = ["SET #token = :t", "platform = :p", "lastUserId = :u", "lastUpdated = :ts"];
  const attributeNames = {
    "#token": "token"
  };
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

  if (manufacturer) {
    updateExpr.push("manufacturer = :mfr");
    values[":mfr"] = { S: manufacturer };
  }

  if (deviceModel) {
    updateExpr.push("deviceModel = :mdl");
    values[":mdl"] = { S: deviceModel };
  }

  if (osVersion) {
    updateExpr.push("osVersion = :dv");
    values[":dv"] = { S: osVersion };
  }

  if (appVersion) {
    updateExpr.push("appVersion = :av");
    values[":av"] = { S: appVersion };
  }

  if (buildNumber) {
    updateExpr.push("buildNumber = :bn");
    values[":bn"] = { S: buildNumber };
  }

  if (locale) {
    updateExpr.push("locale = :loc");
    values[":loc"] = { S: locale };
  }

  const params = {
    TableName: TABLE_NAME,
    Key: { deviceId: { S: deviceId } },
    UpdateExpression: updateExpr.join(", "),
    ExpressionAttributeNames: attributeNames,
    ExpressionAttributeValues: values
  };
  
  console.log("DynamoDB UpdateItem params:", params);
  
  await client.send(new UpdateItemCommand(params));
  
  console.log("DynamoDB update successful");

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({
      message: "Device registered successfully",
      deviceId,
      userId
    })
  };
  } catch (err) {
    console.error("HandleRegister Error:", err);
    console.error("Error stack:", err.stack);
    throw err;
  }
};

const handleGet = async (event, headers) => {
  const { deviceId, userId } = event.queryStringParameters || {};

  if (!deviceId && !userId) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ error: "Either deviceId or userId parameter is required" })
    };
  }

  if (deviceId) {
    const result = await client.send(new GetItemCommand({
      TableName: TABLE_NAME,
      Key: { deviceId: { S: deviceId } }
    }));

    if (!result.Item) {
      return {
        statusCode: 404,
        headers,
        body: JSON.stringify({ error: "Device not found" })
      };
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ device: unmarshall(result.Item) })
    };
  }

  if (userId) {
    const result = await client.send(new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: "userIdIndex",
      KeyConditionExpression: "lastUserId = :u",
      ExpressionAttributeValues: { ":u": { S: userId } }
    }));

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ devices: result.Items.map(item => unmarshall(item)) })
    };
  }
};