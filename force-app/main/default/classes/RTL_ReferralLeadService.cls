/****   RTL_ReferralLeadService  this class created to check logic between Referral and Lead
created by CR Referral Enhancement RQ-004 sync lead status and referral status
*****/
public class RTL_ReferralLeadService {

	public static void updateReferralStageContacted(List<sObject> leadList){
		Set<Id> referralIdSet = new Set<Id>();
        Map<Id,RTL_Referral__c> referralMap;
        List<RTL_Referral__c> referralToUpdate = new List<RTL_Referral__c>();
        
        for(sObject sObj : leadList){
        	Lead leadObj = (Lead)sObj;
            if(leadObj.RTL_Referral__c != null){
        		referralIdSet.add(leadObj.RTL_Referral__c);        
            }
        }
        
        if(referralIdSet.size() > 0){
            referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,RTL_Stage__c  FROM RTL_Referral__c WHERE ID IN:referralIdSet]);
        }
        
        for(sObject sObj : leadList){
        	Lead leadObj = (Lead)sObj;
            RTL_Referral__c refObj;
            //If lead status = contacted or qualified and referral status != In progress_Contacted
            if(leadObj.RTL_Referral__c != null && referralMap.containsKey(leadObj.RTL_Referral__c) 
            	&& (leadObj.Status == 'Contacted' || leadObj.Status == 'Qualified') )
                {
            	
                refObj = referralMap.get(leadObj.RTL_Referral__c);
            	//23 May 2018 CR Refer within Commercial exclude 'Closed (Service Completed)' support type = To Product team to auto update referral stage
                if(refObj.RTL_Stage__c != 'In progress_Contacted' && refObj.RTL_Stage__c != 'Closed (Service Completed)'){
                    refObj.RTL_Stage__c = 'In progress_Contacted';
                    referralToUpdate.add(refObj);
                }
                    
            }
                
            
        }
        
        if(referralToUpdate.size() > 0){
            update referralToUpdate;
        }
	}


	public static void updateReferralInfo(Map<Id,sObject> oldMap,Map<Id,sObject> newMap){
        List<Lead> contactedLeadWithReferral = new List<Lead>();
        for(Id leadId : newMap.keySet()){
            Lead oldLead = (Lead)oldMap.get(leadId);
            Lead newLead = (Lead)newMap.get(leadId);
            //If lead status changed
            if(oldLead.Status != newLead.Status){
                contactedLeadWithReferral.add(newLead);
            }
            //If Referral Changed
            else if(oldLead.RTL_Referral__c != newLead.RTL_Referral__c){
            	contactedLeadWithReferral.add(newLead);
            }
        }
		updateReferralStageContacted(contactedLeadWithReferral);        
    }

    public static List<SObject> prepareLeadInfo(List<SObject> leadList){
        /// Call in RTL_LeadTriggerHandler (retail)
        /// and LeadTrigger (CRM)
        System.debug('RTL_ReferralLeadService prepareLeadInfo');
        Set<String> referalIdSet = new Set<String>();
        Map<String, RTL_Referral__c> mapReferral = new MAP<String, RTL_Referral__c>();
        for(SObject sObj : leadList){
            Lead leadObj = (Lead)sObj;
            if(leadobj.RTL_Referral__c != null){
                referalIdSet.add(leadobj.RTL_Referral__c);
            }
        }

        if(referalIdSet.size() > 0){
            List<RTL_Referral__c> referralList = [SELECT id, name, FNA_Activity__c, FNA_Activity__r.Avatar_Name__c, 
                                FNA_Activity__r.Avatar_Url__c, FNA_Activity__r.CreatedDate, 
                                FNA_Activity__r.Product_Holding__c, FNA_Activity__r.Product_Interested__c 
                                FROM RTL_Referral__c WHERE Id in : referalIdSet];

            for(RTL_Referral__c refer : referralList){
                mapReferral.put(refer.id, refer);
            }
        }

        if(mapReferral.size() > 0){
            for(SObject sObj : leadList){
                Lead leadObj = (Lead)sObj;
                leadobj.FNA_Activity__c = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__c;
                leadobj.Fna_Avatar_Name__c  = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__r.Avatar_Name__c;
                leadobj.Fna_Avatar_Url__c = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__r.Avatar_Url__c;
                leadobj.Fna_Create_Date__c = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__r.CreatedDate;
                leadobj.Fna_Product_Holding__c = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__r.Product_Holding__c;
                leadobj.Fna_Product_Interested__c = mapReferral.get(leadobj.RTL_Referral__c).FNA_Activity__r.Product_Interested__c;
            }

        }

        return leadList;
    }

}