// =====================================================
// MongoDB NoSQL Implementation for Pharmaceutical Supply Chain
// Demonstrates document-based database design and queries
// =====================================================

// Database: pharma_nosql
// Collections: representatives, customers, products, orders, inventory

// =====================================================
// COLLECTION SCHEMA DEFINITIONS
// =====================================================

// Representatives Collection Schema
const representativeSchema = {
    _id: ObjectId(),
    representative_id: Number,
    name: String,
    email: String,
    phone: String,
    region: {
        region_id: Number,
        name: String,
        description: String
    },
    performance_rating: Number,
    hire_date: Date,
    customers_managed: [Number], // Array of customer IDs
    sales_metrics: {
        total_sales: Number,
        total_orders: Number,
        average_order_value: Number,
        last_sale_date: Date
    },
    created_at: Date,
    updated_at: Date
};

// Customers Collection Schema (Embedded customer types)
const customerSchema = {
    _id: ObjectId(),
    customer_id: Number,
    name: String,
    contact_details: String,
    address: String,
    status: String, // "Active", "Inactive", "Pending"
    customer_type: String, // "Doctor", "Hospital", "Pharmacy"
    
    // Conditional fields based on customer type
    doctor_info: {
        speciality: String,
        license_number: String,
        medical_school: String,
        years_experience: Number
    },
    
    hospital_info: {
        hospital_type: String,
        bed_capacity: Number,
        accreditation: String,
        emergency_services: Boolean
    },
    
    pharmacy_info: {
        license_number: String,
        chain_affiliation: String,
        operating_hours: String,
        dea_number: String
    },
    
    order_history: {
        total_orders: Number,
        total_spent: Number,
        last_order_date: Date,
        average_order_value: Number
    },
    
    registration_date: Date,
    last_interaction: Date
};

// Products Collection Schema
const productSchema = {
    _id: ObjectId(),
    product_id: Number,
    name: String,
    category: String,
    price: Number,
    description: String,
    manufacturer: String,
    expiry_date: Date,
    fda_approved: Boolean,
    
    inventory_info: {
        current_stock: Number,
        reorder_level: Number,
        location: String,
        last_updated: Date
    },
    
    sales_metrics: {
        total_sold: Number,
        revenue_generated: Number,
        times_ordered: Number,
        turnover_ratio: Number
    },
    
    created_date: Date
};

// Orders Collection Schema (Denormalized with embedded details)
const orderSchema = {
    _id: ObjectId(),
    order_id: Number,
    order_date: Date,
    total_cost: Number,
    order_status: String,
    priority_level: String,
    
    representative: {
        representative_id: Number,
        name: String,
        region_name: String
    },
    
    customer: {
        customer_id: Number,
        name: String,
        customer_type: String
    },
    
    line_items: [
        {
            product_id: Number,
            product_name: String,
            quantity_ordered: Number,
            unit_price: Number,
            line_total: Number
        }
    ],
    
    shipment_info: {
        shipment_id: Number,
        interaction_type: String,
        tracking_number: String,
        shipment_status: String,
        estimated_delivery: Date
    },
    
    created_at: Date,
    updated_at: Date
};

// =====================================================
// SAMPLE DATA INSERTION
// =====================================================

// Insert Sample Representatives
db.representatives.insertMany([
    {
        representative_id: 1,
        name: "John Doe",
        email: "john.doe@medibuddy.com",
        phone: "555-0101",
        region: {
            region_id: 1,
            name: "North America",
            description: "Primary market covering US and Canada"
        },
        performance_rating: 4.2,
        hire_date: new Date("2022-01-15"),
        customers_managed: [1, 2, 3],
        sales_metrics: {
            total_sales: 89750.50,
            total_orders: 45,
            average_order_value: 1994.45,
            last_sale_date: new Date("2023-11-20")
        },
        created_at: new Date(),
        updated_at: new Date()
    },
    {
        representative_id: 2,
        name: "Jane Smith",
        email: "jane.smith@medibuddy.com",
        phone: "555-0102",
        region: {
            region_id: 2,
            name: "South",
            description: "Southern United States region"
        },
        performance_rating: 4.7,
        hire_date: new Date("2021-03-22"),
        customers_managed: [4, 5, 6],
        sales_metrics: {
            total_sales: 125300.75,
            total_orders: 62,
            average_order_value: 2021.00,
            last_sale_date: new Date("2023-11-18")
        },
        created_at: new Date(),
        updated_at: new Date()
    }
]);

