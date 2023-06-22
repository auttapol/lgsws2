@isTest
public class SilverlakeService_Test {
	@isTest
    static void testHttpPostSuccess() {
        // prepare test-data
    	Uuid uuid = new Uuid();
		String uuidValue = uuid.getValue();
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/silverlake/'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('1234');
        req.addParameter('uuid', uuidValue);
        
        /* Debug */
        req.addHeader('Request-UID', uuidValue);
        SCSMessageAPIUtil.EncHeader encHeader = new SCSMessageAPIUtil.EncHeader(UserInfo.getName(), datetime.now().format('dd/MM/yyyy hh:mm:ss'), UserInfo.getUserName(), uuidValue);
        String header = JSON.serialize(encHeader);
        String result = EncodingUtil.Base64Encode( Blob.valueOf( header ) );
        req.addHeader('X-Salesforce-EHD', 'EHD ' + result);
    
        RestContext.request = req;
        RestContext.response= res;
    
        Test.startTest();
            String response = SilverlakeService.getKey();
        Test.stopTest(); 
    }
    
    @isTest
    static void testHttpPostFail() {
        // prepare test-data
    	Uuid uuid = new Uuid();
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/silverlake/?uuid=' + uuid; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('1234');
        
        /* Debug */
        
        String uuidValue = uuid.getValue();
        req.addHeader('Request-UID', uuidValue);
        SCSMessageAPIUtil.EncHeader encHeader = new SCSMessageAPIUtil.EncHeader(UserInfo.getName(), datetime.now().format('dd/MM/yyyy hh:mm:ss'), UserInfo.getUserName(), uuidValue);
        String header = JSON.serialize(encHeader);
        String result = EncodingUtil.Base64Encode( Blob.valueOf( header ) );
        req.addHeader('X-Salesforce-EHD', 'EHD ' + result);
    
        RestContext.request = req;
        RestContext.response= res;
    
        Test.startTest();
            String response = SilverlakeService.getKey();
        Test.stopTest(); 
    }
}