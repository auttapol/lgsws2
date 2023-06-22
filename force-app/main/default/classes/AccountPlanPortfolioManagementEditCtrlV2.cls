public without sharing class AccountPlanPortfolioManagementEditCtrlV2 {
    public AcctPlanPortfolio__c  portfolio {get;set;}
    transient public Integer tempGroupNum {get;set;}
    transient public Integer tempCustomerNum {get;set;}
    public final String portfolioID;
    public String infoMsg {get;set;}
    //Start Pagination
    Public Integer noOfRecords{get; set;}
    Public Integer size {get;set;}
    public ApexPages.StandardSetController setCon;
    public class companyPortWrapper {
        transient public String groupName {get;set;}
        transient public Boolean hasGroupProfile {get;set;}
        transient public Id groupProfile {get;set;}
        transient public AcctPlanCompanyPort__c comport {get;set;}
    }
    public Map<Id,AcctPlanCompanyPort__c> Accountwithgroup;
    public List<companyPortWrapper> companyPortListEdit {get{ 
        companyPortListEdit = new List<companyPortWrapper>();
        if((List<AcctPlanCompanyPort__c>)setcon.getRecords() != null){
            ID groupProfileID ;
            String groupProfileName ='';
            for(AcctPlanCompanyPort__c acct : (List<AcctPlanCompanyPort__c>)setcon.getRecords()){
                if(Accountwithgroup.containsKey(acct.Account__c)){
                    companyPortWrapper comportitem = new companyPortWrapper();
                    String groupName = 'None';
                    if(acct.AcctPlanGroupPort__c  != null){        
                        groupName = acct.AcctPlanGroupPort__r.Name+'';
                        if(acct.AcctPlanGroupPort__r.Account_Plan_Group_Profile__c != null){
                            comportitem.hasGroupProfile = true;
                        }
                    } 
                    comportitem.groupName = groupName;
                    comportitem.comport = Accountwithgroup.get(acct.Account__c);                
                    companyPortListEdit.add(comportitem);
                }
            }          
        }        
        return companyPortListEdit;
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
    //public List<AcctPlanCompanyPort__c> CompanyPortList;  
    //End Pagination
    
    public String FiltersOption {get;set;}
    public AccountPlanPortfolioManagementEditCtrlV2(ApexPages.StandardController controller){
        portfolioID = ApexPages.currentPage().getParameters().get('id');
        if(portfolioID !=null && portfolioID !=''){
            portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
            FiltersOption = 'Flag';
            size = 100;
            AccountPlanFilters();
        }else{
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any ID')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('0001').Status_Message__c));
        
        }  
        infoMsg = Account_Plan_Status_Code__c.GetValues('0013').Status_Message__c;
    }
    
    public void AccountPlanFilters(){
        List<AcctPlanCompanyPort__c> CompanyPortList;
        if(FiltersOption=='Flag'){
            setCon = new ApexPages.StandardSetController(AccountPlanUtilities.QueryCompanyPortbyPortIDFlag(portfolio.id));
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDFlag(portfolio.id);
        }else if(FiltersOption=='Target'){
            setCon = new ApexPages.StandardSetController(AccountPlanUtilities.QueryCompanyPortbyPortIDTarget(portfolio.id));
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDTarget(portfolio.id);
        }else if(FiltersOption=='Group'){
            setCon = new ApexPages.StandardSetController(AccountPlanUtilities.QueryCompanyPortbyPortIDGroup(portfolio.id));
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDGroup(portfolio.id);
        }
        //limit 1000
        /*CompanyPortList = [SELECT ID,Account__c,Account_Name__c,Account__r.id,
                                                        AcctPlanGroupPort__c,AcctPlanGroupPort__r.Group_Name__c,
                                                        Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,
                           
                                                        ExpectedNIbyAccountPlan__c
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portfolio.id
                                                        AND Available_for_Account_Plan__c = true
                                                        ORDER BY AcctPlanGroupPort__r.Group__r.Name ASC NULLS LAST,Account__r.id
                                                       LIMIT 1500];*/
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        SetPortTabledata(CompanyPortList);   
    }
    
    transient public Map<String,List<AcctPlanCompanyPort__c>> MapAccountwithgroup;
    public void SetPortTabledata(List<AcctPlanCompanyPort__c> ComList){
        tempCustomerNum =0;
        tempGroupNum = 0;        
        Accountwithgroup = new Map<Id,AcctPlanCompanyPort__c>();
        MapAccountwithgroup = new Map<String,List<AcctPlanCompanyPort__c>>();
        companyPortListEdit = new List<companyPortWrapper>();
        for(AcctPlanCompanyPort__c comport : ComList){  
            Accountwithgroup.put(comport.Account__r.id,comport);
            if(comport.AcctPlanGroupPort__c !=null){
                if(MapAccountwithgroup.containsKey(comport.AcctPlanGroupPort__c)){
                    MapAccountwithgroup.get(comport.AcctPlanGroupPort__c).add(comport);
                }else{
                    List<AcctPlanCompanyPort__c > comportList = new List<AcctPlanCompanyPort__c >();
                    comportList.add(comport);
                    MapAccountwithgroup.put(comport.AcctPlanGroupPort__c,comportList);
                    tempGroupNum++;
                }                
            }else{
                if(MapAccountwithgroup.containsKey('None')){
                    MapAccountwithgroup.get('None').add(comport);
                }else{
                    List<AcctPlanCompanyPort__c > comportList = new List<AcctPlanCompanyPort__c >();
                    comportList.add(comport);
                    MapAccountwithgroup.put('None',comportList);  
                }                
            }                              
        }
        tempCustomerNum =ComList.size(); 
        
    }    
    public pageReference redirect(){
        PageReference pr = Page.AccountPlanPortfolioManagementEditV2;
        pr.setRedirect(true);
        pr.getParameters().put('id',portfolio.id);
        return pr; 
    } 
    public pageReference updateTargetNI(){
        List<AcctPlanCompanyPort__c> updateList = new List<AcctPlanCompanyPort__c>();
        Double tempTotalTarget = 0;  
        portfolio.SumOfWallet__c  = 0;
        portfolio.SumOfTargetNIByRM__c = 0;
        portfolio.SumOfPerformance__c = 0;
        portfolio.SumOfExpectedNIByAcctPlan__c = 0;  
        List<AcctPlanCompanyPort__c> CompanyPortList;
        if(FiltersOption=='Flag'){
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDFlag(portfolio.id);
        }else if(FiltersOption=='Target'){
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDTarget(portfolio.id);
        }else if(FiltersOption=='Group'){
            CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDGroup(portfolio.id);
        }
        for(AcctPlanCompanyPort__c comportw : CompanyPortList){
            updateList.add(Accountwithgroup.get(comportw.Account__r.id));               
        }
        try{
            update updateList;            
            portfolio.SumOfTargetNIByRM__c = tempTotalTarget;
            portfolio.Status__c = 'In Progress';
            List<AcctPlanCompanyPort__c> CompanyPortListtotal = AccountPlanUtilities.QueryCompanyPortbyPortID(portfolio.id);
            for(AcctPlanCompanyPort__c comport : CompanyPortListtotal){  
                if(comport.Wallet__c != null){
                    portfolio.SumOfWallet__c +=comport.Wallet__c;
                }
                if(comport.Target_NI_By_RM__c !=null){
                    portfolio.SumOfTargetNIByRM__c +=comport.Target_NI_By_RM__c;
                    tempTotalTarget +=comport.Target_NI_By_RM__c;
                }
                if(comport.Performance__c !=null){
                    portfolio.SumOfPerformance__c += comport.Performance__c;
                }
                if(comport.ExpectedNIbyAccountPlan__c != null){
                    portfolio.SumOfExpectedNIByAcctPlan__c += comport.ExpectedNIbyAccountPlan__c;
                } 
            }
            update portfolio;
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
            return null;
        }       
        PageReference pr = Page.AccountPlanPortfolioManagementV2;
        pr.setRedirect(true);
        pr.getParameters().put('id',portfolio.id);
        return pr;  
    }
}