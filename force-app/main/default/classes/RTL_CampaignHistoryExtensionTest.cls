@isTest
private class RTL_CampaignHistoryExtensionTest {
  static {
    TestUtils.createAppConfig();
  }
  @testSetup
  static void setupData() {
    TestUtils.createAppConfig();
    RecordType rt = [
      SELECT id
      FROM recordType
      WHERE DeveloperName = 'Exclusive_Campaign_Active'
    ];
    RecordType masterRt = [
      SELECT id, DeveloperName
      FROM recordType
      WHERE DeveloperName = 'Mass_Campaign_Active'
    ];

    RecordType localRt = [
      SELECT id, DeveloperName
      FROM recordType
      WHERE DeveloperName = 'Local_Exclusive_Campaign_Active'
    ];
    RecordType massRt = [
      SELECT id, DeveloperName
      FROM recordType
      WHERE DeveloperName = 'Mass_Campaign_Active'
    ];

    RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c(
      Name = 'Local Exclusive Campaign Running No.',
      DateValue__c = '170717',
      Day__c = '17',
      Month__c = '07',
      Year__c = '17',
      Running_No__c = '01'
    );
    insert rn;

    RTL_Campaign_Endpoint__c cmep06 = new RTL_Campaign_Endpoint__c(
      Name = 'Campaign TO HQ INT06',
      RTL_Endpoint__c = 'https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign'
    );
    insert cmep06;

    RTL_Campaign_Endpoint__c cmep07 = new RTL_Campaign_Endpoint__c(
      Name = 'Campaign TO HQ INT07',
      RTL_Endpoint__c = 'https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveSmsussdRegistration'
    );
    insert cmep07;

    RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
      Name = 'Campaign Member Running No',
      Running_No__c = '000000'
    );

    insert cmrn;

    List<AppConfig__c> mc = new List<AppConfig__c>();
    mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
    insert mc;

    Branch_and_zone__c bz = new Branch_and_zone__c();
    bz.Branch_Code__c = '611';
    insert bz;

    User u = RTL_TestUtility.createUsers(
        1,
        'UserTest',
        'User1',
        'test@email.com',
        false
      )
      .get(0);
    u.RTL_Branch_Code__c = '611';
    insert u;

    List<Data_Security_Matrix__c> dsmlst = new List<Data_Security_Matrix__c>();

    Data_Security_Matrix__c dsm = new Data_Security_Matrix__c(
      Section_Name__c = 'RtlCust:Campaign History',
      Profile_Name__c = 'System Administrator',
      Access_Type__c = 'All'
    );
    Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c(
      Section_Name__c = 'RtlCust:Campaign History',
      Profile_Name__c = 'TMB System Administrator',
      Access_Type__c = 'All'
    );
    dsmlst.add(dsm);
    dsmlst.add(dsm2);
    insert dsmlst;

    List<Campaign> camList = new List<Campaign>();
    // Campaign masterC = RTL_TestUtility.createMasterCampaign(
    //   'MasterCam1',
    //   'D20171001',
    //   'Exclusive',
    //   'MB',
    //   u
    // );
    // // masterC.RTL_Category__c = 'Sales';
    // // masterC.RTL_Campaign_Objective__c = 'Drop-Lead';
    // masterC.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // masterC.startDate = Date.today().addMonths(-8);
    // camList.add(masterC);

    Campaign masterCamCusReq = RTL_TestUtility.createMasterCampaign(
      'MasterCam2 Cust Req',
      'D20171002',
      'Exclusive',
      'MB',
      u
    );
    camList.add(masterCamCusReq);

    // Campaign masterMassReq = RTL_TestUtility.createMasterCampaign(
    //   'MasterCam4 Mass',
    //   'M20171002',
    //   'Mass',
    //   'MB',
    //   u
    // );
    // masterMassReq.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // masterMassReq.startDate = Date.today().addMonths(-8);

    // camList.add(masterMassReq);

    // Campaign masterLocalReq = RTL_TestUtility.createMasterCampaign(
    //   'MasterCam3 Local',
    //   'L20171002',
    //   'Local Exclusive',
    //   'MB',
    //   u
    // );
    // masterLocalReq.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // masterLocalReq.startDate = Date.today().addMonths(-8);

