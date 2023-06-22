global class SmartBDM_BusinessTypeSchedule implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext ctx) {
        List<IndustryMaster__c> IndustryMasterList = [SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c];
        Map<String, IndustryMaster__c> IndustryMasterMap = new Map<String, IndustryMaster__c>();
        for(IndustryMaster__c item : IndustryMasterList) {
            IndustryMasterMap.put(item.TMBCode__c, item);
        }
        SmartBDM_BusinessTypeBatch BusinessType = new SmartBDM_BusinessTypeBatch(IndustryMasterMap, 0);
        Database.executeBatch(BusinessType, 200);
    }
}