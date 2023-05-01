/* 1 */
SELECT Name, Color, Size
FROM Production.Product

/* 2 */
SELECT Name, Color, Size
FROM Production.Product as p
WHERE p.ListPrice>100

/* 3 */
SELECT Name, Color, Size
FROM Production.Product as p
WHERE p.ListPrice<100 AND p.Color='Black'

/* 4 */
SELECT Name, Color, Size
FROM Production.Product as p
WHERE p.ListPrice<100 AND p.Color='Black'
ORDER BY p.ListPrice ASC

/* 5 */
SELECT TOP 3 Name, Size
FROM Production.Product as p
WHERE p.Color='Black'
ORDER BY p.ListPrice DESC

/* 6 */
SELECT Name, Color
FROM Production.Product as p
WHERE p.Color IS NOT NULL AND p.Size IS NOT NULL

/* 7 */
SELECT DISTINCT Color
FROM Production.Product as p
WHERE p.ListPrice BETWEEN 10 AND 50

/* 8 */
SELECT Color
FROM Production.Product as p
WHERE p.Name LIKE 'L_N%'

/* 9 */
SELECT Name
FROM Production.Product as p
WHERE p.Name LIKE '[DM]___%'

/* 10 */
SELECT Name
FROM Production.Product as p
WHERE DATEPART(year, p.SellStartDate)<=2012

/* 11 */
SELECT Name
FROM Production.ProductSubcategory

/* 12 */
SELECT Name
FROM Production.ProductCategory

/* 13 */
SELECT FirstName, MiddleName, LastName
FROM Person.Person as p
WHERE p.Title='Mr.'

/* 14 */
SELECT FirstName, MiddleName, LastName
FROM Person.Person as p
WHERE p.Title IS NULL

-- task
SELECT Name
FROM Production.ProductSubcategory
WHERE ProductSubcategoryID IN (1,3,5)