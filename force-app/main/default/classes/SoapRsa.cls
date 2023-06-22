/* create by ktc@ii.co.th */
public class SoapRsa{
	public static TMBServiceProxy.TMBServiceProxySoap setSecureHeader(TMBServiceProxy.TMBServiceProxySoap tmbService){
		AppConfig__c mc = AppConfig__c.getValues('CertName');
	    System.debug('SOAP RAS LOG >> Cername : '+ mc.Value__c);
	    string userName =  ii_UserInfoEx.EmployeeId;  
	    Map<String,String> keys = new  Map<String,String>();
	    string signed = ii_SecurityCryptoManager.SignWithCertificate(userName, mc.Value__c); 
	    keys.put('SFDC-SIGN', signed);
	    keys.put('SFDC-USR-ID', userName);
	    tmbService.inputHttpHeaders_x = keys; 
	    return tmbService;
	}
    public static TMBAccountPlanServiceProxy.AccountPlantProxySoap setSecureHeader(TMBAccountPlanServiceProxy.AccountPlantProxySoap tmbService){
		AppConfig__c mc = AppConfig__c.getValues('CertName');
	    System.debug('SOAP RAS LOG >> Cername : '+ mc.Value__c);
	    string userName =  ii_UserInfoEx.EmployeeId;  
	    Map<String,String> keys = new  Map<String,String>();
	    string signed = ii_SecurityCryptoManager.SignWithCertificate(userName, mc.Value__c); 
	    keys.put('SFDC-SIGN', signed);
	    keys.put('SFDC-USR-ID', userName);
	    tmbService.inputHttpHeaders_x = keys; 
	    return tmbService;
	}
}