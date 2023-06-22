global class EsuitReportScheduler implements Schedulable{
       /*
        EsuitReportScheduler sch = new EsuitReportScheduler();
        sch.executeJob();
        sch.abortJob();
       */
       private String REPORT_API_NAME;

       global EsuitReportScheduler(String reportApiName) {
       		this.REPORT_API_NAME = reportApiName;
       }

       global EsuitReportScheduler() {}


       public void abortJob() {
          List<ESuit_Report_Schedule__c> esuitReportScheduleLst = [SELECT Report_API_Name__c
                                                                      ,CRON_TIME__c
                                                                  FROM ESuit_Report_Schedule__c 
                                                                  Where isActive__c = true LIMIT 20];

          Set<String> reportSet = new Set<String>();

          for (ESuit_Report_Schedule__c esuitReport: esuitReportScheduleLst) {
              String CRON = esuitReport.CRON_TIME__c;

              if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                  reportSet.add(esuitReport.Report_API_Name__c+' '+cronJob);
                }
              }else {
                  reportSet.add(esuitReport.Report_API_Name__c);
              }
          } 

          List<CronTrigger > cronLst= [SELECT Id,CronJobDetailId FROM CronTrigger where CronJobDetail.Name in : reportSet];


          for (CronTrigger  cronjob : cronLst) {
               System.AbortJob(cronjob.Id);
          }
          
       }

       public void executeJob() {
          List<ESuit_Report_Schedule__c> esuitReportScheduleLst = [SELECT ID,Email_List__c
                                ,Report_API_Name__c
                                ,User_Role_List__c
                                ,UserField__c
                                ,NoRecordMessage__c
                                ,CRON_TIME__c
                                          FROM ESuit_Report_Schedule__c 
                                          Where isActive__c = true LIMIT 20];

          for (ESuit_Report_Schedule__c esuitSch : esuitReportScheduleLst) {
            String CRON = esuitSch.CRON_TIME__c;
            String REPORT_API_NAME = esuitSch.Report_API_Name__c;

              if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                  System.schedule(REPORT_API_NAME+' '+cronJob
                          , cronJob
                          , new EsuitReportScheduler(REPORT_API_NAME));
                }
              }else {
                  System.schedule(REPORT_API_NAME
                          , CRON
                          , new EsuitReportScheduler(REPORT_API_NAME));
              }
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
                          ,new List<Messaging.Emailfileattachment>()
                          ,'FAIL');
          }
         	
      }

      public void runReport() {
          List<ESuit_Report_Schedule__c> esuitReportScheduleLst = [SELECT ID,Email_List__c
                                ,Report_API_Name__c
                                ,User_Role_List__c
                                ,UserField__c
                                ,NoRecordMessage__c
                                          FROM ESuit_Report_Schedule__c 
                                          Where isActive__c = true 
                                            AND Report_API_Name__c =: this.REPORT_API_NAME LIMIT 1];
              
                
              for (ESuit_Report_Schedule__c esuit : esuitReportScheduleLst) {
              //Send Remaining FX Order Report
                String filename = esuit.Report_API_Name__c;
                List<String> emailOpsList = new List<String>();

                if (esuit.Email_List__c != null && esuit.Email_List__c.length() > 0) {
                    String emailStr = esuit.Email_List__c;
                  List<String> emailList = emailStr.split(';');

                  for (String email:emailList) {
                      emailOpsList.add(email);
                  }
                }

                if (esuit.User_Role_List__c != null && esuit.User_Role_List__c.length() > 0) {
                  String query = 'SELECT Email,UserRole.DeveloperName  FROM User WHERE IsActive = true and UserRoleId in (SELECT Id FROM UserRole where DeveloperName in ('
                                  +esuit.User_Role_List__c+'))';
                                  
                  List<User> userList = Database.query(query);
                  for (User user:userList) {
                      emailOpsList.add(user.Email);
                  }

                  //Notify Role Not found
                  //'MB_CM_Sales_TH_TL','CB_CM_Sales_TH_TL','FI_CM_Sales_TH_TL','BB_SMERetail_CM_Sales_TH_TL','MB_CB_CM_Sales_TH_TL'
                  List<String> roleList = esuit.User_Role_List__c.replaceAll('\'','').split(',');

                  ReportExportToEmailUtil.getRoleNotFoundForReportEmail(roleList,userList,filename);
                  //Notify Role Not found
                }


                String body = 'Please see in the attachment.';

                ReportExportToEmailUtil.exportCSVReportFuture(filename
                                  ,body
                                  ,filename
                                  ,esuit.UserField__c
                                  ,esuit.NoRecordMessage__c
                                  ,emailOpsList);
            }
      }

}