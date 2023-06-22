public class ForecastInputSynchronizationBatch implements Database.Batchable<sObject>, Database.Stateful {
    final Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }
    
    final static Id RTDrawdown {
        get{
            if(RTDrawdown == null){
                RTDrawdown = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Drawdown').getRecordTypeId();
            }
            return RTDrawdown;
        }set;
    }

    public Map<String, NIM_Port__c> mapNIMport {
        get{
            if(mapNIMport == null){
                mapNIMport = new Map<String, NIM_Port__c> ();
                for (NIM_Port__c nimp : [SELECT Id, Segment__c, NIMc__c, NIMd__c FROM NIM_Port__c]) {
                    mapNIMport.put(nimp.Segment__c, nimp);
                }
            }
            return mapNIMport;
        }set;
    }

    public String query;

    public String mainQuery{
        get{
            if(mainQuery == null){
                Commercial_Forecast_App_Config__mdt mainQueryObj = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'Forecast_Input_Sync_Batch_Main_Query' LIMIT 1];

                if(mainQueryObj != null && mainQueryObj.Value__c != null){
                    mainQuery = mainQueryObj.Value__c;
                }else{
                    mainQuery = 'SELECT Id, Year__c, Month__c, RecordtypeId, Recordtype.Name, adjustMonthYear__c, YearMonthAcctSuffRef__c, Account_Suffix_Ref__c, Current_Ending_Balance__c, F_Projected_Balance__c, Last_Month_Ending_Balance__c, Ending_Balance__c, Repay_Due_Amount_Week1__c, Repay_Due_Amount_Week2__c, Repay_Due_Amount_Week3__c, Repay_Due_Amount_Week4__c, Repay_Due_Amount_Week5__c, Repay_Due_Amount_Week6__c, Total_Repay_Due_Amount__c, Hold_Commitment__c, FTP__c, Interest_Income__c, Last_Month_Forecast__c, Actual_NIM__c, Forecast_NIM__c, Last_Month_Forecast__r.Actual_NIM__c, Last_Month_Forecast__r.Forecast_NIM__c, Last_Month_Forecast__r.Hold_Commitment__c, Last_Month_Forecast__r.FTP__c, Last_Month_Forecast__r.Interest_Income__c, Product__r.Financial_Product_Domain__c, Customer__r.Owner.Segment__c, NI_Monthly_Performance__c FROM Monthly_Forecast_Input__c WHERE LastmodifiedDate = TODAY AND RecordtypeId =: RTExistingRepay ';
                }
            }
            return mainQuery;
        }set;
    }

    public String orderByQuery {
        get{
            if(orderByQuery == null){
                Commercial_Forecast_App_Config__mdt orderByQueryObj = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'Forecast_Input_Sync_Batch_Order_By_Query' LIMIT 1];

                if(orderByQueryObj != null && orderByQueryObj.Value__c != null){
                    orderByQuery = orderByQueryObj.Value__c;
                }else{
                    orderByQuery = ' ORDER BY Customer__c, Product__c';
                }
            }
            return orderByQuery;
        }set;
    }

    public String addOnQuery = '';

    public String queryFields = 'Id, Year__c, Month__c, RecordtypeId, Recordtype.Name, adjustMonthYear__c, YearMonthAcctSuffRef__c, Account_Suffix_Ref__c, Current_Ending_Balance__c, F_Projected_Balance__c, Last_Month_Ending_Balance__c, Ending_Balance__c, Repay_Due_Amount_Week1__c, Repay_Due_Amount_Week2__c, Repay_Due_Amount_Week3__c, Repay_Due_Amount_Week4__c, Repay_Due_Amount_Week5__c, Repay_Due_Amount_Week6__c, Total_Repay_Due_Amount__c, Hold_Commitment__c, FTP__c, Interest_Income__c, Last_Month_Forecast__c, Actual_NIM__c, Forecast_NIM__c, Last_Month_Forecast__r.Actual_NIM__c, Last_Month_Forecast__r.Forecast_NIM__c, Last_Month_Forecast__r.Hold_Commitment__c, Last_Month_Forecast__r.FTP__c, Last_Month_Forecast__r.Interest_Income__c, Product__r.Financial_Product_Domain__c, Customer__r.Owner.Segment__c, NI_Monthly_Performance__c FROM Monthly_Forecast_Input__c';

    public Date ThisBatchDate;

    public Date currentMonth = Date.newInstance(Date.today().year(), Date.today().month(), 1);
    
    public String year;
    public String month;
    public Integer daysMonth;
    public Integer daysYear;

    public String prodDomainStr;
    public String prodRemarkStr;
    private String customerSegment;
    
    public Boolean isSpecificAcctSuffRef = false;
    public Set<String> SpecificAcctSuffRefSet;

    private Boolean goNext = true;

    Datetime batchDate = datetime.now();
    Datetime batchEndTime;
    Integer  recordsSuccessful = 0;
    Integer  recordsFailed = 0;
    
    public List<Datetime> batchStartTimeSet = new List<Datetime>();
    public List<Datetime> batchEndTimeSet = new List<Datetime>();
    public List<String> yearSet = new List<String>();
    public List<String> monthSet = new List<String>();
    public List<Integer> recordsSuccessfulSet = new List<Integer>();
    public List<Integer> recordsFailedSet = new List<Integer>();
    Map<Id, String> mapMFIErrorMsg = new Map<Id, String>();
    Map<Id, Monthly_Forecast_Input__c> mapIdErrorMFI = new Map<Id, Monthly_Forecast_Input__c>();

    public ForecastInputSynchronizationBatch(Date batDate) {
        ThisBatchDate = batDate;

        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());

        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        query = mainQuery + ' AND Name LIKE \'' + year + month + '%\' ' + orderByQuery;
    }

    public ForecastInputSynchronizationBatch(Date batDate, List<Datetime> batStartTimeSet, List<Datetime> batEndTimeSet, List<String> batYearSet, List<String> batMonthSet, List<Integer> batRecordsSuccessfulSet, List<Integer> batRecordsFailedSet, Map<Id, String> tempmapMFIErrorMsg, Map<Id, Monthly_Forecast_Input__c> tempmapIdErrorMFI) {
        ThisBatchDate = batDate;

        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());

        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        batchStartTimeSet = batStartTimeSet;
        batchEndTimeSet = batEndTimeSet;
        yearSet = batYearSet;
        monthSet = batMonthSet;
        recordsSuccessfulSet = batRecordsSuccessfulSet;
        recordsFailedSet = batRecordsFailedSet;
        mapMFIErrorMsg = tempmapMFIErrorMsg;
        mapIdErrorMFI = tempmapIdErrorMFI;

        query = mainQuery + ' AND Name LIKE \'' + year + month + '%\' ' + orderByQuery;
    }

    public ForecastInputSynchronizationBatch(Date batDate, Set<String> AcctSuffRefSet) {
        ThisBatchDate = batDate;

        isSpecificAcctSuffRef = true;
        SpecificAcctSuffRefSet = AcctSuffRefSet;

        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());
        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        query = 'SELECT ' + queryFields + ' WHERE Name LIKE \'' + year + month + '%\' AND Account_Suffix_Ref__c IN :SpecificAcctSuffRefSet';
    }

    public ForecastInputSynchronizationBatch(Date batDate, set<String> AcctSuffRefSet, List<Datetime> batStartTimeSet, List<Datetime> batEndTimeSet, List<String> batYearSet, List<String> batMonthSet, List<Integer> batRecordsSuccessfulSet, List<Integer> batRecordsFailedSet, Map<Id, String> tempmapMFIErrorMsg, Map<Id, Monthly_Forecast_Input__c> tempmapIdErrorMFI) {
        ThisBatchDate = batDate;

        isSpecificAcctSuffRef = true;
        SpecificAcctSuffRefSet = AcctSuffRefSet;

        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());
        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        batchStartTimeSet = batStartTimeSet;
        batchEndTimeSet = batEndTimeSet;
        yearSet = batYearSet;
        monthSet = batMonthSet;
        recordsSuccessfulSet = batRecordsSuccessfulSet;
        recordsFailedSet = batRecordsFailedSet;
        mapMFIErrorMsg = tempmapMFIErrorMsg;
        mapIdErrorMFI = tempmapIdErrorMFI;

        query = 'SELECT ' + queryFields + ' WHERE Name LIKE \'' + year + month + '%\' AND Account_Suffix_Ref__c IN :SpecificAcctSuffRefSet';
    }

    public ForecastInputSynchronizationBatch(Date batDate, String addOnCriteria, String prodDomain, String prodRemark, String custSegment, Boolean gonext) {
        ThisBatchDate = batDate;
        
        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());

        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        goNext = gonext;

        addOnQuery = addOnCriteria;

        prodDomainStr = prodDomain;
        prodRemarkStr = prodRemark;
        customerSegment = custSegment;

        String nameKey = year + month + prodDomainStr + prodRemarkStr.replaceAll( '\\s+', '') + customerSegment;

        query = mainQuery + ' AND Name LIKE \'' + nameKey + '%\' ' + addOnQuery + orderByQuery;
    }

    public ForecastInputSynchronizationBatch(Date batDate, String addOnCriteria, String prodDomain, String prodRemark, String custSegment, Boolean gonext, List<Datetime> batStartTimeSet, List<Datetime> batEndTimeSet, List<String> batYearSet, List<String> batMonthSet, List<Integer> batRecordsSuccessfulSet, List<Integer> batRecordsFailedSet, Map<Id, String> tempmapMFIErrorMsg, Map<Id, Monthly_Forecast_Input__c> tempmapIdErrorMFI) {
        ThisBatchDate = batDate;

        year = String.valueOf(ThisBatchDate.year());
        month = ThisBatchDate.month() < 10 ? '0' + String.valueOf(ThisBatchDate.month()) : String.valueOf(ThisBatchDate.month());

        daysMonth = Date.daysInMonth(ThisBatchDate.year(), ThisBatchDate.month());
        daysYear = Date.isLeapYear(ThisBatchDate.year()) ? 366 : 365;

        goNext = gonext;
        
        addOnQuery = addOnCriteria;

        prodDomainStr = prodDomain;
        prodRemarkStr = prodRemark;
        customerSegment = custSegment;

        batchStartTimeSet = batStartTimeSet;
        batchEndTimeSet = batEndTimeSet;
        yearSet = batYearSet;
        monthSet = batMonthSet;
        recordsSuccessfulSet = batRecordsSuccessfulSet;
        recordsFailedSet = batRecordsFailedSet;
        mapMFIErrorMsg = tempmapMFIErrorMsg;
        mapIdErrorMFI = tempmapIdErrorMFI;

        String nameKey = year + month + prodDomainStr + prodRemarkStr.replaceAll( '\\s+', '') + customerSegment;

        query = mainQuery + ' AND Name LIKE \'' + nameKey + '%\' ' + addOnQuery + orderByQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        System.debug('ThisBatchDate:: ' + ThisBatchDate);
        batchDate = datetime.now();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Monthly_Forecast_Input__c> scope){
        System.debug(':::::::::::::::execute:::::::::::::::');

        List<Monthly_Forecast_Input__c> updateSet = new List<Monthly_Forecast_Input__c>();

        for(Monthly_Forecast_Input__c forecastInput : scope){
            if((forecastInput.Total_Repay_Due_Amount__c > forecastInput.Last_Month_Ending_Balance__c && forecastInput.Last_Month_Forecast__c != null) || (forecastInput.Total_Repay_Due_Amount__c > forecastInput.Current_Ending_Balance__c && forecastInput.Last_Month_Forecast__c == null)){
                Decimal tmpRepay = forecastInput.Total_Repay_Due_Amount__c;
                Decimal diffRepay = forecastInput.Total_Repay_Due_Amount__c - forecastInput.Last_Month_Ending_Balance__c;
                for (Integer i = 1 ; i <= 6 ; i++){

                    if(tmpRepay <= forecastInput.Last_Month_Ending_Balance__c) break;

                    Decimal repayW = forecastInput.get('Repay_Due_Amount_Week' + i + '__c') == null ? 0 : Decimal.valueOf(String.valueOf(forecastInput.get('Repay_Due_Amount_Week' + i + '__c')));
                    if(repayW > diffRepay){
                        tmpRepay -= diffRepay;
                        forecastInput.put('Repay_Due_Amount_Week' + i + '__c', repayW - diffRepay);
                    }else{
                        tmpRepay -= repayW;
                        forecastInput.put('Repay_Due_Amount_Week' + i + '__c', 0);
                    }
                }
            }

            Decimal totalrepayment = 0;

            for (Integer i = 1 ; i <= 6 ; i++){
                totalrepayment += forecastInput.get('Repay_Due_Amount_Week' + i + '__c') == null ? 0 : Decimal.valueOf(String.valueOf(forecastInput.get('Repay_Due_Amount_Week' + i + '__c')));
            }

            if(forecastInput.adjustMonthYear__c >= currentMonth && forecastInput.recordtypeId == RTExistingRepay){
                if(forecastInput.Last_Month_Forecast__c != null){
                    forecastInput.Ending_Balance__c = forecastInput.Last_Month_Ending_Balance__c - totalrepayment;
                }else{
                    forecastInput.Ending_Balance__c = forecastInput.Current_Ending_Balance__c - totalrepayment;
                }
            }else{
                forecastInput.Ending_Balance__c = forecastInput.Current_Ending_Balance__c;
            }
            
            if(forecastInput.RecordtypeId == RTDrawdown){
                if(forecastInput.Last_Month_Forecast__c == null){
                    forecastInput.Average_Balance__c = forecastInput.Current_Ending_Balance__c / 2;
                }else{
                    forecastInput.Average_Balance__c = (forecastInput.Ending_Balance__c + forecastInput.Last_Month_Ending_Balance__c) / 2;
                }
            }else{
                if(forecastInput.adjustMonthYear__c >= currentMonth){
                    forecastInput.Average_Balance__c = forecastInput.Current_Ending_Balance__c;
                    if(forecastInput.Last_Month_Forecast__c != null){
                        forecastInput.Average_Balance__c = (forecastInput.Ending_Balance__c + forecastInput.Last_Month_Ending_Balance__c) / 2;
                    }
                }
            }
            
            if(forecastInput.Last_Month_Forecast__r?.Actual_NIM__c != null && forecastInput.Last_Month_Forecast__r?.Actual_NIM__c != 0){
                forecastInput.Forecast_NIM__c = forecastInput.Last_Month_Forecast__r.Actual_NIM__c;
            }else if(forecastInput.Last_Month_Forecast__r?.Forecast_NIM__c != null && forecastInput.Last_Month_Forecast__r?.Forecast_NIM__c != 0){
                forecastInput.Forecast_NIM__c = forecastInput.Last_Month_Forecast__r.Forecast_NIM__c;
            }else if(forecastInput.RecordtypeId == RTExistingRepay){
                if(forecastInput.Product__r?.Financial_Product_Domain__c == 'Deposit'){
                    forecastInput.Forecast_NIM__c = mapNIMport.containsKey(forecastInput.Customer__r.Owner.Segment__c) ? mapNIMport.get(forecastInput.Customer__r.Owner.Segment__c).NIMd__c : 0;
                }else if(forecastInput.Product__r?.Financial_Product_Domain__c == 'Credit'){
                    forecastInput.Forecast_NIM__c = mapNIMport.containsKey(forecastInput.Customer__r.Owner.Segment__c) ? mapNIMport.get(forecastInput.Customer__r.Owner.Segment__c).NIMc__c : 0;
                }
            }
            
            if(forecastInput.adjustMonthYear__c >= currentMonth){
                forecastInput.Hold_Commitment__c = (forecastInput.Hold_Commitment__c != null && forecastInput.Hold_Commitment__c != 0) ? forecastInput.Hold_Commitment__c : forecastInput.Last_Month_Forecast__r?.Hold_Commitment__c == null ? 0 : forecastInput.Last_Month_Forecast__r.Hold_Commitment__c;

                forecastInput.FTP__c = (forecastInput.FTP__c != null && forecastInput.FTP__c != 0) ? forecastInput.FTP__c : forecastInput.Last_Month_Forecast__r?.FTP__c == null ? 0 : forecastInput.Last_Month_Forecast__r.FTP__c;

                forecastInput.Interest_Income__c = (forecastInput.Interest_Income__c != null && forecastInput.Interest_Income__c != 0) ? forecastInput.Interest_Income__c : forecastInput.Last_Month_Forecast__r?.Interest_Income__c == null ? 0 : forecastInput.Last_Month_Forecast__r.Interest_Income__c;
            }
            
            if(forecastInput.adjustMonthYear__c >= currentMonth && forecastInput.Forecast_NIM__c != null){
                forecastInput.NI__c = (forecastInput.Average_Balance__c * (forecastInput.Forecast_NIM__c / 100) * daysMonth) / daysYear;
            }
            updateSet.add(forecastInput);
        }

        if(updateSet.size() > 0){
            Database.SaveResult[] srLst = Database.update(updateSet, false);

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
                    mapMFIErrorMsg.put(updateSet.get(i).Id, errormsg);
                    mapIdErrorMFI.put(updateSet.get(i).Id, updateSet.get(i));
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug(':::::::::::::::finish:::::::::::::::');

        batchEndTime = datetime.now();

        if(recordsFailed + recordsSuccessful > 0){
            batchStartTimeSet.add(batchDate);
            recordsSuccessfulSet.add(recordsSuccessful);
            recordsFailedSet.add(recordsFailed);
            batchEndTimeSet.add(batchEndTime);
            monthSet.add(month);
            yearSet.add(year);
        }

        Date nextBatchDate = ThisBatchDate.addMonths(1);

        if(nextBatchDate < Date.today().addMonths(11) && goNext){
            ForecastInputSynchronizationBatch instance;
            if(isSpecificAcctSuffRef){
                ForecastInputSynchronizationBatch bat = new ForecastInputSynchronizationBatch(nextBatchDate, SpecificAcctSuffRefSet, batchStartTimeSet, batchEndTimeSet, yearSet, monthSet, recordsSuccessfulSet, recordsFailedSet, mapMFIErrorMsg, mapIdErrorMFI);

                database.executebatch(bat, 500);

            } else if (prodDomainStr != null && prodRemarkStr != null){
                instance = new ForecastInputSynchronizationBatch(nextBatchDate, addOnQuery, prodDomainStr, prodRemarkStr, customerSegment, goNext, batchStartTimeSet, batchEndTimeSet, yearSet, monthSet, recordsSuccessfulSet, recordsFailedSet, mapMFIErrorMsg, mapIdErrorMFI);
            } else {
                instance = new ForecastInputSynchronizationBatch(nextBatchDate, batchStartTimeSet, batchEndTimeSet, yearSet, monthSet, recordsSuccessfulSet, recordsFailedSet, mapMFIErrorMsg, mapIdErrorMFI);
            }

            if(instance != null){
                AsyncQueue__c job = AsyncApexFrameworkUtil.CreateBatchQueue(instance, 1000, 'ForecastInputSynchronizationBatch', null);
                insert job;
            }
        } else {
            if(recordsSuccessfulSet.size() + recordsFailedSet.size() > 0 && !isSpecificAcctSuffRef){

                String subjectEmail = 'Forecast Synchronization: ';

                String customerSegmentStr = '';

                if(customerSegment != null && customerSegment != ''){
                    customerSegmentStr = customerSegment;
                }else{
                    customerSegmentStr = 'All';
                }

                if(prodDomainStr != null && prodDomainStr != '') subjectEmail += 'Product domain:' + prodDomainStr;
                if(prodRemarkStr != null && prodRemarkStr != '') subjectEmail += ', Product Remark:' + prodRemarkStr;

                subjectEmail += ', Customer Segment:' + customerSegmentStr;

                String sObjectName = 'Monthly_Forecast_Input__c';

                List<String> sendToEmail = new List<String>();
                sendToEmail.add('CRM Admin 2');
                
                String csvHeaderStr = 'Account_Suffix_Ref__c, Year__c, Month__c, Recordtype.Name, adjustMonthYear__c, YearMonthAcctSuffRef__c, ErrorMessage\n';
                String CSV_BODY = '';
        
                for (Id mfiId : mapIdErrorMFI.keySet()) {
                    CSV_BODY += mapIdErrorMFI.get(mfiId).Account_Suffix_Ref__c 
                                + ',' + mapIdErrorMFI.get(mfiId).Year__c
                                + ',' + mapIdErrorMFI.get(mfiId).Month__c
                                + ',' + mapIdErrorMFI.get(mfiId).Recordtype.Name
                                + ',' + mapIdErrorMFI.get(mfiId).adjustMonthYear__c
                                + ',' + mapIdErrorMFI.get(mfiId).YearMonthAcctSuffRef__c
                                + ',' + mapMFIErrorMsg.get(mfiId) + '\n';
                }
            
                Forecast_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchStartTimeSet, batchStartTimeSet, batchEndTimeSet, recordsSuccessfulSet, recordsFailedSet, yearSet, monthSet, subjectEmail, sobjectName, sendToEmail, CSV_BODY, '', '', csvHeaderStr, '', '', '');
            }
        }
    }
}