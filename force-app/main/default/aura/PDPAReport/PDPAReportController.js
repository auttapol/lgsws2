({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Customer Name', fieldName: 'accId', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
            // { label: 'Type', fieldName: 'pdpaId', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'pdpaName' } } },
            { label: 'Has PDPA', fieldName: 'RMC_Has_PDPA__c', type: 'text' },
           // { label: 'Due Date', fieldName: 'dueDate', type: 'date' }

        ]);
        console.log('pdpa init');
        var action = component.get('c.getPDPAReport');
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('pdpa Data: ' + resp.data);
                console.log('pdpa Data json: ' + JSON.stringify(resp.data));
                //component.set('v.data', resp.data);
                var finalData = [];
                var data = resp.data;
                data.forEach(element => {
                    var accountId = element.accId;
                    element.accId = '/'+ accountId;
                    // finalData.push(element);
                    if(element.pdpaId){
                        var pdpaId = element.pdpaId;
                        element.pdpaId = '/'+ pdpaId;
                    }
                    
                    finalData.push(element);

                });
                component.set('v.data', finalData);
                component.set('v.reportId', resp.reportId);
            } else {
                console.log('pdpa STATE: '+response.getState());
            }
            component.set('v.isLoading', false);

        })
        $A.enqueueAction(action);
    },

    openTab: function (component, event, helper) {
        var workspaceAPI = component.find("pdpaReportCmp");
        workspaceAPI.openTab({
            recordId: component.get('v.reportId'),
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("pdpa The url for this tab is: " + tabInfo.url);
            });
        }).catch(function (error) {
            console.log('pdpa error: '+error);
        });
    }

})