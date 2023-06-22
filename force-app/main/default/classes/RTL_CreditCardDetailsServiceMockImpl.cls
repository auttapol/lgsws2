@isTest
public class RTL_CreditCardDetailsServiceMockImpl implements WebServiceMock {
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
       
		System.debug(LoggingLevel.INFO, 'RTL_CreditCardDetailsServiceMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf RTL_CreditCardDetailsService.getCreditCardDetails_element) {
			RTL_CreditCardDetailsService.getCreditCardDetailsResponse_element res = new RTL_CreditCardDetailsService.getCreditCardDetailsResponse_element();

			RTL_CreditCardDetailsService.CreditCardDetails Result = new RTL_CreditCardDetailsService.CreditCardDetails();
			res.Result = Result;

			response.put( 'response_x', res);
		}
	}
}