public class AutoLoan_HPFeetHPDetailController {

    public class autoLoanHPFeetDetailWrapper{
        @AuraEnabled public String CarBrandName{ get; set; }
        @AuraEnabled public String CarChasis{ get; set; }
        @AuraEnabled public String CarColorName{ get; set; }
        @AuraEnabled public String CarEngineSize{ get; set; }
        @AuraEnabled public String CarpriceAmt{ get; set; }
        @AuraEnabled public String CarEngno{ get; set; }
        @AuraEnabled public String CarRegno{ get; set; }
        @AuraEnabled public String CarRegProv{ get; set; }
        @AuraEnabled public String CarTypeDesc{ get; set; }
        @AuraEnabled public String CarYear{ get; set; }
        @AuraEnabled public String ContractDate10{ get; set; }
        @AuraEnabled public String ContractNo{ get; set; }
        @AuraEnabled public String ContractStatusCode{ get; set; }
        @AuraEnabled public String CurrentOfInstallments{ get; set; }
        @AuraEnabled public String CustomerCode{ get; set; }
        @AuraEnabled public String CarDownAmt{ get; set; }
        @AuraEnabled public String DealerName{ get; set; }
        @AuraEnabled public String DueDay{ get; set; }
        @AuraEnabled public String FinancialAmount{ get; set; }
        @AuraEnabled public String FirstInstallmentDate10{ get; set; }
        @AuraEnabled public String HPTotalAmount{ get; set; }
        @AuraEnabled public String HubOwnerName{ get; set; }
        @AuraEnabled public String InstallmentAmount{ get; set; }
        @AuraEnabled public String InterestedRate{ get; set; }
        @AuraEnabled public String LastDueDate{ get; set; }
        @AuraEnabled public String MarketingOfficerName{ get; set; }
        @AuraEnabled public String NumberOfInstallmentBalance{ get; set; }
        @AuraEnabled public String OutstandingAmount{ get; set; }
        @AuraEnabled public String OverdueAmount{ get; set; }
        @AuraEnabled public String OverdueNo{ get; set; }
        @AuraEnabled public String PaymentMethodDesc{ get; set; }
        @AuraEnabled public String PenaltyAmount{ get; set; }
        @AuraEnabled public String ProductCarType{ get; set; }
        @AuraEnabled public String ProductCode{ get; set; }
        @AuraEnabled public String TotalInstallments{ get; set; }
        @AuraEnabled public String ContractStatusName{ get; set; }
        @AuraEnabled public String GuarantorName1{ get; set; }
        @AuraEnabled public String GuarantorBD1{ get; set; }
        @AuraEnabled public String GuarantorIDNo1{ get; set; }
        @AuraEnabled public String GuarantorName2{ get; set; }
        @AuraEnabled public String GuarantorBD2{ get; set; }
        @AuraEnabled public String GuarantorIDNo2{ get; set; }
        @AuraEnabled public String GuarantorName3{ get; set; }
        @AuraEnabled public String GuarantorBD3{ get; set; }
        @AuraEnabled public String GuarantorIDNo3{ get; set; }
        @AuraEnabled public String GuarantorName4{ get; set; }
        @AuraEnabled public String GuarantorBD4{ get; set; }
        @AuraEnabled public String GuarantorIDNo4{ get; set; }
        @AuraEnabled public String CarModel{ get; set; }
    }

