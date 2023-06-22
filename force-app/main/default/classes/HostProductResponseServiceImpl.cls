public with sharing class HostProductResponseServiceImpl implements HostProductResponseService.IHostProductResponseService {

    private  list<Host_Product_Response__c> listExistProduct {get; set;}
    private  list<Host_Product_Response__c> listNotExistProduct {get; set;}
    private  list<Host_Product_Response__c> listhostproduct {get; set;}
    private  map<string, list<opportunitylineitem>> mapOpportunityProductSF {get; set;}
    private  map<string, list<host_product_response__c>> mapOpportunityProductResponse {get; set;}



    public void reMappingHostProductResponseToOppLineItem(List<Host_Product_Response__c> hostProductResponse) {
        List<Host_Product_Response__c> needToReMappingHostProductResponseToOppLineItem = new List<Host_Product_Response__c>();

        // Step 1) Set Of hostProductUniqueKey
        Set<string>  hostProductUniqueKey =  new set<string>();
        for (Host_Product_Response__c proRes : hostProductResponse ) {

            hostProductUniqueKey.add(proRes.HostProductUniqueKey__c);
        }
        // Step 2) Create Host Product Mapping that has product2 id
        Map<string /*UniqueKey__c*/, Host_Product_Mapping__c> productMappingsByUniqueKey = getHostProductMappingByUniqueKey(hostProductUniqueKey);
        if (productMappingsByUniqueKey.size() > 0) {
            //>> Release Memory
            hostProductUniqueKey.clear();
            // Step 3) Filter Only Host Product That Contain Product2 Id
            for (Host_Product_Response__c hpres : hostProductResponse) {
                if (productMappingsByUniqueKey.containsKey(hpres.HostProductUniqueKey__c)) {
                    // Host Product Mapping
                    needToReMappingHostProductResponseToOppLineItem.add(hpres);
                }
            }
        }

        //>> Release Memory
        productMappingsByUniqueKey.clear();
        if (needToReMappingHostProductResponseToOppLineItem.size() > 0) {
            // Create a savepoint while AccountNumber is null
            Savepoint sp = Database.setSavepoint();
            try {
                // Step 4) Call same business process with trigger               
                checkProductExistInSalesforce(needToReMappingHostProductResponseToOppLineItem, true);
                // Step 5 Update Opportunity field  Pending Mapping Product Flag to false
                updatePendingMappingProductFlag(needToReMappingHostProductResponseToOppLineItem);
            } catch (Exception remapEx) {
                // Rollback to the previous null value
                system.debug(remapEx.getMessage());
                Database.rollback(sp);
            }
        }
    }
    public void updatePendingMappingProductFlag(List<Host_Product_Response__c> hostProductResponse) {
        if (null != hostProductResponse && hostProductResponse.size() > 0) {
            Set<id> opportunityIds = new Set<id>();
            for (Host_Product_Response__c item : hostProductResponse ) {
                //Set Of Opportunity Id
                opportunityIds.add(item.Host_Application_Response__r.Opportunity__c);
            }
            if (opportunityIds.size() > 0) {
                AggregateResult[] ars =
                    [ select Host_Application_Response__r.Opportunity__c, COUNT(ID) Total
                      from Host_Product_Response__c
                      where  Product2__c = null
                                           and Host_Application_Response__r.Opportunity__c in :opportunityIds
                                           and Host_Application_Response__r.Current_Application_Response__c = true
                                                   group by Host_Application_Response__r.Opportunity__c
                                                   having COUNT(ID) > 0 ] ;
                Set<Id> oppIds = new Set<id>();
                if (ars.size() > 0) {
                    for (AggregateResult ar : ars) {
//                        oppIds.add( (Id)ar.get('Host_Application_Response__r.Opportunity__c'));
                        oppIds.add( (Id)ar.get('Opportunity__c'));
                    }
                }
                List<Opportunity> oppUpdateFlag = new List<Opportunity>();
                for (Id oppId : opportunityIds) {
                    if (!oppIds.contains(oppId)) {
                        oppUpdateFlag.add(new Opportunity(Id = oppId ,  Pending_Mapping_Product__c = false));
                    }
                }
                if (oppUpdateFlag.size() > 0 ) {
                    update oppUpdateFlag;
                }
            }
        }
    }
    @testVisible
    private Map<string, Host_Product_Mapping__c> getHostProductMappingByUniqueKey(Set<string> hostProductUniqueKey) {

        Map<string, Host_Product_Mapping__c> ProductMappingsByUniqueKey = new Map<string, Host_Product_Mapping__c>();
        for (List<Host_Product_Mapping__c> hostProductMappings :
                [SELECT Host_Name__c, Host_Prod_Name_Credit_Facility__c, Host_Product_Code__c, Host_Product_Group__c, Id, UniqueKey__c, Product_Program__c
                 FROM Host_Product_Mapping__c
                 WHERE Salesforce_Product__c != null  AND UniqueKey__c IN: hostProductUniqueKey]) {
            for (Host_Product_Mapping__c hostProductMapping : hostProductMappings) {
                ProductMappingsByUniqueKey.put(hostProductMapping.UniqueKey__c, hostProductMapping);
            }
        }
        return ProductMappingsByUniqueKey;
    }
     public  void populateProductID(list<Host_Product_Response__c> listhostproductIN)
    {
        set<string> setProductMapping = new set<string>();
        set<string> setProductMappingCode = new set<string>();
        set<id> setHostAppResponseID = new set<id>();
        list<opportunity> listOpportunity = new list<opportunity>();
        map<string,Host_Product_Mapping__c> mapProductMappingSFProductID = new map<string,Host_Product_Mapping__c>();
        map<string,Host_Product_Mapping__c> mapProductMappingCodeSFProductID = new map<string,Host_Product_Mapping__c>();
        
        for (Host_Product_Mapping__c hp : [select ID, UniqueKey__c, Salesforce_Product__c, Host_Product_Code__c
                                           , Product_Group_ID__c
                                           , Product_Program_ID__c
                                           , Credit_Type_ID__c
                                           from Host_Product_Mapping__c
                                           Where Active_Flag__c = true])
        {
            setProductMapping.add(hp.UniqueKey__c);
            mapProductMappingSFProductID.put(hp.UniqueKey__c, hp);
            
            if (hp.Host_Product_Code__c != null && hp.Host_Product_Code__c != ''){
                setProductMappingCode.add(hp.Host_Product_Code__c);
                mapProductMappingCodeSFProductID.put(hp.UniqueKey__c, hp);
            }
        }
        
        for (Host_Product_Response__c hp : listhostproductIN)
        {
            if (setProductMapping.contains(hp.HostProductUniqueKey__c)){
                hp.Product2__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Salesforce_Product__c;
                hp.Product_Group_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Product_Group_ID__c;
                hp.Product_Program_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Product_Program_ID__c;
                hp.Credit_Type_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Credit_Type_ID__c;
                // add field host product mapping lookup
                hp.Host_Product_Mapping__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).ID;
            }else if (hp.Host_Product_Code__c != null && hp.Host_Product_Code__c != ''){
                if (setProductMappingCode.contains(hp.Host_Product_Code__c)){
                    hp.Product2__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Salesforce_Product__c;
                    hp.Product_Group_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Product_Group_ID__c;
                    hp.Product_Program_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Product_Program_ID__c;
                    hp.Credit_Type_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Credit_Type_ID__c;
                    // add field host product mapping lookup
                    hp.Host_Product_Mapping__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).ID;
                }
            }
        }
    }

    public  void checkProductExistInSalesforce(list<Host_Product_Response__c> listhostproductIN, boolean isUpdate)
    {
        try {
            listExistProduct = new list<Host_Product_Response__c>();
            listNotExistProduct = new list<Host_Product_Response__c>();
            listhostproduct = listhostproductIN;
            set<string> setProductMapping = new set<string>();
            set<string> setProductMappingCode = new set<string>();
            set<id> setHostAppResponseID = new set<id>();
            list<opportunity> listOpportunity = new list<opportunity>();
            map<string,Host_Product_Mapping__c> mapProductMappingSFProductID = new map<string,Host_Product_Mapping__c>();
            map<string,Host_Product_Mapping__c> mapProductMappingCodeSFProductID = new map<string,Host_Product_Mapping__c>();
            
            for (Host_Product_Mapping__c hp : [select ID, UniqueKey__c, Salesforce_Product__c, Host_Product_Code__c
                                               , Product_Group_ID__c
                                               , Product_Program_ID__c
                                               , Credit_Type_ID__c
                                               from Host_Product_Mapping__c
                                               where Active_Flag__c = true])
            {
                setProductMapping.add(hp.UniqueKey__c);
                mapProductMappingSFProductID.put(hp.UniqueKey__c, hp);
                
                if (hp.Host_Product_Code__c != null && hp.Host_Product_Code__c != ''){
                    setProductMappingCode.add(hp.Host_Product_Code__c);
                    mapProductMappingCodeSFProductID.put(hp.UniqueKey__c, hp);
                }
            }
        
            for (Host_Product_Response__c hp : listhostproduct)
            {
                boolean exist = false;
                
                if (setProductMapping.contains(hp.HostProductUniqueKey__c)){
                    exist = true;  
                    if (isUpdate){
                        hp.Product2__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Salesforce_Product__c;
                        hp.Product_Group_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Product_Group_ID__c;
                        hp.Product_Program_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Product_Program_ID__c;
                        hp.Credit_Type_ID__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).Credit_Type_ID__c;
                        // add field host product mapping lookup
                        hp.Host_Product_Mapping__c = mapProductMappingSFProductID.get(hp.HostProductUniqueKey__c).ID;
                    }
                }else if (hp.Host_Product_Code__c != null && hp.Host_Product_Code__c != ''){
                    if (setProductMappingCode.contains(hp.Host_Product_Code__c)){
                        exist = true;  
                        if (isUpdate){
                            hp.Product2__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Salesforce_Product__c;
                            hp.Product_Group_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Product_Group_ID__c;
                            hp.Product_Program_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Product_Program_ID__c;
                            hp.Credit_Type_ID__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).Credit_Type_ID__c;
                            // add field host product mapping lookup
                            hp.Host_Product_Mapping__c = mapProductMappingCodeSFProductID.get(hp.Host_Product_Code__c).ID;
                        }
                    }
                }
               
                if (!exist){
                    listNotExistProduct.add(hp);
                    setHostAppResponseID.add(hp.Host_Application_Response__c);
                }else{
                    listExistProduct.add(hp);
                }
            }
           
            if (setHostAppResponseID.size() > 0)
            {
                for (AggregateResult ar : [select Opportunity__c from Host_Application_Response__c where id in: setHostAppResponseID group by Opportunity__c])
                {
                    if (ar.get('Opportunity__c') != null && ar.get('Opportunity__c') != '')
                        listOpportunity.add(new Opportunity(id=string.valueof(ar.get('Opportunity__c')),Pending_Mapping_Product__c=true));
                }
                update listOpportunity;
            }
           
            if (listExistProduct.size() > 0)
            {
                if (isUpdate) update listhostproduct;
                HostProductResponseTriggerMainProcess();
            }
            
            if (listNotExistProduct.size() > 0)
            {
                createProductMapping();
            }
            
        }catch(exception ex){
            system.debug('Line number - ' + ex.getLineNumber() + ' Error - ' + ex.getMessage());
        }
    }
    
    public  void createProductMapping()
    {
        try {
            list<Host_Product_Mapping__c> listCreateProductMap = new list<Host_Product_Mapping__c>();
            for (Host_Product_Response__c hp : listNotExistProduct)
            {
                Host_Product_Mapping__c h = new Host_Product_Mapping__c(
                    Host_Name__c = hp.Host_Name__c,
                    Host_Prod_Name_Credit_Facility__c = hp.Host_Product_Name__c,
                    Host_Product_Code__c = hp.Host_Product_Code__c,
                    Host_Product_Group__c = hp.Host_Product_Group__c,
                    Product_Program__c = hp.Host_Product_Program__c
                );
                listCreateProductMap.add(h);
            }
            
            insert listCreateProductMap;
        }catch(exception ex){
            system.debug('Line number - ' + ex.getLineNumber() + ' Error - ' + ex.getMessage());
        }
    }
    
    public  void HostProductResponseTriggerMainProcess()
    {
        try{
            mapOpportunityProductSF = new map<string,list<opportunitylineitem>>();
            mapOpportunityProductResponse = new map<string,list<host_product_response__c>>();
            set<string> setAppResponseID = new set<string>();
            set<string> setOpportunityID = new set<string>();
            map<string,string> mapPricebook = new map<string,string>();
            map<string,string> mapNewHostProductGroup = new map<string,string>();
            list<opportunity> listUpdateOpportunityHostProductGroup = new list<opportunity>();
            
            for (host_product_response__c hp : listExistProduct)
            {
                setAppResponseID.add(hp.Host_Application_Response__c);
            }
            
            for (host_application_response__c ha : [select opportunity__c
                                                    , (select id
                                                       , Product_Status__c
                                                       , Cancel_Reject_Reason__c
                                                       , Approved_Amount__c
                                                       , Actual_Amount__c
                                                       , Product2__c
                                                       , Request_Amt_Vol__c
                                                       , No_of_Accounts__c
                                                       , Product_Group_ID__c
                                                       , Product_Program_ID__c
                                                       , Credit_Type_ID__c
                                                       , Host_Product_Mapping__c
                                                       , Host_Product_Group__c
                                                       from host_product_response__r
                                                       where product2__c != null)
                                                       , opportunity__r.pricebook2id
                                                       , opportunity__r.Host_Product_Group__c
                                                    from host_application_response__c 
                                                    where id in: setAppResponseID
                                                    and Current_Application_Response__c = true])
            {
                setOpportunityID.add(ha.Opportunity__c);
                mapOpportunityProductResponse.put(ha.opportunity__c, ha.host_product_response__r);
                mapPricebook.put(ha.opportunity__c, ha.opportunity__r.pricebook2id);
                
                mapNewHostProductGroup.put(ha.opportunity__c, ha.host_product_response__r.get(0).Host_Product_Group__c);
                /*
                for (host_product_response__c hp : ha.host_product_response__r)
                {
                    if (hp.Host_Product_Group__c != ha.opportunity__c.Host_Product_Group__c){
                        mapNewHostProductGroup.put(ha.opportunity__c, hp.Host_Product_Group__c);
                    }
                }
                */
            } 
            
            for (opportunity op : [select ID, Host_Product_Group__c
                                           , (select id
                                              , Product2id
                                              , unitprice
                                              , Host_Product_Status__c
                                              , quantity
                                              , Approved_Amount__c
                                              , Actual_Amount__c 
                                              , Cancel_Reject_Reason__c
                                              , Product_Group_ID__c
                                              , Product_Program_ID__c
                                              , Credit_Type_ID__c
                                              , Host_Product_Mapping__c
                                              from opportunity.opportunitylineitems)
                                           from opportunity where ID in: setOpportunityID])
            {
                mapOpportunityProductSF.put(op.ID, op.opportunitylineitems);
                
                if ((op.Host_Product_Group__c != mapNewHostProductGroup.get(op.ID)) && mapNewHostProductGroup.get(op.ID) != null){
                    op.Host_Product_Group__c = mapNewHostProductGroup.get(op.ID);
                    listUpdateOpportunityHostProductGroup.add(op);
                }
            }

            
            list<opportunitylineitem> listupdateOppline = new list<opportunitylineitem>();
            list<opportunitylineitem> listcreateoppProduct = new list<opportunitylineitem>();
            
            Map<String, PricebookEntry> mapProductPricebookEntry = getProductPricebookEntryList();
            
            for (string s : setOpportunityID)
            {
                string oppid = s;
                list<opportunitylineitem> listoppline = mapOpportunityProductSF.get(s);
                list<host_product_response__c> listhostproductresponse = mapOpportunityProductResponse.get(s);
              
                for (host_product_response__c h : listhostproductresponse)
                {
                    boolean createOppProduct = false;
                    string productid = h.Product2__c;
                    list<opportunitylineitem> listopplinetemp = listoppline;
                    integer index = 0;
                    boolean found = false;
                    for (opportunitylineitem o : listopplinetemp)
                    {
                        //if (productid == o.product2id && !found)
                        if (h.host_product_mapping__c == o.host_product_mapping__c && !found)
                        {
                            found = true;
                            listupdateOppline.add(mapFieldOpportunityProduct(o,h));
                        }else{
                            if (!found) index++;
                        }
                    }
                    if (found) listoppline.remove(index);
                    if (!found){
                        String pbeKey = productid + mapPricebook.get(s);
                        PricebookEntry pbe = mapProductPricebookEntry.get(pbeKey);
                        if (pbe != null)
                        {
                            opportunitylineitem oppProd = new opportunitylineitem(
                                opportunityid = s,
                                pricebookentryid = pbe.id
                            );
                            oppProd = mapFieldOpportunityProduct(oppProd, h);
                            listcreateoppProduct.add(oppProd);
                        }else{
                            listhostproduct.get(0).addError('Product Pricebook not match with Opportunity Pricebook');
                            //system.debug('pricebook not match with opty');
                        }
                    }
                }
                
            }
            
            if (listupdateoppline.size() > 0){
                update listupdateoppline;
            }
            if (listcreateoppProduct.size() > 0){
                insert listcreateoppProduct;    
            }
            if (listUpdateOpportunityHostProductGroup.size() > 0){
                update listUpdateOpportunityHostProductGroup;
            }
        }catch(exception ex){
            system.debug('Line number - ' + ex.getLineNumber() + ' Error - ' + ex.getMessage());
        }    
    }
  
    public  opportunitylineitem mapFieldOpportunityProduct(opportunitylineitem oppProduct, host_product_response__c hostProductResponse)
    {
        /****** Change condition 2017-06-26
        if (string.isNotBlank(hostProductResponse.product_status__c) && hostProductResponse.product_status__c.tolowercase().contains('reject')){
            oppProduct.unitprice = 0;
        }else{
            oppProduct.unitprice = (hostProductResponse.Request_Amt_Vol__c != null) ? hostProductResponse.Request_Amt_Vol__c : 0;
        }
        ***********/
        if (string.isNotBlank(hostProductResponse.product_status__c) 
            && (hostProductResponse.product_status__c.tolowercase().contains('reject') || hostProductResponse.product_status__c.tolowercase().contains('cancel'))
        ){
            oppProduct.Approved_Amount__c = 0;
            oppProduct.Actual_Amount__c = 0;
        }else{
            oppProduct.Approved_Amount__c = (hostProductResponse.Approved_Amount__c != null) ? hostProductResponse.Approved_Amount__c : 0;
            oppProduct.Actual_Amount__c = (hostProductResponse.Actual_Amount__c != null) ? hostProductResponse.Actual_Amount__c: 0;
        }
        
        oppProduct.unitprice = (hostProductResponse.Request_Amt_Vol__c != null) ? hostProductResponse.Request_Amt_Vol__c : 0;
        
        oppProduct.Host_Product_Status__c = hostProductResponse.Product_Status__c;
        oppProduct.quantity = (hostProductResponse.No_of_Accounts__c != null && hostProductResponse.No_of_Accounts__c > 0) ? hostProductResponse.No_of_Accounts__c : 1;
        //oppProduct.Approved_Amount__c = hostProductResponse.Approved_Amount__c;
        //oppProduct.Actual_Amount__c = hostProductResponse.Actual_Amount__c;
        oppProduct.Cancel_Reject_Reason__c = hostProductResponse.Cancel_Reject_Reason__c;
        
        oppProduct.Product_Group_ID__c = hostProductResponse.Product_Group_ID__c;
        oppProduct.Product_Program_ID__c = hostProductResponse.Product_Program_ID__c;
        oppProduct.Credit_Type_ID__c = hostProductResponse.Credit_Type_ID__c;
        
        oppProduct.Host_Product_Mapping__c = hostProductResponse.Host_Product_Mapping__c;
        
        return oppProduct;
    }


    public void validateCurrentAppAfterUpsertHostApp (list<host_product_response__c> listHostProductIN)
    {
        try{
        
            set<string> setHostAppID = new set<string>();
            set<string> setOpty = new set<string>();
            set<host_application_response__c> setHostApp = new set<host_application_response__c>();
            map<string,boolean> mapCurrentAppResponse = new map<string,boolean>();
            
            for (host_product_response__c hp : listHostProductIn)
            {
                setHostAppID.add(hp.host_application_response__c);
            }
            
            for (host_application_response__c ha : [select id, opportunity__c, current_application_response__c 
                                                    from host_application_response__c 
                                                    where id in: setHostAppID])
            {
                setOpty.add(ha.opportunity__c);
                mapCurrentAppResponse.put(ha.id, ha.current_application_response__c);
            }
            
            string tempOpty1 = '';
            string tempOpty2 = '';
            list<host_application_response__c> listAppTemp = new list<host_application_response__c>();
            list<host_application_response__c> listAppUpdate = new list<host_application_response__c>();
            
            for (host_application_response__c hp : [select id, App_Ref_Number__c, Current_Application_Response__c, opportunity__c 
                                                    from Host_Application_Response__c 
                                                    where opportunity__c in : setOpty
                                                    //where id in: setHostAppID 
                                                    order by opportunity__c,App_Ref_Number__c desc])
            {
                tempOpty1 = hp.opportunity__c;
                
                if ((tempOpty1 != tempOpty2) && (tempOpty2 != '')){
    
                    double tempRef1 = 0;
                    double tempRef2 = 0;
                    string maxAppRef = '';
                    for (host_application_response__c hp2 : listAppTemp)
                    {
                        if (tempRef1 < double.valueof(hp2.app_ref_number__c.right(6))){
                            tempRef1 = double.valueof(hp2.app_ref_number__c.right(6));
                            maxAppRef = hp2.app_ref_number__c;
                        }
                    }
                    
                    for (host_application_response__c hp2 : listAppTemp)
                    {
                        if (hp2.app_ref_number__c == maxAppRef){
                            hp2.Current_Application_Response__c = true;
                        }else{
                            hp2.Current_Application_Response__c = false;
                        }
                        
                        if (hp2.Current_Application_Response__c != mapCurrentAppResponse.get(hp2.id))
                            listAppUpdate.add(hp2);
                    }
                    
                    listAppTemp = new list<host_application_response__c>();
                }
                
                listAppTemp.add(hp);
                
                tempOpty2 = hp.opportunity__c;
            }
         
            if (tempOpty1 == tempOpty2){
                double tempRef1 = 0;
                double tempRef2 = 0;
                string maxAppRef = '';
                for (host_application_response__c hp2 : listAppTemp)
                {
                    if (tempRef1 < double.valueof(hp2.app_ref_number__c.right(6))){
                        tempRef1 = double.valueof(hp2.app_ref_number__c.right(6));
                        maxAppRef = hp2.app_ref_number__c;
                    }
                }
                
                for (host_application_response__c hp2 : listAppTemp)
                {
                    if (hp2.app_ref_number__c == maxAppRef){
                        hp2.Current_Application_Response__c = true;
                    }else{
                        hp2.Current_Application_Response__c = false;
                    }
                    
                    if (hp2.Current_Application_Response__c != mapCurrentAppResponse.get(hp2.id))
                        listAppUpdate.add(hp2);
                }
                
                listAppTemp = new list<host_application_response__c>();
            }
            
            
            if (listAppUpdate.size() > 0)
                update listAppUpdate;
        }catch(exception ex){
            system.debug('Line number - ' + ex.getLineNumber() + ' Error - ' + ex.getMessage());
        }
    }

    //Fix BAU_8654_INC0090053
    private Map<String, PricebookEntry> getProductPricebookEntryList()
    {
        Map<String, PricebookEntry> mapPricebookEntry = new Map<String, PricebookEntry>();        
        for(PricebookEntry pbe : [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry])
        {
            String idKey = String.valueOf(pbe.Product2Id) + String.valueOf(pbe.Pricebook2Id);
            mapPricebookEntry.put(idKey, pbe);
        }
        
        return mapPricebookEntry;              
    }  


}