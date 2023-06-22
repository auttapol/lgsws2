@isTest
global class MockupEWMServiceResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) { 
    	System.assertEquals('POST', req.getMethod());

    	// Create a fake response
        HttpResponse res = new HttpResponse();

        String body = '<CRMIntegrationOuput xmlns="http://schemas.datacontract.org/2004/07/Kofax.TMB.S2O.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><ErrorCode i:nil="true"/><ErrorDescription i:nil="true"/><IsSuccess>True</IsSuccess><JobId>645EF55D380C4442BA2D1F998E38C764</JobId><ServiceRefID>00T0l000007WGCUEA4</ServiceRefID></CRMIntegrationOuput>';

        res.setBody(body);
        res.setStatusCode(200);
        return res;

    }
}