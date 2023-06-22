public class OpportunityRecordTypeSelection {
    public Opportunity opp {get;set;}
    public String planid;
    ApexPages.StandardController controller;
    public OpportunityRecordTypeSelection(ApexPages.StandardController controller){
        this.controller = controller;
        opp = (Opportunity) Controller.getRecord();
        planid = ApexPages.currentPage().getParameters().get('visitplanID');
    }
    
    public PageReference next(){
        
        PageReference OppCreationPage = Page.OpportunityCreation;
        OppCreationPage.setRedirect(true);
        OppCreationPage.getParameters().put('recordtype',opp.RecordTypeID);
        OppCreationPage.getParameters().put('visitplanID',planid);
        System.debug('NEXT BUTTON : '+opp.RecordTypeID);
        return OppCreationPage;
         
    }
    
    public PageReference cancel(){
            
            PageReference pageRef = new PageReference('/'+planid);
            pageREf.setRedirect(true);

            
            return pageRef;
        }

}