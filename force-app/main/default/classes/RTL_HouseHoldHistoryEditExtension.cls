public class RTL_HouseHoldHistoryEditExtension {

    public RTL_Household_History_and_Approval__c history {get;set;}
    public Boolean hasError {get;set;}
    public String householdTabId {get;set;}
    
    private PageReference householdDetailPage;
    private PageReference customerDetailPage;
    private RTL_Household_Member__c primaryMember;
    private String primaryMemberId;
    private List<RTL_Household_History_and_Approval__c> historyToDelete;
    private String oldStatus;
    
    public RTL_HouseHoldHistoryEditExtension(ApexPages.StandardController std){
        history = (RTL_Household_History_and_Approval__c)std.getRecord();
        history = [SELECT ID,Name,RTL_Field_Label__c,RTL_Household__c,RTL_Field_Changed__c,
                          RTL_Household_Member__c,RTL_Prev_Value__c,RTL_User_Requesting__c,
                          RTL_New_Value__c,RTL_Outcome__c,RTL_Date_Requested__c,
                          RTL_Date_Approved__c,RTL_Household__r.RTL_Status__c,
                          RTL_Household__r.Name,RTL_Household_Member__r.Name,
                          RTL_User_Requesting__r.Name,RTL_Member_Lookup_Account__c,RTL_Member_Lookup_Account__r.Name,
                          RTL_Field_Label_Display__c,RTL_Section__c,RTL_HHM_Benefit__c ,
                          RTL_HH_Req_Benefit_Package__c ,RTL_HH_Req_Remarks__c ,RTL_HH_RM_BM__c , RTL_HHM_Relationship__c,
                   		  RTL_HH_RM_BM__r.Name
                   FROM RTL_Household_History_and_Approval__c WHERE Id=:history.id];
        oldStatus = history.RTL_Outcome__c;
        primaryMember = getPrimaryMember(history.RTL_Household__c);
        primaryMemberId = String.ValueOf(primaryMember.RTL_Household_Member_Name__c).left(15);
        householdDetailPage = new PageReference('/apex/RTL_Household_Detail?id='+history.RTL_Household__c);
        householdDetailPage.setRedirect(true);
        customerDetailPage = new PageReference('/'+primaryMemberId);
        customerDetailPage.setRedirect(true);
        historyToDelete = new List<RTL_Household_History_and_Approval__c>();
        householdTabId = ApexPages.currentPage().getParameters().get('tabId');
       
    }
    
    public PageReference save(){
        hasError = false;
        try{
            System.debug('Field Label ::: '+history.RTL_Field_Label__c);
            System.debug('HH Status ::: '+history.RTL_Household__r.RTL_Status__c);
            if(oldStatus != history.RTL_Outcome__c){
                if(history.RTL_Field_Label__c == 'New Member' && history.RTL_Household__r.RTL_Status__c != 'Approved' && history.RTL_Outcome__c == 'Approved'){
                    System.debug('THROW ERROR HERE');
                    return showErrorMessage(System.Label.RTL_Household_ERR04);
                }
                if(history.RTL_Field_Label__c == 'Delete Member' && history.RTL_Outcome__c == 'Approved' && history.RTL_New_Value__c == 'true' && history.RTL_Household_Member__c != null){
                    historyToDelete = [SELECT ID,Name FROM RTL_Household_History_and_Approval__c 
                                        WHERE (RTL_Outcome__c = 'New' OR RTL_Outcome__c = 'Pending')
                                        AND id !=: history.id
                                        AND RTL_Household_Member__c =:history.RTL_Household_Member__c];
                }
            
                if(historyToDelete.size() > 0){
                    delete historyToDelete;
                }
                update history;
            }
           
        }catch(DMLException e){
            return showErrorMessage(e.getDmlMessage(0));
        }
        catch(Exception e){
            return showErrorMessage(e.getMessage());
        }
        Set<Id> householdIdSet = new Set<Id>{history.RTL_Household__c};
        List<RTL_Household__c> householdList = [SELECT ID,Name FROM RTL_Household__c WHERE ID IN:householdIdSet];
        return null;
        /*if(householdList.size() == 0){
            return customerDetailPage;
        }
        return householdDetailPage;*/
    }
    
    public RTL_Household_Member__c getPrimaryMember(String householdId){
        RTL_Household_Member__c member = [SELECT ID,Name,RTL_Household_Member_Name__c 
                                          FROM RTL_Household_Member__c WHERE RTL_Household__c =:householdId
                                          AND RTL_Primary__c = true];
        return member;
    }
    
    public PageReference showErrorMessage(String errMsg){
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,errMsg));
        hasError = true;
        return null;
    }
}