/**********************************************************************
* Project           : Account Plan 5.2
* Author            : Jittramas Kumpeepong / jtk@ii.co.th
* Date created      : 2016-10-10
* Purpose           : To control when user new , edit and clone Executive Summary 
*                     on Customer Single View compatible with desktop,SF1,console
*
* Revision History  :
* Date        Author      Ref    Revision Desrciption
* 2010-10-28  JK            1    First Drop.
* 2019-11-04  JK            2    Order availableyear by DESC , Check owner permission(Account owner)
*
/**********************************************************************/
public class ExecutiveSummaryCtrl {
    public ApexPages.StandardController ctrl;
    public String CompanyID {get;set;}
    public String GroupID {get;set;}
    public String WalletID {get;set;}
    public String AccountID {get;set;}
    public String ExecutiveSummaryID {get;set;}
    public Account acct {get;set;}
    public List<AcctPlanProdStrategy__c> productstgyThisyear {get;set;}
    public List<AcctPlanProdStrategy__c> productstgyLastyear {get;set;}
    public List<AcctPlanActivity__c> actionactivityList {get;set;}
    public List<AcctPlanActionPlan__c> actionplanList {get;set;}
    public Executive_Summary__c ExecutiveSummary {get;set;}
    public Executive_Summary__c ExecutiveSummaryClone {get;set;}
    public Boolean isDisable {get;set;}
    public Boolean isNewByOwn {get;set;}
    public Boolean isNew {get;set;}
    public Boolean isEdit {get;set;}
    public Boolean SelectAcctPlanMode {get;set;}
    public List<SelectOption> availableyear {get;set;}
    public String SelectedYear {get;set;}
    public Boolean isSF1 {get;set;}
    public Boolean isClone {get;set;}
    public Boolean isRefresh {get;set;}
    public Boolean isHasPermission {get;set;}
    public Boolean isOwner {get;set;}
    public String warningMsg {get;set;}
    public String errorMsg {get;set;}
    AcctPlanCompanyProfile__c lastyear {get;set;}
    public string redirectMobileID {get;set;}
    public boolean isSaveSuccess {get;set;}
    
