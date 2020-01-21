-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-15 08:20:36.146


--Dropping
  IF OBJECT_ID('dbo.Workshop_Attendee_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Workshop_Attendee_Reservations
  IF OBJECT_ID('dbo.Conference_Day_Attendee_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day_Attendee_Reservations
  IF OBJECT_ID('dbo.Conference_Day_Customer_Reservations', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day_Customer_Reservations
  IF OBJECT_ID('dbo.Workshop', 'U') IS NOT NULL
    DROP TABLE dbo.Workshop
  IF OBJECT_ID('dbo.Conference_Day', 'U') IS NOT NULL
    DROP TABLE dbo.Conference_Day
  IF OBJECT_ID('dbo.Conference', 'U') IS NOT NULL
    DROP TABLE dbo.Conference
  IF OBJECT_ID('dbo.Private_Individuals', 'U') IS NOT NULL
    DROP TABLE dbo.Private_Individuals
  IF OBJECT_ID('dbo.Companies', 'U') IS NOT NULL
    DROP TABLE dbo.Companies
  IF OBJECT_ID('dbo.Attendees', 'U') IS NOT NULL
    DROP TABLE dbo.Attendees
  IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
    DROP TABLE dbo.Customers


-- tables
-- Table: Workshop_Attendee_Reservations

CREATE TABLE Workshop_Attendee_Reservations
(
    ViaConferenceDayAttendeeReservation int NOT NULL,
    WorkshopID                          int NOT NULL,
    WasPaid                             bit NOT NULL,
    CONSTRAINT Workshop_Attendee_Reservations_pk PRIMARY KEY (ViaConferenceDayAttendeeReservation, WorkshopID)
);

-- Table: Conference_Day_Attendee_Reservations

CREATE TABLE Conference_Day_Attendee_Reservations
(
    AttendeeID                          int NOT NULL,
    ViaConferenceDayCustomerReservation int NOT NULL,
    ConferenceDayAttendeeReservationID  int NOT NULL IDENTITY (1,1),
    CONSTRAINT Unique_Reservation UNIQUE (AttendeeID, ViaConferenceDayCustomerReservation),
    CONSTRAINT Conference_Day_Attendee_Reservations_pk PRIMARY KEY (ConferenceDayAttendeeReservationID)
);


-- Table: Companies
CREATE TABLE Companies
(
    CustomerID  int         NOT NULL,
    CompanyName varchar(20) NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY (CustomerID)
);

-- Table: Conference_Day

CREATE TABLE Conference_Day
(
    ConferenceID       int  NOT NULL,
    ConferenceDate     date NOT NULL,
    AttendeeLimit      int  NOT NULL,
    BasePricePerPerson money  NOT NULL,
    CONSTRAINT Conference_Day_pk PRIMARY KEY (ConferenceDate)
);

-- Table: Conference

CREATE TABLE Conference
(
    ConferenceID   int         NOT NULL IDENTITY (1,1),
    StartDate      date        NOT NULL,
    EndDate        date        NOT NULL,
    ConferenceName varchar(50) NOT NULL,
    CONSTRAINT ConferenceDateCheck CHECK (StartDate < EndDate),
    CONSTRAINT Conference_pk PRIMARY KEY (ConferenceID)
);


-- Table: Conference_Day_Customer_Reservations
CREATE TABLE Conference_Day_Customer_Reservations
(
    ConferenceDay         date NOT NULL,
    CustomerID            int  NOT NULL,
    AttendeeAmount        int  NOT NULL,
    ReservationDate       date NOT NULL,
    WasPaid               bit  NOT NULL,
    CustomerReservationID int  NOT NULL IDENTITY (1,1),
	  CONSTRAINT UniqueCustomerReservation UNIQUE(ConferenceDay, CustomerID),
    CONSTRAINT Conference_Day_Customer_Reservations_pk PRIMARY KEY (CustomerReservationID)
);

-- Table: Customers
CREATE TABLE Customers
(
    CustomerID int        NOT NULL IDENTITY (1,1),
    Phone      varchar(9) NOT NULL,
    CONSTRAINT PhoneCheck CHECK (Phone Like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID)
);

-- Table: Private_Individuals
CREATE TABLE Private_Individuals
(
    CustomerID int         NOT NULL,
    FirstName  varchar(20) NOT NULL,
    LastName   varchar(20) NOT NULL,
    CONSTRAINT Private_Individuals_pk PRIMARY KEY (CustomerID)
);

-- Table: Attendees
CREATE TABLE Attendees
(
    AttendeeID int         NOT NULL IDENTITY (1,1),
    ByCustomer int         NOT NULL,
    FirstName  varchar(20) NOT NULL,
    LastName   varchar(20) NOT NULL,
    IsStudent  bit         NULL,
    CONSTRAINT Attendees_pk PRIMARY KEY (AttendeeID)
);

-- Table: Workshop
CREATE TABLE Workshop
(
    WorkshopID     int         NOT NULL IDENTITY (1,1),
    WorkshopDate   date        NOT NULL,
    StartTime      time(0)     NOT NULL,
    EndTime        time(0)     NOT NULL,
    PricePerPerson money       NOT NULL,
    AttendeeLimit  int         NOT NULL,
    WorkshopName   varchar(50) NOT NULL,
    CONSTRAINT WorkshopTimeCheck CHECK (StartTime < EndTime),
    CONSTRAINT Workshop_pk PRIMARY KEY (WorkshopID)
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


--INDEXES
create nonclustered index AttendeesFK_index on Attendees(AttendeeID)
create nonclustered index CDFK_index on Conference_Day(ConferenceID)
create nonclustered index WorkshopFK_index on Workshop(WorkshopDate)
GO

--PROCEDURES
CREATE OR ALTER PROCEDURE proc_new_conference(@ConferenceName varchar(50),
                                              @StartDate date,
                                              @EndDate date)
AS
BEGIN
    SET NOCOUNT ON;
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
                                            @WorkshopName varchar(50))
AS
BEGIN
    SET NOCOUNT ON;
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

CREATE OR ALTER PROCEDURE proc_add_conference_day_payment(@ConferenceDay date)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Conference_Day_Customer_Reservations
    SET WasPaid = 1
    WHERE ConferenceDay = @ConferenceDay
END
GO
-- dbo.proc_add_conference_day_payment'2012-12-10'
-- GO

CREATE OR ALTER PROCEDURE proc_add_workshop_payment(@ConferenceDayAttendeeReservationID int)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Workshop_Attendee_Reservations
    SET WasPaid = 1
    WHERE ViaConferenceDayAttendeeReservation = @ConferenceDayAttendeeReservationID
END
GO
-- dbo.proc_add_workshop_payment 1
-- GO

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
    SELECT @AttendeeAmount = SUM(AttendeeAmount)
    FROM Conference_Day_Customer_Reservations
    WHERE ConferenceDay = @ConferenceDay

    RETURN ISNULL(@AttendeeLimit, 0) - ISNULL(@AttendeeAmount, 0)
END
GO
--print dbo.func_conference_free_places('2012-12-10')


--Views
CREATE OR ALTER VIEW Customer_Reservation_Discount AS
(SELECT CustomerReservationID,DATEDIFF(day, ReservationDate, ConferenceDay) as diff,
CASE
	WHEN DATEDIFF(day, ReservationDate, ConferenceDay) >= 14 THEN 0.1
	WHEN DATEDIFF(day , Reservationdate, ConferenceDay) >=7 THEN 0.05
	ELSE 0
END
AS Discount
FROM Conference_Day_Customer_Reservations cdcr
)
GO

CREATE OR ALTER VIEW Attendee_Reservation_Value AS
(
SELECT ViaConferenceDayCustomerReservation,
       cdar.AttendeeID,
       IsStudent,
       (1 - Discount) *
       (0.9 * CAST(BasePricePerPerson AS FLOAT) * IsStudent + BasePricePerPerson * (1 - IsStudent)) AS ReservationValue
FROM Conference_Day_Attendee_Reservations cdar
         INNER JOIN Attendees a ON cdar.AttendeeID = a.AttendeeID
         INNER JOIN Conference_Day_Customer_Reservations cdcr
                    ON cdcr.CustomerReservationID = cdar.ViaConferenceDayCustomerReservation
         INNER JOIN Conference_Day cd ON cd.ConferenceDate = cdcr.ConferenceDay
         Inner JOIN Customer_Reservation_Discount crd ON crd.CustomerReservationID = cdcr.CustomerReservationID
    )
GO

CREATE OR ALTER VIEW Conference_Payments AS
(
SELECT CustomerID, ConferenceDay, SUM(ReservationValue) AS ReservationValue
FROM Conference_Day_Customer_Reservations cdcr
         INNER JOIN Attendee_Reservation_Value crv
                    ON cdcr.CustomerReservationID = crv.ViaConferenceDayCustomerReservation
WHERE WasPaid = 1
GROUP BY CustomerID, ConferenceDay
    )
GO

CREATE OR ALTER VIEW Customer_Payments AS
  (SELECT CustomerID, SUM(ReservationValue) AS CustomerValue
  FROM Conference_Payments cp
  GROUP BY CustomerID
)
GO
--SELECT * FROM Customer_Payments ORDER BY CustomerValue DESC
CREATE OR ALTER VIEW Workshop_Payments AS
  (SELECT war.WorkshopID, Count(*) * w.PricePerPerson as WorkshopValue
  FROM Workshop_Attendee_Reservations war
  INNER JOIN Workshop w ON war.WorkshopID = w.WorkshopID
  WHERE WasPaid = 1
  GROUP BY war.WorkshopID,w.PricePerPerson
)
GO

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
    SELECT @AttendeeAmount = SUM(AttendeeAmount)
    FROM Conference_Day_Customer_Reservations
    WHERE ConferenceDay = @ConferenceDay

    RETURN ISNULL(@AttendeeLimit, 0) - ISNULL(@AttendeeAmount, 0)
END
GO
--print dbo.func_conference_free_places('2012-12-10')

CREATE OR ALTER FUNCTION func_workshop_free_places(@WorkshopDay date)
    RETURNS int
AS
BEGIN
    DECLARE @WorkshopID int
    DECLARE @AttendeeLimit int
    SELECT @AttendeeLimit = AttendeeLimit, @WorkshopID = WorkshopID
    FROM Workshop
    WHERE WorkshopDate = @WorkshopDay

    DECLARE @AttendeeAmount int
    SELECT @AttendeeAmount = COUNT(WorkshopID)
    FROM Workshop_Attendee_Reservations
    WHERE WorkshopID = @WorkshopID

    RETURN ISNULL(@AttendeeLimit, 0) - ISNULL(@AttendeeAmount, 0)
END
GO
--print dbo.func_workshop_free_places('2012-12-10')
--GO

CREATE OR ALTER FUNCTION func_workshop_list_for_attendee(@AttendeeID int)
    RETURNS @ReturnTable TABLE
                         (
                             WorkshopID     int,
                             WorkshopDate   date,
                             StartTime      time(0),
                             EndTime        time(0),
                             PricePerPerson money,
                             AttendeeLimit  int,
                             WorkshopName   varchar(50)
                         )
AS
BEGIN
    INSERT INTO @ReturnTable
    SELECT *
    FROM Workshop AS w
    WHERE w.WorkshopID IN (SELECT war.WorkshopID
                           FROM Workshop_Attendee_Reservations AS war
                                    JOIN Conference_Day_Attendee_Reservations AS cdar
                                         ON war.ViaConferenceDayAttendeeReservation =
                                            cdar.ConferenceDayAttendeeReservationID
                           WHERE cdar.AttendeeID = @AttENDEEID)
    RETURN;
END
GO
-- SELECT * FROM dbo.func_workshop_list_for_attendee(1)
-- GO

CREATE OR ALTER FUNCTION func_conference_day_attendees(@ConferenceDate date)
    RETURNS @ReturnTable TABLE
                         (
                             AttendeeID int
                         )
AS
BEGIN
    INSERT INTO @ReturnTable
    SELECT AttendeeID
    FROM Conference_Day_Attendee_Reservations AS cdar
             JOIN Conference_Day_Customer_Reservations AS cdcr
                  ON cdar.ViaConferenceDayCustomerReservation = cdcr.CustomerReservationID
    WHERE cdcr.ConferenceDay = @ConferenceDate
    RETURN;
END
GO
-- SELECT * FROM dbo.func_conference_day_attendees('2012-12-10')
-- GO

CREATE OR ALTER FUNCTION func_conference_days(@ConferenceID int)
    RETURNS @ReturnTable TABLE
                         (
                             ConferenceID       int,
                             ConferenceDate     date,
                             AttendeeLimit      int,
                             BasePricePerPerson int
                         )
AS
BEGIN
    INSERT INTO @ReturnTable
    SELECT *
    FROM Conference_Day AS cd
    WHERE @ConferenceID = cd.ConferenceID
    RETURN;
END
GO
-- SELECT * FROM dbo.func_conference_days(1)
-- GO

CREATE OR ALTER FUNCTION func_workshop_list_by_conference(@ConferenceID int)
    RETURNS @ReturnTable TABLE
                         (
                             WorkshopID int
                         )
AS
BEGIN
    INSERT INTO @ReturnTable
    SELECT w.WorkshopID
    FROM Workshop AS w
             JOIN Conference_Day AS cd ON w.WorkshopDate = cd.ConferenceDate
    WHERE cd.ConferenceID = @ConferenceID
    RETURN;
END
GO
--SELECT * FROM dbo.func_workshop_list_by_conference(1)
--GO

CREATE OR ALTER FUNCTION func_workshop_list_by_day(@Day date)
    RETURNS @ReturnTable TABLE
                         (
                             WorkshopID int
                         )
AS
BEGIN
    INSERT INTO @ReturnTable
    SELECT WorkshopID
    FROM Workshop
    WHERE WorkshopDate = @Day
    RETURN
END
GO
-- SELECT * FROM dbo.func_workshop_list_by_day('2012-12-10')
-- GO


--TRIGGERS
CREATE OR ALTER TRIGGER trig_conference_day_within_conference
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
            THROW 51000, 'Not enough places for conference', 1;
        END
END
GO

CREATE OR ALTER TRIGGER trig_not_enough_places_workshop
    ON Workshop_Attendee_Reservations
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS i
                       JOIN Workshop AS w
                            ON i.WorkshopID = w.WorkshopID
              WHERE (dbo.func_workshop_free_places(w.WorkshopDate) < 0))
        BEGIN
            THROW 51000, 'Not enough places for workshop', 1;
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

CREATE OR ALTER TRIGGER trig_overlapping_workshops
    ON Workshop_Attendee_Reservations
    AFTER INSERT
    AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AttendeeID int
    SELECT @AttendeeID = cdar.AttendeeID
    FROM Conference_Day_Attendee_Reservations AS cdar
             JOIN Workshop_Attendee_Reservations AS war
                  ON ConferenceDayAttendeeReservationID = war.ViaConferenceDayAttendeeReservation
    IF EXISTS(SELECT *
              FROM inserted AS i
                       JOIN Workshop AS w ON i.WorkshopID = w.WorkshopID
                       JOIN dbo.func_workshop_list_for_attendee(@AttendeeID) AS awl ON w.WorkshopDate = awl.WorkshopDate
              WHERE awl.WorkshopID <> w.WorkshopID
                AND (w.StartTime < awl.StartTime AND awl.StartTime < w.EndTime OR
                     w.StartTime < awl.EndTime AND awl.EndTime < w.EndTime)
        )
        BEGIN
            THROW 51000, 'Workshop overlapping with another workshop.', 1;
        END
END
GO

CREATE OR ALTER TRIGGER trig_cancel_payed_conference
    ON Conference_Day_Customer_Reservations
    AFTER UPDATE
    AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS i
              WHERE i.WasPaid = 1)
    BEGIN
        THROW 51000, 'Trying to cancel already paid reservation.', 1;
    END
END
GO

-- End of file.

