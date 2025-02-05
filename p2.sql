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
