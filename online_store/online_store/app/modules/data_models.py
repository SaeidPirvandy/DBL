from dataclasses import dataclass
from datetime import date
from typing import List, Dict

@dataclass
class Product:
    name: str
    description: str
    brand_id: int
    base_price: float
    cost: float
    quantity: int

@dataclass
class OrderItem:
    product_id: int
    quantity: int
    discount_id: Optional[int] = None
