-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-15 08:20:36.146

-- tables
-- Table: Attendees
CREATE TABLE Attendees (
    AttendeeID int  NOT NULL IDENTITY(1,1),
    ByCustomer int  NOT NULL,
    FirstName varchar(20)  NOT NULL,
    LastName varchar(20)  NOT NULL,
    IsStudent bit  NULL,
    CONSTRAINT Attendees_pk PRIMARY KEY  (AttendeeID)
);

-- Table: Companies
CREATE TABLE Companies (
    CustomerID int  NOT NULL,
    CompanyName varchar(20)  NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY  (CustomerID)
);

-- Table: Conference
CREATE TABLE Conference (
    ConferenceID int  NOT NULL IDENTITY(1,1),
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    ConferenceName varchar(20)  NOT NULL,
    CONSTRAINT ConferenceDateCheck CHECK (StartDate < EndDate),
    CONSTRAINT Conference_pk PRIMARY KEY  (ConferenceID)
);

-- Table: Conference_Day
CREATE TABLE Conference_Day (
    ConferenceID int  NOT NULL,
    ConferenceDate date  NOT NULL,
    AttendeeLimit int  NOT NULL,
    BasePricePerPerson int  NOT NULL,
    CONSTRAINT Conference_Day_pk PRIMARY KEY  (ConferenceDate)
);

-- Table: Conference_Day_Attendee_Reservations
CREATE TABLE Conference_Day_Attendee_Reservations (
    AttendeeID int  NOT NULL,
    ViaConferenceDayCustomerReservation int  NOT NULL,
    ConferenceDayAttendeeReservationID int  NOT NULL IDENTITY(1,1),
    CONSTRAINT Conference_Day_Attendee_Reservations_pk PRIMARY KEY  (ConferenceDayAttendeeReservationID)
);

-- Table: Conference_Day_Customer_Reservations
CREATE TABLE Conference_Day_Customer_Reservations (
    ConferenceDay date  NOT NULL,
    CustomerID int  NOT NULL,
    AttendeeAmount int  NOT NULL,
    ReservationDate date  NOT NULL,
    WasPaid bit  NOT NULL,
    CancellationDate date  NULL,
    CustomerReservationID int  NOT NULL IDENTITY(1,1),
    CONSTRAINT DateCheck CHECK (CancellationDate IS NULL OR ReservationDate < CancellationDate),
    CONSTRAINT Conference_Day_Customer_Reservations_pk PRIMARY KEY  (CustomerReservationID)
);

