-- =====================================================
-- Advanced SQL Queries for Business Intelligence
-- Pharmaceutical Supply Chain Analytics
-- =====================================================

-- Query 1: Sales Representative Performance Ranking
-- Uses window functions and CTEs for advanced analytics
WITH SalesMetrics AS (
    SELECT 
        sr.Representative_ID,
        sr.Name AS Rep_Name,
        r.Name AS Region_Name,
        COUNT(o.Order_ID) AS Total_Orders,
        SUM(o.Total_cost) AS Total_Sales,
        AVG(o.Total_cost) AS Avg_Order_Value,
        sr.Performance_Rating
    FROM Sales_Representative sr
    JOIN Region r ON sr.Region_ID = r.Region_ID
    LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
    WHERE o.Order_Status != 'Cancelled' OR o.Order_Status IS NULL
    GROUP BY sr.Representative_ID, sr.Name, r.Name, sr.Performance_Rating
),
RankedSales AS (
    SELECT *,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank,
        RANK() OVER (PARTITION BY Region_Name ORDER BY Total_Sales DESC) AS Regional_Rank,
        NTILE(4) OVER (ORDER BY Total_Sales DESC) AS Performance_Quartile
    FROM SalesMetrics
)
SELECT 
    Rep_Name,
    Region_Name,
    Total_Sales,
    Sales_Rank,
    Regional_Rank,
    CASE Performance_Quartile
        WHEN 1 THEN 'Top Performer'
        WHEN 2 THEN 'Above Average'
        WHEN 3 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS Performance_Category
FROM RankedSales
ORDER BY Sales_Rank;

-- Query 2: Product Profitability Analysis with Market Share
-- Complex aggregation with percentage calculations
SELECT 
    p.Category,
    p.Name AS Product_Name,
    SUM(inv.Quantity_Ordered) AS Units_Sold,
    SUM(inv.Line_Total) AS Total_Revenue,
    AVG(p.Price) AS Average_Price,
    SUM(inv.Line_Total) / SUM(SUM(inv.Line_Total)) OVER () * 100 AS Market_Share_Percent,
    SUM(inv.Line_Total) / SUM(SUM(inv.Line_Total)) OVER (PARTITION BY p.Category) * 100 AS Category_Share_Percent,
    RANK() OVER (PARTITION BY p.Category ORDER BY SUM(inv.Line_Total) DESC) AS Category_Rank
FROM Product p
JOIN Involvement inv ON p.Product_ID = inv.Product_ID
JOIN Orders o ON inv.Order_ID = o.Order_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY p.Product_ID, p.Category, p.Name
HAVING Total_Revenue > 0
ORDER BY p.Category, Total_Revenue DESC;

-- Query 3: Customer Lifetime Value Analysis
-- Advanced customer analytics with cohort analysis
WITH CustomerMetrics AS (
    SELECT 
        c.Customer_ID,
        c.Name AS Customer_Name,
        CASE 
            WHEN d.Customer_ID IS NOT NULL THEN 'Doctor'
            WHEN h.Customer_ID IS NOT NULL THEN 'Hospital'
            WHEN ph.Customer_ID IS NOT NULL THEN 'Pharmacy'
            ELSE 'Other'
        END AS Customer_Type,
        MIN(o.Date) AS First_Order_Date,
        MAX(o.Date) AS Last_Order_Date,
        COUNT(DISTINCT o.Order_ID) AS Total_Orders,
        SUM(o.Total_cost) AS Total_Spent,
        AVG(o.Total_cost) AS Average_Order_Value,
        DATEDIFF(MAX(o.Date), MIN(o.Date)) AS Customer_Lifespan_Days
    FROM Customer c
    LEFT JOIN Doctors d ON c.Customer_ID = d.Customer_ID
    LEFT JOIN Hospital h ON c.Customer_ID = h.Customer_ID
    LEFT JOIN Pharmacy ph ON c.Customer_ID = ph.Customer_ID
    JOIN Order_Placed op ON c.Customer_ID = op.Customer_ID
    JOIN Orders o ON op.Order_ID = o.Order_ID
    WHERE o.Order_Status = 'Delivered'
    GROUP BY c.Customer_ID, c.Name
)
SELECT 
    Customer_Name,
    Customer_Type,
    Total_Orders,
    Total_Spent,
    Average_Order_Value,
    Customer_Lifespan_Days,
    CASE 
        WHEN Customer_Lifespan_Days > 0 
        THEN Total_Spent / (Customer_Lifespan_Days / 30.0)
        ELSE Total_Spent
    END AS Monthly_Value,
    CASE 
        WHEN Total_Spent >= 1000 AND Total_Orders >= 5 THEN 'High Value'
        WHEN Total_Spent >= 500 AND Total_Orders >= 3 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM CustomerMetrics
