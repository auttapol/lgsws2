trigger LeadScoringConditionTrigger on Lead_Scoring_Condition__c ( after insert, after update) {


    list<Lead_Scoring_Condition__c> listNewLeadScoringCondition = new list<Lead_Scoring_Condition__c>();

    if (Trigger.new != null){
        for (Lead_Scoring_Condition__c l : Trigger.new){
            listNewLeadScoringCondition.add(l);
        }
    }

    
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isAfter && Trigger.isInsert) 
    {   
        System.debug('-- Start After Insert Trigger --');
        System.debug(Trigger.new);
        LeadScorConTriggerHandler.handlerAfterInsert(listNewLeadScoringCondition);
        
    }
    // ********   AFTER UPDATE TRIGGER RUN HERE   ********* 
    if(Trigger.isAfter && Trigger.isUpdate) 
    {   
        System.debug('-- Start After Update Trigger --');
        // System.debug(Trigger.new);
        LeadScorConTriggerHandler.handlerAfterUpdate(Trigger.oldMap ,listNewLeadScoringCondition);
        
    } 
}