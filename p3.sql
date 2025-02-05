//SQL, P3.1

-- Cities with count of people (no JOIN/GROUP BY)
SELECT DISTINCT
    a.City,
    (SELECT COUNT(DISTINCT p.BusinessEntityID)
     FROM Person.Person p
     WHERE EXISTS (
         SELECT 1
         FROM Person.BusinessEntity be
         WHERE be.BusinessEntityID = p.BusinessEntityID
           AND EXISTS (
               SELECT 1
               FROM Person.BusinessEntityAddress bea
               WHERE bea.BusinessEntityID = be.BusinessEntityID
                 AND bea.AddressID = a.AddressID
           )
     )) AS PeopleCount
FROM
    Person.Address a
ORDER BY
    PeopleCount DESC;
