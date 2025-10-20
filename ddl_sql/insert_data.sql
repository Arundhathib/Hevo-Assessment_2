INSERT INTO assignment2.customers_raw VALUES
(101, 'John@example.co\nm', '111-222-\n3333', 'US', '2025-07-01 10:15:00', '2025-01-01 08:00:00'),
(101, 'john.d@example.c\nom', '(111)222333\n3', 'usa', '2025-07-03 14:25:00', '2025-01-01 08:00:00'),
(102, 'alice@example.co\nm', NULL, 'UnitedStates', '2025-07-01 09:10:00', NULL),
(103, 'michael@abc.com', '9998887777', NULL, '2025-07-02 12:45:00', '2025-03-01 10:00:00'),
(104, 'bob@xyz.com', NULL, 'IND', '2025-07-05 15:00:00', '2025-03-10 09:30:00'),
(104, 'bob@xyz.com', NULL, 'India', '2025-07-06 18:00:00', '2025-03-10 09:30:00'),
(106, 'duplicate@email.c\nom', '1234567890', 'SINGAPORE', '2025-07-01 08:00:00', '2025-04-01 11:45:00'),
(106, 'duplicate@email.c\nom', '123-456-\n7890', 'SG', '2025-07-10 12:00:00', '2025-04-01 11:45:00'),
(108, NULL, NULL, NULL, NULL, NULL);

INSERT INTO assignment2.orders_raw VALUES
(5001,101,'P01',120.00,'2025-07-10 09:00:00','USD'),
(5002,102,'P02',80.5,'2025-07-10 09:05:00','usd'),
(5003,103,NULL,200.00,'2025-07-10 09:15:00','INR'),
(5004,105,'P99',NULL,'2025-07-10 09:20:00',NULL),
(5002,102,'P02',80.50,'2025-07-10 09:05:00','USD'),
(5005,106,'P03',-50,'2025-07-10 09:25:00','SGD'),
(5006,107,NULL,300,'2025-07-11 10:00:00','usd'),
(5007,108,'P04',500,'2025-07-11 10:15:00','EUR');

INSERT INTO assignment2.products_raw VALUES
('P01','keyboard','hardware','Y'),
('P02','MOUSE','Hardware','Y'),
('P03','Monitor','Hardware','N'),
('P04','Premium Cable','Accessory','Y');

INSERT INTO assignment2.country_dim VALUES
('United States','US'),
('India','IN'),
('Singapore','SG'),
('Unknown',NULL);
