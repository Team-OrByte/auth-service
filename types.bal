// ─────────────────────────────────────────────────────────────
// Auth Service — Core Types (Database per Service)
// ─────────────────────────────────────────────────────────────

import ballerina/http;

// ========== DB Row Models (mirror your auth DB) ==========

type AuthAccount record {|
    int id;
    string userId;           // mirrors id from user-service (no FK)
    string email;
    string passwordHash;
    string? lastLogin;       
    string createdAt;        
    string? updatedAt;     
    boolean isLocked = false;
    int failedLoginCount = 0; 
    string role ;
|};

type RefreshToken record {|
    int id;
    string userId;
    string token;         
    string expiresAt;        
    string createdAt;        
|};

type LoginAttempt record {|
    int id;
    string? userId;
    string email;
    boolean success;
    string attemptedAt;      // ISO-8601 string
    string? ipAddress;
    string? userAgent;
|};


type LoginRequest record {|
    string email;
    string password;
|};

type CreateAuthAccountRequest record {|
    string userId;
    string email;
    string passwordPlaintext; 
    string role;
|};

type RefreshRequest record {|
    string refreshToken;
|};

// Optional logout (server-side revoke)
type RevokeRefreshRequest record {|
    string refreshToken;
|};

// Optional password change (authenticated)
type ChangePasswordRequest record {|
    string currentPassword;
    string newPassword;
|};

// Optional start/reset flows (email-based)
type StartPasswordResetRequest record {|
    string email;
|};

type CompletePasswordResetRequest record {|
    string resetToken;
    string newPassword;
|};



type TokenPair record {|
    string accessToken;
    string refreshToken;
    string tokenType = "Bearer";
    int   expiresIn;         // access token TTL in seconds
|};

type TokenOnlyResponse record {|
    string accessToken;
    string tokenType = "Bearer";
    int   expiresIn;
|};

type ApiMessageResponse record {|
    string message;
|};

type ErrorResponse record {|
    string message;
    int status = 400;
|};

// Optional: standard envelope you can reuse
type ApiResponse record {|
    string message;
    anydata data?;
|};

// ========== JWT Claims (what you’ll encode into accessToken) ==========

type JwtClaims record {|
    string sub;              // userId
    string iss;              // e.g., "cycle-share-auth"
    int exp;                 // epoch seconds
    string? email;
    string[]? roles;         // optional (fetched from user-service at login)
    // add custom claims as needed: "tenantId", "scopes", etc.
|};

// ========== Config Types (service config/env mapping) ==========

type JwtConfig record {|
    string issuer;
    string secret;           // HMAC secret or private key (if using JWS)
    int accessTokenTtlSec;   // e.g., 900 (15 mins)
    int refreshTokenTtlSec;  // e.g., 2592000 (30 days)
    string? audience;
|};

type HashingConfig record {|
    string algorithm;        // "argon2id" | "bcrypt" | "pbkdf2-sha256"
    int iterations?;         // for PBKDF2
    int memoryKb?;           // for Argon2
    int parallelism?;        // for Argon2
    int saltBytes?;          // recommended: 16+
|};


// Uniform HTTP error helper (optional)
function httpError(int code, string msg) returns http:Response {
    http:Response r = new;
    r.statusCode = code;
    r.setJsonPayload({ message: msg, status: code });
    return r;
}

type AuthAccountIn record {|
    string userId;
    string email;
    string password;      
    string[] roles = ["user"]; // ["user"] or ["admin","user"]
|};

type AuthAccountOut record {|
    int id;
    string userId;
    string email;
    string[] roles;
    boolean isLocked;
    int failedLoginCount;
    string createdAt;
    string? updatedAt;
|};

type AuthAccountUpdate record {|
    string? email;
    string? password;
    string[]? roles;
    boolean? isLocked;
|};


public type Claims record {|
    string? userId;
    string? email;
    string? role;
|};