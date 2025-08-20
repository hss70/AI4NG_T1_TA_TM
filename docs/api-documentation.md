# EEG Processing Pipeline API Documentation

## Base URL
```
https://{api-id}.execute-api.{region}.amazonaws.com/dev
```

## Authentication
All endpoints require JWT authentication via `Authorization: Bearer {token}` header.

## Endpoints

### GET /api/status/{sessionId}
Get processing status for a specific session.

**Parameters:**
- `sessionId` (path, required): Numeric session ID

**Response:**
```json
{
  "sessionName": "string",
  "sessionId": 123456789,
  "status": "PROCESSING|COMPLETED|FAILED|UNKNOWN",
  "userId": "string",
  "startTime": 1234567890,
  "startTimeISO": "2024-01-01T12:00:00Z",
  "processingDuration": 300,
  "resultsPath": "string",
  "exitCode": 0
}
```

**Status Codes:**
- `200`: Success
- `404`: Session not found
- `500`: Server error

### GET /api/status
Get all processing sessions with optional filtering.

**Query Parameters:**
- `status` (optional): Filter by status (`PROCESSING`, `COMPLETED`, `FAILED`, `UNKNOWN`)

**Response:**
```json
{
  "sessions": [
    {
      "sessionName": "string",
      "sessionId": 123456789,
      "status": "COMPLETED",
      "userId": "string",
      "startTime": 1234567890,
      "startTimeISO": "2024-01-01T12:00:00Z",
      "processingDuration": 300,
      "resultsPath": "string",
      "exitCode": 0
    }
  ],
  "count": 1
}
```

**Status Codes:**
- `200`: Success
- `500`: Server error

## Status Values
- `PROCESSING`: Session is currently being processed
- `COMPLETED`: Processing finished successfully
- `FAILED`: Processing failed with errors
- `UNKNOWN`: Status could not be determined

## Error Response Format
```json
{
  "error": "Error message description"
}
```