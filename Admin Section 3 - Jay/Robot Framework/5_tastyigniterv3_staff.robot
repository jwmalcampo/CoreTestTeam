*** Settings ***
Documentation  Login Functionality
Library  SeleniumLibrary
Suite Setup  Go to Website
Suite Teardown  Close Browser
Task Setup  Set Selenium Speed    0.2

*** Variables ***
${URL}  http://localhost/TastyIgniter_v3/admin/login
${Browser}  firefox

*** Keywords ***
Go to Website
    [Documentation]  This test case verify user is able to open the URL
    Open Browser  ${URL}  ${Browser}
    Page Should Contain    Login

*** Test Cases ***
Login to your account
    Input Text    username    eyeksel
    Input Text    password    Eyeksel@060499
    Click Button    css=button.btn.btn-primary.btn-block

Navigate and Create Staff
    Wait Until Element Is Visible    xpath=//span[normalize-space()='System']    15s
    Click Element    xpath=//span[normalize-space()='System']
    Wait Until Element Is Visible    css=a.nav-link.staffs   10s
    Click Element    css=a.nav-link.staffs
    Wait Until Element Is Visible    css=a.btn.btn-primary    10s
    Click Element                    css=a.btn.btn-primary
    Wait Until Element Is Visible    id=form-field-staff-staff-name    10s
    Click Element                    id=form-field-staff-staff-name
    Clear Element Text               id=form-field-staff-staff-name
    Input Text                       id=form-field-staff-staff-name    Homer Simpson
    Click Element                    id=form-field-staff-staff-email
    Clear Element Text               id=form-field-staff-staff-email
    Input Text                       id=form-field-staff-staff-email    hsimpson@gmail.com
    Click Element                    id=form-field-staff-user-username
    Clear Element Text               id=form-field-staff-user-username
    Input Text                       id=form-field-staff-user-username    hsimpson
    Click Element                    id=form-field-staff-user-send-invite
    Click Element                    id=form-field-staff-user-password
    Clear Element Text               id=form-field-staff-user-password
    Input Text                       id=form-field-staff-user-password    Hsimpson20
    Click Element                    id=form-field-staff-user-password-confirm
    Clear Element Text               id=form-field-staff-user-password-confirm
    Input Text                       id=form-field-staff-user-password-confirm   Hsimpson20
    Click Element                    xpath=//div[@id='form-field-staff-groups-group']//div[@role='combobox']
    Wait Until Element Is Visible    xpath=//div[contains(@class,'ss-option') and normalize-space()='Waiters']    10s
    Click Element                    xpath=//div[contains(@class,'ss-option') and normalize-space()='Waiters']
    Click Element                    id=radio_form-field-staff-staff-role-id_3
    Click Button    css=button.btn.btn-primary
    Wait Until Page Contains         created    10s
    Sleep                            1.0s
    Pass Execution                   Staff account created successfully.

Delete Staff
    Click Element                    css=a.btn.btn-outline-secondary
    Wait Until Element Is Visible    xpath=//table//tr[.//td[normalize-space()='Homer Simpson']]//input[@type='checkbox']    10s
    Click Element    xpath=//table//tr[.//td[normalize-space()='Homer Simpson']]//input[@type='checkbox']
    Click Button                    css=button.btn.text-danger
    Handle Alert                    accept
    Wait Until Page Contains         deleted   10s
    Sleep                            1.0s
    Pass Execution                   Staff account deleted successfully.