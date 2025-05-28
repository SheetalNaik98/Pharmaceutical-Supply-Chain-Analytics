# Pharmaceutical Supply Chain Analytics

> Healthcare Analytics and Reporting Solution for Supply Chain Optimization using SQL and Python

## Project Overview

**MediBuddy** is a comprehensive healthcare analytics solution designed to optimize pharmaceutical supply chains through data-driven insights and automated reporting. This project addresses critical challenges in coordinating manufacturing, inventory management, and sales operations across healthcare networks.

The system provides end-to-end analytics from warehouse management to customer delivery, focusing on efficient order processing, inventory optimization, and strategic decision-making for pharmaceutical companies.

### Key Features

- **Robust Database Design**: 14-table relational schema with comprehensive foreign key relationships
- **Advanced SQL Analytics**: Complex queries including joins, subqueries, and aggregate functions
- **Python Integration**: Database connectivity with pandas and visualization libraries
- **Interactive Dashboards**: Real-time charts and business intelligence reports
- **NoSQL Support**: MongoDB implementation for scalable data handling
- **Performance Analytics**: Sales representative tracking and regional performance analysis

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Database** | MySQL 8.0+ | Primary relational database |
| **Analytics** | Python 3.8+ | Data processing and analysis |
| **Visualization** | Matplotlib, Seaborn | Chart generation and dashboards |
| **Data Processing** | Pandas, NumPy | Data manipulation and statistics |
| **Connectivity** | mysql-connector-python | Database integration |
| **NoSQL** | MongoDB | Scalable document storage |

## Database Architecture

### Entity Relationship Model

The system manages complex relationships between key business entities:

- **Sales Representatives** manage customer relationships across geographic regions
- **Customers** include Doctors, Pharmacies, and Hospitals with specialized attributes
- **Orders** connect customers to products through representative interactions
- **Inventory** tracks product quantities and supports supply chain decisions
- **Shipments** coordinate product distribution across regional allocations

### Core Schema Design

```sql
Sales_Representative → Customer → Orders → Products
         ↓               ↓         ↓         ↓
     Regions       Interactions  Shipments  Inventory
```

## Installation and Setup

### Prerequisites

- Python 3.8 or higher
- MySQL Server 8.0+
- Git for version control

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Pharmaceutical-Supply-Chain-Analytics.git
   cd Pharmaceutical-Supply-Chain-Analytics
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Database setup**
   ```bash
   mysql -u root -p < sql/create_tables.sql
   ```

4. **Configure database connection**
   
   Update credentials in `python/database_connection.py`:
   ```python
   db_config = {
       'host': 'localhost',
       'user': 'your_username',
       'password': 'your_password',
       'database': 'pharma_db'
   }
   ```

5. **Run analytics**
   ```bash
   python python/database_connection.py
   ```

## Analytics Capabilities

### SQL Query Features

**Aggregate Analysis**
- Sales performance by representative and region
- Inventory summaries with low-stock alerts
- Revenue analysis across product categories

**Complex Joins**
- Multi-table relationship analysis
- Customer interaction patterns
- Supply chain efficiency metrics

**Advanced Queries**
- Nested subqueries for business intelligence
- Correlated queries for performance rankings
- Window functions for trend analysis

### Python Visualizations

**Performance Dashboards**
- Sales representative comparison charts
- Regional revenue distribution analysis
- Product category performance metrics
- Customer interaction method analysis

**Business Intelligence**
- Inventory turnover calculations
- Price-quantity relationship analysis
- Monthly sales trend identification
- Executive summary report generation

## Use Cases and Applications

### Inventory Management
- Real-time stock level monitoring
- Automated low-stock alert system
- Product turnover rate analysis
- Category-wise inventory optimization

### Sales Analytics
- Representative performance tracking
- Regional sales comparison
- Customer interaction effectiveness
- Revenue trend analysis

### Supply Chain Optimization
- Shipment route efficiency analysis
- Customer delivery performance metrics
- Regional allocation optimization
- Order fulfillment timing analysis

## Project Structure

```
Pharmaceutical-Supply-Chain-Analytics/
├── sql/                    # Database scripts and queries
│   ├── create_tables.sql   # Database schema creation
│   ├── sample_queries.sql  # Analytics and reporting queries
│   └── nosql_queries.js    # MongoDB implementation
├── python/                 # Analysis and visualization
│   ├── database_connection.py  # Main analytics script
│   ├── data_analysis.py        # Statistical analysis
│   └── visualization.py        # Chart generation
├── docs/                   # Documentation
│   ├── database_schema.md  # Schema documentation
│   ├── user_guide.md      # Usage instructions
│   └── api_reference.md   # Code documentation
├── data/                   # Sample datasets
└── images/                # Diagrams and charts
```

## Sample Queries

### Sales Performance Analysis
```sql
SELECT 
    sr.Name AS Representative_Name,
    SUM(o.Total_cost) AS Total_Sales,
    COUNT(o.Order_ID) AS Total_Orders,
    AVG(o.Total_cost) AS Average_Order_Value
FROM Sales_Representative sr
LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
GROUP BY sr.Representative_ID
ORDER BY Total_Sales DESC;
```

### Inventory Status Check
```sql
SELECT 
    p.Name AS Product_Name,
    p.Category,
    i.Quantity AS Current_Stock,
    CASE 
        WHEN i.Quantity < 100 THEN 'CRITICAL'
        WHEN i.Quantity < 200 THEN 'LOW'
        ELSE 'ADEQUATE'
    END AS Stock_Status
FROM Product p
JOIN Inventory i ON p.Product_ID = i.Product_ID
ORDER BY i.Quantity ASC;
```

## Contributing

We welcome contributions to improve the pharmaceutical supply chain analytics platform. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Commit your changes (`git commit -m 'Add new analytics feature'`)
4. Push to the branch (`git push origin feature/enhancement`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. Please take a look at the [LICENSE](LICENSE) file for details.

## Authors and Acknowledgments

**Development Team**
- **Sheetal Anand Naik** - Database Design and Implementation
- **Lohith Vardireddygari** - Data Analysis and Visualization

**Academic Context**
- Developed for Database Management Systems coursework at Northeastern University
- Demonstrates advanced SQL techniques and healthcare data analytics
- Showcases integration of relational and NoSQL database technologies

## Contact Information

For questions, collaboration opportunities, or technical support:

- **Email**: naik.she@northeastern.edu
- **Project Repository**: [Pharmaceutical-Supply-Chain-Analytics](https://github.com/yourusername/Pharmaceutical-Supply-Chain-Analytics)

---

**⭐ Star this repository if you find it valuable for your healthcare analytics or database learning journey.**
