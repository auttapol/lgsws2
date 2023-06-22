public class BancassuranceDetailController {

    public class BAInfoWrapper{
        @AuraEnabled public String ProductType{ get; set; }
        @AuraEnabled public String TMBProductCode{ get; set; }
        @AuraEnabled public String ProductName{ get; set; }
        @AuraEnabled public String EffectiveDate{ get; set; }
        @AuraEnabled public String PolicyStatus{ get; set; }
        @AuraEnabled public String PolicyNo{ get; set; }
        @AuraEnabled public String SumInsured{ get; set; }
        @AuraEnabled public String AFYP{ get; set; }
        @AuraEnabled public String ExpiryDate{ get; set; }
        @AuraEnabled public String Sales{ get; set; }
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String Message{ get; set; }
    }
    
    public class BADetailWrapper{
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String Message{ get; set; }
        @AuraEnabled public String InsuranceCompany{ get; set; }
        @AuraEnabled public String Address{ get; set; }
        @AuraEnabled public String ContactNumber1{ get; set; }
        @AuraEnabled public String ContactNumber2{ get; set; }
    }
    
    public class PaymentInfoWrapper{
        @AuraEnabled public String PaymentMode{ get; set; }        
        @AuraEnabled public String PremiumAmount{ get; set; }        
        @AuraEnabled public String PaymentMethod{ get; set; }        
        @AuraEnabled public String TotalPremiumPaid{ get; set; }        
        @AuraEnabled public String YearOfPayment{ get; set; }        
        @AuraEnabled public String NumberOfTimePremiumPaid{ get; set; }        
        @AuraEnabled public String LastPaymentDate{ get; set; }        
        @AuraEnabled public String NextDueDate{ get; set; }        
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }        
    }
    
    public class NextCashBackWrapper{
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }        
        @AuraEnabled public String PaymentDate{ get; set; }        
        @AuraEnabled public String Amount{ get; set; }        
        @AuraEnabled public String TotalPaid{ get; set; }        
    }

    public class PropAssetWrapper{
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }        
        @AuraEnabled public String Address{ get; set; } 
    }

    public class AutomobileWrapper{
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }        
        @AuraEnabled public String Brand{ get; set; } 
        @AuraEnabled public String YearOfManufactured{ get; set; } 
        @AuraEnabled public String Model{ get; set; } 
        @AuraEnabled public String PlateNumber{ get; set; } 
    }

    public class BeneficiaryInfoWrapper{
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }        
        @AuraEnabled public List<Beneficiary> Beneficiary{ get; set; } 
    }

    public class Beneficiary{
        @AuraEnabled public String Name{ get; set; }        
        @AuraEnabled public String Relationship{ get; set; }  
    }

    public class ClaimRecordWrapper{
        @AuraEnabled public String Status{ get; set; }        
        @AuraEnabled public String Message{ get; set; }  
        @AuraEnabled public List<EachClaimRecordWrapper> ClaimRecord{ get; set; }  
    }

    public class EachClaimRecordWrapper{
        @AuraEnabled public String TempDate{ get; set; }        
        @AuraEnabled public String Type{ get; set; }  
        @AuraEnabled public String Description{ get; set; }  
        @AuraEnabled public String RequestAmount{ get; set; }  
        @AuraEnabled public String ApprovedAmount{ get; set; }  
    }

    @AuraEnabled
    public static Object getBancDetailData(String rmId, String policyNo, String recordId, String tmbCustId){
        String reqBody = '{"GetBancassuranceAccountDetailRequest":{"RMID":"' + rmId + '","PolicyNumber":"' + policyNo + '"}}';
        String responseBody = RTL_ProductHoldingWebSvcUtils.callOSC05Detail(reqBody, tmbCustId);
        // if (Test.isRunningTest()) {
            // responseBody = '{"GetBancassuranceAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","BancassuranceInformation":{"Status":"SUCCESS","Message":"","ProductType":"LIFE INSURANCE","TMBProductCode":"En05","ProductName":"Smart Life 15/8","EffectiveDate":"2008-05-26+07:00","PolicyStatus":"Active","PolicyNo":"T00004644","SumInsured":"100000","AFYP":"25700","ExpiryDate":"2023-05-26+07:00","Sales":"14487"},"BancassuranceDetails":{"Status":"SUCCESS","Message":"","InsuranceCompany":"FWD Life Insurance"},"PaymentInformation":{"Status":"SUCCESS","Message":"","PaymentMode":"Annual","PremiumAmount":"25700","PaymentMethod":"Cheque","TotalPremiumPaid":"25700","YearOfPayment":" of 8","NumberOfTimePremiumPaid":"1"},"NextCashBackInformation":{"Status":"SUCCESS","Message":"","PaymentDate":"2018-05-16+07:00","Amount":"5000"},"InsuredPropertyAsset":{"Status":"SUCCESS","Message":"","Address":", , , , "},"InsuredAutomobileAsset":{"Status":"SUCCESS","Message":"","Brand":"","YearOfManufactured":"","Model":"","PlateNumber":""},"BeneficiaryInformation":{"Status":"SUCCESS","Message":"","Beneficiary":[{"Name":" ??????????????","Relationship":"คู่สมรส"},{"Name":"","Relationship":"น้อง"}]},"InsuranceClaimRecord":{"Status":"SUCCESS","Message":""}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}';
        // }
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        Map<String, Object> checkStatus = (Map<String,Object>)jsonMap.get('Status');
        Map<String, Object> returnMap = new Map<String, Object>(jsonMap);
        if(String.valueOf(checkStatus.get('StatusCode')) != '200'){
            checkStatus.put( 'StatusDesc', RTL_ProductHoldingSummaryController.getErrorMessageForBanc(String.valueOf(checkStatus.get('StatusCode')), String.valueOf(checkStatus.get('StatusDesc'))));
            returnMap.put('Status', checkStatus);
            return (Object) returnMap;
        }
        else{
            try{
                Map<String, Object> outsideStatus = (Map<String, Object>)jsonMap.get('Status');
                if(String.valueOf(outsideStatus.get('StatusCode')) != '200'){
                    return (Object) jsonMap;
                }
                Map<String, Object> returnGetDetail = new Map<String, Object>();
                Map<String, Object> returnResult = new Map<String, Object>();
                Map<String, Object> getDetail = (Map<String, Object>)jsonMap.get('GetBancassuranceAccountDetailResponse');
                Map<String, Object> result = (Map<String, Object>)getDetail.get('Result');
                String resultStatus = String.valueOf(result.get('Status'));
                String resultMessage = String.valueOf(result.get('Message'));
                if(resultStatus == 'SUCCESS'){
                    Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Details of Bancassurance Product');
                    returnResult.put('Status', result.get('Status'));
                    returnResult.put('Message', result.get('Message'));
                    returnResult.put('BancassuranceInformation', parseBAInfo(result, fieldVisible));
                    returnResult.put('BancassuranceDetails', parseBADetail(result, fieldVisible));
                    returnResult.put('PaymentInformation', parsePayment(result, fieldVisible));
                    returnResult.put('NextCashBackInformation', parseNextCashBack(result, fieldVisible));
                    returnResult.put('InsuredPropertyAsset', parsePropertyAsset(result, fieldVisible));
                    returnResult.put('InsuredAutomobileAsset', parseAutoMobileAsset(result, fieldVisible));
                    returnResult.put('BeneficiaryInformation', parseBeneficaryInfo(result, fieldVisible));
                    returnResult.put('InsuranceClaimRecord', parseClaimRecord(result, fieldVisible));
                    returnGetDetail.put('Result', returnResult);
                    returnMap.put('GetBancassuranceAccountDetailResponse', returnGetDetail);
                    returnMap.put('Authorize', fieldVisible.get('Authorize'));
                }
                return (Object) returnMap;
            }catch(Exception e){
                return (Object) jsonMap;
            }
        }
    }

    private static AutomobileWrapper parseAutoMobileAsset(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('InsuredAutomobileAsset');
        AutomobileWrapper wrapper = new AutomobileWrapper();
        try{
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            wrapper.Brand = fieldVisible.get('BADetail_Brand') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('Brand');
            wrapper.PlateNumber = fieldVisible.get('BADetail_PlateNumber') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('PlateNumber');
            wrapper.Model = fieldVisible.get('BADetail_Model') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('Model');
            wrapper.YearOfManufactured = fieldVisible.get('BADetail_YearOfManufactured') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('YearOfManufactured');
            return wrapper;
        }
        catch(Exception e){
            return wrapper;
        }
    }

    private static ClaimRecordWrapper parseClaimRecord(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('InsuranceClaimRecord');
        ClaimRecordWrapper wrapper = new ClaimRecordWrapper();
        try{
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            Object o = jsonMap.get('ClaimRecord');
            if(o instanceof List<Object>){
                List<EachClaimRecordWrapper> claimRecordList = new List<EachClaimRecordWrapper>();
                List<Object> objList = (List<Object>) jsonMap.get('ClaimRecord');
                for(Object i : objList){
                    EachClaimRecordWrapper cr = new EachClaimRecordWrapper();
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    Date tdd;
                    String td = genDateFormat(String.valueOf(each.get('Date')));
                    if(td != 'Invalid'){
                        tdd = date.parse(td);
                    }
                    cr.TempDate = fieldVisible.get('BADetail_ClaimDate') == false ? Label.Data_Condition_Hidden_Text : td == 'Invalid' ? String.valueOf(each.get('Date')) : NumberHelper.DateFormat(tdd);
                    cr.Type = fieldVisible.get('BADetail_ClaimType') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Type');
                    cr.Description = fieldVisible.get('BADetail_ClaimDescription') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Description');
                    cr.RequestAmount = fieldVisible.get('BADetail_ClaimRequestAmount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf((String) each.get('RequestAmount')));
                    cr.ApprovedAmount = fieldVisible.get('BADetail_ClaimApprovedAmount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf((String) each.get('ApprovedAmount')));
                    claimRecordList.add(cr);
                }
                wrapper.ClaimRecord = claimRecordList;
                return wrapper;
            }
            else{
                List<EachClaimRecordWrapper> claimRecordList = new List<EachClaimRecordWrapper>();
                EachClaimRecordWrapper cr = new EachClaimRecordWrapper();
                Map<String, Object> obj = (Map<String, Object>) jsonMap.get('ClaimRecord');
                Date tdd;
                String td = genDateFormat((String) obj.get('Date'));
                if(td != 'Invalid'){
                    tdd = date.parse(td);
                }
                cr.TempDate = fieldVisible.get('BADetail_ClaimDate') == false ? Label.Data_Condition_Hidden_Text : td == 'Invalid' ? String.valueOf(obj.get('Date')) : NumberHelper.DateFormat(tdd);
                cr.Type = fieldVisible.get('BADetail_ClaimType') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('Type');
                cr.Description = fieldVisible.get('BADetail_ClaimDescription') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('Description');
                cr.RequestAmount = fieldVisible.get('BADetail_ClaimRequestAmount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf((String) obj.get('RequestAmount')));
                cr.ApprovedAmount = fieldVisible.get('BADetail_ClaimApprovedAmount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf((String) obj.get('ApprovedAmount')));
                claimRecordList.add(cr);
                wrapper.ClaimRecord = claimRecordList;
                return wrapper;
            }
        }catch(Exception e){
            return wrapper;
        }
    }

    private static BeneficiaryInfoWrapper parseBeneficaryInfo(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('BeneficiaryInformation');
        BeneficiaryInfoWrapper wrapper = new BeneficiaryInfoWrapper();
        try{
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            Object o = jsonMap.get('Beneficiary');
            if(o instanceof List<Object>){
                List<Object> objList = (List<Object>) jsonMap.get('Beneficiary');
                List<Beneficiary> beneList = new List<Beneficiary>();
                for(Object i : objList){
                    Beneficiary bene = new Beneficiary();
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    bene.Name = fieldVisible.get('BADetail_Beneficiary_Name') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Name');
                    bene.Relationship = fieldVisible.get('BADetail_Beneficiary_Relationship') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Relationship');
                    beneList.add(bene);
                }
                wrapper.Beneficiary = beneList;
                return wrapper;
            }
            else{
                Beneficiary bene = new Beneficiary();
                Map<String, Object> beneMap = (Map<String, Object>) jsonMap.get('Beneficiary');
                List<Beneficiary> beneList = new List<Beneficiary>();
                bene.Name = fieldVisible.get('BADetail_Beneficiary_Name') == false ? Label.Data_Condition_Hidden_Text : (String) beneMap.get('Name');
                bene.Relationship = fieldVisible.get('BADetail_Beneficiary_Relationship') == false ? Label.Data_Condition_Hidden_Text : (String) beneMap.get('Relationship');
                beneList.add(bene);
                wrapper.Beneficiary = beneList;
                return wrapper;
            }
        }catch(Exception e){
            return  wrapper;
        }
    }

    private static PropAssetWrapper parsePropertyAsset(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('InsuredPropertyAsset');
        PropAssetWrapper wrapper = new PropAssetWrapper();
        try{
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            wrapper.Address = fieldVisible.get('BADetail_PropertyAddress') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('Address');
            return wrapper;
        }
        catch(Exception e){
            return wrapper;
        }
    }

    private static NextCashBackWrapper parseNextCashBack(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('NextCashBackInformation');
        NextCashBackWrapper wrapper = new NextCashBackWrapper();
        try{
            Date pd;
            String p = genDateFormat(String.valueOf(jsonMap.get('PaymentDate')));
            if(p != 'Invalid'){
                pd = date.parse(p);
            }
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            wrapper.PaymentDate = fieldVisible.get('BADetail_PaymentDate') == false ? Label.Data_Condition_Hidden_Text : p == 'Invalid' ? String.valueOf(jsonMap.get('PaymentDate')) : NumberHelper.DateFormat(pd);
            wrapper.Amount = fieldVisible.get('BADetail_Amount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(jsonMap.get('Amount'))).setScale(2));
            wrapper.TotalPaid = fieldVisible.get('BADetail_TotalPaid') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(jsonMap.get('TotalPaid'))).setScale(2));
            return wrapper;
        }catch(Exception e){
            return wrapper;
        }
    }

    private static BADetailWrapper parseBADetail(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> baDetailMap = (Map<String, Object>)resultMap.get('BancassuranceDetails');
        BADetailWrapper baDetail = new BADetailWrapper();
        try{
            baDetail.Status = (String) baDetailMap.get('Status');
            baDetail.Message = (String) baDetailMap.get('Message');
            baDetail.InsuranceCompany = fieldVisible.get('BADetail_InsuranceCompany') == false ? Label.Data_Condition_Hidden_Text : (String) baDetailMap.get('InsuranceCompany');
            baDetail.Address = fieldVisible.get('BADetail_Address') == false ? Label.Data_Condition_Hidden_Text : (String) baDetailMap.get('Address');
            baDetail.ContactNumber1 = fieldVisible.get('BADetail_ContactNumber1') == false ? Label.Data_Condition_Hidden_Text : (String) baDetailMap.get('ContactNumber1');
            baDetail.ContactNumber2 = fieldVisible.get('BADetail_ContactNumber2') == false ? Label.Data_Condition_Hidden_Text : (String) baDetailMap.get('ContactNumber2');
            return baDetail;
        }catch(Exception e){
            return baDetail;
        }
    }
    
    private static PaymentInfoWrapper parsePayment(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> jsonMap = (Map<String, Object>)resultMap.get('PaymentInformation');
        PaymentInfoWrapper wrapper = new PaymentInfoWrapper();
        try{
            Date lpd;
            Date ndd;
            String lp = genDateFormat(String.valueOf(jsonMap.get('LastPaymentDate')));
            String nd = genDateFormat(String.valueOf(jsonMap.get('NextDueDate')));
            if( lp != 'Invalid' ){
                lpd = date.parse(lp);
            }
            if( nd != 'Invalid' ){
                ndd = date.parse(nd);
            }
            wrapper.Status = (String) jsonMap.get('Status');
            wrapper.Message = (String) jsonMap.get('Message');
            wrapper.PaymentMode = fieldVisible.get('BADetail_PaymentMode') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('PaymentMode');
            wrapper.PremiumAmount = fieldVisible.get('BADetail_PremiumAmount') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(jsonMap.get('PremiumAmount'))));
            wrapper.PaymentMethod = fieldVisible.get('BADetail_PaymentMethod') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('PaymentMethod');
            wrapper.TotalPremiumPaid = fieldVisible.get('BADetail_TotalPremiumPaid') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(jsonMap.get('TotalPremiumPaid'))));
            wrapper.YearOfPayment = fieldVisible.get('BADetail_YearOfPayment') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('YearOfPayment');
            wrapper.NumberOfTimePremiumPaid = fieldVisible.get('BADetail_NumberOfTimePremiumPaid') == false ? Label.Data_Condition_Hidden_Text : (String) jsonMap.get('NumberOfTimePremiumPaid');
            wrapper.LastPaymentDate = fieldVisible.get('BADetail_LastPaymentDate') == false ? Label.Data_Condition_Hidden_Text : lp == 'Invalid' ? String.valueOf(jsonMap.get('LastPaymentDate')) : NumberHelper.DateFormat(lpd);
            wrapper.NextDueDate = fieldVisible.get('BADetail_NextDueDate') == false ? Label.Data_Condition_Hidden_Text : nd == 'Invalid' ? String.valueOf(jsonMap.get('NextDueDate')) : NumberHelper.DateFormat(ndd); 
            return wrapper;
        }catch(Exception e){
            return wrapper;
        }
    }

    private static BAInfoWrapper parseBAInfo(Map<String, Object> resultMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> baInfoMap = (Map<String, Object>)resultMap.get('BancassuranceInformation');
        BAInfoWrapper baInfo = new BAInfoWrapper();
        try{
            Date exDate;
            Date efDate;
            String ex = genDateFormat(String.valueOf(baInfoMap.get('ExpiryDate')));
            String ef = genDateFormat(String.valueOf(baInfoMap.get('EffectiveDate')));
            if(ex != 'Invalid'){
                exDate = date.parse(ex);
            }
            if(ef != 'Invalid'){
                efDate = date.parse(ef);
            }
            baInfo.ProductType = fieldVisible.get('BADetail_ProductType') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('ProductType');
            baInfo.TMBProductCode = fieldVisible.get('BADetail_TMBProductCode') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('TMBProductCode');
            baInfo.ProductName = fieldVisible.get('BADetail_ProductName') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('ProductName');
            baInfo.PolicyStatus = fieldVisible.get('BADetail_PolicyStatus') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('PolicyStatus');
            baInfo.PolicyNo = fieldVisible.get('BADetail_PolicyNo') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('PolicyNo');
            baInfo.SumInsured = fieldVisible.get('BADetail_SumInsured') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(baInfoMap.get('SumInsured'))));
            baInfo.AFYP = fieldVisible.get('BADetail_AFYP') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(baInfoMap.get('AFYP'))));
            baInfo.Sales = fieldVisible.get('BADetail_Sales') == false ? Label.Data_Condition_Hidden_Text : (String) baInfoMap.get('Sales');
            baInfo.Message = (String) baInfoMap.get('Message');
            baInfo.Status = (String) baInfoMap.get('Status');
            baInfo.EffectiveDate = fieldVisible.get('BADetail_EffectiveDate') == false ? Label.Data_Condition_Hidden_Text : ef == 'Invalid' ? String.valueOf(baInfoMap.get('EffectiveDate')) : NumberHelper.DateFormat(efDate);
            baInfo.ExpiryDate = fieldVisible.get('BADetail_ExpiryDate') == false ? Label.Data_Condition_Hidden_Text : ex == 'Invalid' ? String.valueOf(baInfoMap.get('ExpiryDate')) : NumberHelper.DateFormat(exDate);
            return baInfo;
        }catch(Exception e){
            return baInfo;
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

    @AuraEnabled
    public static string getWatermark() {
        return RTL_ProductHoldingsLightningUtil.getWatermarkHTML();
    }

    @AuraEnabled
    public static string getMakeValue(String functionName, String value) {
        return RTL_ProductHoldingsLightningUtil.MakeValue(functionName, value);
    }

    public static String genDateFormat(String dateStr){
        try{
            List<String> dateArr = dateStr.split('\\+');
            List<String> ymd = (dateArr.get(0)).split('-');
            String propperDate;
            propperDate = ymd.get(2) + '/' + ymd.get(1) + '/' + ymd.get(0);
            return propperDate;
        }catch(Exception e){
            return 'Invalid';
        }
    }
}