SELECT p.Name
FROM Production.Product AS p
WHERE p.Color = 'Red'
    AND p.ListPrice =
        (SELECT MAX(p.ListPrice)
         FROM Production.Product AS p
         WHERE p.Color = 'Red')

SELECT TOP 1 WITH TIES p.Name
FROM Production.Product AS p
WHERE p.Color = 'Red'
ORDER BY p.ListPrice DESC

SELECT p.Name
FROM Production.Product AS p
WHERE p.Color != 'Red'
    AND p.ListPrice IN
        (SELECT DISTINCT p.ListPrice
         FROM Production.Product AS p
          WHERE p.Color = 'Red'
        )

SELECT p.Name
FROM Production.Product AS p
WHERE p.Color != 'Red'
    AND p.ListPrice = ANY
        (SELECT DISTINCT p.ListPrice
         FROM Production.Product AS p
         WHERE p.Color = 'Red'
        )

SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice > ALL
        (SELECT DISTINCT p.ListPrice
        FROM Production.Product AS p
        WHERE p.Color = 'Red')

SELECT p.Name
FROM Production.Product AS p
WHERE p.Color IN
      (SELECT p.Color
       FROM Production.Product AS p
       WHERE p.ListPrice > 3000)

SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE pc.ProductCategoryID IN
    (SELECT psc.ProductCategoryID
     FROM Production.ProductSubcategory AS psc
     WHERE psc.ProductSubcategoryID IN
        (SELECT p.ProductSubcategoryID
        FROM Production.Product AS p
        WHERE p.ListPrice =
              (SELECT MAX(p.ListPrice)
               FROM Production.Product AS p)))

SELECT p.Name, p.Color, p.Style
FROM Production.Product AS p
WHERE p.Color IN
    (SELECT p.Color
     FROM Production.Product AS p
    WHERE p.ListPrice =
          (SELECT MAX(p.ListPrice)
           FROM Production.Product AS p
           ))
AND p.Style IN
    (SELECT p.Style
     FROM Production.Product AS p
    WHERE p.ListPrice =
          (SELECT MAX(p.ListPrice)
           FROM Production.Product AS p
           ))

-- SELECT psc.Name, COUNT(*)
-- FROM Production.ProductSubcategory AS psc
-- GROUP BY psc.ProductSubcategoryID, psc.Name
-- HAVING COUNT(*) =
--        (SELECT TOP 1 COUNT(*)
--         FROM Production.Product AS p
--         GROUP BY p.ProductSubcategoryID
--         ORDER BY COUNT(*) DESC)

SELECT psc.Name
FROM Production.ProductSubcategory AS psc
WHERE psc.ProductSubcategoryID =
       (SELECT TOP 1 p.ProductSubcategoryID
        FROM Production.Product AS p
        WHERE p.ProductSubcategoryID IS NOT NULL
        GROUP BY p.ProductSubcategoryID
        ORDER BY COUNT(*) DESC)

SELECT p1.Name, p1.ProductSubcategoryID
FROM Production.Product AS p1
WHERE p1.ListPrice =
      (SELECT MAX(p2.ListPrice)
       FROM Production.Product AS p2
       WHERE p1.ProductSubcategoryID = p2.ProductSubcategoryID)

SELECT p.Name,
       (SELECT psc.Name AS 'Product subcategory'
        FROM Production.ProductSubcategory AS psc
        WHERE p.ProductSubcategoryID = psc.ProductSubcategoryID)
FROM Production.Product AS p

SELECT so.CustomerID, COUNT(*)
FROM Sales.SalesOrderHeader AS so
GROUP BY so.CustomerID
HAVING COUNT(*) > 1 AND COUNT(*) = ALL (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS so2
        INNER JOIN Sales.SalesOrderDetail AS sod
        ON so2.SalesOrderID = sod.SalesOrderID
    WHERE so2.CustomerID = so.CustomerID
    GROUP BY so2.CustomerID, sod.ProductID
    )

SELECT p.Name,
       (SELECT COUNT(DISTINCT soh.CustomerID)
        FROM Sales.SalesOrderDetail AS sod
            INNER JOIN Sales.SalesOrderHeader soh
            ON soh.SalesOrderID = sod.SalesOrderID
        WHERE sod.ProductID = p.ProductID),
        (SELECT COUNT(DISTINCT soh.CustomerID)
         FROM Sales.SalesOrderDetail AS sod
            INNER JOIN Sales.SalesOrderHeader soh
            ON soh.SalesOrderID = sod.SalesOrderID
         WHERE soh.CustomerID NOT IN (
                SELECT DISTINCT soh.CustomerID
                FROM Sales.SalesOrderDetail AS sod
                    INNER JOIN Sales.SalesOrderHeader soh
                    ON soh.SalesOrderID = sod.SalesOrderID
                WHERE sod.ProductID = p.ProductID
             ))
