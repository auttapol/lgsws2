@isTest
public class T_Performance_P2Controller_Test {
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

    @TestSetup
    static void makeData(){
        List<User> userList = TestForP4Utils.createUsers(2, 'Takeshi', 'Nobita', 'takeshiza007@gmail.com', true);
         T_Performance_Team_List__c tl = TestForP4Utils.createPTL('015', 'สาขาคลองเตย', true);
        Team_Profile_and_KPI__c tk = TestForP4Utils.createTPK(tl.id, '6', '2022','สำนักพหลโยธิน', '0001', 'XL', 'HQ', Double.valueOf(1000), Double.valueOf(1000), Double.valueOf(1000) ,true);
        List<Branch_Performance_by_Pillar__c> bp =  TestForP4Utils.createBPP(2, '2022', '04', '0001', 'Customer', 'Customer', '1', Double.valueOf(90), 'Branch', tl, true);
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์','05','2022','0520228287', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '82827', true);
        Sale_Performance__c sp = TestForP4Utils.createSalesPerform('2022', '05','82827', true);
        List<Sale_Transaction__c> stList = TestForP4Utils.createSalesTransaction(2, '2022', '05', true);
    }
    @isTest static void testGetSharePointLink(){
        T_Performance_P2Controller.getSharePointLink();
    }
    @isTest static void testGetWatermarkHTML(){

        T_Performance_P2Controller.getWatermarkHTML();
    }
    // @isTest static void testGetPerformanceDataP2(){
    //     Date toDay = Date.Today();
    //     User newUser = new User(FirstName = 'kittisak' , LastName = 'Lamnoi', 
    //     UserName='kittisak_Lamnoi@tmbbank.com',
    //     Email='kittisak_Lamnoi@gmail.com', Alias='Testtmb',
    //     LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
    //     CommunityNickname='kittisak'+'_'+'Lamnoi'+'_'+'TMBTesttmb',
    //     ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
    //     Employee_ID__c ='88881'
    //     ,RTL_License_No_Complex_P2__c = null
    //     );
    //     insert newUser;
    //     Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),
    //     '2022',String.valueOf(toDay.month()).leftPad(2,'0')+'2022'+String.valueOf(toDay.month()).leftPad(2,'0')+'88881', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '88881', true);
    //     // test.startTest();
    //     Integer currMonthInt = datetime.now().month();
    //     String currYearStr = Datetime.now().format('yyyy');
    //     T_Performance_P2Controller.getPerformanceDataP2('88881', 0, 1, 'name', 'Home Equity with MRTA',currMonthInt ,currYearStr);
    //     // getPerformanceDataP2(String empId, Integer startRow, Integer endRow, String keyTypeFilter, String keyValueFilter, Integer selectedMonth, String selectedYear)
    //     // test.stopTest();
    // }
    
    
    // @isTest static void testGetPerformanceDataP2_EmpId_Null(){
        //     User newUser = new User(FirstName = 'kittisak' , LastName = 'Lamnoi', 
        //     UserName='kittisak_Lamnoi@tmbbank.com',
        //     Email='kittisak_Lamnoi@gmail.com', Alias='Testtmb',
        //     LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
        //     CommunityNickname='kittisak'+'_'+'Lamnoi'+'_'+'TMBTesttmb',
        //     ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
    //     Employee_ID__c ='88881'
    //     ,RTL_License_No_Complex_P2__c = null
    //     );
    //     insert newUser;
    //     Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '88881', true);
    //     test.startTest();
    //     T_Performance_P2Controller.getPerformanceDataP2(null, 0, 1, 'name', 'Home Equity with MRTA', 5, '2022');
    //     test.stopTest();
    // }
    // @isTest static void testGetPerformanceDataP2_License(){
        //     // Line 67: (licenseInfo.RTL_License_No_IP__c != null ? licenseInfo.RTL_License_No_IP__c : licenseInfo.RTL_License_No_ICT__c )
        //     T_Performance_P2Controller.getPerformanceDataP2('52625' , 0, 1, 'name', 'Home Equity with MRTA');
        // }
        
