-- This file is to bootstrap a database for the CS3200 project. 

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith 
-- data source creation.
create database elections;

-- Via the Docker Compose file, a special user called webapp will 
-- be created in MySQL. We are going to grant that user 
-- all privilages to the new database we just created. 
-- TODO: If you changed the name of the database above, you need 
-- to change it here too.
grant all privileges on elections.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too. 
use elections;

-- Put your DDL 
CREATE TABLE politicalParty (
    partyID integer AUTO_INCREMENT PRIMARY KEY,
    partyName varchar(40) NOT NULL
);

CREATE TABLE pollingPlace (
    pollingPlaceID integer AUTO_INCREMENT PRIMARY KEY,
    placeName varchar(40) NOT NULL,
    placeStreet varchar(40) NOT NULL,
    placeCity varchar(40) NOT NULL,
    placeState varchar(2) NOT NULL,
    placeZip integer NOT NULL
);

CREATE TABLE absenteeRequest (
    requestID integer AUTO_INCREMENT PRIMARY KEY,
    requestStreet varchar(40) NOT NULL,
    requestCity varchar(40) NOT NULL,
    requestState varchar(2) NOT NULL,
    requestZip integer(40) NOT NULL
);

CREATE TABLE election (
    electionID integer AUTO_INCREMENT PRIMARY KEY,
    electionDate date NOT NULL,
    typeOfElection enum('General', 'Primary', 'Special') NOT NULL
);

CREATE TABLE precinct (
    precinctID integer AUTO_INCREMENT PRIMARY KEY,
    precinctCity varchar(40) NOT NULL,
    precinctWard integer NOT NULL,
    curElection integer NOT NULL,
    location integer NOT NULL,
    CONSTRAINT currentElection_fk
        FOREIGN KEY (curElection) REFERENCES election (electionID),
    CONSTRAINT pollingPlace_fk
        FOREIGN KEY (location) REFERENCES pollingPlace (pollingPlaceID)
);

CREATE TABLE voter (
    voterID integer AUTO_INCREMENT PRIMARY KEY,
    ssn varchar(11) UNIQUE NOT NULL,
    license varchar(8) UNIQUE,
    firstName varchar(40) NOT NULL,
    middleName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL,
    dob date NOT NULL,
    street varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(2) NOT NULL,
    zip integer NOT NULL,
    partyAfil integer NOT NULL,
    homePrecinct integer NOT NULL,
    absRequest integer,
    CONSTRAINT voterAfil_fk
        FOREIGN KEY (partyAfil) REFERENCES politicalParty (partyID),
    CONSTRAINT voterPrecinct_fk
        FOREIGN KEY (homePrecinct) REFERENCES precinct (precinctID),
    CONSTRAINT voterAbsent_fk
        FOREIGN KEY (absRequest) REFERENCES absenteeRequest (requestID)
);

CREATE TABLE electedPosition (
    electedPosID integer AUTO_INCREMENT PRIMARY KEY,
    posName varchar(40) NOT NULL,
    constituency varchar(40) NOT NULL,
    term integer NOT NULL,
    salary integer NOT NULL,
    signatureReq integer NOT NULL,
    ofLevel enum('State', 'Local', 'Federal') NOT NULL
);

CREATE TABLE race (
    raceID integer AUTO_INCREMENT PRIMARY KEY,
    positionFor integer,
    inElection integer,
    CONSTRAINT racePosition_fk
        FOREIGN KEY (positionFor) REFERENCES electedPosition (electedPosID),
    CONSTRAINT electionRace_fk
        FOREIGN KEY (inElection) REFERENCES election (electionID)
);

CREATE TABLE candidate (
    candidateID integer AUTO_INCREMENT PRIMARY KEY,
    ssn varchar(11) UNIQUE NOT NULL,
    firstName varchar(40) NOT NULL,
    middleName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL,
    partyMemb integer NOT NULL,
    raceIn integer NOT NULL,
    CONSTRAINT candPartyMemb_fk
        FOREIGN KEY (partyMemb) REFERENCES politicalParty (partyID),
    CONSTRAINT candRace_fk
        FOREIGN KEY (raceIn) REFERENCES race (raceID)
);

