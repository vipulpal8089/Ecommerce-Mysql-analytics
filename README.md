🛒 E-Commerce Sales & Customer Analytics — MySQL Project

A complete SQL portfolio project analyzing e-commerce sales data using a normalized relational database. Built to demonstrate real-world data analysis skills — from database design to advanced query writing.

📌 Project Overview

This project simulates an e-commerce company's sales system with 150 customers, 32 products, 900 orders, 2,261 order items, and 824 payments. The goal is to answer real business questions using SQL — such as revenue trends, top customers, product performance, and repeat purchase behavior.

🗂️ Database Schema
Table	Description
customers	Customer master data (id, name, city, segment, signup date)
products	Product catalog (id, name, category, price, cost)
orders	Order header — one row per order
order_items	Order line items — one row per product per order
payments	Payment transactions per order

Relationships: customers → orders → order_items → products; orders → payments

🛠️ SQL Concepts Covered
Joins: INNER JOIN, LEFT JOIN
Filtering: WHERE, HAVING, ORDER BY, LIMIT
Aggregation: GROUP BY, SUM, COUNT, AVG
Window Functions: RANK(), ROW_NUMBER(), NTILE(), LAG(), running totals
Subqueries: correlated and non-correlated
CTEs: WITH clause
Views: reusable saved queries for reporting/dashboards
Triggers: auto-updating counts, data validation
Stored Procedures: parameterized reusable reports
📁 Repository Structure
├── 01_schema.sql      # Table structure, triggers, view
├── 02_data.sql        # Sample data (INSERT statements)
├── 03_queries.sql     # 25 business questions with SQL answers
├── screenshots/        # Query result screenshots
└── README.md
▶️ How to Run
Run 01_schema.sql in MySQL Workbench (creates database, tables, triggers, view)
Run 02_data.sql (inserts sample data)
Open 03_queries.sql and run any question to see results
📊 Key Insights (fill in after running your queries)
Highest revenue-generating category: _____
Top spending customer segment: _____
Best-performing month: _____
Most-used payment method: _____
🚀 Future Improvements
Connect to Power BI/Tableau for interactive dashboards
Automate reporting with Python + pandas

Author: Vipul Pal
LinkedIn - https://www.linkedin.com/in/vipul-pal-49391a406/
Email - VipulPal8089@gmail.com
