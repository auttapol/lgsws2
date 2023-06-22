@isTest
public class RTL_CvsAnalyticsDataServiceMockImpl implements WebServiceMock{
	public void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType) {
       
		System.debug(LoggingLevel.INFO, 'RTL_CvsAnalyticsDataServiceMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf RTL_CvsAnalyticsDataService.getCVSAnalyticsData_element) {
			RTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_element res = new RTL_CvsAnalyticsDataService.getCVSAnalyticsDataResponse_element();
			RTL_CvsAnalyticsDataService.CVSAnalyticsData item = new RTL_CvsAnalyticsDataService.CVSAnalyticsData();
			res.Result = item;
			system.debug('TMB: CvsAnalyticsDataSOAPMock res => ' + res);
			response.put('response_x', res);		
		
		}
	}
}