ORDER BY Total_Spent DESC;

-- Query 4: Inventory Turnover and Optimization Analysis
-- Supply chain efficiency metrics
WITH InventoryAnalysis AS (
    SELECT 
        p.Product_ID,
        p.Name AS Product_Name,
        p.Category,
        p.Price,
        i.Quantity AS Current_Stock,
        i.Reorder_Level,
        COALESCE(SUM(inv.Quantity_Ordered), 0) AS Total_Sold_YTD,
        COUNT(DISTINCT inv.Order_ID) AS Number_of_Orders,
        COALESCE(AVG(inv.Quantity_Ordered), 0) AS Avg_Order_Quantity
    FROM Product p
    LEFT JOIN Inventory i ON p.Product_ID = i.Product_ID
    LEFT JOIN Involvement inv ON p.Product_ID = inv.Product_ID
    LEFT JOIN Orders o ON inv.Order_ID = o.Order_ID 
        AND o.Date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
        AND o.Order_Status = 'Delivered'
    GROUP BY p.Product_ID, p.Name, p.Category, p.Price, i.Quantity, i.Reorder_Level
)
SELECT 
    Product_Name,
    Category,
    Current_Stock,
    Total_Sold_YTD,
    CASE 
        WHEN Current_Stock > 0 AND Total_Sold_YTD > 0 
        THEN ROUND(Total_Sold_YTD / Current_Stock, 2)
        ELSE 0
    END AS Turnover_Ratio,
    CASE 
        WHEN Current_Stock > 0 AND Total_Sold_YTD > 0 
        THEN ROUND(365 / (Total_Sold_YTD / Current_Stock), 0)
        ELSE NULL
    END AS Days_of_Supply,
    Current_Stock * Price AS Inventory_Value,
    CASE 
        WHEN Current_Stock = 0 THEN 'OUT_OF_STOCK'
        WHEN Current_Stock <= Reorder_Level * 0.3 THEN 'CRITICAL'
        WHEN Current_Stock <= Reorder_Level * 0.6 THEN 'LOW'
        WHEN Current_Stock <= Reorder_Level THEN 'REORDER'
        WHEN Current_Stock > Reorder_Level * 3 THEN 'OVERSTOCK'
        ELSE 'OPTIMAL'
    END AS Stock_Status,
    CASE 
        WHEN Total_Sold_YTD = 0 THEN 'DISCONTINUE'
        WHEN Current_Stock = 0 THEN 'URGENT_REORDER'
        WHEN Current_Stock <= Reorder_Level THEN 'REORDER_SOON'
        WHEN Current_Stock > Reorder_Level * 3 THEN 'REDUCE_STOCK'
        ELSE 'MAINTAIN'
    END AS Recommended_Action
FROM InventoryAnalysis
ORDER BY Turnover_Ratio DESC;

