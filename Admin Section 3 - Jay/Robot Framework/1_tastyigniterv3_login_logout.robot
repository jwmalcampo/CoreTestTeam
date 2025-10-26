*** Settings ***
Documentation  Login Functionality
Library  SeleniumLibrary
Suite Setup  Go to Website
Suite Teardown  Close Browser
Task Setup  Set Selenium Speed    0.5

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

Logout
    Wait Until Element Is Visible    css=a.nav-link img.rounded-circle    20s
    Click Element                    css=a.nav-link img.rounded-circle
    Wait Until Element Is Visible    xpath=//a[contains(@href,'logout')]    15s
    Click Element                    xpath=//a[contains(@href,'logout')]