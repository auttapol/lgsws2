global with sharing class SmartBDM_PicklistOption {
    //Tinnakrit
    @AuraEnabled
    global String value{get;set;}

    @AuraEnabled
    global String label{get;set;}

    global SmartBDM_PicklistOption(String value, String label){
        this.value = value;
        this.label = label;
    }
}