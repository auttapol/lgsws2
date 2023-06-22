public class NIMonthlyPerformanceSyncBatch implements Database.Batchable<sObject>{
    final static Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }

    final static Boolean RunGenerateMFIbatch {
        get{
            if(RunGenerateMFIbatch == null){
                RunGenerateMFIbatch = false;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Auto_run_Generate_MFI_batch');

                if(mc != null && mc.Value__c != null){
                    RunGenerateMFIbatch = mc.Value__c.toLowercase() == 'true';
                }
            }
            return RunGenerateMFIbatch;
        }set;
    }

    private String query;

    Datetime batchDate = datetime.now();
    Datetime batchEndTime;

    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;

    Map<String, String> mapMFIErrorMsg = new Map<String, String>();
    Map<String, Monthly_Forecast_Input__c> mapKeyErrorMFI = new Map<String, Monthly_Forecast_Input__c>();

    // public NIMonthlyPerformanceSyncBatch(String q) {
    //     query = q;
    // }

    public NIMonthlyPerformanceSyncBatch() {
        Commercial_Forecast_App_Config__mdt mc = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'Forecast_NI_Monthly_Batch_query' LIMIT 1];

        if(mc != null && mc.Value__c != null){
            query = mc.Value__c;
        }else{
            query = 'SELECT Id, As_of_Date__c, YearMonthAcctSuffRef__c, Average_Balance__c, Average_Balance_YTD__c, NIIc__c, NIId__c, Fund_Transfer__c, Interest_Revenue__c, Product_Code__c, Product_Key__c, Product_Group__c, Loan_Status__c, NIId_DPA__c, DPA__c,  Unused_Balance__c, Gross_Rate_Deposit__c, Gross_Rate_Loan__c, SABS_Type__c, Origination_Date__c, TMB_Hold_Commitment__c, Product__c, Product__r.Financial_Product_Domain__c, Ending_Balance__c, Customer__c, Account_Suffix_Ref__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, Issue_Date__c, Product_Type__c, Limit_Loan__c, Maturity_Date__c, Product__r.Remark__c FROM NI_Monthly_Performance__c WHERE CreatedDate = TODAY AND isUpdateToMFISuccess__c = false ORDER BY Customer__c, Product__c';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        batchDate = datetime.now();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<NI_Monthly_Performance__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        List<Monthly_Forecast_Input__c> MFIupdateLst = new List<Monthly_Forecast_Input__c>();
        Map<String, NI_Monthly_Performance__c> mapKeyNIMonthly = new Map<String, NI_Monthly_Performance__c>();
        
        for(NI_Monthly_Performance__c Mperf : scope){
            mapKeyNIMonthly.put(Mperf.YearMonthAcctSuffRef__c, Mperf);
            Integer daysMonth = Date.daysInMonth(Mperf.As_of_Date__c != null ? Mperf.As_of_Date__c.year() : Date.today().year(), Mperf.As_of_Date__c != null ? Mperf.As_of_Date__c.month() : Date.today().month());
            Integer daysYear = Date.isLeapYear(Mperf.As_of_Date__c != null ? Mperf.As_of_Date__c.year() : Date.today().year()) ? 366 : 365;
            Decimal NI = 0;

            String recMonth = Mperf.As_of_Date__c.month() < 10 ? '0' + String.valueOf(Mperf.As_of_Date__c.month()) : String.valueOf(Mperf.As_of_Date__c.month());
            String recYear = String.valueOf(Mperf.As_of_Date__c.year());

            Monthly_Forecast_Input__c MFI = new Monthly_Forecast_Input__c();

            MFI.YearMonthAcctSuffRef__c = Mperf.YearMonthAcctSuffRef__c;

            String combkey = recYear + recMonth + Mperf.Product__r.Financial_Product_Domain__c + Mperf.Product__r.Remark__c + Mperf.Account_Suffix_Ref__c;
            MFI.Name = combkey.replaceAll( '\\s+', '');

            if(Mperf.Gross_Rate_Deposit__c != null && Mperf.Gross_Rate_Deposit__c != 0){
                MFI.Gross_Rate__c = Mperf.Gross_Rate_Loan__c == null ? Mperf.Gross_Rate_Deposit__c : Mperf.Gross_Rate_Loan__c > Mperf.Gross_Rate_Deposit__c ? Mperf.Gross_Rate_Loan__c : Mperf.Gross_Rate_Deposit__c;
            }else if(Mperf.Gross_Rate_Loan__c != null && Mperf.Gross_Rate_Loan__c != 0){
                MFI.Gross_Rate__c = Mperf.Gross_Rate_Loan__c;
            }

            MFI.Average_Balance_YTD__c = Mperf.Average_Balance_YTD__c;
            MFI.NIIc__c = Mperf.NIIc__c;
            MFI.NIId__c = Mperf.NIId_DPA__c;
            
            if(Mperf.Product__r?.Financial_Product_Domain__c == 'Deposit'){
                NI = Mperf.NIId_DPA__c;
            }else if(Mperf.Product__r?.Financial_Product_Domain__c == 'Credit'){
                NI = Mperf.NIIc__c;
            }
            
            MFI.Average_Balance__c = Mperf.Average_Balance__c;
            MFI.Actual_NIM__c = Mperf.Average_Balance__c == 0 ? Mperf.Average_Balance__c : (NI * daysYear) / (Mperf.Average_Balance__c * daysMonth) * 100;
            MFI.Interest_Income__c = Mperf.Interest_Revenue__c;
            MFI.FTP__c = Mperf.Fund_Transfer__c;
            MFI.Loan_Status__c = Mperf.Loan_Status__c;
            MFI.Product_Group__c = Mperf.Product_Group__c;
            MFI.Product_Code__c = Mperf.Product_Code__c;
            MFI.Origination_Date__c = Mperf.Origination_Date__c;
            MFI.Unused_Balance__c = Mperf.Unused_Balance__c;
            MFI.SABS__c = Mperf.SABS_Type__c;
            MFI.Product_Key__c = Mperf.Product_Key__c;
            MFI.DPA__c = Mperf.DPA__c;
            MFI.Hold_Commitment__c = Mperf.TMB_Hold_Commitment__c;
            MFI.NI_Monthly_Performance__c = Mperf.Id;
            
            MFI.Current_Ending_Balance__c = Mperf.Ending_Balance__c;

            MFI.RecordTypeId = RTExistingRepay;
            MFI.Account_Suffix_Ref__c = Mperf.Account_Suffix_Ref__c;
            MFI.Customer__c = Mperf.Customer__c;
            MFI.Product__c = Mperf.Product__c;
            MFI.Year__c = recYear;
            MFI.Month__c = recMonth;
            MFI.adjustMonthYear__c = Date.newInstance(Mperf.As_of_Date__c.year(), Mperf.As_of_Date__c.month(), 1);
            MFI.TMB_Account_ID__c = Mperf.TMB_Account_ID__c;
            MFI.TMB_Suffix__c = Mperf.TMB_Suffix__c;
            MFI.TMB_Ref__c = Mperf.TMB_Ref__c;
            MFI.Issue_Date__c = Mperf.Issue_Date__c;
            MFI.Product_Type__c = Mperf.Product_Type__c;
            MFI.Limit__c = Mperf.Limit_Loan__c;
            MFI.Maturity_Date__c = Mperf.Maturity_Date__c;

            MFIupdateLst.add(MFI);

            System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        }

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        if(MFIupdateLst.size() > 0){
            Database.UpsertResult[] results = Database.upsert(MFIupdateLst, Monthly_Forecast_Input__c.YearMonthAcctSuffRef__c, false);

            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    recordsSuccessful++;
                    mapKeyNIMonthly.get(MFIupdateLst[index].YearMonthAcctSuffRef__c).isUpdateToMFISuccess__c = true;
                }else{
                    recordsFailed++;

                    String errormsg = '';

                    for(Database.Error err : results[index].getErrors()) {
                        errormsg += err.getStatusCode() + ':' + err.getMessage();
                    }

                    mapMFIErrorMsg.put(MFIupdateLst[index].YearMonthAcctSuffRef__c, errormsg);
                    mapKeyErrorMFI.put(MFIupdateLst[index].YearMonthAcctSuffRef__c, MFIupdateLst[index]);
                }
            }
        }

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        if(mapKeyNIMonthly.size() > 0) update mapKeyNIMonthly.values();

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
    }

    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');
        batchEndTime = Datetime.now();

        String filename = 'Forecast NI Monthly Performance_'+ String.Valueof(Datetime.now());
        String sObjectName = 'Monthly_Forecast_Input__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');

        String csvHeaderStr = 'YearMonthAcctSuffRef__c, NI_Monthly_Performance__c, ErrorMessage\n';
        String CSV_BODY = '';

        for (String mfiId : mapMFIErrorMsg.keySet()) {
            CSV_BODY += mapKeyErrorMFI.get(mfiId).YearMonthAcctSuffRef__c 
                        + ',' + mapKeyErrorMFI.get(mfiId).NI_Monthly_Performance__c
                        + ',' + mapMFIErrorMsg.get(mfiId) + '\n';
        }

        if(recordsFailed + recordsSuccessful > 0){
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate, batchDate, batchEndTime, recordsSuccessful, recordsFailed, filename, sobjectName, sendToEmail, CSV_BODY, '', '', csvHeaderStr, '', '', '');
        }


        if(RunGenerateMFIbatch){
            List<AsyncQueue__c> jobList = new List<AsyncQueue__c>();
            for(Generate_Forecast_Input_Batch_Manager__mdt eachGenerateForecast : [SELECT Id, Main_Query__c, Additional_Criteria__c, Order_By_Query__c, Product_Domain__c, Product_Remark__c, Requied_Sync__c, Batch_size__c,Priority__c,Customer_Segment__c FROM Generate_Forecast_Input_Batch_Manager__mdt]){

                String mainQuery = eachGenerateForecast.Main_Query__c != null ? eachGenerateForecast.Main_Query__c : ' ';
                String addOnFilter = eachGenerateForecast.Additional_Criteria__c != null ? eachGenerateForecast.Additional_Criteria__c : ' ';
                String orderByQuery = eachGenerateForecast.Order_By_Query__c != null ? eachGenerateForecast.Order_By_Query__c : ' ';
                String customerSegment = eachGenerateForecast.Customer_Segment__c != null ? eachGenerateForecast.Customer_Segment__c : '';
                
                String queryGenerate = mainQuery + ' '  + addOnFilter + ' ' + orderByQuery;

                String prodDomain = eachGenerateForecast.Product_Domain__c;
                String prodRemark = eachGenerateForecast.Product_Remark__c;
                Boolean runSync = eachGenerateForecast.Requied_Sync__c;

                Integer batchSize = Integer.valueOf(eachGenerateForecast.Batch_size__c);
                Integer priority = Integer.valueOf(eachGenerateForecast.Priority__c);


                GenerateForecastInputBatch instance = new GenerateForecastInputBatch(queryGenerate, addOnFilter, prodDomain, prodRemark, customerSegment, runSync);

                AsyncQueue__c job = AsyncApexFrameworkUtil.CreateBatchQueue(instance, batchSize, 'GenerateForecastInputBatch', priority);

                jobList.add(job);
            }
            insert jobList;

        }
    }
}