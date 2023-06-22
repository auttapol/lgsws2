@isTest
public class ForecastAdjustmentControllerTest {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
       
    static{
        TestUtils.createAppConfig();
        
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;
        
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
        
        User userSystemadmin = RTL_TestUtility.createUsers(1, 'Sysad', 'Sysad', 'Sysad@tmb.com.test', false).get(0);
		userSystemadmin.ProfileId = SYSAD_PROFILE_ID;
		userSystemadmin.isActive = true;
		userSystemadmin.RTL_Branch_Code__c = bz.Branch_Code__c;
		userSystemadmin.Employee_ID__c = '000002';
		userSystemadmin.Zone__c = 'ChiangMai';
		userSystemadmin.Zone_Code__c = '8888';
		userSystemadmin.Region__c = 'North1';
		userSystemadmin.Region_Code__c = '2222';
        userlst.add(userSystemadmin);
        
        User teamhead = RTL_TestUtility.createUsers(1, 'teamhead', 'teamhead', 'teamhead@tmb.com.test', false).get(0);
		teamhead.ProfileId = SEZM_PROFILE_ID;
		teamhead.isActive = true;
		teamhead.RTL_Branch_Code__c = bz.Branch_Code__c;
		teamhead.Employee_ID__c = '111111';
		teamhead.Zone__c = 'SE-ChiangMai';
		teamhead.Zone_Code__c = '9999';
		teamhead.Region__c = 'SE1-North1';
		teamhead.Region_Code__c = '1111';
        teamhead.ManagerId = salesManagementSE.Id;
        userlst.add(teamhead);
        
        User bdmSEowner0 = RTL_TestUtility.createUsers(1, 'bdmSEowner0', 'bdmSEowner0', 'bdmSEowner0@tmb.com.test', false).get(0);
		bdmSEowner0.ProfileId = BDM_PROFILE_ID;
		bdmSEowner0.isActive = true;
		bdmSEowner0.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner0.Employee_ID__c = '333330';
		bdmSEowner0.Zone__c = 'IIG-Dev';
		bdmSEowner0.Zone_Code__c = '5001';
		bdmSEowner0.Region__c = 'IIG';
		bdmSEowner0.Region_Code__c = '5000';
        bdmSEowner0.Segment__c = 'SE';
        userlst.add(bdmSEowner0);
        
        insert userlst;

        Region_and_Zone_Mapping__c regZone = new Region_and_Zone_Mapping__c();
        regZone.Team_Zone_Code__c = '9999';
        regZone.Team_Zone_Name__c = 'SE-ChiangMai';
        regZone.Region_Group_Code__c = '1111';
        regZone.Region_Group_Name__c = 'SE1-North1';

        insert regZone;
    }
    
    public static String getMonthName (Integer monthNumber){
        monthNumber = monthNumber - 1;
        List<String> monthsMap = new List<String>();
        monthsMap.add('Jan');
        monthsMap.add('Feb');
        monthsMap.add('Mar');
        monthsMap.add('Apr');
        monthsMap.add('May');
        monthsMap.add('Jun');
        monthsMap.add('Jul');
        monthsMap.add('Aug');
        monthsMap.add('Sep');
        monthsMap.add('Oct');
        monthsMap.add('Nov');
        monthsMap.add('Dec');
        
        return monthsMap.get(monthNumber);
    }
    
