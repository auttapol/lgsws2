@isTest
public without sharing class fnaAvatarPassportFlagshipCtrl_Test {

    @isTest
    private static void Test_fnaAvatarPassportFlagshipCtrl() {
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Branch__c = '252';
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
        
        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        for(Integer i=0; i< 2; i++){
            RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
            RTLProductMaster.FNA_Active__c = true;
            RTLPRoductMaster.FNA_Product_Group__c  = i==0? 'For Save': 'For Invest';
            listRTLProductMaster.add(RTLProductMaster);
        }
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        for(Integer i=0; i< 2; i++){
        	FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
            productMapping.Product__c = listRTLProductMaster[i].Id;
            listProductMapping.add(productMapping);
        }
        insert listProductMapping;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        for(Integer i=0; i< 2; i++){
            FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
            productOffering.FNA_Product_Name__c = listProductMapping[i].Id;
            productOffering.FNA_Activity__c = listFnaAct[0].Id;
            productOffering.Flag_Highlight__c = true;
            listProductOffering.add(productOffering);
        }
        insert listProductOffering;

        // PageReference pageRef = Page.fnaAvatarPassportFlagship; // Add your VF page Name here
        // Test.setCurrentPage(pageRef);

        String fnaId = listFnaAct[0].Id;
        System.currentPageReference().getParameters().put('Id',fnaId);
        // System.currentPageReference().getParameters().put('Home', 'fna-tmbbankpws.cs58.force.com');

        fnaAvatarPassportFlagshipCtrl testClass = new fnaAvatarPassportFlagshipCtrl();
    }
    
    @isTest
    private static void Test_saveScreenShot() {
        

        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        insert fnaActivity;
        
        String fnaId = fnaActivity.id;
        String strImageBlob = '123456';
        Attachment atth = new Attachment();
        atth.Name = 'test';
        atth.body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
        atth.ContentType = 'image/png';
        atth.ParentId = fnaId;
        insert atth;        
        
        System.currentPageReference().getParameters().put('Id', fnaId);

        fnaAvatarPassportFlagshipCtrl testClass = new fnaAvatarPassportFlagshipCtrl();
        testClass.strImageBlob = strImageBlob;
        testClass.saveScreenShot();
    }
}