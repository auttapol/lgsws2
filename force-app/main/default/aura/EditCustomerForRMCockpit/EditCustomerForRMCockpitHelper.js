({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set("v.showSpinnerLoading", true);
    },
    stopSpinner: function (component) {
        component.set("v.showSpinnerLoading", false);
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMessage: function (component, isError, message, detail) {
        component.set('v.isError', isError);
        component.set('v.errorDetail', detail ? detail : '');
        component.set('v.errorMessage', message);
    },
    doWorkspaceAPI: function (component) {
        var tabName = `Edit ${component.get('v.account.Name')}`;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:account",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    closeTab: function (component) {
        if (component.get('v.theme') == 'Theme4u') {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.openTab({
                        recordId: component.get('v.recordId'),
                        focus: true
                    }).then((res) => {
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(err => {
                        console.log(err);
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        } else {
            var navService = component.find('navService');
            navService.navigate({
                type: 'standard__recordPage',
                attributes: {
                    recordId: component.get('v.recordId'),
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            }, false);
        }
    },
    getDescribeFieldResult: function (component, event, helper) {
        var action = component.get('c.getDescribeFieldResultAndValue');
        //var action = component.get('c.testByNobnab');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": [...new Set(Object.keys(component.get('v.fields')).reduce((l, i) => {
                l = l.concat(component.get(`v.fields.${i}`));
                return l;
            }, []))]
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var objectInfoField = response.getReturnValue();
                Object.keys(component.get('v.fields')).forEach(section => {
                    helper.getVerifyFieldSecurity(component, objectInfoField, section);
                });
            } else {
                var errors = response.getError();
                errors.forEach(error => {
                    console.log(error.message);
                    helper.displayToast('error', error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    getVerifyFieldSecurity: function (component, fields, section) {
        var helper = this;
        var action = component.get('c.verifyFieldSecurity');
      
        action.setParams({
            "section": component.get(`v.dataPartition.${section}.sectionName`),
            "userProfile": component.get('v.profileName'),
            "accountId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();            
                //component.set(`v.dataPartition.${section}.isRerender`, true);       
                component.set(`v.dataPartition.${section}.isRerender`, result);
                component.set(`v.isSubmit`, component.get(`v.isSubmit`) || result);
                //component.set(`v.isSubmit`, result);

                helper.callbackRunVerify(component, fields, section);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });

        if (section)
        $A.enqueueAction(action);
    },
    callbackRunVerify: function (component, fields, section) {
        var helper = this;
        var fieldsPartition = [];
        component.get(`v.fields.${section}`).forEach((fieldName, index) => {          
            var field = fields[fieldName];
     
            fieldsPartition.push({
                name: fieldName,
                label: field.label,
                value: component.get('v.hiddenText'),
            });
        });
   
        component.set(`v.fieldsPartition.${section}`, fieldsPartition);

        helper.stopSpinner(component);
    },
    getInitialData: function (component, event, helper) {
        var action = component.get('c.getInitialDataController');
        action.setParams({
            "userId": component.get('v.userId'),
            "accId": component.get('v.recordId')
        });
        // action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result: '+JSON.stringify(result));
                if(result.success){
                    component.set('v.profileName', result.profileName);

                    component.set('v.incomeCatOption', result.incomeCategory);
                    component.set('v.incomeAmountOption', result.incomeAmount);

                    component.set('v.expenseCatOption', result.expenseCategory );
                    component.set('v.expenseAmountOption', result.expenseAmount);

                    component.set('v.frequencyOption', result.frequency);
                    component.set('v.account', result.account);

                    this.doWorkspaceAPI(component);
                }else{
                    this.displayToast('error', 'Error: '+result.message);
                }
                
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },

    getIncomeExpense: function (component, event, helper){
        var action = component.get('c.getIncomeExpense');
        action.setParams({
            "accId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.success){
                    if(result.income){
                        var rawIncome = result.income;
                        var cleanIncome = [];
                        rawIncome.forEach(element => {
                            element.Income_Category__Label = element.Income_Category__c;
                            element.Frequency__Label = element.Frequency__c;
                            element.Income_Amount__Label = element.Income_Amount__c;
                            cleanIncome.push(element);
                        });
                        component.set('v.IncomeData', cleanIncome);
                    }

                    if(result.expense){
                        var rawExpense = result.expense;
                        var cleanExpense = [];
                        rawExpense.forEach(element => {
                            element.Expense_Category__Label = element.Expense_Category__c;
                            element.Frequency__Label = element.Frequency__c;
                            element.Expense_Amount__Label = element.Expense_Amount__c;
                            cleanExpense.push(element);
                        });
                        component.set('v.ExpenseData', cleanExpense);
                    }
                    
                }else{
                    this.displayToast('error', 'Error: '+result.message);
                }
              
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));

                this.displayToast('error', 'Error: '+JSON.stringify(errors));
            }
            this.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },
    deleteRow: function(component, event, type){
        console.log('deleteRow');
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'deleteRow':
                this.deleteRowHelper(component, row, type);
                break;
          
            default:               
                break;
        }
    },
    deleteRowHelper: function(component, row, type){
        console.log('deleteRowHelper');

        var dataToDelete;
        if(type == 'income'){
            dataToDelete = component.get('v.IncomeData');
        }else if(type == 'expense'){
            dataToDelete = component.get('v.ExpenseData');
        }

        var indexToDelete;
        dataToDelete.forEach((element, index) => {
            if(element.Id == row.Id){
                indexToDelete = index; 
            }
        });

        if( indexToDelete > -1){
            dataToDelete.splice(indexToDelete, 1);
        }

        if(type == 'income'){
            component.set('v.IncomeData', dataToDelete);
        }else if(type == 'expense'){
            component.set('v.ExpenseData', dataToDelete);
        }
    },
    submitData: function(component, eventFields){
        eventFields.Id = component.get('v.recordId');
        console.log('submitData: '+JSON.stringify(eventFields));
        var action = component.get('c.submitEditAccount');
        action.setParams({
            "acc": eventFields,
            "income": component.get('v.IncomeData'),
            "expense": component.get('v.ExpenseData')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.success){
                    //ต้องมีตรงนี้ไม่งั้น text ไม่ปัปเดต
                    this.closeTab(component);
                    var appEvent = $A.get("e.c:RetailCSV_Event");
                    appEvent.setParams({
                        isRefresh: true,
                        recordId: component.get(`v.recordId`),
                        fieldUpdate: eventFields
                    });
                    appEvent.fire(); 

                    this.displayToast('success', 'Your data has beed recorded. Please refresh page to see latest data.');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId')
                  
                    });
                    navEvt.fire();

                }else{
                    this.displayToast('error', 'Error: '+result.message);
                }
              
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));

                this.displayToast('error', 'Error: '+JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
    }

    
})