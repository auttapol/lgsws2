public class OtherExpenditureEdittableCtrl extends EditableList {
    public String walletId {get;set;}
        public  List<SelectOption> CurrencyOptions {get;set;}
    public OtherExpenditureEdittableCtrl(ApexPages.StandardController stdController) {
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
                          AcctPlanWallet__c  ,
                          Currency__c    ,
                          currency__r.Name   ,
                          ExpectedAmountOrHistoricalAmount__c    ,
                          HedgingPolicy__c   ,
                          MismatchCurrency__c  ,
                          Opportunity__c  ,
                          RevenueOrExpenditure__c   ,
                          Timeline__c   
                      FROM AcctPlanOtherRevenueExpenditure__c     
                      WHERE AcctPlanWallet__c   = :walletid
                      ];
    
     CurrencyOptions = new List<SelectOption>();
        CurrencyOptions.add(new SelectOption('','--None--'));
        
        List<Currency__c> currencyList = [SELECT ID,Name,SEQ__c,Exchange_Rate__c,FlagForAcctPlan__c, Full_Name__c 
                                         FROM Currency__c
                                         WHERE FlagForAcctPlan__c = true
                                         ORDER BY SEQ__c];
        
        for(Currency__c curr : currencyList){
            CurrencyOptions.add(new SelectOption(curr.id,curr.Name));
        }
           
        
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanOtherRevenueExpenditure__c  > getChildren()
  {

    return (List<AcctPlanOtherRevenueExpenditure__c  >)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanOtherRevenueExpenditure__c   child = new AcctPlanOtherRevenueExpenditure__c  ();
    // Can either use mysObject or acct here
    
    
    child.AcctPlanWallet__c = walletid;
    return child;
  }
    
    
    public  void checkportion(){

        try{
            
            for(AcctPlanOtherRevenueExpenditure__c child : getChildren()){
                if(child.HedgingPolicy__c =='Natural hedge'){
                    child.Opportunity__c = 'FCD Account';
                }else if(child.HedgingPolicy__c !=null
                   &&child.HedgingPolicy__c !='Natural hedge'){
                    child.Opportunity__c = 'Forward or Derivative';
                  }else{
                      child.Opportunity__c = null;
                  }
                
                
                
            }
            super.save();
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
          
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }
    // Fix Refresh
    public override  void  refresh(){
          removeChildList.clear();
          childList.clear();
        
            this.childList = [SELECT Id,
                          AcctPlanWallet__c  ,
                          Currency__c    ,
                          currency__r.Name   ,
                          ExpectedAmountOrHistoricalAmount__c    ,
                          HedgingPolicy__c   ,
                          MismatchCurrency__c  ,
                          Opportunity__c  ,
                          RevenueOrExpenditure__c   ,
                          Timeline__c   
                      FROM AcctPlanOtherRevenueExpenditure__c     
                      WHERE AcctPlanWallet__c   = :walletid
                      ];

    }


}