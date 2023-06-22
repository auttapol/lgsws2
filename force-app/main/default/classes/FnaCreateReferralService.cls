@RestResource(urlMapping='/fna/createReferral/*')
global class FnaCreateReferralService {
    global class Response {
        global String status	{get;set;}
        global String message 	{get;set;}
    }

    global class Request {
        global String fnaActivityId         {get;set;}
        global String branch_code           {get;set;}
        global String product_code            {get;set;}
    }
    
    @HttpPost
    global static Response createReferral (String fna_activity_id, String branch_code, String product_code)
    {
       	/* Prepare Request File */
        Request req = new Request();
        req.fnaActivityId =  fna_activity_id;
        req.branch_code = branch_code;
        req.product_code = product_code;

        boolean isSuccess = false;
        Datetime startTime = DateTime.Now();


        Response res = new Response();
        if(fna_activity_id != '' && branch_code != '' && product_code != ''){
            try{
                FNA_Activity__c fnaObj = new FNA_Activity__c();
                fnaObj.id           = fna_activity_id;
                fnaObj.Branch__c    = branch_code;
                update fnaObj;

                List<RTL_product_master__c> productList = [SELECT Id, Name, Product_Code__c, FNA_Product_Code__c FROM RTL_product_master__c WHERE Product_Code__c = :product_code];
                if(productList.size() > 0){
                    String productId = productList[0].Id;
                    try{
                        ReferralUtility.createReferral(fna_activity_id, productId);
                        res.status = 'SUCCESS';
                        res.message = 'Successful';
                        isSuccess = true;

                    }catch(Exception ex){
                        res.status = 'ERROR';
                        res.message = 'Please contact salesforce administrator team' + ex.getMessage();
                        system.debug('ex : ' + ex);
                        system.debug('ex : ' + ex.getLineNumber());
                        system.debug('ex : ' + ex.getCause());
                        system.debug('ex : ' + ex.getTypeName());
                        system.debug('ex : ' + ex.getStackTraceString());   
                        system.debug('ex : ' + ex.getStackTraceString().substringAfter('\n'));                        

                    }
                }else{
                    res.status = 'ERROR';
                    res.message = 'PRODUCT NOT FOUND';
                }
            }catch(Exception ex){
                res.status = 'ERROR';
                res.message = 'Please contact salesforce administrator team';
            }
            
  
        }else{
            res.status = 'ERROR';
            res.message = 'INVALID PARAMETER';
        }

        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String requestBody = JSON.serialize(req);
        String responseBody = JSON.serialize(res);
        DateTime endTime = DateTime.Now();
        OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '', res.message, '', userName, 
		fna_activity_id , 'CreateReferral' , requestBody , responseBody , null , startTime , endTime, '');

        return res;
    }
}