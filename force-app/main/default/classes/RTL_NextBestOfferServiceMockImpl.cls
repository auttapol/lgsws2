@isTest
public class RTL_NextBestOfferServiceMockImpl implements WebServiceMock {
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
       
		System.debug(LoggingLevel.INFO, 'RTL_NextBestOfferServiceMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf RTL_NextBestOffer.getNextBestOffer_element) {
			RTL_NextBestOffer.getNextBestOfferResponse_element res = new RTL_NextBestOffer.getNextBestOfferResponse_element();

			RTL_NextBestOffer.NextBestOffer Result = new RTL_NextBestOffer.NextBestOffer();
			res.Result = Result;

			response.put( 'response_x', res);
		}
	}
}