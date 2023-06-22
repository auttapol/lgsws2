@isTest
public class QuickCaseControllerTest {
	@testSetup static void initData(){
		TestUtils.createAppConfig();
		Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center'];
        
  		Case caseObj = New Case(); 
        caseObj.recordtypeID = SErecordType.id;
        caseObj.Subject = 'TestCase';
        caseObj.PTA_Segment__c = 'SBG';
        caseObj.Category__c = 'Service Level1';
        caseObj.Sub_Category__c = 'Service level2';
        caseObj.Product_Category__c = 'Service level3';
        caseObj.Issue__c = 'Service level4';
        caseObj.Status = 'New';
        caseObj.Description = 'Test create Case';
        caseObj.Contact_Person_Name__c='test1';
        caseObj.Root_Cause_List__c = 'Other';
        caseObj.Root_Cause__c = 'test';
        caseObj.Resolution_LIst__c = 'Other';
        caseObj.Resolution__c =  'test';
        caseObj.Service_Type_Matrix_Code__c = 'xxxx5';
        caseObj.Current_Service_Template__c = 'General';
        insert caseObj;
        
        //Create Service Type matrix
        Service_Type_Matrix__c SeMatrix = New Service_Type_Matrix__c();
        SeMatrix.Segment__c = 'SBG';
        SeMatrix.Service_Level1__c = 'Service Level1';
        SeMatrix.Service_Level2__c = 'Service level2';
        SeMatrix.Service_Level3__c = 'Service level3';
        SeMatrix.Service_Level4__c = 'Service level4';
        SeMatrix.SLA__c = 7;
        SeMatrix.Severity__c = '1';
        SeMatrix.Responsible_BU__c = 'Test Queue SE';
        SeMatrix.Problem_Type__c = 'Test Problem Type';
        SeMatrix.Journey__c = 'Test Jorney';
        SeMatrix.active__c = true;
        SeMatrix.Closed_By_BU__c = 'Test Queue SE';
        SeMatrix.Validate_Code__c = 'xxxx5';
        // [2020-03-26] Case Select Template.
        SeMatrix.Service_Template__c = 'CreditService';
        insert SeMatrix;

		Quick_case__c qc = new Quick_case__c();
			
			qc.Active__c =true;
			qc.Service_Type_Code__c = 'xxxx5';
			qc.Subject__c = 'TMB Touch';
			qc.Segment__c = 'RBG';
			qc.Category__c = 'Complaint';
			qc.Problem_Channel__c = 'TMB Touch';
			qc.Product_Service__c = 'Savings&Deposits';
			qc.Issue__c = 'ไม่สามารถ log in ได้';
			qc.Problem_Type__c = 'Failure - ไม่ได้รับบริการในสิ่งที่ลูกค้าต้องการ';
			qc.Journey__c = 'After Used';
			qc.Quick_Issue__c = 'TMB Touch';
		insert qc;
    }
	
	@isTest static void QuickCaseController() {
		List<Case> c = [SELECT Id FROM Case Limit 1];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(c);
        QuickCaseController qcc = new QuickCaseController(sc);   
		qcc.getCaseList();
		qcc.save();

	}
}