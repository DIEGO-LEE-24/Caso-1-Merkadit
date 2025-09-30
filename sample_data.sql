-- =====================================================
-- SAMPLE DATA FOR MERKADIT DATABASE
-- =====================================================

USE merkadit;

-- Disable foreign key checks for insertion
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. BASIC DATA: COUNTRIES, STATES, CITIES
-- =====================================================

INSERT INTO Countries (countryID, name) VALUES 
(1, 'Costa Rica');

INSERT INTO States (stateID, name, countryID) VALUES 
(1, 'San José', 1),
(2, 'Cartago', 1);

INSERT INTO Cities (cityID, name, stateID) VALUES 
(1, 'San José Centro', 1),
(2, 'Escazú', 1),
(3, 'Cartago Centro', 2),
(4, 'Paraíso', 2);

-- =====================================================
-- 2. ADDRESSES FOR BUILDINGS
-- =====================================================

INSERT INTO Addresses (addressID, line1, line2, zipCode, cityID) VALUES 
(1, 'Avenida Central, Calle 5', 'Frente al Banco Nacional', '10101', 1),
(2, 'Calle Principal #45', 'Plaza Comercial Este', '20201', 3);

-- =====================================================
-- 3. CURRENCIES AND EXCHANGE RATES
-- =====================================================

INSERT INTO Currencies (currencyID, name, isoCode, currencySymbol, countryID) VALUES 
(1, 'Colón Costarricense', 'CRC', '₡', 1),
(2, 'US Dollar', 'USD', '$', 1);

INSERT INTO ExchangeRates (exchangeRateID, startDate, endDate, exchangeRate, currencySourceID, currencyDestinyID, current) VALUES 
(1, '2024-01-01', NULL, 530.00, 2, 1, 1);

-- =====================================================
-- 4. USER TYPES AND PERMISSIONS
-- =====================================================

INSERT INTO ContactTypes (contactTypeID, name) VALUES 
(1, 'Mobile'),
(2, 'Email'),
(3, 'WhatsApp');

INSERT INTO Roles (roleID, name, description) VALUES 
(1, 'Administrator', 'Full system access'),
(2, 'Tenant', 'Commerce owner with POS access'),
(3, 'Cashier', 'POS operation only');

-- =====================================================
-- 5. USERS (Admin and Tenants)
-- =====================================================

INSERT INTO Users (userID, firstName, lastName, passwordHash, isActive) VALUES 
(1, 'Carlos', 'Rodríguez', 0x1234567890ABCDEF, 1),  -- Admin Building 1
(2, 'María', 'González', 0x1234567890ABCDEF, 1),    -- Admin Building 2
(3, 'Juan', 'Pérez', 0x1234567890ABCDEF, 1),        -- Tenant
(4, 'Ana', 'López', 0x1234567890ABCDEF, 1),         -- Tenant
(5, 'Pedro', 'Vargas', 0x1234567890ABCDEF, 1),      -- Tenant
(6, 'Laura', 'Soto', 0x1234567890ABCDEF, 1),        -- Tenant
(7, 'Diego', 'Mora', 0x1234567890ABCDEF, 1),        -- Tenant
(8, 'Sofia', 'Jiménez', 0x1234567890ABCDEF, 1);     -- Tenant

INSERT INTO UserXRoles (userID, roleID, enabled) VALUES 
(1, 1, 1), (2, 1, 1),  -- Admins
(3, 2, 1), (4, 2, 1), (5, 2, 1), (6, 2, 1), (7, 2, 1), (8, 2, 1);  -- Tenants

-- =====================================================
-- 6. BUILDINGS (2 required)
-- =====================================================

INSERT INTO Buildings (buildingID, name, totalArea, floors, openingTime, closingTime, adminUserID, addressID, initialInvestment) VALUES 
(1, 'Mercado Central San José', 5000.00, 2, '06:00:00', '20:00:00', 1, 1, 5000000.00),
(2, 'Plaza Comercial Cartago', 3500.00, 1, '07:00:00', '21:00:00', 2, 2, 3500000.00);

