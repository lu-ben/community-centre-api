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
  FROM client c;

INSERT INTO account VALUES ('blu', 'Ben', 'Lu', 1234, 'client');
INSERT INTO account VALUES ('kchua', 'Kelsey', 'Chua', 4444, 'client');
INSERT INTO account VALUES ('rzou', 'Raymond', 'Zou', 1234, 'client');
INSERT INTO account VALUES ('blu1', 'Ben', 'Lu', 1234, 'employee');
INSERT INTO account VALUES ('kchua1', 'Kelsey', 'Chua', 4444, 'employee');
INSERT INTO account VALUES ('rzou1', 'Raymond', 'Zou', 1234, 'employee');
INSERT INTO account VALUES ('jsmith', 'John', 'Smith', 1234, 'employee');
INSERT INTO account VALUES ('jsmith1', 'John', 'Smith', 1234, 'client');
INSERT INTO account VALUES ('msue', 'Mary', 'Sue', 1234, 'employee');
INSERT INTO account VALUES ('msue1', 'Mary', 'Sue', 1234, 'client');
INSERT INTO account VALUES ('child1', 'Child', 'One', 1234, 'client');
INSERT INTO account VALUES ('child2', 'Child', 'Two', 1234, 'client');
INSERT INTO account VALUES ('child3', 'Child', 'Three', 1234, 'client');
INSERT INTO account VALUES ('child4', 'Child', 'Four', 1234, 'client');
INSERT INTO account VALUES ('child5', 'Child', 'Five', 1234, 'client');
INSERT INTO account VALUES ('youth1', 'Youth', 'One', 1234, 'client');
INSERT INTO account VALUES ('youth2', 'Youth', 'Two', 1234, 'client');
INSERT INTO account VALUES ('youth3', 'Youth', 'Three', 1234, 'client');
INSERT INTO account VALUES ('youth4', 'Youth', 'Four', 1234, 'client');
INSERT INTO account VALUES ('youth5', 'Youth', 'Five', 1234, 'client');
INSERT INTO account VALUES ('adult1', 'Adult', 'One', 1234, 'client');
INSERT INTO account VALUES ('adult2', 'Adult', 'Two', 1234, 'client');
INSERT INTO account VALUES ('adult3', 'Adult', 'Three', 1234, 'client');
INSERT INTO account VALUES ('adult4', 'Adult', 'Four', 1234, 'client');
INSERT INTO account VALUES ('adult5', 'Adult', 'Five', 1234, 'client');
INSERT INTO account VALUES ('potterboy72', 'Harry', 'Potter', 1234, 'client');
INSERT INTO account VALUES ('chocolate', 'Charlie', 'Song', 1234, 'client');
INSERT INTO account VALUES ('garen', 'Garen', 'Top', 1234, 'client');
INSERT INTO account VALUES ('pstar32', 'Patrick', 'Star', 1234, 'client');
INSERT INTO account VALUES ('mario', 'Mario', 'Mushroom', 1234, 'client');
INSERT INTO account VALUES ('luigi', 'Luigi', 'Mushroom', 1234, 'client');
INSERT INTO account VALUES ('steve24', 'Steve', 'Chow', 1234, 'client');
INSERT INTO account VALUES ('james18', 'James', 'Lee', 1234, 'client');
INSERT INTO account VALUES ('johnnyboy', 'John', 'Doe', 1234, 'client');
INSERT INTO account VALUES ('darren', 'Darren', 'Song', 1234, 'client');
INSERT INTO account VALUES ('bowser12', 'Bowser', 'Shell', 1234, 'employee');

