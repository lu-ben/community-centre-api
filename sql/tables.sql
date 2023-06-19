CREATE TYPE account_type AS ENUM ('client', 'employee');
CREATE TYPE event_type AS ENUM ('program', 'drop-in');
CREATE TYPE role AS ENUM ('instructor', 'receptionist', 'manager');
CREATE TYPE age_range AS ENUM ('child', 'youth', 'adult', 'all');
CREATE TYPE program_frequency AS ENUM ('one-time', 'weekly', 'biweekly');
CREATE TYPE drop_in_sport AS ENUM ('basketball', 'volleyball', 'badminton', 'table tennis', 'pickleball');

CREATE TABLE IF NOT EXISTS account (
  username VARCHAR(255) PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255),
  pin INT NOT NULL,
  account_type account_type NOT NULL
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

CREATE TABLE IF NOT EXISTS facility (
  facility_name VARCHAR(255) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS event (
  event_id SERIAL PRIMARY KEY,
  age_range age_range,
  date TIMESTAMP NOT NULL,
  capacity INT NOT NULL,
  facility_name VARCHAR(255) NOT NULL,
  event_type event_type NOT NULL,
  FOREIGN KEY (facility_name) REFERENCES facility (facility_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS event_price (
  age_range age_range,
  capacity INT NOT NULL,
  price DECIMAL NOT NULL,
  PRIMARY KEY (age_range, capacity)
);

CREATE TABLE IF NOT EXISTS program (
  event_id INT PRIMARY KEY,
  program_name VARCHAR(255) NOT NULL,
  frequency program_frequency NOT NULL,
  instructed_by INT NOT NULL,
  FOREIGN KEY (event_id) REFERENCES event (event_id) ON DELETE CASCADE,
  FOREIGN KEY (instructed_by) REFERENCES employee (employee_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS drop_in (
  event_id INT PRIMARY KEY,
  sport drop_in_sport NOT NULL,
  FOREIGN KEY (event_id) REFERENCES event (event_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS event_sign_up (
  client_id INT,
  event_id INT,
  enroll_date TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (client_id, event_id),
  FOREIGN KEY (client_id) REFERENCES client (client_id) ON DELETE CASCADE,
  FOREIGN KEY (event_id) REFERENCES event (event_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS equipment (
  equipment_id SERIAL PRIMARY KEY,
  equipment_name VARCHAR(255) NOT NULL,
  facility_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (facility_name) REFERENCES facility (facility_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS borrow_equipment (
  client_id INT,
  equipment_id INT,
  borrow_date TIMESTAMP DEFAULT NOW(),
  return_date TIMESTAMP,
  PRIMARY KEY (client_id, equipment_id, borrow_date),
  FOREIGN KEY (client_id) REFERENCES client (client_id) ON DELETE CASCADE,
  FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bulletin_post (
  post_id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT NOW(),
  title VARCHAR(255),
  content TEXT,
  is_public BOOLEAN DEFAULT false,
  created_by INT NOT NULL,
  approved_by INT,
  FOREIGN KEY (created_by) REFERENCES client (client_id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES employee (employee_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS announcement (
  announcement_id SERIAL PRIMARY KEY,
  title VARCHAR(255),
  message TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (created_by) REFERENCES employee (employee_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS facility_announcement (
  announcement_id INT,
  facility_name VARCHAR(255),
  PRIMARY KEY (announcement_id, facility_name),
  FOREIGN KEY (announcement_id) REFERENCES announcement (announcement_id) ON DELETE CASCADE,
  FOREIGN KEY (facility_name) REFERENCES facility (facility_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS event_announcement (
  announcement_id INT,
  event_id INT,
  PRIMARY KEY (announcement_id, event_id),
  FOREIGN KEY (announcement_id) REFERENCES announcement (announcement_id) ON DELETE CASCADE,
  FOREIGN KEY (event_id) REFERENCES event (event_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS unscheduled_drop_in (
  activity VARCHAR(255) PRIMARY KEY,
  facility_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (facility_name) REFERENCES facility (facility_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS go_to_unscheduled_drop_in (
  client_id INT,
  date TIMESTAMP,
  activity VARCHAR(255) NOT NULL,
  PRIMARY KEY (client_id, date),
  FOREIGN KEY (activity) REFERENCES unscheduled_drop_in (activity) ON DELETE CASCADE,
  FOREIGN KEY (client_id) REFERENCES client (client_id) ON DELETE CASCADE
);

CREATE VIEW client_with_age_ranges AS
  SELECT 
    *, 
    CASE 
      WHEN c.age <= 11 THEN 'child'
      WHEN c.age > 11 AND c.age < 18 THEN 'youth'
      WHEN c.age >= 18 THEN 'adult'
    END AS age_range 
  FROM client c