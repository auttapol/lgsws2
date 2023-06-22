@isTest 
public class Main_Bank_List_View_Trigger_Test { 

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
        //   Test.setMock(HttpCalloutMock.class, new MockupSMSResponse());
        }
                acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        //insert acct;
                 system.debug('acct :' + acct);
   

    }
     static testMethod void runTestClass() {  
                 setupData();
        account ac = [select id , TMB_Customer_ID_PE__c from account limit 1 ];
         ac.TMB_Customer_ID_PE__c ='00000000';
         update ac;
         system.debug('ac.TMB_Customer_ID_PE__c :' +ac.TMB_Customer_ID_PE__c);
         Test.startTest();
           //List<User> adminuser = [Select ID, Name from user where isActive = true  and profileID in: [Select ID from profile where name = 'System Administrator'] limit 2];
           system.runAs(adminUser){
            //Create Customer
            TestUtils.createAppConfig();
            	Main_Bank_List_View__c mb = new Main_Bank_List_View__c();
               mb.customer_id__c = ac.TMB_Customer_ID_PE__c;
               mb.Has_Call_List__c = 'Y';
               insert mb;
           }
     }
    
}