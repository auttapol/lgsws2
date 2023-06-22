public class QCA_LeadSimplifiedController {
    public QCA_LeadSimplifiedController() {

    }
    public class RecordTypeWrapper {
        @AuraEnabled
        public Id RecordTypeLead {get; set;}
        @AuraEnabled
        public Id RecordTypeVisitPlanReport {get; set;}
        @AuraEnabled
        public Id RecordTypeTask {get; set;}
        @AuraEnabled
        public Id RecordTypeOpportunity {get; set;}
    }

    public static Id TaskRecordTypeId {
        get {
            if (TaskRecordTypeId == null) {
               TaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task Record type').getRecordTypeId();
            }
            return TaskRecordTypeId;
        }
        set;
    }
    public static Id VisitPlanforLeadRecordTypeId {
        get {
            if (VisitPlanforLeadRecordTypeId == null) {
               VisitPlanforLeadRecordTypeId = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByName().get('Visit Plan for Lead').getRecordTypeId();
            }
            return VisitPlanforLeadRecordTypeId;
        }
        set;
    }
    public static Id CommercialLeadRecordTypeId {
        get {
            if (CommercialLeadRecordTypeId == null) {
               CommercialLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
            }
            return CommercialLeadRecordTypeId;
        }
        set;
    }
    public static Id CommercialAccountRecordTypeId {
        get {
            if (CommercialAccountRecordTypeId == null) {
               CommercialAccountRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
            }
            return CommercialAccountRecordTypeId;
        }
        set;
    }
    public static Id CommercialCompletedRecordTypeId {
        get {
            if (CommercialCompletedRecordTypeId == null) {
               CommercialCompletedRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Completed').getRecordTypeId();
            }
            return CommercialCompletedRecordTypeId;
        }
        set;
    }

    public static Id ExistingCustomerRecordTypeId {
        get {
            if (ExistingCustomerRecordTypeId == null) {
               ExistingCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
            }
            return ExistingCustomerRecordTypeId;
        }
        set;
    }
    public static Id ProspectRecordTypeId {
        get {
            if (ProspectRecordTypeId == null) {
               ProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            }
            return ProspectRecordTypeId;
        }
        set;
    }
    public static Id SECreditProductRecordTypeId {
        get {
            if (SECreditProductRecordTypeId == null) {
               SECreditProductRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
            }
            return SECreditProductRecordTypeId;
        }
        set;
    }

    @AuraEnabled
    public static RecordTypeWrapper getRecordTypeSimplifiedLead() {
        RecordTypeWrapper recordTypeLead = new RecordTypeWrapper();
        recordTypeLead.RecordTypeLead = CommercialLeadRecordTypeId;
        recordTypeLead.RecordTypeVisitPlanReport = VisitPlanforLeadRecordTypeId;
        recordTypeLead.RecordTypeTask = TaskRecordTypeId;
        recordTypeLead.RecordTypeOpportunity = SECreditProductRecordTypeId;
        return recordTypeLead;
    }
    @AuraEnabled
    public static String getDeepLink(){
        return Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
    }

    @AuraEnabled
    public static List<SmartBDM_PicklistOption> getLeadFieldValues(String FieldAPIName)
    {
        return SmartBDM_PicklistDescriber.describe('Lead', QCA_LeadSimplifiedController.CommercialLeadRecordTypeId, FieldAPIName);
    }
    
    @AuraEnabled
    public static Lead getMyLeadInforamtion(Id leadObjId){
        try {
            return [SELECT Id, Name, Unqualified_Reasons__c, Remark__c, RecordType.Name, MobilePhone, Phone, Primary_Campaign__c, Customer_Type__c, Salutation, FirstName, LastName, company, Customer_Name_EN__c, ID_Type__c, ID_Number__c, Exception_Flag__c, OwnerID, Contacted_Flag__c, Interest_result__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ext__c, email, Email__c, RecordTypeId, Mobile_No__c, Office_No__c ,Unqualified_Action__c, Parent_Company__c, Total_Expected_Revenue__c, LeadSource, Other_Source__c, Preferred_Branch__c, Branch_Referred__c, Referral_Staff_ID__c, Referral_Staff_Name__c, Rating, Industry__c, Account__c, Account__r.OwnerID, Account__r.Name, Owner_Segment__c, Title, Decision_Map__c, Phone__c, Province__c, Zipcode__c, Country__c, Sales_amount_per_year__c, No_of_Years_Business_Run__c, Group__c, Original_Referral_Staff_ID__c, Original_Referral_Staff__c, Suggested_Segment__c, Suggested_Team__c, Pre_screen_passed__c, Sub_Unqualified_Reason__c, RTL_Referral__c, Link_Document__c, Other_Reason__c, Lead_Segment__c, Status, SmartBDM_QuickCA_ProcessStatus__c FROM lead WHERE Id =: leadObjId];
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;    
        }        
    }

    @AuraEnabled
    public static Id getMyOpportunityId(Id leadObjId)
    {
        return QCA_ConvertLeadController.getStdConvertOpptyId(leadObjId);
    }

    private static User currentUserInfo{
        get{
            if( currentUserInfo == null )
            {
                currentUserInfo = [SELECT Id, Name, Username, Segment__c, Reporting_Segment__c, Profile.name
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()
                    LIMIT 1];
            }
            return currentUserInfo;
        }
        set;
    }

    @AuraEnabled
    public static User getUserCurrent(){
        return currentUserInfo;
    }


    // Query Lead list with param
    // String - ID type and ID Number
    // Criteria - Lead's Owner and Record Type are Commercial Lead and Commercial Account
    // return value List of Lead sObject
    public static List<Lead> getLeadListByIDTypeIDNumber(String ID_Type, String ID_Number)
    {
        // Id userCurrentId = UserInfo.getUserId();
        Set<Id> LeadRecordTypeCriteria = new Set<Id> { CommercialLeadRecordTypeId, CommercialAccountRecordTypeId };

        String strQuery = 'FIND :ID_Number IN ALL FIELDS RETURNING Lead(Id, RecordTypeId, OwnerId, IsConverted, Customer_Type__c, Company, Customer_Name_EN__c, ID_Type__c, ID_Number__c, Mobile_No__c, Office_No__c, Ext__c, Email, Status, Remark__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Province__c, Zipcode__c, Country__c, Name, Phone__c, Title, Primary_Campaign__c, TMB_Cust_ID__c, Account__c, Account__r.TMB_Customer_ID_PE__c WHERE ID_Type__c = :ID_Type AND RecordTypeId IN :LeadRecordTypeCriteria )';

        return (List<Lead>)search.query(strQuery)[0];
    }

    // Query Account list with param
    // String - ID type and ID Number
    // Criteria - Lead's Owner and Record Type are Commercial Lead and Commercial Account
    // return value List of Lead sObject
    public static List<Account> getAccountListByIDTypeIDNumber(String ID_Type, String ID_Number)
    {
        // Id userCurrentId = UserInfo.getUserId();
        Set<Id> AccountRecordTypeCriteria = new Set<Id> { ExistingCustomerRecordTypeId, ProspectRecordTypeId };

        String strQuery = 'FIND :ID_Number IN ALL FIELDS RETURNING Account(Id, RecordTypeId, OwnerId, Name, Customer_Name_PE_Eng__c, Customer_Type__c, ID_Type_PE__c, ID_Number_PE__c, Mobile_Number_PE__c, Phone, Primary_Phone_Ext_PE__c, Email_Address_PE__c, Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c, Country_Primary_PE__c, Industry__c, ParentId, Sales_amount_per_year__c, Group__c, No_of_years_business_run__c, Branch_and_Zone__c WHERE ID_Type_PE__c = :ID_Type AND RecordTypeId IN :AccountRecordTypeCriteria )';

        return (List<Account>)search.query(strQuery)[0];
    }

    public class LeadUpdateRecordWrapper {
        @AuraEnabled
        public Lead leadObj {get; set;}
        @AuraEnabled
        public Account accountObj {get; set;}
        @AuraEnabled
        public Boolean isOwner {
            get{
                if(isOwner == null){
                    isOwner = false;
                }
                return isOwner;
            }
            set;
        }
    }

    @AuraEnabled
    public static Lead LeadRecordObj { get; set; }
    @AuraEnabled
    public static Account AccountRecordObj { get; set; }

    @AuraEnabled
    public static void updateLeadDetail(Lead leadObj)
    {
        try {
            update leadObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static LeadUpdateRecordWrapper validateDuplicateLeadAndAccount(Lead leadObj)
    {
        LeadUpdateRecordWrapper leadUpdateRecordWrapper = new LeadUpdateRecordWrapper();
        leadUpdateRecordWrapper.leadObj = leadObj;
        LeadRecordObj = leadObj;
        CommercialDuplicateCheck.LeadWrapper duplicatedLeadWrapper  = checkLeadDuplicateAccount();
        Boolean isDuplicateLeadOrAccount = duplicatedLeadWrapper.isfoundDuplicate;

        // System.debug('LeadRecordObj :' + LeadRecordObj);
        // System.debug('duplicatedLeadWrapper :' + duplicatedLeadWrapper);
        // System.debug('isDuplicateLeadOrAccount :' + isDuplicateLeadOrAccount);
        // System.debug('LeadRecordObj.ID_Type__c, LeadRecordObj.ID_Number__c : '+ LeadRecordObj.ID_Type__c +' | '+ LeadRecordObj.ID_Number__c);

        if(LeadRecordObj.RecordTypeId == CommercialLeadRecordTypeId)
        {
            if(isDuplicateLeadOrAccount)
            {

                List<Account> duplicationAccountList = getAccountListByIDTypeIDNumber(LeadRecordObj.ID_Type__c, LeadRecordObj.ID_Number__c);                
                List<Lead> duplicationLeadList = getLeadListByIDTypeIDNumber(LeadRecordObj.ID_Type__c, LeadRecordObj.ID_Number__c);
                if(duplicationAccountList.size() > 0){
                    AccountRecordObj = duplicationAccountList.get(0);

                    Boolean isOwnerAllowed = checkTransformPermission();
                    if(isOwnerAllowed){
                        leadUpdateRecordWrapper.isOwner = isOwnerAllowed;
                        leadUpdateRecordWrapper.accountObj = AccountRecordObj;
                        leadUpdateRecordWrapper.leadObj = updateLeadToCommercialAccountAfterValidated(leadUpdateRecordWrapper);
                        return leadUpdateRecordWrapper;
                    }
                    else {
                        // throw new AuraHandledException(Status_Code__c.GetValues('6003').Status_Message__c);
                        // Lead Create

                        if(leadObj.Id == null)
                        {
                            throw new AuraHandledException(Status_Code__c.GetValues('6003').Status_Message__c);
                        }
                        // Lead Edit
                        else if(leadObj.Id != null)
                        {
                            //Unqualified because do not have permissions
                            LeadRecordObj.Status = 'Unqualified';
                            LeadRecordObj.Unqualified_Rejected_List__c = 'Owned by another RM';
                            LeadRecordObj.Unqualified_Reasons__c = 'Owned by another RM';
                            LeadRecordObj.RecordTypeId = CommercialCompletedRecordTypeId;
                            leadUpdateRecordWrapper.leadObj = LeadRecordObj;
                            // Flag update record
                            leadUpdateRecordWrapper.isOwner = true;
                        }
                        
                    }
                }
                
                // System.debug('duplicationLeadList :: ' + duplicationLeadList);
                if(duplicationLeadList.size() > 0)
                {
                    Lead anotherLead;
                    Boolean isAnotherLead = false;
                    Boolean isOwnerAllowed = checkTransformPermission();
                    for (Lead lead : duplicationLeadList) {
                        if(currentUserInfo.Id != lead.OwnerId || !isOwnerAllowed || (lead.ID_Number__c ==  LeadRecordObj.ID_Number__c && lead.ID_Type__c == LeadRecordObj.ID_Type__c))
                        {
                            anotherLead = lead;
                            isAnotherLead = true;
                            break;
                        }
                    }
                    
                    // System.debug('isAnotherLead :: ' + isAnotherLead);
                    // System.debug('isOwnerAllowed :: ' + isOwnerAllowed);
                    // System.debug('anotherLead :: ' + anotherLead);
                    if(isAnotherLead) {
                        // Lead Create
                        if(leadObj.Id == null)
                        {
                            throw new AuraHandledException(Status_Code__c.GetValues('6003').Status_Message__c);
                        }
                        // Lead Edit
                        else if(leadObj.Id != null)
                        {
                            //Unqualified because do not have permissions
                            LeadRecordObj.Status = 'Unqualified';
                            LeadRecordObj.Unqualified_Rejected_List__c = 'Owned by another RM';
                            LeadRecordObj.Unqualified_Reasons__c = 'Owned by another RM';
                            LeadRecordObj.RecordTypeId = CommercialCompletedRecordTypeId;
                            leadUpdateRecordWrapper.leadObj = LeadRecordObj;
                            // Flag update record
                            leadUpdateRecordWrapper.isOwner = true;
                        }
                    }
                    // else {
                    //     leadUpdateRecordWrapper.isOwner = true;
                        
                    // }
                }
            }
        }

        return leadUpdateRecordWrapper;
    }

    public static CommercialDuplicateCheck.LeadWrapper checkLeadDuplicateAccount()
    {
        return CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(LeadRecordObj, LeadRecordObj).get(0);
    }

    public static Boolean checkTransformPermission()
    {
        if(LeadRecordObj != null){
            if(AccountRecordObj != null){
                List<AccountTeamMember> acctTeam = [SELECT ID, AccountId, UserId FROM AccountTeamMember WHERE AccountId =: AccountRecordObj.Id AND UserId =: LeadRecordObj.OwnerId LIMIT 1];
                
                //Owner Or Account Owner or Account Team allow
                if((LeadRecordObj.ownerID == AccountRecordObj.OwnerID) || (acctTeam.size() > 0)){
                    return true;
                }else{
                    //RMC Allow
                    List<Account__c> privilegeList = Account__c.getall().values();
                    User LeadOwner = [SELECT Id, UserRole.Name, Segment__c FROM user WHERE ID =: LeadRecordObj.OwnerId LIMIT 1];

                    for(Account__c eachPrivilege : privilegeList){
                        if(LeadOwner.UserRole.Name == eachPrivilege.Role__c ){
                            return true;
                        }                    
                    }
                    return false;
                }
            }
            else {
                return true;
            }
        }
        throw new AuraHandledException('LeadRecordObj ::: ' + LeadRecordObj);
    }

    // @AuraEnabled
    public static Lead updateLeadToCommercialAccountAfterValidated(leadUpdateRecordWrapper leadWrapper)
    {
        Lead tmpLead = (Lead)leadWrapper.leadObj;
        Account tmpDuplicateAccount = (Account)leadWrapper.accountObj;
        // System.debug(tmpLead);
        // System.debug(tmpDuplicateAccount);
        tmpLead.RecordTypeId = CommercialAccountRecordTypeId;
        tmpLead.Company = tmpDuplicateAccount.Name;
        tmpLead.Customer_Name_EN__c = tmpDuplicateAccount.Customer_Name_PE_Eng__c;
        tmpLead.Customer_Type__c = tmpDuplicateAccount.Customer_Type__c;
        tmpLead.ID_Type__c = tmpDuplicateAccount.ID_Type_PE__c;
        tmpLead.ID_Number__c = tmpDuplicateAccount.ID_Number_PE__c;
        tmpLead.Account__c = tmpDuplicateAccount.Id;
        
        if((tmpDuplicateAccount.Mobile_Number_PE__c != null && tmpDuplicateAccount.Mobile_Number_PE__c != '') ||
          (tmpDuplicateAccount.Phone != null && tmpDuplicateAccount.Phone != ''))
        {
            tmpLead.Mobile_No__c = tmpDuplicateAccount.Mobile_Number_PE__c;
            tmpLead.Office_No__c = tmpDuplicateAccount.Phone;
        }
        
        tmpLead.Ext__c = tmpDuplicateAccount.Primary_Phone_Ext_PE__c;
        tmpLead.Email__c = tmpDuplicateAccount.Email_Address_PE__c;
        tmpLead.Address_Line_1__c = tmpDuplicateAccount.Primary_Address_Line_1_PE__c == 'None' ? '':tmpDuplicateAccount.Primary_Address_Line_1_PE__c;
        tmpLead.Address_Line_2__c = tmpDuplicateAccount.Primary_Address_Line_2_PE__c == 'None' ? '':tmpDuplicateAccount.Primary_Address_Line_2_PE__c;
        tmpLead.Address_Line_3__c = tmpDuplicateAccount.Primary_Address_Line_3_PE__c == 'None' ? '':tmpDuplicateAccount.Primary_Address_Line_3_PE__c;
        tmpLead.Province__c = tmpDuplicateAccount.Province_Primary_PE__c;
        tmpLead.Zipcode__c = tmpDuplicateAccount.Zip_Code_Primary_PE__c;
        tmpLead.Country__c = tmpDuplicateAccount.Country_Primary_PE__c;
        tmpLead.Industry__c = tmpDuplicateAccount.Industry__c;
        tmpLead.Parent_Company__c = tmpDuplicateAccount.ParentId;
        tmpLead.Sales_amount_per_year__c = tmpDuplicateAccount.Sales_amount_per_year__c;
        tmpLead.Group__c = tmpDuplicateAccount.Group__c;
        tmpLead.No_of_Years_Business_Run__c = tmpDuplicateAccount.No_of_years_business_run__c;
        tmpLead.Preferred_Branch__c = tmpDuplicateAccount.Branch_and_Zone__c;
        // System.debug('tmpLead.Account__c :: ' +tmpLead.Account__c);
        return tmpLead;
    }

    @AuraEnabled
    public static void updateTrackStatus(String leadId, String stage)
    {
        SmartBDM_Utility.updateLeadStatus(leadId,stage);
    }
    
}