*** Settings ***
Library  Selenium2Screenshots
Library  Selenium2Library
Library  String
Library  DateTime
Library  kapitalist_service.py
Library  DebugLibrary

*** Variables ***
# Вхід в кабінет
${loginLink}                     id=loginLink
${loginEmailField}               id=Email
${loginPasswordField}            id=Password
${submitButton}                  xpath=//*[@type="submit"]
${createTenderButton}            xpath=//*[@id="mainControl"]/a[1]/div
#Тип тендеру - Допорогові закупівлі
${typeOfAdvertisementLink}       xpath=//* [text()="Допорогові закупівлі"]
${titleOfTenderField}            css=#Title
${descriptionOfTenderField}      css=#Description
${turnOnPdvCheckBox}             id=Value_VATIncluded
${questionStartDate}             id=EnquiryPeriod_StartDate_Local
${questionEndDate}               id=EnquiryPeriod_EndDate_Local
${tenderPeriodStartDate}         id=TenderPeriod_StartDate_Local
${tenderPeriodEndDate}           id=TenderPeriod_EndDate_Local
${saveButton}                    xpath=//*[@type="submit"]

#Вхід до кабінету
${personalCabinetButton}         xpath=//*[@id="logoutForm"]//li/a/span

# Додавання лоту
${addLot}                        xpath=//fieldset[2]/a[1]
${lotHeader}                     id=Title
${lotDescription}                id=Description
${lotValueAmount}                id=Value_Amount
${lotGuaranteeAmount}            id=Guarantee_Amount
${lotMinimalStepAmount}          id=MinimalStep_Amount
${lotSaveButton}                 xpath=//*[@type="submit"]

# Додавання айтему
${addItemButton}                 xpath=//fieldset[3]/a[1]
${CpvCodeList}                   xpath=//*[@id='accordionCPV']/div/div/h4/a
${searchCPV}                     id=Classification_search
${addCpvCode}                    id=03121100-6_anchor
${unitCode}                      id=Unit_Code
${unitName}                      id=Unit_Name
${unitQuantity}                  id=Quantity
${deliveryDateStartDateLocal}    id=DeliveryDate_StartDate_Local
${deliveryDateEndDateLocal}      id=DeliveryDate_EndDate_Local
${deliveryAddressCountry}        id=DeliveryAddress_Country
${DeliveryAddress.Region}        id=DeliveryAddress_Region
${DeliveryAddress.City}          id=DeliveryAddress_Locality
${DeliveryAddress_PostalCode}    id=DeliveryAddress_PostalCode
${DeliveryAddress_Street}        id=DeliveryAddress_Street
${item.deliveryAdress.longtitude}      id=DeliveryLocation_Longitude
${item.deliveryAdress.latitude}        id=DeliveryLocation_Latitude
${itemSaveButton}                xpath=//*[@type="submit"]

# Завантадення документу
${addDocument}                   xpath=//div/fieldset[2]/a[3]
${documentDescription}           id=Description
#${typeOfDocument}
#${languageOfDocument}
${uploadButton}                  id=Document
${document.save.button}          css=[type="submit"]

#Пошук тендеру по идентифікатору
${tenderSearchButton}            xpath=//*[@id="mainControl"]/a[3]
${byTenderNumber}                xpath=//div[2]/a[2]
${PrecurementNumber}             id=ProcurementNumber
${searchButton}                  id=search
${publicTenderButton}            xpath=//*[@type="submit"]

#Питання
${addQuestionButton}             xpath=//*[@id="general"]/div/fieldset[1]/a[4]
${QuestionTitle}                 id=Title
${QuestionDescription}           id=Description
${saveQuestionButton}            xpath=//*[@type="submit"]
${answerQuestionButton}          xpath=//*[@id="general"]/div/fieldset/div[4]/fieldset/div[1]/div[4]/a
${answer.text.field}             id=Answer
${answer.save.button}            css=[type="submit"]
*** Keywords ***
#Виконано
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  [return]  ${ARGUMENTS[1]}

#Виконано
Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${ARGUMENTS[0]}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'kapitalist_Viewer'   Вхід   ${ARGUMENTS[0]}

