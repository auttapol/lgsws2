public class Top5Editable extends EditableList {
	String companyid; 
    public String segment{get;set;}
    public String SegmentName {get;set;}
    public boolean isIDNull{get;set;}
	public Top5Editable(ApexPages.StandardController stdController) {
    super(stdController);

    // If necessary, explicitly query for additional metadata on parent record
    // if you are looking to display things that don't come back with the 
    // StandardController. In that case, you will need to replace the "Account.X"
    // references in the Visualforce Page with references to an Account variable
    // that you will need to declare in this class (myAccount.X). I have commented out
    // an example.
    companyid = ApexPages.currentPage().getParameters().get('companyid');
    segment = ApexPages.currentPage().getParameters().get('segment');
    SegmentName = segment.substring(0,segment.length()-1);    
        System.debug('companyid : '+companyid +' segment: '+segment);
        isIDNull =false;
           if( (companyid !=null && companyid !='') && (segment !=null && segment != '')){
    this.childList = [SELECT ID,Name,
                            Account_Plan_Company_Profile__c  ,
                            Credit_Term_Days__c,
                            Customer_Name__c,
                            Percent__c,
                            Top_5_Types__c
                           FROM Account_Plan_Company_Top_5__c  
                      	   WHERE Account_Plan_Company_Profile__c  =: companyid
                      		AND  Top_5_Types__c =: segment
                      	   ORDER BY Percent__c  DESC,Name ASC];
           }else{
               isIDNull = true;
      
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please return to save the current Account Plan from the main screen before adding new record in this screen.'));
       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2009').Status_Message__c));
        
     
    }
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<Account_Plan_Company_Top_5__c> getChildren()
  {
    return (List<Account_Plan_Company_Top_5__c>)childList;
  }

  public override sObject initChildRecord()
  {
    Account_Plan_Company_Top_5__c   child = new Account_Plan_Company_Top_5__c  ();
    // Can either use mysObject or acct here
      if((companyid !=null && companyid !='') && (segment !=null && segment !='')){
           child.Account_Plan_Company_Profile__c  = companyid;
           child.Top_5_Types__c = segment;
      
    }else{
        isIDNull = true;
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Add error : Cannot Add/Edit record when ID is null.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2011').Status_Message__c));
        
        return null;
    }
    
    return child;
  }
    
    
    public void insertRecord(){
        try{
            
            Double totalpercent = 0.00;
            for(Account_Plan_Company_Top_5__c accttop : getChildren()){
                if(accttop.Percent__c !=null){
                    totalpercent +=accttop.Percent__c;
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