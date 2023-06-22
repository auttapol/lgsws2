({
    init: function (component, event, helper) {
        component.set('v.columns', [
            { label: 'Title', fieldName: 'Id', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'Title' } } },
            { label: 'Published Date', fieldName: 'FirstPublishedDate', type: 'date', wrapText: true },
            { label: 'Modified Date', fieldName: 'LastModifiedDate', type: 'date', wrapText: true },
           
        ]);

        var action = component.get('c.getTipKnowledge');
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
                        element.Id = '/' + element.Id;
                        // element.Name = element.Customer__r.Name;
                        // console.log('ele ele: '+element.Insurance_Paid_Up_Date__c );
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
        var workspaceAPI = component.find("TipReport");
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