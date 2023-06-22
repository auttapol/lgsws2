public class EditableLongTermLoan extends EditableList {
    public Boolean isExisting {get;set;}
    public Boolean isCapital  {get;set;}
    public String WalletID {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public EditableLongTermLoan(ApexPages.StandardController stdController) {
        super(stdController);
        
        String typelongTermLoan = ApexPages.currentPage().getParameters().get('type');
        String CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        
        if(CompanyID !=null && CompanyID != ''){
            companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
        }
        
        isExisting = false;
        isCapital = false;
        if(typelongTermLoan=='Existing'){
            isExisting = true;
        }else{
            isCapital = true;
        }
       
        if(isExisting){
            this.childList = [SELECT Id,Bank__c,BankName__c, CCY__c,CCYName__c, Collateral__c, EquivalentAmount__c, 
                              InterestFixedRate__c, InterestType__c, LTVPercent__c, NimcPercent__c, RemainingTenorsYear__c,
                              Remark__c, TypeOfLoan__c,WalletNiicYearly__c,InterestFloatingRate__c,AcctPlanWallet__c,CollateralDetail__c
                              FROM AcctPlanExistingLongTermLoan__c 
                              WHERE AcctPlanWallet__c = :WalletID];
        }else if(isCapital){
            this.childList = [SELECT Id,Purpose__c,ProjectAmount__c,InvestmentLocation__c,FinancingRation__c,
                              TenorYearly__c,NimcPercent__c,WalletNiicYearly__c,FrontEndFee__c,CreditFee__c,
                              AcctPlanWallet__c
                              FROM AcctPlanCapitalExpenditurePlan__c  
                              WHERE AcctPlanWallet__c = :WalletID];
        }
    } 

    public List<AcctPlanExistingLongTermLoan__c> getChildrenLongTermLoan()
    {
        return (List<AcctPlanExistingLongTermLoan__c>)childList;
    }
    public List<AcctPlanCapitalExpenditurePlan__c> getChildrenExpenditure()
    {
        return (List<AcctPlanCapitalExpenditurePlan__c>)childList;
    }
    
    public override sObject initChildRecord()
    {
        if(isExisting){
            AcctPlanExistingLongTermLoan__c   child = new AcctPlanExistingLongTermLoan__c  ();
            child.AcctPlanWallet__c = mysObject.Id;
            return child;
        }else if(isCapital){
            AcctPlanCapitalExpenditurePlan__c   child = new AcctPlanCapitalExpenditurePlan__c  ();
            child.AcctPlanWallet__c = mysObject.Id;
            return child;
        }
        return null;
    }
    
    
    public void insertRecord(){
        try{
            Boolean validateFloat = true;
            Boolean validateFixed = true;
            Boolean validateBank = true;
            Boolean validateCCY = true;
            String errorMessage = '';
            if(isExisting){
                for(AcctPlanExistingLongTermLoan__c item : (List<AcctPlanExistingLongTermLoan__c>)childList){               
                    /*if(item.InterestType__c == 'Floating rate' && item.InterestFloatingRate__c == null){
                        validateFloat = false;
                    }else if(item.InterestType__c == 'Fixed rate' && item.InterestFixedRate__c == null){
                        validateFixed = false; 
                    }*/
                    if(item.Bank__c == null){
                        validateBank = false;                    
                    }
                    if(item.CCY__c == null){
                        validateCCY = false;                    
                    }
                }
            }
            if(!validateBank){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Bank is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3023').Status_Message__c));
        

            }
            if(!validateCCY){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'CCY is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3024').Status_Message__c));
        
            }
            /*if(!validateFloat){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Interest Rate for Floating is required'));
            }
            if(!validateFixed){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Interest Rate for Fixed is required'));
            }*/
            if(validateBank && validateCCY && validateFloat && validateFixed){
                Double SumOfExistingLongTermLoan = 0;
                Double SumofExistingLongTermLoanNIIC =0;   
                
                Double SumOfCapitalExpenditurePlanProjectAmt = 0;
                Double SumOfCapitalExpenditurePlanCreditFee = 0;      
                Double SumOfCapitalExpenditurePlanNIIC = 0;
                Double SumOfWalletNiicLongTermLoan = 0;
                Double SumOfWalletNiicYearly = 0;
                Double SumOfWalletCreditFeeYearly = 0;
                
                if(isExisting){
                    for(AcctPlanExistingLongTermLoan__c item : (List<AcctPlanExistingLongTermLoan__c>)childList){
                        item.AcctPlanWallet__c = WalletID;
                        if(item.EquivalentAmount__c == null){
                            item.EquivalentAmount__c = 0;
                        } 
                        if(item.NimcPercent__c == null){
                            item.NimcPercent__c =0;
                        }
                        if(item.InterestType__c == 'Floating rate'){
                            item.InterestFixedRate__c = null;
                        }else if (item.InterestType__c == 'Fixed rate'){
                            item.InterestFloatingRate__c = null;
                        }   
                        item.Opportunity__c = 'Forward/Derivative/ Option';
                        if(item.RemainingTenorsYear__c <1){
                            item.WalletNiicYearly__c = item.RemainingTenorsYear__c * item.EquivalentAmount__c * (item.NimcPercent__c/100);
                        }else{
                            item.WalletNiicYearly__c = item.EquivalentAmount__c * (item.NimcPercent__c/100);
                        }
                        
                        SumOfExistingLongTermLoan += item.EquivalentAmount__c;
                        SumofExistingLongTermLoanNIIC += item.WalletNiicYearly__c;                  
                    }    
                    
                }else if(isCapital){
                    for(AcctPlanCapitalExpenditurePlan__c item : (List<AcctPlanCapitalExpenditurePlan__c>)childList){
                        item.AcctPlanWallet__c = WalletID;
                        if(item.ProjectAmount__c == null){
                            item.ProjectAmount__c = 0;
                        }
                        if(item.FinancingRation__c == null){
                            item.FinancingRation__c =0;
                        }
                        if(item.FrontEndFee__c == null){
                            item.FrontEndFee__c = 0;
                        }
                        if(item.NimcPercent__c == null){
                            item.NimcPercent__c = 0;
                        }
                        item.Opportunity__c = 'Derivative or IB';
                        SumOfCapitalExpenditurePlanProjectAmt += item.ProjectAmount__c;
                        item.CreditFee__c = Integer.valueof(item.ProjectAmount__c * item.FinancingRation__c/100 * item.FrontEndFee__c/100);
                        item.WalletNiicYearly__c = Integer.valueof(item.ProjectAmount__c * item.FinancingRation__c/100 * item.NimcPercent__c/100);
                        //SumOfCapitalExpenditurePlanCreditFee += item.ProjectAmount__c * item.FinancingRation__c * item.FrontEndFee__c;
                        //SumOfCapitalExpenditurePlanNIIC += item.ProjectAmount__c * item.FinancingRation__c * item.NimcPercent__c;
                        
                        SumOfCapitalExpenditurePlanCreditFee += item.CreditFee__c;
                        SumOfCapitalExpenditurePlanNIIC += item.WalletNiicYearly__c;
                        
                    } 
                    
                }
                List<AcctPlanWallet__c> acctplanwalletLists = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
                AcctPlanWallet__c wallet;
                if(acctplanwalletLists.size() > 0){
                    wallet = acctplanwalletLists.get(0);
                    wallet.Id = WalletID;
                    if(isExisting){
                        wallet.SumOfExistingLongTermLoan__c = SumOfExistingLongTermLoan;
                        wallet.SumofExistingLongTermLoanNIIC__c = SumofExistingLongTermLoanNIIC;
                        upsert wallet;
                    }else if(isCapital){
                        if(wallet.SumofExistingLongTermLoanNIIC__c == null){
                            wallet.SumofExistingLongTermLoanNIIC__c =0;
                        }
                        if(wallet.TotalWalletNiic__c== null){
                            wallet.TotalWalletNiic__c =0;
                        }
                        if(wallet.MaxCreditFeeWorkingCapital__c == null){
                            wallet.MaxCreditFeeWorkingCapital__c =0;
                        }

                        wallet.SumOfCapitalExpenditurePlanProjectAmt__c = SumOfCapitalExpenditurePlanProjectAmt;
                        wallet.SumOfCapitalExpenditurePlanCreditFee__c = SumOfCapitalExpenditurePlanCreditFee;      
                        wallet.SumOfCapitalExpenditurePlanNIIC__c = SumOfCapitalExpenditurePlanNIIC;
                        
                        SumOfWalletNiicLongTermLoan =  wallet.SumofExistingLongTermLoanNIIC__c + SumOfCapitalExpenditurePlanNIIC;
                        SumOfWalletNiicYearly = wallet.TotalWalletNiic__c + SumOfWalletNiicLongTermLoan;
                        SumOfWalletCreditFeeYearly = wallet.MaxCreditFeeWorkingCapital__c + SumOfCapitalExpenditurePlanCreditFee; 
                        
                        wallet.SumOfWalletNiicLongTermLoan__c = SumOfWalletNiicLongTermLoan;
                        wallet.SumOfWalletNiicYearly__c = SumOfWalletNiicYearly;
                        wallet.SumOfWalletCreditFeeYearly__c = SumOfWalletCreditFeeYearly;
                        
                        upsert wallet;
                    }
                }
                super.save();
                
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
         
            }else{
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,errorMessage));
            }
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Save error : '+e.getMessage()));
        }
    }
    //select option bank
    public List<SelectOption> getBanks(){
        List<SelectOption> shareBanksOption = new List<SelectOption>();
        List<Bank__c> bankListitem = [SELECT Id,Name FROM Bank__c];
        shareBanksOption.add(new SelectOption('','--none--'));
        Id othersId;
        String othersName;
        for(Bank__c b : bankListitem){
            if(b.Name == 'Others'){
                othersId = b.Id;
                othersName = b.Name;
            }else{
                shareBanksOption.add(new SelectOption(b.Id,b.Name));
            }
        }
        shareBanksOption.add(new SelectOption(othersId,othersName));
        return shareBanksOption;   
    }
    //select option currency
    public List<SelectOption> getCurrency(){
        List<SelectOption> currencyOption = new List<SelectOption>();
        List<Currency__c> currencyListitem = [SELECT Id,Name FROM Currency__c WHERE FlagForAcctPlan__c = TRUE];
        currencyOption.add(new SelectOption('','--none--'));
        for(Currency__c c : currencyListitem){
            currencyOption.add(new SelectOption(c.Id,c.Name));
        }         
        return currencyOption;
    }

}