INSERT INTO client (age, username) VALUES (21, 'blu');
INSERT INTO client (age, username) VALUES (20, 'kchua');
INSERT INTO client (age, username) VALUES (22, 'rzou');
INSERT INTO client (age, username) VALUES (40, 'jsmith1');
INSERT INTO client (age, username) VALUES (30, 'msue1');
INSERT INTO client (age, username) VALUES (11, 'child1');
INSERT INTO client (age, username) VALUES (10, 'child2');
INSERT INTO client (age, username) VALUES (8, 'child3');
INSERT INTO client (age, username) VALUES (9, 'child4');
INSERT INTO client (age, username) VALUES (10, 'child5');
INSERT INTO client (age, username) VALUES (12, 'youth1');
INSERT INTO client (age, username) VALUES (16, 'youth2');
INSERT INTO client (age, username) VALUES (14, 'youth3');
INSERT INTO client (age, username) VALUES (13, 'youth4');
INSERT INTO client (age, username) VALUES (17, 'youth5');
INSERT INTO client (age, username) VALUES (19, 'adult1');
INSERT INTO client (age, username) VALUES (34, 'adult2');
INSERT INTO client (age, username) VALUES (21, 'adult3');
INSERT INTO client (age, username) VALUES (30, 'adult4');
INSERT INTO client (age, username) VALUES (75, 'adult5');
INSERT INTO client (age, username) VALUES (19, 'potterboy72');
INSERT INTO client (age, username) VALUES (20, 'chocolate');
INSERT INTO client (age, username) VALUES (20, 'garen');
INSERT INTO client (age, username) VALUES (20, 'pstar32');
INSERT INTO client (age, username) VALUES (20, 'mario');
INSERT INTO client (age, username) VALUES (20, 'luigi');
INSERT INTO client (age, username) VALUES (15, 'steve24');
INSERT INTO client (age, username) VALUES (15, 'james18');
INSERT INTO client (age, username) VALUES (15, 'johnnyboy');
INSERT INTO client (age, username) VALUES (15, 'darren');

INSERT INTO employee (role, username) VALUES ('manager', 'blu1');
INSERT INTO employee (role, username) VALUES ('manager', 'kchua1');
INSERT INTO employee (role, username) VALUES ('manager', 'rzou1');
INSERT INTO employee (role, username) VALUES ('manager', 'jsmith');
INSERT INTO employee (role, username) VALUES ('manager', 'msue');
INSERT INTO employee (role, username) VALUES ('manager', 'bowser12');