    // camList.add(masterLocalReq);

    Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
    List<Campaign> childCamList = new List<Campaign>();
    Campaign campLocal = new Campaign();
    campLocal.RTL_Campaign_Code_10_digits__c = 'L20171002A';
    campLocal.Name = 'Campaign_campLocal';
    campLocal.Segment__c = 'MB';
    campLocal.OwnerId  = UserInfo.getUserId();
    campLocal.RecordTypeId = recordTypeId;
    campLocal.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    campLocal.RTL_Call_End_Date__c = Date.today().addDays(7);
    campLocal.startDate = Date.today().addMonths(-8);
    campLocal.endDate = Date.today().addDays(7);
    camList.add(campLocal);

    Campaign campExclu = new Campaign();
    campExclu.RTL_Campaign_Code_10_digits__c = 'D20171002A';
    campExclu.Name = 'Campaign_campExclu';
    campExclu.Segment__c = 'MB';
    campExclu.OwnerId  = UserInfo.getUserId();
    campExclu.RecordTypeId = recordTypeId;
    campExclu.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    campExclu.RTL_Call_End_Date__c = Date.today().addDays(7);
    campExclu.startDate = Date.today().addMonths(-8);
    campExclu.endDate = Date.today().addDays(7);
    camList.add(campExclu);

    Campaign campMass = new Campaign();
    campMass.RTL_Campaign_Code_10_digits__c = 'M20171002A';
    campMass.Name = 'Campaign_campMass';
    campMass.Segment__c = 'MB';
    campMass.OwnerId  = UserInfo.getUserId();
    campMass.RecordTypeId = recordTypeId;
    campMass.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    campMass.RTL_Call_End_Date__c = Date.today().addDays(7);
    campMass.startDate = Date.today().addMonths(-8);
    campMass.endDate = Date.today().addDays(7);
    camList.add(campMass);

    insert camList;
    // Campaign childC = RTL_TestUtility.createChildCampaign(
    //   'ChildCam1',
    //   '1',
    //   masterC,
    //   rt
    // );
    // childC.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // childC.startDate = Date.today().addMonths(-8);
    // childCamList.add(childC);

    Campaign childC2 = RTL_TestUtility.createChildCampaign(
      'ChildCam2 Cust Request',
      '2',
      masterCamCusReq,
      rt
    );
    childCamList.add(childC2);

    // Campaign childC3 = RTL_TestUtility.createChildCampaign(
    //   'ChildCam3 Local',
    //   '3',
    //   masterLocalReq,
    //   localRt
    // );
    // childC3.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // childC3.startDate = Date.today().addMonths(-8);
    // childCamList.add(childC3);

    // Campaign childC4 = RTL_TestUtility.createChildCampaign(
    //   'ChildCam4 Mass',
    //   '2',
    //   masterMassReq,
    //   massRt
    // );
    // childC4.RTL_Call_Start_Date__c = Date.today().addMonths(-8);
    // childC4.startDate = Date.today().addMonths(-8);
    // childCamList.add(childC4);
    insert childCamList;
    // masterC.RTL_Campaign_Objective__c = 'Drop-Lead';
    // update masterC;

    List<CampaignMemberStatus> camStatusList = new List<CampaignMemberStatus>();
    // CampaignMemberStatus cms = new CampaignMemberStatus();
    // cms.CampaignId = masterCamCusReq.id;
    // cms.SortOrder = 9;
    // cms.Label = 'aaa';
    // camStatusList.add(cms);

    // CampaignMemberStatus cms2 = new CampaignMemberStatus();
    // cms2.CampaignId = childC2.id;
    // cms2.SortOrder = 8;
    // cms2.Label = 'aaa';
    // camStatusList.add(cms2);

    // masterCamCusReq.RTL_Category__c = 'Sales';
    // masterCamCusReq.RTL_Campaign_Objective__c = 'Drop-Lead';
    // update camList;

