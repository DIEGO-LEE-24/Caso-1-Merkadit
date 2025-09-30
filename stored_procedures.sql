-- =====================================================
-- MERKADIT STORED PROCEDURES - MySQL Version (Simplified)
-- =====================================================

USE merkadit;

-- =====================================================
-- SP_registerSale - Register a sale with inventory update
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS SP_registerSale
//

CREATE PROCEDURE SP_registerSale(
    IN p_commerceID INT,
    IN p_customerID INT,
    IN p_paymentMethodID TINYINT,
    IN p_paymentReference VARCHAR(100),
    IN p_discountAmount DECIMAL(16,2),
    IN p_products JSON,
    IN p_computer VARCHAR(50),
    IN p_username VARCHAR(50),
    OUT p_saleID INT,
    OUT p_totalAmount DECIMAL(16,2),
    OUT p_result VARCHAR(200)
)
sp_main: BEGIN
    DECLARE v_invoiceNumber VARCHAR(50);
    DECLARE v_subtotal DECIMAL(16,2) DEFAULT 0;
    DECLARE v_taxAmount DECIMAL(16,2);
    DECLARE v_stockAvailable INT;
    DECLARE v_lineSubtotal DECIMAL(16,2);
    DECLARE v_userID INT DEFAULT 3;
    
    DECLARE v_currentProductId INT;
    DECLARE v_currentQuantity INT;
    DECLARE v_currentUnitPrice DECIMAL(16,2);
    DECLARE v_totalProducts INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_checksum VARBINARY(250);
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Transaction failed';
        SET v_error_occurred = TRUE;
    END;
    
    -- Initialize output parameters
    SET p_saleID = 0;
    SET p_totalAmount = 0;
    SET p_result = 'Success';
    
    -- Validate inputs
    IF p_commerceID IS NULL OR p_commerceID <= 0 THEN
        SET p_result = 'Error: Invalid commerce ID';
        LEAVE sp_main;
    END IF;
    
    IF JSON_LENGTH(p_products) = 0 OR p_products IS NULL THEN
        SET p_result = 'Error: At least one product must be specified';
        LEAVE sp_main;
    END IF;
    
    -- Verify commerce exists and is active
    IF NOT EXISTS (SELECT 1 FROM Commerces WHERE commerceID = p_commerceID AND isActive = 1) THEN
        SET p_result = 'Error: Commerce not found or inactive';
        LEAVE sp_main;
    END IF;
    
    -- Get user ID
    SELECT userID INTO v_userID FROM Users WHERE firstName = p_username LIMIT 1;
    
    -- Generate invoice number
    SET v_invoiceNumber = CONCAT('FAC-', YEAR(CURDATE()), '-', 
                               LPAD(MONTH(CURDATE()), 2, '0'), '-',
                               LPAD(p_commerceID, 3, '0'), '-',
                               LPAD(FLOOR(RAND() * 9999), 4, '0'));
    
    START TRANSACTION;
    
    -- Check stock for all products
    SET v_totalProducts = JSON_LENGTH(p_products);
    
    WHILE v_i < v_totalProducts DO
    
		SET v_currentProductId = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_products, CONCAT('$[', v_i, '].productID'))) AS UNSIGNED);
		SET v_currentQuantity = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_products, CONCAT('$[', v_i, '].quantity'))) AS UNSIGNED);
    
        IF v_currentProductId IS NOT NULL AND v_currentQuantity > 0 THEN
			SELECT stockQuantity INTO v_stockAvailable
			FROM Products 
			WHERE productID = v_currentProductId AND commerceID = p_commerceID AND isActive = 1;
			
			IF v_stockAvailable IS NULL THEN
				SET p_result = CONCAT('Error: Product ', v_currentProductId, ' not found or inactive');
				ROLLBACK;
				LEAVE sp_main;
			END IF;
			
			IF v_stockAvailable < v_currentQuantity THEN
				SET p_result = CONCAT('Error: Insufficient stock for product ', v_currentProductId, 
									'. Available: ', v_stockAvailable, ', Required: ', v_currentQuantity);
				ROLLBACK;
				LEAVE sp_main;
			END IF;
		END IF;
    
		SET v_i = v_i + 1;
    END WHILE;
    
    -- Insert sale header
    INSERT INTO Sales (
        commerceID, invoiceNumber, saleDate, customerID,
        subtotal, discountAmount, taxAmount, totalAmount,
        currencyID, computer, userID, paymentMethodID,
        paymentReference, saleStatusID
    )
    VALUES (
        p_commerceID, v_invoiceNumber, NOW(), p_customerID,
        0, COALESCE(p_discountAmount, 0), 0, 0,
        1, p_computer, v_userID, p_paymentMethodID,
        p_paymentReference, 1
    );
    
    SET p_saleID = LAST_INSERT_ID();
    
    -- Process all products
    
    SET v_i = 0;
	WHILE v_i < v_totalProducts DO
    
		SET v_currentProductId = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_products, CONCAT('$[', v_i, '].productID'))) AS UNSIGNED);
		SET v_currentQuantity = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_products, CONCAT('$[', v_i, '].quantity'))) AS UNSIGNED);
		SET v_currentUnitPrice = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_products, CONCAT('$[', v_i, '].unitPrice'))) AS DECIMAL(16,2));
    
        IF v_currentProductId IS NOT NULL AND v_currentQuantity > 0 THEN
			SET v_lineSubtotal = v_currentUnitPrice * v_currentQuantity;
			SET v_subtotal = v_subtotal + v_lineSubtotal;
			
			INSERT INTO SaleDetails (saleID, productID, unitPrice, quantity, discountAmount, subtotal)
			VALUES (p_saleID, v_currentProductId, v_currentUnitPrice, v_currentQuantity, 0, v_lineSubtotal);
			
			UPDATE Products 
			SET stockQuantity = stockQuantity - v_currentQuantity
			WHERE productID = v_currentProductId;
			
			INSERT INTO InventoryMovements (
				productID, movementTypeID, stockQuantity,
				referenceDescription, referenceID, movementDate, createdBy
			)
			VALUES (
				v_currentProductId, 2, - v_currentQuantity,
				CONCAT('Sale #', v_invoiceNumber), p_saleID, NOW(), p_username
			);
		END IF;
    
		SET v_i = v_i + 1;
    END WHILE;
    
    -- Calculate totals
    SET v_taxAmount = v_subtotal * 0.13;
    SET p_totalAmount = v_subtotal - COALESCE(p_discountAmount, 0) + v_taxAmount;
    
    -- Update sale totals
    UPDATE Sales 
    SET subtotal = v_subtotal,
        taxAmount = v_taxAmount,
        totalAmount = p_totalAmount
    WHERE saleID = p_saleID;
    
    -- Create checksum
    SET v_checksum = SHA2(CONCAT('Sale registered successfully: ', v_invoiceNumber , p_computer , p_username , 
    p_saleID , p_totalAmount , 1 , 1 , 4), 256);
    -- Log the transaction
    INSERT INTO Logs (
        description, computer, username, 
        ref1ID, value1, logTypeID, logLevelID, logSourceID, checksum
    )
    VALUES (
        CONCAT('Sale registered successfully: ', v_invoiceNumber),
        p_computer, p_username, p_saleID, p_totalAmount,
        1, 4, 4, v_checksum
    );
    
    SET p_result = CONCAT('Sale registered successfully', v_invoiceNumber, 
                         '. Total: ₡', FORMAT(p_totalAmount, 2));
    
    IF v_error_occurred = FALSE THEN
        COMMIT;
    END IF;
    
