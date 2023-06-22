public  without sharing  class  AccountPlanWalletSelector {

 public static string sqlWallet(){
    return  '   SELECT ID,                                   '+
    '       AcctPlanCompanyProfile__c,    AcctPlanCompanyProfile__r.Account__c ,      '+
    '       AvgOperatingDepBalance__c ,                      '+
    '       CashCycle__c ,                                   '+
    '       CashOnHand__c ,                                  '+
    '       COGSAmount__c ,                                  '+
    '       COGSPercent__c ,                                 '+
    '       CollectionExportFeeCharge__c ,                   '+
    '       CollectionExportStandardFee__c ,                 '+
    '       EstimatedSalesAmtPerYear__c ,                    '+
    '       EstimatedSalesPercent__c ,                       '+
    '       InvestmentAmount__c ,                            '+
    '       NimdPercent_OperatingTransaction__c,             '+
    '       NimdPercent_CashOnHand__c,                       '+
    '       OperatingExpAmount__c ,                          '+
    '       SumOfCollectionCurrencyAmtPerYear__c ,           '+
    '       SumOfCollectionCurrencyPortion__c ,              '+
    '       SumOfCollectionDomesticVolumn__c ,               '+
    '       SumOfCollectionExportVolPercent__c ,             '+
    '       SumOfCollectionExportWalletTradeFee__c ,         '+
    '       SumOfCollectionVolumnPercent__c ,                '+
    '       SumOfCollectionWalletCashFee__c ,                '+
    '       SumOfDepositInternationalAmtPerMonth__c ,        '+
    '       SumOfPaymentCurrencyAmtPerYear__c ,              '+
    '       SumOfPaymentCurrencyPortion__c ,                 '+
    '       SumOfPaymentDomesticAvgPerMonth__c ,             '+
    '       SumOfPaymentDomesticVolPercent__c ,              '+
    '       SumOfPaymentDomesticWalletCashFee__c ,           '+
    '       SumOfPaymentImportImportVol__c ,                 '+
    '       SumOfPaymentImportNoOfTransaction__c ,           '+
    '       SumOfPaymentImportVolPercent__c ,                '+
    '       SumOfPaymentImportWalletTFFee__c ,               '+
    '       SumOfCollectionExportStandardFee__c,             '+
    '       SumOfCollectionExportFeeCharge__c,               '+
    '       SumOfWalletCashFee__c ,                          '+
    '       SumOfWalletTFFee__c ,                            '+
    '       TotalDomesticAmtPerYear__c ,                     '+
    '       TotalDomesticPercent__c ,                        '+
    '       TotalExportAmtPerYear__c ,                       '+
    '       TotalExportAvgPerMonth__c,                       '+
    '       TotalExportPercent__c,                           '+
    '       TotalPayment__c ,                                '+
    '       TotalPaymentDomesticAmtPerYear__c ,              '+
    '       TotalPaymentDomesticPercent__c ,                 '+
    '       TotalPaymentImportAmtPerYear__c ,                '+
    '       TotalPaymentImportPercent__c ,                   '+
    '       TotalWalletNIID__c ,                             '+
    '       TotalWalletNiic__c,                              '+
    '       WalletNiid_CashOnHand__c ,                       '+
    '       WalletNiid_OperatingTransaction__c,              '+
    '       HighSeasonStartMonth__c,                         '+
    '       HighSeasonEndMonth__c,                           '+
    '       BusinessHasSeasonal__c,                          '+
    '       DataAsOfMonthFacilityDomestic__c ,               '+
    '       DataAsOfMonthFacilityInternational__c ,          '+
    '       DataAsOfYearFacilityDomestic__c ,                '+
    '       DataAsOfYearFacilityInternational__c ,           '+
    '       LGPurchaseAmountPerMonth__c,                     '+
    '       LGPurchaseCreditTerm__c,                         '+
    '       LGPurchaseRequiredLGPortion__c,                  '+
    '       LGPurchaseRequiredLGAmount__c,                   '+
    '       LGPurchaseLGFee__c,                              '+
    '       LGPurchaseTotalWalletLGFee__c,                   '+
    '       ShortTermWalletLGFee__c ,                        '+
    '       LongTermWalletLGFee__c ,                         '+
    '       SumOfCapitalExpenditurePlanCreditFee__c ,        '+
    '       SumOfCapitalExpenditurePlanNIIC__c ,             '+
    '       SumOfCapitalExpenditurePlanProjectAmt__c ,       '+
    '       SumOfCreditFacilityLimit__c ,                    '+
    '       SumOfCreditFacilityLimitInter__c ,               '+
    '       SumOfCreditFacilityOutstanding__c ,              '+
    '       SumOfCreditFacilityOutstandingInter__c ,         '+
    '       SumOfExistingLongTermLoan__c ,                   '+
    '       SumofExistingLongTermLoanNIIC__c ,               '+
    '       SumOfExportTransactionLimit__c ,                 '+
    '       SumOfExportTransactionOutStanding__c ,           '+
    '       SumOfWalletCreditFeeYearly__c ,                  '+
    '       SumOfWalletNiicLongTermLoan__c ,                 '+
    '       SumOfWalletNiicYearly__c,                        '+
    '       SumOfWalletLGFeeYearly__c,                       '+
    '       SumOfAcctPlanForeignWalletFXFeePerYear__c ,      '+


    '       WalletASFee_AgencyService__c ,                   '+
    '       WalletASFee_Custodian__c ,                       '+
    '       WalletASFee_FundSupervisory__c,                  '+
    '       WalletASFee_MiddleOffice__c,                     '+
    '       WalletASFee_RegistrarPaymentAgent__c ,           '+
    '       SumOfWalletASFee__c ,           '+

    '       RequestLGFromBuyerOrderPerBuyer__c,              '+
    '       RequestLGFromBuyerLGPercent__c,                  '+
    '       RequestLGFromBuyerWhoPayLGFee__c,                '+
    '       ExistingAmountLGUtilities__c,                    '+
    '       ExistingAmountLGTax__c,                          '+
    '       AmtOfCreditFaciWithTMB__c ,                      '+
    '       ProtectionPercent__c,                            '+
    '       RequiredProtectionAmt__c,                        '+
    '       BA_Premium__c,                                   '+
    '       WalletOfBAFee__c,                                '+
    '       TotalWalletBAFee__c,                             '+
    '       TotalCreditFee__c,                               '+
    '       MaxCreditFeeWorkingCapital__c,                   '+
    '       Total_Fee__c , SumOfWalletFXFeePerYear__c        '+
    '   FROM                                                 '+
    '       AcctPlanWallet__c                                ';
 }


 // SOQL Statement
 public static string sqlWalletByIds(){
    return sqlWallet()  +'  WHERE  Id IN : walletIds ';
 }
public static string sqlWalletByCompanyProfileIds(){
    return sqlWallet()  +'  WHERE  AcctPlanCompanyProfile__c IN : companyProfileIds ';
 }



 public static List<AcctPlanWallet__c> getWalletByIds(Set<Id> walletIds) {   
    if(walletIds == null || walletIds.size() < 1 )
    throw new AccountPlanWalletSelectorException('Set of walletIds  Cannot be null');
    string sql = sqlWalletByIds();
    system.debug('::: sql' + sql);
    return (List<AcctPlanWallet__c>) Database.query(sql);
 }

public static List<AcctPlanWallet__c> getWalletByCompanyProfileIds(Set<Id> companyProfileIds) {   
   
    System.debug('::: companyProfileIds '+ companyProfileIds);


    if(companyProfileIds == null || companyProfileIds.size() < 1 )
    throw new AccountPlanWalletSelectorException('Set of companyProfileIds  Cannot be null');
    string sql = sqlWalletByCompanyProfileIds();
    system.debug('::: sql' + sql);
    return (List<AcctPlanWallet__c>) Database.query(sql);
 }


// Exception
public class AccountPlanWalletSelectorException extends Exception{}
}