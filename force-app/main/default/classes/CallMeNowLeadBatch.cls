global class CallMeNowLeadBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    String query;

    private List<Lead> updateleadlst;
    private Set<Id> queryLeadIdlst;
    private Map<String, RTL_Online_Service_Log__c> mapWebUnioslog;
    private Map<String, OnlineServiceLog> mapWebUnioslogDetail;
    private Lead obj = null;

    private static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Employee_ID__c FROM User WHERE Id = :System.UserInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    private static Map<String, NamedCredential> mapNamedCredentiallURL {
        get{
            if(mapNamedCredentiallURL == null){
                mapNamedCredentiallURL = new Map<String, NamedCredential>();
                for(NamedCredential namedCre : [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName LIKE 'WsCallMeNow%']){
                    mapNamedCredentiallURL.put(namedCre.DeveloperName, namedCre);
                }
            }
            System.debug('mapNamedCredentiallURL : ' + mapNamedCredentiallURL);
            return mapNamedCredentiallURL;
        }
        set;
    }

    private static Map<String, RTL_Lead_Assignment_Rule__c> mapLeadAssignmentRules {
        get{
            if(mapLeadAssignmentRules == null){
                mapLeadAssignmentRules = new Map<String, RTL_Lead_Assignment_Rule__c>();
                for(RTL_Lead_Assignment_Rule__c rule : [select id, RTL_Integration_Type__c from RTL_Lead_Assignment_Rule__c]){
                    mapLeadAssignmentRules.put(rule.Id, rule);
                }
            }
            System.debug('mapLeadAssignmentRules : ' + mapLeadAssignmentRules);
            return mapLeadAssignmentRules;
        }
        set;
    }

    private static Integer SLATime{
        get{
            if(SLATime == null ){
                Integer slaT;
                AppConfig__c cf = AppConfig__c.getValues('SLATime');
                slaT = (cf == null ? 1 : (cf.Value__c == null ? 1 : integer.valueof(cf.Value__c)));

                SLATime = slaT;
                
            }
            return SLATime;

        }set;
    }

    private static BusinessHours callMeNowBusinessHours{
        get{
            if(callMeNowBusinessHours == null ){
                String bhName;
                AppConfig__c cf = AppConfig__c.getValues('RetailOutboundBH');
                bhName = (cf == null ? 'Retail Outbound' : cf.Value__c);
                List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours WHERE Name =: bhName];
                if(businessHours.size() > 0){
                    callMeNowBusinessHours = businessHours[0];
                }
                
            }
            return callMeNowBusinessHours;

        }set;
    }

	global CallMeNowLeadBatch(Set<Id> leadIdlst) {
        System.debug(':::: CallMeNowLeadBatch ::::');
        updateleadlst = new List<Lead>();
        mapWebUnioslog = new Map<String, RTL_Online_Service_Log__c>();
        mapWebUnioslogDetail = new Map<String, OnlineServiceLog>();
         
        queryLeadIdlst = leadIdlst;
        
		//query = 'SELECT Id, Name, FirstName, LastName, RTL_Product_Name__c, RTL_Mobile_Number__c, RTL_Lead_Campaign_Outbound__c, RTL_Lead_Channel_Outbound__c, RTL_Call_Back_Date_time__c, RTL_Lead_Assigned_By_Rule__c, RTL_Lead_Assigned_By_Rule__r.RTL_Integration_Type__c, RTL_Web_Unique_ID_c__c, RTL_Call_Me_Now_Status__c, RTL_Call_Me_Now_Retry_Count__c, RTL_Contact_Method__c FROM Lead WHERE Id IN :queryLeadIdlst';
        query = 'SELECT Id, LeadId, Lead.Name, Lead.FirstName, Lead.RTL_Remark__c, Lead.RTL_AL_ContactProvince__c, Lead.LastName, Lead.RTL_Product_Name__c, Lead.RTL_Mobile_Number__c, Lead.RTL_Lead_Campaign_Outbound__c, Lead.RTL_Lead_Channel_Outbound__c, Lead.RTL_Call_Back_Date_time__c, Lead.RTL_Lead_Assigned_By_Rule__c, Lead.RTL_Web_Unique_ID_c__c, Lead.RTL_Call_Me_Now_Status__c, Lead.RTL_Call_Me_Now_Retry_Count__c, Lead.RTL_Contact_Method__c,Lead.RTL_TMB_Campaign_Reference__c,Lead.RTL_W2L_Campaign_Name__c,Lead.RTL_AL_Car_Status__c,Lead.RTL_AL_Leasing_Condition__c,Lead.RTL_Customer_Segment__c FROM CampaignMember WHERE LeadId IN :queryLeadIdlst';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::: CallMeNowLeadBatch start ::::');
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        System.debug(':::: CallMeNowLeadBatch execute ::::');
        //for(Lead obj : scope){
        for(CampaignMember cm : scope){
            CallMeNowDTO callMeNowObj = new CallMeNowDTO();
            String strDateTime = cm.lead.RTL_Call_Back_Date_time__c != null ? cm.lead.RTL_Call_Back_Date_time__c.format('yyyy-MM-dd HH:mm') : cm.lead.RTL_Contact_Method__c == 'Call Me Now' ? System.now().format('yyyy-MM-dd HH:mm') : getNextnBSDate().addHours(7).formatGMT('yyyy-MM-dd HH:mm') ;

            AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
            String sfdcBaseLightningURL = lightCF == null ? 'https://tmbbank--uat.lightning.force.com' : lightCF.Value__c;
            String remark = cm.lead.RTL_Remark__c;
            String subRemark = '';
            if(remark != null){
                subRemark = remark.left(150);
            }
            String strvar5 = '';
            if(cm.lead.RTL_AL_Car_Status__c != null && cm.lead.RTL_AL_Leasing_Condition__c != null){
                strvar5 = cm.lead.RTL_AL_Leasing_Condition__c + '_' + cm.lead.RTL_AL_Car_Status__c;
            }else if (cm.lead.RTL_AL_Car_Status__c != null && cm.lead.RTL_AL_Leasing_Condition__c == null){
                strvar5 = cm.lead.RTL_AL_Car_Status__c;
            }else if (cm.lead.RTL_AL_Car_Status__c == null && cm.lead.RTL_AL_Leasing_Condition__c != null){
                strvar5 = cm.lead.RTL_AL_Leasing_Condition__c;
            }
            
            callMeNowObj.request.setRequestId(cm.lead.RTL_Web_Unique_ID_c__c);
            callMeNowObj.request.setFirstName(cm.lead.FirstName);
            callMeNowObj.request.setLastName(cm.lead.LastName);
            callMeNowObj.request.setProductName(cm.lead.RTL_Product_Name__c);
            
            callMeNowObj.request.setMobile(cm.lead.RTL_Mobile_Number__c);
            callMeNowObj.request.setCampaign(cm.lead.RTL_Lead_Campaign_Outbound__c);
            callMeNowObj.request.setDropLeadDateTime(strDateTime);
            
            callMeNowObj.request.setVar1(cm.Id);
            callMeNowObj.request.setVar2(subRemark);
            callMeNowObj.request.setVar3(cm.lead.RTL_Customer_Segment__c);
            callMeNowObj.request.setVar4(cm.lead.RTL_W2L_Campaign_Name__c);
            callMeNowObj.request.setVar5(strvar5);
            callMeNowObj.request.setVar6(cm.lead.RTL_TMB_Campaign_Reference__c);

            // AL Enhancement
            Blob cmUrl = Blob.valueOf('{"componentDef":"c:CampaignMember_Main","attributes":{"recordId":"' + cm.Id + '","mode":"Edit"},"state":{}}');
            String encUrl = EncodingUtil.base64Encode(cmUrl);
            //callMeNowObj.request.setURL(sfdcBaseLightningURL + '/lightning/r/CampaignMember/' + cm.Id + '/view');
            callMeNowObj.request.setURL(sfdcBaseLightningURL + '/one/one.app#' + encUrl);

            callMeNowObj.request.setChannel(cm.lead.RTL_Lead_Channel_Outbound__c);
            callMeNowObj.request.setRequiredWrapUp('true');

            System.debug('callMeNowObj : ' + callMeNowObj);

            RTL_Lead_Assignment_Rule__c leadAssignmentRule = mapLeadAssignmentRules.get(cm.lead.RTL_Lead_Assigned_By_Rule__c);
            OnlineServiceLog oslogDetail = CallMeNowService.callOutCMNLead(callMeNowObj, leadAssignmentRule.RTL_Integration_Type__c);

            System.debug('callMeNowObj : ' + callMeNowObj);

            // AL Enhancement
            obj = new Lead();
            obj.Id = cm.leadId;
            obj.RTL_Call_Me_Now_Status__c = 'success';
            System.debug(obj.RTL_Call_Me_Now_Status__c);
            
            if(callMeNowObj.response.message != 'success'){
                obj.RTL_Call_Me_Now_Status__c = '';
                System.debug('Call Me Now Retry Count -->' + obj.RTL_Call_Me_Now_Retry_Count__c);
                if (obj.RTL_Call_Me_Now_Retry_Count__c == null) {
                    obj.RTL_Call_Me_Now_Retry_Count__c = 0; 
                }
                obj.RTL_Call_Me_Now_Retry_Count__c += 1;
                if(obj.RTL_Call_Me_Now_Retry_Count__c >= 3){
                    obj.RTL_Call_Me_Now_Status__c = 'fail';
                }
            }
            updateleadlst.add(obj);

            RTL_Online_Service_Log__c oslog = new RTL_Online_Service_Log__c();
            oslog.RTL_Customer_Name__c = obj.RTL_Web_Unique_ID_c__c;
            oslog.RTL_Error_Message__c = oslogDetail.errorMesssage;
            oslog.RTL_Name_of_User__c = currentUser.Name;
            oslog.RTL_RM_ID__c = currentUser.Employee_ID__c;
            if (mapNamedCredentiallURL.get('WsCallMeNow_' + leadAssignmentRule.RTL_Integration_Type__c) != null) {
                oslog.RTL_Service_Name__c = mapNamedCredentiallURL.get('WsCallMeNow_' + leadAssignmentRule.RTL_Integration_Type__c).Endpoint;
            }
            oslog.RTL_Is_Success__c = oslogDetail.isSuccess;
            oslog.RTL_Start_DateTime__c = oslogDetail.startTime;
            oslog.RTL_End_DateTime__c = oslogDetail.endTime;

            String key = obj.RTL_Web_Unique_ID_c__c + obj.RTL_Call_Me_Now_Retry_Count__c;

            mapWebUnioslog.put(key, oslog);
            mapWebUnioslogDetail.put(key, oslogDetail);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(':::: CallMeNowLeadBatch finish ::::');
        if(mapWebUnioslog.size() > 0){
            RTL_CampaignUtil.insertOnlineServiceLogMultiWithAttach(mapWebUnioslog, mapWebUnioslogDetail);
        }
        System.debug('updateleadlst : ' + updateleadlst);
		if(updateleadlst.size() > 0){
			update updateleadlst;
		}
    }

    public static Datetime getNextnBSDate(){
        Datetime now;
        Date nowDate = System.now().adddays(SLATime).date();
        
        now = SLATime == 0 ? System.now() :  Datetime.newInstance(nowDate.year(), nowDate.month(), nowDate.day(), 1, 0, 0);

        Datetime nextStart = BusinessHours.nextStartDate(callMeNowBusinessHours.id, now);
        return nextStart;
    }
}