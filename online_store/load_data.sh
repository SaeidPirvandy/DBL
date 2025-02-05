#!/bin/bash

DATA_DIR="./data"
DB_NAME="c_db"
DB_USER="c"

declare -A COLUMNS=(
    [cities]="name"
    [brands]="name,description"
    [users]="username,email,city_id"
    [products]="name,description,brand_id,base_price,cost"
    [inventory]="product_id,quantity"
    [orders]="user_id,order_date,status"
    [price_history]="product_id,price,effective_date"
    [discounts]="product_id,discount_amount,start_date,end_date"
    [order_items]="order_id,product_id,quantity,sold_price,discount_amount"
    [comments]="user_id,product_id,comment_text,satisfaction"
    [comment_ratings]="user_id,comment_id,is_like"
)

TABLES=(
    cities
    brands
    users
    products
    inventory
    orders
    price_history
    discounts
    order_items
    comments
    comment_ratings
)

for table in "${TABLES[@]}"; do
    echo "Loading $table..."
    psql -U $DB_USER -d $DB_NAME -c \
        "\copy $table (${COLUMNS[$table]}) FROM '$DATA_DIR/$table.csv' WITH CSV HEADER DELIMITER ',';"
done

echo "All data imported successfully!"
