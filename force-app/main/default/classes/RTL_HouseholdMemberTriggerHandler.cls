public class RTL_HouseholdMemberTriggerHandler extends TriggerHandler{
	private List<String> fieldsToTrack = new List<String>{'RTL_Relationship__c','RTL_Benefit__c','RTL_To_Delete__c'};
    private Map<String,String> fieldNameMap;
        
    public RTL_HouseholdMemberTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(4);
        }
        System.Debug( 'TMB: -> RTL_HouseholdMemberTriggerHandler Invoked' );
        //Initiate Household Field Name mapping with API Name
        fieldNameMap = new Map<String,String>();
        fieldNameMap.put('RTL_Relationship__c','Edit Member : Relationship');
        fieldNameMap.put('RTL_Benefit__c','Edit Member : Benefit');
        fieldNameMap.put('RTL_To_Delete__c','Delete Member');
        
    }
    
    protected override void beforeInsert(List<SObject> so) {       
        System.Debug('TMB: -> RTL_HouseholdMemberTriggerHandler start of afterInsert');
        checkDuplicateMember(so);
    }  

    protected override void afterInsert(map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_HouseholdMemberTriggerHandler start of afterInsert');
        Map<id,SObject> newMemberMap = getNotPrimaryMember(newMap);
        RTL_WriteHistory.writeInsertHistory(newMemberMap,fieldsToTrack,fieldNameMap);
    }   
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_HouseholdMemberTriggerHandler start of afterUpdate'); 
        if(RTL_HouseholdHistoryTriggerHandler.historyTrigger == false){
            Map<String,RTL_Household_History_and_Approval__c> existingHistoryMap = getExistingHistory(newMap);
        	RTL_WriteHistory.writeUpdateHistory(oldMap,newMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        }       
    }
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_HouseholdMemberTriggerHandler start of afterUpdate'); 
		Map<String,RTL_Household_History_and_Approval__c> existingHistoryMap = getExistingHistory(newMap);
        lockRecord(newMap);
    }
    
    private void checkDuplicateMember(List<SObject> so){
        Set<Id> householdId = new Set<Id>();
        Map<Id,RTL_Household__c> householdwithMember;
        for(SObject obj : so){
            RTL_Household_Member__c member = (RTL_Household_Member__c)obj;
            householdId.add(member.RTL_Household__c);
        }
        householdwithMember = new Map<ID,RTL_Household__c>([SELECT ID,(SELECT ID,RTL_Household_Member_Name__c FROM Household_Members__r) FROM RTL_Household__c WHERE ID IN:householdId]);
        for(SObject obj : so){
            RTL_Household_Member__c member = (RTL_Household_Member__c)obj;
            List<RTL_Household_Member__c> memberList = householdwithMember.get(member.RTL_Household__c).Household_Members__r;
            for(RTL_Household_Member__c memb : memberList){
                if(member.RTL_Household_Member_Name__c == memb.RTL_Household_Member_Name__c){
                    member.addError(System.Label.RTL_Household_ERR06);
                }
            }
        }
    }
    
    private void lockRecord(map<id,sObject> newMap){
        List<RTL_Household__c> householdToLock = new List<RTL_Household__c>();
        List<RTL_Household_Member__c> memberToLock = new List<RTL_Household_Member__c>();
        Set<ID> householdId = new Set<ID>();
        for(sObject member : newMap.values()){
            householdId.add(String.ValueOf(member.get('RTL_Household__c')));
        }
        List<RTL_Household__c> householdList = [SELECT ID,(SELECT ID,RTL_Outcome__c 
                                 	FROM Household_History_and_Approvals__r 
                                 	WHERE  RTL_Outcome__c = 'Pending') ,(SELECT ID,Name FROM Household_Members__r)
                         FROM RTL_Household__c 
                         WHERE Id IN:householdId];
        for(RTL_Household__c household : householdList){
            if(household.Household_History_and_Approvals__r.size() > 0){
                householdToLock.add(household);
                memberToLock.addAll(household.Household_Members__r);
            }   
        }
        Approval.lock(householdToLock);
        Approval.lock(memberToLock);
    }
    
    
    private Map<String,RTL_Household_History_and_Approval__c> getExistingHistory(map<id,SObject> newMap){
        Map<String,RTL_Household_History_and_Approval__c> historyMap = new Map<String,RTL_Household_History_and_Approval__c>();
        List<RTL_Household_History_and_Approval__c> historyList = [SELECT ID,Name,RTL_Prev_Value__c,RTL_New_Value__c,
                                                              RTL_Field_Changed__c,RTL_Household__c,
                                                              RTL_Household_Member__c 
                                                       FROM RTL_Household_History_and_Approval__c 
                                                       WHERE RTL_Outcome__c = 'New' 
                                                       		AND RTL_Household_Member__c IN:newMap.values()];
        for(RTL_Household_History_and_Approval__c history : historyList){
            historyMap.put(history.RTL_Household_Member__c+history.RTL_Field_Changed__c,history);
        }
        return historyMap;
        
    }
    private map<id,SObject> getNotPrimaryMember(map<id,SObject> newMap){
        map<id,SObject> memberMap = new map<id,SObject>();
        for(SObject member : newMap.values()){
            if(Boolean.ValueOf(member.get('RTL_Primary__c')) == false){
                memberMap.put(member.id,member);
            }
            
        }
        return memberMap;
    }
    
}