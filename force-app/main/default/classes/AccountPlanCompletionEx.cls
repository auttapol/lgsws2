public class AccountPlanCompletionEx {
	public AcctPlanCompanyProfile__c companyprofile { get; set; }
    public boolean isMiniView {get;set;}
	public AcctPlanGroupProfile__c groupprofile { get; set; }
	public Map<String, String> StyleClass { get; set; }
	public AcctPlanWallet__c wallet { get; set; }
	public Account_Plan_Completion__c Acctplancompletion { get; set; }
	public Double GrandTotalPercentage { get; set; }
	public Integer GrandTotalFieldNum { get; set; }
	public boolean IsMandatoryPage { get; set; }
	public List<Account_Plan_Mandatory__c> mandatoryList { get; set; }
	public List<Integer> MandatoryIndexList { get; set; }
	public Map<Integer, MandatoryWrapper> MandatoryWrapperMap { get; set; }
	public class MandatoryWrapper {
		public boolean isHasValue { get; set; }
		public boolean isFirstcolumn { get; set; }
		public Account_Plan_Mandatory__c mandatory { get; set; }
		public String styleClass { get {
				if (isHasValue) {
					return 'success';
				} else {
					return 'danger';
				}

			} set; }
		public String DomainStyle { get {

				if (mandatory.Domain__c == 'Step 1 Group Company') {
					return '#F1A9A0';
				} else if (mandatory.Domain__c == 'Step 2 Customer Profile') {
					return '#F4B350';

				} else if (mandatory.Domain__c == 'Step 3 Wallet By Domain - Domain I' ||
				           mandatory.Domain__c == 'Step 3 Wallet By Domain - Domain II' ||
				           mandatory.Domain__c == 'Step 3 Wallet By Domain - Domain III' ||
				           mandatory.Domain__c == 'Step 3 Wallet By Domain - Domain IV') {
					return '#C8F7C5';

				} else if (mandatory.Domain__c == 'Step 4 Product Strategy') {
					return '#FDE3A7';

				} else if (mandatory.Domain__c == 'Step 5 Decision Map and Action Plan') {
					return '#86E2D5';

				} else {
					return 'default';
				}


			} set; }

	}

	public AccountPlanCompletionEx() {
		//List<String> OverallCompletionLabel = new List<String>{'Step 1 - Group Company','Step 2 - Customer Profile','Step 3 - Wallet by Domain' ,'Step 4 - Product Strategy','Step 5 - Decision Map & Action Plan'};
		IsMandatoryPage = true;
		String CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
		if (CompanyID != null && CompanyID != '') {
			companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
            
            /*if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }*/
            
            isMiniView = AccountPlanUtilities.ISMINIVIEW;
            
			Acctplancompletion = [SELECT ID, Name, Account_Plan_Company_Profile__c,
			                      Step_1_Percentage__c, Step_2_Percentage__c, Step_3_Percentage__c,
			                      Step_4_Percentage__c, Step_5_Percentage__c, Step_6_Percentage__c,
			                      Step_1_Entered_Fields__c, Step_2_Entered_Fields__c,
			                      Step_3_1_Entered_Fields__c, Step_3_2_Entered_Fields__c,
			                      Step_3_3_Entered_Fields__c, Step_3_4_Entered_Fields__c,
			                      Step_4_Entered_Fields__c, Step_5_Entered_Fields__c,
			                      Step_1_Required_Fields__c, Step_2_Required_Fields__c, Step_3_Required_Fields__c,
			                      Step_3_1_Required_Fields__c, Step_3_2_Required_Fields__c,
			                      Step_3_3_Required_Fields__c, Step_3_4_Required_Fields__c,
			                      Step_4_Required_Fields__c, Step_5_Required_Fields__c,
			                      Account_Plan_Completion_Percentage__c
			                      FROM Account_Plan_Completion__c
			                      WHERE Account_Plan_Company_Profile__c = :CompanyID LIMIT 1];

			StyleClass = new Map<String, String> ();
			List<Double> Percentagelist = new List<Double> ();
			List<String> StepNamelist = new List<String> { 'Step 1', 'Step 2', 'Step 3', 'Step 4', 'Step 5' };
			Map<String, String> bootstrapclass = new Map<String, String> ();
			MandatoryWrapperMap = new Map<Integer, MandatoryWrapper> ();
			Percentagelist.add(Acctplancompletion.Step_1_Percentage__c);
			Percentagelist.add(Acctplancompletion.Step_2_Percentage__c);
			Percentagelist.add(Acctplancompletion.Step_3_Percentage__c);
			Percentagelist.add(Acctplancompletion.Step_4_Percentage__c);
			Percentagelist.add(Acctplancompletion.Step_5_Percentage__c);
			for (integer i = 0; i < Percentagelist.size(); i++) {
				Double Percentage = Percentagelist.get(i);
				String bootstrap = '';
				if (Percentage == null || Percentage < 50) { bootstrap = 'bg-danger'; }
				if (Percentage >= 50 && Percentage < 70) { bootstrap = 'bg-warning'; }
				if (Percentage >= 70 && Percentage < 100) { bootstrap = 'bg-info'; }
				if (Percentage == 100) { bootstrap = 'bg-success'; }
				StyleClass.put(StepNamelist.get(i), bootstrap);
			}
			mandatoryList = [SELECT ID, Condition__c, Domain__c, Required_Field__c, Section__c, SEQ__C
			                 FROM Account_Plan_Mandatory__c
			                 WHERE ID != null
			                 ORDER BY SEQ__c ASC];
			MandatoryIndexList = new List<Integer> ();
			String currentdomainname = '';
			for (Account_Plan_Mandatory__c manda : mandatoryList) {
                boolean isSEandWallet = false;
                if(isMiniView){
                    String Domain = manda.Domain__c;
                    if(domain.containsIgnoreCase('Step 3')){
                        isSEandWallet =true;
                    }
                }
				MandatoryWrapper wrapper = new MandatoryWrapper();
				wrapper.ishasvalue = false;
				wrapper.mandatory = manda;
                if(!isSEandWallet){
                    MandatoryWrapperMap.put(Integer.valueof(manda.SEQ__c), wrapper);
					MandatoryIndexList.add(Integer.valueof(manda.SEQ__c));
                }
				if (currentdomainname != manda.Domain__c) {
					currentdomainname = manda.Domain__c;
					wrapper.isFirstColumn = true;
				}
			}
			if (companyprofile.AcctPlanGroup__c != null) {
				groupprofile = AccountPlanUtilities.QueryGroupProfileByID(companyprofile.AcctPlanGroup__c).get(0);
				Step1CompletionCheck();
			}
			Step2CompletionCheck();
            List<AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
            system.debug('walletList='+walletList.size());
            if (walletList.size() > 0) {
                wallet = walletList.get(0);
                if(!isMiniView){
                    Step3Domain1CompletionCheck();
                    Step3Domain2CompletionCheck();
                    Step3Domain3CompletionCheck();
                    Step3Domain4CompletionCheck();
                }
                    Step4CompletionCheck();
                    Step5CompletionCheck();
                
            }
		} else {

			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account Plan Company Profile ID is null.'));

		}


	}
	public AccountPlanCompletionEx(String CompanyID) {
		GrandTotalPercentage = 0.00;
		GrandTotalFieldNum = 0;
		if (CompanyID != null && CompanyID != '') {
			IsMandatoryPage = false;
			companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);



			//Query
			List<Account_Plan_Completion__c> CompleteList = [SELECT ID, Name,
			                                                 Account_Plan_Company_Profile__c,
			                                                 Step_2_Percentage__c,
			                                                 Step_2_Required_Fields__c,
			                                                 Account_Plan_Completion_Percentage__c
			                                                 FROM Account_Plan_Completion__c
			                                                 WHERE Account_Plan_Company_Profile__c = :companyprofile.id LIMIT 1];

			//Initiate
			if (CompleteList.size() > 0) {
				Acctplancompletion = CompleteList.get(0);
			} else {
				Acctplancompletion = new Account_Plan_Completion__c();
				Acctplancompletion.Account_Plan_Company_Profile__c = companyprofile.id;
				if (companyprofile.AcctPlanGroup__c != null) {
					Acctplancompletion.Account_Plan_Group_Profile__c = companyprofile.AcctPlanGroup__c;
				}
			}

			//Step1
			if (companyprofile.AcctPlanGroup__c != null) {
				groupprofile = AccountPlanUtilities.QueryGroupProfileByID(companyprofile.AcctPlanGroup__c).get(0);
				Step1CompletionCheck();
			}
            
            

			//Step2
			Step2CompletionCheck();
			List<AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
			System.debug('walletList : ' + walletList);
			if (walletList.size() > 0) {
				wallet = walletList.get(0);
				Step3Domain1CompletionCheck();
				Step3Domain2CompletionCheck();
				Step3Domain3CompletionCheck();
				Step3Domain4CompletionCheck();
				Step4CompletionCheck();
				Step5CompletionCheck();
			} else {
				Acctplancompletion.Step_3_1_Entered_Fields__c = 0;
				Acctplancompletion.Step_3_1_Required_Fields__c = 1;
				Acctplancompletion.Step_3_2_Entered_Fields__c = 0;
				Acctplancompletion.Step_3_2_Required_Fields__c = 1;
				Acctplancompletion.Step_3_3_Entered_Fields__c = 0;
				Acctplancompletion.Step_3_3_Required_Fields__c = 1;
				Acctplancompletion.Step_3_4_Entered_Fields__c = 0;
				Acctplancompletion.Step_3_4_Required_Fields__c = 1;
				Acctplancompletion.Step_4_Entered_Fields__c = 0;
				Acctplancompletion.Step_4_Required_Fields__c = 1;
				Acctplancompletion.Step_5_Entered_Fields__c = 0;
				Acctplancompletion.Step_5_Required_Fields__c = 1;
			}

			if (Acctplancompletion.id != null) {
				update Acctplancompletion;
			} else {
				insert Acctplancompletion;
			}

			if (acctplancompletion.Account_Plan_Completion_Percentage__c == 100) {
				companyprofile.isAvailableforApproval__c = true;
			} else {
				companyprofile.isAvailableforApproval__c = false;
			}

			//start issue inactive step5-6
			System.debug('###UpdateComprofile inactive flag###'); 

			//List<AcctPlanWallet__c> walletList =[SELECT ID,AcctPlanCompanyProfile__c FROM AcctPlanWallet__c WHERE AcctPlanCompanyProfile__c =: CompanyID];

			if(walletList.size()>0){

				AcctPlanWallet__c wallet = walletList.get(0);
                List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c
                                                      where AcctPlanWallet__c =: wallet.Id];


                List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Objective__c, Status__c, WinningPropostion__c
                                                      FROM AcctPlanActionPlan__c
                                                      WHERE AcctPlanWalletByDomain__c IN :domainList];

                System.debug('actionplanList='+actionplanList.size()); 
                if(actionplanList.size()>0){
                	System.debug('companyprofile.isHasActionPlan__c='+companyprofile.isHasActionPlan__c); 
                    if(!companyprofile.isHasActionPlan__c || companyprofile.isHasActionPlan__c == null ){
                        companyprofile.isHasActionPlan__c = true;
                    }
                }

             }
            List<AcctPlanProdStrategy__c> productStrategyList = [SELECT Id,AcctPlanCompanyProfileID__c FROM AcctPlanProdStrategy__c  Where AcctPlanCompanyProfileID__c =: CompanyID];
			if(productStrategyList.size()>0){
				companyprofile.isHasProdStrategy__c = true;
			}
			//end issue inactive step5-6

			update companyprofile;
		}
	}



	public void Step1CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;
		if (groupprofile.Name != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(1).ishasValue = true; } } else { FieldTotal++; }
        if (groupprofile.Year__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(2).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.Group_Industry_Info__c  != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(3).ishasValue = true; } } else { FieldTotal++; }
        if (groupprofile.GroupRevenue__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(4).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.ShareholdingStructure__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(5).ishasValue = true; } } else { FieldTotal++; }
		
		if (groupprofile.BusinessFlow__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(6).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.BargainingPowerOfSupplier__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(8).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.BargainingPowerOfBuyer__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(9).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.BarrierOfNewEntrant__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(10).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.ThreatOfSubstituteProduct__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(11).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.IndustryCompetition__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(12).ishasValue = true; } } else { FieldTotal++; }
		if (groupprofile.FactorType1__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(13).ishasValue = true; } } else { FieldTotal++; }
		List<AcctPlanContribution__c> contributionlist = [SELECT ID,
		                                                  AccountPlanGroupProfile__c
		                                                  FROM AcctPlanContribution__c
		                                                  WHERE AccountPlanGroupProfile__c = :groupprofile.Id
		                                                  AND Account_Plan_Company_Profile__c =null];
		if (contributionlist.size() > 0) { FieldCount++; FieldTotal++;
                                          if (IsMandatoryPage) {MandatoryWrapperMap.get(7).ishasValue = true;}
                                         } else { FieldTotal++; }

		Acctplancompletion.Step_1_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_1_Required_Fields__c = FieldTotal;
        

	}

	public void Step2CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;
		if (companyprofile.Year__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(14).ishasValue = true; } } else { FieldTotal++; }
		if (companyprofile.Name != null) {  FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(15).ishasValue = true; } } else { FieldTotal++; }
		if (companyprofile.ShareholdingStructure__c != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(16).ishasValue = true; } } else { FieldTotal++; }
		//Contribution
		//
		List<AcctPlanContribution__c> contributionlist = [SELECT ID,
		                                                  Account_Plan_Company_Profile__c
		                                                  FROM AcctPlanContribution__c
		                                                  WHERE Account_Plan_Company_Profile__c = :companyprofile.Id];
		if (contributionlist.size() > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(17).ishasValue = true; } } else { FieldTotal++; }

		Acctplancompletion.Step_2_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_2_Required_Fields__c = FieldTotal;

	}


	public void Step3Domain1CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;

		if (wallet.EstimatedSalesAmtPerYear__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(18).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.TotalDomesticPercent__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(19).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.COGSPercent__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(20).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.OperatingExpAmount__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(21).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.TotalPaymentDomesticPercent__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(22).ishasValue = true; } } else { FieldTotal++; }
        
        		// Currency
		//
		Boolean isHasCollectionCurrency = false;
		Boolean IsHasPaymentCurrency = false;
		List<AcctPlanCollectionOrPaymentCurrency__c> CurrencyList = [SELECT Name, AcctPlanWallet__c,
		                                                             CCY__c,
		                                                             CCY__r.ShortName__c,
		                                                             CollectionAmtPerYear__c,
		                                                             CollectionIsDeleted__c,
		                                                             CollectionPortion__c,
		                                                             Currency_Type__c,
		                                                             PaymentAmtPerYear__c,
		                                                             PaymentIsDeleted__c,
		                                                             PaymentPortion__c
		                                                             FROM AcctPlanCollectionOrPaymentCurrency__c
		                                                             WHERE AcctPlanWallet__c = :wallet.id];

		for (AcctPlanCollectionOrPaymentCurrency__c curr : CurrencyList) {
			if (curr.Currency_Type__c == 'Collection') {
				isHasCollectionCurrency = true;
			} else if (curr.Currency_Type__c == 'Payment') {
				IsHasPaymentCurrency = true;
			}
		}




		if (wallet.TotalExportPercent__c > 0) {
			if (isHasCollectionCurrency) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(26).ishasValue = true; } } else { FieldTotal++; }
		}
        
		if (wallet.TotalPaymentImportPercent__c > 0) {
			if (IsHasPaymentCurrency) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(29).ishasValue = true; } } else { FieldTotal++; }
		}
        
        
        
        
        
        
		//CollectionDomestic

		List <Account_Plan_Flow_Details__c> CDflowdetailList = new List<Account_Plan_Flow_Details__c>();
		List <Account_Plan_Flow_Details__c> CEflowdetailList = new List<Account_Plan_Flow_Details__c>();
		List <Account_Plan_Flow_Details__c> PDflowdetailList = new List<Account_Plan_Flow_Details__c>();
		List <Account_Plan_Flow_Details__c> PIflowdetailList = new List<Account_Plan_Flow_Details__c>();		




		for (Account_Plan_Flow_Details__c fdetail : [SELECT ID, Account_Plan_Flow_Header__c , Account_Plan_Wallet__c,
                                   FeeCharge__c ,Pattern__c ,TermDays__c ,
                                   NoOfTransaction__c,Volume__c ,
                                   Account_Plan_Flow_Header__r.isExcludeforSum__c,
                                   Account_Plan_Flow_Header__r.isFreeCharge__c ,
                                   Account_Plan_Flow_Header__r.method__c,
                                   Account_Plan_Flow_Header__r.isVolumePercent__c,
                                   Account_Plan_Flow_Header__r.Label__c ,                                   
                                   VolumePercent__c ,CD_WalletFee__c,AvgProvidentFund__c,
                                   Account_Plan_Flow_Header__r.Account_Plan_Flow_Header__c
                                 FROM Account_Plan_Flow_Details__c 
                                 WHERE Account_Plan_Wallet__c =: wallet.id
                                 AND Account_Plan_Flow_Header__r.isActive__c = true                                      
                                 ORDER BY Account_Plan_Flow_Header__r.SEQ__c ASC,Account_Plan_Flow_Header__r.method__c ASC]){

			if(fdetail.Account_Plan_Flow_Header__r.method__c == 'Collection Domestic' ){
				CDflowdetailList.add(fdetail);
			}else if(fdetail.Account_Plan_Flow_Header__r.method__c == 'Collection Export'){
				CEflowdetailList.add(fdetail);
			}else if(fdetail.Account_Plan_Flow_Header__r.method__c == 'Payment Domestic'){
				PDflowdetailList.add(fdetail);
			}else if(fdetail.Account_Plan_Flow_Header__r.method__c == 'Payment Import'){
				PIflowdetailList.add(fdetail);
			}

		}







		if (wallet.TotalDomesticPercent__c > 0) {
			List<AcctPlanCollectionDomestic__c> collectdomesticlist = [SELECT ID, AcctPlanCollectionMethodDomestic__c, NoOfTransaction__c,
			                                                           Volume__c, Label__c
			                                                           FROM AcctPlanCollectionDomestic__c
			                                                           WHERE AcctPlanCollectionMethodDomestic__c = :wallet.id];


			Boolean BillisHasVolume = false;
			Boolean BillisHasNumberOfTransaction = false;
			Boolean CDHasVolume = false;
			for (AcctPlanCollectionDomestic__c cd : collectdomesticlist) {
              if(cd.Label__c !='2) Cheque'
                       && cd.Label__c !='5) Card' 
                       &&cd.Label__c!=null ){
				if (cd.Label__c == '3) Bill Payment') {
					if (cd.Volume__c > 0) { BillisHasVolume = true; }
					if (cd.NoOfTransaction__c > 0 && cd.NoOfTransaction__c!= null) { BillisHasNumberOfTransaction = true; }
                }else{
                   if (cd.Volume__c > 0) { CDHasVolume = true; }
                }
             }
			}


			if(CDflowdetailList.size() >0){
				BillisHasVolume= false;
				BillisHasNumberOfTransaction = false;
				CDHasVolume = false;
			}


			for(Account_Plan_Flow_Details__c CDdetail : CDflowdetailList){
				if(!CDdetail.Account_Plan_Flow_Header__r.isExcludeforSum__c
					&& CDdetail.Account_Plan_Flow_Header__r.isVolumePercent__c){
					if(Cddetail.Account_Plan_Flow_Header__r.Label__c =='3) Bill Payment'){
						if (Cddetail.Volume__c > 0) { BillisHasVolume = true; }
						if (Cddetail.NoOfTransaction__c > 0 && Cddetail.NoOfTransaction__c!= null) { BillisHasNumberOfTransaction = true; }
					}else{
						if (Cddetail.Volume__c > 0) { CDHasVolume = true; }
					}

				}

			}









			if (BillisHasVolume || CDHasVolume) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(23).ishasValue = true; }

			} else {
				FieldTotal++;
			}
			if (BillisHasVolume) {
				if (BillisHasNumberOfTransaction) { FieldCount++; FieldTotal++;
					if (IsMandatoryPage) { MandatoryWrapperMap.get(24).ishasValue = true; }} else { FieldTotal++; }
            }else{
                if (IsMandatoryPage) { MandatoryWrapperMap.get(24).ishasValue = true; }
            }
        }else{
            if (IsMandatoryPage) { MandatoryWrapperMap.get(23).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(24).ishasValue = true; }  
        }

		//CollectionExport
		if (wallet.TotalExportPercent__c > 0) {
			List<AcctPlanCollectionExport__c> cExportList = [SELECT ID, AcctPlanCollectionMethodExport__c,Label__c, Volumn__c
			                                                 FROM AcctPlanCollectionExport__c
			                                                 WHERE AcctPlanCollectionMethodExport__c = :wallet.id];

			Boolean CEisHasVolume = false;
			for (AcctPlanCollectionExport__c cE : cExportList) {
                if( cE.Label__c !='2) Export collection' 
                   && cE.Label__c !='3) Advice L/C'){
					if (cE.Volumn__c > 0) { CEisHasVolume = true; }
                }
			}

			if(CEflowdetailList.size()>0){
				CEisHasVolume = false;
			}

			for (Account_Plan_Flow_Details__c CEdetail : CEflowdetailList) {
	               if(!CEdetail.Account_Plan_Flow_Header__r.isExcludeforSum__c
	               	&& CEdetail.Account_Plan_Flow_Header__r.isVolumePercent__c){
	               			if (CEdetail.Volume__c > 0) { CEisHasVolume = true; }
	               
	           }
			}


			if (CEisHasVolume) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(25).ishasValue = true; } } else { FieldTotal++; }
        }else{
            if (IsMandatoryPage) { MandatoryWrapperMap.get(25).ishasValue = true; } 
            if (IsMandatoryPage) { MandatoryWrapperMap.get(26).ishasValue = true; } 
            
        }
		//Payment Domestic
		if (wallet.TotalPaymentDomesticPercent__c > 0 && wallet.TotalPaymentDomesticAmtPerYear__c >0) {
			List<AcctPlanPaymentDomestic__c> pDomesticList = [SELECT ID, AcctPlanPaymentMethodDomestic__c,Label__c, Volume__c
			                                                  FROM AcctPlanPaymentDomestic__c
			                                                  WHERE AcctPlanPaymentMethodDomestic__c = :wallet.id];

			Boolean PDisHasVolume = false;
			for (AcctPlanPaymentDomestic__c pD : pDomesticList) {
                if( pD.Label__c != '2) Cheque'){
					if (pD.Volume__c > 0) { PDisHasVolume = true; }
            	}
			}

			if(PDflowdetailList.size() >0){
				PDisHasVolume = false;
			}
			for (Account_Plan_Flow_Details__c PDdetail : PDflowdetailList) {
	               if(!PDdetail.Account_Plan_Flow_Header__r.isExcludeforSum__c
	               	&& PDdetail.Account_Plan_Flow_Header__r.isVolumePercent__c){
	               			if (PDdetail.Volume__c > 0) { PDisHasVolume = true; }
	               
	           }
			}


			if (PDisHasVolume) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(27).ishasValue = true; } } else { FieldTotal++; }
        }else{
            if (IsMandatoryPage) { MandatoryWrapperMap.get(27).ishasValue = true; }
            
        }



		//Payment Import
		//
		System.debug(wallet.TotalPaymentImportPercent__c);
		if (wallet.TotalPaymentImportPercent__c > 0 && wallet.TotalPaymentImportAmtPerYear__c >0) {
			List<AcctPlanPaymentImport__c> pImportList = [SELECT ID, AcctPlanPaymentMethodImport__c, Volume__c,Label__c, Type_of_Fee__c 
			                                              FROM AcctPlanPaymentImport__c
			                                              WHERE AcctPlanPaymentMethodImport__c = :wallet.id];
			Boolean PIisHasVolume = false;
			for (AcctPlanPaymentImport__c pI : pImportList) {
                if(pI.Type_of_Fee__c != 'Engagement Fee'
                   && pI.Label__c != '2) Bill'
                   && pI.Label__c != '3) Import L/C'){
				if (pI.Volume__c > 0) { PIisHasVolume = true; }
                }
			}

			if(PIflowdetailList.size() >0){
				PIisHasVolume = false;
			}
			for (Account_Plan_Flow_Details__c PIdetail : PIflowdetailList) {
	               if(!PIdetail.Account_Plan_Flow_Header__r.isExcludeforSum__c
	               	&& PIdetail.Account_Plan_Flow_Header__r.isVolumePercent__c){
	               			if (PIdetail.Volume__c > 0) { PIisHasVolume = true; }
	               
	           }
			}



			if (PIisHasVolume) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(28).ishasValue = true; } } else { FieldTotal++; }

        }else{
            if (IsMandatoryPage) { MandatoryWrapperMap.get(28).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(29).ishasValue = true; }
        }




		Acctplancompletion.Step_3_1_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_3_1_Required_Fields__c = FieldTotal;

	}

	public void Step3Domain2CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;
		if (wallet.CashCycle__c != null && wallet.CashCycle__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(30).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.NimdPercent_OperatingTransaction__c != null && wallet.NimdPercent_OperatingTransaction__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(31).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.CashOnHand__c != null && wallet.CashOnHand__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(32).ishasValue = true; } } else { FieldTotal++; }
		if (wallet.InvestmentAmount__c != null && wallet.InvestmentAmount__c >= 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(33).ishasValue = true; } } else { FieldTotal++; }
		/*if (wallet.NimdPercent_CashOnHand__c != null && wallet.NimdPercent_CashOnHand__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(34).ishasValue = true; } } else { FieldTotal++; }*/
        //New field in Step 3 Domain 2 : Jantanee Saetang Account Plan R5.2 
        if (wallet.CashOnHand_Nimd__c != null && wallet.CashOnHand_Nimd__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(34).ishasValue = true; } } else { FieldTotal++; }
        if (wallet.InvestmentAmount_NIMd__c != null && wallet.InvestmentAmount_NIMd__c > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(35).ishasValue = true; } } else { FieldTotal++; }
       // if (wallet.AS_Fee__c != null && wallet.AS_Fee__c > 0) { FieldCount++; FieldTotal++;
		//	if (IsMandatoryPage) { MandatoryWrapperMap.get(59).ishasValue = true; } } else { FieldTotal++; }

		Acctplancompletion.Step_3_2_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_3_2_Required_Fields__c = FieldTotal;

	}

	public void Step3Domain3CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;

		String Seasonal = wallet.BusinessHasSeasonal__c;
		String HighSeasonStartMonth = wallet.HighSeasonStartMonth__c;
		String HighSeasonEndMonth = wallet.HighSeasonEndMonth__c;
		Boolean isFICustomer = wallet.FICustomerFlag__c;
		//35-48
		if (Seasonal != null) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(36).ishasValue = true; } } else { FieldTotal++; }
		
		for (AcctPlanWorkingCapital__c item :[SELECT Id, AvgARDays__c, AvgInvDays__c, AvgAPDays__c, FrontEndFee__c, NimcPercent__c, RecordType__c
		     FROM AcctPlanWorkingCapital__c
		     WHERE AcctPlanWallet__c = :wallet.Id]) {
			if (item.RecordType__c == 'Normal Period' || (item.RecordType__c == 'High Season Period' && Seasonal == 'Yes')) {
					
				if ((item.AvgARDays__c != null && item.AvgARDays__c >= 0) || isFICustomer) {
					if (IsMandatoryPage) {
						FieldCount++; FieldTotal++;
						if (item.RecordType__c == 'Normal Period') {
							MandatoryWrapperMap.get(39).ishasValue = true;
						} else {
							MandatoryWrapperMap.get(44).ishasValue = true;
						}
					}
				} else { FieldTotal++; }
				if ((item.AvgInvDays__c != null && item.AvgInvDays__c >= 0) || isFICustomer) {
					if (IsMandatoryPage) {
						FieldCount++; FieldTotal++;
						if (item.RecordType__c == 'Normal Period') {
							MandatoryWrapperMap.get(40).ishasValue = true;
						} else {
							MandatoryWrapperMap.get(45).ishasValue = true;
						}
					}
				} else { FieldTotal++; }
				if ((item.AvgAPDays__c != null && item.AvgAPDays__c >= 0) || isFICustomer) {
					if (IsMandatoryPage) {
						FieldCount++; FieldTotal++;
						if (item.RecordType__c == 'Normal Period') {
							MandatoryWrapperMap.get(41).ishasValue = true;
						} else {
							MandatoryWrapperMap.get(46).ishasValue = true;
						}
					}
				} else { FieldTotal++; }
				if (item.NimcPercent__c != null && item.NimcPercent__c > 0) {
					if (IsMandatoryPage) {
						FieldCount++; FieldTotal++;
						if (item.RecordType__c == 'Normal Period') {
							MandatoryWrapperMap.get(42).ishasValue = true;
						} else {
							MandatoryWrapperMap.get(47).ishasValue = true;
						}
					}
				} else { FieldTotal++; }
				if (item.FrontEndFee__c != null && item.FrontEndFee__c >= 0) {
					if (IsMandatoryPage) {
						FieldCount++; FieldTotal++;
						if (item.RecordType__c == 'Normal Period') {
							MandatoryWrapperMap.get(43).ishasValue = true;
						} else {
							MandatoryWrapperMap.get(48).ishasValue = true;
						}
					}
				} else { FieldTotal++; }


			}
		}


       
        
        
        if (Seasonal == 'Yes') {
			if (HighSeasonStartMonth != null) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(37).ishasValue = true; } } else { FieldTotal++; }
			if (HighSeasonEndMonth != null) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(38).ishasValue = true; } } else { FieldTotal++; }
        }else{
            if (IsMandatoryPage) { MandatoryWrapperMap.get(37).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(38).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(44).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(45).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(46).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(47).ishasValue = true; }
            if (IsMandatoryPage) { MandatoryWrapperMap.get(48).ishasValue = true; }
        }





        



		List<AcctPlanWalletCreditFacility__c> CreditFacilityDomestic = [SELECT Id, Bank__c, Bank__r.Name, Collateral__c, CreditType__c, LimitAmount__c, LTV__c,
		                                                                OtherCreditType__c, Outstanding__c, Segment__c
		                                                                FROM AcctPlanWalletCreditFacility__c
		                                                                WHERE AcctPlanWallet__c = :wallet.Id AND Segment__c = 'Domestic'];
		if (CreditFacilityDomestic.size() > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(49).ishasValue = true; } } else { FieldTotal++; }


		Acctplancompletion.Step_3_3_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_3_3_Required_Fields__c = FieldTotal;
	}

	public void Step3Domain4CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;

		List<AcctPlanQuestionnaire__c> QuestionnaireList = [SELECT ID, Answer__c
		                                                    FROM AcctPlanQuestionnaire__c
		                                                    WHERE AcctPlanWallet__c = :wallet.id
		                                                    AND Segment__c = :'Credit life insurance'];

		if (QuestionnaireList.size() > 0) {
			AcctPlanQuestionnaire__c question = QuestionnaireList.get(0);


			if (question.Answer__c != null) { FieldCount++; FieldTotal++;
				if (IsMandatoryPage) { MandatoryWrapperMap.get(50).ishasValue = true; } } else { FieldTotal++; }
			if (question.Answer__c == 'Yes') {
				if (wallet.AmtOfCreditFaciWithTMB__c > 0 && wallet.AmtOfCreditFaciWithTMB__c !=null) { FieldCount++; FieldTotal++;
					if (IsMandatoryPage) { MandatoryWrapperMap.get(51).ishasValue = true; } } else { FieldTotal++; }
				if (wallet.ProtectionPercent__c >= 0 && wallet.ProtectionPercent__c  !=null) { FieldCount++; FieldTotal++;
					if (IsMandatoryPage) { MandatoryWrapperMap.get(52).ishasValue = true; } } else { FieldTotal++; }
				if (wallet.BA_Premium__c >= 0 &&wallet.BA_Premium__c !=null) { FieldCount++; FieldTotal++;
					if (IsMandatoryPage) { MandatoryWrapperMap.get(53).ishasValue = true; } } else { FieldTotal++; }
            }else{
                if (IsMandatoryPage) { MandatoryWrapperMap.get(51).ishasValue = true; }
                if (IsMandatoryPage) { MandatoryWrapperMap.get(52).ishasValue = true; }
                if (IsMandatoryPage) { MandatoryWrapperMap.get(53).ishasValue = true; }
            }

		} else {
			FieldTotal++;
		}



		Acctplancompletion.Step_3_4_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_3_4_Required_Fields__c = FieldTotal;


	}


	public void Step4CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;
		boolean isHasPriority = false;
        boolean isAspirationSOW = false;
        //Priority
		for (AcctPlanWalletByDomain__c wallByDomain : AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(new Set<Id> { wallet.id })) {


			if (wallbyDomain.Priority__c == 'High' || wallbyDomain.Priority__c == 'Medium') {
				isHasPriority = true;
			}
		}
        
        //AspirationSOW
        List<AcctPlanProdStrategy__c> acctPlanProdStrategies = AccountPlanProductStrategyService.getCompaniesProductStrategy(new Set<Id> { companyprofile.id });

         for (AcctPlanProdStrategy__c item : acctPlanProdStrategies) {
         	if ((item.SEQ__c != 3 && item.SEQ__c != 4 && item.SEQ__c != 10) && 
						(
							((item.SEQ__c != 9 && item.SEQ__c != 13 && item.SEQ__c != 14) && (item.AspirationSOW__c != 0 && item.AspirationSOW__c != null)) ||
							((item.SEQ__c == 9 || item.SEQ__c == 13 || item.SEQ__c == 14) && (item.ExpectedIncrementalNI__c != 0 && item.ExpectedIncrementalNI__c != null))
						)
						) {
						isAspirationSOW = true;
			}

            /* if((item.AspirationSOW__c != 0 && item.AspirationSOW__c != null) ||(item.ExpectedIncrementalNI__c != 0 && item.ExpectedIncrementalNI__c != null) ){
                 isAspirationSOW = true;
             }*/
         }
        
       
		if (isAspirationSOW) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(54).ishasValue = true; } } else { FieldTotal++; }
		if (isHasPriority) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(55).ishasValue = true; } } else { FieldTotal++; }

		Acctplancompletion.Step_4_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_4_Required_Fields__c = FieldTotal;
	}

	public void Step5CompletionCheck() {
		Integer FieldCount = 0;
		Integer FieldTotal = 0;

		List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c
		                                              where AcctPlanWallet__c = :wallet.id];


		List<AcctPlanActionPlan__c> actionplanList = [SELECT Id, Objective__c, Status__c, WinningPropostion__c
		                                              FROM AcctPlanActionPlan__c
		                                              WHERE AcctPlanWalletByDomain__c IN :domainList];


		List<AcctPlanActivity__c> actionactivityList = [SELECT ID, AccountPlanActionPlanID__c, Date__c
		                                                FROM AcctPlanActivity__c
		                                                WHERE AccountPlanActionPlanID__c IN :actionplanList];


		List<AcctPlanNIProject__c> NIProjectList = [SELECT ID, AcctPlanActionPlanID__c
		                                            FROM AcctPlanNIProject__c
		                                            WHERE AcctPlanActionPlanID__c IN :actionplanList];


		if (actionplanList.size() > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(56).ishasValue = true; } } else { FieldTotal++; }
		if (NIProjectList.size() > 0) { FieldCount++; FieldTotal++;
			if (IsMandatoryPage) { MandatoryWrapperMap.get(57).ishasValue = true; } } else { FieldTotal++; }
		Acctplancompletion.Step_5_Entered_Fields__c = FieldCount;
		Acctplancompletion.Step_5_Required_Fields__c = FieldTotal;

	}

}