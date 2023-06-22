public class OtherBankTriggerHandler {
    public static void onDelete(List<Other_Bank__c> triggerNew){
        Set<String> accountSet = new Set<String>();
        for(Other_Bank__c ob: triggerNew){
			accountSet.add(ob.Customer__c);            
        }
        
        List<Account> accList = [SELECT Id, Name, RTL_Wealth_RM__c FROM Account WHERE Id IN :accountSet];
        Map<String , Account> accMap = new Map<String, Account>();
        
        for(Account acc: accList){
            accMap.put(acc.Id, acc);
        }
        
        for(Other_Bank__c ob: triggerNew){
            if(accMap.containsKey(ob.Customer__c)){
                Account acc = accMap.get(ob.Customer__c);
                if(acc.RTL_Wealth_RM__c != userinfo.getUserId()){
                    ob.addError('Only RM of the customer may delete record.');
                }
            }
        }
    }
}