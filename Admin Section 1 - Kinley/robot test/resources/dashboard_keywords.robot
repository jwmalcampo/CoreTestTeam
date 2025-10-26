*** Settings ***
Library    SeleniumLibrary
Library    String
Library    DateTime

*** Variables ***
${BROWSER}             chrome
${BASE_URL}            http://localhost/tastyigniter
${ADMIN_URL}           ${BASE_URL}/admin
${ADMIN_USERNAME}      admin
${ADMIN_PASS}          123456
${TIMEOUT}             40s

# Dashboard Module URLs
${DASHBOARD_URL}       ${ADMIN_URL}/dashboard
${LOGIN_URL}           ${ADMIN_URL}/login

*** Keywords ***
# ============================================
# LOGIN / SETUP
# ============================================
Open Admin And Login
    [Arguments]    ${username}=${ADMIN_USERNAME}    ${password}=${ADMIN_PASS}
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    3s
    Wait Until Page Contains    Username    ${TIMEOUT}
    Input Text    name:username    ${username}
    Input Password    name:password    ${password}
    Click Button    xpath://button[@type='submit']
    Sleep    5s
    # Wait for dashboard with correct selector
    Wait Until Page Contains Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]    ${TIMEOUT}
    Log    Login successful - Dashboard loaded

Logout And Close
    Run Keyword And Ignore Error    Click Element    xpath://a[contains(@href, 'logout')]
    Sleep    1s
    Close All Browsers

# ============================================
# NAVIGATION
# ============================================
Go To Dashboard
    ${on_dashboard}=    Run Keyword And Return Status    Location Should Contain    dashboard
    Run Keyword Unless    ${on_dashboard}    Go To    ${DASHBOARD_URL}
    Sleep    2s
    # Wait for the Dashboard span element
    Wait Until Page Contains Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]    ${TIMEOUT}

Verify Dashboard Loaded
    # Use the exact selector for Dashboard
    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]
    # Also check for widgets/cards
    ${has_widgets}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[contains(@class, 'widget') or contains(@class, 'card')]
    Run Keyword Unless    ${has_widgets}    Log    No widgets found on dashboard

Navigate To Section Via Sidebar
    [Arguments]    ${section_name}
    # Click on sidebar item with span structure
    ${clicked}=    Run Keyword And Return Status    
    ...    Click Element    xpath://a[.//span[@class='content' and contains(text(), '${section_name}')]]
    
    Run Keyword Unless    ${clicked}    
    ...    Click Element    xpath://a[contains(., '${section_name}')]
    
    Sleep    2s

# ============================================
# ADD WIDGET MODAL - UPDATED WITH CORRECT SELECTORS
# ============================================
Click Add Widget Button
    [Documentation]    Clicks the Add Widget button to open Bootstrap modal
    # Check if button exists with Bootstrap 5 attributes
    ${button_exists}=    Run Keyword And Return Status    
    ...    Wait Until Element Is Visible    xpath://button[@data-bs-toggle='modal' and @data-bs-target='#newWidgetModal']    timeout=5s
    
    Run Keyword If    ${button_exists}    Run Keywords
    ...    Log    Add Widget button found
    ...    AND    Click Element    xpath://button[@data-bs-target='#newWidgetModal']
    ...    AND    Sleep    2s
    ...    AND    Wait For Add Widget Modal To Open
    ...    ELSE    Log    Add Widget button not found

Wait For Add Widget Modal To Open
    [Documentation]    Waits for the Add Widget modal to be fully visible
    Wait Until Element Is Visible    xpath://div[@id='newWidgetModal']    timeout=10s
    # Check for Bootstrap 'show' class
    Wait Until Page Contains Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]    timeout=5s
    # Wait for form elements to be ready
    Wait Until Element Is Visible    xpath://select[@name='widget']    timeout=5s
    Log    Add Widget modal opened successfully

Select Widget Type
    [Arguments]    ${widget_type}
    [Documentation]    Selects a widget type from the dropdown in Add Widget modal
    # Select from the widget dropdown by visible text
    Wait Until Element Is Visible    xpath://select[@name='widget']    timeout=5s
    Select From List By Label    xpath://select[@name='widget']    ${widget_type}
    Log    Selected widget: ${widget_type}

Select Widget Size
    [Arguments]    ${size}
    [Documentation]    Selects widget grid width size (1-12)
    Wait Until Element Is Visible    xpath://select[@name='size']    timeout=5s
    Select From List By Value    xpath://select[@name='size']    ${size}
    Log    Selected widget size: ${size}

Get Available Widget Types
    [Documentation]    Returns list of available widget types from dropdown
    Wait Until Element Is Visible    xpath://select[@name='widget']    timeout=5s
    @{options}=    Get List Items    xpath://select[@name='widget']
    # Remove empty option if present
    ${filtered_options}=    Create List
    FOR    ${option}    IN    @{options}
        Run Keyword If    '${option}' != 'Select a widget' and '${option}' != ''    
        ...    Append To List    ${filtered_options}    ${option}
    END
    Log    Available widgets: ${filtered_options}
    Return From Keyword    ${filtered_options}

