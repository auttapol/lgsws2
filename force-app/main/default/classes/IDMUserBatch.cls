global class IDMUserBatch implements Database.Batchable<sObject> ,
    Database.Stateful {
    /**
    * @author Keattisak Chinburarat
    * @date 2016-11-24
    * @description
    */
    global string batchname = 'IDMUserBatch';
    global string batchtype = 'HCM';
    global BatchHistory__c m_batchHistory;
    global String query;
    global List<String> fields = new List<String> {
        'FirstName',
        'LastName',
        'Email',
        'Employee_ID__c',
        'Manager_Employee_ID__c',
        'ProfileId',
        'IsActive',
        'Profile.Name',
        'IsDataChange__c'
    };
    global IDMUserBatch() {
        system.debug('=>4: Invoked IDMUserBatch ');
        
        query = 'Select Id ,' + String.join(fields, ',') + ' From User Where LastModifiedDate = TODAY ';
        /**** Change Condition 2017-07-20 (CR HCM) ****/
        //query += ' AND Manager_Employee_ID__c != null AND IsActive = true';
        query += ' AND IsDataChange__c = true AND IsActive = true';
        /**** Change Condition 2017-07-20 (CR HCM) ****/
        
        if(Test.isRunningTest()){
            query += ' LIMIT 200 '; // prevent batch run more than 1 loop
        }    
    }
    //Lazy Load Pattern
    global BatchHistory__c BatchHistory {
        get{
            if (null == m_batchHistory) {
                //  has record this day
                List<BatchHistory__c> hts = [Select Id, Name,LastModifiedDate From BatchHistory__c Where CreatedDate = today ]; 
                if (hts.size() > 0) {
                    m_batchHistory = hts[0];
                } else {
                    m_batchHistory = (BatchHistory__c)BatchHistory__c.sObjectType.newSObject(null, true);
                    m_batchHistory.Batch_Name__c = batchname;
                    m_batchHistory.Batch_Type__c = batchtype;
                    insert m_batchHistory;
                }
            }
            return m_batchHistory;
        }
    }
    global map<string, User> getManagerUser(List<sObject> dataset) {
        Map<string, User> mapOfManagerUserByEmployeeId = new Map<string, User>();
        //Find Manager by Employee Id
        Set<string> setManagerEmployeeCode = new Set<string>();
        for (User u : (List<User>)dataset) {
            if (String.isNotEmpty(u.Manager_Employee_ID__c)) {
                setManagerEmployeeCode.add(u.Manager_Employee_ID__c);
            }
        }
        //Flow 1): Setup Manager salesforce id to User object
        if (setManagerEmployeeCode.size() > 0) {
            // Make Manager data set
            for (List<User> users : [Select Id, Name, Email , Employee_ID__c , IsActive,Manager.IsActive,Manager_Employee_ID__c
                                     From User
                                     Where Employee_ID__c IN: setManagerEmployeeCode]) {
                for (User u : users) { 
                    if (!mapOfManagerUserByEmployeeId.containsKey(u.Employee_ID__c)) {
                        mapOfManagerUserByEmployeeId.put(u.Employee_ID__c, u);
                    }
                }
            }
        }

        return mapOfManagerUserByEmployeeId;
    }
    global BatchHistoryDetail__c createlog(BatchHistoryDetail__c log, User usr, string errorMessage, string status) {
        //3.  Do tmb want success log and error log ?
        //Yes, Prefer to get separate result both of success log and error log
        //Field : profile , Sfid (object user) , employeeID 5 digits , employeename , managerid 5 digits, status , error description.
        List<String> msgs = new List<String>();
        msgs.add(usr.Profile.Name);
        msgs.add(usr.Id);
        msgs.add(usr.Employee_ID__c);
        msgs.add(usr.FirstName + ' ' + usr.LastName);
        msgs.add(usr.Manager_Employee_ID__c);
        msgs.add(status);
        msgs.add(errorMessage);
        log.User__c = usr.Id;
        log.Status__c = status;
        log.Message__c = String.join(msgs, ',');
        log.MessageDetails__c = 'Profile: '+msgs[0]+' ,UserId: '+msgs[1]+' ,EmployeeId: '+msgs[2]+' ,UserName: '+msgs[3]+' ,ManagerId: '+msgs[4]+' ,Status: '+msgs[5]+' ,Message: '+msgs[6];
        log.Batch_History__c = BatchHistory.Id;
        return log;
    }
    /**
    * Batch Implementation
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }
        // Loop 200 records
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //Apply SRC
        Map<string, User> mapOfManagerUserByEmployeeId = getManagerUser(scope);
        List<BatchHistoryDetail__c> idmlogs = new List<BatchHistoryDetail__c>();
        
        //Flow 1.1): Map Manager salesforce id to user
        if (mapOfManagerUserByEmployeeId.size() > 0) {
            List<User> listUserNeedToUpdateMangerId = new  List<User>();
            for (User u : (List<User>)scope) {
                /**** Change Condition 2017-07-20 (CR HCM) ****/
                //boolean exp1 = String.isNotEmpty(u.Manager_Employee_ID__c);
                boolean exp1 = u.IsDataChange__c;
                /**** Change Condition 2017-07-20 (CR HCM) ****/
                boolean exp2 = mapOfManagerUserByEmployeeId.containsKey(u.Manager_Employee_ID__c);
                System.debug('u.Manager_Employee_ID__c :'+u.Manager_Employee_ID__c);
                System.debug('manager is inactive or not? : '+((User)mapOfManagerUserByEmployeeId.get(u.Manager_Employee_ID__c)));
                if (exp1 && exp2 ) {
                    if(((User)mapOfManagerUserByEmployeeId.get(u.Manager_Employee_ID__c)).IsActive){
                        u.ManagerId = ((User)mapOfManagerUserByEmployeeId.get(u.Manager_Employee_ID__c)).Id;
                        u.DelegatedApproverId = ((User)mapOfManagerUserByEmployeeId.get(u.Manager_Employee_ID__c)).Id;
                        listUserNeedToUpdateMangerId.add(u);
                    }else{
                        BatchHistoryDetail__c log  = (BatchHistoryDetail__c)BatchHistoryDetail__c.sObjectType.newSObject(null, true);
                        log = createlog(log, u , statuscodeMap().get('HCM0002').Status_Message_EN__c, 'Fail'); //Manager is inactive
                        idmlogs.add(log);  
                    }  
                }else {
                    //No Manager
                    BatchHistoryDetail__c log  = (BatchHistoryDetail__c)BatchHistoryDetail__c.sObjectType.newSObject(null, true);
                    log = createlog(log, u , statuscodeMap().get('HCM0003').Status_Message_EN__c, 'Fail'); //  Can not find Manager for this user
                    idmlogs.add(log);
                }
            }
            if (listUserNeedToUpdateMangerId.size() > 0) {
                try {
                    // version 1 =>  update listUserNeedToUpdateMangerId;
                    // version 2 =>  Partial Insert
                    Database.SaveResult[] srList = Database.update(listUserNeedToUpdateMangerId, false);
                    User retUser = new User();
                    // Iterate through each returned result
                    List<string> logs = new list<string>();
                    for(integer i = 0; i < listUserNeedToUpdateMangerId.size() ; i++){
                    Database.SaveResult sr = srList[i];
                        
                        BatchHistoryDetail__c log  = (BatchHistoryDetail__c)BatchHistoryDetail__c.sObjectType.newSObject(null, true);
                        
                            retUser = (User)listUserNeedToUpdateMangerId[i];
                            if (!sr.isSuccess()) {
                                //Fail Case :
                                string error = '';
                                
                                for (Database.Error err : sr.getErrors()) {
                                    error = 'Fail to update cause : ' +
                                        'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() +
                                        'User fields that affected this error: ' + err.getFields();
                                }
                                log = createlog(log, retUser , error, 'Fail');
                            } else {
                                //Success Case :
                                log = createlog(log, retUser , statuscodeMap().get('HCM0001').Status_Message_EN__c, 'Success'); // Update Manager successfully
                            }
                            idmlogs.add(log);
                        //}
                    
                    }
                    //Insert Log Details
                } catch (Exception ex) {
                }
            }
        }
        //>End Flow 1.1): Map Manager salesforce id to user
        else {
            // No Manager for all user
            for (User u : (List<User>)scope) {
                BatchHistoryDetail__c log  = (BatchHistoryDetail__c)BatchHistoryDetail__c.sObjectType.newSObject(null, true);
                log = createlog(log, u , statuscodeMap().get('HCM0003').Status_Message_EN__c, 'Fail'); //Can not find Manager for this user
                idmlogs.add(log);
            }
        }
        insert idmlogs;
        
        // get userId that had created log already
        List<Id> userinlogs = new List<Id>();
        List<User> clearManagerIdTemp = new List<User>();
        for(BatchHistoryDetail__c batchlogs : idmlogs){
            userinlogs.add(batchlogs.User__c);
        }
        
        // find user for clear Manager_Employee__ID__c to Blank and update
        List<User> userToclear = new List<User>([SELECT Id, Manager_Employee_ID__c, IsDataChange__c FROM User WHERE Id IN: userinlogs]);
        if(userToclear.size() > 0){
            for(User clearMngTemp: userToclear){
                /**** Change Condition 2017-07-20 (CR HCM) ****/
                //clearMngTemp.Manager_Employee_ID__c = '';
                clearMngTemp.IsDataChange__c = false;
                /**** Change Condition 2017-07-20 (CR HCM) ****/
                clearManagerIdTemp.add(clearMngTemp);
            }
            update clearManagerIdTemp;
        }

    }
    global void finish(Database.BatchableContext BC) {
        
        //1) Send mail
        
        try {
        
            list<string> ListIdUser = new list<string>();
            list<string> ListIdNewUser = new list<string>();
            list<string> ListIdMovementUser = new list<string>();
            //list<User> ListIdMovementUser = new list<User>();
            list<BatchHistoryDetail__c> ListBatchDetail = new list<BatchHistoryDetail__c>();
    
            for(BatchHistoryDetail__c b : [select id,Batch_History__c,User__c,IsSendMail__c,Status__c from BatchHistoryDetail__c 
                                           where createddate = TODAY and Status__c = 'Success' and IsSendMail__c = false])
            {
                ListIdUser.add(b.User__c);
                ListBatchDetail.add(b);
            } 
            
            for(user u: [Select Id From User Where LastModifiedDate = TODAY and CreatedDate = TODAY and id in: ListIdUser])
            {
                ListIdNewUser.add(u.id);
            }
            
            for(user u: [Select Id From User Where LastModifiedDate = TODAY and CreatedDate != TODAY and id in: ListIdUser])
            {
                ListIdMovementUser.add(u.Id);
            }
            
            IDMUserEmailServices callMail = new IDMUserEmailServices();
        
            if (ListIdNewUser.size() > 0)
                callMail.sendMailToUser(ListIdNewUser, 'HCM:Email Template for New User');
            if (ListIdMovementUser.size() > 0)
                callMail.sendMailToUser(ListIdMovementUser, 'HCM:Email Template for User Movement');
            
            for (BatchHistoryDetail__c b : ListBatchDetail) 
            {
                b.IsSendMail__c = true;
            }
            
            update ListBatchDetail;
        
        }catch(exception ex){
            system.debug('Line - '+ex.getLineNumber()+' Error - '+ex.getMessage());
        }
        // Send mail result
        IDMUserEmailServices callMail = new IDMUserEmailServices();
        List<BatchHistory__c> bht = new List<BatchHistory__c>([SELECT Id,LastModifiedDate FROM BatchHistory__c WHERE CreatedDate = TODAY]);
        List<String> endTimeList = new List<String>();
        if(AppConfig__c.getValues('HCM_BatchEndTime').Value__c != null){
            endTimeList = (AppConfig__c.getValues('HCM_BatchEndTime').Value__c).split(':');
            Integer hour = Integer.valueOf(endTimeList[0]);
            Integer minute = Integer.valueOf(endTimeList[1]);
            Time endTime = Time.newInstance(hour, minute, 0, 0);
            if(bht.size() > 0){
                  if(bht[0].LastModifiedDate.time() > endTime || System.now().time() > endTime){
                    callMail.sendMailResult(); 
                }  
            }       
        }else{
            System.debug('## HCM_BatchEndTime is Blank');
        }
        //2) purge log
        PurgeBatchHistoryServices purgeService = new PurgeBatchHistoryServices();
        purgeService.Purgelog();



        try {
            AppConfig__c cf = AppConfig__c.getValues('IS_WEALTH_RM_BATCH');
            String isWealthRMBatch = (cf == null ? 'false' : cf.Value__c);

            Boolean isEnable = isWealthRMBatch.equalsIgnoreCase('true'); 
            
            if (isEnable) {
                executeWealthRMBatch();
            }
        }catch(Exception e) {
            System.debug(e);
        }
        
    }


    private void executeWealthRMBatch() {

        //AppConfig__c cf2 = AppConfig__c.getValues('N_DAYS_WEALTH_RM_BATCH');
        //Integer ndays = (cf2 == null ? Integer.valueOf('3') : Integer.valueOf(cf2.Value__c));
        //do Wealth RM replacement
        String wealthRMSQL = 'SELECT Id,RecordType.Name,RTL_Wealth_RM__c,RTL_Wealth_RM__r.Employee_ID__c,RTL_RM_Name__c,TMB_Customer_ID_PE__c,RTL_Assigned_BRC__c,RTL_Most_Operating_Branch__c,LastModifiedDate FROM Account '
                                + ' WHERE RecordType.Name in (\'Retail Customer\',\'Existing Customer\') and RTL_Wealth_RM__c = null'
                                + ' and RTL_RM_Name__c <> null and RTL_RM_Name__c <> \'00000\' ';

        DailyScheduleBatch wealthRMBatch = new DailyScheduleBatch(wealthRMSQL
                                                ,true
                                                ,DailyScheduleBatch.WEALTH_RM_REPLACE
                                                ,'Account'
                                                ,'CRM Admin 2');

        Id WealTHRMBatchId = Database.ExecuteBatch(wealthRMBatch,20);

        List<String> sendToEmailList = new List<String>();
        sendToEmailList.add('CRM Admin 2');

        AppConfig__c limitWealtchBatch = AppConfig__c.getValues('N_LIMIT_FOR_WEALTH_BATCH');
        Integer nLimit = (limitWealtchBatch == null ? Integer.valueOf('4000') : Integer.valueOf(limitWealtchBatch.Value__c));

        String wealthRMBMAssignedSQL = 'SELECT Id,RecordType.Name,RTL_Wealth_RM__c,RTL_Wealth_RM__r.Employee_ID__c,RTL_RM_Name__c,TMB_Customer_ID_PE__c,RTL_Assigned_BRC__c,RTL_Most_Operating_Branch__c,LastModifiedDate FROM Account '
                                                    + ' WHERE IsBranchManagerWealthAssigned_Date__c = TODAY';
            										//+ ' WHERE RecordType.Name in (\'Retail Customer\',\'Existing Customer\') '
                                                    //+ ' and Is_Branch_Manager_Wealth_Assigned__c = true and LastModifiedDate = LAST_N_DAYS:'+ndays;
                                                    //+ ' and Is_Branch_Manager_Wealth_Assigned__c = true';

        
        /*
        DailyScheduleBatch wealthRMBMAssignedBatch = new DailyScheduleBatch(wealthRMBMAssignedSQL
                                                ,true
                                                ,DailyScheduleBatch.WEALTH_BM_ASSIGNED_REPLACE
                                                ,'Account'
                                                ,'CRM Admin 2');*/



        DailyScheduleBatch wealthRMBMAssignedBatch = new DailyScheduleBatch(wealthRMBMAssignedSQL
                                                                ,DailyScheduleBatch.WEALTH_BM_ASSIGNED_REPLACE
                                                                ,'Account'
                                                                ,nLimit
                                                                ,''
                                                                ,''
                                                                ,0
                                                                ,0
                                                                ,true
                                                                ,''
                                                                ,sendToEmailList
                                                                );

        Id WealTHRMRMBatchId = Database.ExecuteBatch(wealthRMBMAssignedBatch,50);

        // String wealthRMZMAssignedSQL = 'SELECT Id,RecordType.Name,RTL_Wealth_RM__c ,RTL_RM_Name__c,TMB_Customer_ID_PE__c,RTL_Assigned_BRC__c,RTL_Most_Operating_Branch__c FROM Account '
        //     										+ ' WHERE IsZoneManagerWealthAssigned_Date__c  = TODAY';
        //                                             //+ ' WHERE RecordType.Name in (\'Retail Customer\',\'Existing Customer\') '
        //                                             //+ ' and Is_Zone_Manager_Wealth_Assigned__c  = true and LastModifiedDate = LAST_N_DAYS:3 ';
        //                                             //+ ' and Is_Zone_Manager_Wealth_Assigned__c  = true';
        // /*
        // DailyScheduleBatch wealthRMZMAssignedBatch = new DailyScheduleBatch(wealthRMZMAssignedSQL
        //                                         ,DailyScheduleBatch.WEALTH_ZM_ASSIGNED_REPLACE
        //                                         ,'Account'
        //                                         ,'CRM Admin 2');*/

        // DailyScheduleBatch wealthRMZMAssignedBatch = new DailyScheduleBatch(wealthRMZMAssignedSQL
        //                                                         ,DailyScheduleBatch.WEALTH_ZM_ASSIGNED_REPLACE
        //                                                         ,'Account'
        //                                                         ,nLimit
        //                                                         ,''
        //                                                         ,''
        //                                                         ,0
        //                                                         ,0
        //                                                         ,true
        //                                                         ,''
        //                                                         ,sendToEmailList
        //                                                         );

        // Id WealTHRMZMBatchId = Database.ExecuteBatch(wealthRMZMAssignedBatch,50);

        String handleReorgSQL = 'SELECT Id,RecordType.Name,RTL_Wealth_RM__c,RTL_Wealth_RM__r.Employee_ID__c ,RTL_RM_Name__c,TMB_Customer_ID_PE__c,RTL_Assigned_BRC__c,RTL_Most_Operating_Branch__c,LastModifiedDate FROM Account '
                                                    + ' WHERE IsReorgWealthRM_Date__c = TODAY';
            										//+ ' WHERE RecordType.Name in (\'Retail Customer\',\'Existing Customer\') '
                                                    //+ ' and Is_Reorg_Wealth_RM__c = true';
                                                    //+ ' and LastModifiedDate = LAST_N_DAYS:'+ndays;


        /*
        DailyScheduleBatch handleReorgSQLBatch = new DailyScheduleBatch(handleReorgSQL
                                                ,true
                                                ,DailyScheduleBatch.HANDLE_WEALTH_RM_REORG
                                                ,'Account'
                                                ,'CRM Admin 2');*/

        DailyScheduleBatch handleReorgSQLBatch = new DailyScheduleBatch(handleReorgSQL
                                                                ,DailyScheduleBatch.HANDLE_WEALTH_RM_REORG
                                                                ,'Account'
                                                                ,nLimit
                                                                ,''
                                                                ,''
                                                                ,0
                                                                ,0
                                                                ,true
                                                                ,''
                                                                ,sendToEmailList
                                                                );


        Id handleReorgSQLBatchId = Database.ExecuteBatch(handleReorgSQLBatch,50);

        

        String handleWealthInactiveSQL = 'SELECT Id,RecordType.Name,RTL_Wealth_RM__c,RTL_Wealth_RM__r.Employee_ID__c ,RTL_RM_Name__c,TMB_Customer_ID_PE__c,RTL_Assigned_BRC__c,RTL_Most_Operating_Branch__c,LastModifiedDate FROM Account '
                                                    + ' WHERE RecordType.Name in (\'Retail Customer\',\'Existing Customer\') '
                                                    + ' and RTL_RM_Name__c <> null and RTL_RM_Name__c <> \'00000\' and RTL_Wealth_RM__c <> null '
                                                    //+ ' and RTL_Wealth_RM__r.IsActive = false and LastModifiedDate = LAST_N_DAYS:'+ndays;
                                                    + ' and RTL_Wealth_RM__r.IsActive = false ';


        /*
        DailyScheduleBatch handleWealthInactiveSQLBatch = new DailyScheduleBatch(handleWealthInactiveSQL
                                                ,true
                                                ,DailyScheduleBatch.HANDLE_INACTIVE_WEALTH
                                                ,'Account'
                                                ,'CRM Admin 2');*/

         DailyScheduleBatch handleWealthInactiveSQLBatch = new DailyScheduleBatch(handleWealthInactiveSQL
                                                                ,DailyScheduleBatch.HANDLE_INACTIVE_WEALTH
                                                                ,'Account'
                                                                ,nLimit
                                                                ,''
                                                                ,''
                                                                ,0
                                                                ,0
                                                                ,true
                                                                ,''
                                                                ,sendToEmailList
                                                                );

        Id handleWealthInactiveSQLId = Database.ExecuteBatch(handleWealthInactiveSQLBatch,50);

      
        //do Wealth RM replacement
    }
    
        public static Map<String,Host_Status_Code__mdt> statuscodeMap(){
            Map<String,Host_Status_Code__mdt> statuscodeMap = new Map<String,Host_Status_Code__mdt>();
            for(Host_Status_Code__mdt statuscode : [SELECT Id,DeveloperName,Status_Message_EN__c,Status_Message_TH__c 
                                                     FROM Host_Status_Code__mdt 
                                                     WHERE Host_System__c =: 'HCM']){
                statuscodeMap.put(statuscode.DeveloperName, statuscode);
            }
            return statuscodeMap;
        }
    
    /**
    * Batch Exception
    */
    public class IDMUserBatchException extends Exception {}
}