-- Table: Customers
CREATE TABLE Customers (
    CustomerID int  NOT NULL IDENTITY(1,1),
    Phone varchar(9)  NOT NULL,
    CONSTRAINT PhoneCheck CHECK (Phone Like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Customers_pk PRIMARY KEY  (CustomerID)
);

-- Table: Private_Individuals
CREATE TABLE Private_Individuals (
    CustomerID int  NOT NULL,
    FirstName varchar(20)  NOT NULL,
    LastName varchar(20)  NOT NULL,
    CONSTRAINT Private_Individuals_pk PRIMARY KEY  (CustomerID)
);

-- Table: Workshop
CREATE TABLE Workshop (
    WorkshopID int  NOT NULL IDENTITY(1,1),
    WorkshopDate date  NOT NULL,
    StartTime time(0)  NOT NULL,
    EndTime time(0)  NOT NULL,
    PricePerPerson int  NOT NULL,
    AttendeeLimit int  NOT NULL,
    WorkshopName varchar(20)  NOT NULL,
    CONSTRAINT WorkshopTimeCheck CHECK (StartTime < EndTime),
    CONSTRAINT Workshop_pk PRIMARY KEY  (WorkshopID)
);

-- Table: Workshop_Attendee_Reservations
CREATE TABLE Workshop_Attendee_Reservations (
    ViaConferenceDayAttendeeReservation int  NOT NULL,
    WorkshopID int  NOT NULL,
    WasPaid bit  NOT NULL,
    CONSTRAINT Workshop_Attendee_Reservations_pk PRIMARY KEY  (ViaConferenceDayAttendeeReservation,WorkshopID)
);

-- foreign keys
-- Reference: Attendees_Customers (table: Attendees)
ALTER TABLE Attendees ADD CONSTRAINT Attendees_Customers
    FOREIGN KEY (ByCustomer)
    REFERENCES Customers (CustomerID);

-- Reference: CDAR_Attendees (table: Conference_Day_Attendee_Reservations)
ALTER TABLE Conference_Day_Attendee_Reservations ADD CONSTRAINT CDAR_Attendees
    FOREIGN KEY (AttendeeID)
    REFERENCES Attendees (AttendeeID);

-- Reference: CDAR_CDR (table: Conference_Day_Attendee_Reservations)
ALTER TABLE Conference_Day_Attendee_Reservations ADD CONSTRAINT CDAR_CDR
    FOREIGN KEY (ViaConferenceDayCustomerReservation)
    REFERENCES Conference_Day_Customer_Reservations (CustomerReservationID);

-- Reference: CDAR_WAR (table: Workshop_Attendee_Reservations)
ALTER TABLE Workshop_Attendee_Reservations ADD CONSTRAINT CDAR_WAR
    FOREIGN KEY (ViaConferenceDayAttendeeReservation)
    REFERENCES Conference_Day_Attendee_Reservations (ConferenceDayAttendeeReservationID);

-- Reference: CDR_Customers (table: Conference_Day_Customer_Reservations)
ALTER TABLE Conference_Day_Customer_Reservations ADD CONSTRAINT CDR_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: CD_CDR (table: Conference_Day_Customer_Reservations)
ALTER TABLE Conference_Day_Customer_Reservations ADD CONSTRAINT CD_CDR
    FOREIGN KEY (ConferenceDay)
    REFERENCES Conference_Day (ConferenceDate);

-- Reference: CD_Conference (table: Conference_Day)
ALTER TABLE Conference_Day ADD CONSTRAINT CD_Conference
    FOREIGN KEY (ConferenceID)
    REFERENCES Conference (ConferenceID);

-- Reference: Company_Customers (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Company_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: PI_Customers (table: Private_Individuals)
ALTER TABLE Private_Individuals ADD CONSTRAINT PI_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: WAR_Workshop (table: Workshop_Attendee_Reservations)
ALTER TABLE Workshop_Attendee_Reservations ADD CONSTRAINT WAR_Workshop
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshop (WorkshopID);

-- Reference: Workshop_CD (table: Workshop)
ALTER TABLE Workshop ADD CONSTRAINT Workshop_CD
    FOREIGN KEY (WorkshopDate)
    REFERENCES Conference_Day (ConferenceDate);


CREATE PROCEDURE new_conference (
@ConferenceName character varying,
@StartDate date,
@EndDate date
)
as
BEGIN
INSERT INTO Conference(ConferenceName, StartDate, EndDate) VALUES(@ConferenceName, @StartDate, @EndDate)
END;

CREATE PROCEDURE new_conference_day (
@ConferenceID int,
@ConferenceDate date,
@AttendeeLimit int,
@BasePricePerPerson int
)
as
BEGIN
INSERT INTO Conference_Day(ConferenceID, ConferenceDate, AttendeeLimit, BasePricePerPerson) 
VALUES(@ConferenceID, @ConferenceDate, @AttendeeLimit, @BasePricePerPerson)
END;

CREATE PROCEDURE new_company (
@CompanyName character varying,
@Phone varchar(9)
)
as
BEGIN
INSERT INTO Customers(Phone) VALUES (@Phone)
DECLARE @CustomerID INT
SET @CustomerID = @@IDENTITY
INSERT INTO Companies(CustomerID, CompanyName) VALUES(@CustomerID, @CompanyName)
END;

CREATE PROCEDURE new_private_individual (
@FirstName varchar(20),
@LastName varchar(20),
@Phone varchar(9)
)
as
BEGIN
INSERT INTO Customers(Phone) VALUES (@Phone)
DECLARE @CustomerID INT
SET @CustomerID = @@IDENTITY
INSERT INTO Private_Individuals(CustomerID, FirstName, LastName) VALUES(@CustomerID, @FirstName, @LastName)
END;

CREATE PROCEDURE new_attendee (
@ByCustomer integer,
@FirstName varchar(20),
@LastName varchar(20),
@IsStudent bit
)
as
BEGIN
INSERT INTO Attendees(ByCustomer,FirstName, LastName, IsStudent) VALUES(@ByCustomer, @FirstName, @LastName, @IsStudent)
END;

new_conference "tmp", "12/10/12", "12.12.12";

new_conference_day 1, "12/10/12", 20, 45

new_company "tmp", "123456789";

new_private_individual "Jan", "Chyb", "123415512"

new_attendee 2, "Ala", "Kota", 1
-- End of file.

