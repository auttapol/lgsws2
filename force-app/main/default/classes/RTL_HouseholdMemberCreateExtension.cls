public class RTL_HouseholdMemberCreateExtension {
    public RTL_Household_Member__c member{get;set;}
    public RTL_Household__c household{get;set;}
    public Boolean hasError {get;set;}
    
    private String householdId;
    public String tabId{get;set;}
    private PageReference householdDetailPage;
    private Account account;
    
    public RTL_HouseholdMemberCreateExtension(ApexPages.StandardController std){
        member = (RTL_Household_Member__c)std.getRecord();
        householdId = ApexPages.currentPage().getParameters().get('householdId');
        tabId = ApexPages.currentPage().getParameters().get('tabId');
        if(householdId != null) {
            household = queryHousehold(householdId); 
            member.RTL_Household__c = householdId;
        }
        householdDetailPage = new PageReference('/apex/RTL_Household_Detail?id='+householdId);
        householdDetailPage.setRedirect(true);
    }
    
    
    
    public PageReference cancel(){ 
        return householdDetailPage;
    }
    
    public PageReference save(){
        hasError = false;
        try{
            account = queryAccount();
            member.Name = account.Name;
            insert member;
        }catch(DMLException e){
        	return showErrorMessage(e.getDmlMessage(0));
        }catch(Exception e){
        	return showErrorMessage(e.getMessage());
        }
        
        return null;
    }
    
    public RTL_Household__C queryHousehold(String hhId){
        RTL_Household__c hh = [SELECT ID,Name FROM RTL_Household__c WHERE ID=:hhId];
        return hh;
    }
    
    public Account queryAccount(){
        Account acct = [SELECT ID,Name FROM Account WHERE ID=:member.RTL_Household_Member_Name__c];
        return acct;
    }
    
    public PageReference showErrorMessage(String errMsg){
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,errMsg));
        hasError = true;
        return null;
    }
}