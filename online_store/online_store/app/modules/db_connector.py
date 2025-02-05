import psycopg2
from typing import Optional, Dict

class DBConnector:
    def __init__(self):
        self.config = {
            "dbname": "c_db",
            "user": "c",
            "password": "1",
            "host": "localhost"
        }
        
    def get_connection(self):
        return psycopg2.connect(**self.config)
    
    def execute_query(self, query: str, params: Optional[tuple] = None) -> list:
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params or ())
                if cursor.description:
                    return cursor.fetchall()
                return []

class ReportManager(DBConnector):
    def get_view_data(self, view_name: str) -> list:
        return self.execute_query(f"SELECT * FROM {view_name}")
    
    def call_function(self, func_name: str, params: tuple) -> list:
        return self.execute_query(f"SELECT * FROM {func_name}(%s)", params)
    
    def call_procedure(self, proc_name: str, params: tuple):
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc(proc_name, params)
                conn.commit()

