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
//SQL, P3.2


-- Order details with item count (no JOIN/GROUP BY)
SELECT
    soh.SalesOrderID AS OrderNumber,
    soh.OrderDate,
    (SELECT COUNT(*)
     FROM Sales.SalesOrderDetail sod
     WHERE sod.SalesOrderID = soh.SalesOrderID) AS ItemCount
FROM
    Sales.SalesOrderHeader soh;

//Execution
//SQL, P3.3

-- Employee first name counts (no JOIN/GROUP BY)
SELECT DISTINCT
    p.FirstName,
    (SELECT COUNT(*)
     FROM Person.Person p2
     WHERE p2.FirstName = p.FirstName
       AND EXISTS (
           SELECT 1
           FROM HumanResources.Employee e
           WHERE e.BusinessEntityID = p2.BusinessEntityID
       )) AS EmployeeCount
FROM
    Person.Person p
WHERE
    EXISTS (
        SELECT 1
        FROM HumanResources.Employee e
        WHERE e.BusinessEntityID = p.BusinessEntityID
    )
ORDER BY
    EmployeeCount DESC;

//Execution
//SQL, P3.4



-- Top 10 vendors by product price (no JOIN/GROUP BY)
SELECT TOP 10
    v.Name AS VendorName,
    (SELECT MAX(pv.StandardPrice)
     FROM Purchasing.ProductVendor pv
     WHERE pv.BusinessEntityID = v.BusinessEntityID) AS MaxProductPrice
FROM
    Purchasing.Vendor v
WHERE
    EXISTS (
        SELECT 1
        FROM Purchasing.ProductVendor pv
        WHERE pv.BusinessEntityID = v.BusinessEntityID
    )
ORDER BY
    MaxProductPrice DESC;
