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


//SQL, P1.3

SELECT
    soh.SalesOrderID AS OrderNumber,
    soh.OrderDate,
    COUNT(sod.SalesOrderDetailID) AS ItemCount
FROM
    Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
    ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
    soh.SalesOrderID, soh.OrderDate;
//SQL, P1.3

SELECT
    soh.SalesOrderID AS OrderNumber,
    soh.OrderDate,
    COUNT(sod.SalesOrderDetailID) AS ItemCount
FROM
    Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
    ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
    soh.SalesOrderID, soh.OrderDate;
//SQL, P1.4


SELECT
    p.FirstName,
    COUNT(*) AS EmployeeCount
FROM
    HumanResources.Employee e
JOIN Person.Person p
    ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY
    p.FirstName
ORDER BY
    EmployeeCount DESC;
//SQL, P1.5

SELECT TOP 10
    v.Name AS VendorName,
    MAX(pv.StandardPrice) AS MaxProductPrice
FROM
    Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv
    ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY
    v.Name
ORDER BY
    MaxProductPrice DESC;
