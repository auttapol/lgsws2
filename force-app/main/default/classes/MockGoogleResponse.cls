@isTest
global class MockGoogleResponse implements HttpCalloutMock {
    private String status = '';

    global MockGoogleResponse (String sts) {
        this.status = sts;
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (this.status == 'RETURN_NULL') return res;

        
        String body = '{ "results": [{"address_components" : [{'+
                                     '"long_name" : "9/14",'+
                                     '"short_name" : "9/14",'+
                                     '"types" : [ "street_number" ]'+
                                      '}, {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxxx",'+
                                     '"types" : [ "route" ]'+
                                     '} , {';

        if (this.status == 'ZERO_RESULTS') {
          body = body+'"long_name" : "xxx",'+
                      '"short_name" : "xxx",'+
                      '"types" : [ "political" ]';
        }else {
          body = body+'"long_name" : "xxx",'+
                      '"short_name" : "xxx",'+
                      '"types" : [ "locality" ]';
        }
                                     
                                     
              body = body+'} , {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxx",'+
                                     '"types" : [ "sublocality" ]'+
                                     '} , {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxx",'+
                                     '"types" : [ "premise" ]'+
                                     '} , {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxx",'+
                                     '"types" : [ "administrative_area_level_1" ]'+
                                     '} , {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxx",'+
                                     '"types" : [ "postal_code" ]'+
                                     '} , {'+
                                     '"long_name" : "xxx",'+
                                     '"short_name" : "xxx",'+
                                     '"types" : [ "country" ]'+
                                     '} '+
                                     ']}],'+
                        '"status" : "'+this.status+'"'+
                        '}';
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}