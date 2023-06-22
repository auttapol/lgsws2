@isTest
private class TestUrlHelper {

	@isTest
	private static void CodeCoverOnly() {

		string url1 = UrlHelper.protocolAndHost;
		string url2 = Url.getSalesforceBaseUrl().toExternalForm();
		System.assertEquals(url1, url2, 'not same url');


		string en1 = UrlHelper.encryptParams('pommatt');
		string dc1 = UrlHelper.decryptParams(en1);

		System.assertEquals('pommatt' , dc1);


	}

}