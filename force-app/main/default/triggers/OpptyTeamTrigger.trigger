trigger OpptyTeamTrigger on OpportunityTeamMember (before insert,after insert,before update,after update, before delete,after delete) {


    /***---------------        Check OpportunityTeamMember is not retail        ---------------***/   
    
    map<id, OpportunityTeamMember> mapOldObj = new map<id, OpportunityTeamMember>();
    set<Id> setRecordTypeId = new set<Id>();
    set<Id> oppId = new set<Id>(); 
    for (recordtype r : [SELECT Id  FROM RecordType
                         WHERE SobjectType='Opportunity' AND Name NOT IN ('Retail Bancassurance','Retail Card and RDC','Retail Deposit',
                         'Retail Investment','Retail Loans','Retail Others','Retail Retentions')]){
        setRecordTypeId.add(r.id);
        
    }

    if (Trigger.old != null){
        for (OpportunityTeamMember o : Trigger.old){
            oppId.add(o.OpportunityId);    
        }
        Opportunity opp =[SELECT RecordTypeId FROM Opportunity WHERE Id IN:oppId LIMIT 1];
        
        for (OpportunityTeamMember o : Trigger.old){
            if (setRecordTypeId.contains(opp.RecordTypeId)){
                mapOldObj.put(o.id,o);
            }
        }
    }
    
    /***---------------        Check OpportunityTeamMember is not retail        ---------------***/



    if(Trigger.isAfter && Trigger.isDelete) {
        //OpptyTeamTriggerHandler.getDeletedRecord(Trigger.oldMap);
        OpptyTeamTriggerHandler.getDeletedRecord(mapOldObj);
    }
}