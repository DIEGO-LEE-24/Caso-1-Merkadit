-- MySQL Workbench Forward Engineering
-- MERKADIT DATABASE SCHEMA

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema merkadit
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `merkadit`;
CREATE SCHEMA IF NOT EXISTS `merkadit` DEFAULT CHARACTER SET utf8 ;
USE `merkadit` ;

-- =====================================================
-- TABLAS DE ADDRESSES
-- =====================================================

CREATE TABLE IF NOT EXISTS `Countries` (
  `countryID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`countryID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `States` (
  `stateID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `countryID` TINYINT NOT NULL,
  PRIMARY KEY (`stateID`),
  INDEX `fk_States_Countries_idx` (`countryID` ASC),
  CONSTRAINT `fk_States_Countries`
    FOREIGN KEY (`countryID`)
    REFERENCES `Countries` (`countryID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Cities` (
  `cityID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `stateID` INT NOT NULL,
  PRIMARY KEY (`cityID`),
  INDEX `fk_Cities_States_idx` (`stateID` ASC),
  CONSTRAINT `fk_Cities_States`
    FOREIGN KEY (`stateID`)
    REFERENCES `States` (`stateID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Addresses` (
  `addressID` INT NOT NULL AUTO_INCREMENT,
  `line1` VARCHAR(200) NOT NULL,
  `line2` VARCHAR(200) NULL,
  `zipCode` VARCHAR(10) NULL,
  `location` POINT NULL,
  `cityID` INT NOT NULL,
  PRIMARY KEY (`addressID`),
  INDEX `fk_Addresses_Cities_idx` (`cityID` ASC),
  CONSTRAINT `fk_Addresses_Cities`
    FOREIGN KEY (`cityID`)
    REFERENCES `Cities` (`cityID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Currencies` (
  `currencyID` SMALLINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `isoCode` VARCHAR(3) NOT NULL,
  `currencySymbol` VARCHAR(5) NULL,
  `countryID` TINYINT NOT NULL,
  PRIMARY KEY (`currencyID`),
  INDEX `fk_Currencies_Countries_idx` (`countryID` ASC),
  CONSTRAINT `fk_Currencies_Countries`
    FOREIGN KEY (`countryID`)
    REFERENCES `Countries` (`countryID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ExchangeRates` (
  `exchangeRateID` SMALLINT NOT NULL AUTO_INCREMENT,
  `startDate` DATETIME NOT NULL,
  `endDate` DATETIME NULL,
  `exchangeRate` DECIMAL(10,4) NOT NULL,
  `currencySourceID` SMALLINT NOT NULL,
  `currencyDestinyID` SMALLINT NOT NULL,
  `current` BIT DEFAULT 1,
  PRIMARY KEY (`exchangeRateID`),
  INDEX `fk_ExchangeRates_CurrencySource_idx` (`currencySourceID` ASC),
  INDEX `fk_ExchangeRates_CurrencyDestiny_idx` (`currencyDestinyID` ASC),
  CONSTRAINT `fk_ExchangeRates_CurrencySource`
    FOREIGN KEY (`currencySourceID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ExchangeRates_CurrencyDestiny`
    FOREIGN KEY (`currencyDestinyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE USUARIO
-- =====================================================

CREATE TABLE IF NOT EXISTS `Users` (
  `userID` INT NOT NULL AUTO_INCREMENT,
  `firstName` VARCHAR(50) NOT NULL,
  `lastName` VARCHAR(50) NOT NULL,
  `passwordHash` VARBINARY(250) NOT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `lastLogin` DATETIME NULL,
  `isActive` BIT NOT NULL DEFAULT 1,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`userID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `AddressXUsers` (
  `addressXUserID` INT NOT NULL AUTO_INCREMENT,
  `addressID` INT NOT NULL,
  `userID` INT NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `isDefault` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`addressXUserID`),
  INDEX `fk_AddressXUsers_Addresses_idx` (`addressID` ASC),
  INDEX `fk_AddressXUsers_Users_idx` (`userID` ASC),
  CONSTRAINT `fk_AddressXUsers_Addresses`
    FOREIGN KEY (`addressID`)
    REFERENCES `Addresses` (`addressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_AddressXUsers_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ContactTypes` (
  `contactTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`contactTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `UserContacts` (
  `contactID` INT NOT NULL AUTO_INCREMENT,
  `userID` INT NOT NULL,
  `contactTypeID` TINYINT NOT NULL,
  `value` VARCHAR(80) NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`contactID`),
  INDEX `fk_UserContacts_Users_idx` (`userID` ASC),
  INDEX `fk_UserContacts_ContactTypes_idx` (`contactTypeID` ASC),
  CONSTRAINT `fk_UserContacts_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserContacts_ContactTypes`
    FOREIGN KEY (`contactTypeID`)
    REFERENCES `ContactTypes` (`contactTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Roles` (
  `roleID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  `description` VARCHAR(200) NULL,
  PRIMARY KEY (`roleID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `UserXRoles` (
  `userID` INT NOT NULL,
  `roleID` INT NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`userID`, `roleID`),
  INDEX `fk_UserXRoles_Roles_idx` (`roleID` ASC),
  CONSTRAINT `fk_UserXRoles_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_UserXRoles_Roles`
    FOREIGN KEY (`roleID`)
    REFERENCES `Roles` (`roleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Permissions` (
  `permissionID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  `code` VARCHAR(20) NOT NULL,
  `module` VARCHAR(50) NULL,
  PRIMARY KEY (`permissionID`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PermissionXRoles` (
  `permissionID` INT NOT NULL,
  `roleID` INT NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`permissionID`, `roleID`),
  INDEX `fk_PermissionXRoles_Roles_idx` (`roleID` ASC),
  CONSTRAINT `fk_PermissionXRoles_Permissions`
    FOREIGN KEY (`permissionID`)
    REFERENCES `Permissions` (`permissionID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_PermissionXRoles_Roles`
    FOREIGN KEY (`roleID`)
    REFERENCES `Roles` (`roleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE COMERCIOS
-- =====================================================

CREATE TABLE IF NOT EXISTS `CommerceTypes` (
  `commerceTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`commerceTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Commerces` (
  `commerceID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `legalName` VARCHAR(200) NULL,
  `taxID` VARCHAR(30) NULL,
  `commerceTypeID` TINYINT NOT NULL,
  `ownerUserID` INT NOT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `isActive` BIT NOT NULL DEFAULT 1,
  PRIMARY KEY (`commerceID`),
  UNIQUE INDEX `taxID_UNIQUE` (`taxID` ASC),
  INDEX `fk_Commerces_CommerceTypes_idx` (`commerceTypeID` ASC),
  INDEX `fk_Commerces_Users_idx` (`ownerUserID` ASC),
  CONSTRAINT `fk_Commerces_CommerceTypes`
    FOREIGN KEY (`commerceTypeID`)
    REFERENCES `CommerceTypes` (`commerceTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Commerces_Users`
    FOREIGN KEY (`ownerUserID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `CommerceContacts` (
  `commerceXContactID` INT NOT NULL AUTO_INCREMENT,
  `commerceID` INT NOT NULL,
  `contactTypeID` TINYINT NOT NULL,
  `value` VARCHAR(80) NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`commerceXContactID`),
  INDEX `fk_CommerceContacts_Commerces_idx` (`commerceID` ASC),
  INDEX `fk_CommerceContacts_ContactTypes_idx` (`contactTypeID` ASC),
  CONSTRAINT `fk_CommerceContacts_Commerces`
    FOREIGN KEY (`commerceID`)
    REFERENCES `Commerces` (`commerceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CommerceContacts_ContactTypes`
    FOREIGN KEY (`contactTypeID`)
    REFERENCES `ContactTypes` (`contactTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Buildings` (
  `buildingID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `totalArea` DECIMAL(10,2) NULL,
  `floors` TINYINT NULL,
  `openingTime` TIME NULL,
  `closingTime` TIME NULL,
  `adminUserID` INT NOT NULL,
  `addressID` INT NOT NULL,
  `initialInvestment` DECIMAL(15,2) NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`buildingID`),
  INDEX `fk_Buildings_Users_idx` (`adminUserID` ASC),
  INDEX `fk_Buildings_Addresses_idx` (`addressID` ASC),
  CONSTRAINT `fk_Buildings_Users`
    FOREIGN KEY (`adminUserID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Buildings_Addresses`
    FOREIGN KEY (`addressID`)
    REFERENCES `Addresses` (`addressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Floors` (
  `floorID` INT NOT NULL AUTO_INCREMENT,
  `buildingID` INT NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `floorNumber` TINYINT NOT NULL,
  PRIMARY KEY (`floorID`),
  INDEX `fk_Floors_Buildings_idx` (`buildingID` ASC),
  CONSTRAINT `fk_Floors_Buildings`
    FOREIGN KEY (`buildingID`)
    REFERENCES `Buildings` (`buildingID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SpaceTypes` (
  `spaceTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  PRIMARY KEY (`spaceTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SpaceStatus` (
  `statusID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`statusID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Spaces` (
  `spaceID` INT NOT NULL AUTO_INCREMENT,
  `floorID` INT NOT NULL,
  `spaceCode` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `area` DECIMAL(10,2) NULL,
  `spaceTypeID` TINYINT NOT NULL,
  `spaceStatusID` TINYINT NOT NULL,
  `baseRent` DECIMAL(16,2) NOT NULL,
  PRIMARY KEY (`spaceID`),
  INDEX `fk_Spaces_Floors_idx` (`floorID` ASC),
  INDEX `fk_Spaces_SpaceTypes_idx` (`spaceTypeID` ASC),
  INDEX `fk_Spaces_SpaceStatus_idx` (`spaceStatusID` ASC),
  CONSTRAINT `fk_Spaces_Floors`
    FOREIGN KEY (`floorID`)
    REFERENCES `Floors` (`floorID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Spaces_SpaceTypes`
    FOREIGN KEY (`spaceTypeID`)
    REFERENCES `SpaceTypes` (`spaceTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Spaces_SpaceStatus`
    FOREIGN KEY (`spaceStatusID`)
    REFERENCES `SpaceStatus` (`statusID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE CONTRATOS
-- =====================================================

CREATE TABLE IF NOT EXISTS `ScheduleRecurrencies` (
  `scheduleRecurrencyID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `intervalDays` INT NOT NULL,
  PRIMARY KEY (`scheduleRecurrencyID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Schedules` (
  `scheduleID` INT NOT NULL AUTO_INCREMENT,
  `scheduleRecurrencyID` TINYINT NOT NULL,
  `startDate` DATETIME NOT NULL,
  `endDate` DATETIME NULL,
  `lastExecute` DATETIME NULL,
  `nextExecute` DATETIME NOT NULL,
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`scheduleID`),
  INDEX `fk_Schedules_ScheduleRecurrencies_idx` (`scheduleRecurrencyID` ASC),
  CONSTRAINT `fk_Schedules_ScheduleRecurrencies`
    FOREIGN KEY (`scheduleRecurrencyID`)
    REFERENCES `ScheduleRecurrencies` (`scheduleRecurrencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ContractStatus` (
  `contractStatusID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`contractStatusID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Contracts` (
  `contractID` INT NOT NULL AUTO_INCREMENT,
  `contractNumber` VARCHAR(50) NOT NULL,
  `commerceID` INT NOT NULL,
  `spaceID` INT NOT NULL,
  `startDate` DATE NOT NULL,
  `endDate` DATE NOT NULL,
  `documentUrl` VARCHAR(500) NULL,
  `baseRent` DECIMAL(16,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `commissionPercentage` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `scheduleID` INT NULL,
  `contractStatusID` TINYINT NOT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `createdBy` INT NOT NULL,
  PRIMARY KEY (`contractID`),
  UNIQUE INDEX `contractNumber_UNIQUE` (`contractNumber` ASC),
  INDEX `fk_Contracts_Commerces_idx` (`commerceID` ASC),
  INDEX `fk_Contracts_Spaces_idx` (`spaceID` ASC),
  INDEX `fk_Contracts_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_Contracts_Schedules_idx` (`scheduleID` ASC),
  INDEX `fk_Contracts_ContractStatus_idx` (`contractStatusID` ASC),
  INDEX `fk_Contracts_Users_idx` (`createdBy` ASC),
  CONSTRAINT `fk_Contracts_Commerces`
    FOREIGN KEY (`commerceID`)
    REFERENCES `Commerces` (`commerceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contracts_Spaces`
    FOREIGN KEY (`spaceID`)
    REFERENCES `Spaces` (`spaceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contracts_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contracts_Schedules`
    FOREIGN KEY (`scheduleID`)
    REFERENCES `Schedules` (`scheduleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contracts_ContractStatus`
    FOREIGN KEY (`contractStatusID`)
    REFERENCES `ContractStatus` (`contractStatusID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Contracts_Users`
    FOREIGN KEY (`createdBy`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SettlementStatus` (
  `settlementStatusID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`settlementStatusID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Settlements` (
  `settlementID` INT NOT NULL AUTO_INCREMENT,
  `contractID` INT NOT NULL,
  `scheduleID` INT NULL,
  `baseRentAmount` DECIMAL(16,2) NOT NULL,
  `totalSales` DECIMAL(16,2) NOT NULL,
  `commissionAmount` DECIMAL(16,2) NOT NULL,
  `totalAmount` DECIMAL(16,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `settlementDate` DATETIME NOT NULL DEFAULT NOW(),
  `settlementStatusID` TINYINT NOT NULL,
  `paidDate` DATETIME NULL,
  `createdBy` INT NOT NULL,
  PRIMARY KEY (`settlementID`),
  INDEX `fk_Settlements_Contracts_idx` (`contractID` ASC),
  INDEX `fk_Settlements_Schedules_idx` (`scheduleID` ASC),
  INDEX `fk_Settlements_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_Settlements_SettlementStatus_idx` (`settlementStatusID` ASC),
  INDEX `fk_Settlements_Users_idx` (`createdBy` ASC),
  CONSTRAINT `fk_Settlements_Contracts`
    FOREIGN KEY (`contractID`)
    REFERENCES `Contracts` (`contractID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Settlements_Schedules`
    FOREIGN KEY (`scheduleID`)
    REFERENCES `Schedules` (`scheduleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Settlements_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Settlements_SettlementStatus`
    FOREIGN KEY (`settlementStatusID`)
    REFERENCES `SettlementStatus` (`settlementStatusID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Settlements_Users`
    FOREIGN KEY (`createdBy`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE INVENTARIO
-- =====================================================

CREATE TABLE IF NOT EXISTS `Categories` (
  `categoryID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  PRIMARY KEY (`categoryID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Products` (
  `productID` INT NOT NULL AUTO_INCREMENT,
  `commerceID` INT NOT NULL,
  `sku` VARCHAR(50) NOT NULL,
  `barcode` VARCHAR(50) NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(200) NULL,
  `categoryID` INT NULL,
  `currencyID` SMALLINT NOT NULL,
  `stockQuantity` INT NOT NULL DEFAULT 0,
  `minStock` INT NULL DEFAULT 0,
  `maxStock` INT NULL,
  `isActive` BIT NOT NULL DEFAULT 1,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`productID`),
  INDEX `fk_Products_Commerces_idx` (`commerceID` ASC),
  INDEX `fk_Products_Categories_idx` (`categoryID` ASC),
  INDEX `fk_Products_Currencies_idx` (`currencyID` ASC),
  CONSTRAINT `fk_Products_Commerces`
    FOREIGN KEY (`commerceID`)
    REFERENCES `Commerces` (`commerceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Products_Categories`
    FOREIGN KEY (`categoryID`)
    REFERENCES `Categories` (`categoryID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Products_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PriceHistory` (
  `priceHistoryID` INT NOT NULL AUTO_INCREMENT,
  `productID` INT NOT NULL,
  `price` DECIMAL(15,2) NOT NULL,
  `cost` DECIMAL(15,2) NULL,
  `currencyID` SMALLINT NOT NULL,
  `isCurrent` BIT NOT NULL DEFAULT 1,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`priceHistoryID`),
  INDEX `fk_PriceHistory_Products_idx` (`productID` ASC),
  INDEX `fk_PriceHistory_Currencies_idx` (`currencyID` ASC),
  CONSTRAINT `fk_PriceHistory_Products`
    FOREIGN KEY (`productID`)
    REFERENCES `Products` (`productID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_PriceHistory_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `MovementTypes` (
  `movementTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`movementTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `InventoryMovements` (
  `movementID` INT NOT NULL AUTO_INCREMENT,
  `productID` INT NOT NULL,
  `movementTypeID` TINYINT NOT NULL,
  `stockQuantity` INT NOT NULL,
  `referenceDescription` VARCHAR(100) NULL,
  `referenceID` INT NULL,
  `movementDate` DATETIME NOT NULL DEFAULT NOW(),
  `createdBy` VARCHAR(50) NOT NULL,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`movementID`),
  INDEX `fk_InventoryMovements_Products_idx` (`productID` ASC),
  INDEX `fk_InventoryMovements_MovementTypes_idx` (`movementTypeID` ASC),
  CONSTRAINT `fk_InventoryMovements_Products`
    FOREIGN KEY (`productID`)
    REFERENCES `Products` (`productID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_InventoryMovements_MovementTypes`
    FOREIGN KEY (`movementTypeID`)
    REFERENCES `MovementTypes` (`movementTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE VENTAS
-- =====================================================

CREATE TABLE IF NOT EXISTS `CustomerTypes` (
  `customerTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`customerTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Customers` (
  `customerID` INT NOT NULL AUTO_INCREMENT,
  `customerTypeID` TINYINT NOT NULL,
  `name` VARCHAR(60) NOT NULL,
  `taxID` VARCHAR(30) NULL,
  `birthdate` DATETIME NULL,
  `addressID` INT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`customerID`),
  INDEX `fk_Customers_CustomerTypes_idx` (`customerTypeID` ASC),
  INDEX `fk_Customers_Addresses_idx` (`addressID` ASC),
  CONSTRAINT `fk_Customers_CustomerTypes`
    FOREIGN KEY (`customerTypeID`)
    REFERENCES `CustomerTypes` (`customerTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Customers_Addresses`
    FOREIGN KEY (`addressID`)
    REFERENCES `Addresses` (`addressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PaymentMethods` (
  `paymentMethodID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `code` VARCHAR(20) NOT NULL,
  `requiresReference` BIT NOT NULL DEFAULT 0,
  `processingFee` DECIMAL(5,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`paymentMethodID`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PaymentTypes` (
  `paymentTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  PRIMARY KEY (`paymentTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `PaymentStatus` (
  `paymentStatusID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`paymentStatusID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Payment` (
  `paymentID` INT NOT NULL AUTO_INCREMENT,
  `paymentMethodID` TINYINT NOT NULL,
  `paymentTypeID` TINYINT NOT NULL,
  `transactionAmount` DECIMAL(16,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `description` VARCHAR(100) NULL,
  `paymentDate` DATETIME NOT NULL DEFAULT NOW(),
  `paymentReference` VARCHAR(100) NULL,
  `paymentConfirmation` VARCHAR(100) NULL,
  `paymentStatusID` TINYINT NOT NULL,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`paymentID`),
  INDEX `fk_Payment_PaymentMethods_idx` (`paymentMethodID` ASC),
  INDEX `fk_Payment_PaymentTypes_idx` (`paymentTypeID` ASC),
  INDEX `fk_Payment_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_Payment_PaymentStatus_idx` (`paymentStatusID` ASC),
  CONSTRAINT `fk_Payment_PaymentMethods`
    FOREIGN KEY (`paymentMethodID`)
    REFERENCES `PaymentMethods` (`paymentMethodID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Payment_PaymentTypes`
    FOREIGN KEY (`paymentTypeID`)
    REFERENCES `PaymentTypes` (`paymentTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Payment_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Payment_PaymentStatus`
    FOREIGN KEY (`paymentStatusID`)
    REFERENCES `PaymentStatus` (`paymentStatusID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SaleStatus` (
  `saleStatusID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`saleStatusID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Sales` (
  `saleID` INT NOT NULL AUTO_INCREMENT,
  `commerceID` INT NOT NULL,
  `invoiceNumber` VARCHAR(50) NOT NULL,
  `saleDate` DATETIME NOT NULL DEFAULT NOW(),
  `customerID` INT NULL,
  `subtotal` DECIMAL(16,2) NOT NULL,
  `discountAmount` DECIMAL(16,2) NOT NULL DEFAULT 0,
  `taxAmount` DECIMAL(16,2) NOT NULL DEFAULT 0,
  `totalAmount` DECIMAL(16,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `computer` VARCHAR(50) NULL,
  `userID` INT NOT NULL,
  `paymentMethodID` TINYINT NOT NULL,
  `paymentReference` VARCHAR(100) NULL,
  `paymentConfirmation` VARCHAR(100) NULL,
  `saleStatusID` TINYINT NOT NULL,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`saleID`),
  INDEX `fk_Sales_Commerces_idx` (`commerceID` ASC),
  INDEX `fk_Sales_Customers_idx` (`customerID` ASC),
  INDEX `fk_Sales_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_Sales_Users_idx` (`userID` ASC),
  INDEX `fk_Sales_PaymentMethods_idx` (`paymentMethodID` ASC),
  INDEX `fk_Sales_SaleStatus_idx` (`saleStatusID` ASC),
  CONSTRAINT `fk_Sales_Commerces`
    FOREIGN KEY (`commerceID`)
    REFERENCES `Commerces` (`commerceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_Customers`
    FOREIGN KEY (`customerID`)
    REFERENCES `Customers` (`customerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_PaymentMethods`
    FOREIGN KEY (`paymentMethodID`)
    REFERENCES `PaymentMethods` (`paymentMethodID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Sales_SaleStatus`
    FOREIGN KEY (`saleStatusID`)
    REFERENCES `SaleStatus` (`saleStatusID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `SaleDetails` (
  `saleDetailID` INT NOT NULL AUTO_INCREMENT,
  `saleID` INT NOT NULL,
  `productID` INT NOT NULL,
  `unitPrice` DECIMAL(16,2) NOT NULL,
  `quantity` INT NOT NULL,
  `discountAmount` DECIMAL(16,2) NOT NULL DEFAULT 0,
  `subtotal` DECIMAL(16,2) NOT NULL,
  PRIMARY KEY (`saleDetailID`),
  INDEX `fk_SaleDetails_Sales_idx` (`saleID` ASC),
  INDEX `fk_SaleDetails_Products_idx` (`productID` ASC),
  CONSTRAINT `fk_SaleDetails_Sales`
    FOREIGN KEY (`saleID`)
    REFERENCES `Sales` (`saleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_SaleDetails_Products`
    FOREIGN KEY (`productID`)
    REFERENCES `Products` (`productID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS FINANCIERAS
-- =====================================================

CREATE TABLE IF NOT EXISTS `InvestmentCategories` (
  `investmentCategoryID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  `isCapital` BIT NOT NULL DEFAULT 0,
  `depreciationMonths` SMALLINT NULL,
  PRIMARY KEY (`investmentCategoryID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Investments` (
  `investmentID` INT NOT NULL AUTO_INCREMENT,
  `spaceID` INT NULL,
  `contractID` INT NULL,
  `description` VARCHAR(500) NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `investmentDate` DATE NOT NULL,
  `investmentCategoryID` TINYINT NOT NULL,
  `userID` INT NOT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`investmentID`),
  INDEX `fk_Investments_Spaces_idx` (`spaceID` ASC),
  INDEX `fk_Investments_Contracts_idx` (`contractID` ASC),
  INDEX `fk_Investments_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_Investments_InvestmentCategories_idx` (`investmentCategoryID` ASC),
  INDEX `fk_Investments_Users_idx` (`userID` ASC),
  CONSTRAINT `fk_Investments_Spaces`
    FOREIGN KEY (`spaceID`)
    REFERENCES `Spaces` (`spaceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Investments_Contracts`
    FOREIGN KEY (`contractID`)
    REFERENCES `Contracts` (`contractID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Investments_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Investments_InvestmentCategories`
    FOREIGN KEY (`investmentCategoryID`)
    REFERENCES `InvestmentCategories` (`investmentCategoryID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Investments_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ExpenseTypes` (
  `expenseTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`expenseTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Expenses` (
  `expenseID` INT NOT NULL AUTO_INCREMENT,
  `buildingID` INT NULL,
  `spaceID` INT NULL,
  `description` VARCHAR(500) NOT NULL,
  `amount` DECIMAL(16,2) NOT NULL,
  `expenseDate` DATE NOT NULL,
  `expenseTypeID` TINYINT NOT NULL,
  `invoiceNumber` VARCHAR(50) NULL,
  `supplierName` VARCHAR(100) NULL,
  `createdBy` INT NOT NULL,
  `createdDate` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`expenseID`),
  INDEX `fk_Expenses_Buildings_idx` (`buildingID` ASC),
  INDEX `fk_Expenses_Spaces_idx` (`spaceID` ASC),
  INDEX `fk_Expenses_ExpenseTypes_idx` (`expenseTypeID` ASC),
  INDEX `fk_Expenses_Users_idx` (`createdBy` ASC),
  CONSTRAINT `fk_Expenses_Buildings`
    FOREIGN KEY (`buildingID`)
    REFERENCES `Buildings` (`buildingID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Expenses_Spaces`
    FOREIGN KEY (`spaceID`)
    REFERENCES `Spaces` (`spaceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Expenses_ExpenseTypes`
    FOREIGN KEY (`expenseTypeID`)
    REFERENCES `ExpenseTypes` (`expenseTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Expenses_Users`
    FOREIGN KEY (`createdBy`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ReportTypes` (
  `reportTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NULL,
  PRIMARY KEY (`reportTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `FinancialReports` (
  `reportID` INT NOT NULL AUTO_INCREMENT,
  `userID` INT NOT NULL,
  `startDate` DATE NOT NULL,
  `endDate` DATE NOT NULL,
  `totalRevenue` DECIMAL(16,2) NOT NULL,
  `totalExpenses` DECIMAL(16,2) NOT NULL,
  `netIncome` DECIMAL(16,2) NOT NULL,
  `grossMargin` DECIMAL(5,2) NULL,
  `occupancyRate` DECIMAL(5,2) NULL,
  `currencyID` SMALLINT NOT NULL,
  `reportTypeID` TINYINT NOT NULL,
  `documentURL` VARCHAR(250) NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`reportID`),
  INDEX `fk_FinancialReports_Users_idx` (`userID` ASC),
  INDEX `fk_FinancialReports_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_FinancialReports_ReportTypes_idx` (`reportTypeID` ASC),
  CONSTRAINT `fk_FinancialReports_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FinancialReports_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FinancialReports_ReportTypes`
    FOREIGN KEY (`reportTypeID`)
    REFERENCES `ReportTypes` (`reportTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `CommerceReports` (
  `commerceReportID` INT NOT NULL AUTO_INCREMENT,
  `commerceID` INT NOT NULL,
  `startDate` DATE NOT NULL,
  `endDate` DATE NOT NULL,
  `totalSales` DECIMAL(16,2) NOT NULL,
  `totalCosts` DECIMAL(16,2) NOT NULL,
  `grossProfit` DECIMAL(16,2) NOT NULL,
  `totalRent` DECIMAL(16,2) NOT NULL,
  `commissionPaid` DECIMAL(16,2) NOT NULL,
  `netProfit` DECIMAL(16,2) NOT NULL,
  `currencyID` SMALLINT NOT NULL,
  `postTime` DATETIME NOT NULL DEFAULT NOW(),
  `userID` INT NOT NULL,
  PRIMARY KEY (`commerceReportID`),
  INDEX `fk_CommerceReports_Commerces_idx` (`commerceID` ASC),
  INDEX `fk_CommerceReports_Currencies_idx` (`currencyID` ASC),
  INDEX `fk_CommerceReports_Users_idx` (`userID` ASC),
  CONSTRAINT `fk_CommerceReports_Commerces`
    FOREIGN KEY (`commerceID`)
    REFERENCES `Commerces` (`commerceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CommerceReports_Currencies`
    FOREIGN KEY (`currencyID`)
    REFERENCES `Currencies` (`currencyID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CommerceReports_Users`
    FOREIGN KEY (`userID`)
    REFERENCES `Users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `FinancialReportDetails` (
  `financialReportDetailID` INT NOT NULL AUTO_INCREMENT,
  `financialReportID` INT NOT NULL,
  `expensesID` INT NULL,
  `investmentID` INT NULL,
  `commerceReportID` INT NULL,
  PRIMARY KEY (`financialReportDetailID`),
  INDEX `fk_FinancialReportDetails_FinancialReports_idx` (`financialReportID` ASC),
  INDEX `fk_FinancialReportDetails_Expenses_idx` (`expensesID` ASC),
  INDEX `fk_FinancialReportDetails_Investments_idx` (`investmentID` ASC),
  INDEX `fk_FinancialReportDetails_CommerceReports_idx` (`commerceReportID` ASC),
  CONSTRAINT `fk_FinancialReportDetails_FinancialReports`
    FOREIGN KEY (`financialReportID`)
    REFERENCES `FinancialReports` (`reportID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FinancialReportDetails_Expenses`
    FOREIGN KEY (`expensesID`)
    REFERENCES `Expenses` (`expenseID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FinancialReportDetails_Investments`
    FOREIGN KEY (`investmentID`)
    REFERENCES `Investments` (`investmentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FinancialReportDetails_CommerceReports`
    FOREIGN KEY (`commerceReportID`)
    REFERENCES `CommerceReports` (`commerceReportID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `CommerceReportDetails` (
  `commerceReportDetailID` INT NOT NULL AUTO_INCREMENT,
  `commerceReportID` INT NOT NULL,
  `contractID` INT NOT NULL,
  `salesAmount` DECIMAL(16,2) NOT NULL,
  `rentAmount` DECIMAL(16,2) NOT NULL,
  `commissionAmount` DECIMAL(16,2) NOT NULL,
  PRIMARY KEY (`commerceReportDetailID`),
  INDEX `fk_CommerceReportDetails_CommerceReports_idx` (`commerceReportID` ASC),
  INDEX `fk_CommerceReportDetails_Contracts_idx` (`contractID` ASC),
  CONSTRAINT `fk_CommerceReportDetails_CommerceReports`
    FOREIGN KEY (`commerceReportID`)
    REFERENCES `CommerceReports` (`commerceReportID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CommerceReportDetails_Contracts`
    FOREIGN KEY (`contractID`)
    REFERENCES `Contracts` (`contractID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- =====================================================
-- TABLAS DE LOGS
-- =====================================================

CREATE TABLE IF NOT EXISTS `LogTypes` (
  `logTypeID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`logTypeID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LogLevels` (
  `logLevelID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`logLevelID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `LogSources` (
  `logSourceID` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`logSourceID`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Logs` (
  `logID` BIGINT NOT NULL AUTO_INCREMENT,
  `posttime` DATETIME NOT NULL DEFAULT NOW(),
  `description` VARCHAR(500) NOT NULL,
  `computer` VARCHAR(100) NULL,
  `username` VARCHAR(50) NULL,
  `ref1ID` BIGINT NULL,
  `ref2ID` BIGINT NULL,
  `value1` VARCHAR(200) NULL,
  `value2` VARCHAR(200) NULL,
  `logTypeID` TINYINT NOT NULL,
  `logLevelID` TINYINT NOT NULL,
  `logSourceID` TINYINT NOT NULL,
  `checksum` VARBINARY(250) NULL,
  PRIMARY KEY (`logID`),
  INDEX `fk_Logs_LogTypes_idx` (`logTypeID` ASC),
  INDEX `fk_Logs_LogLevels_idx` (`logLevelID` ASC),
  INDEX `fk_Logs_LogSources_idx` (`logSourceID` ASC),
  CONSTRAINT `fk_Logs_LogTypes`
    FOREIGN KEY (`logTypeID`)
    REFERENCES `LogTypes` (`logTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Logs_LogLevels`
    FOREIGN KEY (`logLevelID`)
    REFERENCES `LogLevels` (`logLevelID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Logs_LogSources`
    FOREIGN KEY (`logSourceID`)
    REFERENCES `LogSources` (`logSourceID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;