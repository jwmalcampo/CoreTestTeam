*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${ADMIN_URL}              http://localhost/TastyIgniter_v3/admin
${MAIL_TEMPLATES_URL}     http://localhost/TastyIgniter_v3/admin/mail_templates
${SLIDERS_URL}            http://localhost/TastyIgniter_v3/admin/igniter/frontend/sliders
${THEMES_URL}             http://localhost/TastyIgniter_v3/admin/themes
${PAGES_URL}              http://localhost/TastyIgniter_v3/admin/igniter/pages/pages
${ADMIN_USERNAME}         anand
${ADMIN_PASS}             MySecurePass123!
${TIMEOUT}                40s

*** Keywords ***
# ============================================
# THEMES KEYWORDS
# ============================================
Navigate To Themes
    Go To    ${THEMES_URL}
    Wait Until Page Contains    Themes    timeout=${TIMEOUT}
    Sleep    2s

Click Browse More Themes
    Wait Until Element Is Visible    xpath://a[contains(text(), 'Browse more themes')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(text(), 'Browse more themes')]
    Sleep    3s

Click Check Updates
    Wait Until Element Is Visible    xpath://a[contains(text(), 'Check Updates')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(text(), 'Check Updates')]
    Sleep    3s

Click First Theme Card
    Wait Until Element Is Visible    xpath:(//div[contains(@class, 'theme-card') or contains(@class, 'card')])[1]    timeout=${TIMEOUT}
    Click Element    xpath:(//div[contains(@class, 'theme-card') or contains(@class, 'card')])[1]
    Sleep    3s

# ============================================
# STATIC PAGES KEYWORDS
# ============================================
Navigate To Static Pages
    Go To    ${PAGES_URL}
    Wait Until Page Contains    Static Pages    timeout=${TIMEOUT}
    Sleep    2s

Click New Static Page
    Wait Until Element Is Visible    xpath://a[contains(@href, 'pages/create')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@href, 'pages/create')]
    Sleep    3s

Fill Static Page Form
    [Arguments]    ${title}    ${permalink}    ${content}
    Wait Until Element Is Visible    name:Page[title]    timeout=${TIMEOUT}
    Input Text    name:Page[title]    ${title}
    Input Text    name:Page[permalink_slug]    ${permalink}
    Wait Until Element Is Visible    xpath://a[@href='#primarytab-1']    timeout=${TIMEOUT}
    Click Element    xpath://a[@href='#primarytab-1']
    Sleep    2s
    Wait Until Element Is Visible    css:.note-editable    timeout=${TIMEOUT}
    Click Element    css:.note-editable
    Sleep    1s
    Execute JavaScript    var editor = document.querySelector('.note-editable'); editor.innerHTML = '<p>${content}</p>'; editor.dispatchEvent(new Event('input', { bubbles: true }));
    Sleep    1s

Set Page Language
    [Arguments]    ${language}=English
    Wait Until Element Is Visible    xpath://a[@href='#primarytab-2']    timeout=${TIMEOUT}
    Click Element    xpath://a[@href='#primarytab-2']
    Sleep    2s
    Wait Until Element Is Visible    xpath://select[@name='Page[language_id]']/following-sibling::div[contains(@class, 'ss-main')]    timeout=${TIMEOUT}
    Click Element    xpath://select[@name='Page[language_id]']/following-sibling::div[contains(@class, 'ss-main')]
    Sleep    1s
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option') and text()='${language}']    timeout=${TIMEOUT}
    Click Element    xpath://div[contains(@class, 'ss-option') and text()='${language}']
    Sleep    1s

Set Page Status
    [Arguments]    ${status}=Enabled
    Wait Until Element Is Visible    xpath://a[@href='#primarytab-2']    timeout=${TIMEOUT}
    Click Element    xpath://a[@href='#primarytab-2']
    Sleep    2s
    ${is_checked}=    Run Keyword And Return Status    Element Should Be Visible    xpath://input[@id='form-field-page-status' and @checked='checked']
    Run Keyword If    '${status}' == 'Enabled' and not ${is_checked}    Click Element    id:form-field-page-status
    Run Keyword If    '${status}' == 'Disabled' and ${is_checked}    Click Element    id:form-field-page-status

Save Static Page
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=${TIMEOUT}
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s

Verify Page In List
    [Arguments]    ${page_title}
    Navigate To Static Pages
    Sleep    2s
    Wait Until Page Contains    ${page_title}    timeout=${TIMEOUT}

Edit Page By Title
    [Arguments]    ${page_title}
    Navigate To Static Pages
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${page_title}')]//a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${page_title}')]//a[contains(@class, 'btn-edit')]
    Sleep    3s
    Wait Until Element Is Visible    xpath://a[@href='#primarytab-2']    timeout=${TIMEOUT}

