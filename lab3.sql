SELECT p.Name, ps.Name
FROM Production.Product AS p INNER JOIN
    Production.ProductSubcategory AS ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.ListPrice > 100

SELECT p.Name, ps.Name
FROM Production.Product AS p LEFT JOIN
    Production.ProductSubcategory AS ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.ListPrice > 100

SELECT p.Name, pc.Name
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID

SELECT p.Name, p.ListPrice, pv.LastReceiptCost
FROM Production.Product AS p
    INNER JOIN Purchasing.ProductVendor AS pv
        ON p.ProductID = pv.ProductID

SELECT p.Name, p.ListPrice, pv.LastReceiptCost
FROM Production.Product AS p
    INNER JOIN Purchasing.ProductVendor AS pv
        ON p.ProductID = pv.ProductID
WHERE p.ListPrice != 0 AND p.ListPrice < pv.LastReceiptCost

SELECT COUNT(DISTINCT pv.ProductID) AS 'Products count'
FROM Purchasing.Vendor AS v
    INNER JOIN Purchasing.ProductVendor AS pv
        ON v.BusinessEntityID = pv.BusinessEntityID
WHERE v.CreditRating = 1

SELECT v.CreditRating, COUNT(DISTINCT pv.ProductID) AS 'Products count for this rating'
FROM Purchasing.Vendor AS v
    INNER JOIN Purchasing.ProductVendor AS pv
        ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY v.CreditRating

SELECT TOP 3 ps.ProductSubcategoryID
FROM Production.ProductSubcategory AS ps
    INNER JOIN Production.Product AS p
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY ps.ProductSubcategoryID
ORDER BY COUNT(DISTINCT p.ProductID) DESC

SELECT TOP 3 ps.Name
FROM Production.ProductSubcategory AS ps
    INNER JOIN Production.Product AS p
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY ps.ProductSubcategoryID, ps.Name
ORDER BY COUNT(DISTINCT p.ProductID) DESC

SELECT 1.0 * COUNT(*) / COUNT(DISTINCT ps.ProductSubcategoryID)
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID

SELECT COUNT(*) / COUNT(DISTINCT pc.ProductCategoryID)
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID

SELECT pc.ProductCategoryID, COUNT(DISTINCT p.Color)
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.Color IS NOT NULL
GROUP BY pc.ProductCategoryID

SELECT AVG(ISNULL(p.[Weight], 10))
FROM Production.Product AS p

SELECT p.Name, DATEDIFF(D, p.SellStartDate, ISNULL(p.SellEndDate, GETDATE())) AS 'Active sell dates'
FROM Production.Product AS p

SELECT LEN(p.Name) AS 'name length', COUNT(*) AS 'products count'
FROM Production.Product AS p
GROUP BY LEN(p.Name)

SELECT pv.BusinessEntityID, COUNT(DISTINCT p.ProductSubcategoryID) AS 'product subcategories count'
FROM Purchasing.ProductVendor AS pv
    INNER JOIN Production.Product AS p
        ON pv.ProductID = p.ProductID
WHERE p.ProductSubcategoryID IS NOT NULL
GROUP BY pv.BusinessEntityID

SELECT p.Name
FROM Production.Product AS p
GROUP BY p.ProductID, p.Name
HAVING COUNT(*) > 1

SELECT p1.Name
FROM Production.Product AS p1,
     Production.Product AS p2
WHERE p1.ProductID != p2.ProductID AND p1.Name = p2.Name

SELECT TOP 10 WITH TIES p.Name
FROM Production.Product AS p
ORDER BY p.ListPrice DESC

SELECT TOP 10 PERCENT WITH TIES p.Name
FROM Production.Product AS p
ORDER BY p.ListPrice DESC

SELECT TOP 3 WITH TIES pv.BusinessEntityID
FROM Purchasing.ProductVendor AS pv
    INNER JOIN Production.Product AS p
        ON pv.ProductID = p.ProductID
