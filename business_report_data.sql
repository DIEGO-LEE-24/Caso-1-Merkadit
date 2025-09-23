CREATE OR REPLACE VIEW BusinessReportView AS
SELECT 
    c.name AS business_name,
    s.name AS space_name,
    b.name AS building_name,
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
    SELECT commerceID, SUM(totalAmount) as total_sales_amount
    FROM Sales 
    WHERE MONTH(saleDate) = MONTH(CURDATE()) 
      AND YEAR(saleDate) = YEAR(CURDATE())
    GROUP BY commerceID
) SALES ON c.commerceID = SALES.commerceID
WHERE c.isActive = 1;