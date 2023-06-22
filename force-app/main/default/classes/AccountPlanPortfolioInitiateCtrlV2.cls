public without sharing class AccountPlanPortfolioInitiateCtrlV2 {
    public AcctPlanPortfolio__c  portfolio {get;set;}
    public String YearStr {get;set;}
    private ApexPages.StandardController standardController {get;set;}
    public List<Target__c> TargetList {get;set;}
    public Integer tempCustomerNum {get;set;}
    public Integer tempGroupNum {get;set;}
    public Map<String,List<AcctPlanCompanyPort__c>> MapAccountwithgroup {get;set;}
    public Map<String,AcctPlanGroupPort__c> MapGroupPort {get;set;} 
    public Map<Id,AcctPlanCompanyProfile__c> ExistingComProfileMap {get;set;}
    public Map<Id,AcctPlanGroupProfile__c> ExistingGroupProfileMap  {get;set;}
    public Set<String> GroupCompanySequenceSet {get;set;} 
    public Date currentDate {get;set;}
    public List<Date> AnnualDate {get;set;}
    public Map<Id,AcctPlanCompanyPort__c> Accountwithgroup {get;set;}
    public Boolean hasNonGroup {get;set;}
    public Boolean isReadyToSave {get;set;}
    transient public Map<String,AccountPlanRefreshService.CustomerWalletInfo> walletinfoMap {get;set;}    
    public List<SelectOption> getFiscalYear(){
        List<SelectOption> fiscalyearoption = new List<SelectOption>();
        List<Account_Plan_Fiscal_Year__c> yearlistitem = [SELECT ID,Name,AD_Year__c,BE_Year__c
                                                          FROM Account_Plan_Fiscal_Year__c 
                                                          WHERE ID!=null
                                                          ORDER BY Name];
        fiscalyearoption.add(new SelectOption('','None'));
        for(Account_Plan_Fiscal_Year__c year : yearlistitem){
            fiscalyearoption.add(new SelectOption(year.AD_Year__c,year.AD_Year__c));
        }         
        return fiscalyearoption;
    }
    
    
    //Start Pagination
    Public Integer noOfRecords{get; set;}
    Public Integer size {get;set;}
    public ApexPages.StandardSetController setCon {get{
        if(setCon ==null){
            size = 100; 
            setCon = new ApexPages.StandardSetController([SELECT ID,Name,Group__r.Name,Group__c
                                                          FROM Account
                                                          WHERE OwnerId =: Userinfo.getUserId()
                                                          AND Account_Plan_Flag__c ='Yes' 
                                                          ORDER BY Group__r.Name ASC NULLS LAST,id 
                                                          LIMIT 1500]);
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        }
        return setCon; 
        
    }set;} 
    public class companyPortWrapper {
        public String groupName {get;set;}
        public Boolean hasGroupProfile {get;set;}
        public Id groupProfile {get;set;}
        public AcctPlanCompanyPort__c comport {get;set;}
    }
    //public List<companyPortWrapper> companyPortList {get;set;}
    public List<companyPortWrapper> companyPortList {get{ 
        companyPortList = new List<companyPortWrapper>();
        if(GroupCompanySequenceSet != null){
            ID groupProfileID ;
            String groupProfileName ='';
            for(Account acct : (List<Account>)setcon.getRecords()){
                companyPortWrapper comportitem = new companyPortWrapper();
                String groupName = 'None';
                if(acct.Group__c != null){        
                    groupName = acct.Group__r.Name+'';
                    if(ExistingComProfileMap.containsKey(acct.id)){   
                        if(ExistingComProfileMap.get(acct.id).AcctPlanGroup__c !=null){
                            comportitem.groupProfile = ExistingComProfileMap.get(acct.id).AcctPlanGroup__c;
                            comportitem.hasGroupProfile =true;
                            groupProfileID = ExistingComProfileMap.get(acct.id).AcctPlanGroup__c;
                            groupName = ExistingComProfileMap.get(acct.id).AcctPlanGroup__r.GroupName__c;
                            groupProfileName = groupName;  
                                                      
                        }
                    }else if(ExistingGroupProfileMap.containsKey(acct.Group__c)){
                             groupProfileID = ExistingGroupProfileMap.get(acct.Group__c).id;
                             groupName = ExistingGroupProfileMap.get(acct.Group__c).GroupName__c; 
                             groupProfileName = groupName;           
                    }


                    if(groupName !='None' && groupProfileName != ''){
                        comportitem.groupProfile = groupProfileID;
                        comportitem.hasGroupProfile =true;
                    }else{
                        comportitem.hasGroupProfile =false;
                    }
                }else{
                    comportitem.hasGroupProfile =false;
                } 

                comportitem.groupName = groupName;
                comportitem.comport = Accountwithgroup.get(acct.id);                
                companyPortList.add(comportitem);
            }             
        }        
        return companyPortList;
    }set;}    
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }  
    public void first() {
        setCon.first();
    }  
    public void last() {
        setCon.last();
    }  
    public void previous() {
        setCon.previous();
    }  
    public void next() {
        setCon.next();
    }
    public AccountPlanPortfolioInitiateCtrlV2(ApexPages.StandardController controller){
        standardController = controller;
        currentDate = System.today();
        isReadyToSave = false;
        AnnualDate = new List<Date>();
        portfolio = new AcctPlanPortfolio__c();    
    }
    
    public void selectedYear(){
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'After selecting year, please click Refresh button to view list of customers.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, Account_Plan_Status_Code__c.GetValues('0002').Status_Message__c));
        portfolio.Year__c = YearStr;
        isReadyToSave = false;
    }
    
    public pageReference Refreshfunction(){
        List<Account> AccountList = new List<Account>();
        List<AcctPlanPortfolio__c> PortList = [SELECT ID,OwnerID,Year__C
                                               From AcctPlanPortfolio__c
                                               WHERE Year__c =: portfolio.Year__c
                                               AND SalesOwner__c =:Userinfo.getUserId()];

        /***** Checck Duplicate Portfolio Management *****/
        
        if(PortList.size() > 0){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Year :'+portfolio.Year__c+'. RM Portfolio already exists.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0003A').Status_Message__c+portfolio.Year__c+Account_Plan_Status_Code__c.GetValues('0003B').Status_Message__c));
            return null;     
        }else{
            AccountList = [SELECT ID,Name, First_Name_PE__c , Industry,Last_Name_PE__c  ,Group__c,Account_Plan_Flag__c,
                           Group__r.Name,
                           Group__r.GroupCompany__c ,
                           //Group__r.GroupIndustry__c , //mm
                           Group__r.Parent_Company__c ,
                           //Group__r.ParentIndustry__c, //mm
                           Group__r.UltimateParent__c 
                           FROM Account
                           WHERE OwnerId =: Userinfo.getUserId()
                           AND Account_Plan_Flag__c ='Yes'
                           ORDER BY Group__r.Name ASC NULLS LAST,id
                           LIMIT 1500];
            
            if(AccountList.size()>0){
                /***** Get Annual and Wallet *****/
                String tempids = '';
               Set<ID> groupMasterID = new Set<ID>(); 
                for(Account acct : AccountList){
                    tempids += acct.id+',';
                    if(acct.Group__c !=null){
                        groupMasterID.add(acct.Group__c);
                    }
                }          
                String ids = tempids.substring(0,tempids.length()-1);
                walletinfoMap  = new Map<String,AccountPlanRefreshService.CustomerWalletInfo>();
                List<AccountPlanRefreshService.CustomerWalletInfo> WalletInfoList = AccountPlanRefreshService.initialStep0(ids);
                if(WalletInfoList !=null){
                    if(WalletInfoList.size()>0){
                        for(AccountPlanRefreshService.CustomerWalletInfo walletInfo : WalletInfoList){
                            walletinfoMap.put(walletInfo.Id,walletInfo);
                        }
                    }
                }
                /***** Get Company Profile *****/
                List<AcctPlanCompanyProfile__c> ExistingComProfileList = [SELECT ID,Year__c,Account__c,Account__r.name,AcctPlanGroup__r.GroupName__c,
                                                                            AcctPlanGroup__c,AcctPlanGroup__r.Group__c, Portfolio__c
                                                                          FROM AcctPlanCompanyProfile__c
                                                                          WHERE Year__c =: portfolio.Year__c
                                                                          AND Account__c IN: AccountList];
                    
                  ExistingGroupProfileMap = new Map<Id,AcctPlanGroupProfile__c>();
                  ExistingComProfileMap = new Map<Id,AcctPlanCompanyProfile__c>();
                for(AcctPlanCompanyProfile__c comprofile : ExistingComProfileList){
                    ExistingComProfileMap.put(comprofile.Account__c,comprofile);
                    if(comprofile.AcctPlanGroup__c !=null){
                        groupMasterID.add(comprofile.AcctPlanGroup__r.Group__C);
                    }
                }

                 /***** Get Group Profile *****/
                List<AcctPlanGroupProfile__c> ExistingGroupProfileList = [SELECT ID,Year__c,Group__c,group__r.Name,GroupName__c
                                                                          FROM AcctPlanGroupProfile__c
                                                                          WHERE Year__c =: portfolio.Year__c
                                                                          AND Group__c IN: groupMasterID]; 

                 
                 for(AcctPlanGroupProfile__c groupProfile : ExistingGroupProfileList){
                    ExistingGroupProfileMap.put(groupProfile.group__C,groupProfile);

                 }                                                         
                                                                                                                                     
                
               
                /***** Set Portfolio *****/
                SetPortTableData(AccountList);
                
                if(tempCustomerNum >0){
                    isReadyToSave= true;
                }
                /***** Set Target in Portfolio *****/ 
                portfolio.SalesOwner__c = Userinfo.getUserId();
                Date tempDate = currentDate;
                portfolio.AsOf__c = currentDate.year() +'-'+currentDate.month()+'-'+ currentDate.day() ;
                portfolio.RefreshAsOf__c = System.today();
                
                Date twelvemonths = tempDate.addMonths(-12);
                TargetList = AccountPlanUtilities.QueryTargetNIbyOwnerIDandYear(Userinfo.getUserId(),Integer.valueof(portfolio.Year__c));
                Decimal TargetNI = 0;
                for(Target__C target : TargetList){
                    TargetNI +=target.NI_Target_Monthly__c;
                }
                portfolio.TargetNI__c =TargetNI;
            }else{
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any account.'));    
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0004').Status_Message__c));    
            }
            return null;             
        }
    }
    
    public void SetPortTableData(List<Account> AcctsList){        
        hasnongroup = false;
        MapGroupPort = new Map<String,AcctPlanGroupPort__c>();
        GroupCompanySequenceSet = new Set<String>();
        MapAccountwithgroup = new Map<String,List<AcctPlanCompanyPort__c>>();
        Accountwithgroup = new Map<Id,AcctPlanCompanyPort__c>();




            
        for(Account acct : AcctsList){            
            //Initiate AcctPort
            AcctPlanCompanyPort__c acctCom = new AcctPlanCompanyPort__c ();
            acctCom.Account__c = acct.id;
            acctCom.Account_Name__c = acct.Name;
            acctCom.Account_Plan_Portfolio__c = portfolio.id;



            if(ExistingComProfileMap.containsKey(acct.id)){
                acctCom.Account_Plan_Company_Profile__c = ExistingComProfileMap.get(acct.id).id;
            }            
            if(walletinfoMap.containsKey(acctCom.Account__c)){
                acctCom.Wallet__c = walletinfoMap.get(acctCom.Account__c).Wallet;
                acctCom.Performance__c = walletinfoMap.get(acctCom.Account__c).Annual;            
            }




            //Group Assign
            if(acct.Group__c !=null){                      
                //Has Group
                String groupName = acct.Group__r.Name+'';

                //for old group 
                System.debug('AccountName : '+acct.Name);
                if(ExistingComProfileMap.containsKey(acct.id)){ 
                   
                        AcctPlanCompanyProfile__c existingComProfile = ExistingComProfileMap.get(acct.id);
                        //Matching Realtime Group Profile
                        System.debug('existingComProfile :  '+existingComProfile.Account__r.name);
                        if(ExistingGroupProfileMap.containsKey(existingComProfile.AcctPlanGroup__r.Group__c)){

                            AcctPlanGroupProfile__c groupProfile  = ExistingGroupProfileMap.get(existingComProfile.AcctPlanGroup__r.Group__c);
                            System.debug('groupProfile :'+groupProfile.Group__r.Name);
                            groupName = groupProfile.Group__r.Name;
                        }

                    }

                    System.debug('groupName : '+groupName);
                GroupCompanySequenceSet.add(groupName);

                if(MapAccountwithgroup.containsKey(groupName)){
                    System.debug('ADD Existing group');
                    acctCom.AcctPlanGroupPort__c = MapGroupPort.get(groupName).id;
                    MapAccountwithgroup.get(groupName).add(acctCom);
                }else{
                    System.debug('ADD New group');
                    //New has Group
                    List<AcctPlanCompanyPort__c> acctList = new List<AcctPlanCompanyPort__c>();
                    acctlist.add(acctCom);
                   
                    
                    AcctPlanGroupPort__c  groupport = new AcctPlanGroupPort__c ();
                    groupport.Account_Plan_Portfolio__c = portfolio.id;
                    groupport.Group_Name__c =acct.group__r.Name;
                    groupport.Name =acct.group__r.Name;
                    groupport.Group__c = acct.Group__c;

                    //Matching Realtime CompanyProfile
                    if(ExistingComProfileMap.containsKey(acct.id)){ 
                        AcctPlanCompanyProfile__c existingComProfile = ExistingComProfileMap.get(acct.id);

                        //Matching Realtime Group Profile
                        if(ExistingGroupProfileMap.containsKey(existingComProfile.AcctPlanGroup__r.Group__c)){
                            AcctPlanGroupProfile__c groupProfile  = ExistingGroupProfileMap.get(existingComProfile.AcctPlanGroup__r.Group__c);
                            
                            groupport.Account_Plan_Group_Profile__c =groupProfile.id;
                            groupport.Group_Name__c =groupProfile.group__r.Name;
                            groupport.Name =groupProfile.group__r.Name;
                            groupport.Group__c = groupProfile.Group__c;
                            

                        }

                    }else if(ExistingGroupProfileMap.containsKey(acct.group__c)){
                            AcctPlanGroupProfile__c groupProfile  = ExistingGroupProfileMap.get(acct.Group__c);
                            groupport.Account_Plan_Group_Profile__c =groupProfile.id;
                            groupport.Group_Name__c =groupProfile.group__r.Name;
                            groupport.Name =groupProfile.group__r.Name;
                            groupport.Group__c = groupProfile.Group__c;
                            

                        }




                    acctCom.AcctPlanGroupPort__c = groupport.id;
                    MapGroupPort.put(groupname, groupport);
                    MapAccountwithgroup.put(groupName,acctlist);
                }
                //Initiate GroupPort                
            }else{
                //Non group
                HasNongroup = true;
                if(MapAccountwithgroup.containsKey('None')){
                    MapAccountwithgroup.get('None').add(acctCom);
                    acctCom.AcctPlanGroupPort__c = MapGroupPort.get('None').id;
                }else{
                    //New non group
                    List<AcctPlanCompanyPort__c> acctList = new List<AcctPlanCompanyPort__c>();
                    acctlist.add(acctCom);
                    MapAccountwithgroup.put('None',acctlist); 
                    
                    AcctPlanGroupPort__c  groupport = new AcctPlanGroupPort__c ();
                    groupport.Group_Name__c ='None';
                    groupport.Account_Plan_Portfolio__c = portfolio.id;
                    acctCom.AcctPlanGroupPort__c = groupport.id;
                    MapGroupPort.put('None', groupport);
                }





            }
            
            Accountwithgroup.put(acct.id,acctCom);
        }   
        
        
        
        tempGroupNum = GroupCompanySequenceSet.size();
        if(hasnongroup){
            GroupCompanySequenceSet.add('None');
            
        }
        tempCustomerNum =AcctsList.size(); 
    }
    
    public pageReference save(){
        List<AcctPlanCompanyPort__c> SelectedCustomerList = new  List<AcctPlanCompanyPort__c>();
        Set<AcctPlanGroupPort__c> SelectedGroupSet = new Set<AcctPlanGroupPort__c>();
        Map<String,List<AcctPlanCompanyPort__c>> GroupNamewithComMap = new Map<String,List<AcctPlanCompanyPort__c>>();
        double tempSumTargetRM = 0;
        if(portfolio.Year__c == null){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Portforlio Year is null.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0005').Status_Message__c));
            return null;  
        }        
        List<AcctPlanPortfolio__c> PortList = [SELECT ID,OwnerID,Year__C
                                               From AcctPlanPortfolio__c
                                               WHERE Year__c =: portfolio.Year__c
                                               AND SalesOwner__c =:Userinfo.getUserId()];
        if(PortList.size()>0){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Year :'+portfolio.Year__c+'. RM Portfolio already exists.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0003A').Status_Message__c+portfolio.Year__c+Account_Plan_Status_Code__c.GetValues('0003B').Status_Message__c));
            return null; 
        }
        for(String groupname : GroupCompanySequenceSet){
            for(AcctPlanCompanyPort__c companyport : MapAccountwithgroup.get(groupname)) {
                if(companyport.Target_NI_By_RM__c !=null ){tempSumTargetRM +=companyport.Target_NI_By_RM__c;}
                if(groupname != 'None'){
                    SelectedGroupSet.add(MapGroupPort.get(groupname));
                }
                SelectedCustomerList.add(companyport);  
            }           
        }
        User currentuser = [SELECT ID,Employee_ID__c FROM User WHERE ID =: Userinfo.getUserID() LIMIT 1];
        
        if(SelectedCustomerList.size()==0){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to input Target NI by RM at least one record.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0006').Status_Message__c));
            return null;    
        }else if(currentuser.Employee_ID__c ==null){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User does not have Employee ID.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0007').Status_Message__c));
            return null;
        }else{
            try{
                portfolio.Status__c = 'In progress';
                portfolio.Name = currentuser.Employee_ID__c+' '+Userinfo.getFirstName()+' Portfolio: '+portfolio.Year__c;
                portfolio.SumOfTargetNIByRM__c = tempSumTargetRM;
                portfolio.RefreshAsOf__c = System.Now();
                insert portfolio;
                List <AcctPlanGroupPort__c> GroupInsertList = new List<AcctPlanGroupPort__c>();
                for(AcctPlanGroupPort__c groupport :  SelectedGroupSet){
                    groupport.Account_Plan_Portfolio__c = portfolio.id;
                    GroupInsertList.add(groupport);
                }
                insert GroupInsertList;
                Map<String,AcctPlanGroupPort__c> groupportMap = new Map<String,AcctPlanGroupPort__c>();
                for(AcctPlanGroupPort__c groupport :  SelectedGroupSet){
                    groupportMap.put(groupport.Group_Name__c,groupport);
                }
                List<AcctPlanCompanyPort__c> insertcompanyList = new List<AcctPlanCompanyPort__c>();
                for(String groupname : GroupCompanySequenceSet){
                    for(AcctPlanCompanyPort__c companyport : MapAccountwithgroup.get(groupname)) {
                        if(groupname != 'None'){
                            companyport.AcctPlanGroupPort__c = groupportMap.get(groupname).id;
                        }
                        companyport.Account_Plan_Portfolio__c = portfolio.id;
                        insertcompanyList.add(companyport);                       
                    }   
                }
                insert insertcompanyList;                
                PageReference pr = Page.AccountPlanPortfolioManagementV2;
                pr.setRedirect(true);
                pr.getParameters().put('id',portfolio.id);
                return pr;  
            }catch(DMLException d){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,d.getMessage()));
                return null;
            }
        }       
    } 
}