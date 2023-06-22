public class T_Performance_P1Controller {

    public class FinancePerfWrapper {
        @AuraEnabled
        public Decimal individualPerf;
        @AuraEnabled
        public Decimal avgBankWide;
    }

    public class objectWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public List<Sale_Transaction__c> Data;
        @AuraEnabled 
        public Decimal SumActualPoint;
        @AuraEnabled 
        public Decimal SumDeductPoint;
        @AuraEnabled 
        public Decimal NetPoint;
    }
    
    public class objectWrapper2 {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public List<objectWrapper> Data;
        @AuraEnabled 
        public Decimal SumActualPoint;
        @AuraEnabled 
        public Decimal SumDeductPoint;
        @AuraEnabled 
        public Decimal NetPoint;
    }

    public class LicenseWrapper {
        @AuraEnabled
        public String Life_License;
        @AuraEnabled
        public String Life_License_Name;
        @AuraEnabled
        public String Life_License_Status;
        @AuraEnabled
        public String Nonlife_License;
        @AuraEnabled
        public String Nonlife_License_Name;
        @AuraEnabled
        public String Nonlife_License_Status;
        @AuraEnabled
        public String Fund_License;
        @AuraEnabled
        public String Fund_License_Name;
        @AuraEnabled
        public String Fund_License_Status;
        @AuraEnabled
        public String Unitlink_License;
        @AuraEnabled
        public String Unitlink_License_Name;
        @AuraEnabled
        public String Unitlink_License_Status;
    }

    public class PerformanceWrapper2{
        @AuraEnabled
        public Sale_Info__c saleInfo;
        @AuraEnabled
        public Sale_Performance__c salePerformance;
        @AuraEnabled
        public FinancePerfWrapper financePerformance;
        @AuraEnabled
        public Decimal appIncentive;
        @AuraEnabled
        public Decimal sumFiActPoint;
        @AuraEnabled
        public Decimal sumFiTargPoint;
        @AuraEnabled
        public LicenseWrapper licenses;
        @AuraEnabled
        public Integer asOfMonth;
        @AuraEnabled
        public String asOfYear;
        @AuraEnabled
        public String sumBWTransQueryCond;
        @AuraEnabled
        public String sumBWPerfQueryCond;
        @AuraEnabled
        public Decimal totalTransTargetBW;
        @AuraEnabled
        public Boolean isCalBankwide = true;
        @AuraEnabled
        public String saleResignedMonth;
        @AuraEnabled
        public String saleResignedYear;
    }

    public class lastAvailPerfWrapper {
        @AuraEnabled
        public Sale_Performance__c availPerfObj;
        @AuraEnabled
        public String availPerfMonth;
        @AuraEnabled
        public String availPerfYear;
        @AuraEnabled
        public String perfDateTimeCondition;
        @AuraEnabled
        public String transDateTimeCondition;
        @AuraEnabled
        public Integer targetMultipiler;
    }  

    public class targetProductWrapper {
        @AuraEnabled
        public String totalFinance;
        @AuraEnabled
        public String productGroupCode;
        @AuraEnabled
        public String unit;
        @AuraEnabled
        public String rank;
        @AuraEnabled
        public Decimal weightKPIs;
        @AuraEnabled
        public Decimal targetUnit;
        @AuraEnabled
        public Decimal actualUnit;
        @AuraEnabled
        public Decimal successUnit;
        @AuraEnabled
        public Decimal achivement;
        @AuraEnabled
        public Boolean subGroupFlag;  
    }

    public class targetProductTableWrapper {
        @AuraEnabled
        public List<targetProductWrapper> productList;
        @AuraEnabled
        public Decimal grandTotal;
    }
    

    private static List<Sale_Info__c> getSaleInfo(String empId, String period, String monthStr, String year) {
    try{
        List<Sale_Info__c> saleInfo = new List<Sale_Info__c>();
        if(period == 'Month' && monthStr != null) {
            saleInfo = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                        Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c, Branch_Name__c, Year__c, Month__c
                                        FROM Sale_Info__c WHERE Employee_ID__c =: empId AND Month__c =: monthStr AND Year__c =: year LIMIT 1];
            if(saleInfo.size() < 1) {
                saleInfo = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                        Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c, Branch_Name__c, Year__c, Month__c
                                        FROM Sale_Info__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            }
        } else {
            saleInfo = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                        Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c, Branch_Name__c, Year__c, Month__c
                                        FROM Sale_Info__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
        }
        return saleInfo;

    } catch (Exception e) {
        System.debug('Error:'+e);
        // throw new AuraHandledException(' '+e);
        throw new AuraHandledException(e.getMessage());
    }
    }

    @AuraEnabled
    public static PerformanceWrapper2 getPerformanceDataP1(String empId, String period, String year, Integer monthNo)
    {
            List<Sale_Info__c> lastSaleInfo = [SELECT Month__c,Year__c FROM Sale_Info__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            if(lastSaleInfo.size() > 0) {
                try {
                // try {
                    PerformanceWrapper2 performanceWrapper = new PerformanceWrapper2();
                    if(empId == null) {
                        User currentUser = [SELECT Id, FirstName, LastName, RTL_Branch__c, RTL_Branch_Code__c, UserRoleName__c,RTL_Channel__c, Employee_ID__c FROM User WHERE Id =: UserInfo.getUserId()];
                        empId = currentUser.Employee_ID__c;
                    }

                    String groupFilter = '';
                    // if(saleInfo.get(0).Channel__c == 'Branch') {
                        groupFilter = ' AND Employee_ID__c = \''+empId+'\' ';   

                    Date toDay = Date.Today();
                    Datetime toDayTime = Datetime.now();
                    String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                    String currYearStr = toDayTime.format('yyyy');
                    String prevYearStr = Datetime.now().addYears(-1).format('yyyy');
                    String monthStr = String.valueOf(monthNo).leftPad(2,'0');
                    Integer daysInMonth = Integer.valueOf(String.valueOf(date.daysInMonth(Integer.valueOf(currYearStr),Integer.valueOf(String.valueOf(toDay.Month())))));


                    List<User> licenseInfoLst = [SELECT Id, RTL_License_No_ICP_1__c, RTL_License_No_Complex_P2__c, RTL_License_No_ICP_3__c, RTL_License_No_Paper_5__c, RTL_License_No_ICT__c, RTL_License_No_Paper_4__c, RTL_License_No_Paper_1__c, RTL_License_No_IP__c, RTL_License_No_Life_Insurance__c, RTL_License_No_Non_Life_Insurance__c, RTL_License_No_Wealthy_Link__c, RTL_Expiry_Date_Wealthy_Link__c, RTL_Active_Flag_Wealthy_Link__c, RTL_License_No_Unit_Link__c, RTL_Expiry_Date_Unit_Link__c, RTL_Active_Flag_Unit_Link__c, RTL_Expiry_Date_ICP_1__c, RTL_Expiry_Date_Complex_P2__c, RTL_Expiry_Date_ICP_3__c, RTL_Expiry_Date_Paper_5__c, RTL_Expiry_Date_ICT__c, RTL_Expiry_Date_Paper_4__c, RTL_Expiry_Date_Paper_1__c, RTL_Expiry_Date_IP__c, RTL_Expiry_Date_Life_Insurance__c, RTL_Expiry_Date_Non_Life_Insurance__c FROM User WHERE Employee_ID__c =: empId];
                    
                    List<Sale_Info__c> saleInfo = getSaleInfo(empId,period,monthStr,year);
                    List<Sale_Info__c> fixedSaleInfoDisplay = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                    Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c, Branch_Name__c 
                    FROM Sale_Info__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];

                    // toDay = Date.newInstance(2022,1,15); // for testing
                    // toDayTime = Datetime.newInstance(2022,1,15); // for testing
                    LicenseWrapper licenses = new LicenseWrapper();
                    if(saleInfo.size() > 0) {
                        licenses = getLicenses(licenseInfoLst,empId);
                    }

                    // String selectYearStr = toDayTime.format('yyyy');
                    Integer previousMonth = toDay.month()-1;
                    String previousMonthStr = String.valueOf(previousMonth).leftPad(2,'0');
                    String checkpointYearMonth = Datetime.now().format('yyyy') + previousMonthStr;
                    if(previousMonth < 1) {
                        // privous year
                        previousMonth = 12;
                        String selectYearStr = Datetime.now().addYears(-1).format('yyyy');
                        checkpointYearMonth = selectYearStr + String.valueOf(previousMonth);
                    }

                    String cpyGroupFilter = groupFilter.replace('AND', 'WHERE');
                    List<AggregateResult> sumActPoint = new List<AggregateResult>();
                    try {
                        String sumTransActQuery = 'SELECT SUM(Actual_Point__c) Sum_Point FROM Sale_Transaction__c WHERE Year__c =: currYearStr AND Month__c =: currMonthStr '+groupFilter;
                        sumActPoint = Database.query(sumTransActQuery);
                    } catch(DmlException e) {
                        // System.debug('sum act point null '+ e.getMessage());
                    }

                    List<Sale_Info__c> lastCurrSaleInfo = getSaleInfo(empId,'year',null,null);
                    String saleResignedMonth;
                    String saleResignedYear;
                    if(!(lastCurrSaleInfo.size() > 0 && lastCurrSaleInfo[0].Year__c == lastSaleInfo[0].Year__c && lastCurrSaleInfo[0].Month__c == lastSaleInfo[0].Month__c)) {
                        // current sale is resigned
                        saleResignedMonth = lastCurrSaleInfo[0].Month__c;
                        saleResignedYear = lastCurrSaleInfo[0].Year__c;
                        performanceWrapper.saleResignedMonth = saleResignedMonth;
                        performanceWrapper.saleResignedYear = saleResignedYear;
                    }

                    String saleType = saleInfo[0].Sale_Type__c;
                    String saleChannel = saleInfo[0].Channel__c;
                    String lastAvailPerfQuery = 'SELECT Year__c, Month__c, Target_Point__c FROM Sale_Performance__c '+cpyGroupFilter+' ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                    lastAvailPerfWrapper saleAvailPerfObj = getAvailPerfObj(lastAvailPerfQuery, toDay, true);

                    String branchLastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+saleType+'\' AND Channel__c = \''+saleChannel+'\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                    lastAvailPerfWrapper branchAvailPerfObj = getAvailPerfObj(branchLastAvailPerfQuery, toDay, false);

                    List<Sale_Performance__c> salePerformance = new List<Sale_Performance__c>();
                    List<AggregateResult> financialSalePerf = new List<AggregateResult>();
                    FinancePerfWrapper financePerfWrapper = new FinancePerfWrapper();
                    
                    Decimal sumFiActPoint = null;
                    Decimal sumFiTargPoint = null;
                    // 
                    // String branchAvailPerfMonthStr = branchAvailPerfObj.availPerfMonth;
                    // String saleAvailPerfMonthStr = saleAvailPerfObj.availPerfMonth;

                    String branchAvailPerfYearMonthStr = branchAvailPerfObj.availPerfYear+branchAvailPerfObj.availPerfMonth;
                    String saleAvailPerfYearMonthStr = saleAvailPerfObj.availPerfYear+saleAvailPerfObj.availPerfMonth;
                    
                    List<Sale_Transaction__c> productList = new List<Sale_Transaction__c>();

                    String saleResignedYearMonth = saleResignedMonth != null ? saleResignedYear + saleResignedMonth : null;
                    String currYearMonth = currYearStr + currMonthStr;
                    String selectedYearMonth = monthStr == null ? year : year + monthStr;
                    String lastCurrSaleYearMonth = lastCurrSaleInfo.size() > 0 && lastCurrSaleInfo[0].Month__c != null ? lastCurrSaleInfo[0].Year__c + lastCurrSaleInfo[0].Month__c : null;

                    if(period == 'year') {
                        monthNo = toDay.Month();
                        monthStr = String.valueOf(monthNo).leftPad(2,'0');

                        // Section B All
                        performanceWrapper.asOfYear = currYearStr;
                        performanceWrapper.asOfMonth = null;
                        performanceWrapper.isCalBankwide = false;
                        String salePerfQuery = 'SELECT SUM(Service_Target_Point__c) Service_Target_Point__c, SUM(Service_Actual_Point__c) Service_Actual_Point__c, SUM(Customer_Point__c) Customer_Point__c, SUM(People_Point__c) People_Point__c, SUM(Operation_Point__c) Operation_Point__c, SUM(Financial_Actual_Point__c) Financial_Actual_Point__c, SUM(Financial_Target_Point__c) Financial_Target_Point__c FROM Sale_Performance__c WHERE Year__c =: year '+groupFilter;
                        List<AggregateResult> salePerfAggResult = Database.query(salePerfQuery);
                        salePerformance = perfAggResultToSalePerf(salePerfAggResult);
                        productList = [SELECT Indicator_Name__c, Indicator_Level1__c, Indicator_Level2__c,Actual_Performance__c, Actual_Point__c, Sale_Unit__c,Deduct_Flag__c,Deduct_Date__c,KPI_Date__c,Deduct_Point__c, Employee_ID__c From Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: year ORDER BY Indicator_Code_Level1__c,Indicator_Code_Level2__c,Indicator_Code__c ];
                        if(year == currYearStr) {
                            // period = year and current year
                            String financialSaleQuery = 'SELECT SUM(Financial_Actual_Point__c) Sum_Point, SUM(Target_Point__c) Sum_Target FROM Sale_Performance__c WHERE Year__c =: year '+groupFilter;
                            financialSalePerf = Database.query(financialSaleQuery);
        
                            if(financialSalePerf.size() > 0) {
                                sumFiActPoint = financialSalePerf[0].get('Sum_Point') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Point'))) : null;
                                sumFiTargPoint = financialSalePerf[0].get('Sum_Target') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Target'))) : null;
                            }

                            if(branchAvailPerfObj.availPerfObj != null) {
                            //  try {
                                String sumBranchPerfQuery = ' WHERE Sale_Type__c = \''+saleType+'\' AND Channel__c = \''+saleChannel+'\' '+branchAvailPerfObj.perfDateTimeCondition;
                                String sumBranchTransQueryCond = ' WHERE Sale_Type__c = \''+saleType+'\' AND Channel__c = \''+saleChannel+'\' '+branchAvailPerfObj.transDateTimeCondition;
                                
                                performanceWrapper.sumBWPerfQueryCond = sumBranchPerfQuery;
                                performanceWrapper.sumBWTransQueryCond = sumBranchTransQueryCond;
                                Integer dayInMonth = Integer.valueOf(String.valueOf(date.daysInMonth(Integer.valueOf(currYearStr),Integer.valueOf(String.valueOf(toDay.Month())))));
                                Integer targetMultipiler = branchAvailPerfObj.targetMultipiler;
                                Decimal totalTransTarget = ((branchAvailPerfObj.availPerfObj.Target_Point__c/dayInMonth)*(Integer.valueOf(String.valueOf(toDayTime.format('dd')))-2));
                                if ((Integer.valueOf(String.valueOf(toDayTime.format('dd'))))-2 < 1 ){  
                                    totalTransTarget = 0;
                                }
                                if(targetMultipiler > 1) {
                                    totalTransTarget = totalTransTarget + branchAvailPerfObj.availPerfObj.Target_Point__c;
                                }

                                performanceWrapper.totalTransTargetBW = totalTransTarget;
                            }
            
                            if(saleAvailPerfObj.availPerfObj != null) {
                                // Section C Individual
                                String sumSalePerfQuery = 'SELECT SUM(Financial_Actual_Point__c) Sum_Act_Point, SUM(Target_Point__c) Sum_Target_Point FROM Sale_Performance__c '+cpyGroupFilter+' '+saleAvailPerfObj.perfDateTimeCondition;
                                List<AggregateResult> sumSalePerf = Database.query(sumSalePerfQuery);
                                
                                Decimal salePerfPoint = sumSalePerf[0].get('Sum_Act_Point') == null ? null : Decimal.valueOf(String.valueOf(sumSalePerf[0].get('Sum_Act_Point')));
                                Decimal salePerfTarget = sumSalePerf[0].get('Sum_Target_Point') == null ? null : Decimal.valueOf(String.valueOf(sumSalePerf[0].get('Sum_Target_Point')));
                                if(saleInfo[0].Month__c == lastSaleInfo[0].Month__c && saleInfo[0].Year__c == lastSaleInfo[0].Year__c) {
                                    // sale still working
                                    String sumSaleTransQuery = 'SELECT SUM(Actual_Point__c) Sum_Act_Point FROM Sale_Transaction__c '+cpyGroupFilter+' '+saleAvailPerfObj.transDateTimeCondition;
                                    List<AggregateResult> sumSaleTrans = Database.query(sumSaleTransQuery);

                                    Decimal saleTransPoint = sumSaleTrans[0].get('Sum_Act_Point') == null ? null : Decimal.valueOf(String.valueOf(sumSaleTrans[0].get('Sum_Act_Point')));
                                    Integer targetMultipiler2 = saleAvailPerfObj.targetMultipiler;
                                    Decimal transTarget;
                                    if(saleTransPoint == null) {
                                        saleTransPoint = 0;
                                    }

                                    if(saleAvailPerfObj.availPerfObj.Target_Point__c != null) {
                                        transTarget = (saleAvailPerfObj.availPerfObj.Target_Point__c/daysInMonth)*(Integer.valueOf(String.valueOf(toDayTime.format('dd')))-2);
                                        /* ถ้า today -2 < 1 ให้ set transTarget เป็น 0 */

                                        if ((Integer.valueOf(String.valueOf(toDayTime.format('dd'))))-2 < 1 ){  
                                            transTarget = 0;
                                        }
                                        
                                        if(targetMultipiler2 > 1) {
                                            transTarget = transTarget + saleAvailPerfObj.availPerfObj.Target_Point__c;
                                        }
                                    }

                                    if(salePerfPoint == null) {
                                        financePerfWrapper.individualPerf = (saleTransPoint/transTarget)*100;
                                    } else {
                                        if(saleTransPoint != null && saleAvailPerfObj.availPerfObj.Target_Point__c != null) {
                                            
                                            // transTarget = saleAvailPerfObj.availPerfObj.Target_Point__c*targetMultipiler2;
                                            decimal allTarget = salePerfTarget+transTarget;
                                            if (allTarget == 0){
                                                financePerfWrapper.individualPerf = 0;
                                            }
                                            else{
                                                financePerfWrapper.individualPerf = ((salePerfPoint+saleTransPoint)/(allTarget))*100;
                                            }
                                        }
                                    }

                                    
                                } else {
                                    // sale resigned => do not cal transaction
                                    System.debug('Sale Perf Point '+salePerfPoint);
                                    System.debug('Sale Perf Target '+salePerfTarget);
                                    // if(saleAvailPerfObj.availPerfObj.Target_Point__c != null) {
                                    if(salePerfTarget != null) {
                                        financePerfWrapper.individualPerf = (salePerfPoint/salePerfTarget)*100;
                                    }
                                }

                                if(financePerfWrapper.individualPerf == null && saleResignedYearMonth == null) {
                                    financePerfWrapper.individualPerf = 0;
                                }
                            }

                            // set by default
                            if(saleResignedYearMonth == null) {
                                financePerfWrapper.avgBankWide = 0;
                            }
                        } else {
                            Decimal addSalePoint = 0;
                            Decimal addSaleTarget = 0;
                            Decimal addBankPoint = 0;
                            Decimal addBankTarget = 0;

                            String sumBWPerfQueryCond = ' WHERE Year__c = \''+year+'\' AND Sale_Type__c =  \''+saleInfo.get(0).Sale_Type__c+'\'  AND Channel__c = \''+saleInfo.get(0).Channel__c+'\' ';
                            performanceWrapper.sumBWPerfQueryCond = sumBWPerfQueryCond;
                            if(currMonthStr == '01') {
                                List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c = '12' AND Year__c =: year LIMIT 1];
                                if(saleAvailPerfObj.availPerfYear == year && saleAvailPerfObj.availPerfMonth != '12' && checkOtherPerf.size() == 0) {
                                    // no performance on month 12
                                    addSaleTarget = saleAvailPerfObj.availPerfObj.Target_Point__c;
                                    String transMonth12 = 'SELECT SUM(Actual_Point__c) Sum_Point FRoM Sale_Transaction__c WHERE Year__c =: year AND Month__c = \'12\' '+groupFilter;
                                    List<AggregateResult> sumTransMonth12 = Database.query(transMonth12);
                                    if(sumTransMonth12.size() > 0 && sumTransMonth12[0].get('Sum_Point') != null) {
                                        addSalePoint = Decimal.valueOf(String.valueOf(sumTransMonth12[0].get('Sum_Point')));
                                    }
                                }
                                
                                if(branchAvailPerfObj.availPerfYear == year && saleAvailPerfObj.availPerfMonth != '12' && checkOtherPerf.size() == 0) {
                                    // no performance on month 12
                                    performanceWrapper.totalTransTargetBW = branchAvailPerfObj.availPerfObj.Target_Point__c;

                                    String sumBWTransQueryCond = ' WHERE Year__c = \''+year+'\' AND Month__c = \'12\' AND Sale_Type__c = \''+saleInfo.get(0).Sale_Type__c+'\' AND Channel__c = \''+saleInfo.get(0).Channel__c+'\' ';

                                    performanceWrapper.sumBWTransQueryCond = sumBWTransQueryCond;
                                } 
                                
                            } 

                            toDayTime.format('yyyy');
                            Datetime cpyToDayTime = toDayTime;
                        //  cpyToDayTime.addYears(2);
                            performanceWrapper.asOfYear = cpyToDayTime.addYears(-1).format('yyyy');
                            performanceWrapper.asOfMonth = null;
                            String financialSaleQuery = 'SELECT SUM(Financial_Actual_Point__c) Sum_Point, SUM(Target_Point__c) Sum_Target FROM Sale_Performance__c WHERE Year__c =: year '+groupFilter;
                            financialSalePerf = Database.query(financialSaleQuery);

                            if(financialSalePerf.size() > 0) {
                                sumFiActPoint = financialSalePerf[0].get('Sum_Point') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Point'))) : null;
                                sumFiTargPoint = financialSalePerf[0].get('Sum_Target') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Target'))) : null;
                            }

                            if(saleInfo[0].Month__c == lastSaleInfo[0].Month__c && saleInfo[0].Year__c == lastSaleInfo[0].Year__c) {
                                // sale still working
                                if(sumFiActPoint != null && sumFiTargPoint != null) {
                                    financePerfWrapper.individualPerf = (((sumFiActPoint+addSalePoint)/(sumFiTargPoint+addSaleTarget))*100).setScale(2,RoundingMode.HALF_UP);
                                }
                            } else {
                                // sale resigned
                                if(sumFiActPoint != null && sumFiTargPoint != null) {
                                    financePerfWrapper.individualPerf = ((sumFiActPoint/sumFiTargPoint)*100).setScale(2,RoundingMode.HALF_UP);
                                }
                            }
                            
                            List<Sale_Info__c> checkSaleWorking = [SELECT Id FROM Sale_Info__c WHERE Employee_ID__c =: empId AND Year__c =: year LIMIT 1];
                            if(financePerfWrapper.individualPerf == null && (saleResignedYearMonth == null || selectedYearMonth <= saleResignedYearMonth)) {
                                if(checkSaleWorking.size() > 0) {
                                    financePerfWrapper.individualPerf = 0;
                                }
                            }

                            // set by default
                            if(saleResignedYearMonth == null || selectedYearMonth <= saleResignedYearMonth) {
                                if(checkSaleWorking.size() > 0) {
                                    financePerfWrapper.avgBankWide = 0;
                                }
                            }
                        }
                    } else {

                        if(monthNo != null) {
                            // select month
                            productList = [SELECT Indicator_Name__c, Indicator_Level1__c, Indicator_Level2__c,Actual_Performance__c, Actual_Point__c, Sale_Unit__c,Deduct_Flag__c,Deduct_Date__c,KPI_Date__c,Deduct_Point__c, Employee_ID__c From Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: year AND Month__c =: monthStr ORDER BY Indicator_Code_Level1__c,Indicator_Code_Level2__c,Indicator_Code__c ];

                            String financialSaleQuery = 'SELECT SUM(Financial_Actual_Point__c) Sum_Point, SUM(Target_Point__c) Sum_Target FROM Sale_Performance__c WHERE Year__c =: year AND Month__c =: monthStr '+groupFilter;
                            financialSalePerf = Database.query(financialSaleQuery);

                            if(financialSalePerf.size() > 0) {
                                sumFiActPoint = financialSalePerf[0].get('Sum_Point') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Point'))) : null;
                                sumFiTargPoint = financialSalePerf[0].get('Sum_Target') != null ? Decimal.valueOf(String.valueOf(financialSalePerf[0].get('Sum_Target'))) : null;
                            }
                            performanceWrapper.asOfYear = year;
                            performanceWrapper.asOfMonth = monthNo;
                            if(year == currYearStr && monthNo == toDay.month()) {
                                // current month
                                Integer dayRate = Integer.valueOf(String.valueOf(toDayTime.format('dd')))-2;
                                String sumBWPerfQueryCond;
                                if(saleInfo.get(0).Channel__c == 'Branch') {
                                    sumBWPerfQueryCond = ' WHERE Sale_Type__c = \''+saleInfo.get(0).Sale_Type__c+'\' AND Channel__c = \''+saleInfo.get(0).Channel__c+'\' AND Year__c = \''+currYearStr+'\' AND Month__c = \''+currMonthStr+'\' ';
                                } else {
                                    sumBWPerfQueryCond = ' WHERE Channel__c = \''+saleInfo.get(0).Channel__c+'\' AND Year__c = \''+currYearStr+'\' AND Month__c = \''+currMonthStr+'\' ';
                                }
                                performanceWrapper.isCalBankwide = false;
                                performanceWrapper.sumBWPerfQueryCond = sumBWPerfQueryCond;

                                if(branchAvailPerfObj.availPerfObj != null) {
                                    performanceWrapper.totalTransTargetBW = (branchAvailPerfObj.availPerfObj.Target_Point__c/daysInMonth)*dayRate;
                                    performanceWrapper.sumBWTransQueryCond = sumBWPerfQueryCond;
                                }
                                

                                if(saleResignedMonth == null) {
                                    if(saleAvailPerfObj.availPerfObj != null) {
                                        Decimal sumTransActualPoint = sumActPoint[0].get('Sum_Point') == null ? null : Decimal.valueOf(String.valueOf(sumActPoint[0].get('Sum_Point')));
                                        Decimal sumTargetCurrentMonth;
                                        if(dayRate > 0 && sumTransActualPoint != null) {
                                            sumTargetCurrentMonth = (saleAvailPerfObj.availPerfObj.Target_Point__c/daysInMonth)*dayRate;
                                            if(sumTargetCurrentMonth != null && sumTargetCurrentMonth != 0) {
                                                financePerfWrapper.individualPerf = ((sumTransActualPoint/sumTargetCurrentMonth)*100).setScale(2,RoundingMode.HALF_UP);
                                            }
                                        }

                                        if(financePerfWrapper.individualPerf == null) {
                                            financePerfWrapper.individualPerf = 0.00;
                                        }
                                    }
                                } else {
                                    financePerfWrapper.individualPerf = null;
                                }
                                
                                // if(saleResignedYearMonth == null) {
                                    // set by default
                                    financePerfWrapper.avgBankWide = 0;
                                // }
                            } else if(year == currYearStr && monthNo == toDay.month()-1 && branchAvailPerfYearMonthStr < currYearStr+String.valueOf(toDay.month()-1).leftPad(2,'0')) {
                                String sumTransPointPrevMonthQuery = 'SELECT SUM(Actual_Point__c) Sum_Point FROM Sale_Transaction__c WHERE Year__c =: currYearStr AND Month__c =: previousMonthStr '+groupFilter;
                                List<AggregateResult> sumTransPointPrevMonth = Database.query(sumTransPointPrevMonthQuery);
                                
                                String sumBWPerfQueryCond;
                                if(saleInfo.get(0).Channel__c == 'Branch') {
                                    sumBWPerfQueryCond = ' WHERE Sale_Type__c = \''+saleInfo.get(0).Sale_Type__c+'\' AND Channel__c = \''+saleInfo.get(0).Channel__c+'\' AND Year__c = \''+currYearStr+'\' AND Month__c = \''+previousMonthStr+'\' ';
                                } else {
                                    sumBWPerfQueryCond = ' WHERE Channel__c = \''+saleInfo.get(0).Channel__c+'\' AND Year__c = \''+currYearStr+'\' AND Month__c = \''+previousMonthStr+'\' ';
                                }
                                performanceWrapper.isCalBankwide = false;
                                performanceWrapper.sumBWPerfQueryCond = sumBWPerfQueryCond;


                                if(branchAvailPerfObj.availPerfObj != null) {
                                    performanceWrapper.totalTransTargetBW = branchAvailPerfObj.availPerfObj.Target_Point__c;
                                    performanceWrapper.sumBWTransQueryCond = sumBWPerfQueryCond;
                                }

                                if(saleResignedMonth == null) {
                                    if(saleInfo[0].Month__c == lastSaleInfo[0].Month__c && saleInfo[0].Year__c == lastSaleInfo[0].Year__c) {
                                        if(saleAvailPerfObj.availPerfObj != null) {
                                            Decimal sumTargetCurrentMonth = saleAvailPerfObj.availPerfObj.Target_Point__c;
                                            Decimal sumTransActualPoint = sumTransPointPrevMonth[0].get('Sum_Point') == null ? null : Decimal.valueOf(String.valueOf(sumTransPointPrevMonth[0].get('Sum_Point')));
                                            if(sumTargetCurrentMonth != null && sumTransActualPoint != null) {
                                                financePerfWrapper.individualPerf = ((sumTransActualPoint/sumTargetCurrentMonth)*100).setScale(2,RoundingMode.HALF_UP);
                                            }
                                        }
                                    }
                                    if(financePerfWrapper.individualPerf == null) {
                                        financePerfWrapper.individualPerf = 0.00;
                                    }
                                } else {
                                    financePerfWrapper.individualPerf = null;
                                }

                                // if(saleResignedYearMonth == null) {
                                    // set by default
                                    financePerfWrapper.avgBankWide = 0;
                                // }
                            }
                            
                            else {
                                // System.debug('Not current month');
                                String lastSaleInfoYearMonth = lastSaleInfo[0].Month__c != null ? lastSaleInfo[0].Year__c + lastSaleInfo[0].Month__c : null;
                                if(selectedYearMonth > lastSaleInfoYearMonth && selectedYearMonth <= currYearMonth) {
                                    financePerfWrapper.avgBankWide = 0.00;
                                }

                                List<AggregateResult> sumBranchPerf = [SELECT SUM(Financial_Actual_Point__c) Sum_Act_Point, SUM(Target_Point__c) Sum_Target_Point FROM Sale_Performance__c WHERE Year__c =: year AND Month__c =: monthStr AND Sale_Type__c =: saleInfo.get(0).Sale_Type__c AND Channel__c =: saleInfo.get(0).Channel__c];
                                if(sumBranchPerf.size() > 0 && sumBranchPerf[0].get('Sum_Act_Point') != null && sumBranchPerf[0].get('Sum_Target_Point') != null) {
                                    financePerfWrapper.avgBankWide = ((Decimal.valueOf(String.valueOf(sumBranchPerf[0].get('Sum_Act_Point')))/Decimal.valueOf(String.valueOf(sumBranchPerf[0].get('Sum_Target_Point'))))*100).setScale(2,RoundingMode.HALF_UP);
                                }
                                if(sumFiActPoint != null && sumFiTargPoint != null) {
                                    financePerfWrapper.individualPerf = ((sumFiActPoint/sumFiTargPoint)*100).setScale(2,RoundingMode.HALF_UP);
                                }

                                Decimal sumTargetPoint = sumBranchPerf[0].get('Sum_Target_Point') == null ? null : Decimal.valueOf(String.valueOf(sumBranchPerf[0].get('Sum_Target_Point')));
                                if(saleInfo[0].Month__c == monthStr) {
                                    // selected month sales คนนี้มาทำงานปกติ และมีข้อมูลมาปกติ
                                    if(financePerfWrapper.individualPerf == null && sumFiTargPoint != null) {
                                        // sales not have any point
                                        financePerfWrapper.individualPerf = 0.00;
                                    }

                                    // if(financePerfWrapper.avgBankWide == null) {
                                    //     financePerfWrapper.avgBankWide = 0.00;
                                    // }
                                } else {
                                    // sales คนนั้นลาออก หรือข้อมูลเดือนนี้ยังไม่มา
                                    List<Sale_Info__c> checkSaleWorkingInTheMonth = [SELECT Id FROM Sale_Info__c WHERE Employee_ID__c =: empId AND Year__c =: year AND Month__c =: monthStr LIMIT 1];
                                    if(saleResignedYearMonth != null) {
                                        // sales ลาออกแล้ว
                                        
                                        if(checkSaleWorkingInTheMonth.size() > 0 && selectedYearMonth <= currYearMonth && selectedYearMonth <= saleResignedYearMonth) {
                                            // sale ยังทำงานอยู่แต่ข้อมูลในเดือนนั้นยังไม่มา
                                            if(financePerfWrapper.individualPerf == null) {
                                                // sales not have any point
                                                financePerfWrapper.individualPerf = 0.00;
                                            }

                                            // if(financePerfWrapper.avgBankWide == null) {
                                            //     financePerfWrapper.avgBankWide = 0.00;
                                            // }
                                            
                                        }
                                    // }
                                    } else {
                                        // sale ยังไม่ลาออก
                                        List<Sale_Info__c> checkData = [SELECT Id FROM Sale_Info__c WHERE Year__c =: year AND Month__c =: monthStr LIMIT 1];
                                        if(selectedYearMonth <= currYearMonth && saleResignedYearMonth == null) {
                                            if((checkSaleWorkingInTheMonth.size() > 0 || (checkSaleWorkingInTheMonth.size() <= 0 && checkData.size() <= 0)) && selectedYearMonth >= lastCurrSaleYearMonth) {
                                                if(financePerfWrapper.individualPerf == null) {
                                                    // sales not have any point
                                                    financePerfWrapper.individualPerf = 0.00;
                                                }
    
                                                // if(financePerfWrapper.avgBankWide == null) {
                                                //     financePerfWrapper.avgBankWide = 0.00;
                                                // }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            String salePerfQuery = 'SELECT SUM(Service_Target_Point__c) Service_Target_Point__c, SUM(Service_Actual_Point__c) Service_Actual_Point__c, SUM(Customer_Point__c) Customer_Point__c, SUM(People_Point__c) People_Point__c, SUM(Operation_Point__c) Operation_Point__c, SUM(Financial_Actual_Point__c) Financial_Actual_Point__c, SUM(Financial_Target_Point__c) Financial_Target_Point__c FROM Sale_Performance__c WHERE Month__c =: monthStr AND Year__c =: year '+groupFilter;
                            List<AggregateResult> salePerfAggResult = Database.query(salePerfQuery);
                            salePerformance = perfAggResultToSalePerf(salePerfAggResult);
                        }
                    }

                    Integer percentSuccess = null;
                    Decimal appIncentive = null;
                    Decimal incentiveTargetPoint;
                    if(saleAvailPerfObj.availPerfObj.Target_Point__c != null) {
                        incentiveTargetPoint = saleAvailPerfObj.availPerfObj.Target_Point__c;
                    }

                    if(saleInfo.get(0).Channel__c == 'Branch' && sumActPoint.size() > 0 && sumActPoint[0].get('Sum_Point') != null && incentiveTargetPoint != null) {
                        Decimal actualPoint = Decimal.valueOf(String.valueOf(sumActPoint[0].get('Sum_Point')));
                        Integer percentSuccessCriteria = AppConfig__c.getValues('Percent Success Criteria').Value__c == null ? null : Integer.valueOf(AppConfig__c.getValues('Percent Success Criteria').Value__c);
                        percentSuccess = Integer.valueOf(((actualPoint/incentiveTargetPoint)*100).round(System.RoundingMode.HALF_UP));
                        if(percentSuccess < percentSuccessCriteria) {
                            appIncentive = 0;
                        } else {
                            List<Incentive_Multiplier__c> multipiler = [SELECT Id,Multiplier__c FROM Incentive_Multiplier__c WHERE SSP_Max__c >=: actualPoint AND SSP_Start__c <=: actualPoint AND Target_max__c >=: incentiveTargetPoint AND Target_min__c <= : incentiveTargetPoint LIMIT 1];
                            if(multipiler.size() > 0) {
                                appIncentive = actualPoint*multipiler.get(0).Multiplier__c;
                            }
                        }
                    }

                    performanceWrapper.saleInfo = fixedSaleInfoDisplay.size() > 0 ? fixedSaleInfoDisplay.get(0) : null;
                    performanceWrapper.salePerformance = salePerformance.size() > 0 ? salePerformance.get(0) : null;
                    performanceWrapper.financePerformance = financePerfWrapper;
                    // performanceWrapper.sumProduct = sumProductObj;
                    performanceWrapper.appIncentive = appIncentive;
                    performanceWrapper.sumFiActPoint = sumFiActPoint;
                    performanceWrapper.sumFiTargPoint = sumFiTargPoint;
                    performanceWrapper.licenses = licenses;
                    // performanceWrapper.sumTransBankWideWrapper = sumTransBWWrapper;
                    return performanceWrapper;
                } catch (Exception e) {
                    System.debug('Error:'+e);
                    // throw new AuraHandledException(' '+e);
                    throw new AuraHandledException(e.getMessage());
                }
            } else {
                throw new AuraHandledException('ไม่พบข้อมูล User ใน Sale Info');
                // throw new AuraHandledException(e.getMessage());
            }    
    }

    @AuraEnabled
    public static LicenseWrapper getLicenses(List<User> licenseInfoLst, String empId){
        try{
        Date toDay = Date.Today();
        Datetime toDayTime = Datetime.now();
        String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
        String currYearStr = toDayTime.format('yyyy');
        List<String> hasLicense = new List<String>();
        String filterLicense;
        LicenseWrapper licenses = new LicenseWrapper();

        // waiting for confirmation meta data*****************
        licenses.Fund_License_Name = T_Performance_License_Description__mdt.getInstance('IC').Description__c;
        licenses.Nonlife_License_Name = T_Performance_License_Description__mdt.getInstance('NLB').Description__c;
        licenses.Unitlink_License_Name = T_Performance_License_Description__mdt.getInstance('UL').Description__c;
        licenses.Life_License_Name = T_Performance_License_Description__mdt.getInstance('LB').Description__c;

        if(licenseInfoLst.size() > 0) {
            User licenseInfo = licenseInfoLst[0];
        
            licenses.Life_License = licenseInfo.RTL_License_No_Life_Insurance__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Life_Insurance__c ? licenseInfo.RTL_License_No_Life_Insurance__c : null;
            if(licenses.Life_License != null) hasLicense.add('LB');
            
            // licenses.Life_License_Status = toDay <= licenseInfo.RTL_Expiry_Date_Life_Insurance__c ? 'Y' : 'N';
            licenses.Nonlife_License = licenseInfo.RTL_License_No_Non_Life_Insurance__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Non_Life_Insurance__c ? licenseInfo.RTL_License_No_Non_Life_Insurance__c : null;
            if(licenses.Nonlife_License != null) hasLicense.add('NLB');
            // licenses.Nonlife_License_Status = toDay <= licenseInfo.RTL_Expiry_Date_Non_Life_Insurance__c ? 'Y' : 'N';
            
            licenses.Fund_License = licenseInfo.RTL_License_No_Paper_1__c != null  && toDay <= licenseInfo.RTL_Expiry_Date_Paper_1__c ? licenseInfo.RTL_License_No_Paper_1__c : 
            (licenseInfo.RTL_License_No_Paper_4__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Paper_4__c ? licenseInfo.RTL_License_No_Paper_4__c : 
            (licenseInfo.RTL_License_No_Paper_5__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Paper_5__c ? licenseInfo.RTL_License_No_Paper_5__c : 
            (licenseInfo.RTL_License_No_ICP_1__c != null && toDay <= licenseInfo.RTL_Expiry_Date_ICP_1__c ? licenseInfo.RTL_License_No_ICP_1__c : 
            (licenseInfo.RTL_License_No_Complex_P2__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Complex_P2__c ? licenseInfo.RTL_License_No_Complex_P2__c :
            (licenseInfo.RTL_License_No_ICP_3__c != null && toDay <= licenseInfo.RTL_Expiry_Date_ICP_3__c ? licenseInfo.RTL_License_No_ICP_3__c : 
            (licenseInfo.RTL_License_No_IP__c != null && toDay <= licenseInfo.RTL_Expiry_Date_IP__c ? licenseInfo.RTL_License_No_IP__c : 
            (licenseInfo.RTL_License_No_ICT__c != null && toDay <= licenseInfo.RTL_Expiry_Date_ICT__c ? licenseInfo.RTL_License_No_ICT__c : null)))))));
            if(licenses.Fund_License != null) hasLicense.add('IC');
            
            
            licenses.Unitlink_License = licenseInfo.RTL_License_No_Wealthy_Link__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Wealthy_Link__c && licenseInfo.RTL_Active_Flag_Wealthy_Link__c ? licenseInfo.RTL_License_No_Wealthy_Link__c : 
            licenseInfo.RTL_License_No_Unit_Link__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Unit_Link__c && licenseInfo.RTL_Active_Flag_Unit_Link__c ? licenseInfo.RTL_License_No_Unit_Link__c : null;
            if(licenses.Fund_License != null) hasLicense.add('UL');
            

            if(hasLicense.size() > 0) {
                for(Integer i = 0; i < hasLicense.size(); i++) {
                    if(i == 0) {
                        filterLicense = '\''+hasLicense[i]+'\'';
                    } else {
                        filterLicense += ',\''+hasLicense[i]+'\'';
                    }
                    
                }
                String query = 'SELECT Id, Indicator_Code__c, License_Type__c FROM T_Performance_Indicator_License__c WHERE License_Type__c INCLUDES('+filterLicense+')';
                List<T_Performance_Indicator_License__c> productLicense = Database.query(query);
                Map<String,T_Performance_Indicator_License__c> productMapLicense = new Map<String,T_Performance_Indicator_License__c>();
                for(T_Performance_Indicator_License__c prodLicense : productLicense) {
                    productMapLicense.put(prodLicense.Indicator_Code__c,prodLicense);
                }
                
                List<AggregateResult> checkSaleProduct = [SELECT Indicator_Code__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Indicator_Code__c IN:productMapLicense.keySet() AND Month__c =: currMonthStr AND Year__c =: currYearStr GROUP BY Indicator_Code__c];
        
                for(String license : hasLicense) {
                    for(AggregateResult saleTrans : checkSaleProduct) {
                        List<String> selectedLicenses = productMapLicense.get(String.valueOf(saleTrans.get('Indicator_Code__c'))).License_Type__c.split(';');
                        if(selectedLicenses.contains(license)) {
                            if(license == 'LB' && licenses.Life_License_Status == null) {
                                licenses.Life_License_Status = 'Y';
                                break;
                            } else if(license == 'NLB' && licenses.Nonlife_License_Status == null) {
                                licenses.Nonlife_License_Status = 'Y';
                                break;
                            } else if(license == 'IC' && licenses.Fund_License_Status == null) {
                                licenses.Fund_License_Status = 'Y';
                                break;
                            } else if(license == 'UL' && licenses.Unitlink_License_Status == null) {
                                licenses.Unitlink_License_Status = 'Y';
                                break;
                            }
                        }
                    }
                }
            }
        }
        return licenses;
        
        
        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
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
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Sale_Performance__c> perfAggResultToSalePerf(List<AggregateResult> salePerfAggResult) {
        try{
        List<Sale_Performance__c> salePerformanceList = new List<Sale_Performance__c>();
        if(salePerfAggResult[0] != null) {
            Sale_Performance__c salePerformance = new Sale_Performance__c();
            salePerformance.Service_Target_Point__c = salePerfAggResult[0].get('Service_Target_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Service_Target_Point__c')));
            salePerformance.Service_Actual_Point__c = salePerfAggResult[0].get('Service_Actual_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Service_Actual_Point__c')));
            salePerformance.Customer_Point__c = salePerfAggResult[0].get('Customer_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Customer_Point__c')));
            salePerformance.People_Point__c = salePerfAggResult[0].get('People_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('People_Point__c')));
            salePerformance.Operation_Point__c = salePerfAggResult[0].get('Operation_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Operation_Point__c')));
            salePerformance.Financial_Actual_Point__c = salePerfAggResult[0].get('Financial_Actual_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Financial_Actual_Point__c')));
            salePerformance.Financial_Target_Point__c = salePerfAggResult[0].get('Financial_Target_Point__c') == null ? null : Decimal.valueOf(String.valueOf(salePerfAggResult[0].get('Financial_Target_Point__c')));
            salePerformanceList.add(salePerformance);
        }
        return salePerformanceList;

        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    private static lastAvailPerfWrapper getAvailPerfObj(String lastAvailPerfQuery, Date toDay, Boolean isIndividual){
        try{
        if(lastAvailPerfQuery != null) {
            lastAvailPerfWrapper retWrapper = new lastAvailPerfWrapper();
            List<Sale_Performance__c> lastAvailPerf = new List<Sale_Performance__c>();
            Integer targetMultipiler;
            Datetime nowTime = Datetime.now();
            // nowTime = Datetime.newInstance(2022, 1, 15); // ********* for testing only
            String currYearStr = nowTime.format('yyyy'); //****************** 
            String prevYearStr = nowTime.addYears(-1).format('yyyy');

            String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
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
            String lastAvailPerfMonth;
            String lastAvailPerfYear;
            String perfDateTimeCondition = '';
            String transDateTimeCondition = '';
            if(lastAvailPerf.size() > 0) {
                if(lastAvailPerf[0].Year__c != null) {
                    lastAvailPerfYear = lastAvailPerf[0].Year__c;
                    lastAvailPerfMonth = lastAvailPerf[0].Month__c;
                } else {
                    lastAvailPerf[0] = null;
                }
            }
            String monthCondition = toDay.month() < Integer.valueOf(oneMonthAgo) ? '12' : currMonthStr;

            if(lastAvailPerfYear == prevYearStr && (currMonthStr == '01' || currMonthStr == '02')) {
                // มีโอกาสที่เดือนปัจจุบันจะเป็น 1,2
                perfDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' ';
                
                if(currMonthStr == '01') {
                    targetMultipiler = 1;
                    transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c >= \'01\' AND Month__c <= \''+monthCondition+'\' ';
                } else if(currMonthStr == '02') {
                    List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c = '01' AND Year__c =: currYearStr LIMIT 1];
                    if(checkOtherPerf.size() > 0) {
                        targetMultipiler = 1;
                        transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c = \'02\' ';
                    } else {
                        targetMultipiler = 2;
                        transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c >= \'01\' AND Month__c <= \''+monthCondition+'\' ';
                    }
                }
            } else {
            // if(lastAvailPerfYear == currYearStr) {
                if(lastAvailPerfMonth == oneMonthAgo) {
                    perfDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c <= \''+oneMonthAgo+'\' ';
                    transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c > \''+oneMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                // } else if(lastAvailPerfMonth == twoMonthAgo) {
                    targetMultipiler = 1;
                } else if(lastAvailPerfMonth != null) {
                    
                    
                    List<Sale_Performance__c> checkOtherPerf = [SELECT Id FROM Sale_Performance__c WHERE Month__c =: oneMonthAgo AND Year__c =: currYearStr LIMIT 1];
                    if(checkOtherPerf.size() > 0) {
                        targetMultipiler = 1;
                        perfDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c <= \''+oneMonthAgo+'\' ';
                        transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c > \''+oneMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                    } else {
                        targetMultipiler = 2;
                        perfDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c <= \''+twoMonthAgo+'\' ';
                        transDateTimeCondition = ' AND Year__c = \''+currYearStr+'\' AND Month__c > \''+twoMonthAgo+'\' AND Month__c <= \''+monthCondition+'\' ';
                    }
                }
                
            } 
            retWrapper.availPerfObj = lastAvailPerf.size() > 0 ? lastAvailPerf[0] : null;
            retWrapper.availPerfMonth = lastAvailPerfMonth;
            retWrapper.availPerfYear = lastAvailPerfYear;
            retWrapper.perfDateTimeCondition = perfDateTimeCondition;
            retWrapper.transDateTimeCondition = transDateTimeCondition;
            retWrapper.targetMultipiler = targetMultipiler;

            return retWrapper;
        }
        return null;
        
        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class lastDataAvailWrapper {
        @AuraEnabled
        public Integer defaultYear;
        @AuraEnabled
        public Integer currYearDefaultMonth;
        @AuraEnabled
        public Integer prevYearDefaultMonth;
    }

    @AuraEnabled
    public static lastDataAvailWrapper getLastAvailData(String empId) {
        List<Sale_Info__c> lastSaleInfo = [SELECT Month__c,Year__c FROM Sale_Info__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
        // throw new AuraHandledException('ไม่พบข้อมูล User ใน Sale Info');
        
            
        List<Sale_Info__c> currSaleInfo = getSaleInfo(empId, 'year', null, null);
        if(currSaleInfo.size() > 0) {
            try {
                lastDataAvailWrapper lastDataWrapper = new lastDataAvailWrapper();
                Integer currYearDefaultMonth;
                Integer prevYearDefaultMonth;
                Integer defaultYear;

                Date toDay = Date.Today();
                Datetime toDayTime = Datetime.now();
                String currMonthStr = String.valueOf(toDay.month()).leftPad(2,'0');
                String currYearStr = toDayTime.format('yyyy');
                String prevYearStr = Datetime.now().addYears(-1).format('yyyy');

                List<Sale_Transaction__c> checkLastSaleTrans = new List<Sale_Transaction__c>();
                String twoMonthAgo = toDay.month()-2 > 0 ? String.valueOf(toDay.month()-2).leftPad(2,'0') : String.valueOf(12-(2-toDay.month())).leftPad(2,'0');
                
                // if(defaultYear == null) {
                    List<Sale_Transaction__c> lastYearSaleTran = new List<Sale_Transaction__c>();
                    if(lastSaleInfo[0].Month__c == currSaleInfo[0].Month__c && lastSaleInfo[0].Year__c == currSaleInfo[0].Year__c) {
                        // this sale still working
                        lastYearSaleTran = [SELECT Year__c, Month__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
                    }
                    
                    List<Sale_Performance__c> lastYearSalePerf = [SELECT Year__c, Month__c FROM Sale_Performance__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
                    if(lastYearSaleTran.size() > 0 && lastYearSalePerf.size() > 0) {
                        if(lastYearSaleTran[0].Year__c > lastYearSalePerf[0].Year__c) {
                            defaultYear = Integer.valueOf(lastYearSaleTran[0].Year__c);
                        } else {
                            defaultYear = Integer.valueOf(lastYearSalePerf[0].Year__c);
                        }
                    } else if(lastYearSaleTran.size() > 0) {
                        defaultYear = Integer.valueOf(lastYearSaleTran[0].Year__c);
                    } else if(lastYearSalePerf.size() > 0) {
                        defaultYear = Integer.valueOf(lastYearSalePerf[0].Year__c);
                    }
                // } 

                // lastDataAvailWrapper.defaultYear;
                
                // if(selectedYear == currYearStr) {
                    if(lastSaleInfo[0].Month__c == currSaleInfo[0].Month__c && lastSaleInfo[0].Year__c == currSaleInfo[0].Year__c) {
                        if(toDay.month() < 3) {
                            // last 2 month is previous year
                            checkLastSaleTrans = [SELECT Year__c, Month__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND ((Month__c >=: twoMonthAgo AND Year__c =: prevYearStr) OR Year__c =: currYearStr) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
                        } else {
                            checkLastSaleTrans = [SELECT Year__c, Month__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: currYearStr AND Month__c >=: twoMonthAgo ORDER BY Month__c DESC LIMIT 1];
                        }
                    }
            
                    if(checkLastSaleTrans.size() > 0) {
                        currYearDefaultMonth = Integer.valueOf(checkLastSaleTrans[0].Month__c);
                    } else {
                        List<Sale_Performance__c> checkLastSalePerf = [SELECT Year__c, Month__c FROM Sale_Performance__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
                        if(checkLastSalePerf.size() > 0) {
                            currYearDefaultMonth = Integer.valueOf(checkLastSalePerf[0].Month__c);
                        }
                    }
                // } else 
                // {
                    // previous year
                    if(lastSaleInfo[0].Month__c == currSaleInfo[0].Month__c && lastSaleInfo[0].Year__c == currSaleInfo[0].Year__c) {
                        //sale still working
                        checkLastSaleTrans = [SELECT Year__c, Month__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: prevYearStr ORDER BY Month__c DESC LIMIT 1];
                    }
                    List<Sale_Performance__c> checkLastSalePerf = [SELECT Year__c, Month__c FROM Sale_Performance__c WHERE Employee_ID__c =: empId AND Year__c =: prevYearStr ORDER BY Month__c DESC LIMIT 1];
                    if(checkLastSaleTrans.size() > 0 && checkLastSalePerf.size() > 0) {
                        if(checkLastSaleTrans[0].Month__c > checkLastSalePerf[0].Month__c) {
                            prevYearDefaultMonth = Integer.valueOf(checkLastSaleTrans[0].Month__c);
                        } else {
                            prevYearDefaultMonth = Integer.valueOf(checkLastSalePerf[0].Month__c);
                        }
                    } else if(checkLastSaleTrans.size() > 0) {
                        prevYearDefaultMonth = Integer.valueOf(checkLastSaleTrans[0].Month__c);
                    } else if(checkLastSalePerf.size() > 0) {
                        prevYearDefaultMonth = Integer.valueOf(checkLastSalePerf[0].Month__c);
                    }
                // }
                lastDataWrapper.defaultYear = defaultYear;
                lastDataWrapper.currYearDefaultMonth = currYearDefaultMonth;
                lastDataWrapper.prevYearDefaultMonth = prevYearDefaultMonth;
                return lastDataWrapper;
            } catch(Exception e) {
                // throw new AuraHandledException('Error: '+e);
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            throw new AuraHandledException('ไม่พบข้อมูล User ใน Sale Info');
        }
            
    }

    @AuraEnabled
    public static List<T_Performance_Sharepoint__mdt> getSharePointLink(){
        try{
        List<T_Performance_Sharepoint__mdt> sharePoint = [SELECT Id, SharePoint_Type__c, URL_Link__c FROM T_Performance_Sharepoint__mdt WHERE SharePoint_Type__c IN('Help','Branch Summary') LIMIT 2];
        return sharePoint;

        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static targetProductTableWrapper getTargetProductTable(String EmployeeId, String year, String month){
        try{
        targetProductTableWrapper targetProductTable = new targetProductTableWrapper();
        List<targetProductWrapper> productList = new List<targetProductWrapper>();
        
        String targetProductListQuery = 'SELECT id, Cap_Max_Pct__c, Channel__c, Employee_ID__c, Month__c, Product_Group__c, Product_Group_Code__c,	Product_List__c, Rank__c, Sub_Group_Flag__c, Name, 	Target_Point__c, Target_Unit__c, Unique_External_Key__c, Unit__c, Weight_Pct__c, Year__c '
        +' FROM T_Performance_Target_Product_by_Sales__c'
        +' WHERE Employee_ID__c = \''+EmployeeId+'\' AND Year__c = \''+year+'\'';
        if(month != null && month != '' ){
            targetProductListQuery += ' AND Month__c = \''+month+'\'';
        }
        targetProductListQuery += ' Order By Rank__c, Month__c'; 
        
        List<sObject> sobjListTarget = Database.query(targetProductListQuery);
        List<T_Performance_Target_Product_by_Sales__c> targetProductList = (List<T_Performance_Target_Product_by_Sales__c>)sobjListTarget;
        
        // select yearly : select product_Group last month and sumarget 
        if(month == null || month == ''){
            Map<String,T_Performance_Target_Product_by_Sales__c> targetProductMap = new Map<String,T_Performance_Target_Product_by_Sales__c>();
            for (T_Performance_Target_Product_by_Sales__c targetProduct : targetProductList) {
                if (targetProduct.Product_Group_Code__c != '' && targetProduct.Product_Group_Code__c != null ) {
                    T_Performance_Target_Product_by_Sales__c targetProductToMap = new T_Performance_Target_Product_by_Sales__c();
                    if (targetProductMap.containsKey(targetProduct.Product_Group_Code__c)) {
                        targetProductToMap = targetProductMap.get(targetProduct.Product_Group_Code__c);

                        Decimal targetUnit;
                        if (targetProductToMap.Target_Unit__c != null && targetProduct.Target_Unit__c != null) {
                            targetUnit = targetProductToMap.Target_Unit__c + targetProduct.Target_Unit__c;
                        }
                        // merge product_List
                        Set<String> product_List_Set = new Set<String>();
                        for (String product : (targetProductToMap.Product_List__c + targetProduct.Product_List__c).split(';')) {
                            if(product != '' && product != null){
                                product_List_Set.add(product);
                            }
                        }
                        
                        // Update  Last Month
                        targetProductToMap = targetProduct;
                        targetProductToMap.Target_Unit__c = targetUnit;
                        targetProductToMap.Product_List__c = String.join(new List<String>(product_List_Set), ';') + ';' ;

                        targetProductMap.put(targetProduct.Product_Group_Code__c, targetProductToMap);
                    }else {
                        targetProductMap.put(targetProduct.Product_Group_Code__c, targetProduct);
                    }
                }
            }

            List<T_Performance_Target_Product_by_Sales__c> newTargetProductList = (List<T_Performance_Target_Product_by_Sales__c>)targetProductMap.values();
            T_Performance_Target_Product_by_Sales__c temp = new T_Performance_Target_Product_by_Sales__c();
            for (Integer i = 0; i < newTargetProductList.size() - 1 ; i++) {
                Integer indexMin = i;
                for (Integer j = i+1; j <= newTargetProductList.size() - 1 ; j++) {
                    if (newTargetProductList[j].Rank__c < newTargetProductList[indexMin].Rank__c) {
                        indexMin = j;
                    }
                }
                temp = newTargetProductList[i];
                newTargetProductList[i] = newTargetProductList[indexMin];
                newTargetProductList[indexMin] = temp;
            }
            targetProductList = newTargetProductList;

        }

        // Indicator_Code Set to query
        Set<String> indicatorSet = new Set<String>();
        List<String> indicatorList = new List<String>();
        for (T_Performance_Target_Product_by_Sales__c targetProduct : targetProductList) {
            for (String indicator : (targetProduct.Product_List__c).split(';')) {
                if(indicator != '' && indicator != null){
                    indicatorSet.add(indicator);
                }
            }
        }
        indicatorList.addAll(indicatorSet);
        
        String actualPerformanceQuery =  'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Employee_ID__c, Sale_Name__c, Indicator_Code__c, Actual_Point__c, Actual_Performance__c'
        +' FROM Sale_Transaction__c'
        +' WHERE Employee_ID__c = \''+EmployeeId+'\' AND Year__c = \''+year+'\'';
        if(month != null && month != ''){
            actualPerformanceQuery += ' AND Month__c = \''+month+'\'';
        }
        if (indicatorList.size() != 0) {
            actualPerformanceQuery += ' AND Indicator_Code__c IN:indicatorList';
        }
        actualPerformanceQuery += ' Order By Indicator_Code__c';
        
        List<sObject> sobjListActual = Database.query(actualPerformanceQuery);
        List<Sale_Transaction__c> actualPerformanceList = (List<Sale_Transaction__c>)sobjListActual;

        // ### Sum Actual_Performance Map
        Map<String,Decimal> sumActualPerformanceMap = new Map<String,Decimal>();
        for (Sale_Transaction__c actualPerformance : actualPerformanceList) {
            Decimal value = 0;
            if (actualPerformance.Actual_Performance__c != null) {
                if (sumActualPerformanceMap.containsKey(actualPerformance.Indicator_Code__c)) {
                    value = sumActualPerformanceMap.get(actualPerformance.Indicator_Code__c);
                    value += actualPerformance.Actual_Performance__c;
                }else {
                    value = actualPerformance.Actual_Performance__c;
                }
                sumActualPerformanceMap.put(actualPerformance.Indicator_Code__c, value);
            }
        }      
        
        // ### Create Table
        Decimal summaryAchivement = 0;
        for (T_Performance_Target_Product_by_Sales__c targetProduct : targetProductList) {
            // ### Sum Actual_Performance of each indicator_Code
            Decimal sumActualOfEachIndicator = 0;
            for (String indicator : (targetProduct.Product_List__c).split(';')) {
                if (indicator != '' && indicator != null) {
                    if (sumActualPerformanceMap.containsKey(indicator)) {
                        sumActualOfEachIndicator += sumActualPerformanceMap.get(indicator);
                    }
                }
            }

            targetProductWrapper product = new targetProductWrapper();
            product.totalFinance = targetProduct.Product_Group__c;
            product.productGroupCode = targetProduct.Product_Group_Code__c;
            product.unit = targetProduct.Unit__c;
            product.weightKPIs = targetProduct.Weight_Pct__c;
            product.targetUnit = targetProduct.Target_Unit__c;
            product.subGroupFlag = targetProduct.Sub_Group_Flag__c;
            product.actualUnit = sumActualOfEachIndicator;
            product.successUnit = (product.actualUnit / product.targetUnit)*100;
            product.rank = targetProduct.Rank__c;
            Decimal percentMultipiler = 1;

            if(product.weightKPIs == null) {
                product.achivement = null;
            } else {
                percentMultipiler = product.weightKPIs/100;
                product.achivement = product.successUnit * percentMultipiler;
                if(product.achivement > targetProduct.Cap_Max_Pct__c && targetProduct.Cap_Max_Pct__c != null){
                    product.achivement = targetProduct.Cap_Max_Pct__c;
                }
            }

            if(!targetProduct.Sub_Group_Flag__c) {
                summaryAchivement += product.achivement;
            }
            
            productList.add(product);
        }
        targetProductTable.productList = productList;

        targetProductTable.grandTotal = summaryAchivement;
        return targetProductTable;

        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }



    public class chunkQueryWrapper {
        @AuraEnabled
        public Integer chunkSize = 35000;
        @AuraEnabled
        public Id lastRecordId;
        @AuraEnabled
        public Boolean isEndRecord;
        @AuraEnabled
        public String fieldList;
        @AuraEnabled
        public String queryObject;
        @AuraEnabled
        public String condition;
        @AuraEnabled
        public List<sObject> resultRecords;
    }

    @AuraEnabled
    public static chunkQueryWrapper chunkQuery(Object queryWrapperObj) {
        try {
        chunkQueryWrapper queryWrapper = (chunkQueryWrapper)JSON.deserialize(JSON.serialize(queryWrapperObj), chunkQueryWrapper.class);
        if(queryWrapper.fieldList != null && queryWrapper.queryObject != null) {
            String defaultQuery = 'SELECT '+queryWrapper.fieldList+' FROM '+queryWrapper.queryObject+' ';
            String query = defaultQuery;
            
            queryWrapper.isEndRecord = true;
            Integer chunkSize = queryWrapper.chunkSize;
            if(queryWrapper.lastRecordId == null) {
                // first time
                String condition = queryWrapper.condition == null ? '' : queryWrapper.condition;
                query = query+condition+' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
            } else {
                if(queryWrapper.condition == null) {
                    query = query+' WHERE Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                } else {
                    query = query+queryWrapper.condition+' AND Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT '+String.valueOf(chunkSize);
                }
            }
            List<sObject> resultRecords = Database.query(query);
            Integer dataRow = resultRecords.size();
            if(dataRow >= chunkSize) {
                queryWrapper.lastRecordId = resultRecords[dataRow-1].Id;
                List<Object> checkNext = new List<Object>();
                String checkNextQuery = '';
                if(queryWrapper.condition == null) { 
                    checkNextQuery = defaultQuery+' WHERE Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT 1';
                } else {
                    checkNextQuery = defaultQuery+queryWrapper.condition+' AND Id > \''+queryWrapper.lastRecordId+'\' ORDER BY Id LIMIT 1';
                }
                checkNext = Database.query(checkNextQuery);
                if(checkNext.size() > 0) {
                    queryWrapper.isEndRecord = false;
                }
            }

            queryWrapper.resultRecords = resultRecords;
        }
        return queryWrapper;
            
        } catch (Exception e) {
            System.debug('Error:'+e);
            // throw new AuraHandledException(' '+e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}