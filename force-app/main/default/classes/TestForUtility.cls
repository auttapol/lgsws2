@IsTest
public class TestForUtility{
	 private static void createAppConfigList(){     
        //Create For After Refresh Sandbox
        List<For_After_Refresh_Sandbox__c> afterSBList = new List<For_After_Refresh_Sandbox__c>(); 

        For_After_Refresh_Sandbox__c afterSB = new For_After_Refresh_Sandbox__c();
        afterSB.Name = 'TEST';
        afterSB.Field_Name__c = 'Value__c';
        afterSB.Name__c = 'AppConfig__c';
        afterSB.Value__c = 'GoogleMapSFKey2';

        afterSBList.add(afterSB);
        insert afterSBList;

        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'GoogleMapSFKey1';
        Aconfig.Value__c = 'GoogleMapSFKey1';        
        apps.add(Aconfig);
        
        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'GoogleMapSFKey2';
        Aconfig2.Value__c = 'GoogleMapSFKey2'; 
        apps.add(Aconfig2);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'FX_Order_Email_Admin';
        Aconfig3.Value__c = 'FX_Order_Email_Admin'; 
        apps.add(Aconfig3);

        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'FX_BCP_Report';
        Aconfig4.Value__c = 'FX_BCP_Report'; 
        apps.add(Aconfig4);

        insert apps;
    }
    //Test class for SandboxRefresh
    public static testmethod void testSandboxPostCopyScript() 
    {
    
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();
        
        Test.testSandboxPostCopyScript(
                new AfterSandboxRefresh(), 
                UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId()
                , UserInfo.getOrganizationName()
        ); 
        
        List<AppConfig__c> appList = [SELECT Id 
                                            ,Value__c
                                        FROM AppConfig__c 
                                        WHERE Name = 'FilterRetailSegment'];

        System.assertEquals(appList.get(0).Value__c, '5|6|7|8|9');

        List<AppConfig__c> appList2 = [SELECT Id 
                                            ,Value__c
                                        FROM AppConfig__c 
                                        WHERE Name = 'GoogleMapSFKey2'];

        System.assertEquals(appList2.get(0).Value__c, 'FOR_SANDBOX');

        Test.stopTest();
        
    }


    //Test class for GoogleMap
    public static testmethod void forcallreportGoogleMap(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        RTL_TestUtility.createEmailConfig();
        TestInit.createAccount(3);

        Map<Id,Call_Report__c> mapReport = new Map<Id,Call_Report__c>();
        List<Call_Report__c> listForDML = new List<Call_Report__c>();
        System.debug(TestInit.accountList.values());

        for(Account a : TestInit.accountList.values() ){
             Call_Report__c createReport = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                                             Customer_name__c = a.id,
                                                             Status__c = 'Open',
                                                             Date_of_Visit__c = Date.today(),
                                                            Categories__c  = 'Sell product',
                                                            Main_purpose__c = 'Sell product',
                                                            Sub_Purpose__c  = 'Product'
                                                            );  
            listForDML.add(createReport);
        }
        
        insert listForDML;
        mapReport.putAll(listForDML);
        
