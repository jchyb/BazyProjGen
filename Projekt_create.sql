-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-15 08:20:36.146

-- tables
-- Table: Attendees
IF OBJECT_ID('dbo.Attendees', 'U') IS NOT NULL
    DROP TABLE dbo.Attendees
CREATE TABLE Attendees
(
    AttendeeID int         NOT NULL IDENTITY (1,1),
    ByCustomer int         NOT NULL,
    FirstName  varchar(20) NOT NULL,
    LastName   varchar(20) NOT NULL,
    IsStudent  bit         NULL,
    CONSTRAINT Attendees_pk PRIMARY KEY (AttendeeID)
);

-- Table: Companies
IF OBJECT_ID('dbo.Companies', 'U') IS NOT NULL
    DROP TABLE dbo.Companies
CREATE TABLE Companies
(
    CustomerID  int         NOT NULL,
    CompanyName varchar(20) NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY (CustomerID)
);

-- Table: Conference
IF OBJECT_ID('dbo.Conference', 'U') IS NOT NULL
    DROP TABLE dbo.Conference
CREATE TABLE Conference
(
    ConferenceID   int         NOT NULL IDENTITY (1,1),
    StartDate      date        NOT NULL,
    EndDate        date        NOT NULL,
    ConferenceName varchar(20) NOT NULL,
    CONSTRAINT ConferenceDateCheck CHECK (StartDate < EndDate),
    CONSTRAINT Conference_pk PRIMARY KEY (ConferenceID)
);

