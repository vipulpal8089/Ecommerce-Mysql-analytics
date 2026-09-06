
-- Q1 Display the customer's name and city with every order.
SELECT o.order_id, c.name, c.city, o.order_date, o.order_status
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 20;

-- Q2 Find the customers who have never placed an order.
SELECT c.customer_id, c.name, c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q3 Show the product name and category along with the order.
SELECT oi.order_id, p.product_name, p.category, oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id
LIMIT 20;

-- Q4 Products in the 'Electronics' category priced above ₹1,000.
select product_name , category , price
from products 
where category = 'Electronics' and price > 1000 
ORDER BY price DESC;

-- Q5 Show 'completed' orders from the last 30 days.
SELECT order_id, customer_id, order_date
FROM orders
WHERE order_status = 'Completed'
  AND order_date >= (SELECT DATE_SUB(MAX(order_date), INTERVAL 30 DAY) FROM orders)
ORDER BY order_date DESC;

-- Q6. Top 10 highest-priced products.
select  product_name, category, price	
from products 
order by price desc 
limit 10 ;

-- Q7. Category-wise total revenue.
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Q8. City-wise customer count.
select city , count(*) as Total_customers
from customers
group by city
order by Total_customers desc ;

-- Q9 Show only those customers whose total spend is more than ₹10,000.
SELECT c.customer_id, c.name, SUM(oi.quantity * oi.unit_price) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.name
HAVING total_spend > 10000
ORDER BY total_spend DESC;

 -- Q10. Which products have been sold fewer than 5 times?
 SELECT p.product_name, COUNT(oi.order_item_id) AS times_ordered
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING times_ordered < 5
ORDER BY times_ordered;

-- Q11. Top-selling product of each category (by revenue)
 SELECT category, product_name, revenue, rnk
FROM (
    SELECT p.category, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue,
           RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rnk
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
) ranked
WHERE rnk = 1;

-- Q12. What was each customer's first order?
SELECT customer_id, order_id, order_date
FROM (
    SELECT customer_id, order_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rn
    FROM orders
) t
WHERE rn = 1;

-- Q13. Month-wise running total revenue
SELECT order_month, monthly_revenue,
       SUM(monthly_revenue) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
) m
ORDER BY order_month;

-- Q14. Month-over-month revenue growth % — LAG()
SELECT order_month, monthly_revenue,
       LAG(monthly_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
       ROUND(
         (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
         / LAG(monthly_revenue) OVER (ORDER BY order_month) * 100, 2
       ) AS growth_pct
FROM (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
           SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
) m
ORDER BY order_month;

-- Q15. Divide customers into 4 equal groups (quartiles) based on total spend.
SELECT customer_id, total_spend,
       NTILE(4) OVER (ORDER BY total_spend DESC) AS spend_quartile
FROM (
    SELECT c.customer_id, SUM(oi.quantity * oi.unit_price) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) s;

-- Q16. Customers whose spending is higher than the average customer spend. 
SELECT customer_id, total_spend
FROM (
    SELECT c.customer_id, SUM(oi.quantity * oi.unit_price) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) t
WHERE total_spend > (
    SELECT AVG(total_spend) FROM (
        SELECT SUM(oi.quantity * oi.unit_price) AS total_spend
        FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY o.customer_id
    ) avg_t
);

-- Q17. Single product generating the highest revenue.
SELECT product_name, revenue FROM (
    SELECT p.product_name, SUM(oi.quantity*oi.unit_price) AS revenue
    FROM order_items oi JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_name
) t
WHERE revenue = (
    SELECT MAX(revenue) FROM (
        SELECT SUM(oi.quantity*oi.unit_price) AS revenue
        FROM order_items oi GROUP BY oi.product_id
    ) x
);

-- Q18. Use the pre-existing view to analyze the revenue trend for the last three months.
SELECT * FROM monthly_sales_summary
ORDER BY order_month DESC
LIMIT 3;

-- Q19. Create a new view — High-value customers.
CREATE VIEW high_value_customers AS
SELECT c.customer_id, c.name, c.city,
       SUM(oi.quantity * oi.unit_price) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.name, c.city
HAVING total_spend > 10000;

-- use :
SELECT * FROM high_value_customers ORDER BY total_spend DESC;

-- Q20. Test the trigger — place a new order and check the customer's `total_orders` count.
-- check first
SELECT total_orders FROM customers WHERE customer_id = 1;

-- insert New order
INSERT INTO orders (customer_id, order_date, order_status)
VALUES (1, CURDATE(), 'Completed');

-- Now check again — the count will automatically increase by 1 (due to the trigger).
SELECT total_orders FROM customers WHERE customer_id = 1;

-- Q21. Test the second trigger by inserting an invalid quantity.
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, -2, 500);
-- This will throw an error because the 'before insert' trigger blocks negative quantities.

-- Q22. Procedure to retrieve the complete order history of any customer.
DELIMITER $$
CREATE PROCEDURE get_customer_orders(IN cust_id INT)
BEGIN
    SELECT o.order_id, o.order_date, o.order_status,
           SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = cust_id
    GROUP BY o.order_id, o.order_date, o.order_status
    ORDER BY o.order_date DESC;
END$$
DELIMITER ;

-- call 
CALL get_customer_orders(5);

-- Q23. Procedure for generating a revenue report for any month/year.
DELIMITER $$
CREATE PROCEDURE monthly_revenue_report(IN p_year INT, IN p_month INT)
BEGIN
    SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE YEAR(o.order_date) = p_year
      AND MONTH(o.order_date) = p_month
      AND o.order_status = 'Completed'
    GROUP BY p.category
    ORDER BY revenue DESC;
END$$
DELIMITER ;

-- call :
CALL monthly_revenue_report(2025, 3);

-- Q24. Calculate category-wise revenue ranks using the `WITH` clause.
WITH category_revenue AS (
    SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
)
SELECT category, revenue,
       RANK() OVER (ORDER BY revenue DESC) AS category_rank
FROM category_revenue;

-- Q25. Payment method-wise total transactions and revenue.
SELECT payment_method,
       COUNT(*) AS total_transactions,
       SUM(amount) AS total_revenue,
       ROUND(AVG(amount), 2) AS avg_transaction_value
FROM payments
GROUP BY payment_method
ORDER BY total_revenue DESC;