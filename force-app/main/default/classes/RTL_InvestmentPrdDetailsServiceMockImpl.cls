@isTest
public class RTL_InvestmentPrdDetailsServiceMockImpl implements WebServiceMock {
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

		System.debug(LoggingLevel.INFO, 'RTL_InvestmentPrdDetailsServiceMockImpl.doInvoke() - ' +
		             '\n request: ' + request +
		             '\n response: ' + response +
		             '\n endpoint: ' + endpoint +
		             '\n soapAction: ' + soapAction +
		             '\n requestName: ' + requestName +
		             '\n responseNS: ' + responseNS +
		             '\n responseName: ' + responseName +
		             '\n responseType: ' + responseType);

		RTL_InvestmentPrdDetailsService.getInvestmentProductDetailsResponse_element res =
		new RTL_InvestmentPrdDetailsService.getInvestmentProductDetailsResponse_element();
		RTL_InvestmentPrdDetailsService.InvestmentProductDetails Result = new RTL_InvestmentPrdDetailsService.InvestmentProductDetails();
		res.Result = Result;
		response.put('response_x', res);
	}
}