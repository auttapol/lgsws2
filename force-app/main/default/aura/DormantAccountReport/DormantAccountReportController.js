({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'cusName' } } },
            { label: 'Account Number', fieldName: 'Account_Number__c', type: 'text' },
            {
                label: 'Due Date', fieldName: 'Dormant_Date__c', type: 'date',
                cellAttributes:
                {
                    class: { fieldName: 'textColor' }
                }
            }

        ]);
        console.log('init');
        var action = component.get('c.getDormantAccount');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('resp.Data: ' + resp.data);
                console.log('resp.Data json: ' + JSON.stringify(resp.data));
                //component.set('v.data', resp.data);
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var url = element.Customer__r.Id;
                    element.Id = '/' + url;

                    var cusName = element.Customer__r.Name;
                    element.cusName = cusName;

                    // var accNum = element.Customer__r.TMB_Customer_ID_PE__c;
                    // element.AccNum = accNum;

                    var today = new Date();
                    var duedate = new Date(element.Dormant_Date__c);
                   
                    if (duedate < today) {                      
                        element.textColor = 'redText';
                    }

                    finalData.push(element);

                });
                component.set('v.data', finalData);
                component.set('v.reportId', resp.reportId);
            } else {
                console.log('STATE');
            }
            component.set('v.isLoading', false);

        })
        $A.enqueueAction(action);
    },

    openTab: function (component, event, helper) {
        var workspaceAPI = component.find("DormantAccCmp");
        workspaceAPI.openTab({
            recordId: component.get('v.reportId'),
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        }).catch(function (error) {
            console.log(error);
        });
    }

})