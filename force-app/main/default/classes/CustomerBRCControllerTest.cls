@isTest
public class CustomerBRCControllerTest {
    public static final UserRole USERROLE_BRANCH_MANAGER = [SELECT Id, Name FROM UserRole WHERE Name = 'BR-MGR-Zone-7440' LIMIT 1]; 
    public static final UserRole USERROLE_BRANCH_SALES = [SELECT Id, Name FROM UserRole WHERE Name = 'BR-Sales-Zone-7440' LIMIT 1]; 
    public static final Group GROUP7440_INFO = [SELECT Id, DeveloperName, RelatedId, Type FROM Group WHERE DeveloperName = 'Zone_7440' and Type = 'RoleAndSubordinates' LIMIT 1]; 
    public static final Group GROUP7450_INFO = [SELECT Id, DeveloperName, RelatedId, Type FROM Group WHERE DeveloperName = 'Zone_7450' and Type = 'Role' LIMIT 1]; 


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
        system.runAs(adminUser){
            TestUtils.createAppConfig();
            

            User managerUser = new User();
            managerUser.FirstName = 'MngUser';  
            managerUser.LastName = 'TestManager';
            managerUser.UserName='mng_testmanager@tmb.com';
            managerUser.Email='mng_testmanager@tmbbank.com';
            managerUser.Alias='MNGTest';
            managerUser.LocaleSidKey='en_US';
            managerUser.LanguageLocaleKey='en_US'; 
            managerUser.EmailEncodingKey='ISO-8859-1'; 
            managerUser.ProfileId = RTL_TestUtility.RTL_BRANCH_SALES_PROFILE_ID; 
            managerUser.TimeZoneSidKey='America/New_York';
            managerUser.UserRoleId = USERROLE_BRANCH_MANAGER.Id;
            //managerUser.UserRoleName__c = USERROLE_BRANCH_MANAGER.Name;
            managerUser.IsActive = true;
            insert managerUser;
            System.debug('managerUser.id: '+managerUser.id);

            User saleUser = new User();
            saleUser.FirstName = 'SaleUser';  
            saleUser.LastName = 'TestSale';
            saleUser.UserName='sale_testuser@tmb.com';
            saleUser.Email='sale_testuser@tmbbank.com';
            saleUser.Alias='SALETest';
            saleUser.LocaleSidKey='en_US';
            saleUser.LanguageLocaleKey='en_US'; 
            saleUser.EmailEncodingKey='ISO-8859-1'; 
            saleUser.ProfileId = RTL_TestUtility.RTL_BRANCH_SALES_PROFILE_ID; 
            saleUser.TimeZoneSidKey='America/New_York';
            saleUser.UserRoleId = USERROLE_BRANCH_SALES.Id;
            saleUser.IsActive = true;
            insert saleUser;
            System.debug('saleUser.id: '+saleUser.id);

            Group publicGroup = new Group();
            publicGroup.Name = 'Test public group';
            publicGroup.DeveloperName = 'Test_public_group';
            publicGroup.type = 'Regular';
            insert publicGroup;     

            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = GROUP7440_INFO.Id; //managerUser.id;
            member1.GroupId = publicGroup.Id;
            groupMemberList.add(member1);

            GroupMember member2 = new GroupMember();
            member2.UserOrGroupId = GROUP7450_INFO.Id; //managerUser.id;
            member2.GroupId = publicGroup.Id;
            groupMemberList.add(member2);

            GroupMember member3 = new GroupMember();
            member3.UserOrGroupId = managerUser.id;
            member3.GroupId = publicGroup.Id;
            groupMemberList.add(member3);
            insert groupMemberList;           
        }
    }

    @isTest
    static void getReportId()
    {
        Test.startTest();
        CustomerBRCController.getReportId('Report_BRC_Customer_List');       
        Test.stopTest();       
    }

    @isTest
    static void testManagerUser(){
        Test.startTest();
        User managerUser = [SELECT Id, Name FROM User WHERE IsActive = true AND FirstName = 'MngUser' LIMIT 1];

        system.runAs(managerUser){
            User testUser = CustomerBRCController.getCurrentUser(); 
            Group testGroup = CustomerBRCController.getGroupId('Test_public_group');  
            Boolean isAccess = CustomerBRCController.getGroupMemberIdList(testGroup.Id, testUser, testUser.UserRoleId);
        }
        Test.stopTest();   
    }

    @isTest
    static void testSaleUser(){
        Test.startTest();
        User saleUser = [SELECT Id, Name FROM User WHERE IsActive = true AND FirstName = 'SaleUser' LIMIT 1];

        system.runAs(saleUser){
            User testUser = CustomerBRCController.getCurrentUser(); 
            Group testGroup = CustomerBRCController.getGroupId('Test_public_group');  
            Boolean isAccess = CustomerBRCController.getGroupMemberIdList(testGroup.Id, testUser, testUser.UserRoleId);
        }
        Test.stopTest();   
    }

    @isTest
    static void testAdminUser(){
        Test.startTest();
        system.runAs(adminUser){
            User testUser = CustomerBRCController.getCurrentUser(); 
            Group testGroup = CustomerBRCController.getGroupId('Test_public_group');  
            Boolean isAccess = CustomerBRCController.getGroupMemberIdList(testGroup.Id, testUser, testUser.UserRoleId);
        }
        Test.stopTest();   
    }

}