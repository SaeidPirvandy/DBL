---------------------------
-- Requirement 1-2: Product/Inventory Management --
---------------------------

-- Add Product
CREATE OR REPLACE PROCEDURE add_product(
    p_name VARCHAR(200),
    p_description TEXT,
    p_brand_id INT,
    p_base_price DECIMAL(10,2),
    p_cost DECIMAL(10,2),
    p_quantity INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO products(name, description, brand_id, base_price, cost)
    VALUES (p_name, p_description, p_brand_id, p_base_price, p_cost)
    RETURNING product_id INTO product_id;
    
    INSERT INTO inventory(product_id, quantity)
    VALUES (product_id, p_quantity);
END;
$$;

-- Update Price
CREATE OR REPLACE PROCEDURE update_price(
    p_product_id INT,
    new_price DECIMAL(10,2),
    effective_date DATE DEFAULT CURRENT_DATE
) AS $$
BEGIN
    UPDATE products SET base_price = new_price WHERE product_id = p_product_id;
    INSERT INTO price_history(product_id, price, effective_date)
    VALUES (p_product_id, new_price, effective_date);
END;
$$ LANGUAGE plpgsql;

---------------------------
-- Requirement 3: Search Function --
---------------------------
CREATE OR REPLACE FUNCTION search_products(
    search_term TEXT,
    min_price DECIMAL(10,2) DEFAULT 0,
    max_price DECIMAL(10,2) DEFAULT 9999999999,
    min_inventory INT DEFAULT 0,
    sort_by TEXT DEFAULT 'price',
    sort_dir TEXT DEFAULT 'asc'
) RETURNS TABLE (
    product_id INT,
    name VARCHAR(200),
    price DECIMAL(10,2),
    inventory INT,
    satisfaction_ratio NUMERIC(3,2)
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT p.product_id, p.name, p.base_price, i.quantity, 
                COALESCE(avg(c.satisfaction::int), 0) as satisfaction_ratio
         FROM products p
         LEFT JOIN inventory i USING (product_id)
         LEFT JOIN comments c USING (product_id)
         WHERE (to_tsvector(''english'', p.name || '' '' || p.description) @@ websearch_to_tsquery(%L))
           AND p.base_price BETWEEN %s AND %s
           AND i.quantity >= %s
         GROUP BY p.product_id, i.quantity
         ORDER BY %I %s',
        search_term,
        min_price,
        max_price,
        min_inventory,
        sort_by,
        sort_dir
    );
END;
$$ LANGUAGE plpgsql;

---------------------------
-- Requirement 4: Order/Comments --
---------------------------
-- Place Order
CREATE OR REPLACE PROCEDURE place_order(
    p_user_id INT,
    p_items JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    new_order_id INT;
    item RECORD;
BEGIN
    INSERT INTO orders(user_id, order_date) 
    VALUES (p_user_id, CURRENT_DATE)
    RETURNING order_id INTO new_order_id;

    FOR item IN SELECT * FROM jsonb_to_recordset(p_items) AS x(
        product_id INT, 
        quantity INT,
        discount_id INT DEFAULT NULL
    ) LOOP
        -- Check inventory
        PERFORM 1 FROM inventory 
        WHERE product_id = item.product_id 
        AND quantity >= item.quantity;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient inventory for product %', item.product_id;
        END IF;

        -- Get price and discount
        INSERT INTO order_items(order_id, product_id, quantity, sold_price, discount_amount)
        SELECT new_order_id, item.product_id, item.quantity,
               p.base_price - COALESCE(d.discount_amount, 0),
               COALESCE(d.discount_amount, 0)
        FROM products p
        LEFT JOIN discounts d 
            ON d.product_id = item.product_id
            AND CURRENT_DATE BETWEEN d.start_date AND d.end_date
        WHERE p.product_id = item.product_id;

        -- Update inventory
        UPDATE inventory 
        SET quantity = quantity - item.quantity
        WHERE product_id = item.product_id;
    END LOOP;
END;
$$;

-- Add Comment with Satisfaction
CREATE OR REPLACE PROCEDURE add_comment(
    p_user_id INT,
    p_product_id INT,
    p_comment_text TEXT,
    p_satisfaction BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO comments(user_id, product_id, comment_text, satisfaction)
    VALUES (p_user_id, p_product_id, p_comment_text, p_satisfaction);
END;
$$;

-- Rate Comment
CREATE OR REPLACE PROCEDURE rate_comment(
    p_user_id INT,
    p_comment_id INT,
    p_is_like BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO comment_ratings(user_id, comment_id, is_like)
    VALUES (p_user_id, p_comment_id, p_is_like)
    ON CONFLICT (user_id, comment_id) DO UPDATE
    SET is_like = EXCLUDED.is_like;
    
    -- Prevent self-rating
    IF EXISTS (
        SELECT 1 FROM comments c 
        WHERE c.comment_id = p_comment_id 
        AND c.user_id = p_user_id
    ) THEN
        RAISE EXCEPTION 'Cannot rate your own comment';
    END IF;
END;
$$;

