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
('Varius Utta Memorial High School', '08493 Scott Pass', 'Zenith', 'WC', 41540),
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
('12 Blaine Way', 'Columbus', 'OH', '43215'),
('17 Eagan Crossing', 'Lafayette', 'LA', '70505'),
('36 Granby Road', 'Houston', 'TX', '77005');

INSERT INTO election (electionDate, typeOfElection) 
VALUES ('2023-10-10', 1), -- Zenith, 4th Ward
('2023-08-12', 2), -- Pottersville
('2023-09-08', 3), -- Paradise
('2023-10-10', 1); -- Zenith 2

INSERT INTO precinct (precinctCity, precinctWard, curElection, location) 
VALUES ('Zenith', 4, 1, 1),
('Zenith', 4, 1, 2),
('Zenith', 4, 1, 3),
('Pottersville', 1, 2, 4),
('Pottersville', 1, 2, 5),
('Zenith', 4, 1, 6),
('Zenith', 4, 1, 7),
('Zenith', 4, 1, 8),
('Zenith', 4, 1, 9),
('Zenith', 9, 4, 10),
('Zenith', 9, 4, 11),
('Zenith', 9, 4, 12),
('Zenith', 9, 4, 13),
('Zenith', 9, 4, 14),
('Zenith', 9, 4, 15),
('Zenith', 9, 4, 16),
('Zenith', 9, 4, 17),
('Paradise', 1, 3, 18),
('Paradise', 1, 3, 19),
('Zenith', 4, 1, 20);

INSERT INTO voter (ssn, license, firstName, middleName, lastName, dob, street, city, state, zip, partyAfil, homePrecinct, absRequest) 
VALUES ('400-24-8236', 'TC327361', 'Ram', 'Adelman', 'Phifer', '1951-01-25', '07 Mayfield Alley', 'Zenith', 'WC', 41121, 4, 1, 1),
('376-62-8133', null, 'Juan', 'Andreia', 'Villiers', '1956-03-05', '3 Towne Way', 'Zenith', 'WC', 41828, 3, 2, null),
('861-86-2435', null, 'Fran', 'Upex', 'Gillbee', '1956-08-05', '25787 Quincy Court', 'Zenith', 'WC', 41060, 3, 3, null),
('164-97-9073', null, 'Phillie', 'Vickar', 'Hanny', '1950-10-25', '689 La Follette Terrace', 'Pottersville', 'WC', 41354, 4, 4, null),
('504-71-1486', null, 'Violette', 'Mc Curlye', 'Gutherson', '1971-08-21', '761 Scofield Avenue', 'Pottersville', 'WC', 41538, 5, 5, null),
('875-95-8924', null, 'Demetria', 'Renvoise', 'Pottie', '1975-07-12', '4600 Lakewood Trail', 'Pottersville', 'WC', 41035, 5, 6, null),
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
('852-75-0840', 'BF080418', 'Mindy', 'MacDwyer', 'Bursnall', '1976-12-22', '61481 Londonderry Hill', 'Zenith', 'WC', 41384, 2, 20, 8),
('812-61-0475', null, 'Curcio', 'Sherbrooke', 'Yushachkov', '1990-12-22', '020 Cherokee Point', 'Zenith', 'WC', 41879, 2, 17, null),
('717-13-2305', null, 'Emily', 'Margrem', 'Venard', '1957-06-28', '016 Ludington Court', 'Pottersville', 'WC', 41263, 2, 5, null),
('469-68-0641', null, 'Pietra', 'Laphorn', 'Golsby', '1984-02-26', '9 Calypso Pass', 'Zenith', 'WC', 41041, 2, 11, null),
('818-11-2900', null, 'Giralda', 'Saiens', 'Birchill', '1946-02-05', '21 Di Loreto Hill', 'Zenith', 'WC', 41540, 3, 8, null),
('230-18-2617', 'XO637117', 'Babette', 'Czajkowska', 'Harridge', '1956-12-21', '41033 Continental Road', 'Zenith', 'WC', 41577, 3, 10, 9),
('454-04-4589', null, 'Malina', 'Philipot', 'Luigi', '1961-11-19', '47 Homewood Parkway', 'Pottersville', 'WC', 41960, 3, 4, null),
('243-57-0166', null, 'Biddy', 'Haswell', 'Oxberry', '1960-02-23', '2651 Grover Junction', 'Zenith', 'WC', 41062, 4, 10, null),
('303-54-7982', null, 'Melisenda', 'Loadsman', 'Creek', '1948-01-11', '6 Hoffman Alley', 'Zenith', 'WC', 41513, 1, 3, null),
('890-43-6706', null, 'Melinde', 'Orsay', 'Aberdalgy', '2000-04-06', '5277 Nevada Point', 'Zenith', 'WC', 41607, 3, 3, null),
('561-28-5719', null, 'Kim', 'Leming', 'Hardson', '1964-10-18', '5097 Lillian Park', 'Zenith', 'WC', 41425, 3, 10, null),
('490-26-9683', 'IX030846', 'Tiphany', 'Borne', 'Findlay', '1959-04-17', '466 Surrey Point', 'Zenith', 'WC', 41548, 1, 9, null),
('333-11-9777', 'GN542731', 'Ulrica', 'Massenhove', 'Aingell', '1946-06-21', '8 Milwaukee Junction', 'Zenith', 'WC', 41140, 3, 11, 10),
('567-37-5310', null, 'Nathanael', 'Clemont', 'Friese', '1993-11-07', '569 Welch Place', 'Zenith', 'WC', 41577, 2, 6, null),
('322-92-8040', null, 'Shanon', 'Branson', 'Elizabeth', '1942-06-09', '60638 Springs Trail', 'Zenith', 'WC', 41363, 2, 6, null),
('151-63-0497', null, 'Lou', 'Meggison', 'Barkworth', '1991-05-21', '7 Old Gate Point', 'Zenith', 'WC', 41298, 3, 2, null),
('492-48-1289', 'DU766176', 'Earl', 'Abramov', 'Flacknoe', '2003-04-24', '9 Corscot Place', 'Zenith', 'WC', 41173, 1, 9, null),
('770-35-7821', null, 'Merilyn', 'MacCahey', 'Chicchetto', '1968-02-11', '71549 Milwaukee Terrace', 'Pottersville', 'WC', 41236, 1, 5, null),
('162-77-5878', null, 'Vida', 'Minchella', 'Bereford', '1974-02-14', '17931 Springs Park', 'Zenith', 'WC', 41361, 2, 8, null),
('628-17-2897', null, 'Alfred', 'Milmore', 'Whenman', '1964-01-12', '6 La Follette Road', 'Zenith', 'WC', 41893, 3, 12, null),
('874-66-8722', null, 'Pen', 'Echallier', 'Benediktovich', '1986-05-11', '7306 Kings Drive', 'Paradise', 'WC', 41112, 3, 19, null);

