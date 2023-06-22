@isTest
public with sharing class TestForP4Utils {
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
    public static final String SUCCESS_CODE = '0000';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String FOUND_DUP_ALLOW_CREATE = '1010';
    public static final String FOUND_DUP_NOT_ALLOW_CREATE = '1011';
    public static final String WEBSERVICE_ERROR_CODE = '1003';
    public static final String DML_EXCEPTION_CODE = '1000';

    public static List<User> createUsers(Integer size , String FName , String LName , String Email , Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            User newUser = new User(FirstName = FName+i , LastName = LName+i, 
                                    UserName=FName+i+LName+i+'@tmbbank.com',
                                    Email=Email, Alias='Testtmb'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=FName+i+'_'+LName+i+'_'+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM01'+i
                                    );

            userToCreate.add(newUser);
        }
        if(doInsert){
            insert userToCreate;
        }
        return userToCreate;
    }

    public static Team_Profile_and_KPI__c createTPK(String tperformanceTeam,String month,String year,String teamName, String branchCode, String branchTier, String branchType, Double branchTran, Double branchATM, Double branchDigital, Boolean doInsert){
        Team_Profile_and_KPI__c newTeam = new Team_Profile_and_KPI__c();
        newTeam.T_Performance_Team__c = tperformanceTeam;
        newTeam.Month__c = month;
        newTeam.Year__c = year;
        newTeam.Team_Name_TH__c = teamName;
        newTeam.Branch_Tier__c = branchTier;
        newTeam.Branch_Type__c = branchType;
        newTeam.Branch_Team_Code__c = branchCode;
        newTeam.Working_Day__c = '5';
        newTeam.Office_Hour__c = 'จ-ศ : 08.30 - 16.00 น.';
        newTeam.Phone__c = '';
        newTeam.Branch_Transaction__c = branchTran;
        newTeam.ATM_Transaction__c = branchATM;
        newTeam.Digital_Transaction__c = branchDigital;
        newTeam.Zone_Code__c = '8061';
        newTeam.Channel__c = 'SBO';
        newTeam.Zone__c = 'Phahonyothin';
        newTeam.Region__c = 'RH2';
        newTeam.Region_Code__c = 'RH2';
        newTeam.Unique_External_Key__c = '2022010535Wealth';
        newTeam.Total_Transaction__c = branchTran + branchATM + branchDigital;
        
        if(doInsert){
            insert newTeam;
        }
        return newTeam;
    }

    public static T_Performance_Team_List__c createPTL(String branchTeamCode, String branchTeamName, Boolean doInsert){
        T_Performance_Team_List__c t = new T_Performance_Team_List__c();
        t.Branch_Team_Code__c = branchTeamCode;
        t.Branch_Team_Name__c = branchTeamName;
        t.Branch_Team_Manager__c = null;
        t.Channel__c = 'Branch';
        t.Region_Code__c = '0700';
        t.Zone_Code__c = '1860';
        if(doInsert){
            insert t;
        }
        return t;
    }

    public static List<Branch_Performance_by_Pillar__c> createBPP(Integer size, String year, String month, String branchTeamCode, String indicatorParentName, String indicatorName, String indicatorRank, Double kpiValue, String channel, T_Performance_Team_List__c t, Boolean doInsert ){
        List<Branch_Performance_by_Pillar__c> bcList = new List<Branch_Performance_by_Pillar__c>();
        for(Integer i=0 ;i<size ;i++){
            Branch_Performance_by_Pillar__c b = new Branch_Performance_by_Pillar__c();
            b.Year__c = year;
            b.Month__c = month;
            b.Branch_Team_Code__c = branchTeamCode;
            b.Indicator_Parent_Name__c = indicatorParentName;
            b.Indicator_Name__c = indicatorName + i;
            b.Indicator_Rank__c = indicatorRank;
            b.KPI_Value__c = kpiValue;
            b.Channel__c = channel;
            b.T_Performance_Team__c = t.Id;
            b.Unique_External_Key__c = '202204001Net Branch' + i;
            bcList.add(b);
        }
        
        if(doInsert){
            insert bcList;
        }
        return bcList;
    }

    public static Sale_Info__c createSaleInfo(String name,String month,String year,String ExternalKey, String salesType, String workType, String teamName, String employeeId, Boolean doInsert){
        Sale_Info__c s = new Sale_Info__c();
        s.Name = name;
        s.Month__c = month ;
        s.Year__c = Year;
        s.External_Key__c = Year+month+employeeId;
        s.Sale_Type__c = salesType;
        s.Work_Type__c = workType;
        s.Team_Name__c = teamName;
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = employeeId;
        s.BM_Expected__c = 'CYC';
        s.CYC_Grade__c = 'A+';
        s.HL_Grade__c = 'B';
        s.SME_Grade__c = 'B+';
        s.Fund_Grade__c = 'C';
        if(doInsert){
            insert s;
        }
        return s;
    }

    public static Sale_Performance__c createSalesPerform(String year, String month, String employeeId, Boolean doInsert){
        Sale_Performance__c sp = new Sale_Performance__c();
        sp.Year__c = year;
        sp.Month__c = month;
        sp.Employee_ID__c = employeeId;
        /* sp.Sale_Info__c =  saleInfo; */
        sp.Sale_Type__c = 'Sale In';
        sp.Position__c = 'CSO';
        sp.Work_Type__c = 'Sale';
        sp.Branch_Team_Code__c = '0001';
        sp.Zone__c = 'CHATUCHAK';
        sp.Region__c = 'RH2';
        sp.Channel__c = 'Branch';
        sp.Team_Name__c = 'สำนักพหลโยธิน';
        sp.Number_of_Customer__c = 56;
        sp.Actual_Point__c = 8000;
        sp.Target_Point__c = 6000;
        sp.Target_Other_Point__c = 2000;
        sp.Unique_External_Key__c = 'sdfjlkdsj';
        if(doInsert){
            insert sp;
        }
        return sp;
    }

    public static List<Sale_Transaction__c> createSalesTransaction(Integer size, String year, String month, Boolean doInsert){
        List<Sale_Transaction__c> stList = new List<Sale_Transaction__c>();
        for(Integer i=0; i<size ;i++){
            Sale_Transaction__c st = new Sale_Transaction__c();
            st.Year__c = year;
            st.Month__c = month;
            st.Sale_Team__c = '0001';
            st.Zone__c = 'RH6';
            st.Region__c = '9220';
            st.Channel__c = 'Branch';
            st.Book_Service_Branch__c = '148' + i;
            st.Employee_ID__c = '17981' + i;
            st.Sale_Name__c = 'จักรพันธ์ พิมพ์งาม' + i;
            st.Position__c = 'S_HL';
            st.Indicator_Name__c = 'Home Equity with MRTA';
            st.Sale_Unit__c = 'บาท';
            st.Actual_Point__c = 400 + i;
            st.Unique_External_Key__c = 'sdljflsd' + i;
            st.Indicator_Code__c = '305' ;
           /*  st.Sale_Info__c = saleInfo ; */
            st.Customer_Number__c = '001100000000000000000012024928';
            stList.add(st);
        }
        if(doInsert){
            insert stList;
        }
        return stList;

    }
}