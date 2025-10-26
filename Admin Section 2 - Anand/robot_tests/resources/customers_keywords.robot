Delete Customer
    [Arguments]    ${customer_email}
    Navigate To Customers
    Sleep    3s
    # First, ensure we can see all customers by clearing any existing filters
    ${filter_visible}=    Run Keyword And Return Status    Element Should Be Visible    name:list_filterSearch
    Run Keyword If    ${filter_visible}    Clear Element Text    name:list_filterSearch
    Run Keyword If    ${filter_visible}    Press Keys    name:list_filterSearch    RETURN
    Run Keyword If    ${filter_visible}    Sleep    3s
    # If filter not visible, click to open it
    Run Keyword If    not ${filter_visible}    Click Element    xpath://button[@data-toggle='list-filter']
    Run Keyword If    not ${filter_visible}    Sleep    2s
    # Now search for the specific customer
    Wait Until Element Is Visible    name:list_filterSearch    timeout=${TIMEOUT}
    Clear Element Text    name:list_filterSearch
    Input Text    name:list_filterSearch    ${customer_email}
    Press Keys    name:list_filterSearch    RETURN
    Sleep    4s
    # Verify customer appears in results before trying to delete
    Page Should Contain    ${customer_email}
    # Select the checkbox for the customer (not the header checkbox)
    Wait Until Element Is Visible    xpath://table//tbody//tr[1]//input[@type='checkbox']    timeout=${TIMEOUT}
    Click Element    xpath://table//tbody//tr[1]//input[@type='checkbox']
    Sleep    *** Settings ***
Library    SeleniumLibrary

*** Variables ***
${ADMIN_URL}       http://localhost/TastyIgniter_v3/admin
${CUSTOMERS_URL}   http://localhost/TastyIgniter_v3/admin/customers
${ADMIN_USERNAME}  anand
${ADMIN_PASS}      MySecurePass123!
${BROWSER}         chrome
${TIMEOUT}         40s

