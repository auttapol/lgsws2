public with sharing class LogACallUnderAccountProxy {
   public sObject obj{get;set;}
    private ApexPages.StandardController standardController;    
    public LogACallUnderAccountProxy(ApexPages.StandardController controller){
        standardController = controller;        
        obj = (SObject)standardController.getRecord();
    }     
    public  PageReference NextPage(){   
    system.debug(obj.getSObjectType());
    system.debug(obj.Id);
        if(String.valueof(obj.getSObjectType()) =='Contact'){
            ////////////old redirect//////////////
            PageReference result = Page.LogACallMobileLayout;
            Contact Con = [SELECT ID,AccountID from Contact WHERE ID =: obj.id LIMIT 1];
            result.getParameters().put('what_id',Con.AccountID);
            result.getParameters().put('who_id',Con.Id);
            result.setRedirect(true); 
            ///////////new redirect/////////////
            string url ='/';
            url = '/apex/LogACallMobileLayout';
            url+='?what_id='+Con.AccountID;
            url+='&who_id='+ Con.Id;
            PageReference page = new PageReference(url);
            page.setRedirect(true);
        return page;  
                  
        }else if(String.valueof(obj.getSObjectType()) =='Account'){
            ////////////old redirect//////////////
            PageReference result2 =Page.LogACallMobileLayout;
            result2.getParameters().put('what_id',obj.Id);
            result2.setRedirect(true);
            ///////////new redirect/////////////
            string url ='/';
            url = '/apex/LogACallMobileLayout';
            url+='?what_id='+obj.Id;
            PageReference page = new PageReference(url);
            page.setRedirect(true);
        return page;  
        }else  if(String.valueof(obj.getSObjectType()) =='Opportunity'){
            ////////////old redirect//////////////
            PageReference result3 =Page.LogACallMobileLayout;
            result3.getParameters().put('what_id',obj.Id);
            result3.setRedirect(true); 
            ///////////new redirect/////////////
            string url ='/';
            url = '/apex/LogACallMobileLayout';
            url+='?what_id='+obj.Id;
            PageReference page = new PageReference(url);
            page.setRedirect(true);
        return page;  
        }else if(String.valueof(obj.getSObjectType()) == 'Lead'){
            ////////////old redirect//////////////
            PageReference result4 =Page.LogACallMobileLayout;
            result4.getParameters().put('who_id',obj.Id);
            result4.setRedirect(true); 
            ///////////new redirect/////////////
            string url ='/';
            url = '/apex/LogACallMobileLayout';
            url+='?who_id='+ obj.Id;
            PageReference page = new PageReference(url);
            page.setRedirect(true);
        return page; 
        }else if(String.valueof(obj.getSObjectType()) == 'RTL_Referral__c'){
            ////////////old redirect//////////////
            PageReference result5 =Page.LogACallMobileLayout;
            result5.getParameters().put('what_id',obj.Id);
            result5.setRedirect(true); 
            ///////////new redirect/////////////
            string url ='/';
            url = '/apex/LogACallMobileLayout';
            url+='?what_id='+ obj.Id;
            PageReference page = new PageReference(url);
            page.setRedirect(true);
        return page; 
        }
       return null;
    }
}