        List<Call_Report__c> listReport = [select Id from Call_Report__c where Id IN :mapReport.keySet()];
        for( Call_Report__c report : listReport ){
            report.Check_in_Location__Latitude__s = 14.462621926686355;
            report.Check_in_Location__Longitude__s = 100.20213282666623;
            report.Status__c = 'Completed';
            report.Outcome__c = 'Win oppty';
        }
        update listReport;

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockGoogleResponse('OK'));
        
        for( Call_Report__c report : listReport ){
            report.Is_Last_Checkin_Location__c = false;
        }

        update listReport;

        Datetime currenttime = System.now();
        Datetime nextRuntime = currenttime.addMinutes(10);

        String day = string.valueOf(nextRuntime.day());
        String month = string.valueOf(nextRuntime.month());
        String hour = string.valueOf(nextRuntime.hour());
        String minute = string.valueOf(nextRuntime.minute());
        String second = string.valueOf(nextRuntime.second());
        String year = string.valueOf(nextRuntime.year());

        String strJobName = 'Job-GoogleMapAPISchedulable_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        String jobId = System.schedule(strJobName, strSchedule, new GoogleMapAPISchedulable());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(strSchedule, ct.CronExpression);

        Test.stopTest();
    }

    public static testmethod void forcallreportGoogleMapZeroResult(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        RTL_TestUtility.createEmailConfig();
        TestInit.createAccount(3);

        Map<Id,Call_Report__c> mapReport = new Map<Id,Call_Report__c>();
        List<Call_Report__c> listForDML = new List<Call_Report__c>();
        System.debug(TestInit.accountList.values());

        for(Account a : TestInit.accountList.values() ){
             Call_Report__c createReport = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                                             Customer_name__c = a.id,
                                                             Status__c = 'Open',
                                                             Date_of_Visit__c = Date.today(),
                                                            Categories__c  = 'Sell product',
                                                            Main_purpose__c = 'Sell product',
                                                            Sub_Purpose__c  = 'Product'
                                                            );  
            listForDML.add(createReport);
        }
        
        insert listForDML;
        mapReport.putAll(listForDML);
        
        List<Call_Report__c> listReport = [select Id from Call_Report__c where Id IN :mapReport.keySet()];
        for( Call_Report__c report : listReport ){
            report.Check_in_Location__Latitude__s = 14.462621926686355;
            report.Check_in_Location__Longitude__s = 100.20213282666623;
            report.Status__c = 'Completed';
            report.Outcome__c = 'Win oppty';
        }
        update listReport;

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockGoogleResponse('ZERO_RESULTS'));
        
        for( Call_Report__c report : listReport ){
            report.Is_Last_Checkin_Location__c = false;
        }

        update listReport;

        Datetime currenttime = System.now();
        Datetime nextRuntime = currenttime.addMinutes(10);

        String day = string.valueOf(nextRuntime.day());
        String month = string.valueOf(nextRuntime.month());
        String hour = string.valueOf(nextRuntime.hour());
        String minute = string.valueOf(nextRuntime.minute());
        String second = string.valueOf(nextRuntime.second());
        String year = string.valueOf(nextRuntime.year());

        String strJobName = 'Job-GoogleMapAPISchedulable_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        String jobId = System.schedule(strJobName, strSchedule, new GoogleMapAPISchedulable());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(strSchedule, ct.CronExpression);

        Test.stopTest();
    }

    public static testmethod void forcallreportGoogleMapError(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        RTL_TestUtility.createEmailConfig();
        TestInit.createAccount(3);

        Map<Id,Call_Report__c> mapReport = new Map<Id,Call_Report__c>();
        List<Call_Report__c> listForDML = new List<Call_Report__c>();
        System.debug(TestInit.accountList.values());

        for(Account a : TestInit.accountList.values() ){
             Call_Report__c createReport = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                                             Customer_name__c = a.id,
                                                             Status__c = 'Open',
                                                             Date_of_Visit__c = Date.today(),
                                                            Categories__c  = 'Sell product',
                                                            Main_purpose__c = 'Sell product',
                                                            Sub_Purpose__c  = 'Product'
                                                            );  
            listForDML.add(createReport);
        }
        
        insert listForDML;
        mapReport.putAll(listForDML);
        
        List<Call_Report__c> listReport = [select Id from Call_Report__c where Id IN :mapReport.keySet()];
        for( Call_Report__c report : listReport ){
            report.Check_in_Location__Latitude__s = 14.462621926686355;
            report.Check_in_Location__Longitude__s = 100.20213282666623;
            report.Status__c = 'Completed';
            report.Outcome__c = 'Win oppty';
        }
        update listReport;

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockGoogleResponse('ERROR'));
        
        for( Call_Report__c report : listReport ){
            report.Is_Last_Checkin_Location__c = false;
        }

        update listReport;

        Datetime currenttime = System.now();
        Datetime nextRuntime = currenttime.addMinutes(10);

        String day = string.valueOf(nextRuntime.day());
        String month = string.valueOf(nextRuntime.month());
        String hour = string.valueOf(nextRuntime.hour());
        String minute = string.valueOf(nextRuntime.minute());
        String second = string.valueOf(nextRuntime.second());
        String year = string.valueOf(nextRuntime.year());

        String strJobName = 'Job-GoogleMapAPISchedulable_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        String jobId = System.schedule(strJobName, strSchedule, new GoogleMapAPISchedulable());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(strSchedule, ct.CronExpression);

        Test.stopTest();
    }

    public static testmethod void forcallreportGoogleMapReturnNull(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        RTL_TestUtility.createEmailConfig();
        TestInit.createAccount(3);

        Map<Id,Call_Report__c> mapReport = new Map<Id,Call_Report__c>();
        List<Call_Report__c> listForDML = new List<Call_Report__c>();
        System.debug(TestInit.accountList.values());

        for(Account a : TestInit.accountList.values() ){
             Call_Report__c createReport = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                                             Customer_name__c = a.id,
                                                             Status__c = 'Open',
                                                             Date_of_Visit__c = Date.today(),
                                                            Categories__c  = 'Sell product',
                                                            Main_purpose__c = 'Sell product',
                                                            Sub_Purpose__c  = 'Product'
                                                            );  
            listForDML.add(createReport);
        }
        
        insert listForDML;
        mapReport.putAll(listForDML);
        
        List<Call_Report__c> listReport = [select Id from Call_Report__c where Id IN :mapReport.keySet()];
        for( Call_Report__c report : listReport ){
            report.Check_in_Location__Latitude__s = 14.462621926686355;
            report.Check_in_Location__Longitude__s = 100.20213282666623;
            report.Status__c = 'Completed';
            report.Outcome__c = 'Win oppty';
        }
        update listReport;

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockGoogleResponse('RETURN_NULL'));
        
        for( Call_Report__c report : listReport ){
            report.Is_Last_Checkin_Location__c = false;
        }

        update listReport;

        Datetime currenttime = System.now();
        Datetime nextRuntime = currenttime.addMinutes(10);

        String day = string.valueOf(nextRuntime.day());
        String month = string.valueOf(nextRuntime.month());
        String hour = string.valueOf(nextRuntime.hour());
        String minute = string.valueOf(nextRuntime.minute());
        String second = string.valueOf(nextRuntime.second());
        String year = string.valueOf(nextRuntime.year());

        String strJobName = 'Job-GoogleMapAPISchedulable_' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        String jobId = System.schedule(strJobName, strSchedule, new GoogleMapAPISchedulable());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(strSchedule, ct.CronExpression);

        Test.stopTest();
    }

    //Test class for Report Utility
    @IsTest(SeeAllData=true) private static  void forexortReportUtility(){
        String content  = Datetime.now().addDays(-1).format('YYYY_MM_dd');
        String filename = 'CXM_Task_Notification'+content;
        List<String> emailOpsList = new List<String>();
        emailOpsList.add('Operation CXM Team');
        ReportExportToEmailUtil.exportFuture('CXM_Task_Notification','Data as of '+content,ReportExportToEmailUtil.EXCEL_TYPE,filename,emailOpsList);
    }


    //For Commercial Campaign and Lead Expired
    public static List<Campaign> createCampaign(Integer size,String segment,Boolean doInsert ){
        List<Campaign> CampaignToCreate = new List<Campaign>();
        RecordType commercial = [select id from RecordType where DeveloperName = 'Commercial'];
        Id comId    = commercial.id;
        User testUser = TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@tmbbank.com', true).get(0);

        for(Integer i=0;i<size;i++){
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_'+i;
            camp.Segment__c = segment;
            camp.Status  = 'In Progress';
            camp.EndDate = Date.today().addDays(-1);
            camp.RecordTypeId = comId;
            camp.OwnerId  = testUser.id;
            CampaignToCreate.add(camp);
        }

        if(doInsert){
            insert CampaignToCreate;
        }
        return CampaignToCreate;
    }

    public static List<Lead> createCommLead(Integer size,Boolean doInsert,Id primaryCampId){
        RecordType commercialLead = [select id from RecordType where DeveloperName = 'Commercial_Lead'];
        Id comLeadID    = commercialLead.id;

        List<Lead> leadList = new List<Lead>();

         for(Integer i=0;i<size;i++){
            Lead led = new Lead();
            led.RecordTypeId = comLeadID;
            led.Status       = 'Open';
            led.LastName     = 'LeadName';
            led.Company      = 'Company'; 
            led.Primary_Campaign__c = primaryCampId;
            leadList.add(led);
        }

        if(doInsert){
            insert leadList;
        }
        return leadList;
    }   



    //For Opportunity is Lock
    public static List<Opportunity> createOpportunities(Account acct,Integer size, Boolean doInsert) {
        List<Opportunity> opptList = new List<Opportunity>();
        Opportunity o;
        RecordType recordType = [select Id from RecordType where developername='Retail_Deposit' 
                                        and SobjectType = 'Opportunity' and IsActive = true limit 1];
        for( Integer i = 0 ; i < size ; i++ ){
            o = new Opportunity(Name='II-OPP-'+i,
                                StageName = 'Analysis',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
                                Description = 'desc'+i,
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Expected_submit_date__c = Date.today(),
                                RecordTypeId=recordType.Id
                               );
            opptList.add(o);
            
        }
        if(doInsert){
                insert opptList;
        }
        return opptList;
    }     

    //For RemoteVFClass Smart Queue
    public static testmethod void testSmartQueueForNoMatch(){
        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo = RemoteVFClass.encyptText('0111111111');
        RemoteVFClass.getAccountById(encpData);
        RemoteVFClass.searchDocuments(encpData);
        RemoteVFClass.searchSOSLDocuments(encpData);

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo
                                                ,''
                                                ,''
                                                ,'');

    }

    public static testmethod void testSmartQueueForAccountSingleMatch(){
        TestUtils.createAppConfig();
        //ForSingleMatch
        Test.startTest();
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';                
        insert acct;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acct.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo = RemoteVFClass.encyptText('0111111111');
        RemoteVFClass.getAccountById(encpData);
        RemoteVFClass.searchDocuments(encpData);
        RemoteVFClass.searchSOSLDocuments(encpData);

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo
                                                ,''
                                                ,''
                                                ,'');

        String encpData2 = RemoteVFClass.encyptText('001100000440000000000000010102');
        String encPhoneNo2 = RemoteVFClass.encyptText('0111211111');

        RemoteVFClass.getKeyValueForNewVersion(encpData2
                                                ,encPhoneNo2
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData2
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo2
                                                ,''
                                                ,''
                                                ,'');

        
        Test.stopTest();
    }

    public static testmethod void testSmartQueueForProspectSingleMatch(){

        TestUtils.createAppConfig();
        //For Prospsect
        Test.startTest();
        Account prosp = new Account();
        prosp.First_Name_PE__c = 'abc';
        prosp.Last_Name_PE__c = 'abc';
        prosp.Name = prosp.First_Name_PE__c + ' ' + prosp.Last_Name_PE__c;
        prosp.Email_Address_PE__c = 'test@sfdc.com';
        prosp.Mobile_Number_PE__c = '0111111111';
        prosp.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Prospect').getRecordTypeId();
        prosp.Account_Type__c = 'Retail Customer';
        prosp.ID_Type_PE__c = 'Citizen ID';
        prosp.ID_Number_PE__c = '4496799264466';
        prosp.Segment_crm__c   = '5';
        prosp.RTL_NID__c = '44466';
        prosp.TMB_Employee_ID__c ='MM010';
        prosp.TMB_Customer_ID_PE__c = '';                
        insert prosp;

        Id [] fixedSearchResults2 = new Id[1];
        fixedSearchResults2[0] = prosp.Id;
        Test.setFixedSearchResults(fixedSearchResults2);

        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo2 = RemoteVFClass.encyptText('0111111111');
        RemoteVFClass.getAccountById(encpData);
        RemoteVFClass.searchDocuments(encpData);
        RemoteVFClass.searchSOSLDocuments(encpData);

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo2
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo2
                                                ,''
                                                ,''
                                                ,'');

        Test.stopTest();
        //For Prospsect
    }

    public static testmethod void testSmartQueueForLeadSingleMatch(){

        TestUtils.createAppConfig();
        //For Lead
        Test.startTest();
        Lead l = new Lead();

        l.LastName = 'LastName';
        l.Company  = 'Company';
        l.MobilePhone = '02222222';
        insert l;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = l.Id;
        Test.setFixedSearchResults(fixedSearchResults3);

        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo3 = RemoteVFClass.encyptText('02222222');

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo3
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo3
                                                ,''
                                                ,''
                                                ,'');

        String notFoundPhoneNo = RemoteVFClass.encyptText('022222333322');

        RemoteVFClass.getKeyValueForNewVersion(notFoundPhoneNo
                                                ,''
                                                ,''
                                                ,'');
        //For Lead
        Test.stopTest();
    }

    public static testmethod void testSmartQueueForLeadMultipleMatch(){
        TestUtils.createAppConfig();
        //For Lead
        Test.startTest();
        List<Lead> leadList = new List<Lead>();
        Lead l = new Lead();

        l.LastName = 'LastName';
        l.Company  = 'Company';
        l.MobilePhone = '02222222';

        Lead l1 = new Lead();
        l1.LastName = 'LastName1';
        l1.Company  = 'Company1';
        l1.MobilePhone = '02222222';

        leadList.add(l);
        leadList.add(l1);
        insert leadList;

        Id [] fixedSearchResults3= new Id[2];
        fixedSearchResults3[0] = l.Id;
        fixedSearchResults3[1] = l1.Id;
        Test.setFixedSearchResults(fixedSearchResults3);

        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo3 = RemoteVFClass.encyptText('02222222');

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo3
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo3
                                                ,''
                                                ,''
                                                ,'');
        //For Lead
        Test.stopTest();

    }

    public static testmethod void testSmartQueueForAccountMultipleMatch(){
        TestUtils.createAppConfig();
        //For Account Multiple
        Test.startTest();
        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';  

        Account prosp = new Account();
        prosp.First_Name_PE__c = 'abc';
        prosp.Last_Name_PE__c = 'abc';
        prosp.Name = prosp.First_Name_PE__c + ' ' + prosp.Last_Name_PE__c;
        prosp.Email_Address_PE__c = 'test@sfdc.com';
        prosp.Mobile_Number_PE__c = '0111111111';
        prosp.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Prospect').getRecordTypeId();
        prosp.Account_Type__c = 'Retail Customer';
        prosp.ID_Type_PE__c = 'Citizen ID';
        prosp.ID_Number_PE__c = '4496799264466';
        prosp.Segment_crm__c   = '5';
        prosp.RTL_NID__c = '44466';
        prosp.TMB_Employee_ID__c ='MM010';
        prosp.TMB_Customer_ID_PE__c = '';

        accList.add(acct);
        accList.add(prosp);
        insert accList;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = acct.Id;
        fixedSearchResults[1] = prosp.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        String encpData = RemoteVFClass.encyptText('001100000000000000000000010102');
        String encPhoneNo2 = RemoteVFClass.encyptText('0111111111');

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,encPhoneNo2
                                                ,'1111'
                                                ,'1111'); 

        RemoteVFClass.getKeyValueForNewVersion(encpData
                                                ,''
                                                ,''
                                                ,'');

        RemoteVFClass.getKeyValueForNewVersion(encPhoneNo2
                                                ,''
                                                ,''
                                                ,'');

        

        Test.stopTest();
    }
    //For RemoteVFClass Smart Queue
    

    //Test class for UserExcelImport
    public static testMethod void testNoAttachmentUserExcelImport(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        UserExcelImport excelImport = new UserExcelImport();
        Messaging.InboundEmailResult result = excelImport.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_ATTACHMENT_NUMBERS');    
    }

    public static testMethod void testInvalidAttachmentUserExcelImport(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        binaryAttachment.Body = Blob.valueOf('test');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UserExcelImport excelImport = new UserExcelImport();
        Messaging.InboundEmailResult result = excelImport.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_CSV_EXTENTSION');    
    }

    public static testMethod void caseInvalidColumnExcelImport(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();

        List<User> userToCreate = new List<User>();

        Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User newUser = new User(FirstName = 'TEST' , LastName = 'TEST', 
                                    UserName='testfortest@tmbbank.com',
                                    Email='testfortest@tmbbank.com', 
                                    Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='TEST',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='1110');
        userToCreate.add(newUser);
        
        insert userToCreate;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'USER_IMPORT.CSV';
        binaryAttachment.Body = Blob.valueOf('Employee_IDTEST__c,MobilePhoneTEST\n1110,0111111111');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UserExcelImport userExcelIMport = new UserExcelImport();
        Messaging.InboundEmailResult result = userExcelIMport.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_UTF8_ENCODING_OR_IMPORT_FILE_INVALID_FORMAT');   
        Test.stopTest();
    }

    public static testMethod void caseSuccessUserExcelImport(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();

        List<User> userToCreate = new List<User>();

        Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User newUser = new User(FirstName = 'TEST' , LastName = 'TEST', 
                                    UserName='testfortest@tmbbank.com',
                                    Email='testfortest@tmbbank.com', 
                                    Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='TEST',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='1110');
        userToCreate.add(newUser);
        
        insert userToCreate;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'USER_IMPORT.CSV';
        binaryAttachment.Body = Blob.valueOf('Employee_ID__c,MobilePhone\n1110,0111111111');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UserExcelImport userExcelIMport = new UserExcelImport();
        Messaging.InboundEmailResult result = userExcelIMport.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }


    //Test class for UserExcelImport

    //Test class for CommercialAccChangeOwnerEmail
    public static testMethod void caseNoAttachement(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        CommercialAccChangeOwnerEmail emailChangeRO = new CommercialAccChangeOwnerEmail();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_ATTACHMENT_NUMBERS');    

    }

    public static testMethod void caseInvalidCSVAttachment(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        binaryAttachment.Body = Blob.valueOf('test');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        CommercialAccChangeOwnerEmail emailChangeRO = new CommercialAccChangeOwnerEmail();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_CSV_EXTENTSION');    

    }

    public static testMethod void caseSuccessUpdateChangeRO(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006431274');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006431474');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'RO_CHANGE.CSV';
        binaryAttachment.Body = Blob.valueOf('OwnerId,TMB_Customer_ID_PE__c\n28134,001100000000000000000006431274\n28134,001100000000000000000006431474');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        CommercialAccChangeOwnerEmail emailChangeRO = new CommercialAccChangeOwnerEmail();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }
    //Test class for CommercialAccChangeOwnerEmail

    //Test class for CommercialNBOImport
    public static testMethod void caseComNBOImportNoAttachement(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        CommercialNBOImport emailChangeRO = new CommercialNBOImport();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_ATTACHMENT_NUMBERS');    

    }

    public static testMethod void caseComNBOImportInvalidCSVAttachment(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        binaryAttachment.Body = Blob.valueOf('test');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        CommercialNBOImport emailChangeRO = new CommercialNBOImport();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_CSV_EXTENTSION');    

    }

    public static testMethod void caseComNBOImportThrownException(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000579053');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006852353');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'RO_CHANGE.CSV';
        binaryAttachment.Body = Blob.valueOf('AccountAccount__c,Product_name__c,Product_Name_Medium_Priority__c,Product_Name_Low_Priority__c,Start_Date__C,Validity_Period_Ending__c\n001100000011000000000000579053,Normal - Step rate (2Tier),Normal - Step rate (2Tier),SME TMBBitz,2018-07-17,2018-07-17\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08');

        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        CommercialNBOImport emailChangeRO = new CommercialNBOImport();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }

    public static testMethod void caseComNBOImportSuccessUpdateChangeRO(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000579053');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006852353');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'RO_CHANGE.CSV';
        binaryAttachment.Body = Blob.valueOf('AccountAccount__c,Product_name__c,Product_Name_Medium_Priority__c,Product_Name_Low_Priority__c,Start_Date__C,Validity_Period_Ending__c\n001100000000000000000000579053,Normal - Step rate (2Tier),Normal - Step rate (2Tier),SME TMBBitz,2018-07-17,2018-07-17\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08\n001100000000000000000006852353,Commercial Product (Merge),SME TMBBitz,สินเชื่อ NGV (นิติบุคคล),2018-07-17,2018-08-08');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        CommercialNBOImport emailChangeRO = new CommercialNBOImport();
        Messaging.InboundEmailResult result = emailChangeRO.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }
    //Test class for CommercialNBOImport


    //Test class for FX Order
    public static testMethod void testcaseforFXOrderReport(){

        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        //mockup data 
        List<FX_Order_Report_Schedule__c> fxOrderReportList = new List<FX_Order_Report_Schedule__c>();

        FX_Order_Report_Schedule__c fxReport = new FX_Order_Report_Schedule__c();
        fxReport.Email_List__c = 'test@aaa.com;test2@aa.com';
        fxReport.User_Role_List__c = 'Role';
        fxReport.Report_API_Name__c = 'reportName';
        fxReport.Name = 'For test';

        fxOrderReportList.add(fxReport);

        insert fxOrderReportList;

        String jobId = System.schedule('FXOrderReportSchedulerForTest',
                        RTL_TestUtility.CRON_EXP, 
                        new FXOrderReportScheduler());
                        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id
                            , CronExpression, TimesTriggered
                            , NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(RTL_TestUtility.CRON_EXP,ct.CronExpression);

        Test.stopTest();
    }

    public static testMethod void testcaseforBCPFXOrderReport(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        String jobId = System.schedule('BCPFXOrderReportSchedulerForTest',
                        RTL_TestUtility.CRON_EXP, 
                        new BCPFXOrderReportScheduler());
                        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(RTL_TestUtility.CRON_EXP, ct.CronExpression);

        Test.stopTest();

    }
    
    //Test class for FX Order
    //Test class for AsyncReportController
    @IsTest(SeeAllData=true) private static  void testcaseforAsyncReport(){
        List<Report> reportList =  [Select Id, Name, DeveloperName
                                     From Report
                                     Where DeveloperName = 'Branch_Top_Bottom_for_BBG_LONG'];

        AsyncReportController.runAsyncReport(reportList.get(0).Id,reportList.get(0).DeveloperName,false);

        Test.startTest();
        Reports.ReportMetadata reportMetadata =
                                 Reports.ReportManager.describeReport(reportList.get(0).Id).getReportMetadata();

        Reports.ReportInstance instanceObj =
                Reports.ReportManager.runAsyncReport(reportList.get(0).Id,reportMetadata,false);

        String instanceId = instanceObj.getId();

        List<Report> reportList1 =  [Select Id, Name, DeveloperName
                                     From Report
                                     Where DeveloperName = 'Cmp_Util_by_Region_Campaign_Long'];

        Reports.ReportMetadata reportMetadata1 =
                                 Reports.ReportManager.describeReport(reportList1.get(0).Id).getReportMetadata();

        Reports.ReportInstance instanceObj1 =
                Reports.ReportManager.runAsyncReport(reportList1.get(0).Id,reportMetadata1,false);

        String instanceId1 = instanceObj1.getId();
        
        Test.stopTest();

        AsyncReportController.getResultsByInstaceId(instanceId
                                                    ,reportList.get(0).DeveloperName
                                                    ,false);

        AsyncReportController.runCompletedAsyncReport(reportList.get(0).Id);

        

        

        AsyncReportController.getResultsByInstaceId(instanceId1
                                                    ,reportList1.get(0).DeveloperName
                                                    ,false);

        AsyncReportController.runCompletedAsyncReport(reportList1.get(0).Id);

        


         String jobId = System.schedule('AsyncReportScheduler',
                        RTL_TestUtility.CRON_EXP, 
                        new AsyncReportScheduler(10));

        
    }


    //Test class for SFExtIntregration
    public static testMethod void testcaseforSFExtIntNoMatch(){
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        System.assertEquals(jsonData, jsonDecypt);

        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(mobileEncData);
        System.assertEquals(mobileData, mobileDecypt);

        String encData = SFExtIntregration.customEncryptText('0111111111');
        String decData = SFExtIntregration.customDecryptText(encData);

        SFExtIntregration.call_interface(encData,'','');

        System.assertEquals('0111111111', decData);
    }
   
    public static testMethod void testcaseforSFExtIntForAccount(){
        Test.startTest();
        TestUtils.createAppConfig();

        List<Account> accList = new List<Account>();
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';  

        Account prosp = new Account();
        prosp.First_Name_PE__c = 'abc';
        prosp.Last_Name_PE__c = 'abc';
        prosp.Name = prosp.First_Name_PE__c + ' ' + prosp.Last_Name_PE__c;
        prosp.Email_Address_PE__c = 'test@sfdc.com';
        prosp.Mobile_Number_PE__c = '0111111111';
        prosp.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Prospect').getRecordTypeId();
        prosp.Account_Type__c = 'Retail Customer';
        prosp.ID_Type_PE__c = 'Citizen ID';
        prosp.ID_Number_PE__c = '4496799264466';
        prosp.Segment_crm__c   = '5';
        prosp.RTL_NID__c = '44466';
        prosp.TMB_Employee_ID__c ='MM010';
        prosp.TMB_Customer_ID_PE__c = '';

        accList.add(acct);
        accList.add(prosp);
        insert accList;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = acct.Id;
        fixedSearchResults[1] = prosp.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface('','',encId);
        SFExtIntregration.call_interface('','',mobileEncData);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleLead(){
        TestUtils.createAppConfig();
        //For Lead
        Test.startTest();
        Lead l = new Lead();

        l.LastName = 'LastName';
        l.Company  = 'Company';
        l.MobilePhone = '02222222';
        insert l;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = l.Id;
        Test.setFixedSearchResults(fixedSearchResults3);

        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '02222222';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForMultipleLead(){
        TestUtils.createAppConfig();
        //For Lead
        Test.startTest();
        List<Lead> leadList = new List<Lead>();
        Lead l = new Lead();

        l.LastName = 'LastName';
        l.Company  = 'Company';
        l.MobilePhone = '02222222';

        Lead l1 = new Lead();
        l1.LastName = 'LastName1';
        l1.Company  = 'Company1';
        l1.MobilePhone = '02222222';

        leadList.add(l);
        leadList.add(l1);
        insert leadList;

        Id [] fixedSearchResults3= new Id[2];
        fixedSearchResults3[0] = l.Id;
        fixedSearchResults3[1] = l1.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
       String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '02222222';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleContact(){
        TestUtils.createAppConfig();
        Test.startTest();
        //For Contact
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';  
        insert acct;

        
        List<Contact> contactsToCreate = new List<Contact>();

        Contact cont = new Contact();
        cont.AccountId = acct.Id;
        cont.Salutation = 'Mr.';
        cont.LastName = 'contact'; 
        cont.Phone = '02222222';
        cont.Date_of_Birth__c = Date.today();
        
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        contactsToCreate.add(cont);
        insert contactsToCreate;

        Id [] fixedSearchResults3= new Id[2];
        fixedSearchResults3[0] = acct.Id;
        fixedSearchResults3[1] = cont.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForMultipleContacts(){
        TestUtils.createAppConfig();
        Test.startTest();
        //For Contact
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';  

        Account acct2 = new Account();
        acct2.First_Name_PE__c = 'abc';
        acct2.Last_Name_PE__c = 'abc';
        acct2.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct2.Email_Address_PE__c = 'test@sfdc.com';
        acct2.Mobile_Number_PE__c = '0111111111';
        acct2.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct2.Account_Type__c = 'Retail Customer';
        acct2.ID_Type_PE__c = 'Citizen ID';
        acct2.ID_Number_PE__c = '4496799264466';
        acct2.Segment_crm__c   = '5';
        acct2.RTL_NID__c = '44466';
        acct2.TMB_Employee_ID__c ='MM010';
        acct2.TMB_Customer_ID_PE__c = '001100000000000000000000010103';  

        List<Account> accList = new List<Account>();
        accList.add(acct);
        accList.add(acct2);

        insert accList;

        
        List<Contact> contactsToCreate = new List<Contact>();

        Contact cont = new Contact();
        cont.AccountId = acct.Id;
        cont.Salutation = 'Mr.';
        cont.LastName = 'contact'; 
        cont.Phone = '02222222';
        cont.Date_of_Birth__c = Date.today();
        
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';

        Contact cont2 = new Contact();
        cont2.AccountId = acct.Id;
        cont2.Salutation = 'Mr.';
        cont2.LastName = 'contact2'; 
        cont2.Phone = '02222222';
        cont2.Date_of_Birth__c = Date.today();
        
        cont2.Position__c = 'position1';
        cont2.Value_Style__c = 'Risk Awareness';
        cont2.Decision_Map__c = 'User';
        cont2.Product_Decision__c = '';
        cont2.Description__c = 'contact description';

        contactsToCreate.add(cont);
        contactsToCreate.add(cont2);
        insert contactsToCreate;

        Id [] fixedSearchResults3= new Id[3];
        fixedSearchResults3[0] = acct.Id;
        fixedSearchResults3[1] = cont.Id;
        fixedSearchResults3[2] = cont2.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
       
        String mobileData = '02222222';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);


        String mobileData2 = '0111111111';
        String mobileEncData2 = SFExtIntregration.encyptText(mobileData2);
        

        SFExtIntregration.call_interface('','',mobileEncData2);


        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleContactWithProspect(){
        TestUtils.createAppConfig();
        Test.startTest();
        //For Contact
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '0111111111';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '';  
        insert acct;

        
        List<Contact> contactsToCreate = new List<Contact>();

        Contact cont = new Contact();
        cont.AccountId = acct.Id;
        cont.Salutation = 'Mr.';
        cont.LastName = 'contact'; 
        cont.Phone = '02222222';
        cont.Date_of_Birth__c = Date.today();
        
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        contactsToCreate.add(cont);
        insert contactsToCreate;

        Id [] fixedSearchResults3= new Id[2];
        fixedSearchResults3[0] = acct.Id;
        fixedSearchResults3[1] = cont.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '02222222';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleAccount(){
        TestUtils.createAppConfig();
        Test.startTest();
        //For Contact
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '02222222';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000010102';  
        insert acct;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = acct.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleProspect(){
        TestUtils.createAppConfig();
        Test.startTest();
        //For Contact
        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '02222222';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '';  
        insert acct;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = acct.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);
        Test.stopTest();
    }

    public static testMethod void testcaseforSFExtIntForSingleContactNoAccount(){
        TestUtils.createAppConfig();
        //For Contact
        Test.startTest();
        List<Contact> contactsToCreate = new List<Contact>();

        Contact cont = new Contact();
        cont.Salutation = 'Mr.';
        cont.LastName = 'contact'; 
        cont.Phone = '02222222';
        cont.Date_of_Birth__c = Date.today();
        
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        contactsToCreate.add(cont);
        insert contactsToCreate;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = cont.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.call_interface(mobileEncData,jsonEncData,encId);

        Test.stopTest();
    }

    //test class for ccpin
   
    public static testMethod void testcaseforccpincall_interface(){
        TestUtils.createAppConfig();
        //For Contact
        Test.startTest();
        List<Contact> contactsToCreate = new List<Contact>();

        Contact cont = new Contact();
        cont.Salutation = 'Mr.';
        cont.LastName = 'contact'; 
        cont.Phone = '02222222';
        cont.Date_of_Birth__c = Date.today();
        
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        contactsToCreate.add(cont);
        insert contactsToCreate;

        Id [] fixedSearchResults3= new Id[1];
        fixedSearchResults3[0] = cont.Id;
        Test.setFixedSearchResults(fixedSearchResults3);
        String jsonData = '{"attributes":{"type":"Task"},"Call_Agent_Id__c":"66666","Call_Log_ID__c":"AAAAA","Call_Number__c":"091111111","Call_Start_Datetime__c":"2018-09-27T04:07:58.876+0000"}';
        String jsonEncData = SFExtIntregration.encyptText(jsonData);
        String jsonDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String mobileData = '0123123123123';
        String mobileEncData = SFExtIntregration.encyptText(mobileData);
        String mobileDecypt  = SFExtIntregration.decryptText(jsonEncData);
        
        String encId = SFExtIntregration.encyptText('001100000000000000000000010102');
        String decId = SFExtIntregration.decryptText(encId);
        
        SFExtIntregration.service_contactcenter(mobileEncData,jsonEncData,encId,'','');

        Test.stopTest();
    }

    
    private static void createCCHandlerList() {
        List<ContactCenter_Handler__c> apps = new  List<ContactCenter_Handler__c>();
        ContactCenter_Handler__c Aconfig = new ContactCenter_Handler__c();
        Aconfig.Name = 'CCPIN';
        Aconfig.Action__c = 'ccpin';
        Aconfig.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';        
        Aconfig.IsActive__c = true;  
        Aconfig.ObjectOperation__c = 'Verification_History__c';  
        Aconfig.ObjectRedirect__c = 'Account';  
        Aconfig.FieldForTab__c = 'Customer__c';  
        Aconfig.RMIDSearchField__c = 'TMB_Cust_ID__c';  
        Aconfig.PhoneSearchField__c = 'Phone_Number__c';  
        Aconfig.url__c = '{Customer__c}?verf_hist_id={Id}'; 
        Aconfig.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c'; 

        apps.add(Aconfig);

        insert apps;
    }

    public static testMethod void testcaseforccpincall_interface2(){
        TestUtils.createAppConfig();
        //For Contact
        Test.startTest();

        createCCHandlerList();

        Account acct = new Account();
        acct.First_Name_PE__c = 'abc';
        acct.Last_Name_PE__c = 'abc';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'test@sfdc.com';
        acct.Mobile_Number_PE__c = '02222222';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.Segment_crm__c   = '5';
        acct.RTL_NID__c = '44466';
        acct.TMB_Employee_ID__c ='MM010';
        acct.TMB_Customer_ID_PE__c = '001100000000000000000000116466';  
        insert acct;

        String dataJson = '{"Extension_Number__c" : "0998887777","Xfer__c":"Xfer: CardBalance,CardSelection,BackendError","Verification_Status__c":"02 ActiveCustomer","Verification_Type__c":"TMB ID","Verification_Result__c":"Success","Verification_Date_Time__c":"2019-03-22T07:00:00.000Z","Call_ID__c":"Call01","Fail_Reason__c":"ทดสอบภาษาไทย","Employee_ID__c":"23213","Phone_Number__c":"0910002222","TMB_Cust_ID__c":"001100000000000000000000116466","Customer__r.TMB_Customer_ID_PE__c":"001100000000000000000000116466"}';


        SFExtIntregration.service_contactcenter('','','','ccpin',SFExtIntregration.encyptText(dataJson ));
        Test.stopTest();

    }

    //Test class for SFExtIntregration

    //Test class for UploadWeathDataImport
    public static testMethod void caseUploadWealthDataImportTestInvalidAttNumber(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        UploadWeathDataImport uploadWealth = new UploadWeathDataImport();
        Messaging.InboundEmailResult result = uploadWealth.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_ATTACHMENT_NUMBERS');    

    }


    public static testMethod void caseUploadWealthDataImportInvalidCSVAttachment(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        binaryAttachment.Body = Blob.valueOf('test');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UploadWeathDataImport uploadWealth = new UploadWeathDataImport();
        Messaging.InboundEmailResult result = uploadWealth.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false); 
        System.assertEquals( result.message  ,'INVALID_CSV_EXTENTSION');    

    }

    public static testMethod void caseUploadWealthDataThrownException(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000579053');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006852353');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'For_Weath_Data.CSV';
        binaryAttachment.Body = Blob.valueOf('TMB_Customer_ID_PE__c,Operating_model__c,Next_generate_task_date__c\n001100000000000000000006852353,1.Monthly,2018-11-01\n001100000000000000000000579053,2.Bi_Monthly,2018-11-01');

        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UploadWeathDataImport uploadWealth = new UploadWeathDataImport();
        Messaging.InboundEmailResult result = uploadWealth.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }

    public static testMethod void caseUploadWealthDataThrownUTF8Invalid(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000579053');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006852353');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'For_Weath_Data.CSV';
        binaryAttachment.Body = Blob.valueOf('TMB_Customer_ID_PE__c,Operating_models__c,Next_generates_task_date__c\n001100000000000000000006852353,1.Monthly,2018-11-01\n001100000000000000000000579053,2.Bi_Monthly,2018-11-01');

        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UploadWeathDataImport uploadWealth = new UploadWeathDataImport();
        Messaging.InboundEmailResult result = uploadWealth.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,false);  
        Test.stopTest();
    }

    public static testMethod void caseUploadWealthDataSuccessUpdateChangeRO(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000579053');

        Account acc2 = new Account(Name='Test2' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000006852353');

        accList.add(acc);
        accList.add(acc2);

        insert accList;

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'For_Weath_Data.CSV';
        binaryAttachment.Body = Blob.valueOf('TMB_Customer_ID_PE__c,Operating_model__c,Next_generate_task_date__c\n001100000000000000000006852353,1.Monthly,2018-11-01\n001100000000000000000000579053,2.Bi_Monthly,2018-11-01');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UploadWeathDataImport uploadWealth = new UploadWeathDataImport();
        Messaging.InboundEmailResult result = uploadWealth.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();
    }

    //Test class for UploadWeathDataImport

    //Test class for UploadFulfillmentEmail
    public static testMethod void caseUploadfullfillmentEmail(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000051187');

        accList.add(acc);

        insert accList;

        List<Migration_Info__c> migrateLst = new List<Migration_Info__c>();

        Migration_Info__c migrate = new Migration_Info__c();
        migrate.Name = 'Fulfillment_Upload';
        migrate.Migrated_Field__c = 'RTL_Fulfillment_Type__c,RTL_Description__c,RTL_Account_ID__c,RTL_Amount__c,RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,RTL_Customer__r.TMB_Customer_ID_PE__c,RTL_Delivery_Date__c,RTL_Fulfillment_ID__c,RTL_Fulfillment_Status__c';
        migrate.ObjectName__c = 'RTL_Fulfillment__c';
        migrate.Migrated_Field_1__c = 'RTL_Fulfillment_Type__c,RTL_Home_No__c,RTL_Mobile_No__c,RTL_Office_No__c,RTL_PCI_Card_NO__c  ';
        migrate.IsActive__c = true;
        migrate.Type__c = 'UPLOAD_EMAIL';
        
        migrateLst.add(migrate);

        insert migrateLst;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_voucher.CSV';
        binaryAttachment.Body = Blob.valueOf('RTL_Customer__r.TMB_Customer_ID_PE__c,RTL_Account_ID__c,RTL_Fulfillment_ID__c,RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,RTL_Fulfillment_Type__c,RTL_Amount__c,RTL_Delivery_Date__c,RTL_Fulfillment_Status__c,RTL_Description__c\n001100000000000000000000051187,FFMCCUS7819,FFMCCUS7819,MCCUS0116D,Limousine,1,2019-04-04,C00,Expired Date: 2020-01-01');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';


        UploadFulfillmentEmail uploadFulfillment = new UploadFulfillmentEmail();
        Messaging.InboundEmailResult result = uploadFulfillment.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);  
        Test.stopTest();

    }
    

    //Test class for UploadFulfillmentEmail

    //Test class for UploadDNCByUser
    public static testMethod void caseUploadDNCByUser(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigList();

        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    ,recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000051187'
                                    ,ID_Number_PE__c = '722416A382133'
                                    ,ID_Type_PE__c = 'Citizen ID'
                                    );

        accList.add(acc);

        insert accList;
        List<Migration_Info__c> migrateLst = new List<Migration_Info__c>();

        Migration_Info__c migrate = new Migration_Info__c();
        migrate.Name = 'CXM_BulkUpload_Do_Not_Contact';
        migrate.Migrated_Field__c = 'MK_CODE_EXT_KEY__c,ID_Number_PE__c,Start_Date__c,End_Date__c,Product_Group__c,Channel__c,Reason__c';
        migrate.ObjectName__c = 'RTL_Do_not_Contact_Info__c';
        migrate.SOSL_QUERY__c = 'FIND {{%ID_Number_PE__c%}} IN ALL FIELDS RETURNING Account (Id,ID_Number_PE__c,ID_Type_PE__c,TMB_Customer_ID_PE__c)';
        migrate.SOSL_KEY_MAP__c = 'ID_Number_PE__c=TMB_Customer_ID_PE__c';
        migrate.SOSL_KEY_FIELD__c = 'Customer__r.TMB_Customer_ID_PE__c';

        migrate.IsActive__c = true;
        migrate.Type__c = 'UPLOAD_EMAIL';
        migrate.Validate_Field_1__c = 'ID_Type_PE__c';
        migrate.Validate_Field_Value_1__c = 'Citizen ID';
        
        migrateLst.add(migrate);

        insert migrateLst;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_dnc.CSV';
        binaryAttachment.Body = Blob.valueOf('ID_Number_PE__c,MK_CODE_EXT_KEY__c,Start_Date__c,End_Date__c,Product_Group__c,Channel__c,Reason__c\n722416A382133,13111,2018-07-19,2020-07-19,Others,SMS;Phone,DonotContact_Reason');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';


        UploadDNCByUser uploaddnc = new UploadDNCByUser();
        Messaging.InboundEmailResult result = uploaddnc.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true); 

        //for fail case
         Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope2 = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments2 = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment2 = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_dnc_for_fail.CSV';
        binaryAttachment.Body = Blob.valueOf('ID_Number_PEA__c,MK_CODE_EXT_KEY__c,Start_Date__c,End_Date__c,Product_Group__c,Channel__c,Reason__c\n722416A382133,13111,2018-07-19,2020-07-19,Others,SMS;Phone,DonotContact_Reason');
        binaryAttachments[0] =  binaryAttachment ;
        email2.binaryAttachments = binaryAttachments ;
        envelope2.fromAddress = 'aaaa@test.com';


        UploadDNCByUser uploaddnc2 = new UploadDNCByUser();
        Messaging.InboundEmailResult result2 = uploaddnc2.handleInboundEmail(email2, envelope2);

        System.assertEquals( result2.success  ,false); 

        Test.stopTest();
    }
    //Test class for UploadDNCByUser

    public static void createMigrateInfo() {
        List<Migration_Info__c> migrateLst = new List<Migration_Info__c>();

        Migration_Info__c migrate1 = new Migration_Info__c();
        migrate1.Name = 'Upload_Case';
        migrate1.Migrated_Field__c = 'Id,CaseNumber,Status';
        migrate1.ObjectName__c = 'Case';
        migrate1.Migrated_Field_1__c = '';
        migrate1.Validate_Field_1__c = '';
        migrate1.Validate_Field_Value_1__c = '';
        migrate1.IsActive__c = true;
        migrate1.Type__c = 'UPLOAD_EMAIL';

        Migration_Info__c migrate2 = new Migration_Info__c();
        migrate2.Name = 'UPLOAD_BA_INFO_BY_USER';
        migrate2.Migrated_Field__c = 'TMB_Customer_ID_PE__c,RTL_BA_Privilege__c';
        migrate2.ObjectName__c = 'Account';
        migrate2.Migrated_Field_1__c = '';
        migrate2.Validate_Field_1__c = '';
        migrate2.Validate_Field_Value_1__c = '';
        migrate2.IsActive__c = true;
        migrate2.Type__c = 'UPLOAD_EMAIL';

        migrateLst.add(migrate1);
        migrateLst.add(migrate2);

        insert migrateLst;
    }

    //Test class for UploadBAInfoByUser
    public static testMethod void caseUpdateBAInfoByUser(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        createMigrateInfo();

        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000051187');

        accList.add(acc);

        insert accList;


        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_ba.CSV';
        binaryAttachment.Body = Blob.valueOf('TMB_Customer_ID_PE__c,RTL_BA_Privilege__c\n001100000000000000000000051187,ทดสอบภาษาไทย');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UploadBAInfoByUser updateBA = new UploadBAInfoByUser();
        Messaging.InboundEmailResult result = updateBA.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);  

         Test.stopTest();
    }

    //Test class for UpdateCaseForCCEmailService
    public static testMethod void caseUpdateCaseCCService(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        createMigrateInfo();


        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];

        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                    , recordTypeId=rt.id
                                    ,TMB_Customer_ID_PE__c='001100000000000000000000051187');

        accList.add(acc);

        insert accList;

        List<Case> caseList = new List<Case>();
        
        Case caseObj = New Case(); 
        //case.recordtypeID = SErecordType.id;
        caseObj.Subject = 'TestCase';
        caseObj.PTA_Segment__c = 'SBG';
        caseObj.Category__c = 'Service Level1';
        caseObj.Sub_Category__c = 'Service level2';
        caseObj.Product_Category__c = 'Service level3';
        caseObj.Issue__c = 'Service level4';
        caseObj.Status = 'New';
        caseObj.Description = 'Test create Case';
        caseObj.AccountId = accList.get(0).id;
        caseObj.Root_Cause_List__c = 'Other';
        caseObj.Root_Cause__c = 'test';
        caseObj.Resolution_LIst__c = 'Other';
        caseObj.Resolution__c =  'test';
        caseObj.Service_Type_Matrix_Code__c = '09090';
        caseObj.Current_Service_Template__c = 'General';
        caseList.add(caseObj);

        insert caseList;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_case.CSV';
        binaryAttachment.Body = Blob.valueOf('Id,CaseNumber,Status\n'+caseList.get(0).Id+','+caseList.get(0).CaseNumber+','+'Completed');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';

        UpdateCaseForCCEmailService updateCase = new UpdateCaseForCCEmailService();
        Messaging.InboundEmailResult result = updateCase.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);  
        Test.stopTest();

    }
    //Test class for UpdateCaseForCCEmailService

    //Test class for UploadInvestmentModelEmail
    public static testMethod void caseUploadInvestmentModelEmail(){
        Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();

        List<Migration_Info__c> migrateLst = new List<Migration_Info__c>();

        Migration_Info__c migrate = new Migration_Info__c();
        migrate.Name = 'InvestmentModel_Upload';
        migrate.Migrated_Field__c = 'INVESTMENT_PROFILE__c,Suitability_Model__c,Asset_Class__c,FUND_TARGET_WGT__c';
        migrate.ObjectName__c = 'Invesment_Model__c';
        migrate.IsActive__c = true;
        migrate.Type__c = 'UPLOAD_EMAIL';

        migrateLst.add(migrate);

        insert migrateLst;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        email.subject = 'test';
        email.fromName = 'test test';

        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'upload_investment_model.csv';
        binaryAttachment.Body = Blob.valueOf('INVESTMENT_PROFILE__c,Suitability_Model__c,Asset_Class__c,FUND_TARGET_WGT__c\r\nTMB_MP_PG_RAV,1,Fixed Income,85');
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'aaaa@test.com';


        UploadInvestmentModelEmail uploadInvestmentModel = new UploadInvestmentModelEmail();
        Messaging.InboundEmailResult result = uploadInvestmentModel.handleInboundEmail(email, envelope);

        System.assertEquals( result.success  ,true);
        Test.stopTest();

    }
    //Test class for UploadInvestmentModelEmail

    @isTest static void testSendEmailByUserId() {
        Test.startTest();
        List<String> emailOpsList =  new List<String>();

        for (Integer i=0;i<100;i++) {
            emailOpsList.add('email_'+i+'@test.com');
        }

        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'UserTest1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        u.Title = 'BM';
        u.Employee_ID__c = 'emp-test-1';
        insert u;

        emailOpsList.add('test@email.com');

        RTL_BatchEmailService.SendEmailByUserIdsAndSingleEmail('test_subject'
                                                                ,'test_htmlBody'
                                                                ,emailOpsList
                                                                ,new List<Messaging.Emailfileattachment>()
                                                                ,false);
        Test.stopTest();
    }


    public static testMethod void testForDNCService(){
         Test.startTest();

        TestUtils.createAppConfig();
        createAppConfigList();
        createMigrateInfo();
        List<EIM_Map__c> eimList = new List<EIM_Map__c>();

        EIM_Map__c eim = new EIM_Map__c();
        
        eim.External_Field__c = 'customerId';
        eim.Field_Order__c = Decimal.valueOf('0');
        eim.Field_Type__c = 'Request';
        eim.IsActive__c = true;
        eim.Job_Type__c = 'DNCToMISBatch';
        eim.Node__c = 'DataNode';
        eim.SF_Field__c = 'RTL_TMB_Customer_ID_PE__c';
        eim.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim1 = new EIM_Map__c();
        
        eim1.External_Field__c = 'donotcontactId';
        eim1.Field_Order__c = Decimal.valueOf('1');
        eim1.Field_Type__c = 'Request';
        eim1.IsActive__c = true;
        eim1.Job_Type__c = 'DNCToMISBatch';
        eim1.Node__c = 'DataNode';
        eim1.SF_Field__c = 'Id';
        eim1.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim2 = new EIM_Map__c();
        
        eim2.External_Field__c = 'createByEmployeeId';
        eim2.Field_Order__c = Decimal.valueOf('2');
        eim2.Field_Type__c = 'Request';
        eim2.IsActive__c = true;
        eim2.Job_Type__c = 'DNCToMISBatch';
        eim2.Node__c = 'DataNode';
        eim2.SF_Field__c = 'RTL_CreatedBy_EmployeeID__c';
        eim2.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim3 = new EIM_Map__c();
        
        eim3.External_Field__c = 'name';
        eim3.Field_Order__c = Decimal.valueOf('3');
        eim3.Field_Type__c = 'Request';
        eim3.IsActive__c = true;
        eim3.Job_Type__c = 'DNCToMISBatch';
        eim3.Node__c = 'DataNode';
        eim3.SF_Field__c = 'Name';
        eim3.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim4 = new EIM_Map__c();
        
        eim4.External_Field__c = 'lastModifiedByEmployeeId';
        eim4.Field_Order__c = Decimal.valueOf('4');
        eim4.Field_Type__c = 'Request';
        eim4.IsActive__c = true;
        eim4.Job_Type__c = 'DNCToMISBatch';
        eim4.Node__c = 'DataNode';
        eim4.SF_Field__c = 'LastModifiedDate';
        eim4.Object__c = 'RTL_Do_not_Contact_Info__c';

    /*
        EIM_Map__c eim5 = new EIM_Map__c();
        
        eim5.External_Field__c = 'Customer_Name__c';
        eim5.Field_Order__c = Decimal.valueOf('5');
        eim5.Field_Type__c = 'Request';
        eim5.IsActive__c = true;
        eim5.Job_Type__c = 'DNCToMISBatch';
        eim5.Node__c = 'DataNode';
        eim5.SF_Field__c = 'Customer_Name__c';
        eim5.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim6 = new EIM_Map__c();

        eim6.External_Field__c = 'Contact_Person_Name__c';
        eim6.Field_Order__c = Decimal.valueOf('6');
        eim6.Field_Type__c = 'Request';
        eim6.IsActive__c = true;
        eim6.Job_Type__c = 'DNCToMISBatch';
        eim6.Node__c = 'DataNode';
        eim6.SF_Field__c = 'Contact_Person_Name__c';
        eim6.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim7 = new EIM_Map__c();

        eim7.External_Field__c = 'Sub_Category__c';
        eim7.Field_Order__c = Decimal.valueOf('7');
        eim7.Field_Type__c = 'Request';
        eim7.IsActive__c = true;
        eim7.Job_Type__c = 'DNCToMISBatch';
        eim7.Node__c = 'DataNode';
        eim7.SF_Field__c = 'Sub_Category__c';
        eim7.Object__c = 'RTL_Do_not_Contact_Info__c';

        EIM_Map__c eim8 = new EIM_Map__c();

        eim8.External_Field__c = 'Product_Category__c';
        eim8.Field_Order__c = Decimal.valueOf('7');
        eim8.Field_Type__c = 'Request';
        eim8.IsActive__c = true;
        eim8.Job_Type__c = 'DNCToMISBatch';
        eim8.Node__c = 'DataNode';
        eim8.SF_Field__c = 'Product_Category__c';
        eim8.Object__c = 'RTL_Do_not_Contact_Info__c';
*/

        eimList.add(eim);
        eimList.add(eim1);
        eimList.add(eim2);
        eimList.add(eim3);
        eimList.add(eim4);
        //eimList.add(eim5);
        //eimList.add(eim6);
        //eimList.add(eim7);
        //eimList.add(eim8);

        insert eimList;

        List<Integration_Info__c> intInfoList = new List<Integration_Info__c>(); 

        Integration_Info__c intInfo = new Integration_Info__c();
        intInfo.Name = 'DNCToMISBatch';
        intInfo.Endpoint__c = 'not_use';
        intInfo.Request_Format__c = 'application/json';
        intInfo.Response_Format__c = 'application/json ';
        intInfo.Timeout__c = Decimal.valueOf('2');

        intInfoList.add(intInfo);
        insert intInfoList;


        List<Integration_Mapping__c> intMappingLst = new List<Integration_Mapping__c>();

        Integration_Mapping__c intMapp = new Integration_Mapping__c();
        intMapp.IsActive__c = true;
        intMapp.Variable_Field_1__c = 'Id';
        intMapp.Name = 'DNCToMISBatch';
        intMapp.Batch_SQL__c = 'Select RTL_TMB_Customer_ID_PE__c,Id,RTL_CreatedBy_EmployeeID__c,Name,RTL_LastModifiedBy_EmployeeID__c,LastModifiedDate';
        intMapp.Batch_SQL__c += ',End_Date__c,Reason__c,Start_Date__c,Expired__c';
        intMapp.Batch_SQL__c += ',Channel_All__c,Channel_Direct_Contact__c,Channel_Email__c';
        intMapp.Batch_SQL__c += ',Channel_MIB__c,Channel_others__c,Channel_Phone__c,Channel_Postmail__c';
        intMapp.Batch_SQL__c += ',Channel_SMS__c,PD_All__c,PD_Bancassurance__c,PD_Credit_Cards__c';
        intMapp.Batch_SQL__c += ',PD_Deposits__c,PD_Loans__c,PD_Mutual_Fund__c,PD_Others__c,Customer__c,Customer__r.Name';
        intMapp.Batch_SQL__c += ' From RTL_Do_not_Contact_Info__c WHERE LastModifiedDate <> null  {%id_list%} ';
        intMappingLst.add(intMapp);

        Integration_Mapping__c intMapp2 = new Integration_Mapping__c();
        intMapp2.IsActive__c = true;
        intMapp2.Variable_Field_1__c = 'Id';
        intMapp2.Name = 'RetailLogForDNC';
        intMapp2.Batch_SQL__c = 'Select Id,RTL_Service_Name__c,RTL_Is_Success__c,RTL_Error_Message__c From RTL_Online_Service_Log__c Where RTL_Service_Name__c = \'DO_NOT_CONTACT_SERVICE_API\' and RTL_Is_Success__c = false';
        intMappingLst.add(intMapp2);

        insert intMappingLst;

        RecordType rt = [select id,Name from RecordType where SobjectType='Account' 
                            and Name='Existing Customer' Limit 1];
        List<Account> accList = new List<Account>();
        Account acc = new Account(Name='Test' 
                                  , recordTypeId=rt.id
                                  ,TMB_Customer_ID_PE__c='001100000000000000000000051187');

        accList.add(acc);

        insert accList;

        //DNC
        
       
        List<RTL_Do_not_Contact_Info__c>  dncLst = new List<RTL_Do_not_Contact_Info__c>();
        
        RTL_Do_not_Contact_Info__c dncObj = new RTL_Do_not_Contact_Info__c();
    
        dncObj.Channel__c = 'All';
        dncObj.Customer__c = acc.Id;
        dncObj.Start_Date__c = Date.today();
        dncObj.End_Date__c   = Date.today().addDays(1);

        dncObj.Product_Group__c = 'All';

        dncLst.add(dncObj);

        insert dncLst;

        List<RTL_Online_Service_Log__c> retryLogLst = new List<RTL_Online_Service_Log__c>();

        RTL_Online_Service_Log__c retryLog = new RTL_Online_Service_Log__c();

        retryLog.RTL_Name_of_User__c = UserInfo.getName();
        retryLog.RTL_RM_ID__c          = '';
        retryLog.Online_Batch_Log__c   = 'DO_NOT_CONTACT_SERVICE_API';
        retryLog.RTL_Start_DateTime__c = Datetime.now();  
        retryLog.RTL_Service_Name__c   = 'DO_NOT_CONTACT_SERVICE_API';
        retryLog.RTL_Is_Success__c = false;
        retryLog.RTL_End_DateTime__c = Datetime.now();
        retryLog.RTL_Error_Message__c = 'a1n0l0000003VFkAAM,a1n0l0000003fXyAAI	';
        
        retryLogLst.add(retryLog);

        insert retryLogLst;

        DoNotContactServiceBatch dncService = new DoNotContactServiceBatch();
        dncService.execute();

        intMapp2.IsActive__c = false;
        update intMapp2;

        dncService = new DoNotContactServiceBatch();
        dncService.execute();

        intMapp.Batch_SQL__c = '';
        update intMapp;

        dncService = new DoNotContactServiceBatch();
        dncService.execute();

        Test.stopTest();
    }
}