public with sharing class CreateContacUnderAccountProxy {
	public  Account account;
    private ApexPages.StandardController standardController;	
    public CreateContacUnderAccountProxy(ApexPages.StandardController controller){
        standardController = controller;        
        account = (Account)standardController.getRecord();
    }    
    /*public  PageReference NextPage(){   
        // redirect to search screen
       PageReference result=Page.ContactCreationMobileLayoutV3;
       result.getParameters().put('accid', account.Id);      
       result.setRedirect(true); 
       return result;  
    }*/

    public PageReference redirectMobile(){
      return new PageReference('/apex/ContactCreationMobileLayoutV3?accid='+account.Id);
    }

    public PageReference redirectPage(){
      return new PageReference('/apex/ContactCreationV3?accid='+account.Id);
    }
}