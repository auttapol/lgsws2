public with sharing class EditCustomerController {
   

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields, List<String> fields_translate){        
        return RetailCSVLightningUtil.getDescribeFieldResultAndValue(recordId, fields, fields_translate);
    }

    @AuraEnabled(cacheable=true)
    public static Object verifyFieldSecurity(String section, String userProfile, String accountId){
        return RTL_AccountUtility.verifyFieldSecurity(section, userProfile, accountId);
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getInitialDataController(Id userId, String accId){
        Map<String, Object> response = new Map<String, Object>();
        try{
            Object profileName = RetailCSVLightningUtil.getProfileName(userId);
            response.put('profileName', profileName);

            response.put('expenseAmount',   getPickListValuesIntoList('Income_Expense__c', 'Expense_Amount__c'));
            response.put('expenseCategory', getPickListValuesIntoList('Income_Expense__c', 'Expense_Category__c'));
            response.put('incomeAmount',    getPickListValuesIntoList('Income_Expense__c', 'Income_Amount__c'));
            response.put('incomeCategory',  getPickListValuesIntoList('Income_Expense__c', 'Income_Category__c'));
            response.put('frequency',       getPickListValuesIntoList('Income_Expense__c', 'Frequency__c'));
            
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :accId];
            if(accList != null && accList.size() > 0){
                response.put('account', accList[0]);
            }
            response.put('success', true);
        }catch(Exception ex){
            response.put('success', false);
            response.put('message', ex.getMessage());
        }

        return response;
        // return [SELECT Id, Name, Profile.Name FROM User WHERE Id = :userId].Profile.Name;
    }

    private static List<Map<String, String>> getPickListValuesIntoList(String objectName, String field){ 
     
        // Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(field).getDescribe().getPickListValues();

        List<Map<String, String>> picklist = new List<Map<String, String>>();
        Map<String, String> defaultValue = new Map<String, String>();
        defaultValue.put('label', '-- None --');
        defaultValue.put('value', '');

        picklist.add(defaultValue);
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Map<String, String> picklistMap = new Map<String, String>();
            picklistMap.put('label',objPickList.getLabel());
            picklistMap.put('value',objPickList.getValue());

            picklist.add(picklistMap);
            // System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
        }
        return picklist;
     }

    @AuraEnabled
    public static Map<String, Object> getIncomeExpense(String accId){
        Map<String, Object> response = new Map<String, Object>();
        try {            
            // List<Income_Expense__c> allIE = null;
            List<Income_Expense__c> allIE = [SELECT Id, Name, tolabel(Expense_Amount__c), tolabel(Expense_Category__c) , 
                                        tolabel(Income_Amount__c),tolabel(Income_Category__c),
                                        tolabel(Frequency__c), Remark__c, RecordType.DeveloperName 
                                        FROM Income_Expense__c WHERE Customer__c = :accId];
            List<Income_Expense__c> incomeList = new List<Income_Expense__c>();
            List<Income_Expense__c> expenseList = new List<Income_Expense__c>();

            for(Income_Expense__c ie: allIE){
                if(ie.RecordType.DeveloperName == 'Income'){
                    incomeList.add(ie);
                }else if(ie.RecordType.DeveloperName == 'Expense'){
                    expenseList.add(ie);
                }
            }

            response.put('income', incomeList);
            response.put('expense', expenseList);
            response.put('success', true);

        } catch (Exception e) {
            response.put('error', e.getMessage());
            response.put('success', false);
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> submitEditAccount(Account acc, List<Income_Expense__c> income, List<Income_Expense__c> expense){
        Map<String, Object> response = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Update acc;

            List<Income_Expense__c> allIE = [SELECT Id, Name, RecordType.Name 
                                FROM Income_Expense__c WHERE Customer__c = :acc.Id];

            List<Income_Expense__c> currentExpense = new List<Income_Expense__c>();
            List<Income_Expense__c> currentIncome = new List<Income_Expense__c>();

            for(Income_Expense__c ie: allIE){
                if(ie.recordType.Name == 'Income'){
                    currentIncome.add(ie);
                }else if(ie.recordType.Name == 'Expense'){
                    currentExpense.add(ie);
                }
            }

            IncomeExpenseOperation(currentIncome, income, acc, Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Income').getRecordTypeId());
            IncomeExpenseOperation(currentExpense, expense, acc, Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Expense').getRecordTypeId());
            response.put('success', true);
        } catch(DmlException e){
            Database.rollback(sp);
            response.put('success', false);
            response.put('message', e.getDmlMessage(0)+' '+e.getLineNumber());
        }catch (Exception e) {
            Database.rollback(sp);
            response.put('success', false);
            response.put('message', e.getMessage()+ ' '+e.getLineNumber());
        }
        return response;
    }

    private static void IncomeExpenseOperation(List<Income_Expense__c> oldData, List<Income_Expense__c> newData, Account acc, String recTypeId){
        Set<String> oldDataId = new Set<String>();
        for(Income_Expense__c ie: oldData){
            oldDataId.add(ie.Id+'');
        }

        List<Income_Expense__c> toInsert = new  List<Income_Expense__c>();
        Set<String> newDataId = new Set<String>();
        for(Income_Expense__c ie: newData){
            newDataId.add(ie.Id+'');
            String dataId = ie.Id+'';
            //Random id generate from frontend -- Data meant tobe insert
            if(dataId.length() <10){
                ie.Id = null;
                ie.customer__c = acc.Id;
                ie.recordTypeId = recTypeId;
                toInsert.add(ie);
            }
        }

        List<Income_Expense__c> toDelete = new List<Income_Expense__c>();
        for(String old: oldDataId){
            //Not existed from frontend -- Delete record
            if(!newDataId.contains(old)){
                Income_Expense__c ie = new Income_Expense__c();
                ie.Id = old;
                toDelete.add(ie);
            }
        }

        if(toDelete != null && toDelete.size() > 0){
            DELETE toDelete;
        }

        if(toInsert!= null && toInsert.size() > 0){
            INSERT toInsert;
        }
    }
    @AuraEnabled(cacheable=false)
    public static Object getDataAfterRefresh(String recordId, List<String> fields, List<String> fields_translate) {
        String queryString = 'SELECT ' + String.join(fields, ',') + ' FROM Account WHERE Id = :recordId LIMIT 1';
        for (string fieldTranslate : fields_translate) {
            queryString = queryString.replace( fieldTranslate, 'toLabel('+fieldTranslate+')');
        }
        Account AccountObj = Database.query(queryString);
        Map<String, Schema.SObjectField> sObjectField = Schema.SObjectType.Account.fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            if(!f.contains('__r')) {
                Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => dfr.getName(),
                    'value' => AccountObj.get(dfr.getName()) != null ? AccountObj.get(dfr.getName()) : '',
                    'label' => dfr.getLabel(),
                    'type' => dfr.getType(),
                    'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                    'isAccessible' => dfr.isAccessible()
                });
            }
            else {
                Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(AccountObj));
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => f,
                    'value' => AccountObj.get(f.substringBefore('.').replace('__r', '__c')) != null ? ((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : null
                });
            }
        }
        return JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }
}