// Insert Sample Customers
db.customers.insertMany([
    {
        customer_id: 1,
        name: "Metropolitan General Hospital",
        contact_details: "contact@metrohealth.com",
        address: "123 Hospital Boulevard, Metro City",
        status: "Active",
        customer_type: "Hospital",
        
        hospital_info: {
            hospital_type: "General",
            bed_capacity: 500,
            accreditation: "Joint Commission",
            emergency_services: true
        },
        
        order_history: {
            total_orders: 25,
            total_spent: 45750.00,
            last_order_date: new Date("2023-11-15"),
            average_order_value: 1830.00
        },
        
        registration_date: new Date("2022-01-10"),
        last_interaction: new Date("2023-11-20")
    },
    {
        customer_id: 2,
        name: "Dr. Sarah Johnson",
        contact_details: "dr.johnson@healthcenter.com",
        address: "456 Medical Plaza, Suite 200",
        status: "Active",
        customer_type: "Doctor",
        
        doctor_info: {
            speciality: "Cardiology",
            license_number: "MD-12345",
            medical_school: "Harvard Medical School",
            years_experience: 15
        },
        
        order_history: {
            total_orders: 18,
            total_spent: 12750.50,
            last_order_date: new Date("2023-11-12"),
            average_order_value: 708.36
        },
        
        registration_date: new Date("2021-08-15"),
        last_interaction: new Date("2023-11-12")
    }
]);

// Insert Sample Products
db.products.insertMany([
    {
        product_id: 1,
        name: "Aspirin",
        category: "Pain Relief",
        price: 29.99,
        description: "Acetylsalicylic acid tablets 325mg",
        manufacturer: "PharmaCorp",
        expiry_date: new Date("2025-12-31"),
        fda_approved: true,
        
        inventory_info: {
            current_stock: 500,
            reorder_level: 100,
            location: "Warehouse A-1",
            last_updated: new Date()
        },
        
        sales_metrics: {
            total_sold: 2500,
            revenue_generated: 74975.00,
            times_ordered: 125,
            turnover_ratio: 5.0
        },
        
        created_date: new Date("2022-01-01")
    }
]);

// =====================================================
// ADVANCED MONGODB QUERIES
// =====================================================

// Query 1: Sales Performance Analysis with Aggregation Pipeline
db.representatives.aggregate([
    {
        $match: { "sales_metrics.total_sales": { $gt: 50000 } }
    },
    {
        $lookup: {
            from: "orders",
            localField: "representative_id",
            foreignField: "representative.representative_id",
            as: "orders"
        }
    },
    {
        $project: {
            name: 1,
            "region.name": 1,
            performance_rating: 1,
            "sales_metrics.total_sales": 1,
            order_count: { $size: "$orders" },
            efficiency_score: {
                $multiply: [
                    "$performance_rating",
                    { $divide: ["$sales_metrics.total_sales", 10000] }
                ]
            }
        }
    },
    {
        $sort: { efficiency_score: -1 }
    }
]);

// Query 2: Customer Segmentation and Value Analysis
db.customers.aggregate([
    {
        $group: {
            _id: "$customer_type",
            customer_count: { $sum: 1 },
            total_revenue: { $sum: "$order_history.total_spent" },
            average_order_value: { $avg: "$order_history.average_order_value" },
            total_orders: { $sum: "$order_history.total_orders" }
        }
    },
    {
        $project: {
            customer_type: "$_id",
            customer_count: 1,
            total_revenue: 1,
            average_order_value: { $round: ["$average_order_value", 2] },
            total_orders: 1,
            revenue_per_customer: {
                $round: [{ $divide: ["$total_revenue", "$customer_count"] }, 2]
            }
        }
    },
    {
        $sort: { total_revenue: -1 }
    }
]);

