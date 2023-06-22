@isTest
private class CustomerProductHoldingsAndNBOCtrlTest {

	static List<Account> acctList;
	static Contact contact;
	static RTL_NBO_History_Product__c nboProduct;
	static List<RTL_NBO_History__c> nboHistoryList;
	static List<RTL_product_master__c> productList;
	static Campaign childCampaign;
    static {
		TestUtils.createAppConfig();


        //Add for Test NBO to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();


        //query campaign record type
        RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
		//create brnach user
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;
		//insert account
		acctList = RTL_TestUtility.createAccounts(1,true);
		
        //insert contact
        contact = RTL_TestUtility.createContacts(acctList[0]);
		contact.TMB_Customer_ID__c = acctList[0].TMB_Customer_ID_PE__c;
		contact.OwnerId = u.id;
		insert contact;
		
        //insert master campaign
        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB',u
        	);
		insert masterC;

        //insert child campaign
		childCampaign = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childCampaign;

        //insert retail product
		productList = createRetailProducts();

	}

    static testmethod void testOSC12Success() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '1:Deposit';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{'+
                        '"mule_info": {'+
                        '"log_id": "66620702-25c2-4852-9514-8b21ca1fc699",'+
                        '"message": ['+
                            // '"PartyAcctRelInq|javax.script.ScriptException: java.lang.Exception: rm id not found",'+
                            '"InsurancePolicyListCRMInq|javax.script.ScriptException: java.lang.NullPointerException: Cannot invoke method reverse() on null object"'+
                        //    '"OSC08|com.mulesoft.weave.mule.exception.WeaveExecutionException: Exception while executing: \t(payload.ns0#getNextBestOfferResponse.Result.NextBestOfferDetails.*NextBestOfferDetail map ((nextBestOfferDetail , indexOfNextBestOfferDetail) -> { Cannot coerce a :null to a :array"'+
                        '],'+
                        '"status": "SUCCESS"'+
                        '},'+
                        '"data": {'+
                            '"Deposit": {'+
                            '"Transactional": {'+
                            '  "All_Free": "0:2;D201710011:1;R17B0939170500132483",'+
                            '  "No_Fixed": "1:0:1;R17B0939170500132483",'+
                            '  "Others": "0:0:0"'+
                            '},'+
                            '"Non-Transactional": {'+
                            '  "Others": "1:0:0"'+
                            '}'+
                            '},   '+                 
                            '"Credit_Card_&_RDC": {'+
                            '  "Credit_Cards": "2:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Loan": {'+
                            '  "Secured_Loan": "0:1;DMBZLAZ56D0000063718:1;DMBZLAZ56D0000063718",'+
                            ' "Personal_Loan": "5:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Bancassurance": {'+
                            '  "Life": "-1:0:0",'+
                            '  "Non_Life": "0:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Investment": "20:1;DMBZLAZ56D0000063718:0"'+
                        '}'+
                        '}';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            // Verify that the controller's result variable
            //   is set to the mock response.
            //System.assertEquals('Mock response body', controller.result);
            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            
            ctrl.currentOfferMap.get('All Free').campaignNBO.getNBOFlag();
            ctrl.currentOfferMap.get('All Free').campaignNBO.getNBOId();
        Test.stopTest();
	}
	
	static testmethod void testOSC12PartialSuccess() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '1:Deposit';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{'+
                        '"mule_info": {'+
                        '"log_id": "66620702-25c2-4852-9514-8b21ca1fc699",'+
                        '"message": ['+
                            // '"PartyAcctRelInq|javax.script.ScriptException: java.lang.Exception: rm id not found",'+
                            '"InsurancePolicyListCRMInq|javax.script.ScriptException: java.lang.NullPointerException: Cannot invoke method reverse() on null object"'+
                        //    '"OSC08|com.mulesoft.weave.mule.exception.WeaveExecutionException: Exception while executing: \t(payload.ns0#getNextBestOfferResponse.Result.NextBestOfferDetails.*NextBestOfferDetail map ((nextBestOfferDetail , indexOfNextBestOfferDetail) -> { Cannot coerce a :null to a :array"'+
                        '],'+
                        '"status": "PARTIAL SUCCESS"'+
                        '},'+
                        '"data": {'+
                            '"Deposit": {'+
                            '"Transactional": {'+
                            '  "All_Free": "0:2;D201710011:1;R17B0939170500132483",'+
                            '  "No_Fixed": "1:0:1;R17B0939170500132483",'+
                            '  "Others": "0:0:0"'+
                            '},'+
                            '"Non-Transactional": {'+
                            '  "Others": "1:0:0"'+
                            '}'+
                            '},   '+                 
                            '"Credit_Card_&_RDC": {'+
                            '  "Credit_Cards": "2:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Loan": {'+
                            '  "Secured_Loan": "0:1;DMBZLAZ56D0000063718:1;DMBZLAZ56D0000063718",'+
                            ' "Personal_Loan": "5:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Bancassurance": {'+
                            '  "Life": "-1:0:0",'+
                            '  "Non_Life": "0:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Investment": "20:1;DMBZLAZ56D0000063718:0"'+
                        '}'+
                        '}';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            // Verify that the controller's result variable
            //   is set to the mock response.
            //System.assertEquals('Mock response body', controller.result);
            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            CustomerProductHoldingsAndNBOCtrl.checkNBOExists('2345652356543');
            CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('001p000000CKy8AAD1','D201710011');
        Test.stopTest();
	}

    static testmethod void testOSC12PartialSuccessNONBO() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '1:Deposit';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{'+
                        '"mule_info": {'+
                        '"log_id": "66620702-25c2-4852-9514-8b21ca1fc699",'+
                        '"message": ['+           
                            '"OSC08|Status ERROR ERR004"'+
                        '],'+
                        '"status": "PARTIAL SUCCESS"'+
                        '},'+
                        '"data": {'+
                            '"Deposit": {'+
                            '"Transactional": {'+
                            '  "All_Free": "0:2;D201710011:1;R17B0939170500132483",'+
                            '  "No_Fixed": "1:0:1;R17B0939170500132483",'+
                            '  "Others": "0:0:0"'+
                            '},'+
                            '"Non-Transactional": {'+
                            '  "Others": "1:0:0"'+
                            '}'+
                            '},   '+                 
                            '"Credit_Card_&_RDC": {'+
                            '  "Credit_Cards": "2:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Loan": {'+
                            '  "Secured_Loan": "0:1;DMBZLAZ56D0000063718:1;DMBZLAZ56D0000063718",'+
                            ' "Personal_Loan": "5:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Bancassurance": {'+
                            '  "Life": "-1:0:0",'+
                            '  "Non_Life": "0:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Investment": "20:1;DMBZLAZ56D0000063718:0"'+
                        '}'+
                        '}';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            // Verify that the controller's result variable
            //   is set to the mock response.
            //System.assertEquals('Mock response body', controller.result);
            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            CustomerProductHoldingsAndNBOCtrl.checkNBOExists('2345652356543');
            CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('001p000000CKy8AAD1','D201710011');
        Test.stopTest();
	}

    static testmethod void testOSC12ServiceError() {
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{'+
                        '"mule_info": {'+
                        '"log_id": "66620702-25c2-4852-9514-8b21ca1fc699",'+
                        '"message": ['+
                            // '"PartyAcctRelInq|javax.script.ScriptException: java.lang.Exception: rm id not found",'+
                            '"InsurancePolicyListCRMInq|javax.script.ScriptException: java.lang.NullPointerException: Cannot invoke method reverse() on null object"'+
                        //    '"OSC08|com.mulesoft.weave.mule.exception.WeaveExecutionException: Exception while executing: \t(payload.ns0#getNextBestOfferResponse.Result.NextBestOfferDetails.*NextBestOfferDetail map ((nextBestOfferDetail , indexOfNextBestOfferDetail) -> { Cannot coerce a :null to a :array"'+
                        '],'+
                        '"status": "ERROR"'+
                        '},'+
                        '"data": {'+
                            '"Deposit": {'+
                            '"Transactional": {'+
                            '  "All_Free": "0:2;D201710011:1;R17B0939170500132483",'+
                            '  "No_Fixed": "1:0:1;R17B0939170500132483",'+
                            '  "Others": "0:0:0"'+
                            '},'+
                            '"Non-Transactional": {'+
                            '  "Others": "1:0:0"'+
                            '}'+
                            '},   '+                 
                            '"Credit_Card_&_RDC": {'+
                            '  "Credit_Cards": "2:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Loan": {'+
                            '  "Secured_Loan": "0:1;DMBZLAZ56D0000063718:1;DMBZLAZ56D0000063718",'+
                            ' "Personal_Loan": "5:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Bancassurance": {'+
                            '  "Life": "-1:0:0",'+
                            '  "Non_Life": "0:1;DMBZLAZ56D0000063718:0"'+
                            '},'+
                            '"Investment": "20:1;DMBZLAZ56D0000063718:0"'+
                        '}'+
                        '}';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            // Verify that the controller's result variable
            //   is set to the mock response.
            //System.assertEquals('Mock response body', controller.result);
            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            CustomerProductHoldingsAndNBOCtrl.checkNBOExists('2345652356543');
            CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('001p000000CKy8AAD1','D201710011');
        Test.stopTest();
	}

    static testmethod void testOSC12TimeoutFail() {
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '';
            response.setStatusCode(2000);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            // Verify that the controller's result variable
            //   is set to the mock response.
            //System.assertEquals('Mock response body', controller.result);
            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            CustomerProductHoldingsAndNBOCtrl.checkNBOExists('2345652356543');
            CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('001p000000CKy8AAD1','D201710011');
        Test.stopTest();
	}

    static testmethod void testOSC12ResponseFail() {
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '';
            response.setStatusCode(2001);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation     
            Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);

            createOpportunity(acctList[0]);
            ctrl.getLastOffer();
            
        Test.stopTest();
	}

    static testmethod void testOSC12NoResponseFail() {
		Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallProductOfferService();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response;  
            // Set the fake response for the continuation     
            //Test.setContinuationResponse(ctrl.requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);
            createOpportunity(acctList[0]);
        Test.stopTest();
	}
	
	static testmethod void testOSC08Success() {
		// nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(20,acctList[0].id,'Investment',true);
        // nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        // nboProduct.RTL_Status__c = 'Pending';
        // update nboProduct;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();
            ctrl.NBOId = '001p000000CKy8AAD';
            
            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startRequest();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '<SOAP:Envelope'
                    + ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
                    + '<SOAP:Body>'
                    + '<ns2:getNextBestOfferResponse '
                    + 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
                    + '<Result>'
                    + '<NextBestOfferDetails>'
                    + '<Status>SUCCESS</Status>'
                    + '		<NextBestOfferDetail>'
                    + '			<NboId>001p000000CKy8AAD</NboId>'
                    + '			<CampaignCode>R1205975</CampaignCode>'
                    + '			<CampaignName>R1205975</CampaignName>'
                    + '			<ValidFrom>2016/08/01</ValidFrom>'
                    + '			<ContactDate>2016/08/01</ContactDate>'
                    + '			<CustomerId>'+acctList[0].TMB_Customer_ID_PE__c+'</CustomerId>'
                    + '		</NextBestOfferDetail>'             
                    + '</NextBestOfferDetails>'
                    + '<NextBestOfferProducts>'
                    + '		<Status>SUCCESS</Status>'
                    + '		<NextBestOfferProduct>'
                    + '		<NboId>001p000000CKy8AAD</NboId>'
                    + '		<NboProductId>R1205975032423</NboProductId>'
                    + '		<Product>All Free</Product>'
                    + '		</NextBestOfferProduct>'
                    + '</NextBestOfferProducts>'
                    + '<Status>SUCCESS</Status>'
                    + '</Result>' 
                    + '</ns2:getNextBestOfferResponse>' 
                    + '</SOAP:Body>'
                    + '</SOAP:Envelope>';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation    
            String requestLabel = requests.keyset().iterator().next(); 
            Test.setContinuationResponse(requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);

            ctrl.nboSeq = new List<String> ();
            ctrl.result = '';
        Test.stopTest();
	}

    static testmethod void testOSC08SuccessInvalidNBO() {
		// nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(20,acctList[0].id,'Investment',true);
        // nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        // nboProduct.RTL_Status__c = 'Pending';
        // update nboProduct;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();
            ctrl.NBOId = '001p000000CKy8AAD';
            
            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startRequest();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            Account a = new Account();
            // Perform mock callout
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '<SOAP:Envelope'
                    + ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
                    + '<SOAP:Body>'
                    + '<ns2:getNextBestOfferResponse '
                    + 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
                    + '<Result>'
                    + '<NextBestOfferDetails>'
                    + '<Status>SUCCESS</Status>'
                    + '		<NextBestOfferDetail>'
                    + '			<NboId>001p000000CKy8AAD</NboId>'
                    + '			<CampaignCode>R1205975</CampaignCode>'
                    + '			<CampaignName>R1205975</CampaignName>'
                    + '			<ValidFrom>2016/08/01</ValidFrom>'
                    + '			<ContactDate>2016/08/01</ContactDate>'
                    + '			<CustomerId>'+acctList[0].TMB_Customer_ID_PE__c+'</CustomerId>'
                    + '		</NextBestOfferDetail>'             
                    + '</NextBestOfferDetails>'
                    + '<NextBestOfferProducts>'
                    + '		<Status>SUCCESS</Status>'
                    + '		<NextBestOfferProduct>'
                    + '		<NboId>001p000000CKy8AAD</NboId>'
                    + '		<NboProductId>R1205975032423</NboProductId>'
                    + '		<Product>All Free Deposit</Product>'
                    + '		</NextBestOfferProduct>'
                    + '</NextBestOfferProducts>'
                    + '<Status>SUCCESS</Status>'
                    + '</Result>' 
                    + '</ns2:getNextBestOfferResponse>' 
                    + '</SOAP:Body>'
                    + '</SOAP:Envelope>';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation    
            String requestLabel = requests.keyset().iterator().next(); 
            Test.setContinuationResponse(requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);

            ctrl.nboSeq = new List<String> ();
            ctrl.result = '';
        Test.stopTest();
	}

    static testmethod void testOSC08ServiceError() {
		nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(20,acctList[0].id,'Investment',true);
        nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        nboProduct.RTL_Status__c = 'Pending';
        update nboProduct;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startRequest();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '<SOAP:Envelope'
                    + ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
                    + '<SOAP:Body>'
                    + '<ns2:getNextBestOfferResponse '
                    + 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
                    + '<Result>'
                    + '<Status>ERROR</Status>'
                    + '</Result>' 
                    + '</ns2:getNextBestOfferResponse>' 
                    + '</SOAP:Body>'
                    + '</SOAP:Envelope>';
            response.setStatusCode(2001);
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation    
            String requestLabel = requests.keyset().iterator().next(); 
            Test.setContinuationResponse(requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);

            ctrl.getLastOffer();
            Test.stopTest();
    }

    static testmethod void testOSC08ReturnFail() {
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startRequest();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse =
                    + '</Result>' 
                    + '</ns2:getNextBestOfferResponse>' 
                    + '</SOAP:Body>'
                    + '</SOAP:Envelope>';
            response.setBody(jsonResponse);   
            // Set the fake response for the continuation    
            String requestLabel = requests.keyset().iterator().next(); 
            Test.setContinuationResponse(requestLabel, response);
            // Invoke callback method
            Object result = Test.invokeContinuationMethod(ctrl, conti);
            // result is the return value of the callback
            System.assertEquals(null, result);

            ctrl.getLastOffer();
            Test.stopTest();
    }

    static testmethod void testLastOfferProductName() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '3:All Free';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';

        insert cm1;

        createOpportunity(acctList[0]);
        
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            ctrl.getLastOffer();
        Test.stopTest();
	}
    
    static testmethod void testLastOfferProductSubGroup() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '2:Credit Cards';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            ctrl.getLastOffer();
            ctrl.lastOfferMap.get('Credit Cards').getLastModifiedDate();
        Test.stopTest();
	}

    static testmethod void testLastOfferBAProductSubGroup() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '2:Life Insurance';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            ctrl.getLastOffer();
        Test.stopTest();
	}

    static testmethod void testLastOfferProductGroup() {
        CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '1:Investment';
        cm1.RTL_OfferResult_Product_1__c = 'Not Interested';
        cm1.RTL_Reason_1__c = 'Others';
        cm1.RTL_Memo__c = 'test only';
        insert cm1;
		
        Test.startTest();
            PageReference pageRef = Page.CustomerProductHoldingsAndNBO;
            pageRef.getParameters().put('Id', acctList[0].id);
            Test.setCurrentPage(pageRef);

            CustomerProductHoldingsAndNBOCtrl ctrl = new CustomerProductHoldingsAndNBOCtrl();

            ctrl.getLastOffer();
        Test.stopTest();
	}

    static testmethod void testNBOExists() {
		nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Investment',true);
        Test.startTest();
            String url = CustomerProductHoldingsAndNBOCtrl.checkNBOExists('001p000000CKy8AAD0');
            System.assertEquals('/apex/RTL_NBODetailView?p=',url);
        Test.stopTest();
	}

    static testmethod void testNBONotExists() {
		
        Test.startTest();
            String url = CustomerProductHoldingsAndNBOCtrl.checkNBOExists('2345652356543');
            System.assertEquals(null,url);
        Test.stopTest();
	}

    static testmethod void testCampaignMemberExists() {
		CampaignMember cm1 = new CampaignMember();
        cm1.ContactId = contact.id;
        cm1.CampaignId = childCampaign.id;
        cm1.RTL_Products_Offer_String__c = '1:Investment';
        insert cm1;
		
        Test.startTest();
            String campaignMemberId = CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('D201710011','001p000000CKy8AAD1');
            System.assertEquals(cm1.id,campaignMemberId);
        Test.stopTest();
	}

    static testmethod void testCampaignMemberNotExists() {
		
        Test.startTest();
            String campaignMemberId = CustomerProductHoldingsAndNBOCtrl.checkCampaignMemberExists('001p000000CKy8AAD1','D201710011');
            System.assertEquals(null,campaignMemberId);
        Test.stopTest();
	}

	static List<RTL_product_master__c>  createRetailProducts(){
        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        
        RTL_product_master__c product = new RTL_product_master__c(Name='All Free', Product_Group__c='Deposit', Product_Sub_group__c='Transactional',Active__c=true);
        productList.add(product);
        product = new RTL_product_master__c(Name='TMB Wealthy Link', Product_Group__c='Bancassurance', Product_Sub_group__c='LIFE INSURANCE',Active__c=true);
        productList.add(product);
        product = new RTL_product_master__c(Name='Asset Allocation Medium Term', Product_Group__c='Investment', Product_Sub_group__c='NON MM',Active__c=true);
        productList.add(product);
        product = new RTL_product_master__c(Name='So Fast', Product_Group__c='Credit Card & RDC', Product_Sub_group__c='Credit Cards',Active__c=true);
        productList.add(product);
		insert productList;
        return productList;
	}

	public static List<Opportunity> createOpportunity(Account acct) {
        List<Opportunity> opptList = new List<Opportunity>();
        Opportunity o;
        Id opptyDepositRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Deposit').getRecordTypeId();
        Id opptyBARecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Bancassurance').getRecordTypeId();
        Id opptyInvestmentRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Investment').getRecordTypeId();
        Id opptyCardRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Card and RDC').getRecordTypeId();
            o = new Opportunity(Name='II-OPP-All Free',
                                StageName = 'Open',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
								RTL_Product_Name__c = productList[0].id,
                                RecordTypeId=opptyDepositRecordTypeId
                               );
            opptList.add(o);
            o = new Opportunity(Name='II-OPP-Wealthy Link',
                                StageName = 'Open',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
								RTL_Product_Name__c = productList[1].id,
                                RecordTypeId=opptyBARecordTypeId
                               );
            opptList.add(o);
            o = new Opportunity(Name='II-OPP-Medium Term',
                                StageName = 'Open',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
								RTL_Product_Name__c = productList[2].id,
                                RecordTypeId=opptyInvestmentRecordTypeId
                               );
            opptList.add(o);
            o = new Opportunity(Name='II-OPP-So Fast',
                                StageName = 'Open',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
								RTL_Product_Name__c = productList[3].id,
                                RecordTypeId=opptyCardRecordTypeId
                               );
            opptList.add(o);
        
		insert opptList;
        return opptList;
    }  
	
}