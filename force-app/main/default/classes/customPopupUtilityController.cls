global with sharing class customPopupUtilityController {
	private static String ACCOUNT_SF_ID = 'ACCOUNT_SF_ID';
    private static String LEAD_SF_ID = 'LEAD_SF_ID';
    private static String GLOBAL_SEARCH_VAL = 'GLOBAL_SEARCH_VAL';
    private static String GLOBAL_SEARCH_OBJ = 'GLOBAL_SEARCH_OBJ';

    private static String NICE_SEARCH_POPUP = 'NICE_SEARCH_POPUP';
    private static String FINEESE_SEARCH_POPUP = 'FINEESE_SEARCH_POPUP';
    private static String APPOINTMENT_SEARCH_POPUP = 'APPOINTMENT_SEARCH_POPUP';

    private static String CCPIN_FUNCTION = 'CCPIN_FUNCTION';


    global class PhoneNumberMatch {
        public String ACCOUNT_SF_ID {get;set;}
        public String LEAD_SF_ID {get;set;}
        public String GLOBAL_SEARCH_OBJ {get;set;}
        public String GLOBAL_SEARCH_VAL {get;set;}

        public String accountName {get;set;}
        public String contactName {get;set;}
        public String leadName {get;set;}

        public String contactPhoneNumbers {get;set;}
        public String accountPhoneNumbers {get;set;}
        public String leadPhoneNumbers {get;set;}

        public String urlret {get;set;}
        //public String sfid {get;set;}
        public String sfidForTab {get;set;}
        public String ACCOUNT_TMBCUSTID {get;set;}
    }

    private static String customKeyEncypted;

    static {
        AppConfig__c mc   = AppConfig__c.getValues('SaltKeyCustom');
        customKeyEncypted = (mc == null ? 'ABCDEFGHIJ' : mc.Value__c);
    }

    private static Blob smartQueue;
    private static Blob ivKey;

    static {
        AppConfig__c mc = AppConfig__c.getValues('ForSmartQ');
        string key = (mc == null ? 'fortestsmartqfortestsmartqfortes' : mc.Value__c);
        smartQueue = Blob.valueOf(key);

        AppConfig__c mc2 = AppConfig__c.getValues('ForSmartQIV');
        string key2 = (mc2 == null ? 'ivkeytestforsmar' : mc2.Value__c);
        ivKey = Blob.valueOf(key2);
    }

    
    public static String POPUP_EVENT_NAME{
        get{
            String DEFAULT_NAME = 'PopupInfo';
            if(POPUP_EVENT_NAME == null){
                try{
                    POPUP_EVENT_NAME = DEFAULT_NAME;
                    List<App_Config__mdt> eventName = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Popup_Event'];           
                        if (eventName != null) {
                            POPUP_EVENT_NAME = String.valueOf(eventName.get(0).Value__c);
                        }           
                        
                    }catch( Exception e ){
                        POPUP_EVENT_NAME = DEFAULT_NAME;
                    }
            }
            return POPUP_EVENT_NAME;
            
        }set;
    }


    public static Map<String,String> callcenterPermission{
        get{ 
            if(callcenterPermission == null)
            {
                callcenterPermission = new Map<String,String>();
                List<Call_Center_Permission__mdt> ccPermissonList = [SELECT Profile__c FROM Call_Center_Permission__mdt ];  
                for(Call_Center_Permission__mdt profile : ccPermissonList)
                {
                    callcenterPermission.put(profile.Profile__c,profile.Profile__c);
                }
            }  
            return callcenterPermission;       
        }
        set;
    }

    public class initData {
        @AuraEnabled
        public String AgentId;
        @AuraEnabled
        public String EventName; 
        @AuraEnabled
        public Boolean Permission; 
    }

    @AuraEnabled
    public static initData initAgentId(){
        System.debug(UserInfo.getUserId());
        try {
            List<User> result = [SELECT Employee_ID__c,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            initData initdata = new initData();
            initdata.AgentId = result.get(0).Employee_ID__c;
            initdata.EventName = POPUP_EVENT_NAME;
            initdata.Permission = callcenterPermission.containsKey(result.get(0).Profile.Name) ? true : false;
            System.debug(result.get(0).Profile.Name);
            return initdata;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
       
    }

    private static ContactCenter_Handler__c getCCHandler(String actionType) {
        return [SELECT Id
                    ,Action__c
                    ,Field__c
                    ,IsActive__c
                    ,ObjectOperation__c
                    ,ObjectRedirect__c 
                    ,FieldForTab__c
                    ,RMIDSearchField__c
                    ,PhoneSearchField__c
                    ,url__c
                    ,ResultField__c
                    ,Field_2__c
                From ContactCenter_Handler__c 
                WHERE IsActive__c=true AND Action__c =: actionType];
    }

    private static void addRecord(List<SObject> scope
                           ,ContactCenter_Handler__c ccHandler
                           ,List<PhoneNumberMatch> retLst
                           ,String decryptData
                           ,String searchType
                           ,Datetime startDatetime
                           ) {
        
        List<Id> idLst= new List<Id>();

        for (SObject sobj : scope) {
            idLst.add(sobj.Id);
        }
        String query = 'SELECT '+ccHandler.ResultField__c+' FROM '+ccHandler.ObjectOperation__c
                        +' WHERE Id in (\''+String.join(idLst,'\',\'')+'\')';
        System.debug(scope);

        List<SObject> sobjList = Database.query(query);
        List<String> resultFieldLst = ccHandler.ResultField__c.split(',');
        
        for (SObject sobj : sobjList) {
            PhoneNumberMatch record = new PhoneNumberMatch();
            record.sfidForTab  = String.Valueof(sobj.get(ccHandler.FieldForTab__c));
            record.urlret = ccHandler.url__c;
            for(String field : resultFieldLst) {
                if (!field.contains('.')) {
                    System.debug(field);
                    System.debug(sobj);
                    record.urlret = record.urlret.replace('{'+field+'}',String.Valueof(sobj.get(field)));
                }
                
            }
            retLst.add(record);

            //insert log for success case
            RTL_Utility.InsertRTOnlineLog(String.valueof(sobj.getSObject('Customer__r').get('Name'))
                         ,String.valueof(sobj.getSObject('Customer__r').get('TMB_Customer_ID_PE__c'))
                         ,UserInfo.getName()
                         ,String.valueof(sobj.Id)
                         ,'Success Create VerifyHistory ' + decryptData
                         ,String.valueof(sobj.getSObject('Customer__r').get('Core_Banking_Suggested_Segment__c'))
                         ,String.valueof(sobj.get('Customer__c'))
                         ,startDatetime
                         ,DateTime.now()
                         ,searchType
                         ,true);
        }
    }
    
    @AuraEnabled
    global static Object service_contactcenterLightning(String service
                                            ,String dataJson
                                            ,String taskId
                                            ,String msLogId) {
        Datetime startDatetime = Datetime.now();
        String searchType = CCPIN_FUNCTION;

        try {
                ContactCenter_Handler__c ccHandler = getCCHandler(service);
                String objectRedirect = ccHandler.ObjectRedirect__c;
                String enableField    = ccHandler.Field__c;
                List<String> enableFieldLst = enableField.split(',');
                if (ccHandler.Field_2__c != null && ccHandler.Field_2__c.length() > 0) {
                    enableFieldLst.addAll(ccHandler.Field_2__c.split(','));
                }
                System.debug(JSON.serializePretty(enableFieldLst));

                String objectName = ccHandler.ObjectOperation__c;

                Map<String, Schema.SObjectField> FIELDMAP 
                            = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                System.debug(FIELDMAP);

                Set<String> extKeySet = new Set<String>();

                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(dataJson);

                Map<String,String> dataObjMap= new Map<String,String>();

                for(String strKey: dataMap.keyset())
                {
                    dataObjMap.put(strKey, String.valueof(dataMap.get(strKey)));   
                }
                String rmidVal = String.ValueOf(dataObjMap.get(ccHandler.RMIDSearchField__c));
                String phoneVal = String.ValueOf(dataObjMap.get(ccHandler.PhoneSearchField__c));
                System.debug(msLogId);
                System.debug(ccHandler.RMIDSearchField__c);
                System.debug(phoneVal);
                System.debug(JSON.serializePretty(dataObjMap));
            	System.debug('rmidVal-->' + rmidVal);
                // DateTime dateVal = DateTime.valueOf(dataObjMap.get('Verification_Date_Time__c'));

                // dataObjMap.put('Verification_Date_Time__c', DateTime.valueOf(dataObjMap.get('Verification_Date_Time__c')));

                List<PhoneNumberMatch> retSearchLst = null;

                if (rmidVal != null && rmidVal.length() > 0) {
                    //search by rmid
                    // String rmidEncypted = encyptText(rmidVal);
                    System.debug('rmid');
                    retSearchLst = getAccountByRmId(rmidVal,searchType, msLogId);

                    dataObjMap.put('Customer__c'
                              , String.valueof(retSearchLst.get(0).ACCOUNT_SF_ID));
                }else {
                    //search by phone
                    retSearchLst = getValues(phoneVal,searchType, msLogId);  
                    if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                    ) {
                        System.debug(JSON.serializePretty(dataObjMap));
                        dataObjMap.put('TMB_Cust_ID__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));

                        dataObjMap.put('Customer__r.TMB_Customer_ID_PE__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));  
                                  
                    }
                }
                System.debug('retSearchLst-->' + JSON.serializePretty(retSearchLst));
                if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                ) {

                        System.debug(taskId);
                        List<Task> taskToUpdate = [SELECT Id, WhatId FROM Task WHERE Id = :taskId];
                        if(taskToUpdate.size() > 0){
                            if(String.isEmpty(taskToUpdate.get(0).WhatId)){
                                taskToUpdate.get(0).WhatId = retSearchLst.get(0).ACCOUNT_SF_ID;
                                update taskToUpdate;
                            }
                        }
                        
                        List<PhoneNumberMatch> retLst = new List<PhoneNumberMatch>();
                        for (String key : FIELDMAP.keyset()) {
                            Schema.SObjectField fieldObj = FIELDMAP.get(key);
                            Schema.DescribeFieldResult F = fieldObj.getDescribe();
                            if (F.isExternalID()) {
                                extKeySet.add(key);
                            }
                        }

                        SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                        System.debug('dataObjMap-->' + JSON.serializePretty(dataObjMap));
                        for (String field : dataObjMap.keySet()) {
                            if (!enableFieldLst.contains(field)) {
                                System.debug(' <> ' + field);
                                RTL_Utility.InsertRTOnlineLog(
                                                    null
                                                    ,retSearchLst.get(0).ACCOUNT_TMBCUSTID
                                                    ,UserInfo.getName()
                                                    ,msLogId
                                                    ,'this field '+ field +' is not allowed to execute.'
                                                    ,null
                                                    ,null
                                                    ,startDatetime
                                                    ,DateTime.now()
                                                    ,searchType
                                                    ,false);
                                System.debug('----------');
                                return 'a1234';
                            }
                            
                            RTL_Utility.setRelationData(sObj,FIELDMAP,field, dataObjMap,false);
                        }         

                        List<SObject> scope = new List<SObject>();
                        scope.add(sObj);

                        System.debug('scope-->' + JSON.serializePretty(scope));
                        if (dataObjMap.keySet().contains('Id') || dataObjMap.keySet().contains('ID')) {
                            //do update
                            scope = RTL_Utility.doDBOperation(RTL_Utility.UPDATE_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,'Id'
                                                    );
                            addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,dataJson
                                ,searchType
                                ,startDatetime
                                );
                            return retLst;
                        }

                        for (String field : dataObjMap.keySet()) {
                            if (extKeySet.contains(field)) {
                                //do upsert
                                System.debug('ext');
                                scope = RTL_Utility.doDBOperation(RTL_Utility.UPSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,field
                                                    );

                                addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,dataJson
                                ,searchType
                                ,startDatetime
                                );

                                return retLst;
                            }
                        }
                        System.debug(scope);
                        scope = RTL_Utility.doDBOperation(RTL_Utility.INSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,'Id'
                                                    );
  						System.debug(scope);
                        addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,dataJson
                                ,searchType
                                ,startDatetime
                                );
                        System.debug('Result:' + JSON.deserializeUntyped(JSON.serialize(retLst)));
                        return JSON.deserializeUntyped(JSON.serialize(retLst));
                }else {
                    return JSON.deserializeUntyped(JSON.serialize(retSearchLst));
                }
            // }
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            RTL_Utility.InsertRTOnlineLog( searchType
                                          ,startDatetime
                                          ,e);
            return null;
        }
    }


    private static List<PhoneNumberMatch> getAccountByRmId(String rmid,String searchType, String msLogId) {
    	DateTime startDatetime = DateTime.now();

        List<PhoneNumberMatch> phoneList = new List<PhoneNumberMatch>();
        // String rmid = decryptText(encpData);

        List<Account> accList = [SELECT Id  
                                        ,Name 
                                        ,TMB_Customer_ID_PE__c
                                        ,Core_Banking_Suggested_Segment__c
                                 FROM Account WHERE
                                      TMB_Customer_ID_PE__c = : rmid LIMIT 1];

        if (accList != null && accList.size() > 0) {
            Account acc = accList.get(0);
            PhoneNumberMatch phone = new PhoneNumberMatch();
            phone.ACCOUNT_SF_ID = acc.Id;
            phone.ACCOUNT_TMBCUSTID = acc.TMB_Customer_ID_PE__c;
            phoneList.add(phone);

            System.debug(phone);
            RTL_Utility.InsertRTOnlineLog(acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_CUSTOMER
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
        }else {
            System.debug('else');
            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();

            phoneNumber.GLOBAL_SEARCH_OBJ = '001';
            phoneNumber.GLOBAL_SEARCH_VAL = rmid;

            phoneList.add(phoneNumber);
            RTL_Utility.InsertRTOnlineLog(null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.NO_FOUND
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,false);
        }

    	return phoneList;
    }

    private static List<PhoneNumberMatch> getValues(String phoneValue,String searchType, String msLogId) {
        DateTime startDatetime = DateTime.now();

        List<PhoneNumberMatch> phoneList = new List<PhoneNumberMatch>();
        //query contact
        List<Contact> contactList = querySOSLContact(phoneValue);
        Map<String,String> mapValue = new Map<String,String>();
        if (contactList != null && contactList.size() == 1) {
            Contact contact = contactList.get(0);

            if (contact != null && contact.AccountId != null) {
                Account acc = [SELECT Id
                                ,Name
                                ,TMB_Customer_ID_PE__c
                                ,Core_Banking_Suggested_Segment__c 
                                FROM Account Where Id =: contact.AccountId];

                if (acc.TMB_Customer_ID_PE__c != null) {
                    RTL_Utility.InsertRTOnlineLog(
                                            acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_CUSTOMER
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
                }else {
                    RTL_Utility.InsertRTOnlineLog(
                                            acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_PROSPECT
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
                }

                PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
                phoneNumber.ACCOUNT_SF_ID = contact.AccountId;
                phoneNumber.ACCOUNT_TMBCUSTID = acc.TMB_Customer_ID_PE__c;
                phoneList.add(phoneNumber);
                return phoneList;
            }else {
                // no account
                PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
                phoneNumber.GLOBAL_SEARCH_OBJ = '003';
                phoneNumber.GLOBAL_SEARCH_VAL = phoneValue;
                phoneList.add(phoneNumber);

                RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_CONTACT
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);

                return phoneList;
            }
        }if (contactList != null && contactList.size() > 1) {
            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.GLOBAL_SEARCH_OBJ = '003';
            phoneNumber.GLOBAL_SEARCH_VAL = phoneValue;
            phoneList.add(phoneNumber);

            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_CONTACT
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
            
            return phoneList;
        }
        

        //query account and prospect
        List<Account> accList = querySOSLAccount(phoneValue);
        if (accList != null && accList.size() == 1) {
            Account acc = accList.get(0);

            if (acc != null && acc.TMB_Customer_ID_PE__c != null && acc.TMB_Customer_ID_PE__c.length() > 0) {
                    RTL_Utility.InsertRTOnlineLog(
                                            acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_CUSTOMER
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
            }else {
                RTL_Utility.InsertRTOnlineLog(
                                            acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_PROSPECT
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
            }

            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.ACCOUNT_SF_ID = acc.Id;
            phoneNumber.ACCOUNT_TMBCUSTID = acc.TMB_Customer_ID_PE__c;
            phoneList.add(phoneNumber);
            return phoneList;
        }else if (accList != null && accList.size() > 1)  {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_ACCOUNT
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);

            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.GLOBAL_SEARCH_OBJ = '001';
            phoneNumber.GLOBAL_SEARCH_VAL = phoneValue;
            phoneList.add(phoneNumber);
            return phoneList;
        }
        //query lead
        List<Lead> leadList = querySOSLLead(phoneValue);


        if (leadList != null && leadList.size() == 1) {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_AS_LEAD
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);

            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.LEAD_SF_ID = leadList.get(0).Id;
            System.debug(phoneNumber);
            phoneList.add(phoneNumber);
            return phoneList;
        }else if (leadList != null && leadList.size() > 1)  {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_LEAD
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);

            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.GLOBAL_SEARCH_OBJ = '00Q';
            phoneNumber.GLOBAL_SEARCH_VAL = phoneValue;
            phoneList.add(phoneNumber);
            return phoneList;
        }else {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,msLogId
                                            ,RTL_Utility.NO_FOUND
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
            
            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.GLOBAL_SEARCH_OBJ = '';
            phoneNumber.GLOBAL_SEARCH_VAL = phoneValue;
            phoneList.add(phoneNumber);
            return phoneList;
        }
    }


    private static List<Contact> querySOSLContact(String phoneValue) {
        String searchquery= 'FIND {'+phoneValue+'} IN PHONE FIELDS RETURNING Contact (Id,Name,AccountId,HomePhone,Phone,MobilePhone)';
        List<List<Contact>> listofcontactList = search.query(searchquery);
        return listofcontactList.get(0);
    }

    private static List<Account> querySOSLAccount(String phoneValue) {
        String searchquery= 'FIND {'+phoneValue+'} IN PHONE FIELDS RETURNING Account (Id,Name,RTL_Alternative_Number__c,Phone,RTL_Contact_Person_Number_1__c,RTL_Contact_Person_Number_2__c,Mobile_Number_PE__c,RTL_Office_Phone_Number__c,TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c)';
        List<List<Account>> listofAccList = search.query(searchquery);
        return listofAccList.get(0);
    }

    private static List<Lead> querySOSLLead(String phoneValue) {
        String searchquery= 'FIND {'+phoneValue+'} IN PHONE FIELDS RETURNING Lead (Id,Name,MobilePhone,Phone,Phone__c,Mobile_No__c,RTL_Mobile_Number__c,RTL_Phone_Number__c)';
        List<List<Lead>> listofLeadList = search.query(searchquery);
        return listofLeadList.get(0);
    }

    @AuraEnabled
    public static Map<String, Object> getAccountByTask(String taskId, String newTaskId, String callNumber){

        Map<String, Object> retSearchLst = new Map<String, Object>();
        String searchType = CCPIN_FUNCTION;
        String msLogId = '';
        String accountId = '';
        System.debug(taskId);
        System.debug(newTaskId);
        System.debug('callNumber:'+callNumber);
        //Get customer id from old task before transfer
        List<Task> result = [SELECT Id, WhatId, Call_Number__c FROM Task WHERE Id = :taskId LIMIT 1];
        if(result.size() > 0){
            accountId = result.get(0).WhatId;
            //Update new task for new agent
            List<Task> newTask = [SELECT Id, WhatId FROM Task WHERE Id = :newTaskId LIMIT 1];
    
            if(newTask.size() > 0 && String.isNotBlank(accountId)){
                
                // if(newTask.get(0).WhatId == null || newTask.get(0).WhatId == ''){

                if(String.isEmpty(newTask.get(0).WhatId)){
                    newTask.get(0).WhatId = accountId;
    
                    update newTask;
                }
                retSearchLst.put('ACCOUNT_ID', accountId);

            } else if (String.isBlank(accountId)){
                retSearchLst.put('GLOBAL_SEARCH', result.get(0).Call_Number__c);
                System.debug('getValues');
                System.debug(retSearchLst);
            }
        }
        else {
            retSearchLst.put('GLOBAL_SEARCH', callNumber);
        }


        System.debug('retSearchLst: ' + retSearchLst);
        return retSearchLst;
    }

    @AuraEnabled
    public static string getCampaignMemberByMarketingCode(String marketing_code, String task_id){

        String memberId = '';
        String acctId = '';
        
        List<CampaignMember> member = [SELECT Id, Customer__r.Id FROM CampaignMember WHERE RTL_Marketing_Code__c = :marketing_code LIMIT 1];
        if(member.size() > 0){
            memberId = member.get(0).Id;
            acctId = member.get(0).Customer__r.Id;
            if(String.isNotBlank(task_id)){
                List<Task> tasks = [SELECT Id, Related_Object__c, WhatId FROM Task WHERE Id = :task_id LIMIT 1];
                if(tasks.size() > 0){
                    if(String.isEmpty(tasks.get(0).Related_Object__c)){
                        tasks.get(0).Related_Object__c = memberId;
                        tasks.get(0).WhatId = acctId;
                        update tasks;
                    }
                }
            }

        }
        
        return memberId;
    }

    @AuraEnabled
    public static void stampTaskSFID(String task_id, String referral_id){
        List<Task> t = [SELECT Id, WhatId FROM Task WHERE Id = :task_id LIMIT 1];
        Id object_id = Id.valueOf(referral_id);
        if(t.size() > 0){
            if(object_id.getSObjectType().getDescribe().getName() == 'RTL_Referral__c'){
                t.get(0).WhatId = referral_id;
            }
            else if (object_id.getSObjectType().getDescribe().getName() == 'Lead'){
                t.get(0).WhoId = referral_id;
            }
        }
        else{
            //Handle error
        }

        update t;
    }

    @AuraEnabled
    public static Map<String, String> preparePopupByUniqueKey(String unique_key, String task_id, String callback_id){

        Map<String, String> return_map = new Map<String, String>();
        String type = '';

        if(String.isNotBlank(callback_id)){
            //Search for callback task and complete it
            List<Task> callbackTask = [SELECT Id, Status FROM Task WHERE /*Call_Log_ID__c = :callback_id AND*/ RecordType.Name = 'Call Back' LIMIT 1];
            if(callbackTask.size() > 0){
                if(callbackTask.get(0).Status != 'Completed'){
                    callbackTask.get(0).Status = 'Completed';
                    update callbackTask;
                }
            }
        }

        try{
            //Campaign Member
            if(unique_key.StartsWith('L') || unique_key.StartsWith('D')){
                
                List<CampaignMember> member = [SELECT Id, Customer__r.Id FROM CampaignMember WHERE RTL_Marketing_Code__c = :unique_key LIMIT 1];
                
                if(member.size() > 0){

                    return_map.put('type', 'CampaignMember');
                    return_map.put('id', member.get(0).Id);

                    String acctId = member.get(0).Customer__r.Id;
                    if(String.isNotBlank(task_id)){
                        List<Task> tasks = [SELECT Id, Related_Object__c, WhatId FROM Task WHERE Id = :task_id LIMIT 1];
                        if(tasks.size() > 0 && String.isEmpty(tasks.get(0).Related_Object__c)){
                            tasks.get(0).Related_Object__c = member.get(0).Id;
                            tasks.get(0).WhatId = acctId;
                            update tasks;
                        }
                    }
                }
            }
            //Lead or referral
            else {

                return_map.put('type', Id.valueOf(unique_key).getSObjectType().getDescribe().getName());
                return_map.put('id', unique_key);

                List<Task> t = [SELECT Id, WhatId FROM Task WHERE Id = :task_id LIMIT 1];

                if(t.size() > 0){
                    if(return_map.get('type') == 'RTL_Referral__c'){
                        t.get(0).WhatId = unique_key;
                    }
                    else if (return_map.get('type') == 'Lead'){
                        t.get(0).WhoId = unique_key;
                    }
                    t.get(0).Related_Object__c = unique_key;
                }

                update t;

            }

        }
        catch(Exception e){
            System.debug(e.getTypeName()+': '+ e.getMessage()+' at ' + e.getStackTraceString());
        }

        return return_map;
    }

    @AuraEnabled
    public static Map<String, String> prepareTransfer(String task_id, String original_task){

        Map<String, String> return_map = new Map<String, String>();
        String type = '';

        List<Task> originalTask = [SELECT Id, Related_Object__c, WhatId, WhoId FROM Task WHERE Id = :original_task LIMIT 1];
        List<Task> newTask = [SELECT Id, Related_Object__c, WhatId, WhoId FROM Task WHERE Id = :task_id LIMIT 1];

        System.debug(originalTask);
        System.debug(newTask);

        if(newTask.size() > 0 && originalTask.size() > 0){

            newTask.get(0).Related_Object__c = originalTask.get(0).Related_Object__c;
            newTask.get(0).WhatId = originalTask.get(0).WhatId;
            newTask.get(0).WhoId = originalTask.get(0).WhoId;

            update newTask;

            Id objId = Id.valueOf(originalTask.get(0).Related_Object__c);
            System.debug('type '+objId.getSObjectType());
            System.debug('id '+objId);

            return_map.put('type', objId.getSObjectType()+'');
            return_map.put('id', objId);
        }

        return return_map;

    }

}