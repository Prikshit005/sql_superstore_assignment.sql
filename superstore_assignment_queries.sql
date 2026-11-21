create database superstore;
CREATE DATABASE IF NOT EXISTS superstore;
use superstore;

select * from superstoredatasets;

describe superstoredatasets;

SHOW DATABASES;
SHOW TABLES;

SELECT * FROM superstoredatasets LIMIT 20;

SELECT `Order ID`, `Order Date`, `Customer Name`, `Product Name`, `Sales`, `Profit`
FROM superstoredatasets;

SELECT COUNT(*) AS total_rows FROM superstoredatasets;

SELECT COUNT(DISTINCT `Order ID`)    AS unique_orders,
       COUNT(DISTINCT `Customer ID`) AS unique_customers
FROM superstoredatasets;

SELECT DISTINCT `Category`, `Sub-Category`
FROM superstoredatasets
ORDER BY `Category`, `Sub-Category`;

SELECT MIN(`Order Date`) AS earliest_order, MAX(`Order Date`) AS latest_order
FROM superstoredatasets;

SELECT SUM(`Customer ID` IS NULL OR TRIM(`Customer ID`) = '') AS missing_customer_id,
       SUM(`Sales` IS NULL)      AS missing_sales,
       SUM(`Profit` IS NULL)     AS missing_profit,
       SUM(`Order Date` IS NULL) AS missing_order_date
FROM superstoredatasets;

SELECT * FROM superstoredatasets WHERE `Region` = 'West';

SELECT * FROM superstoredatasets WHERE `Sales` > 500;

SELECT * FROM superstoredatasets WHERE `Quantity` BETWEEN 3 AND 8;

SELECT * FROM superstoredatasets
WHERE `Ship Mode` IN ('Second Class', 'First Class');

SELECT * FROM superstoredatasets WHERE `Discount` > 0.20;

SELECT * FROM superstoredatasets WHERE `Profit` < 0;

SELECT DISTINCT `Product ID`, `Product Name`
FROM superstoredatasets
WHERE `Product Name` LIKE '%Chair%';

SELECT DISTINCT `Customer ID`, `Customer Name`
FROM superstoredatasets
WHERE `Customer Name` LIKE 'A%'
ORDER BY `Customer Name`;

SELECT `Order ID`, `Product Name`, `Sales`
FROM superstoredatasets
ORDER BY `Sales` DESC
LIMIT 10;

SELECT `Order ID`, `Order Date`, `Product Name`, `Sales`
FROM superstoredatasets
ORDER BY `Order Date` DESC, `Sales` DESC;

SELECT ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit,
       SUM(`Quantity`) AS total_quantity
FROM superstoredatasets;

SELECT ROUND(AVG(`Sales`),2) AS avg_sales, ROUND(AVG(`Discount`),4) AS avg_discount,
       ROUND(AVG(`Profit`),2) AS avg_profit
FROM superstoredatasets;

SELECT MAX(`Sales`) AS highest_sales, MIN(`Sales`) AS lowest_sales FROM superstoredatasets;

SELECT `Ship Mode`, COUNT(DISTINCT `Order ID`) AS order_count,
       COUNT(*) AS line_items
FROM superstoredatasets
GROUP BY `Ship Mode`
ORDER BY order_count DESC;

SELECT `Region`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets GROUP BY `Region` ORDER BY total_sales DESC;

SELECT `Category`, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Category` ORDER BY total_profit DESC;

SELECT `Segment`, COUNT(DISTINCT `Customer ID`) AS customers
FROM superstoredatasets GROUP BY `Segment`;

SELECT `Ship Mode`, ROUND(AVG(`Sales`),2) AS avg_sales_per_line
FROM superstoredatasets GROUP BY `Ship Mode` ORDER BY avg_sales_per_line DESC;

SELECT `State`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets GROUP BY `State` ORDER BY total_sales DESC;

SELECT `Region`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets
GROUP BY `Region`
HAVING SUM(`Sales`) > 100000;

--
SELECT `State`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets GROUP BY `State` ORDER BY total_sales DESC LIMIT 10;

SELECT `Sub-Category`, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Sub-Category` ORDER BY total_profit DESC LIMIT 10;

