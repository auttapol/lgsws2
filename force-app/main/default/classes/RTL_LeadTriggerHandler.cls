public without sharing class RTL_LeadTriggerHandler extends TriggerHandler {//Use without sharing to allow lead conversion from non-owner
/*------------------------------------------------------------------------
Author:        Debi Prasad Baral
Company:       Salesforce
Description:   A class created to manage trigger actions from the Lead object 
               Responsible for:
               1 - Validating that the Lead Status is qualified and the at least one associated interested product is primary
               2 - Updating the opportunity created during lead conversion according to the correct record type.
History
<Date>            <Authors Name>    <Brief Description of Change> 
--------------------------------------------------------------------------*/
      
    List<Account> updateAccounts = new List<Account>(); 
    List<Opportunity> updateOpportunities = new List<Opportunity>(); 
    List<RTL_Interested_products_c__c> updateInterestedProducts = new List<RTL_Interested_products_c__c>();
    List<RTL_Referral__c> updateReferrals = new List<RTL_Referral__c>();
    List<FNA_Activity__c> updateFnaActivity = new List<FNA_Activity__c>();
    public static List<Lead> leadBranchList = new List<Lead>();
    public static List<Id> specialistAssignedIdList = new List<Id>();
    public static List<String> branchAssignIdList = new List<String>();
    public static Set<Specialist_and_Product_Group_Mapping__c> assignSpecialist = new Set<Specialist_and_Product_Group_Mapping__c>();

    public static List<CampaignMember> campaignMember = new List<CampaignMember>();

    // private static RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule;

    public class ProductGroupSpecialistWrapper{
        public Integer currentIndex{get;set;}
        public List<Specialist_and_Product_Group_Mapping__c> specialistProductList{get;set;}
    }

    public static Map<String, RTL_product_master__c> productMap {
        get{
            if(productMap == null){
                productMap = new Map<String,RTL_product_master__c>();
                for(RTL_product_master__c eachProduct : [SELECT Id, Name, Product_Group__c, Product_Sub_group__c 
                                                            FROM RTL_product_master__c WHERE Active__c = true]){
                    productMap.put(eachProduct.Name, eachProduct);
                }
            }
            return productMap;
        }
        set;
    }

    private static Map<String,Branch_and_Zone__c> branchZoneMap{
        get{
            if(branchZoneMap == null){
                branchZoneMap = new Map<String,Branch_and_Zone__c>();
                for(Branch_and_Zone__c eachBranch : [SELECT Id, Name, Branch_Name__c, Branch_Code__c, RTL_Branch_Manager_User__c,RTL_Branch_Manager_User__r.Email,RTL_Branch_Manager_User__r.Name
                                                        FROM Branch_and_Zone__c 
                                                        WHERE RTL_Branch_Manager_User__c != null]){
                    branchZoneMap.put(eachBranch.Branch_Code__c,eachBranch);                    
                }
            }
            return branchZoneMap;
        }
        set;
    }

    private static Map<Id, RTL_Lead_Assignment_Rule__c>  leadAssignmentRule {
        get{
            if(leadAssignmentRule == null){
                leadAssignmentRule = new Map<Id, RTL_Lead_Assignment_Rule__c>([SELECT Id, Name, RTL_Active_Flag__c, RTL_Priority__c, RTL_Lead_Record_Type__c, RTL_Integration_Type__c, RTL_Lead_Field_Criteria_1__c, RTL_Lead_Field_Criteria_2__c, RTL_Lead_Field_Criteria_3__c, RTL_Lead_Field_Criteria_4__c, RTL_Lead_Field_Criteria_5__c, RTL_Lead_Field_Value_1__c, RTL_Lead_Field_Value_2__c, RTL_Lead_Field_Value_3__c, RTL_Lead_Field_Value_4__c, RTL_Lead_Field_Value_5__c, RTL_Assigned_User__c, RTL_Assigned_User_field__c, RTL_Assigned_Queue_Name__c, RTL_Branch_and_Zone_Queue_User_field__c, RTL_Default_Queue_Name__c, RTL_Default_User__c, RTL_IsAssign_Campaign__c, RTL_Assigned_Apex__c, RTL_IsInsertProduct__c FROM RTL_Lead_Assignment_Rule__c WHERE RTL_Active_Flag__c = true ORDER BY RTL_Priority__c]);
            }
            return leadAssignmentRule;
        }
        set{}
    }

    private static User tmbAdmin {
        get{
            if(tmbAdmin == null){
                tmbAdmin = [SELECT Id, Name FROM User WHERE Name = 'TMB Administrator'];
            }
            return tmbAdmin;
        }
        set;
    }

    private static Map<String, RTL_Product_Outbound_Mapping__mdt> mapProductOutboundDetail {
        get{
            if(mapProductOutboundDetail == null){
                mapProductOutboundDetail = new Map<String, RTL_Product_Outbound_Mapping__mdt>();
                for(RTL_Product_Outbound_Mapping__mdt productOutbound : [SELECT RTL_Product_Name__c, RTL_Contact_Method__c, RTL_Lead_Campaign_Outbound__c, RTL_Lead_Channel_Outbound__c FROM RTL_Product_Outbound_Mapping__mdt] ){
                    mapProductOutboundDetail.put(productOutbound.RTL_Product_Name__c + productOutbound.RTL_Contact_Method__c, productOutbound);
                }
            }
            return mapProductOutboundDetail;
        }
        set;
    }

    private static List<String> profileAssignList {
        get{
            if(profileAssignList == null){
                profileAssignList = new List<String>();
                for(Campaign_Member_Profile_Assignment__mdt eachCampaign : [SELECT Id,MasterLabel,DeveloperName,Profile_Name__c FROM Campaign_Member_Profile_Assignment__mdt]){
                    profileAssignList.add(eachCampaign.Profile_Name__c);
                }
            }
            return profileAssignList;
        }
        set;
    }
    
    public RTL_LeadTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
     
        System.Debug( 'TMB: -> LeadTriggerHandler Invoked' );
    }
            
    //take the first and last 3 characters of ID number as NID of customer
    public String getNID (String idNumber) {
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }
    
    protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
        System.Debug('TMB: -> LeadTriggerHandler start of beforeUpdate');      

        //----------  CR Referral  Validate referral before Update lead -----------------
        validateReferral(newMap.values());

        //------------ CR R4.1 Simplified Lead -------------//
        transformReasons(oldMap,newMap);

        User user = null;
        Group queue = null;
        Branch_and_Zone__c branch = null;
        //Map<String, Branch_and_Zone__c> branchNameMap = new Map<String, Branch_and_Zone__c>();
        Map<String, Branch_and_Zone__c> branchCodeMap = new Map<String, Branch_and_Zone__c>();
        for(Branch_and_Zone__c branchzone : [Select Name, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c]) {
            //branchNameMap.put(branchzone.Name, branchzone);
            branchCodeMap.put(branchzone.Branch_Code__c, branchzone);
        }   
        
        //Store lead owners to map to user object
        Set<Id> leadOwnerIds = new Set<Id>();
        //Store the last 3 characters of the lead ID number as NID number to compare against account object
        Set<String> leadNIDNumbers = new Set<String>();
        String leadIDNumber = null;
         // Add filter status check for lead conversion
        String qStatus = 'Qualified';
        String cStatus = 'Closed Converted';
        for (Id lId:newMap.keySet()){
            leadOwnerIds.add(((lead)newMap.get(lId)).OwnerId);
            leadIDNumber = ((lead)newMap.get(lId)).RTL_Citizen_Id__c;
            boolean currentStatus = (((lead)oldMap.get(lId)).Status == qStatus);
            boolean targetStatus = (((lead)newMap.get(lId)).Status == cStatus);
            if (leadIdNumber != null && currentStatus && targetStatus)  
                leadNIDNumbers.add(getNID(leadIDNumber));
        }
        //Keep the list of the lead owner as users
        Map<Id, User> userMap = new Map<Id, User>();
        for(User u: [Select Id, RTL_Branch__c, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c from User where id in :leadOwnerIds])
            userMap.put(u.Id, u);
        //Keep the list of the lead owner as queues
        Map<Id, Group> queueMap = new Map<Id, Group>();
        for(Group q : [Select Id,Name ,DeveloperName from Group where Type = 'Queue' and id in :leadOwnerIds])
            queueMap.put(q.Id, q);
           
        //Store account ID type + ID number combination as set for dudup check of customer before lead conversion validation
        Set<String> accountSet = new Set<String>();
        for(Account acct : [Select ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c from Account where RTL_NID__c in :leadNIDNumbers])
            accountSet.add(acct.ID_Type_PE__c+acct.ID_Number_PE__c);
        
        String branchCode = null;
        for (Id lId:newMap.keySet()){
            Lead leadObj = (lead)newMap.get(lId);
            Lead oldLeadObj = (lead)oldMap.get(lId);
            
            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                //lead conversion validation
                if(leadObj.IsConverted){
                    //FR-008: make sure the lead status is Qualified with only 1 primary product before lead conversion
                    validateLead(leadObj, oldLeadObj, accountSet);
                }
                //update branch name after lead owner is changed
                if(leadObj.OwnerId != oldLeadObj.OwnerId) {
                    //the lead owner chould be either a user or a queue
                    user = userMap.get(leadObj.OwnerId);
                    if (user != null) {
                        if (user.RTL_Branch_Code__c != null && branchCodeMap.get(user.RTL_Branch_Code__c) != null) {
                            leadObj.RTL_Branch_and_Zone__c = branchCodeMap.get(user.RTL_Branch_Code__c).Id;
                        } else {
                            leadObj.RTL_Branch_and_Zone__c = null;
                        }
                        leadObj.RTL_Branch_Team_Name_Code_Rpt__c = user.RTL_Branch__c;
                        leadObj.RTL_Branch_Code_Rpt__c = user.RTL_Branch_Code__c;
                        leadObj.RTL_Region_Code_Rpt__c = user.Region_Code__c;
                        leadObj.RTL_Zone_Code_Rpt__c = user.Zone_Code__c;
                        leadObj.RTL_Lead_Channel__c = user.RTL_Channel__c;
                    } else {
                        //the lead owner could be a branch queue or outbound queue
                        queue = queueMap.get(leadObj.OwnerId);
                        branchCode = queue.DeveloperName;
                        if (branchCode.indexOf('_') != -1) {
                            branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                        }
                        branch = branchCodeMap.get(branchCode);
                        if (branch != null) {//branch queue
                            leadObj.RTL_Branch_and_Zone__c = branch.Id;      
                            leadObj.RTL_Branch_Team_Name_Code_Rpt__c = branch.Name;                     
                            leadObj.RTL_Branch_Code_Rpt__c = branch.Branch_Code__c;
                            leadObj.RTL_Region_Code_Rpt__c = branch.RTL_Region_Code__c;
                            leadObj.RTL_Zone_Code_Rpt__c = branch.RTL_Zone_Code__c;
                            leadObj.RTL_Lead_Channel__c = null;                         
                        } else {//outbound queue
                            leadObj.RTL_Branch_and_Zone__c = null;
                            leadObj.RTL_Branch_Team_Name_Code_Rpt__c = null;
                            leadObj.RTL_Branch_Code_Rpt__c = null;
                            leadObj.RTL_Region_Code_Rpt__c = null;
                            leadObj.RTL_Zone_Code_Rpt__c = null; 
                            leadObj.RTL_Lead_Channel__c = null;                                   
                        }
                    }
               }
            }          
        }
        System.Debug('TMB: -> LeadTriggerHandler end of beforeUpdate');  
    }
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> LeadTriggerHandler start of afterUpdate');  
        //FR-001: Add lead Primary Interested Product
        addInterestedProductFromLead(oldMap, newMap);

        //CR Referral Enhancement RQ-004 sync lead status and referral stage
        RTL_ReferralLeadService.updateReferralInfo(oldMap,newMap);
        
        Map<ID,ID> convertedLeadsAccountIDMap = new Map<ID,ID>();
        List<Lead> leadSendToOutboundCisco = new List<Lead>();
        // List<Lead> leadSendToOutboundAvaya = new List<Lead>();
        /*
         * Loop through the leads submitted through this
         * trigger.  Populate the appropriate sets of Ids
         * for each lead with populated values.
         */
        for (Id lId:newMap.keySet()){
            Lead leadObj = (lead)newMap.get(lId);
            Lead oldLeadObj = (lead)oldMap.get(lId);

            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type            
                //post processing of lead conversion
                if(leadObj.IsConverted){ 
                    if (leadObj.convertedAccountId != null) {
                        //Call method to create a list of account to be updated
                        createAccountToUpdate(leadObj);
                        //Call method to create a list of opportunities to be updated 
                        createOpportunitiesToUpdate(leadObj);
                        //Call Method to Update Interested Product Reference if Account was generated from Lead        
                        insertInterestedProductsForConvertedAccounts(leadObj);
                        //Call Method to Update Referral Reference if Account was generated from Lead 
                        createReferralsToUpdate(leadObj);
                        //Call Method to Update FNA Activity
                        createFnaActivityToUpdate(leadObj);
                        // Add lead and Account for update campaign member
                        convertedLeadsAccountIDMap.put(leadObj.id,leadObj.ConvertedAccountId);
                    }
                }

                if(leadObj.RTL_Call_Me_Now_Retry_Count__c != oldLeadObj.RTL_Call_Me_Now_Retry_Count__c && leadObj.RTL_Call_Me_Now_Retry_Count__c < 3){
                    RTL_Lead_Assignment_Rule__c rule = leadAssignmentRule.get(leadObj.RTL_Lead_Assigned_By_Rule__c);
                    if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c == 'Cisco') leadSendToOutboundCisco.add(leadObj);
                    // if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c == 'Avaya') leadSendToOutboundAvaya.add(leadObj);
                }
            }    
        }
      
        //Update the records for any update list populated with records.
        if(updateAccounts.size() > 0){
            // Update the converted account records
            Database.SaveResult[] lsr = Database.update(updateAccounts, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead converted account.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating lead converted account. Error Message is: ' + err.getMessage());
                    }
                }
            }            
        }
        
        if(updateReferrals.size() > 0){
            // Update the account interested product
            Database.SaveResult[] lsr = Database.update(updateReferrals, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead converted referral.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating lead converted referrals. Error Message is: ' + err.getMessage());

                    }
                }
            }           
        }

        if(updateFnaActivity.size() > 0){
            Database.SaveResult[] lsr = Database.update(updateFnaActivity, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead converted FNAactivity.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating lead converted FNAactivity. Error Message is: ' + err.getMessage());
                    }
                }
            }    
        }
        
        if(updateOpportunities.size() > 0){
            // Update the converted opportunities records
            Database.SaveResult[] lsr = Database.update(updateOpportunities, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead converted opportunity.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating lead converted opportunity. Error Message is: ' + err.getMessage());
                    }
                }
            }             
        }

                
        if(updateInterestedProducts.size() > 0){
            // Update the account interested product
            Database.SaveResult[] lsr = Database.update(updateInterestedProducts, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead converted interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating lead converted interested product. Error Message is: ' + err.getMessage());
                    }
                }
            }           
        }     

        // To Update Campaign Member which customer__c is blank
        
        if( convertedLeadsAccountIDMap.size() > 0 )
        {
            Set<ID> leadIds = convertedLeadsAccountIDMap.keySet();
            List<CampaignMember> camMems = [SELECT Id,LeadId,Customer__c FROM CampaignMember WHERE LeadId in:leadIds ];
            for( CampaignMember cm:camMems )
            {
                // Use value from lead(Maybe can user value from Campaign )
                if( cm.Customer__c == null  )
                {
                    cm.Customer__c = convertedLeadsAccountIDMap.get(cm.LeadId);
                }
            }

            Database.SaveResult[] lsr = Database.update(camMems, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated campaign Member customer__c when lead converted.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating campaign Member customer__c when lead converted .. Error Message is: ' + err.getMessage());
                    }
                }
            }    
        }

        if(leadSendToOutboundCisco.size() > 0){
            sendToCallMeNowServiceCisco(leadSendToOutboundCisco);
        }

        // if(leadSendToOutboundAvaya.size() > 0){
        //     sendToCallMeNowServiceAvaya(leadSendToOutboundAvaya);
        // }
    }
    
    protected override void beforeInsert(List<SObject> leads) {        
        System.Debug('TMB: -> RTL_LeadTriggerHandler start of beforeInsert');
        //----------  CR Referral  Validate referral before create lead -----------------
        validateReferral(leads);
        //FR-011: Only auto assign the web-to-lead to different lead queue based on Assignment Criteria
        //A Lead Assignment Rule named "WebToLeadNoOwner" is created with "Do Not Reassign Owner" for web-to-lead 
        //this is to make sure the default lead owner (set in lead settings) won't overwrite the value set in beforeInsert trigger
        // LeadAssignmentUtil.assignLeadOwnerByLeadAssignmentrule(leads);
        prepareLeadInfo(leads);

        //// Prepare Lead data(FNA)
        RTL_ReferralLeadService.prepareLeadInfo(leads);

    }
    
    protected override void afterInsert(map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_LeadTriggerHandler start of afterInsert');
        
        //FR-001: Add lead Primary Interested Product
        addInterestedProductFromLead(null, newMap);

        //FR-003: Add lead interested product from web-to-lead
        addInterestedProducts(newMap);
        addInterestedProductFromReferral(newMap);

        //CR Referral Enhancement RQ-004 sync lead status and referral stage
        RTL_ReferralLeadService.updateReferralStageContacted(newMap.values());
        //CR Lead to MDM assign WebDropLead to Campaign
        List<Lead> leadAssignCampaign = new List<Lead>();
        List<Lead> leadSendToOutboundCisco = new List<Lead>();
        // List<Lead> leadSendToOutboundAvaya = new List<Lead>();
        List<Lead> leadSendALSales = new List<Lead>();
        Map<Id,String> mapLeadwithIntegrationtype = new Map<Id,String>();
        for (Id lId : newMap.keySet()){
            Lead leadObj = (lead)newMap.get(lId);
            // System.debug('Debug11 leadObj.RTL_Lead_Assigned_By_Rule__c:'+leadObj.RTL_Lead_Assigned_By_Rule__c);
            RTL_Lead_Assignment_Rule__c rule = leadAssignmentRule.containsKey(leadObj.RTL_Lead_Assigned_By_Rule__c) ? leadAssignmentRule.get(leadObj.RTL_Lead_Assigned_By_Rule__c) : null;            
            if(rule != null && rule.RTL_IsAssign_Campaign__c) leadAssignCampaign.add(leadObj);
            
            if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c == 'Cisco') leadSendToOutboundCisco.add(leadObj);
            // if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c == 'Avaya' && LeadAssignmentUtil.mapIdQueue.containsKey(leadObj.OwnerId) && LeadAssignmentUtil.mapIdQueue.get(leadObj.OwnerId).DeveloperName == 'RTLQ_Outbound') leadSendToOutboundAvaya.add(leadObj);
            if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c != 'Cisco') {
                leadSendALSales.add(leadObj);
                mapLeadwithIntegrationtype.put(leadObj.Id, rule.RTL_Integration_Type__c);
            }
            //If it is lead from Web and a Retail Lead
            // if(leadObj.RTL_TMB_Campaign_Source__c != null && (leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Web') || leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Call Me Now')) && RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)){
            //     webLeadList.add(leadObj);
            // }
            
        }
        System.debug('Debug11 leadAssignCampaign:'+leadAssignCampaign);
        if(leadAssignCampaign.size() > 0){
            System.debug('Start attachToCampaign after insert');
            attachToCampaign(leadAssignCampaign);
            System.debug('leadSendALSales size ' + leadSendALSales.size());
            if(leadSendALSales.size() > 0){
                RTL_LeadDistribution.mappingleadDistribution(campaignMember,mapLeadwithIntegrationtype);
            }
        }
        
        if(leadSendToOutboundCisco.size() > 0){
            sendToCallMeNowServiceCisco(leadSendToOutboundCisco);
        }

        // if(leadSendToOutboundAvaya.size() > 0){
        //     sendToCallMeNowServiceAvaya(leadSendToOutboundAvaya);
        // }

        if(leadBranchList.size() > 0){
            sendEmailToProductSpecialist();
        }
    }   
    
    private void sendEmailToProductSpecialist(){
        List<Id> leadBranchIdList = new List<Id>();
        EmailTemplate emailTemplate =[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Drop_Lead_Notify_Lead_Owner' LIMIT 1];
        Map<Id, User> specialistLeadOwnerMap = new Map<ID, User>([SELECT Id, Name,Email,Profile.Name FROM User WHERE Id IN: specialistAssignedIdList]);
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];

        for(Lead eachLead : leadBranchList){
            leadBranchIdList.add(eachLead.Id);
        }

        AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
        String sfdcBaseLightningURL = lightCF == null ? 'https://tmbbank--rq006.sandbox.lightning.force.com' : lightCF.Value__c;

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(CampaignMember eachCampaign : [SELECT Id, LeadId,Lead.Name,Lead.OwnerId,Lead.Owner.Name, Name,Lead.Owner.Profile.Name FROM CampaignMember WHERE LeadId IN: leadBranchIdList]){

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setOrgWideEmailAddressId(owea.id);
            message.setSubject(emailTemplate.Subject);
            String emailBody = emailTemplate.Body;
            String ownerName = '';
            Blob cmUrl = Blob.valueOf('{"componentDef":"c:CampaignMember_Main","attributes":{"recordId":"' + eachCampaign.Id + '","mode":"Edit"},"state":{}}');
            String encUrl = EncodingUtil.base64Encode(cmUrl);
            String leadOwnerProfile = eachCampaign.Lead.Owner.Profile.Name;

            if(specialistLeadOwnerMap.containsKey(eachCampaign.Lead.OwnerId)){
                if(eachCampaign.Lead.Owner.Name != null){
                    ownerName = eachCampaign.Lead.Owner.Name;
                }
                emailBody = emailBody.replace('{!Lead.Owner}', ownerName);
                message.toAddresses = new String[] {specialistLeadOwnerMap.get(eachCampaign.Lead.OwnerId).Email};
                messages.add(message);
            }else  if(LeadAssignmentUtil.mapIdQueue.containsKey(eachCampaign.Lead.OwnerId)){
                
                String branchCode = LeadAssignmentUtil.mapIdQueue.get(eachCampaign.Lead.OwnerId).DeveloperName;
                if(branchCode.indexOf('_') != -1) {
                    branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                }
                if (branchZoneMap.containsKey(branchCode)) {
                    emailBody = emailBody.replace('{!Lead.Owner}',branchZoneMap.get(branchCode).RTL_Branch_Manager_User__r.Name);
                    message.toAddresses = new String[] {branchZoneMap.get(branchCode).RTL_Branch_Manager_User__r.Email};
                    messages.add(message);
                }
            }
            if(profileAssignList.contains(leadOwnerProfile)){
                emailBody = emailBody.replace('{!Lead.Call_Me_Now_URL__c}', sfdcBaseLightningURL + '/one/one.app#' + encUrl);
            }else{
                emailBody = emailBody.replace('{!Lead.Call_Me_Now_URL__c}', sfdcBaseLightningURL + '/lightning/r/CampaignMember/' + eachCampaign.Id + '/view');
            }
            emailBody = '<html><body>'+emailBody+'</body> </html>';
            message.setHtmlBody(emailBody);
        }

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
    }

    private void createFnaActivityToUpdate(Lead leadObj){
        if(leadObj.FNA_Activity__c != null){
            FNA_Activity__c fna = new FNA_Activity__c();
            fna.id = leadObj.FNA_Activity__c;
            fna.Customer__c = leadObj.convertedAccountId;
            updateFnaActivity.add(fna);
        }
    } 

    /*end trigger handler overrides*/
    //====================================================================
    
    /* private methods */
    //====================================================================
    /**
     * @desc This method would validate rules before the lead is converted: 
     * Lead is qualified and it has only one primary product
     * @param [Lead leadObj Lead oldLeadObj Set accountSet]
     */
    private void validateLead(Lead leadObj, Lead oldLeadObj, Set<String> accountSet){ 
        System.debug('AccountSet :: '+accountSet);
        if (oldLeadObj.Status != 'Qualified'){//check if the lead status was Qualified
            leadObj.addError(System.Label.LeadError_QualifiedBeforeConversion);
        }else if (accountSet.contains(leadObj.RTL_ID_Type__c + leadObj.RTL_Citizen_Id__c) && !leadObj.RTL_Allow_Convert_Lead__c ) {//check if customer is duplicated with combination of ID type and ID number
            leadObj.addError(System.Label.LeadError_DupCustomerBeforeConversion);
        } else {
            //Get the count of primary product of lead interested products
            Integer primaryProductCount = [SELECT Count() FROM RTL_Interested_products_c__c 
                          WHERE Lead__c = :leadObj.Id AND Is_Primary__c = true];          
            if(primaryProductCount != 1){
                leadObj.addError(System.Label.LeadError_OnePrimaryProductBeforeConversion);
            }
        }
    }
    /* private methods */
    //====================================================================
    /**
     * @desc This method would create a list of account records which were associated with lead being converted
     * and will be updated
     * @param [Lead leadObj]
     */
    private void createAccountToUpdate(Lead leadObj){
        Account account = [SELECT Id, RecordTypeId, Account_Type__c, 
                            ID_Number_PE__c,First_name_PE__c,Last_name_PE__c,
                            RTL_Income__c,RTL_Occupation__c,RTL_Customer_Title__c,
                            Mobile_Number_PE__c,C_Home_phone_PE__c,RTL_Office_Phone_Number__c,
                            Email_Address_PE__c,RTL_NID__c,Primary_Address_Line_1_PE__c,
                            Primary_Address_Line_3_PE__c,Province_Primary_PE__c,Primary_Address_Line_2_PE__c,
                            Country_Primary_PE__c,Zip_Code_Primary_PE__c,
                            Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c,
                            Fna_Product_Holding__c, Fna_Product_Interested__c,
                            (SELECT ID,Name FROM Contacts) FROM Account WHERE Id =:leadObj.convertedAccountId];
         System.Debug('account afterUpdate' + account ); 
        // Make appropriate updates here.
        if(account.Contacts.size() < 2){
          account.RecordTypeId = [Select Id from RecordType 
                                        where Name = :'Retail Prospect' and SobjectType = 'Account' 
                                        and IsActive = true limit 1].Id;
          account.Account_Type__c = 'Retail Prospect';

            if(account.First_name_PE__c == null || account.First_name_PE__c == ''){
                account.First_name_PE__c  = leadObj.FirstName;
            }

            if(account.Last_name_PE__c == null || account.Last_name_PE__c ==''){
                account.Last_name_PE__c  = leadObj.LastName;
            }
            
            if(account.RTL_Income__c == null || account.RTL_Income__c == 0){
                account.RTL_Income__c =leadObj.RTL_Income__c;
            }

            if(account.RTL_Occupation__c == null || account.RTL_Occupation__c == ''){
                account.RTL_Occupation__c = leadObj.RTL_Occupation__c;
            }

            if(account.RTL_Customer_Title__c == null || account.RTL_Customer_Title__c == ''){
             account.RTL_Customer_Title__c = leadObj.Salutation; //Customer Title Name (TH)
            }

          //account.Mobile_Number_PE__c = leadObj.MobilePhone; //Mobile Phone Number
          //account.C_Home_phone_PE__c = leadObj.Phone; //Home Phone Number
          //account.Phone = leadObj.RTL_Office_Number__c; //Office Phone Number  

            if(account.Mobile_Number_PE__c == null || account.Mobile_Number_PE__c == ''){
                account.Mobile_Number_PE__c = leadObj.RTL_Mobile_Number__c; //Mobile Phone Number
            }

            if(account.C_Home_phone_PE__c == null || account.C_Home_phone_PE__c == ''){
                account.C_Home_phone_PE__c = leadObj.RTL_Phone_Number__c; //Home Phone Number
            }

            if(account.RTL_Office_Phone_Number__c == null || account.RTL_Office_Phone_Number__c == ''){
                account.RTL_Office_Phone_Number__c = leadObj.RTL_Office_Number__c; //Office Phone Number
            }

            if(account.Email_Address_PE__c == null || account.Email_Address_PE__c == ''){
               account.Email_Address_PE__c = leadObj.RTL_Email_Address__c; //Email 1
            }

            if(account.RTL_NID__c == null || account.RTL_NID__c == ''){
               account.RTL_NID__c = getNID(account.ID_Number_PE__c);
            }

            if(account.Primary_Address_Line_1_PE__c == null || account.Primary_Address_Line_1_PE__c == ''){
               if(leadObj.RTL_Address_Line1__c != null){
                    account.Primary_Address_Line_1_PE__c = leadObj.RTL_Address_Line1__c; //Primary Address No./Moo/Soi/Street
                }
            }

            if(account.Primary_Address_Line_3_PE__c == null || account.Primary_Address_Line_3_PE__c == ''){
               if(leadObj.RTL_Address_Line2__c != null){
                    account.Primary_Address_Line_3_PE__c = leadObj.RTL_Address_Line2__c; //Primary District
                }  
            }

            if(account.Primary_Address_Line_2_PE__c == null || account.Primary_Address_Line_2_PE__c == ''){
               if(leadObj.RTL_Address_Line3__c != null){
                    account.Primary_Address_Line_2_PE__c = leadObj.RTL_Address_Line3__c; //Primary Sub District
                }  
            }

            if(account.Province_Primary_PE__c == null || account.Province_Primary_PE__c == ''){
               if(leadObj.RTL_Address_Line4__c != null){
                    account.Province_Primary_PE__c = leadObj.RTL_Address_Line4__c; //Primary Province
                } 
            }

            if(account.Zip_Code_Primary_PE__c == null || account.Zip_Code_Primary_PE__c == ''){
               if(leadObj.RTL_Address_Line5__c != null){
                    account.Zip_Code_Primary_PE__c = leadObj.RTL_Address_Line5__c; //Primary Zip code
                }
            }

            if(account.Country_Primary_PE__c == null || account.Country_Primary_PE__c == ''){
               if(leadObj.Country != null){
                    account.Country_Primary_PE__c = leadObj.Country; //Primary Country
                }
            }

            /* START FIELD of FIN AVATAR */
            System.Debug('FNA_Activity__c afterUpdate' + leadObj.FNA_Activity__c ); 
            if(leadObj.FNA_Activity__c != null){
                System.Debug('Fna_Avatar_Name__c afterUpdate' + leadObj.Fna_Avatar_Name__c ); 
                System.Debug('Fna_Avatar_Url__c afterUpdate' + leadObj.Fna_Avatar_Url__c ); 
                System.Debug('Fna_Create_Date__c afterUpdate' + leadObj.Fna_Create_Date__c ); 
                System.Debug('Fna_Have_Referral__c afterUpdate' + leadObj.Fna_Have_Referral__c ); 
                System.Debug('Fna_Product_Holding__c afterUpdate' + leadObj.Fna_Product_Holding__c ); 
                System.Debug('Fna_Product_Interested__c afterUpdate' + leadObj.Fna_Product_Interested__c ); 
                if(account.Fna_Avatar_Name__c == null || account.Fna_Avatar_Name__c == ''){
                    if(leadObj.Fna_Avatar_Name__c != null){
                        account.Fna_Avatar_Name__c = leadObj.Fna_Avatar_Name__c; //Avatar Name
                    }
                }

                if(account.Fna_Avatar_Url__c == null || account.Fna_Avatar_Url__c == ''){
                    if(leadObj.Fna_Avatar_Url__c != null){
                        account.Fna_Avatar_Url__c = leadObj.Fna_Avatar_Url__c; //URL Avatar Image
                    }
                }

                if(account.Fna_Create_Date__c == null ){
                    if(leadObj.Fna_Create_Date__c != null){
                        account.Fna_Create_Date__c = leadObj.Fna_Create_Date__c; //FNA Create date
                    }
                }

                account.Fna_Have_Referral__c = leadObj.Fna_Have_Referral__c; //Primary Country

                if(account.Fna_Product_Holding__c == null || account.Fna_Product_Holding__c == ''){
                    if(leadObj.Fna_Product_Holding__c != null){
                        account.Fna_Product_Holding__c = leadObj.Fna_Product_Holding__c; //Primary Country
                    }
                }
                if(account.Fna_Product_Interested__c == null || account.Fna_Product_Interested__c == ''){
                    if(leadObj.Fna_Product_Interested__c != null){
                        account.Fna_Product_Interested__c = leadObj.Fna_Product_Interested__c; //Primary Country
                    }
                }
            }
            /* END FIELD of FIN AVATAR */
          
        }else{
            leadObj.addError(System.Label.LeadError_CannotConvertToExistingCustomer );
        } 
                
        updateAccounts.add(account);
    }
    
    /**
     * @desc This method would create a list of opportunity records which were associated with lead being converted
     * and will be updated
     * @param [Lead leadObj]
     */
    private void createOpportunitiesToUpdate(Lead leadObj){
        if (leadObj.convertedOpportunityId != null) {
            //opportunity will only be created during lead conversion
            //1. if "Do not create a new opportunity upon conversion" is not checked and opportunity detail is provided in browser
            //2. opportunity detail is provided in SF1 UI
            Opportunity opportunity = [SELECT Id, Name, RTL_Product_Name__c FROM Opportunity WHERE Id =: leadObj.convertedOpportunityId];
            //get interested product fields to pass on to oppertunity
            RTL_Interested_products_c__c intProduct = new RTL_Interested_products_c__c();
            
            intProduct = [Select Id, Product_Name__c, product_group__c, Product_Sub_Group__c, 
                                      Income_SL__c, Income_SE__c, Debt__c, Collateral_Type__c, Loan_Amount__c,
                                      Co_borrower_1__c, Co_borrower_2__c from RTL_Interested_products_c__c 
                                                       where Is_Primary__c = : true and Lead__c = : leadObj.Id limit 1];
            
           
            //get the custom settings values 
            List<Opportunity_Recordtype_Mapping__c> stageMappingCodes = Opportunity_Recordtype_Mapping__c.getAll().values(); 
            
            for (Opportunity_Recordtype_Mapping__c stagemappingCode : stageMappingCodes){
                if (intProduct.product_group__c == stagemappingCode.Product_Group__c){
                    opportunity.RecordTypeId = [Select Id from RecordType 
                                            where Name = : stagemappingCode.Record_Type__c and SobjectType = 'Opportunity' 
                                            and IsActive = true limit 1].Id;
                    opportunity.StageName = stagemappingCode.Stage__c;         
                }
            }
                       
            //make appropriate updates here.
           
            opportunity.RTL_Product_Group__c = intProduct.product_group__c;
            opportunity.RTL_Product_Name__c = intProduct.Product_Name__c; //Product Name
            opportunity.RTL_Prod_SubGrp__c = intProduct.Product_Sub_Group__c; //Product Sub Group
            opportunity.RTL_Income_SL__c = intProduct.Income_SL__c; //Income - SL
            opportunity.RTL_Income_SE__c = intProduct.Income_SE__c; //Income - SE
            opportunity.RTL_Debt__c = intProduct.Debt__c; // Debt
            // Remove the mapping of Collateral Type as per business confirmation on 12 Aug.
            //opportunity.RTL_Collateral_Type__c = intProduct.Collateral_Type__c; //Collateral Type 
            opportunity.RTL_Loan_Calculation_Amount__c = intProduct.Loan_Amount__c; //Loan amount
            opportunity.RTL_Co_borrower_1__c = intProduct.Co_borrower_1__c; //Co-borrower 1
            opportunity.RTL_Co_borrower_2__c = intProduct.Co_borrower_2__c; //Co-borrower 2 
            opportunity.RTL_Referral__c = leadObj.RTL_Referral__c;
            
            /*
                Project: AL Integration
                Description: Mapping fields Auto loan create opportunity
                Editor: Narathip Santhip
                Date modified: 20201014
            */
            opportunity.RTL_AL_available_time__c = leadObj.RTL_AL_available_time__c;
            opportunity.RTL_AL_car_bought_from__c = leadObj.RTL_AL_car_bought_from__c;
            opportunity.RTL_AL_car_brand__c = leadObj.RTL_AL_car_brand__c;
            opportunity.RTL_AL_car_gear__c = leadObj.RTL_AL_car_gear__c;
            opportunity.RTL_AL_car_group__c = leadObj.RTL_AL_car_group__c;
            opportunity.RTL_AL_car_plate_no__c = leadObj.RTL_AL_car_plate_no__c;
            opportunity.RTL_AL_car_subtype__c = leadObj.RTL_AL_car_subtype__c;
            opportunity.RTL_AL_car_type__c = leadObj.RTL_AL_car_type__c;
            opportunity.RTL_AL_car_year__c = leadObj.RTL_AL_car_year__c;
            opportunity.RTL_AL_comment__c = leadObj.RTL_AL_comment__c;
            opportunity.RTL_AL_contact_channel__c = leadObj.RTL_AL_contact_channel__c;
            opportunity.RTL_AL_ContactDistrict__c = leadObj.RTL_AL_ContactDistrict__c;
            opportunity.RTL_AL_ContactProvince__c = leadObj.RTL_AL_ContactProvince__c;
            opportunity.RTL_AL_ContactSubDistrict__c = leadObj.RTL_AL_ContactSubDistrict__c;
            opportunity.RTL_AL_ContactZipcode__c = leadObj.RTL_AL_ContactZipcode__c;
            opportunity.RTL_AL_installment_amount__c = leadObj.RTL_AL_installment_amount__c;
            opportunity.RTL_AL_installment_periods__c = leadObj.RTL_AL_installment_periods__c;
            opportunity.RTL_AL_Interested_Rate__c = leadObj.RTL_AL_Interested_Rate__c;
            opportunity.RTL_AL_max_set_up_amount__c = leadObj.RTL_AL_max_set_up_amount__c;
            opportunity.RTL_AL_normal_price__c = leadObj.RTL_AL_normal_price__c;
            opportunity.RTL_AL_oa_ref_code__c = leadObj.RTL_AL_oa_ref_code__c;
            opportunity.RTL_AL_wanted_amount__c = leadObj.RTL_AL_wanted_amount__c;
            opportunity.RTL_AL_BlueBook__c = leadObj.RTL_AL_BlueBook__c;
            
            updateOpportunities.add(opportunity);
        }   
    }
    
    /**
     * @desc This method would associate interested product with account records which were associated with lead being converted
     * @param [Lead leadObj]
     */
    private void insertInterestedProductsForConvertedAccounts(Lead leadObj){
        //associate lead interested product to customer
       for(RTL_Interested_products_c__c relatedInterestedProduct : [Select Id, Lead__c, Customer__c FROM RTL_Interested_products_c__c 
                               WHERE Lead__c =:leadObj.Id]) {                   
           relatedInterestedProduct.Customer__c = leadObj.convertedAccountId;
           updateInterestedProducts.add(relatedInterestedProduct);
       }
    }
    
    private void createReferralsToUpdate(Lead leadObj){
        RTL_Referral__c referral = new RTL_Referral__c();
        referral.id = leadObj.RTL_Referral__c;
        referral.RTL_Account_Name__c = leadObj.convertedAccountId;
        referral.RTL_Stage__c = 'In progress_Contacted';
        if(leadObj.ConvertedOpportunityId != null){
            referral.RTL_Stage__c = 'Closed (Interested)';
        }
        
        updateReferrals.add(referral);
    }
    
    /**
     * This is the method to auto assign lead queue (FR-011)
     **/
    private static void prepareLeadInfo(List<Lead> leads) {      
        //Keep the list of the lead queues, where queue Id will be assigned as lead OwnerId
        // Map<String, Group> queueMap = new Map<String, Group>();
        // Map<String, Group> queueMapFullName = new Map<String, Group>();

        List<Lead> leadNotDup = new List<Lead>();

        // String branchCode = null;

        // for(Group queue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
        //     branchCode = queue.DeveloperName;//e.g. DeveloperName=RTLQ_001, branchcode=001
        //     if (branchCode.indexOf('_') != -1) {
        //         branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
        //     }
        //     queueMap.put(branchCode, queue);
        //     queueMapFullName.put(queue.DeveloperName, queue);
        // }
        
        //Keep the list of the lead assignment criteria in map, which will help to determine the lead queue
        // Map<String, RTL_Assignment_Criterias__c> ruleMap = new Map<String, RTL_Assignment_Criterias__c>();

        // for(RTL_Assignment_Criterias__c rule : [SELECT Product_Name__r.Name, Destination_BKK__c, Destination_UPC__c FROM RTL_Assignment_Criterias__c]){
        //     ruleMap.put(rule.Product_Name__r.Name, rule);
        // }

        // String queryBranchField = 'Name, Branch_Name__c, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c';

        // for(RTL_Lead_Assignment_Rule__c rule : leadAssignmentRule.values()){
        //     if(RTL_Utility.isNotNull(rule.RTL_Branch_and_Zone_Queue_User_field__c)  && !queryBranchField.contains(rule.RTL_Branch_and_Zone_Queue_User_field__c)){
        //         queryBranchField += ', ' + rule.RTL_Branch_and_Zone_Queue_User_field__c;
        //     }
        // }

        //Keep the branch Name into list for lead owner to lookup
        //CR Web-Drop Lead , query only active branch
        
        // String queryStr = 'SELECT ' + queryBranchField + ' FROM Branch_and_Zone__c WHERE isActive__c = true';
        // List<Branch_and_Zone__c> tempObj = Database.query(queryStr);

        // Map<String, Branch_and_Zone__c> branchCodeMap = new Map<String, Branch_and_Zone__c>();

        // for(Branch_and_Zone__c branchzone : tempObj){
        //     branchCodeMap.put(branchzone.Branch_Code__c, branchzone);
        // }
            
        // Set<String> leadOwnerIds = new Set<String>();

        // for (Lead lead : leads){
        //     leadOwnerIds.add(lead.OwnerId);
        //     System.debug('lead : ' + lead);
        //     RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule = getAssignMatchedRule(lead);
        //     System.debug('LeadMatchAssignmentRule : ' + LeadMatchAssignmentRule);
        //     if(LeadMatchAssignmentRule != null){
        //         lead.RTL_Lead_Assigned_By_Rule__c = LeadMatchAssignmentRule.Id;
                
        //         if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)){
        //             leadOwnerIds.add(String.valueOf(lead.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)));
        //             System.debug(String.valueOf(lead.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)));
        //         }
                
        //         if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)){
        //             leadOwnerIds.add(String.valueOf(branchCodeMap.get(lead.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)));
        //             System.debug(String.valueOf(branchCodeMap.get(lead.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)));
        //         }
        //     }
        //     System.debug('leadOwnerIds : ' + leadOwnerIds);
        // }

        // for(RTL_Lead_Assignment_Rule__c rule : leadAssignmentRule.values()){
        //     if(RTL_Utility.isNotNull(rule.RTL_Assigned_User__c)) leadOwnerIds.add(rule.RTL_Assigned_User__c);
        //     if(RTL_Utility.isNotNull(rule.RTL_Default_User__c)) leadOwnerIds.add(rule.RTL_Default_User__c);
        // }

        //Keep the list of the lead owner as users
        // Map<Id, User> userMap = new Map<Id, User>();
        // for(User u : [SELECT Id, Name, RTL_Branch__c, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c, IsActive FROM User WHERE Id IN :leadOwnerIds]){
        //     userMap.put(u.Id, u);
        // }
                   
        
        //Date 2018-05-11
        //By: Danudath
        //CR Lead Duplication Management - Check duplicate for lead from Web-to-Lead
        //Query lead record for check duplicate by createdDate = Today and lead created from web
        List<Lead> leadForCheckDup = New List<Lead>();
        Map<String,String> mapCheckDupLead = New Map<String,String>();
        String[] lastName_List = new String[]{};

        for(Lead newLead : leads){
            if(newLead.LastName != ''){
                lastName_List.add(newLead.LastName);
                //Map all new lead for check duplicate
                String keyDup = newLead.FirstName + newLead.LastName + newLead.RTL_Mobile_Number__c + newLead.RTL_Product_Name__c;
                mapCheckDupLead.put(keyDup.toLowerCase(),newLead.RTL_Web_Unique_ID_c__c);
            }
        }

        if(lastName_List.size() > 0){
           leadForCheckDup = [SELECT Id, FirstName, LastName, RTL_Customer_Segment__c, RTL_Product_Name__c, RTL_Web_Unique_ID_c__c, RTL_Mobile_Number__c FROM Lead WHERE CreatedDate = Today AND RTL_Web_Unique_ID_c__c != '' AND RTL_IsDuplicate_Lead__c = false AND LastName IN: lastName_List]; 
        }

        //Map all existing lead for check duplicate
        if(leadForCheckDup.size() > 0){
            for(lead existingDup : leadForCheckDup){
                //Key for check duplicate lead from web is FirstName + LastName + Mobile + product Name
                String keyDup = existingDup.FirstName + existingDup.LastName + existingDup.RTL_Mobile_Number__c + existingDup.RTL_Product_Name__c;
                mapCheckDupLead.put(keyDup.toLowerCase(),existingDup.RTL_Web_Unique_ID_c__c);
            }
        }
        //End 
        
        // String failProducts = null;
        // Set<String> productNameList = null;
        // RTL_Assignment_Criterias__c assignRule = null;
        // RTL_AssignmentCriteriaService assignmentService = null;
        
        for(Lead leadObj : leads){
            //Check duplicate before process other rule. Key for check duplicate lead from web is FirstName + LastName + Mobile + product Name
            //If Lead duplicate tick RTL_IsDuplicate_Lead__c = True and not process assignment rule
            String keyCheckDup = leadObj.FirstName + leadObj.LastName + leadObj.RTL_Mobile_Number__c + leadObj.RTL_Product_Name__c;

            if(mapCheckDupLead.size() > 0 &&  mapCheckDupLead.containsKey(keyCheckDup.toLowerCase()) && leadObj.RTL_Web_Unique_ID_c__c != mapCheckDupLead.get(keyCheckDup.toLowerCase())){
                System.debug('Duplicate Lead!');
                leadObj.OwnerID = tmbAdmin.ID;
                leadObj.RTL_IsDuplicate_Lead__c = true;
                leadObj.RTL_Duplicate_With_ID__c = 'Duplicated with record ID ' + mapCheckDupLead.get(keyCheckDup.toLowerCase());
                leadObj.Status = 'Duplicated';
                leadObj.RTL_Lead_Assigned_By_Rule__c = null; //Clear assignment rule
            }else{
                //Check if it's From web or ATM to Lead
                //only continue if it's retail record type
                // if(leadObj.RTL_TMB_Campaign_Source__c!= null && (leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Web') || leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('ATM Request') || leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Call me now')) && RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {
                //Get Product Name from lead object, which may contains multiple products delimited by ";"
                
                leadObj.Status = leadObj.Status == null ? 'New' : leadObj.Status;
                leadObj.RTL_Register_Date__c = leadObj.RTL_Register_Date__c == null ? System.today() : leadObj.RTL_Register_Date__c;
                leadObj.RTL_Call_Me_Now_Retry_Count__c = 0;

                leadNotDup.add(leadObj);                
                //only auto assign to lead queue if custom settings Lead Assignment/Auto Assign/Enable__c = true
                // if(RTL_Lead_Assignment__c.getValues('Auto Assign') != null && RTL_Lead_Assignment__c.getValues('Auto Assign').Enable__c) {
                //     if(leadObj.RTL_Lead_Assigned_By_Rule__c != null){
                //         RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule = leadAssignmentRule.get(leadObj.RTL_Lead_Assigned_By_Rule__c);
                //         System.debug('LeadMatchAssignmentRule : ' + LeadMatchAssignmentRule);

                //         if(LeadMatchAssignmentRule.RTL_Assigned_Apex__c != null){
                //             if(LeadMatchAssignmentRule.RTL_Assigned_Apex__c == 'RTL_AssignmentCriteriaService'){
                //                 assignmentService = assignmentService == null ? new RTL_AssignmentCriteriaService() : assignmentService;

                //                 String w2lBranchCode = leadObj.RTL_Branch_Name__c;
                //                 Boolean isMultipleProducts = leadObj.RTL_Multiple_Interested_Product_s__c == null ? false : leadObj.RTL_Multiple_Interested_Product_s__c;

                //                 String queueName = assignmentService.assignmentCriteria(leadObj.RTL_TMB_Campaign_Source__c, leadObj.RTL_BranchW2L_Area__c, leadObj.RTL_Product_Name__c, isMultipleProducts, w2lBranchCode);

                //                 leadObj.ownerId = queueMap.get(queueName) == null ? tmbAdmin.id : queueMap.get(queueName).Id;

                //                 System.debug('Q Name :: ' + queueName + 'Q info :: ' + queueMap.get(queueName));

                //                 //Assign queue Id to lead OwnerId
                //                 if (queueName != null) {
                //                     //branch queue
                //                     if (queueName != 'Outbound' && queueName != 'TMB Admin' && branchCodeMap.get(w2lBranchCode) != null) {
                //                         Branch_and_Zone__c branch = branchCodeMap.get(w2lBranchCode);
                //                         leadObj.RTL_Branch_and_Zone__c = branch.Id;
                //                         leadObj.RTL_Branch_Team_Name_Code_Rpt__c = branch.Name;
                //                         leadObj.RTL_Branch_Code_Rpt__c = branch.Branch_Code__c;
                //                         leadObj.RTL_Region_Code_Rpt__c = branch.RTL_Region_Code__c;
                //                         leadObj.RTL_Zone_Code_Rpt__c = branch.RTL_Zone_Code__c;                                  
                //                     } else {//outbound queue or branch is not defined in branch_and_zone
                //                         leadObj.RTL_Branch_and_Zone__c = null;                                  
                //                     }
                //                 }
                //             }

                //             //****** ADD APEX FUNCTION HERE ******

                //         }else{
                //             // IF IS PRODUCT WILL STAMP RTL_Lead_Campaign_Outbound__c AND RTL_Lead_Campaign_Outbound__c
                //             if(LeadMatchAssignmentRule.RTL_Integration_Type__c != null){
                //                 leadObj.RTL_Lead_Campaign_Outbound__c = mapProductOutboundDetail.containsKey(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c) ? mapProductOutboundDetail.get(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c).RTL_Lead_Campaign_Outbound__c : null;
                //                 leadObj.RTL_Lead_Channel_Outbound__c = mapProductOutboundDetail.containsKey(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c) ? mapProductOutboundDetail.get(leadObj.RTL_Product_Name__c + leadObj.RTL_Contact_Method__c).RTL_Lead_Channel_Outbound__c : null;
                //             }

                //             assignLeadOwnerByRule(leadObj, LeadMatchAssignmentRule, userMap, queueMapFullName, branchCodeMap);
                //         }
                //     }else{
                //         // leadObj.ownerId = tmbAdmin.id;
                //         assignLeadOwnerBranch(leadObj, userMap, branchCodeMap);
                //     }
                // } else {
                //     // leadObj.ownerId = tmbAdmin.id;
                //     //if not custom setting is not enabled, the lead owner will be user
                //     assignLeadOwnerBranch(leadObj, userMap, branchCodeMap);
                // }
                // } else {
                //     //if not web-to-lead, the lead owner will be user
                //     assignLeadOwnerBranch(leadObj, userMap, branchCodeMap);    
                // }
            }
            // System.debug('Lead Id : ' + leadObj.id + ' , Owner : ' + leadObj.OwnerId);
        }
        
        if(leadNotDup.size() > 0) LeadAssignmentUtil.assignLeadOwnerByLeadAssignmentrule(leadNotDup);
        
        List<String> productGroupList = new List<String>();
        List<String> branchList = new List<String>();

        for (Lead leadObj : leadNotDup) {
            if(LeadAssignmentUtil.mapIdQueue.containsKey(leadObj.OwnerId)){
                String branchCode = LeadAssignmentUtil.mapIdQueue.get(leadObj.OwnerId).DeveloperName;
                System.debug('Owner BR: ' + branchCode);
                if(branchCode.indexOf('_') != -1) {
                    branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                }
                
                if (LeadAssignmentUtil.mapBranchCode.containsKey(branchCode)) {
                    Branch_and_Zone__c branch = LeadAssignmentUtil.mapBranchCode.get(branchCode);
                    leadObj.RTL_Branch_and_Zone__c = branch.Id;
                    leadObj.RTL_Branch_Team_Name_Code_Rpt__c = branch.Name;
                    leadObj.RTL_Branch_Code_Rpt__c = branch.Branch_Code__c;
                    leadObj.RTL_Region_Code_Rpt__c = branch.RTL_Region_Code__c;
                    leadObj.RTL_Zone_Code_Rpt__c = branch.RTL_Zone_Code__c;
                    leadBranchList.add(leadObj); 
                    
                    RTL_product_master__c productMaster = productMap.get(leadObj.RTL_Product_Name__c);
                    productGroupList.add(productMaster.Product_Group__c);
                    branchList.add(branchCode);
                    
                }
            }else if(LeadAssignmentUtil.mapIdUser.containsKey(leadObj.OwnerId)){
                User user = LeadAssignmentUtil.mapIdUser.get(leadObj.OwnerId);
                System.debug('Owner User: ' + user.Name);
                if (user != null) {
                    if (user.RTL_Branch_Code__c != null && LeadAssignmentUtil.mapBranchCode.containsKey(user.RTL_Branch_Code__c)) {
                        leadObj.RTL_Branch_and_Zone__c = LeadAssignmentUtil.mapBranchCode.get(user.RTL_Branch_Code__c).Id;   
                    } else {
                        leadObj.RTL_Branch_and_Zone__c = null;
                    }
                    leadObj.RTL_Branch_Team_Name_Code_Rpt__c = user.RTL_Branch__c;
                    leadObj.RTL_Branch_Code_Rpt__c = user.RTL_Branch_Code__c;
                    leadObj.RTL_Region_Code_Rpt__c = user.Region_Code__c;
                    leadObj.RTL_Zone_Code_Rpt__c = user.Zone_Code__c;   
                    leadObj.RTL_Lead_Channel__c = user.RTL_Channel__c;
                }       
            }
        }
        Map<String,ProductGroupSpecialistWrapper> specialistProductMap = new Map<String,ProductGroupSpecialistWrapper>();
        for(Specialist_and_Product_Group_Mapping__c eachSpecialist : [SELECT Id, Name, External_Key__c, Agent__c, Agent__r.Employee_ID__c, Title__c, Product_Group__c, Branch_Code__c,
                                                                            Last_Assigned_Lead_Date__c, Title_and_Product_Group_Mapping__c, IsActive__c 
                                                                        FROM Specialist_and_Product_Group_Mapping__c
                                                                        WHERE IsActive__c = true AND Product_Group__c IN:productGroupList AND Agent__r.RTL_Branch_Code__c IN: branchList
                                                                        ORDER BY Last_Assigned_Lead_Date__c, Agent__r.Employee_ID__c ASC NULLS FIRST]){
            String productSpecialKey = eachSpecialist.Product_Group__c + eachSpecialist.Branch_Code__c;
            ProductGroupSpecialistWrapper productSpecialWrapper = new ProductGroupSpecialistWrapper();
            if(specialistProductMap.containsKey(productSpecialKey)){
                productSpecialWrapper = specialistProductMap.get(productSpecialKey);
                productSpecialWrapper.specialistProductList.add(eachSpecialist);
            }else{
                productSpecialWrapper.currentIndex = 0;
                productSpecialWrapper.specialistProductList = new List<Specialist_and_Product_Group_Mapping__c>{eachSpecialist};
            }
            specialistProductMap.put(productSpecialKey,productSpecialWrapper);
        }
        Map<Id,Specialist_and_Product_Group_Mapping__c> mapSpecialistId = new Map<Id,Specialist_and_Product_Group_Mapping__c>();
        for(Lead eachLead : leadBranchList){
            if(productMap.containsKey(eachLead.RTL_Product_Name__c)){
                RTL_product_master__c productMaster = productMap.get(eachLead.RTL_Product_Name__c);
                String branchCode = LeadAssignmentUtil.mapIdQueue.get(eachLead.OwnerId).DeveloperName;
                if(branchCode.indexOf('_') != -1) {
                    branchCode = branchCode.substring(branchCode.indexOf('_') + 1, branchCode.length());
                }
                String productSpecialKey = productMaster.Product_Group__c + branchCode;
                if(specialistProductMap.containsKey(productSpecialKey)){
                    ProductGroupSpecialistWrapper productSpecialWrapper = specialistProductMap.get(productSpecialKey);
                    eachLead.OwnerId = productSpecialWrapper.specialistProductList[productSpecialWrapper.currentIndex].Agent__c;
                    productSpecialWrapper.specialistProductList[productSpecialWrapper.currentIndex].Last_Assigned_Lead_Date__c = DateTime.now();
                    mapSpecialistId.put(productSpecialWrapper.specialistProductList[productSpecialWrapper.currentIndex].Id,productSpecialWrapper.specialistProductList[productSpecialWrapper.currentIndex]);
                    // assignSpecialist.add(productSpecialWrapper.specialistProductList[productSpecialWrapper.currentIndex]);
                    specialistAssignedIdList.add(eachLead.OwnerId);
                    productSpecialWrapper.currentIndex += 1;
                    if(productSpecialWrapper.currentIndex > productSpecialWrapper.specialistProductList.size()-1){
                        productSpecialWrapper.currentIndex = 0;
                    }
                }
            }   
        }
        
        update mapSpecialistId.values();

    }

    private static void validateReferral(List<Lead> leadList){
        Set<Id> referralIdSet = new Set<Id>();
        List<RTL_Interested_products_c__c> interestProductList = new List<RTL_Interested_products_c__c>();
        Map<Id,RTL_Referral__c> referralMap;
        Map<String, RTL_product_master__c> productMap = new Map<String, RTL_product_master__c>();
        
        for(Lead leadObj : leadList){
            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                if(leadObj.RTL_Referral__c != null){
                    referralIdSet.add(leadObj.RTL_Referral__c);                
                }
            }
        }
        
        if(referralIdSet.size() > 0){
            referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,Name,RTL_Stage__c,RTL_Account_Name__c,OwnerId,RTL_Type__c,(SELECT Id,Name FROM Leads__r) FROM RTL_Referral__c WHERE ID IN:referralIdSet]);
        }
        
        for(Lead leadObj: leadList){
            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                if(leadObj.RTL_Referral__c != null && leadObj.RTL_isAllowedToUpdate__c == false){
                    RTL_Referral__c referral = referralMap.get(leadObj.RTL_Referral__c);
                    //If current user is not referral owner
                    if(referral.OwnerId != System.UserInfo.getUserId()){
                        leadObj.addError(System.Label.RTL_Referral_ERR012);
                    }
                    //If Referral attach with customer     
                    else if(referral.RTL_Account_Name__c != null){
                        leadObj.addError(System.Label.RTL_Referral_ERR002);
                    }
                    //If Referral Stage is not New or Contacted & In progress
                    else if(referral.RTL_Stage__c != 'New' && referral.RTL_Stage__c != 'In progress_Contacted'){
                        leadObj.addError(System.Label.RTL_Referral_ERR010);
                    }
                    //If Referral Type = Account Opening/Service don't allow link lead
                    else if(referral.RTL_Type__c == 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)'){
                        leadObj.addError(System.Label.RTL_Referral_ERR016);
                    }
                    //If Referral already has a lead attached
                    //else if(referral.Leads__r.size() > 0){
                    //modifed at 8 Aug 2017 referral's lead index 0 (because Referral can have only one lead) 
                    //must not be equal to lead.id
                    else if(referral.Leads__r.size() > 0 && referral.Leads__r[0].id != leadObj.Id){
                        leadObj.addError(System.Label.RTL_Referral_ERR011);
                    }
                }
                leadObj.RTL_isAllowedToUpdate__c = false;
            }
        }
    }    
    
    /**
    * This is the method to assign lead owner's branch information
    **/
    // private static void assignLeadOwnerBranch(Lead leadObj, Map<Id, User> userMap, Map<String, Branch_and_Zone__c> branchCodeMap) {
    //     User user = userMap.get(leadObj.OwnerId);
    //     if (user != null) {
    //         if (user.RTL_Branch_Code__c != null && branchCodeMap.get(user.RTL_Branch_Code__c) != null) {
    //             leadObj.RTL_Branch_and_Zone__c = branchCodeMap.get(user.RTL_Branch_Code__c).Id;   
    //         } else {
    //             leadObj.RTL_Branch_and_Zone__c = null;
    //         }
    //        leadObj.RTL_Branch_Team_Name_Code_Rpt__c = user.RTL_Branch__c;
    //        leadObj.RTL_Branch_Code_Rpt__c = user.RTL_Branch_Code__c;
    //        leadObj.RTL_Region_Code_Rpt__c = user.Region_Code__c;
    //        leadObj.RTL_Zone_Code_Rpt__c = user.Zone_Code__c;   
    //        leadObj.RTL_Lead_Channel__c = user.RTL_Channel__c;
    //     }       
    // }
    
    /**
     * This is the method to persist interested products from web-to-lead (FR-003)
     **/
    private static void addInterestedProducts(map<id,sObject> leadMap) {   
        // List of lead interested products to be inserted
        List<RTL_Interested_products_c__c> interestProductList = new List<RTL_Interested_products_c__c>();
        List<Lead> leads = new List<Lead>();
        
        String productName = null;
        Set<String> productNameList = null;
        Integer i = 0;
        RTL_Interested_products_c__c interestProduct = null;
        
        //Put all retail product master to map for later retrieval
        Map<String, RTL_product_master__c> productMap = new Map<String, RTL_product_master__c>();
        for(RTL_product_master__c product : [Select Id, Name, Product_Group__c, Product_Sub_group__c 
                                                         from RTL_product_master__c WHERE Active__c = true order by Name, Product_Group__c desc]) {
            if (product.Product_Group__c != 'Loan Retention') productMap.put(product.Name, product);                                                            
        }
        for (Id lId:leadMap.keySet()){
            Lead leadObj = (lead)leadMap.get(lId);
            //if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type 
            // Check if it's web-to-lead
            // if (leadObj.RTL_TMB_Campaign_Source__c != null && (leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Web') || leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('ATM Request') || leadObj.RTL_TMB_Campaign_Source__c.equalsIgnoreCase('Call me now'))) {
            RTL_Lead_Assignment_Rule__c rule = leadAssignmentRule.containsKey(leadObj.RTL_Lead_Assigned_By_Rule__c) ? leadAssignmentRule.get(leadObj.RTL_Lead_Assigned_By_Rule__c) : null;

            System.debug('lId : ' + lId);
            System.debug('rule : ' + rule);
            System.debug('leadObj : ' + leadObj);

            if(rule != null && rule.RTL_IsInsertProduct__c){
                // Get Product Name from lead object, which may contains multiple products delimited by ";"
                productName = leadObj.RTL_Product_Name__c;
                if (productName != null) {
                    productNameList = new Set<String>();
                    productNameList.addAll(productName.split(';'));
                    i = 0;
                    for (String name: productNameList) {
                        RTL_product_master__c productDetail = productMap.get(name);
                        if (productDetail != null) {
                            interestProduct = new RTL_Interested_products_c__c();
                            // Only set the first interested product as primary
                            if (i == 0) {
                                interestProduct.Is_Primary__c = true;
                                i++;
                            }
                            interestProduct.Product_Name__c = productDetail.Id;
                            interestProduct.product_group__c = productDetail.Product_Group__c;
                            interestProduct.Product_Sub_Group__c = productDetail.Product_Sub_group__c;
                            interestProduct.Lead__c = leadObj.Id;
                            // Add Loan Product information
                            
                            //interestProduct.Co_borrower_1__c = leadObj.W2L_Co_borrower1__c;
                            interestProduct.Co_borrower_1__c = leadObj.RTL_W2L_Co_borrower1__c;
                            //interestProduct.Co_borrower_2__c = leadObj.W2L_Co_borrower2__c;
                            interestProduct.Co_borrower_2__c = leadObj.RTL_W2L_Co_borrower2__c;
                            //interestProduct.Collateral_Type__c = leadObj.W2L_Collateral_Type__c;
                            interestProduct.Collateral_Type__c = leadObj.RTL_W2L_Collateral_Type__c;                               
                            //interestProduct.Debt__c = leadObj.W2L_Debt__c;
                            interestProduct.Debt__c = leadObj.RTL_W2L_Debt__c;
                            //interestProduct.Income_SE__c = leadObj.W2L_Income_SE__c;
                            interestProduct.Income_SE__c = leadObj.RTL_W2L_Income_SE__c;
                            //interestProduct.Income_SL__c = leadObj.W2L_Income_SL__c;
                            interestProduct.Income_SL__c = leadObj.RTL_W2L_Income_SL__c;
                            //interestProduct.Loan_Amount__c = leadObj.W2L_Loan_Amount__c;
                            interestProduct.Loan_Amount__c = leadObj.RTL_W2L_Calculated_Amount__c;
                            //interestProduct.Others_2__c = leadObj.W2L_Others2__c;
                            interestProduct.Others_2__c = leadObj.RTL_W2L_Transfer_Period__c;
                            //interestProduct.Others_3__c = leadObj.W2L_Others3__c;
                            interestProduct.Others_3__c = leadObj.RTL_W2L_Others1__c;
                            
                            interestProductList.add(interestProduct);
                        }
                    }
                }
            }
        }
        // insert lead interested product
        if (interestProductList.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(interestProductList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted lead interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error inserting lead interested product. Error Message is: ' + err.getMessage());
                    }
                }
            } 
        }
    }
    
    private static void addInterestedProductFromReferral(map<id,sObject> leadMap) {
        Set<Id> referralIdSet = new Set<Id>();
        List<RTL_Interested_products_c__c> interestProductList = new List<RTL_Interested_products_c__c>();
        Map<Id,RTL_Referral__c> referralMap;
        Map<String, RTL_product_master__c> productMap = new Map<String, RTL_product_master__c>();
        
        for(Id lId : leadMap.keySet()){
            Lead leadObj = (lead)leadMap.get(lId);
            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                if(leadObj.RTL_Referral__c != null){
                    referralIdSet.add(leadObj.RTL_Referral__c);                
                }
            }
        }
        
        if(referralIdSet.size() > 0){
            referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,Name,RTL_Product_Name__c,RecordType.DeveloperName FROM RTL_Referral__c WHERE ID IN:referralIdSet]);
        }
        
        for(Id lId : leadMap.keySet()){
            Lead leadObj = (lead)leadMap.get(lId);
            if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                if(leadObj.RTL_Referral__c != null){
                    RTL_Referral__c referral = referralMap.get(leadObj.RTL_Referral__c);
                    String productId = referral.RTL_Product_Name__c;
                    String recordTypeDevName = referral.RecordType.DeveloperName;
                    if(productId != null && recordTypeDevName == 'Retail_Cross_Channel_Referral'){
                      RTL_Interested_products_c__c interestProduct = new RTL_Interested_products_c__c();
                        interestProduct.Is_Primary__c = true;
                        interestProduct.Product_Name__c = productId;
                        interestProduct.Lead__c = leadObj.Id;
                        interestProductList.add(interestProduct);          
                  }
              }
          }
        }
        
        // insert lead interested product
        if (interestProductList.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(interestProductList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted lead interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error inserting lead interested product. Error Message is: ' + err.getMessage());
                    }
                }
            } 
        }
        
    }
    
    /**
     * This is the method to attach WebdropLead to an active Campaign (CR-Lead to MDM)
     **/
    private static void attachToCampaign(List<Lead> leadList) {

        System.debug('Lead for attach campaign : ' + leadList);
        RTL_Default_Campaign_Code__mdt defaultCampaignCode = [SELECT RTL_Value__c FROM RTL_Default_Campaign_Code__mdt WHERE masterLabel = 'Retail Default Campaign Web'];
        List<CampaignMember> campaignMemberToInsert = new List<CampaignMember>();

        /*List<Campaign> campaignList = [SELECT Id,Name FROM Campaign WHERE StartDate <= TODAY AND EndDate >= TODAY 
                                             AND RecordType.Name = 'Retail' ORDER BY StartDate ASC];*/
        
        List<Campaign> defaultCampaign = new List<Campaign>();
        if(defaultCampaignCode != null){
            defaultCampaign = [SELECT ID,Name FROM Campaign WHERE RTL_Campaign_Code_10_digits__c = :defaultCampaignCode.RTL_Value__C];
        }


        List<RTL_Campaign_Assignment_Rule__c> campaignAssignmentRule = [SELECT Id, Name, 
                                                            RTL_Campaign_Lead_Source__c,
                                                            RTL_TMB_Campaign_Reference__c,
                                                            LeadSource__c,
                                                            RTL_Customer_Segment__c,
                                                            RTL_Start_Date__c, 
                                                            RTL_End_Date__c, 
                                                            RTL_Campaign__c, 
                                                            RTL_Active__c,
                                                            RTL_Priority__c,
                                                            Is_Valid_Campaign__c
                                                            FROM RTL_Campaign_Assignment_Rule__c
                                                            WHERE RTL_Start_Date__c <= TODAY AND RTL_End_Date__c >= TODAY
                                                            and RTL_Active__c = true
                                                            ORDER BY RTL_Start_Date__c, RTL_Priority__c ASC NULLS LAST];

        List<RTL_Campaign_Assignment_Rule__c> campaignAssignmentRuleDefault = new List<RTL_Campaign_Assignment_Rule__c> ();

        for (Lead leadObj : leadList){    
            // If lead duplicate from Wed-to-Lead not assign to campaign member.		
            if(leadObj.RTL_IsDuplicate_Lead__c == false){
                CampaignMember campaignMemb = new CampaignMember();
                //If an active campaign found , attach lead to it
                if(campaignAssignmentRule.size() > 0){
                    for(RTL_Campaign_Assignment_Rule__c car : campaignAssignmentRule){
                        Boolean Criteria1 = car.RTL_Campaign_Lead_Source__c == null ? true : leadObj.RTL_TMB_Campaign_Source__c == car.RTL_Campaign_Lead_Source__c;
                        Boolean Criteria2 = car.RTL_TMB_Campaign_Reference__c == null ? true : leadObj.RTL_TMB_Campaign_Reference__c == car.RTL_TMB_Campaign_Reference__c;
                        Boolean Criteria3 = car.LeadSource__c == null ? true : leadObj.LeadSource == car.LeadSource__c;
                        Boolean Criteria4 = car.RTL_Customer_Segment__c == null ? true : leadObj.RTL_Customer_Segment__c == car.RTL_Customer_Segment__c;
                        Boolean Criteria5 = car.Is_Valid_Campaign__c;
                        
                        System.debug('Campaign RTL_Campaign_Lead_Source__c Criteria1 : ' + Criteria1);
                        System.debug('Campaign RTL_TMB_Campaign_Reference__c Criteria2 : ' + Criteria2);
                        System.debug('Campaign LeadSource__c Criteria3 : ' + Criteria3);
                        System.debug('Campaign RTL_Customer_Segment__c Criteria4 : ' + Criteria4);
                        System.debug('Campaign RTL_Customer_Segment__c Criteria5 : ' + Criteria5);

                        if(Criteria1 && Criteria2 && Criteria3 && Criteria4 && Criteria5){
                            campaignMemb.CampaignId = car.RTL_Campaign__c;
                            campaignMemb.LeadId = leadObj.id;
                            campaignMemb.RTL_TMB_Campaign_Source__c = leadObj.RTL_TMB_Campaign_Source__c;
                            campaignMemb.RTL_TMB_Campaign_Reference__c = leadObj.RTL_TMB_Campaign_Reference__c;
                            campaignMemb.RTL_Lead_Group__c = leadObj.RTL_Customer_Segment__c;
                            campaignMemb.RTL_Contact_Method__c = leadObj.RTL_Contact_Method__c;
                            campaignMemb.RTL_Assigned_Campaign_By_Rule__c = car.id;
                            break;
                        }
                    }

                    //Add default campaign to list
                    for(RTL_Campaign_Assignment_Rule__c car : campaignAssignmentRule){
                        if(car.LeadSource__c == 'Default' && car.Is_Valid_Campaign__c){
                            campaignAssignmentRuleDefault.add(car);
                        }
                    }

                    //If active campaign assignment rule not found , attach to the default campaign
                    if((campaignMemb.CampaignId == null && campaignMemb.LeadId == null) && campaignAssignmentRuleDefault.size() > 0){
                        for(RTL_Campaign_Assignment_Rule__c defaults : campaignAssignmentRuleDefault){
                            campaignMemb.CampaignId = defaults.RTL_Campaign__c;
                            campaignMemb.LeadId = leadObj.id;
                            campaignMemb.RTL_TMB_Campaign_Source__c = leadObj.RTL_TMB_Campaign_Source__c;
                            campaignMemb.RTL_TMB_Campaign_Reference__c = leadObj.RTL_TMB_Campaign_Reference__c;
                            campaignMemb.RTL_Lead_Group__c = leadObj.RTL_Customer_Segment__c;
                            campaignMemb.RTL_Contact_Method__c = leadObj.RTL_Contact_Method__c;
                            campaignMemb.RTL_Assigned_Campaign_By_Rule__c = defaults.id;
                            break;
                        }
                    }
                }
                
                //If active campaign not found , attach to the dummy campaign
                if(campaignMemb.CampaignId == null && campaignMemb.LeadId == null){
                    if(defaultCampaign.size() > 0){
                        campaignMemb.CampaignId = defaultCampaign[0].id;
                        campaignMemb.LeadId = leadObj.id;
                        campaignMemb.RTL_TMB_Campaign_Source__c = leadObj.RTL_TMB_Campaign_Source__c;
                        campaignMemb.RTL_TMB_Campaign_Reference__c = leadObj.RTL_TMB_Campaign_Reference__c;
                        campaignMemb.RTL_Lead_Group__c = leadObj.RTL_Customer_Segment__c;
                        campaignMemb.RTL_Contact_Method__c = leadObj.RTL_Contact_Method__c;
                    }
                }

                /*
                    Project: AL Integration
                    Description: Mapping fields Auto loan create campaign member
                    Editor: Narathip Santhip
                    Date modified: 20201014
                 */
                campaignMemb.RTL_Product_Name__c = leadObj.RTL_Product_Name__c;
                campaignMemb.RTL_AL_ContactZipcode__c = leadObj.RTL_AL_ContactZipcode__c;
                campaignMemb.RTL_AL_ContactProvince__c = leadObj.RTL_AL_ContactProvince__c;
                campaignMemb.RTL_AL_ContactDistrict__c = leadObj.RTL_AL_ContactDistrict__c;
                campaignMemb.RTL_AL_ContactSubDistrict__c = leadObj.RTL_AL_ContactSubDistrict__c;
                campaignMemb.RTL_AL_available_time__c = leadObj.RTL_AL_available_time__c;
                campaignMemb.RTL_AL_car_brand__c = leadObj.RTL_AL_car_brand__c;
                campaignMemb.RTL_AL_car_gear__c = leadObj.RTL_AL_car_gear__c;
                campaignMemb.RTL_AL_car_group__c = leadObj.RTL_AL_car_group__c;
                campaignMemb.RTL_AL_car_subtype__c = leadObj.RTL_AL_car_subtype__c;
                campaignMemb.RTL_AL_car_type__c = leadObj.RTL_AL_car_type__c;
                campaignMemb.RTL_AL_car_year__c = leadObj.RTL_AL_car_year__c;
                campaignMemb.RTL_AL_installment_amount__c = leadObj.RTL_AL_installment_amount__c;
                campaignMemb.RTL_AL_installment_periods__c = leadObj.RTL_AL_installment_periods__c;
                campaignMemb.RTL_AL_max_set_up_amount__c = leadObj.RTL_AL_max_set_up_amount__c;
                campaignMemb.RTL_AL_normal_price__c = leadObj.RTL_AL_normal_price__c;
                campaignMemb.RTL_AL_wanted_amount__c = leadObj.RTL_AL_wanted_amount__c;
                campaignMemb.RTL_AL_car_plate_no__c = leadObj.RTL_AL_car_plate_no__c;
                campaignMemb.RTL_AL_response__c = leadObj.RTL_AL_response__c; // HOT LEAD to top record.
                campaignMemb.RTL_AL_car_bought_from__c = leadObj.RTL_AL_car_bought_from__c;
                campaignMemb.RTL_AL_comment__c = leadObj.RTL_AL_comment__c;
                campaignMemb.RTL_AL_contact_channel__c = leadObj.RTL_AL_contact_channel__c;
                campaignMemb.RTL_AL_Interested_Rate__c = leadObj.RTL_AL_Interested_Rate__c;
                campaignMemb.RTL_AL_oa_ref_code__c = leadObj.RTL_AL_oa_ref_code__c;

                /**
                 * AL Ingretaion Phases 2
                 * Add field for touch app
                 */
                campaignMemb.RTL_AL_ILA_AMT__c = leadObj.RTL_AL_ILA_AMT__c;
                campaignMemb.RTL_AL_REMN_MTH__c = leadObj.RTL_AL_REMN_MTH__c;
                campaignMemb.RTL_AL_OFFR_ILA_AMT__c = leadObj.RTL_AL_OFFR_ILA_AMT__c;
                campaignMemb.RTL_AL_OFFR_ILA_MTH__c = leadObj.RTL_AL_OFFR_ILA_MTH__c;
                campaignMemb.RTL_AL_promotion_detail__c = leadObj.RTL_AL_promotion_detail__c;
                campaignMemb.RTL_AL_CAMP_EXP_DTE__c = leadObj.RTL_AL_CAMP_EXP_DTE__c;

                /** AL Droplead enhancement for TTB Web */
                campaignMemb.RTL_Lead_Remark__c = leadObj.RTL_Remark__c;

                /** Droplead MGM 022022 */
                campaignMemb.RTL_Cus_Refer_Code__c = leadObj.RTL_Cus_Refer_Code__c;
                
                /** Droplead CYC*/
                campaignMemb.RTL_AL_Car_Status__c = leadObj.RTL_AL_Car_Status__c;
                campaignMemb.RTL_AL_Leasing_Condition__c = leadObj.RTL_AL_Leasing_Condition__c;
                campaignMemb.RTL_Partner_Branch__c = leadObj.RTL_Partner_Branch__c;
                campaignMemb.RTL_Partner_Employee__c = leadObj.RTL_Partner_Employee__c;

                /** LGS WS2 enhancement */
                campaignMemb.Partner_Lead_ID__c = leadObj.Partner_Lead_ID__c;
                campaignMemb.RTL_AL_province_car_plate_no__c = leadObj.RTL_AL_province_car_plate_no__c;
                campaignMemb.Car_Reference_No__c = leadObj.Car_Reference_No__c;
                campaignMemb.LGS_VIN_No__c = leadObj.LGS_VIN_No__c;
                campaignMemb.RTL_AL_DownAmt__c = leadObj.RTL_AL_DownAmt__c;
                campaignMemb.RTL_AL_DownPercent__c = leadObj.RTL_AL_DownPercent__c;
                campaignMemb.RTL_AL_PayPerMonth__c = leadObj.RTL_AL_PayPerMonth__c;
                campaignMemb.RTL_AL_IsCarBooked__c = leadObj.RTL_AL_IsCarBooked__c;
                campaignMemb.RTL_Promotion__c = leadObj.RTL_Promotion__c;
                campaignMemb.RTL_Remark__c = leadObj.RTL_Remark__c;
                campaignMemb.RTL_W2L_Campaign_Name__c = leadObj.RTL_W2L_Campaign_Name__c;
                campaignMemb.LGS_Child_Campaign_ID__c = leadObj.LGS_Child_Campaign_ID__c;
                campaignMemb.LGS_Campaign_Start_Date__c = leadObj.LGS_Campaign_Start_Date__c;
                campaignMemb.LGS_Campaign_End_Date__c = leadObj.LGS_Campaign_End_Date__c;
                campaignMemb.RTL_Media_Source__c = leadObj.RTL_Media_Source__c;
                campaignMemb.RTL_Medium__c = leadObj.RTL_Medium__c;
                campaignMemb.RTL_W2L_Content__c = leadObj.RTL_W2L_Content__c;
                campaignMemb.RTL_W2L_Term__c = leadObj.RTL_W2L_Term__c;
                campaignMemb.RTL_AL_Income__c = leadObj.RTL_Income__c;
                campaignMemb.RTL_Consent__c = leadObj.RTL_Consent__c;
                campaignMemb.RTL_Market_Conduct__c = leadObj.RTL_Market_Conduct__c;
                campaignMemb.RTL_PDPA__c = leadObj.RTL_PDPA__c;
                campaignMemb.RTL_TC__c = leadObj.RTL_TC__c;
                campaignMemb.LGS_Partner__c = leadObj.LGS_Partner__c;
                // campaignMemb.RTL_Partner_Branch_Code__c = leadObj.RTL_Partner_Branch_Code__c;
                // campaignMemb.RTL_Partner_Employee_Code__c = leadObj.RTL_Partner_Employee_Code__c;
                campaignMemb.LGS_Lead_Received_Time__c = leadObj.LGS_Lead_Received_Time__c;
                campaignMemb.LGS_001__c = leadObj.LGS_001__c;
                campaignMemb.LGS_002__c = leadObj.LGS_002__c;
                campaignMemb.LGS_003__c = leadObj.LGS_003__c;
                campaignMemb.LGS_004__c = leadObj.LGS_004__c;
                campaignMemb.LGS_005__c = leadObj.LGS_005__c;
                campaignMemb.LGS_006__c = leadObj.LGS_006__c;
                campaignMemb.LGS_007__c = leadObj.LGS_007__c;
                campaignMemb.LGS_008__c = leadObj.LGS_008__c;
                campaignMemb.LGS_009__c = leadObj.LGS_009__c;
                campaignMemb.LGS_010__c = leadObj.LGS_010__c;
                campaignMemb.LGS_011__c = leadObj.LGS_011__c;
                campaignMemb.LGS_012__c = leadObj.LGS_012__c;
                campaignMemb.LGS_013__c = leadObj.LGS_013__c;
                campaignMemb.LGS_014__c = leadObj.LGS_014__c;
                campaignMemb.LGS_015__c = leadObj.LGS_015__c;
                campaignMemb.LGS_016__c = leadObj.LGS_016__c;
                campaignMemb.LGS_017__c = leadObj.LGS_017__c;
                campaignMemb.LGS_018__c = leadObj.LGS_018__c;
                campaignMemb.LGS_019__c = leadObj.LGS_019__c;
                campaignMemb.LGS_020__c = leadObj.LGS_020__c;
                campaignMemb.LGS_Assignment_Code__c = leadObj.LGS_Assignment_Code__c;
                campaignMemb.LGS_LinkInfo__c = leadObj.LGS_LinkInfo__c;
                campaignMemb.LGS_BrandCode__c = leadObj.LGS_BrandCode__c;
                campaignMemb.LGS_BrandShowroomCode__c = leadObj.LGS_BrandShowroomCode__c;
                campaignMemb.LGS_PartnerCode__c = leadObj.LGS_PartnerCode__c;
                campaignMemb.LGS_File_Upload__c = leadObj.LGS_File_Upload__c;
                campaignMemb.RTL_Integration_System__c = leadObj.RTL_Integration_System__c;
                campaignMemb.Scoring_Condition_Id__c = leadObj.Scoring_Condition_Id__c;
                campaignMemb.RTL_Partner_Branch_Code__c = leadObj.RTL_Partner_Branch_Code__c;
                campaignMemb.RTL_Partner_Employee_Code__c = leadObj.RTL_Partner_Employee_Code__c;
                campaignMemb.RTL_AL_Showroom__c = leadObj.RTL_AL_Showroom__c;
                campaignMemb.RTL_AL_TentName__c = leadObj.RTL_AL_TentName__c;

                campaignMemberToInsert.add(campaignMemb);
            } 
        } 
        if(campaignMemberToInsert.size() > 0){
            System.debug('Lead attach to Campaign member : '+campaignMemberToInsert);
            campaignMember = campaignMemberToInsert;
            // insert campaignMemberToInsert;
            Database.SaveResult[] lsr = Database.insert(campaignMemberToInsert, false);
            // Iterate through each returned result
            Integer index = 0;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('log test sr : '+sr);
                    System.debug('Successfully attach web-drop-lead to campaign.');
                    
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMessage = err.getMessage();
                        System.debug(err);
                        System.debug(logginglevel.ERROR, 'There is error on attach web-drop-lead to campaign . Error Message is: ' + errorMessage);
                        CampaignMember errorCampaignMember = campaignMemberToInsert[index];
                        if(errorMessage.containsIgnoreCase('unable to obtain exclusive access to this record')){
                            System.debug('retry insert campaign');
                            Boolean insertSuccess = false;
                            for(Integer i = 0; i<2;i++){
                                Integer round = i+1;
                                System.debug('round : '+round);                                
                                errorCampaignMember.RTL_Retry_Info__c = 'SUCCESS_ON_RETRY_'+round;
                                insertSuccess = RTL_Utility.retryInsertRecord(errorCampaignMember);
                                if(insertSuccess){
                                    break; 
                                }

                            }
                            System.debug('is insert success ::: '+insertSuccess );
                            if(insertSuccess == false){
                                errorCampaignMember.RTL_Retry_Info__c = '';
                                String message = JSON.serialize(errorCampaignMember);
                                System.debug('serialize json :: '+ message);
                                RTL_Utility.InsertRTLog(errorCampaignMember.Leadid
                                ,''
                                ,UserInfo.getName()
                                ,''
                                ,message
                                ,''
                                ,null
                                ,System.now()
                                ,Datetime.now()
                                ,'Insert Retry Rowlock Fail'
                                ,false
                                );
                            }
                            
                        }
                    }
                }
                index++;
            } 
        } 

    }


    /**
    *
    * CR R4.1 Simplefied Lead : FR-001 Insert/Update Primary interest product
    *        
    */
    private static void addInterestedProductFromLead(map<id, sObject> oldLeadMap, map<id,sObject> leadMap) {   
        // List of lead interested products to be inserted
        List<RTL_Interested_products_c__c> interestProductList = new List<RTL_Interested_products_c__c>();
        List<RTL_Interested_products_c__c> updateinterestProductList = new List<RTL_Interested_products_c__c>();
        List<RTL_Interested_products_c__c> updatePrimaryinterestProductList = new List<RTL_Interested_products_c__c>();
        RTL_Interested_products_c__c interestProduct = null;
        RTL_Interested_products_c__c primaryProduct = null;

        Map<String, RTL_Interested_products_c__c> interestProductMap = new Map<String, RTL_Interested_products_c__c>();
        Map<String, RTL_Interested_products_c__c> primaryInterestProductMap = new Map<String, RTL_Interested_products_c__c>();
        for(RTL_Interested_products_c__c interestedProduct : [
                                                                SELECT Id, Lead__c, Product_Name__c, Is_Primary__c
                                                                FROM RTL_Interested_products_c__c 
                                                                WHERE Lead__c in :leadMap.keySet()
                                                                ORDER BY LastModifiedDate desc
                                                            ])
        {
             
            if(interestedProduct.Is_Primary__c == true)
            {
                primaryInterestProductMap.put(interestedProduct.Lead__c, interestedProduct);
            }
            else
            {
                String key = (String)interestedProduct.Lead__c+interestedProduct.Product_Name__c;
                interestProductMap.put(key, interestedProduct); 
            }                                                        
        }

        for (Id lId:leadMap.keySet()){
            Lead leadObj = (lead)leadMap.get(lId);
            Lead oldLeadObj;
            String productLeadKey;
            
            if(oldLeadMap != null && oldLeadMap.containsKey(lId))
            {
                oldLeadObj = (lead)oldLeadMap.get(lId);
            }
            //Update Lead
            if(oldLeadObj != null)
            {              
                // System.debug('TEST_oldLeadObj: '+ oldLeadObj.RTL_Primary_Interested_Product__c);
                // System.debug('TEST_leadObj: '+ leadObj.RTL_Primary_Interested_Product__c);
                if(oldLeadObj.RTL_Primary_Interested_Product__c != leadObj.RTL_Primary_Interested_Product__c )
                {

                    if(oldLeadObj.RTL_Primary_Interested_Product__c != null && leadObj.RTL_Primary_Interested_Product__c != null)
                    {
                       
                        productLeadKey = (String)leadObj.Id+leadObj.RTL_Primary_Interested_Product__c;
                        interestProduct = interestProductMap.get(productLeadKey);
                        primaryProduct = primaryInterestProductMap.get(leadObj.Id);

                        //found existing interested product with input product and lead already has primary product
                        if(interestProduct != null && primaryProduct != null)
                        {
                            interestProduct.Is_Primary__c = true;
                            updateinterestProductList.add(interestProduct);

                            primaryProduct.Is_Primary__c = false;
                            updatePrimaryinterestProductList.add(primaryProduct);
                        }
                        //no interested product record with input product but lead already has primary product
                        else if(interestProduct == null && primaryProduct != null)
                        {
                            primaryProduct.Product_Name__c = leadObj.RTL_Primary_Interested_Product__c;
                            updateinterestProductList.add(primaryProduct);
                        }
                        //no interested product record with input product and lead don't have primary product 
                        else
                        {
                            RTL_Interested_products_c__c newInterestProduct = new RTL_Interested_products_c__c();
                            newInterestProduct.Is_Primary__c = true;
                            newInterestProduct.Lead__c = leadObj.Id;
                            newInterestProduct.Product_Name__c = leadObj.RTL_Primary_Interested_Product__c;
                            interestProductList.add(newInterestProduct);
                        }

                    }
                    else if(leadObj.RTL_Primary_Interested_Product__c != null )
                    {
                        productLeadKey = (String)leadObj.Id+leadObj.RTL_Primary_Interested_Product__c;
                        interestProduct = interestProductMap.get(productLeadKey);
                        if(interestProduct != null)
                        {
                            interestProduct.Is_Primary__c = true;
                            updateinterestProductList.add(interestProduct);
                        }
                        else
                        {
                            RTL_Interested_products_c__c newInterestProduct = new RTL_Interested_products_c__c();
                            newInterestProduct.Is_Primary__c = true;
                            newInterestProduct.Lead__c = leadObj.Id;
                            newInterestProduct.Product_Name__c = leadObj.RTL_Primary_Interested_Product__c;
                            interestProductList.add(newInterestProduct);
                        }
                    }
                    else if(leadObj.RTL_Primary_Interested_Product__c == null)
                    {
                        primaryProduct = primaryInterestProductMap.get(leadObj.Id);
                        System.debug('primary interested product '+interestProduct);
                        if(primaryProduct != null){
                            primaryProduct.Is_Primary__c = false;
                            updatePrimaryinterestProductList.add(primaryProduct);
                        }
                        
                    }
                    
                }
            //Create Lead
            }
            else
            {
                if(leadObj.RTL_Primary_Interested_Product__c != null)
                {
                    RTL_Interested_products_c__c newInterestProduct = new RTL_Interested_products_c__c();
                    newInterestProduct.Is_Primary__c = true;
                    newInterestProduct.Lead__c = leadObj.Id;
                    newInterestProduct.Product_Name__c = leadObj.RTL_Primary_Interested_Product__c;
                    interestProductList.add(newInterestProduct);
                }
            }
        }
        
        // insert lead interested product
        if (interestProductList.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(interestProductList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted lead interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error inserting lead interested product. Error Message is: ' + err.getMessage());
                    }
                }
            } 
        }

        // update lead interested product
        if (updatePrimaryinterestProductList.size() > 0) {
            Database.SaveResult[] lsr = Database.update(updatePrimaryinterestProductList, false);
            // Iterate through each returned result
            Integer i = 0;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead primary interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        leadMap.get(updatePrimaryinterestProductList[i].Lead__c).addError(err.getMessage());
                        System.debug(logginglevel.ERROR, 'There is error updating lead primary interested product. Error Message is: ' + err.getMessage());
                    }
                }
                i++;
            } 
        }

        // update lead interested product
        if (updateinterestProductList.size() > 0) {
            Database.SaveResult[] lsr = Database.update(updateinterestProductList, false);
            // Iterate through each returned result
            Integer i = 0;
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated lead interested product.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        leadMap.get(updateinterestProductList[i].Lead__c).addError(err.getMessage());
                        System.debug(logginglevel.ERROR, 'There is error updating lead interested product. Error Message is: ' + err.getMessage());
                    }
                }
                i++;
            } 
        }
    }
     
     /**
    *
    * CR R4.1 Simplefied Lead 4 Sep 2018 : FR-004 Migrate data to field Reason , this is additional CR due to impact on CR142
    *        
    */
    private static void transformReasons(map<id, sObject> oldMap, map<id,sObject> newMap) {   
        for (Id lId:newMap.keySet()){
            Lead leadObj = (lead)newMap.get(lId);
            Lead oldLeadObj = (lead)oldMap.get(lId);

            if(leadObj.RTL_Uncontact_reason__c != oldLeadObj.RTL_Uncontact_reason__c && leadObj.Status == 'Uncontacted'){
                leadObj.RTL_Reason__c = leadObj.RTL_Uncontact_reason__c;
            }else if(leadObj.RTL_Lost_Reason__c != oldLeadObj.RTL_Lost_Reason__c && leadObj.Status == 'Closed Lost'){
                leadObj.RTL_Reason__c = leadObj.RTL_Lost_Reason__c;
            }
        }          

    }

    // private static RTL_Lead_Assignment_Rule__c getAssignMatchedRule(lead leadObj){
    //     RTL_Lead_Assignment_Rule__c result;
        
    //     for(RTL_Lead_Assignment_Rule__c rule : leadAssignmentRule.values()){
    //         if(checkCriteria(leadObj, rule)){
    //             result = rule;
    //             break;
    //         }
    //     }
    //     return result;
    // }

    // public static Boolean checkCriteria(Lead leadObj, RTL_Lead_Assignment_Rule__c rule){
    //     Boolean result = false;

    //     Boolean cond1 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_1__c);
    //     Boolean cond2 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_2__c);
    //     Boolean cond3 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_3__c);
    //     Boolean cond4 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_4__c);
    //     Boolean cond5 = !RTL_Utility.isNotNull(rule.RTL_Lead_Field_Criteria_5__c);

    //     cond1 = checkCondition(rule.RTL_Lead_Field_Criteria_1__c, leadObj, rule.RTL_Lead_Field_Value_1__c);
    //     // System.debug('cond1 : ' + cond1);
    //     cond2 = checkCondition(rule.RTL_Lead_Field_Criteria_2__c, leadObj, rule.RTL_Lead_Field_Value_2__c);
    //     // System.debug('cond2 : ' + cond2);
    //     cond3 = checkCondition(rule.RTL_Lead_Field_Criteria_3__c, leadObj, rule.RTL_Lead_Field_Value_3__c);
    //     // System.debug('cond3 : ' + cond3);
    //     cond4 = checkCondition(rule.RTL_Lead_Field_Criteria_4__c, leadObj, rule.RTL_Lead_Field_Value_4__c);
    //     // System.debug('cond4 : ' + cond4);
    //     cond5 = checkCondition(rule.RTL_Lead_Field_Criteria_5__c, leadObj, rule.RTL_Lead_Field_Value_5__c);
    //     // System.debug('cond5 : ' + cond5);

    //     if(cond1 && cond2 && cond3 && cond4 && cond5){
    //         result = true;           
    //     }

    //     return result;
    // }

    // private static Boolean checkCondition(String cond, SObject data, String condValue){
    //     if(cond == null || cond == ''){
    //         return true;
    //     }
        
    //     // System.debug(cond);
    //     // System.debug(data.get(cond));
    //     // System.debug(condValue);
        
    //     if(String.valueOf(data.get(cond)) == condValue){
    //     	return true;    
    //     }
    //     return false;
    // }

    // private static void assignLeadOwnerByRule(Lead leadObj, RTL_Lead_Assignment_Rule__c LeadMatchAssignmentRule, Map<Id, User> userMap, Map<String, Group> queueMap, Map<String, Branch_and_Zone__c> branchCodeMap){
    //     // 2.1 Assigned User
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_User__c)){
    //         if(userMap.containsKey(LeadMatchAssignmentRule.RTL_Assigned_User__c) && userMap.get(LeadMatchAssignmentRule.RTL_Assigned_User__c).IsActive){
    //             leadObj.ownerId = LeadMatchAssignmentRule.RTL_Assigned_User__c;
    //             System.debug(userMap.get(leadObj.ownerId).Name);
    //             return ;
    //         }
    //     }
    //     // 2.2 Assigned User field
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_User_field__c)){
    //         if(userMap.containsKey(String.valueOf(leadObj.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c))) && userMap.get(String.valueOf(leadObj.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c))).IsActive){
    //             leadObj.ownerId = userMap.get(String.valueOf(leadObj.get(LeadMatchAssignmentRule.RTL_Assigned_User_field__c))).Id;
    //             System.debug(userMap.get(leadObj.ownerId).Name);
    //             return ;
    //         }
    //     }
        
    //     // 3.1 Assigned Queue Name	
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c)){
    //         if(queueMap.containsKey(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c)){
    //             leadObj.ownerId = queueMap.get(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c).Id;
    //             System.debug(queueMap.get(LeadMatchAssignmentRule.RTL_Assigned_Queue_Name__c).DeveloperName);
    //             return ;
    //         }
    //     }
        
    //     // 3.2 Branch and Zone Queue/User field
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)){
    //         if(queueMap.containsKey(String.valueOf(branchCodeMap.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)))){
    //             leadObj.ownerId = queueMap.get(String.valueOf(branchCodeMap.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c))).Id;
    //             System.debug(queueMap.get(String.valueOf(branchCodeMap.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c))).DeveloperName);
    //             return ;
    //         }
            
    //         try{
    //             if(userMap.containsKey(String.valueOf(branchCodeMap.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)))){
    //                 User u = userMap.get(String.valueOf(branchCodeMap.get(leadObj.RTL_Branch_Name__c).get(LeadMatchAssignmentRule.RTL_Branch_and_Zone_Queue_User_field__c)));
    //                 if(u != null && u.IsActive){
    //                     leadObj.ownerId = u.Id;
    //                     System.debug(userMap.get(leadObj.ownerId).Name);
    //                     return ;
    //                 }
    //             }
    //         }catch(Exception e) {
    //             System.debug(e.getMessage());
    //         }
    //     }
        
    //     // 4.1 Default Queue Name
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c)){
    //         if(queueMap.containsKey(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c)){
    //             leadObj.ownerId = queueMap.get(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c).Id;
    //             System.debug(queueMap.get(LeadMatchAssignmentRule.RTL_Default_Queue_Name__c).DeveloperName);
    //             return ;
    //         }
    //     }
        
    //     // 4.2 Default User
    //     if(RTL_Utility.isNotNull(LeadMatchAssignmentRule.RTL_Default_User__c)){
    //         if(userMap.containsKey(LeadMatchAssignmentRule.RTL_Default_User__c) && userMap.get(LeadMatchAssignmentRule.RTL_Default_User__c).IsActive){
    //             leadObj.ownerId = LeadMatchAssignmentRule.RTL_Default_User__c;
    //             System.debug(userMap.get(leadObj.ownerId).Name);
    //             return ;
    //         }
    //     }

    //     // System defult to tmb admin
    //     // leadObj.ownerId = tmbAdmin.id;
    // }

    private static void sendToCallMeNowServiceCisco(List<Lead> leadLst){
        System.debug('sendToCallMeNowServiceCisco :::::');
        System.debug('leadLst : ' + leadLst);

        Map<Id, Lead> leadIdSet = new Map<Id, Lead>(leadLst);

        if(leadIdSet.size() > 0){
            CallMeNowLeadBatch bat = new CallMeNowLeadBatch(leadIdSet.keySet());
            DataBase.executeBatch(bat, 100);
        }
    }

    // private static void sendToCallMeNowServiceAvaya(List<Lead> leadLst){
    //     System.debug('sendToCallMeNowServiceAvaya :::::');
    //     System.debug('leadLst : ' + leadLst);

    //     Map<Id, Lead> leadIdSet = new Map<Id, Lead>(leadLst);

    //     if(leadIdSet.size() > 0){
    //         //avayaCallListLeadBatch bat = new avayaCallListLeadBatch(leadIdSet.keySet());
    //         //DataBase.executeBatch(bat, 100);
    //     }
    // }


      /* end private methods */
    //====================================================================

     // exception class
    public class LeadTriggerHandlerException extends Exception {} 

}