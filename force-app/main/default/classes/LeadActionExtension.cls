public class LeadActionExtension {

    public string action {get{if(action==null){return displayAction();}else return action;}set;}
    public lead tempLead {get;set;}
    public boolean clicksave {get;set;}
    public string act {get;set;}
    public string descriptionPage {get;set;}
    public string buttonValue {get;set;}
    public boolean isPass {get;set;}
    public boolean isReassign {get;set;}
    public boolean isFailedPreScreening {get;set;}
    public boolean isbyPassDuplicateCheck {get;set;}
    public boolean isDuplicated {get;set;}
    public Boolean isCancel {get;set;}
    public LeadActionExtension(Apexpages.StandardController sc)
    {
        lead objLead = (lead)sc.getRecord();
        tempLead = [select id, Pre_screening_Result__c, Unqualified_Reasons__c, Remark__c
                           , name, company
                           , Status
                           , Unqualified_Action__c 
                           , Unqualified_Rejected_List__c
                           , Sub_Unqualified_Reason__c
                           , Customer_Type__c, Suggested_Segment__c, Suggested_Team__c, Suggested_Person__c
                           , recordtypeid, account__r.ownerid
                           , Mobile_No__c, Office_No__c
                           , recordtype.name
                    	   , isBypassDuplicateCheck__c, Other_Reason__c
                           , Lead_Segment__c
                           , Referral_Staff_ID__c
                           , Referral_Staff_Name__c
                   from lead where id =: objLead.id];
        clicksave = false;
        act = ApexPages.currentPage().getParameters().get('action');
        descriptionPage = '';
        buttonValue = '';
        if (tempLead.Pre_screening_Result__c == 'Passed') isPass = true; else isPass = false;
        isbyPassDuplicateCheck = tempLead.isBypassDuplicateCheck__c;
        isReassign = false;
        isFailedPreScreening = false;
		isDuplicated= false;
        
        if(isByPassDuplicateCheck && !isPass){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Status_Code__c.GetValues('6112').Status_Message__c));
  
        }
        isCancel = false;
    }
    
    
    public void checkDupAction()
    {

        String mode = Apexpages.currentPage().getParameters().get('mode');

        tempLead.isBypassDuplicateCheck__c = false;
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(tempLead);
        LeadExtensionV2 LeadEx = new LeadExtensionV2(controllerinsert);
        if(mode != null ){
           if(mode == '1'){
               LeadEx.doActionMobile();
           }else{
               LeadEx.doAction();
           }           
        }else{
            LeadEx.doAction();
        }
        
        System.debug('LeadEx.isDisqualified: '+LeadEx.isDisqualified);
        
        if(LeadEx.isDisqualified){
			isDuplicated =true;
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c)); 
             
        }else{
            isByPassDuplicateCheck = false;
           
        }
        
        
    }
    
    public string displayAction()
    {
        string result = '';
        descriptionPage = '';
        
        String pre ='';
        pre = ApexPages.currentPage().getParameters().get('prescreen');
        
        if (act != null){
            if (act.toLowerCase() == 'prescreen'){
                result = 'Pre-Screen';
                buttonValue = 'Save';
                if(tempLead.Lead_Segment__c == 'SE'){
                    tempLead.Unqualified_Action__c = 'For SE Failed Prescreening';   
                }
                else
                {
                    tempLead.Unqualified_Action__c = 'For Failed Prescreening';
                }
                if(pre == '1')
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, status_code__c.getValues('6100').status_message__c)); 
                }
            }
            else if (act.toLowerCase() == 'reassign'){
                result = 'Reassign';
                buttonValue = 'Reassign';     
                descriptionPage += 'If you reassign lead, system will reassign lead to system-determined user or queue';   
            }
            else if (act.toLowerCase() == 'reject'){
                result = 'Reject';
                buttonValue = 'Reject';        
            }
            else if (act.toLowerCase() == 'notinterest'){
                result = 'Not Interested';
                buttonValue = 'Not Interested';        
            }
        }else{
            descriptionPage = 'If you reject lead, it will be reassign to previous owner / queue. ';
            descriptionPage += 'If you reassign lead, system will reassign lead to system-determined user or queue';
        }
        return result;
    }
    
    public void selectAction()
    {
        action=null;
    }
    
    public pageReference backtoListview()
    {
        PageReference ref = new PageReference('/00Q');
        ref.setRedirect(true);
        return ref;
    }
    
    public pageReference saveDesktop()
    {
        if (!actSave())
        {
            PageReference redirectSuccess = new ApexPages.StandardController(tempLead).view();
            
            if (act.toLowerCase() == 'reassign')
            {
                isReassign = true;
                return null;
            }else
                isCancel = true;
                return null;
                // return (redirectSuccess);
        }else
            return null;
    }
    public void saveMobile()
    {
        if (!actSave())
        {
            if (act.toLowerCase() == 'reassign')
            {
                isReassign = true;
                clicksave = true;
            }else
                isCancel = true;
                clicksave = true;
        }       
    }
    
    
    public boolean actSave()
    {   
        boolean error = true;
        User user = [SELECT Id,Name,Employee_ID__c FROM User WHERE Id= :UserInfo.getUserId() LIMIT 1];
        if(act.toLowerCase() == 'prescreen')
        {
            if(tempLead.Pre_screening_Result__c == 'Failed')
            {
                if(tempLead.Unqualified_Action__c  == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6101').status_message__c));
                }else if(tempLead.Unqualified_Reasons__c == null){
                    //tempLead.Unqualified_Action__c = 'For Failed Prescreening';
                    system.debug('tempLead.Unqualified_Action__c='+tempLead.Unqualified_Action__c);
                    tempLead.Unqualified_Action__c = 'For Failed Prescreening';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6102').status_message__c));
                }else if(tempLead.Unqualified_Reasons__c == 'Credit issue' && tempLead.Sub_Unqualified_Reason__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6103').status_message__c));
                }else {
                    tempLead.Status = 'Failed Prescreening'; 
                    tempLead.RecordTypeId = [select id from recordtype where name = 'Commercial Completed'].get(0).id;
                    error = false;
                }
                
                if(tempLead.Account__c !=null){
                    List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c
                                                          FROM Call_report__c 
                                                          WHERE Lead__c =: tempLead.id];                   
                    if(VisitPlanList.size()>0){
                        for(Call_report__c visit : VisitPlanList){
                            visit.Customer_name__c = tempLead.Account__c;
                        }    
                        update VisitPlanList;
                    }  
                }
            }
            else if(tempLead.Pre_screening_Result__c == 'Passed')
            {
                if(tempLead.Unqualified_Reasons__c != null || tempLead.Sub_Unqualified_Reason__c != null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6104').status_message__c));  
                }else if(tempLead.Status == 'Contacted') {
                    error = false;
                }else {
                    tempLead.Status = 'Passed Prescreening';
                    error = false;
                }
            }
        }else if(act.toLowerCase() == 'reassign'){
            
            integer cntRecProduct = [select count() from product_interest__c where lead__c =: tempLead.id];
            boolean checkConitionFalse = false;
            string recordtypename = tempLead.recordtype.name;
            string errorText = '';
           
            if (recordtypename == 'Commercial Account' && (cntRecProduct < 1 || tempLead.Suggested_Person__c == null))
            {
                checkConitionFalse = true;
                errorText = status_code__c.getValues('6108').status_message__c;
                
            }else if (recordtypename == 'Commercial Lead'){
             
                if (tempLead.Suggested_Team__c == null){
                    checkConitionFalse = true;
                    errorText = status_code__c.getValues('6105').status_message__c;
                    errorText += status_code__c.getValues('6110').status_message__c;
                }else if (cntRecProduct < 1){
                    checkConitionFalse = true;
                    errorText = status_code__c.getValues('6108').status_message__c;
                }else if (tempLead.Mobile_No__c == null && tempLead.Office_No__c == null){
                    checkConitionFalse = true;
                    errorText = status_code__c.getValues('6109').status_message__c;
                }
            
            }

            if (checkConitionFalse){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorText));
            } else {
                if (recordtypename == 'Commercial Account') 
                {
                    tempLead.ownerid = tempLead.Account__r.ownerid;
                    if(tempLead.Referral_Staff_ID__c == null && tempLead.Referral_Staff_Name__c == null){
                        tempLead.Referral_Staff_ID__c = user.Employee_ID__c;
                        tempLead.Referral_Staff_Name__c = user.Name;
                        
                    }
                    
                    error = false;
                }
                else if (recordtypename == 'Commercial Lead') 
                {
                    list<group> listAllgroup = [select id from group where type = 'Queue' and name =: tempLead.Suggested_Team__c];
     
                    if (listAllgroup.size() > 1)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6106').status_message__c));
                    }else if (listAllgroup.size() == 0){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,status_code__c.getValues('6107').status_message__c));
                    }else{
                        tempLead.ownerid = listAllgroup.get(0).id;
                        System.debug(tempLead.Referral_Staff_ID__c);
                        System.debug(tempLead.Referral_Staff_Name__c);
                        if(tempLead.Referral_Staff_ID__c == null && tempLead.Referral_Staff_Name__c == null){
                            tempLead.Referral_Staff_ID__c = user.Employee_ID__c;
                            tempLead.Referral_Staff_Name__c = user.Name;
                        }
                        error = false;
                    }
                }
            }
        }
        system.debug('error='+error);
        if (!error)   
        {      
            try {
                update tempLead;
            }catch(DMLException ex){
                error = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getDmlMessage(0)));
            }catch(exception ex){
                error = true;
              //  system.debug(ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }
        }
        return error;
    }
    
    public pageReference PreScreenResultChange(){
        system.debug('tempLead.Pre_screening_Result__c='+tempLead.Pre_screening_Result__c);
        
        if(tempLead.Pre_screening_Result__c == 'Failed'){
            isFailedPreScreening = true;
        }else{
            isFailedPreScreening = false;            
        }
        tempLead.Unqualified_Action__c = 'For Not Interested';
        tempLead.Unqualified_Reasons__c = null;
        tempLead.Sub_Unqualified_Reason__c = null;
        
        return null;
    }
    
    //Fixed: 2018Jan
    public void preScreenAction(){        
        string valPreScreenResult = apexpages.currentPage().getParameters().get('inpPreScreenResult');
        system.debug('val preScreenResult ==== '+valPreScreenResult);
        tempLead.Pre_screening_Result__c = valPreScreenResult;
        
        system.debug('tempLead.Pre_screening_Result__c='+tempLead.Pre_screening_Result__c);
        
        if(tempLead.Pre_screening_Result__c == 'Failed'){
            isFailedPreScreening = true;
        }else{
            isFailedPreScreening = false;            
        }
        tempLead.Unqualified_Action__c = 'For Not Interested';
        tempLead.Unqualified_Reasons__c = null;
        tempLead.Sub_Unqualified_Reason__c = null;        
    }

}