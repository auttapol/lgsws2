@IsTest

public class RTL_AccountTriggerTest {
    
    public static testmethod void testContactCreation(){
        Test.startTest();
        
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   
        
        Account acct = new Account();
        acct.First_Name_PE__c = 'ปรียา';
        acct.Last_Name_PE__c = 'เสรีวิชยสวัสดิ์';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0998877665';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.RTL_NID__c = '44466';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';                
        insert acct;
        
        Contact contact = [select Id, Name, Email from Contact where AccountId = :acct.Id limit 1];
        System.assertEquals(contact.Name, acct.Name);
        System.assertEquals(contact.Email, acct.Email_Address_PE__c);
        
        Account uAcct = new Account(Id=acct.Id);
        //uAcct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';
        uAcct.Email_Address_PE__c = 'test123@sfdc.com';
        //uAcct.Mobile_Number_PE__c = '0998877665';
        //uAcct.Name = acct.Name;
        update uAcct;
        
        Contact uContact = [select Id, Email from Contact where AccountId = :acct.Id limit 1];
        System.assertEquals(uContact.Email, uAcct.Email_Address_PE__c);
        Test.stopTest();
    }

}