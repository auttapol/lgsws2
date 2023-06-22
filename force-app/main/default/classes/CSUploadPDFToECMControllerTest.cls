@isTest

    private class CSUploadPDFToECMControllerTest {
	
	@testSetup static void setup() {
		// Implement test code
		AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

		Account acc = CSTestUtils.createAccounts(1,false).get(0);
		acc.Murex_Counter_Label__c = 'eclient';
		insert acc;

		List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);

		ECM_Key__mdt appConMeta_DocKey = [SELECT Id, Label, Key__c FROM ECM_Key__mdt WHERE Label = 'Eclient Doc Key'];
		
        ECM_MS_Doctype__c ecmDoc = new ECM_MS_Doctype__c();
        ecmDoc.Archival_Period__c = 1;
        ecmDoc.Disposal_Period__c = 3;
		ecmDoc.Expiry_Period__c = 10;
        ecmDoc.Channel__c = '05';
        ecmDoc.Source__c = 'A0291';
        ecmDoc.Type_Code__c = '20136';
        ecmDoc.Doc_Location__c = '/ECM/Customer Service Management/Customer Profile/Know Your Customer (KYC)';
        ecmDoc.Repository__c = 'ECMWBGDEV';
        ecmDoc.Doc_Template__c = 'CommercialDocument';
		ecmDoc.Key__c = appConMeta_DocKey.Key__c;
        insert ecmDoc;

		List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'ECM_Endpoint';
        Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
        apps.add(Aconfig);

        insert apps;

	}
	
	@isTest static void getEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSUploadPDFToECMController.getEclient(ec[0].Id);
	}

    @isTest static void getOnlineLog() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSUploadPDFToECMController.getOnlineLog(ec[0].Id);
	}
	
	@isTest static void getApexJob() {
		// Implement test code
		CSUploadPDFToECMController.getApexJob();
	}
	
    @isTest static void saveFile() {
		// Implement test code
    
        
        String fileName = 'TestPDF';
        String base64Data = 'encrypt';
        String contentType = 'application/pdf';
        List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSUploadPDFToECMController.saveFile(fileName, base64Data, contentType , ec[0].Id);
	}

    @isTest static void insertPropString() {
		// Implement test code
        ECM_MS_Doctype__c ecm = [SELECT Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c,
		Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c,Source__c FROM ECM_MS_Doctype__c Where Type_Code__c =: '20136'];

		CSUploadPDFToECMController.insertPropString('TMB_DOC_SUBMIT_CHANNEL',ecm.Channel__c);
	}
    @isTest static void insertPropDatetime() {
		// Implement test code
		CSUploadPDFToECMController.insertPropDatetime('TMB_DOC_IMPORT_DATETIME',DateTime.Now());
	}

    @isTest static void saveToOnlineLog() {
		// Implement test code
        List<E_Client_Suitability__c> ec = [SELECT Id,Name,CS_Murex_ID__c,CS_Customer__c,CS_Customer__r.TMB_Customer_ID_PE__c FROM E_Client_Suitability__c Limit 1];

        Datetime startTime = DateTime.Now();	
        String errorMessage = '';
        Boolean isSuccess = false;
        String customerName = ec[0].Name;
        String msLogId = 'appId';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = ec[0].CS_Customer__r.TMB_Customer_ID_PE__c;
        String serviceName = 'ECM-getContent';
        String requestBody = '';
        String responseBody = '';
        Account acc = null;
        Datetime endTime = DateTime.Now();
        String base64Data = 'encrypt';

		OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessage, msLogId , userName, 
		rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data);
	}

    @isTest static void ecmTimeOut() {
		// Implement test code
		CSUploadPDFToECMController.ecmTimeOut();
	}

	@isTest static void getCurrentUser() {
		// Implement test code
		CSUploadPDFToECMController.getCurrentUser();
	}
}