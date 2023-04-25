import pytest
import pymssql


class SQLConnect:
    # Create SQL Server database connection
    def __init__(self):
        conn = pymssql.connect(
            server='127.0.0.1',
            user='TestUser3',
            password='TestUser3',
            database='TRN'
        )
        self.cursor = conn.cursor()

    def execute_query(self, query):
        # execute query and return 1 row
        self.cursor.execute(query)
        return self.cursor.fetchone()


@pytest.fixture(scope="session")
def db():
    return SQLConnect()
