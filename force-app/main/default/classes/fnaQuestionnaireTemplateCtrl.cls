public without sharing class fnaQuestionnaireTemplateCtrl {
    
    public class QuestionResponse{
        @AuraEnabled
        public boolean success      {get;set;}
        @AuraEnabled
        public String nextPage      {get;set;} //Id question_template
        @AuraEnabled
        public String idForm        {get;set;} // Id question_form
        @AuraEnabled
        public String errMsg        {get;set;}
        @AuraEnabled
        public Decimal nextProgress {get;set;} //Dynamic move animation by JJ
    }
    
    public class Template {
        @AuraEnabled
        public Boolean template1 {get;set;}
        @AuraEnabled
        public Boolean template2 {get;set;}
        @AuraEnabled
        public Boolean template3 {get;set;}
        @AuraEnabled
        public Boolean template4 {get;set;}
        @AuraEnabled
        public Boolean template5 {get;set;}
        @AuraEnabled
        public Boolean template6 {get;set;}
        @AuraEnabled
        public Boolean template7 {get;set;}
    }

    public class Choice{
        @AuraEnabled
        public Integer id           {get;set;}
        @AuraEnabled
        public String choice        {get;set;}
        @AuraEnabled
        public String urlImage      {get;set;}
        @AuraEnabled
        public String imageClass    {get;set;}
        @AuraEnabled
        public String btnClass      {get;set;}
        @AuraEnabled
        public Boolean bootstrap    {get;set;}
    }

    public class QuestionTemplate{
        @AuraEnabled
        public Question__c question             {get;set;}
        @AuraEnabled
        public Template template                {get;set;}
        @AuraEnabled
        public List<Choice> choiceObj           {get;set;}
        @AuraEnabled
        public Map<String, String> nextQuestion {get;set;}
        @AuraEnabled
        public String idForm                    {get;set;}
        @AuraEnabled
        public String answer                    {get;set;}
        @AuraEnabled
        public Map<String, String> answerAvatar {get;set;}
        @AuraEnabled
        public String previousQuestion          {get;set;}
        @AuraEnabled
        public Decimal progress                 {get;set;} //Dynamic move animation by JJ
        
    }

    @AuraEnabled
    public static QuestionTemplate getQuestion(String thisQuestion, String thisForm, String preQuestion){
        String questionId = thisQuestion;
        String questionName = '';
        system.debug('Question Id' + questionId);
        system.debug('thisForm' + thisForm);
        
        if(questionId != '' && questionId != null && questionId != 'undefined'){
            questionId = UrlHelper.decryptParams(questionId);
        }

        if(thisForm != '' && thisForm != null && thisForm != 'undefined'){
            thisForm = UrlHelper.decryptParams(thisForm);
        }

        QuestionTemplate res = new QuestionTemplate();
        List<Question__c> questionnaireList = new List<Question__c>();
        if(questionId != ''){
            questionnaireList = [SELECT Id, Name, Choice_Layout__c, Bypass_Value__c, Dependent__c, QuestionType__c, Choice_Layout__r.name, Project__c, Question__c, Version__c, Progress__c,
                                                                 (SELECT Id, Name, Answer__c, Image_Title__c, Question__c, Next_Question__c, Answer_Avatar__c
                                                                  From Answers__r ORDER BY Answer_Avatar__c) FROM Question__c WHERE id =:questionId AND Project__c = :fnaUtility.getprojectFin()];
        }else{
            questionnaireList = [SELECT Id, Name, Choice_Layout__c, Bypass_Value__c, Dependent__c, QuestionType__c, Choice_Layout__r.name, Project__c, Question__c, Version__c, Progress__c,
                                                                 (SELECT Id, Name, Answer__c, Image_Title__c, Question__c, Next_Question__c, Answer_Avatar__c
                                                                  From Answers__r ORDER BY Answer_Avatar__c) FROM Question__c WHERE First_Question__c = true AND Project__c = :fnaUtility.getprojectFin()];
            
        }
        system.debug('questionnaireList ' + questionnaireList);
        if(questionnaireList.size() > 0){
            Question__c question = questionnaireList[0];
            questionId = question.Id;
            questionName = question.Name;
            res.question = question;
            res.template = defineTemplate(question.Choice_Layout__r.Name);
            res.choiceObj = new List<Choice>();
            res.nextQuestion = new Map<String, String>();
            res.answerAvatar = new Map<String, String>();  

            if(thisForm == null || thisForm == '' || thisForm == 'undefined'){
                res.idForm = '';
            }else{
                res.idForm = thisForm;
            }

            //Dynamic move animation by JJ
            res.progress = (question.Progress__c != null ? question.Progress__c : 0);
            Integer x = 0;
            Boolean isRight = false;
            Map<String, String> titleImage = new Map<String, String>();
            for(Answer__c choice : question.Answers__r){
                system.debug('choice ' + choice);
                x++;
                Choice tmpChoice = new Choice();
                tmpChoice.id = x;
                tmpChoice.choice = choice.Answer__c;
                tmpChoice.imageClass = 'hideLoading';
                tmpChoice.bootstrap = isRight;
                res.choiceObj.add(tmpChoice);

                if(choice.Answer__c == null || choice.Answer__c == ''){
                    res.nextQuestion.put('fill input', choice.Next_Question__c); 
                    
                }else{
                    res.nextQuestion.put(choice.Answer__c, choice.Next_Question__c);
                   
                }

                res.answerAvatar.put(choice.Answer__c, choice.Answer_Avatar__c);

                if(choice.Image_Title__c != '' && choice.Image_Title__c != null){
                     titleImage.put(choice.Answer__c , choice.Image_Title__c);
                }
                tmpChoice.btnClass= 'slds-button slds-button_neutral fullbutton';
                isRight = !isRight;

            }

            system.debug('NextQuestion ' + res.nextQuestion);

            if(question.Dependent__c != null){
                List<Questionnaire_Result__c> questionList = [SELECT Id, Question_ID__c, Answer__c, FNA_Activity_Name__c, Question__c 
                                                                    FROM Questionnaire_Result__c 
                                                                    WHERE FNA_Activity_Name__c =: res.idForm 
                                                                    AND Question_ID__c= :question.Dependent__c];
                system.debug('questionList : ' + questionList);
                     
                if(questionList.size() > 0){
                    List<Answer__c> ans = [SELECT Id, Question__c, Answer__c, Image_Title__c FROM Answer__c WHERE Question__c=: questionList[0].Question_ID__c];
                    for(Answer__c a : ans){
                        if(a.Answer__c == questionList[0].Answer__c){
                            titleImage.put(questionList[0].Answer__c , a.Image_Title__c);
                        }
                    }

                    res.choiceObj[0].choice = questionList[0].Answer__c;
                }
            }

            if(titleImage.size() > 0){
                Map<String, String> temp = fnaUtility.getImageUrl(titleImage);
                for(Choice tempChoice : res.choiceObj){
                    for(String imageKey : temp.keySet()){
                        if(tempChoice.choice == imageKey){
                            tempChoice.imageClass = '';
                            tempChoice.urlImage = temp.get(imageKey);
                        }
                    }
                }
            }

            system.debug('res choice ' + res.choiceObj);
        } 

        if(res.idForm != ''){
            List<FNA_Activity__c> questionList = [SELECT Id, Avatar_Master__c, Person_Name__c, Drop_Off_URL__c , Drop_Off_Page__c, 
                                                    (Select Id, Question__c, Answer__c FROM Questionnaire_Results__r WHERE Question_ID__c=:questionId) 
                                                    FROM FNA_Activity__c WHERE id=: res.idForm];
            if(questionList.size() > 0){
                system.debug('questionList[0].Questionnaire_Results__r' + questionList[0].Questionnaire_Results__r );
                if(questionList[0].Questionnaire_Results__r != null && questionList[0].Questionnaire_Results__r.size() > 0){
                    res.answer = questionList[0].Questionnaire_Results__r[0].Answer__c;
                }else if(questionName == 'Q0'){
                    res.answer = questionList[0].Person_Name__c;
                }
                questionList[0].Drop_Off_Page__c = 'questionnaire=' + questionName;
                questionList[0].Drop_Off_URL__c = '/fin/s/questionnaire';
                update questionList;
            }

            res.idForm = UrlHelper.encryptParams(res.idForm);
        }

        if(preQuestion != null && preQuestion != '' && preQuestion != 'undefined'){
            res.previousQuestion = preQuestion; //aom
        }

        return res;
    }
    
    @AuraEnabled
    public static QuestionResponse saveQuestionInformation(QuestionTemplate thisQuestion, String answerQuestion){
        system.debug('saveQuestionInformation');
        system.debug('thisQuestion : ' + thisQuestion);
        system.debug('thisQuestion.previousQuestion : ' + thisQuestion.previousQuestion);
        system.debug('thisQuestion.nextQuestion : ' + thisQuestion.nextQuestion);
        system.debug('answerQuestion : ' + answerQuestion);

        String originalAnswer = '';
        Boolean isInput = false;
        QuestionResponse questionRes = new QuestionResponse();
        FNA_Activity__c objquestionnaireForm = new FNA_Activity__c();  
        if(thisQuestion.idForm == '' || thisQuestion.idForm == null || thisQuestion.idForm == 'undefined'){
            upsert objquestionnaireForm;
            thisQuestion.idForm = objquestionnaireForm.Id;
            system.debug('thisQuestion.idForm if : ' + thisQuestion.idForm);
        }else{
            system.debug('thisQuestion.idForm else decrypt : ' + thisQuestion.idForm);
            thisQuestion.idForm = UrlHelper.decryptParams(thisQuestion.idForm);
            system.debug('thisQuestion.idForm else decrypt : ' + thisQuestion.idForm);
        }
        system.debug('thisQuestion.idForm out : ' + thisQuestion.idForm);
        system.debug('thisQuestion.questionId : ' + thisQuestion.question.Id);
        List<Questionnaire_Result__c> questionnaire_DB = [SELECT Id, Name, Question__c, Answer__c, Question_ID__c,Question_ID__r.IsInput__c FROM Questionnaire_Result__c WHERE Question_ID__c =: thisQuestion.question.Id AND FNA_Activity_Name__c =: thisQuestion.idForm];
        system.debug('questionnaire_DB : ' + questionnaire_DB);

        String choiceAns = splitAnswer(answerQuestion, thisQuestion.answerAvatar);
        if(questionnaire_DB.isEmpty()){
            Questionnaire_Result__c objQuestionnaire = new Questionnaire_Result__c();
            objQuestionnaire.Question__c = thisQuestion.question.Question__c;
            objQuestionnaire.Choice_Answer__c = choiceAns;
            objQuestionnaire.Answer__c = answerQuestion;
            objQuestionnaire.Question_ID__c = thisQuestion.question.Id;
            objQuestionnaire.FNA_Activity_Name__c = thisQuestion.idForm;
            system.debug('questionnaire (if) : ' + objQuestionnaire);
            upsert objQuestionnaire;
        }else{
            originalAnswer = questionnaire_DB[0].Answer__c;
            isInput = questionnaire_DB[0].Question_ID__r.IsInput__c;
            questionnaire_DB[0].Choice_Answer__c = choiceAns;
            questionnaire_DB[0].Question__c = thisQuestion.question.Question__c;
            questionnaire_DB[0].Answer__c = answerQuestion;
            system.debug('questionnaire (else) : ' + questionnaire_DB);
            upsert questionnaire_DB;            
            
        }

        ///////////////////////////////////////////////////////////////
        system.debug('answerQuestion : ' + answerQuestion);
        system.debug('thisQuestion : ' + thisQuestion);
        questionRes.nextPage = findNextPage(thisQuestion, answerQuestion);
        system.debug('questionRes.nextPage : ' + questionRes.nextPage);
        ///////////////////////////////////////////////////////////////
        List<FNA_Activity__c> questionnaireForm_DB = [SELECT Id, Questionnaire_Flow__c, Answer_Flow__c FROM FNA_Activity__c WHERE Id =: thisQuestion.idForm];
        system.debug('FNA_Activity__c : ' + questionnaireForm_DB);
        questionnaireForm_DB[0].Answer_Flow__c = questionnaireForm_DB[0].Answer_Flow__c == null ? '' : questionnaireForm_DB[0].Answer_Flow__c; 
        if(thisQuestion.question.Bypass_Value__c || thisQuestion.answerAvatar.get(answerQuestion) == null){
            questionnaireForm_DB[0].Answer_Flow__c += 'X';
        }else{
            questionnaireForm_DB[0].Answer_Flow__c += thisQuestion.answerAvatar.get(answerQuestion);
        }
        
        if(thisQuestion.question.name == 'Q0'){
            questionnaireForm_DB[0].Person_Name__c = answerQuestion;
        }

        if(thisQuestion.question.name == 'Q13'){
            questionnaireForm_DB[0].Gender__c = answerQuestion == 'ชาย' ? 'male' : 'female';
        }

        system.debug('thisQuestion.questionId : ' + thisQuestion.question.Id);
        system.debug('questionnaireForm_DB[0].Answer_Flow__c : ' + questionnaireForm_DB[0].Answer_Flow__c);

        List<Question__c> question_DB = [SELECT Id, Name, Question__c, Dependent__c FROM Question__c WHERE Id =: thisQuestion.question.Id];

        system.debug('question_DB.Name : ' + question_DB[0].Name);
        if(questionnaireForm_DB[0].Questionnaire_Flow__c == null){
            questionnaireForm_DB[0].Questionnaire_Flow__c = question_DB[0].Name;
        }
        else{
            questionnaireForm_DB[0].Questionnaire_Flow__c += question_DB[0].Name;            
        }

        System.debug('thisQuestion :'+thisQuestion);
        System.debug('answerQuestion :'+answerQuestion);
        System.debug('questionnaireForm_DB :'+questionnaireForm_DB);
        questionnaireForm_DB[0].Avatar_Master__c = saveAvatarMaster(thisQuestion, answerQuestion, questionnaireForm_DB);
        
        update questionnaireForm_DB;
        
        system.debug('answerQuestion : ' + answerQuestion);
        system.debug('originalAnswer : ' + originalAnswer);
            system.debug('isInput : ' + isInput);
        if(!isInput){
            if(answerQuestion != originalAnswer){
                changeFlow(thisQuestion.idForm, thisQuestion.question.Id, thisQuestion.previousQuestion);
            }
        }
        
        system.debug('thisQuestion.nextQuestion ' + thisQuestion.nextQuestion);
        system.debug('thisQuestion.nextPage ' + questionRes.nextPage);

        questionRes.success = true;
        questionRes.errMsg = '';
        Set<ID> idFNA = new Set<ID>();
        idFNA.add(thisQuestion.idForm);

        //Dynamic move animation by JJ
        List<Question__c> questionnaireList = [SELECT Id,  Progress__c FROM Question__c WHERE id =:questionRes.nextPage];            
        if(questionnaireList.size()>0){
            questionRes.nextProgress = questionnaireList.get(0).Progress__c;
        }

        /// save Question
        if(thisQuestion.idForm != '' && thisQuestion.idForm != null){
            questionRes.idForm = UrlHelper.encryptParams(thisQuestion.idForm);
        }
        else{
            questionRes.idForm = thisQuestion.idForm;
        }
        system.debug('questionRes ' + questionRes);

        if(questionRes.nextPage != '' && questionRes.nextPage != null && questionRes.nextPage != 'undefined'){
            questionRes.nextPage = UrlHelper.encryptParams(questionRes.nextPage);
        }

        return questionRes;
    }

    public static String splitAnswer(String answerQuestion , Map<String,String> answerAvatar){
        List<String> ansList = answerQuestion.split(';');
        String choiceAns = '';
        for(String ans : ansList){
            choiceAns = choiceAns == '' ? answerAvatar.get(ans): choiceAns + ',' + answerAvatar.get(ans);
        }

        choiceAns = choiceAns == null ? 'X': choiceAns;
        return choiceAns;
    }

    public static String findNextPage(QuestionTemplate thisQuestion, String answerQuestion){
        String nextPage = '';
        String ans = answerQuestion;
        system.debug('thisQuestion.template :' + thisQuestion.template);
        if(thisQuestion.template.template5 == true){
            List<String> temp = ans.split(';');
            if(temp.size() > 0){
                system.debug(' temp[0] ' + temp[0]);
                ans = temp[0];
            }
        }

        Boolean haveAnswer = thisQuestion.nextQuestion.containsKey(ans);
        system.debug('haveAnswer +++' + haveAnswer);
        system.debug('ans +++' + ans);
        if(haveAnswer){
            nextPage = thisQuestion.nextQuestion.get(ans);
            system.debug('111111111 ');
        }else if(thisQuestion.nextQuestion.containsKey('fill input')){
            nextPage = thisQuestion.nextQuestion.get('fill input');
            system.debug('222222222 ');
        }

        return nextPage;

    }

    public static void changeFlow(String idForm, String thisQuestion, String previousQuestion){
        system.debug('idForm :' + idForm);
        system.debug('previousQuestion ' + previousQuestion);
        List<Questionnaire_Result__c> deleteQuestionnaire = new List<Questionnaire_Result__c>();
        if(previousQuestion != '' && previousQuestion != null){
            List<Questionnaire_Result__c> questionnaire_DB = [SELECT Id, Name, Question_ID__c, Answer__c, Question__c, FNA_Activity_Name__c  FROM Questionnaire_Result__c WHERE FNA_Activity_Name__c =: idForm ORDER BY CreatedDate DESC]; 
            for(Questionnaire_Result__c ques : questionnaire_DB){
            
                if(ques.Question_ID__c == previousQuestion){
                    break;
                }
                system.debug('ques.Question_ID__c ' + ques.Question_ID__c);
                system.debug('thisQuestion >> ' + thisQuestion);

                if(ques.Question_ID__c != thisQuestion ){
                    system.debug('ques >> ' + ques);
                    deleteQuestionnaire.add(ques);
                }
                system.debug('temp ' + deleteQuestionnaire);
            }
        }
        
        if(deleteQuestionnaire.size() > 0){
            system.debug('deleteQuestionnaire ' + deleteQuestionnaire);
            delete deleteQuestionnaire;
        }
    }

    public static String saveAvatarMaster(QuestionTemplate thisQuestion, String answerQuestion, List<FNA_Activity__c> qForm_DB){
        String temp = thisQuestion.nextQuestion.get(answerQuestion);
        String tempDB;
        if(temp == null || temp == ''){    //Avatar__c
            List<AvatarResultMapping__c> avatarMap_DB = [SELECT Id, Answer__c, AvatarMaster__c FROM AvatarResultMapping__c WHERE Answer__c =: qForm_DB[0].Answer_Flow__c];
            if(avatarMap_DB.isEmpty()){//default avatar
                List<Avatar_Master__c> avatarMap_DB_Default = [SELECT Id, Segment__c, Avatar_EN__c, Avatar_TH__c, Avatar_Description__c FROM Avatar_Master__c WHERE Segment__c =: 'Default Avatar'];
                tempDB = avatarMap_DB_Default[0].Id;
            }else {
                tempDB = avatarMap_DB[0].AvatarMaster__c;
            }
        }
        return tempDB;
    }

    @AuraEnabled
    public static Boolean saveBranchId(String idForm ,String branchId){
        system.debug('idForm : ' + idForm);
        if(idForm != 'undefined' && idForm != '' && idForm != null){
            idForm = UrlHelper.decryptParams(idForm);
        }else{
            idForm = '';
        }

        system.debug('idForm : ' + idForm);
        system.debug('saveBranchId : ' + branchId);
        if(idForm != '' && branchId != ''){
            FNA_Activity__c fnaObj = new FNA_Activity__c();
            fnaObj.id = idForm;
            fnaObj.Branch__c = branchId;
            fnaObj.Created_Branch_Code__c = branchId;
            update fnaObj;
            return true;
        }else{
            return false;
        }
    }    

    @AuraEnabled
    public static String previousQuestionInformation(String idForm, String idQuestion, String preQusetion){
        system.debug('idForm' + idForm);
        if(idForm != '' && idForm != null){
            idForm = UrlHelper.decryptParams(idForm);
        }

        String previousQuestionId = '';
        system.debug('idForm' + idForm); 
        system.debug('idQuestion' + idQuestion); //res

        //Delete Question from Questionnaire_Flow__c when click Back
        List<FNA_Activity__c> tamQuestionnaireFlow = [SELECT Id, Questionnaire_Flow__c FROM FNA_Activity__c WHERE Id =: idForm];
        system.debug('Before --- Questionnaire_Flow__c----> : ' + tamQuestionnaireFlow[0].Questionnaire_Flow__c);
        if(tamQuestionnaireFlow.size() > 0){
            do{
                tamQuestionnaireFlow[0].Questionnaire_Flow__c = tamQuestionnaireFlow[0].Questionnaire_Flow__c.substring(0,tamQuestionnaireFlow[0].Questionnaire_Flow__c.length()-1);
            }while((tamQuestionnaireFlow[0].Questionnaire_Flow__c.substring(0,tamQuestionnaireFlow[0].Questionnaire_Flow__c.length())).right(1) != 'Q');
            tamQuestionnaireFlow[0].Questionnaire_Flow__c = tamQuestionnaireFlow[0].Questionnaire_Flow__c.substring(0,tamQuestionnaireFlow[0].Questionnaire_Flow__c.length()-1);
            system.debug('After --- Questionnaire_Flow__c----> : ' + tamQuestionnaireFlow[0].Questionnaire_Flow__c);
        }
        upsert tamQuestionnaireFlow;
        //Delete Answer from Answer_Flow__c when click Back
        List<FNA_Activity__c> questionnaireForm_DB = [SELECT Id, Answer_Flow__c, (SELECT Id, Name, Question__c, Answer__c, Question_ID__c,Question_ID__r.Name, FNA_Activity_Name__c FROM Questionnaire_Results__r ORDER BY CreatedDate DESC) FROM FNA_Activity__c WHERE Id =: idForm];
        if(questionnaireForm_DB.size() > 0){

            questionnaireForm_DB[0].Answer_Flow__c = questionnaireForm_DB[0].Answer_Flow__c.substring(0,questionnaireForm_DB[0].Answer_Flow__c.length()-1);
            upsert questionnaireForm_DB;
            
            //Redirect when click back
            if(questionnaireForm_DB[0].Questionnaire_Results__r != null && questionnaireForm_DB[0].Questionnaire_Results__r.size() > 0){
                List<String> temp = new List<String>();
                for(Questionnaire_Result__c ques : questionnaireForm_DB[0].Questionnaire_Results__r){
                    temp.add(ques.Question_ID__c);
                    system.debug('temp ' + temp);
                }
                

                System.debug('TEMP : ' + temp.indexOf(idQuestion));
                System.debug('DB size  : ' + questionnaireForm_DB[0].Questionnaire_Results__r.size());

                if( temp.indexOf(idQuestion) != -1 && temp.indexOf(idQuestion) != questionnaireForm_DB[0].Questionnaire_Results__r.size() - 1){
                    System.debug('PRE ID : ' + temp[temp.indexOf(idQuestion) + 1]);
                    previousQuestionId = temp[temp.indexOf(idQuestion) + 1];
                }else{
                    previousQuestionId = preQusetion;
                }
            }

        }
        
        system.debug('previousQuestionId : ' + previousQuestionId);
        if(previousQuestionId != null && previousQuestionId != '' && previousQuestionId != 'undefined'){
            previousQuestionId = UrlHelper.encryptParams(previousQuestionId);//aom
        }
        return previousQuestionId;
    }

    public class ImageResponse{
        @AuraEnabled
        public String logo {get;set;}
        @AuraEnabled
        public String front {get;set;}
        @AuraEnabled
        public String horizon {get;set;}
        @AuraEnabled
        public String middle {get;set;}
        @AuraEnabled
        public String dead {get;set;}
        @AuraEnabled
        public String hurt {get;set;}
        @AuraEnabled
        public String biker {get;set;}
        @AuraEnabled
        public String wheel {get;set;}
        @AuraEnabled
        public String notSupport {get;set;}
        @AuraEnabled
        public String star {get;set;}
        @AuraEnabled
        public String back {get;set;}
        @AuraEnabled
        public String backInvert {get;set;}
        @AuraEnabled
        public String cancel {get;set;}
        @AuraEnabled
        public String cancelInvert {get;set;}
        @AuraEnabled
        public String orientation {get;set;}
        @AuraEnabled
        public String less {get;set;}
        @AuraEnabled
        public String more {get;set;}
    }

    @AuraEnabled
    public static ImageResponse getImage(){
        ImageResponse resImage = new ImageResponse();
        Map<String, String> titleImage = new Map<String, String>();
        titleImage.put('logo', 'logo');
        titleImage.put('front', 'bg-front');
        titleImage.put('horizon', 'bg-horizon');
        titleImage.put('middle', 'bg-middle');
        titleImage.put('dead', 'img-dead');
        titleImage.put('hurt', 'img-hurt');
        titleImage.put('biker', 'biker');
        titleImage.put('wheel', 'wheel');
        titleImage.put('notSupport', '404');
        titleImage.put('star', 'ico-star');

        titleImage.put('less', 'ico-less');
        titleImage.put('more', 'ico-more');

        titleImage.put('back', 'ico-back');
        titleImage.put('backInvert', 'ico-back-inverted');
        titleImage.put('cancel', 'ico-cancel');
        titleImage.put('cancelInvert', 'ico-cancel-inverted');
        titleImage.put('orientation', 'orientation');

        titleImage = fnaUtility.getImageUrl(titleImage);
        
        resImage.logo = titleImage.get('logo');
        resImage.front = titleImage.get('front');
        resImage.horizon = titleImage.get('horizon');
        resImage.middle = titleImage.get('middle');
        resImage.dead = titleImage.get('dead');
        resImage.hurt = titleImage.get('hurt');
        resImage.biker = titleImage.get('biker');
        resImage.wheel = titleImage.get('wheel');
        resImage.notSupport = titleImage.get('notSupport');
        resImage.star = titleImage.get('star');

        resImage.less = titleImage.get('less');
        resImage.more = titleImage.get('more');

        resImage.back = titleImage.get('back');
        resImage.backInvert = titleImage.get('backInvert');
        resImage.cancel = titleImage.get('cancel');
        resImage.cancelInvert = titleImage.get('cancelInvert');

        resImage.orientation = titleImage.get('orientation');

        return resImage;
    
    }

    public static Template defineTemplate(String idTemplate){
        Template resTemplate = new Template();
        switch on idTemplate {
            when 'Template#1' {
                resTemplate.template1 = true;
            }
            when 'Template#2' {
                resTemplate.template2 = true;
            }
            when 'Template#3' {
                resTemplate.template3 = true;
            }
            when 'Template#4' {
                resTemplate.template4 = true;
            }
            when 'Template#5' {
                resTemplate.template5 = true;
            }
            when 'Template#6' {
                resTemplate.template6 = true;
            }
            when 'Template#7' {
                resTemplate.template7 = true;
            }
        }
        return resTemplate;
    }  
}