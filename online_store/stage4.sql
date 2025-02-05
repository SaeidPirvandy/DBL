----------------------------
-- Report 5: City Users with Orders (Monthly)
----------------------------
CREATE OR REPLACE VIEW city_monthly_users AS
SELECT u.user_id, u.username, c.name AS city
FROM users u
JOIN cities c USING (city_id)
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.user_id = u.user_id
    AND EXTRACT(MONTH FROM o.order_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM o.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
);

----------------------------
-- Report 6: Top Buyers (6 Months)
----------------------------
CREATE MATERIALIZED VIEW top_half_year_buyers AS
WITH purchase_counts AS (
    SELECT o.user_id, SUM(oi.quantity) AS total_items,
           COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN order_items oi USING (order_id)
    WHERE o.order_date BETWEEN DATE_TRUNC('year', CURRENT_DATE) 
                          AND DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '6 months'
    GROUP BY o.user_id
)
SELECT u.*, pc.total_items, pc.order_count
FROM purchase_counts pc
JOIN users u USING (user_id)
ORDER BY pc.total_items DESC
LIMIT 10;

----------------------------
-- Report 7: Monthly Profit Leaders
----------------------------
CREATE OR REPLACE FUNCTION monthly_profit_leaders(target_month DATE)
RETURNS TABLE (
    product_id INT,
    product_name VARCHAR(200),
    total_profit DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.product_id, p.name,
           SUM((oi.sold_price - p.cost) * oi.quantity) AS profit
    FROM order_items oi
    JOIN products p USING (product_id)
    JOIN orders o USING (order_id)
    WHERE DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', target_month)
    GROUP BY p.product_id
    ORDER BY profit DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

----------------------------
-- Report 8: Least Popular Brands
----------------------------
CREATE VIEW unpopular_brands AS
SELECT b.brand_id, b.name,
       COUNT(DISTINCT c.comment_id) AS comment_count,
       COUNT(DISTINCT oi.order_item_id) AS order_count
FROM brands b
LEFT JOIN products p USING (brand_id)
LEFT JOIN comments c USING (product_id)
LEFT JOIN order_items oi USING (product_id)
GROUP BY b.brand_id
ORDER BY (comment_count + order_count) ASC
LIMIT 5;

----------------------------
-- Report 9: Low-Sales Brands
----------------------------
CREATE VIEW low_sales_brands AS
WITH monthly_sales AS (
    SELECT p.brand_id,
           DATE_TRUNC('month', o.order_date) AS month,
           COUNT(DISTINCT oi.product_id) AS products_sold
    FROM order_items oi
    JOIN orders o USING (order_id)
    JOIN products p USING (product_id)
    GROUP BY p.brand_id, month
    HAVING COUNT(DISTINCT oi.product_id) <= 1
)
SELECT b.* 
FROM brands b
WHERE NOT EXISTS (
    SELECT 1 FROM monthly_sales ms
    WHERE ms.brand_id = b.brand_id
    AND ms.products_sold > 1
);

----------------------------
-- Report 10: Price Change Leaders
----------------------------
CREATE OR REPLACE FUNCTION most_price_changes(start_date DATE, end_date DATE)
RETURNS TABLE (
    product_id INT,
    product_name VARCHAR(200),
    change_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.product_id, p.name, COUNT(ph.price_id) AS changes
    FROM price_history ph
    JOIN products p USING (product_id)
    WHERE ph.effective_date BETWEEN start_date AND end_date
    GROUP BY p.product_id
    ORDER BY changes DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

----------------------------
-- Report 11: City Profit Breakdown
----------------------------
CREATE MATERIALIZED VIEW monthly_city_profits AS
SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    p.product_id,
    c.name AS city,
    SUM((oi.sold_price - p.cost) * oi.quantity) AS profit
FROM order_items oi
JOIN orders o USING (order_id)
JOIN users u USING (user_id)
JOIN cities c USING (city_id)
JOIN products p USING (product_id)
GROUP BY month, p.product_id, c.name;

----------------------------
-- Report 12: Discount Champions
----------------------------
CREATE OR REPLACE FUNCTION yearly_discount_leaders(target_year INT)
RETURNS TABLE (
    user_id INT,
    username VARCHAR(50),
    total_discounts DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.user_id, u.username, 
           SUM(oi.discount_amount * oi.quantity) AS total_saved
    FROM order_items oi
    JOIN orders o USING (order_id)
    JOIN users u USING (user_id)
    WHERE EXTRACT(YEAR FROM o.order_date) = target_year
    GROUP BY u.user_id
    ORDER BY total_saved DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Indexes for Report Performance
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_price_history_dates ON price_history(effective_date);
