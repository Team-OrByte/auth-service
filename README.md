# Ballerina Authentication Service

This project is a **JWT-secured authentication service** built with [Ballerina](https://ballerina.io/).  
It connects to a PostgreSQL database, allows account creation and login, and secures API endpoints with role-based JWT authorization.

---

## 📌 Features
- **User Registration** (`/auth/createAccount`)
- **User Login** with bcrypt password verification (`/auth/login`)
- **JWT Token Issuance** with custom claims
- **Role-based Authorization** using scopes (`scp`)
- **PostgreSQL Integration** with `ballerinax/postgresql`
- Example secured endpoint (`/album`) protected by JWT and scopes

---

## 🛠 Prerequisites
Before running the service, install:
- [Ballerina](https://ballerina.io/downloads/) (latest version)
- PostgreSQL database
- OpenSSL (for generating keys, if needed)

---

## 📂 Project Structure 
└── auth-service/
    ├── Ballerina.toml
    ├── Config.toml
    ├── Dependencies.toml
    ├── docker-compose.yml
    ├── main.bal
    ├── private.key
    ├── public.crt
    ├── service.bal
    ├── service.txt
    ├── types.bal
    ├── .devcontainer.json
    ├── db/
    │   └── init.sql
    ├── logs/
    ├── private.crt/
    └── public.key/



---

## ⚙ Configuration

All configuration is read from `Config.toml`:

```toml
db_port = 5432
db_host = "localhost"
db_pass = "your_db_password"
db_user = "your_db_user"
db_name = "your_db_name"

pvt_key = "/app/private.key"
pub_key = "/app/public.crt"
```

# Private key
```bash
openssl genrsa -out private.key 2048
````
# Public certificate
```
openssl req -new -x509 -key private.key -out public.crt -days 365
```

## 📡 API Endpoints
1️⃣ Create Account
```
curl -X POST http://localhost:8080/auth/createAccount \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "test@example.com",
    "passwordPlaintext": "mypassword",
    "role": "admin"
  }'
```
2️⃣ Login
```
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "mypassword"
  }'
```
The response will contain a JWT token.

3️⃣ Access Secured /album Endpoint

```
curl -k -X GET https://localhost:9090/album \
  -H "Authorization: Bearer <your-jwt-token>"

```
