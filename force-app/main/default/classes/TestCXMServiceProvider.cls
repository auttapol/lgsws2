@IsTest
public class TestCXMServiceProvider{
	static List<Service_Type_Matrix__c> serviceTypeList;
    static List<Case> caseList;

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
    @testSetup static void setup() {
        system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);

            List<AppConfig__c> apps = new  List<AppConfig__c>();
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
            Aconfig.Value__c = 'true';        
            apps.add(Aconfig);
            insert apps;

            //for Integration_Mapping__c
            TestUtils.prepareIntegrationMapping();
            
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
             SeMatrix.Validate_Code__c = 'xxxx5';
             // [2020-03-26] Case Select Template.
             SeMatrix.Service_Template__c = 'CreditService';
             insert SeMatrix;
             
             //Create Queue         
             Group que = new Group(Name='Test Queue SE', DeveloperName = 'Test_Queue_SE', type='Queue');
             insert que;
             QueuesObject q1 = new QueueSObject(QueueID = que.id, SobjectType = 'Case');
             insert q1;

            TestUtils.prepareEIMmaps();
             //Create Case
             Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
             List<Case> list_case = New list<Case>();
             Case caseNew1 = New Case(); 
             caseNew1.recordtypeID = SErecordType.id;
             caseNew1.Subject = 'TestCase';
             caseNew1.PTA_Segment__c = 'RBG';
             caseNew1.Category__c = 'Complaint';
             caseNew1.Sub_Category__c = 'Service level2';
             caseNew1.Product_Category__c = 'Service level3';
             caseNew1.Issue__c = 'Service level4';
             caseNew1.Status = 'New';
             caseNew1.Description = 'Test create Case';
             caseNew1.AccountId = acct.id;
             caseNew1.CCRP_Number__c = '11-99770-9';
             caseNew1.Journey__c     = 'Journey__c';
             caseNew1.Problem_Type__c = 'Problem_Type__c';
             caseNew1.Service_Type_Matrix_Code__c = 'xxxx5';
        	 caseNew1.Current_Service_Template__c = 'General';
             list_case.add(caseNew1);

             //05-08-2020 - Fix Support Deploy Date: 06-08-2020
             /*Case caseNew2 = New Case(); 
             caseNew2.recordtypeID = SErecordType.id;
             caseNew2.Subject = 'TestCase';
             caseNew2.PTA_Segment__c = 'RBG';
             caseNew2.Category__c = 'Complaint';
             caseNew2.Sub_Category__c = 'Service level2';
             caseNew2.Product_Category__c = 'Service level3';
             caseNew2.Issue__c = 'Service level4';
             caseNew2.Status = 'New';
             caseNew2.FCR__c = true;
             caseNew2.Root_Cause_List__c = 'Other';
             caseNew2.Root_Cause__c = 'test';
             caseNew2.Resolution_LIst__c = 'Other';
             caseNew2.Resolution__c =  'test';   
             caseNew2.Description = 'Test create Case';
             caseNew2.AccountId = acct.id;
             caseNew2.CCRP_Number__c = '11-99770-9';
             caseNew2.Journey__c     = 'Journey__c';
             caseNew2.Problem_Type__c = 'Problem_Type__c';
             caseNew2.Service_Type_Matrix_Code__c = 'xxxx5';
             list_case.add(caseNew2);*/