-- =====================================================
-- 7. FLOORS
-- =====================================================

INSERT INTO Floors (floorID, buildingID, name, floorNumber) VALUES 
(1, 1, 'Planta Baja', 1),
(2, 1, 'Segundo Piso', 2),
(3, 2, 'Planta Principal', 1);

-- =====================================================
-- 8. SPACE TYPES AND STATUS
-- =====================================================

INSERT INTO SpaceTypes (spaceTypeID, name, description) VALUES 
(1, 'Food Stall', 'Small food service space'),
(2, 'Kiosk', 'Small retail kiosk'),
(3, 'Restaurant', 'Full service restaurant');

INSERT INTO SpaceStatus (statusID, name) VALUES 
(1, 'Available'),
(2, 'Occupied'),
(3, 'Under Renovation');

-- =====================================================
-- 9. SPACES (1 in building 1, 2 in building 2)
-- =====================================================

INSERT INTO Spaces (spaceID, floorID, spaceCode, name, area, spaceTypeID, spaceStatusID, baseRent) VALUES 
(1, 1, 'A-101', 'Local Esquina Norte', 50.00, 3, 2, 500000.00),  -- Building 1
(2, 3, 'B-201', 'Kiosko Central', 20.00, 2, 2, 200000.00),       -- Building 2
(3, 3, 'B-202', 'Local Sur', 35.00, 1, 2, 350000.00);           -- Building 2

-- =====================================================
-- 10. COMMERCE TYPES
-- =====================================================

INSERT INTO CommerceTypes (commerceTypeID, name) VALUES 
(1, 'Restaurant'),
(2, 'Clothing'),
(3, 'Electronics'),
(4, 'Groceries'),
(5, 'Jewelry');

-- =====================================================
-- 11. COMMERCES (4-7 per space randomly)
-- Space 1: 5 commerces, Space 2: 4 commerces, Space 3: 6 commerces
-- =====================================================

INSERT INTO Commerces (commerceID, name, legalName, taxID, commerceTypeID, ownerUserID, isActive) VALUES 
-- Historical commerces for Space 1 (Building 1)
(1, 'Restaurante El Sabor', 'El Sabor S.A.', '3101234567', 1, 3, 1),
(2, 'Café Central', 'Café Central Ltda.', '3101234568', 1, 4, 0),
(3, 'Comida China Express', 'China Express S.A.', '3101234569', 1, 5, 0),
(4, 'Pizza Italiana', 'Pizza IT S.A.', '3101234570', 1, 6, 0),
(5, 'Soda Tica', 'Soda Tradicional S.A.', '3101234571', 1, 7, 1),

-- Historical commerces for Space 2 (Building 2)
(6, 'Joyería Brillante', 'Brillante S.A.', '3101234572', 5, 8, 0),
(7, 'Bisutería Moderna', 'Bisutería M S.A.', '3101234573', 5, 3, 0),
(8, 'Accesorios Fashion', 'Fashion Acc S.A.', '3101234574', 2, 4, 1),
(9, 'Relojería Suiza', 'Reloj Suiza S.A.', '3101234575', 5, 5, 0),

-- Historical commerces for Space 3 (Building 2)
(10, 'Minisuper Express', 'Super Express S.A.', '3101234576', 4, 6, 0),
(11, 'Verdulería Fresh', 'Fresh Vegetables S.A.', '3101234577', 4, 7, 1),
(12, 'Carnicería Don Juan', 'Carnes DJ S.A.', '3101234578', 4, 8, 0),
(13, 'Panadería Artesanal', 'Pan Artesanal S.A.', '3101234579', 4, 3, 0),
(14, 'Heladería Tropical', 'Helados Trop S.A.', '3101234580', 1, 4, 0),
(15, 'Abarrotes La Esquina', 'Abarrotes LE S.A.', '3101234581', 4, 5, 1);

-- =====================================================
-- 12. CONTRACT STATUS AND SCHEDULES
-- =====================================================

