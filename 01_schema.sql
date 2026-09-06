-- ============================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS DATABASE
-- ============================================================
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;
-- ------------------------------------------------------------
-- 1. CUSTOMERS
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    city            VARCHAR(50),
    segment         VARCHAR(20) DEFAULT 'Regular',   -- Regular / Premium / VIP
    signup_date     DATE NOT NULL,
    total_orders    INT DEFAULT 0                    -- updated automatically via trigger
);
-- ------------------------------------------------------------
-- 2. PRODUCTS
-- ------------------------------------------------------------

CREATE TABLE products (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    price           DECIMAL(10,2) NOT NULL,
    cost            DECIMAL(10,2) NOT NULL,
    stock_qty       INT DEFAULT 0
);

-- ------------------------------------------------------------
-- 3. ORDERS  (header level: one row per order)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    order_date      DATE NOT NULL,
    order_status    VARCHAR(20) DEFAULT 'Completed',  -- Completed / Cancelled / Returned
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ------------------------------------------------------------
-- 4. ORDER_ITEMS (line item level: one row per product in an order)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ------------------------------------------------------------
-- 5. PAYMENTS
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    payment_method  VARCHAR(30),          -- UPI / Card / COD / NetBanking
    amount          DECIMAL(10,2) NOT NULL,
    payment_date    DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_orderitems_order  ON order_items(order_id);
CREATE INDEX idx_orderitems_prod   ON order_items(product_id);

-- ============================================================
-- TRIGGER #1: auto-update customer's total_orders count
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE customers
    SET total_orders = total_orders + 1
    WHERE customer_id = NEW.customer_id;
END$$

DELIMITER ;

-- ============================================================
-- TRIGGER 2: prevent invalid (negative/zero) quantity
-- ============================================================
DELIMITER $$

CREATE TRIGGER trg_before_orderitem_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than 0';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- SAMPLE VIEW: monthly sales summary 
-- ============================================================
CREATE VIEW monthly_sales_summary AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    SUM(oi.quantity * oi.unit_price)    AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

USE ecommerce_analytics;

SET FOREIGN_KEY_CHECKS=0;