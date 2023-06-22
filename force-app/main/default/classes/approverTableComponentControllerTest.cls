@isTest
public class approverTableComponentControllerTest {
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

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
        insert User01;
    }

    @isTest
    public static void testflow() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];

        approverTableComponentController ctrl = new approverTableComponentController();
        ctrl.approverlst = new List<User>();
        ctrl.approverlst.add(user);
        List<approverTableComponentController.approverWraperClass> approverWraperlst = ctrl.approverWraperlst;
    }
}