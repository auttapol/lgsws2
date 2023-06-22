@isTest
private class CallMeNowServiceTest {
	
	@isTest static void CallMeNowServiceTest() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":"1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.basicAuthCallout(dto,'testreferral');
		Test.stopTest();
	}

	@isTest static void CallMeNowServiceFailTest() {
		//set response in wrong format
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{code":"1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.basicAuthCallout(dto,'testreferral');
		Test.stopTest();
	}

	@isTest static void CallMeNowLeadServiceTest() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":"1","message":"success"}'));

		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.callOutCMNLead(dto,'Cisco');
		Test.stopTest();
	}

	@isTest static void CallMeNowServiceTestFail() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":1","message":"success"}'));
	
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			dto.request.setFirstName('Test First Name');
			dto.request.setLastName('Last Name');
			dto.request.setProductName('Home Loan');
			dto.request.setMobile('0881122993');
			dto.request.setCampaign('callmenow_sme');
			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.setVar2('var2');
			dto.request.setVar3('var3');
			dto.request.setVar4('var4');
			dto.request.setVar5('var5');
			dto.request.setVar6('var6');
			dto.request.setURL('http://www.google.co.th');
			dto.request.setChannel('Web');
			dto.request.setRequiredWrapUp('true');
			CallMeNowService.callOutCMNLead(dto,'Cisco');
		Test.stopTest();
	}
	
	
}