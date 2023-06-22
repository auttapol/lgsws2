public class updateLongtermRepaymentBatch implements Database.Batchable<sObject> {
    final static Boolean RunForcastNIMonthlyBatch {
        get{
            if(RunForcastNIMonthlyBatch == null){
                RunForcastNIMonthlyBatch = false;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Auto_run_NI_monthly_batch');

                if(mc != null && mc.Value__c != null){
                    RunForcastNIMonthlyBatch = mc.Value__c.toLowercase() == 'true';
                }
            }
            return RunForcastNIMonthlyBatch;
        }set;
    }

    final static Integer NIMonthlyBatchSize{
        get{
            if(NIMonthlyBatchSize == null){
                NIMonthlyBatchSize = 1000;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_NI_Monthly_Batch_size');

                if(mc != null && mc.Value__c != null){
                    NIMonthlyBatchSize = Integer.valueOf(mc.Value__c);
                }
            }
            return NIMonthlyBatchSize;
        }set;
    }

    final static Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }
    
	private String query;

    Datetime batchDate = datetime.now();
    Datetime batchEndTime;

    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;

    Map<String, String> mapMFIErrorMsg = new Map<String, String>();
    Map<String, Monthly_Forecast_Input__c> mapKeyErrorMFI = new Map<String, Monthly_Forecast_Input__c>();

    // public updateLongtermRepaymentBatch(String q) {
    //     query = q;
    // }

    public updateLongtermRepaymentBatch() {
        Commercial_Forecast_App_Config__mdt mc = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'Forecast_Long_Term_Batch_Query' LIMIT 1];

        if(mc != null && mc.Value__c != null){
            query = mc.Value__c;
        }else{
            query = 'SELECT Id, OwnerId, Name, Next_Due_Date__c, Repayment_Amount__c, As_of_Date__c, AccountId_Due_Date__c, Account_Suffix_Ref__c FROM Long_Term_Loan_Repayment__c WHERE LastmodifiedDate = TODAY ORDER BY AccountId_Due_Date__c';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(':::::::::::::::start:::::::::::::::');
        batchDate = datetime.now();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Long_Term_Loan_Repayment__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        map<String, Monthly_Forecast_Input__c> mapMFI = new map<String, Monthly_Forecast_Input__c>();

        for(Long_Term_Loan_Repayment__c LTScope : scope){
            Date dueDate = LTScope.Next_Due_Date__c;
            String year = String.valueOf(dueDate.year());
            String month = dueDate.month() < 10 ? '0' + String.valueOf(dueDate.month()) : String.valueOf(dueDate.month());
            Monthly_Forecast_Input__c MFI = new Monthly_Forecast_Input__c();

            MFI.YearMonthAcctSuffRef__c = year + month + LTScope.Account_Suffix_Ref__c;
            MFI.Long_Term_Loan_Repayment__c = LTScope.Id;

            String weekNo = GenerateForecastInputBatchUtil.getWeekNumber(dueDate);
            MFI.put('Repay_Due_Amount_Week' + weekNo + '__c', LTScope.Repayment_Amount__c);

            mapMFI.put(MFI.YearMonthAcctSuffRef__c, MFI);

            System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        }

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        if(mapMFI.size() > 0){
            Database.UpsertResult[] results = Database.upsert(mapMFI.values(), Monthly_Forecast_Input__c.YearMonthAcctSuffRef__c, false);
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    recordsSuccessful++;
                }else{
                    recordsFailed++;
                    String errormsg = '';
                    for(Database.Error err : results[index].getErrors()) {
                        errormsg += err.getStatusCode() + ':' + err.getMessage();
                    }
                    mapMFIErrorMsg.put(mapMFI.values()[index].YearMonthAcctSuffRef__c, errormsg);
                    mapKeyErrorMFI.put(mapMFI.values()[index].YearMonthAcctSuffRef__c, mapMFI.values()[index]);
                }
            }
        }

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
    }

    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');
        batchEndTime = datetime.now();

        String filename = 'Forecast Update Long Term Loan Repayment' + String.Valueof(Datetime.now());
        String sObjectName = 'Monthly_Forecast_Input__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');

        String csvHeaderStr = 'YearMonthAcctSuffRef__c, Long_Term_Loan_Repayment__c, ErrorMessage\n';
        String CSV_BODY = '';

        for (String mfikey : mapMFIErrorMsg.keySet()) {
            CSV_BODY += mapKeyErrorMFI.get(mfikey).YearMonthAcctSuffRef__c 
                        + ',' + mapKeyErrorMFI.get(mfikey).Long_Term_Loan_Repayment__c
                        + ',' + mapMFIErrorMsg.get(mfikey) + '\n';
        }

        if(recordsFailed + recordsSuccessful > 0){
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate, batchDate, batchEndTime, recordsSuccessful, recordsFailed, filename, sobjectName, sendToEmail, CSV_BODY, '', '', csvHeaderStr, '', '', '');
        }

        if(RunForcastNIMonthlyBatch){
            NIMonthlyPerformanceSyncBatch instance = new NIMonthlyPerformanceSyncBatch();

            AsyncQueue__c job = AsyncApexFrameworkUtil.CreateBatchQueue(instance, NIMonthlyBatchSize, 'NIMonthlyPerformanceSyncBatch', null);

            insert job;
        }
    }
}