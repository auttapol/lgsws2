@isTest
public class RTL_DataQualityCheckTest {
    static {
        TestUtils.createAppConfig();
        RTL_TestUtility.createAddrFieldLength();
    }
    
    public static testMethod void positiveTest(){
        system.debug(':::: Data Quality Check Test Start ::::');
        
        TEST.startTest();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig; 
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        RTL_ValidateData validate;
        RTL_DataSummary dataSummary;
        RTL_Customer_Data_Validation__c dataValidation;
        System.runAs(retailUser){
            
            //data age
            List<Account> accList = new List<Account>();
           
        	accList =  RTL_TestUtility.createAccountDataAge(true);
            for(Integer i =0 ; i < accList.size() ; i++){
                validate = new RTL_ValidateData(accList[i],new RTL_Customer_Data_Validation__c(),new RTL_Data_Summary__c()); 
                dataSummary = validate.execute();
                if(i == 0 || i==2 || i ==4){
                    System.assertEquals('Pass', dataSummary.getDataAgeStatus());
                }else if (i==1 || i==3 || i==5){
                    //System.assertEquals('Fail', accList[i].RTL_Age_Result_Formula__c);
                	System.assertEquals('Fail', dataSummary.getDataAgeStatus());
                }else System.assertEquals('Fail', dataSummary.getDataAgeStatus());
            }
            
            //marketing
           List<Account> accList2 = new List<Account>();
        	accList2 =  RTL_TestUtility.createAccountMkt(true);
            
            for(Integer i = 0 ; i < accList2.size(); i++){
                
                
                if(i == 0){
                    dataValidation = getDataValidation(accList2[i].id);
            		
                    validate = new RTL_ValidateData(accList2[i],dataValidation,new RTL_Data_Summary__c()); 
                	dataSummary = validate.execute();
                    //system.assertEquals(null, accList2[i].RTL_DOB_Mkt__c);
            		system.assertEquals('Pass', dataSummary.getMarketingStatus());
                }
                else if(i == 1){
                    dataValidation = getDataValidation(accList2[i].id);
                    dataValidation.RTL_DOB_Mkt__c = 'Plase Check Year of Birth';
            		update dataValidation;
                    validate = new RTL_ValidateData(accList2[i],dataValidation,new RTL_Data_Summary__c()); 
                	dataSummary = validate.execute();
                    //system.assertEquals('DOB Mkt', accList2[i].RTL_DOB_Mkt__c);
            		system.assertEquals('Fail', dataSummary.getMarketingStatus());
                }
            }
            
            //validation
            List<Account> accList3 = new List<Account>();
            accList3 =  RTL_TestUtility.createAccountDataQualityFail(true);
            for(Integer i = 0 ; i < accList3.size() ; i++){
                accList3[i].Account_Type__c = 'Retail Customer';
                validate = new RTL_ValidateData(accList3[i],new RTL_Customer_Data_Validation__c(),new RTL_Data_Summary__c()); 
                dataSummary = validate.execute();
                if(i == 0){
                    system.assertEquals('Fail', dataSummary.getQualityStatus());
                }
            }
        }
        
        TEST.stopTest();
        
    }
    
    public static RTL_Customer_Data_Validation__c getDataValidation(Id acctId){
        RTL_Customer_Data_Validation__c validation;
        validation = [SELECT ID,Name, RTL_Citizen_ID_Mkt__c ,RTL_Citizen_ID_Quality__c ,RTL_DOB_Mkt__c ,
                      RTL_DOB_Quality__c ,RTL_Email_Mkt__c ,RTL_Email_Quality__c,RTL_Mobile_Mkt__c , RTL_Mobile_Quality__c,
                      RTL_Occupation_Mkt__c ,RTL_Occupation_Quality__c  ,RTL_Office_Address_Marketing_Combined__c ,
                      RTL_Office_Address_Quality_Combined__c ,RTL_Office_Address_Mkt__c,RTL_Office_Address_Zip_Mkt__c,
                      RTL_Primary_Address_Marketing_Combined__c ,RTL_Primary_Address_Mkt__c,RTL_Primary_Address_Zip_Mkt__c,
                      RTL_Primary_Address_Quality_Combined__c  ,RTL_Registered_Address_Mkt__c,RTL_Registered_Address_Zip_Mkt__c,
                      RTL_Registered_Address_Marketing_Combine__c ,
                      RTL_Registered_Address_Quality_Combined__c  
                      FROM RTL_Customer_Data_Validation__c WHERE RTL_Account__c =:acctId];
        return validation;
    }

}