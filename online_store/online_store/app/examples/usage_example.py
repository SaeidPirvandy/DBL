from examples.report_examples import StoreApp
from modules.data_models import Product, OrderItem

def main():
    app = StoreApp()
    
    # Using a view
    print("City Users:")
    print(app.get_city_users("Tehran"))
    
    # Using a function
    print("\nMarch Profit Leaders:")
    print(app.get_monthly_profit_leaders("2024-03-01"))
    
    # Using a procedure
    new_product = Product(
        name="Wireless Headphones",
        description="Noise-canceling BT headphones",
        brand_id=1,
        base_price=3500000,
        cost=2500000,
        quantity=50
    )
    app.add_product(new_product)
    
    # Place order
    order_items = [
        OrderItem(product_id=1, quantity=2),
        OrderItem(product_id=3, quantity=1, discount_id=2)
    ]
    app.place_order(1, order_items)
    
    # Get discount leaders
    print("\n2024 Discount Leaders:")
    print(app.get_discount_leaders(2024))

if __name__ == "__main__":
    main()
