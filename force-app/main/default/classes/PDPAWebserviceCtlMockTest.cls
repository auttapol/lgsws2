@isTest
global class PDPAWebserviceCtlMockTest implements HttpCalloutMock{
    // Implement this interface method
    protected Integer code;
    protected String body;
    

    public PDPAWebserviceCtlMockTest(Integer code, String body) {
        this.code = code;
        this.body = body;

    }

    global HTTPResponse respond(HTTPRequest req) { 
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(this.code);
        return res;

    }   
    
}