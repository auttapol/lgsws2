@isTest
private class SCSMessageAPIUtil_Test {
    @isTest(SeeAllData=true)
	static void testLeftPadZero() {
        String accountStatusValue = '12345';
        
        Integer accountType = SCSMessageAPIUtil.ACCOUNT_TYPE;
        String padMessage1 = SCSMessageAPIUtil.leftPadZero(accountStatusValue, accountType);
        System.assertEquals(accountType, padMessage1.length());

        Integer accountStatusType = SCSMessageAPIUtil.ACCOUNT_STATUS_TYPE;
        String padMessage2 = SCSMessageAPIUtil.leftPadZero(accountStatusValue, accountStatusType);
        System.assertEquals(accountStatusValue.length(), padMessage2.length());
    }
    
	@isTest(SeeAllData=true)
	static void testEncryptMessage() {     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'f69ec45f187e39b0e2f3a74d1c81676db45ad3d1eb7380c8e50e65626a64048f'));
        String request = '{"query":{"rm_id":"001100000000000000000012005267", "user_interface":"", "more_records":"N","search_keys":""}}';
        String encryptMessage = SCSMessageAPIUtil.encryptMessage(request, UserInfo.getSessionId());
   		String decryptMessage = SCSMessageAPIUtil.decryptMessage(encryptMessage, UserInfo.getSessionId());
        
        Uuid uuid = new Uuid();
        String uuidValue = uuid.getValue();
        SCSMessageAPIUtil.EncHeader encHeader = new SCSMessageAPIUtil.EncHeader(UserInfo.getName(), datetime.now().format('dd/MM/yyyy hh:mm:ss'), UserInfo.getUserName(), uuidValue);
        String header = JSON.serialize(encHeader);

        encHeader = SCSMessageAPIUtil.deserializeEncHeader(header);
    }
    
    @isTest(SeeAllData=true)
	static void testEncryptSummaryMessage() {      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, '1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2'));
        String request = '{"query":{"accountId":"11140019042000"}}';
        String encryptMessage = SCSMessageAPIUtil.encryptSummaryMessage(request, UserInfo.getSessionId());
        String decryptMessage = SCSMessageAPIUtil.decryptSummaryMessage(encryptMessage, UserInfo.getSessionId());
    }

    @isTest(SeeAllData=true)
	static void testDecryptMessageExcetion() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, '1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2'));
        String response = null;
        String decryptMessage = SCSMessageAPIUtil.decryptMessage(response, UserInfo.getSessionId());
    }
}