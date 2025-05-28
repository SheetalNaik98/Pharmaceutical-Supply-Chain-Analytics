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
