@isTest
global class pdpaCalloutUtilHttpF2FServiceTokenMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        System.debug('MockHttpCallout\n\n');
        System.debug('Request:'+request);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=utf-8');
        response.setHeader('request-uid', '1563286287422');
        response.setHeader('request-datetime', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        
        String responseBody = '{\n' + '"status": {\n"code": "0000",\n"description": "Success"\n},\n' +
            '"data": {\n' +
            '"consentUrl": "https://kycreview-dev.tau2904.com:8444",' +
			'"formUrl": "https://kycreview-dev.tau2904.com:8444",' +
			'"isCorrect": true,' +
			'"token": "fsdfsd4234234cwdg13t4fg"' +            
            '\n}\n}';
        
        System.debug('MockresponseBody: \n***********\n'+ responseBody);
        response.setBody(responseBody);
        response.setStatusCode(200);
        response.setStatus('success');
        response.setHeader('response-datetime', DateTime.now().AddSeconds(5).format('yyyy-MM-dd\'T\'HH:mm:ss'));
                
        return response;
    }
}