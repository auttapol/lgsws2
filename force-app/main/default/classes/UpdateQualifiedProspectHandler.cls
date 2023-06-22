public with sharing class UpdateQualifiedProspectHandler {
    public Account acc;
    public ApexPages.StandardController std;
    public String strResult{        
        get;set;
    }
    public String strCallFunc{        
        get;set;
    }
    
    public UpdateQualifiedProspectHandler(ApexPages.StandardController controller){
        acc = (Account)controller.getRecord();
        std = controller;
    }
    // Defualt Action When click Change State
    public void checkChangeAccountType(){
        List<Account> listAcc = [select Id,Account_Type__c from Account where Id = :acc.Id limit 1];
        Account ac = listAcc[0];
        if( ac.Account_Type__c != 'Qualified Prospect' ){
            changeAccountType();
        }else{
            callFunc('Qualified Prospect already exists');
        }
        
    }
    
    public void changeAccountType(){
    
        Map<Id,AggregateResult> listOpp = new Map<Id,AggregateResult>([select AccountId Id,count(id) counts
                                                                       from Opportunity 
                                                                       where AccountId = :acc.Id group by AccountId limit 200]);
        Map<Id,AggregateResult> listLogACall = new Map<Id,AggregateResult>([select AccountId Id,count(id) counts 
                                                                            from Task
                                                                            where Subject = 'Call' and AccountId = :acc.Id group by AccountId limit 200]);
        Map<Id,AggregateResult> listVisitReport = new Map<Id,AggregateResult>([select Customer_name__c Id,count(id) counts
                                                                               FROM Call_Report__c 
                                                                               WHERE Customer_name__c = :acc.Id group by Customer_name__c limit 200]);
        
        Integer countOpp = 0;
        Integer countLogACall = 0;
        Integer countVisitReport = 0;
        
        if( listOpp.containsKey(acc.Id) ){
            countOpp = (Integer)listOpp.get(acc.Id).get('counts');
        }
        if( listLogACall.containsKey(acc.Id) ){
            countLogACall = (Integer)listLogACall.get(acc.Id).get('counts');
        }
        if( listVisitReport.containsKey(acc.Id) ){
            countVisitReport = (Integer)listVisitReport.get(acc.Id).get('counts');
        }
        
        if( countOpp != 0 && ( countLogACall != 0 || countVisitReport  !=0) ){
            acc.Account_Type__c = 'Qualified Prospect';
            acc.Prospect_Converted_Date__c = Date.today();
            std.save();
            System.debug('::::: Converted Date Success : ' + Date.today()+' :::::');
            callFunc('Change to Qualified Prospect Success');
        }else{
            callFunc('Can\'t change to Qualified Prospect :<br/>'+
                     'Log a Call : '+countLogACall+' record<br/>'+
                     'Visit Plan / Report : '+countVisitReport+' record<br/>'+
                     'Opportuinity : '+countOpp+' record<br/>'
                    );
        }
          
        System.debug('::::: AccountId is : '+acc.Id+' Opp :' +countOpp+ ' , LogACall : '+countLogACall+' , VisitReport : '+countVisitReport+' :::::');
    }
    
    public void callFunc(String str){
        strResult = str;
        strCallFunc = '<script>checkResult(\'' +strResult+ '\');</script>';
    }
    
    public PageReference returnPage(){
        PageReference acctPage = new ApexPages.StandardController(acc).view();        
        acctPage.setRedirect(true);
        return acctPage;  
    }
}