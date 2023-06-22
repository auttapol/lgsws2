public class RTL_ReferralOpportunityService {
    public static Boolean isOpportunityTrigger = false;
    public static Map<String, Branch_and_Zone__c> branchNameMap{
    get{
        if(branchNameMap ==null){
        	branchNameMap = new Map<String, Branch_and_Zone__c>();
        	for(Branch_and_Zone__c branchzone : [Select Id,Name, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c]) {
            	branchNameMap.put(branchzone.Name, branchzone);
        	}
        }
        return branchNameMap;
        
    }set;}
    
    public static void updateReferralInfo(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        List<Opportunity> opportunityWithReferral = new List<Opportunity>();
        for(Id oppId : newMap.keySet()){
            Opportunity oldOpp = oldMap.get(oppId);
            Opportunity newOpp = newMap.get(oppId);
            if(oldOpp.RTL_Referral__c != newOpp.RTL_Referral__c){
                opportunityWithReferral.add(newOpp);
            }
        }
		updateReferralClosedInterest(opportunityWithReferral);        
    }
    public static void updateReferralClosedInterest(List<Opportunity> opportunityList){
        Set<Id> referralIdSet = new Set<Id>();
        Map<Id,RTL_Referral__c> referralMap;
        List<RTL_Referral__c> referralToUpdate = new List<RTL_Referral__c>();
        Map<String,String> channelLeadSourceMap = RTL_ReferralAssignUtility.channelLeadSourceMap;
        
        if(isOpportunityTrigger == false){
            isOpportunityTrigger = true;
        }
        for(Opportunity oppObj : opportunityList){
            if(oppObj.RTL_Referral__c != null){
                if(oppObj.RTL_External_Ref_ID__c == null){ // NOT FROM AL SYSTEM
        		referralIdSet.add(oppObj.RTL_Referral__c);        
                }
            }
        }
        
        if(referralIdSet.size() > 0){
            referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,RTL_Stage__c,RTL_Employee_Name__c,RTL_EmployeeId__c,RTL_Branch__c,RTL_Account_Name__c,OwnerId,CreatedDate,
                                                       		  RTL_Refer_Branch_Name__c,RTL_Type__c,RecordType.DeveloperName,RecordType.Name,RTL_Preferred_Branch__r.IsActive__c,RTL_Channel_Segment__c,RTL_Preferred_Branch__c  FROM RTL_Referral__c WHERE ID IN:referralIdSet]);
        }
        for(Opportunity oppObj : opportunityList){
            RTL_Referral__c refObj;
            //CR Feb2018 #211 stamp referral record type on opportunity , this field will be used in sharing rule
            oppObj.Referral_Record_Type__c = null;
            if(oppObj.RTL_Referral__c != null && referralMap != null && referralMap.containsKey(oppObj.RTL_Referral__c)){
                refObj = referralMap.get(oppObj.RTL_Referral__c);
                System.debug('Ref created ::: '+refObj.CreatedDate);
                System.debug('Opp Created ::: '+oppObj.CreatedDate);
                //CR Feb2018 #211 stamp referral record type on opportunity , this field will be used in sharing rule
                oppObj.Referral_Record_Type__c = refObj.RecordType.Name;
                
                if(refObj.RTL_Account_Name__c != oppObj.AccountId){
                    //Customer on referral and opportunity must be same
                    oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR007);
                }else if(refObj.CreatedDate > oppObj.CreatedDate){
                    //Referral must be crated before opportunity
                    oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR008);
                }
                //Error if type = 'To Product Team' and Stage != 'Closed (Service Completed)','New',In progress & Contact','Closed (Interested)'
                else if(refObj.RTL_Type__c == 'To Product Team (เพื่อส่งให้ทีม Product)' && refObj.RTL_Stage__c != 'New' && refObj.RTL_Stage__c != 'In progress_Contacted' &&
                        refObj.RTL_Stage__c != 'Closed (Service Completed)'){
                        //You can create a new opportunity when the referral's stage is "New","Contacted & In Progress", or "Closed (Service Completed)" only.
                        oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR020);

                }else if(refObj.RTL_Type__c != 'To Product Team (เพื่อส่งให้ทีม Product)' && refObj.RTL_Stage__c != 'New' && refObj.RTL_Stage__c != 'In progress_Contacted' &&
                         refObj.RTL_Stage__c != 'Closed (Interested)' ){
                    //Cannot attached opportunity if referral is closed (lost) and type != To Product Team
                	oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR009);
                }else if(refObj.RTL_Type__c == 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)'){
                    //Cannot attach opportunity if referral type = Account Opening/Service
                    oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR015);
                }else if(refObj.RTL_Preferred_Branch__c != null && refObj.RTL_Preferred_Branch__r.IsActive__c == false){
                    //Cannot attach opportunity if referral preferrred branch is inactive
                    oppObj.RTL_Referral__c.addError(System.Label.RTL_Referral_ERR017);
                }
                /*
                Auto close referral to 'Closed(Interested)' when create first opportunity on referral
                CH001 : 16 Mar 2018 CR MF by Phone  , don't auto 'Closed(Interested)' when create opportunity on Retail Order Transaction
                CH002 : 23 April 2018 CR Refer within commercial , don't auto 'Closed(Interested)' when create opportunity under Referral with Refer Type = To Product Team
                */
            	else if(refObj.RTL_Stage__c != 'Closed (Interested)' && refObj.RecordType.DeveloperName != 'Retail_Order_Transaction' && refObj.RecordType.DeveloperName != 'Closed_Retail_Order_Transaction' && refObj.RTL_Type__c != 'To Product Team (เพื่อส่งให้ทีม Product)' ){
                	refObj.RTL_Stage__c = 'Closed (Interested)';
                	referralToUpdate.add(refObj);
            	}
            	
            	oppObj.Referral_Staff_Name__c = refObj.RTL_Employee_Name__c;
            	oppObj.Referral_Staff_ID__c = refObj.RTL_EmployeeID__c;
                
                //set lead source value
                oppObj.LeadSource = 'Refer from branch';
                
                //CR Referral Enhancement RQ-008 Add new recordtype 'Refer within Commercial'
                //if referral recordtype is refer within commericial , set lead source to 'Refer within Commercial'
                if(refObj.RecordType.DeveloperName == 'Refer_within_Commercial' || refObj.RecordType.DeveloperName == 'Closed_Refer_within_Commercial'){
                    oppObj.LeadSource = 'Refer within Commercial';

                    if(channelLeadSourceMap.containsKey(refObj.RTL_Channel_Segment__c)){
                        oppObj.LeadSource = channelLeadSourceMap.get(refObj.RTL_Channel_Segment__c);
                    }
                    // if(refObj.RTL_Channel_Segment__c == 'Web'){
                    //     oppObj.LeadSource = 'Website';   
                    // }
                    // if(refObj.RTL_Channel_Segment__c == 'Biztouch'){
                    //     oppObj.LeadSource = 'Biztouch';   
                    // }
                    // if(refObj.RTL_Channel_Segment__c == 'OLAP'){
                    //     oppObj.LeadSource = 'OLAP';   
                    // }
                    // //CR OLAP Phase2 : 15 May 2018 , add channel 'OLAP-Lead'
                    // if(refObj.RTL_Channel_Segment__c == 'OLAP-Lead'){
                    //     oppObj.LeadSource = 'OLAP-Lead';   
                    // }

                }
                
                if(branchNameMap.containsKey(refObj.RTL_Refer_Branch_Name__c )){
                    oppObj.Branch_Referred__c = branchNameMap.get(refObj.RTL_Refer_Branch_Name__c ).Id;
                }
                
            }
            
        }
        
        if(referralToUpdate.size() > 0){
            update referralToUpdate;
        }
    }
}