FROM Production.Product AS p

SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductSubcategoryID IS NOT NULL
AND p.ProductID IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader soh
        ON soh.SalesOrderID = sod.SalesOrderID
    WHERE soh.CustomerID IN (
        SELECT soh.CustomerID
        FROM Sales.SalesOrderDetail AS sod
            INNER JOIN Sales.SalesOrderHeader soh
            ON soh.SalesOrderID = sod.SalesOrderID
                INNER JOIN Production.Product AS p
                ON sod.ProductID = p.ProductID
        GROUP BY soh.CustomerID
        HAVING COUNT(DISTINCT p.ProductSubcategoryID) = 1
        )
    GROUP BY sod.ProductID
    HAVING COUNT(DISTINCT soh.CustomerID) > 1
    )

-- SELECT DISTINCT so.CustomerID
-- FROM Sales.SalesOrderHeader AS so
-- WHERE so.CustomerID NOT IN (
--     SELECT soh.CustomerID
--     FROM Sales.SalesOrderHeader AS soh
--         INNER JOIN Sales.SalesOrderDetail SOD
--         ON soh.SalesOrderID = SOD.SalesOrderID
--     WHERE EXISTS (
--         SELECT sod1.ProductID
--         FROM Sales.SalesOrderDetail AS sod1
--             INNER JOIN Sales.SalesOrderHeader AS soh1
--             ON sod1.SalesOrderID = soh1.SalesOrderID
--         WHERE soh1.CustomerID = soh.CustomerID
--             AND sod1.ProductID = sod.ProductID
--             AND sod.SalesOrderID != sod1.SalesOrderID
--               )
--     )

SELECT DISTINCT CustomerID
FROM [Sales].[SalesORDERHeader]
WHERE CustomerID NOT IN (
SELECT soh.Customerid
FROM [Sales].[SalesORDERDetail] AS sod JOIN
[Sales].[SalesORDERHeader] AS soh
ON sod.SalesORDERID=soh.SalesORDERID
WHERE
exists(SELECT ProductID
FROM [Sales].[SalesORDERDetail] AS sod1 JOIN
[Sales].[SalesORDERHeader] AS soh1
ON sod.SalesORDERID=soh.SalesORDERID
WHERE soh1.CustomerID=soh.CustomerID AND
sod1.ProductID=sod.ProductID AND
sod.SalesORDERID!=sod1.SalesORDERID
))

-- SELECT soh.CustomerID
-- FROM Sales.SalesOrderHeader AS soh
--     INNER JOIN Sales.SalesOrderDetail SOD
--     on soh.SalesOrderID = SOD.SalesOrderID
-- GROUP BY soh.CustomerID
-- HAVING COUNT(DISTINCT sod.ProductID) = (
--     SELECT COUNT(DISTINCT sod1.ProductID)
--     FROM Sales.SalesOrderDetail AS sod1
--         INNER JOIN Sales.SalesOrderHeader AS soh1
--         ON soh1.SalesOrderID = sod1.SalesOrderID
--     WHERE soh.CustomerID = soh1.CustomerID
--     AND sod1.ProductID IN (
--         SELECT sod2.ProductID
--         FROM Sales.SalesOrderDetail AS sod2
--             INNER JOIN Sales.SalesOrderHeader AS soh2
--             ON soh2.SalesOrderID = sod2.SalesOrderID
--         GROUP BY sod2.ProductID
--         HAVING COUNT(DISTINCT soh1.CustomerID) = 1
--         )
--     )

SELECT soh1.CustomerID
FROM[Sales].[SalesORDERDetail] AS sod1 INner JOIN
[Sales].[SalesORDERHeader] AS soh1
ON sod1.SalesORDERID=soh1.SalesORDERID
GROUP BY soh1.CustomerID
HAVING count(DISTINCT sod1.productid)=
(SELECT count(DISTINCT sod.ProductID)
FROM [Sales].[SalesORDERDetail] AS sod INner JOIN
[Sales].[SalesORDERHeader] AS soh
ON sod.SalesORDERID=soh.SalesORDERID
WHERE soh.CustomerID=soh1.CustomerID
AND sod.ProductID IN
(SELECT sod.ProductID
FROM[Sales].[SalesORDERDetail] AS sod INner JOIN
[Sales].[SalesORDERHeader] AS soh
ON sod.SalesORDERID=soh.SalesORDERID
GROUP BY sod.ProductID
HAVING count(DISTINCT soh.CustomerID)=1))

SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
WHERE soh.CustomerID NOT IN (
    SELECT DISTINCT soh.CustomerID
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail SOD
        ON soh.SalesOrderID = SOD.SalesOrderID
    WHERE sod.ProductID NOT IN (
        SELECT sod.ProductID
        FROM Sales.SalesOrderDetail AS sod
            INNER JOIN Sales.SalesOrderHeader S
            ON S.SalesOrderID = sod.SalesOrderID
        GROUP BY sod.ProductID
        HAVING COUNT(DISTINCT s.CustomerID) = 1
        )
    )

-- homework

-- 1
SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID = (
    SELECT TOP 1 sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.ProductID
    ORDER BY COUNT(*) DESC
    )

-- 2

SELECT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail SOD
    ON soh.SalesOrderID = SOD.SalesOrderID
WHERE sod.OrderQty * sod.UnitPrice = (
    SELECT MAX(sod.OrderQty * sod.UnitPrice)
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail SOD
    ON soh.SalesOrderID = SOD.SalesOrderID
    )

-- 3

SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Sales.SalesOrderHeader SOh
    ON soh.SalesOrderID = SOD.SalesOrderID
GROUP BY sod.ProductID
HAVING COUNT(DISTINCT soh.CustomerID) = 1

-- or
SELECT TOP 1 p.Name
FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
        INNER JOIN Sales.SalesOrderHeader SOH
        ON SOH.SalesOrderID = sod.SalesOrderID
GROUP BY p.Name
HAVING COUNT(soh.CustomerID) = 1

-- 4

SELECT p.Name, p.ProductSubcategoryID
FROM Production.Product AS p
WHERE p.ProductSubcategoryID IS NOT NULL
AND p.ListPrice > (
    SELECT AVG(p2.ListPrice)
    FROM Production.Product AS p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
    )

-- 5 (?)

SELECT p.Name
FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
        INNER JOIN Sales.SalesOrderHeader SOH
        ON SOH.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID IN (
    SELECT soh.CustomerID
    FROM Sales.SalesOrderHeader AS soh
        INNER JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
            INNER JOIN Production.Product AS p
            ON p.ProductID = sod.ProductID
    GROUP BY soh.CustomerID
    HAVING COUNT(DISTINCT p.Color) = 1 -- and count(distinct p.color) != 2
    )
GROUP BY p.Name
HAVING COUNT(soh.CustomerID) > 1



-- 6
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod


-- 7 (false?)
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
WHERE EXISTS(
    SELECT sod2.ProductID
    FROM Sales.SalesOrderDetail AS sod2
        INNER JOIN Sales.SalesOrderHeader soh2
        ON soh2.SalesOrderID = sod2.SalesOrderID
    WHERE
        soh2.CustomerID = soh.CustomerID
    AND sod.ProductID = sod2.ProductID
    AND sod.SalesOrderID != sod2.SalesOrderID
          )

-- 8

SELECT p.Name
FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
        INNER JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY p.Name
HAVING COUNT(DISTINCT soh.CustomerID) IN (
    SELECT soh2.CustomerID
    FROM Sales.SalesOrderHeader AS soh2
    GROUP BY soh2.CustomerID
    HAVING COUNT(*) <= 3
    )

