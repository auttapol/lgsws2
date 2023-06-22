public without sharing class SmartBDM_BusinessTypeController {

    public SmartBDM_BusinessTypeController() {

    }

    public class BusinessTypeGroupWrapper {
        public List<OnlineServiceLog> onlineServiceLog {get;set;}
        public List<SmartBDMBusinessType.Response> businessGroup {get;set;}
        public List<SmartBDMBusinessType.Response> businessType {get;set;}

        public BusinessTypeGroupWrapper() {
            this.onlineServiceLog = new List<OnlineServiceLog>();
            this.businessGroup = new List<SmartBDMBusinessType.Response>();
            this.businessType = new List<SmartBDMBusinessType.Response>();
        }

        public Boolean isSuccess() {
            Boolean temp_isSuccess = !this.onlineServiceLog.isEmpty() ? true : false;
            for (OnlineServiceLog o : this.onlineServiceLog) {
                temp_isSuccess = temp_isSuccess && o.isSuccess;
            }
            return temp_isSuccess;
        }
    }

    @AuraEnabled
    public static List<IndustryMaster__c> fetchIndustryMaster(String searchKeyWord) {
        try {
            return [SELECT Id, BusinessType__c, TMBCode__c FROM IndustryMaster__c WHERE BusinessType__c LIKE: '%' + searchKeyWord + '%' OR TMBCode__c LIKE: '%' + searchKeyWord + '%' LIMIT 100];
        } catch (Exception e) {
            return new List<IndustryMaster__c>();
        }
    }

    @AuraEnabled
    public static IndustryMaster__c getIndustryMaster(String IndustryMasterID) {
        try {
            return [SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c WHERE Id =: IndustryMasterID];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getDeepLink(){
        return Smart_BDM_Constant.DEEP_LINK_TO_KONY_CAL_TOOLS;
    }

}