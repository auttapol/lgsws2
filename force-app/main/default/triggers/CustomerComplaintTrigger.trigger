trigger CustomerComplaintTrigger on Customer_Complaint__c (after insert, after update) {
/* // Inactive Trigger
    //Trigger to auto update case in salesforce that mapping with case in CCRP
    List<Case> list_case = New List<Case>(); //for store all case to update that mapping whith CCRP
    Set<String> set_ccrpID = New Set<String>();
    Map<String,String> map_ccrp_status = New Map<String,String>();
    
    //After Insert Customer Complaint
    if(Trigger.isAfter && Trigger.isInsert){
        for(Customer_Complaint__c ccrp_for : trigger.new){  
            //Mapping all record from CCRP that status CLOSED, CANCEL or REJECTED for process auto update Case in salesforce to Closed
            if(ccrp_for.TMB_Care__c != null && (ccrp_for.Status__c == 'CLOSED' || ccrp_for.Status__c == 'CANCEL' || ccrp_for.Status__c == 'REJECTED')){
                   set_ccrpID.add(ccrp_for.TMB_Care__c);
                   map_ccrp_status.put(ccrp_for.TMB_Care__c, ccrp_for.Status__c);
               }        
        } 
    }
    
    //After update Customer Complaint
    if(Trigger.isAfter && Trigger.isUpdate){    
        for(Integer i = 0; i < trigger.new.size(); i++ ){  
            //Mapping all record from CCRP that status CLOSED, CANCEL or REJECTED for process auto update Case in salesforce to Closed
            if(trigger.new[i].TMB_Care__c != null && trigger.new[i].Status__c != trigger.old[i].Status__c && 
               (trigger.new[i].Status__c == 'CLOSED' || trigger.new[i].Status__c == 'CANCEL' || trigger.new[i].Status__c == 'REJECTED')){
                   set_ccrpID.add(trigger.new[i].TMB_Care__c);
                   map_ccrp_status.put(trigger.new[i].TMB_Care__c, trigger.new[i].Status__c);
               }        
        }
    }
    
    //Query Case to auto update to closed
    if(set_ccrpID.size() > 0){
        List<Case> list_case_ccrp =[Select ID, Status, CCRP_Number__c from Case where IsClosed = false and CCRP_Number__c in: set_ccrpID and CCRP_Number__c != null];
        if(list_case_ccrp.size() > 0){
            for(Case case_for: list_case_ccrp){
                Boolean isUpdate = false;
                if(map_ccrp_status.get(case_for.CCRP_Number__c) == 'CLOSED'){
                    case_for.Status = 'Completed';
                    isUpdate = true;
                }
                if(map_ccrp_status.get(case_for.CCRP_Number__c) == 'CANCEL' || map_ccrp_status.get(case_for.CCRP_Number__c) == 'REJECTED'){
                    case_for.Status = 'Cancel';
                    isUpdate = true;
                }
                if(isUpdate){
                    list_case.add(case_for);
                }
            }
        }
        if(list_case.size() > 0){
            try{ 
                update list_case;
            }catch(exception e){
                //Do nothing
            }
        }
    } 
*/
}