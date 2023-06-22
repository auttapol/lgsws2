({
    doInit: function (component, event, helper) {

        helper.mapColumns(component, event, helper);
        helper.execAccessibleCusHold(component, event, helper);

        helper.calloutService(component, event, helper);
        helper.callProductGuarantor(component, event, helper);
    },
    doWorkspaceAPI: function (component, event, helper) {
        var tabName = component.get("v.markedca_no");
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

    startSpinner: function (component, num) {
        if (num == 1) {
            component.set('v.isLoadingFloorplan', true);
            this.ButtonPaginator(component);
        } else if (num == 2) {
            component.set('v.isLoadingGuarantor', true);
        }
    },
    stopSpinner: function (component, num) {
        if (num == 1) {
            component.set('v.isLoadingFloorplan', false);
            this.ButtonPaginator(component);
        } else if (num == 2) {
            component.set('v.isLoadingGuarantor', false);
        }
    },
    execAccessibleCusHold: function (component, event, helper) {
        component.set('v.product.columns', component.get('v.product.columns').map(function (m) {
            m.fieldName = m.isAccessible ? (component.get(`v.accessibleCusHold.${m.isAccessible}`) ? m.fieldName : 'Hidden') : m.fieldName;
            m.type = m.fieldName == 'Hidden' ? 'text' : m.type;
            return m;
        }));

        component.set('v.product.Guarantor', component.get('v.product.Guarantor').map(function (m) {
            m.fieldName = m.isAccessible ? (component.get(`v.accessibleCusHold.${m.isAccessible}`) ? m.fieldName : 'Hidden') : m.fieldName;
            m.type = m.fieldName == 'Hidden' ? 'STRING' : m.type;
            m.value = m.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '';
            return m;
        }));
    },
    calloutService: function (component, event, helper) {
        /*
            1. get limit
            2. get product
         */
        var action = component.get('c.getAppConfigMdtByKey');
        action.setParams({
            'key': 'FloorplanDetail_LIMIT'
        });
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.limit', result ? parseInt(result) : 100);
                helper.callProductTable(component, event, helper);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    callProductTable: function (component, event, helper) {
        var limit = component.get('v.limit');
        var offset = component.get('v.offset');

        helper.startSpinner(component, 1);
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': `callout:AutoLoan_FloorplanDetail?limit=${limit}&offset=${offset}`,
            'callback': 'callbackFloorPlanDetail',
            'body': JSON.stringify({
                "fp_ca_no": component.get("v.ca_no")
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
                component.set('v.error.messages.AutoLoan_Floorplan.label', $A.get('$Label.c.Auto_Loan_Floor_Plan'));
                component.set('v.error.messages.AutoLoan_Floorplan.isError', result['isError'] || result['isThrow'] ? true : false);
                component.set('v.error.messages.AutoLoan_Floorplan.isTimeout', result['isTimeout'] ? true : false);
                $A.enqueueAction(component.get('c.handleAlertError'));

                helper.paginator(component, result);
                helper.mapFloorplanData(component, result ? result : []);
                helper.stopSpinner(component, 1);
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
                component.set('v.error.messages.AutoLoan_Floorplan.isError', true);
                helper.stopSpinner(component, 1);

            }

        });
        $A.enqueueAction(action);
    },
    paginator: function (component, result) {
        component.set('v.result', result);
        component.set('v.showPage', !result['isError'] && !result['isThrow'] && !result['isTimeout'] && (result.details ? result.details.length > 0 : false));
        // component.set('v.limit', component.get('v.result.paging.limit') ? component.get('v.result.paging.limit') : component.get('v.limit'));
        component.set('v.offset', component.get('v.result.paging.offset') ? component.get('v.result.paging.offset') : component.get('v.offset'));
        component.set('v.count', component.get('v.result.paging.count') ? component.get('v.result.paging.count') : component.get('v.count'));
        component.set('v.total_record', component.get('v.result.total_record') ? component.get('v.result.total_record') : component.get('v.total_record'));

        component.set('v.pageInfo',
            `(${component.get('v.offset') + 1} - ${component.get('v.offset') + component.get('v.count')} of ${component.get('v.total_record')})`);
        this.ButtonPaginator(component);
    },
    ButtonPaginator: function (component) {
        var previous = Array.isArray(component.find('previous')) ? component.find('previous') : [component.find('previous')];
        previous.forEach(cmp => {
            if (cmp) cmp.set('v.disabled', component.get('v.isLoadingFloorplan') || (component.get('v.offset') <= 0));
        });
        var next = Array.isArray(component.find('next')) ? component.find('next') : [component.find('next')];
        next.forEach(cmp => {
            if (cmp) cmp.set('v.disabled', component.get('v.isLoadingFloorplan') || (component.get('v.offset') + component.get('v.count') >= component.get('v.total_record')));
        });
    },
    callProductGuarantor: function (component, event, helper) {

        helper.startSpinner(component, 2);
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_Guarantor',
            'callback': 'callbackGuarantor',
            'body': JSON.stringify({
                "query": {
                    "acct_nbr": component.get('v.ca_no'),
                    "appl_code": "92"
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
                component.set('v.error.messages.Guarantor.isError', result['isError'] || result['isThrow'] ? true : false);
                component.set('v.error.messages.Guarantor.isNoData', result.isNoData ? result.isNoData : false);
                component.set('v.error.messages.Guarantor.isTimeout', result.isTimeout ? true : false);
                $A.enqueueAction(component.get('c.handleAlertError'));

                helper.mapDataGuarantor(component, result ? result : {});
                helper.stopSpinner(component, 2);
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
                component.set('v.error.messages.Guarantor.isError', true);
                helper.stopSpinner(component, 2);
            }
        });
        $A.enqueueAction(action);
    },

    mapColumns: function (component, event, helper) {
        component.set('v.product.columns', [{
                label: 'No.',
                fieldName: 'No.',
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
                label: $A.get("$Label.c.Effective_Date_AutoLoan"),
                fieldName: 'Effective_Date_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.T_S_No"),
                fieldName: 'T_S_No',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'center',
                },
                isAccessible: 'isAccessibleCusHoldHig',
            }, {
                label: $A.get("$Label.c.VIN"),
                fieldName: 'VIN',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'left',
                },
                fixedWidth: 220,
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.Engine"),
                fieldName: 'Engine',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'left'
                },
                fixedWidth: 200,
                isAccessible: 'isAccessibleCusHoldLow',
            }, {
                label: $A.get("$Label.c.License_Plate"),
                fieldName: 'License_Plate',
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
                label: $A.get("$Label.c.Make"),
                fieldName: 'Make',
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
                label: $A.get("$Label.c.Principle"),
                fieldName: 'MarkPrinciple',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                fixedWidth: 100,
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get("$Label.c.of_Days_in_Floor_Plan"),
                fieldName: 'of_Days_in_Floor_Plan',
                type: 'number',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                isAccessible: 'isAccessibleCusHoldLow',
            },
            {
                label: $A.get("$Label.c.Outstanding_Balance_AutoLoan"),
                fieldName: 'MarkOutstanding_Balance_AutoLoan',
                type: 'text',
                cellAttributes: {
                    class: {
                        fieldName: 'ERROR'
                    },
                    alignment: 'right'
                },
                isAccessible: 'isAccessibleCusHoldLow',
            }
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : 140;
            }
            return m;
        }));

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
    mapFloorplanData: function (component, data) {
        var methodUtils = component.find('methodUtils');
        component.set('v.product.datas', data.details ? data.details.reduce((l, product, index) => {
            l.push({
                'No.': component.get('v.offset') + 1 + index,
                'Effective_Date_AutoLoan': $A.get("$Locale.language") == 'th' ? product.eff_date_th : product.eff_date,
                'T_S_No': product.fp_ts_no,
                'VIN': product.chassis_no,
                'Engine': product.engine_no,
                'License_Plate': product.license_no,
                'Make': product.make_desc,
                'Principle': product.prin_amt,
                'of_Days_in_Floor_Plan': product.loan_day,
                'Outstanding_Balance_AutoLoan': product.os_balance,
                'MarkPrinciple': methodUtils.markAmount(product.prin_amt),
                'MarkOutstanding_Balance_AutoLoan': methodUtils.markAmount(product.os_balance),
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            });
            return l;
        }, []) : []);

        component.set('v.os_sum',
            data.os_balance ?
            `${$A.get('$Locale.currency')}${methodUtils.markAmount(data.os_balance)}` :
            '-'
        );
        // component.set('v.os_sum', `${$A.get('$Locale.currency')}${methodUtils.markAmount(parseFloat(component.get('v.os_balance')).toLocaleString('en-US', {
        //     style: 'decimal',
        //     minimumFractionDigits: 0,
        //     maximumFractionDigits: 0
        // }))}`);
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
                        console.log(index + '-->' + e.id_no);
                        component.set(`v.product.Guarantor.${(index * 4)}.value`, e.tha_fullname);
                        component.set(`v.product.Guarantor.${(index * 4) + 1}.value`, e.id_no);
                        component.set(`v.product.Guarantor.${(index * 4) + 2}.value`, e.id_birth_date);

                    });
            }
        }
    },

    handleErrorMessage: function (component) {
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

    }
})