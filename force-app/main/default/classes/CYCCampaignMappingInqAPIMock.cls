@isTest
Global class CYCCampaignMappingInqAPIMock implements HttpCalloutMock {
    
    private Integer statusCode;
    private String body;


    public CYCCampaignMappingInqAPIMock(Integer statusCode,String body) {
        this.statusCode = statusCode;
        this.body = body;
        //test
    }

    global HTTPResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.body);
        response.setStatusCode(this.statusCode);
        return response;
    }

}