SELECT `Category`, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Category` HAVING SUM(`Profit`) < 0;

SELECT `Customer ID`, `Customer Name`, COUNT(DISTINCT `Order ID`) AS orders
FROM superstoredatasets
GROUP BY `Customer ID`, `Customer Name`
HAVING COUNT(DISTINCT `Order ID`) > 5
ORDER BY orders DESC;

SELECT `Sub-Category`, ROUND(AVG(`Discount`),3) AS avg_discount
FROM superstoredatasets GROUP BY `Sub-Category` HAVING AVG(`Discount`) > 0.20
ORDER BY avg_discount DESC;

SELECT YEAR(`Order Date`) AS yr, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets GROUP BY YEAR(`Order Date`) ORDER BY yr;

SELECT YEAR(`Order Date`) AS yr, MONTH(`Order Date`) AS mth,
       ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets
GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
ORDER BY yr, mth;

-- Single highest year-month
SELECT DATE_FORMAT(`Order Date`, '%Y-%m') AS ym, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets
GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
ORDER BY total_sales DESC LIMIT 1;

-- Highest calendar month across all years (seasonality)
SELECT MONTHNAME(`Order Date`) AS month_name, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets
GROUP BY MONTH(`Order Date`), MONTHNAME(`Order Date`)
ORDER BY total_sales DESC LIMIT 1;

SELECT ROUND(AVG(order_total),2) AS avg_order_value
FROM (SELECT `Order ID`, SUM(`Sales`) AS order_total
      FROM superstoredatasets GROUP BY `Order ID`) o;

SELECT `Customer ID`, `Customer Name`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets
GROUP BY `Customer ID`, `Customer Name`
HAVING SUM(`Sales`) > 5000
ORDER BY total_sales DESC;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers AS
SELECT `Customer ID`, MIN(`Customer Name`) AS `Customer Name`, MIN(`Segment`) AS `Segment`
FROM superstoredatasets GROUP BY `Customer ID`;
ALTER TABLE customers ADD PRIMARY KEY (`Customer ID`);

DROP TABLE IF EXISTS customer_sales_summary;
CREATE TABLE customer_sales_summary AS
SELECT `Customer ID`, COUNT(DISTINCT `Order ID`) AS order_count,
       ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Customer ID`;

SELECT c.`Customer ID`, c.`Customer Name`, c.`Segment`,
       s.order_count, s.total_sales, s.total_profit
FROM customers c
JOIN customer_sales_summary s ON s.`Customer ID` = c.`Customer ID`
ORDER BY s.total_sales DESC LIMIT 10;

DROP TABLE IF EXISTS products;
CREATE TABLE products AS
SELECT `Product ID`, MIN(`Product Name`) AS `Product Name`,
       MIN(`Category`) AS `Category`, MIN(`Sub-Category`) AS `Sub-Category`
FROM superstoredatasets GROUP BY `Product ID`;
ALTER TABLE products ADD PRIMARY KEY (`Product ID`);

SELECT p.`Product ID`, p.`Product Name`, p.`Category`, p.`Sub-Category`,
       ROUND(SUM(s.`Sales`),2) AS total_sales, SUM(s.`Quantity`) AS units_sold
FROM products p
JOIN superstoredatasets s ON s.`Product ID` = p.`Product ID`
GROUP BY p.`Product ID`, p.`Product Name`, p.`Category`, p.`Sub-Category`
ORDER BY total_sales DESC LIMIT 10;

DROP TABLE IF EXISTS products;
CREATE TABLE products AS
SELECT `Product ID`, MIN(`Product Name`) AS `Product Name`,
       MIN(`Category`) AS `Category`, MIN(`Sub-Category`) AS `Sub-Category`
FROM superstoredatasets GROUP BY `Product ID`;
ALTER TABLE products ADD PRIMARY KEY (`Product ID`);

SELECT p.`Product ID`, p.`Product Name`, p.`Category`, p.`Sub-Category`,
       ROUND(SUM(s.`Sales`),2) AS total_sales, SUM(s.`Quantity`) AS units_sold
FROM products p
JOIN superstoredatasets s ON s.`Product ID` = p.`Product ID`
GROUP BY p.`Product ID`, p.`Product Name`, p.`Category`, p.`Sub-Category`
ORDER BY total_sales DESC LIMIT 10;

-- Add a test customer who has never ordered (removed again in Q6.7)
INSERT INTO customers VALUES ('ZZ-0000', 'Test Customer (no orders)', 'Consumer');

SELECT c.`Customer ID`, c.`Customer Name`
FROM customers c
LEFT JOIN customer_sales_summary s ON s.`Customer ID` = c.`Customer ID`
WHERE s.`Customer ID` IS NULL;

