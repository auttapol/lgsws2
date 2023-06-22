trigger OnlineServiceLogTrigger on RTL_Online_Service_Log__c (before insert) {
	for(RTL_Online_Service_Log__c osl : Trigger.new){
        if(osl.Remark__c==null || osl.Remark__c ==''){
            if(RTL_CampaignUtil.remark!=null && RTL_CampaignUtil.remark!=''){
        		osl.Remark__c = RTL_CampaignUtil.remark+'\n'+RTL_CampaignUtil.service;
                RTL_CampaignUtil.remark = '';
            }
        }
    }
}