@IsTest
public class ContactTriggerTest {
    
    public static testmethod void positiveTest(){
        TestUtils.createAppConfig();
        TestUtils.createObjUserPermission();
        AppConfig__c appconfig = new AppConfig__c(Name = 'runtrigger' , Value__c = 'true') ;
        
        System.debug(':::: positiveTest Start ::::');
        TestInit.createUser(false);
        User u = TestInit.us;
        user u2 = TestInit.us2;
        System.runAs(u) {            
            // Before Insert
             TestUtils.createUsers(1,'TestUtilTest', 'Utiltest','testUtil@tmbbank.com', true);
            TestInit.createAccount(1);
            
            List<Account> accountList = TestInit.accountList.values();

            List<Contact> contactList = TestInit.createContacts(1,accountList.get(0).id, true);
            
            Id salesforceRecId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
            List<Contact> conList = new List<Contact>();
            Contact con = new Contact(LastName = 'test contact' ,AccountId = accountList.get(0).id,
                                      Photo__c = '<img alt="User-added image" src="test"></img>');
            Contact con2 = new Contact(LastName = 'test contact2' ,AccountId = accountList.get(0).id,
                                      Photo__c = '<img alt="User-added image" src="test" style="height:200;"></img>');
            Contact con3 = new Contact(LastName = 'test contact3' ,AccountId = accountList.get(0).id,
                                      RecordTypeId = salesforceRecId);
            conList.add(con);
            conList.add(con2);
            conList.add(con3);
            Test.startTest();
            insert conList;
            update conList;            
            ContactTriggerHandler.resizeContactPhoto(conList,'update');
            ContactTriggerHandler.handlerBeforeInsert(conList);
            ContactTriggerHandler.handlerBeforeUpdate(conList);
            
            
            List<AccountTeamMember> accountTeamMemberList = TestInit.createAccountTeamMember(1,accountList.get(0).id,UserInfo.getUserId());            
            accountList.get(0).OwnerId = u2.Id;
            update accountList.get(0);
            contactList = TestInit.createContacts(1,accountList.get(0).id, true);  
            
            
            accountList.get(0).OwnerID = TestInit.us.id;
            update accountList;
              List<Contact>  contactList2 = TestInit.createContacts(1,accountList.get(0).id, true);  
            Test.stopTest();
           
            
            
        }
        System.debug(':::: positiveTest End ::::');
    }

}