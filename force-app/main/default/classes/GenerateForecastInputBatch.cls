public class GenerateForecastInputBatch implements Database.Batchable<sObject>, Database.Stateful {
    final Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }

    final static Boolean RunForcastSyncBatch {
        get{
            if(RunForcastSyncBatch == null){
                RunForcastSyncBatch = false;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Auto_run_forcast_sync_batch');

                if(mc != null && mc.Value__c != null){
                    RunForcastSyncBatch = mc.Value__c.toLowercase() == 'true';
                }
            }
            return RunForcastSyncBatch;
        }set;
    }

    final static Integer ForecastSyncBatchSize{
        get{
            if(ForecastSyncBatchSize == null){
                ForecastSyncBatchSize = 1000;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Sync_Batch_size');

                if(mc != null && mc.Value__c != null){
                    ForecastSyncBatchSize = Integer.valueOf(mc.Value__c);
                }
            }
            return ForecastSyncBatchSize;
        }set;
    }

    Datetime batchDate = datetime.now();
    Datetime batchEndTime = null;
    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;
    Map<String, String> errorMFI = new Map<String, String>();
    Map<String, Monthly_Forecast_Input__c> mapErrorMFIKey = new Map<String, Monthly_Forecast_Input__c>();

    private String query;

    private String queryCriteria = '';
    private String prductDomain = '';
    private String prductRemark = '';
    private String customerSegment = '';
    private Boolean needSync = false;
    private Boolean hasSyncRec = false;
    // private Set<String> prductDomainSet;
    // private Set<String> customerSegmentSet;
    
    // public GenerateForecastInputBatch(Set<String> prdDomainSet, Set<String> custSegmentSet, Boolean syncRec) {
    //     prductDomainSet = prdDomainSet;
    //     customerSegmentSet = custSegmentSet;
    //     needSync = syncRec;
    //     hasSyncRec = false;

    //     query = 'SELECT Id, As_of_Date__c, Customer__c, Account_Suffix_Ref__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, Product_Type__c, Loan_Status__c, Limit_Loan__c, Ending_Balance_BE__c, Ending_Balance_Deposit__c, Ending_Balance_Loan__c, Average_Balance_BE__c, Average_Balance_Deposit__c, Average_Balance_Loan__c,Product_Group__c, Gross_Rate__c, Interest_Revenue__c, Product_Code__c, Issue_Date__c, Maturity_Date__c, Origination_Date__c, Account_Status_Desc__c, Liability_O_S__c, Unused_Balance__c,RPN_Type__c, SABS_Type__c, Current_4G__c, Business_Readiness_Level_BRL__c, Product__c, Product__r.Financial_Product_Domain__c, Product__r.Remark__c FROM Product_Volume_Information__c WHERE CreatedDate = TODAY AND Customer__c != null AND Product__c != null AND Customer__r.Segment_crm__c IN :customerSegmentSet AND Product__r.Financial_Product_Domain__c IN :prductDomainSet ORDER BY Customer__c, Product__c';
    // }

    // public GenerateForecastInputBatch(String q, Set<String> prdDomainSet, Set<String> custSegmentSet, Boolean syncRec) {
    //     prductDomainSet = prdDomainSet;
    //     customerSegmentSet = custSegmentSet;
    //     needSync = syncRec;
    //     hasSyncRec = false;

    //     query = q;
    // }

    public GenerateForecastInputBatch(String q, String addOnFilter, String prdDomain, String remark, String custSegment, Boolean syncRec) {
        query = q;

        queryCriteria = addOnFilter;
        prductDomain = prdDomain;
        prductRemark = remark;
        customerSegment = custSegment;

        hasSyncRec = true;

        needSync = syncRec;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        batchDate = datetime.now();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Product_Volume_Information__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        
        Set<String> acctSuffRefset = new Set<String>();
        
        for(Product_Volume_Information__c PVImapScope : scope){
            if(PVImapScope.Account_Suffix_Ref__c != null){
                acctSuffRefset.add(PVImapScope.Account_Suffix_Ref__c);
            }
        }

        System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        
        if(acctSuffRefset.size() > 0){
            Map<String, Monthly_Forecast_Input__c> mapMFIKey = new Map<String, Monthly_Forecast_Input__c>();
            map<String, Monthly_Forecast_Input__c> mapMFI = new map<String, Monthly_Forecast_Input__c>();
            
            for(Monthly_Forecast_Input__c mfi : [SELECT Id, Last_Month_Forecast__c, Limit__c, Maturity_Date__c, Current_Ending_Balance__c, Account_Suffix_Ref__c, YearMonthAcctSuffRef__c FROM Monthly_Forecast_Input__c WHERE RecordTypeId = :RTExistingRepay AND Account_Suffix_Ref__c IN :acctSuffRefset AND adjustMonthYear__c >= LAST_MONTH]){
                mapMFIKey.put(mfi.YearMonthAcctSuffRef__c, mfi);
            }
    
            for(Product_Volume_Information__c PVImapScope : scope){
                Date genDate = Date.newInstance(PVImapScope.As_of_Date__c.year(), PVImapScope.As_of_Date__c.month() + 1, 0);
                while (genDate < Date.today().addMonths(12)) {
                    String genYear = String.valueOf(genDate.year());
                    String genMonth = genDate.month() < 10 ? '0' + String.valueOf(genDate.month()) : String.valueOf(genDate.month());
                    String MFIKey = genYear + genMonth + PVImapScope.Account_Suffix_Ref__c;
    
                    if(mapMFIKey.containsKey(MFIKey)){
                        Monthly_Forecast_Input__c mfi = mapMFIKey.get(MFIKey);
                        Decimal currentEnding = 0;
    
                        if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Deposit'){
                            if(PVImapScope.Ending_Balance_Deposit__c != null && PVImapScope.Ending_Balance_Deposit__c != 0){
                                currentEnding = PVImapScope.Ending_Balance_Deposit__c;
                            }else if(PVImapScope.Ending_Balance_BE__c != null && PVImapScope.Ending_Balance_BE__c != 0){
                                currentEnding = PVImapScope.Ending_Balance_BE__c;
                            }
                        }else if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Credit'){
                            currentEnding = PVImapScope?.Ending_Balance_Loan__c;
                        }
    
                        Boolean cond1 = mfi.Limit__c != PVImapScope.Limit_Loan__c;
                        Boolean cond2 = mfi.Maturity_Date__c != PVImapScope.Maturity_Date__c;
                        Boolean cond3 = mfi.Current_Ending_Balance__c != currentEnding;
    
                        if(cond1 || cond2 || cond3){
                            Monthly_Forecast_Input__c newmfi = GenerateForecastInputBatchUtil.genNewMFI(PVImapScope, genDate);
                            newmfi.Last_Month_Forecast__c = mfi.Last_Month_Forecast__c;
                            mapMFI.put(newmfi.YearMonthAcctSuffRef__c, newmfi);
                        }
                    }else{
                        Monthly_Forecast_Input__c MFI = GenerateForecastInputBatchUtil.genNewMFI(PVImapScope, genDate);

                        date MFIdate = genDate.addMonths(-1);
                        String LastMonthMFIkey = String.valueOf(MFIdate.Year()) + (MFIdate.month() < 10 ? '0' + String.valueOf(MFIdate.month()) : String.valueOf(MFIdate.Month())) + MFI.Account_Suffix_Ref__c;

                        if(mapMFIKey.containsKey(LastMonthMFIkey)){
                            MFI.Last_Month_Forecast__c = mapMFIKey.get(LastMonthMFIkey).Id;
                        }

                        mapMFI.put(MFI.YearMonthAcctSuffRef__c, MFI);
                    }
    
                    genDate = genDate.addMonths(1);
                }

                System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
                System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
            }

            System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
    
            
            if(mapMFI.size() > 0){
                List<Monthly_Forecast_Input__c> MFIRelatedList = new List<Monthly_Forecast_Input__c>();

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
                        MFI.isSkipUpdateCUBE__c = false;
                        MFIRelatedList.add(MFI);
                    }
                }
                if(MFIRelatedList.size() > 0){
                    List<Database.SaveResult> srList = Database.update(MFIRelatedList, false);
                }
                hasSyncRec = true;
            }
            System.debug(limits.getHeapSize() + ' of ' + limits.getLimitHeapSize());
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');
        batchEndTime = datetime.now();

        String customerSegmentStr = '';
        if(customerSegment != null && customerSegment != ''){
            customerSegmentStr = customerSegment;
        }else{
            customerSegmentStr = 'All';
        }
        
        String filename = 'Generate Forecast Input Prduct Domain:' + prductDomain + ', Product Remark:' + prductRemark + ', Customer Segment:' + customerSegmentStr + ', Execute sync:' + (RunForcastSyncBatch && needSync && hasSyncRec);

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

        // if(recordsFailed + recordsSuccessful > 0){
        RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate, batchDate, batchEndTime, recordsSuccessful, recordsFailed, filename, sobjectName, sendToEmail, CSV_BODY, '', CSV_LOG_SUCCESS, csvHeaderStr, '', SUCCESSLOG_HEAEDER, '');
        // }

        if(RunForcastSyncBatch && needSync && hasSyncRec){
            Date syncBatchDate = Date.newInstance(Date.today().addMonths(-1).year(), Date.today().addMonths(-1).month(), 1);

            if(prductDomain != null && prductRemark != null){
                ForecastInputSynchronizationBatch instance = new ForecastInputSynchronizationBatch(syncBatchDate, queryCriteria, prductDomain, prductRemark, customerSegment, true);

                AsyncQueue__c job = AsyncApexFrameworkUtil.CreateBatchQueue(instance, ForecastSyncBatchSize, 'ForecastInputSynchronizationBatch', null);
                
                insert job;
            }
        }
    }
}