public class AccountPlanActionPlanController{
    public String CompanyID {get;set;}
    public String GroupID {get;set;}
    public String AccountID {get;set;}
    public String AccountName {get;set;}
    public String ActionPlanID {get;set;}
    public String ActivityID {get;set;}
    public String Domain {get;set;}
    public String DomainCode {get;set;}
    public String Sub {get;set;}
    public String Type {get;set;}
    public String Objective {get;set;}
    public String Status {get;set;}
    public String Winning {get;set;}
    public String Url {get;set;}
    /*public String DomainName1 {get;set;}
    public String DomainName2 {get;set;}
    public String DomainName3 {get;set;}
    public String DomainName4 {get;set;} */
    public Id WalletID {get;set;}
    public Id WalletDomainID {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public Boolean ishasProdStrategy {get;set;}
    public Boolean isHasPermission {get;set;}
    public Boolean isExist = false;
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public List<Contact> cont; 
    public List<SelectOption> PriorityOptionList {get;set;}
    public AcctPlanActionPlan__c actionplan {get;set;}
    //public List<AcctPlanNIProject__c>  NIProjectListNoOpt {get;set;}
    //public List<AcctPlanNIProject__c>  NIProjectListOpt {get;set;} 
    public List<AcctPlanWalletByDomain__c >domainList1 {get;set;}
    public List<AcctPlanWalletByDomain__c >domainList2{get;set;}
    public List<AcctPlanWalletByDomain__c >domainList3 {get;set;}
    public List<AcctPlanWalletByDomain__c >domainList4 {get;set;}
    public List<AcctPlanActivity__c  >actionactivityList1 {get;set;}
    public List<AcctPlanActivity__c  >actionactivityList2 {get;set;}
    public List<AcctPlanActivity__c  >actionactivityList3 {get;set;}
    public List<AcctPlanActivity__c  >actionactivityList4 {get;set;}
    public List<AcctPlanActivity__c  >actionactivityListFilter {get;set;}
    public Map<String,List<AcctPlanActivity__c>> actionactivityMap {get;set;}
    
    public List<AcctPlanWalletByDomain__c >domainNIList1 {get;set;}
    public List<AcctPlanWalletByDomain__c >domainNIList2{get;set;}
    public List<AcctPlanWalletByDomain__c >domainNIList3 {get;set;}
    public List<AcctPlanWalletByDomain__c >domainNIList4 {get;set;}
    public List<AcctPlanNIProject__c>NIProjectList1{get;set;}
    public List<AcctPlanNIProject__c>NIProjectList2{get;set;}
    public List<AcctPlanNIProject__c>NIProjectList3{get;set;}
    public List<AcctPlanNIProject__c>NIProjectList4{get;set;}
    public List<AcctPlanActionPlan__c> actionplandomainList {get;set;}
    public boolean typeBook{get;set;}
    public boolean typeVisit{get;set;}
    public boolean typeTask{get;set;} 
    public boolean isVisit {get;set;} 
    public boolean isTask {get;set;}
    public String TaskURL {get;set;}  
    public integer bSelected {get;set;}
    public List<Task> TaskList {get;set;}
    //List<CustomDomain__c> Cusdomain {get;set;}
    //public List<AcctPlanWalletByDomain__c>  actiondomainList {get;set;}
   // public List<AcctPlanActivity__c>  actionactivityList {get;set;}

    /*public string d1{get;set;}
    public string d2 {get;set;}
    public string d3 {get;set;}
    public string d4 {get;set;} */
    
    public String selectedHigh {get;set;}
    //public string selectedCoreAsset {get;set;}
    //public String SelectedDomain {get;set;}
 
    
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}        
    private Account standardFree = new Account();  
    public Boolean isMiniView {get;set;}
    public Boolean isHasActionPlan {get;set;}
    public Boolean isHasActionPlanActivities {get;set;}
    public boolean isSystemAdmin {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public Boolean isHasNiProjection {get{
        if(NIProjectListAll.size()>0){
            isHasNiProjection = false;
        }else{
            isHasNiProjection = true;
        }
        return isHasNiProjection;
    }set;}
    public String msgActionPlan {get;set;}
    public String msgNIProjection {get;set;}
    public String msgActivitiesQuestion {get;set;}
    
    
    public AccountPlanActionPlanController()
    {   
        msgActionPlan = Account_Plan_Status_Code__c.GetValues('5031').Status_Message__c;
        msgNIProjection = Account_Plan_Status_Code__c.GetValues('5032').Status_Message__c;
        msgActivitiesQuestion = Account_Plan_Status_Code__c.GetValues('5033').Status_Message__c;

        System.debug('###AccountPlanActionPlanController###'); 
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyID);
        System.debug('CompanyID  '+CompanyID );   
        System.debug('companyprofile '+companyprofile );   
        //Completion
        //
        if(companyprofile !=null){
                List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_5_Percentage__c ,
                      Account_Plan_Completion_Percentage__c 
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                 if(CompleteList.size()>0){
                 Acctplancompletion = CompleteList.get(0);
             }
            }  
        //
        //
        ishasProdStrategy = companyprofile.isHasProdStrategy__c;
        isHasActionPlan = companyprofile.isHasActionPlan__c;
        isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
        isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
        isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
         if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
        
        mode = ApexPages.currentPage().getParameters().get('mode');
        if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        
        
        //if(HasActplan == 'Y'){
        //UpdateComprofile();
       // }
        
        //AccountID = '001O000000nWKob';
        //CompanyID ='a0XO0000008R3bk';
        getWallet();
        system.debug('Cusdomain '+Cusdomain);
        system.debug('DomainMap '+DomainMap);
        system.debug('DomainMap2 '+DomainMap2); 
      
        //getDomainName();
        //WalletDomainID = ApexPages.currentPage().getParameters().get('WalletDomainID');
        //AccountID = '001O000000nWKob';
        //ActionPlanID = 'a1LO00000014o41';
        //CompanyID ='a0XO0000008R3bk';
        //WalletDomainID = 'a1JO0000001bsTvMAI';

       /* if(CompanyID !=null && CompanyID !=''){
             companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
        }
        system.debug('ComId '+CompanyID);
        system.debug('WalletDomainID '+WalletDomainID);
        getWallet();
    */
      //  isHasActionPlan = true;
      /*  for(AcctPlanWalletByDomain__c w :actiondomainList){
            for(AcctPlanActionPlan__c a :actionplandomainList){
                if(w.Id==a.AcctPlanWalletByDomain__r.id){
                  //  isHasActionPlan = false;
                }
            }
        }  */
        //Complettion Mandatory
        List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c
                                                      where AcctPlanWallet__c = :WalletID];


