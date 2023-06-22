@isTest
public class RTL_DataQualityDetailsExtensionTest {
    static RTL_Customer_Data_Validation__c dataValidation;
    static RTL_Data_Summary__c dataSummary;
	static {
        TestUtils.createAppConfig();
        RTL_TestUtility.createAddrFieldLength();
    }
    public static testMethod void RunDataAgeTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            List<Account> accList = new List<Account>();
			accList = RTL_TestUtility.createAccountDataAge(true);
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualityDetailsExtension extController = new RTL_DataQualityDetailsExtension(controller);
            extController.updateAccountValidation();
            dataSummary = [SELECT ID,Name,RTL_Data_Age__c FROM RTL_Data_Summary__c WHERE RTL_Account__c =: accList.get(0).id];
            System.assertEquals('Pass', dataSummary.RTL_Data_Age__c);
        }
        
       TEST.stopTest();
        
    }
    
    public static testMethod void RunMktTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            List<Account> accList = new List<Account>();
			accList = RTL_TestUtility.createAccountMkt(true);
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualityDetailsExtension extController = new RTL_DataQualityDetailsExtension(controller);
            extController.updateAccountValidation();
            dataValidation = getDataValidation(accList.get(0).id);
            System.assertNotEquals(null, dataValidation);
            System.assertEquals(null, dataValidation.RTL_Citizen_ID_Mkt__c);
            System.assertEquals(null, dataValidation.RTL_Email_Mkt__c);
            System.assertEquals(null, dataValidation.RTL_Mobile_Mkt__c);
            System.assertEquals(null, dataValidation.RTL_Occupation_Mkt__c); 
            System.assertEquals('- / -', dataValidation.RTL_Office_Address_Marketing_Combined__c);
            System.assertEquals('- / -', dataValidation.RTL_Primary_Address_Marketing_Combined__c);
            System.assertEquals('- / -', dataValidation.RTL_Registered_Address_Marketing_Combine__c);
            
        }
        
       TEST.stopTest();
    }
    
    public static testMethod void RunQualityTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            List<Account> accList = new List<Account>();
			accList = RTL_TestUtility.createAccountDataQuality(true);
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualityDetailsExtension extController = new RTL_DataQualityDetailsExtension(controller);
            extController.updateAccountValidation();
            dataValidation = getDataValidation(accList.get(0).id);
            System.assertNotEquals(null, dataValidation);
            System.assertEquals(null, dataValidation.RTL_Citizen_ID_Quality__c);
            System.assertEquals(null, dataValidation.RTL_DOB_Quality__c);
            System.assertEquals(null, dataValidation.RTL_Email_Quality__c);
            System.assertEquals(null, dataValidation.RTL_Mobile_Quality__c);
            System.assertEquals(null, dataValidation.RTL_Occupation_Quality__c);
            System.assertEquals('- / -', dataValidation.RTL_Office_Address_Quality_Combined__c);
            System.assertEquals('- / -', dataValidation.RTL_Primary_Address_Quality_Combined__c);
            System.assertEquals('- / -', dataValidation.RTL_Registered_Address_Quality_Combined__c);
        }
        
       TEST.stopTest();
    }
    
    static RTL_Customer_Data_Validation__c getDataValidation(Id acctId){
        RTL_Customer_Data_Validation__c validation;
        validation = [SELECT ID,Name, RTL_Citizen_ID_Mkt__c ,RTL_Citizen_ID_Quality__c ,RTL_DOB_Mkt__c ,
                      RTL_DOB_Quality__c ,RTL_Email_Mkt__c ,RTL_Email_Quality__c,RTL_Mobile_Mkt__c , RTL_Mobile_Quality__c,
                      RTL_Occupation_Mkt__c ,RTL_Occupation_Quality__c  ,RTL_Office_Address_Marketing_Combined__c ,
                      RTL_Office_Address_Quality_Combined__c ,
                      RTL_Primary_Address_Marketing_Combined__c ,
                      RTL_Primary_Address_Quality_Combined__c  ,
                      RTL_Registered_Address_Marketing_Combine__c ,
                      RTL_Registered_Address_Quality_Combined__c  
                      FROM RTL_Customer_Data_Validation__c WHERE RTL_Account__c =:acctId];
        return validation;
    }
}