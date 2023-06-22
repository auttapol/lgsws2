@isTest
public class CompanyProfileEmbedExTest {

    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    public static final Id RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id RM_ROLE_ID = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1].Id;

    static testmethod void CompanyProfileEmbedTest(){
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();


        User SalesOwner = new User(FirstName='ff', LastName='ll', 
                                    UserName='aa_TMBTestTMB@tmb.com',
                                    Email='ee@tmbbank.com', Alias='tTesttmb',Segment__c ='BB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='fflTMBTesttmb',
                                    ProfileId = BDM_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='T0011');
        User Sales2 = new User(FirstName='f', LastName='l', 
                                    UserName='a_TMBTestTMB@tmb.com',
                                    Email='e@tmbbank.com', Alias='Testtmb',Segment__c ='BB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='flTMBTesttmb',
                                    ProfileId = RM_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='T0012');
        insert SalesOwner;
        insert Sales2;


        Test.startTest();

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(thisUser){
            Sales2.UserRoleId = RM_ROLE_ID;
            update Sales2;
        }

        system.runAs(SalesOwner){

            List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
            List<Account> NewAccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupMaster', 'Individual', SalesOwner.id, true, true);
            List<Account> acctForCompanyProfile = new List<Account>();
            acctForCompanyProfile.add(AccountList.get(0));
            acctForCompanyProfile.add(AccountList.get(2));
            acctForCompanyProfile.add(AccountList.get(3));
            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, false);
            
            List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
            AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(AccountList.get(0));
            CompanyProfileEmbedEx cont = new CompanyProfileEmbedEx(sc);

            boolean ca = cont.getCheckAuthorize();

            system.runAs(Sales2){
                CompanyProfileEmbedEx cont2 = new CompanyProfileEmbedEx(sc);
                boolean ca2 = cont2.getCheckAuthorize();
            }
        }

        Test.stopTest();
    }
    
}