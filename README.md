# Ballerina Authentication Service

[![CI](https://github.com/Team-OrByte/payment-service/actions/workflows/automation.yaml/badge.svg)](https://github.com/Team-OrByte/auth-service/actions/workflows/automation.yaml)
[![Docker Image](https://img.shields.io/badge/docker-thetharz%2Forbyte__auth__service-blue)]([https://hub.docker.com/r/thetharz/orbyte_payment_servic](https://hub.docker.com/r/thetharz/orbyte_auth_service)e)

A Ballerina-based authentication microservice that integrates with PostgreSQL for data persistence, bcrypt (via Ballerina crypto) for password hashing, and JWT for token issuance and verification. This service provides account creation, login, and a sample JWT-protected endpoint within the OrByte ride-hailing application ecosystem.

---

## How Ballerina is Used

This project leverages Ballerina's cloud-native capabilities and built-in connectors for:

- **Service Orchestration**: HTTP services for login and account creation, plus a secured endpoint on a separate listener<br>
- **Database Integration**: PostgreSQL connector for auth account storage<br>
- **API Security**: JWT issuance (private key) and validation (public certificate) with scope-based authorization<br>
- **Configuration Management**: External configuration for environment-specific settings
- **Observability & Logging**: Structured logs for auth and DB operations

### Key Ballerina Features Used

- Configurable variables for environment-specific settings
- Built-in connectors for HTTP and PostgreSQL
- JSON data binding and type-safe records
- Bcrypt hashing (crypto) for password verification
- JWT issuance/validation with issuer, audience, and scope checks
- Error handling and logging

## ⚙ Configuration Example

Create a `Config.toml` file with the following structure:

```toml
# PostgreSQL Configuration
db_host = "auth_service_db"
db_port = 5432
db_user = "auth_service_user"
db_pass = "qwertyui"
db_name = "auth_db"

# Key Paths (mounted inside the container/host path)
pvt_key = "private.key"
pub_key = "public.crt"
```

# Private key
Use this command to generate private key.
```bash
openssl genrsa -out private.key 2048
````
# Public certificate
use this command to generate the public key for the previously generated private key.
```
openssl req -new -x509 -key private.key -out public.crt -days 365
```

##  API Endpoints
#### REST Endpoints (Port 8080)
Base path: ```/auth```

#### Create Account

**Path**: `/createAccount`
**Method**: `POST`
**Request Body**:
```
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "email": "test@example.com",
  "passwordPlaintext": "mypassword",
  "role": "user"
}

```
#### Success Response:
```
{ "message": "Account created successfully", "data": ["550e8400-e29b-41d4-a716-446655440000"] }
```
#### Duplicate Response:
```
{ "message": "User already exists", "data": [] }
```
#### Login

**Path**: `/login`<br>
**Method**: `POST`<br>
**Request Body**:
```
{
  "email": "test@example.com",
  "password": "mypassword"
}
```
#### Success Response:
```
{
  "message": "success",
  "data": { "token": "<JWT>", "role": "user" }
}
```

#### Invalid Credentials:
```
{ "message": "Invalid credentials", "data": [] }
```
### JWT-Protected Sample (Port 9090)

**Path**: `/album`<br>
**Method**: `GET`<br>
**Auth**: `JWT (requires scope user)`

**Success Response**:
```
[
  { "title": "Blue Train", "artist": "John Coltrane" },
  { "title": "Jeru", "artist": "Gerry Mulligan" }
]
```
