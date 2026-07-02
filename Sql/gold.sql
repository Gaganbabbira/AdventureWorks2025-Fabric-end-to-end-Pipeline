-- Gold Layer: dim_Customer
CREATE OR ALTER VIEW gold_dim_Customer AS
SELECT 
    CustomerID,
    FullName,
    EmailAddress,
    Phone,
    CompanyName,
    SalesPerson
FROM silver_Customer;

-- Gold Layer: dim_Product
CREATE OR ALTER VIEW gold_dim_Product AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.ProductNumber,
    p.Color,
    p.StandardCost,
    p.ListPrice,
    p.Size,
    p.Weight,
    c.CategoryName,
    p.SellStartDate,
    p.SellEndDate
FROM silver_Product p
LEFT JOIN silver_ProductCategory c 
    ON p.ProductCategoryID = c.ProductCategoryID;

-- Gold Layer: dim_Date
CREATE OR ALTER VIEW gold_dim_Date AS
SELECT DISTINCT
    CAST(OrderDate AS DATE) AS DateKey,
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    DAY(OrderDate) AS Day,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATENAME(WEEKDAY, OrderDate) AS DayName,
    DATEPART(QUARTER, OrderDate) AS Quarter,
    CASE 
        WHEN MONTH(OrderDate) >= 4 THEN YEAR(OrderDate)
        ELSE YEAR(OrderDate) - 1
    END AS FiscalYear
FROM silver_SalesOrderHeader;


-- Gold Layer: fact_Sales
CREATE OR ALTER VIEW gold_fact_Sales AS
SELECT 
    d.SalesOrderID,
    d.SalesOrderDetailID,
    h.CustomerID,
    d.ProductID,
    CAST(h.OrderDate AS DATE) AS DateKey,
    d.OrderQty,
    d.UnitPrice,
    d.UnitPriceDiscount,
    d.LineTotal,
    d.DiscountedLineTotal,
    h.TotalAmount,
    h.SubTotal,
    h.TaxAmt,
    h.Freight,
    h.Status
FROM silver_SalesOrderDetail d
JOIN silver_SalesOrderHeader h 
    ON d.SalesOrderID = h.SalesOrderID;