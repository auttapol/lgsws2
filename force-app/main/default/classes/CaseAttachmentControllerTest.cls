@isTest
public class CaseAttachmentControllerTest {
	//public static final Id BB_ARM_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BB ARM Profile' LIMIT 1].Id;
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
        caseObj.Service_Type_Matrix_Code__c  = 'xxxx5'; 
        caseObj.Current_Service_Template__c = 'General';
        caseObj.AccountId = acct.id;
 
        insert caseObj;

        ECM_MS_Doctype__c ecmDoc = new ECM_MS_Doctype__c();
        ecmDoc.Archival_Period__c = 1;
        ecmDoc.Disposal_Period__c = 3;
		    ecmDoc.Expiry_Period__c = 10;
        ecmDoc.Channel__c = '05';
        ecmDoc.Source__c = 'A0291';
        ecmDoc.Type_Code__c = '20136';
        ecmDoc.Doc_Location__c = '/ECM/Customer Service Management/Customer Profile/Know Your Customer (KYC)';
        ecmDoc.Repository__c = 'ECMLOANDEV';
        ecmDoc.Doc_Template__c = 'RetailDocument';
        ecmDoc.Type_Name_TH__c = 'Test';
		    ecmDoc.Segment__c ='P';
		    ecmDoc.Document_Object__c = 'case';
        insert ecmDoc;
        
    }
	
	@isTest static void CaseAttachmentController() {

    Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());
    Test.startTest();
		List<Case> c = [SELECT Id FROM Case Limit 1];
    List<ECM_MS_Doctype__c> ecm = [SELECT Segment__c,Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c
                  ,Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c,Type_Name_TH__c
                  ,Source__c,Key__c FROM ECM_MS_Doctype__c];
                  system.debug(ecm[0]);

    ApexPages.StandardSetController sc = new ApexPages.StandardSetController(c);

    PageReference pageRef = Page.CaseAttachment;
      pageRef.getParameters().put('id', c[0].Id );
   
      Test.setCurrentPage(pageRef);

      CaseAttachmentController caseAttach = new CaseAttachmentController(sc);
      caseAttach.objCaseAttach.Name='Unit Test Attachment';
      caseAttach.objCaseAttach.body=Blob.valueOf('Unit Test Attachment Body');
      caseAttach.obContentType = 'application/pdf';

    	caseAttach.getDoc();
      caseAttach.upload();
      Test.stopTest();
	}
}