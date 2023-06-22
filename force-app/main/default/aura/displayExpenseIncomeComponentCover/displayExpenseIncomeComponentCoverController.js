({
    handleRefreshfield : function(component, event, helper) {        
        var recordId = event.getParam('recordId');
        var fieldUpdate = event.getParam('fieldUpdate');
        var expenseIncome = component.find('displayExpenseIncomeComponent');

        expenseIncome.refreshPage(fieldUpdate);
    }
})