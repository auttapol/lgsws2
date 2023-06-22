public with sharing class RTL_NBOHistoryDetailProxyCtrl {
    public RTL_NBO_History__c nboHistory;
    public RTL_NBOHistoryDetailProxyCtrl(ApexPages.StandardController std){
        nboHistory = (RTL_NBO_History__c)std.getRecord();
        nboHistory = [SELECT ID,RTL_NBO_Id__c FROM RTL_NBO_History__c WHERE ID=:nboHistory.id];
    }
    public PageReference redirectPage(){
        return new PageReference('/apex/RTL_NBOHistoryDetailView?p='+nboHistory.RTL_NBO_Id__c);
    }    
}