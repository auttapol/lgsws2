public with sharing class fnaQRcodeCSVCtrl {
    public string urlForQRcode      {get;set;}

    public fnaQRcodeCSVCtrl() {
        String customerId = ApexPages.currentpage().getparameters().get('customerId');
        String branchAgentId = ApexPages.currentpage().getparameters().get('branchAgentId');
        String branchCode = ApexPages.currentpage().getparameters().get('branchCode');
        
        List<App_Config__mdt> FnaURL = [SELECT Id, Label, Value__c, DeveloperName FROM App_Config__mdt Where DeveloperName = 'FNA_Community_Url'];
        String site = '';
        if(FnaURL.size() > 0){
            site = FnaURL[0].Value__c;
        }
        


        urlForQRcode = site + '/s/?cusId=' + customerId + '&branchCode=' + branchCode + '&branchAgentId=' + branchAgentId;
    }
}