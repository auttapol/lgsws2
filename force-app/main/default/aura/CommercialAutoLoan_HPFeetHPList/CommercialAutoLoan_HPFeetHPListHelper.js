({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    setColumns: function (component, event, helper) {
        component.set('v.product.columns', [{
                label: 'No.',
                fieldName: 'No',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'center',
                },
                fixedWidth: 60,
                isAccessible: 'isAccessibleCusHoldLow'
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
                        fieldName: 'errorClass'
                    },
                    alignment: 'center',
                },
                fixedWidth: 140,
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Status_AutoLoan'),
                fieldName: 'Status_AutoLoan',
                type: 'text',
                wrapText: true,
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'left',
                },
                fixedWidth: 180,
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.HP_Amount'),
                fieldName: 'HP_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Financial_Amount_Ex_Vat'),
                fieldName: 'Financial_Amount_Ex_Vat',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                fixedWidth: 160,
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Outstanding_AutoLoan'),
                fieldName: 'Outstanding_Amount',
                type: 'text',
                wrapText: true,
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Installment_Amount'),
                fieldName: 'Installment_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Overdue_No'),
                fieldName: 'Overdue_No',
                type: 'number',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Overdue_Amount'),
                fieldName: 'MarkedOverdue_Amount',
                type: 'text',
                wrapText: true,
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.HUB'),
                fieldName: 'HUB',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'errorClass'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            }
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : 140;
            }
            return m;
        }));
    },

    getCoreHPCompany: function (component, event, helper) {
        var action = component.get('c.getAppConfigMdtByKey');
        action.setParams({
            'key': 'CoreHP_Company'
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.company', result ? result : 'TBANK');
                $A.enqueueAction(component.get('c.calloutService'));
            }
        });
        $A.enqueueAction(action);
    },
    getALDXWFMdt: function (component, event, helper) {
        var action = component.get('c.getALDXWFMdt');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.alds_wf', result);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    callProduct: function (component, event, helper) {
        helper.startSpinner(component, event, helper);
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_HpFleetHpList',
            'callback': 'callbackHpFleetHpList',
            'body': JSON.stringify({
                "Company": component.get('v.company'),
                "RMID": component.get('v.tmbCustId'),
                "HPType": "HP",
                "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
            }),
            'service': 'CoreHP',
            'state': {
                'service': 'CoreHP',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId")
            },
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.isError', result.isError || result.isThrow ? result.isError || result.isThrow : false);
                component.set('v.isTimeout', result.isTimeout ? result.isTimeout : false);
                helper.parseMappaing(component, result.Output ? result.Output : []);
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
    fireEventStatus: function (component, event, isSuccess) {
        var event = component.getEvent("eCommercialAutoLoan_ProductHoldingEvent");
        event.setParams({
            "productType": "CommercialAutoLoan_HPFeetHPList",
            "isSuccess": isSuccess == true ? true : false
        });
        event.fire();
    },
    parseMappaing: function (component, data) {
        var methodUtils = component.find('methodUtils');
        component.set('v.product.datas', data.filter(f => parseInt(f.ContractStatusCode) >= 10)
            .reduce((list, product, index) => {
                list.push({
                    'No': index + 1,
                    'C_A_No': product.ContractNo,
                    'MarkedC_A_No': methodUtils.markAccountNo(product.ContractNo, 'xxxxxxxyyyyy'.substr(12 - `${product.ContractNo}`.length ? 12 - `${product.ContractNo}`.length : 0)),
                    // 'ContractStatusCode': `${product.ContractStatusCode} - ${product.ContractStatusName}`,
                    'Status_AutoLoan': `${product.ContractStatusCode ? product.ContractStatusCode : ''} - ${product.ContractStatusName ? product.ContractStatusName : ''}`,
                    'HP_Amount': methodUtils.markAmount(product.HPTotalAmount),
                    'Financial_Amount_Ex_Vat': methodUtils.markAmount(product.HPNetAmount),
                    'Outstanding_Amount': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) : methodUtils.markAmount(product.OutstandingAmount),
                    'Installment_Amount': methodUtils.markAmount(product.Installment),
                    'Overdue_No': product.OverdueNo,
                    'Overdue_Amount': product.OverdueAmount,
                    'MarkedOverdue_Amount': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) : methodUtils.markAmount(product.OverdueAmount),
                    'HUB': product.Channel,
                    'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
                });
                return list;
            }, []));
    },


})