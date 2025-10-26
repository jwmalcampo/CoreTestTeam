*** Settings ***
Library    SeleniumLibrary
Library    String
Suite Setup      Open Browser To Register Page
Suite Teardown   Close Browser
Test Teardown    Capture Page Screenshot

*** Variables ***
${BASE}                 http://localhost/TastyIgniter_v3
${REGISTER_URL}         ${BASE}/register
${HOME_URL}             ${BASE}/
${BROWSER}              chrome

${FIRSTNAME}            John
${LASTNAME}             Doe
${PASSWORD}             P@ssw0rd123
${TELEPHONE}            +61400123456


${LOC_FIRST}            id=first-name
${LOC_LAST}             id=last-name
${LOC_EMAIL}            id=email
${LOC_PASS}             id=password
${LOC_CONFIRM}          id=password-confirm
${LOC_TEL}              id=telephone
${LOC_AGREE}            id=agree-terms
${LOC_BTN_REGISTER}     css=button.btn.btn-primary.btn-block.btn-lg
${LOC_MYACC_DROPDOWN}   css=a.nav-link.dropdown-toggle

${TXT_SUCCESS}          Account created successfully
${TXT_MYACC}            My Account

*** Keywords ***
Open Browser To Register Page
    Open Browser    ${REGISTER_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    ${LOC_FIRST}    10s

Capture On Fail
    Run Keyword If    '${TEST STATUS}'=='FAIL'    Capture Page Screenshot

Generate Unique Email
    ${rand}=    Generate Random String    6
    ${email}=   Set Variable    user${rand}@example.com
    RETURN      ${email}

Fill Registration Form
    [Arguments]    ${firstname}    ${lastname}    ${email}    ${password}    ${telephone}
    Wait Until Page Contains Element    ${LOC_FIRST}    10s
    Clear Element Text    ${LOC_FIRST}
    Clear Element Text    ${LOC_LAST}
    Clear Element Text    ${LOC_EMAIL}
    Clear Element Text    ${LOC_PASS}
    Clear Element Text    ${LOC_CONFIRM}
    Clear Element Text    ${LOC_TEL}
    Input Text    ${LOC_FIRST}       ${firstname}
    Input Text    ${LOC_LAST}        ${lastname}
    Input Text    ${LOC_EMAIL}       ${email}
    Input Text    ${LOC_PASS}        ${password}
    Input Text    ${LOC_CONFIRM}     ${password}
    Input Text    ${LOC_TEL}         ${telephone}
    Run Keyword And Ignore Error    Unselect Checkbox    ${LOC_AGREE}
    Select Checkbox    ${LOC_AGREE}
    Click Button    ${LOC_BTN_REGISTER}

Verify Registration Succeeded (Robust)
    Wait Until Keyword Succeeds    30x    500ms    _registration_success_probe

_registration_success_probe
    ${loc}=      Get Location
    ${src}=      Get Source
    ${on_home}=  Evaluate    "${loc}".rstrip("/") == "${HOME_URL}".rstrip("/")
    ${on_acct}=  Evaluate    "account" in "${loc}"
    ${has_dd}=   Run Keyword And Return Status    Page Should Contain Element    ${LOC_MYACC_DROPDOWN}
    ${has_txt}=  Run Keyword And Return Status    Should Contain    ${src}    ${TXT_SUCCESS}
    ${has_my}=   Run Keyword And Return Status    Should Contain    ${src}    ${TXT_MYACC}
    Run Keyword If    ${on_home} or ${on_acct} or ${has_dd} or ${has_txt} or ${has_my}    Return From Keyword
    Fail    Registration not confirmed yet.

*** Test Cases ***
Register New User Successfully
    ${email}=    Generate Unique Email
    Fill Registration Form    ${FIRSTNAME}    ${LASTNAME}    ${email}    ${PASSWORD}    ${TELEPHONE}
    Verify Registration Succeeded (Robust)