        List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Objective__c, Status__c, WinningPropostion__c
                                                      FROM AcctPlanActionPlan__c
                                                      WHERE AcctPlanWalletByDomain__c IN :domainList];
        isHasActionPlanActivities = false; 
        //Comment code mandatort for action plan activities
        /*List<AcctPlanActivity__c> actionactivityList = [SELECT ID, AccountPlanActionPlanID__c, Date__c
                                                        FROM AcctPlanActivity__c
                                                        WHERE AccountPlanActionPlanID__c IN :actionplanList];*/
        if (actionplanList.size() > 0) { 
            isHasActionPlanActivities = true;
        }
        
        //Filter Customer Counterparties
        actionactivityMap = new Map<String,List<AcctPlanActivity__c>>();
        actionactivityListFilter = [SELECT ID,Status__c , Group__c,Activities__c,Date__c,CustomerCounterparties__c,
                                    CustomerCounterparties__r.Name,Visit_Plan_Report__c,TaskId__c, isBook__c,
                                    AccountPlanActionPlanID__r.AcctPlanWalletByDomain__r.WalletDomain__c, CheckOther__c , Other__c 
                                    FROM AcctPlanActivity__c 
                                    WHERE AccountPlanActionPlanID__c IN :actionplanList AND Visit_Plan_Report__c =null and TaskId__c =null and CustomerCounterparties__c!=null 
                                    ORDER BY CustomerCounterparties__c,AccountPlanActionPlanID__r.AcctPlanWalletByDomain__r.WalletDomain__c,Group__c,Date__c ];
        for(AcctPlanActivity__c item : actionactivityListFilter){
            if(actionactivityMap.containsKey(item.CustomerCounterparties__r.Name)){
                actionactivityMap.get(item.CustomerCounterparties__r.Name).add(item);
            }else{
                List<AcctPlanActivity__c> a = new List<AcctPlanActivity__c>();
                a.add(item);
                actionactivityMap.put(item.CustomerCounterparties__r.Name, a);
            }
        }

        
        
    }
    
        public void UpdateComprofile()
        {
            try{
                System.debug('###UpdateComprofile###'); 
                List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c
                                                      where AcctPlanWallet__c = :WalletID];


                List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Objective__c, Status__c, WinningPropostion__c
                                                      FROM AcctPlanActionPlan__c
                                                      WHERE AcctPlanWalletByDomain__c IN :domainList];
                if(actionplanList.size()>0){
                    AcctPlanCompanyProfile__c  Actcomp = [select id,AccountPlanWalletID__c,isHasActionPlan__c from AcctPlanCompanyProfile__c where Id =: CompanyID Limit 1];
                    System.debug('Actcomp  '+Actcomp ); 
                    if(!Actcomp.isHasActionPlan__c || Actcomp.isHasActionPlan__c == null ){
                        Actcomp.isHasActionPlan__c = true;
                        update Actcomp;
                    }
                }
            }catch(Exception ex){
                System.debug('Exception UpdateComprofile'+ex);   
            }
        }  
    
    public void actionPlan()
    {
        try{
        //GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        //CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        
        //AccountID = '001O000000nWKob';
        //CompanyID ='a0XO0000008R3bk';
        //WalletDomainID = 'a1JO0000001bsTvMAI';

       /* if(CompanyID !=null && CompanyID !=''){
             companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
        }
        system.debug('ComId '+CompanyID);
        system.debug('WalletDomainID '+WalletDomainID); */
        getWallet();
        getAccount();
        //cont = new List<Contact>();
        //cont = [Select id, Salutation__c,Name,M_C_FName__c,M_C_LName__c, Position__c,Product_Decision__c,Product_Decision2__c,Product_Decision3__c, Decision_Map__c,Decision_Map2__c,Decision_Map3__c from Contact where Account.id = :AccountID];
        //NoOfCurrentPage = System.currentPagereference().getParameters().get('id');
        PriorityOptionList = new List<SelectOption>();
        //PriorityOptionList.add(new SelectOption('Please select','Please select'));
        PriorityOptionList.add(new SelectOption('All','All'));
        PriorityOptionList.add(new SelectOption('Medium','Medium'));
        PriorityOptionList.add(new SelectOption('High','High'));
        selectedHigh = 'High';
                }catch(Exception ex){
            
        }
    }  
    
        public void planSelection()
    {
        
        WalletDomainID = ApexPages.currentPage().getParameters().get('WalletDomainID');
        //Domain = ApexPages.currentPage().getParameters().get('Domain');
        //Sub = ApexPages.currentPage().getParameters().get('Sub');
        //Type = ApexPages.currentPage().getParameters().get('Type');
        Url = 'https://' +ApexPages.currentPage().getHeaders().get('Host');
        system.debug('WalletDomainID '+WalletDomainID );
        
       // ActionPlanID = 'a1LO00000014o41';
       actionplan = new AcctPlanActionPlan__c();
       try{
       List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Objective__c, Status__c ,WinningPropostion__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c = :WalletDomainID  ];
       for (AcctPlanActionPlan__c actplan : actionplanList){
       ActionPlanID = actplan.Id;
       Objective = actplan.Objective__c;
       actionplan.Objective__c  = actplan.Objective__c;
       Status = actplan.Status__c;
       actionplan.Status__c =actplan.Status__c;
       Winning = actplan.WinningPropostion__c;
        }
        

        AcctPlanWalletByDomain__c actionpdomainList = [SELECT  WalletDomain__c ,SubDomain__c ,TypeOfNI__c  FROM AcctPlanWalletByDomain__c WHERE Id = :WalletDomainID Limit 1];
        boolean isExist = true;
        DomainCode = String.valueOf(actionpdomainList.WalletDomain__c)  ;
        String DomainName4='';
        try{
        CustomDomain__c D4 = CustomDomain__c.GetValues(DomainCode);
        DomainName4= D4.DomainName__c;
        }catch(Exception Ex){
          isExist = false;
        }

        Domain ='';

                if( isExist ){
                    Domain = DomainName4;
                    }
                    else{
                    Domain = actionpdomainList.WalletDomain__c+'. N/A';
                    }  
 
        system.debug('Domain '+Domain);
        
        Sub = actionpdomainList.SubDomain__c  ;
        Type = actionpdomainList.TypeOfNI__c   ;   
           
        //getDomainName();   
        getAccount();
        getAccountName();
        
        system.debug('actionplanList  '+actionplanList );
         }catch(Exception ex){
            system.debug('Planselection Exception ' );
        }
     /*  ActionPlanID = actionplanList.Id;
       Objective = actionplanList.Objective__c;
       Status = actionplanList.Status__c;
       Winning = actionplanList.WinningPropostion__c;
       */

               
    }  
    
  /*         public List<AcctPlanWalletByDomain__c>  actionpdomainList {
        get {
            if(actionpdomainList == null){
                actionpdomainList = [SELECT  WalletDomain__c ,SubDomain__c ,TypeOfNI__c  FROM AcctPlanWalletByDomain__c WHERE Id = :WalletDomainID Limit 1];
                
              }
             return actionpdomainList;
        
       } set;
       }
*/

    public void getWallet()
    {
        WalletID = [Select id from AcctPlanWallet__c where AcctPlanCompanyProfile__c = : CompanyID ].Id;
        //system.debug('WalletID '+WalletID);
    }
    
    public void getAccount()
    {
        List<AcctPlanCompanyProfile__c> company = [Select Account__c from AcctPlanCompanyProfile__c where Id = : CompanyID ];
        for(AcctPlanCompanyProfile__c  c : company){
        AccountID = c.Account__c;
        }
        //system.debug('AccountID '+AccountID);
    }
    
    
    public void getAccountName()
    {
        List<Account> company = [Select Name from Account where Id = : AccountID ];
        for(Account c : company){
        AccountName = c.Name;
        }
        //system.debug('AccountID '+AccountID);
    }

    public List<Contact> getCont()
    {
        //system.debug('AccountID '+AccountID);
        cont = [Select id, Salutation__c,Name,FirstName,LastName, Position__c,Product_Decision__c,
        Product_Decision2__c,Product_Decision3__c, Decision_Map__c,Decision_Map2__c,Decision_Map3__c,
        Product_Decision_2_2__c,Product_Decision_3_2__c
        from Contact where Account.id = :AccountID];
        return cont;
    }
    
   /* public void getDomainName()
    {
    
    
    try{
    CustomDomain__c D1 = CustomDomain__c.GetValues('1');
    DomainName1= D1.DomainName__c;
    system.debug('DomainName1'+DomainName1);
    }catch(Exception Ex){
    DomainName1 = '1. null';
    }
    
    try{
    CustomDomain__c D2 = CustomDomain__c.GetValues('2');
    DomainName2= D2.DomainName__c;
    system.debug('DomainName2 '+DomainName2);
    }catch(Exception Ex){
    DomainName2 = '2. null';
    }
    
    try{
    CustomDomain__c D3 = CustomDomain__c.GetValues('3');
    DomainName3= D3.DomainName__c;
    system.debug('DomainName3 '+DomainName3);
    }catch(Exception Ex){
    DomainName3 = '3. null';
    }
    
    try{
    CustomDomain__c D4 = CustomDomain__c.GetValues('4');
    DomainName4= D4.DomainName__c;
    system.debug('DomainName4 '+DomainName4);
    }catch(Exception Ex){
    DomainName4 = '4. null';
    }
    
    }*/
    
    
    public List<CustomDomain__c> Cusdomain {
        get {
            //if(Cusdomain == null){
                Cusdomain= CustomDomain__c.getAll().values(); 
                //}
               
             return Cusdomain;
        
       } set;
       }
      
      public Map<String,CustomDomain__c> DomainMap {get{
        //if(DomainMap ==null){
            DomainMap = CustomDomain__c.getAll();
        //}
        return DomainMap;
    }set;} 
    

    public List<AcctPlanWalletByDomain__c>  actiondomainList {
        get {
            if(actiondomainList == null){
                actiondomainList = [SELECT ID, Opportunity__c, WalletDomain__c ,Priority__c ,SubDomain__c ,TypeOfNI__c  FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID and Priority__c = 'High' ORDER BY WalletDomain__c ];
             
              actionplandomainList = [Select id, AcctPlanWalletByDomain__r.id from AcctPlanActionPlan__c where AcctPlanWalletByDomain__c in (SELECT ID  FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID and Priority__c = 'High') ORDER BY AcctPlanWalletByDomain__r.WalletDomain__c ];
             }
             return actiondomainList;
        
       } set;
       }
       
       
       public Map<Decimal,String> DomainMap2 {get{
        //if(DomainMap2 ==null){

          DomainMap2 = new Map<Decimal,String>();
          boolean isSet = false;      
            
           for(AcctPlanWalletByDomain__c w: actiondomainList){
                for(CustomDomain__c c: Cusdomain){
                if( isSet == false){
                    if(w.WalletDomain__c == Decimal.ValueOf(c.Name) ){
                    isSet = true;
                    DomainMap2.put(Decimal.ValueOf(c.Name),c.DomainName__c);
                    }
                    else{
                    DomainMap2.put(w.WalletDomain__c,w.WalletDomain__c+'. N/A');
                    }  
                  }// check found in Custom setting
                }
                isSet = false;
            }    
        //}
       return DomainMap2;
    }set;} 
    

    
    
    public void selectPriority(){
                try{
                Set<String> s1 = new Set<String>();
                s1.add('High');
                s1.add('Medium');

              if(selectedHigh=='High'||selectedHigh=='Medium'){
                actiondomainList = [SELECT ID,                                      
                                    Opportunity__c,
                                    WalletDomain__c ,Priority__c ,SubDomain__c ,TypeOfNI__c 
                                    FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID and Priority__c = : selectedHigh  ORDER BY WalletDomain__c ];
                 actionplandomainList = [Select id, AcctPlanWalletByDomain__r.id from AcctPlanActionPlan__c where AcctPlanWalletByDomain__c in (SELECT ID  FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID and Priority__c =: selectedHigh ) ORDER BY AcctPlanWalletByDomain__r.WalletDomain__c ];
                }else if(selectedHigh=='All'){
                    actiondomainList = [SELECT ID,                                      
                                    Opportunity__c,
                                    WalletDomain__c ,Priority__c ,SubDomain__c ,TypeOfNI__c 
                                    FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID ORDER BY  WalletDomain__c ];
                                   // FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID and Priority__c IN : s1 ORDER BY Priority__c ,WalletDomain__c ];
                    actionplandomainList = [Select id, AcctPlanWalletByDomain__r.id from AcctPlanActionPlan__c where AcctPlanWalletByDomain__c in (SELECT ID  FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c = :WalletID ) ORDER BY AcctPlanWalletByDomain__r.WalletDomain__c ];  
                } 
                    
                    //System.debug('PriorityOptionList '+PriorityOptionList);
                    //System.debug('selectedPriority '+selectedHigh);
                } catch(Exception Ex){
                    
                }
        
    }
    
    public integer ZERO {get;set;}
    public Map<Id,List<AcctPlanStakeholder__c>> StakeHolderMap {get{
        if(StakeHolderMap ==null){
            StakeHolderMap = new Map<Id,List<AcctPlanStakeholder__c>>();
        }
        return StakeHolderMap;
    }set;} 
    
     public Map<Id,List<Task>> TaskMap {get{
        if(TaskMap ==null){
            TaskMap = new Map<Id,List<Task>>();
        }
        return TaskMap;
    }set;} 
    
        public List<AcctPlanActivity__c>  actionactivityList {
        get {
            if(actionactivityList == null){
            
            system.debug('ActionPlanID '+ActionPlanID);
                if(ActionPlanID!=null){
                actionactivityList = [SELECT ID, Group__c,Activities__c,Date__c,CustomerCounterparties__c,Visit_Plan_Report__c , Visit_Plan_Report__r.Status__c,TaskId__c,CheckOther__c , Other__c FROM AcctPlanActivity__c WHERE AccountPlanActionPlanID__c = : ActionPlanID ORDER BY Date__c ];
                }else{
                actionactivityList= new List<AcctPlanActivity__c>();     
                }
                    system.debug('actionactivityList '+actionactivityList);
           /*     for(AcctPlanActivity__c a: actionactivityList){
                if(a.TaskId__c != null){
                TaskList = [SELECT ID,Subject,Status FROM Task WHERE Id = : a.TaskId__c ];
                TaskMap.put(Id.valueOf(a.TaskId__c),TaskList );
                }
                }
                
                for(Task t: TaskList){
                TaskMap.get(t.id).add(t);
                } */
           
            }
          /*  List<AcctPlanStakeholder__c> StakeholderList =  [select Id,User__c,User__r.Name,AcctPlanActivity__c  from AcctPlanStakeholder__c where AcctPlanActivity__c IN : actionactivityList ];
            
            
            for(AcctPlanActivity__c acti : actionactivityList){
                List<AcctPlanStakeholder__c> stakesList = new List <AcctPlanStakeholder__c>();
                StakeHolderMap.put(acti.id,stakesList);
            }
            //Put Users (Stakeholders) to map in each Action Activity
            for(AcctPlanStakeholder__c stake : StakeholderList){
              
                StakeHolderMap.get(stake.AcctPlanActivity__c).add(stake);
              
            }*/
            
            getStakeHolder(actionactivityList );
            getTask(actionactivityList );
            //System.debug('actionactivityList Size '+actionactivityList.size());
            //System.debug('actionactivityList '+actionactivityList);
            //System.debug(StakeHolderMap);
             return actionactivityList ;
        
       } set;
       } 
       
    //public List<AcctPlanActivity__c> ActivityList {get;set;}
    public Map<String,List<AcctPlanActivity__c>> ActivityMap {get;set;}
    public List<AcctPlanActivity__c> CustomerCounterpartiesIDSet {get;set;}
       public void actSummary(){
       
       system.debug(' #####--actSummary--#### ' );
       getWallet();
       system.debug('WalletID '+WalletID );
       /*===== Account Plan 5.2 : Jantanee Saetung=====*/    
           List<AcctPlanActionPlan__c> ActionPlanList = [SELECT Id 
                                                         FROM AcctPlanActionPlan__c 
                                                         WHERE AcctPlanWalletByDomain__r.AcctPlanWallet__c =:WalletID];
           Set<ID> ActionPlanIDSet = new Set<ID>();
           for(AcctPlanActionPlan__c item : ActionPlanList){
               ActionPlanIDSet.add(item.id);
           }
           List<AcctPlanActivity__c> ActivityList =  [SELECT ID,Status__c , Group__c,
                            Activities__c,Date__c,
                            CustomerCounterparties__c,
                            CustomerCounterparties__r.FirstName,
                            CustomerCounterparties__r.Last_Name__c,
                            Visit_Plan_Report__c,TaskId__c, 
                            isBook__c,Other__c,CheckOther__c,
                            Visit_Plan_Report__r.Status__c                          
                            FROM AcctPlanActivity__c 
                            WHERE AccountPlanActionPlanID__c IN :ActionPlanIDSet
                            ORDER BY CustomerCounterparties__c ASC NULLS LAST,Group__c];
           
           CustomerCounterpartiesIDSet = new List<AcctPlanActivity__c>();
           ActivityMap = new Map<String,List<AcctPlanActivity__c>>();
           
           for(AcctPlanActivity__c item : ActivityList){
               
               system.debug('item.CustomerCounterparties__c = '+item.CustomerCounterparties__c);
               system.debug('item.CustomerCounterparties__c = '+item.CustomerCounterparties__r.FirstName  );
               system.debug('item = '+item);
               
               String CustomerCounterparties;
                if(item.CustomerCounterparties__c != null){
                    
                    CustomerCounterparties = item.CustomerCounterparties__c;
                }else{
                    CustomerCounterparties = 'None';
                }
               
               
               if(ActivityMap.containsKey(CustomerCounterparties)){
                   
                   ActivityMap.get(CustomerCounterparties).add(item);
               }else{
                   CustomerCounterpartiesIDSet.add(item);  
                   List<AcctPlanActivity__c>  AcctPlanActivityList = new List< AcctPlanActivity__c>();
                   AcctPlanActivityList.add(item);
                   ActivityMap.put(CustomerCounterparties,AcctPlanActivityList);   
               }
               
           }
           system.debug('ActivityMap.size()'+ActivityMap.size());
           getStakeHolder(ActivityList);
           getTask(ActivityList);
           
           
       if(typeBook== null) typeBook =false;
       if(typeVisit== null) typeVisit =false;
       if(typeTask== null) typeTask =false;
       String Status='';
       if(WalletID != null){
       
       try{
       domainList1 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=1];
       //system.debug('domainList1 '+domainList1 );
        }catch(Exception Ex){
       //system.debug('ActivitySum Exception ' );
       }
       
       actionactivityList1 = actSummary(domainList1);
       
       
       try{
       domainList2 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=2];
       //system.debug('domainList2 '+domainList2 );
       }catch(Exception Ex){
       //system.debug('ActivitySum Exception ' );
       }
       actionactivityList2 = actSummary(domainList2);

       
       try{
       domainList3 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=3];
       //system.debug('domainList3 '+domainList3 );
       }catch(Exception Ex){
       //system.debug('ActivitySum Exception ' );
       }
       actionactivityList3 = actSummary(domainList3);

       
       try{
       domainList4 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=4];
       //system.debug('domainList4 '+domainList4 );
       }catch(Exception Ex){
       //system.debug('ActivitySum Exception ' );
       }
       actionactivityList4 = actSummary(domainList4);


       } //if check wallet id

       }
       
       public List<AcctPlanActivity__c> actSummary(List<AcctPlanWalletByDomain__c> domainList){
       List<AcctPlanActivity__c> actList= null;
       List<AcctPlanActionPlan__c> actionplanList = new List<AcctPlanActionPlan__c>();
       AcctPlanActionPlan__c actionplan = new AcctPlanActionPlan__c();
       Set<Id> records = new Set<Id>();
       Set<Id> AcctPlanWalletByDomainID = new Set<Id>();
       for(AcctPlanWalletByDomain__c d : domainList){
            AcctPlanWalletByDomainID.add(d.id);
       }
       actionplanList = [SELECT Id, Status__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c IN : AcctPlanWalletByDomainID];
       if(actionplanList.size()>0){
        actionplan = actionplanList.get(0);
            records.add(actionplan.id);
            Status = actionplan.Status__c;

       
       }

       system.debug('actionplanList '+records);
        
       try{
       /*if(typeBook){
       actList = [SELECT ID,Status__c , Group__c,Activities__c,Date__c,CustomerCounterparties__c,Visit_Plan_Report__c,TaskId__c, isBook__c FROM AcctPlanActivity__c WHERE AccountPlanActionPlanID__c IN : records AND Visit_Plan_Report__c =null ORDER BY Date__c ];
       }else*/ if(typeVisit){
           actList = [SELECT ID,Status__c , Group__c,Activities__c,Date__c,CustomerCounterparties__c,
                      Visit_Plan_Report__c,TaskId__c, isBook__c,Other__c,CheckOther__c 
                      FROM AcctPlanActivity__c 
                      WHERE AccountPlanActionPlanID__c IN : records 
                      AND Visit_Plan_Report__c =null and TaskId__c =null  
                      ORDER BY Date__c ]; //remove CustomerCounterparties__c!=null
       
       }else if(typeTask){
       actList = [SELECT ID,Status__c , Group__c,Activities__c,Date__c,CustomerCounterparties__c,
                  Visit_Plan_Report__c,TaskId__c, isBook__c,Other__c,CheckOther__c 
                  FROM AcctPlanActivity__c 
                  WHERE AccountPlanActionPlanID__c IN : records 
                  AND Visit_Plan_Report__c =null and TaskId__c =null  
                  ORDER BY Date__c ]; //remove CustomerCounterparties__c=null
       }else{
       actList = [SELECT ID,Status__c , Group__c,Activities__c,Date__c,CustomerCounterparties__c,
                  Visit_Plan_Report__c ,TaskId__c, Visit_Plan_Report__r.Status__c,Other__c,CheckOther__c 
                  FROM AcctPlanActivity__c 
                  WHERE AccountPlanActionPlanID__c IN : records 
                  ORDER BY Date__c ];
       }
       }catch(Exception Ex){
       //system.debug('ActivitySum Exception ' );
       }
       //system.debug('actList '+actList);
       if(actList != null){
       for(AcctPlanActivity__c ac : actList){
       ac.Status__c = Status;
       }
       getStakeHolder(actList);
       getTask(actList);
       }
       
       return actList;
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
         
                public void getTask(List<AcctPlanActivity__c> actionactivityList ){
                Set<String> records = new Set<String>();
                for(AcctPlanActivity__c a: actionactivityList){
                system.debug('a.TaskId__c '+a.TaskId__c);
                if(a.TaskId__c != null){
                system.debug('a.TaskId__c '+a.TaskId__c);
                records.add(a.TaskId__c);
                //TaskList = [SELECT ID,Subject,Status FROM Task WHERE Id = : a.TaskId__c ];
                TaskList = new List<Task>();
                TaskMap.put(Id.valueOf(a.TaskId__c),TaskList );
              
                }
                }
                TaskList = [SELECT ID,Subject,Status FROM Task WHERE Id IN : records ];
                system.debug('TaskList '+TaskList );
                system.debug('TaskMap '+TaskMap);
               
              /* 
                for(Task t: TaskList){
                TaskMap.put(t.id,TaskList);
                } 
                system.debug('TaskMap '+TaskMap); */
                for(Task t: TaskList){
                TaskMap.get(t.id).add(t);
                } 
                system.debug('TaskMap '+TaskMap);
            
         }
            

           
            
       
    /*   public void getBookActivity(){
       typeBook = true;
       bookSummary(); 
       }  */
       
       public void getBookActivityToVisit(){
       typeVisit = true;
       bookSummary();
       getAccount();
       getAccountName();
       }
       
       public void getBookActivityToTask(){
       typeTask = true;
       bookSummary();
       }
       
       public void bookSummary(){
       actSummary();
       for(AcctPlanActivity__c book: actionactivityList1 ){
                bookActList.add(book);
        }
        for(AcctPlanActivity__c book: actionactivityList2 ){
                bookActList.add(book);
        }
        for(AcctPlanActivity__c book: actionactivityList3 ){
                bookActList.add(book);
        }
        for(AcctPlanActivity__c book: actionactivityList4 ){
                bookActList.add(book);
        }
       }
       
       public List<AcctPlanActivity__c> getActSelect(){
       system.debug('getActSelect');
       
       List<AcctPlanActivity__c> act = new List<AcctPlanActivity__c>(); 
        for(AcctPlanActivity__c book: actionactivityList1 ){
            isExist = true;
            if(book.isBook__c){
            bSelected++;
            act.add(book);
            }
        }
        for(AcctPlanActivity__c book: actionactivityList2 ){
                isExist = true;
                if(book.isBook__c){
                bSelected++;
                act.add(book);
                }
        }
        for(AcctPlanActivity__c book: actionactivityList3 ){
                isExist = true;
                if(book.isBook__c){
                bSelected++;
                act.add(book);
                }
        }
        for(AcctPlanActivity__c book: actionactivityList4 ){
                isExist = true;
                if(book.isBook__c){
                bSelected++;
                act.add(book);
                }
         }
         system.debug(act);
         return act;
       }
       
       
       public void newVisit(){
       system.debug('New visit');
       bSelected = 0;
       isVisit = false;
       
       List<AcctPlanActivity__c> activity = new List<AcctPlanActivity__c>();
       activity = getActSelect();
        
       if(isExist){ 
       system.debug('bselected '+bSelected);
       if(bSelected>=1){
         isVisit=true;
         getAccount();
         getAccountName();
         system.debug('AccountID '+AccountID);
         //for(AcctPlanActivity__c actvt: activity ){
         ActivityID='';
         integer size=activity.size();
         system.debug('size '+size);
         for(integer i=0; i<size;i++ ){
            if(i==size-1){
            ActivityID+= activity.get(i).id;
            }else{
            ActivityID+= activity.get(i).id+',';
            }
            }
         //ActivityID=activity.id ; 
         //visit.Account_Plan_Activity =activity.id;
         system.debug('ActivityID '+ActivityID);
         /*PageReference visitPage = new PageReference('/a0A/e?CF00N9000000DneE6='+AccountName+'&CF00N9000000DneE6_lkid='+AccountID+'&retURL=%2F'+AccountID);
         //PageReference visitPage = new ApexPages.StandardController(visit).view();
          system.debug('visitPage '+visitPage);
          visitPage.setRedirect(true);
          return visitPage; */
                   //gotoObj();
        }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please select at least one activity record.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5001').Status_Message__c));
        
        }
        
        ////isExist
        }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'There is no available activities (with user counterparty) to book to Visit Plan/Report.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5002').Status_Message__c));
        
        }
        
        }
       
   /*   public PageReference gotoObj() {
              system.debug('gotoObj ');
          //PageReference objPage = new ApexPages.StandardController(obj).view();
          PageReference objPage = new PageReference('/a0A/e?CF00N9000000DneE6='+AccountName+'&CF00N9000000DneE6_lkid='+AccountID+'&retURL=%2F'+AccountID);
          objPage.setRedirect(true);
          return objPage;
         
      } */

       
       public void newTask(){
       system.debug('New task');
       bSelected = 0;
       isTask = false;
       
       List<AcctPlanActivity__c> activity = new List<AcctPlanActivity__c>();
       activity = getActSelect();
       
       if(isExist){ 
       system.debug('bselected '+bSelected);
       if(bSelected>=1){
         isTask =true;
         getAccount();
         getAccountName();
         system.debug('AccountID '+AccountID);
         ActivityID='';
         integer size=activity.size();
         system.debug('size '+size);
         for(integer i=0; i<size;i++ ){
            if(i==size-1){
            ActivityID+= activity.get(i).id;
            }else{
            ActivityID+= activity.get(i).id+',';
            }
            }
         //ActivityID=activity.id ; 
         //visit.Account_Plan_Activity =activity.id;
         system.debug('ActivityID '+ActivityID);
         
         User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
         System.debug('user : '+us);
         string segment = us.Segment__c;
         //String recordTypeName='';
          TaskURL= '/apex/TaskCreation?AccountID='+AccountID+'&ActivityID='+ActivityID+'&isdtp=vw';
         
         if(segment == 'CB' || segment == 'MB' ){
         TaskURL= '/apex/TaskCreationWBG?AccountID='+AccountID+'&ActivityID='+ActivityID+'&isdtp=vw';
        
        }else{
        TaskURL= '/apex/TaskCreation?AccountID='+AccountID+'&ActivityID='+ActivityID+'&isdtp=vw';

        }
         
        }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please select at least one activity record.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5001').Status_Message__c));
        
        }
        
        ////isExist
        }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'There is no available activities to book to Task.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5003').Status_Message__c));
        
        }
        
        
        }
        
       
       public List<AcctPlanActivity__c> bookActList {get{
        if(bookActList == null){
            bookActList = new List<AcctPlanActivity__c>();
        }
        return bookActList ;
        }set;}
       
       /*public void bookActivity(){
       
       
       }*/
  
    
        public List<AcctPlanNIProject__c>  NIProjectList {
        get {
            if(NIProjectList  == null){
                NIProjectList  = [SELECT ID,GroupCount__c,PropsProductOrServices__c,DealProbability__c, 
                                  NIRecuringType__c,FeeRecuringType__c,NIStartMonth__c,NIStartYear__c,
                                  FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,
                                  ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,
                                  ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,
                                  StandardInitiative__c,NonStandardInitiative__c,
                                  ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalFeePerYear2Year__c,
                                  Opportunity__c,Opportunity__r.StageName,Opportunity__r.Probability ,Description__c
                                  FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c =: ActionPlanID 
                                  ORDER BY Group__c , GroupCount__c  ];
            }
             return NIProjectList  ;
        
       } set;
       }
    public List<AcctPlanNIProject__c>  NIProjectListAll {
        get {
            if(NIProjectListAll  == null){
                getWallet();
                List<AcctPlanWalletByDomain__c > walletByDomainList  = [SELECT Id FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c  = :WalletID  ];
                
                List<AcctPlanActionPlan__c> actionplanListAll = [SELECT Id FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c = :walletByDomainList  ];
                NIProjectListAll  = [SELECT ID FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c =:actionplanListAll];
            }
             return NIProjectListAll  ;
        
       } set;
       }
    
    public void NISummary(){
    
    try{
    
    system.debug(' #####NISummary#### ' );
    getWallet();
    system.debug('WalletID '+WalletID );
    //ActionPlanID = 'a1LO00000014o41';
   /* Set<Id> domainIds = new Set<Id>();
    List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID ];
    for(AcctPlanWalletByDomain__c d : domainList){
    domainIds.add(d.id);
    }
    Set<Id> actPlanIds = new Set<Id>();
    List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Status__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c IN :domainIds];
    for(AcctPlanActionPlan__c ap : actionplanList ){
    actPlanIds.add(ap.id);
    }
    system.debug(actPlanIds );
    NIProjectListNoOpt = [SELECT ID,Group__c, PropsProductOrServices__c,DealProbability__c, NIRecuringType__c,NIStartMonth__c,NIStartYear__c,FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,StandardInitiative__c,NonStandardInitiative__c,ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalFeePerYear2Year__c FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c IN : actPlanIds and Opportunity__c = null  ];
    NIProjectListOpt= [SELECT ID,Group__c, PropsProductOrServices__c,DealProbability__c, NIRecuringType__c,NIStartMonth__c,NIStartYear__c,FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,StandardInitiative__c,NonStandardInitiative__c,ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalFeePerYear2Year__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.Probability FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c IN : actPlanIds and Opportunity__c != null ORDER BY Opportunity__c  ];
    */
    
       try{
       domainNIList1 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=1];
       system.debug('domainNIList1 '+domainNIList1 );
        }catch(Exception Ex){
       system.debug('domainNIList1  Exception ' );
       }
       
       NIProjectList1 = NISummary(domainNIList1);
       
       try{
       domainNIList2 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=2];
       system.debug('domainNIList2 '+domainNIList1 );
        }catch(Exception Ex){
       system.debug('domainNIList2  Exception ' );
       }
       
       NIProjectList2 = NISummary(domainNIList2);
       
       try{
       domainNIList3 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=3];
       system.debug('domainNIList3 '+domainNIList3 );
        }catch(Exception Ex){
       system.debug('domainNIList3  Exception ' );
       }
       
       NIProjectList3 = NISummary(domainNIList3);
       
       try{
       domainNIList4 = [SELECT Id FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c =: WalletID and WalletDomain__c=4];
       system.debug('domainNIList4 '+domainNIList4 );
        }catch(Exception Ex){
       system.debug('domainNIList4  Exception ' );
       }
       
       NIProjectList4 = NISummary(domainNIList4);
       
               
    }catch(Exception Ex){
    
    }
    
    }
    
    
       public List<AcctPlanNIProject__c> NISummary(List<AcctPlanWalletByDomain__c> domainNIList){
       List<AcctPlanNIProject__c> NIList= null;
       List<AcctPlanActionPlan__c> actionplanList = null;
       Set<Id> records = new Set<Id>();
       Set<Id> walletdomainIDs = new Set<Id>();
       for(AcctPlanWalletByDomain__c d : domainNIList){
           walletdomainIDs.add(d.id); 
       }
       /*for(AcctPlanWalletByDomain__c d : domainNIList){
           try{
           	actionplanList = [SELECT Id, Status__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c = :d.id];
           }catch(Exception Ex){
           	system.debug('ActivitySum Exception ' );
           }
         	 system.debug('actionplanList  '+actionplanList );
           if(actionplanList != null){
           	records.add(actionplanList.id);
           }
        
        
       }*/
            try{
           	actionplanList = [SELECT Id, Status__c FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c = :walletdomainIDs];
           }catch(Exception Ex){
           	system.debug('ActivitySum Exception ' );
           }
         	 system.debug('actionplanList  '+actionplanList );
           if(actionplanList.size() > 0){
               for(AcctPlanActionPlan__c item :actionplanList){
                   records.add(item.id);
               }
           	
           }
           
       try{
      NIList =  [SELECT ID,GroupCount__c, PropsProductOrServices__c,DealProbability__c, 
                 NIRecuringType__c,FeeRecuringType__c,NIStartMonth__c,NIStartYear__c,
                 FeeStartMonth__c,FeeStartYear__c,TypeOfNI__c,TypeOfFee__c,ExpectedNimRate__c,
                 ExpectedFeeRate__c,ExpectedIncrementalNIPerYear2Year__c,
                 ExpectedIncrementalNIPerYear1Year__c,ExpectedIncremental__c,
                 StandardInitiative__c,NonStandardInitiative__c,ExpectedIncrementalFeePerYear1Year__c,
                 ExpectedIncrementalFeePerYear2Year__c,Opportunity__c,Opportunity__r.StageName,
                 Opportunity__r.Probability ,Description__c
                 FROM AcctPlanNIProject__c 
                 WHERE AcctPlanActionPlanID__c  IN : records ORDER BY Group__c , GroupCount__c  ];
   
      
       }catch(Exception Ex){
       system.debug('NIList  Exception ' );
       }
       system.debug('NIList '+NIList );

       
       return NIList;
       }
       
    
/*
    public boolean displayPopup {get; set;}    

   

    public void closePopup() 
    {       
        displayPopup = false;   
    }    

    public void showPopup() 
    {   
        displayPopup = true;   

    }
    */
    
    
    public void RequiredField()
{
  // Checks if record exists else throw below error message
  //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Objective and Status.');
  //ApexPages.addMessage(myMsg);
  ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5030').Status_Message__c));
        
        
}

    public PageReference UpdateCompletion(){
        if(CompanyID!=null){
          AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CompanyID);
          UpdateComprofile();
        }
        return null;
    }
}