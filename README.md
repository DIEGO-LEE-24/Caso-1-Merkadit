# 🛒 Caso-1: Merkadit - Market Management System

## 👥 Team Members
| Name                         | ID         |
|------------------------------|------------|
| Lindsay Nahome Marín Sánchez | 2024163904 |
| Lee Sangcheol                | 2024801079 |

**Professor:** Rodrigo Núñez Núñez  
**Course:** Base de Datos I  
**Institution:** Universidad de Costa Rica  

---

## 📖 Project Description

Merkadit is a comprehensive system designed to optimize the management of gastronomic and retail markets. The platform enables administrators to transform physical spaces into multiple shops or kiosks rented by independent businesses, with integrated POS functionality for tenants and centralized financial control.

### Business Model
- **Administrator Investment:** Remodeling physical spaces into commercial markets
- **Space Rental:** Multiple independent businesses rent individual spaces
- **Revenue Streams:** Base rent + commission percentage on sales
- **Integrated Technology:** POS system with real-time inventory and financial tracking

---

## 🎓 Academic Feedback Integration

After presenting the initial ERD diagram, we received valuable feedback from Professor Rodrigo Núñez that was incorporated into the final design:

### 📋 Professor's Feedback:
> *"Todo super, con esta revisión estamos más que bien, creo que podrían avanzar ya sin mayor problema con el resto del trabajo. Solo hay dos cositas que podrían tomar en cuenta..."*

### 🔧 Implemented Improvements:

**1. Category-Based Commission Negotiation**
Following the professor's recommendation about flexible commission rates:
> *"Los fees que pagan los comercios podrían ser negociados por categoría de producto, por ejemplo como mieles, vinagres y eso de un precio bajo, al rato la comisión sería algo algo digamos no se un 7%, pero también podría ser que también venden vinos caros importados, de unos 40 mil colones, entonces ahí se negocie con el administrador que para la categoría de licores el fee sea 3%"*

**Implementation:**
- **Basic products** (honey, vinegars): 7% commission
- **Imported liquors** (₡40,000 wines): 3% commission  
- **Electronics** (drones, expensive equipment): 2% commission
- **Fallback logic:** Specific negotiation → Category default → General contract rate

**2. Dynamic Reporting Strategy**
Following the professor's guidance on reporting systems:
> *"Los reportes, estos normalmente son calculados al vuelo, es decir, se usa una herramienta de reportería que haciendo la consulta calcula la información dinámicamente que va en el reporte, entonces no es necesario tener esas tablas de reportes, pues en una empresa pueden haber 10, 20, 80 reportes diferentes"*

**Decision:** Implemented **Option B** - SQL Views for each report:
- Real-time dynamic calculation
- Scalability for multiple enterprise reports  
- Compatibility with professional BI tools
- Data consistency and integrity

---

## ✨ Key Features

- **Space and Contract Management:** Complete lifecycle management of physical locations and rental agreements
- **Financial Tracking:** Comprehensive tracking of investments, expenses, and revenue streams  
- **Integrated POS System:** Real-time sales processing with automatic inventory updates
- **Automated Settlement Calculations:** Monthly commission and rent calculations with category-specific rates
- **Advanced Reporting System:** Dynamic SQL views and comprehensive business analytics
- **Role-Based Access Control:** Secure authentication for administrators, tenants, and cashiers
- **Category-Based Commissions:** Flexible commission rates by product category (e.g., 7% for basic goods, 3% for luxury items, 2% for electronics)
- **Audit Trail:** Complete logging system with checksums for data integrity

---

## 📂 Project Structure

```
Caso-1-Merkadit/
├── README.md                           # Project documentation
├── merkadit_schema_v1.sql             # Complete database schema (60+ tables)
├── sample_data.sql                    # Sample data with 4 months of sales
├── stored_procedures.sql              # SP_registerSale & SP_settleCommerce
├── advanced_sql_queries.sql           # Advanced SQL queries & views
├── Merkadit_API_Collection.json       # Postman testing collection
├── Merkadit_Business_Report.pbix      # Power BI report file
├── diagrama_merkadit_v1.pdf          # Entity Relationship Diagram
├── merkadit_v1.mwb                   # MySQL Workbench model
├── EntityDocumentation.docx           # Initial entity documentation
├── EntityDocumentationv2.docx        # Updated entity documentation
└── merkadit-api/                     # REST API (4-layer architecture)
    ├── package.json
    ├── .env                          # Environment configuration
    └── src/
        ├── app.js                    # Main application entry point
        ├── config/database.js        # Database connection configuration
        ├── handlers/                 # HTTP request handlers
        ├── controllers/              # Business logic orchestration
        ├── services/                 # Business logic implementation
        └── repositories/             # Data access layer
```