    private static Boolean isEmployee(String tmbCustId) {
        try {
            return [SELECT RTL_Is_Employee__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1 FOR UPDATE].RTL_Is_Employee__c;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Object getHPFeetDetail(String Company, String ContractNo, String TranDate, String TranTime, String recordId, String tmbCustId) {
        String body = '{"Company":"' + Company + '","ContractNo":"' + ContractNo + '","TranDate":"' + TranDate + '","TranTime":"' + TranTime + '"}';
        // Object result = parseWrapper(RTL_ProductHoldingWebSvcUtils.calloutAutoLoan_HpFeetHpDetail(body), recordId, tmbCustId);
        Object resultDetail = RTL_ProductHoldingWebSvcUtils.calloutAutoLoan_HpFeetHpDetail(body);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resultDetail));
        if(String.valueOf(jsonMap.get('HTTPStatusCode')) == '200'){
            return parseWrapper(resultDetail, recordId, tmbCustId);
        }
        else{
            return resultDetail;
        }
        // String response = '{"isError":false,"Output":[{"ContractNo":"252016203974","CustomerCode":"1844976","ContractDate10":"28/02/2562","DealerName":"บจก. 107993 ชื่อผูเ้ช่าซื้อ 107993 นามสกุล","CarpriceAmt":"605000.00","HPTotalAmount":"350016.00","InstallmentAmount":"7292.00","InterestedRate":".00","TotalInstallments":"48","CurrentOfInstallments":"48","NumberOfInstallmentBalance":"0","CarBrandName":"MAZDA","CarModel":"2","CarColorName":"แดง","ProductCarType":"รถใหม่","FinancialAmount":"350000.00","OverdueAmount":"0.77","PenaltyAmount":"0.00","OverdueNo":"0","HubOwnerName":"งามวงศ์วาน","ProductCode":"NEW","LastDueDate":"10/03/2566","MarketingOfficerName":"น.ส. 3867038 ชื่อผูเ้ช่าซื้อ 3867038 นามสกุล","CarDownAmt":"255000.00","DueDay":"10","PaymentMethodDesc":"2 :Auto Debit","FirstInstallmentDate10":"10/04/2562","OutstandingAmount":"0.00","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","CarYear":"2019","CarTypeDesc":"เก๋ง 2 ตอน","CarRegno":"8กส745","CarRegProv":"กรุงเทพ ฯ","CarChasis":"MM8DJ2H3A0W428926","CarEngno":"P350338083","CarEngineSize":"1299","GuarantorName1":"","GuarantorBD1":"","GuarantorIDNo1":"","GuarantorName2":"","GuarantorBD2":"","GuarantorIDNo2":"","GuarantorName3":"","GuarantorBD3":"","GuarantorIDNo3":"","GuarantorName4":"","GuarantorBD4":"","GuarantorIDNo4":""}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}';
        // Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        // return (Object) responseMap;
    }

