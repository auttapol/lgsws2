@isTest
public class CampaignMemberLeadConversionCtrlTest {

    @testSetup static void setup() {
        // Implement test code
        
        TestUtils.createAppConfig();
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;              
    }
    
    
    @isTest static void checkDuplicate() 
    {
        Test.StartTest();
        // Implement test code  
        Account acc = [SELECT Id,Name,Mobile_Number_PE__c,ID_Type_PE__c,ID_Number_PE__c FROM Account LIMIT 1];
        
        CampaignMemberLeadConversionCtrl.checkDuplicate(acc.Mobile_Number_PE__c,acc.ID_Number_PE__c,acc.ID_Type_PE__c);
        Test.StopTest();
    }
    
    @isTest static void checkDuplicateOtherId() 
    {
        Test.StartTest();
        // Implement test code  
        Account acc = new Account(); 
        acc.Name = 'Test Account ';
        acc.Mobile_Number_PE__c  = '0801112233';
        acc.ID_Type_PE__c  = 'Other ID';
        acc.ID_Number_PE__c  = '1111111';
        insert acc;
        
        CampaignMemberLeadConversionCtrl.checkDuplicate(acc.Mobile_Number_PE__c,acc.ID_Number_PE__c,acc.ID_Type_PE__c);
        Test.StopTest();
    }

    @isTest static void getPickListValues() 
    {
        Test.StartTest();
        CampaignMemberLeadConversionCtrl.getPickListValues('CampaignMember','RTL_Contact_Status__c');
        Test.StopTest();
    }
}