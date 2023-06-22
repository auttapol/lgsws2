@isTest
public without sharing class fnaOSCServiceUtility_Test {

    @isTest
    private static void Test_fnaOSCServiceUtility() {
        List<AppConfig__c> listAconfig = new List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        listAconfig.add(Aconfig);
        insert listAconfig;

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String customerId = listAccount[0].Id;
        String fnaActId = listFnaAct[0].Id;
        fnaOSCServiceUtility fnaOSC = new fnaOSCServiceUtility(customerId,fnaActId);
    }

    @isTest
    private static void Test_fnaOSCServiceUtility_2() {
        TestUtils.createAppConfig();

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = true;
        // productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;
        
        /*Test.startTest();
           
            fnaOSCServiceUtility ctrl = new fnaOSCServiceUtility(account.id,fnaActivity.id);

            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)ctrl.startCallCaseProductDeposit();
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1);
            system.assert(requests.get(ctrl.requestLabel) != null);
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
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
        Test.stopTest();*/

        /*System.currentPageReference().getParameters().put('itemNumber', '1');
        System.currentPageReference().getParameters().put('accountId', listAccount[0].Id);
        System.currentPageReference().getParameters().put('productType', 'DepositLoan');
        System.currentPageReference().getParameters().put('tabindex', '0');

        String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
        String responseBodyOSC16 = '{"status": {"code": "0000","description": "Success"},"bancassurances": null,"total": "0"}';

    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'Application/json');
        res.setBody(' Dummy responce in body  ');
        res.setStatusCode(200);

        String customerId = listAccount[0].Id;
        String fnaActId = listFnaAct[0].Id;

        fnaOSCServiceUtility customerProdList = new fnaOSCServiceUtility(customerId,fnaActId);

        customerProdList.fnaActivityId = listFnaAct[0].Id;
        customerProdList.caseProductBancassurance = null;
        customerProdList.productBAs = null;
        customerProdList.productAccounts = CaseAccountProduct.parseJsonToObj(responseBodyOSC14);

        customerProdList.startCallCaseProductDeposit();
        List<String> labels = new  List<String>();
        Object state;
        customerProdList.processResponseWsOSC14(labels,state);
        customerProdList.startCallCaseProductBA();
        customerProdList.processResponseWsOSC16(labels,state);

        // customerProdList.previousDepositAndLoan(); //List index out of bound -10
        // customerProdList.previousBA(); //List index out of bound -10
        // customerProdList.previousInvestment(); //List index out of bound -10
        */
    }
    
    @isTest
    private static void Test_fnaOSCServiceUtility_3() {
        TestUtils.createAppConfig();

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = true;
        listProductOffering.add(productOffering);
        insert listProductOffering;
        
        Test.startTest();
           
            fnaOSCServiceUtility ctrl = new fnaOSCServiceUtility(account.id,fnaActivity.id);
			
        	
            Continuation conti = (Continuation)ctrl.startCallCaseProductDeposit();
        	Continuation conti2 = (Continuation)ctrl.startCallCaseProductBA();
            
            /*Map<String, HttpRequest> requests = conti.getRequests();
       		String requestLabel = requests.keyset().iterator().next();
            
            HttpResponse response = new HttpResponse();
            String jsonResponse = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
            response.setStatusCode(200);
            response.setBody(jsonResponse);   
            Test.setContinuationResponse(requestLabel, response);*/
        	fnaOSCServiceUtility.StateInfo state = new fnaOSCServiceUtility.StateInfo('','','', system.now());
        	ctrl.processResponseWsOSC14(new List<String>(), state);
        	ctrl.processResponseWsOSC16(new List<String>(), state);
        	List<CaseProductNumberService.CaseProductWrapper> temp = ctrl.caseProductDepositAndLoanAll;
        	temp = ctrl.caseProductBancassurance;
        	temp = ctrl.caseProductBancassuranceAll;
        	CaseAccountProduct temp2 = ctrl.productAccounts;
        	CaseBAProduct temp3= ctrl.productBAs;
        	//Test.invokeContinuationMethod(ctrl, conti);
            //Object result = Test.invokeContinuationMethod(ctrl, conti);
        Test.stopTest();

    }
    
    
}