CREATE TABLE petition (
    petitionID integer AUTO_INCREMENT PRIMARY KEY,
    numSignatures integer NOT NULL,
    residence integer NOT NULL,
    forCandidate integer NOT NULL,
    forRace integer NOT NULL,
    CONSTRAINT petitionCand_fk
        FOREIGN KEY (forCandidate) REFERENCES candidate (candidateID),
    CONSTRAINT petitionRace_fk
        FOREIGN KEY (forRace) REFERENCES race (raceID)
);

CREATE TABLE electionOfficial (
    employeeID integer AUTO_INCREMENT PRIMARY KEY,
    ssn varchar(11) UNIQUE,
    firstName varchar(40) NOT NULL,
    middleName varchar(40) NOT NULL,
    lastName varchar(40) NOT NULL
);

CREATE TABLE absenteeApproval (
    official integer NOT NULL,
    request integer NOT NULL,
    sent BOOLEAN NOT NULL,
    CONSTRAINT absentOfficial_fk
        FOREIGN KEY (official) REFERENCES electionOfficial (employeeID),
    CONSTRAINT absentRequest_fk
        FOREIGN KEY (request) REFERENCES absenteeRequest (requestID)
);

CREATE TABLE petitionApproval (
    official integer NOT NULL,
    candidatePetition integer NOT NULL,
    CONSTRAINT petitionOfficial_fk
        FOREIGN KEY (official) REFERENCES electionOfficial (employeeID),
    CONSTRAINT candPetition_fk
        FOREIGN KEY (candidatePetition) REFERENCES petition (petitionID)
);

-- Add sample data. 
INSERT INTO politicalParty (partyName)
VALUES ('Independent'), ('Bull Moose'), ('Whig'), ('Reform'), ('Farmer-Labor');

INSERT INTO pollingPlace (placeName, placeStreet, placeCity, placeState, placeZip)
VALUES ('Our Lady of Ladies', '6853 Walton Crossing', 'Zenith', 'WC', 41852),
('Penatibus et Magnis Community Center', '62 Anthes Alley', 'Zenith', 'WC', 41374),
('Non Velit Elementary', '20 Independence Street', 'Zenith', 'WC', 41321),
('Vivamus Memorial High School', '48795 Texas Hill', 'Pottersville', 'WC', 41598),
('Dapibus Museum', '2822 Maryland Plaza', 'Pottersville', 'WC', 41227),
('Tincidunt Lacus Elementary', '56 Fisk Parkway', 'Zenith', 'WC', 41738),
('Luctus et Ultrices Center', '34421 Parkside Center', 'Zenith', 'WC', 41845),
('Accumsan High School', '6028 Fairview Plaza', 'Zenith', 'WC', 41242),
('Iaculis Public Library', '912 Blackbird Avenue', 'Zenith', 'WC', 41843),
('Old Etiam Church', '612 8th Plaza', 'Zenith', 'WC', 41367),
('Parturient Montes Center for the Blind', '3 Carpenter Park', 'Zenith', 'WC', 41567),
('Varius Utta Memorail High School', '08493 Scott Pass', 'Zenith', 'WC', 41540),
('Sid Vestibulum Center', '3042 Barby Trail', 'Zenith', 'WC', 41935),
('Feugiat Elementary', '0157 Vidon Parkway', 'Zenith', 'WC', 41243),
('Adipiscing Public Library', '8682 Esker Center', 'Zenith', 'WC', 41412),
('Mauris Public Library', '8601 Moland Way', 'Zenith', 'WC', 41529),
('Nascetur Memorial Library', '243 Clove Avenue', 'Zenith', 'WC', 41488),
('Lacinia Community Center', '6 Nevada Place', 'Paradise', 'WC', 41589),
('Proin Community School', '22 Comanche Pass', 'Paradise', 'WC', 41891),
('St. Faucibus High School', '36 Northfield Terrace', 'Zenith', 'WC', 41725);

