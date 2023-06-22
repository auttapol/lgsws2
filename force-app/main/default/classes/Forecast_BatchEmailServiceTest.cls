@isTest
public class Forecast_BatchEmailServiceTest {
    
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    static{
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CRM Admin 2';
        Aconfig.Value__c = 'SMSE@tmb.com.test;';
		apps.add(Aconfig);
        insert apps;
        
        TestUtils.createAppConfig();
        
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;


        List<Region_and_Zone_Mapping__c> rzlst = new List<Region_and_Zone_Mapping__c>();
        Region_and_Zone_Mapping__c Rz1 = new Region_and_Zone_Mapping__c();
        Rz1.Team_Zone_Code__c = '9999';
        Rz1.Team_Zone_Name__c = 'SE-ChiangMai';
        Rz1.Region_Group_Code__c = '1111';
        Rz1.Region_Group_Name__c = 'SE1-North1';
        rzlst.add(Rz1);
        insert rzlst;
        
        List<User> userlst = new List<User>();
        User salesManagementSE = RTL_TestUtility.createUsers(1, 'SMSE', 'SMSE', 'SMSE@tmb.com.test', false).get(0);
		salesManagementSE.ProfileId = SESM_PROFILE_ID;
		salesManagementSE.isActive = true;
		salesManagementSE.RTL_Branch_Code__c = bz.Branch_Code__c;
		salesManagementSE.Employee_ID__c = '000001';
		salesManagementSE.Zone__c = 'SE-ChiangMai';
		salesManagementSE.Zone_Code__c = '9999';
		salesManagementSE.Region__c = 'SE1-North1';
		salesManagementSE.Region_Code__c = '1111';
        salesManagementSE.Segment__c = 'SE';
        userlst.add(salesManagementSE);
        
        insert userlst;
    }
	@IsTest
    static void sentEmailFailedRec(){
        Test.startTest();
        Datetime batchDate = datetime.now();
        List<Datetime> batchStartTimeSet = new List<Datetime>();
        List<Datetime> batchEndTimeSet = new List<Datetime>();
        List<Integer> recordsSuccessfulSet = new List<Integer>();
        List<Integer> recordsFailedSet = new List<Integer>();
        List<String> yearSet = new List<String>();
        List<String> monthSet = new List<String>();
        batchStartTimeSet.add(batchDate);
        batchEndTimeSet.add(batchDate);
        recordsSuccessfulSet.add(2);
        recordsFailedSet.add(1);
        yearSet.add('2021');
        monthSet.add('06');
        String filename = 'Forecast Batch Test Class';
        String sObjectName = 'Monthly_Forecast_Input__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');
        String CSV_BODY = 'TestBody';
        String csvHeaderStr = 'Test Header\n';
        Forecast_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchStartTimeSet, batchStartTimeSet, batchEndTimeSet, recordsSuccessfulSet, recordsFailedSet ,yearSet ,monthSet , filename, sobjectName, sendToEmail, CSV_BODY, CSV_BODY, CSV_BODY, csvHeaderStr, csvHeaderStr, csvHeaderStr, '');

        Test.stopTest();
    }

	@IsTest
    static void sentEmailSuccessRec(){
        Test.startTest();
        Datetime batchDate = datetime.now();
        List<Datetime> batchStartTimeSet = new List<Datetime>();
        List<Datetime> batchEndTimeSet = new List<Datetime>();
        List<Integer> recordsSuccessfulSet = new List<Integer>();
        List<Integer> recordsFailedSet = new List<Integer>();
        List<String> yearSet = new List<String>();
        List<String> monthSet = new List<String>();
        batchStartTimeSet.add(batchDate);
        batchEndTimeSet.add(batchDate);
        recordsSuccessfulSet.add(2);
        recordsFailedSet.add(0);
        yearSet.add('2021');
        monthSet.add('06');
        String filename = 'Forecast Batch Test Class';
        String sObjectName = 'Monthly_Forecast_Input__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');
        String CSV_BODY = 'TestBody';
        String csvHeaderStr = 'Test Header\n';
        Forecast_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchStartTimeSet, batchStartTimeSet, batchEndTimeSet, recordsSuccessfulSet, recordsFailedSet ,yearSet ,monthSet , filename, sobjectName, sendToEmail, CSV_BODY, '', '', csvHeaderStr, '', '', '');

        Test.stopTest();
    }

}