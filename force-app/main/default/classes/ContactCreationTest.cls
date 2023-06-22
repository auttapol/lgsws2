@isTest
public class ContactCreationTest {
	@testSetup static void setup() {
        User user0 = userTest();
        
        List<User> user = new List<User>();
        user.add(user0);
        insert user;
        
        Status_Code__c sc = new Status_Code__c(Name='7006',Status_Message__c ='Only Visit Owner and TMB counterparty can create/update Visit Report');
        AppConfig__c app1 = new AppConfig__c(Name='DefaultOwner',Value__c='00000');
        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        AppConfig__c app3 = new AppConfig__c(Name='FilterRetailSegment',Value__c='5');
		List<AppConfig__c> app = new List<AppConfig__c>();
        app.add(app1);
        app.add(app2);
        app.add(app3);
        insert app;
        insert sc;
		
        Trigger_Msg__c tmc = new Trigger_Msg__c(Name='Permission_Create_Opportunity',Description__c = 'Permission Invalid [You must be the owner or account team member to do so]');
		insert tmc;
        
        System.runAs(user0){
            Account acc = new Account (Name='TestAcc',Mobile_Number_PE__c ='0987654321');
            insert acc;
            Contact c = new Contact(FirstName='test',LastName='jaa',AccountId=acc.Id);
            insert c;
        }
    }
    
    @isTest static void testMethod1() {
        User user1 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
		Contact c = [Select Id FROM Contact LIMIT 1 ];
        System.runAs(user1){
            test.startTest();
            ContactCreation.picklist_values('Contact', 'Salutation');
            ContactCreation.countries();
            ContactCreation.provinces();
            ContactCreation.districts('เชียงใหม่');
            ContactCreation.subDistricts('อำเภอเมืองน่าน');
            ContactCreation.postalCode('คลองตัน','อำเภอเมืองน่าน');
            ContactCreation.getContact(c.Id);
            
            test.stopTest();
        }
    }
    
    public static User userTest(){
		Profile p = [SELECT Id, Name FROM Profile Where Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.Username = 'test@tmbbank.com';
        user.LastName ='test';
        user.Email ='test@tmbbank.com';
        user.Alias ='test';
        user.TimeZoneSidKey ='Asia/Bangkok';
        user.LocaleSidKey ='th_TH';
        user.EmailEncodingKey ='UTF-8';
        user.ProfileId = p.Id;
        user.LanguageLocaleKey ='en_US';
        user.Employee_ID__c = '86790';
        return user ;
    }
}