DROP TABLE IF EXISTS region_lookup;
CREATE TABLE region_lookup (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(20) NOT NULL UNIQUE,
    regional_manager VARCHAR(50)
);
INSERT INTO region_lookup VALUES
 (1,'Central','Manager A'), (2,'East','Manager B'),
 (3,'South','Manager C'),   (4,'West','Manager D');

SELECT r.region_id, r.region_name, r.regional_manager,
       ROUND(t.total_sales,2) AS total_sales, ROUND(t.total_profit,2) AS total_profit
FROM region_lookup r
LEFT JOIN (SELECT `Region`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
           FROM superstoredatasets GROUP BY `Region`) t
       ON t.`Region` = r.region_name;

SELECT c.`Customer ID`, c.`Customer Name`, c.`Segment`,
       COUNT(o.`Order ID`) AS order_count, ROUND(SUM(o.order_total),2) AS total_spent
FROM customers c
JOIN (SELECT `Order ID`, `Customer ID`, SUM(`Sales`) AS order_total
      FROM superstoredatasets GROUP BY `Order ID`, `Customer ID`) o
  ON o.`Customer ID` = c.`Customer ID`
GROUP BY c.`Customer ID`, c.`Customer Name`, c.`Segment`
ORDER BY order_count DESC, total_spent DESC;

DROP TABLE IF EXISTS category_lookup;
CREATE TABLE category_lookup (category_id INT PRIMARY KEY, category_name VARCHAR(30));
INSERT INTO category_lookup VALUES (1,'Furniture'), (2,'Office Supplies'), (3,'Technology');

SELECT l.category_id, l.category_name,
       ROUND(t.total_sales,2) AS total_sales, ROUND(t.total_profit,2) AS total_profit
FROM category_lookup l
JOIN (SELECT `Category`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
      FROM superstoredatasets GROUP BY `Category`) t
  ON t.`Category` = l.category_name;

DROP TABLE IF EXISTS org_chart;
CREATE TABLE org_chart (
    emp_id INT PRIMARY KEY, emp_name VARCHAR(50), manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES org_chart(emp_id)
);
INSERT INTO org_chart VALUES
 (1,'Asha Mehta (CEO)',NULL), (2,'Ravi Kumar',1), (3,'Neha Singh',1),
 (4,'Amit Rao',2), (5,'Pooja Das',2), (6,'Karan Shah',3), (7,'Isha Verma',4);

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM org_chart e
LEFT JOIN org_chart m ON m.emp_id = e.manager_id
ORDER BY e.emp_id;

SELECT r.region_name, c.category_name
FROM region_lookup r
CROSS JOIN category_lookup c
ORDER BY r.region_name, c.category_name;

-- INNER JOIN: only rows that match on both sides
SELECT c.`Customer Name`, s.total_sales
FROM customers c INNER JOIN customer_sales_summary s ON s.`Customer ID` = c.`Customer ID`;

-- LEFT JOIN: all rows from the left table, NULLs where no match on the right
SELECT c.`Customer Name`, s.total_sales
FROM customers c LEFT JOIN customer_sales_summary s ON s.`Customer ID` = c.`Customer ID`;

-- RIGHT JOIN: all rows from the right table, NULLs where no match on the left
SELECT l.category_name, t.total_sales
FROM category_lookup l
RIGHT JOIN (SELECT `Category`, SUM(`Sales`) AS total_sales
            FROM superstoredatasets GROUP BY `Category`) t ON t.`Category` = l.category_name;

-- CROSS JOIN: every row of one table paired with every row of the other
SELECT r.region_name, c.category_name
FROM region_lookup r CROSS JOIN category_lookup c;

SELECT `Order ID`, `Product Name`, `Sales`
FROM superstoredatasets
WHERE `Sales` > (SELECT AVG(`Sales`) FROM superstoredatasets)
ORDER BY `Sales` DESC;

SELECT s.`Category`, s.`Product Name`, s.`Sales`
FROM superstoredatasets s
WHERE s.`Sales` > (SELECT AVG(s2.`Sales`) FROM superstoredatasets s2
                 WHERE s2.`Category` = s.`Category`)
ORDER BY s.`Category`, s.`Sales` DESC;

SELECT `Customer ID`, `Customer Name`, ROUND(SUM(`Sales`),2) AS total_sales
FROM superstoredatasets
GROUP BY `Customer ID`, `Customer Name`
HAVING SUM(`Sales`) > (SELECT AVG(cust_total)
                     FROM (SELECT SUM(`Sales`) AS cust_total
                           FROM superstoredatasets GROUP BY `Customer ID`) t)
