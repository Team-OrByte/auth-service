import ballerina/crypto;
import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/postgresql;

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

        AuthAccount? account = rs.next();

        if account is () {
            return {message: "invalid credentials", data: []};
        }

        if account.value.isLocked {
            return {message: "account locked", data: []};
        }

    }
}