-- Query 5: Regional Market Penetration Analysis
-- Geographic performance with growth metrics
WITH RegionalMetrics AS (
    SELECT 
        r.Region_ID,
        r.Name AS Region_Name,
        COUNT(DISTINCT sr.Representative_ID) AS Active_Reps,
        COUNT(DISTINCT c.Customer_ID) AS Unique_Customers,
        COUNT(DISTINCT o.Order_ID) AS Total_Orders,
        SUM(o.Total_cost) AS Total_Revenue,
        AVG(o.Total_cost) AS Avg_Order_Value
    FROM Region r
    LEFT JOIN Sales_Representative sr ON r.Region_ID = sr.Region_ID
    LEFT JOIN Interaction i ON sr.Representative_ID = i.Representative_ID
    LEFT JOIN Customer c ON i.Customer_ID = c.Customer_ID
    LEFT JOIN Order_Placed op ON c.Customer_ID = op.Customer_ID
    LEFT JOIN Orders o ON op.Order_ID = o.Order_ID
    WHERE o.Order_Status = 'Delivered' OR o.Order_Status IS NULL
    GROUP BY r.Region_ID, r.Name
)
SELECT 
    Region_Name,
    Active_Reps,
    Unique_Customers,
    Total_Orders,
    Total_Revenue,
    Avg_Order_Value,
    CASE 
        WHEN Active_Reps > 0 THEN Total_Revenue / Active_Reps
        ELSE 0
    END AS Revenue_Per_Rep,
    CASE 
        WHEN Active_Reps > 0 THEN Total_Orders / Active_Reps
        ELSE 0
    END AS Orders_Per_Rep,
    CASE 
        WHEN Unique_Customers > 0 THEN Total_Revenue / Unique_Customers
        ELSE 0
    END AS Revenue_Per_Customer,
    Total_Revenue / SUM(Total_Revenue) OVER () * 100 AS Market_Share_Percent,
    CASE 
        WHEN Total_Revenue >= 100000 THEN 'High Performance'
        WHEN Total_Revenue >= 50000 THEN 'Medium Performance'
        WHEN Total_Revenue > 0 THEN 'Low Performance'
        ELSE 'No Activity'
    END AS Performance_Category
FROM RegionalMetrics
ORDER BY Total_Revenue DESC;

-- Query 6: Customer Interaction Effectiveness Analysis
-- Analyze which interaction methods drive the most revenue
WITH InteractionAnalysis AS (
    SELECT 
        s.Interaction_Type,
        COUNT(DISTINCT s.Shipment_ID) AS Total_Shipments,
        COUNT(DISTINCT o.Order_ID) AS Total_Orders,
        SUM(o.Total_cost) AS Total_Revenue,
        AVG(o.Total_cost) AS Avg_Order_Value,
        COUNT(DISTINCT sr.Representative_ID) AS Reps_Using_Method
    FROM Shipment s
    JOIN Orders o ON s.Shipment_ID = o.Shipment_ID
    JOIN Sales_Representative sr ON o.Representative_ID = sr.Representative_ID
    WHERE o.Order_Status = 'Delivered'
    GROUP BY s.Interaction_Type
)
SELECT 
    Interaction_Type,
    Total_Orders,
    Total_Revenue,
    Avg_Order_Value,
    Reps_Using_Method,
    Total_Revenue / SUM(Total_Revenue) OVER () * 100 AS Revenue_Share_Percent,
    CASE 
        WHEN Avg_Order_Value >= (SELECT AVG(Avg_Order_Value) FROM InteractionAnalysis) 
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS Performance_vs_Average,
    RANK() OVER (ORDER BY Total_Revenue DESC) AS Effectiveness_Rank
FROM InteractionAnalysis
ORDER BY Total_Revenue DESC;

-- Query 7: Seasonal Sales Pattern Analysis
-- Identify seasonal trends and patterns
SELECT 
    YEAR(o.Date) AS Sales_Year,
    MONTH(o.Date) AS Sales_Month,
    MONTHNAME(o.Date) AS Month_Name,
    COUNT(DISTINCT o.Order_ID) AS Monthly_Orders,
    SUM(o.Total_cost) AS Monthly_Revenue,
    AVG(o.Total_cost) AS Avg_Order_Value,
    COUNT(DISTINCT o.Representative_ID) AS Active_Reps,
    SUM(o.Total_cost) / LAG(SUM(o.Total_cost)) OVER (ORDER BY YEAR(o.Date), MONTH(o.Date)) - 1 AS Growth_Rate,
    SUM(SUM(o.Total_cost)) OVER (PARTITION BY YEAR(o.Date) ORDER BY MONTH(o.Date)) AS YTD_Revenue
