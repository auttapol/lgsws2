@isTest

public class CustomSearchControllerTest {
    
    @testSetup static void setup() {
        // Implement test code
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;
        
        AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
        insert ac;
        User u = CSTestUtils.createUsers(1, 'UserTest1' ,'User1' , 'test@gmail.com' , false).get(0);
        u.IsActive = true;
        insert u;
        
        Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        Account acc = new Account(); 
        acc.Name = 'Test RTL Account ';
        acc.First_Name_PE__c = 'Test';
        acc.Last_name_PE__c = 'RTL Account ';
        acc.Phone ='1111111111';
        acc.Mobile_Number_PE__c  = '1111111111';
        acc.ID_Type_PE__c = 'Passport ID';
        acc.ID_Number_PE__c = '11111';
        acc.RTL_NID__c = '1111';
        acc.RecordType = recordType;
        acc.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAD';
        acc.RTL_RM_Name__c = 'RTL02';
        acc.Email_Address_PE__c = 'test@gmail.com';
        acc.RecordTypeId = acctRT;
        insert acc;
        
        Account acc1 = new Account(); 
        acc1.Name = 'Test RTL Account2';
        acc1.First_Name_PE__c = 'Test2';
        acc1.Last_name_PE__c = 'RTL Account2';
        acc1.Phone ='22222';
        acc1.Mobile_Number_PE__c  = '22222';
        acc1.ID_Type_PE__c = 'Passport ID';
        acc1.ID_Number_PE__c = '2222';
        acc1.RTL_NID__c = '222';
        acc1.RecordType = recordType;
        acc1.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAC';
        acc1.RTL_RM_Name__c = 'RTL03';
        acc1.Email_Address_PE__c = 'test@gmail.com';
        acc1.RecordTypeId = acctRT;
        insert acc1;
        
        List<Contact> ctList = new List<Contact>();
        Contact ct = new Contact();
        ct.FirstName = 'Test';
        ct.LastName = 'Popup';
        ct.Email = 'test@gmail.com';
        ct.AccountId = acc.Id;
        ctList.add(ct);
        
        Contact ct1 = new Contact();
        ct1.FirstName = 'Test1';
        ct1.LastName = 'Popup1';
        ct1.Email = 'test@gmail.com';
        ct1.AccountId = acc.Id;
        ctList.add(ct1);
        
        insert ctList;
        
        //Create Case
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.recordtypeID = SErecordType.id;
        caseNew1.Subject = 'TestCase';
        caseNew1.Status = 'New';
        caseNew1.Description = 'Test create Case';
        caseNew1.AccountId = acc.id;
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);
        
        insert list_case;
        
        LiveChatVisitor chatVisit = new LiveChatVisitor();
        insert chatVisit;
        
        LiveChatTranscript chatTran = new LiveChatTranscript();
        chatTran.Case = list_case[0];
        chatTran.ContactId = ctList[0].Id;
        chatTran.LiveChatVisitorId = chatVisit.Id; 
        insert chatTran;
        
    }
    
    @isTest static void searchContactFromEmail() {
        // Implement test code
        Case caseObj = [SELECT Id,Origin,Contact_Person_Email__c FROM Case];
        List<Contact> ct = [SELECT Id,Name,FirstName,LastName FROM Contact LIMIT 1];
        Test.startTest();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ct[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomSearchController.searchContactFromEmail(caseObj.Id);
        Test.stopTest();              
    }
    
    @isTest static void searchContactFromEmail_Error() {
        // Implement test code
        Test.startTest();
        CustomSearchController.searchContactFromEmail(null);
        Test.stopTest();              
    }
    
    @isTest static void searchContactFromChat() {
        // Implement test code
        List<LiveChatTranscript> chatTranList = [SELECT Id, Name, ContactId,CaseId FROM LiveChatTranscript LIMIT 1];
        List<Contact> ct = [SELECT Id,Name,FirstName,LastName FROM Contact LIMIT 1];
        Test.startTest();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ct[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomSearchController.searchContactFromChat(chatTranList[0].Id);
        Test.stopTest();             
    }
    
    @isTest static void searchContactFromChat_Error() {
        // Implement test code
        Test.startTest();
        CustomSearchController.searchContactFromChat(null);
        Test.stopTest();              
    }
    
    @isTest static void getCase() {
        // Implement test code
        Case caseObj = [SELECT Id,Origin,Contact_Person_Email__c FROM Case];       
        Test.startTest();
        CustomSearchController.getCase(caseObj.Id);
        Test.stopTest();              
    }
    
    @isTest static void getCase1() {
        // Implement test code
        Test.startTest();
        CustomSearchController.getCase(null);
        Test.stopTest();              
    }
    
    @isTest static void getContactFromTranscript() {
        // Implement test code
        List<LiveChatTranscript> chatTranList = [SELECT Id, Name, ContactId,CaseId FROM LiveChatTranscript LIMIT 1];
        Test.startTest();
        CustomSearchController.getContactFromTranscript(chatTranList[0].Id);
        Test.stopTest();              
    }
    
    @isTest static void getContactFromTranscript_Error() {
        // Implement test code       
        Test.startTest();
        CustomSearchController.getContactFromTranscript(null);
        Test.stopTest();              
    }
    
    
    
}