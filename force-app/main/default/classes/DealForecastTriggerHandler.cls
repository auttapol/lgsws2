public class DealForecastTriggerHandler {

    private static Id RTNewDeal {
        get{
            if(RTNewDeal == null){
                RTNewDeal = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('New Deal').getRecordTypeId();
            }
            return RTNewDeal;
        }set;
    }

    public static void generateForecastInput(list<Deal_Forecast_Income__c> dealForecastlst){
        Integer startMonthNewDeal = Date.Today().Month();
        try {
            List<Monthly_Forecast_Input__c> monthlyForecastList = new List<Monthly_Forecast_Input__c>();
            map<String, Monthly_Forecast_Input__c> mapMFI = new map<String, Monthly_Forecast_Input__c>();

            for (Deal_Forecast_Income__c dealForecast : dealForecastlst) {
                for (Integer i = startMonthNewDeal; i <= 12; i++) {
                    
                    Monthly_Forecast_Input__c monthlyForecast = new Monthly_Forecast_Input__c();
                    String month = i < 10 ? '0' + String.valueOf(i) : String.valueOf(i);
                    String year = String.valueOf(Date.Today().Year());
                    
                    monthlyForecast.RecordTypeId = RTNewDeal;
                    monthlyForecast.Deal_Forecast_Income__c = dealForecast.Id;
                    monthlyForecast.Customer__c = dealForecast.Customer__c;
                    monthlyForecast.Ending_Balance__c = dealForecast.Volume__c;
                    monthlyForecast.Year__c = year;
                    monthlyForecast.Month__c = month;
                    monthlyForecast.Opportunity__c = dealForecast.Opportunity__c;
                    monthlyForecast.OpportunityLineItem_Id__c = dealForecast.Opportunity_Product_Id__c;               
                    monthlyForecast.Product__c = dealForecast.Product__c;
                    monthlyForecast.adjustMonthYear__c = Date.newInstance(Date.Today().Year(),i,1); 
                    
                    // Acc/Suff/Ref = Opportunity Product Id
                    monthlyForecast.Account_Suffix_Ref__c = dealForecast.Opportunity_Product_Id__c; 
                    monthlyForecast.YearMonthAcctSuffRef__c = year + month + dealForecast.Id + dealForecast.Opportunity_Product_Id__c;

                    mapMFI.put(monthlyForecast.YearMonthAcctSuffRef__c, monthlyForecast);
                }
            }

            insert mapMFI.values();

            for(Monthly_Forecast_Input__c MFI : mapMFI.values()){
                if(MFI.Last_Month_Forecast__c == null){
                    date dateKey = MFI.adjustMonthYear__c.addMonths(-1);
                    String key = String.valueOf(dateKey.Year()) + (dateKey.month() < 10 ? '0' + String.valueOf(dateKey.month()) : String.valueOf(dateKey.Month())) + MFI.Account_Suffix_Ref__c;

                    if(mapMFI.containsKey(key)){
                        MFI.Last_Month_Forecast__c = mapMFI.get(key).Id;
                        monthlyForecastList.add(MFI);
                    }
                }
            }

            update monthlyForecastList;

        } catch (Exception ex) {
            system.debug(ex.getLineNumber() + ' - ' + ex.getMessage());
        }
    }

    public static void updateOpportunitylineitem (map<Id, Deal_Forecast_Income__c> oldMap, map<Id, Deal_Forecast_Income__c> newMap){
        map<Id, Deal_Forecast_Income__c> mapSyncDealForecast = new map<Id, Deal_Forecast_Income__c>();

        for (Deal_Forecast_Income__c newdealForecast : newMap.values()) {
            if((newdealForecast.OpportunityLineItem_Limit_Volume__c != oldMap.get(newdealForecast.Id).OpportunityLineItem_Limit_Volume__c || newdealForecast.Probability__c != oldMap.get(newdealForecast.Id).Probability__c) && newdealForecast.Opportunity_Product_Id__c != null){
                mapSyncDealForecast.put(newdealForecast.Id, newdealForecast);
            }
        }
        
        List<String> oppIdList = new List<String>();

        for (Deal_Forecast_Income__c newdealForecast : mapSyncDealForecast.values()) {
            oppIdList.add(newdealForecast.Opportunity_Product_Id__c);
        }

        Map<Id, Opportunitylineitem> mapOppItemId = new Map<Id, Opportunitylineitem>([SELECT Id, Deal_Probability__c, UnitPrice FROM Opportunitylineitem WHERE Id IN :oppIdList]);
        
        for(Deal_Forecast_Income__c dealForecast : mapSyncDealForecast.values()){
            mapOppItemId.get(dealForecast.Opportunity_Product_Id__c).Deal_Probability__c = getProbPercent(dealForecast.Probability__c);
            mapOppItemId.get(dealForecast.Opportunity_Product_Id__c).UnitPrice = dealForecast.OpportunityLineItem_Limit_Volume__c;
        }
        
        try{
            update mapOppItemId.values();
        }catch (Exception e) {
            system.debug(e.getLineNumber() + ' - ' + e.getMessage());
        }
    }

    public static void updateForecastInput (Map<Id, Deal_Forecast_Income__c> dealForecastlst){
        
        Set<Id> dealForecastIdList = dealForecastlst.keySet();
        
        Map<Id, Monthly_Forecast_Input__c> monthlyForecastList = new Map<Id, Monthly_Forecast_Input__c>([SELECT Id, Deal_Forecast_Income__c, Ending_Balance__c FROM Monthly_Forecast_Input__c WHERE Deal_Forecast_Income__c IN :dealForecastIdList AND RecordTypeId = :RTNewDeal]);
        
        List<Monthly_Forecast_Input__c> monthlyForecastUpdatedList = new List<Monthly_Forecast_Input__c>();

        for(Monthly_Forecast_Input__c monthlyForecast : monthlyForecastList.values()){
            Deal_Forecast_Income__c dealForecastItem = dealForecastlst.get(monthlyForecast.Deal_Forecast_Income__c);
            Boolean isUpdate = false;

            if(dealForecastItem.Volume__c != monthlyForecast.Ending_Balance__c) {
                monthlyForecast.Ending_Balance__c = dealForecastItem.Volume__c;
                isUpdate = true;
            }

            if(isUpdate) monthlyForecastUpdatedList.add(monthlyForecast);
        }
        
        if(monthlyForecastUpdatedList.size() > 0){
            try{
                update monthlyForecastUpdatedList;
            }catch (Exception e) {
                system.debug(e.getLineNumber() + ' - ' + e.getMessage());
            }
        }

    }

    public static void deleteSubDealForecast (Map<Id, Deal_Forecast_Income__c> dealForecastlst){
        System.debug('dealForecastlst: ' + dealForecastlst);

        List<Deal_Forecast_Income__c> dealForecastDeletedList = new List<Deal_Forecast_Income__c>();

        Set<Id> dealForecastIdList = dealForecastlst.keySet();
        
        Map<Id, Deal_Forecast_Income__c> subDealForecastlst = new Map<Id, Deal_Forecast_Income__c>([SELECT Id, Main_Deal_forecast__c FROM Deal_Forecast_Income__c WHERE Main_Deal_forecast__c IN :dealForecastIdList]);
        System.debug('subDealForecastlst: ' + subDealForecastlst);

        for(Deal_Forecast_Income__c subDealForecast : subDealForecastlst.values()){
            Deal_Forecast_Income__c dealForecast = dealForecastlst.get(subDealForecast.Main_Deal_forecast__c);

            if(dealForecast != null) {
                dealForecastDeletedList.add(subDealForecast);
            }
        }
        
        if(dealForecastDeletedList.size() > 0){
            try{
                delete dealForecastDeletedList;
            }catch (Exception e) {
                system.debug(e.getLineNumber() + ' - ' + e.getMessage());
            }
        }
    }

    public static void deleteForecastInput (Map<Id, Deal_Forecast_Income__c> dealForecastlst){
        System.debug('dealForecastlst: ' + dealForecastlst);
        
        Set<Id> dealForecastIdList = dealForecastlst.keySet();

        Map<Id, Monthly_Forecast_Input__c> monthlyForecastList = new Map<Id, Monthly_Forecast_Input__c>([SELECT Id, Deal_Forecast_Income__c FROM Monthly_Forecast_Input__c WHERE Deal_Forecast_Income__c IN :dealForecastIdList AND RecordTypeId = :RTNewDeal]);
        
        List<Monthly_Forecast_Input__c> monthlyForecastDeletedList = new List<Monthly_Forecast_Input__c>();

        System.debug('monthlyForecastList: ' + monthlyForecastList);

        for(Monthly_Forecast_Input__c monthlyForecast : monthlyForecastList.values()){
            Deal_Forecast_Income__c dealForecast = dealForecastlst.get(monthlyForecast.Deal_Forecast_Income__c);

            if(dealForecast != null) {
                monthlyForecastDeletedList.add(monthlyForecast);
            }
        }
        
        if(monthlyForecastDeletedList.size() > 0){
            try{
                delete monthlyForecastDeletedList;
            }catch (Exception e) {
                system.debug(e.getLineNumber() + ' - ' + e.getMessage());
            }
        }
    }

    public static void syncOpportunitylineitem (Map<Id, Deal_Forecast_Income__c> dealForecastlst){
        List<String> oppIdList = new List<String>();

        for (Deal_Forecast_Income__c dealForecast : dealForecastlst.values()) {
            if(dealForecast.Main_Deal_forecast__c == null) {
                oppIdList.add(dealForecast.Opportunity_Product_Id__c);
            }
        }

        Map<Id, Opportunitylineitem> mapOppItemId = new Map<Id, Opportunitylineitem>([SELECT Id, Deal_Probability__c, UnitPrice FROM Opportunitylineitem WHERE Id IN :oppIdList]);

        System.debug('syncOpportunitylineitem | Oppline Item: ' + mapOppItemId);

        for(Opportunitylineitem oppItem : mapOppItemId.values()) {
            oppItem.Deal_Probability__c = '';
            oppItem.UnitPrice = 0;
        }
        
        try{
            update mapOppItemId.values();
        }catch (Exception e) {
            system.debug(e.getLineNumber() + ' - ' + e.getMessage());
        }
    }
    public static String getProbPercent (String probName){
        Map<String, String> probMap = new  Map<String, String>();
        probMap.put('Cancelled', '0%');
        probMap.put('Low', '25%');
        probMap.put('Medium', '50%');
        probMap.put('High', '75%');
        
        return probMap.get(probName);
    }
}