GROUP BY pv.BusinessEntityID
ORDER BY COUNT(DISTINCT p.ProductID) DESC

-- lab

-- 1
SELECT p.Name, p.Color, p.ListPrice, pc.Name
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.Color = 'Red' AND p.ListPrice >= 100

-- 2

SELECT ps1.Name
FROM Production.ProductSubcategory AS ps1,
     Production.ProductSubcategory AS ps2
WHERE ps1.Name = ps2.Name AND ps1.ProductSubcategoryID != ps2.ProductSubcategoryID

-- 3

SELECT pc.Name, COUNT(DISTINCT p.ProductID) AS 'products quantity'
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name

-- 4

SELECT pc.Name, COUNT(DISTINCT p.ProductID) AS 'products quantity'
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name

-- 5

SELECT TOP 3 ps.Name
FROM Production.ProductSubcategory AS ps
    INNER JOIN Production.Product AS p
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY ps.Name
ORDER BY COUNT(DISTINCT p.ProductID) DESC

-- 6

SELECT pc.Name, MAX(p.ListPrice) AS 'max price for red product'
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.Color = 'Red'
GROUP BY pc.ProductCategoryID, pc.Name

-- 7

SELECT pv.BusinessEntityID, COUNT(DISTINCT p.ProductID)
FROM Purchasing.ProductVendor AS pv
    INNER JOIN Production.Product AS p
        ON pv.ProductID = p.ProductID
GROUP BY pv.BusinessEntityID

-- 8

SELECT p.Name, COUNT(DISTINCT pv.BusinessEntityID)
FROM Purchasing.ProductVendor AS pv
    INNER JOIN Production.Product AS p
        ON pv.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(DISTINCT pv.BusinessEntityID) > 1

-- 9

SELECT TOP 1 p.Name, COUNT(DISTINCT pv.BusinessEntityID)
FROM Production.Product AS p
    INNER JOIN Purchasing.ProductVendor AS pv
        ON p.ProductID = pv.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY COUNT(DISTINCT pv.BusinessEntityID) DESC

-- 10

SELECT TOP 1 pc.Name, COUNT(DISTINCT pv.BusinessEntityID)
FROM Production.ProductCategory AS pc
    INNER JOIN Production.ProductSubcategory PS
        on pc.ProductCategoryID = PS.ProductCategoryID
    INNER JOIN Production.Product P
        on PS.ProductSubcategoryID = P.ProductSubcategoryID
    INNER JOIN Purchasing.ProductVendor AS pv
        ON P.ProductID = pv.ProductID
GROUP BY pc.ProductCategoryID, pc.Name
ORDER BY COUNT(DISTINCT pv.BusinessEntityID) DESC

-- 11

SELECT pc.Name,
       COUNT(DISTINCT ps.ProductSubcategoryID) AS 'product subcategories',
       COUNT(DISTINCT p.ProductID) AS 'product quantity'
FROM Production.ProductCategory AS pc
    INNER JOIN Production.ProductSubcategory PS
        on pc.ProductCategoryID = PS.ProductCategoryID
    INNER JOIN Production.Product P
        on PS.ProductSubcategoryID = P.ProductSubcategoryID
    INNER JOIN Purchasing.ProductVendor AS pv
        ON P.ProductID = pv.ProductID
GROUP BY pc.ProductCategoryID, pc.Name

-- 12

SELECT v.CreditRating, COUNT(DISTINCT p.ProductID) AS 'product quantity'
FROM Purchasing.ProductVendor AS pv
    INNER JOIN Purchasing.Vendor AS v
        on V.BusinessEntityID = pv.BusinessEntityID
    INNER JOIN Production.Product AS p
        ON pv.ProductID = p.ProductID
GROUP BY v.CreditRating

-- task

SELECT pc.Name
FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name
HAVING COUNT(DISTINCT p.ProductID) > 20WHERE