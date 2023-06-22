({
    doInit: function (component, event, helper) {

        helper.doInitDepositProduct(component, event, helper);
        helper.getIsUnmaskData(component, helper);
        helper.getRedProductcodeList(component, event, helper);
        helper.doInitErrorMessageControl(component, event, helper);
        helper.getFieldVisibility(component, event, helper);

        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);
    },
    handlerAccount: function (component, event, helper) {

        const resultFrom01 = component.get('v.resultFrom01');
        var parentComponent = component.get("v.parent");   
        if(resultFrom01.StatusCode == '401' ){
            const sendToParent = new Map();
            sendToParent.set('DepositProductSummaryView', "error");
            parentComponent.handleReturnData(sendToParent);
        }
        else if(resultFrom01.StatusCode != null ){
            // var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('DepositProductSummaryView', "error");
            parentComponent.handleReturnData(sendToParent);
        }
        else{
            helper.getProductOSC02(component, helper);
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