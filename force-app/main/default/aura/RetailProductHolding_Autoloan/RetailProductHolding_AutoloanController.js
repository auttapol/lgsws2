({
    onInit: function (component, event, helper) {
        helper.getIsUnmaskData(component,helper);
        helper.setHeaderColumns(component);
        helper.getALDXWFMdt(component, event, helper);

        //get constants retry
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);
    },
    handleAccessibleCusHold: function (component, event, helper) {
        // handler on change to callout service initial
        var accessibleCusHold = component.get('v.accessibleCusHold');
        if (
            accessibleCusHold.isAccessibleCusHoldLow ||
            accessibleCusHold.isAccessibleCusHoldMid ||
            accessibleCusHold.isAccessibleCusHoldHig
        ) {
            component.set('v.product.columns', component.get('v.product.columns').map(function (m) {
                m.fieldName = m.isAccessible ? (accessibleCusHold[m.isAccessible] ? m.fieldName : 'Hidden') : m.fieldName;
                m.type = m.fieldName == 'Hidden' ? 'text' : m.type;
                return m;
            }));
        }
    },
    onClickAction: function (component, event, helper) {
        var row = event.getParam('row');
        var navService = component.find('navService');
        navService.navigate({
            "type": "standard__webPage",
            "attributes": {
                "url": '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:CommercialAutoLoan_HPFeetHPDetail",
                    "attributes": {
                        "recordId": component.get('v.recordId'),
                        "tmbCustId": component.get('v.tmbCustId'),
                        "accessibleCusHold": component.get('v.accessibleCusHold'),
                        "company": component.get('v.company'),
                        "contractNo": row.HP_Account_No,
                        "markedcontractNo": row.MarkedHP_Account_No,
                        "accountType": "Retail",
                        // "isEmployee" : helper.isEmployee(component)
                    }
                }))
            }
        }, false);
    },
    calloutService: function (component, event, helper) {
        if (component.get('v.company')) {
            helper.callProduct(component, event, helper, 0)
        } else {
            helper.getCoreHPCompany(component, event, helper);
        }
    },
    getProducts: function (component, event, helper) {
        return component.get('v.product.datas');
    },
    getError: function (component, event, helper) {
        return {
            isError: component.get('v.isError'),
            isTimeout: component.get('v.isTimeout'),
            auraId: component.get('v.auraId'),
            Tag: component.get('v.tag'),
            Type: $A.get('$Label.c.Auto_loan_HP'),
        };
    },
})