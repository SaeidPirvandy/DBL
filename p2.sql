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
