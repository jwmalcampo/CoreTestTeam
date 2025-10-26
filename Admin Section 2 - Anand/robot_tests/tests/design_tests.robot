*** Settings ***
Documentation    Automated Functional Tests for Design Module (19 Test Cases)
Library          SeleniumLibrary
Resource         ../resources/customers_keywords.robot
Resource         ../resources/design_keywords.robot
Suite Setup      Login To Admin
Suite Teardown   Logout From Admin

*** Variables ***
${RANDOM_NUM}           ${EMPTY}
${CREATED_PAGE}         ${EMPTY}
${CREATED_TEMPLATE}     ${EMPTY}

*** Test Cases ***
# ============================================
# THEMES TESTS (4 Tests)
# ============================================
TC_THEME_AUTO_001_View_Installed_Themes
    [Documentation]    TC_THEME_001: Verify installed themes are visible
    [Tags]    smoke    themes
    Navigate To Themes
    Page Should Contain    Orange Theme
    Page Should Contain    Demo Theme
    Page Should Contain Element    xpath://a[contains(text(), 'Browse more themes')]
    Page Should Contain Element    xpath://a[contains(text(), 'Check Updates')]

TC_THEME_AUTO_002_Browse_Marketplace
    [Documentation]    TC_THEME_002: Open marketplace themes
    [Tags]    functional    themes
    Navigate To Themes
    Click Browse More Themes
    Sleep    3s

TC_THEME_AUTO_003_Check_Updates
    [Documentation]    TC_THEME_003: Check for theme updates
    [Tags]    functional    themes
    Navigate To Themes
    Click Check Updates
    Sleep    3s

TC_THEME_AUTO_004_View_Theme_Details
    [Documentation]    TC_THEME_004: View theme details page
    [Tags]    functional    themes
    Navigate To Themes
    Click First Theme Card
    Sleep    2s

# ============================================
# STATIC PAGES TESTS (6 Tests)
# ============================================
TC_PAGE_AUTO_001_View_Pages_List
    [Documentation]    TC_PAGE_001: Verify static pages list is accessible
    [Tags]    smoke    pages
    Navigate To Static Pages
    Page Should Contain    Terms and Conditions
    Page Should Contain    Policy
    Page Should Contain    About Us
    Page Should Contain Element    xpath://a[contains(@href, 'pages/create')]

TC_PAGE_AUTO_002_Create_New_Page
    [Documentation]    TC_PAGE_002: Create new static page
    [Tags]    functional    pages    critical
    Navigate To Static Pages
    Click New Static Page
    ${RANDOM_NUM}=    Evaluate    str(random.randint(1000, 9999))    random
    Set Suite Variable    ${RANDOM_NUM}
    ${CREATED_PAGE}=    Set Variable    Contact Us Test ${RANDOM_NUM}
    Set Suite Variable    ${CREATED_PAGE}
    Fill Static Page Form    ${CREATED_PAGE}    contact-us-test-${RANDOM_NUM}    This is a test page for testing purposes. Email: test@restaurant.com
    Set Page Language    English
    Set Page Status    Enabled
    Save Static Page
    Design Verify Success Message
    Verify Page In List    ${CREATED_PAGE}

TC_PAGE_AUTO_003_Edit_Existing_Page
    [Documentation]    TC_PAGE_003: Edit existing page
    [Tags]    functional    pages
    Edit Page By Title    About Us
    Clear Element Text    name:Page[title]
    Input Text    name:Page[title]    About Us - Updated Test
    Save Static Page
    Design Verify Success Message
    Navigate To Static Pages
    Page Should Contain    About Us - Updated Test

TC_PAGE_AUTO_004_Change_Page_Status
    [Documentation]    TC_PAGE_004: Disable a page
    [Tags]    functional    pages
    Edit Page By Title    Policy
    Set Page Status    Disabled
    Save Static Page
    Design Verify Success Message

