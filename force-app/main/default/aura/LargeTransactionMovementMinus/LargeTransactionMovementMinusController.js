({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'CusName' } } },
            { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
            { label: 'Transaction Date', fieldName: 'Transaction_Date_Time__c', type: 'date' },
          

        ]);
        console.log('init');
        var action = component.get('c.getTransactionMinus');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                //component.set('v.data', resp.data);
                var finalData = [];
                var data = resp.data;
                console.log('111 data: '+JSON.stringify(data));
                data.forEach(element => {
                    console.log(JSON.stringify(element));
                    var url = element.Customer__c;
                    element.Id = '/'+ url;
                    
                    console.log('111element.Customer__r.Name: '+element.Customer__r.Name);
                    var name = element.Customer__r.Name;
                    console.log('111Name: '+name);
                    element.CusName = name;
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
        var workspaceAPI = component.find("transactionMinus");
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