public class DomainIVQuestionnaireEdittableCtrl extends EditableList {
    
    public String walletId {get;set;}
    public String typeofFX {get;set;}
    public String TypeofQuestionnaire {get;set;}
    public boolean isBehavior {get;set;}
    public boolean isEXP {get;set;}
    public boolean isRisk {get;set;}
    public List<AcctPlan_Questionnaire_Template__c> InitiateQ {get;set;}
    public Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap {get;set;}
    public List<AcctPlanQuestionnaire__c> QuestionnaireList {get;set;}
    public List<AcctPlan_Questionnaire_Template__c> QTemplateList {get;set;}
    public Map<String,List<AcctPlan_Questionnaire_Template__c>> QTemplateMap;
    public DomainIVQuestionnaireEdittableCtrl(ApexPages.StandardController stdController) {
    super(stdController);
    walletId = ApexPages.currentPage().getParameters().get('walletid');
    typeofFX = ApexPages.currentPage().getParameters().get('type');
        isBehavior =false;
         isRisk =false;
         isEXP =false;
        
        if(typeofFX=='behavior'){
            isBehavior = true;
           TypeofQuestionnaire = 'FX Hedging Behavior';
        }else if(typeofFX=='exp'){
            isEXP = true;
           TypeofQuestionnaire = 'FX Hedging experience';
        }else if (typeofFX=='risk'){
            isRisk = true;
            TypeofQuestionnaire = 'Credit protection risk';
        }
        
        if(walletid !=null){
                QuestionnaireList = AccountPlanUtilities.QueryQuestionnaireByWalletID(walletid);
                //Collection all Questionnaires
                     for(AcctPlanQuestionnaire__c question : QuestionnaireList){
                         if(question.Segment__c ==TypeofQuestionnaire){
                           this.childList.add(question); 
                           
                         }
                     }
        
        
        //FX Hedging Behavior Questionnaire - Initiate
             
                
                  if(this.childList.size()==0){
                       QTemplateList = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain IV');
                        QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
                        QTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
                      
                      
                         for(AcctPlan_Questionnaire_Template__c QT : QTemplateList){
                                 String Segment = QT.Segment__c;
                                 if(QTemplateMap.containsKey(Segment)){
                                     QTemplateMap.get(Segment).add(qt);
                                 }else{
                                    List< AcctPlan_Questionnaire_Template__c>  QTList = new List< AcctPlan_Questionnaire_Template__c>();
                                     QTList.add(qt);
                                     QTemplateMap.put(Segment,QTList);
                                     
                                 }
                                 
                             }
                      for(AcctPlan_Questionnaire_Template__c qt : QTemplateMap.get(TypeofQuestionnaire)){
                          AcctPlanQuestionnaire__c question = new AcctPlanQuestionnaire__c ();
                          question.SEQ__c = qt.SEQ__c;
                          question.Question_TH__c = qt.Question_TH__C;
                          question.Question__c = qt.Question__c;
                          question.isStandard__c = true;
                          question.Opportunity__c = qt.Opportunity__c;
                          question.Segment__c = TypeofQuestionnaire;
                          question.AcctPlanWallet__c = walletid;
                          question.Product_Label__c = qt.Product_Label__c;
                          question.Sub_Domain__c = qt.Sub_Domain__c;
                          question.Sub_Segment_SEQ__c = qt.Sub_Segment_SEQ__c;
                          question.Answer_Type__c = qt.Answer_Field_Type__c;
                             
                          this.childList.add(question);
                         
                      }
                      
                  }

        }        
      
        
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanQuestionnaire__c > getChildren()
  {

    return (List<AcctPlanQuestionnaire__c >)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanQuestionnaire__c  child = new AcctPlanQuestionnaire__c ();
    // Can either use mysObject or acct here
    
    child.Segment__c = TypeofQuestionnaire;
    child.AcctPlanWallet__c = walletid;
    child.SEQ__c = getChildren().size()+1;
    return child;
  }
    
    
    public  void checkportion(){

        try{
       
            super.save();
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Save Successful.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }
    // Fix Refresh
    public override  void  refresh(){
          removeChildList.clear();
          childList.clear();
         
             QuestionnaireList = AccountPlanUtilities.QueryQuestionnaireByWalletID(walletid);
            for(AcctPlanQuestionnaire__c question : QuestionnaireList){
                if(question.Segment__c == TypeofQuestionnaire){
                        this.childList.add(question);  
                      }
            }

    }
    

}