@isTest
global class TMBUpdateContactNegativeMock implements WebServiceMock {
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
       
        System.debug(LoggingLevel.INFO, 'TMBServiceProxyMockImpl.doInvoke() - ' +
            '\n request: ' + request +
            '\n response: ' + response +
            '\n endpoint: ' + endpoint +
            '\n soapAction: ' + soapAction +
            '\n requestName: ' + requestName +
            '\n responseNS: ' + responseNS +
            '\n responseName: ' + responseName +
            '\n responseType: ' + responseType);
       
        TMBServiceProxy.ContactResultDTO ContactResult = new TMBServiceProxy.ContactResultDTO(); 
            ContactResult.status ='0001';
            ContactResult.totalrecord = '0';
            ContactResult.massage = 'updated fail';
     
                
        TMBServiceProxy.UpdateContactResponse_element UpdateElement = new TMBServiceProxy.UpdateContactResponse_element();
        UpdateElement.UpdateContactResult = ContactResult;
       response.put('response_x', UpdateElement); 
   } 
}