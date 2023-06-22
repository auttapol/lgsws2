public class ForecastExpireDrawdownBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;


    Datetime batchDate = datetime.now();
    Datetime batchEndTime = null;
    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;
    Map<Id, String> mapMFIErrorMsg = new Map<Id, String>();
    Map<Id, Monthly_Forecast_Input__c> mapIdErrorMFI = new Map<Id, Monthly_Forecast_Input__c>();
    public Date ThisBatchDate;
    
    
    public List<Datetime> batchStartTimeSet = new List<Datetime>();
    public List<Datetime> batchEndTimeSet = new List<Datetime>();
    public List<String> yearSet = new List<String>();
    public List<String> monthSet = new List<String>();
    public List<Integer> recordsSuccessfulSet = new List<Integer>();
    public List<Integer> recordsFailedSet = new List<Integer>();

    final static Id RTDrawdown {
        get{
            if(RTDrawdown == null){
                RTDrawdown = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Drawdown').getRecordTypeId();
            }
            return RTDrawdown;
        }set;
    }
    
    public ForecastExpireDrawdownBatch(Date batDate,List<Datetime> batStartTimeSet , List<Datetime> batEndTimeSet , List<String> batyearSet , List<String> batmonthSet , List<Integer> batrecordsSuccessfulSet , List<Integer> batrecordsFailedSet ,Map<Id, String> tempmapMFIErrorMsg , Map<Id, Monthly_Forecast_Input__c> tempmapIdErrorMFI) {
        mapMFIErrorMsg = tempmapMFIErrorMsg;
        mapIdErrorMFI = tempmapIdErrorMFI;
        ThisBatchDate = batDate;
        String year = String.valueOf(ThisBatchDate.year());
        String month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());
        batchStartTimeSet = batStartTimeSet;
        batchEndTimeSet = batEndTimeSet;
        yearSet = batyearSet;
        monthSet = batmonthSet;
        recordsSuccessfulSet = batrecordsSuccessfulSet;
        recordsFailedSet = batrecordsFailedSet;
        query = 'SELECT Id, Recordtype.Name, Last_Month_Forecast__c, Product__c, Product__r.Name, Customer__c, Customer__r.Name, YearMonthAcctSuffRef__c, Year__c, Month__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, adjustMonthYear__c, Account_Suffix_Ref__c, Ending_Balance__c FROM Monthly_Forecast_Input__c WHERE RecordtypeId = \'' + RTDrawdown + '\' AND adjustMonthYear__c < THIS_MONTH AND YearMonthAcctSuffRef__c LIKE \'' + year + month + '%\'  ORDER BY Account_Suffix_Ref__c, adjustMonthYear__c ';
    }

    public ForecastExpireDrawdownBatch(Date batDate) {
        ThisBatchDate = batDate;
        String year = String.valueOf(ThisBatchDate.year());
        String month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());

        query = 'SELECT Id, Recordtype.Name, Last_Month_Forecast__c, Product__c, Product__r.Name, Customer__c, Customer__r.Name, YearMonthAcctSuffRef__c, Year__c, Month__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, adjustMonthYear__c, Account_Suffix_Ref__c, Ending_Balance__c FROM Monthly_Forecast_Input__c WHERE RecordtypeId = \'' + RTDrawdown + '\' AND adjustMonthYear__c < THIS_MONTH AND YearMonthAcctSuffRef__c LIKE \'' + year + month + '%\'  ORDER BY Account_Suffix_Ref__c, adjustMonthYear__c ';
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Monthly_Forecast_Input__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');
        batchStartTimeSet.add(batchDate);
        for (Monthly_Forecast_Input__c mfi : scope) {
            mfi.Ending_Balance__c = 0;
        }

        Database.SaveResult[] srLst = Database.update(scope, false);
        for (Integer i = 0; i < srLst.size(); i++) {
            Database.SaveResult sr = srLst.get(i);
            if(sr.isSuccess()){
                recordsSuccessful++;
            }else{
                recordsFailed++;
                String errormsg = '';
                for(Database.Error err : sr.getErrors()) {
                    errormsg += err.getStatusCode() + ':' + err.getMessage();
                }
                mapMFIErrorMsg.put(scope.get(i).Id, errormsg);
                mapIdErrorMFI.put(scope.get(i).Id, scope.get(i));
            }
        }
        recordsSuccessfulSet.add(recordsSuccessful);
        recordsFailedSet.add(recordsFailed);
    }

    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');
        batchEndTime = Datetime.now();
        String year = String.valueOf(ThisBatchDate.year());
        String month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());
        monthSet.add(month);
        yearSet.add(year);
        batchEndTimeSet.add(batchEndTime);
        
        if(ThisBatchDate < Date.today().addMonths(12)){
            ForecastExpireDrawdownBatch bat = new ForecastExpireDrawdownBatch(ThisBatchDate.addMonths(1), batchStartTimeSet , batchEndTimeSet , yearSet , monthSet , recordsSuccessfulSet , recordsFailedSet, mapMFIErrorMsg , mapIdErrorMFI);
            Database.ExecuteBatch(bat, 500);
        }else {
            String filename = 'Forecast Expired Drawdown';
            String sObjectName = 'Monthly_Forecast_Input__c';
            List<String> sendToEmail = new List<String>();
            sendToEmail.add('CRM Admin 2');

            String csvHeaderStr = 'Id, YearMonthAcctSuffRef__c, Year__c, Month__c, Recordtype.Name, Product__r.Name, Customer__r.Name, adjustMonthYear__c, ErrorMessage\n';
            String CSV_BODY = '';

            for (Id mfiId : mapMFIErrorMsg.keySet()) {
                CSV_BODY += mapIdErrorMFI.get(mfiId).Id 
                            + ',' + mapIdErrorMFI.get(mfiId).YearMonthAcctSuffRef__c
                            + ',' + mapIdErrorMFI.get(mfiId).Year__c
                            + ',' + mapIdErrorMFI.get(mfiId).Month__c
                            + ',' + mapIdErrorMFI.get(mfiId).Recordtype.Name
                            + ',' + mapIdErrorMFI.get(mfiId).Product__r.Name
                            + ',' + mapIdErrorMFI.get(mfiId).Customer__r.Name
                            + ',' + mapIdErrorMFI.get(mfiId).adjustMonthYear__c
                            + ',' + mapMFIErrorMsg.get(mfiId) + '\n';
            }
            
            if(recordsSuccessfulSet.size() + recordsFailedSet.size() > 0){
                Forecast_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchStartTimeSet, batchStartTimeSet, batchEndTimeSet, recordsSuccessfulSet, recordsFailedSet ,yearSet ,monthSet , filename, sobjectName, sendToEmail, CSV_BODY, '', '', csvHeaderStr, '', '', '');
            }
        }
    }
}