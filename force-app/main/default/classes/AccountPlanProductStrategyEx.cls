public class AccountPlanProductStrategyEx {
	//region
	public ViewState ViewState { get; set; }
	private ApexPages.StandardController standardController;


	//public Boolean IsNeedInitData { get; set; }
	public Boolean IsSESegment { get; set; }
	public Boolean isHasPermission { get; set; }
	public boolean isAccountTeamReadWrite { get; set; }
	public Boolean IsHasGroupId { get; set; }
	public boolean isSystemAdmin { get; set; }
	public String btnGroupWallet { get; set; }


	//	public String AccountID { get; set; }
	//	public AcctPlanWallet__c Wallet { get; set; }


	//	public string selectedYesOrNo { get; set; }
	//	public string selectedYes { get; set; }
	//	public string selectedNo { get; set; }
	//	public String selectedLow { get; set; }
	//	public String selectedMedium { get; set; }
	//	public String selectedHigh { get; set; }
	//	public Boolean isShowGroupWallet { get; set; }
	//	public String buttonName { get; set; }
	//	public String runAsToday { get { return System.Now().format('MM/dd/yyyy HH:mm:ss'); } }

	public Account_Plan_Completion__c Acctplancompletion { get; set; }
	public Boolean isMiniView { get; set; }
	public String mode { get; set; }
	public Boolean isConsoleMode { get; set; }
	public Boolean ishasProdStrategy { get; set; }
	public Boolean isHasActionPlan { get; set; }
	public AcctPlanCompanyProfile__c companyprofile { get; set; }

	public Datetime RefreshAsOf { get; set; }
	public Boolean isWarningMandatoryFields { get; set; }
	public Boolean isWarningAspirationSOW_ExpectedIncrementalNI { get; set; }
	public Boolean isHasAspirationSOW_ExpectedIncrementalNI_ASFee { get; set; }
	public Boolean isWarningPriority { get; set; }
	public Boolean isWarningASFee { get; set; }
	public String WarningPriorityEN { get; set; }
	public String WarningPriorityTH { get; set; }
	public String WarningAspirationSOW { get; set; }
	//endregion
	public AccountPlanProductStrategyEx(ApexPages.StandardController controller) {
		IsHasGroupId = false;
		standardController = controller;
		ViewState = new ViewState();
		//IsNeedInitData = false;
		IsSESegment = false;
		mode = ApexPages.currentPage().getParameters().get('mode');
		if (mode == 'console') {
			isConsoleMode = true;
		} else {
			isConsoleMode = false;
		}

		initCssId();


		ViewState.WalletID = ApexPages.currentPage().getParameters().get('WalletID');
		ViewState.CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
		if (ApexPages.currentPage().getParameters().containsKey('GroupID')) {
			ViewState.GroupID = ApexPages.currentPage().getParameters().get('GroupID');
			IsHasGroupId = true;

			if (ViewState.GroupID != '')
			btnGroupWallet = '<a class="btn btn-primary btn-sm" onclick="popupNewWindow(\'/apex/AccountPlanGroupWalletV2?GroupID=' + ViewState.GroupID + '&CompanyID='+ ViewState.CompanyID + '&WalletID=' + ViewState.WalletID +'&step=4\', \'_blank\', \'scrollbars=1,resizable=1,width=1000,height=800,left=50,top=50\'); return false;">Show Group\'s wallet</a>';


		}
		else {
			ViewState.GroupID = '';
			btnGroupWallet = '';
		}

		if (ViewState.CompanyID != null && ViewState.CompanyID != '') {
			companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(ViewState.CompanyID).get(0);
			ishasProdStrategy = companyprofile.isHasProdStrategy__c;
			isHasActionPlan = companyprofile.isHasActionPlan__c;
			isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
			isSystemAdmin = AccountPlanUtilities.isSystemAdmin;
		}
		// ***************   Current version  1 Company Profile  will have only 1 Wallet  **************************        
		List<AcctPlanWallet__c> Wallets = AccountPlanWalletSelector.getWalletByCompanyProfileIds(new Set<Id> { ViewState.CompanyID });
		if (Wallets.size() > 0) {
			ViewState.Wallet = Wallets[0];
		}
		//else {
		//IsNeedInitData = true;
		//}
		List<Account_Plan_Completion__c> CompleteList = [SELECT ID, Name,
		                                                 Account_Plan_Company_Profile__c,
		                                                 Step_4_Percentage__c,
		                                                 Account_Plan_Completion_Percentage__c,
		                                                 Step_4_Entered_Fields__c,
		                                                 Step_4_Required_Fields__c
		                                                 FROM Account_Plan_Completion__c
		                                                 WHERE Account_Plan_Company_Profile__c = :ViewState.CompanyID LIMIT 1];
		if (CompleteList.size() > 0) {
			Acctplancompletion = CompleteList.get(0);
		}
		AcctPlanCompanyProfile__c companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(ViewState.CompanyID);
		isHasPermission = AccountPlanUtilities.ISHASPERMISSION;

		if (AccountPlanUtilities.OWNERSEGMENT != null) {
			isMiniView = AccountPlanUtilities.ISMINIVIEW;
		} else {
			isMiniView = false;
		}

		WarningPriorityEN  = Account_Plan_Status_Code__c.GetValues('4003').Status_Message__c;
		//WarningPriorityTH  = Account_Plan_Status_Code__c.GetValues('4004').Status_Message__c;
		WarningPriorityTH ='';
	    WarningAspirationSOW =  Account_Plan_Status_Code__c.GetValues('4002').Status_Message__c;
	}
	/**************************************************************
	 *  Alread Support SE
	 *************************************************************/
	public PageReference InitData() {

		system.debug('::::: Call InitData');
       AcctPlanCompanyProfile__c companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(ViewState.CompanyID);
		/* if(IsNeedInitData){            
		  initialWallet();
		  }   */
		//
		List<AcctPlanProdStrategy__c> acctPlanProdStrategies = AccountPlanProductStrategyService.getCompaniesProductStrategy(new Set<Id> { ViewState.CompanyID });
		system.debug('::: Product Strategy >> ' + acctPlanProdStrategies.size());

		if (acctPlanProdStrategies.size() == 0
		    && (	
                	AccountPlanUtilities.IsAccountTeamReadWrite  
                	||  
                	companyprofile.OwnerId == Userinfo.getUserId()// Add support only owner can make edit
			    )
		) {

			system.debug('::::::  Call Create Product Strategy 14 Item');


			try {
				// Create 14 Product Strategy
				system.debug('::: ViewState.GroupID  = ' + ViewState.GroupID);

				String groupId = ViewState.GroupID;
				if (ViewState.GroupID == null || ViewState.GroupID == '') {
					acctPlanProdStrategies =
					AccountPlanProductStrategyService.createProductStrategyRecordToWallet(
					                                                                      ViewState.CompanyID
					                                                                      , ViewState.WalletID);
				}
				else {
					acctPlanProdStrategies =
					AccountPlanProductStrategyService.createProductStrategyRecordToWallet(
					                                                                      ViewState.CompanyID
					                                                                      , ViewState.WalletID
					                                                                      , ViewState.GroupID);
				}
				system.debug('::: New Product Strategy >> ' + acctPlanProdStrategies);
				ViewState.PlanProdStrategies = acctPlanProdStrategies;

			}
			catch(Exception e)
			{
				ApexPages.addMessages(e);
			}
		}else if(
					AccountPlanUtilities.IsAccountTeamReadWrite  
                	||  
                	companyprofile.OwnerId == Userinfo.getUserId()// Add support only owner can make edit
			){


			//Account Plan 5.2 check AS free Products
			Double AsFeeRowNo;
			AcctPlanProdStrategy__c ASFeeStrategy;
			for(AcctPlanProdStrategy__c existingStrategy : acctPlanProdStrategies){
				if(existingStrategy.Name == '3.5 AS Fee'){
					AsFeeRowNo = existingStrategy.SEQ__c;
					ASFeeStrategy = existingStrategy;
				}

			}

			if(AsFeeRowNo !=null){

				List<AcctPlanWalletByDomain__c> AsFeeProductList =[SELECT  Id, Name, Domain__c, SubDomain__c, TypeOfNI__c, Opportunity__c, WalletFromCRMDB__c, 
													                      AdjWalletUnit__c, Priority__c, Reason__c, AcctPlanWallet__c, Seq__c, WalletFieldName__c,
													                      Row__c 
													                FROM AcctPlanWalletByDomain__c 
													                WHERE AcctPlanWallet__c =: ViewState.WalletID
													                AND Row__C =: AsFeeRowNo ];


																	Double adjustedWallet = 0;
													                if(AsFeeProductList.size() == 0){
													                	System.debug('new 5 ASFee product');
													                	
													                	List<AcctPlanWalletByDomain__c> newASFeeProduct = new List<AcctPlanWalletByDomain__c> ();
																				for (AccountPlanProductStrategyServiceImpl.WalletByDomainTemplate template 
																					: AccountPlanProductStrategyServiceImpl.getWalletByDomainTemplate) {
																					if(template.Row ==9){
																						system.debug(' Type Of NI >> ' + template.TypeOfNI + ' SubDomain >> ' + template.Domain);

																					Decimal val = 0;
																					if (template.WalletFieldName != null && template.WalletFieldName != '') {

																						if (template.WalletFieldName.contains(',')) {
																							for (String fieldName : template.WalletFieldName.split(',')) {
																								system.debug(' fieldName >> ' + fieldName);
																								val += (Decimal) (ViewState.Wallet.get(fieldName) == null ? 0 : ViewState.Wallet.get(fieldName));
																							}
																						}
																						else {
																							val += (Decimal) (ViewState.Wallet.get(template.WalletFieldName) == null ? 0 : ViewState.Wallet.get(template.WalletFieldName));
																						}
																						adjustedWallet +=val;

																					}
																					newASFeeProduct.add(
																					                       new AcctPlanWalletByDomain__c(
																					                                                     AcctPlanWallet__c = ViewState.WalletID
																					                                                     , Row__c = template.Row
																					                                                     , Seq__c = template.Seq
																					                                                     , TypeOfNI__c = template.TypeOfNI
																					                                                     , Domain__c = template.Domain
																					                                                     , SubDomain__c = template.SubDomain
																					                                                     , AdjWalletUnit__c = val
																					                                                     , WalletFieldName__c = template.WalletFieldName
																					                                                     , WalletDomain__c = template.WalletDomain

																					)
																					);
																					}
																				}

																			insert newASFeeProduct;
																			ASFeeStrategy.WalletSizing__c = adjustedWallet;
															                AsFeeStrategy.WalletFieldName__c = 'SumOfWalletASFee__c';

															                update ASFeeStrategy;

													                }

													                
			}



		}
		updateViewState();
		return null;
	}

	public void updateViewState() {

		System.debug('>>> CALL : ' + ViewState.CompanyID);

		initCssId();

		List<AcctPlanCompanyProfile__c> companies = AccountPlanCompanyProfileSelector.getCompanyProfileIds(new set<id> { ViewState.CompanyID });
		if (companies.size() > 0)
		{
			ViewState.AccountPlanCompanyProfile = companies[0];
		}

		ViewState.PlanProdStrategies = AccountPlanProductStrategyService.getCompaniesProductStrategy(New Set<Id> { ViewState.CompanyID });
		if (ViewState.PlanProdStrategies.size() > 0) {
			System.debug('::: ViewState.PlanProdStrategies = ' + ViewState.PlanProdStrategies.size());
			ViewState.TotalWallet = 0;
			ViewState.TotalAnnual = 0;
			ViewState.TotalAdjustedNI = 0;
			ViewState.TotalFeeAdjustedNI = 0;
			ViewState.TotalExpextedincrementalNI = 0;
			ViewState.WalletByDomains /*Map*/ = new Map<Decimal /*Seq*/, WalletSet> ();
			Decimal FeeAdjustedNI = 0;

			for (AcctPlanProdStrategy__c item : ViewState.PlanProdStrategies) {
				//  Must contail  12 item
				//  Seq == ProductStrategySection__c
				if (!ViewState.WalletByDomains.containsKey(item.SEQ__c)) {
					System.debug('>>> ADD KEY ' + item.SEQ__c);

					ViewState.WalletByDomains.put(item.SEQ__c, new WalletSet());
				}
				if (item.SEQ__c == 1.00 || item.SEQ__c == 2.00 || item.SEQ__c == 3.00  ) {
					ViewState.TotalWallet += item.WalletSizing__c == null ? 0 : item.WalletSizing__c;
					ViewState.TotalAnnual += item.AnnualizedPerformance__c == null ? 0 : item.AnnualizedPerformance__c;
					//  ViewState.TotalAdjustedNI +=   item.Adjust_NI__c   == null ? 0 : item.Adjust_NI__c;
				}
				if (item.SEQ__c != 3.00 && item.SEQ__c != 4.00 && item.SEQ__c != 10.0)
				{
					ViewState.TotalExpextedincrementalNI += item.ExpectedIncrementalNI__c == null ? 0 : item.ExpectedIncrementalNI__c;
				}


				if (item.SEQ__c != 1.00 && item.SEQ__c != 2.00 && item.SEQ__c != 3.00 && item.SEQ__c != 4.00 && item.SEQ__c != 10.00)
				{
					ViewState.TotalFeeAdjustedNI += item.Adjust_NI__c == null ? 0 : item.Adjust_NI__c;

				}
				if (item.SEQ__c == 1.00 || item.SEQ__c == 2.00) {

					ViewState.TotalAdjustedNI += item.Adjust_NI__c == null ? 0 : item.Adjust_NI__c;
				}


			}

			ViewState.TotalAdjustedNI += ViewState.TotalFeeAdjustedNI;

			for (AcctPlanWalletByDomain__c wallByDomain : AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(new Set<Id> { ViewState.WalletID })) {
				ViewState.WalletByDomains.get(wallByDomain.Row__c).add(wallByDomain);
			}

			List<AcctPlanCusUnderstanding__c> customerUderstandings = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(new Set<Id> { ViewState.WalletID });
			if (customerUderstandings.size() > 0) {
				ViewState.CustomerUnderstanding = customerUderstandings[0];

			} else {
				ViewState.CustomerUnderstanding = new AcctPlanCusUnderstanding__c();
			}


			RefreshAsOf = ViewState.PlanProdStrategies[0].RefreshAsOf__c;

			/*----- Start Mandatory Fields -----*/
			isWarningMandatoryFields = false;
			isWarningAspirationSOW_ExpectedIncrementalNI = false;
			isHasAspirationSOW_ExpectedIncrementalNI_ASFee = false;
			isWarningPriority = false;
			isWarningASFee = false;
			Boolean isWarningMandatoryInitFields = true;
			Boolean isWarningMandatoryCompareFields = false;
			Boolean isHasPriorityASFee = false;

			List<Boolean> isWarningMandatoryFieldsInitLists = new List<Boolean> ();
			List<Boolean> isWarningMandatoryFieldsLists = new List<Boolean> ();
			for (AcctPlanProdStrategy__c item : ViewState.PlanProdStrategies) {
				if (item.SEQ__c == 9 && (item.ExpectedIncrementalNI__c != 0 && item.ExpectedIncrementalNI__c != null)) {
					//isHasAspirationSOW_ExpectedIncrementalNI_ASFee = true;
					isHasAspirationSOW_ExpectedIncrementalNI_ASFee = false;
				}
			}
			//NOT Case 3.5 AS Fee
			Boolean isHasAspirationSOW_ExpectedIncrementalNI = false;
			Boolean isHasPriority = false;
			if (!isHasAspirationSOW_ExpectedIncrementalNI_ASFee) {
				for (AcctPlanProdStrategy__c item : ViewState.PlanProdStrategies) {
					
					//Check AspirationSOW and ExpectedIncrementalNI values
					system.debug('ViewState.AspirationSOW__c = ' + item.AspirationSOW__c);
					system.debug('ViewState.ExpectedIncrementalNI__c = ' + item.ExpectedIncrementalNI__c);
					system.debug('ViewState.SEQ__c = ' + item.SEQ__c);
					system.debug('ViewState.Name = ' + item.Name);
					System.debug('ViewStage.AdjustedNI = '+item.Adjust_NI__c);
					if ((item.SEQ__c != 3 && item.SEQ__c != 4 && item.SEQ__c != 10) && 
						(
							((item.SEQ__c != 9 && item.SEQ__c != 13 && item.SEQ__c != 14) && (item.AspirationSOW__c != 0 && item.AspirationSOW__c != null)) ||
							((item.SEQ__c == 9 || item.SEQ__c == 13 || item.SEQ__c == 14) && (item.ExpectedIncrementalNI__c != 0 && item.ExpectedIncrementalNI__c != null))
						)
						) {
						isHasAspirationSOW_ExpectedIncrementalNI = true;
					}
					if(item.SEQ__c == 3){
						item.Adjust_NI__c = ViewState.TotalFeeAdjustedNI;
					}
					system.debug('isHasAspirationSOW_ExpectedIncrementalNI = ' + isHasAspirationSOW_ExpectedIncrementalNI);
					system.debug('isHasAspirationSOW_ExpectedIncrementalNI_ASFee = ' + isHasAspirationSOW_ExpectedIncrementalNI_ASFee);
					//Check Priority values
					for (AcctPlanWalletByDomain__c itemwallet : ViewState.WalletByDomains.get(item.SEQ__c).Record) {
						system.debug('itemwallet.priority = ' + itemwallet.priority__c);
						if (itemwallet.Priority__c != null && itemwallet.Priority__c != '' && (itemwallet.Priority__c == 'Medium' || itemwallet.Priority__c == 'High')) {
							isHasPriority = true;
						}
					}
					system.debug('isHasPriority = ' + isHasPriority);
					system.debug('---------------------------------------------');

					if (!isHasAspirationSOW_ExpectedIncrementalNI_ASFee) {
						if (isHasAspirationSOW_ExpectedIncrementalNI == isHasPriority) {
							if (isHasPriority == false) {
								isWarningMandatoryFieldsInitLists.add(false);
							} else if (isHasPriority == true) {
								isWarningMandatoryFieldsInitLists.add(true);
							}
						}
						if (isHasAspirationSOW_ExpectedIncrementalNI == isHasPriority) {
							isWarningMandatoryFieldsLists.add(false);
						} else if (isHasAspirationSOW_ExpectedIncrementalNI != isHasPriority) {
							isWarningMandatoryFieldsLists.add(true);
							if (isHasPriority == true) {
								isWarningAspirationSOW_ExpectedIncrementalNI = true;
								isWarningPriority = false;
							} else if (isHasPriority == false) {
								isWarningAspirationSOW_ExpectedIncrementalNI = false;
								isWarningPriority = true;
							}
						}
					}
				}
				//Check Initial values
				Boolean isWarningMandatoryFieldsInit = false;
				for (Boolean item : isWarningMandatoryFieldsInitLists) {
					if (item == true) {
						isWarningMandatoryInitFields = false;
					}
				}
				for (Boolean item : isWarningMandatoryFieldsLists) {
					if (item == true) {
						isWarningMandatoryCompareFields = true;
					}
				}
				if (isWarningMandatoryInitFields || isWarningMandatoryCompareFields) {
					isWarningMandatoryFields = true;
				}
				if (isWarningMandatoryInitFields && !isWarningMandatoryCompareFields) {
					isWarningAspirationSOW_ExpectedIncrementalNI = true;
					isWarningPriority = true;
				}
			} else {
				for (AcctPlanProdStrategy__c itemProductStrategy : ViewState.PlanProdStrategies) {
					for (AcctPlanWalletByDomain__c itemwallet : ViewState.WalletByDomains.get(itemProductStrategy.SEQ__c).Record) {
						system.debug('AS Fee itemwallet.priority = ' + itemwallet.priority__c);
						if (itemwallet.Priority__c != null && itemwallet.Priority__c != '' && (itemwallet.Priority__c == 'Medium' || itemwallet.Priority__c == 'High')) {
							isHasPriorityASFee = true;
						}
					}
				}
				system.debug('isHasPriorityASFee = ' + isHasPriorityASFee);
				if (!isHasPriorityASFee) {
					isWarningMandatoryFields = true;
					isWarningAspirationSOW_ExpectedIncrementalNI = false;
					isWarningPriority = true;
				}
			}

			system.debug('isWarningMandatoryFields = ' + isWarningMandatoryFields);
			system.debug('isWarningAspirationSOW_ExpectedIncrementalNI = ' + isWarningAspirationSOW_ExpectedIncrementalNI);
			system.debug('isWarningPriority = ' + isWarningPriority);
			/*----- End Mandatory Fields -----*/

			//Original Condition
			isWarningAspirationSOW_ExpectedIncrementalNI = !isHasAspirationSOW_ExpectedIncrementalNI;
			isWarningPriority = !isHasPriority;

			if (!isWarningAspirationSOW_ExpectedIncrementalNI && !isWarningPriority) {
					isWarningMandatoryFields  = false;
			}else{
				isWarningMandatoryFields  = true ;
			}
			system.debug('isWarningMandatoryFields = ' + isWarningMandatoryFields);
			system.debug('isWarningAspirationSOW_ExpectedIncrementalNI = ' + isWarningAspirationSOW_ExpectedIncrementalNI);
			system.debug('isWarningPriority = ' + isWarningPriority);

		} else {
			//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You\'re not authorized to view Product Strategy until the Account Plan owner/authorized person has visited the Product Strategy'));
			
			//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Strategy has not been created by account owner. (Product Strategy ยังไม่ถูกสร้างโดยเจ้าของ Account Plan)'));
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, Account_Plan_Status_Code__c.GetValues('4001').Status_Message__c));
        }
	}

	//	private void initialWallet() {
	//
	//		AcctPlanWallet__c accWallet = new AcctPlanWallet__c();
	//		accWallet.AcctPlanCompanyProfile__c = ViewState.CompanyID;
	//		Insert accWallet;
	//		System.debug('New Wallet Id >> ' + accWallet.Id);
	//		AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(ViewState.CompanyID);
	//		if (isMiniView) {
	//			// If SE Segment 
	//			// This process must automate snap data from single view       
	//
	//		}
	//		ViewState.Wallet = accWallet;
	//	}

	public PageReference refresh() {
		system.debug('::: Refresh :::');
		try {



			//  if(isMiniView){
			/*  SE  */

			//  }
			//  else{
			// AccountPlanRefreshService.RefreshCompanyProfileProductStrategy(ViewState.CompanyID,ViewState.Wallet.Id);  
			AccountPlanRefreshService.RefreshProductStrategyAndWalletByDomain(ViewState.CompanyID, ViewState.Wallet.Id, ViewState.GroupID);
			//   } 
			updateViewState();
			initCssId();
		}
		catch(Exception e) {
			ApexPages.addMessages(e);
		}
		return null;
	}
	//region
	public PageReference cancel() {
		PageReference view = Page.AccountPlanProductStrategy;
		view.setRedirect(true);
		view.getParameters().put('GroupID', ViewState.GroupID);
		view.getParameters().put('CompanyID', ViewState.CompanyID);
		view.getParameters().put('WalletID', ViewState.walletID);
		if (mode != null && mode != '') {
			view.getParameters().put('mode', mode);
		}
		return view;
	}

	public PageReference EditPage() {
		PageReference edit = Page.AccountPlanProductStrategyEdit;
		edit.setRedirect(true);
		edit.getParameters().put('GroupID', ViewState.GroupID);
		edit.getParameters().put('CompanyID', ViewState.CompanyID);
		edit.getParameters().put('WalletID', ViewState.walletID);
		if (mode != null && mode != '') {
			edit.getParameters().put('mode', mode);
		}
		return edit;
	}
	//endregion

	public PageReference save() {

		try {

			//Enhanced for 3.Fee - AdjustedNI 
			AcctPlanProdStrategy__c FeeProdStrategy;
			ViewState.TotalFeeAdjustedNI  = 0;
			for (AcctPlanProdStrategy__c item : ViewState.PlanProdStrategies) {
				if (item.SEQ__c != 1.00 && item.SEQ__c != 2.00 && item.SEQ__c != 3.00 && item.SEQ__c != 4.00 && item.SEQ__c != 10.00)
				{
					ViewState.TotalFeeAdjustedNI += item.Adjust_NI__c == null ? 0 : item.Adjust_NI__c;

				}
				if(item.SEQ__c == 3.00){
					FeeProdStrategy = item;
				}
			}

			if(FeeProdStrategy !=null){
						FeeProdStrategy.Adjust_NI__c = ViewState.TotalFeeAdjustedNI == null ? 0 :ViewState.TotalFeeAdjustedNI;
			}			

			//Enhanced for 3.Fee - AdjustedNI
			update ViewState.PlanProdStrategies;

			List<AcctPlanWalletByDomain__c> updatewal = new List<AcctPlanWalletByDomain__c> ();
			for (Decimal key : ViewState.WalletByDomains.keyset()) {
				updatewal.addAll(ViewState.WalletByDomains.get(key).Record);
			}
			update updatewal;
			companyprofile.Status__c = 'In Progress';

			//start issue inactive step5-6
			System.debug('###UpdateComprofile inactive flag###'); 
                List<AcctPlanWalletByDomain__c> domainList = [SELECT Id FROM AcctPlanWalletByDomain__c
                                                      where AcctPlanWallet__c = :ViewState.WalletID];


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

			companyprofile.isHasProdStrategy__c = true;
			//end issue inactive step5-6
			
			update companyprofile;
			AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(ViewState.CompanyID);
		}
		catch(Exception e) {

			//  ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  


			return null;
		}


		PageReference view = Page.AccountPlanProductStrategy;
		view.setRedirect(true);
		view.getParameters().put('GroupID', ViewState.GroupID);
		view.getParameters().put('CompanyID', ViewState.CompanyID);
		view.getParameters().put('WalletID', ViewState.walletID);
		if (mode != null && mode != '') {
			view.getParameters().put('mode', mode);
		}
		return view;



	}



	public void initCssId() {
		ViewState.ToggleId.put(1.00, new List<string> { 'collapseNIIc', 'toggleNIIc' });
		ViewState.ToggleId.put(2.00, new List<string> { 'collapseNIId', 'toggleNIId' });

		ViewState.ToggleId.put(3.00, new List<string> { '', '' });
		ViewState.ToggleId.put(4.00, new List<string> { '', '' });

		ViewState.ToggleId.put(5.00, new List<string> { 'collapseTFFee', 'toggleTFFee' });
		ViewState.ToggleId.put(6.00, new List<string> { 'collapseFXFee', 'toggleFXFee' });
		ViewState.ToggleId.put(7.00, new List<string> { 'collapseLGFee', 'toggleLGFee' });
		ViewState.ToggleId.put(8.00, new List<string> { 'collapseCashFee', 'toggleCashFee' });

		ViewState.ToggleId.put(9.00, new List<string> { 'collapseASFee', 'toggleASFee' });
		ViewState.ToggleId.put(10.00, new List<string> { '', '' });

		ViewState.ToggleId.put(11.00, new List<string> { 'collapseCreditFee', 'toggleCreditFee' });
		ViewState.ToggleId.put(12.00, new List<string> { 'collapseBAFee', 'toggleBAFee' });
		ViewState.ToggleId.put(13.00, new List<string> { 'collapseDerivativeFee', 'toggleDerivativeFee' });
		ViewState.ToggleId.put(14.00, new List<string> { 'collapseIBFee', 'toggleIBFee' });

	}

	public class ViewState
	{
		public ViewState() {

			ToggleId = new Map<decimal, List<string>> ();
		}

		public AcctPlanCompanyProfile__c AccountPlanCompanyProfile { get; set; }

		//Account Navigation information
		public String CompanyID { get; set; }
		public String GroupID { get; set; }
		public String WalletID { get; set; }
		public Map<decimal, List<string>> ToggleId { get; set; }
		public AcctPlanCusUnderstanding__c CustomerUnderstanding { get; set; }
		//Calculateion Field

		public Decimal TotalWallet { get; set; }
		public Decimal TotalAnnual { get; set; }
		public Decimal TotalAdjustedNI { get; set; }
		public Decimal TotalExpextedincrementalNI { get; set; }


		public Decimal TotalFeeAdjustedNI { get; set; }


		public AcctPlanWallet__c Wallet { get; set; }

		public List<AcctPlanProdStrategy__c> PlanProdStrategies { get; set; }

		public Map<Decimal /*Seq*/, WalletSet> WalletByDomains { get; set; }

	}
	public class WalletSet {
		public integer Size { get { return Record.size(); } }
		public String CssId { get { return 'collapse_' + Seq; } }


		public String TypeOfNI { get; set; }
		public Decimal Seq { get; set; }
		public List<AcctPlanWalletByDomain__c> Record { get; set; }
		public WalletSet() {


			Record = new List<AcctPlanWalletByDomain__c> ();
		}
		public void add(AcctPlanWalletByDomain__c walletByDomain) {
			// Label
			TypeOfNI = walletByDomain.TypeOfNI__c;
			Record.add(walletByDomain);
			Seq = walletByDomain.Row__c;
		}
	}
}