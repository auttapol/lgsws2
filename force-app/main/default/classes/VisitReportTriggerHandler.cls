public class VisitReportTriggerHandler {

    
      public static void checkTMBPerson(List<Visit_Report__c> TriggerNew,String ACTION){
       set<id> visitPlanID = new set<id>();
	   Map<ID,Set<ID>> counterpartyMap = new Map<ID,Set<ID>>();
       Map<ID,Set<ID>> permissionMap = new Map<ID,Set<ID>>();
        for(Visit_Report__c report : TriggerNew){
            visitplanid.add(report.Visit_Plan_Report__c);
        }
       
       List<Call_report__c> callreportList = [SELECT ID,OwnerID from Call_Report__c
                                            WHERE ID IN:visitplanid];
        MAP<ID,id> visitplanList = new Map<ID,ID>();
        for(Call_report__c visitplan : callreportList){
            visitplanList.put(visitplan.id,visitplan.OwnerId);
        }

          List<Visit_Plan_Invitee__c> counterpartyList = [SELECT TMB_Person__c,TMB_Person__r.id,
                                               Visit_Plan_Report__c,
                                              Visit_Plan_Report__r.OwnerID
                                              FROM Visit_Plan_Invitee__c
                                              WHERE Visit_Plan_Report__c IN: visitplanList.keySet()];

        for(Visit_Plan_Invitee__c counterparty : counterpartyList ){
            if(counterpartyMap.containsKey(counterparty.Visit_Plan_Report__c)){
                counterpartyMap.get(counterparty.Visit_Plan_Report__c).add(counterparty.TMB_Person__r.id);
            }else{
                Set<ID> counterpartySet = new Set<ID>();
                counterpartySet.add(counterparty.TMB_Person__r.id);
                counterpartyMap.put(counterparty.Visit_Plan_Report__c,counterpartySet);
            }
        }
        
        
        for(Visit_Report__c report : TriggerNew){
            ID OwnerID = visitplanList.get(report.Visit_Plan_Report__c);
                Set<ID> permissions = new Set<ID>();
                permissions.add(OwnerID);
                permissionMap.put(report.Visit_Plan_Report__c,permissions);
            
            if(ACTION=='INSERT'){
                 if(counterpartyMap.containsKey(report.Visit_Plan_Report__c)){
                    for(ID tmbcounterparty : counterpartyMap.get(report.Visit_Plan_Report__c)){
                        permissionMap.get(report.Visit_Plan_Report__c).add(tmbcounterparty);
                    }
            	}
            }
        }
          
        for(Visit_Report__c visitreport : TriggerNew){
            boolean isHasPermission = false;
            if(ACTION=='INSERT'){
                if(permissionMap.get(visitreport.Visit_Plan_Report__c).contains(visitreport.OwnerID)){
               isHasPermission = true; 
            	}
            }else{
                if(Userinfo.getUserId() == visitreport.OwnerId){
                    isHasPermission = true;
                }
            }
            
            if(!isHasPermission){
                 visitreport.addError( Status_Code__c.GetValues('7006').Status_Message__c);
            }
              
        }
        
        }   
   
    
    

}