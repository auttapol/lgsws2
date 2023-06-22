public class RTL_HouseholdRelatedListProxyCtrl {
    public RTL_Household_Member__c member;
    public String prefix;
    public String rlid;
    public String parentID;
    private String acctId;
        
    public RTL_HouseholdRelatedListProxyCtrl(ApexPages.StandardController std){
        member = (RTL_Household_Member__c)std.getRecord();
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        Schema.DescribeSObjectResult r = RTL_Household_Member__c.sObjectType.getDescribe();
        //get prefix
        prefix = r.getKeyPrefix();
        
        //get related list ID from custom setting
        RTL_HHM_RLID__c hhmrlid = RTL_HHM_RLID__c.getValues('ID');
        rlid = hhmrlid.RTL_RLID__c;
        
        //get the ID of the parent record
        parentID = member.RTL_Household_Member_Name__r.Id;
    }
    public PageReference redirectPage(){
        return new PageReference('/'+prefix+'?rlid='+rlid+'&id='+acctId+'&lsi=-2');
    }

}