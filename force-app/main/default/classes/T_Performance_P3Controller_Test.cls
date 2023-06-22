@isTest
public with sharing class T_Performance_P3Controller_Test {
    public static final Id SYSADMIN_PROFILE_ID{
        get
        {
            if(SYSADMIN_PROFILE_ID == null){
                SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            }
            return SYSADMIN_PROFILE_ID;
        }
        set;
    }
    
    public static final Id TMB_SYSADMIN_PROFILE_ID{
        get
        {
            if(TMB_SYSADMIN_PROFILE_ID == null){
                TMB_SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB System Administrator' LIMIT 1].Id;
            }
            return TMB_SYSADMIN_PROFILE_ID;
        }
        set;
    }

    public static final String currentYear{
        get
        {
            if(currentYear == null){
                Datetime toDayTime = Datetime.now();
                // String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                currentYear = toDayTime.format('yyyy');
            }
            return currentYear;
        }
        set;
    }

    public static final String previousYear{
        get
        {
            if(previousYear == null){
                Datetime toDayTime = Datetime.now().addYears(-1);
                // String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                previousYear = toDayTime.format('yyyy');
            }
            return previousYear;
        }
        set;
    }

    public static final String currentMonth{
        get
        {
            if(currentMonth == null){
                Datetime toDayTime = Datetime.now();
                currentMonth = String.valueOf(toDayTime.month()).leftpad(2,'0');
                // String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                // previousYear = toDayTime.format('yyyy');
            }
            return currentMonth;
        }
        set;
    }

    public static final String previousMonth{
        get
        {
            if(previousMonth == null){
                Datetime toDayTime = Datetime.now();
                Integer prevMonthInt = toDayTime.month()-1 > 0 ? toDayTime.month()-1 : 12;
                previousMonth = String.valueOf(prevMonthInt).leftpad(2,'0');
                // String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                // previousYear = toDayTime.format('yyyy');
            }
            return previousMonth;
        }
        set;
    }

    @TestSetup
    static void makeData(){
        List<User> userList = TestForP4Utils.createUsers(2, 'Takeshi', 'Nobita', 'takeshiza007@gmail.com', true);
        T_Performance_Team_List__c tl = TestForP4Utils.createPTL('015', 'สาขาคลองเตย', true);
        Team_Profile_and_KPI__c tk = TestForP4Utils.createTPK(tl.id, '6', currentYear,'สำนักพหลโยธิน', '0001', 'XL', 'HQ', Double.valueOf(1000), Double.valueOf(1000), Double.valueOf(1000) ,true);
        List<Branch_Performance_by_Pillar__c> bp =  TestForP4Utils.createBPP(2, currentYear, '04', '0001', 'Customer', 'Customer', '1', Double.valueOf(90), 'Branch', tl, true);
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',currentMonth,currentYear,'05202282827', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '82827', true);
        Sale_Performance__c sp = TestForP4Utils.createSalesPerform(currentYear, currentMonth,'82827', true);
        List<Sale_Transaction__c> stList = TestForP4Utils.createSalesTransaction(2, currentYear, currentMonth, true);
    }
    @isTest static void testNoDatagetLastedPerfomanceYear(){
        List<String> years =  new List<String>{previousYear, currentYear};
        List<String> years1 =  new List<String>() ;
        T_Performance_P3Controller.getLastedPerfomanceYear(years, 'Branch','001');
        T_Performance_P3Controller.getLastedPerfomanceYear( years1, 'Branch','001');
    }

    @isTest static void testgetLastedPerfomanceYear(){
        Date toDay = Date.Today();
        List<String> years =  new List<String>{previousYear, currentYear};
        Sale_Info__c s = new Sale_Info__c();
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
       /*  sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        T_Performance_P3Controller.getLastedPerfomanceYear(years, 'Branch','001');
        T_Performance_P3Controller.getCurrentMonthKPI('001',currentYear);
        T_Performance_P3Controller.getLastSaleInfo('001');
        List<User> loginUser = [Select Id, Name, Employee_ID__c From User];
        T_Performance_P3Controller.getWatermarkHTML();
    }

    @isTest static void testgetBranchSectionA(){
        T_Performance_P3Controller.getBranchSectionA(currentYear, '001');
    }

    @isTest static void testgetBranchInfo(){
        Date toDay = Date.Today();
        T_Performance_Team_List__c t = new T_Performance_Team_List__c();
        t.Branch_Team_Code__c = '001';
        t.Branch_Team_Name__c = 'สาขาสำนักพหลโยธิน';
        t.Branch_Team_Manager__c = 'นายรวีวงศ์  สุภาพวนิช';
        t.Channel__c = 'Branch';
        t.Region_Code__c = '1111';
        t.Zone_Code__c = '2222';
        insert t;
        Team_Profile_and_KPI__c newTeam = new Team_Profile_and_KPI__c();
        newTeam.T_Performance_Team__c = t.id;
        newTeam.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        newTeam.Year__c = currentYear;
        newTeam.Team_Name_TH__c = 'test001';
        newTeam.Branch_Tier__c = 'XL';
        newTeam.Branch_Type__c = 'HQ';
        newTeam.Working_Day__c = '5';
        newTeam.Office_Hour__c = 'จ-ศ : 08.30 - 16.00 น.';
        newTeam.Address__c = '3000 ถนนพหลโยธิน แขวงจอมพล เขตจตุจักร กทม. 10900';
        newTeam.Phone__c = '02-299-1304';
        newTeam.Branch_Transaction__c = 9999;
        newTeam.ATM_Transaction__c = 8888;
        newTeam.Digital_Transaction__c = 7777;
        newTeam.Total_Transaction__c = 26664;
        newTeam.Total_Customer__c = 66666;
        newTeam.Total_Active_Customer__c = 33333;
        newTeam.Total_Mainbank_Customer__c = 88888;
        newTeam.Net_Promoter_Score__c = 77.77;
        newTeam.Branch_Team_Code__c = '001';
        newTeam.Zone_Code__c = '1880';
        newTeam.Channel__c = 'Branch';
        newTeam.Zone__c = 'RH1';
        newTeam.Region__c = 'BANGNA';
        newTeam.Unique_External_Key__c = 'test123';
        insert newTeam;
        T_Performance_P3Controller.getBranchInfo('001','Branch','BANGNA','RH1');
    }

    @isTest static void testgetBranchInfo_NoData(){
        Date toDay = Date.Today();
        T_Performance_Team_List__c t = new T_Performance_Team_List__c();
        t.Branch_Team_Code__c = '002';
        t.Branch_Team_Name__c = 'สาขาสำนักพหลโยธิน';
        t.Branch_Team_Manager__c = 'นายรวีวงศ์  สุภาพวนิช';
        t.Channel__c = 'Branch';
        t.Region_Code__c = '1111';
        t.Zone_Code__c = '2222';
        insert t;
        Team_Profile_and_KPI__c newTeam = new Team_Profile_and_KPI__c();
        newTeam.T_Performance_Team__c = t.id;
        newTeam.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        newTeam.Year__c = currentYear;
        newTeam.Team_Name_TH__c = 'test001';
        newTeam.Branch_Tier__c = 'XL';
        newTeam.Branch_Type__c = 'HQ';
        newTeam.Working_Day__c = '5';
        newTeam.Office_Hour__c = 'จ-ศ : 08.30 - 16.00 น.';
        newTeam.Address__c = '3000 ถนนพหลโยธิน แขวงจอมพล เขตจตุจักร กทม. 10900';
        newTeam.Phone__c = '02-299-1304';
        newTeam.Branch_Transaction__c = 9999;
        newTeam.ATM_Transaction__c = 8888;
        newTeam.Digital_Transaction__c = 7777;
        newTeam.Total_Transaction__c = 26664;
        newTeam.Total_Customer__c = 66666;
        newTeam.Total_Active_Customer__c = 33333;
        newTeam.Total_Mainbank_Customer__c = 88888;
        newTeam.Net_Promoter_Score__c = 77.77;
        newTeam.Branch_Team_Code__c = '002';
        newTeam.Zone_Code__c = '1880';
        newTeam.Channel__c = 'Branch';
        newTeam.Zone__c = 'RH1';
        newTeam.Region__c = 'BANGNA';
        newTeam.Unique_External_Key__c = 'test123';
        insert newTeam;
        T_Performance_P3Controller.getBranchInfo('001','Branch','BANGNA','RH1');
    }

    @isTest static void testprepareDataForSectionD(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
       /*  s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        s.Year__c = currentYear;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Id = sp.id;
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;


        T_Performance_P3Controller.prepareDataForSectionD(currentYear,'001','Branch');
    }

    @isTest static void testprepareDataForSectionDPrevYear(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
       /*  s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        s.Year__c = previousYear;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Id = sp.id;
        sp.Year__c = previousYear;
        sp.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = previousYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        List<Sale_Transaction__c> stList1 = new List<Sale_Transaction__c>();
        Sale_Transaction__c st1 = new Sale_Transaction__c();
        st1.Year__c = previousYear;
        st1.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st1.Sale_Team__c = '001';
        st1.Channel__c = 'Branch';
        st1.Employee_ID__c = '98755';
        st1.Sale_Name__c = 'ทดสอบ พิมพ์งาม123';
        st1.Position__c = 'S_HL';
        st1.Indicator_Name__c = 'Type A';
        st1.Indicator_Level1__c = 'Investment';
        st1.Indicator_Level2__c = 'Deposit';
        st1.Indicator_Code_Level1__c = '001';
        st1.Indicator_Code_Level2__c = '120';
        st1.Indicator_Code__c = '3056' ;
        st1.Sale_Unit__c = 'หน่วย';
        st1.Actual_Point__c = 7000;
        st1.Actual_Performance__c = null;
        st1.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz';
        /* st.Sale_Info__c = s.id; */
        st1.Customer_Number__c = '001189567777700012024989';
        stList1.add(st1);
        insert stList1;


        T_Performance_P3Controller.prepareDataForSectionD(previousYear,'001','Branch');
    }

    @isTest static void testgetAvailPerfObjThisYearMonthAgo(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
       /*  s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Id = sp.id;
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        String lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, currentYear);
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, 'previousYear');
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, null);
        /* case query fail */
        String lastAvailPerfQuery1 = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM test_query_fail WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
        
        try {
            T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery1, false, currentYear);
        } catch (AuraHandledException e) {
            
        }
    }  

    @isTest static void testgetAvailPerfObjtoDay(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
       /*  s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        // sp.Id = sp.id;
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;

        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        List<Sale_Transaction__c> stList1 = new List<Sale_Transaction__c>();
        Sale_Transaction__c st1 = new Sale_Transaction__c();
        st1.Year__c = currentYear;
        st1.Month__c = '01';
        st1.Sale_Team__c = '001';
        st1.Channel__c = 'Branch';
        st1.Employee_ID__c = '987429' ;
        st1.Sale_Name__c = 'ทดสอบ พิมพ์งาม99' ;
        st1.Position__c = 'S_HL';
        st1.Indicator_Name__c = 'Type A';
        st1.Indicator_Level1__c = 'Investment';
        st1.Indicator_Level2__c = 'Deposit';
        st1.Indicator_Code_Level1__c = '001';
        st1.Indicator_Code_Level2__c = '120';
        st1.Indicator_Code__c = '3056' ;
        st1.Sale_Unit__c = 'หน่วย';
        st1.Actual_Point__c = 7000;
        st1.Actual_Performance__c = null;
        st1.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz9';
        /* st.Sale_Info__c = s.id; */
        st1.Customer_Number__c = '001189567777700012024989';
        stList1.add(st1);
        insert stList1;
        String lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, currentYear);
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, previousYear);
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, null);
        T_Performance_P3Controller.checkLastPerf();
        T_Performance_P3Controller.getSharePointLink();
        T_Performance_P3Controller.checkLastSaleInfo();
    }  

    @isTest static void testgetAvailPerfObjtoOneMonthAGO(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
       /*  s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        // sp.Id = sp.id;
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;

        String oneMonthAgo = String.valueOf(toDay.month()-1).leftPad(2,'0');
        String testYear = currentYear;
        if(toDay.month()-1 <= 0) {
            oneMonthAgo = '12';
            testYear = previousYear;
        }
        Sale_Performance__c sp2 = new Sale_Performance__c();
        // sp2.Id = sp2.id;
        sp2.Year__c = testYear;
        sp2.Month__c = oneMonthAgo;
        sp2.Employee_ID__c = '98755';
        /*2 sp.Sale_Info__c =  s.id; */
        sp2.Sale_Type__c = 'Sale Out';
        sp2.Work_Type__c = 'Sale';
        sp2.Branch_Team_Code__c = '001';
        sp2.Sale_Branch_Code__c = '001';
        sp2.Zone__c = 'CHATUCHAK';
        sp2.Region__c = 'RH2';
        sp2.Channel__c = 'Branch';
        sp2.Team_Name__c = 'สำนักพหลโยธิน';
        sp2.Number_of_Customer__c = 56;
        sp2.Actual_Point__c = 9000;
        sp2.Target_Point__c = 7000;
        sp2.Target_Other_Point__c = 1000;
        sp2.Service_Target_Point__c = 1000;
        sp2.Service_Actual_Point__c = 1500;
        sp2.Financial_Actual_Point__c = 8000;
        sp2.People_Point__c = 0;
        sp2.Operation_Point__c = 0;
        sp2.Customer_Point__c = 1000;
        sp2.Financial_Target_Point__c = 50000;
        sp2.Unique_External_Key__c = 'testcalmonthgapstest2';
        insert sp2;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        List<Sale_Transaction__c> stList1 = new List<Sale_Transaction__c>();
        Sale_Transaction__c st1 = new Sale_Transaction__c();
        st1.Year__c = currentYear;
        st1.Month__c = '01';
        st1.Sale_Team__c = '001';
        st1.Channel__c = 'Branch';
        st1.Employee_ID__c = '987429' ;
        st1.Sale_Name__c = 'ทดสอบ พิมพ์งาม99' ;
        st1.Position__c = 'S_HL';
        st1.Indicator_Name__c = 'Type A';
        st1.Indicator_Level1__c = 'Investment';
        st1.Indicator_Level2__c = 'Deposit';
        st1.Indicator_Code_Level1__c = '001';
        st1.Indicator_Code_Level2__c = '120';
        st1.Indicator_Code__c = '3056' ;
        st1.Sale_Unit__c = 'หน่วย';
        st1.Actual_Point__c = 7000;
        st1.Actual_Performance__c = null;
        st1.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz9';
        /* st.Sale_Info__c = s.id; */
        st1.Customer_Number__c = '001189567777700012024989';
        stList1.add(st1);
        insert stList1;
        String lastAvailPerfQuery = 'SELECT Year__c, Month__c, Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
        // T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, currentYear);
        // T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, previousYear);
        // T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, null);

        // String lastAvailPerfOneMonthAgo = 'SELECT Year__c, Month__c, Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' AND Month__c = \''+oneMonthAgo+'\' AND Year__c = \''+testYear+'\' LIMIT 1';
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, true, currentYear);
        T_Performance_P3Controller.checkLastPerf();
        T_Performance_P3Controller.getSharePointLink();
        T_Performance_P3Controller.checkLastSaleInfo();
    }  
    
    @isTest static void testgetAvailPerfObLastYear(){
        Date toDay = Date.Today();
        Date hireDay = date.valueOf('2019-05-28');
        Sale_Info__c s = new Sale_Info__c();
        /* s.Id = s.id; */
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Name = 'ทดสอบ';
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        s.Sale_Hire_Date__c = hireDay;
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Id = sp.id;
        sp.Year__c = previousYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = previousYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
       /*  st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        String lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+'Sale Out'+'\' AND Channel__c = \''+'Branch'+'\' AND Sale_Branch_Code__c = \''+'001'+'\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, currentYear);
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, previousYear);
        T_Performance_P3Controller.getAvailPerfObj( lastAvailPerfQuery, false, null);
    } 

    @isTest static void testsumBankWideTrans(){
        Date toDay = Date.Today();
        Sale_Info__c s = new Sale_Info__c();
        /* s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale In';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale In';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        T_Performance_P3Controller.sumTransBankWideWrapperSectionC testWrapper = new  T_Performance_P3Controller.sumTransBankWideWrapperSectionC();
        testWrapper.sumTrans = null;
        testWrapper.sumBranchTransQueryCond = ' WHERE Channel__c = \''+'Branch'+'\' AND Sale_Team__c = \''+'001'+'\' ';
        testWrapper.lastRecordId = stList[0].id;
        System.debug('lastRecordId'+testWrapper.lastRecordId );
        testWrapper.isEndRecord = false;
        testWrapper.sumPerfPoint = null;
        testWrapper.totalTarget = null;
        testWrapper.totalBankTransSum = null;
        T_Performance_P3Controller.sumBankWideTrans(testWrapper);

        T_Performance_P3Controller.sumTransBankWideWrapperSectionC testWrapper1 = new  T_Performance_P3Controller.sumTransBankWideWrapperSectionC();
        testWrapper1.sumTrans = null;
        testWrapper1.sumBranchTransQueryCond = ' WHERE test_wrong = \''+'Branch'+'\' AND Sale_Team__c = \''+'001'+'\' ';
        testWrapper1.lastRecordId = null;
        System.debug('lastRecordId'+testWrapper1.lastRecordId );
        testWrapper1.isEndRecord = false;
        testWrapper1.sumPerfPoint = null;
        testWrapper1.totalTarget = null;
        testWrapper1.totalBankTransSum = null;
        
        try {
            T_Performance_P3Controller.sumBankWideTrans(testWrapper1);
        } catch (AuraHandledException e) {
            
        }
    }

    @isTest static void testsumBankWidePerf(){
        Date toDay = Date.Today();
        Sale_Info__c s = new Sale_Info__c();
        /* s.Id = s.id; */
        s.Name = 'ทดสอบ';
        s.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        s.Year__c = currentYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale In';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'เทส';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '98755';
        s.Branch_Code__c = '001';
        s.Branch_Name__c = 'ขอทดสอบ';
        s.Position__c = 'GENE';
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = '98755';
        /* sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale In';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Sale_Branch_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 9000;
        sp.Target_Point__c = 7000;
        sp.Target_Other_Point__c = 1000;
        sp.Service_Target_Point__c = 1000;
        sp.Service_Actual_Point__c = 1500;
        sp.Financial_Actual_Point__c = 8000;
        sp.People_Point__c = 0;
        sp.Operation_Point__c = 0;
        sp.Customer_Point__c = 1000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testcalmonthgapstest';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '001';
        st.Channel__c = 'Branch';
        st.Employee_ID__c = '98742'+i ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม'+i ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Type A';
        st.Indicator_Level1__c = 'Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Unique_External_Key__c = 'sdsddsxtestdwdaaazzwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '001189567777700012024989';
        stList.add(st);
        }
        insert stList;
        T_Performance_P3Controller.sumPerfBankWideWrapperSectionC sumPerfObj = new  T_Performance_P3Controller.sumPerfBankWideWrapperSectionC();
        sumPerfObj.salePerfBank = null;
        sumPerfObj.sumQueryCond = ' WHERE Channel__c = \''+'Branch'+'\' AND Branch_Team_Code__c = \''+'001'+'\' ';
        sumPerfObj.lastRecordId = stList[0].id;
        sumPerfObj.isEndRecord = false;
        T_Performance_P3Controller.sumPerfBankWideWrapperSectionC sumPerfObj1 = new  T_Performance_P3Controller.sumPerfBankWideWrapperSectionC();
        sumPerfObj1.salePerfBank = sp;
        sumPerfObj1.sumQueryCond = ' WHERE Test_Wrong_field = \''+'Branch'+'\' AND Branch_Team_Code__c = \''+'001'+'\' ';
        sumPerfObj1.lastRecordId = null;
        sumPerfObj1.isEndRecord = false;
        T_Performance_P3Controller.sumBankWidePerf(sumPerfObj);
        try {
            T_Performance_P3Controller.sumBankWidePerf(sumPerfObj1);
        } catch (AuraHandledException e) {
            
        }
        try {
            T_Performance_P3Controller.sumPerfAgg(sumPerfObj1.sumQueryCond);
        } catch (AuraHandledException e) {
            
        }
        
        T_Performance_P3Controller.sumPerfAgg(sumPerfObj.sumQueryCond);
        T_Performance_P3Controller.sumPerfAgg(' WHERE Channel__c = \''+'Branch'+'\' AND Branch_Team_Code__c = \''+'002'+'\' ');
        T_Performance_P3Controller.checkPerfIsReceived(String.valueOf(toDay.month()).leftPad(2,'0'),currentYear);
        T_Performance_P3Controller.checkPerfIsReceived(String.valueOf(toDay.month()).leftPad(2,'0'),'2023');
    }


}