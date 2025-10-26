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

Disable Country
    Wait Until Element Is Visible    xpath=//span[normalize-space()='Localisation']    15s
    Click Element    xpath=//span[normalize-space()='Localisation']
    Wait Until Element Is Visible    css=a.nav-link.countries    10s
    Click Element    css=a.nav-link.countries
    Wait Until Element Is Visible    css=input#checkbox-1.form-check-input    10s
    Click Element                    css=input#checkbox-1.form-check-input
    Wait Until Element Is Visible    xpath=//button[contains(.,'Enable/Disable')]    5s
    Click Element                    xpath=//button[contains(.,'Enable/Disable')]
    Click Button    xpath=//button[normalize-space()='Disable']
    Wait Until Page Contains         disabled    10s
    Pass Execution                   Country successfully disabled.

Enable Country
    Wait Until Element Is Visible    css=input#checkbox-1.form-check-input    10s
    Click Element                    css=input#checkbox-1.form-check-input
    Wait Until Element Is Visible    xpath=//button[contains(.,'Enable/Disable')]    5s
    Click Element                    xpath=//button[contains(.,'Enable/Disable')]
    Click Button    xpath=//button[normalize-space()='Enable']
    Wait Until Page Contains         enabled    10s
    Pass Execution                   Country successfully enabled.