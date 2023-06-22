public class RTL_HouseholdMemberEditExtension {
    public RTL_Household_Member__c member{get;set;}
    public Boolean hasError {get;set;}
    public String householdTabId {get;set;}
    
    private Boolean oldBenefit;
    private String oldRelationship;

    private PageReference householdDetailPage;
    
    public RTL_HouseholdMemberEditExtension(ApexPages.StandardController std){
        member = (RTL_Household_Member__c)std.getRecord();
        member = [SELECT ID,Name,RTL_Primary__c,RTL_Household__c,RTL_Benefit__c,RTL_Relationship__c, RTL_Household_Member_Name__c,RTL_Household__r.Name  FROM RTL_Household_Member__c WHERE id=:member.id];
        householdDetailPage = new PageReference('/apex/RTL_Household_Detail?id='+member.RTL_Household__c);
        householdDetailPage.setRedirect(true);
        householdTabId = ApexPages.currentPage().getParameters().get('tabId');
        oldBenefit = member.RTL_Benefit__c;
        oldRelationship = member.RTL_Relationship__c;
    }
        
    public PageReference cancel(){ 
        return householdDetailPage;
    }
    
    public PageReference save(){
        hasError = false;
        try{
            if(oldBenefit != member.RTL_Benefit__c || oldRelationship != member.RTL_Relationship__c){
                update member;
            }
            
        }catch(DMLException e){
        	return showErrorMessage(e.getDmlMessage(0));
        }catch(Exception e){
        	return showErrorMessage(e.getMessage());
        }
        return null;
    }
    
    public PageReference showErrorMessage(String errMsg){
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,errMsg));
        hasError = true;
        return null;
    }
}