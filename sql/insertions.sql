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

INSERT INTO client VALUES (1, 21, 'blu');
INSERT INTO client VALUES (2, 20, 'kchua');
INSERT INTO client VALUES (3, 22, 'rzou');
INSERT INTO client VALUES (4, 40, 'jsmith1');
INSERT INTO client VALUES (5, 30, 'msue1');

INSERT INTO employee VALUES (1, 'manager', 'blu1');
INSERT INTO employee VALUES (2, 'manager', 'kchua1');
INSERT INTO employee VALUES (3, 'manager', 'rzou1');
INSERT INTO employee VALUES (4, 'manager', 'jsmith');
INSERT INTO employee VALUES (5, 'manager', 'msue');

INSERT INTO facility VALUES ('Gymnasium A');
INSERT INTO facility VALUES ('Gymnasium B');
INSERT INTO facility VALUES ('Gymnasium C');
INSERT INTO facility VALUES ('Studio A');
INSERT INTO facility VALUES ('Studio B');
INSERT INTO facility VALUES ('Weight Room');
INSERT INTO facility VALUES ('Swimming Pool');
INSERT INTO facility VALUES ('Combatant Room');

INSERT INTO event VALUES (1, 'all', '2023-06-30 11:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event VALUES (2, 'all', '2023-06-30 12:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event VALUES (3, 'adult', '2023-06-30 13:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event VALUES (4, 'all', '2023-06-30 14:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event VALUES (5, 'adult', '2023-06-30 15:30:00', 20, 'Gymnasium A', 'program');
INSERT INTO event VALUES (6, 'all', '2023-06-30 11:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event VALUES (7, 'all', '2023-06-30 12:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event VALUES (8, 'all', '2023-06-30 13:30:00', 24, 'Gymnasium B', 'drop-in');
INSERT INTO event VALUES (9, 'all', '2023-06-30 14:30:00', 20, 'Gymnasium B', 'drop-in');
INSERT INTO event VALUES (10, 'all', '2023-06-30 15:30:00', 24, 'Gymnasium B', 'drop-in');

INSERT INTO program VALUES (1, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (2, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (3, 'Badminton Lesson', 'one-time', 1);
INSERT INTO program VALUES (4, 'Basketball Lesson', 'one-time', 1);
INSERT INTO program VALUES (5, 'Volleyball Lesson', 'one-time', 1);

INSERT INTO drop_in VALUES (6, 'volleyball');
INSERT INTO drop_in VALUES (7, 'badminton');
INSERT INTO drop_in VALUES (8, 'basketball');
INSERT INTO drop_in VALUES (9, 'volleyball');
INSERT INTO drop_in VALUES (10, 'badminton');

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

INSERT INTO bulletin_post VALUES (1,'2023-06-11 13:40:00', 'Lost Cat', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', false, 5, null);
INSERT INTO bulletin_post VALUES (2,'2023-06-11 13:40:00', 'Lost Dog', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', false, 4, null);
INSERT INTO bulletin_post VALUES (3,'2023-06-11 13:40:00', 'Garage Sale', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', true, 1, 1);
INSERT INTO bulletin_post VALUES (4,'2023-06-11 13:40:00', 'Free cookies', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu.', true, 2, 1);
INSERT INTO bulletin_post VALUES (5,'2023-06-11 13:40:00', 'Donut Sale', 'Lorem ipsum dolor sit amet,. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes vulputate eget, arcu.', true, 3, 1);

INSERT INTO announcement VALUES (1, 'Class Registration Now Open', 'Multiple classes has just opened for registration. Check the registration tab for more information.', 1, '2023-06-11 17:30');
INSERT INTO announcement VALUES (2, 'Pool Closed for Maintenance', 'The swimming pool will be closed for maintenance until further notice.', 1, '2023-06-11 17:35');
INSERT INTO announcement VALUES (3, 'Lat Pulldown Broken', 'The lat pulldown machine is once again broken. We apologize for the inconvenience.', 1, '2023-06-11 17:40');
INSERT INTO announcement VALUES (4, 'Annual Swim Meet', 'There will be a swim meet on June 20th, Tuesday. As such the pool will be closed to public access for the entire day.', 1, '2023-06-11 17:45');
INSERT INTO announcement VALUES (5, 'New Benches Installed', 'New benches for the gymnasiums have arrived and installed, please take care of them!', 1, '2023-06-11 17:50');

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

INSERT INTO unscheduled_drop_in VALUES ('Weight Lifting', 'Weight Room');
INSERT INTO unscheduled_drop_in VALUES ('Swimming', 'Swimming Pool');
INSERT INTO unscheduled_drop_in VALUES ('Yoga', 'Studio B');
INSERT INTO unscheduled_drop_in VALUES ('Sauna', 'Swimming Pool');
INSERT INTO unscheduled_drop_in VALUES ('Cardio', 'Weight Room');

INSERT INTO go_to_unscheduled_drop_in VALUES (1, '2023-06-11 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (2, '2023-06-11 10:00:00', 'Cardio');
INSERT INTO go_to_unscheduled_drop_in VALUES (3, '2023-06-11 10:00:00', 'Weight Lifting');
INSERT INTO go_to_unscheduled_drop_in VALUES (4, '2023-06-11 10:00:00', 'Swimming');
INSERT INTO go_to_unscheduled_drop_in VALUES (5, '2023-06-11 10:00:00', 'Yoga');
