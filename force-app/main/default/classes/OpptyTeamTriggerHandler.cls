public class OpptyTeamTriggerHandler {
    
    public static void getDeletedRecord(Map<Id,OpportunityTeamMember> MapOld){
       List<OpportunityTeamMemberHistory__c> lstOppteams = new List<OpportunityTeamMemberHistory__c>();
        for(Id oppTeamId : MapOld.keySet()){
            OpportunityTeamMember OppTeamObj = MapOld.get(oppTeamId);
            OpportunityTeamMemberHistory__c  tempObj = new OpportunityTeamMemberHistory__c();
            /** Map deleted record from Opportunity Team Member to Opportunity Team Member History **/

            tempObj.OpptyTeamId__c = OppTeamObj.Id;
            tempObj.OpptyId__c = OppTeamObj.OpportunityId;
            tempObj.User__c = OppTeamObj.UserId;
            tempObj.Opportunity_Access__c = OppTeamObj.OpportunityAccessLevel;
            tempObj.Team_Role__c = OppTeamObj.TeamMemberRole;
            tempObj.LastModifiedDate__c = OppTeamObj.LastModifiedDate;
            tempObj.CreatedDate__c = OppTeamObj.CreatedDate;
            tempObj.CreatedBy__c = OppTeamObj.CreatedById; 
            lstOppteams.add(tempObj);   
        }
        insert lstOppteams;
    }
    
}