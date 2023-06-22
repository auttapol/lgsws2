({

    onInit: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__recordId;
        console.log('id: '+id);
        component.set("v.recordId", id);

        component.set('v.fields', {
            'SpecialPrefAndRelationshipLevel': [
               'RTL_Special_Pref__c',
               'RTL_Other2__c',
               'RMC_Relationship_Level__c'
            ],
            'Sales_Support_Information': [
                'FATCA_Form_Completed__c',
                // 'KYC_CCI1_Completed__c',
                // 'RTL_Lifetime_Code__c',
                'RTL_Assigned_BRC__c',
                'RTL_OnSite_Service__c',
                // 'RMC_Relationship_Level__c'
            ],
            'Occupation': [
                'RMC_Occupation__c',
                // 'RTL_Special_Pref__c',
                // 'RTL_Other2__c',
                // 'RMC_Additional_Information__c'
            ],
            'Personalized_Information': [
                'Hobbies__c',
                'Favorite_Sport__c',
                'RTL_Lifestyle__c',
                'RTL_Preferred_Activity__c',
                'Favorite_Place_Travel__c',
                'Favorite_Music__c',
                'Favorite_Food__c',
                'RTL_Other1__c',
               
                // 'RTL_Life_Objective_1__c',
                // 'RTL_Life_Objective_2__c',
                // 'RTL_Life_Objective_3__c',
                // 'RTL_Other2__c',
                // 'RTL_Other2__c',
               
            ],
            'Contact_Number_and_Email_Address': [
                'RTL_Preferred_Contact_Channel__c',
                'RTL_Alternative_Contact_Channel__c',
                'RTL_Alternative_Number__c',
                // 'C_Home_phone_PE__c',
                // 'Mobile_Number_PE__c',
                // 'Email_Address_PE__c',
                // 'RTL_Office_Phone_Number__c',
                // 'RTL_Email_2__c',
                // 'Fax',
            ],
            'Alternate_Contact_Information': [
                'RTL_Contact_Person_Name_1__c',
                'RTL_Contact_Person_Name_2__c',
                'RTL_Contact_Person_Number_1__c',
                'RTL_Contact_Person_Number_2__c',
                'RTL_Purpose_for_Contact1__c',
                'RTL_Purpose_of_Contact2__c',
                'RTL_Relationship_Contact_1__c',
                'RTL_Relationship_Contact_2__c'
            ],
            'Visit_and_Event': [
                'RMC_No_of_Management_Visits__c',
                'RMC_No_of_Participating_Events__c',
              
            ],
           
        });

        // if ($A.get("$Browser.isPhone")) {
        //     var aciFields = component.get('v.fields.Alternate_Contact_Information');
        //     // Separate left and right
        //     component.set('v.fields.Alternate_Contact_Information', aciFields.reduce((l, i, index) => {
        //         // right
        //         if (index % 2 == 1) l.push(i);
        //         return l;
        //     }, aciFields.reduce((l, i, index) => {
        //         // left
        //         if (index % 2 == 0) l.push(i);
        //         return l
        //     }, [])));
        // }

        component.set('v.dataPartition', {
            'SpecialPrefAndRelationshipLevel': {
                sectionName: 'RtlCust:Customer Insight - Personalized Information',
                isRerender: false,
            },
            'Sales_Support_Information': {
                sectionName: 'RtlCust:Customer Insight - Personalized Information',
                isRerender: false,
            },
            'Personalized_Information': {
                sectionName: 'RtlCust:Customer Insight - Personalized Information',
                isRerender: false,
            },
            'Contact_Number_and_Email_Address': {
                sectionName: 'RtlCust:Contact Number and Email Address',
                isRerender: false,
            },
            'Alternate_Contact_Information': {
                sectionName: 'RtlCust:Alternative Contact Information',
                isRerender: false
            },
            'Visit_and_Event': {
                sectionName: 'RtlCust:Customer Insight - Personalized Information',
                isRerender: false
            },
            'Occupation': {
                sectionName: 'RtlCust:Customer Insight - Personalized Information',
                isRerender: false
            },
        });

        component.set('v.IncomeColumn', [
            {label: 'หมวดหมู่',      fieldName: 'Income_Category__Label',    type: 'text'},
            {label: 'ความถี่',            fieldName: 'Frequency__Label',          type: 'text'},
            {label: 'ยอดรายรับต่อปี',        fieldName: 'Income_Amount__Label',      type: 'text'},
            {label: 'หมายเหตุ',               fieldName: 'Remark__c',             type: 'text'},
            {label: 'จัดการ', fieldName: '', type: 'button', initialWidth: 130, typeAttributes: { label: 'Delete', name: 'deleteRow', title: 'Delete', iconName: 'utility:delete' },  cellAttributes: { class:  'deleteBtn' }},
        ]);

        component.set('v.ExpenseColumn', [
            {label: 'หมวดหมู่',     fieldName: 'Expense_Category__Label',   type: 'text'},
            {label: 'ความถี่',            fieldName: 'Frequency__Label',          type: 'text'},
            {label: 'ยอดรายจ่ายต่อปี',       fieldName: 'Expense_Amount__Label',     type: 'text'},
            {label: 'หมายเหตุ',               fieldName: 'Remark__c',             type: 'text'},
            {label: 'จัดการ', fieldName: '', type: 'button', initialWidth: 130, typeAttributes: { label: 'Delete', name: 'deleteRow', title: 'Delete', iconName: 'utility:delete' },  cellAttributes: { class:  'deleteBtn' }},
        ]);
        helper.getInitialData(component, event, helper);
        helper.getIncomeExpense(component, event, helper);
        helper.startSpinner(component);
        // helper.doWorkspaceAPI(component);
    },
    handleProfileName: function (component, event, helper) {
        helper.getDescribeFieldResult(component, event, helper);
    },
    onLoad: function (component, event, helper) {
        helper.stopSpinner(component);
        var recordUi = event.getParam('recordUi');

        // Default lookup field 
        // component.find('Sales_Support_Information').forEach(cmp => {
        //     if (cmp.get('v.fieldName') == 'RTL_Assigned_BRC__c') {
        //         cmp.set('v.value', recordUi.record.fields.RTL_Assigned_BRC__c.value);
        //     }
        // })
    },
    onSubmit: function (component, event, helper) {
        event.preventDefault();
        helper.displayErrorMessage(component, false, '', '');

        var eventFields = event.getParam("fields");
        component.set('v.fieldUpdate', eventFields);
        
        helper.submitData(component, eventFields);     
    },
    onSuccess: function (component, event, helper) {
        helper.stopSpinner(component);
        var appEvent = $A.get("e.c:RetailCSV_Event");
        appEvent.setParams({
            isRefresh: true,
            recordId: component.get(`v.recordId`),
            fieldUpdate: component.get(`v.fieldUpdate`)
        });
        appEvent.fire()
        helper.closeTab(component);
    },
    onError: function (component, event, helper) {
        helper.stopSpinner(component);
        var params = event.getParams();
        if (params.output.errors) {
            component.set('v.isModify', !params.output.errors.some(s => ["INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY", "INSUFFICIENT_ACCESS"].includes(s.errorCode)));
        }

        // Checking default value BRC
        if (!params.message || !`${params.message}`.includes('undefined')) {
            helper.displayErrorMessage(component, true, params.message, params.detail);
            if (params.message) helper.displayToast('error', `${params.message}`);
        }

    },
    handleSectionToggle: function (component, event, helper) {
        component.set('v.activeSections', ['OccupationSection', 'IncomeSection', 'ExpenseSection', 'SpecialPrefAndRelationshipLevel', 'A', 'B', 'C', 'D', 'E']);
    },
    onClose: function (component, event, helper) {
        helper.closeTab(component);
    },
    rowActionIncome: function(component, event, helper){
        helper.deleteRow(component, event, 'income');
    },
    rowActionExpense: function(component, event, helper){
        helper.deleteRow(component, event, 'expense');
    },
    addExpense: function (component, event, helper){
        var expenseCat = component.find('ExpenseCat').get('v.value');
        var freq = component.find('ExpenseFreq').get('v.value');
        var amount = component.find('ExpenseAmount').get('v.value');
      
        if(expenseCat && freq && amount){
            var expenseCatOption = component.get('v.expenseCatOption');
            var freqOption = component.get('v.frequencyOption');
            var amountOption = component.get('v.expenseAmountOption');

            var expenseCatLabel = '';
            expenseCatOption.forEach(element => {
                if(element.value == expenseCat){
                    expenseCatLabel = element.label;
                    return;
                }
            });

            var freqCatLabel = '';
            freqOption.forEach(element => {
                if(element.value == freq){
                    freqCatLabel = element.label;
                    return;
                }
            });

            var amountLabel = '';
            amountOption.forEach(element => {
                if(element.value == amount){
                    amountLabel = element.label;
                    return;
                }
            });
            
            var expenseList = component.get('v.ExpenseData');
            var expense ={
                Expense_Category__c:        expenseCat,
                Expense_Category__Label:    expenseCatLabel,
                Frequency__c:               freq,
                Frequency__Label:           freqCatLabel,
                Expense_Amount__c:          amount,
                Expense_Amount__Label:      amountLabel,
                Remark__c:              component.find('ExpenseRemark').get('v.value'),
                Id: expenseList.length + 1
            };       
        
            expenseList.push(expense);
        
            component.set('v.ExpenseData', expenseList);

            component.find('ExpenseCat').set('v.value', '');
            component.find('ExpenseFreq').set('v.value', '');
            component.find('ExpenseAmount').set('v.value', '');
            component.find('ExpenseRemark').set('v.value', '');
        }else{
            helper.displayToast('error', 'Please input "Category", "Frequency" and "Expense Amount"');
        }
        // console.log('ExpenseCat: '+ component.find('ExpenseCat').get('v.value'));
       
    },
    addIncome : function (component, event, helper){
        var incomeCat = component.find('IncomeCat').get('v.value');
        var freq = component.find('IncomeFreq').get('v.value');
        var amount = component.find('IncomeAmount').get('v.value');

        if(incomeCat && freq && amount){
            var IncomeCatOption = component.get('v.incomeCatOption');
            var freqOption = component.get('v.frequencyOption');
            var amountOption = component.get('v.incomeAmountOption');

            var incomeCatLabel = '';
            IncomeCatOption.forEach(element => {
                if(element.value == incomeCat){
                    incomeCatLabel = element.label;
                    return;
                }
            });

            var freqCatLabel = '';
            freqOption.forEach(element => {
                if(element.value == freq){
                    freqCatLabel = element.label;
                    return;
                }
            });

            var amountLabel = '';
            amountOption.forEach(element => {
                if(element.value == amount){
                    amountLabel = element.label;
                    return;
                }
            });
            
            var incomeList = component.get('v.IncomeData');
            var income ={
                Income_Category__c:     incomeCat,
                Income_Category__Label: incomeCatLabel,
                Frequency__c:           freq,
                Frequency__Label:       freqCatLabel,
                Income_Amount__c:       amount,
                Income_Amount__Label:   amountLabel,
                Remark__c:              component.find('IncomeRemark').get('v.value'),
                Id: incomeList.length + 1
            };       
        
            incomeList.push(income);
        
            component.set('v.IncomeData', incomeList);

            component.find('IncomeCat').set('v.value', '');
            component.find('IncomeFreq').set('v.value', '');
            component.find('IncomeAmount').set('v.value', '');
            component.find('IncomeRemark').set('v.value', '');
        }else{
            helper.displayToast('error', 'Please input "Category", "Frequency" and "Expense Amount"');
        }  
    },

    onCancel : function(component, event, helper){
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
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
        }
        else{
            var appEvent = $A.get("e.c:RetailCSV_Event");
            appEvent.setParams({
                isRefresh: true,
                recordId: component.get(`v.recordId`),
                fieldUpdate: []
            });
            appEvent.fire(); 
    
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId')
            
            });
            navEvt.fire();
        }
    }
})