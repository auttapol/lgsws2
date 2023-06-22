@RestResource(urlMapping='/leads/insertLeadswEligibleProducts/*')
global class LeadsWithProductsCreationService {
    global class leads
    {
        global String id {get;set;}
        global String campaign_id {get;set;}   
        global String channel {get;set;}
        global String tmb_customer_id {get;set;}
        global String id_number {get;set;}
        global String id_type {get;set;}
        global String customer_type {get;set;}
        global String first_name {get;set;}
        global String last_name {get;set;}
        global String mobile_number {get;set;}
        global String company_name {get;set;}
        global String email {get;set;}
        global List<recommended_products > recommended_products  {get;set;}
    }
    global class recommended_products 
    {
        global String id {get;set;}
        global String project_code {get;set;}
        global String product_name {get;set;}
        global String product_code {get;set;}
        global String host_product_mapping_id {get;set;}
        global Integer max_offer_amount  {get;set;}
        global Integer max_tenor {get;set;}
        global String max_tenor_unit {get;set;}
        global Integer max_installment {get;set;}
        global String rate {get;set;}
        global String fee {get;set;}
        global Date offer_start_date {get;set;}
        global Date offer_end_date {get;set;}
        global DateTime offer_last_update_date {get;set;}
        global String status {get;set;}
        global String merchant_unique_id {get;set;}
        global String remark {get;set;}
    }
    
    global class leadWrapper
    {
        global String status {get;set;}
        global String message {get;set;} 
    }
    
    @HttpPost
    global static leadWrapper insertLeadswEligibleProducts (List<leads> leads)
    {
        leadWrapper leadWrapper = new leadWrapper();
        Id accRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id leadRecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Digital Channel').getRecordTypeId();
        List<String> tmbCustIdList = new List<String>();     
        List<Account> insertAccList = new List<Account>();
        List<Lead> insertLeadList = new List<Lead>();       
        List<Product_Interest__c> insertRecProductList = new List<Product_Interest__c>();
        Map<String,Account> insertAccMap = new Map<String,Account>();
        Map<String,Account> insertAccMap2 = new Map<String,Account>();
        Map<String,Lead> insertLeadMap = new Map<String,Lead>();
        Map<String,Product2> insertProductMap = new Map<String,Product2>();
        Map<String,leads> checkLeadsMap = new Map<String,leads>();
        Map<String,Account> checkAccMap = new Map<String,Account>();
        
        String message = '';
        String status = 'SUCCESS';
        
        Boolean isSuccess;
        String customerName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String msLogId = '-';
        String errorMessage;
        String userName;
        String rmId;
        String serviceName = 'insertLeadswEligibleProducts';
        String requestBody;
        String responseBody;
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        Account accForLog = new Account();
        
        String TrackMsgQuery = '';
        String TrackMsgCheckStart = '';
        String TrackMsgCheckEnd = '';
        String TrackMsgInsertProspect = '';
        String TrackMsgInsertLead = '';
        String TrackMsgInsertProduct = '';
        
        
        try
        {           
            
            //--------------TrackMsg--------------------
            TrackMsgQuery += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAccount, message=';
            //--------------TrackMsg--------------------
            for(leads ld : leads)
            {
                if(!String.isBlank(ld.tmb_customer_id))
                {
                    tmbCustIdList.add(ld.tmb_customer_id);
                    
                    //--------------TrackMsg--------------------
                    TrackMsgQuery += '\n tmbcustid:' + ld.tmb_customer_id;
                    //--------------TrackMsg--------------------
                }               
            }          
            List<Account> accList = [SELECT Id,Name,TMB_Customer_ID_PE__c,ID_Type_PE__c,ID_Number_PE__c,Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c in : tmbCustIdList];        
            
            List<leads> tmbCusIdList_isNotFound = new List<leads>(); 
            
            //--------------TrackMsg--------------------
            TrackMsgQuery += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message=';
            
            TrackMsgCheckStart += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start CheckAccountDuplicate, message=';
            
            TrackMsgCheckEnd += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CheckAccountDuplicate, message=';
            
            TrackMsgInsertProspect += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start InsertProspect, message=';
            
            //--------------TrackMsg--------------------
            
            //Query Account is found
            if(accList.size() > 0)
            {
                for(leads ld : leads)
                {
                    for(Account acc : accList)
                    {
                        //--------------TrackMsg--------------------
                        TrackMsgQuery += '\n accountid:' + acc.Id;
                        //--------------TrackMsg--------------------
                        if(ld.tmb_customer_id != acc.TMB_Customer_ID_PE__c)
                        {
                            if(!String.isBlank(ld.tmb_customer_id))
                        	{
                            	tmbCusIdList_isNotFound.add(ld);
                            }
                        }
                    }
                } 
                
                // Find TMB CUST ID is not found
                if(tmbCusIdList_isNotFound.size() > 0)
                {         
                    List<String> nidList = new List<String>();
                    for(leads ld : leads)
                    {
                        //--------------TrackMsg--------------------
                        TrackMsgCheckStart += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                        //--------------TrackMsg--------------------
                        String nid = ld.id_number.left(1)+ ld.id_number.right(4);
                        nidList.add(nid);
                    }
                    List<Account> accList1 = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account Where RTL_NID__c in : nidList];                                       
                    
                    // Check duplicate account from ID Type and ID Number
                    if(accList1.size() > 0 )
                    {
                        for(Account acc : accList1)
                        {
                            //--------------TrackMsg--------------------
                            TrackMsgCheckEnd += '\n Account found id:' + acc.Id;
                            //--------------TrackMsg--------------------
                            if(!checkAccMap.containsKey (acc.ID_Type_PE__c+acc.ID_Number_PE__c))
                            {
                                checkAccMap.put(acc.ID_Type_PE__c+acc.ID_Number_PE__c,acc);                               
                            }
                            insertAccMap.put(acc.ID_Type_PE__c+acc.ID_Number_PE__c,acc);
                            insertAccMap2.put(acc.TMB_Customer_ID_PE__c,acc);
                        }          		                     
                        for(leads ld : tmbCusIdList_isNotFound)
                        {
                            if(!checkAccMap.containsKey (ld.id_type+ld.id_number))
                            {
                                //--------------TrackMsg--------------------
                                TrackMsgInsertProspect += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                                //--------------TrackMsg--------------------
                                Account new_account = new Account();
                                new_account.name = ld.first_name + ' ' + ld.last_name;
                                new_account.RecordTypeId = accRecordTypeId;
                                new_account.Account_Type__c = 'Qualified Prospect';
                                new_account.Customer_Type__c = ld.customer_type;
                                new_account.First_name_PE__c = ld.first_name;
                                new_account.Last_name_PE__c = ld.last_name;
                                new_account.ID_Type_PE__c = ld.id_type;
                                new_account.ID_Number_PE__c = ld.id_number;
                                new_account.phone = ld.mobile_number;
                                insertAccList.add(new_account);
                                insertAccMap.put(new_account.ID_Type_PE__c+new_account.ID_Number_PE__c,new_account);
                            }                           
                        }
                    }
                    else
                    {
                        //--------------TrackMsg--------------------
                        TrackMsgCheckEnd += '\n Account found id:';
                        //--------------TrackMsg--------------------
                        
                        for(leads ld : leads)
                        {
                            if(!checkLeadsMap.containsKey(ld.id_type+ld.id_number))
                            {
                                checkLeadsMap.put(ld.id_type+ld.id_number,ld);
                            }
                        }
                        for(leads ld : checkLeadsMap.values())
                        {    
                            //--------------TrackMsg--------------------
                            TrackMsgInsertProspect += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                            //--------------TrackMsg--------------------
                            Account new_account = new Account();
                            new_account.name = ld.first_name + ' ' + ld.last_name;
                            new_account.RecordTypeId = accRecordTypeId;
                            new_account.Account_Type__c = 'Qualified Prospect';
                            new_account.Customer_Type__c = ld.customer_type;
                            new_account.First_name_PE__c = ld.first_name;
                            new_account.Last_name_PE__c = ld.last_name;
                            new_account.ID_Type_PE__c = ld.id_type;
                            new_account.ID_Number_PE__c = ld.id_number;
                            new_account.phone = ld.mobile_number;
                            insertAccList.add(new_account);
                            insertAccMap.put(new_account.ID_Type_PE__c+new_account.ID_Number_PE__c,new_account); 
                        }        
                    }
                }
                else
                {       
                    TrackMsgCheckStart = '';
                    
                    TrackMsgCheckEnd = '';
                    for(Account acc : accList)
                    {
                        insertAccMap.put(acc.ID_Type_PE__c+acc.ID_Number_PE__c,acc);    
                        insertAccMap2.put(acc.TMB_Customer_ID_PE__c,acc);
                    }
                    accForLog = accList[0];
                }   
                
            }
            else
            {
                // Query Account is not found
                
                TrackMsgQuery += '';
                List<String> nidList = new List<String>();
                for(leads ld : leads)
                {
                    String nid = ld.id_number.left(1)+ ld.id_number.right(4);
                    nidList.add(nid);
                    //--------------TrackMsg--------------------
                    TrackMsgCheckStart += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                    //--------------TrackMsg--------------------
                }
                List<Account> accList2 = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c FROM Account Where RTL_NID__c in : nidList];                
                
                if(accList2.size() > 0 )
                {         
                    for(Account acc : accList2)
                    {
                        //--------------TrackMsg--------------------
                        TrackMsgCheckEnd += '\n Account found id:' + acc.Id;
                        //--------------TrackMsg--------------------
                        
                        if(!checkAccMap.containsKey (acc.ID_Type_PE__c+acc.ID_Number_PE__c))
                        {
                            checkAccMap.put(acc.ID_Type_PE__c+acc.ID_Number_PE__c,acc);
                        }
                        insertAccMap.put(acc.ID_Type_PE__c+acc.ID_Number_PE__c,acc);
                    }
                    for(leads ld : leads)
                    {                   
                        if(!checkAccMap.containsKey (ld.id_type+ld.id_number))
                        {
                            //--------------TrackMsg--------------------
                            TrackMsgInsertProspect += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                            //--------------TrackMsg--------------------
                            Account new_account = new Account();
                            new_account.name = ld.first_name + ' ' + ld.last_name;
                            new_account.RecordTypeId = accRecordTypeId;
                            new_account.Account_Type__c = 'Qualified Prospect';
                            new_account.Customer_Type__c = ld.customer_type;
                            new_account.First_name_PE__c = ld.first_name;
                            new_account.Last_name_PE__c = ld.last_name;
                            new_account.ID_Type_PE__c = ld.id_type;
                            new_account.ID_Number_PE__c = ld.id_number;
                            new_account.phone = ld.mobile_number;
                            insertAccList.add(new_account);
                            insertAccMap.put(new_account.ID_Type_PE__c+new_account.ID_Number_PE__c,new_account);
                        }
                    }               
                }
                else
                {        
                    //--------------TrackMsg--------------------
                    TrackMsgCheckEnd += '\n Account found id:';
                    //--------------TrackMsg--------------------
                    
                    for(leads ld : leads)
                    {
                        if(!checkLeadsMap.containsKey(ld.id_type+ld.id_number))
                        {
                            checkLeadsMap.put(ld.id_type+ld.id_number,ld);
                        }
                    }
                    for(leads ld : checkLeadsMap.values())
                    {             
                        //--------------TrackMsg--------------------
                        TrackMsgInsertProspect += '\n Idtype:' + ld.id_type + ',Idnumber:'+ ld.id_number;
                        //--------------TrackMsg--------------------
                        Account new_account = new Account();
                        new_account.name = ld.first_name + ' ' + ld.last_name;
                        new_account.RecordTypeId = accRecordTypeId;
                        new_account.Account_Type__c = 'Qualified Prospect';
                        new_account.Customer_Type__c = ld.customer_type;
                        new_account.First_name_PE__c = ld.first_name;
                        new_account.Last_name_PE__c = ld.last_name;
                        new_account.ID_Type_PE__c = ld.id_type;
                        new_account.ID_Number_PE__c = ld.id_number;
                        new_account.phone = ld.mobile_number;
                        insertAccList.add(new_account);
                        insertAccMap.put(new_account.ID_Type_PE__c+new_account.ID_Number_PE__c,new_account);                    
                    }                
                }            
                
            }
            
            if(insertAccList.size() > 0)
            {
                insert insertAccList;
                //--------------TrackMsg--------------------
                TrackMsgInsertProspect += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertProspect, message=';
                //--------------TrackMsg--------------------
                for(Account acc : insertAccList)
                {
                    //--------------TrackMsg--------------------
                    TrackMsgInsertProspect += '\n Id:' + acc.Id;
                    //--------------TrackMsg--------------------
                }
                accForLog = insertAccList[0];
            }
            else
            {
                TrackMsgInsertProspect = '';
            }           
            //--------------TrackMsg--------------------
            TrackMsgInsertLead += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start InsertLead, message=';
            //--------------TrackMsg--------------------         
            for(leads ld : leads)
            {
                if(insertAccMap2.containsKey(ld.tmb_customer_id))
                {
                    //--------------TrackMsg--------------------
                    TrackMsgInsertLead += '\n accountid:' + insertAccMap2.get(ld.tmb_customer_id).Id;
                    //--------------TrackMsg--------------------
                    Lead new_lead = new Lead();
                    new_lead.RecordTypeId = leadRecordTypeId;
                    new_lead.FirstName = ld.first_name;
                    new_lead.LastName = ld.last_name;
                    if(!String.isBlank(ld.company_name))
                    {
                    	new_lead.Company = ld.company_name;
                    }
                    else
                    {
                        new_lead.Company = ld.first_name + ' ' +ld.last_name;
                    }
                    new_lead.ID_Type__c = ld.id_type;
                    new_lead.ID_Number__c = ld.id_number;
                    new_lead.Customer_Type__c = ld.customer_type;
                    new_lead.Account__c = insertAccMap2.get(ld.tmb_customer_id).Id;
                    new_lead.Mobile_No__c = ld.mobile_number;
                    new_lead.Primary_Campaign__c = ld.campaign_id;
                    new_lead.LeadSource = ld.channel;
                    insertLeadList.add(new_lead);   
                    insertLeadMap.put(new_lead.ID_Type__c+new_lead.ID_Number__c,new_lead);
                }
                else if(insertAccMap.containsKey(ld.id_type+ld.id_number))
                {                    
                    //--------------TrackMsg--------------------
                    TrackMsgInsertLead += '\n accountid:' + insertAccMap.get(ld.id_type+ld.id_number).Id;
                    //--------------TrackMsg--------------------
                    Lead new_lead = new Lead();
                    new_lead.RecordTypeId = leadRecordTypeId;
                    new_lead.FirstName = ld.first_name;
                    new_lead.LastName = ld.last_name;
                    if(!String.isBlank(ld.company_name))
                    {
                        new_lead.Company = ld.company_name;
                    }
                    else
                    {
                        new_lead.Company = ld.first_name + ' ' +ld.last_name;
                    }
                    new_lead.ID_Type__c = ld.id_type;
                    new_lead.ID_Number__c = ld.id_number;
                    new_lead.Customer_Type__c = ld.customer_type;
                    new_lead.Account__c = insertAccMap.get(ld.id_type+ld.id_number).Id;
                    new_lead.Mobile_No__c = ld.mobile_number;
                    new_lead.Primary_Campaign__c = ld.campaign_id;
                    new_lead.LeadSource = ld.channel;
                    new_lead.Email__c = ld.email;
                    insertLeadList.add(new_lead);   
                    insertLeadMap.put(new_lead.ID_Type__c+new_lead.ID_Number__c,new_lead);
                }         
            }  
            
            if(insertLeadList.size() > 0)
            {
                insert insertLeadList; 
                //--------------TrackMsg--------------------
                TrackMsgInsertLead += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertLead, message=';
                //--------------TrackMsg--------------------
                for(Lead lead : insertLeadList)
                {
                    //--------------TrackMsg--------------------
                    TrackMsgInsertLead += '\n Id:' + lead.Id;
                    //--------------TrackMsg--------------------
                }
            }
            else
            {
                TrackMsgInsertLead = '';
                status = 'ERROR';
                message = 'Id Type and Id Number Not Match';
            }
            
            //--------------TrackMsg--------------------
            TrackMsgInsertProduct += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start Recommended Product, message=';
            //--------------TrackMsg--------------------
            
            for(leads ld : leads)
            {
                if(insertLeadMap.containsKey(ld.id_type+ld.id_number))
                {
                    for(recommended_products rp : ld.recommended_products)
                    {
                        //--------------TrackMsg--------------------
                        TrackMsgInsertProduct += ' \n hostproductmappingid:' + rp.host_product_mapping_id + ',leadid:'+insertLeadMap.get(ld.id_type+ld.id_number).Id;
                        //--------------TrackMsg--------------------
                        Product_Interest__c new_product = new Product_Interest__c();
                        new_product.Project_Code__c = rp.project_code;
                        new_product.Host_Product_Mapping__c = rp.host_product_mapping_id;
                        new_product.Max_Offer_Amount__c = rp.max_offer_amount;
                        new_product.Max_Tenor__c = rp.max_tenor;
                        new_product.Max_Tenor_Unit__c = rp.max_tenor_unit;
                        new_product.Max_Installment__c = rp.max_installment;
                        new_product.Rate__c = rp.rate;
                        new_product.Fee__c = rp.fee;
                        new_product.Offer_start_date__c = Date.valueOf(rp.offer_start_date);
                        new_product.Offer_end_date__c = Date.valueOf(rp.offer_end_date);
                        new_product.Offer_Last_update_date__c = DateTime.valueOf(rp.offer_last_update_date);
                        new_product.Status__c = rp.status;
                        new_product.Opportunity_Type__c = 'Credit';                
                        new_product.product__r = new Product2(SF_Product_Key__c = rp.product_code);
                        new_product.Lead__c = insertLeadMap.get(ld.id_type+ld.id_number).Id;
                        new_product.Merchant_Unique_ID__c = rp.merchant_unique_id;
                        new_product.Remark__c = rp.remark;
                        insertRecProductList.add(new_product);
                    }
                }
            }  
            if(insertRecProductList.size() > 0)
            {
                insert insertRecProductList;
                //--------------TrackMsg--------------------
                TrackMsgInsertProduct += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop Recommended Product, message=';
                //--------------TrackMsg--------------------
                for(Product_Interest__c pd : insertRecProductList)
                {
                    //--------------TrackMsg--------------------
                    TrackMsgInsertProduct += ' \n Id:' + pd.Id;
                    //--------------TrackMsg--------------------
                }
            }
            else
            {
                TrackMsgInsertProduct = '';
            }
            
            leadWrapper.status = status;
            leadWrapper.message = ''+message;
            
            errorMessage = TrackMsgQuery + TrackMsgCheckStart + TrackMsgCheckEnd + TrackMsgInsertProspect + TrackMsgInsertLead + TrackMsgInsertProduct;
            isSuccess = true;
            endTime = DateTime.Now();
            userName = accForLog.Name;
            rmId = accForLog.TMB_Customer_ID_PE__c;
            requestBody = JSON.serialize(leads);
            responseBody = JSON.serialize(leadWrapper);          
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
            return leadWrapper;
        }
        catch(System.DmlException e)
        {
            leadWrapper.status = 'ERROR';
            leadWrapper.message = 'Message: ' + e.getDmlMessage(0);
            
            errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString() + TrackMsgQuery + TrackMsgCheckStart + TrackMsgCheckEnd + TrackMsgInsertProspect + TrackMsgInsertLead + TrackMsgInsertProduct;
            isSuccess = false;
            endTime = DateTime.Now();
            userName = accForLog.Name;
            rmId = accForLog.TMB_Customer_ID_PE__c;
            requestBody = JSON.serialize(leads);
            responseBody = JSON.serialize(leadWrapper);
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog, 
                                                  startTime ,  endTime,  null );
            return leadWrapper;
        }
    }
}