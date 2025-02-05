CREATE OR REPLACE PROCEDURE import_table(
    table_name TEXT,
    csv_path TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY %I FROM %L WITH CSV HEADER DELIMITER '','';', 
                 table_name, csv_path);
    
    -- Reset sequences after import
    IF table_name = 'users' THEN
        PERFORM setval('users_user_id_seq', (SELECT MAX(user_id) FROM users));
    ELSIF table_name = 'products' THEN
        PERFORM setval('products_product_id_seq', (SELECT MAX(product_id) FROM products));
    END IF;
END;
$$;
