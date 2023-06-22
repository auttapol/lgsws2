public with sharing class LoanProductDetailViewController extends AbstractCoreClass {

    public class LoanProductDetailWrapper{
        @AuraEnabled 
        public string MarkedLoanAccountNumber { get; set; }
        @AuraEnabled 
        public string ProductName {get; set; }
        @AuraEnabled
        public String OpenDate {get;set;}
        @AuraEnabled 
        public string SubProductGroup {get; set; }
        @AuraEnabled
        public String AccountStatus {get;set;}
        @AuraEnabled
        public String CampaignName {get;set;}
        @AuraEnabled 
        public string HasCoBorrower {get; set; }
        @AuraEnabled
        public String ContractEndDate {get;set;}
        @AuraEnabled 
        public string MarkedOutstanding {get; set; }
        @AuraEnabled
        public String LastPaymentDate {get;set;}
        @AuraEnabled 
        public string MarkedVLimit {get; set; }
        @AuraEnabled
        public String PaymentDueDate {get;set;}
        @AuraEnabled
        public String CurrentTenor {get;set;}
        @AuraEnabled
        public String Tenor {get;set;}
        @AuraEnabled
        public String Status {get;set;}
    }
    public class LoanProductPaymentWrapper{
        @AuraEnabled
        public String PaymentMethod {get;set;}
        @AuraEnabled
        public String PayrollDeductionUnit {get;set;}
        @AuraEnabled
        public String SavingAccount {get;set;}
        @AuraEnabled 
        public String InstallmentBalance {get; set; }
        @AuraEnabled
        public String Status {get;set;}
    }

    public class LoanInterestPlanWrapper{
        @AuraEnabled
        public String AccountNumber {get;set;}
        @AuraEnabled
        public String Period {get;set;}
        @AuraEnabled
        public String InterestRate {get;set;}
    }

    public class LoanCoBorrowerWrapper{
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Relationship {get;set;}
        @AuraEnabled
        public String Status {get;set;}
    }

    public class VehicleInformationWrapper{
        @AuraEnabled
        public String license_no {get;set;}
        @AuraEnabled
        public String car_details {get;set;}
        @AuraEnabled
        public String chasis_no {get;set;}
        @AuraEnabled
        public String engine_no {get;set;}
        @AuraEnabled
        public String car_regis_date {get;set;}
        @AuraEnabled
        public String committee_price {get;set;}
        @AuraEnabled
        public String tax_due_date {get;set;}
        @AuraEnabled
        public String req_date {get;set;}
        @AuraEnabled
        public String custdn_status_desc {get;set;}
        @AuraEnabled
        public String past_due_payment_count {get;set;}
        @AuraEnabled
        public String late_charges_amount {get;set;}
        @AuraEnabled
        public String total_past_due_amount {get;set;}
        @AuraEnabled
        public String fee_due_amount {get;set;}
        @AuraEnabled
        public Boolean isSuccess {get;set;}
        @AuraEnabled
        public Boolean isTimeout {get;set;}
        @AuraEnabled
        public Boolean isError {get;set;}
        @AuraEnabled
        public String Message {get;set;}
       
    }

    public class GuarantorWrapper{
        @AuraEnabled
        public String tha_fullname {get;set;}
        @AuraEnabled
        public String id_no {get;set;}
        @AuraEnabled
        public String id_birth_date {get;set;}
    }

    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                timeout = productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static Boolean isEmployee(String tmbCustId) {
        try {
            return [SELECT RTL_Is_Employee__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1 FOR UPDATE].RTL_Is_Employee__c;
        } catch (Exception e) {
            return false;
        }
    }

    private static Account getAccount(String RMID) {
        try {
            // return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1];
            return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1 FOR UPDATE];
        } catch (Exception e) {
            return new Account();
        }
    }

    private static Boolean isEmployee{get;set;}

    @AuraEnabled
    public static Map<String,Object> getLoanProductDetail(String rmId, String fiiDent, String accountNumber, String accountType, String tmbCustId,String recordId,  Map<String, Object> resultFrom01){
        Map<String,Object> mapLoanResult = new Map<String,Object>();
        LoanProductPaymentWrapper loanPaymentWrapper = new LoanProductPaymentWrapper();
        LoanProductDetailWrapper LoanInformation = new LoanProductDetailWrapper();
        List<LoanCoBorrowerWrapper> loanCoBorrower = new List<LoanCoBorrowerWrapper>();
        List<LoanInterestPlanWrapper> loanInterestPlanWrapperList = new List<LoanInterestPlanWrapper>();
        String decAccountNumber = Test.isRunningTest() ? accountNumber : (SFExtIntregration.decryptText(accountNumber)); 
        String decAccountType = Test.isRunningTest() ? accountType : (SFExtIntregration.decryptText(accountType));
        Map<String,Object> mapUnmasked = RTL_ProductHoldingSummaryController.getUnmaskBalance('Loan_Detail');
        Map<String, Boolean> fieldAccessMap =RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId,'Detail of Loan Product');
        isEmployee = isEmployee(tmbCustId);

        Object result = RTL_ProductHoldingWebSvcUtils.callbackOSC04(decAccountNumber,decAccountType,rmId,fiiDent,tmbCustId);
        Map<String,Object> mapResult04 = (Map<String,Object>)result;
        
        Boolean isError =  (getResult('StatusCode', result) != null) && ((String)getResult('StatusCode', result) != '200') ? true :  (getResult('Status.StatusCode', result) != null) && ((String)getResult('Status.StatusCode', result) != '200') ? true:false;
        String coBorrowStatus = !isError && getResult('GetLoanAccountDetailResponse.Result.CoBorrowerInformation.Status', result) != null ? (String)getResult('GetLoanAccountDetailResponse.Result.CoBorrowerInformation.Status', result):'';
        System.debug('mapResult04 :'+mapResult04);
        LoanInformation = tranformLoanInfoProductdetail(mapResult04,mapUnmasked,resultFrom01,fieldAccessMap,isError);
        loanCoBorrower = tranformLoanCoBorrowerdetail(mapResult04,fieldAccessMap,isError);
        loanInterestPlanWrapperList = tranformLoanInterestPlanDetail(mapResult04,fieldAccessMap,isError);
        loanPaymentWrapper = tranformLoanProductPaymentDetail(mapResult04,fieldAccessMap,isError);
        if(!isError && (Map<String,Object>)getResult('GetLoanAccountResponse.AcctInqRs.LoanAcctId', result) != null){
            mapLoanResult.put('AcctType',(String)getResult('GetLoanAccountResponse.AcctInqRs.LoanAcctId.AcctType', result));
        }

        mapLoanResult.put('LoanProductDetail',LoanInformation);
        mapLoanResult.put('CoBorrowerInformation',loanCoBorrower);
        mapLoanResult.put('CoBorrowerInformationStatus',coBorrowStatus);
        mapLoanResult.put('InterestPlan',loanInterestPlanWrapperList);
        mapLoanResult.put('LoanPaymentInformation',loanPaymentWrapper);
        if(isError){
            mapLoanResult.put('StatusCode',(String)getResult('StatusCode', result));
            mapLoanResult.put('Timeout',(String)getResult('StatusCode', result) == '500' ? true : false);
            // (String)getResult('StatusCode', result)
        }

        return mapLoanResult;
    }

    public static LoanProductPaymentWrapper tranformLoanProductPaymentDetail(Map<String,Object> result,  Map<String, Boolean> fieldAccessMap, Boolean isError){
        Map<String,Object> loanProduct = !isError && (String)getResult('GetLoanAccountDetailResponse.Result.LoanPaymentInformation.Status', result) == 'SUCCESS' ? (Map<String,Object>)getResult('GetLoanAccountDetailResponse.Result.LoanPaymentInformation.LoanPayment', result) : new Map<String,Object>();
        
        LoanProductPaymentWrapper loanPaymentWrapper = new LoanProductPaymentWrapper();

        Decimal installment = loanProduct.get('InstallmentBalance') != null ? (Double.valueOf(loanProduct.get('InstallmentBalance'))) : 0;
        loanPaymentWrapper.InstallmentBalance = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_InstallmentBalance') ? System.Label.Data_Condition_Hidden_Text :  (installment.format()).contains('.') ? installment.format() : installment.format() + '.00';
        loanPaymentWrapper.SavingAccount = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_SavingAccount') ? System.Label.Data_Condition_Hidden_Text : NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo((String)loanProduct.get('SavingAccount')));
        loanPaymentWrapper.PaymentMethod = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_PaymentMethod') ? System.Label.Data_Condition_Hidden_Text : (RTL_Payment_Method__c.getValues((String)loanProduct.get('PaymentMethod')) != null ? RTL_Payment_Method__c.getValues((String)loanProduct.get('PaymentMethod')).Value__c : '');
        loanPaymentWrapper.PayrollDeductionUnit = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_PayrollDeductionUnit') ? System.Label.Data_Condition_Hidden_Text : (String)loanProduct.get('PayrollDeductionUnit');
        loanPaymentWrapper.Status = (String)getResult('Result.LoanPaymentInformation.Status', result);
        return loanPaymentWrapper;
    }

    public static LoanProductDetailWrapper tranformLoanInfoProductdetail(Map<String,Object> result,Map<String, Object> unmaskedMap, Map<String,Object> productFrom01,Map<String, Boolean> fieldAccessMap, Boolean isError){
        LoanProductDetailWrapper loanProductDetail = new LoanProductDetailWrapper();
        
        Boolean isLoanUnmasked = unmaskedMap == null;
        Boolean isUnmaskedOutstanding = !isLoanUnmasked ? (Boolean)unmaskedMap.get('MarkedOutstanding') : false;
        Boolean isUnmaskedLimit = !isLoanUnmasked ? (Boolean)unmaskedMap.get('MarkedVLimit') : false;

        Map<String,Object> loanProduct = !isError && (String)getResult('GetLoanAccountDetailResponse.Result.LoanInformation.Status', result) == 'SUCCESS' ? (Map<String,Object>)getResult('GetLoanAccountDetailResponse.Result.LoanInformation', result): new Map<String,Object>();

        String openDate = (loanProduct.get('OpenDate') != null && loanProduct.get('OpenDate') != '') ?  String.valueOf(loanProduct.get('OpenDate')): 'Invalid';
        if(openDate != 'Invalid'){
            openDate = openDate.split('\\+')[0];
        }
        String contractEndDate = (loanProduct.get('ContractEndDate') != null && loanProduct.get('ContractEndDate') != '') ? String.valueOf(loanProduct.get('ContractEndDate')) : 'Invalid';
        if(contractEndDate != 'Invalid'){
            contractEndDate = contractEndDate.split('\\+')[0];
        }
        String lastPaymentDate = (loanProduct.get('LastPaymentDate') != null && loanProduct.get('LastPaymentDate') != '') ? String.valueOf(loanProduct.get('LastPaymentDate')) : 'Invalid';
        if(lastPaymentDate != 'Invalid'){
            lastPaymentDate = lastPaymentDate.split('\\+')[0];
        }
        String paymentDueDate = (loanProduct.get('PaymentDueDate') != null && loanProduct.get('PaymentDueDate') != '') ? String.valueOf(loanProduct.get('PaymentDueDate')) : 'Invalid';
        if(paymentDueDate != 'Invalid'){
            paymentDueDate = paymentDueDate.split('\\+')[0];
        }

        Decimal outStanding = loanProduct.get('Outstanding') == null ? 0 : Double.valueOf((String)loanProduct.get('Outstanding'));
        Decimal credLimit = loanProduct.get('CreditLimit') == null ? 0 : Double.valueOf((String)loanProduct.get('CreditLimit'));

        String maskedOutstanding = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_MarkedOutstanding') || isEmployee ? System.Label.Data_Condition_Hidden_Text : isUnmaskedOutstanding ? outStanding.format() : (String)NumberHelper.MarkDecimal(outStanding);
        String maskedLimit = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_MarkedVLimit') || isEmployee ? System.Label.Data_Condition_Hidden_Text : isUnmaskedLimit ? credLimit.format() : (String)NumberHelper.MarkDecimal(credLimit);
         
        loanProductDetail.OpenDate =  isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_OpenDate') ? System.Label.Data_Condition_Hidden_Text : openDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(openDate));
        loanProductDetail.ContractEndDate =   isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_ContractEndDate') ? System.Label.Data_Condition_Hidden_Text : contractEndDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(contractEndDate));
        loanProductDetail.PaymentDueDate =  isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_PaymentDueDate') ? System.Label.Data_Condition_Hidden_Text : paymentDueDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(paymentDueDate));
        loanProductDetail.LastPaymentDate = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_LastPaymentDate') ? System.Label.Data_Condition_Hidden_Text : lastPaymentDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(lastPaymentDate));
        
        loanProductDetail.MarkedLoanAccountNumber = !fieldAccessMap.get('Loan_Detail_MarkedLoanAccountNumber') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('MarkedLoanAccountNumber');
        loanProductDetail.ProductName = !fieldAccessMap.get('Loan_Detail_ProductName') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('ProductName');
        loanProductDetail.SubProductGroup = !fieldAccessMap.get('Loan_Detail_SubProductGroup') ? System.Label.Data_Condition_Hidden_Text : (String)productFrom01.get('SubProductGroup');
        loanProductDetail.AccountStatus = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_AccountStatus') ? System.Label.Data_Condition_Hidden_Text : String.valueOf(loanProduct.get('AccountStatus'));
        loanProductDetail.CampaignName = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CampaignName') ? System.Label.Data_Condition_Hidden_Text : String.valueOf(loanProduct.get('CampaignName'));
        loanProductDetail.HasCoBorrower =  isError ? System.Label.ERR008 :!fieldAccessMap.get('Loan_Detail_HasCoBorrower') ? System.Label.Data_Condition_Hidden_Text :  String.valueOf(loanProduct.get('HasCoBorrower'));
        loanProductDetail.MarkedOutstanding = maskedOutstanding;
        loanProductDetail.MarkedVLimit =  maskedLimit;
        loanProductDetail.CurrentTenor = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CurrentTenor') ? System.Label.Data_Condition_Hidden_Text : String.valueOf(loanProduct.get('CurrentTenor'));
        loanProductDetail.Tenor =  isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_Tenor') ? System.Label.Data_Condition_Hidden_Text :String.valueOf(loanProduct.get('Tenor'));
        loanProductDetail.Status = String.valueOf(loanProduct.get('Status'));
       
        return loanProductDetail;
    } 

    public static List<LoanCoBorrowerWrapper> tranformLoanCoBorrowerdetail(Map<String,Object> result, Map<String, Boolean> fieldAccessMap, Boolean isError){
        List<LoanCoBorrowerWrapper> loanCoBorrowerList = new List<LoanCoBorrowerWrapper>();
        
        Map<String,Object> responseResult =  !isError && (String)getResult('GetLoanAccountDetailResponse.Result.CoBorrowerInformation.Status', result) == 'SUCCESS' ? (Map<String,Object>)getResult('GetLoanAccountDetailResponse.Result.CoBorrowerInformation', result): new Map<String,Object>();
    
        List<object> loanCoBorrowerProductList =  (List<Object>)responseResult.get('CoBorrower') != null ? (List<Object>)responseResult.get('CoBorrower') : new List<Object>();
        
        for(Object each :loanCoBorrowerProductList ){
            Map<String,Object> mapEachCoBorrower = (Map<String,Object>)each;
            String relation = (String)mapEachCoBorrower.get('Relationship');
            if(relation == 'PRIJNT' || relation == 'SECJNT' || relation == 'OTHJNT' ){
                LoanCoBorrowerWrapper loanCoBorrowerWrapper = new LoanCoBorrowerWrapper();
                loanCoBorrowerWrapper.Name = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CoBorrower_Name') ? System.Label.Data_Condition_Hidden_Text :(String)mapEachCoBorrower.get('Name');
                loanCoBorrowerWrapper.Relationship = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CoBorrower_Name') ? System.Label.Data_Condition_Hidden_Text : relation;
                // loanCoBorrowerWrapper.Status = (String)responseResult.get('Status');
                loanCoBorrowerList.add(loanCoBorrowerWrapper);
            }
        }
      
        return loanCoBorrowerList;
    }

    public static List<LoanInterestPlanWrapper> tranformLoanInterestPlanDetail(Map<String,Object> result, Map<String, Boolean> fieldAccessMap, Boolean isError){
        List<LoanInterestPlanWrapper> loanInterestPlanWrapperList = new List<LoanInterestPlanWrapper>();
        List<Object> loanInterestPlanList = !isError && getResult('GetLoanAccountDetailResponse.Result.InterestPlan', result) != null  ? (List<Object>)getResult('GetLoanAccountDetailResponse.Result.InterestPlan', result) : new List<Object>();
        for(Object each : loanInterestPlanList){
            Map<String,Object> mapEachInterest = (Map<String,Object>)each;
            LoanInterestPlanWrapper eachLoanInterest = new LoanInterestPlanWrapper();
            eachLoanInterest.AccountNumber = isError ? System.Label.ERR008 :  !fieldAccessMap.get('Loan_Detail_Interest_AccountNumber') ? System.Label.Data_Condition_Hidden_Text : (String)mapEachInterest.get('AccountNumber');
            eachLoanInterest.Period = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_Interestest_Period') ? System.Label.Data_Condition_Hidden_Text : (String)mapEachInterest.get('Period');
            eachLoanInterest.InterestRate = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_Interestest_InterestRate') ? System.Label.Data_Condition_Hidden_Text : (String)mapEachInterest.get('InterestRate');
            loanInterestPlanWrapperList.add(eachLoanInterest);
        }
        return loanInterestPlanWrapperList;
    }

    @AuraEnabled
    public static Object getCYBDetail(String accountNumber, String recordId, String tmbCustId){
        Map<String, Boolean> fieldAccessMap =RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId,'Detail of Loan Product');
        Map<String,Object> mapResult = new Map<String,Object>();
        accountNumber = Test.isRunningTest() ? accountNumber : SFExtIntregration.decryptText(accountNumber);
        Object result = RTL_ProductHoldingWebSvcUtils.calloutCYBDetail(accountNumber,recordId,tmbCustId);
        Map<String,Object> mapResultCYB = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(result));

        VehicleInformationWrapper vehicleInformation = tranformCYBDetail(mapResultCYB, fieldAccessMap);
        mapResult.put('VehicleInformation',vehicleInformation);
        mapResult.put('StatusCode', getResult('StatusCode', mapResultCYB) != null ? (String)getResult('StatusCode', mapResultCYB):'');
        return mapResult;
    }
    

    @AuraEnabled
    public static Object getGuarantorDetail(String accountNumber, String recordId, String tmbCustId){
        Map<String,Object> mapResult = new Map<String,Object>();
        Map<String, Boolean> fieldAccessMap =RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId,'Detail of Loan Product');
        accountNumber = Test.isRunningTest() ? accountNumber : SFExtIntregration.decryptText(accountNumber);
        Object result = RTL_ProductHoldingWebSvcUtils.callbackGuarantor(accountNumber,recordId,tmbCustId);
        Map<String,Object> mapResultFromGuarantor = (Map<String,Object>)result;
        Boolean isThrow = mapResultFromGuarantor.get('isThrow')  != null ? (Boolean)mapResultFromGuarantor.get('isThrow') : false;
        Boolean isError = mapResultFromGuarantor.get('isError') != null  ? (Boolean)mapResultFromGuarantor.get('isError') : false;
        Boolean isTimeout = mapResultFromGuarantor.get('isTimeout')  != null ? (Boolean)mapResultFromGuarantor.get('isTimeout') : false;
        Boolean isNoData = mapResultFromGuarantor.get('isNoData') != null ? (Boolean)mapResultFromGuarantor.get('isNoData') : false;

        List<GuarantorWrapper> resultWrapper = tranformGuarantor(mapResultFromGuarantor, isError, isTimeout, isNoData,fieldAccessMap);
        mapResult.put('isError',isError || isThrow);
        mapResult.put('isTimeout',isTimeout);
        mapResult.put('isNoData',isNoData);
        mapResult.put('Message',mapResultFromGuarantor.get('Message') != null ? (String)mapResultFromGuarantor.get('Message') : '');
        mapResult.put('Guarantors',resultWrapper);
        mapResult.put('StatusCode', getResult('StatusCode', mapResultFromGuarantor) != null ? (String)getResult('StatusCode', mapResultFromGuarantor):'');

        return mapResult;
    }

    private static List<GuarantorWrapper> tranformGuarantor(Map<String,Object> mapResultFromGuarantor, Boolean isError, Boolean isTimeout, Boolean isNoData, Map<String, Boolean> fieldAccessMap){
        Boolean isSuccess = !isError && !isTimeout && !isNoData;
        List<Object> guarantorList =  getResult('account.guarantors', mapResultFromGuarantor) != null ? (List<Object>)getResult('account.guarantors', mapResultFromGuarantor): new List<Object>();
        List<GuarantorWrapper> guarantorWrapperList = new List<GuarantorWrapper>();
        if(guarantorList.size() > 0){
            for (Integer i = 0; i < guarantorList.size() ; i++) {
            
                GuarantorWrapper guarantorWrapper = new GuarantorWrapper();
                Map<String,Object> eachGuarantor = isSuccess ? (Map<String,Object>)guarantorList[i] : new Map<String,Object>();
                String idBirthDate = (eachGuarantor.get('id_birth_date') != null && eachGuarantor.get('id_birth_date') != '') ? String.valueOf(eachGuarantor.get('id_birth_date')) : 'Invalid';
                if(idBirthDate != 'Invalid'){
                    idBirthDate = idBirthDate.split('\\+')[0];
                }
                guarantorWrapper.id_birth_date =  isError || isTimeout ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_IdBirthDate') ? System.Label.Data_Condition_Hidden_Text : isNoData ? System.Label.No_data : idBirthDate == 'Invalid' ? '' : NumberHelper.DateFormat(Date.ValueOf(idBirthDate));
                guarantorWrapper.tha_fullname =  isError || isTimeout ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_GuarantorName') ? System.Label.Data_Condition_Hidden_Text : isNoData ? System.Label.No_data : (String)eachGuarantor.get('tha_fullname');
                guarantorWrapper.id_no =  isError || isTimeout ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_IdNo') ? System.Label.Data_Condition_Hidden_Text : isNoData ? System.Label.No_data : (String)eachGuarantor.get('id_no');
                guarantorWrapperList.add(guarantorWrapper);
            }
        }
        return guarantorWrapperList;
    }

    private static VehicleInformationWrapper tranformCYBDetail(Map<String,Object> result02,Map<String, Boolean> fieldAccessMap){
        VehicleInformationWrapper vehicleInformation = new VehicleInformationWrapper();
        Boolean isError = result02.get('isError') != null? (Boolean)result02.get('isError') : true;
        // Map<String, Boolean> fieldAccessMap =RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId,'Loan_Detail_%');

        Map<String,Object> cybProductMap = !isError && getResult('cyb_product_detail', result02) != null  ? (Map<String,Object>)getResult('cyb_product_detail', result02) : new Map<String,Object>();
        
        String car_regis_date = (cybProductMap.get('car_regis_date') != null && cybProductMap.get('car_regis_date') != '') ? String.valueOf(cybProductMap.get('car_regis_date')) : 'Invalid';
        if(car_regis_date != 'Invalid'){
            car_regis_date = car_regis_date.split('\\+')[0];
        }
        String tax_due_date = (cybProductMap.get('tax_due_date') != null && cybProductMap.get('tax_due_date') != '') ? String.valueOf(cybProductMap.get('tax_due_date')) : 'Invalid';
        if(tax_due_date != 'Invalid'){
            tax_due_date = tax_due_date.split('\\+')[0];
        }
        String req_date = (cybProductMap.get('req_date') != null && cybProductMap.get('req_date') != '') ? String.valueOf(cybProductMap.get('req_date')) : 'Invalid';
        if(req_date != 'Invalid'){
            req_date = req_date.split('\\+')[0];
        }

        Decimal committeePrice = cybProductMap.get('committee_price') == null || String.valueOf(cybProductMap.get('committee_price')) == ''? 0 : (Decimal)cybProductMap.get('committee_price');
        Decimal lateChargesAmount = cybProductMap.get('late_charges_amount') == null || String.valueOf(cybProductMap.get('late_charges_amount')) == '' ? 0: (Decimal)cybProductMap.get('late_charges_amount');
        Decimal totalPastDueAmount = cybProductMap.get('total_past_due_amount') == null || String.valueOf(cybProductMap.get('total_past_due_amount')) == '' ? 0 : (Decimal)cybProductMap.get('total_past_due_amount');
        Decimal feeDueAmount = cybProductMap.get('fee_due_amount') == null || String.valueOf(cybProductMap.get('total_past_due_amount')) == '' ? 0 : (Decimal)cybProductMap.get('fee_due_amount');
        
        String markedCommitteePrice = committeePrice == 0 ? '-' : (String)NumberHelper.MarkDecimal(committeePrice);
        String markedLateChargesAmount = lateChargesAmount == 0 ? '-' : (String)NumberHelper.MarkDecimal(lateChargesAmount);
        String markedTotalPastDueAmount = totalPastDueAmount == 0 ? '-' : (String)NumberHelper.MarkDecimal(totalPastDueAmount);
        String markedFeeDueAmount = feeDueAmount == 0 ? '-' : (String)NumberHelper.MarkDecimal(feeDueAmount);

        vehicleInformation.tax_due_date = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_TaxDueDate') ? System.Label.Data_Condition_Hidden_Text : tax_due_date != 'Invalid' ? NumberHelper.DateFormat(Date.ValueOf(tax_due_date)) : '';
        vehicleInformation.req_date = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_ReqDate') ? System.Label.Data_Condition_Hidden_Text : req_date != 'Invalid' ? NumberHelper.DateFormat(Date.ValueOf(req_date)): '';
        vehicleInformation.car_regis_date = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CarRegisDate') ? System.Label.Data_Condition_Hidden_Text : car_regis_date != 'Invalid' ? NumberHelper.DateFormat(Date.ValueOf(car_regis_date)): '';
        vehicleInformation.isError = isError;
        vehicleInformation.isSuccess = cybProductMap.get('isSuccess') != null ? (Boolean)cybProductMap.get('isSuccess') : null;
        vehicleInformation.isTimeout = cybProductMap.get('isTimeout') != null ? (Boolean)cybProductMap.get('isTimeout') : false;
        vehicleInformation.car_details = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CarDetails') ? System.Label.Data_Condition_Hidden_Text : (String)cybProductMap.get('car_details');
        vehicleInformation.license_no = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_LicenseNo') ? System.Label.Data_Condition_Hidden_Text : (String)cybProductMap.get('license_no');
        vehicleInformation.chasis_no = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_ChasisNo') ? System.Label.Data_Condition_Hidden_Text :(String)cybProductMap.get('chasis_no');
        vehicleInformation.engine_no = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_EngineNo') ? System.Label.Data_Condition_Hidden_Text : (String)cybProductMap.get('engine_no');
        vehicleInformation.committee_price = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CommitteePrice') ? System.Label.Data_Condition_Hidden_Text : markedCommitteePrice;
        vehicleInformation.custdn_status_desc = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_CustdnStatusDesc') ? System.Label.Data_Condition_Hidden_Text : String.ValueOf(cybProductMap.get('custdn_status_desc'));
        vehicleInformation.past_due_payment_count = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_PastDuePaymentCount') ? System.Label.Data_Condition_Hidden_Text : String.valueOf(cybProductMap.get('past_due_payment_count'));
        vehicleInformation.late_charges_amount = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_LateChargesAmount') ? System.Label.Data_Condition_Hidden_Text : markedLateChargesAmount;
        vehicleInformation.total_past_due_amount = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_TotalPastDueAmount') ? System.Label.Data_Condition_Hidden_Text : markedTotalPastDueAmount;
        vehicleInformation.fee_due_amount = isError ? System.Label.ERR008 : !fieldAccessMap.get('Loan_Detail_FeeDueAmount') ? System.Label.Data_Condition_Hidden_Text : markedFeeDueAmount;

        return vehicleInformation;
    }
}