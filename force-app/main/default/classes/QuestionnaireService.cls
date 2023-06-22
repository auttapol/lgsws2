global class QuestionnaireService {

	@TestVisible
	private static IQuestionnaireService mock;

	@TestVisible
	private static void setMockservice(IQuestionnaireService mockService) {
		mock = mockService;
	}

	// Factory
	@TestVisible
	private static IQuestionnaireService service() {
		if (Test.isRunningTest() && mock != null) return mock;
		return(IQuestionnaireService) new QuestionnaireServiceImpl();
	}


	global static List<BusinessOppInfo> getQuestionairByWalletId(Id walletId) {
		return service().GetQuestionairByWalletId(walletId);
	}
	/********************************************
	 *    DTO Object
	 *********************************************/
	global class BusinessOppInfo {
		public BusinessOppInfo(string name) {
			this.Domain = name;
			Sectors = new Map<string, BusinessOppInfoSector> ();
		}
		public string Domain { get; set; } /*Ex. Domain I: Transactional Banking*/

		public List<BusinessOppInfoSector> Values {
			get { return Sectors.values(); }
		}



		public Map<string, BusinessOppInfoSector> Sectors { get; set; }
	}
	global class BusinessOppInfoSector {
		public BusinessOppInfoSector(string subDomain) {
			this.SubDomain = subDomain;
			this.ProductLable = new Map<string, ProductLable> ();
		}
		public string SubDomain { get; set; } /*Ex .Domestic */

		public List<ProductLable> Values {
			get { return ProductLable.values(); }
		}

		public Map<string, ProductLable> ProductLable { get; set; }
	}
	global class ProductLable {
		public ProductLable(string label, string subDomain) {
			this.SubDomain = subDomain;
			this.Label = label;
			if (subDomain == 'International' && label == 'Collection')
			{
				System.debug(':::  HIT Change Label');
				this.Label = 'Export';
			}
			this.Questionnaires = new List<AcctPlanQuestionnaire__c> ();
		}
		public string SubDomain { get; set; }
		public string Label { get; set; } /*Ex .Domestic */
		public List<AcctPlanQuestionnaire__c> Questionnaires { get; set; }
		public String getText {
			get {
				return ToText();
			}
		}


		public string ToText() {
			Map<string, string> checkdupp = new Map<string, string> ();
			//suport special case
			integer countInternationalbanksection1 = 0;
			integer countInternationalbanksection2 = 0;
			boolean isfirst = true;
			string val = '';
			for (AcctPlanQuestionnaire__c item : Questionnaires) {
				if (item.Segment__c == 'International bank section1') countInternationalbanksection1++;
				if (item.Segment__c == 'International bank section2') countInternationalbanksection2++;
				if (item.Opportunity__c != null && item.Opportunity__c != '') {
					if (!checkdupp.containsKey(item.Opportunity__c)) {
						checkdupp.put(item.Opportunity__c, item.Opportunity__c);
						if (countInternationalbanksection1 == 2) {
							System.debug('::: >>>> countInternationalbanksection1 >>>>>>');
							if (isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								isfirst = false;
								val += item.Opportunity__c;
							}
							else if (!isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								val += ',<br />' + item.Opportunity__c;
							}
						}
						else if (countInternationalbanksection2 == 2) {
							System.debug('::: >>>> countInternationalbanksection2 >>>>>>');
							if (isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								isfirst = false;
								val += item.Opportunity__c;
							}
							else if (!isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								val += ',<br />' + item.Opportunity__c;
							}
						}
						else {
							if (isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								isfirst = false;
								val += item.Opportunity__c;
							}
							else if (!isfirst && (item.Opportunity__c != null && item.Opportunity__c != '')) {
								val += ',<br />' + item.Opportunity__c;
							}
						}
					}
				}
			}
			return val;
		}
	}
}