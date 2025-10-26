*** Settings ***
Library          SeleniumLibrary
Library  String
Suite Setup      Open Menus Page
Suite Teardown   Close Browser
Test Teardown    Capture Page Screenshot

*** Variables ***
${BASE}                 http://localhost/TastyIgniter_v3
${MENUS_URL}           ${BASE}/default/menus
${BROWSER}             chrome

${LOC_ADD_PUFF}        css=button.btn-cart[data-menu-id="1"]
${LOC_CHECKOUT_BTN}    css=button.checkout-btn[data-request*="onProceedToCheckout"]

${LOC_FIRST}           id=first-name
${LOC_LAST}            id=last-name
${LOC_EMAIL}           id=email
${LOC_TEL}             id=telephone
${LOC_ADDR1}           xpath=//input[@name="address[address_1]"]
${LOC_ADDR2_NAME}      xpath=//input[@name="address[address_2]"]
${LOC_ADDR2_ALT}       xpath=(//input[@name="address[address_1]"])[2]
${LOC_CITY}            xpath=//input[@name="address[city]"]
${LOC_STATE}           xpath=//input[@name="address[state]"]
${LOC_POSTCODE}        xpath=//input[@name="address[postcode]"]
${LOC_CONFIRM_BTN}     css=button.checkout-btn[data-checkout-control="confirm-checkout"]

${LOC_ORDER_H}         xpath=//h5[contains(normalize-space(.),'Order #')]
${LOC_SUCCESS_LEAD}    xpath=//p[contains(@class,'lead') and contains(normalize-space(.),'Your order has been received')]

${FIRST_NAME}          Test
${LAST_NAME}           Guest
${EMAIL_PREFIX}        autotest
${EMAIL_DOMAIN}        example.com
${TELEPHONE}           +61400123456
${ADDR1}               1 Test Street
${ADDR2}               Unit 2
${CITY}                Sydney
${STATE}               NSW
${POSTCODE}            2000

*** Keywords ***
Open Menus Page
    Open Browser    ${MENUS_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    ${LOC_CHECKOUT_BTN}    10s
    Run Keyword And Ignore Error    Page Should Contain    Menu
    Run Keyword And Ignore Error    Page Should Contain Element    css=button.btn-cart

Add Puff Puff To Cart
    Wait Until Element Is Visible    ${LOC_ADD_PUFF}    10s
    Click Element                    ${LOC_ADD_PUFF}

    Sleep    2s

    Wait Until Keyword Succeeds    20x    500ms    Run Keywords
    ...    Run Keyword And Ignore Error    Page Should Contain Element    css=#cart-box-modal.show
    ...    AND    Run Keyword And Ignore Error    Element Should Be Enabled    ${LOC_CHECKOUT_BTN}



Go To Checkout
    ${modal_open}=    Run Keyword And Return Status    Page Should Contain Element    css=#cart-box-modal.show
    IF    ${modal_open}
        ${modal_has_cta}=    Run Keyword And Return Status    Page Should Contain Element    css=#cart-box-modal.show .checkout-btn
        IF    ${modal_has_cta}
            Click Button    css=#cart-box-modal.show .checkout-btn
            Wait Until Page Contains Element    ${LOC_FIRST}    10s
            RETURN
        END
        ${has_close}=    Run Keyword And Return Status    Page Should Contain Element    css=#cart-box-modal.show button.close, css=#cart-box-modal.show [data-dismiss="modal"]
        Run Keyword If    ${has_close}    Click Element    css=#cart-box-modal.show button.close, css=#cart-box-modal.show [data-dismiss="modal"]
        Press Keys    xpath=//body    ESCAPE
        Wait Until Page Does Not Contain Element    css=#cart-box-modal.show    5s
    END

    Scroll Element Into View    ${LOC_CHECKOUT_BTN}
    Wait Until Element Is Enabled    ${LOC_CHECKOUT_BTN}    10s
    Click Button    ${LOC_CHECKOUT_BTN}
    ${ok}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_FIRST}    5s
    Run Keyword Unless    ${ok}    Execute Javascript    document.querySelector("button.checkout-btn[data-request*='onProceedToCheckout']").click();
    Wait Until Page Contains Element    ${LOC_FIRST}    10s

Type If Present
    [Arguments]    ${locator}    ${value}
    ${ok}=    Run Keyword And Return Status    Page Should Contain Element    ${locator}
    Run Keyword If    ${ok}    Input Text    ${locator}    ${value}

Fill Guest Details
    ${random}=    Generate Random String    6
    ${email}=     Set Variable    ${EMAIL_PREFIX}+${random}@${EMAIL_DOMAIN}

    Input Text    ${LOC_FIRST}      ${FIRST_NAME}
    Input Text    ${LOC_LAST}       ${LAST_NAME}
    Input Text    ${LOC_EMAIL}      ${email}

    Click Element                    ${LOC_TEL}
    Press Keys                       ${LOC_TEL}    CTRL+A
    Input Text                       ${LOC_TEL}    ${TELEPHONE}

    Input Text    ${LOC_ADDR1}      ${ADDR1}
    Type If Present    ${LOC_ADDR2_NAME}    ${ADDR2}
    Run Keyword Unless    "${ADDR2}" == ""    Type If Present    ${LOC_ADDR2_ALT}    ${ADDR2}

    Input Text    ${LOC_CITY}       ${CITY}
    Input Text    ${LOC_STATE}      ${STATE}
    Input Text    ${LOC_POSTCODE}   ${POSTCODE}

Confirm Order
    Click Button    ${LOC_CONFIRM_BTN}
    Wait Until Page Contains Element    ${LOC_ORDER_H}        15s
    Wait Until Page Contains Element    ${LOC_SUCCESS_LEAD}   10s
    ${hdr}=    Get Text    ${LOC_ORDER_H}
    Log    ORDER HEADER: ${hdr}

*** Test Cases ***
Guest Can Place Order From Menus (Happy Path)
    Add Puff Puff To Cart
    Go To Checkout
    Fill Guest Details
    Confirm Order
