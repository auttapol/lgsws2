public class AccountPlanWalletUtilities {
    
    public static List<AcctPlanWallet__c>  walletList {get{
        if(walletList == null){
            walletList = new List<AcctPlanWallet__c>();
        }
        return walletList; 
    }set;}
    
    public static List<AcctPlan_Questionnaire_Template__c> questionTemplate {get{
         if(questionTemplate == null){
            questionTemplate = new List<AcctPlan_Questionnaire_Template__c>();
        }
        return questionTemplate; 
        
    }set;}
    
    
    public static List<AcctPlan_Questionnaire_Template__c> queryQuestionnaireTemplate(String domain){
        questionTemplate =  [SELECT ID,
                            Account_Plan_Page_Name__c ,
                            Answer_Field_Type__c ,
                            Opportunity__c,
                            Product_Label__c,
                             Sub_Domain__c,
                            Question__c ,
                            Question_TH__c,
                            Segment__c,
                            SEQ__c ,
                            Sub_Segment__c ,
                            Sub_Segment_SEQ__c 
                            FROM AcctPlan_Questionnaire_Template__c
                            WHERE Account_Plan_Page_Name__c =: domain
                            ORDER BY  SEQ__c ASC,Sub_Segment_SEQ__c ASC
                            ];
        
        return questionTemplate;
    }
    
    
    public static List<AcctPlanWallet__c> queryWalletbyCompanyID (String CompanyID){
        walletList = [SELECT ID,
                      AcctPlanCompanyProfile__c,
                      AvgOperatingDepBalance__c ,
                      CashCycle__c ,
                      CashOnHand__c ,
                      COGSAmount__c ,
                      COGSPercent__c ,
                      CollectionExportFeeCharge__c ,
                      CollectionExportStandardFee__c ,
                      EstimatedSalesAmtPerYear__c ,
                      EstimatedSalesPercent__c ,
                      InvestmentAmount__c ,
                      NimdPercent_OperatingTransaction__c, 
                      NimdPercent_CashOnHand__c,
                      OperatingExpAmount__c ,
                      SumOfCollectionCurrencyAmtPerYear__c ,
                      SumOfCollectionCurrencyPortion__c ,
                      SumOfCollectionDomesticVolumn__c ,
                      SumOfCollectionExportVolPercent__c ,
                      SumOfCollectionExportWalletTradeFee__c ,
                      SumOfCollectionVolumnPercent__c ,
                      SumOfCollectionWalletCashFee__c ,
                      SumOfDepositInternationalAmtPerMonth__c ,
                      SumOfPaymentCurrencyAmtPerYear__c ,
                      SumOfPaymentCurrencyPortion__c ,
                      SumOfPaymentDomesticAvgPerMonth__c ,
                      SumOfPaymentDomesticVolPercent__c ,
                      SumOfPaymentDomesticWalletCashFee__c ,
                      SumOfPaymentImportImportVol__c ,
                      SumOfPaymentImportNoOfTransaction__c ,
                      SumOfPaymentImportVolPercent__c ,
                      SumOfPaymentImportWalletTFFee__c ,
                      SumOfCollectionExportStandardFee__c,
                      SumOfCollectionExportFeeCharge__c,
                      SumOfWalletCashFee__c ,
                      SumOfWalletTFFee__c ,
                      TotalDomesticAmtPerYear__c ,
                      TotalDomesticPercent__c , 
                      TotalExportAmtPerYear__c ,
                      TotalExportAvgPerMonth__c,
                      TotalExportPercent__c,
                      TotalPayment__c ,
                      TotalPaymentDomesticAmtPerYear__c ,
                      TotalPaymentDomesticPercent__c ,
                      TotalPaymentImportAmtPerYear__c ,
                      TotalPaymentImportPercent__c ,
                      TotalWalletNIID__c ,
                      TotalWalletNIID_Mini__c ,
                      TotalWalletNiic__c,
                      WalletNiid_CashOnHand__c ,
                      WalletNiid_OperatingTransaction__c,
                      HighSeasonStartMonth__c,
                      HighSeasonEndMonth__c, 
                      BusinessHasSeasonal__c,
                      DataAsOfMonthFacilityDomestic__c ,
                      DataAsOfMonthFacilityInternational__c ,
                      DataAsOfYearFacilityDomestic__c ,
                      DataAsOfYearFacilityInternational__c ,
                      LGPurchaseAmountPerMonth__c,
                      LGPurchaseCreditTerm__c,
                      LGPurchaseRequiredLGPortion__c,
                      LGPurchaseRequiredLGAmount__c,
                      LGPurchaseLGFee__c,
                      LGPurchaseTotalWalletLGFee__c,
                      ShortTermWalletLGFee__c ,
                      LongTermWalletLGFee__c ,
                      SumOfCapitalExpenditurePlanCreditFee__c ,
                      SumOfCapitalExpenditurePlanNIIC__c ,
                      SumOfCapitalExpenditurePlanProjectAmt__c ,
                      SumOfCreditFacilityLimit__c ,
                      SumOfCreditFacilityLimitInter__c ,
                      SumOfCreditFacilityOutstanding__c ,
                      SumOfCreditFacilityOutstandingInter__c ,
                      SumOfExistingLongTermLoan__c ,
                      SumofExistingLongTermLoanNIIC__c ,
                      SumOfExportTransactionLimit__c ,
                      SumOfExportTransactionOutStanding__c ,
                      SumOfWalletCreditFeeYearly__c ,
                      SumOfWalletNiicLongTermLoan__c ,
                      SumOfWalletNiicYearly__c,
                      SumOfWalletLGFeeYearly__c,
                      SumOfAcctPlanForeignWalletFXFeePerYear__c ,
                      RequestLGFromBuyerOrderPerBuyer__c,
                      RequestLGFromBuyerLGPercent__c,
                      RequestLGFromBuyerWhoPayLGFee__c,
                      ExistingAmountLGUtilities__c,
                      ExistingAmountLGTax__c,
                      AmtOfCreditFaciWithTMB__c ,
                      ProtectionPercent__c,
                      RequiredProtectionAmt__c,
                      BA_Premium__c,
                      WalletOfBAFee__c,
                      TotalWalletBAFee__c,
                      TotalCreditFee__c,
                      MaxCreditFeeWorkingCapital__c,
                      Total_Fee_Mini__c ,
                      Total_Fee__c ,
                       DataAsOfDeposit__c ,
                       FICustomerFlag__c,
                       FI_Customer_FX__c,
                       CashOnHand_Nimd__c,
                       InvestmentAmount_NIMd__c ,
                       AS_Fee__c ,
                       AS_Fee_AUM__c ,
                       Wallet_FX_Fee_Yearly_THB__c,
                       Spread__c,
                       FX_Volume_per_Year_THB__c,
                       Asset_Under_Management__c,
                       SumOfWalletASFee__c,
                       WalletASFee_AgencyService__c, 
             WalletASFee_Custodian__c,  
             WalletASFee_FundSupervisory__c, 
             WalletASFee_MiddleOffice__c, 
             WalletASFee_RegistrarPaymentAgent__c
                      
                 FROM AcctPlanWallet__c
                 WHERE AcctPlanCompanyProfile__c =:CompanyID];
        
        
        
        return walletList;
    }

}