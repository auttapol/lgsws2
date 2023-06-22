public with sharing class DepositProductDetailViewController extends AbstractCoreClass {
    
    Public class DepositProductDetailWrapper{
        @AuraEnabled 
        public string MarkedDepositAccountNumber { get; set; }
        @AuraEnabled 
        public string ProductName { get; set; }
        @AuraEnabled 
        public string AccountName { get; set; }
        @AuraEnabled 
        public string SubProductGroup { get; set; }
        @AuraEnabled 
        public string OpenedDate { get; set; }
        @AuraEnabled 
        public string MarkedLedgerBalance { get; set; }
        @AuraEnabled 
        public string AccountStatus { get; set; }
        @AuraEnabled 
        public string ODLimit { get; set; }
        @AuraEnabled 
        public string HasJoint { get; set; }
        @AuraEnabled 
        public string MarkedOutStanding { get; set; }
        @AuraEnabled 
        public string MaturityDate { get; set; }
        @AuraEnabled 
        public string MarkedAvgBalanceMTD { get; set; }
        @AuraEnabled 
        public string NumberOfActiveDebitCardBundling { get; set; }
        @AuraEnabled 
        public string InterestRate { get; set; }
        @AuraEnabled 
        public string SMSAlertService { get; set; }
        @AuraEnabled 
        public string InterestEarned { get; set; }
    }

    Public class LastMonthTransactionWrapper{
        @AuraEnabled 
        public string MonthlyAvgDepositTransactions { get; set; }
        @AuraEnabled 
        public string MonthlyAvgTransfersWithinTMB { get; set; }
        @AuraEnabled 
        public string MonthlyAvgWithdrawTransactions { get; set; }
        @AuraEnabled 
        public string MonthlyAvgTransfersToOtherBanks { get; set; }
        @AuraEnabled 
        public string MonthlyAvgBillPaymentTransactions { get; set; }
    }

    public class JointAccountWrapper{
        @AuraEnabled 
        public string OwnerNumber { get; set; }
        @AuraEnabled 
        public string Relationship { get; set; }
    }

    private static boolean isEmployeePayroll(Decimal OutStanding, Decimal AvgBalanceMTD, Boolean isEmployee){
        if(OutStanding == 0 && AvgBalanceMTD == 0 && isEmployee == true) return true;
        return false;
    }

    private static Boolean isEmployee(String tmbCustId) {
        try {
            return [SELECT RTL_Is_Employee__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1 FOR UPDATE].RTL_Is_Employee__c;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Map<String,Object> getDepositProductDetail(String accountNumber,String accountType,String productType, String rmId, String fiiDent, String tmbCustId, String recordId,Map<String,Object> productFrom01){
        Map<String,Object> mapResult = new Map<String,Object>();
        String decAccountNumber = (SFExtIntregration.decryptText(accountNumber)); 
        String decAccountType = (SFExtIntregration.decryptText(accountType));
        Boolean isEmployee = isEmployee(tmbCustId);
        Map<String,Object> mapUnmasked = RTL_ProductHoldingSummaryController.getUnmaskBalance('Deposit_Detail');
        Map<String, Boolean> fieldAccessMap =RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId,'Detail of Deposit Product');
        Object result = RTL_ProductHoldingWebSvcUtils.callbackOSC02(decAccountNumber,decAccountType,productType,rmId,fiiDent,tmbCustId);
        Map<String,Object> result02 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(result));
        // return result02;
        Boolean isError =  (getResult('StatusCode', result) != null) && ((String)getResult('StatusCode', result) != '200') ? true :  (getResult('Status.StatusCode', result) != null) && ((String)getResult('Status.StatusCode', result) != '200') ? true : false;
        String statusCode =  (getResult('StatusCode', result) != null) ? (String)getResult('StatusCode', result) :  getResult('Status.StatusCode', result) != null ? (String)getResult('Status.StatusCode', result) : '';

        if(!isError){
            DepositProductDetailWrapper depositProductDetail = tranformDepositDetail(result02,productFrom01,fieldAccessMap,mapUnmasked,isEmployee);
            List<JointAccountWrapper> jointAccountList = tranformDepositJointAccount(result02,fieldAccessMap);
            LastMonthTransactionWrapper lastMonthTrans = tranformDepositLasttMonth(result02,fieldAccessMap,isEmployee);
            mapResult.put('DepositAccountInfo',depositProductDetail);
            mapResult.put('LastMonthTransactionSummary',lastMonthTrans);
            mapResult.put('JointAccount',jointAccountList);
            mapResult.put('JointAccountStatus',(String)getResult('GetDepositAccountDetailResponse.Result.JointAccount.Status', result02) == 'SUCCESS'? true:false);
        }
        
        mapResult.put('isError',isError);
        mapResult.put('statusCode',statusCode);
        mapResult.put('Message', getResult('Message', result) != null ? (String)getResult('Message', result) : '');
        return mapResult;
    }

    private static DepositProductDetailWrapper tranformDepositDetail(Map<String,Object> result02, Map<String,Object> productFrom01, Map<String, Boolean> fieldAccessMap, Map<String,Object> mapUnmasked,Boolean isEmployee){
        DepositProductDetailWrapper depositDetail = new DepositProductDetailWrapper();
        Map<String,Object> depositProd = (String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Status', result02) == 'SUCCESS'? (Map<String,Object>)getResult('GetDepositAccountDetailResponse.Result.DepositAccount', result02) : new Map<String,Object>();
        String status = (String)depositProd.get('AccountStatus');
        status = status.toLowerCase();

        Boolean isAccountDormant = (status.trim()).length() > 0 ? status.contains('dormant') : false;

        Boolean isDepositUnmasked = mapUnmasked == null;
        Boolean isLedgerBalance = !isDepositUnmasked ? (Boolean)mapUnmasked.get('MarkedLedgerBalance') : false;
        Boolean isAvgOutstanding = !isDepositUnmasked ? (Boolean)mapUnmasked.get('MarkedAvgOutStanding') : false;
        Boolean isOutstanding = !isDepositUnmasked ? (Boolean)mapUnmasked.get('MarkedOutStanding') : false;
        
        Decimal ledgerBalance = depositProd.get('Ledger') == null ? 0 : Double.valueOf((String)depositProd.get('Ledger'));
        Decimal outStanding = depositProd.get('Outstanding') == null ? 0 : Double.valueOf((String)depositProd.get('Outstanding'));
        Decimal avgBalanceMTD = depositProd.get('AvgBalanceMTD') == null ? 0 : Double.valueOf((String)depositProd.get('AvgBalanceMTD'));
        Decimal odLimit = depositProd.get('ODLimit') == null ? 0 : Double.valueOf((String)depositProd.get('ODLimit'));
        Decimal interestEarned = depositProd.get('InterestEarned') == null ? 0 : Double.valueOf((String)depositProd.get('InterestEarned'));
        Boolean isEmployeePayroll = isEmployeePayroll(outStanding, avgBalanceMTD, isEmployee);

        String markedLedgerBalance = ledgerBalance == 0 ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : (String)NumberHelper.MarkDecimal(ledgerBalance);
        String markedAvgBalanceMTD = avgBalanceMTD == 0  ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text :(String)NumberHelper.MarkDecimal(avgBalanceMTD);
        String markedOutstanding = outStanding == 0 ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : (String)NumberHelper.MarkDecimal(outStanding);
       
        String openDate = depositProd.get('OpenedDate') != null ?  String.valueOf(depositProd.get('OpenedDate')): 'Invalid';
        if(openDate != 'Invalid'){
            openDate = openDate.split('\\+')[0];
        }
        
        String maturityDate = depositProd.get('MaturityDate') != null ?  String.valueOf(depositProd.get('MaturityDate')): 'Invalid';
        if(maturityDate != 'Invalid'){
            maturityDate = maturityDate.split('\\+')[0];
        } 
  
        depositDetail.MarkedDepositAccountNumber = !fieldAccessMap.get('Deposit_Detail_MarkedDepositAccountNumbe') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('MarkedDepositAccountNumber');
        depositDetail.ProductName = !fieldAccessMap.get('Deposit_Detail_ProductName') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('ProductName');
        depositDetail.AccountName = !fieldAccessMap.get('Deposit_Detail_AccountName') ? System.Label.Data_Condition_Hidden_Text : (String)depositProd.get('AccountName');
        depositDetail.SubProductGroup = !fieldAccessMap.get('Deposit_Detail_SubProductGroup') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('SubProductGroup');
        depositDetail.OpenedDate = !fieldAccessMap.get('Deposit_Detail_OpenedDate') ? System.Label.Data_Condition_Hidden_Text : openDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(openDate));
        // convertDateValue(NumberHelper.DateFormat(Date.ValueOf(openDate))
        depositDetail.MarkedLedgerBalance = !fieldAccessMap.get('Deposit_Detail_MarkedLedgerBalance') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked ? markedLedgerBalance : isAccountDormant ? markedLedgerBalance : isLedgerBalance ? String.valueOf(ledgerBalance): markedLedgerBalance;
        depositDetail.AccountStatus =  !fieldAccessMap.get('Deposit_Detail_AccountStatus') ? System.Label.Data_Condition_Hidden_Text :  (String)depositProd.get('AccountStatus');
        depositDetail.ODLimit =  !fieldAccessMap.get('Deposit_Detail_ODLimit') ? System.Label.Data_Condition_Hidden_Text : String.valueOf(odLimit);
        depositDetail.HasJoint =  !fieldAccessMap.get('Deposit_Detail_HasJoint') ? System.Label.Data_Condition_Hidden_Text :  (String)depositProd.get('HasJoint');
        depositDetail.MarkedOutStanding =  !fieldAccessMap.get('Deposit_Detail_MarkedOutStanding') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked ? markedOutstanding : isAccountDormant ? markedOutstanding : isOutstanding ? String.valueOf(outstanding) : markedOutstanding;
        depositDetail.MaturityDate =  !fieldAccessMap.get('Deposit_Detail_MaturityDate') ? System.Label.Data_Condition_Hidden_Text : maturityDate != 'Invalid' ? String.ValueOf(NumberHelper.DateFormat(Date.ValueOf(maturityDate))): '';
        depositDetail.MarkedAvgBalanceMTD =  !fieldAccessMap.get('Deposit_Detail_MarkedAvgBalanceMTD') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked ? markedAvgBalanceMTD : isAccountDormant ? markedAvgBalanceMTD : isAvgOutstanding ? String.valueOf(avgBalanceMTD)  : markedAvgBalanceMTD;
        depositDetail.InterestRate =  !fieldAccessMap.get('Deposit_Detail_InterestRate') ? System.Label.Data_Condition_Hidden_Text : (String)depositProd.get('InterestRate');
        depositDetail.SMSAlertService =  !fieldAccessMap.get('Deposit_Detail_SMSAlertService') ? System.Label.Data_Condition_Hidden_Text : (String)depositProd.get('SMSAlertService');
        // depositDetail.InterestEarned =  !fieldAccessMap.get('Deposit_Detail_InterestEarned') ? System.Label.Data_Condition_Hidden_Text : interestEarned == 0 ? '-' : String.valueOf(interestEarned) ;
        // depositDetail.NumberOfActiveDebitCardBundling =  !fieldAccessMap.get('Deposit_Detail_NumberOfActiveDebitCardBu') ? System.Label.Data_Condition_Hidden_Text : depositProd.get('NumberOfActiveDebitCardBundling') != null ? (String)depositProd.get('NumberOfActiveDebitCardBundling') : '0';
        depositDetail.NumberOfActiveDebitCardBundling =  !fieldAccessMap.get('Deposit_Detail_NumberOfActiveDebitCardBu') ? System.Label.Data_Condition_Hidden_Text : depositProd.get('NumberOfActiveDebitCardBundling') != null ? (String)depositProd.get('NumberOfActiveDebitCardBundling') : '';
        depositDetail.InterestEarned =  !fieldAccessMap.get('Deposit_Detail_InterestEarned') ? System.Label.Data_Condition_Hidden_Text : interestEarned == 0 ? '0.00' : String.valueOf(interestEarned) ;
        System.debug('RETURN:');
        System.debug(depositDetail);
        return depositDetail;
    }

    private static List<JointAccountWrapper> tranformDepositJointAccount(Map<String,Object> result02, Map<String, Boolean> fieldAccessMap){
        List<JointAccountWrapper> jointAccountList = new List<JointAccountWrapper>();
        List<Object> depositJointAccount =  (String)getResult('GetDepositAccountDetailResponse.Result.JointAccount.Status', result02) == 'SUCCESS' 
                                            && getResult('GetDepositAccountDetailResponse.Result.JointAccount.JointAccount', result02) != null
                                            ? (List<Object>)getResult('GetDepositAccountDetailResponse.Result.JointAccount.JointAccount', result02) : new List<Object>();
        for(Object eachJoint : depositJointAccount){
            JointAccountWrapper eachJointAccount = new JointAccountWrapper();
            Map<String,Object> mapEachJoint = (Map<String,Object>)eachJoint;
            eachJointAccount.OwnerNumber =  !fieldAccessMap.get('Deposit_Detail_OwnerNumber') ? System.Label.Data_Condition_Hidden_Text : (String)mapEachJoint.get('OwnerNumber');
            eachJointAccount.Relationship =  !fieldAccessMap.get('Deposit_Detail_Relationship') ? System.Label.Data_Condition_Hidden_Text : (String)mapEachJoint.get('Relationship');
            jointAccountList.add(eachJointAccount);
        }
        return jointAccountList;
    }

    private static LastMonthTransactionWrapper tranformDepositLasttMonth(Map<String,Object> result02, Map<String, Boolean> fieldAccessMap,Boolean isEmployee){
        LastMonthTransactionWrapper lastMonthTrans = new LastMonthTransactionWrapper();
        Map<String,Object> depositProd =  (String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Status', result02) == 'SUCCESS'? (Map<String,Object>)getResult('GetDepositAccountDetailResponse.Result.DepositAccount', result02) : new Map<String,Object>();
        Decimal avgOutstanding = getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', result02) != null ? (Decimal)getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', result02) : 0;
        Decimal outstanding = getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Outstanding', result02) != null ? Double.valueOf(getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Outstanding', result02)) : 0;
        Boolean isEmployeePayroll = isEmployeePayroll(outstanding, avgOutstanding, isEmployee);
        Map<String,Object> mapLastMonth =  (String)getResult('GetDepositAccountDetailResponse.Result.LastMonthTransactionSummary.Status', result02) == 'SUCCESS' 
                                            && getResult('GetDepositAccountDetailResponse.Result.LastMonthTransactionSummary', result02) != null
                                            ? (Map<String,Object>)getResult('GetDepositAccountDetailResponse.Result.LastMonthTransactionSummary', result02) : new Map<String,Object>();
        lastMonthTrans.MonthlyAvgDepositTransactions =  !fieldAccessMap.get('Deposit_Detail_MonthlyAvgDepositTransact') || isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : mapLastMonth.get('MonthlyAvgDepositTransactions') != null ? (String)mapLastMonth.get('MonthlyAvgDepositTransactions') : '';
        lastMonthTrans.MonthlyAvgTransfersWithinTMB =  !fieldAccessMap.get('Deposit_Detail_MonthlyAvgTransfersWithin') || isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : mapLastMonth.get('MonthlyAvgTransfersWithinTMB') != null ? (String)mapLastMonth.get('MonthlyAvgTransfersWithinTMB'): '';
        lastMonthTrans.MonthlyAvgWithdrawTransactions =  !fieldAccessMap.get('Deposit_Detail_MonthlyAvgWithdrawTransac') || isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : mapLastMonth.get('MonthlyAvgWithdrawTransactions') != null ? (String)mapLastMonth.get('MonthlyAvgWithdrawTransactions') : '';
        lastMonthTrans.MonthlyAvgTransfersToOtherBanks =  !fieldAccessMap.get('Deposit_Detail_MonthlyAvgTransfersToOthe') || isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : mapLastMonth.get('MonthlyAvgTransfersToOtherBanks') != null ? (String)mapLastMonth.get('MonthlyAvgTransfersToOtherBanks'):'';
        lastMonthTrans.MonthlyAvgBillPaymentTransactions =  !fieldAccessMap.get('Deposit_Detail_MonthlyAvgBillPaymentTran') || isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : mapLastMonth.get('MonthlyAvgBillPaymentTransactions') != null ? (String)mapLastMonth.get('MonthlyAvgBillPaymentTransactions') : '';
        return lastMonthTrans;
    }

    private static String convertDateValue(String dateStr){
        Integer year = Integer.valueOf(dateStr.split('/')[2]);
        System.debug(year);

        Integer month = Integer.valueOf(dateStr.split('/')[1]);
        System.debug(month);

        Integer day = Integer.valueOf(dateStr.split('/')[0]);
        System.debug(day);

        Date dateResult = date.newInstance(year,month,day);
        return dateResult.format();
    }
}