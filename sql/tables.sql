CREATE TYPE user_type AS ENUM ('client', 'employee');

CREATE TABLE IF NOT EXISTS account (
  username VARCHAR(255) PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  pin INT NOT NULL,
  user_type user_type NOT NULL
)