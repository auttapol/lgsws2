public class SurveyQuestionWrapper {
	@AuraEnabled
    public Survey_Question__c question {get;set;}
    @AuraEnabled
    public List<SurveyManagerController.choiceWrapper> choiceList {get;set;}
    @AuraEnabled
    public List<SurveyQuestionWrapper> subQuestionList {get;set;}
    @AuraEnabled
    public String gridTitleStyleClass {get;set;}
    @AuraEnabled
    public String gridChoiceStyleClass {get;set;}

    public Map<ID,SurveyManagerController.choiceWrapper> choiceMap {get;set;}
    public List<SurveyManagerController.choiceWrapper> getChoiceList()
    {
    	if( choiceMap != null )
    	{
    		return choiceMap.values();
    	}
    	else 
    	{
    		return null;	
    	}
    }

    public Map<ID,SurveyQuestionWrapper> subQuestionMap {get;set;}
    public List<SurveyQuestionWrapper> getSubQuestionList()
    {
    	if( subQuestionMap != null )
    	{
    		return subQuestionMap.values();
    	}
    	else 
    	{
    		return null;	
    	}
    }
    
    public String genTitleGridStyleClass()
    {
    	if( question != null )
    	{
    		if( question.Choice_Render_Type__c == 'Choice Render Below' )
    		{
    			return 'slds-size_' + question.Question_Grid_Size__c + '-of-' + question.Question_Grid_Size__c ;
    		}
    		else if ( question.Choice_Render_Type__c == 'Choice Render On Right' )
    		{
    			return 'slds-size_'+ (question.Question_Grid_Size__c - 1) +'-of-' + question.Question_Grid_Size__c ;
    		}
    		else 
    		{
    			return 'slds-size_1-of-1' ;
    		}
    		
    	}
    	else 
    	{
    		return 'slds-size_1-of-1';	
    	}
    }

    public String genChoiceGridStyleClass()
    {

    	if( question != null )
    	{
    		if( question.Choice_Render_Type__c == 'Choice Render Below' )
    		{
    			return 'slds-size_' + question.Question_Grid_Size__c + '-of-' + question.Question_Grid_Size__c ;
    		}
    		else if ( question.Choice_Render_Type__c == 'Choice Render On Right' )
    		{
    			return 'slds-size_1-of-' + question.Question_Grid_Size__c ;
    		}
    		else 
    		{
    			return 'slds-size_1-of-1' ;
    		}
    		
    	}
    	else 
    	{
    		return 'slds-size_1-of-1';
    	}
    }
}