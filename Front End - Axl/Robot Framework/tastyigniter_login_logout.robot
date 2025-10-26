*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser To Login Page
Suite Teardown    Close Browser
Test Teardown    Capture Page Screenshot

*** Variables ***
${BROWSER}         chrome
${BASE_URL}        http://localhost/TastyIgniter_v3/login

${VALID_EMAIL}     jasmine_welch@gmail.com
${VALID_PASS}      Eyeksel@060499
${WRONG_EMAIL}     wronguser@example.com
${CASE_EMAIL}      caseuser@example.com

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

Login With Credentials
    [Arguments]    ${email}    ${password}
    Input Text    id=login-email    ${email}
    Input Text    id=login-password    ${password}
    Click Button    css=button[type="submit"]

Logout User
    Click Element    css=a.nav-link.dropdown-toggle
    Wait Until Element Is Visible    css=a.dropdown-item.py-2.rounded[data-request="session::onLogout"]    5s
    Click Element    css=a.dropdown-item.py-2.rounded[data-request="session::onLogout"]
    Wait Until Page Contains    You have been logged out successfully.    10s

*** Test Cases ***
Invalid Login Wrong Password
    Login With Credentials    ${WRONG_EMAIL}    WrongPass123
    Wait Until Page Contains    Username and password not found!    10s

Empty Fields Should Show Browser Error
    Click Button    css=button[type="submit"]
    Element Attribute Value Should Be    id=login-email    required    true
    Element Attribute Value Should Be    id=login-password    required    true

Password Case Sensitivity
    Login With Credentials    ${CASE_EMAIL}    validpass123
    Wait Until Page Contains    Username and password not found!    10s

Valid Login Should Succeed
    Login With Credentials    ${VALID_EMAIL}    ${VALID_PASS}
    Wait Until Page Contains    Find a restaurant near you    10s
    Location Should Be    http://localhost/TastyIgniter_v3/
    
Logout After Successful Login
    Logout User