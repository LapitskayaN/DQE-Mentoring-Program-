*** Settings ***
Library           DatabaseLibrary
Library           Screenshot
Library           OperatingSystem
Resource          resources/variables.robot

*** Variables ***
${DBName}         TNR
${DBUser}         TestUser3
${DBPass}         TestUser3
${DBPort}         1433
${DBHost}         127.0.0.1



*** Test Cases ***


Connect to database
    Connect To Database    pymssql

Tc_screen
    Take Screenshot
    Log    screen was take

TC1 Count of unique values of city column in US from table hr.locations
    @{results}    Query    SELECT COUNT(DISTINCT(city)) FROM ${TABLE_NAME1} where country_id = 'US'
    Should Not Be Empty    ${results}
    Should Be Equal As Integers    ${results}[0][0]    ${ER_TC1}

TC2 Found post-code of some city from table hr.locations
    [Template]    Check post_code
                                    postal_code    'Munich'

TC3 Find max value in column country_name where region_id ='1' from table hr.countries
    @{results}    Query    SELECT max(country_name) FROM ${TABLE_NAME2} where region_id ='1'
    Should Not Be Empty    ${results}
    Should Be Equal As Strings    ${results}[0][0]    ${ER_TC3}

TC4 Check number of NULL values in columns table hr.countries
    [Template]    Check number of NULL values in column
                                country_name
                                region_id

TC5 Check minimal value in region_name column
    @{results}    Query    SELECT min(last_name) FROM ${TABLE_NAME3}
    Should Not Be Empty    ${results}
    Should Be Equal As Strings    ${results}[0][0]    ${ER_TC5}

TC6 Check average salary
    [Template]    Check average value in column
                                salary    ${ER_TC6}

*** Keywords ***
Check post_code
    [Arguments]    ${column}    ${filter_column}
    @{results}    Query    SELECT ${column} from ${TABLE_NAME1} where city = ${filter_column}
    Should Not Be Empty    ${results}

Check number of NULL values in column
    [Arguments]    ${column}
    @{results}    Query    SELECT * from ${TABLE_NAME2} WHERE ${column} IS NULL
    Should Be Empty    ${results}

Check average value in column
    [Arguments]    ${column}    ${expected}
    @{results}    Query    SELECT AVG(${column}) from ${TABLE_NAME3} where department_id='10'
    Should Be Equal As Strings    ${results}[0][0]    ${expected}
