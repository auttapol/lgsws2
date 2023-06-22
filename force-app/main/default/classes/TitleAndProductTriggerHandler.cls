public with sharing class TitleAndProductTriggerHandler {

    public static void handleBeforeInsert(List<Title_and_Product_Group_Mapping__c> titleNew){
        updateUniqueKey(titleNew);
    }

    public static void handleBeforeUpdate(List<Title_and_Product_Group_Mapping__c> titleNew){
        updateUniqueKey(titleNew);
    }

    public static void handleAfterInsert(List<Title_and_Product_Group_Mapping__c> titleNew,Map<Id,Title_and_Product_Group_Mapping__c> mapTitleOld){
        upsertSpecialistProduct(titleNew, mapTitleOld);
    }
    
    public static void handleAfterUpdate(List<Title_and_Product_Group_Mapping__c> titleNew,Map<Id,Title_and_Product_Group_Mapping__c> mapTitleOld){
        upsertSpecialistProduct(titleNew, mapTitleOld);
    }

    public static void updateUniqueKey(List<Title_and_Product_Group_Mapping__c> titleNew){
        for (Title_and_Product_Group_Mapping__c eachTitleNew : titleNew) {
            eachTitleNew.Unique_Key__c = eachTitleNew.Title__c + eachTitleNew.Product_Group__c;
            System.debug('Unique_Key__c : '+eachTitleNew.Unique_Key__c);
        }  
    }

    public static void upsertSpecialistProduct(List<Title_and_Product_Group_Mapping__c> titleNew,Map<Id,Title_and_Product_Group_Mapping__c> mapTitleOld){
        List<String> titleNewList = new List<String>();

        // Create Title Product Map
        Map<String,List<Title_and_Product_Group_Mapping__c>> titleProductMap = new Map<String,List<Title_and_Product_Group_Mapping__c>>();
        // for (Title_and_Product_Group_Mapping__c TP : [SELECT Name, Title__c , Product_Group__c, LastModifiedById,  Active__c FROM Title_and_Product_Group_Mapping__c WHERE Active__c = true]) {
        for (Title_and_Product_Group_Mapping__c TP : titleNew) {
            List<Title_and_Product_Group_Mapping__c> titleProductListAdd = new List<Title_and_Product_Group_Mapping__c>();
            if (TP.Active__c) {
                if(titleProductMap.containsKey(TP.Title__c)){
                    titleProductListAdd = titleProductMap.get(TP.Title__c);
                }
                titleProductListAdd.add(TP);
                titleProductMap.put(TP.Title__c, titleProductListAdd);

                titleNewList.add(TP.Title__c);
            }
        }//Create Title Product Map
            
        
        Integer i = 0;
        List<Specialist_and_Product_Group_Mapping__c> upsertSpecialistProductList = new List<Specialist_and_Product_Group_Mapping__c>();
        for (User eachUser : [SELECT ID, FirstName, LastName ,Title , RTL_Branch_Code__c, Employee_ID__c FROM User WHERE Title IN : titleNewList AND IsActive = true]) {
            if(titleProductMap.containsKey(eachUser.Title) && eachUser.RTL_Branch_Code__c != '' && eachUser.RTL_Branch_Code__c != null){
                List<Title_and_Product_Group_Mapping__c> titleProductListOfUser = titleProductMap.get(eachUser.Title);
                for (Title_and_Product_Group_Mapping__c TP : titleProductListOfUser) {
                    Specialist_and_Product_Group_Mapping__c newSpecialistAndProduct = new Specialist_and_Product_Group_Mapping__c();
                    newSpecialistAndProduct.Title__c = TP.Title__c;
                    newSpecialistAndProduct.Product_Group__c = TP.Product_Group__c;
                    // newSpecialistAndProduct.Last_Assigned_Lead_Date__c = Datetime.now();
                    newSpecialistAndProduct.Branch_Code__c = eachUser.RTL_Branch_Code__c;
                    newSpecialistAndProduct.External_Key__c = eachUser.RTL_Branch_Code__c+eachUser.Employee_ID__c+TP.Product_Group__c;
                    newSpecialistAndProduct.Agent__c = eachUser.ID;
                    newSpecialistAndProduct.Title_and_Product_Group_Mapping__c = TP.ID;

                    upsertSpecialistProductList.add(newSpecialistAndProduct);
                }
            }
        }
        if(upsertSpecialistProductList.size() > 0) upsert upsertSpecialistProductList External_Key__c;
    }
}