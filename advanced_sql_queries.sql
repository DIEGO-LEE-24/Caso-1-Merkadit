-- =====================================================
-- MERKADIT - ADVANCED SQL QUERIES
-- Deliverable #5: SQL queries using ORDER BY, TOP, nested queries, EXISTS, IN, calculated fields
-- =====================================================

-- =====================================================
-- QUERY 1: Business Report with Calculated Fields (Main Report Requirement)
-- Uses: ORDER BY, nested queries, calculated fields
-- =====================================================

SELECT 
    c.name AS business_name,
    s.name AS space_name,
    b.name AS building_name,
    
    -- Calculated field: First sale date of current month
    (SELECT MIN(sa.saleDate) 
     FROM Sales sa 
     WHERE sa.commerceID = c.commerceID 
       AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
       AND YEAR(sa.saleDate) = YEAR(CURDATE())) AS first_sale_current_month,
    
    -- Calculated field: Last sale date of current month  
    (SELECT MAX(sa.saleDate) 
     FROM Sales sa 
     WHERE sa.commerceID = c.commerceID 
       AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
       AND YEAR(sa.saleDate) = YEAR(CURDATE())) AS last_sale_current_month,
    
    -- Calculated field: Number of items sold
    (SELECT COALESCE(SUM(sd.quantity), 0)
     FROM Sales sa 
     JOIN SaleDetails sd ON sa.saleID = sd.saleID
     WHERE sa.commerceID = c.commerceID 
       AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
       AND YEAR(sa.saleDate) = YEAR(CURDATE())) AS items_sold,
    
    -- Calculated field: Total sales amount
    (SELECT COALESCE(SUM(sa.totalAmount), 0)
     FROM Sales sa 
     WHERE sa.commerceID = c.commerceID 
       AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
       AND YEAR(sa.saleDate) = YEAR(CURDATE())) AS total_sales_amount,
    
    -- Calculated field: Commission percentage
    ct.commissionPercentage AS base_commission_percentage,
    
    -- Calculated field: Commission amount due to space owner
    ((SELECT COALESCE(SUM(sa.totalAmount), 0)
      FROM Sales sa 
      WHERE sa.commerceID = c.commerceID 
        AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
        AND YEAR(sa.saleDate) = YEAR(CURDATE())) * ct.commissionPercentage / 100) AS commission_amount,
    
    -- Calculated field: Base rent amount
    ct.baseRent AS rental_fee_amount,
    
    -- Calculated field: Total amount due (rent + commission)
    (ct.baseRent + 
     ((SELECT COALESCE(SUM(sa.totalAmount), 0)
       FROM Sales sa 
       WHERE sa.commerceID = c.commerceID 
         AND MONTH(sa.saleDate) = MONTH(CURDATE()) 
         AND YEAR(sa.saleDate) = YEAR(CURDATE())) * ct.commissionPercentage / 100)) AS total_amount_due

FROM Commerces c
JOIN Contracts ct ON c.commerceID = ct.commerceID
JOIN Spaces s ON ct.spaceID = s.spaceID
JOIN Floors f ON s.floorID = f.floorID
JOIN Buildings b ON f.buildingID = b.buildingID
WHERE c.isActive = 1 
ORDER BY b.name, s.name, c.name;

-- =====================================================
-- QUERY 2: TOP Performing Products by Sales Volume
-- Uses: ORDER BY, LIMIT (MySQL equivalent of TOP), calculated fields
-- =====================================================

SELECT 
    p.name AS product_name,
    p.sku AS product_sku,
    c.name AS commerce_name,
    cat.name AS category_name,
    
    -- Calculated fields
    SUM(sd.quantity) AS total_quantity_sold,
    SUM(sd.quantity * sd.unitPrice) AS total_revenue,
    AVG(sd.unitPrice) AS average_selling_price,
    COUNT(DISTINCT s.saleID) AS number_of_sales,
    
    -- Calculated field: Revenue per sale
    (SUM(sd.quantity * sd.unitPrice) / COUNT(DISTINCT s.saleID)) AS revenue_per_sale

FROM Products p
JOIN SaleDetails sd ON p.productID = sd.productID
JOIN Sales s ON sd.saleID = s.saleID
JOIN Commerces c ON p.commerceID = c.commerceID
JOIN Categories cat ON p.categoryID = cat.categoryID
WHERE s.saleDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY p.productID, p.name, p.sku, c.name, cat.name
ORDER BY total_revenue DESC, total_quantity_sold DESC
LIMIT 15;

