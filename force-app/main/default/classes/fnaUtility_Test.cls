@isTest
public without sharing class fnaUtility_Test {

    @isTest
    private static void Test_getprojectFin() {
        List<Project__c> listProject = new List<Project__c>();
        Project__c project = new Project__c();
        project.name = 'Fin Avatar';
        listProject.add(project);
        insert listProject;

        fnaUtility.getprojectFin();
    }

    @isTest
    private static void Test_getImageUrl() {
        // ContentVersion
        Map<String, String> titleImage = new Map<String, String>();
        titleImage.put('test','test');

        fnaUtility.getImageUrl(titleImage);
    }

    @isTest
    private static void Test_getListContentVersion() {
        String libraryName = 'test';
        String folderName = 'test';
        String titleName = 'test';
            
        fnaUtility.getListContentVersion(libraryName,folderName,titleName);
    }

    @isTest
    private static void Test_sendSMS() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.phone__c = '0123456789';
        fnaActivity.Send_SMS_Details__c = '{"{}":{"service_code":"test","office_code":"test","success":""}}';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        FNA_Activity__c fnaForm = listFnaAct[0];
        String serviceName = 'test';
        fnaUtility.sendSMS(fnaForm, serviceName);
        // mock App_Config__mdt
    }

    @isTest
    private static void Test_sendSMSURL() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaUtility.sendSMSURL(fnaId);
    }


    @isTest
    private static void Test_meargeSmallAvatarTitle() {
        String segment = 'test';
        String gender = 'ชาย';
        fnaUtility.meargeSmallAvatarTitle(segment, gender);
    }

    @isTest
    private static void Test_createLead() {
        TestUtils.createAppConfig();
        TestUtils.createAppConfig_Trigger();
        
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Person_Name__c = 'PersonName';
        fnaActivity.phone__c = '0123456789';
        // fnaActivity.Avatar_Name__c = 'AvatarName';
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q13';
        listQuestion.add(question);
        insert listQuestion;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        questionnaireResults.Choice_Answer__c = 'B';
        listQuestionnaireResults.add(questionnaireResults);
        insert listQuestionnaireResults;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        // productOffering.Flag_Offset_product_holding__c = false;
        // productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        // productOffering.FNA_Activity__c = listFnaAct[0].Id;
        // productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);

        ContentVersion cv=new Contentversion();
        cv.title='Test_female';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('This is version data');
        insert cv;

        //RTL_Referral__c ref = listRTLRef[0];
        List<FNA_Activity__c> fnaActList = [SELECT Id, Avatar_Name__c, Avatar_Downloaded__c, Phone__c, Person_Name__c, Avatar_Master__r.Avatar_Segment__c, 
                                            Avatar_Master__r.Segment__c, Customer__c, CreatedDate, Product_Holding__c,
                                            (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                            (SELECT id, name, FNA_Activity__c FROM Leads__r)
                                            FROM FNA_Activity__c WHERE Person_Name__c = 'PersonName'];
        
        Id recordTypeLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        
        fnaUtility.createLead(fnaActList[0], recordTypeLead, new RTL_Referral__c(), listProductOffering);

        //Trigger for you : RTL_ReferralTrigger
    }

    @isTest
    private static void Test_splitProductOffering() {
        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        // productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering.Flag_Interested_Product__c = true;
        // productOffering.FNA_Activity__c = listFnaAct[0].Id;
        productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        fnaUtility.splitProductOffering(listProductOffering);
    }

    @isTest
    private static void Test_stampFieldExisting() {
        List<AppConfig__c> listAconfig = new List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        listAconfig.add(Aconfig);

        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'DefaultOwner';
        Aconfig2.Value__c = '99999';
        listAconfig.add(Aconfig2);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'FilterRetailSegment';
        Aconfig3.Value__c = '5|6|7|8|9';
        listAconfig.add(Aconfig3);
        insert listAconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.phone__c = '0800000000';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q13';
        listQuestion.add(question);
        insert listQuestion;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        questionnaireResults.Choice_Answer__c = 'B';
        questionnaireResults.answer__c = 'กู้หรือ รีไฟแนนซ์ เพื่อซื้อบ้าน รถ หรือ ขยายธุรกิจ;ลงทุนหรือ ออม ระยะปานกลาง-ยาว หรือเพื่อประหยัดภาษี;';
        listQuestionnaireResults.add(questionnaireResults);
        insert listQuestionnaireResults;
        
        List<FNA_Activity__c> fnaActList = [SELECT Id, Avatar_Name__c, Avatar_Downloaded__c, Phone__c, Person_Name__c, Avatar_Master__r.Avatar_Segment__c, 
                                            Avatar_Master__r.Segment__c, Customer__c, CreatedDate, Product_Holding__c,
                                            (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                            (SELECT id, name, FNA_Activity__c FROM Leads__r)
                                            FROM FNA_Activity__c WHERE Phone__c = '0800000000'];

        fnaUtility.stampFieldExisting(fnaActList[0],listAccount[0]);

        //Account Trigger 
    }

    @isTest
    private static void Test_updateProductofLead() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      	User u2 = new User(Alias = 'newUser', Email='newuserforTestClass@testorg.com',
       	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuserforTestClass@testorg.com');

      	System.runAs(u2) {
            List<AppConfig__c> listAconfig = new List<AppConfig__c>();
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'runtrigger';
            Aconfig.Value__c = 'true';
            listAconfig.add(Aconfig);
            insert listAconfig;
    
            List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
            FNA_Activity__c fnaActivity = new FNA_Activity__c();
            listFnaAct.add(fnaActivity);
            insert listFnaAct;
    
            List<Lead> listLead = new List<Lead>();
            Lead lead = new Lead();
            lead.LastName = 'test';
            lead.Company = 'test';
            lead.FNA_Activity__c = listFnaAct[0].Id;
            listLead.add(lead);
            insert listLead;
    
            String fnaId = listFnaAct[0].Id;
            fnaUtility.updateProductofLead(fnaId);
        }
    }

    @isTest
    private static void Test_FnaCheckExisting() {
        
        AppConfig__c app = new AppConfig__c();
        app.name = 'runtrigger';
        app.Value__c = 'false';
        insert app;
        
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Phone__c = '0123456789';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaUtility.FnaCheckExisting(fnaId);
    }


    @isTest
    private static void Test_FnaCheckExistingNonEncrypt() {
        
        AppConfig__c app = new AppConfig__c();
        app.name = 'runtrigger';
        app.Value__c = 'false';
        insert app;
        
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Phone__c = '0123456789';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaId = listFnaAct[0].Id;
        fnaUtility.FnaCheckExistingNonEncrypt(fnaId);
    }

    @isTest
    private static void Test_successDownload() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaUtility.successDownload(fnaId);
    }

    @isTest
    private static void Test_checkBusinessHour() {

        List<BusinessHours> bhsList = [SELECT id, name FROM BusinessHours WHERE IsDefault=true];
        if(bhsList.size() > 0){
            Datetime targetTime = Datetime.now();
        	fnaUtility.checkBusinessHour(bhsList[0].name, targetTime);
            fnaUtility.checkBusinessHourTF(bhsList[0].name, targetTime);
        }
        
    }


    @isTest
    private static void Test_checkCustomerId() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='fnastandardusertest@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='fnastandardusertest@testorg.com');
        insert u;

        String cusId = listAccount[0].Id;
        String branchCode = '9999';
        String branchAgentId = u.Id;
        fnaUtility.checkCustomerId(cusId, branchCode, branchAgentId);
    }

    @isTest
    private static void Test_getListContentVersionAll() {

        String libraryName = '';
        String folderName = '';
        List<String> titleName = new List<String>();
        String title = 'Penguins';
        titleName.add(title);
        fnaUtility.getListContentVersionAll(libraryName,folderName,titleName);
    }

    @isTest
    private static void Test_getAvatarImage() {
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Phone__c = '0800000000';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q13';
        listQuestion.add(question);
        insert listQuestion;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        questionnaireResults.Choice_Answer__c = 'B';
        questionnaireResults.answer__c = 'กู้หรือ รีไฟแนนซ์ เพื่อซื้อบ้าน รถ หรือ ขยายธุรกิจ;ลงทุนหรือ ออม ระยะปานกลาง-ยาว หรือเพื่อประหยัดภาษี;';
        listQuestionnaireResults.add(questionnaireResults);
        insert listQuestionnaireResults;

        /*ContentVersion contentVersion = new ContentVersion(
        Title = 'TEST_female',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion; */
		List<FNA_Activity__c> fnaActList = [SELECT Id, Avatar_Name__c, Avatar_Downloaded__c, Phone__c, Person_Name__c, Avatar_Master__r.Avatar_Segment__c, 
                                            Avatar_Master__r.Segment__c, Customer__c, CreatedDate, Product_Holding__c,
                                            (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                            (SELECT id, name, FNA_Activity__c FROM Leads__r)
                                            FROM FNA_Activity__c WHERE Phone__c = '0800000000'];
        system.debug('fnaObj.Avatar_Master__r.Segment__c ' + fnaActList[0].Avatar_Master__r.Segment__c);
        fnaUtility.getAvatarImage(fnaActList[0]);
        //COntentVersion IsLatest = true
        // /Questionnaire_Results__r -> null
    }

    @isTest
    private static void Test_stampOffSetProductHoldingOSC14() {
        //SERVICE OSC14 MOCK
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaActivityId = listFnaAct[0].Id;
        String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": null,"creditCards": null,"loans": null,"bancassurances": null,"investments": null,"treasuries": [],"tradeFinances": []}}';
        String responseBodyOSC16 = '{"status": {"code": "0000","description": "Success"},"bancassurances": null,"total": "0"}';

        List<Product2> listProd2 = new List<Product2>();
        Product2 prod2 = new Product2();
        prod2.SF_Product_Key__c = '001';
        prod2.Name = '001';
        listProd2.add(prod2);
        insert listProd2;

        CaseAccountProduct mockCaseAcctProd = new CaseAccountProduct();
        
            CaseAccountProduct.Accounts caseAccount = new  CaseAccountProduct.Accounts();
            List<CaseAccountProduct.Deposits> depositList = new List<CaseAccountProduct.Deposits>();
            CaseAccountProduct.Deposits caseAcctProd_depObj = new CaseAccountProduct.Deposits();
                caseAcctProd_depObj.productCode = '001CRE';
                caseAcctProd_depObj.accountTitle = '001CRE';
                caseAcctProd_depObj.accountNumber = '001CRE';
                caseAcctProd_depObj.accountType = '001CRE';
                caseAcctProd_depObj.openDate = '001CRE';
                caseAcctProd_depObj.accountStatus = '001CRE';
            depositList.add(caseAcctProd_depObj);
            caseAccount.creditCards = depositList;
        	caseAccount.deposits = depositList;
        
        	List<CaseAccountProduct.Loans> caseLoanProductLsit = new List<CaseAccountProduct.Loans>();
        	CaseAccountProduct.Loans caseLoanProduct = new CaseAccountProduct.Loans();
        	caseLoanProductLsit.add(caseLoanProduct);
        
        	caseAccount.loans = caseLoanProductLsit;
		
        mockCaseAcctProd.Accounts = caseAccount;
        
        
        fnaUtility.stampOffSetProductHoldingOSC14(fnaActivityId, mockCaseAcctProd);
        fnaUtility.splitResProductHoldingOSC14(mockCaseAcctProd);
    }

    @isTest
    private static void Test_stampOffSetProductHoldingOSC16() {
        //SERVICE OSC16 MOCK
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaActivityId = listFnaAct[0].Id;

        List<Product2> listProd2 = new List<Product2>();
        Product2 prod2 = new Product2();
        prod2.SF_Product_Key__c = '001';
        prod2.Name = '001';
        listProd2.add(prod2);
        insert listProd2;

        CaseBAProduct mockCaseBAProd = new CaseBAProduct();
        mockCaseBAProd.bancassurances = new List<CaseBAProduct.Bancassurances>();
        CaseBAProduct.Bancassurances caseBaProd_bancObj = new CaseBAProduct.Bancassurances();
        caseBaProd_bancObj.insureType = '001';
        (mockCaseBAProd.bancassurances).add(caseBaProd_bancObj);


        fnaUtility.stampOffSetProductHoldingOSC16(fnaActivityId, mockCaseBAProd);
        fnaUtility.splitResProductHoldingOSC16(mockCaseBAProd);
    }

    @isTest
    private static void Test_encryptParams() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAId = listFnaAct[0].Id;
        fnaUtility.encryptParams(FNAId);
    }

    @isTest
    private static void Test_decryptParams() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaUtility.decryptParams(FNAId);
    }

    @isTest
    private static void Test_fnGenerateOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaUtility.fnGenerateOTP(FNAId);
    }

    @isTest
    private static void Test_fnVerifyOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String otpCode = '123456';
        fnaUtility.fnVerifyOTP(FNAId, otpCode);
    }
}