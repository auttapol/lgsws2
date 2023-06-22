global class CustBaseReportScheduler implements Schedulable{
  /*
        CustBaseReportScheduler sch = new CustBaseReportScheduler();
        sch.executeJob();
        sch.abortJob();
        Change_Owner_Cross_Segment_Pending_Rpt
        Change_Owner_Within_Segment_Pending
        CustBaseReportScheduler sch = new CustBaseReportScheduler('Change_Owner_Cross_Segment_Pending');
        sch.runReport();
       */
   private String REPORT_API_NAME;

   global CustBaseReportScheduler(String reportApiName) {
      this.REPORT_API_NAME = reportApiName;
   }


  global CustBaseReportScheduler() {}

   public void runReport() {
     List<Cust_Base_Report_Scheduler__c> reportScheduleLst = [SELECT ID,Email_List__c
                                ,Report_API_Name__c
                                ,User_Role_List__c
                                ,UserField__c
                                ,NoRecordMessage__c
                                          FROM Cust_Base_Report_Scheduler__c 
                                          Where isActive__c = true 
                                            AND Report_API_Name__c =: this.REPORT_API_NAME LIMIT 1];
              
                
              for (Cust_Base_Report_Scheduler__c custbase : reportScheduleLst) {
              //Send Remaining FX Order Report
                String filename = custbase.Report_API_Name__c;
                List<String> emailOpsList = new List<String>();

                if (custbase.Email_List__c != null && custbase.Email_List__c.length() > 0) {
                    String emailStr = custbase.Email_List__c;
                  List<String> emailList = emailStr.split(';');

                  for (String email:emailList) {
                      emailOpsList.add(email);
                  }
                }

                if (custbase.User_Role_List__c != null && custbase.User_Role_List__c.length() > 0) {
                  String query = 'SELECT Email,UserRole.DeveloperName  FROM User WHERE IsActive = true and UserRoleId in (SELECT Id FROM UserRole where DeveloperName in ('
                                  +custbase.User_Role_List__c+'))';
                                  
                  List<User> userList = Database.query(query);
                  for (User user:userList) {
                      emailOpsList.add(user.Email);
                  }

                  //Notify Role Not found
                  //'MB_CM_Sales_TH_TL','CB_CM_Sales_TH_TL','FI_CM_Sales_TH_TL','BB_SMERetail_CM_Sales_TH_TL','MB_CB_CM_Sales_TH_TL'
                  List<String> roleList = custbase.User_Role_List__c.replaceAll('\'','').split(',');

                  ReportExportToEmailUtil.getRoleNotFoundForReportEmail(roleList,userList,filename);
                  //Notify Role Not found
                }


                String body = 'Please see in the attachment.';

                ReportExportToEmailUtil.exportCSVReportFuture(filename
                                  ,body
                                  ,filename
                                  ,custbase.UserField__c
                                  ,custbase.NoRecordMessage__c
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
                          ,new List<Messaging.Emailfileattachment>()
                          ,'FAIL');
          }
         	
      }

   public void abortJob() {
          List<Cust_Base_Report_Scheduler__c> reportScheduleLst = [SELECT Report_API_Name__c
                                                                      ,CRON_TIME__c
                                                                  FROM Cust_Base_Report_Scheduler__c 
                                                                  Where isActive__c = true LIMIT 20];

          Set<String> reportSet = new Set<String>();

          for (Cust_Base_Report_Scheduler__c custbaseReport: reportScheduleLst) {
              String CRON = custbaseReport.CRON_TIME__c;

              if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                  reportSet.add(custbaseReport.Report_API_Name__c+' '+cronJob);
                }
              }else {
                  reportSet.add(custbaseReport.Report_API_Name__c);
              }
          } 

          List<CronTrigger > cronLst= [SELECT Id,CronJobDetailId 
                              FROM CronTrigger where CronJobDetail.Name 
                                in : reportSet];


          for (CronTrigger  cronjob : cronLst) {
               System.AbortJob(cronjob.Id);
          }
          
       }

   public void executeJob() {
          List<Cust_Base_Report_Scheduler__c> custBaseReportScheduler = [SELECT ID,Email_List__c
                                                ,Report_API_Name__c
                                                ,User_Role_List__c
                                                ,UserField__c
                                                ,NoRecordMessage__c
                                                ,CRON_TIME__c
                                          FROM Cust_Base_Report_Scheduler__c 
                                          Where isActive__c = true LIMIT 20];

          for (Cust_Base_Report_Scheduler__c custBased : custBaseReportScheduler) {
            String CRON = custBased.CRON_TIME__c;
            String REPORT_API_NAME = custBased.Report_API_Name__c;

              if (CRON.contains(';')) {
                List<String> cronLst = CRON.split(';');

                for (String cronJob : cronLst) {
                  System.schedule(REPORT_API_NAME+' '+cronJob
                          , cronJob
                          , new CustBaseReportScheduler(REPORT_API_NAME));
                }
              }else {
                  System.schedule(REPORT_API_NAME
                          , CRON
                          , new CustBaseReportScheduler(REPORT_API_NAME));
              }
          }
       }

}