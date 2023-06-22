global class DailyScheduleBatch implements Database.Batchable<sObject>, Database.Stateful {
    global final String query;
    // instance member to retain state across transactions
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = datetime.now();
    global Datetime batchStartTime = datetime.now();
    global Datetime batchEndTime = null;
    global final static String IS_LOCK_OPPORTUNITY = 'Update_IsLock_Opportunity';

    //For Commerical Campaign Expired and Lead Expired
    global final static String COMMERCIAL_CAMPAIGN_EXPIRED = 'COMMERCIAL_CAMPAIGN_EXPIRED';
    global final static String COMMERCIAL_LEAD_EXPIRED     = 'COMMERCIAL_LEAD_EXPIRED';


    //For INSERT_ROWLOCK_BATCH
    global final static String INSERT_ROWLOCK_BATCH = 'INSERT_ROWLOCK_BATCH';

    global final static String CHANGE_RO_OWNER_BATCH = 'CHANGE_RO_OWNER_BATCH';
    
    //For delete Task call log
    global final static String DELETE_TASK_CALLLOG = 'DELETE_TASK_CALLLOG';

    //For Wealth RM Replace
    global final static String WEALTH_RM_REPLACE = 'WEALTH_RM_REPLACE';
    global final static String WEALTH_BM_ASSIGNED_REPLACE = 'WEALTH_BM_ASSIGNED_REPLACE';
    global final static String WEALTH_ZM_ASSIGNED_REPLACE = 'WEALTH_ZM_ASSIGNED_REPLACE';
    global final static String HANDLE_WEALTH_RM_REORG = 'HANDLE_WEALTH_RM_REORG';
    global final static String HANDLE_INACTIVE_WEALTH= 'HANDLE_INACTIVE_WEALTH';



    
    //For Batch Login History
    global final static String INSERT_USER_LOGIN_HEADER_HISORY_BATCH = 'INSERT_USER_LOGIN_HEADER_HISORY_BATCH';
    global final static String INSERT_USER_LOGIN_DETAIL_HISORY_BATCH = 'INSERT_USER_LOGIN_DETAIL_HISORY_BATCH';
    global final static String DELETE_USER_HISTORYLOG_BATCH = 'DELETE_USER_HISTORYLOG_BATCH';
    //For Batch Login History    

    global final static String EXPIRED_OPPTY_ON_DEMAND = 'EXPIRED_OPPTY_ON_DEMAND';

    //For AutoInactive User
    global final static String AUTO_INACTIVE_USER_BATCH = 'AUTO_INACTIVE_USER_BATCH';

    //For PURGER_VERIFICATION_HISTORY_BATCH
    global final static String PURGE_VERIFICATION_HISTORY_BATCH = 'PURGE_VERIFICATION_HISTORY_BATCH';
    
    //Refacorting Delete Batch 27-12-2017
    private String sobjectName;
    public String jobDailyName;

    private String EMAIL_TO  = 'Operation Team E';
    public String CSV_BODY = '';
    private String SECONDARY_BODY = '';
    private List<String> SEND_EMAIL_LIST = null;

    public List<Id> sucessIdList = new List<Id>();
    private Boolean isFromChainMethod = false;
    private String  chainBatch;

    private String ERRORLOG_FILENAME = '';
    private String CSV_BODY_NOTE = '';

    private String QUERY_SQL = '';


    private Map<String,List<String>> DATA_MAP  = null;
    private String KEY_FIELD_MAP = 'Not Specified Key of Map';

    private Boolean isEmailNotifySuccessAndError = true;

    // [2020-03-03] Add for log to Object UserInactiveHistory.
    private Set<Id> userInactiveList = new Set<Id>();

    //for Success log
    public String CSV_LOG_SUCCESS = '';
    //for Success log

    private String MAINERR_HEADER      = 'RecordId,ErrorMessage,ErrorOnFields,StatusCode\n';
    private String SECONDARYERR_HEADER = 'RecordId,ErrorMessage,ErrorOnFields,StatusCode\n';
    public String SUCCESSLOG_HEAEDER  = 'RecordId,Description\n';

    //for migrate field
    global final static String MIGRATE_INFO = 'MIGRATE_INFO';
    global final static String EXPORT_REPORT = 'EXPORT_REPORT';
    global final static String QUERY_MIGRATE_RE_ORG = 'QUERY_MIGRATE_RE_ORG';
    global final static String IMPORT_MIGRATE_RE_ORG = 'IMPORT_MIGRATE_RE_ORG';
    private Map<String,String> MIGRATEMAP_FIELD = new Map<String,String>();
    global final static String SELECT_FIELDS = 'SELECT_FIELDS';
    global final static String MIGRATE_FIELD = 'MIGRATE_FIELD';
    global final static String MIGRATE_NAME = 'MIGRATE_NAME';

    private DailyBatchAbstract BATCH_ABSTRACT = null;

    public void setDailyBatchAbstract(DailyBatchAbstract batchAbstract) {
        this.BATCH_ABSTRACT = batchAbstract;
    }

    global DailyScheduleBatch(String q
                             ,String jobName
                             ,String objName
                             ,Map<String,String> migratedMapField
                             ,List<String> sendToEmailList){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.MIGRATEMAP_FIELD = migratedMapField;
        this.SUCCESSLOG_HEAEDER = '';
        this.ERRORLOG_FILENAME = this.MIGRATEMAP_FIELD.get(MIGRATE_NAME);
        this.QUERY_SQL = query;
        this.SEND_EMAIL_LIST  = sendToEmailList;
        this.EMAIL_TO  = null;
    }
    //for migrate field
    
    //for Update Email service
    
    private Map<String,Map<String,String>> FieldUpdateMap; 
    global final static String UPDATE_CASE_BY_CONTACT_CENTER = 'UPDATE_CASE_BY_CONTACT_CENTER';
    private List<String> COLUMN_HEADER_LST = null;
    private Map<String,List<String>> FIELD_VALIDATE_MAP = null;
    global DailyScheduleBatch(String q
                             ,String jobName
                             ,String objName
                             ,Map<String,Map<String,String>> fieldUpdateMap
                             ,List<String> colHeaderLst
                             ,List<String> sendToEmailList
                             ,Map<String,List<String>> fieldValidate
                             ){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.FieldUpdateMap = fieldUpdateMap;
        this.EMAIL_TO  = null;
        this.SEND_EMAIL_LIST  = sendToEmailList;
        this.COLUMN_HEADER_LST = colHeaderLst;
        this.FIELD_VALIDATE_MAP = fieldValidate;
    }
    //for Update Email service
    /*
    //for Update Email service
    private Map<String,Map<String,String>> FieldUpdateMap; 
    global final static String UPDATE_CASE_BY_CONTACT_CENTER = 'UPDATE_CASE_BY_CONTACT_CENTER';
    private List<String> COLUMN_HEADER_LST = null;
    */
    global DailyScheduleBatch(String q
                             ,String jobName
                             ,String objName
                             ,Map<String,Map<String,String>> fieldUpdateMap
                             ,List<String> colHeaderLst
                             ,List<String> sendToEmailList){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.FieldUpdateMap = fieldUpdateMap;
        this.EMAIL_TO  = null;
        this.SEND_EMAIL_LIST  = sendToEmailList;
        this.COLUMN_HEADER_LST = colHeaderLst;
    }
    //for Update Email service

    //for long query
    private Boolean IS_LONG_QUERY = false;
    //private Integer LIMIT_ROW_FOR_LONG_QUERY = 200000;
    //private Integer LIMIT_ROW_FOR_LONG_QUERY = 100000;

    AppConfig__c cf = AppConfig__c.getValues('LIMIT_ROW_FOR_LONG_QUERY');
    private Integer LIMIT_ROW_FOR_LONG_QUERY = (cf == null ? 2000 : Integer.valueOf(cf.Value__c));

    
    private String LONG_QUERY = null;
    private String PREFIX_LONG_QUERY = ' ORDER BY Id ASC LIMIT ';
    private Integer LIMIT_ROW_PER_LONG_QUERY = 0;
    private String LATEST_SF_ID = null;
    global DailyScheduleBatch(String q
                             ,String jobName
                             ,String objName
                             ,Integer limitPerQuery
                             ,String successLog
                             ,String failLog
                             ,Integer successRecord
                             ,Integer failRecord
                             ,Boolean isLongQuery
                             ,String lastestSFID
                             ,List<String> sendToEmailList
                             ){
        LONG_QUERY = q;
        LIMIT_ROW_PER_LONG_QUERY = limitPerQuery;

        if (lastestSFID != null && lastestSFID.length() > 0) {
            if (LONG_QUERY.containsIgnoreCase('where'))
                PREFIX_LONG_QUERY = ' AND Id > \''+lastestSFID+'\''+PREFIX_LONG_QUERY;
            else PREFIX_LONG_QUERY = ' WHERE Id > \''+lastestSFID+'\''+PREFIX_LONG_QUERY;
        }

        PREFIX_LONG_QUERY = PREFIX_LONG_QUERY + LIMIT_ROW_PER_LONG_QUERY;
        query = LONG_QUERY + PREFIX_LONG_QUERY;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.IS_LONG_QUERY = isLongQuery;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.CSV_BODY = this.CSV_BODY + failLog;
        this.CSV_LOG_SUCCESS = this.CSV_LOG_SUCCESS + successLog;
        this.EMAIL_TO  = null;
        this.recordsSuccessful = successRecord;
        this.recordsFailed = failRecord;
        this.SEND_EMAIL_LIST  = sendToEmailList;
    }
    //for long query

    //use for main batch
    global DailyScheduleBatch(String q,String jobName,String objName){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.ERRORLOG_FILENAME = this.jobDailyName;
    }

    global DailyScheduleBatch(String q
                                ,Boolean isShowQueryInEmail
                                ,String jobName
                                ,String objName
                                ,String emailToAfterDone){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.EMAIL_TO     = emailToAfterDone;
        this.ERRORLOG_FILENAME = this.jobDailyName;

        if (isShowQueryInEmail) this.QUERY_SQL = q;
    }

    global DailyScheduleBatch(String q,String jobName,String objName,String emailToAfterDone){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.EMAIL_TO     = emailToAfterDone;
        this.ERRORLOG_FILENAME = this.jobDailyName;
    }

    global DailyScheduleBatch(String q,String jobName
                                ,String objName
                                ,Map<String,List<String>> dataMap
                                ,String keyFieldMap
                                ,List<String> sendToEmailList){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.EMAIL_TO     = null;
        this.SEND_EMAIL_LIST  = sendToEmailList;
        this.DATA_MAP = dataMap;
        this.ERRORLOG_FILENAME = jobDailyName + '_'+'TOTAL_'+dataMap.size()+'_ROW';
        this.KEY_FIELD_MAP = keyFieldMap;
    }

    //use for main batch to have chain batch
    global DailyScheduleBatch(String q,String jobName,String objName,String batchChainName,String emailToAfterDone){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        //this.isFromChainMethod is to identify there is a chain batch
        this.isFromChainMethod = true;
        this.chainBatch = batchChainName;
        this.EMAIL_TO     = emailToAfterDone;
        this.ERRORLOG_FILENAME = this.jobDailyName;
    }

    global DailyScheduleBatch(String q,String jobName,String objName,String batchChainName,String emailToAfterDone,Boolean isNotifyEmail){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        //this.isFromChainMethod is to identify there is a chain batch
        this.isFromChainMethod = true;
        this.chainBatch = batchChainName;
        this.EMAIL_TO     = emailToAfterDone;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.isEmailNotifySuccessAndError = isNotifyEmail;
    }

    global DailyScheduleBatch(String q,String jobName,String objName,String emailToAfterDone,Boolean isNotifyEmail){
        query = q;
        this.sobjectName = objName;
        this.jobDailyName = jobName;
        this.EMAIL_TO     = emailToAfterDone;
        this.ERRORLOG_FILENAME = this.jobDailyName;
        this.isEmailNotifySuccessAndError = isNotifyEmail;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    /* This function is used to do SOQL (Not Batch - this function will not call finish function)*/
    public class DailyScheduleException extends Exception {}
    global void executeQuery(){
        List<sObject> scope = Database.query(this.query);
        //only support 5000 records
        if (scope != null && scope.size() > 5000) {
            new DailyScheduleException('HIT The LIMIT OF 5000 Records, Your amount of record is' +scope.size() +'Records' );
        }

        this.execute(null,scope);
    }
    /* This function is used to do SOQL (Not Batch - this function will not call finish function)*/
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        try {
            if (scope.size() > 0) {
                if (this.jobDailyName == IS_LOCK_OPPORTUNITY) {
                    for (sObject obj: scope) {
                        Opportunity opp = (Opportunity)obj;
                        opp.RTL_IsLock__c = true;
                    }                    
                    updateObjects(scope,this.jobDailyName);
                }else if (this.jobDailyName == COMMERCIAL_LEAD_EXPIRED) {
                    RecordType commercial = [select id from RecordType where DeveloperName = 'Commercial_Completed'];
                    Id rtId               = commercial.id;
                    for (sObject obj: scope) {
                        Lead ld = (Lead)obj;
                        ld.status = 'Expired';
                        ld.RecordTypeId  = rtId;
                    }
                    updateObjects(scope,this.jobDailyName);
                }else if (this.jobDailyName == COMMERCIAL_CAMPAIGN_EXPIRED) {
                    for (sObject obj: scope) {
                        Campaign cam = (Campaign)obj;
                        cam.status = 'Expired';
                        cam.IsActive = False;
                    }
                    updateObjects(scope,this.jobDailyName);
                } else if (this.jobDailyName == INSERT_ROWLOCK_BATCH) {
                    
                    Map<String,List<Sobject>> dataInsertRowLockMap 
                                            = new Map<String,List<Sobject>>();

                    for (Sobject obj: scope) {
                        String txtErrMsg = (String)obj.get('RTL_Error_Message__c');

                        Sobject objJsonEntries = (Sobject)JSON.deserialize(txtErrMsg
                                                            , Sobject.class);

                        objJsonEntries.put('RTL_Retry_Info__c',obj.Id);
                        String sobjType = ''+objJsonEntries.getSobjectType();
                        List<Sobject> insertList = null;

                        if (dataInsertRowLockMap.containsKey(sObjType)) {
                            insertList = dataInsertRowLockMap.get(sObjType);
                        }else {
                            String listType = 'List<' + sobjType + '>';
                            insertList = (List<SObject>)Type.forName(listType).newInstance();
                            dataInsertRowLockMap.put(sobjType, insertList);
                        }
                        
                        insertList.add(objJsonEntries);
                        obj.put('RTL_Is_Success__c',true);
                    }

                    for (String key : dataInsertRowLockMap.keySet()) {
                        List<Sobject> insertList = dataInsertRowLockMap.get(key);
                        insertObjects(insertList,this.jobDailyName,'RTL_Retry_Info__c');
                    }
                    updateSecondaryObjects(scope,this.jobDailyName);
                }
                //End case 7040
                //For CR Change RO Owner
                else if (this.jobDailyName == CHANGE_RO_OWNER_BATCH) {
                    List<Account> changeROList = new List<Account>();

                    for (sObject obj: scope) {
                        Account acc = (Account)obj;
                        List<String> empInfoList = this.DATA_MAP.get(acc.TMB_Customer_ID_PE__c);
                        //remove key
                        this.DATA_MAP.remove(acc.TMB_Customer_ID_PE__c);

                        String empCode = empInfoList.get(0);
                        
                        if (empInfoList.get(1) == null || empInfoList.get(1).length() == 0) {
                            this.CSV_BODY_NOTE = this.CSV_BODY_NOTE
                                                    +acc.TMB_Customer_ID_PE__c 
                                                    + ','
                                                    + empCode
                                                    +' OWNER_NOT_FOUND_OR_OWNER_INACTIVE' + ','
                                                    +'OwnerId,'
                                                    +','
                                                    +'\n';
                            recordsFailed++;

                            continue;
                        }

                        acc.OwnerId = empInfoList.get(1);
                        changeROList.add(acc);
                    }
                    updateObjects(changeROList,this.jobDailyName,'TMB_Customer_ID_PE__c');
                }
                //--Delete Task Call Log --
                else if(this.jobDailyName == DELETE_TASK_CALLLOG){                    
                    deleteObjects(scope, this.jobDailyName);
                    
                }
                else if(
                        this.jobDailyName == WEALTH_RM_REPLACE
                    || this.jobDailyName == WEALTH_BM_ASSIGNED_REPLACE
                    || this.jobDailyName == HANDLE_WEALTH_RM_REORG
                    || this.jobDailyName == HANDLE_INACTIVE_WEALTH
                    || this.jobDailyName == WEALTH_ZM_ASSIGNED_REPLACE
                    ){
                    Map<String,String> successMap = new Map<String,String>();

                    List<Sobject> newScopeLst = new List<sObject>();

                    Set<Id> setAssignBRCUser = new Set<Id>();
                    Set<Id> setBranchZoneId = new Set<Id>();
                    for(sObject sobj : scope) {
                        Account acc = (Account)sobj;
                        setAssignBRCUser.add(acc.RTL_Assigned_BRC__c);
                        setBranchZoneId.add(acc.RTL_Most_Operating_Branch__c);
                    }
                    if(setAssignBRCUser.size() > 0 && RTL_AccountUtility.mapUserById == null) {
                        RTL_AccountUtility.generateUserMapId(setAssignBRCUser);
                    }

                    if(setBranchZoneId.size() > 0 && RTL_AccountUtility.mapBranchZoneById == null) {
                        RTL_AccountUtility.generateBranchZoneMapId(setBranchZoneId);
                    }

                    for (sObject sobj : scope) {
                        Account acc = (Account)sobj;

                        String newWealthRM = RTL_AccountUtility.getWealth_RM(acc);

                        // if (newWealthRM != null && newWealthRM.length() > 0 && acc.RTL_Wealth_RM__c != newWealthRM) {
                        if (acc.RTL_Wealth_RM__c != newWealthRM) {
                            String log = 'TMB CUST ID = '+acc.TMB_Customer_ID_PE__c
                                    +' OLD RTL_Wealth_RM__c ='+acc.RTL_Wealth_RM__c;

                            //acc.RTL_Wealth_RM__c = newWealthRM;
                            sobj.put('RTL_Wealth_RM__c',newWealthRM);

                            log += ' NEW RTL_Wealth_RM__c = '+newWealthRM 
                                    + ' RTL_RM_Name__c = '+acc.RTL_RM_Name__c;

                            log += ' NEW LastModifiedDate = '+sobj.get('LastModifiedDate');


                            successMap.put(acc.Id,log);
                            newScopeLst.add(sobj);
                        }
                    }

                    if (newScopeLst!=null && newScopeLst.size() > 0 ) {
                        updateObjects(newScopeLst, this.jobDailyName);

                        for (String successId:this.sucessIdList) {
                            if (successMap.get(successId) != null) {
                                this.CSV_LOG_SUCCESS += successId+','+successMap.get(successId)+'\n';
                            }
                        }
                    }
                }
                //For User Login History Batch
                else if (this.jobDailyName == INSERT_USER_LOGIN_HEADER_HISORY_BATCH) {
                    List<User_Login_History__c> newUserLogList = New  List<User_Login_History__c>();

                    for (sObject obj: scope) {
                        User u = (User)obj;
                        User_Login_History__c newUserLog = New User_Login_History__c();
                        newUserLog.Name = u.Name;
                        newUserLog.Active__c = u.IsActive;
                        newUserlog.Profile__c = u.UserProfileName__c;
                        newUserLog.Role__c = u.UserRoleName__c;
                        newUserLog.Employee_ID__c = u.Employee_ID__c;
                        newUserLog.Email__c = u.Email;           
                        newUserLog.Segment__c = u.Segment__c;
                        newUserLog.Reporting_Segment__c = u.Reporting_Segment__c;
                        newUserLog.Region_Group__c = u.Region__c;
                        newUserLog.Region_Code_Group_Code__c = u.Region_Code__c;
                        newUserLog.Zone_Team__c = u.Zone__c;
                        newUserLog.Zone_Code_Team_Code__c = u.Zone_Code__c;
                        newUserLog.Branch_Team_Name_Code__c = u.RTL_Branch__c;
                        newUserLog.Branch_Team_Code__c = u.RTL_Branch_Code__c;
                        newUserLog.Channel__c = u.RTL_Channel__C;
                        newUserLog.Date__c = System.today();          
                        /*
                        if(u.UserType != 'Standard'){
                            //Not assign owner, it will aotu to system admin 
                        }else{
                            newUserLog.OwnerId = u.id; 
                            //uMap.put(u.id, u); //Add only user Standard to map for use in next query  
                        }*/
                        newUserLog.OwnerId = u.id; 
                        newUserLog.Username__c = u.username; 
                        newUserLog.External_ID__c = u.id+ String.valueOf(system.today());

                        Date loginDate;
                        if(u.LastLoginDate != null ){
                            loginDate = date.newinstance(u.LastLoginDate.year(), u.LastLoginDate.month(), u.LastLoginDate.day());
                        
                            if(loginDate == System.today()){
                                newUserLog.IsLogin__c = True;                 
                            }else{
                                newUserLog.IsLogin__c = False;
                            }
                        }else{
                            newUserLog.IsLogin__c = False;   
                        }
                        newUserLog.Last_Login_Time__c = u.LastLoginDate ;       
                        newUserLogList.add(newUserLog);
                    }

                    insertObjects(newUserLogList,this.jobDailyName,'Id');
                }
                else if (this.jobDailyName == INSERT_USER_LOGIN_DETAIL_HISORY_BATCH) {
                    Map<String,String> userLoginMap = new Map<String,String>();

                    for (sObject obj: scope) {
                        User_Login_History__c userLogin = (User_Login_History__c)obj;
                        userLoginMap.put(userLogin.OwnerId,userLogin.Id);
                    }

                    List<Login_History__c> loginList = New List<Login_History__c>();


                    List<LoginHistory> loginHistories = [SELECT ApiType,
                                    ApiVersion,
                                    Application,
                                    Browser,
                                    ClientVersion,
                                    Id,
                                    LoginTime,
                                    LoginType,
                                    LoginUrl,
                                    Platform,
                                    SourceIp,
                                    Status,
                                    UserId
                            FROM LoginHistory
                            WHERE LoginTime > YESTERDAY
                                AND UserId in : userLoginMap.keySet()
                            ];     

                                                 
                    for(LoginHistory loginH : loginHistories){
                        Login_History__c LoginP = new Login_History__c();
                        loginP.Name = loginP.Id;
                        loginP.ApiType__c = loginH.ApiType;
                        loginP.ApiVersion__c = loginH.ApiVersion;
                        loginP.Application__c = loginH.Application;
                        loginP.Browser__c = loginH.Browser;
                        loginP.ClientVersion__c = loginH.ClientVersion;
                        loginP.LoginTime__c = loginH.LoginTime;
                        loginP.LoginType__c = loginH.LoginType;
                        loginP.Login_URL__c = loginH.LoginUrl;
                        loginP.Platform__c = loginH.Platform;
                        loginP.Source_IP__c = loginH.SourceIp;
                        loginP.Status__c = loginH.status;
                        loginP.CreateDate_Date__c = system.today();

                        LoginP.User_Login_History__c = userLoginMap.get(loginH.UserId);            
                        loginList.add(LoginP);                
                    }

                    insertObjects(loginList,this.jobDailyName,'Id');
                }
                else if (this.jobDailyName == DELETE_USER_HISTORYLOG_BATCH) {
                    deleteObjects(scope, this.jobDailyName);
                }else if (this.jobDailyName == EXPIRED_OPPTY_ON_DEMAND) {
                    List<RecordType> opptyRecordTypeLst = 
                            [Select Id,Developername from RecordType where SobjectType = 'Opportunity' and IsActive = true];

                    Map<String,Id> opptyRecordMap = new Map<String,Id>();

                    for (RecordType rec: opptyRecordTypeLst) {
                        opptyRecordMap.put(rec.DeveloperName, rec.Id);
                    }

                    for (sObject obj: scope) {
                        Opportunity oppty = (Opportunity)obj;
                        String recordTypeName = oppty.RecordType.Developername;

                        oppty.RecordTypeId = opptyRecordMap.get(recordTypeName+'_Closed');
                        oppty.StageName     = 'Closed Expired';
                        oppty.RTL_Status__c = 'Expired';
                    }

                    updateObjects(scope, this.jobDailyName);
                }else if (this.jobDailyName == UPDATE_CASE_BY_CONTACT_CENTER) {
                    this.MAINERR_HEADER = 'RecordId,CaseNumber,ErrorMessage,ErrorOnFields,StatusCode\n';

                    Map<String, Schema.SObjectField> FIELDMAP 
                            = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();

                    List<Sobject> newScopeLst = new List<sObject>();

                    for (SObject sobj : scope) {
                        Map<String,String> caseFieldMap = this.FieldUpdateMap.get('\''+String.valueOf(sobj.Id).subString(0,15)+'\'');

                        Boolean isValid = true;

                        if (this.FIELD_VALIDATE_MAP != null && this.FIELD_VALIDATE_MAP.size() > 0) {
                            for (String field : this.FIELD_VALIDATE_MAP.keySet()) {
                                List<String> valueFieldLst = this.FIELD_VALIDATE_MAP.get(field);
                                String value = String.valueOf(caseFieldMap.get(field));

                                if (value!= null && !valueFieldLst.contains(value)) {
                                    String ErrorOnFields = field;
                                    String ErrorMessage  = value+'_Status_Invalid';
                                    String RecordId      = String.valueOf(sobj.get('Id'));
                                    String CaseNumber    = String.valueOf(sobj.get('CaseNumber'));

                                    this.CSV_BODY = this.CSV_BODY 
                                                        +RecordId 
                                                        + ','
                                                        +CaseNumber 
                                                        + ','
                                                        +ErrorMessage 
                                                        + ','
                                                        +field
                                                        +','
                                                        +''
                                                        +'\n';
                                    isValid = false;
                                }
                            }
                        }

                        for (String key : caseFieldMap.keySet()) {
                            if (isValid) {
                                RTL_Utility.setRelationData(sObj,FIELDMAP,key, caseFieldMap,false);
                            }
                        }

                        if (isValid) {
                            newScopeLst.add(sobj);  
                        }else {
                            recordsFailed++;
                        }
                    }

                    updateObjects(newScopeLst, this.jobDailyName);
                }else if (this.jobDailyName == AUTO_INACTIVE_USER_BATCH) {
                    Map<String,String> successMap = new Map<String,String>();
                    this.SUCCESSLOG_HEAEDER = 'Id,Username,Name,IsActive,LastLoginDate,Employee_ID__c\n';
                    for (sObject obj: scope) {
                        User u = (User)obj;
                        u.IsActive = false;

                        String log = obj.get('Username')
                                    +','
                                    +obj.get('Name')
                                    +','
                                    +obj.get('IsActive')
                                    +','
                                    +obj.get('LastLoginDate')
                                    +','
                                    +obj.get('Employee_ID__c');

                        successMap.put(u.Id,log);

                        // [2020-03-03] Add for log to Object UserInactiveHistory.
                        userInactiveList.add(u.Id);
                    }

                    updateObjects(scope,this.jobDailyName);

                    for (String successId:this.sucessIdList) {
                        if (successMap.get(successId) != null) {
                            this.CSV_LOG_SUCCESS += successId+','+successMap.get(successId)+'\n';
                        }
                    }
                }//--Purger Verification History --
                else if(this.jobDailyName == PURGE_VERIFICATION_HISTORY_BATCH){                    
                    deleteObjects(scope, this.jobDailyName);
                    
                }
                else if (this.jobDailyName == EXPORT_REPORT) {
                    this.ERRORLOG_FILENAME = this.MIGRATEMAP_FIELD.get(MIGRATE_NAME);
                    this.SUCCESSLOG_HEAEDER = '';
                    List<String> fieldLst = this.MIGRATEMAP_FIELD.get(SELECT_FIELDS).split(',');
                    this.SUCCESSLOG_HEAEDER = this.SUCCESSLOG_HEAEDER+String.join(fieldLst,',')+'\n';

                    for (SObject obj : scope) {
                        List<String> valLst = new List<String>();
                        for (String column: fieldLst) {
                           if (column.contains('.')) {
                                List<String> sffieldList = column.split('\\.');
                                SObject tempSobj = null;
                                for (Integer i=0;i<sffieldList.size()-1;i++) {
                                    if (tempSobj == null) tempSobj =  obj.getSobject(sffieldList.get(i));
                                    else tempSobj =  tempSobj.getSobject(sffieldList.get(i));
                                }                   

                                if (tempSobj != null) {
                                    valLst.add(String.valueOf(tempSobj.get(sffieldList.get(sffieldList.size()-1))));
                                }else {
                                    valLst.add('');
                                }
                            }else {
                                Object o = obj.get(column.trim());
                                if(o instanceof Datetime) {
                                    valLst.add(String.valueOf(DateTime.ValueofGmt(String.valueOf(o))));
                                }else {
                                    valLst.add(String.valueOf(o));
                                }
                                
                            }
                        }
                    
                        this.CSV_LOG_SUCCESS = this.CSV_LOG_SUCCESS + String.join(valLst,',')+'\n';

                        recordsSuccessful++;
                    }
                }else if (this.BATCH_ABSTRACT != null) {
                    this.BATCH_ABSTRACT.doAction(bc,scope,this);
                }
            }

            //for long query
            if (IS_LONG_QUERY) {
                Integer sizeRecord = scope.size();
                if (sizeRecord > 0) {
                    this.LATEST_SF_ID = String.Valueof(scope.get(sizeRecord-1).Id);
                }else {
                    this.LATEST_SF_ID = null;
                }
            }
            //for long query
        }catch(Exception err) {
            //print exception
            this.CSV_BODY = this.CSV_BODY +''+ ','
                                                +err.getMessage() + ','
                                                +err.getStackTraceString() + ','
                                                +''+'\n';
        }
    }

    private void insertObjects(List<sObject> scope
                                    ,String jobName
                                    ,String refField) {
        Integer runningIndex = 0;
        Database.SaveResult[]  lsr = Database.Insert(scope, false);

        //System.debug('jobDailyName = ' + this.jobDailyName);
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                recordsSuccessful++;
                this.sucessIdList.add(sr.Id);
            }
            else {
                // Operation failed, so get all errors                
                //Id recordId = scope[runningIndex].Id;
                String recordId = (String)scope[runningIndex].get(refField);
                for(Database.Error err : sr.getErrors()) {
                        this.CSV_BODY = this.CSV_BODY +recordId + ','
                                            +err.getMessage() + ','
                                            +String.join(err.getFields(),',') + ','
                                            +err.getStatusCode()+'\n';

                        System.debug(logginglevel.ERROR, 'There is error on'+this.jobDailyName
                                        +'. Error Message is: ' + err.getMessage());
                }
                recordsFailed++;
            }
            runningIndex++;
        }
    }

    public void updateObjects(List<sObject> scope,String jobName) {
        this.updateObjects(scope,jobName,'Id');
    }

    public void updateObjects(List<sObject> scope,String jobName,String refField) {
        Database.SaveResult[]  lsr = Database.update(scope, false);
        Integer runningIndex = 0;
        // Iterate through each returned result
        for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                    recordsSuccessful++;
                    this.sucessIdList.add(sr.Id);
                }
                else {
                    // Operation failed, so get all errors                
                    String recordId = (String)scope[runningIndex].get(refField);

                    if (this.COLUMN_HEADER_LST != null && this.COLUMN_HEADER_LST.size() > 0) {
                        recordId = '';
                        for (String field : this.COLUMN_HEADER_LST) {
                            recordId += scope[runningIndex].get(field)+',';
                        }

                        recordId = recordId.substring(0,recordId.length()-1);
                    }

                    for(Database.Error err : sr.getErrors()) {
                            this.CSV_BODY = this.CSV_BODY +recordId + ','
                                                +err.getMessage() + ','
                                                +String.join(err.getFields(),',') + ','
                                                +err.getStatusCode()+'\n';

                            System.debug(logginglevel.ERROR, 'There is error on'+this.jobDailyName
                                            +'. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            runningIndex++;
        } 
    }

    private void updateSecondaryObjects(List<sObject> scope,String jobName) {
        Database.SaveResult[]  lsr = Database.update(scope, false);
        Integer runningIndex = 0;
        // Iterate through each returned result
        for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    Id recordId = scope[runningIndex].Id;
                    for(Database.Error err : sr.getErrors()) {
                            this.SECONDARY_BODY = this.SECONDARY_BODY +recordId + ','
                                                +err.getMessage() + ','
                                                +String.join(err.getFields(),',') + ','
                                                +err.getStatusCode()+'\n';

                            System.debug(logginglevel.ERROR, 'There is error on'+this.jobDailyName
                                            +'. Error Message is: ' + err.getMessage());
                    }
                }
        } 
    }
    
    //Add function delete record by Danudath
    private void deleteObjects(List<sObject> scope, String jobName) {
        Database.DeleteResult[]  lsr = Database.delete(scope,false);
        Integer runningIndex = 0;
        // Iterate through each returned result
        for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    recordsSuccessful++;
                    System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    Id recordId = scope[runningIndex].Id;
                    for(Database.Error err : sr.getErrors()) {
                            this.SECONDARY_BODY = this.SECONDARY_BODY +recordId + ','
                                                +err.getMessage() + ','
                                                +String.join(err.getFields(),',') + ','
                                                +err.getStatusCode()+'\n';

                            System.debug(logginglevel.ERROR, 'There is error on'+this.jobDailyName
                                            +'. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            runningIndex++;
        } 
                                        
    }

    global void finish(Database.BatchableContext bc){
        //for long query
        if (this.IS_LONG_QUERY 
                && this.LATEST_SF_ID <> null
                && (this.recordsSuccessful + this.recordsFailed) < this.LIMIT_ROW_FOR_LONG_QUERY) {

            DailyScheduleBatch longQueryBatch = new DailyScheduleBatch(this.LONG_QUERY
                                                                    ,this.jobDailyName
                                                                    ,this.sobjectName
                                                                    ,this.LIMIT_ROW_PER_LONG_QUERY
                                                                    ,this.CSV_LOG_SUCCESS
                                                                    ,this.CSV_BODY
                                                                    ,this.recordsSuccessful
                                                                    ,this.recordsFailed
                                                                    ,this.IS_LONG_QUERY
                                                                    ,this.LATEST_SF_ID
                                                                    ,this.SEND_EMAIL_LIST
                                                                    );

            Id BatchProcessId = Database.ExecuteBatch(longQueryBatch,50);
            return;
        }
        //for long query

        batchEndTime = datetime.now();
        List<String> emailOpsList = new List<String>();

        if (this.EMAIL_TO != null && this.EMAIL_TO.length() > 0) {
            emailOpsList.add(this.EMAIL_TO);
        }
        

        if (this.SEND_EMAIL_LIST != null && this.SEND_EMAIL_LIST.size() > 0) {
            emailOpsList.addAll(this.SEND_EMAIL_LIST);
        }

        if (this.DATA_MAP != null && this.DATA_MAP.size() > 0) {
            for (String key : this.DATA_MAP.keySet()) {
                //to fix issue to count not found records in sql
                recordsFailed++;
                this.CSV_BODY_NOTE = this.CSV_BODY_NOTE
                                                    +key 
                                                    + ','
                                                    +this.KEY_FIELD_MAP+' not Found' 
                                                    +','
                                                    +','
                                                    +'\n';
            } 
        }

        if (this.isEmailNotifySuccessAndError || this.recordsFailed > 0) {
            String filename = this.ERRORLOG_FILENAME +'_'+ String.Valueof(Datetime.now());
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , filename
                                                        , sobjectName
                                                        , emailOpsList
                                                        , this.CSV_BODY+this.CSV_BODY_NOTE
                                                        , this.SECONDARY_BODY
                                                        , this.CSV_LOG_SUCCESS
                                                        , this.MAINERR_HEADER
                                                        , this.SECONDARYERR_HEADER
                                                        , this.SUCCESSLOG_HEAEDER
                                                        , this.QUERY_SQL
                                                        );
        }
        
        

        if (isFromChainMethod) chainFinishJob(); 

        //for long query
        if (this.IS_LONG_QUERY && this.LATEST_SF_ID <> null) {
            //next email for long query
            DailyScheduleBatch longQueryBatch = new DailyScheduleBatch(this.LONG_QUERY
                                                                    ,this.jobDailyName
                                                                    ,this.sobjectName
                                                                    ,this.LIMIT_ROW_PER_LONG_QUERY
                                                                    ,''
                                                                    ,''
                                                                    ,0
                                                                    ,0
                                                                    ,this.IS_LONG_QUERY
                                                                    ,this.LATEST_SF_ID
                                                                    ,this.SEND_EMAIL_LIST
                                                                    );

            Id BatchProcessId = Database.ExecuteBatch(longQueryBatch,50);
            return;
        } 
        //for long query

        //For Auto Inactive user batch need to log the inactive user here to avoid MIX DML error.
        if (this.jobDailyName == AUTO_INACTIVE_USER_BATCH && userInactiveList.size() > 0){
            insertUserInactiveHistory(userInactiveList);
        }
    }

    private void chainFinishJob() {
        String qryChain     = null;
        String chainObjName = 'NA';
        Integer chainBatchSize = 50;

        if (this.chainBatch == COMMERCIAL_LEAD_EXPIRED && this.sucessIdList != null && this.sucessIdList.size() > 0) {
            //do Commercial Lead Expired
            String priCampIds = '(\''+String.join(this.sucessIdList, '\',\'')+'\')';
            chainObjName = 'Lead';
            qryChain = 'SELECT Id,Name,Primary_Campaign__c ,status,RecordTypeId From Lead '
                        + 'WHERE status IN (\'Open\',\'Passed Prescreening\', \'Contacted\')'
                        + ' AND Primary_Campaign__c  IN '+priCampIds;
        }else if (this.chainBatch == INSERT_USER_LOGIN_DETAIL_HISORY_BATCH && this.sucessIdList != null && this.sucessIdList.size() > 0) {

            String userLoginIds = '(\''+String.join(this.sucessIdList, '\',\'')+'\')';

            qryChain = 'Select ID,External_ID__c,OwnerId,Owner.Name from User_Login_History__c '
                        + ' where Id  IN '+userLoginIds;

            chainObjName = 'User_Login_History__c';
        }

        
        if (qryChain != null && qryChain.length() > 0) {
             DailyScheduleBatch chainBatchExe = new DailyScheduleBatch(qryChain
                                                                    ,this.chainBatch
                                                                    ,chainObjName
                                                                    ,this.EMAIL_TO
                                                                    ,this.isEmailNotifySuccessAndError);

            Id BatchProcessId = Database.ExecuteBatch(chainBatchExe,chainBatchSize);
        }
    }

    // [2020-03-03] Add for log to Object UserInactiveHistory.
    private void insertUserInactiveHistory(Set<Id> Ids) {
        List<UserInactiveHistory__c> userInactiveHisList = new List<UserInactiveHistory__c>();
        List<User> users = [SELECT Id,Username,Email,Title,UserRoleName__c
                                   ,UserProfileName__c,LastLoginDate,Employee_ID__c
                                   ,Segment__c,Reporting_Segment__c,Region__c
                                   ,Region_Code__c,Zone__c,Zone_Code__c
                                   ,RTL_Branch__c,RTL_Branch_Code__c
                                   ,RTL_Channel__c,LastModifiedDate,CreatedDate
                            FROM User 
                            WHERE Id IN : Ids];
        for(User u : users){

            UserInactiveHistory__c userInactiveHis = new UserInactiveHistory__c();
            userInactiveHis.User__c = u.Id;
            userInactiveHis.UserName__c = u.Username;
            userInactiveHis.UserEmail__c = u.Email;
            userInactiveHis.Title__c = u.Title;
            userInactiveHis.Role__c = u.UserRoleName__c;
            userInactiveHis.Profile__c = u.UserProfileName__c;
            userInactiveHis.Employee_ID__c = u.Employee_ID__c;
            userInactiveHis.Segment__c = u.Segment__c;
            userInactiveHis.Reporting_Segment__c = u.Reporting_Segment__c;
            userInactiveHis.Region__c = u.Region__c;
            userInactiveHis.Region_Code__c = u.Region_Code__c;
            userInactiveHis.Zone__c = u.Zone__c;
            userInactiveHis.Zone_Code__c = u.Zone_Code__c;
            userInactiveHis.RTL_Branch__c = u.RTL_Branch__c;
            userInactiveHis.RTL_Branch_Code__c = u.RTL_Branch_Code__c;
            userInactiveHis.RTL_Channel__c = u.RTL_Channel__c;
            userInactiveHis.Last_Login_Date__c = u.LastLoginDate;
            userInactiveHis.LastModified_Datetime__c = u.LastModifiedDate;
            userInactiveHis.Created_Datetime__c = u.CreatedDate;
                
            userInactiveHisList.add(userInactiveHis);
            System.debug('User Inactive: ' + userInactiveHis);
        }

        Database.SaveResult[]  lsr = Database.Insert(userInactiveHisList, false);

        //System.debug('jobDailyName = ' + this.jobDailyName);
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                // Log nothing.
            }
            else {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug(logginglevel.ERROR, 'Error Message is: ' + err.getMessage());
                }
            }
        }
    }
}