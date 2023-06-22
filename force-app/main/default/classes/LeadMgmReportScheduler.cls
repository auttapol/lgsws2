global class LeadMgmReportScheduler implements Schedulable{
    /*
        LeadMgmReportScheduler sch = new LeadMgmReportScheduler();
        sch.executeJob();
        sch.abortJob();
        Wealth_MGM_Lead_Tracking_Report_2
        LeadMgmReportScheduler sch = new LeadMgmReportScheduler('Wealth_MGM_Lead_Tracking_Report_2');
        sch.runReport();
       */
    private String REPORT_API_NAME;

    global LeadMgmReportScheduler(String reportApiName) {
        this.REPORT_API_NAME = reportApiName;
    }


    global LeadMgmReportScheduler() {}

    public void runReport() {
        List<Lead_MGM_Report_Scheduler__c> reportScheduleLst = [SELECT ID
                                                                    ,Email_List__c
                                                                    ,Report_API_Name__c
                                                                    ,UserField__c
                                                                    ,User_Role_List__c
                                                                    ,NoRecordMessage__c
                                                                FROM Lead_MGM_Report_Scheduler__c 
                                                                Where isActive__c = true 
                                                                AND Report_API_Name__c =: this.REPORT_API_NAME LIMIT 1];
              
                
            for (Lead_MGM_Report_Scheduler__c leadMgm : reportScheduleLst) {
            //Send Remaining FX Order Report
            String filename = leadMgm.Report_API_Name__c;
            List<String> emailOpsList = new List<String>();

            if (leadMgm.Email_List__c != null && leadMgm.Email_List__c.length() > 0) {
                String emailStr = leadMgm.Email_List__c;
                List<String> emailList = emailStr.split(';');

                for (String email:emailList) {
                    emailOpsList.add(email);
                }
            }

            String body = 'Please see in the attachment.';

            ReportExportToEmailUtil.exportCSVReportFuture(filename
                                ,body
                                ,filename
                                ,leadMgm.UserField__c
                                ,leadMgm.NoRecordMessage__c
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
        List<Lead_MGM_Report_Scheduler__c> reportScheduleLst = [SELECT Report_API_Name__c, CRON_TIME__c
                                                                FROM Lead_MGM_Report_Scheduler__c 
                                                                Where isActive__c = true LIMIT 20];

        Set<String> reportSet = new Set<String>();

        for (Lead_MGM_Report_Scheduler__c leadMgmReport: reportScheduleLst) {
            String CRON = leadMgmReport.CRON_TIME__c;

            if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                    reportSet.add(leadMgmReport.Report_API_Name__c+' '+cronJob);
                }
            }
            else {
                reportSet.add(leadMgmReport.Report_API_Name__c);
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
        List<Lead_MGM_Report_Scheduler__c> leadMgmReportScheduler = [SELECT ID,Email_List__c
                                                                            ,Report_API_Name__c
                                                                            ,User_Role_List__c
                                                                            ,UserField__c
                                                                            ,NoRecordMessage__c
                                                                            ,CRON_TIME__c
                                                                    FROM Lead_MGM_Report_Scheduler__c 
                                                                    Where isActive__c = true LIMIT 20];

        for (Lead_MGM_Report_Scheduler__c leadMgm : leadMgmReportScheduler) {
            String CRON = leadMgm.CRON_TIME__c;
            String REPORT_API_NAME = leadMgm.Report_API_Name__c;

            if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                    System.schedule(REPORT_API_NAME+' ' + cronJob
                                    , cronJob
                                    , new LeadMgmReportScheduler(REPORT_API_NAME));
                }
            }
            else {
                System.schedule(REPORT_API_NAME
                                , CRON
                                , new LeadMgmReportScheduler(REPORT_API_NAME));
            }
        }
    }
}