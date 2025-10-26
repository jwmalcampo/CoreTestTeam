*** Settings ***
Library          SeleniumLibrary
Library          String
Test Setup       Open Menus Page
Test Teardown    Run Keywords    Run Keyword If    '${TEST STATUS}'=='FAIL'    Capture Page Screenshot
...                             AND    Close Browser

*** Variables ***
${BASE}                 http://localhost/TastyIgniter_v3
${MENUS_URL}            ${BASE}/default/menus
${BROWSER}              chrome

${LOC_ADD_PUFF}         css=button.btn-cart[data-menu-id="1"]
${LOC_CHECKOUT_BTN}     css=button.checkout-btn[data-request*="onProceedToCheckout"]
${LOC_CART_MODAL}       css=#cart-box-modal.show
${LOC_CART_MODAL_CTA}   css=#cart-box-modal.show .checkout-btn

${LOC_FIRST}            id=first-name
${LOC_LAST}             id=last-name
${LOC_EMAIL}            id=email
${LOC_TEL}              id=telephone
${LOC_ADDR1}            xpath=//input[@name="address[address_1]"]
${LOC_ADDR2_NAME}       xpath=//input[@name="address[address_2]"]
${LOC_ADDR2_ALT}        xpath=(//input[@name="address[address_1]"])[2]
${LOC_CITY}             xpath=//input[@name="address[city]"]
${LOC_STATE}            xpath=//input[@name="address[state]"]
${LOC_POSTCODE}         xpath=//input[@name="address[postcode]"]
${LOC_CONFIRM_BTN}      css=button.checkout-btn[data-checkout-control="confirm-checkout"]

${VAL_ANY_1}            css=.text-danger
${VAL_ANY_2}            css=.alert-danger
${VAL_ANY_3}            css=.invalid-feedback
${VAL_ANY_4}            xpath=//*[contains(@class,'text-danger') or contains(@class,'invalid') or contains(@class,'help-block')]
${VAL_ANY_5}            css=input.is-invalid, select.is-invalid, textarea.is-invalid
${VAL_ANY_6}            css=[aria-invalid="true"]
${VAL_ANY_7}            css=.invalid-feedback, .valid-feedback, [data-validate-for], [data-validate-error]
${VAL_ANY_8}            css=.alert.alert-danger, .alert-danger

${EMAIL_INVALID_MSG}    The Email must be a valid email address.

${FIRST_OK}             Test
${LAST_OK}              Guest
${EMAIL_PREFIX}         checkout.neg
${EMAIL_DOMAIN}         example.com
${TEL_OK}               +61400123456
${ADDR1_OK}             10 Test Street
${ADDR2_OK}             Unit 2
${CITY_OK}              Sydney
${STATE_OK}             NSW
${POSTCODE_OK}          2000

*** Keywords ***
Open Menus Page
    Open Browser    ${MENUS_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    ${LOC_CHECKOUT_BTN}    10s
    Run Keyword And Ignore Error    Page Should Contain Element    css=button.btn-cart

Add Puff Puff To Cart (with settle)
    Wait Until Element Is Visible    ${LOC_ADD_PUFF}    10s
    Click Element                    ${LOC_ADD_PUFF}
    Sleep    2s
    Wait Until Keyword Succeeds    20x    500ms    Run Keywords
    ...    Run Keyword And Ignore Error    Page Should Contain Element    ${LOC_CART_MODAL}
    ...    AND    Run Keyword And Ignore Error    Element Should Be Enabled    ${LOC_CHECKOUT_BTN}

Go To Checkout (modal-safe)
    ${modal_open}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_CART_MODAL}
    IF    ${modal_open}
        ${has_cta}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_CART_MODAL_CTA}
        IF    ${has_cta}
            Click Button    ${LOC_CART_MODAL_CTA}
            Wait Until Page Contains Element    ${LOC_FIRST}    10s
            RETURN
        END
        Press Keys    xpath=//body    ESCAPE
        Wait Until Page Does Not Contain Element    ${LOC_CART_MODAL}    5s
    END
    Scroll Element Into View    ${LOC_CHECKOUT_BTN}
    Wait Until Element Is Enabled    ${LOC_CHECKOUT_BTN}    10s
    Click Button    ${LOC_CHECKOUT_BTN}
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_FIRST}    5s
    IF    not ${ok}
        Execute Javascript    document.querySelector("button.checkout-btn[data-request*='onProceedToCheckout']").click();
        Wait Until Page Contains Element    ${LOC_FIRST}    10s
    END

Start Checkout Fresh
    Add Puff Puff To Cart (with settle)
    Go To Checkout (modal-safe)

Generate Unique Email
    ${r}=    Generate Random String    6
    ${email}=    Set Variable    ${EMAIL_PREFIX}+${r}@${EMAIL_DOMAIN}
    RETURN    ${email}