TC_PAGE_AUTO_005_Delete_Created_Test_Page
    [Documentation]    TC_PAGE_005: Delete the test page created in TC_PAGE_002
    [Tags]    functional    pages    cleanup
    Delete Page By Title    ${CREATED_PAGE}
    Design Verify Success Message
    Navigate To Static Pages
    Sleep    2s
    ${page_exists}=    Run Keyword And Return Status    Page Should Contain    ${CREATED_PAGE}
    Should Be Equal    ${page_exists}    ${False}    msg=Page should be deleted

TC_PAGE_AUTO_006_View_Static_Menus
    [Documentation]    TC_PAGE_006: Navigate to static menus
    [Tags]    functional    menus
    Click Static Menus
    Page Should Contain    Menus

# ============================================
# MAIL TEMPLATES TESTS (5 Tests)
# ============================================
TC_MAIL_AUTO_001_View_Templates_List
    [Documentation]    TC_MAIL_001: Verify mail templates list is accessible
    [Tags]    smoke    mail
    Navigate To Mail Templates
    Page Should Contain Element    xpath://a[contains(@href, 'mail_templates/create')]
    Page Should Contain    Order email to customer
    ${template_count}=    Get Element Count    xpath://table//tbody//tr
    Should Be True    ${template_count} >= 10    msg=Should have multiple templates

TC_MAIL_AUTO_002_Edit_Template_Subject
    [Documentation]    TC_MAIL_002: Edit mail template subject
    [Tags]    functional    mail
    Edit First Mail Template
    Sleep    1s
    ${current_subject}=    Get Value    name:Mail_template[subject]
    ${new_subject}=    Set Variable    ${current_subject} - TEST UPDATE
    Clear Element Text    name:Mail_template[subject]
    Sleep    0.5s
    Input Text    name:Mail_template[subject]    ${new_subject}
    Sleep    0.5s
    Save Mail Template
    Design Verify Success Message

