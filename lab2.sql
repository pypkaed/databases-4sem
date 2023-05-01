/* 1 */
SELECT Color, COUNT(*) AS 'Amount'
FROM Production.Product AS p
WHERE p.ListPrice < 30
GROUP BY p.Color

/* 2 */
SELECT Color
FROM Production.Product AS p
GROUP BY p.Color
HAVING MIN(ListPrice) > 100

/* 3 */
SELECT ProductSubcategoryID, COUNT(*) AS 'Product amount'
FROM Production.Product AS p
GROUP BY p.ProductSubcategoryID

/* 4 */
SELECT ProductID, SUM(OrderQty)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY ProductID

/* 5  */
SELECT ProductID, SUM(OrderQty)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(OrderQty) > 5

/* 6 */
SELECT CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, OrderDate
HAVING COUNT(SalesOrderID) > 1

/* 7 */
SELECT SalesOrderID, COUNT(*) AS 'Positions'
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) > 3

/* 8 */
SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 3

/* 9 */
SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) IN (3, 5)

/* 10 */
SELECT ProductSubcategoryID
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID
HAVING COUNT(*)>10

/* 11 */
SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING MAX(OrderQty) = 1
ORDER BY ProductID

/* 12 */
SELECT top 1 SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY COUNT(DISTINCT ProductID) DESC

/* 13 */
SELECT top 1 SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SUM(OrderQty * UnitPrice) DESC

/* 14 */
SELECT ProductSubcategoryID, COUNT(*) AS 'Product amount'
FROM Production.Product AS p
WHERE p.Color IS NOT NULL AND p.ProductSubcategoryID IS NOT NULL
GROUP BY p.ProductSubcategoryID

/* 15 */
SELECT Color, COUNT(*) AS 'Product amount'
FROM Production.Product AS p
GROUP BY p.Color
ORDER BY 'Product amount' DESC

/* 16 */
SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING MIN(OrderQty) > 1 AND COUNT(*) > 2
ORDER BY ProductID

-- task
SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING MAX(OrderQty) < 3 AND COUNT(*) > 3
ORDER BY ProductID