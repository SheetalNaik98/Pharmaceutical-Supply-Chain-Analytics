# Database Schema Documentation

## Overview

The Pharmaceutical Supply Chain Analytics database is designed to support comprehensive healthcare supply chain management operations. The schema consists of 14 interconnected tables that manage sales operations, inventory tracking, customer relationships, and business intelligence reporting.

## Core Design Principles

- **Normalized Structure**: Follows 3NF to minimize data redundancy
- **Referential Integrity**: Comprehensive foreign key constraints
- **Scalability**: Designed to handle enterprise-level data volumes
- **Performance**: Optimized indexes for analytical queries
- **Flexibility**: Supports multiple customer types and product categories

## Entity Relationship Structure

### Primary Entities

#### Region
**Purpose**: Geographic territory management for sales operations

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Region_ID | INT | PRIMARY KEY, NOT NULL | Unique region identifier |
| Name | VARCHAR(100) | NOT NULL | Region name |
| Description | VARCHAR(255) | | Detailed region description |
| Created_Date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Business Rules**:
- Each region can have multiple sales representatives
- Regions are used for performance analysis and territory management
- Regional allocation affects shipment distribution

#### Sales_Representative
**Purpose**: Sales team management and performance tracking

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Representative_ID | INT | PRIMARY KEY, NOT NULL | Unique representative identifier |
| Region_ID | INT | FOREIGN KEY → Region | Assigned territory |
| Name | VARCHAR(100) | NOT NULL | Representative full name |
| Email | VARCHAR(150) | | Contact email address |
| Phone | VARCHAR(20) | | Contact phone number |
| Hire_Date | DATE | | Employment start date |
| Performance_Rating | DECIMAL(3,2) | | Current performance score (1-5) |

**Business Rules**:
- Each representative is assigned to exactly one region
- Performance ratings are updated quarterly
- Representatives manage customer relationships and process orders

#### Customer
**Purpose**: Base customer information management

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Customer_ID | INT | PRIMARY KEY, NOT NULL | Unique customer identifier |
| Name | VARCHAR(100) | NOT NULL | Customer name |
| Contact_Details | VARCHAR(200) | | Primary contact information |
| Address | VARCHAR(300) | | Physical address |
| Registration_Date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation date |
| Status | ENUM | DEFAULT 'Active' | Account status |

**Business Rules**:
- Customers can be Doctors, Hospitals, or Pharmacies
- Each customer type has specialized attributes
- Customer status affects ordering capabilities

#### Product
**Purpose**: Product catalog management with pharmaceutical specifications

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Product_ID | INT | PRIMARY KEY, NOT NULL | Unique product identifier |
| Name | VARCHAR(100) | NOT NULL | Product name |
| Category | VARCHAR(100) | NOT NULL | Product classification |
| Price | DECIMAL(10,2) | NOT NULL | Unit price |
| Description | TEXT | | Detailed product description |
| Manufacturer | VARCHAR(100) | | Manufacturing company |
| Expiry_Date | DATE | | Product expiration date |
| FDA_Approved | BOOLEAN | DEFAULT TRUE | Regulatory approval status |
| Created_Date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Catalog entry date |

**Business Rules**:
- Products must have FDA approval for sale
- Price changes are tracked through audit mechanisms
- Categories support business analytics and inventory management

### Specialized Customer Tables

#### Doctors
**Purpose**: Medical practitioner specific information

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Customer_ID | INT | PRIMARY KEY, FOREIGN KEY → Customer | Customer reference |
| Speciality | VARCHAR(100) | NOT NULL | Medical specialization |
| License_Number | VARCHAR(50) | UNIQUE | Medical license identifier |
| Medical_School | VARCHAR(150) | | Educational background |
| Years_Experience | INT | | Professional experience |

#### Hospital
**Purpose**: Healthcare facility management

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Customer_ID | INT | PRIMARY KEY, FOREIGN KEY → Customer | Customer reference |
| Hospital_Type | ENUM | NOT NULL | Facility classification |
| Bed_Capacity | INT | | Patient capacity |
| Accreditation | VARCHAR(100) | | Quality certifications |
| Emergency_Services | BOOLEAN | DEFAULT TRUE | Emergency care availability |

#### Pharmacy
**Purpose**: Pharmaceutical retail management

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Customer_ID | INT | PRIMARY KEY, FOREIGN KEY → Customer | Customer reference |
| License_Number | VARCHAR(50) | UNIQUE, NOT NULL | Pharmacy license |
| Chain_Affiliation | VARCHAR(100) | | Corporate affiliation |
| Operating_Hours | VARCHAR(100) | | Business hours |
| DEA_Number | VARCHAR(20) | | Drug Enforcement Administration number |

### Transaction Management

