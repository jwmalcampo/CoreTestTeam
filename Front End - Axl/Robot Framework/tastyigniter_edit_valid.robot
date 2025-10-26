*** Settings ***
Library          SeleniumLibrary
Suite Setup      Open Browser And Login
Suite Teardown   Close Browser
Test Teardown    Capture Page Screenshot

*** Variables ***
${BASE}              http://localhost/TastyIgniter_v3
${LOGIN_URL}         ${BASE}/login
${ACCOUNT_CANDIDATES}    @{EMPTY}    ${BASE}/account    ${BASE}/account/account    ${BASE}/account/profile
${BROWSER}           chrome

${EMAIL}             jasmine_welch@gmail.com
${PWD}               Eyeksel@060499

${NEW_FIRST}         Axl
${NEW_LAST}          Espiritu
${NEW_PHONE}         +61466587982

${OLD_PASSWORD}      ${PWD}
${NEW_PASSWORD}      Eyeksel@0604999

${LOC_NAV_TOGGLER}        css=button.navbar-toggler
${LOC_DROPDOWN_TOGGLE}    css=a.nav-link.dropdown-toggle
${LOC_MENU_ANY_ACCOUNT}   xpath=//div[contains(@class,'dropdown-menu') and contains(@class,'show')]//a[contains(@href,'/account')]
${LOC_FIRST_BY_NAME}      name=first_name
${LOC_FIRST_BY_ID}        id=first-name
${LOC_LAST_BY_NAME}       name=last_name
${LOC_LAST_BY_ID}         id=last-name
${LOC_PHONE_BY_DATA}      css=input[data-control="country-code-picker"]
${LOC_SAVE_BTN}           css=button.btn.btn-primary[type="submit"]
${LOC_ALERT_SUCCESS}      css=.alert-success

${LOC_OLD_PWD}            name=old_password
${LOC_NEW_PWD}            name=new_password
${LOC_NEW_PWD_CONFIRM}    name=confirm_new_password


*** Keywords ***
Open Browser And Login
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    id=login-email    10s
    Input Text     id=login-email       ${EMAIL}
    Input Text     id=login-password    ${PWD}
    Click Button   css=button[type="submit"]
    Wait Until Keyword Succeeds    20x    500ms    _probe_logged_in

_probe_logged_in
    ${loc}=        Get Location
    ${on_home}=    Evaluate    "${loc}".rstrip("/") == "${BASE}/".rstrip("/")
    ${has_menu}=   Run Keyword And Return Status    Page Should Contain Element    ${LOC_DROPDOWN_TOGGLE}
    ${has_hero}=   Run Keyword And Return Status    Page Should Contain    Find a restaurant near you
    Run Keyword If    ${on_home} or ${has_menu} or ${has_hero}    Return From Keyword
    Fail    Not logged in yet.

Open My Account Page (Robust)
    Run Keyword And Ignore Error    Click Element    ${LOC_NAV_TOGGLER}
    Run Keyword And Ignore Error    Click Element    ${LOC_DROPDOWN_TOGGLE}
    ${menu_open}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_MENU_ANY_ACCOUNT}    2s
    IF    ${menu_open}
        ${clicked}=    Run Keyword And Return Status    Click Element    xpath=(//div[contains(@class,'dropdown-menu') and contains(@class,'show')]//a[contains(@href,'/account') and not(contains(@href,'/address')) and not(contains(@href,'/orders'))])[1]
        IF    not ${clicked}
            Execute Javascript    (function(){var el=document.querySelector(".dropdown-menu.show a[href*='/account']:not([href*='/address']):not([href*='/orders'])"); if(el){el.click();}})();
        END
        ${on_acc}=    Run Keyword And Return Status    Wait Until Location Contains    /account    3s
        Run Keyword If    ${on_acc}    Return From Keyword
    END

    FOR    ${url}    IN    @{ACCOUNT_CANDIDATES}
        Go To    ${url}
        ${on_acc}=    Run Keyword And Return Status    Wait Until Location Contains    /account    4s
        Run Keyword If    ${on_acc}    Return From Keyword
    END

    Fail    Could not navigate to My Account page.

Wait For Account Form
    Wait Until Keyword Succeeds    20x    500ms    _form_probe

_form_probe
    ${by_name}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_FIRST_BY_NAME}
    ${by_id}=      Run Keyword And Return Status    Page Should Contain Element    ${LOC_FIRST_BY_ID}
    Run Keyword If    ${by_name} or ${by_id}    Return From Keyword
    Fail    Account form not visible yet.

Clear And Type
    [Arguments]    ${locator}    ${value}
    Run Keyword And Ignore Error    Clear Element Text    ${locator}
    Input Text    ${locator}    ${value}

Clear And Type Password
    [Arguments]    ${locator}    ${value}
    Run Keyword And Ignore Error    Clear Element Text    ${locator}
    Input Password    ${locator}    ${value}

Update Password (Optional)
    [Arguments]    ${old_pwd}    ${new_pwd}
    Run Keyword If    '${new_pwd}' == ''    Return From Keyword
    ${has_old}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_OLD_PWD}
    ${has_new}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_NEW_PWD}
    ${has_cfm}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_NEW_PWD_CONFIRM}
    Run Keyword Unless    ${has_old} and ${has_new} and ${has_cfm}    Return From Keyword
    Wait Until Element Is Visible    ${LOC_OLD_PWD}          5s
    Wait Until Element Is Visible    ${LOC_NEW_PWD}          5s
    Wait Until Element Is Visible    ${LOC_NEW_PWD_CONFIRM}  5s
    Clear And Type Password          ${LOC_OLD_PWD}          ${old_pwd}
    Clear And Type Password          ${LOC_NEW_PWD}          ${new_pwd}
    Clear And Type Password          ${LOC_NEW_PWD_CONFIRM}  ${new_pwd}

Update Your Details (No Password Change)
    Open My Account Page (Robust)
    Wait For Account Form

    ${ok1}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_FIRST_BY_NAME}    2s
    Run Keyword If        ${ok1}    Clear And Type    ${LOC_FIRST_BY_NAME}    ${NEW_FIRST}
    Run Keyword Unless    ${ok1}    Clear And Type    ${LOC_FIRST_BY_ID}     ${NEW_FIRST}

    ${ok2}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${LOC_LAST_BY_NAME}    2s
    Run Keyword If        ${ok2}    Clear And Type    ${LOC_LAST_BY_NAME}    ${NEW_LAST}
    Run Keyword Unless    ${ok2}    Clear And Type    ${LOC_LAST_BY_ID}     ${NEW_LAST}

    Wait Until Element Is Visible    ${LOC_PHONE_BY_DATA}    10s
    Click Element                    ${LOC_PHONE_BY_DATA}
    Press Keys                       ${LOC_PHONE_BY_DATA}    CTRL+A
    Input Text                       ${LOC_PHONE_BY_DATA}    ${NEW_PHONE}

    Update Password (Optional)       ${OLD_PASSWORD}    ${NEW_PASSWORD}

    Click Button    ${LOC_SAVE_BTN}
    Assert Details Updated

Assert Details Updated
    Wait Until Element Contains    css=.alert-success    Details updated successfully    10s
    Element Should Contain         css=.alert-success    Details updated successfully


*** Test Cases ***
Update My Account Details (Happy Path)
    Update Your Details (No Password Change)
