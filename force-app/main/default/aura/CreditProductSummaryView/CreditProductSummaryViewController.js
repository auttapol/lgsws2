({
    onInit: function (component, event, helper) {

        // helper.getIsUnmaskData(component, helper);
        helper.doInitCreditCardRDCProduct(component, event, helper);        

        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);
    },

    handlerAccount: function (component, event, helper) {

        if (component.get('v.isOnce')) {
            component.set('v.isOnce', false);

            window.addEventListener("offline", function (event) {
                component.set('v.isOnline', false);
            });

            window.addEventListener("online", function (event) {
                event.preventDefault();
                component.set('v.isOnline', true);
            });

            // handler to callout service
            if (!component.get('v.recordId')) {
                var recordId = component.get('v.recordId');
                var pageReference = component.get("v.pageReference");
                component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
            }
            component.set('v.tmbCustId', helper.getTMBCustID(component));
            if(component.get('v.allowCallChild') == true){
                helper.GetCreditCard(component, helper, 'N', '', null, 0);
            }
            else{
                var parentComponent = component.get("v.parent");   
                const sendToParent = new Map();
                sendToParent.set('CreditProductSummaryView', 'default');
                parentComponent.handleReturnData(sendToParent);
            }
            
        }
    },

    onViewClickHref: function (component, event, helper) {
        var row = event.getParam('row');
        if (!row.isError && row.link) {
            var theme = component.get('v.theme');
            if (theme == 'Theme3') {
                var appEvent = $A.get("e.c:CallCenterCSV_ProductHoldingEvent");
                appEvent.setParams({
                    'componentName': row.Tag,
                    'tabName': row.TabName,
                    'params': row.link.replace('/one/one.app#', '')
                });
                appEvent.fire();
            } else if (theme == 'Theme4t' || theme == 'Theme4d') {
                var navService = component.find('navService');
                navService.navigate({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": row.link
                    }
                }, false);
            } else {
                // Theme4u
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: row.link,
                        focus: true
                    });
                })
                    .catch(function (error) {
                        console.log(error);
                    });
            }
        }
    },

})