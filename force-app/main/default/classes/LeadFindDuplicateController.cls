public class LeadFindDuplicateController {
    Lead leadRecord {get;set;}
    Lead oldLead {get;set;}
    Account acct {get;set;}
    public LeadFindDuplicateController(ApexPages.StandardController controller){
        leadRecord = (Lead)controller.getRecord();
        
        if(leadRecord !=null){
            oldLead = [SELECT Name,Phone,Rating,ID_Type__c,ID_Number__c FROM LEAD WHERE ID=: leadRecord.id];
        }
        acct = new account();
        acct.Name = oldLead.Name;
        acct.ID_Type_PE__c = oldLead.ID_Type__c;
        acct.ID_Number_PE__c = oldLead.ID_Number__c;
        
        List<account> acctlist = new List<Account>();
        List<account> oldacctList = new List<account>();
        acctlist.add(acct);
        boolean isDuplicated = DisqualifiedProcessBuilder.CheckDisqualifiedAction(acctlist,oldacctList,'insert');
        
        System.debug(isDuplicated);
    }
}