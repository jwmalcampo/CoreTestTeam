*** Settings ***
Library           SeleniumLibrary
Library           String
Suite Setup       Open Browser To Register
Suite Teardown    Close Browser
Test Teardown     Reset To Register Page


*** Variables ***
${BASE_URL}               http://localhost/TastyIgniter_v3
${REGISTER_URL}           ${BASE_URL}/register
${BROWSER}                firefox

${LOC_FIRST_NAME}         id=first-name
${LOC_LAST_NAME}          id=last-name
${LOC_EMAIL}              id=email
${LOC_PASSWORD}           id=password
${LOC_CONFIRM}            id=password-confirm
${LOC_TELEPHONE}          id=telephone
${LOC_AGREE}              id=agree-terms
${LOC_BTN_REGISTER}       css=button.btn.btn-primary.btn-block.btn-lg

${REQ_FIRST}              The First Name field is required.
${REQ_LAST}               The Last Name field is required.
${REQ_EMAIL}              The Email Address field is required.
${REQ_PASS}               The Password field is required.
${REQ_CONFIRM}            The Password Confirm field is required.
${REQ_TEL}                The Telephone field is required.
${REQ_AGREE}              The I Agree field is required.
${MSG_PASS_MUST_MATCH}    The Password and Password Confirm must match.

${DEF_FIRST}              Axel
${DEF_LAST}               Espiritu
${DEF_PASS}               Test1234!
${DEF_TEL}                7400123456

*** Keywords ***
Open Browser To Register
    Open Browser    ${REGISTER_URL}    ${BROWSER}
    Set Window Size    1280    900
    Wait Until Page Contains Element    ${LOC_FIRST_NAME}    10s

Reset To Register Page
    Run Keyword If    '${TEST STATUS}'=='FAIL'    Capture Page Screenshot
    Go To    ${REGISTER_URL}
    Wait Until Page Contains Element    ${LOC_FIRST_NAME}    10s

New Random Email
    ${rand}=    Generate Random String    6
    ${email}=   Set Variable    rf${rand}@example.com
    RETURN      ${email}

Fill Registration Form
    [Arguments]    ${first}    ${last}    ${email}    ${pass}    ${confirm}    ${tel}    ${agree}
    ${rand}=    Generate Random String    6
    ${final_email}=    Set Variable If    '${email}' == ''    rf${rand}@example.com    ${email}
    Input Text    ${LOC_FIRST_NAME}    ${first}
    Input Text    ${LOC_LAST_NAME}     ${last}
    Input Text    ${LOC_EMAIL}         ${final_email}
    Input Text    ${LOC_PASSWORD}      ${pass}
    Input Text    ${LOC_CONFIRM}       ${confirm}
    Input Text    ${LOC_TELEPHONE}     ${tel}
    Run Keyword If    ${agree}    Select Checkbox    ${LOC_AGREE}
    ...    ELSE    Unselect Checkbox    ${LOC_AGREE}

Submit Registration
    Click Button    ${LOC_BTN_REGISTER}

Assert Messages Present
    [Arguments]    @{messages}
    Wait Until Keyword Succeeds    10x    500ms    Check Messages Once    @{messages}

Check Messages Once
    [Arguments]    @{messages}
    ${src}=    Get Source
    FOR    ${m}    IN    @{messages}
        Should Contain    ${src}    ${m}
    END

Assert Any Message Present
    [Arguments]    @{candidates}
    Wait Until Keyword Succeeds    10x    500ms    _Any Message Once    @{candidates}

_Any Message Once
    [Arguments]    @{candidates}
    ${src}=    Get Source
    ${hit}=    Set Variable    ${False}
    FOR    ${m}    IN    @{candidates}
        ${ok}=    Run Keyword And Return Status    Should Contain    ${src}    ${m}
        Run Keyword If    ${ok}    Set Variable    ${hit}    ${True}
    END
    Run Keyword Unless    ${hit}    Fail    None of the expected messages appeared: ${candidates}

*** Test Cases ***
All Fields Empty → All Required Messages
    Go To    ${REGISTER_URL}
    Click Button    ${LOC_BTN_REGISTER}

    Wait Until Page Contains    The First Name field is required.           5s
    Wait Until Page Contains    The Last Name field is required.            5s
    Wait Until Page Contains    The Email Address field is required.        5s
    Wait Until Page Contains    The Password field is required.             5s
    Wait Until Page Contains    The Password Confirm field is required.     5s
    Wait Until Page Contains    The Telephone field is required.            5s
    Wait Until Page Contains    The I Agree field is required.              5s

Missing First Name Only
    Fill Registration Form    ${EMPTY}    ${DEF_LAST}    ${EMPTY}    ${DEF_PASS}    ${DEF_PASS}    ${DEF_TEL}    True
    Submit Registration
    Assert Messages Present    ${REQ_FIRST}

Missing Telephone Only
    Fill Registration Form    ${DEF_FIRST}    ${DEF_LAST}    ${EMPTY}    ${DEF_PASS}    ${DEF_PASS}    ${EMPTY}    True
    Submit Registration
    Assert Messages Present    ${REQ_TEL}

Password Mismatch
    ${email}=    New Random Email
    Fill Registration Form    ${DEF_FIRST}    ${DEF_LAST}    ${email}    ${DEF_PASS}    Wrong123    ${DEF_TEL}    True
    Submit Registration
    Assert Messages Present    ${MSG_PASS_MUST_MATCH}

Invalid Email Format
    Fill Registration Form    ${DEF_FIRST}    ${DEF_LAST}    not-an-email    ${DEF_PASS}    ${DEF_PASS}    ${DEF_TEL}    True
    Submit Registration
    Location Should Contain    /register
