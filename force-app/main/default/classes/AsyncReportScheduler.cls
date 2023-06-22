global class AsyncReportScheduler implements Schedulable {
        private Integer REPORT_JOB_TIME;
        global AsyncReportScheduler(Integer timeout) {
            this.REPORT_JOB_TIME = timeout;
        }

        global void execute(SchedulableContext sc) { 
               Id jobId = sc.getTriggerId();
               System.abortJob(jobId);

               List<Long_Running_Report__c> runningReportList =  [SELECT Id
                                                                    ,SF_Report_Id__c
                                                                    FROM Long_Running_Report__c
                                                                    WHERE isActive__c = true
                                                                ];

               Boolean reportIsQueue = false;
               List<Id> reportIds = new List<Id>();
               
                for (Long_Running_Report__c runningReport : runningReportList) {
                    String reportId = runningReport.SF_Report_Id__c;
                    try {
                        List<Reports.ReportInstance> reportInstanceList 
                                                            = Reports.ReportManager.getReportInstances(reportId);

                        for (Reports.ReportInstance reportIns : reportInstanceList) {
                            Boolean reportIsRunning = reportIns.getStatus() == 'Running' || reportIns.getStatus() == 'New';
                        
                            if (!reportIsRunning) {
                                reportIds.add(reportIns.getReportId());
                            }else {
                                reportIsQueue = true;
                            }
                        }
                    }catch(Exception e) {
                        System.debug(e);
                    }
                }
              

                if (reportIds != null && reportIds.size() > 0 || Test.isRunningTest()) {
                    notifyLongReport(reportIds);
                }

                if(reportIsQueue || Test.isRunningTest()) {
                    Datetime currenttime = System.now();
                    Datetime nextRuntime = currenttime.addMinutes(this.REPORT_JOB_TIME);

                    String day = string.valueOf(nextRuntime.day());
                    String month = string.valueOf(nextRuntime.month());
                    String hour = string.valueOf(nextRuntime.hour());
                    String minute = string.valueOf(nextRuntime.minute());
                    String second = string.valueOf(nextRuntime.second());
                    String year = string.valueOf(nextRuntime.year());
                    TimeZone tz = UserInfo.getTimeZone();
                    String datetimeStr = nextRuntime.format('dd/MM/yyyy HH:mm:ss', tz.toString());
                    String strJobName = 'Job-AsyncReportScheduler_' + datetimeStr;

                    String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                    
                    if (!Test.isRunningTest())
                        System.schedule(strJobName, strSchedule, new AsyncReportScheduler(this.REPORT_JOB_TIME));
                }
            }
            
            private void notifyLongReport(List<Id> reportIds){
                List<Report> reportList = [SELECT Name FROM Report WHERE Id in : reportIds];

                String appURL = System.URL.getSalesforceBaseUrl().toExternalForm();

                String subject  = 'Your Long-Running Report Ready to review.';
                String htmlBody = 'Your Long-Running Report Ready to review as below <br/>';

                Integer indexReport = 1;
                for (Report report : reportList) {
                    htmlBody += indexReport+'. '+'<a href=\''+appURL+'/apex/asyncReport?reportId='+report.Id+'\'>'+report.Name+'</a><br/>';
                    indexReport++;
                }

                List<String> emailList = new List<String>();
                
                emailList.add(UserInfo.getUserEmail());

                RTL_BatchEmailService.SendEmailByUserIdsAndSingleEmail(subject
                                                                        ,htmlBody
                                                                        ,emailList
                                                                        ,new List<Messaging.Emailfileattachment>()
                                                                        ,false);
            }

           
}