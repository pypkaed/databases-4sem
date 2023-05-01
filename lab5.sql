SELECT t1.ps, t1.c, t2.c
FROM (
    SELECT COUNT(*) AS c, p.ProductSubcategoryID AS ps
    FROM Production.Product AS p
    WHERE p.ListPrice < (
        SELECT AVG(ListPrice)
        FROM Production.Product AS pt
        WHERE pt.ProductSubcategoryID = p.ProductSubcategoryID
        )
    GROUP BY ProductSubcategoryID
     ) AS t1
INNER JOIN (
    SELECT COUNT(*) AS c, ProductSubcategoryID AS ps
    FROM Production.Product AS p
    WHERE p.ListPrice >= (
        SELECT AVG(ListPrice)
        FROM Production.Product AS pt
        WHERE pt.ProductSubcategoryID = p.ProductSubcategoryID
        )
    GROUP BY ProductSubcategoryID
) AS t2
ON t1.ps = t2.ps

WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)
AS (
    SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
    )
SELECT SalesPersonID, COUNT(SalesOrderID) AS 'TotalSales', SalesYear
FROM Sales_CTE
GROUP BY SalesYear, SalesPersonID
ORDER BY SalesPersonID, SalesYear

SELECT tmp.c, COUNT(tmp.ch), COUNT(DISTINCT tmp.ch)
FROM (
    SELECT soh.CustomerID as c,
           soh.SalesOrderID as o,
           CHECKSUM_AGG(sod.ProductID) as ch
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
     ) AS tmp
GROUP BY tmp.c
HAVING COUNT(tmp.ch) = COUNT(DISTINCT tmp.ch)
AND COUNT(tmp.ch) > 1
RETURN

WITH Sales_CTE (CustomerID, SalesOrderID, chProductID)
AS (
    SELECT soh.CustomerID, soh.SalesOrderID, CHECKSUM_AGG(ProductID) AS chProductID
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on soh.SalesOrderID = SOD.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
    )
SELECT CustomerID
FROM Sales_CTE
GROUP BY CustomerID
HAVING COUNT(chProductID) = COUNT(DISTINCT chProductID)
AND COUNT(chProductID) > 1

SELECT DISTINCT TOP 3 t1.c, t2.c
FROM (
    SELECT soh.CustomerID as c,
           sod.ProductID AS p
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on soh.SalesOrderID = SOD.SalesOrderID
     ) AS t1,
    (
    SELECT soh.CustomerID as c,
           sod.ProductID AS p
        FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail SOD
    on soh.SalesOrderID = SOD.SalesOrderID
    ) AS t2
WHERE t1.p != ALL (
    SELECT sod.PRoductID as p
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader Soh
        on Soh.SalesOrderID = sod.SalesOrderID
    WHERE soh.CustomerID = t2.c
    )

WITH popa (ProductSubcategoryID, AvgPrice)
AS (
    SELECT ProductSubcategoryID, AVG(ListPrice) AS AvgPrice
    FROM Production.Product
    GROUP BY ProductSubcategoryID
)
SELECT ProductID
FROM Production.Product AS p
    INNER JOIN popa
    ON p.ProductSubcategoryID = popa.ProductSubcategoryID
WHERE ListPrice > popa.AvgPrice

-- 1: correct

WITH popa (CustomerID, SalesOrderID, CountProducts)
AS (
    SELECT CustomerID, sod.SalesOrderID, COUNT(DISTINCT ProductID) AS CountProducts
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY CustomerID, sod.SalesOrderID
    )
SELECT CustomerID, AVG(CountProducts) AS AverageProductsCount
FROM popa
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
RETURN

-- something

WITH popa (CustomerID, SalesOrderID, ProductID)
AS (
    SELECT CustomerID, sod.SalesOrderID, ProductID
    FROM Sales.SalesOrderHeader AS Soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on Soh.SalesOrderID = SOD.SalesOrderID
    )
SELECT CustomerID,
       ProductID,
       COUNT(DISTINCT ProductID),
       COUNT(*),
       CAST(COUNT(DISTINCT ProductID) AS float) / CAST(COUNT(*) AS float)
FROM popa
GROUP BY CustomerID, ProductID
ORDER BY CustomerID

RETURN

-- 2: correct i think

WITH popa (CustomerID, SalesOrderID, ProductID)
AS (
    SELECT CustomerID, sod.SalesOrderID, ProductID
    FROM Sales.SalesOrderHeader AS Soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on Soh.SalesOrderID = SOD.SalesOrderID
--     GROUP BY CustomerID, sod.SalesOrderID, ProductID
    ),
    pisya (CustomerID, AllBuys)
AS (
    SELECT CustomerID, COUNT(ProductID) AS AllBuys
    FROM Sales.SalesOrderHeader AS soh INNER JOIN Sales.SalesOrderDetail S on soh.SalesOrderID = S.SalesOrderID
    GROUP BY CustomerID
    )
SELECT popa.CustomerID,
       ProductID,
       COUNT(ProductID),
       AllBuys,
       CAST(COUNT(ProductID) AS float) / CAST(AllBuys AS float)
FROM popa INNER JOIN pisya ON popa.CustomerID = pisya.CustomerID
GROUP BY popa.CustomerID, ProductId, AllBuys
ORDER BY CustomerID