ORDER BY total_sales DESC;

SELECT `State`, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets
GROUP BY `State`
HAVING SUM(`Profit`) = (SELECT MAX(state_profit)
                      FROM (SELECT SUM(`Profit`) AS state_profit
                            FROM superstoredatasets GROUP BY `State`) t);

SELECT `Customer ID`, `Customer Name`, COUNT(DISTINCT `Category`) AS categories_bought
FROM superstoredatasets
GROUP BY `Customer ID`, `Customer Name`
HAVING COUNT(DISTINCT `Category`) > 1
ORDER BY categories_bought DESC;

SELECT c.`Customer ID`, c.`Customer Name`
FROM customers c
WHERE EXISTS (SELECT 1 FROM superstoredatasets s
              WHERE s.`Customer ID` = c.`Customer ID` AND s.`Profit` < 0);

SELECT c.`Customer ID`, c.`Customer Name`
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM customer_sales_summary s
                  WHERE s.`Customer ID` = c.`Customer ID`);

-- Clean up the test customer added in Q5.4
DELETE FROM customers WHERE `Customer ID` = 'ZZ-0000';

SELECT MAX(`Sales`) AS second_highest_sales
FROM superstoredatasets
WHERE `Sales` < (SELECT MAX(`Sales`) FROM superstoredatasets);

SELECT `Product ID`, MIN(`Product Name`) AS `Product Name`
FROM superstoredatasets
WHERE YEAR(`Order Date`) IN (2016, 2017)
GROUP BY `Product ID`
HAVING COUNT(DISTINCT YEAR(`Order Date`)) = 2;

-- Same result with EXISTS
SELECT DISTINCT a.`Product ID`
FROM superstoredatasets a
WHERE YEAR(a.`Order Date`) = 2016
  AND EXISTS (SELECT 1 FROM superstoredatasets b
              WHERE b.`Product ID` = a.`Product ID` AND YEAR(b.`Order Date`) = 2017);

-- Customers who have at least one loss-making line, three ways
SELECT `Customer ID` FROM customers
WHERE `Customer ID` IN (SELECT `Customer ID` FROM superstoredatasets WHERE `Profit` < 0);

SELECT c.`Customer ID` FROM customers c
WHERE EXISTS (SELECT 1 FROM superstoredatasets s
              WHERE s.`Customer ID` = c.`Customer ID` AND s.`Profit` < 0);

SELECT DISTINCT c.`Customer ID`
FROM customers c JOIN superstoredatasets s ON s.`Customer ID` = c.`Customer ID`
WHERE s.`Profit` < 0;

-- ADVANCED SQL

WITH region_totals AS (
    SELECT `Region`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
    FROM superstoredatasets GROUP BY `Region`
)
SELECT `Region`, ROUND(total_sales,2) AS total_sales, ROUND(total_profit,2) AS total_profit
FROM region_totals ORDER BY total_sales DESC;

WITH category_totals AS (
    SELECT `Category`, SUM(`Sales`) AS cat_sales FROM superstoredatasets GROUP BY `Category`
),
grand_total AS (
    SELECT SUM(cat_sales) AS total_sales FROM category_totals
)
SELECT c.`Category`, ROUND(c.cat_sales,2) AS cat_sales,
       ROUND(c.cat_sales / g.total_sales * 100, 2) AS pct_of_total_sales
FROM category_totals c CROSS JOIN grand_total g
ORDER BY pct_of_total_sales DESC;

WITH cust AS (
    SELECT `Customer ID`, `Customer Name`, SUM(`Sales`) AS total_sales
    FROM superstoredatasets GROUP BY `Customer ID`, `Customer Name`
)
SELECT ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS rn,
       `Customer ID`, `Customer Name`, ROUND(total_sales,2) AS total_sales
FROM cust ORDER BY rn LIMIT 20;

WITH st AS (
    SELECT `State`, SUM(`Profit`) AS total_profit FROM superstoredatasets GROUP BY `State`
)
SELECT `State`, ROUND(total_profit,2) AS total_profit,
       RANK()       OVER (ORDER BY total_profit DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY total_profit DESC) AS dense_rnk
FROM st ORDER BY rnk;

-- Exact profits rarely tie, so round to the nearest 1,000 to see the difference
WITH st AS (
    SELECT `State`, ROUND(SUM(`Profit`), -3) AS profit_k FROM superstoredatasets GROUP BY `State`
)
SELECT `State`, profit_k,
       RANK()       OVER (ORDER BY profit_k DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY profit_k DESC) AS dense_rnk
