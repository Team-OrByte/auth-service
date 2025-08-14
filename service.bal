import ballerina/crypto;
import ballerina/http;
import ballerina/jwt;
import ballerina/log;
import ballerina/sql;
import ballerinax/postgresql;
import ballerina/time;

configurable int db_port = ?;
configurable string db_host = ?;
configurable string db_pass = ?;
configurable string db_user = ?;
configurable string db_name = ?;

postgresql:Options postgresqlOptions = {
    connectTimeout: 10
};

postgresql:Client dbClient = check new (username = db_user, password = db_pass, database = db_name, host = db_host, port = db_port, options = postgresqlOptions);

function hashPassword(string pwd, string salt) returns string {
    return crypto:hashSha256((salt + ":" + pwd).toBytes()).toBase16();
}

service /auth on new http:Listener(8080) {

    resource function post login(@http:Payload LoginRequest req) returns ApiResponse {

        log:printInfo("Received request: POST /Login");

        sql:ParameterizedQuery q = `SELECT
        id,
        user_id AS userId,
        email,
        password_hash AS passwordHash,
        last_login AS lastLogin,
        created_at AS createdAt,
        updated_at AS updatedAt,
        is_locked AS isLocked,
        failed_login_count AS failedLoginCount
      FROM auth_accounts
      WHERE email = ${req.email}
      LIMIT 1`;

        stream<AuthAccount, sql:Error?> rs = dbClient->query(q, AuthAccount);

        if rs.count() == 0 {
            return {message: "invalid credentials", data: []};
        }

        AuthAccount[] users = [];

        error? e = rs.forEach(function(AuthAccount user) {
            users.push(user);
        });

        if e is error {
            log:printError("Error while processing users stream", err = e.toString());
            return {
                message: "Failed",
                data: []
            };
        }

        var verifyRes = crypto:verifyBcrypt(req.password, users[0].passwordHash);

        if verifyRes is error {
            log:printError("bcrypt verify failed", err = verifyRes.toString());
            return {message: "Failed", data: []};
        }

        boolean passwordMatch = verifyRes;

        if passwordMatch {
            jwt:IssuerConfig issuerConfig = {
                username: users[0].email,
                issuer: "Orbyte",
                audience: "vEwzbcasJVQm1jVYHUHCjhxZ4tYa",
                expTime: 3600,
                signatureConfig: {
                    config: {
                        keyFile: "private.key"
                    }
                },
                customClaims: {
                    scp: [users[0].role],
                    userId: users[0].id
                }
            };

            var tokenResult = jwt:issue(issuerConfig);
            if tokenResult is jwt:Error {
                log:printError("Failed to issue token", err = tokenResult.toString());
                return {message: "Failed to issue token", data: []};
            }
            string token = tokenResult;

            return {
                message: "success",
                data: token
            };

        } else {
            return {message: "Invalid credentials", data: []};
        }
    }

    resource function post createAccount(@http:Payload CreateAuthAccountRequest req) returns ApiResponse {

        log:printInfo("Received request: POST /createAccount");

        // Check if user already exists
        sql:ParameterizedQuery checkUserQuery = `SELECT id FROM auth_accounts WHERE email = ${req.email} LIMIT 1`;
        stream<AuthAccount, sql:Error?> checkUserStream = dbClient->query(checkUserQuery, AuthAccount);
        
        AuthAccount[] existingAccounts = [];

        error? e = checkUserStream.forEach(function(AuthAccount account) {
            existingAccounts.push(account);
        });

        if e is error {
            log:printError("Error while checking existing accounts", err = e.toString());
            return {message: "Failed to check existing accounts", data: []};
        }
        foreach var item in existingAccounts {
            log:printInfo("Existing account found: " + item.userId);
        }
        
        if existingAccounts.length() > 0 {
            return {message: "User already exists", data: []};
        }

        // Hash the password
        var passwordHash = crypto:hashBcrypt(req.passwordPlaintext);
        if passwordHash is error {
            return {message: " failed to create user", data: []};
        }
           // Insert new account
        time:Utc currentTime = time:utcNow();

        sql:ParameterizedQuery insertQuery = `INSERT INTO auth_accounts (user_id, email, password_hash, created_at, role)
                                              VALUES (${req.userId}, ${req.email}, ${passwordHash}, ${currentTime}, ${req.role})`;

        var insertResult = dbClient->execute(insertQuery);

        if insertResult is sql:Error {
            log:printError("Failed to create account", err = insertResult.toString());
            return {message: "Failed to create account", data: []};
        }

        return {message: "Account created successfully", data: [req.userId]};
    }
}
