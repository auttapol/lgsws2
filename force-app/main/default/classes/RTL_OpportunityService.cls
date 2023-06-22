public class RTL_OpportunityService {
	/**
    * This method is to add additional opportunity information before insertion
    */
    public static void defaultOpportunityName (List<Opportunity> oppsNew) {
        //Set the Name prefix
        String oppNamePrefix = 'O-';
        //Get current year
        Integer year = System.Today().year();

        if(UserInfo.getLocale() == 'th_TH'){
            year = year - 543;
        }
        
        Map<Id,RTL_Opportunity_Running_Number__c> oppRunningNumberToInsert = new Map<Id,RTL_Opportunity_Running_Number__c>();
    	//Store opportunity account to map to oppNumber object
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity newOppObj: oppsNew) acctIds.add(newOppObj.AccountId);
        
        Map<Id,RTL_Opportunity_Running_Number__c> oppRunningNumbers = new Map<Id,RTL_Opportunity_Running_Number__c>();
        for(RTL_Opportunity_Running_Number__c oppNumber : [SELECT ID,RTL_Account__c,RTL_Year__c,RTL_Number__c 
                                                           FROM RTL_Opportunity_Running_Number__c
                                                           WHERE RTL_Account__c in :acctIds AND RTL_Year__c = :year]){
        	oppRunningNumbers.put(oppNumber.RTL_Account__c,oppNumber);	                                                       
        }  
        
        for (Opportunity newOppObj: oppsNew){
            //
            if(oppRunningNumbers.containsKey(newOppObj.AccountId)){
                Decimal runningNumber = oppRunningNumbers.get(newOppObj.AccountId).RTL_Number__c+1;
                String runningNumbString = String.ValueOf(runningNumber);
                newOppObj.Name = oppNamePrefix+year+'-'+runningNumbString.leftPad(3).replace(' ', '0');
                oppRunningNumbers.get(newOppObj.AccountId).RTL_Number__c = runningNumber;
            }else if(oppRunningNumberToInsert.containsKey(newOppObj.AccountId)){
                Decimal runningNumber = oppRunningNumberToInsert.get(newOppObj.AccountId).RTL_Number__c+1;
                String runningNumbString = String.ValueOf(runningNumber);
                newOppObj.Name = oppNamePrefix+year+'-'+runningNumbString.leftPad(3).replace(' ', '0');
                oppRunningNumberToInsert.get(newOppObj.AccountId).RTL_Number__c = runningNumber;
            }
            else{
                oppRunningNumberToInsert.put(newOppObj.AccountId,new RTL_Opportunity_Running_Number__c(RTL_Account__c = newOppObj.AccountId,
                                                                                  RTL_Year__c = year,
                                                                                  RTL_Number__c = 1));
                newOppObj.Name = oppNamePrefix+year+'-001';
            }
        }
        
        if(oppRunningNumbers.size() > 0){
            update oppRunningNumbers.values();
        }
        
        if(oppRunningNumberToInsert.size() > 0){
            insert oppRunningNumberToInsert.values();
        }
        
    }
}