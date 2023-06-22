public class AcctPlanComProfileTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
 
        
    public static void handlerAfterInsert(List<AcctPlanCompanyProfile__c> portNew){
        List<AcctPlanCompanyProfile__c> listNew = checkConditionApprove(portNew,null);
        if( listNew.size() > 0 ){
            System.debug(':::: afterInsert Start ::::');
            Trigger_CSV(listNew,null,STR_INSERT);    
            System.debug(':::: afterInsert End ::::');
        }        
    }
    
    public static void handlerAfterUpdate(List<AcctPlanCompanyProfile__c> portNew,List<AcctPlanCompanyProfile__c> portOld){
        List<AcctPlanCompanyProfile__c> listNew = checkConditionApprove(portNew,portOld);
        if( listNew.size() > 0 ){
            System.debug(':::: afterUpdate Start ::::');
            Trigger_CSV(listNew,portOld,STR_UPDATE);    
            System.debug(':::: afterUpdate End ::::');
        }      
    }
    
    public static List<AcctPlanCompanyProfile__c> checkConditionApprove(List<AcctPlanCompanyProfile__c> portNew,List<AcctPlanCompanyProfile__c> portOld){
        List<AcctPlanCompanyProfile__c> listReturn = new List<AcctPlanCompanyProfile__c>();
        Map<Id,AcctPlanCompanyProfile__c> mapPortOld = new Map<Id,AcctPlanCompanyProfile__c>();
        if( portOld != null && portOld.size() > 0 ){
            mapPortOld.putAll(portOld);
        }
        system.debug(' Test Check Approve ');
        for(AcctPlanCompanyProfile__c port : portNew){
            if(port.Status__c.indexOf('Approved') >= 0 ){
                listReturn.add(port);
            }
        }
        
        return listReturn;
    }
    
    
     
     public static void Trigger_CSV(List<AcctPlanCompanyProfile__c> portNew,List<AcctPlanCompanyProfile__c> portOld,String eventMode){
     System.debug(':::: Trigger_CSV Start ::::');
     
     String comID;
     for(AcctPlanCompanyProfile__c cp: portNew){
     comID = String.valueOf(cp.id);
     }
     system.debug(' Test Account ID = '+ comID);
       List<AcctPlanWallet__c > WalletList = [SELECT ID,Name,AcctPlanCompanyProfile__r.Account__c,TotalWalletNiic__c,TotalWalletNIID__c,Total_Fee__c,
                                                       SumOfWalletNiicYearly__c, TotalWalletNIID_Mini__c , Total_Fee_Mini__c
                                                       FROM AcctPlanWallet__c
                                                       WHERE AcctPlanCompanyProfile__c =:comID ];
                                                        
      List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> AcctPlanProdStrategyList= AccountPlanProductStrategyService.getCompaniesProductStrategyInfo(new Set<ID> { comID });
      System.debug(':AcctPlanProdStrategyList: '+AcctPlanProdStrategyList);  
      
      
        decimal TotalNI= 0;
        decimal TotalNIc= 0;
        decimal TotalNId= 0;
        decimal TotalFee= 0;      
        Id acctID;   
         
        //Edit by: Danudath 18-04-2017
        //CR Wallet from Account plan, capture data NI, NIIc, NIId, Fee from account plan step 4 
        //Keep data in Customer after account plan approved
        decimal TotalWalletNi = 0;
        decimal TotalWalletNIIc = 0;
        decimal TotalWalletNIId = 0;
        decimal TotalWalletFee = 0; 
        //---------------------
        
        Decimal feeCompanyWallet = 0;
        Decimal feeCompanyActualNI = 0;
        Decimal feeCompanyAdjustNI = 0;  
        Decimal feeCompanyExistingSOW = 0; 
        Decimal feeCompanyExpectedNIFromStep5 = 0;
        for(AccountPlanProductStrategyService.AcctPlanProdStrategyInfo item : acctPlanProdStrategyList){
            
             if(item.Name == '1. NIIc'){
                 TotalNIc = item.TotalCompanyNI;
             }else if(item.Name == '2. NIId'){
                 TotalNId = item.TotalCompanyNI;
             }else if(item.Name == '3.1 TF Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.2 FX Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.3 L/G Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.4 Cash Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.5 AS Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.6 Credit Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.7 BA Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.8 Derivative Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }else if(item.Name == '3.9 IB Fee'){
                feeCompanyWallet += item.WalletSizing;                        
                feeCompanyActualNI += item.AnnualizedPerformance;                
                feeCompanyAdjustNI += item.AdjustNI;
                feeCompanyExistingSOW += item.ExistingSOW;
                feeCompanyExpectedNIFromStep5 += item.ExpectedIncrementalNIFromStep5;
            }  
            
            //26-07-2017  CR Wallet from account plan-----
            if(item.Name == '1. NIIc'){
                TotalWalletNIIc = item.WalletSizing;
            }else if(item.Name == '2. NIId'){
                TotalWalletNIId = item.WalletSizing;
            }else if(item.Name == '3. Fee'){
                TotalWalletFee = item.WalletSizing;
            }
            // ---------------
            
        }
      
         TotalFee = feeCompanyAdjustNI + feeCompanyExpectedNIFromStep5;
         
         TotalWalletNi = TotalWalletNIIc + TotalWalletNIId + TotalWalletFee ; //Update total NI Wallet
         
                for(AcctPlanWallet__c wallet : WalletList){                                    
                        
                  acctID = wallet.AcctPlanCompanyProfile__r.Account__c; 
                    
                }
                TotalNI= TotalNIc + TotalNId +TotalFee;    
                
                
               System.debug('TotalNI '+TotalNI); 
               System.debug('TotalNIc '+TotalNIc); 
               System.debug('TotalNId '+TotalNId); 
               System.debug('TotalFee '+TotalFee); 
                   
               if(acctID!=null){
               Account Customer = [SELECT ID,NI_Plan__c,NIIc_Plan__c,NIId_Plan__c,Fee_Plan__c,
                                   NI_Account_Plan__c, NIIc_Account_Plan__c, NIId_Account_Plan__c, 
                                   Fee_Account_Plan__c, As_of_Date_Account_Plan__c,Segment_crm__c,Account_Plan_Form__c
                                   FROM Account WHERE Id=:acctID ];
               Customer.NI_Plan__c = TotalNI;
               Customer.NIIc_Plan__c = TotalNIc;
               Customer.NIId_Plan__c= TotalNId;
               Customer.Fee_Plan__c = TotalFee;
               Customer.As_of_Date_Account_Plan__c = System.today();  
                   
                Customer.NI_Account_Plan__c =  TotalWalletNi;
                Customer.NIIc_Account_Plan__c = TotalWalletNIIc;
                Customer.NIId_Account_Plan__c = TotalWalletNIId;
                Customer.Fee_Account_Plan__c = TotalWalletFee;   

               update Customer;
               }
        
        //return WalletList;
        System.debug(':::: Trigger_CSV End::::');
    }

        }