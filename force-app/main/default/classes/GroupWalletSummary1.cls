/*****************************************************************************************
*  NOTE : GroupWallet & Group Performance Summary
*
******************************************************************************************/

global without sharing class GroupWalletSummary1 implements Database.Batchable<sObject> ,Database.AllowsCallouts{
    
    public string m_year {get;set;}
    public id m_groupId {get;set;} 
    public id m_groupProfileId {get;set;}
    public Set<Id> m_accountWithAccountPlan    {get;set;}
    public Set<Id> m_accountWithoutAccountPlan {get;set;}
    public Boolean m_isGroupWallet {get;set;}
    public String SEQString(Decimal seq){
        String SEQStringReturn = '0';
        if(seq == 1){
            SEQStringReturn = '1';
        }else if(seq == 2){
            SEQStringReturn = '2';
        }else if(seq == 3){
            SEQStringReturn = '3';
        }else if(seq == 4){
            SEQStringReturn = '4';
        }else if(seq == 5){
            SEQStringReturn = '5';
        }else if(seq == 6){
            SEQStringReturn = '6';
        }else if(seq == 7){
            SEQStringReturn = '7';
        }else if(seq == 8){
            SEQStringReturn = '8';
        }else if(seq == 9){
            SEQStringReturn = '9';
        }else if(seq == 10){
            SEQStringReturn = '10';
        }else if(seq == 11){
            SEQStringReturn = '11';
        }else if(seq == 12){
            SEQStringReturn = '12';
        }else if(seq == 13){
            SEQStringReturn = '13';
        }else if(seq == 14){
            SEQStringReturn = '14';
        }
        return SEQStringReturn;
    }
    
    global GroupWalletSummary1(Set<Id> accountWithAccountPlan,Set<Id> accountWithoutAccountPlan,Id groupId,string year,id groupProfileId,Boolean isGroupWallet) {
        m_year = year;
        m_groupId = groupId;
        m_groupProfileId = groupProfileId;
        m_accountWithAccountPlan = accountWithAccountPlan;
        m_accountWithoutAccountPlan = accountWithoutAccountPlan;
        m_isGroupWallet = isGroupWallet;
    }

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){  
        //Query AcctPlanProdStrategy__c for Summary
        Set<Id> accountIdsSet = this.m_accountWithoutAccountPlan ;
        return Database.getQueryLocator([SELECT Id, Name ,Account_Plan_Flag__c,  Group__c,Group__r.Name ,Owner.Segment__c   
            FROM Account 
            WHERE    Id IN : accountIdsSet 
                                         ]);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Account> scopeAccount){
        Set<id> accountIds = new Set<id>();
        system.debug('scopeAccount='+scopeAccount.size());
         for(Account item : scopeAccount){
            accountIds.add(item.Id);
         }
        List<AcctPlanProdStrategyPort__c> scope = [SELECT AccountId_PE__c,AccountId__c,AccountName__c,AccountPlanYear__c,
                                        Adjust_NI__c,AnnualizedPerformance__c,AsOfDate__c,AspirationSOW__c,CompareSOW__c,ExistingSOW__c,
                                        ExpectedIncrementalNIFreeText__c,ExpectedIncrementalNIFromStep5__c,ExpectedIncrementalNI__c,
                                        ExpectedSOWPercent__c,GroupCompany__c,Id,Name,SEQ__c,TotalCompanyNI__c,WalletSizing__c,Year__c
                                         FROM AcctPlanProdStrategyPort__c  
                                         WHERE AccountId__c IN :accountIds
                                         AND Year__c = :this.m_year
                                         //AND AcctPlanCompanyProfileID__r.isActive__c =true
                                         ORDER BY AccountId__c,SEQ__c
                                         ];
        // Logic to be Executed batch wise   
        /**********************************************************************
        *  Step initiate Sum Group Wallet Sizing (Yearly)
        ***********************************************************************/  
        if(scope.size()>0){
        List<AccountPlanWalletSizing__c> SumWalletSizingList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                    WHERE Group__c = :this.m_groupId
                                    AND Year__c = :this.m_year
                                    AND SummaryType__c  = 'WalletSizing' LIMIT 1];
        AccountPlanWalletSizing__c SumWalletSizing = new AccountPlanWalletSizing__c();
        if(SumWalletSizingList.size()>0){
            SumWalletSizing = SumWalletSizingList.get(0);
        }else{
            SumWalletSizing.NIIc__c = 0;
            SumWalletSizing.NIId__c = 0;
            SumWalletSizing.Fee__c = 0;
            SumWalletSizing.RecurringFee__c ='';
            SumWalletSizing.TFFee__c = 0;
            SumWalletSizing.FXFee__c = 0;
            SumWalletSizing.LGFee__c = 0;
            SumWalletSizing.CashFee__c = 0;
            SumWalletSizing.ASFee__c = 0;
            SumWalletSizing.NonRecurringFee__c ='';
            SumWalletSizing.CreditFee__c = 0;
            SumWalletSizing.BAFee__c = 0;
            SumWalletSizing.DerivativeFee__c = 0;
            SumWalletSizing.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum Group's Actual NI (12-mth Rolling)
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumActualNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ActualNI' LIMIT 1];
        AccountPlanWalletSizing__c SumActualNI = new AccountPlanWalletSizing__c();
        if(SumActualNIList.size()>0){
            SumActualNI = SumActualNIList.get(0);
        }else{
            SumActualNI.NIIc__c = 0;
            SumActualNI.NIId__c = 0;
            SumActualNI.Fee__c = 0;
            SumActualNI.RecurringFee__c ='';
            SumActualNI.TFFee__c = 0;
            SumActualNI.FXFee__c = 0;
            SumActualNI.LGFee__c = 0;
            SumActualNI.CashFee__c = 0;
            SumActualNI.ASFee__c = 0;
            SumActualNI.NonRecurringFee__c ='';
            SumActualNI.CreditFee__c = 0;
            SumActualNI.BAFee__c = 0;
            SumActualNI.DerivativeFee__c = 0;
            SumActualNI.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapActualNIRolling = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){
            //system.debug('SEQ='+item.SEQ__c);
            String SEQ = SEQString(item.SEQ__c);
            if(item.AnnualizedPerformance__c == null){
                item.AnnualizedPerformance__c = 0;
            }
            if(!MapActualNIRolling.containsKey(SEQ)){
                MapActualNIRolling.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => item.AnnualizedPerformance__c});
            }else{
                MapActualNIRolling.get(SEQ).put(item.AccountId__c ,item.AnnualizedPerformance__c);
            }   
        }
        
        /**********************************************************************
        *  Step initiate Sum Group's Adjusted NI (12-mth Rolling) 
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumAdjustedNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'AdjustedNI' LIMIT 1];
        AccountPlanWalletSizing__c SumAdjustedNI = new AccountPlanWalletSizing__c();
        if(SumAdjustedNIList.size()>0){
            SumAdjustedNI = SumAdjustedNIList.get(0);
        }else{
            SumAdjustedNI.NIIc__c = 0;
            SumAdjustedNI.NIId__c = 0;
            SumAdjustedNI.Fee__c = 0;
            SumAdjustedNI.RecurringFee__c ='';
            SumAdjustedNI.TFFee__c = 0;
            SumAdjustedNI.FXFee__c = 0;
            SumAdjustedNI.LGFee__c = 0;
            SumAdjustedNI.CashFee__c = 0;
            SumAdjustedNI.ASFee__c = 0;
            SumAdjustedNI.NonRecurringFee__c ='';
            SumAdjustedNI.CreditFee__c = 0;
            SumAdjustedNI.BAFee__c = 0;
            SumAdjustedNI.DerivativeFee__c = 0;
            SumAdjustedNI.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapAdjustedNI = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){
            String SEQ = SEQString(item.SEQ__c);
            if(item.Adjust_NI__c == null){
                item.Adjust_NI__c  = 0;
            }
            if(!MapAdjustedNI.containsKey(SEQ)){
                MapAdjustedNI.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => item.Adjust_NI__c });
            }else{
                //Product strategy port set as 0
                MapAdjustedNI.get(SEQ).put(item.AccountId__c ,0);
            }
        }
        
        /**********************************************************************
        *  Step initiate Sum % Aspiration SOW 
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumAspirationSOWList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'AspirationSOW' LIMIT 1];
        AccountPlanWalletSizing__c SumAspirationSOW = new AccountPlanWalletSizing__c();
        if(SumAspirationSOWList.size()>0){
            SumAspirationSOW = SumAspirationSOWList.get(0);
        }else{
            SumAspirationSOW.NIIc__c = 0;
            SumAspirationSOW.NIId__c = 0;
            SumAspirationSOW.Fee__c = 0;
            SumAspirationSOW.RecurringFee__c ='';
            SumAspirationSOW.TFFee__c = 0;
            SumAspirationSOW.FXFee__c = 0;
            SumAspirationSOW.LGFee__c = 0;
            SumAspirationSOW.CashFee__c = 0;
            SumAspirationSOW.ASFee__c = 0;
            SumAspirationSOW.NonRecurringFee__c ='';
            SumAspirationSOW.CreditFee__c = 0;
            SumAspirationSOW.BAFee__c = 0;
            SumAspirationSOW.DerivativeFee__c = 0;
            SumAspirationSOW.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum Expected Incremental NI(Unit: THB)
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumExpectedIncrementalNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExpectedIncrementalNI' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedIncrementalNI = new AccountPlanWalletSizing__c();
        if(SumExpectedIncrementalNIList.size()>0){
            SumExpectedIncrementalNI = SumExpectedIncrementalNIList.get(0);
        }else{
            SumExpectedIncrementalNI.NIIc__c = 0;
            SumExpectedIncrementalNI.NIId__c = 0;
            SumExpectedIncrementalNI.Fee__c = 0;
            SumExpectedIncrementalNI.RecurringFee__c ='';
            SumExpectedIncrementalNI.TFFee__c = 0;
            SumExpectedIncrementalNI.FXFee__c = 0;
            SumExpectedIncrementalNI.LGFee__c = 0;
            SumExpectedIncrementalNI.CashFee__c = 0;
            SumExpectedIncrementalNI.ASFee__c = 0;
            SumExpectedIncrementalNI.NonRecurringFee__c ='';
            SumExpectedIncrementalNI.CreditFee__c = 0;
            SumExpectedIncrementalNI.BAFee__c = 0;
            SumExpectedIncrementalNI.DerivativeFee__c = 0;
            SumExpectedIncrementalNI.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapExpectedIncrementalNI = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){
            String SEQ = SEQString(item.SEQ__c);
            decimal ExpectedIncrementalNIValue =0;                                                                      
                if (item.SEQ__c == 9.00 || item.SEQ__c == 13.00 || item.SEQ__c == 14.00) {
                    ExpectedIncrementalNIValue = item.ExpectedIncrementalNIFreeText__c == null ? 0 : item.ExpectedIncrementalNIFreeText__c;
                }else {
                    ExpectedIncrementalNIValue = item.ExpectedIncrementalNI__c == null ? 0 : item.ExpectedIncrementalNI__c;
                }
            if(!MapExpectedIncrementalNI.containsKey(SEQ)){
                MapExpectedIncrementalNI.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => ExpectedIncrementalNIValue });
            }else{
                MapExpectedIncrementalNI.get(SEQ).put(item.AccountId__c ,ExpectedIncrementalNIValue );
            }
        }
        
        /**********************************************************************
        *  Step initiate Sum Expected Incremental NI from Step 5
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumExpectedIncrementalNIStep5List = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExpectedIncrementalNIStep5' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedIncrementalNIStep5 = new AccountPlanWalletSizing__c();
        if(SumExpectedIncrementalNIStep5List.size()>0){
            SumExpectedIncrementalNIStep5 = SumExpectedIncrementalNIStep5List.get(0);
        }else{
            SumExpectedIncrementalNIStep5.NIIc__c = 0;
            SumExpectedIncrementalNIStep5.NIId__c = 0;
            SumExpectedIncrementalNIStep5.Fee__c = 0;
            SumExpectedIncrementalNIStep5.RecurringFee__c ='';
            SumExpectedIncrementalNIStep5.TFFee__c = 0;
            SumExpectedIncrementalNIStep5.FXFee__c = 0;
            SumExpectedIncrementalNIStep5.LGFee__c = 0;
            SumExpectedIncrementalNIStep5.CashFee__c = 0;
            SumExpectedIncrementalNIStep5.ASFee__c = 0;
            SumExpectedIncrementalNIStep5.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep5.CreditFee__c = 0;
            SumExpectedIncrementalNIStep5.BAFee__c = 0;
            SumExpectedIncrementalNIStep5.DerivativeFee__c = 0;
            SumExpectedIncrementalNIStep5.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapExpectedIncrementalNIStep5 = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){
            String SEQ = SEQString(item.SEQ__c);
            if(item.ExpectedIncrementalNIFromStep5__c == null){
                item.ExpectedIncrementalNIFromStep5__c = 0;
            }
            if(!MapExpectedIncrementalNIStep5.containsKey(SEQ)){
                MapExpectedIncrementalNIStep5.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => item.ExpectedIncrementalNIFromStep5__c });
            }else{
                MapExpectedIncrementalNIStep5.get(SEQ).put(item.AccountId__c ,item.ExpectedIncrementalNIFromStep5__c );
            }   
        }
        
        /**********************************************************************
        *  Step initiate Total Group NI 
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> SumTotalCompanyNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'TotalCompanyNI' LIMIT 1];
        AccountPlanWalletSizing__c SumTotalCompanyNI = new AccountPlanWalletSizing__c();
        if(SumTotalCompanyNIList.size()>0){
            SumTotalCompanyNI = SumTotalCompanyNIList.get(0);
        }else{
            SumTotalCompanyNI.NIIc__c = 0;
            SumTotalCompanyNI.NIId__c = 0;
            SumTotalCompanyNI.Fee__c = 0;
            SumTotalCompanyNI.RecurringFee__c ='';
            SumTotalCompanyNI.TFFee__c = 0;
            SumTotalCompanyNI.FXFee__c = 0;
            SumTotalCompanyNI.LGFee__c = 0;
            SumTotalCompanyNI.CashFee__c = 0;
            SumTotalCompanyNI.ASFee__c = 0;
            SumTotalCompanyNI.NonRecurringFee__c ='';
            SumTotalCompanyNI.CreditFee__c = 0;
            SumTotalCompanyNI.BAFee__c = 0;
            SumTotalCompanyNI.DerivativeFee__c = 0;
            SumTotalCompanyNI.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapTotalCompanyNI = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){ 
            String SEQ = SEQString(item.SEQ__c);          
            if(!MapTotalCompanyNI.containsKey(SEQ)){
                MapTotalCompanyNI.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => item.TotalCompanyNI__c });
            }else{
                MapTotalCompanyNI.get(SEQ).put(item.AccountId__c ,item.TotalCompanyNI__c );
            }  
        }
        
        /**************************************************************************
        *  Step initiate Sum ExpectedIncrementalNIStep6 before Sum Aspiration SOW
        ***************************************************************************/
        List<AccountPlanWalletSizing__c> SumExpectedIncrementalNIStep6List = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                                              WHERE Group__c = :this.m_groupId
                                                                              AND Year__c = :this.m_year
                                                                              AND SummaryType__c  = 'ExpectedIncrementalNIStep6' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedIncrementalNIStep6 = new AccountPlanWalletSizing__c();
        if(SumExpectedIncrementalNIStep6List.size()>0){
            SumExpectedIncrementalNIStep6 = SumExpectedIncrementalNIStep6List.get(0);
        }else{
            SumExpectedIncrementalNIStep6.NIIc__c = 0;
            SumExpectedIncrementalNIStep6.NIId__c = 0;
            SumExpectedIncrementalNIStep6.Fee__c = 0;
            SumExpectedIncrementalNIStep6.RecurringFee__c ='';
            SumExpectedIncrementalNIStep6.TFFee__c = 0;
            SumExpectedIncrementalNIStep6.FXFee__c = 0;
            SumExpectedIncrementalNIStep6.LGFee__c = 0;
            SumExpectedIncrementalNIStep6.CashFee__c = 0;
            SumExpectedIncrementalNIStep6.ASFee__c = 0;
            SumExpectedIncrementalNIStep6.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep6.CreditFee__c = 0;
            SumExpectedIncrementalNIStep6.BAFee__c = 0;
            SumExpectedIncrementalNIStep6.DerivativeFee__c = 0;
            SumExpectedIncrementalNIStep6.IBFee__c = 0;
        }
        
        Map<String, Map<Id, Decimal>> MapExpectedIncrementalNIStep6 = new Map<String, Map<Id, Decimal>>();
        for(AcctPlanProdStrategyPort__c item : scope){
            String SEQ = SEQString(item.SEQ__c);
            if(item.AspirationSOW__c == null){
                item.AspirationSOW__c = 0;
            }
            if(item.WalletSizing__c == null){
                item.WalletSizing__c = 0;
            }
            if(!MapExpectedIncrementalNIStep6.containsKey(SEQ)){
                MapExpectedIncrementalNIStep6.put(SEQ,new Map<Id, Decimal>{item.AccountId__c  => ((item.AspirationSOW__c/100) * item.WalletSizing__c) });
            }else{
                MapExpectedIncrementalNIStep6.get(SEQ).put(item.AccountId__c ,((item.AspirationSOW__c/100)* item.WalletSizing__c) );
            }  
        }        
        
        /**************************************************************************
        *  Step start Summary
        ***************************************************************************/
        system.debug('accountIds='+accountIds);
        for(Id item : accountIds){
            //SumActualNI
            system.debug('id='+item);
            system.debug(MapActualNIRolling.get('1'));
            system.debug(MapActualNIRolling.get('1').get(item));
            SumActualNI.NIIc__c = (SumActualNI.NIIc__c == null ? 0.00 : SumActualNI.NIIc__c) + (MapActualNIRolling.get('1').get(item));//
            SumActualNI.NIId__c = (SumActualNI.NIId__c == null ? 0.00 : SumActualNI.NIId__c) + (MapActualNIRolling.get('2').get(item));
            SumActualNI.Fee__c = (SumActualNI.Fee__c == null ? 0.00 : SumActualNI.Fee__c) + (MapActualNIRolling.get('3').get(item));
            SumActualNI.RecurringFee__c ='';
            SumActualNI.TFFee__c = (SumActualNI.TFFee__c == null ? 0.00 : SumActualNI.TFFee__c)  + (MapActualNIRolling.get('5').get(item));
            SumActualNI.FXFee__c = (SumActualNI.FXFee__c == null ? 0.00 : SumActualNI.FXFee__c) + (MapActualNIRolling.get('6').get(item));
            SumActualNI.LGFee__c = (SumActualNI.LGFee__c == null ? 0.00 : SumActualNI.LGFee__c)  + (MapActualNIRolling.get('7').get(item));
            SumActualNI.CashFee__c = (SumActualNI.CashFee__c == null ? 0.00 : SumActualNI.CashFee__c) + (MapActualNIRolling.get('8').get(item));
            SumActualNI.ASFee__c = (SumActualNI.ASFee__c == null ? 0.00 : SumActualNI.ASFee__c) + (MapActualNIRolling.get('9').get(item));
            SumActualNI.NonRecurringFee__c ='';
            SumActualNI.CreditFee__c = (SumActualNI.CreditFee__c == null ? 0.00 : SumActualNI.CreditFee__c)  + (MapActualNIRolling.get('11').get(item));
            SumActualNI.BAFee__c = (SumActualNI.BAFee__c == null ? 0.00 : SumActualNI.BAFee__c)  + (MapActualNIRolling.get('12').get(item));//
            SumActualNI.DerivativeFee__c = (SumActualNI.DerivativeFee__c == null ? 0.00 : SumActualNI.DerivativeFee__c) + (MapActualNIRolling.get('13').get(item));
            SumActualNI.IBFee__c = (SumActualNI.IBFee__c == null ? 0.00 : SumActualNI.IBFee__c)  + (MapActualNIRolling.get('14').get(item));
            
            //SumAdjustedNI
            SumAdjustedNI.NIIc__c = (SumAdjustedNI.NIIc__c == null ? 0.00 : SumAdjustedNI.NIIc__c) + (MapAdjustedNI.get('1').get(item));
            SumAdjustedNI.NIId__c = (SumAdjustedNI.NIId__c == null ? 0.00 : SumAdjustedNI.NIId__c) + (MapAdjustedNI.get('2').get(item));
            SumAdjustedNI.RecurringFee__c ='';
            SumAdjustedNI.TFFee__c = (SumAdjustedNI.TFFee__c == null ? 0.00 : SumAdjustedNI.TFFee__c)  + (MapAdjustedNI.get('5').get(item));
            SumAdjustedNI.FXFee__c = (SumAdjustedNI.FXFee__c == null ? 0.00 : SumAdjustedNI.FXFee__c) + (MapAdjustedNI.get('6').get(item));
            SumAdjustedNI.LGFee__c = (SumAdjustedNI.LGFee__c == null ? 0.00 : SumAdjustedNI.LGFee__c)  + (MapAdjustedNI.get('7').get(item));
            SumAdjustedNI.CashFee__c = (SumAdjustedNI.CashFee__c == null ? 0.00 : SumAdjustedNI.CashFee__c) + (MapAdjustedNI.get('8').get(item));
            SumAdjustedNI.ASFee__c = (SumAdjustedNI.ASFee__c == null ? 0.00 : SumAdjustedNI.ASFee__c) + (MapAdjustedNI.get('9').get(item));
            SumAdjustedNI.NonRecurringFee__c ='';
            SumAdjustedNI.CreditFee__c = (SumAdjustedNI.CreditFee__c == null ? 0.00 : SumAdjustedNI.CreditFee__c)  + (MapAdjustedNI.get('11').get(item));
            SumAdjustedNI.BAFee__c = (SumAdjustedNI.BAFee__c == null ? 0.00 : SumAdjustedNI.BAFee__c)  + (MapAdjustedNI.get('12').get(item));
            SumAdjustedNI.DerivativeFee__c = (SumAdjustedNI.DerivativeFee__c == null ? 0.00 : SumAdjustedNI.DerivativeFee__c) + (MapAdjustedNI.get('13').get(item));
            SumAdjustedNI.IBFee__c = (SumAdjustedNI.IBFee__c == null ? 0.00 : SumAdjustedNI.IBFee__c)  + (MapAdjustedNI.get('14').get(item));
            //Sum total Fee SEQ 3.0
            SumAdjustedNI.Fee__c =   (SumAdjustedNI.TFFee__c + SumAdjustedNI.FXFee__c + SumAdjustedNI.LGFee__c
                                      +SumAdjustedNI.CashFee__c +SumAdjustedNI.ASFee__c +SumAdjustedNI.CreditFee__c 
                                      +SumAdjustedNI.BAFee__c + SumAdjustedNI.DerivativeFee__c
                                      +SumAdjustedNI.IBFee__c);  
            
            //SumExpestedIncrementalNI
            SumExpectedIncrementalNI.NIIc__c = (SumExpectedIncrementalNI.NIIc__c == null ? 0.00 : SumExpectedIncrementalNI.NIIc__c) + (MapExpectedIncrementalNI.get('1').get(item));
            SumExpectedIncrementalNI.NIId__c = (SumExpectedIncrementalNI.NIId__c == null ? 0.00 : SumExpectedIncrementalNI.NIId__c) + (MapExpectedIncrementalNI.get('2').get(item));
            SumExpectedIncrementalNI.RecurringFee__c =''; 
            SumExpectedIncrementalNI.Fee__c = (SumExpectedIncrementalNI.Fee__c == null ? 0.00 : SumExpectedIncrementalNI.Fee__c) + (MapExpectedIncrementalNI.get('3').get(item));
            SumExpectedIncrementalNI.TFFee__c = (SumExpectedIncrementalNI.TFFee__c == null ? 0.00 : SumExpectedIncrementalNI.TFFee__c)  + (MapExpectedIncrementalNI.get('5').get(item));
            SumExpectedIncrementalNI.FXFee__c = (SumExpectedIncrementalNI.FXFee__c == null ? 0.00 : SumExpectedIncrementalNI.FXFee__c) + (MapExpectedIncrementalNI.get('6').get(item));
            SumExpectedIncrementalNI.LGFee__c = (SumExpectedIncrementalNI.LGFee__c == null ? 0.00 : SumExpectedIncrementalNI.LGFee__c)  + (MapExpectedIncrementalNI.get('7').get(item));
            SumExpectedIncrementalNI.CashFee__c = (SumExpectedIncrementalNI.CashFee__c == null ? 0.00 : SumExpectedIncrementalNI.CashFee__c) + (MapExpectedIncrementalNI.get('8').get(item));
            SumExpectedIncrementalNI.ASFee__c = (SumExpectedIncrementalNI.ASFee__c == null ? 0.00 : SumExpectedIncrementalNI.ASFee__c) + (MapExpectedIncrementalNI.get('9').get(item));
            SumExpectedIncrementalNI.NonRecurringFee__c ='';
            SumExpectedIncrementalNI.CreditFee__c = (SumExpectedIncrementalNI.CreditFee__c == null ? 0.00 : SumExpectedIncrementalNI.CreditFee__c)  + (MapExpectedIncrementalNI.get('11').get(item));
            SumExpectedIncrementalNI.BAFee__c = (SumExpectedIncrementalNI.BAFee__c == null ? 0.00 : SumExpectedIncrementalNI.BAFee__c)  + (MapExpectedIncrementalNI.get('12').get(item));
            SumExpectedIncrementalNI.DerivativeFee__c = (SumExpectedIncrementalNI.DerivativeFee__c == null ? 0.00 : SumExpectedIncrementalNI.DerivativeFee__c) + (MapExpectedIncrementalNI.get('13').get(item));
            SumExpectedIncrementalNI.IBFee__c = (SumExpectedIncrementalNI.IBFee__c == null ? 0.00 : SumExpectedIncrementalNI.IBFee__c)  + (MapExpectedIncrementalNI.get('14').get(item));
                 
            //SumExpestedIncrementalNIStep5
            SumExpectedIncrementalNIStep5.NIIc__c = (SumExpectedIncrementalNIStep5.NIIc__c == null ? 0.00 : SumExpectedIncrementalNIStep5.NIIc__c) + (MapExpectedIncrementalNIStep5.get('1').get(item));
            SumExpectedIncrementalNIStep5.NIId__c = (SumExpectedIncrementalNIStep5.NIId__c == null ? 0.00 : SumExpectedIncrementalNIStep5.NIId__c) + (MapExpectedIncrementalNIStep5.get('2').get(item));
            SumExpectedIncrementalNIStep5.RecurringFee__c ='';
            SumExpectedIncrementalNIStep5.TFFee__c = (SumExpectedIncrementalNIStep5.TFFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.TFFee__c)  + (MapExpectedIncrementalNIStep5.get('5').get(item));
            SumExpectedIncrementalNIStep5.FXFee__c = (SumExpectedIncrementalNIStep5.FXFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.FXFee__c) + (MapExpectedIncrementalNIStep5.get('6').get(item));
            SumExpectedIncrementalNIStep5.LGFee__c = (SumExpectedIncrementalNIStep5.LGFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.LGFee__c)  + (MapExpectedIncrementalNIStep5.get('7').get(item));
            SumExpectedIncrementalNIStep5.CashFee__c = (SumExpectedIncrementalNIStep5.CashFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.CashFee__c) + (MapExpectedIncrementalNIStep5.get('8').get(item));
            SumExpectedIncrementalNIStep5.ASFee__c = (SumExpectedIncrementalNIStep5.ASFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.ASFee__c) + (MapExpectedIncrementalNIStep5.get('9').get(item));
            SumExpectedIncrementalNIStep5.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep5.CreditFee__c = (SumExpectedIncrementalNIStep5.CreditFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.CreditFee__c)  + (MapExpectedIncrementalNIStep5.get('11').get(item));
            SumExpectedIncrementalNIStep5.BAFee__c = (SumExpectedIncrementalNIStep5.BAFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.BAFee__c)  + (MapExpectedIncrementalNIStep5.get('12').get(item));
            SumExpectedIncrementalNIStep5.DerivativeFee__c = (SumExpectedIncrementalNIStep5.DerivativeFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.DerivativeFee__c) + (MapExpectedIncrementalNIStep5.get('13').get(item));
            SumExpectedIncrementalNIStep5.IBFee__c = (SumExpectedIncrementalNIStep5.IBFee__c == null ? 0.00 : SumExpectedIncrementalNIStep5.IBFee__c)  + (MapExpectedIncrementalNIStep5.get('14').get(item));
            //Sum total Fee SEQ 3.0
            SumExpectedIncrementalNIStep5.Fee__c = (SumExpectedIncrementalNIStep5.TFFee__c + SumExpectedIncrementalNIStep5.FXFee__c + SumExpectedIncrementalNIStep5.LGFee__c
                                                    +SumExpectedIncrementalNIStep5.CashFee__c +SumExpectedIncrementalNIStep5.ASFee__c +SumExpectedIncrementalNIStep5.CreditFee__c 
                                                    +SumExpectedIncrementalNIStep5.BAFee__c +SumExpectedIncrementalNIStep5.DerivativeFee__c
                                                    +SumExpectedIncrementalNIStep5.IBFee__c); 
            
            
            //SumTotalCompanyNI
            SumTotalCompanyNI.NIIc__c = (SumTotalCompanyNI.NIIc__c == null ? 0.00 : SumTotalCompanyNI.NIIc__c) + (MapTotalCompanyNI.get('1').get(item) == null ? 0.00 : MapTotalCompanyNI.get('1').get(item));
            SumTotalCompanyNI.NIId__c = (SumTotalCompanyNI.NIId__c == null ? 0.00 : SumTotalCompanyNI.NIId__c) + (MapTotalCompanyNI.get('2').get(item) == null ? 0.00 : MapTotalCompanyNI.get('2').get(item));
            SumTotalCompanyNI.RecurringFee__c ='';
            SumTotalCompanyNI.TFFee__c = (SumTotalCompanyNI.TFFee__c == null ? 0.00 : SumTotalCompanyNI.TFFee__c)  + (MapTotalCompanyNI.get('5').get(item) == null ? 0.00 : MapTotalCompanyNI.get('5').get(item));
            SumTotalCompanyNI.FXFee__c = (SumTotalCompanyNI.FXFee__c == null ? 0.00 : SumTotalCompanyNI.FXFee__c) + (MapTotalCompanyNI.get('6').get(item) == null ? 0.00 : MapTotalCompanyNI.get('6').get(item));
            SumTotalCompanyNI.LGFee__c = (SumTotalCompanyNI.LGFee__c == null ? 0.00 : SumTotalCompanyNI.LGFee__c)  + (MapTotalCompanyNI.get('7').get(item) == null ? 0.00 : MapTotalCompanyNI.get('7').get(item));
            SumTotalCompanyNI.CashFee__c = (SumTotalCompanyNI.CashFee__c == null ? 0.00 : SumTotalCompanyNI.CashFee__c) + (MapTotalCompanyNI.get('8').get(item) == null ? 0.00 : MapTotalCompanyNI.get('8').get(item));
            SumTotalCompanyNI.ASFee__c = (SumTotalCompanyNI.ASFee__c == null ? 0.00 : SumTotalCompanyNI.ASFee__c) + (MapTotalCompanyNI.get('9').get(item) == null ? 0.00 : MapTotalCompanyNI.get('9').get(item));
            SumTotalCompanyNI.NonRecurringFee__c ='';
            SumTotalCompanyNI.CreditFee__c = (SumTotalCompanyNI.CreditFee__c == null ? 0.00 : SumTotalCompanyNI.CreditFee__c)  + (MapTotalCompanyNI.get('11').get(item) == null ? 0.00 : MapTotalCompanyNI.get('11').get(item));
            SumTotalCompanyNI.BAFee__c = (SumTotalCompanyNI.BAFee__c == null ? 0.00 : SumTotalCompanyNI.BAFee__c)  + (MapTotalCompanyNI.get('12').get(item) == null ? 0.00 : MapTotalCompanyNI.get('12').get(item));
            SumTotalCompanyNI.DerivativeFee__c = (SumTotalCompanyNI.DerivativeFee__c == null ? 0.00 : SumTotalCompanyNI.DerivativeFee__c) + (MapTotalCompanyNI.get('13').get(item) == null ? 0.00 : MapTotalCompanyNI.get('13').get(item));
            SumTotalCompanyNI.IBFee__c = (SumTotalCompanyNI.IBFee__c == null ? 0.00 : SumTotalCompanyNI.IBFee__c)  + (MapTotalCompanyNI.get('14').get(item) == null ? 0.00 : MapTotalCompanyNI.get('14').get(item));
            //Sum total Fee SEQ 3.0
            SumTotalCompanyNI.Fee__c =  (SumTotalCompanyNI.TFFee__c + SumTotalCompanyNI.FXFee__c + SumTotalCompanyNI.LGFee__c
                                         +SumTotalCompanyNI.CashFee__c +SumTotalCompanyNI.ASFee__c +SumTotalCompanyNI.CreditFee__c 
                                         +SumTotalCompanyNI.BAFee__c +SumTotalCompanyNI.DerivativeFee__c
                                         +SumTotalCompanyNI.IBFee__c); 
            
            //SumExpectedIncrementalNIStep6
            SumExpectedIncrementalNIStep6.NIIc__c = (SumExpectedIncrementalNIStep6.NIIc__c == null ? 0.00 : SumExpectedIncrementalNIStep6.NIIc__c) + (MapExpectedIncrementalNIStep6.get('1').get(item));
            SumExpectedIncrementalNIStep6.NIId__c = (SumExpectedIncrementalNIStep6.NIId__c == null ? 0.00 : SumExpectedIncrementalNIStep6.NIId__c) + (MapExpectedIncrementalNIStep6.get('2').get(item));
            SumExpectedIncrementalNIStep6.Fee__c = (SumExpectedIncrementalNIStep6.Fee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.Fee__c) + (MapExpectedIncrementalNIStep6.get('3').get(item));
            SumExpectedIncrementalNIStep6.RecurringFee__c ='';
            SumExpectedIncrementalNIStep6.TFFee__c = (SumExpectedIncrementalNIStep6.TFFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.TFFee__c)  + (MapExpectedIncrementalNIStep6.get('5').get(item));
            SumExpectedIncrementalNIStep6.FXFee__c = (SumExpectedIncrementalNIStep6.FXFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.FXFee__c) + (MapExpectedIncrementalNIStep6.get('6').get(item));
            SumExpectedIncrementalNIStep6.LGFee__c = (SumExpectedIncrementalNIStep6.LGFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.LGFee__c)  + (MapExpectedIncrementalNIStep6.get('7').get(item));
            SumExpectedIncrementalNIStep6.CashFee__c = (SumExpectedIncrementalNIStep6.CashFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.CashFee__c) + (MapExpectedIncrementalNIStep6.get('8').get(item));
            SumExpectedIncrementalNIStep6.ASFee__c = (SumExpectedIncrementalNIStep6.ASFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.ASFee__c) + (MapExpectedIncrementalNIStep6.get('9').get(item));
            SumExpectedIncrementalNIStep6.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep6.CreditFee__c = (SumExpectedIncrementalNIStep6.CreditFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.CreditFee__c)  + (MapExpectedIncrementalNIStep6.get('11').get(item));
            SumExpectedIncrementalNIStep6.BAFee__c = (SumExpectedIncrementalNIStep6.BAFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.BAFee__c)  + (MapExpectedIncrementalNIStep6.get('12').get(item));
            SumExpectedIncrementalNIStep6.DerivativeFee__c = (SumExpectedIncrementalNIStep6.DerivativeFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.DerivativeFee__c) + (MapExpectedIncrementalNIStep6.get('13').get(item));
            SumExpectedIncrementalNIStep6.IBFee__c = (SumExpectedIncrementalNIStep6.IBFee__c == null ? 0.00 : SumExpectedIncrementalNIStep6.IBFee__c)  + (MapExpectedIncrementalNIStep6.get('14').get(item));
 
        }
        //SumActualNI
        SumActualNI.Group__c = this.m_groupId;
        SumActualNI.Year__c = this.m_year ;
        SumActualNI.IsProductStrategy__c = false;
        SumActualNI.IsGroupWallet__c = true;
        SumActualNI.IsGroupPerformance__c = true;
        SumActualNI.SummaryType__c = 'ActualNI';
        upsert SumActualNI;
        
        //SumAdjustedNI
        SumAdjustedNI.Group__c = this.m_groupId;
        SumAdjustedNI.Year__c = this.m_year ;
        SumAdjustedNI.IsProductStrategy__c = false;
        SumAdjustedNI.IsGroupWallet__c = true;
        SumAdjustedNI.IsGroupPerformance__c = true;
        SumAdjustedNI.SummaryType__c = 'AdjustedNI';   
        upsert SumAdjustedNI;
        
        //SumExpestedIncrementalNI
        SumExpectedIncrementalNI.Group__c = this.m_groupId;
        SumExpectedIncrementalNI.Year__c = this.m_year ;
        SumExpectedIncrementalNI.IsProductStrategy__c = false;
        SumExpectedIncrementalNI.IsGroupWallet__c = true;
        SumExpectedIncrementalNI.IsGroupPerformance__c = false;
        SumExpectedIncrementalNI.SummaryType__c = 'ExpectedIncrementalNI';
        upsert SumExpectedIncrementalNI;
        
        //SumExpestedIncrementalNIStep5
        SumExpectedIncrementalNIStep5.Group__c = this.m_groupId;
        SumExpectedIncrementalNIStep5.Year__c = this.m_year ;
        SumExpectedIncrementalNIStep5.IsProductStrategy__c = false;
        SumExpectedIncrementalNIStep5.IsGroupWallet__c = false;
        SumExpectedIncrementalNIStep5.IsGroupPerformance__c = true;
        SumExpectedIncrementalNIStep5.SummaryType__c = 'ExpectedIncrementalNIStep5';
        upsert SumExpectedIncrementalNIStep5;
        
        //SumTotalCompanyNI
        SumTotalCompanyNI.Group__c = this.m_groupId;
        SumTotalCompanyNI.Year__c = this.m_year ;
        SumTotalCompanyNI.IsProductStrategy__c = false;
        SumTotalCompanyNI.IsGroupWallet__c = false;
        SumTotalCompanyNI.IsGroupPerformance__c = true;
        SumTotalCompanyNI.SummaryType__c = 'TotalCompanyNI';
        upsert SumTotalCompanyNI;
        
        //SumExpectedIncrementalNIStep6
        SumExpectedIncrementalNIStep6.Group__c = this.m_groupId;
        SumExpectedIncrementalNIStep6.Year__c = this.m_year ;
        SumExpectedIncrementalNIStep6.IsProductStrategy__c = false;
        SumExpectedIncrementalNIStep6.IsGroupWallet__c = false;
        SumExpectedIncrementalNIStep6.IsGroupPerformance__c = false;
        SumExpectedIncrementalNIStep6.SummaryType__c = 'ExpectedIncrementalNIStep6';
        upsert SumExpectedIncrementalNIStep6;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        /**********************************************************************
        *  Step initiate Sum Group Wallet Sizing (Yearly)
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumWalletSizingList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                    WHERE Group__c = :this.m_groupId
                                    AND Year__c = :this.m_year
                                    AND SummaryType__c  = 'WalletSizing' LIMIT 1];
        AccountPlanWalletSizing__c SumWalletSizing = new AccountPlanWalletSizing__c();
        if(SumWalletSizingList.size()>0){
            SumWalletSizing = SumWalletSizingList.get(0);
        }else{
            SumWalletSizing.NIIc__c = 0;
            SumWalletSizing.NIId__c = 0;
            SumWalletSizing.Fee__c = 0;
            SumWalletSizing.RecurringFee__c ='';
            SumWalletSizing.TFFee__c = 0;
            SumWalletSizing.FXFee__c = 0;
            SumWalletSizing.LGFee__c = 0;
            SumWalletSizing.CashFee__c = 0;
            SumWalletSizing.ASFee__c = 0;
            SumWalletSizing.NonRecurringFee__c ='';
            SumWalletSizing.CreditFee__c = 0;
            SumWalletSizing.BAFee__c = 0;
            SumWalletSizing.DerivativeFee__c = 0;
            SumWalletSizing.IBFee__c = 0;
        }
  
        /**********************************************************************
        *  Step initiate Sum Group's Adjusted NI (12-mth Rolling)
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumAdjustedNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'AdjustedNI' LIMIT 1];
        AccountPlanWalletSizing__c SumAdjustedNI = new AccountPlanWalletSizing__c();
        if(SumAdjustedNIList.size()>0){
            SumAdjustedNI = SumAdjustedNIList.get(0);
        }else{
            SumAdjustedNI.NIIc__c = 0;
            SumAdjustedNI.NIId__c = 0;
            SumAdjustedNI.Fee__c = 0;
            SumAdjustedNI.RecurringFee__c ='';
            SumAdjustedNI.TFFee__c = 0;
            SumAdjustedNI.FXFee__c = 0;
            SumAdjustedNI.LGFee__c = 0;
            SumAdjustedNI.CashFee__c = 0;
            SumAdjustedNI.ASFee__c = 0;
            SumAdjustedNI.NonRecurringFee__c ='';
            SumAdjustedNI.CreditFee__c = 0;
            SumAdjustedNI.BAFee__c = 0;
            SumAdjustedNI.DerivativeFee__c = 0;
            SumAdjustedNI.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum % Existing SOW Group
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumExistingSOWList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExistingSOW' LIMIT 1];
        AccountPlanWalletSizing__c SumExistingSOW = new AccountPlanWalletSizing__c();
        if(SumExistingSOWList.size()>0){
            SumExistingSOW = SumExistingSOWList.get(0);
        }else{
            SumExistingSOW.NIIc__c = 0;
            SumExistingSOW.NIId__c = 0;
            SumExistingSOW.Fee__c = 0;
            SumExistingSOW.RecurringFee__c ='';
            SumExistingSOW.TFFee__c = 0;
            SumExistingSOW.FXFee__c = 0;
            SumExistingSOW.LGFee__c = 0;
            SumExistingSOW.CashFee__c = 0;
            SumExistingSOW.ASFee__c = 0;
            SumExistingSOW.NonRecurringFee__c ='';
            SumExistingSOW.CreditFee__c = 0;
            SumExistingSOW.BAFee__c = 0;
            SumExistingSOW.DerivativeFee__c = 0;
            SumExistingSOW.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum Expected Incremental NI (Unit: THB)
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumExpectedIncrementalNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExpectedIncrementalNI' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedIncrementalNI = new AccountPlanWalletSizing__c();
        if(SumExpectedIncrementalNIList.size()>0){
            SumExpectedIncrementalNI = SumExpectedIncrementalNIList.get(0);
        }else{
            SumExpectedIncrementalNI.NIIc__c = 0;
            SumExpectedIncrementalNI.NIId__c = 0;
            SumExpectedIncrementalNI.Fee__c = 0;
            SumExpectedIncrementalNI.RecurringFee__c ='';
            SumExpectedIncrementalNI.TFFee__c = 0;
            SumExpectedIncrementalNI.FXFee__c = 0;
            SumExpectedIncrementalNI.LGFee__c = 0;
            SumExpectedIncrementalNI.CashFee__c = 0;
            SumExpectedIncrementalNI.ASFee__c = 0;
            SumExpectedIncrementalNI.NonRecurringFee__c ='';
            SumExpectedIncrementalNI.CreditFee__c = 0;
            SumExpectedIncrementalNI.BAFee__c = 0;
            SumExpectedIncrementalNI.DerivativeFee__c = 0;
            SumExpectedIncrementalNI.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum % Aspiration SOW
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumAspirationSOWList = [ SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'AspirationSOW' LIMIT 1];
        AccountPlanWalletSizing__c SumAspirationSOW = new AccountPlanWalletSizing__c();
        if(SumAspirationSOWList.size()>0){
            SumAspirationSOW = SumAspirationSOWList.get(0);
        }else{
            SumAspirationSOW.NIIc__c = 0;
            SumAspirationSOW.NIId__c = 0;
            SumAspirationSOW.Fee__c = 0;
            SumAspirationSOW.RecurringFee__c ='';
            SumAspirationSOW.TFFee__c = 0;
            SumAspirationSOW.FXFee__c = 0;
            SumAspirationSOW.LGFee__c = 0;
            SumAspirationSOW.CashFee__c = 0;
            SumAspirationSOW.ASFee__c = 0;
            SumAspirationSOW.NonRecurringFee__c ='';
            SumAspirationSOW.CreditFee__c = 0;
            SumAspirationSOW.BAFee__c = 0;
            SumAspirationSOW.DerivativeFee__c = 0;
            SumAspirationSOW.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum Total Group NI
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumTotalCompanyNIList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'TotalCompanyNI' LIMIT 1];
        AccountPlanWalletSizing__c SumTotalCompanyNI = new AccountPlanWalletSizing__c();
        if(SumTotalCompanyNIList.size()>0){
            SumTotalCompanyNI = SumTotalCompanyNIList.get(0);
        }else{
            SumTotalCompanyNI.NIIc__c = 0;
            SumTotalCompanyNI.NIId__c = 0;
            SumTotalCompanyNI.Fee__c = 0;
            SumTotalCompanyNI.RecurringFee__c ='';
            SumTotalCompanyNI.TFFee__c = 0;
            SumTotalCompanyNI.FXFee__c = 0;
            SumTotalCompanyNI.LGFee__c = 0;
            SumTotalCompanyNI.CashFee__c = 0;
            SumTotalCompanyNI.ASFee__c = 0;
            SumTotalCompanyNI.NonRecurringFee__c ='';
            SumTotalCompanyNI.CreditFee__c = 0;
            SumTotalCompanyNI.BAFee__c = 0;
            SumTotalCompanyNI.DerivativeFee__c = 0;
            SumTotalCompanyNI.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum % Expected SOW Group
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumExpectedSOWList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExpectedSOW' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedSOW = new AccountPlanWalletSizing__c();
        if(SumExpectedSOWList.size()>0){
            SumExpectedSOW  = SumExpectedSOWList.get(0);
        }else{
            SumExpectedSOW.NIIc__c = 0;
            SumExpectedSOW.NIId__c = 0;
            SumExpectedSOW.Fee__c = 0;
            SumExpectedSOW.RecurringFee__c ='';
            SumExpectedSOW.TFFee__c = 0;
            SumExpectedSOW.FXFee__c = 0;
            SumExpectedSOW.LGFee__c = 0;
            SumExpectedSOW.CashFee__c = 0;
            SumExpectedSOW.ASFee__c = 0;
            SumExpectedSOW.NonRecurringFee__c ='';
            SumExpectedSOW.CreditFee__c = 0;
            SumExpectedSOW.BAFee__c = 0;
            SumExpectedSOW.DerivativeFee__c = 0;
            SumExpectedSOW.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum ExpectedIncrementalNIStep6
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumExpectedIncrementalNIStep6List = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            FROM AccountPlanWalletSizing__c
                                                            WHERE Group__c = :this.m_groupId
                                                            AND Year__c = :this.m_year
                                                            AND SummaryType__c  = 'ExpectedIncrementalNIStep6' LIMIT 1];
        AccountPlanWalletSizing__c SumExpectedIncrementalNIStep6 = new AccountPlanWalletSizing__c();
        if(SumExpectedIncrementalNIStep6List.size()>0){
            SumExpectedIncrementalNIStep6 = SumExpectedIncrementalNIStep6List.get(0);
        }else{
            SumExpectedIncrementalNIStep6.NIIc__c = 0;
            SumExpectedIncrementalNIStep6.NIId__c = 0;
            SumExpectedIncrementalNIStep6.Fee__c = 0;
            SumExpectedIncrementalNIStep6.RecurringFee__c ='';
            SumExpectedIncrementalNIStep6.TFFee__c = 0;
            SumExpectedIncrementalNIStep6.FXFee__c = 0;
            SumExpectedIncrementalNIStep6.LGFee__c = 0;
            SumExpectedIncrementalNIStep6.CashFee__c = 0;
            SumExpectedIncrementalNIStep6.ASFee__c = 0;
            SumExpectedIncrementalNIStep6.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep6.CreditFee__c = 0;
            SumExpectedIncrementalNIStep6.BAFee__c = 0;
            SumExpectedIncrementalNIStep6.DerivativeFee__c = 0;
            SumExpectedIncrementalNIStep6.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum % Aspiration SOW Step 6
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> SumAspirationSOWStep6List = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                      IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                      NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                      Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                      FROM AccountPlanWalletSizing__c
                                                                      WHERE Group__c = :this.m_groupId
                                                                      AND Year__c = :this.m_year
                                                                      AND SummaryType__c  = 'AspirationSOWStep6' LIMIT 1];
        AccountPlanWalletSizing__c SumAspirationSOWStep6 = new AccountPlanWalletSizing__c();
        if(SumAspirationSOWStep6List.size()>0){
            SumAspirationSOWStep6  = SumAspirationSOWStep6List.get(0);
        }else{
            SumAspirationSOWStep6.NIIc__c = 0;
            SumAspirationSOWStep6.NIId__c = 0;
            SumAspirationSOWStep6.Fee__c = 0;
            SumAspirationSOWStep6.RecurringFee__c ='';
            SumAspirationSOWStep6.TFFee__c = 0;
            SumAspirationSOWStep6.FXFee__c = 0;
            SumAspirationSOWStep6.LGFee__c = 0;
            SumAspirationSOWStep6.CashFee__c = 0;
            SumAspirationSOWStep6.ASFee__c = 0;
            SumAspirationSOWStep6.NonRecurringFee__c ='';
            SumAspirationSOWStep6.CreditFee__c = 0;
            SumAspirationSOWStep6.BAFee__c = 0;
            SumAspirationSOWStep6.DerivativeFee__c = 0;
            SumAspirationSOWStep6.IBFee__c = 0;
        }
        
        /**********************************************************************
        *  Step initiate Sum Compare % Aspiration SOW and % Expected SOW
        ***********************************************************************/  
        List<AccountPlanWalletSizing__c> CompareExpextedToAspirationList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                            IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,
                                                                            NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                            Account__c,IsGroupWallet__c,IsGroupPerformance__c
                                                                            
                                                                            FROM AccountPlanWalletSizing__c
                                                                            WHERE Group__c = :this.m_groupId
                                                                            AND Year__c = :this.m_year
                                                                            AND SummaryType__c  = 'CompareExpectedtoAspirationSOW' LIMIT 1];
        AccountPlanWalletSizing__c CompareExpextedToAspiration = new AccountPlanWalletSizing__c();
        if(CompareExpextedToAspirationList.size()>0){
            CompareExpextedToAspiration  = CompareExpextedToAspirationList.get(0);
        }else{
            CompareExpextedToAspiration.NIIc__c = 0;
            CompareExpextedToAspiration.NIId__c = 0;
            CompareExpextedToAspiration.Fee__c = 0;
            CompareExpextedToAspiration.RecurringFee__c ='';
            CompareExpextedToAspiration.TFFee__c = 0;
            CompareExpextedToAspiration.FXFee__c = 0;
            CompareExpextedToAspiration.LGFee__c = 0;
            CompareExpextedToAspiration.CashFee__c = 0;
            CompareExpextedToAspiration.ASFee__c = 0;
            CompareExpextedToAspiration.NonRecurringFee__c ='';
            CompareExpextedToAspiration.CreditFee__c = 0;
            CompareExpextedToAspiration.BAFee__c = 0;
            CompareExpextedToAspiration.DerivativeFee__c = 0;
            CompareExpextedToAspiration.IBFee__c = 0;
        }
        
        /**************************************************************************
        *  Step start Summary
        ***************************************************************************/
        //SumExistingSOW
        system.debug('SumExistingSOW.NIIc__c='+SumExistingSOW.NIIc__c);
        system.debug('SumWalletSizing.NIIc__c='+SumWalletSizing.NIIc__c);
        system.debug('SumAdjustedNI.NIIc__c='+SumAdjustedNI.NIIc__c);
        SumExistingSOW.NIIc__c = (SumWalletSizing.NIIc__c == null || SumWalletSizing.NIIc__c == 0 ? 0 :((SumAdjustedNI.NIIc__c/SumWalletSizing.NIIc__c)*100));
        SumExistingSOW.NIId__c = (SumWalletSizing.NIId__c == null || SumWalletSizing.NIId__c == 0 ? 0 :((SumAdjustedNI.NIId__c/SumWalletSizing.NIId__c)*100));
        SumExistingSOW.Fee__c = (SumWalletSizing.Fee__c == null || SumWalletSizing.Fee__c == 0 ? 0 :((SumAdjustedNI.Fee__c/SumWalletSizing.Fee__c)*100));
        SumExistingSOW.RecurringFee__c ='';
        SumExistingSOW.TFFee__c = (SumWalletSizing.TFFee__c == null || SumWalletSizing.TFFee__c == 0 ? 0 :((SumAdjustedNI.TFFee__c/SumWalletSizing.TFFee__c)*100));
        SumExistingSOW.FXFee__c = (SumWalletSizing.FXFee__c == null || SumWalletSizing.FXFee__c == 0 ? 0 :((SumAdjustedNI.FXFee__c/SumWalletSizing.FXFee__c)*100));
        SumExistingSOW.LGFee__c = (SumWalletSizing.LGFee__c == null || SumWalletSizing.LGFee__c == 0 ? 0 :((SumAdjustedNI.LGFee__c/SumWalletSizing.LGFee__c)*100));
        SumExistingSOW.CashFee__c = (SumWalletSizing.CashFee__c == null || SumWalletSizing.CashFee__c == 0 ? 0 :((SumAdjustedNI.CashFee__c/SumWalletSizing.CashFee__c)*100));
        SumExistingSOW.ASFee__c = (SumWalletSizing.ASFee__c == null || SumWalletSizing.ASFee__c == 0 ? 0 :((SumAdjustedNI.ASFee__c/SumWalletSizing.ASFee__c)*100));
        SumExistingSOW.NonRecurringFee__c ='';
        SumExistingSOW.CreditFee__c = ( SumWalletSizing.CreditFee__c == null || SumWalletSizing.CreditFee__c == 0 ? 0 :((SumAdjustedNI.CreditFee__c/SumWalletSizing.CreditFee__c)*100));
        SumExistingSOW.BAFee__c = (SumWalletSizing.BAFee__c == null || SumWalletSizing.BAFee__c == 0 ? 0 :((SumAdjustedNI.BAFee__c/SumWalletSizing.BAFee__c)*100));
        SumExistingSOW.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == null || SumWalletSizing.DerivativeFee__c == 0 ? 0 :((SumAdjustedNI.DerivativeFee__c/SumWalletSizing.DerivativeFee__c)*100));
        SumExistingSOW.IBFee__c = (SumWalletSizing.IBFee__c == null || SumWalletSizing.IBFee__c == 0 ? 0 :((SumAdjustedNI.IBFee__c/SumWalletSizing.IBFee__c)*100));
        
        SumExistingSOW.Group__c = this.m_groupId;
        SumExistingSOW.Year__c = this.m_year ;
        SumExistingSOW.IsProductStrategy__c = false;
        SumExistingSOW.IsGroupWallet__c = true;
        SumExistingSOW.IsGroupPerformance__c = true;
        SumExistingSOW.SummaryType__c = 'ExistingSOW';
        upsert SumExistingSOW;
        
        //SumAspirationSOW
        SumAspirationSOW.NIIc__c = (SumWalletSizing.NIIc__c == 0 ? 0 :(((SumExpectedIncrementalNI.NIIc__c + SumAdjustedNI.NIIc__c)/SumWalletSizing.NIIc__c)*100));
        SumAspirationSOW.NIId__c = (SumWalletSizing.NIId__c == 0 ? 0 :(((SumExpectedIncrementalNI.NIId__c +SumAdjustedNI.NIId__c)/SumWalletSizing.NIId__c)*100));
        SumAspirationSOW.Fee__c = (SumWalletSizing.Fee__c == 0 ? 0 :(((SumExpectedIncrementalNI.Fee__c +SumAdjustedNI.Fee__c)/SumWalletSizing.Fee__c)*100));
        SumAspirationSOW.RecurringFee__c ='';
        SumAspirationSOW.TFFee__c = (SumWalletSizing.TFFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.TFFee__c +SumAdjustedNI.TFFee__c)/SumWalletSizing.TFFee__c)*100));
        SumAspirationSOW.FXFee__c = (SumWalletSizing.FXFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.FXFee__c +SumAdjustedNI.FXFee__c)/SumWalletSizing.FXFee__c)*100));
        SumAspirationSOW.LGFee__c = (SumWalletSizing.LGFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.LGFee__c +SumAdjustedNI.LGFee__c)/SumWalletSizing.LGFee__c)*100));
        SumAspirationSOW.CashFee__c = (SumWalletSizing.CashFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.CashFee__c +SumAdjustedNI.CashFee__c)/SumWalletSizing.CashFee__c)*100));
        SumAspirationSOW.ASFee__c = (SumWalletSizing.ASFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.ASFee__c +SumAdjustedNI.ASFee__c)/SumWalletSizing.ASFee__c)*100));
        SumAspirationSOW.NonRecurringFee__c ='';
        SumAspirationSOW.CreditFee__c = (SumWalletSizing.CreditFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.CreditFee__c +SumAdjustedNI.CreditFee__c)/SumWalletSizing.CreditFee__c)*100));
        SumAspirationSOW.BAFee__c = (SumWalletSizing.BAFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.BAFee__c +SumAdjustedNI.BAFee__c)/SumWalletSizing.BAFee__c)*100));
        SumAspirationSOW.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.NIIc__c +SumAdjustedNI.DerivativeFee__c)/SumWalletSizing.DerivativeFee__c)*100));
        SumAspirationSOW.IBFee__c = (SumWalletSizing.IBFee__c == 0 ? 0 :(((SumExpectedIncrementalNI.IBFee__c +SumAdjustedNI.IBFee__c)/SumWalletSizing.IBFee__c)*100));
        
        SumAspirationSOW.Group__c = this.m_groupId;
        SumAspirationSOW.Year__c = this.m_year ;
        SumAspirationSOW.IsProductStrategy__c = false;
        SumAspirationSOW.IsGroupWallet__c = true;
        SumAspirationSOW.IsGroupPerformance__c = false;
        SumAspirationSOW.SummaryType__c = 'AspirationSOW';
        upsert SumAspirationSOW;
        
        //SumExpectedSOW
        SumExpectedSOW.NIIc__c = (SumWalletSizing.NIIc__c == 0 ? 0 :((SumTotalCompanyNI.NIIc__c/SumWalletSizing.NIIc__c)*100));
        SumExpectedSOW.NIId__c = (SumWalletSizing.NIId__c == 0 ? 0 :((SumTotalCompanyNI.NIId__c/SumWalletSizing.NIId__c)*100));
        SumExpectedSOW.Fee__c = (SumWalletSizing.Fee__c == 0 ? 0 :((SumTotalCompanyNI.Fee__c/SumWalletSizing.Fee__c)*100));
        SumExpectedSOW.RecurringFee__c ='';
        SumExpectedSOW.TFFee__c = (SumWalletSizing.TFFee__c == 0 ? 0 :((SumTotalCompanyNI.TFFee__c/SumWalletSizing.TFFee__c)*100));
        SumExpectedSOW.FXFee__c = (SumWalletSizing.FXFee__c == 0 ? 0 :((SumTotalCompanyNI.FXFee__c/SumWalletSizing.FXFee__c)*100));
        SumExpectedSOW.LGFee__c = (SumWalletSizing.LGFee__c == 0 ? 0 :((SumTotalCompanyNI.LGFee__c/SumWalletSizing.LGFee__c)*100));
        SumExpectedSOW.CashFee__c = (SumWalletSizing.CashFee__c == 0 ? 0 :((SumTotalCompanyNI.CashFee__c/SumWalletSizing.CashFee__c)*100));
        SumExpectedSOW.ASFee__c = (SumWalletSizing.ASFee__c == 0 ? 0 :((SumTotalCompanyNI.ASFee__c/SumWalletSizing.ASFee__c)*100));
        SumExpectedSOW.NonRecurringFee__c ='';
        SumExpectedSOW.CreditFee__c = (SumWalletSizing.CreditFee__c == 0 ? 0 :((SumTotalCompanyNI.CreditFee__c/SumWalletSizing.CreditFee__c)*100));
        SumExpectedSOW.BAFee__c = (SumWalletSizing.BAFee__c == 0 ? 0 :((SumTotalCompanyNI.BAFee__c/SumWalletSizing.BAFee__c)*100));
        SumExpectedSOW.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == 0 ? 0 :((SumTotalCompanyNI.DerivativeFee__c/SumWalletSizing.DerivativeFee__c)*100));
        SumExpectedSOW.IBFee__c = (SumWalletSizing.IBFee__c == 0 ? 0 :((SumTotalCompanyNI.IBFee__c/SumWalletSizing.IBFee__c)*100));
        
        SumExpectedSOW.Group__c = this.m_groupId;
        SumExpectedSOW.Year__c = this.m_year ;
        SumExpectedSOW.IsProductStrategy__c = false;
        SumExpectedSOW.IsGroupWallet__c = false;
        SumExpectedSOW.IsGroupPerformance__c = true;
        SumExpectedSOW.SummaryType__c = 'ExpectedSOW';
        upsert SumExpectedSOW;
        
        //SumAspirationSOWStep6
        SumAspirationSOWStep6.NIIc__c = (SumWalletSizing.NIIc__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.NIIc__c/SumWalletSizing.NIIc__c)*100));
        SumAspirationSOWStep6.NIId__c = (SumWalletSizing.NIId__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.NIId__c/SumWalletSizing.NIId__c)*100));
        SumAspirationSOWStep6.Fee__c = (SumWalletSizing.Fee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.Fee__c/SumWalletSizing.Fee__c)*100));
        SumAspirationSOWStep6.RecurringFee__c ='';
        SumAspirationSOWStep6.TFFee__c = (SumWalletSizing.TFFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.TFFee__c/SumWalletSizing.TFFee__c)*100));
        SumAspirationSOWStep6.FXFee__c = (SumWalletSizing.FXFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.FXFee__c/SumWalletSizing.FXFee__c)*100));
        SumAspirationSOWStep6.LGFee__c = (SumWalletSizing.LGFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.LGFee__c/SumWalletSizing.LGFee__c)*100));
        SumAspirationSOWStep6.CashFee__c = (SumWalletSizing.CashFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.CashFee__c/SumWalletSizing.CashFee__c)*100));
        SumAspirationSOWStep6.ASFee__c = (SumWalletSizing.ASFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.ASFee__c/SumWalletSizing.ASFee__c)*100));
        SumAspirationSOWStep6.NonRecurringFee__c ='';
        SumAspirationSOWStep6.CreditFee__c = (SumWalletSizing.CreditFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.CreditFee__c/SumWalletSizing.CreditFee__c)*100));
        SumAspirationSOWStep6.BAFee__c = (SumWalletSizing.BAFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.BAFee__c/SumWalletSizing.BAFee__c)*100));
        SumAspirationSOWStep6.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.DerivativeFee__c/SumWalletSizing.DerivativeFee__c)*100));
        SumAspirationSOWStep6.IBFee__c = (SumWalletSizing.IBFee__c == 0 ? 0 :((SumExpectedIncrementalNIStep6.IBFee__c/SumWalletSizing.IBFee__c)*100));
        
        SumAspirationSOWStep6.Group__c = this.m_groupId;
        SumAspirationSOWStep6.Year__c = this.m_year ;
        SumAspirationSOWStep6.IsProductStrategy__c = false;
        SumAspirationSOWStep6.IsGroupWallet__c = false;
        SumAspirationSOWStep6.IsGroupPerformance__c = true;
        SumAspirationSOWStep6.SummaryType__c = 'AspirationSOWStep6';
        upsert SumAspirationSOWStep6;
              
        //CompareExpextedToAspiration
        CompareExpextedToAspiration.NIIc__c = SumExpectedSOW.NIIc__c - SumAspirationSOWStep6.NIIc__c;
        CompareExpextedToAspiration.NIId__c = SumExpectedSOW.NIId__c - SumAspirationSOWStep6.NIId__c;
        CompareExpextedToAspiration.Fee__c = SumExpectedSOW.Fee__c - SumAspirationSOWStep6.Fee__c;
        CompareExpextedToAspiration.TFFee__c = SumExpectedSOW.TFFee__c - SumAspirationSOWStep6.TFFee__c;
        CompareExpextedToAspiration.FXFee__c = SumExpectedSOW.FXFee__c - SumAspirationSOWStep6.FXFee__c;
        CompareExpextedToAspiration.LGFee__c = SumExpectedSOW.LGFee__c - SumAspirationSOWStep6.LGFee__c;
        CompareExpextedToAspiration.CashFee__c = SumExpectedSOW.CashFee__c - SumAspirationSOWStep6.CashFee__c;
        CompareExpextedToAspiration.ASFee__c = SumExpectedSOW.ASFee__c - SumAspirationSOWStep6.ASFee__c;
        CompareExpextedToAspiration.NonRecurringFee__c = '';
        CompareExpextedToAspiration.CreditFee__c = SumExpectedSOW.CreditFee__c - SumAspirationSOWStep6.CreditFee__c;
        CompareExpextedToAspiration.BAFee__c = SumExpectedSOW.BAFee__c - SumAspirationSOWStep6.BAFee__c;
        CompareExpextedToAspiration.DerivativeFee__c = SumExpectedSOW.DerivativeFee__c - SumAspirationSOWStep6.DerivativeFee__c;
        CompareExpextedToAspiration.IBFee__c = SumExpectedSOW.IBFee__c - SumAspirationSOWStep6.IBFee__c;
        CompareExpextedToAspiration.RecurringFee__c = '';
        
        CompareExpextedToAspiration.Group__c = this.m_groupId;
        CompareExpextedToAspiration.Year__c = this.m_year ;
        CompareExpextedToAspiration.IsProductStrategy__c = false;
        CompareExpextedToAspiration.IsGroupWallet__c = false;
        CompareExpextedToAspiration.IsGroupPerformance__c = true;
        CompareExpextedToAspiration.SummaryType__c = 'CompareExpectedtoAspirationSOW';
        upsert CompareExpextedToAspiration;
        
        
        /*Decimal TotalGroupTargetNIByRm = 0;
        for (AcctPlanCompanyPort__c item :AccountPlanCompanyPortSelector.getAllCompanyPortUnderGroupByGroupProfolioId(this.m_groupProfileId)) {
            TotalGroupTargetNIByRm = TotalGroupTargetNIByRm +(item.Target_NI_By_RM__c == null ? 0 : item.Target_NI_By_RM__c);
        }
        AccountPlanWalletSizing__c SumTargetbyGroup = new AccountPlanWalletSizing__c();
        SumTargetbyGroup.Group__c = this.m_groupId;
        SumTargetbyGroup.Year__c = this.m_year ;
        SumTargetbyGroup.IsProductStrategy__c = false;
        SumTargetbyGroup.IsGroupWallet__c = false;
        SumTargetbyGroup.IsGroupPerformance__c = true;
        SumTargetbyGroup.TargetbyGroup__c = TotalGroupTargetNIByRm;
        SumTargetbyGroup.SummaryType__c = 'TargetbyGroup';
        insert SumTargetbyGroup;*/
        
        Set<id> accountIds = m_accountWithoutAccountPlan;
        if(accountIds.size() <=0){
            //SumActualNI
            AccountPlanWalletSizing__c SumActualNI = new AccountPlanWalletSizing__c();
            SumActualNI.NIIc__c = 0;
            SumActualNI.NIId__c = 0;
            SumActualNI.Fee__c = 0;
            SumActualNI.RecurringFee__c ='';
            SumActualNI.TFFee__c = 0;
            SumActualNI.FXFee__c = 0;
            SumActualNI.LGFee__c = 0;
            SumActualNI.CashFee__c = 0;
            SumActualNI.ASFee__c = 0;
            SumActualNI.NonRecurringFee__c ='';
            SumActualNI.CreditFee__c = 0;
            SumActualNI.BAFee__c = 0;
            SumActualNI.DerivativeFee__c = 0;
            SumActualNI.IBFee__c = 0;    
            SumActualNI.Group__c = this.m_groupId;
            SumActualNI.Year__c = this.m_year ;
            SumActualNI.IsProductStrategy__c = false;
            SumActualNI.IsGroupWallet__c = true;
            SumActualNI.IsGroupPerformance__c = true;
            SumActualNI.SummaryType__c = 'ActualNI';
            upsert SumActualNI;
            
            //SumAdjustedNI
            //AccountPlanWalletSizing__c SumAdjustedNI = new AccountPlanWalletSizing__c();
            SumAdjustedNI.NIIc__c = 0;
            SumAdjustedNI.NIId__c = 0;
            SumAdjustedNI.Fee__c = 0;
            SumAdjustedNI.RecurringFee__c ='';
            SumAdjustedNI.TFFee__c = 0;
            SumAdjustedNI.FXFee__c = 0;
            SumAdjustedNI.LGFee__c = 0;
            SumAdjustedNI.CashFee__c = 0;
            SumAdjustedNI.ASFee__c = 0;
            SumAdjustedNI.NonRecurringFee__c ='';
            SumAdjustedNI.CreditFee__c = 0;
            SumAdjustedNI.BAFee__c = 0;
            SumAdjustedNI.DerivativeFee__c = 0;
            SumAdjustedNI.IBFee__c = 0;
            SumAdjustedNI.Group__c = this.m_groupId;
            SumAdjustedNI.Year__c = this.m_year ;
            SumAdjustedNI.IsProductStrategy__c = false;
            SumAdjustedNI.IsGroupWallet__c = true;
            SumAdjustedNI.IsGroupPerformance__c = true;
            SumAdjustedNI.SummaryType__c = 'AdjustedNI';   
            upsert SumAdjustedNI;
            
            //SumExpestedIncrementalNI
            //AccountPlanWalletSizing__c SumExpectedIncrementalNI = new AccountPlanWalletSizing__c();
            SumExpectedIncrementalNI.NIIc__c = 0;
            SumExpectedIncrementalNI.NIId__c = 0;
            SumExpectedIncrementalNI.Fee__c = 0;
            SumExpectedIncrementalNI.RecurringFee__c ='';
            SumExpectedIncrementalNI.TFFee__c = 0;
            SumExpectedIncrementalNI.FXFee__c = 0;
            SumExpectedIncrementalNI.LGFee__c = 0;
            SumExpectedIncrementalNI.CashFee__c = 0;
            SumExpectedIncrementalNI.ASFee__c = 0;
            SumExpectedIncrementalNI.NonRecurringFee__c ='';
            SumExpectedIncrementalNI.CreditFee__c = 0;
            SumExpectedIncrementalNI.BAFee__c = 0;
            SumExpectedIncrementalNI.DerivativeFee__c = 0;
            SumExpectedIncrementalNI.IBFee__c = 0;
            SumExpectedIncrementalNI.Group__c = this.m_groupId;
            SumExpectedIncrementalNI.Year__c = this.m_year ;
            SumExpectedIncrementalNI.IsProductStrategy__c = false;
            SumExpectedIncrementalNI.IsGroupWallet__c = true;
            SumExpectedIncrementalNI.IsGroupPerformance__c = false;
            SumExpectedIncrementalNI.SummaryType__c = 'ExpectedIncrementalNI';
            upsert SumExpectedIncrementalNI;
            
            //SumExpestedIncrementalNIStep5
            AccountPlanWalletSizing__c SumExpectedIncrementalNIStep5 = new AccountPlanWalletSizing__c();
            SumExpectedIncrementalNIStep5.NIIc__c = 0;
            SumExpectedIncrementalNIStep5.NIId__c = 0;
            SumExpectedIncrementalNIStep5.Fee__c = 0;
            SumExpectedIncrementalNIStep5.RecurringFee__c ='';
            SumExpectedIncrementalNIStep5.TFFee__c = 0;
            SumExpectedIncrementalNIStep5.FXFee__c = 0;
            SumExpectedIncrementalNIStep5.LGFee__c = 0;
            SumExpectedIncrementalNIStep5.CashFee__c = 0;
            SumExpectedIncrementalNIStep5.ASFee__c = 0;
            SumExpectedIncrementalNIStep5.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep5.CreditFee__c = 0;
            SumExpectedIncrementalNIStep5.BAFee__c = 0;
            SumExpectedIncrementalNIStep5.DerivativeFee__c = 0;
            SumExpectedIncrementalNIStep5.IBFee__c = 0;
            SumExpectedIncrementalNIStep5.Group__c = this.m_groupId;
            SumExpectedIncrementalNIStep5.Year__c = this.m_year ;
            SumExpectedIncrementalNIStep5.IsProductStrategy__c = false;
            SumExpectedIncrementalNIStep5.IsGroupWallet__c = false;
            SumExpectedIncrementalNIStep5.IsGroupPerformance__c = true;
            SumExpectedIncrementalNIStep5.SummaryType__c = 'ExpectedIncrementalNIStep5';
            upsert SumExpectedIncrementalNIStep5;
            
            //SumTotalCompanyNI
            //AccountPlanWalletSizing__c SumTotalCompanyNI = new AccountPlanWalletSizing__c();
            SumTotalCompanyNI.NIIc__c = 0;
            SumTotalCompanyNI.NIId__c = 0;
            SumTotalCompanyNI.Fee__c = 0;
            SumTotalCompanyNI.RecurringFee__c ='';
            SumTotalCompanyNI.TFFee__c = 0;
            SumTotalCompanyNI.FXFee__c = 0;
            SumTotalCompanyNI.LGFee__c = 0;
            SumTotalCompanyNI.CashFee__c = 0;
            SumTotalCompanyNI.ASFee__c = 0;
            SumTotalCompanyNI.NonRecurringFee__c ='';
            SumTotalCompanyNI.CreditFee__c = 0;
            SumTotalCompanyNI.BAFee__c = 0;
            SumTotalCompanyNI.DerivativeFee__c = 0;
            SumTotalCompanyNI.IBFee__c = 0;
            SumTotalCompanyNI.Group__c = this.m_groupId;
            SumTotalCompanyNI.Year__c = this.m_year ;
            SumTotalCompanyNI.IsProductStrategy__c = false;
            SumTotalCompanyNI.IsGroupWallet__c = false;
            SumTotalCompanyNI.IsGroupPerformance__c = true;
            SumTotalCompanyNI.SummaryType__c = 'TotalCompanyNI';
            upsert SumTotalCompanyNI;
            
            //SumExpectedIncrementalNIStep6
            //AccountPlanWalletSizing__c SumExpectedIncrementalNIStep6 = new AccountPlanWalletSizing__c();
            SumExpectedIncrementalNIStep6.NIIc__c = 0;
            SumExpectedIncrementalNIStep6.NIId__c = 0;
            SumExpectedIncrementalNIStep6.Fee__c = 0;
            SumExpectedIncrementalNIStep6.RecurringFee__c ='';
            SumExpectedIncrementalNIStep6.TFFee__c = 0;
            SumExpectedIncrementalNIStep6.FXFee__c = 0;
            SumExpectedIncrementalNIStep6.LGFee__c = 0;
            SumExpectedIncrementalNIStep6.CashFee__c = 0;
            SumExpectedIncrementalNIStep6.ASFee__c = 0;
            SumExpectedIncrementalNIStep6.NonRecurringFee__c ='';
            SumExpectedIncrementalNIStep6.CreditFee__c = 0;
            SumExpectedIncrementalNIStep6.BAFee__c = 0;
            SumExpectedIncrementalNIStep6.DerivativeFee__c = 0;
            SumExpectedIncrementalNIStep6.IBFee__c = 0;
            SumExpectedIncrementalNIStep6.Group__c = this.m_groupId;
            SumExpectedIncrementalNIStep6.Year__c = this.m_year ;
            SumExpectedIncrementalNIStep6.IsProductStrategy__c = false;
            SumExpectedIncrementalNIStep6.IsGroupWallet__c = false;
            SumExpectedIncrementalNIStep6.IsGroupPerformance__c = false;
            SumExpectedIncrementalNIStep6.SummaryType__c = 'ExpectedIncrementalNIStep6';
            upsert SumExpectedIncrementalNIStep6;
        }


        /**************************************************************************
        *  Go to Summary Batch 2
        ***************************************************************************/
        GroupWalletSummary2 batch = 
            new GroupWalletSummary2( m_accountWithAccountPlan,m_accountWithoutAccountPlan
                                    , m_groupId
                                    , m_year,m_groupProfileId,m_isGroupWallet );  
        Database.executeBatch(batch ,100); 
        
        /**************************************************************************
        *  Send Email
        ***************************************************************************/
        /*if(m_isGroupWallet){
            string mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/'+'apex/AccountPlanGroupWallet?walletID=&CompanyID=&GroupID='+m_groupProfileId;
            string htmlMsg =  'Refresh Group Wallet batch processing is completed'
                +'<br />Please click below url to view group wallet '
                +'<br />View <a href="'+mainUrl+'"> click here</a>';
            BatchEmailService.SendEmail(BC.getJobId(),'Batch Processing','Refresh Group Wallet batch processing is completed',htmlMsg);
            
        }else if(!m_isGroupWallet){
            string mainUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/' + 'apex/AccountplanGroupPerformanceV2?walletID=&CompanyID=&GroupID=' + m_groupProfileId;
            string htmlMsg = 'Refresh Group Performance batch processing is completed'
                + '<br />Please click below url to view group formance '
                + '<br />View <a href="' + mainUrl + '"> click here</a>';
            BatchEmailService.SendEmail(BC.getJobId(), 'Batch Processing', 'Refresh Group Performance batch processing is completed', htmlMsg);   
        }
        AcctPlanGroupWalletLockService.Unlock(m_groupId);*/
        
    }
}