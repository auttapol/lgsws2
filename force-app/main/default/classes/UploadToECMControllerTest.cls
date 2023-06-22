@isTest
public class UploadToECMControllerTest {
    @testSetup static void initData(){
		TestUtils.createAppConfig();
		
        List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'ECM_Endpoint';
        Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
        apps.add(Aconfig);

        insert apps;

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
		ecmDoc.Segment__c ='C';
		ecmDoc.Document_Object__c = 'case';
        insert ecmDoc;

        
    }
    @isTest static void UploadToECMControllerTest() {
        Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());

        Test.startTest();
        UploadToECMController upECM = new UploadToECMController();
		List<ECM_MS_Doctype__c> ecm = [SELECT Segment__c,Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c
									,Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c
									,Source__c,Key__c FROM ECM_MS_Doctype__c LIMIT 1];

        string repositoryId=ecm[0].Repository__c;
  	
        wsapiEcmClevelCom.dmsPropertiesType properties;
        string folderId;
        string folderPath;

        wsapiEcmClevelCom.dmsContentStreamType contentStream = new wsapiEcmClevelCom.dmsContentStreamType();
        contentStream.stream = 'TEST';
    	upECM.createDocInECM(repositoryId, properties, folderId, folderPath, contentStream);
        //upECM.deleteInECM(repositoryId,'idd_1102E18C-B583-4104-BF68-2DCC2F52DA45');
        upECM.deleteInECM(repositoryId,'');
        upECM.viewInECM(repositoryId,'');
        Test.stopTest();
	}
}