    // CampaignMemberStatus cms3 = new CampaignMemberStatus();
    // cms3.CampaignId = masterC.id;
    // cms3.SortOrder = 9;
    // cms3.Label = 'aaa2';
    // // camStatusList.add(cms3);
    // insert cms3;

    // CampaignMemberStatus cms4 = new CampaignMemberStatus();
    // cms4.CampaignId = childC.id;
    // cms4.SortOrder = 8;
    // cms4.Label = 'aaa2';
    // insert cms4;

    // insert camStatusList;

    // masterC.RTL_Category__c = 'Sales';
    // masterC.RTL_Campaign_Objective__c = 'Drop-Lead';
    // update masterC;

    List<Lead> leadList = new List<Lead>();
    Lead l = new Lead(
      Company = 'JohnMiller',
      LastName = 'Mike',
      Status = 'Open'
    );
    leadList.add(l);

    insert leadList;

    List<CampaignMember> cml = new List<CampaignMember>();

    CampaignMember cm1 = new CampaignMember();
    cm1.LeadId = l.id;
    cm1.CampaignId = campExclu.id;
    cml.add(cm1);

    Account acct = RTL_TestUtility.createAccounts(1, true).get(0);

    RTL_Fulfillment__c ffm1 = new RTL_Fulfillment__c();
    insert ffm1;

    Contact ct = RTL_TestUtility.createContacts(acct);
    ct.OwnerId = u.id;
    insert ct;

    CampaignMember cm2 = new CampaignMember();
    cm2.ContactId = ct.id;
    cm2.CampaignId = campExclu.id;
    cm2.Customer__c = acct.id;
    cml.add(cm2);

    //====================== Customer Request =============================

    CampaignMember cm3 = new CampaignMember();
    cm3.ContactId = ct.id;
    cm3.CampaignId = childC2.id;
    cml.add(cm3);

    //===================== Local Exclusive ==============================

    CampaignMember cm4 = new CampaignMember();
    cm4.ContactId = ct.id;
    cm4.CampaignId = campLocal.id;
    cm4.Customer__c = acct.id;
    cml.add(cm4);

    //===================== Mass ==================================

    CampaignMember cm5 = new CampaignMember();
    cm5.ContactId = ct.id;
    cm5.CampaignId = campMass.id;
    cml.add(cm5);

    //===================== exclusive ==================================

    // CampaignMember cm6 = new CampaignMember();
    // cm6.ContactId = ct.id;
    // cm6.CampaignId = childC.id;
    // cm6.Customer__c = acct.id;
    // cml.add(cm6);

