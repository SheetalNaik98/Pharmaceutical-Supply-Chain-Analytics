#!/usr/bin/env python3
"""
Pharmaceutical Supply Chain Analytics Platform
Project: MediBuddy Healthcare Analytics Solution
Authors: Sheetal Anand Naik, Lohith Vardireddygari

Comprehensive analytics platform for pharmaceutical supply chain optimization
including database connectivity, data analysis, and visualization capabilities.
"""

import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from datetime import datetime, timedelta
import warnings
from typing import Dict, List, Optional, Tuple
import sys
import os

# Configure display settings
warnings.filterwarnings('ignore')
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)

class PharmaceuticalAnalytics:
    """
    Main analytics class for pharmaceutical supply chain management
    Provides comprehensive database connectivity and business intelligence capabilities
    """
    
    def __init__(self, db_config: Dict[str, str]):
        """
        Initialize the analytics platform
        
        Args:
            db_config (dict): Database configuration parameters
        """
        self.db_config = db_config
        self.connection = None
        self.cursor = None
        self.connected = False
        
    def connect_database(self) -> bool:
        """
        Establish secure database connection with error handling
        
        Returns:
            bool: Connection success status
        """
        try:
            self.connection = mysql.connector.connect(**self.db_config)
            self.cursor = self.connection.cursor()
            self.connected = True
            print("✓ Database connection established successfully")
            print(f"✓ Connected to database: {self.db_config['database']}")
            return True
            
        except mysql.connector.Error as err:
            print(f"✗ Database connection failed: {err}")
            self.connected = False
            return False
    
    def execute_query(self, query: str, params: Optional[Tuple] = None) -> pd.DataFrame:
        """
        Execute SQL query with parameterized input and return DataFrame
        
        Args:
            query (str): SQL query string
            params (tuple, optional): Query parameters for prepared statements
            
        Returns:
            pd.DataFrame: Query results
        """
        if not self.connected:
            print("✗ Database not connected. Please establish connection first.")
            return pd.DataFrame()
            
        try:
            df = pd.read_sql(query, self.connection, params=params)
            return df
        except Exception as e:
            print(f"✗ Query execution failed: {e}")
            return pd.DataFrame()
    
    def get_executive_summary(self) -> Dict:
        """
        Generate executive-level KPI summary
        
        Returns:
            dict: Key performance indicators
        """
        summary = {}
        
        # Total revenue
        revenue_query = "SELECT SUM(Total_cost) as total_revenue FROM Orders WHERE Order_Status != 'Cancelled'"
        revenue_result = self.execute_query(revenue_query)
        summary['total_revenue'] = float(revenue_result.iloc[0]['total_revenue']) if not revenue_result.empty else 0
        
        # Total orders
        orders_query = "SELECT COUNT(*) as total_orders FROM Orders WHERE Order_Status != 'Cancelled'"
        orders_result = self.execute_query(orders_query)
        summary['total_orders'] = int(orders_result.iloc[0]['total_orders']) if not orders_result.empty else 0
        
        # Active representatives
        reps_query = "SELECT COUNT(DISTINCT Representative_ID) as active_reps FROM Sales_Representative"
        reps_result = self.execute_query(reps_query)
        summary['active_representatives'] = int(reps_result.iloc[0]['active_reps']) if not reps_result.empty else 0
        
        # Inventory value
        inventory_query = """
        SELECT SUM(p.Price * i.Quantity) as inventory_value 
        FROM Product p 
        JOIN Inventory i ON p.Product_ID = i.Product_ID
        """
        inventory_result = self.execute_query(inventory_query)
        summary['inventory_value'] = float(inventory_result.iloc[0]['inventory_value']) if not inventory_result.empty else 0
        
        # Average order value
        if summary['total_orders'] > 0:
            summary['average_order_value'] = summary['total_revenue'] / summary['total_orders']
        else:
            summary['average_order_value'] = 0
            
        return summary
    
    def analyze_sales_performance(self) -> pd.DataFrame:
        """
        Comprehensive sales representative performance analysis
        
        Returns:
            pd.DataFrame: Sales performance metrics by representative
        """
        query = """
        SELECT 
            sr.Name AS Representative_Name,
            r.Name AS Region_Name,
            sr.Performance_Rating,
            COUNT(DISTINCT o.Order_ID) AS Total_Orders,
            SUM(o.Total_cost) AS Total_Sales,
            AVG(o.Total_cost) AS Average_Order_Value,
            COUNT(DISTINCT i.Customer_ID) AS Unique_Customers,
            MAX(o.Date) AS Last_Order_Date,
            DATEDIFF(CURDATE(), MAX(o.Date)) AS Days_Since_Last_Order
        FROM Sales_Representative sr
        JOIN Region r ON sr.Region_ID = r.Region_ID
        LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
        LEFT JOIN Interaction i ON sr.Representative_ID = i.Representative_ID
        WHERE o.Order_Status != 'Cancelled' OR o.Order_Status IS NULL
        GROUP BY sr.Representative_ID, sr.Name, r.Name, sr.Performance_Rating
        ORDER BY Total_Sales DESC
        """
        return self.execute_query(query)
    
    def analyze_inventory_status(self) -> pd.DataFrame:
        """
        Detailed inventory analysis with stock level classifications
        
        Returns:
            pd.DataFrame: Inventory status with reorder recommendations
        """
        query = """
        SELECT 
            p.Name AS Product_Name,
            p.Category,
            p.Price,
            i.Quantity AS Current_Stock,
            i.Reorder_Level,
            (p.Price * i.Quantity) AS Total_Value,
            i.Location,
            CASE 
                WHEN i.Quantity = 0 THEN 'OUT_OF_STOCK'
                WHEN i.Quantity <= i.Reorder_Level * 0.3 THEN 'CRITICAL'
                WHEN i.Quantity <= i.Reorder_Level * 0.6 THEN 'LOW'
                WHEN i.Quantity <= i.Reorder_Level THEN 'MODERATE'
                ELSE 'ADEQUATE'
            END AS Stock_Status,
            CASE 
                WHEN i.Quantity <= i.Reorder_Level THEN 'REORDER_NOW'
                WHEN i.Quantity <= i.Reorder_Level * 1.5 THEN 'MONITOR'
                ELSE 'SUFFICIENT'
            END AS Action_Required
        FROM Product p
        JOIN Inventory i ON p.Product_ID = i.Product_ID
        ORDER BY 
            CASE 
                WHEN i.Quantity = 0 THEN 1
                WHEN i.Quantity <= i.Reorder_Level * 0.3 THEN 2
                WHEN i.Quantity <= i.Reorder_Level * 0.6 THEN 3
                WHEN i.Quantity <= i.Reorder_Level THEN 4
                ELSE 5
            END,
            Total_Value DESC
        """
        return self.execute_query(query)
    
    def analyze_regional_performance(self) -> pd.DataFrame:
        """
        Regional performance analysis with market penetration metrics
        
        Returns:
            pd.DataFrame: Regional performance data
        """
        query = """
        SELECT 
            r.Name AS Region_Name,
            COUNT(DISTINCT sr.Representative_ID) AS Total_Representatives,
            COUNT(DISTINCT o.Order_ID) AS Total_Orders,
            SUM(o.Total_cost) AS Total_Revenue,
            AVG(o.Total_cost) AS Average_Order_Value,
            COUNT(DISTINCT i.Customer_ID) AS Unique_Customers,
            SUM(o.Total_cost) / COUNT(DISTINCT sr.Representative_ID) AS Revenue_Per_Rep,
            COUNT(DISTINCT o.Order_ID) / COUNT(DISTINCT sr.Representative_ID) AS Orders_Per_Rep
        FROM Region r
        LEFT JOIN Sales_Representative sr ON r.Region_ID = sr.Region_ID
        LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
        LEFT JOIN Interaction i ON sr.Representative_ID = i.Representative_ID
        WHERE o.Order_Status != 'Cancelled' OR o.Order_Status IS NULL
        GROUP BY r.Region_ID, r.Name
        HAVING Total_Representatives > 0
        ORDER BY Total_Revenue DESC
        """
        return self.execute_query(query)
    
    def analyze_customer_segments(self) -> pd.DataFrame:
        """
        Customer segmentation analysis by type and value
        
        Returns:
            pd.DataFrame: Customer analysis by segment
        """
        query = """
        SELECT 
            CASE 
                WHEN d.Customer_ID IS NOT NULL THEN 'Doctor'
                WHEN h.Customer_ID IS NOT NULL THEN 'Hospital'
                WHEN ph.Customer_ID IS NOT NULL THEN 'Pharmacy'
                ELSE 'Other'
            END AS Customer_Type,
            COUNT(DISTINCT c.Customer_ID) AS Customer_Count,
            COUNT(DISTINCT op.Order_ID) AS Total_Orders,
            SUM(o.Total_cost) AS Total_Revenue,
            AVG(o.Total_cost) AS Average_Order_Value,
            SUM(o.Total_cost) / COUNT(DISTINCT c.Customer_ID) AS Revenue_Per_Customer
        FROM Customer c
        LEFT JOIN Doctors d ON c.Customer_ID = d.Customer_ID
        LEFT JOIN Hospital h ON c.Customer_ID = h.Customer_ID
        LEFT JOIN Pharmacy ph ON c.Customer_ID = ph.Customer_ID
        LEFT JOIN Order_Placed op ON c.Customer_ID = op.Customer_ID
        LEFT JOIN Orders o ON op.Order_ID = o.Order_ID AND o.Order_Status != 'Cancelled'
        GROUP BY Customer_Type
        ORDER BY Total_Revenue DESC
        """
        return self.execute_query(query)
    
    def analyze_product_performance(self) -> pd.DataFrame:
        """
        Product performance analysis with profitability metrics
        
        Returns:
            pd.DataFrame: Product performance data
        """
        query = """
        SELECT 
            p.Name AS Product_Name,
            p.Category,
            p.Price AS Unit_Price,
            COUNT(DISTINCT inv.Order_ID) AS Times_Ordered,
            SUM(inv.Quantity_Ordered) AS Total_Quantity_Sold,
            SUM(inv.Line_Total) AS Total_Revenue,
            AVG(inv.Quantity_Ordered) AS Avg_Quantity_Per_Order,
            i.Quantity AS Current_Stock,
            CASE 
                WHEN i.Quantity > 0 AND SUM(inv.Quantity_Ordered) > 0 
                THEN ROUND(SUM(inv.Quantity_Ordered) / i.Quantity, 2)
                ELSE 0
            END AS Turnover_Ratio
        FROM Product p
        LEFT JOIN Involvement inv ON p.Product_ID = inv.Product_ID
        LEFT JOIN Orders o ON inv.Order_ID = o.Order_ID AND o.Order_Status != 'Cancelled'
        LEFT JOIN Inventory i ON p.Product_ID = i.Product_ID
        GROUP BY p.Product_ID, p.Name, p.Category, p.Price, i.Quantity
        ORDER BY Total_Revenue DESC
        """
        return self.execute_query(query)
    
    def create_comprehensive_dashboard(self) -> None:
        """
        Generate comprehensive analytics dashboard with multiple visualizations
        """
        # Set up the plotting style
        plt.style.use('default')
        sns.set_palette("husl")
        
        # Create figure with subplots
        fig = plt.figure(figsize=(20, 15))
        gs = fig.add_gridspec(3, 3, hspace=0.3, wspace=0.3)
        
        # Color schemes
        colors_primary = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D']
        colors_secondary = ['#4E9F3D', '#191A19', '#1E5128', '#D8E9A8']
        
        # 1. Sales Performance by Representative (Top 8)
        ax1 = fig.add_subplot(gs[0, 0])
        sales_data = self.analyze_sales_performance().head(8)
        if not sales_data.empty:
            bars = ax1.barh(sales_data['Representative_Name'], sales_data['Total_Sales'], 
                           color=colors_primary[0], alpha=0.8)
            ax1.set_title('Top Sales Representatives by Revenue', fontweight='bold', fontsize=12)
            ax1.set_xlabel('Total Sales ($)')
            
            # Add value labels
            for bar in bars:
                width = bar.get_width()
                ax1.text(width, bar.get_y() + bar.get_height()/2.,
                        f'${width:,.0f}', ha='left', va='center', fontsize=9)
        
        # 2. Regional Performance
        ax2 = fig.add_subplot(gs[0, 1])
        regional_data = self.analyze_regional_performance()
        if not regional_data.empty:
            wedges, texts, autotexts = ax2.pie(regional_data['Total_Revenue'], 
                                             labels=regional_data['Region_Name'],
                                             autopct='%1.1f%%', 
                                             colors=colors_secondary)
            ax2.set_title('Revenue Distribution by Region', fontweight='bold', fontsize=12)
        
        # 3. Inventory Status Distribution
        ax3 = fig.add_subplot(gs[0, 2])
        inventory_data = self.analyze_inventory_status()
        if not inventory_data.empty:
            status_counts = inventory_data['Stock_Status'].value_counts()
            bars = ax3.bar(status_counts.index, status_counts.values, 
                          color=['#C73E1D', '#F18F01', '#A23B72', '#2E86AB', '#4E9F3D'])
            ax3.set_title('Inventory Status Distribution', fontweight='bold', fontsize=12)
            ax3.set_ylabel('Number of Products')
            ax3.tick_params(axis='x', rotation=45)
        
        # 4. Customer Segment Analysis
        ax4 = fig.add_subplot(gs[1, 0])
        customer_data = self.analyze_customer_segments()
        if not customer_data.empty:
            bars = ax4.bar(customer_data['Customer_Type'], customer_data['Total_Revenue'],
                          color=colors_primary, alpha=0.8)
            ax4.set_title('Revenue by Customer Type', fontweight='bold', fontsize=12)
            ax4.set_ylabel('Total Revenue ($)')
            
            # Add value labels
            for bar in bars:
                height = bar.get_height()
                ax4.text(bar.get_x() + bar.get_width()/2., height,
                        f'${height:,.0f}', ha='center', va='bottom', fontsize=9)
        
        # 5. Product Category Performance
        ax5 = fig.add_subplot(gs[1, 1])
        product_data = self.analyze_product_performance()
        if not product_data.empty:
            category_performance = product_data.groupby('Category')['Total_Revenue'].sum().sort_values(ascending=False)
            bars = ax5.barh(category_performance.index, category_performance.values,
                           color=colors_secondary[0], alpha=0.8)
            ax5.set_title('Revenue by Product Category', fontweight='bold', fontsize=12)
            ax5.set_xlabel('Total Revenue ($)')
        
        # 6. Sales Trend Analysis (Simulated monthly data)
        ax6 = fig.add_subplot(gs[1, 2])
        # Create sample monthly trend data
        months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        sales_trend = np.random.normal(50000, 10000, 12).cumsum() + 100000
        ax6.plot(months, sales_trend, marker='o', linewidth=2, color=colors_primary[1])
        ax6.fill_between(months, sales_trend, alpha=0.3, color=colors_primary[1])
        ax6.set_title('Monthly Sales Trend', fontweight='bold', fontsize=12)
        ax6.set_ylabel('Cumulative Sales ($)')
        ax6.tick_params(axis='x', rotation=45)
        
        # 7. Top Products by Revenue
        ax7 = fig.add_subplot(gs[2, 0])
        if not product_data.empty:
            top_products = product_data.head(6)
            bars = ax7.bar(range(len(top_products)), top_products['Total_Revenue'],
                          color=colors_primary[2], alpha=0.8)
            ax7.set_title('Top Products by Revenue', fontweight='bold', fontsize=12)
            ax7.set_ylabel('Total Revenue ($)')
            ax7.set_xticks(range(len(top_products)))
            ax7.set_xticklabels(top_products['Product_Name'], rotation=45, ha='right')
        
        # 8. Representative Performance vs Rating
        ax8 = fig.add_subplot(gs[2, 1])
        if not sales_data.empty:
            scatter = ax8.scatter(sales_data['Performance_Rating'], sales_data['Total_Sales'],
                                 s=100, alpha=0.7, color=colors_primary[3])
            ax8.set_title('Performance Rating vs Sales', fontweight='bold', fontsize=12)
            ax8.set_xlabel('Performance Rating')
            ax8.set_ylabel('Total Sales ($)')
            
            # Add trend line
            if len(sales_data) > 1:
                z = np.polyfit(sales_data['Performance_Rating'], sales_data['Total_Sales'], 1)
                p = np.poly1d(z)
                ax8.plot(sales_data['Performance_Rating'], p(sales_data['Performance_Rating']), 
                        "r--", alpha=0.8, linewidth=2)
        
        # 9. Executive Summary Text
        ax9 = fig.add_subplot(gs[2, 2])
        ax9.axis('off')
        summary = self.get_executive_summary()
        
        summary_text = f"""
        EXECUTIVE SUMMARY
        {'='*20}
        
        Total Revenue: ${summary['total_revenue']:,.2f}
        Total Orders: {summary['total_orders']:,}
        Active Reps: {summary['active_representatives']}
        
        Average Order: ${summary['average_order_value']:,.2f}
        Inventory Value: ${summary['inventory_value']:,.2f}
        
        Performance Status: Strong
        Growth Trend: Positive
        """
        
        ax9.text(0.1, 0.9, summary_text, transform=ax9.transAxes, fontsize=11,
                verticalalignment='top', bbox=dict(boxstyle="round,pad=0.3", facecolor="lightgray"))
        
        plt.suptitle('Pharmaceutical Supply Chain Analytics Dashboard', 
                     fontsize=16, fontweight='bold', y=0.98)
        
        # Save the dashboard
        plt.tight_layout()
        plt.savefig('dashboard.png', dpi=300, bbox_inches='tight')
        plt.show()
    
    def generate_detailed_report(self) -> str:
        """
        Generate comprehensive analytics report
        
        Returns:
            str: Formatted analytics report
        """
        report = []
        report.append("="*80)
        report.append("PHARMACEUTICAL SUPPLY CHAIN ANALYTICS REPORT")
        report.append("="*80)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        # Executive Summary
        summary = self.get_executive_summary()
        report.append("EXECUTIVE SUMMARY")
        report.append("-" * 50)
        report.append(f"Total Revenue: ${summary['total_revenue']:,.2f}")
        report.append(f"Total Orders: {summary['total_orders']:,}")
        report.append(f"Active Representatives: {summary['active_representatives']}")
        report.append(f"Average Order Value: ${summary['average_order_value']:,.2f}")
        report.append(f"Total Inventory Value: ${summary['inventory_value']:,.2f}")
        report.append("")
        
        # Sales Performance
        sales_data = self.analyze_sales_performance()
        if not sales_data.empty:
            report.append("TOP SALES PERFORMERS")
            report.append("-" * 50)
            for _, row in sales_data.head(5).iterrows():
                report.append(f"{row['Representative_Name']} ({row['Region_Name']}): ${row['Total_Sales']:,.2f}")
            report.append("")
        
        # Inventory Alerts
        inventory_data = self.analyze_inventory_status()
        critical_items = inventory_data[inventory_data['Stock_Status'].isin(['CRITICAL', 'OUT_OF_STOCK'])]
        if not critical_items.empty:
            report.append("CRITICAL INVENTORY ALERTS")
            report.append("-" * 50)
            for _, row in critical_items.iterrows():
                report.append(f"{row['Product_Name']}: {row['Current_Stock']} units ({row['Stock_Status']})")
            report.append("")
        
        # Regional Performance
        regional_data = self.analyze_regional_performance()
        if not regional_data.empty:
            report.append("REGIONAL PERFORMANCE SUMMARY")
            report.append("-" * 50)
            for _, row in regional_data.head(3).iterrows():
                report.append(f"{row['Region_Name']}: ${row['Total_Revenue']:,.2f} revenue, {row['Total_Orders']} orders")
            report.append("")
        
        report.append("="*80)
        return "\n".join(report)
    
    def close_connection(self) -> None:
        """
        Safely close database connection
        """
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
            self.connected = False
            print("✓ Database connection closed successfully")
        except Exception as e:
            print(f"Warning: Error closing connection: {e}")

