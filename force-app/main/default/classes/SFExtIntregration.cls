global with sharing class SFExtIntregration{
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

    public static String encyptText(String plainText) {
        Blob cipherText = Crypto.encrypt('AES256'
                                        ,smartQueue
                                        ,ivKey
                                        ,Blob.valueOf(plainText));

        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        return encodedCipherText;
    }

    public static String decryptText(String encodedCipherText) {
        if (String.isBlank(encodedCipherText)) return null;
        
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob decryptedBlob = Crypto.decrypt('AES256'
                                            ,smartQueue
                                            , ivKey
                                            ,encodedEncryptedBlob);

       

        String decryptedClearText = decryptedBlob.toString();
        return decryptedClearText;
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

        List<SObject> sobjList = Database.query(query);
        List<String> resultFieldLst = ccHandler.ResultField__c.split(',');
        
        for (SObject sobj : sobjList) {
            PhoneNumberMatch record = new PhoneNumberMatch();
            record.sfidForTab  = String.Valueof(sobj.get(ccHandler.FieldForTab__c));
            record.urlret = ccHandler.url__c;
            for(String field : resultFieldLst) {
                if (!field.contains('.')) {
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

    @RemoteAction
    global static List<PhoneNumberMatch> service_contactcenter(String encpData
                                            ,String taskEncpData
                                            ,String rmid
                                            ,String service
                                            ,String dataJson) {
        Datetime startDatetime = Datetime.now();
        String searchType = CCPIN_FUNCTION;
   
        try {
            if (taskEncpData != null && taskEncpData.length() > 0) {
                return call_interface(encpData,taskEncpData,rmid);
            }else {
                ContactCenter_Handler__c ccHandler = getCCHandler(service);
                String objectRedirect = ccHandler.ObjectRedirect__c;
                String enableField    = ccHandler.Field__c;

                List<String> enableFieldLst = enableField.split(',');

                if (ccHandler.Field_2__c != null && ccHandler.Field_2__c.length() > 0) {
                    enableFieldLst.addAll(ccHandler.Field_2__c.split(','));
                }

                String objectName = ccHandler.ObjectOperation__c;

                Map<String, Schema.SObjectField> FIELDMAP 
                            = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


                Set<String> extKeySet = new Set<String>();
                
                String decryptData = decryptText(dataJson);
                call_inquiry_interface(decryptData, encpData, rmid);

                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(decryptData);

                Map<String,String> dataObjMap= new Map<String,String>();

                for(String strKey: dataMap.keyset())
                {
                    dataObjMap.put(strKey, String.valueof(dataMap.get(strKey)));   
                }
                String rmidVal = String.ValueOf(dataObjMap.get(ccHandler.RMIDSearchField__c));
                String phoneVal = String.ValueOf(dataObjMap.get(ccHandler.PhoneSearchField__c));

                List<PhoneNumberMatch> retSearchLst = null;

                if (rmidVal != null && rmidVal.length() > 0) {
                    //search by rmid
                    String rmidEncypted = encyptText(rmidVal);
                    retSearchLst = getAccountByRmId(rmidEncypted,searchType);
                }else {
                    //search by phone
                    retSearchLst = getValues(phoneVal,searchType);  
                    if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                    ) {
                        dataObjMap.put('TMB_Cust_ID__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));

                        dataObjMap.put('Customer__r.TMB_Customer_ID_PE__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));  
                    }
                }

                if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                ) {
                        
                        List<PhoneNumberMatch> retLst = new List<PhoneNumberMatch>();
                        for (String key : FIELDMAP.keyset()) {
                            Schema.SObjectField fieldObj = FIELDMAP.get(key);
                            Schema.DescribeFieldResult F = fieldObj.getDescribe();
                            if (F.isExternalID()) {
                                extKeySet.add(key);
                            }
                        }

                        SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                        for (String field : dataObjMap.keySet()) {
                            if (!enableFieldLst.contains(field)) {
                                RTL_Utility.InsertRTOnlineLog(
                                                    null
                                                    ,rmid
                                                    ,UserInfo.getName()
                                                    ,null
                                                    ,'this field '+ field +' is not allowed to execute.'
                                                    ,null
                                                    ,null
                                                    ,startDatetime
                                                    ,DateTime.now()
                                                    ,searchType
                                                    ,false);
                                return null;
                            }
                            
                            RTL_Utility.setRelationData(sObj,FIELDMAP,field, dataObjMap,false);
                        }         

                        List<SObject> scope = new List<SObject>();
                        scope.add(sObj);

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
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );

                            return retLst;
                        }

                        for (String field : dataObjMap.keySet()) {
                            if (extKeySet.contains(field)) {
                                //do upsert
                                scope = RTL_Utility.doDBOperation(RTL_Utility.UPSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,field
                                                    );

                                addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );

                                return retLst;
                            }
                        }

                        scope = RTL_Utility.doDBOperation(RTL_Utility.INSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,'Id'
                                                    );
                        
                        addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );
                        
                        return retLst;
                }else {
                    return retSearchLst;
                }
            }
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            RTL_Utility.InsertRTOnlineLog( searchType
                                          ,startDatetime
                                          ,e);
            return null;
        }
    }

    @AuraEnabled
    global static Object service_contactcenterLightning(String encpData
                                            ,String taskEncpData
                                            ,String rmid
                                            ,String service
                                            ,String dataJson) {
        Datetime startDatetime = Datetime.now();
        String searchType = CCPIN_FUNCTION;

        try {
            if (taskEncpData != null && taskEncpData.length() > 0) {
                return call_interface(encpData,taskEncpData,rmid);
            }else {
                ContactCenter_Handler__c ccHandler = getCCHandler(service);
                String objectRedirect = ccHandler.ObjectRedirect__c;
                String enableField    = ccHandler.Field__c;

                List<String> enableFieldLst = enableField.split(',');

                if (ccHandler.Field_2__c != null && ccHandler.Field_2__c.length() > 0) {
                    enableFieldLst.addAll(ccHandler.Field_2__c.split(','));
                }

                String objectName = ccHandler.ObjectOperation__c;

                Map<String, Schema.SObjectField> FIELDMAP 
                            = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

                String decryptData = decryptText(dataJson);
                call_inquiry_interface(decryptData, encpData, rmid);

                Set<String> extKeySet = new Set<String>();

                Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(decryptData);

                Map<String,String> dataObjMap= new Map<String,String>();

                for(String strKey: dataMap.keyset())
                {
                    dataObjMap.put(strKey, String.valueof(dataMap.get(strKey)));   
                }

                String rmidVal = String.ValueOf(dataObjMap.get(ccHandler.RMIDSearchField__c));
                String phoneVal = String.ValueOf(dataObjMap.get(ccHandler.PhoneSearchField__c));

                List<PhoneNumberMatch> retSearchLst = null;

                if (rmidVal != null && rmidVal.length() > 0) {
                    //search by rmid
                    String rmidEncypted = encyptText(rmidVal);
                    retSearchLst = getAccountByRmId(rmidEncypted,searchType);
                }else {
                    //search by phone
                    retSearchLst = getValues(phoneVal,searchType);  
                    if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                    ) {
                        dataObjMap.put('TMB_Cust_ID__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));

                        dataObjMap.put('Customer__r.TMB_Customer_ID_PE__c'
                                  , String.valueof(retSearchLst.get(0).ACCOUNT_TMBCUSTID));  
                    }
                }

                if (retSearchLst != null 
                        && retSearchLst.size() == 1 
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_SF_ID)
                        && !String.isEmpty(retSearchLst.get(0).ACCOUNT_TMBCUSTID)
                ) {
                        
                        List<PhoneNumberMatch> retLst = new List<PhoneNumberMatch>();
                        for (String key : FIELDMAP.keyset()) {
                            Schema.SObjectField fieldObj = FIELDMAP.get(key);
                            Schema.DescribeFieldResult F = fieldObj.getDescribe();
                            if (F.isExternalID()) {
                                extKeySet.add(key);
                            }
                        }

                        SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                        for (String field : dataObjMap.keySet()) {
                            if (!enableFieldLst.contains(field)) {
                                RTL_Utility.InsertRTOnlineLog(
                                                    null
                                                    ,rmid
                                                    ,UserInfo.getName()
                                                    ,null
                                                    ,'this field '+ field +' is not allowed to execute.'
                                                    ,null
                                                    ,null
                                                    ,startDatetime
                                                    ,DateTime.now()
                                                    ,searchType
                                                    ,false);
                                return null;
                            }
                            
                            RTL_Utility.setRelationData(sObj,FIELDMAP,field, dataObjMap,false);
                        }         

                        List<SObject> scope = new List<SObject>();
                        scope.add(sObj);

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
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );

                            return retLst;
                        }

                        for (String field : dataObjMap.keySet()) {
                            if (extKeySet.contains(field)) {
                                //do upsert
                                scope = RTL_Utility.doDBOperation(RTL_Utility.UPSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,field
                                                    );

                                addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );

                                return retLst;
                            }
                        }

                        scope = RTL_Utility.doDBOperation(RTL_Utility.INSERT_RECORD
                                                    ,scope
                                                    ,startDatetime
                                                    ,searchType
                                                    ,'Id'
                                                    );
                        
                        addRecord(scope
                                ,ccHandler
                                ,retLst
                                ,decryptData
                                ,searchType
                                ,startDatetime
                                );
                        
                        return JSON.deserializeUntyped(JSON.serialize(retLst));
                }else {
                    return JSON.deserializeUntyped(JSON.serialize(retSearchLst));
                }
            }
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            RTL_Utility.InsertRTOnlineLog( searchType
                                          ,startDatetime
                                          ,e);
            return null;
        }
    }

    @RemoteAction
    global static List<PhoneNumberMatch> call_interface(String encpData,String taskEncpData,String rmid) {
    	Datetime startDatetime = Datetime.now();
    	String searchType = NICE_SEARCH_POPUP;
    	try {
            if (taskEncpData != null && taskEncpData.length() > 0) {
                try {
                    searchType = FINEESE_SEARCH_POPUP;
                    String taskObjstr = decryptText(taskEncpData);

                    Task taskObj = (Task)JSON.deserialize(taskObjstr ,Task.class);

                    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                          .get('Call_Log_Record_Type').getRecordTypeId();

                    taskObj.Subject = 'Call Log';
                    taskObj.Status = 'Completed';
                    taskObj.RecordTypeId = recordTypeId;
                    insert taskObj;
                }catch(Exception e) {
                    RTL_Utility.InsertRTOnlineLog(
                                                    null
                                                    ,null
                                                    ,UserInfo.getName()
                                                    ,null
                                                    ,e.getMessage()
                                                    ,null
                                                    ,null
                                                    ,startDatetime
                                                    ,DateTime.now()
                                                    ,searchType
                                                    ,false);
                }
                String phoneValue = decryptText(encpData);
                return getValues(phoneValue,searchType);
            }else if (rmid != null && rmid.length() > 0 ) {
                return getAccountByRmId(rmid,APPOINTMENT_SEARCH_POPUP);
            }else {
                String phoneValue = customDecryptText(encpData);
                return getValues(phoneValue,searchType);   
            }
        }catch (Exception e) {
            RTL_Utility.InsertRTOnlineLog(
                                                    null
                                                    ,rmid
                                                    ,UserInfo.getName()
                                                    ,null
                                                    ,e.getMessage()
                                                    ,null
                                                    ,null
                                                    ,startDatetime
                                                    ,DateTime.now()
                                                    ,searchType
                                                    ,false);
            return null;
        }
    	
    }

    @AuraEnabled
    global static Object call_interfaceLightning(String encpData, String taskEncpData, String rmid){
        List<PhoneNumberMatch> tmp = call_interface(encpData, taskEncpData, rmid);
        return JSON.deserializeUntyped(JSON.serialize(tmp));
    }

    @RemoteAction
    global static void call_inquiry_interface(String decryptData,String encpData, String rmid) {
    	Datetime startDatetime = Datetime.now();
        String searchType = NICE_SEARCH_POPUP;
    	try {
            if (decryptData != null && decryptData.length() > 0) {
                try {
                    searchType = CCPIN_FUNCTION;
                    Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(decryptData);
                    Map<String, String> dataObjMap = new Map<String, String>();
                    for(String strKey: dataMap.keyset())
                    {
                        dataObjMap.put(strKey, String.valueof(dataMap.get(strKey)));   
                    }
                    Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Call_Log_Record_Type').getRecordTypeId();
                    Task taskObj = new Task();
                    taskObj.Subject = 'Call Log';
                    taskObj.RecordTypeId = recordTypeId;
                    taskObj.Status = 'Completed';
                    taskObj.Call_Number__c = (dataObjMap.get('Phone_Number__c')!=null && dataObjMap.get('Phone_Number__c') != '')?dataObjMap.get('Phone_Number__c'):'';
                    taskObj.Call_Log_Id__c = (dataObjMap.get('Call_ID__c')!=null && dataObjMap.get('Call_ID__c') != '')?dataObjMap.get('Call_ID__c'):'';
                    taskObj.Call_Agent_Id__c = (dataObjMap.get('Employee_ID__c')!=null && dataObjMap.get('Employee_ID__c') != '')?dataObjMap.get('Employee_ID__c'):'';
                    // taskObj.Call_Start_Datetime__c = ()?DateTime.valueOf(dataObjMap.get('Call_Start_Datetime__c')):'';
                    if (dataObjMap.get('Verification_Date_Time__c')!=null && dataObjMap.get('Verification_Date_Time__c') != ''){
                        String DT = dataObjMap.get('Verification_Date_Time__c');
                        DateTime startDate = Datetime.valueofGmt(DT.replace('T', ' ').replace('Z', ''));
                        taskObj.Call_Start_Datetime__c = startDate;
                    }
                    taskObj.OwnerId = UserInfo.getUserId();
                    insert taskObj;
                }catch(Exception e) {
                   // Do nothing
                   System.Debug(e.getMessage());
                }
            }
        }catch (Exception e) {
            //Do nothing
        }
    	
    }


    private static List<PhoneNumberMatch> getAccountByRmId(String encpData,String searchType) {
    	DateTime startDatetime = DateTime.now();

        List<PhoneNumberMatch> phoneList = new List<PhoneNumberMatch>();
        String rmid = decryptText(encpData);

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

            RTL_Utility.InsertRTOnlineLog(acc.Name 
                                            ,acc.TMB_Customer_ID_PE__c
                                            ,UserInfo.getName()
                                            ,null
                                            ,RTL_Utility.FOUND_AS_CUSTOMER
                                            ,acc.Core_Banking_Suggested_Segment__c
                                            ,acc.Id
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);
        }else {
            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();

            phoneNumber.GLOBAL_SEARCH_OBJ = '001';
            phoneNumber.GLOBAL_SEARCH_VAL = rmid;

            phoneList.add(phoneNumber);
            RTL_Utility.InsertRTOnlineLog(null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
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

    private static List<PhoneNumberMatch> getValues(String phoneValue,String searchType) {
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
                                            ,null
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
                                            ,null
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
                                            ,null
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
                                            ,null
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
                                            ,null
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
                                            ,null
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
            phoneList.add(phoneNumber);
            return phoneList;
        }else if (accList != null && accList.size() > 1)  {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
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
                                            ,null
                                            ,RTL_Utility.FOUND_AS_LEAD
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,DateTime.now()
                                            ,searchType
                                            ,true);

            PhoneNumberMatch phoneNumber = new PhoneNumberMatch();
            phoneNumber.LEAD_SF_ID = leadList.get(0).Id;
            phoneList.add(phoneNumber);
            return phoneList;
        }else if (leadList != null && leadList.size() > 1)  {
            RTL_Utility.InsertRTOnlineLog(
                                             null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
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
                                            ,null
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

    public static String customEncryptText(String plainText) {
        String salt = customKeyEncypted;

        String[] plainCharacters = plainText.split('');
        String[] saltCharacters  = salt.split('');

        String encyptedText = '';
        for (Integer i = 0;i<plainText.length();i++) {
            String plainNumber = plainCharacters[i];
            encyptedText += saltCharacters[Integer.valueOf(plainNumber)];
        }
        return encyptedText;
    }

    public static String customDecryptText(String encodedCipherText) {
        String salt = customKeyEncypted;

        String[] encodedCipherCharacters = encodedCipherText.split('');
        String[] saltCharacters  = salt.split('');

        String decyptedText = '';

        for (Integer i = 0;i<encodedCipherText.length();i++) {
            String plainNumber = encodedCipherCharacters[i];
            decyptedText += salt.indexOf(plainNumber);
        }
        return decyptedText;
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

}