// Query 3: Product Performance and Inventory Analysis
db.products.aggregate([
    {
        $project: {
            name: 1,
            category: 1,
            price: 1,
            current_stock: "$inventory_info.current_stock",
            reorder_level: "$inventory_info.reorder_level",
            total_revenue: "$sales_metrics.revenue_generated",
            turnover_ratio: "$sales_metrics.turnover_ratio",
            inventory_value: {
                $multiply: ["$price", "$inventory_info.current_stock"]
            },
            stock_status: {
                $switch: {
                    branches: [
                        {
                            case: { $eq: ["$inventory_info.current_stock", 0] },
                            then: "OUT_OF_STOCK"
                        },
                        {
                            case: {
                                $lte: [
                                    "$inventory_info.current_stock",
                                    { $multiply: ["$inventory_info.reorder_level", 0.3] }
                                ]
                            },
                            then: "CRITICAL"
                        },
                        {
                            case: {
                                $lte: [
                                    "$inventory_info.current_stock",
                                    "$inventory_info.reorder_level"
                                ]
                            },
                            then: "LOW"
                        }
                    ],
                    default: "ADEQUATE"
                }
            }
        }
    },
    {
        $match: {
            $or: [
                { stock_status: "CRITICAL" },
                { stock_status: "LOW" },
                { turnover_ratio: { $gte: 3.0 } }
            ]
        }
    },
    {
        $sort: { turnover_ratio: -1 }
    }
]);

// Query 4: Order Analysis with Time-based Aggregation
db.orders.aggregate([
    {
        $match: {
            order_date: {
                $gte: new Date("2023-01-01"),
                $lt: new Date("2024-01-01")
            }
        }
    },
    {
        $group: {
            _id: {
                year: { $year: "$order_date" },
                month: { $month: "$order_date" },
                customer_type: "$customer.customer_type"
            },
            monthly_orders: { $sum: 1 },
            monthly_revenue: { $sum: "$total_cost" },
            average_order_value: { $avg: "$total_cost" }
        }
    },
    {
        $project: {
            year: "$_id.year",
            month: "$_id.month",
            customer_type: "$_id.customer_type",
            monthly_orders: 1,
            monthly_revenue: { $round: ["$monthly_revenue", 2] },
            average_order_value: { $round: ["$average_order_value", 2] }
        }
    },
    {
        $sort: { year: 1, month: 1, monthly_revenue: -1 }
    }
]);

// Query 5: Regional Performance with Geographic Insights
db.representatives.aggregate([
    {
        $group: {
            _id: "$region.name",
            rep_count: { $sum: 1 },
            total_sales: { $sum: "$sales_metrics.total_sales" },
            total_orders: { $sum: "$sales_metrics.total_orders" },
            avg_performance: { $avg: "$performance_rating" }
        }
    },
    {
        $project: {
            region_name: "$_id",
            rep_count: 1,
            total_sales: { $round: ["$total_sales", 2] },
            total_orders: 1,
            avg_performance: { $round: ["$avg_performance", 2] },
            sales_per_rep: {
                $round: [{ $divide: ["$total_sales", "$rep_count"] }, 2]
            },
            orders_per_rep: {
                $round: [{ $divide: ["$total_orders", "$rep_count"] }, 2]
            }
        }
    },
    {
        $sort: { total_sales: -1 }
    }
]);

// Query 6: Customer Lifetime Value and Retention Analysis
db.customers.aggregate([
    {
        $match: { status: "Active" }
    },
    {
        $project: {
            name: 1,
            customer_type: 1,
            total_spent: "$order_history.total_spent",
            total_orders: "$order_history.total_orders",
            days_since_registration: {
                $divide: [
                    { $subtract: [new Date(), "$registration_date"] },
                    1000 * 60 * 60 * 24
                ]
            },
            days_since_last_order: {
                $divide: [
                    { $subtract: [new Date(), "$order_history.last_order_date"] },
                    1000 * 60 * 60 * 24
                ]
            }
        }
    },
    {
        $project: {
            name: 1,
            customer_type: 1,
            total_spent: 1,
            total_orders: 1,
            days_since_last_order: { $round: ["$days_since_last_order", 0] },
            monthly_value: {
                $round: [
                    {
                        $divide: [
                            "$total_spent",
                            { $divide: ["$days_since_registration", 30] }
                        ]
                    },
                    2
                ]
            },
            customer_status: {
                $switch: {
                    branches: [
                        {
                            case: { $lte: ["$days_since_last_order", 30] },
                            then: "Active"
                        },
                        {
                            case: { $lte: ["$days_since_last_order", 60] },
                            then: "At Risk"
                        },
                        {
                            case: { $lte: ["$days_since_last_order", 90] },
                            then: "Inactive"
                        }
                    ],
                    default: "Churned"
                }
            }
        }
    },
    {
        $sort: { total_spent: -1 }
    }
]);

