public class AccountPlanPortfolioPerformanceCtrl {
    private ApexPages.StandardController standardController {get;set;}
    public String CompanyID {get;set;}  
    public String PortfolioID {get;set;}
    
    public boolean isDisabled {get;set;}
    public String messagePortPerformanceNoData { get { 
        //String messageNoData = 'Projected performance data are not yet generated so the report has no data.';
        String messageNoData = Account_Plan_Status_Code__c.GetValues('0014').Status_Message__c;
        return messageNoData; }}
    
    public integer NoOfGroup {get; set;} 
    public AcctPlanPortfolio__c portfolio {get;set;}
    public AcctPlanProdStrategy__c refreshProductStrategy {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public List<AcctPlanCompanyProfile__c> lstCompanyProfile {get;set;}
    
    public integer TotalTableRow {get;set;}
    public Map<Decimal,String> TableLabel {get;set;}
    public Map<String/*Name*/,List<Decimal>> GroupWallets {get; set;}         
    public Map<String/*Name*/,List<Decimal>> GroupTotalNI {get; set;}  
    public Map<String/*Name*/,List<Decimal>> GroupTotalNIByEachGroup {get; set;}
    public Map<String,Decimal> mapFeeGroupWallets {get;set;}
    public Map<String,Decimal> mapFeeGroupTotalNI {get;set;}
    public Map<String,List<Decimal>> mapFeeGroupTotalNIByEachGroup {get;set;}
    public Map<Id,AcctPlanGroupProfile__c> mapAcctPlanGroupProfile {get;set;}
    public Map<Id,String> mapGropProfileIds {get;set;}
    
    public Map<string,string> GroupNameMap {get; set;}
    public transient Decimal totalGroupWalletSizing {get;set;}
    public transient Decimal totalTargetByPortfolio {get;set;}
    public transient Decimal totalGroupTotalNI {get;set;}     
    public transient Decimal percentTargetAchievement {get;set;} 
    
    public Map<Decimal,Decimal> totalGroupTotalNIByEachGroup {get;set;} 
    public String year {get;set;} 
    public String portfolioOwnerName {get;set;} 
    public Boolean isStep6 {get;set;}
    
    public AccountPlanPortfolioPerformanceCtrl(ApexPages.StandardController controller){
    standardController = controller;
        
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        PortfolioID = ApexPages.currentPage().getParameters().get('PortID');       
                           
        AcctPlanPortfolioPerformanceCtrl();        
        
    }
    
    public pageReference Refreshfunction(){ 
        
        TotalTableRow = 0;
        TableLabel = null;
        GroupNameMap = null;
        
        GroupWallets = null;
        GroupTotalNI = null;    
        GroupTotalNIByEachGroup = null;
        
        totalGroupWalletSizing = 0;
        totalTargetByPortfolio = 0;
        totalGroupTotalNI = 0;        
        percentTargetAchievement = 0;
        totalGroupTotalNIByEachGroup = null;
        
        mapFeeGroupWallets = null;
        mapFeeGroupTotalNI = null;
        mapFeeGroupTotalNIByEachGroup = null;
        
        Boolean refreshResult = AccountPlanRefreshService.RefreshPortfolioPerformanceProductStrategyForStep0(PortfolioID);      
        
        if(refreshResult){
            AcctPlanPortfolioPerformanceCtrl();
        }
                        
        return null;
    }
    
    public void AcctPlanPortfolioPerformanceCtrl(){
        isStep6 = false;
        
        if(PortfolioID !=null && PortfolioID !=''){

            
            portfolio = AccountPlanUtilities.QueryPortfolioByID(PortfolioID);
            year = portfolio.Year__c;
            portfolioOwnerName = portfolio.SalesOwner__r.Name;  
              
            lstCompanyProfile = [Select Id, Name,AccountName__c, OwnerId, Year__c 
                                 From AcctPlanCompanyProfile__c
                                 Where OwnerId =: portfolio.OwnerId 
                                 AND Year__c =: portfolio.Year__c]; 
            //lstCompanyProfile = AccountPlanCompanyProfileSelector.getCompanyProfileIdByPortfolioIds(new Set<Id>{ PortfolioID });
        
        }else if(CompanyID !=null && CompanyID !=''){
            
            isStep6 = true;
                companyprofile = [Select Id, Year__c, AcctPlanGroup__c,
                                OwnerId, Owner.Name,Portfolio__c,Portfolio__r.TargetNI__c
                                From AcctPlanCompanyProfile__c 
                                Where ID =: CompanyID];     
            
            year = companyprofile.Year__c;
            portfolioOwnerName = companyprofile.Owner.Name;
                            
            lstCompanyProfile = [Select Id, Name,AccountName__c, OwnerId, Year__c 
                                 From AcctPlanCompanyProfile__c
                                 Where OwnerId =: companyprofile.OwnerId 
                                 AND Year__c =: companyprofile.Year__c]; 
        }
        
        if(lstCompanyProfile.size() > 0){
            Map<Id,AcctPlanCompanyProfile__c>  mapLstCompanyProfile = new Map<Id,AcctPlanCompanyProfile__c>(lstCompanyProfile);
            
            List<AcctPlanWallet__c> lstWallets =  AccountPlanWalletSelector.getWalletByCompanyProfileIds(mapLstCompanyProfile.keySet());
            
            if(lstWallets.size() > 0){
                
                totalGroupWalletSizing = 0;
                totalTargetByPortfolio = 0;
                totalGroupTotalNI = 0;
                percentTargetAchievement = 0;
                totalGroupTotalNIByEachGroup = null;
                
                AggregateResult[] prodStrategyResults = 
                    AccountPlanProductStrategySelector.selectProductStrategyPortfolioPerformanceByCompanyIds(mapLstCompanyProfile.keySet());
                
                if(prodStrategyResults.size() > 0){
                    
                    AcctPlanGroupProfileInfo(prodStrategyResults);                    
                    calculateTotalTableRowInScreen(prodStrategyResults);
                    calculateFeeGroupTotalNIByEachGroup(prodStrategyResults);
                    initGroupInfo(prodStrategyResults);
                    calculateGroupTotalNIByEachGroup(GroupTotalNIByEachGroup);
                    calculateTotalValues(prodStrategyResults);  
                }                                             
                
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, messagePortPerformanceNoData)); 
                isDisabled = true;
            }              
        }else{
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, messagePortPerformanceNoData)); 
            isDisabled = true;
        }        
    }
       
    private void AcctPlanGroupProfileInfo(AggregateResult[] prodStrategyResults){
        for (AggregateResult ar : prodStrategyResults){                         
            if(mapGropProfileIds == null) mapGropProfileIds = new Map<Id,String>();
            
            String arGroupProfileID = String.valueOf(ar.get('AcctPlanGroupProfileID__c'));
            if(arGroupProfileID != null && arGroupProfileID != ''){            
                mapGropProfileIds.put(arGroupProfileID, arGroupProfileID);
            }                                      
        }
        
        for(AcctPlanGroupProfile__c groupProfile : 
            [Select Id,Name,Year__c,Group__c,Group__r.Name
             From AcctPlanGroupProfile__c 
             Where Id IN : mapGropProfileIds.keySet()]){      
                 
                 if(mapAcctPlanGroupProfile == null) mapAcctPlanGroupProfile = new Map<Id,AcctPlanGroupProfile__c>();
                 if(!mapAcctPlanGroupProfile.containsKey(groupProfile.Id)){
                     mapAcctPlanGroupProfile.put(groupProfile.Id, groupProfile);
                 }
             }                          
    }  
    
    private void calculateTotalValues(AggregateResult[] prodStrategyResults){
        if(refreshProductStrategy == null) refreshProductStrategy = new AcctPlanProdStrategy__c();  
        /*========= Fixed issue Target By Portfolio is not same step 0===========*/
        if(portfolio != null){
            totalTargetByPortfolio = portfolio.TargetNI__c;
        }else if(companyprofile != null){
            totalTargetByPortfolio = companyprofile.Portfolio__r.TargetNI__c;
        } 
        //totalTargetByPortfolio = portfolio.TargetNI__c != 0 ? portfolio.TargetNI__c : 0;
        
        if(prodStrategyResults.size() > 0){
            
            totalGroupWalletSizing = GroupWallets.get('1. NIIc')[0] + GroupWallets.get('2. NIId')[0] + GroupWallets.get('3. Fee')[0];  
            totalGroupTotalNI = GroupTotalNI.get('1. NIIc')[0] + GroupTotalNI.get('2. NIId')[0] + GroupTotalNI.get('3. Fee')[0];
            percentTargetAchievement = totalTargetByPortfolio == 0 ? 0 : (totalGroupTotalNI / totalTargetByPortfolio);
                               
            if(mapGropProfileIds.size() > 0){
                List<AcctPlanProdStrategy__c> prodStrategy = [SELECT Id, RefreshAsOf__c FROM AcctPlanProdStrategy__c 
                                                        WHERE AcctPlanGroupProfileID__c IN: mapGropProfileIds.keySet() 
                                                        AND RefreshAsOf__c != NULL ORDER BY RefreshAsOf__c DESC LIMIT 1];
                
                if(prodStrategy.size() > 0){ refreshProductStrategy = prodStrategy[0]; }
            }             
        }
    }
          
    private void calculateTotalTableRowInScreen(AggregateResult[] prodStrategyResults){
        if(TotalTableRow == null) TotalTableRow =0;   
        if(TableLabel == null) TableLabel = new Map<Decimal,String>();
               
        Integer row = 1;
        for (AggregateResult ar : prodStrategyResults){
            String arName = String.valueOf(ar.get('Name'));
            
            if(row <=3){
                if(!TableLabel.containsKey(row)){
                    TableLabel.put(row, arName);
                }
            }else if(row > 3 && row <= 8){
                if(!TableLabel.containsKey(row+1)){
                    TableLabel.put(row+1, arName);
                }
            }else if(row > 8 && row <= 12){
                if(!TableLabel.containsKey(10+row)){
                    TableLabel.put((10+row), arName);
                }                
            }else if(row == 13){
                if(!TableLabel.containsKey(row)){
                    TableLabel.put(10, arName);
                }
            }else if(row == 14){
                if(!TableLabel.containsKey(row)){
                    TableLabel.put(4, arName);
                }
            }          
            
            row++;
        }   
        TotalTableRow = TableLabel.size();        
    }  

    //Sum Fee : add to '3. Fee' row.     
    private void calculateFeeGroupTotalNIByEachGroup(AggregateResult[] prodStrategyResults){
        if(mapFeeGroupWallets == null) mapFeeGroupWallets = new Map<String,Decimal>();
        if(mapFeeGroupTotalNI == null) mapFeeGroupTotalNI = new Map<String,Decimal>(); 
        if(mapFeeGroupTotalNIByEachGroup == null) mapFeeGroupTotalNIByEachGroup = new Map<String,List<Decimal>>();
                
        Decimal totalWalletsizing = 0;
        Decimal totalNI = 0;  
        for (AggregateResult ar : prodStrategyResults){
            
            String arName = String.valueOf(ar.get('Name'));
            
            //Walletsizing
            String arWalletSizing = String.valueOf(ar.get('WalletSizing')) == null ? '0' : String.valueOf(ar.get('WalletSizing'));
            Decimal walletSizing = Decimal.valueOf(arWalletSizing);
            
            //Total NI
            String arTotalCompanyNI = String.valueOf(ar.get('TotalCompanyNI'));
            Decimal totalCompanyNI = Decimal.valueOf(arTotalCompanyNI);
            
            if(arName == '3.1 TF Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI; 
            }else if(arName == '3.2 FX Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.3 L/G Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;  
            }else if(arName == '3.4 Cash Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.5 AS Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.6 Credit Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.7 BA Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.8 Derivative Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }else if(arName == '3.9 IB Fee'){
                totalWalletsizing += walletSizing;              
                totalNI += totalCompanyNI;
            }  
              
            String arGroupProfileID = String.valueOf(ar.get('AcctPlanGroupProfileID__c'));
            if(arGroupProfileID != null && arGroupProfileID != ''){            
                
                if(!mapFeeGroupTotalNIByEachGroup.containsKey(arGroupProfileID)){
                    mapFeeGroupTotalNIByEachGroup.put(arGroupProfileID,new List<Decimal>());                     
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(0);  
                }
                
                if(arName == '3.1 TF Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.2 FX Fee'){                    
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.3 L/G Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.4 Cash Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.5 AS Fee'){                    
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI; 
                }else if(arName == '3.6 Credit Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.7 BA Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.8 Derivative Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI;
                }else if(arName == '3.9 IB Fee'){
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID).add(totalCompanyNI); 
                    mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0] += totalCompanyNI; 
                }        
            }
        }          
        
        mapFeeGroupTotalNI.put('3. Fee', totalNI);
        mapFeeGroupWallets.put('3. Fee', totalWalletsizing);
    }
    
    private void initGroupInfo(AggregateResult[] prodStrategyResults){
        if(GroupNameMap ==null) GroupNameMap = new Map<string,string>();
        
        if(GroupWallets ==null) GroupWallets = new Map<String/*typeName*/,List<Decimal>>(); 
        if(GroupTotalNI ==null) GroupTotalNI = new Map<String/*typeName*/,List<Decimal>>();
        if(GroupTotalNIByEachGroup ==null) GroupTotalNIByEachGroup = new Map<String/*typeName*/,List<Decimal>>();
        
        Integer row = 1;        
        for (AggregateResult ar : prodStrategyResults){
            
            String arName = String.valueOf(ar.get('Name'));
            
            /*----------------Walletsizing-----------------*/            
            String arWalletSizing = String.valueOf(ar.get('WalletSizing')) == null ? '0' : String.valueOf(ar.get('WalletSizing'));
            Decimal walletSizing = Decimal.valueOf(arWalletSizing);
            
            if(!GroupWallets.containsKey(arName)){
                GroupWallets.put(arName,new List<Decimal>());
                
                //Wallet sizing (Yearly)
                GroupWallets.get(arName).add(0);                
            }
            
            GroupWallets.get(arName).add(walletSizing);
            
            if(arName == '3. Fee'){                
                GroupWallets.get(arName)[0] = mapFeeGroupWallets.get(arName);
            }else{ GroupWallets.get(arName)[0] += walletSizing; }   
            
            
            /*----------------NI-----------------*/
            String arTotalCompanyNI = String.valueOf(ar.get('TotalCompanyNI'));
            Decimal totalCompanyNI = Decimal.valueOf(arTotalCompanyNI);
            
            if(!GroupTotalNI.containsKey(arName)){
                GroupTotalNI.put(arName, new List<Decimal>());
                
                //Total NI (Portfolio basis)  
                GroupTotalNI.get(arName).add(0);
            }
            
            //Total NI (Portfolio basis)
            if(arName == '3. Fee'){                
                GroupTotalNI.get(arName)[0] = mapFeeGroupTotalNI.get(arName);
            }else{ GroupTotalNI.get(arName)[0] += totalCompanyNI; }   
            
            String arGroupProfileID = String.valueOf(ar.get('AcctPlanGroupProfileID__c'));
            if(arGroupProfileID != null && arGroupProfileID != ''){
                
                AcctPlanGroupProfile__c groupProfile = mapAcctPlanGroupProfile.get(arGroupProfileID);
                
                //Find Group Name
                if(!GroupNameMap.containsKey(groupProfile.Id)){
                    GroupNameMap.put(groupProfile.Id, groupProfile.Name);             
                }           
                
                /*----------------NI-----------------*/                                        
                if(!GroupTotalNIByEachGroup.containsKey(arName)){
                    GroupTotalNIByEachGroup.put(arName, new List<Decimal>());
                }
                
                if(arName == '3. Fee'){
                    GroupTotalNIByEachGroup.get(arName).add(mapFeeGroupTotalNIByEachGroup.get(arGroupProfileID)[0]);                  
                }else{ GroupTotalNIByEachGroup.get(arName).add(totalCompanyNI); }               
            }            
            row++;           
        }             
        
        NoOfGroup = GroupNameMap.size();          
    }

    private void calculateGroupTotalNIByEachGroup(Map<String/*SEQ*/,List<Decimal>> GroupTotalNIByEachGroup){
        if(totalGroupTotalNIByEachGroup == null) totalGroupTotalNIByEachGroup = new Map<Decimal,Decimal>(); 
        
        for(integer startIdx = 0; startIdx < NoOfGroup;  startIdx++){
            Decimal total=
                /*1. NIIc */ GroupTotalNIByEachGroup.get('1. NIIc')[startIdx] + 
                /*2. NIId */ GroupTotalNIByEachGroup.get('2. NIId')[startIdx] + 
                /*3. Fee  */ GroupTotalNIByEachGroup.get('3. Fee')[startIdx];
            
            Decimal idx = (Decimal)startIdx;                     
            totalGroupTotalNIByEachGroup.put(idx,total);              
        }              
    }    
}