#Виконано
Вхід
  [Arguments]  ${username}
  Run Keyword And Ignore Error   Wait Until Page Contains Element    ${loginLink}         10
  Click Element                  ${loginLink}
  Run Keyword And Ignore Error   Wait Until Page Contains Element    ${loginEmailField}   10
  Input text                     ${loginEmailField}                  ${USERS.users['${username}'].login}
  Sleep  2
  Input text                     ${loginPasswordField}               ${USERS.users['${username}'].password}
  Click Button                   ${submitButton}
  Sleep  3
#Виконано
Змінити користувача
  [Arguments]  @{ARGUMENTS}
  Go to                          ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Input text                     ${loginEmailField}                  ${USERS.users['${username}'].login}
  Sleep  2
  Input text                     ${loginPasswordField}               ${USERS.users['${username}'].password}
  Click Button                   ${submitButton}
  Sleep  3
#Виконано
Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

  Set Global Variable      ${TENDER_INIT_DATA_LIST}    ${ARGUMENTS[1]}
  ${items}=             Get From Dictionary     ${ARGUMENTS[1].data}               items
  ${title}=             Get From Dictionary     ${ARGUMENTS[1].data}               title
  ${description}=       Get From Dictionary     ${ARGUMENTS[1].data}               description
  ${budget}=            Get From Dictionary     ${ARGUMENTS[1].data.value}         amount
  ${step_rate}=         Get From Dictionary     ${ARGUMENTS[1].data.minimalStep}   amount
  ${items_description}=   Get From Dictionary   ${items[0]}         description
  ${quantity}=          Get From Dictionary     ${items[0]}                        quantity
  ${cpv}=               Get From Dictionary     ${items[0].classification}         id
  ${unit}=              Get From Dictionary     ${items[0].unit}                   name
  ${latitude}=          Get From Dictionary     ${items[0].deliveryLocation}      latitude
  ${longitude}=         Get From Dictionary     ${items[0].deliveryLocation}      longitude
  ${postalCode}=        Get From Dictionary     ${items[0].deliveryAddress}       postalCode
  ${streetAddress}=     Get From Dictionary     ${items[0].deliveryAddress}       streetAddress
  ${deliveryDate}=      Get From Dictionary     ${items[0].deliveryDate}          endDate
  ${deliveryDate}=      convert_date_to_format        ${deliveryDate}
  ${enquiry_end_date}=   get_all_dates   ${ARGUMENTS[1]}         EndPeriod          date
#  ${enquiry_end_time}=   get_all_dates   ${ARGUMENTS[1]}         EndPeriod          time
  ${start_date}=         get_all_dates   ${ARGUMENTS[1]}         StartDate          date
#  ${start_time}=         get_all_dates   ${ARGUMENTS[1]}         StartDate          time
  ${end_date}=           get_all_dates   ${ARGUMENTS[1]}         EndDate            date
#  ${end_time}=           get_all_dates   ${ARGUMENTS[1]}

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    ${createTenderButton}                               10
  Click Element                       ${createTenderButton}
  Sleep  3
  Click Element                       ${typeOfAdvertisementLink}
#  Wait Until Page Contains Element    ${titleOfTenderField}                              30
  Click Element                       ${titleOfTenderField}
  Input text                          ${titleOfTenderField}                              ${title}
  Input text                          ${descriptionOfTenderField}                        ${description}
#  Чек бокс для включення/відключення ПДВ (при необхідності закоментувати)
  Click Element                       ${turnOnPdvCheckBox}
  Sleep  3
  Input text                          ${questionEndDate}                                ${enquiry_end_date}
  Sleep  3
  Input text                          ${tenderPeriodStartDate}                          ${start_date}
  Sleep  3
  Input text                          ${tenderPeriodEndDate}                            ${end_date}
  Click Element                       ${saveButton}
#  Створена чернетка допорогового тендеру
  Sleep  1

# Додавання лоту
#Додати Предмет
  Wait Until Page Contains Element      ${addLot}
  click element                         ${addLot}
  Wait Until Page Contains Element      ${lotHeader}
  Input text                            ${lotHeader}                      ${title}
  Input text                            ${lotDescription}                 ${description}
  Sleep  3
  Execute Javascript                    $(${lotValueAmount}).data("kendoNumericTextBox").value(${budget});
  Execute Javascript                    $(${lotGuaranteeAmount}).data("kendoNumericTextBox").value(${budget});
  Execute Javascript                    $(${lotMinimalStepAmount}).data("kendoNumericTextBox").value(${step_rate});
  Click Element                         ${lotSaveButton}

