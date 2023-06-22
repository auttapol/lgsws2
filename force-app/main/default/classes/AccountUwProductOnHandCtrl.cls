public class AccountUwProductOnHandCtrl{

    public decimal recPerPage = 10;
    public string accId {get;set;}
    // Transactional Banking Section
    public integer totalTransPage {get;set;}
    public integer currentTransPage {get;set;}
    public integer startTransOffset {get;set;}
    public List<Product_Information_Detail__c> listTransProduct {get;set;}

    // Deposit & Investment Section
    public integer totalDepositPage {get;set;}
    public integer currentDepositPage {get;set;}
    public integer startDepositOffset {get;set;}
    public List<Product_Information_Detail__c> listDepositProduct {get;set;}

    // Funding & Borrowing Section
    public integer totalFundPage {get;set;}
    public integer currentFundPage {get;set;}
    public integer startFundOffset {get;set;}
    public List<Product_Information_Detail__c> listFundProduct {get;set;}

    // Risk Protection Section
    public integer totalRiskPage {get;set;}
    public integer currentRiskPage {get;set;}
    public integer startRiskOffset {get;set;}
    public List<Product_Information_On_Hand__c> listRiskProduct {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AccountUwProductOnHandCtrl(ApexPages.StandardController stdController) {
        Account acc = (Account)stdController.getRecord();
        accId = acc.Id;

        // Find the total Transactional records.
        integer totalTransRec = [Select count() 
                                 From Product_Information_Detail__c 
                                 Where Customer__c =: accId 
                                 And Product_Domain__c Like '%Transactional%'];
        totalTransPage = integer.valueof((totalTransRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug('Total Transactional page: ' + totalTransPage);
        totalTransPage = (totalTransPage < 1) ? 1 : totalTransPage;
        currentTransPage = 1;
        startTransOffset = 0;
        // Query for Transactional detail.
        queryTransProductDetail();

        // Find the total Deposit records.
        integer totalDepositRec = [Select count() 
                                   From Product_Information_Detail__c 
                                   Where Customer__c =: accId 
                                   And Product_Domain__c Like '%Deposit%'];
        totalDepositPage = integer.valueof((totalDepositRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug('Total Deposit page: ' + totalDepositPage);
        totalDepositPage = (totalDepositPage < 1) ? 1 : totalDepositPage;
        currentDepositPage = 1;
        startDepositOffset = 0;
        // Query for Deposit detail.
        queryDepositProductDetail();

        // Find the total Funding records.
        integer totalFundRec = [Select count() 
                                From Product_Information_Detail__c 
                                Where Customer__c =: accId 
                                And Product_Domain__c Like '%Funding%'];
        totalFundPage = integer.valueof((totalFundRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug('Total Funding page: ' + totalFundPage);
        totalFundPage = (totalFundPage < 1) ? 1 : totalFundPage;
        currentFundPage = 1;
        startFundOffset = 0;
        // Query for Funding detail.
        queryFundProductDetail();

        // Find the total Risk records.
        integer totalRiskRec = [Select count() 
                                From Product_Information_On_Hand__c 
                                Where Account__c =: accId 
                                And Product_Domain__c Like '%Risk%'];
        totalRiskPage = integer.valueof((totalRiskRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug('Total Risk page: ' + totalRiskPage);
        totalRiskPage = (totalRiskPage < 1) ? 1 : totalRiskPage;
        currentRiskPage = 1;
        startRiskOffset = 0;
        // Query for Transactional detail.
        queryRiskProductDetail();
    }

    //======================================Transactional Banking======================================
    public void nextTransPage()
    {
        currentTransPage = (currentTransPage != totalTransPage) ? (currentTransPage+1) : totalTransPage;
        startTransOffset = (currentTransPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryTransProductDetail();
    }
    
    public void previousTransPage()
    {
        currentTransPage = (currentTransPage != 1) ? (currentTransPage-1) : 1;
        startTransOffset = (currentTransPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryTransProductDetail();
    }

    public void queryTransProductDetail(){
        listTransProduct = [Select  Id
                                    ,TMB_Account_ID__c
                                    ,Account_Name__c
                                    ,TMB_Suffix__c
                                    ,TMB_Ref__c
                                    ,Product_Performance_Name__c
                                    ,Product_Description__c
                                    ,Limit_Balance__c
                                    ,Ending_out_Ending_Balance__c
                                    ,Avg_out__c
                                    ,Issue_Date__c
                                    ,Maturity_Date__c
                             From Product_Information_Detail__c 
                             Where Customer__c =: accId 
                             And Product_Domain__c Like '%Transactional%'
                             Order By LastModifiedDate DESC
                             Limit: integer.valueof(recPerPage) offset: startTransOffset];
    }
    //======================================Transactional Banking======================================

    //======================================Deposit & Investment=======================================
    public void nextDepositPage()
    {
        currentDepositPage = (currentDepositPage != totalDepositPage) ? (currentDepositPage+1) : totalDepositPage;
        startDepositOffset = (currentDepositPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryDepositProductDetail();
    }
    
    public void previousDepositPage()
    {
        currentDepositPage = (currentDepositPage != 1) ? (currentDepositPage-1) : 1;
        startDepositOffset = (currentDepositPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryDepositProductDetail();
    }

    public void queryDepositProductDetail(){
        listDepositProduct = [Select  Id
                                    ,TMB_Account_ID__c
                                    ,Account_Name__c
                                    ,TMB_Suffix__c
                                    ,TMB_Ref__c
                                    ,Product_Performance_Name__c
                                    ,Product_Description__c
                                    ,Ending_out_Ending_Balance__c
                                    ,Avg_out__c
                                    ,Issue_Date__c
                                    ,Maturity_Date__c
                                    ,Rate__c
                             From Product_Information_Detail__c 
                             Where Customer__c =: accId 
                             And Product_Domain__c Like '%Deposit%'
                             Order By LastModifiedDate DESC
                             Limit: integer.valueof(recPerPage) offset: startDepositOffset];
    }
    //======================================Deposit & Investment=======================================

    //======================================Funding & Borrowing========================================
    public void nextFundPage()
    {
        currentFundPage = (currentFundPage != totalFundPage) ? (currentFundPage+1) : totalFundPage;
        startFundOffset = (currentFundPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryFundProductDetail();
    }
    
    public void previousFundPage()
    {
        currentFundPage = (currentFundPage != 1) ? (currentFundPage-1) : 1;
        startFundOffset = (currentFundPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryFundProductDetail();
    }

    public void queryFundProductDetail(){
        listFundProduct = [Select  Id
                                    ,TMB_Account_ID__c
                                    ,Account_Name__c
                                    ,TMB_Suffix__c
                                    ,TMB_Ref__c
                                    ,Product_Performance_Name__c
                                    ,Product_Description__c
                                    ,Limit_Balance__c
                                    ,Ending_out_Ending_Balance__c
                                    ,Avg_out__c
                                    ,Issue_Date__c
                                    ,Maturity_Date__c
                                    ,DPD_Date__c
                                    ,Loan_Status__c
                             From Product_Information_Detail__c 
                             Where Customer__c =: accId 
                             And Product_Domain__c Like '%Funding%'
                             Order By LastModifiedDate DESC
                             Limit: integer.valueof(recPerPage) offset: startFundOffset];
    }
    //======================================Funding & Borrowing========================================

    //=========================================Risk Protection=========================================
    public void nextRiskPage()
    {
        currentRiskPage = (currentRiskPage != totalRiskPage) ? (currentRiskPage+1) : totalRiskPage;
        startRiskOffset = (currentRiskPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryRiskProductDetail();
    }
    
    public void previousRiskPage()
    {
        currentRiskPage = (currentRiskPage != 1) ? (currentRiskPage-1) : 1;
        startRiskOffset = (currentRiskPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryRiskProductDetail();
    }

    public void queryRiskProductDetail(){
        listRiskProduct = [Select  Id
                                   ,Product_Description__c
                                   ,Product_Family__c
                                   ,Product_Hierachy_Code__c
                                   ,Product_Hierachy_Code__r.Name
                                   ,No_of_Account__c
                                   ,Limit_Balance__c
                            From Product_Information_On_Hand__c 
                            Where Account__c =: accId 
                            And Product_Domain__c Like '%Risk%'
                            Order By LastModifiedDate DESC
                            Limit: integer.valueof(recPerPage) offset: startRiskOffset];
    }
    //=========================================Risk Protection=========================================
}