@isTest 
public class mainBankInfoControllerTest { 

    static List<Service_Type_Matrix__c> serviceTypeList;
    static List<Case> caseList;
    static Account acct = new Account();

    static User adminUser{
        get
        {
            if(adminUser == null){
                adminUser = [SELECT Id,Name , Profile.Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.SYSADMIN_PROFILE_ID LIMIT 1];
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
             list<Data_Security_Matrix__c> dsm = new  list<Data_Security_Matrix__c>();
        Data_Security_Matrix__c ds1 = new Data_Security_Matrix__c();
		ds1.Access_Type__c ='Authorize Only';
                ds1.Profile_Name__c ='System Administrator';

                ds1.Data_Matrix_Key__c ='TMB CM Product Manager ProfileCommCust:Customer Product Holding (Low)';
                        ds1.Section_Name__c  ='RtlCust:MI Benefits';
                dsm.add(ds1);

      /*  Data_Security_Matrix__c ds2 = new Data_Security_Matrix__c();
		ds2.Access_Type__c ='All';
                ds2.Profile_Name__c ='System Administrator';

                ds2.Data_Matrix_Key__c ='TMB CM Product Manager ProfileCommCust:Customer Product Holding (Low)';
                        ds2.Section_Name__c  ='RtlCust:MI Benefits';
        
        dsm.add(ds2);*/
        insert dsm; 


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
			system.debug('adminUser.Profile.Name :' +adminUser.Profile.Name);

            //Create Customer
            TestUtils.createAppConfig();
            /*	Main_Bank_List_View__c mb = new Main_Bank_List_View__c();
               mb.customer_id__c = ac.TMB_Customer_ID_PE__c;
               insert mb;*/
          	//     mainBankInfoController mbc = new mainBankInfoController();
            account testac = mainBankInfoController.getAccount(ac.id);
            ac.Rtl_wealth_rm__c = adminUser.Id;
            update ac;
        	Boolean checktest = mainBankInfoController.checkPermission(ac.id);
            
            AccountTeamMember atm = new AccountTeamMember();
            atm.AccountId = ac.Id;
            atm.AccountAccessLevel = 'Edit';
            atm.UserId = userinfo.getUserId();
            insert atm;
             mainBankInfoController.checkPermission(ac.id);
		}
    }
    
    @isTest
    static void test(){
        TestUtils.createAppConfig();
        
        Account acc = new Account();
        acc.Name = 'Acc';
        acc.Phone = '0933332222';
        acc.Mobile_Number_PE__c = '022838388';
        acc.Email_Address_PE__c = 'aa@a.a';
        insert acc;
        
        List<String> fields = new List<String>{'Name'};
		List<String> trans = new List<String>{'X4G_Base__c'};
        mainBankInfoController.getDescribeFieldResultAndValue(acc.Id, fields, trans );
        mainBankInfoController.verifyFieldSecurity('Section', 'System Administrator',acc.Id);
        mainBankInfoController.CallCYCCampaignMappingInqAPI('test', null, null, null);
    }
    
}