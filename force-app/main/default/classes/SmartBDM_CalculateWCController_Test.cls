@isTest
public class SmartBDM_CalculateWCController_Test {
    public static final Id BDM_PROFILE_ID {
        get{
            if(BDM_PROFILE_ID == null){
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
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

        String authorized = '{'+
            '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
            '"token_type": "bearer",'+
            '"expires_in": 3600,'+
            '"scope": "read write",'+
            '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
            '"client_id": "xxxxx",'+
            '"version": "001-20181111",'+
            '"isSuccess": true,'+
            '"errorMessage": "",'+
            '"requestBody": "",'+
            '"responseBody": ""'+
        '}';
        
        AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
        Datetime startTime = Datetime.now();
        Datetime endTime = Datetime.now();
        
        Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.CreateGateWayToken'); 
        orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

        OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
        orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);

    }

    @isTest static void test_method_onInit() {
        SmartBDM_CalculateWCController.getVFBaseURL();
        SmartBDM_CalculateWCController.getBusinessGroup();

        SmartBDMWorkingCapital objectWorkingCapital = new SmartBDMWorkingCapital();
        Test.setCurrentPageReference(new PageReference('Page.BDM_Customer_list_mobile'));
        System.currentPageReference().getParameters().put('isdtp', 'p1');
        SmartBDM_CalculateWCController objClass = new SmartBDM_CalculateWCController();
        Boolean b = objClass.isSF1;
        SmartBDM_CalculateWCController.getDeepLink();
    }

    @isTest static void test_method_calloutWorkingCapital() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		// ApexPages.currentPage().getParameters().put('itemNumber', '0001');
		// ApexPages.currentPage().getParameters().put('accountId', acct.Id);

        // Instantiate a new controller with all parameters in the page
		// SmartBDM_CalculateWCController objClass = new SmartBDM_CalculateWCController();
        System.runAs(u){
            Test.startTest();
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');

            Test.setCurrentPage(Page.SmartBDM_WorkingCapitalCallout);
            SmartBDMWorkingCapital.Request requestWorkingCapital = new SmartBDMWorkingCapital.Request();
            requestWorkingCapital.businessGroupCode = '1';
            requestWorkingCapital.salePerYear = 2;
            requestWorkingCapital.tmbWcLimit = 3;
            Continuation conti = (Continuation)SmartBDM_CalculateWCController.getWorkingCapitalContinuation('1', 2, 3);
            
            Map<String, HttpRequest> requests = conti.getRequests();
			// Set the fake response for the continuation
			String requestLabel = requests.keyset().iterator().next();
            HttpResponse response = new HttpResponse();
			response.setBody('{"wcLimit":32.00}');
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
			// Invoke callback method
            // respone is successesful
            SmartBDM_CalculateWCController.WorkingCapitalState wcs = new SmartBDM_CalculateWCController.WorkingCapitalState(requestLabel, requestWorkingCapital, Datetime.now());
			SmartBDM_CalculateWCController.WorkingCapitalWrapper resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)SmartBDM_CalculateWCController.callBackGetCalculateWorkingCapitalContinuation(wcs);
            // respone is timeout
			response = new HttpResponse();
			response.setBody('');
			response.setStatusCode(2000);
			Test.setContinuationResponse(requestLabel, response);
            wcs = new SmartBDM_CalculateWCController.WorkingCapitalState(requestLabel, requestWorkingCapital, Datetime.now());
            resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)SmartBDM_CalculateWCController.callBackGetCalculateWorkingCapitalContinuation(wcs);
            // respone is other error
            response = new HttpResponse();
			response.setBody('');
			response.setStatusCode(9999);
			Test.setContinuationResponse(requestLabel, response);
            wcs = new SmartBDM_CalculateWCController.WorkingCapitalState(requestLabel, requestWorkingCapital, Datetime.now());
            resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)SmartBDM_CalculateWCController.callBackGetCalculateWorkingCapitalContinuation(wcs);
            // catch Exception
            response = new HttpResponse();
			response.setBody('{"wcLimit"}');
			response.setStatusCode(200);
			Test.setContinuationResponse(requestLabel, response);
            wcs = new SmartBDM_CalculateWCController.WorkingCapitalState(requestLabel, requestWorkingCapital, Datetime.now());
            resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)SmartBDM_CalculateWCController.callBackGetCalculateWorkingCapitalContinuation(wcs);
            // respone is null
            Continuation con = new Continuation(60);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setHeader('Authorization', SmartBDM_Utility.tokenKeyCalculateTools);
            req.setEndpoint('callout:' + Smart_BDM_Constant.SmartBDM_CalculateTools_Settings.get('ENDPOINT_WORKING_CAPITAL'));
            req.setBody(requestWorkingCapital.parseToJSON());
            req.setTimeout(120000);
            con.addHttpRequest(req);
            wcs = new SmartBDM_CalculateWCController.WorkingCapitalState(con.addHttpRequest(req), requestWorkingCapital, Datetime.now());
            resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)SmartBDM_CalculateWCController.callBackGetCalculateWorkingCapitalContinuation(wcs);

            Test.stopTest();
        }
    }

    @isTest static void test_method_calloutWorkingCapital_negative() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];

        // Instantiate a new controller with all parameters in the page
		SmartBDM_CalculateWCController objClass = new SmartBDM_CalculateWCController();
        System.runAs(u){
            Test.startTest();
            AuthenticationToken authenTokenCalculateTools_Failed = SmartBDM_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');

            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');

            Test.setCurrentPage(Page.SmartBDM_WorkingCapitalCallout);
            SmartBDMWorkingCapital.Request requestWorkingCapital = new SmartBDMWorkingCapital.Request();
            requestWorkingCapital.businessGroupCode = '1';
            requestWorkingCapital.salePerYear = 2;
            requestWorkingCapital.tmbWcLimit = 3;
            // SmartBDM_CalculateWCController.WorkingCapitalWrapper resultWC = (SmartBDM_CalculateWCController.WorkingCapitalWrapper)\
            SmartBDM_CalculateWCController.getWorkingCapitalContinuation('1', 2, 3);
            Test.stopTest();
        }
    }
    
}