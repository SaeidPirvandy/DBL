//SQL, p2.1

CREATE OR ALTER PROCEDURE SearchCommentsByText
    @SearchString NVARCHAR(MAX)
AS
BEGIN
    SELECT
        ProductReviewID AS ID,
        Comments AS CommentText
    FROM
        Production.ProductReview
    WHERE
        Comments LIKE '%' + @SearchString + '%';
END;

//Execution
   EXEC SearchCommentsByText @SearchString = 'bike';
//SQL, P2.2

CREATE VIEW ProductsWithDetails
AS
SELECT
    ProductID,
    Name,
    ProductNumber
FROM
    Production.Product
WHERE
    Style IS NOT NULL
    OR Size IS NOT NULL
    OR Color IS NOT NULL;

//Execution

   SELECT * FROM ProductsWithDetails;
//SQL, P2.3
CREATE OR ALTER VIEW ProductsWithDetails
AS
SELECT
    ProductID,
    Name,
    Color -- Added Color to the output
FROM
    Production.Product
WHERE
    Style IS NOT NULL
    OR Size IS NOT NULL
    OR Color IS NOT NULL;
//SQL, P2.4

CREATE OR ALTER PROCEDURE GetPersonsModifiedBetweenDates
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT
        BusinessEntityID AS UserID,
        FirstName,
        LastName,
        ModifiedDate
    FROM
        Person.Person
    WHERE
        ModifiedDate BETWEEN @StartDate AND @EndDate
    ORDER BY
        ModifiedDate DESC; -- Optional: Sort by most recent
END;

//
   EXEC GetPersonsModifiedBetweenDates
       @StartDate = '2023-01-01',
       @EndDate = '2023-12-31';
   ```

//Execution

    UPDATE Person.Person
    SET ModifiedDate = GETDATE() -- Sets to current date/time
    WHERE BusinessEntityID = 1;
//SQL, P2.5

CREATE OR ALTER PROCEDURE GetOrdersByDateRange
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT
        SalesOrderID,
        OrderDate,
        TotalDue
    FROM
        Sales.SalesOrderHeader
    WHERE
        OrderDate BETWEEN @StartDate AND @EndDate
    ORDER BY
        OrderDate;
END;

//Execution
CREATE OR ALTER PROCEDURE GetOrdersByDateAndAmount
    @StartDate DATETIME,
    @EndDate DATETIME,
    @MinTotalDue MONEY
AS
BEGIN
    -- Create a temporary table to hold results from Part 1's SP
    CREATE TABLE #TempOrders (
        SalesOrderID INT,
        OrderDate DATETIME,
        TotalDue MONEY
    );

    -- Insert results from the first SP into the temp table
    INSERT INTO #TempOrders
    EXEC GetOrdersByDateRange @StartDate, @EndDate;

    -- Filter by minimum TotalDue
    SELECT
        SalesOrderID,
        OrderDate,
        TotalDue
    FROM
        #TempOrders
    WHERE
        TotalDue >= @MinTotalDue
    ORDER BY
        TotalDue DESC; -- Optional: Show highest amounts first

    -- Cleanup (temp tables auto-delete when the SP finishes)
END;



//Execution

EXEC GetOrdersByDateAndAmount
    @StartDate = '2011-06-01',
    @EndDate = '2011-06-30',
    @MinTotalDue = 1000; -- Example: $1,000 minimum
//SQL, P2.6

CREATE VIEW ProductsWithNullColor
AS
SELECT
    ProductID,
    Name,
    ProductNumber, -- Optional: Include other columns
    Color
FROM
    Production.Product
WHERE
    Color IS NULL;
//SQL, P2.7

CREATE VIEW FormattedAddresses
AS
SELECT
    CONCAT('[', AddressID, '] ', AddressLine1, ' [', City, ': ', PostalCode, ']') AS FormattedAddress
FROM
    Person.Address;

//Execution

SELECT * FROM FormattedAddresses;
//SQL, P2.8

CREATE VIEW SpecialOfferTax
AS
SELECT TOP 100 PERCENT
    SpecialOfferID,
    ISNULL(MaxQty, 20) * DiscountPct AS Tax
FROM
    Sales.SpecialOffer
ORDER BY
    Tax DESC;


//Execution

SELECT * FROM SpecialOfferTax;
//SQL, P2.9

CREATE VIEW PersonNameCodes
AS
SELECT
    BusinessEntityID,
    LEFT(FirstName, 5) + '_' + LEFT(LastName, 5) AS NameCode
FROM
    Person.Person;


//Execution

SELECT * FROM PersonNameCodes;
//SQL, P2.10

AS
BEGIN
    SELECT
        SalesOrderID,
        OrderDate,
        ShipDate,
        DATEDIFF(DAY, OrderDate, ShipDate) AS DaysDifference
    FROM
        Sales.SalesOrderHeader
    WHERE
        DATEDIFF(DAY, OrderDate, ShipDate) > @DiffDays
    ORDER BY
        DaysDifference DESC;
END;


//Execution

AS
BEGIN
    SELECT
        SalesOrderID,
        OrderDate,
        ShipDate,
        DATEDIFF(DAY, OrderDate, ShipDate) AS DaysDifference
    FROM
        Sales.SalesOrderHeader
    WHERE
        DATEDIFF(DAY, OrderDate, ShipDate) > @DiffDays
    ORDER BY
        DaysDifference DESC;
END;
//SQL, P2.11

CREATE VIEW SalesOrderWithRandom
AS
SELECT
    SalesOrderID,
    ROUND(SubTotal, 1) AS RoundedSubTotal,
    FLOOR(RAND(CHECKSUM(NEWID())) * 101) + 100 AS RandomNumber
FROM
    Sales.SalesOrderHeader;

//Execution

    SELECT * FROM SalesOrderWithRandom;
//SQL, P2.12
//PART 1

CREATE VIEW SalesOrderDetailCategories
AS
SELECT
    SalesOrderDetailID,
    SalesOrderID,
    OrderQty,
    CASE
        WHEN OrderQty < 10 THEN 'Less than 10'
        WHEN OrderQty BETWEEN 10 AND 30 THEN 'Between 10 and 30'
        ELSE 'Greater than 30'
    END AS OrderQtyCategory
FROM
    Sales.SalesOrderDetail;

//PART 2


    CREATE OR ALTER PROCEDURE GetOrderQtyCategoryStats
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT
        SODC.OrderQtyCategory,
        COUNT(*) AS RecordCount
    FROM
        SalesOrderDetailCategories SODC
    INNER JOIN
        Sales.SalesOrderHeader SOH ON SODC.SalesOrderID = SOH.SalesOrderID
    WHERE
        SOH.OrderDate BETWEEN @StartDate AND @EndDate
    GROUP BY
        SODC.OrderQtyCategory
    ORDER BY
        RecordCount DESC;
END;


//Execution

EXEC GetOrderQtyCategoryStats
    @StartDate = '2011-06-01',
    @EndDate = '2011-06-30';
