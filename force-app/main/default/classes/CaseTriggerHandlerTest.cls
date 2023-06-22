//Test Class
@isTest 
public class CaseTriggerHandlerTest { 

    static List<Service_Type_Matrix__c> serviceTypeList;
    static List<Case> caseList;
    static Account acct = new Account();

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
    
    static User tmbAdminUser{
        get
        {
            if(tmbAdminUser == null){
                tmbAdminUser = [SELECT Id,Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.TMB_SYSADMIN_PROFILE_ID LIMIT 1];
            }
            return tmbAdminUser;
        }
        set;
    }

    static User branchUser{
        get
        {
            if(branchUser == null){
                branchUser = [SELECT Id,Name,RTL_Branch_Code__c,UserRole.Name FROM User WHERE IsActive = true AND ProfileId =: RTL_TestUtility.RTL_BRANCH_SALES_PROFILE_ID AND RTL_Branch_Code__c = '001' LIMIT 1 ];
            }
            return branchUser;
        }
        set;
    }

    static void setupData(){

        System.runAs(adminUser){
            
            List<Group> groupList = new List<Group>();
            Group queue = new Group();
            queue.Name = 'test queue';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;
            
            Group rmcGroup = new Group();
            rmcGroup.Name = 'RMC Test';
            rmcGroup.Type = 'Queue';
            rmcGroup.DeveloperName ='RMC_Test';
            insert rmcGroup;
            
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

            TestUtils.createAppConfig();

            Mapping_Service_BU_Name__c mapBuName = new Mapping_Service_BU_Name__c();
            mapBuName.Name = 'test';
            mapBuName.Owner_Team__c = 'test';
            mapBuName.BU_Name__c = 'test queue';

            insert mapBuName;
            
            // Set mock callout class 
           Test.setMock(HttpCalloutMock.class, new MockupSMSResponse());
        } 

        //Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);

        serviceTypeList = new List<Service_Type_Matrix__c>();
        caseList = new List<Case>();

        Service_Type_Matrix__c serviceType = New Service_Type_Matrix__c();
        serviceType.Segment__c = 'SBG';
        serviceType.Service_Level1__c = 'Service Level1';
        serviceType.Service_Level2__c = 'Service level2';
        serviceType.Service_Level3__c = 'Service level3';
        serviceType.Service_Level4__c = 'Service level4';
        serviceType.SLA__c = 7;
        serviceType.Severity__c = '1';
        serviceType.Responsible_BU__c = 'Test_Queue_SE';
        serviceType.active__c = true;
        serviceType.Service_issue_EN__c = 'english version';
        serviceType.Validate_Code__c = 'xxxx1';
        serviceType.Responsible_BU_Hop_2__c = 'RMC';
        serviceType.Responsible_BU_Hop_3__c ='test queue';
        serviceType.Closed_By_BU__c = 'REGISTER';
        serviceType.SLA_Hop_1_Day__c = 1;
        serviceType.SLA_Hop_2_Day__c = 1;
        serviceType.SLA_Hop_3_Day__c = 1;
        serviceType.SLA_Closed_By_BU_Day__c = 1;
        // [2020-03-26] Case Select Template.
        serviceType.Service_Template__c = 'CreditService';
        serviceTypeList.add(serviceType);

        Service_Type_Matrix__c serviceType2 = New Service_Type_Matrix__c();
        serviceType2.Segment__c = 'RBG';
        serviceType2.Service_Level1__c = 'Service_Level1';
        serviceType2.Service_Level2__c = 'Service_level2';
        serviceType2.Service_Level3__c = 'Service_level3';
        serviceType2.Service_Level4__c = 'Service_level4';
        serviceType2.SLA__c = 7;
        serviceType2.Severity__c = '1';
        serviceType2.Responsible_BU__c = 'Test_Queue_SE';
        serviceType2.active__c = true;
        serviceType2.Service_issue_EN__c = 'english version';
        serviceType2.Validate_Code__c = 'xxxx2';
        serviceType2.Responsible_BU_Hop_2__c = 'RMC';
        serviceType2.Responsible_BU_Hop_3__c ='test queue';
        serviceType2.Closed_By_BU__c = 'Test_Queue_SE';
        serviceType2.SLA_Hop_1_Day__c = 1;
        serviceType2.SLA_Hop_2_Day__c = 1;
        serviceType2.SLA_Hop_3_Day__c = 1;
        serviceType2.SLA_Closed_By_BU_Day__c = 1;
        // [2020-03-26] Case Select Template.
        serviceType2.Service_Template__c = 'Card';
        serviceTypeList.add(serviceType2);
        
        Service_Type_Matrix__c serviceType3 = New Service_Type_Matrix__c();
        serviceType3.Segment__c = 'WBG';
        serviceType3.Service_Level1__c = 'Service_Level1';
        serviceType3.Service_Level2__c = 'Service_level2';
        serviceType3.Service_Level3__c = 'Service_level3';
        serviceType3.Service_Level4__c = 'Service_level4';
        serviceType3.SLA__c = 7;
        serviceType3.Severity__c = '1';
        serviceType3.Responsible_BU__c = 'Test_Queue_SE';
        serviceType3.active__c = true;
        serviceType3.Service_issue_EN__c = 'english version';
        serviceType3.Validate_Code__c = 'xxxx3';
        // [2020-03-26] Case Select Template.
        serviceType3.Service_Template__c = 'CheckInvalidTransfer';
        serviceTypeList.add(serviceType3);
        
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
        Case caseObj = New Case(); 
        caseObj.recordtypeID = SErecordType.id;
        caseObj.Subject = 'TestCase';
        caseObj.PTA_Segment__c = 'SBG';
        caseObj.Category__c = 'Service Level1';
        caseObj.Sub_Category__c = 'Service level2';
        caseObj.Product_Category__c = 'Service level3';
        caseObj.Issue__c = 'Service level4';
        caseObj.Status = 'New';
        caseObj.Description = 'Test create Case';
        caseObj.AccountId = acct.id;
        caseObj.Root_Cause_List__c = 'Other';
        caseObj.Root_Cause__c = 'test';
        caseObj.Resolution_LIst__c = 'Other';
        caseObj.Resolution__c =  'test';
        caseObj.Service_issue_EN__c = 'english version';
        caseObj.Service_Type_Matrix_Code__c = 'xxxx1';
        caseObj.Card_No_Full__c = '1234567890009123';
        caseObj.Card_No2_Full__c = '1234567890009125';
        caseObj.SMS_Code_New__c = 'RGB001';
        caseObj.Current_Service_Template__c = 'General';
        caseList.add(caseObj);
        
        
        Case caseObj2 = New Case(); 
        caseObj2.recordtypeID = SErecordType.id;
        caseObj2.Subject = 'TestCase';
        caseObj2.PTA_Segment__c = 'RBG';
        caseObj2.Category__c = 'Service_Level1';
        caseObj2.Sub_Category__c = 'Service_level2';
        caseObj2.Product_Category__c = 'Service_level3';
        caseObj2.Issue__c = 'Service_level4';
        caseObj2.Status = 'New';
        caseObj2.Description = 'Test create Case';
        caseObj2.AccountId = acct.id;
        caseObj2.Root_Cause_List__c = 'Other';
        caseObj2.Root_Cause__c = 'test';
        caseObj2.Resolution_LIst__c = 'Other';
        caseObj2.Resolution__c =  'test';
        caseObj2.Service_issue_EN__c = 'english version';
        caseObj2.Service_Type_Matrix_Code__c = 'xxxx2';
        caseObj2.Current_Service_Template__c = 'General';
        caseList.add(caseObj2);
        
        Case caseObj3 = New Case(); 
        caseObj3.recordtypeID = SErecordType.id;
        caseObj3.Subject = 'TestCase';
        caseObj3.PTA_Segment__c = 'WBG';
        caseObj3.Category__c = 'Service_Level1';
        caseObj3.Sub_Category__c = 'Service_level2';
        caseObj3.Product_Category__c = 'Service_level3';
        caseObj3.Issue__c = 'Service_level4';
        caseObj3.Status = 'New';
        caseObj3.Description = 'Test create Case';
        caseObj3.AccountId = acct.id;
        caseObj3.Root_Cause_List__c = 'Other';
        caseObj3.Root_Cause__c = 'test';
        caseObj3.Resolution_LIst__c = 'Other';
        caseObj3.Resolution__c =  'test';
        caseObj3.Service_issue_EN__c = 'english version';
        caseObj3.Service_Type_Matrix_Code__c = 'xxxx3';
        caseObj3.Current_Service_Template__c = 'General';
        caseList.add(caseObj3);

    }
    
