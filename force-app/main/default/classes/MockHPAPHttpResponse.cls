@isTest
public class MockHPAPHttpResponse implements HttpCalloutMock {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    public Boolean isFailed = false;
    public MockHPAPHttpResponse(){

    }
    public MockHPAPHttpResponse(Boolean isFailed){
        this.isFailed = isFailed;
    }
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }
    public HttpResponse respond( HttpRequest req ) {
        System.debug('Request : ' + req);
        System.debug('GetEndpoint : ' + req.getEndpoint());

        String endpoint = req.getEndpoint();
        
        if (endpoint.contains('callout:RTL_AL_SubmitApp_HPAP')) {
            if(isFailed){
                buildCreateReferResponseFail(req);
                return null;
            }else{
                return buildCreateReferResponse(req);
            }
        }else if (endpoint.contains('callout:get_hpap_key')){
            return build_HPAP_API_KEY_Response(req);
        }else if (endpoint.contains('callout:Smart_BDM_Cal_Tools_Create_Token')){
            return build_Get_Token_Response(req);
        }
        return null;
    }
    private HttpResponse build_HPAP_API_KEY_Response( HttpRequest req ) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(encryptKey);

        return res;
    }
    private HttpResponse build_Get_Token_Response( HttpRequest req ) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(encryptKey);
        res.setStatusCode(200);
        return res;

    }
    private HttpResponse buildCreateReferResponse( HttpRequest req ) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        String body = '{ "RefCode3" : "20220228141195350", "RefCode2" : "a2S0l000000DdujEAC", "RefCode" : "", "ResponseDetail" : "OK", "ResponseCode" : "000" }';
        res.setBody(SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));

        return res;
    }
    private void buildCreateReferResponseFail( HttpRequest req ) {
        HttpResponse res = new HttpResponse();
        // res.setStatusCode(200);
        // String body = '{ "Status": { "StatusCode": "401", "StatusDesc": "Unauthorized" } }';
        // res.setBody(SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
        String errMsg = 'Read timed out';
        throw new OtherException(errMsg);
        //return res;

    }
}