INSERT INTO electedPosition (posName, constituency, term, salary, signatureReq, ofLevel) 
VALUES ('Governor', 'Winnemac', 4, 110000, 5000, 1),
('U.S. Representative', '11th District', 2, 120000, 5000, 3),
('Secretary of State', 'Winnemac', 4, 80000, 5000, 1),
('Treasurer', 'Winnemac', 4, 80000, 5000, 1),
('State Representative', '2nd District', 2, 80000, 2500, 1),
('U.S. Senator', 'Winnemac', 6, 120000, 5000, 3),
('Mayor', 'Zenith', 4, 100000, 1000, 2),
('City Councilor', 'Zenith 4th Ward', 4, 75000, 250, 2),
('State Senator', '3rd District', 4, 80000, 2500, 1),
('County Commissioner', 'Zenith County', 4, 75000, 1000, 2),
('State Senator', '4th District', 4, 80000, 2500, 1),
('State Representative', '10th District', 2, 80000, 2500, 1),
('U.S. Representative', '12th District', 2, 120000, 5000, 3),
('Mayor', 'Pottersville', 2, 90000, 800, 2),
('City Councillor', 'Pottersville At-Large', 2, 20000, 100, 2),
('County Commissioner', 'Zenith County', 4, 75000, 1000, 2),
('U.S. Representative', '8th District', 2, 120000, 5000, 3),
('State Representative', '15th District', 2, 80000, 2500, 1),
('Mayor', 'Paradise', 2, 80000, 900, 2),
('City Councillor', 'Paradise At-Large', 2, 50000, 200, 2);

INSERT INTO race (positionFor, inElection) 
VALUES (1, 1), -- Governor
(2, 1), -- US Rep 11th District
(3, 1), -- SOS
(4, 1), -- Treasurer
(5, 3), -- State Rep 2nd District
(6, 1), -- US Senator
(7, 1), -- Zenith Mayor
(8, 1), -- Zenith Councillor 4th Ward
(10, 1), -- State Senator 3rd District
(11, 1), -- County Comissioner 1
(12, 2), -- State Senator 4th District
(13, 1), -- State Rep 10th District
(14, 3), -- US Rep 12th District
(14, 2), -- Pottersville Mayor
(15, 2), -- Pottersville City Council
(16, 2), -- County Comissioner 2
(17, 4), -- US Rep 8th District
(18, 4), -- State Rep 15th District
(19, 3), -- Paradise Mayor
(20, 3); -- Paradise City Council

