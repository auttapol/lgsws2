public class wsapiEcmCaseAttachmentMock implements WebServiceMock {
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
       
		System.debug(LoggingLevel.INFO, 'wsapiEcmClevelComMockImpl.doInvoke() - ' +
			'\n request: ' + request +
			'\n response: ' + response +
			'\n endpoint: ' + endpoint +
			'\n soapAction: ' + soapAction +
			'\n requestName: ' + requestName +
			'\n responseNS: ' + responseNS +
			'\n responseName: ' + responseName +
			'\n responseType: ' + responseType);

		if(request instanceOf wsapiEcmClevelCom.createDocument) {
			response.put( 'response_x', new wsapiEcmClevelCom.createDocumentResponse());
		}
		else if(request instanceOf wsapiEcmClevelCom.getContentStream) {
			wsapiEcmClevelCom.dmsContentStreamType response_stream = new wsapiEcmClevelCom.dmsContentStreamType();
			response_stream.length = 1234;
        	response_stream.mimeType = 'application/pdf';
        	response_stream.filename = 'testName';
        	response_stream.stream = 'testestestsetbase64dsfdstsgfmssdfmgsefgsems';

        	wsapiEcmClevelCom.getContentStreamResponse res = new wsapiEcmClevelCom.getContentStreamResponse();
        	res.contentStream = response_stream;
			response.put( 'response_x', res);
		}
		else if(request instanceOf wsapiEcmClevelCom.deleteObject) {
			wsapiEcmClevelCom.dmsSuccessType response_delete = new wsapiEcmClevelCom.dmsSuccessType();
			response_delete.objectId = '{08189612-3F45-4ED4-9607-FEE974C4F93D}';
        	response_delete.type_x = 'success';
        	response_delete.code = '200';
        	response_delete.description = 'Move documents into recycle bin success.';
        	wsapiEcmClevelCom.deleteObjectResponse res = new wsapiEcmClevelCom.deleteObjectResponse();
        	res.dmsSuccessType = response_delete;
			response.put( 'response_x', res);
		}
		//createDocumentResponse
	}
}