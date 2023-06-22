global class RTL_SchedulerEmailErrorLog implements Schedulable{
    global void execute(SchedulableContext sc){ 
        String query = 'select ID from RTL_Online_Service_Log__c where CreatedDate = YESTERDAY';
        RTL_BatchEmailErrorLog logPurge = new RTL_BatchEmailErrorLog(query);
        Id BatchProcessId = Database.ExecuteBatch(logPurge);
        String optToLockQuery = 'Select Id,RTL_IsLock__c from Opportunity '
                                +' where RTL_Lock_Opp_Date__c <= TODAY and RTL_IsLock__c = false'
                                +' AND RecordType.DeveloperName in (\'Retail_Bancassurance\',\'Retail_Card_and_RDC\',\'Retail_Deposit\',\'Retail_Investment\',\'Retail_Loans\',\'Retail_Others\') '
                                +' AND (StageName in (\'Closed Won (Cards)\',\'Closed Won (Loans)\',\'Closed Won\') OR StageName in (\'Closed Won (Deposit)\',\'Closed Won (Others)\',\'Closed Lost\',\'Closed Won (Retention)\'))';
                                

        if(Test.isRunningTest()){
            optToLockQuery += ' LIMIT 200';
        }

        DailyScheduleBatch optToLockBatch = new DailyScheduleBatch(optToLockQuery,DailyScheduleBatch.IS_LOCK_OPPORTUNITY,'Opportunity');
        Id BatchProcessIdForOptToLock = Database.ExecuteBatch(optToLockBatch);

        //For Commercial Campaign and Lead Expired
        String queryCampaignExpr = 'SELECT Id, Name, RecordType.DeveloperName,IsActive,EndDate, Status From Campaign '
                                +' Where Status != \'Expired\' AND EndDate < TODAY '
                                +' AND RecordType.DeveloperName = \'Commercial\' ';

        if(Test.isRunningTest()){
            queryCampaignExpr += ' LIMIT 200';
        }

        DailyScheduleBatch comCamapginExpr = new DailyScheduleBatch(queryCampaignExpr
                                                                    ,DailyScheduleBatch.COMMERCIAL_CAMPAIGN_EXPIRED
                                                                    ,'Campaign'
                                                                    ,DailyScheduleBatch.COMMERCIAL_LEAD_EXPIRED
                                                                    ,'CRM Admin 2');

        Id BatchProcessIdForCampExpr = Database.ExecuteBatch(comCamapginExpr);
        //For Commercial Campaign and Lead Expired

        //Start Case No.7040 For Insert Rowlock Retry  
        String queryInsertRowLock = 'SELECT Id, Name, RTL_Service_Name__c, RTL_Error_Message__c, RTL_Is_Success__c' 
                                    +' FROM RTL_Online_Service_Log__c '
                                    +' Where RTL_Is_Success__c = False '
                                    +' AND RTL_Service_Name__c = \'Insert Retry Rowlock Fail\' ';
                                    
        //queryInsertRowLock += 'LIMIT 2';
        if(Test.isRunningTest()){
            queryInsertRowLock += ' LIMIT 200';
        }

        DailyScheduleBatch insertRowLockBatch = new DailyScheduleBatch(queryInsertRowLock
                                                ,DailyScheduleBatch.INSERT_ROWLOCK_BATCH
                                                ,'RTL_Online_Service_Log__c'
                                                ,'CRM Admin 2');

        Id BatchProcessIdForCampMem = Database.ExecuteBatch(insertRowLockBatch);
        //End Case No.7040 For Insert Rowlock Retry  

        
        //---Start query Task call log last 90 days for Delete--
        String queryDeleteTask = 'select ID,recordtypeID, CreatedDate from Task '+ 
                                      'WHERE CreatedDate < LAST_N_DAYS:90' +
                                      'AND RecordType.Name  = \'Call Log Record Type\'';
         DailyScheduleBatch deleteTaskCallLogBatch = new DailyScheduleBatch(queryDeleteTask
                                                ,DailyScheduleBatch.DELETE_TASK_CALLLOG
                                                ,'Task'
                                                ,'CRM Admin 2');

        Id BatchDeletetaskCallLog = Database.ExecuteBatch(deleteTaskCallLogBatch);        
        //--End delete task call log ----
        
        
        
        //Send Task_Notification for CXM SCR_2018-0475_CXM_Monitoring
        String content  = Datetime.now().addDays(-1).format('yyyy_MM_dd');
        String filename = 'CXM_Task_Notification'+content;
        List<String> emailOpsList = new List<String>();
        emailOpsList.add('Operation CXM Team');
        ReportExportToEmailUtil.exportFuture('CXM_Task_Notification','Data as of '+content,ReportExportToEmailUtil.EXCEL_TYPE,filename,emailOpsList);
        //Send Task_Notification for CXM SCR_2018-0475_CXM_Monitoring

        
        //Schedule to send report
        List<Schedule_Report_Config__c> scheReportList = [select ID,File_Name__c, Email__c, Report_Unique_Name__c from  Schedule_Report_Config__c];
        if(scheReportList.size() > 0){
            for(Schedule_Report_Config__c shedule: scheReportList){
                String contentReport  = Datetime.now().addDays(-1).format('yyyy_MM_dd');
                String filenameReport = shedule.File_Name__c +contentReport;
                List<String> emailList = new List<String>();
                if(shedule.Email__c.contains(';')){
                    emailList.addAll(shedule.Email__c.split(';'));
                }else{
                     emailList.add(shedule.Email__c);
                }
                try {
                    ReportExportToEmailUtil.exportFuture(shedule.Report_Unique_Name__c
                                        ,'Data as of '+contentReport
                                        ,ReportExportToEmailUtil.CSV_TYPE
                                        ,filenameReport,emailList);
                }catch(Exception e) {
                    system.debug('Error schedule report = '+ e);
                }
            } 
        }
        //End send report schedule

        //For Set expired opportunity
        AppConfig__c cf = AppConfig__c.getValues('On_Demand_Expired_Opportunity');
        String dateToExecuteOnDemand = (cf == null ? '' : cf.Value__c);

        Integer lastModifiedNDays = 21;

        try {
            AppConfig__c cf2 = AppConfig__c.getValues('On_Demand_Expired_Opportunity_N_DAYS');
            lastModifiedNDays = Integer.valueOf(cf2.Value__c);
        }catch(Exception e) {}
        

        if (dateToExecuteOnDemand != null && dateToExecuteOnDemand.length() > 0) {
            List<String> dateToExeLst = dateToExecuteOnDemand.split(';');

            Date curDate = Date.today();

            for (String d: dateToExeLst) {
                Date dToExe = Date.valueOf(d);

                if (curDate == dToExe) {
                    String queryExpiredOpp = 'SELECT Id, Name, Account.TMB_Customer_ID_PE__c, Account.RTL_RM_Name__c '
                                +', RTL_Stage__c, StageName, RTL_Status__c, RecordTypeId '
                                +', RecordType.Name,  Created_Channel__c,  CreatedBy.Name '
                                +', CreatedDate, LastModifiedDate, CampaignId, Campaign.RTL_Campaign_Type__c '
                                +', RTL_Is_Create_from_Campaign_Member__c, Campaign.IsActive '
                                +', RecordType.Developername '
                                +', RTL_Product_Name__r.Active__c '
                                +' FROM Opportunity '
                                +' WHERE ' 
                                +' Created_Channel__c in (\'Branch\',\'\') '
                                +' AND Account.RTL_RM_Name__c = null ' 
                                +' AND RecordType.Name IN (\'Retail Bancassurance\', \'Retail Card and RDC\', \'Retail Deposit\', \'Retail Investment\', \'Retail Loans\', \'Retail Others\')'
                                +' AND (NOT StageName LIKE \'%Closed%\') ';


                    if(Test.isRunningTest()){
                        queryExpiredOpp += ' AND LastModifiedDate = TODAY ';
                    }else {
                        queryExpiredOpp += ' AND LastModifiedDate < LAST_N_DAYS:'+lastModifiedNDays;
                    }

                    
                    DailyScheduleBatch queryExpiredOppBatch = new DailyScheduleBatch(queryExpiredOpp
                                                    ,DailyScheduleBatch.EXPIRED_OPPTY_ON_DEMAND
                                                    ,'Opportunity'
                                                    ,'CRM Admin 2');

                    Id queryExpiredOppBatchId = Database.ExecuteBatch(queryExpiredOppBatch);  
                }
            }
        }
        //For Set expired opportunity

         //---Start Auto Inactive user--
        AppConfig__c cfInUser = AppConfig__c.getValues('Inactive_User_Batch');
        String isInactiveUserBatch = (cfInUser == null ? 'false' : cfInUser.Value__c);

        Boolean isEnable = isInactiveUserBatch.equalsIgnoreCase('true');      
            
        if (isEnable) {
            String queryAutoInactiveUserSQL = 'Select Id,Username,Name,IsActive,LastLoginDate,Employee_ID__c FROM User '
            +' WHERE IsActive = true AND Employee_Id__c != null AND Employee_Id__c NOT IN(\'00000\', \'60001\', \'99998\',\'99999\',\'idacapp\')'
            + 'AND CreatedDate < LAST_N_DAYS:45 AND LastModifiedDate < LAST_N_DAYS:30 '
            +' AND (LastLoginDate = null or LastLoginDate < LAST_N_DAYS:45)';

            /*  
            String queryAutoInactiveUserSQL = 'Select Id,Username,Name,IsActive,LastLoginDate,Employee_ID__c,CreatedDate,LastModifiedDate FROM User '
                                        +' WHERE IsActive = true AND Employee_Id__c != null AND CreatedDate < LAST_N_DAYS:90 AND LastModifiedDate < LAST_N_DAYS:30'
                                        +' AND (LastLoginDate = null or LastLoginDate < LAST_N_DAYS:90)';
            */

            if(Test.isRunningTest()){
                queryAutoInactiveUserSQL += ' LIMIT 200';
            }

            DailyScheduleBatch autoInactiveUserBatch = new DailyScheduleBatch(queryAutoInactiveUserSQL
                                                    ,true
                                                    ,DailyScheduleBatch.AUTO_INACTIVE_USER_BATCH
                                                    ,'User'
                                                    ,'CRM Admin 2'); // CRM Admin 2

            Id autoInactiveUserBatchLog = Database.ExecuteBatch(autoInactiveUserBatch);  
        }

              
        //--End Auto Inactive use ----

        //Expor Report
        
        AppConfig__c cfReportExport = AppConfig__c.getValues('Report_Export');
        Boolean RunExportReport = (cfReportExport == null ? false : true);

        if(RunExportReport){
            List<Migration_Info__c> exportReportLst = [SELECT Id
                                                        ,Name
                                                        ,Migrated_Field__c
                                                        ,Migrated_Field_1__c
                                                        ,Migrated_Field_2__c
                                                        ,ObjectName__c
                                                        ,SQL1__c
                                                        ,SQL2__c
                                                        ,SQL3__c 
                                                        ,Email__c
                                                    FROM  Migration_Info__c 
                                                    Where IsActive__c = true 
                                                    AND Type__c =: DailyScheduleBatch.EXPORT_REPORT
                                                    LIMIT 20];
        
            for (Migration_Info__c exportRecord : exportReportLst) {

                String qryExport = 'SELECT '
                                    +exportRecord.SQL1__c
                                    +(exportRecord.Migrated_Field__c == null ? ' '   :   ','+exportRecord.Migrated_Field__c)
                                    +(exportRecord.Migrated_Field_1__c == null ? ' ' : ','+exportRecord.Migrated_Field_1__c)
                                    +(exportRecord.Migrated_Field_2__c == null ? ' ' : ','+exportRecord.Migrated_Field_2__c)
                                    +' FROM '+exportRecord.ObjectName__c
                                    +' '+(exportRecord.SQL2__c == null ? '' : exportRecord.SQL2__c)+' '
                                    +' '+(exportRecord.SQL3__c == null ? '' : exportRecord.SQL3__c)+' ';
                
                Map<String,String> migratedMapField = new Map<String,String>();

                migratedMapField.put(DailyScheduleBatch.SELECT_FIELDS, 
                                    exportRecord.SQL1__c
                                    +(exportRecord.Migrated_Field__c == null ? ' '   :   ','+exportRecord.Migrated_Field__c)
                                    +(exportRecord.Migrated_Field_1__c == null ? ' ' : ','+exportRecord.Migrated_Field_1__c)
                                    +(exportRecord.Migrated_Field_2__c == null ? ' ' : ','+exportRecord.Migrated_Field_2__c)
                                    );
                migratedMapField.put(DailyScheduleBatch.MIGRATE_NAME,exportRecord.Name);

                List<String> sendToEmailList = new List<String>();
                List<String> emailLst = exportRecord.Email__c.split(';');

                for (String email :  emailLst) {
                    sendToEmailList.add(email);
                }

                DailyScheduleBatch exportReportBatch = new DailyScheduleBatch(qryExport
                                                    ,DailyScheduleBatch.EXPORT_REPORT
                                                    ,exportRecord.ObjectName__c
                                                    ,migratedMapField
                                                    ,sendToEmailList);

                Id exportReportBatchLog = Database.ExecuteBatch(exportReportBatch);
            }   
        }
        //Expor Report

        /* Purger Verification History */
        AppConfig__c cfPurVH = AppConfig__c.getValues('PurgeVerificationHistory');
        String isPurgerVH = (cfPurVH == null ? 'false' : cfPurVH.Value__c);

        Boolean isEnablePurgeVH = isPurgerVH.equalsIgnoreCase('true');  

        if (isEnablePurgeVH) {
            App_Config__mdt PurgeErrorLogsAfter = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeErrorLogsAfter']; 
            String days = PurgeErrorLogsAfter.Value__c;
            String queryPurgerVH = 'select ID from Verification_History__c where LastModifiedDate < LAST_N_DAYS:'+days;
            
           
            DailyScheduleBatch purgerErrorLogBatch = new DailyScheduleBatch(queryPurgerVH
                                                ,DailyScheduleBatch.PURGE_VERIFICATION_HISTORY_BATCH
                                                ,'Verification_History__c'
                                                ,'CRM Admin 2');

            Id purgerErrorLogBatchId = Database.ExecuteBatch(purgerErrorLogBatch);
        }

        //SELECT Id, Expired__c,End_Date__c  from RTL_Do_not_Contact_Info__c where End_Date__c = TODAY AND  Expired__c = false
       
        AppConfig__c cfTaskNoStarted = AppConfig__c.getValues('IS_UPDATE_TASK_NOT_STARTED');
        String iscfTaskNoStarted = (cfTaskNoStarted == null ? 'false' : cfTaskNoStarted.Value__c);

        Boolean isEnableTaskNoStarted = iscfTaskNoStarted.equalsIgnoreCase('true');

        if (isEnableTaskNoStarted) {
            UpdateWealthTaskBatch wealthTaskBatch = new UpdateWealthTaskBatch();

            if(Test.isRunningTest()){
                wealthTaskBatch.UPDATE_TASK_NOT_STARTED += ' LIMIT 200';
            }

            DailyScheduleBatch updateWealthBatch = new DailyScheduleBatch(wealthTaskBatch.SQL_WEALTH_TASK
                                                    ,true
                                                    ,wealthTaskBatch.UPDATE_TASK_NOT_STARTED
                                                    ,'Task'
                                                    ,'CRM Admin 2'
                                                    );

            updateWealthBatch.setDailyBatchAbstract(wealthTaskBatch);

            Id BatchupdateWealthBatch = Database.ExecuteBatch(updateWealthBatch,25);
        }
    }
}