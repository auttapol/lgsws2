@isTest
public without sharing class fnaHighlightProductCtrl_Test {

    @isTest
    private static void Test_idleTime() {
        fnaHighlightProductCtrl.idleTime();
    }

    @isTest
    private static void Test_createRef() {

        Avatar_Master__c avatar = new Avatar_Master__c();
        avatar.Avatar_Description__c = 'description';
        avatar.Avatar_EN__c = 'Avtar Name';
        avatar.Avatar_Segment__c = 'SME';
        avatar.Avatar_TH__c = 'นักบริหาร';
        avatar.Segment__c = 'SEM';
        avatar.Avatar_Short_Description__c = 'description';
        insert avatar;
        
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Branch__c = '555';
        fnaActivity.Avatar_Master__c = avatar.id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;
        
        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;
        
        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping);
        insert listProductMapping;
        
        FNA_Product_Offering__c offering = new FNA_Product_Offering__c();
        offering.FNA_Activity__c = listFnaAct[0].id;
        offering.FNA_Product_Name__c = listProductMapping[0].id;
        insert offering;
        
        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Branch_Code__c = '555';
        branch.isActive__c = true;
        insert branch;
        
        List<String> appNameList = new List<String>();
        appNameList.add('RTL_Referral_Assignment_ISNULL');
        appNameList.add('RTL_Referral_Assignment_NOTNULL');
        appNameList.add('runReferralTrigger');
        List<AppConfig__c> appList = new List<AppConfig__c>();
        for(String str : appNameList){
            AppConfig__c app = new AppConfig__c();
            app.name = str;
            app.Value__c = 'true';
            appList.add(app);
        }
        insert appList;
        
        
        String fnaActId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String sessionData = listRTLProductMaster[0].id;
        try{
            fnaHighlightProductCtrl.createRef(fnaActId, sessionData);
        }catch(Exception ex){
            
        }
    }

    @isTest
    private static void Test_getMapGroup() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Downloaded__c = false;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        listRTLProductMaster.add(RTLProductMaster);
        RTL_product_master__c RTLProductMaster2 = new RTL_product_master__c();
        RTLProductMaster2.FNA_Active__c = true;
        RTLProductMaster2.Product_Type__c = 'Package';
        listRTLProductMaster.add(RTLProductMaster2);
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping);
        FNA_Product_Mapping__c productMapping1 = new FNA_Product_Mapping__c();
        productMapping1.Product__c = listRTLProductMaster[1].Id;
        listProductMapping.add(productMapping1);
        insert listProductMapping;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        productOffering.Flag_Highlight__c = true;
        listProductOffering.add(productOffering);

        FNA_Product_Offering__c productOffering2 = new FNA_Product_Offering__c();
        productOffering2.Flag_Offset_product_holding__c = false;
        productOffering2.FNA_Product_Name__c = listProductMapping[0].Id;
        productOffering2.FNA_Activity__c = listFnaAct[0].Id;
        productOffering2.Flag_Highlight__c = false;
        listProductOffering.add(productOffering2);
        
        FNA_Product_Offering__c productOffering3 = new FNA_Product_Offering__c();
        productOffering3.Flag_Offset_product_holding__c = false;
        productOffering3.FNA_Product_Name__c = listProductMapping[1].Id;
        productOffering3.FNA_Activity__c = listFnaAct[0].Id;
        productOffering3.Flag_Highlight__c = true;
        listProductOffering.add(productOffering3);
        insert listProductOffering;

        String fnaActivityId = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaHighlightProductCtrl.getMapGroup(fnaActivityId);
    }

    @isTest
    private static void Test_getThumbnailUrlAll() {

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        for(integer i=0; i < 6; i++){
            RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
                RTLProductMaster.FNA_Active__c = true;
                RTLProductMaster.FNA_Product_Name__c = 'Example_1';
                if(i == 0){
                    RTLProductMaster.FNA_Product_Group__c = 'For Use';
                }else if(i == 1){
                    RTLProductMaster.FNA_Product_Group__c = 'For Save';
                }else if(i == 2){
                    RTLProductMaster.FNA_Product_Group__c = 'For Borrow';
                }else if(i == 3){
                    RTLProductMaster.FNA_Product_Group__c = 'For Protect';
                }else if(i == 4){
                    RTLProductMaster.FNA_Product_Group__c = 'For Invest';
                }else{
                    RTLProductMaster.FNA_Product_Group__c = 'SME Product';
                }
        	listRTLProductMaster.add(RTLProductMaster);
        }
       
        insert listRTLProductMaster;        

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        for(RTL_product_master__c product : listRTLProductMaster){
            FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
            productMapping.Product__c = product.Id;
            listProductMapping.add(productMapping);
        }
        insert listProductMapping;
        
        List<FNA_Product_Mapping__c> productMapList = [Select id, name ,Product__r.FNA_Product_Group_TH__c, Product__r.FNA_Product_Name__c
                                                       FROM FNA_Product_Mapping__c Limit 10];

        List<fnaHighlightProductCtrl.ProductFNA> listMockData = new List<fnaHighlightProductCtrl.ProductFNA>();
        for(FNA_Product_Mapping__c productMap : productMapList){
            fnaHighlightProductCtrl.ProductFNA mockData = new fnaHighlightProductCtrl.ProductFNA();
            mockData.product = productMap;
            listMockData.add(mockData);
            system.debug('Mock ' + mockData.product.Product__r.FNA_Product_Group_TH__c);
        }
 
        fnaHighlightProductCtrl.getThumbnailUrlAll(listMockData);
    }

    @isTest
    private static void Test_getAvatar() {
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);

        fnaHighlightProductCtrl.getAvatar(idForm);
    }

    @isTest
    private static void Test_getAvatarMasterDetail() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
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

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        String urlDropOff = 'Test';
        fnaHighlightProductCtrl.getAvatarMasterDetail(idForm, urlDropOff);
    }

    @isTest
    private static void Test_getAvatarImageUrl() {
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(integer i=0; i < 2; i++){
           ContentVersion cv = new Contentversion();
           if(i==0){
              cv.title = 'Default_male_small';
           }else{
              cv.title = 'Default_female_small';
           }
           cv.PathOnClient ='test';
           Blob b=Blob.valueOf('Unit Test Attachment Body');
           cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
           cvList.add(cv);
        }	
        insert cvList;
	
        fnaHighlightProductCtrl.getAvatarImageUrl('Default', 'ชาย');
        fnaHighlightProductCtrl.getAvatarImageUrl('Default', 'หญิง');
    }

    @isTest
    private static void Test_getAvatarName() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q13';
        listQuestion.add(question);
        Question__c question1 = new Question__c();
        question1.Progress__c = 50;
        question1.Name = 'Q0';
        listQuestion.add(question1);
        insert listQuestion;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        questionnaireResults.Choice_Answer__c = 'B';
        listQuestionnaireResults.add(questionnaireResults);
        Questionnaire_Result__c questionnaireResults1 = new Questionnaire_Result__c();
        questionnaireResults1.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults1.Question_ID__c = listQuestion[1].Id;
        questionnaireResults1.Choice_Answer__c = 'B';
        listQuestionnaireResults.add(questionnaireResults1);
        insert listQuestionnaireResults;

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        fnaHighlightProductCtrl.getAvatarName(idForm);
    }

    @isTest
    private static void Test_sendOTP() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<OTP__c> listOtp = new List<OTP__c>();
        OTP__c otp = new OTP__c();
        listOtp.add(otp);
        insert listOtp;

        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);

        String phone = '0912345678';
        String otpId = listOtp[0].Id;
        fnaHighlightProductCtrl.sendOTP(phone, fnaId, otpId);
    }
}