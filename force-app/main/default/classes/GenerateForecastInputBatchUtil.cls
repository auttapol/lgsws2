public class GenerateForecastInputBatchUtil {
    final static Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }

    public static String getWeekNumber(Date dateVar){
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        Date dt = dateVar.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        
        startWeekResidue = dt.daysBetween(dtFirstWeekend);
        
        Date dtLastWeekend = dateVar.toStartOfWeek().addDays(-1);

        endWeekResidue = dtLastWeekend.daysBetween(dateVar);
        weekCount = (dateVar.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);

        return String.valueOf(weekCount);
    }

    public static Monthly_Forecast_Input__c genNewMFI(Product_Volume_Information__c PVImapScope, Date genDate){
        Monthly_Forecast_Input__c MFI = new Monthly_Forecast_Input__c();

        MFI.RecordTypeId = RTExistingRepay;
        MFI.Customer__c = PVImapScope.Customer__c;
        MFI.Product__c = PVImapScope.Product__c;
        MFI.Year__c = String.valueOf(genDate.year());
        MFI.Month__c = genDate.month() < 10 ? '0' + String.valueOf(genDate.month()) : String.valueOf(genDate.month());
        MFI.adjustMonthYear__c = Date.newInstance(genDate.year(),genDate.month(),1);
        MFI.Account_Suffix_Ref__c = PVImapScope.Account_Suffix_Ref__c;
        MFI.TMB_Account_ID__c = PVImapScope.TMB_Account_ID__c;
        MFI.TMB_Ref__c = PVImapScope.TMB_Ref__c;
        MFI.TMB_Suffix__c = PVImapScope.TMB_Suffix__c;
        MFI.YearMonthAcctSuffRef__c = MFI.Year__c + MFI.Month__c + MFI.Account_Suffix_Ref__c;
        MFI.Issue_Date__c = PVImapScope.Issue_Date__c;
        MFI.RPN_Type__c = PVImapScope.RPN_Type__c;
        MFI.Product_Group__c = PVImapScope.Product_Group__c;
        MFI.Interest_Revenue__c = PVImapScope.Interest_Revenue__c;
        MFI.Product_Code__c = PVImapScope.Product_Code__c;

        MFI.isSkipUpdateCUBE__c = true;

        String combkey = MFI.Year__c + MFI.Month__c + PVImapScope.Product__r.Financial_Product_Domain__c + PVImapScope.Product__r.Remark__c + PVImapScope.Customer__r.Segment_crm__c + MFI.Account_Suffix_Ref__c;
        MFI.Name = combkey.replaceAll( '\\s+', '');

        MFI.Product_Type__c = PVImapScope.Product_Type__c;
        MFI.X4G__c = PVImapScope.Current_4G__c;
        MFI.Gross_Rate__c = PVImapScope.Gross_Rate__c;
        MFI.Loan_Status__c = PVImapScope.Loan_Status__c;
        MFI.Origination_Date__c = PVImapScope.Origination_Date__c;
        MFI.Account_Status_Desc__c = PVImapScope.Account_Status_Desc__c;
        MFI.Liability_O_S__c = PVImapScope.Liability_O_S__c;
        MFI.SABS__c = PVImapScope.SABS_Type__c;
        MFI.Unused_Balance__c = PVImapScope.Unused_Balance__c;
        MFI.BRL_Group__c = PVImapScope.Business_Readiness_Level_BRL__c;

        MFI.Limit__c = PVImapScope.Limit_Loan__c;
        MFI.Maturity_Date__c = PVImapScope.Maturity_Date__c;

        if(PVImapScope.Product__r?.Remark__c != 'LT Loan' &&  PVImapScope.Maturity_Date__c != null && genDate.year() == PVImapScope.Maturity_Date__c.year() && genDate.month() == PVImapScope.Maturity_Date__c.month()) {
            String weekNo = getWeekNumber(PVImapScope.Maturity_Date__c);
            Decimal repay = 0;

            if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Deposit'){
                if(PVImapScope.Ending_Balance_Deposit__c != null && PVImapScope.Ending_Balance_Deposit__c != 0){
                    repay = PVImapScope.Ending_Balance_Deposit__c;
                }else if(PVImapScope.Ending_Balance_BE__c != null && PVImapScope.Ending_Balance_BE__c != 0){
                    repay = PVImapScope.Ending_Balance_BE__c;
                }
            }else if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Credit'){
                if(PVImapScope.Ending_Balance_Loan__c != null && PVImapScope.Ending_Balance_Loan__c != 0){
                    repay = PVImapScope.Ending_Balance_Loan__c;
                }
            }

            MFI.put('Repay_Due_Amount_Week' + weekNo + '__c', repay);
        }

        if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Deposit'){
            if(PVImapScope.Ending_Balance_Deposit__c != null && PVImapScope.Ending_Balance_Deposit__c != 0){
                MFI.Current_Ending_Balance__c = PVImapScope.Ending_Balance_Deposit__c;
            }else if(PVImapScope.Ending_Balance_BE__c != null && PVImapScope.Ending_Balance_BE__c != 0){
                MFI.Current_Ending_Balance__c = PVImapScope.Ending_Balance_BE__c;
            }else{
                MFI.Current_Ending_Balance__c = 0;
            }
        }else if(PVImapScope.Product__r?.Financial_Product_Domain__c == 'Credit'){
            MFI.Current_Ending_Balance__c = PVImapScope?.Ending_Balance_Loan__c;
        }

        return MFI;
    }
}