    //23/06/2020 Fix Support Deploy Date 25/06/2020
    static void setupDataCase(){

        System.runAs(adminUser){
            
            List<Group> groupList = new List<Group>();
            Group queue = new Group();
            queue.Name = 'test queue';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;
            
            Group rmcGroup = new Group();
            rmcGroup.Name = 'RMC Test';
            rmcGroup.Type = 'Queue';
            rmcGroup.DeveloperName ='RMC_Test';
            insert rmcGroup;
            
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

            TestUtils.createAppConfig();

            Mapping_Service_BU_Name__c mapBuName = new Mapping_Service_BU_Name__c();
            mapBuName.Name = 'test';
            mapBuName.Owner_Team__c = 'test';
            mapBuName.BU_Name__c = 'test queue';

            insert mapBuName;
            
            // Set mock callout class 
           Test.setMock(HttpCalloutMock.class, new MockupSMSResponse());
        } 

        //Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);

        serviceTypeList = new List<Service_Type_Matrix__c>();
        caseList = new List<Case>();

        Service_Type_Matrix__c serviceType = New Service_Type_Matrix__c();
        serviceType.Segment__c = 'SBG';
        serviceType.Service_Level1__c = 'Service Level1';
        serviceType.Service_Level2__c = 'Service level2';
        serviceType.Service_Level3__c = 'Service level3';
        serviceType.Service_Level4__c = 'Service level4';
        serviceType.SLA__c = 7;
        serviceType.Severity__c = '1';
        serviceType.Responsible_BU__c = 'Test_Queue_SE';
        serviceType.active__c = true;
        serviceType.Service_issue_EN__c = 'english version';
        serviceType.Validate_Code__c = 'xxxx1';
        serviceType.Responsible_BU_Hop_2__c = 'RMC';
        serviceType.Responsible_BU_Hop_3__c ='test queue';
        serviceType.Closed_By_BU__c = 'REGISTER';
        serviceType.SLA_Hop_1_Day__c = 1;
        serviceType.SLA_Hop_2_Day__c = 1;
        serviceType.SLA_Hop_3_Day__c = 1;
        serviceType.SLA_Closed_By_BU_Day__c = 1;
        // [2020-03-26] Case Select Template.
        serviceType.Service_Template__c = 'CreditService';
        serviceTypeList.add(serviceType);

        Service_Type_Matrix__c serviceType2 = New Service_Type_Matrix__c();
        serviceType2.Segment__c = 'RBG';
        serviceType2.Service_Level1__c = 'Service_Level1';
        serviceType2.Service_Level2__c = 'Service_level2';
        serviceType2.Service_Level3__c = 'Service_level3';
        serviceType2.Service_Level4__c = 'Service_level4';
        serviceType2.SLA__c = 7;
        serviceType2.Severity__c = '1';
        serviceType2.Responsible_BU__c = 'Test_Queue_SE';
        serviceType2.active__c = true;
        serviceType2.Service_issue_EN__c = 'english version';
        serviceType2.Validate_Code__c = 'xxxx2';
        serviceType2.Responsible_BU_Hop_2__c = 'RMC';
        serviceType2.Responsible_BU_Hop_3__c ='test queue';
        serviceType2.Closed_By_BU__c = 'Test_Queue_SE';
        serviceType2.SLA_Hop_1_Day__c = 1;
        serviceType2.SLA_Hop_2_Day__c = 1;
        serviceType2.SLA_Hop_3_Day__c = 1;
        serviceType2.SLA_Closed_By_BU_Day__c = 1;
        // [2020-03-26] Case Select Template.
        serviceType2.Service_Template__c = 'Card';
        serviceTypeList.add(serviceType2);
        
        Service_Type_Matrix__c serviceType3 = New Service_Type_Matrix__c();
        serviceType3.Segment__c = 'WBG';
        serviceType3.Service_Level1__c = 'Service_Level1';
        serviceType3.Service_Level2__c = 'Service_level2';
        serviceType3.Service_Level3__c = 'Service_level3';
        serviceType3.Service_Level4__c = 'Service_level4';
        serviceType3.SLA__c = 7;
        serviceType3.Severity__c = '1';
        serviceType3.Responsible_BU__c = 'Test_Queue_SE';
        serviceType3.active__c = true;
        serviceType3.Service_issue_EN__c = 'english version';
        serviceType3.Validate_Code__c = 'xxxx3';
        // [2020-03-26] Case Select Template.
        serviceType3.Service_Template__c = 'CheckInvalidTransfer';
        serviceTypeList.add(serviceType3);
        
        
        Case caseObj = New Case(); 
        // caseObj.recordtypeID = SErecordType.id;
        caseObj.Subject = 'TestCase';
        caseObj.PTA_Segment__c = 'SBG';
        caseObj.Category__c = 'Service Level1';
        caseObj.Sub_Category__c = 'Service level2';
        caseObj.Product_Category__c = 'Service level3';
        caseObj.Issue__c = 'Service level4';
        caseObj.Status = 'New';
        caseObj.Description = 'Test create Case';
        caseObj.AccountId = acct.id;
        caseObj.Root_Cause_List__c = 'Other';
        caseObj.Root_Cause__c = 'test';
        caseObj.Resolution_LIst__c = 'Other';
        caseObj.Resolution__c =  'test';
        caseObj.Service_issue_EN__c = 'english version';
        caseObj.Service_Type_Matrix_Code__c = 'xxxx1';
        caseObj.Card_No_Full__c = '1234567890009123';
        caseObj.Card_No2_Full__c = '1234567890009125';
        caseObj.SMS_Code_New__c = 'RGB001';
        caseObj.Current_Service_Template__c = 'General';
        caseList.add(caseObj);
    }
    
