public class Opportunity_NBO_Controller {
    public Opportunity opp {get;set;}
    public Call_Report__c Callreport {get;set;}
    public String VisitplanID,AccountID;
    public String recordtypeID {get;set;}
    public String newOpportunityID {get;set;}
    public boolean continueStep {get;set;}
    public boolean Expired {get;set;}
    public boolean IsCreatable {get;set;}
    public boolean isMobile { get; set; }
    public boolean isSaveSuccess {get{
        if(isSaveSuccess==null){
            isSaveSuccess=false;
        }
        return isSaveSuccess;
    }set;}
    private ApexPages.StandardSetController standardController;

    public Opportunity_NBO_Controller(ApexPages.StandardSetController standardController){

        System.debug('Opportunity_NBO_Controller start'+Account.SObjectType.getDescribe().getRecordTypeInfos());
        this.standardController = standardController;
        Opportunity newOpp = new Opportunity();
		opp = setDefaultValue(newOpp);
        
		isSaveSuccess = false;
        isMobile = UserInfo.getUiTheme() == 'Theme4t';

        IsCreatable = Schema.SObjectType.Opportunity.createable;
        if(!IsCreatable){
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You not have permission to create new oppurtunity!'));
        }
    }

    public Opportunity setDefaultValue(Opportunity tempOpp){

        VisitplanID =   ApexPages.currentPage().getParameters().get('id');
        Product_Campaign_Recommend__c NBO  =   [SELECT AccountAccount__c, Product_name__c ,ID, Name, Status__c FROM  Product_Campaign_Recommend__c WHERE ID =:VisitPlanID LIMIT 1 ];

        System.debug('VisitplanID = '+ VisitplanID);
        Expired = false;
        if(NBO.Status__c == 'Expired'){
            Expired = true;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Commercial NBO date already expired.'));
        }

        tempOpp.AccountId = NBO.AccountAccount__c;
        tempOpp.product_campaign_recommend__c = NBO.ID;
        tempOpp.OwnerId = Userinfo.getUserId();
        tempOpp.StageName ='Analysis';
        //tempOpp.Expected_submit_date__c = System.today();
        //tempOpp.CloseDate = System.today();
        tempOpp.LeadSource = 'NBO';

        return tempOpp;
    }
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> recordTypesOption = new List<SelectOption>();
        //List<Bank__c> bankListitem = [SELECT Id,Name FROM Bank__c];
        List<RecordType> ListRecordTypes = [SELECT ID, Name FROM RecordType WHERE SObjectType = 'Opportunity'];
        //recordTypesOption.add(new SelectOption('','Select one...'));
        Id othersId;
        String othersName;
        for(RecordTypeInfo info: Schema.SObjectType.Opportunity.getRecordTypeInfos()) {
        	if(info.isAvailable() && info.getName() != 'Master') {
            	recordTypesOption.add(new SelectOption(info.getRecordTypeId(), info.getName()));

                if(info.isDefaultRecordTypeMapping()){
                    recordTypeId = info.getRecordTypeId();
                }
        	}
    	}
        return recordTypesOption;
    }

       public PageReference continueRecordType(){
           try{
               	if(recordtypeID =='' || recordtypeID ==null){
               		ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'please select RecordType.'));
                }else{
                    continueStep = true;
               		opp.RecordTypeId =  recordtypeID;
                }
           }catch(DMLException E){
                    string errormessage = e.getMessage().split(',').get(1).replace(': []','');
                    if(!errormessage.containsIgnoreCase('Permission Invalid') && !errormessage.containsIgnoreCase('Incorrect Opportunity Stage')
                        && !errormessage.containsIgnoreCase('Complete Date'))
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    System.debug(e.getMessage());
           }
           return null;
       }

    	public PageReference viewOpportunity(){
                    PageReference NBOpage = new ApexPages.StandardController(opp).view();
                    //PageReference NBOpage = new PageReference('/'+opp.Id+'?sfdc.tabName=Name'+opp.Name);
                    NBOpage.setRedirect(true);
                    return NBOpage;                
        }
    
        public PageReference save(){
            // if(isMobile){
            //     String submit_date = Apexpages.currentPage().getParameters().get('submit_date');
            //     String CloseDate = Apexpages.currentPage().getParameters().get('CloseDate');
            //     try{
            //         opp.Expected_submit_date__c=Date.valueOf(submit_date);
            //         opp.CloseDate=Date.valueOf(CloseDate);
            //     }catch(Exception E){
            //         System.debug(E);
            //     }
            // }
            
            if(opp.Expected_submit_date__c == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Expected Submit Date'));
            }

            if(opp.CloseDate == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Expected Complete Date'));
            }
            try{
                if(saveOpp()){
                    isSaveSuccess = true;
                    PageReference NBOpage = new ApexPages.StandardController(opp).view();
                    //PageReference NBOpage = new PageReference('/'+opp.Id+'?sfdc.tabName=Name'+opp.Name);
                    NBOpage.setRedirect(true);
                    
            System.debug('NBOpage:::'+NBOpage);
                    return NBOpage;
                }
            }catch(Exception E){
                System.debug(e.getMessage());
            }
            return null;
        }

        public PageReference saveAndNew(){
            // if(isMobile){
            //     String submit_date = Apexpages.currentPage().getParameters().get('submit_date');
            //     String CloseDate = Apexpages.currentPage().getParameters().get('CloseDate');
            //     try{
            //         opp.Expected_submit_date__c=Date.valueOf(submit_date);
            //         opp.CloseDate=Date.valueOf(CloseDate);
            //     }catch(Exception E){
            //         System.debug(E);
            //     }
            // }
            if(opp.Expected_submit_date__c == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Expected Submit Date'));
            }

            if(opp.CloseDate == null){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Expected Complete Date'));
            }

            try{
                if(saveOpp()){
                    back();
                }
            }catch(Exception E){

            }
            return null;
        }
    
        public boolean saveOpp(){
            try{
                User currentuser = [SELECT ID,Employee_ID__c FROM User WHERE ID =: Userinfo.getUserID() LIMIT 1];

                if(currentuser.Employee_ID__c ==null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User does not have Employee ID.'));
                    return false;
                }else if(currentuser.Employee_ID__c !=null){
                    insert opp;
                    newOpportunityID = opp.ID;
                    isSaveSuccess = true;
                    return true;
                }
            }catch(DMLException E){
                    string errormessage = e.getMessage().split(',').get(1).replace(': []','');
                    if(!errormessage.containsIgnoreCase('Permission Invalid') && !errormessage.containsIgnoreCase('Incorrect Opportunity Stage')
                        && !errormessage.containsIgnoreCase('Complete Date'))
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errormessage));
                    System.debug(e.getMessage());
                }
            return false;
        }

    	public PageReference back(){
            
            Opportunity newOpp = new Opportunity();
            opp = setDefaultValue(newOpp);
            continueStep = false;
            System.debug('continueStep::'+continueStep);
            return null;
        }
        public PageReference cancel(){
            PageReference pageRef = new PageReference('/'+VisitplanID);
            pageREf.setRedirect(true);


            return pageRef;
        }

}