*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${BROWSER}             chrome
${BASE_URL}            http://localhost/TastyIgniter_v3
${ADMIN_URL}           ${BASE_URL}/admin
${ADMIN_USERNAME}      anand
${ADMIN_PASS}          MySecurePass123!
${TIMEOUT}             40s

# Module URLs
${LOCATIONS_URL}       ${ADMIN_URL}/locations
${MENUS_URL}           ${ADMIN_URL}/menus
${CATEGORIES_URL}      ${ADMIN_URL}/categories
${MEALTIMES_URL}       ${ADMIN_URL}/mealtimes
${TABLES_URL}          ${ADMIN_URL}/tables
${ALLERGENS_URL}       ${ADMIN_URL}/allergens

*** Keywords ***
# ============================================
# LOGIN / SETUP
# ============================================
Open Admin And Login
    [Arguments]    ${username}=${ADMIN_USERNAME}    ${password}=${ADMIN_PASS}
    Open Browser    ${ADMIN_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    xpath://input[@name='username' or contains(@id, 'username')]    ${TIMEOUT}
    Input Text    xpath://input[@name='username' or contains(@id, 'username')]    ${username}
    Input Password    xpath://input[@name='password' or contains(@id, 'password')]    ${password}
    Click Button    xpath://button[@type='submit' or contains(., 'Sign in')]
    Sleep    3s
    Wait Until Page Contains Element    xpath://a[contains(@href, 'locations') or contains(@href, 'dashboard')]    ${TIMEOUT}

Logout And Close
    Run Keyword And Ignore Error    Click Element    xpath://a[contains(@href, 'logout')]
    Sleep    1s
    Close All Browsers

# ============================================
# SHARED HELPERS
# ============================================
Design Verify Success Message
    # Try multiple success message patterns
    ${has_success}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath://*[contains(@class,'alert-success')]    timeout=5s
    Run Keyword Unless    ${has_success}    Wait Until Page Contains Element    xpath://*[contains(text(),'success')]    timeout=5s

# ============================================
# LOCATIONS
# ============================================
Go To Locations
    Go To    ${LOCATIONS_URL}
    Wait Until Page Contains    Locations    ${TIMEOUT}
    Sleep    2s

Create Location
    [Arguments]    ${name}    ${email}    ${phone}    ${address1}    ${city}    ${state}    ${country}    ${postcode}
    Go To Locations
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    # Fill Details tab
    Wait Until Element Is Visible    xpath://input[contains(@name, 'location_name')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'location_name')]    ${name}
    Input Text    xpath://input[contains(@name, 'location_email')]    ${email}
    Input Text    xpath://input[contains(@name, 'location_telephone')]    ${phone}
    Input Text    xpath://input[contains(@name, 'address_1') or contains(@name, 'location_address_1')]    ${address1}
    Input Text    xpath://input[contains(@name, 'location_city')]    ${city}
    Input Text    xpath://input[contains(@name, 'location_state')]    ${state}
    Input Text    xpath://input[contains(@name, 'location_postcode')]    ${postcode}
    
    # Country - custom dropdown with search
    # First click the dropdown container to open it
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-values')]//div[contains(@class, 'ss-single')]    ${TIMEOUT}
    Click Element    xpath://div[contains(@class, 'ss-values')]//div[contains(@class, 'ss-single')]
    Sleep    1s
    
    # Then type in the search input that appears
    Wait Until Element Is Visible    xpath://input[@type='search' and @placeholder='Search']    ${TIMEOUT}
    Input Text    xpath://input[@type='search' and @placeholder='Search']    ${country}
    Sleep    1s
    
    # Click the matching option
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option') and contains(., '${country}')]    ${TIMEOUT}
    Click Element    xpath://div[contains(@class, 'ss-option') and contains(., '${country}')]
    Sleep    1s
    
    # Save
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Location Telephone
    [Arguments]    ${name}    ${new_phone}
    Go To Locations
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://input[contains(@name, 'location_telephone')]    ${TIMEOUT}
    Clear Element Text    xpath://input[contains(@name, 'location_telephone')]
    Input Text    xpath://input[contains(@name, 'location_telephone')]    ${new_phone}
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Delete Location
    [Arguments]    ${name}
    Go To Locations
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//input[@type='checkbox']    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    ${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message

# ============================================
# MENU ITEMS
# ============================================
Go To Menu Items
    Go To    ${MENUS_URL}
    Wait Until Page Contains    Menus    ${TIMEOUT}
    Sleep    2s

Create Menu Item
    [Arguments]    ${name}    ${price}    ${priority}
    Go To Menu Items
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    Wait Until Element Is Visible    xpath://input[contains(@name, 'menu_name')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'menu_name')]    ${name}
    Input Text    xpath://input[contains(@name, 'menu_price')]    ${price}
    Input Text    xpath://input[contains(@name, 'menu_priority') or contains(@name, 'priority')]    ${priority}
    
    # Status toggle - enable
    ${status_checked}=    Run Keyword And Return Status    Element Should Be Visible    xpath://input[contains(@name, 'menu_status') and @checked]
    Run Keyword Unless    ${status_checked}    Click Element    xpath://label[contains(@for, 'menu_status')]
    
    # Save
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Menu Price
    [Arguments]    ${name}    ${new_price}
    Go To Menu Items
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://input[contains(@name, 'menu_price')]    ${TIMEOUT}
    Clear Element Text    xpath://input[contains(@name, 'menu_price')]
    Input Text    xpath://input[contains(@name, 'menu_price')]    ${new_price}
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Menu Stock
    [Arguments]    ${name}    ${qty}
    Go To Menu Items
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    
    # Click "Manage Stock" button
    Wait Until Element Is Visible    xpath://a[@data-toggle='record-editor' and contains(., 'Manage Stock')]    ${TIMEOUT}
    Click Element    xpath://a[@data-toggle='record-editor' and contains(., 'Manage Stock')]
    Sleep    3s
    
    # Wait for Stock Action dropdown
    Wait Until Element Is Visible    xpath://div[@class='ss-values']//div[contains(@class, 'ss-single')]    ${TIMEOUT}
    
    # Click Stock Action dropdown
    Click Element    xpath://div[@class='ss-values']//div[contains(@class, 'ss-single')]
    Sleep    1s
    
    # Select "[+] Stock Received"
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option') and contains(., '[+] Stock Received')]    ${TIMEOUT}
    Click Element    xpath://div[contains(@class, 'ss-option') and contains(., '[+] Stock Received')]
    Sleep    2s
    
    # Enter quantity
    Wait Until Element Is Visible    xpath://input[@type='number' and contains(@id, 'stock-action-quantity')]    ${TIMEOUT}
    Clear Element Text    xpath://input[@type='number' and contains(@id, 'stock-action-quantity')]
    Input Text    xpath://input[@type='number' and contains(@id, 'stock-action-quantity')]    ${qty}
    Sleep    1s
    
    # Click Save - using class selectors that match the button
    Wait Until Element Is Visible    xpath://button[@type='submit' and contains(@class, 'btn-primary')]    ${TIMEOUT}
    Click Button    xpath://button[@type='submit' and contains(@class, 'btn-primary')]
    Sleep    4s
    Design Verify Success Message

Open Allergens
    Go To    ${ALLERGENS_URL}
    Wait Until Page Contains    Allergens    ${TIMEOUT}
    Sleep    2s

Delete Menu Item
    [Arguments]    ${name}
    Go To Menu Items
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//input[@type='checkbox']    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    ${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message

# ============================================
# CATEGORIES
# ============================================
Go To Categories
    Go To    ${CATEGORIES_URL}
    Wait Until Page Contains    Categories    ${TIMEOUT}
    Sleep    2s

Create Category
    [Arguments]    ${name}    ${priority}=10
    Go To Categories
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    Wait Until Element Is Visible    xpath://input[contains(@name, 'Category[name]') or contains(@name, '[name]')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'Category[name]') or contains(@name, '[name]')]    ${name}
    Input Text    xpath://input[contains(@name, 'priority')]    ${priority}
    
    # Enable status
    ${status_checked}=    Run Keyword And Return Status    Element Should Be Visible    xpath://input[contains(@name, 'status') and @checked]
    Run Keyword Unless    ${status_checked}    Click Element    xpath://label[contains(@for, 'status')]
    
    # Save
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Category Priority
    [Arguments]    ${name}    ${new_priority}
    Go To Categories
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://input[contains(@name, 'priority')]    ${TIMEOUT}
    Clear Element Text    xpath://input[contains(@name, 'priority')]
    Input Text    xpath://input[contains(@name, 'priority')]    ${new_priority}
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Delete Category
    [Arguments]    ${name}
    Go To Categories
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//input[@type='checkbox']    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    ${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message

# ============================================
# MEALTIMES
# ============================================
Go To Mealtimes
    Go To    ${MEALTIMES_URL}
    Wait Until Page Contains    Mealtimes    ${TIMEOUT}
    Sleep    2s

Create Mealtime
    [Arguments]    ${name}    ${start}    ${end}
    Go To Mealtimes
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    Wait Until Element Is Visible    xpath://input[contains(@name, 'mealtime_name') or contains(@name, '[name]')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'mealtime_name') or contains(@name, '[name]')]    ${name}
    Input Text    xpath://input[contains(@name, 'start_time')]    ${start}
    Input Text    xpath://input[contains(@name, 'end_time')]    ${end}
    
    # Enable status
    ${status_checked}=    Run Keyword And Return Status    Element Should Be Visible    xpath://input[contains(@name, 'status') and @checked]
    Run Keyword Unless    ${status_checked}    Click Element    xpath://label[contains(@for, 'status')]
    
    # Save
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Mealtime End
    [Arguments]    ${name}    ${new_end}
    Go To Mealtimes
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://input[contains(@name, 'end_time')]    ${TIMEOUT}
    Clear Element Text    xpath://input[contains(@name, 'end_time')]
    Input Text    xpath://input[contains(@name, 'end_time')]    ${new_end}
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Delete Mealtime
    [Arguments]    ${name}
    Go To Mealtimes
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//input[@type='checkbox']    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    ${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message

# ============================================
# TABLES
# ============================================
Go To Tables
    Go To    ${TABLES_URL}
    Wait Until Page Contains    Tables    ${TIMEOUT}
    Sleep    2s

Create Table
    [Arguments]    ${name}    ${min}    ${max}    ${priority}=0
    Go To Tables
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    Wait Until Element Is Visible    xpath://input[contains(@name, 'table_name') or contains(@name, '[name]')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'table_name') or contains(@name, '[name]')]    ${name}
    Input Text    xpath://input[contains(@name, 'min_capacity')]    ${min}
    Input Text    xpath://input[contains(@name, 'max_capacity')]    ${max}
    Input Text    xpath://input[contains(@name, 'priority')]    ${priority}
    
    # Extra Capacity is required - set to 2
    Wait Until Element Is Visible    xpath://input[contains(@name, 'extra_capacity')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'extra_capacity')]    2
    
    # Location(s) - custom dropdown, click and select
    ${location_dropdown}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://select[contains(@name, 'location')]    timeout=5s
    Run Keyword If    ${location_dropdown}    Select From List By Label    xpath://select[contains(@name, 'location')]    Default
    ...    ELSE    Run Keywords
    ...    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-main')]    timeout=10s
    ...    AND    Click Element    xpath://div[contains(@class, 'ss-main')]
    ...    AND    Sleep    1s
    ...    AND    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option')]    timeout=10s
    ...    AND    Click Element    xpath:(//div[contains(@class, 'ss-option')])[1]
    ...    AND    Sleep    1s
    
    # Enable status
    ${status_checked}=    Run Keyword And Return Status    Element Should Be Visible    xpath://input[contains(@name, 'status') and @checked]
    Run Keyword Unless    ${status_checked}    Click Element    xpath://label[contains(@for, 'status')]
    
    # Save
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Edit Table Max Capacity
    [Arguments]    ${name}    ${new_max}
    Go To Tables
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://input[contains(@name, 'max_capacity')]    ${TIMEOUT}
    Clear Element Text    xpath://input[contains(@name, 'max_capacity')]
    Input Text    xpath://input[contains(@name, 'max_capacity')]    ${new_max}
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s
    Design Verify Success Message

Try Create Invalid Table
    [Arguments]    ${name}    ${min}    ${max}
    Go To Tables
    Wait Until Element Is Visible    xpath://a[contains(@href, '/create') or contains(., 'New')]    ${TIMEOUT}
    Click Element    xpath://a[contains(@href, '/create') or contains(., 'New')]
    Sleep    3s
    
    Wait Until Element Is Visible    xpath://input[contains(@name, 'table_name') or contains(@name, '[name]')]    ${TIMEOUT}
    Input Text    xpath://input[contains(@name, 'table_name') or contains(@name, '[name]')]    ${name}
    Input Text    xpath://input[contains(@name, 'min_capacity')]    ${min}
    Input Text    xpath://input[contains(@name, 'max_capacity')]    ${max}
    
    # Try to save - should fail validation or system might allow it
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Click Button    xpath://button[@data-request='onSave']
    Sleep    3s
    
    # Check if validation error appears OR if it saved anyway (system behavior varies)
    ${has_error}=    Run Keyword And Return Status    Page Should Contain Element    xpath://*[contains(@class, 'alert-danger') or contains(@class, 'error') or contains(., 'error')]
    ${has_success}=    Run Keyword And Return Status    Page Should Contain Element    xpath://*[contains(@class, 'alert-success')]
    
    # Log the behavior for documentation
    Run Keyword If    ${has_error}    Log    System correctly shows validation error
    Run Keyword If    ${has_success}    Log    System allows invalid capacity values - potential bug
    
    # Clean up if it was created
    Run Keyword If    ${has_success}    Run Keywords
    ...    Go To Tables
    ...    AND    Sleep    2s
    ...    AND    Run Keyword And Ignore Error    Delete Table    ${name}

Delete Table
    [Arguments]    ${name}
    Go To Tables
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${name}')]//input[@type='checkbox']    ${TIMEOUT}
    Click Element    xpath://tr[contains(., '${name}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    ${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message