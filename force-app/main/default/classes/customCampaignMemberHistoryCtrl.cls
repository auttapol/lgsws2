public with sharing class customCampaignMemberHistoryCtrl {

    public class HistoryWrapper{

        @AuraEnabled
        public DateTime modifiedDate {get;set;}
        @AuraEnabled
        public String modifiedBy{get;set;}
        @AuraEnabled
        public String modifiedById{get;set;}
        @AuraEnabled
        public String oldValue{get;set;}
        @AuraEnabled
        public String newValue{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}

        public HistoryWrapper(RTL_Campaign_Member_History_detail__c cmhd){
            this.modifiedDate = cmhd.RTL_Campaign_Member_History__r.RTL_Date__c;
            this.modifiedBy = cmhd.RTL_Campaign_Member_History__r.RTL_Modified_By__r.Name;
            this.modifiedById = cmhd.RTL_Campaign_Member_History__r.RTL_Modified_By__r.Id;
            this.oldValue = cmhd.RTL_Field_Old_Value__c;
            this.newValue = cmhd.RTL_Field_New_Value__c;
            this.fieldLabel = getLabel(cmhd.RTL_Field_Name__c);
        }

        private String getLabel(String fieldName){
            String label = '';
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('CampaignMember').getDescribe();
            DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
            label =  fieldResult.getLabel();

            return label;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<HistoryWrapper> getHistoryDetails(String recordId){
        
        List<HistoryWrapper> wrapperList = new List<HistoryWrapper>();
        List<RTL_Campaign_Member_History_detail__c> returnList = [
            SELECT Id, RTL_Campaign_Member_History__r.RTL_Date__c, RTL_Field_Name__c,
                    RTL_Campaign_Member_History__r.RTL_Modified_By__r.Name, RTL_Field_Old_Value__c, RTL_Field_New_Value__c
            FROM RTL_Campaign_Member_History_detail__c
            WHERE RTL_Campaign_Member_History__r.RTL_Campaign_Member_ID__c = :recordId ORDER BY RTL_Campaign_Member_History__r.RTL_Date__c DESC];

        if(!returnList.isEmpty()){
            for(RTL_Campaign_Member_History_detail__c cmhd : returnList){
                wrapperList.add(new HistoryWrapper(cmhd));
            }
        }

        System.debug('wrapperList'+ wrapperList);
        return wrapperList;

    }

    @AuraEnabled
    public static List<HistoryWrapper> getHistoryDetailsWithLimit(String recordId, Integer numOfElement){

        List<HistoryWrapper> wrapperList = new List<HistoryWrapper>();
        List<RTL_Campaign_Member_History_detail__c> returnList = [
            SELECT Id, RTL_Campaign_Member_History__r.RTL_Date__c, RTL_Field_Name__c,
                    RTL_Campaign_Member_History__r.RTL_Modified_By__r.Name, RTL_Field_Old_Value__c, RTL_Field_New_Value__c
            FROM RTL_Campaign_Member_History_detail__c
            WHERE RTL_Campaign_Member_History__r.RTL_Campaign_Member_ID__c = :recordId
            ORDER BY RTL_Campaign_Member_History__r.RTL_Date__c DESC
            LIMIT :numOfElement];

        if(!returnList.isEmpty()){
            for(RTL_Campaign_Member_History_detail__c cmhd : returnList){
                wrapperList.add(new HistoryWrapper(cmhd));
            }
        }
        System.debug('wrapperList2'+ wrapperList);
        return wrapperList;

    }

}