INSERT INTO absenteeRequest (requestStreet, requestCity, requestState, requestZip) 
VALUES ('152 Lighthouse Bay Street', 'Saint Louis', 'MO', '63131'),
('697 Fairfield Way', 'Philadelphia', 'PA', '19136'),
('15 Fisk Pass', 'Des Moines', 'IA', '50320'),
('1 Utah Court', 'San Antonio', 'TX', '78265'),
('27731 Nelson Way', 'Torrance', 'CA', '90510'),
('39833 Clyde Gallagher Point', 'Tucson', 'AZ', '85732'),
('212 Anderson Park', 'San Jose', 'CA', '95160'),
('12 Blaine Way', 'Columbus', 'OH', '43215');

INSERT INTO election (electionDate, typeOfElection) 
VALUES ('2023-10-10', 1),
('2023-08-12', 2),
('2023-09-08', 3);

INSERT INTO precinct (precinctCity, precinctWard, curElection, location) 
VALUES ('Zenith', 9, 1, 1),
('Zenith', 4, 2, 2),
('Zenith', 10, 3, 3),
('Pottersville', 4, 1, 4),
('Pottersville', 3, 1, 5),
('Zenith', 6, 1, 6),
('Zenith', 7, 1, 7),
('Zenith', 7, 1, 8),
('Zenith', 9, 1, 9),
('Zenith', 9, 1, 10),
('Zenith', 9, 1, 11),
('Zenith', 8, 1, 12),
('Zenith', 1, 1, 13),
('Zenith', 10, 1, 14),
('Zenith', 1, 1, 15),
('Zenith', 3, 1, 16),
('Zenith', 8, 1, 17),
('Paradise', 7, 1, 18),
('Paradise', 4, 1, 19),
('Zenith', 6, 2, 20);

INSERT INTO voter (ssn, license, firstName, middleName, lastName, dob, street, city, state, zip, partyAfil, homePrecinct, absRequest) 
VALUES ('400-24-8236', 'TC327361', 'Ram', 'Adelman', 'Phifer', '1951-01-25', '07 Mayfield Alley', 'Zenith', 'WC', 41121, 4, 1, 1),
('376-62-8133', null, 'Juan', 'Andreia', 'Villiers', '1956-03-05', '3 Towne Way', 'Zenith', 'WC', 41828, 3, 2, null),
('861-86-2435', null, 'Fran', 'Upex', 'Gillbee', '1956-08-05', '25787 Quincy Court', 'Zenith', 'WC', 41060, 3, 3, null),
('164-97-9073', null, 'Phillie', 'Vickar', 'Hanny', '1950-10-25', '689 La Follette Terrace', 'Pottersville', 'WC', 41354, 4, 4, null),
('504-71-1486', null, 'Violette', 'Mc Curlye', 'Gutherson', '1971-08-21', '761 Scofield Avenue', 'Pottersville', 'WC', 41538, 5, 5, null),
('875-95-8924', null, 'Demetria', 'Renvoise', 'Pottie', '1975-07-12', '4600 Lakewood Trail', 'Zenith', 'WC', 41035, 5, 6, null),
('493-51-2060', null, 'Sutherlan', 'Orgee', 'Landeaux', '1943-06-18', '3 Brickson Park Drive', 'Zenith', 'WC', 41491, 1, 7, null),
('466-90-7767', null, 'Sterne', 'Linay', 'Stanbrooke', '1986-01-25', '76512 Twin Pines Place', 'Zenith', 'WC', 41355, 5, 8, null),
('149-47-3362', null, 'Barnie', 'Mungin', 'Mountney', '1993-11-30', '82 Nova Parkway', 'Zenith', 'WC', 41103, 2, 9, null),
('648-49-2732', null, 'Gerladina', 'Eccles', 'Paffitt', '2002-03-01', '82031 Cambridge Court', 'Zenith', 'WC', 41233, 2, 10, null),
('162-14-1459', 'YD718513', 'Saba', 'Skinley', 'Ladon', '1975-07-19', '559 Algoma Parkway', 'Zenith', 'WC', 41412, 1, 11, 2),
('176-37-9058', 'XC569484', 'Eberto', 'Extil', 'Boodell', '1953-04-09', '22 Manitowish Parkway', 'Zenith', 'WC', 41253, 4, 12, 3),
('621-91-0880', null, 'Rickard', 'McCourt', 'Grimwade', '1995-05-15', '206 Hollow Ridge Alley', 'Zenith', 'WC', 41730, 4, 13, null),
('226-01-7357', null, 'Louisa', 'Sexstone', 'Cicculini', '1945-03-04', '4 Westridge Court', 'Zenith', 'WC', 41870, 5, 14, null),
('881-39-4382', 'EK188773', 'Gaylene', 'Nieass', 'Burdoun', '1947-02-20', '7 Warrior Lane', 'Zenith', 'WC', 41458, 4, 15, 4),
('138-16-0908', 'PG962311', 'Franzen', 'Maylour', 'Filler', '1956-09-02', '1336 Kings Drive', 'Zenith', 'WC', 41164, 4, 16, 5),
('722-08-0372', 'SD968539', 'Alvinia', 'Minchenton', 'Elwel', '1991-04-12', '538 Shopko Lane', 'Zenith', 'WC', 41337, 5, 17, 6),
('417-34-7483', null, 'Zitella', 'Langstaff', 'Jeskins', '1961-01-09', '4 Dayton Place', 'Paradise', 'WC', 41593, 5, 18, null),
('148-70-4753', null, 'Doll', 'Kaasman', 'Kubicki', '1999-09-15', '351 Hagan Circle', 'Paradise', 'WC', 41910, 1, 19, 7),
('852-75-0840', 'BF080418', 'Mindy', 'MacDwyer', 'Bursnall', '1976-12-22', '61481 Londonderry Hill', 'Zenith', 'WC', 41384, 2, 20, 8);

