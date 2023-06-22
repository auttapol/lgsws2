@isTest
public with sharing class T_Performance_P4Controller_Test {

    @TestSetup
    static void makeData(){
        List<User> userList = TestForP4Utils.createUsers(2, 'Takeshi', 'Nobita', 'takeshiza007@gmail.com', true);
        T_Performance_Team_List__c tl = TestForP4Utils.createPTL('015', 'สาขาคลองเตย', true);
        Team_Profile_and_KPI__c tk = TestForP4Utils.createTPK(tl.Id, '04', '2022', 'สำนักพหลโยธิน', '0001', 'XL', 'HQ', Double.valueOf(1000), Double.valueOf(1000), Double.valueOf(1000), true);
        List<Branch_Performance_by_Pillar__c> bp =  TestForP4Utils.createBPP(2, '2022', '04', '0001', 'Customer', 'Customer', '1', Double.valueOf(90), 'Branch', tl, true);
        Sale_Info__c si = TestForP4Utils.createSaleInfo('จุฬามาส เจียกจันทร์','05','2022','0520228287', 'Sale Out', 'Sale', 'สำนักพหลโยธิน', '82827', true);
        Sale_Performance__c sp = TestForP4Utils.createSalesPerform('2022', '05', '82827',  true);
        List<Sale_Transaction__c> stList = TestForP4Utils.createSalesTransaction(2, '2022', '05', true);
    }

    @isTest static void testGetBranchInfo(){
        List<Branch_Performance_by_Pillar__c> bb = [SELECT Id, Name, Year__c, Month__c, Branch_Team_Code__c, Indicator_Parent_Name__c, Indicator_Name__c, Indicator_Rank__c, KPI_Value__c, Channel__c 
        FROM Branch_Performance_by_Pillar__c ];
        List<User> loginUser = [Select Id, Name, Employee_ID__c From User];
        System.debug(bb);
        T_Performance_P4Controller.getPerformanceData('0001');
        T_Performance_P4Controller.getWatermarkHTML();
    }


    @isTest static void testGetSumActual(){
        List<AggregateResult> sumVolume = [SELECT Indicator_Name__c, SUM(Actual_Point__c) sumOf, Sale_Unit__c FROM Sale_Transaction__c WHERE Sale_Team__c='0001' AND Year__c='2022' AND Month__c='05' GROUP BY Indicator_Name__c, Sale_Unit__c];
        System.debug(sumVolume.get(0));
        T_Performance_P4Controller.getSumActual('0001');
    }

    
    @isTest static void testGetSaleInOut(){
        Date toDay = Date.Today();
        String year = Datetime.now().format('yyyy');
        string month = String.valueOf(toDay.month()).leftPad(2,'0');
        Sale_Info__c s = new Sale_Info__c();
        s.Month__c = month;
        s.Year__c = year;
        s.External_Key__c = s.Year__c+s.Month__c+s.Employee_ID__c;
        s.Name = 'ทดสอบ ขายใน';
        s.Sale_Type__c = 'Sale In';
        s.Work_Type__c = 'Sale';
        s.Team_Name__c = 'สำนักพหลโยธิน';
        s.Zone__c = 'CHATUCHAK';
        s.Region__c = 'RH2';
        s.Channel__c = 'Branch';
        s.Employee_ID__c = '85432';
        s.BM_Expected__c = 'CYC';
        s.CYC_Grade__c = 'A+';
        s.HL_Grade__c = 'B';
        s.SME_Grade__c = 'B+';
        s.Fund_Grade__c = 'C';
        insert s;
        T_Performance_P4Controller.getSaleInOut(year,month);
    }
    
    @isTest static void testGetHelpAndSummary(){
        List<T_Performance_Sharepoint__mdt> sharePoint = [SELECT Id, SharePoint_Type__c, URL_Link__c FROM T_Performance_Sharepoint__mdt ];
        T_Performance_P4Controller.getHelpAndSummary();
    }
    

}