public with sharing class RTL_NBOService {
    public class NBO {
        public String SoapStatus;
        public String SoapMessage;
        public Map<NBOHistory, List<NBOHistoryProduct>> nboMap;
    }
    public class NBOHistory {
        //public String RTL_NBO_Name;//Name (keyword, can't use Name as variable) 
        public String RTL_Campaign_Name;//Campaign Name   
        public String RTL_Campaign_Code;//Campaign Code
        public Date RTL_Contact_Date;//Contact Date
        public String RTL_Customer_Name;//Customer Name (SFDC ID)
        public String RTL_NBO_Group;//NBO Group
        public String RTL_NBO_ID;//NBO ID
        public String RTL_NBO_SubGroup;//NBO SubGroup
        public String RTL_Smart_Info;//Smart Info
        public String RTL_Status;//Status
        public String RTL_TMB_Customer_ID_PE;//TMB Customer ID
        public Date RTL_Valid_From;//Valid From
        public Date RTL_Valid_To;//Valid To
        public String RTL_Channel;//Assigned Channel
    }

    public class NBOHistoryProduct {
        public String RTL_NBO_ID;//NBO ID
        public String RTL_Product;//Product
        public String RTL_Product_Group;//Product Group
        public String RTL_Product_SubGroup;//Product SubGroup
        public String RTL_Product_Smart_Info;//Smart Info
        public String RTL_User_Branch;//Branch
        public String RTL_User_Region;//Region
        public String RTL_User_Zone;//Zone
        public String RTL_NBO_Product_External_ID;    
    }

    public static RTL_NBO_History__c newNBO(Id acctId, NBOHistory nbo) {
        RTL_NBO_History__c nboHistory = new RTL_NBO_History__c();
        nboHistory.RTL_NBO_ID__c = nbo.RTL_NBO_ID;
        nboHistory.RTL_Campaign_Name__c = nbo.RTL_Campaign_Name;
        nboHistory.RTL_Campaign_Code__c = nbo.RTL_Campaign_Code;
        nboHistory.RTL_Customer_Name__c = acctId;
        nboHistory.RTL_NBO_Group__c = nbo.RTL_NBO_Group;
        nboHistory.RTL_NBO_SubGroup__c = nbo.RTL_NBO_SubGroup;
        nboHistory.RTL_Valid_From__c = nbo.RTL_Valid_From;
        nboHistory.RTL_Valid_To__c = nbo.RTL_Valid_To;
        nboHistory.RTL_Smart_Info__c = nbo.RTL_Smart_Info;
        nboHistory.RTL_Contact_Date__c = nbo.RTL_Contact_Date;
        nboHistory.RTL_Channel__c = nbo.RTL_Channel;   
        nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();  
        nboHistory.RTL_TMB_Customer_ID_PE__c = nbo.RTL_TMB_Customer_ID_PE;
        return nboHistory;
    }   
    
    public static RTL_NBO_History_Product__c newNBOProduct(NBOHistoryProduct nboProduct, User user) {
        RTL_NBO_History_Product__c nboHistoryProduct = new RTL_NBO_History_Product__c();
        nboHistoryProduct.RTL_NBO_ID__c = nboProduct.RTL_NBO_ID;
        nboHistoryProduct.RTL_Product__c = nboProduct.RTL_Product;
        nboHistoryProduct.RTL_Product_Group__c = nboProduct.RTL_Product_Group;
        nboHistoryProduct.RTL_Product_SubGroup__c = nboProduct.RTL_Product_SubGroup;
        nboHistoryProduct.RTL_Product_Smart_Info__c = nboProduct.RTL_Product_Smart_Info;
        //nboHistoryProduct.RTL_User_Branch__c = user.RTL_Branch_Code__c;//leave it as blank until the NBO product is offered
        //nboHistoryProduct.RTL_User_Region__c = user.Region_Code__c;//leave it as blank until the NBO product is offered
        //nboHistoryProduct.RTL_User_Zone__c = user.Zone_Code__c;//leave it as blank until the NBO product is offered
        //nboHistoryProduct.RTL_Offering_Channel__c = 'Branch';//leave it as blank until the NBO product is offered
        nboHistoryProduct.RTL_Status__c = 'New';
        nboHistoryProduct.RTL_NBO_Product_External_ID__c = nboProduct.RTL_NBO_Product_External_ID;
        return nboHistoryProduct;//map the parent id later
    }     
    
    /**
    * @param acctId - Account Id specific to the NBO
    * @param user - User who press the 
    * @param nboMap - map of NBO and product
    */
    public static String validateNBO (Id acctId, User user, Map<NBOHistory, List<NBOHistoryProduct>> nboMap) {
        List<RTL_NBO_History__c> newNBOListToReturn = new List<RTL_NBO_History__c>(); 
        String insertionErrMsg = '';
        String errMsg = null;  
        
        //Get the list of inbound external NBO ID first
        Set<String> nboExtIdList = new Set<String>();
        for (NBOHistory nbo : nboMap.keySet()){
            nboExtIdList.add(nbo.RTL_NBO_ID);
        }
        
        //Store the list of existing NBO history filtering by inbound external NBO ID
        Map<String, RTL_NBO_History__c> nboHistoryList = new Map<String, RTL_NBO_History__c>();
        for(RTL_NBO_History__c nboHistory : [Select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c in : nboExtIdList and RTL_Customer_Name__c = :acctId]) {
            nboHistoryList.put(nboHistory.RTL_NBO_ID__c, nboHistory);
        }      

        List<RTL_NBO_History__c> nboHistoryListToInsert = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductListToInsertFinal = new List<RTL_NBO_History_Product__c>();
        List<NBOHistoryProduct> nboHisProductList = null;
        List<RTL_NBO_History_Product__c> nboHistoryProductList = null;
        Map<String, List<RTL_NBO_History_Product__c>> nboHistoryProductMapToInsert = new Map<String, List<RTL_NBO_History_Product__c>>();//key is NBO external ID
        for (NBOHistory nbo : nboMap.keySet()){
            if (nboHistoryList.get(nbo.RTL_NBO_ID) == null) {//nbo is not exist for this customer
                nboHistoryListToInsert.add(newNBO(acctId, nbo));
                nboHisProductList = nboMap.get(nbo);
                nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
                for (NBOHistoryProduct nboProduct: nboHisProductList) {                 
                    nboHistoryProductList.add(newNBOProduct(nboProduct, user));
                }
                nboHistoryProductMapToInsert.put(nbo.RTL_NBO_ID, nboHistoryProductList);
            }
        }
        
        String nboId = null;
        List<RTL_NBO_History__c> nboInsertedList = new List<RTL_NBO_History__c>();
        if(nboHistoryListToInsert.size() > 0){
            Integer nboCounter = 0;
            // Insert new NBO History
            Database.SaveResult[] lsr = Database.insert(nboHistoryListToInsert, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted NBO History with ID: ' + sr.getId());
                    nboInsertedList.add(nboHistoryListToInsert[nboCounter]);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if (nboHistoryListToInsert[nboCounter].RTL_NBO_ID__c == null) nboId = 'Unknown';
                        else nboId = nboHistoryListToInsert[nboCounter].RTL_NBO_ID__c;
                        errMsg = System.Label.RTL_NBO + ' - ID=' + nboId + ' - ' + System.Label.RTL_NBO_Insertion_ERR001 + ' ' + System.Label.RTL_NBO_Insertion_ERR000 + ': ' + err.getMessage();
                        System.debug(logginglevel.ERROR, errMsg);
                        insertionErrMsg += errMsg + '<br/>';
                    }
                }
                nboCounter++;
            }             
        }
        
        //map NBO history SFDC ID to each NBO History Product, then insert
        for (RTL_NBO_History__c nboHistoryWithId: nboInsertedList) {
            List<RTL_NBO_History_Product__c> nboHistoryProdList = nboHistoryProductMapToInsert.get(nboHistoryWithId.RTL_NBO_ID__c);
            if (nboHistoryProdList != null) {//invalid NBO History doesn't have NBO History Product
                for (RTL_NBO_History_Product__c nboHistoryProd: nboHistoryProdList) {
                    nboHistoryProd.RTL_Related_NBO__c = nboHistoryWithId.Id;//map to parent NBO History Id
                    nboHistoryProductListToInsertFinal.add(nboHistoryProd);
                }
            }
        }
        
        String nboProductId = null;
        if(nboHistoryProductListToInsertFinal.size() > 0){
            Integer nboProductCounter = 0;          
            // Insert new NBO History
            Database.SaveResult[] lsr = Database.insert(nboHistoryProductListToInsertFinal, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted NBO History Product with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if (nboHistoryProductListToInsertFinal[nboProductCounter].RTL_NBO_Product_External_ID__c == null) nboProductId = 'Unknown';
                        else nboProductId = nboHistoryProductListToInsertFinal[nboProductCounter].RTL_NBO_Product_External_ID__c;                       
                        errMsg = System.Label.RTL_NBO_Product + ' - ID=' + nboProductId + ' - ' + System.Label.RTL_NBO_Insertion_ERR002 + ' ' + System.Label.RTL_NBO_Insertion_ERR000 + ': ' + err.getMessage();
                        System.debug(logginglevel.ERROR, errMsg);
                        insertionErrMsg += errMsg + '<br/>';                        
                    }
                }
                nboProductCounter++;
            }             
        }
                                            
        return insertionErrMsg;
    }     
}