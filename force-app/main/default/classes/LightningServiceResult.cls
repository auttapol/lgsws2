public with sharing class LightningServiceResult {
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String errorMessage {get;set;}
    @AuraEnabled public Object data {get;set;}
    @AuraEnabled public Map<String, Object>  dataMap {get;set;}
    @AuraEnabled public DateTime executeDateTime {get;set;}
}