@isTest
public class updateLongtermRepaymentBatchTest {
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
    public static void updateLongtermRepaymentBatchTest() {
        User admin = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];

        Test.startTest();
        
        system.runAs(admin){
            Long_Term_Loan_Repayment__c LTP = new Long_Term_Loan_Repayment__c();
            LTP.Next_Due_Date__c = Date.newInstance(2021,3,31);
            LTP.Repayment_Amount__c = 10000;
            LTP.As_of_Date__c = Date.newInstance(2021,01,01);
            LTP.AccountId_Due_Date__c = '001aLT-G1-Acc12021-03-31';
            LTP.Account_Suffix_Ref__c = '001aLT-G1-Acc1';
            insert LTP;
            
            database.executebatch(new updateLongtermRepaymentBatch(), 300);

        }
        Test.stopTest();
    }
}