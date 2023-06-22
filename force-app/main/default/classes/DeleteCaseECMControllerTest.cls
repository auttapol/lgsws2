@isTest
public class DeleteCaseECMControllerTest {
	@testSetup static void initData(){

		TestUtils.createAppConfig();

    	List<AppConfig__c> apps = new  List<AppConfig__c>();
    	AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'ECM_Endpoint';
        Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
        apps.add(Aconfig);

        insert apps;

		Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center'];

        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = 'test' + ' ' + 'testL';
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.OwnerId = UserInfo.getUserId();
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';                
        insert acct;

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
        caseObj.AccountId = acct.id;
        caseObj.Service_Type_Matrix_Code__c = 'xxxx5';
        caseObj.Current_Service_Template__c = 'General';
 
        insert caseObj;

        ECM_Repository__c ecmRepo = new ECM_Repository__c();
        ecmRepo.Case__c = caseObj.Id;
        ecmRepo.File_Link__c = 'www.Test.com';
        ecmRepo.ECM_Uploaded_Date_Time__c = DateTime.Now();
        ecmRepo.Repository__c = 'ECMWBGDEV';
        ecmRepo.Uploaded_By__c = UserInfo.getUserid();
        ecmRepo.Object_ID__c = 'idd_test';
		insert ecmRepo;
        
    }

    @isTest static void CaseAttachmentController() {

	    Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());
	    Test.startTest();
		
		ECM_Repository__c c = [SELECT Id FROM ECM_Repository__c];
	    ApexPages.StandardController sc = new ApexPages.StandardController(c);
	    PageReference pageRef = Page.DeleteCaseECM;
	    pageRef.getParameters().put('id', c.Id );
	    Test.setCurrentPage(pageRef);
	    DeleteCaseECMController caseDelete = new DeleteCaseECMController(sc);
	    caseDelete.deleteECM();
        caseDelete.redirect();
	    Test.stopTest();
	}

}