INSERT INTO bulletin_post (created_at, title, content, is_public, created_by, approved_by) VALUES ('2023-06-11 13:40:00', 'Lost Cat', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', false, 5, null);
INSERT INTO bulletin_post (created_at, title, content, is_public, created_by, approved_by) VALUES ('2023-06-11 13:40:00', 'Lost Dog', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', false, 4, null);
INSERT INTO bulletin_post (created_at, title, content, is_public, created_by, approved_by) VALUES ('2023-06-11 13:40:00', 'Garage Sale', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', true, 1, 1);
INSERT INTO bulletin_post (created_at, title, content, is_public, created_by, approved_by) VALUES ('2023-06-11 13:40:00', 'Free cookies', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', true, 2, 1);
INSERT INTO bulletin_post (created_at, title, content, is_public, created_by, approved_by) VALUES ('2023-06-11 13:40:00', 'Donut Sale', 'Lorem ipsum dolor sit amet,. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes vulputate eget, arcu.', true, 3, 1);

INSERT INTO announcement (title, message, created_by, created_at) VALUES ('Class Registration Now Open', 'Multiple classes has just opened for registration. Check the registration tab for more information.', 1, '2023-06-11 17:30');
INSERT INTO announcement (title, message, created_by, created_at) VALUES ('Pool Closed for Maintenance', 'The swimming pool will be closed for maintenance until further notice.', 1, '2023-06-11 17:35');
INSERT INTO announcement (title, message, created_by, created_at) VALUES ('Lat Pulldown Broken', 'The lat pulldown machine is once again broken. We apologize for the inconvenience.', 1, '2023-06-11 17:40');
INSERT INTO announcement (title, message, created_by, created_at) VALUES ('Annual Swim Meet', 'There will be a swim meet on June 20th, Tuesday. As such the pool will be closed to public access for the entire day.', 1, '2023-06-11 17:45');
INSERT INTO announcement (title, message, created_by, created_at) VALUES ('New Benches Installed', 'New benches for the gymnasiums have arrived and installed, please take care of them!', 1, '2023-06-11 17:50');

INSERT INTO facility VALUES ('Gymnasium A');
INSERT INTO facility VALUES ('Gymnasium B');
INSERT INTO facility VALUES ('Gymnasium C');
INSERT INTO facility VALUES ('Studio A');
INSERT INTO facility VALUES ('Studio B');
INSERT INTO facility VALUES ('Weight Room');
INSERT INTO facility VALUES ('Swimming Pool');
INSERT INTO facility VALUES ('Combatant Room');

INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 11:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 12:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('adult', '2023-06-30 13:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 14:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('adult', '2023-06-30 15:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 11:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 12:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 13:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 14:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-30 15:30:00', 24, 'Gymnasium B', 'drop-in');

INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 11:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 12:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('adult', '2023-06-13 13:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 14:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('adult', '2023-06-13 15:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 11:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 12:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 13:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 14:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-06-13 15:30:00', 24, 'Gymnasium B', 'drop-in');

INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('adult', '2023-07-25 13:30:00', 20, 'Weight Room', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-07-25 12:30:00', 20, 'Weight Room', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES 
('youth', '2023-07-23 12:30:00', 20, 'Studio B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES 
('all', '2023-07-23 11:30:00', 24, 'Studio B', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES 
('youth', '2023-07-12 11:30:00', 20, 'Combatant Room', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES 
('all', '2023-07-12 12:30:00', 20, 'Combatant Room', 'program');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('child', '2023-07-30 12:30:00', 24, 'Studio A', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('all', '2023-07-30 13:30:00', 24, 'Studio A', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('child', '2023-07-25 12:30:00', 20, 'Swimming Pool', 'drop-in');
INSERT INTO event (age_range, date, capacity, facility_name, event_type) VALUES ('youth', '2023-07-25 13:30:00', 20, 'Swimming Pool', 'drop-in');

INSERT INTO program VALUES (1, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (2, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (3, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (4, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (5, 'Volleyball Lesson', 'one-time', 2);
INSERT INTO program VALUES (11, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (12, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (13, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (14, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (15, 'Volleyball Lesson', 'one-time', 2);

INSERT INTO drop_in VALUES (6, 'volleyball');
INSERT INTO drop_in VALUES (7, 'badminton');
INSERT INTO drop_in VALUES (8, 'basketball');
INSERT INTO drop_in VALUES (9, 'volleyball');
INSERT INTO drop_in VALUES (10, 'badminton');
INSERT INTO drop_in VALUES (16, 'volleyball');
INSERT INTO drop_in VALUES (17, 'badminton');
INSERT INTO drop_in VALUES (18, 'basketball');
INSERT INTO drop_in VALUES (19, 'volleyball');
INSERT INTO drop_in VALUES (20, 'badminton');

INSERT INTO event_price VALUES ('child', 20, 3);
INSERT INTO event_price VALUES ('youth', 20, 5);
INSERT INTO event_price VALUES ('adult', 20, 6);
INSERT INTO event_price VALUES ('child', 24, 2);
INSERT INTO event_price VALUES ('youth', 24, 4);
INSERT INTO event_price VALUES ('adult', 24, 5);

INSERT INTO event_sign_up VALUES (1, 1, '2023-06-11 17:15:00');
INSERT INTO event_sign_up VALUES (1, 2, '2023-06-11 17:16:00');
INSERT INTO event_sign_up VALUES (1, 3, '2023-06-11 17:17:00');
INSERT INTO event_sign_up VALUES (1, 4, '2023-06-11 17:18:00');
INSERT INTO event_sign_up VALUES (1, 5, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (2, 1, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (2, 2, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (2, 3, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (2, 4, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (2, 5, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 11, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 12, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 13, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 14, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 15, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 16, '2023-06-11 17:19:00');
INSERT INTO event_sign_up VALUES (1, 17, '2023-06-11 17:19:00');
INSERT INTO event_sign_up (client_id, event_id) VALUES (3, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (4, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (5, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (6, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (7, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (8, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (9, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (10, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (11, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (12, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (13, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (14, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (15, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (16, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (17, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (18, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (19, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (20, 1);
INSERT INTO event_sign_up (client_id, event_id) VALUES (1, 8);
INSERT INTO event_sign_up (client_id, event_id) VALUES (1, 10);
INSERT INTO event_sign_up (client_id, event_id) VALUES (1, 19);
INSERT INTO event_sign_up (client_id, event_id) VALUES (1, 20);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 6);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 7);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 8);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 9);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 10);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 11);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 12);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 13);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 14);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 15);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 16);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 17);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 18);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 19);
INSERT INTO event_sign_up (client_id, event_id) VALUES (2, 20);
INSERT INTO event_sign_up (client_id, event_id) VALUES (11, 23);
INSERT INTO event_sign_up (client_id, event_id) VALUES (12, 23);
INSERT INTO event_sign_up (client_id, event_id) VALUES (13, 25);
INSERT INTO event_sign_up (client_id, event_id) VALUES (14, 25);
INSERT INTO event_sign_up (client_id, event_id) VALUES (15, 25);
INSERT INTO event_sign_up (client_id, event_id) VALUES (11, 30);
INSERT INTO event_sign_up (client_id, event_id) VALUES (12, 30);
INSERT INTO event_sign_up (client_id, event_id) VALUES (21, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (22, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (23, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (24, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (25, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (26, 21);
INSERT INTO event_sign_up (client_id, event_id) VALUES (11, 22);
INSERT INTO event_sign_up (client_id, event_id) VALUES (21, 22);
INSERT INTO event_sign_up (client_id, event_id) VALUES (12, 24);
INSERT INTO event_sign_up (client_id, event_id) VALUES (13, 24);
INSERT INTO event_sign_up (client_id, event_id) VALUES (22, 24); 
INSERT INTO event_sign_up (client_id, event_id) VALUES (23, 24);

INSERT INTO equipment VALUES (1, 'Frisbee', 'Gymnasium A');
INSERT INTO equipment VALUES (2, 'Kan Jam Set', 'Gymnasium B');
INSERT INTO equipment VALUES (3, 'Yoga Mat', 'Studio A');
INSERT INTO equipment VALUES (4, 'Yoga Mat', 'Studio B');
INSERT INTO equipment VALUES (5, 'Spikeball Set', 'Gymnasium C');
INSERT INTO equipment VALUES (6, 'Skipping Rope', 'Gymnasium A');

INSERT INTO borrow_equipment VALUES (2, 1, '2023-06-11 12:30:00', '2023-06-11 13:30:00');
INSERT INTO borrow_equipment VALUES (3, 2, '2023-06-11 12:30:00', '2023-06-11 13:30:00');
INSERT INTO borrow_equipment VALUES (4, 3, '2023-06-11 12:30:00', '2023-06-11 13:30:00');
INSERT INTO borrow_equipment VALUES (5, 4, '2023-06-11 12:30:00', '2023-06-11 13:30:00');
INSERT INTO borrow_equipment VALUES (2, 5, '2023-06-11 12:30:00', null);

INSERT INTO facility_announcement VALUES (2, 'Swimming Pool');
INSERT INTO facility_announcement VALUES (3, 'Weight Room');
INSERT INTO facility_announcement VALUES (4, 'Swimming Pool');
INSERT INTO facility_announcement VALUES (5, 'Gymnasium A');
INSERT INTO facility_announcement VALUES (5, 'Gymnasium B');
INSERT INTO facility_announcement VALUES (5, 'Gymnasium C');

INSERT INTO event_announcement VALUES (1, 1);
INSERT INTO event_announcement VALUES (1, 2);
INSERT INTO event_announcement VALUES (1, 3);
INSERT INTO event_announcement VALUES (1, 4);
INSERT INTO event_announcement VALUES (1, 5);
INSERT INTO event_announcement VALUES (5, 1);

INSERT INTO unscheduled_drop_in VALUES ('Weight Lifting', 'Weight Room');
INSERT INTO unscheduled_drop_in VALUES ('Swimming', 'Swimming Pool');
INSERT INTO unscheduled_drop_in VALUES ('Yoga', 'Studio B');
INSERT INTO unscheduled_drop_in VALUES ('Sauna', 'Swimming Pool');
INSERT INTO unscheduled_drop_in VALUES ('Cardio', 'Weight Room');

INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-11 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (2, '2023-06-11 10:00:00', 'Cardio');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-11 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (4, '2023-06-11 10:00:00', 'Swimming');
INSERT INTO go_to_unscheduled_drop_in VALUES (6, '2023-06-11 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (7, '2023-06-11 11:10:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (8, '2023-06-11 12:53:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (9, '2023-06-11 12:58:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (10, '2023-06-11 13:10:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (11, '2023-06-11 13:11:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (12, '2023-06-11 14:04:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (13, '2023-06-11 15:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (14, '2023-06-11 16:57:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (15, '2023-06-11 16:57:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (16, '2023-06-11 16:57:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-12 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-13 11:10:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-14 12:53:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-15 12:58:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (2, '2023-06-12 13:10:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (2, '2023-06-13 13:11:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (2, '2023-06-14 14:04:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-12 15:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-13 16:57:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-14 16:57:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-15 16:57:00', 'Weight Lifting');