--  9 :(

-- SELECT p.Name
-- FROM Production.Product AS p
--     INNER JOIN Sales.SalesOrderDetail AS sod
--     ON p.ProductID = sod.ProductID
-- WHERE sod.SalesOrderID IN (
    -- find sales that contain max priced product
    SELECT DISTINCT sod2.SalesOrderID, p2.Name
    FROM Sales.SalesOrderDetail AS sod2
        INNER JOIN Production.Product AS p2
        ON p2.ProductID = sod2.ProductID
    WHERE p2.Name IN (
        -- find max priced product
        SELECT p.Name
        FROM Production.Product AS p
        WHERE p.ListPrice IN (
            SELECT MAX(p.ListPrice)
            FROM Production.Product AS p
                INNER JOIN Production.ProductSubcategory AS ps
                ON p.ProductSubcategoryID = ps.ProductSubcategoryID
                    INNER JOIN Production.ProductCategory AS pc
                    ON ps.ProductCategoryID = pc.ProductCategoryID
            GROUP BY pc.ProductCategoryID
            )
        )
--     )

SELECT sod.SalesOrderID, COUNT(sod.ProductID)
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID

    -- find sales that contain max priced product
    SELECT DISTINCT sod2.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod2
    WHERE sod2.ProductID IN (
            -- find max priced product
            SELECT p.ProductID
            FROM Production.Product AS p
            WHERE p.ListPrice IN (
                SELECT MAX(p2.ListPrice)
                FROM Production.Product AS p2
                    INNER JOIN Production.ProductSubcategory AS ps
                    ON p2.ProductSubcategoryID = ps.ProductSubcategoryID
                        INNER JOIN Production.ProductCategory AS pc
                        ON ps.ProductCategoryID = pc.ProductCategoryID
                GROUP BY pc.ProductCategoryID
                )
            )

--
SELECT p.Name, p.ProductID
FROM Production.Product AS p
WHERE p.Color IN (
    SELECT DISTINCT Color
    FROM Production.Product
    WHERE p.ListPrice < 5000
    )

--
SELECT p.Name, p.ProductID
FROM Production.Product AS p
WHERE p.Color = (
    SELECT TOP 1 Color
    FROM Production.Product
    WHERE Color IS NOT NULL
    ORDER BY ListPrice DESC
    )

SELECT p.Name, p.ProductID
FROM Production.Product AS p
WHERE p.Color IN (
    SELECT Color
    FROM Production.Product
    WHERE ListPrice = (
        SELECT MAX(ListPrice)
        FROM Production.Product
        )
    )
--
SELECT p.Name
FROM Production.Product AS p
WHERE p.Color IN ( -- or = ANY
    SELECT p2.Color
    FROM Production.Product AS p2
    WHERE p2.ListPrice < 4000
    )
--
SELECT ps.Name
FROM Production.ProductSubcategory AS ps
WHERE ps.ProductSubcategoryID = (
    SELECT TOP 1 p.ProductSubcategoryID
    FROM Production.Product AS p
    WHERE p.Color = 'Red'
    ORDER BY p.ListPrice
    )
--
SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE pc.ProductCategoryID IN (
    SELECT ps.ProductCategoryID
    FROM Production.ProductSubcategory AS ps
    WHERE ps.ProductSubcategoryID IN (
        SELECT TOP 1 p.ProductSubcategoryID
        FROM Production.Product AS p
        WHERE p.ProductSubcategoryID IS NOT NULL
        GROUP BY p.ProductSubcategoryID
        ORDER BY COUNT(DISTINCT p.ProductID)
        )
    )
--
SELECT p.Name
FROM Production.Product AS p
WHERE p.Color = ANY (
    SELECT DISTINCT p2.Color
    FROM Production.Product AS p2
    WHERE p2.Color IS NOT NULL
    AND p2.ListPrice > 2000
    )
--
SELECT DISTINCT soh.CustomerID,
       (SELECT TOP 1 p.Name
        FROM Production.Product AS p
        WHERE p.ProductID IN (
            SELECT sod.ProductID
            FROM Sales.SalesOrderDetail AS sod
            WHERE sod.SalesOrderID IN (
                SELECT soh2.SalesOrderID
                FROM Sales.SalesOrderHeader AS soh2
                WHERE soh2.CustomerID = soh.CustomerID
                )
            )
        ORDER BY p.ListPrice DESC)
FROM Sales.SalesOrderHeader AS soh

--
SELECT DISTINCT pc.Name,
        (SELECT TOP 1 p.Name
         FROM Production.Product AS p
         WHERE p.ProductSubcategoryID IS NOT NULL
         AND p.Color = 'Red'
         AND p.ProductSubcategoryID IN (
             SELECT ps.ProductSubcategoryID
             FROM Production.ProductSubcategory AS ps
             WHERE ps.ProductCategoryID IN (
                 SELECT pc2.ProductCategoryID
                 FROM Production.ProductCategory AS pc2
                 WHERE pc.Name = pc2.Name
                 ))
         ORDER BY p.ListPrice DESC)
FROM Production.ProductCategory AS pc
--
SELECT soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
WHERE soh.CustomerID IN (
    SELECT DISTINCT soh2.CustomerID
    FROM Sales.SalesOrderHeader AS soh2
    GROUP BY soh2.CustomerID
    HAVING COUNT(*) > 3
    )
--

SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE (
    (SELECT COUNT(p.ProductID)
    FROM Production.Product AS p
        INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    WHERE p.Color = 'Red'
    AND ps.ProductCategoryID = pc.ProductCategoryID
    )
    > (
    SELECT COUNT(p.ProductID)
    FROM Production.Product AS p
        INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    WHERE p.Color = 'Black'
    AND ps.ProductCategoryID = pc.ProductCategoryID
    )
)
--
SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE pc.ProductCategoryID IN (
    SELECT ps.ProductCategoryID
    FROM Production.ProductSubcategory AS ps
    WHERE ps.ProductSubcategoryID = (
        SELECT p.ProductSubcategoryID
        FROM Production.Product AS p
        WHERE p.ProductID IN (
            SELECT TOP 1 sod.ProductID
            FROM Sales.SalesOrderDetail AS sod
            GROUP BY sod.ProductID
            ORDER BY COUNT(*) DESC
            )
        )
    )

--

SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.SalesOrderID IN (
        SELECT soh.SalesOrderID
        FROM Sales.SalesOrderHeader AS soh
        WHERE soh.CustomerID IN (
            SELECT soh2.CustomerID
            FROM Sales.SalesOrderHeader AS soh2
            GROUP BY soh2.CustomerID
            HAVING COUNT(*) > 3
            )
        )
    GROUP BY sod.ProductID
    HAVING COUNT(*) > 3
    )

