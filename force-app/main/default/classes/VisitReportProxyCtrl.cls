public class VisitReportProxyCtrl {
    
private final ApexPages.StandardController std ;
    private final Visit_Report__c visit; 
    public Visit_Report__c visit_tmp; 
    public string visitplan{get;set;}
    public id planId{get;set;}
    public id planIdFromLead{get;set;}
    public string checkvisitplan{get;set;}
    public boolean checkprefill {get;set;}
    public boolean isCreateSuccess {get;set;}
    public string str_action {get;set;}
    public string callReportId {get;set;}
    public string backId {get;set;}
    public static Visit_Report__c editrecord {get;set;}

    public VisitReportProxyCtrl(ApexPages.StandardController controller){
        str_action = '';
        backId = '';
        std = controller;
        visit = (Visit_Report__c)std.getRecord();
        visit_report__c tmpVisit = (Visit_Report__c)std.getRecord();
        if (tmpVisit.Id != null) {
            visit_tmp = [select Id,Visit_Plan_Report__c from Visit_Report__c where Id =: tmpVisit.Id];
            str_action = 'Edit';
            backId = visit_tmp.Id;
            editrecord = [select Visit_Plan_Report__c from Visit_Report__c where Id =: tmpVisit.Id];
        } else {
            visit_tmp = new Visit_Report__c();
            str_action = 'New';
            callReportId = apexpages.currentpage().getparameters().get('planId');
            backId = callReportId;

            if(callReportId == null){
                callReportId = Apexpages.currentPage().getUrl().substringBetween('_lkid=','&');
            }
            planIdFromLead = Apexpages.currentPage().getUrl().substringBetween('_lkid=','&');
        }
        redirectLightning();
    }
    // Desktop
    public PageReference redirectPage(){      
        string visitplan = apexpages.currentpage().getparameters().get('visitplanId');
        id planId = apexpages.currentpage().getparameters().get('planId');
        planIdFromLead = Apexpages.currentPage().getUrl().substringBetween('_lkid=','&');
        string planFromLead;
        if (planId == null){
            planFromLead = [select Name from Call_Report__c where Id =: planIdFromLead].Name;
            system.debug('null ' + planIdFromLead );
            planId = planIdFromLead;
        }
        system.debug(':::: visitplan = ' + visitplan );
        system.debug(':::: Visit_Report__c Id  = ' + visit.Id);
        System.debug(apexpages.currentpage());
        string url = '/apex/VisitreportCreation';
        if(visit.id!=null){
            url += '?id='+visit.id;
        }
        if(visitplan != null){
            url += '?visitplan='+visitplan+'&planId='+planId;
        }
        else{
            url += '?visitplan='+planFromLead+'&planId='+planId;
        }
  
        system.debug(':::: url  = ' + url);        
        PageReference page = new PageReference(url); 
        page.setRedirect(true); 
        return page; 
    }
    // Mobile
    public PageReference redirectMobile(){
        string visitplan = apexpages.currentpage().getparameters().get('visitplanId');
        id planId = apexpages.currentpage().getparameters().get('planId');
        string url = '/apex/VisitreportCreationMobile';
        planIdFromLead = Apexpages.currentPage().getUrl().substringBetween('_lkid=','&');
        string planFromLead; 
        if (planId == null){
            planFromLead = [select Name from Call_Report__c where Id =: planIdFromLead].Name;
            system.debug('null ' + planIdFromLead );
            planId = planIdFromLead;
        }
        if(visit.id!=null){
            url += '?id='+visit.id;
        }
        if(visitplan != null){
            url += '?visitplan='+visitplan+'&planId='+planId;
        }
        else{
            url += '?visitplan='+planFromLead+'&planId='+planId;
        }
        PageReference page = new PageReference(url); 
        page.setRedirect(true); 
        return page; 
    }
    
    //Rendered
    public void lookupfields(){
        string checkvisitplan = apexpages.currentpage().getparameters().get('visitplan');
        
        if(checkvisitplan != null){
            checkprefill = true;
        }
        system.debug('##checkvisitplan = '+checkvisitplan);
        system.debug('##checkprefill = '+checkprefill);
    }
    
    
    public PageReference saveSF1(){ 
            isCreateSuccess=true;
        try{
            if (str_action == 'New')
                insert visit;
            else if (str_action == 'Edit')
                update visit;
 
        }catch(DMLException e){
            system.debug(e.getMessage());
            isCreateSuccess=false;
            return null;
        }
        system.debug('isCreateSuccess = '+isCreateSuccess);
        system.debug('visit = '+visit);
        return null;
        
    }
    
    /*public PageReference Save() {
        try {
        Visit_Report__c vi = new Visit_Report__c();   
        insert visit;
        }
        catch(Exception e) {
        return null;
 	    }
        pagereference pr = new pagereference('/' + visit.id);
  		return pr;
    }*/


    public boolean getCheckAuthorize()
    {
        boolean validate = false;    
        system.debug(callReportId);
        system.debug(str_action); 
        if (str_action == 'New') {

            Call_Report__c callReport = [select Id,Customer_name__c,OwnerId 
                                         from Call_Report__c 
                                         where Id =: callReportId];
            system.debug(str_action);

            List<UserRecordAccess> accessList = [SELECT RecordId, 
                HasAllAccess,HasEditAccess, HasReadAccess  
                FROM UserRecordAccess 
                WHERE UserId =: Userinfo.getUserId()
                AND RecordId =: callReport.Id];

            if (accessList.size() > 0) {
                if (accessList.get(0).HasEditAccess) {
                    validate = true;
                }
            } 

            for (Visit_Plan_Invitee__c vpi : [select Id,Visit_Plan_Report__c,TMB_Person__c 
                                              from Visit_Plan_Invitee__c
                                              where Visit_Plan_Report__c =: callReport.Id 
                                              and TMB_Person__c =: Userinfo.getUserId()])
            {
                validate = true;
            }

        } else if (str_action == 'Edit') {

            List<UserRecordAccess> accessList = [SELECT RecordId, 
                HasAllAccess,HasEditAccess, HasReadAccess  
                FROM UserRecordAccess 
                WHERE UserId =: Userinfo.getUserId()
                AND RecordId =: visit_tmp.Id];

            if (accessList.size() > 0) {
                if (accessList.get(0).HasEditAccess) {
                    validate = true;
                }
            } 

        }

        if (!validate) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Insufficient Privileges'));
        }

        return validate;
    }

    public pageReference goBack()
    {
        PageReference page = new PageReference('/'+backId); 
        page.setRedirect(true); 
        return page; 
    }

    public void redirectLightning(){
        visitplan = apexpages.currentpage().getparameters().get('visitplanId');
        planId = apexpages.currentpage().getparameters().get('planId');
    }

    @AuraEnabled
    public static Visit_Report__c getVisitReport(Id editId){
        editRecord = [SELECT Id, Visit_Plan_Report__c,Business_Talk_Opportunity__c,Additional_Comments__c FROM Visit_Report__c  WHERE Id =:editId];
        return editRecord;

    }
}