INSERT INTO electedPosition (posName, constituency, term, salary, signatureReq, ofLevel) 
VALUES ('Governor', 'Winnemac', 4, 110000, 5000, 1),
('U.S. Representative', '11th District', 2, 120000, 5000, 3),
('Secretary of State', 'Winnemac', 4, 80000, 5000, 1),
('Treasurer', 'Winnemac', 4, 80000, 5000, 1),
('State Representative', '2nd District', 2, 80000, 2500, 1),
('U.S. Senator', 'Winnemac', 6, 120000, 5000, 3),
('Mayor', 'Zenith', 4, 100000, 1000, 2),
('City Councilor', '4th Ward', 4, 75000, 250, 2),
('State Senator', '3rd District', 4, 80000, 2500, 1),
('County Comissioner', 'Zenith County', 4, 75000, 1000, 2);

INSERT INTO race (positionFor, inElection) 
VALUES (1, 1),
(2, 2),
(3, 1),
(4, 1),
(5, 3),
(6, 2),
(7, 2),
(8, 2),
(9, 1),
(10, 1);

INSERT INTO candidate (ssn, firstName, middleName, lastName, partyMemb, raceIn) 
VALUES ('808-31-2225', 'Christa', 'Coal', 'Cheeseman', 1, 8),
('638-20-7653', 'Silvano', 'Dowsett', 'McAndrew', 1, 3),
('884-37-4410', 'Margalo', 'Allington', 'Ingerith', 2, 10),
('523-28-1183', 'Del', 'Routh', 'Despenser', 1, 4),
('125-75-0703', 'Augy', 'Mosdell', 'Baudinelli', 4, 4),
('766-04-6967', 'Ethelin', 'Drysdall', 'Croall', 3, 7),
('164-18-1177', 'Filmer', 'Salsbury', 'Housecroft', 4, 10),
('202-83-5091', 'Brandie', 'Temporal', 'Ratcliffe', 2, 5),
('209-82-4937', 'Tirrell', 'Truett', 'McCurtain', 5, 1),
('341-57-7936', 'Marylinda', 'Tarry', 'Shortell', 4, 8),
('195-06-2992', 'Brynn', 'Doleman', 'Ree', 4, 7),
('781-13-6800', 'Cello', 'Candey', 'Casseldine', 4, 6),
('304-16-8357', 'Flin', 'Maultby', 'Sones', 2, 8),
('478-71-4373', 'Lannie', 'Kennett', 'Blades', 3, 3),
('624-72-2364', 'Andrej', 'Mc Andrew', 'Starford', 2, 1),
('374-98-5341', 'Nathaniel', 'Skinley', 'Ortas', 4, 1),
('328-20-0054', 'Sybilla', 'Claybourne', 'Torritti', 3, 1),
('671-20-5671', 'Ford', 'Tildesley', 'Woodberry', 2, 5),
('379-86-4864', 'Orelie', 'Newns', 'Alexandersen', 3, 2),
('229-35-0472', 'Janice', 'Lowther', 'O''Corrin', 4, 2);

