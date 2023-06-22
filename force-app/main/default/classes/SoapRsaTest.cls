@isTest
private class SoapRsaTest {
	
    static{
        
        List<AppConfig__c> mc = new List<AppConfig__c>();
        mc.Add(new  AppConfig__c(Name ='CertName' , Value__c= 'TMB_RSA'));
        mc.Add(new  AppConfig__c(Name ='runtrigger' , Value__c= 'false'));
        insert mc;
    }
    
	@isTest 
	static void P_SuccessAddHeader() {
		// Prepair Data 
		
        Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User u = new User(FirstName='tmbfirstname-uat', LastName='tmbfirstname-uat', 
                                    UserName='1200t@tmb.com.uat', 
                                    Email='1200t@tmbbank.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='tmb-nickname',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='1200t');
        insert u;
        TMBServiceProxy.TMBServiceProxySoap tmbService = null;
        System.RunAs(u) {
			//   Create Soap Request
	        tmbService = new TMBServiceProxy.TMBServiceProxySoap();
	        tmbService.timeout_x = 120000 ;	        
	        tmbService = SoapRsa.setSecureHeader(tmbService);  
        }              

       
       String userId = tmbService.inputHttpHeaders_x.get('SFDC-USR-ID');
       System.assertEquals('1200t' ,userId, 'User must have ro code : 1200t');

	}	
    @isTest 
	static void P_SuccessAddHeader_AccountPlant() {
        
            // Prepair Data 
		AppConfig__c mc = new  AppConfig__c(Name ='CertName' , Value__c= 'TMB_RSA');
		insert mc;
        Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User u = new User(FirstName='tmbfirstname-uat', LastName='tmbfirstname-uat', 
                                    UserName='1200t@tmb.com.uat', 
                                    Email='1200t@tmbbank.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='tmb-nickname',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='1200t');
        TMBAccountPlanServiceProxy.AccountPlantProxySoap tmbService = null;
        insert u;
        System.RunAs(u) {
			//   Create Soap Request
	        tmbService = new TMBAccountPlanServiceProxy.AccountPlantProxySoap();
	        tmbService.timeout_x = 120000 ;	        
	        tmbService = SoapRsa.setSecureHeader(tmbService);  
        }              

       
       String userId = tmbService.inputHttpHeaders_x.get('SFDC-USR-ID');
       System.assertEquals('1200t' ,userId, 'User must have ro code : 1200t');
    }
}