public without sharing class AccountPlanRevenueExpectationCtrl {
    private ApexPages.StandardController standardController {get;set;}
    public String CompanyID {get;set;}
    public String GroupID {get;set;}   
    public String WalletID {get;set;}
    public Boolean isPending {get;set;}
    public Integer refreshclick {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}    
    public List<ApprovalWrapper> ApprovalWrapList {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public transient List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> AcctPlanProdStrategyList {get;set;}
     
    public AcctPlanProdStrategy__c refreshProdStrategy {get;set;}
    
    public transient Decimal sumTargetNIByRm {get;set;}  
    public transient Decimal sumWalletSizing {get;set;}  
    public transient Decimal sumActualNI {get;set;}       
    public transient Decimal sumAdjustNI {get;set;}
    public transient Decimal sumExistingSOW {get;set;} 
    public transient Decimal sumExpectedNIFromStep5 {get;set;}
    public transient Decimal sumTotalCompanyNI {get;set;}    
    
    public Map<String,Decimal> mapFeeCompanyWallet {get;set;}
    public Map<String,Decimal> mapFeeCompanyActualNI {get;set;}    
    public Map<String,Decimal> mapFeeCompanyAdjustNI {get;set;}
    public Map<String,Decimal> mapFeeCompanyExistingSOW {get;set;}
    public Map<String,Decimal> mapFeeCompanyExpectedNIFromStep5 {get;set;}

    public Boolean isMiniView {get;set;} 
    public boolean isHasPermission {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public Boolean isHasGroup {get;set;}
    public Boolean isHasPortfolio {get;set;}
    
    public class ApprovalWrapper implements Comparable{
        public String submitdatetime {get;set;}
        public String Status {get;set;}
        public User AssignedTo {get;set;}
        public User ActualApprover {get;set;}
        public String Comments {get;set;}
        public String OverallStatus {get;set;}
        public String StepStatus {get;set;}
        //used to sort
         public Datetime lastupdate{get;set;}
         
         
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ApprovalWrapper compareToOppy = (ApprovalWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.lastupdate  > compareToOppy.lastupdate ) {
            // Set return value to a positive value.
            returnValue = -1;
            } else if (this.lastupdate  < compareToOppy.lastupdate ) {
            // Set return value to a negative value.
            returnValue = 2;
            } else if (this.lastupdate  == compareToOppy.lastupdate ) {
            // Set return value to a negative value.
            returnValue = 1;
            }
            
            return returnValue;       
        }
         
    }
    
    public AccountPlanRevenueExpectationCtrl(ApexPages.StandardController controller){
        standardController = controller;
        
        sumTargetNIByRm = 0;
        sumWalletSizing = 0;
        sumActualNI = 0;
        sumAdjustNI = 0;
        sumExistingSOW = 0;
        sumExpectedNIFromStep5 = 0;
        sumTotalCompanyNI = 0;
        
        refreshclick =0;
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
        isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
        isHasPortfolio = false;

        if(CompanyID !=null && CompanyID !=''){
           AcctPlanProdStrategyList = AccountPlanProductStrategyService.getCompaniesProductStrategyInfo(new Set<ID> { CompanyID });

            companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyID);
            ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
            System.debug(AccountPlanUtilities.OWNERSEGMENT);
            if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
            
             List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_2_Percentage__c ,
                      Account_Plan_Completion_Percentage__c , 
                      Step_2_Entered_Fields__c ,                                          
                      Step_2_Required_Fields__c
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                 if(CompleteList.size()>0){
                 Acctplancompletion = CompleteList.get(0);
             }       
            
            ApprovalEx();

            if(companyprofile.Portfolio__c !=null ){
               isHasPortfolio = true; 
            }
        }      
        
        AccountPlanProdStrategyInfoDisplay(AcctPlanProdStrategyList); 

        isHasGroup = false;
        if(GroupID!=null && GroupID!=''){
            isHasGroup = true;
        }

       
        
    }    
        
    public void ApprovalEx(){
         Set<String> UsersSet = new Set<String>();
        ApprovalWrapList = new List<ApprovalWrapper>();
        System.debug('companyprofile.ProcessSteps : '+companyprofile.ProcessSteps);
            for(Sobject sobj : companyprofile.ProcessSteps){
               UsersSet.add(String.valueof(sobj.get('ActorId')));
               UsersSet.add(String.valueof(sobj.get('OriginalActorId')));
               
            }
        
        Map<ID,User> UserMap = new Map<ID,User>([SELECT id,Firstname,LastName FROM USER
                                                WHERE ID =: UsersSet]);

            isPending = false; 
        List<SObject> SObjLists  = companyprofile.ProcessSteps;
        for(integer i=0 ;i < SObjLists.size(); i++){
            
            Sobject sobj =  SObjLists.get(i);
            //for(Sobject sobj : companyprofile.ProcessSteps){
            ApprovalWrapper app = new ApprovalWrapper();
            app.lastupdate = (DateTime)sobj.get('CreatedDate');
            app.submitdatetime = String.valueof(sobj.get('CreatedDate'));
                TimeZone tz = UserInfo.getTimeZone();
                DateTime correctedDateTime = app.lastupdate;
                app.submitdatetime = correctedDateTime.format(app.lastupdate.format(),tz.getDisplayName());
            app.status = String.valueof(sobj.get('StepStatus'))=='Started'?'Submitted': String.valueof(sobj.get('StepStatus'));
            app.comments = String.valueof(sobj.get('Comments'));
            app.AssignedTo = UserMap.get(String.valueof(sobj.get('ActorId')));
            app.ActualApprover = UserMap.get(String.valueof(sobj.get('OriginalActorId')));
            //app.OverallStatus = String.valueof(sobj.get('IsPending'));
            
            if(app.Status =='Submitted'){
                app.Stepstatus = 'Approval Request Submitted';
            }else{
                app.Stepstatus = 'Step: Step1';
            }
            
            
            if(String.valueof(sobj.get('IsPending')) =='true'){
                app.OverallStatus  = 'Pending';
                app.Stepstatus += ' (Pending for first approval)';
                isPending = true;  
            }
            if(app.status =='Removed'){
                app.OverallStatus  = 'Recalled';
                app.Stepstatus = 'Approval Request Recalled';
                app.status = 'Recalled';
            }
            
            
            
            ApprovalWrapList.add(app);
        }
        
        ApprovalWrapList.sort();        
    }
    
     public PageReference ApprovalExRemoteAction(){
        // Refresh data
        
       if(CompanyID !=null && CompanyID !=''){
        companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyID);
      }
        ApprovalEx();
        refreshclick++;
        return null;
    }
    
    public pageReference Refreshfunction(){         
        
        sumTargetNIByRm = 0;
        sumWalletSizing = 0;
        sumActualNI = 0;
        sumAdjustNI = 0;        
        sumExistingSOW = 0;
        sumExpectedNIFromStep5 = 0;
        sumTotalCompanyNI = 0;
                
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');  
        	
        try{
            if(CompanyID !=null && CompanyID !=''){
                
                Boolean refreshResult = AccountPlanRefreshService.RefreshCompanyPerformanceProductStrategyForStep6(CompanyID, WalletID, GroupID);      
                if(refreshResult){                    
                    AcctPlanProdStrategyList = AccountPlanProductStrategyService.getCompaniesProductStrategyInfo(new Set<ID> { CompanyID });
                    AccountPlanProdStrategyInfoDisplay(AcctPlanProdStrategyList);                    
                }
            }
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
                
        return null;
    }    

	public void AccountPlanProdStrategyInfoDisplay(List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> acctPlanProdStrategyList){
        
        List<AcctPlanCompanyPort__c> companyPort  = AccountPlanCompanyPortSelector.getTargetNIByRMById(new Set<ID> { CompanyID });
        if(companyPort.size() > 0) sumTargetNIByRm  = companyPort[0].Target_NI_By_RM__c;
        
        calculateFeeCompany(acctPlanProdStrategyList);        
        
        integer index = 1;
        for(AccountPlanProductStrategyService.AcctPlanProdStrategyInfo item : acctPlanProdStrategyList){

            //find Fee in '3. Fee' row.
            if(item.Name == '3. Fee'){
            	//item.WalletSizing = mapFeeCompanyWallet.get(item.Name);
                //item.AnnualizedPerformance = mapFeeCompanyActualNI.get(item.Name);
                Decimal AdjustNI = mapFeeCompanyAdjustNI.get(item.Name);
                item.AdjustNI = AdjustNI;
                decimal companyExistingSOWFee = item.WalletSizing != 0 ? ((AdjustNI / item.WalletSizing)*100).setScale(4) : 0;
                item.ExistingSOW = companyExistingSOWFee;
                //item.ExistingSOW = mapFeeCompanyExistingSOW.get(item.Name); 
                Decimal ExpectedIncrementalNIFromStep5 = mapFeeCompanyExpectedNIFromStep5.get(item.Name);
                item.ExpectedIncrementalNIFromStep5 = ExpectedIncrementalNIFromStep5;
                item.TotalCompanyNI = AdjustNI + ExpectedIncrementalNIFromStep5;
            }
            
            //Find total value in footer row
            if(index <=3){
                sumWalletSizing += item.WalletSizing;                
                sumActualNI += item.AnnualizedPerformance;                
                sumAdjustNI += item.AdjustNI;                
        		//sumExistingSOW += item.ExistingSOW;                
                sumExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
                sumTotalCompanyNI += item.TotalCompanyNI;
            }            
            index++;
        }
        
        decimal sumExistingSOWFooter = sumWalletSizing != 0 ? ((sumAdjustNI / sumWalletSizing)*100).setScale(4) : 0;
       	sumExistingSOW = sumExistingSOWFooter;
               
        if(acctPlanProdStrategyList.size() > 0){
            refreshProdStrategy = [SELECT Id, Name, RefreshAsOf__c 
                                  FROM AcctPlanProdStrategy__c
                                  WHERE Id =:acctPlanProdStrategyList[0].Id];
        }
        
    }     
    
	private void calculateFeeCompany(List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> acctPlanProdStrategyList){
        if(mapFeeCompanyWallet == null) mapFeeCompanyWallet = new Map<String,Decimal>();
        if(mapFeeCompanyActualNI == null) mapFeeCompanyActualNI = new Map<String,Decimal>(); 
        if(mapFeeCompanyAdjustNI == null) mapFeeCompanyAdjustNI = new Map<String,Decimal>();
        if(mapFeeCompanyExistingSOW == null) mapFeeCompanyExistingSOW = new Map<String,Decimal>();
        if(mapFeeCompanyExpectedNIFromStep5 == null) mapFeeCompanyExpectedNIFromStep5 = new Map<String,Decimal>();
        
        Decimal feeCompanyWallet = 0;
    	Decimal feeCompanyActualNI = 0;
    	Decimal feeCompanyAdjustNI = 0;  
    	Decimal feeCompanyExistingSOW = 0; 
        Decimal feeCompanyExpectedNIFromStep5 = 0;
        for(AccountPlanProductStrategyService.AcctPlanProdStrategyInfo item : acctPlanProdStrategyList){
                        
            if(item.Name == '3.1 TF Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.2 FX Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.3 L/G Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.4 Cash Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.5 AS Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.6 Credit Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.7 BA Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.8 Derivative Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.9 IB Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3. Fee' && AccountPlanUtilities.OWNERSEGMENT != null && AccountPlanUtilities.OWNERSEGMENT == 'SE'){
            	feeCompanyWallet = item.WalletSizing; 
            }
        }
        
        mapFeeCompanyWallet.put('3. Fee', feeCompanyWallet);
        mapFeeCompanyActualNI.put('3. Fee', feeCompanyActualNI);
        mapFeeCompanyAdjustNI.put('3. Fee', feeCompanyAdjustNI);
        
     	decimal companyExistingSOWFee = feeCompanyWallet != 0 ? ((feeCompanyAdjustNI / feeCompanyWallet)*100).setScale(4) : 0;
     	mapFeeCompanyExistingSOW.put('3. Fee', companyExistingSOWFee);
        
        mapFeeCompanyExpectedNIFromStep5.put('3. Fee', feeCompanyExpectedNIFromStep5);
    }
        
}