    private static Object parseWrapper(Object resultFromDetail, String recordId, String tmbCustId){
        try{
            Map<String, Boolean> maskMap = getFieldMask();
            Boolean isEmployee = isEmployee(tmbCustId);
            Map<String, Object> aldxwfmdtResult = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(CommercialAutoLoanController.getALDXWFMdt()));
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resultFromDetail));
            List<autoLoanHPFeetDetailWrapper> autoDetailList = new List<autoLoanHPFeetDetailWrapper>();
            Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Auto Loan%');
            if(result.get('isError') == false){
                List<Object> outputList = (List<Object>) result.get('Output');
                for(Object i : outputList){
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    autoLoanHPFeetDetailWrapper auto = new autoLoanHPFeetDetailWrapper();
                    Map<String, Object> aldxOfCode = (Map<String, Object>)aldxwfmdtResult.get(String.valueOf(each.get('ContractStatusCode'))); 
                    Date ctdd;
                    Date ldd;
                    Date fid;
                    String ctd = genMMDDYYYY(String.valueOf(each.get('ContractDate10')));
                    String ld = genMMDDYYYY(String.valueOf(each.get('LastDueDate')));
                    String fi = genMMDDYYYY(String.valueOf(each.get('FirstInstallmentDate10')));
                    if(ctd != 'Invalid'){
                        ctdd = date.parse(ctd);
                    }
                    if(ld != 'Invalid'){
                        ldd = date.parse(ld);
                    }
                    if(fi != 'Invalid'){
                        fid = date.parse(fi);
                    }
                    auto.ContractDate10 = fieldVisible.get('ALDetail_ContractDate10') == false ? Label.Data_Condition_Hidden_Text : ctd == 'Invalid' ? String.valueOf(each.get('ContractDate10')) : NumberHelper.DateFormat(ctdd);
                    auto.LastDueDate = fieldVisible.get('ALDetail_LastDueDate') == false ? Label.Data_Condition_Hidden_Text : ld == 'Invalid' ? String.valueOf(each.get('LastDueDate')) : NumberHelper.DateFormat(ldd);
                    auto.FirstInstallmentDate10 = fieldVisible.get('ALDetail_FirstInstallmentDate10') == false ? Label.Data_Condition_Hidden_Text : fi == 'Invalid' ? String.valueOf(each.get('FirstInstallmentDate10')) : NumberHelper.DateFormat(fid);

                    auto.CarBrandName = fieldVisible.get('ALDetail_CarBrandName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarBrandName'));
                    auto.CarChasis = fieldVisible.get('ALDetail_CarChasis') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarChasis'));
                    auto.CarColorName = fieldVisible.get('ALDetail_CarColorName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarColorName'));
                    auto.CarEngineSize = fieldVisible.get('ALDetail_CarEngineSize') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarEngineSize'));
                    auto.CarEngno = fieldVisible.get('ALDetail_CarEngno') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarEngno'));
                    auto.CarRegno = fieldVisible.get('ALDetail_CarRegno') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarRegno'));
                    auto.CarRegProv = fieldVisible.get('ALDetail_CarRegProv') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarRegProv'));
                    auto.CarTypeDesc = fieldVisible.get('ALDetail_CarTypeDesc') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarTypeDesc'));
                    auto.CarYear = fieldVisible.get('ALDetail_CarYear') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarYear'));
                    auto.ContractNo = fieldVisible.get('ALDetail_ContractNo') == false ? Label.Data_Condition_Hidden_Text :  maskContractNo(String.valueOf(each.get('ContractNo')));
                    auto.ContractStatusCode = fieldVisible.get('ALDetail_ContractStatusCode') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ContractStatusCode'));
                    auto.CurrentOfInstallments = fieldVisible.get('ALDetail_CurrentOfInstallments') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CurrentOfInstallments'));
                    auto.CustomerCode = fieldVisible.get('ALDetail_CustomerCode') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CustomerCode'));
                    auto.DealerName = fieldVisible.get('ALDetail_DealerName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('DealerName'));
                    auto.DueDay = fieldVisible.get('ALDetail_DueDay') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('DueDay'));
                    auto.HubOwnerName = fieldVisible.get('ALDetail_HubOwnerName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('HubOwnerName'));
                    auto.InterestedRate = fieldVisible.get('ALDetail_InterestedRate') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('InterestedRate'));
                    auto.MarketingOfficerName = fieldVisible.get('ALDetail_MarketingOfficerName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('MarketingOfficerName'));
                    auto.NumberOfInstallmentBalance = fieldVisible.get('ALDetail_NumberOfInstallmentBalance') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('NumberOfInstallmentBalance'));
                    auto.OverdueNo = fieldVisible.get('ALDetail_OverdueNo') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('OverdueNo'));
                    auto.PaymentMethodDesc = fieldVisible.get('ALDetail_PaymentMethodDesc') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('PaymentMethodDesc'));
                    auto.ProductCarType = fieldVisible.get('ALDetail_ProductCarType') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ProductCarType'));
                    auto.ProductCode = fieldVisible.get('ALDetail_ProductCode') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ProductCode'));
                    auto.TotalInstallments = fieldVisible.get('ALDetail_TotalInstallments') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('TotalInstallments'));
                    auto.CarModel = fieldVisible.get('ALDetail_CarModel') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('CarModel'));
                    auto.ContractStatusName = fieldVisible.get('ALDetail_ContractStatusName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('ContractStatusName'));

                    Date gbd1d, gbd2d, gbd3d, gbd4d;
                    String gbd1 = genMMDDYYYY(String.valueOf(each.get('GuarantorBD1')));
                    String gbd2 = genMMDDYYYY(String.valueOf(each.get('GuarantorBD2')));
                    String gbd3 = genMMDDYYYY(String.valueOf(each.get('GuarantorBD3')));
                    String gbd4 = genMMDDYYYY(String.valueOf(each.get('GuarantorBD4')));
                    if(gbd1 != 'Invalid'){
                        gbd1d = date.parse(gbd1);
                    }
                    if(gbd2 != 'Invalid'){
                        gbd2d = date.parse(gbd2);
                    }
                    if(gbd3 != 'Invalid'){
                        gbd3d = date.parse(gbd3);
                    }
                    if(gbd4 != 'Invalid'){
                        gbd4d = date.parse(gbd4);
                    }
                    auto.GuarantorBD1 = fieldVisible.get('ALDetail_GuarantorBD1') == false ? Label.Data_Condition_Hidden_Text : gbd1 == 'Invalid' ? String.valueOf(each.get('GuarantorBD1')) : NumberHelper.DateFormat(gbd1d);
                    auto.GuarantorBD2 = fieldVisible.get('ALDetail_GuarantorBD2') == false ? Label.Data_Condition_Hidden_Text : gbd2 == 'Invalid' ? String.valueOf(each.get('GuarantorBD2')) : NumberHelper.DateFormat(gbd2d);
                    auto.GuarantorBD3 = fieldVisible.get('ALDetail_GuarantorBD3') == false ? Label.Data_Condition_Hidden_Text : gbd3 == 'Invalid' ? String.valueOf(each.get('GuarantorBD3')) : NumberHelper.DateFormat(gbd3d);
                    auto.GuarantorBD4 = fieldVisible.get('ALDetail_GuarantorBD4') == false ? Label.Data_Condition_Hidden_Text : gbd4 == 'Invalid' ? String.valueOf(each.get('GuarantorBD4')) : NumberHelper.DateFormat(gbd4d);
                    auto.GuarantorName1 = fieldVisible.get('ALDetail_GuarantorName1') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorName1'));
                    auto.GuarantorIDNo1 = fieldVisible.get('ALDetail_GuarantorIDNo1') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorIDNo1'));
                    auto.GuarantorName2 = fieldVisible.get('ALDetail_GuarantorName2') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorName2'));
                    auto.GuarantorIDNo2 = fieldVisible.get('ALDetail_GuarantorIDNo2') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorIDNo2'));
                    auto.GuarantorName3 = fieldVisible.get('ALDetail_GuarantorName3') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorName3'));
                    auto.GuarantorIDNo3 = fieldVisible.get('ALDetail_GuarantorIDNo3') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorIDNo3'));
                    auto.GuarantorName4 = fieldVisible.get('ALDetail_GuarantorName4') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorName4'));
                    auto.GuarantorIDNo4 = fieldVisible.get('ALDetail_GuarantorIDNo4') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('GuarantorIDNo4'));

                    String oda = getCents(Decimal.valueOf(String.valueOf(each.get('OverdueAmount'))));
                    String pna = getCents(Decimal.valueOf(String.valueOf(each.get('PenaltyAmount'))));
                    oda = oda.contains('.') ? oda : oda + '.00';
                    pna = pna.contains('.') ? pna : pna + '.00';
                    auto.OverdueAmount = fieldVisible.get('ALDetail_OverdueAmount') == false ? Label.Data_Condition_Hidden_Text : aldxOfCode != null ? (String) aldxOfCode.get('WARNING_MESSAGE__c') : isEmployee == true ? maskWithXX((String) each.get('OverdueAmount')) : maskMap.get('OverdueAmount') == false ? maskWithXX((String) each.get('OverdueAmount')) : oda;
                    auto.PenaltyAmount = fieldVisible.get('ALDetail_PenaltyAmount') == false ? Label.Data_Condition_Hidden_Text : aldxOfCode != null ? (String) aldxOfCode.get('WARNING_MESSAGE__c') : isEmployee == true ? maskWithXX((String) each.get('PenaltyAmount')) : maskMap.get('PenaltyAmount') == false ? maskWithXX((String) each.get('PenaltyAmount')) : pna;
                    auto.HPTotalAmount = (isEmployee == true || fieldVisible.get('ALDetail_HPTotalAmount') == false) ? Label.Data_Condition_Hidden_Text : maskMap.get('HPTotalAmount') == false ? maskWithXX((String) each.get('HPTotalAmount')) : getCents(Decimal.valueOf(String.valueOf(each.get('HPTotalAmount'))));
                    auto.OutstandingAmount = (isEmployee == true || fieldVisible.get('ALDetail_OutstandingAmount') == false) ? Label.Data_Condition_Hidden_Text : aldxOfCode != null ? (String) aldxOfCode.get('WARNING_MESSAGE__c') : maskMap.get('OutstandingAmount') == false ? maskWithXX((String) each.get('OutstandingAmount')) : getCents(Decimal.valueOf(String.valueOf(each.get('OutstandingAmount'))));
                    auto.InstallmentAmount = (isEmployee == true || fieldVisible.get('IALDetail_nstallmentAmount') == false) ? Label.Data_Condition_Hidden_Text : maskMap.get('InstallmentAmount') == false ? maskWithXX((String) each.get('InstallmentAmount')) : getCents(Decimal.valueOf(String.valueOf(each.get('InstallmentAmount'))));
                    auto.CarDownAmt = fieldVisible.get('ALDetail_CarDownAmt') == false ? Label.Data_Condition_Hidden_Text :  isEmployee == true ? maskWithXX((String) each.get('CarDownAmt')) : maskMap.get('CarDownAmt') == false ? maskWithXX((String) each.get('CarDownAmt')) : getCents(Decimal.valueOf(String.valueOf(each.get('CarDownAmt'))));
                    auto.CarpriceAmt = fieldVisible.get('ALDetail_CarpriceAmt') == false ? Label.Data_Condition_Hidden_Text : isEmployee == true ? maskWithXX((String) each.get('CarpriceAmt')) : maskMap.get('CarpriceAmt') == false ? maskWithXX((String) each.get('CarpriceAmt')) : getCents(Decimal.valueOf(String.valueOf(each.get('CarpriceAmt'))));
                    auto.FinancialAmount = fieldVisible.get('ALDetail_FinancialAmount') == false ? Label.Data_Condition_Hidden_Text : isEmployee == true ? maskWithXX((String) each.get('FinancialAmount')) : maskMap.get('FinancialAmount') == false ? maskWithXX((String) each.get('FinancialAmount')) : getCents(Decimal.valueOf(String.valueOf(each.get('FinancialAmount'))));
                    autoDetailList.add(auto);
                }
                result.put('Authorize', fieldVisible.get('Authorize'));
                result.put('Output', (Object) autoDetailList);
            }
            return result;
        }catch(Exception e){
            return new Map<String, Object>();
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

    public static string maskContractNo(String contractNo){
        String mask = 'xxxxxxxyyyyy'.substring(0, 7);
        String remain = contractNo.substring(7);
        return mask + remain;
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
    public static String getUnmaskBalance(){
        return ProductingUnmaskingSetup.getProductUnmaskSetting();
    }

    public static Map<String, Boolean> getFieldMask(){
        try{
            String str = ProductingUnmaskingSetup.getProductUnmaskSetting();
            Map<String, Object> unmaskMap = (Map<String, Object>)JSON.deserializeUntyped(str);
            List<Object> autoUnmaskMapList = (List<Object>)unmaskMap.get('AutoLoan_Detail');
            Map<String, Boolean> maskMap = new Map<String, Boolean>();
            for(Object i : autoUnmaskMapList){
                Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                maskMap.put((String) each.get('field'), (Boolean) each.get('unmasked'));
            }
            return maskMap;
        }catch(Exception e){
            throw new IllegalArgumentException('error at getFieldMask');
        }
    }
}