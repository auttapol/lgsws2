@isTest
private class CallMeNowDTOTest {
	
	@isTest static void testDTO() {
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			dto.request.setRequestId('001zf34002dxgQAA');
			System.assertEquals('001zf34002dxgQAA',dto.request.getRequestId());

			dto.request.setFirstName('Test First Name');
			System.assertEquals('Test First Name',dto.request.getFirstName());
			dto.request.getTruncateFirstName();

			dto.request.setLastName('Last Name');
			dto.request.getLastName();
			System.assertEquals('Last Name',dto.request.getLastName());
			dto.request.getTruncateLastName();

			dto.request.setProductName('Home Loan');
			dto.request.getProductName();
			System.assertEquals('Home Loan',dto.request.getProductName());
			dto.request.getTruncateProductName();

			dto.request.setMobile('0881122993');
			dto.request.getMobile();
			System.assertEquals('0881122993',dto.request.getMobile());

			dto.request.setCampaign('callmenow_sme');
			dto.request.getCampaign();
			System.assertEquals('callmenow_sme',dto.request.getCampaign());

			dto.request.setDropLeadDateTime('2017:02:02 12:12');
			dto.request.getDropLeadDateTime();
			System.assertEquals('2017:02:02 12:12',dto.request.getDropLeadDateTime());

			dto.request.setVar1('บัญชีธุรกิจ');
			dto.request.getVar1();
			System.assertEquals('บัญชีธุรกิจ',dto.request.getVar1());
			dto.request.getTruncateVar1();

			dto.request.setVar2('var2');
			dto.request.getVar2();
			System.assertEquals('var2',dto.request.getVar2());

			dto.request.setVar3('var3');
			dto.request.getVar3();
			System.assertEquals('var3',dto.request.getVar3());

			dto.request.setVar4('var4');
			dto.request.getVar4();
			System.assertEquals('var4',dto.request.getVar4());

			dto.request.setVar5('var5');
			dto.request.getVar5();
			System.assertEquals('var5',dto.request.getVar5());

			dto.request.setVar6('var6');
			dto.request.getVar6();
			System.assertEquals('var6',dto.request.getVar6());

			dto.request.setURL('http://www.google.co.th');
			dto.request.getURL();
			System.assertEquals('http://www.google.co.th',dto.request.getURL());
			dto.request.getTruncateURL();

			dto.request.setChannel('Web');
			dto.request.getChannel();
			System.assertEquals('Web',dto.request.getChannel());
			dto.request.getTruncateChannel();

			dto.request.setRequiredWrapUp('true');
			dto.request.getRequiredWrapUp();
			System.assertEquals('true',dto.request.getRequiredWrapUp());

			String a = dto.response.code;
			String b = dto.response.message;
			String c = dto.response.rawResponse;
			String d = dto.response.status;

			dto.generateJSONContent();
		Test.stopTest();
	}

	@isTest static void testDTOtruncate() {
		Test.startTest();
			CallMeNowDTO dto = new CallMeNowDTO();
			//set first name length to 116 characters
			dto.request.setFirstName('FirstNameAAAAAAAAAAAAAAAAAAAAAAAAAA');
			System.assertEquals('FirstNameAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateFirstName());

			dto.request.setLastName('LastNameAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			System.assertEquals('LastNameAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateLastName());

			dto.request.setProductName('HomeLoanAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			dto.request.getTruncateProductName();
			System.assertEquals('HomeLoanAAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateProductName());

			dto.request.setVar1('บัญชีธุรกิจLoanAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			dto.request.getTruncateVar1();
			System.assertEquals('บัญชีธุรกิจLoanAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateVar1());

			dto.request.setURL('http://www.google.co.thAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			System.assertEquals('http://www.google.co.thAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateURL());

			dto.request.setChannel('WebAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			System.assertEquals('WebAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',dto.request.getTruncateChannel());
		Test.stopTest();
	}

	
}