             insert list_case;
        }
    }
	public static testmethod void testCreateCaseAndCompleted() {
		Test.startTest();
         	//List<User> adminuser = [Select ID, Name from user where isActive = true  and profileID in: [Select ID from profile where name = 'System Administrator'] limit 2];
         	/*system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);

            List<AppConfig__c> apps = new  List<AppConfig__c>();
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
            Aconfig.Value__c = 'true';        
            apps.add(Aconfig);
            insert apps;

            //for Integration_Mapping__c
            TestUtils.prepareIntegrationMapping();
            
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
             SeMatrix.Validate_Code__c = 'xxxx5'; 
             insert SeMatrix;
             
             //Create Queue         
             Group que = new Group(Name='Test Queue SE', DeveloperName = 'Test_Queue_SE', type='Queue');
             insert que;
             QueuesObject q1 = new QueueSObject(QueueID = que.id, SobjectType = 'Case');
             insert q1;

            TestUtils.prepareEIMmaps();
             //Create Case
             Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
             List<Case> list_case = New list<Case>();
             Case caseNew1 = New Case(); 
             caseNew1.recordtypeID = SErecordType.id;
             caseNew1.Subject = 'TestCase';
             caseNew1.PTA_Segment__c = 'RBG';
             caseNew1.Category__c = 'Complaint';
             caseNew1.Sub_Category__c = 'Service level2';
             caseNew1.Product_Category__c = 'Service level3';
             caseNew1.Issue__c = 'Service level4';
             caseNew1.Status = 'New';
             caseNew1.Description = 'Test create Case';
             caseNew1.AccountId = acct.id;
             caseNew1.CCRP_Number__c = '11-99770-9';
             caseNew1.Journey__c     = 'Journey__c';
             caseNew1.Problem_Type__c = 'Problem_Type__c';
             caseNew1.Service_Type_Matrix_Code__c = 'xxxx5';
             list_case.add(caseNew1);

             Case caseNew2 = New Case(); 
             caseNew2.recordtypeID = SErecordType.id;
             caseNew2.Subject = 'TestCase';
             caseNew2.PTA_Segment__c = 'RBG';
             caseNew2.Category__c = 'Complaint';
             caseNew2.Sub_Category__c = 'Service level2';
             caseNew2.Product_Category__c = 'Service level3';
             caseNew2.Issue__c = 'Service level4';
             caseNew2.Status = 'New';
             caseNew2.FCR__c = true;
             caseNew2.Root_Cause_List__c = 'Other';
             caseNew2.Root_Cause__c = 'test';
             caseNew2.Resolution_LIst__c = 'Other';
             caseNew2.Resolution__c =  'test';   
             caseNew2.Description = 'Test create Case';
             caseNew2.AccountId = acct.id;
             caseNew2.CCRP_Number__c = '11-99770-9';
             caseNew2.Journey__c     = 'Journey__c';
             caseNew2.Problem_Type__c = 'Problem_Type__c';
             caseNew2.Service_Type_Matrix_Code__c = 'xxxx5';
             list_case.add(caseNew2);

             insert list_case;*/
			 List<Case> list_case = [SELECT Id,Status FROM Case LIMIT 2];
             Case caseUpdate1 = New Case(Id = list_case[0].Id); 
             caseUpdate1.Status = 'Completed';
             update caseUpdate1;

             Test.stopTest();
         //}
	}

    public static testmethod void testRunBatchForRetry() {
        Test.startTest();
            //List<User> adminuser = [Select ID, Name from user where isActive = true  and profileID in: [Select ID from profile where name = 'System Administrator'] limit 2];
            /*system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);

            List<AppConfig__c> apps = new  List<AppConfig__c>();
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
            Aconfig.Value__c = 'true';        
            apps.add(Aconfig);
            insert apps;

            //for Integration_Mapping__c
            TestUtils.prepareIntegrationMapping();
         
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
             SeMatrix.Validate_Code__c = 'xxxx6';  
             insert SeMatrix;
             
             //Create Queue         
             Group que = new Group(Name='Test Queue SE', DeveloperName = 'Test_Queue_SE', type='Queue');
             insert que;
             QueuesObject q1 = new QueueSObject(QueueID = que.id, SobjectType = 'Case');
             insert q1;             
            
            TestUtils.prepareEIMmaps();

             //Create Case
            Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
            List<Case> list_case = New list<Case>();
            Case caseNew1 = New Case(); 
            caseNew1.recordtypeID = SErecordType.id;
            caseNew1.Subject = 'TestCase';
            caseNew1.PTA_Segment__c = 'RBG';
            caseNew1.Category__c = 'Complaint';
            caseNew1.Sub_Category__c = 'Service level2';
            caseNew1.Product_Category__c = 'Service level3';
            caseNew1.Issue__c = 'Service level4';
            caseNew1.Status = 'New';
            caseNew1.Description = 'Test create Case';
            caseNew1.AccountId = acct.id;
            caseNew1.CCRP_Number__c = '11-99770-9';
            caseNew1.Journey__c     = 'Journey__c';
            caseNew1.Problem_Type__c = 'Problem_Type__c';
            caseNew1.CXM_Latest_Response__c = 'FAIL_WAIT_FOR_RETRY';
            caseNew1.CXM_Latest_Status__c = 'FAIL_WAIT_FOR_RETRY';
            caseNew1.Service_Type_Matrix_Code__c = 'xxxx6';
            list_case.add(caseNew1);

            Case caseNew2 = New Case(); 
            caseNew2.recordtypeID = SErecordType.id;
            caseNew2.Subject = 'TestCase';
            caseNew2.PTA_Segment__c = 'RBG';
            caseNew2.Category__c = 'Complaint';
            caseNew2.Sub_Category__c = 'Service level2';
            caseNew2.Product_Category__c = 'Service level3';
            caseNew2.Issue__c = 'Service level4';
            caseNew2.Status = 'New';
            caseNew2.FCR__c = true;
            caseNew2.Root_Cause_List__c = 'Other';
            caseNew2.Root_Cause__c = 'test';
            caseNew2.Resolution_LIst__c = 'Other';
            caseNew2.Resolution__c =  'test';    
            caseNew2.Description = 'Test create Case';
            caseNew2.AccountId = acct.id;
            caseNew2.CCRP_Number__c = '11-99770-9';
            caseNew2.Journey__c     = 'Journey__c';
            caseNew2.Problem_Type__c = 'Problem_Type__c';
            caseNew2.CXM_Latest_Response__c = 'OFFHOUR_RETRY';
            caseNew2.CXM_Latest_Status__c = 'OFFHOUR_RETRY';
            caseNew2.Service_Type_Matrix_Code__c = 'xxxx6';
            list_case.add(caseNew2);

            insert list_case;*/
        
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().addMinutes(10).minute()); 
            String ss = String.valueOf(Datetime.now().second());

            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            //CXMServiceProvider s = new CXMServiceProvider('CXMCaseService'); 
            Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> schemaFieldMap = global_describe.get('Case').getDescribe().fields.getMap();
            List<String> fieldsList = new List<String>();
            for (String field : schemaFieldMap.keySet()) {
                fieldsList.add(String.valueOf(schemaFieldMap.get(field)));
            }
            String caseField = String.join( fieldsList, ', ' );
            String query = 'select ' + caseField + ' from Case limit 1';
            List<Case> caseList = Database.query(query);
            Map<Id, Case> caseNew = new Map<Id, Case>();
            Map<Id, Case> caseOld = new Map<Id, Case>();
            for (Case c : caseList) {
                caseNew.put(c.Id, c);
                caseOld.put(c.Id, c);
            }
            CXMServiceProvider s = new CXMServiceProvider(); 
            System.enqueueJob(s);
            CXMServiceProvider cxm = new CXMServiceProvider();
            cxm.integrateToCXM(caseOld,caseNew);
            cxm.integrateToCXMForSales(caseOld,caseNew);
            cxm.integrateToCXM(caseOld,caseNew,false);
            // System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);

        //}
            Test.stopTest();
        
    }

  
}