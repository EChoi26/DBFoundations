--*************************************************************************--
-- Title: Assignment06
-- Author: EChoi
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_EChoi')
	 Begin 
	  Alter Database [Assignment06DB_EChoi] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_EChoi;
	 End
	Create Database Assignment06DB_EChoi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_EChoi;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO
CREATE VIEW dbo.vCategories
WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName
FROM dbo.Categories;
GO


CREATE VIEW dbo.vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
GO


CREATE VIEW dbo.vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
GO

CREATE VIEW dbo.vInventories
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
FROM dbo.Inventories;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON dbo.Categories TO Public;
DENY SELECT ON dbo.Products TO Public;
DENY SELECT ON dbo.Employees TO Public;
DENY SELECT ON dbo.Inventories TO Public;
GO

GRANT SELECT ON dbo.vCategories TO Public;
GRANT SELECT ON dbo.vProducts TO Public;
GRANT SELECT ON dbo.vEmployees TO Public;
GRANT SELECT ON dbo.vInventories TO Public;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?

--CREATE VIEW dbo.vProductsByCategories
--AS
--SELECT CategoryName, ProductName, UnitPrice
--FROM dbo.vCategories
--INNER JOIN dbo.vProducts ON vCategories.CategoryID = vProducts.CategoryID;
--GO

-- Order the result by the Category and Product!

CREATE VIEW dbo.vProductsByCategories
AS
SELECT TOP 1000000000 CategoryName, ProductName, UnitPrice
FROM dbo.vCategories
INNER JOIN dbo.vProducts ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName, ProductName;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?

--CREATE VIEW dbo.vInventoriesByProductsByDates
--AS
--SELECT ProductName, InventoryDate, Count
--FROM vProducts
--INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID;
--GO

-- Order the results by the Product, Date, and Count!

CREATE VIEW dbo.vInventoriesByProductsByDates
AS
SELECT TOP 1000000000 ProductName, InventoryDate, Count
FROM vProducts
INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName, InventoryDate, Count;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?

--CREATE VIEW dbo.vInventoriesByEmployeesByDates
--AS
--SELECT DISTINCT InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
--FROM vInventories
--INNER JOIN vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID;
--GO 

-- Order the results by the Date and return only one row per date!

CREATE VIEW dbo.vInventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 1000000000 InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM vInventories
INNER JOIN vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID
ORDER BY InventoryDate;
GO 

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?

--CREATE VIEW dbo.vInventoriesByProductsByCategories
--AS
--SELECT CategoryName, ProductName, InventoryDate, Count
--FROM vCategories
--INNER JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID
--INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID;
--GO

-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW dbo.vInventoriesByProductsByCategories
AS
SELECT TOP 1000000000 CategoryName, ProductName, InventoryDate, Count
FROM vCategories
INNER JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID
INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?

--CREATE VIEW dbo.vInventoriesByProductsByEmployees
--AS
--SELECT TOP 1000000000 CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
--FROM vCategories
--INNER JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID
--INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID
--INNER JOIN vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID;
--GO

-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW dbo.vInventoriesByProductsByEmployees
AS
SELECT TOP 1000000000 CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM vCategories
INNER JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID
INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID
INNER JOIN vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 1000000000 CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM vCategories
INNER JOIN vProducts ON vCategories.CategoryID = vProducts.CategoryID
INNER JOIN vInventories ON vProducts.ProductID = vInventories.ProductID
INNER JOIN vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID
WHERE vProducts.ProductName IN ('Chai', 'Chang');
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW dbo.vEmployeesByManager
AS
SELECT TOP 1000000000 vManager.EmployeeFirstName + ' ' + vManager.EmployeeLastName AS Manager, vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS Employee
FROM vEmployees
LEFT JOIN vEmployees AS vManager ON vEmployees.ManagerID = vManager.EmployeeID
ORDER BY Manager;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW dbo.vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 1000000000 vCategories.CategoryID, vCategories.CategoryName, vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice, 
       vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
       vEmployees.EmployeeID, vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS Employee,
       Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName AS Manager
FROM dbo.vCategories
INNER JOIN dbo.vProducts ON vCategories.CategoryID = vProducts.CategoryID
INNER JOIN dbo.vInventories ON vProducts.ProductID = vInventories.ProductID
INNER JOIN dbo.vEmployees ON vInventories.EmployeeID = vEmployees.EmployeeID
LEFT JOIN dbo.vEmployees AS Manager ON vEmployees.ManagerID = Manager.EmployeeID
ORDER BY CategoryName, ProductName, InventoryID, Employee;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/