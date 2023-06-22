public with sharing class AdvisoryPlanningEditAllocationServices {
    public static final Integer MAX_DEFAULT_ROW = 50;
    @AuraEnabled
    public static LightningServiceResult getProductInformation(ProductSearchCriteria criteria){
        System.debug('------ get product information -------');
        System.debug(criteria);
        
        LightningServiceResult result = new LightningServiceResult();
        try {
            String objectName   = 'Product2';
            String limitItem    = '1000';
            String fieldSet     = 'Id, ProductCode, RTL_PRODUCT_CODE__c,RTL_TMB_Product_Type__c,Name, RMC_1Year_Return__c, RMC_Latest_Update_of_MF_Return__c, RTL_Product_Name_ENG__c, RTL_Product_Name_TH__c, RTL_Product_Short_Name_ENG__c, RTL_Product_Short_Name_TH__c, Family, Sub_Family__c, RTL_Asset_Class__c, IsActive';
            String conditions   = 'IsActive = TRUE';
            String  keyword1 = criteria.keyword1;
            String  keyword2 = criteria.keyword2;
            String  keyword3 = criteria.keyword3;
            Integer maxReturnRow = (criteria.maxReturnRow == null) ? MAX_DEFAULT_ROW : criteria.maxReturnRow;
            List<Product2> recordList = new List<Product2>();

            if(criteria.productFamily != null && !criteria.productFamily.isEmpty()){
                List<String> productFamilyList = criteria.productFamily;
                conditions += ' AND Family IN: productFamilyList';
            }
            if(criteria.existingProduuctIdSet != null && !criteria.existingProduuctIdSet.isEmpty()){
                List<String> existingProduuctIdSet = criteria.existingProduuctIdSet;
                conditions += ' AND Id NOT IN: existingProduuctIdSet';
            }

            String query        = 'SELECT {0} FROM {1} WHERE {2} LIMIT {3}';
            String soql         = String.format(query, new List<String>{fieldSet, objectName,  conditions, limitItem});
            System.debug(soql);
            recordList = (List<Product2>) Database.query(soql);


            /*if(String.isBlank(keyword1) && String.isBlank(keyword2) && String.isBlank(keyword3)){
                String query        = 'SELECT {0} FROM {1} WHERE {2} LIMIT {3}';
                String soql         = String.format(query, new List<String>{fieldSet, objectName,  conditions, limitItem});
                System.debug(soql);
                recordList = (List<Product2>) Database.query(soql);
            }else{ 
                String query        = 'FIND {0} IN NAME FIELDS RETURNING {1}({2} WHERE {3} LIMIT {4})';
                String findStr      = '{';
                Integer indexFind   = 0;
                if(!String.isBlank(keyword1)){
                    findStr += '"'+ keyword1 + '*"';
                    indexFind++;
                }
                if(!String.isBlank(keyword2)){
                    if(indexFind > 0) findStr += ' AND ';
                    findStr += '"'+ keyword2 + '*"';
                    indexFind++;
                }
                if(!String.isBlank(keyword3)){
                    if(indexFind > 0) findStr += ' AND ';
                    findStr += '"'+ keyword3 + '*"';
                }

                findStr            += '}';
                String sosl         = String.format(query, new List<String>{ findStr , objectName, fieldSet, conditions, limitItem});
                System.debug(sosl);
                Search.SearchResults productSearchResults = Search.find(sosl);
                if(productSearchResults != null){
                    
                    List<Search.SearchResult> productSearchResultList = productSearchResults.get('Product2');
                    System.debug(productSearchResultList);
                    if(productSearchResultList != null && !productSearchResultList.isEmpty()){
                        for(Search.SearchResult eachResult : productSearchResultList){
                            System.debug(eachResult);
                            recordList.add((Product2) eachResult.getSObject());
                        }
                    }
                }
            }
            System.debug('---- record list ----');
            System.debug(recordList);*/

            Integer keywordSize = 0;
            if(!String.isBlank(keyword1)) keywordSize += 1;
            if(!String.isBlank(keyword2)) keywordSize += 1;
            if(!String.isBlank(keyword3)) keywordSize += 1;

            if(keywordSize == 0) maxReturnRow = MAX_DEFAULT_ROW;
            System.debug('keywordSize = ' + keywordSize);

            String userLanguage = UserInfo.getLanguage();
            Boolean isThai      = (userLanguage.toLowerCase() == 'th') ? true : false;
            Map<Id,AdvisoryPlanningEditAllocationServices.ProductData> productResultList = new Map<Id,AdvisoryPlanningEditAllocationServices.ProductData>();
            if(recordList != null && !recordList.isEmpty()){
                Integer listIndex = 0;
                for(Product2 eachProduct : recordList){
                    Integer containsCount  = 0;
                    if(!String.isBlank(keyword1)){
                        Boolean isContain = isContainKeyword(eachProduct, 'Sub_Family__c', keyword1) ||
                                            isContainKeyword(eachProduct, 'RTL_Asset_Class__c', keyword1) ||
                                            isContainKeyword(eachProduct, 'ProductCode', keyword1) ||
                                            isContainKeyword(eachProduct, 'Name', keyword1) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_ENG__c', keyword1) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_TH__c', keyword1);
                        if(isContain) containsCount += 1;
                    }

                    if(!String.isBlank(keyword2)){
                        Boolean isContain = isContainKeyword(eachProduct, 'Sub_Family__c', keyword2) ||
                                            isContainKeyword(eachProduct, 'RTL_Asset_Class__c', keyword2) ||
                                            isContainKeyword(eachProduct, 'ProductCode', keyword2) ||
                                            isContainKeyword(eachProduct, 'Name', keyword2) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_ENG__c', keyword2) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_TH__c', keyword2);
                        if(isContain) containsCount += 1;
                    }

                    if(!String.isBlank(keyword3)){
                        Boolean isContain = isContainKeyword(eachProduct, 'Sub_Family__c', keyword3) ||
                                            isContainKeyword(eachProduct, 'RTL_Asset_Class__c', keyword3) ||
                                            isContainKeyword(eachProduct, 'ProductCode', keyword3) ||
                                            isContainKeyword(eachProduct, 'Name', keyword3) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_ENG__c', keyword3) ||
                                            isContainKeyword(eachProduct, 'RTL_Product_Name_TH__c', keyword3);
                        if(isContain) containsCount += 1;
                    }

                    if(containsCount != 0) System.debug('containsCount = ' + containsCount);
                    if(containsCount == keywordSize && listIndex < maxReturnRow){
                        AdvisoryPlanningEditAllocationServices.ProductData newProductData = new AdvisoryPlanningEditAllocationServices.ProductData();
                        newProductData.productId            = eachProduct.Id;
                        newProductData.productName          = eachProduct.Name;
                        if(isThai){
                            if(!String.isBlank(eachProduct.RTL_Product_Name_TH__c)) newProductData.productName      = eachProduct.RTL_Product_Name_TH__c;
                        }else{
                            if(!String.isBlank(eachProduct.RTL_Product_Name_ENG__c)) newProductData.productName      = eachProduct.RTL_Product_Name_ENG__c;
                        }
    
                        
                        if(!String.isBlank(eachProduct.RTL_PRODUCT_CODE__c)){
                            newProductData.productCode      = eachProduct.RTL_PRODUCT_CODE__c;
                        }else if(!String.isBlank(eachProduct.RTL_TMB_Product_Type__c)){
                            newProductData.productCode          = eachProduct.RTL_TMB_Product_Type__c+'CRE';
                        }else{
                            newProductData.productCode          = eachProduct.Productcode;
                        }
                        newProductData.family               = eachProduct.Family;
                        if(eachProduct.RMC_1Year_Return__c != null){
                            newProductData.invest_1YearReturn   = eachProduct.RMC_1Year_Return__c;
                        }else{
                            newProductData.invest_1YearReturn   = 0;
                        }
                        
                        // newProductData.investmentSyncDateTime = eachProduct.RMC_Latest_Update_of_MF_Return__c;
                        if(eachProduct.RMC_Latest_Update_of_MF_Return__c != null){
                            newProductData.investmentSyncDateTime = (eachProduct.RMC_Latest_Update_of_MF_Return__c).format('dd-MM-yyyy HH:mm', 'Asia/Bangkok');
                        }
                        
                        newProductData.subFamiltyAsset      = '';
                        if(!String.isBlank(eachProduct.Sub_Family__c)){
                            newProductData.subFamiltyAsset  += eachProduct.Sub_Family__c;
                        }
    
                        if(!String.isBlank(eachProduct.RTL_Asset_Class__c)){
                            if(!String.isBlank(newProductData.subFamiltyAsset))  newProductData.subFamiltyAsset += ' - ';
                            newProductData.subFamiltyAsset += eachProduct.RTL_Asset_Class__c;
                        }
    
                        productResultList.put(eachProduct.Id, newProductData);
                        listIndex++;
                    }

                    if(listIndex == maxReturnRow) break;
                }
            }

            result.isSuccess = true;
            result.data      = (productResultList != null && !productResultList.isEmpty()) ?  productResultList.values() : null;


        } catch (Exception e) {
            result.isSuccess = false;
            result.errorMessage = e.getMessage();
        }

        return result;
    }

    public static Boolean isContainKeyword(Product2 eachProduct, String fieldName, String keyword){
        String fieldData = (String) eachProduct.get(fieldName);
        if(!String.isBlank(fieldData)) fieldData = fieldData.toLowerCase();
        return (!String.isBlank(fieldData) && fieldData.contains(keyword.toLowerCase()) );                        
    }

    @AuraEnabled
    public static LightningServiceResult saveAdvisoryPlanningItem(String advisoryId , List<Advisory_Planning_Item__c> itemList, List<String> toDeletedIdList){
        LightningServiceResult result = new LightningServiceResult();
        try {
            if(toDeletedIdList != null && !toDeletedIdList.isEmpty()){
                Map<Id,Advisory_Planning_Item__c> toBeDeleteItemMap = new Map<Id,Advisory_Planning_Item__c>();
                for(String itemId : toDeletedIdList){
                    if(!String.isBlank(itemId)){
                        Advisory_Planning_Item__c eachItem = new Advisory_Planning_Item__c(Id = itemId);
                        toBeDeleteItemMap.put(eachItem.Id, eachItem);
                    }
                }

                if(toBeDeleteItemMap != null && !toBeDeleteItemMap.isEmpty()) delete toBeDeleteItemMap.values();
            }

            List<Advisory_Planning_Item__c> toBeSaveItemList = new List<Advisory_Planning_Item__c>();
            if(itemList != null && !itemList.isEmpty() && !String.isBlank(advisoryId)){
                Integer index = 1;
                for(Advisory_Planning_Item__c eachItem : itemList){
                    String itemName = eachItem.Advisory_Item_Type__c  + '-' + eachItem.Product_Group__c + '-' + index;
                    eachItem.Name   = itemName;
                    
                    if(!String.isBlank(eachItem.Id)){
                        if(eachItem.Product_Group__c == 'BOND'){
                            toBeSaveItemList.add(eachItem);
                        }else{
                            Advisory_Planning_Item__c updateItem = new Advisory_Planning_Item__c(Id = eachItem.Id);
                            updateItem.Name                    = itemName;
                            updateItem.Baseline_Allocation__c  = eachItem.Baseline_Allocation__c;
                            updateItem.Target_Allocation__c    = eachItem.Target_Allocation__c;
                            updateItem.Target_Amount__c        = eachItem.Target_Amount__c;
                            toBeSaveItemList.add(updateItem);
                        }
                    }else{
                        eachItem.Advisory_Planning__c = advisoryId;
                        toBeSaveItemList.add(eachItem);
                    }
                    index++;
                }
            }

            if(toBeSaveItemList != null && !toBeSaveItemList.isEmpty()) upsert toBeSaveItemList;
            result.isSuccess = true;
            
        } catch (Exception e) {
            result.isSuccess     = false;
            result.errorMessage  = e.getMessage();
        }

        return result;
    }

    public class ProductSearchCriteria{
        
        @AuraEnabled public List<String> productFamily {get;set;}
        // @AuraEnabled public String productName {get;set;}
        // @AuraEnabled public String productSubFamily {get;set;}
        // @AuraEnabled public String assetClass {get;set;}
        @AuraEnabled public String keyword1 {get;set;}
        @AuraEnabled public String keyword2 {get;set;}
        @AuraEnabled public String keyword3 {get;set;}
        @AuraEnabled public List<String> existingProduuctIdSet {get;set;}
        @AuraEnabled public Integer maxReturnRow {get;set;}
    }

    public class ProductData{
        @AuraEnabled public String productId {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String productCode {get;set;}
        @AuraEnabled public String family {get;set;}
        @AuraEnabled public String subFamiltyAsset {get;set;}
        @AuraEnabled public Decimal invest_1YearReturn {get;set;}
        @AuraEnabled public String investmentSyncDateTime {get;set;}
    }
}