END
//

-- =====================================================
-- SP_settleCommerce - Monthly settlement calculation
-- =====================================================

DROP PROCEDURE IF EXISTS SP_settleCommerce//

CREATE PROCEDURE SP_settleCommerce(
    IN p_commerceID INT,
    IN p_settlementMonth INT,
    IN p_settlementYear INT,
    IN p_username VARCHAR(50),
    OUT p_settlementID INT,
    OUT p_totalAmount DECIMAL(16,2),
    OUT p_result VARCHAR(200)
)
sp_settle: BEGIN
    DECLARE v_contractID INT;
    DECLARE v_baseRent DECIMAL(16,2);
    DECLARE v_totalSales DECIMAL(16,2) DEFAULT 0;
    DECLARE v_commissionAmount DECIMAL(16,2) DEFAULT 0;
    DECLARE v_commissionRate DECIMAL(5,2);
    DECLARE v_periodStart DATE;
    DECLARE v_periodEnd DATE;
    DECLARE v_scheduleID INT;
    DECLARE v_userID INT DEFAULT 1;
    DECLARE v_checksum VARBINARY(250);
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Transaction failed';
        SET v_error_occurred = TRUE;
    END;
    
    -- Initialize output parameters
    SET p_settlementID = 0;
    SET p_totalAmount = 0;
    SET p_result = 'Success';
    
    -- Validate inputs
    IF p_commerceID IS NULL OR p_commerceID <= 0 THEN
        SET p_result = 'Error: Invalid commerce ID';
        LEAVE sp_settle;
    END IF;
    
    IF p_settlementMonth < 1 OR p_settlementMonth > 12 THEN
        SET p_result = 'Error: Invalid month (1-12)';
        LEAVE sp_settle;
    END IF;
    
    -- Set period dates
    SET v_periodStart = DATE(CONCAT(p_settlementYear, '-', LPAD(p_settlementMonth, 2, '0'), '-01'));
    SET v_periodEnd = LAST_DAY(v_periodStart);
    
    -- Get active contract for commerce
    SELECT contractID, baseRent, scheduleID, commissionPercentage
    INTO v_contractID, v_baseRent, v_scheduleID, v_commissionRate
    FROM Contracts 
    WHERE commerceID = p_commerceID 
    AND contractStatusID = 1
    AND v_periodStart BETWEEN startDate AND endDate
    LIMIT 1;
    
    IF v_contractID IS NULL THEN
        SET p_result = 'Error: No active contract found for this commerce in the specified period';
        LEAVE sp_settle;
    END IF;
    
    -- Check if settlement already exists
    IF EXISTS (
        SELECT 1 FROM Settlements 
        WHERE contractID = v_contractID
        AND MONTH(settlementDate) = p_settlementMonth
        AND YEAR(settlementDate) = p_settlementYear
    ) THEN
        SET p_result = 'Error: Settlement already exists for this period';
        LEAVE sp_settle;
    END IF;
    
    -- Get user ID
    SELECT userID INTO v_userID FROM Users WHERE firstName = p_username LIMIT 1;
    
    START TRANSACTION;
    
    -- Calculate total sales for the period
    SELECT COALESCE(SUM(s.totalAmount), 0)
    INTO v_totalSales
    FROM Sales s
    WHERE s.commerceID = p_commerceID
    AND s.saleDate BETWEEN v_periodStart AND v_periodEnd
    AND s.saleStatusID = 1; -- Only completed sales
    
    -- Calculate commission
    SET v_commissionAmount = v_totalSales * (v_commissionRate / 100);
    SET p_totalAmount = v_baseRent + v_commissionAmount;
    
    -- Insert settlement
    INSERT INTO Settlements (
        contractID, scheduleID, baseRentAmount, totalSales,
        commissionAmount, totalAmount, currencyID,
        settlementDate, settlementStatusID, createdBy
    )
    VALUES (
        v_contractID, v_scheduleID, v_baseRent, v_totalSales,
        v_commissionAmount, p_totalAmount, 1,
        v_periodEnd, 1, v_userID
    );
    
    SET p_settlementID = LAST_INSERT_ID();
    -- Calculate checksum
    SET v_checksum = SHA2(CONCAT('Settlement created for commerce ', p_commerceID , ' - Period: ', 
    DATE_FORMAT(v_periodStart, '%Y-%m-%d'), ' to ', DATE_FORMAT(v_periodEnd, '%Y-%m-%d'),  p_username, 
    p_settlementID, v_contractID, v_totalSales , p_totalAmount , 2 , 1 , 4), 256);
    -- Log the settlement
    INSERT INTO Logs (
        description, username, ref1ID, ref2ID, 
        value1, value2, logTypeID, logLevelID, logSourceID, checksum
    )
    VALUES (
        CONCAT('Settlement created for commerce ', p_commerceID, 
               ' - Period: ', DATE_FORMAT(v_periodStart, '%Y-%m-%d'), 
               ' to ', DATE_FORMAT(v_periodEnd, '%Y-%m-%d')),
        p_username, p_settlementID, v_contractID,
        v_totalSales, p_totalAmount, 2, 1, 4, v_checksum
    );
    
    SET p_result = CONCAT('Settlement created successfully. ',
                         'Sales: ₡', FORMAT(v_totalSales, 2), 
                         ', Commission: ₡', FORMAT(v_commissionAmount, 2),
                         ', Rent: ₡', FORMAT(v_baseRent, 2),
                         ', Total: ₡', FORMAT(p_totalAmount, 2));
    
    IF v_error_occurred = FALSE THEN
        COMMIT;
    END IF;
    