Delete Page By Title
    [Arguments]    ${page_title}
    Navigate To Static Pages
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${page_title}')]//input[@type='checkbox']    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${page_title}')]//input[@type='checkbox']
    Sleep    1s
    Wait Until Element Is Visible    xpath://button[contains(., 'Delete')]    timeout=${TIMEOUT}
    Click Element    xpath://button[contains(., 'Delete')]
    Sleep    1s
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s

Click Static Menus
    Navigate To Static Pages
    Wait Until Element Is Visible    xpath://a[contains(text(), 'Static Menus')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(text(), 'Static Menus')]
    Sleep    3s

# ============================================
# MAIL TEMPLATES KEYWORDS
# ============================================
Navigate To Mail Templates
    Go To    ${MAIL_TEMPLATES_URL}
    Wait Until Page Contains    Mail Templates    timeout=${TIMEOUT}
    Sleep    2s

Click New Mail Template
    Wait Until Element Is Visible    xpath://a[contains(@class, 'btn-primary') and contains(@href, 'create')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@class, 'btn-primary') and contains(@href, 'create')]
    Sleep    3s

Fill Mail Template Form
    [Arguments]    ${title}    ${code}    ${subject}    ${body}
    # First fill code field
    Wait Until Element Is Visible    name:Mail_template[code]    timeout=${TIMEOUT}
    Input Text    name:Mail_template[code]    ${code}
    Sleep    0.5s
    # Then label/description
    Wait Until Element Is Visible    name:Mail_template[label]    timeout=${TIMEOUT}
    Input Text    name:Mail_template[label]    ${title}
    Sleep    0.5s
    # Then subject - with proper wait to ensure field is loaded
    Wait Until Element Is Visible    name:Mail_template[subject]    timeout=${TIMEOUT}
    Input Text    name:Mail_template[subject]    ${subject}
    Sleep    0.5s
    # Finally the body using CodeMirror
    Wait Until Element Is Visible    css:.CodeMirror    timeout=${TIMEOUT}
    Sleep    1s
    Execute JavaScript    var editor = document.querySelector('.CodeMirror').CodeMirror; editor.setValue('${body}');
    Sleep    1s

Select Mail Layout
    [Arguments]    ${layout}=Default layout
    Wait Until Element Is Visible    xpath://select[@name='Mail_template[layout_id]']/following-sibling::div[contains(@class, 'ss-main')]    timeout=${TIMEOUT}
    Click Element    xpath://select[@name='Mail_template[layout_id]']/following-sibling::div[contains(@class, 'ss-main')]
    Sleep    1s
    Wait Until Element Is Visible    xpath://div[contains(@class, 'ss-option') and text()='${layout}']    timeout=${TIMEOUT}
    Click Element    xpath://div[contains(@class, 'ss-option') and text()='${layout}']
    Sleep    1s

Save Mail Template
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=${TIMEOUT}
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s

