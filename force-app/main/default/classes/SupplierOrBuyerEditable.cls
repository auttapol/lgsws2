public class SupplierOrBuyerEditable extends EditableList {
	String companyid,segment;
    public String title {get;set;}
    public String typeOf {get;set;}
    public String estimated {get;set;}
    public String method {get;set;}
    public boolean isIDnull {get;set;}
        //select option currency Other Currency
    public List<SelectOption> getCurrency(){
        List<SelectOption> currencyOption = new List<SelectOption>();
        List<Currency__c> currencyListitem = [SELECT Id,Name FROM Currency__c WHERE FlagForAcctPlan__c = TRUE];
        currencyOption.add(new SelectOption('','None'));
        for(Currency__c c : currencyListitem){
            currencyOption.add(new SelectOption(c.Id,c.Name));
        }         
        return currencyOption;
    }
    
	public SupplierOrBuyerEditable(ApexPages.StandardController stdController) {
    super(stdController);

    // If necessary, explicitly query for additional metadata on parent record
    // if you are looking to display things that don't come back with the 
    // StandardController. In that case, you will need to replace the "Account.X"
    // references in the Visualforce Page with references to an Account variable
    // that you will need to declare in this class (myAccount.X). I have commented out
    // an example.
    companyid = ApexPages.currentPage().getParameters().get('companyid');
    segment = ApexPages.currentPage().getParameters().get('segment');
        System.debug('companyid : '+companyid +' segment: '+segment);
        if(segment=='Majorraw'){
            title = 'Add/Edit Major Raw Materials';
            typeof = 'Supplier Type';
            estimated = 'Estimated No. of Suppliers';
            method = 'Method of Payment';
            segment = 'Major raw material';
        }else{
            typeof = 'Buyer Type'; 
             method = 'Method of Collection';
            estimated = 'Estimated No. of Buyers';
            title = 'Add/Edit Revenue Contribution by Buyer Type/Segment/Distribution Channel';
        }
        isIDnull =false;
           if( (companyid !=null && companyid !='') && (segment !=null && segment != '')){
    this.childList = [SELECT ID,Name,CreatedDate,
                            CCY__c ,
                            CCY_Short_Name__c ,
                            Company_Name__c  ,
                            Country__c  ,
                            Country_Name__c , 
                            Credit_Term__c ,
                            DataType__c,
                      		EstimateNo__c ,
                      		FromDays__c ,
                      		Method__c ,
                      		Segment__c,
                      		ToDays__c,
                      	 	Percent__c 
                           FROM AcctPlanSupplierOrBuyer__c  
                      	   WHERE Account_Plan_Company_Profile__c  =: companyid
                      		AND  Segment__c =: segment
                      	   ORDER by Percent__c DESC];
               
               
           }else{
               isIDnull = true;
        /*ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                                                   'Please return to '+
                                                   'save the current Account Plan from the main screen '+
                                                   'before adding new record in this screen.'
                                                   
                                                   
                                                   ));*/
           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2009').Status_Message__c));
        
       
       
    }
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanSupplierOrBuyer__c> getChildren()
  {
    return (List<AcctPlanSupplierOrBuyer__c>)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanSupplierOrBuyer__c  child = new AcctPlanSupplierOrBuyer__c ();
    // Can either use mysObject or acct here
      if((companyid !=null && companyid !='') && (segment !=null && segment !='')){
           child.Account_Plan_Company_Profile__c = companyid;
           child.Segment__c = segment;
      
    }else{
        isIDnull = true;
        /*ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                                                   
                                                   'Please return to '+
                                                   'save the current Account Plan from the main screen '+
                                                   'before adding new record in this screen.'
                                                   
                                                   
                                                  ));*/
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2009').Status_Message__c));
        
       return null;
    }
    
    return child;
  }
    
    
    public void insertRecord(){
        try{
            Double totalpercent = 0.00;
            for(AcctPlanSupplierOrBuyer__c acctSoB : getChildren()){
                if(acctSoB.Percent__c !=null){
                    totalpercent +=acctSoB.Percent__c;
                }
            }  
            
            if(totalpercent > 100){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Percentage must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2010').Status_Message__c));
        
            }else{
                super.save(); 
       			//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
            }
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Save error : '+e.getMessage()));
        }
    }
}