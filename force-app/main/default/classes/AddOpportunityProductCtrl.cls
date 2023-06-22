public class AddOpportunityProductCtrl {
    public String OppID {get;set;}
    public String Pricebookid {get;set;}
    public String PricebookName {get;set;}
    public String OpptyName {get;set;}
    public List<OpportunityLineItem> OppLineItem {get;set;}
    public AddOpportunityProductCtrl(Apexpages.StandardController controller){
			OppID = ApexPages.currentPage().getParameters().get('opptyid');
        	Pricebookid = ApexPages.currentPage().getParameters().get('pricebookid');
        if(OppID !=null && OppID != ''){
            OppLineItem = [SELECT ID,Name,IsTemporary__c,OpportunityID,Quantity, UnitPrice, Description,
                           Opportunity.Name,
                           Product2.Name
                      FROM OpportunityLineItem
                      WHERE OpportunityID =: OppID
                      AND IsTemporary__c = true];
            for(OpportunityLineItem oppLine : OppLineItem){
               oppLine.Quantity =null;
                oppLine.UnitPrice = null;
                OpptyName = oppLine.Opportunity.Name;
               
            }
            
        }else{
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'not found Opportunity ID.'));
        }
        
        if(Pricebookid !=null && Pricebookid !=''&&!Test.isRunningTest()){
            PricebookName =  [SELECT ID,Name From Pricebook2 WHERE ID =: Pricebookid LIMIT 1 ].Name;
        }
    }
    
    public void cancel(){
        
        delete OppLineItem;
        
    }
    
    public PageReference save(){
         for(OpportunityLineItem oppLine : OppLineItem){
             oppline.isTemporary__c = false;
            }
        try{
        update OppLineItem;
            
             
            PageReference OpportunityPage = new ApexPages.StandardController([SELECT ID from Opportunity WHERE ID =:OppID LIMIT 1]).view();
            OpportunityPage.setRedirect(true);
            return OpportunityPage;
        }catch(DMLException e ){
             System.debug(e.getMessage());
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

}