# Додавання номенклатури закупівлі
  Wait Until Page Contains Element      ${addItemButton}                  10
  Click Element                         ${addItemButton}
  Wait Until Page Contains Element      ${lotDescription}                 10
  Input Text                            ${lotDescription}                 ${item_description}
  Sleep  1
  Click Element                         ${cpvcodelist}
  Sleep  1
  Wait Until Element Is Visible         ${searchCPV}                      10
  Sleep  1
  Input Text                            ${searchCPV}                      ${cpv}
  Sleep  1
  Execute Javascript                    location.href = "#${cpv}_anchor";
  Click Element                         id=${cpv}_anchor
  Sleep  1
  Execute Javascript                    location.href = "#Unit_Code";
  Sleep  1
  Wait Until Element Is Visible         ${unitCode}                       10
  Input Text                            ${unitCode}                       KGM
  Input Text                            ${unitName}                       ${unit}
  Input Text                            ${unitQuantity}                   ${quantity}
  Input Text                            ${deliveryDateStartDateLocal}     ${deliveryDate}
  Input Text                            ${deliveryDateEndDateLocal}       ${deliveryDate}
  Input Text                            ${deliveryAddressCountry}         Україна
  Input Text                            ${DeliveryAddress.Region}         м. Київ
  Input Text                            ${DeliveryAddress.City}           м. Київ
  Input Text                            ${DeliveryAddress_PostalCode}     ${postalCode}
  Input Text                            ${DeliveryAddress_Street}         ${streetAddress}
#  Execute Javascript                    location.href = "#DeliveryLocation_Longitude";
#  Convert To String                     ${longitude}
#  Input Text                            ${item.deliveryAdress.longtitude} 123
#  Input Text                            ${item.deliveryAdress.latitude}   ${latitude}
  Click Element                         ${itemSaveButton}
  #Публікація тендеру
  Click Element                         ${publicTenderButton}
  Sleep  3
  wait until page contains element      xpath=//*[@id="tabstrip"]/../h3
  ${tender_UAid}=  Get Text  xpath=//*[@id="tabstrip"]/../h3
  Sleep  1
  ${tender_UAid}=  get_tender_id      ${tender_UAid}
  Log   ${tender_UAid}
  ${Ids}=   Convert To String         ${tender_UAid}
  log to console      ${Ids}
  Log   ${Ids}
#  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${ARGUMENTS[0]}   ${tender_UAid}
  [return]  ${Ids}
 Debug
#Виконано
# Додавання лоту(тетс пройшов)
Додати предмет
  [Arguments]
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ...      ${ARGUMENTS[1]} ==  ${INDEX}
  ${dkpp_desc}=     Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${ARGUMENTS[0].additionalClassifications[0]}   id
  Wait Until Page Contains Element      ${addLot}
  click element                         ${addLot}
  Wait Until Page Contains Element      ${lotHeader}
  Input text                            ${lotHeader}                      ${title}
  Input text                            ${lotDescription}                 ${description}
  Sleep  3
  Execute Javascript                    $(${lotValueAmount}).data("kendoNumericTextBox").value(${budget});
  Execute Javascript                    $(${lotGuaranteeAmount}).data("kendoNumericTextBox").value(${budget});
  Execute Javascript                    $(${lotMinimalStepAmount}).data("kendoNumericTextBox").value(${step_rate});
#  Input text                            ${lotGuaranteeAmount}             ${budget}
#  Input text                            ${lotMinimalStepAmount}           ${step_rate}
  Click Element                         ${lotSaveButton}
#Виконано(тест не пройшов)
Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  kapitalist.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[2]}
  Wait Until Page Contains Element             ${addDocument}        10
  Click Element                                ${addDocument}
  Input Text                                   ${documentDescription}  Test_document
  Choose File                                  ${uploadButton}   ${ARGUMENTS[1]}
  Sleep             2
  Press Key         ENTER
  Click Element                                ${document.save button}
#  Reload Page
#Виконано(тест пройшов для tender_owner)
Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER}
  Switch Browser                    ${ARGUMENTS[0]}
  Go to                             ${USERS.users['${ARGUMENTS[0]}'].homepage}
