@isTest
public class GenerateForecastInputExistFeeBatchTest {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

    
    static{
        TestUtils.createAppConfig();
        
        User userSystemadmin = RTL_TestUtility.createUsers(1, 'Sysad', 'Sysad', 'Sysad@tmb.com.test', false).get(0);
		userSystemadmin.ProfileId = SYSAD_PROFILE_ID;
		userSystemadmin.isActive = true;
		userSystemadmin.Employee_ID__c = '000002';
		userSystemadmin.Zone__c = 'ChiangMai';
		userSystemadmin.Zone_Code__c = '8888';
		userSystemadmin.Region__c = 'North1';
		userSystemadmin.Region_Code__c = '2222';
        
        insert userSystemadmin;
    }


    @isTest
    public static void testExistingFeeBatch() {
        User admin = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];

        Test.startTest();
        
        system.runAs(admin){
        account acct = TestUtils.createAccounts(1, 'fname', 'Individual', true).get(0);
        AcctAnnualPerformance__c AAP = new AcctAnnualPerformance__c();
        AAP.AS_FEE__c = 100000;
        AAP.AVG_CASA__c = 0;
        AAP.Account__c = acct.Id;
        AAP.BA_FEE__c = 0;
        AAP.CREDIT_FEE__c = 10000;
        AAP.DERIVATIVES_FEE__c = 0;
        AAP.DIRECT_CM_FEE__c = 0;
        AAP.EDC_FEE__c = 0;
        AAP.FLEET_FEE__c = 0;
        AAP.FRONT_END_FEE__c = 30000;
        AAP.FX_FEE__c = 0;
        AAP.Fee__c = 0;
        AAP.IB_FEE__c = 50000;
        AAP.LG_FEE__c = 0;
        AAP.OTHER_CM_FEE__c = 20000;
        AAP.OTHER_FEE__c = 0;
        AAP.TF_FEE__c = 100000;
        AAP.Transaction_Date__c = Date.Today();
        AAP.Supply_Chain__c = 10000;
        AAP.MF_Fee__c = 0;
        AAP.AL_Fee__c = 50000;
        AAP.TMB_CUST_ID__c='TestID';
        insert AAP;
        database.executebatch(new GenerateForecastInputExistFeeBatch(), 300);
        System.schedule('Test_GenerateForecastInputExistFeeScheduler',  '0 0 9 * * ?', new GenerateForecastInputExistFeeScheduler());
        }
        Test.stopTest();
    }
}