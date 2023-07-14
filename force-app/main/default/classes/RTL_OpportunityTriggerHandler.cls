public without sharing class RTL_OpportunityTriggerHandler extends TriggerHandler {
    /*------------------------------------------------------------------------
    Author:        Debi Prasad Baral
    Company:       Salesforce
    Description:   A class created to manage trigger actions from the Opportunity object
                   Responsible for:
                   1 - Inserting referral history record when a new oppertunity is created
                   2 - Creating new referral history records when the owner of the opportunity changed and
                   the channel is different than the original channel
    History
    <Date>            <Authors Name>    <Brief Description of Change>
    --------------------------------------------------------------------------*/
        ///////////////////////////////////////////////////////////
        // ------------------------------------------------------------------------------
        // Transection No. : CH01
        // Author : Nuchanard S.
        // Date : 2018.03.12
        // Description : auto create order
        // ------------------------------------------------------------------------------
        // Author : Nootchaba T.
        // Date : 2018.03.09
        // Description : auto create campaign member
        // ------------------------------------------------------------------------------
        ///////////////////////////////////////////////////////////
    
        Set<id> opportunityId = new Set<id>(); // Set of Opportunity Ids
        static List<CampaignMember> newMember = new List<CampaignMember>();
    
        public RTL_OpportunityTriggerHandler(){
            if(Test.isRunningTest()){
                this.setMaxLoopCount(10);
            }
            else{
                this.setMaxLoopCount(200);
            }
    
            System.Debug( 'TMB: -> OpportunityTriggerHandler Invoked' );
        }
    
        protected override void beforeInsert(List<SObject> oppsNew) {
            List<Opportunity> retailNewList = getRetailList(oppsNew);
            if(retailNewList.size() > 0){
                addOpptInfo(retailNewList);
                defaultOppName(retailNewList);
    
                getCampaignOrNBOToOpportunity(retailNewList);
    
                //Retail Phase2 Create Opp link to Mass Campaign generate Campaign Member.
                linkToMassCampaign(retailNewList);
    
                updateOpptyByReferral(retailNewList);
                updateOpptyByCampaignMember(retailNewList);
            }
    
        }
    
        protected override void afterInsert(map<id,sObject> newMap) {
            Map<Id,sObject> retailNewMap = getRetailMap(newMap);
            if(retailNewMap.size() > 0){
                //insertChannelReferralRecords(newMap);
                insertOppAutoOrder(newMap); //MF by Phone auto create Order
    
                //create campaign member after create opportunity with mass campaign
                createMemberOnMassCampaign(retailNewMap.values());
                updateOpptyToCampaignMember(retailNewMap.values());
            }
    
        }
    
        protected override void beforeUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
            Map<Id,sObject> retailOldMap = getRetailMap(oldMap);
            Map<Id,sObject> retailNewMap = getRetailMap(newMap);
            if(retailOldMap.size() > 0){
                updateOpptInfo(retailOldMap, retailNewMap);
            }
    
        }
        protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {       
            System.debug('After Update oppty Id :'+newMap.keySet());
            Map<Id,sObject> retailOldMap = getRetailMap(oldMap);
            Map<Id,sObject> retailNewMap = getRetailMap(newMap);
            System.debug('retailOldMap:'+retailOldMap);
            System.debug('retailNewMap:'+retailNewMap);
            if(retailOldMap.size() > 0){
                afterUpdateOpportunitytoCampaignMember(retailOldMap, retailNewMap);
            }
            /* System.debug('Opportunity afterupdate start -----');
            afterUpdateOpportunitytoCampaignMember(oldMap,newMap); */
        }
    
        public static void afterUpdateOpportunitytoCampaignMember(map<id,sObject> oldMap, map<id,sObject> newMap) {
        List<CampaignMember> cmlist =  [SELECT id,RTL_Contact_Status__c,RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c FROM CampaignMember WHERE RTL_RelatedOpportunity_1__c IN: newMap.keySet() OR RTL_RelatedOpportunity_2__c IN: newMap.keySet() OR RTL_RelatedOpportunity_3__c IN: newMap.keySet() OR RTL_RelatedOpportunity_4__c IN: newMap.keySet() OR RTL_RelatedOpportunity_5__c IN: newMap.keySet()];
        //List<CampaignMember> cmlist1 = [SELECT id,RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c FROM CampaignMember];
        system.debug('CMOpp size' + cmlist.size());
        //system.debug('testsize1' + cmlist1.size());
        Set<Id> opptyId = newMap.keySet();
        Set<Id> opptyCampaignId = new Set<Id>();
        Set<Id> opptyCrossSellId = new Set<Id>();
        System.debug('cmop:'+cmlist);
        System.debug('opid:'+newMap.keySet());
        for(CampaignMember each : cmlist){
            if(each.RTL_RelatedOpportunity_1__c != null && newMap.containsKey(each.RTL_RelatedOpportunity_1__c)){
                each.RTL_Stage_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('StageName'));
                each.RTL_Status_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Status__c'));
                each.Details_of_Status_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('HPAP_Reason_Description__c'));
               
                each.RTL_Status_Approve_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Status_Approve__c'));
                each.RTL_Submit_Date_1__c = Date.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Submit_Date__c'));
                each.RTL_Refer_Date_1__c = Datetime.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Refer_Date__c'));
                if(each.RTL_Contact_Status__c == 'New' || each.RTL_Contact_Status__c == 'Uncontact'){
                    each.RTL_Contact_Status__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Contact_Status__c'));
                    each.RTL_Reason__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Ws_Reason__c'));
                }
                each.Corebank_Branch_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Branch_Code__c'));
                each.Corebank_Branch_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Branch_Name__c'));
                each.Corebank_Sales_Manager_Head_Id_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Sales_Manager_Head_Id__c'));
                each.Corebank_Sales_Manager_Head_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Sales_Manager_Head__c'));
                each.RTL_Request_Hub_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Request_Hub_Code__c'));
                each.RTL_Request_Hub_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Request_Hub_Name__c'));
                each.Corebank_Approved_Date_Time_1__c = Datetime.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('Corebank_Approved_Date_Time__c'));
                each.RTL_Product_Campaign_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Product_Campaign_Code__c'));
                each.RTL_Product_Campaign_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Product_Campaign_Name__c'));
                each.RTL_Dealer_Code_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Dealer_Code__c'));
                each.RTL_Dealer_Name_1__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Dealer_Name__c'));
                each.RTL_Stage_Name_Date_Time_1__c = Datetime.valueOf(newMap.get(each.RTL_RelatedOpportunity_1__c).get('RTL_Stage_Name_Date_Time__c'));
      
                each.RTL_isBatchUpdateCampaignMember__c = true; 
                opptyCampaignId.add(each.RTL_RelatedOpportunity_1__c);
            }
            if(each.RTL_RelatedOpportunity_2__c != null && newMap.containsKey(each.RTL_RelatedOpportunity_2__c)){
                each.RTL_Stage_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('StageName'));
                each.RTL_Status_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_Status__c'));
                each.Details_of_Status_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_2__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_2__c).get('HPAP_Reason_Description__c'));
                each.RTL_isBatchUpdateCampaignMember__c = true; 
                opptyCampaignId.add(each.RTL_RelatedOpportunity_2__c);
            }
            if(each.RTL_RelatedOpportunity_3__c != null && newMap.containsKey(each.RTL_RelatedOpportunity_3__c)){
                each.RTL_Stage_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('StageName'));
                each.RTL_Status_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_Status__c'));
                each.Details_of_Status_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_3__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_3__c).get('HPAP_Reason_Description__c'));
                each.RTL_isBatchUpdateCampaignMember__c = true; 
                opptyCampaignId.add(each.RTL_RelatedOpportunity_3__c);
            }
            if(each.RTL_RelatedOpportunity_4__c != null && newMap.containsKey(each.RTL_RelatedOpportunity_4__c)){
                each.RTL_Stage_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('StageName'));
                each.RTL_Status_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_Status__c'));
                each.Details_of_Status_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_4__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_4__c).get('HPAP_Reason_Description__c'));
                each.RTL_isBatchUpdateCampaignMember__c = true; 
                opptyCampaignId.add(each.RTL_RelatedOpportunity_4__c);
            }
            if(each.RTL_RelatedOpportunity_5__c != null && newMap.containsKey(each.RTL_RelatedOpportunity_5__c)){
                each.RTL_Stage_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('StageName'));
                each.RTL_Status_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_Status__c'));
                each.Details_of_Status_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('Details_of_Status__c'));
                each.RTL_AL_Refer_No_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_AL_Refer_No__c'));
                each.RTL_AL_Req_No1_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_AL_Req_No1__c'));
                each.RTL_AL_Req_No2_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_AL_Req_No2__c'));
                each.Corebank_Emp_Id_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('Corebank_Emp_Id__c'));
                each.Corebank_Emp_Name_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('Corebank_Emp_Name__c'));
                each.Corebank_Emp_Phone_No_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('Corebank_Emp_Phone_No__c'));
                each.RTL_Hub_Code_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_Hub_Code__c'));
                each.RTL_Hub_Name_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_Hub_Name__c'));
                each.RTL_Account_No_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('RTL_Account_No__c'));
                each.HPAP_Status_Code_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('HPAP_Status_Code__c'));
                each.HPAP_Reason_Code_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('HPAP_Reason_Code__c'));
                each.HPAP_Reason_Description_5__c = String.valueOf(newMap.get(each.RTL_RelatedOpportunity_5__c).get('HPAP_Reason_Description__c'));
                each.RTL_isBatchUpdateCampaignMember__c = true; 
                opptyCampaignId.add(each.RTL_RelatedOpportunity_5__c);
            }
         }
         
        for(Id Id : opptyId){
            if(!opptyCampaignId.contains(Id)){
                opptyCrossSellId.add(Id);
            }
        }
        List<Cross_Sell_Product__c> crossSelllist = [SELECT Id,OpportunityId__c FROM Cross_Sell_Product__c WHERE OpportunityId__c IN: opptyCrossSellId AND OpportunityId__c != null];
    
        for(Cross_Sell_Product__c each : crossSelllist){
                    each.RTL_Stage__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Stage__c'));
                    each.RTL_Status__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Status__c'));
                    each.Details_of_Status__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Details_of_Status__c'));
                    each.RTL_AL_Refer_No__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_AL_Refer_No__c'));
                    each.RTL_AL_Req_No1__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_AL_Req_No1__c'));
                    each.RTL_AL_Req_No2__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_AL_Req_No2__c'));
                    each.Corebank_Emp_Id__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Emp_Id__c'));
                    each.Corebank_Emp_Name__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Emp_Name__c'));
                    each.Corebank_Emp_Phone_No__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Emp_Phone_No__c'));
                    each.RTL_Hub_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Hub_Code__c'));
                    each.RTL_Hub_Name__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Hub_Name__c'));
                    each.RTL_Account_No__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Account_No__c'));
                    each.HPAP_Status_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('HPAP_Status_Code__c'));
                    each.HPAP_Reason_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('HPAP_Reason_Code__c'));
                    each.HPAP_Reason_Description__c = String.valueOf(newMap.get(each.OpportunityId__c).get('HPAP_Reason_Description__c'));
                    
                    each.RTL_Refer_Date__c = Datetime.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Refer_Date__c'));
                    each.Corebank_Branch_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Branch_Code__c'));
                    each.Corebank_Branch_Name__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Branch_Name__c'));
                    each.Corebank_Sales_Manager_Head_Id__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Sales_Manager_Head_Id__c'));
                    each.Corebank_Sales_Manager_Head__c = String.valueOf(newMap.get(each.OpportunityId__c).get('Corebank_Sales_Manager_Head__c'));
                    each.RTL_Product_Campaign_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Product_Campaign_Code__c'));
                    each.RTL_Product_Campaign_Name__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Product_Campaign_Name__c'));
                    each.RTL_Dealer_Code__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Dealer_Code__c'));
                    each.RTL_Dealer_Name__c = String.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Dealer_Name__c'));
                    each.RTL_Stage_Name_Date_Time__c = Datetime.valueOf(newMap.get(each.OpportunityId__c).get('RTL_Stage_Name_Date_Time__c'));
        }
    
        if(cmlist.size() > 0){
            //update cmlist;
            try{
                update cmlist;
            }catch (DmlException e){
                System.debug('Error afterUpdateOpportunitytoCampaignMember :' + e); 
            }
            
        }
        if(crossSelllist.size() > 0 ){
            update crossSelllist;
        }
        
        }
    
            
        /*protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {
            //List of channel records to be inserted
            List<RTL_Channel_Referral__c> channelReferralsToInsert = new List<RTL_Channel_Referral__c>();
            //List of channel records to be updated
            List<RTL_Channel_Referral__c> channelReferralsToUpdate = new List<RTL_Channel_Referral__c>();
    
            //Store old and new opportunity owners to map to user object
            Set<Id> opptOwnerIds = new Set<Id>();
            for (Id lId:oldMap.keySet()) opptOwnerIds.add(((opportunity)oldMap.get(lId)).OwnerId);
            for (Id lId:newMap.keySet()) opptOwnerIds.add(((opportunity)newMap.get(lId)).OwnerId);
            //Keep the list of the opportunity owner as users
            Map<Id, User> userMap = new Map<Id, User>();
            for(User u: [Select Id, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c from User where id in :opptOwnerIds])
                userMap.put(u.Id, u);
    
            for (Id oppId:newMap.keySet()){
                Opportunity newOppObj = (opportunity)newMap.get(oppId);
                Opportunity oldOppObj = (opportunity)oldMap.get(oppId);
    
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(newOppObj.RecordTypeId)) {//only continue if it's retail record type
                    //get old and new user channel details for comparision
                    User oldUser = userMap.get(oldOppObj.OwnerId);
                    User newUser = userMap.get(newOppObj.OwnerId);
                    if (oldOppObj.OwnerId != newOppObj.OwnerId &&
                        oldUser.RTL_Channel__c != newUser.RTL_Channel__c)
                    {
                        //Create New Channel Referral record and then associate with the opportunity
                        channelReferralsToInsert.add(new RTL_Channel_Referral__c ( RTL_Branch_Code__c = newUser.RTL_Branch_Code__c,
                        RTL_Opportunity__c = newOppObj.Id,
                        RTL_Start_Date__c =DateTime.now(),
                        RTL_Owner__c = newUser.Id,
                        RTL_Previous_Owner__c = oldUser.Id,
                        RTL_Last_Entry__c = true,
                        Name = newUser.RTL_Channel__c));
    
    
                    }
    
                    if ((oldOppObj.OwnerId != newOppObj.OwnerId && oldUser.RTL_Channel__c != newUser.RTL_Channel__c) ||
                         newOppObj.StageName.contains('Closed'))
                        {
                            //Get the associated Channel Referral record with blank end date and update the
                            //channel referral record with end date as current datetime
    
                            //Comment out to fix issue #6578 Time based WF(Error101)
                            /*List<RTL_Channel_Referral__c> channelReferralToUpdate =
                                                [SELECT Id, RTL_End_Date__c FROM RTL_Channel_Referral__c
                                                  WHERE RTL_End_Date__c = : null and RTL_Opportunity__c = : newOppObj.Id limit 1];
    
                            if(channelReferralToUpdate.size() > 0 ){
                                channelReferralToUpdate[0].RTL_End_Date__c = DateTime.now();
                                channelReferralToUpdate[0].RTL_Last_Entry__c = false;
                                if(newOppObj.StageName.contains('Closed')){
                                    channelReferralToUpdate[0].RTL_Last_Entry__c = true;
                                }
                                channelReferralsToUpdate.add(channelReferralToUpdate[0]);
                            }
    
                        }
                }
            }
    
            if(channelReferralsToInsert.size() > 0){
                // Insert the channel referral records
                Database.SaveResult[] lsr = Database.insert(channelReferralsToInsert, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted opportunity channel referrals.');
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(logginglevel.ERROR, 'There is error inserting opportunity channel referrals. Error Message is: ' + err.getMessage());
                        }
                    }
                }
            }
    
            if(channelReferralsToUpdate.size() > 0){
                // Update the channel referral records
                Database.SaveResult[] lsr = Database.update(channelReferralsToUpdate, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated opportunity channel referrals.');
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(logginglevel.ERROR, 'There is error updating opportunity channel referrals. Error Message is: ' + err.getMessage());
                        }
                    }
                }
            }
    
            System.Debug('TMB: -> OpportunityTriggerHandler end of afterUpdate');
        }*/
    
        //====================================================================
    
        /* private methods */
        //====================================================================
        /**
         * @desc This method would insert the first channel referral history record for each opportunity
         * @param [map<id,sObject> newMap]
         */
        /*
        private void insertChannelReferralRecords(map<id,sObject> newMap){
            System.Debug('TMB: -> OpportunityTriggerHandler start of afterInsert for channel referral' + opportunityId.size());
            // Create a set of OpportunityId
            opportunityId.addAll(newMap.keySet());
            //List of channel records to be inserted
            List<RTL_Channel_Referral__c> channelReferralsToInsert = new List<RTL_Channel_Referral__c>();
    
             //Store new opportunity owners to map to user object
            Set<Id> opptOwnerIds = new Set<Id>();
            for (Id lId:newMap.keySet()) opptOwnerIds.add(((opportunity)newMap.get(lId)).OwnerId);
            //Keep the list of the opportunity owner as users
            Map<Id, User> userMap = new Map<Id, User>();
            for(User u: [Select Id, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c from User where id in :opptOwnerIds])
                userMap.put(u.Id, u);
    
            for (Id oppId:newMap.keySet()){
                Opportunity oppObj = (opportunity)newMap.get(oppId);
    
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(oppObj.RecordTypeId)) {//only continue if it's retail record type
                    //Get the owner details to populate referral history record
                    User user = userMap.get(oppObj.OwnerId);
    
                   //Create New Channel Referral record and then associate with the opportunity
                    channelReferralsToInsert.add(new RTL_Channel_Referral__c ( RTL_Branch_Code__c = user.RTL_Branch_Code__c,
                        RTL_Opportunity__c = oppObj.Id,
                        RTL_Start_Date__c =DateTime.now(),
                        RTL_Owner__c = user.Id,
                        Name = user.RTL_Channel__c,
                        RTL_First_Entry__c = true));//only set the 1st channel referral to true
                }
            }
    
            if(channelReferralsToInsert.size() > 0){
                // Insert the channel referral records
                Database.SaveResult[] lsr = Database.insert(channelReferralsToInsert, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted opportunity channel referrals.');
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(logginglevel.ERROR, 'There is error inserting opportunity channel referrals. Error Message is: ' + err.getMessage());
                        }
                    }
                }
            }
    
            System.Debug('TMB: -> OpportunityTriggerHandler end of afterInsert');
        }
    /*--------- START CH01 --------------*/
        private void insertOppAutoOrder(map<id,sObject> newMap){
            List<Order> listAutoCreateOrder = new List<Order>();
            Id retailOrderRecordTypeId = Schema.Sobjecttype.Order.getRecordTypeInfosByName().get('Retail Investment Order').getRecordTypeId();
    
            for (Id oppId:newMap.keySet()){
                Opportunity oppObj = (opportunity)newMap.get(oppId);
                Order autoCreateOrder = new Order();
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail Investment').contains(oppObj.RecordTypeId)) {//only continue if it's retail record type
                    //auto create order if attach to 'Retail Order Transaction' referral
                    if(oppObj.Referral_Record_Type__c == 'Retail Order Transaction'
                        || oppObj.Referral_Record_Type__c == 'Closed Retail Order Transaction'){
                        autoCreateOrder.RTL_Unit_Holder_No__c = oppObj.RTL_Unit_Holder_No__c;
                        autoCreateOrder.RTL_License_No__c = oppObj.RTL_License_No__c;
                        autoCreateOrder.RTL_Product_Switch_Out__c = oppObj.RTL_Product_Switch_Out__c;
                        autoCreateOrder.RTL_Product_Name__c = oppObj.RTL_Product_Name__c;
                        autoCreateOrder.RTL_Unit__c = oppObj.RTL_Unit__c;
                        autoCreateOrder.RTL_Debit_Account_Type__c = oppObj.RTL_Debit_Account_Type__c;
                        autoCreateOrder.RTL_Debit_Account_No__c = oppObj.RTL_Debit_Account_No__c;
                        autoCreateOrder.RTL_Referral__c = oppObj.RTL_Referral__c;
                        autoCreateOrder.OpportunityId = oppObj.Id;
                        autoCreateOrder.AccountId = oppObj.AccountId;
                        autoCreateOrder.EffectiveDate = System.today();
                        autoCreateOrder.RTL_Type__c = oppObj.RTL_Type__c;
                        autoCreateOrder.RTL_No_of_Unit__c = oppObj.RTL_No_of_Unit__c;
                        autoCreateOrder.Status = 'New';
                        autoCreateOrder.RTL_Amount__c = oppObj.Amount;
                        autoCreateOrder.RecordTypeId = retailOrderRecordTypeId;
                        //autoCreateOrder.RTL_Credit_Account_No__c = oppObj.RTL_Credit_Account_No__c;
    
                        listAutoCreateOrder.add(autoCreateOrder);
                    }
                }
    
            }
            if(listAutoCreateOrder.size() > 0){
                // Insert the channel referral records
                Database.SaveResult[] lsr = Database.insert(listAutoCreateOrder, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted opportunity auto create Order.');
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(logginglevel.ERROR, 'There is error inserting opportunity auto create Order. Error Message is: ' + err.getMessage());
                        }
                    }
                }
            }
        }
    /*--------- END CH01 --------------*/
        /**
        * This method is to default opportunity name before insertion -- CR default Opportunity Name
        */
    
        private static void defaultOppName (List<Opportunity> oppsNew){
            List<Opportunity> oppTodefaultName = new List<Opportunity>();
            for (Opportunity newOppObj: oppsNew) {
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(newOppObj.RecordTypeId)){
                    //Let Trigger Overwrite OppName only Opportunity which are not from NBO
                    if(newOppObj.RTL_Related_to_NBO_History__c == false){
                        oppTodefaultName.add(newOppObj);
                    }
                }
            }
            
            RTL_OpportunityService.defaultOpportunityName(oppTodefaultName);
    
            for(Opportunity newOppObj: oppsNew){
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(newOppObj.RecordTypeId)){
                    //Let Trigger Overwrite OppName only Opportunity which are not from NBO
                    if(newOppObj.CampaignId != null && newOppObj.RTL_Is_Create_From_Campaign_Member__c){
                        newOppObj.name += ' (CMP)';
                    }
                }
            }
        }
    
        /**
        * This method is to add additional opportunity information before insertion
        */
        private static void addOpptInfo (List<Opportunity> oppsNew) {
            //Store opportunity owners to map to user object
            Set<Id> opptOwnerIds = new Set<Id>();
            for (Opportunity newOppObj: oppsNew) opptOwnerIds.add(newOppObj.OwnerId);
    
            //Keep the list of the opportunity owner as users
            Map<Id, User> ownerMap = new Map<Id, User>();
            Set<String> ownerBranchCodeMap = new Set<String>();
            for(User u: [Select Id, RTL_Branch__c, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c from User where id in :opptOwnerIds]) {
                ownerMap.put(u.Id, u);
                ownerBranchCodeMap.add(u.RTL_Branch_Code__c);
            }
            
            //Keep the owner's branch_and_zone list in map
            Map<String, Id> ownerBranchCodeIdMap = new Map<String, Id>();
            for(Branch_and_Zone__c branchzone : [Select Id, Branch_Code__c from Branch_and_Zone__c where Branch_Code__c in :ownerBranchCodeMap]) {
                ownerBranchCodeIdMap.put(branchzone.Branch_Code__c, branchzone.Id);
            }            
            
            for (Opportunity newOppObj: oppsNew){
                newOppObj.RTL_Branch_Team_Name_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).RTL_Branch__c;
                newOppObj.RTL_Branch_Code_Rpt__c = ownerBranchCodeIdMap.get(ownerMap.get(newOppObj.OwnerId).RTL_Branch_Code__c);
                newOppObj.RTL_Region_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).Region_Code__c;
                newOppObj.RTL_Zone_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).Zone_Code__c;
                newOppObj.RTL_Oppt_Channel__c = ownerMap.get(newOppObj.OwnerId).RTL_Channel__c;
            }
        }
        
        /**
        * This method is to update additional opportunity information before update
        */
        private static void updateOpptInfo(map<id,SObject> oldMap, map<id,SObject> newMap){
            //Store old and new opportunity owners to map to user object
            Set<Id> opptOwnerIds = new Set<Id>();
            for (Id lId:oldMap.keySet()) opptOwnerIds.add(((opportunity)oldMap.get(lId)).OwnerId);
            for (Id lId:newMap.keySet()) opptOwnerIds.add(((opportunity)newMap.get(lId)).OwnerId);
    
            //Keep the list of the opportunity owner as users
            Map<Id, User> ownerMap = new Map<Id, User>();
            Set<String> ownerBranchCodeMap = new Set<String>();
            for(User u: [Select Id, RTL_Branch__c, RTL_Branch_Code__c, Region_Code__c, Zone_Code__c, RTL_Channel__c from User where id in :opptOwnerIds]) {
                ownerMap.put(u.Id, u);
                ownerBranchCodeMap.add(u.RTL_Branch_Code__c);
            }
            
            //Keep the owner's branch_and_zone list in map
            Map<String, Id> ownerBranchCodeIdMap = new Map<String, Id>();
            for(Branch_and_Zone__c branchzone : [Select Id, Branch_Code__c from Branch_and_Zone__c where Branch_Code__c in :ownerBranchCodeMap]) {
                ownerBranchCodeIdMap.put(branchzone.Branch_Code__c, branchzone.Id);
            }   
              
            for (Id oppId:newMap.keySet()){
                Opportunity oldOppObj = (opportunity)oldMap.get(oppId);
                Opportunity newOppObj = (opportunity)newMap.get(oppId);
                if (oldOppObj.OwnerId != newOppObj.OwnerId) {
                    newOppObj.RTL_Branch_Team_Name_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).RTL_Branch__c;
                    newOppObj.RTL_Branch_Code_Rpt__c = ownerBranchCodeIdMap.get(ownerMap.get(newOppObj.OwnerId).RTL_Branch_Code__c);
                    newOppObj.RTL_Region_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).Region_Code__c;
                    newOppObj.RTL_Zone_Code_Rpt__c = ownerMap.get(newOppObj.OwnerId).Zone_Code__c;
                    newOppObj.RTL_Oppt_Channel__c = ownerMap.get(newOppObj.OwnerId).RTL_Channel__c;
                }
            }       
        }
        
        private static Map<Id,sObject> getRetailMap(Map<Id,sObject> oppMap){
            Map<Id,sObject> retailOppMap = new Map<Id,sObject>();
            for(Id oppId : oppMap.keySet()){
                Opportunity oppObj = (Opportunity)oppMap.get(oppId);
                if(RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(oppObj.RecordTypeId)){
                    retailOppMap.put(oppId,oppObj);
                }
            }
            return retailOppMap;
        }
        
        private static List<sObject> getRetailList(List<Opportunity> oppList){
            List<Opportunity> retailOppList = new List<sObject>();
            for(Opportunity oppObj : oppList){
                if(RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Opportunity.SObjectType, 'Retail').contains(oppObj.RecordTypeId)){
                    retailOppList.add(oppObj);
                }  
            }
            return retailOppList;
        }
    
    
        /**
        * This method is to stamp campaign or nbo before insertion
        */
        private static void getCampaignOrNBOToOpportunity (List<Opportunity> oppsNew) {
            Set<Id> campaignIds = new Set<Id>();
            Set<Id> nboIds = new Set<Id>();
            Set<String> tmbCusSet = new Set<String>();
            Map<String,RTL_NBO_History__c> tmbCuswithCampaign = new Map<String,RTL_NBO_History__c>();
            Map<String,RTL_NBO_History__c> tmbCuswithNBO = new Map<String,RTL_NBO_History__c>();
    
            for(Opportunity newOppObj: oppsNew){
                //Set Campaign id
                if(newOppObj.Campaignid != null){
                    campaignIds.add(newOppObj.Campaignid);
                }
                //Set NBO id
                if(newOppObj.RTL_Related_NBO_History__c != null){
                    nboIds.add(newOppObj.RTL_Related_NBO_History__c);
                }
    
                //Set TMB Cus
                if(newOppObj.RTL_TMB_Customer_ID_PE__c != null){
                    tmbCusSet.add(newOppObj.RTL_TMB_Customer_ID_PE__c);
                }
            }
    
            //Query nboId from campaignId
            if(campaignIds.size() > 0){
                for(RTL_NBO_History__c nbo : [Select Id,RTL_Campaign__c,RTL_TMB_Customer_ID_PE__c from RTL_NBO_History__c 
                                            where RTL_Campaign__c in :campaignIds and RTL_TMB_Customer_ID_PE__c in :tmbCusSet]) {
                    if(nbo.RTL_Campaign__c != null && nbo.RTL_TMB_Customer_ID_PE__c != null){
                        tmbCuswithCampaign.put(nbo.RTL_TMB_Customer_ID_PE__c,nbo);
                    }
                } 
            }
    
            //Query campaignId from nboId
            if(nboIds.size() > 0){
                for(RTL_NBO_History__c nbo : [Select Id,RTL_Campaign__c,RTL_TMB_Customer_ID_PE__c from RTL_NBO_History__c 
                                            where id in :nboIds and RTL_TMB_Customer_ID_PE__c in :tmbCusSet]) {
                    if(nbo.id != null && nbo.RTL_TMB_Customer_ID_PE__c != null){
                        tmbCuswithNBO.put(nbo.RTL_TMB_Customer_ID_PE__c,nbo);
                    }
                } 
            }
    
            for(Opportunity newOppObj: oppsNew){
    
                //check campaign is null,set campaign id => create from NBO
                if(newOppObj.RTL_Related_NBO_History__c != null && newOppObj.Campaignid == null){
    
                    RTL_NBO_History__c nborow = tmbCuswithNBO.get(newOppObj.RTL_TMB_Customer_ID_PE__c);
                    if(nborow.RTL_Campaign__c != null){
                        newOppObj.Campaignid = nborow.RTL_Campaign__c;
                        newOppObj.RTL_Is_Create_From_Campaign_Member__c = true;
                    }
                }
    
                //check nbo is null,set NBO id and check related nbo => create from campaign member
                if(newOppObj.Campaignid != null && newOppObj.RTL_Related_NBO_History__c == null){
                    RTL_NBO_History__c nborow = tmbCuswithCampaign.get(newOppObj.RTL_TMB_Customer_ID_PE__c);
                    if(nborow != null){
                        newOppObj.RTL_Related_NBO_History__c = nborow.id;
                        newOppObj.RTL_Related_to_NBO_History__c = true;
                        newOppObj.RTL_Is_Create_From_Campaign_Member__c = true;
                    }
                }
    
            }
        }
    
        /**
        * This method is to create opportunity and link to mass campaign before insertion
        */
        private static void linkToMassCampaign (List<Opportunity> oppsNew) {
           
    
            System.Debug('TMB: -> OpportunityTriggerHandler start of beforeInsert for new opp link to Mass Campaign.');  
    
            Set<Id> campaignIdSet = new Set<Id>();
            Set<Id> oppProductIdSet = new Set<Id>();
            Map<Id,Opportunity> newOpportunity = new Map<Id,Opportunity>();
            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Map<Id,RTL_product_master__c> mapProductName = new Map<Id,RTL_product_master__c>();
            Map<Id,Retail_Campaign_Products__c> mapCampaignProductName = new Map<Id,Retail_Campaign_Products__c>();
    
            for (Opportunity newOppObj: oppsNew) {
                if(newOppObj.CampaignId != null){
                    campaignIdSet.add(newOppObj.CampaignId);
                }
    
                oppProductIdSet.add(newOppObj.RTL_Product_Name__c);
                newOpportunity.put(newOppObj.id,newOppObj);
    
            }
    
            //Opportunity create with campaign
            if(campaignIdSet.size() > 0){
    
                //Get RecordType Child Mass Campaign active
                Map<Id, Recordtype> campaignRecordType = new Map<Id, RecordType>([SELECT ID, Name, DeveloperName 
                                                                                FROM Recordtype 
                                                                                WHERE sObjectType = 'Campaign'
                                                                                AND DeveloperName LIKE '%Mass%']);
    
                //Get Mass campaign in Primary Campaign Source
                for(Campaign c :[SELECT Id,name
                        FROM Campaign 
                        where IsActive = true 
                        and id in: campaignIdSet
                        and RecordTypeid in:campaignRecordType.values()]){
                    mapCampaign.put(c.id, c);
                }
    
                //founf mass campaign
                if(mapCampaign.size() > 0){
    
    
                    for(RTL_product_master__c p :[select id,name,Product_Sub_group__c,Product_Group__c from RTL_product_master__c where id in: oppProductIdSet]){
                        mapProductName.put(p.id, p);
                    }
    
    
                    for(Retail_Campaign_Products__c cp :[Select RTL_Campaign__c, 
                                                        RTL_Retail_Product_Master__c, 
                                                        RTL_Product_Group__c, 
                                                        RTL_Sub_Group__c, 
                                                        Id, Name 
                                                        FROM Retail_Campaign_Products__c 
                                                        where RTL_Campaign__c in: mapCampaign.keySet()]){
                        mapCampaignProductName.put(cp.id, cp);
                    }
    
    
                    /*system.debug('Opportunity : newOpportunity'+newOpportunity);
                    system.debug('Opportunity : mapContact'+mapContact);
                    system.debug('Opportunity : mapCampaign'+mapCampaign);
                    system.debug('Opportunity : mapUser'+mapUser);
                    system.debug('Opportunity : mapProductName'+mapProductName);
                    system.debug('Opportunity : mapCampaignProductName'+mapCampaignProductName);*/
    system.debug('opp mapCampaignProductName ----->' + mapCampaignProductName);
                    Boolean createCampaignMember = false;
                    string errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR001;
    
                    for(Opportunity opp : newOpportunity.values()){
    
                        RTL_product_master__c product = new RTL_product_master__c();
                        product = mapProductName.get(opp.RTL_Product_Name__c);
    system.debug('opp product ----->' + product);
                        //found product on mass campaign
                        if(mapCampaignProductName.size()>0 && mapProductName.size() > 0 && product!=null){
    
                            //check product on opp matching campaign product
                            Boolean isSelectedProductCampaign = checkSelectedProductinCampaign(mapCampaignProductName,product);
                            system.debug('Opportunity : isSelectedProductCampaign '+isSelectedProductCampaign);
    
                            if(isSelectedProductCampaign){
                                createCampaignMember = true;
                                opp.RTL_Is_Create_From_Campaign_Member__c = true;
                            }else{
                                createCampaignMember = false;
                                errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR003;
                                break;
                            }
    
                        }else if(mapProductName.size() > 0 && product!=null){ //Not found product on Mass campaign
                            createCampaignMember = true;
                            opp.RTL_Is_Create_From_Campaign_Member__c = true;
                        }else{
                            createCampaignMember = false;
                            errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR001;
                            break;
                        }
    system.debug('opp in ----->' + opp);
                    }//end loop
    
    
                    //Error message
                    for (Opportunity newOppObj: oppsNew){
                        if(!createCampaignMember){
                            newOppObj.addError(errorMessage); 
                        }   
                    }
                }
            }
            
            System.Debug('TMB: -> OpportunityTriggerHandler end of beforeInsert for new opp link to Mass Campaign.');  
            
    
        }
    
        private static void createMemberOnMassCampaign (List<Opportunity> oppsNew) {
            System.Debug('TMB: -> OpportunityTriggerHandler start of afterInsert for new opp link to Mass Campaign.');  
    
            Set<Id> campaignIdSet = new Set<Id>();
            Set<Id> opptOwnerIds = new Set<Id>();
            Set<Id> accIds = new Set<Id>();
            Set<Id> oppProductIdSet = new Set<Id>();
            Map<Id,Opportunity> newOpportunity = new Map<Id,Opportunity>();
            Map<String,Contact> mapContact = new Map<String,Contact>();
            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Map<Id,User> mapUser = new Map<Id,User>();
            Map<Id,RTL_product_master__c> mapProductName = new Map<Id,RTL_product_master__c>();
            string errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR001;
            Boolean createCampaignMember = false;
            Savepoint sp = Database.setSavepoint(); 
    
            for (Opportunity newOppObj: oppsNew) {
                if(newOppObj.CampaignId != null && newOppObj.RTL_Is_Create_From_Campaign_Member__c){
                    campaignIdSet.add(newOppObj.CampaignId);
                }
    
                opptOwnerIds.add(newOppObj.OwnerId);
                accIds.add(newOppObj.AccountId);
                oppProductIdSet.add(newOppObj.RTL_Product_Name__c);
                newOpportunity.put(newOppObj.id,newOppObj);
    
            }
                
            //Opportunity create with campaign
            if(campaignIdSet.size() > 0){
    
                //Get RecordType Child Mass Campaign active
                Map<Id, Recordtype> campaignRecordType = new Map<Id, RecordType>([SELECT ID, Name, DeveloperName 
                                                                                FROM Recordtype 
                                                                                WHERE sObjectType = 'Campaign'
                                                                                AND DeveloperName LIKE '%Mass%']);
    
                //Get Mass campaign in Primary Campaign Source
                for(Campaign c :[SELECT Id,name
                        FROM Campaign 
                        where IsActive = true 
                        and id in: campaignIdSet
                        and RecordTypeid in:campaignRecordType.values()]){
                    mapCampaign.put(c.id, c);
                }
    
                //found mass campaign
                if(mapCampaign.size() > 0){
    
                    //Get Contact from account 
                    for(Contact c : [SELECT Id,TMB_Customer_ID__c,Account.TMB_Customer_ID_PE__c 
                            FROM Contact 
                            WHERE AccountId in:accIds]){
                        mapContact.put(c.TMB_Customer_ID__c,c);
                    }
    
                    //Keep opportunity owner as users
                    for(User u : [Select id,RTL_Channel__c,Region__c,Zone__c,RTL_Branch__c from User where id in :opptOwnerIds]){
                        mapUser.put(u.id,u);
                    }
    
                    for(RTL_product_master__c p :[select id,name,Product_Sub_group__c,Product_Group__c from RTL_product_master__c where id in: oppProductIdSet]){
                        mapProductName.put(p.id, p);
                    }
    
                    for(Opportunity opp : oppsNew){
    
                        User userowner = mapUser.get(opp.OwnerId);
                        Contact cont = mapContact.get(opp.RTL_TMB_Customer_ID_PE__c);
                        RTL_product_master__c product = new RTL_product_master__c();
                        product = mapProductName.get(opp.RTL_Product_Name__c);
    
                        if(cont!=null && userowner!=null){
                            CampaignMember cm = createCampaignMemberWithOpportunity(opp,userowner,product);
                            cm.ContactId = cont.id;
                            createCampaignMember = true;
    
                            //Add Campaign member is matching
                            newMember.add(cm);
    
                        }else{
                            createCampaignMember = false;
                            errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR004;
                            break;
                        }
                    }
    
                    //Insert Campaign member
                    try{
                        system.debug('Opportunity new campaign mem : '+newMember);
                        if(newMember.size() > 0){
                            insert newMember;
                            createCampaignMember = true;
                        }
    
                    }catch(Exception e ){
                        Database.rollback(sp);
                        createCampaignMember = false;
    
                        Integer numErrors = e.getNumDml();
                        String errorText ='';
                        for(Integer i=0;i<numErrors;i++) {
                            errorText += e.getDmlMessage(i); 
                        }
    
                        errorMessage = System.label.RTL_CampaignMemberMassCampaign_ERR001+errorText;
                        System.debug(e.getMessage());
                    }
    
                    system.debug('Opportunity : createCampaignMember '+createCampaignMember);
    
                    //Error message
                    for (Opportunity newOppObj: oppsNew){
                        if(!createCampaignMember){
                            newOppObj.addError(errorMessage); 
                        }   
                    }
    
            }
            }
    
    
            System.Debug('TMB: -> OpportunityTriggerHandler end of afterInsert for new opp link to Mass Campaign.'); 
        }
    
        private static CampaignMember createCampaignMemberWithOpportunity (Opportunity opp,User userowner,RTL_product_master__c product){
            system.debug('Opportunity : Start Create Campaign');
            
                CampaignMember cm = new CampaignMember();
                //Detail
                cm.CampaignId = opp.CampaignId;
                cm.Customer__c = opp.accountId;
    
                //Product
                cm.RTL_RelatedOpportunity_1__c = opp.id;
                cm.RTL_Campaign_Product_1__c = opp.RTL_Product_Name__c;
                cm.RTL_Product_Group_1__c = product.Product_Group__c;
                cm.RTL_Sub_Group_1__c = product.Product_Sub_group__c;
                cm.RTL_OfferResult_Product_1__c = 'Interested';
    
                //Contact Info
                cm.RTL_Assigned_Agent__c = userowner.id;
                cm.RTL_Contact_Staff_Name__c = userowner.id;
                cm.RTL_Channel_Branch__c = (userowner.RTL_Channel__c!=null&&userowner.RTL_Channel__c.equals('Branch'))?true:false;
                cm.RTL_Channel_Outbound__c = (userowner.RTL_Channel__c!=null&&userowner.RTL_Channel__c.equals('Call Center'))?true:false;
                cm.RTL_Contact_Channel__c = (userowner.RTL_Channel__c!=null)?userowner.RTL_Channel__c:null;
    
                //Branch 
                cm.RTL_Assigned_Branch__c = opp.RTL_Branch_Code_Rpt__c;
                cm.RTL_Contact_Branch__c = opp.RTL_Branch_Code_Rpt__c;
                cm.RTL_Branch_Team_Name_Code_Rpt__c = opp.RTL_Branch_Team_Name_Code_Rpt__c;
                cm.RTL_Contact_Branch_Team_Name_Code__c = opp.RTL_Branch_Team_Name_Code_Rpt__c;
                cm.RTL_Assigned_Zone_Rpt__c = opp.RTL_Zone_Code_Rpt__c;
                cm.RTL_Contact_Zone_Group__c = opp.RTL_Zone_Code_Rpt__c;
                cm.RTL_Assigned_Region_Code_Rpt__c = opp.RTL_Region_Code_Rpt__c;
                cm.RTL_Contact_Region_Group_Head__c = opp.RTL_Region_Code_Rpt__c;
                cm.RTL_Contact_Status__c = 'Contact';
                //cm.RTL_Offer_Result__c = 'Interested All'; Formula auto interested all 
                cm.Fulfillment_Status__c = 'N/A';
                cm.RTL_Remark__c = opp.Remark__c;
    
            system.debug('Opportunity : End Create Campaign');
    
            return cm;
        }
    
        private static Boolean checkSelectedProductinCampaign (Map<Id,Retail_Campaign_Products__c> mapCampaignProductName,RTL_product_master__c oppProduct) {
            Boolean isSelected = false;
            
            system.debug('Opportunity : list Product On Campaign - '+mapCampaignProductName.values());
            system.debug('Opportunity : Product Master - '+oppProduct);
    
            if(mapCampaignProductName.values().size() > 0 ){
                for(Retail_Campaign_Products__c l : mapCampaignProductName.values()){
    
                    if(oppProduct.id == l.RTL_Retail_Product_Master__c){
                        system.debug('Opportunity : Product matching by id');
                        isSelected = true;
                        break;
                    }else if(oppProduct.Name == l.Name){
                        system.debug('Opportunity : Product matching by name');
                        isSelected = true;
                        break;
                    }else if(oppProduct.Product_Sub_group__c == l.RTL_Sub_Group__c){
                        system.debug('Opportunity : Product matching by subgroup');
                        isSelected = true;
                        break;
                    }else if(oppProduct.Product_Group__c == l.RTL_Product_Group__c){
                        system.debug('Opportunity : Product matching by group');
                        isSelected = true;
                        break;
                    }else{
                        system.debug('Opportunity : Not match');
                        isSelected = false;
                    }
                }
    
            }
    
            system.debug('Opportunity : This opp selected campaign product - '+isSelected);
    
    
            return isSelected;
        }
    
        
        /* End of private methods */
        //====================================================================
    
        //--- CR AL Re-org Long Term ---
        public static void updateOpptyByReferral (List<Opportunity> oppty)
        {
            Set<Id> refId = new Set<Id>();
            Set<Id> cmId = new Set<Id>();
            Map<Id,Opportunity> opptyMapWithProduct = new Map<Id,Opportunity>();
            Map<Id,Opportunity> opptyMapWithRefId = new Map<Id,Opportunity>();
            Map<Id,Id> refMapWithCmId = new Map<Id,Id> ();
            Map<Id,CampaignMember> campaignMemMap = new Map<Id,CampaignMember> ();
    
            System.debug('oppty:' +oppty);
            for(Opportunity op : oppty)
            {
                if(op.RTL_Product_Name__c != null && op.RTL_Referral__c != null)
                {
                    refId.add(op.RTL_Referral__c);
                    opptyMapWithRefId.put(op.RTL_Referral__c,op);
                    opptyMapWithProduct.put(op.RTL_Product_Name__c, op);
                }
            }
            System.debug('refId:' +refId);
            System.debug('opptyMapWithProduct:' + opptyMapWithProduct);
            if(refId.size() > 0)
            {  
                List<RTL_Referral__c> refList = [SELECT Id,RTL_Campaign_Member__c FROM RTL_Referral__c WHERE Id IN: refId];    
                for(RTL_Referral__c ref : refList)
                {
                    cmId.add(ref.RTL_Campaign_Member__c);
                    refMapWithCmId.put(ref.RTL_Campaign_Member__c,ref.Id);
                }
    
                List<CampaignMember> campaignMemList = [SELECT Id,Campaign.Name,RTL_Campaign_Name_TH__c,RTL_Marketing_Code__c,RTL_Campaign_Product_1__c,RTL_Campaign_Product_2__c,RTL_Campaign_Product_3__c,RTL_Campaign_Product_4__c,RTL_Campaign_Product_5__c,
                                                    RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,RTL_OfferResult_Product_5__c,
                                                    RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c 
                                                    FROM CampaignMember WHERE Id IN: cmId];
                List<Cross_Sell_Product__c> crossSellList = [SELECT Id,Name, CampaignMemberId__c,Campaign_Product__c,RTL_OfferResult_Product__c,OpportunityId__c FROM Cross_Sell_Product__c WHERE CampaignMemberId__c IN: cmId ORDER BY Name];
    
                if(campaignMemList.size() > 0)
                {
                    for(CampaignMember campaignMem : campaignMemList)
                    {
                        campaignMemMap.put(campaignMem.Id,campaignMem);
                        for(Integer i = 1; i <= 5; i++)
                        {
                            System.debug('Marketing Code:'+ campaignMem.RTL_Marketing_Code__c);
                            System.debug('Campaign Name:' + campaignMem.Campaign.Name);
                            System.debug('Product:' + (String)campaignMem.get('RTL_Campaign_Product_'+i+'__c'));
                            if(opptyMapWithProduct.containsKey((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c')) && campaignMem.get('RTL_OfferResult_Product_'+i+'__c') == 'Referred' 
                                && campaignMem.get('RTL_RelatedOpportunity_'+i+'__c') == null)
                            {
                                System.debug('Oppty :' + opptyMapWithProduct.get((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c')));
                                Opportunity updateOppty = new Opportunity();
                                updateOppty = opptyMapWithProduct.get((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c'));
                                updateOppty.Name += ' (CMP)';
                                updateOppty.Marketing_Code__c = campaignMem.RTL_Marketing_Code__c;   
                                updateOppty.CampaignId = campaignMem.CampaignId;
                                updateOppty.RTL_Campaign_Name__c = campaignMem.Campaign.Name;
                                updateOppty.RTL_Is_Create_From_Campaign_Member__c = true;
                            }
                        }
                    }
                                   
                    if(crossSellList.size() > 0)
                    {
                        for(Cross_Sell_Product__c cs : crossSellList)
                        {
                            if(opptyMapWithProduct.containsKey(cs.Campaign_Product__c) && cs.RTL_OfferResult_Product__c == 'Referred' 
                            && cs.OpportunityId__c == null)
                            {
                                Opportunity updateOppty = new Opportunity();
                                updateOppty = opptyMapWithProduct.get(cs.Campaign_Product__c);
                                updateOppty.Marketing_Code__c = campaignMemMap.containskey(cs.CampaignMemberId__c) ?  campaignMemMap.get(cs.CampaignMemberId__c).RTL_Marketing_Code__c : null;   
                            }                
                        }
                    }
                    
    
                }
               
            }
        }
        public static void updateOpptyToCampaignMember (List<Opportunity> oppty)
        {    
            Set<Id> refId = new Set<Id>();
            Set<Id> cmId = new Set<Id>();
            List<CampaignMember> updateCM = new List<CampaignMember>();
            List<Cross_Sell_Product__c> updateCS = new List<Cross_Sell_Product__c>();
            Map<Id,Opportunity> opptyMapWithProduct = new Map<Id,Opportunity>();
            Map<Id,Opportunity> opptyMapWithRefId = new Map<Id,Opportunity>();
            Map<Id,Id> refMapWithCmId = new Map<Id,Id> ();
            Map<Id,CampaignMember> campaignMemMap = new Map<Id,CampaignMember> ();
    
            System.debug('oppty:' +oppty);
    
            for(Opportunity op : oppty)
            {
                if(op.RTL_Product_Name__c != null && op.RTL_Referral__c != null)
                {
                    refId.add(op.RTL_Referral__c);
                    opptyMapWithRefId.put(op.RTL_Referral__c,op);
                    opptyMapWithProduct.put(op.RTL_Product_Name__c, op);
                }
            }
            System.debug('refId:' +refId);
            if(refId.size() > 0)
            {  
                List<RTL_Referral__c> refList = [SELECT Id,RTL_Campaign_Member__c FROM RTL_Referral__c WHERE Id IN: refId];    
                for(RTL_Referral__c ref : refList)
                {
                    cmId.add(ref.RTL_Campaign_Member__c);
                    refMapWithCmId.put(ref.RTL_Campaign_Member__c,ref.Id);
                }
    
                List<CampaignMember> campaignMemList = [SELECT Id,Campaign.Name,RTL_Campaign_Name_TH__c,RTL_Marketing_Code__c,RTL_Campaign_Product_1__c,RTL_Campaign_Product_2__c,RTL_Campaign_Product_3__c,RTL_Campaign_Product_4__c,RTL_Campaign_Product_5__c,
                                                    RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,RTL_OfferResult_Product_5__c,
                                                    RTL_RelatedOpportunity_1__c,RTL_RelatedOpportunity_2__c,RTL_RelatedOpportunity_3__c,RTL_RelatedOpportunity_4__c,RTL_RelatedOpportunity_5__c 
                                                    FROM CampaignMember WHERE Id IN: cmId];
                List<Cross_Sell_Product__c> crossSellList = [SELECT Id,Name, CampaignMemberId__c,Campaign_Product__c,RTL_OfferResult_Product__c,OpportunityId__c FROM Cross_Sell_Product__c WHERE CampaignMemberId__c IN: cmId ORDER BY Name ASC];
    
                if(campaignMemList.size() > 0)
                {
                    for(CampaignMember campaignMem : campaignMemList)
                    {
                        campaignMemMap.put(campaignMem.Id,campaignMem);
                        for(Integer i = 1; i <= 5; i++)
                        {
                            System.debug('Marketing Code:'+ campaignMem.RTL_Marketing_Code__c);
                            System.debug('Campaign Name:' + campaignMem.Campaign.Name);
    
                            if(opptyMapWithProduct.containsKey((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c')) && campaignMem.get('RTL_OfferResult_Product_'+i+'__c') == 'Referred' 
                                && campaignMem.get('RTL_RelatedOpportunity_'+i+'__c') == null)
                            {
                                campaignMem.put('RTL_RelatedOpportunity_'+i+'__c',opptyMapWithProduct.get((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c')).Id);                   
                                //opptyMapWithProduct.get((String)campaignMem.get('RTL_Campaign_Product_'+i+'__c')).Marketing_Code__c = campaignMem.RTL_Marketing_Code__c;                  
                                updateCM.add(campaignMem);
                            }
                        }
                    }
                    System.debug('Update Campaign Member :' +updateCM);
                    if(updateCM.size() > 0)
                    {
                        update updateCM;
                    }   
                    else
                    {         
                        if(crossSellList.size() > 0)
                        {
                            String checkDupOppty = '';
                            for(Cross_Sell_Product__c cs : crossSellList)
                            {          
                                if(opptyMapWithProduct.containsKey(cs.Campaign_Product__c) && cs.RTL_OfferResult_Product__c == 'Referred' 
                                && cs.OpportunityId__c == null)
                                {
                                    System.debug('opptyMapWithProduct :' +opptyMapWithProduct.get(cs.Campaign_Product__c).Id);
                                    if(checkDupOppty != (String)opptyMapWithProduct.get(cs.Campaign_Product__c).Id)
                                    {
                                        cs.OpportunityId__c = opptyMapWithProduct.get(cs.Campaign_Product__c).Id;
                                        checkDupOppty = (String)opptyMapWithProduct.get(cs.Campaign_Product__c).Id;
                                        updateCS.add(cs);
                                    }
                                }                
                            }
                        }
    
                        System.debug('Update Cross Sell :' +updateCM);
                        if(updateCS.size() > 0)
                        {
                            update updateCS;
                        }
                    }
                }
               
            }
    
        }
        public static void updateOpptyByCampaignMember (List<Opportunity> oppty){
            List<String> opptyExternalCM = new List<String>();
            Map<String,String> opptyMapWithMktCode = new Map<String,String>();
    
            for(Opportunity op : oppty)
            {
                if(op.RTL_External_Ref_ID__c != null && !op.RTL_External_Ref_ID__c.startsWith('a2S')){
                    opptyExternalCM.add(op.RTL_External_Ref_ID__c);
                }
            }
            if(opptyExternalCM.size()>0){
                List<CampaignMember> listcm = [SELECT Id,RTL_Marketing_Code__c FROM CampaignMember WHERE Id IN: opptyExternalCM OR RTL_Marketing_Code__c IN: opptyExternalCM OR RTL_Web_Unique_Id__c IN: opptyExternalCM];
                if(listcm.size()>0){
                    for(CampaignMember cm : listcm){
                        if(cm.RTL_Marketing_Code__c != null){
                            if(opptyExternalCM.contains(cm.Id)){
                                opptyMapWithMktCode.put(cm.Id,cm.RTL_Marketing_Code__c);
                            }
                            else if(opptyExternalCM.contains(cm.RTL_Marketing_Code__c)){
                                opptyMapWithMktCode.put(cm.RTL_Marketing_Code__c,cm.RTL_Marketing_Code__c);
                            }
                            else if(opptyExternalCM.contains(cm.RTL_Web_Unique_ID__c)){
                                opptyMapWithMktCode.put(cm.RTL_Web_Unique_ID__c,cm.RTL_Marketing_Code__c);
                            }
                        }
                    }
                }

                if(opptyMapWithMktCode.size()>0){ 
                    for(Opportunity op : oppty)
                    {
                        if(opptyMapWithMktCode.containsKey(op.RTL_External_Ref_ID__c)){
                            op.Marketing_Code__c = opptyMapWithMktCode.get(op.RTL_External_Ref_ID__c);
                        }
                    }
                }
            }
        }
    
        
     }