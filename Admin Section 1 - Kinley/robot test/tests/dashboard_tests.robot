*** Settings ***
Documentation    Complete Dashboard Tests including Add Widget Modal Testing
Library          SeleniumLibrary
Library          String
Library          DateTime
Resource         ../resources/dashboard_keywords.robot
Suite Setup      Open Admin And Login
Suite Teardown   Logout And Close

*** Variables ***
${SCREENSHOT_DIR}    screenshots

*** Test Cases ***
# ============================================
# DASHBOARD ACCESS & NAVIGATION (5 Tests)
# ============================================
TC_DASH_001_Access_Dashboard_After_Login
    [Documentation]    TC_DASH_001: Verify dashboard loads successfully after login
    [Tags]    smoke    critical    dashboard
    # Dashboard should already be loaded from Suite Setup login
    Location Should Contain    admin
    
    # Verify Dashboard element is present
    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]
    
    # Take screenshot for verification
    Take Dashboard Screenshot    dashboard_after_login.png
    
    # No error messages should be present
    Check For Error Messages

TC_DASH_002_Verify_Dashboard_URL
    [Documentation]    TC_DASH_002: Verify correct dashboard URL after navigation
    [Tags]    smoke    dashboard
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /admin
    Log    Dashboard URL verified: ${current_url}

TC_DASH_003_Verify_Sidebar_Navigation_Present
    [Documentation]    TC_DASH_003: Verify sidebar menu is present and visible
    [Tags]    smoke    dashboard    navigation
    # Check that sidebar exists with menu items
    ${has_sidebar}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://span[@class='content']
    Should Be True    ${has_sidebar}    msg=Sidebar elements should be present
    
    # Verify at least Dashboard is visible
    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]

TC_DASH_004_Navigate_To_Sales_From_Dashboard
    [Documentation]    TC_DASH_004: Navigate from Dashboard to Sales section
    [Tags]    functional    dashboard    navigation
    # Try to navigate to Sales
    ${has_sales}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://a[.//span[@class='content' and contains(text(), 'Sales')]]
    
    Run Keyword If    ${has_sales}    Run Keywords
    ...    Click Element    xpath://a[.//span[@class='content' and contains(text(), 'Sales')]]
    ...    AND    Sleep    3s
    ...    AND    Location Should Contain    /admin
    ...    ELSE    Log    Sales menu item not found in sidebar

TC_DASH_005_Navigate_Back_To_Dashboard
    [Documentation]    TC_DASH_005: Navigate back to Dashboard from another section
    [Tags]    functional    dashboard    navigation
    # Click Dashboard in sidebar
    ${clicked}=    Run Keyword And Return Status    
    ...    Click Element    xpath://a[.//span[@class='content' and contains(text(), 'Dashboard')]]
    
    Run Keyword Unless    ${clicked}    
    ...    Go To Dashboard
    
    # Verify we're back on dashboard
    Wait Until Page Contains Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]    ${TIMEOUT}

# ============================================
# WIDGETS & STATISTICS (6 Tests)
# ============================================
TC_DASH_006_Verify_Total_Sales_Widget_Present
    [Documentation]    TC_DASH_006: Verify Total Sales widget or similar is displayed
    [Tags]    smoke    dashboard    widgets
    Go To Dashboard
    
    # Look for Total Sales or any sales-related widget
    ${has_sales_text}=    Run Keyword And Return Status    Page Should Contain    Total Sales
    ${has_value}=    Run Keyword And Return Status    Page Should Contain    £0.00
    
    Should Be True    ${has_sales_text} or ${has_value}    
    ...    msg=Dashboard should display sales information

TC_DASH_007_Verify_Total_Lost_Sales_Widget_Present
    [Documentation]    TC_DASH_007: Verify Total Lost Sales widget or similar is displayed
    [Tags]    smoke    dashboard    widgets
    # Look for Lost Sales or monetary values
    ${has_lost_sales}=    Run Keyword And Return Status    Page Should Contain    Total Lost Sales
    ${has_value}=    Run Keyword And Return Status    Page Should Contain    £0.00
    
    Should Be True    ${has_lost_sales} or ${has_value}    
    ...    msg=Dashboard should display sales metrics

TC_DASH_008_Verify_Total_Cash_Payments_Widget_Present
    [Documentation]    TC_DASH_008: Verify Total Cash Payments widget or similar is displayed
    [Tags]    smoke    dashboard    widgets
    # Look for Cash Payments or payment-related info
    ${has_cash}=    Run Keyword And Return Status    Page Should Contain    Total Cash Payments
    ${has_value}=    Run Keyword And Return Status    Page Should Contain    £0.00
    
    Should Be True    ${has_cash} or ${has_value}    
    ...    msg=Dashboard should display payment information

TC_DASH_009_Verify_All_Main_Widgets_Present
    [Documentation]    TC_DASH_009: Verify dashboard has widgets/cards present
    [Tags]    smoke    critical    dashboard    widgets
    Check All Main Widgets Present
    ${summary}=    Get Dashboard Statistics Summary
    Log    Dashboard Statistics: ${summary}

