({
    onInit: function (component, event, helper) {
        helper.doHeaderColumns(component, event, helper);
        // helper.callProduct(component, event, helper);
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

            $A.enqueueAction(component.get('c.calloutService'));
        }
    },
    calloutService: function (component, event, helper) {
        helper.callProduct(component, event, helper);
    },

    getError: function (component, event, helper) {
        return {
            isError: component.get('v.isError'),
            isTimeout: component.get('v.isTimeout'),
            type: $A.get('$Label.c.Auto_Loan_Floor_Plan')
        };

    },

    onSummaryClickHref: function (component, event, helper) {
        var navService = component.find('navService');
        var row = event.getParam('row');

        navService.navigate({
            "type": "standard__webPage",
            "attributes": {
                "url": '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:CommercialAutoLoan_FloorPlanDetail",
                    "attributes": {
                        "recordId": component.get('v.recordId'),
                        "tmbCustId": component.get('v.tmbCustId'),
                        "theme": component.get('v.theme'),
                        "accessibleCusHold": component.get('v.accessibleCusHold'),
                        "ca_no": row.C_A_No,
                        "markedos_balance": row.Outstanding_Amount,
                        "markedca_no": row.MarkedC_A_No
                    }
                }))
            }
        }, false);
    }
})