///////////////////////////////////////////////////////////
    // ------------------------------------------------------------------------------
    // Transection No. : CH01
    // Author : Nuchanard S.
    // Date : 2018.03.12
    // Description : MF By Phone > update order in referral by reassign or assign
    // ------------------------------------------------------------------------------
    ///////////////////////////////////////////////////////////
    public class RTL_ReferralTriggerHandler {
        public static Boolean isBeforeInsert = false;
        public static Boolean isBeforeUpdate = false;
        
        private static RTL_Branch_Manager_Title__c branchTitle;
        private static Map<String,User> branchCodeUserMap = new Map<String,User>();
        private static Map<String,User> empCodeUserMap = new Map<String,User>();
        public static User currentUser{
        get{
            if(currentUser ==null){
                currentUser = [SELECT Id,Name,Employee_ID__c ,Segment__c ,Reporting_Segment__c ,
                                        Region__c ,Region_Code__c ,Zone__c ,Zone_Code__c ,RTL_Branch_Code__c ,
                                        RTL_Branch__c ,RTL_Channel__c,UserRole.Name,Profile.Name
                                FROM User
                               WHERE Id =: System.UserInfo.getUserId()];
            }
            return currentUser;
            
        }set;}
        
        public static Map<String, Branch_and_Zone__c> branchCodeMap{
        get{
            if(branchCodeMap ==null){
                branchCodeMap = new Map<String, Branch_and_Zone__c>();
                for(Branch_and_Zone__c branchzone : [Select Name, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c,RTL_Zone__c, RTL_Region_Retail__c  
                                                     from Branch_and_Zone__c]) {
                    branchCodeMap.put(branchzone.Branch_Code__c, branchzone);
                }
            }
            return branchCodeMap;
            
        }set;}
    
        //CR Call Me Now , query business hours of Call Me Now -- phase2
         private static BusinessHours callMeNowBusinessHours{
         get{
             if(callMeNowBusinessHours == null ){
                 String bhName;
                 AppConfig__c cf = AppConfig__c.getValues('CallMeNowBH');
                 bhName = (cf == null ? 'Call Me Now' : cf.Value__c);
                 List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours WHERE Name =: bhName];
                 if(businessHours.size() > 0){
                     callMeNowBusinessHours = businessHours[0];
                 }
                 
             }
     
             return callMeNowBusinessHours;
     
         }set;
    
         }
        
         private static BusinessHours serviceBusinessHours{
            get{
                if(serviceBusinessHours == null ){
                    String bhName;
                    AppConfig__c cf = AppConfig__c.getValues('Service');
                    bhName = (cf == null ? 'Service' : cf.Value__c);
                    List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours WHERE Name =: bhName];
                    if(businessHours.size() > 0){
                        serviceBusinessHours = businessHours[0];
                    }
                    
                }
        
                return serviceBusinessHours;
        
            }set;
       
            }
    
        public static List<String> flagshipBRCode{
            get{
                if(flagshipBRCode == null){
                    String lstBRcode;
                    AppConfig__c cf = AppConfig__c.getValues('FlagshipBRCode');
                    
                    lstBRcode = (cf == null ? '252,283' : (cf.Value__c == null ? '252,283' : cf.Value__c));
                    flagshipBRCode = lstBRcode.split(',');
                }
                return flagshipBRCode;
            }
            
            set ;
        }
        public static String Referral_SLA{
            get{
                if(Referral_SLA == null){
                    App_Config__mdt appconfig = new App_Config__mdt();
                    appconfig = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Value__c FROM App_Config__mdt
                                                            WHERE DeveloperName = : 'Referral_SLA'];
                    System.debug(appconfig.Value__c);
                    Referral_SLA = appconfig.Value__c;
                }
                return Referral_SLA;
            }
            
            set ;
        }
    
        public static void handleBeforeInsert(List<RTL_Referral__c> newList){
            if(isBeforeInsert == false){
                isBeforeInsert = true;
            }
            //filter only referral that attached to existing customer
            List<RTL_Referral__c> referralWithCust = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralToUpdate = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralWithRetailProduct = new List<RTL_Referral__c>();
            Map<RTL_Referral__c,String> mapReferralwithcmScoreLevel = new Map<RTL_Referral__c,String>();
            Map<String,Decimal> mapLeadLevelWithScore = new Map<String,Decimal>();
            List<Id> obcmId = new List<Id>();
            Map<Id,CampaignMember> outboundCampaignMember = new Map<Id,CampaignMember>();
            Set<Id> retailProductIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<String> accountExternalIdSet = new Set<String>();
            List<String> multiInterestedProduct = new List<String>();
            Map<String,Account> accountExtIdMap = new Map<String,Account>();
    
            for(RTL_Referral__c referral: newList){
                if(referral.RTL_TMB_Customer_ID__c != null){
                    accountExternalIdSet.add(referral.RTL_TMB_Customer_ID__c);
                }
                referral.countsendHPAP__c = 0;
                referral.Is_Update_Refer__c = false;
                referral.Is_Send_to_HPAP_Done__c = true;
                if(referral.RTL_Campaign_Member__c != null){
                    obcmId.add(referral.RTL_Campaign_Member__c);
                }
            }
            if(obcmId.size() > 0){
                for(CampaignMember each : [SELECT Id,Lead_Score_LeveL__c,Lead_Score__c FROM CampaignMember WHERE Id IN: obcmId]){
                    outboundCampaignMember.put(each.Id,each);
                }
            }

            for(Lead_Score_Level__c each : [SELECT Name,Score_Min__c FROM Lead_Score_Level__c]){
                mapLeadLevelWithScore.put(each.Name,each.Score_Min__c);
            }

            if(accountExternalIdSet.size() > 0){
                for(Account acct : [SELECT Id,Name,TMB_Customer_ID_PE__c FROM Account WHERE TMB_Customer_ID_PE__c IN : accountExternalIdSet]){
                    accountExtIdMap.put(acct.TMB_Customer_ID_PE__c,acct);
                }
            }
            //loop through new referral list
            for(RTL_Referral__c referral : newList){
                System.debug('Campaign Reference :: '+referral.RTL_Campaign_Reference__c);
                System.debug('First Name :: '+referral.RTL_FirstName__c);
                System.debug('Last Name :: '+referral.RTL_LastName__c);
                System.debug('Mobile 1 :: '+referral.RTL_Mobile1__c);
                System.debug('Preferred Branch Code :: '+referral.RTL_Preferred_Branch_Code__c);
                System.debug('Interested Product :: '+referral.RTL_Interested_Product__c);
                System.debug('Sub Product :: '+referral.RTL_Sub_Product__c);
                System.debug('Refer Type :: '+referral.RTL_Type__c);
                System.debug('Channel/Segment :: '+referral.RTL_Channel_Segment__c);
                System.debug('Customer Segment :: '+referral.RTL_Customer_Segment__c);
                System.debug('RecordTypeId :: '+referral.RecordTypeId);
    
                //if source send RM_ID then map to existing customer
                String acctExtId = referral.RTL_TMB_Customer_ID__c;
                if(acctExtId != null){
                    if(accountExtIdMap.containsKey(acctExtId)){
                        referral.RTL_Account_Name__c = accountExtIdMap.get(acctExtId).id;
                    }
                    
                }
                
                //if attach to account keep account id into set
                if(referral.RTL_Account_Name__c != null){
                    accountIdSet.add(referral.RTL_Account_Name__c);
                    referralWithCust.add(referral);
                }
                
         
                //If created with Closed-xxx stage or Invalid (Duplicate Opportunity), stamp First Contacted
                if(referral.RTL_Stage__c.containsIgnoreCase('Closed') || referral.RTL_Stage__c == 'Invalid (Duplicate Opportunity)' || referral.RTL_Stage__c == 'Cancel'){
                    referralToUpdate.add(referral);
                }
                
                if(referral.RTL_Product_Name__c != null){
                    retailProductIdSet.add(referral.RTL_Product_Name__c);
                    referralWithRetailProduct.add(referral);
                }
                
                //Populate interested product on reporting product field
                if(referral.RTL_Interested_Product__c != null){   
                    referral.RTL_Reporting_Product__c = sortMultiInterestedProduct(referral.RTL_Interested_Product__c);
                }
                
                if(referral.RTL_Stage__c == 'Closed (Interested)'){
                    referral.addError(System.Label.RTL_Referral_ERR006);
                }
                
                //CR Call Me Now , if come frome web or biztouch(another CR) map Sales Amount Per Year and Preferred Branch
                //CR OLAP Phase2 : 15 May 2018 , add channel 'OLAP-Lead'
                //CR Flagship : 20 Dec 2018 , add channel 'Flagship' and revised code to support all channel , 
                //                            RTL_Preferred_Branch_Code__c will always have value if record dropped from external system,
                //                            and don't have value when create within Salesforce
    
                if(referral.RTL_Preferred_Branch_Code__c != null && referral.RTL_Preferred_Branch__c == null ){
                    referral.RTL_Sales_Amount_Per_Year__c = getSalesAmountPerYear(referral.RTL_Customer_Segment__c);
                    referral.RTL_Preferred_Branch__c = branchCodeMap.get(referral.RTL_Preferred_Branch_Code__c).id;
                }
                
                if(referral.RTL_Preferred_Branch__c == null && branchCodeMap.containsKey(currentUser.RTL_Branch_Code__c) ){
                    referral.RTL_Preferred_Branch__c = branchCodeMap.get(currentUser.RTL_Branch_Code__c).id;
                   
                }
                if(referral.RTL_Preferred_Branch__c == null && referral.RTL_RecordType_Name__c != 'Refer Within Commercial'){
                    referral.RTL_Preferred_Branch__c.addError(System.Label.RTL_Required_Field);
                }
    
                //CR Call Me Now
                //start CR Call Me Now -- Phase2
                //From web(Refer within Commercial) , Campaign Reference won't be null , For Referral from Branch check Business Hours to define Campaign Reference
                if(referral.RTL_RecordType_Name__c == 'Refer to Commercial'){
                    Boolean isWithThin = false;
                    //check if current time is within business hours , if within set TMB Campaign Reference to 'Call Me Now' else set to 'Normal Request'
                    if(callMeNowBusinessHours != null){
                        isWithThin  = BusinessHours.isWithin(callMeNowBusinessHours.id, System.now());
                    }
                    referral.RTL_Campaign_Reference__c = 'Normal Request';
                    if(isWithThin){
                         referral.RTL_Campaign_Reference__c = 'Call Me Now';
                    }  
                }
                //end CR Call Me Now -- Phase 2
    
                //CR Refer from branch to any channel
                if(referral.RTL_RecordType_Name__c == 'Retail Cross Channel Referral'){
                    if (flagshipBRCode.contains(currentUser.RTL_Branch_Code__c)) {
                        referral.Is_Flagship__c = true;
                    }
                }
    
                //Stamp Created Date as Referred Date
                referral.RTL_Referred_Date_time__c = System.now();
                referral.RTL_Referred_Date__c = System.today();
                referral.RTL_Referred_By_ID__c = currentUser.Id; 
                
                System.debug('RTL_Product_Group__c : '+referral.RTL_Product_Group__c);
                System.debug('RTL_Product_Name__c : '+referral.RTL_Product_Name__c);
                System.debug('RTL_Product_Sub_Group__c : '+referral.RTL_Product_Sub_Group__c);
                System.debug('IS_Flagship__c : '+referral.IS_Flagship__c);
                System.debug('RTL_Preferred_Branch_Name__c  : '+referral.RTL_Preferred_Branch_Name__c );
                System.debug('RTL_Preferred_Branch_Type__c  : '+referral.RTL_Preferred_Branch_Type__c );
                System.debug('RTL_Refer_Branch_Name__c   : '+referral.RTL_Refer_Branch_Name__c  );
                System.debug('RTL_Branch__c  : '+referral.RTL_Branch__c );
                System.debug('current user branch   : '+currentUser.RTL_Branch__c  );
                System.debug('current user branch code  : '+currentUser.RTL_Branch_Code__c );
                //Update Over SLA from createDate with SLA days from appconfig
                updateOverSLA(referral);

                if(outboundCampaignMember.containsKey(referral.RTL_Campaign_Member__c)){
                    CampaignMember obcm = outboundCampaignMember.get(referral.RTL_Campaign_Member__c);
                    if(referral.Lead_Score_Level__c != obcm.Lead_Score_Level__c){
                        // Referral to set default score
                        if(mapLeadLevelWithScore.containsKey(referral.Lead_Score_Level__c)){
                            referral.Lead_Score__c = mapLeadLevelWithScore.get(referral.Lead_Score_LeveL__c);
                            referral.RTL_Lead_Score_Flag__c = true;
                        }
                    }
                }
                else{
                    if(mapLeadLevelWithScore.containsKey(referral.Lead_Score_Level__c)){
                        referral.Lead_Score__c = mapLeadLevelWithScore.get(referral.Lead_Score_LeveL__c);
                        referral.RTL_Lead_Score_Flag__c = true;
                    }
                }
            }
            
            
            
            if(referralWithCust.size() > 0){
                //query account information to stamp on referral record
                Map<Id,Account> accountMap = queryAccount(accountIdSet);
                setAccountInfo(referralWithCust,accountMap);
            }
            
            if(referralToUpdate.size() > 0){
                updateFirstContactedInfo(referralToUpdate);
                updateClosedInfo(referralToUpdate);
            }
             
            if(retailProductIdSet.size() > 0){
                Map<Id,RTL_Product_Master__c> productMap = queryRetailProduct(retailProductIdSet);
                for(RTL_Referral__c referral : referralWithRetailProduct){
                       referral.RTL_Reporting_Product__c = productMap.get(referral.RTL_Product_Name__c).Product_Group__c;
                }
            }
            
            
            
            
            new RTL_ReferralAssignment(newList);
            Set<Id> ownerIdSet = new Set<Id>();
            for(RTL_Referral__c referral : newList){
                ownerIdSet.add(referral.OwnerId);
            }
            Map<Id, User> userMap = queryUser(ownerIdSet);
            Map<Id, Group> queueMap = queryQueue(ownerIdSet);
            updateLastAssignedInfo(newList);
            updateOwnerInfo(newList,userMap,queueMap);
    
            autoStampContactAddress(newList);
            //update Before over SLA 
            updateBeforeOverSLA(newList);
    
        }
        
        public static void handleAfterInsert(List<RTL_Referral__c> newList){
            List<CampaignMember> listcmtoUpdateLeadScore = new List<CampaignMember>();
            List<Lead> Leadupdatedlist = new List<Lead>();
            manualShareCreatorRecord(newList);
            sendToCallMeNowService(newList);
            String RetailCrossChannel_RecordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Cross Channel Referral').getRecordTypeId();
            String ReferToRetail_RecordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Retail').getRecordTypeId();
            List<RTL_Referral__c> emailSendRefId = new List<RTL_Referral__c>();
            for(RTL_Referral__c ref : newList){
                System.debug('RecordId :'+ ref.RecordTypeId);
                System.debug('Stage : '+ ref.RTL_Stage__c);
    
                if((ref.RecordTypeId == RetailCrossChannel_RecordTypeId || ref.RecordTypeId == ReferToRetail_RecordTypeId) && ref.RTL_Stage__c == 'New'){
                    emailSendRefId.add(ref);
                }
                

                if(ref.RTL_Campaign_Member__c != null && ref.RTL_Lead_Score_Flag__c != null){
                    CampaignMember cm = new CampaignMember();
                    cm.Id = ref.RTL_Campaign_Member__c;
                    cm.Lead_Score__c = ref.Lead_Score__c;
                    cm.Lead_Score_Level__c = ref.Lead_Score_LeveL__c;
                    cm.RTL_Lead_Score_Flag__c = true;
                    CampaignMember cmWithLead = [SELECT Id,Lead_Score__c,Lead_Score_Level__c,LeadId FROM CampaignMember WHERE Id =: cm.Id LIMIT 1];
                    if(cmWithLead.LeadId != null){
                        Lead updateLead = new Lead();
                        updateLead.Id = cmWithLead.leadId;
                        updateLead.Lead_Score__c = ref.Lead_Score__c;
                        updateLead.Lead_Score_Level__c =ref.Lead_Score_Level__c;
                        System.debug('Update Lead when insert ref: '+ updateLead);
                        Leadupdatedlist.add(updateLead);
                    }
                    listcmtoUpdateLeadScore.add(cm);
                }
            }
            createdReferralEmailNotification(emailSendRefId);  
            if(listcmtoUpdateLeadScore.size() > 0){
                update listcmtoUpdateLeadScore;  
            }
            if(Leadupdatedlist.size() > 0){
                try{
                    update Leadupdatedlist;
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }
        
        public static void handleBeforeUpdate(Map<Id,RTL_Referral__c> oldMap,Map<Id,RTL_Referral__c> newMap){
            List<RTL_Referral__c> referralWithCust = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralToClosed = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralToFirstContacted = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralOwnerChanged = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralAssign  = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralWithRetailProduct = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralCalLeadScore = new List<RTL_Referral__c>();

            
            Set<Id> retailProductIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> ownerIdSet = new Set<Id>();
            Map<Id,Opportunity> opportunityMap = queryOpportunity(newMap.keySet());
            Map<Id,UserRecordAccess> recordAccessMap = queryRecordaccess(newMap.keySet());
            
            System.debug('Referral Before Update');
            for(Id referralId : newMap.keySet()){
                RTL_Referral__c newReferral = newMap.get(referralId);
                RTL_Referral__c oldReferral = oldMap.get(referralId);
                System.debug(newReferral);
                System.debug(oldReferral);
    
                UserRecordAccess recordAccess = recordAccessMap.containsKey(referralId)?recordAccessMap.get(referralId):null; 
                    
                newReferral.RTL_Reporting_Product__c = String.ValueOf(newReferral.RTL_Interested_Product__c);
    
                // if(newReferral.RTL_Is_Send_To_HPAP__c){
                //     newReferral.wsUpdateFlag__c = false;
                // }else{
                //     newReferral.wsUpdateFlag__c = true;
                // }
    
                
                //If Stage Changed
                if(newReferral.RTL_Stage__c != oldReferral.RTL_Stage__c){
                    //if New to Closed ,Invalid (Duplicate Opportunity) , In progress
                    if((oldReferral.RTL_Stage__c == 'New' && 
                        (newReferral.RTL_Stage__c.containsIgnoreCase('Closed') || newReferral.RTL_Stage__c == 'Invalid (Duplicate Opportunity)'))||
                        newReferral.RTL_Stage__c == 'In progress_Contacted'){
                        referralToFirstContacted.add(newReferral);
                    }
                    
                    //prevent users from Closed (Interested) Referral without opportunity
                    if(newReferral.RTL_Stage__c == 'Closed (Interested)' && 
                       (opportunityMap.containsKey(newReferral.id) == false && 
                        RTL_ReferralOpportunityService.isOpportunityTrigger == false)){
                        newReferral.addError(System.Label.RTL_Referral_ERR006);
                    }
                    //6 June 2018 , BAU Issue #7122 user able to choose Closed (Transferred)
                    if(newReferral.RTL_Stage__c == 'Closed (Transferred)' && newReferral.Is_Transfer_Page__c == false && isBeforeUpdate == false){               
                        newReferral.addError(System.Label.RTL_Referral_ERR022);
                    }
                    if(newReferral.Is_Transfer_Page__c == true){
                        newReferral.Is_Transfer_Page__c = false;
                    }
                    //If any stage to closed
                    if(newReferral.RTL_Stage__c.containsIgnoreCase('Closed') || newReferral.RTL_Stage__c == 'Invalid (Duplicate Opportunity)' || newReferral.RTL_Stage__c == 'Cancel'){
                        referralToClosed.add(newReferral);
                    }
    
                }
                
                if(newReferral.RTL_Account_Name__c != null && newReferral.RTL_Account_Name__c != oldReferral.RTL_Account_Name__c){
                    referralWithCust.add(newReferral);
                    accountIdSet.add(newReferral.RTL_Account_Name__c);
                }
                            
                //if owner changed
                if(newReferral.OwnerId != oldReferral.OwnerId){
                    //Accept Referral from Accept Button
                    if(newReferral.OwnerId == System.UserInfo.getUserId() && newReferral.RTL_Is_Accept_Button__c == true){
                        newReferral.RTL_Is_Accept_Button__c = false;
                        if(currentUser.Profile.Name.containsIgnoreCase('Retail') == false && recordAccess != null && recordAccess.hasTransferAccess == false){
                            newReferral.addError(System.Label.RTL_Referral_ERR003);
                        }else if(currentUser.Profile.Name.containsIgnoreCase('Retail') == true && oldReferral.RTL_isUserinQueue__c == false ){
                            newReferral.addError(System.Label.RTL_Referral_ERR003);
                        }
                    }
                    //Assign Referral
                    else{
                        referralAssign.add(newReferral);
                    }
                    ownerIdSet.add(newReferral.OwnerId);
                    referralOwnerChanged.add(newReferral);
                }
                //if other field change
                else{
                    /*Valiate if current use is retail or commercial user which don't have transfer permission
                    and if not referral owner 
                    and not come from before insert trigger
                    and if not call me now fields
                    don't allow edit referral record
                    */
                    /* CR AL Re-org Long Term 
                    add Profile App External API for edit 
                    */
                    // List<String> valid_product = new List<String>{'CYC','CYB','NEW','USED'};
                    // if(newReferral.RTL_Product_Name__c != null && newReferral.RTL_Preferred_Branch__c != null && valid_product.contains(newReferral.RTL_Product_Name_Str__c) && newReferral.RTL_Preferred_Branch_Name__c == 'AL Marketing'){
                    //    if(newReferral.RTL_Product_Name__c != oldReferral.RTL_Product_Name__c || newReferral.RTL_Preferred_Branch_Name__c != oldReferral.RTL_Preferred_Branch_Name__c){
                    //         newReferral.Is_Update_Refer__c = true;
                    //    }
                    //     if (newReferral.Is_Send_to_HPAP_Done__c == true && oldReferral.Is_Send_to_HPAP_Done__c == true && newReferral.CheckClickSubmit__c == oldReferral.CheckClickSubmit__c ){
                    //         System.debug('Set HPAP DONE : FALSE');
                    //         newReferral.Is_Send_to_HPAP_Done__c = false;
                    //     }
                    //     if( newReferral.countsendHPAP__c == oldReferral.countsendHPAP__c && newReferral.RTL_Is_Send_To_HPAP__c == false && (newReferral.countsendHPAP__c == 2 || newReferral.countsendHPAP__c == 1 || 
                    //     (newReferral.countsendHPAP__c == 0  && newReferral.Is_Update_Refer__c == oldReferral.Is_Update_Refer__c && newReferral.Is_Update_Refer__c == true) || 
                    //     (newReferral.countsendHPAP__c == 0  && newReferral.Is_Update_Refer__c != oldReferral.Is_Update_Refer__c && newReferral.Is_Update_Refer__c == true && (!valid_product.contains(oldReferral.RTL_Product_Name_Str__c) || oldReferral.RTL_Preferred_Branch_Name__c != 'AL Marketing' ))) 
                    //     && newReferral.CheckClickSubmit__c == oldReferral.CheckClickSubmit__c){ 
                    //         System.debug('Reset!');
                    //         newReferral.countsendHPAP__c = 9;
                    //         newReferral.wsUpdateFlag__c = true;
                    //     }
                    // }
                    
                    if(currentUser.Profile.Name.containsIgnoreCase('App External API') == false )
                    {
                        if((currentUser.Profile.Name.containsIgnoreCase('Retail') == true || recordAccess != null && recordAccess.HasTransferAccess == false) && 
                            newReferral.RTL_Is_Owner__c == false && isBeforeInsert == false && 
                            newReferral.RTL_From_Call_Me_Now__c == false ){
                            
                            newReferral.addError(System.Label.RTL_Referral_ERR004);
                        }
                    }
                    //reset from call me now flag
                    if(newReferral.RTL_From_Call_Me_Now__c == true){
                        newReferral.RTL_From_Call_Me_Now__c = false;
                    }
                }
                
                if(newReferral.RTL_Product_Name__c != null){
                    retailProductIdSet.add(newReferral.RTL_Product_Name__c);
                    referralWithRetailProduct.add(newReferral);
                }else{
                    newReferral.RTL_Reporting_Product__c = null;
                }
                
                if(newReferral.RTL_Interested_Product__c != null){
                    newReferral.RTL_Reporting_Product__c = sortMultiInterestedProduct(newReferral.RTL_Interested_Product__c);
                }else{
                    newReferral.RTL_Reporting_Product__c = null;
                }
                
                
                    
                //Clear Acccount Info if Account lookup to Referral is null
                if(newReferral.RTL_Account_Name__c != oldReferral.RTL_Account_Name__c && newReferral.RTL_Account_Name__c == null){
                    newReferral.RTL_Wealth_RM__c = null;
                    newReferral.RTL_Segment__c = null;
                    newReferral.RTL_TMB_Customer_ID__c = null;
                    newReferral.RTL_Privilege__c = null;
                    newReferral.RTL_Customer_Type__c = null;
                    newReferral.RTL_RM_Owner__c = null;
                    newReferral.RTL_RM_Owner_Id__c = null;
                    newReferral.RTL_Wealth_RM_Id__c = null;
                    newReferral.RTL_EMP_BR_Code__c = null;
                    newReferral.RTL_Is_BM__c = false;
                }

                // LGS Set Lead Score
                if(newReferral.Lead_Score_Level__c != null && newReferral.Lead_Score_Level__c != oldReferral.Lead_Score_Level__c && newReferral.RTL_Is_Send_To_HPAP__c == false){
                    referralCalLeadScore.add(newReferral);
                }
    
            }
            //If Owner Changed
            if(referralOwnerChanged.size() > 0){
                Map<Id, User> userMap = queryUser(ownerIdSet);
                Map<Id, Group> queueMap = queryQueue(ownerIdSet);
                updateOwnerInfo(referralOwnerChanged,userMap,queueMap);
                
            }
            
            if(referralAssign.size() > 0){
                updateLastAssignedInfo(referralAssign);
            }
    
            
            if(referralWithCust.size() > 0){
                //query account information to stamp on referral record
                Map<Id,Account> accountMap = queryAccount(accountIdSet);
                setAccountInfo(referralWithCust,accountMap);
            }
            
            
            
            if(referralToFirstContacted.size() > 0){
                updateFirstContactedInfo(referralToFirstContacted);
            }
            
            if(referralToClosed.size() > 0){
                updateClosedInfo(referralToClosed);
            }
    
            autoStampContactAddress(newMap.values());
            
            if(retailProductIdSet.size() > 0){
                Map<Id,RTL_Product_Master__c> productMap = queryRetailProduct(retailProductIdSet);
                for(RTL_Referral__c referral : referralWithRetailProduct){
                       referral.RTL_Reporting_Product__c = productMap.get(referral.RTL_Product_Name__c).Product_Group__c;
                }
            }
            if(referralCalLeadScore.size() > 0){
                Map<String,Integer> mapLeadLevelwithScore = new Map<String,Integer>();
                for(Lead_Score_Level__c lv : [SELECT Id,Name,Score_Min__c FROM Lead_Score_Level__c]){
                    mapLeadLevelwithScore.put(lv.Name,Integer.valueOf(lv.Score_Min__c));
                }
                for(RTL_Referral__c ref : referralCalLeadScore){
                    if(mapLeadLevelwithScore.containsKey(ref.Lead_Score_Level__c)){
                        ref.Lead_Score__c = mapLeadLevelwithScore.get(ref.Lead_Score_Level__c);
                    }
                }
            }
            isBeforeUpdate = true;
    
        }
        
        public static void handleAfterUpdate(Map<Id,RTL_Referral__c> oldMap,Map<Id,RTL_Referral__c> newMap){
            List<RTL_Referral__c> referralToShare = new List<RTL_Referral__c>();
            List<RTL_Referral__c> newReferralList = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralChangeAccontList = new List<RTL_Referral__c>();
            List<RTL_Referral__c> referralChangeOwnerList = new List<RTL_Referral__c>();
            Set<Id> refIdCallAPI = new Set<Id>();
            List<RTL_Referral__c> referraltoUpdateCMLeadScore = new List<RTL_Referral__c>();

            
            for(Id referralId : newMap.keySet()){ 
                RTL_Referral__c newReferral = newMap.get(referralId);
                RTL_Referral__c oldReferral = oldMap.get(referralId);
    
    
                // if(newReferral.countsendHPAP__c != null && Integer.valueOf(newReferral.countsendHPAP__c) == 9 && newReferral.RTL_Is_Send_To_HPAP__c == false && newReferral.wsUpdateFlag__c == true){
                //     System.debug('Edit auto send referral'); 
                //     refIdCallAPI.add(referralId);
                // }
                // else{
                //     RTL_Referral__c newRef = new RTL_Referral__c();
                //     newRef.Id = referralId;
                //     newRef.Is_Send_to_HPAP_Done__c = true;
                //     refUpdateIsSendDone.add(newRef);
                // }
                //If owner changed
                if(newReferral.OwnerId != oldReferral.OwnerId){
                    referralToShare.add(oldReferral);
                    newReferralList.add(newReferral);
                    if(newReferral.FNA_Activity__c != null){
                        referralChangeOwnerList.add(newReferral);
                    }
                }
    
                if( newReferral.FNA_Activity__c != null && newReferral.RTL_Account_Name__c != oldReferral.RTL_Account_Name__c){
                    referralChangeAccontList.add(newReferral);
                }
                if( newReferral.Lead_Score__c != null && newReferral.Lead_Score__c != oldReferral.Lead_Score__c && newReferral.RTL_Campaign_Member__c != null && newReferral.RTL_Is_Send_To_HPAP__c == false){
                    referraltoUpdateCMLeadScore.add(newReferral);
                }
    
            }
            // if(refIdCallAPI.size() > 0){
            //     RTL_AL_SubmitHPAPCtrl.callAPIcreateReferral(refIdCallAPI,true);
            // }
            //share record back as 'Read' to last owner
            if(referralToShare.size() > 0){
                manualShareLastOwnerRecord(referralToShare);
            }
            if(newReferralList.size() > 0){
                updateOwnerOrderAllInReferral(newReferralList);
            }
    
            if(referralChangeAccontList.size() > 0){
                updateCustomerFnaActivity(referralChangeAccontList, oldMap);
            }
    
            if(referralChangeOwnerList.size() > 0){
                updateOwnerLead(referralChangeOwnerList);            
            }
            System.debug('referraltoUpdateCMLeadScore' + referraltoUpdateCMLeadScore.size());
            if(referraltoUpdateCMLeadScore.size() > 0){
                updateCMLeadScore(referraltoUpdateCMLeadScore);
            }
    
            retrySendToCallMeNowService(oldMap,newMap);
            
            afterUpdateReferraltoCampaignMember(oldMap,newMap); 
        
    }
    public static void afterUpdateReferraltoCampaignMember(map<id,RTL_Referral__c> oldMap, map<id,RTL_Referral__c> newMap) {
        
        List<CampaignMember> cmlistr =  [SELECT id,RTL_Contact_Status__c,RTL_Referral_ID_1__c,RTL_Referral_ID_2__c,RTL_Referral_ID_3__c,RTL_Referral_ID_4__c,RTL_Referral_ID_5__c FROM CampaignMember WHERE RTL_Referral_ID_1__c IN: newMap.keySet() OR RTL_Referral_ID_2__c IN: newMap.keySet() OR RTL_Referral_ID_3__c IN: newMap.keySet() OR RTL_Referral_ID_4__c IN: newMap.keySet() OR RTL_Referral_ID_5__c IN: newMap.keySet()];
        //system.debug('test' + cmlist.size());
        Set<Id> refId = newMap.keySet();
        Set<Id> refCampaignId = new Set<Id>();
        Set<Id> refCrossSellId = new Set<Id>();
        System.debug('cmref '+cmlistr);
        System.debug('refid '+newMap.keySet());
        for(CampaignMember each : cmlistr){
            if(each.RTL_Referral_ID_1__c != null && newMap.containsKey(each.RTL_Referral_ID_1__c)){
                each.RTL_Stage_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Ws_Stage__c'));
                each.RTL_Status_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Status__c'));
                each.Details_of_Status_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('HPAP_Reason_Description__c'));

                each.RTL_Refer_Date_1__c = Datetime.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Refer_Date__c'));
                if(each.RTL_Contact_Status__c == 'New' || each.RTL_Contact_Status__c == 'Uncontact'){
                    each.RTL_Contact_Status__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Contact_Status__c'));
                    each.RTL_Reason__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Ws_Reason__c'));
                }
                each.Corebank_Branch_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Branch_Code__c'));
                each.Corebank_Branch_Name_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Branch_Name__c'));
                each.Corebank_Sales_Manager_Head_Id_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Sales_Manager_Head_Id__c'));
                each.Corebank_Sales_Manager_Head_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('Corebank_Sales_Manager_Head__c'));
                each.RTL_Product_Campaign_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Product_Campaign_Code__c'));
                each.RTL_Product_Campaign_Name_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Product_Campaign_Name__c'));
                each.RTL_Dealer_Code_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Dealer_Code__c'));
                each.RTL_Dealer_Name_1__c = String.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Dealer_Name__c'));
                each.RTL_Stage_Name_Date_Time_1__c = Datetime.valueOf(newMap.get(each.RTL_Referral_ID_1__c).get('RTL_Stage_Name_Date_Time__c'));

                refCampaignId.add(each.RTL_Referral_ID_1__c);
            }
            if(each.RTL_Referral_ID_2__c != null && newMap.containsKey(each.RTL_Referral_ID_2__c)){
                each.RTL_Stage_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_Ws_Stage__c'));
                each.RTL_Status_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_Status__c'));
                each.Details_of_Status_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_2__c = String.valueOf(newMap.get(each.RTL_Referral_ID_2__c).get('HPAP_Reason_Description__c'));
                refCampaignId.add(each.RTL_RelatedOpportunity_2__c);
            
            }
            if(each.RTL_Referral_ID_3__c != null && newMap.containsKey(each.RTL_Referral_ID_3__c)){
                each.RTL_Stage_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_Ws_Stage__c'));
                each.RTL_Status_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_Status__c'));
                each.Details_of_Status_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_3__c = String.valueOf(newMap.get(each.RTL_Referral_ID_3__c).get('HPAP_Reason_Description__c'));
                refCampaignId.add(each.RTL_RelatedOpportunity_3__c);
            }
            if(each.RTL_Referral_ID_4__c != null && newMap.containsKey(each.RTL_Referral_ID_4__c)){
                each.RTL_Stage_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_Ws_Stage__c'));
                each.RTL_Status_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_Status__c'));
                each.Details_of_Status_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_4__c = String.valueOf(newMap.get(each.RTL_Referral_ID_4__c).get('HPAP_Reason_Description__c'));
                refCampaignId.add(each.RTL_RelatedOpportunity_4__c);
            }
            if(each.RTL_Referral_ID_5__c != null && newMap.containsKey(each.RTL_Referral_ID_5__c)){
                each.RTL_Stage_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_Ws_Stage__c'));
                each.RTL_Status_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_Status__c'));
                each.Details_of_Status_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_5__c = String.valueOf(newMap.get(each.RTL_Referral_ID_5__c).get('HPAP_Reason_Description__c'));
                refCampaignId.add(each.RTL_RelatedOpportunity_5__c);
            }       
         }
         
        
        for(Id Id : refId){
            if(!refCampaignId.contains(Id)){
                refCrossSellId.add(Id);
            }
        }
        System.debug('Cross_Sell_Product__c Size :' + refCrossSellId.size());
        List<Cross_Sell_Product__c> crossSelllist = [SELECT Id,ReferralID__c FROM Cross_Sell_Product__c WHERE ReferralID__c IN: refCrossSellId];
        
        for(Cross_Sell_Product__c each : crossSelllist){
                each.RTL_Stage__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Stage__c'));
                each.RTL_Status__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Status__c'));
                each.Details_of_Status__c = String.valueOf(newMap.get(each.ReferralID__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description__c = String.valueOf(newMap.get(each.ReferralID__c).get('HPAP_Reason_Description__c'));
                
                each.RTL_Refer_Date__c = Datetime.valueOf(newMap.get(each.ReferralID__c).get('RTL_Refer_Date__c'));
                each.Corebank_Branch_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Branch_Code__c'));
                each.Corebank_Branch_Name__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Branch_Name__c'));
                each.Corebank_Sales_Manager_Head_Id__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Sales_Manager_Head_Id__c'));
                each.Corebank_Sales_Manager_Head__c = String.valueOf(newMap.get(each.ReferralID__c).get('Corebank_Sales_Manager_Head__c'));
                each.RTL_Product_Campaign_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Product_Campaign_Code__c'));
                each.RTL_Product_Campaign_Name__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Product_Campaign_Name__c'));
                each.RTL_Dealer_Code__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Dealer_Code__c'));
                each.RTL_Dealer_Name__c = String.valueOf(newMap.get(each.ReferralID__c).get('RTL_Dealer_Name__c'));
                each.RTL_Stage_Name_Date_Time__c = Datetime.valueOf(newMap.get(each.ReferralID__c).get('RTL_Stage_Name_Date_Time__c'));
        }
    
        if(cmlistr.size() > 0){
            update cmlistr;
        }
        if(crossSelllist.size() > 0 ){
            update crossSelllist;
        }
            
        }
        
        private static void setAccountInfo(List<RTL_Referral__c> referralList , Map<Id,Account> accountMap){
            Set<String> employeeIdSet = new Set<String>();
            
            for(Account acct : accountMap.values()){
                if(acct.RTL_RM_Name__c!= null && !acct.RTL_RM_Name__c.startsWith('00')){
                    employeeIdSet.add(acct.RTL_RM_Name__c);
                }
            }
            if(employeeIdSet.size()>0){
                queryUser(employeeIdSet);
            }
            for(RTL_Referral__c referral : referralList){
                Account acct = accountMap.get(referral.RTL_Account_Name__c);
                //get wealth rm user information
                User rmUser = getRMUser(acct.RTL_RM_Name__c);
                //assign wealth rm information 
                if(rmUser != null){
                    referral.RTL_Wealth_RM__c = rmUser.Name;
                    referral.RTL_Wealth_RM_ID__c = rmUser.id;
                    if(rmUser.IsActive == false){
                        referral.RTL_Wealth_RM__c += ' (INACTIVE)';
                    }
                    
                }
    
                referral.RTL_Segment__c = acct.Core_Banking_Suggested_Segment__c;
                referral.RTL_TMB_Customer_ID__c = acct.TMB_Customer_ID_PE__c;
                referral.RTL_Privilege__c = acct.RTL_Privilege1__c;
                referral.RTL_Customer_Type__c = acct.Account_Type__c;
                referral.RTL_Owner_Role__c = acct.Owner.UserRole.Name;
                referral.RTL_EMP_BR_Code__c = acct.RTL_RM_Name__c;
                if(acct.RTL_RM_Name__c != null){
                    string empBRCode = acct.RTL_RM_Name__c;
                    referral.RTL_Is_BM__c = empBRCode.startsWith('00');
                }
                if(referral.RTL_RecordType_Name__c == 'Retail Cross Channel Referral' 
                    || referral.RTL_RecordType_Name__c == 'Retail Order Transaction'){ // CH01
                    referral.RTL_FirstName__c = referral.RTL_FirstName__c==null?acct.First_Name_PE__c:referral.RTL_FirstName__c;
                    referral.RTL_LastName__c = referral.RTL_LastName__c==null?acct.Last_name_PE__c:referral.RTL_LastName__c;
                    referral.RTL_Email__c = referral.RTL_Email__c==null?acct.Email_Address_PE__c:referral.RTL_Email__c;
                    referral.RTL_Mobile1__c = referral.RTL_Mobile1__c==null?acct.Mobile_Number_PE__c:referral.RTL_Mobile1__c;
    
                }
                
                if(acct.Account_Type__c != 'Retail Customer' && acct.Account_Type__c != 'Retail Prospect'){
                    referral.RTL_RM_Owner__c = acct.Owner.Name;
                    referral.RTL_RM_Owner_Id__c = acct.Owner.Id;
                    
                }
                //Map Sales amount per year with segment of existing customer
                if(acct.Account_Type__c == 'Existing Customer'){
                    referral.RTL_Sales_Amount_Per_Year__c = getSalesAmountPerYear(referral.RTL_Segment__c);
                }
            }
        }
        
        private static void manualShareCreatorRecord(List<RTL_Referral__c> referralList){
            System.debug('Start Share for Creator');
            List<RTL_Referral__Share> referralShares  = new List<RTL_Referral__Share>();
    
            // For each of the Job records being inserted, do the following:
            for(RTL_Referral__c referral : referralList){
                if(referral.RTL_RecordType_Name__c != 'Retail Cross Channel Referral'
                || referral.RTL_RecordType_Name__c == 'Retail Order Transaction'){ // CH01
                    System.debug('Share to '+referral.CreatedById);
                    // Create a new RTL_Referral__Share record to be inserted in to the RTL_Referral__Share table.
                    RTL_Referral__Share priorOwnerShare = createManualShare(referral.id,referral.CreatedById,'Edit',Schema.RTL_Referral__Share.RowCause.Creator_Sharing__c);
                    // Add the new Share record to the list of new Share records.
                    referralShares.add(priorOwnerShare);
                }
            
            }
            
            if(referralShares.size() > 0){
                // Insert all of the newly created Share records and capture save result 
                Database.SaveResult[] referralShareInsertResult = Database.insert(referralShares,false); 
                System.debug(referralShareInsertResult);
            }
            
        }
        
        private static void sendToCallMeNowService(List<RTL_Referral__c> referralList){
            Set<Id> avayaIdList = new Set<Id>();
            List<Id> ciscoIdList = new List<Id>();
            System.debug('referralList : '+referralList);
            // For each of the Job records being inserted, do the following:
            System.debug('Start sendToCallMeNowService ++++++');
            List<Id> referralId = new List<Id>(); 
            for(RTL_Referral__c referral : referralList){
                system.debug('sendToCallMeNowService');
                system.debug('OwnerId : ' + referral.OwnerId);
                system.debug('RTL_Send_To_Call_Me_Now_Flag__c : ' + referral.RTL_Send_To_Call_Me_Now_Flag__c);
                system.debug('RTL_Campaign_Reference__c : ' + referral.RTL_Campaign_Reference__c);
                system.debug('RTL_RecordType_Name__c : ' + referral.RTL_RecordType_Name__c);
                if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Cisco' && (referral.RTL_Campaign_Reference__c == 'Call Me Now' || referral.RTL_RecordType_Name__c == 'Retail Cross Channel Referral')){
                    ciscoIdList.add(referral.Id);
                    System.debug('ciscoIdList1 Check : '+ciscoIdList);
                }else if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Cisco' && referral.RecordTypeId == Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer from Digital Channel').getRecordTypeId()){
                    ciscoIdList.add(referral.Id);
                    System.debug('ciscoIdList2 Check : '+ciscoIdList);
                }else if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Cisco'){
                    ciscoIdList.add(referral.Id);
                    System.debug('ciscoIdList3 Check : '+ciscoIdList);
                }if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Avaya' && (referral.RTL_Campaign_Reference__c == 'Call Me Now' || referral.RTL_RecordType_Name__c == 'Retail Cross Channel Referral')){
                    avayaIdList.add(referral.Id);
                    System.debug('avayaIdList1 Check : '+avayaIdList);
                }else if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Avaya' && referral.RecordTypeId == Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer from Digital Channel').getRecordTypeId()){
                    avayaIdList.add(referral.Id);
                    System.debug('avayaIdList2 Check : '+avayaIdList);
                }else if(referral.OwnerId != null && referral.RTL_Send_To_Call_Me_Now_Flag__c == 'Avaya'){
                    avayaIdList.add(referral.Id);
                    System.debug('avayaIdList3 Check : '+avayaIdList);
                }
            
            }
            System.debug('ciscoIdList.size() : '+ciscoIdList.size());
            if(ciscoIdList.size() > 0){
                System.debug('sendToCallMeNowService ++++++' + ciscoIdList.size());
                CallMeNowBatch callmeNow = new CallMeNowBatch(ciscoIdList);
                DataBase.executeBatch(callmeNow,100);
            }
            System.debug('avayaIdList.size() : '+avayaIdList.size());
            if(avayaIdList.size() > 0){
                System.debug('sendToavayaCallListReferralBatch ++++++' + avayaIdList.size());
                //avayaCallListReferralBatch avayaCall = new avayaCallListReferralBatch(avayaIdList);
                // CallMeNowBatch callmeNow = new CallMeNowBatch(referralId);
                //DataBase.executeBatch(avayaCall, 100);
            }
           
        }
    
        private static void retrySendToCallMeNowService(Map<Id,RTL_Referral__c> oldMap,Map<Id,RTL_Referral__c> newMap){
            // For each of the Job records being updated, do the following:
            Set<Id> avayaIdList = new Set<Id>();
            List<Id> ciscoIdList = new List<Id>();
            List<Id> referralId = new List<Id>(); 
            for(RTL_Referral__c referral : newMap.values()){
                RTL_Referral__c oldValue = oldMap.get(referral.id);
                RTL_Referral__c newValue = newMap.get(referral.id);
                System.debug('old request count' + oldValue.RTL_Call_Me_Now_Request_Count__c);
                System.debug('new request count' + newValue.RTL_Call_Me_Now_Request_Count__c);
                // System.debug('call me now flag' + newValue.RTL_Send_To_Call_Me_Now_Flag__c);
                System.debug('call me now status' + newValue.RTL_Call_Me_Now_Status__c);
                //if request count changed , this value will count+1 when callout fail
                if(oldValue.RTL_Call_Me_Now_Request_Count__c != newValue.RTL_Call_Me_Now_Request_Count__c){
                    system.debug('retrySendToCallMeNowService');
                    system.debug('OwnerId : ' + newValue.OwnerId);
                    // system.debug('RTL_Send_To_Call_Me_Now_Flag__c : ' + newValue.RTL_Send_To_Call_Me_Now_Flag__c);
                    system.debug('RTL_Call_Me_Now_Status__c : ' + newValue.RTL_Call_Me_Now_Status__c);
                    system.debug('RTL_Call_Me_Now_Request_Count__c : ' + newValue.RTL_Call_Me_Now_Request_Count__c);
                    if(newValue.OwnerId != null && newValue.RTL_Send_To_Call_Me_Now_Flag__c == 'Cisco' && newValue.RTL_Call_Me_Now_Status__c == 'fail' && newValue.RTL_Call_Me_Now_Request_Count__c < 3){
                        ciscoIdList.add(newValue.Id);
                    }
                    if(newValue.OwnerId != null && newValue.RTL_Send_To_Call_Me_Now_Flag__c == 'Avaya' && newValue.RTL_Call_Me_Now_Status__c == 'fail' && newValue.RTL_Call_Me_Now_Request_Count__c < 3){
                        avayaIdList.add(newValue.Id);
                    }
                }            
            
            }
    
            if(ciscoIdList.size() > 0){
                CallMeNowBatch callmeNow = new CallMeNowBatch(ciscoIdList);
                DataBase.executeBatch(callmeNow,100);
            }
            if(avayaIdList.size() > 0){
                // avayaCallListReferralBatch avayaCall = new avayaCallListReferralBatch(avayaIdList);
                // DataBase.executeBatch(avayaCall,100);
            }
            
        }
        
        private static void manualShareLastOwnerRecord(List<RTL_Referral__c> referralList){
            List<RTL_Referral__Share> referralShares  = new List<RTL_Referral__Share>();
    
            // For each of the Job records being inserted, do the following:
            for(RTL_Referral__c referral : referralList){
                if(string.valueOf(referral.OwnerId).startsWith('005') && (referral.RTL_RecordType_Name__c == 'Refer to Commercial' || referral.RTL_RecordType_Name__c == 'Refer Within Commercial' )){
                    // Create a new RTL_Referral__Share record to be inserted in to the RTL_Referral__Share table.
                    RTL_Referral__Share priorOwnerShare = createManualShare(referral.id,referral.OwnerId,'Edit',Schema.RTL_Referral__Share.RowCause.Prior_Owner_Sharing__c);
                    // Add the new Share record to the list of new Share records.
                    referralShares.add(priorOwnerShare);
                }
            
            }
            
            if(referralShares.size() > 0){
                // Insert all of the newly created Share records and capture save result 
                Database.SaveResult[] referralShareInsertResult = Database.insert(referralShares,false);   
            }
                 
        }
        /*-------------------Start CH01-----------------------*/
        private static void updateOwnerOrderAllInReferral(List<RTL_Referral__c> referralList){
            Map<Id,RTL_Referral__c> mapReferralId = new Map<Id,RTL_Referral__c>();
            for(RTL_Referral__c eachReferralList : referralList){
                mapReferralId.put(eachReferralList.id,eachReferralList);
            }
    
            List<Order> listOrder = new List<Order>();
            for(Order eachOrder : [SELECT Id, OwnerId, RTL_Referral__c FROM Order WHERE RTL_Referral__c IN:referralList]){
                if(mapReferralId.containsKey(eachOrder.RTL_Referral__c)){
                    eachOrder.OwnerId = mapReferralId.get(eachOrder.RTL_Referral__c).OwnerId;
                    listOrder.add(eachOrder);
                }
            }
            if(listOrder.size() > 0){
                // Insert the channel referral records
                Database.SaveResult[] lsr = Database.update(listOrder, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully update Order Owner if change Owner Referral.');
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(logginglevel.ERROR, 'There is error update Order Owner if change Owner Referral. Error Message is: ' + err.getMessage());
                        }
                    }
                }           
            }
    
        }
        /*-------------------End CH01-----------------------*/
        
        private static RTL_Referral__Share createManualShare(String parentId,String userOrGroupId,String accessLevel,String cause){
            RTL_Referral__Share priorOwnerShare = new RTL_Referral__Share();
            // Populate the RTL_Referral__Share record with the ID of the record to be shared.
            priorOwnerShare.ParentId = parentId;
            priorOwnerShare.UserOrGroupId = userOrGroupId;
               priorOwnerShare.AccessLevel = accessLevel;
            priorOwnerShare.RowCause = cause;
            return priorOwnerShare;
        }
        private static void updateFirstContactedInfo(List<RTL_Referral__c> referralList){
            for(RTL_Referral__c referral : referralList){
                referral.RTL_First_Contacted_Date__c = System.now();/*Type : Datetime*/
                referral.RTL_First_Contacted_Date2__c = System.today();/*CR SLA Exclude Weekend*/
                referral.RTL_First_Contacted_Name__c = currentUser.Name;
                referral.RTL_First_Contacted_Branch_Team_NameCode__c  = currentUser.RTL_Branch__c;
                referral.RTL_First_Contacted_Branch_Code__c = currentUser.RTL_Branch_Code__c;
                referral.RTL_First_Contacted_Region__c = currentUser.Region__c;
                referral.RTL_First_Contacted_Region_Code__c = currentUser.Region_Code__c;
                referral.RTL_First_Contacted_Zone__c  = currentUser.Zone__c;
                referral.RTL_First_Contacted_Zone_Code__c = currentUser.Zone_Code__c;
                referral.RTL_First_Contacted_Segment__c  = currentUser.RTL_Channel__c==null?currentUser.Segment__c:currentUser.RTL_Channel__c;
                referral.RTL_First_Contacted_Reporting_Segment__c  = currentUser.Reporting_Segment__c;     
            }
        }
        
        private static void updateClosedInfo(List<RTL_Referral__c> referralList){
    
            for(RTL_Referral__c referral : referralList){
                referral.RTL_Closed_Date_Time__c  = System.now();
                referral.RTL_Closed_by_Name__c = currentUser.Name;
                referral.RTL_Closed_Date_Branch_Team_Name_Code__c = currentUser.RTL_Branch__c;
                referral.RTL_Closed_Branch_Code__c = currentUser.RTL_Branch_Code__c;
                referral.RTL_Closed_Date_Region__c = currentUser.Region__c;
                referral.RTL_Closed_Date_Region_Code__c = currentUser.Region_Code__c;
                referral.RTL_Closed_Date_Zone__c  = currentUser.Zone__c;
                referral.RTL_Closed_Date_Zone_Code__c = currentUser.Zone_Code__c;
                referral.RTL_Closed_Date_Segment__c  = currentUser.RTL_Channel__c==null?currentUser.Segment__c:currentUser.RTL_Channel__c;
                referral.RTL_Closed_Date_Reporting_Segment__c  = currentUser.Reporting_Segment__c;
          
            }
        }
        
        private static void updateOwnerInfo(List<RTL_Referral__c> referralList,Map<Id,User> userMap,Map<Id,Group> queueMap){
            User user = null;
            Group queue = null;
            String branchCode = null;
            Branch_and_Zone__c branch = null;
            for(RTL_Referral__c referral : referralList){
                user = userMap.get(referral.OwnerId);
                if (user != null){
                    referral.RTL_Owner_Branch__c = user.RTL_Branch__c;
                    referral.RTL_Owner_Branch_Code__c = user.RTL_Branch_Code__c;
                    referral.RTL_Owner_Region__c = user.Region__c;
                    referral.RTL_Owner_Region_Code__c = user.Region_Code__c;
                    referral.RTL_Owner_Zone__c = user.Zone__c;
                    referral.RTL_Owner_Zone_Code__c = user.Zone_Code__c;
                    referral.RTL_Owner_Segment__c = user.RTL_Channel__c==null?user.Segment__c:user.RTL_Channel__c;
                    referral.RTL_Owner_Reporting_Segment__c = user.Reporting_Segment__c;
                    referral.RTL_Owner_Role__c = user.UserRole.Name; 
                    
                } else {
                    //the referral owner could be a branch queue or wealth queue
                    queue = queueMap.get(referral.OwnerId);
                    branchCode = queue.DeveloperName;
                       if (branchCode.indexOf('_') != -1) {
                        branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                    }
                    branch = branchCodeMap.get(branchCode);
                    if (branch != null) {//branch queue
                        referral.RTL_Owner_Branch__c = branch.Name;
                        referral.RTL_Owner_Branch_Code__c = branch.branch_Code__c;
                          referral.RTL_Owner_Region__c = branch.RTL_Region_Retail__c ;
                        referral.RTL_Owner_Region_Code__c = branch.RTL_Region_Code__c; 
                        referral.RTL_Owner_Zone__c = branch.RTL_Zone__c;
                        referral.RTL_Owner_Zone_Code__c = branch.RTL_Zone_Code__c;
                        referral.RTL_Owner_Segment__c = null;
                        referral.RTL_Owner_Reporting_Segment__c = null;
                        referral.RTL_Owner_Role__c = null;        
                    } else {//wealth queue
                        referral.RTL_Owner_Branch__c = null;
                        referral.RTL_Owner_Branch_Code__c = null;
                          referral.RTL_Owner_Region__c = null;
                        referral.RTL_Owner_Region_Code__c = null;  
                        referral.RTL_Owner_Zone__c = null;
                        referral.RTL_Owner_Zone_Code__c = null;
                        referral.RTL_Owner_Segment__c = null;
                        referral.RTL_Owner_Reporting_Segment__c = null;   
                        referral.RTL_Owner_Role__c = null; 
                    }
                    
                }
            }
            
            
        }
        
        private static void updateLastAssignedInfo(List<RTL_Referral__c> referralList){
            for(RTL_Referral__c referral : referralList){
                referral.RTL_Last_Assigned_Date_time__c = System.now();
                referral.RTL_Last_Assigned_Name__c = currentUser.Name;
                referral.RTL_Last_Assigned_Branch_Team_NameCode__c  = currentUser.RTL_Branch__c;
                referral.RTL_Last_Assigned_Branch_Code__c = currentUser.RTL_Branch_Code__c;
                referral.RTL_Last_Assigned_Region__c = currentUser.Region__c;
                referral.RTL_Last_Assigned_Region_Code__c = currentUser.Region_Code__c;
                referral.RTL_Last_Assigned_Zone__c  = currentUser.Zone__c;
                referral.RTL_Last_Assigned_Zone_Code__c = currentUser.Zone_Code__c;
                referral.RTL_Last_Assigned_Segment__c  = currentUser.RTL_Channel__c==null?currentUser.Segment__c:currentUser.RTL_Channel__c;
                referral.RTL_Last_Assigned_Reporting_Segment__c  = currentUser.Reporting_Segment__c;    
            }
            
            
        }
        
        private static String sortMultiInterestedProduct(String products){
            List<String> multiInterestedProduct = new List<String>();
            String reportingProduct = '';
            
            //get value from multipicklist field , split and put into list to do sorting
            multiInterestedProduct.addAll(products.split(';'));
            if(multiInterestedProduct.size() > 0){
                //sort 
                multiInterestedProduct.sort();
                for(String product:multiInterestedProduct) {
                    reportingProduct+=product+'; ';
                    System.debug(product);
                } 
                reportingProduct = reportingProduct.left(reportingProduct.length()-2);
            }
            return reportingProduct;
        }
        
        private static void queryUser(Set<String> employeeIdSet) {
            //get branch title from custom setting
            branchTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager');
            //Loop Through all user which employee id is not null or branch code is not null and is a branch manager
            for(User user : [SELECT ID,Name,ManagerId,Manager.Name,RTL_Branch_Code__c,Employee_Id__c,title,IsActive FROM User 
                             WHERE  (RTL_Branch_Code__c != null AND title =:branchTitle.RTL_Value__c) 
                                     OR Employee_ID__c IN:employeeIdSet ])
            {
                //if Branch Code is not null and is branch manager
                if(user.RTL_Branch_Code__c != null && user.title == branchTitle.RTL_Value__c){
                    branchCodeUserMap.put(user.RTL_Branch_Code__c,user);
                }
                //if Employee Id is not null
                if(user.Employee_ID__c != null){
                    empCodeUserMap.put(user.Employee_ID__c,user);
                }
            }
        }
        
        public static User getRMUser(String empBrCode){
            //If EMP/BR Code starts with 00 , find User with this branch code and is a branch manager
            if(empBrCode != null && empBrCode.startsWith('00')){
                empBrCode = empBrCode.substring(2);
                if(branchCodeUserMap.containsKey(empBrCode)){
                    return branchCodeUserMap.get(empBrCode);
                }
            //else find a User with EMP/BR = Employee_Id   
            }else{
                if(empCodeUserMap.containsKey(empBrCode)){
                    return empCodeUserMap.get(empBrCode);
                }
                
            }
            return null;
        }
            
        private static Map<Id,Account> queryAccount(Set<Id> accountIds){
            Map<Id,Account> accountMap = new Map<ID,Account>([SELECT Id,Name,First_name_PE__c ,Last_Name_Pe__c,
                                                                       TMB_Customer_ID_PE__c,RTL_RM_Name__c,Owner.Name,
                                                                       Core_Banking_Suggested_Segment__c,RTL_Privilege1__c,
                                                                       Account_Type__c,Owner.UserRole.Name,Owner.Id,Email_Address_PE__c,Mobile_Number_PE__c
                                                              FROM Account WHERE ID IN : accountIds]);
            
            return accountMap;
        }
        
        private static Map<ID,RTL_Product_Master__c> queryRetailProduct(Set<Id> productIds){
            Map<Id,RTL_Product_Master__c> productMap = new Map<ID,RTL_Product_Master__c>([SELECT Id,Name,Product_Group__c,
                                                                             Product_Sub_Group__c
                                                                             FROM RTL_Product_Master__c
                                                                             WHERE ID IN : productIds]);
            return productMap;
        }
        
        private static Map<Id,User> queryUser (Set<Id> ownerIdSet){
            Map<Id, User> userMap = new Map<Id, User>();
            for(User u: [Select Id,Name, RTL_Branch__c, RTL_Branch_Code__c, Region_Code__c, 
                             Zone_Code__c, RTL_Channel__c,Region__c,Segment__c,Zone__c,
                             Reporting_Segment__c,UserRole.Name from User where id in :ownerIdSet])
                    userMap.put(u.Id, u);
            return userMap;      
        }
        
        private static Map<Id,Group> queryQueue (Set<Id> ownerIdSet){          
            //Keep the list of the referral owner as queues
               Map<Id, Group> queueMap = new Map<Id, Group>();
            for(Group q : [Select Id, DeveloperName from Group where Type = 'Queue' and id in :ownerIdSet])
                queueMap.put(q.Id, q);
            return queueMap;
            
        }
        
        private static Map<Id,Opportunity> queryOpportunity (Set<Id> referralIdSet){          
            //Keep the list of the referral with opportunity
               Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
            for(Opportunity opp : [Select Id, Name,RTL_Referral__c from Opportunity WHERE id in :referralIdSet])
                opportunityMap.put(opp.RTL_Referral__c, opp);
            return opportunityMap;
            
        }
                   
        private static Map<Id,UserRecordAccess> queryRecordAccess(Set<Id> referralIdSet){
            Map<Id,UserRecordAccess> recordAccesssMap = new Map<Id,UserRecordAccess>();
            for(UserRecordAccess recordAccess : [SELECT RecordId,HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                                     FROM UserRecordAccess
                                                     WHERE UserId =: System.UserInfo.getUserId()
                                                     AND RecordId IN:referralIdSet])
                recordAccesssMap.put(recordAccess.recordId, recordAccess);
            
            return recordAccesssMap;
                
    
        }
        
        @TestVisible
        private static String getSalesAmountPerYear(String segment){
            if(segment == null){
                return null;
            }
            if(segment == 'SE'){
                return 'SE : <100 MB';
            }
            if(segment == 'BB'){
                return 'BB : 100-1,000 MB';
            }
            if(segment == 'CB'){
                return 'CB : 1,001-5,000 MB';
            }
            if(segment == 'MB'){
                return 'MB : >5,000 MB';
            }
            if(segment == 'SBO'){
                return 'SBO';
            }
            return null;
    
        }
    
        @TestVisible
        private static void updateCustomerFnaActivity (List<RTL_Referral__c> refList, Map<Id,RTL_Referral__c> oldMap){
            List<FNA_Activity__c> fnaListUpdate = new List<FNA_Activity__c>();
            SET<String> oldAccountSet = new SET<String>();
            Map<String, String> mapNewCustomer = new Map<String, String>();
            for(RTL_Referral__c rtl : refList){
                FNA_Activity__c fna = new FNA_Activity__c();
                fna.id = rtl.FNA_Activity__c;
                fna.Customer__c = rtl.RTL_Account_Name__c;
                fnaListUpdate.add(fna);
    
                if(oldMap.get(rtl.id).RTL_Account_Name__c != null){
                    oldAccountSet.add(oldMap.get(rtl.id).RTL_Account_Name__c);
                }
                
                if(rtl.RTL_Account_Name__c != null){
                    mapNewCustomer.put(rtl.FNA_Activity__c, rtl.RTL_Account_Name__c);
                }
                
            }
    
            if(fnaListUpdate.size() > 0){
                update fnaListUpdate;
            }
            
            if(mapNewCustomer.size() > 0){
                List<FNA_Activity__c> fnaList = [SELECT id, Customer__c, Customer__r.Fna_Create_Date__c, Avatar_Name__c, Avatar_Url__c, CreatedDate, Have_Referral__c, 
                                                        Product_Holding__c, Product_Interested__c
                                                        FROM FNA_Activity__c 
                                                        WHERE id IN :mapNewCustomer.keySet() ORDER BY CreatedDate DESC];
                List<Account> newAccountList = new List<Account>();
                for(FNA_Activity__c fna : fnaList){
                    if(fna.CreatedDate > fna.Customer__r.Fna_Create_Date__c){
                        Account newAccount = new Account();
                        newAccount.Id = fna.Customer__c;
                        newAccount.Fna_Avatar_Name__c = fna.Avatar_Name__c;
                        newAccount.Fna_Avatar_Url__c = fna.Avatar_Url__c;
                        newAccount.Fna_Create_Date__c = fna.CreatedDate;
                        newAccount.Fna_Have_Referral__c = fna.Have_Referral__c;
                        newAccount.Fna_Product_Interested__c = fna.Product_Interested__c;
                        newAccount.Fna_Product_Holding__c = fna.Product_Holding__c;
                        
                        newAccountList.add(newAccount);
                    }
                }
    
                if(newAccountList.size() > 0){
                    update newAccountList;
                }
    
            }
    
    
    
            // Update FNA info of old Customer 
            if(oldAccountSet.size() > 0){
                List<FNA_Activity__c> fnaList = [SELECT id, Customer__c, Avatar_Name__c, Avatar_Url__c, CreatedDate, Have_Referral__c, 
                                                        Product_Holding__c, Product_Interested__c FROM FNA_Activity__c 
                                                        WHERE Customer__c IN :oldAccountSet ORDER BY CreatedDate DESC];
                SET<String> accIdSet = new SET<String>();
    
                List<Account> oldAccountList = new List<Account>();
                for(FNA_Activity__c fna : fnaList){
                    if(!accIdSet.contains(fna.Customer__c)){
                        Account oldAccount = new Account();
                        oldAccount.Id = fna.Customer__c;
                        oldAccount.Fna_Avatar_Name__c = fna.Avatar_Name__c;
                        oldAccount.Fna_Avatar_Url__c = fna.Avatar_Url__c;
                        oldAccount.Fna_Create_Date__c = fna.CreatedDate;
                        oldAccount.Fna_Have_Referral__c = fna.Have_Referral__c;
                        oldAccount.Fna_Product_Holding__c = fna.Product_Holding__c;
                        oldAccount.Fna_Product_Interested__c = fna.Product_Interested__c;
                        oldAccountList.add(oldAccount);
                        accIdSet.add(fna.Customer__c);
                        oldAccountSet.remove(fna.Customer__c);
                    }
                }
    
                
                for(String oldAccId : oldAccountSet){
                    Account oldAccount = new Account();
                    oldAccount.Id = oldAccId;
                    oldAccount.Fna_Avatar_Name__c = '';
                    oldAccount.Fna_Avatar_Url__c = '';
                    oldAccount.Fna_Create_Date__c = null;
                    oldAccount.Fna_Have_Referral__c = false;
                    oldAccount.Fna_Product_Holding__c = '';
                    oldAccount.Fna_Product_Interested__c = '';
                    oldAccountList.add(oldAccount);                
                }
    
    
                if(oldAccountList.size() > 0){
                    update oldAccountList;
                }
            }
    
        }
    
        @TestVisible
        private static void updateOwnerLead(List<RTL_Referral__c> refList){
    
            Map<Id, RTL_Referral__c> referralMap = new Map<Id, RTL_Referral__c>();
            for(RTL_Referral__c ref : refList){
                referralMap.put(ref.id, ref);
            }
        
            List<Lead> leadUpdateList = [SELECT id, name, RTL_Referral__c, OwnerId, RTL_isAllowedToUpdate__c FROM Lead WHERE RTL_Referral__c IN :refList];
            for(Lead leadObj : leadUpdateList){
                leadObj.OwnerId = referralMap.get(leadObj.RTL_Referral__c).OwnerId;
                leadObj.RTL_isAllowedToUpdate__c = true;
            }
    
            update leadUpdateList;
    
            /*List<Lead> leadUpdateList = new List<Lead>();
            Map<Id, RTL_Referral__c> referralMap = new Map<Id, RTL_Referral__c>();
            for(RTL_Referral__c ref : refList){
                referralMap.put(ref.FNA_Activity__c, ref);
            }
            
            List<FNA_Activity__c> fnaListUpdate = [SELECT id, Lead__c FROM FNA_Activity__c WHERE id in : referralMap.keySet() AND Lead__c != null];
            for(FNA_Activity__c fna : fnaListUpdate){
                Lead leadObj = new Lead();
                leadObj.id = fna.Lead__c;
                leadObj.OwnerId = referralMap.get(fna.id).OwnerId;
                leadObj.RTL_isAllowedToUpdate__c = true;
                leadUpdateList.add(leadObj);
            }
    
            if(leadUpdateList.size() > 0){
                update leadUpdateList;
            }*/
    
        }
    
        //-- CR AL Re-org Long Term --
        public static void autoStampContactAddress(List<RTL_Referral__c> refList)
        {
            List<RTL_Contact_Address__c> contactAddr = [SELECT Id,Name,RTL_Province__c,RTL_District__c,RTL_Sub_District__c,RTL_Zipcode__c,isActive__c FROM RTL_Contact_Address__c WHERE isActive__c = true];
            Map<String,RTL_Contact_Address__c> contactAddrMap = new Map<String,RTL_Contact_Address__c>();
            for(RTL_Contact_Address__c ca : contactAddr)
            {
                contactAddrMap.put(ca.Id,ca);
            }
            for(RTL_Referral__c ref : refList)
            {
                if(ref.RTL_Contact_Address__c != null)
                {
                    ref.RTL_AL_ContactProvince__c = contactAddrMap.containsKey(ref.RTL_Contact_Address__c) ? contactAddrMap.get(ref.RTL_Contact_Address__c).RTL_Province__c : null;
                    ref.RTL_AL_ContactDistrict__c = contactAddrMap.containsKey(ref.RTL_Contact_Address__c) ? contactAddrMap.get(ref.RTL_Contact_Address__c).RTL_District__c : null;
                    ref.RTL_AL_ContactSubDistrict__c = contactAddrMap.containsKey(ref.RTL_Contact_Address__c) ? contactAddrMap.get(ref.RTL_Contact_Address__c).RTL_Sub_District__c : null;
                    ref.RTL_AL_ContactZipcode__c = contactAddrMap.containsKey(ref.RTL_Contact_Address__c) ? contactAddrMap.get(ref.RTL_Contact_Address__c).RTL_Zipcode__c : null;
                }
            }
        }
        private static void updateCMLeadScore(List<RTL_Referral__c> refList){
    
            Map<Id, RTL_Referral__c> referralMap = new Map<Id, RTL_Referral__c>();
            Map<Id, RTL_Referral__c> campaignMemberMapwithRef = new Map<Id, RTL_Referral__c>();

            for(RTL_Referral__c ref : refList){
                referralMap.put(ref.id, ref);
                campaignMemberMapwithRef.put(ref.RTL_Campaign_Member__c,ref);
            }
        
            List<CampaignMember> cmlist = [SELECT Id,Lead_Score__c,Lead_Score_Level__c,LeadId FROM CampaignMember WHERE Id IN: campaignMemberMapwithRef.keySet()];
            List<Lead> Leadupdatedlist = new List<Lead>();

            for(CampaignMember cm : cmlist){
                if(campaignMemberMapwithRef.containsKey(cm.Id)){
                    RTL_Referral__c refupdate = campaignMemberMapwithRef.get(cm.Id);
                    System.debug('refupdate.Lead_Score__c ' + refupdate.Lead_Score__c);
                    cm.RTL_Lead_Score_Flag__c = true;
                    cm.Lead_Score__c = refupdate.Lead_Score__c;
                    cm.Lead_Score_Level__c = refupdate.Lead_Score_Level__c;
                    if(cm.LeadId != null){
                        Lead updateLead = new Lead();
                        updateLead.Id = cm.leadId;
                        updateLead.Lead_Score__c = refupdate.Lead_Score__c;
                        updateLead.Lead_Score_Level__c =refupdate.Lead_Score_Level__c;
                        System.debug('Update Lead : '+ updateLead);
                        Leadupdatedlist.add(updateLead);
                    }
                }
            }
            if(cmlist.size() > 0){
                try{
                    System.debug('Is Lead Updated');
                    update cmlist;
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
            if(Leadupdatedlist.size() > 0){
                try{
                    update Leadupdatedlist;
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }

        }
        
        public static void updateOverSLA(RTL_Referral__c ref){
            Datetime overSLA = Datetime.now(); 
            System.debug('---Current Time ' + overSLA);
    
            for (Integer i = 0 ; i < Integer.ValueOf(Referral_SLA) ; i++){
                overSLA = overSLA.addDays(1);
                System.debug('---Add day.' + overSLA);
                if(!BusinessHours.isWithin(serviceBusinessHours.Id, overSLA)){
                    System.debug('---'+overSLA + ' is not available date.');
                    overSLA = BusinessHours.nextStartDate(serviceBusinessHours.Id,overSLA).addHours(7);
                    System.debug('---'+overSLA + ' is available date.');                
                }
            }
            ref.Referral_Over_SLA__c = overSLA;
        } 
    
        public static void updateBeforeOverSLA(List<RTL_Referral__c> refList){
                for(RTL_Referral__c ref : refList){
                    
                    Datetime beforeOverSLA = ref.Referral_Over_SLA__c;
                    beforeOverSLA = beforeOverSLA.addDays(-1);
    
                    while(!BusinessHours.isWithin(serviceBusinessHours.Id, beforeOverSLA)){
                        beforeOverSLA = beforeOverSLA.addDays(-1);
                    }
                    ref.Before_Over_SLA__c = beforeOverSLA;
                }
            } 
    
        public static void createdReferralEmailNotification(List<RTL_Referral__c> refList){
            Set<Id> setuserID = new Set<Id>();
            List<Messaging.SingleEmailMessage> sendMailList = new List<Messaging.SingleEmailMessage>();
            Map<Id , List<RTL_Referral__c>> mapReferralLst = new Map<Id , List<RTL_Referral__c>>();
            Map<Id,String> mapUserIdwithManagerEmail = new Map<Id,String>();
            OrgWideEmailAddress orgWideEmail= [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' LIMIT 1];
            Set<Id> refIdlst = new Set<Id>();
            Integer emailSuccessful = 0;
            Integer emailFailed = 0;
            for(RTL_Referral__c r : refList){
                refIdlst.add(r.Id);
            }
            List<RTL_Referral__c> newList = [SELECT Id, OwnerId, CreatedBy.Email, Owner.Name, Owner.Email, RTL_Preferred_Staff__c, Name, RTL_Stage__c, RecordType.Name, RTL_Interested_Product__c, RTL_Account_Name__c, RTL_Account_Name__r.Name, RTL_Type__c, RTL_Product_Group__c, RTL_Product_Name__r.Name, RTL_Preferred_Staff__r.Manager_Email__c FROM RTL_Referral__c WHERE (RecordType.Name =: 'Refer to Retail' OR RecordType.Name =: 'Retail Cross Channel Referral') AND Id IN: refIdlst];
    
            for (RTL_Referral__c a : newList) {
                if(String.valueof(a.OwnerId).startsWith('005')){
                    setuserID.add(a.OwnerId);
                }
                if(mapReferralLst.containsKey(a.OwnerId)) {
                    mapReferralLst.get(a.Id).add(a);
                }
                else {
                    mapReferralLst.put(a.Id, new List<RTL_Referral__c>{ a });
                }
            }
            List<User> ownerlst = [SELECT Id,ManagerId,Manager_Email__c FROM User WHERE Id IN: setuserID];
            for(User each : ownerlst){
                System.debug('Test ' + each.Manager_Email__c);
                mapUserIdwithManagerEmail.put(each.Id,each.Manager_Email__c);
            }
            System.debug('mapUserIdwithManagerEmail Size ' + mapUserIdwithManagerEmail.size());
            for (Id Id : mapReferralLst.keySet()) {
                if(mapReferralLst.get(Id).get(0).Owner.Email != null){
                //System.debug('CNAME' + mapReferralLst.get(Id).get(0).RTL_Account_Name__c);
                //System.debug('RTL_Interested_Product__c: ' + mapReferralLst.get(Id).get(0).RTL_Interested_Product__c);
                //System.debug('RecordType.Name: ' + mapReferralLst.get(Id).get(0).RecordType.Name);
                String recordType = mapReferralLst.get(Id).get(0).RecordType.Name;
                String textHeader = mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__c != null ? 'เรียน คุณ ' : 'เรียน ';
                String textTitle = mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__c != null ? 'คุณ ' : '';
                String productName = recordType == 'Retail Cross Channel Referral' ? mapReferralLst.get(Id).get(0).RTL_Product_Name__r.Name : mapReferralLst.get(Id).get(0).RTL_Interested_Product__c;
                String productGroup = recordType == 'Retail Cross Channel Referral' ? '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;กลุ่มผลิตภัณฑ์: ' + mapReferralLst.get(Id).get(0).RTL_Product_Group__c + '<br/>': '' ;
                String customerName = mapReferralLst.get(Id).get(0).RTL_Account_Name__c == null ?  '' : mapReferralLst.get(Id).get(0).RTL_Account_Name__r.Name;
                
                List<String> ccAddress = new List<String>();
                String Creator = mapReferralLst.get(Id).get(0).CreatedBy.Email;
                ccAddress.add(Creator);
                System.debug(Id + ' | ' + mapReferralLst.get(Id).size());
                String Link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapReferralLst.get(Id).get(0).Id;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ mapReferralLst.get(Id).get(0).Owner.Email });
                //System.debug('Owner eMail: ' + mapReferralLst.get(Id).get(0).Owner.Email);
                mail.setSubject('[New] CRM Referral_[' + mapReferralLst.get(Id).get(0).Name + ']' );
                mail.setHtmlBody(
                    textHeader + mapReferralLst.get(Id).get(0).Owner.Name 
                    + '<br/><br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;ขณะนี้ได้มีงาน Refer ใหม่สร้างขึ้นในระบบ CRM ส่งมาที่ '
                    + textTitle + mapReferralLst.get(Id).get(0).Owner.Name 
                    + ' กรุณาคลิก URL Link ด้านล่างและล็อคอินเข้าระบบ CRM '
                    + 'เพื่อพิจารณารายละเอียดและดำเนินการในขั้นตอนต่อไป '
                    + '<br/><br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;Link: ' + Link
                    + '<br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;หมายเหตุ กรณีงาน Refer เข้าสาขาให้ท่านกด "รับงาน" ก่อนติดต่อลูกค้ารายนี้ '
                    + '<br/><br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;Referal Number: ' + mapReferralLst.get(Id).get(0).Name  
                    + '<br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ขั้นตอน: ' + mapReferralLst.get(Id).get(0).RTL_Stage__c 
                    + '<br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;Customer Name: ' + customerName
                    + '<br/>'
                    + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ประเภทการ Refer: ' + mapReferralLst.get(Id).get(0).RTL_Type__c 
                    + '<br/>'
                    +  productGroup
                    + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ชื่อผลิตภัณฑ์: ' + productName
                    + '<br/>' 
                );
                mail.setCharset('UTF-8');
                if(mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__c != null ){
                    String teamLeadOwner = mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__r.Manager_Email__c;
                    System.debug('Preferred Staff Owner ' + teamLeadOwner);
    
                    if(teamLeadOwner != null){
                        ccAddress.add(teamLeadOwner);
                        System.debug(teamLeadOwner);
                    }
                }else if(String.ValueOF(mapReferralLst.get(Id).get(0).OwnerId).startsWith('005')){
                    String teamLeadOwner = mapUserIdwithManagerEmail.get(mapReferralLst.get(Id).get(0).OwnerId);
                    System.debug('Mananger Email ' + teamLeadOwner);
                    if(teamLeadOwner != null){
                        ccAddress.add(teamLeadOwner);
                    }
                }
                
                mail.setCcAddresses(ccAddress);
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
                sendMailList.add(mail);
                }else{
                    system.debug('Owner Email is NULL');
                }
            }
            if(sendMailList.size() > 0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendMailList);    
                for (Messaging.SendEmailResult result : results) {
                    if(result.isSuccess()){
                        emailSuccessful++;
                    }
                    else {
                        System.debug(logginglevel.ERROR, 'There is error on overSLAReferralEmailNotificationBatch. Error Message is: ' + result.getErrors());
                        emailFailed++;
                    }
                }
            }
        }
    }