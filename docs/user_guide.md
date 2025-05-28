# User Guide - Pharmaceutical Supply Chain Analytics

## Getting Started

This guide provides step-by-step instructions for setting up and using the Pharmaceutical Supply Chain Analytics platform for healthcare organizations and database professionals.

## System Requirements

### Hardware Requirements
- **RAM**: Minimum 8GB, Recommended 16GB
- **Storage**: 50GB free space for database and logs
- **CPU**: Multi-core processor (4+ cores recommended)

### Software Requirements
- **Database**: MySQL 8.0 or higher
- **Programming Language**: Python 3.8+
- **Operating System**: Windows 10+, macOS 10.15+, or Linux Ubuntu 18.04+

## Installation Instructions

### Step 1: Database Setup

1. **Install MySQL Server**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install mysql-server
   
   # CentOS/RHEL
   sudo yum install mysql-server
   
   # macOS (using Homebrew)
   brew install mysql
   ```

2. **Create Database and User**
   ```sql
   CREATE DATABASE pharma_db;
   CREATE USER 'pharma_user'@'localhost' IDENTIFIED BY 'secure_password';
   GRANT ALL PRIVILEGES ON pharma_db.* TO 'pharma_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Import Database Schema**
   ```bash
   mysql -u pharma_user -p pharma_db < sql/create_tables.sql
   ```

### Step 2: Python Environment Setup

1. **Create Virtual Environment**
   ```bash
   python -m venv pharma_analytics
   source pharma_analytics/bin/activate  # Linux/Mac
   pharma_analytics\Scripts\activate     # Windows
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Database Connection**
   
   Edit `python/database_connection.py`:
   ```python
   db_config = {
       'host': 'localhost',
       'user': 'pharma_user',
       'password': 'secure_password',
       'database': 'pharma_db'
   }
   ```

## Core Features and Usage

### Analytics Dashboard

Launch the comprehensive analytics dashboard:
```bash
python python/database_connection.py
```

**Dashboard Components:**
- Sales performance by representative
- Regional revenue distribution
- Inventory status alerts
- Customer segmentation analysis
- Product performance metrics

### SQL Query Interface

Access advanced business intelligence queries:
```bash
mysql -u pharma_user -p pharma_db < sql/advanced_queries.sql
```

**Available Query Categories:**
- Sales performance ranking
- Product profitability analysis
- Customer lifetime value
- Inventory optimization
- Regional market penetration

### NoSQL Analytics (Optional)

For document-based analytics with MongoDB:
```bash
mongoimport --db pharma_nosql --collection products --file data/products.json
mongo pharma_nosql < nosql/mongodb_queries.js
```

## Business Intelligence Features

### Executive Reporting

Generate executive summary reports with key performance indicators:

**Financial Metrics:**
- Total revenue and growth trends
- Average order value analysis
- Profitability by product category
- Regional performance comparison

**Operational Metrics:**
- Inventory turnover rates
- Stock-out frequency analysis
- Order fulfillment efficiency
- Customer satisfaction scores

### Predictive Analytics

**Demand Forecasting:**
- Seasonal trend analysis
- Product demand prediction
- Inventory optimization recommendations

**Customer Analytics:**
- Churn prediction modeling
- Customer lifetime value calculation
- Segmentation and targeting

## User Roles and Permissions

### Sales Manager
**Access Level**: Regional data and team performance
**Key Features**:
- Representative performance tracking
- Customer interaction analysis
- Territory management reports

### Inventory Manager
**Access Level**: Product and stock management
**Key Features**:
- Real-time inventory monitoring
- Automated reorder alerts
- Supplier performance analysis

### Executive/C-Level
**Access Level**: Company-wide analytics
**Key Features**:
- Executive dashboard
- Strategic performance indicators
- Market analysis reports

## Data Management

### Data Import Procedures

**Customer Data Import:**
```sql
LOAD DATA INFILE 'customer_data.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

