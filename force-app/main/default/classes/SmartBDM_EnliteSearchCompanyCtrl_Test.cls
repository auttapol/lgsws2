@isTest
public class SmartBDM_EnliteSearchCompanyCtrl_Test {
    public static final Id BDM_PROFILE_ID {
        get{
            if(BDM_PROFILE_ID == null){
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
    }

    public static final String GetExcuteSearchResponseCompanyList {
        get {
            return '{"GetExcuteSearchResponse":{"Status":"0","ListOfExcuteSearchs":{"ListOfSearchDescs":[{"ResultDesc":"REGISTRATION_ID","Value":["0113539004504","0103542011133","0113555008861","0113557005541","0113553003480"]},{"ResultDesc":"NAME_EN","Value":["EAST WIND INTERTRADE LIMITED PARTNERSHIP","M.D. GLASS LIMITED PARTNERSHIP","KANONG POOKLAP LIMITED PARTNERSHIP","SUCCESS GROUP 2014 LIMITED PARTNERSHIP","A.P. AUTO CAR LIMITED PARTNERSHIP"]},{"ResultDesc":"NAME_TH","Value":["ห้างหุ้นส่วนจำกัด อีสท์ วินด์ อินเตอร์เทรด","ห้างหุ้นส่วนจำกัด เอ็ม ดี กลาส","ห้างหุ้นส่วนจำกัด คะนอง พูนลาภ","ห้างหุ้นส่วนจำกัด ซัคเซส กรุ๊ป 2014","ห้างหุ้นส่วนจำกัด เอ. พี. ออโต้ คาร์"]}]}}}';
        }
    }

    public static final String GetExcuteSearchResponseCompanyDetail {
        get {
            return '{"GetExcuteSearchResponse":{"FinancialBalance":{"FinancialType":"Company","ListOfBalances":[{"BalanceKey":"FS1101010","BalanceDesc":"Cash and deposits at financial institutions","ListOfBalanceValues":{"BalanceDate":"2017/12/31","Value":"1083302.4"}},{"BalanceKey":"FS1103020","BalanceDesc":"Accounts receivable","ListOfBalanceValues":{"BalanceDate":"2017/12/31","Value":"110958"}}]},"FinancialIncome":{"FinancialType":"Company","ListOfIncomes":[{"IncomeKey":"FS4110100","IncomeDesc":"Net Sales","ListOfIncomeValues":{"IncomeDate":"2017/12/31","Value":"14499374.55"}},{"IncomeKey":"FS4190000","IncomeDesc":"Total revenue","ListOfIncomeValues":{"IncomeDate":"2017/12/31","Value":"14499374.55"}}]},"FinancialRatio":{"FinancialType":"Company","ListOfRatios":[{"RatioKey":"FS8101000","RatioDesc":"Quick Ratio (times)","ListOfRatioValues":{"RatioDate":"2017/12/31","Value":"616.29"}},{"RatioKey":"FS8102000","RatioDesc":"Current Ratio (times)","ListOfRatioValues":{"RatioDate":"2017/12/31","Value":"794.04"}}]},"ShareHolder":{"ListOfShareHolders":[{"numOfSH":"300000","shareAmount":"300000","sharePercent":"24","nationality":"1080210","directorship":"NO","holderType":"Human","title":"น.ส.","firstname":"Jariya","lastname":"Saejong"},{"numOfSH":"300000","shareAmount":"300000","sharePercent":"13","nationality":"1080210","directorship":"YES","directorUpdDate":"24-MAY-99","holderType":"Human","title":"นาย","firstname":"Charoen","lastname":"Saejong"},{"numOfSH":"300000","shareAmount":"300000","sharePercent":"16","nationality":"1080210","directorship":"YES","directorUpdDate":"21-MAY-99","holderType":"Human","title":"นาย","firstname":"TTCharoen","lastname":"TTSaejong"}]},"CompanyProfile":{"NameFull":"M.D. GLASS LIMITED PARTNERSHIP","NameShort":"MDGLASS","businessType":"รับติดตั้งกระจกอลูมิเนียม","regisId":"0103542011133","companyStatus":"Active","RegistrationType":"Limited Partnership","capital":"600000","regisDate":"1999/05/24","Address":{"addressNo":"82/179","RoadName":"Kalapapruek","subDistrict":"BANG KHAE","district":"BANG KHAE","province":"BANGKOK","postcode":"10160","Reconcile":{"TotalCount":"1"}},"Telephone":{"ListOfTelephones":{"Telephone":"","Extension":"","Fax":""},"Reconcile":{"TotalCount":"1"}},"tsicDescrLatest":"F433090 Other building completion and finishing, not elsewhere classified","officialSignatory":"CHAROEN Saejong","SignatoryText":"ไม่มี","Reconcile":{"TotalCount":"1"}}}}';
        }
    }

    public static final SmartBDMEnliteCompany smartBDMEnliteCompanyList {
        get {
            SmartBDMEnliteCompany smartBDMEnlite = new SmartBDMEnliteCompany();
            SmartBDMEnliteCompany.Request request = new SmartBDMEnliteCompany.Request();
            request.ToKenKey = '12341523467162384712394';
            request.RequiredTable = 'COMPANY_PROFILE';
            request.ResultFields = 'REGISTRATION_ID, NAME_EN, NAME_TH';
            request.CriteriaField0 = 'REGISTRATION_ID';
            request.CriteriaOperator0 = 'contains';
            request.CriteriaValues0 = '12345';
            request.CriteriaAndOr0 = 'Or';
            request.CriteriaField1 = 'NAME_EN';
            request.CriteriaOperator1 = 'contains';
            request.CriteriaValues1 = '12345';
            request.CriteriaAndOr1 = 'Or';
            request.CriteriaField2 = 'NAME_TH';
            request.CriteriaOperator2 = 'contains';
            request.CriteriaValues2 = '12345';
            smartBDMEnlite.companyRequest.GetExcuteSearchRequest = request;
            return smartBDMEnlite;
        }
    }

    public static final SmartBDMEnliteCompanyDetail smartBDMEnliteCompanyDetail {
        get {
            SmartBDMEnliteCompanyDetail smartBDMEnlite = new SmartBDMEnliteCompanyDetail();
            SmartBDMEnliteCompanyDetail.Request request = new SmartBDMEnliteCompanyDetail.Request();
            request.ToKenKey = '12341523467162384712394';
            request.RegistrationID = '123456789';
            request.CompanyName = '?';
            request.FiscalYear = String.valueOf(Datetime.now().year());
            request.Language = Smart_BDM_Constant.SMARTBDM_ENLITE_LANGUAGE_SEARCHING;
            request.TagRequired = 'company profile';
            smartBDMEnlite.enliteDataRequest.GetEnliteDataRequest = request;
            return smartBDMEnlite;
        }
    }

    @testSetup static void setup() {
		
		TestUtils.createAppConfig();
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
		
		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

		User User02 = RTL_TestUtility.createUsers(2, 'TestMock02', 'SmartBDM02', 'smartbdm02@tmb.com.test', false).get(1);
        insert User02;

        Integer length = 10;
        List<Account> acct = TestUtils.createAccounts(length, 'SmartBDM', 'Juristic', false);
		RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
		RecordType Prospect = [SELECT Id FROM RecordType WHERE developername='Prospect' and SobjectType = 'Account' AND IsActive = true LIMIT 1];
		for (Integer i = 0; i < length; i++ ) {
			Account acct_mock = acct.get(i);
			if(Math.mod(i, 2) == 0){
				acct_mock.RecordType = Existing_Customer;
				acct_mock.RecordTypeId = Existing_Customer.Id;
			} else {
                acct_mock.RecordType = Prospect;
                acct_mock.RecordTypeId = Prospect.Id;
			}
			acct_mock.OwnerId = User01.Id;
		}
        acct.get(0).ID_Number_PE__c = '0113553003480';
        acct.get(1).ID_Number_PE__c = '0113539004504';
        acct.get(2).ID_Number_PE__c = '0113557005541';
        acct.get(2).OwnerId = User02.Id;
		insert acct;

    }

    public static Map<Id, Account> getAccountMap() {
        return new Map<Id, Account>([
            SELECT Id, Name, Customer_Type__c, Core_Banking_Suggested_Segment__c, TMB_Customer_ID_PE__c, ID_Number_PE__c, OwnerId, Customer_Owner__c FROM Account
        ]);
    }

    @isTest static void test_method_onInit() {
        SmartBDM_EnliteSearchCompanyCtrl.getVFBaseURL();
        SmartBDM_EnliteSearchCompanyCtrl.getLimitOffsetRecord();

        Test.setCurrentPageReference(new PageReference('Page.SmartBDM_EnliteSearchingCompany'));
        System.currentPageReference().getParameters().put('isdtp', 'p1');
        SmartBDM_EnliteSearchCompanyCtrl objClass = new SmartBDM_EnliteSearchCompanyCtrl();
        Boolean isSF1 = objClass.isSF1;
        
        SmartBDMEnliteCompany cList = new SmartBDMEnliteCompany();
        cList.companyResponse.GetExcuteSearchResponse = new SmartBDMEnliteCompany.Response();
        cList.companyResponse.GetExcuteSearchResponse.Status = '0';
        cList.convertToResponseObject('{"status":{"code":"0500","description":"Internal server error - xxx"}}');
        String pasrsToJson = cList.companyResponse.parseJson();
        Integer statuscode = cList.companyResponse.status.code;
        String statusdescription = cList.companyResponse.status.description;

        SmartBDMEnliteCompanyDetail cDetatil = new SmartBDMEnliteCompanyDetail();
        cDetatil.convertToResponseObject(GetExcuteSearchResponseCompanyDetail);
        String FinancialType;
        FinancialType =  cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialBalance.FinancialType;
        Decimal sumTotalBalances = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialBalance.sumTotalBalances();
        String BalanceDesc = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialBalance.ListOfBalances.get(0).BalanceDesc;
        String BalanceDate = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialBalance.ListOfBalances.get(0).ListOfBalanceValues.BalanceDate;

        FinancialType =  cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialIncome.FinancialType;
        Decimal sumTotalIncomes = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialIncome.sumTotalIncomes();
        String IncomeDesc = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialIncome.ListOfIncomes.get(0).IncomeDesc;
        String IncomeDate = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialIncome.ListOfIncomes.get(0).ListOfIncomeValues.IncomeDate;

        FinancialType =  cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.FinancialType;
        Decimal sumTotalRatio = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.sumTotalRatio();
        Map<String, Object> getRatioMap = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.getRatioMap();
        String RatioKey = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.ListOfRatios.get(0).RatioKey;
        String RatioDesc = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.ListOfRatios.get(0).RatioDesc;
        String RatioDate = cDetatil.enliteDataResponse.GetExcuteSearchResponse.FinancialRatio.ListOfRatios.get(0).ListOfRatioValues.RatioDate;

        Decimal numOfSH = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).numOfSH;
        Decimal shareAmount = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).shareAmount;
        String nationality = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).nationality;
        String directorship = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).directorship;
        String holderType = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).holderType;
        String title = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).title;
        String firstname = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).firstname;
        String lastname = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).lastname;
        String shareholderName = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).shareholderName;
        String companyName = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).companyName;
        String companyNameFull = cDetatil.enliteDataResponse.GetExcuteSearchResponse.ShareHolder.ListOfShareHolders.get(0).companyNameFull;

        String NameShort = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.NameShort;
        String businessType = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.businessType;
        String companyStatus = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.companyStatus;
        String RegistrationType = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.RegistrationType;
        String capital = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.capital;
        String regisDate = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.regisDate;
        String tsicDescrLatest = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.tsicDescrLatest;
        String officialSignatory = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.officialSignatory;
        String SignatoryText = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.SignatoryText;
        String isicCode = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.isicCode;
        String isicDescription = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.isicDescription;
        String mobileNo = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.mobileNo;
        String officeNo = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.officeNo;
        String Extension = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.Telephone.ListOfTelephones.Extension;
        String Fax = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.Telephone.ListOfTelephones.Fax;
        Integer TotalCount = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.Reconcile.TotalCount;
        TotalCount = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.Address.Reconcile.TotalCount;
        TotalCount = cDetatil.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile.Telephone.Reconcile.TotalCount;

        cDetatil.convertToResponseObject('{"status":{"code":"0500","description":"Internal server error - xxx"}}');
        statuscode = cDetatil.enliteDataResponse.status.code;
        statusdescription = cDetatil.enliteDataResponse.status.description;
        pasrsToJson = cDetatil.enliteDataResponse.parseJson();

        SmartBDMEnliteToken cToken = new SmartBDMEnliteToken();
        cToken.response.convertToObject('{"GetTokenResponse":{"Status":"0","TokenKey":"e8209b9b889b984edf6f2228624179d9","Reconcile":{"TotalCount":"1"}}}');
        String Status = cToken.response.GetTokenResponse.Status;
        String TokenKey = cToken.response.GetTokenResponse.TokenKey;
        TotalCount = cToken.response.GetTokenResponse.Reconcile.TotalCount;
        cToken.response.status = new SmartBDMEnliteToken.Status();
        cToken.response.status.code = '0500';
        cToken.response.status.description = 'Internal server error - xxx';
        pasrsToJson = cToken.response.parseJson();
    }

    @isTest static void test_method_calloutCompanyList_negative() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id, AssigneeId=u.Id);
        // Instantiate a new controller with all parameters in the page
		SmartBDM_CalculateWCController objClass = new SmartBDM_CalculateWCController();
        System.runAs(u){
            Test.startTest();
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            String tokenKeyEnliteRequestBody = '';

            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            tokenKeyEnliteRequestBody = SmartBDM_Utility.tokenKeyEnliteRequestBody;

            Test.setCurrentPage(Page.SmartBDM_EnliteSearchingCompany);
            Continuation conti = (Continuation)SmartBDM_EnliteSearchCompanyCtrl.startCallGetCompanyListService('12345');
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();
            // Invoke callback method
            // respone is successesful
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyList);
			response.setStatusCode(200);
            Test.setContinuationResponse(requestLabel, response);
            SmartBDM_EnliteService.SmartBDMEnliteWrapper requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyList);
            SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);
            Test.stopTest();
        }
    }

    @isTest static void test_method_CallGetCompanyListService() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        // Instantiate a new controller with all parameters in the page
		SmartBDM_EnliteSearchCompanyCtrl objClass = new SmartBDM_EnliteSearchCompanyCtrl();
        insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id, AssigneeId=u.Id);
        System.runAs(u){
            Test.startTest();
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

            Test.setCurrentPage(Page.SmartBDM_EnliteSearchingCompany);
            Continuation conti = (Continuation)SmartBDM_EnliteSearchCompanyCtrl.startCallGetCompanyListServiceContinuation('12345', false);
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();

            // Invoke callback method
            // respone is successesful
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyList);
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            SmartBDM_EnliteService.SmartBDMEnliteWrapper requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyList);
            SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);
            Map<String, Object> tempCompanyDetail = companyWrapper.tempCompanyDetail;
            Map<String, Object> tempCompanyList = companyWrapper.tempCompanyList;
            Account tempCompanyDetailAccount = companyWrapper.tempCompanyDetailAccount;
            
            List<Account> listAccount = getAccountMap().values();
            Test.setFixedSearchResults(new Id[] { listAccount.get(0).Id, listAccount.get(1).Id, listAccount.get(2).Id, listAccount.get(3).Id, listAccount.get(4).Id, listAccount.get(5).Id, listAccount.get(6).Id, listAccount.get(7).Id, listAccount.get(8).Id, listAccount.get(9).Id });
            objClass.resultCompany = GetExcuteSearchResponseCompanyList;
            objClass.refreshCompanyTable();
            objClass.NextPage();
            objClass.PreviousPage();
            objClass.SortCompany();


            // respone is timeout
			response = new HttpResponse();
			response.setBody('');
			response.setStatusCode(2000);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyList);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);
            // respone is other error
            response = new HttpResponse();
			response.setBody('{"status":{"code":"0500","description":"Internal server error - xxx"}}');
			response.setStatusCode(9999);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyList);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);
            // catch Exception
            response = new HttpResponse();
			response.setBody('{"GetExcuteSearchResponse"}');
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyList);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);

            // respone is null
            Continuation con = new Continuation(60);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setHeader('Service-Name', 'loan-od-inq');
            req.setHeader('Request-UID', '{!$Credential.UserName}');
            req.setHeader('Request-App-ID', '{!$Credential.Password}');
            req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
            req.setHeader('Authorization', 'bearer' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_List');
            req.setBody(smartBDMEnliteCompanyList.companyRequest.parseJson());
            req.setTimeout(120000);
            con.addHttpRequest(req);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(con.addHttpRequest(req), smartBDMEnliteCompanyList);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyListServiceContinuation(requestEnliteWrapper);

            Test.stopTest();
        }
    }



    @isTest static void test_method_calloutCompanyDetail_negative() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
       	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id, AssigneeId=u.Id);
        // Instantiate a new controller with all parameters in the page
		SmartBDM_CalculateWCController objClass = new SmartBDM_CalculateWCController();
        System.runAs(u){
            Test.startTest();
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            String tokenKeyEnliteRequestBody = '';

            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            tokenKeyEnliteRequestBody = SmartBDM_Utility.tokenKeyEnliteRequestBody;

            Test.setCurrentPage(Page.SmartBDM_EnliteSearchingCompany);
            Continuation conti = (Continuation)SmartBDM_EnliteSearchCompanyCtrl.startCallGetCompanyDetailService('123456789', '2019');
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();
            // Invoke callback method
            // respone is successesful
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyDetail);
			response.setStatusCode(200);
            Test.setContinuationResponse(requestLabel, response);
            SmartBDM_EnliteService.SmartBDMEnliteWrapper requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyDetail);
            SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);
            Test.stopTest();
        }
    }

    @isTest static void test_method_CallGetCompanyDetailService() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
       	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id, AssigneeId=u.Id);
        System.runAs(u){
            Test.startTest();
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

            Test.setCurrentPage(Page.SmartBDM_EnliteSearchingCompany);
            Continuation conti = (Continuation)SmartBDM_EnliteSearchCompanyCtrl.startCallGetCompanyDetailService('123456789', '2019');
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();

            // Invoke callback method
            // respone is successesful
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyDetail);
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            SmartBDM_EnliteService.SmartBDMEnliteWrapper requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyDetail);
            SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);
            // respone is timeout
			response = new HttpResponse();
			response.setBody('');
			response.setStatusCode(2000);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyDetail);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);
            // respone is other error
            response = new HttpResponse();
			response.setBody('{"status":{"code":"0500","description":"Internal server error - xxx"}}');
			response.setStatusCode(9999);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyDetail);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);
            // catch Exception
            response = new HttpResponse();
			response.setBody('{"GetExcuteSearchResponse"}');
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(requestLabel, smartBDMEnliteCompanyDetail);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);

            // respone is null
            Continuation con = new Continuation(60);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setHeader('Service-Name', 'loan-od-inq');
            req.setHeader('Request-UID', '{!$Credential.UserName}');
            req.setHeader('Request-App-ID', '{!$Credential.Password}');
            req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
            req.setHeader('Authorization', 'bearer' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_Detail');
            req.setBody(smartBDMEnliteCompanyDetail.enliteDataRequest.parseJson());
            req.setTimeout(120000);
            con.addHttpRequest(req);
            requestEnliteWrapper = new SmartBDM_EnliteService.SmartBDMEnliteWrapper(con.addHttpRequest(req), smartBDMEnliteCompanyDetail);
            companyWrapper = (SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper)SmartBDM_EnliteSearchCompanyCtrl.callBackGetCompanyDetailServiceContinuation(requestEnliteWrapper);

            Test.stopTest();
        }
    }
}