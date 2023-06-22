public class InvestmentAcountDetailController {

    public class InvestmentDetailWrapper{
        @AuraEnabled public String UnitHolderNo{ get; set; }
        @AuraEnabled public String FundCode{ get; set; }
        @AuraEnabled public String ProductName{ get; set; }
        @AuraEnabled public String SubProductGroup{ get; set; }
        @AuraEnabled public String AssetClass{ get; set; }
        @AuraEnabled public String SeqGrp{ get; set; }
        @AuraEnabled public String IssuerFundHouse{ get; set; }
    }

    public class InvestmentInfoWrapper{
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String Message{ get; set; }
        @AuraEnabled public String NumberOfUnit{ get; set; }
        @AuraEnabled public String CostOfInvestment{ get; set; }
        @AuraEnabled public String MarketValue{ get; set; }
        @AuraEnabled public String UnrealizedGL{ get; set; }
        @AuraEnabled public String NAVUnit{ get; set; }
        @AuraEnabled public String AipInstruction{ get; set; }
        @AuraEnabled public String AverageCostPerUnit{ get; set; }
        @AuraEnabled public String UnrealizedGLPerc{ get; set; }
    }

    public class AutoInvestmentPlanCover{
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String Message{ get; set; }
        @AuraEnabled public List<AutoInvestmentPlanWrapper> AutoInvestmentPlan{ get; set; }
    }

    public class AutoInvestmentPlanWrapper{
        @AuraEnabled public String SinceDate{ get; set; }
        @AuraEnabled public String CreatedChannel{ get; set; }
        @AuraEnabled public String Frequency{ get; set; }
        @AuraEnabled public String TempDate{ get; set; }
        @AuraEnabled public String Balance{ get; set; }
        @AuraEnabled public String SavingAccountBundling{ get; set; }
    }

    public class InvestmentTransactionCover{
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String Message{ get; set; }
        @AuraEnabled public List<InvestmentTransactionWrapper> InvestmentTransaction{ get; set; }
    }
    
    public class InvestmentTransactionWrapper{
        @AuraEnabled public String TransactionType{ get; set; }
        @AuraEnabled public String SettlementDate{ get; set; }
        @AuraEnabled public String InteractChannel{ get; set; }
        @AuraEnabled public String UnitMovement{ get; set; }
        @AuraEnabled public String TransactionValue{ get; set; }
        @AuraEnabled public String ValuePerUnit{ get; set; }
        @AuraEnabled public String Statue{ get; set; }
    }

    private static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Employee_ID__c, Profile.Name, UserRole.Name FROM User WHERE Id = :userInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }
    
    @AuraEnabled
    public static Object getInvestmentDetailProduct(String unitHolderNo, String fundCode, String recordId, String tmbCustId){
        Object result = RTL_ProductHoldingWebSvcUtils.calloutOSC06Detail(unitHolderNo, fundCode, tmbCustId);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result));
        Map<String, Object> statusOutSide = (Map<String, Object>)jsonMap.get('Status');
        if(String.valueOf(statusOutSide.get('StatusCode')) != '200'){
            jsonMap.remove('GetInvestmentAccountDetailResponse');
            jsonMap.remove('InvestmentDetail');
            jsonMap.remove('product');
            return (Object) jsonMap;
        }
        try{
            Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Details of Investment Product');
            Map<String, Object> returnMap = new Map<String, Object>(jsonMap);
            Map<String, Object> layer1 = (Map<String, Object>)jsonMap.get('GetInvestmentAccountDetailResponse');
            Map<String, Object> layer2 = (Map<String, Object>)layer1.get('Result');
            layer2.put('InvestmentInformation', parseInvestInfo(jsonMap, fieldVisible));
            layer2.put('InvestmentTransaction', parseInvestTran(jsonMap, fieldVisible));
            layer2.put('AutoInvestmentPlan', parseAutoInvest(jsonMap, fieldVisible));
    
            layer1.put('Result', (Object) layer2);
            returnMap.put('Authorize', (Object) fieldVisible.get('Authorize'));
            returnMap.put('GetInvestmentAccountDetailResponse', layer1);
            returnMap.put('InvestmentDetail', parseInvestDetail(jsonMap, fieldVisible));
            returnMap.remove('product');
            
            return (Object) returnMap;
        }catch(Exception e){
            return (Object) jsonMap;
        }
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        return currentUser.Employee_ID__c;
    }

    private static InvestmentInfoWrapper parseInvestInfo(Map<String, Object> jsonMap, Map<String, Boolean> fieldVisible){
        try{
            Map<String, Object> layer1 = (Map<String, Object>)jsonMap.get('GetInvestmentAccountDetailResponse');
            Map<String, Object> layer2 = (Map<String, Object>)layer1.get('Result');
            Map<String, Object> investInfoMap = (Map<String, Object>)layer2.get('InvestmentInformation');
            InvestmentInfoWrapper wrapper = new InvestmentInfoWrapper();
            wrapper.Status = (String) investInfoMap.get('Status');
            wrapper.Message = (String) investInfoMap.get('Message');
            wrapper.NumberOfUnit = fieldVisible.get('Investment_Detail_NumberOfUnit') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('NumberOfUnit');
            wrapper.CostOfInvestment = fieldVisible.get('Investment_Detail_CostOfInvestment') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('CostOfInvestment');
            wrapper.MarketValue = fieldVisible.get('Investment_Detail_MarketValue') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('MarketValue');
            wrapper.UnrealizedGL = fieldVisible.get('Investment_Detail_UnrealizedGL') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('UnrealizedGL');
            wrapper.NAVUnit = fieldVisible.get('Investment_Detail_NAVUnit') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('NAVUnit');
            wrapper.AipInstruction = fieldVisible.get('Investment_Detail_AipInstruction') == false ? Label.Data_Condition_Hidden_Text : (String) investInfoMap.get('AipInstruction');
            wrapper.AverageCostPerUnit = (fieldVisible.get('Investment_Detail_NumberOfUnit') == false || fieldVisible.get('Investment_Detail_CostOfInvestment') == false ) ? Label.Data_Condition_Hidden_Text : calculateAverageCostPerUnit(investInfoMap.get('NumberOfUnit'), investInfoMap.get('CostOfInvestment'));
            wrapper.UnrealizedGLPerc = (fieldVisible.get('Investment_Detail_NumberOfUnit') && fieldVisible.get('Investment_Detail_CostOfInvestment') && fieldVisible.get('Investment_Detail_UnrealizedGL')) ? calculateUnrealizedGLPerc(investInfoMap.get('NumberOfUnit'), investInfoMap.get('CostOfInvestment'), investInfoMap.get('UnrealizedGL')) : Label.Data_Condition_Hidden_Text;
            return wrapper;
        }catch(Exception e){
            return new InvestmentInfoWrapper();
        }
    }

    public static String calculateAverageCostPerUnit(Object NumberOfUnit, Object CostOfInvestment){
        try{
            Decimal n = Decimal.valueOf((String) NumberOfUnit);
            Decimal c = Decimal.valueOf( (String) CostOfInvestment);
            Decimal avgCost = n != 0 ? c / n : 0;
            avgCost = avgCost.setScale(4);
            return String.valueOf(avgCost);
        }catch(Exception e){
            return '';
        }
    }

    public static String calculateUnrealizedGLPerc(Object NumberOfUnit, Object CostOfInvestment, Object UnrealizedGL){
        try{
            Decimal n = Decimal.valueOf( (String) NumberOfUnit);
            Decimal c = Decimal.valueOf( (String) CostOfInvestment);
            Decimal u = Decimal.valueOf( (String) UnrealizedGL); 
            Decimal gl = n != 0 ? (u / c) * 100 : 0;
            gl = gl.setScale(2);
            return String.valueOf(gl);
        }catch(Exception e){
            return '';
        }
    }

    private static InvestmentTransactionCover parseInvestTran(Map<String, Object> jsonMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer1 = (Map<String, Object>)jsonMap.get('GetInvestmentAccountDetailResponse');
        Map<String, Object> layer2 = (Map<String, Object>)layer1.get('Result');
        Map<String, Object> invsetCoverMap = (Map<String, Object>)layer2.get('InvestmentTransaction');
        InvestmentTransactionCover cover = new InvestmentTransactionCover();
        cover.Status = (String) invsetCoverMap.get('Status');
        cover.Message = (String) invsetCoverMap.get('Message');
        try{
            Object o = invsetCoverMap.get('InvestmentTransaction');
            if(o instanceof List<Object>){
                List<Object> objList = (List<Object>) invsetCoverMap.get('InvestmentTransaction');
                List<InvestmentTransactionWrapper> wrapperList = new List<InvestmentTransactionWrapper>();
                for(Object i : objList){
                    InvestmentTransactionWrapper wrapper = new InvestmentTransactionWrapper();
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    String genSettlementDate = genDateFormat(String.valueOf(each.get('SettlementDate')));
                    Date settlementDate = date.parse(genSettlementDate);
                    wrapper.SettlementDate = fieldVisible.get('Investment_Detail_SettlementDate') == false ? Label.Data_Condition_Hidden_Text : genSettlementDate == 'Invalid' ? String.valueOf(each.get('SettlementDate')) : NumberHelper.DateFormat(settlementDate);
                    wrapper.TransactionType = fieldVisible.get('Investment_Detail_TransactionType') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('TransactionType');
                    wrapper.InteractChannel = fieldVisible.get('Investment_Detail_InteractChannel') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('InteractChannel');
                    wrapper.UnitMovement = fieldVisible.get('Investment_Detail_UnitMovement') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(each.get('UnitMovement'))));
                    wrapper.TransactionValue = fieldVisible.get('Investment_Detail_TransactionValue') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(each.get('TransactionValue'))));
                    wrapper.ValuePerUnit = fieldVisible.get('Investment_Detail_ValuePerUnit') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('ValuePerUnit');
                    wrapper.Statue = fieldVisible.get('Investment_Detail_Statue') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Statue');
                    wrapperList.add(wrapper);
                }
                cover.InvestmentTransaction = wrapperList;
                return cover;
            }
            else{
                List<InvestmentTransactionWrapper> wrapperList = new List<InvestmentTransactionWrapper>();
                Map<String, Object> obj = (Map<String, Object>) invsetCoverMap.get('InvestmentTransaction');
                InvestmentTransactionWrapper wrapper = new InvestmentTransactionWrapper();
                String genSettlementDate = genDateFormat(String.valueOf(obj.get('SettlementDate')));
                Date settlementDate = date.parse(genSettlementDate);
                wrapper.SettlementDate = fieldVisible.get('Investment_Detail_SettlementDate') == false ? Label.Data_Condition_Hidden_Text : genSettlementDate == 'Invalid' ? String.valueOf(obj.get('SettlementDate')) : NumberHelper.DateFormat(settlementDate);
                wrapper.TransactionType = fieldVisible.get('Investment_Detail_TransactionType') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('TransactionType');
                wrapper.InteractChannel = fieldVisible.get('Investment_Detail_InteractChannel') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('InteractChannel');
                wrapper.UnitMovement = fieldVisible.get('Investment_Detail_UnitMovement') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(obj.get('UnitMovement'))));
                wrapper.TransactionValue = fieldVisible.get('Investment_Detail_TransactionValue') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(obj.get('TransactionValue'))));
                wrapper.ValuePerUnit =  fieldVisible.get('Investment_Detail_ValuePerUnit') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('ValuePerUnit');
                wrapper.Statue = fieldVisible.get('Investment_Detail_Statue') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('Statue');
                wrapperList.add(wrapper);
                cover.InvestmentTransaction = wrapperList;
                return cover;
            }
        }catch(Exception e){
            return cover;
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

    private static AutoInvestmentPlanCover parseAutoInvest(Map<String, Object> jsonMap, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer1 = (Map<String, Object>)jsonMap.get('GetInvestmentAccountDetailResponse');
        Map<String, Object> layer2 = (Map<String, Object>)layer1.get('Result');
        Map<String, Object> autoCoverMap = (Map<String, Object>)layer2.get('AutoInvestmentPlan');
        AutoInvestmentPlanCover cover = new AutoInvestmentPlanCover();
        cover.Status = (String) autoCoverMap.get('Status');
        cover.Message = (String) autoCoverMap.get('Message');
        try{
            Object o = autoCoverMap.get('AutoInvestmentPlan');
            if(o instanceof List<Object>){
                List<Object> objList = (List<Object>) autoCoverMap.get('AutoInvestmentPlan');
                List<AutoInvestmentPlanWrapper> wrapperList = new List<AutoInvestmentPlanWrapper>();
                for(Object i : objList){
                    AutoInvestmentPlanWrapper wrapper = new AutoInvestmentPlanWrapper();
                    Map<String, Object> each = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(i));
                    String genSinceDate = genDateFormat(String.valueOf(each.get('SinceDate')));
                    Date sinceDate = date.parse(genSinceDate);
                    wrapper.TempDate = fieldVisible.get('Investment_Detail_Date') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(each.get('Date'));
                    wrapper.SinceDate = fieldVisible.get('Investment_Detail_SinceDate') == false ? Label.Data_Condition_Hidden_Text : NumberHelper.DateFormat(sinceDate);
                    wrapper.CreatedChannel = fieldVisible.get('Investment_Detail_CreatedChannel') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('CreatedChannel');
                    wrapper.Frequency = fieldVisible.get('Investment_Detail_Frequency') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('Frequency');
                    wrapper.Balance = fieldVisible.get('Investment_Detail_Balance') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(each.get('Balance'))));
                    wrapper.SavingAccountBundling = fieldVisible.get('Investment_Detail_SavingAccountBundling') == false ? Label.Data_Condition_Hidden_Text : (String) each.get('SavingAccountBundling');
                    wrapperList.add(wrapper);
                }
                cover.AutoInvestmentPlan = wrapperList;
                return cover;
            }
            else{
                List<AutoInvestmentPlanWrapper> wrapperList = new List<AutoInvestmentPlanWrapper>();
                Map<String, Object> obj = (Map<String, Object>) autoCoverMap.get('AutoInvestmentPlan');
                AutoInvestmentPlanWrapper wrapper = new AutoInvestmentPlanWrapper();
                String genSinceDate = genDateFormat(String.valueOf(obj.get('SinceDate')));
                Date sinceDate = date.parse(genSinceDate);
                wrapper.TempDate = fieldVisible.get('Investment_Detail_Date') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(obj.get('Date'));
                wrapper.SinceDate = fieldVisible.get('Investment_Detail_SinceDate') == false ? Label.Data_Condition_Hidden_Text : NumberHelper.DateFormat(sinceDate);
                wrapper.CreatedChannel = fieldVisible.get('Investment_Detail_CreatedChannel') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('CreatedChannel');
                wrapper.Frequency =  fieldVisible.get('Investment_Detail_Frequency') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('Frequency');
                wrapper.Balance = fieldVisible.get('Investment_Detail_Balance') == false ? Label.Data_Condition_Hidden_Text : getCents(Decimal.valueOf(String.valueOf(obj.get('Balance'))));
                wrapper.SavingAccountBundling = fieldVisible.get('Investment_Detail_SavingAccountBundling') == false ? Label.Data_Condition_Hidden_Text : (String) obj.get('SavingAccountBundling');
                wrapperList.add(wrapper);
                cover.AutoInvestmentPlan = wrapperList;
                return cover;
            }
        }catch(Exception e){
            return cover;
        }
    }

    private static InvestmentDetailWrapper parseInvestDetail(Map<String, Object> jsonMap, Map<String, Boolean> fieldVisible){
        try{
            Map<String, Object> investDetailMap = (Map<String, Object>)jsonMap.get('InvestmentDetail');
            InvestmentDetailWrapper wrapper = new InvestmentDetailWrapper();
            wrapper.UnitHolderNo = fieldVisible.get('Investment_Detail_UnitHolderNo') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('UnitHolderNo');
            wrapper.FundCode = fieldVisible.get('Investment_Detail_FundCode') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('FundCode');
            wrapper.ProductName = fieldVisible.get('Investment_Detail_ProductName') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('ProductName');
            wrapper.SubProductGroup = fieldVisible.get('Investment_Detail_SubProductGroup') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('SubProductGroup');
            wrapper.AssetClass = fieldVisible.get('Investment_Detail_AssetClass') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('AssetClass');
            wrapper.SeqGrp = fieldVisible.get('Investment_Detail_SeqGrp') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('SeqGrp');
            wrapper.IssuerFundHouse = fieldVisible.get('Investment_Detail_IssuerFundHouse') == false ? Label.Data_Condition_Hidden_Text : (String) investDetailMap.get('IssuerFundHouse');
            return wrapper;
        }catch(Exception e){
            return new InvestmentDetailWrapper();
        }
    }

    public static String genDateFormat(String dateStr){
        try{
            List<String> dateArr = dateStr.split('\\+');
            List<String> ymd = (dateArr.get(0)).split('-');
            String propperDate = ymd.get(2) + '/' + ymd.get(1) + '/' + ymd.get(0);
            return propperDate;
        }catch(Exception e){
            return 'Invalid';
        }
    }
}