        @isTest static void testGetPerformanceDataP2_phase1_1(){
            Date toDay = Date.Today();
            Date kpiDay = date.valueOf('2022-01-01');
            Date deDay = date.valueOf('2022-01-08');
            User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                        UserName='testnotsame@tmbbank.com',
                                        Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                        LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                        CommunityNickname='whereareyouTMBTesttmb',
                                        ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                        Employee_ID__c ='74185',
                                        // RTL_License_No_Complex_P2__c = null,
                                        // RTL_Expiry_Date_Complex_P2__c = null,
                                        // RTL_Active_Flag_Wealthy_Link__c = false,
    
                                        RTL_License_No_Life_Insurance__c = '6203008582',
                                        RTL_Expiry_Date_Life_Insurance__c = toDay.addYears(1),
                                        RTL_License_No_Non_Life_Insurance__c = '6404004513',
                                        RTL_Expiry_Date_Non_Life_Insurance__c = toDay.addYears(1),
    
                                        RTL_License_No_Paper_1__c = null,
                                        RTL_Expiry_Date_Paper_1__c = null,
                                        RTL_License_No_Paper_4__c = null,
                                        RTL_Expiry_Date_Paper_4__c = null,
                                        RTL_License_No_Paper_5__c = null,//'111858',
                                        RTL_Expiry_Date_Paper_5__c = toDay.addYears(1),
                                        RTL_License_No_ICP_1__c = null,
                                        RTL_Expiry_Date_ICP_1__c = null,
                                        RTL_License_No_Complex_P2__c = '111858',
                                        RTL_Expiry_Date_Complex_P2__c = null,
                                        RTL_License_No_ICP_3__c = null,
                                        RTL_Expiry_Date_ICP_3__c = null,
                                        RTL_License_No_IP__c = null,
                                        RTL_Expiry_Date_IP__c = null,
                                        RTL_License_No_ICT__c = '123456',
                                        RTL_Expiry_Date_ICT__c = toDay.addYears(1),
    
                                        RTL_License_No_Wealthy_Link__c = null,
                                        RTL_Expiry_Date_Wealthy_Link__c = null,
                                        RTL_Active_Flag_Wealthy_Link__c = false,
                                        RTL_License_No_Unit_Link__c = '654321',
                                        RTL_Expiry_Date_Unit_Link__c = toDay.addYears(1),
                                        RTL_Active_Flag_Unit_Link__c = true 
                                        );
    
            
            insert newUser;
            Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์', String.valueOf(toDay.month()).leftPad(2,'0'), '2021', String.valueOf(toDay.month()).leftPad(2,'0')+'2021'+String.valueOf(toDay.month()).leftPad(2,'0')+'74185', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '74185', true);
            /* System.debug('Debug of si: '+si); */

            List<Sale_Performance__c> salePerfomanceList = new List<Sale_Performance__c>();
            Sale_Performance__c sp1 = new Sale_Performance__c();
            sp1.Year__c = Datetime.now().format('yyyy');
            sp1.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
            sp1.Employee_ID__c = '74185';
            /* sp1.Sale_Info__c =  si.id; */
            sp1.Sale_Type__c = 'Sale Out';
            sp1.Position__c = 'CSO';
            sp1.Work_Type__c = 'Sale';
            sp1.Branch_Team_Code__c = '001';
            sp1.Zone__c = 'CHATUCHAK';
            sp1.Region__c = 'RH2';
            sp1.Channel__c = 'Branch';
            sp1.Team_Name__c = 'สำนักพหลโยธิน';
            sp1.Number_of_Customer__c = 56;
            sp1.Actual_Point__c = 9000;
            sp1.Target_Point__c = 7000;
            sp1.Target_Other_Point__c = 1000;
            sp1.Service_Target_Point__c = 1000;
            sp1.Service_Actual_Point__c = 1500;
            sp1.People_Point__c = 10;
            sp1.Operation_Point__c = 10;
            sp1.Customer_Point__c = 1000;
            sp1.Financial_Actual_Point__c = 8000;
            sp1.Financial_Target_Point__c = 50000;
            sp1.Unique_External_Key__c = 'testmonthperiod1';
            salePerfomanceList.add(sp1); 