RETURN

-- 3: correct I think

WITH pisya (ProductID, SalesCnt)
AS (
    SELECT ProductID, COUNT(SalesOrderID) AS SalesCnt
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
    ),
    popa (ProductID, CustomersCnt)
AS (
    SELECT ProductID, COUNT(DISTINCT CustomerID)
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on soh.SalesOrderID = SOD.SalesOrderID
    GROUP BY ProductID
    )
SELECT popa.ProductID, SalesCnt, CustomersCnt
FROM pisya INNER JOIN popa ON pisya.ProductID = popa.ProductID
ORDER BY ProductID

WITH pisya (ProductID, SalesCnt, CustomersCnt)
AS (
    SELECT ProductID,
           COUNT(sod.SalesOrderID) AS SalesCnt,
           COUNT(DISTINCT CustomerID) AS CustomersCnt
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader SOH
        on SOH.SalesOrderID = sod.SalesOrderID
    GROUP BY ProductID
    )
SELECT ProductID, SalesCnt, CustomersCnt
FROM pisya
ORDER BY ProductID

-- 4: correct

SELECT CustomerID,
       MIN(sod.UnitPrice * sod.OrderQty) AS minPrice,
       MAX(sod.UnitPrice * sod.OrderQty) AS maxPrice
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail SOD
    on soh.SalesOrderID = SOD.SalesOrderID
GROUP BY CustomerID

SELECT CustomerID,
       MIN(sod.LineTotal) AS minPrice,
       MAX(sod.LineTotal) AS maxPrice
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail SOD
    on soh.SalesOrderID = SOD.SalesOrderID
GROUP BY CustomerID
RETURN

-- 5: correct

WITH popa (CustomerID, SalesOrderID, ProductCnt)
AS (
    SELECT CustomerID, sod.SalesOrderID, COUNT(DISTINCT ProductID) AS ProductCnt
    FROM Sales.SalesOrderHeader AS Soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on Soh.SalesOrderID = SOD.SalesOrderID
    GROUP BY CustomerID, sod.SalesOrderID
    )
SELECT DISTINCT CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID NOT IN (
    SELECT DISTINCT popa1.CustomerID
    FROM popa AS popa1
        INNER JOIN popa AS popa2
        ON popa1.CustomerID = popa2.CustomerID
        AND popa1.SalesOrderID != popa2.SalesOrderID
        AND popa1.ProductCnt = popa2.ProductCnt
    )

-- 6: correct?

SELECT CustomerID, sod.SalesOrderID, ProductID
    FROM Sales.SalesOrderHeader AS Soh
        INNER JOIN Sales.SalesOrderDetail SOD
        on Soh.SalesOrderID = SOD.SalesOrderID

WITH popa (CustomerID, ProductID)
AS (
    SELECT
      soh.CustomerID,
      sod.ProductID
    FROM
      Sales.SalesOrderDetail AS sod
    JOIN
      Sales.SalesOrderHeader AS soh
    ON
      sod.SalesOrderID = soh.SalesOrderID
    GROUP BY
        soh.CustomerID, sod.ProductID
    HAVING COUNT(*) > 1
  ),
    pisya (CustomerID)
AS (
    SELECT
        CustomerID
    FROM
        Sales.SalesOrderHeader AS soh
    JOIN
        Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.CustomerID, sod.ProductID
    HAVING COUNT(*) = 1
    )
SELECT DISTINCT
    CustomerID
FROM
    popa
WHERE
    CustomerID NOT IN (SELECT * FROM pisya)
ORDER BY
    CustomerID

-- kakat

WITH popa (CustomerID, SalesOrderCnt)
AS (
    SELECT CustomerID, COUNT(SalesOrderID) AS SalesOrderCnt
    FROM Sales.SalesOrderHeader AS soh
    GROUP BY CustomerID
    ),
    pisya (CustomerID, ProductCnt)
AS (
    SELECT CustomerID, COUNT(ProductID) AS ProductCnt
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail S
        on soh.SalesOrderID = S.SalesOrderID
    GROUP BY CustomerID
    )
SELECT popa.CustomerID, SalesOrderCnt, ProductCnt
FROM popa INNER JOIN pisya ON popa.CustomerID = pisya.CustomerID

-- task

WITH t1 (CustomerID, SubcatCnt)
AS (
    SELECT CustomerID, COUNT(DISTINCT ProductSubcategoryID) AS SubcatCnt
    FROM Sales.SalesOrderHeader
        INNER JOIN Sales.SalesOrderDetail SOD
        on SalesOrderHeader.SalesOrderID = SOD.SalesOrderID
        INNER JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
    GROUP BY CustomerID
    ),
    t2 (CustomerID, SalesCnt, AvgPrice)
AS (
    SELECT CustomerID, COUNT(SalesOrderID) AS SalesCnt, AVG(soh.TotalDue)
    FROM Sales.SalesOrderHeader AS Soh
    GROUP BY CustomerID
    )
SELECT t1.CustomerID, SalesCnt, AvgPrice
FROM t2 INNER JOIN t1 ON t1.CustomerID = t2.CustomerID
WHERE t1.SubcatCnt > (
    SELECT COUNT(*) / 2
    FROM Production.ProductSubcategory
    )