@isTest
public class SLOSSoapServiceMockImp implements WebServiceMock {
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

		System.debug(LoggingLevel.INFO, 'SLOSSoapServiceMockImp.doInvoke() - ' +
		             '\n request: ' + request +
		             '\n response: ' + response +
		             '\n endpoint: ' + endpoint +
		             '\n soapAction: ' + soapAction +
		             '\n requestName: ' + requestName +
		             '\n responseNS: ' + responseNS +
		             '\n responseName: ' + responseName +
		             '\n responseType: ' + responseType);

		if (request instanceOf SLOSSoapService.CreateOpportunityResponse_element) {

			SLOSSoapService.CreateOpportunityResponse_element res = new SLOSSoapService.CreateOpportunityResponse_element();
			SLOSSoapService.OpportunityResponse Result = new SLOSSoapService.OpportunityResponse();
			res.Result = Result;
			response.put('response_x',res);
		}else if (request instanceOf SLOSSoapService.FacilityInfos_element) {

			SLOSSoapService.FacilityInfos_element fres = new SLOSSoapService.FacilityInfos_element();
			SLOSSoapService.FacilityInfoRequest fResult = new SLOSSoapService.FacilityInfoRequest();
			fres.FacilityInfo[0] = fResult;
			response.put('response_x',fres);
		}
	}
}