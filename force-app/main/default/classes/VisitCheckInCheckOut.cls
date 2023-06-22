public class VisitCheckInCheckOut {

    public string VisitId {get;set;}
    public string typeVisit {get;set;}
    public string lat {get;set;}
    public string lon {get;set;}
    public boolean ShowMap {get;set;}
    public string isOwner {get;set;}
    public string errorText {get;set;}

    public VisitCheckInCheckOut(ApexPages.standardController sc)
    {
        ShowMap=false;
        VisitId = ApexPages.CurrentPage().getParameters().get('id');
        typeVisit = ApexPages.CurrentPage().getParameters().get('typeVisit');
        lat = ApexPages.CurrentPage().getParameters().get('lat');
        lon = ApexPages.CurrentPage().getParameters().get('lon');
        
        isOwner = 'no';
        errorText = Status_Code__c.GetValues('7011').Status_Message__c;
        string visitOwner = [select ownerId from call_report__c where id =: visitId].ownerId;
        if (visitOwner == userinfo.getuserId())
            isOwner = 'yes';
    }
    
    public pageReference RedirectCheckInOut()
    {
        system.debug(VisitId);
        system.debug(typeVisit);
        system.debug(lat);
        system.debug(lon);
        
        if (typeVisit == 'in')
        {
            PageReference result = Page.VisitCheckIn;
            result.getParameters().put('typeVisit',typeVisit);
            result.getParameters().put('id',VisitId);
            result.getParameters().put('lat',lat);
            result.getParameters().put('lon',lon);
            result.setRedirect(true); 
            return result;
        }else{
            PageReference result = Page.VisitCheckOut;
            result.getParameters().put('typeVisit',typeVisit);
            result.getParameters().put('id',VisitId);
            result.getParameters().put('lat',lat);
            result.getParameters().put('lon',lon);
            result.setRedirect(true); 
            return result;
        }
    }
    
    public pageReference BackPage()
    {
        PageReference result = new PageReference('/'+VisitId);
        result.setRedirect(true);
        return result;
    }
    
    public void CheckIn()
    {
        Call_Report__c VisitObj = [select id,Check_in_Location__c,Check_in_Location__latitude__s,Check_in_Location__longitude__s,
                                   Actual_Check_in_Time__c,Actual_Check_out_Time__c, Actual_Visit_Date__c
                                   from Call_Report__c where id =: VisitId];
        
        system.debug(VisitObj);
        
        string textMsg = '';
        if (VisitObj.Check_in_Location__c != null)
        {
            textMsg = 'This Visit Plan has already been checked in';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, textMsg);
            ApexPages.addmessage(myMsg);
        }else{
            ShowMap=true;
            DateTime myDateTime = datetime.now();
            Date myDate = myDateTime.date();
            
            try {
                VisitObj.Check_in_Location__latitude__s = decimal.valueof(lat);
                VisitObj.Check_in_Location__longitude__s = decimal.valueof(lon);
                VisitObj.Actual_Check_in_Time__c = datetime.now();
                VisitObj.Actual_Visit_Date__c = date.today();
                
                system.debug(VisitObj);
                update VisitObj;
                
                textMsg = 'Check in Success - You have already Check in at '+string.valueof(mydate).substring(0,10)+
                          ' time '+string.valueof(myDateTime.time()).substring(0,8);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, textMsg);
                ApexPages.addmessage(myMsg);
            }catch(exception ex){
                system.debug(ex);
            }

            
        }
        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, textMsg);
        //ApexPages.addmessage(myMsg);
    }
    
    public void CheckOut()
    {
        Call_Report__c VisitObj = [select id,Check_in_Location__c,Check_in_Location__latitude__s,Check_in_Location__longitude__s,
                                   Actual_Check_in_Time__c,Actual_Check_out_Time__c
                                   from Call_Report__c where id =: VisitId];
        system.debug(VisitObj);
        
        string textMsg = '';
        if (VisitObj.Check_in_Location__c == null)
        {
            textMsg = 'Check out Error - You cannot check out the Visit Plan because it hasn\'t been checked in yet.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, textMsg);
            ApexPages.addmessage(myMsg);
        }else if (VisitObj.Actual_Check_out_Time__c != null){
            textMsg = 'This Visit Plan has already been checked out';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, textMsg);
            ApexPages.addmessage(myMsg);
        }else{
            
            DateTime myDateTime = datetime.now();
            Date myDate = myDateTime.date();
            
            try {
                VisitObj.Actual_Check_out_Time__c = datetime.now();
                
                system.debug(VisitObj);
                update VisitObj;
                
                textMsg = 'Check out Success - You have already Check out at '+string.valueof(mydate).substring(0,10)+
                          ' time '+string.valueof(myDateTime.time()).substring(0,8);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, textMsg);
                ApexPages.addmessage(myMsg);
            }catch(exception ex){
                system.debug(ex);
            }

            
        }
        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, textMsg);
        //ApexPages.addmessage(myMsg);
    }
    

}