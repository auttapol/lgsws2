public class EdittableActionPlanModel extends EditableList {
    //String parameter;
    public String ActionPlanID {get;set;}
    public String CompanyID {get;set;}
    public String AccountID {get;set;}
    public String Objective {get;set;}
    public String Status {get;set;}
    public Boolean isSelected{get;set;}
    public String jsScript {get;set;}
    public String StakeActId {get;set;}
    public String jsScriptPopup {get;set;}
    public boolean isSuccess {get;set;}

   public String msgTMBCounterparties {get;set;}
    public String alertTMBCounterparties {get;set;}
    
   
   public Map<Id,List<AcctPlanStakeholder__c>> StakeHolderMap {get{
        if(StakeHolderMap ==null){
            StakeHolderMap = new Map<Id,List<AcctPlanStakeholder__c>>();
        }
        return StakeHolderMap;
    }set;} 
   
    public EdittableActionPlanModel(ApexPages.StandardController stdController) {
    super(stdController);
    
    ActionPlanID = ApexPages.currentPage().getParameters().get('ActionPlanId');
    CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
    AccountID=ApexPages.currentPage().getParameters().get('AccountId');
    Objective = ApexPages.currentPage().getParameters().get('Objective');
    Status = ApexPages.currentPage().getParameters().get('Status');
     system.debug('Objective '+Objective );
     system.debug('Status '+Status );
     system.debug('ActionPlanID '+ActionPlanID );
   
      this.childList = [SELECT Id,
                          Activities__c ,
                          Account__c ,
                          Date__c,
                          CustomerCounterparties__c,
                          Group__c , 
                          CheckOther__c ,
                          Other__c,
                          Visit_Plan_Report__c,
                          TaskId__c,
                          Objective__c,
                          Status__c
                      FROM AcctPlanActivity__c  
                      WHERE AccountPlanActionPlanID__c  = : ActionPlanID ORDER BY Date__c ];  
                      
                      getStakeHolder(this.childList);  
        
                    jsScript= '<script>var listSize='+childList.size()+';</script>';

      msgTMBCounterparties =  Account_Plan_Status_Code__c.GetValues('5035').Status_Message__c;
      alertTMBCounterparties =  Account_Plan_Status_Code__c.GetValues('5036').Status_Message__c;
  }
  
  

  
  public void getStakeHolder(List<AcctPlanActivity__c> actionactivityList ){
       
        List<AcctPlanStakeholder__c> StakeholderList =  [select Id,User__c,User__r.Name,AcctPlanActivity__c  from AcctPlanStakeholder__c where AcctPlanActivity__c IN : actionactivityList ];

       for(AcctPlanActivity__c acti : actionactivityList){
                List<AcctPlanStakeholder__c> stakesList = new List <AcctPlanStakeholder__c>();
                StakeHolderMap.put(acti.id,stakesList);
            }
            //Put Users (Stakeholders) to map in each Action Activity
            for(AcctPlanStakeholder__c stake : StakeholderList){
              
                StakeHolderMap.get(stake.AcctPlanActivity__c).add(stake);
              
            }
            
         }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanActivity__c > getChildren()
  {
    return (List<AcctPlanActivity__c >)childList;
  }
    
  public override sObject initChildRecord()
  {

    system.debug(childList.size());

    AcctPlanActivity__c child = new AcctPlanActivity__c();
    system.debug('Objective2 '+Objective );
     system.debug('Status2 '+Status );
     system.debug('ActionPlanID2 '+ActionPlanID );
    // Can either use mysObject or acct here
    child.AccountPlanActionPlanID__c  = ActionPlanID;
    child.Objective__c  = Objective ;
    child.Status__c  = Status;    
    child.Account__c  = AccountID;
    system.debug('AccountID '+AccountID);
    //SoftSave 
    //child.Group__c = 'Group 1 : Relationship';
    //child.Activities__c = 'Event activity';    
    //child.Date__c = System.today();
    jsScript= '<script>var listSize='+childList.size()+';</script>';
    system.debug('jsScript '+jsScript);
      
    return child;
  }
    
    
       /* public void addChildToList()
        {
            
          childList.add(initChildRecord());
            
        }*/
  
    public void softsave(){
        //addToList();
        //super.save();
        //getStakeHolder(this.childList);  
        try{
            system.debug('##softsave##');
            ApexPages.getMessages().clear();
             boolean checkOther= true;
         
         for(AcctPlanActivity__c acti: (List<AcctPlanActivity__c>)childList){
         system.debug('acti.Other__c '+acti.Other__c);
         system.debug('acti.CheckOther__c '+acti.CheckOther__c);
         if(acti.CheckOther__c== 'Y' && acti.Other__c == null){
         checkOther= false;
         }
         
          }
            
            
            if(checkOther){

            super.save();
            getStakeHolder(this.childList);  
            isSuccess = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
            jsScriptPopup = '<script> openStake(\''+StakeActId+'\'); </script>';
            system.debug('jsScriptPopup '+jsScriptPopup);
            
                if(CompanyID!=null){
          //AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CompanyID);
         AcctPlanCompanyProfile__c companyprofile = [Select id,Status__c from AcctPlanCompanyProfile__c where id =: CompanyID ];
         companyprofile.Status__c = 'In Progress';
         update companyprofile;
                }
           }//checkOther
           else{
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please input Other Activity value.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5004').Status_Message__c));
           
           }
 
        }catch(Exception e){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
    }
    
    
    public void dosave(){
    
       
            system.debug('##dosave##');
            
             boolean checkOther= true;
             boolean isGroupNull = false;
             boolean isActivityNull = false;
             boolean isDateNull = false;
         
         for(AcctPlanActivity__c acti: (List<AcctPlanActivity__c>)childList){
               system.debug('acti.Other__c '+acti.Other__c);
               system.debug('acti.CheckOther__c '+acti.CheckOther__c);
               if(acti.CheckOther__c== 'Y' && (acti.Other__c == null ||acti.Other__c =='' )){
               checkOther= false;
               }
               if(acti.Group__c ==null || acti.Group__c =='' ){
                  isGroupNull = true;
               }
               if(acti.Activities__c ==null || acti.Activities__c ==''){
                  isActivityNull = true;
               }
               if(acti.Date__c ==null){
                isDateNull = true;
               }

         
          }
            
            
            if(checkOther && !isGroupNull && !isActivityNull && !isDateNull){
         
             try{    
                
            super.save();
            getStakeHolder(this.childList); 
            
            
            system.debug('CompanyID '+CompanyID);          
                  if(CompanyID!=null){
            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CompanyID);
            AcctPlanCompanyProfile__c companyprofile = [Select id,Status__c from AcctPlanCompanyProfile__c where id =: CompanyID ];
            system.debug('companyprofile '+companyprofile);      
            companyprofile.Status__c = 'In Progress';
            update companyprofile;
                 }
            
            /*isSuccess = true;
            jsScriptPopup = '<script> callclose(); </script>';
            system.debug('jsScriptPopup '+jsScriptPopup);*/
                 
         }catch(Exception e){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         } 
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
           }//checkOther
           else if(!checkOther){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5004').Status_Message__c));
           }else if(isGroupNull){
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5037').Status_Message__c));     
            }else if(isActivityNull){
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5038').Status_Message__c));        
              }else if(isDateNull){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5039').Status_Message__c));
        
              }
 
       
        
    }
    
    

  
}