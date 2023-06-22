@isTest
public class AccountPlanRecallApprovalTest {
        static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
    public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
     public static final Id TMB_RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id TMB_SEGMENTHEAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Segment Head Profile' LIMIT 1].Id; 
    
    public static testmethod void myUnitTest(){

         User ManagerUser = new User(FirstName='TestApproval',LastName='Manager', 
                                    UserName='Manager_TMBTestTMB@tmb.com',
                                    Email='tmbmanager@tmbbank.com', Alias='TmbMr',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='ManagerNickname',
                                    ProfileId = TMB_RM_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MN001');
         insert ManagerUser;
         User SalesOwner = new User(FirstName='TestApproval',LastName='RM', 
                                    UserName='RM_TMBTestTMB@tmb.com',
                                    Email='rmtmb@tmbbank.com', Alias='TmbRM',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='RMNickname',
                                    ProfileId = TMB_SEGMENTHEAD_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='RM001',ManagerId = ManagerUser.id);
         insert SalesOwner;
        Test.startTest();
        
        
         List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'RejectedTest', 'Individual', SalesOwner.id, true, true);
         List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList, false);
        AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        comprofile.Status__c = 'Waiting for Approval';
        comprofile.isAvailableforApproval__c = true;
        comprofile.OwnerID = SalesOwner.id;
        insert comprofile;
        
        List<ID> CompanyProfileIDs = new List<ID>();
        CompanyProfileIDs.add(comprofile.id);
        
        
        //Create an approval request for the change
       
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(comprofile.Id);
        req1.setNextApproverIds(new Id[] {SalesOwner.id});
        //Submit the approval request for the change
        Approval.ProcessResult result = Approval.process(req1);

        AccountPlanRecallApproval.recallAccountPlanApproval(CompanyProfileIDs);
             
         Test.stopTest();
    }

}