@IsTest
public class TaskTriggerTest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    } 
    public static String STR_POSITIVE = 'positive';
    public static String STR_NEGATIVE = 'negative';
    
    public static testmethod void RunPositiveTestTask(){
        System.debug(':::: RunPositiveTestTask Start ::::');
        //TestInit.createUser(false);
        //User u = TestInit.us;
        User u= [SELECT ID,Zone__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            //Test for T02            
            TestInit.createAccount(3);
            TestInit.createTarget(TestInit.accountList.values()); 
            TEST.startTest();
            flowTest(STR_POSITIVE);    
            TEST.stopTest();
        }
        System.debug(':::: RunPositiveTestTask End ::::');
    }
    
    public static void flowTest(String testMode){
        TestInit.createTask(TestInit.accountList.values());
                    List<Target__c> listTarget = [select OwnerId,Zone__c,Monthly_Contacted_Actual__c 
                                from Target__c 
                                where Id IN :TestInit.targetList.keySet()];
            for(Target__c t : listTarget){
                System.assertEquals(1,t.Monthly_Contacted_Actual__c);    
            }
    }
    

    public static testmethod void TestTriggerTask(){
       
       TaskTriggerHandler TaskTrigger= new TaskTriggerHandler();
       Task t1= new task();
       insert t1;
       
       //Create Account
        Account  testAccount1 =  TestUtils.createAccounts(1,'TaskTrigger','TestTriggerTask',true).get(0);
        
        
        User us = [SELECT ID,Zone__c FROM User WHERE ID=:testAccount1.OwnerID LIMIT 1];
        
        //List<Account> accountList = [select id from Account where id=:testAccount1.id];
        //TestInit.createTask(accountList);
        
       Task t2= new task(Subject='Call',ActivityDate=System.Today(),whatid=testAccount1.id);
       insert t2;
       
       t2.Subject='Call';
       update t2;
       delete t2;
       
       //TaskTrigger.checkConditionT02(t2,t1);
       
       
        
      
       //TaskTrigger.Trigger_T02(t2,t1,'Test');
       

    }
    
}