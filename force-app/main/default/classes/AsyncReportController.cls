global with sharing class AsyncReportController {
    private static String SUMMARY_GROUP_1 = 'SUMMARY_GROUP_1';
    private static String MATRIX_GROUP_2 = 'MATRIX_GROUP_2';
    private static String TABLE_COLUMN    = 'TABLE_COLUMN';
    private static String TABLE_TBODY     = 'TABLE_TBODY';
    private static String TABLE_TFOOTER   = 'TABLE_TFOOTER';
    private static String REPORT_INSANCE_ID   = 'REPORT_INSANCE_ID';
    private static String REPORT_STATUS   = 'REPORT_STATUS';
    private static String REPORT_COMPLETED_DATE   = 'REPORT_COMPLETED_DATE';
    private static String REPORT_MESSAGE   = 'REPORT_MESSAGE';
    private static String REPORT_NAME   = 'REPORT_NAME';
    //private static String REPORT_RUNNING = '{!reportname} Report is {!reportStatus} Status. Please wait a moment';
    private static String REPORT_RUNNING = 'รายงาน {!reportname} เป็นรายงานที่ใช้เวลาในการ run นาน ทางระบบจะส่ง email แจ้งเมื่อ report run เรียบร้อย สถานะการ run ตอนนี้ {!reportStatus}';
    public List<SelectOption> availableReports { get; set; }
    public Id reportId { get; set; }

    public AsyncReportController() {
        availableReports = retrieveAvailableReports();
    }
    
    private List<SelectOption> retrieveAvailableReports() {
        List<SelectOption> reptOpts = new List<SelectOption>();
        for (Report r : [
             Select Id, Name
             From Report
             Where Format in ('Summary','Matrix')
             AND FolderName LIKE 'Long Running%'
             Order By Name
        ]) {
            reptOpts.add(new SelectOption(r.Id, r.Name));
        }
        return reptOpts;
    }

    private static Reports.ReportInstance getInfoByInstaceId(String reportId) {
         List<Reports.ReportInstance> reportInstanceList 
                        = Reports.ReportManager.getReportInstances(reportId);

         for (Reports.ReportInstance reportIns : reportInstanceList) {
                Id ownerId = reportIns.getOwnerId();
                Id userId  = UserInfo.getUserId();

                if (ownerId == userId && reportIns.getStatus() == 'Success') return reportIns;
         }

         return null;
    }

    @RemoteAction
    global static Map<String,String> runCompletedAsyncReport(String reportId) {
        Map<String,String> reportMap = new Map<String,String>();

        Reports.ReportInstance reportInstance = getInfoByInstaceId(reportId);

        Report r = [Select Id, Name
                         From Report
                         Where Id =: reportId
                    ];


        if (reportInstance != null) {
             createReportCompleted(reportMap
                              ,r.Name
                              ,reportInstance);

            reportMap.put(REPORT_INSANCE_ID,reportInstance.getId());
            reportMap.put(REPORT_STATUS,reportInstance.getStatus());
        }

        reportMap.put(REPORT_NAME,r.Name);
        return reportMap;
    }
    

    @RemoteAction
    global static Map<String,String> runAsyncReport(String reportId,String reportName,Boolean newLoad) {
        Map<String,String> reportMap = new Map<String,String>();

        Reports.ReportInstance reportInstance = getInfoByInstaceId(reportId);

        if (reportInstance != null && !newLoad) {
            if (reportInstance.getCompletionDate() != null && reportInstance.getOwnerId() == UserInfo.getUserId()) {
                createReportCompleted(reportMap,reportName,reportInstance);
            }
        }else {
            reportInstance = Reports.ReportManager.runAsyncReport(reportId, false);
            reportMap.put(REPORT_MESSAGE,REPORT_RUNNING.replace('{!reportname}',reportName)
                        .replace('{!reportStatus}',reportInstance.getStatus()));

            //add to queue?
            if (isNotificationInQueue()) {
                run();
            }
        }

        reportMap.put(REPORT_INSANCE_ID,reportInstance.getId());
        reportMap.put(REPORT_STATUS,reportInstance.getStatus());
        return reportMap;
    }
    
    @RemoteAction
    global static Map<String,String>
                 getResultsByInstaceId(String instanceId
                                      ,String reportName
                                      ,Boolean isFirstTime) {
        Map<String,String> reportMap = new Map<String,String>();

        Reports.ReportInstance reportInstance = Reports.ReportManager.getReportInstance(instanceId);
        Boolean reportIsRunning = reportInstance.getStatus() == 'Running' 
                                || reportInstance.getStatus() == 'New'
                                || reportInstance.getStatus() == 'Error' ;
                                
        if (!reportIsRunning || Test.isRunningTest()) {
            createReportCompleted(reportMap,reportName,reportInstance);
        }else {
            reportMap.put(REPORT_MESSAGE,REPORT_RUNNING.replace('{!reportname}',reportName)
                        .replace('{!reportStatus}',reportInstance.getStatus()));
        }

        reportMap.put(REPORT_STATUS,reportInstance.getStatus());
        return reportMap;
    }

    private static void createReportCompleted(Map<String,String> reportMap
                                              ,String reportName
                                              ,Reports.ReportInstance reportInstance) {
        List<Long_Running_Report__c> longRunningList = getTableColumList(reportInstance.getReportId());

        if (longRunningList != null && longRunningList.size() > 0 ) {
            Long_Running_Report__c longReport = longRunningList.get(0);
            //String completedTime = reportInstance.getCompletionDate().format('dd-MM-yyyy HH:MM:SS');
            String completedTime =  String.valueOf(reportInstance.getCompletionDate());

            String reportMessage = reportName+' Report Running '
                                       +reportInstance.getStatus()
                                       +' at '
                                       +completedTime;
                                       /*
                                       +'<br/>'
                                       +'Want to reload reprot again? Please click';*/

            reportMap.put(REPORT_MESSAGE,reportMessage);

            if (longReport.Report_Type__c == SUMMARY_GROUP_1 && reportInstance.getStatus() == 'Success') {
                Map<String,String> mapTable =  createSummaryGroup1(longRunningList
                                                ,reportInstance.getReportResults()); 

                reportMap.putAll(mapTable);
            }else if (longReport.Report_Type__c == MATRIX_GROUP_2 && reportInstance.getStatus() == 'Success') {
                Map<String,String> mapTable =  createMatrixGroup1(longRunningList
                                                ,reportInstance.getReportResults()); 

                reportMap.putAll(mapTable);
            }
        }
    }

    private static List<Long_Running_Report__c> getTableColumList(String sfReportId) {
        sfReportId = sfReportId.substring(0,15);
        return [SELECT Id
                    ,Long_Running_Report_Header__c
                    ,Report_Type__c
                    ,SF_Report_Id__c
                FROM Long_Running_Report__c 
                WHERE SF_Report_Id__c =: sfReportId];

    }

    private static Map<String,String> createMatrixGroup1(List<Long_Running_Report__c> longRunningList
                                                          ,Reports.ReportResults reportResults) {
        Map<String,String> htmlMap = new Map<String,String>();

        List<String> colList = new List<String>();

        for (Long_Running_Report__c running : longRunningList) {
            String reportHeader = running.Long_Running_Report_Header__c;

            List<String> reportHeaderList = reportHeader.split(';');
            colList.addAll(reportHeaderList);
        }


        if (reportResults != null) {
             String firstGroupRow = '<tr><th>'+colList.get(0)+'</th>';
             firstGroupRow += '<th></th>';
             String tbody = '';
             String tfooter = '';
             Reports.Dimension dimension                = reportResults.getGroupingsAcross();
             Reports.Dimension dimensionForGroupingDown = reportResults.getGroupingsDown();
             //Reports.ReportExtendedMetadata reportMetadata = reportResults.getReportExtendedMetadata();

             if (dimension != null && dimension.getGroupings() != null) {
                List<Reports.GroupingValue> grpList = dimension.getGroupings();
                
                Map<String,Reports.ReportFact> factMap = reportResults.getFactMap();
                firstGroupRow += '<th></th>';
                for (Reports.GroupingValue grp : grpList) {
                  firstGroupRow += '<th>'+grp.getLabel()+'</th>';
                }

                
                firstGroupRow += '<th>'+colList.get(1)+'</th>';
              
                List<Reports.GroupingValue> grpDownList = dimensionForGroupingDown.getGroupings();
                
                Integer grpRowIndex = 0;
                for (Reports.GroupingValue grpDown : grpDownList) {
                    tbody += '<tr>';
                    tbody += '<td>'+grpDown.getLabel()+'</td>';
                    tbody += '<td>Sum of Num Member อัตราส่วนรายชื่อถูกโทรออก<td>';

                    if (factMap != null && factMap.size() > 0 && grpList.size() > 0) {
                        Integer grpIndex = 0;
                        for (Reports.GroupingValue grpVal : grpList) {
                                Reports.ReportFact fact = factMap.get(grpRowIndex+'!'+grpIndex);
                                if (fact != null) {
                                    tbody += '<td>'+fact.getAggregates().get(0).getLabel()
                                                +'<br/>';

                                    if (fact.getAggregates().get(1).getValue() != null) {
                                        Decimal value = Decimal.valueOf(String.valueOf(fact.getAggregates().get(1).getValue()));
                                        tbody += (value/100* 100).setScale(1)  + '%'
                                                 +'</td>';
                                    }
                                }

                                grpIndex++;
                        }
                    }

                    

                    Reports.ReportFact fact = factMap.get(grpRowIndex+'!T');
                    if (fact != null) {
                        tbody += '<td>'+fact.getAggregates().get(0).getLabel()
                                +'<br/>';
                        Decimal value = Decimal.valueOf(String.valueOf(fact.getAggregates().get(1).getValue()));
                        tbody += (value/100* 100).setScale(1)  + '%'
                                                 +'</td>';
                    }

                    grpRowIndex++;
                    tbody += '</tr>';
                }
                firstGroupRow += '</tr>';

                tfooter = '<tr><th>'+colList.get(1)+'</th>';
                tfooter += '<td>Sum of Num Member อัตราส่วนรายชื่อถูกโทรออก<td>';

                Integer grpIndex = 0;
                for (Reports.GroupingValue grpVal : grpList) {
                    Reports.ReportFact fact = factMap.get('T!'+grpIndex);
                    if (fact != null) {
                        tfooter += '<td>'+fact.getAggregates().get(0).getLabel()
                                                    +'<br/>';

                        if (fact.getAggregates().get(1).getValue() != null) {
                            Decimal value = Decimal.valueOf(String.valueOf(fact.getAggregates().get(1).getValue()));
                            tfooter += (value/100* 100).setScale(1) + '%'
                                                    +'</td>';
                        }
                    }

                    grpIndex++;
                }

                Reports.ReportFact fact = factMap.get('T!T');
                if (fact != null) {
                    tfooter += '<td>'+fact.getAggregates().get(0).getLabel()
                                                    +'<br/>';

                    if (fact.getAggregates().get(1).getValue() != null) {
                        Decimal value = Decimal.valueOf(String.valueOf(fact.getAggregates().get(1).getValue()));
                            tfooter += (value/100* 100).setScale(1)  + '%'
                                                    +'</td>';
                    }
                }
                
                tfooter += '</tr>';
             }


            
            //For Header
            htmlMap.put(TABLE_COLUMN,firstGroupRow);

            //For Body
            htmlMap.put(TABLE_TBODY,tbody);
            //For Footer
            htmlMap.put(TABLE_TFOOTER,tfooter);
        }

        return htmlMap;
    }
    
    private static Boolean isNotificationInQueue() {
        List<AsyncApexJob> asyncJobNotCompleted = [ SELECT ApexClass.Name,ApexClassId ,Status, MethodName, JobType, Id  
                                                    FROM AsyncApexJob 
                                                    WHERE  JobType = 'ScheduledApex' 
                                                            AND ApexClass.Name = 'AsyncReportScheduler'
                                                            AND CreatedById    =: UserInfo.getUserId()
                                                            AND Status not in ('Completed','Aborted','Failed') LIMIT 1];

        if (asyncJobNotCompleted != null && asyncJobNotCompleted.size() > 0) return false;
        return true;
    }

    private static Map<String,String> createSummaryGroup1(List<Long_Running_Report__c> longRunningList
                                                          ,Reports.ReportResults reportResults) {

        Map<String,String> htmlMap = new Map<String,String>();

        List<String> colList = new List<String>();

        for (Long_Running_Report__c running : longRunningList) {
            String reportHeader = running.Long_Running_Report_Header__c;

            List<String> reportHeaderList = reportHeader.split(';');
            colList.addAll(reportHeaderList);
        }


        String column = '<tr>';
        for (String col: colList) {
            if (col.endsWithIgnoreCase('null')) {
                column += '<th></th>';
            }else {
                column += '<th>'+col+'</th>';
            }   
            
        }
        column += '</tr>';
        //For Header
        htmlMap.put(TABLE_COLUMN,column);

        if (reportResults != null) {
            Reports.Dimension dimension = reportResults.getGroupingsDown();
            System.debug(dimension);

            if (dimension != null && dimension.getGroupings() != null) {
                List<Reports.GroupingValue> grpList = dimension.getGroupings();
                
                Map<String,Reports.ReportFact> factMap = reportResults.getFactMap();

                if (factMap != null && factMap.size() > 0 && grpList.size() > 0) {
                    String tbody   = '';
                    System.debug(factMap);
                    Integer grpIndex = 0;
                    for (Reports.GroupingValue grpVal : grpList) {
                            Reports.ReportFact fact = factMap.get(grpIndex +'!T');
                            tbody += '<tr>';
                            tbody += '<td>'+grpVal.getLabel()+'</td>';
                            
                            for (Integer i = 0;i<colList.size()-1;i++) {
                               tbody += '<td>'+fact.getAggregates().get(i).getLabel()+'</td>';
                            }

                            tbody += '</tr>';
                            grpIndex++;
                    }
                    
                    
                    String tfooter = '<tr>';
                    
                    Reports.ReportFact totalFact = factMap.get('T!T');
                    for (Integer i = 0;i<colList.size()-1;i++) {
                        if (i == 0) {
                             tfooter += '<td>Grand Totals ('+totalFact .getAggregates().get(i).getLabel()+' records)</td>';
                        }
                        tfooter += '<td>'+totalFact.getAggregates().get(i).getLabel()+'</td>';
                   }
                                    
                    tfooter += '</tr>';
                    //For Body
                    htmlMap.put(TABLE_TBODY,tbody);
                    //For Footer
                    //htmlMap.put(TABLE_TFOOTER,column);
                    htmlMap.put(TABLE_TFOOTER,tfooter);
                }
            }
        }

        return htmlMap;
    }
    
    private static void run() {
        Integer LONGRUNNING_REPORT_TIME;
        try {
            AppConfig__c cf = AppConfig__c.getValues('Long_Running_Report_Time');
            LONGRUNNING_REPORT_TIME = (cf == null ? 10 : Integer.valueOf(cf.Value__c));
        }catch(Exception e) {
            LONGRUNNING_REPORT_TIME = 10;
        }
        Datetime currenttime = System.now();
        Datetime nextRuntime = currenttime.addMinutes(LONGRUNNING_REPORT_TIME);

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
        System.schedule(strJobName, strSchedule, new AsyncReportScheduler(LONGRUNNING_REPORT_TIME));
    }
}