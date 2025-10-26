*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${BROWSER}             chrome
${BASE_URL}            http://localhost/tastyigniter
${ADMIN_URL}           ${BASE_URL}/admin
${ADMIN_USERNAME}      admin
${ADMIN_PASS}          123456
${TIMEOUT}             40s

# Sales Module URLs
${ORDERS_URL}          ${ADMIN_URL}/orders
${RESERVATIONS_URL}    ${ADMIN_URL}/reservations
${REVIEWS_URL}         ${ADMIN_URL}/igniter/local/reviews
${STATUSES_URL}        ${ADMIN_URL}/statuses
${PAYMENTS_URL}        ${ADMIN_URL}/payments

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
    Wait Until Page Contains Element    xpath://a[contains(@href, 'dashboard') or contains(@href, 'orders')]    ${TIMEOUT}

Logout And Close
    Run Keyword And Ignore Error    Click Element    xpath://a[contains(@href, 'logout')]
    Sleep    1s
    Close All Browsers

# ============================================
# SHARED HELPERS
# ============================================
Verify Success Message
    # Try multiple success message patterns
    ${has_success}=    Run Keyword And Return Status    Wait Until Page Contains Element    xpath://*[contains(@class,'alert-success')]    timeout=5s
    Run Keyword Unless    ${has_success}    Wait Until Page Contains Element    xpath://*[contains(text(),'success') or contains(text(),'Success')]    timeout=5s

# ============================================
# ORDERS
# ============================================
Go To Orders
    Go To    ${ORDERS_URL}
    Wait Until Page Contains    Orders    ${TIMEOUT}
    Sleep    2s

Check If Orders Exist
    [Documentation]    Returns True if orders exist, False otherwise
    ${has_orders}=    Run Keyword And Return Status    Page Should Contain Element    xpath://table//tbody//tr[not(contains(., 'no orders'))]
    Return From Keyword    ${has_orders}

Open Orders Filter
    ${has_filter}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-toggle='list-filter']    timeout=5s
    Run Keyword If    ${has_filter}    Click Element    xpath://button[@data-toggle='list-filter']
    ...    ELSE    Click Element    xpath://button[contains(., 'Filter')]
    Sleep    2s

Filter Orders By Status
    [Arguments]    ${status}
    Open Orders Filter
    ${has_status}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://select[contains(@name, 'status')]    timeout=10s
    Run Keyword If    ${has_status}    Select From List By Label    xpath://select[contains(@name, 'status')]    ${status}
    ...    ELSE    Log    Status filter not found
    Sleep    2s

Search Orders
    [Arguments]    ${search_term}
    Open Orders Filter
    ${has_search}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[@name='filter_search']    timeout=5s
    Run Keyword If    ${has_search}    Input Text    xpath://input[@name='filter_search']    ${search_term}
    ...    ELSE    Input Text    xpath://input[contains(@name, 'search')]    ${search_term}
    ${has_search}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[@name='filter_search']    timeout=5s
    Run Keyword If    ${has_search}    Press Keys    xpath://input[@name='filter_search']    RETURN
    ...    ELSE    Press Keys    xpath://input[contains(@name, 'search')]    RETURN
    Sleep    3s