-- =====================================================
-- QUERY 3: Commerces with High-Value Sales using EXISTS
-- Uses: EXISTS, nested query, calculated fields, ORDER BY
-- =====================================================

SELECT 
    c.commerceID,
    c.name AS commerce_name,
    s.name AS space_name,
    b.name AS building_name,
    
    -- Calculated field: Average sale value
    (SELECT AVG(sa.totalAmount) 
     FROM Sales sa 
     WHERE sa.commerceID = c.commerceID 
       AND sa.saleDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AS avg_sale_value,
    
    -- Calculated field: Total high-value sales count
    (SELECT COUNT(*) 
     FROM Sales sa 
     WHERE sa.commerceID = c.commerceID 
       AND sa.totalAmount > 50000.00 
       AND sa.saleDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AS high_value_sales_count

FROM Commerces c
JOIN Contracts ct ON c.commerceID = ct.commerceID
JOIN Spaces s ON ct.spaceID = s.spaceID
JOIN Floors f ON s.floorID = f.floorID
JOIN Buildings b ON f.buildingID = b.buildingID
WHERE EXISTS (
    -- Nested query: Check if commerce has high-value sales
    SELECT 1 
    FROM Sales sa 
    WHERE sa.commerceID = c.commerceID 
      AND sa.totalAmount > 50000.00 
      AND sa.saleDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
)
AND c.isActive = 1
ORDER BY avg_sale_value DESC, high_value_sales_count DESC;

-- =====================================================
-- QUERY 4: Category Performance Analysis using IN
-- Uses: IN, nested queries, calculated fields, ORDER BY
-- =====================================================

SELECT 
    cat.categoryID,
    cat.name AS category_name,
    cat.defaultCommissionPercentage AS default_commission,
    
    -- Calculated field: Total products in category
    COUNT(DISTINCT p.productID) AS total_products,
    
    -- Calculated field: Active commerces selling this category
    COUNT(DISTINCT p.commerceID) AS commerces_count,
    
    -- Calculated field: Total sales volume
    COALESCE(SUM(sd.quantity), 0) AS total_volume_sold,
    
    -- Calculated field: Total revenue
    COALESCE(SUM(sd.quantity * sd.unitPrice), 0) AS total_revenue,
    
    -- Calculated field: Average price per unit
    CASE 
        WHEN SUM(sd.quantity) > 0 
        THEN SUM(sd.quantity * sd.unitPrice) / SUM(sd.quantity)
        ELSE 0 
    END AS avg_price_per_unit,
    
    -- Calculated field: Commission generated
    COALESCE(SUM(sd.quantity * sd.unitPrice), 0) * cat.defaultCommissionPercentage / 100 AS commission_generated

FROM Categories cat
LEFT JOIN Products p ON cat.categoryID = p.categoryID
LEFT JOIN SaleDetails sd ON p.productID = sd.productID
LEFT JOIN Sales s ON sd.saleID = s.saleID
WHERE cat.categoryID IN (
    -- Nested query: Categories with sales in the last 3 months
    SELECT DISTINCT p2.categoryID
    FROM Products p2
    JOIN SaleDetails sd2 ON p2.productID = sd2.productID
    JOIN Sales s2 ON sd2.saleID = s2.saleID
    WHERE s2.saleDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
)
AND (s.saleDate IS NULL OR s.saleDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH))
GROUP BY cat.categoryID, cat.name, cat.defaultCommissionPercentage
ORDER BY total_revenue DESC, total_volume_sold DESC;

-- =====================================================
-- QUERY 5: Settlement Analysis with Complex Nested Queries
-- Uses: Nested queries, EXISTS, calculated fields, ORDER BY
-- =====================================================

SELECT 
    c.commerceID,
    c.name AS commerce_name,
    b.name AS building_name,
    
    -- Calculated field: Months with settlements
    (SELECT COUNT(DISTINCT CONCAT(YEAR(st.settlementDate), '-', MONTH(st.settlementDate)))
     FROM Settlements st
     JOIN Contracts ct2 ON st.contractID = ct2.contractID
     WHERE ct2.commerceID = c.commerceID) AS months_with_settlements,
    
    -- Calculated field: Average monthly revenue
    (SELECT AVG(st.totalSales)
     FROM Settlements st
     JOIN Contracts ct2 ON st.contractID = ct2.contractID
     WHERE ct2.commerceID = c.commerceID) AS avg_monthly_revenue,
    
    -- Calculated field: Average monthly commission
    (SELECT AVG(st.commissionAmount)
     FROM Settlements st
     JOIN Contracts ct2 ON st.contractID = ct2.contractID
     WHERE ct2.commerceID = c.commerceID) AS avg_monthly_commission,
    
    -- Calculated field: Total revenue generated
    (SELECT COALESCE(SUM(st.totalSales), 0)
     FROM Settlements st
     JOIN Contracts ct2 ON st.contractID = ct2.contractID
     WHERE ct2.commerceID = c.commerceID) AS total_revenue_generated,
    
    -- Calculated field: Performance trend (latest vs previous month)
    CASE 
        WHEN (SELECT st1.totalSales 
              FROM Settlements st1 
              JOIN Contracts ct3 ON st1.contractID = ct3.contractID 
              WHERE ct3.commerceID = c.commerceID 
              ORDER BY st1.settlementDate DESC LIMIT 1) > 
             (SELECT st2.totalSales 
              FROM Settlements st2 
              JOIN Contracts ct4 ON st2.contractID = ct4.contractID 
              WHERE ct4.commerceID = c.commerceID 
              ORDER BY st2.settlementDate DESC LIMIT 1 OFFSET 1)
        THEN 'IMPROVING'
        WHEN (SELECT st1.totalSales 
              FROM Settlements st1 
              JOIN Contracts ct3 ON st1.contractID = ct3.contractID 
              WHERE ct3.commerceID = c.commerceID 
              ORDER BY st1.settlementDate DESC LIMIT 1) < 
             (SELECT st2.totalSales 
              FROM Settlements st2 
              JOIN Contracts ct4 ON st2.contractID = ct4.contractID 
              WHERE ct4.commerceID = c.commerceID 
              ORDER BY st2.settlementDate DESC LIMIT 1 OFFSET 1)
        THEN 'DECLINING'
        ELSE 'STABLE'
    END AS performance_trend

FROM Commerces c
JOIN Contracts ct ON c.commerceID = ct.commerceID
JOIN Spaces s ON ct.spaceID = s.spaceID
JOIN Floors f ON s.floorID = f.floorID
JOIN Buildings b ON f.buildingID = b.buildingID
WHERE EXISTS (
    -- Only include commerces with settlements
    SELECT 1
    FROM Settlements st
    JOIN Contracts ct2 ON st.contractID = ct2.contractID
    WHERE ct2.commerceID = c.commerceID
)
AND c.isActive = 1
ORDER BY total_revenue_generated DESC, avg_monthly_revenue DESC;

-- =====================================================
-- QUERY 6: Inventory Analysis with Multiple Techniques
-- Uses: IN, EXISTS, nested queries, calculated fields, ORDER BY
-- =====================================================

SELECT 
    p.productID,
    p.name AS product_name,
    p.sku,
    c.name AS commerce_name,
    cat.name AS category_name,
    
    -- Calculated fields for inventory management
    p.stockQuantity AS current_stock,
    p.minStock AS minimum_threshold,
    p.maxStock AS maximum_capacity,
    
    -- Calculated field: Stock status
    CASE 
        WHEN p.stockQuantity <= p.minStock THEN 'LOW_STOCK'
        WHEN p.stockQuantity >= p.maxStock * 0.9 THEN 'OVERSTOCKED'
        ELSE 'NORMAL'
    END AS stock_status,
    
    -- Calculated field: Days of inventory remaining (based on recent sales velocity)
    CASE 
        WHEN (SELECT AVG(daily_sales.qty_per_day) 
              FROM (SELECT DATE(s.saleDate) as sale_date, 
                           SUM(sd.quantity) as qty_per_day
                    FROM Sales s
                    JOIN SaleDetails sd ON s.saleID = sd.saleID
                    WHERE sd.productID = p.productID 
                      AND s.saleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                    GROUP BY DATE(s.saleDate)) daily_sales) > 0
        THEN p.stockQuantity / (SELECT AVG(daily_sales.qty_per_day) 
                                FROM (SELECT DATE(s.saleDate) as sale_date, 
                                             SUM(sd.quantity) as qty_per_day
                                      FROM Sales s
                                      JOIN SaleDetails sd ON s.saleID = sd.saleID
                                      WHERE sd.productID = p.productID 
                                        AND s.saleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                                      GROUP BY DATE(s.saleDate)) daily_sales)
        ELSE NULL
    END AS estimated_days_remaining,
    
    -- Calculated field: Revenue potential of current stock
    p.stockQuantity * (SELECT ph.sellingPrice 
                       FROM PriceHistory ph 
                       WHERE ph.productID = p.productID 
                       ORDER BY ph.effectiveDate DESC 
                       LIMIT 1) AS stock_value

FROM Products p
JOIN Commerces c ON p.commerceID = c.commerceID
JOIN Categories cat ON p.categoryID = cat.categoryID
WHERE p.commerceID IN (
    -- Only include products from active commerces
    SELECT ct.commerceID 
    FROM Contracts ct 
)
AND EXISTS (
    -- Only include products that have been sold
    SELECT 1 
    FROM SaleDetails sd 
    JOIN Sales s ON sd.saleID = s.saleID 
    WHERE sd.productID = p.productID 
      AND s.saleDate >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
)
ORDER BY 
    CASE 
        WHEN p.stockQuantity <= p.minStock THEN 1
        WHEN p.stockQuantity >= p.maxStock * 0.9 THEN 2
        ELSE 3
    END,
    estimated_days_remaining ASC;

-- =====================================================
-- CREATE MAIN BUSINESS REPORT VIEW
-- Transform Query 1 into a view for reporting tools
-- =====================================================

CREATE OR REPLACE VIEW BusinessReportView AS
SELECT 
    c.name AS business_name,
    s.name AS space_name,
    b.name AS building_name,
    DATE(MIN_DATE.first_sale) AS first_sale_current_month,
    DATE(MAX_DATE.last_sale) AS last_sale_current_month,
    COALESCE(ITEMS.items_sold, 0) AS items_sold,
    COALESCE(SALES.total_sales_amount, 0) AS total_sales_amount,
    ct.commissionPercentage AS commission_percentage,
    COALESCE(SALES.total_sales_amount * ct.commissionPercentage / 100, 0) AS commission_amount,
    ct.baseRent AS rental_fee_amount,
    (ct.baseRent + COALESCE(SALES.total_sales_amount * ct.commissionPercentage / 100, 0)) AS total_amount_due,
    CURDATE() AS report_date

FROM Commerces c
JOIN Contracts ct ON c.commerceID = ct.commerceID
JOIN Spaces s ON ct.spaceID = s.spaceID
JOIN Floors f ON s.floorID = f.floorID
JOIN Buildings b ON f.buildingID = b.buildingID

LEFT JOIN (
    SELECT commerceID, MIN(saleDate) as first_sale
    FROM Sales 
    WHERE MONTH(saleDate) = MONTH(CURDATE()) 
      AND YEAR(saleDate) = YEAR(CURDATE())
    GROUP BY commerceID
) MIN_DATE ON c.commerceID = MIN_DATE.commerceID

LEFT JOIN (
    SELECT commerceID, MAX(saleDate) as last_sale
    FROM Sales 
    WHERE MONTH(saleDate) = MONTH(CURDATE()) 
      AND YEAR(saleDate) = YEAR(CURDATE())
    GROUP BY commerceID
) MAX_DATE ON c.commerceID = MAX_DATE.commerceID

LEFT JOIN (
    SELECT sa.commerceID, SUM(sd.quantity) as items_sold
    FROM Sales sa
    JOIN SaleDetails sd ON sa.saleID = sd.saleID
    WHERE MONTH(sa.saleDate) = MONTH(CURDATE()) 
      AND YEAR(sa.saleDate) = YEAR(CURDATE())
    GROUP BY sa.commerceID
) ITEMS ON c.commerceID = ITEMS.commerceID

LEFT JOIN (
    SELECT commerceID, SUM(totalAmount) as total_sales_amount
    FROM Sales 
    WHERE MONTH(saleDate) = MONTH(CURDATE()) 
      AND YEAR(saleDate) = YEAR(CURDATE())
    GROUP BY commerceID
) SALES ON c.commerceID = SALES.commerceID

WHERE c.isActive = 1 
ORDER BY b.name, s.name, c.name;