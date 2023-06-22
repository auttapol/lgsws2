@isTest
public with sharing class CommercialVerifyButtonControllerTest {
    private static string MockData() {
        AppConfig__c appconfigObj1 = new AppConfig__c(Name = 'runtrigger',Value__c = 'true');
        insert appconfigObj1;
        
        Account a = new Account();
        a.mobile_number_pe__c = '1111111';
        a.name = 'name';
        insert a;
                
        Contact con = new Contact();
        con.FirstName = 'firstname';
        con.LastName = 'lastname';
        con.Phone = '095-959-9561';
        con.Email = 'test@test.co.th';
        con.IsVerified__c = true;
        con.IsTBankData__c = true;
        con.Account__c = a.id;
        con.AccountId = a.id;
        insert con;
        
        return con.Id;
    }
    
    @isTest
    public static void Test_CommercialVerifyButtonController() {
        CommercialVerifyButtonController c = new CommercialVerifyButtonController();
    }
    
	@isTest
    public static void Test_getContactDetail() {
		string conId = MockData();
        Contact con = CommercialVerifyButtonController.getContactDetail(conId);
    }
    
    @isTest
    public static void Test_UpdateContact() {
        string conId = MockData();
        CommercialVerifyButtonController.UpdateContact(conId, true);
    }
}