TC_MAIL_AUTO_003_Edit_Template_Body_With_Variables
    [Documentation]    TC_MAIL_003: Add variables to template body
    [Tags]    functional    mail
    Navigate To Mail Templates
    Sleep    2s
    # Click on the first available template (or use a more reliable selector)
    Wait Until Element Is Visible    xpath:(//tr//a[contains(@class, 'btn-edit')])[2]    timeout=${TIMEOUT}
    Click Element    xpath:(//tr//a[contains(@class, 'btn-edit')])[2]
    Sleep    3s
    # Try to find the body editor - CodeMirror or textarea
    ${codemirror_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    css:.CodeMirror    timeout=5s
    Run Keyword If    ${codemirror_exists}    Execute JavaScript    var editor = document.querySelector('.CodeMirror').CodeMirror; editor.setValue(editor.getValue() + ' Welcome {{customer_name}}! Thank you for registering.');
    Run Keyword Unless    ${codemirror_exists}    Execute JavaScript    var editor = document.querySelector('[name="Mail_template[body]"]'); if(editor) { editor.value = editor.value + ' Welcome {{customer_name}}! Thank you for registering.'; }
    Sleep    1s
    Save Mail Template
    Design Verify Success Message

TC_MAIL_AUTO_004_Create_Custom_Template
    [Documentation]    TC_MAIL_004: Create new custom mail template
    [Tags]    functional    mail    critical
    # First, check if custom_test already exists and delete it
    Navigate To Mail Templates
    Sleep    2s
    ${template_exists}=    Run Keyword And Return Status    Page Should Contain    custom_test
    Run Keyword If    ${template_exists}    Run Keywords
    ...    Log    Template custom_test already exists, deleting it first
    ...    AND    Delete Template By Code    custom_test
    ...    AND    Sleep    2s
    # Now create the template
    Navigate To Mail Templates
    Click New Mail Template
    ${RANDOM_NUM}=    Evaluate    str(random.randint(1000, 9999))    random
    ${CREATED_TEMPLATE}=    Set Variable    admin::_mail.custom_test
    Set Suite Variable    ${CREATED_TEMPLATE}
    Fill Mail Template Form    Test Custom Email ${RANDOM_NUM}    ${CREATED_TEMPLATE}    Test Email Subject    Hello, this is a test email template.
    Select Mail Layout    Default layout
    Save Mail Template
    Sleep    2s
    Design Verify Success Message
    Navigate To Mail Templates
    Sleep    2s
    Page Should Contain    custom_test

TC_MAIL_AUTO_005_Delete_Custom_Template
    [Documentation]    TC_MAIL_005: Delete custom template created in TC_MAIL_004
    [Tags]    functional    mail    cleanup
    Delete Template By Code    custom_test
    Design Verify Success Message
    Navigate To Mail Templates
    Sleep    2s
    ${template_exists}=    Run Keyword And Return Status    Page Should Contain    custom_test
    Should Be Equal    ${template_exists}    ${False}    msg=Template should be deleted

# ============================================
# SLIDERS & BANNERS TESTS (4 Tests)
# ============================================
TC_SLIDER_AUTO_001_View_Sliders_List
    [Documentation]    TC_SLIDER_001: Verify sliders list is accessible
    [Tags]    smoke    sliders
    Navigate To Sliders
    Page Should Contain Element    xpath://a[contains(@href, 'sliders/create')]
    ${slider_exists}=    Run Keyword And Return Status    Page Should Contain    Homepage
    Run Keyword If    not ${slider_exists}    Log    No sliders found

TC_SLIDER_AUTO_002_Create_Slider_Without_Image
    [Documentation]    TC_SLIDER_002: Create slider without uploading image
    [Tags]    functional    sliders
    Navigate To Sliders
    Click New Slider
    ${RANDOM_NUM}=    Evaluate    str(random.randint(1000, 9999))    random
    Set Suite Variable    ${RANDOM_NUM}
    ${CREATED_SLIDER_NAME}=    Set Variable    Test Promotional Slider ${RANDOM_NUM}
    Set Suite Variable    ${CREATED_SLIDER_NAME}
    Fill Slider Form Without Image    ${CREATED_SLIDER_NAME}    test-promo-slider-${RANDOM_NUM}
    Save Slider
    Sleep    2s

TC_SLIDER_AUTO_003_Edit_Existing_Slider
    [Documentation]    TC_SLIDER_003: Edit the slider created in TC_SLIDER_002
    [Tags]    functional    sliders
    Navigate To Sliders
    Sleep    2s
    # Edit the slider we just created
    Wait Until Element Is Visible    xpath://tr[contains(., '${CREATED_SLIDER_NAME}')]//a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${CREATED_SLIDER_NAME}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    name:Slider[name]    timeout=${TIMEOUT}
    Clear Element Text    name:Slider[name]
    Input Text    name:Slider[name]    ${CREATED_SLIDER_NAME} - Updated
    Save Slider
    Design Verify Success Message
    Navigate To Sliders
    Page Should Contain    ${CREATED_SLIDER_NAME} - Updated

TC_SLIDER_AUTO_004_View_Banners_Section
    [Documentation]    TC_SLIDER_004: Navigate to banners section
    [Tags]    functional    banners
    Click Banners Button
    Page Should Contain    Banners

TC_SLIDER_AUTO_005_Delete_Created_Slider
    [Documentation]    TC_SLIDER_005: Delete the test slider created in TC_SLIDER_002
    [Tags]    functional    sliders    cleanup
    Navigate To Sliders
    Sleep    2s
    # Select the checkbox for the created slider
    Wait Until Element Is Visible    xpath://tr[contains(., '${CREATED_SLIDER_NAME}')]//input[@type='checkbox']    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${CREATED_SLIDER_NAME}')]//input[@type='checkbox']
    Sleep    1s
    # Click the Delete button
    Wait Until Element Is Visible    xpath://button[contains(@class, 'text-danger') and contains(., 'Delete')]    timeout=${TIMEOUT}
    Click Element    xpath://button[contains(@class, 'text-danger') and contains(., 'Delete')]
    Sleep    2s
    # Confirm deletion
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s
    Design Verify Success Message

*** Keywords ***