-- Stored Procedures
CREATE OR REPLACE PROCEDURE import_table(
    table_name TEXT,
    csv_path TEXT,
    delimiter CHAR(1) DEFAULT ','
) LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format('COPY %I FROM %L WITH CSV HEADER DELIMITER %L', 
                 table_name, csv_path, delimiter);
END;
$$;

-- Grant permission if needed
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO c;
