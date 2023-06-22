public class OpportunityController {
    public Opportunity opp {get;set;}
    public Call_Report__c Callreport {get;set;}
    public String RecordtypeID {get;set;}
    public String VisitplanID {get;set;} 
    // public String AccountID; 
    ApexPages.StandardController controller;
    public OpportunityController(ApexPages.StandardController controller){
        this.controller = controller;
        opp = (Opportunity) Controller.getRecord();
      RecordTypeID =   ApexPages.currentPage().getParameters().get('recordType');
      VisitplanID =   ApexPages.currentPage().getParameters().get('visitPlanID');
        RecordType rts = [SELECT ID, name FROM RecordType 
                                    WHERE SObjectType = 'Opportunity'
                                     AND ID =: RecordTypeID LIMIT 1];
        Callreport  =   [SELECT Customer_name__c ,ID FROM  Call_Report__c WHERE ID =:VisitPlanID LIMIT 1];
        opp.RecordTypeId =  rts.id;
        opp.AccountId = Callreport.Customer_name__c;
        opp.OwnerId = Userinfo.getUserId();
        opp.StageName ='Analysis';
        opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
    }
    
    
    
        //   
        public PageReference save(){ 
            if(VisitplanID.length() ==0 || VisitPlanID =='' || VisitPlanID ==null){
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'cannot retrieving visit plan id')); 
            }
            try{
                /*User currentuser = [SELECT ID,Employee_ID__c FROM User WHERE ID =: Userinfo.getUserID() LIMIT 1];
        
                if(currentuser.Employee_ID__c ==null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User does not have Employee ID.'));
                    return null;
                }else if(currentuser.Employee_ID__c !=null){*/
                    insert opp;
                        
                    Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c ();
                     visitopp.Customer__c = VisitplanID;
                     visitopp.Opportunity__c = opp.id;
                        
                        insert visitopp;
                    PageReference opppage = new ApexPages.StandardController(opp).view();
                    opppage.setRedirect(true);
                    return opppage;
                //}
            }catch(DMLException E){
                    string errormessage = e.getMessage().split(',').get(1).replace(': []','');
                    if(!errormessage.containsIgnoreCase('Permission Invalid') && !errormessage.containsIgnoreCase('Incorrect Opportunity Stage')
                        && !errormessage.containsIgnoreCase('Complete Date'))
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errormessage));
                    System.debug(e.getMessage());
                }
            return null;
        }
    
        public PageReference cancel(){
            
            PageReference pageRef = new PageReference('/'+VisitplanID);
            pageREf.setRedirect(true);

            
            return pageRef;
        }

        @AuraEnabled
        public static Opportunity getOppRec(string RecordTypeID,string VisitPlanID){
            System.debug('RecordTypeID '+RecordTypeID);
            System.debug('VisitPlanID '+VisitPlanID);
            Opportunity oppRec = new Opportunity();
            RecordType rts = [SELECT id, name FROM RecordType WHERE SObjectType = 'Opportunity' AND id =:RecordTypeID LIMIT 1];
            System.debug('rts '+rts);
            Call_Report__c tempCallreport  =   [SELECT Customer_name__c ,ID FROM  Call_Report__c WHERE id =:VisitPlanID LIMIT 1];
            System.debug('tempCallreport '+tempCallreport.Customer_name__c);
            oppRec.RecordTypeId =  rts.id;
            oppRec.AccountId = tempCallreport.Customer_name__c;
            oppRec.OwnerId = Userinfo.getUserId();
            oppRec.StageName ='Analysis';
            oppRec.Expected_submit_date__c = System.today();
            oppRec.CloseDate = System.today();
            return oppRec;
        }

        @AuraEnabled
        public static void insertToVisitPlan(string oppRecID,string VisitPlanID){
            Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c ();
            
            System.debug('oppRecID :: '+oppRecID);
            visitopp.Customer__c = VisitplanID;
            visitopp.Opportunity__c = oppRecID;
            System.debug('visitopp'+visitopp);
            insert visitopp;
        }
            
}