    static testMethod void runTestClass() {        
        
         Test.startTest();
           //List<User> adminuser = [Select ID, Name from user where isActive = true  and profileID in: [Select ID from profile where name = 'System Administrator'] limit 2];
           system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            
               
            //Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
      if(acct.id == null || acct.id == ''){
              acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
           }
             //Create Entitlement
             Recordtype   typeID = [Select ID, Name from Recordtype where SobjectType = 'Entitlement' and Name = 'With Business Hours' limit 1];   
             Entitlement ent = new Entitlement(Name='Testing', AccountId= acct.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)), SLA_Day__c = 7, recordtypeID = typeID.id);
             insert ent;
             
             //Create Service Type matrix
             Service_Type_Matrix__c SeMatrix = New Service_Type_Matrix__c();
             SeMatrix.Segment__c = 'SBG';
             SeMatrix.Service_Level1__c = 'Service Level1';
             SeMatrix.Service_Level2__c = 'Service level2';
             SeMatrix.Service_Level3__c = 'Service level3';
             SeMatrix.Service_Level4__c = 'Service level4';
             SeMatrix.SLA__c = 7;
             SeMatrix.Severity__c = '1';
             SeMatrix.Responsible_BU__c = 'Test Queue SE';
             SeMatrix.active__c = true;
             SeMatrix.Closed_By_BU__c = 'Test Queue SE';
             SeMatrix.Validate_Code__c = 'xxxx4';
             // [2020-03-26] Case Select Template.
             SeMatrix.Service_Template__c = 'CreditService';
             insert SeMatrix;
             
             //Create Queue         
             Group que = new Group(Name='Test Queue SE', DeveloperName = 'Test_Queue_SE', type='Queue');
             insert que;
             QueuesObject q1 = new QueueSObject(QueueID = que.id, SobjectType = 'Case');
             insert q1;
             
             //Create Case
             Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
             List<Case> list_case = New list<Case>();
             Case caseNew1 = New Case(); 
             caseNew1.recordtypeID = SErecordType.id;
             caseNew1.Subject = 'TestCase';
             caseNew1.PTA_Segment__c = 'SBG';
             caseNew1.Category__c = 'Service Level1';
             caseNew1.Sub_Category__c = 'Service level2';
             caseNew1.Product_Category__c = 'Service level3';
             caseNew1.Issue__c = 'Service level4';
             caseNew1.Status = 'New';
             caseNew1.Description = 'Test create Case';
             caseNew1.AccountId = acct.id;
             caseNew1.CCRP_Number__c = '11-99770-9';
             caseNew1.SMS_Auto_Completed__c = true;
             caseNew1.Service_Type_Matrix_Code__c = 'xxxx4';
            caseNew1.Current_Service_Template__c = 'General';
             list_case.add(caseNew1);
             insert list_case;
             
             Case caseRecord = [Select ID, OwnerID, EntitlementId, Case_Severity__c from Case where id =: caseNew1.id];
             system.assertEquals(que.id, caseRecord.ownerID);
             system.assertEquals('1', caseRecord.Case_Severity__c);
             system.assertEquals(ent.ID, caseRecord.EntitlementId);
              
              CaseComment caComment = New CaseComment();  
              caComment.CommentBody = 'test 4567 2345 number';
              caComment.ParentId = caseRecord.id;
              insert caComment;              

             Test.stopTest();
         }
     }

    static testMethod void testWithClosedByBURegister() {
        setupData();
        serviceTypeList[0].Closed_By_BU__c = 'REGISTER';
        insert serviceTypeList;
        insert caseList;

        Test.startTest();
            caseList[0].Status = 'Resolved';  

            caseList[0].Contact_Person_Phone__c ='0800000000';
            caseList[0].Contact_Person_Phone_2__c ='0800000000';
            caseList[0].To_Ext_1__c ='401 ,403';
            caseList[0].To_Ext_2__c ='401 ,(403)- 1';
            caseList[0].Root_Cause_List__c = 'Other';
            caseList[0].Root_Cause__c = 'test';
            caseList[0].Resolution_LIst__c = 'Other';
            caseList[0].Resolution__c =  'test';
            caseList[0].Bulk_Send_SMS__c = true;
            caseList[0].SMS_Auto_Completed__c = true;
            caseList[0].SMS_Code_Resolved__c = 'CRMSV_001';
            caseList[0].Card_No_Full__c = '4534567890009123';
            caseList[0].Card_No2_Full__c = '6734567890009125';
            update caseList;

            Case caseObj = [SELECT Id,Subject,Owner.Name, Send_SMS_Details__c, Send_SMS_Status_Resolved__c FROM Case WHERE Id=: caseList[0].id];
            //System.assertEquals('test queue',caseObj.Owner.Name);

            //Test class CaseSMSButtonCtl
            ApexPages.StandardController smsButton = new ApexPages.StandardController(caseObj);
            CaseSMSButtonCtl casecls = new CaseSMSButtonCtl(smsButton);  
            casecls.validateSendSMS();
            casecls.getSMSStatus();
            casecls.getIsEnabled();        
            
        
            Case caseObj1 = [SELECT Id,Subject,Owner.Name, Send_SMS_Details__c FROM Case WHERE Id=: caseObj.id];
            ApexPages.StandardController smsButton2 = new ApexPages.StandardController(caseObj1);
            CaseSMSButtonCtl casecls2 = new CaseSMSButtonCtl(smsButton2);  
            casecls2.validateSendSMS();
            casecls2.getSMSStatus();  
           
            //--End test CaseSMSButtonCtl

            System.runAs(adminUser){
                try{
                    caseList[0].Status = 'Completed';
                    update caseList;
                }catch(Exception e){
                    System.assertEquals(e.getMessage().contains('Case close failed, Logged in User is not match to Close by BU'),true);
                }
            }
            
        Test.stopTest();
    }

    static testMethod void testWithClosedByBU() {
        setupData();
        serviceTypeList[0].Closed_By_BU__c = 'test queue';
        insert serviceTypeList;
        insert caseList;

        Test.startTest();
            caseList[0].Status = 'Resolved'; 
        
            caseList[1].Contact_Person_Phone__c ='0800000000';
            caseList[1].Contact_Person_Phone_2__c ='0800000000';
            caseList[1].To_Ext_1__c ='401 ,403';
            caseList[1].To_Ext_2__c ='401 ,(403)- 1';
            caseList[1].Status = 'Resolved'; 
            caseList[1].Root_Cause_List__c = 'Other';
            caseList[1].Root_Cause__c = 'test';
            caseList[1].Resolution_LIst__c = 'Other';
            caseList[1].Resolution__c =  'test';
            caseList[1].Bulk_Send_SMS__c = true;
            caseList[1].SMS_Auto_Completed__c = true;
            caseList[1].SMS_Code_Resolved__c = 'CRMSV_001';
        
            caseList[2].PTA_Segment__c = 'RBG';
            caseList[2].Category__c = 'Service_Level1';
            caseList[2].Sub_Category__c = 'Service_level2';
            caseList[2].Product_Category__c = 'Service_level3';
            caseList[2].Issue__c = 'Service_level4';  
            caseList[2].Service_Type_Matrix_Code__c = 'xxxx4';

            update caseList;            
        
            caseList[0].Status = 'Completed';
            caseList[0].CS_Status__c = '01. Onhand CS1';
            try{
              update caseList;
            }catch(Exception e){
                 System.debug(e.getMessage());
            }

        Test.stopTest();
    }


    static testMethod void testWithWrongClosedByBU() {
        setupData();
        serviceTypeList[0].Closed_By_BU__c = 'testqueue';
        insert serviceTypeList;
        insert caseList;

        Test.startTest();
            caseList[0].Status = 'Resolved';
            caseList[0].Bulk_Send_SMS__c = true;
           
            caseList[1].Status = 'Completed';
            caseList[1].Bulk_Send_SMS__c = true;
        
            caseList[2].Status = 'Resolved';
            caseList[2].Bulk_Send_SMS__c = true;
            caseList[2].SMS_Resolution_1__c = 'ปรับปรุงเงินคืน';
            caseList[2].Resolution_LIst__c = 'ปรับปรุงเงินคืน';
            caseList[2].SMS_Code_Resolution_1__c = 'CRMSV_001';
        
            update caseList;

            Case caseObj = [SELECT Id,Subject,Owner.Name,SMS_Code_Resolved__c,Status FROM Case WHERE Id=: caseList[0].id];
            System.assertEquals(UserInfo.getUserId(),caseObj.OwnerId);            
        
            ApexPages.StandardController smsButton3 = new ApexPages.StandardController(caseObj);
            CaseSMSButtonCtl casecls3 = new CaseSMSButtonCtl(smsButton3);  
          casecls3.validateSendSMS();      

        Test.stopTest();
    }

    static testMethod void testWithoutClosedByBU() {
        setupData();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'KYC_SUB_4G';
        Aconfig.Value__c = 'Grow_Blue';        
        insert Aconfig;
        // Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 

        // for(Case nCase : caseList) {
        //     nCase.RecordTypeId = SErecordType.id;
        // }
        insert serviceTypeList;
        insert caseList;

        Test.startTest();
            caseList[0].Status = 'Resolved';
            caseList[0].Description = null;
            caseList[0].AccountId = null;
            caseList[0].Contact_Person_Name__c = null;      
   
           try{
            update caseList;
           }catch(Exception e){
                System.debug(e.getMessage());
           }
        
        //Test apex class BatchPurgeCustomerComplaint
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().addMinutes(10).minute()); 
        String ss = String.valueOf(Datetime.now().second());
        
        String min3 = String.valueOf(Datetime.now().addMinutes(18).minute());
        String min4 = String.valueOf(Datetime.now().addMinutes(22).minute());  
        String nextFireTime3 = ss + ' ' + min3 + ' ' + hour + ' * * ?';
        String nextFireTime4 = ss + ' ' + min4 + ' ' + hour + ' * * ?';
        BatchPurgeCustomerComplaint batch2 = new BatchPurgeCustomerComplaint(); 
        System.schedule('Job Started At ' + nextFireTime3, nextFireTime4, batch2);
        
       // Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        if(acct.id == null){
            acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        } 
        List<Customer_Complaint__c> custCompList = new List<Customer_Complaint__c>();
        Customer_Complaint__c custComp = new Customer_Complaint__c();
        custComp.Name = 'Test';
        custComp.Account__c = acct.id;
        custComp.Status__c = 'Closed';
        custCompList.Add(custComp);
        insert custCompList;
        batch2.execute(null, custCompList); 
        
        Test.stopTest();
    }

    static testMethod void testUpdateToCEMController(){        
        
        Test.startTest();
        //23/06/2020 Fix Support Deploy Date 25/06/2020
        setupDataCase();

        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
        for(Case nCase : caseList) {
            nCase.recordTypeId = SErecordType.Id;
        }
        //setupData();
        insert serviceTypeList;
        insert caseList;

        TestUtils.createAppConfig();
    
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'ECM_Endpoint';
        Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
        apps.add(Aconfig);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'ECM_REQUEST_TIMEOUT';
        Aconfig3.Value__c = '60';        
        apps.add(Aconfig3);

        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'Purge_Case_Back_Date';
        Aconfig4.Value__c = '1';        
        apps.add(Aconfig4);

        insert apps;

        ECM_Key__mdt appConMeta_DocKey = [SELECT Id, Label, Key__c FROM ECM_Key__mdt WHERE Label = 'Eclient Doc Key'];

        ECM_MS_Doctype__c ecmDoc = new ECM_MS_Doctype__c();
        ecmDoc.Archival_Period__c = 1;
        ecmDoc.Disposal_Period__c = 3;
        ecmDoc.Expiry_Period__c = 10;
        ecmDoc.Channel__c = '05';
        ecmDoc.Source__c = 'A0291';
        ecmDoc.Type_Code__c = '20136';
        ecmDoc.Doc_Location__c = '/ECM/Customer Service Management/Customer Profile/Know Your Customer (KYC)';
        ecmDoc.Repository__c = 'ECMWBGDEV';
        ecmDoc.Doc_Template__c = 'CommercialDocument';
        ecmDoc.Key__c = appConMeta_DocKey.Key__c;
        ecmDoc.Segment__c ='C';
        ecmDoc.Document_Object__c = 'case';
        insert ecmDoc;

        Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());

        List<ECM_MS_Doctype__c> ecm = [SELECT Segment__c,Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c
                  ,Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c
                  ,Source__c,Key__c, Type_Name_TH__c FROM ECM_MS_Doctype__c LIMIT 1];

        string repositoryId=ecm[0].Repository__c;
    
        wsapiEcmClevelCom.dmsPropertiesType properties;
        string folderId;
        string folderPath;

        wsapiEcmClevelCom.dmsContentStreamType contentStream = new wsapiEcmClevelCom.dmsContentStreamType();
        contentStream.stream = 'TEST';

        UploadToECMController uploadECM = new UploadToECMController();
        UploadToECMController.upToECM res = uploadECM.createDocInECM(repositoryId,properties,folderId,folderPath,contentStream);
        Boolean isSuccess = res.isSuccess;
        String errorMessageRespone = res.errorMessage;
        String requestBody=res.requestToJSON;
        String responseBody=res.responseToJSON;
        Datetime startTime = res.startTime;
        Datetime endTime = res.endTime;
        String responseObjectId = res.responseObjectId;      

        ECM_Repository__c insertEcmRep = new ECM_Repository__c();
        insertEcmRep.Object_ID__c = responseObjectId;
        insertEcmRep.Case__c = caseList[0].id;
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        insertEcmRep.File_Link__c = fullFileURL+'/apex/viewECMfile?obId=' + responseObjectId;
        insertEcmRep.Document_Type__c = ecm[0].Type_Name_TH__c;
        insertEcmRep.Repository__c = ecm[0].Repository__c;
        insertEcmRep.ECM_Uploaded_Date_Time__c = DateTime.Now();
        insertEcmRep.File_Name__c = 'Test fileName';
        insertEcmRep.Uploaded_By__c = UserInfo.getUserid();
        insertEcmRep.ECM_App_ID__c = caseList[0].CaseNumber;
        insertEcmRep.ECM_MS_Doctype_Key__c = ecm[0].Key__c;

        insert insertEcmRep;

        //05-08-2020 - Fix Support Deploy Date: 06-08-2020
        /*caseList[0].Status = 'Completed';
        caseList[0].Root_Cause_List__c = 'Other';
        caseList[0].Root_Cause__c = 'test';
        caseList[0].Resolution_LIst__c = 'Other';
        caseList[0].Resolution__c =  'test';

        update caseList;*/

        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().addMinutes(10).minute()); 
        String ss = String.valueOf(Datetime.now().second());

        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        UpdateToECMController updateECM = new UpdateToECMController(); 
        System.enqueueJob(updateECM);
        // System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, updateECM);

        //Test apex class BatchPurgeCase
        TestUtils.createStatusCode(); 

        String min1 = String.valueOf(Datetime.now().addMinutes(15).minute());
        String min2 = String.valueOf(Datetime.now().addMinutes(20).minute());  
        String nextFireTime1 = ss + ' ' + min1 + ' ' + hour + ' * * ?';
        String nextFireTime2 = ss + ' ' + min2 + ' ' + hour + ' * * ?';
        BatchPurgeCase batch1 = new BatchPurgeCase(); 
        System.schedule('Job Started At ' + nextFireTime1, nextFireTime2, batch1);
        batch1.execute(null, caseList);

        Test.stopTest();
    }
    
     static testMethod void testEmailToCase() {
        setupData();
        
        Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        if(acct.id == null){
            acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        }
    
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

        Test.startTest();
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'Retail Service']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.recordtypeID = SErecordType.id;
        caseNew1.Subject = 'ผลิตภัณฑ์สินเชื่อ';
        caseNew1.Status = 'New';
        caseNew1.Description = 'Test create Case';
        caseNew1.AccountId = acct.id;
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Origin = 'Email - TMBWeb';
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);

        insert list_case;

        Test.stopTest();
    }
    
    static testMethod void testEmailMEToCase() {
        setupData();
        
        Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
           
        if(acct.id == null){
            acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        }
    
        Skill_Master__c skill = new Skill_Master__c();
        skill.Topic__c = 'MEBYTMB';
        skill.Source__c = 'Email - ME';
        skill.Assign_to_Queue__c = 'Email - TMB';
        skill.Segment__c = 'SBG';
        skill.Service_Level1__c = 'Service_Level1';
        skill.Service_Level2__c = 'Service_Level2';
        skill.Service_Level3__c = 'Service_Level3';
        skill.Validate_Code__c = 'X0001';
        skill.Problem_Type__c = 'N/A';
        skill.Journey__c = 'N/A';
        insert skill;  

        Test.startTest();
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'Retail Service']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.recordtypeID = SErecordType.id;
        caseNew1.Subject = 'MEBYTMB';
        caseNew1.Status = 'New';
        caseNew1.Description = 'Test create Case';
        caseNew1.AccountId = acct.id;
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Origin = 'Email - ME';
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);

        insert list_case;

        Test.stopTest();
    }

    static testMethod void testAutoSMSCase() {
        setupData();
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Resolution_List__c = 'ปรับปรุงเงินคืน';
        testCase.Contact_Person_Name__c = 'TEST TEST';
        testCase.Contact_Person_Phone__c ='0800000000';
        testCase.Contact_Person_Phone_2__c ='0800000000';
        testCase.To_Ext_1__c ='401 ,403';
        testCase.To_Ext_2__c ='401 ,(403)- 1';

        testCase.Contact_Person_Email__c = 'test@gmail.com';
        testCase.Current_Service_Template__c = 'General';

        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
        testCase.recordtypeID = SErecordType.id;
        insert testCase;
        Test.startTest();
        testCase.Status = 'Resolved';
        testCase.Closed_By_BU__c = 'TEST';
        testCase.Subject = 'TEST AUTO SMS';
        testCase.Service_Type_Matrix_Code__c = 'V0012';
        testCase.SMS_Resolution_1__c = 'ปรับปรุงเงินคืน';
        testCase.SMS_Resolution_2__c = 'ยืนยันรายการปกติ';
        testCase.SMS_Code_Resolution_1__c = 'CRMRBG_012';
        testCase.SMS_Code_Resolution_2__c = 'CRMRBG_001';
        testCase.Root_Cause_List__c = 'Customer_ลูกค้าร้องขอบริการ';
        testCase.Amount_Received_Deposit_to_Account__c = 200;
        testCase.Transaction_Date__c = system.today();
        testCase.Product_Number_1__c = '223433345433';
        testCase.Product_Type_1__c = 'Deposit';
        testCase.Amount_Withdrawal_Deposit__c = 200;
        testCase.Transaction_Time__c = Time.newInstance(1, 2, 3, 4);
        testCase.Transaction_Type__c = 'ถอน';
        testCase.Transaction_Method__c= 'เงินสด';
        testCase.ATM_Bank_Owner__c = 'CHINA UNION PAY (CUP)';
        
        update testCase;
        Test.stopTest();
    }

    @isTest
    static void testAutoAssignKYCCaseOwner() {
        setupData();
        Id KYCRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('KYC System').getRecordTypeId();
        Profile RM_Profile = [SELECT Id, Name FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1];
        Profile Admin_Profile = [SELECT Id, Name FROM Profile WHERE Name = 'TMB System Administrator' LIMIT 1];

        Id busHoursRecordId = Schema.SObjectType.Entitlement.getRecordTypeInfosByName().get('With Business Hours').getRecordTypeId();

        Service_Type_Matrix__c kycMatrix = new Service_Type_Matrix__c(Validate_Code__c='K0001', Segment__c='WBG',Service_Level1__c='Request',Service_Template__c='KYCReview', SLA__c=4);
        insert kycMatrix;

        // Account entitleCus = new Account(Name = 'Test cust');
        // insert entitleCus;

        Entitlement entitle = new Entitlement(
            recordTypeId=busHoursRecordId, 
            Name='test entitle', 
            AccountId=acct.Id,
            StartDate=Date.today(),
            EndDate=Date.today().addDays(4),
            SLA_Day__c=4
        );
        insert entitle;

        Entitlement ent = [select Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AccountId, Type, ServiceContractId, ContractLineItemId, AssetId, StartDate, EndDate, SlaProcessId, BusinessHoursId, IsPerIncident, CasesPerEntitlement, RemainingCases, Status, SLA_Day__c from Entitlement];

        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'KYC_SUB_4G';
        Aconfig.Value__c = 'Grow_Blue';        
        insert Aconfig;
        
        List<User> User_List = TestUtils.createUsers(3, 'TestRM', 'TestRMUser', 'rmuser@test.com', false);
        insert User_List.get(2);

        User_List.get(0).ProfileId = RM_Profile.Id;
        User_List.get(0).Employee_Id__c = 'TT01';
        User_List.get(0).ManagerId = User_List.get(2).Id;
        insert User_List.get(0);

        User_List.get(1).ProfileId = Admin_Profile.Id;
        User_List.get(1).Employee_Id__c = 'TT02';
        User_List.get(1).ManagerId = User_List.get(2).Id;
        insert User_List.get(1);

        List<Account> Customer_List = TestUtils.createAccounts(2, 'test kyc','Individual', false);
        Customer_List.get(0).OwnerId = User_List.get(0).Id;
        Customer_List.get(1).OwnerId = User_List.get(1).Id;
        insert Customer_List;

        Test.startTest();
            List<Case> testCases = new List<Case>();
            Case testCaseRMUser = new Case(
                Status = 'New',
                RecordTypeId = KYCRecordTypeId,
                Service_Type_Matrix_Code__c = 'K0001',
                AccountId = Customer_List.get(0).Id,
                KYC_Risk_Level__c = '2'
            );
            Case testCaseBITeam = new Case(
                Status = 'New',
                RecordTypeId = KYCRecordTypeId,
                Service_Type_Matrix_Code__c = 'K0001',
                AccountId = Customer_List.get(1).Id
            );
            testCases.add(testCaseRMUser);
            testCases.add(testCaseBITeam);
            insert testCases;

            List<Case> KYCCaseList = [SELECT Id FROM Case WHERE RecordTypeId =: KYCRecordTypeId];
            System.assertEquals(2, KYCCaseList.size());
        Test.stopTest();
    }

    @isTest
    static void testUpdateKYCCaseHighRiskLevel() {
        setupData();
        Id KYCRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('KYC System').getRecordTypeId();
        Profile RM_Profile = [SELECT Id, Name FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1];
        Profile BDM_Profile = [SELECT Id, Name FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1];
        Profile SEPM_Profile = [SELECT Id, Name FROM Profile WHERE Name = 'TMB SEPM Profile' LIMIT 1];

        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'KYC_SUB_4G';
        Aconfig.Value__c = 'Grow_Blue';        
        insert Aconfig;
        
        List<User> MngUser = TestUtils.createUsers(2, 'TestRMMng1', 'TestRMMng1', 'TestRMMng1@test.com', false);
        MngUser.get(1).Employee_Id__c = 'TMSAZ02';
        insert MngUser.get(1);

        MngUser.get(0).Employee_Id__c = 'TMSAZ01';
        MngUser.get(0).ManagerId = MngUser.get(1).Id;
        insert MngUser.get(0);

        List<User> User_List = TestUtils.createUsers(4, 'TestRM', 'TestRMUser', 'rmuser@test.com', false);
        User_List.get(0).ProfileId = RM_Profile.Id;
        User_List.get(0).Employee_Id__c = 'TTx01';
        User_List.get(0).ManagerId = MngUser.get(0).Id;

        User_List.get(1).ProfileId = RM_Profile.Id;
        User_List.get(1).Employee_Id__c = 'TTx02';
        User_List.get(1).ManagerId = MngUser.get(0).Id;

        User_List.get(2).ProfileId = BDM_Profile.Id;
        User_List.get(2).Employee_Id__c = 'TTx03';
        User_List.get(2).ManagerId = MngUser.get(0).Id;

        User_List.get(3).ProfileId = SEPM_Profile.Id;
        User_List.get(3).Employee_Id__c = 'TTx04';
        User_List.get(3).ManagerId = MngUser.get(0).Id;
        insert User_List;

        List<Account> Customer_List = TestUtils.createAccounts(2, 'test kyc','Individual', false);
        Customer_List.get(0).OwnerId = User_List.get(0).Id;
        Customer_List.get(1).OwnerId = User_List.get(1).Id;
        insert Customer_List;

        List<Case> testCases = new List<Case>();
        Case testCase1 = new Case(
            Status = 'New',
            RecordTypeId = KYCRecordTypeId,
            Service_Type_Matrix_Code__c = 'K0001',
            AccountId = Customer_List.get(0).Id,
            KYC_Risk_Level__c = '3'
        );
        Case testCase2 = new Case(
            Status = 'New',
            RecordTypeId = KYCRecordTypeId,
            Service_Type_Matrix_Code__c = 'K0001',
            AccountId = Customer_List.get(1).Id,
            KYC_Risk_Level__c = '3'
        );
        testCases.add(testCase1);
        testCases.add(testCase2);
        insert testCases;

        Test.startTest();
            testCases.get(0).OwnerId = User_List.get(2).Id;
            testCases.get(1).OwnerId = User_List.get(3).Id;
            update testCases;
            // List<Case> bdmCase = [SELECT Id FROM Case WHERE Id =: testCases.get(0).Id];
            // List<Case> sepmCase = [SELECT Id FROM Case WHERE RecordTypeId =: KYCRecordTypeId];
            System.assertEquals(testCases.get(0).KYC_Approver2__c, User_List.get(2).Manager.ManagerId);
            System.assertEquals(testCases.get(1).KYC_Approver2__c, User_List.get(3).Manager.ManagerId);
        Test.stopTest();
    }
}