import pytest


# queries to table hr.locations
class TestLocations:
    TABLE = "[TRN].[hr].[locations]"

    # TC1 Count of unique values of city column in US from table hr.locations
    def test_tc1(self, db):
        query = f"SELECT COUNT(DISTINCT(city)) FROM  {self.TABLE} where country_id = 'US';"
        exp_result = 3
        result = db.execute_query(query)
        assert float(result[0]) == exp_result

    # TC2 Found post-code of some city from table hr.locations
    def test_tc2(self, db):
        query = f"SELECT postal_code from {self.TABLE}  where city ='Munich';"
        exp_result = 80925
        result = db.execute_query(query)
        assert float(result[0]) == exp_result


# queries to table hr.countries
class TestCountries:
    TABLE = "[TRN].[hr].[countries]"

    # TC3 Find max value in column country_name where region_id ='1' from table hr.countries
    def test_tc3(self, db):
        query = f"SELECT max(country_name) FROM  {self.TABLE}  where region_id ='1';"
        exp_result = 'United Kingdom'
        result = db.execute_query(query)
        assert result[0] == exp_result

    # TC4 Check number of NULL values in columns table hr.countries
    def test_tc4(self, db):
        query = f"SELECT count(*) from  {self.TABLE}  WHERE country_name IS NULL ;"
        exp_result = 0
        result = db.execute_query(query)
        assert float(result[0]) == exp_result


# queries to table hr.employees
class TestEmployees:
    TABLE = "[TRN].[hr].[employees]"

    # TC5 Check minimal value in region_name column
    def test_tc5(self, db):
        query = f"SELECT min(last_name) FROM   {self.TABLE}  ;"
        exp_result = 'Austin'
        result = db.execute_query(query)
        assert result[0] == exp_result

    # TC6 Check average salary
    def test_tc6(self, db):
        query = f"SELECT  AVG(salary) from  {self.TABLE}   where department_id='10' ;"
        exp_result = 8600
        result = db.execute_query(query)
        assert float(result[0]) == exp_result

