@RestResource(urlMapping='/fna/getHighLightProductByStation/*')
global class FnaHighlightProductService {
    global class Response {
        global List<Product> fna_products   {get;set;}
        global String        message        {get;set;}

    }

    global class Request {
        global String fnaActivityId         {get;set;}
        global String branch_code           {get;set;}
        global String station_no            {get;set;}
    }
    
    global class Product
    {
        global String product_code          {get;set;}
        global String product_name          {get;set;} 
        global String product_url           {get;set;} 
        global String product_type          {get;set;} 
        global Boolean is_highlight         {get;set;} 
    }
    
    @HttpPost
    global static Response getHighLightProductByStation (String fna_activity_id, String branch_code, String station_no)
    {
        /* Prepare Request File */
        Request req = new Request();
        req.fnaActivityId =  fna_activity_id;
        req.branch_code = branch_code;
        req.station_no = station_no;

        boolean isSuccess = false;
        Datetime startTime = DateTime.Now();

        Response res = new Response();
        if(fna_activity_id != '' && branch_code != '' && station_no != ''){
            try{
                List<Flagship_Station_Mapping__mdt> flagshipList = [SELECT Id, FNA_Product_Group__c, Branch_Code__c, Station_Number__c FROM Flagship_Station_Mapping__mdt WHERE Branch_Code__c =: branch_code AND Station_Number__c =: station_no];

                if(flagshipList.size() > 0){
                    //String productGroup = flagshipList[0].FNA_Product_Group__c;
                    List<String> productGroupList = new List<String>();
                    for(Flagship_Station_Mapping__mdt flagship : flagshipList){
                        productGroupList.add(flagship.FNA_Product_Group__c);
                    }
                    
                    List<FNA_Product_Offering__c> prodOfferList = [SELECT Id, FNA_Product_Name__c, product_type__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, 
                                                        FNA_Activity__c, FNA_Product_Name__r.Product__c, FNA_Product_Name__r.Product__r.FNA_Active__c, 
                                                        FNA_Product_Name__r.Product__r.FNA_Product_Name_TH__c , FNA_Product_Name__r.Product__r.Product_Code__c
                                                        FROM FNA_Product_Offering__c 
                                                        WHERE FNA_Activity__c =: fna_activity_id 
                                                        AND Flag_Offset_product_holding__c = false 
                                                        AND FNA_Product_Name__r.Product__r.FNA_Active__c = true 
                                                        AND FNA_Product_Name__r.Product__r.FNA_Product_Group__c in :productGroupList];
                    String FNA_COMMUNITY = 'FNA_Community_Url';
                    App_Config__mdt domainFNA = [SELECT Id, DeveloperName, Value__c FROM App_Config__mdt WHERE DeveloperName = :FNA_COMMUNITY limit 1];
                    List<Product> resProductList = new List<Product>();

                    for(FNA_Product_Offering__c product : prodOfferList){

                        //String encrypt_param = UrlHelper.encryptParams('Id=' + fnaActivityId + '&RTLId=' + product.FNA_Product_Name__r.Product__c);
                        String fnaId_Encrypt = UrlHelper.encryptParams(fna_activity_id);
                        String rtlId_Encrypt = UrlHelper.encryptParams(product.FNA_Product_Name__r.Product__c);

                        Product resProd = new Product();
                        resProd.product_code    = product.FNA_Product_Name__r.Product__r.Product_Code__c;
                        resProd.product_name    = product.FNA_Product_Name__r.Product__r.FNA_Product_Name_TH__c;
                        resProd.is_highlight    = product.Flag_Highlight__c;
                        
                        String urlEncrypte      = EncodingUtil.urlEncode('Id=' + fnaId_Encrypt + '&RTLId=' + rtlId_Encrypt, 'UTF-8');
                        resProd.product_url     = domainFNA.Value__c + '/fnaProductDetail?' + urlEncrypte;
                        resProd.product_type    = product.product_type__c;

                        resProductList.add(resProd);
                    }

                    res.fna_products = resProductList;
                    res.message = 'SUCCESS';
                    isSuccess = true;
                }else{
                    res.message = 'Not Found : Branch Code or Station No';
                }

            }catch(Exception ex){
                res.message = 'ERROR : Please contact salesforce administrator team';
            }
        }else{
            res.message = 'Error : Parameter can\'t be null';
        }

        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String requestBody = JSON.serialize(req);
        String responseBody = JSON.serialize(res);
        DateTime endTime = DateTime.Now();
        OnlineServiceLogUtils.saveToOnlineLog(isSuccess , '', res.message, '', userName, 
		fna_activity_id , 'GetHighlightProductByStation' , requestBody , responseBody , null , startTime , endTime, '');

        return res;
    }
}