---

## 🗄️ Database Architecture

The system features a robust database design with **60+ tables** organized into modular systems:

### Core Modules

**📍 Address System**
- Countries, States, Cities, Addresses
- Support for international locations

**👤 User Management System**
- Users, Roles, Permissions, Contacts
- Role-based access control (RBAC)

**🏢 Commerce Infrastructure**
- Buildings, Floors, Spaces, Commerces
- Hierarchical space organization

**📑 Contract Management**
- Contracts, Schedules, Settlements
- Flexible commission structures with category negotiations

**📦 Inventory Management**
- Products, Categories, Price History, Inventory Movements
- Real-time stock tracking

**💰 Sales Processing**
- Sales, Customers, Payment Methods, Sale Details
- Multi-payment method support

**📊 Financial Control**
- Investments, Expenses, Commission Tracking
- Comprehensive financial reporting

**🛡️ Audit & Security**
- Comprehensive logging with checksums
- Data integrity verification

### Advanced Features

**Dynamic Commission System (Professor's Recommendation):**
- Base contract commission rates
- Category-specific commission overrides via `ContractCategoryCommissions` table
- Fallback logic: Contract-specific → Category default → General contract rate

**Dynamic Reporting Infrastructure (Professor's Recommendation):**
- `BusinessReportView`: Main business reporting view
- `ReportCommercesSales`: Sales performance by commerce
- `ReportBuildingFinancials`: Financial overview by building
- `ReportCategoryPerformance`: Product category analytics

---

## 🔧 Technical Implementation

### Database Technology
- **MySQL 8.0:** Primary database engine
- **MySQL Workbench:** Database modeling and design
- **InnoDB Storage Engine:** ACID compliance and foreign key support

### API Architecture (4-Layer Design)
- **Handler Layer:** HTTP request/response management
- **Controller Layer:** Business logic orchestration and validation
- **Service Layer:** Complex business operations and transaction management
- **Repository Layer:** Database access and stored procedure calls

### Technology Stack
- **Backend:** Node.js + Express.js
- **Database Driver:** MySQL2 with connection pooling
- **API Testing:** Postman with comprehensive test collection
- **Business Intelligence:** Power BI Desktop
- **Development Tools:** Nodemon for hot reloading
- **Security:** Helmet for HTTP headers, CORS support

---

## 📋 Implementation Deliverables

### ✅ Completed Deliverables

**1. Database Design & Implementation**
- Complete ERD with 60+ tables
- MySQL Workbench model file
- Production-ready schema with constraints and relationships

**2. Sample Data Generation**
- 4 months of realistic sales data (May-August 2024)
- 2 commercial buildings with 3 rental spaces
- 15 historical commerces with 5 active contracts
- 14 products across multiple categories
- 240+ generated sales transactions

**3. Stored Procedures (Production-Ready)**

**SP_registerSale:**
- Complete sales transaction processing
- Multi-product support (up to 3 products per sale)
- Automatic inventory updates with movement tracking
- Invoice number generation with business logic
- Transaction safety with rollback capabilities
- Comprehensive error handling and logging

**SP_settleCommerce:**
- Monthly settlement calculations with category-specific commissions
- Duplicate settlement prevention
- Base rent + commission calculation
- Settlement history tracking
- Business rule validation and error handling

**4. REST API (Fully Functional)**
- 4-layer architecture implementation
- 5 endpoints with complete CRUD operations
- Error handling and validation
- Database connection pooling
- Security middleware integration

**5. Advanced SQL Queries**
- 6 complex queries demonstrating required techniques:
  - ORDER BY with multi-column sorting
  - LIMIT for top N results
  - Complex nested subqueries
  - EXISTS for conditional filtering
  - IN with subquery filters
  - Calculated fields with business logic

**6. Testing & Validation**
- Complete Postman collection with 7 test cases
- All endpoints tested and validated
- Sample requests and expected responses
- Error scenario testing

**7. Professional Business Report**
- Interactive Power BI dashboard
- Visual comparison between buildings
- Executive summary with key metrics
- Export capability for distribution

---

## 🚀 Installation & Setup

### Prerequisites
- MySQL 8.0+
- Node.js 18.0+
- npm 8.0+
- Power BI Desktop (for report visualization)

### Database Setup
```bash
# 1. Connect to MySQL
mysql -u root -p

# 2. Create database and tables
SOURCE merkadit_schema_v1.sql;

# 3. Load sample data
SOURCE sample_data.sql;

# 4. Create stored procedures
SOURCE stored_procedures.sql;

# 5. Create views and advanced queries
SOURCE advanced_sql_queries.sql;
```

### API Setup
```bash
# 1. Navigate to API directory
cd merkadit-api

# 2. Install dependencies
npm install

# 3. Configure environment variables
# Copy .env.example to .env and configure:
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=merkadit
PORT=3000

# 4. Start development server
npm run dev
```

### Testing with Postman
1. Import `Merkadit_API_Collection.json` into Postman
2. Ensure API is running on `http://localhost:3000`
3. Execute test cases in sequence:
   - Health Check
   - Register Sale
   - Get Sale Details
   - Process Settlement
   - Get Commerce Settlements

### Business Report Visualization
1. Open Power BI Desktop
2. Load `Merkadit_Business_Report.pbix`
3. Refresh data connection if needed
4. Explore interactive visualizations

---

## 📊 API Endpoints

| Method | Endpoint | Description | Status |
|--------|----------|-------------|---------|
| GET | `/health` | API health check | ✅ Tested |
| POST | `/api/sales/register` | Register new sale | ✅ Tested |
| GET | `/api/sales/:saleID` | Get sale details | ✅ Tested |
| POST | `/api/settlements/process` | Process monthly settlement | ✅ Tested |
| GET | `/api/settlements/commerce/:commerceID` | Get settlement history | ✅ Tested |

### Sample API Responses

**Successful Sale Registration:**
```json
{
  "success": true,
  "saleID": 243,
  "totalAmount": "3390.00",
  "message": "Sale registered successfully. Invoice: FAC-2025-09-001-6486. Total: ₡3,390.00"
}
```

**Successful Settlement Processing:**
```json
{
  "success": true,
  "settlementID": 17,
  "totalAmount": "500000.00",
  "message": "Settlement created successfully. Sales: ₡0.00, Commission: ₡0.00, Rent: ₡500,000.00, Total: ₡500,000.00"
}
```

---

## 📈 Business Intelligence Features

### Dynamic Reporting (Professor's Recommendation Implementation)
- **Real-time calculation:** All reports generated on-demand using SQL views
- **Category-based insights:** Performance analysis by product category
- **Settlement tracking:** Complete financial settlement history
- **Inventory optimization:** Stock level monitoring with reorder alerts

### Key Business Metrics
- Monthly revenue per commerce
- Commission generation by category
- Space utilization rates
- Inventory turnover analysis
- Settlement payment tracking

---

## 🔍 Advanced SQL Capabilities

The system demonstrates mastery of advanced SQL techniques:

**Complex Nested Queries:** Multi-level subqueries for business logic
**Performance Optimization:** Indexed queries with efficient joins
**Data Aggregation:** GROUP BY with multiple levels of aggregation
**Conditional Logic:** CASE statements for business rule implementation
**Dynamic Views:** Real-time reporting infrastructure (Professor's recommendation)
**Category-Based Logic:** Flexible commission calculation system

---

## 🏆 Project Achievements

- **100% Requirement Fulfillment:** All project deliverables completed successfully
- **Academic Feedback Integration:** Professor's recommendations fully implemented
- **Production-Ready Code:** Enterprise-level code quality with error handling
- **Scalable Architecture:** 4-layer API design supporting future growth
- **Comprehensive Testing:** Full test coverage with Postman validation
- **Advanced Database Design:** 60+ table schema with complex relationships
- **Business Logic Implementation:** Real-world commission and settlement logic
- **Professional Documentation:** Complete technical and user documentation
- **Visual Business Intelligence:** Interactive Power BI dashboard

---

## 📅 Project Timeline

- **Research & Design Phase:** Completed
- **ERD Review & Feedback Integration:** Completed
- **Database Implementation:** Completed  
- **Stored Procedures Development:** Completed
- **API Development & Testing:** Completed
- **Advanced SQL Queries:** Completed
- **Business Report Creation:** Completed
- **Documentation & Validation:** Completed
- **Final Delivery:** Ready for submission

---

## 🔗 Additional Resources

- **GitHub Repository:** https://github.com/CholiRat/Caso-1-Merkadit
- **API Documentation:** Available in Postman collection
- **Database Schema:** Detailed ERD in `diagrama_merkadit_v1.pdf`
- **Business Report:** Interactive dashboard in `Merkadit_Business_Report.pbix`
- **Technical Specifications:** Complete implementation details in LaTeX documentation

---

**Final Submission Date:** September 30, 2025  
**Project Status:** ✅ Complete and Ready for Evaluation
