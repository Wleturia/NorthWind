Insert NORTHWIND_MART.dbo.Employee_Dim
(EmployeeID,EmployeeName,HireDate)
Select EmployeeID, LastName, HireDate
From Northwind.dbo.Employees
Where EmployeeID NOT IN 
(Select EmployeeID FROM NORTHWIND_MART.dbo.Employee_Dim)

Insert NORTHWIND_MART.dbo.Customer_Dim
(Region, Country,ContactTitle,Address,City,CustomerID,CompanyNAme,ContactName)
Select Regionpe=ISNULL(Region, 'Otros'), Country,ContactTitle,Address,City,CustomerID,CompanyNAme,ContactName
From Northwind.dbo.Customers
Where CustomerID NOT IN 
(Select CustomerID FROM NORTHWIND_MART.dbo.Customer_Dim)

Insert NORTHWIND_MART.dbo.Product_Dim
(CategoryName,ListUnitPrice,ProductID,ProductName,SupplierName)
Select p.ProductName, s.CompanyName,c.CategoryName, p.ProductID, p.UnitPrice
From  Northwind.dbo.Categories c
INNER JOIN Northwind.dbo.Products p ON c.CategoryID = p.CategoryID
INNER JOIN Northwind.dbo.Suppliers s ON p.SupplierID = s.SupplierID
Where ProductID NOT IN 
(Select ProductID FROM NORTHWIND_MART.dbo.Product_Dim)

Insert NORTHWIND_MART.dbo.Shipper_Dim
(ShipperID,ShipperName)
Select ShipperID,CompanyName
From Northwind.dbo.Shippers
Where ShipperID NOT IN 
(Select ShipperID FROM NORTHWIND_MART.dbo.Shipper_Dim)

INSERT NORTHWIND_MART.dbo.Time_Dim
(TheDate,YearMonth,DayOfWeek,Quarter,DayOfYear,WeekOfYear,Month,Year)
SELECT DISTINCT S.ShippedDate,
DATENAME(MONTH,S.ShippedDate)+' '+
DATENAME (YEAR,S.ShippedDate),
DATEPART (DW,S.ShippedDate),
DATEPART (qq,S.ShippedDate),
DATEPART (dy,S.ShippedDate),
DATEPART (WK,S.ShippedDate),
DATEPART (mm,S.ShippedDate),
DATEPART (yy,S.ShippedDate)
FROM Northwind.dbo.Orders S
WHERE S.ShippedDate IS NOT NULL

SELECT
NORTHWIND_MART.dbo.Time_Dim.TimeKey,
NORTHWIND_MART.dbo.Customer_Dim.CustomerKey,
NORTHWIND_MART.dbo.Shipper_Dim.ShipperKey,
NORTHWIND_MART.dbo.Product_Dim.ProductKey,
NORTHWIND_MART.dbo.Employee_Dim.EmployeeKey,
Northwind.dbo.Orders.RequiredDate,
Orders.Freight*[Order Details].Quantity/
(SELECT SUM (Quantity)
FROM [Order Details] od
WHERE od.OrderID = Orders.OrderID) AS LineItemFreight,
[Order Details].UnitPrice * [Order Details].Quantity AS LineItemTotal,
[Order Details].Quantity AS LineItemQuantity,
[Order Details].Discount * [Order Details].UnitPrice*[Order Details].Quantity AS LineItemDiscount
FROM Orders
INNER JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
INNER JOIN NORTHWIND_MART.dbo.Product_Dim ON [Order Details].ProductID = NORTHWIND_MART.dbo.Product_Dim.ProductID
INNER JOIN NORTHWIND_MART.dbo.Customer_Dim ON Orders.CustomerID= NORTHWIND_MART.dbo.Customer_Dim.CustomerID
INNER JOIN NORTHWIND_MART.dbo.Time_Dim ON Orders.ShippedDate = NORTHWIND_MART.dbo.Time_Dim.TheDate
INNER JOIN NORTHWIND_MART.dbo.Shipper_Dim ON Orders.ShipVia = NORTHWIND_MART.dbo.Shipper_Dim.ShipperID
INNER JOIN NORTHWIND_MART.dbo.Employee_Dim ON Orders.EmployeeID = NORTHWIND_MART.dbo.Employee_Dim.EmployeeID
WHERE (Orders.ShippedDate IS NOT NULL)