FROM st ORDER BY rnk, `State`;

WITH prod AS (
    SELECT `Category`, `Product ID`, `Product Name`, SUM(`Sales`) AS total_sales
    FROM superstoredatasets GROUP BY `Category`, `Product ID`, `Product Name`
)
SELECT `Category`, `Product Name`, ROUND(total_sales,2) AS total_sales,
       RANK() OVER (PARTITION BY `Category` ORDER BY total_sales DESC) AS rank_in_category
FROM prod
ORDER BY `Category`, rank_in_category
LIMIT 30;

WITH monthly AS (
    SELECT DATE_FORMAT(`Order Date`, '%Y-%m') AS ym, SUM(`Sales`) AS monthly_sales
    FROM superstoredatasets GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
)
SELECT ym, ROUND(monthly_sales,2) AS monthly_sales,
       ROUND(SUM(monthly_sales) OVER (ORDER BY ym),2) AS running_total
FROM monthly ORDER BY ym;

WITH monthly AS (
    SELECT DATE_FORMAT(`Order Date`, '%Y-%m') AS ym, SUM(`Sales`) AS monthly_sales
    FROM superstoredatasets GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
)
SELECT ym, ROUND(monthly_sales,2) AS monthly_sales,
       ROUND(LAG(monthly_sales) OVER (ORDER BY ym),2) AS prev_month_sales,
       ROUND(monthly_sales - LAG(monthly_sales) OVER (ORDER BY ym),2) AS change_amt,
       ROUND((monthly_sales / LAG(monthly_sales) OVER (ORDER BY ym) - 1) * 100,1)
           AS change_pct
FROM monthly ORDER BY ym;

SELECT `Region`, ROUND(SUM(`Profit`),2) AS region_profit,
       ROUND(SUM(`Profit`) / SUM(SUM(`Profit`)) OVER () * 100, 2) AS pct_of_total_profit
FROM superstoredatasets
GROUP BY `Region`
ORDER BY pct_of_total_profit DESC;

WITH sc AS (
    SELECT `Region`, `Sub-Category`, SUM(`Profit`) AS total_profit
    FROM superstoredatasets GROUP BY `Region`, `Sub-Category`
),
ranked AS (
    SELECT `Region`, `Sub-Category`, total_profit,
           ROW_NUMBER() OVER (PARTITION BY `Region` ORDER BY total_profit DESC) AS rn
    FROM sc
)
SELECT `Region`, rn AS position, `Sub-Category`, ROUND(total_profit,2) AS total_profit
FROM ranked WHERE rn <= 3
ORDER BY `Region`, rn;

-- Uses the org_chart table created in Q5.8
WITH RECURSIVE org AS (
    SELECT emp_id, emp_name, manager_id, 1 AS lvl,
           CAST(emp_name AS CHAR(500)) AS path
    FROM org_chart WHERE manager_id IS NULL
    UNION ALL
    SELECT o.emp_id, o.emp_name, o.manager_id, g.lvl + 1,
           CONCAT(g.path, ' > ', o.emp_name)
    FROM org_chart o JOIN org g ON o.manager_id = g.emp_id
)
SELECT lvl, emp_name, path FROM org ORDER BY path;