    public ExecutiveSummaryCtrl(ApexPages.StandardController controller){
        ExecutiveSummaryID = ApexPages.currentPage().getParameters().get('ID');
        AccountID =  ApexPages.currentPage().getParameters().get('CF'+Account_Search_Parameters__c.getValues('Customer Name').FieldID__c+'_lkid');
        isClone = (ApexPages.currentPage().getParameters().get('clone') == '1')? true:false;
        system.debug('## is clone : '+isClone);
        isDisable = false; 
        isRefresh = false;
        isHasPermission = false;
        isNew = false;
        isOwner = false;
        isNewByOwn = false;
        isEdit = false;
        isSF1 = isSF1();
        SelectAcctPlanMode =false;
        availableyear = new List<SelectOption>();
        System.debug('AccountID '+AccountID );
        redirectMobileID = '';
        isSaveSuccess = false;
        // get Executive Summary
        if(ExecutiveSummaryID != null && ExecutiveSummaryID != ''){
            isEdit = true;
            List<Executive_Summary__c> ExecutiveSummaryList = AccountPlanUtilities.QueryExecutiveSummaryByID(ExecutiveSummaryID);
            if(ExecutiveSummaryList.size()>0){
                ExecutiveSummary = ExecutiveSummaryList.get(0);
            }
            // mode edit that cannot get Account
            if(AccountID == null){
                acct = [SELECT ID,OwnerId,Owner.Name,Owner.ManagerId, NIIc_Actual__c,NIId_Actual__c,Fee_Actual__c,As_of_date_Wallet__c from Account WHERE ID =:ExecutiveSummary.Customer_Name__c LIMIT 1];
                system.debug('acct : '+acct);
            }
        // mode new that get Account from AccountID (getParameters from URL)
        }else if(AccountID!=null){
            ExecutiveSummary = new Executive_Summary__c();
            acct = [SELECT ID,OwnerId,Owner.Name,Owner.ManagerId, NIIc_Actual__c,NIId_Actual__c,Fee_Actual__c,As_of_date_Wallet__c from Account WHERE ID =:AccountID LIMIT 1];
            
            ExecutiveSummary.Customer_Name__c  = acct.id;
            ExecutiveSummary.RM_Owner_Name__c = acct.OwnerId;
            ExecutiveSummary.Team_Head__c = acct.Owner.ManagerId;
            // check avaliable account plan
            for(AcctPlanCompanyProfile__c  comlist : [SELECT ID,Year__c from AcctPlanCompanyProfile__c 
                                                          WHERE Account__c =:acct.id ORDER BY Year__c DESC
                                                           
                                                           ] )
            {
                availableyear.add(new SelectOption(comlist.id,comlist.Year__C));                                         
            }
            
            if(availableyear.size()>0){
               SelectAcctPlanMode =true;
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Account_Plan_Status_Code__c.getValues('7002').Status_Message__c));
                isDisable = true;
            }
                
        }

        if(isClone){
            ExecutiveSummary.Talk_Point__c = '';
        } 
        
        // call method
        CannotNewExecbyOwn(); 
        warningMsg = Account_Plan_Status_Code__c.getValues('7003').Status_Message__c;
        errorMsg = Account_Plan_Status_Code__c.getValues('7002').Status_Message__c;
        cancleSF1();
        checkUserPermission();
        checkSharingPermission();
        
    }//--- End constructor ---
    
    public void selectAcctPlan(){
        SelectAcctPlanMode = false;
        ExecutiveSummary.Account_Plan_Company_Profile__c = SelectedYear;
    }

    /*** Retrieve values from step of Account Plan that pick from Account Plan Company Profile year ***/
    public void retrieveAcctPlan(Id selectedYear){
        system.debug('## retrieveAcctPlan acctId : '+acct.Id);
        if((acct.As_of_date_Wallet__c.startsWith('1') 
            || acct.As_of_date_Wallet__c.startsWith('2') 
            ||acct.As_of_date_Wallet__c.startsWith('3')) ){
            
            List<String> asofdate = acct.As_of_Date_Wallet__c.split(' ');
            String year_asofdate = asofdate[2];
		   	Integer year_today = (Integer)system.today().Year();
            if(year_asofdate == String.valueOf(year_today)){
                ExecutiveSummary.Run_Rate_NIIc_This_Year__c = (acct.NIIc_Actual__c==null)? 0 :acct.NIIc_Actual__c;
                ExecutiveSummary.Run_Rate_NIId_This_Year__c = (acct.NIId_Actual__c==null)? 0 :acct.NIId_Actual__c;
                ExecutiveSummary.Run_Rate_Fees_This_Year__c = (acct.Fee_Actual__c==null)? 0 :acct.Fee_Actual__c;
                ExecutiveSummary.Total_Run_Rate_This_Year__c = ExecutiveSummary.Run_Rate_NIIc_This_Year__c  + ExecutiveSummary.Run_Rate_NIId_This_Year__c + ExecutiveSummary.Run_Rate_Fees_This_Year__c;
           
            }else{
                ExecutiveSummary.Run_Rate_NIIc_This_Year__c = 0;
                ExecutiveSummary.Run_Rate_NIId_This_Year__c = 0;
                ExecutiveSummary.Run_Rate_Fees_This_Year__c = 0;
                ExecutiveSummary.Total_Run_Rate_This_Year__c = 0;
            }
          }else{
              ExecutiveSummary.Run_Rate_NIIc_This_Year__c = 0;
              ExecutiveSummary.Run_Rate_NIId_This_Year__c = 0;
              ExecutiveSummary.Run_Rate_Fees_This_Year__c = 0;
              ExecutiveSummary.Total_Run_Rate_This_Year__c = 0;  
          }
        
        
        /*MM*/ system.debug('## ExecutiveSummary.Total_Run_Rate_This_Year__c : '+ExecutiveSummary.Total_Run_Rate_This_Year__c);
        /*** Account Plan selected year ***/
        AcctPlanCompanyProfile__c thisyear = AccountPlanUtilities.QueryCompanyProfileByID(selectedYear).get(0);
        system.debug('## this year : '+thisyear.Year__c);
        /*MM*/ system.debug('## this year : '+thisyear.Account__c);
        // assign values  
        ExecutiveSummary.This_Year__c = thisyear.Year__c;                                      
        ExecutiveSummary.TMB_Customer_Since__c = thisyear.CustomerSince__c;
        ExecutiveSummary.Business_Established_Since__c = thisyear.EstablishedSince__c;
        ExecutiveSummary.No_of_Employee__c = thisyear.NoOfEmployee__c;
        ExecutiveSummary.Company_Industry_Info__c = thisyear.Company_Industry_Info__c; 
        ExecutiveSummary.Business_Code__c = thisyear.Business_Code__c;
        ExecutiveSummary.Other_Information__c = thisyear.Other_Information__c;
        ExecutiveSummary.Shareholding_Structure__c = thisyear.ShareholdingStructure__c;
        ExecutiveSummary.TMB_Business__c = thisyear.TMB_Business__c;
        ExecutiveSummary.Financial_Highlight__c = thisyear.FinancialHighlight__c;

        /*** Wallet this year ***/
        ExecutiveSummary.Wallet_NIIc_This_Year__c = null;
        ExecutiveSummary.Expected_Incremental_NIIc__c = null;
        ExecutiveSummary.Wallet_NIId_This_Year__c = null;
        ExecutiveSummary.Expected_Incremental_NIId__c = null;
        ExecutiveSummary.Wallet_Fees_This_Year__c = null;
        ExecutiveSummary.Expected_Incremental_Fees__c = null;
        ExecutiveSummary.Total_Wallet_This_Year__c = null;
        ExecutiveSummary.Total_Expected_Incremental__c = null;
        Decimal TXFee = 0;
        Decimal FXFee = 0;
        Decimal LGFee = 0;
        Decimal cashFee = 0;
        Decimal ASFee = 0;
        Decimal creditFee = 0;
        Decimal BAFee = 0;
        Decimal DerivativeFee = 0;
        Decimal IBFee = 0;

        productstgyThisyear = AccountPlanUtilities.QueryProductStrategyByCompanyProfileID(selectedYear);
        system.debug('## productstgyThisyear : '+productstgyThisyear);
        if(productstgyThisyear.size() >  0){
            for(AcctPlanProdStrategy__c productstgyItem : productstgyThisyear){
                if(productstgyItem.Name == '1. NIIc'){
                    ExecutiveSummary.Wallet_NIIc_This_Year__c = (productstgyItem.WalletSizing__c==null)? 0 : productstgyItem.WalletSizing__c;
                    ExecutiveSummary.Expected_Incremental_NIIc__c = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '2. NIId'){
                    ExecutiveSummary.Wallet_NIId_This_Year__c = (productstgyItem.WalletSizing__c==null)? 0 : productstgyItem.WalletSizing__c;
                    ExecutiveSummary.Expected_Incremental_NIId__c = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3. Fee'){
                    ExecutiveSummary.Wallet_Fees_This_Year__c = (productstgyItem.WalletSizing__c==null)? 0 : productstgyItem.WalletSizing__c;
                    
                }
                 else if(productstgyItem.Name == '3.1 TF Fee'){
                    TXFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.2 FX Fee'){
                    FXFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.3 L/G Fee'){
                    LGFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.4 Cash Fee'){
                    cashFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.5 AS Fee'){
                    ASFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.6 Credit Fee'){
                    creditFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.7 BA Fee'){
                    BAFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.8 Derivative Fee'){
                    DerivativeFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }
                 else if(productstgyItem.Name == '3.9 IB Fee'){
                    IBFee = (productstgyItem.ExpectedIncrementalNIFromStep5__c==null)? 0 : productstgyItem.ExpectedIncrementalNIFromStep5__c;
                }    
            }
            ExecutiveSummary.Expected_Incremental_Fees__c = TXFee+FXFee+LGFee+cashFee+ASFee+creditFee+BAFee+DerivativeFee+IBFee;
            ExecutiveSummary.Total_Wallet_This_Year__c = ExecutiveSummary.Wallet_NIId_This_Year__c + ExecutiveSummary.Wallet_NIIc_This_Year__c + ExecutiveSummary.Wallet_Fees_This_Year__c;
            ExecutiveSummary.Total_Expected_Incremental__c = ExecutiveSummary.Expected_Incremental_NIIc__c + ExecutiveSummary.Expected_Incremental_NIId__c + ExecutiveSummary.Expected_Incremental_Fees__c;
            /*MM*/ system.debug('## ExecutiveSummary.Expected_Incremental_Fees__c : '+ExecutiveSummary.Expected_Incremental_Fees__c);
            /*MM*/ system.debug('## ExecutiveSummary.Expected_Incremental_NIIc__c : '+ExecutiveSummary.Expected_Incremental_NIIc__c);
            /*MM*/ system.debug('## ExecutiveSummary.Expected_Incremental_NIId__c : '+ExecutiveSummary.Expected_Incremental_NIId__c);            
        }else{
            // assign 0 to these fields
            ExecutiveSummary.Wallet_NIIc_This_Year__c = 0;
            ExecutiveSummary.Expected_Incremental_NIIc__c = 0;
            ExecutiveSummary.Wallet_NIId_This_Year__c = 0;
            ExecutiveSummary.Expected_Incremental_NIId__c = 0;
            ExecutiveSummary.Wallet_Fees_This_Year__c = 0;
            ExecutiveSummary.Expected_Incremental_Fees__c = 0;
            ExecutiveSummary.Total_Wallet_This_Year__c = 0;
            ExecutiveSummary.Total_Expected_Incremental__c = 0;
        }

        /*** Actual last year ***/
        
        //List<AcctPlanCompanyProfile__c> lastyear = new List<AcctPlanCompanyProfile__c>();
        String lastyearExp = String.valueOf(Integer.valueOf(thisyear.Year__c) - 1);
        /*MM*/ system.debug('## lastyearExp : '+lastyearExp);
        try{
            lastyear = [SELECT Id, Name, Year__c 
                        FROM AcctPlanCompanyProfile__c 
                        WHERE Account__c =: thisyear.Account__c AND Year__c =: lastyearExp LIMIT 1];
            system.debug('## last year : '+lastyear.Year__c);
            system.debug('## last year : '+lastyear);
        }catch(Exception ex){
            /*MM*/ system.debug('## last year msg Error : '+ex.getMessage());
            /*MM*/ system.debug('## last year cause Error : '+ex.getCause());
            /*MM*/ system.debug('## last year line Error : '+ex.getLineNumber());
            lastyear = null;
        }
        
        if(lastyear != null){
            ExecutiveSummary.Last_Year__c  = lastyear.Year__c;
        }else {
            ExecutiveSummary.Last_Year__c  = lastyearExp;
        }
        retrieveAnnualPerformance(acct.Id,Decimal.valueOf(lastyearExp));
        
        retrieveAcctPlanActivity();
        

    }

    /*** Get Actual Last year fields ***/
    public void  retrieveAnnualPerformance(Id accountId,Decimal last_year){
        List<AggregateResult> annualResults = [ SELECT SUM(Fee__c) fee,SUM(NIIc__c) niic,SUM(NIId__c) niid 
                                                    FROM AcctAnnualPerformance__c
                                                    WHERE Account__c =: accountId AND Year__c =:last_year
                                                    GROUP BY Account__c];
        system.debug('## annualResults : '+annualResults);
        if(annualResults.size() > 0){
            for(AggregateResult actualLastyear : annualResults){
                ExecutiveSummary.Actual_NIIc_Last_Year__c = (Decimal)actualLastyear.get('niic');
                ExecutiveSummary.Actual_NIId_Last_Year__c = (Decimal)actualLastyear.get('niid');
                ExecutiveSummary.Actual_Fees_Last_Year__c = (Decimal)actualLastyear.get('fee');
                ExecutiveSummary.Total_Actual_Last_Year__c = ExecutiveSummary.Actual_NIIc_Last_Year__c +  ExecutiveSummary.Actual_NIId_Last_Year__c + ExecutiveSummary.Actual_Fees_Last_Year__c;
            }
        }
        else{
            ExecutiveSummary.Actual_NIIc_Last_Year__c = 0;
            ExecutiveSummary.Actual_NIId_Last_Year__c = 0;
            ExecutiveSummary.Actual_Fees_Last_Year__c = 0;
            ExecutiveSummary.Total_Actual_Last_Year__c = 0;
        }
    }
    // Properties for Account Plan Activity
    public class ActivityPack{
        public String activityDate {get;set;}
        public String activity {get;set;}
        public String other {get;set;}
        public String counterparties {get;set;}
    }

    /*** Action ***/  
    // DB : wallet > walletByDomain > acctPlanActionPlan > acctPlanActivity
    public void retrieveAcctPlanActivity(){

        ActivityPack activityPack = new ActivityPack();
        ExecutiveSummary.Action__c = '';
        ExecutiveSummary.Customer_Strategy__c = ''; 
        AcctPlanWallet__c wallet; 

        try{
            wallet = AccountPlanWalletUtilities.queryWalletbyCompanyID(ExecutiveSummary.Account_Plan_Company_Profile__c).get(0); 
        }catch(Exception ex){
            /*MM*/ system.debug('## wallet msg Error : '+ex.getMessage());
            /*MM*/ system.debug('## wallet cause Error : '+ex.getCause());
            /*MM*/ system.debug('## wallet line Error : '+ex.getLineNumber());
            wallet = null;
        }
        
        if(wallet != null){

        
            List<AcctPlanWalletByDomain__c> domainList = [SELECT Id,WalletDomain__c 
                                                          FROM AcctPlanWalletByDomain__c
                                                          WHERE AcctPlanWallet__c = :wallet.Id];
            system.debug('## domainList = '+domainList.size());
            
                 actionplanList = [SELECT Id, Objective__c, Status__c, WinningPropostion__c
                                  FROM AcctPlanActionPlan__c
                                  WHERE AcctPlanWalletByDomain__c IN :domainList];
                
                system.debug('## actionplanList = '+actionplanList.size());
                    actionactivityList = [SELECT ID, AccountPlanActionPlanID__c, Date__c,
                                      Other__c, CustomerCounterparties__c,CustomerCounterparties__r.Name , Activities__c 
                                      FROM AcctPlanActivity__c
                                      WHERE AccountPlanActionPlanID__c IN :actionplanList
                                      AND Date__c  >= Today
                                      ORDER BY Date__c];
                
                system.debug('## actionactivityList = '+actionactivityList.size());
    
                // map into Action field
                if(actionactivityList.size() > 0){
                    for(AcctPlanActivity__c actionactivityItem : actionactivityList){
                        activityPack.activityDate = String.valueOf(actionactivityItem.Date__c.format() );
                        activityPack.activity = String.isEmpty(actionactivityItem.Activities__c)? '' : ' , '+actionactivityItem.Activities__c;
                        activityPack.other = String.isEmpty(actionactivityItem.Other__c)? '' : ' , '+actionactivityItem.Other__c;
                        activityPack.counterparties = String.isEmpty(actionactivityItem.CustomerCounterparties__r.Name)? '' : ' , '+actionactivityItem.CustomerCounterparties__r.Name;
                        ExecutiveSummary.Action__c += '- ' + activityPack.activityDate + activityPack.activity + activityPack.other + activityPack.counterparties+'\n';
                        system.debug('## ExecutiveSummary.Action__c : '+ExecutiveSummary.Action__c);
                    } 
                }
                else{
                    ExecutiveSummary.Action__c = '';
                }
                retrieveNIProject(actionplanList);
            

        } //end wallet != null
        else{
            ExecutiveSummary.Action__c = '';
        } 
        
    }

    // Properties for NI project
    public class CustStgPack{
        public String productName {get;set;}
        public String strategy {get;set;}
        public decimal expectedNIProjectnum {get;set;}
        public String expectNIthisyear {get;set;}
    }

    /*** Customer Strategy ***/
    public void retrieveNIProject(List<AcctPlanActionPlan__c> actionplanList){

        
        CustStgPack custStgPack = new CustStgPack(); 

        List<AcctPlanNIProject__c> acctPlanNIProjectList = [SELECT ID,Name,Description__c,Product__c,Group__c,Product__r.Name,
                                                            ExpectedIncrementalFeePerYear1Year__c,ExpectedIncrementalNIPerYear1Year__c
                                                            FROM AcctPlanNIProject__c 
                                                            WHERE AcctPlanActionPlanID__c =: actionplanList
                                                            ORDER BY AcctPlanActionPlanID__r.AcctPlanWalletByDomain__r.Domain__c,Group__c ];


        system.debug('## acctPlanNIProjectList = '+acctPlanNIProjectList);                                                   
        if(acctPlanNIProjectList.size() > 0){
            for(AcctPlanNIProject__c acctPlanNIProjectItem : acctPlanNIProjectList){
                custStgPack.productName = String.isEmpty(acctPlanNIProjectItem.Product__r.Name)? '': acctPlanNIProjectItem.Product__r.Name;
                custStgPack.strategy = String.isEmpty(acctPlanNIProjectItem.Description__c)? '' : ' , '+ acctPlanNIProjectItem.Description__c ;
                Double NIPerYear = acctPlanNIProjectItem.ExpectedIncrementalNIPerYear1Year__c==null? 0:acctPlanNIProjectItem.ExpectedIncrementalNIPerYear1Year__c;
                Double FeePerYear = acctPlanNIProjectItem.ExpectedIncrementalFeePerYear1Year__c==null?0:acctPlanNIProjectItem.ExpectedIncrementalFeePerYear1Year__c;
                CustStgPack.expectedNIProjectnum = NIPerYear + FeePerYear;
                custStgPack.expectNIthisyear = (CustStgPack.expectedNIProjectnum==null)? '':' , ' +CustStgPack.expectedNIProjectnum.format() + ' THB' ;
                system.debug('## custStgPack : '+custStgPack);
                ExecutiveSummary.Customer_Strategy__c += '- '+custStgPack.productName + custStgPack.strategy + custStgPack.expectNIthisyear+'<br/>';
            }

        }else{
            ExecutiveSummary.Customer_Strategy__c = '';        
        }
    }

    /*** Save ***/
    public PageReference save(){
            retrieveAcctPlan(ExecutiveSummary.Account_Plan_Company_Profile__c);
            try{
                if(isClone){
                    CloneExecutiveSummary();
                }
                else{
                    upsert ExecutiveSummary;
                }
            }catch(DMLException e){
                system.debug('dml exception : '+e.getMessage());
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return null;
            }

        PageReference pr;
        if(isClone){
            pr =  new pagereference('/' + ExecutiveSummaryClone.id);
        }
        else{
            pr =  new pagereference('/' + ExecutiveSummary.id);
        }
        
        pr.setRedirect(true);
        return pr; 
    }
    
    public void mobileSave(){
        retrieveAcctPlan(ExecutiveSummary.Account_Plan_Company_Profile__c);
        try{
            if(isClone){
                CloneExecutiveSummary();
                redirectMobileID = ExecutiveSummaryClone.id;
            }else{
                upsert ExecutiveSummary;
                redirectMobileID = ExecutiveSummary.id;
            }
            isSaveSuccess = true;
        }catch(DMLException e){
            system.debug('dml exception : '+e.getMessage());
        }
    }

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

    /*** throw warning msg that user cannot create Executive Summary by own ***/
    public void CannotNewExecbyOwn(){
        if(String.IsEmpty(AccountID) && String.isEmpty(ExecutiveSummaryID)){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Account_Plan_Status_Code__c.getValues('7001').Status_Message__c));
            isNewByOwn = true;
        }
    }

    /*** Refresh Function on Screen ***/
    public pageReference Refresh(){
        if(isHasPermission){

        
            if(ExecutiveSummaryID !=null){
                retrieveAcctPlan(ExecutiveSummary.Account_Plan_Company_Profile__c);
                try{
                    update ExecutiveSummary;
                    isRefresh = true;
                    system.debug('## update ExecutiveSummary: '+ExecutiveSummary);
                }catch(DMLException e){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    return null;
                } 

            }
                //return null;
                PageReference pr =  new pagereference('/' + ExecutiveSummary.id);
                pr.setRedirect(true);
                if (!isSf1) return pr; else return null;
       }/*else if(!isHasPermission && !isEdit){
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Account_Plan_Status_Code__c.GetValues('7005').Status_Message__c));
        return null;
       }*/
       return null;
        
    }

    /*** Clone function on Screen ***/
   public void CloneExecutiveSummary(){
        ExecutiveSummaryClone = ExecutiveSummary.clone(false,false,false,false);
        ExecutiveSummaryClone.CloneSource__c = ExecutiveSummary.Id;
        insert ExecutiveSummaryClone;
   }

   public PageReference cancleSF1(){
    
       if(isSF1){
            if(ExecutiveSummary.Id != null){
                system.debug('##Executive Id : '+ExecutiveSummary.Id);
                return new PageReference('/'+ExecutiveSummary.Id);
            }else{
                return new PageReference('/'+AccountID);
            }
        
        }
    
    return null;
   }

   /*** Check user permission / Only account owner can create Executive Summary ***/
   public void checkUserPermission(){
        system.debug('## Account owner : ' +acct.Owner.Name);
        system.debug('## Current user : '+UserInfo.getName());
        if(UserInfo.getUserId() != acct.OwnerId && ExecutiveSummaryID ==null && AccountID != null){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Account_Plan_Status_Code__c.getValues('7003').Status_Message__c));
            isNewByOwn = true;
            isNew =true;
            isOwner = false;
        }
        else if(UserInfo.getUserId() == acct.OwnerId){
            isOwner = true;
        }
   }

   /*** Check manual sharing permission ***/
   public void checkSharingPermission(){
    List<UserRecordAccess> RecordAccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                             WHERE UserId =: UserInfo.getUserId() 
                                             AND RecordId =: ExecutiveSummary.id];
            system.debug('## checkSharingPermission RecordAccessList : '+RecordAccessList);
            if(RecordAccessList.size()>0){
                for(UserRecordAccess ura : RecordAccessList){
                    
                        if(ura.HasEditAccess){
                            isHasPermission =true;
                        }
                    
                }
            }
            if(!isHasPermission && (!isNewByOwn&&!isOwner)){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Account_Plan_Status_Code__c.GetValues('7004').Status_Message__c));
             }
             /*else if(!isHasPermission && !isEdit){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Account_Plan_Status_Code__c.GetValues('7005').Status_Message__c));
             }*/
   }
    
}