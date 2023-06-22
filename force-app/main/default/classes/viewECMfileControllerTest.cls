@isTest
public class viewECMfileControllerTest {
    static void initData(){
		TestUtils.createAppConfig();
        TestUtils.createSMSNotiHandler();
		

        List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'ECM_Endpoint';
        Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
        apps.add(Aconfig);

        insert apps;

        List<Account> newAccountList = new List<Account>(); 
            Account Acct = new Account(); 
            Acct.Name = 'Test Account CUS';
            Acct.ID_Type_PE__c  = 'Passport ID';
            Acct.ID_Number_PE__c  = '15101';
            Acct.Office_Address_Line_1_PE__c  = 'Address1';
            Acct.Office_Address_Line_2_PE__c  = 'Address2';
            Acct.Office_Address_Line_3_PE__c  = 'Address3';
            Acct.Primary_Address_Line_1_PE__c  = 'Primary Address1';
            Acct.Primary_Address_Line_2_PE__c  = 'Primary Address2';
            Acct.Primary_Address_Line_3_PE__c  = 'Primary Address3';
            Acct.Province_Primary_PE__c  = 'Chiang Mai';
            Acct.Zip_Code_Primary_PE__c  = '50000';
            Acct.Zip_Code_Office_PE__c   = '1001';
            Acct.Customer_Type__c = 'CType';
            Acct.First_name_PE__c  = 'Fname';
            Acct.First_Name_ENG_PE__c = 'Fname';
            Acct.Last_name_PE__c  = 'TestMock';
            Acct.Last_Name_PE_Eng__c   = 'TestMock';
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            Acct.OwnerId = UserInfo.getUserid();
            Acct.Owner_name_ID__c = 'test1';
            Acct.Account_Plan_Flag__c = 'Yes';
        newAccountList.add(acct);
 
        insert newAccountList;

        
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
        caseObj.AccountId = newAccountList[0].id;
        caseObj.Service_Type_Matrix_Code__c = 'xxxx1';
        caseObj.Current_Service_Template__c = 'General';
        insert caseObj;

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

        ECM_Repository__c ecmRepo = new ECM_Repository__c();
        ecmRepo.Case__c = caseObj.Id;
        ecmRepo.File_Link__c = 'www.Test.com';
        ecmRepo.ECM_Uploaded_Date_Time__c = DateTime.Now();
        ecmRepo.Repository__c = 'ECMWBGDEV';
        ecmRepo.Uploaded_By__c = UserInfo.getUserid();
        ecmRepo.Object_ID__c = 'idd_test';
		insert ecmRepo;

    }
    @isTest static void getStream() {
        initData();
        Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());
        Test.startTest();
        PageReference pageRef = Page.viewECMfile;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('obId', 'idd_test');
        viewECMfileController controller = new viewECMfileController();

        controller.getStream();
        Test.stopTest();
        
	}

    

    @isTest static void getStream2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User uThai = new User(Alias = 'standt', Email='standarduser@tmbbank.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='th_TH', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', Username= System.now().millisecond() + 'p***n.tmb**@***.com');
        insert uThai;
        TestUtils.createAppConfig();
        TestUtils.createSMSNotiHandler();

        System.runAs(uThai){
            List<AppConfig__c> apps = new  List<AppConfig__c>();
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'ECM_Endpoint';
            Aconfig.Value__c = 'https://sfmashupservices.tmbbank.com/common/ecm/vit/ObjectService?wsdl';        
            apps.add(Aconfig);
            insert apps;

            List<Account> newAccountList = new List<Account>(); 
            Account Acct = new Account(); 
            Acct.Name = 'Test Account CUS';
            Acct.ID_Type_PE__c  = 'Passport ID';
            Acct.ID_Number_PE__c  = '15101';
            Acct.Office_Address_Line_1_PE__c  = 'Address1';
            Acct.Office_Address_Line_2_PE__c  = 'Address2';
            Acct.Office_Address_Line_3_PE__c  = 'Address3';
            Acct.Primary_Address_Line_1_PE__c  = 'Primary Address1';
            Acct.Primary_Address_Line_2_PE__c  = 'Primary Address2';
            Acct.Primary_Address_Line_3_PE__c  = 'Primary Address3';
            Acct.Province_Primary_PE__c  = 'Chiang Mai';
            Acct.Zip_Code_Primary_PE__c  = '50000';
            Acct.Zip_Code_Office_PE__c   = '1001';
            Acct.Customer_Type__c = 'CType';
            Acct.First_name_PE__c  = 'Fname';
            Acct.First_Name_ENG_PE__c = 'Fname';
            Acct.Last_name_PE__c  = 'TestMock';
            Acct.Last_Name_PE_Eng__c   = 'TestMock';
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            Acct.OwnerId = UserInfo.getUserid();
            Acct.Owner_name_ID__c = 'test1';
            Acct.Account_Plan_Flag__c = 'Yes';
            newAccountList.add(acct);
 
            insert newAccountList;

        
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
            caseObj.AccountId = newAccountList[0].id;
            caseObj.Service_Type_Matrix_Code__c = 'xxxx1';
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

        Test.setMock(WebServiceMock.class, new wsapiEcmCaseAttachmentMock());
        Test.startTest();
        PageReference pageRef = Page.viewECMfile;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('obId', 'idd_test');
        viewECMfileController controller = new viewECMfileController();
        controller.getStream();
        Test.stopTest();

        
        
        
    }
    
}