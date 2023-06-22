public class GenerateForecastInputExistFeeBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    final Id RTExistingFee {
        get{
            if(RTExistingFee == null){
                RTExistingFee = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Fee').getRecordTypeId();
            }
            return RTExistingFee;
        }set;
    }

    public static List<Existing_Fee_Mapping__mdt> feeDatas{
        get{
            if(feeDatas == null){
                feeDatas = [SELECT Id, Label, Account_Annualized_Performance_field__c ,Recurring_Flag__c FROM Existing_Fee_Mapping__mdt];
            }
            return feeDatas;
        }set;
    }
    public static List<String> PickListIncomeTypeValuesList{
        get{
            if(PickListIncomeTypeValuesList == null){
                PickListIncomeTypeValuesList = new List<String>();
                List<Schema.PicklistEntry> ple = Monthly_Forecast_Input__c.Income_Type__c.getDescribe().getPicklistValues();
                for(Schema.PicklistEntry pickListVal : Monthly_Forecast_Input__c.Income_Type__c.getDescribe().getPicklistValues()){
                    PickListIncomeTypeValuesList.add(pickListVal.getLabel());
                }
            }
            return PickListIncomeTypeValuesList;
        }set;
    }
    
    private Boolean objectHasProperty(AcctAnnualPerformance__c obj, String propertyName){
        try {
            AcctAnnualPerformance__c temp = new AcctAnnualPerformance__c();
            temp = obj;
            if(temp.get(propertyName) != null){
                return true;
            }
        } catch (Exception e) {
            return false;
        }
        return true;
    }
    
    private String query;
    Datetime batchDate = datetime.now();
    Datetime batchEndTime = null;
    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;
    Map<String, String> errorMFI = new Map<String, String>();
    Map<String, Monthly_Forecast_Input__c> mapErrorMFIKey = new Map<String, Monthly_Forecast_Input__c>();


    public GenerateForecastInputExistFeeBatch() {
        query = 'SELECT Id, AS_FEE__c, AVG_CASA__c, AVG_LOAN_OUT__c, Account__c, BA_FEE__c, CREDIT_FEE__c, DERIVATIVES_FEE__c, DIRECT_CM_FEE__c, EDC_FEE__c, END_CASA__c, ENG_LOAN_OUT__c, External_Key__c, FLEET_FEE__c, FRONT_END_FEE__c, FX_FEE__c, FX_VOLUME__c, Fee__c, IB_FEE__c, LG_FEE__c, MonthYear__c, Month__c, NIIc__c, NIId__c, OTHER_CM_FEE__c, OTHER_FEE__c, TF_FEE__c, TF_VOLUME__c, TMB_CUST_ID__c, Transaction_Date__c, Year__c, Supply_Chain__c, MF_Fee__c, AL_Fee__c FROM AcctAnnualPerformance__c WHERE LastModifiedDate = TODAY';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<AcctAnnualPerformance__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');
        map<String, Monthly_Forecast_Input__c> mapMFI = new map<String, Monthly_Forecast_Input__c>();
        List<Monthly_Forecast_Input__c> listMFI = new List<Monthly_Forecast_Input__c>();
        for(AcctAnnualPerformance__c AAPmapScope : scope){
            for ( Existing_Fee_Mapping__mdt feeData: feeDatas ){  //loop with fee type
                Date asOfDate = AAPmapScope.Transaction_Date__c;
                Integer monthsBetween = Date.today().monthsBetween(asOfDate) != null ? Date.today().monthsBetween(asOfDate) : 0;
                if(objectHasProperty(AAPmapScope , feeData.Account_Annualized_Performance_field__c) && PickListIncomeTypeValuesList.contains(feeData.Label)){
                    if(AAPmapScope.get(feeData.Account_Annualized_Performance_field__c) != null && AAPmapScope.get(feeData.Account_Annualized_Performance_field__c) != '' && AAPmapScope.get(feeData.Account_Annualized_Performance_field__c) != 0){
                        for(Integer i = monthsBetween ; i < 12 ; i++ ){ //loop to generate Monthly_Forecast_Input__c for x month
                            Date genDate = Date.newInstance(Date.Today().year(),Date.Today().month()+1+i,0);
                            if(genDate >= asOfDate){
                                Monthly_Forecast_Input__c existingFee = new Monthly_Forecast_Input__c();
                                existingFee.RecordTypeId = RTExistingFee;
                                existingFee.Customer__c = AAPmapScope.Account__c;
                                existingFee.Income_Type__c = feeData.Label;
                                if(feeData.Recurring_Flag__c){
                                    existingFee.NI__c = Integer.valueOf(AAPmapScope.get(feeData.Account_Annualized_Performance_field__c));
                                }else {
                                    existingFee.NI__c = (genDate.month() == asOfDate.month() && genDate.year() == asOfDate.year()) ? Integer.valueOf(AAPmapScope.get(feeData.Account_Annualized_Performance_field__c)) : 0 ;
                                }
                                existingFee.Year__c = String.valueOf(genDate.year());
                                existingFee.Month__c = genDate.month() < 10 ? '0' + String.valueOf(genDate.month()) : String.valueOf(genDate.Month());
                                String key = existingFee.Customer__c + feeData.Label.replaceAll( '\\s+', '');
                                existingFee.adjustMonthYear__c = Date.newInstance(genDate.year(),genDate.month(),1);
                                existingFee.Account_Suffix_Ref__c = key;
                                existingFee.YearMonthAcctSuffRef__c = existingFee.Year__c + existingFee.Month__c + key;
                                mapMFI.put(existingFee.YearMonthAcctSuffRef__c,existingFee);
                            }
                        }
                    }
                }
            }
        }
        
        if(mapMFI.size() > 0){
            List<Monthly_Forecast_Input__c> MFIRelatedList = new List<Monthly_Forecast_Input__c>();

            // upsert mapMFI.values() YearMonthAcctSuffRef__c;

            Database.UpsertResult[] results = Database.upsert(mapMFI.values(), Monthly_Forecast_Input__c.YearMonthAcctSuffRef__c, false);

            for (Integer i = 0 ; i < results.size() ; i++){
                Database.UpsertResult sr = results.get(i);
                if (sr.isSuccess()) {
                    recordsSuccessful++;
                }else {
                    recordsFailed++;
                    String errormsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errormsg += err.getStatusCode() + ':' + err.getMessage();
                    }
                    errorMFI.put(mapMFI.values()[i].YearMonthAcctSuffRef__c, errormsg);
                    mapErrorMFIKey.put(mapMFI.values()[i].YearMonthAcctSuffRef__c, mapMFI.values()[i]);
                }
            } 

            for(Monthly_Forecast_Input__c MFI : mapMFI.values()){
                if(MFI.Last_Month_Forecast__c == null){
                    date dateKey = MFI.adjustMonthYear__c.addMonths(-1);
                    String key = String.valueOf(dateKey.Year()) + (dateKey.month() < 10 ? '0' + String.valueOf(dateKey.month()) : String.valueOf(dateKey.Month())) + MFI.Account_Suffix_Ref__c;

                    Monthly_Forecast_Input__c lastmonthMFI = new Monthly_Forecast_Input__c(YearMonthAcctSuffRef__c = key); 
                    MFI.Last_Month_Forecast__r = lastmonthMFI;
                    MFIRelatedList.add(MFI);
                }
            }
            if(MFIRelatedList.size() > 0){
                List<Database.SaveResult> srList = Database.update(MFIRelatedList, false);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');
        batchEndTime = datetime.now();
        String filename = 'Generate Forecast Existing Fee';

        String sObjectName = 'Monthly_Forecast_Input__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');
        
        String csvHeaderStr = 'YearMonthAcctSuffRef__c, ErrorMessage\n';
        String SUCCESSLOG_HEAEDER = '';
        String CSV_BODY = '';
        String CSV_LOG_SUCCESS = '';

        for (String mfiKey : errorMFI.keySet()) {
            CSV_BODY += mapErrorMFIKey.get(mfiKey).YearMonthAcctSuffRef__c + ',' + errorMFI.get(mfiKey) + '\n';
        }

        if(recordsFailed + recordsSuccessful > 0){
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate, batchDate, batchEndTime, recordsSuccessful, recordsFailed, filename, sobjectName, sendToEmail, CSV_BODY, '', CSV_LOG_SUCCESS, csvHeaderStr, '', SUCCESSLOG_HEAEDER, '');
        }
    }
}