// Query 7: Complex Product Cross-Sell Analysis
db.orders.aggregate([
    {
        $unwind: "$line_items"
    },
    {
        $group: {
            _id: "$order_id",
            products: { $push: "$line_items.product_name" },
            product_count: { $sum: 1 }
        }
    },
    {
        $match: { product_count: { $gte: 2 } }
    },
    {
        $unwind: "$products"
    },
    {
        $unwind: "$products"
    },
    {
        $group: {
            _id: {
                product1: { $min: ["$products", "$products"] },
                product2: { $max: ["$products", "$products"] }
            },
            frequency: { $sum: 1 }
        }
    },
    {
        $match: { frequency: { $gte: 2 } }
    },
    {
        $sort: { frequency: -1 }
    },
    {
        $limit: 10
    }
]);

// =====================================================
// INDEXES FOR PERFORMANCE OPTIMIZATION
// =====================================================

// Create compound indexes for common queries
db.representatives.createIndex({ "region.name": 1, "sales_metrics.total_sales": -1 });
db.customers.createIndex({ customer_type: 1, status: 1 });
db.products.createIndex({ category: 1, "inventory_info.current_stock": 1 });
db.orders.createIndex({ order_date: -1, "customer.customer_type": 1 });
db.orders.createIndex({ "representative.representative_id": 1, order_status: 1 });

// Text indexes for search functionality
db.products.createIndex({ name: "text", description: "text" });
db.customers.createIndex({ name: "text", contact_details: "text" });

// =====================================================
// UTILITY FUNCTIONS AND ADMINISTRATIVE QUERIES
// =====================================================

// Function to update sales metrics for representatives
function updateRepresentativeSalesMetrics(repId) {
    const salesData = db.orders.aggregate([
        {
            $match: { "representative.representative_id": repId }
        },
        {
            $group: {
                _id: null,
                total_sales: { $sum: "$total_cost" },
                total_orders: { $sum: 1 },
                last_sale_date: { $max: "$order_date" }
            }
        }
    ]).toArray()[0];
    
    if (salesData) {
        db.representatives.updateOne(
            { representative_id: repId },
            {
                $set: {
                    "sales_metrics.total_sales": salesData.total_sales,
                    "sales_metrics.total_orders": salesData.total_orders,
                    "sales_metrics.average_order_value": salesData.total_sales / salesData.total_orders,
                    "sales_metrics.last_sale_date": salesData.last_sale_date,
                    updated_at: new Date()
                }
            }
        );
    }
}

// Function to generate low stock alerts
function generateLowStockAlerts() {
    return db.products.aggregate([
        {
            $match: {
                $expr: {
                    $lte: [
                        "$inventory_info.current_stock",
                        "$inventory_info.reorder_level"
                    ]
                }
            }
        },
        {
            $project: {
                name: 1,
                category: 1,
                current_stock: "$inventory_info.current_stock",
                reorder_level: "$inventory_info.reorder_level",
                urgency: {
                    $switch: {
                        branches: [
                            {
                                case: { $eq: ["$inventory_info.current_stock", 0] },
                                then: "URGENT"
                            },
                            {
                                case: {
                                    $lte: [
                                        "$inventory_info.current_stock",
                                        { $multiply: ["$inventory_info.reorder_level", 0.3] }
                                    ]
                                },
                                then: "HIGH"
                            }
                        ],
                        default: "MEDIUM"
                    }
                }
            }
        },
        {
            $sort: { urgency: 1, current_stock: 1 }
        }
    ]);
}

// Database statistics and health check
function getDatabaseStats() {
    return {
        collections: {
            representatives: db.representatives.countDocuments(),
            customers: db.customers.countDocuments(),
            products: db.products.countDocuments(),
            orders: db.orders.countDocuments()
        },
        total_revenue: db.orders.aggregate([
            { $group: { _id: null, total: { $sum: "$total_cost" } } }
        ]).toArray()[0]?.total || 0,
        active_customers: db.customers.countDocuments({ status: "Active" }),
        low_stock_products: db.products.countDocuments({
            $expr: {
                $lte: ["$inventory_info.current_stock", "$inventory_info.reorder_level"]
            }
        })
    };
}