INSERT INTO candidate (ssn, firstName, middleName, lastName, partyMemb, raceIn) 
VALUES ('808-31-2225', 'Christa', 'Coal', 'Cheeseman', 1, 1),
('638-20-7653', 'Silvano', 'Dowsett', 'McAndrew', 1, 1),
('884-37-4410', 'Margalo', 'Allington', 'Ingerith', 2, 1),
('523-28-1183', 'Del', 'Routh', 'Despenser', 1, 2),
('125-75-0703', 'Augy', 'Mosdell', 'Baudinelli', 4, 2),
('766-04-6967', 'Ethelin', 'Drysdall', 'Croall', 3, 3),
('164-18-1177', 'Filmer', 'Salsbury', 'Housecroft', 4, 4),
('202-83-5091', 'Brandie', 'Temporal', 'Ratcliffe', 2, 4),
('209-82-4937', 'Tirrell', 'Truett', 'McCurtain', 5, 4),
('341-57-7936', 'Marylinda', 'Tarry', 'Shortell', 4, 5),
('195-06-2992', 'Brynn', 'Doleman', 'Ree', 4, 5),
('781-13-6800', 'Cello', 'Candey', 'Casseldine', 4, 6),
('304-16-8357', 'Flin', 'Maultby', 'Sones', 2, 6),
('478-71-4373', 'Lannie', 'Kennett', 'Blades', 3, 7),
('624-72-2364', 'Andrej', 'Mc Andrew', 'Starford', 2, 7),
('374-98-5341', 'Nathaniel', 'Skinley', 'Ortas', 4, 8),
('328-20-0054', 'Sybilla', 'Claybourne', 'Torritti', 3, 8),
('671-20-5671', 'Ford', 'Tildesley', 'Woodberry', 2, 9),
('379-86-4864', 'Orelie', 'Newns', 'Alexandersen', 3, 10),
('229-35-0472', 'Janice', 'Lowther', 'O''Corrin', 4, 10),
('758-97-5894', 'Jaime', 'Coltart', 'Wakeham', 1, 10),
('413-13-5131', 'Vickie', 'Darke', 'Purver', 3, 11),
('459-09-7389', 'Shellie', 'Cicculi', 'Woodcraft', 1, 11),
('871-59-1451', 'Courtnay', 'Slyde', 'O''Suaird', 5, 12),
('670-90-1635', 'Katheryn', 'Humpherson', 'Whear', 4, 12),
('801-70-9637', 'Claudianus', 'Fenelon', 'Covil', 3, 13),
('645-39-6303', 'Kelci', 'Westmore', 'Yonnie', 2, 13),
('790-97-0193', 'Bettina', 'Hefforde', 'Sheahan', 4, 14),
('523-04-9441', 'Bert', 'Daelman', 'Ocklin', 2, 14),
('604-30-8207', 'Chane', 'Trehearne', 'Filchakov', 5, 15),
('337-93-5096', 'Keelia', 'Jealous', 'Farrer', 5, 15),
('451-07-2271', 'Violet', 'Morriss', 'Giraldon', 1, 16),
('585-02-1305', 'Karleen', 'Diche', 'Batthew', 1, 16),
('821-66-2250', 'Terrell', 'Alten', 'Coryndon', 3, 16),
('449-41-7999', 'Euell', 'Hannon', 'Betho', 5, 17),
('370-32-0130', 'Thadeus', 'Wrightson', 'Routh', 5, 17),
('834-59-0399', 'Joseito', 'Lytton', 'Paolino', 2, 18),
('726-88-9091', 'Karrie', 'Strasse', 'Finlay', 4, 18),
('684-56-2503', 'Arvie', 'Featherstonhalgh', 'Owlner', 4, 19),
('212-38-7404', 'Odo', 'Turbefield', 'Huc', 2, 20);

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
(1233, 9, 20, 10),
(654, 9, 21, 11),
(558, 2, 22, 11),
(527, 4, 23, 12),
(2905, 4, 24, 12),
(1097, 4, 25, 13),
(2133, 4, 26, 13),
(1595, 8, 27, 14),
(1956, 5, 28, 14),
(1770, 8, 29, 15),
(246, 7, 30, 15),
(1378, 9, 31, 16),
(2740, 5, 32, 16),
(2759, 5, 33, 16),
(2032, 9, 34, 16),
(650, 4, 35, 17),
(1128, 2, 36, 17),
(863, 6, 37, 18),
(1476, 9, 38, 18),
(1982, 3, 39, 19),
(1830, 4, 40, 20);

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
