public class RTL_ProductHoldingSummaryController extends AbstractCoreClass{

    public class BancAssuranceWrapperClass {
        @AuraEnabled public String POLICY_NO { get; set; }
        @AuraEnabled public String PRODUCT_GROUP { get; set; }
        @AuraEnabled public String POLICY_NAME { get; set; }
        @AuraEnabled public String COMPANY_NAME { get; set; }
        @AuraEnabled public String EFFECTIVE_DATE { get; set; }
        @AuraEnabled public String STATUS { get; set; }
        @AuraEnabled public String SUM_INSURE { get; set; }
        @AuraEnabled public String PREMIUM { get; set; }
        @AuraEnabled public String EXPIRY_DATE { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String ProductName { get; set; }
        @AuraEnabled public String SeqGrp { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String Tag { get; set; }
        @AuraEnabled public String TabName { get; set; }
        @AuraEnabled public String Hidden { get; set; }
    }

    public class LoanProductWrapper{
        @AuraEnabled public string MarkedLoanAccountNumber { get; set; }
        @AuraEnabled public string AccountType { get; set; }
        @AuraEnabled public string AccountNumber { get; set; }
        @AuraEnabled public string FIIdent { get; set; }
        @AuraEnabled public string Status {get; set; }
        @AuraEnabled public string MarkedOutstanding {get; set; }
        @AuraEnabled public string MarkedVLimit {get; set; }
        @AuraEnabled public string convertedMaturityDate {get; set; }
        @AuraEnabled public string HasCoBorrower {get; set; }
        @AuraEnabled public string Link {get; set; }
        @AuraEnabled public string ProductName {get; set; }
        @AuraEnabled public string SubProductGroup {get; set; }
        @AuraEnabled public string SeqGrp {get; set; }
        @AuraEnabled public boolean isError {get; set; }
        @AuraEnabled public String VLimit {get; set; }
        @AuraEnabled public String Outstanding {get; set; }
    }

    public class DepositProductWrapper{
        @AuraEnabled public string MarkedDepositAccountNumber { get; set; }
        @AuraEnabled public string SeqGrp { get; set; }
        @AuraEnabled public string FIIdent { get; set; }
        @AuraEnabled public string DepositAccountNumber {get; set; }
        @AuraEnabled public string DepositProductCode {get; set; }
        @AuraEnabled public string ProductType {get; set; }
        @AuraEnabled public string ProductName {get; set; }
        @AuraEnabled public string SubProductGroup {get; set; }
        @AuraEnabled public string Link {get; set; }
        @AuraEnabled public string Status {get; set; }
        @AuraEnabled public string MarkedLedgerBalance {get; set; }
        @AuraEnabled public string MarkedAvgOutStanding {get; set; }
        @AuraEnabled public string MarkedOutStanding {get; set; }
        @AuraEnabled public String ODLimit {get; set; }
        @AuraEnabled public String OutStanding {get; set; }
        @AuraEnabled public String LedgerBalance {get; set; }
        // @AuraEnabled public Decimal AvgOutStanding {get; set; }
        @AuraEnabled public string Other {get; set; }
        @AuraEnabled public string HasJoint {get; set; }
        @AuraEnabled public string ProductCodeMainBank {get; set; }
        @AuraEnabled public boolean isError {get; set; }
        @AuraEnabled public boolean checkAllFree {get; set; }
    }

    public class AutoLoanDataWrapper{
        @AuraEnabled public String SeqGrp{ get; set; }
        @AuraEnabled public String Outstanding{ get; set; }
        @AuraEnabled public String ODLimit{ get; set; }
        @AuraEnabled public String HP_Account_No{ get; set; }
        @AuraEnabled public String MarkedHP_Account_No{ get; set; }
        @AuraEnabled public String Status_AutoLoan{ get; set; }
        @AuraEnabled public String HP_Amount{ get; set; }
        @AuraEnabled public String Outstanding_Amount{ get; set; }
        @AuraEnabled public String Installment_Amount{ get; set; }
        @AuraEnabled public String Remain_Period{ get; set; }
        @AuraEnabled public String Contract_Period{ get; set; }
        @AuraEnabled public String Paid_Period{ get; set; }
        @AuraEnabled public String MarkedOverdue_Amount{ get; set; }
        @AuraEnabled public String HUB{ get; set; }
        @AuraEnabled public String Hidden{ get; set; }
        @AuraEnabled public String Link{ get; set; }
    }

    public class CreditCardWrapper {
        @AuraEnabled public String CardNumber{get; set;}
        @AuraEnabled public String SubProductGroup{get; set;}
        @AuraEnabled public String ProductName{get; set;}
        @AuraEnabled public String CardRole{get; set;}
        @AuraEnabled public String CardActive{get; set;}
        // @AuraEnabled public String CreditLine{get; set;}
        @AuraEnabled public String Outstanding{get; set;}        
        @AuraEnabled public String MarkedVLimit{get; set;}
        @AuraEnabled public String account_id{get; set;}
        @AuraEnabled public String SeqGrp{get; set;}
        @AuraEnabled public String CreditCardType{get; set;}
        @AuraEnabled public String MarkedCardNumber{get; set;}
        @AuraEnabled public String ProductType{get; set;}
        @AuraEnabled public String MarkedOutstanding{get; set;}
        @AuraEnabled public String VLimit{get; set;}
        @AuraEnabled public String MaskedCreditLine{get; set;}    
        @AuraEnabled public String CardPLoan{get; set;}    
        @AuraEnabled public String isError{get; set;}    
        @AuraEnabled public String Link{get; set;}    
        @AuraEnabled public String EncodeProduct{get; set;}    
    }

    public class InvestmentSummaryWrapper{
        @AuraEnabled public String isError {get; set;}
        @AuraEnabled public String SeqGrp {get; set;}
        @AuraEnabled public String UnitHolderNo {get; set;}
        @AuraEnabled public String FundCode {get; set;}
        @AuraEnabled public String ProductName {get; set;}
        @AuraEnabled public String AssetClass {get; set;}
        @AuraEnabled public String IssuerFundHouse {get; set;}
        @AuraEnabled public String NumberOfUnit {get; set;}
        @AuraEnabled public String NavUnit {get; set;}
        @AuraEnabled public String CostOfInvestment {get; set;}
        @AuraEnabled public String AverageCostPerUnit {get; set;}
        @AuraEnabled public String MarketValue {get; set;}
        @AuraEnabled public String UnrealizedGL {get; set;}
        @AuraEnabled public String UnrealizedGLPerc {get; set;}
        @AuraEnabled public String link {get; set;}
        @AuraEnabled public String ERROR {get; set;}
        @AuraEnabled public String UnitHolderNoClass {get; set;}
        @AuraEnabled public String convertedOpenedDate {get; set;}
        @AuraEnabled public String Params {get; set;}
        @AuraEnabled public String SubProductGroup {get; set;}
        @AuraEnabled public String UnitLtf5y {get; set;}
    }

    public class InvestmentFrom01SummaryWrapper{
        @AuraEnabled public String NoOfUnit {get; set;}
        @AuraEnabled public String AvgCost {get; set;}
        @AuraEnabled public String UnrealizedGL {get; set;}
        @AuraEnabled public String Units {get; set;}
        @AuraEnabled public String UnitHoldNo {get; set;}
        @AuraEnabled public String Status {get; set;}
        @AuraEnabled public String MarketValue {get; set;}
        @AuraEnabled public Boolean AccessHigh {get; set;}
    }


    private static final Map<String /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode {
        get {
            if(OnlyProductWithProductCode == null){
                OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
                // for(String each : OnlyProductWithProductCode.keySet()){
                    // System.debug('each : '+each);
                    // System.debug('value : '+OnlyProductWithProductCode.get(each));
                // }
            }
            return OnlyProductWithProductCode;
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

    private static boolean isEmployeePayroll(Decimal OutStanding, Decimal AvgOutStanding, Boolean isEmployee){
        if(OutStanding == 0 && AvgOutStanding == 0 && isEmployee == true) return true;
        return false;
    }

    @AuraEnabled
    public static list<Show_Red_Product_Code__mdt> getRedProductcode(){
        List<Show_Red_Product_Code__mdt> mcs = [SELECT Show_Red__c, Product_Code__c, Id FROM Show_Red_Product_Code__mdt];
        return mcs;
    }

    @AuraEnabled
    public static Object getProduct(String recordId,String rmId, String FiiDent, String tmbCustId){

        String responseBody = RTL_ProductHoldingWebSvcUtils.callOSC01(rmId,FiiDent,tmbCustId);
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        // return (Object) result;
        Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
        Object afterparse01 = parse01Data(result, responseBody, tmbCustId);
        Map<String, Object> object01 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(afterparse01));
        object01.put('LoanAccount', getLoanProductSummary(object01,recordId,tmbCustId));
        object01.put('DepositAccount', getDepositProductSummary(object01,recordId,tmbCustId));
        object01.put('InvestmentAccount', getInvestmentSummary(object01, fieldAccessMap));
        object01.remove('result');
        return object01;
    }

    public static Object getInvestmentSummary(Map<String, Object> jsonMap, Map<String, Boolean> fieldAccessMap){
        try{
            List<Object> investList = (List<Object>)jsonMap.get('InvestmentAccount');
            List<InvestmentFrom01SummaryWrapper> wrapperList = new List<InvestmentFrom01SummaryWrapper>();
            for(Object i : investList){
                Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                InvestmentFrom01SummaryWrapper wrapper = new InvestmentFrom01SummaryWrapper();
                wrapper.NoOfUnit = String.valueOf(each.get('NoOfUnit'));
                wrapper.AvgCost = String.valueOf(each.get('AvgCost'));
                wrapper.UnrealizedGL = String.valueOf(each.get('UnrealizedGL'));
                wrapper.Units = String.valueOf(each.get('Units'));
                wrapper.MarketValue = String.valueOf(each.get('MarketValue'));
                wrapper.Status = String.valueOf(each.get('Status'));
                wrapper.UnitHoldNo = fieldAccessMap.get('Investment_UnitHolderNo') == false ? SFExtIntregration.encyptText(String.valueOf(each.get('UnitHoldNo'))) : String.valueOf(each.get('UnitHoldNo'));
                wrapper.AccessHigh = fieldAccessMap.get('Investment_UnitHolderNo') == false ? false : true;
                wrapperList.add(wrapper);
            }
            return (Object) wrapperList;
        }catch(Exception e){
            return (Object) new List<InvestmentFrom01SummaryWrapper>();
        }
    }

    //BancAssurance Method
    @AuraEnabled
    public static Object getBancAssuranceData(String rmId, String recordId, String tmbCustId){
        String responseBody = RTL_ProductHoldingWebSvcUtils.callOSC05(rmId, tmbCustId);
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        // return (Object) result;
        Map<String, Object> checkStatus = (Map<String,Object>)result.get('Status');
        Map<String,Object> getBanAccountResponse = (Map<String,Object>)result.get('GetBancassuranceAccountResponse');
        Map<String,Object> innerStatus = getBanAccountResponse == null ? null : (Map<String,Object>)getBanAccountResponse.get('Status');
        Map<String, Object> returnMap = new Map<String, Object>();
 
        if(String.valueOf(checkStatus.get('StatusCode')) != '200'){
            checkStatus.put( 'StatusDesc', getErrorMessageForBanc(String.valueOf(checkStatus.get('StatusCode')), String.valueOf(checkStatus.get('StatusDesc'))));
            returnMap.put('Status', checkStatus);
            returnMap.put('GetBancassuranceAccountResponse', new List<BancAssuranceWrapperClass>());
            return (Object) returnMap;
        }
        else if(String.valueOf(checkStatus.get('StatusCode')) == '200' && String.valueOf(innerStatus.get('StatusCode')) != '200'){
            returnMap.put('StatusCode', String.valueOf(innerStatus.get('StatusCode')));
            returnMap.put('StatusDesc', getErrorMessageForBanc(String.valueOf(innerStatus.get('StatusDesc')), String.valueOf(innerStatus.get('StatusCode'))));
            return (Object) returnMap;
        }
        else if(String.valueOf(checkStatus.get('StatusCode')) == '200' && String.valueOf(innerStatus.get('StatusCode')) == '200'){
            try{
                Map<String, Boolean> fieldVisibleMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
                Map<String, Object> insurancePolicyList = (Map<String,Object>)getBanAccountResponse.get('InsurancePolicyListCRMInqResponse');
                Map<String, Object> insurancePolicyInq = (Map<String,Object>)insurancePolicyList.get('InsurancePolicyListCRMInqResult');
                List<Object> dataSets = (List<Object>)insurancePolicyInq.get('DataSets');
                List<BancAssuranceWrapperClass> bancList = new List<BancAssuranceWrapperClass>();
                Set<String> newSet = new Set<String>();
                for(Integer i=0 ;i<dataSets.size() ;i++){
                    BancAssuranceWrapperClass bancAss = new BancAssuranceWrapperClass();
                    String dataStr = JSON.serialize(dataSets.get(i));
                    Map<String, Object> forWrapper = (Map<String, Object>)JSON.deserializeUntyped(dataStr);
                    Date expireDate;
                    Date effectDate;
                    String ex = genMMDDYYYY(String.ValueOf(forWrapper.get('EXPIRY_DATE')));
                    String ef = genMMDDYYYY(String.ValueOf(forWrapper.get('EFFECTIVE_DATE')));
                    if(ex != 'Invalid'){
                        expireDate = date.parse(ex);
                    }
                    if( ef != 'Invalid' ){
                        effectDate = date.parse(ef);
                    }
 
                    String link = '{"componentDef":"c:BancassuranceDetailView","attributes":{"recordId":"' + recordId + '","tmbCustId":"' + tmbCustId + '","RMID":"' + rmId + '","PolicyNumber":"' + String.valueOf(forWrapper.get('POLICY_NO')) + '"}}';
                    bancAss.POLICY_NO = fieldVisibleMap.get('Bancassurance_POLICY_NO') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('POLICY_NO'));
                    bancAss.PRODUCT_GROUP = fieldVisibleMap.get('Bancassurance_PRODUCT_GROUP') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('PRODUCT_GROUP'));
                    bancAss.POLICY_NAME = fieldVisibleMap.get('Bancassurance_POLICY_NAME') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('POLICY_NAME'));
                    bancAss.COMPANY_NAME = fieldVisibleMap.get('Bancassurance_COMPANY_NAME') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('COMPANY_NAME'));
                    bancAss.STATUS =fieldVisibleMap.get('Bancassurance_STATUS') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('STATUS'));
                    bancAss.SUM_INSURE =fieldVisibleMap.get('Bancassurance_SUM_INSURE') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('SUM_INSURE'));
                    bancAss.PREMIUM =fieldVisibleMap.get('Bancassurance_PREMIUM') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('PREMIUM'));
                    bancAss.ProductName =fieldVisibleMap.get('Bancassurance_POLICY_NAME') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('POLICY_NAME'));
                    bancAss.link = '/one/one.app#' + EncodingUtil.base64Encode(Blob.valueof(link));
                    bancAss.Hidden = Label.Data_Condition_Hidden_Text;
                    bancAss.Type = Label.Bancassurance_Product_Details;
                    bancAss.Tag = 'Bancassurance_Product_Details';
                    bancAss.TabName = fieldVisibleMap.get('Bancassurance_POLICY_NO') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(forWrapper.get('POLICY_NO'));
                    bancAss.SeqGrp = '6';
                    bancAss.EFFECTIVE_DATE = fieldVisibleMap.get('Bancassurance_EFFECTIVE_DATE') == false ? Label.Data_Condition_Hidden_Text : ef == 'Invalid' ? String.ValueOf(forWrapper.get('EFFECTIVE_DATE')) : NumberHelper.DateFormat(effectDate);
                    bancAss.EXPIRY_DATE =fieldVisibleMap.get('Bancassurance_EXPIRY_DATE') == false ? Label.Data_Condition_Hidden_Text : ex == 'Invalid' ? String.ValueOf(forWrapper.get('EXPIRY_DATE')) : NumberHelper.DateFormat(expireDate);
                    bancList.add(bancAss);
                }
                returnMap.put('Status', checkStatus);
                returnMap.put('GetBancassuranceAccountResponse', (Object) bancList);
                return (Object) returnMap;
            }
            catch(Exception e){
                returnMap.put('Status', (Object) checkStatus);
                returnMap.put('GetBancassuranceAccountResponse', new List<BancAssuranceWrapperClass>());
                return (Object) returnMap;
            }
        }
        else {
            return (Object) result;
        }  
    }

    public static String genMMDDYYYY(String dateStr){
        try{
            List<String> dList = dateStr.split('/');
            return dList[0] + '/' + dList[1] + '/' + dList[2];
        }catch(Exception e){
            return 'Invalid';
        }
    }

    public static String getErrorMessageForBanc(String innerStatusCode, String innerStatusDesc){
        try{
            Screen_Message_Management__mdt displayMessage = [SELECT Id, StatusCode__c, StatusDesc__c, Screen_Message__c FROM Screen_Message_Management__mdt WHERE StatusDesc__c LIKE : innerStatusDesc AND StatusCode__c =: innerStatusCode LIMIT 1];
            return displayMessage.Screen_Message__c;
        }catch(Exception e){
            return Label.INT_Investment_Incomplete_Info;
        }
    }

    //Deposit Product
    private static Object getDepositProductSummary(Map<String, Object> responseFromWs,String recordId, String tmbCustId){
        List<DepositProductWrapper> returnDepositList = new List<DepositProductWrapper>();
        System.debug('responseFromWs : '+responseFromWs);
        Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
        Boolean isEmployee = isEmployee(tmbCustId);

        if(!responseFromWs.isEmpty() && responseFromWs.get('DepositAccount') != null){
            List<Object> depositProductList = (List<Object>)responseFromWs.get('DepositAccount');
            for(Object eachLoan : depositProductList){
                DepositProductWrapper result = transformDepositeProductDTO((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(eachLoan)),null,new DepositProductWrapper(),tmbCustId,new Map<String,Object>(),recordId,fieldAccessMap,isEmployee,new List<String>());
                returnDepositList.add(result);
            }
        }  
        return (Object)returnDepositList;
    }
    @AuraEnabled
    public static Map<String,Object> getDepositProductDetail(DepositProductWrapper depositProduct,String RMID,String tmbCustId,Map<String,Object> mapUnmasked, String recordId, Map<String, Boolean> fieldAccessMap, Boolean isEmployee,List<String> listProdMDT){
        Map<String,Object> mapDepositProductDetail = new Map<String,Object>(); 
        Map<String,Object> resultMap = new Map<String,Object>();
        String accountNumber = Test.isRunningTest() ? depositProduct.DepositAccountNumber : (SFExtIntregration.decryptText(depositProduct.DepositAccountNumber)); 
        String accountType = Test.isRunningTest() ? depositProduct.DepositProductCode : (SFExtIntregration.decryptText(depositProduct.DepositProductCode));
        Object result = RTL_ProductHoldingWebSvcUtils.callbackOSC02(accountNumber, accountType, depositProduct.ProductType,RMID, depositProduct.FIIdent,tmbCustId);
        Map<String,Object> mapResultFrom02 = (Map<String, Object>)result;
        if((String)getResult('Status.StatusCode', mapResultFrom02) != '200'){
            return mapResultFrom02;
        }
        Boolean isError = (String)getResult('GetDepositAccountResponse.AcctInqRs.Status.Severity', mapResultFrom02) != 'Error' ? false:true;
        if((String)getResult('GetDepositAccountResponse.AcctInqRs.Status.Severity', mapResultFrom02) != 'Error'){
            Map<String, Object> AcctBalMap = new Map<String, Object>();
            for (Object obj : (List<Object>)getResult('GetDepositAccountResponse.AcctInqRs.AcctBal', mapResultFrom02)) {
                AcctBalMap.put((String)getResult('BalType', obj), obj);
            }
            resultMap.put('Outstanding',AcctBalMap.containsKey('Avail') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Avail'))) : 0);
            resultMap.put('AvgOutStanding',getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', mapResultFrom02) != null ? (Decimal)getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', mapResultFrom02) : 0);
            resultMap.put('ODLimit',getResult('GetDepositAccountResponse.AcctInqRs.DepAcctRec.DepAcctInfo.ODLimitAmt', mapResultFrom02) != null ? Decimal.valueOf((String)getResult('GetDepositAccountResponse.AcctInqRs.DepAcctRec.DepAcctInfo.ODLimitAmt', mapResultFrom02)) : 0);
            resultMap.put('LedgerBalance',AcctBalMap.containsKey('Ledger') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Ledger'))) : 0);
        }
        if((String)getResult('GetDepositAccountDetailResponse.Result.Status', mapResultFrom02) == 'SUCCESS') {
            resultMap.put('ProductCodeMainBank',!isError ? getResult('GetDepositAccountDetailResponse.Result.DepositAccount.ProductCode',mapResultFrom02):'');
        }
        resultMap.put('isError', isError);

        depositProduct = transformDepositeProductDTO(null, resultMap, depositProduct, tmbCustId,mapUnmasked,recordId,fieldAccessMap,isEmployee,listProdMDT);
        String link = genLinkForDepositProduct(resultMap,depositProduct,recordId,tmbCustId);
        depositProduct.Link = link;
        mapDepositProductDetail.put('DepositAccount',depositProduct);
        mapDepositProductDetail.put('StatusCode',String.valueOf(mapResultFrom02.get('StatusCode')));
        return mapDepositProductDetail;
    }
    private static DepositProductWrapper transformDepositeProductDTO(Map<String, Object> obj,Map<String, Object> objFromOSC02,DepositProductWrapper depositProduct,String tmbCustId, Map<String, Object> mapUnmasked,String recordId, Map<String, Boolean> fieldAccessMap, Boolean isEmployee,List<String> listProdMDT){
        // Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'Deposit%');
        String markedLedgerBalance = '-';
        String markedAvgOutstanding =  '-';
        String markedOutstanding =  '-';
        if(objFromOSC02 == null){
            String depositProductCode = (String)obj.get('ProductCode');
            String projectCode = (String)obj.get('ProjectCode');
            String dataSource = (String)obj.get('DataSource');
            String productcode = depositProductCode != null ? depositProductCode : '' + projectCode != null ? projectCode : '' + dataSource != null ? dataSource : '';
            depositProduct.MarkedDepositAccountNumber = !fieldAccessMap.get('Deposit_MarkedDepositAccountNumber') ? System.Label.Data_Condition_Hidden_Text : NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo((String)obj.get('AccountNumber')));
            depositProduct.SeqGrp = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
            depositProduct.FIIdent =(String)obj.get('FIIdent');
            depositProduct.DepositProductCode = SFExtIntregration.encyptText((String)obj.get('ProductCode'));
            depositProduct.DepositAccountNumber = SFExtIntregration.encyptText((String)obj.get('AccountNumber'));
            depositProduct.ProductType = (String)obj.get('ProductType');
            depositProduct.ProductName = !fieldAccessMap.get('Deposit_ProductName') ? System.Label.Data_Condition_Hidden_Text :  productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            depositProduct.SubProductGroup = !fieldAccessMap.get('Deposit_ProductName') ? System.Label.Data_Condition_Hidden_Text : productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A';
            depositProduct.Status = !fieldAccessMap.get('Deposit_Status') ? System.Label.Data_Condition_Hidden_Text : (String)obj.get('AccountStatus');
            depositProduct.HasJoint = !fieldAccessMap.get('Deposit_HasJoint') ? System.Label.Data_Condition_Hidden_Text : (String)obj.get('HasJoint');
            depositProduct.MarkedLedgerBalance = !fieldAccessMap.get('Deposit_MarkedLedgerBalance') ? System.Label.Data_Condition_Hidden_Text : markedLedgerBalance;
            depositProduct.MarkedAvgOutStanding = !fieldAccessMap.get('Deposit_MarkedAvgOutStanding') ? System.Label.Data_Condition_Hidden_Text : markedAvgOutstanding;
            depositProduct.MarkedOutStanding = !fieldAccessMap.get('Deposit_MarkedOutStanding') ? System.Label.Data_Condition_Hidden_Text : markedOutstanding;
            depositProduct.Other = !fieldAccessMap.get('Deposit_Other') ? System.Label.Data_Condition_Hidden_Text : (String)obj.get('Other') != null ? (String)obj.get('Other') : '';
        }else if(objFromOSC02 != null){
            Boolean isError = (Boolean)objFromOSC02.get('isError');
            Boolean isLedgerBalance = false;
            Boolean isAvgOutstanding = false;
            Boolean isOutstanding = false;
            String status = depositProduct.Status;
            status = status.toLowerCase();
            Boolean isAccountDormant = (status.trim()).length() > 0 ? status.contains('dormant') : false;
            Boolean isDepositUnmasked = mapUnmasked == null;
            String  productCodeMainBank = (String)objFromOSC02.get('ProductCodeMainBank');
            if(!isDepositUnmasked){
                // Map<String,Object> mapDepositSection = (Map<String,Object>)mapUnmasked.get('Deposit_Section');
                isLedgerBalance = (Boolean)mapUnmasked.get('MarkedLedgerBalance');
                isAvgOutstanding = (Boolean)mapUnmasked.get('MarkedAvgOutStanding');
                isOutstanding = (Boolean)mapUnmasked.get('MarkedOutStanding');
            }
            // Decimal ledgereBalance = (Decimal)objFromOSC02.get('LedgerBalance') == null ? 0 : Decimal.valueOf(String.valueOf(objFromOSC02.get('LedgerBalance')));
            Decimal ledgereBalance = objFromOSC02.get('LedgerBalance') == null ? 0 : Decimal.valueOf(String.valueOf(objFromOSC02.get('LedgerBalance')));
            // Decimal outStanding = objFromOSC02.get('Outstanding') == null ? 0 : (Decimal)objFromOSC02.get('Outstanding');
            Decimal outStanding = objFromOSC02.get('Outstanding') == null ? 0 : Decimal.valueOf(String.valueOf(objFromOSC02.get('Outstanding')));
            // Decimal odLimit = objFromOSC02.get('ODLimit') == null ? 0 : (Decimal)objFromOSC02.get('ODLimit');
            Decimal odLimit = objFromOSC02.get('ODLimit') == null ? 0 : Decimal.valueOf(String.valueOf(objFromOSC02.get('ODLimit')));
            Decimal avgOutStanding = (Decimal)objFromOSC02.get('AvgOutStanding') == null ? 0 : (Decimal)objFromOSC02.get('AvgOutStanding');
            Boolean isEmployeePayroll = isEmployeePayroll(outStanding, avgOutStanding, isEmployee);
            depositProduct.isError = isError;
            depositProduct.checkAllFree = listProdMDT.contains(productCodeMainBank) && ledgereBalance < 5000 ? true : false;
            depositProduct.ProductCodeMainBank = productCodeMainBank;
            depositProduct.OutStanding = SFExtIntregration.encyptText(String.valueOf(ledgereBalance));
            depositProduct.ODLimit = SFExtIntregration.encyptText(String.valueOf(odLimit));
            depositProduct.LedgerBalance = SFExtIntregration.encyptText(String.valueOf(ledgereBalance));
            // depositProduct.AvgOutStanding = avgOutStanding;
			
            markedLedgerBalance = ledgereBalance == 0 ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : (String)NumberHelper.MarkDecimal(ledgereBalance);
            markedAvgOutstanding = avgOutStanding == 0 ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : (String)NumberHelper.MarkDecimal(avgOutStanding);
            markedOutstanding = outStanding == 0 ? '-' : isEmployeePayroll ? System.Label.Data_Condition_Hidden_Text : (String)NumberHelper.MarkDecimal(outStanding);

            depositProduct.MarkedLedgerBalance = isError ? System.Label.ERR008 : !fieldAccessMap.get('Deposit_MarkedLedgerBalance') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked == false ? markedLedgerBalance : isAccountDormant ? markedLedgerBalance : isLedgerBalance ? ledgereBalance.longValue().format() : markedLedgerBalance;
            depositProduct.MarkedAvgOutStanding = isError ? System.Label.ERR008 : !fieldAccessMap.get('Deposit_MarkedAvgOutStanding') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked == false ? markedAvgOutstanding : isAccountDormant ? markedAvgOutstanding : isAvgOutstanding ? avgOutStanding.longValue().format() : markedAvgOutstanding;
            depositProduct.MarkedOutStanding = isError ? System.Label.ERR008 : !fieldAccessMap.get('Deposit_MarkedOutStanding') ? System.Label.Data_Condition_Hidden_Text : isDepositUnmasked == false ? markedOutstanding : isAccountDormant ? markedOutstanding : isOutstanding ? outStanding.longValue().format() : markedOutstanding;
        }
        // returnList.add(depositProduct);
        return depositProduct;
    }
    public static String genLinkForDepositProduct(Map<String,Object> result,DepositProductWrapper depositProduct,String recordId, String tmbCustId){
        String link = '';
        String product = '';
        if(result.get('MarkedOutstanding') != System.Label.Loading){
            // String accountNumber = (SFExtIntregration.decryptText(depositProduct.DepositAccountNumber)); 
            // String accountType = (SFExtIntregration.decryptText(depositProduct.DepositProductCode));
            product = EncodingUtil.urlEncode((
                '{"SeqGrp":"' + depositProduct.SeqGrp
                    + '","Fiident":"' +  depositProduct.FIIdent
                    + '","ProductType":"' +  depositProduct.ProductType
                    + '","DepositAccountNumber":"' + (String)result.get('AccountNumber')
                    + '","MarkedDepositAccountNumber":"' + depositProduct.MarkedDepositAccountNumber
                    + '","SubProductGroup":"' + depositProduct.SubProductGroup
                    + '","ProductName":"' + depositProduct.ProductName
                    + '","HasJoint":"' + depositProduct.HasJoint
                    + '","MarkedOutStanding":"' + depositProduct.MarkedAvgOutStanding
                    + '","MarkedLedgerBalance":"' + depositProduct.MarkedLedgerBalance
                    + '","MarkedAvgBalanceMTD":"' + depositProduct.MarkedAvgOutStanding
                    + '"}'),'UTF-8');

            product = product.replaceAll('\\+','%20');
            System.debug('product : '+product);


            product = EncodingUtil.base64Encode(Blob.valueof(product));
                    
            link = '/one/one.app#' + EncodingUtil.base64Encode(Blob.valueof(
                '{"componentDef":"c:DepositProductDetailsView",'
                    +'"attributes": {"recordId":"' + recordId 
                                + '","tmbCustId":"' + tmbCustId
                                + '","FIIdent":"' + depositProduct.FIIdent
                                + '","AccountNumber":"' + depositProduct.DepositAccountNumber
                                + '","AccountType":"' + depositProduct.DepositProductCode
                                + '","ProductType":"' + depositProduct.ProductType
                                + '","product":"' + product
                                + '"}}'));
        }
        return link;
    }

    //Loan Product
    public static Object getLoanProductSummary(Map<String, Object> responseFromWs,String recordId, String tmbCustId){
        List<LoanProductWrapper> returnList = new List<LoanProductWrapper>();
        if(!responseFromWs.isEmpty() && responseFromWs.get('LoanAccount') != null){
            Boolean isEmployee = isEmployee(tmbCustId);

            Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
            List<Object> loanProductList = (List<Object>)responseFromWs.get('LoanAccount');
            for(Object eachLoan : loanProductList){
                LoanProductWrapper result = transformLoanProduct((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(eachLoan)),null,new LoanProductWrapper(),tmbCustId,new Map<String,Object>(),recordId,fieldAccessMap,isEmployee);
                // String link = genLinkForLoanProduct((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(eachLoan)),result,recordId,tmbCustId);
                // result.Link = link;
                returnList.add(result);
            }
        }
        return (Object)returnList;
    }
    @AuraEnabled
    public static Map<String,Object> getLoanProductDetail(LoanProductWrapper loanProduct, String recordId, String rmId, String tmbCustId, Map<String,Object> mapUnmasked, Map<String, Boolean> fieldAccessMap, Boolean isEmployee){
        Boolean isError = true;
        Map<String,Object> mapResult= new Map<String,Object>();
        Map<String,Object> resultMap04 = new Map<String,Object>();

        String accountNumber = Test.isRunningTest() ? loanProduct.AccountNumber : (SFExtIntregration.decryptText(loanProduct.AccountNumber));
        String accountType = Test.isRunningTest() ? loanProduct.AccountType : (SFExtIntregration.decryptText(loanProduct.AccountType));
        Object result = RTL_ProductHoldingWebSvcUtils.callbackOSC04(accountNumber, accountType, rmId, loanProduct.FIIdent,tmbCustId);

        Map<String,Object> mapResultFrom04 = (Map<String, Object>)result;
        if((String)getResult('Status.StatusCode', mapResultFrom04) != '200'){
            return mapResultFrom04;
        }

        if((String)getResult('GetLoanAccountResponse.AcctInqRs.Status.Severity', mapResultFrom04) != 'Error'){
            isError = false;
            Map<String, Object> AcctBalMap = new Map<String, Object>();
            for (Object obj : (List<Object>)getResult('GetLoanAccountResponse.AcctInqRs.AcctBal', mapResultFrom04)) {
                AcctBalMap.put((String)getResult('BalType', obj), obj);
            }
            
            String MatDt = (String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.MatDt', mapResultFrom04);
            resultMap04.put('Outstanding',AcctBalMap.containsKey('Principal') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Principal'))) : 0);
            resultMap04.put('VLimit',Decimal.valueOf((String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.LOCLimit.Amt', mapResultFrom04)));
            resultMap04.put('MuturityDate', MatDt != null && String.isNotEmpty(MatDt) ? Date.valueOf((String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.MatDt', mapResultFrom04)) : null);
        }
       resultMap04.put('isError', isError);
            
        loanProduct =  transformLoanProduct(null,resultMap04, loanProduct,tmbCustId,mapUnmasked,recordId,fieldAccessMap,isEmployee);
        String link = genLinkForLoanProduct(mapResultFrom04,loanProduct,recordId,tmbCustId);
        loanProduct.Link = link;
        mapResult.put('LoanAccount',loanProduct);
        mapResult.put('StatusCode', (String)getResult('Status.StatusCode', mapResultFrom04));
        return mapResult;
    }
    private static LoanProductWrapper transformLoanProduct(Map<String, Object> obj,Map<String, Object> objFromOSC04,LoanProductWrapper loanProduct,String tmbCustId, Map<String, Object> unmaskedMap ,String recordId, Map<String, Boolean> fieldAccessMap, Boolean isEmployee) {
        // Boolean isEmployee = isEmployee(tmbCustId);
        // Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'Loan%');
        String maskedLimit = isEmployee || !fieldAccessMap.get('Loan_MarkedVLimit') ? System.Label.Data_Condition_Hidden_Text : '-';
        String maskedOutstanding = isEmployee || !fieldAccessMap.get('Loan_MarkedOutstanding') ? System.Label.Data_Condition_Hidden_Text : '-';
        System.debug('loanProduct : '+loanProduct);

        if(objFromOSC04 == null ){
            String LoanProductCode = (String)obj.get('ProductCode');
            String ProjectCode = (String)obj.get('ProjectCode');
            String DataSource = (String)obj.get('DataSource');
    
            // LoanProductWrapper loanProduct = new LoanProductWrapper();
            loanProduct.MarkedLoanAccountNumber = !fieldAccessMap.get('Loan_MarkedLoanAccountNumber') ? System.Label.Data_Condition_Hidden_Text : NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo((String)obj.get('AccountNumber')));
            loanProduct.AccountType = obj.get('AccountType') != null ? SFExtIntregration.encyptText((String)obj.get('AccountType')) : SFExtIntregration.encyptText((String)obj.get('ProductType'));
            loanProduct.AccountNumber = obj.get('AccountNumber') != null ? SFExtIntregration.encyptText((String)obj.get('AccountNumber')) : SFExtIntregration.encyptText((String)obj.get('LoanAccountNumber'));
            loanProduct.FIIdent = (String)obj.get('FIIdent');
            loanProduct.Status = !fieldAccessMap.get('Loan_Status') ? System.Label.Data_Condition_Hidden_Text : (String)obj.get('AccountStatus');
            loanProduct.MarkedOutstanding = maskedOutstanding;
            loanProduct.MarkedVLimit = maskedLimit;
            loanProduct.convertedMaturityDate = !fieldAccessMap.get('Loan_convertedMaturityDate') ? System.Label.Data_Condition_Hidden_Text : obj.get('MaturityDate') != null ? String.ValueOf(NumberHelper.DateFormat(Date.ValueOf(obj.get('MaturityDate')))) : null;
            loanProduct.HasCoBorrower = !fieldAccessMap.get('Loan_HasCoBorrower') ? System.Label.Data_Condition_Hidden_Text : (String)obj.get('HasCoborrower');
            
            String productcode = LoanProductCode != null ? LoanProductCode : '' + ProjectCode != null ? ProjectCode : '' + DataSource != null ? DataSource : '';
            loanProduct.ProductName = !fieldAccessMap.get('Loan_ProductName') ? System.Label.Data_Condition_Hidden_Text : productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            loanProduct.SubProductGroup = !fieldAccessMap.get('Loan_SubProductGroup') ? System.Label.Data_Condition_Hidden_Text :  productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A';
            loanProduct.SeqGrp = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
        }else if(objFromOSC04 != null){
            System.debug('Condition 2');
            Boolean isLoanUnmasked = unmaskedMap == null;
            Boolean isOutstanding = false;
            Boolean isUnmaskedLimit = false;
            if(!isLoanUnmasked){
                // Map<String, Object> unmaskedLoanMap = (Map<String, Object>)unmaskedMap.get('Loan_Section');
                isOutstanding = (Boolean)unmaskedMap.get('MarkedOutstanding');
                isUnmaskedLimit = (Boolean)unmaskedMap.get('MarkedVLimit');
            }
            loanProduct.isError = (Boolean)objFromOSC04.get('isError');
            Decimal outStanding = objFromOSC04.get('Outstanding') == null ? 0 : (Decimal)objFromOSC04.get('Outstanding');
            Decimal vLimit = objFromOSC04.get('VLimit') == null ? 0 : (Decimal)objFromOSC04.get('VLimit');
            
            maskedOutstanding = (Decimal)objFromOSC04.get('Outstanding') == 0 ? '-' : ((Decimal)objFromOSC04.get('Outstanding')).longValue().format();
            maskedLimit = (Decimal)objFromOSC04.get('VLimit') == 0 ? '-' : ((Decimal)objFromOSC04.get('VLimit')).longValue().format();
            maskedOutstanding = isEmployee || !fieldAccessMap.get('Loan_MarkedOutstanding') ? System.Label.Data_Condition_Hidden_Text : isOutstanding ? maskedOutstanding : (String)NumberHelper.MarkDecimal((Decimal)objFromOSC04.get('Outstanding'));
            maskedLimit = isEmployee || !fieldAccessMap.get('Loan_MarkedVLimit') ? System.Label.Data_Condition_Hidden_Text : isUnmaskedLimit ? String.valueOf(maskedLimit) : (String)NumberHelper.MarkDecimal((Decimal)objFromOSC04.get('VLimit'));
            loanProduct.MarkedOutstanding = loanProduct.isError ? System.Label.ERR008 : maskedOutstanding;
            loanProduct.MarkedVLimit =loanProduct.isError ? System.Label.ERR008 : maskedLimit;
            loanProduct.convertedMaturityDate = !fieldAccessMap.get('Loan_convertedMaturityDate') ? System.Label.Data_Condition_Hidden_Text : objFromOSC04.get('MuturityDate') != null ? String.ValueOf(NumberHelper.DateFormat((Date)objFromOSC04.get('MuturityDate'))) : null;
            loanProduct.VLimit = SFExtIntregration.encyptText(String.valueOf(vLimit));
            loanProduct.Outstanding = SFExtIntregration.encyptText(String.valueOf(outStanding));
        }
        return loanProduct;
    }
    public static String genLinkForLoanProduct(Map<String,Object> result,LoanProductWrapper loanProduct,String recordId, String tmbCustId){
        String link = '';
        String product = '';
        if(loanProduct.MarkedOutstanding != System.Label.Loading){
            System.debug('loanProduct : '+loanProduct);
            // String accountNumber = (SFExtIntregration.decryptText(loanProduct.AccountNumber)); 
            // String accountType = (SFExtIntregration.decryptText(loanProduct.AccountType));
            product = EncodingUtil.urlEncode((
                '{"MarkedLoanAccountNumber":"' + loanProduct.MarkedLoanAccountNumber
                    + '","SubProductGroup":"' +loanProduct.SubProductGroup
                    + '","ProductName":"' + loanProduct.ProductName
                    + '","MarkedOutstanding":"' + loanProduct.MarkedOutstanding
                    + '","MarkedVLimit":"' + loanProduct.MarkedVLimit
                    + '","HasCoBorrower":"' + loanProduct.HasCoBorrower
                    + '"}'),'UTF-8');

            product = product.replaceAll('\\+','%20');
            System.debug('product : '+product);


            product = EncodingUtil.base64Encode(Blob.valueof(product));
                    
            link = '/one/one.app#' + EncodingUtil.base64Encode(Blob.valueof(
                '{"componentDef":"c:LoanProductDetailsView",'
                    +'"attributes": {"recordId":"' + recordId 
                                + '","tmbCustId":"' + tmbCustId
                                + '","RMID":"' + tmbCustId.substring(12)
                                + '","Fiident":"' + loanProduct.Fiident
                                + '","AccountNumber":"' + loanProduct.AccountNumber
                                + '","AccountType":"' + loanProduct.AccountType
                                + '","ProductType":"' 
                                + '","SeqGrp":"' + loanProduct.SeqGrp
                                + '","product":"' + product
                                + '"}}'));
        }
        return link;
    }

    public static Object parse01Data(Map<String, Object> result, String response01Body, String tmbCustId){
        String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
        String StatusDesc = String.isNotEmpty(response01Body) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(response01Body))) : '';
        String keyMessage = (StatusDesc.contains('Record not found') || StatusDesc.contains('account not found')) ? 'RecordNotFound' : 'General';
        String errorMessage = new Map<String, String>{
            'General' => System.Label.ERR001,
            'RecordNotFound' => System.Label.INT_No_Active_Product
        }.get(keyMessage);
        if (StatusCode != '200' || ((Map<String, Object>)getResult('GetCustomerAccountResponse', result)).isEmpty()) {
            Map<String, Object> returnData = new Map<String, Object>();
            returnData.put('StatusCode', StatusCode);
            returnData.put('StatusDesc', StatusDesc);
            returnData.put('Message', errorMessage);
            return returnData;
            // Object Status = getResult('Status', result);
            // Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
            // Status = putObject('Message', errorMessage, Status);
            // return Status;
        }
        Map<String, Object> resultProduct = (Map<String, Object>)getResult('GetCustomerAccountResponse', result);

        List<Object> DepositAccount = resultProduct.containsKey('DepositAccounts') ? (List<Object>)getResult('DepositAccounts.DepositAccount', resultProduct) : new List<Object>();
        List<Object> LoanAccount = resultProduct.containsKey('LoanAccounts') ? (List<Object>)getResult('LoanAccounts.LoanAccount', resultProduct) : new List<Object>();
        List<Object> InvestmentAccount = resultProduct.containsKey('InvestmentAccounts') ? (List<Object>)getResult('InvestmentAccounts.InvestmentAccount', resultProduct) : new List<Object>();

        Boolean isEmployee = isEmployee(tmbCustId);
        return new Map<String, Object> {
            'DepositAccount' => DepositAccount,
            'LoanAccount' => LoanAccount,
            'InvestmentAccount' => InvestmentAccount,
            'result' => result,
            'isEmployee' => isEmployee
        };
    }

    @AuraEnabled(cacheable=true)
    public static Object getAppConfigMdtByKey(String key) {
        Map<String, String> appConfigs = new Map<String, String>();
        for (App_Config__mdt appc : [SELECT DeveloperName, Value__c FROM App_Config__mdt WHERE DeveloperName = :key]) {
            appConfigs.put(appc.DeveloperName, appc.Value__c);
        }
        return appConfigs.containsKey(key) ? appConfigs.get(key) : '';
    }


    @AuraEnabled
    public static Map<String, Object> getUnmaskBalance(String sectionUnmask){
        Map<String, Object> unmaskedData = (Map<String, Object>)JSON.deserializeUntyped(ProductingUnmaskingSetup.getProductUnmaskSetting());
        Map<String, Object> unmaskedSection = unmaskedData.containsKey(sectionUnmask) != null ? (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(unmaskedData.get(sectionUnmask))):new Map<String, Object>();
        return unmaskedSection;
    }

    @AuraEnabled(cacheable=true)
    public static Object getALDXWFMdt() {
        Map<String, ALDX_WF_Status__mdt> alds_wf_map = new Map<String, ALDX_WF_Status__mdt>();
        for(ALDX_WF_Status__mdt alds_wf : [SELECT STATUS_CODE__c, STATUS_NAME__c, WARNING_MESSAGE__c, IS_ACTIVE__c FROM ALDX_WF_Status__mdt WHERE WARNING_MESSAGE__c <> null]) {
            alds_wf_map.put(String.valueOf(Integer.valueOf(alds_wf.STATUS_CODE__c)), alds_wf);
        }
        return alds_wf_map;
    }

    @AuraEnabled(cacheable=true)
    public static Object getALDXWFMdtAll() {
        Map<String, ALDX_WF_Status__mdt> alds_wf_map = new Map<String, ALDX_WF_Status__mdt>();
        for(ALDX_WF_Status__mdt alds_wf : [SELECT STATUS_CODE__c, STATUS_NAME__c, WARNING_MESSAGE__c, IS_ACTIVE__c FROM ALDX_WF_Status__mdt]) {
            alds_wf_map.put(String.valueOf(Integer.valueOf(alds_wf.STATUS_CODE__c)), alds_wf);
        }
        return alds_wf_map;
    }

    @AuraEnabled
    public static Object getAutoloanHpFleetHpList(String Company, String RMID, String HPType, String TranDate, String TranTime, String recordId, Object state, String accessCustHold){
        Object result = RTL_ProductHoldingWebSvcUtils.calloutAutoLoan_HpFleetHpList(Company, RMID, HPType, TranDate, TranTime, recordId, state);
        // return result;
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result));
        Map<String, Object> returnMap = new Map<String, Object>();
        if(String.valueOf(jsonMap.get('HTTPStatusCode')) == '200'){
            Object outputList = parseAutoLoanWrapper(JSON.serialize(result), RMID, recordId, Company, accessCustHold);
            returnMap.put('Output', outputList);
            returnMap.put('HTTPStatusCode', jsonMap.get('HTTPStatusCode'));
        }
        else {
            returnMap.put('HTTPStatusCode', jsonMap.get('HTTPStatusCode'));
            returnMap.put('Output', (Object) new List<AutoLoanDataWrapper>());
        }
        return returnMap;
    }

    private static Object parseAutoLoanWrapper(String autoLoanResponse, String RMID, String recordId, String Company, String accessCustHold){
        try{
            Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
            List<AutoLoanDataWrapper> autoLoanList = new List<AutoLoanDataWrapper>();
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(autoLoanResponse);
            List<Object> outputList = (List<Object>)jsonMap.get('Output');
            if( outputList.size() > 0 ){
                Boolean isEmployee = isEmployee(RMID);
                Map<String, Object> autoLoanIsUnmask = getUnmaskBalance('AutoLoan_Section');
                Boolean IsInstallmentAmount = false;
                Boolean IsOutstandingAmount = false;
                Boolean IsHPTotalAmount = false;
                Boolean IsOverdueAmount = false;
                Boolean isAllLogic = autoLoanIsUnmask == null ? true : false;
                if(isAllLogic == false){
                    IsInstallmentAmount = (Boolean)autoLoanIsUnmask.get('Installment_Amount');
                    IsOutstandingAmount = (Boolean)autoLoanIsUnmask.get('Outstanding_Amount');
                    IsHPTotalAmount = (Boolean)autoLoanIsUnmask.get('HP_Amount');
                    IsOverdueAmount = (Boolean)autoLoanIsUnmask.get('MarkedOverdue_Amount');
                }
                Object aldxwfmdt = getALDXWFMdt();
                Map<String, Object> aldxwfmdtResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(aldxwfmdt));
                Integer index = 0;
                for(Object i : outputList){
                    index += 1;
                    AutoLoanDataWrapper autoWrapper = new AutoLoanDataWrapper();
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    Map<String, Object> aldxOfCode = (Map<String, Object>)aldxwfmdtResult.get(String.valueOf(each.get('ContractStatusCode')));
                    String link = '{"componentDef":"c:AutoLoan_HPFeetHPDetailView","attributes":{"recordId":"' + recordId + '","tmbCustId":"' + RMID + '","accessibleCusHold":"' + accessCustHold + '","company":"' + Company + '","contractNo":"' + String.valueOf(each.get('ContractNo')) + '","markedcontractNo":"' + getMarkedHPAccount(String.valueOf(each.get('ContractNo'))) + '","accountType":"Retail"}}';
                    autoWrapper.Status_AutoLoan = fieldAccessMap.get('AutoLoan_Status_AutoLoan') == false ? Label.Data_Condition_Hidden_Text : (each.get('ContractStatusCode') != null ? String.valueOf(each.get('ContractStatusCode')) : '' ) + ' - ' +  (each.get('ContractStatusName') != null ? String.valueOf(each.get('ContractStatusName')) : '' );
                    autoWrapper.HP_Amount = (isEmployee == true || fieldAccessMap.get('AutoLoan_HP_Amount') == false) ? Label.Data_Condition_Hidden_Text : isAllLogic == true ? maskWithXX(String.valueOf(each.get('HPTotalAmount'))) : IsHPTotalAmount == false ? maskWithXX(String.valueOf(each.get('HPTotalAmount'))) : getCents(Decimal.valueOf(String.valueOf(each.get('HPTotalAmount'))));
                    autoWrapper.Outstanding_Amount = (isEmployee == true || fieldAccessMap.get('AutoLoan_Outstanding_Amount') == false) ? Label.Data_Condition_Hidden_Text : aldxOfCode != null ? String.valueOf(aldxOfCode.get('WARNING_MESSAGE__c')) : isAllLogic == true ? maskWithXX(String.valueOf(each.get('OutstandingAmount'))) : IsOutstandingAmount == false ? maskWithXX(String.valueOf(each.get('OutstandingAmount'))) : getCents(Decimal.valueOf(String.valueOf(each.get('OutstandingAmount'))));
                    autoWrapper.Installment_Amount = (isEmployee == true || fieldAccessMap.get('AutoLoan_Installment_Amount') == false) ? Label.Data_Condition_Hidden_Text : isAllLogic == true ? maskWithXX(String.valueOf(each.get('Installment'))) : !IsInstallmentAmount ? maskWithXX(String.valueOf(each.get('Installment'))) : getCents(Decimal.valueOf(String.valueOf(each.get('Installment'))));
                    autoWrapper.Remain_Period = fieldAccessMap.get('AutoLoan_Remain_Period') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('NumberOfInstallmentBalance'));
                    autoWrapper.Contract_Period = fieldAccessMap.get('AutoLoan_Contract_Period') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('TotalInstallments'));
                    autoWrapper.Paid_Period = fieldAccessMap.get('AutoLoan_Paid_Period') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CurrentOfInstallments'));
                    autoWrapper.MarkedOverdue_Amount = fieldAccessMap.get('AutoLoan_MarkedOverdue_Amount') == false ? Label.Data_Condition_Hidden_Text : aldxOfCode != null ? String.valueOf(aldxOfCode.get('WARNING_MESSAGE__c')) : isAllLogic == true ? maskWithXX(String.valueOf(each.get('OverdueAmount'))) : IsOverdueAmount == false ? maskWithXX(String.valueOf(each.get('OverdueAmount'))) : getCents(Decimal.valueOf(String.valueOf(each.get('OverdueAmount'))));
                    autoWrapper.HUB = fieldAccessMap.get('AutoLoan_HUB') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('Channel'));
                    
                    autoWrapper.SeqGrp = 'AutoLoan';
                    autoWrapper.Hidden = Label.Data_Condition_Hidden_Text;
                    autoWrapper.MarkedHP_Account_No = fieldAccessMap.get('AutoLoan_MarkedHP_Account_No') == false ? Label.Data_Condition_Hidden_Text : getMarkedHPAccount(String.valueOf(each.get('ContractNo')));
                    autoWrapper.Outstanding = aldxOfCode != null ? '0' : SFExtIntregration.encyptText(String.valueOf(each.get('OutstandingAmount')));
                    autoWrapper.ODLimit = SFExtIntregration.encyptText(String.valueOf(each.get('HPTotalAmount')));
                    autoWrapper.HP_Account_No = SFExtIntregration.encyptText(String.valueOf(each.get('ContractNo'))) ;
                    autoWrapper.Link = '/one/one.app#' + EncodingUtil.base64Encode(Blob.valueof(link));

                    autoLoanList.add(autoWrapper);
                }
            }   
            return (Object) autoLoanList;
        }catch (Exception e){
            return new List<AutoLoanDataWrapper>();
        }
    }

    private static string getMarkedHPAccount(String value){
        Integer len = 12 - value.length() + 1;
        String mask = 'xxxxxxxyyyyy'.substring(0, len);
        String remain = value.substring(len);
        return mask+remain;
    }

    public static string maskWithXX(String value){
        if(Decimal.valueOf(value) >= 100){
            value = getCents(Decimal.valueOf(value));
            List<String> parts = value.split('\\.');
            value = parts.get(0);
            String mask = value.substring(0, value.length()-2 >= 0 ? value.length()-2 : 0);
            mask += (mask == '' || mask == null) ? '-' : 'xx';
            return mask;
        }
        else if(Decimal.valueOf(value) == 0){
            return '-';
        }
        else{
            return 'xx';
        }
    }

    public static String getCents(Decimal x){
        String i = String.valueOf(x);
        if(i.contains('.')){
            String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
            String p = s.substring(0,s.length()-1);
            return p;
        }
        else{
            List<String> args = new String[]{'0','number','###,###,##0.00'};
            String s = String.format(x.format(), args);
            return s;
        }
    }

    @AuraEnabled
    public static Object getInvestmentAccountList(String unitHolderNo, String recordId, String tmbCustId, String rmId, Boolean isEncrypt){

        String decryptUnitHolderNo = isEncrypt == true ? SFExtIntregration.decryptText(unitHolderNo) : unitHolderNo ;
        Object result = RTL_ProductHoldingWebSvcUtils.calloutOSC06List(decryptUnitHolderNo, tmbCustId);
        return parseInvestmentWrapper(JSON.serialize(result), decryptUnitHolderNo, recordId, tmbCustId, rmId);

    }

    private static Object parseInvestmentWrapper(String responseFromInvest, String unitHolderNo, String recordId, String tmbCustId, String rmId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String ,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseFromInvest);
        Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
        try{
            List<Object> investmentList = (List<Object>)jsonMap.get('InvestmentAccount');
            if(investmentList.size() > 0){
                List<InvestmentSummaryWrapper> investWrapList = new List<InvestmentSummaryWrapper>();
                for(Object i : investmentList){
                    InvestmentSummaryWrapper investclass = new InvestmentSummaryWrapper();
                    Map<String ,Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    String link = '{"componentDef":"c:InvestmentProductDetailNewView","attributes":{"recordId":"' + recordId + '","tmbCustId":"' + tmbCustId + '","UnitHolderNo":"' + each.get('UnitHolderNo') + '","FundCode":"' + each.get('FundCode') + '"}}';
                    Boolean isError = each.get('UnitHolderNo') == null ? true : false;
                    String productName = fieldAccessMap.get('Investment_ProductName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ProductName'));
                    investclass.isError = String.valueOf(isError);
                    investclass.SeqGrp = (isError == false && productName != '#N/A') ? String.valueOf(each.get('SeqGrp')) : 'OTHERS';
                    investclass.FundCode = isError == false ? String.valueOf(each.get('FundCode')) : '';
                    investclass.IssuerFundHouse = fieldAccessMap.get('Investment_IssuerFundHouse') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('IssuerFundHouse')) : '';
                    investclass.NumberOfUnit = fieldAccessMap.get('Investment_NumberOfUnit') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('NumberOfUnit')) : '';
                    investclass.NavUnit = fieldAccessMap.get('Investment_NavUnit') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('NavUnit')) : '';
                    investclass.CostOfInvestment = fieldAccessMap.get('Investment_CostOfInvestment') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('CostOfInvestment')) : '';
                    investclass.AverageCostPerUnit = fieldAccessMap.get('Investment_AverageCostPerUnit') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('AverageCostPerUnit')) : '';
                    investclass.UnrealizedGL = fieldAccessMap.get('Investment_UnrealizedGL') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('UnrealizedGL')) : '';
                    investclass.UnrealizedGLPerc = fieldAccessMap.get('Investment_UnrealizedGLPerc') == false ? Label.Data_Condition_Hidden_Text : isError == false ? String.valueOf(each.get('UnrealizedGLPerc')) : '';
                    investclass.link = isError == false ? '/one/one.app#' + EncodingUtil.base64Encode(Blob.valueof(link)) : '';
                    investclass.ERROR = isError == false ? '' : 'notFound';
                    investclass.UnitHolderNoClass = isError == false ? '' : 'notFound';
                    investclass.Params = String.valueOf(each.get('Params'));
                    investclass.convertedOpenedDate = String.valueOf(each.get('convertedOpenedDate'));
                    investclass.UnitLtf5y = String.valueOf(each.get('UnitLtf5y'));
                    
                    investclass.MarketValue = fieldAccessMap.get('Investment_MarketValue') == false ? SFExtIntregration.encyptText(String.valueOf(each.get('MarketValue')))  : isError == false ? String.valueOf(each.get('MarketValue')) : '';
                    // investclass.MarketValue = isError == false ? String.valueOf(each.get('MarketValue')) : '';
                    investclass.ProductName = isError == false ? String.valueOf(each.get('ProductName')) : Label.ERR008;
                    investclass.UnitHolderNo = isError == false ? String.valueOf(each.get('UnitHolderNo')) : unitHolderNo;
                    investclass.AssetClass = isError == false ? String.valueOf(each.get('AssetClass')) : '';
                    investWrapList.add(investclass);
                }
                returnMap.put('InvestmentAccount', investWrapList);
                returnMap.put('Status', jsonMap.get('Status'));
                
                return (Object) returnMap;
            }
            else {
                String make = '{"State":{"Account":{"attributes":{"type":"Account","url":"/services/data/v56.0/sobjects/Account/' + recordId + '"},"Id":"' + recordId + '","Name":"","Core_Banking_Suggested_Segment__c":""},"RMID":"","StartTime":"","body":"{\\"GetInvestmentAccountRequest\\":{\\"UnitHolderNo\\":\\"' + unitHolderNo + '\\"}}","isEmployee":false},"StatusCode":"200","StatusDesc":"success","InvestmentAccountStatusCode":"200","Message":"Sorry, some error occurred while getting information. Please contact 02-299-1740 or report issue via “SNOW”","Result":{"GetInvestmentAccountResponse":{"percOfFundType":{"Balanced":"","ForeignEquity":"","ForeignFixedIncome":"","LocalEquity":"","LocalFixedIncome":"","Others":""},"listFundClass":"","FeeAsOfDate":"","SumAccruedFee":"","GetFundDetails":[],"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}}';
                Map<String, Object> makeItHappen = (Map<String, Object>)JSON.deserializeUntyped(make);
                makeItHappen.put('InvestmentAccount', new List<InvestmentSummaryWrapper>());
                makeItHappen.put('Status', jsonMap.get('Status'));
                return (Object) makeItHappen;
            }
        }
        catch(Exception e){
            String make = '{"State":{"Account":{"attributes":{"type":"Account","url":"/services/data/v56.0/sobjects/Account/' + recordId + '"},"Id":"' + recordId + '","Name":"","Core_Banking_Suggested_Segment__c":""},"RMID":"","StartTime":"","body":"{\\"GetInvestmentAccountRequest\\":{\\"UnitHolderNo\\":\\"' + unitHolderNo + '\\"}}","isEmployee":false},"StatusCode":"200","StatusDesc":"success","InvestmentAccountStatusCode":"200","Message":"Sorry, some error occurred while getting information. Please contact 02-299-1740 or report issue via “SNOW”","Result":{"GetInvestmentAccountResponse":{"percOfFundType":{"Balanced":"0.0","ForeignEquity":"1.0","ForeignFixedIncome":"0.0","LocalEquity":"0.0","LocalFixedIncome":"0.0","Others":"0"},"listFundClass":"","FeeAsOfDate":"","SumAccruedFee":"0.00","GetFundDetails":[],"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}}';
            Map<String, Object> makeItHappen = (Map<String, Object>)JSON.deserializeUntyped(make);
            makeItHappen.put('InvestmentAccount', new List<InvestmentSummaryWrapper>());
            makeItHappen.put('Status', jsonMap.get('Status'));
            return (Object) makeItHappen;
        }
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;
        return userEmpId;
    }

    @AuraEnabled
    public static Object callgetCreditCardData(String rmId, String more_records, String search_keys, String user_interface, String tmbCusId, String recordId){
        Object result = RTL_ProductHoldingWebSvcUtils.callOSC03(rmId,more_records,search_keys,user_interface,tmbCusId);  
        // return result;       
        return parseCreditCardWrapper(JSON.serialize(result), rmId, recordId);               
    }


    private static Object parseCreditCardWrapper(String creditCardresponse, String rmId, String recordId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> endReturnMap = new Map<String, Object>(); 
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(creditCardresponse);
        List<Object> credit_error = (List<Object>)jsonMap.get('error_status');        
        Map<String, Boolean> fieldAccessMap = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
        List<Object> credit_output = (List<Object>)jsonMap.get('CreditCardAccounts');        
        Map<String, Object> credit_status = (Map<String, Object>)jsonMap.get('Status');
        List<CreditCardWrapper> creditWrapper = new List<CreditCardWrapper>();
        Map<String, Object> creditIsUnmask = getUnmaskBalance('CreditCard_Section');

        if(credit_error != null){
            return (Object)jsonMap;           
        }
        else {
            try{
            
                // Variable to Check IsMasking or not
                Boolean IsCreditLogic = creditIsUnmask == null;
                Boolean IsOutStanding = false;
                Boolean IsLimit = false;
                Boolean IsMaskedCreditLine = false;
                Boolean isEmployee = isEmployee(rmId);
    
                if(!IsCreditLogic){
                    IsOutStanding = (Boolean)creditIsUnmask.get('MarkedOutstanding');
                    IsLimit = (Boolean)creditIsUnmask.get('MarkedVLimit');
                    IsMaskedCreditLine = (Boolean)creditIsUnmask.get('MaskedCreditLine');            
                }         
    
                if(credit_output == null){
                    credit_output.clear();
                    returnMap.put('Body', creditWrapper);
                    returnMap.put('Status', credit_status);                                        
                } else {
                    for (Object i : credit_output) {
                        CreditCardWrapper autoWrapper = new CreditCardWrapper();
                        Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                        String product = '{"SeqGrp":"' + String.valueOf(each.get('SeqGrp')) + '","CardNumber":"' + String.valueOf(each.get('CardNumber')) + '","CreditCardType":"' + String.valueOf(each.get('CreditCardType')) + '","MarkedCardNumber":"' + String.valueOf(each.get('MarkedCardNumber')) + '","SubProductGroup":"' + String.valueOf(each.get('SubProductGroup')) + '","ProductName":"' + String.valueOf(each.get('ProductName')) + '","ProductType":"' + String.valueOf(each.get('ProductType')) + '","MarkedOutstanding":"' + String.valueOf(each.get('MarkedOutstanding')) + '","MarkedVLimit":"' + String.valueOf(each.get('MarkedVLimit')) + '","VLimit":"' + String.valueOf(each.get('VLimit')) + '","Outstanding":"' + String.valueOf(each.get('Outstanding')) + '"}';
                        String encodedProduct = EncodingUtil.base64Encode(Blob.valueof(EncodingUtil.urlEncode(product, 'UTF-8')));
                        autoWrapper.SubProductGroup = fieldAccessMap.get('Creditcard_SubProductGroup') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('SubProductGroup'));
                        autoWrapper.ProductName = fieldAccessMap.get('Creditcard_ProductName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ProductName'));
                        autoWrapper.CardRole = fieldAccessMap.get('Creditcard_CardRole') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CardRole'));
                        autoWrapper.CardActive = fieldAccessMap.get('Creditcard_CardActive') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CardActive'));
                        // autoWrapper.CreditLine = (isEmployee == true || fieldAccessMap.get('Creditcard_MaskedCreditLine') == false) ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CreditLine'));
                        autoWrapper.MarkedVLimit = (isEmployee == true || fieldAccessMap.get('Creditcard_MarkedVLimit') == false ) ? Label.Data_Condition_Hidden_Text : IsLimit == false ? String.valueOf(each.get('MarkedVLimit')) : getCents(Decimal.valueOf(String.valueOf(each.get('VLimit'))));
                        autoWrapper.SeqGrp = String.valueOf(each.get('SeqGrp'));
                        autoWrapper.CreditCardType = String.valueOf(each.get('CreditCardType'));
                        autoWrapper.MarkedCardNumber = fieldAccessMap.get('Creditcard_MarkedCardNumber') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('MarkedCardNumber'));
                        autoWrapper.ProductType = String.valueOf(each.get('ProductType'));
                        autoWrapper.MarkedOutstanding = (isEmployee == true || fieldAccessMap.get('Creditcard_MarkedOutstanding') == false) ? Label.Data_Condition_Hidden_Text : IsOutStanding == false ? String.valueOf(each.get('MarkedOutstanding')) : getCents(Decimal.valueOf(String.valueOf(each.get('Outstanding'))));
                        autoWrapper.MaskedCreditLine = (isEmployee == true || fieldAccessMap.get('Creditcard_MaskedCreditLine') == false) ? Label.Data_Condition_Hidden_Text : IsMaskedCreditLine == false ? String.valueOf(each.get('MaskedCreditLine')) : getCents(Decimal.valueOf(String.valueOf(each.get('CreditLine'))));
                        autoWrapper.isError = String.valueOf(each.get('isError'));
                        autoWrapper.CardPLoan = String.valueOf(each.get('CardPLoan'));  
                        autoWrapper.EncodeProduct = encodedProduct;  


                        autoWrapper.CardNumber = fieldAccessMap.get('Creditcard_MarkedCardNumber') == false ? Label.Data_Condition_Hidden_Text : SFExtIntregration.encyptText(String.valueOf(each.get('CardNumber')));
                        autoWrapper.VLimit = SFExtIntregration.encyptText(String.valueOf(each.get('VLimit')));
                        autoWrapper.Outstanding = SFExtIntregration.encyptText(String.valueOf(each.get('Outstanding')));                        
                        creditWrapper.add(autoWrapper);                                     
                    }
            
                    Map<String, Object> credit_result = (Map<String, Object>)jsonMap.get('result');
                    List<Object> creditcardToaccount = (List<Object>)credit_result.get('credit_card');
                    List<Object> newAccount = new List<Object>();
                    for(Object i : creditcardToaccount){    
                        Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                        newAccount.add(each.get('account_id'));    
                    }
            
                    Integer countIndexaccount = 0;
            
                    for(CreditCardWrapper i : creditWrapper){    
                        i.account_id = String.valueOf(newAccount.get(countIndexaccount));
                        String link = '{"componentDef":"c:CreditCardDetails","attributes":{"recordId":"' + recordId + '","tmbCustId":"' + rmId + '","account_id":"' + String.valueOf(newAccount.get(countIndexaccount)) + '", "CardNumber":"' + i.CardNumber + '","CreditCardType":"' + i.CreditCardType + '","account_id":"' + String.valueOf(newAccount.get(countIndexaccount)) + '","product":"' + i.EncodeProduct + '"}}';
                        String encodeLink = EncodingUtil.base64Encode(Blob.valueof(link));
                        i.Link = '/one/one.app#' + encodeLink; 
                        countIndexaccount++;    
                    }
    
                    Map<String, Object> setCredit_status = new Map<String, Object>();
                    setCredit_status.put('StatusCode', '200');
                    setCredit_status.put('StatusDesc', 'SUCCESS');
    
                    returnMap.put('Body', creditWrapper);
                    returnMap.put('Status', setCredit_status);        
                }        
                return (Object) returnMap;
            }
            catch(Exception e){  
                endReturnMap.put('Body', creditWrapper);
                endReturnMap.put('error_status', credit_error);
                endReturnMap.put('Status', credit_status);                     
                return (Object) endReturnMap;
            }
        }

    }
    @AuraEnabled
    public static Map<String, Boolean> getFieldVisibilityByPage(String recordId, String pageName){
        User currentUser = [SELECT Id, Name, RTL_Branch__c, RTL_Branch_Code__c, ProfileId, UserRoleId FROM User WHERE Id=: UserInfo.getUserId() LIMIT 1];
        Profile p = [SELECT Name FROM Profile WHERE Id =: currentUser.ProfileId];
        String dataHidden = Label.Data_Condition_Hidden_Text;
        String profileName = p.Name;
        Boolean isAuth = false;
        List<Security_Matrix__mdt> autoLoan = [SELECT Field__c, Section__c FROM Security_Matrix__mdt WHERE Page__c LIKE :pageName];
        Map<String, String> mapFieldSection = new Map<String, String>();
        List<String> sectionList = new List<String>();
        for(Security_Matrix__mdt each : autoLoan){
            if(sectionList.contains(each.Section__c) == false){
                sectionList.add(each.Section__c);
            }
            mapFieldSection.put(each.Field__c, each.Section__c);
        }
        List<Data_Security_Matrix__c> dataSecMat = [SELECT Id, Access_Type__c, Section_Name__c FROM Data_Security_Matrix__c WHERE Section_Name__c IN:sectionList  AND Profile_Name__c =:profileName];
        Map<String, String> sectionAccessMap = new Map<String, String>();
        Boolean isVisibleForAuth = Test.isRunningTest() ? true : SecurityScan.verifyForAuth(recordId);
        for(Data_Security_Matrix__c i : dataSecMat){
            sectionAccessMap.put(i.Section_Name__c, i.Access_Type__c);
        }
        Map<String, Boolean> fieldAcess = new Map<String, Boolean>();
        for(String i : mapFieldSection.keySet()){
            Boolean isVisible = false;
            String section = mapFieldSection.get(i);
            String accessType = sectionAccessMap.get(section);

            if(accessType == 'All'){
                isVisible = true;
                isAuth = true;
            }
            else if(accessType == 'Authorize Only'){
                isVisible = isVisibleForAuth;
                if(isVisible == true){
                    isAuth = true;
                }
            }
            else {
                isVisible = false;
            }
            fieldAcess.put(i, isVisible);
        }
        fieldAcess.put('Authorize', isAuth);           
        return fieldAcess;
    }

    @AuraEnabled
    public static Map<String, Boolean> getAccessibleCustHolding(String accountId){
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
        Map<String, Boolean> accessCustMap = new Map<String, Boolean>();
        accessCustMap.put('isAccessibleCusHoldLow', RTL_AccountUtility.verifyFieldSecurity('RtlCust:Customer Product Holding (Low)', userProfile.name, accountId ));
        accessCustMap.put('isAccessibleCusHoldMid', RTL_AccountUtility.verifyFieldSecurity('RtlCust:Customer Product Holding (Medium)', userProfile.name, accountId ));
        accessCustMap.put('isAccessibleCusHoldHig', RTL_AccountUtility.verifyFieldSecurity('RtlCust:Customer Product Holding (High)', userProfile.name, accountId ));
        return accessCustMap;
    }

    @AuraEnabled
    public static Account getAccount(String recId, List<String> fields, List<String>trans_fields){
        try {
            return [SELECT Id, Name, TMB_Customer_ID_PE__c, RTL_Is_Employee__c, RTL_Suitability__c FROM Account WHERE Id = :recId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAllUnmaskBalance(){
        return ProductingUnmaskingSetup.getProductUnmaskSetting();
    }

    @AuraEnabled
    public static Object getSummarizedObj(String recordId, String tmbCustId, Boolean isEncrypt, String seqGrp, Object toSumMap, Boolean summaryString, Boolean summaryODLimit, Boolean isOutStandingLimit){
        Boolean isEmployee = isEmployee(tmbCustId);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(toSumMap));
        Map<String, Boolean> fieldVisible = getFieldVisibilityByPage(recordId, 'RetailProductHoldingSummary');
        Map<String, String> returnMap = new Map<String, String>();
        List<Object> outList = (List<Object>) jsonMap.get('outStandingList');
        List<Object> odList = (List<Object>) jsonMap.get('odLimitList');
        List<Object> accList = (List<Object>) jsonMap.get('accountList');
        List<Object> prodList = (List<Object>) jsonMap.get('productList');
        String prodGroup;
        String tag;
        Decimal outStanding = 0;
        Decimal odLimit = 0;
        if(isEncrypt == false){
            for(Object i : outList){
                outStanding += Decimal.valueOf(String.valueOf(i));
            }
            for(Object i : odList){
                odLimit += Decimal.valueOf(String.valueOf(i));
            }
        }
        else{
            for(Object i : outList){
                if(i instanceof String){
                    outStanding += Test.isRunningTest() ? Decimal.valueOf(String.valueOf(i)) : Decimal.valueOf(SFExtIntregration.decryptText(String.valueOf(i)));
                }
                else{
                    outStanding += Decimal.valueOf(String.valueOf(i));
                }
            }
            for(Object i : odList){
                if(i instanceof String){
                    odLimit += Test.isRunningTest() ? Decimal.valueOf(String.valueOf(i)) : Decimal.valueOf(SFExtIntregration.decryptText(String.valueOf(i)));
                }
                else{
                    odLimit += Decimal.valueOf(String.valueOf(i));
                }
            }
        }
        returnMap.put('AUM', SFExtIntregration.encyptText(String.valueOf(outStanding)));
        returnMap.put('Number_of_Account_AUM', SFExtIntregration.encyptText(String.valueOf(accList.size())));
        if(outStanding == 0){
            if(seqGrp == '1' || seqGrp == '3' || seqGrp == '7' || seqGrp == '8' || seqGrp == 'AutoLoan'){
                returnMap.put('MarkedOutstanding', (fieldVisible.get('ProductSum_MarkedOutstanding') == false || isEmployee == true) ? Label.Data_Condition_Hidden_Text : '-');
            }
            else{
                returnMap.put('MarkedOutstanding', fieldVisible.get('ProductSum_MarkedOutstanding') == false ? Label.Data_Condition_Hidden_Text : '-');
            }
        }
        else{
            String centOutStanding = getCents(outStanding);
            String markedOutstanding = isOutStandingLimit ? maskWithXX(String.valueOf(outStanding)) : (!summaryString ? maskWithXX(String.valueOf(outStanding)) : centOutStanding.contains('.') ? centOutStanding : centOutStanding + '.00');
            String strOutStanding;
            if(seqGrp == '1' || seqGrp == '3' || seqGrp == '7' || seqGrp == '8' || seqGrp == 'AutoLoan'){
                strOutStanding = isEmployee == true ? Label.Data_Condition_Hidden_Text : markedOutstanding;
            }
            else{
                strOutStanding = markedOutstanding;
            }
            returnMap.put('MarkedOutstanding', fieldVisible.get('ProductSum_MarkedOutstanding') == false ? Label.Data_Condition_Hidden_Text : strOutStanding);
        } 
        if(odLimit == 0){
            if(seqGrp == '3' || seqGrp == '7' || seqGrp == '8' || seqGrp == 'AutoLoan'){
                returnMap.put('MarkedODLimit', (fieldVisible.get('ProductSum_MarkedODLimit') == false || isEmployee == true) ? Label.Data_Condition_Hidden_Text : '-');
            }
            else{
                returnMap.put('MarkedODLimit', fieldVisible.get('ProductSum_MarkedODLimit') == false ? Label.Data_Condition_Hidden_Text : '-');
            }
        }
        else{
            String centOdLimit = getCents(odLimit);
            String markedOdLimit = isOutStandingLimit ? maskWithXX(String.valueOf(odLimit)) : (!summaryODLimit ? maskWithXX(String.valueOf(odLimit)) : centOdLimit.contains('.') ? centOdLimit : centOdLimit + '.00');
            String strOdLimit;
            if(seqGrp == '3' || seqGrp == '7' || seqGrp == '8' || seqGrp == 'AutoLoan'){
                strOdLimit = isEmployee == true ? Label.Data_Condition_Hidden_Text : markedOdLimit;
            }
            else{
                strOdLimit = markedOdLimit;
            }
            returnMap.put('MarkedODLimit', fieldVisible.get('ProductSum_MarkedODLimit') == false ? Label.Data_Condition_Hidden_Text : strOdLimit);
        }
        switch on seqGrp {
            when '1' {prodGroup = 'Transactional Deposit'; tag = 'Deposit_Product_Details';}
            when '2' {prodGroup = 'Non Transactional Deposit'; tag = 'Deposit_Product_Details';}
            when '3' {prodGroup = 'Credit Card'; tag = 'Credit_Card_RDC_Product_Details';}
            when '5' {prodGroup = 'Mutual Fund'; tag = 'Investment_Product_Details';}
            when '6' {prodGroup = 'Bancassurance'; tag = 'Bancassurance_Product_Details';}
            when '7' {prodGroup = 'Personal Loan'; tag = 'Loan_Product_Details';}
            when '8' {prodGroup = 'Secured Loan'; tag = 'Loan_Product_Details';}
            when 'AutoLoan' {prodGroup = 'Auto Loan'; tag = 'AutoLoan_Product_Details';}
            when else {prodGroup = 'Others'; tag = '';}
        }
        returnMap.put('Number_of_Account', fieldVisible.get('ProductSum_Number_of_Account') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(accList.size()));
        returnMap.put('Number_of_Product', fieldVisible.get('ProductSum_Number_of_Product') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(prodList.size()));
        returnMap.put('Product_Group', fieldVisible.get('ProductSum_Product_Group') == false ? Label.Data_Condition_Hidden_Text : prodGroup);
        returnMap.put('Tag', tag);
        return (Object) returnMap;
    }

    @AuraEnabled
    public static Boolean updateAUMField(String recordId, List<Object> dataList){
        Decimal outStanding = 0;
        Decimal noOfAccount = 0;
        for(Object i : dataList){
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
            if(String.valueOf(jsonMap.get('SeqGrp')) == '1' || String.valueOf(jsonMap.get('SeqGrp')) == '2' || String.valueOf(jsonMap.get('SeqGrp')) == '5'){
                outStanding += Decimal.valueOf(SFExtIntregration.decryptText(String.valueOf(jsonMap.get('AUM'))));
            }
            if(String.valueOf(jsonMap.get('SeqGrp')) == 'OTHERS'){
                noOfAccount += Decimal.valueOf(String.valueOf(jsonMap.get('Number_of_Account_AUM')));
            }
            else{
                noOfAccount += Decimal.valueOf(SFExtIntregration.decryptText(String.valueOf(jsonMap.get('Number_of_Account_AUM'))));
            }
        }

        Boolean isSuccess = RTL_ProductHoldingsLightningUtil.UpdateTotalAccountsAndSumOfDepesite(recordId, noOfAccount, outStanding);
        return isSuccess;
    }

    @AuraEnabled
    public static string get0EncryptString(Decimal val){
        return SFExtIntregration.encyptText(String.valueOf(val));
    }
}