FROM Orders o
WHERE o.Order_Status = 'Delivered'
    AND o.Date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY YEAR(o.Date), MONTH(o.Date), MONTHNAME(o.Date)
ORDER BY Sales_Year DESC, Sales_Month DESC;

-- Query 8: Product Cross-Sell Analysis
-- Identify products frequently bought together
WITH ProductPairs AS (
    SELECT 
        i1.Product_ID AS Product_A,
        i2.Product_ID AS Product_B,
        COUNT(*) AS Co_Purchase_Frequency
    FROM Involvement i1
    JOIN Involvement i2 ON i1.Order_ID = i2.Order_ID
    WHERE i1.Product_ID < i2.Product_ID  -- Avoid duplicates
    GROUP BY i1.Product_ID, i2.Product_ID
    HAVING COUNT(*) >= 2  -- Only pairs bought together at least twice
)
SELECT 
    p1.Name AS Product_A_Name,
    p1.Category AS Product_A_Category,
    p2.Name AS Product_B_Name,
    p2.Category AS Product_B_Category,
    pp.Co_Purchase_Frequency,
    RANK() OVER (ORDER BY pp.Co_Purchase_Frequency DESC) AS Cross_Sell_Rank,
    CASE 
        WHEN p1.Category = p2.Category THEN 'Same Category'
        ELSE 'Cross Category'
    END AS Relationship_Type
FROM ProductPairs pp
JOIN Product p1 ON pp.Product_A = p1.Product_ID
JOIN Product p2 ON pp.Product_B = p2.Product_ID
ORDER BY pp.Co_Purchase_Frequency DESC;

-- Query 9: Representative Workload and Efficiency Analysis
-- Analyze representative capacity and efficiency
WITH RepWorkload AS (
    SELECT 
        sr.Representative_ID,
        sr.Name AS Rep_Name,
        r.Name AS Region_Name,
        COUNT(DISTINCT i.Customer_ID) AS Customers_Managed,
        COUNT(DISTINCT o.Order_ID) AS Orders_Processed,
        SUM(o.Total_cost) AS Total_Sales,
        COUNT(DISTINCT o.Date) AS Active_Days,
        sr.Performance_Rating
    FROM Sales_Representative sr
    JOIN Region r ON sr.Region_ID = r.Region_ID
    LEFT JOIN Interaction i ON sr.Representative_ID = i.Representative_ID
    LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
    WHERE o.Order_Status = 'Delivered' OR o.Order_Status IS NULL
    GROUP BY sr.Representative_ID, sr.Name, r.Name, sr.Performance_Rating
)
SELECT 
    Rep_Name,
    Region_Name,
    Customers_Managed,
    Orders_Processed,
    Total_Sales,
    Performance_Rating,
    CASE 
        WHEN Orders_Processed > 0 THEN Total_Sales / Orders_Processed
        ELSE 0
    END AS Revenue_Per_Order,
    CASE 
        WHEN Customers_Managed > 0 THEN Total_Sales / Customers_Managed
        ELSE 0
    END AS Revenue_Per_Customer,
    CASE 
        WHEN Active_Days > 0 THEN Orders_Processed / Active_Days
        ELSE 0
    END AS Orders_Per_Day,
    CASE 
        WHEN Customers_Managed <= 10 THEN 'Light Load'
        WHEN Customers_Managed <= 20 THEN 'Moderate Load'
        WHEN Customers_Managed <= 30 THEN 'Heavy Load'
        ELSE 'Overloaded'
    END AS Workload_Category,
    CASE 
        WHEN Performance_Rating >= 4.5 AND Total_Sales >= 50000 THEN 'Star Performer'
        WHEN Performance_Rating >= 4.0 AND Total_Sales >= 30000 THEN 'High Performer'
        WHEN Performance_Rating >= 3.5 AND Total_Sales >= 15000 THEN 'Good Performer'
        ELSE 'Needs Development'
    END AS Overall_Rating