            Sale_Performance__c sp2 = new Sale_Performance__c();
            sp2.Year__c = Datetime.now().format('yyyy');
            sp2.Month__c = String.valueOf(toDay.month()-1 > 0 ? toDay.month()-1: toDay.month()).leftPad(2,'0');
            sp2.Employee_ID__c = '74185';
            /* sp2.Sale_Info__c =  si.id; */
            sp2.Sale_Type__c = 'Sale Out';
            sp2.Position__c = 'CSO';
            sp2.Work_Type__c = 'Sale';
            sp2.Branch_Team_Code__c = '001';
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
            sp2.People_Point__c = 10;
            sp2.Operation_Point__c = 10;
            sp2.Customer_Point__c = 1000;
            sp2.Financial_Actual_Point__c = 8000;
            sp2.Financial_Target_Point__c = 50000;
            sp2.Unique_External_Key__c = 'testmonthperiod2';
            salePerfomanceList.add(sp2); 
            insert salePerfomanceList; 

            List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
            for(Integer i=0; i<2 ;i++){
            Sale_Transaction__c st = new Sale_Transaction__c();
            st.Year__c = Datetime.now().format('yyyy');
            // st.Month__c = String.valueOf(i+1).leftPad(2,'0');
            st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
            st.Sale_Team__c = '0001';
            st.Zone__c = 'RH6';
            st.Region__c = '9220';
            st.Channel__c = 'Branch';
            st.Book_Service_Branch__c = '148' + i;
            st.Employee_ID__c = '74185' ;
            st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
            st.Position__c = 'S_HL';
            st.Indicator_Name__c = 'Home Equity with MRTA';
            st.Indicator_Level1__c = 'Deposit & Investment';
            st.Indicator_Level2__c = 'Deposit';
            st.Indicator_Code_Level1__c = '001';
            st.Indicator_Code_Level2__c = '120';
            // st.Indicator_Code__c = '3056' ;
            st.Indicator_Code__c = '00'+String.valueOf(i+1) ;
            st.Sale_Unit__c = 'บัญชี';
            st.Actual_Point__c = 7000;
            st.Actual_Performance__c = null;
            st.Deduct_Flag__c = 'T';
            st.Deduct_Date__c = deDay;
            st.Deduct_Point__c = null;
            st.KPI_Date__c = kpiDay;
            st.Unique_External_Key__c = 'szxcwlqwezxyyulqwdwzz' + i;
            /* st.Sale_Info__c = si.id; */
            st.Customer_Number__c = '001104564560656000000012024989';

            st.Actual_Point__c = 10000;

            stList.add(st);
            }
            insert stList;

            List<T_Performance_Indicator_License__c> indicatorLicenseList = new List<T_Performance_Indicator_License__c>();
            T_Performance_Indicator_License__c indicatorLicense1 = new T_Performance_Indicator_License__c();
            indicatorLicense1.Indicator_Code__c = '001';
            indicatorLicense1.License_Type__c= 'UL;LB;NLB;IC;';
            indicatorLicenseList.add(indicatorLicense1);
            
            insert indicatorLicenseList;

            AppConfig__c ac = new AppConfig__c();
            ac.Name = 'Percent Success Criteria';
            ac.Value__c =  null;
            insert ac;