SELECT p1.name
FROM
Production.Product as p1
WHERE p1.ProductID IN (
    SELECT sod.ProductID
    FROM Sales.SalesOrderDetail as sod
        INNER JOIN Sales.SalesOrderHeader as soh
        ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY sod.ProductID
    HAVING COUNT(DISTINCT soh.SalesOrderID) > 3 AND COUNT(DISTINCT soh.CustomerID) > 3
    )

--
SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE pc.ProductCategoryID IN (
    SELECT ps.ProductCategoryID
    FROM Production.ProductSubcategory AS ps
    WHERE ps.ProductSubcategoryID = (
        SELECT TOP 1 p.ProductSubcategoryID
        FROM Production.Product AS p
        WHERE p.ProductSubcategoryID IS NOT NULL
        GROUP BY p.ProductSubcategoryID
        ORDER BY COUNT(DISTINCT p.ProductID) DESC
        )
    )

--
SELECT sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
GROUP BY sod.SalesOrderID
HAVING COUNT(DISTINCT p.ProductSubcategoryID) > 2

--

select distinct CustomerID
from Sales.SalesOrderHeader
where CustomerID in
      (select soh1.CustomerID
       from Sales.SalesOrderHeader as SOH1
           join Sales.SalesOrderDetail as SOD1
           on SOH1.SalesOrderID = SOD1.SalesOrderID
               join Production.Product as p
               on SOD1.ProductID = p.ProductID
       group by SOH1.CustomerID
       having count (p.ProductSubcategoryID) >= 2
       )

--

SELECT soh.CustomerID, soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
WHERE SalesOrderID in (
    SELECT TOP 1 soh2.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader as soh2
        ON sod.SalesOrderID = soh2.SalesOrderID
    WHERE soh.CustomerID = soh2.CustomerID
    GROUP BY CustomerID, soh2.SalesOrderID
    order by count(soh2.SalesOrderID) desc
    )
order by soh.CustomerID
--

SELECT soh.CustomerID, soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
WHERE SalesOrderID in (
    SELECT TOP 1 soh2.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Sales.SalesOrderHeader AS soh2
        ON sod.SalesOrderID = soh2.SalesOrderID
            INNER JOIN Production.Product AS p
            ON p.ProductID = sod.ProductID
    WHERE soh.CustomerID = soh2.CustomerID
    GROUP BY CustomerID, soh2.SalesOrderID
    ORDER BY count(p.Name) DESC
    )
ORDER BY soh.CustomerID

--

SELECT p.Name, p.ProductSubcategoryID
FROM Production.Product AS p
WHERE p.ProductSubcategoryID IS NOT NULL
AND p.ListPrice > (
    SELECT AVG(p2.ListPrice)
    FROM Production.Product AS p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
    )

-- 7
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
WHERE EXISTS(
    SELECT sod2.ProductID
    FROM Sales.SalesOrderDetail AS sod2
        INNER JOIN Sales.SalesOrderHeader soh2
        ON soh2.SalesOrderID = sod2.SalesOrderID
    WHERE soh2.CustomerID = soh.CustomerID
    AND sod.ProductID = sod2.ProductID
    AND sod.SalesOrderID != sod2.SalesOrderID
    )


-- task

SELECT pc.Name
FROM Production.ProductCategory AS pc
WHERE pc.ProductCategoryID IN (
    SELECT ps.ProductCategoryID
    FROM Production.ProductSubcategory AS ps
        INNER JOIN Production.Product AS p
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
    WHERE p.ProductID IN (
        SELECT TOP 1 sod.ProductID
        FROM Sales.SalesOrderDetail AS sod
        GROUP BY sod.ProductID
        ORDER BY COUNT(*) DESC
        )
    )