public class VisitReportOpportunityTriggerHandler {

    private static Set<Id> customerIdSet { 
        get;
        set;
    }

    public static Map<Id, Visit_Report_Opportunity__c> visitReportOpportunityMap {
        get{
            if(visitReportOpportunityMap == null){
                visitReportOpportunityMap = new Map<Id, Visit_Report_Opportunity__c>([select Customer__c, Opportunity__c from Visit_Report_Opportunity__c where Customer__c = :customerIdSet]);
            }
            return visitReportOpportunityMap;
        }
        set;
    }

    public static void checkDuplicate(list<Visit_Report_Opportunity__c> listNewObject, list<Visit_Report_Opportunity__c> listOldObject)
    {
        list<Visit_Report_Opportunity__c> listObject = new list<Visit_Report_Opportunity__c>();
        set<string> setOldObject = new set<string>();
        
        for (Visit_Report_Opportunity__c v : listOldObject)
        {
            setOldObject.add(string.valueof(v.id)+string.valueof(v.Customer__c)+string.valueof(v.Opportunity__c));
        }
        
        for (Visit_Report_Opportunity__c v : listNewObject)
        {
            if (!setOldObject.contains(string.valueof(v.id)+string.valueof(v.Customer__c)+string.valueof(v.Opportunity__c)))
                listObject.add(v);
        }
        
        set<string> checkInputDup = new set<string>();
        set<id> listCustomerId = new set<id>();
        for (Visit_Report_Opportunity__c v : listObject)
        {
            if (checkInputDup.contains(string.valueof(v.Customer__c)+string.valueof(v.Opportunity__c)))
                listNewObject.get(0).addError(status_code__c.getValues('8014').status_message__c);
            else
                checkInputDup.add(string.valueof(v.Customer__c)+string.valueof(v.Opportunity__c));
            listCustomerId.add(v.Customer__c);
        }
        customerIdSet = listCustomerId;
        for (Visit_Report_Opportunity__c v : visitReportOpportunityMap.values())
        {
            if (checkInputDup.contains(string.valueof(v.Customer__c)+string.valueof(v.Opportunity__c)))
                listNewObject.get(0).addError(status_code__c.getValues('8014').status_message__c);
        }
        
    }


}