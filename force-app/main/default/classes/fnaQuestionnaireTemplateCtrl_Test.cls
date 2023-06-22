@isTest
public without sharing class fnaQuestionnaireTemplateCtrl_Test {

    @isTest
    private static void Test_getQuestion() {
        List<Question__c> listQuestion = new List<Question__c>();

        Question__c questionPrevious = new Question__c();
        questionPrevious.Progress__c = 0;
        Question__c questionNow = new Question__c();
        questionNow.Progress__c = 10;

        listQuestion.add(questionPrevious);
        listQuestion.add(questionNow);
        insert listQuestion;

        listQuestion[0].Dependent__c = listQuestion[1].Id;
        listQuestion[1].Dependent__c = listQuestion[0].Id;
        update listQuestion;

        List<Answer__c> listAnswer = new List<Answer__c>();

        Answer__c answerPrevious = new Answer__c();
        answerPrevious.Answer__c = 'คำตอบ Previous';
        answerPrevious.Question__c = questionPrevious.Id;
        answerPrevious.Image_Title__c = 'รูปภาพ Previous';
        Answer__c answerNow = new Answer__c();
        answerNow.Answer__c = 'คำตอบ Now';
        answerNow.Question__c = questionNow.Id;
        answerNow.Image_Title__c = 'รูปภาพ Now';

        listAnswer.add(answerPrevious);
        listAnswer.add(answerNow);
        insert listAnswer;
        
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Questionnaire_Result__c> listQuestionResult = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionResult = new Questionnaire_Result__c();
        questionResult.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionResult.Question_ID__c = listQuestion[0].Id;
        listQuestionResult.add(questionResult);
        insert listQuestionResult;

        String encryptQuestionId = UrlHelper.encryptParams(questionNow.Id);
        String encryptFnaActId = UrlHelper.encryptParams(fnaActivity.Id);
        fnaQuestionnaireTemplateCtrl.getQuestion(encryptQuestionId, encryptFnaActId, questionPrevious.Id);
    }

    @isTest
    private static void Test_saveQuestionInformation() {
        List<Question__c> listQuestion = new List<Question__c>();

        Question__c questionPrevious = new Question__c();
        questionPrevious.Progress__c = 0;
        Question__c questionNow = new Question__c();
        questionNow.Progress__c = 10;

        listQuestion.add(questionPrevious);
        listQuestion.add(questionNow);
        insert listQuestion;

        listQuestion[0].Dependent__c = listQuestion[1].Id;
        listQuestion[1].Dependent__c = listQuestion[0].Id;
        update listQuestion;

        List<Answer__c> listAnswer = new List<Answer__c>();

        Answer__c answerPrevious = new Answer__c();
        answerPrevious.Answer__c = 'คำตอบ Previous';
        answerPrevious.Question__c = questionPrevious.Id;
        answerPrevious.Image_Title__c = 'รูปภาพ Previous';
        Answer__c answerNow = new Answer__c();
        answerNow.Answer__c = 'คำตอบ Now';
        answerNow.Question__c = questionNow.Id;
        answerNow.Image_Title__c = 'รูปภาพ Now';

        listAnswer.add(answerPrevious);
        listAnswer.add(answerNow);
        insert listAnswer;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Answer_Flow__c = 'คำตอบทั้งหมด';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Questionnaire_Result__c> listQuestionResult = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionResult = new Questionnaire_Result__c();
        questionResult.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionResult.Question_ID__c = listQuestion[0].Id;
        listQuestionResult.add(questionResult);
        insert listQuestionResult;

        List<AvatarResultMapping__c> listAvatarResultMaping = new List<AvatarResultMapping__c>();
        AvatarResultMapping__c avatarResultMaping = new AvatarResultMapping__c();
        avatarResultMaping.Answer__c = 'คำตอบทั้งหมดX';
        listAvatarResultMaping.add(avatarResultMaping);
        insert listAvatarResultMaping;

        fnaQuestionnaireTemplateCtrl.QuestionTemplate mockDataQuestionTemplate = new fnaQuestionnaireTemplateCtrl.QuestionTemplate();
        mockDataQuestionTemplate.idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        mockDataQuestionTemplate.question = listQuestion[0];

        mockDataQuestionTemplate.template = new fnaQuestionnaireTemplateCtrl.Template();
        mockDataQuestionTemplate.template.template5 = true;

        mockDataQuestionTemplate.nextQuestion = new Map<String, String>();
        mockDataQuestionTemplate.nextQuestion.put('choice.Answer_Avatar__c', 'คำตอบ Previous');

        mockDataQuestionTemplate.answerAvatar = new Map<String, String>();
        mockDataQuestionTemplate.answerAvatar.put('คำตอบ Previous', 'choice.Answer_Avatar__c');

        fnaQuestionnaireTemplateCtrl.saveQuestionInformation(mockDataQuestionTemplate, 'choice.Answer_Avatar__c;');
    }

    @isTest
    private static void Test_previousQuestionInformation() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Answer_Flow__c = 'คำตอบทั้งหมด';
        fnaActivity.Questionnaire_Flow__c = 'Q1Q2Q3';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        String idQuestion = '';
        String preQusetion = '';

        fnaQuestionnaireTemplateCtrl.previousQuestionInformation(idForm, idQuestion, preQusetion);
    }

    @isTest
    private static void Test_getImage() {
        fnaQuestionnaireTemplateCtrl.getImage();
    }

    @isTest
    private static void Test_saveBranchId() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        String branchId = '1234';
        fnaQuestionnaireTemplateCtrl.saveBranchId(idForm, branchId);
    }
}