({
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMessage: function (component, title, errMsg) {
        console.log('set display error.message', errMsg);
        component.set('v.error.state', true);
        component.set('v.error.title', title);
        component.set('v.error.message', errMsg);
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },

    fireEventStatus: function (component, event, isSuccess) {
        var event = component.getEvent("eCommercialAutoLoan_ProductHoldingEvent");
        event.setParams({
            "productType": "CommercialAutoLoan_FloorPlanList",
            "isSuccess": isSuccess == true ? true : false
        });
        event.fire();
    },

    callProduct: function (component, event, helper) {
        helper.startSpinner(component);
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_FloorplanList',
            'callback': 'callbackFloorPlanList',
            'body': JSON.stringify({
                "rm_id": component.get("v.tmbCustId")
            }),
            'service': 'FloorPlan',
            'state': {
                'service': 'FloorPlan',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId")
            },
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                component.set('v.isError', result['isError'] || result['isThrow'] ? result['isError'] || result['isThrow'] : false);
                component.set('v.isTimeout', result['isTimeout'] ? result['isTimeout'] : false);
                helper.mapData(component, result['details'] ? result['details'] : []);
                helper.fireEventStatus(component, event, typeof result.isThrow === 'boolean' ? (!result.isThrow) : true);

            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                component.set('v.isError', true);
                helper.fireEventStatus(component, event, false);
            }
            helper.stopSpinner(component);
        });
        $A.enqueueAction(action);
    },

    doHeaderColumns: function (component, event, helper) {
        component.set('v.product.columns', [{
                label: 'No.',
                fieldName: 'No',
                type: 'text',
                wrapText: true,
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                fixedWidth: 60,
            },
            {
                label: $A.get("$Label.c.C_A_No"),
                type: 'button',
                typeAttributes: {
                    variant: 'base',
                    label: {
                        fieldName: 'MarkedC_A_No'
                    },
                    title: {
                        fieldName: 'MarkedC_A_No'
                    },
                    name: {
                        fieldName: 'MarkedC_A_No'
                    },
                },
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.Description_AutoLoan"),
                fieldName: 'Description_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.Approved_Date"),
                fieldName: 'Approved_Date',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.Expired_Date"),
                fieldName: 'Expired_Date',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center'
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.Status_AutoLoan"),
                fieldName: 'Status_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center'
                },
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get("$Label.c.Credit_Limit_AutoLoan"),
                fieldName: 'Credit_Limit_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                fixedWidth: 150,
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get("$Label.c.Outstanding_AutoLoan"),
                fieldName: 'Outstanding_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                fixedWidth: 150,
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get("$Label.c.Credit_Available"),
                fieldName: 'Credit_Available',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                fixedWidth: 150,
                isAccessible: 'isAccessibleCusHoldLow',
            }
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : 140;
            }
            return m;
        }));
    },
    mapData: function (component, data) {
        var methodUtils = component.find('methodUtils');
        component.set('v.product.datas', data.reduce((l, product, index) => {
            l.push({
                'C_A_No': product.fp_ca_no,
                'MarkedC_A_No': methodUtils.markAccountNo(product.fp_ca_no, 'xxxxxxyyyyyx'),
                'No': index + 1,
                'Description_AutoLoan': product.car_type_desc,
                'Approved_Date': product.approve_date,
                'Expired_Date': product.exp_date,
                'Status_AutoLoan': product.status,
                'os_balance': product.os_balance,
                'Credit_Limit_AutoLoan': methodUtils.markAmount(product.credit_limit),
                'Outstanding_Amount': methodUtils.markAmount(product.os_balance),
                'Credit_Available': methodUtils.markAmount(product.credit_available),
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            })
            return l;
        }, []));
    }
})