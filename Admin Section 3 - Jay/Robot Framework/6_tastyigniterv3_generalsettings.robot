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

Navigate and Update Details
    Wait Until Element Is Visible    xpath=//span[normalize-space()='System']    15s
    Click Element    xpath=//span[normalize-space()='System']
    Wait Until Element Is Visible    css=a.nav-link.settings    10s
    Click Element    css=a.nav-link.settings
    Click Element    xpath=//a[.//h5[normalize-space()='General']] 
    Wait Until Element Is Visible    id=form-field-setting-site-name    10s
    Click Element                    id=form-field-setting-site-name
    Clear Element Text               id=form-field-setting-site-name
    Input Text                       id=form-field-setting-site-name    McDonald's
    Click Element                    id=form-field-setting-site-email
    Clear Element Text               id=form-field-setting-site-email
    Input Text                       id=form-field-setting-site-email    mcdonalds@mcdo.com
    Click Element    xpath=//a[@data-request='onSave']
    Wait Until Page Contains         updated    10s
    Sleep                            1.0s
    Pass Execution                   Restaurant name and email updated successfully.

Revert Details
    Wait Until Element Is Visible    id=form-field-setting-site-name    10s
    Click Element                    id=form-field-setting-site-name
    Clear Element Text               id=form-field-setting-site-name
    Input Text                       id=form-field-setting-site-name    TastyIgniter
    Click Element                    id=form-field-setting-site-email
    Clear Element Text               id=form-field-setting-site-email
    Input Text                       id=form-field-setting-site-email    admin@domain.tld
    Click Element    xpath=//a[@data-request='onSave']
    Wait Until Page Contains         updated    10s
    Sleep                            1.0s
    Pass Execution                   Restaurant name and email updated successfully.