---Silver Layer: Customer Table

CREATE OR ALTER VIEW silver_Customer AS
SELECT 
    CustomerID,
    FirstName,
    LastName,
    FirstName + ' ' + LastName AS FullName,
    EmailAddress,
    Phone,
    CompanyName,
    SalesPerson,
    CAST(ModifiedDate AS DATE) AS ModifiedDate,
    GETDATE() AS ingestion_timestamp,
    'AdventureWorksLT2025' AS source_system
FROM lh_bronze_adventureworks.dbo.SalesLT_Customer
WHERE CustomerID IS NOT NULL;

-- Silver Layer: Product Table
CREATE OR ALTER VIEW silver_Product AS
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice,
    Size,
    Weight,
    ProductCategoryID,
    ProductModelID,
    CAST(SellStartDate AS DATE) AS SellStartDate,
    CAST(SellEndDate AS DATE) AS SellEndDate,
    GETDATE() AS ingestion_timestamp,
    'AdventureWorksLT' AS source_system
FROM lh_bronze_adventureworks.dbo.SalesLT_Product
WHERE ProductID IS NOT NULL
AND ListPrice > 0;

-- Silver Layer: ProductCategory Table
CREATE OR ALTER VIEW silver_ProductCategory AS
SELECT 
    ProductCategoryID,
    ParentProductCategoryID,
    Name AS CategoryName,
    GETDATE() AS ingestion_timestamp,
    'AdventureWorksLT2025' AS source_system
FROM lh_bronze_adventureworks.dbo.SalesLT_ProductCategory
WHERE ProductCategoryID IS NOT NULL;

-- Silver Layer: SalesOrderHeader Table
CREATE OR ALTER VIEW silver_SalesOrderHeader AS
SELECT 
    SalesOrderID,
    OrderDate,
    DueDate,
    ShipDate,
    Status,
    CustomerID,
    BillToAddressID,
    ShipToAddressID,
    SubTotal,
    TaxAmt,
    Freight,
    SubTotal + TaxAmt + Freight AS TotalAmount,
    CAST(OrderDate AS DATE) AS OrderDateOnly,
    GETDATE() AS ingestion_timestamp,
    'AdventureWorksLT2025' AS source_system
FROM lh_bronze_adventureworks.dbo.SalesLT_SalesOrderHeader
WHERE SalesOrderID IS NOT NULL
AND CustomerID IS NOT NULL;


-- Silver Layer: SalesOrderDetail Table
CREATE OR ALTER VIEW silver_SalesOrderDetail AS
SELECT 
    SalesOrderID,
    SalesOrderDetailID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount,
    OrderQty * UnitPrice AS LineTotal,
    OrderQty * UnitPrice * (1 - UnitPriceDiscount) AS DiscountedLineTotal,
    GETDATE() AS ingestion_timestamp,
    'AdventureWorksLT2025' AS source_system
FROM lh_bronze_adventureworks.dbo.SalesLT_SalesOrderDetail
WHERE SalesOrderID IS NOT NULL
AND ProductID IS NOT NULL;