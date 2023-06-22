public class EdittableStakeHolderModel extends EditableList {
    //String parameter;
    public String ActivityId {get;set;}


    public EdittableStakeHolderModel (ApexPages.StandardController stdController) {
    super(stdController);
    
    //parameter = ApexPages.currentPage().getParameters().get('sobjectid');  
    ActivityId = ApexPages.currentPage().getParameters().get('ActivityId');

     system.debug('ActivityId  '+ActivityId );


    this.childList = [select Id,User__c,User__r.Name,AcctPlanActivity__c  from AcctPlanStakeholder__c where AcctPlanActivity__c = : ActivityId ];
        
    
  }
  
  public override sObject initChildRecord()
  {

    AcctPlanStakeholder__c child = new AcctPlanStakeholder__c();
    child.AcctPlanActivity__c = ActivityId;
    system.debug('child '+child);

    return child;
  }
  
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanStakeholder__c> getChildren()
  {
    return (List<AcctPlanStakeholder__c>)childList;
  }


    public void dosave(){
    
        try{
            system.debug('##dosave##');
            super.save();
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('5001').Status_Message__c));
        
    
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }
    
    

  
}