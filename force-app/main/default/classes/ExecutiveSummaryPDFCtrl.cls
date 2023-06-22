/**********************************************************************
* Project           : Account Plan 5.2
* Author            : Jittramas Kumpeepong / jtk@ii.co.th
* Date created      : 2016-10-10
* Purpose           : To view PDF and Save PDF to Attachment compatible with desktop,SF1,console
*
* Revision History  :
* Date        Author      Ref    Revision Desrciption
* 2010-10-28  JK            1    First Drop.
*
/**********************************************************************/
public class ExecutiveSummaryPDFCtrl {
    public ApexPages.StandardController ctrl;
    public User user {get;set;}
    public String theUserId {get;set;}
    public String ExecutiveSummaryID {get;set;}
    public Id parentId {get;set;}
    public Attachment a {get;set;}
    public Boolean isSF1 {get;set;}
    public Boolean isDone {get;set;}
    public Executive_Summary__c ExecutiveSummary {get;set;}
    public List<AcctPlanActivity__c> actionactivityList {get;set;}
    public Map<Decimal,List<AcctPlanNIProject__c>> acctPlanNIProjectMap {get;set;}
    public string pdfID {get;set;}
    
    public ExecutiveSummaryPDFCtrl(ApexPages.StandardController controller){
        theUserId = UserInfo.getUserId();
        user = [SELECT Id,Name,SmallPhotoUrl, fullphotourl  FROM User WHERE User.ID = :theUserId LIMIT 1];
        ExecutiveSummaryID = ApexPages.currentPage().getParameters().get('ID');
        parentId = ExecutiveSummaryID;
        isSF1 = isSF1();
        isDone = false;
        pdfID = '';
        // get Executive Summary
        if(ExecutiveSummaryID != null && ExecutiveSummaryID != ''){
            List<Executive_Summary__c> ExecutiveSummaryList = AccountPlanUtilities.QueryExecutiveSummaryByID(ExecutiveSummaryID);
            if(ExecutiveSummaryList.size()>0){
                ExecutiveSummary = ExecutiveSummaryList.get(0);
            }
        }
    }
    
    /*** Check SF1 ***/
    public Boolean isSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) &&
        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) &&
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ){
            isSF1 = true;
        }else{
            isSF1 = false;
        }
        system.debug('## isSF1 : '+isSF1);
        return isSF1;
    }

    /*** Open PDF and Save PDF on Attachment behide the scene. ***/
    public PageReference SavePDF(){
        string page= '/apex/ExecutiveSummaryPDF?id='+parentId;
        PageReference pg = new PageReference(page);
        Blob pdf;
        try{
                pdf = pg.getContent();                
            }catch(VisualforceException ve){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR:', ve.getMessage()));
                system.debug('## ve error :'+ve.getMessage());
            }

         attachmentToDelete(parentId);
         a = new Attachment();
                      a.Body = pdf;
                      a.ParentID = parentId;        
                      a.Name = 'ExecutiveSummary_'+system.now().format('dd-MM-yyyy_(HH.mm.ss)')+'.pdf';
                      a.IsPrivate = false;
                      a.ContentType = 'application/pdf';
                      try{
                        insert a;
                        isDone = true;
                        }catch(Exception e){
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR:', e.getMessage()));
                            system.debug('## e error :'+e.getMessage());
                        }  
        
        if(isSF1){
            // on mobile redirect to file PDF
            //return new PageReference('/'+a.Id);
            pdfID = a.Id;
        }
        else{
            // on desktop redirect to VF page that renderAS = PDF
            //pg.setRedirect(true);  
            return new PageReference('/apex/ExecutiveSummaryPDF?id='+parentId);
        }
        return null;
    }

    /*** Delete Attachment for keep only one Executive Summary PDF per Executive Summary ***/
    public void attachmentToDelete(Id parentId){
        List<Attachment> attachmentToDeleteList = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId =: parentId]); 
        system.debug('## attachmentToDeleteList : '+attachmentToDeleteList);
        if(attachmentToDeleteList.size() > 0){
            delete attachmentToDeleteList;
        }
    }



}