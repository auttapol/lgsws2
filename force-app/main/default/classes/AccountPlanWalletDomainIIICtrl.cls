public without sharing class AccountPlanWalletDomainIIICtrl {
    public String WalletID {get;set;}
    public String CompanyID {get;set;}
    public String GroupID {get;set;}  
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isSystemAdMin {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public AcctPlanWallet__c acctplanwallet {get;set;}   
    public List<AcctPlanWorkingCapital__c> APWorkingCapital {get;set;} 
    public Double TotalWalletNIIcWorkingCapital {get;set;}
    public Double TotalCreditFeeWorkingCapital {get;set;}
    public Double MaxCreditFeeWorkingCapital {get;set;} 
    public List< AcctPlanWalletCreditFacility__c> APCreditFacility {get;set;} 
    public List<AcctPlanExistingLongTermLoan__c> APExisitngLongTermLoan {get;set;}    
    public Double SumofExistingLongTermLoanNIIC {get;set;}    
    public List<AcctPlanCapitalExpenditurePlan__c> APCapitalExpenditurePlan {get;set;} 
    public Double SumOfWalletNiicLongTermLoan {get;set;}
    public Double SumOfWalletNiicYearly {get;set;}
    public Double SumOfWalletCreditFeeYearly {get;set;}
    public Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireLists {get;set;}
    public String LGissuingSegment {get;set;}
    public String LGprojectSegment {get;set;}
    public String AVALAcceptanceSegment {get;set;}
    public String InternationalBank1Segment {get;set;}
    public String InternationalBank2Segment {get;set;}
    public String ShippingGuaranteeSegment {get;set;}
    public String RequestLGSegment {get;set;}    
    public List<AcctPlanLGProject__c> APLGProjectList {get;set;}  
    public AcctPlanLGProject__c APLGProject {get;set;}    
    public Double ShortTermWalletLGFee {get;set;}  
    public Double LongTermWalletLGFee {get;set;}   
    public String Seasonal {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public Boolean isMiniView {get;set;}
    public boolean isHasPermission {get;set;}
    public Boolean isHasSeasonal {get{
        if(Seasonal == 'Yes'){
            isHasSeasonal =  true;      
        }else{
            isHasSeasonal =  false;      
        }
        return isHasSeasonal;
    }set;}   
    public String selectedStartmonth {get;set;}
    public String selectedEndmonth {get;set;}
    public String covertMonth(String month){
        if(month == null){
            month = '0';
        }else if(month == 'January'){
            month = '1';
        }else if(month == 'February'){
            month = '2';
        }else if(month == 'March'){
            month = '3';
        }else if(month == 'April'){
            month = '4';
        }else if(month == 'May'){
            month = '5';
        }else if(month == 'June'){
            month = '6';
        }else if(month == 'July'){
            month = '7';
        }else if(month == 'August'){
            month = '8';
        }else if(month == 'September'){
            month = '9';
        }else if(month == 'October'){
            month = '10';
        }else if(month == 'November'){
            month = '11';
        }else if(month == 'December'){
            month = '12';
        }
        return month;
    }
    public String covertMonthSave(String month){
        if(month == '0'){
            month = null;
        }else if(month == '1'){
            month = 'January';
        }else if(month == '2'){
            month = 'February';
        }else if(month == '3'){
            month = 'March';
        }else if(month == '4'){
            month = 'April';
        }else if(month == '5'){
            month = 'May';
        }else if(month == '6'){
            month = 'June';
        }else if(month == '7'){
            month = 'July';
        }else if(month == '8'){
            month = 'August';
        }else if(month == '9'){
            month = 'September';
        }else if(month == '10'){
            month = 'October';
        }else if(month == '11'){
            month = 'November';
        }else if(month == '12'){
            month = 'December';
        }
        return month;
    }
    public Integer NormalPeriod {get{
        if(selectedStartmonth == null || selectedEndmonth == null){
            NormalPeriod = 12;
        }
        return NormalPeriod;
    } set;}  
    public Integer SeasonalPeriod {get{
        if(selectedStartmonth == null || selectedEndmonth == null){
            SeasonalPeriod = 0;
        }
        return SeasonalPeriod;
    }set;}    
    public void SelectSeasonalMonth(){ 
        if(Seasonal=='Yes'){
            Integer Startmonth = Integer.valueOf(selectedStartmonth);  
            Integer Endmonth = Integer.valueOf(selectedEndmonth);
            if(Endmonth-Startmonth >=0){
                NormalPeriod = (12 -(Endmonth-Startmonth))-1;
                SeasonalPeriod = 12-NormalPeriod;
            }else if(Endmonth-Startmonth <0){
                SeasonalPeriod = (12 -((Endmonth-Startmonth)*(-1)))+1;
                NormalPeriod = 12-SeasonalPeriod;    
            }else{
                NormalPeriod = 0;
                SeasonalPeriod = 0;
            }           
        }else{           
            NormalPeriod = 12;
            SeasonalPeriod =0;
        }
    }
    public List<SelectOption> Months {get{
        if(Months ==null || Months.size()==0){
            Months = new List<SelectOption>();
            Months.add(new SelectOption('0','--None--'));
            Months.add(new SelectOption('1','January'));
            Months.add(new SelectOption('2','February'));
            Months.add(new SelectOption('3','March'));
            Months.add(new SelectOption('4','April'));
            Months.add(new SelectOption('5','May'));
            Months.add(new SelectOption('6','June'));
            Months.add(new SelectOption('7','July'));
            Months.add(new SelectOption('8','August'));
            Months.add(new SelectOption('9','September'));
            Months.add(new SelectOption('10','October'));
            Months.add(new SelectOption('11','November'));
            Months.add(new SelectOption('12','December'));
        }
        return Months;
    }set;}   
    public String selectedDomesticyear {get;set;}
    public String selectedInternationalyear {get;set;}
    public List<SelectOption> Year {get{
        if(Year ==null || Year.size()==0){
            Year = new List<SelectOption>();
            Integer currentYear = System.Today().year(); 
            Year.add(new SelectOption('','--None--'));
            for(integer y=currentYear;y > (currentYear-543) && y > 1970;y--){
                Year.add(new SelectOption(String.valueOf(y-543),String.valueOf(y-543)));
            }
        }
        return Year;
    }set;} 
    public List<SelectOption> getFiscalYear(){
        List<SelectOption> fiscalyearoption = new List<SelectOption>();
        List<Account_Plan_Fiscal_Year__c> yearlistitem = [SELECT ID,Name,AD_Year__c,BE_Year__c
                                                FROM Account_Plan_Fiscal_Year__c 
                                                WHERE ID!=null
                                                ORDER BY Name];
        fiscalyearoption.add(new SelectOption('','--None--'));
        for(Account_Plan_Fiscal_Year__c year : yearlistitem){
            fiscalyearoption.add(new SelectOption(year.AD_Year__c,year.AD_Year__c));
        }         
        return fiscalyearoption;
    }
    public Boolean isHasLGProject {get{
        if(selectedLGProject =='Yes'){
            isHasLGProject =true;
        }else{
            isHasLGProject = false;
        }
        return isHasLGProject;
    }set;}    
    public Boolean isHasLGpurchase {get{
        if(selectedLGPurchase =='Yes'){
            isHasLGpurchase =true;
        }else{
            isHasLGpurchase = false;
        }
        return isHasLGpurchase;
    }set;}    
    public Boolean isHasLGUtilities {get{
        if(selectedLGUtilities =='Yes'){
            isHasLGUtilities =true;
        }else{
            isHasLGUtilities = false;
        }
        return isHasLGUtilities;
    }set;}
    
    public Boolean isHasLGTax {get{
        if(selectedLGTax =='Yes'){
            isHasLGTax =true;
        }else{
            isHasLGTax = false;
        }
        return isHasLGTax;
    }set;}    
    public Boolean isHasInternationalBank {get{
        isHasInternationalBank = true;
        return isHasInternationalBank;
    }set;}
    public String selectedLGProject {get;set;}
    public String selectedLGPurchase {get;set;}
    public String selectedLGUtilities {get;set;}
    public String selectedLGTax {get;set;}
    public String selectedInternationalBankQ1 {get;set;}
    public String selectedInternationalBankQ2 {get;set;}    
    public List<SelectOption> YesorNo{
        get{
            if(YesOrNo==null || YesOrNo.size() ==0){
                Yesorno = new List<SelectOption>();
                Yesorno.add(new SelectOption('','--None--'));
                Yesorno.add(new SelectOption('Yes','Yes'));
                Yesorno.add(new SelectOption('No','No'));
                
            }
            return YesorNo;
        }set;
    }    
    public void checklgsection(){
        System.debug(selectedLGProject);
        System.debug(isHasLGproject);       
    }
    
    //Percent
    public Integer TotalDomesticPercentage {get;set;}
    public Integer TotalExportPercentage {get;set;}
    public Integer EstimatedAmount {get;set;}
    public Integer TotalDomesticAmount {get;set;}
    public Integer TotalExportAmount {get;set;}

    //R5.2 FI : Jantanee Saetung
    public Double WorkingCapitalNeedsFI {get;set;}
    public String msgTableMandatory {get;set;}
    
    public AccountPlanWalletDomainIIICtrl(ApexPages.StandardController controller){     
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }    
        String strurl = ApexPages.currentPage().getUrl();           
        strurl = strurl.split('apex/')[1];
        
        if(CompanyID !=null && CompanyID != ''){
            companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
             ishasProdStrategy = companyprofile.isHasProdStrategy__c;
             isHasActionPlan = companyprofile.isHasActionPlan__c;
            isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
            isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
            isSystemAdMin = AccountPlanUtilities.isSystemAdmin;
            if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
            List<AcctPlanWallet__c> acctplanwalletLists = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
      
            if(acctplanwalletLists.size() > 0){
                acctplanwallet = acctplanwalletLists.get(0);
                workingCapital();
                CreditFacility(); 
                ExisitngLongTermLoan();
                CapitalExpenditurePlan();
                ContingentLiabilities();
                
                Seasonal = acctplanwallet.BusinessHasSeasonal__c;
                
                selectedStartmonth = acctplanwallet.HighSeasonStartMonth__c;
                selectedEndmonth = acctplanwallet.HighSeasonEndMonth__c;
                selectedDomesticyear = acctplanWallet.DataAsOfYearFacilityDomestic__c ;
                selectedInternationalyear = acctplanWallet.DataAsOfYearFacilityInternational__c;
            }else{
                Seasonal = 'No';
                selectedStartmonth = '0';
                selectedEndmonth = '0';
                
            }
            selectedStartmonth = covertMonth(selectedStartmonth);
            selectedEndmonth = covertMonth(selectedEndmonth); 
            SelectSeasonalMonth();           
        }
        
        if(strurl.containsIgnoreCase('view')){
            selectedStartmonth = covertMonthSave(selectedStartmonth);
            selectedEndmonth = covertMonthSave(selectedEndmonth);
            
            List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_3_Percentage__c,
                      Account_Plan_Completion_Percentage__c , 
                      Step_3_1_Entered_Fields__c  ,                                          
                      Step_3_1_Percentage__c ,
                      Step_3_1_Required_Fields__c                                               
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                     if(CompleteList.size()>0){
                         Acctplancompletion = CompleteList.get(0);
                     }
            
        }else{
            
        }
        msgTableMandatory = Account_Plan_Status_Code__c.GetValues('9005').Status_Message__c;
         
    }

    public void workingCapital(){
        TotalWalletNIIcWorkingCapital = 0;
        TotalCreditFeeWorkingCapital = 0;
        Boolean isHasWorkingCapital = true;
        
        APWorkingCapital = [SELECT Id,AvgAPDays__c ,AvgARDays__c , AvgInvDays__c, CreditFee__c, FrontEndFee__c, NimcPercent__c, 
                    NoOfMonth__c, RecordType__c, TotalCreditFee__c, TotalWalletNiic__c, TradeCycleDays__c,
                    WalletNIIC__c, WorkingCapitalNeeds__c , WorkingCapitalNeedsFI__c 
                    FROM AcctPlanWorkingCapital__c
                    WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        if(APWorkingCapital.size() > 0){      
            if(APWorkingCapital.get(0).CreditFee__c != null){
                MaxCreditFeeWorkingCapital = APWorkingCapital.get(0).CreditFee__c;
            }else{
                MaxCreditFeeWorkingCapital = 0;
            }

            for(AcctPlanWorkingCapital__c item : APWorkingCapital){
                if(item.WalletNIIC__c!=null){
                    //item.WalletNIIC__c=0;
                    TotalWalletNIIcWorkingCapital += item.WalletNIIC__c;
                }
                if(item.CreditFee__c!=null){
                    //item.CreditFee__c=0;
                    TotalCreditFeeWorkingCapital += item.CreditFee__c; 
                }
                //TotalWalletNIIcWorkingCapital += item.WalletNIIC__c;
                //TotalCreditFeeWorkingCapital += item.CreditFee__c; 
                if(item.CreditFee__c > MaxCreditFeeWorkingCapital){
                    MaxCreditFeeWorkingCapital = item.CreditFee__c;
                }
            }           
        }else{
            isHasWorkingCapital = false;
        }
        
        if(!isHasWorkingCapital){
            APWorkingCapital = new List<AcctPlanWorkingCapital__c>();     
            AcctPlanWorkingCapital__c item1 = new AcctPlanWorkingCapital__c();
            item1.AcctPlanWallet__c = acctplanwallet.Id;
            item1.RecordType__c = 'Normal Period';
            APWorkingCapital.add(item1);
            
            AcctPlanWorkingCapital__c item2 = new AcctPlanWorkingCapital__c();
            item2.AcctPlanWallet__c = acctplanwallet.Id;
            item2.RecordType__c = 'High Season Period';
            APWorkingCapital.add(item2);   
        }
        acctplanwallet.TotalWalletNiic__c = TotalWalletNIIcWorkingCapital;
        acctplanwallet.TotalCreditFee__c = TotalCreditFeeWorkingCapital;
    }
    
    public void CreditFacility(){
        Double SumOfCreditFacilityLimit = 0;
        Double SumOfCreditFacilityOutstanding = 0;
        Double SumOfCreditFacilityLimitInter = 0;
        Double SumOfCreditFacilityOutstandingInter = 0;
        Double SumOfExportTransactionLimit = 0;
        Double SumOfExportTransactionOutStanding = 0;           
        Boolean isHasCreditFacility = true;
        
        APCreditFacility = [SELECT Id,Bank__c, Bank__r.Name, Collateral__c , CreditType__c, LimitAmount__c, LTV__c, 
                            OtherCreditType__c, Outstanding__c, Segment__c, CollateralDetail__c
                            FROM AcctPlanWalletCreditFacility__c 
                            WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        if(APCreditFacility.size() > 0){
            for(AcctPlanWalletCreditFacility__c item : APCreditFacility){
                if(item.LimitAmount__c == null){
                    item.LimitAmount__c = 0;
                }
                if(item.Outstanding__c == null){
                    item.Outstanding__c = 0;
                }
                
                if(item.Segment__c == 'Domestic'){
                    SumOfCreditFacilityLimit += item.LimitAmount__c;
                    SumOfCreditFacilityOutstanding += item.Outstanding__c;
                }else if(item.Segment__c == 'ImportTransaction'){
                    SumOfCreditFacilityLimitInter += item.LimitAmount__c;
                    SumOfCreditFacilityOutstandingInter += item.Outstanding__c;
                }else if(item.Segment__c == 'ExportTransaction'){
                    SumOfExportTransactionLimit += item.LimitAmount__c;
                    SumOfExportTransactionOutStanding += item.Outstanding__c;
                }  
                if(item.LimitAmount__c <= 0){
                    item.LimitAmount__c = null;
                }
                if(item.Outstanding__c <= 0){
                    item.Outstanding__c = null;
                }
            }
        }else{
            isHasCreditFacility = false;
        }
        
        if(!isHasCreditFacility){
            APCreditFacility = new List<AcctPlanWalletCreditFacility__c>();  
        }
        acctplanwallet.SumOfCreditFacilityLimit__c = SumOfCreditFacilityLimit;
        acctplanwallet.SumOfCreditFacilityOutstanding__c = SumOfCreditFacilityOutstanding;
        acctplanwallet.SumOfCreditFacilityLimitInter__c = SumOfCreditFacilityLimitInter;
        acctplanwallet.SumOfCreditFacilityOutstandingInter__c = SumOfCreditFacilityOutstandingInter;
        acctplanwallet.SumOfExportTransactionLimit__c = SumOfExportTransactionLimit;
        acctplanwallet.SumOfExportTransactionOutStanding__c = SumOfExportTransactionOutStanding;
    }
    
    public void ExisitngLongTermLoan(){
        Double SumOfExistingLongTermLoan = 0;
        SumofExistingLongTermLoanNIIC =0;       
        Boolean isHasExisitngLongTermLoan = true;
        
        APExisitngLongTermLoan = [SELECT Id,Bank__c,Bank__r.Name, CCY__c,CCY__r.Name, Collateral__c, EquivalentAmount__c, 
                                  InterestFixedRate__c,InterestFloatingRate__c , InterestType__c, LTVPercent__c, NimcPercent__c, RemainingTenorsYear__c,
                                  Remark__c, TypeOfLoan__c,WalletNiicYearly__c  , CollateralDetail__c
                                  FROM AcctPlanExistingLongTermLoan__c 
                                  WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        if(APExisitngLongTermLoan.size() > 0){
            for(AcctPlanExistingLongTermLoan__c item : APExisitngLongTermLoan){
                if(item.EquivalentAmount__c == null){
                    item.EquivalentAmount__c = 0;
                } 
                if(item.WalletNiicYearly__c == null){
                    item.WalletNiicYearly__c =0;
                }
                SumOfExistingLongTermLoan += item.EquivalentAmount__c;
                SumofExistingLongTermLoanNIIC += item.WalletNiicYearly__c;
                
                if(item.EquivalentAmount__c <= 0){
                    item.EquivalentAmount__c = null;
                } 
                if(item.WalletNiicYearly__c <= 0){
                    item.WalletNiicYearly__c = null;
                }
            }            
        }else{
            isHasExisitngLongTermLoan = false;
        }
        
        if(!isHasExisitngLongTermLoan){
            APExisitngLongTermLoan = new List<AcctPlanExistingLongTermLoan__c>();
        }
        acctplanwallet.SumOfExistingLongTermLoan__c = SumOfExistingLongTermLoan;
        acctplanwallet.SumofExistingLongTermLoanNIIC__c = SumofExistingLongTermLoanNIIC;
    }

    public void CapitalExpenditurePlan(){
        Double SumOfCapitalExpenditurePlanProjectAmt = 0;
        Double SumOfCapitalExpenditurePlanCreditFee = 0;      
        Double SumOfCapitalExpenditurePlanNIIC = 0;
        SumOfWalletNiicLongTermLoan = 0;
        SumOfWalletNiicYearly = 0;
        SumOfWalletCreditFeeYearly = 0;
        
        Boolean isHasCapitalExpenditurePlan = true;
        
        APCapitalExpenditurePlan = [SELECT Id,Purpose__c,ProjectAmount__c,InvestmentLocation__c,FinancingRation__c,
                                    TenorYearly__c,NimcPercent__c,WalletNiicYearly__c,FrontEndFee__c,CreditFee__c
                                    FROM AcctPlanCapitalExpenditurePlan__c  
                                    WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        if(APCapitalExpenditurePlan.size() > 0){
            for(AcctPlanCapitalExpenditurePlan__c item : APCapitalExpenditurePlan){
                if(item.ProjectAmount__c == null){
                    item.ProjectAmount__c = 0;
                }
                if(item.WalletNiicYearly__c == null){
                    item.WalletNiicYearly__c =0;
                }
                if(item.CreditFee__c ==null){
                    item.CreditFee__c =0;
                }
                SumOfCapitalExpenditurePlanProjectAmt += item.ProjectAmount__c;
                SumOfCapitalExpenditurePlanCreditFee += item.CreditFee__c;      
                SumOfCapitalExpenditurePlanNIIC += item.WalletNiicYearly__c.setScale(0);
                
                if(item.ProjectAmount__c <= 0){
                    item.ProjectAmount__c = null;
                }
                if(item.WalletNiicYearly__c <= 0){
                    item.WalletNiicYearly__c = null;
                }
                if(item.CreditFee__c <= 0){
                    item.CreditFee__c = null;
                }
            }          
        }else{
            isHasCapitalExpenditurePlan = false;
        }
        
        if(!isHasCapitalExpenditurePlan){
            APCapitalExpenditurePlan = new List<AcctPlanCapitalExpenditurePlan__c>();
        }
        
        if(MaxCreditFeeWorkingCapital == null){
            MaxCreditFeeWorkingCapital = 0;
        }
        SumOfWalletNiicLongTermLoan =  SumofExistingLongTermLoanNIIC + SumOfCapitalExpenditurePlanNIIC;
        SumOfWalletNiicYearly = TotalWalletNIIcWorkingCapital + SumOfWalletNiicLongTermLoan;
        SumOfWalletCreditFeeYearly = MaxCreditFeeWorkingCapital + SumOfCapitalExpenditurePlanCreditFee; 
        
        acctplanwallet.SumOfCapitalExpenditurePlanProjectAmt__c = SumOfCapitalExpenditurePlanProjectAmt;
        acctplanwallet.SumOfCapitalExpenditurePlanCreditFee__c = SumOfCapitalExpenditurePlanCreditFee;      
        acctplanwallet.SumOfCapitalExpenditurePlanNIIC__c = SumOfCapitalExpenditurePlanNIIC;
        acctplanwallet.SumOfWalletNiicLongTermLoan__c = SumOfWalletNiicLongTermLoan;
        
        acctplanwallet.SumOfWalletNiicYearly__c = SumOfWalletNiicYearly;
        acctplanwallet.SumOfWalletCreditFeeYearly__c = SumOfWalletCreditFeeYearly;
        acctplanwallet.MaxCreditFeeWorkingCapital__c = MaxCreditFeeWorkingCapital;
    }

    public void ContingentLiabilities(){
        Boolean isHasQuestionnaire = true;
        List<AcctPlan_Questionnaire_Template__c> QuestionnaireTemplateList = new List<AcctPlan_Questionnaire_Template__c>();
        Map<String,List< AcctPlan_Questionnaire_Template__c>> QuestionnaireTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c>>();
        Set<String> SegmentSet = new Set<String>();
        
        List<AcctPlanQuestionnaire__c> APQuestionnaire = AccountPlanUtilities.QueryQuestionnaireByWalletID(WalletID);
        
        QuestionnaireLists = new Map<String,List<AcctPlanQuestionnaire__c>>();
        
        LGissuingSegment = 'L/G issuing';
        LGprojectSegment = 'L/G Project';
        AVALAcceptanceSegment = 'AVAL & Acceptance';
        InternationalBank1Segment = 'International bank section1';
        InternationalBank2Segment = 'International bank section2';
        ShippingGuaranteeSegment = 'Shipping guarantee';
        RequestLGSegment = 'Request L/G';
        
        isHasLGproject = false;
        isHasLGpurchase = false;        
        isHasLGUtilities = false;      
        isHasLGTax = false;
        isHasQuestionnaire = false;
        if(APQuestionnaire.size()>0){
            //LG issuing Segment            
            for(AcctPlanQuestionnaire__c item : APQuestionnaire){
                Boolean status = false;
                if(item.Segment__c == LGissuingSegment){
                    item.AcctPlanWallet__c = acctplanwallet.id;
                }                
                if(item.Answer__c == 'Yes'){
                    status = true;
                }
                if(item.Question__c == '1.1 L/G project'){
                    isHasLGProject = status;
                    selectedLGProject = item.Answer__c;
                }else if(item.Question__c == '1.2 L/G purchase'){
                    isHasLGpurchase = status; 
                    selectedLGPurchase = item.Answer__c;
                }else if(item.Question__c == '1.3 L/G Utilities'){
                    isHasLGUtilities = status;  
                    selectedLGUtilities = item.Answer__c;
                }else if(item.Question__c == '1.4 L/G Tax'){
                    isHasLGTax = status;  
                    selectedLGTax = item.Answer__c;
                }             
            }
            
        }else{
            /*isHasLGproject = false;
            isHasLGpurchase = false;        
            isHasLGUtilities = false;      
            isHasLGTax = false;*/
        }
        
        //Set Questionnaire
        QuestionnaireTemplateList = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain III');
        QuestionnaireTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
        if(QuestionnaireTemplateList.size() > 0){
            for(AcctPlan_Questionnaire_Template__c QT : QuestionnaireTemplateList){
                String Segment;
                if(qt.Sub_Segment__c != null){
                    Segment = qt.Sub_Segment__c;
                    SegmentSet.add(qt.Sub_Segment__c);
                }else{
                    Segment = qt.Segment__c;
                }
                if(QuestionnaireTemplateMap.containsKey(Segment)){
                    QuestionnaireTemplateMap.get(Segment).add(qt);
                }else{
                    SegmentSet.add(Segment); 
                    List<AcctPlan_Questionnaire_Template__c>  QTList = new List< AcctPlan_Questionnaire_Template__c>();
                    QTList.add(qt);
                    QuestionnaireTemplateMap.put(Segment,QTList);   
                }
                
            }
            
            for(AcctPlanQuestionnaire__c question : APQuestionnaire){
                if(QuestionnaireLists.containsKey(question.Segment__c)){
                    QuestionnaireLists.get(question.Segment__c).add(question);
                }else{
                    List<AcctPlanQuestionnaire__c> qlist = new List<AcctPlanQuestionnaire__c>();
                    qlist.add(question);
                    QuestionnaireLists.put(question.Segment__c, qlist);
                }
            }
            
            for(String segment : SegmentSet){
                if(!QuestionnaireLists.containsKey(segment)){
                    List<AcctPlanQuestionnaire__c> qList = new List<AcctPlanQuestionnaire__c>();
                    
                    for(integer i =0;i<QuestionnaireTemplateMap.get(segment).size();i++){
                        
                        AcctPlanQuestionnaire__c question = new AcctPlanQuestionnaire__c ();
                        question.Question__c = QuestionnaireTemplateMap.get(segment).get(i).Question__c;
                        question.Segment__c = segment;
                        question.Question_TH__c = QuestionnaireTemplateMap.get(segment).get(i).Question_TH__c;
                        question.Opportunity__c = QuestionnaireTemplateMap.get(segment).get(i).Opportunity__c;
                        question.Sub_Domain__c  = QuestionnaireTemplateMap.get(segment).get(i).Sub_Domain__c;
                        question.Product_Label__c  = QuestionnaireTemplateMap.get(segment).get(i).Product_Label__c;
                        question.Sub_Segment_SEQ__c = QuestionnaireTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c;
                        question.Answer_Type__c  = QuestionnaireTemplateMap.get(segment).get(i).Answer_Field_Type__c;
                        question.SEQ__c  = QuestionnaireTemplateMap.get(segment).get(i).SEQ__c;
                        /*if(QuestionnaireTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c  !=null){
                            question.SEQ__c = QuestionnaireTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c ;
                        }else{
                            question.SEQ__c = QuestionnaireTemplateMap.get(segment).get(i).SEQ__c;
                        }*/
                        question.AcctPlanWallet__c = WalletID;
                        qList.add(question);
                    }
                    
                    QuestionnaireLists.put(segment, qList);
                }
            }
            
        }
        LGProject();
        LGPurchase();
    }
    
    public void LGProject(){
        ShortTermWalletLGFee = 0; 
        LongTermWalletLGFee = 0;
        Boolean isHasAPLGProject = true;
        APLGProjectList =[SELECT Id,LongTermLGPercent__c,LongTermLGRate__c,LongTermProjectValue__c,
                          ShortTermLGPercent__c,ShortTermLGRate__c,ShortTermProjectTenor__c,
                          ShortTermProjectValue__c
                          FROM AcctPlanLGProject__c 
                          WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        APLGProject = new AcctPlanLGProject__c();
        
        if(APLGProjectList.size() > 0){
            for(AcctPlanLGProject__c item :APLGProjectList){
                if(item.ShortTermProjectValue__c  == null){
                    item.ShortTermProjectValue__c  = 0;
                }
                if(item.ShortTermLGPercent__c == null){
                     item.ShortTermLGPercent__c  = 0;
                }
                if(item.ShortTermLGRate__c == null){
                     item.ShortTermLGRate__c = 0;
                }
                if(item.ShortTermProjectTenor__c == null){
                    item.ShortTermProjectTenor__c = 0;
                }
                if(item.LongTermProjectValue__c == null){
                    item.LongTermProjectValue__c = 0;                
                }
                if(item.LongTermLGPercent__c == null){
                    item.LongTermLGPercent__c = 0;
                }
                if(item.LongTermLGRate__c == null){
                    item.LongTermLGRate__c = 0;
                }                
           }
           
            APLGProject.Id = APLGProjectList.get(0).Id;
            APLGProject.AcctPlanWallet__c = acctplanwallet.Id;
            APLGProject.ShortTermProjectValue__c  = APLGProjectList.get(0).ShortTermProjectValue__c;
            APLGProject.ShortTermLGPercent__c  = APLGProjectList.get(0).ShortTermLGPercent__c;
            APLGProject.ShortTermLGRate__c  = APLGProjectList.get(0).ShortTermLGRate__c;
            APLGProject.ShortTermProjectTenor__c = APLGProjectList.get(0).ShortTermProjectTenor__c;
            APLGProject.LongTermProjectValue__c  = APLGProjectList.get(0).LongTermProjectValue__c;
            APLGProject.LongTermLGPercent__c  = APLGProjectList.get(0).LongTermLGPercent__c;
            APLGProject.LongTermLGRate__c  = APLGProjectList.get(0).LongTermLGRate__c;     
            
            ShortTermWalletLGFee = APLGProject.ShortTermProjectValue__c * (APLGProject.ShortTermLGPercent__c/100) * (APLGProject.ShortTermLGRate__c/100) * APLGProject.ShortTermProjectTenor__c/12; 
            LongTermWalletLGFee = APLGProject.LongTermProjectValue__c * (APLGProject.LongTermLGPercent__c/100) * (APLGProject.LongTermLGRate__c/100);   
            
        }else{
            isHasAPLGProject = false;
        }
        
        acctplanwallet.ShortTermWalletLGFee__c = ShortTermWalletLGFee;
        acctplanwallet.LongTermWalletLGFee__c =LongTermWalletLGFee;
        
        if(!isHasAPLGProject){
            APLGProject.AcctPlanWallet__c = acctplanwallet.Id;
        }
        
    }
    
    public void LGPurchase(){   
        Double SumOfWalletLGFeeYearly = 0;        
        if(isHasLGpurchase){
            SumOfWalletLGFeeYearly = ShortTermWalletLGFee  + LongTermWalletLGFee + acctplanwallet.LGPurchaseTotalWalletLGFee__c;
        }
        acctplanwallet.SumOfWalletLGFeeYearly__c = SumOfWalletLGFeeYearly;
    }    
    
    public PageReference save(){
        try{
            Boolean validate = true;
            if(APLGProject.ShortTermLGRate__c >100){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'L/G Fee (%) Short term project in the L/G Project must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3018').Status_Message__c));
            }
            
            if(APLGProject.LongTermLGRate__c >100){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'L/G Fee (%) Long term project in the L/G Project must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3019').Status_Message__c));
            }
            
            if(acctplanwallet.LGPurchaseRequiredLGPortion__c > 100){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Required L/G portion (%) in the L/G Purchase must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3020').Status_Message__c));
            }
            
           /* if(SeasonalPeriod == null || NormalPeriod == null || selectedStartmonth == null || selectedEndmonth == null){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'test')); 
            }*/
               
            
            if(validate){
                //Working Capital
                List<AcctPlanWorkingCapital__c> saveAPWorkingCapital = new List<AcctPlanWorkingCapital__c>();
                
                for(AcctPlanWorkingCapital__c item :APWorkingCapital){
                    if(item.RecordType__c == 'High Season Period'){
                        item.NoOfMonth__c = SeasonalPeriod;
                        if(!isHasSeasonal){
                            item.AvgAPDays__c = null;
                            item.AvgARDays__c = null;
                            item.AvgInvDays__c = null;
                            item.FrontEndFee__c = null;
                            item.NimcPercent__c = null;
                        }
                    }else{
                        item.NoOfMonth__c = NormalPeriod;
                    }
                    item.AcctPlanWallet__c = acctplanwallet.id;
                    saveAPWorkingCapital.add(item);
                }
                
                acctplanwallet.BusinessHasSeasonal__c  = Seasonal;
                if(isHasSeasonal){
                    acctplanwallet.HighSeasonStartMonth__c = covertMonthSave(selectedStartmonth);
                    acctplanwallet.HighSeasonEndMonth__c = covertMonthSave(selectedEndmonth);
                }else{
                    acctplanwallet.HighSeasonStartMonth__c = null;
                    acctplanwallet.HighSeasonEndMonth__c = null;
                }
                upsert saveAPWorkingCapital;
                
                //Credit Facility
                acctplanwallet.DataAsOfYearFacilityDomestic__c  = selectedDomesticyear;
                acctplanwallet.DataAsOfYearFacilityInternational__c  = selectedInternationalyear;
                
                //APQuestionnaire           
                Set<AcctPlanQuestionnaire__c> saveQuestion = new Set<AcctPlanQuestionnaire__c>();
                List <AcctPlanQuestionnaire__c> saveQuestionAll = new List<AcctPlanQuestionnaire__c>();
                
                system.debug('isHasLGProject='+isHasLGProject);
                system.debug('isHasLGpurchase='+isHasLGpurchase);
                system.debug('isHasLGUtilities='+isHasLGUtilities);
                system.debug('isHasLGTax='+isHasLGTax);
                        
                for(String segment : QuestionnaireLists.keySet()){
                    for(AcctPlanQuestionnaire__c item : QuestionnaireLists.get(segment)){
                        //LG Project
                        if((item.Question__c == '- L/G Bid' ||
                            item.Question__c == '- L/G Advance' ||
                            item.Question__c == '- L/G performance' ||
                            item.Question__c == '- L/G Retention') && !isHasLGProject){
                                item.Answer__c = null;    
                            } 
                        
                        if(item.Segment__c == 'L/G Project' && !isHasLGProject){
                            item.Answer__c = null;                              
                        }
                        /*if(item.Segment__c == 'AVAL & Acceptance' && !isHasLGUtilities){
                            item.Answer__c = null;                              
                        }
                        if(item.Segment__c == 'International bank section1' && !isHasLGTax){
                            item.Answer__c = null;   
                        }
                        if(item.Segment__c == 'International bank section2' && !isHasLGTax){
                            item.Answer__c = null;   
                        }
                        if(item.Segment__c == 'Shipping guarantee' && item.Answer__c != 'Yes'){
                            item.Answer__c = null;   
                        }
                        if(item.Segment__c == 'Request L/G' && item.Answer__c != 'Yes'){
                            item.Answer__c = null;   
                        }*/
                        
                        if(item.Question__c == '1.1 L/G project'){
                            item.Answer__c = selectedLGProject;                           
                        }else if(item.Question__c == '1.2 L/G purchase'){
                            item.Answer__c = selectedLGPurchase;
                        }else if(item.Question__c == '1.3 L/G Utilities'){
                            item.Answer__c = selectedLGUtilities;
                        }else if(item.Question__c == '1.4 L/G Tax'){
                            item.Answer__c = selectedLGTax;
                        }               
                        
                        item.AcctPlanWallet__c = acctplanwallet.id;
                        saveQuestion.add(item);
                    }
                    
                }
                if(!isHasLGProject){
                    if(APLGProjectList.size()>0){
                        delete APLGProject;
                        acctplanwallet.ShortTermWalletLGFee__c = 0;
                        acctplanwallet.LongTermWalletLGFee__c = 0;
                    }   
                }else{
                    upsert APLGProject;
                }
                
                if(!isHasLGpurchase){
                    acctplanwallet.LGPurchaseAmountPerMonth__c = 0;
                    acctplanwallet.LGPurchaseCreditTerm__c = 0;
                    acctplanwallet.LGPurchaseRequiredLGPortion__c = 0;
                    acctplanwallet.LGPurchaseLGFee__c = 0; 
                    //acctplanwallet.SumOfWalletLGFeeYearly__c = 0;
                }
                
                saveQuestionAll.addAll(saveQuestion);
                
                //Questionnaire
                upsert saveQuestionAll;
                
                //Account Plan Wallet
                workingCapital();
                CreditFacility(); 
                ExisitngLongTermLoan();
                CapitalExpenditurePlan();
                ContingentLiabilities();


                //FI Customer flag

                /*if(!acctplanwallet.FICustomerFlag__c){
                    acctPlanwallet.Spread__c =null;
                    acctPlanwallet.FX_Volume_per_Year_THB__c =null;

         
         
                    Double SumWalletFX = 0;
                    for(AcctPlanForeignTrans__c ft : [ SELECT ID,WalletFXFeePerYear__c
                                            FROM AcctPlanForeignTrans__c 
                                            WHERE AcctPlanWallet__c =: acctPlanwallet.id]){
                        SumWalletFX += ft.WalletFXFeePerYear__c;
                       
                    }
                    acctplanwallet.SumOfAcctPlanForeignWalletFXFeePerYear__c = SumWalletFX;
                }*/

                    
                upsert acctplanwallet;
                
                List<AcctPlanWallet__c> acctplanwalletListsSave = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
                if(acctplanwalletListsSave.size() > 0){
                    AcctPlanWallet__c acctplanwalletSave = acctplanwalletListsSave.get(0);
                    if(!isHasLGpurchase && !isHasLGProject){
                        acctplanwalletSave.SumOfWalletLGFeeYearly__c = 0;
                    }else{
                        acctplanwalletSave.SumOfWalletLGFeeYearly__c = acctplanwalletSave.ShortTermWalletLGFee__c + acctplanwalletSave.LongTermWalletLGFee__c + acctplanwalletSave.LGPurchaseTotalWalletLGFee__c;
                    }
                    upsert acctplanwalletSave;
                }
                
                companyprofile.Status__c = 'In Progress';
                update companyprofile;
                AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(acctplanwallet.AcctPlanCompanyProfile__c);
                
                PageReference redirectPage = View();
                return redirectPage;
            }else{
                return null;
            }
        }catch(Exception E){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public pageReference EditPage(){       
        PageReference redirectPage = Page.AccountPlanWalletDomainIIIEdit;
        redirectPage.getParameters().put('GroupID',GroupID);
        redirectPage.getParameters().put('CompanyID',CompanyID);
        redirectPage.getParameters().put('WalletID',WalletID);
        if(mode !=null && mode !=''){
            redirectPage.getParameters().put('mode',mode);
        }
        redirectPage.setRedirect(true);
        return redirectPage; 
    }
    
    public pageReference View(){
        PageReference redirectPage = Page.AccountPlanWalletDomainIIIView;
        redirectPage.getParameters().put('GroupID',GroupID);
        redirectPage.getParameters().put('CompanyID',CompanyID);
        redirectPage.getParameters().put('WalletID',WalletID);
        if(mode !=null && mode !=''){
            redirectPage.getParameters().put('mode',mode);
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    //old 
    public void Changetotalpercent(){
        System.debug('ChangeTotalPercent : '+TotalDomesticPercentage);
        if( TotalDomesticPercentage != null && TotalDomesticPercentage != 0 && TotalDomesticPercentage <=100){
            TotalExportPercentage = 100- TotalDomesticPercentage;
            
            if(EstimatedAmount != null && EstimatedAmount != 0){
                System.debug( EstimatedAmount*(TotalDomesticPercentage/100));
                System.debug(TotalDomesticAmount);
                 
                TotalDomesticAmount = Integer.valueOf(EstimatedAmount*(TotalDomesticPercentage/100));
                
                TotalExportAmount = EstimatedAmount - TotalDomesticAmount;
            }
        }else{
            TotalExportPercentage = 0;
            TotalDomesticAmount =0;
            TotalExportAmount = 0;
        }
    }

     /*Account Plan 5.2 : jantanee Saetung*/
    public void FICustomerFlagAction(){
        /*WorkingCapitalNeedsFI__c = limit x %utilization x margin (spread)*/
        
        APWorkingCapital = [SELECT Id,AvgAPDays__c ,AvgARDays__c , AvgInvDays__c, CreditFee__c, FrontEndFee__c, NimcPercent__c, 
                            NoOfMonth__c, RecordType__c, TotalCreditFee__c, TotalWalletNiic__c, TradeCycleDays__c,
                            WalletNIIC__c, WorkingCapitalNeeds__c , WorkingCapitalNeedsFI__c 
                            FROM AcctPlanWorkingCapital__c
                            WHERE AcctPlanWallet__c = :acctplanwallet.Id];
        system.debug('APWorkingCapital='+APWorkingCapital.size());
        if(APWorkingCapital.size() > 0){  
            APWorkingCapital = new List<AcctPlanWorkingCapital__c>();
            for(AcctPlanWorkingCapital__c item : [SELECT Id,AvgAPDays__c ,AvgARDays__c , AvgInvDays__c, CreditFee__c, FrontEndFee__c, NimcPercent__c, 
                                                  NoOfMonth__c, RecordType__c, TotalCreditFee__c, TotalWalletNiic__c, TradeCycleDays__c,
                                                  WalletNIIC__c, WorkingCapitalNeeds__c , WorkingCapitalNeedsFI__c 
                                                  FROM AcctPlanWorkingCapital__c
                                                  WHERE AcctPlanWallet__c = :acctplanwallet.Id]){ 
                if(acctplanwallet.FICustomerFlag__c == true){
                    item.AvgAPDays__c = 0;
                    item.AvgARDays__c = 0;
                    item.AvgInvDays__c = 0;
                    if(item.WorkingCapitalNeedsFI__c == null || item.WorkingCapitalNeedsFI__c <=0){
                        item.WorkingCapitalNeedsFI__c = null;
                    }else{
                        item.WorkingCapitalNeedsFI__c = item.WorkingCapitalNeedsFI__c;
                    }
                }else {
                    item.AvgAPDays__c = item.AvgAPDays__c;
                    item.AvgARDays__c = item.AvgARDays__c;
                    item.AvgInvDays__c = item.AvgInvDays__c;
                    if(item.WorkingCapitalNeedsFI__c == null || item.WorkingCapitalNeedsFI__c <=0){
                        item.WorkingCapitalNeedsFI__c = 0;
                    }else{
                        item.WorkingCapitalNeedsFI__c = item.WorkingCapitalNeedsFI__c;
                    }
                }
                system.debug('item.WorkingCapitalNeedsFI__c  = '+item.WorkingCapitalNeedsFI__c );
                APWorkingCapital.add(item);
            }
        }else{
            workingCapital();
        } 
    }

    /*public void Step3DoaminIIICompletionCheck(){  
        Integer FieldCount = 0;
        Integer FieldTotal = 0;
        
        String Seasonal = wallet.BusinessHasSeasonal__c;
        String HighSeasonStartMonth = wallet.HighSeasonStartMonth__c;
        String HighSeasonEndMonth = wallet.HighSeasonEndMonth__c;

        if(Seasonal != null){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        if(Seasonal == 'Yes'){
            if(HighSeasonStartMonth != null){FieldCount++;FieldTotal++;}else{FieldTotal++;}
            if(HighSeasonEndMonth != null){FieldCount++;FieldTotal++;}else{FieldTotal++;}
        }
        for(AcctPlanWorkingCapital__c item : [SELECT Id,AvgARDays__c, AvgInvDays__c, AvgAPDays__c, FrontEndFee__c, NimcPercent__c
                                              FROM AcctPlanWorkingCapital__c
                                              WHERE AcctPlanWallet__c = :wallet.Id]){
            if(item.RecordType__c = 'Normal Period' || (item.RecordType__c = 'High Season Period' && Seasonal == 'Yes')){
                if(item.AvgARDays__c != null && item.AvgARDays__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
                if(item.AvgInvDays__c != null && item.AvgInvDays__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
                if(item.AvgAPDays__c != null && item.AvgAPDays__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
                if(item.FrontEndFee__c != null && item.FrontEndFee__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
                if(item.NimcPercent__c != null && item.NimcPercent__c >0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
            }
        } 

        List<AcctPlanWalletCreditFacility__c> CreditFacilityDomestic = [SELECT Id,Bank__c, Bank__r.Name, Collateral__c , CreditType__c, LimitAmount__c, LTV__c, 
                            OtherCreditType__c, Outstanding__c, Segment__c
                            FROM AcctPlanWalletCreditFacility__c 
                            WHERE AcctPlanWallet__c = :wallet.Id AND Segment__c = 'Domestic'];
        if(CreditFacilityDomestic.size() > 0){FieldCount++;FieldTotal++;}else{FieldTotal++;}
    }*/
}