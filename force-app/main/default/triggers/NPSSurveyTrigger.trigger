trigger NPSSurveyTrigger on Survey__c (before delete) {

    for(Survey__c sv : trigger.old){
        if(sv.result__c !=null){
            sv.addError('Cannot delete completed survey.');
        }
    }

}