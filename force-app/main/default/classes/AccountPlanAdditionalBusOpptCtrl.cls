public with sharing class AccountPlanAdditionalBusOpptCtrl {	
	//Property
	 public String WalletID {get;set;}	 
	 public List<QuestionnaireService.BusinessOppInfo> lstBussOppt {get;set;} 
	 
	 //Constructure
	 public AccountPlanAdditionalBusOpptCtrl(){         
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');        
        lstBussOppt = QuestionnaireService.getQuestionairByWalletId(WalletID); 
        
        system.debug('::::::: SIZE ' + lstBussOppt.size());     
	 }
    
}