@isTest
public without sharing class fnaAvatarDetailCtrl_Test {

    @isTest
    private static void Test_stampOffSet() {
        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String fnaActivityId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String responseBodyOSC14 = '{"GetCustomerAccountResponse": {"DepositAccounts":{"DepositAccount":[{"Status":"SUCCESS","AccountNumber":"02473011316002","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-05-05","AccountStatus":"Active | à¸›à¸à¸•à¸´ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"}]},' +
            '"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015405889701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},' +
            '"Status":{"StatusCode":200,"StatusDesc":"success"}}';
        String responseBodyOSC16 = '{"GetBancassuranceAccountResponse":{"InsurancePolicyListCRMInqResponse":{"InsurancePolicyListCRMInqResult":{"Message":{"REQUEST_NO":"1","STATUS_CODE":"0000","STATUS_NAME":"Success"},"DataSets":[{"POLICY_NO":"T00004644","POLICY_NAME":"TMB Smart Life 15/8","STATUS":"Active","COMPANY_NAME":"FWD Life Insurance",'+
        '"PRODUCT_GROUP":"LIFE INSURANCE","EFFECTIVE_DATE":"26/05/2008","EXPIRY_DATE":"26/05/2023","SUM_INSURE":"100000","INSURE_TYPE":"En05","EMP_ID":"14487","NEXT_PAYMENT_DATE":"","NEXT_INTERIM_DATE":"16/05/2018","NEXT_INTERIM_AMOUNT":"5000","TOTAL_PREMIUM_PAID":"25700","PAYMODE3":"01","PAYMENT_TYPE":"Annual",'+
        '"PAYMENT_TERM":" of 8","PAYMENT_DATE":"","PAYMENT_METHOD":"Cheque","PAYMENT_FREQUENCY_AMOUNT":"25700","PREMIUM":"25700","INTERIM_PAY_AMOUNT":"","BENEFICIARY":" ??????????????","BENEFICIARY_RELATION":"à¸„à¸¹à¹ˆà¸ªà¸¡à¸£à¸ª,à¸™à¹‰à¸­à¸‡","INSURED_ADDRESS":"","INSURED_STREET":"","INSURED_DISTRICT":"","INSURED_AMPHUR":"",'+
            '"INSURED_PROVINCE":"","INSURED_POSTCODE":"","CAR_MODEL":"","CARBRAND":"","REGISTERPLATENUMBER":"","YEAR_OF_MANUFACTURE":""}]}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}';
        String responseBodyGetCardsBalance = '{"status":{"status_code":0},"rm_id": "001100000000000000000000051187","credit_card":[' + 
        '{"card_id":"533969XXXXXX1528","account_id":"0000000050076190136001528","product_id":"MBKDWD","card_points":{"point_earned":0,"point_used":0,"point_available":0,"point_remain":0,"expiry_points":0,"expiry_date":""},'+
        '"card_status":{"stop_code":1,"stop_code_desc":"24 - Account Closed","account_status":"000","account_agree_status":"010","activated_date":"2020-05-04","block_code":"CUS","previous_expiry_date":"0000","application_type":"B","card_ploan_flag":"1","card_active_flag":"INACTIVE","card_role":"PRI"},'+
        '"card_balances":{"current_balance":0,"ledger_balance":0,"available_cash_advance":250000,"available_credit_allowance":500000,"last_payment_amount":0,"last_payment_date":"","eptb_installment_available":0,"epai_installment_available":0,"balance_credit_limit":{"total":500000,"available_to_transfer":250000,"current":500000},"balance_credit_line":{"total":500000,"available":500000,"current":500000}}}]}';
        // String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": null,"creditCards": null,"loans": null,"bancassurances": null,"investments": null,"treasuries": [],"tradeFinances": []}}';
        // String responseBodyOSC16 = '{"status": {"code": "0000","description": "Success"},"bancassurances": null,"total": "0"}';

        fnaAvatarDetailCtrl.stampOffSet(fnaActivityId, responseBodyOSC14, responseBodyOSC16, responseBodyGetCardsBalance);
    }

    @isTest
    private static void Test_callServiceOSC14() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

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
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        String fnaActivityId = UrlHelper.encryptParams(listFnaAct[0].Id);

        fnaAvatarDetailCtrl.callServiceOSC14(fnaActivityId);
    }

    @isTest
    private static void Test_processResponseWsOSC14() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

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

        Datetime mockDateTime = Datetime.now();
        // String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": null,"creditCards": null,"loans": null,"bancassurances": null,"investments": null,"treasuries": [],"tradeFinances": []}}';
        String responseBodyOSC14 = '{"GetCustomerAccountResponse": {"DepositAccounts":{"DepositAccount":[{"Status":"SUCCESS","AccountNumber":"02473011316002","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-05-05","AccountStatus":"Active | à¸›à¸à¸•à¸´ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"}]},' +
            '"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015405889701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},' +
            '"Status":{"StatusCode":200,"StatusDesc":"success"}}';
        List<String> labels = new List<String>();
        String fnaActivityId = listFnaAct[0].Id;
        String accountId = listAccount[0].Id;
        fnaOSCServiceUtility.StateInfo state = new fnaOSCServiceUtility.StateInfo(fnaActivityId,accountId,responseBodyOSC14,mockDateTime); 

        // fnaAvatarDetailCtrl.processResponseWsOSC14(labels, state);
        fnaAvatarDetailCtrl.processResponseCaseProductDeposit(labels, state);
    }

    @isTest
    private static void Test_callServiceOSC16() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

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
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        String fnaActivityId = UrlHelper.encryptParams(listFnaAct[0].Id);

        fnaAvatarDetailCtrl.callServiceOSC16(fnaActivityId);
    }
    
    @isTest
    private static void Test_processResponseWsOSC16() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

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

        Datetime mockDateTime = Datetime.now();
        // String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": null,"creditCards": null,"loans": null,"bancassurances": null,"investments": null,"treasuries": [],"tradeFinances": []}}';
        String responseBodyOSC14 = '{"GetBancassuranceAccountResponse":{"InsurancePolicyListCRMInqResponse":{"InsurancePolicyListCRMInqResult":{"Message":{"REQUEST_NO":"1","STATUS_CODE":"0000","STATUS_NAME":"Success"},"DataSets":[{"POLICY_NO":"T00004644","POLICY_NAME":"TMB Smart Life 15/8","STATUS":"Active","COMPANY_NAME":"FWD Life Insurance",'+
        '"PRODUCT_GROUP":"LIFE INSURANCE","EFFECTIVE_DATE":"26/05/2008","EXPIRY_DATE":"26/05/2023","SUM_INSURE":"100000","INSURE_TYPE":"En05","EMP_ID":"14487","NEXT_PAYMENT_DATE":"","NEXT_INTERIM_DATE":"16/05/2018","NEXT_INTERIM_AMOUNT":"5000","TOTAL_PREMIUM_PAID":"25700","PAYMODE3":"01","PAYMENT_TYPE":"Annual",'+
        '"PAYMENT_TERM":" of 8","PAYMENT_DATE":"","PAYMENT_METHOD":"Cheque","PAYMENT_FREQUENCY_AMOUNT":"25700","PREMIUM":"25700","INTERIM_PAY_AMOUNT":"","BENEFICIARY":" ??????????????","BENEFICIARY_RELATION":"à¸„à¸¹à¹ˆà¸ªà¸¡à¸£à¸ª,à¸™à¹‰à¸­à¸‡","INSURED_ADDRESS":"","INSURED_STREET":"","INSURED_DISTRICT":"","INSURED_AMPHUR":"",'+
            '"INSURED_PROVINCE":"","INSURED_POSTCODE":"","CAR_MODEL":"","CARBRAND":"","REGISTERPLATENUMBER":"","YEAR_OF_MANUFACTURE":""}]}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}';
        List<String> labels = new List<String>();
        String fnaActivityId = listFnaAct[0].Id;
        String accountId = listAccount[0].Id;

        fnaOSCServiceUtility.StateInfo state = new fnaOSCServiceUtility.StateInfo(fnaActivityId,accountId,responseBodyOSC14,mockDateTime);

        // fnaAvatarDetailCtrl.processResponseWsOSC16(labels, state);
        fnaAvatarDetailCtrl.processResponseCaseBancassurance(labels, state);
    }

    @isTest
    private static void Test_getAvatarMasterDetail() {
        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'test';
        avatarMaster.Avatar_Description__c = '{1} description';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q13';
        listQuestion.add(question);
        insert listQuestion;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        listQuestionnaireResults.add(questionnaireResults);
        insert listQuestionnaireResults;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        listFnaAct.add(fnaActivity);
        FNA_Activity__c fnaActivity2 = new FNA_Activity__c();
        fnaActivity2.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity2.Phone__c = '0066666666';
        listFnaAct.add(fnaActivity2);
        insert listFnaAct;

        ContentVersion cv=new Contentversion();
        cv.title='Avatar_bullet_Example1';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        String idForm = UrlHelper.encryptParams(listFnaAct[0].Id);
        String urlDropOff = 'Mockup';

        fnaAvatarDetailCtrl.getAvatarMasterDetail(idForm, urlDropOff);
        listFnaAct[0].Phone__c = '0066666666';
        update listFnaAct;
        fnaAvatarDetailCtrl.getAvatarMasterDetail(idForm, urlDropOff);
    }

    @isTest
    private static void Test_sendOTP() {
        List<OTP__c> listOtp = new List<OTP__c>();
        OTP__c otp = new OTP__c();
        listOtp.add(otp);
        insert listOtp;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        String phone = '0123456789';
        String fnaId = UrlHelper.encryptParams(listFnaAct[0].Id);
        String otpId = listOtp[0].Id;

        fnaAvatarDetailCtrl.sendOTP(phone, fnaId, otpId);
    }

    @isTest
    private static void Test_getImage() {
        fnaAvatarDetailCtrl.getImage();
    }

    @isTest
    private static void Test_getProductOffer() {
        List<AppConfig__c> listAconfig = new List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        listAconfig.add(Aconfig);

        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'DefaultOwner';
        Aconfig2.Value__c = '99999';
        listAconfig.add(Aconfig2);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'FilterRetailSegment';
        Aconfig3.Value__c = '5|6|7|8|9';
        listAconfig.add(Aconfig3);

        insert listAconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<Question__c> listQuestion = new List<Question__c>();
        Question__c question = new Question__c();
        question.Progress__c = 50;
        question.Name = 'Q9';
        listQuestion.add(question);
        insert listQuestion;

        List<RTL_product_master__c> listRTLProductMaster = new List<RTL_product_master__c>();
        RTL_product_master__c RTLProductMaster = new RTL_product_master__c();
        RTLProductMaster.FNA_Active__c = true;
        RTLProductMaster.FNA_Product_Name__c = 'Example';
        listRTLProductMaster.add(RTLProductMaster);
        insert listRTLProductMaster;

        List<FNA_Product_Mapping__c> listProductMapping = new List<FNA_Product_Mapping__c>();
        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Segment__c = 'Default';
        productMapping.Product__c = listRTLProductMaster[0].Id;
        productMapping.Highlight_Product_Condition__c = 'Q9-A,Q10-C|Q9-B,Q10-C|Q9-C,Q10-C';
        productMapping.Normal_Product_Condition__c = 'Q9-A/B/C';
        listProductMapping.add(productMapping);

        FNA_Product_Mapping__c productMapping2 = new FNA_Product_Mapping__c();
        productMapping2.Segment__c = 'Default';
        productMapping2.Product__c = listRTLProductMaster[0].Id;
        productMapping2.Highlight_Product_Condition__c = 'Q9-A/B/C';
        productMapping2.Normal_Product_Condition__c = 'Q9-A,Q10-C|Q9-B,Q10-C|Q9-C,Q10-C';
        listProductMapping.add(productMapping2);
        
        FNA_Product_Mapping__c productMapping3 = new FNA_Product_Mapping__c();
        productMapping3.Segment__c = 'Default';
        productMapping3.Product__c = listRTLProductMaster[0].Id;
        listProductMapping.add(productMapping3);
        
        FNA_Product_Mapping__c productMapping4 = new FNA_Product_Mapping__c();
        productMapping4.Segment__c = 'Default';
        productMapping4.Product__c = listRTLProductMaster[0].Id;
        //productMapping.Highlight_Product_Condition__c = 'Q9-A,Q10-C|Q9-B,Q10-C|Q9-C,Q10-C';
        productMapping4.Highlight_Product_Condition__c = 'Q9-A/B/C';
        listProductMapping.add(productMapping4);
        insert listProductMapping;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Avatar_Master__c = listAvatarMaster[0].Id;
        fnaActivity.Customer__c = listAccount[0].Id;
        // fnaActivity.Questionnaire_Results__c = listQuestionnaireResults[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<Questionnaire_Result__c> listQuestionnaireResults = new List<Questionnaire_Result__c>();
        Questionnaire_Result__c questionnaireResults = new Questionnaire_Result__c();
        questionnaireResults.FNA_Activity_Name__c = listFnaAct[0].Id;
        questionnaireResults.Question_ID__c = listQuestion[0].Id;
        questionnaireResults.Choice_Answer__c = 'B';
        listQuestionnaireResults.add(questionnaireResults);
        insert listQuestionnaireResults;

        String fnaActivityId = UrlHelper.encryptParams(listFnaAct[0].Id);

        fnaAvatarDetailCtrl.getProductOffer(fnaActivityId);
    }
    
    @isTest
    private static void Test_OSC14_Negative() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        Account account2 = new Account();
        account2.Name = 'Mockup Data';
        account2.RTL_Office_Phone_Number__c = '012345678';
        account2.Mobile_Number_PE__c = '0';
        listAccount.add(account2);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        // Already Offset
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        listFnaAct.add(fnaActivity);
        // Don't have TMB_Customer_ID_PE__c
        FNA_Activity__c fnaActivity2 = new FNA_Activity__c();
        fnaActivity2.Customer__c = listAccount[1].Id;
        listFnaAct.add(fnaActivity2);
        // Don't have Customer
        FNA_Activity__c fnaActivity3 = new FNA_Activity__c();
        listFnaAct.add(fnaActivity3);
        insert listFnaAct;
        
        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = true;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;
        
        List<String> fnaIDList = new List<String>();
        for(FNA_Activity__c fna : listFnaAct){
            String fnaActivityId = UrlHelper.encryptParams(fna.Id);
            fnaIDList.add(fnaActivityId);
        }
        
        String encryptCustomerId = UrlHelper.encryptParams(listAccount[0].Id);
        
        fnaAvatarDetailCtrl.callServiceOSC14(fnaIDList[0]);
        fnaAvatarDetailCtrl.callServiceOSC14(fnaIDList[1]);
        fnaAvatarDetailCtrl.callServiceOSC14(fnaIDList[2]);
        fnaAvatarDetailCtrl.callServiceOSC14(encryptCustomerId);
        fnaAvatarDetailCtrl.saveAllProdToProdOffer(listFnaAct[0].Id, new List<FNA_Product_Mapping__c>(), new List<FNA_Product_Mapping__c>());
    }
    
    @isTest
    private static void Test_OSC16_Negative() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        insert Aconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        Account account2 = new Account();
        account2.Name = 'Mockup Data';
        account2.RTL_Office_Phone_Number__c = '012345678';
        account2.Mobile_Number_PE__c = '0';
        listAccount.add(account2);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        // Already Offset
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        listFnaAct.add(fnaActivity);
        // Don't have TMB_Customer_ID_PE__c
        FNA_Activity__c fnaActivity2 = new FNA_Activity__c();
        fnaActivity2.Customer__c = listAccount[1].Id;
        listFnaAct.add(fnaActivity2);
        // Don't have Customer
        FNA_Activity__c fnaActivity3 = new FNA_Activity__c();
        listFnaAct.add(fnaActivity3);
        insert listFnaAct;
        
        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = true;
        productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;
        
        List<String> fnaIDList = new List<String>();
        for(FNA_Activity__c fna : listFnaAct){
            String fnaActivityId = UrlHelper.encryptParams(fna.Id);
            fnaIDList.add(fnaActivityId);
        }
        
        String encryptCustomerId = UrlHelper.encryptParams(listAccount[0].Id);
        
        fnaAvatarDetailCtrl.callServiceOSC16(fnaIDList[0]);
        fnaAvatarDetailCtrl.callServiceOSC16(fnaIDList[1]);
        fnaAvatarDetailCtrl.callServiceOSC16(fnaIDList[2]);
        fnaAvatarDetailCtrl.callServiceOSC16(encryptCustomerId);
    }

}