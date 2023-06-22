@isTest
public class overSLAReferralEmailNotifyBatchTest{
    static List<Branch_And_Zone__c> branchAndZoneList;
    static{
        TestUtils.createAppConfig();
        Id TMB_RC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        system.debug(TMB_RC_PROFILE_ID);

        RTL_product_master__c prod = new RTL_product_master__c();
        prod.Name = 'CYC';
        prod.Active__c = true;
        insert prod;
        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Branch_Code__c = '001';
        branch.IsActive__c = true;
        insert branch;

        // List<User> userlst = [SELECT Id, ManagerId, Email, RTL_Branch_Code__c FROM User LIMIT 2];
        // for(User u:userlst){
        //     u.RTL_Branch_Code__c = '001';           
        // }

        User ManagerUser = new User(FirstName='TestApproval',LastName='Manager', 
                                    UserName='Manager_TMBTestTMB@tmb.com',
                                    Email='tmbmanager@tmbbank.com', Alias='TmbMr',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='ManagerNickname',
                                    ProfileId = TMB_RC_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MN001');
        insert ManagerUser;
        User PreferredStaff = new User(FirstName='TestApproval',LastName='PS', 
                                    UserName='RM_TMBTestTMB@tmb.com',
                                    Email='rmtmb@tmbbank.com', Alias='TmbRM',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='RMNickname',RTL_Branch_Code__c='001',
                                    ProfileId = TMB_RC_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='RM001',ManagerId = ManagerUser.id);
        insert PreferredStaff;

        System.runAs(PreferredStaff){
        String RecordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Cross Channel Referral').getRecordTypeId();
        RTL_Referral__c ref01 = new RTL_Referral__c();
        ref01.RecordTypeId = RecordTypeId;
        ref01.RTL_FirstName__c = 'Fname001';
        ref01.RTL_LastName__c = 'Lname001';
        ref01.RTL_Mobile1__c = '0951234560';
        ref01.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        ref01.RTL_Preferred_Staff__c = PreferredStaff.Id;
        ref01.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
        ref01.RTL_Stage__c = 'New';
        ref01.RTL_Preferred_Branch__c = [SELECT Id,Branch_Code__c  FROM  Branch_and_Zone__c WHERE Branch_Code__c = '001' LIMIT 1].Id;
        insert ref01;
        ref01.Before_Over_SLA__c = Datetime.now();
        update ref01;
        RTL_Referral__c ref02 = new RTL_Referral__c();
        ref02.RecordTypeId = RecordTypeId;
        ref02.RTL_FirstName__c = 'Fname002';
        ref02.RTL_LastName__c = 'Lname002';
        ref02.RTL_Mobile1__c = '0951234560';
        ref02.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        ref02.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
        ref02.RTL_Stage__c = 'New';
        ref02.RTL_Preferred_Branch__c = [SELECT Id,Branch_Code__c  FROM  Branch_and_Zone__c WHERE Branch_Code__c = '001' LIMIT 1].Id;
        insert ref02;
        ref02.Before_Over_SLA__c = Datetime.now();
        update ref02;
        RTL_Referral__c ref03 = new RTL_Referral__c();
        ref03.RecordTypeId = RecordTypeId;
        ref03.RTL_FirstName__c = 'Fname003';
        ref03.RTL_LastName__c = 'Lname003';
        ref03.RTL_Mobile1__c = '0951234560';
        ref03.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        ref03.RTL_Preferred_Staff__c = PreferredStaff.Id;
        ref03.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
        ref03.RTL_Stage__c = 'New';
        ref03.RTL_Preferred_Branch__c = [SELECT Id,Branch_Code__c  FROM  Branch_and_Zone__c WHERE Branch_Code__c = '001' LIMIT 1].Id;
        insert ref03;
        ref03.Before_Over_SLA__c = Datetime.now();
        update ref03;
        }
        
    }

    @isTest
    public static void testFlow(){
        String q = 	' SELECT Id, OwnerId, CreatedBy.Email, Owner.Name, Owner.Email, RTL_Preferred_Staff__c, Name, RTL_Stage__c, RecordType.Name, RTL_Interested_Product__c, RTL_Account_Name__c, RTL_Account_Name__r.Name, RTL_Type__c, RTL_Product_Group__c, RTL_Product_Name__r.Name, RTL_Preferred_Staff__r.Manager_Email__c'
					+ ' FROM RTL_Referral__c '
					+ ' WHERE Before_Over_SLA__c = TODAY AND'
					+ ' (RecordType.Name = \'Refer to Retail\' OR RecordType.Name = \'Retail Cross Channel Referral\') AND'
					+ ' RTL_Stage__c = \'New\' ';
        Test.startTest();
        Database.executeBatch(new overSLAReferralEmailNotificationBatch(q));
        Test.stopTest();
    }

    @isTest
    public static void testScheduled(){
        Test.startTest();
        String jobId = System.schedule('test', '0 0 8 ? * MON,TUE,WED,THU,FRI *', new overSLAReferralEmailNotifyScheduled());
        Test.stopTest();
    }
}