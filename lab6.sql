SELECT SalesOrderID, ProductID, OrderQty,
SUM(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS Total,
AVG(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS "Avg",
COUNT(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS "Count",
MIN(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS "Min",
MAX(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS "Max"
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN (43659, 43664)

SELECT SalesOrderID, ProductID, OrderQty,
SUM(OrderQty)
    OVER (PARTITION BY SalesOrderID) AS "Total",
CAST(1. * OrderQty / SUM(OrderQty)
    OVER (PARTITION BY SalesOrderID) * 100 AS decimal(5,2)) AS "Percent by ProductID"
FROM Sales.salesOrderDetail
WHERE SalesOrderID IN (43659, 43664)

SELECT BusinessEntityID, TerritoryID,
CONVERT(varchar(20), SalesYTD, 1) AS "SalesYTD",
DATEPART(YY, ModifiedDate) AS "SalesYear",
CONVERT(varchar(20), SUM(SalesYTD)
                        OVER (PARTITION BY TerritoryID
                              ORDER BY DATEPART(YY, ModifiedDate)
                              ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING),
        1) AS "CumulativeTotal"
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5

SELECT Name, ListPrice,
FIRST_VALUE(Name)
    OVER (ORDER BY ListPrice) AS "LeastExpensive"
FROM Production.Product
WHERE ProductSubcategoryID = 37

SELECT ProductSubcategoryID, Name, ListPrice,
FIRST_VALUE(Name)
    OVER (PARTITION BY ProductSubcategoryID
            ORDER BY ListPrice) AS "LeastExpensive"
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL

SELECT Department, LastName, Rate, HireDate,
LAST_VALUE(HireDate)
    OVER (PARTITION BY Department ORDER BY Rate) AS "LastValue"
FROM HumanResources.vEmployeeDepartmentHistory AS edh
    INNER JOIN HumanResources.EmployeePayHistory AS eph
    ON edh.BusinessEntityID = eph.BusinessEntityID
        INNER JOIN HumanResources.Employee AS e
        ON e.BusinessEntityID = edh.BusinessEntityID
WHERE Department IN (N'Information Services', N'Document Control')

SELECT BusinessEntityID,
YEAR(QuotaDate) AS "SalesYear",
SalesQuota AS "CurrentQuota",
LAG(SalesQuota, 1, 0)
    OVER (ORDER BY YEAR(QuotaDate)) AS "PreviousQuota"
FROM Sales.SalesPersonQuotaHistory
WHERE BusinessEntityID = 275
    AND YEAR(QuotaDate) IN ('2011', '2012')

SELECT BusinessEntityID,
YEAR(QuotaDate) AS "SalesYear",
SalesQuota AS "CurrentQuota",
LEAD(SalesQuota, 1, 0)
    OVER (ORDER BY YEAR(QuotaDate)) AS "NextQuota"
FROM Sales.SalesPersonQuotaHistory
WHERE BusinessEntityID = 275
    AND YEAR(QuotaDate) IN ('2011', '2012')

SELECT p.FirstName, p.LastName,
ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number",
NTILE(4) OVER (ORDER BY a.PostalCode) AS "Quartile",
s.SalesYTD,
a.PostalCode
FROM Sales.SalesPerson AS s
    INNER JOIN Person.Person AS p
    ON s.BusinessEntityID = p.BusinessEntityID
        INNER JOIN Person.Address AS a
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL AND SalesYTD != 0

-- false

SELECT CustomerID,
       p.ProductID,
       ProductSubcategoryID,
       OrderQty * UnitPrice,
       OrderQty * UnitPrice / SUM(OrderQty * UnitPrice)
            OVER (PARTITION BY sod.SalesOrderID, ProductSubcategoryID)
FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Sales.SalesOrderHeader SOH
    on SOH.SalesOrderID = sod.SalesOrderID
        INNER JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
ORDER BY CustomerID

SELECT soh.SalesOrderID,
       sod.LineTotal AS "Check price",
       LEAD(sod.LineTotal, 1, 0)
           OVER (PARTITION BY soh.SalesOrderID ORDER BY sod.SalesOrderID) AS "Next payment",
       ABS(sod.LineTotal - LEAD(sod.LineTotal, 1, 0)
           OVER (PARTITION BY soh.SalesOrderID ORDER BY sod.SalesOrderID)) AS "Difference"
FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Sales.SalesOrderHeader SOH
    ON SOH.SalesOrderID = sod.SalesOrderID
WHERE CustomerID = 11018

WITH popa (CustomerID, OrderID, Total)
AS (
    SELECT soh.CustomerID,
           soh.SalesOrderID,
           SUM(sod.OrderQty * UnitPrice) AS Total
    FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Sales.SalesOrderHeader SOH
    ON SOH.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
    )
SELECT CustomerID, OrderID, Total,
       Total - LEAD(Total, 1, 0)
                OVER (PARTITION BY CustomerID ORDER BY OrderID)
FROM popa
RETURN

WITH popa (CustomerID, SalesOrderID, Total)
AS (
    SELECT soh.CustomerID,
           soh.SalesOrderID,
           SUM(OrderQty * UnitPrice) AS Total
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on soh.SalesOrderID = SOD.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
    )
SELECT CustomerID,
        SalesOrderID,
        Total,
        SUM(Total) OVER (PARTITION BY CustomerID
                        ORDER BY SalesOrderID DESC
                        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
                                        AS "Accumulative Sum"
FROM popa
RETURN

-- 1: looks nice

WITH popa (SalesOrderID, ProductID, Price)
AS (
    SELECT SalesOrderID,
           ProductID,
           UnitPrice * OrderQty AS Price
    FROM Sales.SalesOrderDetail
)
SELECT SalesOrderID, ProductID,
       Price,
       SUM(Price) OVER (PARTITION BY SalesOrderID
                        ORDER BY SalesOrderID
                        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
                    AS "TotalPrice",
       CAST(Price / SUM(Price) OVER (PARTITION BY SalesOrderID
                        ORDER BY SalesOrderID
                        RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
           AS decimal(5,3)) AS "Relation"
FROM popa
RETURN

-- 2: sounds good

SELECT ProductSubcategoryID,
       ProductID,
       ListPrice,
       MIN(ListPrice)
                    OVER (PARTITION BY ProductSubcategoryID),
       ListPrice - MIN(ListPrice)
                    OVER (PARTITION BY ProductSubcategoryID) AS "Difference"
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
RETURN

-- 3: too easy??

SELECT
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY SalesOrderID),
    CustomerID,
    SalesOrderID
FROM Sales.SalesOrderHeader

-- 4: idk how to use over in this one

SELECT
    ProductID,
    ListPrice
FROM Production.Product AS p1
WHERE ListPrice > (
        SELECT AVG(ListPrice)
        FROM Production.Product AS p2
        WHERE p1.ProductSubcategoryID = p2.ProductSubcategoryID
        GROUP BY p2.ProductSubcategoryID
    )

-- 5: sounds ok-ish?

SELECT DISTINCT ProductID,
       AVG(OrderQty) OVER (PARTITION BY ProductID
                            ORDER BY SalesOrderID DESC
                            ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING)
FROM Sales.SalesOrderDetail AS sod
WHERE
    SalesOrderID IN (
        SELECT TOP 3 SalesOrderID
        FROM Sales.SalesOrderDetail AS sod2
        WHERE sod.ProductID = sod2.ProductID
        ORDER BY SalesOrderID DESC
    )
ORDER BY ProductID

SELECT DISTINCT ProductID, SalesOrderID,
       OrderQty
FROM Sales.SalesOrderDetail AS sod
ORDER BY ProductID, SalesOrderID DESC

-- task

SELECT p.Name, ps.Name,
       COUNT(ProductID) OVER (PARTITION BY ps.ProductSubcategoryID)
            AS 'ProductsCount'
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID

-- task2

