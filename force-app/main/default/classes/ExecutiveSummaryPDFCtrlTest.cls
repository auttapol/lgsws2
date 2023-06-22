/**********************************************************************
* Project           : Account Plan 5.2
* Author            : Jittramas Kumpeepong / jtk@ii.co.th
* Date created      : 2016-12-07
/**********************************************************************/
@isTest
public class ExecutiveSummaryPDFCtrlTest {
    static {
        AccountPlanTestUtilities.AccountPlanStatusCode();
        //Account_Plan_Status_Code__c statuscode7001 = new Account_Plan_Status_Code__c(Name='7001',Status_Message__c='test7001');
        //insert statuscode7001;
    }

    public static testMethod void test(){
    	Account acct = ExecutiveSummaryCtrlTest.createAccountwithAcctplan();
		List<AcctPlanCompanyProfile__c> compro = ExecutiveSummaryCtrlTest.createComProfilewithAcct(acct.Id);
		List<Executive_Summary__c> exec = ExecutiveSummaryCtrlTest.createExecutiveSummary(1,acct.Id,compro.get(0).Id);
		List<Attachment> att = new List<Attachment>([SELECT Id FROM Attachment WHERE ParentId =: exec.get(0).Id]);
		    	
		Test.startTest();
    	ApexPages.StandardController sc = new ApexPages.StandardController(exec.get(0));
    	ExecutiveSummaryPDFCtrl execPDF = new ExecutiveSummaryPDFCtrl(sc);
    	PageReference pg = execPDF.SavePDF();

    	Test.stopTest();
	}
}