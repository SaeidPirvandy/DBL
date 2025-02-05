SELECT
    BusinessEntityID,
    FirstName,
    LastName
FROM
    Person.Person
WHERE
    FirstName LIKE '%[abcdef]';


SELECT
    a.City,
    COUNT(DISTINCT p.BusinessEntityID) AS PeopleCount
FROM
    Person.Person p
JOIN Person.BusinessEntity be
    ON p.BusinessEntityID = be.BusinessEntityID
JOIN Person.BusinessEntityAddress bea
    ON be.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a
    ON bea.AddressID = a.AddressID
GROUP BY
    a.City
ORDER BY
    PeopleCount DESC;
