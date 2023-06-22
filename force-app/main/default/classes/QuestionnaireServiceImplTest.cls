@isTest
public class QuestionnaireServiceImplTest {

	static {
		List<AppConfig__c> mc = new List<AppConfig__c> ();
		mc.Add(new AppConfig__c(Name = 'CertName', Value__c = 'TMB_RSA'));
		mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
		insert mc;
		List<sObject> ls = Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
	}

	@isTest private static void initDataCaseFullNew() {

		// Init Data for testing

		Account acc = new Account(Name = 'TestAcct',Phone ='050111222',Mobile_Number_PE__c  = '0801112233');
		insert acc;
		/*****************************************************************
		 * 		STEP 1) Get default value
		 ******************************************************************/
		AcctPlanCompanyProfile__c companyProfile = new AcctPlanCompanyProfile__c();
		//companyProfile.Name = 'CP All Public Co., Ltd.';
		companyProfile.Account__c = acc.Id;
		insert companyProfile;
		// Make Wallet

		AcctPlanWallet__c wallet = new AcctPlanWallet__c();
		wallet.AcctPlanCompanyProfile__c = companyProfile.Id;
		insert wallet;


		// Make Questionair
		List<AcctPlanQuestionnaire__c> questionOfWallet = new List<AcctPlanQuestionnaire__c> ();
		List<AcctPlan_Questionnaire_Template__c> questionairTemplate = QuestionnaireSelector.SelectSelectQuestionairTemplate();
		for (AcctPlan_Questionnaire_Template__c item : questionairTemplate) {
			if (item.Answer_Field_Type__c == 'Yes or No' && item.Product_Label__c != null && item.Sub_Domain__c != null) {
				AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
				qt.AcctPlanWallet__c = wallet.Id;
				qt.Answer__c = 'Yes';
				qt.Opportunity__c = item.Opportunity__c;
				qt.Question__c = item.Question__c;
				qt.Question_TH__c = item.Question_TH__c;
				qt.Sub_Domain__c = item.Sub_Domain__c;
				qt.Product_Label__c = item.Product_Label__c;
				qt.Segment__c = item.Segment__c;
				questionOfWallet.add(qt);

				if (item.Segment__c == 'International bank section1' || item.Segment__c == 'International bank section2')
				{
					AcctPlanQuestionnaire__c qt1 = new AcctPlanQuestionnaire__c();
					qt1.AcctPlanWallet__c = wallet.Id;
					qt1.Answer__c = 'Yes';
					qt1.Opportunity__c = item.Opportunity__c;
					qt1.Question__c = item.Question__c;
					qt1.Question_TH__c = item.Question_TH__c;
					qt1.Sub_Domain__c = item.Sub_Domain__c;
					qt1.Product_Label__c = item.Product_Label__c;
					qt1.Segment__c = item.Segment__c;
					questionOfWallet.add(qt1);
					System.debug('::::::> Add Plus ' + qt1.Segment__c);
				}

				if (item.Segment__c == 'International bank section2')
				{
				    AcctPlanQuestionnaire__c qt2 = new AcctPlanQuestionnaire__c();
					qt2.AcctPlanWallet__c = wallet.Id;
					qt2.Answer__c = 'Yes';
					qt2.Opportunity__c = 'xxxx';
					qt2.Question__c = item.Question__c;
					qt2.Question_TH__c = item.Question_TH__c;
					qt2.Sub_Domain__c = item.Sub_Domain__c;
					qt2.Product_Label__c = item.Product_Label__c;
					qt2.Segment__c = item.Segment__c;
					questionOfWallet.add(qt2);
					System.debug('::::::> Add Plus ' + qt2.Segment__c);
				}
			}
		}




		List<AcctPlanOtherRevenueExpenditure__c> OtherRevenueExpenditures = new List<AcctPlanOtherRevenueExpenditure__c> ();
		//AcctPlanOtherRevenueExpenditure__c		
		OtherRevenueExpenditures.add(new AcctPlanOtherRevenueExpenditure__c(AcctPlanWallet__c = wallet.id, Opportunity__c = 'Forward or Derivative'));
		OtherRevenueExpenditures.add(new AcctPlanOtherRevenueExpenditure__c(AcctPlanWallet__c = wallet.id, Opportunity__c = 'FCD Account'));
		insert OtherRevenueExpenditures;

		for (AcctPlanOtherRevenueExpenditure__c item : OtherRevenueExpenditures) {
			string m_domain = 'Domain IV';
			string m_subdomain = 'Hedging';
			string m_product = 'Normal business transaction : Other revenue/ expenditure';
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
			qt.AcctPlanWallet__c = wallet.Id;
			qt.Answer__c = 'Yes';
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c = m_subdomain;
			qt.Product_Label__c = m_product;
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);
		}