#### Orders
**Purpose**: Order processing and tracking

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Order_ID | INT | PRIMARY KEY, NOT NULL | Unique order identifier |
| Date | DATE | NOT NULL | Order placement date |
| Total_cost | DECIMAL(10,2) | NOT NULL | Order total amount |
| Representative_ID | INT | FOREIGN KEY → Sales_Representative | Processing representative |
| Shipment_ID | INT | FOREIGN KEY → Shipment | Associated shipment |
| Order_Status | ENUM | DEFAULT 'Pending' | Current order status |
| Priority_Level | ENUM | DEFAULT 'Medium' | Processing priority |

**Business Rules**:
- Orders must be associated with a sales representative
- Status transitions follow defined workflow
- Priority affects processing sequence

#### Shipment
**Purpose**: Logistics and delivery management

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Shipment_ID | INT | PRIMARY KEY, NOT NULL | Unique shipment identifier |
| Date | DATE | NOT NULL | Shipment date |
| Interaction_Type | ENUM | NOT NULL | Communication method |
| Status | ENUM | DEFAULT 'Pending' | Current shipment status |
| Tracking_Number | VARCHAR(50) | | Carrier tracking reference |
| Estimated_Delivery | DATE | | Expected delivery date |

### Inventory Management

#### Inventory
**Purpose**: Stock level tracking and management

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Inventory_ID | INT | PRIMARY KEY, NOT NULL | Unique inventory record |
| Product_ID | INT | FOREIGN KEY → Product, NOT NULL | Product reference |
| Quantity | INT | NOT NULL, CHECK ≥ 0 | Current stock level |
| Reorder_Level | INT | DEFAULT 100 | Minimum stock threshold |
| Last_Updated | TIMESTAMP | AUTO UPDATE | Last modification time |
| Location | VARCHAR(100) | | Storage location |

**Business Rules**:
- Quantity cannot be negative
- Reorder alerts triggered at threshold
- Location supports warehouse management

### Relationship Tables

#### Interaction
**Purpose**: Sales representative-customer relationship tracking

| Columns | Constraints | Description |
|---------|-------------|-------------|
| Representative_ID, Customer_ID | COMPOSITE PRIMARY KEY | Relationship identifier |
| Interaction_Date | TIMESTAMP | Last interaction time |
| Interaction_Notes | TEXT | Communication details |
| Follow_Up_Required | BOOLEAN | Action flag |

#### Order_Placed
**Purpose**: Customer-order relationship management

| Columns | Constraints | Description |
|---------|-------------|-------------|
| Order_ID, Customer_ID | COMPOSITE PRIMARY KEY | Order ownership |
| Order_Date | TIMESTAMP | Placement timestamp |

#### Involvement
**Purpose**: Product-order line item details

| Columns | Constraints | Description |
|---------|-------------|-------------|
| Order_ID, Product_ID | COMPOSITE PRIMARY KEY | Line item identifier |
| Quantity_Ordered | INT | Product quantity |
| Unit_Price | DECIMAL(10,2) | Price at time of order |
| Line_Total | DECIMAL(10,2) | Extended amount |

## Indexes and Performance Optimization

### Primary Indexes
- All primary keys have clustered indexes
- Foreign key columns have non-clustered indexes
- Date columns used in reporting have covering indexes

### Custom Indexes
```sql
-- Performance optimization indexes
CREATE INDEX idx_sales_rep_region ON Sales_Representative(Region_ID);
CREATE INDEX idx_orders_rep ON Orders(Representative_ID);
CREATE INDEX idx_orders_date ON Orders(Date);
CREATE INDEX idx_inventory_product ON Inventory(Product_ID);
CREATE INDEX idx_product_category ON Product(Category);
```

## Views and Analytical Components

### Sales_Performance View
Aggregated sales metrics by representative and region for executive reporting.

### Low_Stock_Alert View
Real-time inventory status with automated reorder recommendations.

## Data Integrity Constraints

### Referential Integrity
- All foreign key relationships enforced
- Cascading updates where appropriate
- Restricted deletes to maintain data history

### Domain Constraints
- ENUM types for standardized values
- CHECK constraints for business rule enforcement
- NOT NULL constraints for required fields

### Business Rule Constraints
- Order quantities must be positive
- Performance ratings between 1.0 and 5.0
- Customer status transitions follow workflow

## Security Considerations

### Access Control
- Role-based permissions by user type
- Sensitive data encryption at rest
- Audit logging for compliance

### Data Privacy
- Customer information access restricted
- PII handling complies with healthcare regulations
- Regular access reviews and cleanup

## Backup and Recovery

### Backup Strategy
- Daily full backups with transaction log backups
- Point-in-time recovery capability
- Cross-region backup replication

### Disaster Recovery
- RTO: 4 hours
- RPO: 1 hour
- Documented recovery procedures

## Future Enhancements

### Planned Extensions
- Integration with ERP systems
- Real-time analytics dashboard
- Mobile application support
- AI-driven demand forecasting

### Scalability Considerations
- Horizontal partitioning for large tables
- Read replica deployment
- Caching layer implementation
