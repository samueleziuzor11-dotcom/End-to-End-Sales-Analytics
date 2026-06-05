CREATE DATABASE superstore;

USE superstore;

CREATE TABLE orders (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2)
);



LOAD DATA INFILE 'C:/Users/User/Desktop/MYSQL/SUPERSTORE_Clean.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, @order_date, @ship_date, ship_mode,
 customer_id, customer_name, segment, country, city,
 state, postal_code, region, product_id, category,
 sub_category, product_name, sales)
SET order_date = STR_TO_DATE(@order_date, '%Y-%m-%d'),
    ship_date = STR_TO_DATE(@ship_date, '%Y-%m-%d');
    
SHOW VARIABLES LIKE 'secure_file_priv';
    
    
    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SUPERSTORE_Clean.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, @order_date, @ship_date, ship_mode,
 customer_id, customer_name, segment, country, city,
 state, postal_code, region, product_id, category,
 sub_category, product_name, sales)
SET order_date = STR_TO_DATE(@order_date, '%Y-%m-%d'),
    ship_date = STR_TO_DATE(@ship_date, '%Y-%m-%d');

SELECT COUNT(*) FROM orders;

SELECT * 
FROM orders;

SELECT COUNT(*) FROM orders;

-- Total Revenue by Region

SELECT region ,SUM(sales) as total_sales, COUNT(DISTINCT order_id) as total_orders
FROM orders
GROUP BY region 
ORDER BY total_sales DESC;

-- Total Revenue by Category
SELECT category, SUM(sales) as total_sales
FROM orders
GROUP BY category
ORDER BY total_sales DESC;

SELECT category,
       SUM(sales) AS total_sales,
       ROUND(SUM(sales) / (SELECT SUM(sales) FROM orders) * 100, 2) AS pct_of_total
FROM orders
GROUP BY category
ORDER BY total_sales DESC;

-- Total Revenue by Segment
SELECT segment, SUM(sales) as total_sales, COUNT(distinct customer_id) AS Customers
FROM orders
GROUP BY segment
ORDER BY total_sales desc;

-- Top 10 Customers by revenue
SELECT customer_id,
       customer_name,
       segment,
       region,
       SUM(sales) AS total_revenue,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders
GROUP BY customer_id, customer_name, segment, region
ORDER BY total_revenue DESC
LIMIT 10;

-- Year-over-Year Sales Growth
SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS total_sales,
    LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) AS prev_year_sales,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)))
        / LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) * 100, 2
    ) AS yoy_growth_pct
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- Average order value by Segment
SELECT segment, COUNT(distinct order_id) as total_orders,
ROUND(SUM(sales) / COUNT(distinct order_id), 2) as avg_order_value,
MIN(sales) as min_sale, MAX(sales) as max_sale
FROM orders
GROUP BY segment
ORDER BY avg_order_value DESC;

-- Best Performing Sub-Categories

SELECT category, sub_category, SUM(sales) as total_sales,
		COUNT(distinct order_id) as orders, 
        ROUND(SUM(sales) / COUNT(distinct order_id), 2) as avg_order_value,
        RANK() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) as rank_in_category
        FROM orders
        GROUP BY category, sub_category
		ORDER BY total_sales DESC;
        
    -- Ship Mode Efficiency    
	SELECT ship_mode,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_days_to_ship,
       SUM(sales) AS total_sales
FROM orders
GROUP BY ship_mode
ORDER BY avg_days_to_ship DESC;