*** Keywords ***
Login To Admin
    Open Browser    ${ADMIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    name:username    timeout=${TIMEOUT}
    Input Text    name:username    ${ADMIN_USERNAME}
    Input Text    name:password    ${ADMIN_PASS}
    Click Button    xpath://button[contains(text(), 'Login')]
    Wait Until Page Contains    Dashboard    timeout=${TIMEOUT}
    Sleep    2s

Navigate To Customers
    Go To    ${CUSTOMERS_URL}
    Sleep    3s
    Wait Until Element Is Visible    xpath://a[contains(@href, 'customers/create')]    timeout=${TIMEOUT}

Click Add Customer Button
    Wait Until Element Is Visible    xpath://a[contains(@href, 'customers/create')]    timeout=${TIMEOUT}
    # Wait for any success alerts to disappear
    Sleep    2s
    ${alert_visible}=    Run Keyword And Return Status    Element Should Be Visible    xpath://div[contains(@class, 'alert-success')]
    Run Keyword If    ${alert_visible}    Sleep    3s
    Click Element    xpath://a[contains(@href, 'customers/create')]
    Sleep    3s
    Wait Until Element Is Visible    name:Customer[first_name]    timeout=${TIMEOUT}

Fill Customer Form
    [Arguments]    ${first}    ${last}    ${email}    ${phone}
    Wait Until Element Is Visible    name:Customer[first_name]    timeout=${TIMEOUT}
    Input Text    name:Customer[first_name]    ${first}
    Input Text    name:Customer[last_name]     ${last}
    Input Text    name:Customer[email]         ${email}
    Input Text    name:Customer[telephone]     ${phone}
    Sleep    1s

Select Customer Group
    [Arguments]    ${group_name}=Default group
    # Wait for the custom dropdown wrapper to be visible (SlimSelect library)
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-main')]    timeout=${TIMEOUT}
    Scroll Element Into View    xpath://div[contains(@class, 'ss-main')]
    Sleep    1s
    # Click to open the dropdown
    Click Element    xpath://div[contains(@class, 'ss-main')]
    Sleep    1s
    # Wait for and click the option
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option') and contains(text(), '${group_name}')]    timeout=10s
    Click Element    xpath://div[contains(@class, 'ss-option') and contains(text(), '${group_name}')]
    Sleep    1s

Click Save Button
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=${TIMEOUT}
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s

Verify Success Message
    Wait Until Page Contains Element    xpath://*[contains(text(), 'success') or contains(@class, 'success')]    timeout=${TIMEOUT}

Verify Error Message
    [Arguments]    ${message}
    Wait Until Page Contains    ${message}    timeout=${TIMEOUT}

Verify Customer In List
    [Arguments]    ${email}
    Navigate To Customers
    Sleep    4s
    Wait Until Page Contains    ${email}    timeout=${TIMEOUT}

Search Customer
    [Arguments]    ${search_term}
    Navigate To Customers
    Sleep    2s
    # Click the Filter button using aria-label or icon
    Wait Until Element Is Visible    xpath://button[@aria-label='Filter' or @data-toggle='list-filter']    timeout=${TIMEOUT}
    Click Element    xpath://button[@aria-label='Filter' or @data-toggle='list-filter']
    Sleep    1s
    # Enter search term in the revealed search field
    Wait Until Element Is Visible    xpath://input[@placeholder='Search by name or email.' or contains(@placeholder, 'Search')]    timeout=${TIMEOUT}
    Input Text    xpath://input[@placeholder='Search by name or email.' or contains(@placeholder, 'Search')]    ${search_term}
    Sleep    3s

Edit First Customer
    Navigate To Customers
    Sleep    2s
    # Click on edit button for first customer
    Wait Until Element Is Visible    xpath://a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    Click Element    xpath:(//a[contains(@class, 'btn-edit')])[1]
    Sleep    3s

Delete Customer
    [Arguments]    ${customer_email}
    Navigate To Customers
    Sleep    3s
    # First, ensure we can see all customers by clearing any existing filters
    ${filter_visible}=    Run Keyword And Return Status    Element Should Be Visible    name:list_filterSearch
    Run Keyword If    ${filter_visible}    Clear Element Text    name:list_filterSearch
    Run Keyword If    ${filter_visible}    Press Keys    name:list_filterSearch    RETURN
    Run Keyword If    ${filter_visible}    Sleep    3s
    # If filter not visible, click to open it
    Run Keyword If    not ${filter_visible}    Click Element    xpath://button[@data-toggle='list-filter']
    Run Keyword If    not ${filter_visible}    Sleep    2s
    # Now search for the specific customer
    Wait Until Element Is Visible    name:list_filterSearch    timeout=${TIMEOUT}
    Clear Element Text    name:list_filterSearch
    Input Text    name:list_filterSearch    ${customer_email}
    Press Keys    name:list_filterSearch    RETURN
    Sleep    4s
    # Verify customer appears in results before trying to delete
    Page Should Contain    ${customer_email}
    # Select the checkbox for the customer (not the header checkbox)
    Wait Until Element Is Visible    xpath://table//tbody//tr[1]//input[@type='checkbox']    timeout=${TIMEOUT}
    Click Element    xpath://table//tbody//tr[1]//input[@type='checkbox']
    Sleep    2s
    # Click the Delete button that appears in toolbar
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    timeout=${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    # Handle the JavaScript alert - accept it (click OK)
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s

Click Groups Button
    Navigate To Customers
    Wait Until Element Is Visible    xpath://a[contains(@href, 'customer_groups')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@href, 'customer_groups')]
    Sleep    3s

Logout From Admin
    ${logout_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://a[contains(@href, 'logout')]    timeout=5s
    Run Keyword If    ${logout_exists}    Click Element    xpath://a[contains(@href, 'logout')]
    Sleep    2s
    Close All Browsers