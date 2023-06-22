public with sharing class submitToEOnBoardingButtonController {

    public Id recID {get; set;}

    public String RecordtypeToUpdate = 'Non-credit Product2';

    public Boolean submitPass {
        get{
            submitPass = false;
            if(ThisOpty != null){
                System.debug('This Oppty : ' + ThisOpty);
                System.debug('This Account : ' + ThisAccount);

                // Boolean cond1 = ThisAccount.TMB_Customer_ID_PE__c == null;
                Boolean cond2 = ThisAccount.Customer_Type__c == 'Individual';
                Boolean cond3 = ThisAccount.ID_Type_PE__c == 'Citizen ID';
                Boolean cond4 = ThisAccount.ID_Number_PE__c != null;
                
                Boolean fag = (cond2 && cond3 && cond4);

                if(fag){
                    submitPass = true;
                }else{
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.submit_f2f_errmsg));
                }
            }
            return submitPass;
        }

        set;
    }
    
    public Account ThisAccount {
        get{
            if(ThisAccount == null){
                if(ThisOpty != null){
                    ThisAccount = [SELECT Id, TMB_Customer_ID_PE__c, ID_Type_PE__c, ID_Number_PE__c, Customer_Type__c FROM Account WHERE Id = :ThisOpty.AccountId LIMIT 1];
                    System.debug('This Account :: ' + ThisAccount);
                }
            }
            return ThisAccount;
        }
        set;
    }

    public Opportunity ThisOpty {
        get{
            if(ThisOpty == null){
                try {
                    ThisOpty = [SELECT Id, RTL_TMB_Customer_ID_PE__c, AccountId, StageName, RecordtypeId, Host_System__c FROM Opportunity WHERE Id = :recID LIMIT 1];
                    System.debug('ThisOpty :: ' + ThisOpty);
                } catch (Exception e) {
                   System.debug(e.getMessage());
                   return null;
                }
            }
            return ThisOpty;
        }
        set;
    }

    public void ValidateEBoarding(){
        System.debug('Opportunity Id : ' + recID);
        System.debug(ThisOpty);

        if(submitPass){
            try {
                Id nonCrProd2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordtypeToUpdate).getRecordTypeId();

                ThisOpty.StageName = 'Submitted to e-onBoarding';
                ThisOpty.RecordtypeId = nonCrProd2;
                ThisOpty.Host_System__c = 'F2F';

                update ThisOpty;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public Pagereference optyPage(){
        return new PageReference('/' + recID).setRedirect(true);
    }

    public submitToEOnBoardingButtonController(ApexPages.StandardController ctrl) {
        recID = ApexPages.currentPage().getParameters().get('Id');
    }
}