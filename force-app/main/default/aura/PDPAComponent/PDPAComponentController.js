({
    doInit: function (component, event, helper) {
        var action = component.get('c.getPDPAList');
        action.setParams({
            accId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();

                console.log('pdpa only: ' + JSON.stringify(resp));

                var finalData = [];

                component.set('v.message', resp.Message);

                if (resp.data && resp.Success) {
                    var data = resp.data;
                    data.forEach((element, index) => {
                        console.log('pdpa index: ' + index);
                        element.index = index;
                        finalData.push(element);
                    });
                    console.log('pdpa data: ' + JSON.stringify(finalData));
                    component.set('v.data', finalData);
                }else if(resp.Success){                   
                    component.set('v.noData', 'No data. / ไม่มีข้อมูล');                    
                }

                
                component.set('v.account', resp.account);
                component.set('v.isSuccess', resp.Success)
                if (resp.isPrintable) {
                    component.set('v.isPrintable', resp.isPrintable);
                } else {
                    component.set('v.isPrintable', false);
                }
                if (resp.isEmailable) {
                    component.set('v.isEmailable', resp.isEmailable);
                } else {
                    component.set('v.isEmailable', false);
                }
                if (resp.isEditable) {
                    component.set('v.isEditable', resp.isEditable);
                } else {
                    component.set('v.isEditable', false);
                }

                if (data) {
                    component.set('v.size', resp.data.length);
                } else {
                    component.set('v.size', 0);
                }

            } else {
                console.log('pdpa STATE: '+response.getState());
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    printConsentPDF: function (component, event, helper) {
        component.set('v.isLoading', true);
        var dataVar = event.getSource().get("v.value");

        helper.printConsentHelper(component, dataVar);

    },
    sendEmail: function (component, event, helper) {
        component.set('v.isLoading', true);
        console.log('pdpa resp sendEmail');
        var dataVar = event.getSource().get("v.value");
        helper.sendEmailHelper(component, dataVar);
    },
    edit: function (component, event, helper) {
        console.log('pdpa resp edit pdpa');
        var dataVar = event.getSource().get("v.value");
        helper.editPDPAHelper(component, dataVar);
    },
    viewAllPDPA: function (component, event, helper) {
        console.log('pdpa resp viewAllPDPA');
        // component.find("navService").navigate({
        //     "type": "standard__webPage",
        //     "attributes": {
        //         "url": '/apex/PDPAScreenComponent?id='+component.get("v.recordId")
        //     }
        // })

        // var urlEvent = $A.get("e.force:navigateToURL");
        // urlEvent.setParams({
        //     "url":'/apex/PDPAScreenComponent?id='+component.get("v.recordId")
        // });
        // urlEvent.fire();

        var workspaceAPI = component.find("pdpaPage");
        workspaceAPI.openTab({
            "url": '/apex/PDPAScreenComponent?id=' + component.get("v.recordId"),
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function (error) {
            console.log(error);
        });

        // var workspaceAPI = component.find("v.pdpaPage");
        // workspaceAPI.openTab({
        //     pageReference: {
        //         "type": "standard__recordPage",
        //         "attributes": {
        //             "url":'/apex/PDPAScreenComponent?id='+component.get("v.recordId"),
        //             "actionName":"view"
        //         },
        //         "state": {}
        //     },
        //     focus: true
        // }).then(function(response) {
        //     workspaceAPI.getTabInfo({
        //     tabId: response
        // }).then(function(tabInfo) {
        //     console.log("The recordId for this tab is: " + tabInfo.recordId);
        // });
        // }).catch(function(error) {
        //     console.log(error);
        // });
    }
})