#  Wait Until Page Contains Element  ${tenderSearchButton}                           Y
  Click Element                     ${tenderSearchButton}
#  Wait Until Page Contains Element  ${byTenderNumber}                           Y
  Click Element                     ${byTenderNumber}
  Wait Until Page Contains Element  ${PrecurementNumber}
  Input Text                        ${PrecurementNumber}                        ${ARGUMENTS[1]}
  Click Element                     ${searchButton}
#  Wait Until Page Contains          ${ARGUMENTS[1]}   10
  Wait Until Page Contains Element    xpath=//*[@id="tender-table"]/tbody/tr[1]/td/a    10
  Click Link    xpath=//*[@id="tender-table"]/tbody/tr[1]/td/a
  sleep  1

#Виконане
Перейти до сторінки запитань
  Wait Until Page Contains Element   ${addQuestionButton}
  Click Element                      ${addQuestionButton}
  Wait Until Page Contains Element   ${QuestionTitle}           10

#Не виконане програмістами
Перейти до сторінки відмін
  Wait Until Page Contains Element   id=cancels_ref
  Click Element     id=cancels_ref
  Wait Until Element Contains  id=records_shown      Y

#Не виконане програмістами
Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
#  Wait Until Page Contains Element      xpath=(//*[@id='btn_question' and not(contains(@style,'display: none'))])
#  Click Element     id=btn_question
  kapitalist.Перейти до сторінки запитань
  Sleep   3
  Input text          ${QuestionTitle}                 ${title}
  Input text          ${QuestionDescription}           ${description}
  Click Element       ${saveQuestionButton}
  Sleep  3

Скасувати закупівлю
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = cancellation_reason
  ...      ${ARGUMENTS[3]} = doc_path
  ...      ${ARGUMENTS[4]} = description
  kapitalist.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=(//*[@id='btnСancel' and not(contains(@style,'display: none'))])
  Click Element     id=btnСancel
  Sleep   2
  Input text                         id=e_reason                 ${ARGUMENTS[2]}
  Click Element                      id=SendCancellation
  Sleep  3
  Wait Until Page Contains Element          xpath=(//*[@id='pnList']//span[contains(@class, 'add_document')])
  Click Element     xpath=(//*[@id='pnList']//span[contains(@class, 'add_document')])
  Choose File       xpath=(//*[@id='upload_form']/input[2])   ${ARGUMENTS[3]}
  Sleep   2
  Input text                   id=eFile_accessDetails      ${ARGUMENTS[4]}
  Click Element     id=upload_button
  Sleep   2
  Reload Page
  Click Element     xpath=(//*[@id='pnList']/div[1]/div[2]/div[2]/span)

Отримати інформацію про cancellations[0].status
  Перейти до сторінки відмін
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_cancel_status')])
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_cancel_status')])
  [return]           ${return_value}

Отримати інформацію про cancellations[0].reason
  Перейти до сторінки відмін
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_cancel_reason')])
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_cancel_reason')])
  [return]           ${return_value}

Оновити сторінку з тендером
  [Arguments]    @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  Switch Browser    ${ARGUMENTS[0]}
  kapitalist.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  item_id
  ...      ${ARGUMENTS[3]} ==  field_name
  ${return_value}=  Run Keyword And Return  kapitalist.Отримати інформацію із тендера  ${username}  ${tender_uaid}  ${field_name}
  [return]           ${return_value}

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[2]} ==  fieldname
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[2]}
  [return]           ${return_value}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${fieldname}
  [return]           ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати текст із поля і показати на сторінці   title
  [return]           ${return_value}

Отримати інформацію про procurementMethodType
  ${return_value}=   Отримати текст із поля і показати на сторінці   procurementMethodType
  [return]           ${return_value}

Отримати інформацію про dgfID
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgf
  [return]           ${return_value}

Отримати інформацію про dgfDecisionID
  ${return_value}=   Отримати текст із поля і показати на сторінці   dgfDecisionID
  [return]           ${return_value}

Отримати інформацію про dgfDecisionDate
  ${date_value}=   Отримати текст із поля і показати на сторінці   dgfDecisionDate
  ${return_value}=   kapitalist_service.convert_date    ${date_value}
  [return]           ${return_value}

Отримати інформацію про tenderAttempts
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderAttempts
  ${return_value}=   Convert To Integer   ${return_value}
  [return]           ${return_value}


Отримати інформацію про eligibilityCriteria
  ${return_value}=   Отримати текст із поля і показати на сторінці   eligibilityCriteria

Отримати інформацію про status
  Reload Page
  Wait Until Page Contains Element      xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Sleep   2
  ${return_value}=   Get Text   id=tPosition_status
  [return]           ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати текст із поля і показати на сторінці   description
  [return]           ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці  value.amount
  ${return_value}=   Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [return]           ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   convert to number   ${return_value.replace(' ', '').replace(',', '.')}
  [return]           ${return_value}

# Внесені правки
Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  fieldname
  ...      ${ARGUMENTS[3]} ==  fieldvalue
  Wait Until Page Contains Element   ${ARGUMENTS[2]}   5
  Input Text                         ${ARGUMENTS[2]}   ${ARGUMENTS[3]}
  Click Element                      ${publicTenderButton}
#  Wait Until Page Contains      Публікацію виконано        5
  ${result_field}=  Get Value        ${ARGUMENTS[2]}
  Should Be Equal   ${result_field}   ${ARGUMENTS[3]}

Отримати інформацію про items[${index}].quantity
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[${index}].quantity
  ${return_value}=    Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [return]           ${return_value}

Отримати інформацію про items[${index}].unit.code
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[${index}].unit.code
  [return]           ${return_value}

Отримати інформацію про items[${index}].unit.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[${index}].unit.name
  [return]           ${return_value}

Отримати інформацію про items[${index}].description
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[${index}].description
  [return]           ${return_value}

Отримати інформацію про items[${index}].classification.id
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[${index}].classification.id
  [return]           ${return_value}

Отримати інформацію про items[${index}].classification.scheme
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[${index}].classification.scheme
  [return]           ${return_value}

Отримати інформацію про items[${index}].classification.description
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[${index}].classification.description
  [return]           ${return_value}

Отримати інформацію про value.currency
  ${return_value}=   Get Selected List Value        slPosition_value_currency
  [return]           ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   is_checked                     cbPosition_value_valueAddedTaxIncluded
  [return]           ${return_value}

Отримати інформацію про auctionID
  ${return_value}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]           ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]           ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryLocation.latitude
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=   Отримати текст із поля і показати на сторінці   items[0].deliveryLocation.longitude
  ${return_value}=   Convert To Number   ${return_value}
  [return]           ${return_value}

Отримати інформацію про auctionPeriod.startDate
  ${date_value}=     Get Text  id=tdtpPosition_auctionPeriod_startDate_Date
  ${time_value}=     Get Text  id=tePosition_auctionPeriod_startDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}
  [return]           ${return_value}

