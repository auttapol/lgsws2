/* --------------------------------------------------
Strike by Appiphony

Version: 0.10.0
Website: http://www.lightningstrike.io
GitHub: https://github.com/appiphony/Strike-Components
License: BSD 3-Clause License
-------------------------------------------------- */
@isTest
private class strike_tst_lookupController {

	public static List<Account> getAccountList() {
        return [SELECT Id, Name, Automate_Result__c FROM Account];
    }

    public static List<Contact> getContact() {
        return [SELECT Id, Name FROM Contact];
    }
    
    @testSetup static void setup() {

        TestUtils.createAppConfig();        
		List<AppConfig__c> mc = new List<AppConfig__c> {
            new AppConfig__c(Name = 'runtrigger', Value__c = 'true')
        };
		insert mc;

        Account a = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
        a.Name = 'Test Account';
        a.Automate_Result__c = 'Test Account';
		a.Customer_Type__c = 'Individual';
		//a.OwnerID = User01.Id;
		//a.RecordTypeId = PROSPECT_ID;
        a.Customer_Type__c = 'Juristic';
        a.ID_Type_PE__c = 'BRN ID';
        a.ID_Number_PE__c = DateTime.Now().format('MMddyyyyhhmmss') + '99901';
        a.BillingStreet='Test Street';
        a.BillingCity='Test City';
        a.BillingState='Test State';
        a.BillingCountry='Test Country';
        a.BillingPostalCode='Test Postal Code';
		insert a;

        Contact c = TestUtils.createContacts(1, a.Id, false).get(0);
        c.LastName = 'Contact';
        c.FirstName = 'Test';
        c.Facebook_ID__c = 'Test Contact';
		c.Primary_Phone_Ext_PE__c = '0817161233';
		insert c;
    }
    
    @isTest static void test_getRecentRecords() {
        String jsonString = '{"searchField":"Automate_Result__c", "object": "Account", "filter": "Automate_Result__c = \'Test Account\'"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{getAccountList().get(0).Id});
        String responseString = strike_lookupController.getRecentRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');

        System.assertEquals(true, response.get('isSuccess'));
    }

    @isTest static void test_getRecordLabel() {
        //Account a = new Account(Name='Test Account');
        //insert a;

        String jsonString = '{"searchField":"Automate_Result__c", "object": "Account", "filter": "Automate_Result__c = \'Test Account\'"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{getAccountList().get(0).Id});
        String responseString = strike_lookupController.getRecordLabel(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        String objectLabel = String.valueOf(results.get('objectLabel'));

        System.assertEquals('Customer', objectLabel);
    }

    @isTest static void test_getData() {
        //Account a = new Account(Name='Test Account');
        //insert a;
        Account a = getAccountList().get(0);
        String jsonString = '{"searchField":"Automate_Result__c", "object": "Account", "filter": "Automate_Result__c = \'Test Account\'", "order": "Automate_Result__c", "limit": "5", "searchTerm": "Test"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{a.Id});
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_subtitleField() {
        //Account a = new Account(Name='Test Account');
        //insert a;
        Account a = getAccountList().get(0);
        String jsonString = '{"searchField":"Automate_Result__c", "subtitleField": "Automate_Result__c", "object": "Account", "filter": "Automate_Result__c = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{a.Id});
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_addressField() {
        // Account a = new Account(
        //    Name='Test Account',
        //    BillingStreet='Test Street',
        //    BillingCity='Test City',
        //    BillingState='Test State',
        //    BillingCountry='Test Country',
        //    BillingPostalCode='Test Postal Code');
        // insert a;
        Account a = getAccountList().get(0);
        String jsonString = '{"searchField":"Automate_Result__c", "subtitleField": "BillingAddress", "object": "Account", "filter": "Automate_Result__c = \'Test Account\'", "searchTerm": "Test"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{a.Id});
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_reference() {
        //Account a = new Account(Name='Test Account');
        //insert a;
		
        // Contact c = new Contact(
        //     LastName='Contact',
        //     FirstName='Test',
        //     AccountId = a.Id);
        // insert c;
        Contact c = getContact().get(0);
        String jsonString = '{"searchField":"Facebook_ID__c", "subtitleField": "Account.Automate_Result__c", "object": "Contact", "filter": "Facebook_ID__c = \'Test Contact\'", "searchTerm": "Test"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{c.Id});
        String responseString = strike_lookupController.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        List<Object> data =(List<Object>)results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>)data.get(0);

        System.assertEquals(c.Id, record.get('value'));
    }
}
/* --------------------------------------------------
Copyright 2017 Appiphony, LLC

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------- */