@isTest
public class OtherBankTriggerTest {
	@istest
    static void test(){
         TestUtils.createAppConfig();
         Account acct = TestUtils.createAccounts(1,'acc','acc', true).get(0);
        acct.RTL_Wealth_RM__c = userinfo.getUserId();
        update acct;
        
        Other_Bank__c ob = new Other_Bank__c();
        ob.Customer__c = acct.Id;
        ob.Amount__c = 200;
        
        insert ob;
        
         TestInit.createUser(true);
         User u = TestInit.us;
         System.runAs(u) {
             try{
        		delete ob;
             }catch(Exception e){
                 
             }
         }
    }
}