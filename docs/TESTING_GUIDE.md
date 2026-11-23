# LAWCCHECK Backend Testing Guide

## 1. Overview

This document describes the testing procedures for the LAWCCHECK Django REST API.

The main objectives are:

- Verify API functionality.
- Test JWT authentication and authorization.
- Verify lawyer-specific data isolation.
- Test CRUD operations for all major resources.
- Ensure users cannot access or modify another lawyer's records.

### Backend Environment

- Framework: Django REST Framework
- Authentication: JWT (SimpleJWT)
- Database: PostgreSQL (configured through environment variables)
- API documentation: `docs/API_DOCUMENTATION.md`
- Local development URL: `http://127.0.0.1:8000`

## 2. Test Accounts

Two additional lawyer accounts were used during previous backend testing.

| Account label | Purpose |
|---|---|
| Second Lawyer | Test access and data isolation between two lawyers |
| Test Lawyer | Test API functionality and authorization |

### Account Credentials

- Second Lawyer credentials are maintained separately in `sec_lawyer.txt`.
- Test Lawyer credentials are maintained separately in `test_lawyer.txt`.

**Security rules:**

- Never add passwords or authentication tokens to this document.
- Never commit credential files to GitHub.
- Use separate JWT access tokens for each lawyer.
- Do not use real client or confidential legal information during testing.

## 3. Starting the Backend

Open PowerShell and run:

```powershell
cd E:\MyProjects\lawccheck\backend
.\.venv\Scripts\Activate.ps1
python manage.py runserver
```

The development API should be available at:

```text
http://127.0.0.1:8000/
```

Keep the terminal running while performing API tests.

### Authentication

The API uses JWT authentication.

Login endpoint:

```text
POST /api/auth/login/
```

Include the access token in authenticated requests:

```text
Authorization: Bearer YOUR_ACCESS_TOKEN
```

Each lawyer must use their own access token when testing data isolation.

## 4. Obtaining JWT Tokens for Test Accounts

Each lawyer must authenticate separately to obtain their own access token.

### 4.1 Login as the Second Lawyer

Run the following in PowerShell:

```powershell
$secondPhone = Read-Host "Enter second lawyer phone number"
$secondPassword = [System.Net.NetworkCredential]::new(
    "",
    (Read-Host "Enter second lawyer password" -AsSecureString)
).Password

$secondLoginBody = @{
    phone_number = $secondPhone
    password = $secondPassword
} | ConvertTo-Json

$secondLogin = Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/auth/login/" `
    -Method POST `
    -ContentType "application/json" `
    -Body $secondLoginBody

$secondAccessToken = $secondLogin.access

$secondHeaders = @{
    Authorization = "Bearer $secondAccessToken"
}
```

### 4.2 Login as the Test Lawyer

```powershell
$testPhone = Read-Host "Enter test lawyer phone number"
$testPassword = [System.Net.NetworkCredential]::new(
    "",
    (Read-Host "Enter test lawyer password" -AsSecureString)
).Password

$testLoginBody = @{
    phone_number = $testPhone
    password = $testPassword
} | ConvertTo-Json

$testLogin = Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/auth/login/" `
    -Method POST `
    -ContentType "application/json" `
    -Body $testLoginBody

$testAccessToken = $testLogin.access

$testHeaders = @{
    Authorization = "Bearer $testAccessToken"
}
```

**Important:**

- Use the phone numbers and passwords from the corresponding private credential files.
- Keep the PowerShell session open while performing tests.
- Access tokens expire after 30 minutes according to the current backend configuration.
- Never publish tokens or passwords.

## 5. Multi-Lawyer Data Isolation Testing

### Objective

Verify that each lawyer can access only their own records.

The backend applies lawyer-specific filtering to:

- Clients
- Cases
- Hearings
- Tasks
- Documents
- Notifications

### Expected Security Behavior

| Test scenario | Expected result |
|---|---|
| Second Lawyer lists clients | Only their own clients |
| Test Lawyer lists clients | Only their own clients |
| Second Lawyer requests Test Lawyer's client ID | 404 Not Found |
| Test Lawyer requests Second Lawyer's client ID | 404 Not Found |
| Lawyer attempts to update another lawyer's record | 404 Not Found |
| Lawyer attempts to delete another lawyer's record | 404 Not Found |

The same ownership checks should be verified for cases, hearings, tasks and documents.

**Note:** A 404 response is expected when a record is outside the authenticated lawyer's filtered queryset. Do not assume every unauthorized request must return 403.

## 6. Practical Client Data Isolation Tests

### 6.1 Retrieve Clients for Each Lawyer

First, retrieve the client records belonging to the Second Lawyer:

```powershell
$secondClients = Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/clients/" `
    -Method GET `
    -Headers $secondHeaders

$secondClients | Format-Table id, full_name, phone_number
```