INSERT INTO ContractStatus (contractStatusID, name) VALUES 
(1, 'Active'),
(2, 'Expired'),
(3, 'Cancelled');

INSERT INTO ScheduleRecurrencies (scheduleRecurrencyID, name, intervalDays) VALUES 
(1, 'Monthly', 30),
(2, 'Weekly', 7);

INSERT INTO Schedules (scheduleID, scheduleRecurrencyID, startDate, endDate, nextExecute, enabled) VALUES 
(1, 1, '2024-01-01', '2024-12-31', '2024-09-01', 1),
(2, 1, '2024-01-01', '2024-12-31', '2024-09-01', 1),
(3, 1, '2024-01-01', '2024-12-31', '2024-09-01', 1);

-- =====================================================
-- 13. CONTRACTS (Active contracts only)
-- =====================================================

INSERT INTO Contracts (contractID, contractNumber, commerceID, spaceID, startDate, endDate, baseRent, currencyID, commissionPercentage, scheduleID, contractStatusID, createdBy) VALUES 
-- Active contracts
(1, 'CTR-2024-001', 1, 1, '2024-01-01', '2024-12-31', 500000.00, 1, 5.00, 1, 1, 1),
(2, 'CTR-2024-002', 5, 1, '2024-06-01', '2025-05-31', 500000.00, 1, 5.00, 1, 1, 1),
(3, 'CTR-2024-003', 8, 2, '2024-03-01', '2025-02-28', 200000.00, 1, 3.00, 2, 1, 2),
(4, 'CTR-2024-004', 11, 3, '2024-01-15', '2025-01-14', 350000.00, 1, 4.00, 3, 1, 2),
(5, 'CTR-2024-005', 15, 3, '2024-04-01', '2025-03-31', 350000.00, 1, 4.00, 3, 1, 2);

-- =====================================================
-- 14. CATEGORIES FOR PRODUCTS (with commission rates)
-- =====================================================

INSERT INTO Categories (categoryID, name, description) VALUES 
(1, 'Bebidas', 'Beverages and drinks'),
(2, 'Comida Preparada', 'Prepared food'),
(3, 'Abarrotes', 'Groceries including honey, vinegars'),
(4, 'Carnes', 'Meat products'),
(5, 'Accesorios', 'Accessories'),
(6, 'Licores', 'Imported wines and premium liquors'),
(7, 'Electrónicos', 'Electronics, drones, expensive equipment');

