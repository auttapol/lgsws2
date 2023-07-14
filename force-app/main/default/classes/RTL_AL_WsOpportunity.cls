@RestResource(urlMapping='/data/V1.0/sobjects/Opportunity/*')
global without sharing class RTL_AL_WsOpportunity extends RTL_AL_WebserviceAbstract {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    private static final Id retailProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Prospect').getRecordTypeId();

    // private static final String notSupportMethodMSG = 'Not support {0} Method';
    private static final List<String> accountFields = new List<String> {
        // 'Email_Address_PE__c',
        'First_name_PE__c',
        'Last_name_PE__c',
        'ID_Type_PE__c',
        'ID_Number_PE__c',
        'Mobile_Number_PE__c'
    };

    // private static final List<String> opportunityFields = new List<String> {
    //     // 'RTL_Branch_Name__c', // Formular field
    //     'RTL_Branch_Code__c',
    //     'RTL_AL_available_time__c',
    //     'RTL_AL_car_bought_from__c',
    //     'RTL_AL_car_brand__c',
    //     'RTL_AL_car_gear__c',
    //     'RTL_AL_car_group__c',
    //     'RTL_AL_car_subtype__c',
    //     'RTL_AL_car_type__c',
    //     'RTL_AL_car_year__c',
    //     'RTL_AL_contact_channel__c',
    //     'RTL_AL_installment_amount__c',
    //     'RTL_AL_installment_periods__c',
    //     'RTL_AL_max_set_up_amount__c',
    //     'RTL_AL_normal_price__c',
    //     'RTL_AL_wanted_amount__c',
    //     'RTL_Product_Name__c',
    //     'LeadSource',
    //     'RTL_Campaign_Lead_Source__c',
    //     // 'RTL_Customer_Segment__c', // Formular field
    //     // 'RTL_Contact_Method__c', // No field opportunity
    //     'RTL_AL_oa_ref_code__c',
    //     'Corebank_Emp_Id__c',
    //     'RTL_Status__c',
    //     'CloseDate',
    //     'RTL_AL_PayPerMonth__c',
    //     'RTL_AL_DownPercent__c',
    //     'RTL_AL_DownAmt__c',
    //     'RTL_AL_CarBooked__c',
    //     'RTL_AL_Showroom__c',
    //     'RTL_AL_TentName__c',
    //     'RecordTypeId',
    //     'RTL_AL_ContactDistrict__c',
    //     'RTL_AL_ContactSubDistrict__c',
    //     'RTL_AL_ContactZipcode__c',
    //     'RTL_AL_ContactProvince__c',
    //     // Add 20201130 18:12
    //     'RTL_AL_Refer_No__c',
    //     'RTL_AL_Req_No1__c',
    //     'RTL_AL_Req_No2__c'
    // };

    private static String getIdRetailProductMasterByName(String productName) {
        Map<String,Id> temp = new Map<String,Id>();
        for (RTL_product_master__c product : [SELECT Id, Name FROM RTL_product_master__c WHERE Name = :productName AND Name <> null and active__c = true]) {
            temp.put(product.Name, product.Id);
        }
        return temp.containsKey(productName) ? temp.get(productName) : null;
    }
   
    private static String assignDoubleQuote(Object obj) {
        return '"' + obj + '"';
    }

    private static String passValueCondition(String key, Object obj) {
        return key + ' = \'' + obj + '\' AND ' + key + ' != null';
    }


    global RTL_AL_WsOpportunity() {

    }
    
    private static Map<String, String> StepFlowCreateOpportunity {
        get {
            return new Map<String, String>{
                '0' => 'Start Create opportunity from HPAP',
                '1' => 'Decrypt data :[{0}]',
                '2' => 'Check RMID from HPAP is sent with TMB Customer ID in Customer :[{0}]',
                '3' => 'The system will check First Name, Last Name, Mobile No, ID Type, ID No in Customer :[{0}]',
                '4' => 'Create Prospect Customer :[{0}]',
                '5' => 'Create Opportunity with Prospect Customer :[{0}]'
            };
        }
    }

    private static String trackingMessage(String step, String message, String value) {
        return String.format('[{0}]: {1}\n', new List<Object>{
            String.valueOf(RESTOpportunityUtil.getTHDatetimeNOW()).remove('|'),
            StepFlowCreateOpportunity.containsKey(step) ? String.format(StepFlowCreateOpportunity.get(step), new List<String>{ value }) : message
        }); 
    }

    /*
        5.12 Provide Web service to Create Opportunity data from HPAP system.						
        Salesforce required data for matching customer data before create opportunity data.					
            1. RMID				
            2. First Name => not null				
            3. Last Name => not null				
            4. Mobile No. => not null				
            5. ID Type => not null				
            6. ID No => not null				
                            
        Logic to create Opportunity.					
        Step1: Check RMID from HPAP is sent with TMB Customer ID in Customer.					
            > IF found then the system will create opportunity in Salesforce.				
            > IF not found then go to Step2.				
        Step2: The system will check First Name, Last Name, Mobile No, ID Type, ID No in Customer.					
            > IF found then the system will create opportunity in Salesforce.				
            > IF not found then the system will process as below.				
            1. Create Prospect Customer.				
                    The system will use address from HPAP when Create Prospect Customer's addres only.				
                    - Account.Primary_Address_Line_2_PE__c = ContactSubDistrict				
                    - Account.Primary_Address_Line_3_PE__c = ContactDistrict				
                    - Account.Province_Primary_PE__c = ContactProvince				
                    - Account.Zip_Code_Primary_PE__c = ContactZipcode				
            2. Create Opportunity with Prospect Customer.				
     */
    @HttpPost
    global static SCSReqRes httpPostWebservice() {
        Savepoint sp;
        String trackMsg = trackingMessage('0', '', '');
        Map<String, String> requestHeader = RestContext.request.headers;
        RestRequest request = RestContext.request;
        Datetime startDate = Datetime.now();
        
        Account accountObj;
        Account accountCheckInDatabase;
        Opportunity opportunityHPAP;
        String privateKey = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
        String resEncrypt;
        String resDecrypt;
        Map<String, Object> requestBodyMap;

        try {
            sp = Database.setSavepoint();
            resEncrypt = request.requestBody.toString();
            // if(requestHeader.containsKey('For-Test') ? requestHeader.get('For-Test') == 'DEV' : false) {
            //     resEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(resEncrypt, privateKey);
            // }
            resDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(resEncrypt, privateKey);
            trackMsg += trackingMessage('1', '', resDecrypt != null ? 'success' : 'failure');

            requestBodyMap = resDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(resDecrypt) : new Map<String, Object>();
              
            System.debug('requestBodyMap : ' + requestBodyMap);
            accountObj = requestBodyMap.containsKey('Account') ? 
                (Account)JSON.deserialize(JSON.serialize(requestBodyMap.get('Account')), Account.class) : null;
            
            System.debug('Check RTL Product Name : ' + checkIsEmpty(requestBodyMap.get('RTL_Product_Name__c')));

            // Checking for require field account
            List<String> fieldsMissing = new List<String>();
            Boolean checkRequireFields = false;
            for (String fieldRequired : new List<String>{ 'CloseDate','StageName', 'RTL_Product_Name__c','RecordTypeId' }) {
                if(requestBodyMap.containsKey(fieldRequired)){
                    if(checkIsEmpty(requestBodyMap.get(fieldRequired))) {
                        fieldsMissing.add(String.format('{0}', new List<Object>{ fieldRequired }));
                        checkRequireFields = true;
                    }
                }else{
                    fieldsMissing.add(String.format('{0}', new List<Object>{ fieldRequired }));
                    checkRequireFields = true;
                }
            }
            if(checkIsEmpty(accountObj, accountFields) || checkRequireFields) {
                for (String fieldRequired : accountFields) {
                    if(checkIsEmpty(accountObj.get(fieldRequired))) {
                        fieldsMissing.add(String.format('{0}.{1}', new List<Object>{ Account.getSObjectType(), fieldRequired}));
                    }
                }
                Response response = responseMsg(false, new List<ErrorDetail>{
                    new ErrorDetail(
                        'REQUIRED_FIELD_MISSING', 
                        String.format('Required fields are missing => [{0}]', new List<String>{ String.join(fieldsMissing, ', ') })
                    )
                }, null);
                trackMsg += trackingMessage('', JSON.serializePretty(response), '');
                RTL_CampaignUtil.saveToOnlineLog(
                    false,
                    accountCheckInDatabase != null ? accountCheckInDatabase.Name : '', // customerName
                    trackMsg, // Error message
                    requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                    UserInfo.getName(),
                    accountCheckInDatabase != null ? (String)accountCheckInDatabase.get('TMB_Customer_ID_PE__c') : '',
                    String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                        request.httpMethod, request.resourcePath
                    }) : getServiceName(SERVICENAME.CreateOpportunity),
                    AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                    JSON.serializePretty(response), // Response Body
                    accountCheckInDatabase,
                    startDate,
                    Datetime.now() // End datetime
                );
                return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
            }
  
            // Action for checking RMID from HPAP is sent with TMB Customer ID in Customer.
            // Preparing query
            List<String> fieldsQuery = new List<String>{ 'Name', 'TMB_Customer_ID_PE__c', 'Core_Banking_Suggested_Segment__c' };
            fieldsQuery.addAll(accountFields);
            String accountFieldsMerge = String.join(fieldsQuery, ',');
            String queryRMID = String.format('SELECT {0} FROM Account WHERE {1}', new List<Object>{
                accountFieldsMerge,
                passValueCondition('TMB_Customer_ID_PE__c', accountObj.get('TMB_Customer_ID_PE__c'))
            });

            String searchKey =  String.join(new List<Object>{
                assignDoubleQuote(setSearch((String)accountObj.get('First_name_PE__c'))),
                assignDoubleQuote(setSearch((String)accountObj.get('Last_name_PE__c'))),
                assignDoubleQuote(setSearch((String)accountObj.get('ID_Type_PE__c'))),
                assignDoubleQuote(setSearch((String)accountObj.get('ID_Number_PE__c'))),
                assignDoubleQuote(setSearch((String)accountObj.get('Mobile_Number_PE__c')))
            }, ' OR ');
            searchKey = '{' + searchKey + '}';
            String queryPersonInfo = String.format('FIND {0} IN ALL FIELDS RETURNING Account({1})', new List<String>{
                searchKey,
                accountFieldsMerge
            });
            
            // find customer existing 
            List<SObject> sObjectList;
            if(!checkIsEmpty(accountObj.get('TMB_Customer_ID_PE__c'))) {
                trackMsg += trackingMessage('2', '', (String)accountObj.get('TMB_Customer_ID_PE__c'));
                sObjectList = (List<SObject>)Database.query(queryRMID);
                accountCheckInDatabase = !sObjectList.isEmpty() ? (Account)sObjectList.get(0) : null;
            }
            if (accountCheckInDatabase == null || checkIsEmpty(accountObj.get('TMB_Customer_ID_PE__c'))) {
                List<String> temp = new List<String>();
                for (String fieldName : accountFields) {
                    temp.add(String.format('{0}: {1}', new List<Object>{
                        fieldName, accountObj.get(fieldName)
                    }));
                }
                trackMsg += trackingMessage('3', '', String.join(temp, ', '));
                sObjectList = ((List<List<SObject>>)Search.query(queryPersonInfo)).get(0);
                for (Account account : (List<Account>)sObjectList) {
                    // account.get('Email_Address_PE__c') == accountObj.get('Email_Address_PE__c') &&
                    // account.get('First_name_PE__c') == accountObj.get('First_name_PE__c') &&
                    // account.get('Last_name_PE__c') == accountObj.get('Last_name_PE__c') &&
                    // account.get('Mobile_Number_PE__c') == accountObj.get('Mobile_Number_PE__c')  &&
                    if(account.get('ID_Type_PE__c') == accountObj.get('ID_Type_PE__c') &&
                        String.valueOf(account.get('ID_Number_PE__c')).contains((String)accountObj.get('ID_Number_PE__c'))) {
                        accountCheckInDatabase = account;
                        break;
                    }
                }
            }
            
            // TODO: Create customer prospect 
            if(accountCheckInDatabase == null) {
                accountCheckInDatabase = new Account(
                    Name = accountObj.get('First_name_PE__c') + ' ' + accountObj.get('Last_name_PE__c'),
                    Email_Address_PE__c = (String)accountObj.get('Email_Address_PE__c'),
                    First_name_PE__c = (String)accountObj.get('First_name_PE__c'),
                    Last_name_PE__c = (String)accountObj.get('Last_name_PE__c'),
                    ID_Type_PE__c = (String)accountObj.get('ID_Type_PE__c'),
                    ID_Number_PE__c = (String)accountObj.get('ID_Number_PE__c'),
                    Mobile_Number_PE__c = (String)accountObj.get('Mobile_Number_PE__c'),
                    // TMB_Customer_ID_PE__c = (String)accountObj.get('TMB_Customer_ID_PE__c'),
                    Primary_Address_Line_2_PE__c = (String)accountObj.get('Primary_Address_Line_2_PE__c'),
                    Primary_Address_Line_3_PE__c = (String)accountObj.get('Primary_Address_Line_3_PE__c'),
                    Zip_Code_Primary_PE__c = (String)accountObj.get('Zip_Code_Primary_PE__c'),
                    Province_Primary_PE__c = (String)accountObj.get('Province_Primary_PE__c'),
                    RecordTypeId = retailProspectRecordTypeId
                );
                insert accountCheckInDatabase;
                trackMsg += trackingMessage('4', '', (String)accountCheckInDatabase.get('Id'));
            }

            // Mapping dynamic 
            opportunityHPAP = mappingOpportunityFields(requestBodyMap);
            System.debug('accountCheckInDatabase' + accountCheckInDatabase.Id);
            opportunityHPAP.AccountId = accountCheckInDatabase.Id;
            // opportunityHPAP.StageName = 'App In';
            opportunityHPAP.RTL_Product_Name__c = getIdRetailProductMasterByName((String)requestBodyMap.get('RTL_Product_Name__c'));
            System.debug('opportunityHPAP Prod Id----->' + opportunityHPAP.RTL_Product_Name__c);
            System.debug('opportunityHPAP----->' + opportunityHPAP);
            //check exist RTL_External_Ref_ID__c Referral Id
 
            if(opportunityHPAP.RTL_External_Ref_ID__c != null && opportunityHPAP.RTL_External_Ref_ID__c != ''){
                if(opportunityHPAP.RTL_External_Ref_ID__c.startsWith('a2S')){
                    List<Opportunity> checkdupoppty = [SELECT Id,RTL_External_Ref_ID__c FROM Opportunity WHERE RTL_External_Ref_ID__c =: opportunityHPAP.RTL_External_Ref_ID__c];
                    if(checkdupoppty.size() > 0){
                        throw new OtherException ('Insert Failed duplicate External Ref Id.');
                    }
                }else{
                    List<CampaignMember> listcm =  [SELECT Id,CampaignId FROM CampaignMember WHERE Id =: opportunityHPAP.RTL_External_Ref_ID__c OR RTL_Marketing_Code__c =: opportunityHPAP.RTL_External_Ref_ID__c OR RTL_Web_Unique_ID__c =: opportunityHPAP.RTL_External_Ref_ID__c LIMIT 1];
                    if(listcm.size() > 0){
                        opportunityHPAP.CampaignId =listcm[0].CampaignId;
                        opportunityHPAP.RTL_Is_Create_From_Campaign_Member__c = true;
                    }else{
                        throw new OtherException ('External Ref ID not found in Salesforce.');
                    }

                }
            }
            //update oppty field ws name not match with api name
            opportunityHPAP.RTL_Ws_Reason__c = requestBodyMap.containsKey('RTL_Reason__c') ? (String)requestBodyMap.get('RTL_Reason__c') : '';
            opportunityHPAP.Submit_Date__c = requestBodyMap.containsKey('RTL_Request_Date__c') && requestBodyMap.get('RTL_Request_Date__c') != null ? Date.valueOf((String)requestBodyMap.get('RTL_Request_Date__c')) : null;
            opportunityHPAP.Corebank_Approved_Date_Time__c = requestBodyMap.containsKey('RTL_Approved_Date_Time__c') && requestBodyMap.get('RTL_Approved_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Approved_Date_Time__c')+'"', DateTime.class) : null;
            opportunityHPAP.Corebank_Branch_Code__c = requestBodyMap.containsKey('RTL_AO_Group_Code__c') ? (String)requestBodyMap.get('RTL_AO_Group_Code__c') : '';
            opportunityHPAP.Corebank_Branch_Name__c = requestBodyMap.containsKey('RTL_AO_Group_Name__c') ? (String)requestBodyMap.get('RTL_AO_Group_Name__c') : '';
            opportunityHPAP.Corebank_Sales_Manager_Head_Id__c = requestBodyMap.containsKey('RTL_Group_Head_Emp_Id__c') ? (String)requestBodyMap.get('RTL_Group_Head_Emp_Id__c') : '';
            opportunityHPAP.Corebank_Sales_Manager_Head__c = requestBodyMap.containsKey('RTL_Group_Head_Name__c') ? (String)requestBodyMap.get('RTL_Group_Head_Name__c') : '';
            opportunityHPAP.LGS_Ao_Branch__c = requestBodyMap.containsKey('LGS_Ao_Branch') ? (String)requestBodyMap.get('LGS_Ao_Branch') : '';

            insert opportunityHPAP;
            //Check update campaign Member
            String external_ref_Id = '';
            Boolean isUpdateCM = false;
            if(opportunityHPAP.RTL_External_Ref_ID__c != null && opportunityHPAP.RTL_External_Ref_ID__c != ''){
                System.debug('RTL_External_Ref_ID__c----->' + opportunityHPAP.RTL_External_Ref_ID__c);
                if(!opportunityHPAP.RTL_External_Ref_ID__c.startsWith('a2S')){
                    String cm_external_ref_Id = opportunityHPAP.RTL_External_Ref_ID__c;
                    external_ref_Id = cm_external_ref_Id;
                    if(!opportunityHPAP.RTL_External_Ref_ID__c.startsWith('00v')){
                        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE RTL_Marketing_code__c =: opportunityHPAP.RTL_External_Ref_ID__c OR RTL_Web_Unique_ID__c =: opportunityHPAP.RTL_External_Ref_ID__c ORDER BY LASTMODIFIEDDATE DESC LIMIT 1];
                        if(cm.size ()> 0 ){
                            cm_external_ref_Id = cm[0].Id;
                            external_ref_Id = cm_external_ref_Id;
                        }
                    }
                    stampOpptyToCampaignMember(opportunityHPAP.Id,cm_external_ref_Id);
                }
            }
            if(external_ref_Id != null && external_ref_Id != ''){
                CampaignMember CMToUpdate = new CampaignMember();
                CMToUpdate.Id = external_ref_Id;
                List<CampaignMember> validatecm = [SELECT Id,RTL_Contact_Status__c FROM CampaignMember WHERE Id=:external_ref_Id ORDER BY LASTMODIFIEDDATE DESC LIMIT 1];
                if(validatecm.size() > 0){
                    CMToUpdate.RTL_Contact_Status__c = validatecm.get(0).RTL_Contact_Status__c;
                }
                updateCampaignMember(CMToUpdate,requestBodyMap);
            }

            if(opportunityHPAP.RTL_Referral__c != null)
            {
                RTL_Referral__c ref = new RTL_Referral__c();
                ref.Id = opportunityHPAP.RTL_Referral__c;
                ref.RTL_Status__c = 'เปิดใบคำขอเรียบร้อยแล้ว';
                ref.Details_of_Status__c = 'กรุณาดู status ใบคำขอล่าสุดที่โอกาส';
                update ref;
            }

            // stampOpptyToCampaignMember(opportunityHPAP);

            trackMsg += trackingMessage('5', '', (String)opportunityHPAP.get('Id'));

            Response response = responseMsg(
                true, 
                new List<ErrorDetail>{
                    // new ErrorDetail('Account', JSON.serialize(accountCheckInDatabase)),
                    // new ErrorDetail('Opportunity', JSON.serialize(opportunityHPAP))
                }, 
                (Id)opportunityHPAP.get('Id')
            );
            RTL_CampaignUtil.saveToOnlineLog(
                true,
                accountCheckInDatabase != null ? accountCheckInDatabase.Name : '', // customerName
                trackMsg, // Error message
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                (String)opportunityHPAP.get('Id'),
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.CreateOpportunity),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                accountCheckInDatabase,
                startDate,
                Datetime.now() // End datetime
            );

            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        } catch (DmlException e) {
            System.debug('Error : ' + e);
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            trackMsg += trackingMessage('', errorMsg, '');
            Response response = responseMsg(false, new List<ErrorDetail>{ 
                new ErrorDetail(e.getDmlStatusCode(0), errorMsg)
            }, null);
            
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                accountObj != null ? (String)accountObj.get('Name') : '', // customerName
                trackMsg,
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                opportunityHPAP != null ? (String)opportunityHPAP.get('RTL_AL_Refer_No__c') : (String)getValueWithKeyCaseInsensitive(requestBodyMap, 'RTL_AL_Refer_No__c'), // RMId
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.CreateOpportunity),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );

            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        } catch (Exception e) {
            System.debug('Error : ' + e +  ' Line: ' + ' || Line : ' + e.getLineNumber());
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            trackMsg += trackingMessage('', errorMsg, '');
            Response response = responseMsg(false, new List<ErrorDetail>{ 
                new ErrorDetail(e.getTypeName(), errorMsg)
            }, null);
            
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                accountObj != null ? (String)accountObj.get('Name') : '', // customerName
                trackMsg,
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                opportunityHPAP != null ? (String)opportunityHPAP.get('RTL_AL_Refer_No__c') : (String)getValueWithKeyCaseInsensitive(requestBodyMap, 'RTL_AL_Refer_No__c'), // RMId
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.CreateOpportunity),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
            System.debug('response:'+JSON.serialize(response));
            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        }
    }

    private static Opportunity mappingOpportunityFields(Map<String, Object> obj) {
        Map<String, Object> objTemp = new Map<String, Object>();
        for (String field : obj.keySet()) {
            if(field.toLowerCase() != 'rtl_reason__c'){
                objTemp.put(field.toLowerCase(), obj.get(field));
            }
        }
        obj = objTemp;
        Opportunity opportunityObj = new Opportunity();

        if(!checkIsEmpty(getValueWithKeyCaseInsensitive(obj, 'Id'))) {
            opportunityObj.Id = (Id)getValueWithKeyCaseInsensitive(obj, 'Id');
        }
        
        Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        String refId = null;
        // Boolean IsReferralId = false;
        for (String field : obj.keySet()) {
            // if(field == 'id'){
            //     String valueId = String.valueOf(obj.get(field));
            //     if(valueId.startsWith('a2S')){
            //         IsReferralId = true;
            //     }
            // }
            if(sObjectField.containsKey(field)) {
                Schema.DescribeFieldResult dfr = sObjectField.get(field).getDescribe();
                if(!dfr.isFormulaTreatNullNumberAsZero() && dfr.isUpdateable()) {
                    String dfrType = String.valueOf(dfr.getType());
                    String fieldNameAPI = dfr.getName();
                    String value = String.valueOf(obj.get(field));
                    // if(IsReferralId == true && (field == 'rtl_status__c' || field == 'details_of_status__c')){
                    //     if(value == null || new List<String>{'STRING', 'PICKLIST', 'TEXTAREA', 'REFERENCE'}.contains(dfrType)) opportunityObj.put(fieldNameAPI, value);
                    //     else opportunityObj.put(fieldNameAPI, value);
                    // }

                    // if(field != 'rtl_status__c' && field != 'details_of_status__c') {
                        if(new List<String>{'BOOLEAN'}.contains(dfrType)) opportunityObj.put(fieldNameAPI, Boolean.valueOf(value == '1' || value == 'true'));
                        else if(value == null || new List<String>{'STRING', 'PICKLIST', 'TEXTAREA', 'REFERENCE'}.contains(dfrType)) opportunityObj.put(fieldNameAPI, value);
                        else if(new List<String>{'DOUBLE', 'CURRENCY', 'PERCENT'}.contains(dfrType)) opportunityObj.put(fieldNameAPI, Decimal.valueOf(value));
                        else if(new List<String>{'INTEGER'}.contains(dfrType)) opportunityObj.put(fieldNameAPI, Integer.valueOf(value));
                        else if(new List<String>{'DATE'}.contains(dfrType)){
                            if(value != null && value != '') opportunityObj.put(fieldNameAPI, Date.valueOf(value));
                        }
                        else if(new List<String>{'DATETIME'}.contains(dfrType)){
                            if(value != null && value != '') opportunityObj.put(fieldNameAPI, (DateTime)JSON.deserialize('"'+value+'"', DateTime.class));
                        }
                        else opportunityObj.put(fieldNameAPI, value);
    
                        if(field == 'rtl_external_ref_id__c' && value != null){
                            if(value.startsWith('a2S')){
                                System.debug('rtl_external_ref_id__c : ' + value);
                                refId = value;
                            }
                        }
                    // }
                }
            }
        }

        if(refId != null){
            System.debug('refId ' + refId);
            opportunityObj.put('RTL_Referral__c',refId);
            //opportunityObj = convertReferralToOppty(opportunityObj,refId);
        }
        opportunityObj.put('Is_Allow_Edit__c',true);

        //System.debug('Oppty ' + opportunityObj);
        return opportunityObj;
    }

    // private static Opportunity convertReferralToOppty(Opportunity currentobj , String refId){
    //     RTL_Referral__c ref = [SELECT Id,RTL_AL_available_time__c,RTL_AL_car_bought_from__c,RTL_AL_car_brand__c,RTL_AL_car_gear__c,RTL_AL_car_group__c,RTL_AL_car_subtype__c,
    //                                 RTL_AL_car_type__c,RTL_AL_car_year__c,RTL_AL_comment__c,RTL_AL_contact_channel__c,RTL_AL_installment_amount__c,RTL_AL_installment_periods__c,
    //                                 RTL_AL_normal_price__c,RTL_AL_wanted_amount__c,RTL_AL_oa_ref_code__c,RTL_AL_car_plate_no__c,RTL_AL_Interested_Rate__c,RTL_AL_ContactDistrict__c,
    //                                 RTL_AL_ContactSubDistrict__c,RTL_AL_ContactZipcode__c,RTL_AL_ContactProvince__c,RTL_AL_max_set_up_amount__c,RTL_AL_ILA_AMT__c,RTL_AL_REMN_MTH__c,
    //                                 RTL_AL_OFFR_ILA_AMT__c,RTL_AL_OFFR_ILA_MTH__c,RTL_AL_BlueBook__c FROM RTL_Referral__c WHERE Id =: refId LIMIT 1];
        
    //     currentobj.RTL_AL_available_time__c = ref.RTL_AL_available_time__c;
    //     currentobj.RTL_AL_car_bought_from__c = ref.RTL_AL_car_bought_from__c;
    //     currentobj.RTL_AL_car_brand__c = ref.RTL_AL_car_brand__c;
    //     currentobj.RTL_AL_car_gear__c = ref.RTL_AL_car_gear__c;
    //     currentobj.RTL_AL_car_group__c = ref.RTL_AL_car_group__c;
    //     currentobj.RTL_AL_car_subtype__c = ref.RTL_AL_car_subtype__c;
    //     currentobj.RTL_AL_car_type__c = ref.RTL_AL_car_type__c;
    //     currentobj.RTL_AL_car_year__c = ref.RTL_AL_car_year__c;
    //     currentobj.RTL_AL_comment__c = ref.RTL_AL_comment__c;
    //     currentobj.RTL_AL_contact_channel__c = ref.RTL_AL_contact_channel__c;
    //     currentobj.RTL_AL_installment_amount__c = ref.RTL_AL_installment_amount__c;
    //     currentobj.RTL_AL_installment_periods__c = ref.RTL_AL_installment_periods__c;
    //     currentobj.RTL_AL_normal_price__c = ref.RTL_AL_normal_price__c;
    //     currentobj.RTL_AL_wanted_amount__c = ref.RTL_AL_wanted_amount__c;
    //     currentobj.RTL_AL_oa_ref_code__c = ref.RTL_AL_oa_ref_code__c;
    //     currentobj.RTL_AL_car_plate_no__c = ref.RTL_AL_car_plate_no__c;
    //     currentobj.RTL_AL_Interested_Rate__c = ref.RTL_AL_Interested_Rate__c;
    //     currentobj.RTL_AL_ContactDistrict__c = ref.RTL_AL_ContactDistrict__c;
    //     currentobj.RTL_AL_ContactSubDistrict__c = ref.RTL_AL_ContactSubDistrict__c;
    //     currentobj.RTL_AL_ContactZipcode__c = ref.RTL_AL_ContactZipcode__c;
    //     currentobj.RTL_AL_ContactProvince__c = ref.RTL_AL_ContactProvince__c;
    //     currentobj.RTL_AL_max_set_up_amount__c = ref.RTL_AL_max_set_up_amount__c;
    //     currentobj.RTL_AL_ILA_AMT__c = ref.RTL_AL_ILA_AMT__c;
    //     currentobj.RTL_AL_REMN_MTH__c = ref.RTL_AL_REMN_MTH__c;
    //     currentobj.RTL_AL_OFFR_ILA_AMT__c = ref.RTL_AL_OFFR_ILA_AMT__c;
    //     currentobj.RTL_AL_OFFR_ILA_MTH__c = ref.RTL_AL_OFFR_ILA_MTH__c;
    //     currentobj.RTL_AL_BlueBook__c = ref.RTL_AL_BlueBook__c;
    //     currentobj.Is_Allow_Edit__c = true;
    //     System.debug('Converted Referral to Oppty ' + currentobj);
    //     return currentobj;
    // }

    @HttpPatch
    global static SCSReqRes httpPatchWebservice() {
        Savepoint sp;
        Map<String, String> requestHeader = RestContext.request.headers;
        RestRequest request = RestContext.request;
        Datetime startDate = Datetime.now();
        String privateKey = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
        String resEncrypt;
        String resDecrypt;

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        Opportunity opportunityReferUpdate;
        RTL_Referral__c referUpdate = new RTL_Referral__c();
        CampaignMember campaignMemberUpdate = new CampaignMember();

        Account accountObj;
        Account accountCheckInDatabase;
        
        Response response;

        try {
            sp = Database.setSavepoint();
            resEncrypt = request.requestBody.toString();
            // if(requestHeader.containsKey('For-Test') ? requestHeader.get('For-Test') == 'DEV' : false) {
            //     resEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(resEncrypt, privateKey);
            // }
            resDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(resEncrypt, privateKey);
            System.debug('resDecrypt:'+resDecrypt);
            requestBodyMap = resDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(resDecrypt) : new Map<String, Object>();
                
            
            // opportunityReferUpdate = mappingOpportunityFields(requestBodyMap);
            List<String> fieldsMissing = new List<String>();
            for (String fieldRequired : new List<String>{ 'Id', 'StageName' }) {
                if(checkIsEmpty(requestBodyMap.get(fieldRequired))) {
                    fieldsMissing.add(String.format('{0}', new List<Object>{ fieldRequired }));
                }
            }
            System.debug('Id :'+ (String)requestBodyMap.get('Id'));
            
            Boolean isSuccess = fieldsMissing.size() == 0 ? true : false;
            response = responseMsg(
                isSuccess, 
                isSuccess ? new List<ErrorDetail>{} : 
                    new List<ErrorDetail>{
                        new ErrorDetail(
                            'REQUIRED_FIELD_MISSING', 
                            String.format('Required fields are missing => [{0}]', new List<String>{ String.join(fieldsMissing, ', ') })
                        )
                    }, 
                    !checkIsEmpty(requestBodyMap) ? (String)requestBodyMap.get('Id') : (Id)getValueWithKeyCaseInsensitive(requestBodyMap, 'Id')
            );
            String errorMsg = (!checkIsEmpty(response.getErrorMessage()) ? response.getErrorMessage() : AbstractCoreClass.getValuesWithRegex(resDecrypt, new List<String>{ 'Message' }));
            System.debug('isSuccess : ' + isSuccess);
            if(isSuccess)
            {
                if(((String)requestBodyMap.get('Id')).startsWith('a2S'))
                {
                    referUpdate.Id = (String)requestBodyMap.get('Id');
                    referUpdate.RTL_Ws_Stage__c = requestBodyMap.containsKey('StageName') ? (String)requestBodyMap.get('StageName') : '';
                    referUpdate.RTL_Status__c = requestBodyMap.containsKey('RTL_Status__c') ? (String)requestBodyMap.get('RTL_Status__c') : '';
                    referUpdate.Details_of_Status__c = requestBodyMap.containsKey('Details_of_Status__c') ? (String)requestBodyMap.get('Details_of_Status__c') : '';
                    referUpdate.RTL_AL_Refer_No__c = requestBodyMap.containsKey('RTL_AL_Refer_No__c') ? (String)requestBodyMap.get('RTL_AL_Refer_No__c') : '';
                    referUpdate.RTL_AL_Req_No1__c = requestBodyMap.containsKey('RTL_AL_Req_No1__c') ? (String)requestBodyMap.get('RTL_AL_Req_No1__c') : '';
                    referUpdate.RTL_AL_Req_No2__c = requestBodyMap.containsKey('RTL_AL_Req_No2__c') ? (String)requestBodyMap.get('RTL_AL_Req_No2__c') : '';
                    referUpdate.Corebank_Emp_Id__c = requestBodyMap.containsKey('Corebank_Emp_Id__c') ? (String)requestBodyMap.get('Corebank_Emp_Id__c') : '';
                    referUpdate.Corebank_Emp_Name__c = requestBodyMap.containsKey('Corebank_Emp_Name__c') ? (String)requestBodyMap.get('Corebank_Emp_Name__c') : '';
                    referUpdate.Corebank_Emp_Phone_No__c = requestBodyMap.containsKey('Corebank_Emp_Phone_No__c') ? (String)requestBodyMap.get('Corebank_Emp_Phone_No__c') : '';
                    referUpdate.RTL_Hub_Code__c = requestBodyMap.containsKey('RTL_Hub_Code__c') ? (String)requestBodyMap.get('RTL_Hub_Code__c') : '';
                    referUpdate.RTL_Hub_Name__c = requestBodyMap.containsKey('RTL_Hub_Name__c') ? (String)requestBodyMap.get('RTL_Hub_Name__c') : '';
                    referUpdate.RTL_Account_No__c = requestBodyMap.containsKey('RTL_Account_No__c') ? (String)requestBodyMap.get('RTL_Account_No__c') : '';
                    referUpdate.HPAP_Status_Code__c = requestBodyMap.containsKey('HPAP_Status_Code__c') ? (String)requestBodyMap.get('HPAP_Status_Code__c') : '';
                    referUpdate.HPAP_Reason_Code__c = requestBodyMap.containsKey('HPAP_Reason_Code__c') ? (String)requestBodyMap.get('HPAP_Reason_Code__c') : '';
                    referUpdate.HPAP_Reason_Description__c = requestBodyMap.containsKey('HPAP_Reason_Description__c') ? (String)requestBodyMap.get('HPAP_Reason_Description__c') : '';
                    // Update From LGS
                    // referUpdate.RTL_Status_Approve__c = requestBodyMap.containsKey('RTL_Status_Approve__c') ? (String)requestBodyMap.get('RTL_Status_Approve__c') : '';
                    referUpdate.RTL_Contact_Status__c = requestBodyMap.containsKey('RTL_Contact_Status__c') ? (String)requestBodyMap.get('RTL_Contact_Status__c') : '';
                    referUpdate.RTL_Ws_Reason__c = requestBodyMap.containsKey('RTL_Reason__c') ? (String)requestBodyMap.get('RTL_Reason__c') : '';

                    referUpdate.RTL_Refer_Date__c = requestBodyMap.containsKey('RTL_Refer_Date__c') && requestBodyMap.get('RTL_Refer_Date__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Refer_Date__c')+'"', DateTime.class) : null;
                    referUpdate.Corebank_Branch_Code__c = requestBodyMap.containsKey('RTL_AO_Group_Code__c') ? (String)requestBodyMap.get('RTL_AO_Group_Code__c') : '';
                    referUpdate.Corebank_Branch_Name__c = requestBodyMap.containsKey('RTL_AO_Group_Name__c') ? (String)requestBodyMap.get('RTL_AO_Group_Name__c') : '';
                    referUpdate.Corebank_Sales_Manager_Head_Id__c = requestBodyMap.containsKey('RTL_Group_Head_Emp_Id__c') ? (String)requestBodyMap.get('RTL_Group_Head_Emp_Id__c') : '';
                    referUpdate.Corebank_Sales_Manager_Head__c = requestBodyMap.containsKey('RTL_Group_Head_Name__c') ? (String)requestBodyMap.get('RTL_Group_Head_Name__c') : '';
                    referUpdate.RTL_Product_Campaign_Code__c = requestBodyMap.containsKey('RTL_Product_Campaign_Code__c') ? (String)requestBodyMap.get('RTL_Product_Campaign_Code__c') : '';
                    referUpdate.RTL_Product_Campaign_Name__c = requestBodyMap.containsKey('RTL_Product_Campaign_Name__c') ? (String)requestBodyMap.get('RTL_Product_Campaign_Name__c') : '';
                    referUpdate.RTL_Dealer_Code__c = requestBodyMap.containsKey('RTL_Dealer_Code__c') ? (String)requestBodyMap.get('RTL_Dealer_Code__c') : '';
                    referUpdate.RTL_Dealer_Name__c = requestBodyMap.containsKey('RTL_Dealer_Name__c') ? (String)requestBodyMap.get('RTL_Dealer_Name__c') : '';
                    referUpdate.RTL_Stage_Name_Date_Time__c = requestBodyMap.containsKey('RTL_Stage_Name_Date_Time__c') && requestBodyMap.get('RTL_Stage_Name_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Stage_Name_Date_Time__c')+'"', DateTime.class) : null;
                    
                    stampReferToCampaignMember(referUpdate.Id);
                    update referUpdate;
                }
                else if(((String)requestBodyMap.get('Id')).startsWith('00v')){
                    campaignMemberUpdate.Id = (String)requestBodyMap.get('Id');
                    List<CampaignMember> validatecm = [SELECT Id,RTL_Contact_Status__c,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c FROM CampaignMember WHERE Id =:campaignMemberUpdate.Id ORDER BY LASTMODIFIEDDATE DESC];
                    if(validatecm.size() >0){
                        campaignMemberUpdate.RTL_Contact_Status__c = validatecm.get(0).RTL_Contact_Status__c;
                    }
                    updateCampaignMember(campaignMemberUpdate,requestBodyMap);
                }
                else if(((String)requestBodyMap.get('Id')).startsWith('006')){
                    System.debug('Update by Oppty Id');
                    if(requestBodyMap.containsKey('Account')){
                        accountObj = requestBodyMap.containsKey('Account') ? 
                        (Account)JSON.deserialize(JSON.serialize(requestBodyMap.get('Account')), Account.class) : null;
    
                        List<String> fieldsQuery = new List<String>{ 'Name', 'TMB_Customer_ID_PE__c', 'Core_Banking_Suggested_Segment__c' };
                        fieldsQuery.addAll(accountFields);
                        String accountFieldsMerge = String.join(fieldsQuery, ',');
                        String queryRMID = String.format('SELECT {0} FROM Account WHERE {1}', new List<Object>{
                            accountFieldsMerge,
                            passValueCondition('TMB_Customer_ID_PE__c', accountObj.get('TMB_Customer_ID_PE__c'))
                        });
    
                        String searchKey =  String.join(new List<Object>{
                            assignDoubleQuote(setSearch((String)accountObj.get('First_name_PE__c'))),
                            assignDoubleQuote(setSearch((String)accountObj.get('Last_name_PE__c'))),
                            assignDoubleQuote(setSearch((String)accountObj.get('ID_Type_PE__c'))),
                            assignDoubleQuote(setSearch((String)accountObj.get('ID_Number_PE__c'))),
                            assignDoubleQuote(setSearch((String)accountObj.get('Mobile_Number_PE__c')))
                        }, ' OR ');
                        searchKey = '{' + searchKey + '}';
                        String queryPersonInfo = String.format('FIND {0} IN ALL FIELDS RETURNING Account({1})', new List<String>{
                            searchKey,
                            accountFieldsMerge
                        });
                        
                        // find customer existing 
                        List<SObject> sObjectList;
                        if(!checkIsEmpty(accountObj.get('TMB_Customer_ID_PE__c'))) {
                            sObjectList = (List<SObject>)Database.query(queryRMID);
                            accountCheckInDatabase = !sObjectList.isEmpty() ? (Account)sObjectList.get(0) : null;
                        }
                        if (accountCheckInDatabase == null || checkIsEmpty(accountObj.get('TMB_Customer_ID_PE__c'))) {
                            List<String> temp = new List<String>();
                            for (String fieldName : accountFields) {
                                temp.add(String.format('{0}: {1}', new List<Object>{
                                    fieldName, accountObj.get(fieldName)
                                }));
                            }
                            sObjectList = ((List<List<SObject>>)Search.query(queryPersonInfo)).get(0);
                            for (Account account : (List<Account>)sObjectList) {
                                // account.get('Email_Address_PE__c') == accountObj.get('Email_Address_PE__c') &&
                                // account.get('First_name_PE__c') == accountObj.get('First_name_PE__c') &&
                                // account.get('Last_name_PE__c') == accountObj.get('Last_name_PE__c') &&
                                // account.get('Mobile_Number_PE__c') == accountObj.get('Mobile_Number_PE__c')  &&
                                if(account.get('ID_Type_PE__c') == accountObj.get('ID_Type_PE__c') &&
                                    String.valueOf(account.get('ID_Number_PE__c')).contains((String)accountObj.get('ID_Number_PE__c'))) {
                                    accountCheckInDatabase = account;
                                    break;
                                }
                            }
                        }
                        
                        // TODO: Create customer prospect 
                        if(accountCheckInDatabase == null) {
                            System.debug('New Customer');
                            accountCheckInDatabase = new Account(
                                Name = accountObj.get('First_name_PE__c') + ' ' + accountObj.get('Last_name_PE__c'),
                                Email_Address_PE__c = (String)accountObj.get('Email_Address_PE__c'),
                                First_name_PE__c = (String)accountObj.get('First_name_PE__c'),
                                Last_name_PE__c = (String)accountObj.get('Last_name_PE__c'),
                                ID_Type_PE__c = (String)accountObj.get('ID_Type_PE__c'),
                                ID_Number_PE__c = (String)accountObj.get('ID_Number_PE__c'),
                                Mobile_Number_PE__c = (String)accountObj.get('Mobile_Number_PE__c'),
                                // TMB_Customer_ID_PE__c = (String)accountObj.get('TMB_Customer_ID_PE__c'),
                                Primary_Address_Line_2_PE__c = (String)accountObj.get('Primary_Address_Line_2_PE__c'),
                                Primary_Address_Line_3_PE__c = (String)accountObj.get('Primary_Address_Line_3_PE__c'),
                                Zip_Code_Primary_PE__c = (String)accountObj.get('Zip_Code_Primary_PE__c'),
                                Province_Primary_PE__c = (String)accountObj.get('Province_Primary_PE__c'),
                                RecordTypeId = retailProspectRecordTypeId
                            );
                            insert accountCheckInDatabase;
                        }
                    }
                   
                    // opportunityHPAP.AccountId = accountCheckInDatabase.Id;
                    opportunityReferUpdate = mappingOpportunityFields(requestBodyMap);
                    System.debug('Customer : ' + accountCheckInDatabase);
                    if(accountCheckInDatabase != null && accountCheckInDatabase.Id != null){
                        opportunityReferUpdate.AccountId = accountCheckInDatabase.Id;
                    }

                    System.debug('Prod Name : ' + opportunityReferUpdate.RTL_Product_Name__c);
                    stampOpptyToCampaignMember(opportunityReferUpdate.Id,null);
                    // opportunityReferUpdate.RTL_Contact_Status__c = requestBodyMap.containsKey('RTL_Contact_Status__c') ? (String)requestBodyMap.get('RTL_Contact_Status__c') : '';
                    opportunityReferUpdate.RTL_Ws_Reason__c = requestBodyMap.containsKey('RTL_Reason__c') ? (String)requestBodyMap.get('RTL_Reason__c') : '';
                    opportunityReferUpdate.Submit_Date__c = requestBodyMap.containsKey('RTL_Request_Date__c') && requestBodyMap.get('RTL_Request_Date__c') != null? Date.valueOf((String)requestBodyMap.get('RTL_Request_Date__c')) : null;
                    opportunityReferUpdate.Corebank_Approved_Date_Time__c = requestBodyMap.containsKey('RTL_Approved_Date_Time__c') && requestBodyMap.get('RTL_Approved_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Approved_Date_Time__c')+'"', DateTime.class) : null;
                    opportunityReferUpdate.Corebank_Approved_Date_Time__c = requestBodyMap.containsKey('RTL_Approved_Date_Time__c') && requestBodyMap.get('RTL_Approved_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Approved_Date_Time__c')+'"', DateTime.class) : null;
                    opportunityReferUpdate.Corebank_Branch_Code__c = requestBodyMap.containsKey('RTL_AO_Group_Code__c') ? (String)requestBodyMap.get('RTL_AO_Group_Code__c') : '';
                    opportunityReferUpdate.Corebank_Branch_Name__c = requestBodyMap.containsKey('RTL_AO_Group_Name__c') ? (String)requestBodyMap.get('RTL_AO_Group_Name__c') : '';
                    opportunityReferUpdate.Corebank_Sales_Manager_Head_Id__c = requestBodyMap.containsKey('RTL_Group_Head_Emp_Id__c') ? (String)requestBodyMap.get('RTL_Group_Head_Emp_Id__c') : '';
                    opportunityReferUpdate.Corebank_Sales_Manager_Head__c = requestBodyMap.containsKey('RTL_Group_Head_Name__c') ? (String)requestBodyMap.get('RTL_Group_Head_Name__c') : '';

                    update opportunityReferUpdate;
                }else{
                    String mktcodeOrWebunique = ((String)requestBodyMap.get('Id'));
                    System.debug('mktcodeOrWebunique Id : ' + mktcodeOrWebunique );

                    List<CampaignMember> validatecm = [SELECT Id,RTL_Contact_Status__c,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c FROM CampaignMember WHERE RTL_Marketing_Code__c =: mktcodeOrWebunique OR RTL_Web_Unique_ID__c =: mktcodeOrWebunique ORDER BY LASTMODIFIEDDATE DESC];
                    //Update CampaignMember when Id is Marketing Code, Web Unique Id
                    if(validatecm.size() > 0){
                        System.debug('CampaignMember Id : ' + validatecm.get(0).Id );
                        campaignMemberUpdate.Id = validatecm.get(0).Id;
                        campaignMemberUpdate.RTL_Contact_Status__c = validatecm.get(0).RTL_Contact_Status__c;
                        updateCampaignMember(campaignMemberUpdate,requestBodyMap);                      
                    }else{
                        System.debug('Invalid Id : ' + ((String)requestBodyMap.get('Id')));
                        CalloutException e = new CalloutException();
                        e.setMessage('Invalid Id : ' + ((String)requestBodyMap.get('Id')));
                        throw e;
                    }
                }
            
            } 
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                '', // customerName
                isSuccess ? '' : errorMsg, // Error message
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                (String)requestBodyMap.get('Id'), // RMId
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.UpdateRefer),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null, // Account
                startDate,
                Datetime.now() // End datetime
            );

            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        } catch (DmlException e) {
            System.debug('Update refer status Error : ' + e.getMessage() + ' || Line : ' + e.getLineNumber());
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            response = responseMsg(
                false, 
                new List<ErrorDetail>{ 
                    new ErrorDetail(e.getDmlStatusCode(0), errorMsg)
                }, 
                null
            );
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                errorMsg,
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                !checkIsEmpty(requestBodyMap) ? (String)requestBodyMap.get('Id') : (String)getValueWithKeyCaseInsensitive(requestBodyMap, 'Id'), // RMId
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.UpdateRefer),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null, // Account
                startDate,
                Datetime.now() // End datetime
            );

            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        } catch (Exception e) {
            System.debug('Update refer status Error : ' + e.getMessage() + ' || ' + e.getLineNumber() );
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            response = responseMsg(
                false, 
                new List<ErrorDetail>{ 
                    new ErrorDetail(e.getTypeName(), errorMsg)
                }, 
                null
            );
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                errorMsg,
                requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', // msLogId
                UserInfo.getName(),
                !checkIsEmpty(requestBodyMap) ? (String)requestBodyMap.get('Id') : (String)getValueWithKeyCaseInsensitive(requestBodyMap, 'Id'), // RMId
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.UpdateRefer),
                AbstractCoreClass.serializePrettyString(resDecrypt != null ? resDecrypt : resEncrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null, // Account
                startDate,
                Datetime.now() // End datetime
            );

            return returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), privateKey));
        }
    }
    public static void updateCampaignMember (CampaignMember campaignMemberUpdate, Map<String, Object> requestBodyMap){
        if(campaignMemberUpdate.Id != null){
            // if(requestBodyMap.containsKey('HPAP_Reason_Description__c') && (String)requestBodyMap.get('HPAP_Reason_Description__c') != null) campaignMemberUpdate.HPAP_Reason_Description_1__c  = (String)requestBodyMap.get('HPAP_Reason_Description__c');
            // if(requestBodyMap.containsKey('HPAP_Reason_Code__c') && (String)requestBodyMap.get('HPAP_Reason_Code__c') != null) campaignMemberUpdate.HPAP_Reason_Code_1__c  = (String)requestBodyMap.get('HPAP_Reason_Code__c');
            // if(requestBodyMap.containsKey('HPAP_Status_Code__c') && (String)requestBodyMap.get('HPAP_Status_Code__c') != null) campaignMemberUpdate.HPAP_Status_Code_1__c  = (String)requestBodyMap.get('HPAP_Status_Code__c');
            // if(requestBodyMap.containsKey('RTL_Account_No__c') && (String)requestBodyMap.get('RTL_Account_No__c') != null) campaignMemberUpdate.RTL_Account_No_1__c  = (String)requestBodyMap.get('RTL_Account_No__c');
            // if(requestBodyMap.containsKey('RTL_Hub_Name__c') && (String)requestBodyMap.get('RTL_Hub_Name__c') != null) campaignMemberUpdate.RTL_Hub_Name_1__c  = (String)requestBodyMap.get('RTL_Hub_Name__c');
            // if(requestBodyMap.containsKey('RTL_Hub_Code__c') && (String)requestBodyMap.get('RTL_Hub_Code__c') != null) campaignMemberUpdate.RTL_Hub_Code_1__c  = (String)requestBodyMap.get('RTL_Hub_Code__c');
            // if(requestBodyMap.containsKey('Corebank_Emp_Phone_No__c') && (String)requestBodyMap.get('Corebank_Emp_Phone_No__c') != null) campaignMemberUpdate.Corebank_Emp_Phone_No_1__c  = (String)requestBodyMap.get('Corebank_Emp_Phone_No__c');
            // if(requestBodyMap.containsKey('Corebank_Emp_Name__c') && (String)requestBodyMap.get('Corebank_Emp_Name__c') != null) campaignMemberUpdate.Corebank_Emp_Name_1__c  = (String)requestBodyMap.get('Corebank_Emp_Name__c');
            // if(requestBodyMap.containsKey('Corebank_Emp_Id__c') && (String)requestBodyMap.get('Corebank_Emp_Id__c') != null) campaignMemberUpdate.Corebank_Emp_Id_1__c  = (String)requestBodyMap.get('Corebank_Emp_Id__c');
            // if(requestBodyMap.containsKey('Details_of_Status__c') && (String)requestBodyMap.get('Details_of_Status__c') != null) campaignMemberUpdate.Details_of_Status_1__c  = (String)requestBodyMap.get('Details_of_Status__c');    
            // if(requestBodyMap.containsKey('RTL_Reason_Lost__c') && (String)requestBodyMap.get('RTL_Reason_Lost__c') != null) campaignMemberUpdate.RTL_Reason_Lost__c  = (String)requestBodyMap.get('RTL_Reason_Lost__c');
            // if(requestBodyMap.containsKey('StageName') && (String)requestBodyMap.get('StageName') != null) campaignMemberUpdate.RTL_Stage_1__c  = (String)requestBodyMap.get('StageName');
            // if(requestBodyMap.containsKey('RTL_Status__c') && (String)requestBodyMap.get('RTL_Status__c') != null) campaignMemberUpdate.RTL_Status_1__c  = (String)requestBodyMap.get('RTL_Status__c');
            // if(requestBodyMap.containsKey('RTL_AL_Req_No1__c') && (String)requestBodyMap.get('RTL_AL_Req_No1__c') != null) campaignMemberUpdate.RTL_AL_Req_No1_1__c  = (String)requestBodyMap.get('RTL_AL_Req_No1__c');
            // if(requestBodyMap.containsKey('RTL_AL_Req_No2__c') && (String)requestBodyMap.get('RTL_AL_Req_No2__c') != null) campaignMemberUpdate.RTL_AL_Req_No2_1__c  = (String)requestBodyMap.get('RTL_AL_Req_No2__c');
            // if(requestBodyMap.containsKey('RTL_AL_Refer_No__c') && (String)requestBodyMap.get('RTL_AL_Refer_No__c') != null) campaignMemberUpdate.RTL_AL_Refer_No_1__c  = (String)requestBodyMap.get('RTL_AL_Refer_No__c');
            campaignMemberUpdate.HPAP_Reason_Description_1__c = requestBodyMap.containsKey('HPAP_Reason_Description__c') ? (String)requestBodyMap.get('HPAP_Reason_Description__c') : '';
            campaignMemberUpdate.HPAP_Reason_Code_1__c = requestBodyMap.containsKey('HPAP_Reason_Code__c') ? (String)requestBodyMap.get('HPAP_Reason_Code__c') : '';
            campaignMemberUpdate.HPAP_Status_Code_1__c = requestBodyMap.containsKey('HPAP_Status_Code__c') ? (String)requestBodyMap.get('HPAP_Status_Code__c') : '';
            campaignMemberUpdate.RTL_Account_No_1__c = requestBodyMap.containsKey('RTL_Account_No__c') ? (String)requestBodyMap.get('RTL_Account_No__c') : '';
            campaignMemberUpdate.RTL_Hub_Name_1__c = requestBodyMap.containsKey('RTL_Hub_Name__c') ? (String)requestBodyMap.get('RTL_Hub_Name__c') : '';
            campaignMemberUpdate.RTL_Hub_Code_1__c = requestBodyMap.containsKey('RTL_Hub_Code__c') ? (String)requestBodyMap.get('RTL_Hub_Code__c') : '';
            campaignMemberUpdate.Corebank_Emp_Phone_No_1__c = requestBodyMap.containsKey('Corebank_Emp_Phone_No__c') ? (String)requestBodyMap.get('Corebank_Emp_Phone_No__c') : '';
            campaignMemberUpdate.Corebank_Emp_Name_1__c = requestBodyMap.containsKey('Corebank_Emp_Name__c') ? (String)requestBodyMap.get('Corebank_Emp_Name__c') : '';
            campaignMemberUpdate.Corebank_Emp_Id_1__c = requestBodyMap.containsKey('Corebank_Emp_Id__c') ? (String)requestBodyMap.get('Corebank_Emp_Id__c') : '';
            campaignMemberUpdate.Details_of_Status_1__c = requestBodyMap.containsKey('Details_of_Status__c') ? (String)requestBodyMap.get('Details_of_Status__c') : '';
            campaignMemberUpdate.RTL_Reason_Lost__c = requestBodyMap.containsKey('RTL_Reason_Lost__c') ? (String)requestBodyMap.get('RTL_Reason_Lost__c') : '';
            campaignMemberUpdate.RTL_Stage_1__c = requestBodyMap.containsKey('StageName') ? (String)requestBodyMap.get('StageName') : '';
            campaignMemberUpdate.RTL_Status_1__c = requestBodyMap.containsKey('RTL_Status__c') ? (String)requestBodyMap.get('RTL_Status__c') : '';
            campaignMemberUpdate.RTL_AL_Req_No1_1__c = requestBodyMap.containsKey('RTL_AL_Req_No1__c') ? (String)requestBodyMap.get('RTL_AL_Req_No1__c') : '';
            campaignMemberUpdate.RTL_AL_Req_No2_1__c = requestBodyMap.containsKey('RTL_AL_Req_No2__c') ? (String)requestBodyMap.get('RTL_AL_Req_No2__c') : '';
            campaignMemberUpdate.RTL_AL_Refer_No_1__c = requestBodyMap.containsKey('RTL_AL_Refer_No__c') ? (String)requestBodyMap.get('RTL_AL_Refer_No__c') : '';
            //Update From LGS
            if(campaignMemberUpdate.RTL_Contact_Status__c == 'New' || campaignMemberUpdate.RTL_Contact_Status__c == 'Uncontact'){
                campaignMemberUpdate.RTL_Contact_Status__c = requestBodyMap.containsKey('RTL_Contact_Status__c') ? (String)requestBodyMap.get('RTL_Contact_Status__c') : '';
                campaignMemberUpdate.RTL_Reason__c = requestBodyMap.containsKey('RTL_Reason__c') ? (String)requestBodyMap.get('RTL_Reason__c') : '';
            }
            campaignMemberUpdate.RTL_Status_Approve_1__c = requestBodyMap.containsKey('RTL_Status_Approve__c') ? (String)requestBodyMap.get('RTL_Status_Approve__c') : '';

            campaignMemberUpdate.RTL_Refer_Date_1__c = requestBodyMap.containsKey('RTL_Refer_Date__c') && requestBodyMap.get('RTL_Refer_Date__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Refer_Date__c')+'"', DateTime.class) : null;
            campaignMemberUpdate.Corebank_Branch_Code_1__c = requestBodyMap.containsKey('RTL_AO_Group_Code__c') ? (String)requestBodyMap.get('RTL_AO_Group_Code__c') : '';
            campaignMemberUpdate.Corebank_Branch_Name_1__c = requestBodyMap.containsKey('RTL_AO_Group_Name__c') ? (String)requestBodyMap.get('RTL_AO_Group_Name__c') : '';
            campaignMemberUpdate.Corebank_Sales_Manager_Head_Id_1__c = requestBodyMap.containsKey('RTL_Group_Head_Emp_Id__c') ? (String)requestBodyMap.get('RTL_Group_Head_Emp_Id__c') : '';
            campaignMemberUpdate.Corebank_Sales_Manager_Head_1__c = requestBodyMap.containsKey('RTL_Group_Head_Name__c') ? (String)requestBodyMap.get('RTL_Group_Head_Name__c') : '';
            campaignMemberUpdate.RTL_Request_Hub_Code_1__c = requestBodyMap.containsKey('RTL_Request_Hub_Code__c') ? (String)requestBodyMap.get('RTL_Request_Hub_Code__c') : '';
            campaignMemberUpdate.RTL_Request_Hub_Name_1__c = requestBodyMap.containsKey('RTL_Request_Hub_Name__c') ? (String)requestBodyMap.get('RTL_Request_Hub_Name__c') : '';
            campaignMemberUpdate.Corebank_Approved_Date_Time_1__c = requestBodyMap.containsKey('RTL_Approved_Date_Time__c') && requestBodyMap.get('RTL_Approved_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Approved_Date_Time__c')+'"', DateTime.class) : null;
            campaignMemberUpdate.RTL_Product_Campaign_Code_1__c = requestBodyMap.containsKey('RTL_Product_Campaign_Code__c') ? (String)requestBodyMap.get('RTL_Product_Campaign_Code__c') : '';
            campaignMemberUpdate.RTL_Product_Campaign_Name_1__c = requestBodyMap.containsKey('RTL_Product_Campaign_Name__c') ? (String)requestBodyMap.get('RTL_Product_Campaign_Name__c') : '';
            campaignMemberUpdate.RTL_Dealer_Code_1__c = requestBodyMap.containsKey('RTL_Dealer_Code__c') ? (String)requestBodyMap.get('RTL_Dealer_Code__c') : '';
            campaignMemberUpdate.RTL_Dealer_Name_1__c = requestBodyMap.containsKey('RTL_Dealer_Name__c') ? (String)requestBodyMap.get('RTL_Dealer_Name__c') : '';
            campaignMemberUpdate.RTL_Stage_Name_Date_Time_1__c = requestBodyMap.containsKey('RTL_Stage_Name_Date_Time__c') && requestBodyMap.get('RTL_Stage_Name_Date_Time__c') != null ? (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Stage_Name_Date_Time__c')+'"', DateTime.class) : null;
            campaignMemberUpdate.RTL_Submit_Date_1__c = requestBodyMap.containsKey('RTL_Request_Date__c') && requestBodyMap.get('RTL_Request_Date__c') != null ? Date.valueOf((String)requestBodyMap.get('RTL_Request_Date__c')) : null;
            // Datetime.valueof((String.valueOf(requestBodyMap.get('RTL_Stage_Name_Date_Time__c'))).replace('T', ' ')).addYears(543);
            // (DateTime)JSON.deserialize('"'+requestBodyMap.get('RTL_Refer_Date__c')+'"'
            campaignMemberUpdate.RTL_isBatchUpdateCampaignMember__c = true;
            update campaignMemberUpdate;
        }
    }
    //--- CR AL Re-org Long Term ---
    public static void stampOpptyToCampaignMember (Id opptyId, String cmId)
    {    
 
        Opportunity opportunityHPAP = [SELECT Id,RTL_Product_Name__c,RTL_Referral__c,Corebank_Emp_Id__c,Corebank_Emp_Name__c,RTL_Status__c,Details_of_Status__c,StageName,RTL_External_Ref_ID__c FROM Opportunity WHERE Id =: opptyId LIMIT 1];
        System.debug('opportunityHPAP ID : ' + opportunityHPAP.Id);
        System.debug('opportunityHPAP RTL_Product_Name__c : ' + opportunityHPAP.RTL_Product_Name__c);
        System.debug('opportunityHPAP RTL_Referral__c : ' + opportunityHPAP.RTL_Referral__c);
        Set<String> existprodList = new Set<String>();
        if(!checkIsEmpty(opportunityHPAP.RTL_Product_Name__c) && !checkIsEmpty(opportunityHPAP.RTL_Referral__c) && cmId == null)
        {
            System.debug('Check campaignMember!');
            Boolean isUpdateCM = false;
            List<RTL_Referral__c> ref = [SELECT Id,RTL_Campaign_Member__c FROM RTL_Referral__c WHERE Id =: opportunityHPAP.RTL_Referral__c LIMIT 1];
            List<CampaignMember> campaignMem = [SELECT Id,RTL_Marketing_Code__c,RTL_Campaign_Product_1__c,RTL_Campaign_Product_2__c,RTL_Campaign_Product_3__c,RTL_Campaign_Product_4__c,RTL_Campaign_Product_5__c,
                                                RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,RTL_OfferResult_Product_5__c,
                                                RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c ,
                                                RTL_Referral_ID_1__c,RTL_Referral_ID_2__c,RTL_Referral_ID_3__c,RTL_Referral_ID_4__c,RTL_Referral_ID_5__c 
                                                FROM CampaignMember WHERE Id =: ref.get(0).RTL_Campaign_Member__c LIMIT 1];
            List<Cross_Sell_Product__c> crossSell = [SELECT Id,CampaignMemberId__c,Campaign_Product__c,RTL_OfferResult_Product__c,OpportunityId__c FROM Cross_Sell_Product__c WHERE CampaignMemberId__c =: ref.get(0).RTL_Campaign_Member__c ORDER BY CreatedDate DESC];
            Map<Id,Cross_Sell_Product__c> csMap = new Map<Id,Cross_Sell_Product__c>();
            for(Integer i = 1; i <= 5; i++)
            {
                if(campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c') != null){
                    existprodList.add(String.valueOf(campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c')));
                }
            }
            if(crossSell.size() > 0 && !existprodList.contains(String.valueOf(opportunityHPAP.Id)))
            {
                for(Cross_Sell_Product__c cs :crossSell)
                {
                    existprodList.add(String.valueOf(cs.OpportunityId__c));
                    csMap.put(cs.Campaign_Product__c,cs);
                }
            }
            if(campaignMem.size() > 0 && !existprodList.contains(String.valueOf(opportunityHPAP.Id))){

                for(Integer i = 1; i <= 5; i++)
                {
                    System.debug('Campaign Product Name : ' + campaignMem.get(0).get('RTL_Campaign_Product_'+i+'__c'));
                    System.debug('Campaign Offer Result : ' + campaignMem.get(0).get('RTL_OfferResult_Product_'+i+'__c'));
                    System.debug('Campaign Check Related oppty ' + i + ' : '+ campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c'));

                    if(opportunityHPAP.RTL_Product_Name__c == campaignMem.get(0).get('RTL_Campaign_Product_'+i+'__c') && campaignMem.get(0).get('RTL_OfferResult_Product_'+i+'__c') == 'Referred' 
                        && campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c') == null )
                    {
                        System.debug('Update : ' + 'RTL_RelatedOpportunity_'+i+'__c || ' + opportunityHPAP.Id);
                        campaignMem.get(0).put('RTL_RelatedOpportunity_'+i+'__c',opportunityHPAP.Id);
                        campaignMem.get(0).put('RTL_Referral_ID_'+i+'__c',opportunityHPAP.RTL_External_Ref_ID__c);
                        isUpdateCM = true;
                        break;
                    }
                }
            }

            if(isUpdateCM)
            {
                campaignMem[0].RTL_isBatchUpdateCampaignMember__c = true;
                update campaignMem;
                // opportunityHPAP.Marketing_Code__c = campaignMem.get(0).RTL_Marketing_Code__c;
                // update opportunityHPAP;
            }   
            else 
            {     
                if(csMap.containsKey(opportunityHPAP.RTL_Product_Name__c) && !existprodList.contains(String.valueOf(opportunityHPAP.Id)))
                {
                    if(csMap.get(opportunityHPAP.RTL_Product_Name__c).RTL_OfferResult_Product__c == 'Referred' && csMap.get(opportunityHPAP.RTL_Product_Name__c).OpportunityId__c == null )
                    {
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).OpportunityId__c = opportunityHPAP.Id;
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).Corebank_Emp_Id__c = opportunityHPAP.Corebank_Emp_Id__c;
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).Corebank_Emp_Name__c = opportunityHPAP.Corebank_Emp_Name__c;
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).RTL_Status__c = opportunityHPAP.RTL_Status__c;
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).Details_of_Status__c = opportunityHPAP.Details_of_Status__c;
                        csMap.get(opportunityHPAP.RTL_Product_Name__c).Opportunity_Stage__c = opportunityHPAP.StageName;
                        update csMap.get(opportunityHPAP.RTL_Product_Name__c);
                    }               
                }  
            } 
        }
        else if(cmId != null){
            Boolean isUpdateCM = false;
            List<CampaignMember> campaignMem = [SELECT Id,RTL_Marketing_Code__c,RTL_Campaign_Product_1__c,RTL_Campaign_Product_2__c,RTL_Campaign_Product_3__c,RTL_Campaign_Product_4__c,RTL_Campaign_Product_5__c,
                                                RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,RTL_OfferResult_Product_5__c,
                                                RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c 
                                                FROM CampaignMember WHERE Id =: cmId AND RTL_RelatedOpportunity_1__c != : opportunityHPAP.Id AND RTL_RelatedOpportunity_2__c != : opportunityHPAP.Id AND RTL_RelatedOpportunity_3__c != : opportunityHPAP.Id AND RTL_RelatedOpportunity_4__c != : opportunityHPAP.Id AND RTL_RelatedOpportunity_5__c != : opportunityHPAP.Id LIMIT 1];
            // List<Cross_Sell_Product__c> crossSell = [SELECT Id,CampaignMemberId__c,Campaign_Product__c,RTL_OfferResult_Product__c,OpportunityId__c FROM Cross_Sell_Product__c WHERE CampaignMemberId__c =: cmId];
            // Map<Id,Cross_Sell_Product__c> csMap = new Map<Id,Cross_Sell_Product__c>();
            // if(crossSell.size() > 0)
            // {
            //     for(Cross_Sell_Product__c cs :crossSell)
            //     {
            //         csMap.put(cs.Campaign_Product__c,cs);
            //     }
            // }

            if(campaignMem.size() > 0){
                for(Integer i = 1; i <= 5; i++)
                {
                    System.debug('Campaign Product Name : ' + campaignMem.get(0).get('RTL_Campaign_Product_'+i+'__c'));
                    System.debug('Campaign Offer Result : ' + campaignMem.get(0).get('RTL_OfferResult_Product_'+i+'__c'));
                    System.debug('Campaign Check Related oppty ' + i + ' : '+ campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c'));

                    if(opportunityHPAP.RTL_Product_Name__c == campaignMem.get(0).get('RTL_Campaign_Product_'+i+'__c') && campaignMem.get(0).get('RTL_OfferResult_Product_'+i+'__c') == 'Referred' 
                        && campaignMem.get(0).get('RTL_RelatedOpportunity_'+i+'__c') == null)
                    {
                        System.debug('Update : ' + 'RTL_RelatedOpportunity_'+i+'__c || ' + opportunityHPAP.Id);
                        campaignMem.get(0).put('RTL_RelatedOpportunity_'+i+'__c',opportunityHPAP.Id);
                        isUpdateCM = true;
                        break;
                    }
                }
            }

            if(isUpdateCM)
            {
                campaignMem[0].RTL_isBatchUpdateCampaignMember__c = true;
                update campaignMem;
            }   
            
        }
    }
    public static void stampReferToCampaignMember (Id refId)
    {    
        System.debug('refId : ' + refId);
        if(!checkIsEmpty(refId))
        {
            Boolean isUpdateCM = false;
            RTL_Referral__c ref = [SELECT Id,RTL_Product_Name__c,RTL_Campaign_Member__c FROM RTL_Referral__c WHERE Id =: refId LIMIT 1];
            System.debug('ref product name : ' + ref.RTL_Product_Name__c);
            Set<String> existprodList = new Set<String>();

            if(!checkIsEmpty(ref.RTL_Product_Name__c)){

            List<CampaignMember> campaignMem = [SELECT Id,RTL_Marketing_Code__c,RTL_Campaign_Product_1__c,RTL_Campaign_Product_2__c,RTL_Campaign_Product_3__c,RTL_Campaign_Product_4__c,RTL_Campaign_Product_5__c,
                                                RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,RTL_OfferResult_Product_5__c,
                                                RTL_Referral_ID_1__c,RTL_Referral_ID_2__c,RTL_Referral_ID_3__c,RTL_Referral_ID_4__c,RTL_Referral_ID_5__c 
                                                FROM CampaignMember WHERE Id =: ref.RTL_Campaign_Member__c LIMIT 1];
            List<Cross_Sell_Product__c> crossSell = [SELECT Id,CampaignMemberId__c,Campaign_Product__c,RTL_OfferResult_Product__c,OpportunityId__c,ReferralId__c FROM Cross_Sell_Product__c WHERE CampaignMemberId__c =: ref.RTL_Campaign_Member__c ORDER BY CreatedDate DESC];
            Map<Id,Cross_Sell_Product__c> csMap = new Map<Id,Cross_Sell_Product__c>();
            System.debug('Size CM : ' + campaignMem.size());
            for(Integer i = 1; i <= 5; i++)
            {   
                if(campaignMem.get(0).get('RTL_Referral_ID_'+i+'__c') != null){
                    existprodList.add(String.valueOf(campaignMem.get(0).get('RTL_Referral_ID_'+i+'__c')));
                }
            }
            if(crossSell.size() > 0 && !existprodList.contains(String.valueOf(ref.Id)))
            {
                for(Cross_Sell_Product__c cs :crossSell)
                {
                    existprodList.add(String.valueOf(cs.ReferralId__c));
                    csMap.put(cs.Campaign_Product__c,cs);
                }
            }
            if(campaignMem.size() > 0 && !existprodList.contains(String.valueOf(ref.Id))){            
                for(Integer i = 1; i <= 5; i++)
                {   
                    if(ref.RTL_Product_Name__c == campaignMem.get(0).get('RTL_Campaign_Product_'+i+'__c') && campaignMem.get(0).get('RTL_OfferResult_Product_'+i+'__c') == 'Referred' 
                        && campaignMem.get(0).get('RTL_Referral_ID_'+i+'__c') == null )
                    {
                        campaignMem.get(0).put('RTL_Referral_ID_'+i+'__c',ref.Id);
                        isUpdateCM = true;
                        System.debug('Update : ' + 'RTL_Referral_ID_'+i+'__c || ' + ref.Id );

                    }
                }
            }

            if(isUpdateCM)
            {
                campaignMem[0].RTL_isBatchUpdateCampaignMember__c = true;
                update campaignMem;
                // opportunityHPAP.Marketing_Code__c = campaignMem.get(0).RTL_Marketing_Code__c;
                // update opportunityHPAP;
            }   
            else 
            {     
                if(csMap.containsKey(ref.RTL_Product_Name__c) && !existprodList.contains(String.valueOf(ref.Id)))
                {
                    if(csMap.get(ref.RTL_Product_Name__c).RTL_OfferResult_Product__c == 'Referred' && csMap.get(ref.RTL_Product_Name__c).ReferralId__c == null )
                    {
                        csMap.get(ref.RTL_Product_Name__c).ReferralId__c = ref.Id;
                        update csMap.get(ref.RTL_Product_Name__c);
                    }               
                }  
            } 
        }
        }
    }
    
}