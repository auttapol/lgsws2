public class RTL_HouseholdTriggerHandler extends TriggerHandler{
    private List<String> fieldsToTrack = new List<String>{'RTL_Remarks__c','RTL_Benefit_Package__c','RTL_To_Delete__c'};
	private Map<String,String> fieldNameMap;
	public static Boolean householdBeforeUpdateTrigger = false;
    
    public RTL_HouseholdTriggerHandler(){        
        if(Test.isRunningTest()){
            this.setMaxLoopCount(30);
        }
        else{
            this.setMaxLoopCount(10);
        }
        System.Debug( 'TMB: -> RTL_HouseholdTriggerHandler Invoked' );
        
        //Initiate Household Field Name mapping with API Name
        fieldNameMap = new Map<String,String>();
        //fieldNameMap.put('Name','Household Name');
        //fieldNameMap.put('RTL_Status__c','Status');
        fieldNameMap.put('RTL_Remarks__c','Edit Household : Remarks');
        fieldNameMap.put('RTL_Benefit_Package__c','Edit Household : Benefit');
        fieldNameMap.put('RTL_To_Delete__c','Delete Household');
        //fieldNameMap.put('RTL_RM__c','Relationship Manager');
    }

    protected override void afterInsert(map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_HouseholdTriggerHandler start of afterInsert');
        RTL_WriteHistory.writeInsertHistory(newMap,fieldsToTrack,fieldNameMap);
        
    }   
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_HouseholdTriggerHandler start of beforeUpdate'); 
        householdBeforeUpdateTrigger = true;
        if(RTL_HouseholdHistoryTriggerHandler.historyTrigger == false){
            Map<String,RTL_Household_History_and_Approval__c> existingHistoryMap = getExistingHistory(newMap);
        	RTL_WriteHistory.writeUpdateHistory(oldMap,newMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        }
    }
    
    protected override void AfterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_HouseholdTriggerHandler start of afterUpdate');         
        lockRecord(newMap);
    }
    
    private Map<String,RTL_Household_History_and_Approval__c> getExistingHistory(map<id,SObject> newMap){
        Map<String,RTL_Household_History_and_Approval__c> historyMap = new Map<String,RTL_Household_History_and_Approval__c>();
        List<RTL_Household_History_and_Approval__c> historyList = [SELECT ID,Name,RTL_Prev_Value__c,RTL_New_Value__c,
                                                              RTL_Field_Changed__c,RTL_Household__c,
                                                              RTL_Household_Member__c 
                                                       FROM RTL_Household_History_and_Approval__c 
                                                       WHERE RTL_Outcome__c = 'New' 
                                                       		AND RTL_Household__c IN:newMap.values()];
        for(RTL_Household_History_and_Approval__c history : historyList){
            historyMap.put(history.RTL_Household__c+history.RTL_Field_Changed__c,history);
        }
        return historyMap;
        
    }
    
    private void lockRecord(map<id,sObject> newMap){
        System.debug('Start Locking Record');
        List<RTL_Household__c> householdToLock = new List<RTL_Household__c>();
        List<RTL_Household_Member__c> memberToLock = new List<RTL_Household_Member__c>();
        List<RTL_Household__c> householdList = [SELECT ID,(SELECT ID,RTL_Outcome__c 
                                 	FROM Household_History_and_Approvals__r 
                                 		WHERE RTL_Outcome__c = 'Pending') ,(SELECT ID,Name FROM Household_Members__r)
                         FROM RTL_Household__c 
                         WHERE Id IN:newMap.values()];
        for(RTL_Household__c household : householdList){
            if(household.Household_History_and_Approvals__r.size() > 0){
                householdToLock.add(household);
                memberToLock.addAll(household.Household_Members__r);
            }   
        }
        Approval.lock(householdToLock);
        Approval.lock(memberToLock);
    }  
    
}