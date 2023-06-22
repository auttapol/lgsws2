public class SearchProxyController {    
    public Account account;
    private ApexPages.StandardController standardController;	
    public SearchProxyController(ApexPages.StandardController controller){
        standardController = controller;        
        account = (Account)standardController.getRecord();
    }    
    public  PageReference NextPage(){   
        // redirect to search screen
        return Page.SearchProspectEx;      
    }
}