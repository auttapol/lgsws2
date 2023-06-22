@RestResource(urlMapping='/leads/getLeadswEligibleProducts/*')
global class LeadsWithProductsRetrievalService {
    global class leads
    {
        global String id {get;set;}
        global String status {get;set;}
        global String campaign_name {get;set;}
        global String campaign_id {get;set;}
        global String campaign_status {get;set;}
        global String channel {get;set;}
        global List<recommended_products > recommended_products  {get;set;}
        
    }
    global class recommended_products 
    {
        global String id {get;set;}
        global String project_code {get;set;}
        global String product_name {get;set;}
        global String product_code {get;set;}
        global String host_product_mapping_id {get;set;}
        global Decimal max_offer_amount  {get;set;}
        global Decimal max_tenor {get;set;}
        global String max_tenor_unit {get;set;}
        global Decimal max_installment {get;set;}
        global String rate {get;set;}
        global String fee {get;set;}
        global Date offer_start_date {get;set;}
        global Date offer_end_date {get;set;}
        global DateTime offer_last_update_date {get;set;}
        global String status {get;set;}
        global Decimal request_amount {get;set;}
        global Decimal request_fee_bath {get;set;}
        global Decimal request_tenor {get;set;}
        global String request_tenor_unit {get;set;}
        global Decimal request_installment {get;set;}
        global Date request_date {get;set;}
        global DateTime request_last_update_date {get;set;}
    }
    
    global class leadWrapper
    {
        global String status {get;set;}
        global String message {get;set;}
        global List<leads> leads {get;set;}   
    }
    
    @HttpPost
    global static leadWrapper getLeadswEligibleProducts(String id_number ,String channel ,String status)
    {
        leadWrapper leadWrapper = new leadWrapper();
        List<Lead> leadList = new List<Lead>();
        List<leads> leads_List = new List<leads>();
        List<String> leadsId_List = new List<String>();
        List<recommended_products> recomProductList = new List<recommended_products>();
        Map<String,List<recommended_products>> recomProductListMap = new Map<String,List<recommended_products>>();
        
        String message;
        
        Boolean isSuccess;
        String customerName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String msLogId = '-';
        String errorMessage;
        String userName;
        String rmId;
        String serviceName = 'getLeadswEligibleProducts';
        String requestBody;
        String responseBody;
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        Account accForLog = new Account();
        
        if(id_number != null)
        {
            requestBody = id_number;
            if(channel != null)
            {
                requestBody += ','+channel;
            }
            if(status != null)
            {
                requestBody += ','+status;
            }
        }
        
        try
        {
            if(id_number != null)
            {
                String id_regex = id_number.left(1)+ id_number.right(4);
                String recordtypeName = 'Digital Channel';
                String queryString = 'SELECT Id,status,LeadSource,ID_Number__c,ID_REGEX__c,Primary_Campaign__c,Primary_Campaign__r.Name,'
                    + 'Primary_Campaign__r.Status,RecordType.Name,Account__c '
                    + 'FROM Lead WHERE ID_REGEX__c =: id_regex AND RecordType.Name =: recordtypeName';
               
                if(channel != null)
                {
                    queryString += ' AND LeadSource =: channel';
                }
                if(status != null)
                {
                    queryString += ' AND Status =: status';
                }
                leadList = Database.query(queryString); 
            }
            
            if(leadList.size() > 0)
            {
                accForLog = [SELECT Id,Name,TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c FROM Account Where Id =: leadList[0].Account__c];
                for(Lead ld : leadList)
                {  
                    leadsId_List.add(ld.Id);
                }
                List<Product_Interest__c> productList = [SELECT Id, Name, Lead__c,Project_Code__c,Host_Product_Mapping__c,Max_Offer_Amount__c,
                                                         Max_Tenor__c,Max_Tenor_Unit__c,Max_Installment__c,Rate__c,Fee__c,Offer_start_date__c,Offer_end_date__c,
                                                         Offer_Last_update_date__c,Status__c,Request_Amount__c, Request_Fee_Baht__c, Request_Tenor__c, Request_Tenor_Unit__c, 
                                                         Request_Installment__c, Request_Date__c, Request_Last_update_date__c,Product__c,Product__r.Name,Product__r.ProductCode
                                                         FROM Product_Interest__c Where Lead__c in: leadsId_List ];                
                
                for(Product_Interest__c pd : productList)
                {  
                    recomProductListMap.put(pd.Lead__c,new List<recommended_products>());
                }
                              
                for(Product_Interest__c pd : productList)
                {        
                    if(recomProductListMap.containsKey(pd.Lead__c))
                    {
                        recommended_products recommended_products = new recommended_products();  
                        recommended_products.Id = pd.Id;
                        recommended_products.project_code = pd.Project_Code__c;
                        recommended_products.product_name = pd.Product__r.Name;
                        recommended_products.product_code = pd.Product__r.ProductCode;
                        recommended_products.host_product_mapping_id  = pd.Host_Product_Mapping__c;
                        recommended_products.max_offer_amount = pd.Max_Offer_Amount__c;
                        recommended_products.max_tenor = pd.Max_Tenor__c;
                        recommended_products.max_tenor_unit = pd.Max_Tenor_Unit__c;
                        recommended_products.max_installment = pd.Max_Installment__c;
                        recommended_products.rate = pd.Rate__c;
                        recommended_products.fee = pd.Fee__c;
                        recommended_products.offer_start_date = pd.Offer_start_date__c;
                        recommended_products.offer_end_date = pd.Offer_end_date__c;
                        recommended_products.offer_last_update_date = pd.Offer_Last_update_date__c;
                        recommended_products.status = pd.Status__c;
                        recommended_products.request_amount = pd.Request_Amount__c; 
                        recommended_products.request_fee_bath = pd.Request_Fee_Baht__c;
                        recommended_products.request_tenor = pd.Request_Tenor__c;
                        recommended_products.request_tenor_unit = pd.Request_Tenor_Unit__c;
                        recommended_products.request_installment = pd.Request_Installment__c;
                        recommended_products.request_date = pd.Request_Date__c;
                        recommended_products.request_last_update_date = pd.Request_Last_update_date__c;
                        
                        recomProductListMap.get(pd.Lead__c).add(recommended_products);

                    }
               
                }
                for(Lead ld : leadList)
                {                               
                    leads leads  = new leads();
                    leads.id  = ld.Id;
                    leads.status = ld.status;
                    leads.campaign_name = ld.Primary_Campaign__r.Name;
                    leads.campaign_id = ld.Primary_Campaign__c;
                    leads.campaign_status = ld.Primary_Campaign__r.Status;
                    leads.channel = ld.LeadSource; 

                    leads.recommended_products = recomProductListMap.get(ld.Id);
                    leads_List.add(leads);               
                }  
                
            }
            
            leadWrapper.status = 'SUCCESS';
            leadWrapper.message = '';
            leadWrapper.leads = leads_List;
            
            errorMessage = '';
            isSuccess = true;
            endTime = DateTime.Now();
            userName = accForLog.Name;
            rmId = accForLog.TMB_Customer_ID_PE__c;
            requestBody = JSON.serialize(requestBody);
            responseBody = JSON.serialize(leadWrapper);    
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog, 
                                                  startTime ,  endTime,  null );
            
            return leadWrapper;           
        }
        catch(System.DmlException e)
        {
            leadWrapper.status = 'ERROR';
            leadWrapper.message = 'Message: ' + e.getDmlMessage(0);
            
            errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
            isSuccess = false;
            endTime = DateTime.Now();
            userName = accForLog.Name;
            rmId = accForLog.TMB_Customer_ID_PE__c;
            requestBody = JSON.serialize(requestBody);
            responseBody = JSON.serialize(leadWrapper);
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog, 
                                                  startTime ,  endTime,  null );
            return leadWrapper;
        }                
    }       
}