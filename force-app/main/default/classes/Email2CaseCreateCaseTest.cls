@isTest

public class Email2CaseCreateCaseTest {
    
    static User adminUser{
        get
        {
            if(adminUser == null){
                adminUser = [SELECT Id,Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.SYSADMIN_PROFILE_ID LIMIT 1];
            }
            return adminUser;
        }
        set;
    }
    
    @testSetup static void setup() {
        // Implement test code
        //AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        //insert mc;
        
        system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            
            Group queue = new Group();
            queue.Name = 'Email - TMB';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;
            
            QueuesObject qsObject = new QueueSObject();
            qsObject.QueueId = queue.Id;
            qsObject.SobjectType = 'Case';
            insert qsObject;
            
            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = adminUser.id;
            member1.GroupId = queue.Id;
            groupMemberList.add(member1);
            
            insert groupMemberList;
        } 
        /*User u = CSTestUtils.createUsers(1, 'UserTest1' ,'User1' , 'test@gmail.com' , false).get(0);
u.IsActive = true;
insert u;*/
        
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
        email.Incoming = true;
        insert email;
        
        Skill_Master__c skill = new Skill_Master__c();
        skill.Topic__c = 'Complaints';
        skill.Source__c = 'Live Chat';
        skill.Assign_to_Queue__c = 'Email - TMB';
        skill.Validate_Code__c = 'X0001';
        insert skill;    
    }
    
    @isTest static void Email2CaseCreateCase() {
        // Implement test code
        Test.startTest();
        List<EmailMessage> email = [SELECT Id,FromAddress,ParentId FROM EmailMessage LIMIT 1];
        
        new Email2CaseCreateCase(email);
        Test.stopTest();        
    }
    
    @isTest static void Email2CaseCreateCase_NotMatch() {
        // Implement test code
       	Test.startTest();
		List<Case> caseList = [SELECT Id,Subject FROM Case LIMIT 1];
		caseList[0].Subject = 'Test';
        update caseList;
        
        List<EmailMessage> email = [SELECT Id,FromAddress,ParentId FROM EmailMessage LIMIT 1];
        
        new Email2CaseCreateCase(email);
        Test.stopTest();        
    }
    
}