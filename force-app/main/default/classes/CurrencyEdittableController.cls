public without sharing class CurrencyEdittableController extends EditableList {
    String CurrencyType {get;set;}
    String walletId {get;set;}
    public boolean isCollection {get;set;}
    public  List<SelectOption> CurrencyOptions {get;set;}
	public CurrencyEdittableController(ApexPages.StandardController stdController) {
    super(stdController);
    isCollection = false;
	walletId = ApexPages.currentPage().getParameters().get('walletid');
    CurrencyType = ApexPages.currentPage().getParameters().get('type');
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
    System.debug('walletID : '+walletID +'  CurrencyType : '+CurrencyType);
        if(currencyType =='Collection'){
            isCollection =true;
        }
    this.childList = [SELECT Id,
                          AcctPlanWallet__c ,
                          CCY__c   ,
                      	  CCY__r.Name   ,
                          CollectionAmtPerYear__c  ,
                          CollectionIsDeleted__c  ,
                      	  CollectionPortion__c ,
                      	  Currency_Type__c,
                          PaymentAmtPerYear__c,
                      	  PaymentIsDeleted__c ,
                      	  PaymentPortion__c 
                      FROM AcctPlanCollectionOrPaymentCurrency__c   
                      WHERE Currency_Type__c  =:CurrencyType
                      AND AcctPlanWallet__c = :walletid
                      ];
        
        CurrencyOptions = new List<SelectOption>();
        CurrencyOptions.add(new SelectOption('','--None--'));
        
            List<Currency__c> currencyList = [SELECT ID,Name,SEQ__C,Exchange_Rate__c,FlagForAcctPlan__c, Full_Name__c 
                                         FROM Currency__c
                                         WHERE FlagForAcctPlan__c = true
                                         ORDER BY SEQ__C ASC];
        
        for(Currency__c curr : currencyList){
            CurrencyOptions.add(new SelectOption(curr.id,curr.Name));
        }
        
        
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanCollectionOrPaymentCurrency__c> getChildren()
  {

    return (List<AcctPlanCollectionOrPaymentCurrency__c>)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanCollectionOrPaymentCurrency__c child = new AcctPlanCollectionOrPaymentCurrency__c();
    // Can either use mysObject or acct here
    
    child.Currency_Type__c = CurrencyType;
    child.AcctPlanWallet__c = walletid;
    return child;
  }
    
    
    public  void checkportion(){
       //super.save(); 
        try{
       Double portion =0;
        boolean isnotTHb = true;
            System.debug('getChildren() :'+getChildren());
             if(isCollection){
                isCollection =true;
                 for(AcctPlanCollectionOrPaymentCurrency__c acctcurrency : getChildren()){
            		portion +=acctcurrency.CollectionPortion__c;
                     //if(acctcurrency.CCY__r.Name =='THB'){
                      //   isnotTHb = false;
                     //}
        			}
             }else{
                for(AcctPlanCollectionOrPaymentCurrency__c acctcurrency : getChildren()){
                    portion +=acctcurrency.PaymentPortion__c;
                    //if(acctcurrency.CCY__r.Name =='THB'){
                         //isnotTHb = false;
                     //}
                }
             }
            
           
            
       
        if(portion <=100 && isnotTHb){
            super.save();
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
        }else if(portion>100){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Portion must not be more than 100%'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3025').Status_Message__c));
        
        }else if(!isnotTHB){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot select THB Currency'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3026').Status_Message__c));
        
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
                              CollectionAmtPerYear__c  ,
                              CollectionIsDeleted__c  ,
                              CollectionPortion__c ,
                              Currency_Type__c,
                              PaymentAmtPerYear__c,
                              PaymentIsDeleted__c ,
                              PaymentPortion__c 
                              FROM AcctPlanCollectionOrPaymentCurrency__c   
                              WHERE Currency_Type__c  =:CurrencyType
                              AND AcctPlanWallet__c = :walletid
                          ];

    }


}