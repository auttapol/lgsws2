public class NPSSurveyController {
   
    public string surveyID {get;set;}
    public string CompleteScreenflag {get;set;}
    public string campaignID {get;set;}
    public string customerSegmentTeam {get;set;}
    public lead tempLead {get;set;}
    public Account tempAccount {get;set;}
    public boolean isLead {get;set;}
    public boolean isAccount {get;set;}
    public boolean isShowResultScreen {get;set;}
    public boolean isExisting {get;set;}
    public boolean isCompleteSurvey {get;set;}
    public boolean isFilterbyCampaign {get;set;}
    public boolean isAlreadyComplete {get;set;}
    public boolean isCompleteLead {get;set;}
    public Boolean isCancel {get;set;}
    public List<selectOption> ListQuestion {get;set;}
    public survey__c tempSurveyDetail {get;set;}
    private static final integer MAXIMUM_NO_OF_QUESTIONS = 20;
    private static final integer MAXIMUM_NO_OF_ANSWERS = 5;
    private static final String QUESTION_FIELDNAME = 'Question';
    private static final String ADDITIONAL_FIELDNAME = 'Additional_Feedback_Required_';
    private static final String ADDITIONAL_ANSWER_FIELDNAME = 'Additional_Feedback_';
    private static final String QUESTIONTYPE_FIELDNAME = 'Question_Type_';
    private static final String ANSWER_FIELDNAME = 'Answer';
    private static final String PREFIX_QUERY =' SELECT ID, Active__c, Name, Topic__c, Campaign__c, ';
    private static final String SUFFIX_QUERY =' from surveyMaster__c';
    public List<QuestionWrapper> QuestionWrapperList {get;set;}

    public static RecordType CompletedSurvey {get{
        if(CompletedSurvey==null){
                CompletedSurvey = [SELECT id,Name FROM RecordType 
                                 WHERE Name='NPS Survey Complete' 
                                 AND sObjectType='Survey__c' LIMIT 1];
            }
        return CompletedSurvey;
    }set;}


    public static RecordType SurveyRecordType {get{
        if(SurveyRecordType==null){
                SurveyRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='NPS Survey' 
                                 AND sObjectType='Survey__c' LIMIT 1];
            }
        return SurveyRecordType;
    }set;}

       public static RecordType CompletedRecordType {get{
        if(CompletedRecordType ==null){
           CompletedRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Completed' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CompletedRecordType;
    }set;}




    public Map<ID,SurveyMaster__c> surveyMasterMap = new Map<Id,SurveyMaster__c>();
    public class QuestionWrapper{
        public  Integer SEQ {get;set;}
        public  String Question {get;set;}
        public  String QuestionType {get;set;}
        public  boolean AdditionalFlag {get;set;}
        public  String AdditionalValue {get;set;}
        public  List<SelectOption> possibleAnswerlist {get;set;}
        public  List<String> StringAnswersList {get;set;}
        public  String SelectedAnswer {get;set;}
        public  List<SelectOption> SelectOptionAnswer {get;set;}
    }
    
    public void SelectedSurveyMaster(){
        System.debug(surveyID);
        QuestionWrapperList = new List<QuestionWrapper>();
        if(surveyID !='None'){
             Sobject selectedSM = surveyMasterMap.get(surveyID);
        //QuestionWrapperList
        Integer SEQrunning = 1;
		System.debug('>>>>>> selectedSM: '+selectedSM);
        System.debug(String.valueof(selectedSM.get('Topic__c')));
        tempSurveyDetail.Topic__c = String.valueof(selectedSM.get('Topic__c'));
            
             for(integer i=1;i<=MAXIMUM_NO_OF_QUESTIONS;i++){
                 String question = String.valueof(selectedSM.get(QUESTION_FIELDNAME+i+'__c'));
                 String questionType = String.valueof(selectedSM.get(QUESTIONTYPE_FIELDNAME+i+'__c'));
                                                      
                 if( question!=null && question!='' && 
                    questionType!=null && questionType !=''){
                        QuestionWrapper qw = new QuestionWrapper();
                        qw.seq = SEQrunning;

                        String questionbreakline = question.replace('\n', '<br />');

                        System.debug(questionbreakline);
                        qw.Question = questionbreakline;
                        qw.QuestionType = questionType;
                        qw.AdditionalFlag = Boolean.valueof(selectedSM.get(ADDITIONAL_FIELDNAME+i+'__c'));
                        qw.SelectedAnswer = '';
                        List<SelectOption> possileSelectAnswerList = new List<SelectOption>();
                        List<String> possileStringAnswerList = new List<String>();



                        qw.AdditionalValue = String.valueof(tempSurveyDetail.get(ADDITIONAL_ANSWER_FIELDNAME+i+'__c'));
                        
                            for(integer j=1;j<=MAXIMUM_NO_OF_ANSWERS;j++){
                                String answerOption = String.valueof(selectedSM.get(ANSWER_FIELDNAME+i+'_'+j+'__c'));
                                
                                if(questiontype=='Picklist' && j==1){
                                    possileSelectAnswerList.add(new SelectOption('None','--None--'));
                                }
                                
                                if(answerOption!=null && answerOption !=''){
                                    if(questiontype=='Check box' || questiontype=='Picklist' || questiontype=='Multi picklist'){

                                        answerOption = answerOption.replace('\r\n','');

                                        

                                        if(isExisting && questiontype =='Multi picklist'){

                                            String existingAnswer = String.valueof(tempSurveyDetail.get(ANSWER_FIELDNAME+i+'__c'));
                                            Set<String> existingAnswerSet = new set<String>();
                                            System.debug('answerOption :'+answerOption);

                                            if(existingAnswer !=null && existingAnswer !=''){
                                                    System.debug('existing has answers');
                                                if(existingAnswer.contains(';')){
                                                    for(String splitanswer : existingAnswer.split(';')){

                                                           if(splitanswer !='None'){
                                                            System.debug('add to eixsting');
                                                                existingAnswerSet.add(splitanswer.trim());
                                                           }
                                                    }   

                                                }else{
                                                    System.debug('add to eixsting');
                                                        if(existingAnswer !='None'){
                                                            existingAnswerSet.add(existingAnswer.trim());
                                                        }
                                                }


                                                    if(!existingAnswerSet.contains(answerOption)){
                                                        System.debug('add new no dup with existing');
                                                        possileSelectAnswerList.add(new SelectOption(answerOption.trim(),answerOption.trim()));
                                                    }
                                            }else{
                                                 System.debug('deadlock');
                                                possileSelectAnswerList.add(new SelectOption(answerOption.trim(),answerOption.trim()));
                                            }

                                           


                                        }else{
                                            
                                            System.debug('not existing multi picklist');
                                            //Fix Support Case No.00010217
                                            String strAns = ConvertAnswer(answerOption.trim());
                                            possileSelectAnswerList.add(new SelectOption(strAns,strAns));
                                            //possileSelectAnswerList.add(new SelectOption(answerOption.trim(),answerOption.trim()));
                                        }

                                }else{
                                        System.debug('else');
                                        possileStringAnswerList.add(answerOption);
                                }
                            }
                        }

                            if(questiontype=='Multi picklist'){
                                System.debug(possileSelectAnswerList);
                            }

                            if( questiontype=='Rating (0-10)'){
                                //possileSelectAnswerList.add(new SelectOption('None','--None--'));
                                for(integer k=0;k<=10;k++){
                                 possileSelectAnswerList.add(new SelectOption(k+'',k+''));
                                }
                            }

                        if(questiontype=='Check box'|| questiontype=='Picklist'|| questiontype=='Multi picklist'|| questiontype=='Rating (0-10)' ){
                            qw.possibleAnswerlist = possileSelectAnswerList;

                            qw.SelectOptionAnswer = new List<SelectOption>();




                            if(isExisting){
                                     String existingAnswer = String.valueof(tempSurveyDetail.get(ANSWER_FIELDNAME+i+'__c'));

                                if(questiontype=='Picklist' || questiontype=='Rating (0-10)' || questiontype =='Check box'){
                                    qw.SelectedAnswer = existingAnswer;

                                }else if(questiontype=='Multi picklist'){
                                    


                                    if(existingAnswer !=null){
                                        if(existingAnswer.contains(';')){
                                        for(String splitanswer : existingAnswer.split(';')){
                                             if(splitanswer !='None'){
                                                   qw.SelectOptionAnswer.add(new SelectOption(splitanswer,splitanswer));
                                            }
                                            
                                         }   

                                        }else{
                                            if(existingAnswer !='None'){
                                             qw.SelectOptionAnswer.add(new SelectOption(existingAnswer,existingAnswer));
                                            }
                                        }
                                    }



                                    
                                }
                            }


                        }else{
                            if(isExisting){
                                qw.SelectedAnswer =  String.valueof(tempSurveyDetail.get(ANSWER_FIELDNAME+i+'__c'));
                            }
                           
                            qw.StringAnswersList = possileStringAnswerList;
                        }
                        QuestionWrapperList.add(qw);
                        SEQrunning++;
                 }
                }
        
        }
        
    }


    public Survey__c SurveysObject {get;set;}
    public NPSSurveyController(ApexPages.StandardController controller){
       SurveysObject = (Survey__c) controller.getRecord();
    }

    public PageReference redirectProxy(){
        PageReference page = new PageReference('/apex/NPS_Survey?id='+SurveysObject.id);
        page.setRedirect(true);
        return page;
    }
    

    public NPSSurveyController()
    { 
        isLead  =false;
        isAccount  = false; 
        isExisting = false;
        isCompleteSurvey = false;
        isShowResultScreen = false;
        isAlreadyComplete = false;
        isFilterbyCampaign = false;
        isCompleteLead = false;
        isCancel = false;
        //Boolean Flag to indicate Lead.Primary_Campaign__c is NULL or not
        Boolean isPrimaryCampaignNULL_ForEditSurvey = false;
        Boolean isPrimaryCampaignNULL_ForNewSurvey = false;
        tempSurveyDetail = new survey__c();
        surveyId = '';

       String SobjectID = apexpages.CurrentPage().getParameters().get('id');
       CompleteScreenflag = apexpages.CurrentPage().getParameters().get('isComplete');
        if(sObjectID!=null && sObjectID!=''){
                String checksObjectType = SobjectId.substring(0,3);
            System.debug(checksObjectType);

            if(CompleteScreenflag !=null && CompleteScreenflag!=''){
                if(CompleteScreenflag =='true'){
                    isShowResultScreen = true;
                }
            }
            
            
            
            if(checksObjectType =='001'){
                isAccount = true;
                isPrimaryCampaignNULL_ForNewSurvey = true;
                 list<Account> acctlist = [select id,name,Customer_Segment_Team__c  from Account where id =:sObjectID ];
                 if(acctlist.size()>0){
                    tempAccount = acctlist.get(0);
                    tempSurveyDetail.Customer__c = tempAccount.id;
                    customerSegmentTeam = tempAccount.Customer_Segment_Team__c;


                 }
            }else if(checksObjectType =='00Q'){
                    list<lead> listLead = [select id,name,status,Phone__c,Account__c,Account__r.Customer_Segment_Team__c,Primary_Campaign__c,Contacted_Flag__c,RecordtypeID  from lead where id =:sObjectID ];
                    if (listLead.size() > 0){
                    isLead = true;
                    tempLead = listLead.get(0); 
                    System.debug(templead);
                    tempSurveyDetail.Lead__c = templead.id;
                    tempSurveyDetail.Campaign__c = templead.Primary_Campaign__c;

                    tempSurveyDetail.Contact_Name__c = templead.name;
                    tempSurveyDetail.Contact_Phone__c = templead.Phone__c;

                    if(tempLead.Account__c !=null){
                        tempSurveyDetail.Customer__c = tempLead.Account__c;
                        customerSegmentTeam = tempLead.Account__r.Customer_Segment_Team__c;
                        isAccount = true;
                    }

                    if(templead.RecordtypeID == CompletedRecordType.id){
                        isCompleteLead = true;
                    }

                    if(templead.Primary_Campaign__c !=null){
                        campaignID = tempLead.Primary_Campaign__c;
                        isFilterbyCampaign = true;
                    }
                    //Added By: Siwapongsakorn Dechapisood
                    //Added Date: 07/Jan/2019
                    //Company: I&I Consulting
                    //Description: Add below code to filter only Active Survey Master 
                    // When a lead record doesn't have a primary campaign
                    else
                    {
                    	isPrimaryCampaignNULL_ForNewSurvey = true;
                    } 
                }
            }else{
                tempSurveyDetail = [SELECT Additional_Feedback_1__c,Additional_Feedback_2__c,
                Additional_Feedback_3__c,Additional_Feedback_4__c,Additional_Feedback_5__c,Additional_Feedback_6__c,
                Additional_Feedback_7__c,Additional_Feedback_8__c,Additional_Feedback_9__c,Additional_Feedback_10__c,
                Additional_Feedback_11__c,Additional_Feedback_12__c,Additional_Feedback_13__c,Additional_Feedback_14__c,
                Additional_Feedback_15__c,Additional_Feedback_16__c,Additional_Feedback_17__c,Additional_Feedback_18__c,
                Additional_Feedback_19__c,Additional_Feedback_20__c,Answer1__c,Answer2__c,Answer3__c,Answer4__c,Answer5__c,
                Answer6__c,Answer7__c,Answer8__c,Answer9__c,Answer10__c,Answer11__c,Answer12__c,Answer13__c,Answer14__c,
                Answer15__c,Answer16__c,Answer17__c,Answer18__c,Answer19__c,Answer20__c,Call_Date_Time__c,Campaign__c,Contact_Name__c,Contact_phone__c,
                Customer__c,Id,Lead__c,NPS_Question_1_Result__c,NPS_Question_2_Result__c,NPS_Question_3_Result__c,
                NPS_Question_4_Result__c,NPS_Question_5_Result__c,Question1__c,Question2__c,Question3__c,Question4__c,Question5__c,
                Question6__c,Question7__c,Question8__c,Question9__c,Question10__c,Question11__c,Question12__c,
                Question13__c,Question14__c,Question15__c,Question16__c,Question17__c,Question18__c,Question19__c,Question20__c,
                RecordTypeId,Result__c,SurveyMaster__c,Topic__c,Customer__r.Customer_Segment_Team__c FROM Survey__c WHERE ID =:SobjectID LIMIT 1];
                surveyId = tempSurveyDetail.SurveyMaster__c;
                System.debug('existing surveyId: '+surveyId);
                isExisting = true;
                customerSegmentTeam = tempSurveyDetail.Customer__r.Customer_Segment_Team__c;
                if(tempSurveyDetail.Lead__c !=null){

                    templead = [select id,isconverted,name,RecordtypeID,status,ConvertedAccountId,Phone__c,Account__c,Account__r.Customer_Segment_Team__c,Primary_Campaign__c,Contacted_Flag__c  from lead where id =:tempSurveyDetail.Lead__c  LIMIT 1 ];
                    if(templead.RecordtypeID == CompletedRecordType.id){
                        isCompleteLead = true;
                    }

                    if(!templead.isConverted){
                        isLead = true;
                    }else{
                        isAccount = true;
                        tempSurveyDetail.Customer__c = templead.ConvertedAccountId;
                    }
                    
                    //Added By: Siwapongsakorn Dechapisood
                    //Added Date: 04/Jan/2019
                    //Company: I&I Consulting
                    //Fix issue when any user edit a Survey record related to a Lead record
                    //Below condition check if when any user edit a survey record
                    if(checksObjectType =='a2J')
                    {
                        if(templead.Primary_Campaign__c != null)
                        {
                            campaignID = tempLead.Primary_Campaign__c;
                            isFilterbyCampaign = true;
                        }
                        //In case of a Lead record deosn't has a Primary Campaign and it should set WHERE condition
                        //to query Survey Master record with Survery__c.SurveyMaster__c
                        //This Boolean Flag code will use to check condtion in Line 449  
                        else
                        {
                            isPrimaryCampaignNULL_ForEditSurvey = true;
                        }
                    }

                }else if(tempSurveyDetail.Customer__c !=null){
                    isAccount = true;
                    //Added By: Siwapongsakorn Dechapisood
                    //Added Date: 14/Jan/2019
                    //Company: I&I Consulting
                    //Fix issue when any user try to edit existing survery record
                    isPrimaryCampaignNULL_ForEditSurvey = true;
                    tempAccount = [select id,name  from Account where id =: tempSurveyDetail.Customer__c LIMIT 1];
                }


                if(tempSurveyDetail.RecordTypeID == CompletedSurvey.id){
                    isAlreadyComplete = true;
                     //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot edit a completed survey.'));
                     ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6201').Status_Message__c));
                }else if(isCompleteLead){
                    //isAlreadyComplete = true;
                    // ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Lead is already completed. Unable to edit survey.'));

                     
                       // tempSurveyDetail.Result__c = 'Completed';
                }
                
            }
            
        }

        QuestionWrapperList = new List<QuestionWrapper>();
        //Merge query string
        //
        String queryString = PREFIX_QUERY;
            
        //All questions
        for(integer i=1;i<=MAXIMUM_NO_OF_QUESTIONS;i++){
            queryString += ' '+QUESTION_FIELDNAME+i+'__c,';
            
        }
        //
            
        //All question types
        for(integer i=1;i<=MAXIMUM_NO_OF_QUESTIONS;i++){
            queryString += ' '+QUESTIONTYPE_FIELDNAME+i+'__c,';
            
        }
        //
            
        //All Possible Answers
        for(integer i=1;i<=MAXIMUM_NO_OF_QUESTIONS;i++){
            for(integer j=1;j<=MAXIMUM_NO_OF_ANSWERS;j++){
                queryString += ' '+ANSWER_FIELDNAME+i+'_'+j+'__c,';
            } 
        }
        //
            
        //All Additional FeedBack Required
        for(integer i=1;i<=MAXIMUM_NO_OF_QUESTIONS;i++){
            queryString += ' '+ADDITIONAL_FIELDNAME+i+'__c,';
            
        }
        //
        //
        queryString = queryString.substring(0,queryString.length()-1);
        queryString += SUFFIX_QUERY;
        
        Set<String> SurveyMasterIDset = new Set<String>();
        if(isFilterbyCampaign)
        {
            for(Campaign_Survey_Master__c csurvy : [SELECT ID,Survey_Master__c,Survey_Master__r.id,Campaign__c from Campaign_Survey_Master__c WHERE Campaign__c =:campaignID]){
                SurveyMasterIDset.add(csurvy.Survey_Master__r.id);
            }
            
            //queryString +=' WHERE Campaign__c =:campaignID ';
            queryString +=' WHERE ID IN: SurveyMasterIDset ';
            
        }
        //Added By: Siwapongsakorn Dechapisood
        //Added Date: 04/Jan/2019
        //Company: I&I Consulting
        //In case of a Lead record deosn't has a Primary Campaign and it should set WHERE condition
        //to query Survey Master record with Survery__c.SurveyMaster__c
        else if(isFilterbyCampaign == FALSE && isPrimaryCampaignNULL_ForEditSurvey == TRUE)
        {
            queryString +=' WHERE ID =: surveyId ';
        }
        else if(isFilterbyCampaign == FALSE && isPrimaryCampaignNULL_ForNewSurvey == TRUE)
        {
            queryString +=' WHERE Active__c = true ORDER BY CreatedDate DESC LIMIT 200';
        }
        
        System.debug('query String : '+queryString);
        //
        //
        
        ListQuestion = new List<SelectOption>();
        List<Sobject> surveyMasterListsObj = new List<Sobject>();
        ListQuestion.add(new SelectOption('None','--None--'));
        List<Sobject> smList = new List<Sobject>();
        List<String> surveyMasterIDs = new List<String>();   

        Map<String,Sobject> allsurveyMasterMap = new Map<String,Sobject>();     
        for(Sobject sm : Database.query(queryString)){
           surveyMasterIDs.add(String.valueof(sm.get('ID')));
           allsurveyMasterMap.put(String.valueof(sm.get('ID')),sm);
        }

        for(UserRecordAccess UserRA : [SELECT RecordId, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                     FROM UserRecordAccess
                                     WHERE UserId =: Userinfo.getUserID()
                                     AND RecordId IN: surveyMasterIDs]){
            if(UserRA.HasReadAccess){
                smList.add(allsurveyMasterMap.get(UserRA.RecordId));
            }
        }

        for(sObject sm : smList){
             surveyMaster__c smobj = (surveyMaster__c)sm;
            if(smobj.Active__c){
                ListQuestion.add(new SelectOption(smobj.ID,smobj.Name));
            }
            surveyMasterMap.put(smobj.ID,smobj);
        }

        if(tempSurveyDetail.id ==null){
            tempSurveyDetail.Call_Date_Time__c = System.now();
        }

        if(tempSurveyDetail.id !=null){
            SelectedSurveyMaster();
        }
        
    }


    public PageReference completesurvey(){
        isCompleteSurvey = true;
        tempSurveyDetail.Completed_Date_Time__c = system.now();
        
        //return dosave();
        return dosave();
    }

    public PageReference completesurveyFromCSV(){

        if(tempSurveyDetail.Result__c ==null){
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Result is required.'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6202').Status_Message__c));
             return null;
        }else{
            tempSurveyDetail.RecordTypeID = CompletedSurvey.id;       
                        

                update tempSurveyDetail;

            // return cancel();
            isCancel = true;
            return null;

        }

        
    }
    
    public PageReference dosave(){


        if(surveyID ==null || surveyID=='None'){
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Master-Topic Question is required.'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6203').Status_Message__c));
             return null;

        }else if(!isExisting){
            tempSurveyDetail.SurveyMaster__c = surveyID;
            //tempSurveyDetail.RecordTypeID = CompletedSurvey.id;
        }

        if(tempSurveyDetail.SurveyMaster__c ==null){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6203').Status_Message__c));
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Master-Topic Question is required.'));
             return null;
        }else{

            try{

                        System.debug(isCompleteSurvey);
                        System.debug(isExisting);


                      
                            tempSurveyDetail.RecordTypeID = SurveyRecordType.id;
                        

                            sObject surveySobject = tempSurveyDetail;

                            if(isExisting){
                                surveySobject.put('ID',tempSurveyDetail.id);
                            }




                            for(QuestionWrapper qw : QuestionWrapperList){
                                
                                surveySobject.put(QUESTION_FIELDNAME+qw.SEQ+'__c',qw.Question);
                                surveySobject.put(ADDITIONAL_ANSWER_FIELDNAME+qw.SEQ+'__c',qw.AdditionalValue);
                               
                                
                                if(qw.QuestionType=='Picklist' || qw.QuestionType=='Free Text' || qw.QuestionType=='Check box' || qw.QuestionType=='Rating (0-10)'){
                                    surveySobject.put(ANSWER_FIELDNAME+qw.SEQ+'__c',qw.selectedAnswer);
                                }else if(qw.QuestionType=='Multi picklist'){
                                    String multianswers ='';
                                    
                                    if(qw.SelectOptionAnswer !=null && qw.SelectOptionAnswer.size()>0){
                                       for(SelectOption so : qw.SelectOptionAnswer){
                                            multianswers +=' '+so.getValue()+';';
                                        }
                                        multianswers = multianswers.substring(0, multianswers.length()-1);
                                        System.debug('multianswers : '+multianswers);
                                        surveySobject.put(ANSWER_FIELDNAME+qw.SEQ+'__c',multianswers);
                                         
                                    }


                                }



                            }




                                database.upsert(surveySobject, true);

                                System.debug('temp lead : '+tempLead);

                                if(!isExisting && isFilterbyCampaign){
                                Campaign_Survey__c camsur = new Campaign_Survey__c();
                                camsur.Campaign__c = campaignID;
                                camsur.Survey__c = (ID)surveySobject.get('ID');
                                insert camsur;

                                }

                                if(isLead){
                                    if(tempLead.Contacted_Flag__c == false){
                                        tempLead.Status = 'Contacted';
                                    }
                                    tempLead.Contacted_Flag__c = true;
                                    update templead;
                                }





                            if(isCompleteSurvey && isLead){
                                 PageReference sObjectDetail;
                                sObjectDetail = new PageReference('/apex/NPS_Survey_Convert?id='+tempSurveyDetail.Lead__c+'&surveyID='+tempSurveyDetail.id);
                                sObjectDetail.setRedirect(true);          
                                return sObjectDetail; 
                            }else if(isCompleteSurvey && isAccount){
                                    isShowResultScreen =true;
                                    return null;
                            }else{
                                //  return cancel();
                                isCancel = true;
                                return null;
                            }
                }catch(Exception ex){
            
                   
                    System.debug('line : '+ex.getLineNumber());
                    System.debug('errormessage : '+ex.getMessage());
                
                 System.debug(ex.getMessage());
                 ApexPages.getMessages().clear();
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
                 return null;
            }
        }

    }


    public PageReference cancel(){
         PageReference sObjectDetail;
        
        if(isExisting){
            /*System.debug('existing : ');
            System.debug(' '+tempSurveyDetail.Customer__c);

            if(isLead){
                sObjectDetail = new PageReference('/'+tempSurveyDetail.Lead__c);
            }else if(isAccount){
                sObjectDetail = new PageReference('/'+tempSurveyDetail.Customer__c);
            }*/

            sObjectDetail = new ApexPages.StandardController(tempSurveyDetail).view();



        }else if(isLead){
            sObjectDetail = new ApexPages.StandardController(tempLead).view();
        }else if(isAccount){
            sObjectDetail = new ApexPages.StandardController(tempAccount).view();
        
        }
        sObjectDetail.setRedirect(true);          
        return sObjectDetail; 
    }

    
    private String ConvertAnswer(String answer) {

        List<string> strAnswerList = answer.split(' ');
        
        Map<Integer,String> answerMap = new Map<Integer,String>();
        
        for (Integer i = 0; i < strAnswerList.size(); i++)
        {
            String lastAns = (i == 0) ? '' : strAnswerList[i - 1];
            
            if (lastAns != '') {
                answerMap.put(i, ' ' + strAnswerList[i]);
            }
            else {
                answerMap.put(i, strAnswerList[i]);
            }
        }
        
        String strResult = '';
        
        for(Integer idValue : answerMap.keyset())
        {
            strResult += answerMap.get(idValue);
        }
                
        return strResult; 
    }
    
}