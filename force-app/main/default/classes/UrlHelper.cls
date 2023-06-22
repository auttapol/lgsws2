public class UrlHelper {
	public static Blob bkey;
	static {
		AppConfig__c mc = AppConfig__c.getValues('UrlEncryptKey');
		string key = (mc == null ? '380db410e8b11fa9' : mc.Value__c);
		bkey = Blob.valueOf(key);
	}
	/*----------------------------------------------------------------------------------
	  Author:       Keattisak Chinburarat
	  Company:      I&I Consulting 
	  Description:   
	  Determines the true API hostname for a Salesforce org using the Identity API.
	  eg 'https://pod.salesforce.com' (most orgs)
	  eg 'https://custom.my.salesforce.com' (my domain)
	  eg 'https://custom--dev.pod.my.salesforce.com' (sandbox orgs)
	  Inputs:       None
	  Test Class:   TestUrlHelper.cls
	  History
	  <Date>       <Authors Name>     <Brief Description of Change>
	  2016-04-18   Keattisak.C        First init
	  ----------------------------------------------------------------------------------*/


	public static String protocolAndHost {
		get {
			if (protocolAndHost == null) {
				//memoize
				String orgId = UserInfo.getOrganizationId();
				String userId = UserInfo.getUserId();
				String sessionId = UserInfo.getSessionId();

				//use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
				if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');

				PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
				pr.getParameters().put('oauth_token', sessionId);
				pr.getParameters().put('format', 'json');

				//within test context use url class, else derive from identity api
				String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
				Map<String, Object> result = (Map<String, Object>) Json.deserializeUntyped(data);
				Map<String, Object> urls = (Map<String, Object>) result.get('urls');

				//compose pod from the REST endpoint
				Url rest = new Url((String) urls.get('rest'));
				protocolAndHost = rest.getProtocol() + '://' + rest.getHost();
			}

			return protocolAndHost;
		}
	}


	public static string encryptParams(string urlParams) {

		System.debug('TMB :-> urlParams is ' + urlParams);
		//encrypted blob
		Blob cipherText = Crypto.encryptWithManagedIV('AES128', bkey, Blob.valueOf(urlParams));
		//encrypted string
		String encodedCipherText = EncodingUtil.base64Encode(cipherText);
		System.debug('TMB :-> encryptParams is ' + encodedCipherText);


		return encodedCipherText;

	}

	public static string decryptParams(String encodedCipherText) {
		if (encodedCipherText == null) return null;
		//encrypted blob
		Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
		//decrypted blob
		Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', bkey, encodedEncryptedBlob);
		//decrypted string
		String decryptedClearText = decryptedBlob.toString();
		//System.debug(decryptedClearText);
		return decryptedClearText;
	}

}