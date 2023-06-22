public class SmartBDM_BusinessTypeBatch implements Database.Batchable<SmartBDMBusinessType.Response>, Database.AllowsCallouts, Database.Stateful {
    
    // String query;
    private Integer retryCount;
    private Map<String, IndustryMaster__c> IndustryMasterMap;

    private String token;
    // private Long tokenExpiresIn;
    private Boolean isSuccess = false;
    private SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessGroupWrapper;
    private SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessTypeWrapper;
    private List<SmartBDMBusinessType.Response> businessTypeList;
    private List<SmartBDMBusinessType.Response> businessGroupList;
    private Map<String, SmartBDMBusinessType.Response> businessTypeMap;
    private Map<String, SmartBDMBusinessType.Response> businessGroupMap;
    private Set<String> keyBusinessTypeCodeUpsert;
    private List<IndustryMaster__c> upsertIndustryMaster;
    private List<IndustryMaster__c> deleteIndustryMaster;
    
    private Datetime startTime;
    private Datetime endTime;
    private Integer recordsSuccessful = 0;
    private Integer recordsFailed = 0;
    private String errorMessage = '';

    public SmartBDM_BusinessTypeBatch(Map<String, IndustryMaster__c> IndustryMasterMap, Integer retryCount) {
        this.IndustryMasterMap = IndustryMasterMap;
        this.retryCount = retryCount;
        this.businessGroupList = new List<SmartBDMBusinessType.Response>();
        this.businessTypeList = new List<SmartBDMBusinessType.Response>();

        businessTypeMap = new Map<String, SmartBDMBusinessType.Response>();
        businessGroupMap = new Map<String, SmartBDMBusinessType.Response>();
        keyBusinessTypeCodeUpsert = new Set<String>();
        upsertIndustryMaster = new List<IndustryMaster__c>();
        deleteIndustryMaster = new List<IndustryMaster__c>();
	}

    public Iterable<SmartBDMBusinessType.Response> start(Database.BatchableContext BC) {
        this.token = SmartBDM_Utility.tokenKeyCalculateTools;

        startTime = DateTime.now();
        tmpBusinessGroupWrapper = SmartBDM_Service.startCallGetBusinessGroupService(token, 1, 100);
        tmpBusinessTypeWrapper = SmartBDM_Service.startCallGetBusinessTypeService(token, 1, 100);
        endTime = DateTime.now();

        if (tmpBusinessGroupWrapper.isSuccess() && tmpBusinessTypeWrapper.isSuccess()) {
            // businessTypeGroupWrapper.isSuccess = true;
            // businessTypeGroupWrapper.businessGroup = tmpBusinessGroupWrapper.businessGroup;
            // businessTypeGroupWrapper.businessType = tmpBusinessTypeWrapper.businessType;

            this.businessGroupList = tmpBusinessGroupWrapper.businessGroup;
            this.businessTypeList = tmpBusinessTypeWrapper.businessType;
            this.isSuccess = true;
        }

        // Business Group log
        RTL_CampaignUtil.saveToOnlineLog(tmpBusinessGroupWrapper.onlineServiceLog, ''/*customerName*/, null/*error message*/, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_BUSINESS_GROUP, null /* Account Object*/, startTime, endTime);
        // Business Type log
        RTL_CampaignUtil.saveToOnlineLog(tmpBusinessTypeWrapper.onlineServiceLog, ''/*customerName*/, null/*error message*/, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_BUSINESS_TYPE, null /* Account Object*/, startTime, endTime);

        for (SmartBDMBusinessType.Response rsp : this.businessGroupList) {
            if(rsp.code != null) businessGroupMap.put(rsp.code, rsp);
        }

        for (SmartBDMBusinessType.Response rsp : this.businessTypeList) {
            if(rsp.businessType != null){
                SmartBDMBusinessType.Response tmp_rsp = businessGroupMap.get(rsp.businessType.groupCode);
                if(tmp_rsp != null && !businessTypeMap.containsKey(rsp.businessType.code)){
                    rsp.code = tmp_rsp.code;
                    rsp.name = tmp_rsp.name;
                    rsp.arDay = tmp_rsp.arDay;
                    rsp.invDay = tmp_rsp.invDay;
                    rsp.apDay = tmp_rsp.apDay;
                    rsp.incomeFactor = tmp_rsp.incomeFactor;
                    rsp.cogDay = tmp_rsp.cogDay;
                    businessTypeMap.put(rsp.businessType.code, rsp);
                }
            }
        }

        return businessTypeMap.values();
	}

    public void execute(Database.BatchableContext BC, List<SmartBDMBusinessType.Response> scope){
        // process each batch of records
        upsertIndustryMaster = new List<IndustryMaster__c>();

        for(SmartBDMBusinessType.Response rsp : scope) {

            if(IndustryMasterMap.containsKey(rsp.businessType.code)){

                IndustryMaster__c im = IndustryMasterMap.get(rsp.businessType.code);
                im.APday__c = rsp.apDay;
                im.ARday__c = rsp.arDay;
                im.BusinessType__c = rsp.businessType.name;
                im.COGday__c = Integer.valueOf(rsp.cogDay.replace('%', ''));
                im.Diversification__c = rsp.diversification.contains('Y') ? true : false;
                im.HighlySelectiveIndustry__c = rsp.highlySelectiveIndustry.contains('Y') ? true : false;
                im.HighRisk__c = rsp.highRisk.contains('Y') ? true : false;
                im.INVday__c = rsp.invDay;
                im.ISICCode__c = rsp.businessType.isicCode;
                im.Negative__c = rsp.negative.contains('Y') ? true : false;
                im.SubIndustry__c = rsp.businessType.subGroup;
                // im.ColorCode__c = rsp.
                im.Suspend__c = rsp.suspend.contains('Y') ? true : false;
                im.TMBCode__c = rsp.businessType.code;
                im.IncomeFactor__c = Integer.valueOf(rsp.incomeFactor.replace('%', ''));
                im.BusinessGroupCode__c = rsp.businessType.groupCode;
                im.BusinessGroupNameTH__c = rsp.name.th;
                im.BusinessGroupNameEN__c = rsp.name.en;
                
                // Move record to list upsert
                upsertIndustryMaster.add(im);
                keyBusinessTypeCodeUpsert.add(rsp.businessType.code);
                // Remove record in industry master mapping 
                IndustryMasterMap.remove(rsp.businessType.code);
            }
            else {
                IndustryMaster__c im = new IndustryMaster__c();
                im.APday__c = rsp.apDay;
                im.ARday__c = rsp.arDay;
                im.BusinessType__c = rsp.businessType.name;
                im.COGday__c = Integer.valueOf(rsp.cogDay.replace('%', ''));
                im.Diversification__c = rsp.diversification.contains('Y') ? true : false;
                im.HighlySelectiveIndustry__c = rsp.highlySelectiveIndustry.contains('Y') ? true : false;
                im.HighRisk__c = rsp.highRisk.contains('Y') ? true : false;
                im.INVday__c = rsp.invDay;
                im.ISICCode__c = rsp.businessType.isicCode;
                im.Negative__c = rsp.negative.contains('Y') ? true : false;
                im.SubIndustry__c = rsp.businessType.subGroup;
                // im.ColorCode__c = rsp.
                im.Suspend__c = rsp.suspend.contains('Y') ? true : false;
                im.TMBCode__c = rsp.businessType.code;
                im.IncomeFactor__c = Integer.valueOf(rsp.incomeFactor.replace('%', ''));
                im.BusinessGroupCode__c = rsp.businessType.groupCode;
                im.BusinessGroupNameTH__c = rsp.name.th;
                im.BusinessGroupNameEN__c = rsp.name.en;

                // Insert record from Data of API WS
                upsertIndustryMaster.add(im);
            }

        }

        if(upsertIndustryMaster.size() > 0){
            // upsert upsertIndustryMaster;
            Database.UpsertResult[]  lsr = Database.upsert(upsertIndustryMaster, false);
            Integer runningIndex = 0;
            // Iterate through each returned result
            for (Database.UpsertResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Upsert with ID: ' + sr.getId());
                    recordsSuccessful += 1;
                }
                else {
                    // Operation failed, so get all errors                
                    Id recordId = upsertIndustryMaster.get(runningIndex).Id;
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + recordId + ','
                                            + err.getMessage() + ','
                                            + String.join(err.getFields(),',') + ','
                                            + err.getStatusCode() + '\n';

                        System.debug(logginglevel.ERROR, 'There is error on BusinessTypeBatch. Error Message is: ' + err.getMessage());
                    }
                    System.debug(errorMsg);
                    recordsFailed += 1;
                    errorMessage += errorMsg;
                }
                runningIndex++;
            }
        }        

    }    

    public void finish(Database.BatchableContext BC){
        String query = '[SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c]';
        if(this.isSuccess){
            deleteIndustryMaster.addAll(IndustryMasterMap.values());
            if(deleteIndustryMaster.size() > 0) {
                // delete IndustryMasterMap.values();
                Database.DeleteResult[]  lsr = Database.delete(deleteIndustryMaster, false);

                Integer runningIndex = 0;
                // Iterate through each returned result
                for (Database.DeleteResult sr : lsr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully Delete with ID: ' + sr.getId());
                        recordsSuccessful += 1;
                    }
                    else {
                        // Operation failed, so get all errors                
                        Id recordId = deleteIndustryMaster.get(runningIndex).Id;
                        String errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = errorMsg + recordId + ','
                                                + err.getMessage() + ','
                                                + String.join(err.getFields(),',') + ','
                                                + err.getStatusCode() + '\n';

                            System.debug(logginglevel.ERROR, 'There is error on BusinessTypeBatch. Error Message is: ' + err.getMessage());
                        }
                        System.debug(errorMsg);
                        recordsFailed += 1;
                        errorMessage += errorMsg;
                    }
                    runningIndex++;
                }
            }

            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(
                Datetime.now(),
                startTime,
                Datetime.now(),
                recordsSuccessful,
                recordsFailed,
                'Syn_Industry_Master',
                'Industry Master',
                Smart_BDM_Constant.EMAIL_SENT_TO_ALERT,
                errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
                '', // secondaryError
                '', // successLog
                'Industry Master ID,Field Error,StatusCode,Error Message\n', // mainErrorHeader
                '', // secondaryErrorHeader
                '', // successLogHeader
                query
            );
        }
        else {
            retryCount++;
            if(retryCount < 3) DataBase.executeBatch(new SmartBDM_BusinessTypeBatch(IndustryMasterMap, retryCount), 200);
            else {
                RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(
                    Datetime.now(),
                    startTime,
                    Datetime.now(),
                    recordsSuccessful,
                    recordsFailed,
                    'Syn_Industry_Master',
                    'Industry Master',
                    Smart_BDM_Constant.EMAIL_SENT_TO_ALERT,
                    errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
                    '', // secondaryError
                    '', // successLog
                    'Industry Master ID,Field Error,StatusCode,Error Message\n', // mainErrorHeader
                    '', // secondaryErrorHeader
                    '', // successLogHeader
                    query
                );
            }
        }
    }    

}