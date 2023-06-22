public with sharing class AccountUwCollateralCtrl {

    public decimal recPerPage = 10;
    public string accId {get;set;}
    // Collatactional Banking Section
    public integer totalCollatPage {get;set;}
    public integer currentCollatPage {get;set;}
    public integer startCollatOffset {get;set;}
    public List<Collateral_Detail__c> listCollateralDetail {get;set;}

    public AccountUwCollateralCtrl(ApexPages.StandardController stdController) {
        Account acc = (Account)stdController.getRecord();
        accId = acc.Id;

        // Find the total Collatactional records.
        integer totalCollatRec = [Select count() 
                                 From Collateral_Detail__c 
                                 Where Collateral__r.Account__c =: accId];
        totalCollatPage = integer.valueof((totalCollatRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug('Total Collateral Detail page: ' + totalCollatPage);
        totalCollatPage = (totalCollatPage < 1) ? 1 : totalCollatPage;
        currentCollatPage = 1;
        startCollatOffset = 0;
        // Query for Collatactional detail.
        queryCollateralDetail();
    }

    public void nextCollatPage()
    {
        currentCollatPage = (currentCollatPage != totalCollatPage) ? (currentCollatPage+1) : totalCollatPage;
        startCollatOffset = (currentCollatPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryCollateralDetail();
    }
    
    public void previousCollatPage()
    {
        currentCollatPage = (currentCollatPage != 1) ? (currentCollatPage-1) : 1;
        startCollatOffset = (currentCollatPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryCollateralDetail();
    }

    public void queryCollateralDetail(){
        listCollateralDetail = [Select  Id
                                        ,Collateral__c
                                        ,Collateral__r.Name
                                        ,Collateral_No__c
                                        ,Collateral_Code__c
                                        ,Collateral_Type__c
                                        ,Reference__c
                                        ,Pledge_Value__c
                                        ,Appraisal_Value__c
                                        ,Appraisal_Date__c
                                        ,Collateral_Owner__c
                                        ,Collateral_Joint__c
                                        ,Collateral_Joint_BOT__c
                                        ,Data_As_of__c
                                From Collateral_Detail__c 
                                Where Collateral__r.Account__c =: accId 
                                Order By LastModifiedDate DESC
                                Limit: integer.valueof(recPerPage) offset: startCollatOffset];
    }
}