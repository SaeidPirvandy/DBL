//SQL, P4.1
//part 1
//step 1
BEGIN
    CREATE TABLE ReportTo (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(50),
        LastName NVARCHAR(50),
        SeniorManagerID INT,
        FOREIGN KEY (SeniorManagerID) REFERENCES ReportTo(ID)
    );
END

//part 1
//step 2

CREATE OR ALTER PROCEDURE GenerateReportToData
    @NumberOfRecords INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Create table if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ReportTo')
    BEGIN
        CREATE TABLE ReportTo (
            ID INT IDENTITY(1,1) PRIMARY KEY,
            FirstName NVARCHAR(50),
            LastName NVARCHAR(50),
            SeniorManagerID INT,
            FOREIGN KEY (SeniorManagerID) REFERENCES ReportTo(ID)
        );
    END

    DECLARE @Counter INT = 0;
    DECLARE @ExistingCount INT = (SELECT COUNT(*) FROM ReportTo);

    -- Insert first record with NULL SeniorManagerID if table is empty
    IF @ExistingCount = 0 AND @NumberOfRecords >= 1
    BEGIN
        INSERT INTO ReportTo (FirstName, LastName, SeniorManagerID)
        SELECT TOP 1 FirstName, LastName, NULL
        FROM Person.Person
        ORDER BY NEWID();

        SET @Counter = 1;
        SET @ExistingCount = 1;
    END

    -- Insert remaining records with random SeniorManagerID
    WHILE @Counter < @NumberOfRecords
    BEGIN
        INSERT INTO ReportTo (FirstName, LastName, SeniorManagerID)
        SELECT TOP 1
            p.FirstName,
            p.LastName,
            (SELECT TOP 1 ID FROM ReportTo ORDER BY NEWID()) -- Random existing ID
        FROM Person.Person p
        ORDER BY NEWID();

        SET @Counter += 1;
    END
END;

//part 2
//step 1

BEGIN
    CREATE TABLE ReportTo (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(50),
        LastName NVARCHAR(50),
        SeniorManagerID INT,
        FOREIGN KEY (SeniorManagerID) REFERENCES ReportTo(ID)
    );
END

//Execution

EXEC GenerateReportToData @NumberOfRecords = 10; -- Generates 10 records

//part 2
//step 2

WITH EmployeeHierarchy AS (
    SELECT
        ID,
        FirstName,
        LastName,
        SeniorManagerID,
        1 AS Level
    FROM ReportTo
    WHERE SeniorManagerID IS NULL -- Start with the root (Senior Manager)
    UNION ALL
    SELECT
        r.ID,
        r.FirstName,
        r.LastName,
        r.SeniorManagerID,
        eh.Level + 1
    FROM ReportTo r
    INNER JOIN EmployeeHierarchy eh
        ON r.SeniorManagerID = eh.ID
)
SELECT * FROM EmployeeHierarchy;
