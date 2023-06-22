global without sharing class CXMServiceProvider implements Queueable
                                            , Database.AllowsCallouts {
    private String query;
    private Integration_Info__c intInfo;
    private EIMManager manager = null;
    private static String FORMAT_DTM = 'dd/MM/yyyy HH:mm:ss';
    private Integer BATCHSIZE = 50;
    private String JSON  = 'application/json';
    private List<String> fieldLst = new List<String>();
    private String OBJ_STR = 'Case';

    private Map<Id, List<ContentVersion>> filesAttachMap 
                    = new Map<Id, List<ContentVersion>>();


    private Datetime startDatetime = Datetime.now();

    private List<RTL_Online_Service_Log__c> inlogLst = new List<RTL_Online_Service_Log__c> ();
    private Map<Id,List<Attachment>> bodyAttMap     = new Map<Id,List<Attachment>>();

    private String INEGRATION_NAME = 'CXMCaseService';
    private String INEGRATION_Channel = 'CRM-CCRP';

    private String ACCOUNT_ID_FIELD = 'AccountId';
    private String REF_NAME_FIELD   = 'Account.Name';
    private String RECORDTYPE_DEV_NAME   = 'RecordType.DeveloperName';


    private String FAIL_WAIT_FOR_RETRY = 'FAIL_WAIT_FOR_RETRY';
    private String OFFHOUR_RETRY = 'OFFHOUR_RETRY';
    private String FAIL_MAX_FOR_RETRY = 'FAIL_MAX_FOR_RETRY';

    private Integer RETRY_MAX = 3;

    private String CXM_Latest_Response = 'CXM_Latest_Response__c';
    private String CXM_Latest_Status = 'CXM_Latest_Status__c';
    private String CXM_write_log_flag = 'CXM_write_log_flag__c';
    
    //Get CXM_Service_Field, CXM_Service_Start_Hour, CXM_Service_End_Hour Value
    private AppConfig__c cf = AppConfig__c.getValues('CXM_Service_Field');
    private String CXM_Service_Field = (cf == null ? 'LastModifiedDate': cf.Value__c);

    private AppConfig__c cf2 = AppConfig__c.getValues('CXM_Service_Start_Hour');
    private String CXM_Service_Start_Hour = (cf2 == null ? '08:05': cf2.Value__c);

    private AppConfig__c cf3 = AppConfig__c.getValues('CXM_Service_End_Hour');
    private String CXM_Service_End_Hour = (cf3 == null ? '19:45': cf3.Value__c);

    private String SUCCESS_CODE = '0000';
    private String FAIL_CODE = '9999';

    private String INEGRATION_ERROR_CODE = '1001';
    private String BACKEND_FAIL_CODE     = '1002';

    private Boolean isRetryBatch = false;
    private List<String> IdLstStr = new List<String>();

    public static String CXMCaseService = 'CXMCaseService';
    public static String OPPTY_TO_CXM = 'OPPTY_TO_CXM';
    //public static String OPPTY_TO_CXM_Channel = 'CRM-OPTY';
    public static String NBO_PRODUCT_CXM = 'NBO_PRODUCT_CXM';
    //public static String NBO_PRODUCT_CXM_Channel = 'CRM-NBO';
    public static String CMP_MEMBER_CXM = 'CMP_MEMBER_CXM';
    //public static String CMP_MEMBER_CXM_Channel = 'CRM-Campaign';

    private String FIELD_FOR_LOG = 'CaseNumber';

    private Boolean IS_WRITE_LOG_FLAG = true;

    private String CRITERIA_SQL = '';

    //check static variable 
    private static Boolean checkForPreventLoop = true;
    //check static variable 

    private List<Sobject> scopeQuery = new List<Sobject> (); // << Change to Queueable
    private Map<Id,Case> oldMapParam = new Map<Id,Case>(); // << Change to Queueable
    private Map<Id,Case> newMapParam = new Map<Id,Case>(); // << Change to Queueable
    private Boolean nextQueue = false; // << Change to Queueable

    /*
        Update by: Narathip Santhip
        Email: nrs@ii.co.th
        Note: Fix bug too many query 101
        Change Date: 2020-06-11
        Change Description: Getting from Schema recordtype infoes library instead of SQOL and property to be Geting/Setting
    */
    private Map<Id,Schema.RecordTypeInfo> mapCaseRecordType {
        get {
            return Schema.SObjectType.Case.getRecordTypeInfosById();
        }
    }

    private List<Integration_Mapping__c> intMappingLst {
        get {
            if(intMappingLst == null){
                intMappingLst = [SELECT Id
                ,Condition_1__c,Condition_2__c
                ,Condition_3__c,Condition_4__c,Field_Condition_1__c
                ,Field_Condition_2__c,Field_Condition_3__c
                ,Field_Value_1__c 
                ,Field_Value_2__c
                ,Field_Value_3__c
                ,Field_Value_4__c
                ,Field_Condition_4__c
                ,Batch_SQL__c
                From Integration_Mapping__c Where Name =: this.INEGRATION_NAME];
            }
            return intMappingLst;
        }
        set;
    }

    private Map<String,RTL_CXM_Config__mdt> mapMetaConf {get{
        Map<String,RTL_CXM_Config__mdt> simList = new Map<String,RTL_CXM_Config__mdt>();
           for( RTL_CXM_Config__mdt conf : [select id,DeveloperName,Value__c from RTL_CXM_Config__mdt ] ){
                simList.put(conf.DeveloperName,conf);
            }
        
        return new Map<String,RTL_CXM_Config__mdt>(simList);
    }set;}

    private String getConfig(String confName,String defaultValue){ 
        try{
            //return CXM_Config__c.getValues(confName).Value__c;
            return mapMetaConf.get(confName).Value__c;
        }catch( Exception e ){
            return defaultValue;
        }
    }

    public CXMServiceProvider() {
        //this.init_process();
    }

    public CXMServiceProvider(String integrationName) {
        this.INEGRATION_NAME    = integrationName;
        
        this.intMappingLst = [SELECT Id
                                ,Condition_1__c,Condition_2__c
                                ,Condition_3__c, Condition_4__c
                                ,Field_Condition_1__c, Field_Condition_2__c
                                ,Field_Condition_3__c, Field_Condition_4__c
                                ,Field_Value_1__c, Field_Value_2__c
                                ,Field_Value_3__c, Field_Value_4__c
                                ,IsActive__c
                                ,ObjectName__c
                                ,Account_Field_Name__c
                                ,Account_Id_Field__c
                                ,Field_For_Log__c
                                ,CXM_Channel__c
                                ,Is_CXM_Write_Log__c
                                ,Batch_SQL__c
                                From Integration_Mapping__c 
                                Where Name =: this.INEGRATION_NAME];

        Integration_Mapping__c intMapping = this.intMappingLst.get(0);
        this.INEGRATION_Channel = intMapping.CXM_Channel__c;
        this.OBJ_STR = intMapping.ObjectName__c;
        this.FIELD_FOR_LOG = intMapping.Field_For_Log__c;
        this.ACCOUNT_ID_FIELD  = intMapping.Account_Id_Field__c;
        this.REF_NAME_FIELD    = intMapping.Account_Field_Name__c;
        this.IS_WRITE_LOG_FLAG = intMapping.Is_CXM_Write_Log__c;

        if (intMapping.Batch_SQL__c != null && intMapping.Batch_SQL__c.length() > 0) {
            this.CRITERIA_SQL       = ' AND '+intMapping.Batch_SQL__c;
        }
        

        //this.init_process();
    }

    public CXMServiceProvider(Map<Id,Case> oldMap, Map<Id,Case> newMap, String queryString, Boolean nextQueueFlag) {
        this.scopeQuery = Database.query(queryString);
        this.nextQueue = nextQueueFlag;
        this.oldMapParam = oldMap;
        this.newMapParam = newMap;
    }

    private void error_finish(Exception error) {
        addIntegrationLog(startDatetime
                                ,DateTime.now()
                                ,null
                                ,error.getMessage()+ ' '+error.getStackTraceString()
                                ,false
                                ,''
                                ,''
                                ,'');
        // this.finish(null); // << Change to Queueable
    }

    /*global void execute(SchedulableContext sc) {
        try {
            //query cxm retry
            List<Integration_Mapping__c> intLst = [SELECT Id
                                                , ObjectName__c
                                                ,Is_CXM_Retry__c
                                                ,Account_Field_Name__c
                                                ,Account_Id_Field__c
                                                ,Field_For_Log__c
                                                ,CXM_Channel__c
                                                ,Name
                                                ,Is_CXM_Write_Log__c
                                                From Integration_Mapping__c
                                                WHERE Is_CXM_Retry__c =: true];

            for (Integration_Mapping__c intMapping : intLst) {
                CXMServiceProvider cxmProvider = new CXMServiceProvider(intMapping.Name);
                cxmProvider.runBatchForRetry();
            }
        }catch(Exception error) {
            this.error_finish(error);
        }
    }*/ // << Change to Queueable
   
    public void integrateToCXM(Map<Id,Case> oldMap,Map<Id,Case> newMap){
        integrateToCXMMethod(oldMap, newMap, false); // << Change to Queueable
    }
    public void integrateToCXM(Map<Id,Case> oldMap,Map<Id,Case> newMap, Boolean nextQueueFlag) { // << Change to Queueable
        integrateToCXMMethod(oldMap, newMap, nextQueueFlag);
    }
   
    public void integrateToCXMMethod(Map<Id,Case> oldMap, Map<Id,Case> newMap, Boolean nextQueueFlag){
        AppConfig__c cf = AppConfig__c.getValues('CXM_SERVICE_CONNECTOR');
        String isCXMServiceConnector = (cf == null ? 'false' : cf.Value__c);

        Boolean isEnable = isCXMServiceConnector.equalsIgnoreCase('true');
        this.nextQueue = nextQueueFlag; // << Change to Queueable
        this.oldMapParam = oldMap; // << Change to Queueable
        this.newMapParam = newMap; // << Change to Queueable

        if (!isEnable) return;
        try {
            Integration_Mapping__c intMapping = this.intMappingLst.get(0);
            //first condition should be setting in mapping, if not it will error exception
            String varfield1 = intMapping.Field_Condition_1__c;
            String fieldVal1 = intMapping.Field_Value_1__c;
            List<String> fieldLst1 = fieldVal1.split(';');
            

            String varfield2 = intMapping.Field_Condition_2__c;
            String fieldVal2 = intMapping.Field_Value_2__c;
            List<String> fieldLst2 = new List<String>();
            fieldLst2.add('DefaultValue');
            if(varfield2 != null && fieldVal2 != null){
                fieldLst2.clear();
                fieldLst2 = fieldVal2.split(';');
            }

            String varfield3 = intMapping.Field_Condition_3__c;
            String fieldVal3 = intMapping.Field_Value_3__c;
            List<String> fieldLst3 = new List<String>();
            fieldLst3.add('DefaultValue');
            if(varfield3 != null && fieldVal3 != null){
                fieldLst3.clear();
                fieldLst3 = fieldVal3.split(';');
            }            
            
            String varfield4 = intMapping.Field_Condition_4__c;
            String fieldVal4 = intMapping.Field_Value_4__c;
            List<String> fieldLst4 = new list<String>();
            fieldLst4.add('DefaultValue');
            if (varfield4 != null && fieldVal4 != null){  
                fieldLst4.clear();              
                fieldLst4 = fieldVal4.split(';');                
            }            

            for (String idVal : newMap.keyset()) {
                Case newcaseObj = newMap.get(idVal);
                String varNewVal1 = String.valueOf(newcaseObj.get(varfield1)); //First value should setting in mapping, if not, error exception
                String varNewVal2 = varfield2 != null?String.valueOf(newcaseObj.get(varfield2)): 'DefaultValue'; 
                String varNewVal3 = varfield3 != null?String.valueOf(newcaseObj.get(varfield3)): 'DefaultValue'; 
                String varNewVal4 = varfield4 != null?String.valueOf(newcaseObj.get(varfield4)): 'DefaultValue'; 
                if (oldMap == null) {                 
                    //call cxm webservice
                    //for inquiry wrap up
                    if (fieldLst1.contains(varNewVal1) 
                        && fieldLst2.contains(varNewVal2) 
                        && fieldLst3.contains(varNewVal3)
                        && fieldLst4.contains(varNewVal4)
                        && newcaseObj.isClosed == true                          
                        ) {
                        if (IdLstStr.size() == this.BATCHSIZE) {
                                this.runBatch(IdLstStr);
                                IdLstStr.clear();
                        }
                        IdLstStr.add(newcaseObj.Id);
                    }

                }else {
                    //for non fcr case
                    Case oldcaseObj = oldMap.get(idVal);
                    String varOldVal1 = String.valueOf(oldcaseObj.get(varfield1)); 
                    String recordDevName = mapCaseRecordType.get(newcaseObj.RecordTypeId).DeveloperName;

                    if (!varNewVal1.equals(varOldVal1)) {//status changed to Completed
                        //call cxm webservice
                        if (fieldLst1.contains(varNewVal1) 
                            && fieldLst2.contains(varNewVal2) 
                            && fieldLst3.contains(varNewVal3)
                            && fieldLst4.contains(varNewVal4)
                            && newcaseObj.isClosed == true
                            && recordDevName.startsWithIgnoreCase('closed')
                            ) {
                            if (IdLstStr.size() == this.BATCHSIZE) {
                                    this.runBatch(IdLstStr);
                                    IdLstStr.clear();
                            }
                            IdLstStr.add(newcaseObj.Id);
                        }
                    }
                }
            }
            if (IdLstStr.size() > 0) {                
                //check static variable loop calling
                if (checkForPreventLoop == false) {
                    return;
                }
                checkForPreventLoop = false;
                //check static variable loop calling
                this.runBatch(IdLstStr);
            }
        }catch (Exception error) {
            //handble exception
            this.error_finish(error);
        }
    }

    public void integrateToCXMForSales(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
        try {            
            Integration_Mapping__c intMapping = this.intMappingLst.get(0);
            if (intMapping == null || !intMapping.IsActive__c) {        
                addIntegrationLog(startDatetime
                                ,DateTime.now()
                                ,null
                                ,this.INEGRATION_NAME + ' is Service Unavailable'
                                ,false
                                ,''
                                ,''
                                ,'');
                // this.finish(null); // << Change to Queueable
                return;
            }

            for (String idVal : newMap.keyset()) {
                SObject newObj = newMap.get(idVal);

                if (oldMap == null) {
                    ///do nothing
                }else {
                    SObject oldObj = oldMap.get(idVal);

                    Boolean isConditionMeet = false;

                    //Condition 1, first condition should be have value. if not will exception error
                    String varfield1 = intMapping.Field_Condition_1__c;
                    String varNewVal1 = String.valueOf(newObj.get(varfield1)); 
                    String varOldVal1 = String.valueOf(oldObj.get(varfield1));                    
                    String fieldVal1 = intMapping.Field_Value_1__c;
                    List<String> fieldLst1 = fieldVal1.split(';');                                  
                    
                    //and condition 2
                    String varfield2 = intMapping.Field_Condition_2__c;
                    String fieldVal2 = intMapping.Field_Value_2__c;
                    if (varfield2 != null && fieldVal2 != null) {
                        String varNewVal2 = String.valueOf(newObj.get(varfield2)); 
                        String varOldVal2 = String.valueOf(oldObj.get(varfield2));                        
                        if (varOldVal1 != varNewVal1 || varOldVal2 != varNewVal2 ) {
                            List<String> fieldLst2 = fieldVal2.split(';');
                            if ( fieldLst1.contains(varNewVal1) && fieldLst2.contains(varNewVal2) ) {
                                isConditionMeet = true;
                            }else {
                                isConditionMeet = false;
                            }
                        }

                    }else if (varOldVal1 != varNewVal1 && fieldLst1.contains(varNewVal1)) {
                        isConditionMeet = true;
                    }

                    //and condition 3
                    String varfield3 = intMapping.Field_Condition_3__c;
                    String fieldVal3 = intMapping.Field_Value_3__c;
                    if (varfield3 != null && fieldVal3 != null) {
                        String varNewVal3 = String.valueOf(newObj.get(varfield3));                         
                        List<String> fieldLst3 = fieldVal3.split(';');
                        if (fieldLst3.contains(varNewVal3) && isConditionMeet) {
                            isConditionMeet = true;
                        }else {
                            isConditionMeet = false;
                        }
                    }

                    //and condition 4
                    String varfield4 = intMapping.Field_Condition_4__c;
                    String fieldVal4 = intMapping.Field_Value_4__c;
                    if (varfield4 != null && fieldVal4 != null) {
                        String varNewVal4 = String.valueOf(newObj.get(varfield4));                         
                        List<String> fieldLst4 = fieldVal4.split(';');
                        if (fieldLst4.contains(varNewVal4) && isConditionMeet) {
                            isConditionMeet = true;
                        }else {
                            isConditionMeet = false;
                        }
                    }

                    if (isConditionMeet) {
                        IdLstStr.add(newObj.Id);
                    }
                }
            }

            if (IdLstStr.size() > 0) {                
                //check static variable loop calling
                if (checkForPreventLoop == false) {
                    return;
                }
                checkForPreventLoop = false;
                //check static variable loop calling
                this.runBatch(IdLstStr);
            }
        }catch (Exception error) {
            //handble exception
            this.error_finish(error);
        }
    }

    private void init_process(){
        String fieldType = 'Request';
        List<EIM_Map__c> eimMapList = [SELECT Id
                                            ,Name
                                            ,Default_Value__c
                                            ,Attribute__c
                                            ,Attribute_value__c
                                            ,External_Field__c
                                            ,Job_Type__c
                                            ,SF_Field__c
                                            ,Node__c
                                            ,ParentNode__c
                                            ,Node_Key__c
                                            ,Object__c
                             FROM EIM_Map__c Where Job_Type__c =: this.INEGRATION_NAME 
                                  AND IsActive__c = true
                                  AND Field_Type__c =: fieldType
                             ORDER BY Field_Order__c ASC ];        

        for (EIM_Map__c eim : eimMapList) {
            if (!this.fieldLst.contains(eim.SF_Field__c)) {
                this.fieldLst.add(eim.SF_Field__c);
            }
        }
    }

    public void runBatch(List<String> IdsLst) {
        this.init_process();
        
        String objIds = '(\''+String.join(IdsLst,'\',\'')+'\')';

        if (this.fieldLst.contains(this.CXM_Service_Field)) {
            Integer indexFound = this.fieldLst.indexOf(this.CXM_Service_Field);
            this.fieldLst.remove(indexFound);
        }

        if (this.fieldLst.contains(this.CXM_Service_Field)) {
            Integer indexFound = this.fieldLst.indexOf(this.CXM_Service_Field);
            this.fieldLst.remove(indexFound);
        }

        if (this.fieldLst.contains(this.ACCOUNT_ID_FIELD)) {
            Integer indexFound = this.fieldLst.indexOf(this.ACCOUNT_ID_FIELD);
            this.fieldLst.remove(indexFound);
        }

        if (this.fieldLst.contains(this.REF_NAME_FIELD)) {
            Integer indexFound = this.fieldLst.indexOf(this.REF_NAME_FIELD);
            this.fieldLst.remove(indexFound);
        }

        this.query = 'SELECT '+String.join(this.fieldLst,',') 
                            + ','
                            + this.CXM_Service_Field
                            + ','
                            + this.CXM_Latest_Response
                            + ','
                            + this.CXM_Latest_Status
                            + ','
                            + this.ACCOUNT_ID_FIELD
                            + ','
                            + this.REF_NAME_FIELD
                        + ' FROM '+this.OBJ_STR 
                        + ' WHERE Id in '+objIds
                        + this.CRITERIA_SQL;
        try {
            // System.debug('this.query >> ' + this.query);
            CXMServiceProvider cxm = new CXMServiceProvider(this.oldMapParam, this.newMapParam, this.query, this.nextQueue);
            System.enqueueJob(cxm);
            // Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); // << Change to Queueable
        }catch(Exception e) {
            this.executeQuery();
            // this.finish(null); // << Change to Queueable
        }
    }

    private void executeQuery(){
        List<sObject> scope = Database.query(this.query);
        //only support 5000 records
        if (scope != null && scope.size() > 99) {
            addIntegrationLog(startDatetime
                                ,DateTime.now()
                                ,null
                                ,'HIT The LIMIT OF 99 Records, Your amount of record is' 
                                    +scope.size() +'Records'
                                ,false
                                ,''
                                ,''
                                ,'');
            // this.finish(null); // << Change to Queueable

            new DailyScheduleBatch.DailyScheduleException('HIT The LIMIT OF 99 Records, Your amount of record is' 
                                    +scope.size() +'Records' );
        }

        CXMServiceProvider cxm = new CXMServiceProvider(this.oldMapParam, this.newMapParam, this.query, this.nextQueue);
        System.enqueueJob(cxm);
        // this.execute(null,scope); // << Change to Queueable
    }

    public void runBatchForRetry() {
        AppConfig__c cf = AppConfig__c.getValues('CXM_SERVICE_CONNECTOR');
        String isCXMServiceConnector = (cf == null ? 'false' : cf.Value__c);

        Boolean isEnable = isCXMServiceConnector.equalsIgnoreCase('true'); 

        if (!isEnable) return;

        this.init_process();
        
        isRetryBatch = true;

        String retryCriteria = CXM_Latest_Status+' in (\''+OFFHOUR_RETRY+'\',\''+FAIL_WAIT_FOR_RETRY+'\')';

        if (this.fieldLst.contains(this.CXM_Service_Field)) {
            Integer indexFound = this.fieldLst.indexOf(this.CXM_Service_Field);
            this.fieldLst.remove(indexFound);
        }

        if (this.fieldLst.contains(this.ACCOUNT_ID_FIELD)) {
            Integer indexFound = this.fieldLst.indexOf(this.ACCOUNT_ID_FIELD);
            this.fieldLst.remove(indexFound);
        }

        if (this.fieldLst.contains(this.REF_NAME_FIELD)) {
            Integer indexFound = this.fieldLst.indexOf(this.REF_NAME_FIELD);
            this.fieldLst.remove(indexFound);
        }

        this.query = 'SELECT '+String.join(this.fieldLst,',')
                            + ','
                            + this.CXM_Service_Field
                            + ','
                            + this.CXM_Latest_Response
                            + ','
                            + this.CXM_Latest_Status
                            + ','
                            + this.ACCOUNT_ID_FIELD
                            + ','
                            + this.REF_NAME_FIELD
                            + ','
                            + this.RECORDTYPE_DEV_NAME
                        + ' FROM '+this.OBJ_STR 
                        + ' WHERE '+retryCriteria
                        + this.CRITERIA_SQL;
                        //+ ' LIMIT 50';

        try {
            CXMServiceProvider cxm = new CXMServiceProvider(this.oldMapParam, this.newMapParam, this.query, false);
            System.enqueueJob(cxm);
            // Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); // << Change to Queueable
        }catch(Exception e) {
            this.executeQuery();
            // this.finish(null); // << Change to Queueable
        }
    }

    // global Database.QueryLocator start(Database.BatchableContext BC){ // << Change to Queueable
    //     return Database.getQueryLocator(this.query);
    // }

    global void execute(QueueableContext context){
    // global void execute(Database.BatchableContext bc, List<Sobject> scope){ // << Change to Queueable
        this.manager = new EIMManager(this.INEGRATION_NAME);
        //Get Data
        Date today = Date.today();
        Integer d = today.day();
        Integer mo = today.month();
        Integer yr = today.year();

        DateTime startOffHour = DateTime.newInstance(yr, mo, d
                                            , Integer.valueOf(CXM_Service_Start_Hour.split(':').get(0))
                                            , Integer.valueOf(CXM_Service_Start_Hour.split(':').get(1))
                                            , 0);

        DateTime endOffHour = DateTime.newInstance(yr, mo, d
                                            , Integer.valueOf(CXM_Service_End_Hour.split(':').get(0))
                                            , Integer.valueOf(CXM_Service_End_Hour.split(':').get(1))
                                            , 0);

        for (SObject sobj : this.scopeQuery) {
        // for (SObject sobj : scope) { // << Change to Queueable
            Datetime transactionDT = (Datetime)sobj.get(CXM_Service_Field);
            //Integer retryAmount = Integer.valueOf(sobj.get(CXM_Retry_Counter));
            if(this.IS_WRITE_LOG_FLAG) {
                sobj.put(CXM_write_log_flag,this.IS_WRITE_LOG_FLAG);
            }
            
            
            
            if (!this.isRetryBatch && (transactionDT < startOffHour || transactionDT > endOffHour)) {
                //stop call
                sobj.put(CXM_Latest_Response,OFFHOUR_RETRY);
                sobj.put(CXM_Latest_Status,OFFHOUR_RETRY);
                addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    ,sobj
                                    ,OFFHOUR_RETRY 
                                    +'\n TransDT '+transactionDT.format()
                                    +' startOffHour '+startOffHour.format()
                                    +' endOffHour '+endOffHour.format()
                                    ,false
                                    ,''
                                    ,String.valueOf('')
                                    ,sobj.Id);
            }else {
                connectToCXM(sobj);
            }
            
        }
        updateObjects(this.scopeQuery,'CXM','Id');
        // System.debug('this.nextQueue >> ' + this.nextQueue);
        finishQueue();
        // updateObjects(scope,'CXM','Id'); // << Change to Queueable
    }

    private void connectToCXM(SObject sobj) {
        connectToCXM(sobj,0);
    }

    private void connectToCXM(SObject sobj,Integer retryCount) {
        if (sobj == null) return;

        CXMService.TaskEventPort cxm = new CXMService.TaskEventPort();                
        CXMService.ForwardTaskEventResponse_element result 
                                = new CXMService.ForwardTaskEventResponse_element();

        //String channel = 'CRM-CCRP';
        String channel   = this.INEGRATION_Channel;

        try {
            this.manager.getBodyRequest(sobj,JSON);

            String requestBody = this.manager.getBodyRequestMap().get(sobj.Id).escapeHtml4().replace('&nbsp;',' ');
            String dtm         = System.now().format(FORMAT_DTM);
            cxm.timeout_x = 1000*(Integer.valueOf(getConfig('CXM_TIMEOUT','60000'))/1000);
           
            result = cxm.add(sobj.Id,channel,dtm,requestBody); 

            /**
                1001    Integration error
                1002    Communication with backend failed

            **/
            String code = result.Code;
            Boolean isIntegrationSuccess = (code.equals(SUCCESS_CODE) || code.equals(FAIL_CODE));

            while(!isIntegrationSuccess && retryCount < RETRY_MAX) {
                result = cxm.add(sobj.Id,channel,dtm,requestBody);
                code = result.Code;
                isIntegrationSuccess = (code.equals(SUCCESS_CODE) || code.equals(FAIL_CODE));

                if (isIntegrationSuccess) break;
                else retryCount++;
            }

            if (isIntegrationSuccess) {
                sobj.put(CXM_Latest_Response,result.ReqId+' '+result.Description);
                sobj.put(CXM_Latest_Status,result.Code);

                addIntegrationLog(startDatetime
                                        ,DateTime.now()
                                        ,sobj
                                        ,'SUCCESS'+'\n'
                                        + result.ReqId+' '+result.Description
                                        ,true
                                        ,String.valueOf(cxm) + '\n'+requestBody
                                        ,String.valueOf(result)
                                        ,sobj.Id
                                        );
            }else {
                String errorRetry = FAIL_WAIT_FOR_RETRY;
                if (this.isRetryBatch) {
                    errorRetry = FAIL_MAX_FOR_RETRY;
                }

                sobj.put(CXM_Latest_Response,errorRetry);
                sobj.put(CXM_Latest_Status,errorRetry);
                addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    //,this.objectId
                                    ,sobj
                                    ,errorRetry+'\n'
                                    + result.ReqId+' '+result.Description
                                    ,false
                                    ,String.valueOf(cxm) + '\n'+requestBody
                                    ,String.valueOf(result)
                                    ,sobj.Id
                                    );
            }
        }catch( Exception error ){
            if (error.getMessage().contains('System.CalloutException IO Exception: Time out.') && retryCount < RETRY_MAX ) {
                retryCount++;
                connectToCXM(sobj,retryCount);
            }else {
                String errorRetry = FAIL_WAIT_FOR_RETRY;
                if (this.isRetryBatch) {
                    errorRetry = FAIL_MAX_FOR_RETRY;
                }

                sobj.put(CXM_Latest_Response,errorRetry);
                sobj.put(CXM_Latest_Status,errorRetry);
                addIntegrationLog(startDatetime
                                ,DateTime.now()
                                ,sobj
                                ,errorRetry+'\n'
                                +error.getMessage()+ ' '+error.getStackTraceString()
                                ,false
                                ,''
                                ,''
                                ,sobj.Id);
                return;
            }
        }
    }

    private void updateObjects(List<sObject> scope,String jobName,String refField) {
        Database.SaveResult[]  lsr = Database.update(scope, false);
        // Iterate through each returned result
        Integer runningIndex = 0;
        
        for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                }else {
                    String CSV_BODY = '';
                    // Operation failed, so get all errors                
                    String recordId = (String)scope[runningIndex].get(refField);
                    for(Database.Error err : sr.getErrors()) {
                        CSV_BODY = CSV_BODY +recordId + ','
                                                +err.getMessage() + ','
                                                +String.join(err.getFields(),',') + ','
                                                +err.getStatusCode()+'\n';

                        addIntegrationLog(startDatetime
                                ,DateTime.now()
                                //,this.objectId
                                ,scope[runningIndex]
                                ,CSV_BODY
                                ,false
                                ,''
                                ,''
                                ,recordId);
                }  

                runningIndex++; 
            }
        }
    }

    private void addIntegrationLog(DateTime startDatetime
                                  ,DateTime endDatetime
                                  ,Sobject sobj
                                  ,String errorMessages
                                  ,Boolean isRet
                                  ,String requestBody
                                  ,String responseBody
                                  ,String egLog
                                  ) {
            RTL_Online_Service_Log__c inlog = new RTL_Online_Service_Log__c ();
            inlog.RTL_Name_of_User__c = UserInfo.getName();
            
            inlog.RTL_Error_Message__c = errorMessages;
            inlog.RTL_Start_DateTime__c = startDatetime;      
            inlog.RTL_End_DateTime__c   = endDatetime;
            inlog.RTL_Service_Name__c   = this.INEGRATION_NAME;
            inlog.RTL_Is_Success__c     = isRet;
            
            

            if (sobj != null) {
                inlog.RTL_RM_ID__c = sobj.Id;
                inlog.RTL_Mulesoft_Log_Id__c = egLog 
                                                + ' ' + sobj.get(this.FIELD_FOR_LOG);

                if (this.ACCOUNT_ID_FIELD != null  && this.ACCOUNT_ID_FIELD.length() > 0) {
                if (this.ACCOUNT_ID_FIELD.contains('.')) {
                    List<String> sffieldList = this.ACCOUNT_ID_FIELD.split('\\.');
                    SObject tempSobj = null;

                    for (Integer i=0;i<sffieldList.size()-1;i++) {
                        if (tempSobj == null) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }else {
                            tempSobj =  tempSobj.getSobject(sffieldList.get(i));
                        }
                            
                    }  


                    if (tempSobj != null) {
                        String value = String.valueof(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                        inlog.RTL_Account__c =  Id.valueOf(value);
                   }
                }else if(sobj.get(this.ACCOUNT_ID_FIELD) != null) {
                    inlog.RTL_Account__c = Id.valueOf((String)sobj.get(this.ACCOUNT_ID_FIELD));
                }
            }

            if (this.REF_NAME_FIELD != null && this.REF_NAME_FIELD.length() > 0) {
                if (this.REF_NAME_FIELD.contains('.')) {
                    List<String> sffieldList = this.REF_NAME_FIELD.split('\\.');
                    SObject tempSobj = null;
                    
                    for (Integer i=0;i<sffieldList.size()-1;i++) {
                        if (tempSobj == null) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }else {
                            tempSobj =  tempSobj.getSobject(sffieldList.get(i));
                        }
                            
                    }          
                   
                   if (tempSobj != null) {
                        String value = String.valueof(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                        inlog.RTL_Customer_Name__c = value;
                   }
                }else if(sobj.get(this.REF_NAME_FIELD) != null){
                    inlog.RTL_Customer_Name__c = String.valueof(sobj.get(this.REF_NAME_FIELD));
                }
            }

            List<ContentVersion> cvList = new List<ContentVersion>();

            if(!String.isBlank(requestBody)) { 
                OnlineServiceLogUtils.GenerateContentVersions ('requestBody.txt',requestBody,cvList);
            }

            if(!String.isBlank(responseBody)) { 
                OnlineServiceLogUtils.GenerateContentVersions ('responseBody.txt',responseBody,cvList);
            }


            filesAttachMap.put(sobj.Id,cvList);
            //insert content version for file
        }

        this.inlogLst.add(inlog);
    }

    public void finishQueue() {
    // global void finish(Database.BatchableContext bc){ // << Change to Queueable
        System.debug('this.nextQueue >> ' + this.nextQueue);
        if (!this.inlogLst.isEmpty()) {
            insert this.inlogLst;
            //call finish method from error_finish so,there is no doc log.
            // if (bc == null) return; // << Change to Queueable

            List<ContentVersion> allcvList = new List<ContentVersion>();


            for (RTL_Online_Service_Log__c log : this.inlogLst) {
                
                List<ContentVersion> cvList = filesAttachMap.get(log.RTL_RM_ID__c);
                allcvList.addAll(cvList);
            }
            if (allcvList.size() > 0) {
                insert allcvList;
                
                Map<Id,Id> cvLogIdMap = new Map<Id,Id>();
                List<ContentDocumentLink> allcdList = new List<ContentDocumentLink>();
                List<ContentDocumentLink> removeCDList = new List<ContentDocumentLink>();

                for (RTL_Online_Service_Log__c log : this.inlogLst) {
                    List<ContentVersion> cvList = filesAttachMap.get(log.RTL_RM_ID__c);
                    for (ContentVersion cv : cvList) {
                        cvLogIdMap.put(cv.Id,log.Id);
                    }
                }

                OnlineServiceLogUtils.GenerateContentDocumentLink(cvLogIdMap
                                                            ,allcdList
                                                            ,removeCDList
                                                            );
                if (allcdList.size() > 0)    insert allcdList;
                if (removeCDList.size() > 0) delete removeCDList;
            }
        }
        if (this.nextQueue) {
            //Send closed case date update to ECM
            UpdateToECMController callUpdateECM = new UpdateToECMController();
            System.debug('this.oldMapParam >> ' + this.oldMapParam);
            System.debug('this.newMapParam >> ' + this.newMapParam);
            callUpdateECM.caseClosedFromTrigger(this.oldMapParam,this.newMapParam);
        }
    }
}