Edit First Mail Template
    Navigate To Mail Templates
    Sleep    2s
    Wait Until Element Is Visible    xpath://a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@class, 'btn-edit')]
    Sleep    4s
    # Wait for the subject field to be visible in edit mode
    Wait Until Element Is Visible    name:Mail_template[subject]    timeout=${TIMEOUT}

Edit Template By Code
    [Arguments]    ${template_code}
    Navigate To Mail Templates
    Sleep    2s
    Wait Until Element Is Visible    xpath://tr[contains(., '${template_code}')]//a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${template_code}')]//a[contains(@class, 'btn-edit')]
    Sleep    4s
    Wait Until Element Is Visible    name:Mail_template[code]    timeout=${TIMEOUT}

Delete Template By Code
    [Arguments]    ${template_code}
    Navigate To Mail Templates
    Sleep    2s
    # Select the checkbox for the template
    Wait Until Element Is Visible    xpath://tr[contains(., '${template_code}')]//input[@type='checkbox']    timeout=${TIMEOUT}
    Click Element    xpath://tr[contains(., '${template_code}')]//input[@type='checkbox']
    Sleep    1s
    # Click the Delete button in the bulk actions toolbar
    Wait Until Element Is Visible    xpath://button[contains(@class, 'text-danger') and contains(., 'Delete')]    timeout=${TIMEOUT}
    Click Element    xpath://button[contains(@class, 'text-danger') and contains(., 'Delete')]
    Sleep    2s
    # Confirm deletion in the dialog
    Handle Alert    action=ACCEPT    timeout=10s
    Sleep    3s

Verify Template In List
    [Arguments]    ${template_code}
    Navigate To Mail Templates
    Sleep    2s
    Wait Until Page Contains    ${template_code}    timeout=${TIMEOUT}

# ============================================
# SLIDERS KEYWORDS
# ============================================
Navigate To Sliders
    Go To    ${SLIDERS_URL}
    Wait Until Page Contains    Sliders    timeout=${TIMEOUT}
    Sleep    2s

Click New Slider
    Wait Until Element Is Visible    xpath://a[contains(@href, 'sliders/create')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@href, 'sliders/create')]
    Sleep    3s

Fill Slider Form Without Image
    [Arguments]    ${name}    ${code}
    Wait Until Element Is Visible    name:Slider[name]    timeout=${TIMEOUT}
    Input Text    name:Slider[name]    ${name}
    Input Text    name:Slider[code]    ${code}
    Sleep    1s

Save Slider
    Scroll Element Into View    xpath://button[@data-request='onSave']
    Wait Until Element Is Visible    xpath://button[@data-request='onSave']    timeout=${TIMEOUT}
    Click Button    xpath://button[@data-request='onSave']
    Sleep    4s

Edit Slider By Name
    [Arguments]    ${slider_name}
    Navigate To Sliders
    Sleep    2s
    ${slider_exists}=    Run Keyword And Return Status    Page Should Contain    ${slider_name}
    Run Keyword If    ${slider_exists}    Run Keywords
    ...    Wait Until Element Is Visible    xpath://tr[contains(., '${slider_name}')]//a[contains(@class, 'btn-edit')]    timeout=${TIMEOUT}
    ...    AND    Click Element    xpath://tr[contains(., '${slider_name}')]//a[contains(@class, 'btn-edit')]
    ...    AND    Sleep    3s
    ...    AND    Wait Until Element Is Visible    name:Slider[name]    timeout=${TIMEOUT}
    ...    ELSE    Log    Slider ${slider_name} not found

Click Banners Button
    Navigate To Sliders
    Wait Until Element Is Visible    xpath://a[contains(@href, 'banners')]    timeout=${TIMEOUT}
    Click Element    xpath://a[contains(@href, 'banners')]
    Sleep    3s

# ============================================
# SHARED KEYWORDS
# ============================================
Design Verify Success Message
    Wait Until Page Contains Element    xpath://*[contains(text(), 'success') or contains(@class, 'success')]    timeout=${TIMEOUT}