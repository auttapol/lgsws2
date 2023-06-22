@isTest
public class AcceptWorkOrderControllerTest {
    
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
        // Implement test code
        
        system.runAs(adminUser){
            TestUtils.createAppConfig();
            
            Group queue = new Group();
            queue.Name = 'test queue';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;               
            
            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = adminUser.id;
            member1.GroupId = queue.Id;
            groupMemberList.add(member1);
            
            insert groupMemberList;
        }
    }
    
    @isTest
    static void acceptWorkOrder()
    {
        Test.startTest();
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;     
        
        Work_Order__c wo = new Work_Order__c();
        insert wo;
        AcceptWorkOrderController.acceptWorkOrder(wo.Id);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void acceptWorkOrderError()
    {
        Test.startTest();
        
        AcceptWorkOrderController.acceptWorkOrder(null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void getGroupMember()
    {
        Test.startTest();
        GroupMember gm = [SELECT UserOrGroupId,GroupId FROM GroupMember LIMIT 1];
        AcceptWorkOrderController.getGroupMember(gm.GroupId);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void checkBranch()
    {
        Test.startTest();
        Group g = [SELECT Id,Name FROM Group LIMIT 1];
        AcceptWorkOrderController.checkBranch(g.Id);
        
        Test.stopTest();
        
    } 
    
    @isTest
    static void getCurrentUser()
    {
        Test.startTest();
        AcceptWorkOrderController.getCurrentUser();       
        Test.stopTest();       
    }
    
}