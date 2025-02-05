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
