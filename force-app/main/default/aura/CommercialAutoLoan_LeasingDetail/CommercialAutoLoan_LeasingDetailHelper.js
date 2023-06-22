({
    doInit: function (component, event, helper) {
        helper.mapColumn(component, event, helper);
        helper.execAccessibleCusHold(component, event, helper);
        helper.callProduct(component, event, helper);
        helper.callProductGuarantor(component, event, helper);
    },

    doWorkspaceAPI: function (component, event, helper) {
        var tabName = component.get('v.product.LeasingInfo').find(f => f.fieldName == 'ca_no').value ||
            component.get('v.markedca_no');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:product",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },

    startSpinner: function (component, productType) {
        component.set(`v.isLoading${productType}`, true);
    },
    stopSpinner: function (component, productType) {
        component.set(`v.isLoading${productType}`, false);
    },
    execAccessibleCusHold: function (component, event, helper) {
        [
            'v.product.LeasingInfo',
            // 'v.product.Guarantor',
        ].forEach(e => {
            component.set(e, component.get(e).map(function (m) {
                m.fieldName = m.isAccessible ? (component.get(`v.accessibleCusHold.${m.isAccessible}`) ? m.fieldName : 'Hidden') : m.fieldName;
                m.type = m.fieldName == 'Hidden' ? 'STRING' : m.type;
                // m.value = m.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '';
                return m;
            }));
        });

        // Guatorator only
        component.set('v.product.Guarantor', component.get('v.product.Guarantor').map(function (m) {
            m.fieldName = m.isAccessible ? (component.get(`v.accessibleCusHold.${m.isAccessible}`) ? m.fieldName : 'Hidden') : m.fieldName;
            m.type = m.fieldName == 'Hidden' ? 'STRING' : m.type;
            m.value = m.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '';
            return m;
        }));
    },
    callProduct: function (component, event, helper) {
        helper.startSpinner(component, 'Leasing');
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_LeasingDetail',
            'callback': 'callbackLeasingDetail',
            'body': JSON.stringify({
                "ca_no": component.get('v.ca_no')
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
                // console.log(result);
                component.set('v.error.messages.Leasing.label', $A.get('$Label.c.Auto_Loan_Leasing'));
                component.set('v.error.messages.Leasing.isError', result.isError || result.isThrow ? true : false);
                component.set('v.error.messages.Leasing.isTimeout', result.isTimeout ? true : false);
                $A.enqueueAction(component.get('c.handleAlertError'));

                helper.mapDataLeasingInfo(component, result.leasing_detail_info ? result.leasing_detail_info : {});
            } else {
                component.set('v.error.messages.Leasing.isError', true);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.handleErrorMessage(component, event, helper);
            }

            helper.stopSpinner(component, 'Leasing');
        });
        $A.enqueueAction(action);
    },
    callProductGuarantor: function (component, event, helper) {
        helper.startSpinner(component, 'Guarantor');
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_Guarantor',
            'callback': 'callbackGuarantor',
            'body': JSON.stringify({
                "query": {
                    "acct_nbr": component.get('v.ca_no'),
                    "appl_code": "93"
                }
            }),
            'service': 'DWH',
            'state': {
                'service': 'DWH',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId"),
                'sectionName': 'CommCust:Customer Product Holding (High)'
            },
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.error.messages.Guarantor.label', $A.get('$Label.c.Guarantor'));
                component.set('v.error.messages.Guarantor.isError', result.isError || result.isThrow ? true : false);
                component.set('v.error.messages.Guarantor.isTimeout', result.isTimeout ? true : false);
                component.set('v.error.messages.Guarantor.isNoData', result.isNoData ? true : false);
                $A.enqueueAction(component.get('c.handleAlertError'));

                helper.mapDataGuarantor(component, result ? result : {});

            } else {
                component.set('v.error.messages.Guarantor.isError', true);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.handleErrorMessage(component, event, helper);
            }
            helper.stopSpinner(component, 'Guarantor');
        });
        $A.enqueueAction(action);
    },

    mapColumn: function (component, event, helper) {
        component.set('v.product.LeasingInfo', [{
                label: $A.get('$Label.c.Contract_No'),
                fieldName: 'ca_no',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Cash_Price'),
                fieldName: 'cash_price',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Contract_Date'),
                fieldName: 'approve_date',
                type: 'DATE',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Deposit'),
                fieldName: 'deposit_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Type_AutoLoan'),
                fieldName: 'type',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Residual_Value'),
                fieldName: 'residual_value_net_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Due_Date'),
                fieldName: 'due_date',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Asset_Price'),
                fieldName: 'asset_price_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.First_due_Date'),
                fieldName: 'first_due_date',
                type: 'DATE',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Outstanding_Exc_VAT_Unearned'),
                fieldName: 'principal_amount_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Maturity_Date_AutoLoan'),
                fieldName: 'maturity_date',
                type: 'DATE',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Outstanding_AutoLoan'),
                fieldName: 'outstanding',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Installment_No'),
                fieldName: 'installment_no',
                type: 'INTEGER',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Last_Payment_Date_AutoLoan'),
                fieldName: 'last_payment_date',
                type: 'DATE',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Eff_Rate'),
                fieldName: 'effective_rate',
                type: 'DOUBLE',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.No_of_Overdue'),
                fieldName: 'overdue_no',
                type: 'INTEGER',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Installment_Amount'),
                fieldName: 'installment_amount',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
                masking: true,
            },
            {
                label: $A.get('$Label.c.First_Overdue_No'),
                fieldName: 'overdue_dpd',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get('$Label.c.Installment_Amt_Inc_VAT'),
                fieldName: 'installment_amount_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Overdue_Amount'),
                fieldName: 'overdue_amount',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Down_Payment'),
                fieldName: 'down_payment_vat_included',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
                masking: true,
            },
            {
                label: $A.get('$Label.c.Brand_AutoLoan'),
                fieldName: 'brand_name',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: '',
                fieldName: '',
                class: 'slds-hide',
            },
            {
                label: $A.get('$Label.c.Model_AutoLoan'),
                fieldName: 'model_description',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldLow',
            },
        ]);

        // Guarantor
        var guarantorDatas = [];
        for (let i = 0; i < 4; i++) {
            guarantorDatas.push({
                label: $A.get('$Label.c.Guarantor_Name') + ' ' + (i + 1),
                fieldName: 'c_name',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
            }, {
                label: $A.get('$Label.c.ID_Number'),
                fieldName: 'id_no',
                type: 'STRING',
                isAccessible: 'isAccessibleCusHoldHig',
            }, {
                label: $A.get('$Label.c.Birth_Date'),
                fieldName: 'id_birth_date',
                type: 'DATE',
                isAccessible: 'isAccessibleCusHoldHig',
            }, {
                label: '',
                fieldName: '',
                class: 'slds-hide'
            });
        }
        component.set('v.product.Guarantor', guarantorDatas);
    },
    mapDataLeasingInfo: function (component, data) {
        component.set('v.result', data);
        var methodUtils = component.find('methodUtils');
        var isError = component.get('v.error.messages.Leasing.isError') || component.get('v.error.messages.Leasing.isTimeout');
        var leasingDatas = component.get('v.product.LeasingInfo');
        leasingDatas.forEach(item => {
            item.class = isError ? `${item.class} erorrProduct` : `${item.class}`.replace(/( erorrProduct)/g, '');
            item.value = isError ? `${$A.get('$Label.c.ERR008')}` :
                (item.fieldName == 'Hidden' ?
                    $A.get('$Label.c.Data_Condition_Hidden_Text') : component.get(`v.result.${item.fieldName}`));
            item.value = item.type === 'DATE' && component.get(`v.result.${item.fieldName}`) ? // transform date type
                new Date(component.get(`v.result.${item.fieldName}`).match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) :
                item.value;
        });
        if (!isError) {
            leasingDatas.find(f => f.fieldName == 'ca_no').value = component.get(`v.result.ca_no`) ?
                methodUtils.markAccountNo(component.get(`v.result.ca_no`), 'xxxxxxyyyyyx'.substr(12 - `${component.get(`v.result.ca_no`)}`.length ? 12 - `${component.get(`v.result.ca_no`)}`.length : 0)) :
                component.get('v.markedca_no');
            leasingDatas.filter(f => f.masking)
                .forEach(item => {
                    item.value = item.fieldName == 'Hidden' ? item.value : methodUtils.markAmount(item.value);
                });
            this.doWorkspaceAPI(component);
        }

        component.set('v.product.LeasingInfo', leasingDatas);
    },
    mapDataGuarantor: function (component, data) {
        component.set('v.result', data);
        if (component.get('v.error.messages.Guarantor.isNoData') ||
            component.get('v.error.messages.Guarantor.isError') ||
            component.get('v.error.messages.Guarantor.isTimeout')) {
            component.set('v.product.Guarantor',
                component.get('v.product.Guarantor')
                .map(m => {
                    if (m.fieldName != 'Hidden') {
                        m.value = `${component.get('v.error.messages.Guarantor.isNoData') ? $A.get('$Label.c.No_data') : $A.get('$Label.c.ERR008')}`;
                        m.class = `${m.class ? `${m.class}`.replace(/(erorrProduct)/g, '') : ''}${component.get('v.error.messages.Guarantor.isNoData') ? '' : ' erorrProduct'}`;
                    }
                    return m;
                }));
        } else {
            component.get('v.product.Guarantor').filter(f => f.fieldName).forEach(m => {
                m.value = ``;
                m.class = `${m.class ? m.class : ''}`.replace(/(erorrProduct)/g, '');
            });
            if (component.get('v.result.account.guarantors')) {
                component.get('v.result.account.guarantors')
                    .reduce((list, item, index) => {
                        if (index >= 4) return list;
                        list.push(item);
                        return list;
                    }, [])
                    .forEach((e, index) => {
                        component.set(`v.product.Guarantor.${(index * 4)}.value`, e.tha_fullname);
                        component.set(`v.product.Guarantor.${(index * 4) + 1}.value`, e.id_no);
                        component.set(`v.product.Guarantor.${(index * 4) + 2}.value`, e.id_birth_date);

                    });
            }
        }
    },

    handleErrorMessage: function (component, event, helper) {
        var error = component.get('v.error');
        $A.createComponents(
            [
                ["aura:html", {
                    tag: "div",
                    body: `${$A.get('$Label.c.ERR001_ProductHolding')}\n${$A.get('$Label.c.ERR001_DetailBelow')}\n`
                }]
            ].concat(Object.keys(error.messages)
                .filter(f => error.messages[f].isNoData != true && error.messages[f].isError)
                .reduce((l, productType, index, arrays) => {
                    l.push(["aura:html", {
                        tag: "a",
                        HTMLAttributes: {
                            name: `${productType}Href`,
                            class: 'erorrProduct',
                            onclick: component.getReference('c.handleClickHref')
                        },
                        body: `${error.messages[productType].label}${arrays.length - 1 > index ? ', ':''}`,
                    }]);
                    return l;
                }, [])),
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.message', cmp);
                }
            }
        );
    },

    handleRetry: function (component) {
        var error = component.get('v.error');
        var Product_Holding_Refresh = $A.get('$Label.c.Product_Holding_Refresh');
        var messageTimeoutLink = Product_Holding_Refresh.split('{0}');

        component.set('v.error.message',
            Object.keys(error.messages).some(key => error.messages[key].isError) && Object.keys(error.messages).some(key => error.messages[key].isTimeout) ?
            `${$A.get('$Label.c.Error_Persists_Contact')}` : '');

        $A.createComponents(
            [
                ["aura:html", {
                    tag: "span",
                    body: component.get('v.error.message') ?
                        `${$A.get('$Label.c.ERR001_ProductHoldingV2')} ` : `${$A.get('$Label.c.Auto_Loan_Product_holding_Request_Timeout')} `,
                }],
            ]
            .concat(Object.keys(error.messages)
                .filter(f => error.messages[f].isTimeout)
                .reduce((l, productType, index, arrays) => {
                    l.push(["aura:html", {
                        tag: "a",
                        HTMLAttributes: {
                            name: `${productType}Href`,
                            class: 'erorrProduct',
                            onclick: component.getReference('c.handleClickHref')
                        },
                        body: `${error.messages[productType].label}${arrays.length - 1 > index ? ', ':''}`,
                    }]);
                    return l;
                }, [])),
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.herfLink', cmp);
                }
            }
        );
        $A.createComponents(
            [
                ["aura:html", {
                    tag: "span",
                    body: messageTimeoutLink[0]
                }],
                ["aura:html", {
                    tag: "a",
                    HTMLAttributes: {
                        name: 'refreshView',
                        onclick: component.getReference('c.handleRefreshView')
                    },
                    body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
                }],
                ["aura:html", {
                    tag: "span",
                    body: messageTimeoutLink[1]
                }],
            ],
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.retry', cmp);
                }
            }
        );

    },
})