FROM RepWorkload
ORDER BY Total_Sales DESC;

-- Query 10: Customer Retention and Churn Analysis
-- Identify at-risk customers and retention patterns
WITH CustomerActivity AS (
    SELECT 
        c.Customer_ID,
        c.Name AS Customer_Name,
        CASE 
            WHEN d.Customer_ID IS NOT NULL THEN 'Doctor'
            WHEN h.Customer_ID IS NOT NULL THEN 'Hospital'
            WHEN ph.Customer_ID IS NOT NULL THEN 'Pharmacy'
            ELSE 'Other'
        END AS Customer_Type,
        COUNT(DISTINCT o.Order_ID) AS Total_Orders,
        SUM(o.Total_cost) AS Total_Spent,
        MAX(o.Date) AS Last_Order_Date,
        MIN(o.Date) AS First_Order_Date,
        DATEDIFF(CURDATE(), MAX(o.Date)) AS Days_Since_Last_Order,
        AVG(DATEDIFF(o.Date, LAG(o.Date) OVER (PARTITION BY c.Customer_ID ORDER BY o.Date))) AS Avg_Days_Between_Orders
    FROM Customer c
    LEFT JOIN Doctors d ON c.Customer_ID = d.Customer_ID
    LEFT JOIN Hospital h ON c.Customer_ID = h.Customer_ID
    LEFT JOIN Pharmacy ph ON c.Customer_ID = ph.Customer_ID
    JOIN Order_Placed op ON c.Customer_ID = op.Customer_ID
    JOIN Orders o ON op.Order_ID = o.Order_ID
    WHERE o.Order_Status = 'Delivered'
    GROUP BY c.Customer_ID, c.Name
)
SELECT 
    Customer_Name,
    Customer_Type,
    Total_Orders,
    Total_Spent,
    Last_Order_Date,
    Days_Since_Last_Order,
    COALESCE(Avg_Days_Between_Orders, 0) AS Avg_Order_Frequency,
    CASE 
        WHEN Days_Since_Last_Order <= 30 THEN 'Active'
        WHEN Days_Since_Last_Order <= 60 THEN 'At Risk'
        WHEN Days_Since_Last_Order <= 90 THEN 'Inactive'
        ELSE 'Churned'
    END AS Customer_Status,
    CASE 
        WHEN Total_Spent >= 1000 AND Days_Since_Last_Order <= 60 THEN 'High Priority'
        WHEN Total_Spent >= 500 AND Days_Since_Last_Order <= 90 THEN 'Medium Priority'
        WHEN Days_Since_Last_Order > 90 THEN 'Win-Back Campaign'
        ELSE 'Standard'
    END AS Action_Priority,
    CASE 
        WHEN Days_Since_Last_Order > COALESCE(Avg_Days_Between_Orders * 2, 60) THEN 'Overdue'
        WHEN Days_Since_Last_Order > COALESCE(Avg_Days_Between_Orders * 1.5, 45) THEN 'Due Soon'
        ELSE 'On Schedule'
    END AS Reorder_Status
FROM CustomerActivity
ORDER BY 
    CASE Customer_Status
        WHEN 'Churned' THEN 1
        WHEN 'Inactive' THEN 2
        WHEN 'At Risk' THEN 3
        ELSE 4
    END,
    Total_Spent DESC;