    insert cml;
  }

  @isTest
  static void test_method_one() {
    Test.startTest();
    Campaign camMassMaster = [
      SELECT id, isActive
      FROM campaign
      WHERE RTL_Campaign_Code_10_digits__c = :'M20171002A'
      LIMIT 1
    ];
    camMassMaster.Approvedflag__c = true;
    update camMassMaster;

    // Campaign childC = [
    //   SELECT id, Approvedflag__c
    //   FROM Campaign
    //   WHERE name = 'ChildCam4 Mass'
    // ];
    // childC.Approvedflag__c = true;
    // update childC;
    // Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    // req.setObjectId(camMassMaster.Id);
    // Approval.ProcessResult result = Approval.process(req);

    // Approval.ProcessSubmitRequest req1 =
    // new Approval.ProcessSubmitRequest();
    // req1.setComments('Submitting request for approval.');
    // req1.setObjectId(camMassMaster.id);
    // req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
    // // Submit on behalf of a specific submitter
    // req1.setSubmitterId(UserInfo.getUserId());

    // // Submit the record to specific process and skip the criteria evaluation
    // req1.setProcessDefinitionNameOrId('RTL_Campaign_Approval_Mass');
    // req1.setSkipEntryCriteria(true);
    // Approval.ProcessResult result = Approval.process(req1);

    Account acc = [SELECT ID FROM Account LIMIT 1];
    PageReference pageRef = Page.RTL_CampaignHistory;
    pageRef.getParameters().put('id', String.valueOf(acc.Id));
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);

    che.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.massCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.campaignPeriodMethod = 'past';
    try {
      che.setCampaignPeriod();
    } catch (Exception e) {
    }
    che.navigateLocalEx();
    che.nextLocalEx();
    che.previousLocalEx();

    che.navigateMass();
    che.nextMass();
    che.previousMass();

    // che.navigateExclusive();

    try {
      che.reloadAllData();
    } catch (Exception e) {
    }

    string campaignLiteURL = che.campaignLiteURL;
    boolean isRenderCampaign = che.isRenderCampaign;
    boolean isRenderSMS = che.isRenderSMS;
    Boolean isRenderCallingCampaign = che.isRenderCallingCampaign;

    Test.stopTest();
  }

  @isTest
  static void test_method_two() {
    Test.startTest();

    Account acc = [SELECT ID FROM Account LIMIT 1];
    RTL_Fulfillment__c ffm = new RTL_Fulfillment__c(RTL_Customer__c = acc.Id);
    insert ffm;
    PageReference pageRef = Page.RTL_CampaignHistory;
    pageRef.getParameters().put('id', String.valueOf(acc.Id));
    pageRef.getParameters().put('tabName', 'fulfillment');
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);
    che.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.massCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.navigateLocalEx();
    che.nextLocalEx();
    che.previousLocalEx();

    che.navigateMass();
    che.nextMass();
    che.previousMass();

    che.nextFulfillment();
    che.navigateFulfillment();

    che.previousSMS();
    che.nextSMS();
    che.navigateSMS();

    //che.navigateExclusive();
    // che.nextExclusive();
    // che.previousExclusive();
    che.navigateCustomerRequest();
    che.nextCustomerRequest();
    che.previousCustomerRequest();
    che.call_previousCustomerRequest();
    che.call_nextCustomerRequest();
    che.call_navigateCustomerRequest();

    che.campaignPeriodMethod = 'current';
    try {
      che.setCampaignPeriod();
      che.previousFulfillment();
    } catch (Exception e) {
    }
    che.displayData();

    pageRef.getParameters().put('tabName', 'sms');
    Test.setCurrentPage(pageRef);
    che.displayData();

    pageRef.getParameters().put('tabName', 'campaign');
    Test.setCurrentPage(pageRef);
    che.displayData();

    Test.stopTest();
  }

  @isTest
  static void test_method_three() {
    Test.startTest();

    Account acc = [SELECT ID FROM Account LIMIT 1];

    PageReference pageRef = Page.RTL_CampaignHistory;
    pageRef.getParameters().put('id', String.valueOf(acc.Id));
    pageRef.getParameters().put('tabName', 'fulfillment');
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);
    che.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.massCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.navigateLocalEx();
    che.nextLocalEx();
    che.previousLocalEx();

    che.navigateMass();
    che.nextMass();
    che.previousMass();

    che.nextFulfillment();
    che.navigateFulfillment();

    che.previousSMS();
    che.nextSMS();
    che.navigateSMS();

    //che.navigateExclusive();
    // che.nextExclusive();
    // che.previousExclusive();
    che.navigateCustomerRequest();
    che.nextCustomerRequest();
    che.previousCustomerRequest();
    // che.call_previousExclusive();
    // che.call_nextExclusive();
    // che.call_navigateExclusive();
    che.campaignPeriodMethod = '1year';
    try {
      che.setCampaignPeriod();
      che.previousFulfillment();
    } catch (Exception e) {
    }
    che.displayData();

    pageRef.getParameters().put('tabName', 'callingcampaign');
    Test.setCurrentPage(pageRef);
    che.displayData();

    pageRef.getParameters().put('tabName', 'campaign');
    Test.setCurrentPage(pageRef);
    che.displayData();

    Test.stopTest();
  }

  // @isTest
  // static void test_method_four() {
  //   List<Integer> totalPageList = new List<Integer>();
  //   Integer clickPage = 10;
  //   for (Integer i = 0; i < 20; i++) {
  //     totalPageList.add(i);
  //   }
  //   Test.startTest();

  //   Account acc = [SELECT ID FROM Account LIMIT 1];

  //   ApexPages.StandardController sc = new ApexPages.StandardController(acc);
  //   RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);
  //   che.pagination(totalPageList, clickPage);

  //   try {
  //     che.reloadAllData();
  //   } catch (Exception e) {
  //   }
  //   che.requestInt06();
  //   che.processResponseInt06();
  //   che.processResponseInt07();
  //   Test.stopTest();
  // }

  @isTest
  static void test_INT07() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    String accountId = accList[0].Id;
    
    Test.startTest();
    HttpResponse response = new HttpResponse();
    String jsonBody = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>'
    +'<SmsRegistrationResponse>'
    +'<CampaignSmsRegistrationList>'
    +'<CampaignSmsRegistration>'
    +'<SourceUniqueID/>'
    +'<MobilePhoneNumber>081xxxxxxx</MobilePhoneNumber>'
    +'<CampaignCode>DFXXLA122B</CampaignCode>'
    +'<Message/>'
    +'<Content/>'
    +'<RegisterDate/>'
    +'<ApplyChannel/>'
    +'</CampaignSmsRegistration>'
    +'</CampaignSmsRegistrationList>'
    +'<Header>'
    +'<ErrorStatus>success</ErrorStatus>'
    +'<ErrorCode>00</ErrorCode>'
    +'<ErrorDescription/>'
    +'<TotalRecords>1</TotalRecords>'
    +'</Header>'
    +'</SmsRegistrationResponse>';

    response.setStatusCode(200);
    response.setBody(jsonBody); 
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, jsonBody));
    // RTL_CampaignHistoryExtension.OneAppResponse result = ActivityTimelineController.getOneAppData(accountId);
    Account acc = [SELECT ID FROM Account LIMIT 1];

    PageReference pageRef = Page.RTL_CampaignHistory;
    pageRef.getParameters().put('id', String.valueOf(acc.Id));
    pageRef.getParameters().put('tabName', 'sms');
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);
    che.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.massCampaignRecordTypeDevName.add('Dummy_Campaign');
    // Invoke the continuation by calling the action method
    Continuation conti = (Continuation) che.requestInt07();
    // Verify that the continuation has the proper requests
    Map<String, HttpRequest> requests = conti.getRequests();
    // system.assert(requests.size() == 1);
    // system.assert(requests.get(che.requestLabel) != null);
    
    
    // Set the fake response for the continuation
    Test.setContinuationResponse(che.requestLabel, response);
    // Invoke callback method
    Object result = Test.invokeContinuationMethod(che, conti);

    test.stopTest();
  }

  @isTest
  static void test_INT06() {
    List<Account> accList = [SELECT Id FROM Account LIMIT 1];
    String accountId = accList[0].Id;
    
    Test.startTest();
    HttpResponse response = new HttpResponse();
    String jsonBody = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>'
        +'<CampaignMemberResponse>'
        +'<CampaignMemberList>'
        +'<CampaignMember>'
        +'<CampaignCode>DFXXLA122B</CampaignCode>'
        +'<MarketingCode>DFXXLA122B0000051187</MarketingCode>'
        +'<ProductOfferString>1:Investment;2:Life</ProductOfferString>'
        +'<CampaignChannel>BRANCH</CampaignChannel>'
        +'<MobileNumber>081xxxxxxx</MobileNumber>'
        +'<UpdateDate>2022-03-03T00:00:00</UpdateDate>'
        +'<ResultContact/>'
        +'<AgentID/>'
        +'<ResultDetail/>'
        +'<ResultBusiness/>'
        +'<OfferResult/>'
        +'<ContactDate/>'
        +'<Reason/>'
        +'<SmsMessage/>'
        +'<SmsContent/>'
        +'<RegisterDate/>'
        +'<DisplayFlag>N/A</DisplayFlag>'
        +'<DisplayDate/>'
        +'<ClickFlag>N/A</ClickFlag>'
        +'<ClickDate/>'
        +'<EmailSendDate/>'
        +'<EmailRejectDate/>'
        +'<EmailOpenFlag>N/A</EmailOpenFlag>'
        +'<EmailOpenDate/>'
        +'<EmailClickFlag>N/A</EmailClickFlag>'
        +'<EmailClickDate/>'
        +'<ContactSubStatus/>'
        +'<OfferSubResult/>'
        +'<PersonalizedMessage/>'
        +'</CampaignMember>'
        +'<CampaignMember>'
        +'<CampaignCode>D9XXLA122B</CampaignCode>'
        +'<MarketingCode>D9XXLA122B0000051187</MarketingCode>'
        +'<ProductOfferString>1:Investment;2:Life</ProductOfferString>'
        +'<CampaignChannel>BRANCH</CampaignChannel>'
        +'<MobileNumber>081xxxxxxx</MobileNumber>'
        +'<UpdateDate>2022-03-03T00:00:00</UpdateDate>'
        +'<ResultContact/>'
        +'<AgentID/>'
        +'<ResultDetail/>'
        +'<ResultBusiness/>'
        +'<OfferResult/>'
        +'<ContactDate/>'
        +'<Reason/>'
        +'<SmsMessage/>'
        +'<SmsContent/>'
        +'<RegisterDate/>'
        +'<DisplayFlag>N/A</DisplayFlag>'
        +'<DisplayDate/>'
        +'<ClickFlag>N/A</ClickFlag>'
        +'<ClickDate/>'
        +'<EmailSendDate/>'
        +'<EmailRejectDate/>'
        +'<EmailOpenFlag>N/A</EmailOpenFlag>'
        +'<EmailOpenDate/>'
        +'<EmailClickFlag>N/A</EmailClickFlag>'
        +'<EmailClickDate/>'
        +'<ContactSubStatus/>'
        +'<OfferSubResult/>'
        +'<PersonalizedMessage/>'
        +'</CampaignMember>'
        +'</CampaignMemberList>'
        +'<Header>'
        +'<ErrorStatus>success</ErrorStatus>'
        +'<ErrorCode>00</ErrorCode>'
        +'<ErrorDescription/>'
        +'<TotalRecords>2</TotalRecords>'
        +'</Header>'
        +'</CampaignMemberResponse>';

    response.setStatusCode(200);
    response.setBody(jsonBody); 
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, jsonBody));
    // RTL_CampaignHistoryExtension.OneAppResponse result = ActivityTimelineController.getOneAppData(accountId);
    Account acc = [SELECT ID FROM Account LIMIT 1];

    PageReference pageRef = Page.RTL_CampaignHistory;
    pageRef.getParameters().put('id', String.valueOf(acc.Id));
    pageRef.getParameters().put('tabName', 'callingcampaign');
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
    RTL_CampaignHistoryExtension che = new RTL_CampaignHistoryExtension(sc);
    che.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.massCampaignRecordTypeDevName.add('Dummy_Campaign');
    che.int06DataList = jsonBody;
    system.debug('Teset' + che.massCampaignRecordTypeDevName);
    Continuation conti = (Continuation) che.requestInt06();
    System.debug('Conti requestInt 06:' + conti);
    Map<String, HttpRequest> requests = conti.getRequests();
    
    Test.setContinuationResponse(che.requestLabel, response);
    Object result = Test.invokeContinuationMethod(che, conti);
    che.call_navigateExclusive();
    che.call_previousExclusive();
    che.call_nextExclusive();
    test.stopTest();
  }
  @isTest
  static void test_INT06_pastcampaign(){
        //Callout Campaign
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;
        
        Test.startTest();
        HttpResponse response = new HttpResponse();
        String jsonBody = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>'
            +'<CampaignMemberResponse>'
            +'<CampaignMemberList>'
            +'<CampaignMember>'
            +'<CampaignCode>DFXXLA122B</CampaignCode>'
            +'<MarketingCode>DFXXLA122B0000051187</MarketingCode>'
            +'<ProductOfferString>1:Investment;2:Life</ProductOfferString>'
            +'<CampaignChannel>BRANCH</CampaignChannel>'
            +'<MobileNumber>081xxxxxxx</MobileNumber>'
            +'<UpdateDate>2022-03-03T00:00:00</UpdateDate>'
            +'<ResultContact/>'
            +'<AgentID/>'
            +'<ResultDetail/>'
            +'<ResultBusiness/>'
            +'<OfferResult/>'
            +'<ContactDate/>'
            +'<Reason/>'
            +'<SmsMessage/>'
            +'<SmsContent/>'
            +'<RegisterDate/>'
            +'<DisplayFlag>N/A</DisplayFlag>'
            +'<DisplayDate/>'
            +'<ClickFlag>N/A</ClickFlag>'
            +'<ClickDate/>'
            +'<EmailSendDate/>'
            +'<EmailRejectDate/>'
            +'<EmailOpenFlag>N/A</EmailOpenFlag>'
            +'<EmailOpenDate/>'
            +'<EmailClickFlag>N/A</EmailClickFlag>'
            +'<EmailClickDate/>'
            +'<ContactSubStatus/>'
            +'<OfferSubResult/>'
            +'<PersonalizedMessage/>'
            +'</CampaignMember>'
            +'<CampaignMember>'
            +'<CampaignCode>D9XXLA122B</CampaignCode>'
            +'<MarketingCode>D9XXLA122B0000051187</MarketingCode>'
            +'<ProductOfferString>1:Investment;2:Life</ProductOfferString>'
            +'<CampaignChannel>BRANCH</CampaignChannel>'
            +'<MobileNumber>081xxxxxxx</MobileNumber>'
            +'<UpdateDate>2022-03-03T00:00:00</UpdateDate>'
            +'<ResultContact/>'
            +'<AgentID/>'
            +'<ResultDetail/>'
            +'<ResultBusiness/>'
            +'<OfferResult/>'
            +'<ContactDate/>'
            +'<Reason/>'
            +'<SmsMessage/>'
            +'<SmsContent/>'
            +'<RegisterDate/>'
            +'<DisplayFlag>N/A</DisplayFlag>'
            +'<DisplayDate/>'
            +'<ClickFlag>N/A</ClickFlag>'
            +'<ClickDate/>'
            +'<EmailSendDate/>'
            +'<EmailRejectDate/>'
            +'<EmailOpenFlag>N/A</EmailOpenFlag>'
            +'<EmailOpenDate/>'
            +'<EmailClickFlag>N/A</EmailClickFlag>'
            +'<EmailClickDate/>'
            +'<ContactSubStatus/>'
            +'<OfferSubResult/>'
            +'<PersonalizedMessage/>'
            +'</CampaignMember>'
            +'</CampaignMemberList>'
            +'<Header>'
            +'<ErrorStatus>success</ErrorStatus>'
            +'<ErrorCode>00</ErrorCode>'
            +'<ErrorDescription/>'
            +'<TotalRecords>2</TotalRecords>'
            +'</Header>'
            +'</CampaignMemberResponse>';
    
        response.setStatusCode(200);
        response.setBody(jsonBody); 

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, jsonBody));
        Account acc = [SELECT ID FROM Account LIMIT 1];

        PageReference pageRef2 = Page.RTL_CampaignHistory;
        pageRef2.getParameters().put('id', String.valueOf(acc.Id));
        pageRef2.getParameters().put('tabName', 'campaign');
        Test.setCurrentPage(pageRef2);
    
        ApexPages.StandardController sc2 = new ApexPages.StandardController(acc);
        RTL_CampaignHistoryExtension che2 = new RTL_CampaignHistoryExtension(sc2);
        che2.exclusiveCampaignRecordTypeDevName.add('Dummy_Campaign');
        che2.localExCampaignRecordTypeDevName.add('Dummy_Campaign');
        che2.massCampaignRecordTypeDevName.add('Dummy_Campaign');
        che2.campaignPeriodMethod = 'past';
        che2.int06DataList = jsonBody;
        try {
          che2.setCampaignPeriod();
        } catch (Exception e) {
        }
        Continuation conti2 = (Continuation) che2.requestInt06();
        System.debug('Conti requestInt 06:' + conti2);
        Map<String, HttpRequest> requests2 = conti2.getRequests();
    
    
        Test.setContinuationResponse(che2.requestLabel, response);
        Object result2 = Test.invokeContinuationMethod(che2, conti2);
        che2.navigateExclusive();
        che2.nextExclusive();
        che2.previousExclusive();
  }
}