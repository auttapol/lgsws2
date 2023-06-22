//Generated by wsdl2apex

public class AsyncRTL_CampaignToHQ_tempuriOrgSOAP {
    public class manageCampaignResponse_elementFuture extends System.WebServiceCalloutFuture {
        public RTL_CampaignToHQ_schemasDatacontractSOAP.Result getValue() {
            RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element response = (RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.manageCampaignResult;
        }
    }
    public class AsyncBasicHttpsBinding_IService {
        public String endpoint_x = 'https://automate-campaign-sit.tmbbank.local/webservice/CampaignService.svc';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'RTL_CampaignToHQ_tempuriOrgSOAP', 'campaign', 'RTL_CampaingToHQ_CampaignServiceSOAP', 'http://schemas.datacontract.org/2004/07/', 'RTL_CampaignToHQ_schemasDatacontractSOAP', 'http://schemas.microsoft.com/2003/10/Serialization/', 'RTL_CampaignToHQ_schemasMicrosoftSOAP'};
        public AsyncRTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_elementFuture beginManageCampaign(System.Continuation continuation,RTL_CampaingToHQ_CampaignServiceSOAP.Campaign value) {
            RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaign_element request_x = new RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaign_element();
            request_x.value = value;
            return (AsyncRTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://tempuri.org/IService/manageCampaign',
              'http://tempuri.org/',
              'manageCampaign',
              'http://tempuri.org/',
              'manageCampaignResponse',
              'RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element'}
            );
        }
    }
}