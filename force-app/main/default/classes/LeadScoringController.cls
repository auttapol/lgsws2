public with sharing class LeadScoringController{

    public class FieldDescribeWrapper{
        @AuraEnabled
        public Map<String, List<String>> fieldList{ get; set; }

        @AuraEnabled
        public Map<String, List<String>> fieldLabelList{ get; set; }

        @AuraEnabled
        public Map<String, Map<String, String>> mapfieldAPIwithLabel{ get; set; }

        @AuraEnabled
        public Map<String, Map<String, String>> mapfieldNamewithtype{ get; set; }

        @AuraEnabled
        public Map<String, Map<String, String>> mapfieldNamewithLength{ get; set; }

        @AuraEnabled
        public Map<String, FieldAPILabelWrapper> newMapAPiNameLabel{ get; set; }

        @AuraEnabled
        public Map<String, Map<String, String>> newAPiNameWithLabel{ get; set; }


    }

    public class FieldAPILabelWrapper{
        @AuraEnabled
        public List<String> Label{ get; set; }

        @AuraEnabled
        public List<String> API{ get; set; }

    }

    public class scoringListWrapper{
        @AuraEnabled
        public Lead_Scoring_List__c LSL;
        @AuraEnabled
        public LIST<Lead_Scoring_Condition__c> LSC;
    }


    @AuraEnabled
    public static scoringListWrapper getRecord(Id recordId){
        scoringListWrapper slw = new scoringListWrapper();
        slw.LSL = [SELECT Id, Description__c, Total_Weight__c, Summary_weight__c, Name, isActive__c FROM Lead_Scoring_List__c WHERE Id =:recordId];
        slw.LSC = [SELECT Id, Field_Mapping__c, Object__c, Lead_Scoring_List__c, Name, Weight__c FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c =:recordId ORDER BY CreatedDate ];
        return slw;
    }

    @AuraEnabled
    public static List<Lead_Scoring_Condition_Detail__c> getConDetail(Id recordId){
        System.debug(recordId);
        return [SELECT Id, Value1__c, Value2__c, Priority__c, Score__c, Operation__c, Name, Lead_Scoring_Condition__c FROM Lead_Scoring_Condition_Detail__c WHERE Lead_Scoring_Condition__c =:recordId ORDER BY Priority__c ASC];   
    }

    @AuraEnabled
    public static FieldDescribeWrapper getFieldName(){
        FieldDescribeWrapper fieldwrapper = new FieldDescribeWrapper();
        Map<String, FieldAPILabelWrapper> mapAPIwrapper = new Map<String, FieldAPILabelWrapper>();

        List<String> fieldListCM = new List<String>();
        List<String> fieldListLead = new List<String>();

        List<String> fieldAPIListCM = new List<String>();
        List<String> fieldAPIListLead = new List<String>();

        List<String> fieldLabelListCM = new List<String>();
        List<String> fieldLabelListLead = new List<String>();

        Map<String, List<String>> mapobjectwithapiName = new Map<String, List<String>>();

        Map<String, Map<String, String>> mapobjectwithApiType = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapobjectwithApiLength = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapobjectwithApiLabel = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapobjectwithAPI = new Map<String, Map<String, String>>();

        Map<String, String> mapfieldwithTypeCM = new Map<String, String>();
        Map<String, String> mapfieldwithTypeLead = new Map<String, String>();

        Map<String, String> mapfieldwithLengthLead = new Map<String, String>();
        Map<String, String> mapfieldwithLengthCM = new Map<String, String>();
        

        Map<String, String> mapfieldwithAPICM = new Map<String, String>();
        Map<String, String> mapfieldwithAPILead = new Map<String, String>();
        Map<String, String> mapAPICMwithFieldName = new Map<String, String>();
        Map<String, String> mapAPILeadwithFieldName = new Map<String, String>();

        FieldAPILabelWrapper newLeadwrapper = new FieldAPILabelWrapper();
        FieldAPILabelWrapper newCMwrapper = new FieldAPILabelWrapper();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMapCM = schemaMap.get('CampaignMember').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> fieldMapLead = schemaMap.get('Lead').getDescribe().fields.getMap();

        // Set<String> objectFields = new Set<String>();

        // if(objectName == 'CampaignMember'){
        //     objectFields = Schema.SObjectType.CampaignMember.fields.getMap().keySet();
        //     // mapfieldwithlength = Schema.SObjectType.CampaignMember.getDescribe().getLength();
        // }else if(objectName == 'Lead'){
        //     objectFields = Schema.SObjectType.Lead.fields.getMap().keySet();
        // }
        List<String> availableTypeList = new List<String>{ 'STRING', 'BOOLEAN', 'PICKLIST', 'DOUBLE' };
        for (String fieldName : fieldMapCM.keyset()){
            String fieldNamestr = String.valueOf(fieldMapCM.get(fieldName).getDescribe().getLabel());
            String fieldNameAPI = String.valueOf(fieldMapCM.get(fieldName));
            String fieldTypeName = fieldMapCM.get(fieldName).getDescribe().getType().name();
            if (availableTypeList.contains(fieldTypeName.toupperCase())){
                String fieldLabel = String.valueOf(fieldMapCM.get(fieldName).getDescribe().getLabel());
                fieldLabelListCM.add(fieldLabel);
                fieldListCM.add(fieldNamestr);
                fieldAPIListCM.add(fieldNameAPI);

                String fieldLength = String.valueOf(fieldMapCM.get(fieldName).getDescribe().getLength());
                if (fieldTypeName == 'DOUBLE'){
                    fieldTypeName = 'Number';
                    fieldLength = String.valueOf(fieldMapCM.get(fieldName).getDescribe().getPrecision());
                    String fieldDeciaml = String.valueOf(fieldMapCM.get(fieldName).getDescribe().getScale());
                    Integer fieldNum = Integer.valueOf(fieldLength) - Integer.valueOf(fieldDeciaml);
                    fieldLength = fieldNum + ', ' + fieldDeciaml;
                }
                if (fieldTypeName == 'BOOLEAN'){
                    fieldLength = '-';
                    fieldTypeName = 'Boolean';
                }
                if (fieldTypeName == 'STRING'){
                    fieldTypeName = 'Text';
                }
                if (fieldTypeName == 'PICKLIST'){
                    fieldTypeName = 'Picklist';
                }
                mapfieldwithTypeCM.put(fieldNameAPI, fieldTypeName);
                mapfieldwithLengthCM.put(fieldNameAPI, fieldLength);
                mapfieldwithAPICM.put(fieldNamestr, fieldNameAPI);
                mapAPICMwithFieldName.put(fieldNameAPI, fieldNamestr);
            }
        }
        mapobjectwithapiName.put('CampaignMember', fieldListCM);
        mapobjectwithApiType.put('CampaignMember', mapfieldwithTypeCM);
        mapobjectwithApiLength.put('CampaignMember', mapfieldwithLengthCM);
        mapobjectwithApiLength.put('CampaignMember', mapfieldwithLengthCM);
        mapobjectwithApiLabel.put('CampaignMember', mapfieldwithAPICM);
        mapobjectwithAPI.put('CampaignMember', mapAPICMwithFieldName);
        newCMwrapper.Label = fieldLabelListCM;
        newCMwrapper.API = fieldAPIListCM;
        mapAPIwrapper.put('CampaignMember', newCMwrapper);
        for (String fieldName : fieldMapLead.keyset()){
            String fieldNamestr = String.valueOf(fieldMapLead.get(fieldName).getDescribe().getLabel());
            String fieldNameAPI = String.valueOf(fieldMapLead.get(fieldName));
            String fieldTypeName = fieldMapLead.get(fieldName).getDescribe().getType().name();
            if (availableTypeList.contains(fieldTypeName.toupperCase())){
                String fieldLabel = String.valueOf(fieldMapLead.get(fieldName).getDescribe().getLabel());
                fieldListLead.add(fieldNamestr);
                fieldAPIListLead.add(fieldNameAPI);
                fieldLabelListLead.add(fieldLabel);
                String fieldLength = String.valueOf(fieldMapLead.get(fieldName).getDescribe().getLength());
                if (fieldTypeName == 'DOUBLE'){
                    fieldTypeName = 'Number';
                    fieldLength = String.valueOf(fieldMapLead.get(fieldName).getDescribe().getPrecision());
                    String fieldDeciaml = String.valueOf(fieldMapLead.get(fieldName).getDescribe().getScale());
                    Integer fieldNum = Integer.valueOf(fieldLength) - Integer.valueOf(fieldDeciaml);
                    fieldLength = fieldNum + ', ' + fieldDeciaml;
                }
                if (fieldTypeName == 'BOOLEAN'){
                    fieldLength = '-';
                    fieldTypeName = 'Boolean';
                } 
                if (fieldTypeName == 'STRING'){
                    fieldTypeName = 'Text';
                }
                if (fieldTypeName == 'PICKLIST'){
                    fieldTypeName = 'Picklist';
                }
                mapfieldwithTypeLead.put(fieldNameAPI, fieldTypeName);
                mapfieldwithLengthLead.put(fieldNameAPI, fieldLength);
                mapfieldwithAPILead.put(fieldNamestr, fieldNameAPI);
                mapAPILeadwithFieldName.put(fieldNameAPI, fieldNamestr);
            }

        }
        mapobjectwithapiName.put('Lead', fieldListLead);
        mapobjectwithApiType.put('Lead', mapfieldwithTypeLead);
        mapobjectwithApiLength.put('Lead', mapfieldwithLengthLead);
        mapobjectwithApiLabel.put('Lead', mapfieldwithAPILead);
        mapobjectwithAPI.put('Lead', mapAPILeadwithFieldName);
        newLeadwrapper.Label = fieldLabelListLead;
        newLeadwrapper.API = fieldAPIListLead;
        mapAPIwrapper.put('Lead', newLeadwrapper);

        // FieldDescribeWrapper.newMapAPiNameLabel = mapAPIwrapper;
        fieldwrapper.newMapAPiNameLabel = mapAPIwrapper;
        fieldwrapper.fieldList = mapobjectwithapiName;
        fieldwrapper.mapfieldNamewithtype = mapobjectwithApiType;
        fieldwrapper.mapfieldNamewithLength = mapobjectwithApiLength;
        fieldwrapper.mapfieldAPIwithLabel = mapobjectwithApiLabel;
        fieldwrapper.newAPiNameWithLabel = mapobjectwithAPI;
        return fieldwrapper;
    }

    public class conditionObject{
        @AuraEnabled
        public String LObject{ get; set; }
        @AuraEnabled
        public String FieldName{ get; set; }
        @AuraEnabled
        public String FieldType{ get; set; }
        @AuraEnabled
        public String Length{ get; set; }
        @AuraEnabled
        public String APIName{ get; set; }
        @AuraEnabled
        public Integer Weight{ get; set; }
        @AuraEnabled
        public String Id{ get; set; }
    }

    public class conditionDetailObject{
        @AuraEnabled
        public String Operator{ get; set; }
        @AuraEnabled
        public String Value1{ get; set; }
        @AuraEnabled
        public String Value2{ get; set; }
        @AuraEnabled
        public Integer Score{ get; set; }
        @AuraEnabled
        public String Id{ get; set; }
        @AuraEnabled
        public String inputrowIndex{ get; set; }
    }
    @AuraEnabled
    public static Id insertLeadScoring(Id recordId, String Name, Integer totalWeight, String description, Boolean isActive ){
        // System.debug(leadList);
        List<Lead_Scoring_List__c> currScoringRec = [SELECT Id, Total_Weight__c, IsActive__c, Description__c FROM Lead_Scoring_List__c WHERE Id =:recordId LIMIT 1];
        Lead_Scoring_List__c scoringList = new Lead_Scoring_List__c();
        id returnId = null;
        System.debug(currScoringRec);
        if(currScoringRec.size() > 0){
            System.debug('Update existing record');
            currScoringRec[0].Total_Weight__c = totalWeight;
            currScoringRec[0].Description__c = description;
            currScoringRec[0].IsActive__c = isActive;
            currScoringRec[0].Name = Name;
            update currScoringRec;

            returnId = recordId;
        }else{
            System.debug('Insert record');
            scoringList.Total_Weight__c = totalWeight;
            scoringList.Description__c = description;
            scoringList.IsActive__c = isActive;
            scoringList.Name = Name;
            
            insert scoringList;
            
            returnId = scoringList.Id;
        }
        return returnId;
    }

    @AuraEnabled
    public static void insertScoringCon(Id recordId, List<conditionObject> LeadList){
        try {
            List<Lead_Scoring_Condition__c> leadConList = new List<Lead_Scoring_Condition__c>();
            List<String> curId = new List<String>();
            System.debug('LeadList --> '+LeadList);
            for(conditionObject ll : leadList){
                curId.add(ll.id);
                if(ll.APIName != '' && ll.APIName != null){
                    Lead_Scoring_Condition__c leadCon = new Lead_Scoring_Condition__c();
                    if(ll.Id != null && ll.Id != ''){
                        System.debug('Upsert : '+ ll.Id);
                        leadCon.Id = ll.Id;
                    }else{
                        leadCon.Lead_Scoring_List__c = recordId;
                        // List<Lead_Scoring_Condition_Detail__c> leadConDetailList = new List<Lead_Scoring_Condition_Detail__c>();
                        // List<App_Config__mdt> score = [SELECT Id, DeveloperName, MasterLabel, Label, Value__c FROM App_Config__mdt WHERE DeveloperName IN ('LGS_Is_null_Defaul_Score','LGS_Not_match_Defaul_Score') LIMIT 1];
                        // Lead_Scoring_Condition_Detail__c leadConDetail998 = new Lead_Scoring_Condition_Detail__c();
                        // Lead_Scoring_Condition_Detail__c leadConDetail999 = new Lead_Scoring_Condition_Detail__c();
                        // leadConDetail998.Value1__c = 'Is null'; 
                        // leadConDetail998.Priority__c = 998;
                        // leadConDetail998.Operation__c = '=';
                        // leadConDetail998.Lead_Scoring_Condition__c = ll.id;
                        // for(App_Config__mdt ac : score){
                        //     if(ac.DeveloperName == 'LGS_Is_null_Defaul_Score'){
                        //         leadConDetail998.Score__c = Decimal.valueOf(ac.Value__c);
                        //     }     
                        // }
                        // leadConDetail999.Value1__c = 'Not match'; 
                        // leadConDetail999.Priority__c = 999;
                        // leadConDetail999.Operation__c = '=';
                        // leadConDetail999.Lead_Scoring_Condition__c = ll.id;
                        // for(App_Config__mdt ac : score){
                        //     if(ac.DeveloperName == 'LGS_Not_match_Defaul_Score'){
                        //         leadConDetail999.Score__c = Decimal.valueOf(ac.Value__c);
                        //     }     
                        // }
                        // leadConDetailList.add(leadConDetail999);
                        // insert leadConDetailList;
                    }
                    leadCon.Field_Mapping__c = ll.APIName;
                    leadCon.Object__c = ll.LObject;
                    leadCon.Weight__c = ll.Weight;
                    leadConList.add(leadCon);
                }
            }
            List<Lead_Scoring_Condition__c> recordsToDelete = [SELECT Id FROM Lead_Scoring_Condition__c WHERE Id NOT IN :curId AND Lead_Scoring_List__c =: recordId];
            List<String> LSCiD = new List<String>();
            for(Lead_Scoring_Condition__c lsc : recordsToDelete){
                LSCiD.add(lsc.Id);
            }
            List<Lead_Scoring_Condition_Detail__c> lscdToDelete = [SELECT Id FROM Lead_Scoring_Condition_Detail__c WHERE Lead_Scoring_Condition__c IN :LSCiD];
            if(lscdToDelete.size()>0){
                delete lscdToDelete;
            } 
            delete recordsToDelete;
            System.debug(leadConList);
            upsert leadConList;
            // List<Lead_Scoring_Condition__c> addScoringCon = [SELECT Id FROM Lead_Scoring_Condition__c WHERE ]
            System.debug(leadConList);

        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString() + e.getLineNumber());

            throw new AuraHandledException('Text');
        }
    }

    @AuraEnabled
    public static void insertScoringConDetail(Id recordId, List<conditionDetailObject> detailList){
        try {
            List<Lead_Scoring_Condition_Detail__c> leadConDetailList = new List<Lead_Scoring_Condition_Detail__c>();
            List<String> curId = new List<String>();
            System.debug('detailList : '+ detailList);
            for(conditionDetailObject ll : detailList){
                curId.add(ll.id);
                if(ll.inputrowIndex != '' && ll.inputrowIndex != null){
                    Lead_Scoring_Condition_Detail__c leadConDetail = new Lead_Scoring_Condition_Detail__c();
                    if(ll.Id != null && ll.Id != ''){
                        System.debug('Upsert : '+ ll.Id);

                        leadConDetail.Id = ll.Id;
                    }else{
                        leadConDetail.Lead_Scoring_Condition__c = recordId;
                    }
                    leadConDetail.Score__c = ll.Score;
                    leadConDetail.Priority__c = Decimal.valueOf(ll.inputrowIndex);
                    leadConDetail.Operation__c = ll.Operator;
                    leadConDetail.Value1__c = ll.Value1;
                    leadConDetail.Value2__c = ll.Value2;
                    leadConDetailList.add(leadConDetail);
                }
            }
            List<Lead_Scoring_Condition_Detail__c> recordsToDelete = [SELECT Id FROM Lead_Scoring_Condition_Detail__c WHERE Id NOT IN :curId AND Lead_Scoring_Condition__c =: recordId];
            delete recordsToDelete;
            System.debug(leadConDetailList);
            upsert leadConDetailList;
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString() + e.getLineNumber());

            throw new AuraHandledException('Text');
        }
    }
}