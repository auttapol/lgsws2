public with sharing class AdvisoryPlanningItemServices {

    @AuraEnabled
    public static LightningServiceResult getAdvisoryPlanningItems(String advisoryId, String itemType){
        LightningServiceResult result = new LightningServiceResult();

        try {
            if(!String.isBlank(advisoryId) && !String.isBlank(itemType)){
                List<Advisory_Planning_Item__c> planningItemList = AdvisoryPlanningSelector.getAdvisoryPlanningItemByItemType(new Set<String>{advisoryId}, new Set<String>{itemType});
                result.isSuccess = true;
                result.data = planningItemList;
            }else{
                result.isSuccess = false;
                result.errorMessage = 'Unable to get data due to lightning record page layout configuration incorrect.';
            }
            
            
        }catch (Exception e) {
            result.isSuccess = false;
            result.errorMessage = e.getMessage();
        }

        return result;
    }

    @AuraEnabled
    public static LightningServiceResult getColumnByFieldSet(String objectName, String fieldSetName){
        LightningServiceResult result = new LightningServiceResult();

        try {
            if(!String.isBlank(objectName) && !String.isBlank(fieldSetName)){
                List<AdvisoryPlanningItemServices.DataTableColumn> dataTableColumnList = new List<AdvisoryPlanningItemServices.DataTableColumn>();
                List<Schema.FieldSetMember> fieldSetMemberList = RMC_Utility.getFieldsByFieldSet(objectName, fieldSetName);
                if(fieldSetMemberList != null && !fieldSetMemberList.isEmpty()){
                    for(Schema.FieldSetMember eachMember  : fieldSetMemberList){
                        dataTableColumnList.add(new AdvisoryPlanningItemServices.DataTableColumn(eachMember));
                    }
                }
                result.isSuccess = true;
                result.data      = dataTableColumnList;
            }else{
                result.isSuccess = false;
                result.errorMessage = 'Unable to get data due to lightning record page layout configuration incorrect.';
            }
            
            
        }catch (Exception e) {
            result.isSuccess = false;
            result.errorMessage = e.getMessage();
        }
        return result;
    } 

    @AuraEnabled
    public static Object getAppConfigMdtByKey(String key) {
        Map<String, String> appConfigs = new Map<String, String>();
        for (App_Config__mdt appc : [SELECT DeveloperName, Value__c FROM App_Config__mdt WHERE DeveloperName = :key]) {
            appConfigs.put(appc.DeveloperName, appc.Value__c);
        }
        return appConfigs.containsKey(key) ? appConfigs.get(key) : '';
    }

    //mainbank red mdt atk
    @AuraEnabled 
    public static list<Show_Red_Product_Code__mdt> getRedProductcode(){
        List<Show_Red_Product_Code__mdt> mcs = [SELECT Show_Red__c, Product_Code__c, Id FROM Show_Red_Product_Code__mdt];
        return mcs;
    }
    
    @AuraEnabled
    public static Object getALDXWFMdt() {
        Map<String, ALDX_WF_Status__mdt> alds_wf_map = new Map<String, ALDX_WF_Status__mdt>();
        for(ALDX_WF_Status__mdt alds_wf : [SELECT STATUS_CODE__c, STATUS_NAME__c, WARNING_MESSAGE__c, IS_ACTIVE__c FROM ALDX_WF_Status__mdt WHERE WARNING_MESSAGE__c <> null]) {
            alds_wf_map.put(String.valueOf(Integer.valueOf(alds_wf.STATUS_CODE__c)), alds_wf);
        }
        return alds_wf_map;
    }

    

    @AuraEnabled(continuation=true)
    public static Object getProduct(String endpoint, String callback, String body, String ttbCustomerId){
        try{
            Object con = RTL_ProductHoldingsLightningUtil.getProduct(endpoint, callback, body, ttbCustomerId);
            return con;
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled(continuation=true)
    public static Object getAutoLoanProduct(String endpoint, String callback, String body, String service, Object state){
        try{
            Object con = CommercialAutoLoanController.getProduct(endpoint, callback, body, service, state);
            return con;
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Object advisory_callbackOSC01(List<String> labels, Object state){
        Object result = RTL_ProductHoldingsLightningUtil.callbackOSC01(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackOSC02(List<String> labels, Object state){
        Object result = RTL_ProductHoldingsLightningUtil.callbackOSC02(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackOSC04(List<String> labels, Object state){
        Object result = RTL_ProductHoldingsLightningUtil.callbackOSC04(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackOSC05(List<String> labels, Object state){
        Object result = RTL_ProductHoldingsLightningUtil.callbackOSC05(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackOSC06List(List<String> labels, Object state){
        Object result = RTL_ProductHoldingsLightningUtil.callbackOSC06List(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackAutoLoan(List<String> labels, Object state){
        Object result = CommercialAutoLoanController.callbackHpFleetHpList(labels, state);
        return result;
    }

    @AuraEnabled
    public static Object advisory_callbackHpFleetHpDetail(List<String> labels, Object state){
        Object result = CommercialAutoLoanController.callbackHpFleetHpDetail(labels, state);
        return result;
    }

    @AuraEnabled
    public static LightningServiceResult createAdvisoryPlanningItemHolding(String advisoryId, Boolean isHasProductHolding, List<ProductHolding> planningItemWrapperList){
        try {
            LightningServiceResult result = new LightningServiceResult();

            if(String.isBlank(advisoryId) || (isHasProductHolding && (planningItemWrapperList == null  ||  planningItemWrapperList.isEmpty()))){
                result.isSuccess = false;
                result.errorMessage = 'Cannot find the advisory plan id or items to be inserted.';
                return result;
            }

            if(isHasProductHolding){
                if(planningItemWrapperList != null && !planningItemWrapperList.isEmpty()){
                    List<Advisory_Planning_Item__c>  plannningItemList = new List<Advisory_Planning_Item__c>();
                    Set<String> productCodeSet = new Set<String>();
                    for(AdvisoryPlanningItemServices.ProductHolding eachHoldingItem : planningItemWrapperList){
                        productCodeSet.add(eachHoldingItem.productCode);
                    }

                    RMC_Utility.ProductCodeWrapper productCodeMapSet  = new RMC_Utility.ProductCodeWrapper();
                    productCodeMapSet.product2MapByProductCode = new Map<String, Product2>();
                    productCodeMapSet.product2MapByRTLProductCode = new Map<String, Product2>();
                    productCodeMapSet.product2MapByTMBProductType = new Map<String, Product2>();
                    if(productCodeSet != null && !productCodeSet.isEmpty()){
                        productCodeMapSet = RMC_Utility.getProductInformation(productCodeSet);
                    }

                    Integer index = 1;
                    for(AdvisoryPlanningItemServices.ProductHolding eachHoldingItem : planningItemWrapperList){
                        String itemName = eachHoldingItem.itemType  + '-' + eachHoldingItem.family + '-' + index;
                        Advisory_Planning_Item__c eachPlanningItem = new Advisory_Planning_Item__c(
                            Name = itemName,
                            Advisory_Planning__c = advisoryId,
                            Advisory_Item_Type__c = eachHoldingItem.itemType,
                            Is_Product_Holding__c = true,
                            Last_Sync_Date_Time__c = DateTime.now(),
                            Product_Group__c      = eachHoldingItem.family,
                            Baseline_Amount__c    = eachHoldingItem.baselineAmount,
                            Baseline_Allocation__c    = eachHoldingItem.baselineAllocation,
                            Target_Amount__c    = eachHoldingItem.targetAmount,
                            Target_Allocation__c    = eachHoldingItem.targetAllocation
                        );

                        Product2 productMaster = null;
                        String productCode     = eachHoldingItem.productCode;
                       
                        if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByRTLProductCode) && productCodeMapSet.product2MapByRTLProductCode.containsKey(productCode)) productMaster = (Product2) productCodeMapSet.product2MapByRTLProductCode.get(productCode);
                        else if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByTMBProductType) && productCodeMapSet.product2MapByTMBProductType.containsKey(productCode)) productMaster = (Product2) productCodeMapSet.product2MapByTMBProductType.get(productCode);
                        else if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByProductCode) && productCodeMapSet.product2MapByProductCode.containsKey(productCode)) productMaster = (Product2) productCodeMapSet.product2MapByProductCode.get(productCode);


                        if(productMaster != null){
                            eachPlanningItem.Product_Master__c = productMaster.Id;
                            eachPlanningItem.Product_Name__c   = productMaster.Name;
                            eachPlanningItem.Product_Holding_Code__c                = eachHoldingItem.productCode;
                            eachPlanningItem.Product_Sub_Group_Asset_Class__c  = (!String.isBlank( productMaster.Sub_Family__c))  ?  productMaster.Sub_Family__c : '';
                            if(!String.isBlank(productMaster.RTL_Asset_Class__c)){
                                eachPlanningItem.Product_Sub_Group_Asset_Class__c  = (!String.isBlank(eachPlanningItem.Product_Sub_Group_Asset_Class__c))  ? eachPlanningItem.Product_Sub_Group_Asset_Class__c + '-' : '' + productMaster.RTL_Asset_Class__c;
                            }
                        }else{
                            eachPlanningItem.Product_Name__c                        = eachHoldingItem.productName;
                            eachPlanningItem.Product_Holding_Code__c                = eachHoldingItem.productCode;
                            eachPlanningItem.Product_Sub_Group_Asset_Class__c       = eachHoldingItem.subGroup;
                        }

                        plannningItemList.add(eachPlanningItem);
                        index++;
                    }
                    if(plannningItemList != null && !plannningItemList.isEmpty()) upsert plannningItemList;
                }
            }

            Advisory_Planning__c planning = new Advisory_Planning__c(Id = advisoryId);
            planning.Is_Sync_Product_Holding__c = true;
            planning.Last_Sync_Date_Time__c     = DateTime.now();
            update planning;

            
            result.isSuccess = true;
            
            return result;
           
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }   

    public class DataTableColumn{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String fieldtype {get;set;}
        @AuraEnabled public Boolean sortable {get;set;}
        @AuraEnabled public String cellAttributes {get;set;}

        public DataTableColumn(Schema.FieldSetMember fieldMember){
            this.label          = fieldMember.getLabel();
            this.fieldName      = fieldMember.getFieldPath();
            this.sortable       = true;
            Schema.DisplayType memberFieldType    = fieldMember.getType();
            switch on memberFieldType {
                when INTEGER, DOUBLE {
                    this.fieldtype = 'number';
                }
                when CURRENCY {
                    this.fieldtype = 'currency';
                }
                when DATE , DATETIME {
                    this.fieldtype = 'date-local';
                }
                when PERCENT {
                    this.fieldtype = 'percent';
                }
                when else {
                    this.fieldtype = 'text';
                }
            }
            this.cellAttributes = (this.fieldtype == 'number' || this.fieldtype == 'currency' || this.fieldtype == 'percent'  ) ? 'right' : 'left';

        }
    }

    public class ProductHolding{
        @AuraEnabled public String itemType {get;set;}
        @AuraEnabled public String family {get;set;}
        @AuraEnabled public String subGroup {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String productCode {get;set;}
        @AuraEnabled public Decimal baselineAmount {get;set;}
        @AuraEnabled public Decimal baselineAllocation {get;set;}
        @AuraEnabled public Decimal targetAmount {get;set;}
        @AuraEnabled public Decimal targetAllocation {get;set;}
    }
}