@isTest
public class RTL_DataQualitySummaryExtensionTest {
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
            //Segment = 'Affluent' ,Last Update 1 year
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller);
            extController.updateAccount();
            System.assertEquals('Pass', extController.dataAgeStatus);
            System.assertEquals(false, extController.isSF1);
            
            //Segment = 'Mid' ,Last Update 2 year
            ApexPages.StandardController controller2 = new ApexPages.StandardController(accList.get(2));
    		RTL_DataQualitySummaryExtension extController2 = new RTL_DataQualitySummaryExtension(controller2);
            extController2.updateAccount();
            System.assertEquals('Pass', extController2.dataAgeStatus);
            
            //Segment = 'Mass' ,Last Update 4 year
            ApexPages.StandardController controller3 = new ApexPages.StandardController(accList.get(4));
    		RTL_DataQualitySummaryExtension extController3 = new RTL_DataQualitySummaryExtension(controller3);
            extController3.updateAccount();
            System.assertEquals('Pass', extController3.dataAgeStatus);
            
             
            
            
        }
        
       TEST.stopTest();
        
    }
    
    public static testMethod void RunDataAgeFailTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            //Create New Account
            List<Account> accList = new List<Account>();
			accList = RTL_TestUtility.createAccountDataAge(true);
            
            //Segment = 'Affluent' , Lastupdate > 1 year
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(1));
    		RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller);
            extController.updateAccount();
            System.assertEquals('Fail', extController.dataAgeStatus); 
            
            //Segment = 'Mid' , Lastupdate > 2 year
            ApexPages.StandardController controller2 = new ApexPages.StandardController(accList.get(3));
    		RTL_DataQualitySummaryExtension extController2 = new RTL_DataQualitySummaryExtension(controller2);
            extController2.updateAccount();
            System.assertEquals('Fail', extController2.dataAgeStatus);
            
            //Segment = 'Mass' , Lastupdate > 5 year
            ApexPages.StandardController controller3 = new ApexPages.StandardController(accList.get(5));
    		RTL_DataQualitySummaryExtension extController3 = new RTL_DataQualitySummaryExtension(controller3);
            extController3.updateAccount();
            System.assertEquals('Fail', extController3.dataAgeStatus);
            
            //Segment = null ,Last update null
            ApexPages.StandardController controller4 = new ApexPages.StandardController(accList.get(6));
    		RTL_DataQualitySummaryExtension extController4 = new RTL_DataQualitySummaryExtension(controller4);
            extController4.updateAccount();
            System.assertEquals('Fail', extController4.dataAgeStatus);
            
            //Segment = null ,Last Update Date not null
            ApexPages.StandardController controller5 = new ApexPages.StandardController(accList.get(7));
    		RTL_DataQualitySummaryExtension extController5 = new RTL_DataQualitySummaryExtension(controller5);
            extController5.updateAccount();
            System.assertEquals('Fail', extController5.dataAgeStatus);
            
            //Segment = 'Dummy' ,Last Update 1 year
            ApexPages.StandardController controller6 = new ApexPages.StandardController(accList.get(8));
    		RTL_DataQualitySummaryExtension extController6 = new RTL_DataQualitySummaryExtension(controller6);
            extController6.updateAccount();
            System.assertEquals('N.A.', extController6.dataAgeStatus);
        }
        
       TEST.stopTest();
        
    }
    
    public static testMethod void RunMktTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            //Create new Account
            List<Account> accList = new List<Account>();
			accList = RTL_TestUtility.createAccountMkt(true);
            
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller);
            extController.updateAccount();
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
    			RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller); 
            	extController.updateAccount();
            	system.assertEquals('Pass',extController.qualityStatus);
  
        }
        
       TEST.stopTest();
    }
    
    public static testMethod void RunQualityFailTest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            List<Account> accList = new List<Account>();
            
            //Account with null values
			accList = RTL_TestUtility.createAccountDataQualityFail(true);
            ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    		RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller); 
            extController.updateAccount();
            system.assertEquals('Fail',extController.qualityStatus);
            
            //Account with invalid data value
           	ApexPages.StandardController controller2 = new ApexPages.StandardController(accList.get(1));
    		RTL_DataQualitySummaryExtension extController2 = new RTL_DataQualitySummaryExtension(controller2); 
            extController2.updateAccount();
            system.assertEquals('Fail',extController2.qualityStatus);
  
        }
        
       TEST.stopTest();
    }
    
    public static testMethod void RunQualityNATest(){
        User us1 = RTL_TestUtility.createRetailTestUser(true);
        
        TEST.startTest();
        
        System.runAs(us1){
            List<Account> accList = new List<Account>();
            
				accList = RTL_TestUtility.createAccountDataQualityNA(true);
               	ApexPages.StandardController controller = new ApexPages.StandardController(accList.get(0));
    			RTL_DataQualitySummaryExtension extController = new RTL_DataQualitySummaryExtension(controller); 
            	extController.updateAccount();
            	system.assertEquals('N.A',extController.qualityStatus);
  
        }
        
       TEST.stopTest();
    }
    
    
    
    
}