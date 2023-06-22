public without sharing class AccountPlanWalletDomainIICtrl {
    public String WalletID {get;set;}
    public String CompanyID {get;set;}
    public String GroupID {get;set;}  
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public boolean isHasPermission {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isSystemAdmin {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public AcctPlanWallet__c acctplanwallet {get;set;}     
    public Map<String,AcctPlanDepositDomestic__c> APDepositDomesticList {get;set;}
    public Map<String,AcctPlanDepositInternational__c> APDepositInternationalList {get;set;}
    public List<String> APDepositDomesticLabel {get;set;}
    public List<String> APDepositInternationalLabel {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public AcctPlanWalletOtherBank__c otherBankDomestic {get;set;}
    public AcctPlanWalletOtherBank__c otherBankInternational {get;set;}
    public Boolean isMiniView {get;set;}
    public Boolean isHasDepositDomestic {get;set;}
    public Boolean isHasDepositInternational {get;set;}
   
   //Account Plan Bond : Jantanee Saetung R5.2

    //public List<AccountPlanBond__c> APBond  {get;set;}
    public List<Account_Plan_AS_Fee__c> ASFee  {get;set;}

    public Double SumOfNetAssetValue {get;set;}  
    public Double SumOfASFee {get;set;}  
    public Double SumOfFixedASFee {get;set;}  
    public Double SumOfWalletASFee {get;set;}  

    public AccountPlanWalletDomainIICtrl(ApexPages.StandardController controller){         
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        String strurl = ApexPages.currentPage().getUrl();           
        strurl = strurl.split('apex/')[1];
        
     
        if(CompanyID !=null && CompanyID != ''){  
            APDepositDomesticList = new Map<String,AcctPlanDepositDomestic__c>();
            APDepositInternationalList = new Map<String,AcctPlanDepositInternational__c>();
            isSystemAdmin = false;
            companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
             isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
             ishasProdStrategy = companyprofile.isHasProdStrategy__c;
             isHasActionPlan = companyprofile.isHasActionPlan__c;
             isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
             isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
            if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
            List<AcctPlanWallet__c> acctplanwalletLists = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
    
            //label record
            APDepositDomesticLabel = new List<String>{'Transactional','1) Current','2) Saving','Non Transactional','Time Deposit','T-Bill','Mutual Fund','Others','Total'};
            APDepositInternationalLabel = new List<String>{'Transactional','1) Current - USD','Current - Other Currency','2) Saving - USD','Saving - Other Currency','Non Transactional','Time Deposit - USD','Time Deposit - Other Currency','Others - USD','Others - Other Currency','Total'};
            
            if(acctplanwalletLists.size() > 0){
                acctplanwallet = acctplanwalletLists.get(0);
                        if(acctplanwallet.NimdPercent_CashOnHand__c != null && (acctplanwallet.CashOnHand_Nimd__c==null || acctplanwallet.InvestmentAmount_NIMd__c == null)){
                            acctplanwallet.CashOnHand_Nimd__c = acctplanwallet.NimdPercent_CashOnHand__c;
                            acctplanwallet.InvestmentAmount_NIMd__c = acctplanwallet.NimdPercent_CashOnHand__c;
                        }
                DepositDomestic();
                DepositInternational(); 
                ASFee();             
            }
            
        }
        if(strurl.containsIgnoreCase('view')){
             List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_3_Percentage__c,
                      Account_Plan_Completion_Percentage__c , 
                      Step_3_1_Entered_Fields__c  ,                                          
                      Step_3_1_Percentage__c ,
                      Step_3_1_Required_Fields__c                                               
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                     if(CompleteList.size()>0){
                         Acctplancompletion = CompleteList.get(0);
                     }
        }else{
            
        }       
    }
    
    //select option share bank
    public List<SelectOption> getShareBanks(){
        List<SelectOption> shareBanksOption = new List<SelectOption>();
        List<Bank__c> bankListitem = [SELECT Id,Name FROM Bank__c];
        shareBanksOption.add(new SelectOption('','none'));
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

    //select option currency Other Currency
    public List<SelectOption> getCurrency(){
        List<SelectOption> currencyOption = new List<SelectOption>();
        List<Currency__c> currencyListitem = [SELECT Id,Name FROM Currency__c WHERE FlagForAcctPlan__c = TRUE AND Name != 'USD'];
        currencyOption.add(new SelectOption('','none'));
        for(Currency__c c : currencyListitem){
            currencyOption.add(new SelectOption(c.Id,c.Name));
        }         
        return currencyOption;
    }
    
    public pageReference EditPage(){       
        PageReference redirectPage = Page.AccountPlanWalletDomainIIEdit;
        redirectPage.getParameters().put('GroupID',GroupID);
        redirectPage.getParameters().put('CompanyID',CompanyID);
        redirectPage.getParameters().put('WalletID',WalletID);
        if(mode !=null && mode !=''){
            redirectPage.getParameters().put('mode',mode);
        }
        redirectPage.setRedirect(true);
        return redirectPage; 
    }
    public pageReference View(){
        PageReference redirectPage = Page.AccountPlanWalletDomainIIView;
        redirectPage.getParameters().put('GroupID',GroupID);
        redirectPage.getParameters().put('CompanyID',CompanyID);
        redirectPage.getParameters().put('WalletID',WalletID);
        if(mode !=null && mode !=''){
            redirectPage.getParameters().put('mode',mode);
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public PageReference save() { 
        try{
            Boolean validate = true;
            /*if(acctplanwallet.WalletNiid_OperatingTransaction__c >100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'NIMd (%) in the Operating transaction cannot over 100 percent.')); 
            }
            
            if(acctplanwallet.NimdPercent_CashOnHand__c >100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'NIMd (%) in the Cash on hand/ Cash at Bank or Investment cannot over 100 percent.')); 
            }*/
            
            if(acctplanwallet.CashCycle__c > 100){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Cash cycle is invalid')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3015').Status_Message__c));
        
            }
            
            /*for(AcctPlanDepositDomestic__c v : APDepositDomesticList.values()){
                    if(!v.Label__c.containsIgnoreCase('transactional') && !v.Label__c.containsIgnoreCase('total')){
                        if(v.ShareTMBPercent__c == null){
                            v.ShareTMBPercent__c = 0;
                        }
                        if(v.SharePercentBank1__c == null){
                            v.SharePercentBank1__c = 0;
                        }
                        if(v.SharePercentBank2__c == null){
                            v.SharePercentBank2__c = 0;
                        }
                        if(v.SharePercentBank3__c == null){
                            v.SharePercentBank3__c = 0;
                        }
                        if(v.SharePercentBank4__c == null){
                            v.SharePercentBank4__c = 0;
                        }
                        Double sumShareBank = v.ShareTMBPercent__c+v.SharePercentBank1__c+v.SharePercentBank2__c+v.SharePercentBank3__c+v.SharePercentBank4__c;
                        system.debug('sumShareBank='+sumShareBank);
                        if(sumShareBank > 100){
                            validate = false;
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %share of '+v.Label__c+' in Deposit Domestic table must not be more than 100%')); 
                        }
                    }
                }
            
            for(AcctPlanDepositInternational__c v : APDepositInternationalList.values()){
                    if(!v.Label__c.containsIgnoreCase('transactional') && !v.Label__c.containsIgnoreCase('total')){
                        if(v.ShareTMBPercent__c == null){
                            v.ShareTMBPercent__c = 0;
                        }
                        if(v.SharePercentBank1__c == null){
                            v.SharePercentBank1__c = 0;
                        }
                        if(v.SharePercentBank2__c == null){
                            v.SharePercentBank2__c = 0;
                        }
                        if(v.SharePercentBank3__c == null){
                            v.SharePercentBank3__c = 0;
                        }
                        if(v.SharePercentBank4__c == null){
                            v.SharePercentBank4__c = 0;
                        }
                        Double sumShareBank = v.ShareTMBPercent__c+v.SharePercentBank1__c+v.SharePercentBank2__c+v.SharePercentBank3__c+v.SharePercentBank4__c;
                        system.debug('sumShareBank='+sumShareBank);
                        if(sumShareBank > 100){
                            validate = false;
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %share of '+v.Label__c+' in Deposit International table must not be more than 100%')); 
                        }
                    }
                }*/
            Double SumOfWalletASFee = 0;

            Double WalletASFee_AgencyService = 0; 
            Double WalletASFee_Custodian  = 0;  
            Double WalletASFee_FundSupervisory  =0;
            Double WalletASFee_MiddleOffice =0;
            Double WalletASFee_RegistrarPaymentAgent =0;

            if(validate){
                //save deposit domestic
                List<AcctPlanDepositDomestic__c> saveAPDepositDomestic = new List<AcctPlanDepositDomestic__c>();
                for(AcctPlanDepositDomestic__c v : APDepositDomesticList.values()){
                    if(!v.Label__c.containsIgnoreCase('transactional') && !v.Label__c.containsIgnoreCase('total')){
                        if(v.Label__c.containsIgnoreCase('Current') || v.label__c.containsIgnoreCase('Saving')){
                            v.TransactionType__c = true;                    
                        }
                        if(!v.Label__c.containsIgnoreCase('Others')){ 
                            v.Label_Value__c = v.Label__c;
                        }
                        saveAPDepositDomestic.add(v);
                    }
                }
                if(otherBankDomestic != null){
                    upsert otherBankDomestic;
                }
                if(saveAPDepositDomestic.size() > 0){
                    upsert saveAPDepositDomestic;
                }
                
                //save deposit international
                Currency__c usdID = [SELECT Id FROM Currency__c WHERE FlagForAcctPlan__c = TRUE AND Name = 'USD'];
                
                List<AcctPlanDepositInternational__c> saveAPDepositInternational = new List<AcctPlanDepositInternational__c>();
                for(AcctPlanDepositInternational__c v : APDepositInternationalList.values()){
                    if(!v.Label__c.containsIgnoreCase('transactional') && !v.Label__c.containsIgnoreCase('total')){
                        if(v.Label__c.containsIgnoreCase('Current') || v.label__c.containsIgnoreCase('Saving')){
                            v.TransactionType__c = true;                    
                        }
                        if(!v.Label__c.containsIgnoreCase('Others')){
                            v.Label_Value__c = v.Label__c;
                        }
                        if(v.Label__c.containsIgnoreCase('USD')){
                            v.CCY__c = usdID.Id;                    
                        }
                        saveAPDepositInternational.add(v);
                    }
                }
                if(otherBankInternational != null){
                    upsert otherBankInternational;
                }
                if(saveAPDepositInternational.size() > 0){
                    upsert saveAPDepositInternational;
                }

                //AS Fee
                for(Account_Plan_AS_Fee__c item : [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__C
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :WalletID ORDER BY SEQ__C]){
                
                //Sum value
                if(item.Net_Asset_Value__c == null){
                    item.Net_Asset_Value__c = 0;
                } 
                if(item.AS_Fee__c == null){
                    item.AS_Fee__c =0;
                }
                if(item.Fixed_AS_Fee__c == null){
                    item.Fixed_AS_Fee__c =0;
                }


                SumOfNetAssetValue += item.Net_Asset_Value__c;
                SumOfASFee += item.AS_Fee__c;    
                SumOfFixedASFee += item.Fixed_AS_Fee__c; 
                if(item.Wallet_AS_Fee__c != null){
                    SumOfWalletASFee += item.Wallet_AS_Fee__c;  
                }

                if(item.AS_Product_Service__c!=null && item.AS_Product_Service__c!=''){
                    if(item.AS_Product_Service__c.contains('1)')){
                        item.SEQ__C = '1';
                        if(item.Wallet_AS_Fee__c != null){
                        WalletASFee_Custodian += item.Wallet_AS_Fee__c;  
                        }
                        
                    }else if(item.AS_Product_Service__c.contains('2)')){
                        item.SEQ__C = '2';
                        if(item.Wallet_AS_Fee__c != null){
                            WalletASFee_FundSupervisory += item.Wallet_AS_Fee__c; 
                            } 
                        
                    }else if(item.AS_Product_Service__c.contains('3)')){
                        item.SEQ__C = '3';
                        if(item.Wallet_AS_Fee__c != null){
                            WalletASFee_MiddleOffice += item.Wallet_AS_Fee__c;  
                        }
                        
                    }else if(item.AS_Product_Service__c.contains('4)')){
                        item.SEQ__C = '4';
                        if(item.Wallet_AS_Fee__c != null){
                            WalletASFee_AgencyService += item.Wallet_AS_Fee__c;  
                        }
                         
                    }else if(item.AS_Product_Service__c.contains('5)')){
                        item.SEQ__C = '5';
                        if(item.Wallet_AS_Fee__c != null){
                            WalletASFee_RegistrarPaymentAgent += item.Wallet_AS_Fee__c;  
                        }
                      
                    }    
                }
                  
                acctplanwallet.SumOfWalletASFee__c = SumOfWalletASFee;
                acctplanwallet.WalletASFee_AgencyService__c =WalletASFee_AgencyService;
                 acctplanwallet.WalletASFee_Custodian__c = WalletASFee_Custodian;
                 acctplanwallet.WalletASFee_FundSupervisory__c = WalletASFee_FundSupervisory;
                 acctplanwallet.WalletASFee_MiddleOffice__c =WalletASFee_MiddleOffice;
                 acctplanwallet.WalletASFee_RegistrarPaymentAgent__c = WalletASFee_RegistrarPaymentAgent; 
                

            }    
                
                //save wallet
                if(acctplanwallet!=null){
                    upsert acctplanwallet;           
                }
                companyprofile.Status__c = 'In Progress';
                update companyprofile;
                AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(acctplanwallet.AcctPlanCompanyProfile__c);
                
                PageReference redirectPage = View();
                return redirectPage;
            }else{
                return null;
            }
        }catch(Exception E){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public void DepositDomestic(){
        Double totalAPDDTMB = 0.0;
        Double totalAPDDbank1 = 0.0;
        Double totalAPDDbank2 = 0.0;
        Double totalAPDDbank3 = 0.0;
        Double totalAPDDbank4 = 0.0;
        Double totalAPDDtransTMB = 0.0;
        Double totalAPDDtransbank1 = 0.0;
        Double totalAPDDtransbank2 = 0.0;
        Double totalAPDDtransbank3 = 0.0;
        Double totalAPDDtransbank4 = 0.0;
        Double totalAPDDnontransTMB = 0.0;
        Double totalAPDDnontransbank1 = 0.0;
        Double totalAPDDnontransbank2 = 0.0;
        Double totalAPDDnontransbank3 = 0.0;
        Double totalAPDDnontransbank4 = 0.0;
        isHasDepositDomestic = true;
        
        List<AcctPlanDepositDomestic__c> APDepositDomesticTemp = [SELECT Id,AvgRatePercent__c,ShareTMBPercent__c,TMBAmount__c,TMBRate__c,SharePercentBank1__c,
                                                    AmountBank1__c,RateBank1__c,SharePercentBank2__c,AmountBank2__c,RateBank2__c,SharePercentBank3__c,
                                                    AmountBank3__c,RateBank3__C,SharePercentBank4__c,AmountBank4__c,RateBank4__c,Label__c,
                                                    TransactionType__c,Label_Value__c
                                                    FROM AcctPlanDepositDomestic__c
                                                    WHERE AccountPlanDepositDomesticDeposit__c = :acctplanwallet.Id];
         
        List<AcctPlanWalletOtherBank__c> otherBankDomesticList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                  FROM AcctPlanWalletOtherBank__c 
                                                                  WHERE AcctPlanWallet__c = :acctplanwallet.Id AND TableName__c = 'Deposit Domestic'];
        if(otherBankDomesticList.size() <= 0){          
            AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
            ob.AcctPlanWallet__c = acctplanwallet.Id;
            ob.TableName__c = 'Deposit Domestic';
            otherBankDomestic = ob; 
        }else{
            otherBankDomestic = otherBankDomesticList.get(0); 
        }
        
        //Existing Deposit Domestic
        if(APDepositDomesticTemp.size()>0){
            for(AcctPlanDepositDomestic__c item : APDepositDomesticTemp){
                item.AccountPlanDepositDomesticDeposit__c = acctplanwallet.Id;
                if(item.TMBAmount__c == null){
                    item.TMBAmount__c = 0;
                }
                if(item.AmountBank1__c == null){
                    item.AmountBank1__c = 0;
                }
                if(item.AmountBank2__c == null){
                    item.AmountBank2__c = 0;
                }
                if(item.AmountBank3__c == null){
                    item.AmountBank3__c = 0;
                }
                if(item.AmountBank4__c == null){
                    item.AmountBank4__c = 0;
                }                
                totalAPDDTMB += item.TMBAmount__c;
                totalAPDDbank1 += item.AmountBank1__c;
                totalAPDDbank2 += item.AmountBank2__c;
                totalAPDDbank3 += item.AmountBank3__c;
                totalAPDDbank4 += item.AmountBank4__c;
                if(item.TransactionType__c){
                    totalAPDDtransTMB += item.TMBAmount__c;
                    totalAPDDtransbank1 += item.AmountBank1__c;
                    totalAPDDtransbank2 += item.AmountBank2__c;
                    totalAPDDtransbank3 += item.AmountBank3__c;
                    totalAPDDtransbank4 += item.AmountBank4__c;
                }else{
                    totalAPDDnontransTMB += item.TMBAmount__c;
                    totalAPDDnontransbank1 += item.AmountBank1__c;
                    totalAPDDnontransbank2 += item.AmountBank2__c;
                    totalAPDDnontransbank3 += item.AmountBank3__c;
                    totalAPDDnontransbank4 += item.AmountBank4__c;
                }
                /*if(item.TMBAmount__c == 0){
                    item.TMBAmount__c = null;
                }*/
                if(item.AmountBank1__c == 0){
                    item.AmountBank1__c = null;
                }
                if(item.AmountBank2__c == 0){
                    item.AmountBank2__c = null;
                }
                if(item.AmountBank3__c == 0){
                    item.AmountBank3__c = null;
                }
                if(item.AmountBank4__c == 0){
                    item.AmountBank4__c = null;
                } 
                APDepositDomesticList.put(item.label__c,item);
                
                AcctPlanDepositDomestic__c APDDtemptransaction = new AcctPlanDepositDomestic__c();
                APDDtemptransaction.TMBAmount__c = totalAPDDtransTMB;
                APDDtemptransaction.AmountBank1__c = totalAPDDtransbank1;
                APDDtemptransaction.AmountBank2__c = totalAPDDtransbank2;
                APDDtemptransaction.AmountBank3__c = totalAPDDtransbank3;
                APDDtemptransaction.AmountBank4__c = totalAPDDtransbank4;
                APDDtemptransaction.Label__c = 'Transactional';
                APDepositDomesticList.put(APDDtemptransaction.Label__c,APDDtemptransaction);
                
                AcctPlanDepositDomestic__c APDDtempnontransaction = new AcctPlanDepositDomestic__c();
                APDDtempnontransaction.TMBAmount__c = totalAPDDnontransTMB;
                APDDtempnontransaction.AmountBank1__c = totalAPDDnontransbank1;
                APDDtempnontransaction.AmountBank2__c = totalAPDDnontransbank2;
                APDDtempnontransaction.AmountBank3__c = totalAPDDnontransbank3;
                APDDtempnontransaction.AmountBank4__c = totalAPDDnontransbank4;
                APDDtempnontransaction.Label__c = 'Non Transactional';
                APDepositDomesticList.put(APDDtempnontransaction.Label__c,APDDtempnontransaction); 
                
                AcctPlanDepositDomestic__c APDDtemptotal = new AcctPlanDepositDomestic__c();
                APDDtemptotal.TMBAmount__c = totalAPDDTMB;
                APDDtemptotal.AmountBank1__c = totalAPDDbank1;
                APDDtemptotal.AmountBank2__c = totalAPDDbank2;
                APDDtemptotal.AmountBank3__c = totalAPDDbank3;
                APDDtemptotal.AmountBank4__c = totalAPDDbank4;
                APDDtemptotal.Label__c = 'Total';
                APDepositDomesticList.put(APDDtemptotal.Label__c,APDDtemptotal);
            }
    
            
        }else{
            isHasDepositDomestic = false;
        }
 
        if(!isHasDepositDomestic){
            for(String l : APDepositDomesticLabel){ 
                AcctPlanDepositDomestic__c APDepositDomesticitem = new AcctPlanDepositDomestic__c();
                APDepositDomesticitem.AccountPlanDepositDomesticDeposit__c = acctplanwallet.Id;
                APDepositDomesticitem.Label__c = l;
                APDepositDomesticList.put(l,APDepositDomesticitem);
            }
        }       
    }
    
    Public void DepositInternational(){
        Double totalAPDIAverage = 0.0;
        Double totalAPDItransAverage = 0.0;
        Double totalAPDInontransAverage = 0.0;
        Double totalAPDITMB = 0.0;
        Double totalAPDIbank1 = 0.0;
        Double totalAPDIbank2 = 0.0;
        Double totalAPDIbank3 = 0.0;
        Double totalAPDIbank4 = 0.0; 
        Double totalAPDItransTMB = 0.0;
        Double totalAPDItransbank1 = 0.0;
        Double totalAPDItransbank2 = 0.0;
        Double totalAPDItransbank3 = 0.0;
        Double totalAPDItransbank4 = 0.0;
        Double totalAPDInontransTMB = 0.0;
        Double totalAPDInontransbank1 = 0.0;
        Double totalAPDInontransbank2 = 0.0;
        Double totalAPDInontransbank3 = 0.0;
        Double totalAPDInontransbank4 = 0.0;
        isHasDepositInternational = true;
        
        List<AcctPlanDepositInternational__c> APDepositInternationalTemp = [SELECT Id,AmountBank1__c, AmountBank2__c, AmountBank3__c, AmountBank4__c,
                                                         AmtPerMonth__c,CCY__c,CCY__r.Name, Label__c, RateBank1__c, RateBank2__c, RateBank3__c,
                                                         RateBank4__c, SharePercentBank1__c, SharePercentBank2__c, SharePercentBank3__c,
                                                         SharePercentBank4__c, ShareTMBPercent__c, TenorPerPeriod__c,TMBAmount__c, 
                                                         TMBRate__c, AvgRatePercent__c, TransactionType__c, Label_Value__c
                                                         FROM AcctPlanDepositInternational__c  
                                                         WHERE AccountPlanDepositInternationalDeposit__c  = :acctplanwallet.Id];
        
        List<AcctPlanWalletOtherBank__c> otherBankInternationalList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                       FROM AcctPlanWalletOtherBank__c 
                                                                       WHERE AcctPlanWallet__c = :acctplanwallet.Id AND TableName__c = 'Deposit International'];
        if(otherBankInternationalList.size() <= 0){          
            AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
            ob.AcctPlanWallet__c = acctplanwallet.Id;
            ob.TableName__c = 'Deposit International';
            otherBankInternational = ob; 
        }else{
            otherBankInternational = otherBankInternationalList.get(0);
        }
        
        if(APDepositInternationalTemp.size() >0){
            for(AcctPlanDepositInternational__c item : APDepositInternationalTemp){ 
                item.AccountPlanDepositInternationalDeposit__c = acctplanwallet.Id;
                if(item.AmtPerMonth__c == null){
                    item.AmtPerMonth__c = 0;
                }
                if(item.TMBAmount__c == null){
                    item.TMBAmount__c = 0;
                }
                if(item.AmountBank1__c == null){
                    item.AmountBank1__c = 0;
                }
                if(item.AmountBank2__c == null){
                    item.AmountBank2__c = 0;
                }
                if(item.AmountBank3__c == null){
                    item.AmountBank3__c = 0;
                }
                if(item.AmountBank4__c == null){
                    item.AmountBank4__c = 0;
                }                    
                        
                totalAPDIAverage += item.AmtPerMonth__c;
                totalAPDITMB += item.TMBAmount__c;
                totalAPDIbank1 += item.AmountBank1__c;
                totalAPDIbank2 += item.AmountBank2__c;
                totalAPDIbank3 += item.AmountBank3__c;
                totalAPDIbank4 += item.AmountBank4__c;
                if(item.TransactionType__c){              
                    totalAPDItransAverage += item.AmtPerMonth__c;
                    totalAPDItransTMB += item.TMBAmount__c;
                    totalAPDItransbank1 += item.AmountBank1__c;
                    totalAPDItransbank2 += item.AmountBank2__c;
                    totalAPDItransbank3 += item.AmountBank3__c;
                    totalAPDItransbank4 += item.AmountBank4__c;
                }else{
                    totalAPDInontransAverage += item.AmtPerMonth__c;
                    totalAPDInontransTMB += item.TMBAmount__c;
                    totalAPDInontransbank1 += item.AmountBank1__c;
                    totalAPDInontransbank2 += item.AmountBank2__c;
                    totalAPDInontransbank3 += item.AmountBank3__c;
                    totalAPDInontransbank4 += item.AmountBank4__c;
                }
                if(item.AmtPerMonth__c == 0){
                    item.AmtPerMonth__c = null;
                }
                /*if(item.TMBAmount__c == 0){
                    item.TMBAmount__c = null;
                }*/
                if(item.AmountBank1__c == 0){
                    item.AmountBank1__c = null;
                }
                if(item.AmountBank2__c == 0){
                    item.AmountBank2__c = null;
                }
                if(item.AmountBank3__c == 0){
                    item.AmountBank3__c = null;
                }
                if(item.AmountBank4__c == 0){
                    item.AmountBank4__c = null;
                }      
                APDepositInternationalList.put(item.label__c,item);
                
                AcctPlanDepositInternational__c APDItemptransaction = new AcctPlanDepositInternational__c();
                APDItemptransaction.AmtPerMonth__c = totalAPDItransAverage;
                APDItemptransaction.TMBAmount__c  =  totalAPDItransTMB;
                APDItemptransaction.AmountBank1__c = totalAPDItransbank1;
                APDItemptransaction.AmountBank2__c = totalAPDItransbank2;
                APDItemptransaction.AmountBank3__c = totalAPDItransbank3;
                APDItemptransaction.AmountBank4__c = totalAPDItransbank4;
                APDItemptransaction.Label__c = 'Transactional';
                APDepositInternationalList.put(APDItemptransaction.label__c,APDItemptransaction);
                
                AcctPlanDepositInternational__c APDItempnontransaction = new AcctPlanDepositInternational__c();
                APDItempnontransaction.AmtPerMonth__c = totalAPDInontransAverage;
                APDItempnontransaction.TMBAmount__c  =  totalAPDInontransTMB;
                APDItempnontransaction.AmountBank1__c = totalAPDInontransbank1;
                APDItempnontransaction.AmountBank2__c = totalAPDInontransbank2;
                APDItempnontransaction.AmountBank3__c = totalAPDInontransbank3;
                APDItempnontransaction.AmountBank4__c = totalAPDInontransbank4;
                APDItempnontransaction.Label__c = 'Non Transactional';
                APDepositInternationalList.put(APDItempnontransaction.Label__c,APDItempnontransaction);
                
                AcctPlanDepositInternational__c APDItemptotal = new AcctPlanDepositInternational__c();
                APDItemptotal.AmtPerMonth__c = totalAPDIAverage;
                APDItemptotal.TMBAmount__c = totalAPDITMB;
                APDItemptotal.AmountBank1__c = totalAPDIbank1;
                APDItemptotal.AmountBank2__c = totalAPDIbank2;
                APDItemptotal.AmountBank3__c = totalAPDIbank3;
                APDItemptotal.AmountBank4__c = totalAPDIbank4;
                APDItemptotal.Label__c = 'Total';
                APDepositInternationalList.put(APDItemptotal.Label__c,APDItemptotal);
            }
        }else{
            isHasDepositInternational = false;
        }
        if(!isHasDepositInternational){
            for(String l : APDepositInternationalLabel){ 
                AcctPlanDepositInternational__c APDepositInternationalitem = new AcctPlanDepositInternational__c();
                APDepositInternationalitem.AccountPlanDepositInternationalDeposit__c = acctplanwallet.Id;
                APDepositInternationalitem.Label__c = l;
                APDepositInternationalList.put(l,APDepositInternationalitem);
            }
        }
    }
    public PageReference Refresh(){
        try{
            system.debug('isHasDepositDomestic='+isHasDepositDomestic);
            system.debug('isHasDepositInternational='+isHasDepositInternational);
            if(!isHasDepositDomestic){
                insert APDepositDomesticList.values();      
            }
            if(!isHasDepositInternational){
                insert APDepositInternationalList.values();
            }
            AccountPlanRefreshService.RefreshDepositDomestic(CompanyID,WalletID ,GroupID );
            AccountPlanRefreshService.RefreshDepositInter(CompanyID,WalletID ,GroupID);
            //Refresh Values
            DateTime now = DateTime.now();
            acctplanwallet.DataAsOfDeposit__c  = now;
            upsert acctplanwallet;
            DepositDomestic();  
            DepositInternational();
            system.debug('isHasDepositDomestic='+isHasDepositDomestic);
            system.debug('isHasDepositInternational='+isHasDepositInternational);    
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }     
        return null;
    }
    public PageReference RefreshDomestic(){ 
        try{
            AccountPlanRefreshService.RefreshDepositDomestic(CompanyID,WalletID ,GroupID );
            //Refresh Values
            DepositDomestic();
            
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }     
        return null;
    }
    
    public PageReference RefreshInternational(){ 
        try{
            AccountPlanRefreshService.RefreshDepositInter(CompanyID,WalletID ,GroupID);
            //Refresh Values
            DepositInternational();
            
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }     
        return null;
    }

    //Account Plan AS Fee  : Jantanee Saetung R5.2
    public void ASFee(){
        Boolean isHasASFee = true;
         SumOfNetAssetValue = 0;
         SumOfASFee = 0;
         SumOfFixedASFee = 0;
         SumOfWalletASFee = 0; 
        
        ASFee = [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__c
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :acctplanwallet.Id
                          ORDER BY SEQ__c ASC];
        if(ASFee.size() > 0){
            for(Account_Plan_AS_Fee__c item : ASFee){
                if(item.Net_Asset_Value__c == null){
                    item.Net_Asset_Value__c = 0;
                } 
                if(item.AS_Fee__c == null){
                    item.AS_Fee__c =0;
                }
                if(item.Fixed_AS_Fee__c == null){
                    item.Fixed_AS_Fee__c =0;
                }

                SumOfNetAssetValue += item.Net_Asset_Value__c;
                SumOfASFee += item.AS_Fee__c;    
                SumOfFixedASFee += item.Fixed_AS_Fee__c;  
                if( item.Wallet_AS_Fee__c != null) {
                    SumOfWalletASFee += item.Wallet_AS_Fee__c;    
                }
            }   



        }else{
            isHasASFee = false;
        }
        
        if(!isHasASFee){
            ASFee = new List<Account_Plan_AS_Fee__c>();
        }  
            
    }
    
    /*public void Step3DoaminIICompletionCheck(){  
        Integer FieldCount = 0;
        Integer FieldTotal = 0;
        
        if(wallet.CashCycle__c != null && wallet.CashCycle__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        if(wallet.NimdPercent_OperatingTransaction__c != null && wallet.NimdPercent_OperatingTransaction__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        
        if(wallet.CashOnHand__c != null && wallet.CashOnHand__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        if(wallet.InvestmentAmount__c != null && wallet.InvestmentAmount__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        if(wallet.NimdPercent_CashOnHand__c != null && wallet.NimdPercent_CashOnHand__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        
    }*/
}