Fill Checkout Form
    [Arguments]    ${first}    ${last}    ${email}    ${tel}    ${addr1}    ${addr2}    ${city}    ${state}    ${postcode}
    Wait Until Page Contains Element    ${LOC_FIRST}    10s
    Input Text    ${LOC_FIRST}      ${first}
    Input Text    ${LOC_LAST}       ${last}
    Input Text    ${LOC_EMAIL}      ${email}
    Click Element                    ${LOC_TEL}
    Press Keys                       ${LOC_TEL}    CTRL+A
    Input Text                       ${LOC_TEL}    ${tel}
    Input Text    ${LOC_ADDR1}      ${addr1}
    ${has_a2}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_ADDR2_NAME}
    Run Keyword If    ${has_a2}    Input Text    ${LOC_ADDR2_NAME}    ${addr2}
    ${has_a2b}=   Run Keyword And Return Status    Page Should Contain Element    ${LOC_ADDR2_ALT}
    Run Keyword If    ${has_a2b}   Input Text    ${LOC_ADDR2_ALT}     ${addr2}
    Input Text    ${LOC_CITY}       ${city}
    Input Text    ${LOC_STATE}      ${state}
    Input Text    ${LOC_POSTCODE}   ${postcode}
    Press Keys    ${LOC_EMAIL}      TAB
    Press Keys    ${LOC_ADDR1}      TAB

Submit Confirm
    Wait Until Element Is Visible    ${LOC_CONFIRM_BTN}    10s
    Click Button                     ${LOC_CONFIRM_BTN}
    Wait Until Keyword Succeeds    20x    500ms    Run Keywords
    ...    Run Keyword And Ignore Error    Page Should Contain Element    ${VAL_ANY_5}
    ...    AND    Run Keyword And Ignore Error    Page Should Contain Element    ${VAL_ANY_6}
    ...    AND    Run Keyword And Ignore Error    Page Should Contain Element    ${VAL_ANY_7}
    ...    AND    Run Keyword And Ignore Error    Page Should Contain Element    ${VAL_ANY_8}

Assert Validation Visible And Still On Checkout
    Wait Until Page Contains Element    ${LOC_CONFIRM_BTN}    10s
    Wait Until Page Contains Element    ${LOC_FIRST}         10s
    ${v1}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_1}
    ${v2}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_2}
    ${v3}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_3}
    ${v4}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_4}
    ${v5}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_5}
    ${v6}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_6}
    ${v7}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_7}
    ${v8}=    Run Keyword And Return Status    Page Should Contain Element    ${VAL_ANY_8}
    Run Keyword If    ${v1} or ${v2} or ${v3} or ${v4} or ${v5} or ${v6} or ${v7} or ${v8}    No Operation
    ...    ELSE    Fail    No validation markers visible after submit.

Assert Required Messages
    ${expected}=    Create List
    ...    The First Name field is required.
    ...    The Last Name field is required.
    ...    The Email field is required.
    ...    The Address 1 field is required.
    Wait Until Page Contains Element    ${LOC_CONFIRM_BTN}    10s
    Wait Until Page Contains Element    ${LOC_FIRST}         10s
    FOR    ${msg}    IN    @{expected}
        Wait Until Page Contains    ${msg}    10s
    END

Check Email Error Once
    ${by_text}=    Run Keyword And Return Status    Page Should Contain    ${EMAIL_INVALID_MSG}
    ${by_alert}=   Run Keyword And Return Status    Page Should Contain Element    xpath=//*[(@role='alert' or contains(@class,'alert') or contains(@class,'toast') or contains(@class,'swal2')) and contains(normalize-space(.), "${EMAIL_INVALID_MSG}")]
    ${by_msg}=     Run Keyword And Return Status    Page Should Contain Element    css=[data-validate-for="email"], [data-validate-error="email"], #email ~ .invalid-feedback
    ${by_xpath}=   Run Keyword And Return Status    Page Should Contain Element    xpath=//*[.//*[@id='email' or @name='email']]//*[contains(@class,'invalid') or contains(@class,'text-danger') or contains(@class,'help-block')]
    Run Keyword If    ${by_text} or ${by_alert} or ${by_msg} or ${by_xpath}    No Operation
    ...    ELSE    Fail    Could not find email validation via popup, alert, or field-level marker.

Assert Email Error Visible (robust)
    Wait Until Page Contains Element    ${LOC_EMAIL}    10s
    Wait Until Keyword Succeeds    20x    500ms    Check Email Error Once

*** Test Cases ***
All Fields Empty → Show Required Validations
    Start Checkout Fresh
    Submit Confirm
    Assert Required Messages

Invalid Email Format → Show Validation
    Start Checkout Fresh
    Fill Checkout Form    ${FIRST_OK}    ${LAST_OK}    not-an-email    ${TEL_OK}    ${ADDR1_OK}    ${ADDR2_OK}    ${CITY_OK}    ${STATE_OK}    ${POSTCODE_OK}
    Submit Confirm
    Assert Validation Visible And Still On Checkout
    Assert Email Error Visible (robust)

Missing Address 1 Only → Show Validation
    Start Checkout Fresh
    ${email}=    Generate Unique Email
    Fill Checkout Form    ${FIRST_OK}    ${LAST_OK}    ${email}    ${TEL_OK}    ${EMPTY}    ${ADDR2_OK}    ${CITY_OK}    ${STATE_OK}    ${POSTCODE_OK}
    Submit Confirm
    Assert Validation Visible And Still On Checkout
