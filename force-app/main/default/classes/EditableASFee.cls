public class EditableASFee extends EditableList {
    public Boolean isExisting {get;set;}
    public Boolean isCapital  {get;set;}
    public String WalletID {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public Boolean isTypeOfFeePercent {get;set;}
    public Boolean isTypeOfFeeFixed {get;set;}
    public String TypeOfFee {get;set;}
    public Integer row {get;set;}

    public EditableASFee(ApexPages.StandardController stdController) {
        super(stdController);
        
        isTypeOfFeePercent = false;
        isTypeOfFeeFixed = false;
        
        String CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        
        if(CompanyID !=null && CompanyID != ''){
            companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
        }
        
        this.childList = [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__C
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :WalletID ORDER BY SEQ__C];
        
    } 

    public List<Account_Plan_AS_Fee__c> getChildren()
    {
         /*Account_Plan_AS_Fee__c   productList = new Account_Plan_AS_Fee__c  ();
        Schema.DescribeFieldResult fieldResult = Account_Plan_AS_Fee__c.AS_Product_Service__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         
        if(childList.size()<=0){
            for( Schema.PicklistEntry f : ple)
            {
               Account_Plan_AS_Fee__c   child = new Account_Plan_AS_Fee__c  ();  
               child.AS_Product_Service__c = f.getValue();
               child.Account_Plan_Wallet__c = WalletID;
               childList.add(child);
            }
        }*/

        return (List<Account_Plan_AS_Fee__c>)childList;
    }
    
    public override sObject initChildRecord()
    {
        Account_Plan_AS_Fee__c   child = new Account_Plan_AS_Fee__c  ();
        child.Account_Plan_Wallet__c = WalletID;
        //changeTypeOfFee();
        return child;
    }
    
    public void changeTypeOfFee(){
        /*row = Integer.valueOf(ApexPages.currentPage().getParameters().get('row')); 
       
            super.save();
            List<Account_Plan_AS_Fee__c> updatevalue = [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                                                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c
                                                          FROM Account_Plan_AS_Fee__c  
                                                          WHERE Account_Plan_Wallet__c = :WalletID ORDER BY AS_Product_Service__c];
              Account_Plan_AS_Fee__c item = new Account_Plan_AS_Fee__c();
              if(updatevalue.size()>0){               
                item = updatevalue.get(row);             
                system.debug('Net_Asset_Value__c='+item.Net_Asset_Value__c);
                system.debug('AS_Fee__c='+item.AS_Fee__c);
                system.debug('Fixed_AS_Fee__c='+item.Fixed_AS_Fee__c);
                    item.Account_Plan_Wallet__c = WalletID;
                    item.Net_Asset_Value__c = 0;
                    item.AS_Fee__c =0;
                    item.Fixed_AS_Fee__c = 0;
               }
                
            update item;*/
             try{
                //super.save();
            }catch(DMLException e){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Save error : '+e.getMessage()));
            }
    }
    public void insertRecord(){
        Boolean validateProduct = true;
        Boolean validateType = true;
        Boolean valiatePercentNet = true;
        Boolean valiatePercentASFee = true;
        Boolean ValidateFixed = true;
            for(Account_Plan_AS_Fee__c item : (List<Account_Plan_AS_Fee__c>) childList){             
                if(item.AS_Product_Service__c == '' || item.AS_Product_Service__c == null){
                    validateProduct = false;                    
                }
                if(item.Type_of_Fee__c == '' || item.Type_of_Fee__c == null){
                    validateType = false;                    
                }
                if(item.Type_of_Fee__c == 'Percent'){
                            if(item.Net_Asset_Value__c == null ){
                                valiatePercentNet = false;
                            }
                            if(item.AS_Fee__c == null ){
                                valiatePercentASFee = false;
                            }
                       }else if(item.Type_of_Fee__c == 'Fixed'){
                            if(item.Fixed_AS_Fee__c == null ){
                                ValidateFixed = false;
                            }
                        }
                
            }
            if(!validateProduct){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'AS Product/Service is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3201').Status_Message__c));
        
            }
            if(!validateType){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Type of Fee is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3202').Status_Message__c));
        
            }
            if(!valiatePercentNet){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Type of Fee is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3203').Status_Message__c));
        
            }
            if(!valiatePercentASFee){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Type of Fee is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3204').Status_Message__c));
        
            }
            if(!ValidateFixed){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Type of Fee is required'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3205').Status_Message__c));
        
            }
        if(validateProduct && validateType && valiatePercentNet && valiatePercentASFee && ValidateFixed){
            try{
               Double SumOfNetAssetValue = 0;
                Double SumOfASFee = 0;
                Double SumOfFixedASFee = 0;
                Double SumOfWalletASFee = 0;

                Double WalletASFee_AgencyService = 0; 
                Double WalletASFee_Custodian  = 0;  
                Double WalletASFee_FundSupervisory  =0;
                Double WalletASFee_MiddleOffice =0;
                Double WalletASFee_RegistrarPaymentAgent =0;

                super.save();
                
                List<Account_Plan_AS_Fee__c> updateValue = new List<Account_Plan_AS_Fee__c>();
                for(Account_Plan_AS_Fee__c item : [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                                Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__C
                              FROM Account_Plan_AS_Fee__c  
                              WHERE Account_Plan_Wallet__c = :WalletID ORDER BY SEQ__C]){
                    system.debug('Net_Asset_Value__c='+item.Net_Asset_Value__c);
                    system.debug('AS_Fee__c='+item.AS_Fee__c);
                    system.debug('Fixed_AS_Fee__c='+item.Fixed_AS_Fee__c);
                    item.Account_Plan_Wallet__c = WalletID;
                    //Reset value before save
                      if(item.Type_of_Fee__c == 'Fixed'){
                            item.Net_Asset_Value__c = 0;
                            item.AS_Fee__c =0;
                       }else if(item.Type_of_Fee__c == 'Percent'){
                            item.Fixed_AS_Fee__c =0;
                        }
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
                    }else{
                        item.AS_Product_Service__c = '--None--';
                    }
                      

                      updateValue.add(item);
                    

                }    
                update updateValue;
                
                List<AcctPlanWallet__c> acctplanwalletLists = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
                AcctPlanWallet__c wallet;
                if(acctplanwalletLists.size() > 0){
                    wallet = acctplanwalletLists.get(0);
                    wallet.Id = WalletID;
                    wallet.SumOfWalletASFee__c = SumOfWalletASFee;
                    wallet.WalletASFee_AgencyService__c =WalletASFee_AgencyService;
                 wallet.WalletASFee_Custodian__c = WalletASFee_Custodian;
                 wallet.WalletASFee_FundSupervisory__c = WalletASFee_FundSupervisory;
                 wallet.WalletASFee_MiddleOffice__c =WalletASFee_MiddleOffice;
                 wallet.WalletASFee_RegistrarPaymentAgent__c = WalletASFee_RegistrarPaymentAgent; 
                    upsert wallet;     
                                   
                } 
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));   
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
            
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Save error : '+e.getMessage()));
        }
    }
}

public void getParameterTypeofFee(){
    TypeOfFee = ApexPages.currentPage().getParameters().get('TypeOfFee');
        
    if(TypeOfFee == 'Fixed'){
        isTypeOfFeePercent = false;
        isTypeOfFeeFixed = true;
    }else if(TypeOfFee == 'Percent'){
        isTypeOfFeePercent = true;
        isTypeOfFeeFixed = false;
    }
}
/*//select option bank
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
}*/

}