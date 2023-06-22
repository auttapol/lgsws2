public class AccountConsoleExtension {

    public Account acct {get;set;}
    public double NiicForPie {get;set;}
    public double NiidForPie {get;set;}
    public double FeeForPie {get;set;}
    public double NiicActForPie {get;set;}
    public double NiidActForPie {get;set;}
    public double FeeActForPie {get;set;}
    public decimal totalRevenue {get;set;}
    public decimal grossProfit {get;set;}
    public decimal netProfit {get;set;}
    public decimal niPlan {get;set;}
    public decimal niicPlan {get;set;}
    public decimal niidPlan {get;set;}
    public decimal feePlan {get;set;}
    public decimal niWallet {get;set;}
    public decimal niicWallet {get;set;}
    public decimal niidWallet {get;set;}
    public decimal feeWallet {get;set;}
    public decimal niAct {get;set;}
    public decimal niicAct {get;set;}
    public decimal niidAct {get;set;}
    public decimal feeAct {get;set;}
    public decimal niSow {get;set;}
    public decimal niicSow {get;set;}
    public decimal niidSow {get;set;}
    public decimal feeSow {get;set;}
    public decimal supplyActual {get;set;} 
    //public integer openTask {get;set;}
   //public integer openVisitplan {get;set;}
    public date activityDate {get;set;}
    //public date visitDate {get;set;}
    public integer SumTransBank {get;set;}
    public integer SumDepInvest {get;set;}
    public integer SumFundBorrow {get;set;}
    public integer SumRiskProtect {get;set;}
    public double TotalTransBank {get;set;}
    public double TotalDepInvest {get;set;}
    public double TotalFundBorrow {get;set;}
    public double TotalRiskProtect {get;set;}
    public double TotalLimitTransBank {get;set;}
    public double TotalLimitRiskProtect {get;set;}
    public integer SumActTransBank {get;set;}
    public integer SumActDepInvest {get;set;}
    public integer SumActFundBorrow {get;set;}
    public integer SumActRiskProtect {get;set;}
    public id TransBankReportId {get;set;}
    public id TransBankReportId_DataPartition {get;set;}
    public id DepInvestReportId {get;set;}
    public id DepInvestReportId_DataPartition {get;set;}
    public id FundBorrowReportId {get;set;}
    public id FundBorrowReportId_DataPartition {get;set;}
    public id RiskProtectReportId {get;set;}
    public id RiskProtectReportId_DataPartition {get;set;}
    public id CreditPipeReportId {get;set;}
    public id NonCreditPipeReportId {get;set;}
    public id CollateralReportId {get;set;}
    public integer SumOpenTask {get;set;}
    public integer SumOpenVisit {get;set;}
    public integer SumOpenOpt {get;set;}
    public date LastVisitDate {get;set;}
    public Date AsOfDate {get;set;}  // Change from string to Date
    public Account tmpAcct {get;set;}
    public String type {get;set;}
    public Boolean isRenderWallet {get;set;}
    public Boolean isRenderActivity {get;set;}
    public Boolean isRenderRisk {get;set;}
    public boolean isInsufficient {get;set;}
    public boolean isTransBankReport {get;set;}
    public boolean isDepInvestReport {get;set;}
    public boolean isFundBorrowReport {get;set;}
    public boolean isRiskProtectReport {get;set;}
    public boolean isCollateralReport {get;set;}
    public boolean isPerformanceReport {get;set;}
    public boolean isRenderPayroll {get; set;}

    // CR Income Estimation
    public boolean isIncomeEstimation {get;set;}
    public List<Income_Estimation__c> prev1Month {get;set;}
    public List<Income_Estimation__c> prev2Month {get;set;}
    public String prev1MonthName {get;set;}
    public String prev2MonthName {get;set;}
    public Integer prev1year {get;set;}
    public Integer prev2year {get;set;}
    public String dash {
        get {
            return ' - ';
        }
        set;
    }



    public boolean isAccountTeam {get;set;}
    //public date LastActivityDate {get;set;}
    public List<UserRecordAccess> accessList {get;set;}
    public string pageTransBank {get;set;}
    public string pageTransBankMobile {get;set;}    
    public string pageDepInvest {get;set;}
    public string pageDepInvestMobile {get;set;}
    public string pageFundBorrow {get;set;}
    public string pageFundBorrowMobile {get;set;}
    public string pageRiskProtect {get;set;}
    public string pageRiskProtectMobile {get;set;}
    public boolean isClickTransBank {get;set;}
    public boolean isClickDepInvest {get;set;}
    public boolean isClickFundBorrow {get;set;}
    public boolean isClickRiskProtect {get;set;}
    
    //Edit by Danudath  20-04-2017
    //CR Wallet from Account plan
    public double TotalExpNi {get;set;}
    public double TotalExpNIIc {get;set;}
    public double TotalExpNIId {get;set;}
    public double TotalExpFee {get;set;} 
    public double NiSoWAccPlan {get;set;}
    public double NiicSoWAccPlan {get;set;}
    public double NiidSoWAccPlan {get;set;}
    public double FeeSoWAccPlan {get;set;}
    public Date AsOfDatefromAccPlan {get;set;}   
       
    public double NiicWalletAccPlanPie {get;set;}
    public double NiidWalletAccPlanPie {get;set;}
    public double FeeWalletAccPlanPie {get;set;}
    public double NiicExpAccPlanPie {get;set;}
    public double NiidExpAccPlanPie {get;set;}
    public double FeeExpAccPlanPie {get;set;}
    
    private Account acctDetail;
    private Profile userProfile;    
    
    public Boolean isLoading {get;set;}
    public Boolean isLoadSuccess {get;set;}
    
    public String tabId {get;set;}

    // --------------------------------------------------------------------------------------
    public String section {get;set;}
    public String section1 {get;set;}
    public String section2 {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isVisible_product {get;set;}
    public Boolean isVisible_total {get;set;}
    
    //public Account acct;

    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                hiddenText = '';
            }
            return hiddenText;
        }
        set;
    }
    
    public String notAuthorizedMsg {
        get{
            if( notAuthorizedMsg == null )
            {
                notAuthorizedMsg = '';
            }
            return notAuthorizedMsg;
        }
        set;
    }
    
    public string title {get;set;}
    public AccountConsoleExtension(ApexPages.StandardController std){
        
        acct = (Account)std.getRecord();
        //****** Get account detail and User's Profile detail *****
        //*** These data use for loggin button to Online service log ***
        acctDetail = new Account();
        userProfile = new Profile();
        
        try{
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId,Core_Banking_Suggested_Segment__c, TMB_Customer_ID_PE__c FROM Account WHERE id = :acct.id ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }catch (Exception e){ 
            system.debug( e.getMessage() );
            //exception here
        }
                  
        isLoading = true;
        isLoadSuccess = false;
        
        isRenderWallet = true;
        isRenderActivity = true;
        isRenderRisk = true;
        isInsufficient = false;
        
        isTransBankReport = false;
        isDepInvestReport = false;
        isFundBorrowReport = false;
        isRiskProtectReport = false;
        isCollateralReport = false;
        isPerformanceReport = false;
        isAccountTeam = false;

        // CR Income Estimation
        isIncomeEstimation = false;

        // CR Payroll
        isRenderPayroll = false;

        type = ApexPages.currentPage().getParameters().get('type');
        try{
            tabId = ApexPages.currentPage().getParameters().get('tabId');
        }catch(Exception e){
            tabId = '';
        }

        system.debug('tabId = '+ tabId);
        pageTransBank = '';
        pageTransBankMobile = '';
        pageDepInvest = '';
        pageDepInvestMobile = '';
        pageFundBorrow = '';
        pageFundBorrowMobile = '';
        pageRiskProtect = '';
        pageRiskProtectMobile = '';
        isClickTransBank = false;
        isClickDepInvest = false;
        isClickFundBorrow = false;
        isClickRiskProtect = false;
        
        try{
            CustSingleView__c CustSingleView7 = CustSingleView__c.GetValues('CollateralReport');
            String collateral = CustSingleView7.ReportName__c;
            CollateralReportId = [SELECT id FROM report where name = : collateral ].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception Domain5Id::::::');
        }
        
        //////////////////////////////////////////////////
        //////////////////////////////////////////////////
        //////////////////////////////////////////////////
        ////Get Parameter to render error message page////
        //////////////////////////////////////////////////
        //////////////////////////////////////////////////
        //////////////////////////////////////////////////
        if(type != null && type!= ''){
            if(type == '1'){
                title = 'Customer Wallet';
                isRenderWallet = true;
                isRenderActivity = false;
                isRenderRisk = false;
            }else if(type == '2'){
                title = 'Activity/ Pipeline';
                isRenderWallet = false;
                isRenderActivity = true;
                isRenderRisk = false;
            }
            else if(type == '3'){
                title = 'Risk Information';
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = true;
            }
            else if(type == '4'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isTransBankReport = true;
            }
            else if(type == '5'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isDepInvestReport = true;
            }
            else if(type == '6'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isFundBorrowReport = true;
            }
            else if(type == '7'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isRiskProtectReport = true;
            }
            else if(type == '8'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isCollateralReport = true;
            }
            else if(type == '9'){
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isPerformanceReport = true;
            }else if(type == '10'){
                title = 'Income Estimation';
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isIncomeEstimation = true;
            }
            else if(type == '11'){
                title = 'Payroll Estimation';
                isRenderWallet = false;
                isRenderActivity = false;
                isRenderRisk = false;
                isRenderPayroll = true;
            }
        }
        
        set<string> AccteamId = new set<String>();
        id currentuserId = Userinfo.getUserId();
        list<AccountTeamMember> accTeam = [select Id,AccountAccessLevel,AccountId,TeamMemberRole,UserId 
                                       from AccountTeamMember 
                                       where AccountId =:acct.id];
            if(accTeam.size() > 0) {
                for(AccountTeamMember acc : accTeam) {
                    AccteamId.add(acc.UserId);
                }
            }
        if(AccteamId.contains(currentuserId)){
            isAccountTeam = true;
        }
        tmpAcct = [SELECT Loan_Classification__c, SCF_Score__c
                           ,NI_Plan__c,NIIc_Plan__c,NIId_Plan__c,Fee_Plan__c
                           , NI_Wallet__c, NIIc_Wallet__c, NIId_Wallet__c, Fee_Wallet__c
                           ,NI_Actual__c, NIIc_Actual__c, NIId_Actual__c, Fee_Actual__c
                           , NI_SoW__c, NIIc_SoW__c, NIId_SoW__c, Fee_SoW__c
                           , Total_Revenue_Baht__c, Gross_Profit__c, Net_Profit_Baht__c
                           , Last_Activity_Date__c,Supply_Chain_Actual__c,As_of_date_Wallet__c
                           ,No_of_Open_Opportunities__c,Income_as_of_Wallet__c
                           , owner.UserRoleId , NI_Account_Plan__c,NIIc_Account_Plan__c,NIId_Account_Plan__c,
                           Fee_Account_Plan__c,As_of_Date_Account_Plan__c, NI_SoW_Account_Plan__c, NIIc_SoW_Account_Plan__c,
                           NIId_SoW_Account_Plan__c, Fee_Sow_Account_Plan__c
                           FROM Account WHERE id =: acct.id]; 
        
        
       //List<UserRecordAccess> accessList =
        accessList = 
           [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
        ];
        
        //String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        String pageName = ApexPages.currentPage().getUrl();
        system.debug('pageName : '+pageName);
        if(pageName != null){
            
            //if(pageName.equalsIgnoreCase('DataPartitionDetail') ){ //CustomerWallet
            if(pageName.tolowercase().contains('datapartitiondetail') ){ 
                if(accessList.size()>0){
                    System.debug(accessList);
                    if(checkAuthorize() || isAccountTeam == true){
                        System.debug('has Permission');
                        getWallet(); 
                        ActivitySummary();
                        getPipelineReportId();
                        getNonPipelineReportId();
                    }else{
                        isInsufficient = true;
                    }
                }else{
                    isInsufficient = true;
                }
                
                if(isInsufficient){
                    
                    System.debug('isInsufficient');
                    
                    String request;
                    
                    if(isRenderWallet){
                        //request ='Wallet';
                        request = Status_Code__c.getValues('4001').Status_Message__c;
                    }else if(isRenderActivity){
                        //request = 'Activity Pipeline';
                        request = Status_Code__c.getValues('4002').Status_Message__c;
                    }else if(isRenderRisk){
                        //request = 'Risk';
                        request = Status_Code__c.getValues('4003').Status_Message__c;
                    }else if(isTransBankReport){
                        //request = 'Transactional Banking Report';
                        request = Status_Code__c.getValues('4004').Status_Message__c;
                    }else if(isDepInvestReport){
                        //request = 'Deposit & investment';
                        request = Status_Code__c.getValues('4005').Status_Message__c;
                    }else if(isFundBorrowReport){
                        //request = 'Funding & Borrowing';
                        request = Status_Code__c.getValues('4006').Status_Message__c;
                    }else if(isRiskProtectReport){
                        //request = 'Risk & Protection';
                        request = Status_Code__c.getValues('4007').Status_Message__c;
                    }else if(isCollateralReport){
                        //request = 'Collateral Report';
                        request = Status_Code__c.getValues('4008').Status_Message__c;
                    }else if(isPerformanceReport){
                        //request = 'Performance Report';
                        request = Status_Code__c.getValues('4009').Status_Message__c;
                    }else if(isRenderPayroll){
                        //request = 'Performance Report';
                        request = Status_Code__c.getValues('4011').Status_Message__c;
                    }
                    
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, request));
                    //'You do not have sufficient privilege to view '+request+' information of this customer.'));
                }
            }
        }
        

          
    }
    
    public void getWallet()
    {
       // try{
        System.debug('Test Return ACC ID = '+ tmpAcct.ID);
        acct.Loan_Classification__c = tmpAcct.Loan_Classification__c;
        acct.SCF_Score__c = tmpAcct.SCF_Score__c;
        //acct.Service_class__c = tmpAcct.Service_class__c;
        
        NiicForPie =  (tmpAcct.NIIc_Wallet__c != null) ? tmpAcct.NIIc_Wallet__c : 0.00;
        NiidForPie =  (tmpAcct.NIId_Wallet__c != null) ? tmpAcct.NIId_Wallet__c : 0.00;
        FeeForPie =  (tmpAcct.Fee_Wallet__c != null) ? tmpAcct.Fee_Wallet__c : 0.00;
            
        NiicActForPie =  (tmpAcct.NIIc_Actual__c != null) ? tmpAcct.NIIc_Actual__c : 0.00;
        NiidActForPie =  (tmpAcct.NIId_Actual__c != null) ? tmpAcct.NIId_Actual__c : 0.00;
        FeeActForPie =  (tmpAcct.Fee_Actual__c != null) ? tmpAcct.Fee_Actual__c : 0.00;  

        totalRevenue = (tmpAcct.Total_Revenue_Baht__c != null) ? tmpAcct.Total_Revenue_Baht__c : 0.00;
        grossProfit = (tmpAcct.Gross_Profit__c != null) ? tmpAcct.Gross_Profit__c : 0.00;
        netProfit = (tmpAcct.Net_Profit_Baht__c != null) ? tmpAcct.Net_Profit_Baht__c : 0.00;
        
        niPlan = (tmpAcct.NI_Plan__c!= null) ? tmpAcct.NI_Plan__c: 0.00;
        niicPlan = (tmpAcct.NIIc_Plan__c!= null) ? tmpAcct.NIIc_Plan__c: 0.00;
        niidPlan = (tmpAcct.NIId_Plan__c!= null) ? tmpAcct.NIId_Plan__c: 0.00;
        feePlan = (tmpAcct.Fee_Plan__c!= null) ? tmpAcct.Fee_Plan__c: 0.00;
        
        niWallet = (tmpAcct.NI_Wallet__c != null) ? tmpAcct.NI_Wallet__c : 0.00;
        niicWallet = (tmpAcct.NIIc_Wallet__c != null) ? tmpAcct.NIIc_Wallet__c : 0.00;
        niidWallet = (tmpAcct.NIId_Wallet__c != null) ? tmpAcct.NIId_Wallet__c : 0.00;
        feeWallet = (tmpAcct.Fee_Wallet__c != null) ? tmpAcct.Fee_Wallet__c : 0.00;
 
        niAct = (tmpAcct.NI_Actual__c != null) ? tmpAcct.NI_Actual__c : 0.00;
        niicAct = (tmpAcct.NIIc_Actual__c != null) ? tmpAcct.NIIc_Actual__c : 0.00;
        niidAct = (tmpAcct.NIId_Actual__c != null) ? tmpAcct.NIId_Actual__c : 0.00;
        feeAct = (tmpAcct.Fee_Actual__c != null) ? tmpAcct.Fee_Actual__c : 0.00;
        
        niSow= (tmpAcct.NI_SoW__c != null) ? tmpAcct.NI_SoW__c : 0.00;
        niicSow = (tmpAcct.NIIc_SoW__c != null) ? tmpAcct.NIIc_SoW__c : 0.00;
        niidSow = (tmpAcct.NIId_SoW__c != null) ? tmpAcct.NIId_SoW__c : 0.00;
        feeSow = (tmpAcct.Fee_SoW__c != null) ? tmpAcct.Fee_SoW__c : 0.00;          
        supplyActual = (tmpAcct.Supply_Chain_Actual__c != null) ? tmpAcct.Supply_Chain_Actual__c : 0.00;   
        AsOfDate = tmpAcct.Income_as_of_Wallet__c ;  // Change from As_of_date_Wallet__c
             
        //Edit by Danudath  20-04-2017
        //CR Wallet from Account plan
        TotalExpNi =(tmpAcct.NI_Account_Plan__c != null) ? tmpAcct.NI_Account_Plan__c : 0.00;       
        TotalExpNIIc = (tmpAcct.NIIc_Account_Plan__c != null) ? tmpAcct.NIIc_Account_Plan__c : 0.00;
        TotalExpNIId = (tmpAcct.NIId_Account_Plan__c != null) ? tmpAcct.NIId_Account_Plan__c : 0.00;
        TotalExpFee = (tmpAcct.Fee_Account_Plan__c != null) ? tmpAcct.Fee_Account_Plan__c : 0.00;
            
        NiSoWAccPlan = (tmpAcct.NI_SoW_Account_Plan__c  != null)? tmpAcct.NI_SoW_Account_Plan__c : 0.00;
        NiicSoWAccPlan = (tmpAcct.NIIc_SoW_Account_Plan__c  != null)? tmpAcct.NIIc_SoW_Account_Plan__c : 0.00;
        NiidSoWAccPlan = (tmpAcct.NIId_SoW_Account_Plan__c  != null)? tmpAcct.NIId_SoW_Account_Plan__c : 0.00;
        FeeSoWAccPlan = (tmpAcct.Fee_Sow_Account_Plan__c  != null)? tmpAcct.Fee_Sow_Account_Plan__c : 0.00;         
        AsOfDatefromAccPlan = tmpAcct.As_of_Date_Account_Plan__c; 
        
        NiicWalletAccPlanPie = TotalExpNIIc;
        NiidWalletAccPlanPie = TotalExpNIId;
        FeeWalletAccPlanPie = TotalExpFee;
        NiicExpAccPlanPie = niicPlan;
        NiidExpAccPlanPie = niidPlan;
        FeeExpAccPlanPie =  feePlan; 
            

       /* }catch(Exception Ex){
                system.debug('::::::Exception getWallet::::::');
        } */
        
    }
  
    
    public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        
        if (NiicForPie != null) data.add(new PieWedgeData('NIIc', NiicForPie,NiicActForPie));
        if (NiidForPie != null) data.add(new PieWedgeData('NIId', NiidForPie, NiidActForPie));
        if (FeeForPie != null) data.add(new PieWedgeData('Fee', FeeForPie, FeeActForPie));
        system.debug('NiicForPie '+NiicForPie);
        system.debug('NiidForPie '+NiidForPie);
        system.debug('FeeForPie '+FeeForPie);
    
        
        return data;
    }

    public class PieWedgeData {

        public String name { get; set; }
        public double Wallet { get; set; }
        public double Actual_NI { get; set; }

        public PieWedgeData(String name, double Wallet,double Actual) {
            this.name = name;
            this.Wallet = Wallet;
            this.Actual_NI = Actual;
        }
    }
    
    
    //Edit by Danudath
    //CR Wallet from Account plan
    //Date: 9-05-2017
    public List<PieWedgeDataAccPlan> getPieDataAccPlan() {
        List<PieWedgeDataAccPlan> data = new List<PieWedgeDataAccPlan>();        
        if (NiicWalletAccPlanPie != null) data.add(new PieWedgeDataAccPlan('NIIc', NiicWalletAccPlanPie,NiicExpAccPlanPie));
        if (NiidWalletAccPlanPie != null) data.add(new PieWedgeDataAccPlan('NIId', NiidWalletAccPlanPie, NiidExpAccPlanPie));
        if (FeeWalletAccPlanPie != null) data.add(new PieWedgeDataAccPlan('Fee', FeeWalletAccPlanPie, FeeExpAccPlanPie));
        return data;
    }    
    public class PieWedgeDataAccPlan {

        public String name { get; set; }
        public double Wallet { get; set; }
        public double Expected_NI { get; set; }

        public PieWedgeDataAccPlan(String name, double Wallet,double ExpectedNI) {
            this.name = name;
            this.Wallet = Wallet;
            this.Expected_NI  = ExpectedNI;
        }
    }
    // End -----Danudath---
    
    public void ActivitySummary()
    {    
         if(SumOpenTask==null)SumOpenTask=0;
         if(SumOpenVisit==null)SumOpenVisit=0;
         //if(SumOpenOpt==null)SumOpenOpt=0;
        
        try{
        //Status picklist have 5 values (Not Started,In Progress,Completed,Waiting on someone else,Deferred)
        SumOpenTask = [select COUNT() from Task where AccountId = :acct.id  AND IsClosed =: false AND IsRecurrence =: false ]; 
        
        //SumOpenTask = [select COUNT() from Task where AccountId = :acct.id  AND Status != 'Completed' AND IsRecurrence =: false ];
        //acct.Open_Tasks_tmp__c = SumOpenTask;  
        //system.debug('SumOpenTask '+SumOpenTask);

        //Status picklist have 3 values (1 - Open,2 - Completed,3 - Cancel) 
        SumOpenVisit = [select COUNT() from Call_Report__c where Customer_name__c = :acct.id  AND Status__c = '1 - Open'];
        //acct.Open_Visit_Plan_tmp__c = SumOpenVisit;
        //system.debug('SumOpenVisit '+SumOpenVisit);
        List<Call_Report__c> ActualVisitDate = [select Actual_Visit_Date__c from Call_Report__c where Customer_name__c = :acct.id  AND Status__c = '2 - Completed'];
            for (Call_Report__c v1 : ActualVisitDate){

            if (LastVisitDate==null){
            LastVisitDate = Date.valueOf(v1.Actual_Visit_Date__c);
            }
            if(LastVisitDate<Date.valueOf(v1.Actual_Visit_Date__c)){
                LastVisitDate = Date.valueOf(v1.Actual_Visit_Date__c);
            }
           
        }
            
            
            activityDate = tmpAcct.Last_Activity_Date__c;
            SumOpenOpt = Integer.valueOf(tmpAcct.No_of_Open_Opportunities__c) ;
                //acct.Last_Visit_Date__c = LastVisitDate;
            //system.debug('LastVisitDate '+LastVisitDate); 
/*     
        List<Task> ActivityDate =  [select ActivityDate from Task where AccountId = :acct.id  AND Status != 'Completed'];
        for (Task t1 : ActivityDate){

            if (LastActivityDate==null){
            LastActivityDate = Date.valueOf(t1.ActivityDate);
            }
            if(LastActivityDate<Date.valueOf(t1.ActivityDate)){
                LastActivityDate = Date.valueOf(t1.ActivityDate);
            }
           
        }
            acct.LastActivityDate = LastActivityDate;
     */
            //update  acct ;
        }catch(Exception Ex){ system.debug('::::::Exception ActivitySummary::::::');}
    }
    
    public void getReportId()
    {
        system.debug('getReportId ');
        
  /*      try{
        CustSingleView__c CustSingleView1 = CustSingleView__c.GetValues('CreditPipeline');
        String CreditPipeline = CustSingleView1.ReportName__c;
        CreditPipeReportId = [SELECT id FROM report where name = : CreditPipeline ].Id;
        //system.debug('CreditPipeline '+CreditPipeline);
        }catch(Exception Ex){
            system.debug('::::::Exception GetCreditPipelineId::::::');
        }
        
        try{
        CustSingleView__c CustSingleView2 = CustSingleView__c.GetValues('NonCreditPipeline');
        String NonCreditPipeline = CustSingleView2.ReportName__c;
        NonCreditPipeReportId = [SELECT id FROM report where name = : NonCreditPipeline ].Id;
        //system.debug('NonCreditPipeline '+NonCreditPipeline);
        }catch(Exception Ex){
            system.debug('::::::Exception GetNonCreditPipelineId::::::');
        }  */
        try{
        CustSingleView__c CustSingleView3 = CustSingleView__c.GetValues('TransactionBank');
        String TransactionBank = CustSingleView3.ReportName__c;
            system.debug('TransBankReportId '+TransactionBank);
        TransBankReportId = [SELECT id FROM report where name = : TransactionBank ].Id;
            
            
        CustSingleView__c CustSingleView3_2 = CustSingleView__c.GetValues('TransactionBank_DataPartition');
        String TransactionBank_DataPartition = CustSingleView3_2.ReportName__c;
        TransBankReportId_DataPartition = [SELECT id FROM report where name = : TransactionBank_DataPartition ].Id;
        system.debug('TransBankReportId_DataPartition '+TransactionBank_DataPartition);
          }catch(Exception Ex){
            system.debug('::::::Exception Domain1Id::::::'+Ex.getMessage());
        }
        
        try{
        CustSingleView__c CustSingleView4 = CustSingleView__c.GetValues('DepositInvest');
        String DepositInvest = CustSingleView4.ReportName__c;
            system.debug('DepositInvest '+DepositInvest);
        DepInvestReportId = [SELECT id FROM report where name = : DepositInvest ].Id;
            system.debug('DepInvestReportId '+DepInvestReportId);
            
        CustSingleView__c CustSingleView4_2 = CustSingleView__c.GetValues('DepositInvest_DataPartition');
        String DepositInvest_DataPartition = CustSingleView4_2.ReportName__c;
            system.debug('DepositInvest_DataPartition '+DepositInvest_DataPartition);
        DepInvestReportId_DataPartition = [SELECT id FROM report where name = : DepositInvest_DataPartition ].Id;
        //system.debug('DepositInvest '+DepositInvest);
          }catch(Exception Ex){
           system.debug('::::::Exception Domain2Id::::::');
        }
        
        try{
        CustSingleView__c CustSingleView5 = CustSingleView__c.GetValues('FundBorrow');
        String FundBorrow = CustSingleView5.ReportName__c;
        FundBorrowReportId = [SELECT id FROM report where name = : FundBorrow ].Id;
            
        CustSingleView__c CustSingleView5_2 = CustSingleView__c.GetValues('FundBorrow_DataPartition');
        String FundBorrow_DataPartition = CustSingleView5_2.ReportName__c;
        FundBorrowReportId_DataPartition = [SELECT id FROM report where name = : FundBorrow_DataPartition ].Id;
        //system.debug('FundBorrow '+FundBorrow);
        //system.debug('FundBorrowReportId '+FundBorrowReportId);
          }catch(Exception Ex){
            system.debug('::::::Exception Domain3Id::::::');
        }
        
        try{
        CustSingleView__c CustSingleView6 = CustSingleView__c.GetValues('RiskProtect');
        String RiskProtect = CustSingleView6.ReportName__c;
        RiskProtectReportId = [SELECT id FROM report where name = : RiskProtect ].Id;
            
        CustSingleView__c CustSingleView6_2 = CustSingleView__c.GetValues('RiskProtect_DataPartition');
        String RiskProtect_DataPartition = CustSingleView6_2.ReportName__c;
        RiskProtectReportId_DataPartition = [SELECT id FROM report where name = : RiskProtect_DataPartition ].Id;
        }catch(Exception Ex){
           system.debug('::::::Exception Domain4Id::::::');
        }
        
    }

    public void getPipelineReportId()
    {
        try{
        CustSingleView__c CustSingleView1 = CustSingleView__c.GetValues('CreditPipeline');
        String CreditPipeline = CustSingleView1.ReportName__c;
        CreditPipeReportId = [SELECT id FROM report where name = : CreditPipeline ].Id;
        //system.debug('CreditPipeline: '+CreditPipeline);
        //system.debug('CreditPipeReportId: '+CreditPipeReportId);
        }catch(Exception Ex){
             system.debug('::::::Exception GetCreditPipelineId2::::::');
           
        }
        
    }
 
    public void getNonPipelineReportId()
    {
        try{
        
        CustSingleView__c CustSingleView2 = CustSingleView__c.GetValues('NonCreditPipeline');
        String NonCreditPipeline = CustSingleView2.ReportName__c;
        NonCreditPipeReportId = [SELECT id FROM report where name = : NonCreditPipeline ].Id;       

        }catch(Exception Ex){
             system.debug('::::::Exception GetNonCreditPipelineId2::::::');
            
        }
        
    }
  
    
    public void getOnhand()
    {
        
            SumTransBank=0;
            SumDepInvest=0;
            SumFundBorrow=0;
            SumRiskProtect=0;
            TotalTransBank=0;
            TotalDepInvest=0;
            TotalFundBorrow=0;
            TotalRiskProtect=0;
            TotalLimitTransBank=0;
            TotalLimitRiskProtect=0;
            SumActTransBank=0;
            SumActDepInvest=0;
            SumActFundBorrow=0;
            SumActRiskProtect=0;
            System.debug('Product_Information_On_Hand');
            
            //1.Transactional Banking   
            //List<AggregateResult> TransBank = [select COUNT(Id), SUM(Ending_out_Ending_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Transactional%' group by Account__c];
            try{
            List<AggregateResult> TransBank = [select COUNT_DISTINCT(Product_Hierachy_Code__c ), SUM(Ending_out_Ending_Balance__c), SUM(Limit_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Transactional%' group by Account__c];
            for (AggregateResult ar1 : TransBank){
                SumTransBank = Integer.valueOf(ar1.get('expr0'));
                TotalTransBank = double.valueof(ar1.get('expr1'));  
                TotalLimitTransBank = double.valueof(ar1.get('expr2'));  
            }
                }catch(Exception ex){
             system.debug('::::::Exception Ar1::::::');
            }
            //[Fah comment according to CR036] SumActTransBank = [select COUNT() from Product_Information_Detail__c where Product_Information__r.Account__c = :acct.id  AND Product_Information__r.Product_Hierachy_Code__r.Product_Domain__c like '%Transactional%'];
            //TotalTransBank = 1234567890123456.12;  
            
            //2.Deposit investment
            //List<AggregateResult> DepInvest = [select COUNT(Id), SUM(Ending_out_Ending_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Deposit%' group by Account__c];
            try{
            List<AggregateResult> DepInvest = [select COUNT_DISTINCT(Product_Hierachy_Code__c ), SUM(Ending_out_Ending_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Deposit%' group by Account__c];
            for (AggregateResult ar2 : DepInvest){
                SumDepInvest = Integer.valueOf(ar2.get('expr0'));
                TotalDepInvest= double.valueof(ar2.get('expr1'));  
            }
            }catch(Exception ex){
             system.debug('::::::Exception Ar2::::::');
            }
            // TotalDepInvest= 1234567890123456.12;  
            // SumActDepInvest = [select COUNT() from Product_Information_Detail__c where Product_Information__r.Account__c = :acct.id  AND Product_Information__r.Product_Hierachy_Code__r.Product_Domain__c like '%Deposit%'];
            // [Fah comment according to CR036] & Add the new query to count TMB Account ID  
            try{
            List<AggregateResult> DepInvest2 = [select COUNT_DISTINCT(TMB_Account_ID__c) ACCT_NUM from Product_Information_Detail__c where Product_Information__r.Account__c = :acct.id AND Product_Information__r.Product_Hierachy_Code__r.Product_Domain__c like '%Deposit%' group by Customer__c];
            SumActDepInvest = Integer.valueOf(DepInvest2[0].get('ACCT_NUM'));
            }catch(Exception ex){
             system.debug('::::::Exception DepInvest2::::::'+ex);
            }
            //3.Funding and Borrowing
            //List<AggregateResult> FundBorrow = [select COUNT(Id), SUM(Limit_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Funding%' group by Account__c];
            try{
            List<AggregateResult> FundBorrow = [select COUNT_DISTINCT(Product_Hierachy_Code__c ), SUM(Limit_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Funding%' group by Account__c];
            for (AggregateResult ar3 : FundBorrow){
                SumFundBorrow = Integer.valueOf(ar3.get('expr0'));
                TotalFundBorrow = double.valueof(ar3.get('expr1'));  
            }
            }catch(Exception ex){
             system.debug('::::::Exception Ar3::::::');
            }    
            // [Fah comment according to CR036] SumActFundBorrow = [select COUNT() from Product_Information_Detail__c where Product_Information__r.Account__c = :acct.id  AND Product_Information__r.Product_Hierachy_Code__r.Product_Domain__c like '%Funding%'];

            //4.Risk Protection
            //List<AggregateResult> RiskProtect = [select COUNT(Id), SUM(Ending_out_Ending_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Risk%' group by Account__c];
            try{
                List<AggregateResult> RiskProtect = [select COUNT_DISTINCT(Product_Hierachy_Code__c ), SUM(Ending_out_Ending_Balance__c), SUM(Limit_Balance__c) from Product_Information_On_Hand__c where Account__c = :acct.id AND Product_Hierachy_Code__r.Product_Domain__c like '%Risk%' group by Account__c];
                for (AggregateResult ar4 : RiskProtect){
                    SumRiskProtect = Integer.valueOf(ar4.get('expr0'));
                    TotalRiskProtect = double.valueof(ar4.get('expr1'));  
                    TotalLimitRiskProtect = double.valueof(ar4.get('expr2'));  
                }
             }catch(Exception ex){
             system.debug('::::::Exception Ar4::::::');
            }   
            // [Fah comment according to CR036] SumActRiskProtect = [select COUNT() from Product_Information_Detail__c where Product_Information__r.Account__c = :acct.id  AND Product_Information__r.Product_Hierachy_Code__r.Product_Domain__c like '%Risk%'];

            getReportId();
  
       
    }
    
    //public PageReference TransBankReport()
    //{
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
    public void TransBankReport()
    {
        if(accessList.size() > 0)
        {
           // if(checkAuthorize() || isAccountTeam == true){
                string accid = acct.id;
                if(isVisible_total && isVisible_product){
                    system.debug('TransBankReport = 1');
                    pageTransBank = '/lightning/r/Report/'+TransBankReportId+'/view?fv1='+accid;
                    pageTransBankMobile = '../apex/ProductInfo_Domain1_Mobile?id='+accid;
                }else if(isVisible_total || isVisible_product){
                    system.debug('TransBankReport = 2');
                    // Datapartition 
                    if(isVisible_total){
                        pageTransBank = '/lightning/r/Report/'+TransBankReportId+'/view?fv1='+accid;
                        pageTransBankMobile = '../apex/ProductInfo_Domain1_Mobile?id='+accid;
                    }else{
                        pageTransBank = '/lightning/r/Report/'+TransBankReportId_DataPartition+'/view?fv1='+accid;
                        pageTransBankMobile = '../apex/ProductInfo_Domain1_Mobile_Patition?id='+accid;
                        //pageTransBankMobile = '/'+TransBankReportId_DataPartition+'?pv1='+accid.left(15);
                    }
                }else{
                    system.debug('TransBankReport = 3');
                    pageTransBank = '/apex/DataPartitionDetail?id='+accid+'&type=4';
                    pageTransBankMobile = '../apex/DataPartitionDetail?id='+accid+'&type=4';
                }
                //PageReference retURL = new PageReference('/'+TransBankReportId+'?pv1='+accid.left(15));
                //retURL.setRedirect(true);
                //return retURL;
          /*  }else{
                string accid = acct.id;
                pageTransBank = '/apex/DataPartitionDetail?id='+accid+'&type=4';
                //PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=4');
                //retURL2.setRedirect(true);
                //return retURL2;
            }*/
        }
        isClickTransBank = true;
        //system.debug(pageTransBank);
        //return null;
    }
    
    //public PageReference DepInvestReport()
    //{
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
    public void DepInvestReport()
    {
        if(accessList.size() > 0)
        {
            //if(checkAuthorize() || isAccountTeam == true){
                string accid = acct.id;
                if(isVisible_total && isVisible_product){   
                    pageDepInvest = '/lightning/r/Report/'+DepInvestReportId+'/view?fv1='+accid;
                    pageDepInvestMobile = '../apex/ProductInfo_Domain2_Mobile?id='+accid;
                }else if(isVisible_total || isVisible_product){
                    if(isVisible_total){
                        pageDepInvest = '/lightning/r/Report/'+DepInvestReportId+'/view?fv1='+accid;
                    pageDepInvestMobile = '../apex/ProductInfo_Domain2_Mobile?id='+accid;
                    }else{
                        pageDepInvest = '/lightning/r/Report/'+DepInvestReportId_DataPartition+'/view?fv1='+accid;
                        pageDepInvestMobile = '../apex/ProductInfo_Domain2_Mobile_Patition?id='+accid;
                    }
                }else{
                    pageDepInvest = '/apex/DataPartitionDetail?id='+accid+'&type=5';
                    pageDepInvestMobile = '../apex/DataPartitionDetail?id='+accid+'&type=5';
                }
                //PageReference retURL = new PageReference('/'+DepInvestReportId+'?pv1='+accid.left(15));
                //retURL.setRedirect(true);
                //return retURL;
            /*}else{
                string accid = acct.id;
                pageDepInvest = '/apex/DataPartitionDetail?id='+accid+'&type=5';
                //PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=5');
                //retURL2.setRedirect(true);
                //return retURL2;
            }*/
        }
        isClickDepInvest = true;
        //return null;
    }
    
    //public PageReference FundBorrowReport()
    //{
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
    public void FundBorrowReport()
    {
        if(accessList.size() > 0)
        {
           // if(checkAuthorize() || isAccountTeam == true){
                string accid = acct.id;
                if(isVisible_total && isVisible_product){   
                // pageFundBorrow = '/'+FundBorrowReportId+'?pv1='+accid.left(15);
                pageFundBorrow =  '/lightning/r/Report/'+FundBorrowReportId+'/view?fv1='+accid;
                
                    pageFundBorrowMobile = '../apex/ProductInfo_Domain3_Mobile?id='+accid;
                }else if(isVisible_total || isVisible_product){  
                    if(isVisible_total){
                        pageFundBorrow = '/lightning/r/Report/'+FundBorrowReportId+'/view?fv1='+accid;
                    pageFundBorrowMobile = '../apex/ProductInfo_Domain3_Mobile?id='+accid;
                    }else{
                        pageFundBorrow = '/lightning/r/Report/'+FundBorrowReportId_DataPartition+'/view?fv1='+accid;
                        pageFundBorrowMobile = '../apex/ProductInfo_Domain3_Mobile_Patition?id='+accid;
                    }
                }else{
                    pageFundBorrow = '/apex/DataPartitionDetail?id='+accid+'&type=6';
                    pageFundBorrowMobile = '../apex/DataPartitionDetail?id='+accid+'&type=6';
                }
                //PageReference retURL = new PageReference('/'+FundBorrowReportId+'?pv1='+accid.left(15));
                //retURL.setRedirect(true);
                //return retURL;
            /*} else{
                string accid = acct.id;
                pageFundBorrow = '/apex/DataPartitionDetail?id='+accid+'&type=6';
                //PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=6');
                //retURL2.setRedirect(true);
                //return retURL2;
            }*/
        }
        isClickFundBorrow = true;
        //return null;
    }
    
    
    //public PageReference RiskProtectReport()
    //{
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
    public void RiskProtectReport()
    {
        if(accessList.size() > 0)
        {
            //if(checkAuthorize() || isAccountTeam == true){
                string accid = acct.id;
                if(isVisible_total && isVisible_product){     
                // pageRiskProtect = '/'+RiskProtectReportId+'?pv1='+accid.left(15);
                pageRiskProtect = '/lightning/r/Report/'+RiskProtectReportId+'/view?fv1='+accid;
               
                    pageRiskProtectMobile = '../apex/ProductInfo_Domain4_Mobile?id='+accid;
                }else if(isVisible_total || isVisible_product){
                    if(isVisible_total){
                        pageRiskProtect = '/lightning/r/Report/'+RiskProtectReportId+'/view?fv1='+accid;
                    pageRiskProtectMobile = '../apex/ProductInfo_Domain4_Mobile?id='+accid;
                    }else{
                        
                        pageRiskProtect = '/lightning/r/Report/'+RiskProtectReportId_DataPartition+'/view?fv1='+accid;
                        pageRiskProtectMobile = '../apex/ProductInfo_Domain4_Mobile_Patition?id='+accid;
                    }
                }else{
                    pageRiskProtect = '/apex/DataPartitionDetail?id='+accid+'&type=7';
                    pageRiskProtectMobile = '../apex/DataPartitionDetail?id='+accid+'&type=7';
                }
                //PageReference retURL = new PageReference('/'+RiskProtectReportId+'?pv1='+accid.left(15));
                //retURL.setRedirect(true);
                //return retURL;
          /*  } else{
                string accid = acct.id;
                pageRiskProtect = '/apex/DataPartitionDetail?id='+accid+'&type=7';
                //PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=7');
                //retURL2.setRedirect(true);
                //return retURL2;
            }*/
        }
        isClickRiskProtect = true;
        //return null;
    }
    
    
    //Mobile
    public PageReference TransBankReportMobile()
    {               
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
        if(accessList.size() > 0)
        {
            if(checkAuthorize() || isAccountTeam == true){
            string accid = acct.id;
                string url = '';
                if(isVisible_total){   
                    url = '/apex/ProductInfo_Domain1_Mobile?id='+accid;            
                }else{
                    url = '/apex/ProductInfo_Domain1_Mobile?id='+accid;
                }
                PageReference retURL = new PageReference(url);
                
            retURL.setRedirect(true);
            return retURL;
            }
            else{
            string accid = acct.id;
            PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=4');
            retURL2.setRedirect(true);
            return retURL2;
            }
        }
        return null;
    }
    
    public PageReference DepInvestReportMobile()
    {
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
        if(accessList.size() > 0)
        {
            if(checkAuthorize() || isAccountTeam == true){
            string accid = acct.id;
                string url = '';
                if(isVisible_total){
                url = '/apex/ProductInfo_Domain2_Mobile?id='+accid;
                }else{
                    url = '/apex/ProductInfo_Domain2_Mobile?id='+accid;
                }
            PageReference retURL = new PageReference(url);
                
            retURL.setRedirect(true);
            return retURL;
            }
            else{
            string accid = acct.id;
            PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=5');
            retURL2.setRedirect(true);
            return retURL2;
            }
        }
        return null;
    }
    
    public PageReference FundBorrowReportMobile()
    {
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
        if(accessList.size() > 0)
        {
            if(checkAuthorize() || isAccountTeam == true){
            string accid = acct.id;
                string url = '';
                if(isVisible_total){
                url = '/apex/ProductInfo_Domain3_Mobile?id='+accid;
                }else{
                    url = '/apex/ProductInfo_Domain3_Mobile?id='+accid;
                }
            PageReference retURL = new PageReference(url);
            retURL.setRedirect(true);
            return retURL;
            }
            else{
            string accid = acct.id;
            PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=6');
            retURL2.setRedirect(true);
            return retURL2;
            }
        }
        return null;
    }
    
    public PageReference RiskProtectReportMobile()
    {
        /*
        List<UserRecordAccess> accessList = 
            [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
            ];
            */
        if(accessList.size() > 0)
        {
            if(checkAuthorize() || isAccountTeam == true){
            string accid = acct.id;
                string url = '';
                if(isVisible_total){
                url = '/apex/ProductInfo_Domain4_Mobile?id='+accid;
                }else{
                    url = '/apex/ProductInfo_Domain4_Mobile?id='+accid;
                }
            PageReference retURL = new PageReference(url);
            retURL.setRedirect(true);
            return retURL;
            }
            else{
            string accid = acct.id;
            PageReference retURL2 = new PageReference('/apex/DataPartitionDetail?id='+accid+'&type=7');
            retURL2.setRedirect(true);
            return retURL2;
            }
        }
        return null;
    }


    // CR Income Estimation
    public void loadIncomeEstimateData(){
        DateTime d = datetime.now();
        Integer Day = d.day();
        Integer cutoffday;

        List<Income_Estimation__c> tmpIncome1;
        List<Income_Estimation__c> tmpIncome2;

        AppConfig__c mc = AppConfig__c.getValues('Income estimation cut off date');
        
        if(mc != null){
            cutoffday = Integer.valueOf(mc.Value__c);
        }else{
            cutoffday = 11;
        }
        
        System.debug('Day : ' + Day);
        System.debug('cutoffday : ' + cutoffday);
        
        if(Day >= cutoffday){
            d = d.addMonths(-1);
            tmpIncome1 = [SELECT Id, as_of_date__c, BOT_ID__c, AVG_Income_amount__c, Account__c, Model_Type__c, Valida_date__c FROM Income_Estimation__c WHERE as_of_date__c = Last_month AND Account__c = :acct.id];
            tmpIncome2 = [SELECT Id, as_of_date__c, BOT_ID__c, AVG_Income_amount__c, Account__c, Model_Type__c, Valida_date__c FROM Income_Estimation__c WHERE as_of_date__c = Last_n_Months:2 AND as_of_date__c < Last_month AND Account__c = :acct.id];
        }else{
            d = d.addMonths(-2);
            tmpIncome1 = [SELECT Id, as_of_date__c, BOT_ID__c, AVG_Income_amount__c, Account__c, Model_Type__c, Valida_date__c FROM Income_Estimation__c WHERE as_of_date__c = Last_n_Months:2 AND as_of_date__c < Last_month AND Account__c = :acct.id];
            tmpIncome2 = [SELECT Id, as_of_date__c, BOT_ID__c, AVG_Income_amount__c, Account__c, Model_Type__c, Valida_date__c FROM Income_Estimation__c WHERE as_of_date__c = Last_n_Months:3 AND as_of_date__c < Last_n_Months:2 AND Account__c = :acct.id];
        }
        prev1MonthName = d.format('MMMMM');
        prev1year = d.year();

        d = d.addMonths(-1);
        
        prev2MonthName = d.format('MMMMM');
        prev2year = d.year();

        if(tmpIncome1.size() < 1){
            Income_Estimation__c tmpInc1 = new Income_Estimation__c();
            tmpInc1.AVG_Income_amount__c = 0;
            tmpInc1.BOT_ID__c = ' - ';
            tmpInc1.Model_Type__c = ' - ';
            tmpInc1.Valida_date__c = ' - ';

            tmpIncome1.add(tmpInc1);
        }

        if(tmpIncome2.size() < 1){
            Income_Estimation__c tmpInc1 = new Income_Estimation__c();
            tmpInc1.AVG_Income_amount__c = 0;
            tmpInc1.BOT_ID__c = ' - ';
            tmpInc1.Model_Type__c = ' - ';
            tmpInc1.Valida_date__c = ' - ';

            tmpIncome2.add(tmpInc1);
        }


        prev1Month = tmpIncome1;
        prev2Month = tmpIncome2;
    }


    public boolean checkAuthorize()
    {
        boolean validate = false;
        boolean continueVal = true;

        if (accessList.get(0).HasEditAccess) {
            validate = true;
        } else {
            user u = [select UserRoleId from user where id =: UserInfo.getUserId()];
            string accOwnerRole = tmpAcct.owner.UserRoleId;
            string currentUserRole = '';
            if (u != null) currentUserRole = u.UserRoleId;

            if (currentUserRole != '' && currentUserRole != null)
            {
                while (continueVal)
                {
                    string accOwnerParentRole = '';
                    if (accOwnerRole != '' && accOwnerRole != null) {
                        UserRole ur = [select ParentRoleId from UserRole where id =: accOwnerRole];
                        if (ur != null) accOwnerParentRole = ur.ParentRoleId;
                    }
                    
                    if (accOwnerParentRole != '' && accOwnerParentRole != null) {
                        if (accOwnerParentRole != currentUserRole) {
                            accOwnerRole = accOwnerParentRole;
                        } else {
                            validate = true;
                            continueVal = false;
                        }
                    } else {
                        continueVal = false;
                    }
                }
            }
        }

        return validate;
    }
    

    /*public AccountDataPartitionExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        //isLoading = true;
        //isLoadSuccess = false;
    }*/

    public void loadParameter(){
        // set parameter value
        notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));
    }
    
    public void loadData()
    {
        try{
            section = apexpages.currentPage().getParameters().get('sectionName');
            section2 = apexpages.currentPage().getParameters().get('sectionName2');
            // if not defind sectionName2 in VF will catch
        }catch(Exception e){
            section = apexpages.currentPage().getParameters().get('sectionName');
        }
        //system.debug('section = '+ section);
        if(section2 != null && section2 != ''){
            isVisible_product = RTL_AccountUtility.verifyFieldSecurity(section2,userProfile.name, acctDetail.id);
            isVisible_total = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
            system.debug('isVisible_product = '+isVisible_product);
            system.debug('isVisible_total = '+isVisible_total);
        }else{
            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);            
            system.debug('section= '+section+' isVisible = '+isVisible+' id= '+acctDetail.id);
        }

        if( isVisible != null && !isVisible ){
            notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));            
        }
        
        hiddenText = system.Label.Data_Condition_Hidden_Text;
        isLoading = false;
        isLoadSuccess = true;
        
        if(isVisible != null && isVisible){
            if(type == '10'){
               loadIncomeEstimateData();

            }
        }
    }

    public void logButtonEvent(){
        String buttonName = '';
        String sectionName = '';
        
        try{
            buttonName = Apexpages.currentPage().getParameters().get('buttonNameParam');
            sectionName = Apexpages.currentPage().getParameters().get('sectionNameParam');
        }catch(Exception e){
            System.debug('logButtonEvent error');
        }
        
        // System.debug( 'data: ' + buttonName + ' : ' + sectionName);
        
        Boolean isButtonVisible = RTL_AccountUtility.verifyFieldSecurity(sectionName,userProfile.name, acctDetail.id);
        
        //String accessLevel = RTL_AccountUtility.getAccountDataSecurity(sectionName,userProfile.name,acctDetail.recordType.name);
        //Boolean isButtonVisible = RTL_AccountUtility.getAccountAccessibility( acctDetail , accessLevel );
        
        //User u = [SELECT Id,FirstName,LastName,Employee_ID__c FROM User WHERE id =:UserInfo.getUserId() ];
        //String userName = u.FirstName + ' ' + u.LastName; 
        
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        String tmb_cust_id = '';

        try{
            tmb_cust_id = acctDetail.TMB_Customer_ID_PE__c;   
        }catch(Exception e) {
            tmb_cust_id = '';
        }

        String errorMessage = '';

        if( !isButtonVisible )
        {
            errorMessage = 'No Authorize on ' + buttonName;
        }

        RTL_CampaignUtil.saveToOnlineLogDataPartition(isButtonVisible ,'Account', errorMessage , '' , userName, tmb_cust_id , buttonName ,'','', acctDetail, true);
            
        system.debug('TMB_Customer_ID_PE__c: ' + tmb_cust_id);
        
        //return null;
    }

    public PageReference CancelAction(){
        PageReference pr = new PageReference('/'+acct.Id);
        pr.setRedirect(true);        
        return pr;
    }
}