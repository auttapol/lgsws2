public class RTL_HouseholdHistoryTriggerHandler extends TriggerHandler{
    public static Boolean historyTrigger = false;
    private static String newHouseholdRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('New Household').getRecordTypeId();
    private static String newMemberRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('New Member').getRecordTypeId();
    private static String pendingHouseholdRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Pending Household').getRecordTypeId();
    private static String pendingMemberRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Pending Member').getRecordTypeId();
    private static String approvedHouseholdRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Approved Household').getRecordTypeId();
    private static String approvedMemberRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Approved Member').getRecordTypeId();
    private static String rejectedHouseholdRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Rejected Household').getRecordTypeId();
    private static String rejectedMemberRecId = Schema.SObjectType.RTL_Household_History_And_Approval__c.getRecordTypeInfosByName().get('Rejected Member').getRecordTypeId();
    
    public RTL_HouseholdHistoryTriggerHandler(){
        historyTrigger = true;
        if(Test.isRunningTest()){
            this.setMaxLoopCount(50);
        }
        else{
            this.setMaxLoopCount(10);
        }
        System.Debug( 'TMB: -> RTL_HouseholdHistoryTriggerHandler Invoked' );
    }
    
    protected override void beforeInsert(List<sObject> newList){
        setRecordType(newList);
        //setApprover(newList);
    }

    protected override void beforeUpdate(map<id,sObject> oldMap,map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_HouseholdHistoryTriggerHandler start of beforeUpdate');
        setRecordType(newMap);
        setResponsedDate(oldMap,newMap);
        
    }   
    
    protected override void afterInsert(Map<Id,sObject> newMap){
        System.Debug('TMB: -> RTL_HouseholdHistoryTriggerHandler start of afterInsert');
        if(RTL_HouseholdTriggerHandler.householdBeforeUpdateTrigger == false){
        	rollupNewPendingSummary(newMap);
        }
    }
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_HouseholdHistoryTriggerHandler start of afterUpdate');
        if(RTL_HouseholdTriggerHandler.householdBeforeUpdateTrigger == false){
        	rollupNewPendingSummary(newMap);
        }
        changeRequest(oldMap,newMap);
    }
    
    protected override void afterDelete(map<id,sObject> oldMap) {        
        System.Debug('TMB: -> RTL_HouseholdHistoryTriggerHandler start of beforeDelete');
        ReverseValue(oldMap);
        rollupNewPendingSummary(oldMap);
    }
    
    private static void setRecordType(List<sObject> newList){
        for(sObject obj : newList){
            RTL_Household_History_And_Approval__c history = (RTL_Household_History_And_Approval__c)obj;
            history.RecordTypeId = newHouseholdRecId;
            if(history.RTL_Member_Lookup_Account__c!= null){
                history.RecordTypeId = newMemberRecId;
            }
        }
    }
    
    private static void setRecordType(Map<Id,sObject> newMap){
        for(sObject obj : newMap.values()){
            RTL_Household_History_And_Approval__c history = (RTL_Household_History_And_Approval__c)obj;
            if(history.RTL_Outcome__c == 'Approved'){
                history.RecordTypeId = approvedHouseholdRecId;
                if(history.RTL_Member_Lookup_Account__c != null){
                    history.RecordTypeId = approvedMemberRecId;
                }  
            }else if(history.RTL_Outcome__c == 'Pending'){
                history.RecordTypeId = pendingHouseholdRecId;
                if(history.RTL_Member_Lookup_Account__c != null){
                    history.RecordTypeId = pendingMemberRecId;
                }
            }else if(history.RTL_Outcome__c == 'Rejected'){
                history.RecordTypeId = rejectedHouseholdRecId;
                if(history.RTL_Member_Lookup_Account__c != null){
                    history.RecordTypeId = rejectedMemberRecId;
                }
            }
            
        }
    }
    
    /*private static void setApprover(List<sObject> newList){
        set<Id> householdId = new Set<Id>();
        Map<Id,RTL_Household__c> householdMap;
        for(sObject obj : newList){
            RTL_Household_History_And_Approval__c history = (RTL_Household_History_And_Approval__c)obj;
            householdId.add(history.RTL_Household__c);
        }
        householdMap = new Map<Id,RTL_Household__c>([SELECT ID,Name,RTL_RM__r.Manager.Name,RTL_RM__r.ManagerId FROM RTL_Household__c 
                                                      WHERE ID IN:householdId]);
        
        for(sObject obj : newList){
            RTL_Household_History_And_Approval__c history = (RTL_Household_History_And_Approval__c)obj;
            history.RTL_Approver_Link__c = householdMap.get(history.RTL_Household__c).RTL_RM__r.ManagerId;
        }
    }*/
    
    private static void rollupNewPendingSummary(map<id,sObject> newMap){
        Set<Id> householdIdSet = new Set<Id>();
        Map<Id,RTL_Household__c> householdMap;
        List<RTL_Household__c> householdToUpdate = new List<RTL_Household__c>();
        for(Id historyId : newMap.keySet()){
            RTL_Household_History_And_Approval__c newHistory = (RTL_Household_History_And_Approval__c)newMap.get(historyId);
        	householdIdSet.add(newHistory.RTL_Household__c);
        }
        if(householdIdSet.size() > 0){
            householdMap = new Map<Id,RTL_Household__c>([SELECT ID,Name,
                                                      		(SELECT ID,Name,RTL_Outcome__c FROM Household_History_And_Approvals__r
                                                            	WHERE RTL_Outcome__c = 'New' OR RTL_Outcome__c = 'Pending') 
                                                      FROM RTL_Household__c WHERE ID IN:householdIdSet]);
            for(RTL_Household__c household : householdMap.values()){
                household.RTL_Number_of_New_and_Pending_Reque__c = household.Household_History_And_Approvals__r.size();
                RTL_Household__c hh = new RTL_Household__c();
                hh.id = household.Id;
                hh.RTL_Number_of_New_and_Pending_Reque__c = household.Household_History_And_Approvals__r.size();
                householdToUpdate.add(hh);
            }
            
            update householdToUpdate;
            
        }
    }
    
    private static void setResponsedDate(map<id,sObject> oldMap, map<id,sObject> newMap){
        RTL_Household_History_And_Approval__c history;
        
        //Find History which status changed and populate response date
        for(Id historyId : newMap.keySet()){
            history = (RTL_Household_History_And_Approval__c)newMap.get(historyId);
            
            //If Approved or Rejected
            if( history.RTL_Outcome__c == 'Approved' && oldMap.get(history.Id).get('RTL_Outcome__c') != 'Approved'
              ||history.RTL_Outcome__c == 'Rejected' && oldMap.get(history.Id).get('RTL_Outcome__c') != 'Rejected')
            {
                history.RTL_Date_Approved__c = Date.today();
                history.RTL_Approver_Link__c = UserInfo.getUserId();
            }
        }
    }
    
    
    private static void changeRequest(map<id,sObject> oldMap, map<id,sObject> newMap){
        System.debug('Start Change Request');
        
        RTL_Household_History_And_Approval__c history;
        RTL_Household_Member__c member;
        RTL_Household__c household;
        Map<Id,Sobject> objectToUpdate = new Map<Id,Sobject>();
        Map<Id,RTL_Household__c> householdToDelete = new Map<Id,RTL_Household__c>();
        Map<Id,RTL_Household__c> householdToHardDelete = new Map<Id,RTL_Household__c>();
        Map<Id,RTL_Household_Member__c> memberToDelete = new Map<Id,RTL_Household_Member__c>();
        Map<Id,RTL_Household_Member__c> primaryMemberMap;/*<HouseholdId,HouseholdMember>*/
        Map<Id,List<RTL_Household_Member__c>> memberMap;/*<HouseholdId,List<HouseholdMember>>*/
        Set<ID> householdIdSet = new Set<ID>();
        for(SObject hist : newMap.values()){
            householdIdSet.add(String.ValueOf(hist.get('RTL_Household__c')));
        }
        
        memberMap = getHouseholdMember(householdIdSet);
        primaryMemberMap = getHouseholdPrimaryMember(householdIdSet);
        
        for(Id historyId : newMap.keySet()){
            history = (RTL_Household_History_And_Approval__c)newMap.get(historyId);
            
            Id memberId = history.RTL_Household_Member__c;
            Id householdId = history.RTL_Household__c;
            Id objId = householdId;
            Boolean isInsertAction = history.RTL_Is_Insert_Action__c;
            
            
            //If Outcome(Status) changed
            if(history.RTL_Outcome__c != oldMap.get(history.Id).get('RTL_Outcome__c'))
            {
                System.debug('HISTORY STATUS :::::::: '+history.RTL_Outcome__c);
                System.debug('HISTORY IS INSERT ACTION :::::::: '+history.RTL_Is_Insert_Action__c);
                System.debug('HISTORY MEMBER ID :::::::: '+history.RTL_Household_Member__c);
                System.debug('HISTORY FIELD CHANGE :::::::: '+history.RTL_Field_Changed__c);
                System.debug('HISTORY FIELD LABEL :::::::: '+history.RTL_Field_Label__c);
                
                //unlock household record to allow edit
                Approval.UnlockResult result = Approval.unlock(householdId);
                //if memberId is not null means this record is for household member
                if(memberId != null)
                {
                    //assign household member id to objId and unlock the record
                    objId = memberId;
                    result =  Approval.unlock(memberId);
                }
                //if this is new household case
                if(isInsertAction == true && memberId == null)
                {
                    RTL_Household__c householdObj =  new RTL_Household__c(Id = householdId);
                    RTL_Household_Member__c membObj = primaryMemberMap.get(householdId);
                    if(history.RTL_Outcome__c == 'Approved')
                    {    
                        householdObj.RTL_Status__c = 'Approved';
                        
                        membObj.RTL_Is_Approved__c  = true;
                        membObj.RTL_Status__c  = 'Approved';
                        objectToUpdate.put(householdId,householdObj);
                        objectToUpdate.put(membObj.id,membObj);
                    }else if(history.RTL_Outcome__c == 'Rejected')
                    {
                        memberToDelete.put(membObj.id,membObj);
                        householdToHardDelete.put(householdId,householdObj);
                    }
                }
                //if this is new member case
                else if(isInsertAction == true && memberId != null){
                    RTL_Household_Member__c membObj = new RTL_Household_Member__c(Id = memberId);
                    if(history.RTL_Outcome__c == 'Approved')
                    {
                        membObj.RTL_Is_Approved__c  = true;
                        membObj.RTL_Status__c  = 'Approved';
                        objectToUpdate.put(membObj.id,membObj);
                    }else if(history.RTL_Outcome__c == 'Rejected')
                    {
                        memberToDelete.put(membObj.id,membObj);
                    }
                }
                //if it is request to delete
                else if(history.RTL_Field_Changed__c == 'RTL_To_Delete__c' && history.RTL_New_Value__c == 'true'){
                    if(history.RTL_Outcome__c == 'Approved')
                    {
                        if(memberId != null)
                        {
                            memberToDelete.put(objId,new RTL_Household_Member__c(id=objId));
                        }
                        else
                        {
                            householdToDelete.put(objId,new RTL_Household__c(id=objId,RTL_Status__c='Deleted'));
                            for(RTL_Household_Member__c memb : memberMap.get(ObjId)){
                                memb.RTL_Status__c = 'Household Deleted';
                                objectToUpdate.put(memb.id,memb);    
                            }
                        }                        
                    }else if(history.RTL_Outcome__c == 'Rejected')
                    {
                        Sobject obj =  objId.getSObjectType().newSObject(objId);
                        obj.put('RTL_To_Delete__c',false);
                        objectToUpdate.put(objId,obj);
                    }
                }else{
                    if(history.RTL_Outcome__c == 'Approved'){
                        
                        //Start assign new Value
                        //if incoming record already in objectToUpdate Map
                        if(objectToUpdate.containsKey(objId))
                        {
                            Sobject obj = objectToUpdate.get(objId);
                            //convert Field Value to Boolean for RTL_Primary__c,RTL_Benefit__c field
                            if(history.RTL_Field_Changed__c == 'RTL_Primary__c' || history.RTL_Field_Changed__c == 'RTL_Benefit__c')
                            {
                                obj.put(history.RTL_Field_Changed__c,Boolean.ValueOf(history.RTL_New_Value__c));
                            }
                            else
                            {
                                obj.put(history.RTL_Field_Changed__c,history.RTL_New_Value__c);
                            } 
                        }
                        else
                        {
                            Sobject obj =  objId.getSObjectType().newSObject(objId);
                            //convert Field Value to Boolean for RTL_Primary__c,RTL_Benefit__c field
                            if(history.RTL_Field_Changed__c == 'RTL_Primary__c' || history.RTL_Field_Changed__c == 'RTL_Benefit__c')
                            {
                                obj.put(history.RTL_Field_Changed__c,Boolean.ValueOf(history.RTL_New_Value__c));
                            }
                            else
                            {
                                obj.put(history.RTL_Field_Changed__c,history.RTL_New_Value__c);
                            } 
                            objectToUpdate.put(objId,obj);
                        }   
                    }
                    
                }  
               
            }  
            
            if(history.RTL_Outcome__c != 'Pending' && history.RTL_Outcome__c != 'New' && objectToUpdate.containsKey(householdId) == false 
               && householdToDelete.containsKey(householdId) == false && householdToHardDelete.containsKey(householdId) == false){
                   
                   //unlock household record to allow edit
                   Approval.UnlockResult result = Approval.unlock(householdId);
                   //if memberId is not null means this record is for household member
                    if(memberId != null)
                    {
                        //assign household member id to objId and unlock the record
                        objId = memberId;
                        result =  Approval.unlock(memberId);
                    }
                    Sobject HouseholdObj =  householdId.getSObjectType().newSObject(householdId);
                    objectToUpdate.put(householdId,HouseholdObj);
               }
            
        }
        
        if(objectToUpdate.size() > 0 ){
            //Approval.UnlockResult[] result = Approval.unlock(objectToUpdate.values());
            update objectToUpdate.values();
        }
        
        //Delete Household Member Records from the system.
        if(memberToDelete.size() > 0){
            //Approval.UnlockResult[] result = Approval.unlock(memberToDelete.values());
            delete memberToDelete.values();
        }
        
        //Set Household Status to Delete
        if(householdToDelete.size() > 0){
            //Approval.UnlockResult[] result = Approval.unlock(householdToDelete.values());
            update householdToDelete.values();
        }
        //Hard Delete Household in case New Household is rejected
        if(householdToHardDelete.size() > 0){
            //Approval.UnlockResult[] result = Approval.unlock(householdToHardDelete.values());
            delete householdToHardDelete.values();
        }
      
    }
    
    private static void ReverseValue(Map<Id,SObject> oldMap){
        List<RTL_Household__c> householdToUpdate = new List<RTL_Household__c>();
         List<RTL_Household__c> householdToDelete = new List<RTL_Household__c>();
        List<RTL_Household_Member__c> memberToUpdate = new List<RTL_Household_Member__c>();
        List<RTL_Household_Member__c> memberToDelete = new List<RTL_Household_Member__c>();
        for(Id historyId: oldMap.keySet()){
            RTL_Household_History_And_Approval__c history = (RTL_Household_History_And_Approval__c)oldMap.get(historyId);
            if(history.RTL_Field_Changed__c == 'RTL_To_Delete__c'){
                if(history.RTL_Household_Member__c != null){
                    memberToUpdate.add(new RTL_Household_Member__c(Id=history.RTL_Household_Member__c,RTL_To_Delete__c = false));
                }else{
                    householdToUpdate.add(new RTL_Household__c(Id=history.RTL_Household__c,RTL_To_Delete__c = false));
                }
            }
            
            if(history.RTL_Is_Insert_Action__c == true){
                if(history.RTL_Household_Member__c != null){
                    memberToDelete.add(new RTL_Household_Member__c(Id=history.RTL_Household_Member__c));
                }else{
                    householdToDelete.add(new RTL_Household__c(Id=history.RTL_Household__c));
                }
            }
        }
        
        if(householdToUpdate.size() > 0){
            update householdToUpdate;
        }
        if(memberToUpdate.size() > 0){
            update memberToUpdate;
        }
        if(memberToDelete.size() > 0){
            delete memberToDelete;
        }
        if(householdToDelete.size() > 0){
            delete householdToDelete;
        }
        
    }
    
    private static Map<ID,List<RTL_Household_Member__c>> getHouseholdMember(Set<Id> householdId){
        Map<ID,List<RTL_Household_Member__c>> memberToReturn = new Map<ID,List<RTL_Household_Member__c>>();
        List<RTL_Household_Member__c> memberList = [SELECT ID,Name,RTL_Household__c 
                                                    FROM RTL_Household_Member__c 
                                                    WHERE RTL_Household__c IN:householdId];
        for(RTL_Household_Member__c memb: memberList){
            if(memberToReturn.containsKey(memb.RTL_Household__c)){
                memberToReturn.get(memb.RTL_Household__c).add(memb);
            }else{
                memberToReturn.put(memb.RTL_Household__c,new List<RTL_Household_Member__c>{memb});
            }
            
        }
        return memberToReturn;
    }
    
    private static Map<ID,RTL_Household_Member__c> getHouseholdPrimaryMember(Set<Id> householdId){
        Map<ID,RTL_Household_Member__c> memberToReturn = new Map<ID,RTL_Household_Member__c>();
        List<RTL_Household_Member__c> memberList = [SELECT ID,Name,RTL_Household__c 
                                                    FROM RTL_Household_Member__c 
                                                    WHERE RTL_Primary__c = true 
                                                         AND RTL_Household__c IN:householdId];
        for(RTL_Household_Member__c memb: memberList){
            memberToReturn.put(memb.RTL_Household__c,memb);
        }
        return memberToReturn;
    }

}