-- Add commission percentages to categories (Professor's suggestion)
ALTER TABLE Categories ADD COLUMN defaultCommissionPercentage DECIMAL(5,2) DEFAULT 5.00;

-- Update commission rates based on product value/type
UPDATE Categories SET defaultCommissionPercentage = 5.00 WHERE categoryID = 1; -- Bebidas normal
UPDATE Categories SET defaultCommissionPercentage = 4.00 WHERE categoryID = 2; -- Comida preparada
UPDATE Categories SET defaultCommissionPercentage = 7.00 WHERE categoryID = 3; -- Abarrotes (honey, vinegars - low value)
UPDATE Categories SET defaultCommissionPercentage = 6.00 WHERE categoryID = 4; -- Carnes
UPDATE Categories SET defaultCommissionPercentage = 4.00 WHERE categoryID = 5; -- Accesorios
UPDATE Categories SET defaultCommissionPercentage = 3.00 WHERE categoryID = 6; -- Licores caros
UPDATE Categories SET defaultCommissionPercentage = 2.00 WHERE categoryID = 7; -- Electrónicos caros

-- =====================================================
-- 15. PRODUCTS FOR 3 BUSINESSES (with inventory)
-- Commerce 1 (Restaurant), Commerce 8 (Accessories), Commerce 11 (Grocery)
-- =====================================================

-- Products for Commerce 1 (Restaurante El Sabor)
INSERT INTO Products (productID, commerceID, sku, name, description, categoryID, currencyID, stockQuantity, minStock, maxStock) VALUES 
(1, 1, 'BEB-001', 'Coca Cola 500ml', 'Refresco gaseoso', 1, 1, 100, 20, 200),
(2, 1, 'BEB-002', 'Agua Mineral', 'Agua sin gas', 1, 1, 150, 30, 300),
(3, 1, 'COM-001', 'Casado con Pollo', 'Plato típico', 2, 1, 50, 10, 100),
(4, 1, 'COM-002', 'Casado con Carne', 'Plato típico', 2, 1, 50, 10, 100),
(5, 1, 'COM-003', 'Sopa del Día', 'Sopa variable', 2, 1, 30, 10, 60);

-- Products for Commerce 8 (Accesorios Fashion)
INSERT INTO Products (productID, commerceID, sku, name, description, categoryID, currencyID, stockQuantity, minStock, maxStock) VALUES 
(6, 8, 'ACC-001', 'Collar Plata', 'Collar de plata 925', 5, 1, 20, 5, 50),
(7, 8, 'ACC-002', 'Pulsera Cuero', 'Pulsera de cuero genuino', 5, 1, 30, 10, 60),
(8, 8, 'ACC-003', 'Aretes Perla', 'Aretes con perlas cultivadas', 5, 1, 15, 5, 30),
(9, 8, 'ACC-004', 'Bufanda Seda', 'Bufanda de seda natural', 5, 1, 25, 10, 50);

-- Products for Commerce 11 (Verdulería Fresh)
INSERT INTO Products (productID, commerceID, sku, name, description, categoryID, currencyID, stockQuantity, minStock, maxStock) VALUES 
(10, 11, 'VEG-001', 'Tomate kg', 'Tomate fresco', 3, 1, 50, 20, 100),
(11, 11, 'VEG-002', 'Lechuga unidad', 'Lechuga fresca', 3, 1, 40, 15, 80),
(12, 11, 'VEG-003', 'Papa kg', 'Papa blanca', 3, 1, 100, 30, 200),
(13, 11, 'VEG-004', 'Cebolla kg', 'Cebolla blanca', 3, 1, 60, 20, 120),
(14, 11, 'VEG-005', 'Zanahoria kg', 'Zanahoria fresca', 3, 1, 45, 15, 90);

-- =====================================================
-- 16. PRICE HISTORY
-- =====================================================

INSERT INTO PriceHistory (priceHistoryID, productID, price, cost, currencyID, isCurrent, createdDate) VALUES 
-- Commerce 1 prices
(1, 1, 1500.00, 800.00, 1, 1, '2024-01-01'),
(2, 2, 1000.00, 500.00, 1, 1, '2024-01-01'),
(3, 3, 5000.00, 2500.00, 1, 1, '2024-01-01'),
(4, 4, 5500.00, 2800.00, 1, 1, '2024-01-01'),
(5, 5, 3500.00, 1800.00, 1, 1, '2024-01-01'),
-- Commerce 8 prices
(6, 6, 25000.00, 12000.00, 1, 1, '2024-01-01'),
(7, 7, 15000.00, 7000.00, 1, 1, '2024-01-01'),
(8, 8, 18000.00, 9000.00, 1, 1, '2024-01-01'),
(9, 9, 22000.00, 11000.00, 1, 1, '2024-01-01'),
-- Commerce 11 prices
(10, 10, 2500.00, 1500.00, 1, 1, '2024-01-01'),
(11, 11, 1200.00, 700.00, 1, 1, '2024-01-01'),
(12, 12, 1800.00, 1000.00, 1, 1, '2024-01-01'),
(13, 13, 2000.00, 1200.00, 1, 1, '2024-01-01'),
(14, 14, 2200.00, 1300.00, 1, 1, '2024-01-01');

-- =====================================================
-- 17. PAYMENT METHODS AND CUSTOMER TYPES
-- =====================================================

INSERT INTO PaymentMethods (paymentMethodID, name, code, requiresReference, processingFee) VALUES 
(1, 'Efectivo', 'CASH', 0, 0.00),
(2, 'Tarjeta Crédito', 'CC', 1, 2.50),
(3, 'Tarjeta Débito', 'DC', 1, 1.50),
(4, 'Sinpe Móvil', 'SINPE', 1, 0.00);

INSERT INTO CustomerTypes (customerTypeID, name) VALUES 
(1, 'Individual'),
(2, 'Company');

-- =====================================================
-- 18. SAMPLE CUSTOMERS
-- =====================================================

INSERT INTO Customers (customerID, customerTypeID, name, taxID) VALUES 
(1, 1, 'Cliente General', NULL),
(2, 1, 'José Ramírez', '105430234'),
(3, 1, 'Carmen Solís', '203450678'),
(4, 2, 'Empresa ABC S.A.', '3101234590'),
(5, 1, 'Roberto Quesada', '106780234');

-- =====================================================
-- 19. SALE STATUS
-- =====================================================

INSERT INTO SaleStatus (saleStatusID, name) VALUES 
(1, 'Completed'),
(2, 'Cancelled'),
(3, 'Pending');

-- =====================================================
-- 20. STORED PROCEDURE FOR GENERATING RANDOM SALES
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS GenerateRandomSales//

CREATE PROCEDURE GenerateRandomSales()
BEGIN
    DECLARE v_date DATE;
    DECLARE v_commerce INT;
    DECLARE v_product INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(16,2);
    DECLARE v_customer INT;
    DECLARE v_payment INT;
    DECLARE v_invoice VARCHAR(50);
    DECLARE v_saleID INT;
    DECLARE v_month INT;
    DECLARE v_salesCount INT;
    DECLARE v_salesInMonth INT;
    DECLARE v_dayOfMonth INT;
    DECLARE i INT;
    DECLARE j INT;
    DECLARE v_subtotal DECIMAL(16,2);
    DECLARE v_productsInSale INT;
    
    -- Process 4 months: May, June, July, August 2024
    SET v_month = 5;
    
    WHILE v_month <= 8 DO
        -- Determine number of sales for this month (50-70 randomly)
        SET v_salesInMonth = FLOOR(50 + RAND() * 21);
        SET i = 1;
        
        WHILE i <= v_salesInMonth DO
            -- Generate random day of month
            SET v_dayOfMonth = FLOOR(1 + RAND() * 28);
            SET v_date = STR_TO_DATE(CONCAT('2024-', LPAD(v_month, 2, '0'), '-', LPAD(v_dayOfMonth, 2, '0')), '%Y-%m-%d');
            
            -- Select random commerce (from the 3 with inventory)
            SET @rand = RAND();
            IF @rand < 0.4 THEN
                SET v_commerce = 1;  -- Restaurant
            ELSEIF @rand < 0.7 THEN
                SET v_commerce = 8;  -- Accessories
            ELSE
                SET v_commerce = 11; -- Grocery
            END IF;
            
            -- Random customer and payment method
            SET v_customer = FLOOR(1 + RAND() * 5);
            SET v_payment = FLOOR(1 + RAND() * 4);
            SET v_invoice = CONCAT('FAC-2024-', LPAD(v_month, 2, '0'), '-', LPAD(i, 4, '0'));
            
            -- Insert sale header
            INSERT INTO Sales (commerceID, invoiceNumber, saleDate, customerID, 
                             subtotal, discountAmount, taxAmount, totalAmount, 
                             currencyID, userID, paymentMethodID, saleStatusID)
            VALUES (v_commerce, v_invoice, v_date, v_customer, 
                   0, 0, 0, 0, 1, 3, v_payment, 1);
            
            SET v_saleID = LAST_INSERT_ID();
            
            -- Add 1-3 products to each sale
            SET v_productsInSale = FLOOR(1 + RAND() * 3);
            SET j = 1;
            SET v_subtotal = 0;
            
            WHILE j <= v_productsInSale DO
                -- Select random product based on commerce
                IF v_commerce = 1 THEN
                    -- Restaurant products (1-5)
                    SET v_product = FLOOR(1 + RAND() * 5);
                ELSEIF v_commerce = 8 THEN
                    -- Accessories products (6-9)
                    SET v_product = FLOOR(6 + RAND() * 4);
                ELSE
                    -- Grocery products (10-14)
                    SET v_product = FLOOR(10 + RAND() * 5);
                END IF;
                
                -- Random quantity (1-5 for food, 1-2 for accessories)
                IF v_commerce = 8 THEN
                    SET v_quantity = FLOOR(1 + RAND() * 2);
                ELSE
                    SET v_quantity = FLOOR(1 + RAND() * 5);
                END IF;
                
                -- Get current price
                SELECT price INTO v_price 
                FROM PriceHistory 
                WHERE productID = v_product AND isCurrent = 1
                LIMIT 1;
                
                -- Insert sale detail
                INSERT INTO SaleDetails (saleID, productID, unitPrice, quantity, 
                                       discountAmount, subtotal)
                VALUES (v_saleID, v_product, v_price, v_quantity, 
                       0, v_price * v_quantity);
                
                SET v_subtotal = v_subtotal + (v_price * v_quantity);
                
                -- Update product stock (decrease)
                UPDATE Products 
                SET stockQuantity = stockQuantity - v_quantity 
                WHERE productID = v_product;
                
                SET j = j + 1;
            END WHILE;
            
            -- Update sale totals
            UPDATE Sales 
            SET subtotal = v_subtotal,
                taxAmount = v_subtotal * 0.13,
                totalAmount = v_subtotal * 1.13
            WHERE saleID = v_saleID;
            
            SET i = i + 1;
        END WHILE;
        
        -- Move to next month
        SET v_month = v_month + 1;
    END WHILE;
    
    -- Restore inventory levels to avoid negative stock
    UPDATE Products p
    SET stockQuantity = (
        SELECT COUNT(*) * 10 
        FROM SaleDetails sd 
        WHERE sd.productID = p.productID
    )
    WHERE commerceID IN (1, 8, 11);
    
END//

DELIMITER ;

-- =====================================================
-- 21. MOVEMENT TYPES FOR INVENTORY
-- =====================================================

INSERT INTO MovementTypes (movementTypeID, name) VALUES 
(1, 'IN'),
(2, 'OUT'),
(3, 'ADJUSTMENT'),
(4, 'RETURN');

-- =====================================================
-- 22. LOGS TYPES, LEVELS, SOURCES
-- =====================================================

INSERT INTO LogLevels (logLevelID, name) VALUES 
(1, 'INFO'),
(2, 'WARN'),
(3, 'ERROR'),
(4, 'DEBUG');

INSERT INTO LogTypes (logTypeID, name) VALUES 
(1, 'SALES'),
(2, 'SETTLEMENTS');

INSERT INTO LogSources (logSourceID, name) VALUES 
(1, 'FRONTEND'),
(2, 'SERVICES'),
(4, 'DATABASE');

-- =====================================================
-- EXECUTE THE SALES GENERATION
-- =====================================================

-- Generate all random sales
CALL GenerateRandomSales();

-- =====================================================
-- 22. GENERATE INVENTORY MOVEMENTS FROM SALES
-- =====================================================

INSERT INTO InventoryMovements (productID, movementTypeID, stockQuantity, 
                               referenceDescription, referenceID, movementDate, createdBy)
SELECT 
    sd.productID,
    2, -- OUT
    -sd.quantity,
    CONCAT('Sale #', s.invoiceNumber),
    s.saleID,
    s.saleDate,
    'System'
FROM SaleDetails sd
JOIN Sales s ON sd.saleID = s.saleID;

-- =====================================================
-- 23. CONTRACT CATEGORY COMMISSIONS (Professor's suggestion)
-- =====================================================

-- Create table for category-specific commission rates per contract
CREATE TABLE ContractCategoryCommissions (
    contractID INT NOT NULL,
    categoryID INT NOT NULL,
    commissionPercentage DECIMAL(5,2) NOT NULL,
    negotiatedDate DATE DEFAULT (CURDATE()),
    isActive BIT DEFAULT 1,
    PRIMARY KEY (contractID, categoryID),
    FOREIGN KEY (contractID) REFERENCES Contracts(contractID),
    FOREIGN KEY (categoryID) REFERENCES Categories(categoryID)
) ENGINE = InnoDB;

-- Sample negotiated rates for specific contracts and categories
INSERT INTO ContractCategoryCommissions (contractID, categoryID, commissionPercentage) VALUES
-- Contract 1 (Restaurant): negotiated lower rate for liquors
(1, 6, 3.00),  -- Licores at 3% instead of default
-- Contract 3 (Accessories): negotiated higher rate for electronics
(3, 7, 2.50),  -- Electronics at 2.5% instead of default 2%
-- Contract 4 (Grocery): negotiated rate for honey/vinegars
(4, 3, 6.50); -- Abarrotes at 6.5% instead of default 7%

-- =====================================================
-- 24. GENERATE SAMPLE SETTLEMENTS
-- =====================================================

INSERT INTO SettlementStatus (settlementStatusID, name) VALUES 
(1, 'Pending'),
(2, 'Paid'),
(3, 'Overdue');

-- Generate settlements for completed months (May, June, July)
-- Now using category-based commissions when available
INSERT INTO Settlements (contractID, scheduleID, baseRentAmount, totalSales, 
                        commissionAmount, totalAmount, currencyID, 
                        settlementDate, settlementStatusID, paidDate, createdBy)
SELECT 
    c.contractID,
    c.scheduleID,
    c.baseRent,
    COALESCE(SUM(s.totalAmount), 0) as totalSales,
    COALESCE(SUM(
        s.totalAmount * 
        COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, c.commissionPercentage) / 100
    ), 0) as commission,
    c.baseRent + COALESCE(SUM(
        s.totalAmount * 
        COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, c.commissionPercentage) / 100
    ), 0) as total,
    1,
    LAST_DAY(DATE(CONCAT('2024-', LPAD(m.month, 2, '0'), '-01'))),
    2, -- Paid
    LAST_DAY(DATE(CONCAT('2024-', LPAD(m.month, 2, '0'), '-01'))),
    1