Отримати інформацію про auctionPeriod.endDate
  ${date_value}=     Get Text  id=tdtpPosition_auctionPeriod_startDate_Date
  ${time_value}=     Get Text  id=tePosition_auctionPeriod_startDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}

Отримати інформацію про tenderPeriod.startDate
  ${date_value}=     Get Text  id=tdtpPosition_tenderPeriod_startDate_Date
  ${time_value}=     Get Text  id=tePosition_tenderPeriod_startDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}
  [return]           ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${date_value}=     Get Text  id=tPosition_tenderPeriod_endDate_Date
  ${time_value}=     Get Text  id=tPosition_tenderPeriod_endDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}
  [return]           ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${date_value}=     Get Text  id=tdtpPosition_enquiryPeriod_startDate_Date
  ${time_value}=     Get Text  id=tePosition_enquiryPeriod_startDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}
  [return]           ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${date_value}=     Get Text  id=tdtpPosition_enquiryPeriod_endDate_Date
  ${time_value}=     Get Text  id=tePosition_enquiryPeriod_endDate_Time
  ${return_value}=   convert_date_to_iso    ${date_value}   ${time_value}
  [return]           ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.countryName
  [return]           ${return_value.split(', ')[0]}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [return]           ${return_value.split(', ')[1]}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.region
  [return]           ${return_value.split(', ')[2]}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.locality
  [return]           ${return_value.split(', ')[3]}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=   Отримати текст із поля і показати на сторінці  items[0].deliveryAddress.streetAddress
  [return]           ${return_value.split(', ')[4]}

