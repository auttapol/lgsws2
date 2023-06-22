global  without sharing   class QuestionnaireSelector {
	
	 // SOQL Statement
    public static string sqlSelectQuestionairByWalletIds(){
        return   'SELECT 	'
				+'		AcctPlanWallet__c,Segment__c,Sub_Domain__c, Product_Label__c, SEQ__c,Sub_Segment_SEQ__c,Answer__c, Comment__c, CreatedById, CreatedDate, Id, isStandard__c,    ' 
				+'		Name, Opportunity__c, OptionBank__c, OptionFleetCard__c, OptionPercent__c, OptionText__c, Question__c,    '
				+'		Question_TH__c, QuestionnaireTag1__c, QuestionnaireTag2__c, QuestionnaireUniqueName__c   '
				+' FROM    '
				+'	AcctPlanQuestionnaire__c    '
				+' WHERE    '
				+'	Answer__c = \'Yes\' and Opportunity__c != null and Sub_Domain__c != null and Product_Label__c!= null   '
				+'	and AcctPlanWallet__c IN : walletIds   '
				+' ORDER BY    '
				+'	AcctPlanWallet__c, SEQ__c,Sub_Segment_SEQ__c    ';
    }
    
	public static string sqlSelectQuestionairTemplate(){
		return   'SELECT  Account_Plan_Page_Name__c,Sub_Domain__c, Product_Label__c, Answer_Field_Type__c, CreatedById, CreatedDate, Id, IsDeleted, LastModifiedById, LastModifiedDate     '
				+'		, LastReferencedDate, LastViewedDate, Name, Opportunity__c, OwnerId, Question__c, Question_TH__c, Segment__c   '
				+'		, SEQ__c, Sub_Segment__c, Sub_Segment_SEQ__c, SystemModstamp  '  
				+'FROM AcctPlan_Questionnaire_Template__c   '
				+'WHERE Sub_Domain__c!= null and Product_Label__c != null and Answer_Field_Type__c =\'Yes or No\' '
				+'ORDER BY Account_Plan_Page_Name__c ,Sub_Domain__c,Product_Label__c,SEQ__c';
	}
    //Selectors
    public static List<AcctPlan_Questionnaire_Template__c> SelectSelectQuestionairTemplate(){

        string sql = sqlSelectQuestionairTemplate();
        //system.debug('::: sql' + sql);
        return (List<AcctPlan_Questionnaire_Template__c>) Database.query(sql);
    }
    
    
	//Selectors
    public static List<AcctPlanQuestionnaire__c> SelectQuestionairByWalletIds(Set<ID> walletIds){


        if(walletIds == null || walletIds.size() < 1 )
            throw new QuestionnaireSelectorException('Set of walletIds  Cannot be null');
        string sql = sqlSelectQuestionairByWalletIds();
        //system.debug('::: sql' + sql);
        return (List<AcctPlanQuestionnaire__c>) Database.query(sql);
    }
    
    
     
    // Exception
    public class QuestionnaireSelectorException extends Exception{   
    }
	
}