FROM Contracts c
CROSS JOIN (SELECT 5 as month UNION SELECT 6 UNION SELECT 7) m
LEFT JOIN Sales s ON s.commerceID = c.commerceID 
    AND MONTH(s.saleDate) = m.month 
    AND YEAR(s.saleDate) = 2024
LEFT JOIN SaleDetails sd ON s.saleID = sd.saleID
LEFT JOIN Products p ON sd.productID = p.productID
LEFT JOIN Categories cat ON p.categoryID = cat.categoryID
LEFT JOIN ContractCategoryCommissions ccc ON c.contractID = ccc.contractID 
    AND cat.categoryID = ccc.categoryID 
    AND ccc.isActive = 1
WHERE c.contractStatusID = 1
GROUP BY c.contractID, m.month;

-- =====================================================
-- 25. REPORTING VIEWS (Replace heavy report tables)
-- =====================================================

-- View for commerce sales report (Professor's suggestion: dynamic reporting)
CREATE VIEW ReportCommercesSales AS
SELECT 
    c.commerceID,
    c.name as commerce_name,
    c.legalName,
    s.name as space_name,
    b.name as building_name,
    MONTH(sa.saleDate) as report_month,
    YEAR(sa.saleDate) as report_year,
    COUNT(sa.saleID) as total_transactions,
    SUM(sa.totalAmount) as monthly_sales,
    SUM(sa.totalAmount * COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, ct.commissionPercentage) / 100) as commission_amount,
    ct.baseRent as rent_amount,
    ct.baseRent + SUM(sa.totalAmount * COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, ct.commissionPercentage) / 100) as total_due