		//AcctPlanExistingLongTermLoan__c        
		List<AcctPlanExistingLongTermLoan__c> ExistingLongTermLoans = new List<AcctPlanExistingLongTermLoan__c> ();
		// Case 1
		ExistingLongTermLoans.add(new AcctPlanExistingLongTermLoan__c(AcctPlanWallet__c = wallet.Id, CCYAmtFullyHedge__c = 'Yes'
		                                                              , InterestFullyHedge__c = 'No'
		                                                              , HedgingTenor__c = 'Full'
		                                                              , Opportunity__c = 'Forward/Derivative/ Option'));
		insert ExistingLongTermLoans;
		for (AcctPlanExistingLongTermLoan__c item : ExistingLongTermLoans) {
			string m_domain = 'Domain IV';
			string m_subdomain = 'Hedging';
			string m_product = 'Balance sheet management : Liability management';
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
			qt.AcctPlanWallet__c = wallet.Id;
			qt.Answer__c = 'Yes';
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c = m_subdomain;
			qt.Product_Label__c = m_product;
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);
		}




		//AcctPlanCapitalExpenditurePlan__c
		List<AcctPlanCapitalExpenditurePlan__c> CapitalExpenditurePlans = new List<AcctPlanCapitalExpenditurePlan__c> ();
		CapitalExpenditurePlans.add(new AcctPlanCapitalExpenditurePlan__c(AcctPlanWallet__c = wallet.Id
		                                                                  , OppForForeignCCY__c = 'Yes'
		                                                                  , MisMatchCCY__c = 'No'
		                                                                  , NeedToHedgeInterest__c = 'Yes'
		                                                                  , Opportunity__c = 'Derivative or IB'));

		insert CapitalExpenditurePlans;
		for (AcctPlanCapitalExpenditurePlan__c item : CapitalExpenditurePlans) {
			string m_domain = 'Domain IV';
			string m_subdomain = 'Hedging';
			string m_product = 'Balance sheet management : Investment & Capital expenditure plan';
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();

			qt.AcctPlanWallet__c = wallet.Id;
			qt.Answer__c = 'Yes';
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c = m_subdomain;
			qt.Product_Label__c = m_product;
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);
		}


		//AcctPlanCapitalExpenditurePlan__c

		//Make Currencu 


		Currency__c usd = new Currency__c(Name = 'USD', Full_Name__c = 'United States dollar', ShortName__c = 'USD', FlagForAcctPlan__c = true);

		insert usd;
		List<AcctPlanOtherRevenueExpenditure__c> OtherExpenditurePlans = new List<AcctPlanOtherRevenueExpenditure__c> ();
		OtherExpenditurePlans.add(new AcctPlanOtherRevenueExpenditure__c(AcctPlanWallet__c = wallet.Id, Currency__c = usd.Id, ExpectedAmountOrHistoricalAmount__c = 10000.0, HedgingPolicy__c = 'Forward', RevenueOrExpenditure__c = 'Royaltee fee'));

		insert OtherExpenditurePlans;
		for (AcctPlanOtherRevenueExpenditure__c item : OtherExpenditurePlans) {
			string m_domain = 'Domain IV';
			string m_subdomain = 'Hedging';
			string m_product = 'Normal business transaction : Other revenue/ expenditure';
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();

			qt.AcctPlanWallet__c = wallet.Id;
			qt.Answer__c = 'Yes';
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c = m_subdomain;
			qt.Product_Label__c = m_product;
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);
		}

		insert questionOfWallet;
		// Start testing 
		//QuestionnaireServiceImpl serviceImpl = new QuestionnaireServiceImpl();		
		List<QuestionnaireService.BusinessOppInfo> ret = QuestionnaireService.getQuestionairByWalletId(wallet.Id);
		for (QuestionnaireService.BusinessOppInfo item : ret)
		{
			for (QuestionnaireService.BusinessOppInfoSector item2 : item.Values)
			{
				for (QuestionnaireService.ProductLable item3 : item2.Values)
				{
					string txt = item3.getText;
				}
			}
		}
	}
}