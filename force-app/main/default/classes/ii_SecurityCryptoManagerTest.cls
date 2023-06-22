@isTest
public class ii_SecurityCryptoManagerTest {
    static{
       TestUtils.createAppConfig();
       TestUtils.createStatusCode();        
       TestUtils.createIdType();
        
    }
    public static  testmethod void P_CanSignRequest(){       
        TestUtils.createUsers(1,'MockUp2', 'AccountTest2','Account2Test@tmbbank.com', true);
        string signed ='';
        System.RunAs(TestUtils.userList[0])
        {         
            AppConfig__c conf = AppConfig__c.getValues('CertName');            
            system.debug('Cert Name : ' + conf.value__c);
            signed = ii_SecurityCryptoManager.SignWithCertificate(ii_UserInfoEx.EmployeeId,conf.value__c); 
        }
        system.assertNotEquals('', signed);
        
    }
}