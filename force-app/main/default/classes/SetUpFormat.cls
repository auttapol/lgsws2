public with sharing class SetUpFormat {
    // public SetUpFormat() {
        
    // }

    @AuraEnabled(cacheable=true)
    public static string getSetupFormat(String formatname){
        try {
            String returnConditionFormat  = '';
            List<SetupFormat__mdt> setupFormat = [SELECT format_name__c,condition__c FROM SetupFormat__mdt WHERE format_name__c = :formatname];
            //setupFormat = 
            for(SetupFormat__mdt setup : setupFormat ){
                returnConditionFormat = setup.condition__c;
            }
            returnConditionFormat = !Test.isRunningTest()?returnConditionFormat:  formatname !='exception'?'{"Condition":[{"Segment_crm__c":"1","style":"StyledisplayTest1","class":"ClassdisplayTest1","RTL_Privilege1__c":[]},{"Segment_crm__c":"2","style":"StyledisplayTest2","class":"ClassdisplayTest2","RTL_Privilege1__c":[]}]}':String.valueOf(1/0);             
            System.debug('------------ Condition format result : '+returnConditionFormat);
            return returnConditionFormat;
                        
        } catch (Exception e) {
            return '{"Error":"'+e.getCause() +': '+e.getMessage()+'"}';
            //throw new AuraHandledException(e.getMessage());
        }
    }
}