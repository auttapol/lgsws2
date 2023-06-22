@isTest
public class RTL_CustomerProductHoldingsServiMockImpl implements WebServiceMock {
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
       
		System.debug(LoggingLevel.INFO, 'RTL_CustomerProductHoldingsServiMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf RTL_CustomerProductHoldingsService.getProductHoldings_element) {
			
			
			
		RTL_CustomerProductHoldingsService.getProductHoldingsResponse_element res = new RTL_CustomerProductHoldingsService.getProductHoldingsResponse_element();
		RTL_CustomerProductHoldingsService.CustomerProductHoldings item = new RTL_CustomerProductHoldingsService.CustomerProductHoldings();
		res.Result = item;
		system.debug('TMB: CustomerProductHoldingsSOAPMock res => ' + res);
		response.put('response_x', res);		
		
		}
	}
}