CREATE OR REPLACE VIEW regional_sales_summary AS
SELECT `Region`, ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Region`;

CREATE OR REPLACE VIEW negative_profit_transactions AS
SELECT `Row ID`, `Order ID`, `Order Date`, `Customer Name`, `Region`, `State`, `Category`,
       `Sub-Category`, `Product Name`, `Sales`, `Discount`, `Profit`
FROM superstoredatasets WHERE `Profit` < 0;

SELECT * FROM regional_sales_summary
WHERE total_sales > 400000 ORDER BY total_profit DESC;

SELECT `Sub-Category`, COUNT(*) AS loss_lines, ROUND(SUM(`Profit`),2) AS total_loss
FROM negative_profit_transactions
WHERE `Region` = 'Central'
GROUP BY `Sub-Category`
ORDER BY total_loss ASC;

DROP PROCEDURE IF EXISTS sp_region_summary;
DELIMITER $$
CREATE PROCEDURE sp_region_summary(IN p_region VARCHAR(20))
BEGIN
    IF p_region IS NULL OR TRIM(p_region) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Region must not be empty';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM superstoredatasets WHERE `Region` = p_region) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown region';
    END IF;
    SELECT p_region AS `Region`, ROUND(SUM(`Sales`),2) AS total_sales,
           ROUND(SUM(`Profit`),2) AS total_profit
    FROM superstoredatasets WHERE `Region` = p_region;
END$$
DELIMITER ;

CALL sp_region_summary('West');

DROP PROCEDURE IF EXISTS sp_sales_above;
DELIMITER $$
CREATE PROCEDURE sp_sales_above(IN p_min_sales DECIMAL(12,2))
BEGIN
    IF p_min_sales IS NULL OR p_min_sales < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Minimum sales must be a non-negative number';
    END IF;
    SELECT `Order ID`, `Order Date`, `Customer Name`, `Product Name`, `Sales`, `Profit`
    FROM superstoredatasets
    WHERE `Sales` >= p_min_sales
    ORDER BY `Sales` DESC;
END$$
DELIMITER ;

CALL sp_sales_above(2000);

DROP PROCEDURE IF EXISTS sp_sales_above;
DELIMITER $$
CREATE PROCEDURE sp_sales_above(IN p_min_sales DECIMAL(12,2))
BEGIN
    IF p_min_sales IS NULL OR p_min_sales < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Minimum sales must be a non-negative number';
    END IF;
    SELECT `Order ID`, `Order Date`, `Customer Name`, `Product Name`, `Sales`, `Profit`
    FROM superstoredatasets
    WHERE `Sales` >= p_min_sales
    ORDER BY `Sales` DESC;
END$$
DELIMITER ;

CALL sp_sales_above(2000);

DROP FUNCTION IF EXISTS fn_profit_margin;
DELIMITER $$
CREATE FUNCTION fn_profit_margin(p_sales DECIMAL(12,4), p_profit DECIMAL(12,4))
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    IF p_sales IS NULL OR p_sales = 0 THEN
        RETURN NULL;          -- avoids division by zero; margin is undefined
    END IF;
    RETURN ROUND(p_profit / p_sales * 100, 2);
END$$
DELIMITER ;

SELECT fn_profit_margin(200, 50) AS normal_case,     -- 25.00
       fn_profit_margin(0, 10)   AS zero_sales_case; -- NULL

SELECT `Category`, fn_profit_margin(SUM(`Sales`), SUM(`Profit`)) AS margin_pct
FROM superstoredatasets GROUP BY `Category`;

-- Update the view: add order count and margin using the function
CREATE OR REPLACE VIEW regional_sales_summary AS
SELECT `Region`, COUNT(DISTINCT `Order ID`) AS orders,
       ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit,
       fn_profit_margin(SUM(`Sales`), SUM(`Profit`)) AS margin_pct
FROM superstoredatasets GROUP BY `Region`;

SELECT * FROM regional_sales_summary ORDER BY margin_pct DESC;

DROP PROCEDURE IF EXISTS sp_region_summary;
DELIMITER $$
CREATE PROCEDURE sp_region_summary(IN p_region VARCHAR(20))
BEGIN
    IF p_region IS NULL OR TRIM(p_region) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Region must not be empty';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM superstoredatasets WHERE `Region` = p_region) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown region';
    END IF;
    SELECT p_region AS `Region`, COUNT(DISTINCT `Order ID`) AS orders,
           ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit,
           fn_profit_margin(SUM(`Sales`), SUM(`Profit`)) AS margin_pct
    FROM superstoredatasets WHERE `Region` = p_region;
END$$
DELIMITER ;

CALL sp_region_summary('East');

DROP PROCEDURE IF EXISTS sp_region_summary_safe;
DELIMITER $$
CREATE PROCEDURE sp_region_summary_safe(IN p_region VARCHAR(20))
BEGIN
    DECLARE v_state CHAR(5) DEFAULT '00000';
    DECLARE v_msg TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_state = RETURNED_SQLSTATE, v_msg = MESSAGE_TEXT;
        ROLLBACK;
        SELECT 'ERROR' AS status, v_state AS sqlstate_code, v_msg AS error_message;
    END;
    CALL sp_region_summary(p_region);
END$$
DELIMITER ;

CALL sp_region_summary_safe('Mars');  
CALL sp_region_summary_safe('West');  

CREATE INDEX idx_order_date ON superstoredatasets (`Order Date`);
SHOW INDEX FROM superstoredatasets;

SELECT COUNT(*) FROM superstoredatasets
WHERE `Order Date` >= '2016-01-01' AND `Order Date` < '2017-01-01';

SELECT COUNT(*) FROM superstoredatasets WHERE YEAR(`Order Date`) = 2016;

CREATE INDEX idx_region_orderdate ON superstoredatasets (`Region`, `Order Date`);

EXPLAIN SELECT `Order ID`, `Sales` FROM superstoredatasets
WHERE `Region` = 'West' AND `Order Date` BETWEEN '2016-01-01' AND '2016-12-31';

-- Run the whole
DROP TABLE IF EXISTS order_entry;
CREATE TABLE order_entry (
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    order_ref VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- COMMIT: changes become permanent
START TRANSACTION;
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-1001','AB-10015', 250.00);
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-1002','AB-10060', 480.50);
COMMIT;

-- ROLLBACK: changes are undone
START TRANSACTION;
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-1003','AB-10105', 999.99);
SELECT * FROM order_entry;
ROLLBACK;
SELECT * FROM order_entry;      

START TRANSACTION;
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-2001','AB-10015', 100.00);
SAVEPOINT after_first;
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-2002','AB-10060', 200.00);
SAVEPOINT after_second;
INSERT INTO order_entry (order_ref, customer_id, amount) VALUES ('ORD-2003','AB-10105', -5.00);  -- mistake

ROLLBACK TO SAVEPOINT after_second;   -- undoes only ORD-2003
SELECT * FROM order_entry WHERE order_ref LIKE 'ORD-2%';  
COMMIT;

DROP TABLE IF EXISTS employee_audit;
DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    hire_date DATE DEFAULT (CURRENT_DATE)
);
CREATE TABLE employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    action_type VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_employee_after_insert;
DELIMITER $$
CREATE TRIGGER trg_employee_after_insert
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (emp_id, emp_name, department, old_salary, new_salary, action_type)
    VALUES (NEW.emp_id, NEW.emp_name, NEW.department, NULL, NEW.salary, 'INSERT');
END$$
DELIMITER ;

INSERT INTO employee (emp_name, department, salary)
VALUES ('Rohan Sharma', 'Analytics', 55000.00);
SELECT * FROM employee;
SELECT * FROM employee_audit;   

DROP TRIGGER IF EXISTS trg_employee_after_update;
DELIMITER $$
CREATE TRIGGER trg_employee_after_update
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO employee_audit
            (emp_id, emp_name, department, old_salary, new_salary, action_type)
        VALUES (NEW.emp_id, NEW.emp_name, NEW.department, OLD.salary, NEW.salary, 'UPDATE');
    END IF;
END$$
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
UPDATE employee SET salary = 60000.00 WHERE emp_name = 'Rohan Sharma';
UPDATE employee SET department = 'BI' WHERE emp_name = 'Rohan Sharma';
SET SQL_SAFE_UPDATES = 1;
SELECT * FROM employee_audit ORDER BY audit_id;

-- Final Mini-Project

SELECT `Region`, ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit,
       ROUND(SUM(`Profit`)/SUM(`Sales`)*100,2) AS margin_pct,
       RANK() OVER (ORDER BY SUM(`Sales`)  DESC) AS sales_rank,
       RANK() OVER (ORDER BY SUM(`Profit`) DESC) AS profit_rank
FROM superstoredatasets GROUP BY `Region` ORDER BY total_sales DESC;

SELECT `Category`, `Sub-Category`, ROUND(SUM(`Sales`),2) AS total_sales,
       ROUND(SUM(`Profit`),2) AS total_profit,
       ROUND(SUM(`Profit`)/SUM(`Sales`)*100,2) AS margin_pct
FROM superstoredatasets
GROUP BY `Category`, `Sub-Category`
ORDER BY total_profit DESC;

WITH st AS (
    SELECT `State`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit,
           SUM(`Profit`)/SUM(`Sales`)*100 AS margin_pct
    FROM superstoredatasets GROUP BY `State`
)
SELECT `State`, ROUND(total_sales,2) AS total_sales, ROUND(total_profit,2) AS total_profit,
       ROUND(margin_pct,2) AS margin_pct
FROM st
WHERE total_sales > (SELECT AVG(total_sales) FROM st)
  AND (total_profit < 0 OR margin_pct < 5)
ORDER BY total_profit;

SELECT CASE WHEN `Discount` = 0    THEN '1. No discount'
            WHEN `Discount` <= 0.10 THEN '2. Up to 10%'
            WHEN `Discount` <= 0.20 THEN '3. 10-20%'
            WHEN `Discount` <= 0.30 THEN '4. 20-30%'
            WHEN `Discount` <= 0.50 THEN '5. 30-50%'
            ELSE '6. Over 50%' END AS discount_band,
       COUNT(*) AS line_items, ROUND(SUM(`Sales`),2) AS total_sales,
       ROUND(SUM(`Profit`),2) AS total_profit,
       ROUND(SUM(`Profit`)/SUM(`Sales`)*100,2) AS margin_pct,
       ROUND(AVG(`Profit`),2) AS avg_profit_per_line
FROM superstoredatasets
GROUP BY discount_band
ORDER BY discount_band;
SELECT ROUND((AVG(`Discount`*`Profit`) - AVG(`Discount`)*AVG(`Profit`))
             / (STDDEV_POP(`Discount`) * STDDEV_POP(`Profit`)), 4) AS corr_discount_profit
FROM superstoredatasets;

SELECT `Customer ID`, `Customer Name`, `Segment`,
       ROUND(SUM(`Sales`),2) AS total_sales, ROUND(SUM(`Profit`),2) AS total_profit,
       RANK() OVER (ORDER BY SUM(`Sales`)  DESC) AS sales_rank,
       RANK() OVER (ORDER BY SUM(`Profit`) DESC) AS profit_rank
FROM superstoredatasets
GROUP BY `Customer ID`, `Customer Name`, `Segment`
ORDER BY total_sales DESC
LIMIT 10;
-- Top 10 by profit
SELECT `Customer ID`, `Customer Name`, ROUND(SUM(`Profit`),2) AS total_profit
FROM superstoredatasets GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_profit DESC LIMIT 10;

SELECT `Ship Mode`, COUNT(*) AS orders, ROUND(AVG(order_total),2) AS avg_order_value,
       ROUND(AVG(order_profit),2) AS avg_order_profit
FROM (SELECT `Order ID`, `Ship Mode`, SUM(`Sales`) AS order_total, SUM(`Profit`) AS order_profit
      FROM superstoredatasets GROUP BY `Order ID`, `Ship Mode`) o
GROUP BY `Ship Mode`
ORDER BY avg_order_value DESC;

-- Yearly with year-over-year growth
WITH y AS (
    SELECT YEAR(`Order Date`) AS yr, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
    FROM superstoredatasets GROUP BY YEAR(`Order Date`)
)
SELECT yr, ROUND(total_sales,2) AS total_sales, ROUND(total_profit,2) AS total_profit,
       ROUND((total_sales / LAG(total_sales) OVER (ORDER BY yr) - 1) * 100,1) AS yoy_growth_pct
FROM y ORDER BY yr;

-- Monthly, with the same month in the previous year
WITH m AS (
    SELECT YEAR(`Order Date`) AS yr, MONTH(`Order Date`) AS mth, SUM(`Sales`) AS `Sales`
    FROM superstoredatasets GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
)
SELECT yr, mth, ROUND(`Sales`,2) AS `Sales`,
       ROUND(LAG(`Sales`, 12) OVER (ORDER BY yr, mth),2) AS same_month_last_year
FROM m ORDER BY yr, mth;

WITH prod AS (
    SELECT `Product ID`, `Product Name`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
    FROM superstoredatasets GROUP BY `Product ID`, `Product Name`
),
ranked AS (
    SELECT *, RANK() OVER (ORDER BY total_sales  DESC) AS sales_rank,
              RANK() OVER (ORDER BY total_profit ASC)  AS loss_rank
    FROM prod
)
SELECT 'Top 5 by Sales' AS list_name, `Product Name`,
       ROUND(total_sales,2) AS total_sales, ROUND(total_profit,2) AS total_profit
FROM ranked WHERE sales_rank <= 5
UNION ALL
SELECT 'Bottom 5 by Profit', `Product Name`,
       ROUND(total_sales,2), ROUND(total_profit,2)
FROM ranked WHERE loss_rank <= 5;

-- Products that appear in BOTH lists (may return no rows)
WITH prod AS (
    SELECT `Product ID`, `Product Name`, SUM(`Sales`) AS total_sales, SUM(`Profit`) AS total_profit
    FROM superstoredatasets GROUP BY `Product ID`, `Product Name`
),
ranked AS (
    SELECT *, RANK() OVER (ORDER BY total_sales  DESC) AS sales_rank,
              RANK() OVER (ORDER BY total_profit ASC)  AS loss_rank
    FROM prod
)
SELECT `Product Name`, total_sales, total_profit FROM ranked
WHERE sales_rank <= 5 AND loss_rank <= 5;