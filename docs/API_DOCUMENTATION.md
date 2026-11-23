# LAWCCHECK API Documentation

## 1. Overview

LAWCCHECK uses a Django REST Framework backend to manage lawyers' clients, cases, hearings, tasks, documents, and notifications.

| Property | Value |
|---|---|
| Backend | Django REST Framework |
| API prefix | `/api/` |
| Authentication | JWT (JSON Web Token) |
| Database | PostgreSQL |
| Timezone | UTC |
| Default permission | Authenticated users |
| Response format | JSON (except file downloads) |

## 2. Base URL

### Local development

```text
http://127.0.0.1:8000/api/
```

### Android Emulator

```text
http://10.0.2.2:8000/api/
```

For a physical Android device, use your computer's local network IP address instead of `127.0.0.1`. Both devices must be connected to the same network.

The production base URL will be added after backend deployment.

## 3. Authentication

LAWCCHECK uses JWT authentication.

All protected endpoints require the following HTTP header:

```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

For JSON requests, include:

```http
Content-Type: application/json
```

### 3.1 Register

**POST** `/api/auth/register/`

Authentication: Not required.

Request:

```json
{
  "phone_number": "01712345678",
  "first_name": "Rahim",
  "last_name": "Ahmed",
  "email": "rahim@example.com",
  "password": "StrongPassword123!",
  "password2": "StrongPassword123!"
}
```

Fields:

- `phone_number`: Required and unique.
- `first_name`: Optional.
- `last_name`: Optional.
- `email`: Optional.
- `password`: Required.
- `password2`: Required; must match the password.

Passwords are write-only and are not returned in the response.

### 3.2 Login

**POST** `/api/auth/login/`

Authentication: Not required.

Request:

```json
{
  "phone_number": "01712345678",
  "password": "StrongPassword123!"
}
```

Successful response:

```json
{
  "refresh": "YOUR_REFRESH_TOKEN",
  "access": "YOUR_ACCESS_TOKEN"
}
```

### 3.3 Refresh Access Token

**POST** `/api/auth/token/refresh/`

Authentication: Not required.

Request:

```json
{
  "refresh": "YOUR_REFRESH_TOKEN"
}
```

Returns a new access token. Refresh token rotation is enabled, so the response may also contain a new refresh token. Store the latest refresh token returned.

### 3.4 Get Profile

**GET** `/api/auth/profile/`

Authentication: Required.

Example response:

```json
{
  "id": 1,
  "phone_number": "01712345678",
  "first_name": "Rahim",
  "last_name": "Ahmed",
  "email": "rahim@example.com"
}
```

### 3.5 Update Profile

**PUT** `/api/auth/profile/`

**PATCH** `/api/auth/profile/`

Authentication: Required.

Example PATCH request:

```json
{
  "first_name": "Rahim",
  "last_name": "Ahmed",
  "email": "rahim@example.com"
}
```

`id` and `phone_number` are read-only through this serializer.

### 3.6 Logout

**POST** `/api/auth/logout/`

Authentication: Required.

Request:

```json
{
  "refresh": "YOUR_REFRESH_TOKEN"
}
```

Successful response:

```json
{
  "message": "Successfully logged out."
}
```

The supplied refresh token is blacklisted.

### 3.7 Request Phone Number Change

**POST** `/api/auth/phone/change/request/`

Authentication: Required.

Request:

```json
{
  "new_phone_number": "01812345678"
}
```

Successful response:

```json
{
  "message": "OTP generated successfully. It expires in 5 minutes."
}
```

When Django `DEBUG` is enabled, the response also includes `development_otp` for development and testing.

### 3.8 Verify Phone Number Change

**POST** `/api/auth/phone/change/verify/`

Authentication: Required.

Request:

```json
{
  "new_phone_number": "01812345678",
  "otp": "123456"
}
```

Successful response:

```json
{
  "message": "Phone number updated successfully.",
  "phone_number": "01812345678"
}
```

OTP expires after five minutes and has a maximum of five verification attempts.

### 3.9 Change Password

**POST** `/api/auth/password/change/`

Authentication: Required.

Request:

```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword123!",
  "confirm_new_password": "NewPassword123!"
}
```

The new password must pass Django password validation and match the confirmation.

After a successful password change, outstanding refresh tokens are blacklisted. The user must log in again.

## 4. Clients API

Base endpoint: `/api/clients/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/clients/` | List clients |
| POST | `/api/clients/` | Create client |
| GET | `/api/clients/{id}/` | Get client details |
| PUT | `/api/clients/{id}/` | Replace client |
| PATCH | `/api/clients/{id}/` | Partially update client |
| DELETE | `/api/clients/{id}/` | Delete client |

### Search clients

**GET** `/api/clients/?search=Rahim`

Search supports:
- Client name (`full_name`)
- Phone number (`phone_number`)

### Create client

**POST** `/api/clients/`

Request:

```json
{
  "full_name": "Rahim Ahmed",
  "phone_number": "01712345678",
  "email": "rahim@example.com",
  "address": "Agrabad, Chittagong",
  "notes": "Property dispute client"
}
```

Fields:

| Field | Required | Description |
|---|---|---|
| `full_name` | Yes | Client's full name |
| `phone_number` | No | Phone number |
| `email` | No | Email address |
| `address` | No | Client's address |
| `notes` | No | Additional notes |

Example response:

```json
{
  "id": 1,
  "full_name": "Rahim Ahmed",
  "phone_number": "01712345678",
  "email": "rahim@example.com",
  "address": "Agrabad, Chittagong",
  "notes": "Property dispute client",
  "created_at": "2026-11-22T10:00:00Z",
  "updated_at": "2026-11-22T10:00:00Z"
}
```

The backend automatically associates the client with the authenticated lawyer.

## 5. Cases API

Base endpoint: `/api/cases/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/cases/` | List cases |
| POST | `/api/cases/` | Create case |
| GET | `/api/cases/{id}/` | Get case details |
| PUT | `/api/cases/{id}/` | Replace case |
| PATCH | `/api/cases/{id}/` | Partially update case |
| DELETE | `/api/cases/{id}/` | Delete case |

### Create case

**POST** `/api/cases/`

Request:

```json
{
  "client": 1,
  "case_number": "CIV-2026-001",
  "title": "Property Dispute",
  "case_type": "Civil",
  "court_name": "District Court",
  "status": "pending",
  "filing_date": "2026-11-20",
  "next_hearing_date": "2026-12-10",
  "description": "Property ownership dispute."
}
```

Fields:

| Field | Required | Description |
|---|---|---|
| `client` | Yes | ID of an existing client belonging to the authenticated lawyer |
| `case_number` | No | Case reference number |
| `title` | Yes | Case title |
| `case_type` | No | Type of case |
| `court_name` | No | Court name |
| `status` | No | Case status; defaults to `pending` |
| `filing_date` | No | Filing date |
| `next_hearing_date` | No | Next hearing date |
| `description` | No | Case description |

Allowed case statuses:

- `pending`
- `ongoing`
- `completed`
- `dismissed`

The backend automatically associates the case with the authenticated lawyer.

## 6. Hearings API

Base endpoint: `/api/hearings/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/hearings/` | List hearings |
| POST | `/api/hearings/` | Create hearing |
| GET | `/api/hearings/{id}/` | Get hearing details |
| PUT | `/api/hearings/{id}/` | Replace hearing |
| PATCH | `/api/hearings/{id}/` | Partially update hearing |
| DELETE | `/api/hearings/{id}/` | Delete hearing |

### Create hearing

**POST** `/api/hearings/`

Request:

```json
{
  "case": 1,
  "hearing_date": "2026-12-10",
  "hearing_time": "10:30:00",
  "court_name": "District Court",
  "judge_name": "Judge Name",
  "status": "scheduled",
  "outcome": "",
  "notes": "Bring all original documents."
}
```

Fields:

| Field | Required | Description |
|---|---|---|
| `case` | Yes | ID of a case belonging to the authenticated lawyer |
| `hearing_date` | Yes | Hearing date |
| `hearing_time` | No | Hearing time |
| `court_name` | No | Court name |
| `judge_name` | No | Judge name |
| `status` | No | Hearing status; defaults to `scheduled` |
| `outcome` | No | Hearing outcome |
| `notes` | No | Additional notes |

Allowed hearing statuses:

- `scheduled`
- `completed`
- `postponed`
- `cancelled`

## 7. Tasks API

Base endpoint: `/api/tasks/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/tasks/` | List tasks |
| POST | `/api/tasks/` | Create task |
| GET | `/api/tasks/{id}/` | Get task details |
| PUT | `/api/tasks/{id}/` | Replace task |
| PATCH | `/api/tasks/{id}/` | Partially update task |
| DELETE | `/api/tasks/{id}/` | Delete task |

### Create task

**POST** `/api/tasks/`

Request:

```json
{
  "case": 1,
  "title": "Prepare legal documents",
  "description": "Prepare documents for the next hearing.",
  "due_date": "2026-12-05",
  "priority": "high",
  "status": "pending"
}
```

Fields:

| Field | Required | Description |
|---|---|---|
| `case` | No | Optional case ID belonging to the authenticated lawyer |
| `title` | Yes | Task title |
| `description` | No | Task description |
| `due_date` | No | Task due date |
| `priority` | No | Priority; defaults to `medium` |
| `status` | No | Task status; defaults to `pending` |

Allowed priorities:

- `low`
- `medium`
- `high`
- `urgent`

Allowed task statuses:

- `pending`
- `in_progress`
- `completed`
- `cancelled`

## 8. Documents API

Base endpoint: `/api/documents/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/documents/` | List documents |
| POST | `/api/documents/` | Upload document |
| GET | `/api/documents/{id}/` | Get document details |
| PUT | `/api/documents/{id}/` | Replace document |
| PATCH | `/api/documents/{id}/` | Partially update document |
| DELETE | `/api/documents/{id}/` | Delete document |
| GET | `/api/documents/{id}/download/` | Download document file |

### Upload document

**POST** `/api/documents/`

Authentication: Required.

Use `multipart/form-data` because the request contains a file.

Form fields:

| Field | Type | Required |
|---|---|---|
| `case` | Integer | No |
| `title` | String | Yes |
| `document_type` | String | No |
| `file` | File | Yes |
| `description` | String | No |

Example form values:

```text id="y6j7hr"
case: 1
title: Property Dispute Evidence
document_type: evidence
file: [selected file]
description: Supporting evidence for the case.
```

Allowed document types:

- `contract`
- `evidence`
- `court_order`
- `petition`
- `agreement`
- `other`

The default document type is `other`.

### Document response example

```json id="rj3hkw"
{
  "id": 1,
  "case": 1,
  "title": "Property Dispute Evidence",
  "document_type": "evidence",
  "file": "http://127.0.0.1:8000/media/legal_documents/evidence.pdf",
  "description": "Supporting evidence for the case.",
  "uploaded_at": "2026-11-22T10:00:00Z"
}
```

### Download document

**GET** `/api/documents/{id}/download/`

Authentication: Required.

Returns the document as a file attachment, not JSON.

The document must belong to the authenticated lawyer.

Do not use the `file` URL as a public download link. Use the authenticated download endpoint.

## 9. Notifications API

Base endpoint: `/api/notifications/`

Authentication: Required.

### Available operations

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/notifications/` | List notifications |
| POST | `/api/notifications/` | Create notification |
| GET | `/api/notifications/{id}/` | Get notification details |
| PUT | `/api/notifications/{id}/` | Replace notification |
| PATCH | `/api/notifications/{id}/` | Partially update notification |
| DELETE | `/api/notifications/{id}/` | Delete notification |
| GET | `/api/notifications/unread_count/` | Get unread notification count |
| POST | `/api/notifications/mark_all_read/` | Mark all notifications as read |

