@isTest
public with sharing class T_Performance_P1Controller_Test {
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
        List<Branch_Performance_by_Pillar__c> bp =  TestForP4Utils.createBPP(2, currentYear, previousMonth, '0001', 'Customer', 'Customer', '1', Double.valueOf(90), 'Branch', tl, true);
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',currentMonth,currentYear,'0520228287','Sale Out', 'Sale', 'สำนักพหลโยธิน', '82827', true);
        Sale_Performance__c sp = TestForP4Utils.createSalesPerform(currentYear, currentMonth,'82827', true);
        List<Sale_Transaction__c> stList = TestForP4Utils.createSalesTransaction(2, currentYear, currentMonth, true);
    }
 
    @isTest static void testGetPerformanceDataP1V1(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-'+currentMonth+'-21');
        Date deDay = date.valueOf(currentYear+'-'+currentMonth+'-28');
        User newUser = new User(FirstName = 'doraemon' , LastName = 'knwza', 
                                    UserName='testmaisamena@tmbbank.com',
                                    Email='testmaisamena@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='heawkaowTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test001',
                                    
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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),
                                                                        currentYear,String.valueOf(toDay.month()).leftPad(2,'0')+currentYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test001',
                                                                        'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test001', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = 'Test001';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'sdfjlkdsjaswqew';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test001' ;
        st.Sale_Name__c = 'จักร พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'หน่วย';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Deduct_Flag__c = 'T';
        st.Deduct_Date__c = deDay;
        st.Deduct_Point__c = null;
        st.KPI_Date__c = kpiDay;
        st.Unique_External_Key__c = 'sdljflqwdwzz' + i;
        /* st.Sale_Info__c = si.id; */
        st.Customer_Number__c = '001100000000000000000012024989';
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;
       /*  test.startTest(); */
        T_Performance_P1Controller.getPerformanceDataP1('Test001', 'year', currentYear, 1);
        List<User> loginUser = [Select Id, Name, Employee_ID__c From User];
        T_Performance_P1Controller.getWatermarkHTML();
        T_Performance_P1Controller.getLastAvailData('Test001');
        /* T_Performance_P1Controller.getLastAvailData(null); */
        /* test.stopTest(); */
    }

    @isTest static void testGetPerformanceDataP1V2(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(previousYear+'-'+currentMonth+'-21');
        Date deDay = date.valueOf(previousYear+'-'+currentMonth+'-28');
        User newUser = new User(FirstName = 'giant' , LastName = 'test', 
        UserName='testp1na@tmbbank.com',
        Email='testp1na@gmail.com', Alias='Testtmb',
        LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
        CommunityNickname='giantTMBTesttmb',
        ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
        Employee_ID__c ='Test002',

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
        RTL_Active_Flag_Unit_Link__c = true );
        insert newUser;
        Sale_Info__c s = new Sale_Info__c();
        s.Name = 'จุฬามาส เจียกจันทร์';
        s.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        s.Year__c = previousYear;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Sale_Type__c = 'Sale Out';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'สำนักพหลโยธิน';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Wealth Bankking';
        s.Employee_ID__c = 'Test002';
        s.BM_Expected__c = 'CYC';
        s.CYC_Grade__c = 'A+';
        s.HL_Grade__c = 'B';
        s.SME_Grade__c = 'B+';
        s.Fund_Grade__c = 'C';
        insert s;
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = previousYear;
        sp.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        sp.Employee_ID__c = 'Test002';
       /*  sp.Sale_Info__c =  s.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Wealth Bankking';
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
        sp.Unique_External_Key__c = 'qweasdzxcgg';
        insert sp;
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = previousYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'Wealth Bankking';
        st.Book_Service_Branch__c = '120' + i;
        st.Employee_ID__c = 'Test002' ;
        st.Sale_Name__c = 'ทดสอบ พิมพ์งาม' ;
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
        st.Deduct_Flag__c = 'T';
        st.Deduct_Date__c = deDay;
        st.Deduct_Point__c = null;
        st.KPI_Date__c = kpiDay;
        st.Unique_External_Key__c = 'sdsddsxdwdwzz' + i;
        /* st.Sale_Info__c = s.id; */
        st.Customer_Number__c = '00110067777700012024989';
        stList.add(st);
        }
        insert stList;
        T_Performance_P1Controller.getPerformanceDataP1('Test002', 'year', previousYear, 1);
        T_Performance_P1Controller.getLastAvailData('Test002');
       /*  T_Performance_P1Controller.getLastAvailData(null); */
    }

    @isTest static void testGetPerformanceDataP1V3(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-06-01');
        Date deDay = date.valueOf(currentYear+'-06-08');
        User newUser = new User(FirstName = 'doraemon' , LastName = 'knwza', 
                                    UserName='testmaisamena@tmbbank.com',
                                    Email='testmaisamena@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='heawkaowTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test003',

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
                                    RTL_Active_Flag_Unit_Link__c = true );
        insert newUser;
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),
        currentYear,String.valueOf(toDay.month()).leftPad(2,'0')+currentYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test003', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test003', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = 'Test003';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test003' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'บัญชี';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Deduct_Flag__c = 'T';
        st.Deduct_Date__c = deDay;
        st.Deduct_Point__c = null;
        st.KPI_Date__c = kpiDay;
        st.Unique_External_Key__c = 'sdlqwezxcjflqwdwzz' + i;
        /* st.Sale_Info__c = si.id; */
        st.Customer_Number__c = '00110456000000000000012024989';
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;
        T_Performance_P1Controller.getPerformanceDataP1('Test003', 'month', currentYear, toDay.month());
    }
    
    
    @isTest static void testGetPerformanceDataP1V4(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-07-01');
        Date deDay = date.valueOf(currentYear+'-07-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',

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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()-2).leftPad(2,'0'),currentYear,String.valueOf(toDay.month()-2).leftPad(2,'0')+currentYear+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()-2).leftPad(2,'0');
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
        st.Sale_Unit__c = 'บัญชี';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = null;
        st.Deduct_Flag__c = 'T';
        st.Deduct_Date__c = deDay;
        st.Deduct_Point__c = null;
        st.KPI_Date__c = kpiDay;
        st.Unique_External_Key__c = 'szxcwlqwezxcjflqwdwzz' + i;
        /* st.Sale_Info__c = si.id; */
        st.Customer_Number__c = '001104564560000000000012024989';
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;
        T_Performance_P1Controller.getPerformanceDataP1('Test004', 'month', currentYear, toDay.month()-1);
    }
    
    @isTest static void testGetPerformanceDataP1V5(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-01-01');
        Date deDay = date.valueOf(currentYear+'-01-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',
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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),previousYear,String.valueOf(toDay.month()).leftPad(2,'0')+previousYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = previousYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = previousYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
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
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;

        // "RTL_License_No_Life_Insurance__c" : "6203008582",
        T_Performance_P1Controller.getPerformanceDataP1('Test004', 'month', previousYear, toDay.month());
    }
    @isTest static void testGetSharePointLink(){
        T_Performance_P1Controller.getSharePointLink();
    }

    @isTest static void testGetTargetProductTable(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-01-01');
        Date deDay = date.valueOf(currentYear+'-01-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',
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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),previousYear,String.valueOf(toDay.month()).leftPad(2,'0')+previousYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = previousYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = '01';
        // st.Month__c = String.valueOf(i+1).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        // st.Indicator_Code__c = '3056' ;
        st.Indicator_Code__c = '001' ;
        st.Sale_Unit__c = 'บัญชี';
        st.Actual_Point__c = 7000;
        st.Actual_Performance__c = 200;
        st.Deduct_Flag__c = 'T';
        st.Deduct_Date__c = deDay;
        st.Deduct_Point__c = null;
        st.KPI_Date__c = kpiDay;
        st.Unique_External_Key__c = 'szxcwlqwezxyyulqwdwzz' + i;
        /* st.Sale_Info__c = si.id; */
        st.Customer_Number__c = '001104564560656000000012024989';
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;

        List<T_Performance_Target_Product_by_Sales__c> targetProductList = new List<T_Performance_Target_Product_by_Sales__c>();
            T_Performance_Target_Product_by_Sales__c targetProduct_1 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_1.Cap_Max_Pct__c = 130;
            targetProduct_1.Employee_ID__c = 'Test004' ;
            targetProduct_1.Unique_External_Key__c = 'Unique_External_Key_001';
            targetProduct_1.Month__c = '01';
            targetProduct_1.Product_Group__c = 'Product 2';
            targetProduct_1.Product_Group_Code__c = '001';
            targetProduct_1.Product_List__c = '001;';
            targetProduct_1.Rank__c = '1';
            targetProduct_1.Sub_Group_Flag__c = false;
            targetProduct_1.Target_Point__c = 200 ;
            targetProduct_1.Target_Unit__c = 20000;
            targetProduct_1.Unit__c = 'Unit';
            targetProduct_1.Weight_Pct__c = 10;
            targetProduct_1.Year__c = String.valueOf(toDay.year());
            // targetProduct_1.Weight_Pct_Year__c = 10;
            // targetProduct_1.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_1);

            T_Performance_Target_Product_by_Sales__c targetProduct_2 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_2.Cap_Max_Pct__c = 130;
            targetProduct_2.Employee_ID__c = 'Test004' ;
            targetProduct_2.Unique_External_Key__c = 'Unique_External_Key_002';
            targetProduct_2.Month__c = '02';
            targetProduct_2.Product_Group__c = 'Product 2';
            targetProduct_2.Product_Group_Code__c = '001';
            targetProduct_2.Product_List__c = '001;002;';
            targetProduct_2.Rank__c = '2';
            targetProduct_2.Sub_Group_Flag__c = false;
            targetProduct_2.Target_Point__c = 200 ;
            targetProduct_2.Target_Unit__c = 20000;
            targetProduct_2.Unit__c = 'Unit';
            targetProduct_2.Weight_Pct__c = 10;
            targetProduct_2.Year__c = String.valueOf(toDay.year());
            // targetProduct_2.Weight_Pct_Year__c = 10;
            // targetProduct_2.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_2);
            T_Performance_Target_Product_by_Sales__c targetProduct_3 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_3.Cap_Max_Pct__c = 130;
            targetProduct_3.Employee_ID__c = 'Test004' ;
            targetProduct_3.Unique_External_Key__c = 'Unique_External_Key_003';
            targetProduct_3.Month__c = '02';
            targetProduct_3.Product_Group__c = 'Product 1';
            targetProduct_3.Product_Group_Code__c = '002';
            targetProduct_3.Product_List__c = 'T022;';
            targetProduct_3.Rank__c = '3';
            targetProduct_3.Sub_Group_Flag__c = false;
            targetProduct_3.Target_Point__c = 200 ;
            targetProduct_3.Target_Unit__c = 20000;
            targetProduct_3.Unit__c = 'Unit';
            targetProduct_3.Weight_Pct__c = 10;
            targetProduct_3.Year__c = previousYear;
            // targetProduct_3.Weight_Pct_Year__c = 10;
            // targetProduct_3.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_3);
            T_Performance_Target_Product_by_Sales__c targetProduct_4 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_4.Cap_Max_Pct__c = 130;
            targetProduct_4.Employee_ID__c = 'Test004' ;
            targetProduct_4.Unique_External_Key__c = 'Unique_External_Key_004';
            targetProduct_4.Month__c = '01';
            targetProduct_4.Product_Group__c = 'Product 3';
            targetProduct_4.Product_Group_Code__c = '003';
            targetProduct_4.Product_List__c = 'T002;';
            targetProduct_4.Rank__c = '4';
            targetProduct_4.Sub_Group_Flag__c = false;
            targetProduct_4.Target_Point__c = 200 ;
            targetProduct_4.Target_Unit__c = 20000;
            targetProduct_4.Unit__c = 'Unit';
            targetProduct_4.Weight_Pct__c = 10;
            targetProduct_4.Year__c = String.valueOf(toDay.year());
            // targetProduct_4.Weight_Pct_Year__c = 10;
            // targetProduct_4.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_4);
            T_Performance_Target_Product_by_Sales__c targetProduct_5 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_5.Cap_Max_Pct__c = 130;
            targetProduct_5.Employee_ID__c = 'Test004' ;
            targetProduct_5.Unique_External_Key__c = 'Unique_External_Key_005';
            targetProduct_5.Month__c = '04';
            targetProduct_5.Product_Group__c = 'Product 3';
            targetProduct_5.Product_Group_Code__c = '003';
            targetProduct_5.Product_List__c = 'T024;';
            targetProduct_5.Rank__c = '5';
            targetProduct_5.Sub_Group_Flag__c = false;
            targetProduct_5.Target_Point__c = 200 ;
            targetProduct_5.Target_Unit__c = 20000;
            targetProduct_5.Unit__c = 'Unit';
            targetProduct_5.Weight_Pct__c = 10;
            targetProduct_5.Year__c = String.valueOf(toDay.year());
            // targetProduct_5.Weight_Pct_Year__c = 10;
            // targetProduct_5.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_5);
            T_Performance_Target_Product_by_Sales__c targetProduct_6 = new T_Performance_Target_Product_by_Sales__c();
            targetProduct_6.Cap_Max_Pct__c = 130;
            targetProduct_6.Employee_ID__c = 'Test004' ;
            targetProduct_6.Unique_External_Key__c = 'Unique_External_Key_006';
            targetProduct_6.Month__c = currentMonth;
            targetProduct_6.Product_Group__c = 'Product 3';
            targetProduct_6.Product_Group_Code__c = '003';
            targetProduct_6.Product_List__c = 'T024;';
            targetProduct_6.Rank__c = '6';
            targetProduct_6.Sub_Group_Flag__c = false;
            targetProduct_6.Target_Point__c = 200 ;
            targetProduct_6.Target_Unit__c = 20000;
            targetProduct_6.Unit__c = 'Unit';
            targetProduct_6.Weight_Pct__c = 10;
            targetProduct_6.Year__c = String.valueOf(toDay.year());
            // targetProduct_6.Weight_Pct_Year__c = 10;
            // targetProduct_6.Cap_Max_Pct_Year__c  = 10;
            targetProductList.add(targetProduct_6);
        
        insert targetProductList;
        // List<T_Performance_Target_Product_by_Sales__c> targetProductListQuery =[SELECT id, Cap_Max_Pct__c, Channel__c, Employee_ID__c, Month__c, Product_Group__c, Product_Group_Code__c,	Product_List__c, Rank__c, Sub_Group_Flag__c, Name, 	Target_Point__c, Target_Unit__c, Unique_External_Key__c, Unit__c, Weight_Pct__c, Year__c  FROM T_Performance_Target_Product_by_Sales__c];
        // System.debug('targetProductListQuery: '+JSON.serializePretty(targetProductListQuery));

        // T_Performance_P1Controller.getTargetProductTable('Test004', '2021', '');
        // T_Performance_P1Controller.getTargetProductTable('Test004', '2021', '01');
        T_Performance_P1Controller.getTargetProductTable('Test004', currentYear, '');
        T_Performance_P1Controller.getTargetProductTable('Test004', currentYear, '01');
        T_Performance_P1Controller.getTargetProductTable('Test004', currentYear, '12');
    }
    // public class ObjectMock{
    //     @AuraEnabled
    //     public Integer chunkSize = 35000;
    //     @AuraEnabled
    //     public Id lastRecordId;
    //     @AuraEnabled
    //     public Boolean isEndRecord;
    //     @AuraEnabled
    //     public String fieldList;
    //     @AuraEnabled
    //     public String queryObject;
    //     @AuraEnabled
    //     public String condition;
    //     @AuraEnabled
    //     public List<sObject> resultRecords;
    // }

    @isTest static void testChunkQuery(){
        Date toDay = Date.Today();
            Date kpiDay = date.valueOf(currentYear+'-01-01');
            Date deDay = date.valueOf(currentYear+'-01-08');
            User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                        UserName='testnotsame@tmbbank.com',
                                        Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                        LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                        CommunityNickname='whereareyouTMBTesttmb',
                                        ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                        Employee_ID__c ='Test004',
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
            Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์', String.valueOf(toDay.month()).leftPad(2,'0'), previousYear, String.valueOf(toDay.month()).leftPad(2,'0')+previousYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
            /* System.debug('Debug of si: '+si); */
        
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
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        // st.Indicator_Code__c = '3056' ;
        st.Indicator_Code__c = '00'+String.valueOf(i+1) ;
        // st.Indicator_Code__c = '00'+String.valueOf(i+1) ;
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

        // ObjectMock Object1 = new ObjectMock();
        T_Performance_P1Controller.chunkQueryWrapper Object1 = new  T_Performance_P1Controller.chunkQueryWrapper();
        Object1.chunkSize = 35000;
        Object1.fieldList = 'Id, Actual_Point__c';
        Object1.queryObject = 'Sale_Transaction__c';
        Object1.condition = ' WHERE Sale_Type__c = \'PWA\' AND Channel__c = \'Wealth Banking\'  AND Year__c = \''+currentYear+'\' AND Month__c > \'07\' AND Month__c <= \'09\'';
        Object1.isEndRecord = false;
        Object1.lastRecordId = null;
        Object1.resultRecords = null;
        
        T_Performance_P1Controller.chunkQueryWrapper chunkQuery2 = new  T_Performance_P1Controller.chunkQueryWrapper();
        chunkQuery2.chunkSize = 1;
        chunkQuery2.fieldList = 'Id,Actual_Point__c';
        chunkQuery2.queryObject = 'Sale_Transaction__c';
        chunkQuery2.condition = null;
        chunkQuery2.isEndRecord = false;
        chunkQuery2.lastRecordId = null;
        chunkQuery2.resultRecords = null;

        T_Performance_P1Controller.chunkQueryWrapper chunkQueryLastRecordId = new  T_Performance_P1Controller.chunkQueryWrapper();
        chunkQueryLastRecordId.chunkSize = 1;
        chunkQueryLastRecordId.fieldList = 'Id,Actual_Point__c';
        chunkQueryLastRecordId.queryObject = 'Sale_Transaction__c';
        chunkQueryLastRecordId.condition = null;
        chunkQueryLastRecordId.isEndRecord = false;
        chunkQueryLastRecordId.lastRecordId = stList[0].id;
        chunkQueryLastRecordId.resultRecords = null;
        
        T_Performance_P1Controller.chunkQuery(Object1);
        T_Performance_P1Controller.chunkQuery(chunkQuery2);
        T_Performance_P1Controller.chunkQuery(chunkQueryLastRecordId);

    }

    @isTest static void testGetPerformanceDataSaleNotResigned(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-01-01');
        Date deDay = date.valueOf(currentYear+'-01-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',
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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),currentYear,String.valueOf(toDay.month()).leftPad(2,'0')+currentYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
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
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;

        // "RTL_License_No_Life_Insurance__c" : "6203008582",
        T_Performance_P1Controller.getPerformanceDataP1('Test004', 'month', currentYear, toDay.month());
    }

    @isTest static void testGetPerformanceDataSaleNotResigned2(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-01-01');
        Date deDay = date.valueOf(currentYear+'-01-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',
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
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',String.valueOf(toDay.month()).leftPad(2,'0'),currentYear,String.valueOf(toDay.month()).leftPad(2,'0')+currentYear+String.valueOf(toDay.month()).leftPad(2,'0')+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = String.valueOf(toDay.month()-2).leftPad(2,'0');
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = String.valueOf(toDay.month()-1).leftPad(2,'0');
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
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
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;

        // "RTL_License_No_Life_Insurance__c" : "6203008582",
        T_Performance_P1Controller.getPerformanceDataP1('Test004', 'month', currentYear, toDay.month()-1);
    }

    @isTest static void testGetPerformanceData_SalePerfDelay(){
        Date toDay = Date.Today();
        Date kpiDay = date.valueOf(currentYear+'-01-01');
        Date deDay = date.valueOf(currentYear+'-01-08');
        User newUser = new User(FirstName = 'testzxc' , LastName = 'okty', 
                                    UserName='testnotsame@tmbbank.com',
                                    Email='testnotsamesure@gmail.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='whereareyouTMBTesttmb',
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='Test004',
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

        // SELECT Id, Indicator_Code__c, License_Type__c FROM T_Performance_Indicator_License__c WHERE License_Type__c INCLUDES('+filterLicense+')
        T_Performance_Indicator_License__c indicatorLicenses = new T_Performance_Indicator_License__c();
        indicatorLicenses.License_Type__c = 'IC;UL;LB;NLB';
        indicatorLicenses.Indicator_Code__c= '3056';
        insert indicatorLicenses;

        // Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์','07',previousYear,'07'+previousYear+'07'+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์',currentMonth,currentYear,currentMonth+currentYear+currentMonth+'Test004', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', 'Test004', true);
        /* System.debug('Debug of si: '+si); */
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = currentYear;
        sp.Month__c = '05';
        sp.Employee_ID__c = 'Test004';
        /* sp.Sale_Info__c =  si.id; */
        sp.Sale_Type__c = 'Sale Out';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '001';
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
        sp.People_Point__c = 10;
        sp.Operation_Point__c = 10;
        sp.Customer_Point__c = 1000;
        sp.Financial_Actual_Point__c = 8000;
        sp.Financial_Target_Point__c = 50000;
        sp.Unique_External_Key__c = 'testmonthperiod';
        insert sp; 
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<2 ;i++){
        Sale_Transaction__c st = new Sale_Transaction__c();
        st.Year__c = currentYear;
        st.Month__c = currentMonth;
        st.Sale_Team__c = '0001';
        st.Zone__c = 'RH6';
        st.Region__c = '9220';
        st.Channel__c = 'branch';
        st.Book_Service_Branch__c = '148' + i;
        st.Employee_ID__c = 'Test004' ;
        st.Sale_Name__c = 'จักรกล พิมพ์งาม' ;
        st.Position__c = 'S_HL';
        st.Indicator_Name__c = 'Home Equity with MRTA';
        st.Indicator_Level1__c = 'Deposit & Investment';
        st.Indicator_Level2__c = 'Deposit';
        st.Indicator_Code_Level1__c = '001';
        st.Indicator_Code_Level2__c = '120';
        st.Indicator_Code__c = '3056' ;
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
        stList.add(st);
        }
        insert stList;
        AppConfig__c ac = new AppConfig__c();
        ac.Name = 'Percent Success Criteria';
        ac.Value__c =  null;
        insert ac;

        // "RTL_License_No_Life_Insurance__c" : "6203008582",
        T_Performance_P1Controller.getPerformanceDataP1('Test004', 'month', previousYear, 8);
    }
}