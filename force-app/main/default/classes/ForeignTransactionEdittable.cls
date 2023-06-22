public class ForeignTransactionEdittable extends EditableList {
    public String walletId {get;set;}
    public String currenyid {get;set;}

    public Map<String,Decimal> CurrencyMap {get;set;}
    public Map<ID,Double> ExchangeRateMap {get;set;}
    public List<SelectOption> CurrencySelectOption {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c > CurrencyList {get;set;}
    public Map<String,Decimal> ActualHedgingMap {get;set;}
    public ForeignTransactionEdittable(ApexPages.StandardController stdController) {
    super(stdController);
    walletId = ApexPages.currentPage().getParameters().get('walletid');
    // If necessary, explicitly query for additional metadata on parent record
    // if you are looking to display things that don't come back with the 
    // StandardController. In that case, you will need to replace the "Account.X"
    // references in the Visualforce Page with references to an Account variable
    // that you will need to declare in this class (myAccount.X). I have commented out
    // an example.

    // this.myAccount = [SELECT Id,
    //                            Name,
    //                            Custom_Relationship__r.Name
    //                        FROM Account
    //                        WHERE Id =: stdController.getRecord().Id];
    
    this.childList = [SELECT Id,
                          ExchangeRateOfTHB__c,
                          AcctPlanWallet__c ,
                          CCY__c   ,
                          CCY__r.Name,  
                          WalletFXFeePerYear__c   ,
                          PropsectHedgedAmount__c  ,
                          HedgingRatio__c ,
                          HedgingPolicy__c ,
                          FXMarginStg__c  ,
                          AmtPerYear__c  
                      FROM AcctPlanForeignTrans__c    
                      WHERE AcctPlanWallet__c  = :walletid
                      ORDER BY CCY__r.Name ASC
                      ];
        
       
    
        CurrencyMap = new Map<String,Decimal> ();
        CurrencySelectOption = new List<SelectOption>();
        ExchangeRateMap = new Map<Id,Double>();
        CurrencyList = new List<AcctPlanCollectionOrPaymentCurrency__c>( [SELECT Name,AcctPlanWallet__c,
                                                                           CCY__c,
                                                                           CCY__r.Name ,
                                                                           CCY__r.Exchange_Rate__c,
                                                                           CCY__r.Exchange_Rate__r.ExchangeRateOfTHB__c,
                                                                           CollectionAmtPerYear__c,
                                                                           CollectionIsDeleted__c,
                                                                           CollectionPortion__c,
                                                                           Currency_Type__c,
                                                                           PaymentAmtPerYear__c,
                                                                           PaymentIsDeleted__c,
                                                                           PaymentPortion__c 
                                                                           FROM AcctPlanCollectionOrPaymentCurrency__c 
                                                                           WHERE AcctPlanWallet__c =: walletid]);
        for(AcctPlanCollectionOrPaymentCurrency__c curr : CurrencyList){
            System.debug('curr.CCY__c : '+curr.CCY__c);
            System.debug('curr.CCY__r.Exchange_Rate__c : '+curr.CCY__r.Exchange_Rate__c);
            System.debug('ExchangeRateOfTHB__c : '+curr.CCY__r.Exchange_Rate__r.ExchangeRateOfTHB__c);
            if(curr.CCY__r.Exchange_Rate__c !=null){
               ExchangeRateMap.put(curr.CCY__c,curr.CCY__r.Exchange_Rate__r.ExchangeRateOfTHB__c);
            }
            
            
            if(!CurrencyMap.containsKey(curr.CCY__c)){
                CurrencySelectOption.add(new SelectOption(curr.CCY__c,curr.CCY__r.Name));
              
                if(curr.Currency_Type__c =='Collection' ){
                   CurrencyMap.put(curr.CCY__c,curr.CollectionAmtPerYear__c); 
                }else if(curr.Currency_Type__c =='Payment' ){
                   CurrencyMap.put(curr.CCY__c,curr.PaymentAmtPerYear__c); 
                }
            }else{
                
               if(curr.Currency_Type__c =='Collection' ){
                   Decimal oldvalue = CurrencyMap.get(curr.CCY__c);
                   oldvalue +=curr.CollectionAmtPerYear__c;
                   CurrencyMap.put(curr.CCY__c,oldvalue); 
                }else if(curr.Currency_Type__c =='Payment' ){
                 Decimal oldvalue = CurrencyMap.get(curr.CCY__c);
                   oldvalue +=curr.PaymentAmtPerYear__c;
                   CurrencyMap.put(curr.CCY__c,oldvalue); 
                }
            }
           
        }
        
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanForeignTrans__c > getChildren()
  {

    return (List<AcctPlanForeignTrans__c >)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanForeignTrans__c  child = new AcctPlanForeignTrans__c ();
    // Can either use mysObject or acct here
    
    
    child.AcctPlanWallet__c = walletid;
    return child;
  }
    
    
    public  void checkportion(){

        try{
       boolean isOverStack = false;
       ActualHedgingMap = new Map<String,Decimal>();
           
           
        for(AcctPlanForeignTrans__c foreign : getChildren()){
            
            //ExchangeRateMap
            foreign.ExchangeRateOfTHB__c = ExchangeRateMap.get(foreign.CCY__c);
             if(CurrencyMap.containsKey(foreign.CCY__c)){
                  foreign.AmtPerYear__c = CurrencyMap.get(foreign.CCY__c);
                  
               }
            
            
            if(!ActualHedgingMap.containsKey(foreign.CCY__c)){
                if(foreign.HedgingRatio__c >0 && foreign.HedgingRatio__c <101){
                   ActualHedgingMap.put(foreign.CCY__c, foreign.HedgingRatio__c);
                }else{
                    isOverStack = true;
                }
            }else{
                
               Decimal oldvalue = ActualHedgingMap.get(foreign.CCY__c);
               oldvalue +=foreign.HedgingRatio__c;
                if(oldvalue >100){
                     isOverStack = true;
                }else{
                     ActualHedgingMap.put(foreign.CCY__c, oldvalue);
                }
            }
            
            if(foreign.HedgingPolicy__c == 'Natural hedge'){
                foreign.FXMarginStg__c = 0;
            }
            
        }
            
        if(!isOverStack ){
             
            super.save();
            
            AcctPlanWallet__c wallet = [SELECT ID,SumOfAcctPlanForeignWalletFXFeePerYear__c,Wallet_FX_Fee_Yearly_THB__c from AcctPlanWallet__c WHERE ID=:walletId LIMIT 1];
            Double sumFXFee = 0;
            for(AcctPlanForeignTrans__c foreign : getChildren()){
                sumFXFee += foreign.WalletFXFeePerYear__c;
            }
            wallet.SumOfAcctPlanForeignWalletFXFeePerYear__c = sumFXFee + wallet.Wallet_FX_Fee_Yearly_THB__c==null?0:wallet.Wallet_FX_Fee_Yearly_THB__c;
            update wallet;
            
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
        }else if(isOverStack){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Hedging ratio must not be more than 100%'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3027').Status_Message__c));
        
        }
            
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }
    // Fix Refresh
    public override  void  refresh(){
          removeChildList.clear();
          childList.clear();
         
            this.childList = [SELECT Id,
                          AcctPlanWallet__c ,
                          CCY__c   ,
                          CCY__r.Name   ,
                          WalletFXFeePerYear__c   ,
                          PropsectHedgedAmount__c  ,
                          HedgingRatio__c ,
                          HedgingPolicy__c ,
                          FXMarginStg__c  ,
                          ExchangeRateOfTHB__c,
                          AmtPerYear__c  
                      FROM AcctPlanForeignTrans__c    
                      WHERE AcctPlanWallet__c  = :walletid
                      ];

    }


}