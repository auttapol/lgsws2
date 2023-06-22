public class QCA_OpportunitySimplifiedController {

    public class RecordTypeWrapper {
        @AuraEnabled
        public Id RecordTypeVisitPlanReport {get; set;}
        @AuraEnabled
        public Id RecordTypeOpportunity {get; set;}
    }

    public static Id VisitPlanforLeadRecordTypeId {
        get {
            if (VisitPlanforLeadRecordTypeId == null) {
               VisitPlanforLeadRecordTypeId = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByName().get('Visit Plan / Report').getRecordTypeId();
            }
            return VisitPlanforLeadRecordTypeId;
        }
        set;
    }
  
    public static Id SECreditProductRecordTypeId {
        get {
            if (SECreditProductRecordTypeId == null) {
               SECreditProductRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
            }
            return SECreditProductRecordTypeId;
        }
        set;
    }
    @AuraEnabled
    public static String getDeepLink() {
        return Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
    }
    @AuraEnabled
    public static RecordTypeWrapper getRecordTypeSimplifiedOpportunity() {
        RecordTypeWrapper recordTypeLead = new RecordTypeWrapper();
        recordTypeLead.RecordTypeVisitPlanReport = VisitPlanforLeadRecordTypeId;
        recordTypeLead.RecordTypeOpportunity = SECreditProductRecordTypeId;
        return recordTypeLead;
    }
    
    @AuraEnabled
    public static void updateTrackStatus(String opptyObjId, String stage)
    {
        SmartBDM_Utility.updateOpptyStatus(opptyObjId, stage);
    }

    @AuraEnabled
    public static Opportunity getOpportuniyObjById(Id opptyId){
        try {
            Opportunity opptyObj = [SELECT Id, OwnerId, RecordTypeId, RecordType.Name , Name, AccountId,
                                    Expected_submit_date__c, CloseDate, Main_Branch__c,
                                    Remark__c, Host_System__c, CAID__c, SmartBDM_QuickCA_ProcessStatus__c,
                                    StageName,Probability,Application_Status__c,
                                    Details_of_Status__c,Host_Product_Group__c,Amount,
                                    CampaignId,LeadSource,Converted_Lead_ID__c,Other_Source__c,
                                    Branch_Referred__c,product_campaign_recommend__c,
                                    Referral_Staff_ID__c,Referral_Staff_Name__c,RTL_Referral__c,Supply_Chain_Flag__c
                                    FROM Opportunity
                                    WHERE Id =:opptyId ];
            return opptyObj;
        } catch (Exception e) {
            System.debug('(Method) getOpportuniyObjById : '+ e.getMessage());
            return null;
        }
    }
}