-- Table: Conference_Day
IF OBJECT_ID('dbo.Conference_Day', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day
CREATE TABLE Conference_Day
(
    ConferenceID       int  NOT NULL,
    ConferenceDate     date NOT NULL,
    AttendeeLimit      int  NOT NULL,
    BasePricePerPerson int  NOT NULL,
    CONSTRAINT Conference_Day_pk PRIMARY KEY (ConferenceDate)
);

-- Table: Conference_Day_Attendee_Reservations
IF OBJECT_ID('dbo.Conference_Day_Attendee_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day_Attendee_Reservations
CREATE TABLE Conference_Day_Attendee_Reservations
(
    AttendeeID                          int NOT NULL,
    ViaConferenceDayCustomerReservation int NOT NULL,
    ConferenceDayAttendeeReservationID  int NOT NULL IDENTITY (1,1),
    CONSTRAINT Unique_Reservation UNIQUE (AttendeeID, ViaConferenceDayCustomerReservation),
    CONSTRAINT Conference_Day_Attendee_Reservations_pk PRIMARY KEY (ConferenceDayAttendeeReservationID)
);

-- Table: Conference_Day_Customer_Reservations
IF OBJECT_ID('dbo.Conference_Day_Customer_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day_Customer_Reservations
CREATE TABLE Conference_Day_Customer_Reservations
(
    ConferenceDay         date NOT NULL,
    CustomerID            int  NOT NULL,
    AttendeeAmount        int  NOT NULL,
    ReservationDate       date NOT NULL,
    WasPaid               bit  NOT NULL,
    CancellationDate      date NULL,
    CustomerReservationID int  NOT NULL IDENTITY (1,1),
    CONSTRAINT DateCheck CHECK (CancellationDate IS NULL OR ReservationDate < CancellationDate),
    CONSTRAINT Conference_Day_Customer_Reservations_pk PRIMARY KEY (CustomerReservationID)
);

-- Table: Customers
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
    DROP TABLE dbo.Customers
CREATE TABLE Customers
(
    CustomerID int        NOT NULL IDENTITY (1,1),
    Phone      varchar(9) NOT NULL,
    CONSTRAINT PhoneCheck CHECK (Phone Like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID)
);

-- Table: Private_Individuals
IF OBJECT_ID('dbo.Private_Individuals', 'U') IS NOT NULL
    DROP TABLE dbo.Private_Individuals
CREATE TABLE Private_Individuals
(
    CustomerID int         NOT NULL,
    FirstName  varchar(20) NOT NULL,
    LastName   varchar(20) NOT NULL,
    CONSTRAINT Private_Individuals_pk PRIMARY KEY (CustomerID)
);

-- Table: Workshop
IF OBJECT_ID('dbo.Workshop', 'U') IS NOT NULL
    DROP TABLE dbo.Workshop
CREATE TABLE Workshop
(
    WorkshopID     int         NOT NULL IDENTITY (1,1),
    WorkshopDate   date        NOT NULL,
    StartTime      time(0)     NOT NULL,
    EndTime        time(0)     NOT NULL,
    PricePerPerson int         NOT NULL,
    AttendeeLimit  int         NOT NULL,
    WorkshopName   varchar(20) NOT NULL,
    CONSTRAINT WorkshopTimeCheck CHECK (StartTime < EndTime),
    CONSTRAINT Workshop_pk PRIMARY KEY (WorkshopID)
);

-- Table: Workshop_Attendee_Reservations
IF OBJECT_ID('dbo.Workshop_Attendee_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Workshop_Attendee_Reservations
CREATE TABLE Workshop_Attendee_Reservations
(
    ViaConferenceDayAttendeeReservation int NOT NULL,
    WorkshopID                          int NOT NULL,
    WasPaid                             bit NOT NULL,
    CONSTRAINT Workshop_Attendee_Reservations_pk PRIMARY KEY (ViaConferenceDayAttendeeReservation, WorkshopID)
);

-- foreign keys
-- Reference: Attendees_Customers (table: Attendees)
ALTER TABLE Attendees
    ADD CONSTRAINT Attendees_Customers
        FOREIGN KEY (ByCustomer)
            REFERENCES Customers (CustomerID);

-- Reference: CDAR_Attendees (table: Conference_Day_Attendee_Reservations)
ALTER TABLE Conference_Day_Attendee_Reservations
    ADD CONSTRAINT CDAR_Attendees
        FOREIGN KEY (AttendeeID)
            REFERENCES Attendees (AttendeeID);

-- Reference: CDAR_CDR (table: Conference_Day_Attendee_Reservations)
ALTER TABLE Conference_Day_Attendee_Reservations
    ADD CONSTRAINT CDAR_CDR
        FOREIGN KEY (ViaConferenceDayCustomerReservation)
            REFERENCES Conference_Day_Customer_Reservations (CustomerReservationID)
            ON DELETE CASCADE;

-- Reference: CDAR_WAR (table: Workshop_Attendee_Reservations)
ALTER TABLE Workshop_Attendee_Reservations
    ADD CONSTRAINT CDAR_WAR
        FOREIGN KEY (ViaConferenceDayAttendeeReservation)
            REFERENCES Conference_Day_Attendee_Reservations (ConferenceDayAttendeeReservationID)
            ON DELETE CASCADE;

-- Reference: CDR_Customers (table: Conference_Day_Customer_Reservations)
ALTER TABLE Conference_Day_Customer_Reservations
    ADD CONSTRAINT CDR_Customers
        FOREIGN KEY (CustomerID)
            REFERENCES Customers (CustomerID);

-- Reference: CD_CDR (table: Conference_Day_Customer_Reservations)
ALTER TABLE Conference_Day_Customer_Reservations
    ADD CONSTRAINT CD_CDR
        FOREIGN KEY (ConferenceDay)
            REFERENCES Conference_Day (ConferenceDate);

-- Reference: CD_Conference (table: Conference_Day)
ALTER TABLE Conference_Day
    ADD CONSTRAINT CD_Conference
        FOREIGN KEY (ConferenceID)
            REFERENCES Conference (ConferenceID);

-- Reference: Company_Customers (table: Companies)
ALTER TABLE Companies
    ADD CONSTRAINT Company_Customers
        FOREIGN KEY (CustomerID)
            REFERENCES Customers (CustomerID);

-- Reference: PI_Customers (table: Private_Individuals)
ALTER TABLE Private_Individuals
    ADD CONSTRAINT PI_Customers
        FOREIGN KEY (CustomerID)
            REFERENCES Customers (CustomerID);

-- Reference: WAR_Workshop (table: Workshop_Attendee_Reservations)
ALTER TABLE Workshop_Attendee_Reservations
    ADD CONSTRAINT WAR_Workshop
        FOREIGN KEY (WorkshopID)
            REFERENCES Workshop (WorkshopID);

-- Reference: Workshop_CD (table: Workshop)
ALTER TABLE Workshop
    ADD CONSTRAINT Workshop_CD
        FOREIGN KEY (WorkshopDate)
            REFERENCES Conference_Day (ConferenceDate);
GO

CREATE OR ALTER PROCEDURE proc_new_conference(@ConferenceName varchar(20),
                                              @StartDate date,
                                              @EndDate date)
AS
BEGIN
    SET NOCOUNT ON;
    IF (@StartDate > @EndDate)
        BEGIN
            THROW 51000, 'Start time must be after time', 1;
        end
    INSERT INTO Conference(ConferenceName, StartDate, EndDate) VALUES (@ConferenceName, @StartDate, @EndDate)
END
GO

CREATE OR ALTER PROCEDURE proc_new_conference_day(@ConferenceID int,
                                                  @ConferenceDate date,
                                                  @AttendeeLimit int,
                                                  @BasePricePerPerson int)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_Day(ConferenceID, ConferenceDate, AttendeeLimit, BasePricePerPerson)
    VALUES (@ConferenceID, @ConferenceDate, @AttendeeLimit, @BasePricePerPerson)
END
GO

CREATE OR ALTER PROCEDURE proc_new_company(@CompanyName varchar(20),
                                           @Phone varchar(9))
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Customers(Phone) VALUES (@Phone)
    DECLARE @CustomerID INT
    SET @CustomerID = @@IDENTITY
    INSERT INTO Companies(CustomerID, CompanyName) VALUES (@CustomerID, @CompanyName)
END
GO

CREATE OR ALTER PROCEDURE proc_new_private_individual(@FirstName varchar(20),
                                                      @LastName varchar(20),
                                                      @Phone varchar(9))
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Customers(Phone) VALUES (@Phone)
    DECLARE @CustomerID INT
    SET @CustomerID = @@IDENTITY
    INSERT INTO Private_Individuals(CustomerID, FirstName, LastName) VALUES (@CustomerID, @FirstName, @LastName)
END
GO

CREATE OR ALTER PROCEDURE proc_new_attendee(@ByCustomer integer,
                                            @FirstName varchar(20),
                                            @LastName varchar(20),
                                            @IsStudent bit)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Attendees(ByCustomer, FirstName, LastName, IsStudent)
    VALUES (@ByCustomer, @FirstName, @LastName, @IsStudent)
END
GO

CREATE OR ALTER PROCEDURE proc_new_workshop(@WorkshopDate date,
                                            @StartTime time(0),
                                            @EndTime time(0),
                                            @PricePerPerson int,
                                            @AttendeeLimit int,
                                            @WorkshopName varchar(20))
AS
BEGIN
    SET NOCOUNT ON;
    IF (@StartTime > @EndTime)
        BEGIN
            THROW 51000, 'Start time must be after time', 1;
        end
    INSERT INTO Workshop(WorkshopDate, StartTime, EndTime, PricePerPerson, AttendeeLimit, WorkshopName)
    VALUES (@WorkshopDate, @StartTime, @EndTime, @PricePerPerson, @AttendeeLimit, @WorkshopName)
END
GO

CREATE OR ALTER PROCEDURE proc_new_customer_conference_day_reservation(@ConferenceDay date,
                                                                       @CustomerID int,
                                                                       @AttendeeAmount int,
                                                                       @ReservationDate date,
                                                                       @WasPaid bit)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_Day_Customer_Reservations(ConferenceDay, CustomerID, AttendeeAmount, ReservationDate, WasPaid)
    VALUES (@ConferenceDay, @CustomerID, @AttendeeAmount, @ReservationDate, @WasPaid)
END
GO

CREATE OR ALTER PROCEDURE proc_cancel_customer_conference_day_reservation(@CustomerReservationID int)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE
    FROM Workshop_Attendee_Reservations
    WHERE ViaConferenceDayAttendeeReservation IN
          (SELECT ConferenceDayAttendeeReservationID
           FROM Conference_Day_Attendee_Reservations as tmp
           WHERE tmp.ViaConferenceDayCustomerReservation = @CustomerReservationID)
    DELETE FROM Conference_Day_Attendee_Reservations WHERE ViaConferenceDayCustomerReservation = @CustomerReservationID
    DELETE FROM Conference_Day_Customer_Reservations WHERE CustomerReservationID = @CustomerReservationID
END
GO

CREATE OR ALTER PROCEDURE proc_new_attendee_conference_day_reservation(@AttendeeID int,
                                                                       @ViaConferenceDayCustomerReservation int)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_Day_Attendee_Reservations(AttendeeID, ViaConferenceDayCustomerReservation)
    VALUES (@AttendeeID, @ViaConferenceDayCustomerReservation)
END
GO

CREATE OR ALTER PROCEDURE proc_cancel_attendee_conference_day_reservation(@ConferenceDayAttendeeReservationID int)
AS
BEGIN
    SET NOCOUNT ON;
    --     DELETE
--     FROM Workshop_Attendee_Reservations
--     WHERE ViaConferenceDayAttendeeReservation = @ConferenceDayAttendeeReservationID
    DELETE
    FROM Conference_Day_Attendee_Reservations
    WHERE ConferenceDayAttendeeReservationID = @ConferenceDayAttendeeReservationID
END
GO

CREATE OR ALTER PROCEDURE proc_new_workshop_attendee_reservation(@ViaConferenceDayAttendeeReservation int,
                                                                 @WorkshopID int,
                                                                 @WasPaid bit)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workshop_Attendee_Reservations(ViaConferenceDayAttendeeReservation, WorkshopID, WasPaid)
    VALUES (@ViaConferenceDayAttendeeReservation, @WorkshopID, @WasPaid)
END
GO

CREATE OR ALTER PROCEDURE proc_cancel_workshop_attendee_reservation(@ViaConferenceDayAttendeeReservation int)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE
    FROM Workshop_Attendee_Reservations
    WHERE ViaConferenceDayAttendeeReservation = @ViaConferenceDayAttendeeReservation
END
GO


proc_new_conference 'td', '10-12-12', '12-12-12'
GO
proc_new_conference_day 1, '12/10/12', 20, 45;
GO
proc_new_company 'tmp', '123456789';
GO
proc_new_private_individual N'Stanis³aw', 'Denkowski', '123415512';
GO
proc_new_attendee 2, 'Ala', 'Kota', 1;
GO
        proc_new_workshop '12/10/12', '10:30:00', '12:00:00', 20,
        35, 'Programowanie W Grze Minecraft';
GO
        proc_new_customer_conference_day_reservation '12/10/12', 2, 3, '12/9/12', 1;
GO
proc_new_attendee_conference_day_reservation 1, 1;
GO
proc_new_workshop_attendee_reservation 1, 1, 0;
GO

-- proc_cancel_customer_conference_day_reservation 1
-- GO

--FUNCTIONS
CREATE OR ALTER FUNCTION func_conference_free_places(@ConferenceDay date)
    RETURNS int
AS
BEGIN
    DECLARE @AttendeeLimit int
    SELECT @AttendeeLimit = AttendeeLimit
    FROM Conference_Day
    WHERE ConferenceDate = @ConferenceDay

    DECLARE @AttendeeAmount int
    SELECT @AttendeeAmount = AttendeeAmount
    FROM Conference_Day_Customer_Reservations
    WHERE ConferenceDay = @ConferenceDay

    RETURN ISNULL(@AttendeeLimit, 0) - ISNULL(@AttendeeAmount, 0)
END
GO
--print dbo.func_conference_free_places('2012-12-10')


-- nie mozliwe jak na razie
-- CREATE OR ALTER FUNCTION func_workshop_free_places(@WorkshopDay date)
--     RETURNS int
-- AS
-- BEGIN
--     DECLARE @AttendeeLimit int
--     SELECT @AttendeeLimit = AttendeeLimit
--     FROM Workshop
--     WHERE WorkshopDate = @WorkshopDay
--
--     DECLARE @AttendeeAmount int
--     SELECT @AttendeeAmount = AttendeeAmount
--     FROM Conference_Day_Customer_Reservations
--     WHERE ConferenceDay = @WorkshopDay
--
--     RETURN ISNULL(@AttendeeLimit, 0) - ISNULL(@AttendeeAmount, 0)
-- END
-- GO

-- DOESNT WORK
-- CREATE OR ALTER FUNCTION func_workshop_list_for_attendee (@AttendeeID, int)
--     RETURNS TABLE
-- AS
-- BEGIN
--     RETURN (SELECT * FROM Workshop AS w
--      JOIN Workshop_Attendee_Reservations AS war ON w.WorkshopID = war.WorkshopID
--     JOIN Conference_Day_Attendee_Reservations AS cdar)
-- END
-- GO

--TRIGGERS
CREATE OR ALTER TRIGGER trig_conference_day_withing_conference
    ON Conference_Day
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(
            SELECT *
            FROM inserted AS i
                     JOIN Conference AS c ON c.ConferenceID = i.ConferenceID
            WHERE i.ConferenceDate < c.StartDate
               OR i.ConferenceDate > c.EndDate
        )
        BEGIN
            THROW 51000, 'Conference day(s) is(are) not within Conference duration.', 1
        END
END
GO
-- proc_new_conference_day 1, '11-08-2012', 20, 45;
-- GO

CREATE OR ALTER TRIGGER trig_not_enough_places_conference
    ON Conference_Day_Customer_Reservations
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(
            SELECT *
            FROM inserted AS i
            WHERE (dbo.func_conference_free_places(i.ConferenceDay) < 0)
        )
        BEGIN
            THROW 51000, 'Not enough places', 1;
        END
END
GO

CREATE OR ALTER TRIGGER trig_workshop_reservation_corresponds_with_conference
    ON Workshop_Attendee_Reservations
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(
            SELECT *
            FROM inserted AS i
                     JOIN Conference_Day_Attendee_Reservations as cdar
                          ON i.ViaConferenceDayAttendeeReservation = cdar.ConferenceDayAttendeeReservationID
                     JOIN Conference_Day_Customer_Reservations AS cdcr
                          ON cdcr.CustomerReservationID = cdar.ViaConferenceDayCustomerReservation
                     JOIN Workshop as w
                          ON i.WorkshopID = w.WorkshopID
            WHERE w.WorkshopDate = cdcr.ConferenceDay
        )
        BEGIN
            THROW 51000, 'Can not reserve workshop without attending the conference on the same day', 1;
        END
END
GO
-- proc_new_conference_day 1, '11-11-2012', 20, 45;
-- GO
-- proc_new_workshop '11-11-2012', '10:30:00', '12:00:00', 20, 35, 'Programowanie W Minecraft'
-- GO
-- proc_new_workshop_attendee_reservation 1, 2, 0
-- GO

CREATE OR ALTER TRIGGER trig_attendee_mentioned_by_customer
    ON Conference_Day_Attendee_Reservations
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT *
                  FROM inserted AS i
                           JOIN Attendees AS a ON i.AttendeeID = a.AttendeeID
                           JOIN Conference_Day_Customer_Reservations AS cdcr
                                ON i.ViaConferenceDayCustomerReservation = cdcr.CustomerReservationID
                  Where cdcr.CustomerID = a.ByCustomer)
        BEGIN
            THROW 51000, 'Tried to attend conference but is not mentioned by the customer reserving conference.', 1
        END
END
GO
-- proc_new_attendee 1, 'pan', 'zly', 0
-- GO
-- proc_new_attendee_conference_day_reservation 2, 1
-- GO

--DOESNT WORK
-- CREATE OR ALTER TRIGGER trig_overlapping_workshops
--     ON Workshop_Attendee_Reservations
--     AFTER INSERT
--     AS
-- BEGIN
--     SET NOCOUNT ON;
--     IF EXISTS(SELECT *
--               FROM inserted AS i
--                        JOIN Workshop_Attendee_Reservations AS war
--                             ON i.ViaConferenceDayAttendeeReservation = war.ViaConferenceDayAttendeeReservation
--               WHERE i.WorkshopID <> war.WorkshopID
--               JOIN Workshop AS wi ON i.WorkshopID = wi.WorkshopID
--         )
-- END
-- GO

-- End of file.

