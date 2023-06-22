public class T_Performance_P2Controller {

    public class productWrapper{
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Year;
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public String Sale_Team;
        @AuraEnabled
        public String Zone; 
        @AuraEnabled
        public String Region;
        @AuraEnabled
        public String Channel;
        @AuraEnabled
        public String Book_Service_Branch;
        @AuraEnabled
        public String Employee_ID;
        @AuraEnabled
        public String Indicator_Code_Level1;
        @AuraEnabled
        public String Indicator_Code_Level2;
        @AuraEnabled
        public String Indicator_Code; 
        @AuraEnabled
        public String Indicator_Level1;
        @AuraEnabled
        public String Indicator_Level2; 
        @AuraEnabled
        public String Indicator_Name; 
        @AuraEnabled
        public String Indicator_Rank;
        @AuraEnabled
        public String Sale_Point_Engine; 
        @AuraEnabled
        public Decimal Sale_Volume; 
        @AuraEnabled
        public String Sale_Unit;
        @AuraEnabled
        public Decimal Actual_Performance;
        @AuraEnabled
        public Decimal Actual_Point;
        @AuraEnabled
        public Date KPI_Date;
        @AuraEnabled
        public String Customer_Number;
        @AuraEnabled
        public String Reference_Number1;
        @AuraEnabled
        public String Reference_Number2;
        @AuraEnabled
        public Date Deduct_Date;
        @AuraEnabled
        public Decimal Deduct_Point;
        @AuraEnabled
        public String Deduct_Flag;
        @AuraEnabled
        public Decimal Deduct_Actual_Point;
        @AuraEnabled
        public String Unique_External_Key;
        @AuraEnabled
        public String CustomerName;
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

    public class PerformanceWrapperP2{
        @AuraEnabled
        public Sale_Info__c saleInfo;
        // @AuraEnabled
        // public List<productWrapper> salesTransaction;
        @AuraEnabled
        public Decimal appIncentive;
        // @AuraEnabled
        // public Integer totalTransRow;
        @AuraEnabled
        public LicenseWrapper licenses;
    }

    @AuraEnabled
    public static PerformanceWrapperP2 getPerformanceDataP2(String empId, Integer startRow, Integer endRow, Integer selectedMonth, String selectedYear)
    {
        try { 
            // System.debug('selected month'+selectedMonth);
            PerformanceWrapperP2 performanceWrapper = new PerformanceWrapperP2();
            String selectedMonthStr = selectedMonth == null ? null : String.valueOf(selectedMonth).leftPad(2,'0');
            // empId = '82827';
            if(empId == null) {
                User currentUser = [SELECT Id, FirstName, LastName, RTL_Branch__c, RTL_Branch_Code__c, UserRoleName__c,RTL_Channel__c, Employee_ID__c FROM User WHERE Id =: UserInfo.getUserId()];
                empId = currentUser.Employee_ID__c;
            }

            List<User> licenseInfoLst = [SELECT Id, RTL_License_No_ICP_1__c, RTL_License_No_Complex_P2__c, RTL_License_No_ICP_3__c, RTL_License_No_Paper_5__c, RTL_License_No_ICT__c, RTL_License_No_Paper_4__c, RTL_License_No_Paper_1__c, RTL_License_No_IP__c, RTL_License_No_Life_Insurance__c, RTL_License_No_Non_Life_Insurance__c, RTL_License_No_Wealthy_Link__c, RTL_Expiry_Date_Wealthy_Link__c, RTL_Active_Flag_Wealthy_Link__c, RTL_License_No_Unit_Link__c, RTL_Expiry_Date_Unit_Link__c, RTL_Active_Flag_Unit_Link__c, RTL_Expiry_Date_ICP_1__c, RTL_Expiry_Date_Complex_P2__c, RTL_Expiry_Date_ICP_3__c, RTL_Expiry_Date_Paper_5__c, RTL_Expiry_Date_ICT__c, RTL_Expiry_Date_Paper_4__c, RTL_Expiry_Date_Paper_1__c, RTL_Expiry_Date_IP__c, RTL_Expiry_Date_Life_Insurance__c, RTL_Expiry_Date_Non_Life_Insurance__c FROM User WHERE Employee_ID__c =: empId];
            
            List<Sale_Info__c> saleInfo = [SELECT Id, Name, Branch_Name__c, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                            Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c 
                                            FROM Sale_Info__c WHERE Employee_ID__c =: empId ORDER BY Year__c DESC, Month__c DESC LIMIT 1];

            Date toDay = Date.Today();
            LicenseWrapper licenses = new LicenseWrapper();
            if(saleInfo.size() > 0) {
                licenses = getLicenses(licenseInfoLst, empId);
            }

            String groupFilter = '';
            // if(saleInfo.get(0).Channel__c == 'Branch') {
                groupFilter = ' AND Employee_ID__c = \''+empId+'\' ';   
            // } else {
            //     groupFilter = ' AND Channel__c = \''+saleInfo.get(0).Channel__c+'\' ';
            // }

            String currMonthStr = String.valueOf(toDay.month());
                if(toDay.month() < 10) {
                    currMonthStr = '0'+String.valueOf(toDay.month());
                }
            String currYearStr = Datetime.now().format('yyyy');
            String cpyGroupFilter = groupFilter.replace('AND', 'WHERE');
            List<AggregateResult> sumActPoint = new List<AggregateResult>();
            try {
                String sumTransActQuery = 'SELECT SUM(Actual_Point__c) Sum_Point FROM Sale_Transaction__c WHERE Year__c =: currYearStr AND Month__c =: currMonthStr '+groupFilter;
                sumActPoint = Database.query(sumTransActQuery);
            } catch(DmlException e) {
                System.debug('sum act point null '+ e.getMessage());
            }
            
            String selectYear = Datetime.now().format('yyyy');
            Integer previousMonth = toDay.month()-1;
            String previousMonthStr = String.valueOf(previousMonth);
            
            if(previousMonth < 1) {
                // privous year
                previousMonth = 12;
                selectYear = Datetime.now().addYears(-1).format('yyyy');
            }
            
            if(previousMonth < 10) {
                previousMonthStr = '0'+String.valueOf(previousMonth);
            }
            String selectYearStr = selectYear;
            // System.debug('previousMonth '+ previousMonth);
            // System.debug('selectYearStr '+ selectYearStr);
            String lastMonthPerfQuery = 'SELECT Sum(Target_Point__c) Sum_Target_Point, Sum(Financial_Target_Point__c) Sum_Fi_Target_Point FROM Sale_Performance__c WHERE Year__c =: selectYearStr AND Month__c =: previousMonthStr '+groupFilter;
            List<AggregateResult> lastMonthPerf = Database.query(lastMonthPerfQuery);
            // System.debug('lastMonthPerf '+ lastMonthPerf);
            // System.debug('lastMonthPerfQuery '+ lastMonthPerfQuery);

            // startRow = startRow-1 < 0 ? 0 : (startRow-1);

            // String filterStr = '';
            // if(keyValueFilter != null) {
            //     if(keyTypeFilter == 'lv1') {
            //         filterStr = ' AND Indicator_Level1__c=\''+keyValueFilter+'\' ';
            //     } else if(keyTypeFilter == 'lv2') {
            //         filterStr = ' AND Indicator_Level2__c=\''+keyValueFilter+'\' ';
            //     } else if(keyTypeFilter == 'name') {
            //         filterStr = ' AND Indicator_Name__c=\''+keyValueFilter+'\' ';
            //     }
            // }

            // String transRowQuery;
            // String query;
            // if(selectedMonthStr == null) {
            //     // data as of year
            //     transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear '+filterStr;
            //     query = 'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c FROM Sale_Transaction__c WHERE Year__c =: selectedYear AND Employee_ID__c = \''+empId+'\' '+filterStr+' ORDER BY KPI_Date__c DESC LIMIT '+(endRow-startRow)+' OFFSET '+ startRow;
            // } else {
            //     // data as of month
            //     transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear AND Month__c =: selectedMonthStr '+filterStr;
            //     query = 'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c FROM Sale_Transaction__c WHERE Year__c =: selectedYear AND Month__c =: selectedMonthStr AND Employee_ID__c = \''+empId+'\' '+filterStr+' ORDER BY KPI_Date__c DESC LIMIT '+(endRow-startRow)+' OFFSET '+ startRow;
            // }
            // List<AggregateResult> transRow = Database.query(transRowQuery);
            // List<sObject> saleTransaction = Database.query(query);
            // List<productWrapper> saleTransaction = getProductList(empId, keyValueFilter, keyTypeFilter, selectedMonth, selectedYear);

            Integer percentSuccess = null;
            Decimal appIncentive = null;
            Decimal incentiveTargetPoint;
            if(lastMonthPerf[0].get('Sum_Target_Point') == null) {
                Integer previous2Month = toDay.month()-2;
                String previous2MonthStr = String.valueOf(previous2Month);
                String selectYearStr2 = Datetime.now().format('yyyy');
                if(previous2Month < 1) {
                    // privous year
                    previous2Month = 11;
                    selectYearStr2 = Datetime.now().addYears(-1).format('yyyy');
                }
                if(previous2Month < 10) {
                    previous2MonthStr = '0'+String.valueOf(previous2Month);
                }
                String last2MonthPerfQuery = 'SELECT Sum(Target_Point__c) Sum_Target_Point, Sum(Financial_Target_Point__c) Sum_Fi_Target_Point FROM Sale_Performance__c WHERE Year__c =: selectYearStr2 AND Month__c =: previous2MonthStr '+groupFilter;
                List<AggregateResult> last2MonthPerf = Database.query(last2MonthPerfQuery);
                incentiveTargetPoint = last2MonthPerf[0].get('Sum_Target_Point') == null ? null : Decimal.valueOf(String.valueOf(last2MonthPerf[0].get('Sum_Target_Point')));
            } else {
                incentiveTargetPoint = Decimal.valueOf(String.valueOf(lastMonthPerf[0].get('Sum_Target_Point')));
            }

            // System.debug('sumActPoint: '+ sumActPoint);
            // System.debug('channel: '+ saleInfo.get(0).Channel__c);
            // System.debug(sumActPoint.size());
            // System.debug('sumActPoint[0].get(Sum_Point) != null: '+ sumActPoint[0].get('Sum_Point'));
            // System.debug('incentiveTargetPoint != null: '+ incentiveTargetPoint );

            if(saleInfo.get(0).Channel__c == 'Branch' && sumActPoint.size() > 0 && sumActPoint[0].get('Sum_Point') != null && incentiveTargetPoint != null) {
                Decimal actualPoint = Decimal.valueOf(String.valueOf(sumActPoint[0].get('Sum_Point')));
                //Decimal targetPoint = Decimal.valueOf(String.valueOf(lastMonthPerf[0].get('Sum_Target_Point')));
                
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
                // ******************** custom setting/multipiler opject
            }
            performanceWrapper.saleInfo = saleInfo.size() > 0 ? saleInfo.get(0) : null;
            // performanceWrapper.salesTransaction = saleTransaction;
            performanceWrapper.appIncentive = appIncentive;
            // performanceWrapper.totalTransRow = transRow.size() > 0 ? Integer.valueOf(transRow[0].get('Trans_Row')) : null;
            performanceWrapper.licenses = licenses;
            return performanceWrapper;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
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
                
                
                // licenses.Fund_License_Status = toDay <= licenseInfo.RTL_Expiry_Date_Paper_1__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_Paper_4__c ? 'Y' : 
                // (toDay <= licenseInfo.RTL_Expiry_Date_Paper_5__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_ICP_1__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_Complex_P2__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_ICP_3__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_IP__c ? 'Y' : 
                // (toDay <= licenseInfo.RTL_Expiry_Date_ICT__c ? 'Y' : 'N')))))));
                
                
                licenses.Unitlink_License = licenseInfo.RTL_License_No_Wealthy_Link__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Wealthy_Link__c && licenseInfo.RTL_Active_Flag_Wealthy_Link__c ? licenseInfo.RTL_License_No_Wealthy_Link__c : 
                licenseInfo.RTL_License_No_Unit_Link__c != null && toDay <= licenseInfo.RTL_Expiry_Date_Unit_Link__c && licenseInfo.RTL_Active_Flag_Unit_Link__c ? licenseInfo.RTL_License_No_Unit_Link__c : null;
                if(licenses.Fund_License != null) hasLicense.add('UL');
                
            
                // licenses.Unitlink_License_Status = toDay <= licenseInfo.RTL_Expiry_Date_Wealthy_Link__c && licenseInfo.RTL_Active_Flag_Wealthy_Link__c ? 'Y' :
                // (toDay <= licenseInfo.RTL_Expiry_Date_Unit_Link__c && licenseInfo.RTL_Active_Flag_Unit_Link__c ? 'Y' : 'N');
            // }
                if(hasLicense.size() > 0) {
                    for(Integer i = 0; i < hasLicense.size(); i++) {
                        if(i == 0) {
                            filterLicense = '\''+hasLicense[i]+'\'';
                        } else {
                            filterLicense += ',\''+hasLicense[i]+'\'';
                        }
                        
                    }
                    String query = 'SELECT Id, Indicator_Code__c, License_Type__c FROM T_Performance_Indicator_License__c WHERE License_Type__c INCLUDES('+filterLicense+')';
                    System.debug('query: '+query);
                    List<T_Performance_Indicator_License__c> productLicense = Database.query(query);
                    // System.debug('productLicense: '+JSON.serializePretty(productLicense));
                    Map<String,T_Performance_Indicator_License__c> productMapLicense = new Map<String,T_Performance_Indicator_License__c>();
                    for(T_Performance_Indicator_License__c prodLicense : productLicense) {
                        productMapLicense.put(prodLicense.Indicator_Code__c,prodLicense);
                    }
                    // System.debug('productMapLicense: '+JSON.serializePretty(productMapLicense));
                    List<AggregateResult> checkSaleProduct = [SELECT Indicator_Code__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Indicator_Code__c IN:productMapLicense.keySet() AND Month__c =: currMonthStr AND Year__c =: currYearStr GROUP BY Indicator_Code__c];
                    List<Sale_Transaction__c> checkSaleProductDebug = [SELECT Indicator_Code__c FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Indicator_Code__c IN:productMapLicense.keySet()];
                    // System.debug('checkSaleProductDebug: '+JSON.serializePretty(checkSaleProductDebug));
                    // System.debug('checkSaleProduct: '+JSON.serializePretty(checkSaleProduct));
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
            throw new AuraHandledException(e.getMessage());
          }

        
        
    }

    @AuraEnabled
    public static List<productWrapper> getProductList(String empId, String keyValueFilter, String keyTypeFilter, Integer selectedMonth, String selectedYear){
        // startRow = startRow-1 < 0 ? 0 : (startRow-1);
        try{
            String filterStr = '';
            if(keyValueFilter != null) {
                if(keyTypeFilter == 'lv1') {
                    filterStr = ' AND Indicator_Level1__c=\''+keyValueFilter+'\' ';
                } else if(keyTypeFilter == 'lv2') {
                    filterStr = ' AND Indicator_Level2__c=\''+keyValueFilter+'\' ';
                } else if(keyTypeFilter == 'name') {
                    filterStr = ' AND Indicator_Name__c=\''+keyValueFilter+'\' ';
                }
            }

            // String transRowQuery;
            // String query;
            // if(selectedMonthStr == null) {
            //     // data as of year
            //     transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear '+filterStr;
            //     query = 'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c FROM Sale_Transaction__c WHERE Year__c =: selectedYear AND Employee_ID__c = \''+empId+'\' '+filterStr+' ORDER BY KPI_Date__c DESC LIMIT '+(endRow-startRow)+' OFFSET '+ startRow;
            // } else {
            //     // data as of month
            //     transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear AND Month__c =: selectedMonthStr '+filterStr;
            //     query = 'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c FROM Sale_Transaction__c WHERE Year__c =: selectedYear AND Month__c =: selectedMonthStr AND Employee_ID__c = \''+empId+'\' '+filterStr+' ORDER BY KPI_Date__c DESC LIMIT '+(endRow-startRow)+' OFFSET '+ startRow;
            // }
            // List<AggregateResult> transRow = Database.query(transRowQuery);
            // List<sObject> saleTransaction = Database.query(query);
            String query = 'SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c FROM Sale_Transaction__c WHERE Year__c =: selectedYear AND Employee_ID__c = \''+empId+'\' '+filterStr;
            List<Sale_Transaction__c> saleTransaction = Database.query(query);

            List<productWrapper> productList = new List<productWrapper>();
            Set<String> cusNoList = new Set<String>();
            for(Sale_Transaction__c saleTrans : saleTransaction) {
                productWrapper product = new productWrapper();

                cusNoList.add(saleTrans.Customer_Number__c);

                product.Id = saleTrans.Id;
                product.Name = saleTrans.Name;
                product.Year = saleTrans.Year__c;
                product.Month = saleTrans.Month__c;
                product.Sale_Team = saleTrans.Sale_Team__c;
                product.Zone = saleTrans.Zone__c;
                product.Region = saleTrans.Region__c;
                product.Channel = saleTrans.Channel__c;
                product.Book_Service_Branch = saleTrans.Book_Service_Branch__c;
                product.Employee_ID = saleTrans.Employee_ID__c;
                product.Indicator_Code_Level1 = saleTrans.Indicator_Code_Level1__c;
                product.Indicator_Code_Level2 = saleTrans.Indicator_Code_Level2__c;
                product.Indicator_Code = saleTrans.Indicator_Code__c;
                product.Indicator_Level1 = saleTrans.Indicator_Level1__c;
                product.Indicator_Level2  = saleTrans.Indicator_Level2__c;
                product.Indicator_Name  = saleTrans.Indicator_Name__c;
                product.Indicator_Rank = saleTrans.Indicator_Rank__c;
                product.Sale_Point_Engine = saleTrans.Sale_Point_Engine__c;
                product.Sale_Volume = saleTrans.Sale_Volume__c;
                product.Sale_Unit = saleTrans.Sale_Unit__c;
                product.Actual_Performance = saleTrans.Actual_Performance__c;
                product.Actual_Point = saleTrans.Actual_Point__c;
                product.KPI_Date = saleTrans.KPI_Date__c;
                product.Customer_Number = saleTrans.Customer_Number__c;
                product.Reference_Number1 = saleTrans.Reference_Number1__c;
                product.Reference_Number2 = saleTrans.Reference_Number2__c;
                product.Deduct_Date = saleTrans.Deduct_Date__c;
                product.Deduct_Point = saleTrans.Deduct_Point__c;
                product.Deduct_Flag = saleTrans.Deduct_Flag__c;
                product.Deduct_Actual_Point = saleTrans.Deduct_Actual_Point__c;
                product.Unique_External_Key = saleTrans.Unique_External_Key__c;

                productList.add(product);
            }

            Map<String,Account> productMapCust = new Map<String,Account>();
            List<Account> custList = new List<Account>([SELECT Id, TMB_Customer_ID_PE__c, Name FROM Account WHERE TMB_Customer_ID_PE__c =: cusNoList]);
            for(Account cust : custList) {
                productMapCust.put(cust.TMB_Customer_ID_PE__c,cust);
            }

            for(productWrapper product : productList) {
                if(productMapCust.containsKey(product.Customer_Number)) {
                    Account cust = productMapCust.get(product.Customer_Number);
                    product.CustomerName = cust.Name;
                }
            }
            // System.debug(productList);
            return productList;

        }catch (Exception e) {
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

    public class chunkQueryWrapper {
        // @AuraEnabled
        // public String query;
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
        // @AuraEnabled
        // public Decimal sumPerfPoint;
        // @AuraEnabled
        // public Decimal totalTarget;
        // @AuraEnabled
        // public Decimal newAvgBankWide;
    }

    @AuraEnabled
    public static chunkQueryWrapper chunkQuery(Object queryWrapperObj) {
        System.debug('debug chunk query'+queryWrapperObj);
        try {
        chunkQueryWrapper queryWrapper = (chunkQueryWrapper)JSON.deserialize(JSON.serialize(queryWrapperObj), chunkQueryWrapper.class);
        if(queryWrapper.fieldList != null && queryWrapper.queryObject != null) {
            String defaultQuery = 'SELECT '+queryWrapper.fieldList+' FROM '+queryWrapper.queryObject+' ';
            String query = defaultQuery;
            
            queryWrapper.isEndRecord = true;
            Integer chunkSize = queryWrapper.chunkSize;
            System.debug(queryWrapper.condition);
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
            System.debug('debug query records '+query);
            List<sObject> resultRecords = Database.query(query);
            System.debug('test');
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
                // System.debug('debug check next '+checkNextQuery);
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