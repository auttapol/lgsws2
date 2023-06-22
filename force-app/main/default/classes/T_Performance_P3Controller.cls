public with sharing class T_Performance_P3Controller {

    public static Integer LIMIT_DATA {
        get {
            if (LIMIT_DATA == null) {
                LIMIT_DATA = AppConfig__c.getValues('t-performance-limit') == null ? 50 : Integer.valueof(AppConfig__c.getValues('t-performance-limit').Value__c);
            }
            return LIMIT_DATA;
        }
        set;
    }

    @AuraEnabled
    public static String getLastedPerfomanceYear(List<String> years, String channel, String branchCode) {
        try {

            List<Sale_Performance__c> salePerf = [
                SELECT Year__c
                FROM Sale_Performance__c
                WHERE Year__c IN : years
                AND Sale_Branch_Code__c =: branchCode
                AND Channel__c =: channel
                // GROUP BY Year__c
                ORDER BY Year__c DESC
                LIMIT 1
            ];

            if(salePerf.size() > 0) {
                return String.valueOf(salePerf.get(0).get('Year__c'));
            } else {
                if(years.size() > 0) {
                    return years.get(0); // current year
                } else {
                    return Datetime.now().format('yyyy');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class BranchInfoWrapper {
        @AuraEnabled
        public String managerName;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String branchName;
        @AuraEnabled
        public String branchType;
        @AuraEnabled
        public String branchTier;
        @AuraEnabled
        public String workingDays;
        @AuraEnabled
        public String officeHours;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public Decimal totalCustomers;
        @AuraEnabled
        public Decimal totalActiveCustomers;
        @AuraEnabled
        public Decimal totalMainBankCustomers;
        @AuraEnabled
        public Decimal netPromoterScore;
        @AuraEnabled
        public Decimal branchTransactions;
        @AuraEnabled
        public Decimal atmTransactions;
        @AuraEnabled
        public Decimal digitalTransactions;
        @AuraEnabled
        public Decimal totalTransactions;
        @AuraEnabled
        public Integer limitData;
    }

    @AuraEnabled
    public static List<Team_Profile_and_KPI__c> getBranchSectionA(String year, String branchCode){
        try {
            List<Team_Profile_and_KPI__c> teamProfile = [
                SELECT                 
                T_Performance_Team__r.Branch_Team_Manager__c, Team_Name_TH__c, Branch_Tier__c, Branch_Type__c,
                Working_Day__c, Office_Hour__c, Address__c, Phone__c,
                Branch_Transaction__c, ATM_Transaction__c, Digital_Transaction__c, Total_Transaction__c,
                Total_Customer__c, Total_Active_Customer__c, Total_Mainbank_Customer__c, Net_Promoter_Score__c,
                Month__c
                FROM Team_Profile_and_KPI__c WHERE Branch_Team_Code__c =: branchCode AND Year__c=: year
                ORDER BY Month__c DESC
            ];
       
            return teamProfile;
       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static BranchInfoWrapper getBranchInfo(String branchCode, String channel, String region, String zone) {
        try {
            List<Team_Profile_and_KPI__c> teamProfile = [
                SELECT 
                T_Performance_Team__r.Branch_Team_Manager__c, Team_Name_TH__c, Branch_Tier__c, Branch_Type__c,
                Working_Day__c, Office_Hour__c, Address__c, Phone__c,
                Branch_Transaction__c, ATM_Transaction__c, Digital_Transaction__c, Total_Transaction__c,
                Total_Customer__c, Total_Active_Customer__c, Total_Mainbank_Customer__c, Net_Promoter_Score__c
                FROM Team_Profile_and_KPI__c WHERE Branch_Team_Code__c =: branchCode
                AND Channel__c =: channel
                LIMIT 1
            ];

            BranchInfoWrapper branchInfo = new BranchInfoWrapper();

            if (teamProfile.size() > 0) {
                branchInfo.managerName = getNullableString(teamProfile[0].T_Performance_Team__r.Branch_Team_Manager__c);
                branchInfo.address = getNullableString(teamProfile[0].Address__c);
                branchInfo.branchName = getNullableString(teamProfile[0].Team_Name_TH__c);
                branchInfo.branchType = getNullableString(teamProfile[0].Branch_Type__c);
                branchInfo.branchTier = getNullableString(teamProfile[0].Branch_Tier__c);
                branchInfo.workingDays = getNullableString(teamProfile[0].Working_Day__c);
                branchInfo.officeHours = getNullableString(teamProfile[0].Office_Hour__c);
                branchInfo.phoneNumber = getNullableString(teamProfile[0].Phone__c);
                branchInfo.totalCustomers = getNullableNumber(teamProfile[0].Total_Customer__c);
                branchInfo.totalActiveCustomers = getNullableNumber(teamProfile[0].Total_Active_Customer__c);
                branchInfo.totalMainBankCustomers = getNullableNumber(teamProfile[0].Total_Mainbank_Customer__c);
                branchInfo.netPromoterScore = getNullableNumber(teamProfile[0].Net_Promoter_Score__c);
                branchInfo.branchTransactions = getNullableNumber(teamProfile[0].Branch_Transaction__c);
                branchInfo.atmTransactions = getNullableNumber(teamProfile[0].ATM_Transaction__c);
                branchInfo.digitalTransactions = getNullableNumber(teamProfile[0].Digital_Transaction__c);
                branchInfo.totalTransactions = getNullableNumber(teamProfile[0].Total_Transaction__c);
                branchInfo.limitData = LIMIT_DATA;
            } else {
                branchInfo.managerName = '-';
                branchInfo.address = '-';
                branchInfo.branchName = '-';
                branchInfo.branchType = '-';
                branchInfo.branchTier = '-';
                branchInfo.workingDays = '-';
                branchInfo.officeHours = '-';
                branchInfo.phoneNumber = '-';
                branchInfo.totalCustomers = 0;
                branchInfo.totalActiveCustomers = 0;
                branchInfo.totalMainBankCustomers = 0;
                branchInfo.netPromoterScore = 0;
                branchInfo.branchTransactions = 0;
                branchInfo.atmTransactions = 0;
                branchInfo.digitalTransactions = 0;
                branchInfo.totalTransactions = 0;
                branchInfo.limitData = LIMIT_DATA;
            }


            return branchInfo;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getNullableString(Object obj) {
        if (obj == null) return '-';

        String text = String.valueof(obj);
        if (text.trim() == '' || text == null) {
            return '-';
        }
        return text;
    }

    public static Decimal getNullableNumber(Object obj) {
        if (obj == null) return 0.00;

        Decimal x = Double.valueof(obj);
        if (x == 0 || x == null) {
            return 0.00;
        }
        return x;
    }

    public class PrepareDataSectionDWrapper {
        @AuraEnabled
        public Sale_Info__c saleInfo;
        @AuraEnabled
        public List<AggregateResult> salePerf;
        @AuraEnabled
        public List<AggregateResult> saleTrans;
        @AuraEnabled
        public Decimal saleTransTarget;
        @AuraEnabled
        public String salePerfLastMonth;
    }

    public class yearMonthWrapper {
        public String year;
        public String month;
    }

    @AuraEnabled
    public static List<PrepareDataSectionDWrapper> prepareDataForSectionD(String year, String branchCode, String channel) {
        try {
            Map<String,PrepareDataSectionDWrapper> sectionDMap = new  Map<String,PrepareDataSectionDWrapper> ();
            Integer currentMonth = Date.today().month();
            String currentMonthStr = currentMonth < 10 ? String.valueOf(currentMonth).leftPad(2, '0') : String.valueOf(currentMonth);
            // Set<String> salePer_monthList = new Set<String>();
            // List<yearMonthWrapper> salePer_monthList = new List<yearMonthWrapper>();
            List<String> salePer_monthList_currYear = new List<String>();
            List<String> salePer_monthList_prevYear = new List<String>();
            Map<String,String> salePer_monthListMap = new Map<String,String>();
            // Set<String> saleTrans_monthList = new Set<String>();
            // List<String> monthList = new List<String>();
            Integer salePer_dataLastMonth = 0;
            Map<String,String> salePer_dataLastMonthMap = new  Map<String,String>();
            Decimal saleTranTarget = 0;
            Map<String,Decimal> saleTranTargetMap = new  Map<String,Decimal>();


            String currentYear = Datetime.now().format('yyyy');
            String prevYear = Datetime.now().addYears(-1).format('yyyy');
            List<String> currYearMonthList = new List<String>();
            List<String> prevYearMonthList = new List<String>();

            Set<String> saleTrans_monthList_currYear = new Set<String>();
            Set<String> saleTrans_monthList_prevYear = new Set<String>();            
            if(year == currentYear) {
                if(currentMonth == 1) {
                    currYearMonthList.add('01');
                    // prevYearMonthList.add(12);
                } else {
                    for(Integer i = 1; i <= currentMonth; i++)
                    { 
                        currYearMonthList.add(String.valueOf(i).leftPad(2, '0'));
                    }
                }
            } else {
                if(currentMonth == 1) {
                    // currYearMonthList.add(1);
                    // prevYearMonthList.add(12);
                    for(Integer i = 1; i <= 12; i++)
                    { 
                        prevYearMonthList.add(String.valueOf(i).leftPad(2, '0'));
                    }
                } else {
                    for(Integer i = 1; i <= currentMonth; i++)
                    { 
                        prevYearMonthList.add(String.valueOf(i).leftPad(2, '0'));
                    }
                }
            }
            

            // for(Integer i = 0; i <= currentMonth; i++)
            // { 
            //     String month = i < 10 ? String.valueOf(i).leftPad(2, '0') : String.valueOf(i);
            //     monthList.add(month);
            // }
            List<Sale_Performance__c> salePerfLastMonth = [SELECT Year__c, Month__c FROM Sale_Performance__c WHERE Year__c =: year ORDER By Month__c DESC LIMIT 1];

            List<AggregateResult> salePerf = [SELECT Employee_Id__c, Year__c, Month__c,Sale_Branch_Code__c , SUM(Financial_Actual_Point__c) Financial_Actual_Point__c, SUM(Target_Point__c) Target_Point__c
                                            FROM Sale_Performance__c 
                                            WHERE Sale_Branch_Code__c =: branchCode AND Year__c =: year
                                            GROUP BY Employee_Id__c, Year__c, Month__c,Sale_Branch_Code__c];

            for(AggregateResult sale : salePerf)
            {
                Boolean isHasData = false;
                if(sale.get('Year__c') == currentYear && currYearMonthList.contains((String)sale.get('Month__c')) ) {
                    // salePer_monthList.add(new yearMonthWrapper(year = sale.get('Year__c'), month = sale.get('Month__c')));
                    isHasData = true;
                    saleTrans_monthList_currYear.add((String)sale.get('Month__c'));
                    salePer_monthList_currYear.add((String)sale.get('Month__c'));
                }
                if(sale.get('Year__c') == prevYear && prevYearMonthList.contains((String)sale.get('Month__c')))
                // if(monthList.contains((String)sale.get('Month__c')))
                {       
                    isHasData = true;
                    saleTrans_monthList_prevYear.add((String)sale.get('Month__c'));
                    salePer_monthList_prevYear.add((String)sale.get('Month__c'));
                    // String month = (String)sale.get('Month__c');
                    // String empId = (String)sale.get('Employee_Id__c');
                    // salePer_monthList.add(new yearMonthWrapper(year = sale.get('Year__c'), month = sale.get('Month__c')));
                    // // salePer_monthList.add(month);
                    // if(salePer_dataLastMonthMap.containsKey(empId))
                    // {  
                    //     String lastMonth = salePer_dataLastMonthMap.get(empId);
                    //     if((sale.get('Year__c')+sale.get('Month__c')) > lastMonth)
                    //     {
                    //         // salePer_dataLastMonth = Integer.ValueOf(sale.get('Month__c'));
                    //         salePer_dataLastMonthMap.put(empId,sale.get('Year__c')+sale.get('Month__c'));               
                    //     }
                    // }
                    // else 
                    // {
                    //     salePer_dataLastMonthMap.put(empId, sale.get('Year__c')+sale.get('Month__c'));
                    // }
                }

                if(isHasData) {
                    String month = (String)sale.get('Month__c');
                    String empId = (String)sale.get('Employee_Id__c');
                    
                    // salePer_monthList.add(month);
                    if(salePer_dataLastMonthMap.containsKey(empId))
                    {  
                        String lastMonth = salePer_dataLastMonthMap.get(empId);
                        if(((String)sale.get('Year__c')+(String)sale.get('Month__c')) > lastMonth)
                        {
                            // salePer_dataLastMonth = Integer.ValueOf(sale.get('Month__c'));
                            salePer_dataLastMonthMap.put(empId,(String)sale.get('Year__c')+(String)sale.get('Month__c'));               
                        }
                    }
                    else 
                    {
                        salePer_dataLastMonthMap.put(empId, (String)sale.get('Year__c')+(String)sale.get('Month__c'));
                    }
                }
            }
            //Get Target Last Month Form Sale Performance
            for(AggregateResult sale : salePerf)
            {
                if(salePer_dataLastMonthMap.containsKey((String)sale.get('Employee_Id__c')))
                {    
                    if(((String)sale.get('Year__c')+sale.get('Month__c')) == salePer_dataLastMonthMap.get((String)sale.get('Employee_Id__c')))
                    {
                        saleTranTargetMap.put(String.ValueOf(sale.get('Employee_Id__c')),Double.ValueOf(sale.get('Target_Point__c')));
                    }
                }
            }
            if(salePer_monthList_prevYear.size() > 0)
            {
                for(String month : prevYearMonthList)
                {
                    if(!salePer_monthList_prevYear.contains(month))
                    {       
                        saleTrans_monthList_prevYear.add(month);
                    }
                }
            }
            else
            {
                saleTrans_monthList_prevYear.addAll(prevYearMonthList); 
            }

            if(salePer_monthList_currYear.size() > 0)
            {
                for(String month : currYearMonthList)
                {
                    if(!salePer_monthList_currYear.contains(month))
                    {       
                        saleTrans_monthList_currYear.add(month);
                    }
                }
            }
            else
            {
                saleTrans_monthList_currYear.addAll(currYearMonthList); 
            }

            List<AggregateResult> saleTrans = new List<AggregateResult>();
            if(saleTrans_monthList_currYear.size() > 0 || saleTrans_monthList_prevYear.size() > 0)
            {
                saleTrans = [SELECT Employee_Id__c, Year__c, Month__c,Sale_Team__c , SUM(Actual_Point__c) Actual_Point__c
                            FROM Sale_Transaction__c 
                            WHERE Sale_Team__c =: branchCode AND ((Year__c =: currentYear AND Month__c =: saleTrans_monthList_currYear) OR (Year__c =: prevYear AND Month__c =: saleTrans_monthList_prevYear))
                            GROUP BY Employee_Id__c, Year__c, Month__c,Sale_Team__c];
            }
            List<AggregateResult> lastSaleInfoList = [SELECT Max(Month__c) last_month, Employee_ID__c FROM Sale_Info__c WHERE Branch_Code__c =: branchCode AND Channel__c =: channel AND Year__c =: year GROUP by Employee_ID__c ];
            Set<String> setLastSaleInfoExtId = new Set<String>();
            for(AggregateResult sale : lastSaleInfoList) {
                setLastSaleInfoExtId.add(year+sale.get('last_month')+sale.get('Employee_ID__c'));
            }

            List<Sale_Info__c> saleInfo = [SELECT Id, Name, Team_Name__c, Zone__c, Region__c, Sale_Type__c, Channel__c, Employee_ID__c, Branch_Code__c, Branch_Name__c , Position__c ,Sale_Hire_Date__c, Year__c, Month__c
            FROM Sale_Info__c WHERE External_Key__c IN: setLastSaleInfoExtId];

            Map<String,List<AggregateResult>> salePerMap = new Map<String,List<AggregateResult>>(); 
            Map<String,List<AggregateResult>> saleTransMap = new Map<String,List<AggregateResult>>(); 

            for(AggregateResult saleP : salePerf)
            {
                String empId = String.valueOf(saleP.get('Employee_ID__c'));
                if(salePerMap.containsKey(empId))
                {
                    salePerMap.get(empId).add(saleP);
                }           
                else {
                    salePerMap.put(empId,new List<AggregateResult>());
                    salePerMap.get(empId).add(saleP);
                }    
            }

            for(AggregateResult saleT : saleTrans)
            {
                String empId = String.valueOf(saleT.get('Employee_ID__c'));
                if(saleTransMap.containsKey(empId))
                {
                    saleTransMap.get(empId).add(saleT);
                }           
                else {
                    saleTransMap.put(empId,new List<AggregateResult>());
                    saleTransMap.get(empId).add(saleT);
                }    
            }

            for(Sale_Info__c sale : saleInfo)
            {
                PrepareDataSectionDWrapper dataSectionD = new PrepareDataSectionDWrapper();
                if(salePerfLastMonth.size() > 0)
                {
                    dataSectionD.salePerfLastMonth = salePerfLastMonth[0].Month__c;
                }

                if(salePerMap.containsKey(sale.Employee_ID__c))
                {
                    dataSectionD.salePerf = salePerMap.get(sale.Employee_ID__c);
                }
                if(saleTransMap.containsKey(sale.Employee_ID__c))
                {
                    dataSectionD.saleTrans = saleTransMap.get(sale.Employee_ID__c);
                }
                if(saleTranTargetMap.containsKey(sale.Employee_Id__c))
                {
                    dataSectionD.saleTransTarget = saleTranTargetMap.get(sale.Employee_Id__c);
                }
                dataSectionD.saleInfo = sale;
                sectionDMap.put(sale.Employee_ID__c,dataSectionD);
            }

            return sectionDMap.values();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        try{
            string userId = UserInfo.getUserId();
            User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
            string userEmpId = loginUser.Employee_ID__c;
            return userEmpId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class sumTransBankWideWrapperSectionC {
        @AuraEnabled
        public Sale_Transaction__c sumTrans;
        @AuraEnabled
        public String sumBranchTransQueryCond;
        @AuraEnabled
        public Id lastRecordId;
        @AuraEnabled
        public Boolean isEndRecord;
        @AuraEnabled
        public Decimal sumPerfPoint;
        @AuraEnabled
        public Decimal totalTarget;
        @AuraEnabled
        public Decimal totalBankTransSum;
    }


    @AuraEnabled
    public static sumTransBankWideWrapperSectionC sumBankWideTrans(Object sumTransObj) {
        try{
            sumTransBankWideWrapperSectionC sumTransBWWrapper = (sumTransBankWideWrapperSectionC)JSON.deserialize(JSON.serialize(sumTransObj), sumTransBankWideWrapperSectionC.class);
            sumTransBankWideWrapperSectionC sumTransWrapper = sumTransBWWrapper;
            if(sumTransBWWrapper.sumBranchTransQueryCond != null) {
                String query = '';
                
                sumTransWrapper.isEndRecord = true;
                Sale_Transaction__c resSum;
                if (sumTransBWWrapper.sumTrans == null) {
                    resSum = new Sale_Transaction__c();
                } else {
                    resSum = sumTransBWWrapper.sumTrans;
                }

                resSum.Actual_Point__c = resSum.Actual_Point__c != null ? resSum.Actual_Point__c : 0;
                Integer chunkSize = 35000;
                if(sumTransBWWrapper.lastRecordId == null) {
                    // first time
                    query = 'SELECT Id, Actual_Point__c FROM Sale_Transaction__c '+sumTransBWWrapper.sumBranchTransQueryCond+' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                } else {
                    query = 'SELECT Id, Actual_Point__c FROM Sale_Transaction__c '+sumTransBWWrapper.sumBranchTransQueryCond+' AND Id > \''+sumTransBWWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                }


                List<Sale_Transaction__c> bankWideTrans = Database.query(query);
                for(Sale_Transaction__c tran : bankWideTrans) {
                    resSum.Actual_Point__c = tran.Actual_Point__c != null ? resSum.Actual_Point__c+tran.Actual_Point__c : resSum.Actual_Point__c;
                }
                
                Integer dataRow = bankWideTrans.size();
                if(dataRow >= chunkSize) {
                    sumTransWrapper.lastRecordId = bankWideTrans[dataRow-1].Id;
                    List<Sale_Transaction__c> checkNext = [SELECT Id FROM Sale_Transaction__c WHERE Id >: sumTransWrapper.lastRecordId ORDER BY Id LIMIT 1];
                    if(checkNext.size() > 0) {
                        sumTransWrapper.isEndRecord = false;
                    }
                }
                sumTransWrapper.sumTrans = resSum;

                // if end of record, sum new avg bankwide
                if(sumTransWrapper.isEndRecord) {
                    // sumTransBWWrapper.sumPerfPoint = sumTransBWWrapper.sumPerfPoint != null ? sumTransBWWrapper.sumPerfPoint : 0;
                    sumTransWrapper.totalBankTransSum = resSum.Actual_Point__c;
                }
            }
            return sumTransWrapper;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    // List<AggregateResult> salePerfBank = [
    //         SELECT SUM(Financial_Actual_Point__c) sumActualPoint,
    //         SUM(Target_Point__c) sumTargetPoint,
    //         Sale_Type__c, Month__c
    //         FROM Sale_Performance__c 
    //         WHERE Year__c =: year
    //         AND Channel__c =: channel
    //         AND Month__c IN : months
    //         GROUP BY Sale_Type__c, Month__c
    //         ORDER BY Month__c DESC
    //     ];


    public class lastAvailPerfWrapper {
        @AuraEnabled
        public Sale_Performance__c availPerfObj;
        @AuraEnabled
        public String availPerfMonth;
        @AuraEnabled
        public String availPerfYear;
        @AuraEnabled
        public String perfDateTimeCondition = '';
        @AuraEnabled
        public String transDateTimeCondition = '';
        @AuraEnabled
        public Integer targetMultipiler;
        @AuraEnabled
        public Sale_Performance__c lastReceivedPerf;
    }  

    @AuraEnabled
    public static lastAvailPerfWrapper getAvailPerfObj(String lastAvailPerfQuery, Boolean isIndividual, String selectedYear){
        try{
            if(lastAvailPerfQuery != null) {
                lastAvailPerfWrapper retWrapper = new lastAvailPerfWrapper();
                List<Sale_Performance__c> lastAvailPerf = new List<Sale_Performance__c>();
                Integer targetMultipiler;
                Datetime nowTime = Datetime.now();
                Date toDay = Date.today();
                // nowTime = Datetime.newInstance(2022, 1, 15); // ********* for testing only
                // toDay = Date.newInstance(2022, 1, 15); // ********* for testing only
                String currYearStr = nowTime.format('yyyy'); //****************** 
                // String limitMonth =
    
                // if(selectedYear == currYearStr) {
    
                // } else {
    
                // }
    
                String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                // currMonthStr = '01' // for testing;
                String oneMonthAgo = toDay.month()-1 > 0 ? String.valueOf(toDay.month()-1).leftPad(2,'0') : '12';
                String twoMonthAgo = toDay.month()-2 > 0 ? String.valueOf(toDay.month()-2).leftPad(2,'0') : String.valueOf(12-(2-toDay.month())).leftPad(2,'0');
                if(isIndividual) {
                    lastAvailPerf = Database.query(lastAvailPerfQuery);
                } else {
                    List<AggregateResult> aggResult = Database.query(lastAvailPerfQuery);
                    if(aggResult.size() > 0) {
                        Sale_Performance__c convAggResult = new Sale_Performance__c();
                        convAggResult.Target_Point__c = Decimal.valueOf(String.valueOf(aggResult[0].get('Target_Point__c')));
                        convAggResult.Month__c = String.valueOf(aggResult[0].get('Month__c'));
                        convAggResult.Year__c = String.valueOf(aggResult[0].get('Year__c'));
                        lastAvailPerf.add(convAggResult);
                    }
                   
                }
    
                // List<Sale_Performance__c> lastAvailPerf = Database.query(lastAvailPerfQuery);
                String lastAvailPerfMonth;
                String lastAvailPerfYear;
                String perfDateTimeCondition = '';
                String transDateTimeCondition = '';
                if(lastAvailPerf.size() > 0) {
                    // if(lastAvailPerf[0].Year__c == currYearStr) {
                        // lastAvailPerfYear = lastAvailPerf[0].Year__c;
                        // lastAvailPerfMonth = lastAvailPerf[0].Month__c;
                    // } else if(lastAvailPerf[0].Year__c != currYearStr && lastAvailPerf[0].Month__c >= String.valueOf(12-(2-toDay.month())).leftPad(2,'0')) {
                    if(lastAvailPerf[0].Year__c != null) {
                        lastAvailPerfYear = lastAvailPerf[0].Year__c;
                        lastAvailPerfMonth = lastAvailPerf[0].Month__c;
                    } else {
                        lastAvailPerf[0] = null;
                    }
                } else {
                    return retWrapper;
                }
    
                if(selectedYear == null) {
                    selectedYear = lastAvailPerfYear;
                }
    
                String monthCondition = toDay.month() < Integer.valueOf(oneMonthAgo) ? '12' : currMonthStr;
                if(selectedYear == currYearStr) {
                    if(lastAvailPerfYear == currYearStr) {
                        if(lastAvailPerfMonth == oneMonthAgo) {
                            perfDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c <= \''+oneMonthAgo+'\' ';
                            transDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c > \''+oneMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                        // } else if(lastAvailPerfMonth == twoMonthAgo) {
                            targetMultipiler = 1;
                        } else if(lastAvailPerfMonth != null) {
                            
                            
                            List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c =: oneMonthAgo AND Year__c =: lastAvailPerfYear LIMIT 1];
                            
                            if(checkOtherPerf.size() > 0) {
                                perfDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c <= \''+oneMonthAgo+'\' ';
                                transDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c > \''+oneMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                                targetMultipiler = 1;
                                
                            } else {
                                perfDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c <= \''+twoMonthAgo+'\' ';
                                transDateTimeCondition = ' AND Year__c = \''+lastAvailPerfYear+'\' AND Month__c > \''+twoMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                                targetMultipiler = 2;
                            }
                        }
                        
                    } else if(lastAvailPerfYear == Datetime.now().addYears(-1).format('yyyy')) {
                        // current month = 1,2
                        perfDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' ';
                        
                        if(currMonthStr == '01') {
                            targetMultipiler = 1;
                            transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c >= \'01\' AND Month__c <= \''+monthCondition+'\' ';
                        } else {
                            List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c = '01' AND Year__c =: currYearStr LIMIT 1];
                            if(checkOtherPerf.size() > 0) {
                                targetMultipiler = 1;
                                transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c = \'02\' ';
                            } else {
                                targetMultipiler = 2;
                                transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c >= \'01\' AND Month__c <= \''+monthCondition+'\' ';
                            }
                        }
                    }
                } else {
                    if(currMonthStr == '01') {
                        List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c = '12' AND Year__c =: selectedYear LIMIT 1];
                        if(checkOtherPerf.size() > 0) {
                            transDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' AND Month__c = \'000\' ';
                            perfDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' ';
                            targetMultipiler = 1;
                        } else {
                            transDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' AND Month__c = \'12\' ';
                            perfDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' AND Month__c < \'12\' ';
                            targetMultipiler = 2;
                        }
                    } else {
                        transDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' AND Month__c = \'000\' ';
                        perfDateTimeCondition = ' AND Year__c = \''+selectedYear+'\' ';
                        targetMultipiler = 1;
                    }
                    
                }
                
    
                List<Sale_Performance__c> lastReceivedPerf = [SELECT Id,Month__c,Year__c FROM Sale_Performance__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
    
                retWrapper.availPerfObj = lastAvailPerf[0];
                retWrapper.availPerfMonth = lastAvailPerfMonth;
                retWrapper.availPerfYear = lastAvailPerfYear;
                retWrapper.perfDateTimeCondition = perfDateTimeCondition;
                retWrapper.transDateTimeCondition = transDateTimeCondition;
                retWrapper.targetMultipiler = targetMultipiler;
                retWrapper.lastReceivedPerf = lastReceivedPerf.size() > 0 ? lastReceivedPerf[0] : null;
    
                return retWrapper;
            }
            return null;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    public class sumPerfBankWideWrapperSectionC {
        @AuraEnabled
        public Sale_Performance__c salePerfBank;
        @AuraEnabled
        public String sumQueryCond;
        @AuraEnabled
        public Id lastRecordId;
        @AuraEnabled
        public Boolean isEndRecord;
        // @AuraEnabled
        // public Decimal sumPerfPoint;
        // @AuraEnabled
        // public Decimal totalTarget;
        // @AuraEnabled
        // public Decimal totalBankTransSum;
    }

    @AuraEnabled
    public static sumPerfBankWideWrapperSectionC sumBankWidePerf(Object sumPerfObj) {
        try{   
            sumPerfBankWideWrapperSectionC sumPerfBWWrapper = (sumPerfBankWideWrapperSectionC)JSON.deserialize(JSON.serialize(sumPerfObj), sumPerfBankWideWrapperSectionC.class);
            sumPerfBankWideWrapperSectionC sumPerfWrapper = sumPerfBWWrapper;
            if(sumPerfBWWrapper.sumQueryCond != null) {
                String query = '';
                
                sumPerfWrapper.isEndRecord = true;
                Sale_Performance__c resSum;
                if (sumPerfBWWrapper.salePerfBank == null) {
                    resSum = new Sale_Performance__c();
                } else {
                    resSum = sumPerfBWWrapper.salePerfBank;
                }

                resSum.Financial_Actual_Point__c = resSum.Financial_Actual_Point__c != null ? resSum.Financial_Actual_Point__c : 0;
                resSum.Target_Point__c = resSum.Target_Point__c != null ? resSum.Target_Point__c : 0;
                Integer chunkSize = 35000;
                if(sumPerfBWWrapper.lastRecordId == null) {
                    // first time
                    query = 'SELECT Id, Financial_Actual_Point__c, Target_Point__c FROM Sale_Performance__c '+sumPerfBWWrapper.sumQueryCond+' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                } else {
                    query = 'SELECT Id, Financial_Actual_Point__c, Target_Point__c FROM Sale_Performance__c '+sumPerfBWWrapper.sumQueryCond+' AND Id > \''+sumPerfBWWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                }

                List<Sale_Performance__c> bankWidePerf = Database.query(query);
                for(Sale_Performance__c perf : bankWidePerf) {
                    resSum.Financial_Actual_Point__c = perf.Financial_Actual_Point__c != null ? resSum.Financial_Actual_Point__c+perf.Financial_Actual_Point__c : resSum.Financial_Actual_Point__c;
                    resSum.Target_Point__c = perf.Target_Point__c != null ? resSum.Target_Point__c+perf.Target_Point__c : resSum.Target_Point__c;
                }
                
                Integer dataRow = bankWidePerf.size();
                if(dataRow >= chunkSize) {
                    sumPerfWrapper.lastRecordId = bankWidePerf[dataRow-1].Id;
                    List<Sale_Performance__c> checkNext = [SELECT Id FROM Sale_Performance__c WHERE Id >: sumPerfWrapper.lastRecordId ORDER BY Id LIMIT 1];
                    if(checkNext.size() > 0) {
                        sumPerfWrapper.isEndRecord = false;
                    }
                }
                sumPerfWrapper.salePerfBank = resSum;

                // if end of record, sum new avg bankwide
                // if(sumTransWrapper.isEndRecord) {
                //     // sumTransBWWrapper.sumPerfPoint = sumTransBWWrapper.sumPerfPoint != null ? sumTransBWWrapper.sumPerfPoint : 0;
                //     sumTransWrapper.totalBankTransSum = resSum.Actual_Point__c;
                //     System.debug('sumTransWrapper.totalBankTransSum =>' + sumTransWrapper.totalBankTransSum);
                // }
            }
            return sumPerfWrapper;

        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
            
    }

    @AuraEnabled
    public static AggregateResult sumPerfAgg(String whereCondition){
        try{
            // List<AggregateResult> sumBranchPerf;
            // if(isIndividual) {
            String sumBranchPerfQuery = 'SELECT SUM(Financial_Actual_Point__c) Sum_Act_Point, SUM(Target_Point__c) Sum_Target_Point FROM Sale_Performance__c '+whereCondition;
            List<AggregateResult> sumBranchPerf = Database.query(sumBranchPerfQuery);
            // } else {
                
            // }
            if(sumBranchPerf.size() > 0) {
                return sumBranchPerf[0];
            }
            return null;
            
        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Boolean checkPerfIsReceived(String month, String year){
        try{
            List<Sale_Performance__c> salePerfLst = [SELECT Id FROM Sale_Performance__c WHERE Month__c =: month AND Year__c =: year LIMIT 1];
            if(salePerfLst.size() > 0) {
                return true;
            }
            return false;
            
        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
            
    }

    public class currentMonthKPIWrapper {
        @AuraEnabled
        public String empId;
        @AuraEnabled
        public String curMonth;
        @AuraEnabled
        public Decimal curMonthKPI;
    }    

    @AuraEnabled
    public static List<currentMonthKPIWrapper> getCurrentMonthKPI(String branchCode, String selectedYear){
        try{
            List<AggregateResult> saleLst = [SELECT Employee_ID__c, Max(Month__c) LastMonthPerf FROM Sale_Info__c WHERE Branch_Code__c =: branchCode AND Year__c =: selectedYear GROUP BY Employee_ID__c];
            Map<String,String> empIdMap = new Map<String,String>();
            for(AggregateResult sale : saleLst) {
                empIdMap.put(String.valueOf(sale.get('Employee_ID__c')),String.valueOf(sale.get('LastMonthPerf')));
            }
            
            List<currentMonthKPIWrapper> curMonthKPI = new List<currentMonthKPIWrapper>();
            List<Sale_Performance__c> salePerfLst = [SELECT Employee_ID__c, Month__c, Financial_Actual_Point__c, Target_Point__c FROM Sale_Performance__c WHERE Year__c =: selectedYear AND Sale_Branch_Code__c =: branchCode  AND Employee_ID__c IN: empIdMap.keySet() AND Month__c IN: empIdMap.values()];
            Integer i = 0;
            for(Sale_Performance__c salePerf : salePerfLst) {
                if(empIdMap.get(salePerf.Employee_ID__c) == salePerf.Month__c) {
                    currentMonthKPIWrapper kpiWrapper = new currentMonthKPIWrapper();
                    kpiWrapper.empId = salePerf.Employee_ID__c;
                    kpiWrapper.curMonth = salePerf.Month__c;
                    // Integer currentYear = Date.today().year();
                    // Integer currentMonth = Date.today().month();
                    // Integer currentDay = Date.today().day();
                    // Integer dayInMonth = Date.daysInMonth(currentYear, currentMonth);
                    // System.debug(' currentYear: '+currentYear);
                    // System.debug(' currentMonth: '+currentMonth);
                    // System.debug(' currentDay: '+currentDay);
                    // System.debug(' dayInMonth: '+dayInMonth);
                    if(salePerf.Financial_Actual_Point__c != null && salePerf.Target_Point__c != null) {
                        kpiWrapper.curMonthKPI = (salePerf.Financial_Actual_Point__c/salePerf.Target_Point__c)*100;
                    }
                    // kpiWrapper.curMonthKPI = (salePerf.Financial_Actual_Point__c/(salePerf.Target_Point__c * (currentDay-2) /dayInMonth ) )*100;
                    curMonthKPI.add(kpiWrapper);
                }
                i++;
            }
            return curMonthKPI;

        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Sale_Info__c> getLastSaleInfo(String branchCode){
        try{
            List<Sale_Info__c> lastSaleInfo = [SELECT Month__c,Year__c FROM Sale_Info__c ORDER BY Year__c DESC,Month__c DESC LIMIT 1];
            if(lastSaleInfo.size() > 0) {
                String lastYearSaleInfo = lastSaleInfo[0].Year__c;
                String lastMonthSaleInfo = lastSaleInfo[0].Month__c;
                List<Sale_Info__c> saleInfoInList = [SELECT Employee_ID__c, Month__c, Year__c, Branch_Code__c FROM Sale_Info__c WHERE Branch_Code__c =: branchCode AND Year__c =: lastYearSaleInfo AND Month__c =: lastMonthSaleInfo];
                // List<AggregateResult> saleLst = [SELECT Employee_ID__c FROM Sale_Info__c WHERE Branch_Code__c =: branchCode GROUP BY Employee_ID__c]; // get all sale in branch
                // Set<String> empIdSet = new Set<String>();
                // for(AggregateResult sale : saleLst) {
                //     empIdSet.add(String.valueOf(sale.get('Employee_ID__c')));
                // }
                
                // List<Sale_Info__c> saleInfoInList = [SELECT Employee_ID__c, Month__c, Year__c, Branch_Code__c FROM Sale_Info__c WHERE Employee_ID__c in: empIdSet ORDER BY Year__c DESC, Month__c DESC];
                // Map<String,Sale_Info__c> empIdMapSale = new Map<String,Sale_Info__c>();
                // for(Sale_Info__c sale : saleInfoInList) {
                //     if(!empIdMapSale.containsKey(sale.Employee_ID__c)) {
                //         empIdMapSale.put(sale.Employee_ID__c,sale);
                //     }
                // }  
                
                return saleInfoInList;
            }
            return lastSaleInfo;

        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Sale_Info__c checkLastPerf(){
        try{
            List<Sale_Info__c> lastPerf = [SELECT Month__c,Year__c FROM Sale_Info__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            if(lastPerf.size() > 0) {
                return lastPerf[0];
            }
            return null;

        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static List<T_Performance_Sharepoint__mdt> getSharePointLink(){
        try{
            List<T_Performance_Sharepoint__mdt> sharePoint = [SELECT Id, SharePoint_Type__c, URL_Link__c FROM T_Performance_Sharepoint__mdt WHERE SharePoint_Type__c IN('Help','Branch Summary') LIMIT 2];
            return sharePoint;

        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Sale_Info__c checkLastSaleInfo(){
        try{
            List<Sale_Info__c> lastSaleInfo = [SELECT Month__c,Year__c FROM Sale_Info__c ORDER BY Year__c DESC,Month__c DESC LIMIT 1];
            if(lastSaleInfo.size() > 0) {
                return lastSaleInfo[0];
            }
            return null;
            
        }catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
        }
    }
}