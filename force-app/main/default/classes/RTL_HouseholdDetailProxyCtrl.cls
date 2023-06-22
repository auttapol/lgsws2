public class RTL_HouseholdDetailProxyCtrl {
    public RTL_Household_Member__c member;
    public RTL_HouseholdDetailProxyCtrl(ApexPages.StandardController std){
        member = (RTL_Household_Member__c)std.getRecord();
        member = [SELECT ID,RTL_Household__c FROM RTL_Household_Member__c WHERE ID=:member.id];
    }
    public PageReference redirectPage(){
        return new PageReference('/apex/RTL_Household_Detail?id='+member.RTL_Household__c);
    }
}