FROM Sales sa
JOIN Commerces c ON sa.commerceID = c.commerceID
JOIN Contracts ct ON c.commerceID = ct.commerceID AND ct.contractStatusID = 1
JOIN Spaces s ON ct.spaceID = s.spaceID
JOIN Floors f ON s.floorID = f.floorID
JOIN Buildings b ON f.buildingID = b.buildingID
LEFT JOIN SaleDetails sd ON sa.saleID = sd.saleID
LEFT JOIN Products p ON sd.productID = p.productID
LEFT JOIN Categories cat ON p.categoryID = cat.categoryID
LEFT JOIN ContractCategoryCommissions ccc ON ct.contractID = ccc.contractID 
    AND cat.categoryID = ccc.categoryID 
    AND ccc.isActive = 1
GROUP BY c.commerceID, YEAR(sa.saleDate), MONTH(sa.saleDate);

-- View for building financial summary
CREATE VIEW ReportBuildingFinancials AS
SELECT 
    b.buildingID,
    b.name as building_name,
    b.adminUserID,
    CONCAT(u.firstName, ' ', u.lastName) as administrator_name,
    MONTH(sa.saleDate) as report_month,
    YEAR(sa.saleDate) as report_year,
    COUNT(DISTINCT c.commerceID) as active_commerces,
    SUM(sa.totalAmount) as total_building_sales,
    SUM(sa.totalAmount * COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, ct.commissionPercentage) / 100) as total_commissions,
    SUM(ct.baseRent) as total_base_rent,
    SUM(ct.baseRent + sa.totalAmount * COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage, ct.commissionPercentage) / 100) as total_revenue