View First Order Details
    Wait Until Element Is Visible    xpath:(//table//tbody//tr//a[contains(@href, 'orders/')])[1]    ${TIMEOUT}
    Click Element    xpath:(//table//tbody//tr//a[contains(@href, 'orders/')])[1]
    Sleep    3s
    Page Should Contain Element    xpath://*[contains(text(), 'Order Details') or contains(text(), 'Order #')]

# ============================================
# RESERVATIONS
# ============================================
Go To Reservations
    Go To    ${RESERVATIONS_URL}
    Wait Until Page Contains    Reservations    ${TIMEOUT}
    Sleep    2s

Check If Reservations Exist
    [Documentation]    Returns True if reservations exist, False otherwise
    ${has_reservations}=    Run Keyword And Return Status    Page Should Contain Element    xpath://table//tbody//tr[not(contains(., 'no reservation'))]
    Return From Keyword    ${has_reservations}

Edit First Reservation Guest Count
    [Arguments]    ${new_count}
    Sleep    2s
    Wait Until Element Is Visible    xpath:(//table//tbody//tr//a[contains(@class, 'btn-edit')])[1]    ${TIMEOUT}
    Click Element    xpath:(//table//tbody//tr//a[contains(@class, 'btn-edit')])[1]
    Sleep    3s
    ${has_input}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[contains(@name, 'guest_num')]    timeout=10s
    Run Keyword If    ${has_input}    Run Keywords
    ...    Clear Element Text    xpath://input[contains(@name, 'guest_num')]
    ...    AND    Input Text    xpath://input[contains(@name, 'guest_num')]    ${new_count}
    ...    ELSE    Select From List By Value    xpath://select[contains(@name, 'guest_num')]    ${new_count}
    ${has_save}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=5s
    Run Keyword If    ${has_save}    Run Keywords
    ...    Scroll Element Into View    xpath://button[@data-request='onSave']
    ...    AND    Click Button    xpath://button[@data-request='onSave']
    ...    ELSE    Run Keywords
    ...    Scroll Element Into View    xpath://button[contains(., 'Save')]
    ...    AND    Click Button    xpath://button[contains(., 'Save')]
    Sleep    4s
    Verify Success Message

Filter Reservations By Date
    ${has_filter}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-toggle='list-filter']    timeout=5s
    Run Keyword If    ${has_filter}    Click Element    xpath://button[@data-toggle='list-filter']
    ...    ELSE    Click Element    xpath://button[contains(., 'Filter')]
    Sleep    2s
    ${has_date_filter}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[contains(@name, 'date')]    timeout=5s
    Run Keyword If    ${has_date_filter}    Log    Date filter available
    ...    ELSE    Log    Date filter not found

Change First Reservation Status
    [Arguments]    ${new_status}
    Sleep    2s
    Wait Until Element Is Visible    xpath:(//table//tbody//tr//a[contains(@class, 'btn-edit')])[1]    ${TIMEOUT}
    Click Element    xpath:(//table//tbody//tr//a[contains(@class, 'btn-edit')])[1]
    Sleep    3s
    ${has_status}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://select[contains(@name, 'status')]    timeout=10s
    Run Keyword If    ${has_status}    Select From List By Label    xpath://select[contains(@name, 'status')]    ${new_status}
    ...    ELSE    Log    Status field not found or uses custom control
    ${has_save}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=5s
    Run Keyword If    ${has_save}    Run Keywords
    ...    Scroll Element Into View    xpath://button[@data-request='onSave']
    ...    AND    Click Button    xpath://button[@data-request='onSave']
    ...    ELSE    Run Keywords
    ...    Scroll Element Into View    xpath://button[contains(., 'Save')]
    ...    AND    Click Button    xpath://button[contains(., 'Save')]
    Sleep    4s

# ============================================
# REVIEWS
# ============================================
Go To Reviews
    Go To    ${REVIEWS_URL}
    Wait Until Page Contains    Reviews    ${TIMEOUT}
    Sleep    2s

Check If Reviews Exist
    [Documentation]    Returns True if reviews exist, False otherwise
    ${has_reviews}=    Run Keyword And Return Status    Page Should Contain Element    xpath://table//tbody//tr[not(contains(., 'no review'))]
    Return From Keyword    ${has_reviews}

Filter Reviews By Status
    [Arguments]    ${status}
    ${has_filter}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-toggle='list-filter']    timeout=5s
    Run Keyword If    ${has_filter}    Click Element    xpath://button[@data-toggle='list-filter']
    ...    ELSE    Click Element    xpath://button[contains(., 'Filter')]
    Sleep    2s
    ${has_status}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://select[contains(@name, 'status')]    timeout=5s
    Run Keyword If    ${has_status}    Select From List By Label    xpath://select[contains(@name, 'status')]    ${status}
    ...    ELSE    Select From List By Label    xpath://select[contains(@name, 'approved')]    ${status}
    Sleep    2s

View First Review Details
    Wait Until Element Is Visible    xpath:(//table//tbody//tr//a[contains(@href, 'reviews/')])[1]    ${TIMEOUT}
    Click Element    xpath:(//table//tbody//tr//a[contains(@href, 'reviews/')])[1]
    Sleep    3s
    Page Should Contain Element    xpath://*[contains(text(), 'Review') or contains(text(), 'Rating')]

Search Reviews
    [Arguments]    ${search_term}
    ${has_filter}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[@data-toggle='list-filter']    timeout=5s
    Run Keyword If    ${has_filter}    Click Element    xpath://button[@data-toggle='list-filter']
    ...    ELSE    Click Element    xpath://button[contains(., 'Filter')]
    Sleep    2s
    ${has_search}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[@name='filter_search']    timeout=5s
    Run Keyword If    ${has_search}    Input Text    xpath://input[@name='filter_search']    ${search_term}
    ...    ELSE    Input Text    xpath://input[contains(@name, 'search')]    ${search_term}
    ${has_search}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://input[@name='filter_search']    timeout=5s
    Run Keyword If    ${has_search}    Press Keys    xpath://input[@name='filter_search']    RETURN
    ...    ELSE    Press Keys    xpath://input[contains(@name, 'search')]    RETURN
    Sleep    3s

# ============================================
# STATUSES
# ============================================
Go To Statuses
    Go To    ${STATUSES_URL}
    Wait Until Page Contains    Statuses    ${TIMEOUT}
    Sleep    2s

# ============================================
# PAYMENTS
# ============================================
Go To Payments
    Go To    ${PAYMENTS_URL}
    Wait Until Page Contains    Payments    ${TIMEOUT}
    Sleep    2s