### Notification response example

```json id="4zyqbi"
{
  "id": 1,
  "title": "Upcoming Hearing",
  "message": "Your hearing is scheduled in 3 days.",
  "notification_type": "hearing",
  "is_read": false,
  "created_at": "2026-11-22T10:00:00Z"
}
```

Allowed notification types:

- `hearing`
- `task`
- `case`
- `document`
- `general`

### Filter notifications

Get all notifications:

`GET /api/notifications/`

Get unread notifications:

`GET /api/notifications/?is_read=false`

Get read notifications:

`GET /api/notifications/?is_read=true`

### Get unread count

**GET** `/api/notifications/unread_count/`

Example response:

```json id="b3v5gk"
{
  "unread_count": 3
}
```

### Mark all notifications as read

**POST** `/api/notifications/mark_all_read/`

Example response:

```json id="1sd7w3"
{
  "message": "All notifications marked as read.",
  "updated_count": 3
}
```

## 10. Date and Time Formats

Use the following formats in API requests:

| Field type | Format | Example |
|---|---|---|
| Date | `YYYY-MM-DD` | `2026-12-10` |
| Time | `HH:MM:SS` | `10:30:00` |
| DateTime | ISO 8601 | `2026-11-22T10:00:00Z` |

The backend uses UTC and timezone-aware datetimes.

