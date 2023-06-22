public with sharing class RTL_Utility {
    public static String NBO_STATUS_ACCEPTEDALL = System.Label.RTL_NBO_Status_Accepted_All;
    public static String NBO_STATUS_INVALID = System.Label.RTL_NBO_Status_Invalid;
    public static String NBO_STATUS_NEW = System.Label.RTL_NBO_Status_New;
    public static String NBO_STATUS_REJECTEDALL = System.Label.RTL_NBO_Status_Rejected_All;
    /*
    *This method is used to retrieve a list of record type Ids based on the SObject and record type Developer Name prefix
    */
    public static Set<Id> getObjectRecordTypeIdsByDevNamePrefix(SObjectType sObjectType, String recordTypeDevNamePrefix) {
        Set<Id> recordTypeIds = new Set<Id>();
        
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String,Schema.RecordTypeInfo> rtMapByName = sObjectType.getDescribe().getRecordTypeInfosByName();

        for (String rtName : rtMapByName.keySet()){
            if (rtName.startsWith(recordTypeDevNamePrefix)) {
                recordTypeIds.add(rtMapByName.get(rtName).getRecordTypeId());
            }
        }

        //Retrieve the record type id by name
        return recordTypeIds;
    } 
    
    public static Map<String, Id> getObjectRecordTypeMap(String objectType) {//the key is record type developer name, the value is record type id
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt: [select Id, developername from RecordType where SobjectType = :objectType]) {
            rtMap.put(rt.developername, rt.Id);
        }
        return rtMap;
    }
    
    public static List<RTL_NBO_History_Product__c> validNBOProduct(List<RTL_NBO_History_Product__c> nboHistoryProductList, boolean isUpdate) {
        //Store the list of retail product master
        Set<String> retailProductbyGroupList = new Set<String>();//the key is product group
        Map<String, RTL_product_master__c> retailProductbySubGroupMap = new Map<String, RTL_product_master__c>();//the key is product subgroup
        Map<String, RTL_product_master__c> retailProductbyNameMap = new Map<String, RTL_product_master__c> (); //the key is product name
        for(RTL_product_master__c retailProduct : [Select Name, Product_Group__c, Product_Sub_group__c, RTL_Product_Smart_Info__c from RTL_product_master__c where Active__c = true]) {
            retailProductbyGroupList.add(toLowerCase(retailProduct.Product_Group__c));
            if (retailProductbySubGroupMap.get(toLowerCase(retailProduct.Product_Sub_group__c)) == null)
                retailProductbySubGroupMap.put(toLowerCase(retailProduct.Product_Sub_group__c), retailProduct);
            if (retailProductbyNameMap.get(toLowerCase(retailProduct.Name)) == null)    
                retailProductbyNameMap.put(toLowerCase(retailProduct.Name), retailProduct);
        }

        // get the list of NBO External ID to retrieve the related NBO History
        Set<String> nboExternalIdList = new Set<String>();
        for (RTL_NBO_History_Product__c nboHisProduct: nboHistoryProductList) {
            nboExternalIdList.add(nboHisProduct.RTL_NBO_ID__c);
        }
        
        //get the list of NBO History related with NBO History Product by exteranl NBO ID
        Map<String, RTL_NBO_History__c> nboHistoryExistingList = new Map<String, RTL_NBO_History__c>();//the key is NBO external Id
        for(RTL_NBO_History__c nboHis : [Select RTL_NBO_ID__c, RTL_Status__c from RTL_NBO_History__c where RTL_NBO_ID__c in : nboExternalIdList]) {
            nboHistoryExistingList.put(nboHis.RTL_NBO_ID__c, nboHis);
        }
        
        //get the list of NBO History product by exteranl NBO ID, for checking of duplication
        Set<String> nboHistoryProdExistingList = new Set<String>();
        if (!isUpdate) {
            for(RTL_NBO_History_Product__c nboHisProduct : [Select RTL_NBO_ID__c, RTL_Product__c, RTL_Product_Group__c,  RTL_Product_SubGroup__c from RTL_NBO_History_Product__c where RTL_NBO_ID__c in : nboExternalIdList]) {
                nboHistoryProdExistingList.add(nboHisProduct.RTL_NBO_ID__c + nboHisProduct.RTL_Product__c + nboHisProduct.RTL_Product_Group__c + nboHisProduct.RTL_Product_SubGroup__c);
            }
        } 
        
        Map<String, Id> rtMap = RTL_Utility.getObjectRecordTypeMap('RTL_NBO_History_Product__c');//key is recordtype developer name
        Map<String, String> productGroupMap = RTL_Utility.getNBOProductRecoredTypeMapping();//key is NBO product group          
        
        //Id userId = UserInfo.getUserId();
        //User currentUser = [select Region_Code__c, Zone_Code__c, RTL_Branch_Code__c from User where Id = :userId];
          
        String nboProductNameOrig, nboProductGroupOrig, nboProductSubGroupOrig = null;         
        String nboProductName, nboProductGroup, nboProductSubGroup = null;   
        RTL_NBO_History__c nboHis = null;
        RTL_product_master__c retailProduct = null;

        for (RTL_NBO_History_Product__c nboHisProduct: nboHistoryProductList) {//validate each NBO product
            //populate current user branch/region/zone information to NBO Product
            //nboHisProduct.RTL_User_Branch__c = currentUser.RTL_Branch_Code__c;//update user info by task object
            //nboHisProduct.RTL_User_Region__c = currentUser.Region_Code__c;//update user info by task object
            //nboHisProduct.RTL_User_Zone__c = currentUser.Zone_Code__c;//update user info by task object
            //validate each NBO product/group/subgroup (assume backend will pass only one of them)
            nboProductNameOrig = nboHisProduct.RTL_Product__c;
            nboProductName = toLowerCase(nboProductNameOrig);
            nboProductGroupOrig = RTL_Utility.convertProductGroup(nboHisProduct.RTL_Product_Group__c);
            nboProductGroup = toLowerCase(nboProductGroupOrig);
            nboProductSubGroupOrig = nboHisProduct.RTL_Product_SubGroup__c;
            nboProductSubGroup = toLowerCase(nboProductSubGroupOrig);       
            nboHis =  nboHistoryExistingList.get(nboHisProduct.RTL_NBO_ID__c);//check if the NBO exists in DB
            if (nboHis == null) {//this NBO History Product doesn't have related NBO History
                nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR001;
                nboHisProduct.RTL_Status__c = 'Invalid';
            } else if (nboHistoryProdExistingList.contains(nboHisProduct.RTL_NBO_ID__c + nboProductName + nboProductGroup + nboProductSubGroup)) {
                //for insertion, skip if the NBO History product exists based on the combination of RTL_NBO_ID__c+RTL_Product__c+RTL_Product_Group__c+RTL_Product_SubGroup__c
                nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR002 + ' NBO ID=' + nboHisProduct.RTL_NBO_ID__c + ', Product Group=' + nboProductGroupOrig + ', Product Subgroup=' + nboProductSubGroupOrig + ', Product Name=' + nboProductNameOrig + '.';     
                nboHisProduct.RTL_Status__c = 'Invalid';
            } else {
                if (!isUpdate) nboHisProduct.RTL_Related_NBO__c = nboHis.Id; //map parent/child relationship
                if (nboProductGroup == null && nboProductSubGroup == null && nboProductName == null) {//all 3 parameters are null
                    nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR003;             
                    nboHisProduct.RTL_Status__c = 'Invalid';
                } else if (nboProductGroup != null && nboProductSubGroup == null && nboProductName == null) { //only product group is provided
                    if (!retailProductbyGroupList.contains(nboProductGroup)) {//invalid NBO product group
                        //valid NBO product will be persisted automatically                    
                        nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR004 + ' Product Group=' + nboProductGroupOrig + '.';  
                        nboHisProduct.RTL_Status__c = 'Invalid';
                    }    
                } else if (nboProductGroup == null && nboProductSubGroup != null && nboProductName == null) {//only product subgroup is provided
                    retailProduct = retailProductbySubGroupMap.get(nboProductSubGroup);
                    if (retailProduct == null) {//invalid NBO product subgroup
                        //valid NBO product will be persisted automatically                    
                        nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR004 + ' Product Subgroup=' + nboProductSubGroupOrig + '.';  
                        nboHisProduct.RTL_Status__c = 'Invalid';
                    } else {//valid NBO product subgroup, find the NBO product group
                        nboHisProduct.RTL_Product_Group__c = RTL_Utility.convertProductGroup(retailProduct.Product_Group__c);
                    }
                } else if (nboProductGroup == null && nboProductSubGroup == null && nboProductName != null) {//only product name is provided
                    retailProduct = retailProductbyNameMap.get(nboProductName);
                    if (retailProduct == null) {//invalid NBO product name
                        //valid NBO product will be persisted automatically                    
                        nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR004 + ' Product Name=' + nboProductNameOrig + '.';  
                        nboHisProduct.RTL_Status__c = 'Invalid';
                    } else {//valid NBO product name, find the NBO product group and subgroup
                        nboHisProduct.RTL_Product_Group__c = RTL_Utility.convertProductGroup(retailProduct.Product_Group__c);
                        nboHisProduct.RTL_Product_SubGroup__c = retailProduct.Product_Sub_group__c;
                        nboHisProduct.RTL_Product_Smart_Info__c = retailProduct.RTL_Product_Smart_Info__c;//update smart info only when Product Name is provided
                    }                                                                  
                } else {
                    nboHisProduct.RTL_Invalid_Product_Reason__c = System.Label.RTL_NBO_ERR004 + ' Product Group=' + nboProductGroupOrig + ', Product Subgroup=' + nboProductSubGroupOrig + ', Product Name=' + nboProductNameOrig + '.';             
                    nboHisProduct.RTL_Status__c = 'Invalid';
                } 
            }  
            if (nboHisProduct != null && nboHisProduct.RTL_Product_Group__c != null && productGroupMap.get(nboHisProduct.RTL_Product_Group__c.toLowerCase()) != null)//set record type based on product group
                nboHisProduct.recordTypeId = rtMap.get(productGroupMap.get(nboHisProduct.RTL_Product_Group__c.toLowerCase()));                  
        }
        return nboHistoryProductList;   
    }
    
    public static String toLowerCase(String input){
        return input != null ? input.toLowerCase() : null;
    }
    
    public static Map<String, String> getNBOProductRecoredTypeMapping() {//the key is NBO product group, the value is NBO product record type developer name
        Map<String, String> mdtMap = new Map<String, String>();
        for (RTL_NBO_Product_Record_Type_Mapping__mdt mdt : [SELECT RTL_Product_Group__c, RTL_Record_Type_DevName__c FROM RTL_NBO_Product_Record_Type_Mapping__mdt]){
            mdtMap.put(mdt.RTL_Product_Group__c.toLowerCase(), mdt.RTL_Record_Type_DevName__c);
        }
        
        return mdtMap;
    }   
    
    /* This method is to convert product group to match with Opportunity Product Group picklist value */
    public static String convertProductGroup(String input) {
        String output = null;
        if (input != null) {
            List<String> productGrpOptions = getOpptProductGrpOptions();
            for (String option: productGrpOptions) {
                if (input.toLowerCase() == option.toLowerCase()) {
                    return option;
                }
            }
            return input;
        }
        return input;
    }
    
    /* This method returns the list of Opportunity Product Group picklist values */
    public static List<String> getOpptProductGrpOptions()
    {
        List<String> productGrpOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.RTL_Product_Group__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            productGrpOptions.add(f.getValue());
        }  
        return productGrpOptions;      
    } 
    
    /* This method returns the list of NBO Product Field translation mapping */
    public static Map<String, String> getNBOProductFieldTranslationMapping() {//the key is field value in english, the value is field value label
        Map<String, String> mdtMap = new Map<String, String>();
        for (RTL_NBO_Product_Field_Tracking__mdt mdt : [SELECT RTL_Value_English__c, RTL_Value_Label__c FROM RTL_NBO_Product_Field_Tracking__mdt]){
            mdtMap.put(mdt.RTL_Value_English__c, mdt.RTL_Value_Label__c);
        }
        
        return mdtMap;
    }

    public static RTL_Online_Service_Log__c InsertErrorTransactionWithServiceName(String cName , String rmid,String uName,String muleLogId,String errorMessages,String cSegment,String serviceName,Boolean isInsert){
        RTL_Online_Service_Log__c Log = new RTL_Online_Service_Log__c ();
        Log.RTL_Customer_Name__c  = cName;
        Log.RTL_RM_ID__c = rmid;
        Log.RTL_Name_of_User__c = uName;
        Log.RTL_Mulesoft_Log_Id__c = muleLogId;
        Log.RTL_Error_Message__c = errorMessages;
        Log.RTL_Customer_Segment__c = cSegment;
        Log.RTL_Service_Name__c = serviceName;
        if(isInsert){
            insert Log;  
        }

        return Log;
                
    }
    
    public static void InsertErrorTransaction(String cName , String rmid,String uName,String muleLogId,String errorMessages,String cSegment){
        RTL_Online_Service_Log__c Log = new RTL_Online_Service_Log__c ();
        Log.RTL_Customer_Name__c  = cName;
        Log.RTL_RM_ID__c = rmid;
        Log.RTL_Name_of_User__c = uName;
        Log.RTL_Mulesoft_Log_Id__c = muleLogId;
        Log.RTL_Error_Message__c = errorMessages;
        Log.RTL_Customer_Segment__c = cSegment;
        insert Log;          
    }

    //Added on 29 June 2017
    public static String queryAllField(String objName) {
        String strQuery = '';
        List<String> q = new List<String>();
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.DescribeSObjectResult r =  m.get(objName).getDescribe();
        List<String>apiNames =  new list<String>();
        for(string apiName : r.fields.getMap().keySet()){
            q.add(apiName);
        }
        for( String s : q ){
            strQuery += s+',';
        }
        return strQuery;
    }

    public static Map<Id,RecordType> getRecordTypeById(List<Id> recordtypeIdList){
        return new Map<Id,RecordType>([ select Id,DeveloperName 
                from RecordType 
                where Id IN :recordtypeIdList  ]);
    }

    public static Boolean isNotNull(String cond){
        if( cond == null || cond == '' ){
            return false;
        }
        return true;
    }

    //Added on 29 June 2017


    //get label values picklist
    public static string getLabelPicklist (String picklistValues,String apiName,String objectName){
        string label;

        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(apiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            if( picklistValues != null && picklistValues.equals(f.getValue())){
                label = f.getLabel();
                break;
            }
        }

        if(label == null){
            label = (picklistValues!=null)?picklistValues:'';
        }

        return label;
    }

    public static String checkNull(String str,String defaultValue){
        if(str == null)
            return defaultValue;
        return str;
    }

    public static String truncateString(String str,Integer length){
        if(str == null || str.length() < length)
            return str;
        return str.substring(0,length);
    }

    //dynamic translation last contact status
    public static string transLastContactStatus (string lastContactStatus){
        string lstatus = null;

        try
        {
            if(lastContactStatus!=null){
                String[] splitlast = lastContactStatus.split(';');
                string contact = RTL_Utility.getLabelPicklist(splitlast[0],'RTL_Contact_Status__c','CampaignMember');
                string reason = RTL_Utility.getLabelPicklist(splitlast[1],'RTL_Reason__c','CampaignMember');
                reason = (reason!=null&&reason!='')?' ('+reason+') ':' ';
                string lasttime = splitlast[2];
                lastContactStatus = contact+reason+lasttime;
                lstatus = lastContactStatus;
            }
        }
        catch (Exception e)
        {
            lstatus = '';
        }

        return lstatus;
    }

    //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017
    public static void InsertRTLog(String cName 
                                            ,String rmid
                                            ,String uName
                                            ,String muleLogId
                                            ,String errorMessages
                                            ,String cSegment
                                            ,Id accountId
                                            ,DateTime startDatetime
                                            ,DateTime endDatetime
                                            ,String serviceName
                                            ,Boolean isSuccess) {
        AppConfig__c appConfig = AppConfig__c.getValues('Is_Logger');
        String isLogger = appConfig == null ? 'False' : appConfig.Value__c;

        if ('True'.equalsIgnoreCase(isLogger)) {
            InsertRTOnlineLog(cName
                                  ,rmid
                                  ,uName
                                  ,muleLogId
                                  ,errorMessages
                                  ,cSegment
                                  ,accountId
                                  ,startDatetime
                                  ,endDatetime
                                  ,serviceName
                                  ,isSuccess
                                  );
        }
    }

    //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017
    public static void InsertRTOnlineLog(String cName 
                                            ,String rmid
                                            ,String uName
                                            ,String muleLogId
                                            ,String errorMessages
                                            ,String cSegment
                                            ,Id accountId
                                            ,DateTime startDatetime
                                            ,DateTime endDatetime
                                            ,String serviceName
                                            ,Boolean isSuccess){

        RTL_Online_Service_Log__c Log = new RTL_Online_Service_Log__c ();
        Log.RTL_Customer_Name__c  = cName;
        Log.RTL_RM_ID__c = rmid;
        Log.RTL_Name_of_User__c = uName;
        Log.RTL_Mulesoft_Log_Id__c = muleLogId;
        Log.RTL_Error_Message__c = errorMessages;
        Log.RTL_Customer_Segment__c = cSegment;
        log.RTL_Account__c       = accountId;
        log.RTL_Start_DateTime__c = startDatetime;      
        log.RTL_End_DateTime__c   = endDatetime;
        log.RTL_Service_Name__c   = serviceName;
        log.RTL_Is_Success__c     = isSuccess;
        insert Log;          
    }

    public static Boolean retryInsertRecord(sObject obj){
        Boolean isSuccess = false;
            try{
                
                insert obj;
                isSuccess = true;

            }catch(Exception e){
                System.debug('There is an error when insert obj : '+e.getMessage());
            }
        return isSuccess;
    }

    //SCR 2018-08-22 - Smart Queue Log 22-08-2018
    public static String FOUND_AS_CUSTOMER = 'FOUND_AS_CUSTOMER';
    public static String FOUND_AS_PROSPECT = 'FOUND_AS_PROSPECT';
    public static String FOUND_AS_LEAD = 'FOUND_AS_LEAD';

    public static String FOUND_MULTIPLE_ON_ACCOUNT = 'FOUND_MULTIPLE_ON_ACCOUNT';
    public static String FOUND_MULTIPLE_ON_CONTACT = 'FOUND_MULTIPLE_ON_CONTACT';
    public static String FOUND_MULTIPLE_ON_LEAD    = 'FOUND_MULTIPLE_ON_LEAD';

    public static String NO_FOUND = 'NO_FOUND';

    public static void InsertSmartQueueLog(String cName 
                                            ,String rmid
                                            ,String uName
                                            ,String cSegment
                                            ,Id accountId
                                            ,DateTime startDatetime
                                            ,String foundType
                                            ,String queueNo
                                            ,String branchCode
                                            ,String errorMessages
                                            ,Boolean isSuccess){

        AppConfig__c cf = AppConfig__c.getValues('Is_Smart_Queue_Log');
        String isSmartQueue = (cf == null ? 'true' : cf.Value__c);

        Boolean isSmartQueueLog = isSmartQueue.equalsIgnoreCase('true'); 

        if (isSmartQueueLog) {
            RTL_Online_Service_Log__c Log = new RTL_Online_Service_Log__c ();
            Log.RTL_Customer_Name__c  = cName;
            Log.RTL_RM_ID__c = rmid;
            Log.RTL_Name_of_User__c = uName;
            Log.RTL_Mulesoft_Log_Id__c = null;
            Log.RTL_Error_Message__c = errorMessages;
            Log.RTL_Customer_Segment__c = cSegment;
            log.RTL_Account__c       = accountId;
            log.RTL_Start_DateTime__c = startDatetime;      
            log.RTL_End_DateTime__c   = DateTime.now();
            log.RTL_Service_Name__c   = 'SMART_QUEUE_INT';
            log.RTL_Is_Success__c     = isSuccess;

            log.Smart_Branch_Code__c  = branchCode;
            log.Smart_Queue_Found_Type__c  = foundType;
            log.Smart_Queue_Number__c  = queueNo;

            insert Log;     
        }
    }

    //SCR 2018-08-22 - Smart Queue Log 22-08-2018

    public static Map<Id,UserRecordAccess> queryRecordAccess(Set<Id> objectIdSet,Id userId){
        Map<Id,UserRecordAccess> recordAccesssMap = new Map<Id,UserRecordAccess>();
        for(UserRecordAccess recordAccess : [SELECT RecordId,HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                                FROM UserRecordAccess
                                                WHERE UserId =: userId
                                                AND RecordId IN:objectIdSet])
            recordAccesssMap.put(recordAccess.recordId, recordAccess);
        
        return recordAccesssMap;
            

    }

    public static Object getRelationData(SObject record, String field)
    {
        if (record == null) return null;
        if (!field.contains('.')) return record.get(field);
        return getRelationData(
            record.getSObject(field.substringBefore('.')),
            field.substringAfter('.')
        );
    }


    public static void setRelationData(SObject sObj
                                          , Map<String, Schema.SObjectField> fieldMap 
                                          , String field
                                          , Map<String,String> dataObjMap
                                          ) {
        setRelationData(sObj
                     ,fieldMap
                     ,field
                     ,dataObjMap
                     ,true
                       );
    }

            

    public static void setRelationData(SObject sObj
                                          , Map<String, Schema.SObjectField> fieldMap 
                                          , String field
                                          , Map<String,String> dataObjMap
                                          , Boolean isGMTTimeFormat
                                          )
    {

        if (!field.contains('.'))  {
            setValuesToSObject(sObj
                               , field
                               , dataObjMap
                               , fieldMap
                               ,isGMTTimeFormat
                               );
            return;
        }

        String fieldName = field.substringBefore('.').replace('__r','__c');

        if (fieldName == 'RecordType') {
            fieldName = 'RecordTypeId';
        }else if (fieldName == 'Owner') {
            fieldName = 'OwnerId';
        }

        Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();

        for(Schema.SObjectType reference : f.getReferenceTo()) {
            String tempObjectName = reference.getDescribe().getName();
            //System.debug('tempObjectName :'+tempObjectName);
            Map<String, Schema.SObjectField> tempFieldMap 
                            = Schema.getGlobalDescribe().get(tempObjectName).getDescribe().fields.getMap();

            SObject tempSobj = Schema.getGlobalDescribe().get(tempObjectName).newSObject();

            setValuesToSObject(tempSobj
                                , field
                                , dataObjMap
                                , tempFieldMap
                                , isGMTTimeFormat
                              );

            sObj.putSobject(field.substringBefore('.'),tempSobj);
        }
        return;
    }


    private static void setValuesToSObject(SObject sObj
                                             , String field
                                             , Map<String,String> dataObjMap
                                             , Map<String, Schema.SObjectField> fieldMap
                                             , Boolean isGMTTimeFormat
                                             ) {
        Schema.DisplayType fielddataType = null;

        String dataField = field;

        if (dataObjMap.get(dataField) == null || dataObjMap.get(dataField).length() == 0) return;

        if (field.contains('.')) {
            field = field.substringAfter('.');
            fielddataType = fieldMap.get(field).getDescribe().getType();
        }else {
            fielddataType = fieldMap.get(field).getDescribe().getType();
        }

        if (fielddataType.name().equalsIgnoreCase('currency') 
                || fielddataType.name().equalsIgnoreCase('double')) {
            sObj.put(field,Decimal.valueOf(dataObjMap.get(dataField)));
        }else if (fielddataType.name().equalsIgnoreCase('date')) {
            sObj.put(field,Date.valueOf(dataObjMap.get(dataField)));
        }else if (fielddataType.name().equalsIgnoreCase('datetime')) {
            if (isGMTTimeFormat) {
                sObj.put(field,DateTime.ValueofGmt(dataObjMap.get(dataField).replace('T', ' ')));
            }else {
                sObj.put(field,DateTime.Valueof(dataObjMap.get(dataField).replace('T', ' ')));
            }
        }else if (fielddataType.name().equalsIgnoreCase('boolean')) {
            sObj.put(field,Boolean.valueOf(dataObjMap.get(dataField).toLowerCase()));
        }else {
            sObj.put(field,String.valueOf(dataObjMap.get(dataField)));
        }
    }

    private static void setValuesToSObject(SObject sObj
                                             , String field
                                             , Map<String,String> dataObjMap
                                             , Map<String, Schema.SObjectField> fieldMap
                                             ) {
        setValuesToSObject(sObj
                            , field
                            , dataObjMap
                            , fieldMap
                            ,true
                          );
    }

     public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                //System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }


    public static String INSERT_RECORD = 'INSERT_RECORD';
    public static String UPDATE_RECORD = 'UPDATE_RECORD';
    public static String UPSERT_RECORD = 'UPSERT_RECORD';

    private static void insertDatabaseErrLog(List<Sobject> scope
                                        ,Integer index
                                        ,Database.SaveResult  sr
                                        ,Database.UpsertResult upr
                                        ,Datetime startDatetime
                                        ,String searchType
                                        ,String refField) {

        String recordId = (String)scope[index].get(refField);
        String errMessage = '';

        if (sr != null) {
            for(Database.Error err : sr.getErrors()) {
                errMessage = errMessage +recordId + ','
                        +err.getMessage() + ','
                        +String.join(err.getFields(),',') + ','
                        +err.getStatusCode()+'\n';
            }
        }
        
        if (upr != null) {
            for(Database.Error err : upr.getErrors()) {
                errMessage = errMessage +recordId + ','
                            +err.getMessage() + ','
                            +String.join(err.getFields(),',') + ','
                            +err.getStatusCode()+'\n';
            }
        }
        

        InsertRTOnlineLog( null
                        ,null
                        ,UserInfo.getName()
                        ,null
                        ,errMessage
                        ,null
                        ,null
                        ,startDatetime
                        ,DateTime.now()
                        ,searchType
                        ,false);
    }

    
    //doDBOperation only support 1 record otherwise Limit will hit
    public static List<SObject> doDBOperation(String operType
                                            ,List<Sobject> scope
                                            ,Datetime startDatetime
                                            ,String searchType
                                            ,String refField) {

        List<SObject> sObjLst = new List<SObject>();
        Integer index = 0;
        if (operType.equalsIgnoreCase(INSERT_RECORD) ) {
            //do insert
            Database.SaveResult[]  lsr = Database.Insert(scope, false);
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    sObjLst.add(scope[index]);
                }else {
                    insertDatabaseErrLog(scope,index,sr,null,startDatetime,searchType,refField);
                }
                index++;
            }
        }else if (operType.equalsIgnoreCase(UPDATE_RECORD) ) {
            //do update
            Database.SaveResult[]  lsr = Database.update(scope, false);
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    sObjLst.add(scope[index]);
                }else {
                    insertDatabaseErrLog(scope,index,sr,null,startDatetime,searchType,refField);
                }
                index++;
            }
        }else {
            //do upsert
            /*
             Schema.SObjectField extKey  = null;
            Database.UpsertResult[] upr = null;
            if (this.sobjectName.equals('RTL_Fulfillment__c')) {
                extKey = RTL_Fulfillment__c.Fields.RTL_Fulfillment_ID__c;
                String listType = 'List<' + this.sobjectName + '>';
                List<RTL_Fulfillment__c> castRecords = (List<RTL_Fulfillment__c>)Type.forName(listType).newInstance();
                castRecords.addAll((List<RTL_Fulfillment__c>)scope);
                upr = Database.upsert(castRecords,extKey, false);
            }*/
            //upr = Database.upsert(castRecords,extKey, false);
            /*
                    for (Database.SaveResult sr : lsr) {
                        if (sr.isSuccess()) {}
                        else {
                            RTL_Utility.InsertRTOnlineLog( null
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
                    }*/
        }

        //Keep Log
        return sObjLst;
    }
    
    public static void InsertRTOnlineLog(String searchType
                                        ,Datetime startDatetime
                                        ,Exception e){

        InsertRTOnlineLog( null
                           ,null
                           ,UserInfo.getName()
                           ,null
                           ,e.getMessage()+' '+e.getStackTraceString()
                           ,null
                           ,null
                           ,startDatetime
                           ,DateTime.now()
                           ,searchType
                           ,false);

    }

    //UPLOAD_EMAIL Migrate 
    public class UploadDataEmail {
        public Boolean result;
        public String description;
        public Map<String,List<String>> fieldValidateMap;
        public List<String> colHeaderList;
        public Map<String,List<Map<String,String>>> dataMap;
    }


    public static RTL_Utility.UploadDataEmail getDataForUploadEmail(String jobName
                                                    ,String dataString
                                                    ) {
        RTL_Utility.UploadDataEmail uploadDataEmail = new UploadDataEmail();
        
        Map<String,List<Map<String,String>>> valListMap = new Map<String,List<Map<String,String>>>();

        dataString  = RTL_ReportUtility.replaceNewLineForCSV(dataString).replace('"','');

        List<String> ret = new List<String>();
        List<Migration_Info__c> migrateLst = [SELECT Id
                                                        ,Name
                                                        ,Migrated_Field__c
                                                        ,ObjectName__c
                                                        ,Migrated_Field_1__c
                                                        ,Validate_Field_1__c
                                                        ,Validate_Field_Value_1__c
                                                    FROM  Migration_Info__c 
                                                    WHERE IsActive__c = true 
                                                    AND Name =: jobName
                                                    AND Type__c = 'UPLOAD_EMAIL'
                                                    LIMIT 1];
        if (migrateLst.size() == 0) {
            uploadDataEmail.result = false;
            uploadDataEmail.description = jobName+' is Service Unavailable';
            return uploadDataEmail;
        }

        Migration_Info__c migrateObj = migrateLst.get(0);
        List<String> colMigrateLst = new List<String>();
        if (migrateObj.Migrated_Field__c != null) colMigrateLst.addall(migrateObj.Migrated_Field__c.split(','));
        if (migrateObj.Migrated_Field_1__c != null) colMigrateLst.addall(migrateObj.Migrated_Field_1__c.split(','));

        String objectName = migrateObj.ObjectName__c;
        
        List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,objectName);

        if (colHeaderList == null) {
            uploadDataEmail.result = false;
            uploadDataEmail.description = RTL_ReportUtility.INVALID_UTF8_ENCODING;
            return uploadDataEmail;
        }

        uploadDataEmail.colHeaderList = colHeaderList;
        SObject sObj = Schema.getGlobalDescribe().get(migrateObj.ObjectName__c).newSObject();

        for (String field : colHeaderList) {
            if (!colMigrateLst.contains(field)) {
                uploadDataEmail.result = false;
                uploadDataEmail.description = 'this field '+ field +' is not allowed to execute. for '+jobName;
                return uploadDataEmail;
            }
        }         

        
        //remove casenumber column header
        String header = dataString.substringBefore('\n');
        dataString    = dataString.substring(header.length()+1
                                                 ,dataString.length());

        valListMap = RTL_ReportUtility.readCSVToMap(dataString,colHeaderList,5000);

        if (migrateObj.Validate_Field_1__c != null && migrateObj.Validate_Field_1__c.length() > 0 
            && migrateObj.Validate_Field_Value_1__c != null && migrateObj.Validate_Field_Value_1__c.length() > 0 
           ) 
        {
            List<String> fieldValList = migrateObj.Validate_Field_Value_1__c.split(',');
            uploadDataEmail.fieldValidateMap = new Map<String,List<String>>();
            uploadDataEmail.fieldValidateMap.put(migrateObj.Validate_Field_1__c,fieldValList);
        }

        uploadDataEmail.result = true;
        uploadDataEmail.dataMap = valListMap;

        return uploadDataEmail;
    }
    //UPLOAD_EMAIL Migrate
}