({
    startSpinner: function (component) {
        component.set('v.isLoading', true);
        this.ButtonPaginator(component);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
        this.ButtonPaginator(component);
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
            },
            {
                label: $A.get('$Label.c.Status_AutoLoan'),
                fieldName: 'Status_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                fixedWidth: 150,
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Price'),
                fieldName: 'Price',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Outstanding_AutoLoan'),
                fieldName: 'Outstanding_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Installment_Amt_Inc_VAT'),
                fieldName: 'Installment_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Overdue_No'),
                fieldName: 'Overdue_No',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right',
                },
                isAccessible: 'isAccessibleCusHoldLow'
            },
            {
                label: $A.get('$Label.c.Overdue_Amount'),
                fieldName: 'Overdue_Amount',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right',
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
    calloutProductLeasingFlag: function (component, event, calloutAction) {
        var helper = this;
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_LeasingFlag',
            'callback': 'callbackLeasingFlag',
            'body': JSON.stringify({
                "query": {
                    "search_type": "rm-id",
                    "search_value": component.get("v.tmbCustId"),
                    "filter_by": "RMABMIB"
                }
            }),
            'service': 'DWH',
            'state': {
                'service': 'DWH',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId")
            },
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.result', result);
                component.set('v.isError', result.isError || result.isThrow ? result.isError || result.isThrow : false);
                component.set('v.isTimeout', result.isTimeout ? result.isTimeout : false);
                component.set('v.hasLeasing',
                    component.get('v.result.customer.product_holdings.leasing_accounts') ?
                    component.get('v.result.customer.product_holdings.leasing_accounts').length > 0 : false);
                
                /* By pass when response is more than 1 MB*/
                if (component.get('v.result.StatusCode') == '2004') {
                    component.set('v.hasLeasing', true);
                }
                if (component.get('v.hasLeasing')) {
                    $A.enqueueAction(calloutAction);
                } else {
                    component.set('v.isLeasingFlag', true);
                    helper.fireEventStatus(component, event, typeof result.isThrow === 'boolean' ? (!result.isThrow) : true);
                    helper.stopSpinner(component);
                }

            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        return action;
    },
    calloutService: function (component, event, helper) {
        /*
            1. get product flag
            2. get limit
            3. get product
         */
        helper.startSpinner(component);
        var action = component.get('c.getAppConfigMdtByKey');
        action.setParams({
            'key': 'LeasingList_LIMIT'
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.limit', result ? parseInt(result) : 100);
                helper.callProduct(component, event, helper);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });

        if (component.get('v.hasLeasing')) {
            $A.enqueueAction(action);
        } else {
            $A.enqueueAction(helper.calloutProductLeasingFlag(component, event, action));
        }
    },
    callProduct: function (component, event, helper) {
        var limit = component.get('v.limit');
        var offset = component.get('v.offset');

        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': `callout:AutoLoan_LeasingList`,
            'callback': 'callbackLeasingList',
            'body': JSON.stringify({
                "rmid": component.get("v.tmbCustId"),
                // "records_per_page": limit,
                // "page_no": "",
                "start_record": offset + 1,
                "end_record": offset + limit
            }),
            'service': 'DWH',
            'state': {
                'service': 'DWH',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId")
            },
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.isNotFound', result.isNotFound ? result.isNotFound : false);
                component.set('v.isError', result.isError || result.isThrow ? result.isError || result.isThrow : false);
                component.set('v.isTimeout', result.isTimeout ? result.isTimeout : false);
                component.set('v.isLeasingFlag', false);

                helper.mapData(component, result.leasing_summary_info && !component.get('v.isNotFound') ? result.leasing_summary_info : []);
                helper.paginator(component, result);
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
    paginator: function (component, result) {
        component.set('v.result', result);
        component.set('v.showPage', !result.isNotFound && !result.isError && !result.isThrow && !result.isTimeout && (result.leasing_summary_info ? result.leasing_summary_info.length > 0 : false));

        // component.set('v.offset', component.get('v.result.paging.offset') ? component.get('v.result.paging.offset') : component.get('v.offset'));
        component.set('v.count', component.get('v.result.leasing_summary_info.length') ? component.get('v.result.leasing_summary_info.length') : component.get('v.count'));
        component.set('v.total_record', component.get('v.result.status.total_record') ? component.get('v.result.status.total_record') : component.get('v.result.leasing_summary_info.length'));
        component.set('v.pageInfo', !component.get('v.result.isNotFound') ?
            `(${component.get('v.offset') + 1} - ${component.get('v.offset') + component.get('v.count')} of ${component.get('v.total_record')})` : ``); // Records not found
        this.ButtonPaginator(component);
    },
    ButtonPaginator: function (component) {
        var previous = Array.isArray(component.find('previous')) ? component.find('previous') : [component.find('previous')];
        previous.forEach(cmp => {
            if (cmp) cmp.set('v.disabled', component.get('v.isLoading') || (component.get('v.offset') <= 0));
        });
        var next = Array.isArray(component.find('next')) ? component.find('next') : [component.find('next')];
        next.forEach(cmp => {
            if (cmp) cmp.set('v.disabled', component.get('v.isLoading') || (component.get('v.offset') + component.get('v.count') >= component.get('v.total_record')));
        });
    },
    fireEventStatus: function (component, event, isSuccess) {
        var event = component.getEvent("eCommercialAutoLoan_ProductHoldingEvent");
        event.setParams({
            "productType": "CommercialAutoLoan_LeasingList",
            "isSuccess": isSuccess == true ? true : false
        });
        event.fire();
    },

    mapData: function (component, data) {
        var methodUtils = component.find('methodUtils');
        component.set('v.product.datas', data.reduce((l, product, index) => {
            l.push({
                'No': component.get('v.offset') + 1 + index,
                'C_A_No': product.ca_no,
                'MarkedC_A_No': methodUtils.markAccountNo(`${product.ca_no}`.length == 12 ? product.ca_no : `0000${product.ca_no}`, 'xxxxxxyyyyyx'),
                'Status_AutoLoan': product.account_status,
                'Price': methodUtils.markAmount(product.cash_price_vat),
                'Outstanding_Amount': methodUtils.markAmount(product.principal_amount),
                'Installment_Amount': methodUtils.markAmount(product.installment_amount),
                'Overdue_No': product.overdue_no,
                'Overdue_Amount': methodUtils.markAmount(product.overdue_amount),
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            });
            return l;
        }, []));
    }

})