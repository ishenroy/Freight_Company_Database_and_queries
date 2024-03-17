#Get the location_id for each ship
SELECT * FROM Ship NATURAL JOIN ShipAtLocation;


#Get the location_name for each ship
SELECT * FROM Ship NATURAL JOIN ShipAtLocation JOIN Location ON
ShipAtLocation.origin_id=Location.location_id;


#Get all ship_ids in Hamburg
SELECT * FROM Ship NATURAL JOIN ShipAtLocation JOIN Location ON
ShipAtLocation.origin_id=Location.location_id WHERE
location_name="Hamburg";

#Get all containers on ship 1
SELECT * FROM ContainerOnShip WHERE ship_id=1

#Get all containers on ships in Hamburg
SELECT * FROM ContainerOnShip NATURAL JOIN ShipAtLocation JOIN
Location ON ShipAtLocation.origin_id=Location.location_id WHERE
location_name="Hamburg";


#Get all ships which have reached their weight capacity (sum of container weights on ship are equal to the weight capacity)
SELECT * FROM ContainerOnShip NATURAL JOIN Ship NATURAL JOIN
Container GROUP BY ship_id HAVING SUM(weight)=weight_capacity;

#Get all ships which have reached their capacity by either weight or container count
SELECT * FROM ContainerOnShip NATURAL JOIN Ship NATURAL JOIN
Container GROUP BY ship_id HAVING SUM(weight)=weight_capacity OR
COUNT(container_id)=container_capacity;

#Also show the location of the ships (location_id)
SELECT * FROM ContainerOnShip NATURAL JOIN Ship NATURAL JOIN
Container NATURAL JOIN ShipAtLocation GROUP BY ship_id HAVING
SUM(weight)=weight_capacity OR
COUNT(container_id)=container_capacity;

#Also show the location of the ships (location_name)
SELECT * FROM ContainerOnShip NATURAL JOIN Ship NATURAL JOIN
Container NATURAL JOIN ShipAtLocation JOIN Location ON
ShipAtLocation.origin_id=Location.location_id GROUP BY ship_id
HAVING SUM(weight)=weight_capacity OR
COUNT(container_id)=container_capacity;

#Also show the total weight of each ship as a column
SELECT *,SUM(weight) FROM ContainerOnShip NATURAL JOIN Ship
NATURAL JOIN Container NATURAL JOIN ShipAtLocation JOIN Location
ON ShipAtLocation.origin_id=Location.location_id GROUP BY ship_id
HAVING SUM(weight)=weight_capacity OR
COUNT(container_id)=container_capacity;

#Get the lightest Ship in Hamburg
SELECT *,SUM(weight) FROM ContainerOnShip NATURAL JOIN Ship
NATURAL JOIN Container NATURAL JOIN ShipAtLocation JOIN Location
ON ShipAtLocation.origin_id=Location.location_id WHERE
location_name='Hamburg' GROUP BY ship_id ORDER BY SUM(weight)
LIMIT 1

#Get the lightest ship in Hamburg which has a free capacity of 100
SELECT *,SUM(weight) FROM ContainerOnShip NATURAL JOIN Ship
NATURAL JOIN Container NATURAL JOIN ShipAtLocation JOIN Location
ON ShipAtLocation.origin_id=Location.location_id WHERE
location_name='Hamburg' GROUP BY ship_id HAVING weight_capacitySUM(weight)>100 ORDER BY SUM(weight) LIMIT 1

#Get the lightest ship in Hamburg which has a free weight capacity of 100 and a free container capacity of 2
SELECT *,SUM(weight) FROM ContainerOnShip NATURAL JOIN Ship
NATURAL JOIN Container NATURAL JOIN ShipAtLocation JOIN Location
ON ShipAtLocation.origin_id=Location.location_id WHERE
location_name='Hamburg' GROUP BY ship_id HAVING weight_capacitySUM(weight)>=100 AND container_capacity-COUNT(container_id)>=2
ORDER BY SUM(weight) LIMIT 1

#Get all ships and their respective origin and destination
SELECT ship_id,Location1.location_name AS Origin, Location2.location_name AS
Destination FROM Ship NATURAL JOIN ShipAtLocation NATURAL JOIN
ShipGoingToLocation JOIN Location AS Location1 ON
origin_id=Location1.location_ID JOIN Location as Location2 ON
destination_id=Location2.location_id;

#Add a new ship with weight capacity 100, container capacity 10, that is currently in Hamburg
INSERT INTO Ship(weight_capacity, container_capacity)
VALUES(100,10);
INSERT INTO ShipAtLocation(ship_id,origin_id)
VALUES(
LAST_INSERT_ID(),
(SELECT location_id FROM Location WHERE location_name="Hamburg"));

#Get all ships that do not have a destination assigned.
SELECT * FROM Ship NATURAL LEFT JOIN ShipGoingToLocation WHERE
destination_id IS NULL;

#Create a trigger that assigns a newly added container to the lightest ship matching origin, destination and not exceeding the ship's capacity.
CREATE TRIGGER ContainerAssignment AFTER INSERT
ON Container
FOR EACH ROW
INSERT INTO ContainerOnShip(container_id,ship_id)
VALUES(NEW.container_id,
(SELECT ship_id FROM
(SELECT * FROM Ship
NATURAL JOIN ShipAtLocation
JOIN Location AS Origin ON Origin.location_id=ShipAtLocation.origin_id
NATURAL LEFT JOIN ContainerOnShip
NATURAL LEFT JOIN Container
NATURAL LEFT JOIN ShipGoingToLocation
WHERE
ShipAtLocation.origin_id=NEW.origin AND (ShipGoingToLocation.destination_id IS NULL OR
ShipGoingToLocation.destination_id=NEW.destination)
GROUP BY ship_id HAVING SUM(weight) + NEW.weight <= Ship.weight_capacity AND
COUNT(container_id) < Ship.container_capacity
ORDER BY ISNULL(weight), SUM(weight)
LIMIT 1)
AS SubQuery));


