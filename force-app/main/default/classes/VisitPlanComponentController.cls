public with sharing class VisitPlanComponentController {
	@AuraEnabled        
    public static void insertVisitPlan(Id visitplan,List<Visit_Plan_Invitee__c> invitee,Id oppid) {
        System.debug('visitplan.Id:'+visitplan);
        List<Visit_Plan_Invitee__c> insertInvitee = new List<Visit_Plan_Invitee__c>();
        Integer index = 0;
        for(Visit_Plan_Invitee__c invited : invitee){
            if(invited.TMB_Person__c != null ){
                
                invited.Visit_Plan_Report__c = visitplan;
                invited.SEQ__c = index;
                insertInvitee.add(invited);
                index = index + 1;
            }
        }
        System.debug('insertInvitee:'+insertInvitee);
        insert insertInvitee;
        System.debug('oppid:'+oppid);
        if(oppid != null ){
            Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c ();
            visitopp.Customer__c = visitplan;
            visitopp.Opportunity__c = oppid;
            insert visitopp;
        }
    }

    @AuraEnabled
    public static List<Visit_Plan_Invitee__c> getInvitee(Id recordId){
        List<Visit_Plan_Invitee__c> invitee = [SELECT TMB_Person__c,SEQ__c,Visit_Plan_Report__c FROM Visit_Plan_Invitee__c WHERE Visit_Plan_Report__c =: recordId ORDER BY SEQ__C ASC];
        return invitee;
    }

    @AuraEnabled
    public static void updateInvitee(List<Visit_Plan_Invitee__c> invitee,List<Visit_Plan_Invitee__c> old_invitee,Id recordId){
        List<Visit_Plan_Invitee__c> upsertInvitee = new List<Visit_Plan_Invitee__c>();
        Integer index = 0;
        for(Visit_Plan_Invitee__c invited : invitee){
            if(invited.TMB_Person__c != null ){
                System.debug('invited:'+invited);
                if(invited.Visit_Plan_Report__c == null){
                    invited.Visit_Plan_Report__c = recordId;
                }
                invited.SEQ__c = index;
                upsertInvitee.add(invited);
                index = index + 1;
            }
        }
        
        if( upsertInvitee.size() >= old_invitee.size() ){
            for(Integer i=0;i<old_invitee.size();i++){
                upsertInvitee[i].Id = old_invitee[i].Id;
            }
            
            upsert upsertInvitee;
        } else {

            List<Visit_Plan_Invitee__c> removeInvitee = new List<Visit_Plan_Invitee__c>();
            for(Integer i=0;i<old_invitee.size();i++){
                if( i < upsertInvitee.size()){
                    upsertInvitee[i].Id = old_invitee[i].Id;
                } else {
                    removeInvitee.add(old_invitee[i]);
                }
            }
            upsert upsertInvitee;
            delete removeInvitee;
        }
        
    }
}