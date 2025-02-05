from modules.db_connector import ReportManager
from modules.data_models import Product, OrderItem
from typing import List

class StoreApp(ReportManager):
    # Views
    def get_city_users(self, city: str) -> list:
        return self.get_view_data("city_monthly_users")
    
    def get_unpopular_brands(self) -> list:
        return self.get_view_data("unpopular_brands")
    
    # Functions
    def get_monthly_profit_leaders(self, month: str) -> list:
        return self.call_function("monthly_profit_leaders", (date.fromisoformat(month),))
    
    def get_discount_leaders(self, year: int) -> list:
        return self.call_function("yearly_discount_leaders", (year,))
    
    # Procedures
    def add_product(self, product: Product):
        self.call_procedure("add_product", (
            product.name,
            product.description,
            product.brand_id,
            product.base_price,
            product.cost,
            product.quantity
        ))
    
    def place_order(self, user_id: int, items: List[OrderItem]):
        items_json = [
            {
                "product_id": item.product_id,
                "quantity": item.quantity,
                **({"discount_id": item.discount_id} if item.discount_id else {})
            }
            for item in items
        ]
        self.call_procedure("place_order", (user_id, items_json))
