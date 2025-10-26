*** Settings ***
Library          SeleniumLibrary
Library          String
Test Setup       Open Login Page
Test Teardown    Run Keywords    Run Keyword If    '${TEST STATUS}'=='FAIL'    Capture Page Screenshot
...                             AND    Close Browser

*** Variables ***
${BASE}                 http://localhost/TastyIgniter_v3
${LOGIN_URL}            ${BASE}/login
${MENUS_URL}            ${BASE}/default/menus
${RECENT_ORDERS_URL}    ${BASE}/account/orders
${BROWSER}              chrome

${USER_EMAIL}           jasmine_welch@gmail.com
${USER_PASSWORD}        Eyeksel@060499

${LOC_LOGIN_EMAIL}      id=login-email
${LOC_LOGIN_PASS}       id=login-password
${LOC_LOGIN_BTN}        xpath=//button[normalize-space(.)='Login']
${LOC_MYACCOUNT_DD}     css=a.nav-link.dropdown-toggle

${LOC_ADD_PUFF}         css=button.btn-cart[data-menu-id="1"]
${LOC_CHECKOUT_BTN}     css=button.checkout-btn[data-request*='onProceedToCheckout']
${LOC_CART_BOX}         css=#cart-box
${LOC_CART_MODAL}       css=#cart-box-modal.show
${LOC_CART_MODAL_CTA}   css=#cart-box-modal.show .checkout-btn
${LOC_CART_SUBTOTAL}    css=#cart-box-subtotal

${LOC_FIRST}            id=first-name
${LOC_LAST}             id=last-name
${LOC_EMAIL}            id=email
${LOC_TEL}              id=telephone
${LOC_ADDR1}            xpath=//input[@name="address[address_1]"]
${LOC_CITY}             xpath=//input[@name="address[city]"]
${LOC_STATE}            xpath=//input[@name="address[state]"]
${LOC_POSTCODE}         xpath=//input[@name="address[postcode]"]
${LOC_CONFIRM_BTN}      css=button.checkout-btn[data-checkout-control='confirm-checkout']

${LOC_ORDER_H}          xpath=//h5[contains(normalize-space(.),'Order #')]
${LOC_SUCCESS_LEAD}     xpath=//p[contains(@class,'lead') and contains(normalize-space(.),'Your order has been received')]

${ADDR1_OK}             10 Test Street
${CITY_OK}              Sydney
${STATE_OK}             NSW
${POSTCODE_OK}          2000

*** Keywords ***
Open Login Page
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    ${LOC_LOGIN_EMAIL}    10s

Login As Valid User
    Input Text     ${LOC_LOGIN_EMAIL}    ${USER_EMAIL}
    Input Text     ${LOC_LOGIN_PASS}     ${USER_PASSWORD}
    Click Button   ${LOC_LOGIN_BTN}
    Wait Until Page Contains Element     ${LOC_MYACCOUNT_DD}    10s

Open Menus Page
    Go To     ${MENUS_URL}
    Wait Until Page Contains Element    ${LOC_CHECKOUT_BTN}    10s

Add Puff Puff To Cart (with settle)
    Wait Until Element Is Visible    ${LOC_ADD_PUFF}    10s
    Click Element                    ${LOC_ADD_PUFF}
    Sleep    2s
    ${ok1}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_CART_MODAL}       5s
    ${ok2}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_CART_BOX}         5s
    ${ok3}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LOC_CART_SUBTOTAL}    5s
    Run Keyword If    not (${ok1} or ${ok2} or ${ok3})    Fail    Cart UI did not appear after adding item.

Go To Checkout
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
    ${clicked}=    Run Keyword And Return Status    Click Button    ${LOC_CHECKOUT_BTN}
    IF    not ${clicked}
        Execute Javascript
        ...    (function(){
        ...        var btn = document.querySelector("button.checkout-btn[data-request*='onProceedToCheckout']");
        ...        if (btn) btn.click();
        ...    })();
    END
    Wait Until Page Contains Element    ${LOC_FIRST}    10s

Assert Prefilled Fields (Logged-in)
    ${email_val}=    Get Element Attribute    ${LOC_EMAIL}    value
    Should Be Equal    ${email_val}    ${USER_EMAIL}
    ${a1}=    Get Element Attribute    ${LOC_ADDR1}    value
    ${city}=  Get Element Attribute    ${LOC_CITY}     value
    ${st}=    Get Element Attribute    ${LOC_STATE}    value
    ${pc}=    Get Element Attribute    ${LOC_POSTCODE}  value
    IF    '${a1}'==''
        Input Text    ${LOC_ADDR1}     ${ADDR1_OK}
    END
    IF    '${city}'==''
        Input Text    ${LOC_CITY}      ${CITY_OK}
    END
    IF    '${st}'==''
        Input Text    ${LOC_STATE}     ${STATE_OK}
    END
    IF    '${pc}'==''
        Input Text    ${LOC_POSTCODE}  ${POSTCODE_OK}
    END

Confirm Order And Capture Number
    Wait Until Element Is Visible    ${LOC_CONFIRM_BTN}    10s
    Click Button                     ${LOC_CONFIRM_BTN}
    Wait Until Page Contains Element    ${LOC_ORDER_H}        15s
    Wait Until Page Contains Element    ${LOC_SUCCESS_LEAD}   10s
    ${hdr}=        Get Text    ${LOC_ORDER_H}
    Log            ORDER HEADER: ${hdr}
    ${num}=        Replace String    ${hdr}    Order #    ${EMPTY}
    ${num}=        Strip String      ${num}
    Set Suite Variable    ${ORDER_NUMBER}    ${num}

Assert Order Appears In Recent Orders
    Go To    ${RECENT_ORDERS_URL}
    Wait Until Page Contains Element
    ...    xpath=(//a[contains(@class,'btn') and contains(normalize-space(.),'View/Reorder')])[1]    10s

    Click Element    xpath=(//a[contains(@class,'btn') and contains(normalize-space(.),'View/Reorder')])[1]

    Wait Until Page Contains Element    ${LOC_ORDER_H}    10s
    ${hdr}=    Get Text    ${LOC_ORDER_H}
    ${num}=    Replace String    ${hdr}    Order #    ${EMPTY}
    ${num}=    Strip String      ${num}

    Should Be Equal    ${num}    ${ORDER_NUMBER}


*** Test Cases ***
Logged-in User Can Checkout From Menus (Happy Path + Prefill + Recent Orders)
    Login As Valid User
    Open Menus Page
    Add Puff Puff To Cart (with settle)
    Go To Checkout
    Assert Prefilled Fields (Logged-in)
    Confirm Order And Capture Number
    Assert Order Appears In Recent Orders

