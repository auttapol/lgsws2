public class AccountPlanActionPlanConvert{
    public Opportunity Oppty {get;set;}
    public OpportunityLineItem OppLineItem {get;set;}
    public String ActionPlanID {get;set;}
    public String AccountID {get;set;}
    public String CompanyID {get;set;}
    public String GroupID {get;set;}
    public String WalletID {get;set;}
    //public String OptType {get;set;}
    public String jsScript{get;set;}
    public Set<Id> actPlanIds {get;set;}
    public String OpportunityID {get;set;}
    ApexPages.StandardController controller;
    //public boolean isSelected {get;set;}
    //public List<NIProject> niProject {get;set;}
    //public Date OptSubmitDate {get;set;}
    //public Date OptCompleteDate {get;set;}
    
    /*public List<SelectOption> getItems() {
List<SelectOption> options = new List<SelectOption>();
options.add(new SelectOption('','--None--'));
options.add(new SelectOption('Credit','Credit Product'));
options.add(new SelectOption('Non','Non-credit Product'));
return options;
}*/
    public AccountPlanActionPlanConvert(ApexPages.StandardController controller)
    {   
        OpportunityID =   ApexPages.currentPage().getParameters().get('OpportunityID');
        if(OpportunityID!=null && OpportunityID!=''){
            Oppty = [select id,Name,OpportunityTypeForNI__c,Expected_submit_date__c,
                     CloseDate,AccountId,StageName,Pricebook2Id,RecordTypeId,
                     Amount,This_Year_Expected_Revenue__c,Expected_Revenue_Input__c 
                     from Opportunity
                     WHERE ID =:OpportunityID LIMIT 1];
        }
    }
    public AccountPlanActionPlanConvert(){
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        //ActionPlanID = 'a1LO00000014o41';
        //AccountID = '001O000000nWKobIAG';
        system.debug(' #####NIConvert#### ' );
        system.debug('CompanyID  '+CompanyID  );
        getWallet();
        getAccount();
        system.debug('WalletID '+WalletID );
        //ActionPlanID = 'a1LO00000014o41';
        Set<Id> domainIds = new Set<Id>();
        try{
            List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID ];
            for(AcctPlanWalletByDomain__c d : domainList){
                domainIds.add(d.id);
            }
            actPlanIds = new Set<Id>();
            List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Status__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c IN :domainIds];
            for(AcctPlanActionPlan__c ap : actionplanList ){
                actPlanIds.add(ap.id);
            }
            system.debug(' actPlanIds  '+actPlanIds );
        }catch(Exception Ex){
            system.debug(' NIConvert Exception ' );
        }
        
        
        
        Oppty = new Opportunity();
        /*    niProject = new List<NIProject>();
for(AcctPlanNIProject__c o: NIProjectListNoOpt){
niProject.add(new NIProject(o));
} */
        
        
    }
    
    public List<AcctPlanNIProject__c>  NIProjectListNoOpt {
        get {
            if(NIProjectListNoOpt == null && actPlanIds!= null  ){
                List<AcctPlanNIProject__c> NIProjectListNoOptUpdate = new List<AcctPlanNIProject__c>();
                //NIProjectListNoOpt =  [SELECT ID, PropsProductOrServices__c,DealProbability__c, NIRecuringType__c,NIStartMonth__c,NIStartYear__c,FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,StandardInitiative__c,NonStandardInitiative__c,ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalFeePerYear2Year__c,isConvert__c,Product__c FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c =: ActionPlanID and Opportunity__c = null  ];
                NIProjectListNoOpt = [SELECT ID,Group__c, PropsProductOrServices__c,Description__c ,DealProbability__c, UnitPrice__c,NIRecuringType__c,NIStartMonth__c,NIStartYear__c,FeeRecuringType__c,FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,StandardInitiative__c,NonStandardInitiative__c,ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalFeePerYear2Year__c,isConvert__c,Product__c  FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c IN : actPlanIds and Opportunity__c = null  ];
                for(AcctPlanNIProject__c n: NIProjectListNoOpt){
                    if(n.isConvert__c){
                        n.isConvert__c=false;
                        //update n;
                        NIProjectListNoOptUpdate.add(n);
                    }
                }
                if(NIProjectListNoOptUpdate.size()>0){
                    update NIProjectListNoOptUpdate;   
                }
            }
            return NIProjectListNoOpt ;
            
        } set;
    }
    
    
    public void getWallet()
    {
        WalletID = [Select id from AcctPlanWallet__c where AcctPlanCompanyProfile__c = : CompanyID ].Id;
        system.debug('WalletID '+WalletID);
    }
    
    public void getAccount()
    {
        List<AcctPlanCompanyProfile__c> company = [Select Account__c from AcctPlanCompanyProfile__c where Id = : CompanyID ];
        for(AcctPlanCompanyProfile__c  c : company){
            AccountID = c.Account__c;
        }
        system.debug('AccountID '+AccountID);
    }
    
    
    /*  public List<NIProject> getNIProject() {
return niProject;
}


class NIProject{
public ID id {get;set;} 
public String Product {get;set;} 
public String NIRecuringType {get;set;} 
public String NIStartMonth {get;set;} 
public String NIStartYear {get;set;} 
public Decimal DealProbability {get;set;} 
public String TypeOfNI {get;set;} 
public String TypeOfFee {get;set;} 
public Decimal ExpectedNimRate {get;set;} 
public Decimal ExpectedFeeRate {get;set;} 
public Decimal ExpectedIncrementalNIPerYear2Year {get;set;} 
public Decimal ExpectedIncrementalNIPerYear1Year {get;set;} 
public Decimal ExpectedIncremental {get;set;} 
public String StandardInitiative {get;set;} 
public String NonStandardInitiative {get;set;} 
public Decimal ExpectedIncrementalFeePerYear1Year {get;set;} 
public Decimal ExpectedIncrementalFeePerYear2Year {get;set;}  
public boolean isSelected{get;set;} 

public NIProject(AcctPlanNIProject__c actNI){
this.isSelected = false;
this.ID = actNI.ID; 
this.Product  = actNI.PropsProductOrServices__c; 
this.NIRecuringType  = actNI.NIRecuringType__c; 
this.NIStartMonth  = actNI.NIStartMonth__c; 
this.NIStartYear  = actNI.NIStartYear__c; 
this.DealProbability  = actNI.DealProbability__c; 
this.TypeOfNI  = actNI.TypeOfNI__c; 
this.TypeOfFee  = actNI.TypeOfFee__c; 
this.ExpectedNimRate  = actNI.ExpectedNimRate__c; 
this.ExpectedFeeRate  = actNI.ExpectedFeeRate__c; 
this.ExpectedIncrementalNIPerYear2Year  = actNI.ExpectedIncrementalNIPerYear2Year__c; 
this.ExpectedIncrementalNIPerYear1Year  = actNI.ExpectedIncrementalNIPerYear1Year__c; 
this.ExpectedIncremental  = actNI.ExpectedIncremental__c; 
this.StandardInitiative  = actNI.StandardInitiative__c; 
this.NonStandardInitiative  = actNI.NonStandardInitiative__c; 
this.ExpectedIncrementalFeePerYear1Year  = actNI.ExpectedIncrementalFeePerYear1Year__c; 
this.ExpectedIncrementalFeePerYear2Year = actNI.ExpectedIncrementalFeePerYear2Year__c;

}
}
*/
    
    public PageReference doconvert()
    {       
        system.debug(':::::doconvert::::');
        /*       for(AcctPlanNIProject__c n: NIProjectListNoOpt){
system.debug('Product--------------'+n.PropsProductOrServices__c); 
system.debug('Is Selected--------------'+n.isConvert__c); 
}

system.debug(Oppty.Name);
system.debug(OptType);
system.debug(Oppty.Expected_submit_date__c);
system.debug(Oppty.CloseDate);*/
        //Oppty.StageName = 'Open';
        //Oppty.Account.id = '001O000000nWKob';
        system.debug('Oppty.Name ='+Oppty.Name);
        system.debug('Oppty.OpportunityTypeForNI__c ='+Oppty.OpportunityTypeForNI__c);
        system.debug('Oppty.Expected_submit_date__c ='+Oppty.Expected_submit_date__c);
        system.debug('Oppty.CloseDate ='+Oppty.CloseDate);
        
        boolean productselected = false;
        boolean isValidate = true;
        boolean isExist=false;
        for(AcctPlanNIProject__c n: NIProjectListNoOpt){
            isExist=true;
            if(n.isConvert__c){
                productselected=true;
            }
        }
        
        system.debug(NIProjectListNoOpt);
        system.debug(productselected);
        
        if(isExist){
            Pricebook2 standardPricebook = new Pricebook2(); 
            try{
                Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
                Map<String,Pricebook2> pricebookmap = new Map<String,Pricebook2>();
                for(Pricebook2 R : Records){
                    pricebookmap.put(r.Name,r);
                }
                
                System.debug('Pricebook :'+Records+' Map :'+pricebookmap);
                
                User us = [SELECT ID,Segment__c
                           FROM User 
                           WHERE ID=:UserInfo.getUserId() LIMIT 1];
                System.debug('user : '+us);
                
                if(us.Segment__c != null){
                    //standardPricebook.id = pricebookmap.get('SE Price Book').id;
                    standardPricebook.id = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;
                    
                }if(Test.isRunningTest()){
                    standardPricebook.id = Test.getStandardPricebookId();
                }else{ 
                    standardPricebook.id = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
                }
                
                System.debug('Picked : '+standardPricebook);
                String RecordTypeName=''  ;
                if(us.Segment__c=='SE'||us.Segment__c=='9999'||us.Segment__c=='BB'){
                    if(Oppty.OpportunityTypeForNI__c=='Credit Product'){
                        RecordTypeName = 'SE Credit Product';
                    }else if(Oppty.OpportunityTypeForNI__c=='Non-credit Product'){
                        RecordTypeName = 'Non-credit Product';
                    }
                }else if(us.Segment__c=='CB'||us.Segment__c=='MB'||us.Segment__c=='Default'){
                    if(Oppty.OpportunityTypeForNI__c=='Credit Product'){
                        RecordTypeName = 'WBG Credit Product';
                    }else if(Oppty.OpportunityTypeForNI__c=='Non-credit Product'){
                        RecordTypeName = 'Non-credit Product';
                    }
                }
                
                
                
                system.debug('Oppty.OpportunityTypeForNI__c='+Oppty.OpportunityTypeForNI__c);
                system.debug('RecordTypeName='+RecordTypeName);
                
                Id recordTypeId  = [select Id from RecordType where SobjectType = 'Opportunity' and Name=: RecordTypeName and IsActive=true ].Id;
                
                //check Date Condition 
                if(Oppty.CloseDate<Oppty.Expected_submit_date__c){  
                    isValidate = false;
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Expected complete date must be more than expected submitted date'));
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5022').Status_Message__c));
        
                }else if(Oppty.Expected_submit_date__c<System.Today()){
                    isValidate = false;
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Expected Submit Date cannot be the date in the past'));
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5023').Status_Message__c));
        
                }else{
                    //Opportunity opp = new Opportunity(Name = Oppty.Name, Expected_submit_date__c=Oppty.Expected_submit_date__c, CloseDate= Oppty.CloseDate, Account= [Select Id From Account where Id=: AccountID] ,StageName='Open',Pricebook2Id= standardPricebook.id,RecordTypeId=recordTypeId ); 
                    
                    if(Oppty.Name!=null&&Oppty.Expected_submit_date__c!=null&&Oppty.CloseDate!=null&&standardPricebook.id!=null&&recordTypeId!=null){
                        
                        Opportunity opp = new Opportunity();
                        opp.Name = Oppty.Name; 
                        opp.OpportunityTypeForNI__c = Oppty.OpportunityTypeForNI__c;
                        opp.Expected_submit_date__c=Oppty.Expected_submit_date__c; 
                        opp.CloseDate= Oppty.CloseDate; 
                        opp.AccountId= AccountID;
                        opp.StageName='Analysis';
                        opp.Pricebook2Id= standardPricebook.id;
                        opp.RecordTypeId=recordTypeId; 
                        
                        System.debug('Before opp : '+opp);
                        
                        System.debug('Insert Opt and Line Item ');
                        
                        if(productselected){
                            Decimal SumUnitPrice = 0; 
                            Decimal SumThisYearExpectedRevenue = 0;
                            Decimal SumExpectedIncrementalNIPerYear1Year  = 0;
                            Decimal SumExpectedIncrementalFeePerYear1Year  = 0;
                            Decimal SumExpectedIncrementalNIPerYear2Year   = 0;
                            Decimal SumExpectedIncrementalFeePerYear2Year   = 0;
                            
                            for(AcctPlanNIProject__c n: NIProjectListNoOpt){
                                //system.debug('Product--------------'+n.Product__c); 
                                //system.debug('Is Selected--------------'+n.isConvert__c); 
                                if(n.isConvert__c){
                                    System.debug('n.Product__c : '+n.Product__c);
                                    System.debug('standardPricebook.id : '+standardPricebook.id);
                                    if(n.Product__c==null){
                                        isValidate = false;
                                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Cannot Find Product in PricebookEntry.'));
                                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5024').Status_Message__c));
        
                                    }else{
                                        Id entryId= [SELECT Id,Pricebook2Id,Product2Id FROM PricebookEntry where Product2Id =:n.Product__c and Pricebook2Id=:standardPricebook.id].id;
                                        system.debug('n.UnitPrice__c '+n.UnitPrice__c);
                                        if(n.UnitPrice__c>0 && n.UnitPrice__c!= null){
                                            /*  try{
insert opp;
System.debug('After opp : '+opp.id);

OppLineItem = new OpportunityLineItem(OpportunityId =opp.id ,PricebookEntryId= entryId,Quantity=1,UnitPrice= n.UnitPrice__c);
insert OppLineItem;

n.Opportunity__c=opp.id;
update n; 
System.debug('OppLineItem : '+OppLineItem );

ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));

jsScript= '<script>callclose();</script>';
system.debug('jsScript '+jsScript);

}catch (Exception e)
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
}
*/
                                            SumUnitPrice = SumUnitPrice + (n.UnitPrice__c == null? 0 : n.UnitPrice__c);
                                            SumExpectedIncrementalNIPerYear1Year = SumExpectedIncrementalNIPerYear1Year + (n.ExpectedIncrementalNIPerYear1Year__c == null? 0 : n.ExpectedIncrementalNIPerYear1Year__c);
                                            SumExpectedIncrementalFeePerYear1Year = SumExpectedIncrementalFeePerYear1Year + (n.ExpectedIncrementalFeePerYear1Year__c == null? 0 : n.ExpectedIncrementalFeePerYear1Year__c);
                                            SumExpectedIncrementalNIPerYear2Year = SumExpectedIncrementalNIPerYear2Year + (n.ExpectedIncrementalNIPerYear2Year__c == null? 0 : n.ExpectedIncrementalNIPerYear2Year__c);
                                            SumExpectedIncrementalFeePerYear2Year = SumExpectedIncrementalFeePerYear2Year + (n.ExpectedIncrementalFeePerYear2Year__c == null? 0 : n.ExpectedIncrementalFeePerYear2Year__c);
                                            
                                            
                                            
                                        }else{
                                            system.debug('n.UnitPrice__c ApexPages.Severity.ERROR');
                                            isValidate = false;
                                            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Cannot Create Opportunity Line Item. Please insert Opportunity Vol.'));   
                                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5025').Status_Message__c));
        
                                        }   // create OppLineItem and update NI success
                                    } // Product__c not null
                                } // isConvert
                            } // for loop
                            
                            opp.Amount = SumUnitPrice;
                            //opp.This_Year_Expected_Revenue__c  =  SumExpectedIncrementalNIPerYear1Year + SumExpectedIncrementalFeePerYear1Year;
                            //opp.Expected_Revenue_Input__c = SumExpectedIncrementalNIPerYear2Year + SumExpectedIncrementalFeePerYear2Year;
                            
                            
                            if(isValidate){
                                try{
                                    
                                    insert opp;
                                    System.debug('After opp : '+opp.id);
                                    //OpportunityID = opp.id;
                                    
                                    List<OpportunityLineItem> OppLineItemList = new List<OpportunityLineItem>();
                                    List<AcctPlanNIProject__c> AcctPlanNIProjectList = new List<AcctPlanNIProject__c>();
                                        
                                    for(AcctPlanNIProject__c n: NIProjectListNoOpt){
                                        //system.debug('Product--------------'+n.Product__c); 
                                        //system.debug('Is Selected--------------'+n.isConvert__c); 
                                        if(n.isConvert__c){
                                            System.debug('n.Product__c : '+n.Product__c);
                                            System.debug('standardPricebook.id : '+standardPricebook.id);
                                            
                                            Id entryId= [SELECT Id,Pricebook2Id,Product2Id FROM PricebookEntry where Product2Id =:n.Product__c and Pricebook2Id=:standardPricebook.id].id;
                                            system.debug('n.UnitPrice__c '+n.UnitPrice__c);                        
                                            
                                            OppLineItem = new OpportunityLineItem();
                                            
                                            OppLineItem.OpportunityId =opp.id ;
                                            OppLineItem.PricebookEntryId= entryId;
                                            OppLineItem.Quantity=1;
                                            OppLineItem.UnitPrice = n.UnitPrice__c;
                                            //OppLineItem.Product2Id = n.Product__c;
                                            OppLineItem.Deal_Probability__c = n.DealProbability__c;
                                            
                                            OppLineItem.Type_Of_Reference__c = n.TypeOfNI__c;
                                            OppLineItem.Recurring_Type__c = n.NIRecuringType__c;
                                            OppLineItem.Expected_NIM__c = n.ExpectedNimRate__c;
                                            OppLineItem.This_Year_Expected_NI__c = n.ExpectedIncrementalNIPerYear1Year__c;
                                            OppLineItem.Expected_Revenue__c = n.ExpectedIncrementalNIPerYear2Year__c;
                                            OppLineItem.RevisedStartMonth__c = n.NIStartMonth__c;
                                            OppLineItem.RevisedStartYear__c = n.NIStartYear__c;
                                            OppLineItem.OriginalStartMonth__c = n.NIStartMonth__c;
                                            OppLineItem.OriginalStartYear__c  = n.NIStartYear__c;
                                           
                                            OppLineItem.Type_Of_Reference_Fee__c = n.TypeOfFee__c;
                                            OppLineItem.Recurring_Type_Fee__c = n.FeeRecuringType__c;
                                            OppLineItem.Expected_Fee_Rate__c = n.ExpectedFeeRate__c;
                                            OppLineItem.This_Year_Expected_Fee__c = n.ExpectedIncrementalFeePerYear1Year__c;
                                            OppLineItem.Expected_Revenue_Fee__c = n.ExpectedIncrementalFeePerYear2Year__c ;
                                            OppLineItem.RevisedStartMonthFee__c  = n.FeeStartMonth__c ;
                                            OppLineItem.RevisedStartYearFee__c  = n.FeeStartYear__c ;
                                            OppLineItem.OriginalStartMonthFee__c  = n.FeeStartMonth__c ;
                                            OppLineItem.OriginalStartYearFee__c   = n.FeeStartYear__c ;
                                            
                                            //insert OppLineItem;
                                            OppLineItemList.add(OppLineItem);
                                            
                                            n.Opportunity__c=opp.id;
                                            n.isConvert__c = false;
                                            //update n; 
                                            AcctPlanNIProjectList.add(n);
                                            
                                            System.debug('OppLineItem : '+OppLineItem );
                                            
                                            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
                                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
                                            jsScript= '<script>callclose();</script>';
                                            system.debug('jsScript '+jsScript);
                                            
                                        } //if convert      
                                    }//for
                                    if(OppLineItemList.size()>0 && AcctPlanNIProjectList.size()>0){
                                        insert OppLineItemList;
                                        update AcctPlanNIProjectList;
                                    }
                                    /*if(AcctPlanNIProjectList.size()>0){
                                        update AcctPlanNIProjectList;
                                    }*/
                                    /*PageReference OpptyPage = new ApexPages.StandardController(opp).view();
                                    OpptyPage.setRedirect(true);
                                    return OpptyPage;*/
                                    PageReference pr = Page.OpportunityViewDetail;
                                    pr.setRedirect(true);
                                    pr.getParameters().put('OpportunityID',opp.id);
                                    pr.getParameters().put('isdtp','vw');
                                    return pr;
                                }catch (Exception e)
                                {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                                }
                                
                            }// if pass validate
                            
                        } else {
                            isValidate = false;
                            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please select at least one product'));
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5026').Status_Message__c));
        
                        }  
                        
                    }// if
                    else{
                        isValidate = false;
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Cannot Create Opportunity.'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5027').Status_Message__c));
        
                    }
                    
                }  ///if validate expected Date
                
                
                
            }catch(QueryException e){
                System.debug('error select std pricebook : '+e);
            }               
            
             
            
        } else {
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'There is no available NI Projections to convert to Opportunity'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5028').Status_Message__c));
        
        }    
        
      return null;  
        
    }
    
}