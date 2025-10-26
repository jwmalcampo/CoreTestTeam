*** Settings ***
Documentation    Automated Functional Tests for Customers Module
Library          SeleniumLibrary
Resource         ../resources/customers_keywords.robot
Suite Setup      Login To Admin
Suite Teardown   Logout From Admin

*** Variables ***
${RANDOM_NUM}    ${EMPTY}

*** Test Cases ***
TC_AUTO_001_Navigate_To_Customers_Page
    [Documentation]    TC_CUST_001: Verify customers page is accessible
    [Tags]    smoke
    Navigate To Customers
    Page Should Contain Element    xpath://a[contains(@href, 'customers/create')]
    Page Should Contain Element    xpath://a[contains(@href, 'customer_groups')]

TC_AUTO_002_Create_Customer_Valid_Data
    [Documentation]    TC_CUST_002: Create customer with all valid data and customer group
    [Tags]    functional    happy-path
    Navigate To Customers
    Click Add Customer Button
    ${RANDOM_NUM}=    Evaluate    str(random.randint(1000, 9999))    random
    Set Suite Variable    ${RANDOM_NUM}
    Fill Customer Form    TestFirst    TestLast${RANDOM_NUM}    test${RANDOM_NUM}@example.com    +1234567890
    Select Customer Group    Default group
    Click Save Button
    Verify Success Message
    Verify Customer In List    test${RANDOM_NUM}@example.com

    ${CREATED_EMAIL}=    Set Variable    test${RANDOM_NUM}@example.com
    ${CREATED_NAME}=     Set Variable    TestLast${RANDOM_NUM}
    Set Suite Variable    ${CREATED_EMAIL}
    Set Suite Variable    ${CREATED_NAME}
TC_AUTO_003_Create_Customer_Duplicate_Email
    [Documentation]    TC_CUST_003: Attempt to create customer with existing email
    [Tags]    functional    negative-path
    Navigate To Customers
    Click Add Customer Button
    Fill Customer Form    Duplicate    Test    ${CREATED_EMAIL}    +61400000001
    Select Customer Group    Default group
    Click Save Button
    Verify Error Message    already been taken

TC_AUTO_004_Create_Customer_Invalid_Email
    [Documentation]    TC_CUST_004: Try to create customer with invalid email format
    [Tags]    functional    validation
    Navigate To Customers
    Click Add Customer Button
    Fill Customer Form    Ted    Mc    notanemail    +61400000002
    Select Customer Group    Default group
    Click Save Button
    Verify Error Message    valid email

TC_AUTO_005_Create_Customer_Empty_Required_Fields
    [Documentation]    TC_CUST_005: Try to save customer with empty required fields
    [Tags]    functional    validation
    Navigate To Customers
    Click Add Customer Button
    Click Save Button
    Page Should Contain Element    xpath://div[contains(@class, 'alert') or contains(@class, 'error')]

TC_AUTO_006_Create_Customer_Missing_Group
    [Documentation]    Try to save customer without selecting customer group
    [Tags]    functional    validation
    Navigate To Customers
    Click Add Customer Button
    Fill Customer Form    Test    User    emptygroup@test.com    +61400000003
    Click Save Button
    Verify Error Message    required

TC_AUTO_007_Edit_Customer_Telephone
    [Documentation]    TC_CUST_006: Update customer telephone number
    [Tags]    functional    edit
    Edit First Customer
    Wait Until Element Is Visible    name:Customer[telephone]    timeout=10s
    Clear Element Text    name:Customer[telephone]
    Input Text    name:Customer[telephone]    +9999999999
    Click Save Button
    Verify Success Message

TC_AUTO_008_Search_Customer_By_Name
    [Documentation]    TC_CUST_007: Search for existing customer by name
    [Tags]    functional    search
    Navigate To Customers
    Sleep    2s
    # Click Filter button
    Wait Until Element Is Visible    xpath://button[@data-toggle='list-filter']    timeout=${TIMEOUT}
    Click Element    xpath://button[@data-toggle='list-filter']
    Sleep    2s
    # Search for customer using actual field name
    Wait Until Element Is Visible    name:list_filterSearch    timeout=${TIMEOUT}
    Input Text    name:list_filterSearch    ${CREATED_NAME}
    Press Keys    name:list_filterSearch    RETURN
    Sleep    3s
    Page Should Contain    ${CREATED_NAME}

TC_AUTO_009_Search_Customer_No_Results
    [Documentation]    TC_CUST_008: Search with non-existent name
    [Tags]    functional    search
    Navigate To Customers
    Sleep    3s
    # Check if filter is already open, if not click it
    ${filter_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    name:list_filterSearch    timeout=2s
    Run Keyword If    not ${filter_visible}    Click Element    xpath://button[@data-toggle='list-filter']
    Run Keyword If    not ${filter_visible}    Sleep    2s
    # Search for non-existent customer
    Wait Until Element Is Visible    name:list_filterSearch    timeout=${TIMEOUT}
    Clear Element Text    name:list_filterSearch
    Input Text    name:list_filterSearch    NonExistentName12345
    Press Keys    name:list_filterSearch    RETURN
    Sleep    3s
    # Should show no customers message or empty table
    ${has_results}=    Run Keyword And Return Status    Page Should Contain    abi iba
    Should Be Equal    ${has_results}    ${False}    msg=Search should return no results

TC_AUTO_010_Delete_Customer
    [Documentation]    TC_CUST_009: Delete a customer record by selecting checkbox and clicking Delete button
    [Tags]    functional    delete
    Navigate To Customers
    Click Add Customer Button
    ${DEL_RANDOM}=    Evaluate    str(random.randint(5000, 9999))    random
    Fill Customer Form    ToDelete    User${DEL_RANDOM}    delete${DEL_RANDOM}@test.com    +61400000999
    Select Customer Group    Default group
    Click Save Button
    Verify Success Message
    Delete Customer    delete${DEL_RANDOM}@test.com
    Verify Success Message

TC_AUTO_011_View_Customer_Groups
    [Documentation]    TC_CUST_010: Navigate to customer groups page
    [Tags]    functional    groups
    Click Groups Button
    Page Should Contain    Groups

*** Keywords ***