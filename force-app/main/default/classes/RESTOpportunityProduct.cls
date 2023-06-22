@RestResource(urlMapping='/opportunity-product/*')
global class RESTOpportunityProduct {

    @HttpGet
    global static String getDateTime() {
        String result = RESTOpportunityUtil.getTHDatetimeNOW();
        return result;
    }

    @HttpPatch
    global static RESTOpportunityProductUtil.Response updateProductFromHost() {
        // PARAMS FOR OSLOG
        DateTime startTime, endTime;
        Boolean isSuccess = false;
        String userName = UserInfo.getName();
        String serviceName = '';

        startTime =  datetime.now();

        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();

        RESTOpportunityProductWrapperClass rw = RESTOpportunityProductWrapperClass.parse(requestString);

        RESTOpportunityProductUtil.Response res = new RESTOpportunityProductUtil.Response();

        // CHECK FAG FROM EACH SERVICE
        serviceName = rw.HostSystem;
        
        if (rw.HostSystem == 'F2F') {
            RESTOpportunityProductUtil.Response resp = RESTOpportunityProductUtil.updateNewOppLineItem(rw);
            res = resp;
        }

        endTime =  datetime.now();

        RTL_CampaignUtil.saveToOnlineLog(isSuccess, '', res.message, '', userName, '', serviceName, JSON.serialize(req), JSON.serialize(res), null, startTime, endTime);

        return res;
    }
}