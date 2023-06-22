({
    onInit: function (component, event, helper) {
        helper.setColumns(component, event, helper);
        helper.getALDXWFMdt(component, event, helper);
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

            helper.getCoreHPCompany(component, event, helper);
        }
    },

    onClickHref: function (component, event, helper) {
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
                        "theme": component.get('v.theme'),
                        "accessibleCusHold": component.get('v.accessibleCusHold'),
                        "company": component.get('v.company'),
                        "contractNo": row.C_A_No,
                        "markedcontractNo": row.MarkedC_A_No,
                        "accountType": "Commercial",
                    }
                }))
            }
        }, false);
    },
    calloutService: function (component, event, helper) {
        helper.callProduct(component, event, helper);
    },
    getError: function (component, event, helper) {
        return {
            isTimeout: component.get('v.isTimeout'),
            isError: component.get('v.isError'),
            type: $A.get('$Label.c.Auto_Loan_HP_Fleet_HP')
        };

    }
})