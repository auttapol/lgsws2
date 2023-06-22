@isTest
public without sharing class fnaProductDetailCtrl_Test {

    static fnaProductDetailCtrl testClass;

    @isTest
    private static void Test_ProductDetail() {
        Branch_and_Zone__c branch = new Branch_and_Zone__c();
		branch.Branch_Name__c = 'เซ็นทรัลเฟสติวัล เชียงใหม่';
        branch.Branch_Code__c = '500';
        branch.name = 'CM500';
        branch.IsActive__c = true;
        insert branch;

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
        fnaActivity.Branch__c = '485';
        fnaActivity.Phone__c = '0800000000';
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;


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

        Branch_and_Zone__c baz = new Branch_and_Zone__c ();
		baz.name = 'เซ็นทรัลเฟสติวัล เชียงใหม่';
		baz.Branch_Code__c = '485';
		baz.Branch_Name__c = 'test';
        baz.Province__c = 'เชียงใหม่';
        baz.District__c = 'เมือง';
        baz.Branch_Name__c = 'เซ็นทรัลเฟสติวัล เชียงใหม่';
        baz.IsActive__c = true;
		insert baz;

        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String rtlId = UrlHelper.encryptParams(listRTLProductMaster[0].Id);

        String fullParam = 'Id=' + fnaId + '&RTLId=' + rtlId;
        String OriginalFullParam = 'Id=Gg9dp7/Fx1ye2Zl/sO6gEe9BNdRjbHsKabkw59ccpRrrI0Vxlr9u6H6XZZjXPC5D&RTLId=OJampV2YNn+CIePGBh27CKeA5PymmF3Bae97mWA+4Av9i5fyjm3lZjK4i5A6Pcv7=';
        ApexPages.currentPage().getParameters().put('fullParam', fullParam);
        
        fnaProductDetailCtrl ctrl = new fnaProductDetailCtrl();
        // ctrl.provinceDependent = 'ทดสอบ';
        // ctrl.districtDependent = 'ทดสอบ';
        // ctrl.branchDependent = 'ทดสอบ';
        ctrl.provinceDependent = 'เชียงใหม่';
        ctrl.districtDependent = 'เมือง';
        ctrl.branchDependent = 'เซ็นทรัลเฟสติวัล เชียงใหม่';
        ctrl.personName = 'ทดสอบ';
        ctrl.mobileNumber = 'ทดสอบ';

        ctrl.idleTime();
        fnaProductDetailCtrl.idleTimeConstructor();

        ctrl.dependentInformationDistrict();
        ctrl.dependentInformationBranch();

        ctrl.setInformation();
        ctrl.getInformation();
        ctrl.saveInformation();
        //ctrl.createRef();
        ctrl.stampOffSet();
    }

    @isTest
    private static void Test_stampUrlDropOff() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Product_Name__c = 'TestProductName';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        String FNAId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String urlPage = 'Test';
        String RTL = listRTLProductMaster[0].Id;
        fnaProductDetailCtrl.stampUrlDropOff(FNAId, urlPage, RTL);
    }

    @isTest
    private static void Test_getStream() {
        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Product_Name__c = 'TestProductName';
        RTLProductMaster.FNA_Product_Name_TH__c = 'เทสภาษาไทย';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        String rtlid = listRTLProductMaster[0].Id;
        fnaProductDetailCtrl.getStream(rtlid);
    }

    @isTest
    private static void Test_fnGenerateOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        String fnaId = listFnaAct[0].Id;
        String phone = '0912345678';
        fnaProductDetailCtrl.fnGenerateOTP(fnaId,phone);
    }

    @isTest
    private static void Test_sendSMSUrl() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        //String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        
        fnaProductDetailCtrl.sendSMSUrl(listFnaAct[0].Id);
    }

    @isTest
    private static void Test_successDownload() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        //String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaProductDetailCtrl.successDownload(listFnaAct[0].Id); 
    }

    @isTest
    private static void Test_fnVerifyOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        String fnaId = listFnaAct[0].Id;
        String otpCode = '123456';
        fnaProductDetailCtrl.fnVerifyOTP(fnaId, otpCode);
    }

    @isTest
    private static void Test_encryptId() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String FNAIdEncrypt = listFnaAct[0].Id;
        fnaProductDetailCtrl.encryptId(FNAIdEncrypt);
    }
}