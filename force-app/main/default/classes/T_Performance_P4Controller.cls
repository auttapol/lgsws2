public with sharing class T_Performance_P4Controller {
    
    public class PerformanceWrapper{
        @AuraEnabled
        public Map<String,List<Branch_Performance_by_Pillar__c>> branchPerformance;
        @AuraEnabled
        public List<Team_Profile_and_KPI__c> teamProfile;
        @AuraEnabled
        public List<Sale_Info__c> saleInfo;
        @AuraEnabled
        public List<Sale_Performance__c> salePerformance;
        @AuraEnabled
        public List<Sale_Transaction__c> salesTransaction;
        @AuraEnabled
        public List<Branch_Performance_by_Pillar__c> lastBranchperformance;
        @AuraEnabled
        public List<Team_Profile_and_KPI__c> lastTeamprofile;
        @AuraEnabled
        public List<Sale_Performance__c> lastSaleperformance;
        @AuraEnabled
        public List<Sale_Info__c> lastSaleInfo;
        @AuraEnabled
        public List<Sale_Info__c> lastSaleInOut;
    }


    public class BranchPerformWrapper{
        @AuraEnabled
        public String indecatorName;
        @AuraEnabled
        public String sumActual;
        @AuraEnabled
        public String salesUnit;
        @AuraEnabled
        public String latestYear;
        @AuraEnabled
        public String latestMonth;
        @AuraEnabled
        public List<Sale_Transaction__c> latestSaletransaction;
    }

    public class BankWide{
        @AuraEnabled
        public Integer InBankWide;
        @AuraEnabled
        public Integer OutBankWide;
        
    }

    public class HelpAndSummary{
        @AuraEnabled
        public string sharePoint;
    }
    

    @AuraEnabled
    public static PerformanceWrapper getPerformanceData(String branchCode)
    {
        try {
            Integer d = Date.today().month();
            String year = Datetime.now().format('yyyy');
            String lastYear = String.valueOf(Integer.valueOf(year) - 1);
            // String lastMonth = '0' + (d-1);
            // String monthT = '0' + d;
            PerformanceWrapper performanceWrapper = new PerformanceWrapper();
            List<Branch_Performance_by_Pillar__c> branchPerformance = [SELECT Id, Name, Year__c, Month__c, Branch_Team_Code__c, Indicator_Parent_Name__c, Indicator_Name__c, Indicator_Rank__c, KPI_Value__c, Channel__c 
                                                                        FROM Branch_Performance_by_Pillar__c WHERE Branch_Team_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear)];

            List<Team_Profile_and_KPI__c> teamProfile = [SELECT Id, Name, Year__c, Month__c, Branch_Team_Code__c, Team_Name_EN__c, Team_Name_TH__c, Hub_Code__c, Hub_Name__c, Region_Code__c, Region__c, Branch_Type__c, 
                                                        Branch_Tier__c, Working_Day__c, Office_Hour__c, Address__c, Phone__c, Total_Customer__c, KPI__c, Average_Bankwide__c, Rank_Zone__c, Rank_Region__c, Rank_Bankwide__c, 
                                                        Number_of_Outbound_Sales_Bankwide__c, Number_of_Inbound_Sales_Bankwide__c, Number_of_Branch_Zone__c, Number_of_Branch_Region__c, Number_of_Branch_Bankwide__c, Outbound_Sale_Rank_Bankwide__c, 
                                                        Inbound_Sale_Rank_Bankwide__c, Total_Active_Customer__c, Total_Mainbank_Customer__c, Net_Promoter_Score__c, Branch_Transaction__c, ATM_Transaction__c, Digital_Transaction__c, Total_Transaction__c, Zone_Code__c, Zone__c, Channel__c 
                                                        FROM Team_Profile_and_KPI__c WHERE Branch_Team_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear)];

            List<Sale_Info__c> saleInfo = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                            Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c,Year__c, Month__c 
                                            FROM Sale_Info__c WHERE Branch_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear)];

            List<Sale_Performance__c> salePerformance = [SELECT Id, Name, Year__c, Month__c, Employee_ID__c, Sale_Type__c, Position__c, Work_Type__c, Sale_Branch_Code__c, Zone__c, Region__c, Team_Name__c, Channel__c, Number_of_Customer__c, Actual_Point__c, Target_Point__c, 
                                                        Target_Other_Point__c, Percent_Success__c, Variance__c, Percent_Success_YTD__c, Service_Target_Point__c, Service_Actual_Point__c, Financial_Actual_Point__c, People_Point__c, Operation_Point__c, Customer_Point__c, Financial_Target_Point__c, 
                                                        Monthly_Performance__c, Yearly_Performance__c, Rank_Bankwide__c FROM Sale_Performance__c WHERE Sale_Branch_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear)];

            List<Sale_Transaction__c> saleTransaction = [SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, 
                                                        Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, 
                                                        Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c 
                                                        FROM Sale_Transaction__c WHERE Sale_Team__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ];

            List<Team_Profile_and_KPI__c> lastTeamProfile = [SELECT Id, Name, Year__c, Month__c, Branch_Team_Code__c, Team_Name_EN__c, Team_Name_TH__c, Hub_Code__c, Hub_Name__c, Region_Code__c, Region__c, Branch_Type__c, 
                                                        Branch_Tier__c, Working_Day__c, Office_Hour__c, Address__c, Phone__c, Total_Customer__c, KPI__c, Average_Bankwide__c, Rank_Zone__c, Rank_Region__c, Rank_Bankwide__c, 
                                                        Number_of_Outbound_Sales_Bankwide__c, Number_of_Inbound_Sales_Bankwide__c, Number_of_Branch_Zone__c, Number_of_Branch_Region__c, Number_of_Branch_Bankwide__c, Outbound_Sale_Rank_Bankwide__c, 
                                                        Inbound_Sale_Rank_Bankwide__c, Total_Active_Customer__c, Total_Mainbank_Customer__c, Net_Promoter_Score__c, Branch_Transaction__c, ATM_Transaction__c, Digital_Transaction__c, Total_Transaction__c, Zone_Code__c, Zone__c, Channel__c 
                                                        FROM Team_Profile_and_KPI__c WHERE Branch_Team_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            
            List<Branch_Performance_by_Pillar__c> lastBranchPerformance = [SELECT Id, Name, Year__c, Month__c, Branch_Team_Code__c, Indicator_Parent_Name__c, Indicator_Name__c, Indicator_Rank__c, KPI_Value__c, Channel__c 
                                                                    FROM Branch_Performance_by_Pillar__c WHERE Branch_Team_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            
            List<Sale_Performance__c> lastSalePerformance = [SELECT Id, Name, Year__c, Month__c, Employee_ID__c, Sale_Type__c, Position__c, Work_Type__c, Sale_Branch_Code__c, Zone__c, Region__c, Team_Name__c, Channel__c, Number_of_Customer__c, Actual_Point__c, Target_Point__c, 
                                                        Target_Other_Point__c, Percent_Success__c, Variance__c, Percent_Success_YTD__c, Service_Target_Point__c, Service_Actual_Point__c, Financial_Actual_Point__c, People_Point__c, Operation_Point__c, Customer_Point__c, Financial_Target_Point__c, 
                                                        Monthly_Performance__c, Yearly_Performance__c, Rank_Bankwide__c FROM Sale_Performance__c WHERE Sale_Branch_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            
            List<Sale_Info__c> lastSaleInfo = [SELECT Id, Name, Sale_Type__c, Position__c, Work_Type__c, BM_Expected__c, Team_Name__c, Zone__c, Region__c, Channel__c, CYC_Grade__c, HL_Grade__c, SME_Grade__c, Fund_Grade__c, Life_Grade__c, Deposit_Grade__c, 
                                            Number_of_Customer__c, Sale_Hire_Date__c, Employee_ID__c, Branch_Code__c ,Year__c, Month__c
                                            FROM Sale_Info__c WHERE Branch_Code__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            
            List<Sale_Info__c>  lastSaleInOut = [SELECT Year__c, Month__c FROM Sale_Info__c WHERE  Channel__c =:  'Branch' AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            
            Map<String,List<Branch_Performance_by_Pillar__c>> branchPerformanceMap = new Map<String,List<Branch_Performance_by_Pillar__c>>();
            if(branchPerformance.size() > 0)
            {
                for(Branch_Performance_by_Pillar__c bp : branchPerformance)
                {                
                    if(branchPerformanceMap.containsKey(bp.Indicator_Parent_Name__c.replace(' ','_')))
                    {
                        branchPerformanceMap.get(bp.Indicator_Parent_Name__c.replace(' ','_')).add(bp);
                    }           
                    else {
                        branchPerformanceMap.put(bp.Indicator_Parent_Name__c.replace(' ','_'),new List<Branch_Performance_by_Pillar__c>());
                        branchPerformanceMap.get(bp.Indicator_Parent_Name__c.replace(' ','_')).add(bp);
                    }      
                }
            }
            performanceWrapper.branchPerformance = branchPerformanceMap.size() > 0 ? branchPerformanceMap : null;
            performanceWrapper.teamProfile = teamProfile.size() > 0 ? teamProfile : null;
            performanceWrapper.saleInfo = saleInfo.size() > 0 ? saleInfo : null;
            performanceWrapper.salePerformance = salePerformance.size() > 0 ? salePerformance : null;
            performanceWrapper.salesTransaction = saleTransaction.size() > 0 ? saleTransaction : null;
            performanceWrapper.lastTeamprofile = lastTeamprofile.size() > 0 ? lastTeamprofile : null;
            performanceWrapper.lastBranchperformance = lastBranchperformance.size() > 0 ? lastBranchperformance : null;
            performanceWrapper.lastSaleperformance = lastSaleperformance.size() > 0 ? lastSaleperformance : null;
            performanceWrapper.lastSaleInfo = lastSaleInfo.size() > 0 ? lastSaleInfo : null;
            performanceWrapper.lastSaleInOut = lastSaleInOut.size() > 0 ? lastSaleInOut : null;
            return performanceWrapper;
        } catch (Exception e) {
            System.debug('Error:'+e);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static List<BranchPerformWrapper> getSumActual(String branchCode){
        try {
            Integer d = Date.today().month();
            String year = Datetime.now().format('yyyy');
            String lastYear = String.valueOf(Integer.valueOf(year) - 1);
            String latestYear;
            String latestMonth;
            List<Sale_Transaction__c> latestSaletransaction = [SELECT Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, 
                                                        Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, 
                                                        Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c 
                                                        FROM Sale_Transaction__c WHERE Sale_Team__c =: branchCode AND (Year__c=: year OR Year__c=: lastYear) ORDER BY Year__c DESC, Month__c DESC LIMIT 1];
            for( Sale_Transaction__c item : latestSaleTransaction ){
                latestYear = item.Year__c;
                latestMonth = item.Month__c;
            }
            List<BranchPerformWrapper> brancPerformList = new List<BranchPerformWrapper>();
            List<AggregateResult> sumVolume = [SELECT Indicator_Name__c, SUM(Actual_Performance__c ) sumOf, Sale_Unit__c FROM Sale_Transaction__c WHERE Sale_Team__c=:branchCode AND Year__c=: latestYear AND Month__c =:latestMonth GROUP BY Indicator_Name__c, Sale_Unit__c ];
            for(AggregateResult i : sumVolume){
                BranchPerformWrapper b = new BranchPerformWrapper();
                b.indecatorName = String.valueOf(i.get('Indicator_Name__c'));
                b.sumActual = String.valueOf(i.get('sumOf'));
                b.salesUnit = String.valueOf(i.get('Sale_Unit__c'));
                b.latestYear = latestYear;
                b.latestMonth = latestMonth;
                brancPerformList.add(b);
            }
            return brancPerformList;
        } catch (Exception e) {
            System.debug('Error:'+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static BankWide getSaleInOut(String year, String month){
        try {
            
            Integer numberOfIn = 0;
            Integer numberOfOut = 0;
            BankWide sumSaleInOut = new BankWide();
          
            List<Sale_Info__c> saleType = [SELECT Sale_Type__c, Year__c, Month__c FROM Sale_Info__c WHERE Channel__c =:  'Branch' AND Year__c =:year AND Month__c =:month];
            for (Sale_Info__c i : saleType){
          
                if (i.Sale_Type__c == 'Sale In'){
                    numberOfIn++; 
                }
                if (i.Sale_Type__c == 'Sale Out'){
                    numberOfOut++; 
                }
           }
            sumSaleInOut.InBankWide = numberOfIn;
            sumSaleInout.OutBankWide = numberOfOut;
           
            return sumSaleInOut;                      

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<T_Performance_Sharepoint__mdt> getHelpAndSummary(){
        try{
           List<T_Performance_Sharepoint__mdt> sharePoint = [SELECT Id, SharePoint_Type__c, URL_Link__c FROM T_Performance_Sharepoint__mdt WHERE SharePoint_Type__c IN('Help','Branch Summary') LIMIT 2]; 
           return sharePoint;
           
        } catch (Exception e){
          throw new AuraHandledException(e.getMessage());
        }
        
    }


    @AuraEnabled
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        try{
            User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
            string userEmpId = loginUser.Employee_ID__c;
            return userEmpId;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }    
    }
}