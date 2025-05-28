-- =====================================================
-- Pharmaceutical Supply Chain Database Schema
-- Project: MediBuddy Healthcare Analytics Solution
-- Authors: Sheetal Anand Naik, Lohith Vardireddygari
-- Database: MySQL 8.0+
-- =====================================================

-- Create and use database
CREATE DATABASE IF NOT EXISTS pharma_db;
USE pharma_db;

-- Drop existing tables if they exist (for clean setup)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Involvement;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Order_Placed;
DROP TABLE IF EXISTS Allocation;
DROP TABLE IF EXISTS Shipping;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Interaction;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS Pharmacy;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Sales_Representative;
DROP TABLE IF EXISTS Region;
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- CORE ENTITY TABLES
-- =====================================================

-- Region table for geographical management
CREATE TABLE Region (
    Region_ID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Representative management
CREATE TABLE Sales_Representative (
    Representative_ID INT PRIMARY KEY NOT NULL,
    Region_ID INT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    Phone VARCHAR(20),
    Hire_Date DATE,
    Performance_Rating DECIMAL(3,2),
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
);

-- Customer base table
CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Contact_Details VARCHAR(200),
    Address VARCHAR(300),
    Registration_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Active', 'Inactive', 'Pending') DEFAULT 'Active'
);

