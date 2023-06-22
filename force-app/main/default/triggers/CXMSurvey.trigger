trigger CXMSurvey on CXM_Survey__c (before insert) {

    list<Service_Type_Matrix__c> serviceList = new List<Service_Type_Matrix__c>();
    Map<String,String> mapIssueCode = New Map<String,String>(); //<Service Type Code,Issue>
    Set<String> setServiceCode = New Set<String>();

    if(Trigger.isBefore && Trigger.isInsert){
        for(CXM_Survey__c cxm: trigger.new){
            if(cxm.ComplaintIssue__c != null){
                setServiceCode.add(cxm.ComplaintIssue__c);
            }
        }  

        if(setServiceCode.size() > 0){
            serviceList =[Select ID, Service_Level2__c, Service_Level3__c,Service_Level4__c,Validate_Code__c,
            Service_issue_EN__c from Service_Type_Matrix__c where Validate_Code__c in: setServiceCode];

        }

        //mapping ComplaintIssue__c with service type matrix in salesforce
        if(serviceList.size() > 0){
            for(Service_Type_Matrix__c serviceIssue: serviceList){
                if(serviceIssue.Service_Level4__c != null){
                    mapIssueCode.put(serviceIssue.Validate_Code__c,serviceIssue.Service_Level4__c);
                }else if(serviceIssue.Service_Level3__c != null){
                    mapIssueCode.put(serviceIssue.Validate_Code__c,serviceIssue.Service_Level3__c);
                }else{
                    mapIssueCode.put(serviceIssue.Validate_Code__c,serviceIssue.Service_Level2__c);
                }
            }
        }

        for(CXM_Survey__c cxm: trigger.new){
            //geting issue detail form mapping
            if(cxm.ComplaintIssue__c != null ){
                cxm.Activity_description__c = mapIssueCode.get(cxm.ComplaintIssue__c);
            }else if(cxm.ActivityDesc__c != null){
                cxm.Activity_description__c = cxm.ActivityDesc__c;
            }else {
                cxm.Activity_description__c = cxm.parentBusinessOutcome__c;
            }
        }
    }
}