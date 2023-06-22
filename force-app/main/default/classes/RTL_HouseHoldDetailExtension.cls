public class RTL_HouseHoldDetailExtension {

    public RTL_HouseHold__c household {get;set;}
    public List<RTL_Household_History_and_Approval__c > historyList {get;set;}
    public List<RTL_Household_Member__c> memberList {get;set;}
    public List<RTL_Household_History_and_Approval__c > approvalList {get;set;}
    public List<RTL_Household_History_and_Approval__c> notNotifiedHistoryList{get;set;}
    public Map<String,RTL_Household_History_Type__mdt> historyTypeMap{get;set;}
    public List<RTL_Household__c> householdList {get;set;} /*use this list to check whether household is still in the system after any history change*/
    public String membId {get;set;}
    public String histId {get;set;}
    public Boolean hasError{get;set;}
    
    private RTL_Household_Member__c primaryMember;
    private String acctId;
    private String templateId;
    private String responseTemplateId;
    public String primaryMemberId {get;set;}
    private Map<Id,RTL_Household_Member__c> memberMap;
    private PageReference householdDetailPage;
    private PageReference customerDetailPage;
    
    public Integer pageSize {get;set;}
    public Integer counter{get;set;}
    public Integer totalSize {
        get
        {
            if(totalSize == null){
                totalSize = 0;
            }
        return totalSize;
        }set;}
    
    public RTL_HouseHoldDetailExtension(ApexPages.StandardController std){ 
        household = (RTL_HouseHold__c)std.getRecord();
        templateId = [select id, name from EmailTemplate where developername = : 'RTL_Household_Approval_Mail_Template'].id;
        responseTemplateId = [select id, name from EmailTemplate where developername = : 'RTL_Household_Approval_Response_Template'].id;
        memberList = new List<RTL_HouseHold_Member__c>();
        approvalList = new List<RTL_Household_History_and_Approval__c >();
        householdDetailPage = new PageReference('/apex/RTL_Household_Detail?id='+household.id);
        householdDetailPage.setRedirect(true);
        historyTypeMap = getHistoryTypeMdt();
     
        if(null != household.id ){
            counter = 0;
            pageSize = Integer.ValueOf(RTL_Household_Pagination__c.getValues('Record Per Page').Page_Max_Size__c);
            household = queryHouseHold();
            historyList = queryHistoryList();
            memberMap = queryMember();
            primaryMember = getPrimaryMember(memberMap);
            primaryMemberId = String.ValueOf(primaryMember.RTL_Household_Member_Name__c).left(15);
            memberList = generateMemberList();
            approvalList = queryApprovalList();
            notNotifiedHistoryList = RTL_HouseholdApprovalResponseEmail.queryNotSentToRequestorHistoryList(household.id);
            customerDetailPage = new PageReference('/'+primaryMemberId);
            customerDetailPage.setRedirect(true);
            
        }
        
    }
    
     
    public PageReference submitForApproval(){
        hasError = false;
        try{
            if(household.RTL_RM__c == null || household.RTL_Approver_UserName__c == null){
                return showErrorMessage(System.Label.RTL_Household_ERR03);
            }
            
            Set<ID> memberIdSet = new Set<ID>();
            Map<Id,RTL_Household_Member__c> memberToUpdate = new Map<Id,RTL_Household_Member__c>();
            List<RTL_Household_History_and_Approval__c> historyToUpdate = new List<RTL_Household_History_and_Approval__c>();
            
            approvalList = queryApprovalList();
            for(RTL_Household_History_and_Approval__c history : approvalList){
                //if History Status = New
                if(history.RTL_Outcome__c == 'New'){       
                    history.RTL_Outcome__c = 'Pending';
                    history.RTL_Approval_Submit_User__c = UserInfo.getUserId();
                    history.RTL_User_Requesting__c = UserInfo.getUserId();
                    historyToUpdate.add(history);
                    //Keep Member Record to be locked
                    if(history.RTL_Household_Member__c != null ){
                        memberIdSet.add(history.RTL_Household_Member__c);               
                    }
                
                }     
            }
            
            if(historyToUpdate.size() > 0){
                update historyToUpdate;        
            }
            
            if(household.RTL_Status__c == 'New'){
                household.RTL_Status__c = 'Awaiting Approval';
            }
            
            update household;
            
            //Start Locking Records
            Approval.LockResult[] lrList = Approval.lock(memberList, false);

            // Iterate through each returned result
            for(Approval.LockResult lr : lrList) {
                if (lr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                    }
                }
            }
        
            Approval.LockResult result = Approval.lock(household, false);
                if (result.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processe
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                    }
                }
            System.debug('Household data ;:: '+household);
        
            //Start Sending Approval Email
            RTL_HouseholdApprovalEmail.SendEmail(household.Id);
        
            return householdDetailPage;
            
        }catch(DMLException e){
            return showErrorMessage(e.getDmlMessage(0));
        }
        catch(Exception e){
            return showErrorMessage(e.getMessage());
        }
    }
    
    public PageReference notifyRequestor(){
        RTL_HouseholdApprovalResponseEmail.SendEmail(household.Id);
        return householdDetailPage;
    }
    
    public PageReference updateHistory(List<RTL_Household_History_and_Approval__c> historyToDelete){
        hasError = false;
        try{
            
            if(historyToDelete.size() > 0){
                delete historyToDelete;
            }
            
            update approvalList;
            
        }catch(DMLException e){
            resetHistoryList();
            return showErrorMessage(e.getDmlMessage(0));
            
        }
        catch(Exception e){
            resetHistoryList();
            return showErrorMessage(e.getMessage());
        }
        //Check if household is still exists
        householdList = getHouseholdList();
        
        return null;
    }
    
    //Approve All Pending History
    public PageReference approveAll(){
        Set<Id> historyIdSet = new Set<Id>();
        Set<Id> memberIdSet = new Set<Id>();
        List<RTL_Household_History_and_Approval__c> historyToDelete = new List<RTL_Household_History_and_Approval__c>();
        for(RTL_Household_History_and_Approval__c history : approvalList){
            if(history.RTL_Outcome__c == 'Pending'){
                history.RTL_Outcome__c = 'Approved';
                
                if(history.RTL_Field_Label__c == 'Delete Member' && history.RTL_New_Value__c == 'true' && history.RTL_Household_Member__c != null){
                    historyIdSet.add(history.id);
                    memberIdSet.add(history.RTL_Household_Member__c);
                    
                }
            
            }
    
        }
        historyToDelete = [SELECT ID,Name FROM RTL_Household_History_and_Approval__c 
                                            WHERE (RTL_Outcome__c = 'New' OR RTL_Outcome__c = 'Pending') 
                                            AND ID NOT IN:historyIdSet
                                            AND RTL_Household_Member__c IN:historyIdSet];
        
        return updateHistory(historyToDelete);
        
    }
    
    //Reject All Pending History
     public PageReference rejectAll(){
        for(RTL_Household_History_and_Approval__c history : approvalList){
            if(history.RTL_Outcome__c == 'Pending'){
                history.RTL_Outcome__c = 'Rejected';
            }
            
        }
        return updateHistory(new List<RTL_Household_History_and_Approval__c>());
        
    }
    
    public Boolean getIsHouseholdEditable(){
        if(UserInfo.getUserId() == household.RTL_RM__r.ManagerId){
            return false;
        }
        if(household.RTL_Status__c == 'Deleted'){
            return false;
        }
        if(approvalList.size() > 0 ){
            if(UserInfo.getUserId() == approvalList[0].CreatedById || UserInfo.getUserId() == household.RTL_RM__c){
                return true;
            }
            return false;
        }
         return true;
    }
    
    public PageReference requestDelete(){
        approvalList = queryApprovalList();
        if(approvalList.size() >0 ){
            return showErrorMessage(System.Label.RTL_Household_ERR08);
        }
        household.RTL_To_Delete__c = true;
        update household;
        
        historyList = queryHistoryList();
        approvalList = queryApprovalList();
        return submitForApproval();
        
    }
    
    public PageReference requestDeleteMember(){
        RTL_Household_Member__c membToDelete = memberMap.get(membId);
        membToDelete.RTL_To_Delete__c = true;
        update membToDelete;
        return HouseholdDetailPage;
    }
    
    public PageReference deleteHistory(){
        hasError = false;
        try{  
            RTL_Household_History_and_Approval__c histToDelete;
            for(RTL_Household_History_and_Approval__c hist : approvalList){
                if(hist.id == histId){
                    histToDelete = hist;
                }
            }
            
            delete histToDelete;
            householdList = getHouseholdList();
        }catch(DMLException e){
            resetHistoryList();
            return showErrorMessage(e.getDmlMessage(0));
            
        }
        catch(Exception e){
            resetHistoryList();
            return showErrorMessage(e.getMessage());
        }
        //List<RTL_Household__c> householdList = [SELECT ID,Name FROM RTL_Household__c WHERE ID IN:householdIdSet];
        //if(householdList.size() == 0){
            //return CustomerDetailPage;
        //}
        return null;
        //return HouseholdDetailPage;
    }
    
    public Boolean getIsHouseholdRecordLocked(){
        return Approval.isLocked(household.id);
    }
    
    public void resetHistoryList(){
        historyList = queryHistoryList();
    }
    
    public RTL_HouseHold__c queryHouseHold(){
        RTL_HouseHold__c hh;
        hh =  [SELECT Name,RTL_RM__c,RTL_RM__r.ManagerId,RTL_Benefit_Package__c,
                      RTL_Approver_UserName__c,RTL_Status__c,RTL_Number_of_Members__c,RTL_Remarks__c,
                      RTL_Sent_To_Approval__c,CreatedById,RTL_RM__r.Name,
               (SELECT ID FROM Household_History_and_Approvals__r WHERE RTL_Outcome__c = 'New') 
               FROM RTL_HouseHold__C 
               WHERE ID=:household.id];
        return hh;
    }
    
    public List<RTL_Household_History_and_Approval__c> queryHistoryList(){
        List<RTL_Household_History_and_Approval__c> history;
        System.debug('COUNTER : '+counter);
        history = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__c ,RTL_Prev_Value__c ,
                       RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                        RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c,
                        RTL_Section__c,RTL_Sent_to_Requestor__c,RTL_User_Requesting__r.Name, 
                       RTL_Approver_Link__c, RTL_Approver_Link__r.Name,RTL_Member_Lookup_Account__c,RTL_Member_Lookup_Account__r.Name
                   FROM RTL_Household_History_and_Approval__c  
                   WHERE RTL_Household__c =: household.id LIMIT :pageSize OFFSET :counter];
        totalSize = [SELECT count() FROM RTL_Household_History_and_Approval__c WHERE RTL_Household__c =: household.id];
        return history;
    }
    
    public Map<Id,RTL_Household_Member__c> queryMember(){
        Map<Id,RTL_Household_Member__c> member;
        member = new Map<Id,RTL_Household_Member__c>([SELECT ID,Name,RTL_Household_Member_Name__c,RTL_TMB_Customer_ID_PE__c,
                                                      RTL_Primary__c,RTL_Benefit__c,RTL_Relationship__c,RTL_Status__c,RTL_Is_Approved__c,
                                                      RTL_To_Delete__c,RTL_Household_Member_Name__r.Name
                                                      FROM RTL_Household_Member__c  
                                                      WHERE RTL_Household__c =: household.id ORDER BY RTL_Primary__c DESC]);
        return member;
    }
    
    //put member into list  
    public List<RTL_Household_Member__c> generateMemberList(){
        List<RTL_Household_Member__c> membList = new List<RTL_HouseHold_Member__c>();
        for(RTL_Household_Member__c member : memberMap.values()){
            if(member.RTL_Is_Approved__c == true){
                membList.add(member);
            }
        }
        return membList;
    }
    
    public RTL_Household_Member__c getPrimaryMember(Map<Id,RTL_Household_Member__c> membMap){
        RTL_Household_Member__c primaryMemb;
        for(RTL_Household_Member__c memb : membMap.values()){
            if(memb.RTL_Primary__c == true){
                primaryMemb = memb;
            }
        }
        return primaryMemb;
    }
    
    public List<RTL_Household_History_and_Approval__c> queryApprovalList(){
        List<RTL_Household_History_and_Approval__c> apprvList;
        apprvList = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__c ,RTL_Prev_Value__c ,
                       RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                        RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c,
                        RTL_Section__c,RTL_Sent_to_Requestor__c,RTL_User_Requesting__r.Name,RTL_Approver_Link__c,
                        CreatedById,RTL_Member_Lookup_Account__c,RTL_Member_Lookup_Account__r.Name
                   FROM RTL_Household_History_and_Approval__c  
                   WHERE RTL_Outcome__c != 'Approved' AND RTL_Outcome__c != 'Rejected' 
                   AND RTL_Household__c =: household.id];
        return apprvList;
    }
    
    public PageReference showErrorMessage(String errMsg){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errMsg));
        hasError = true;
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      historyList = queryHistoryList();
      return null;
   }
    
    public PageReference  Next() { //user clicked next button
      counter += pageSize;
      historyList = queryHistoryList();
      return null;
   }
    
    public PageReference First(){
        counter = 0;
        historyList = queryHistoryList();
        return null;
    }
    
    public PageReference Last(){
        Decimal page = ((Decimal)totalSize/(Decimal)pageSize);
        Integer LastPage = Integer.ValueOf(page.round(System.RoundingMode.CEILING));
        counter = (LastPage-1) * pageSize;
        historyList = queryHistoryList();
        return null;
    }
    
    public boolean  getDisableNext() { //user clicked next button   
        if((counter + pageSize) >= totalSize) {
            return true;
        }else{
            return false;
        }
   }
    
    public boolean  getDisablePrevious() { //user clicked next button     
        if(counter == 0) {
            return true;
        }else{
            return false;
        }
    }
    
    //This method used to check if the Household is still exists in the database
    public List<RTL_Household__c> getHouseholdList(){
        Set<Id> householdIdSet = new Set<Id>{household.id};
        List<RTL_Household__c> householdList = new List<RTL_Household__c>();
        householdList = [SELECT ID,Name FROM RTL_Household__c WHERE ID IN:householdIdSet];
        return householdList;
    }
    
    public Map <String,RTL_Household_History_Type__mdt > getHistoryTypeMdt(){
        Map <String,RTL_Household_History_Type__mdt > historyTypeMap = new Map <String,RTL_Household_History_Type__mdt >();
        
        for(RTL_Household_History_Type__mdt historyType : [SELECT Id,MasterLabel ,DeveloperName ,RTL_English_Value__c , RTL_Thai_Value__c FROM RTL_Household_History_Type__mdt ]){
            historyTypeMap.put(historyType.RTL_English_Value__c,historyType);
            historyTypeMap.put(historyType.RTL_Thai_Value__c,historyType);
        }
        return historyTypeMap;
    }

}