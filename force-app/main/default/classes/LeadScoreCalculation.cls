public with sharing class LeadScoreCalculation {
    // @future
    public static CampaignMember LeadScoreCalculate(CampaignMember cm) {
        // Query Lead Score List by Id
        System.debug('LeadScoreCalculate Start with CM : ' + cm);
        List<Id> leadScoreListconId =  new List<Id>();
        Map<Id,Decimal> mapLScoreConIdwithWeight = new Map<Id,Decimal>();
        Map<String,String> mapIdwithFieldName = new Map<String,String>();
        Map<Id,List<Lead_Scoring_Condition_Detail__c>> mapLeadConIdwithDetailId = new Map<Id,List<Lead_Scoring_Condition_Detail__c>>();
        List<String> FieldName =  new List<String>();
        List<String> LeadFieldName = new List<String>();
        // CampaignMember cm = [Select Id, Scoring_Condition_Id__c,LeadId FROM CampaignMember WHERE Id =: cmId LIMIT 1];
        List<Lead_Scoring_List__c> lslist = [SELECT Id,isActive__c FROM Lead_Scoring_List__c WHERE Id =: cm.Scoring_Condition_ID__c  LIMIT 1];
        if(lslist.size() > 0 && lslist[0].isActive__c){
            List<Lead_Scoring_Condition__c> lsclist = [SELECT Id,Name,Object__c,Field_Mapping__c, Weight__c FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c =: lslist[0].Id];
            for(Lead_Scoring_Condition__c eachCon : lsclist){
                if(eachCon.Object__c != 'CampaignMember' && cm.LeadId != null){
                    leadScoreListconId.add(eachCon.Id);
                    mapLScoreConIdwithWeight.put(eachCon.Id,eachCon.Weight__c);
                    LeadFieldName.add(eachCon.Field_Mapping__c);
                    FieldName.add(eachCon.Object__c+'.'+eachCon.Field_Mapping__c);
                    mapIdwithFieldName.put(eachCon.Id,eachCon.Object__c+'.'+eachCon.Field_Mapping__c);
                }else{
                    leadScoreListconId.add(eachCon.Id);
                    mapLScoreConIdwithWeight.put(eachCon.Id,eachCon.Weight__c);
                    FieldName.add(eachCon.Field_Mapping__c);
                    mapIdwithFieldName.put(eachCon.Id,eachCon.Field_Mapping__c);

                }
            }
            List<Lead> leadData = new List<Lead>();
            System.debug('LeadID : ' + cm.LeadId);
            System.debug('leadScoreListconId : ' + leadScoreListconId.size());
            System.debug('LeadFieldName : ' + LeadFieldName.size());

            String leadId = cm.LeadID;
            if(LeadFieldName.size() > 0){
                leadData = Database.query(String.format('SELECT {0} FROM Lead WHERE Id =:leadId LIMIT 1', 
                new List<String>{
                    String.join(LeadFieldName, ',')
                }));
            }
            
            List<CampaignMember> cmData = new List<CampaignMember>();
            cmData.add(cm);
            List<Lead_Scoring_Condition_Detail__c> lscoreConDetailList = [SELECT ID,Name,Operation__c,Value1__c,Value2__c,Score__c,Priority__c,Lead_Scoring_Condition__c FROM Lead_Scoring_Condition_Detail__c WHERE Lead_Scoring_Condition__c IN: leadScoreListconId ORDER BY Priority__c];
            for(Lead_Scoring_Condition_Detail__c eachConDetail : lscoreConDetailList){
                System.debug('eachConDetail : ' + eachConDetail);
                List<Lead_Scoring_Condition_Detail__c> listrule = new List<Lead_Scoring_Condition_Detail__c>();
                if(mapLeadConIdwithDetailId.containsKey(eachConDetail.Lead_Scoring_Condition__c)){
                    listrule = mapLeadConIdwithDetailId.get(eachConDetail.Lead_Scoring_Condition__c);
                    listrule.add(eachConDetail);
                    mapLeadConIdwithDetailId.put(eachConDetail.Lead_Scoring_Condition__c,listrule);
                }else{
                    listrule.add(eachConDetail);
                    mapLeadConIdwithDetailId.put(eachConDetail.Lead_Scoring_Condition__c,listrule);
                }
            }
            // Map<Id,List<Lead_Scoring_Condition_Detail__c>> filtermapLeadConIdwithDetailId = new Map<Id,List<Lead_Scoring_Condition_Detail__c>>();
            Map<String,String> filtermapIdwithFieldName = new Map<String,String>();

            for(String ldconId : mapLeadConIdwithDetailId.keySet()){
                if(mapIdwithFieldName.containsKey(ldconId)){
                    filtermapIdwithFieldName.put(ldconId,mapIdwithFieldName.get(ldconId));
                }
            }

            Decimal TotalWeight = 0;
            for(Id key : filtermapIdwithFieldName.keySet()){
                System.debug('Key : ' + key);
                Decimal score = 0;
                String strfieldName = filtermapIdwithFieldName.get(key);
                System.debug('strfieldName : ' + strfieldName);

                Decimal Weight = mapLScoreConIdwithWeight.get(key);
                String value = null;
                System.debug('Weight : ' + Weight);
                if(strfieldName.contains('Lead.')){
                    String filterfieldName = strfieldName.remove('Lead.');

                    value = String.valueOf(leadData[0].get(filterfieldName));

                }else{
                    value = String.valueOf(cmData[0].get(strfieldName));
                }
                System.debug('value : ' + value);

                List<Lead_Scoring_Condition_Detail__c> ruleList = mapLeadConIdwithDetailId.get(key);
                System.debug('ruleList : ' + ruleList);
                for(Lead_Scoring_Condition_Detail__c rule : ruleList){
                    if(rule != null){
                        System.debug('Check Value : ' + value);
                        System.debug('Operation : '+rule.Operation__c);
                        System.debug('Value 1 : '+rule.Value1__c);
                        System.debug('Value 2 : '+rule.Value2__c);
                        System.debug('---------------------');

                        if(rule.Operation__c == '='){
                            if(value == rule.Value1__c){
                                score = rule.Score__c;
                                break;
                            }
                            else if(rule.Value1__c == 'Is null'){
                                if(value == null || value == 'null'){
                                    score = rule.Score__c;
                                    break;
                                }
                            }
                            else if(rule.Value1__c == 'Not match'){
                                score = rule.Score__c;
                                break;
                            }
                        }
                        else if(rule.Operation__c == 'Contain'){
                            if(value != null && value.contains(rule.Value1__c)){
                                score = rule.Score__c;
                                break;
                            }
                        }
                        else if(rule.Operation__c == '<'){
                            if(value != null && Decimal.valueOf(value) < Decimal.valueOf(rule.Value1__c)){
                                score = rule.Score__c;
                                break;
                            }
                        }
                        else if(rule.Operation__c == '>'){
                            if(value != null && Decimal.valueOf(value) > Decimal.valueOf(rule.Value1__c)){
                                score = rule.Score__c;
                                break;
                            }
                        }
                        else if(rule.Operation__c == 'Range'){
                            if(value != null && Decimal.valueOf(value) >= Decimal.valueOf(rule.Value1__c) && Decimal.valueOf(value) <= Decimal.valueOf(rule.Value2__c)){
                                score = rule.Score__c;
                                break;
                            }
                        }
            
                    }

                }
                if(score != 0){
                    System.debug('Calculate : ' + strfieldName + '= Weight(' + Weight + ') x Score(' + score + ')');
                    Decimal thisScore = (Weight*score)/100;
                    TotalWeight += thisScore;
                }
            }
            TotalWeight = TotalWeight.setScale(0);
            List<Lead_Score_Level__c> LeadScoreLv = [SELECT Id,Name FROM Lead_Score_Level__c WHERE Score_Min__c <= :TotalWeight AND Score_Max__c >= :TotalWeight ORDER BY Score_Min__c ASC LIMIT 1];
            if(LeadScoreLv.size() > 0){
                cm.Lead_Score_Level__c = LeadScoreLv[0].Name;
            }
            cm.Lead_Score__c = TotalWeight;
            // cm.Lead.Lead_Score__c = TotalWeight;
            // update cm;
            if(cm.LeadId != null){
                Lead dropLead = new Lead();
                dropLead.Id = cm.LeadId;
                dropLead.Lead_Score__c = TotalWeight;
                if(LeadScoreLv.size() > 0){
                    dropLead.Lead_Score_Level__c = LeadScoreLv[0].Name;
                }
                update dropLead;
            }
            System.debug('TotalWeight :' + TotalWeight);
        }
        else if(lslist.size() > 0 && !lslist[0].isActive__c){
            cm.Lead_Score__c = 0;
            cm.Lead_Score_Level__c = 'Cold';
            if(cm.LeadId != null){
                Lead dropLead = new Lead();
                dropLead.Id = cm.LeadId;
                dropLead.Lead_Score__c = 0;
                dropLead.Lead_Score_Level__c = 'Cold';
                update dropLead;
            }
        }
        // else{
        //     cm.Lead_Score__c = null;
        //     cm.Lead_Score_Level__c = 'Cold';
        //     if(cm.LeadId != null){
        //         Lead dropLead = new Lead();
        //         dropLead.Id = cm.LeadId;
        //         dropLead.Lead_Score__c = null;
        //         dropLead.Lead_Score_Level__c = 'Cold';
        //         update dropLead;
        //     }
        //     System.debug('No Lead Scoring Condition Found !');
        // }
        return cm;
    }
}