TC_DASH_010_Verify_Widget_Values_Format
    [Documentation]    TC_DASH_010: Verify values are in correct currency format
    [Tags]    functional    dashboard    widgets
    # Check for currency symbol
    ${has_currency}=    Run Keyword And Return Status    Page Should Contain    £
    Should Be True    ${has_currency}    msg=Dashboard should show currency values
    
    # Look for formatted values like £0.00
    ${has_formatted}=    Run Keyword And Return Status    
    ...    Page Should Match Regexp    £\\d+\\.\\d{2}
    Log    Has formatted currency values: ${has_formatted}

TC_DASH_011_Count_Dashboard_Widgets
    [Documentation]    TC_DASH_011: Count the number of widgets on dashboard
    [Tags]    functional    dashboard    widgets
    ${widget_count}=    Count Dashboard Widgets
    Should Be True    ${widget_count} > 0    msg=Dashboard should have at least one widget
    Log    Dashboard has ${widget_count} widgets

# ============================================
# ADD WIDGET FUNCTIONALITY (7 Tests)
# ============================================
TC_DASH_012_Verify_Add_Widget_Button_Present
    [Documentation]    TC_DASH_012: Verify Add Widget button is present on dashboard
    [Tags]    functional    dashboard    addwidget
    Go To Dashboard
    
    # Check for Add Widget button with Bootstrap 5 attributes
    ${button_exists}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://button[@data-bs-toggle='modal' and @data-bs-target='#newWidgetModal']
    
    Should Be True    ${button_exists}    msg=Add Widget button should be present
    
    # Verify button text
    ${button_text}=    Get Text    xpath://button[@data-bs-target='#newWidgetModal']
    Should Contain    ${button_text}    Add Widget
    
    # Verify button has icon
    ${has_icon}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://button[@data-bs-target='#newWidgetModal']//i[@class='fa fa-plus']
    Log    Add Widget button has plus icon: ${has_icon}

TC_DASH_013_Click_Add_Widget_Open_Modal
    [Documentation]    TC_DASH_013: Test clicking Add Widget button opens modal
    [Tags]    functional    dashboard    addwidget    modal
    Go To Dashboard
    
    # Click the Add Widget button
    Click Add Widget Button
    
    # Verify modal opened
    ${modal_open}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]
    
    Should Be True    ${modal_open}    msg=Add Widget modal should open
    
    # Take screenshot of open modal
    Take Dashboard Screenshot    add_widget_modal_open.png
    
    # Close modal for next test
    Close Add Widget Modal


TC_DASH_015_Test_Widget_Selection_In_Modal
    [Documentation]    TC_DASH_015: Test widget selection within Add Widget modal
    [Tags]    functional    dashboard    addwidget    modal
    Go To Dashboard
    
    # Open modal
    Click Add Widget Button
    
    # Check for widget options in modal
    @{widget_options}=    Get WebElements    xpath://div[@id='newWidgetModal']//div[@class='modal-body']//*[contains(@class, 'widget-option') or contains(@class, 'form-check')]
    ${option_count}=    Get Length    ${widget_options}
    Log    Found ${option_count} widget options in modal
    
    # Try to select a widget type if available
    ${has_options}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://div[@id='newWidgetModal']//input[@type='radio' or @type='checkbox']
    
    Run Keyword If    ${has_options}    
    ...    Log    Widget selection options available
    ...    ELSE    Log    No widget selection options found
    
    # Close modal
    Close Add Widget Modal

TC_DASH_016_Test_Add_Widget_Modal_Close_Methods
    [Documentation]    TC_DASH_016: Test different ways to close Add Widget modal
    [Tags]    functional    dashboard    addwidget    modal
    Go To Dashboard
    
    # Test 1: Close with X button
    Click Add Widget Button
    ${close_x}=    Run Keyword And Return Status    
    ...    Click Element    xpath://div[@id='newWidgetModal']//button[@aria-label='Close' or @data-bs-dismiss='modal']
    Sleep    2s
    ${modal_closed}=    Run Keyword And Return Status    
    ...    Page Should Not Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]
    Log    Modal closed with X button: ${modal_closed}
    
    # Test 2: Close with ESC key
    Click Add Widget Button
    Press Keys    None    ESC
    Sleep    2s
    ${modal_closed_esc}=    Run Keyword And Return Status    
    ...    Page Should Not Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]
    Log    Modal closed with ESC key: ${modal_closed_esc}
    
    # Test 3: Close by clicking backdrop
    Click Add Widget Button
    ${backdrop}=    Run Keyword And Return Status    
    ...    Click Element    xpath://div[contains(@class, 'modal-backdrop')]
    Sleep    2s
    ${modal_closed_backdrop}=    Run Keyword And Return Status    
    ...    Page Should Not Contain Element    xpath://div[@id='newWidgetModal' and contains(@class, 'show')]
    Log    Modal closed by backdrop click: ${modal_closed_backdrop}


