public without sharing class RTL_HouseHoldUtils extends AbstractCoreClass {
  
    @AuraEnabled
    public static Object getDescribeFieldResultAndValue(String recordId, String sObjectName, List<String> fields) {
       return AbstractCoreClass.getDescribeFieldResultAndValue(recordId, sObjectName, fields);
    }

    @AuraEnabled
    public static Object getDescribeFieldResult(String sObjectName, List<String> fields) {
        return AbstractCoreClass.getDescribeFieldResult(sObjectName, fields);
    }

    @AuraEnabled
    public static Object getQueryDatabase(List<String> fields, String sObjectName, String filter) {
        return AbstractCoreClass.getQueryDatabase(fields, sObjectName, filter);
    }

    @AuraEnabled
    public static Object getReference(Id recordId) {
        return AbstractCoreClass.getReference(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getRecordPerPage() {
        return Integer.ValueOf(
            RTL_Household_Pagination__c.getValues('Record Per Page') != null ? 
            RTL_Household_Pagination__c.getValues('Record Per Page').Page_Max_Size__c : 10
        );
    }

    @AuraEnabled
    public static Boolean getIsHouseholdRecordLocked(Id householdId) {
        return Approval.isLocked(householdId);
    }

    @AuraEnabled
    public static Object initialCreateHouseHold(Id accountId) {
        String BranchManagerTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager').RTL_Value__c;
        Account accountObj = [SELECT Id, Name, First_Name_PE__c, Last_Name_PE__c, RTL_Wealth_RM__c, RTL_RM_Name__c, RTL_Assigned_BRC__r.Employee_ID__c FROM Account WHERE Id = :accountId LIMIT 1];
        List<RTL_Household_Number_Store__c> householdNumberStores = [SELECT ID, Name, RTL_Number__c FROM RTL_Household_Number_Store__c WHERE RTL_Account__c =:accountId LIMIT 1];
        String EmpBrCode = accountObj.RTL_RM_Name__c;
        EmpBrCode =  UserInfo.getUserId() == accountObj.RTL_Wealth_RM__c ? EmpBrCode : accountObj.RTL_Assigned_BRC__r.Employee_ID__c;
        List<User> rmUserList = new List<User>();
        //If it is branch code
        if (EmpBrCode != null && EmpBrCode.startsWith('00')) {
            EmpBrCode = EmpBrCode.substring(2);
            rmUserList = [SELECT Id, Name, ManagerId, Manager.Name FROM User 
                            WHERE RTL_Branch_Code__c = :EmpBrCode 
                            AND RTL_Branch_Code__c  != null 
                            AND IsActive = true
                            AND title = :BranchManagerTitle];
        } else {
            rmUserList = [SELECT Id, Name, ManagerId, Manager.Name FROM User WHERE Employee_ID__c  = :EmpBrCode 
                            AND Employee_ID__c != null 
                            AND IsActive = true];
        }

        if(householdNumberStores.size() > 0) { 
            householdNumberStores.get(0).RTL_Number__c += 1;
        }
        Decimal runningNumber = householdNumberStores.size() > 0 ? householdNumberStores.get(0).RTL_Number__c : 1;

        String HouseHoldName = accountObj.Last_Name_PE__c == null ? accountObj.First_Name_PE__c : String.format('{0} {1}', new List<String>{ accountObj.Last_Name_PE__c, accountObj.First_Name_PE__c });
        HouseHoldName = HouseHoldName + ' ' + String.valueOf(runningNumber).leftPad(3).replace(' ', '0');
        RTL_HouseHold__c household = new RTL_HouseHold__c(
            Name = HouseHoldName,
            RTL_Household_Name_Duplicate_Checker__c = HouseHoldName,
            RTL_RM__c = rmUserList.size() > 0 ? rmUserList.get(0).Id : null
            // RTL_Approver_UserName__c = rmUserList.size() > 0 ? rmUserList.get(0).ManagerId : null
        );

        RTL_HouseHold_Member__c householdMember = new RTL_HouseHold_Member__c(
            Name = accountObj.Name,
            RTL_Primary__c = true,
            RTL_Benefit__c = true,
            RTL_Household_Member_Name__c = accountObj.Id
        );

        return new Map<String, SObject>{
            'RTL_HouseHold__c' => household,
            'RTL_HouseHold_Member__c' => householdMember,
            'RTL_Household_Number_Store__c' => householdNumberStores.size() > 0 ? householdNumberStores.get(0) : new RTL_Household_Number_Store__c(RTL_Number__c=1, RTL_Account__c=accountObj.Id),
            'User' => rmUserList.size() > 0 ? rmUserList.get(0) : new User()
        };
    }


    @AuraEnabled
    public static Object saveHousehold(Map<String, Object> householdObject) {
        String errorMessage = '';
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            System.debug(JSON.serializePretty(householdObject));

            // Household Object
            RTL_HouseHold__c household = (RTL_HouseHold__c)JSON.deserialize(JSON.serialize(householdObject.get('RTL_HouseHold__c')), RTL_HouseHold__c.class);
            insert household;

            // Household Number Store
            RTL_Household_Number_Store__c householdNumberStore = (RTL_Household_Number_Store__c)JSON.deserialize(JSON.serialize(householdObject.get('RTL_Household_Number_Store__c')), RTL_Household_Number_Store__c.class);
            upsert householdNumberStore;

            // Household Member
            RTL_HouseHold_Member__c householdMember = (RTL_HouseHold_Member__c)JSON.deserialize(JSON.serialize(householdObject.get('RTL_HouseHold_Member__c')), RTL_HouseHold_Member__c.class);
            householdMember.RTL_Household__c = household.Id;
            householdMember.RTL_Status__c = 'New';
            insert householdMember;

            return new Map<String, Object>{
                'success' => true,
                'RTL_HouseHold__c' => household
            };
        } catch (Exception e) {
            Database.rollback(sp);
            errorMessage += String.format('\n{0}\n{1}', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            });
            System.debug(errorMessage);
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static String requestDeleteMember(Id householdMemberId) {
        RTL_Household_Member__c membToDelete = new RTL_Household_Member__c(Id = householdMemberId);
        membToDelete.RTL_To_Delete__c = true;
        update membToDelete;
        return Label.PDPA_Update_Success;
    }
    
    @AuraEnabled
    public static String deleteHouseholdHistoryApproval(Id householdHistoryApprovalId) {
        String errorMessage = '';
        try {
            RTL_Household_History_and_Approval__c historyApprovalToDelete = new RTL_Household_History_and_Approval__c(Id = householdHistoryApprovalId);
            delete historyApprovalToDelete;
            return Label.PDPA_Update_Success;
        } 
        // catch(DMLException e) {
        //     throw new AuraHandledException(e.getDmlMessage(0));
        // }
        catch (Exception e) {
            errorMessage += String.format('\n{0}\n{1}', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            });
            System.debug(errorMessage);
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static String householdAction(Object householdInfo, Object memberListInfo, Object approvalListInfo, String actionType) {
        RTL_HouseHold__c household = ((List<RTL_HouseHold__c>)getQueryDatabase(
            getFieldsObject((List<Object>)getResult('fields', householdInfo)),
            (String)getResult('sObjectName', householdInfo),
            (String)getResult('filter', householdInfo)
        )).get(0);
        List<RTL_Household_Member__c> memberList = (List<RTL_Household_Member__c>)getQueryDatabase(
            getFieldsObject((List<Object>)getResult('fields', memberListInfo)),
            (String)getResult('sObjectName', memberListInfo),
            (String)getResult('filter', memberListInfo)
        );
        List<RTL_Household_History_and_Approval__c> approvalList = (List<RTL_Household_History_and_Approval__c>)getQueryDatabase(
            getFieldsObject((List<Object>)getResult('fields', approvalListInfo)),
            (String)getResult('sObjectName', approvalListInfo),
            (String)getResult('filter', approvalListInfo)
        );

        if(actionType == 'RequestDelete') {
            return requestHouseholdDelete(household, memberList, approvalListInfo);
        } else if (actionType == 'SubmitForApproval') {
            return submitHouseholdForApproval(household, memberList, approvalList);
        } else if (actionType == 'approveAll') {
            return approveAll(approvalList);
        } else if (actionType == 'rejectAll') {
            return rejectAll(approvalList);
        } else {
            return 'No action';
        }
    }
    
    @AuraEnabled
    public static String requestHouseholdDelete(RTL_HouseHold__c household, List<RTL_Household_Member__c> memberList, Object approvalListInfo) {
        try {
            List<RTL_Household_History_and_Approval__c> approvalList = (List<RTL_Household_History_and_Approval__c>)getQueryDatabase(
                getFieldsObject((List<Object>)getResult('fields', approvalListInfo)),
                (String)getResult('sObjectName', approvalListInfo),
                (String)getResult('filter', approvalListInfo)
            );

            if(approvalList.size() > 0) {
                throw new AuraHandledException(Label.RTL_Household_ERR08);
            }
    
            household.RTL_To_Delete__c = true;
            update household;
            
            approvalList = (List<RTL_Household_History_and_Approval__c>)getQueryDatabase(
                getFieldsObject((List<Object>)getResult('fields', approvalListInfo)),
                (String)getResult('sObjectName', approvalListInfo),
                (String)getResult('filter', approvalListInfo)
            );
            return submitHouseholdForApproval(household, memberList, approvalList);
        } 
        catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            throw e;
        }
    }

    private static List<String> getFieldsObject(List<Object> fields) {
        List<String> tempFields = new List<String>();
        for (Object f : fields) {
            tempFields.add((String)f);
        }
        return tempFields;
    }

    @AuraEnabled
    public static String submitHouseholdForApproval(RTL_HouseHold__c household, List<RTL_Household_Member__c> memberList, List<RTL_Household_History_and_Approval__c> approvalList) {       
        try{
            if(household.RTL_RM__c == null || household.RTL_Approver_UserName__c == null) {
                throw new AuraHandledException(System.Label.RTL_Household_ERR03);
            }
            
            Set<ID> memberIdSet = new Set<ID>();
            Map<Id,RTL_Household_Member__c> memberToUpdate = new Map<Id,RTL_Household_Member__c>();
            List<RTL_Household_History_and_Approval__c> historyToUpdate = new List<RTL_Household_History_and_Approval__c>();
            
            for(RTL_Household_History_and_Approval__c history : approvalList) {
                
                //if History Status = New
                if(history.RTL_Outcome__c == 'New') {       
                    history.RTL_Outcome__c = 'Pending';
                    history.RTL_Approval_Submit_User__c = UserInfo.getUserId();
                    history.RTL_User_Requesting__c = UserInfo.getUserId();
                    historyToUpdate.add(history);

                    //Keep Member Record to be locked
                    if(history.RTL_Household_Member__c != null ) {
                        memberIdSet.add(history.RTL_Household_Member__c);               
                    }
                
                }     
            }
            
            if(historyToUpdate.size() > 0) {
                update historyToUpdate;        
            }
            
            if(household.RTL_Status__c == 'New') {
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
            if (!Test.isRunningTest()) RTL_HouseholdApprovalEmail.SendEmail(household.Id);
        
            return Label.PDPA_Update_Success;
        }
        catch(DMLException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch(Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static string approveAll(List<RTL_Household_History_and_Approval__c> approvalList){
        try {
            Set<Id> historyIdSet = new Set<Id>();
            for(RTL_Household_History_and_Approval__c history : approvalList){
                if(history.RTL_Outcome__c == 'Pending'){
                    history.RTL_Outcome__c = 'Approved';
                    if(history.RTL_Field_Label__c == 'Delete Member' && 
                        history.RTL_New_Value__c == 'true' && 
                        history.RTL_Household_Member__c != null) {
                        historyIdSet.add(history.Id);
                    }
                }
            }
            List<RTL_Household_History_and_Approval__c> historyToDelete = [
                SELECT Id 
                FROM RTL_Household_History_and_Approval__c 
                WHERE (RTL_Outcome__c = 'New' OR RTL_Outcome__c = 'Pending') AND
                    Id NOT IN :historyIdSet AND 
                    RTL_Household_Member__c IN :historyIdSet];
                                            
    
            if(historyToDelete.size() > 0){
                delete historyToDelete;
            }
            update approvalList;
                
            return Label.PDPA_Update_Success;
        } catch(DMLException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string rejectAll(List<RTL_Household_History_and_Approval__c> approvalList){
        try {
            for (RTL_Household_History_and_Approval__c history : approvalList) {
                if (history.RTL_Outcome__c == 'Pending') {
                    history.RTL_Outcome__c = 'Rejected';
                }
            }                
            update approvalList;
            
            return Label.PDPA_Update_Success;
        } catch(DMLException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void notifyRequestor(Id householdId) {
        RTL_HouseholdApprovalResponseEmail.SendEmail(householdId);
    }

    @AuraEnabled
    public static string saveHouseholdhistory(String oldOutcome, String newOutcome, Id historyRecordId) {
        try{
            List<RTL_Household_History_and_Approval__c> historyToDelete = new List<RTL_Household_History_and_Approval__c>();
            RTL_Household_History_and_Approval__c history = [
                SELECT Id, RTL_Outcome__c, RTL_Field_Label__c, RTL_Household__c, RTL_Household__r.RTL_Status__c, 
                RTL_New_Value__c, RTL_Household_Member__c FROM RTL_Household_History_and_Approval__c WHERE Id = :historyRecordId
            ];
            history.RTL_Outcome__c = newOutcome;
            
            if(oldOutcome != history.RTL_Outcome__c) {

                if(history.RTL_Field_Label__c == 'New Member' && history.RTL_Household__r.RTL_Status__c != 'Approved' && history.RTL_Outcome__c == 'Approved'){
                    throw new AuraHandledException(System.Label.RTL_Household_ERR04);
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

            return Label.PDPA_Update_Success;
        }catch(DMLException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch(Exception e){
            throw e;
        }
    }
}