    @isTest
    public static void testGetRegionZoneNameRM() {
        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        System.runAs(rm){
            //My Customer
            Map<String, Map<String, String>> mapportMyCus = new Map<String, Map<String, String>> ();
            Map<String, String> zoneMyCus = new Map<String, String>();
            zoneMyCus.put('5001', 'IIG-Dev');
            mapportMyCus.put('My Customer', zoneMyCus);
            String myCus = JSON.serialize(mapportMyCus);
            String portMyCus = ForecastAdjustmentController.getUserPortOptionPermission();
            System.assertEquals(portMyCus, myCus);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRegionZoneNameTeamHead() {
        User teamHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'teamhead@tmb.com.test' AND ProfileId = :SEZM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        System.runAs(teamHead){
            Map<String, Map<String, String>> mapportMyTeam = new Map<String, Map<String, String>> ();
            Map<String, String> zoneMyTeam = new Map<String, String>();
            zoneMyTeam.put('9999', 'SE-ChiangMai');
            mapportMyTeam.put('My Team', zoneMyTeam);
            mapportMyTeam.put('My Customer', zoneMyTeam);
            String myTeam = JSON.serialize(mapportMyTeam);
            String portMyTeam = ForecastAdjustmentController.getUserPortOptionPermission();
            System.assertEquals(portMyTeam, myTeam);
            
            /*//My Acc
            Map<String, Map<String, String>> mapportMyAcc = new Map<String, Map<String, String>> ();
            Map<String, String> zoneMyAcc = new Map<String, String>();
            zoneMyAcc.put('5679', 'CB2-1');
            zoneMyAcc.put('5629', 'CB2-2');
            mapportMyAcc.put('My Account Team', zoneMyAcc);
            String myAcc = JSON.serialize(mapportMyAcc);
            String portMyAcc = ForecastAdjustmentController.getUserPortOptionPermission();
            System.assertEquals(portMyAcc, myAcc);*/
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRegionZoneNameGroupHead() {
        User saleM = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        System.runAs(saleM){
            //My Acc
            Map<String, Map<String, String>> mapportMyAcc = new Map<String, Map<String, String>> ();
            Map<String, String> zoneMyAcc = new Map<String, String>();
            zoneMyAcc.put('9999', 'SE-ChiangMai');
            mapportMyAcc.put('Select Team', zoneMyAcc);
            String myAcc = JSON.serialize(mapportMyAcc);
            String portMyAcc = ForecastAdjustmentController.getUserPortOptionPermission();
            System.assertEquals(portMyAcc, myAcc);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDataRM() {
        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);
        List<Product2> listpro = TestUtils.createProduct(1, true);
        
        Test.startTest();
        System.runAs(rm){
            integer month = Date.today().month();
            integer year = Date.today().year();
            String accId = accList.get(0).Id;
            String productDomain = 'Rick Protection';
            String searchGroup = '';
            List<String> searchTeam = new List<String>();
        	searchTeam.add('5001');
            String stage = 'Analysis';
            String port = 'My Customer';
            String prob = 'High';
            String groupId = '';
            String prdDomain = 'Credit';
            String prdGroup = 'Credit Card';
            Boolean isMaturedInMonth = true;
            Double averageNim = 1.00;
            
            //Deal Forecast
            ForecastAdjustmentController.getDealForecast(month,year,accId,productDomain,searchGroup,searchTeam,stage,port,prob);
            
            ForecastAdjustmentController.getFeeRateLink();
            
            //Monthly Forecast
            ForecastAdjustmentController.getmonthlyForecastInput(month,year,accId,groupId ,searchTeam,prdDomain,prdGroup,port,isMaturedInMonth);
            
            // Priority Product
            ForecastAdjustmentController.getpriorityProduct();

            //Drawdown
            ForecastAdjustmentController.getDrawdown(month,year,accId,groupId,searchTeam,prdDomain,prdGroup, port,true);
            
            //Exiting Deatail
            ForecastAdjustmentController.getExistingDetail(accId, prdGroup ,String.valueOf(month) ,String.valueOf(year) ,'IIG-Dev');
            
            //Generate Drawdown
            ForecastAdjustmentController.generateDrawdown(accList.get(0).Id, prdDomain,listpro.get(0).id,String.valueOf(month) ,String.valueOf(year),'10','01',averageNim);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDataTeamHead() {
        User teamHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'teamhead@tmb.com.test' AND ProfileId = :SEZM_PROFILE_ID LIMIT 1];
        
		Test.startTest();
        System.runAs(teamHead){
            integer month = Date.today().month();
            integer year = Date.today().year();
            String accId = '';
            String productDomain = 'Rick Protection';
            String searchGroup = '';
            List<String> searchTeam = new List<String>();
        	searchTeam.add('5001');
            String stage = 'Analysis';
            String port = 'My Team';
            String prob = 'High';
            List<String> searchAccTeam = new List<String>();
        	searchAccTeam.add('5679');
            searchAccTeam.add('5629'); 
            String portAccTeam = 'My Account Team';
            String groupId = '';
            String prdDomain = 'Credit';
            String prdGroup = 'Credit Card';
            Boolean isMaturedInMonth = true;
            
            //Deal Forecast
            ForecastAdjustmentController.getDealForecast(month,year,accId,productDomain,searchGroup,searchTeam,stage,port,prob);
            ForecastAdjustmentController.getDealForecast(month,year,accId,productDomain,searchGroup,searchAccTeam,stage,portAccTeam,prob);
            
            ForecastAdjustmentController.getFeeRateLink();
            
            //Monthly Forecast
            ForecastAdjustmentController.getmonthlyForecastInput(month,year,accId,groupId ,searchTeam,prdDomain,prdGroup,port,isMaturedInMonth);
            ForecastAdjustmentController.getmonthlyForecastInput(month,year,accId,groupId ,searchAccTeam,prdDomain,prdGroup,portAccTeam,isMaturedInMonth);
            
            // Priority Product
            ForecastAdjustmentController.getpriorityProduct();

            //Drawdown
            ForecastAdjustmentController.getDrawdown(month,year,accId,groupId,searchTeam,prdDomain,prdGroup, port,true);
            ForecastAdjustmentController.getDrawdown(month,year,accId,groupId,searchAccTeam,prdDomain,prdGroup, portAccTeam,true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDataGroupHead() {
        User saleM = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        System.runAs(saleM){
            integer month = Date.today().month();
            integer year = Date.today().year();
            String accId = '';
            String productDomain = 'Rick Protection';
            String searchGroup = '';
            List<String> searchTeam = new List<String>();
        	searchTeam.add('5001');
            searchTeam.add('9999');
            String stage = 'all';
            String port = 'Select Team';
            String prob = 'High';
            String groupId = '';
            String prdDomain = 'Credit';
            String prdGroup = 'Credit Card';
            Boolean isMaturedInMonth = true;
            List<String> searchAccTeam = new List<String>();
        	searchAccTeam.add('5679');
            searchAccTeam.add('5629'); 
            String portAccTeam = 'My Team-Account Team';
            
            //Deal Forecast
            ForecastAdjustmentController.getDealForecast(month,year,accId,productDomain,searchGroup,searchTeam,stage,port,prob);
            
            ForecastAdjustmentController.getFeeRateLink();

            //Monthly Forecast
            ForecastAdjustmentController.getmonthlyForecastInput(month,year,accId,groupId ,searchTeam,prdDomain,prdGroup,port,isMaturedInMonth);
            ForecastAdjustmentController.getmonthlyForecastInput(month,year,accId,groupId ,searchAccTeam,prdDomain,prdGroup,portAccTeam,isMaturedInMonth);


            // Priority Product
            ForecastAdjustmentController.getpriorityProduct();
            
			//Drawdown            
            ForecastAdjustmentController.getDrawdown(month,year,accId,groupId,searchTeam,prdDomain,prdGroup, port,true);
            ForecastAdjustmentController.getDrawdown(month,year,accId,groupId,searchAccTeam,prdDomain,prdGroup, portAccTeam,true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testDealForecast() {
        test.startTest();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(1,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(0).RecordTypeId = '01290000001AhOYAA0';
        	
        	update listopp;
        list<product2> listpro = testutils.createProduct(1,true);
        	listpro.get(0).Remark__c = 'ST loan';
        	update listpro;
        
        list<pricebookentry> listpricebook = testutils.createPricebookEntry(1,pricebookId,listpro,true);
        
        OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = listopp.get(0).id;
        	oppline.Product2Id = listpro.get(0).id;
        	oppline.Quantity = 1;
        	oppline.Deal_Probability__c = 'Low';
        	oppline.UnitPrice = 10000000;
        insert oppline; 
        
        Deal_Forecast_Income__c DealForecastData1 = new Deal_Forecast_Income__c();
        DealForecastData1.Income_Type__c = 'NIIc';
        DealForecastData1.Probability__c = oppline.Deal_Probability__c;
        DealForecastData1.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData1.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData1.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData1.Utilization_Percent__c = 100;
        DealForecastData1.NIM_Fee_rate__c = 35;
        DealForecastData1.Volume__c = 1000000;
        DealForecastData1.Remark__c = '';
        DealForecastData1.Opportunity_Product_Id__c = oppline.id;
        DealForecastData1.Customer__c = listacc.get(0).Id;
        DealForecastData1.Opportunity__c = listopp.get(0).Id;
        DealForecastData1.Product__c = listpro.get(0).Id;
            
        System.debug('DealForecastData1: ' + DealForecastData1);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData1);
            ForecastAdjustmentController.getDealForecastDetail(deal.Id);
            
            List<Monthly_Forecast_Input__c> MFI = new List<Monthly_Forecast_Input__c>([SELECT Id, Deal_Forecast_Income__c, Ending_Balance__c, NI__c FROM Monthly_Forecast_Input__c WHERE Deal_Forecast_Income__c =: deal.Id]);
            ForecastAdjustmentController.saveMonthlyForecastRecord(MFI, 5);
            
            ForecastAdjustmentController.deleteDealForecastRecord(deal);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
        //CASE Fee: One-off
        Deal_Forecast_Income__c DealForecastData2 = new Deal_Forecast_Income__c();
        DealForecastData2.Income_Type__c = 'FX Fee';
        DealForecastData2.Recurring_Type__c = 'One-off';
        DealForecastData2.Probability__c = oppline.Deal_Probability__c;
        DealForecastData2.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData2.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData2.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData2.Utilization_Percent__c = 100;
        DealForecastData2.NIM_Fee_rate__c = 35;
        DealForecastData2.Volume__c = 1000000;
        DealForecastData2.Remark__c = '';
        DealForecastData2.Opportunity_Product_Id__c = oppline.id;
        DealForecastData2.Customer__c = listacc.get(0).Id;
        DealForecastData2.Opportunity__c = listopp.get(0).Id;
        DealForecastData2.Product__c = listpro.get(0).Id;
        
        System.debug('DealForecastData2: ' + DealForecastData2);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData2);
        }catch(exception e){
            System.debug(e.getMessage());
        }

        //CASE Fee: Recurring -> Monthly
        Deal_Forecast_Income__c DealForecastData3 = new Deal_Forecast_Income__c();
        DealForecastData3.Income_Type__c = 'FX Fee';
        DealForecastData3.Recurring_Type__c = 'Recurring';
        DealForecastData3.Frequency__c = 'Monthly';
        DealForecastData3.Probability__c = oppline.Deal_Probability__c;
        DealForecastData3.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData3.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData3.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData3.Utilization_Percent__c = 100;
        DealForecastData3.NIM_Fee_rate__c = 35;
        DealForecastData3.Volume__c = 1000000;
        DealForecastData3.Remark__c = '';
        DealForecastData3.Opportunity_Product_Id__c = oppline.id;
        DealForecastData3.Customer__c = listacc.get(0).Id;
        DealForecastData3.Opportunity__c = listopp.get(0).Id;
        DealForecastData3.Product__c = listpro.get(0).Id;
        
        System.debug('DealForecastData3: ' + DealForecastData3);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData3);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
        //CASE Fee: Recurring -> Quarterly
        Deal_Forecast_Income__c DealForecastData4 = new Deal_Forecast_Income__c();
        DealForecastData4.Income_Type__c = 'FX Fee';
        DealForecastData4.Recurring_Type__c = 'Recurring';
        DealForecastData4.Frequency__c = 'Quarterly';
        DealForecastData4.Probability__c = oppline.Deal_Probability__c;
        DealForecastData4.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData4.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData4.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData4.Utilization_Percent__c = 100;
        DealForecastData4.NIM_Fee_rate__c = 35;
        DealForecastData4.Volume__c = 1000000;
        DealForecastData4.Remark__c = '';
        DealForecastData4.Opportunity_Product_Id__c = oppline.id;
        DealForecastData4.Customer__c = listacc.get(0).Id;
        DealForecastData4.Opportunity__c = listopp.get(0).Id;
        DealForecastData4.Product__c = listpro.get(0).Id;
        
        System.debug('DealForecastData4: ' + DealForecastData4);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData4);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
        //CASE Fee: Recurring -> Biyearly
        Deal_Forecast_Income__c DealForecastData5 = new Deal_Forecast_Income__c();
        DealForecastData5.Income_Type__c = 'FX Fee';
        DealForecastData5.Recurring_Type__c = 'Recurring';
        DealForecastData5.Frequency__c = 'Biyearly';
        DealForecastData5.Probability__c = oppline.Deal_Probability__c;
        DealForecastData5.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData5.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData5.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData5.Utilization_Percent__c = 100;
        DealForecastData5.NIM_Fee_rate__c = 35;
        DealForecastData5.Volume__c = 1000000;
        DealForecastData5.Remark__c = '';
        DealForecastData5.Opportunity_Product_Id__c = oppline.id;
        DealForecastData5.Customer__c = listacc.get(0).Id;
        DealForecastData5.Opportunity__c = listopp.get(0).Id;
        DealForecastData5.Product__c = listpro.get(0).Id;
        
        System.debug('DealForecastData5: ' + DealForecastData5);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData5);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
        //CASE Fee: Recurring -> Yearly
        Deal_Forecast_Income__c DealForecastData6 = new Deal_Forecast_Income__c();
        DealForecastData6.Income_Type__c = 'FX Fee';
        DealForecastData6.Recurring_Type__c = 'Recurring';
        DealForecastData6.Frequency__c = 'Yearly';
        DealForecastData6.Probability__c = oppline.Deal_Probability__c;
        DealForecastData6.Expected_Start_Year__c = String.valueOf(Date.today().year());
        DealForecastData6.Expected_Start_Month__c = getMonthName(Date.today().month());
        DealForecastData6.OpportunityLineItem_Limit_Volume__c = oppline.UnitPrice;
        DealForecastData6.Utilization_Percent__c = 100;
        DealForecastData6.NIM_Fee_rate__c = 35;
        DealForecastData6.Volume__c = 1000000;
        DealForecastData6.Remark__c = '';
        DealForecastData6.Opportunity_Product_Id__c = oppline.id;
        DealForecastData6.Customer__c = listacc.get(0).Id;
        DealForecastData6.Opportunity__c = listopp.get(0).Id;
        DealForecastData6.Product__c = listpro.get(0).Id;
        
        System.debug('DealForecastData6: ' + DealForecastData6);
        try{
            Deal_Forecast_Income__c deal = ForecastAdjustmentController.saveDealForecastRecord(DealForecastData6);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void testExisting() {
        test.startTest();
        
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<product2> listpro = testutils.createProduct(1,true);
        Date genDate = Date.newInstance(System.today().year(),System.today().month()+1,0);
        Monthly_Forecast_Input__c MFI = new Monthly_Forecast_Input__c();
        MFI.RecordTypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        MFI.Customer__c = listacc.get(0).Id;
        MFI.Product__c = listpro.get(0).Id;
        MFI.Year__c = String.valueOf(genDate.year());
        MFI.Month__c = genDate.month() < 10 ? '0' + String.valueOf(genDate.month()) : String.valueOf(genDate.month());
        MFI.adjustMonthYear__c = Date.newInstance(genDate.year(),genDate.month(),1);
        MFI.TMB_Account_ID__c = 'TestAcctId';
        MFI.TMB_Ref__c = 'TestRef';
        MFI.TMB_Suffix__c = 'TestRefSuffix';
        MFI.Account_Suffix_Ref__c = 'TestAcctIdTestRefSuffixTestRef';
        MFI.YearMonthAcctSuffRef__c = MFI.Year__c + MFI.Month__c + MFI.Account_Suffix_Ref__c;
        MFI.Issue_Date__c = Date.newInstance(2020,01,01);
        MFI.Product_Type__c = 'PN';
        MFI.Gross_Rate__c = 0;
        MFI.Limit__c = 100000000;
        MFI.Current_Ending_Balance__c = 20000000;
        MFI.Maturity_Date__c = Date.newInstance(2021,11,30);
        insert MFI;
        
        
        MFI.Repay_Due_Amount_Week1__c = 1000000;
        MFI.Repay_Due_Amount_Week3__c = 3000000;
        MFI.Repay_Due_Amount_Week4__c = 4000000;
        List<Monthly_Forecast_Input__c>MFIList = new List<Monthly_Forecast_Input__c>();
        MFIList.add(MFI);
        
        String Year = String.valueOf(System.today().year());
        String Month = String.valueOf(System.today().month());
        try{
            ForecastAdjustmentController.SaveExistingRepayment(MFIList,Year,Month);
            ForecastAdjustmentController.SaveDrawdown(MFI.Customer__c,MFI.Product_Type__c,MFI.Product__c,MFI.Month__c,MFI.Year__c,'0','0','2000000','0','4000000','0');
        }catch(exception e){
            System.debug(e.getMessage());
        }
        test.stopTest();
    }
    
    
    @isTest
    public static void testRunBatch() {
        test.startTest();
        ForecastAdjustmentController.runForecastPipelineBatch('Longterm');
        ForecastAdjustmentController.runForecastPipelineBatch('ExistingFee');
        ForecastAdjustmentController.runForecastPipelineBatch('ExpireDrawdown');
        test.stopTest();
    }
}