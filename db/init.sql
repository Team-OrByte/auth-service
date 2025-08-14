-- Create auth_accounts table
CREATE TABLE IF NOT EXISTS auth_accounts (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL UNIQUE, -- mirrors id from user-service
    email VARCHAR(300) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_count INT NOT NULL DEFAULT 0,
    role VARCHAR(50) NOT NULL DEFAULT 'user'
);

CREATE INDEX IF NOT EXISTS idx_auth_accounts_user_id ON auth_accounts (user_id);

CREATE INDEX IF NOT EXISTS idx_auth_accounts_email ON auth_accounts (email);