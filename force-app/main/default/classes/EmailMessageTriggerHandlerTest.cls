@isTest
public class EmailMessageTriggerHandlerTest {
    
    @testSetup static void setup() {
        
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;
        
        AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
        insert ac;
        
        Service_Type_Matrix__c serviceType = New Service_Type_Matrix__c();
        serviceType.Segment__c = 'SBG';
        serviceType.Service_Level1__c = 'Service Level1';
        serviceType.Service_Level2__c = 'Service level2';
        serviceType.Service_Level3__c = 'Service level3';
        serviceType.Service_Level4__c = 'Service level4';
        serviceType.SLA__c = 1;
        serviceType.Severity__c = '1';
        serviceType.Responsible_BU__c = 'Test_Queue_SE';
        serviceType.active__c = true;
        serviceType.Service_issue_EN__c = 'english version';
        serviceType.Validate_Code__c = 'xxxx1';
        serviceType.Closed_By_BU__c = 'Email - TMB';
        // [2020-03-26] Case Select Template.
        serviceType.Service_Template__c = 'CreditService';
        
        insert serviceType;
        
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
        
        //Create Case
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'Retail Service']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.Subject = 'Complaints';
        caseNew1.PTA_Segment__c = 'SBG';
        caseNew1.Category__c = 'Service Level1';
        caseNew1.Sub_Category__c = 'Service level2';
        caseNew1.Product_Category__c = 'Service level3';
        caseNew1.Issue__c = 'Service level4';
        caseNew1.Status = 'Completed';
        caseNew1.Description = 'Test create Case';
        caseNew1.AccountId = acc.id;
        caseNew1.Service_issue_EN__c = 'english version';
        caseNew1.Service_Type_Matrix_Code__c = 'xxxx1';        
        caseNew1.recordtypeID = SErecordType.id;
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Origin = 'Live Chat';
        caseNew1.Problem_Type__c = 'N/A';
        caseNew1.Is_Cloned__c = false;
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);
        
        insert list_case;
        
        EmailMessage email = new EmailMessage();
        email.ParentId = list_case[0].Id;
        email.FromAddress = '';
        email.Incoming = false;
        email.status = '3';
        email.TextBody = '1111222233334444';
        insert email;        
        
        List<EmailSuppressionRule__c> esList = new List<EmailSuppressionRule__c>();
        
        EmailSuppressionRule__c es = new EmailSuppressionRule__c();
        es.Name = 'card';
        es.Formula__c = '^[^$]*([0-9]{16})[^$]*';
        es.Severity__c = 'Block';
        es.Text_Massage__c = 'ไม่อนุญาตให้ส่งข้อมูลเลขบัตรเครดิต 16 หลัก, กรุณาลบออก แล้วส่งใหม่อีกครั้ง';
		esList.add(es);
        
        EmailSuppressionRule__c es1 = new EmailSuppressionRule__c();
        es1.Name = 'file';
        es1.Formula__c = '^[zZ][iI][pP]|[rR][aA][rR]|[eE][xX][eE]$';
        es1.Severity__c = 'Block';
        es1.Text_Massage__c = 'ไฟล์ที่ใช้แนบ มี Format ไม่ถูกต้อง (zip, rar, exe), กรุณาลบออก แล้วส่งใหม่อีกครั้ง';
        esList.add(es1);
        
        insert esList;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = email.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    
    @isTest static void validateEmailSuppression() {
        // Implement test code
        Test.startTest();
        List<EmailMessage> email = [SELECT Id,TextBody,FromAddress,ParentId,Incoming,HasAttachment,Status FROM EmailMessage LIMIT 1];
        
        EmailMessageTriggerHandler.validateEmailSuppression(email);
        Test.stopTest();        
    }
    
    @isTest static void insertEmailSuppression() {
        // Implement test code
        Test.startTest();
       	List<Case> caseList = [SELECT Id,Subject FROM Case LIMIT 1];
        
        List<EmailMessage> emailList = new List<EmailMessage>();
        EmailMessage email = new EmailMessage();
        email.ParentId = caseList[0].Id;
        email.FromAddress = '';
        email.Incoming = false;
        email.status = '3';
        email.TextBody = 'body --------------- ข้อความต้นฉบับ --------------- test test --------------- Original Message --------------- test test';
        emailList.add(email); 
        
        try
        {
            insert emailList;  
        }
        catch(exception e)
        {
            System.debug('Error');
        }        
        
        Test.stopTest();        
    }
    
    @isTest static void updateEmailSuppression() {
        // Implement test code
        Test.startTest();
        
        EmailMessage email = [SELECT Id,TextBody,FromAddress,ParentId,Incoming,HasAttachment,Status FROM EmailMessage LIMIT 1];
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test';
        contentVersion.PathOnClient = 'Penguins.rar';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = email.id;
        cdl.ContentDocumentId = documents[1].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Attachment a = new Attachment();
        
        a.Name = 'Test Attchment';
        
        a.ParentId = email.Id;
        
        Blob b = blob.valueOf('test');
        
        a.Body = b;
        
        insert a;

        
        email.TextBody = 'Test --------------- ข้อความต้นฉบับ --------------- test test --------------- Original Message --------------- test test';
		
		try
        {
        	update email;  
        }
        catch(exception e)
        {
            System.debug('Error');
        }
        
        Test.stopTest();        
    }
    
}