            Integer currMonthInt = datetime.now().month();
            String currYearStr = Datetime.now().format('yyyy');
            /* T_Performance_P2Controller.getPerformanceDataP2('74185', 0, 1, 'name', 'Home Equity with MRTA',currMonthInt ,currYearStr); */
            T_Performance_P2Controller.getPerformanceDataP2('74185', 0, 1,currMonthInt ,currYearStr);

        }
        @isTest static void testGetPerformanceDataP2_phase1_1_V2(){
            Date toDay = Date.Today();
            Date kpiDay = date.valueOf('2022-01-01');
            Date deDay = date.valueOf('2022-01-08');
            User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                        UserName='testnotsame@tmbbank.com',
                                        Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                        LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                        CommunityNickname='whereareyouTMBTesttmb',
                                        ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                        Employee_ID__c ='74185',
                                        // RTL_License_No_Complex_P2__c = null,
                                        // RTL_Expiry_Date_Complex_P2__c = null,
                                        // RTL_Active_Flag_Wealthy_Link__c = false,
    
                                        RTL_License_No_Life_Insurance__c = '6203008582',
                                        RTL_Expiry_Date_Life_Insurance__c = toDay.addYears(1),
                                        RTL_License_No_Non_Life_Insurance__c = '6404004513',
                                        RTL_Expiry_Date_Non_Life_Insurance__c = toDay.addYears(1),
    
                                        RTL_License_No_Paper_1__c = null,
                                        RTL_Expiry_Date_Paper_1__c = null,
                                        RTL_License_No_Paper_4__c = null,
                                        RTL_Expiry_Date_Paper_4__c = null,
                                        RTL_License_No_Paper_5__c = null,//'111858',
                                        RTL_Expiry_Date_Paper_5__c = toDay.addYears(1),
                                        RTL_License_No_ICP_1__c = null,
                                        RTL_Expiry_Date_ICP_1__c = null,
                                        RTL_License_No_Complex_P2__c = '111858',
                                        RTL_Expiry_Date_Complex_P2__c = null,
                                        RTL_License_No_ICP_3__c = null,
                                        RTL_Expiry_Date_ICP_3__c = null,
                                        RTL_License_No_IP__c = null,
                                        RTL_Expiry_Date_IP__c = null,
                                        RTL_License_No_ICT__c = '123456',
                                        RTL_Expiry_Date_ICT__c = toDay.addYears(1),
    
                                        RTL_License_No_Wealthy_Link__c = null,
                                        RTL_Expiry_Date_Wealthy_Link__c = null,
                                        RTL_Active_Flag_Wealthy_Link__c = false,
                                        RTL_License_No_Unit_Link__c = '654321',
                                        RTL_Expiry_Date_Unit_Link__c = toDay.addYears(1),
                                        RTL_Active_Flag_Unit_Link__c = true 
                                        );
    
            
            insert newUser;
            Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์', String.valueOf(toDay.month()).leftPad(2,'0'), '2021', String.valueOf(toDay.month()).leftPad(2,'0')+'2021'+String.valueOf(toDay.month()).leftPad(2,'0')+'74185', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '74185', true);
            /* System.debug('Debug of si: '+si); */

            List<Sale_Performance__c> salePerfomanceList = new List<Sale_Performance__c>();
            Sale_Performance__c sp1 = new Sale_Performance__c();
            sp1.Year__c = Datetime.now().format('yyyy');
            sp1.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
            sp1.Employee_ID__c = '74185';
            /* sp1.Sale_Info__c =  si.id; */
            sp1.Sale_Type__c = 'Sale Out';
            sp1.Position__c = 'CSO';
            sp1.Work_Type__c = 'Sale';
            sp1.Branch_Team_Code__c = '001';
            sp1.Zone__c = 'CHATUCHAK';
            sp1.Region__c = 'RH2';
            sp1.Channel__c = 'Branch';
            sp1.Team_Name__c = 'สำนักพหลโยธิน';
            sp1.Number_of_Customer__c = 56;
            sp1.Actual_Point__c = 9000;
            sp1.Target_Point__c = 7000;
            sp1.Target_Other_Point__c = 1000;
            sp1.Service_Target_Point__c = 1000;
            sp1.Service_Actual_Point__c = 1500;
            sp1.People_Point__c = 10;
            sp1.Operation_Point__c = 10;
            sp1.Customer_Point__c = 1000;
            sp1.Financial_Actual_Point__c = 8000;
            sp1.Financial_Target_Point__c = 50000;
            sp1.Unique_External_Key__c = 'testmonthperiod1';
            salePerfomanceList.add(sp1); 
            insert salePerfomanceList; 

            List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
            for(Integer i=0; i<2 ;i++){
            Sale_Transaction__c st = new Sale_Transaction__c();
            st.Year__c = Datetime.now().format('yyyy');
            // st.Month__c = String.valueOf(i+1).leftPad(2,'0');
            st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
            st.Sale_Team__c = '0001';
            st.Zone__c = 'RH6';
            st.Region__c = '9220';
            st.Channel__c = 'Branch';
            st.Book_Service_Branch__c = '148' + i;
            st.Employee_ID__c = '74185' ;
            st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
            st.Position__c = 'S_HL';
            st.Indicator_Name__c = 'Home Equity with MRTA';
            st.Indicator_Level1__c = 'Deposit & Investment';
            st.Indicator_Level2__c = 'Deposit';
            st.Indicator_Code_Level1__c = '001';
            st.Indicator_Code_Level2__c = '120';
            // st.Indicator_Code__c = '3056' ;
            st.Indicator_Code__c = '00'+String.valueOf(i+1) ;
            st.Sale_Unit__c = 'บัญชี';
            st.Actual_Point__c = 7000;
            st.Actual_Performance__c = null;
            st.Deduct_Flag__c = 'T';
            st.Deduct_Date__c = deDay;
            st.Deduct_Point__c = null;
            st.KPI_Date__c = kpiDay;
            st.Unique_External_Key__c = 'szxcwlqwezxyyulqwdwzz' + i;
            /* st.Sale_Info__c = si.id; */
            st.Customer_Number__c = '001104564560656000000012024989';
            st.Actual_Point__c = 10000;

            stList.add(st);
            }
            insert stList;

            List<T_Performance_Indicator_License__c> indicatorLicenseList = new List<T_Performance_Indicator_License__c>();
            T_Performance_Indicator_License__c indicatorLicense1 = new T_Performance_Indicator_License__c();
            indicatorLicense1.Indicator_Code__c = '001';
            indicatorLicense1.License_Type__c= 'UL';
            indicatorLicenseList.add(indicatorLicense1);
            
            insert indicatorLicenseList;

            AppConfig__c ac = new AppConfig__c();
            ac.Name = 'Percent Success Criteria';
            ac.Value__c =  null;
            insert ac;
            Integer currMonthInt = datetime.now().month();
            String currYearStr = Datetime.now().format('yyyy');
            T_Performance_P2Controller.chunkQueryWrapper chunkQuery = new  T_Performance_P2Controller.chunkQueryWrapper();
            chunkQuery.chunkSize = 35000;
            chunkQuery.fieldList = 'Id,Actual_Point__c';
            chunkQuery.queryObject = 'Sale_Transaction__c';
            chunkQuery.condition = 'WHERE Employee_ID__c = \'74185\' ';
            chunkQuery.isEndRecord = false;
            chunkQuery.lastRecordId = null;
            chunkQuery.resultRecords = null;

            T_Performance_P2Controller.chunkQueryWrapper chunkQuery2 = new  T_Performance_P2Controller.chunkQueryWrapper();
            chunkQuery2.chunkSize = 1;
            chunkQuery2.fieldList = 'Id,Actual_Point__c';
            chunkQuery2.queryObject = 'Sale_Transaction__c';
            chunkQuery2.condition = null;
            chunkQuery2.isEndRecord = false;
            chunkQuery2.lastRecordId = null;
            chunkQuery2.resultRecords = null;

            T_Performance_P2Controller.chunkQueryWrapper chunkQueryLastRecordId = new  T_Performance_P2Controller.chunkQueryWrapper();
            chunkQueryLastRecordId.chunkSize = 1;
            chunkQueryLastRecordId.fieldList = 'Id,Actual_Point__c';
            chunkQueryLastRecordId.queryObject = 'Sale_Transaction__c';
            chunkQueryLastRecordId.condition = null;
            chunkQueryLastRecordId.isEndRecord = false;
            chunkQueryLastRecordId.lastRecordId = stList[0].id;
            chunkQueryLastRecordId.resultRecords = null;

            T_Performance_P2Controller.getPerformanceDataP2('74185', 0, 1,currMonthInt ,currYearStr);
            T_Performance_P2Controller.getProductList('74185','Deposit & Investment','lv1',currMonthInt ,currYearStr);
            T_Performance_P2Controller.chunkQuery(chunkQuery);
            T_Performance_P2Controller.chunkQuery(chunkQuery2);
            T_Performance_P2Controller.chunkQuery(chunkQueryLastRecordId);

        }
    }