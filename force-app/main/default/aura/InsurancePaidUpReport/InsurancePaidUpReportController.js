({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Insurance Policy No.', fieldName: 'Account_Number__c', type: 'text', wrapText: true },
            { label: 'Insurance Fully Paid Date', fieldName: 'Insurance_Paid_Up_Date__c', type: 'date', wrapText: true }
            // { label: 'Insurance Anniversary Date',    fieldName: 'Insurance_Anniversary_Date__c', type: 'date', wrapText: true }
            // { label: 'MF Maturity Date',   fieldName: 'MF_Maturity_Date__c', type: 'date' },
            // { label: 'MF Amount',          fieldName: 'MF_Amount__c', type: 'currency' },

        ]);

        var action = component.get('c.getPaidUpInsurance');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('resp.Data: ' + resp.data);
                console.log('resp.Data json: ' + JSON.stringify(resp.data));
                //component.set('v.data', resp.data);
                var finalData = [];
                var data = resp.data;
                if (data) {
                    data.forEach(element => {
                        // var url = element.Id;
                        element.Id = '/' + element.Customer__c;
                        element.Name = element.Customer__r.Name;
                        console.log('ele ele: '+element.Insurance_Paid_Up_Date__c );
                        // element.Insurance_Paid_Up_Date__c
                        finalData.push(element);

                    });
                }
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
        var workspaceAPI = component.find("riskReportCmp");
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