END//

DELIMITER ;

-- =====================================================
-- TEST EXAMPLES (Remove comments to test)
-- =====================================================

/*
-- JSON to insert any amount of products to the sale.
SET @v_products = '[
  { "productID": 1, "quantity": 2, "unitPrice": 1500.00 },
  { "productID": 3, "quantity": 1, "unitPrice": 5000.00 }
]';

-- Test SP_registerSale
CALL SP_registerSale(
    1,           -- p_commerceID (Restaurante El Sabor)
    1,           -- p_customerID  
    1,           -- p_paymentMethodID (Efectivo)
    NULL,        -- p_paymentReference
    0,           -- p_discountAmount
    @v_products,           -- p_products 
    'POS-001',   -- p_computer
    'Juan',      -- p_username
    @saleID,     -- p_saleID OUT
    @totalAmount,-- p_totalAmount OUT
    @result      -- p_result OUT
);

SELECT @saleID as SaleID, @totalAmount as TotalAmount, @result as Result;
SELECT * FROM Logs;
*/

/*
-- Test SP_settleCommerce
CALL SP_settleCommerce(
    1,              -- p_commerceID (Restaurante El Sabor)
    9,              -- p_settlementMonth (September)
    2024,           -- p_settlementYear
    'Carlos',       -- p_username
    @settlementID,  -- p_settlementID OUT
    @totalAmount,   -- p_totalAmount OUT
    @result         -- p_result OUT
);
SELECT @settlementID as SettlementID, @totalAmount as TotalAmount, @result as Result;
SELECT * FROM Logs;

-- Para probar venta
CALL SP_registerSale(1, 1, 1, NULL, 0,  @v_products, 'POS-001', 'Juan', @saleID, @totalAmount, @result);
SELECT @saleID, @totalAmount, @result;

-- Para probar liquidación  
CALL SP_settleCommerce(1, 9, 2024, 'Carlos', @settlementID, @totalAmount, @result);
SELECT @settlementID, @totalAmount, @result;

SELECT @settlementID as SettlementID, @totalAmount as TotalAmount, @result as Result;
*/