**Product Catalog Update:**
```python
# Use Python script for complex product imports
python scripts/import_products.py --file products.xlsx --validate
```

### Data Backup and Recovery

**Automated Backup Setup:**
```bash
# Create backup script
#!/bin/bash
mysqldump -u pharma_user -p pharma_db > backup_$(date +%Y%m%d).sql
```

**Recovery Procedure:**
```bash
mysql -u pharma_user -p pharma_db < backup_20231120.sql
```

## Performance Optimization

### Query Optimization

**Indexing Strategy:**
- Primary and foreign key indexes (automatic)
- Composite indexes for frequent query patterns
- Covering indexes for reporting queries

**Query Performance Monitoring:**
```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
```

### System Monitoring

**Database Performance Metrics:**
- Query execution times
- Index usage statistics
- Connection pool utilization
- Memory consumption

**Application Monitoring:**
- Python script execution times
- Dashboard load performance
- User session analytics

## Troubleshooting Guide

### Common Issues

**Database Connection Errors:**
```
Error: Can't connect to MySQL server
Solution: Check MySQL service status and firewall settings
```

**Python Import Errors:**
```
Error: ModuleNotFoundError: No module named 'mysql.connector'
Solution: Ensure virtual environment is activated and dependencies installed
```

**Performance Issues:**
```
Issue: Slow query execution
Solution: Review query execution plans and add appropriate indexes
```

### Diagnostic Commands

**Check Database Status:**
```sql
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;
SHOW TABLE STATUS;
```

**Python Environment Verification:**
```bash
pip list
python --version
which python
```

## API Reference

### Database Connection Class

```python
class PharmaceuticalAnalytics:
    def __init__(self, db_config):
        """Initialize analytics platform"""
    
    def connect_database(self):
        """Establish database connection"""
    
    def execute_query(self, query, params=None):
        """Execute parameterized SQL query"""
    
    def get_executive_summary(self):
        """Generate KPI summary"""
    
    def analyze_sales_performance(self):
        """Sales performance analysis"""
    
    def create_comprehensive_dashboard(self):
        """Generate visual dashboard"""
```

### Key Methods

**Sales Analysis:**
- `analyze_sales_performance()`: Representative metrics
- `analyze_regional_performance()`: Geographic analysis
- `analyze_customer_segments()`: Customer analytics

**Inventory Management:**
- `analyze_inventory_status()`: Stock level analysis
- `generate_reorder_alerts()`: Automated alerts
- `calculate_turnover_rates()`: Efficiency metrics

## Security Best Practices

### Database Security

**User Access Control:**
```sql
-- Create role-based users
CREATE USER 'sales_user'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT ON pharma_db.Sales_Representative TO 'sales_user'@'%';
GRANT SELECT ON pharma_db.Orders TO 'sales_user'@'%';
```

**Data Encryption:**
- Enable SSL connections
- Encrypt sensitive customer data
- Regular security audits

### Application Security

**Configuration Management:**
- Store credentials in environment variables
- Use connection pooling
- Implement query parameterization
- Regular dependency updates

## Compliance and Auditing

### Healthcare Compliance

**HIPAA Considerations:**
- Patient data protection
- Access logging and monitoring
- Data retention policies
- Breach notification procedures

**Audit Trail Implementation:**
```sql
CREATE TABLE Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100),
    table_name VARCHAR(50),
    record_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Support and Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Database backup verification
- Performance metric review
- User access audit

**Monthly:**
- Index optimization analysis
- Storage capacity planning
- Security patch updates

**Quarterly:**
- Comprehensive system health check
- User training updates
- Feature enhancement review

### Contact Information

**Technical Support:**
- Email: support@medibuddy-analytics.com
- Documentation: [Internal Wiki]
- Issue Tracking: [JIRA/GitHub Issues]

**Training Resources:**
- User training videos
- SQL query examples
- Best practices documentation
- Troubleshooting guides
