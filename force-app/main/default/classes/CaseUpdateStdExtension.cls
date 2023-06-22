public class CaseUpdateStdExtension {

    public Case caseObj {get; set;}
    public String caseObjJson {get {return JSON.serialize(new Map<String, Object>{
        'PTA_Segment__c' => caseObj.PTA_Segment__c,
        'Category__c' => caseObj.Category__c,
        'Sub_Category__c' => caseObj.Sub_Category__c,
        'Product_Category__c' => caseObj.Product_Category__c,
        'Issue__c' => caseObj.Issue__c
    });}}

    public String selected_PTA_Segment {get; set;}
    public String tmbCustomerID {get; set;}
    public String type{get;set;}
    public String accountId {get; set;}
    public Boolean isAllowedEdit {get; set;}
    public Boolean isShowFCR {get; set;}
    private Boolean validateOptionFag = true;
    public Boolean checkedStatusNew {
        get {
            if(checkedStatusNew == null) {
                checkedStatusNew = false;
            }
            return checkedStatusNew;
        }
        set;
    }

    public Boolean exceptionFlag {
        get {
            if(exceptionFlag == null) {
                exceptionFlag = false;
            }
            return exceptionFlag;
        }
        set;
    }

    public Boolean validateFormFag {
        get {
            if(validateFormFag == null) {
                validateFormFag = false;
            }
            return validateFormFag;
        }
        set;
    }

    private String FCRChannel = AppConfig__c.getValues('FCR_Channel').Value__c; 
    private String FCRCategory = AppConfig__c.getValues('FCR_Category').Value__c;

    public Account accountSegment {get; set;}
    public static String cardNumber {get; set;}
    public static String cardNumber2 {get; set;}
    public static String promptPay {get; set;}
    public static String interBankAccountNo {get; set;}
    public static String recipientAccountNo {get; set;}
    public static String productNumberForEdit1 {get; set;}
    public String productNumberForEdit2 {get; set;}
    public String productNumberForEdit3 {get; set;}
    public String productNumberForEditFull1 {get; set;}
    public String productNumberForEditFull2 {get; set;}
    public String productNumberForEditFull3 {get; set;}
    
    public String caseOldSegment;
    public String caseOldCategory;
    public String caseOldSubCategory;
    public String caseOldProductCategory;
    public String caseOldIssue;

    // [2020-03-26] Add Select Template.
    public Boolean isFirstLoad {
        get{
            if(isFirstLoad == null) {
                isFirstLoad = false;
            }
            return isFirstLoad;
        }
        set;
    }
    public String caseServiceTemplate {get; set;}
    // Template flags.
    public Boolean templateDefault {get; set;}
    public Boolean templateCard {get; set;}
    public Boolean templateCardProduct {get; set;}
    public Boolean templateProduct {get; set;}
    public Boolean templateDepositWithdraw {get; set;}
    public Boolean templateMoneyTransfer {get; set;}
    public Boolean templateCheckInvalidTransfer {get; set;}
    public Boolean templateBillPayTopup {get; set;}
    public Boolean templateCreditService {get; set;}
    public Boolean templateCheque {get; set;}
    public Boolean templateKYC {get; set;}

    public String Guideline {get; set;}
        
    public Map<String, String> customerServiceSegment {
        get{
            if (customerServiceSegment == null) {
                customerServiceSegment = new Map<String, String>();
                for (Customer_Service_Segment_Mapping__mdt cusSegment : [select id, Customer_Segment__c, Label
                from Customer_Service_Segment_Mapping__mdt]) {
                    List<String> segmentCRM = cusSegment.Customer_Segment__c.split(',');
                    if (segmentCRM != null) {
                        for (String seg : segmentCRM) {
                            if (cusSegment.Label != 'Blank') {
                                customerServiceSegment.put(seg, cusSegment.Label);
                            }
                        }
                    }
                }
            }
            return customerServiceSegment;
        }
        set;
    }


    public List<selectOption> PTA_Segment_Options {
        get{
            if ( PTA_Segment_Options == null ) {
                PTA_Segment_Options = new List<selectOption>();
                PTA_Segment_Options.add(new selectOption('', '-- None --'));

                List<AggregateResult> groupedResults = [SELECT  Segment__c
                FROM Service_Type_Matrix__c
                Where active__c = true
                AND Segment__c != null
                AND Segment__c != ''
                group by Segment__c];

                Set<String> possibleValue = new Set<String>();
                for (AggregateResult ar : groupedResults)  {
                    PTA_Segment_Options.add(new SelectOption( (String)ar.get('Segment__c'), (String)ar.get('Segment__c') ));
                }
                //system.debug('PTA_Segment_Options if null = ' + PTA_Segment_Options);
            } else{
                //system.debug('PTA_Segment_Options = ' + PTA_Segment_Options);
            }
            return PTA_Segment_Options;

        }
        set;
    }

    public String PTA_Segment_Options_Str {
        get{
            if ( PTA_Segment_Options_Str == null ) {
                List<String> PTA_Segment_Options_List = new List<String>();
                
                List<AggregateResult> groupedResults = [SELECT Segment__c
                FROM Service_Type_Matrix__c
                Where active__c = true
                AND Segment__c != null
                AND Segment__c != ''
                group by Segment__c];

                for (AggregateResult ar : groupedResults)  {
                    PTA_Segment_Options_List.add((String)ar.get('Segment__c'));
                }

                PTA_Segment_Options_Str = JSON.serialize(PTA_Segment_Options_List);
            }
            return PTA_Segment_Options_Str;
        }
        set;
    }

    public List<selectOption> CaseStatus_Options {
        get{
            if ( CaseStatus_Options == null ) {
                CaseStatus_Options = new List<selectOption>();

            }
            return CaseStatus_Options;

        }
        set;
    }

    //Check field permission to show all section ATM/ADM in screen when user create new , or edit
    Public Boolean isAccessibleATM_ADM {
        get{
            Schema.DescribeFieldResult drField = Case.Permission_Access_ATM_ADM__c.getDescribe();
            Boolean isMyAccessible = drField.isAccessible();
            return isMyAccessible;
        }
        set;
    }

    //Check field permission to show all section SE Process in screen when user create new , or edit
    Public Boolean isAccessibleSE_Process {
        get{
            Schema.DescribeFieldResult drField = Case.Permission_Access_SE_Process__c.getDescribe();
            Boolean isMyAccessible = drField.isAccessible();
            return isMyAccessible;
        }
        set;
    }
    
    //--- CR Inbound Popup --
    public List<Task> updateTaskList {
        get{
            if ( updateTaskList == null ) {
                updateTaskList = new List<Task>();
            }
            return updateTaskList;
        }
        set;
    }
    //--- CR Inbound Popup --

    public CaseUpdateStdExtension(ApexPages.StandardController stdController) {

        Id defAccountId = apexpages.currentpage().getparameters().get('def_account_id');
        Id defContactId = apexpages.currentpage().getparameters().get('def_contact_id');
        Id defOptyId = apexpages.currentpage().getparameters().get('def_opportunity_id');
        Id recordTypeId = apexpages.currentpage().getparameters().get('recordType');
        type = apexpages.currentpage().getparameters().get('type');
        Object state = apexpages.currentpage().getparameters().get('state');
        String ContactPersonName1 = apexpages.currentpage().getparameters().get('ContactPersonName');
        String ContactPersonPhone1 = apexpages.currentpage().getparameters().get('ContactPersonPhone');
        System.Debug('ContactPersonPhone: '+ContactPersonPhone1);
        System.Debug('ContactPersonName: '+ContactPersonName1);
        System.Debug('state: '+state);
        

        caseObj = (Case)stdController.getRecord();
        tmbCustomerID = '';
        //===========================  Check record Access  ===========================
        isAllowedEdit = false;
        SetDefaultCaseTemplate();
        SetDefaultFirstLoadFlag();

        if ( caseObj.id != null ) {

            try {
                UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = : UserInfo.getUserId()
                                                    AND RecordID = : caseObj.id
                                                            //AND HasReadAccess = True
                                           ];
                Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c, Origin, Category__c FROM case WHERE ID = :caseObj.id];

                if ( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
                    isAllowedEdit = true;
                } else {
                    isAllowedEdit = false;
                }

                if (Userinfo.getUserId() == casePermision.CreatedById && Userinfo.getUserId() == casePermision.LastModifiedById
                    && casePermision.Status == 'New' && casePermision.All_Previous_Owner__c == null) {
                    //Show FCR on record first hop ,creator is last modified by and case status = New
                    isShowFCR = true;
                } else {
                    isShowFCR = false;
                }

                if(casePermision.Origin != null && casePermision.Category__c != null){
                    if(FCRChannel.contains(casePermision.Origin) && FCRCategory.contains(casePermision.Category__c)){
                        isShowFCR = true;
                    } 
                }

            } catch (Exception e) {
                //=========== Case of not found - set no access ========
                isAllowedEdit = false;
                isShowFCR = true; 
            }

        } else {
            isAllowedEdit = true;
            isShowFCR = true; //FCR visible on create page

        }

        // If from clonem always allow to edit
        if ( apexpages.currentpage().getparameters().get('clone') == '1' ) {
            isAllowedEdit = true;
        }

        if ( !isAllowedEdit  ) {
            System.Debug('TEST');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
            caseObj = new Case();//Init case obj
        } else {
            generateStatusOption();

            try {

                if ( caseObj.id != null ) {

                    String clone = '';

                    try {
                        clone = apexpages.currentpage().getparameters().get('clone');
                    } catch (Exception e) {
                        clone = '0';
                    }
                    Id caseId = caseObj.id;

                    DescribeSObjectResult describeResult = Case.getSObjectType().getDescribe();
                    List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );


                    String query = 'SELECT ' +
                                   String.join( fieldNames, ',' ) +
                                   ' FROM ' +
                                   describeResult.getName()  +
                                   ' Where id = :caseId '
                                   ;

                    caseObj = (Case)Database.query( query );

                    if ( clone == '1' ) {
                        Case cloneCase = caseObj.clone();
                        caseObj = cloneCase;
                        caseObj.EntitlementId = null;
                        caseObj.OwnerId = UserInfo.getUserId();
                    }


                } else {
                    caseObj = new Case();
                    List<User> currentUser = [Select ID, Employee_ID__c from User where username = : userinfo.getUserName() limit 1];
                    caseObj.Subject = 'Auto Subject (ไม่ต้องใส่ข้อมูล)'; //Add auto subject

                    //----Start Check is bulk load case or not ---
                    //If bulk load case, not auto mapping call log ID
                    if (currentUser.size() > 0) {
                        mappingCallLog(caseObj, currentUser[0].Employee_ID__c, updateTaskList);
                    }
                    // --- End check bulk load case ---

                    //if recordtypeId is passed from select record type page , use this value  else use default value in profile
                    if (recordTypeId != null) {
                        caseObj.RecordTypeId = recordTypeId;
                    }

                }

                if ( defAccountId != null ) {
                    caseObj.AccountId = defAccountId;
                    getCustomerSegmentAndTMBCusId(defAccountId);
                }
                if ( defOptyId != null) {
                    caseObj.Opportunity__c = defOptyId;
                }
                if (defContactId != null) {
                    caseObj.ContactId = defContactId;

                }
                if ( caseObj.OwnerId == null ) {
                    caseObj.OwnerId = UserInfo.getUserId();
                }

                //set temp value on page for show masking or full data
                caseObj.Product_Number_Temp_1__c = (Schema.sObjectType.Case.fields.Product_Number_Full_1__c.isAccessible())?caseObj.Product_Number_Full_1__c:caseObj.Product_Number_1__c;
                productNumberForEdit2 = (Schema.sObjectType.Case.fields.Product_Number_Full_2__c.isAccessible())?caseObj.Product_Number_Full_2__c:caseObj.Product_Number_2__c;
                productNumberForEdit3 = (Schema.sObjectType.Case.fields.Product_Number_Full_3__c.isAccessible())?caseObj.Product_Number_Full_3__c:caseObj.Product_Number_3__c;
                caseObj.Card_No_Temp__c = (Schema.sObjectType.Case.fields.Card_No_Full__c.isAccessible())?caseObj.Card_No_Full__c:caseObj.Card_No__c;
                caseObj.Card_No2_Temp__c = (Schema.sObjectType.Case.fields.Card_No2_Full__c.isAccessible())?caseObj.Card_No2_Full__c:caseObj.Card_No2__c;
                caseObj.Prompt_Pay_Temp__c = (Schema.sObjectType.Case.fields.Prompt_Pay_Full__c.isAccessible())?caseObj.Prompt_Pay_Full__c:caseObj.Prompt_Pay__c;
                caseObj.Recipient_Account_No_Temp__c = (Schema.sObjectType.Case.fields.Recipient_Account_No_Full__c.isAccessible())?caseObj.Recipient_Account_No_Full__c:caseObj.Recipient_Account_No__c;
                caseObj.Inter_Bank_Recipient_Account_No_Temp__c = (Schema.sObjectType.Case.fields.Inter_Bank_Recipient_Account_No_Full__c.isAccessible())?caseObj.Inter_Bank_Recipient_Account_No_Full__c:caseObj.Inter_Bank_Recipient_Account_No__c;
        
                caseOldSegment = caseObj.PTA_Segment__c;
                caseOldCategory = caseObj.Category__c;
                caseOldSubCategory = caseObj.Sub_Category__c;
                caseOldProductCategory = caseObj.Product_Category__c;
                caseOldIssue = caseObj.Issue__c;
                
                //If create from Inquiry Case
                if (type == 'Inquiry_Case'){
                    System.Debug('IS INQUIRY');
                    String ContactPersonName = apexpages.currentpage().getparameters().get('ContactPersonName');
                    String ContactPersonPhone = apexpages.currentpage().getparameters().get('ContactPersonPhone');
                    String ContactPersonPhone2 = apexpages.currentpage().getparameters().get('ContactPersonPhone2');
                    String ToExt1 = apexpages.currentpage().getparameters().get('ToExt1');
                    String ToExt2 = apexpages.currentpage().getparameters().get('ToExt2');
                    // String PTASegment = apexpages.currentpage().getparameters().get('PTASegment');
                    System.Debug('Alee defAccountId:'+defAccountId);
                    System.Debug('Alee ContactPersonName:'+ContactPersonName);
                    System.Debug('Alee ContactPersonPhone:'+ContactPersonPhone);
                    // System.Debug('Alee PTASegment:'+PTASegment);
                    if (ContactPersonName == 'undefined'){
                        caseObj.Contact_Person_Name__c = null;
                    }else {
                        caseObj.Contact_Person_Name__c = ContactPersonName;
                    }
                    if (ContactPersonName == 'undefined'){
                        caseObj.Contact_Person_Phone__c = null;
                        caseObj.Contact_Person_Phone_2__c = null;
                    }else {
                        caseObj.Contact_Person_Phone__c = ContactPersonPhone;
                        caseObj.Contact_Person_Phone_2__c = ContactPersonPhone2;
                    }
                    
                    if (ContactPersonPhone == 'undefined'){
                        caseObj.To_Ext_1__c = null;
                    }else {
                        caseObj.To_Ext_1__c = ToExt1;
                    }

                    if (ContactPersonPhone2 == 'undefined'){
                        caseObj.To_Ext_2__c = null;
                    }else {
                        caseObj.To_Ext_2__c = ToExt2;
                    }

                    
                    // if (PTASegment == ''){
                    caseObj.PTA_Segment__c = 'RBG';
                    // }else {
                        // caseObj.PTA_Segment__c = PTASegment;
                    // }
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage() + ' (' + e.getLineNumber() + ')'   );
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' (' + e.getLineNumber() + ')'  ));

            }

        }
    }

    public void getCustomerSegmentAndTMBCusId(String accId) {
        try {

            accountSegment = [SELECT Segment_crm__c, TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c
                              FROM Account
                              where id = : accId limit 1];
            system.debug('Customer Segement : ' + accountSegment);

            //get customer segment
            if (accountSegment != null && accountSegment.Segment_crm__c != null) {
                string defaultSegment = customerServiceSegment.get(accountSegment.Segment_crm__c);
                caseObj.PTA_Segment__c = defaultSegment;
            }

            //get tmb cus id
            if (accountSegment != null && accountSegment.TMB_Customer_ID_PE__c != null) {
                tmbCustomerID = accountSegment.TMB_Customer_ID_PE__c;
            }
            system.debug('tmbCustomerID' + tmbCustomerID);

        } catch (Exception e) {
            system.debug('get customer segment on case : ' + e);
        }

    }


    public void generateStatusOption() {

        List<CaseStatus> caseStatusList = [SELECT Id, IsClosed, IsDefault, SortOrder, ApiName, MasterLabel FROM CaseStatus WHERE IsClosed = false];

        Map<String, CaseStatus> caseStatusMap = new Map<String, CaseStatus>();

        for ( CaseStatus cs : caseStatusList ) {
            caseStatusMap.put( cs.ApiName , cs );
        }

        Id recId;

        if ( caseObj.recordTypeId == null ) { // Edit Case
            Schema.DescribeSObjectResult dsr = Case.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if (rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                }
            }

            recId = defaultRecordType.getRecordTypeId();
        } else { // New Case
            recId = caseObj.recordTypeId;
        }

        if (!Test.isRunningTest()) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //String shost = System.Url.getSalesforceBaseURL().toExternalForm();
            String shost = URL.getOrgDomainURL().toExternalForm();
            String url = shost + '/services/data/v43.0/ui-api/object-info/Case/picklist-values/' + recId + '/Status';
            request.setEndpoint(url);
            request.setMethod('GET');
            //sample Case ID 5000k000009OpbM
            // set Authorization
            request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            HttpResponse response = http.send(request);



            Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped( response.getBody() );

            //Set<String> statusOption = new Set<String>();

            List<Object> dataValues = (List<Object>)root.get('values');
            system.debug( dataValues );
            for ( Object picklistData : dataValues ) {
                Map <String, Object> picklistItem = (Map <String, Object>)picklistData;

                String optionApiName = (String)picklistItem.get('value');

                if ( caseStatusMap.containskey( optionApiName ) ) {
                    CaseStatus cstatus = caseStatusMap.get(optionApiName);
                    //statusOption.add(picklistItem.get('value'));
                    CaseStatus_Options.add(new SelectOption( cstatus.ApiName , cstatus.MasterLabel ));
                }

            }

        }
    }

    public PageReference save() {
        //========== Add logic to validate Propduct Category and Issue ===============

        system.debug('result save :' + caseObj);

        Map<id,User> mapUserInactive= new Map<id,User>([SELECT id, name, isactive, profile.name from User where  isactive = false]);

        String clone = '';

        try {
            clone = apexpages.currentpage().getparameters().get('clone');
        } catch (Exception e) {
            clone = '0';
        }

        try {
            String DMLEvents = 'insert';
            exceptionFlag = false;
            setAssignTempValueToMaskingAndFullField();

            //check customer product marking and assign value to full field
            validateMarkingCustomerProduct(productNumberForEdit1,productNumberForEditFull1,'1');
            validateMarkingCustomerProduct(productNumberForEdit2,productNumberForEditFull2,'2');
            validateMarkingCustomerProduct(productNumberForEdit3,productNumberForEditFull3,'3');

            //set temp values to null
            caseObj.Product_Number_Temp_1__c = null;
            caseObj.Card_No_Temp__c = null;
            caseObj.Card_No2_Temp__c = null;
            caseObj.Prompt_Pay_Temp__c = null;
            caseObj.Recipient_Account_No_Temp__c = null;
            caseObj.Inter_Bank_Recipient_Account_No_Temp__c = null;

            if (clone == '1') {
                insert caseObj;
            } else {
                if (caseObj.id != null) { // Edit

                    if (caseObj.Status == 'New' && checkedStatusNew == false && caseObj.FCR__c == false) {
                        checkedStatusNew = true;
                        validateFormFag = false;
                        setTempValueToField();
                        ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.WARNING, Label.Case_ERR003_Save_With_New) );
                        return null;
                    } 
                    if (caseObj.Status == 'Resolved' && checkedStatusNew == false && caseObj.FCR__c == false && mapUserInactive.containsKey(caseObj.CreatedById)) {
                        caseObj.Closed_By_BU__c = null;
                        checkedStatusNew = true;
                        validateFormFag = false;
                        setTempValueToField();
                        ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.WARNING, Label.Case_ERR007_Register_Inactive) );
                        System.debug('Resolved' + caseObj);
                        return null;
                    }
                    DMLEvents = 'update';
                    validateFormFag = true;
                    update caseObj;
                } else { // Add new
                    DMLEvents = 'insert';
                    validateFormFag = true;
                    insert caseObj;
                }

            }
            
            //--- CR Inbound Popup --
            if(updateTaskList.size() > 0)
            {
                updateTaskList[0].WhatId = caseObj.AccountId;
                update updateTaskList;
                System.debug('updateTaskList:'+updateTaskList);
            }
            //--- CR Inbound Popup --
            
            PageReference CasePage = new ApexPages.StandardController(caseObj).view();
            CasePage.setRedirect(true);
            return CasePage;
            // Convert Lightning Project
            // - compatible classic console and desktop lighting
            // System.debug(UserInfo.getUiThemeDisplayed());
            // return String.isNotEmpty(DMLEvents) && DMLEvents == 'insert' ? CasePage : (UserInfo.getUiThemeDisplayed() == 'Theme3' ? CasePage : null);


        } catch (Exception e) {
            setTempValueToField();
            ApexPages.addmessages(e);
            exceptionFlag = true;
            checkedStatusNew = false;
            validateFormFag = false;
            System.debug('getMessage' + e.getMessage());
            //ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ) );
        }

        return null;
    }

    public void setAssignTempValueToMaskingAndFullField(){
        //assign value temp to mark and full field
        cardNumber = caseObj.Card_No_Temp__c;
        cardNumber2 = caseObj.Card_No2_Temp__c;

        caseObj.Card_No__c = cardNumber;
        caseObj.Card_No2__c = cardNumber2;
        if(cardNumber == null || cardNumber == ''){
            caseObj.Card_No_Full__c = null;   
        }
        if(cardNumber2 == null || cardNumber2 == ''){
            caseObj.Card_No2_Full__c = null;   
        }
        if(cardNumber != null && cardNumber != '' && !cardNumber.containsIgnoreCase('*')){//fix masking replace full number
            caseObj.Card_No_Full__c = cardNumber;
        }

        if(cardNumber2 != null && cardNumber2 != '' && !cardNumber2.containsIgnoreCase('*')){//fix masking replace full number    
            caseObj.Card_No2_Full__c = cardNumber2;    
        }
        system.debug('Card_No_Full__c'+caseObj.Card_No_Full__c);

        promptPay = caseObj.Prompt_Pay_Temp__c;
        caseObj.Prompt_Pay__c = NumberHelper.MaskPromptPay(promptPay);
        caseObj.Prompt_Pay_Full__c = promptPay;

        recipientAccountNo = caseObj.Recipient_Account_No_Temp__c;
        caseObj.Recipient_Account_No__c = NumberHelper.MarkAccountNo(recipientAccountNo);
        caseObj.Recipient_Account_No_Full__c = recipientAccountNo;

        interBankAccountNo = caseObj.Inter_Bank_Recipient_Account_No_Temp__c;
        caseObj.Inter_Bank_Recipient_Account_No__c = NumberHelper.MarkAccountNo(interBankAccountNo);
        caseObj.Inter_Bank_Recipient_Account_No_Full__c = interBankAccountNo;

        productNumberForEdit1 = caseObj.Product_Number_Temp_1__c;

        productNumberForEditFull1 = (productNumberForEditFull1!=null && productNumberForEditFull1!='')?productNumberForEditFull1:caseObj.Product_Number_Full_1__c;
        productNumberForEditFull2 = (productNumberForEditFull2!=null && productNumberForEditFull2!='')?productNumberForEditFull2:caseObj.Product_Number_Full_2__c;
        productNumberForEditFull3 = (productNumberForEditFull3!=null && productNumberForEditFull3!='')?productNumberForEditFull3:caseObj.Product_Number_Full_3__c;

    }

    public void setTempValueToField (){
        //set temp values when validate error.
        caseObj.Product_Number_Temp_1__c = productNumberForEdit1;
        caseObj.Card_No_Temp__c = cardNumber;
        caseObj.Card_No2_Temp__c = cardNumber2;
        caseObj.Prompt_Pay_Temp__c = promptPay;
        caseObj.Recipient_Account_No_Temp__c = recipientAccountNo;
        caseObj.Inter_Bank_Recipient_Account_No_Temp__c = interBankAccountNo;
    }

    public void validateMarkingCustomerProduct(String productNumber,String productNumberFull,String fieldsNo){
        
        //assign value temp to field
        if(productNumber != null && productNumber != ''){
            caseObj.put('Product_Number_'+fieldsNo+'__c',productNumber);
            caseObj.put('Product_Number_Full_'+fieldsNo+'__c',productNumberFull);
        }else{
            caseObj.put('Product_Number_'+fieldsNo+'__c',null);
            caseObj.put('Product_Number_Full_'+fieldsNo+'__c',null);
        }

        //marking account number when key in by user
        if(productNumber != null && productNumber != '' && !productNumber.containsIgnoreCase('x')){
            string productType = (string) caseObj.get('Product_Type_'+fieldsNo+'__c');
            if(productType != null){
                if(productType == 'Deposit'){
                    string markingAccNo = NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo10Digit(productNumber));
                    caseObj.put('Product_Number_Full_'+fieldsNo+'__c',productNumber);
                    caseObj.put('Product_Number_'+fieldsNo+'__c',markingAccNo); 
                    
                }else if(productType== 'Loan'){
                    string markingAccNo = NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(productNumber));
                    caseObj.put('Product_Number_Full_'+fieldsNo+'__c',productNumber);
                    caseObj.put('Product_Number_'+fieldsNo+'__c',markingAccNo); 
                }else{
                    caseObj.put('Product_Number_Full_'+fieldsNo+'__c',productNumber);
                    caseObj.put('Product_Number_'+fieldsNo+'__c',productNumber); 
                }
            }else{
                caseObj.put('Product_Number_Full_'+fieldsNo+'__c',productNumber);
                caseObj.put('Product_Number_'+fieldsNo+'__c',productNumber); 
            }
            
        }
    }

    //Function for auto mapping call log Id from Finesse to Case in salesforce
    public static case mappingCallLog(Case caseRecord, string userID, List<Task> updateTaskList) {

        //Datetime halfHourBack = Datetime.now().addMinutes(-30); record last 30 minutes
        //Datetime oneHourBack = Datetime.now().addHours(-1); record last 1 hour
        try {
            System.Debug('userID: '+userID);
            List<Task> callTaskList = [select ID, Call_Agent_Id__c, Call_Log_ID__c, Call_Start_Datetime__c, Call_Number__c,
                                       recordtypeID, CreatedDate, WhatId from Task WHERE Call_Agent_Id__c = : userID
                                               AND CreatedDate >= : Datetime.now().addHours(-1)
                                               AND RecordType.Name  = 'Call Log Record Type' AND Call_Log_ID__c != null
                                                       ORDER BY CreatedDate DESC LIMIT 1 ];
            if (callTaskList.size() > 0) {
                caseRecord.Call_Log_ID__c = callTaskList[0].Call_Log_ID__c;
                caseRecord.Call_Number__c = callTaskList[0].Call_Number__c;
                caseRecord.Call_Start_Datetime__c = callTaskList[0].Call_Start_Datetime__c;
                //--- CR Inbound Popup --
                if(callTaskList[0].WhatId == null)
                {
                    Task updateTask = new Task();
                    updateTask = callTaskList[0];
                    updateTaskList.add(updateTask);
                }            
                //--- CR Inbound Popup --
            }
        } catch (exception e) {
            //return not thing
        }
        return caseRecord;
    }

    public PageReference getAccountId(){
        //get accountid when account is changed.
        accountId = caseobj.accountid;
        getCustomerSegmentAndTMBCusId(accountId);

        return null;
    }

    public PageReference newSave() {
        
        Boolean bool1 = (caseObj.PTA_Segment__c == null || caseObj.PTA_Segment__c == '' || caseObj.PTA_Segment__c == '-- None --');
        Boolean bool2 = (caseObj.Category__c == null || caseObj.Category__c == '' || caseObj.Category__c == '-- None --');
        Boolean bool3 = (caseObj.Sub_Category__c == null || caseObj.Sub_Category__c == '' || caseObj.Sub_Category__c == '-- None --');

        if(bool1) {
            ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_ERR004));
            return null;
        }
        if(bool2) {
            ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_ERR005));
            return null;
        }
        if(bool3) {
            ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_ERR006));
            return null;
        }
        
        Boolean con1 = (caseObj.PTA_Segment__c == caseOldSegment);
        Boolean con2 = (caseObj.Category__c == caseOldCategory);
        Boolean con3 = (caseObj.Sub_Category__c == caseOldSubCategory);
        Boolean con4 = (caseObj.Product_Category__c == caseOldProductCategory);
        Boolean con5 = (caseObj.Issue__c == caseOldIssue);
        
        if(con1 && con2 && con3 && con4 && con5){
            return save();
        }

        List<Service_Type_Matrix__c> ServiceType = [SELECT Id, OwnerId, Name, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Service_Level4__c, Severity__c, SLA__c, Responsible_BU__c, Closed_By_BU__c, Problem_Type__c, Journey__c, Validate_Code__c
        , Service_issue_EN__c, SMS_Code_New__c, SMS_Code_In_Progress__c, SMS_Code_Resolved__c, Resolution_1__c, Resolution_2__c, SMS_Code_Resolution_1__c, SMS_Code_Resolution_2__c, Guideline__c, TAT__c, SMS_Code_for_Update_Progress__c
        , Issue_for_ONEAPP_EN__c ,Issue_for_ONEAPP_TH__c , Product_Service_TH__c , Display_on_OneApp__c
                                    FROM Service_Type_Matrix__c
                                    WHERE Segment__c = :caseObj.PTA_Segment__c
                                              AND Service_Level1__c = :caseObj.Category__c
                                              AND Service_Level2__c = :caseObj.Sub_Category__c
                                              AND Service_Level3__c = :caseObj.Product_Category__c
                                              AND Service_Level4__c = :caseObj.Issue__c
        ];
        if(ServiceType.size() == 1){
            Service_Type_Matrix__c stm = ServiceType[0];
            
            caseObj.Responsible_BU__c = stm.Responsible_BU__c;
            caseObj.SLA_Day__c = stm.SLA__c;
            
            if(caseObj.Problem_Type__c == null){
                 caseObj.Problem_Type__c = stm.Problem_Type__c; 
            }
            if(caseObj.Journey__c == null){
                caseObj.Journey__c = stm.Journey__c;
            }
            caseObj.Service_issue_EN__c  = stm.Service_issue_EN__c;            
            caseObj.Service_Type_Matrix_Code__c = stm.Validate_Code__c;
            caseObj.SMS_Code_New__c = stm.SMS_Code_New__c;
            caseObj.SMS_Code_In_Progress__c = stm.SMS_Code_In_Progress__c;
            caseObj.SMS_Code_Resolved__c = stm.SMS_Code_Resolved__c;
            caseObj.SMS_Resolution_1__c = stm.Resolution_1__c;
            caseObj.SMS_Resolution_2__c = stm.Resolution_2__c;
            caseObj.SMS_Code_Resolution_1__c = stm.SMS_Code_Resolution_1__c;
            caseObj.SMS_Code_Resolution_2__c = stm.SMS_Code_Resolution_2__c;      
            caseObj.Guideline__c = stm.Guideline__c;
            caseObj.TAT__c = stm.TAT__c;
            caseObj.Current_Service_Template__c = caseServiceTemplate;
            caseObj.SMS_Code_for_Update_Progress__c = stm.SMS_Code_for_Update_Progress__c;
            caseObj.Issue_New_for_OneApp__c = stm.Issue_for_ONEAPP_TH__c;
            caseObj.Product_For_OneApp_TH__c = stm.Product_Service_TH__c;
            caseObj.Display_on_OneApp__c = stm.Display_on_OneApp__c;
            caseObj.Issue_New_for_OneApp_EN__c = stm.Issue_for_ONEAPP_EN__c;
			
            return save();
        }else{
            caseObj.Responsible_BU__c = null;
            caseObj.SLA_Day__c = null;
            caseObj.Problem_Type__c = null;
            caseObj.Journey__c = null;
            caseObj.Service_issue_EN__c  = null;
            caseObj.Service_Type_Matrix_Code__c = null;
            caseObj.SMS_Code_New__c = null;
            caseObj.SMS_Code_In_Progress__c = null;
            caseObj.SMS_Code_Resolved__c = null;
            caseObj.SMS_Resolution_1__c = null;
            caseObj.SMS_Resolution_2__c = null;
            caseObj.SMS_Code_Resolution_1__c = null;
            caseObj.SMS_Code_Resolution_2__c = null;
            caseObj.Guideline__c = null;
            caseObj.TAT__c = null;
			caseObj.SMS_Code_for_Update_Progress__c  = null;
            caseObj.Issue_New_for_OneApp__c = null;
            caseObj.Product_For_OneApp_TH__c = null;
            caseObj.Display_on_OneApp__c = null;
            caseObj.Issue_New_for_OneApp_EN__c = null;

            ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_Edit_Invalid_Service_Request  ) );
        }
        return null;
    }

    // [2020-03-26] Add Select Template.
    public PageReference SetCaseTemplate(){
        String templateStr = Apexpages.currentPage().getParameters().get('templateName');

        // Set all templates to false.
        templateDefault = false;
        templateCard = false;
        templateCardProduct = false;
        templateProduct = false;
        templateDepositWithdraw = false;
        templateMoneyTransfer = false;
        templateCheckInvalidTransfer = false;
        templateBillPayTopup = false;
        templateCreditService = false;
        templateCheque = false;
        templateKYC = false;

        if (templateStr != null && templateStr != ''){
            if (templateStr == 'Card'){
                templateCard = true;
            }
            else if (templateStr == 'CardProduct'){
                templateCardProduct = true;
            }
            else if (templateStr == 'Product'){
                templateProduct = true;
            }
            else if (templateStr == 'DepositWithdraw'){
                templateDepositWithdraw = true;
            }
            else if (templateStr == 'MoneyTransfer'){
                templateMoneyTransfer = true;
            }
            else if (templateStr == 'CheckInvalidTransfer'){
                templateCheckInvalidTransfer = true;
            }
            else if (templateStr == 'BillPayTopup'){
                templateBillPayTopup = true;
            }
            else if (templateStr == 'CreditService'){
                templateCreditService = true;
            }else if(templateStr == 'Cheque'){
                templateCheque = true;
            } else if(templateStr == 'KYCReview') {
                templateKYC = true;
            }
        }
        else{
            templateDefault = false;
        }
        system.debug('Kuong Debug: ' + isFirstLoad);
        isFirstLoad = false;
        caseServiceTemplate = templateStr;
        system.debug('Kuong Debug: ' + caseServiceTemplate);
        return null;

    }

    private void SetDefaultCaseTemplate(){
        templateDefault = false;
    }

    private void SetDefaultFirstLoadFlag(){
        isFirstLoad = true;
    }

    @RemoteAction
    public static List<Service_Type_Matrix__c> selectSegmentPicklist (String sgement){
        String picklistAPI = sgement;

        List<Service_Type_Matrix__c> ServiceTypeFilterPTA = new List<Service_Type_Matrix__c>();

        ServiceTypeFilterPTA = [SELECT Id, OwnerId, Name, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Service_Level4__c, Severity__c, SLA__c, Responsible_BU__c, Closed_By_BU__c, Problem_Type__c, Journey__c, Validate_Code__c
        , Service_issue_EN__c, SMS_Code_New__c, SMS_Code_In_Progress__c, SMS_Code_Resolved__c, Resolution_1__c, Resolution_2__c, SMS_Code_Resolution_1__c, SMS_Code_Resolution_2__c, Guideline__c, TAT__c, Service_Template__c, SMS_Code_for_Update_Progress__c
        , Issue_for_ONEAPP_EN__c ,Issue_for_ONEAPP_TH__c  , Product_Service_TH__c , Display_on_OneApp__c
                                    FROM Service_Type_Matrix__c
                                    WHERE Segment__c = :picklistAPI AND active__c = true];

        return ServiceTypeFilterPTA;
    }
}