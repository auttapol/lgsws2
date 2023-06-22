@isTest
global class MockupSMSResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) { 
        System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();

        String body = '{\"result\": {},\"success\": true,\"guid\": \"fc4b2bb2-0e66-4afd-b5a2-937d69c06215\",\"message\": \"Complete.\",\"status\": 200}';
        res.setBody(body);
        res.setStatusCode(200);
        return res;

    }
}