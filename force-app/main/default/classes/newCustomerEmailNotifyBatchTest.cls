@isTest
public class newCustomerEmailNotifyBatchTest {
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    
    static{
        TestUtils.createAppConfig();

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        List<User> userlst = new List<User>();

        User User01 = RTL_TestUtility.createUsers(1, 'testuser', 'testuser', 'testuser@tmb.com.test', false).get(0);
		User01.ProfileId = SESM_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '111111';
		User01.Zone__c = 'SE-ChiangMai';
		User01.Zone_Code__c = '9999';
		User01.Region__c = 'SE1-North1';
		User01.Region_Code__c = '1111';
        User01.Segment__c = 'SE';
        userlst.add(User01);

        insert userlst;

        List<Account> existingAccts = TestUtils.createAccounts(4, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = User01.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';

        insert existingAccts;
    }

    @isTest
    public static void testFlow(){
        String q = 	' SELECT Id, OwnerId, Owner.Name, Owner.Email, Owner.Employee_ID__c, Name, LastModifiedDate, Account_Type__c, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c, Previous_Owner_Name__c '
					+ ' FROM Account ';
        Test.startTest();
        Database.executeBatch(new newCustomerEmailNotifyBatch(q));
        Test.stopTest();
    }

    @isTest
    public static void testScheduled(){
        Test.startTest();
        String jobId = System.schedule('test',  '0 0 0 15 3 ? *', new newCustomerEmailNotifyBatchScheduled());
        Test.stopTest();
    }
}