-- Product catalog
CREATE TABLE Product (
    Product_ID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Description TEXT,
    Manufacturer VARCHAR(100),
    Expiry_Date DATE,
    FDA_Approved BOOLEAN DEFAULT TRUE,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipment tracking
CREATE TABLE Shipment (
    Shipment_ID INT PRIMARY KEY NOT NULL,
    Date DATE NOT NULL,
    Interaction_Type ENUM('In-Person', 'Phone', 'Email', 'Online') NOT NULL,
    Status ENUM('Pending', 'In-Transit', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    Tracking_Number VARCHAR(50),
    Estimated_Delivery DATE,
    Created_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order management
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY NOT NULL,
    Date DATE NOT NULL,
    Total_cost DECIMAL(10, 2) NOT NULL,
    Representative_ID INT,
    Shipment_ID INT,
    Order_Status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    Priority_Level ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    FOREIGN KEY (Representative_ID) REFERENCES Sales_Representative(Representative_ID),
    FOREIGN KEY (Shipment_ID) REFERENCES Shipment(Shipment_ID)
);

-- Inventory management
CREATE TABLE Inventory (
    Inventory_ID INT PRIMARY KEY NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    Reorder_Level INT DEFAULT 100,
    Last_Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Location VARCHAR(100),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- =====================================================
-- RELATIONSHIP TABLES
-- =====================================================

-- Sales Representative-Customer interactions
CREATE TABLE Interaction (
    Representative_ID INT,
    Customer_ID INT,
    Interaction_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Interaction_Notes TEXT,
    Follow_Up_Required BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (Representative_ID, Customer_ID),
    FOREIGN KEY (Representative_ID) REFERENCES Sales_Representative(Representative_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Shipment-Product relationships
CREATE TABLE Shipping (
    Shipment_ID INT,
    Product_ID INT,
    Quantity_Shipped INT NOT NULL CHECK (Quantity_Shipped > 0),
    Unit_Price DECIMAL(10, 2),
    PRIMARY KEY (Shipment_ID, Product_ID),
    FOREIGN KEY (Shipment_ID) REFERENCES Shipment(Shipment_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Regional shipment allocation
CREATE TABLE Allocation (
    Shipment_ID INT,
    Region_ID INT,
    Allocation_Percentage DECIMAL(5, 2) DEFAULT 100.00,
    PRIMARY KEY (Shipment_ID, Region_ID),
    FOREIGN KEY (Shipment_ID) REFERENCES Shipment(Shipment_ID),
    FOREIGN KEY (Region_ID) REFERENCES Region(Region_ID)
);

-- Customer order relationships
CREATE TABLE Order_Placed (
    Order_ID INT,
    Customer_ID INT,
    Order_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Order_ID, Customer_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Product involvement in orders
CREATE TABLE Involvement (
    Order_ID INT,
    Product_ID INT,
    Quantity_Ordered INT NOT NULL CHECK (Quantity_Ordered > 0),
    Unit_Price DECIMAL(10, 2),
    Line_Total DECIMAL(10, 2),
    PRIMARY KEY (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- =====================================================
-- SPECIALIZED CUSTOMER TABLES
-- =====================================================

-- Doctor specialization
CREATE TABLE Doctors (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact_Details VARCHAR(200),
    Speciality VARCHAR(100) NOT NULL,
    License_Number VARCHAR(50) UNIQUE,
    Medical_School VARCHAR(150),
    Years_Experience INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Pharmacy information
CREATE TABLE Pharmacy (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact_Details VARCHAR(200),
    License_Number VARCHAR(50) UNIQUE NOT NULL,
    Chain_Affiliation VARCHAR(100),
    Operating_Hours VARCHAR(100),
    DEA_Number VARCHAR(20),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Hospital details
CREATE TABLE Hospital (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact_Details VARCHAR(200),
    Hospital_Type ENUM('General', 'Specialized', 'Teaching', 'Research', 'Rehabilitation') NOT NULL,
    Bed_Capacity INT,
    Accreditation VARCHAR(100),
    Emergency_Services BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert Regions
INSERT INTO Region (Region_ID, Name, Description) VALUES
(1, 'North America', 'Primary market covering US and Canada'),
(2, 'South', 'Southern United States region'),
(3, 'East', 'Eastern seaboard operations'),
(4, 'West', 'Western states coverage'),
(5, 'Central', 'Central United States hub'),
(6, 'Northeast', 'Northeast corridor markets'),
(7, 'Southeast', 'Southeast regional operations'),
(8, 'Northwest', 'Pacific Northwest territory'),
(9, 'Southwest', 'Southwest regional coverage'),
(10, 'Midwest', 'Midwest distribution center');

-- Insert Sales Representatives
INSERT INTO Sales_Representative (Representative_ID, Region_ID, Name, Email, Phone, Hire_Date, Performance_Rating) VALUES
(1, 1, 'John Doe', 'john.doe@medibuddy.com', '555-0101', '2022-01-15', 4.2),
(2, 2, 'Jane Smith', 'jane.smith@medibuddy.com', '555-0102', '2021-03-22', 4.7),
(3, 3, 'Bob Johnson', 'bob.johnson@medibuddy.com', '555-0103', '2022-06-10', 3.9),
(4, 4, 'Alice Williams', 'alice.williams@medibuddy.com', '555-0104', '2021-11-08', 4.5),
(5, 5, 'Charlie Brown', 'charlie.brown@medibuddy.com', '555-0105', '2022-02-28', 4.1),
(6, 6, 'Eva Davis', 'eva.davis@medibuddy.com', '555-0106', '2021-09-14', 4.8),
(7, 7, 'Frank Miller', 'frank.miller@medibuddy.com', '555-0107', '2022-04-03', 3.8),
(8, 8, 'Grace Taylor', 'grace.taylor@medibuddy.com', '555-0108', '2021-12-20', 4.3),
(9, 9, 'Henry Clark', 'henry.clark@medibuddy.com', '555-0109', '2022-07-15', 4.0),
(10, 10, 'Isabel Martinez', 'isabel.martinez@medibuddy.com', '555-0110', '2021-08-05', 4.6);

-- Insert Products
INSERT INTO Product (Product_ID, Name, Category, Price, Description, Manufacturer, FDA_Approved) VALUES
(1, 'Aspirin', 'Pain Relief', 29.99, 'Acetylsalicylic acid tablets 325mg', 'PharmaCorp', TRUE),
(2, 'Ibuprofen', 'Anti-inflammatory', 49.99, 'Nonsteroidal anti-inflammatory drug 200mg', 'MediGen', TRUE),
(3, 'Amoxicillin', 'Antibiotics', 19.99, 'Penicillin antibiotic 500mg capsules', 'BioPharm', TRUE),
(4, 'Lipitor', 'Cholesterol Management', 89.99, 'Atorvastatin calcium tablets 20mg', 'HeartCare', TRUE),
(5, 'Prozac', 'Mental Health', 79.99, 'Fluoxetine hydrochloride 20mg capsules', 'MindWell', TRUE),
(6, 'Insulin', 'Diabetes Management', 124.99, 'Human insulin injection 100 units/mL', 'DiabetCare', TRUE),
(7, 'Morphine', 'Pain Management', 199.99, 'Morphine sulfate tablets 30mg', 'PainRelief Inc', TRUE),
(8, 'Vitamin C', 'Supplements', 24.99, 'Ascorbic acid tablets 1000mg', 'VitaHealth', TRUE),
(9, 'Omeprazole', 'Digestive Health', 39.99, 'Proton pump inhibitor 20mg capsules', 'GastroMed', TRUE),
(10, 'Fluoxetine', 'Mental Health', 64.99, 'Selective serotonin reuptake inhibitor 40mg', 'PsychCare', TRUE);

-- Insert Customers
INSERT INTO Customer (Customer_ID, Name, Contact_Details, Address, Status) VALUES
(1, 'Metropolitan General Hospital', 'contact@metrohealth.com', '123 Hospital Boulevard, Metro City', 'Active'),
(2, 'Dr. Sarah Johnson', 'dr.johnson@healthcenter.com', '456 Medical Plaza, Suite 200', 'Active'),
(3, 'City Pharmacy Network', 'orders@citypharmacy.com', '789 Main Street, Downtown', 'Active'),
(4, 'Regional Medical Center', 'purchasing@regionalmed.org', '321 Healthcare Drive', 'Active'),
(5, 'Dr. Michael Chen', 'mchen@specialtycare.com', '654 Specialty Lane, Medical District', 'Active'),
(6, 'Community Health Pharmacy', 'admin@communityrx.com', '987 Community Road', 'Active');

-- Insert specialized customer records
INSERT INTO Doctors (Customer_ID, Name, Contact_Details, Speciality, License_Number, Years_Experience) VALUES
(2, 'Dr. Sarah Johnson', 'dr.johnson@healthcenter.com', 'Cardiology', 'MD-12345', 15),
(5, 'Dr. Michael Chen', 'mchen@specialtycare.com', 'Pediatrics', 'MD-67890', 12);

INSERT INTO Hospital (Customer_ID, Name, Contact_Details, Hospital_Type, Bed_Capacity, Emergency_Services) VALUES
(1, 'Metropolitan General Hospital', 'contact@metrohealth.com', 'General', 500, TRUE),
(4, 'Regional Medical Center', 'purchasing@regionalmed.org', 'Specialized', 250, TRUE);

INSERT INTO Pharmacy (Customer_ID, Name, Contact_Details, License_Number, Operating_Hours) VALUES
(3, 'City Pharmacy Network', 'orders@citypharmacy.com', 'PH-54321', '24/7'),
(6, 'Community Health Pharmacy', 'admin@communityrx.com', 'PH-98765', 'Mon-Sat 8AM-10PM');

-- Insert Inventory
INSERT INTO Inventory (Inventory_ID, Product_ID, Quantity, Reorder_Level, Location) VALUES
(1, 1, 500, 100, 'Warehouse A-1'),
(2, 2, 300, 75, 'Warehouse A-2'),
(3, 3, 450, 120, 'Warehouse B-1'),
(4, 4, 200, 50, 'Warehouse B-2'),
(5, 5, 150, 40, 'Warehouse C-1'),
(6, 6, 75, 25, 'Cold Storage-1'),
(7, 7, 60, 20, 'Secure Storage-1'),
(8, 8, 800, 200, 'Warehouse A-3'),
(9, 9, 350, 100, 'Warehouse B-3'),
(10, 10, 180, 50, 'Warehouse C-2');

-- Insert Shipments
INSERT INTO Shipment (Shipment_ID, Date, Interaction_Type, Status, Tracking_Number) VALUES
(1, '2023-11-15', 'In-Person', 'Delivered', 'TRK001'),
(2, '2023-11-20', 'Phone', 'In-Transit', 'TRK002'),
(3, '2023-11-10', 'Email', 'Delivered', 'TRK003'),
(4, '2023-11-25', 'Online', 'Processing', 'TRK004'),
(5, '2023-11-12', 'Phone', 'Delivered', 'TRK005'),
(6, '2023-11-18', 'In-Person', 'In-Transit', 'TRK006');

-- Insert Orders
INSERT INTO Orders (Order_ID, Date, Total_cost, Representative_ID, Shipment_ID, Order_Status) VALUES
(1, '2023-11-15', 299.99, 1, 1, 'Delivered'),
(2, '2023-11-20', 149.99, 2, 2, 'Shipped'),
(3, '2023-11-10', 89.99, 3, 3, 'Delivered'),
(4, '2023-11-25', 199.99, 4, 4, 'Processing'),
(5, '2023-11-12', 79.99, 5, 5, 'Delivered'),
(6, '2023-11-18', 124.99, 6, 6, 'Shipped');

-- Create indexes for performance optimization
CREATE INDEX idx_sales_rep_region ON Sales_Representative(Region_ID);
CREATE INDEX idx_orders_rep ON Orders(Representative_ID);
CREATE INDEX idx_orders_date ON Orders(Date);
CREATE INDEX idx_inventory_product ON Inventory(Product_ID);
CREATE INDEX idx_product_category ON Product(Category);

-- Create views for common queries
CREATE VIEW Sales_Performance AS
SELECT 
    sr.Name AS Representative_Name,
    r.Name AS Region_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Total_cost) AS Total_Sales,
    AVG(o.Total_cost) AS Average_Order_Value
FROM Sales_Representative sr
JOIN Region r ON sr.Region_ID = r.Region_ID
LEFT JOIN Orders o ON sr.Representative_ID = o.Representative_ID
GROUP BY sr.Representative_ID, sr.Name, r.Name;

CREATE VIEW Low_Stock_Alert AS
SELECT 
    p.Name AS Product_Name,
    p.Category,
    i.Quantity AS Current_Stock,
    i.Reorder_Level,
    CASE 
        WHEN i.Quantity <= i.Reorder_Level * 0.5 THEN 'CRITICAL'
        WHEN i.Quantity <= i.Reorder_Level THEN 'LOW'
        ELSE 'ADEQUATE'
    END AS Stock_Status
FROM Product p
JOIN Inventory i ON p.Product_ID = i.Product_ID
WHERE i.Quantity <= i.Reorder_Level
ORDER BY i.Quantity ASC;

COMMIT;

-- Display setup confirmation
SELECT 'Database setup completed successfully!' AS Status;