-- Query 11: Supply Chain Performance Metrics
-- Comprehensive supply chain KPIs
WITH SupplyChainMetrics AS (
    SELECT 
        p.Category,
        COUNT(DISTINCT p.Product_ID) AS Products_In_Category,
        SUM(i.Quantity) AS Total_Inventory_Units,
        SUM(i.Quantity * p.Price) AS Total_Inventory_Value,
        AVG(i.Quantity) AS Avg_Stock_Level,
        COUNT(CASE WHEN i.Quantity <= i.Reorder_Level THEN 1 END) AS Products_Below_Reorder,
        COUNT(CASE WHEN i.Quantity = 0 THEN 1 END) AS Out_Of_Stock_Products,
        SUM(CASE WHEN s.Status = 'Delivered' THEN 1 ELSE 0 END) AS Successful_Shipments,
        COUNT(DISTINCT s.Shipment_ID) AS Total_Shipments
    FROM Product p
    LEFT JOIN Inventory i ON p.Product_ID = i.Product_ID
    LEFT JOIN Shipping sh ON p.Product_ID = sh.Product_ID
    LEFT JOIN Shipment s ON sh.Shipment_ID = s.Shipment_ID
    GROUP BY p.Category
)
SELECT 
    Category,
    Products_In_Category,
    Total_Inventory_Units,
    Total_Inventory_Value,
    Products_Below_Reorder,
    Out_Of_Stock_Products,
    ROUND(Products_Below_Reorder * 100.0 / Products_In_Category, 2) AS Reorder_Rate_Percent,
    ROUND(Out_Of_Stock_Products * 100.0 / Products_In_Category, 2) AS Stockout_Rate_Percent,
    CASE 
        WHEN Total_Shipments > 0 THEN ROUND(Successful_Shipments * 100.0 / Total_Shipments, 2)
        ELSE 0
    END AS Delivery_Success_Rate,
    CASE 
        WHEN Out_Of_Stock_Products = 0 AND Products_Below_Reorder <= Products_In_Category * 0.1 
        THEN 'Excellent'
        WHEN Out_Of_Stock_Products <= 1 AND Products_Below_Reorder <= Products_In_Category * 0.2 
        THEN 'Good'
        WHEN Out_Of_Stock_Products <= 2 AND Products_Below_Reorder <= Products_In_Category * 0.3 
        THEN 'Fair'
        ELSE 'Poor'
    END AS Supply_Chain_Health
FROM SupplyChainMetrics
ORDER BY Total_Inventory_Value DESC;

-- Query 12: Executive Dashboard Summary
-- High-level KPIs for executive reporting
SELECT 
    'Total Revenue (YTD)' AS Metric,
    CONCAT(', FORMAT(SUM(o.Total_cost), 2)) AS Value,
    'Financial' AS Category
FROM Orders o
WHERE YEAR(o.Date) = YEAR(CURDATE()) AND o.Order_Status = 'Delivered'

UNION ALL

SELECT 
    'Total Orders (YTD)' AS Metric,
    FORMAT(COUNT(o.Order_ID), 0) AS Value,
    'Operational' AS Category
FROM Orders o
WHERE YEAR(o.Date) = YEAR(CURDATE()) AND o.Order_Status = 'Delivered'

UNION ALL

SELECT 
    'Average Order Value' AS Metric,
    CONCAT(', FORMAT(AVG(o.Total_cost), 2)) AS Value,
    'Financial' AS Category
FROM Orders o
WHERE o.Order_Status = 'Delivered'

UNION ALL

SELECT 
    'Active Sales Representatives' AS Metric,
    FORMAT(COUNT(DISTINCT sr.Representative_ID), 0) AS Value,
    'Human Resources' AS Category
FROM Sales_Representative sr

UNION ALL

SELECT 
    'Total Inventory Value' AS Metric,
    CONCAT(', FORMAT(SUM(p.Price * i.Quantity), 2)) AS Value,
    'Inventory' AS Category
FROM Product p
JOIN Inventory i ON p.Product_ID = i.Product_ID

UNION ALL

SELECT 
    'Products Below Reorder Level' AS Metric,
    FORMAT(COUNT(*), 0) AS Value,
    'Inventory' AS Category
FROM Inventory i
WHERE i.Quantity <= i.Reorder_Level

UNION ALL

SELECT 
    'Customer Satisfaction Rate' AS Metric,
    CONCAT(FORMAT(AVG(sr.Performance_Rating) * 20, 1), '%') AS Value,
    'Customer Service' AS Category
FROM Sales_Representative sr

ORDER BY Category, Metric;
