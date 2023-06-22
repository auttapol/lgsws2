public class EditableCreditFacility extends EditableList {   
    public Boolean isInternationalType {get;set;}
    public String credittype {get;set;}
    public Boolean isOthersType {get;set;}
    public String WalletID {get;set;}
    public EditableCreditFacility(ApexPages.StandardController stdController) {
        super(stdController);
        String typeCreditFacility = ApexPages.currentPage().getParameters().get('type');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        
        isInternationalType = true;
        if(typeCreditFacility != 'International'){
            isInternationalType = false;
        }  
        if(isInternationalType){
            
            this.childList = [SELECT Id,Bank__c, Bank__r.Name, Collateral__c , CreditType__c, LimitAmount__c, LTV__c, 
                              OtherCreditType__c, Outstanding__c, Segment__c,Type__c,AcctPlanWallet__c, CollateralDetail__c
                              FROM AcctPlanWalletCreditFacility__c 
                              WHERE AcctPlanWallet__c = :WalletID
                              AND (Segment__c = 'ImportTransaction' OR Segment__c = 'ExportTransaction')
                             ];
        }else if(!isInternationalType){
            this.childList = [SELECT Id,Bank__c, Bank__r.Name, Collateral__c , CreditType__c, LimitAmount__c, LTV__c, 
                              OtherCreditType__c, Outstanding__c, Segment__c,Type__c,AcctPlanWallet__c, CollateralDetail__c
                              FROM AcctPlanWalletCreditFacility__c 
                              WHERE AcctPlanWallet__c = :WalletID
                              AND Segment__c = 'Domestic'
                             ];
        }        
    }
    
    public List<AcctPlanWalletCreditFacility__c> getChildren(){
        return (List<AcctPlanWalletCreditFacility__c>)childList;
    }
    
    public override sObject initChildRecord()
    {
        AcctPlanWalletCreditFacility__c child = new AcctPlanWalletCreditFacility__c();
        // Can either use mysObject or acct here
        child.AcctPlanWallet__c = mysObject.Id;
        if(isInternationalType){       
            child.Type__c = 'International';
        }else if(!isInternationalType){
            child.Type__c = 'Domestic';
            child.Segment__c = 'Domestic';
        }
        return child;
    }
    
    public void checkunique(){
        try{  
            Boolean validateOther = true;
            Boolean validateBank = true;
            String errorMessage = ''; 
            for(AcctPlanWalletCreditFacility__c item : (List<AcctPlanWalletCreditFacility__c>) childList){             
                if(item.CreditType__c == 'Others' && item.OtherCreditType__c == null){
                    validateOther = false;                    
                }
                if(item.Bank__c == null){
                    validateBank = false;                    
                }
            }
            if(!validateOther){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Credit Other Types is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3022').Status_Message__c));
        
            }
            if(!validateBank){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Bank is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3023').Status_Message__c));
        
            }
            if(validateOther && validateBank){
                Double SumOfCreditFacilityLimit = 0;
                Double SumOfCreditFacilityOutstanding =0;
                Double SumOfCreditFacilityLimitInter =0;
                Double SumOfCreditFacilityOutstandingInter =0;
                Double SumOfExportTransactionLimit =0;
                Double SumOfExportTransactionOutStanding =0;
                
                for(AcctPlanWalletCreditFacility__c item : (List<AcctPlanWalletCreditFacility__c>) childList){ 
                    item.AcctPlanWallet__c = WalletID;
                    if(item.LimitAmount__c == null){
                        item.LimitAmount__c = 0;
                    }
                    if(item.Outstanding__c == null){
                        item.Outstanding__c = 0;
                    }
                    if(item.CreditType__c != 'Others'){
                        item.OtherCreditType__c = null;
                    }
                    if(isInternationalType){
                        if(item.Segment__c == 'ImportTransaction'){
                            SumOfCreditFacilityLimitInter += item.LimitAmount__c;
                            SumOfCreditFacilityOutstandingInter += item.Outstanding__c;
                        }else if(item.Segment__c == 'ExportTransaction'){
                            SumOfExportTransactionLimit += item.LimitAmount__c;
                            SumOfExportTransactionOutStanding += item.Outstanding__c;
                        }            
                    }else if(!isInternationalType){
                        SumOfCreditFacilityLimit += item.LimitAmount__c;
                        SumOfCreditFacilityOutstanding += item.Outstanding__c;
                    }
                }
                AcctPlanWallet__c wallet = (AcctPlanWallet__c) mysObject;
                wallet.Id = WalletID;
                if(isInternationalType){
                    wallet.SumOfCreditFacilityLimitInter__c = SumOfCreditFacilityLimitInter;
                    wallet.SumOfCreditFacilityOutstandingInter__c = SumOfCreditFacilityOutstandingInter;
                    wallet.SumOfExportTransactionLimit__c = SumOfExportTransactionLimit;
                    wallet.SumOfExportTransactionOutStanding__c = SumOfExportTransactionOutStanding;
                }else if(!isInternationalType){
                    wallet.SumOfCreditFacilityLimit__c = SumOfCreditFacilityLimit;
                    wallet.SumOfCreditFacilityOutstanding__c = SumOfCreditFacilityOutstanding;
                }
                upsert wallet;
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

}