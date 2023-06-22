global without sharing class SLOSServiceBroker {
	@testVisible
	private static ISLOSService mockService;
	global static ISLOSService newinstance() {
		if (null != mockService) return mockService;
		return (ISLOSService) Application.Services.newInstance(SLOSServiceBroker.class);
	}
	global static SLOSContext.SLOSRespond sendRequest(SLOSContext.SLOSRequest slosReq) {
		SLOSContext.SLOSRespond slosresp;
		try {
			slosresp = newinstance().sendRequest(slosReq);
		} catch (Exception ex) {
			slosresp = new SLOSContext.SLOSRespond();
			slosresp.ErrorCode = 'SF001';
			slosresp.Status = false;
			slosresp.AppRefNo = '';
			slosresp.Message = ex.getMessage();
		}
		return slosresp;
	}
	global interface ISLOSService {
		SLOSContext.SLOSRespond sendRequest(SLOSContext.SLOSRequest slosReq);
	}
}