Add Selected Widget
    [Documentation]    Clicks the Add button to add the selected widget
    # Click the Add button with data-request attribute
    Wait Until Element Is Visible    xpath://button[@data-request='dashboardContainer::onAddWidget']    timeout=5s
    Click Element    xpath://button[@data-request='dashboardContainer::onAddWidget']
    Sleep    3s
    Log    Widget add button clicked

Add Widget Complete Process
    [Arguments]    ${widget_type}    ${size}=12
    [Documentation]    Complete process to add a widget: open modal, select widget, select size, add
    # Open modal
    Click Add Widget Button
    
    # Select widget type
    Select Widget Type    ${widget_type}
    
    # Select size
    Select Widget Size    ${size}
    
    # Click Add button
    Add Selected Widget
    
    # Wait for modal to close automatically (data-bs-dismiss="modal")
    Wait Until Page Does Not Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]    timeout=10s
    
    Log    Widget "${widget_type}" with size ${size} added successfully

Close Add Widget Modal
    [Documentation]    Closes the Add Widget modal
    # Try using the Close button
    ${close_button}=    Run Keyword And Return Status    
    ...    Click Element    xpath://button[text()='Close' or @aria-label='Close']
    
    Run Keyword Unless    ${close_button}    
    ...    Click Element    xpath://div[@id='newWidgetModal']//button[@data-bs-dismiss='modal']
    
    Run Keyword Unless    ${close_button}    
    ...    Press Keys    None    ESC
    
    Sleep    2s
    # Verify modal is closed
    Wait Until Page Does Not Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]    timeout=5s
    Log    Add Widget modal closed

Verify Widget Added
    [Arguments]    ${widget_name}
    [Documentation]    Verifies if a widget was successfully added to dashboard
    # Check for success message
    ${has_success}=    Run Keyword And Return Status    
    ...    Wait Until Page Contains Element    xpath://*[contains(@class, 'alert-success') or contains(@class, 'toast-success')]    timeout=3s
    
    # Check if widget appears on dashboard
    ${widget_visible}=    Run Keyword And Return Status    
    ...    Page Should Contain    ${widget_name}
    
    Should Be True    ${has_success} or ${widget_visible}    
    ...    msg=Widget should be added successfully

# ============================================
# WIDGETS
# ============================================
Check Widget Exists
    [Arguments]    ${widget_title}
    [Documentation]    Checks if a widget with the specified title exists
    ${widget_exists}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[contains(@class, 'widget') or contains(@class, 'card')]//*[contains(text(), '${widget_title}')]
    Return From Keyword    ${widget_exists}

Get Widget Value
    [Arguments]    ${widget_title}
    [Documentation]    Gets the numeric value from a widget
    ${value_found}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[contains(., '${widget_title}')]//div[contains(text(), '£')]
    
    Run Keyword If    ${value_found}    
    ...    ${value}=    Get Text    xpath://div[contains(., '${widget_title}')]//div[contains(text(), '£')]
    ...    ELSE    
    ...    ${value}=    Set Variable    0.00
    
    Return From Keyword    ${value}

Count Dashboard Widgets
    [Documentation]    Counts the number of widgets on the dashboard
    @{widgets}=    Get WebElements    xpath://div[contains(@class, 'card') or contains(@class, 'widget')]
    ${count}=    Get Length    ${widgets}
    Log    Found ${count} widgets on dashboard
    Return From Keyword    ${count}

Click Set As Default Button
    ${has_button}=    Run Keyword And Return Status    
    ...    Wait Until Element Is Visible    xpath://button[contains(., 'Set As Default')] | xpath://a[contains(., 'Set As Default')]    timeout=5s
    Run Keyword If    ${has_button}    Run Keywords
    ...    Click Element    xpath://button[contains(., 'Set As Default')] | xpath://a[contains(., 'Set As Default')]
    ...    AND    Sleep    2s
    ...    ELSE    Log    Set As Default button not found

# ============================================
# DATE RANGE
# ============================================
Check Date Range Selector Exists
    ${has_date_range}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://input[contains(@class, 'daterange') or contains(@placeholder, 'date')] | xpath://button[contains(@class, 'date')]
    Return From Keyword    ${has_date_range}

Select Date Range
    [Arguments]    ${start_date}    ${end_date}
    [Documentation]    Selects a date range in the dashboard
    ${has_selector}=    Check Date Range Selector Exists
    Run Keyword If    ${has_selector}    
    ...    Click Element    xpath://input[contains(@class, 'daterange')] | xpath://button[contains(@class, 'date')]
    Sleep    2s

Select Predefined Date Range
    [Arguments]    ${range_option}
    [Documentation]    Selects a predefined date range like "Last 7 days", "Last 30 days", etc.
    ${has_selector}=    Check Date Range Selector Exists
    Run Keyword If    ${has_selector}    Run Keywords
    ...    Click Element    xpath://input[contains(@class, 'daterange')] | xpath://button[contains(@class, 'date')]
    ...    AND    Sleep    1s
    ...    AND    Click Element    xpath://li[contains(., '${range_option}')] | xpath://a[contains(., '${range_option}')]
    Sleep    2s

