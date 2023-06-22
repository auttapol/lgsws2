@isTest
public class SmartBDM_NewMiniCSV_Test {
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

    public static final String GetExcuteSearchResponse {
        get {
            return '{"GetExcuteSearchResponse":{"FinancialBalance":{"FinancialType":"Company","ListOfBalances":[{"BalanceKey":"FS1101010","BalanceDesc":"Cash and deposits at financial institutions","ListOfBalanceValues":{"BalanceDate":"2017/12/31","Value":"1083302.4"}},{"BalanceKey":"FS3700000","BalanceDesc":"Accounts receivable","ListOfBalanceValues":{"BalanceDate":"2017/12/31","Value":"110958"}}]},"FinancialIncome":{"FinancialType":"Company","ListOfIncomes":[{"IncomeKey":"FS4110100","IncomeDesc":"Net Sales","ListOfIncomeValues":{"IncomeDate":"2017/12/31","Value":"14499374.55"}},{"IncomeKey":"FS4190000","IncomeDesc":"Total revenue","ListOfIncomeValues":{"IncomeDate":"2017/12/31","Value":"14499374.55"}}]},"FinancialRatio":{"FinancialType":"Company","ListOfRatios":[{"RatioKey":"FS8101000","RatioDesc":"Quick Ratio (times)","ListOfRatioValues":{"RatioDate":"2017/12/31","Value":"616.29"}},{"RatioKey":"FS8102000","RatioDesc":"Current Ratio (times)","ListOfRatioValues":{"RatioDate":"2017/12/31","Value":"794.04"}}]},"ShareHolder":{"ListOfShareHolders":[{"numOfSH":"300000","shareAmount":"300000","sharePercent":"34","nationality":"1080210","directorship":"NO","holderType":"Human","title":"น.ส.","firstname":"Jariya","lastname":"Saejong"},{"numOfSH":"300000","shareAmount":"300000","sharePercent":"23","nationality":"1080210","directorship":"YES","directorUpdDate":"24-MAY-99","holderType":"Human","title":"นาย","firstname":"Charoen","lastname":"Saejong"},{"numOfSH":"300000","shareAmount":"300000","sharePercent":"16","nationality":"1080210","directorship":"YES","directorUpdDate":"21-MAY-99","holderType":"Human","title":"นาย","firstname":"TTCharoen","lastname":"TTSaejong"}]},"CompanyProfile":{"NameFull":"M.D. GLASS LIMITED PARTNERSHIP","NameShort":"MDGLASS","businessType":"รับติดตั้งกระจกอลูมิเนียม","regisId":"0103542011133","companyStatus":"Active","RegistrationType":"Limited Partnership","capital":"600000","regisDate":"1999/05/24","Address":{"addressNo":"82/179","RoadName":"Kalapapruek","subDistrict":"BANG KHAE","district":"BANG KHAE","province":"BANGKOK","postcode":"10160","Reconcile":{"TotalCount":"1"}},"Telephone":{"ListOfTelephones":{"Telephone":"0850345678","Extension":"","Fax":""},"Reconcile":{"TotalCount":"1"}},"tsicDescrLatest":"F433090 Other building completion and finishing, not elsewhere classified","officialSignatory":"CHAROEN Saejong","SignatoryText":"ไม่มี","Reconcile":{"TotalCount":"1"}}}}';
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
    }

    @isTest static void test_method_onInit() {
        // Instantiate a new controller with all parameters in the page
		SmartBDM_NewMiniCSV objClass = new SmartBDM_NewMiniCSV();

        String deeplinkToKony = objClass.deeplinkToKony;
        Decimal netWorth = objClass.companyInfo.netWorth;
        Decimal totalRevenue = objClass.companyInfo.totalRevenue;
        List<SmartBDMEnliteCompanyDetail.ShareHolder> shareHolders = objClass.companyInfo.shareHolders;
    }

    @isTest static void test_method_calloutCompanyDetail() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		// ApexPages.currentPage().getParameters().put('itemNumber', '0001');
		// ApexPages.currentPage().getParameters().put('accountId', acct.Id);

        // Instantiate a new controller with all parameters in the page
		SmartBDM_NewMiniCSV objClass = new SmartBDM_NewMiniCSV();
        System.runAs(u){
            Test.startTest();
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            // String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

            Test.setCurrentPage(Page.SmartBDM_NewMiniCSV_EnliteData);
            ApexPages.currentPage().getParameters().put('Id', '0103542011133');
            ApexPages.currentPage().getParameters().put('AccountName', 'NewMiniCSV');
		    ApexPages.currentPage().getParameters().put('retURL', '/lightning/n/Searching_Company_VF');
            Continuation conti = (Continuation)objClass.calloutGetCompanyListService();
            
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();
            // Invoke callback method
            // respone is successesful
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyList);
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
			conti = (Continuation)objClass.calloutGetCompanyDetailService();
            response.setBody(GetExcuteSearchResponse);
			response.setStatusCode(200);
			Test.setContinuationResponse((String)conti.getRequests().keyset().iterator().next(), response);
            objClass.callbackGetCompanyDetailService();
            // respone is timeout
			response = new HttpResponse();
			response.setBody('');
			response.setStatusCode(2000);
			Test.setContinuationResponse(requestLabel, response);
            conti = (Continuation)objClass.calloutGetCompanyDetailService();
            response.setBody('');
			response.setStatusCode(2000);
			Test.setContinuationResponse((String)conti.getRequests().keyset().iterator().next(), response);
            objClass.callbackGetCompanyDetailService();
            // catch Exception
            response = new HttpResponse();
			response.setBody('{"GetExcuteSearchResponse"}');
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            conti = (Continuation)objClass.calloutGetCompanyDetailService();
            response.setBody('{"GetExcuteSearchResponse"}');
			response.setStatusCode(200);
			Test.setContinuationResponse((String)conti.getRequests().keyset().iterator().next(), response);
            objClass.callbackGetCompanyDetailService();
            // respone is 404
            response = new HttpResponse();
            response.setBody(GetExcuteSearchResponseCompanyList);
			response.setStatusCode(404);
			Test.setContinuationResponse(requestLabel, response);
            conti = (Continuation)objClass.calloutGetCompanyDetailService();
            response.setBody('{"status":{"code":"10006","description":"System authenticate key (TOKEN) failed!"}}');
			response.setStatusCode(404);
			Test.setContinuationResponse((String)conti.getRequests().keyset().iterator().next(), response);
            objClass.callbackGetCompanyDetailService();
            Test.stopTest();
        }
    }

    @isTest static void test_method_calloutWorkingCapital_negative() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];

        // Instantiate a new controller with all parameters in the page
		SmartBDM_NewMiniCSV objClass = new SmartBDM_NewMiniCSV();
        System.runAs(u){
            Test.startTest();
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

            Test.setCurrentPage(Page.SmartBDM_NewMiniCSV_EnliteData);
            ApexPages.currentPage().getParameters().put('Id', '0103542011133');
            ApexPages.currentPage().getParameters().put('AccountName', 'NewMiniCSV');
		    ApexPages.currentPage().getParameters().put('retURL', '/lightning/n/Searching_Company_VF');
            Continuation conti = (Continuation)objClass.calloutGetCompanyListService();
            
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();
            // respone is null
            HttpResponse response = new HttpResponse();
			response.setBody(GetExcuteSearchResponseCompanyList);
			response.setStatusCode(200);
			// Test.setContinuationResponse(requestLabel, response);
			// Invoke callback method
			objClass.calloutGetCompanyDetailService();
            response.setBody(GetExcuteSearchResponse);
			response.setStatusCode(200);
            objClass.callbackGetCompanyDetailService();
            Test.stopTest();
        }
    }
}