global class UserInactiveListReportSchduler implements Schedulable{
    /*
        UserInactiveListReportSchduler sch = new UserInactiveListReportSchduler();
        sch.executeJob();
        sch.abortJob();
        User_Inactive_Tracking_Report
        UserInactiveListReportSchduler sch = new UserInactiveListReportSchduler('User_Inactive_Tracking_Report');
        sch.runReport();
       */
    private String REPORT_API_NAME;

    global UserInactiveListReportSchduler(String reportApiName) {
        this.REPORT_API_NAME = reportApiName;
    }


    global UserInactiveListReportSchduler() {}

    public void runReport() {
        List<Tracking_Report__mdt> reportScheduleLst = [SELECT ID
                                                               ,Email_List__c
                                                               ,Report_API_Name__c
                                                               ,UserField__c
                                                               ,User_Role_List__c
                                                               ,NoRecordMessage__c
                                                               ,EmailBodyMessage__c
                                                        FROM Tracking_Report__mdt 
                                                        Where IsActive__c = true 
                                                        AND Report_API_Name__c =: this.REPORT_API_NAME LIMIT 1];
              
                
            for (Tracking_Report__mdt userInactive : reportScheduleLst) {
                //Send Remaining FX Order Report
                String filename = userInactive.Report_API_Name__c;
                List<String> emailOpsList = new List<String>();

                if (userInactive.Email_List__c != null && userInactive.Email_List__c.length() > 0) {
                    String emailStr = userInactive.Email_List__c;
                    List<String> emailList = emailStr.split(';');

                    for (String email:emailList) {
                        emailOpsList.add(email);
                    }
                }

                String body = userInactive.EmailBodyMessage__c;

                ReportExportToEmailUtil.exportCSVReportFuture(filename
                                    ,body
                                    ,filename
                                    ,userInactive.UserField__c
                                    ,userInactive.NoRecordMessage__c
                                    ,emailOpsList
                                    ,false); //not send to manager so send false as a parameter for isSentToManager
        }
    }


    global void execute(SchedulableContext sc){ 
        try {
            if (this.REPORT_API_NAME != null && this.REPORT_API_NAME.length() > 0) {
                runReport();
            }
        }catch(Exception e) {
                String description = e.getMessage() + ' '+e.getStackTraceString();
                List<String> emailOpsList = new List<String>();

                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.sendSummaryAttachmentEmail(this.REPORT_API_NAME
                                                                , description,emailOpsList
                                                                , new List<Messaging.Emailfileattachment>()
                                                                , 'FAIL');
        }	
    }

    public void abortJob() {
        List<Tracking_Report__mdt> reportScheduleLst = [SELECT Report_API_Name__c, CRON_TIME__c
                                                        FROM Tracking_Report__mdt 
                                                        Where IsActive__c = true LIMIT 20];

        Set<String> reportSet = new Set<String>();

        for (Tracking_Report__mdt userInactive: reportScheduleLst) {
            String CRON = userInactive.CRON_TIME__c;

            if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                    reportSet.add(userInactive.Report_API_Name__c+' '+cronJob);
                }
            }
            else {
                reportSet.add(userInactive.Report_API_Name__c);
            }
        } 

        List<CronTrigger> cronLst= [SELECT Id,CronJobDetailId 
                                    FROM CronTrigger 
                                    Where CronJobDetail.Name in : reportSet];

        for (CronTrigger  cronjob : cronLst) {
            System.AbortJob(cronjob.Id);
        }
          
    }

    public void executeJob() {
        List<Tracking_Report__mdt> userInactiveReportScheduler = [SELECT ID,Email_List__c
                                                                         ,Report_API_Name__c
                                                                         ,User_Role_List__c
                                                                         ,UserField__c
                                                                         ,NoRecordMessage__c
                                                                         ,CRON_TIME__c
                                                                  FROM Tracking_Report__mdt 
                                                                  Where IsActive__c = true LIMIT 20];

        for (Tracking_Report__mdt userInactive : userInactiveReportScheduler) {
            String CRON = userInactive.CRON_TIME__c;
            String REPORT_API_NAME = userInactive.Report_API_Name__c;

            if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                    System.schedule(REPORT_API_NAME+' ' + cronJob
                                    , cronJob
                                    , new UserInactiveListReportSchduler(REPORT_API_NAME));
                }
            }
            else {
                System.schedule(REPORT_API_NAME
                                , CRON
                                , new UserInactiveListReportSchduler(REPORT_API_NAME));
            }
        }
    }
}