@isTest	
global class RTL_CampaignToHQ_tempuriOrgSOAPMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       	if(request instanceOf RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaign_element) {

       		RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element res = new RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element();

			//RTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_element res = new RTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_element();
			//RTL_CvsAnalyticsDataService.CVSAnalyticsData item = new RTL_CvsAnalyticsDataService.CVSAnalyticsData();
			//res.Result = item;
			system.debug('TMB: CampaignToHQMock res => ' + res);
			response.put('response_x', res);		
		
		}
   }
}