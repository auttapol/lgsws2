//Generated by wsdl2apex

public class AsyncRTL_DepositProductDetailsService {
    public class getProductDetailsResponse_elementFuture extends System.WebServiceCalloutFuture {
        public RTL_DepositProductDetailsService.DepositProductDetails getValue() {
            RTL_DepositProductDetailsService.getProductDetailsResponse_element response = (RTL_DepositProductDetailsService.getProductDetailsResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.Result;
        }
    }
    public class AsyncDepositProductDetailsSOAP {
        /*-------------------------------------------
         * Configurable End point via custom settings
         *--------------------------------------------*/
        AppConfig__c mc = AppConfig__c.getValues('WsOSC02');
        string tmpEndpoing = mc == null ? 'https://tmbcrmservices.tmbbank.com/uatservices/AccountPlantProxy.asmx' : mc.Value__c;
        public String endpoint_x = tmpEndpoing;
        public Map<String, String> inputHttpHeaders_x;
        public Map<String, String> outputHttpHeaders_x;
        AppConfig__c cer = AppConfig__c.getValues('MulesoftCert');
        string certName = cer == null ? 'retailtest_mulesoft' : cer.Value__c;
        public String clientCertName_x = certName; // wil change to 
        public String clientCert_x;
        public String clientCertPasswd_x = 'test';
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.tmbbank.com/DepositProductDetails/', 'RTL_DepositProductDetailsService'};
        public AsyncRTL_DepositProductDetailsService.getProductDetailsResponse_elementFuture beginGetProductDetails(System.Continuation continuation,String accountNumber,String productType,String CustomerRMID,String FIIdent) {
            RTL_DepositProductDetailsService.getProductDetails_element request_x = new RTL_DepositProductDetailsService.getProductDetails_element();
            request_x.accountNumber = accountNumber;
            request_x.productType = productType;
            request_x.CustomerRMID = CustomerRMID;
            request_x.FIIdent = FIIdent;
            return (AsyncRTL_DepositProductDetailsService.getProductDetailsResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRTL_DepositProductDetailsService.getProductDetailsResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://www.tmbbank.com/DepositProductDetails/getProductDetails',
              'http://www.tmbbank.com/DepositProductDetails/',
              'getProductDetails',
              'http://www.tmbbank.com/DepositProductDetails/',
              'getProductDetailsResponse',
              'RTL_DepositProductDetailsService.getProductDetailsResponse_element'}
            );
        }
    }
}