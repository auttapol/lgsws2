@isTest
private class RTL_CampaignToHQ_tempuriOrgSOAPTest {
	
	@isTest static void testclass() {
		Test.startTest();
		RTL_CampaingToHQ_CampaignServiceSOAP.Campaign value;
		String x = null;
		Test.setMock(WebServiceMock.class, new RTL_CampaignToHQ_tempuriOrgSOAPMock());

		RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaign_element manageCampaigne = new RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaign_element();
		RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element manageCampaignResponsee = new RTL_CampaignToHQ_tempuriOrgSOAP.manageCampaignResponse_element();
		RTL_CampaignToHQ_tempuriOrgSOAP.BasicHttpsBinding_IService BasicHttpsBindingi = new RTL_CampaignToHQ_tempuriOrgSOAP.BasicHttpsBinding_IService();
		BasicHttpsBindingi.manageCampaign(value);
		Test.stopTest();

	}	
	
}