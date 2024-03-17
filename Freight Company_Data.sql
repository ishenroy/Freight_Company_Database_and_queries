CREATE TABLE `Location`( location_id INT PRIMARY KEY AUTO_INCREMENT, location_name VARCHAR(100));

CREATE TABLE `Container`( container_id INT PRIMARY KEY AUTO_INCREMENT, weight FLOAT, value FLOAT, origin INT, destination INT,
    FOREIGN KEY (origin) REFERENCES Location(location_id),
    FOREIGN KEY (destination) REFERENCES Location(location_id));

CREATE TABLE `Ship`(ship_id INT PRIMARY KEY AUTO_INCREMENT, weight_capacity FLOAT, container_capacity INT);

CREATE TABLE ShipAtLocation(ship_id INT PRIMARY KEY, origin_id INT,
    FOREIGN KEY (ship_id) REFERENCES Ship(ship_id),
    FOREIGN KEY (origin_id ) REFERENCES Location(location_id));

CREATE TABLE ShipGoingToLocation(ship_id INT PRIMARY KEY, destination_id INT,
    FOREIGN KEY (ship_id) REFERENCES Ship(ship_id),
    FOREIGN KEY (destination_id ) REFERENCES Location(location_id));

CREATE TABLE ContainerOnShip(container_id INT PRIMARY KEY, ship_id INT,
    FOREIGN KEY (container_id) REFERENCES Container(container_id),
    FOREIGN KEY (ship_id) REFERENCES Ship(ship_id));

INSERT INTO Location(location_name)
VALUES
('Rotterdam'),
('Miami'),
('Hamburg');

INSERT INTO Ship(weight_capacity, container_capacity)
VALUES
(1000,100),
(10,2),
(200,2),
(100,10),
(100,10),
(300,10);

INSERT INTO ShipAtLocation(ship_id,origin_id)
VALUES
(1,1),
(2,1),
(3,2),
(4,2),
(5,3),
(6,3);

INSERT INTO Container(weight, value, origin, destination)
VALUES
(1,10,
     (SELECT location_id FROM Location WHERE location_name='Rotterdam'),
     (SELECT location_id FROM Location WHERE location_name='Miami')),
(10,20,
     (SELECT location_id FROM Location WHERE location_name='Rotterdam'),
     (SELECT location_id FROM Location WHERE location_name='Hamburg')),
(10,10,
     (SELECT location_id FROM Location WHERE location_name='Miami'),
     (SELECT location_id FROM Location WHERE location_name='Rotterdam')),
(50,40,
     (SELECT location_id FROM Location WHERE location_name='Miami'),
     (SELECT location_id FROM Location WHERE location_name='Hamburg')),
(30,10,
     (SELECT location_id FROM Location WHERE location_name='Hamburg'),
     (SELECT location_id FROM Location WHERE location_name='Rotterdam')),
(20,1000,
     (SELECT location_id FROM Location WHERE location_name='Hamburg'),
     (SELECT location_id FROM Location WHERE location_name='Miami'));

INSERT INTO ContainerOnShip(container_id,ship_id)
VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(6,6);
INSERT INTO ShipGoingToLocation(ship_id,destination_id)
SELECT ship_id, destination FROM Ship NATURAL JOIN ContainerOnShip NATURAL JOIN Container GROUP BY ship_id;