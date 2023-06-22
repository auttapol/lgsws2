@isTest
public class QuestionnaireServiceTest {
	@isTest private static void codeCoverage() {
		II_TestUtility utility = new II_TestUtility();
		QuestionnaireService.setMockservice(new MockService());
		QuestionnaireService.getQuestionairByWalletId(utility.getFakeId(AcctPlanWallet__c.SObjectType));
	}

	public class MockService implements IQuestionnaireService {
		public List<QuestionnaireService.BusinessOppInfo> GetQuestionairByWalletId(Id walletId) {
			return null;
		}
	}
}