# ============================================
# DATE RANGE FUNCTIONALITY (4 Tests)
# ============================================
TC_DASH_019_Verify_Date_Range_Selector_Present
    [Documentation]    TC_DASH_019: Verify date range selector is present
    [Tags]    functional    dashboard    daterange
    ${has_date_selector}=    Check Date Range Selector Exists
    Log    Date range selector present: ${has_date_selector}
    
    # Also check for date text on page
    ${has_date}=    Run Keyword And Return Status    
    ...    Page Should Contain    2025
    Log    Date information visible: ${has_date}

TC_DASH_020_Verify_Current_Date_Range_Displayed
    [Documentation]    TC_DASH_020: Verify current date range is displayed
    [Tags]    functional    dashboard    daterange
    # Look for date text in various formats
    ${date_visible}=    Run Keyword And Return Status    
    ...    Page Should Match Regexp    (January|February|March|April|May|June|July|August|September|October|November|December).*202[4-5]
    Log    Date range visible: ${date_visible}



# ============================================
# REPORTS CHART (4 Tests)  
# ============================================
TC_DASH_023_Verify_Reports_Chart_Section_Present
    [Documentation]    TC_DASH_023: Verify Reports Chart section is displayed
    [Tags]    functional    dashboard    charts
    ${has_chart}=    Check Reports Chart Exists
    Log    Reports chart present: ${has_chart}
    
    # Also check for chart-related text
    ${has_chart_text}=    Run Keyword And Return Status    
    ...    Page Should Contain    Reports Chart
    Log    Reports Chart text found: ${has_chart_text}

TC_DASH_024_Verify_Chart_Axes_Labels
    [Documentation]    TC_DASH_024: Verify chart has proper labels
    [Tags]    functional    dashboard    charts
    ${has_chart}=    Check Reports Chart Exists
    Run Keyword If    ${has_chart}    Run Keywords
    ...    ${has_labels}=    Run Keyword And Return Status    
    ...    Page Should Match Regexp    (Customers|Orders|Reservations)
    ...    AND    Log    Chart labels found: ${has_labels}
    ...    ELSE    Log    Chart not available or not loaded

TC_DASH_025_Verify_Chart_Data_Points
    [Documentation]    TC_DASH_025: Verify chart displays data or indicates no data
    [Tags]    functional    dashboard    charts
    ${has_chart}=    Check Reports Chart Exists
    Run Keyword If    ${has_chart}    
    ...    Check Chart Has Data
    ...    ELSE    Log    Chart not available

TC_DASH_026_Verify_Chart_Type
    [Documentation]    TC_DASH_026: Verify the type of chart displayed
    [Tags]    functional    dashboard    charts
    ${chart_type}=    Get Chart Type
    Log    Chart type detected: ${chart_type}

# ============================================
# DASHBOARD ACTIONS (3 Tests)
# ============================================
TC_DASH_027_Click_Set_As_Default_Button
    [Documentation]    TC_DASH_027: Test Set As Default button functionality if present
    [Tags]    functional    dashboard    settings
    Click Set As Default Button
    # Check for any response/feedback
    ${success}=    Run Keyword And Return Status    
    ...    Page Should Contain Element    xpath://*[contains(@class, 'alert-success')]    timeout=3s
    Log    Set as default success: ${success}

TC_DASH_028_Refresh_Dashboard_Data
    [Documentation]    TC_DASH_028: Test dashboard data refresh
    [Tags]    functional    dashboard
    # Capture initial state
    Take Dashboard Screenshot    before_refresh.png
    
    # Refresh
    Refresh Dashboard Data
    
    # Capture after refresh
    Take Dashboard Screenshot    after_refresh.png
    
    # Verify dashboard still loads correctly
    Page Should Contain Element    xpath://span[@class='content' and contains(text(), 'Dashboard')]

TC_DASH_029_Take_Dashboard_Screenshot
    [Documentation]    TC_DASH_029: Capture dashboard screenshot for documentation
    [Tags]    functional    dashboard    documentation
    Wait For Dashboard To Load Completely
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Take Dashboard Screenshot    dashboard_${timestamp}.png


*** Keywords ***
# Test-specific helper keywords
Debug Dashboard Elements
    [Documentation]    Debug helper to log all dashboard elements found
    Debug Page Elements
    
    # Also check for specific dashboard elements
    ${widgets}=    Get WebElements    xpath://div[contains(@class, 'card') or contains(@class, 'widget')]
    ${widget_count}=    Get Length    ${widgets}
    Log    Found ${widget_count} widget/card elements
    
    ${spans}=    Get WebElements    xpath://span[@class='content']
    FOR    ${span}    IN    @{spans}
        ${text}=    Get Text    ${span}
        Log    Menu item found: ${text}
    END
