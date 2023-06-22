public with sharing class ClosedCaseLayoutExtension {
    public Case caseObj{get;set;}
    public String DMLEvents{get;set;}
    public String oldStatus{get;set;}
    public List<SelectOption> statusPicklist{get;set;}
    public Map<String,Closed_Case_Warning_Message__mdt> mapWarningMessage {get;set;}
    public Boolean checkedStatusNew {get;set;}
    public Boolean isAllowedEdit {get; set;}
    
    public ClosedCaseLayoutExtension(ApexPages.StandardController controller) {
        Map<String,Closed_Case_Warning_Message__mdt> mapWarning = new Map<String,Closed_Case_Warning_Message__mdt>();
        caseObj = (Case)controller.getRecord();
        caseObj.Status = 'Completed';
        isAllowedEdit = false;
        checkedStatusNew = false;
        try {
            UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = : UserInfo.getUserId()
                                                    AND RecordID = : caseObj.id
                                           ];
            Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c, Origin, Category__c FROM case WHERE ID = :caseObj.id];
            if ( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
                isAllowedEdit = true;
            } else {
                isAllowedEdit = false;
            }
            if (!isAllowedEdit){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
            }else {
                List<Closed_Case_Warning_Message__mdt> listWarningMessage = [SELECT Id,Category__c,Message__c,Status__c FROM Closed_Case_Warning_Message__mdt];
                if (listWarningMessage.size() > 0){
                    for (Closed_Case_Warning_Message__mdt objWarningMessage : listWarningMessage) {
                        mapWarning.put(objWarningMessage.Category__c+objWarningMessage.Status__c,objWarningMessage);
                    }
                    mapWarningMessage = mapWarning;
                }
            }
        } catch (Exception e) {
            System.Debug(e.getMessage());
        }
        statusPicklist = getPicklist();
    }

    public Pagereference validateCase(){
        System.debug(caseObj);
        System.debug(caseObj.Status);
        String keyword = caseObj.Category__c+caseObj.Status;
        Closed_Case_Warning_Message__mdt thisWarningMessage = new Closed_Case_Warning_Message__mdt();
        try {
            thisWarningMessage = mapWarningMessage.get(keyword);
            if (caseObj.Status == 'Completed' || caseObj.Status == 'Cancel'){
                if (thisWarningMessage != null && oldStatus != caseObj.Status){
                    checkedStatusNew = true;
                    oldStatus = caseObj.Status;
                    ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.WARNING, thisWarningMessage.Message__c));
                    return null;
                }
            }
            
        } catch (Exception e) {
            System.Debug(e.getMessage());
        }
        
        
        return updateCase();
    }

    public PageReference updateCase() {
        try {
            DMLEvents = 'update';
            checkedStatusNew = false;
            System.Debug('caseObj: '+caseObj);
            update caseObj;
            PageReference CasePage = new ApexPages.StandardController(caseObj).view();
            CasePage.setRedirect(true);
            return String.isNotEmpty(DMLEvents) && DMLEvents == 'insert' ? CasePage : (UserInfo.getUiThemeDisplayed() == 'Theme3' ? CasePage : null);

        } catch (Exception e) {
            System.Debug('ERROR : '+ e.getMessage());
            System.Debug('ERROR2 : '+ e.getStackTraceString());
            System.Debug('ERROR3 : '+ e.getdmlMessage(0));
            ApexPages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            return null;
        }
    }

    public List<SelectOption> getPicklist(){
        List<SelectOption> statusPicklist = new List<SelectOption>();
        List<CaseStatus> pickListValuesList = [Select Id, MasterLabel From CaseStatus Where IsClosed = true];
        statusPicklist.add(new SelectOption('','--None--'));
        for(CaseStatus c : pickListValuesList){
            statusPicklist.add(new SelectOption(c.MasterLabel,c.MasterLabel));
        }
        return statusPicklist;   
    }

    public PageReference cancelCase(){
        PageReference caseHome = new PageReference('/00Q/o');
        if(null != caseObj.id) {
          caseHome = new PageReference('/'+caseObj.id);
      }
  
        caseHome.setRedirect(true);
        return caseHome;
      }
}