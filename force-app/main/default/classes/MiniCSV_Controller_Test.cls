@isTest
private class MiniCSV_Controller_Test {
    public static final Id BDM_PROFILE_ID {get { if(BDM_PROFILE_ID == null) BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id; return BDM_PROFILE_ID; } set;}
	// public static final Id SE_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id Commercial_Account_ID { get { if(Commercial_Account_ID == null) Commercial_Account_ID = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId(); return Commercial_Account_ID; } set; }
	public static RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType == null){
                CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                        WHERE Name='Commercial Lead' 
                                        AND sObjectType='Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }
        set;
	}

	public static Lead CreateValidLead(Id OwnerID, Id accId){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        leadRec.Account__c = accId;
        return leadRec;
    }
    
    @testSetup static void setupData(){
        TestUtils.createAppConfig();
        
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
         
        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1','D20171001','Exclusive','MB', User01);
        insert masterC;
        RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
        Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
        insert childC;
       
    }

	/*static void setupDataTemp() {
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

		RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
		// Account acc1 = RTL_TestUtility.createAccounts(1 , false).get(0);
		Account acc1 = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acc1.Customer_Type__c = 'Individual';
		acc1.OwnerID = User01.id;
		acc1.RecordType = Existing_Customer;
		acc1.RecordTypeId = Existing_Customer.Id;
		acc1.BIZ_FLAG__c = 'Y';
		acc1.WOW_FLAG__c = 'Y';
		acc1.Total_Revenue_Baht__c = 100000001;
		acc1.Warning_Code__c = 'I078';
		acc1.Business_Type_Code__c = 'C1023';
		acc1.NAMBRL__c = 'Bad';
		insert acc1;

		IndustryMaster__c im = new IndustryMaster__c();
		im.TMBCode__c = 'C1023';
		im.SubIndustry__c ='asd';
		insert im;
		// Create Contact
		// Contact cont1 = new Contact();
		// cont1.FirstName = 'SmartBDM';
		// cont1.LastName = 'II';
		// cont1.Accountid = acc1.id;
		// insert cont1;

		Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB', User01
        	);
		insert masterC;

		RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childC;

		RecordType Commercial_Account = [SELECT Id FROM RecordType WHERE developername='Commercial_Account' AND SobjectType = 'Lead' and IsActive = true LIMIT 1];
		// Lead Lead1 = CreateValidLead(User01.id, acc1.id);
		// Lead Lead1 = RTL_TestUtility.createLeads(1, false).get(0);
		// Lead1.RecordType = Commercial_Account;
		// Lead1.RecordTypeId = CommercialLeadRecordType.id;
        // Lead1.Interest_result__c = 'Yes';
        // Lead1.OwnerID = User01.id;
        // Lead1.Account__c = acc1.id;
		// insert Lead1;
		List<Lead> lead_lst = RTL_TestUtility.createLeads(5, false);
		for (Lead l : lead_lst) {
			l.RecordType = Commercial_Account;
			l.RecordTypeId = CommercialLeadRecordType.id;
			l.Interest_result__c = 'Yes';
			l.OwnerID = User01.id;
			l.Account__c = acc1.id;
			l.Primary_Campaign__c = childC.id;
		}
		insert lead_lst;

		Collateral__c colla = new Collateral__c();
		// colla.Appraisal_Value__c = 123;
		// colla.Pledge_Value__c = 234;
		colla.Collateral_Group_Type__c = 'ASDFG';
		colla.Collateral_Group_Type_Key__c  = 'Test1234';
		colla.Account__c = acc1.id;
		insert colla;
		
		Collateral_Detail__c colladetail = new Collateral_Detail__c();
		colladetail.Appraisal_Date__c = system.today();
		colladetail.Collateral__c = colla.id;
		insert colladetail;
		
        List<Product2> prod2List = new List<Product2>();
		Product2 prod1 = new Product2(Name = 'Funding', Product_Domain__c ='Funding & Borrowing', Family = 'Hardware', IsActive=true);
		//insert prod1;
		Product2 prod2 = new Product2(Name = 'Deposit', Product_Domain__c ='Deposit & Investment', Family = 'Hardware', IsActive=true);
        //insert prod2;
		prod2List.add(prod1);
        prod2List.add(prod2);
        
        insert prod2List;
        
        List<Product_Information_On_Hand__c> prodOnHandList = new List<Product_Information_On_Hand__c>();
		Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = acc1.Id;
        onhand1.Product_Hierachy_Code__c = String.valueOf(prod2List[0].id);
        //insert onhand1;
        //
        Product_Information_On_Hand__c onhand2 = new Product_Information_On_Hand__c();
        onhand2.Account__c = acc1.Id;
        onhand2.Product_Hierachy_Code__c = String.valueOf(prod2.id);
        //insert onhand2;
        prodOnHandList.add(onhand1);
        prodOnHandList.add(onhand2);
        insert prodOnHandList;
        
        List<Product_Information_Detail__c> prodDetailList = new List<Product_Information_Detail__c>();
		Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = prodOnHandList[0].id;
		// detail1.ACC_S1B__c = 'Y';
		// detail1.EDC_FLAG__c = 'Y';
		// detail1.LATEST_MTH_TXN__c = 59;
		// detail1.LATEST_SIXMTH_TXN__c = 49;
        //insert detail1;
        prodDetailList.add(detail1);

		
		Product_Information_Detail__c detail2 = new Product_Information_Detail__c();
        detail2.Product_Information__c = prodOnHandList[1].id;
		detail2.Customer__c = acc1.Id;
		detail2.ACC_S1B__c = 'Y';
		// detail2.EDC_FLAG__c = 'Y';
		detail2.LATEST_MTH_TXN__c = 8;
		detail2.LATEST_SIXMTH_TXN__c = 8;
        //insert detail2;
        prodDetailList.add(detail2);
        
		Product_Information_Detail__c detail3 = new Product_Information_Detail__c();
        detail3.Product_Information__c = prodOnHandList[1].id;
		detail3.Customer__c = acc1.Id;
		detail3.ACC_S1B__c = 'N';
		// detail3.EDC_FLAG__c = 'Y';
		detail3.LATEST_MTH_TXN__c = 9;
		detail3.LATEST_SIXMTH_TXN__c = 9;
        //insert detail3;
		prodDetailList.add(detail3);
        
        insert prodDetailList;
        
		IndustryMaster__c insdusObj_temp = new IndustryMaster__c();
		insdusObj_temp.APday__c = 123;
		insdusObj_temp.ARday__c = 321;
		insdusObj_temp.BusinessType__c = 'rsp.businessType.name';
		insdusObj_temp.COGday__c = 69;
		insdusObj_temp.Diversification__c = true;
		insdusObj_temp.HighlySelectiveIndustry__c = false;
		insdusObj_temp.HighRisk__c = false;
		insdusObj_temp.INVday__c = 780;
		insdusObj_temp.ISICCode__c = 'F433090';
		insdusObj_temp.Negative__c = true;
		insdusObj_temp.SubIndustry__c = 'rsp.businessType.subGroup';
		// insdusObj_temp.ColorCode__c = rsp.
		insdusObj_temp.Suspend__c = false;
		insdusObj_temp.TMBCode__c = '12HAJK11';
		insdusObj_temp.IncomeFactor__c = 34;
		insdusObj_temp.BusinessGroupCode__c = '5';
		insdusObj_temp.BusinessGroupNameTH__c = 'rsp.name.th';
		insdusObj_temp.BusinessGroupNameEN__c = 'rsp.name.en';
		insert insdusObj_temp;

		insert new Income_Estimation__c(
			AVG_Income_amount__c = 3444452,
			Account__c = acc1.Id,
			BOT_ID__c = '12345',
			Income_External_Key__c = '6226410011000000000000000000006226412019-02-28',
			Model_Type__c = 'Non-OD customer',
			Valida_date__c = '10 MAR 2019 - 09 APR 2019',
			as_of_date__c = Date.newInstance(Date.today().year(), Date.today().addMonths(-1).month(), 27)
		);
		
		insert new Income_Estimation__c(
			AVG_Income_amount__c = 3444452,
			Account__c = acc1.Id,
			BOT_ID__c = '63462',
			Income_External_Key__c = '6226410011000000000000000000006226412019-02-28',
			Model_Type__c = 'Non-OD customer',
			Valida_date__c = '10 MAR 2019 - 09 APR 2019',
			as_of_date__c = Date.newInstance(Date.today().year() , Date.today().addMonths(-2).month(), 27)
		);       
        
	}*/
    
    private static Id createAccount(Id userId){
        RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
            // Account acc1 = RTL_TestUtility.createAccounts(1 , false).get(0);
        Account acc1 = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
        acc1.Customer_Type__c = 'Individual';
        acc1.OwnerID = userId;
        acc1.RecordType = Existing_Customer;
        acc1.RecordTypeId = Existing_Customer.Id;
        acc1.BIZ_FLAG__c = 'Y';
        acc1.WOW_FLAG__c = 'Y';
        acc1.Total_Revenue_Baht__c = 100000001;
        acc1.Warning_Code__c = 'I078';
        acc1.Business_Type_Code__c = 'C1023';
        acc1.NAMBRL__c = 'Bad';
        insert acc1;    
        return acc1.id;
    }
    
    private static void createProduct(String accId){
        List<Product2> prod2List = new List<Product2>();
       		Product2 prod2 = new Product2(Name = 'Deposit', Product_Domain__c ='Deposit & Investment', Family = 'Hardware', IsActive=true);
            prod2List.add(prod2);        
        insert prod2List;
            
        List<Product_Information_On_Hand__c> prodOnHandList = new List<Product_Information_On_Hand__c>();
        Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = accId;
        onhand1.Product_Hierachy_Code__c = String.valueOf(prod2List[0].id);
        prodOnHandList.add(onhand1);
        insert prodOnHandList;
        
        List<Product_Information_Detail__c> prodDetailList = new List<Product_Information_Detail__c>();
        Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = prodOnHandList[0].id;
        detail1.Customer__c = accId;
        detail1.ACC_S1B__c = 'Y';
        detail1.LATEST_MTH_TXN__c = 8;
        detail1.LATEST_SIXMTH_TXN__c = 8;
        prodDetailList.add(detail1);
        Product_Information_Detail__c detail3 = new Product_Information_Detail__c();
        detail3.Product_Information__c = prodOnHandList[0].id;
        detail3.Customer__c = accId;
        detail3.ACC_S1B__c = 'N';
        detail3.LATEST_MTH_TXN__c = 9;
        detail3.LATEST_SIXMTH_TXN__c = 9;
        
        prodDetailList.add(detail3);
        insert prodDetailList;
    }

	@isTest 
    private static void test_method_MultiIncome_positive() {
		
        User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		
		System.runAs(user){
			Id Id = createAccount(user.id);
			//Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Accountlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			Test.startTest();
                MiniCSV_Controller objClass = new MiniCSV_Controller();
                String Deeplink_DEPOSIT_ACCOUNT = objClass.Deeplink_DEPOSIT_ACCOUNT;
                String Deeplink_S1B = objClass.Deeplink_S1B;
                String Deeplink_BIZ_TOUCH = objClass.Deeplink_BIZ_TOUCH;
                String Deeplink_BIZ_WOW = objClass.Deeplink_BIZ_WOW;
                String Deeplink_BUSINESS_CLICK = objClass.Deeplink_BUSINESS_CLICK;
                List<MiniCSV_Controller.IncomeInfo> incomeInfolist = objClass.incomeInfo;
            Test.stopTest();
            
		}
        
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

	@isTest 
    private static void test_method_CalloutCompanyDetailEnliteService_positive() {
		Test.startTest();
        User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		
		System.runAs(user){
			Id Id = createAccount(user.id);
			//Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Accountlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			
			MiniCSV_Controller objClass = new MiniCSV_Controller();
			Boolean isNotMappingISIC =  objClass.companyInfo.isNotMappingISIC;
			Boolean isJuristicType =  objClass.companyInfo.isJuristicType;
			Decimal netWorth =  objClass.companyInfo.netWorth;
			Decimal totalRevenue =  objClass.companyInfo.totalRevenue;
			List<SmartBDMEnliteCompanyDetail.ShareHolder> shareHolders =  objClass.companyInfo.shareHolders;
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

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
			response.setBody('{"GetExcuteSearchResponseCompanyList"}');
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

			
		}
        Test.stopTest();
	}

	@isTest
    private static void test_method_CalloutCompanyDetailEnliteService_negative() {
        Test.startTest();
        User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		
		System.runAs(user){
			Id Id = createAccount(user.id);
			//Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Accountlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			
			MiniCSV_Controller objClass = new MiniCSV_Controller();
            String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

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
            
        }
        Test.stopTest();
    }


	@isTest 
    private static void test_method_MiniCSV_Controller_Customer() {
		

		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        
		System.runAs(user){
			Id Id = createAccount(user.id);
            //Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
            
			createProduct(Id);
			
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Accountlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			Test.startTest();	
                MiniCSV_Controller ext = new MiniCSV_Controller();
                Boolean b = ext.isSF1;	
                ext.getAccount();
                ext.getLeads();
                ext.getCreditInfoes();
                ext.getCollateralDetails();	
                ext.getDepositInfoes();	
    
                String summaryInfo = ext.codeList.summaryInfo;
                // xxxMTH_TXN = Medium
                List<Product_Information_Detail__c> tmp_detailProd = [SELECT Id, LATEST_MTH_TXN__c, LATEST_SIXMTH_TXN__c
                    FROM Product_Information_Detail__c 
                    WHERE Customer__c =: ext.account.id and Product_Domain__c = 'Deposit & Investment'
                ];
                Product_Information_Detail__c prodDetail = new Product_Information_Detail__c(Id = tmp_detailProd[0].Id );
                prodDetail.LATEST_MTH_TXN__c = 35;
                prodDetail.LATEST_SIXMTH_TXN__c = 35;
                update prodDetail;
                tmp_detailProd.get(1).LATEST_MTH_TXN__c = 35;
                tmp_detailProd.get(1).LATEST_SIXMTH_TXN__c = 35;
                update tmp_detailProd;
                ext.CheckingProductHoldingInfo();
                String ActionRecommand = ext.ActionRecommand;
                String warning_code_account = ext.warning_code_account;
                String FullNameContactInfo = ext.FullNameContactInfo;
            Test.stopTest();
		}

        
	}

	
	
	@isTest 
    private static void test_method_MiniCSV_Controller_Lead() {
		
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		System.runAs(user){
			//Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			Id Id = createAccount(user.id);
            createProduct(Id);
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Leadlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			System.currentPageReference().getParameters().put('isdtp', 'p1');
			
            Test.startTest();
                MiniCSV_Controller ext = new MiniCSV_Controller();
                Boolean b = ext.isSF1;	
                ext.getAccount();
                ext.getLeads();
                ext.getCreditInfoes();
                ext.getCollateralDetails();		
                ext.getDepositInfoes();
    
                // xxxMTH_TXN = High
                List<Product_Information_Detail__c> tmp_detailProd = [SELECT Id, LATEST_MTH_TXN__c, LATEST_SIXMTH_TXN__c
                    FROM Product_Information_Detail__c 
                    WHERE Customer__c =: ext.account.id and Product_Domain__c = 'Deposit & Investment'
                ];
                tmp_detailProd.get(1).LATEST_MTH_TXN__c = 80;
                tmp_detailProd.get(1).LATEST_SIXMTH_TXN__c = 80;
                update tmp_detailProd;
                ext.CheckingProductHoldingInfo();
			Test.stopTest();
		}
        
	}

	@isTest 
    private static void test_method_MiniCSV_Controller_getFullNameContactLead() {
		
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        
		System.runAs(user){
			Id Id = createAccount(user.id);
			///Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			//MiniCSV_Controller ext;

			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', Id);
			System.currentPageReference().getParameters().put('refType', 'Leadlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			
            Test.startTest();
                Campaign cam = [SELECT Id, Name FROM Campaign WHERE Name = 'ChildCam1' LIMIT 1];

                Lead Lead1 = CreateValidLead(user.id, Id);
                Lead1.Primary_Campaign__c = cam.Id;
                insert Lead1;
                MiniCSV_Controller ext = new MiniCSV_Controller();
                //ext.getFullNameContactLead();
    
    
                // Create Contact
                Contact cont1 = new Contact();
                cont1.FirstName = 'SmartBDM';
                cont1.LastName = 'II';
                cont1.Accountid = Id;
                insert cont1;
                //MiniCSV_Controller ext = new MiniCSV_Controller();
                ext.getFullNameContactLead();
    
    
                //Negative throw Exception - Not availiable
                ext.contact = null;
                ext.leads = null;
                ext.getFullNameContactLead();
            Test.stopTest();
		}	
		
	}

	@isTest 
    private static void test_method_MiniCSV_Controller_Negative() {
		
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
		System.runAs(user){
			//Id Id = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
			Id Id = createAccount(user.id);
			Test.setCurrentPageReference(new PageReference('Page.Mini_CSV'));
			System.currentPageReference().getParameters().put('Id', '001p0000008XXXS');
			System.currentPageReference().getParameters().put('refType', 'Leadlist');
			System.currentPageReference().getParameters().put('retURL', ApexPages.currentPage().getUrl());
			Test.startTest();
                MiniCSV_Controller ext = new MiniCSV_Controller();
                ext.collateral_details = null;
                ext.credit_infoes = null;
                ext.product_holding_info = null;
                ext.BDMLatestMTHTXN = null;
                ext.BDMLatestSIXMTHTXN = null;
                ext.account = null;
                List<Collateral_Detail__c> collateral_details = ext.collateral_details;
                List<Product_Information_Detail__c> credit_infoes = ext.credit_infoes;
                List<Product_Information_Detail__c> product_holding_info = ext.product_holding_info;
                String BDMLatestMTHTXN = ext.BDMLatestMTHTXN;
                String BDMLatestSIXMTHTXN = ext.BDMLatestSIXMTHTXN;
			Test.stopTest();

		}	
		
	}

}