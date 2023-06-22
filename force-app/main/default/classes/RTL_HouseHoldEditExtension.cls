public class RTL_HouseHoldEditExtension {

    public RTL_Household__c household{get;set;}
    
    private PageReference householdDetailPage;
    private String oldBenefitPackage;
    private String oldRemarks;
    
    public RTL_HouseHoldEditExtension(ApexPages.StandardController std){
        household = (RTL_Household__c)std.getRecord();
        household = [SELECT Id,Name,RTL_Benefit_Package__c,RTL_Remarks__c,RTL_RM__c,RTL_RM__r.Name,RTL_RM__r.ManagerId,RTL_Approver_UserName__c FROM RTL_Household__c WHERE ID=:household.id];
        oldBenefitPackage = household.RTL_Benefit_Package__c;
        oldRemarks = household.RTL_Remarks__c;
        householdDetailPage = new PageReference('/apex/RTL_Household_Detail?id='+household.id);
        householdDetailPage.setRedirect(true);
    }
    
    public PageReference save(){
         try{
             
             if(oldBenefitPackage != household.RTL_Benefit_Package__c || oldRemarks != household.RTL_Remarks__c){
                 update household;
             }
            
         
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
            return null;           
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        return householdDetailPage;
    }
}