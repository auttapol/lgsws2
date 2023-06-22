public with sharing class ALDXButton_TBankCaseHistoryController {
    public String ALDX_Link {get; set;}

    public ALDXButton_TBankCaseHistoryController(ApexPages.StandardSetController setcon) {
        App_Config__mdt ALDX_mdt = [SELECT Label, Value__c FROM App_Config__mdt WHERE Label = 'ALDX URL Link' LIMIT 1];
        ALDX_Link = String.valueOf(ALDX_mdt.Value__c);
        // System.debug('ALDX: ' + ALDX_Link);
    }
}