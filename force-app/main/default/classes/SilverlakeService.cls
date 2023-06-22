@RestResource(urlMapping='/silverlake/*')
global with sharing class SilverlakeService {
    
    @HttpPost
    global static String getKey() {
        RestRequest restReq = RestContext.request;
        String body = restReq.requestBody.toString();
        String uuid = restReq.params.get('uuid');
        Map<String, String> headers = RestContext.request.headers;
        System.debug('body-->'+body);
        
        /* Validate header */
        String validToken = headers.get('X-Salesforce-EHD');
        System.debug('validToken :: ' + validToken);
        
        try {
            List<String> validTokenParam = validToken.split(' ');
            System.debug('header ' + validTokenParam[1]);
            String result = EncodingUtil.base64Decode(validTokenParam[1]).toString();
            
            System.debug('header :' + result + ' uuid :' + uuid);
            SCSMessageAPIUtil.EncHeader encHeader = SCSMessageAPIUtil.deserializeEncHeader(result);
            
            if (!uuid.equals(encHeader.uuid)) {
                System.debug('Header not valid');
                RestContext.response.statusCode = 401;     
            	return null; 
            } else {
                System.debug('OK');
                Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(body);
                RestContext.response.statusCode = 200; 
                String apiKey = (String)params.get('api_key');
                return apiKey;
            }
			
            
        } catch (Exception e) {
            System.debug('Error::' + e.getMessage());
            RestContext.response.statusCode = 401;     
            return null;   
        }
    }
}