FROM Buildings b
JOIN Users u ON b.adminUserID = u.userID
JOIN Floors f ON b.buildingID = f.buildingID
JOIN Spaces s ON f.floorID = s.floorID
JOIN Contracts ct ON s.spaceID = ct.spaceID AND ct.contractStatusID = 1
JOIN Commerces c ON ct.commerceID = c.commerceID
JOIN Sales sa ON c.commerceID = sa.commerceID
LEFT JOIN SaleDetails sd ON sa.saleID = sd.saleID
LEFT JOIN Products p ON sd.productID = p.productID
LEFT JOIN Categories cat ON p.categoryID = cat.categoryID
LEFT JOIN ContractCategoryCommissions ccc ON ct.contractID = ccc.contractID 
    AND cat.categoryID = ccc.categoryID 
    AND ccc.isActive = 1
GROUP BY b.buildingID, YEAR(sa.saleDate), MONTH(sa.saleDate);

-- View for product category performance
CREATE VIEW ReportCategoryPerformance AS
SELECT 
    cat.categoryID,
    cat.name as category_name,
    cat.defaultCommissionPercentage,
    MONTH(sa.saleDate) as report_month,
    YEAR(sa.saleDate) as report_year,
    COUNT(sd.saleDetailID) as items_sold,
    SUM(sd.quantity) as total_quantity,
    SUM(sd.subtotal) as total_sales,
    AVG(sd.unitPrice) as avg_price,
    SUM(sd.subtotal * COALESCE(ccc.commissionPercentage, cat.defaultCommissionPercentage) / 100) as total_commissions
FROM Categories cat
JOIN Products p ON cat.categoryID = p.categoryID
JOIN SaleDetails sd ON p.productID = sd.productID
JOIN Sales sa ON sd.saleID = sa.saleID
JOIN Commerces c ON sa.commerceID = c.commerceID
JOIN Contracts ct ON c.commerceID = ct.commerceID AND ct.contractStatusID = 1
LEFT JOIN ContractCategoryCommissions ccc ON ct.contractID = ccc.contractID 
    AND cat.categoryID = ccc.categoryID 
    AND ccc.isActive = 1
GROUP BY cat.categoryID, YEAR(sa.saleDate), MONTH(sa.saleDate);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Verify data insertion
SELECT 'Buildings' as Table_Name, COUNT(*) as Record_Count FROM Buildings
UNION ALL
SELECT 'Spaces', COUNT(*) FROM Spaces
UNION ALL
SELECT 'Commerces', COUNT(*) FROM Commerces
UNION ALL
SELECT 'Contracts', COUNT(*) FROM Contracts
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales;