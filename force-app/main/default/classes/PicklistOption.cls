global with sharing class PicklistOption {
    //Tinnakrit
    @AuraEnabled
    global String value{get;set;}

    @AuraEnabled
    global String label{get;set;}

    global PicklistOption(String value, String label){
        this.value = value;
        this.label = label;
    }
}