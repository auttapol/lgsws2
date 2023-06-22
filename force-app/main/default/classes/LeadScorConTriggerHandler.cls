public with sharing class LeadScorConTriggerHandler{
    public static void handlerAfterInsert(List<Lead_Scoring_Condition__c> newLSC){
        // System.debug(newLSC);
        LeadScorConTriggerHandler.addLevel3(newLSC);
    }

    public static void handlerAfterUpdate(Map<Id,Lead_Scoring_Condition__c> oldLSC, List<Lead_Scoring_Condition__c> newLSC){
        System.debug('Old LSC : '+JSON.serialize(oldLSC));
        System.debug('New LSC : '+newLSC);
        List<String> LSCiD = new List<String>();
        for(Lead_Scoring_Condition__c nl: newLSC){
            if(oldLSC.get(nl.Id).Field_Mapping__c != nl.Field_Mapping__c || oldLSC.get(nl.Id).Object__c != nl.Object__c){
                LSCiD.add(nl.Id);
            }
        }

        List<Lead_Scoring_Condition_Detail__c> lscdToDelete = [SELECT Id FROM Lead_Scoring_Condition_Detail__c WHERE Lead_Scoring_Condition__c IN :LSCiD ];
        if(lscdToDelete.size()>0){
            delete lscdToDelete;
        } 

        List<Lead_Scoring_Condition__c> insertLV3 = [SELECT Id, Name, Object__c, Field_Mapping__c, Weight__c, Lead_Scoring_List__c FROM Lead_Scoring_Condition__c WHERE Id IN :LSCiD];
        LeadScorConTriggerHandler.addLevel3(insertLV3);
    }


    public static void addLevel3(List<Lead_Scoring_Condition__c> newLSC){
        for (Lead_Scoring_Condition__c lsc : newLSC){
            if (newLSC.size() > 0){
                List<Lead_Scoring_Condition_Detail__c> leadConDetailList = new List<Lead_Scoring_Condition_Detail__c>();
                List<App_Config__mdt> score = [SELECT Id, DeveloperName, MasterLabel, Label, Value__c
                                               FROM App_Config__mdt
                                               WHERE DeveloperName IN ('LGS_Is_null_Defaul_Score', 'LGS_Not_match_Defaul_Score')];
                // System.debug('Metadata Score : ' + score);
                Lead_Scoring_Condition_Detail__c leadConDetail998 = new Lead_Scoring_Condition_Detail__c();
                Lead_Scoring_Condition_Detail__c leadConDetail999 = new Lead_Scoring_Condition_Detail__c();
                leadConDetail998.Value1__c = 'Is null';
                leadConDetail998.Priority__c = 998;
                leadConDetail998.Operation__c = '=';
                leadConDetail998.Lead_Scoring_Condition__c = lsc.id;
                for (App_Config__mdt ac : score){
                    if (ac.DeveloperName == 'LGS_Is_null_Defaul_Score'){
                        leadConDetail998.Score__c = Decimal.valueOf(ac.Value__c);
                    }
                }
                leadConDetailList.add(leadConDetail998);
                leadConDetail999.Value1__c = 'Not match';
                leadConDetail999.Priority__c = 999;
                leadConDetail999.Operation__c = '=';
                leadConDetail999.Lead_Scoring_Condition__c = lsc.id;
                for (App_Config__mdt ac : score){
                    if (ac.DeveloperName == 'LGS_Not_match_Defaul_Score'){
                        leadConDetail999.Score__c = Decimal.valueOf(ac.Value__c);
                    }
                }
                leadConDetailList.add(leadConDetail999);
                insert leadConDetailList;
            }
        }
    }

}