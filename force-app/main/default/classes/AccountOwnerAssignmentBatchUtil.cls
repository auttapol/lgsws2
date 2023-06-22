public class AccountOwnerAssignmentBatchUtil {

    public static Boolean checkCriteria(Account acct, Owner_Assignment_Rule__c rule){
        Boolean result = false;

        Boolean cond1 = !RTL_Utility.isNotNull(rule.Entry_Criteria_Field_1__c);
        Boolean cond2 = !RTL_Utility.isNotNull(rule.Entry_Criteria_Field_2__c);
        Boolean cond3 = !RTL_Utility.isNotNull(rule.Entry_Criteria_Field_3__c);
        Boolean cond4 = !RTL_Utility.isNotNull(rule.Entry_Criteria_Field_4__c);
        Boolean cond5 = !RTL_Utility.isNotNull(rule.Entry_Criteria_Field_5__c);

        cond1 = checkCondition(rule.Entry_Criteria_Field_1__c, acct, rule.Criteria_Field_Value_1__c);
        // System.debug('cond1 : ' + cond1);
        cond2 = checkCondition(rule.Entry_Criteria_Field_2__c, acct, rule.Criteria_Field_Value_2__c);
        // System.debug('cond2 : ' + cond2);
        cond3 = checkCondition(rule.Entry_Criteria_Field_3__c, acct, rule.Criteria_Field_Value_3__c);
        // System.debug('cond3 : ' + cond3);
        cond4 = checkCondition(rule.Entry_Criteria_Field_4__c, acct, rule.Criteria_Field_Value_4__c);
        // System.debug('cond4 : ' + cond4);
        cond5 = checkCondition(rule.Entry_Criteria_Field_5__c, acct, rule.Criteria_Field_Value_5__c);
        // System.debug('cond5 : ' + cond5);

        if(cond1 && cond2 && cond3 && cond4 && cond5){
            result = true;           
        }

        return result;
    }

    private static Boolean checkCondition(String cond, SObject data, String condValue){
        if(cond == null || cond == ''){
            return true;
        }
        
        // System.debug(cond);
        // System.debug(data.get(cond));
        // System.debug(condValue);
        
        if(String.valueOf(data.get(cond)) == condValue){
        	return true;    
        }
        return false;
    }
}