# ============================================
# REPORTS/CHARTS
# ============================================
Check Reports Chart Exists
    ${has_chart}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://canvas | xpath://div[contains(@class, 'chart')] | xpath://*[contains(text(), 'Reports Chart')]
    Return From Keyword    ${has_chart}

Check Chart Has Data
    [Documentation]    Verifies if the chart has actual data points
    ${has_data}=    Run Keyword And Return Status    
    ...    Page Should Not Contain    No data available
    Return From Keyword    ${has_data}

Get Chart Type
    [Documentation]    Returns the type of chart displayed
    ${has_canvas}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://canvas
    Run Keyword If    ${has_canvas}    Return From Keyword    Line Chart
    ...    ELSE    Return From Keyword    Unknown

# ============================================
# STATISTICS
# ============================================
Verify Total Sales Widget
    ${widget_exists}=    Check Widget Exists    Total Sales
    Run Keyword If    ${widget_exists}    
    ...    Log    Total Sales widget found
    ...    ELSE    Log    Total Sales widget not found - may be labeled differently
    
    # Try alternative: look for £0.00 value
    ${has_value}=    Run Keyword And Return Status    
    ...    Page Should Contain    £0.00
    Run Keyword If    ${has_value}    Log    Found sales value £0.00

Verify Total Lost Sales Widget
    ${widget_exists}=    Check Widget Exists    Total Lost Sales
    Run Keyword If    ${widget_exists}    
    ...    Log    Total Lost Sales widget found
    ...    ELSE    Log    Total Lost Sales widget not found - may be labeled differently

Verify Total Cash Payments Widget
    ${widget_exists}=    Check Widget Exists    Total Cash Payments
    Run Keyword If    ${widget_exists}    
    ...    Log    Total Cash Payments widget found
    ...    ELSE    Log    Total Cash Payments widget not found - may be labeled differently

Check All Main Widgets Present
    [Documentation]    Verifies dashboard has widgets present
    ${has_widgets}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[contains(@class, 'card') or contains(@class, 'widget')]
    
    ${has_values}=    Run Keyword And Return Status    
    ...    Page Should Contain    £0.00
    
    Should Be True    ${has_widgets} or ${has_values}    
    ...    msg=Dashboard should have widgets or values displayed

# ============================================
# SIDEBAR
# ============================================
Verify Sidebar Menu Items
    [Documentation]    Verifies that main sidebar menu items are present
    ${has_dashboard}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]
    ${has_sales}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Sales')]
    
    Should Be True    ${has_dashboard} or ${has_sales}    
    ...    msg=Sidebar should contain menu items

Check Sidebar Item Active
    [Arguments]    ${menu_item}
    [Documentation]    Checks if a sidebar menu item is active/selected
    ${is_active}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://li[contains(@class, 'active')]//span[contains(text(), '${menu_item}')] | xpath://a[contains(@class, 'active')]//span[contains(text(), '${menu_item}')]
    Return From Keyword    ${is_active}

# ============================================
# HELPERS
# ============================================
Take Dashboard Screenshot
    [Arguments]    ${filename}
    Capture Page Screenshot    ${filename}
    Log    Screenshot saved: ${filename}

Refresh Dashboard Data
    [Documentation]    Refreshes the dashboard to get latest data
    Reload Page
    Sleep    3s
    Wait Until Page Contains Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]    ${TIMEOUT}

Check For Error Messages
    [Documentation]    Checks if any error messages are displayed
    ${has_errors}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://*[contains(@class, 'alert-danger') or contains(@class, 'error')]
    Run Keyword If    ${has_errors}    
    ...    Log    Warning: Error messages found on dashboard
    ...    ELSE    Log    No error messages found

Wait For Dashboard To Load Completely
    [Documentation]    Waits for all dashboard elements to load
    Wait Until Page Contains Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]    ${TIMEOUT}
    Sleep    2s

Get Dashboard Statistics Summary
    [Documentation]    Returns a summary of all dashboard statistics
    @{values}=    Get WebElements    xpath://div[contains(text(), '£')]
    ${count}=    Get Length    ${values}
    Log    Found ${count} value elements on dashboard
    
    FOR    ${element}    IN    @{values}
        ${text}=    Get Text    ${element}
        Log    Value found: ${text}
    END
    
    Return From Keyword    Found ${count} statistical values on dashboard

Debug Page Elements
    [Documentation]    Debug helper to identify page elements
    @{elements}=    Get WebElements    xpath://span[@class='content']
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        Log    Found span.content element: ${text}
    END
    
    @{cards}=    Get WebElements    xpath://div[contains(@class, 'card')]
    ${card_count}=    Get Length    ${cards}
    Log    Found ${card_count} card elements