CREATE TYPE user_type AS ENUM ('client', 'employee');
CREATE TYPE role AS ENUM ('instructor', 'receptionist', 'manager');

CREATE TABLE IF NOT EXISTS account (
  username VARCHAR(255) PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  pin INT NOT NULL,
  user_type user_type NOT NULL
);

CREATE TABLE IF NOT EXISTS employee (
  employee_id SERIAL PRIMARY KEY,
  role role,
  username VARCHAR(255) NOT NULL UNIQUE,
  FOREIGN KEY (username) REFERENCES account (username) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS client (
  client_id SERIAL PRIMARY KEY,
  age INT,
  username VARCHAR(255) NOT NULL UNIQUE,
  FOREIGN KEY (username) REFERENCES account (username) ON DELETE CASCADE
);