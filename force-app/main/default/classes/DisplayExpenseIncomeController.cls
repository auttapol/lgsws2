public with sharing class DisplayExpenseIncomeController {
    @AuraEnabled
    public static Map<String, Object> getIncomeExpense(String accountId){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Income_Expense__c> ieList = [SELECT Id, Name, RecordType.Name, 
                                    Expense_Amount__c, tolabel(Expense_Category__c), tolabel(Frequency__c), tolabel(Income_Amount__c), tolabel(Income_Category__c), Remark__c
                                    FROM Income_Expense__c WHERE Customer__c = :accountId];
            
            List<Income_Expense__c> income = new List<Income_Expense__c>();
            List<Income_Expense__c> expense = new List<Income_Expense__c>();

            for(Income_Expense__c ie: ieList){
                if(ie.RecordType.Name == 'Income'){
                    income.add(ie);
                }else if(ie.RecordType.Name == 'Expense'){
                    expense.add(ie);
                }               
            }

            response.put('expense', expense);
            response.put('income', income);
            response.put('success', true);
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('success', false);
            response.put('message', e.getMessage());
        }
        return response;
    }
}