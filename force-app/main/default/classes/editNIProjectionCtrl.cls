public class editNIProjectionCtrl extends EditableList {
    //public List<AcctPlanNIProject__c> nilist {get;set;}
    //public List<NIWrapper> niwrapperlist {get;set;}
    //public Opportunity Oppty {get;set;}
    //public String pageName {get;set;}
    //public Boolean isTempo {get;set;}
    public String ActionPlanID {get;set;}
    public String CompanyID {get;set;}
    /*public String ProductID {get;set;}
    public String ProductName {get;set;}
    public Integer NoProd {get;set;} */
    public Integer GroupA {get;set;} 
    public Integer GroupB {get;set;} 
    public Integer GroupC {get;set;} 
    public Integer GroupD {get;set;} 
    public Integer GroupE {get;set;} 
    
    
    
    public editNIProjectionCtrl(ApexPages.StandardController stdController){
    super(stdController);
        /*pageName = ApexPages.CurrentPage().getUrl();  
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
        string[] pageNameExtra = pageName.split('%3F',0);   
        pageName = pageNameExtra[0];
        Oppty = new Opportunity();
        if(pageName =='NIPrjectDetails'){
            isTempo = true;
        }else{
            isTempo = false;
        }*/
        //ProductID = '01tO00000038ZrpIAE';
        //ProductName = 'Account Service';
        ActionPlanID= ApexPages.currentPage().getParameters().get('ActionPlanID');
        CompanyID= ApexPages.currentPage().getParameters().get('CompanyID');
       // system.debug(ActionPlanID);
        this.childList =[SELECT ID,Group__c ,GroupCount__c, ExpectedFeeRate__c,DealProbability__c, ExpectedIncrementalFeePerYear1Year__c,
                 ExpectedIncrementalFeePerYear2Year__c ,ExpectedIncrementalNIPerYear2Year__c  ,
                 ExpectedIncrementalNIPerYear1Year__c ,ExpectedIncremental__c ,
                 ExpectedNimRate__c,NIStartMonth__c,NIStartYear__c,FeeStartMonth__c,FeeStartYear__c,Product__c, PropsProductOrServices__c, NIRecuringType__c,
                 FeeRecuringType__c,TypeOfFee__c,TypeOfNI__c,Opportunity__c, Description__c 
                 FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c =: ActionPlanID];
        /*nilist = [SELECT ID,Name,DealProbability__c, ExpectedFeeRate__c, ExpectedIncrementalFeePerYear1Year__c,
                 ExpectedIncrementalFeePerYear2Year__c ,ExpectedIncrementalNIPerYear2Year__c  ,
                 ExpectedIncrementalNIPerYear1Year__c ,ExpectedIncremental__c ,
                 ExpectedNimRate__c,NIStartMonth__c,NIStartYear__c,Product__c, PropsProductOrServices__c, NIRecuringType__c,
                 TypeOfFee__c,TypeOfNI__c
                 FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c =: ActionPlanID];
        niwrapperlist =  new  List<NIWrapper>();
        for(AcctPlanNIProject__c  ni : nilist){
            NIWrapper newWrap = new NIWrapper();
            OpportunityLineItem line = new OpportunityLineItem();
            newWrap.ni =ni;
            newWrap.isSelected =false;
            newWrap.oppline = line;
            niwrapperlist.add(newWrap);
        }*/
        //addToList();
       // system.debug(this.childList);
        //system.debug(childList);
        //this.childList.add(initChildRecord());
    }
    
        /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanNIProject__c> getChildren()
  {
    return (List<AcctPlanNIProject__c>)childList;
  }
  
  public List<SelectOption> getFiscalYear(){
        List<SelectOption> fiscalyearoption = new List<SelectOption>();
        List<Account_Plan_Fiscal_Year__c> yearlistitem = [SELECT ID,Name,AD_Year__c,BE_Year__c FROM Account_Plan_Fiscal_Year__c WHERE ID!=null ORDER BY Name];
        fiscalyearoption.add(new SelectOption('','None'));
        for(Account_Plan_Fiscal_Year__c year : yearlistitem){
            fiscalyearoption.add(new SelectOption(year.AD_Year__c,year.AD_Year__c));
        }         
        return fiscalyearoption;
    }
    
  public void GroupCount(){
  
  //GroupA = [select count(id) FROM AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'A'];
  system.debug('###Group Count####');
  //GroupA = database.countQuery('select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c='+ ActionPlanID +'and Group__c = '+'A');
  GroupA  = [select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'A'];               
  GroupB = [select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'B']; 
  GroupC = [select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'C']; 
  GroupD = [select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'D']; 
  GroupE = [select count() from AcctPlanNIProject__c WHERE  AcctPlanActionPlanID__c=: ActionPlanID and Group__c = 'E']; 
  system.debug('GroupA '+GroupA );
  system.debug('GroupB '+GroupB );
  system.debug('GroupC '+GroupC );
  system.debug('GroupD '+GroupD );
  system.debug('GroupE '+GroupE );
  
  }
    
 
    
public void dosave(){
     try{

           
         GroupCount();
         
         boolean GCA = true;
         boolean GCB = true;
         boolean GCC = true;
         boolean GCD = true;
         boolean GCE = true;
         boolean IsNotError=true;
         
         for(AcctPlanNIProject__c ni: (List<AcctPlanNIProject__c>)childList){
         if(ni.GroupCount__c!= null){
         GCA = ni.GroupCount__c.containsAny('A');
         GCB = ni.GroupCount__c.containsAny('B');
         GCC = ni.GroupCount__c.containsAny('C');
         GCD = ni.GroupCount__c.containsAny('D');
         GCE = ni.GroupCount__c.containsAny('E');
         
          }
          
         if(ni.Group__c == 'A'&& (!GCA|| ni.GroupCount__c== null)){
            ni.GroupCount__c = String.ValueOf(GroupA+1)+'A';
            system.debug('ni.GroupACount__c '+ni.GroupCount__c);
          }else if(ni.Group__c == 'B'&& (!GCB || ni.GroupCount__c== null)){
            ni.GroupCount__c = String.ValueOf(GroupB+1)+'B';
            system.debug('ni.GroupBCount__c '+ni.GroupCount__c);
          }
          else if(ni.Group__c == 'C'&& (!GCC|| ni.GroupCount__c== null)){
           ni.GroupCount__c = String.ValueOf(GroupC+1)+'C';
          }
          else if(ni.Group__c == 'D'&&( !GCD|| ni.GroupCount__c== null)){
           ni.GroupCount__c = String.ValueOf(GroupD+1)+'D';
          }
          else if(ni.Group__c == 'E'&& (!GCE|| ni.GroupCount__c== null)){
           ni.GroupCount__c = String.ValueOf(GroupE+1)+'E';
          }
          
          system.debug(' ni.TypeOfNI__c '+ni.TypeOfNI__c);
          
           //Check NI require field
          if( ni.TypeOfNI__c!=null ){
            if(ni.NIRecuringType__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select NI-Recurring or One-off'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5005').Status_Message__c));
        

            }else if(ni.ExpectedNimRate__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected NIM rate(%)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5006').Status_Message__c));
        
            }else if(ni.ExpectedIncrementalNIPerYear1Year__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Expected Incremental NI per year(first year)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5007').Status_Message__c));
        
            }else if(ni.NIStartMonth__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select NI-Start month'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5008').Status_Message__c));
        
            }else if(ni.NIStartYear__c==null){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select NI-Start year'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5009').Status_Message__c));
        
            }
          }//Check NI require field
             
         if(ni.TypeOfNI__c!=null ){    
           if(ni.NIRecuringType__c=='Recurring' ){
            if(ni.ExpectedIncrementalNIPerYear2Year__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Expected Incremental NI per year(2nd year onward)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5010').Status_Message__c));
        
            } 
             }     
         }
             
             
          //Check Fee require field
          if(ni.TypeOfFee__c!=null ){
            if(ni.FeeRecuringType__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Fee-Recurring or One-off'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5011').Status_Message__c));
        
            }else if(ni.ExpectedFeeRate__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected Fee rate(%)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5012').Status_Message__c));
        
            }else if(ni.ExpectedIncrementalFeePerYear1Year__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Expected Incremental Fee per year(first year)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5013').Status_Message__c));
        
            }else if(ni.FeeStartMonth__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Fee-Start month'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5014').Status_Message__c));
        
            }else if(ni.FeeStartYear__c==null){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Fee-Start year'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5015').Status_Message__c));
        
            }
          }//Check Fee require field
          
          if( ni.TypeOfFee__c!=null ){
            if(ni.FeeRecuringType__c=='Recurring'){
             if(ni.ExpectedIncrementalFeePerYear2Year__c==null ){
             IsNotError = false;
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Expected Incremental Fee per year(2nd year onward)'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5016').Status_Message__c));
        
            }
            }
              
          }  
         
         }//for

            if(IsNotError){   
           super.save();
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
            if(CompanyID!=null){
            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CompanyID);
         AcctPlanCompanyProfile__c companyprofile = [Select id,Status__c from AcctPlanCompanyProfile__c where id =: CompanyID ];
         companyprofile.Status__c = 'In Progress';
         update companyprofile;
              }
            }
            //system.debug(patieslist);
            //system.debug(childList );
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Portion is over 100.'));
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot select THB Currency'));
   
 
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }
    
  /*  public class NIWrapper{
        public AcctPlanNIProject__c ni {get;set;}
        public boolean isSelected {get;set;}
        public OpportunityLineItem oppline {get;set;}
    }*/


}