Next, retrieve the client records belonging to the Test Lawyer:

```powershell
$testClients = Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/clients/" `
    -Method GET `
    -Headers $testHeaders

$testClients | Format-Table id, full_name, phone_number
```

**Expected result:** Each account should receive only its own client records.

Record one client ID from each lawyer's results:

```powershell
$secondClientId = Read-Host "Enter a client ID belonging to Second Lawyer"
$testClientId = Read-Host "Enter a client ID belonging to Test Lawyer"
```

### 6.2 Test Cross-Lawyer Access

Test whether the Second Lawyer can access a client belonging to the Test Lawyer:

```powershell
try {
    Invoke-RestMethod `
        -Uri "http://127.0.0.1:8000/api/clients/$testClientId/" `
        -Method GET `
        -Headers $secondHeaders

    Write-Host "FAIL: Second Lawyer accessed another lawyer's client."
}
catch {
    if ($_.Exception.Response -and
        [int]$_.Exception.Response.StatusCode -eq 404) {
        Write-Host "PASS: Access denied with 404 Not Found."
    }
    else {
        Write-Host "Unexpected result:"
        Write-Host $_.Exception.Message
    }
}
```

Now test the reverse:

```powershell
try {
    Invoke-RestMethod `
        -Uri "http://127.0.0.1:8000/api/clients/$secondClientId/" `
        -Method GET `
        -Headers $testHeaders

    Write-Host "FAIL: Test Lawyer accessed another lawyer's client."
}
catch {
    if ($_.Exception.Response -and
        [int]$_.Exception.Response.StatusCode -eq 404) {
        Write-Host "PASS: Access denied with 404 Not Found."
    }
    else {
        Write-Host "Unexpected result:"
        Write-Host $_.Exception.Message
    }
}
```

### 6.3 Expected Results

| Test | Expected result |
|---|---|
| Second Lawyer accesses own client | 200 OK |
| Test Lawyer accesses own client | 200 OK |
| Second Lawyer accesses Test Lawyer's client | 404 Not Found |
| Test Lawyer accesses Second Lawyer's client | 404 Not Found |

If either lawyer successfully retrieves another lawyer's client, investigate the client queryset and ownership filtering in `clients/views.py`.

**Important:** Run these tests using two different accounts that each have at least one client record. Do not treat an empty client list as proof that data isolation works.

## 7. Testing Data Isolation for Other Resources

The same lawyer-specific ownership rules must be verified for all remaining resources.

### 7.1 Cases

Endpoint:

```text
/api/cases/
```

Tests:

- Retrieve cases using `$secondHeaders`.
- Retrieve cases using `$testHeaders`.
- Try accessing a case ID belonging to the other lawyer.
- Try updating and deleting another lawyer's case.

Expected result: Each lawyer can access and modify only their own cases.

### 7.2 Hearings

Endpoint:

```text
/api/hearings/
```

Tests:

- Retrieve hearings using both lawyer accounts.
- Try accessing another lawyer's hearing ID.
- Try updating and deleting another lawyer's hearing.

Expected result: Hearings must belong to a case owned by the authenticated lawyer.

### 7.3 Tasks

Endpoint:

```text
/api/tasks/
```

Tests:

- Retrieve tasks using both lawyer accounts.
- Try accessing another lawyer's task ID.
- Try updating and deleting another lawyer's task.
- Try creating a task linked to another lawyer's case.

Expected result: A lawyer cannot access another lawyer's tasks or associate a task with another lawyer's case.

### 7.4 Documents

Endpoint:

```text
/api/documents/
```

Tests:

- Retrieve documents using both lawyer accounts.
- Try accessing another lawyer's document ID.
- Try downloading another lawyer's document.
- Try updating or deleting another lawyer's document.
- Try uploading a document linked to another lawyer's case.

Expected result: Only the owning lawyer can access, download, update or delete their documents.

### 7.5 Notifications

Endpoint:

```text
/api/notifications/
```

Tests:

- Retrieve notifications using both lawyer accounts.
- Verify unread notification counts separately.
- Try accessing another lawyer's notification ID.
- Try marking another lawyer's notification as read.
- Verify that `mark_all_read/` affects only the authenticated lawyer's notifications.

Expected result: Notifications must remain isolated between lawyers.

### 7.6 Test Results Record

Record the results after performing the tests.

| Resource | Second Lawyer | Test Lawyer | Cross-access test |
|---|---|---|---|
| Clients | PASS | PASS | PASS |
| Cases | PASS | PASS | PASS |
| Hearings | PASS | PASS | PASS |
| Tasks | PASS | PASS | PASS |
| Documents | PASS | PASS | PASS |
| Document Downloads | PASS | PASS | PASS |
| Notifications | PASS | PASS | PASS |
| Notification Updates | PASS | PASS | PASS |

Use these result labels:

- PASS — Expected security behavior confirmed.
- FAIL — Unexpected access or behavior observed.
- NOT TESTED — Test has not been performed.

## 8. Authentication and Authorization Tests

Verify the following scenarios:

| Test | Expected result |
|---|---|
| Request protected endpoint without token | 401 Unauthorized |
| Request protected endpoint with valid access token | Request accepted |
| Request with expired access token | 401 Unauthorized |
| Refresh using a valid refresh token | New access token returned |
| Logout using a valid refresh token | Successful logout |
| Use another lawyer's access token | Only that lawyer's own data is accessible |

## 9. Final Backend Testing Checklist

Use this checklist before considering backend testing complete.

### Authentication
- [x] Registration works.
- [x] Login works for both test accounts.
- [x] JWT refresh works.
- [x] Logout works.
- [x] Profile retrieval and update work.
- [x] Password change works.
- [ ] Phone number change verification works.

### Resource Management
- [ ] Client CRUD operations work.
- [ ] Case CRUD operations work.
- [ ] Hearing CRUD operations work.
- [ ] Task CRUD operations work.
- [x] Document upload and download work.
- [x] Notification listing and retrieval work.

### Security
- [ ] Unauthenticated requests are rejected.
- [x] Second Lawyer can access only their own records (tested across all six resource types).
- [x] Test Lawyer can access only their own records (tested across all six resource types).
- [x] Cross-lawyer record access is rejected.
- [ ] Cross-lawyer update and delete attempts are rejected (notification update isolation tested in both directions; other update and delete operations remain untested).
- [ ] Tasks, hearings and documents cannot be linked to another lawyer's case.
- [x] Notification access and update isolation works for both lawyers.

### Hearing Reminders
- [x] Reminder command executes successfully.
- [ ] Notifications are generated for hearings 7, 3 and 1 days before.
- [ ] Duplicate reminders are prevented.
- [x] Daily Windows Task Scheduler job is configured.

### Multi-Lawyer Data Isolation Test Results

| Resource | Second Lawyer | Test Lawyer | Cross-access |
|---|---|---|---|
| Clients | PASS | PASS | PASS |
| Cases | PASS | PASS | PASS |
| Hearings | PASS | PASS | PASS |
| Tasks | PASS | PASS | PASS |
| Documents | PASS | PASS | PASS |
| Document Downloads | PASS | PASS | PASS |
| Notifications | PASS | PASS | PASS |
| Notification Updates | PASS | PASS | PASS |

**Testing note:** Cross-lawyer access attempts returned HTTP 404 (`Not Found`) in both directions. Unauthorized document downloads and notification updates were also rejected.

## 10. Testing Notes

- Run tests against a development or test database.
- Use dummy client and legal case information.
- Never expose passwords, JWT tokens or confidential legal documents.
- Record actual results instead of assuming a test passed.
- Investigate every unexpected response before considering testing complete.

For endpoint details, request fields and response formats, refer to:

`docs/API_DOCUMENTATION.md`

---

**Document:** LAWCCHECK Backend Testing Guide

**Purpose:** Development, API verification and security testing

**Status:** Testing procedures documented; execution results must be recorded separately.