INSERT INTO petition (numSignatures, residence, forCandidate, forRace) 
VALUES (5101, 10, 1, 1),
(4695, 6, 2, 1),
(5557, 7, 3, 1),
(6173, 6, 4, 2),
(5914, 5, 5, 2),
(7907, 4, 6, 3),
(5118, 10, 7, 4),
(2288, 10, 8, 4),
(4352, 7, 9, 4),
(2852, 7, 10, 5),
(2848, 8, 11, 5),
(8118, 3, 12, 6),
(1238, 7, 13, 7),
(1454, 1, 14, 7),
(726, 5, 15, 8),
(692, 3, 16, 8),
(3237, 7, 17, 9),
(691, 4, 18, 10),
(1704, 10, 19, 10),
(1233, 9, 20, 10);

INSERT INTO electionOfficial (ssn, firstName, middleName, lastName) 
VALUES ('204-56-4245', 'Elyse', 'Crepel', 'Yon'),
('220-81-4759', 'Morten', 'MacTeague', 'Cronin'),
('627-47-3056', 'Eugenie', 'Kuhnel', 'Smallwood'),
('428-51-4385', 'Dacia', 'Houdmont', 'Pettifer'),
('463-05-2718', 'Freddi', 'Cicchitello', 'Josef'),
('105-96-3571', 'Jarid', 'Gabel', 'Brownlie'),
('773-92-6639', 'Byron', 'Metham', 'Dye'),
('613-27-0124', 'Veronike', 'Whapham', 'Chicchetto'),
('202-92-2731', 'Spike', 'Allsepp', 'De Lisle'),
('166-07-2519', 'Carlina', 'Duferie', 'Gates'),
('535-20-6347', 'Sharai', 'Wakeford', 'Musselwhite'),
('657-05-0146', 'Brandea', 'Zimmermanns', 'Whetnell'),
('692-25-9930', 'Roland', 'Peter', 'Red'),
('599-78-1428', 'Poppy', 'Hawkswood', 'Ghost'),
('558-76-5728', 'Heall', 'Ventris', 'Mainson'),
('701-41-6076', 'Rozanna', 'Fanstone', 'Jakubiak'),
('615-22-9985', 'Meredith', 'Casaroli', 'Jiroutka'),
('295-86-8820', 'Gilligan', 'Perschke', 'Cullity'),
('131-57-2429', 'Tandy', 'Pitway', 'Pettyfer'),
('498-30-3394', 'De', 'Padbery', 'Hawtrey');

INSERT INTO absenteeApproval (official, request, sent)
VALUES (1, 1, false), 
(1, 2, true), 
(2, 3, false), 
(4, 4, false), 
(4, 5, true), 
(4, 6, true), 
(5, 7, false), 
(10, 8, true);

INSERT INTO petitionApproval (official, candidatePetition)
VALUES (1, 1), 
(1, 2), 
(4, 3), 
(3, 4), 
(5, 5), 
(17, 6), 
(17, 7), 
(18, 20), 
(19, 19);