Отримати інформацію про items[0].deliveryDate.endDate
  ${date_value}=     Отримати текст із поля і показати на сторінці  items[0].deliveryDate.endDate
  ${return_value}=   kapitalist_service.convert_date    ${date_value}
  [return]           ${return_value}

Отримати інформацію про questions[${index}].title
  ${index}=          inc              ${index}
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_title')])[${index}]
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_qa_title')])[${index}]
  [return]           ${return_value}

Отримати інформацію про questions[${index}].description
  ${index}=          inc              ${index}
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_qa_description')])[${index}]
  [return]           ${return_value}

Отримати інформацію про questions[${index}].answer
  ${index}=          inc              ${index}
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_qa_answer')])[${index}]
  [return]           ${return_value}

Отримати інформацію про questions[${index}].date
  ${index}=          inc              ${index}
  Wait Until Page Contains Element    xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
  ${return_value}=   Get text         xpath=(//span[contains(@class, 'rec_qa_date')])[${index}]
  ${return_value}=   convert_date_time_to_iso    ${return_value}
  [return]           ${return_value}

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data
  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  kapitalist.Пошук тендера по ідентифікатору        ${ARGUMENTS[0]}          ${ARGUMENTS[1]}
  Wait Until Page Contains Element      ${answerQuestionButton}
  Click Element                         ${answerQuestionButton}
  Input Text                            ${answer.text.field}        ${answer}
  Click Element                         ${answer.save.button}
  sleep   1

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  username
  ...    ${ARGUMENTS[1]} ==  tenderId
  ...    ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${amount}=    get_str          ${ARGUMENTS[2].data.value.amount}
  ${is_qualified}=   is_qualified         ${ARGUMENTS[2]}
  ${is_eligible}=    is_eligible          ${ARGUMENTS[2]}
  kapitalist.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Wait Until Page Contains Element          xpath=(//*[@id='btnBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnBid
  Sleep   3
  Wait Until Page Contains Element          xpath=(//*[@id='eBid_price' and not(contains(@style,'display: none'))])
  Input Text          id=eBid_price         ${amount}
  Run Keyword If    ${is_qualified}   Click Element   id=lcbBid_selfQualified
  Run Keyword If    ${is_eligible}    Click Element   id=lcbBid_selfEligible
  Click Element       id=btn_save
  sleep   3
  Wait Until Page Contains Element          xpath=(//*[@id='btn_public' and not(contains(@style,'display: none'))])
  Click Element       id=btn_public
  sleep   1
  ${resp}=    Get Value      id=eBid_price
  [return]    ${resp}

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  username
  ...    ${ARGUMENTS[1]} ==  tenderId
  kapitalist.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnShowBid
  Sleep   3
  Wait Until Page Contains Element   xpath=(//*[@id='btn_delete' and not(contains(@style,'display: none'))])
  Click Element       id=btn_delete

Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}   ${field}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element   xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnShowBid
  Sleep   3
  ${value}=   Get Value     id=eBid_price
  ${value}=   Convert To Number      ${value}
  [Return]    ${value}

Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  username
  ...    ${ARGUMENTS[1]} ==  tenderId
  ...    ${ARGUMENTS[2]} ==  amount
  ...    ${ARGUMENTS[3]} ==  amount.value
  ${amount}=    get_str          ${${ARGUMENTS[3]}}
  kapitalist.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Wait Until Page Contains Element          xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnShowBid
  Sleep   3
  Wait Until Page Contains Element          xpath=(//*[@id='eBid_price' and not(contains(@style,'display: none'))])
  Input Text              id=eBid_price     ${amount}
  sleep   1
  Click Element       id=btn_public

Завантажити документ в ставку
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[1]} ==  file
  ...    ${ARGUMENTS[2]} ==  tenderId
  Wait Until Page Contains Element          xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element     id=btnShowBid
  Sleep   3
  Wait Until Page Contains Element          xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element     id=btn_documents_add
  Choose File       xpath=(//*[@id='upload_form']/input[2])   ${ARGUMENTS[1]}
  Sleep   2
  Click Element     id=upload_button
  Reload Page

Змінити документ в ставці
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...    ${ARGUMENTS[0]} ==  username
  ...    ${ARGUMENTS[1]} ==  file
  ...    ${ARGUMENTS[2]} ==  bidId
  Reload Page
  Wait Until Page Contains Element           xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element     css=.bt_ReUpload:first-child
  Choose File       xpath=(//*[@id='upload_form']/input[2])   ${ARGUMENTS[1]}
  Sleep   2
  Click Element     id=upload_button
  Reload Page

Завантажити фінансову ліцензію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element   xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnShowBid
  Sleep   3
  Wait Until Page Contains Element    xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                id=btn_documents_add
  Select From List By Value    id=slFile_documentType      financialLicense
  Choose File                  xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button
  Reload Page

Отримати інформацію про bids
  [Arguments]  @{ARGUMENTS}
  Викликати для учасника  ${ARGUMENTS[0]}  Оновити сторінку з тендером  ${ARGUMENTS[1]}
  Click Element                       id=bids_ref

Отримати посилання на аукціон для глядача
  [Arguments]  @{ARGUMENTS}
  Switch Browser       ${ARGUMENTS[0]}
  Wait Until Page Contains Element   xpath=(//*[@id='aPosition_auctionUrl' and not(contains(@style,'display: none'))])
  Sleep   5
  ${result} =   Get Text  id=aPosition_auctionUrl
  [return]   ${result}

Отримати посилання на аукціон для учасника
  [Arguments]  @{ARGUMENTS}
  Switch Browser       ${ARGUMENTS[0]}
  Wait Until Page Contains Element   xpath=(//*[@id='aPosition_auctionUrl' and not(contains(@style,'display: none'))])
  Sleep   5
  ${result}=    Get Text  id=aPosition_auctionUrl
  [return]   ${result}

Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element       xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                          id=btn_documents_add
  Select From List By Value              id=slFile_documentType      ${doc_type}
  Choose File                            xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button

Завантажити ілюстрацію
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element       xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                          id=btn_documents_add
  Select From List By Value              id=slFile_documentType      illustration
  Choose File                            xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button

Додати Virtual Data Room
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element       xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                          id=btn_documents_add
  Select From List By Value              id=slFile_documentType      virtualDataRoom
  Input text                             id=eFile_url                ${vdr_url}
  Click Element     id=upload_button

Додати публічний паспорт активу
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element       xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                          id=btn_documents_add
  Select From List By Value              id=slFile_documentType      x_dgfPublicAssetCertificate
  Input text                             id=eFile_url                ${vdr_url}
  Click Element     id=upload_button

Додати офлайн документ
  [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element       xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                          id=btn_documents_add
  Select From List By Value              id=slFile_documentType      x_dgfAssetFamiliarization
  Input text                             id=eFile_accessDetails      ${accessDetails}
  Click Element     id=upload_button

Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${doc_value}=  Get Text   xpath=(//*[@id='pn_documentsContent_']/table[${document_index + 1}]//span[contains(@class, 'documentType')])
  [return]  ${doc_value}

Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field_name}
  ${doc_value}=  Run Keyword If   '${field_name}' == 'description'
  ...     Get Text    xpath=(//span[contains(@class, 'description') and contains(@class, '${doc_id}')])
  ...     ELSE    Get Text   xpath=(//a[contains(@class, 'doc_title') and contains(@class, '${doc_id}')])
  [Return]   ${doc_value}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${item_id}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Перейти до сторінки запитань
  Wait Until Page Contains Element      ${answerQuestionButton}
  Click Element                         ${answerQuestionButton}
  Input Text                            id=e_answer        ${answer_data.data.answer}
  Click Element                         id=SendAnswer
  sleep   1

Отримати кількість предметів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${return_value}=    Get Text           id=tPosition_items_count
  ${return_value}=    Convert To Number  ${return_value}
  [return]            ${return_value}

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Перейти до сторінки запитань
  ${return_value}=      Run Keyword If   '${field_name}' == 'title'
  ...     Get Text    xpath=(//span[contains(@class, 'qa_title') and contains(@class, '${item_id}')])
  ...     ELSE IF  '${field_name}' == 'answer'     Get Text    xpath=(//span[contains(@class, 'qa_answer') and contains(@class, '${item_id}')])
  ...     ELSE    Get Text   xpath=(//span[contains(@class, 'qa_description') and contains(@class, '${item_id}')])
  [return]           ${return_value}

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Задати питання   ${username}    ${tender_uaid}     ${question}

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element      xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element     xpath=(//span[contains(@class, 'bt_item_question') and contains(@class, '${item_id}')])
  Sleep  3
  Input text          id=e_title                 ${question.data.title}
  Input text          id=e_description           ${question.data.description}
  Click Element     id=SendQuestion
  Sleep  3

Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${index}=  kapitalist.Отримати кількість предметів в тендері     ${username}   ${tender_uaid}
  ${ItemAddButtonVisible}=    Page Should Contain Element    id=btn_items_add
  Run Keyword If  '${ItemAddButtonVisible}'=='PASS'   Run Keywords
  ...   Додати предмет                ${item}                ${index}
  ...   AND    Click Element                 id=btnPublic
  ...   AND    Wait Until Page Contains      Публікацію виконано    10

Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${ItemAddButtonVisible}=    Page Should Contain Element    id=btn_items_add
  Run Keyword If  '${ItemAddButtonVisible}'=='PASS'   Run Keywords
  ...   Wait Until Page Contains Element   xpath=(//ul[contains(@class, 'bt_item_delete') and contains(@class, ${item_id})])
  ...   AND    Click Element     xpath=(//ul[contains(@class, 'bt_item_delete') and contains(@class, ${item_id})])
  ...   AND    Click Element      id=btnPublic
  ...   AND    Wait Until Page Contains      Публікацію виконано         10

Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${tender_doc_number}=   Get Matching Xpath Count   xpath=(//*[@id='pn_documentsContent_']/table)
  [Return]  ${tender_doc_number}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  kapitalist.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element   xpath=(//a[contains(@class, 'doc_title') and contains(@class, '${doc_id}')])
  sleep   3
  ${file_name}=   Get Text    xpath=(//a[contains(@class, 'doc_title') and contains(@class, '${doc_id}')])
  ${url}=   Get Element Attribute    xpath=(//a[contains(@class, 'doc_title') and contains(@class, '${doc_id}')])@href
  download_file   ${url}  ${file_name.split('/')[-1]}  ${OUTPUT_DIR}
  [return]  ${file_name.split('/')[-1]}

Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  ${document_index}=        inc         ${document_index}
  ${result}=   Get Text                 xpath=(//*[@id='pnAwardList']/div[last()]/div/div[1]/div/div/div[2]/table[${document_index}]//span[contains(@class, 'documentType')])
  [Return]   ${result}

Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${bid_doc_number}=   Get Matching Xpath Count   xpath=(//*[@id='pnAwardList']/div[last()]/div/div[1]/div/div/div[2]/table)
  [Return]  ${bid_doc_number}

Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element      xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])
  Sleep   1
  Click Element                         xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Cancel_button')])

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element      xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'award_button')])
  Sleep   1
  Click Element                         xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'award_button')])

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
  Input text          xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Reject_description')])                 ${description}
  Click Element       xpath=(//*[@id='pnAwardList']/div[last()]//*[contains(@class, 'Reject_button')])

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${award_num}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element      xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element                xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'award_docs')]//span[contains(@class, 'add_document')])
  Choose File                  xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button
  Reload Page

Завантажити протокол аукціону
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element          xpath=(//*[@id='btnShowBid' and not(contains(@style,'display: none'))])
  Click Element       id=btnShowBid
  Sleep   1
  Wait Until Page Contains Element          xpath=(//*[@id='btn_documents_add' and not(contains(@style,'display: none'))])
  Click Element                             id=btn_documents_add
  Select From List By Value    id=slFile_documentType      auctionProtocol
  Choose File                  xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button

Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
  kapitalist.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Page Contains Element      xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element                xpath=(//*[@id='pnAwardList']/div[last()]//div[contains(@class, 'contract_docs')]//span[contains(@class, 'add_document')])
  Select From List By Value    id=slFile_documentType      contractSigned
  Choose File                  xpath=(//*[@id='upload_form']/input[2])   ${filepath}
  Sleep   2
  Click Element     id=upload_button
  Reload Page

Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  ${file_path}  ${file_title}  ${file_content}=   create_fake_doc
  Sleep    5
  kapitalist.Завантажити угоду до тендера   ${username}  ${tender_uaid}  1  ${filepath}
  Wait Until Page Contains Element      xpath=(//*[@id='tPosition_status' and not(contains(@style,'display: none'))])
  Click Element                xpath=(//*[@id='pnAwardList']/div[last()]//span[contains(@class, 'contract_register')])