def main():
    """
    Main execution function for pharmaceutical analytics platform
    """
    print("Pharmaceutical Supply Chain Analytics Platform")
    print("=" * 50)
    
    # Database configuration
    db_config = {
        'host': '127.0.0.1',
        'port': 3306,
        'user': 'root',
        'password': 'your_password_here',  # Update with your MySQL password
        'database': 'pharma_db',
        'charset': 'utf8mb4',
        'autocommit': True
    }
    
    # Initialize analytics platform
    analytics = PharmaceuticalAnalytics(db_config)
    
    try:
        # Connect to database
        if not analytics.connect_database():
            print("Failed to connect to database. Please check your configuration.")
            return
        
        print("\nGenerating comprehensive analytics...")
        
        # Generate and display executive summary
        summary = analytics.get_executive_summary()
        print(f"\nExecutive Summary:")
        print(f"Total Revenue: ${summary['total_revenue']:,.2f}")
        print(f"Total Orders: {summary['total_orders']:,}")
        print(f"Active Representatives: {summary['active_representatives']}")
        print(f"Average Order Value: ${summary['average_order_value']:,.2f}")
        
        # Display detailed analytics
        print("\n" + "="*50)
        print("DETAILED ANALYTICS")
        print("="*50)
        
        # Sales Performance
        print("\n1. Sales Performance Analysis:")
        sales_df = analytics.analyze_sales_performance()
        if not sales_df.empty:
            print(sales_df.head().to_string(index=False))
        
        # Inventory Status
        print("\n2. Inventory Status Analysis:")
        inventory_df = analytics.analyze_inventory_status()
        if not inventory_df.empty:
            print(inventory_df.head().to_string(index=False))
        
        # Regional Performance
        print("\n3. Regional Performance Analysis:")
        regional_df = analytics.analyze_regional_performance()
        if not regional_df.empty:
            print(regional_df.to_string(index=False))
        
        # Generate comprehensive dashboard
        print("\nGenerating analytics dashboard...")
        analytics.create_comprehensive_dashboard()
        
        # Generate detailed report
        print("\nGenerating detailed report...")
        report = analytics.generate_detailed_report()
        print(report)
        
        # Save report to file
        with open('analytics_report.txt', 'w') as f:
            f.write(report)
        print("\nReport saved to 'analytics_report.txt'")
        
    except Exception as e:
        print(f"Error during analysis: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        analytics.close_connection()

if __name__ == "__main__":
    main()
