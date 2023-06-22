({
    // handlerAccount : function(component, event, helper) {
    onInit : function(component, event, helper) {
        component.set('v.bancassuranceProduct.columns', [{
            label: $A.get('$Label.c.Policy_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'POLICY_NO'
                },
                title: {
                    fieldName: 'POLICY_NO'
                },
                name: {
                    fieldName: 'POLICY_NO'
                },
            },
            fixedWidth: 180,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'PRODUCT_GROUP',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'POLICY_NAME',
            type: 'text',
            wrapText: true,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Insurance_Company'),
            fieldName: 'COMPANY_NAME',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Opened_Date'),
            fieldName: 'EFFECTIVE_DATE',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Status'),
            fieldName: 'STATUS',
            type: 'text',
            fixedWidth: 90,
            //initialWidth: 80,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Sum_Insure'),
            fieldName: 'SUM_INSURE',
            type: 'number',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.AFYP'),
            fieldName: 'PREMIUM',
            type: 'number',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Expiry_Date'),
            fieldName: 'EXPIRY_DATE',
            type: 'text',
            fixedWidth: 130,
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = ['PRODUCT_GROUP', 'POLICY_NAME', 'COMPANY_NAME'].includes(m.fieldName) ? 160 : 120;
                m.initialWidth = ['PRODUCT_GROUP', 'POLICY_NAME', 'COMPANY_NAME'].includes(m.fieldName) ? 190 : 120;
            }
            return m;
        }));
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);

        if(component.get('v.allowCallChild') == false){
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('BancassuranceSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }
        else{
            helper.GetBancassurance(component, helper, 0);
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