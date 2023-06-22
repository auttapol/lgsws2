({
    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    printConsentHelper: function (component, dataVar) {
        var action = component.get('c.printPDPA');
        action.setParams({
            index: dataVar,
            accId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                if (resp.Success) {
                    console.log('resp printConsentPDF success');
                    var pageRef = resp.PageReference;

                    // var navService = component.find("navService");
                    // navService.navigate(pageRef)
                    component.find("navService").navigate({
                        "type": "standard__webPage",
                        "attributes": {
                            "url": pageRef
                        }
                    })
                } else {
                    console.log('resp printConsentPDF fail: ' + resp.Message);
                }

                //component.set('v.data', resp.data);
                // var finalData = [];

            } else {
                console.log('resp STATE1: ' + response.getState());
                console.log('resp STATE2: ' + response.getError());
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    sendEmailHelper: function (component, dataVar) {
        console.log('sendEmailHelper');
        var action = component.get('c.sendEmailController');
        action.setParams({
            index: dataVar,
            accId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                if (resp.Success) {
                    this.showToast('Success', 'Email send', 'success')
                } else {
                    console.log('resp printConsentPDF fail: ' + resp.Message);
                    this.showToast('Error', resp.Message, 'error')
                }
            } else {
                console.log('resp STATE1: ' + response.getState());
                console.log('resp STATE2: ' + JSON.stringify(response.getError()));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    editPDPAHelper: function (component, dataVar) {
        // openSubTab('{!urlToUpdatePdpa}?id={!accountObj.Id}&retURL={!accountObj.Id}&pdpatype={!pdpaDetail.type}&tmbid={!accountObj.TMB_Customer_ID_PE__c}', 'PDPA and Market Consent', 'PDPA and Market Consent', true); return false;
        var pdpa = component.get('v.data')[dataVar];

        var action = component.get('c.editPDPAController');
        action.setParams({
            index: dataVar,
            accId: component.get("v.recordId"),
            type: pdpa.type
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var resp = response.getReturnValue();
                if (resp.Success) {
                    console.log('resp navigate url: '+resp.url);
                    component.find("navService").navigate({
                        "type": "standard__webPage",
                        "attributes": {
                            "url": resp.url
                        }
                    })
                } else {
                    console.log('resp editPDPAHelper fail: ' + resp.Message);
                    this.showToast('Error', resp.Message, 'error')
                }
            } else {
                console.log('resp STATE1: ' + response.getState());
                console.log('resp STATE2: ' + JSON.stringify(response.getError()));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    }

})