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
