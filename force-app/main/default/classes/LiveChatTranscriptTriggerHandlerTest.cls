@isTest
public class LiveChatTranscriptTriggerHandlerTest {
    
    @testSetup static void setup() {
        // Implement test code
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;
        
        AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
        insert ac;
        
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
        
        List<Contact> ctList = new List<Contact>();
        Contact ct = new Contact();
        ct.FirstName = 'Test';
        ct.LastName = 'Popup';
        ct.Email = 'test@gmail.com';
        ct.AccountId = acc.Id;
        ctList.add(ct);
        
        insert ctList;
        
        Skill_Master__c skill = new Skill_Master__c();
        skill.Topic__c = 'ผลิตภัณฑ์สินเชื่อ';
        skill.Source__c = 'Email - TMBWeb';
        skill.Assign_to_Queue__c = 'Email - TMB';
        skill.Segment__c = 'SBG';
        skill.Service_Level1__c = 'Service_Level1';
        skill.Service_Level2__c = 'Service_Level2';
        skill.Service_Level3__c = 'Service_Level3';
        skill.Validate_Code__c = 'X0001';
        skill.Problem_Type__c = 'N/A';
        skill.Journey__c = 'N/A';
        insert skill;	
        
        //Create Case
        Recordtype caseRecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'Retail Service']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.recordtypeID = caseRecordType.id;
        caseNew1.Subject = 'ผลิตภัณฑ์สินเชื่อ';
        caseNew1.Status = 'New';
        caseNew1.Description = 'Test create Case';
        caseNew1.AccountId = acc.id;
        caseNew1.Origin = 'Email - TMBWeb';
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);
        
        insert list_case;
        
        LiveChatVisitor chatVisit = new LiveChatVisitor();
        insert chatVisit;
        
        LiveChatTranscript chatTran = new LiveChatTranscript();
        chatTran.Case = list_case[0];
        chatTran.Subject__c = 'ผลิตภัณฑ์สินเชื่อ';
        chatTran.ContactId = ctList[0].Id;
        chatTran.LiveChatVisitorId = chatVisit.Id; 
        insert chatTran;
       
    }
    
    @isTest static void handleAfterUpdate() {
        // Implement test code
        Test.startTest();
   		LiveChatTranscript chatTran = [SELECT Id,ContactId,CaseId,OwnerId,Subject__c FROM LiveChatTranscript LIMIT 1];
        Case caseNew = [SELECT Id,Subject FROM Case LIMIT 1];
        System.debug('caseNew:'+caseNew);
        System.debug('chatTran:'+chatTran);
        chatTran.CaseId = caseNew.Id;
        chatTran.Subject__c = 'ผลิตภัณฑ์สินเชื่อ';
        update chatTran;
        Test.stopTest();        
    }
}