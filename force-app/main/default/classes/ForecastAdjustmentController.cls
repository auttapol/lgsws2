public with sharing class ForecastAdjustmentController {
    final static Id RTExistingRepay {
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

    final static Id RTNewdeal {
        get{
            if(RTNewdeal == null){
                RTNewdeal = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('New Deal').getRecordTypeId();
            }
            return RTNewdeal;
        }set;
    }

    final static Map<String, Region_and_Zone_Mapping__c> regionZoneMapping {
        get{
            if(regionZoneMapping == null){
                regionZoneMapping = new Map<String, Region_and_Zone_Mapping__c>();
                for (Region_and_Zone_Mapping__c regionZone : [SELECT Id, Team_Zone_Code__c, Team_Zone_Name__c, Region_Group_Code__c, Region_Group_Name__c FROM Region_and_Zone_Mapping__c]) {
                    if(regionZone.Team_Zone_Code__c != null && regionZone.Team_Zone_Code__c != '') regionZoneMapping.put(regionZone.Team_Zone_Code__c, regionZone);
                }
            }
            return regionZoneMapping;
        }set;
    }

    final static Set<String> SalesManagementProfiles{
        get{
            if(SalesManagementProfiles == null){
                SalesManagementProfiles = new Set<String>();
                
                AppConfig__c conf = AppConfig__c.getValues('Sales Management Profile list');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        SalesManagementProfiles.add(str);
                    }
                }else{
                    SalesManagementProfiles.add('TMB Commercial Report Specialist Profile');
                    SalesManagementProfiles.add('TMB BB Sales Management Profile');
                    SalesManagementProfiles.add('TMB CB/MB Sales Management Profile');
                    SalesManagementProfiles.add('TMB SE Sales Management Profile');
                }
            }
            return SalesManagementProfiles;
        }
        set;
    }

    public static Integer longTermRepaymentbatSize{
        get{
            if(longTermRepaymentbatSize == null){
                longTermRepaymentbatSize = 1000;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('Forecast_Long_Term_Repayment_Batch_size');

                if(mc != null && mc.Value__c != null){
                    longTermRepaymentbatSize = Integer.valueOf(mc.Value__c);
                }
            }
            return longTermRepaymentbatSize;
        }set;
    }
    
    @AuraEnabled
    public static list<Forecast_Product_Group_Priority__mdt> priorityProduct{
        get{
            if(priorityProduct == null){
                priorityProduct = [SELECT DeveloperName, MasterLabel, Priority__c, Product_Type__c FROM Forecast_Product_Group_Priority__mdt];
            }
            return priorityProduct;
        }set;
    }

    @AuraEnabled
    public static List<RecordType> RTSECredit {
        get{
            if(RTSECredit == null){
                RTSECredit = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName LIKE 'SE_Credit%' AND sObjectType = 'Opportunity'];
            }
            return RTSECredit;
        }set;
    }

    @AuraEnabled
    public static List<RecordType> RTNonCredit {
        get{
            if(RTNonCredit == null){
                RTNonCredit = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName LIKE '%Non_credit%' AND sObjectType = 'Opportunity'];
            }
            return RTNonCredit;
        }set;
    }

    @AuraEnabled
    public static List<RecordType> RTWBGCredit {
        get{
            if(RTWBGCredit == null){
                RTWBGCredit = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName LIKE 'WBG_Credit%' AND sObjectType = 'Opportunity'];
            }
            return RTWBGCredit;
        }set;
    }

    @AuraEnabled
    public static User currentUser{
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Segment__c, Zone_Code__c, Zone__c, Region_Code__c, UserRoleId, UserRole.Name, ProfileId, Profile.Name, Employee_ID__c FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
            }
            return currentUser;
        }
        set;
    }

    public class wrapExistingDetail{
        @AuraEnabled
        public List<Monthly_Forecast_Input__c> existingList {get;set;}
        @AuraEnabled
        public List<Monthly_Forecast_Input__c> drawdown {get;set;}

    }

    public class wrapDealForecastDetail {
        @AuraEnabled
        public List<Deal_Forecast_Income__c> dealForecastList {get;set;}
        @AuraEnabled
        public List<Monthly_Forecast_Input__c> monthlyForecastList {get;set;}
        @AuraEnabled
        public List<RecordType> RTSECredit {get;set;}
    }

    @AuraEnabled
    public static Integer getMonthNumber (String monthName){
        Map<String, Integer> monthsMap = new Map<String, Integer>();
        monthsMap.put('Jan',1);
        monthsMap.put('Feb',2);
        monthsMap.put('Mar',3);
        monthsMap.put('Apr',4);
        monthsMap.put('May',5);
        monthsMap.put('Jun',6);
        monthsMap.put('Jul',7);
        monthsMap.put('Aug',8);
        monthsMap.put('Sep',9);
        monthsMap.put('Oct',10);
        monthsMap.put('Nov',11);
        monthsMap.put('Dec',12); 

        return monthsMap.get(monthName);
    }

    @AuraEnabled
    public static list<Forecast_Product_Group_Priority__mdt> getpriorityProduct(){
        return priorityProduct;
    }

    @AuraEnabled
    public static String getFeeRateLink(){
        AppConfig__c conf = AppConfig__c.getValues('Forecast Fee Rate Hyperlink');

        if(conf != null && conf.Value__c != null){
            return String.valueOf(conf.Value__c);
        } else {
            return 'http://www.infahnet.tmb/site/Product/Rates/Forms/AllItems.aspx?RootFolder=%2fsite%2fProduct%2fRates%2f01%5f%e0%b8%ad%e0%b8%b1%e0%b8%95%e0%b8%a3%e0%b8%b2%e0%b8%94%e0%b8%ad%e0%b8%81%e0%b9%80%e0%b8%9a%e0%b8%b5%e0%b9%89%e0%b8%a2%e0%b8%ad%e0%b9%89%e0%b8%b2%e0%b8%87%e0%b8%ad%e0%b8%b4%e0%b8%87%e0%b8%aa%e0%b8%b3%e0%b8%ab%e0%b8%a3%e0%b8%b1%e0%b8%9a%e0%b8%a5%e0%b8%b9%e0%b8%81%e0%b8%84%e0%b9%89%e0%b8%b2%20Wholesale&FolderCTID=0x012000B7EE0C135751C845AF1C1F07165AAB87';
        }
    }

    @AuraEnabled
    public static List<Monthly_Forecast_Input__c> getmonthlyForecastInput(integer month, integer year, String accId, String groupId , List<String> searchTeam, String prdDomain, String prdGroup, String port, Boolean isMaturedInMonth) {
        //System.debug('::::: getmonthlyForecastInput :::::');
        List<Monthly_Forecast_Input__c> result = new List<Monthly_Forecast_Input__c>();
        String stringMonth = month < 10 ? '0' + String.valueOf(month) : String.valueOf(month);
        String stringYear = String.valueOf(year);
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Id currentUserId = currentUser.Id;

        Set<String> searchTeamSet = new Set<String>();

        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }

        String Fields = 'SELECT Id, Product__r.Financial_Product_Group_Name__c, RecordType.Name, Customer__c, Product__r.Financial_Product_Domain__c, Customer__r.TMB_Customer_ID_PE__c, Customer__r.RTL_Customer_Name_TH__c, Customer__r.Group__r.Name, Customer__r.Owner.Name, Product__c, Average_Balance_YTD__c, Team_Code__c, Month__c, Year__c, Account_Suffix_Ref__c, Limit__c, Average_Balance__c, F_Projected_Balance__c, Current_Ending_Balance__c, Ending_Balance__c, Total_Repay_Due_Amount__c, Repay_Due_Amount_Week1__c, Repay_Due_Amount_Week2__c, Repay_Due_Amount_Week3__c, Repay_Due_Amount_Week4__c, Repay_Due_Amount_Week5__c, Repay_Due_Amount_Week6__c, Forecast_NIM__c, X4G__c, Maturity_Date__c, Last_Adjustment_By__r.Name, Last_Update_Adjustment__c, Last_Month_Ending_Balance__c, Product_Type__c, Drawdown_Rollover_Week1__c, Drawdown_Rollover_Week2__c, Drawdown_Rollover_Week3__c, Drawdown_Rollover_Week4__c, Drawdown_Rollover_Week5__c, Drawdown_Rollover_Week6__c, Total_Drawdown_Rollover__c FROM Monthly_Forecast_Input__c ';
        String whereCondCurrent = ' WHERE YearMonthAcctSuffRef__c LIKE \'' + stringYear + stringMonth + '%\' AND RecordTypeId = :RTExistingRepay AND Month__c = :stringMonth AND Year__c = :stringYear AND (Average_Balance__c > 0 OR Current_Ending_Balance__c > 0 OR Limit__c > 0)';

        if(port != null && port != ''){
            if(port == 'My Customer'){
                whereCondCurrent += ' AND Customer__r.OwnerId = :currentUserId';
            }else if(port == 'My Team'){
                userSet = getMyteamUser();
                whereCondCurrent += ' AND Customer__r.OwnerId IN :userSet';
            }else if(port == 'My Account Team'){
                Set<Id> userIdSet = new Set<Id>();
                userIdSet.add(currentUser.Id);
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
                if(acctTeamacctIdSet.size() <= 0) return result;
                whereCondCurrent += ' AND Customer__c IN :acctTeamacctIdSet';
            }else if(port == 'Select Team'){

            }else if(port == 'My Team-Account Team'){
                userSet = getMyteamUser();
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
                if(acctTeamacctIdSet.size() <= 0) return result;
                whereCondCurrent += ' AND Customer__c IN :acctTeamacctIdSet';
            }
        }

        if(prdDomain != null && prdDomain != ''){
            whereCondCurrent += ' AND Product__r.Financial_Product_Domain__c = :prdDomain';
        }

        if(prdGroup != null && prdGroup != ''){
            whereCondCurrent += ' AND Product__r.Financial_Product_Group_Name__c = :prdGroup';
        }

        if (accId != null && accId != ''){
            whereCondCurrent +=' AND Customer__c = :accID';
        }

        if (groupId != null && groupId != ''){
            whereCondCurrent +=' AND Customer__r.Group__c = :groupId';
        }
        
        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereCondCurrent +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }

        if(isMaturedInMonth != null && isMaturedInMonth){
            whereCondCurrent +=' AND CALENDAR_MONTH(Maturity_Date__c) = :month AND CALENDAR_YEAR(Maturity_Date__c) = :year';
        }
        
        String orderBy = ' ORDER BY Team_Code__c asc ,Customer__r.TMB_Customer_ID_PE__c asc  ' ;

        String queryStrCurrent = Fields + whereCondCurrent + orderBy;

        System.debug(queryStrCurrent);
        result = Database.query(queryStrCurrent);
        System.debug(result);
        //System.debug(Limits.getDMLRows());
        return result;
    }

    @AuraEnabled
    public static List<Monthly_Forecast_Input__c> getDrawdown(integer month, integer year, String accId, String groupId, List<String> searchTeam, String prdDomain, String prdGroup, String port, Boolean isLastyear) {
        //System.debug('::::: getDrawdown :::::');
        List<Monthly_Forecast_Input__c> result = new List<Monthly_Forecast_Input__c>();
        String stringMonth = month < 10 ? '0' + String.valueOf(month) : String.valueOf(month);
        String stringYear = String.valueOf(year);
        Integer monthInt = Date.today().month();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Date thisDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date selectedDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
        Id currentUserId = currentUser.Id;
        
        String Fields = 'SELECT Id, RecordType.Name, Customer__c, Customer__r.TMB_Customer_ID_PE__c, Customer__r.RTL_Customer_Name_TH__c, Customer__r.Group__r.Name, Customer__r.Owner.Name, Product__c, Team_Code__c, Month__c, Year__c, Account_Suffix_Ref__c, Limit__c, Average_Balance__c, F_Projected_Balance__c, Current_Ending_Balance__c, Ending_Balance__c, Total_Repay_Due_Amount__c, Repay_Due_Amount_Week1__c, Repay_Due_Amount_Week2__c, Repay_Due_Amount_Week3__c, Repay_Due_Amount_Week4__c, Repay_Due_Amount_Week5__c, Repay_Due_Amount_Week6__c, X4G__c, Maturity_Date__c, Last_Adjustment_By__r.Name, Last_Update_Adjustment__c, Last_Month_Ending_Balance__c, Product_Type__c, Drawdown_Rollover_Week1__c, Drawdown_Rollover_Week2__c, Drawdown_Rollover_Week3__c, Drawdown_Rollover_Week4__c, Drawdown_Rollover_Week5__c, Drawdown_Rollover_Week6__c, Total_Drawdown_Rollover__c FROM Monthly_Forecast_Input__c ';
        String whereDrawdown = ' WHERE YearMonthAcctSuffRef__c LIKE \'' + stringYear + stringMonth + '%\' AND RecordTypeId = :RTDrawdown AND Month__c = :stringMonth AND Year__c = :stringYear ';

        Set<String> searchTeamSet = new Set<String>();

        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }

        if(port != null && port != ''){
            if(port == 'My Customer'){
                whereDrawdown += ' AND Customer__r.OwnerId = :currentUserId';
            }else if(port == 'My Team'){
                userSet = getMyteamUser();
                whereDrawdown +=' AND Customer__r.OwnerId IN :userSet';
            }else if(port == 'My Account Team'){
                Set<Id> userIdSet = new Set<Id>();
                userIdSet.add(currentUser.Id);
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
                if(acctTeamacctIdSet.size() <= 0) return result;
                whereDrawdown += ' AND Customer__c IN :acctTeamacctIdSet';
            }else if(port == 'Select Team'){

            }else if(port == 'My Team-Account Team'){
                userSet = getMyteamUser();
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
                if(acctTeamacctIdSet.size() <= 0) return result;
                whereDrawdown += ' AND Customer__c IN :acctTeamacctIdSet';
            }
        }

        if(prdDomain != null && prdDomain != ''){
            whereDrawdown += ' AND Product__r.Financial_Product_Domain__c = :prdDomain';
        }

        if(prdGroup != null && prdGroup != ''){
            whereDrawdown += ' AND Product__r.Financial_Product_Group_Name__c = :prdGroup';
        }

        if (accId != null && accId != ''){
            whereDrawdown +=' AND Customer__c = :accID ';
        }

        if (groupId != null && groupId != ''){
            whereDrawdown +=' AND Customer__r.Group__c = :groupId';
        }

        if((isLastyear != null && !isLastyear) || selectedDate >= thisDate){
            whereDrawdown +=' AND adjustMonthYear__c >= TODAY ';
        }

        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereDrawdown +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }

        String orderBy = ' ORDER BY Team_Code__c asc ,Customer__r.TMB_Customer_ID_PE__c asc  ' ;
        String queryStrDrawdown = Fields + whereDrawdown + orderBy;
        result = Database.query(queryStrDrawdown);

        return result;
    }

    @AuraEnabled
    public static wrapExistingDetail getExistingDetail(String Id , String Product ,String month , String year ,String team){
        wrapExistingDetail result = new wrapExistingDetail();
        result.drawdown = new List<Monthly_Forecast_Input__c>();
        result.existingList = new List<Monthly_Forecast_Input__c>();
        try{
            String queryStr = 'SELECT Id, Hold_Commitment__c,Customer__r.TMB_Customer_ID_PE__c, Customer__r.Owner.Zone__c , Customer__r.Group__r.Name, Customer__r.RTL_Customer_Name_TH__c , NI_Formula__c, F_Projected_Balance__c, RPN_Type__c, Account_Status_Desc__c, Product_Type__c, Customer__c, Forecast_NIM__c, NIIc__c, NIId__c, Product__r.Financial_Product_Domain__c, Product__c, Limit__c, Team_Code__c, Product_Code__c, Average_Balance__c, Current_Ending_Balance__c, Account_Suffix_Ref__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, Maturity_Date__c, Issue_Date__c, Gross_Rate__c, Interest_Revenue__c, Loan_Status__c FROM Monthly_Forecast_Input__c WHERE YearMonthAcctSuffRef__c LIKE \'' + year + month + '%\' AND RecordTypeId = :RTExistingRepay AND Customer__c = :Id AND Product_Type__c = :Product AND Month__c = :month AND Year__c = :year AND (Average_Balance__c > 0 OR Current_Ending_Balance__c > 0 OR Limit__c > 0)  ';
            result.drawdown = [SELECT Id,Average_Balance__c, F_Projected_Balance__c, NI_Formula__c, Total_Drawdown_Rollover__c, Forecast_NIM__c, adjustMonthYear__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c,Issue_Date__c, Month__c , Year__c FROM Monthly_Forecast_Input__c  WHERE RecordTypeId = :RTDrawdown AND Customer__c = :Id AND Product_Type__c = :Product AND Month__c = :month AND Year__c = :year AND adjustMonthYear__c >= TODAY];
            result.existingList = Database.query(queryStr);
        }catch (Exception e) {
            //System.debug(e.getLineNumber() + ' | ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static void SaveExistingRepayment(List<Monthly_Forecast_Input__c> MFIList, String year, String month){
        Set<String> acctSuffRefSet = new Set<String>();
        Date inputDate = Date.newInstance(year == null ? Date.today().year() : integer.valueof(year), month == null ? Date.today().month() : integer.valueof(month), 1);

        for (Monthly_Forecast_Input__c MFIEach : MFIList){
            acctSuffRefSet.add(MFIEach.Account_Suffix_Ref__c);
            MFIEach.Last_Adjustment_By__c = UserInfo.getUserId();
            MFIEach.Last_Update_Adjustment__c = Datetime.now();
        }
        
        try{
            update MFIList;

            ForecastInputSynchronizationBatch bat = new ForecastInputSynchronizationBatch(inputDate, acctSuffRefSet);
            Database.ExecuteBatch(bat, 200);
        }catch(Exception e){
            //ystem.debug(e.getLineNumber() + ' | ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static void SaveDrawdown(Id acctId, String productType, String product, String month, String year, String drawDownW1, String drawDownW2, String drawDownW3, String drawDownW4, String drawDownW5, String drawDownW6){
        map<String, Monthly_Forecast_Input__c> MFIDrawdownMaplst = new map<String, Monthly_Forecast_Input__c>();

        try{
            Date lastMonthDate = (Date.TODAY()).addMonths(-1);
            String lastMonth = lastMonthDate.month() < 10 ? '0' + String.valueOf(lastMonthDate.month()) : String.valueOf(lastMonthDate.month());
            String lastMonthYear = String.valueOf(lastMonthDate.Year());
            List<Monthly_Forecast_Input__c> listTodayMonthMFI = [SELECT NI_Formula__c , Average_Balance__c ,Account_Suffix_Ref__c FROM Monthly_Forecast_Input__c WHERE Customer__c=:acctId AND Product_Type__c=:productType AND Product__c=:product AND RecordTypeId = :RTExistingRepay AND Month__c =:lastMonth AND Year__c =:lastMonthYear ];
            Map<String, Monthly_Forecast_Input__c> mapMFI = new Map<String, Monthly_Forecast_Input__c>();
            Double totalNI = 0;
            Double totalAvg = 0;
            Decimal dayOfYear = Date.isLeapYear(lastMonthDate.Year()) ? 366 : 365;
            Decimal dayOfMonth = date.daysInMonth(lastMonthDate.Year(), lastMonthDate.month());
            for (Monthly_Forecast_Input__c MFI : listTodayMonthMFI) {
                totalNI += MFI.NI_Formula__c;
                totalAvg += MFI.Average_Balance__c;
            }
            System.debug('totalNI: ' + totalNI);
            System.debug('totalAvg: ' + totalAvg);
            System.debug('dayOfYear: ' + dayOfYear);
            System.debug('dayOfMonth: ' + dayOfMonth);
            
            Double averageNim = totalAvg == 0 ? 0 : (totalNI / totalAvg) * (dayOfYear / dayOfMonth) *100;

            if(drawDownW1 != null && drawDownW1 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW1, '01' , averageNim));
            }
            if(drawDownW2 != null && drawDownW2 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW2, '02' , averageNim));
            }
            if(drawDownW3 != null && drawDownW3 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW3, '03' , averageNim));
            }
            if(drawDownW4 != null && drawDownW4 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW4, '04' , averageNim));
            }
            if(drawDownW5 != null && drawDownW5 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW5, '05' , averageNim));
            }
            if(drawDownW6 != null && drawDownW6 != ''){
                MFIDrawdownMaplst.putAll(generateDrawdown(acctId, productType, product, month, year, drawDownW6, '06' , averageNim));
            }

            if(MFIDrawdownMaplst.size() > 0){
                upsert MFIDrawdownMaplst.values() YearMonthAcctSuffRef__c;       
                Date inputDate = Date.newInstance(year == null ? Date.today().year() : integer.valueof(year), month == null ? Date.today().month() : integer.valueof(month), 1);
                Set<String> acctSuffRefSet = new Set<String>();
                List<Monthly_Forecast_Input__c> MFIRelatedList = new List<Monthly_Forecast_Input__c>();
                for(Monthly_Forecast_Input__c MFI : MFIDrawdownMaplst.values()){
                    if(MFI.Last_Month_Forecast__c == null){
                        Date dateKey =  Date.newInstance(Integer.valueOf(MFI.Year__c), Integer.valueOf(MFI.Month__c) - 1, 1);
                        Date adjustDateKey =  Date.newInstance(Integer.valueOf(MFI.Year__c), Integer.valueOf(MFI.Month__c) - 1, 1);
                        String key = String.valueOf(dateKey.Year()) + (dateKey.month() < 10 ? '0' + String.valueOf(dateKey.month()) : String.valueOf(dateKey.Month())) + String.valueOf(MFI.adjustMonthYear__c.Year()) + (MFI.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(MFI.adjustMonthYear__c.month()) : String.valueOf(MFI.adjustMonthYear__c.Month())) + MFI.Account_Suffix_Ref__c;
                        
                        if(MFIDrawdownMaplst.containsKey(key)){
                            MFI.Last_Month_Forecast__c = MFIDrawdownMaplst.get(key).Id;
                            MFIRelatedList.add(MFI);
                        }
                    }
                    acctSuffRefSet.add(MFI.Account_Suffix_Ref__c);
                }
                update MFIRelatedList;
                ForecastInputSynchronizationBatch bat = new ForecastInputSynchronizationBatch(inputDate, acctSuffRefSet);
                Database.ExecuteBatch(bat, 200);
            } 
        }
        catch(Exception e){
            //System.debug(e.getLineNumber() + ' | ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }     
    }

    public static map<String, Monthly_Forecast_Input__c> generateDrawdown(Id acctId, String productType, String product, String month, String year, String drawDownAmount, String weekNo ,Double averageNim){      
        map<String, Monthly_Forecast_Input__c> mapresultList = new map<String, Monthly_Forecast_Input__c>();
        Date todayDate = date.Today().addMonths(11);
        Date inputDate = Date.newInstance(integer.valueof(year), integer.valueof(month), 1);

        while(todayDate > inputDate) {
            String inputYear = string.valueof(inputDate.year());
            String inputMonth = inputDate.month() < 10 ? '0'+ string.valueof(inputDate.month()) : string.valueof(inputDate.month());

            Monthly_Forecast_Input__c result = new Monthly_Forecast_Input__c();

            result.YearMonthAcctSuffRef__c = inputYear + inputMonth + year + month + acctId + productType + weekNo;
            result.Account_Suffix_Ref__c = acctId + productType + weekNo;
            result.recordtypeId = RTDrawdown;
            result.Month__c = inputMonth;
            result.Year__c = inputYear;
            result.Forecast_NIM__c = averageNim;
            result.Customer__c = acctId;
            result.Product_Type__c = productType;
            result.adjustMonthYear__c = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month) + 1, 0);
            result.Current_Ending_Balance__c = Integer.valueOf(drawDownAmount);
            result.Average_Balance__c = Integer.valueOf(drawDownAmount) /2 ;
            result.Product__c = product;
            result.Last_Adjustment_By__c = UserInfo.getUserId();
            result.Last_Update_Adjustment__c = Datetime.now();
            
            if(inputMonth == month){
                result.put('Drawdown_Rollover_Week' + Integer.valueOf(weekNo) + '__c', Integer.valueOf(drawDownAmount));
                result.put('Ending_Balance__c',Integer.valueOf(drawDownAmount));
            }

            mapresultList.put(result.YearMonthAcctSuffRef__c,result);
            inputDate = inputDate.addMonths(1);
        }
        return mapresultList;
    }


    @AuraEnabled
    public static List<Deal_Forecast_Income__c> getDealForecast(integer month, integer year, String accId, String productDomain, String searchGroup, List<String> searchTeam, String stage, String port, String prob) {
        Date today = System.today();
        Id currentUserId = currentUser.Id;
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        List<String> exceptStageAll = new List<String>{'Closed Won', 'Closed Lost'};

        List<Deal_Forecast_Income__c> dealForecastList = new List<Deal_Forecast_Income__c>();

        Set<String> searchTeamSet = new Set<String>();

        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }

        String Fields = 'SELECT Id, Customer__c, Customer__r.TMB_Customer_ID_PE__c, Customer__r.Name, Customer__r.RTL_Customer_Name_TH__c, Customer__r.Sub_Segment2__c, Customer__r.Group__c, Customer__r.Group__r.Name, Customer__r.Owner.Name, Year__c, Opportunity__c,  Opportunity__r.Name, Opportunity__r.StageName, Opportunity__r.RecordTypeId, Opportunity__r.RecordType.Name, Opportunity__r.Application_Status__c, Opportunity__r.CloseDate, Probability__c, Product__c, Product__r.Name , Income_Type__c, Volume__c, NIM_Fee_rate__c, Utilization_Percent__c, Recurring_Type__c, Frequency__c, Remark__c, Opportunity_Product_Id__c, Last_Adjustment_By__r.Name, Last_Update_Adjustment__c, OpportunityLineItem_Limit_Volume__c, Expected_Start_Month__c , This_Year_Expected_Balance__c, Expected_Start_Year__c, Main_Deal_forecast__c FROM Deal_Forecast_Income__c';
        
        String whereCondCurrent = ' WHERE CALENDAR_YEAR(Opportunity__r.CloseDate) = :year';

        whereCondCurrent += ' AND ((Opportunity__r.RecordTypeId IN :RTSECredit AND Opportunity__r.Probability >= 70) OR (Opportunity__r.RecordTypeId IN :RTWBGCredit AND Opportunity__r.Probability != NULL AND Probability__c != \'\' ) OR (Opportunity__r.RecordTypeId IN :RTNonCredit AND Opportunity__r.Probability >= 70))';

        if(month != null && month != 0) {
            whereCondCurrent += ' AND CALENDAR_MONTH(Opportunity__r.CloseDate) = :month';
        }

        if(accId != null && accId != ''){
            whereCondCurrent +=' AND Customer__c = :accID';
        }

        if(port != null && port != ''){
            if(port == 'My Customer'){
                whereCondCurrent += ' AND Customer__r.OwnerId = :currentUserId';
            }else if(port == 'My Team'){
                userSet = getMyteamUser();
                whereCondCurrent +=' AND Customer__r.OwnerId IN :userSet';
            }else if(port == 'My Account Team'){
                Set<Id> userIdSet = new Set<Id>();
                userIdSet.add(currentUser.Id);
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
                if(acctTeamacctIdSet.size() <= 0) return dealForecastList;
                whereCondCurrent += ' AND Customer__c IN :acctTeamacctIdSet';
            }else if(port == 'My Team-Account Team'){
                userSet = getMyteamUser();
                if(accId != null && accId != '') acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet, accId);
                else acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
                if(acctTeamacctIdSet.size() <= 0) return dealForecastList;
                whereCondCurrent += ' AND Customer__c IN :acctTeamacctIdSet';
            }else if(port == 'Select Team'){

            }
        }

        if (productDomain != null && productDomain != ''){
            productDomain = '%' + productDomain + '%';
            whereCondCurrent +=' AND Product__r.Product_Domain__c LIKE :productDomain';
        }

        if (searchGroup != null && searchGroup != ''){
            whereCondCurrent +=' AND Customer__r.Group__c = :searchGroup';
        }

        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereCondCurrent +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet';
        }

        if (stage != null && stage != ''){
            if (stage == 'all') {
                whereCondCurrent +=' AND Opportunity__r.StageName NOT IN :exceptStageAll';
            } else {
                whereCondCurrent +=' AND Opportunity__r.StageName = :stage';
            }
        }

        if (prob != null && prob != ''){
            whereCondCurrent +=' AND Probability__c = :prob';
        }

        whereCondCurrent += ' ORDER BY Customer__r.Sub_Segment2__c ASC, Customer__c ASC, Product__r.Name ASC, Opportunity__c ASC, Main_Deal_forecast__c ASC';

        
        String queryStrCurrent = Fields + whereCondCurrent;
        dealForecastList = Database.query(queryStrCurrent);

        return dealForecastList;
    }

    @AuraEnabled
    public static Deal_Forecast_Income__c saveDealForecastRecord(Deal_Forecast_Income__c DFI){
        Integer ExpectedStartYaer = Integer.valueOf(DFI.Expected_Start_Year__c);
        Integer ExpectedStartMonth = getMonthNumber(DFI.Expected_Start_Month__c);

        DFI.Start_Utilization_Date__c = Date.newInstance(ExpectedStartYaer, ExpectedStartMonth + 1, 0);
        DFI.Last_Adjustment_By__c = UserInfo.getUserId();
        DFI.Last_Update_Adjustment__c = Datetime.now();
        DFI.This_Year_Expected_Balance__c = ExpectedStartYaer > System.today().year() ? 0 : DFI.Volume__c ;

        try {
           upsert DFI;
        } catch (Exception e) {
            System.debug(e.getMessage());
           throw new AuraHandledException(e.getMessage());
        }

        if (DFI.Expected_Start_Year__c != null && DFI.Expected_Start_Month__c != null) {
            Date ExpectedStartDate = date.newInstance(ExpectedStartYaer, ExpectedStartMonth, 1);
            List<Monthly_Forecast_Input__c> monthlyForecastList = new List<Monthly_Forecast_Input__c>();
            
            // delete old monthly forecast
            List<Monthly_Forecast_Input__c> oldMonthlyForecastList = new List<Monthly_Forecast_Input__c>([SELECT ID FROM Monthly_Forecast_Input__c WHERE Deal_Forecast_Income__c = :DFI.Id]);
            delete oldMonthlyForecastList;
            
            Map<String, Monthly_Forecast_Input__c> mapMFI = new map<String, Monthly_Forecast_Input__c>();
            List<Deal_Forecast_Income__c> checkSE = new List<Deal_Forecast_Income__c>([SELECT Id, Opportunity__r.RecordTypeId, Product__r.Remark__c FROM Deal_Forecast_Income__c 
                WHERE Id = :DFI.Id AND Opportunity__r.RecordTypeId IN :RTSECredit AND Product__r.Remark__c = 'ST loan']);
            Decimal ending = 0;
            Decimal dayOfYear = Date.isLeapYear(ExpectedStartYaer) ? 366 : 365;
            
            for (Integer i = 0; i < 12; i++) {
                Monthly_Forecast_Input__c monthlyForecast = new Monthly_Forecast_Input__c();
                Date forecastDate = ExpectedStartDate.addMonths(i);
                String month = forecastDate.month() < 10 ? '0' + String.valueOf(forecastDate.month()) : String.valueOf(forecastDate.month());
                String year = String.valueOf(forecastDate.year());
                Decimal dayOfMonth = date.daysInMonth(forecastDate.year(), forecastDate.month());
                Double nimRate = DFI.NIM_Fee_rate__c == null ? 0 : DFI.NIM_Fee_rate__c / 100;
                if (i == 0) {
                    ending = DFI.Volume__c;
                } else if (DFI.Income_Type__c != null && DFI.Income_Type__c.contains('NIIc') && (checkSE.size() != 0 && (i == 1 || i == 2))) {
                    Decimal volume = ending + DFI.OpportunityLineItem_Limit_Volume__c * 0.05;
                    if(volume <= DFI.OpportunityLineItem_Limit_Volume__c) {
                        ending += DFI.OpportunityLineItem_Limit_Volume__c * 0.05;
                    }
                }

                monthlyForecast.RecordTypeId = RTNewdeal;
                monthlyForecast.Deal_Forecast_Income__c = DFI.Id;
                monthlyForecast.Year__c = year;
                monthlyForecast.Month__c = month;
                monthlyForecast.adjustMonthYear__c = forecastDate; 
                monthlyForecast.Ending_Balance__c = ending;
                monthlyForecast.Customer__c = DFI.Customer__c;   
                monthlyForecast.Opportunity__c = DFI.Opportunity__c;
                monthlyForecast.OpportunityLineItem_Id__c = DFI.Opportunity_Product_Id__c;               
                monthlyForecast.Product__c = DFI.Product__c;
                monthlyForecast.Forecast_NIM__c = DFI.NIM_Fee_rate__c;
                monthlyForecast.Limit__c = DFI.OpportunityLineItem_Limit_Volume__c;
                monthlyForecast.Income_Type__c = DFI.Income_Type__c;
                
                // Acc/Suff/Ref = Opportunity Product Id
                monthlyForecast.Account_Suffix_Ref__c = DFI.Opportunity_Product_Id__c; 
                monthlyForecast.YearMonthAcctSuffRef__c = year + month + DFI.Id + DFI.Opportunity_Product_Id__c;

                if(DFI.Income_Type__c != null) {
                    if (DFI.Income_Type__c.contains('Fee') || DFI.Income_Type__c.contains('Supply Chain')) {
                        if (DFI.Recurring_Type__c == 'Recurring') {
                            if (DFI.Frequency__c == 'Monthly') {
                                monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * nimRate / 12;
                            } else if (DFI.Frequency__c == 'Quarterly') {
                                if (math.mod(i, 3) == 0) {                                
                                    monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * nimRate / 4;
                                } else {
                                    monthlyForecast.NI__c = 0;
                                }
                            } else if (DFI.Frequency__c == 'Biyearly') {
                                if (math.mod(i, 6) == 0) {                                
                                    monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * nimRate / 2;
                                } else {
                                    monthlyForecast.NI__c = 0;
                                }
                            } else if (DFI.Frequency__c == 'Yearly') {
                                if (i == 0) {                                
                                    monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * nimRate;
                                } else {
                                    monthlyForecast.NI__c = 0;
                                }
                            }
                        } else if (DFI.Recurring_Type__c == 'One-off') {
                            if (i == 0) {                                
                                monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * nimRate;
                            } else {
                                monthlyForecast.NI__c = 0;
                            }
                        }
                    } else {
                        monthlyForecast.NI__c = monthlyForecast.Ending_Balance__c * ((nimRate / dayOfYear) * dayOfMonth);
                    }
                }

                mapMFI.put(monthlyForecast.YearMonthAcctSuffRef__c, monthlyForecast);
            }

            try {
                upsert mapMFI.values() YearMonthAcctSuffRef__c;
    
                for(Monthly_Forecast_Input__c MFI : mapMFI.values()){
                    if(MFI.Last_Month_Forecast__c == null){
                        date dateKey = MFI.adjustMonthYear__c.addMonths(-1);
                        String key = String.valueOf(dateKey.Year()) + (dateKey.month() < 10 ? '0' + String.valueOf(dateKey.month()) : String.valueOf(dateKey.Month())) + DFI.Id + MFI.Account_Suffix_Ref__c;
    
                        if(mapMFI.containsKey(key)){
                            MFI.Last_Month_Forecast__c = mapMFI.get(key).Id;
                            monthlyForecastList.add(MFI);
                        }
                    }
                }
    
                update monthlyForecastList;

                List<Forecast_Cube_1__c> hasCube = new List<Forecast_Cube_1__c>([SELECT Id FROM Forecast_Cube_1__c WHERE Customer__c = :DFI.Customer__c AND Product__c = :DFI.Product__c AND Year__c =: DFI.Expected_Start_Year__c]);
                if(hasCube.size() == 0) {
                    Forecast_Cube_1__c newCube1 = new Forecast_Cube_1__c();
                    newCube1.cubeKey__c = '' + DFI.Customer__c + DFI.Product__c + DFI.Expected_Start_Year__c;
                    newCube1.Customer__c = DFI.Customer__c;
                    newCube1.Product__c = DFI.Product__c;
                    newCube1.Year__c = DFI.Expected_Start_Year__c;

                    insert newCube1;
                }


            } catch (Exception e) {
                //System.debug(e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }

        List<Deal_Forecast_Income__c> dfUpdted = new List<Deal_Forecast_Income__c>([SELECT Id, Last_Adjustment_By__r.Name, Last_Update_Adjustment__c FROM Deal_Forecast_Income__c WHERE Id = :DFI.Id]);
        
        return dfUpdted[0];
    }

    @AuraEnabled
    public static void deleteDealForecastRecord(Deal_Forecast_Income__c DFI){
        try {
            delete DFI;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @AuraEnabled
    public static wrapDealForecastDetail getDealForecastDetail(String Id) {  
        wrapDealForecastDetail dealForecastDetail = new wrapDealForecastDetail();
        List<Deal_Forecast_Income__c> dealForecastList = new List<Deal_Forecast_Income__c>([SELECT Id, Product__c, Product__r.Remark__c, Product__r.Name, Opportunity__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.RecordTypeId, Opportunity__r.This_Year_Expected_Revenue__c, Expected_Start_Month__c, Expected_Start_Year__c, Income_Type__c, Recurring_Type__c, Frequency__c, NIM_Fee_rate__c, Probability__c, Remark__c, OpportunityLineItem_Limit_Volume__c, Utilization_Percent__c FROM Deal_Forecast_Income__c WHERE Id = :Id]);
        List<Monthly_Forecast_Input__c> monthlyForecastList = new List<Monthly_Forecast_Input__c>([SELECT Id, Month__c, Year__c, RecordTypeId, Ending_Balance__c, NI__c, Deal_Forecast_Income__c FROM Monthly_Forecast_Input__c WHERE Deal_Forecast_Income__c = :Id]);
        
        dealForecastDetail.dealForecastList = dealForecastList;
        dealForecastDetail.monthlyForecastList = monthlyForecastList;
        dealForecastDetail.RTSECredit = RTSECredit;

        return dealForecastDetail;
    }

    @AuraEnabled
    public static void saveMonthlyForecastRecord(List<Monthly_Forecast_Input__c> MFI, Integer startMonth) {
        Set<String> dealForecastId = new Set<String>();

        for (Monthly_Forecast_Input__c monthlyForecast : MFI) {
            dealForecastId.add(monthlyForecast.Deal_Forecast_Income__c);
        }

        Map<Id, Deal_Forecast_Income__c> dealForecastList = new Map<Id, Deal_Forecast_Income__c>([SELECT Id,Expected_Start_Year__c, Volume__c, Last_Adjustment_By__c, Last_Update_Adjustment__c, This_Year_Expected_Balance__c FROM Deal_Forecast_Income__c WHERE Id = :dealForecastId]);

        for(Monthly_Forecast_Input__c monthlyForecast : MFI){
        }
        for (Integer i = 0; i < MFI.size(); i++) {
            if (i == 0) {
                dealForecastList.get(MFI[i].Deal_Forecast_Income__c).Volume__c = MFI[i].Ending_Balance__c;
            }
            if (i == 12 - startMonth){
                dealForecastList.get(MFI[i].Deal_Forecast_Income__c).This_Year_Expected_Balance__c = Integer.valueOf(dealForecastList.get(MFI[i].Deal_Forecast_Income__c).Expected_Start_Year__c) > (System.Today().year()) ? 0 : MFI[i].Ending_Balance__c ;
            }
            dealForecastList.get(MFI[i].Deal_Forecast_Income__c).Last_Adjustment_By__c = UserInfo.getUserId();
            dealForecastList.get(MFI[i].Deal_Forecast_Income__c).Last_Update_Adjustment__c = Datetime.now();
        }

        try{
            update MFI;
            update dealForecastList.values();
        }catch (Exception e) {
            system.debug(e.getLineNumber() + ' - ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String getUserPortOptionPermission(){
        String result = '';
        String profileName = currentUser.Profile.Name;
        String roleName = currentUser.UserRole.Name;
        String zoneCode = currentUser.Zone_Code__c == null ? '' : currentUser.Zone_Code__c;
        String zone = currentUser.Zone__c == null ? '' : currentUser.Zone__c;
        String regionCode = currentUser.Region_Code__c == null ? '' : currentUser.Region_Code__c;

        Map<String, Map<String, String>> mapPortTeamcode = new Map<String, Map<String, String>> ();

        try {
            Map<String, Forecast_Permission__mdt> ProfileForecastPermission = new Map<String, Forecast_Permission__mdt>();
            Map<String, Forecast_Permission__mdt> RoleForecastPermission = new Map<String, Forecast_Permission__mdt>();

            for (Forecast_Permission__mdt ForecastPermission : [SELECT Id, Profile_Name__c, Role__c, My_Customer_Accessibility__c, My_Team_Accessibility__c, My_Account_Team_Accessibility__c, Select_Team_Accessibility__c, My_Team_Account_Team_Accessibility__c FROM Forecast_Permission__mdt]) {
                if(ForecastPermission.Profile_Name__c != null && ForecastPermission.Profile_Name__c != ''){
                    ProfileForecastPermission.put(ForecastPermission.Profile_Name__c, ForecastPermission);
                }else if(ForecastPermission.Role__c != null && ForecastPermission.Role__c != ''){
                    RoleForecastPermission.put(ForecastPermission.Role__c, ForecastPermission);
                }
            }

            Forecast_Permission__mdt ForecastPermission = RoleForecastPermission.containsKey(roleName) ? RoleForecastPermission.get(roleName) : ProfileForecastPermission.containsKey(profileName) ? ProfileForecastPermission.get(profileName) : null;
            
            if(ForecastPermission != null){
                if(ForecastPermission?.My_Team_Account_Team_Accessibility__c == true){
                    Map<String, String> mapZoneName = new Map<String, String>();
                    for (String key : regionZoneMapping.keySet()) {
                        mapZoneName.put(key, regionZoneMapping.get(key).Team_Zone_Name__c);
                    }
                    mapPortTeamcode.put('My Team-Account Team', mapZoneName);
                }

                if(ForecastPermission?.Select_Team_Accessibility__c == true){
                    Map<String, String> mapZoneName = new Map<String, String>();
                    for (String key : regionZoneMapping.keySet()) {
                        if(SalesManagementProfiles.contains(profileName)){
                            mapZoneName.put(key, regionZoneMapping.get(key).Team_Zone_Name__c);
                        }
                        else if(regionCode != null && regionCode == regionZoneMapping.get(key).Region_Group_Code__c){
                            mapZoneName.put(key, regionZoneMapping.get(key).Team_Zone_Name__c);
                        }
                    }
                    mapPortTeamcode.put('Select Team', mapZoneName);
                }
                
                if(ForecastPermission?.My_Account_Team_Accessibility__c == true){
                    Map<String, String> mapZoneName = new Map<String, String>();
                    for (String key : regionZoneMapping.keySet()) {
                        mapZoneName.put(key, regionZoneMapping.get(key).Team_Zone_Name__c);
                    }
                    mapPortTeamcode.put('My Account Team', mapZoneName);
                }

                if(ForecastPermission?.My_Team_Accessibility__c == true){
                    Map<String, String> mapZoneName = new Map<String, String>();
                    
                    if(regionZoneMapping.containsKey(zoneCode)) mapZoneName.put(zoneCode, regionZoneMapping.get(zoneCode).Team_Zone_Name__c); 
                    else mapZoneName.put(zoneCode, zone);

                    mapPortTeamcode.put('My Team', mapZoneName);
                }

                if(ForecastPermission?.My_Customer_Accessibility__c == true){
                    Map<String, String> mapZoneName = new Map<String, String>();

                    if(regionZoneMapping.containsKey(zoneCode)) mapZoneName.put(zoneCode, regionZoneMapping.get(zoneCode).Team_Zone_Name__c); 
                    else mapZoneName.put(zoneCode, zone);

                    mapPortTeamcode.put('My Customer', mapZoneName);
                }
            }else{
                throw new AuraHandledException('You have no permission.');
                // Map<String, String> mapZoneName = new Map<String, String>();

                // if(regionZoneMapping.containsKey(zoneCode)) mapZoneName.put(zoneCode, regionZoneMapping.get(zoneCode).Team_Zone_Name__c); 
                // else mapZoneName.put(zoneCode, zone);
                // mapPortTeamcode.put('My Customer', mapZoneName);
            }

            result = JSON.serialize(mapPortTeamcode);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        if(mapPortTeamcode.size() == 0){
            throw new AuraHandledException('You have no permission.');
        }
        return result;
    }
    
    public static Set<Id> getMyteamUser(){
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{currentUser.UserRoleId});
        Map<Id,User> users = new Map<Id, User>([SELECT Id, Name FROM User WHERE UserRoleId IN :allSubRoleIds AND isActive = true]);
        users.put(currentUser.Id,currentUser);
        return users.keySet();
    }

    public static Set<Id> getAcctTeamAcctIdSet(Set<Id> userIdSet){
        Set<Id> result = new Set<Id>();

        for(AccountTeamMember acctTeam : [SELECT Id, AccountId, UserId, TeamMemberRole, Title, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel  FROM AccountTeamMember WHERE UserId IN :userIdSet]){
            result.add(acctTeam.AccountId);
        }
        //System.debug(result);
        return result;
    }

    public static Set<Id> getAcctTeamAcctIdSet(Set<Id> userIdSet, String acctId){
        Set<Id> result = new Set<Id>();

        for(AccountTeamMember acctTeam : [SELECT Id, AccountId, UserId, TeamMemberRole, Title, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel  FROM AccountTeamMember WHERE UserId IN :userIdSet AND AccountId = :acctId]){
            result.add(acctTeam.AccountId);
        }
        //System.debug(result);
        return result;
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
    
        return currentRoleIds;
    }

    @AuraEnabled
    public static void runForecastPipelineBatch(String batchName){
        try{
            if(batchName == 'Longterm') {
                database.executebatch(new updateLongtermRepaymentBatch(), longTermRepaymentbatSize);
            } else if(batchName == 'ExistingFee') {
                database.executebatch(new GenerateForecastInputExistFeeBatch(), 500);
            } else if(batchName == 'ExpireDrawdown') {
                database.executebatch(new ForecastExpireDrawdownBatch(Date.newInstance(Date.today().addMonths(-1).year(), Date.today().addMonths(-1).month(), 1)), 500);
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}