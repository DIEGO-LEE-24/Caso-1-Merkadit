# 🛒 Caso-1: Merkadit - Market Management System

## 👥 Team Members
| Name                         | ID         |
|------------------------------|------------|
| Lindsay Nahome Marín Sánchez | 2024163904 |
| Lee Sangcheol                | 2024801079 |

**Professor:** Rodrigo Nuñez Nuñez  

---

## 📖 Project Description
Merkadit is a comprehensive system designed to optimize the management of gastronomic and retail markets.  
The platform enables administrators to transform physical spaces into multiple shops or kiosks rented by independent businesses, with integrated POS functionality for tenants and centralized financial control.

---

## ✨ Key Features
- [x] Space and contract management for physical locations  
- [x] Financial tracking for investments and expenses  
- [x] POS system with real-time inventory updates  
- [x] Automated monthly settlement calculations  
- [x] Comprehensive reporting system  
- [x] Role-based access control (Administrator/Tenant)  

---

## 📂 Current Files in Repository
- `EntityDocumentation.docx` - Initial entity list with attributes  
- `EntityDocumentationv2.docx` - Updated entity documentation  
- `diagrama_merkadit_v1.pdf` - Entity Relationship Diagram  
- `merkadit_schema_v1.sql` - Complete database schema  
- `merkadit_v1.mwb` - MySQL Workbench model file  
- `README.md` - Project documentation  

---

## 🗄️ Database Structure
The database contains **60+ tables** organized into these modules:

<details>
<summary>📍 Address System</summary>
Countries, States, Cities, Addresses
</details>

<details>
<summary>👤 User System</summary>
Users, Roles, Permissions, Contacts
</details>

<details>
<summary>🏢 Commerce System</summary>
Buildings, Floors, Spaces, Commerces
</details>

<details>
<summary>📑 Contract System</summary>
Contracts, Schedules, Settlements
</details>

<details>
<summary>📦 Inventory System</summary>
Products, Categories, Price History, Inventory Movements
</details>

<details>
<summary>💰 Sales System</summary>
Sales, Customers, Payment Methods, Sale Details
</details>

<details>
<summary>📊 Financial System</summary>
Investments, Expenses, Reports
</details>

<details>
<summary>🛡️ Audit System</summary>
Logs with checksums for data integrity
</details>

---

## 📊 Progress Status

### ✅ Completed
- Database design and ERD  
- Entity documentation  
- MySQL Workbench model  
- Database schema SQL script  

### 🔄 In Progress
- Sample data script  
- Stored procedures (`SP_registerSale`, `SP_settleCommerce`)  

### 🕒 Pending
- REST API implementation  
- Postman test collection  
- SQL queries and views for reporting  
- Final report in Power BI/Tableau  

## 📅 Important Dates
- **Review Deadline:** September 21, 2025
- **Final Submission:** September 30, 2025

## ✅ Requirements Summary
1. Database schema with ERD ✅
2. Sample data for testing
3. Two stored procedures for sales and settlements
4. REST API with 4-layer architecture
5. Postman collection for API testing
6. Business report with SQL views
7. Professional report visualization

## 🛠️ Technologies
- 🗄️ **Database:** MySQL 8.0
- 📝 **Modeling:** MySQL Workbench
- 🌐 **API:** Node.js / Python / Java / .NET (TBD)
- 🧪 **Testing:** Postman
- 📊 **Reporting:** Power BI or Tableau
