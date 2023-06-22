@istest
public class RTL_ReferralAssignmentTest {
    static List<User> userList = TestUtils.createUsers(1,'TestUtilTest', 'Utiltest','testUtil@tmbbank.com', true);
    static Group branchQueue;
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();   
        AppConfig__c app = new AppConfig__c();
        app.Name = 'RTL_Referral_Assignment_ISNULL';
        app.Value__c = 'IS NULL';
        insert app;
        app = new AppConfig__c();
        app.Name = 'RTL_Referral_Assignment_NOTNULL';
        app.Value__c = 'IS NOT NULL';
        insert app;
        
        branchQueue = [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'RTLQ_001' LIMIT 1];
        
        RTL_Referral_Assignment__c objCond = new RTL_Referral_Assignment__c();
        objCond.RTL_Active_Flag__c = true;
        objCond.RTL_Priority__c = 1;
        objCond.RTL_Referral_Type__c = 'Refer_to_Retail';
        objCond.RTL_Referral_Field_Criteria_1__c = 'RTL_Type__c';
        objCond.RTL_Referral_Field_Value_1__c = 'IS NOT NULL';
        objCond.RTL_Assigned_User__c = UserInfo.getUserId();
        objCond.RTL_Default_User__c = UserInfo.getUserId();
        insert objCond;        
        
        objCond = new RTL_Referral_Assignment__c();
        objCond.RTL_Active_Flag__c = true;
        objCond.RTL_Priority__c = 2;
        objCond.RTL_Referral_Type__c = 'Refer_to_Retail';
        objCond.RTL_Referral_Field_Criteria_1__c = 'RTL_Type__c';
        objCond.RTL_Referral_Field_Value_1__c = 'IS NULL';
        objCond.RTL_Assigned_User_field__c = 'RTL_RM_Owner_Id__c';
        objCond.RTL_Default_Queue_Name__c = branchQueue.DeveloperName;
        insert objCond;
        
        
    }
    
    public static  testmethod  void myUnitTest(){
        Id rtId = [ select Id from RecordType where DeveloperName = 'Refer_to_Retail' limit 1 ].Id;
        Branch_and_Zone__c baz = new Branch_and_Zone__c();
        baz.IsActive__c = true;
        insert baz;
        
        
        
        System.runAs( userList.get(0) ){      
            Test.startTest();
            RTL_Referral__c objRefer = new RTL_Referral__c();
            objRefer.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
            objRefer.RTL_Preferred_Branch__c = baz.Id;
            objRefer.RTL_Mobile1__c = '0911111111';
        	objRefer.RecordTypeId = rtId;
            objRefer.RTL_Stage__c = 'New';
            insert objRefer;        
            
            /*objRefer = new RTL_Referral__c();
            objRefer.RTL_Type__c = null;
            objRefer.RTL_Preferred_Branch__c = baz.Id;
        	objRefer.RecordTypeId = rtId;
            insert objRefer;*/
            /*List<RTL_Referral_Assignment__c> condList = [ select Id from RTL_Referral_Assignment__c ];
            RTL_ReferralAssignment objClass = new RTL_ReferralAssignment(new List<RTL_Referral__c>{objRefer});
            objClass.assignForBM(UserInfo.getUserId(),condList.get(0));
            objClass.assignDefault(objRefer,condList.get(0));*/
            Test.stopTest();
        }
        
    }

}