Convert UTC datetimes to the user's local timezone when displaying them in Flutter.

## 11. Data Ownership and Security

- Every protected request must include a valid access token.
- Each lawyer can access only their own clients, cases, hearings, tasks, documents, and notifications.
- A client must belong to the authenticated lawyer when creating or updating a case.
- A case must belong to the authenticated lawyer when creating or updating a hearing.
- Optional case references in tasks and documents must also belong to the authenticated lawyer.
- The backend assigns ownership automatically. Do not send a `lawyer` field when creating resources.
- Document downloads require authentication and ownership verification.

## 12. Common HTTP Status Codes

| Status | Meaning |
|---|---|
| 200 | Request successful |
| 201 | Resource created |
| 204 | Resource deleted successfully |
| 400 | Invalid request or validation error |
| 401 | Missing, invalid, or expired authentication token |
| 403 | Permission denied |
| 404 | Resource not found |

Actual error response structures may vary by endpoint and validation failure.

## 13. Flutter Integration Notes

1. Store access and refresh tokens securely. Prefer secure storage instead of ordinary shared preferences.
2. Attach the access token to every protected API request.
3. When the access token expires, use the refresh endpoint.
4. Store the newest refresh token if token rotation returns one.
5. If token refresh fails, return the user to the login screen.
6. Use `multipart/form-data` for document uploads.
7. Use the authenticated document download endpoint.
8. Do not send `lawyer`, `id`, or automatically generated timestamp fields when creating resources.
9. Handle validation errors and unauthorized responses gracefully.
10. List endpoints currently have no configured pagination.

## 14. Backend Implementation Status

Implemented backend modules:

- User registration and JWT authentication
- Profile management
- Phone number change with OTP verification
- Password change
- Client management
- Case management
- Hearing management
- Task management
- Document upload and secure download
- Notification management
- Automated hearing reminder notifications

Hearing reminders currently generate in-app notifications. SMS, email, and push notification delivery are not implemented as part of the current reminder workflow.

---

**Note:** This document describes the current backend implementation. Update it whenever API endpoints, serializers, permissions, or response formats change.