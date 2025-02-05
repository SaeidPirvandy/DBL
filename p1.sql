SELECT
    BusinessEntityID,
    FirstName,
    LastName
FROM
    Person.Person
WHERE
    FirstName LIKE '%[abcdef]';
