({
    callCYBProduct: function (component, event, helper) {
        // helper.resetAlertMessage(component);
        helper.getLoanProductCYB(component, event, helper,0);
        helper.getGuarantorCYB(component, event, helper,0);
    },
    decodeObject: function (objFields) {
        return objFields ? JSON.parse(decodeURIComponent(atob(objFields))) : null;
    },
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
    handleAlertError: function (component) {
        var helper = this;
        var error = component.get('v.error');
        component.set('v.error.title', 'Warning!');
        component.set('v.error.herfLink', '');
        component.set('v.error.retryMessage', '');
        component.set('v.error.message', '');
        component.set('v.error.state', Object.keys(error.messages)
            .reduce((l, i) =>
                // error.messages[i].isNoData != true &&
                (l ||
                    error.messages[i].isError ||
                    error.messages[i].isTimeout), false));

        if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isTimeout, false)) {
            helper.displayTimeoutMessage(component);
        } else if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isError, false)) {
            helper.displayErrorMessage(component);
        }
    },
    displayErrorMessage: function (component, title, errMsg) {
        var error = component.get('v.error');
        $A.createComponents(
            [
                ["aura:html", {
                    tag: "div",
                    body: `${$A.get('$Label.c.ERR001_ProductHolding')}\n${$A.get('$Label.c.ERR001_DetailBelow')}\n`
                }]
            ].concat(Object.keys(error.messages)
                .filter(f => error.messages[f].isNoData != true && error.messages[f].isError)
                .filter(f => error.messages[f].isShow || error.messages[f].isShow === undefined)
                .reduce((l, productType, index, arrays) => {
                    l.push(["aura:html", {
                        tag: "a",
                        HTMLAttributes: {
                            name: `${productType}Href`,
                            class: 'notFound',
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
    displayTimeoutMessage: function (component) {
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
                            class: 'notFound',
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
                        onclick: component.getReference('c.retryCallout')
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
                    component.set('v.error.retryMessage', cmp);
                }
            }
        );
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    doWorkspaceAPI: function (component, tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.getTabInfo({
                tabId: tabId
            }).then(function (response) {
                workspaceAPI.setTabLabel({
                    tabId: response.tabId,
                    label: tabName,
                });
                workspaceAPI.setTabIcon({
                    tabId: response.tabId,
                    icon: "standard:product",
                    iconAlt: tabName,
                });
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    getLoanProductDetailsView: function (component, event, helper,round) {
        helper.startSpinner(component);
        var action = component.get('c.getLoanProductDetail');
        action.setParams({
            'rmId': component.get('v.RMID'),
            'fiiDent': component.get('v.Fiident'),
            'accountNumber': component.get('v.AccountNumber'),
            'accountType': component.get('v.accountType'),
            'tmbCustId': component.get('v.tmbCustId'),
            'recordId': component.get('v.recordId'),
            'resultFrom01': component.get('v.product'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    if (result.StatusCode) {
                        if(result.StatusCode == '401' && round < component.get('v.numOfRetryTime')){
                            round += 1;
                            setTimeout(() => {
                                helper.getLoanProductDetailsView(component,event,helper, round);
                            }, component.get('v.retrySetTimeOut'));
                        }else{
                            component.set('v.error.messages.LoanInfo', {
                                isShow: true,
                                isError: !result.Timeout,
                                isTimeout: result.Timeout ? result.Timeout : false,
                                isLoading: component.get('v.error.messages.LoanInfo.isLoading'),
                                message: result.Message ? result.Message : '',
                                label: $A.get('$Label.c.Loan_Info'),
                            });
                            if (result.Timeout ? result.Timeout : false) {
                                    component.set('v.error.retry', [...new Set(component.get('v.error.retry')
                                        .concat('OSC04')
                                    )]);
                            }
                            helper.generateValue(component, helper, result);
                            helper.handleAlertError(component);
                            helper.stopSpinner(component);
                        }
                      
                    } else {
                        component.set('v.error.messages.LoanInfo', {})
                        component.set('v.AcctType',result.AcctType);
                        helper.generateValue(component, helper, result);
                        helper.handleAlertError(component);
                        helper.stopSpinner(component);
                    }
                }
            } else {
                helper.stopSpinner(component);
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
            }
        });
        $A.enqueueAction(action);
    },

   
    getLoanProductCYB: function (component, event, helper,round) {
        component.set('v.error.messages.LoanInfo.isLoading', true);
        component.set('v.error.messages.CYB.isLoading', true);
        var action = component.get('c.getCYBDetail');
        action.setParams({
            'accountNumber': component.get('v.AccountNumber'),
            'recordId': component.get('v.recordId'),
            'tmbCustId': component.get('v.tmbCustId')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.StatusCode && result.StatusCode == '401' && round < component.get('v.numOfRetryTime')){
                    round += 1;
                    setTimeout(() => {
                        helper.getLoanProductCYB(component,event,helper, round);
                    }, component.get('v.retrySetTimeOut'));
                }else{
                    var error = {};
                    var product = result.VehicleInformation;

                    error.isSuccess = product.isSuccess;
                    error.isError =  product.isError;
                    error.isTimeout =  product.isTimeout;
                    error.isLoading = true;
                    error.message = product.Message ? product.Message : '';
                    error.label =  $A.get('$Label.c.VehicleInformation');
    
                    component.set('v.error.messages.CYB', error);
                    component.set('v.error.messages.LoanInfo.isLoading', false);
    
                    if (error.isError) {
                        component.set('v.error.retry', [...new Set(component.get('v.error.retry')
                            .concat('CYB')
                        )]);

                        helper.displayTimeoutMessage(component, 'Warning!', error.message);
                    }
    
                    [{
                            key: 'v.fields.LoanInformation',
                            type: 'CYB',
                            section: 'LoanInfo'
                        },
                        {
                            key: 'v.fields.VehicleInformation',
                            type: 'CYB',
                            section: 'CYB'
                        },
                    ].forEach(e => {
                    var isNoExistingValue = false; 
                        component.get(e.key)
                            .filter(f => f.productType == e.type)
                            .forEach(p => {
                                p.value = product[p.fieldName];
                                p.class = p.value != $A.get('$Label.c.ERR008') ? '' : 'notFound'
                                
                                // Remove product type on erorr section
                                isNoExistingValue = (isNoExistingValue || product[p.fieldName] === "" || product[p.fieldName] === undefined)
                            });
                        component.set(`v.error.messages.${e.section}.isShow`, component.get(`v.error.messages.${e.section}.isShow`) || isNoExistingValue);
                        component.set(e.key, component.get(e.key));
                    });
    
                    component.set('v.error.messages.CYB.isLoading', false);
                    helper.handleAlertError(component);
                }
               
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    getGuarantorCYB: function (component, event, helper,round) {
        component.set('v.error.messages.Guarantor.isLoading', true);
        var action = component.get('c.getGuarantorDetail');
        action.setParams({
            'accountNumber': component.get('v.AccountNumber'),
            'recordId': component.get('v.recordId'),
            'tmbCustId': component.get('v.tmbCustId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.StatusCode && result.StatusCode == '401' && round < component.get('v.numOfRetryTime')){
                    round += 1;
                    setTimeout(() => {
                        helper.getGuarantorCYB(component,event,helper, round);
                    }, component.get('v.retrySetTimeOut'));
                }else{
                    var error = {};
                    error.isNoData = result.isNoData;
                    error.isError =  result.isError;
                    error.isTimeout =  result.isTimeout;
                    error.isLoading = true;
                    error.message = result.Message ? result.Message : '';
                    error.label =  $A.get('$Label.c.Guarantor');
                    var product = result;
                    component.set('v.guarantor', product.Guarantors ? product.Guarantors.map(m => {
                        return m;
                    }) : []);
    
                    component.set('v.error.messages.Guarantor', error);
                    if (error.isTimeout || error.isError) {
                        component.set('v.error.retry', [...new Set(component.get('v.error.retry')
                            .concat('Guarantor')
                        )]);
                        helper.displayTimeoutMessage(component, 'Warning!', error.message);
                    }
                    component.get('v.fields.Guarantor')
                        .filter(f => f.fieldName)
                        .forEach(m => {
                            m.value = ``;
                            m.class = `${m.class}`.replace(/(notFound)/g, '');
                        });
                    product.Guarantors
                        .reduce((list, item, index) => {
                            if (index >= 4) return list;
                            list.push(item);
                            return list;
                        }, [])
                        .forEach((e, index) => {
                            component.set(`v.fields.Guarantor.${(index * 4)}.value`, e.tha_fullname);
                            component.set(`v.fields.Guarantor.${(index * 4)}.class`, e.tha_fullname ==  $A.get('$Label.c.ERR008') ? 'notFound' :'' );
                            component.set(`v.fields.Guarantor.${(index * 4) + 1}.value`, e.id_no);
                            component.set(`v.fields.Guarantor.${(index * 4) + 1}.class`, e.id_no == $A.get('$Label.c.ERR008') ? 'notFound' :'' );
                            component.set(`v.fields.Guarantor.${(index * 4) + 2}.value`, e.id_birth_date);
                            component.set(`v.fields.Guarantor.${(index * 4) + 2}.class`, e.id_birth_date ==  $A.get('$Label.c.ERR008') ? 'notFound' :'' );
                        });
                    component.set('v.error.messages.Guarantor.isLoading', false);
                    helper.handleAlertError(component);
                }
               

            }else {
                helper.stopSpinner(component);
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
            }
        })
        $A.enqueueAction(action);

    },
    generateValue: function (component, helper, result) {
        var product = component.get('v.product');
        helper.doWorkspaceAPI(component, product.MarkedLoanAccountNumber);

        var LoanPaymentInformation = result.LoanPaymentInformation;
        var LoanInformation = result.LoanProductDetail;
       
        const mappingField = [{
                key: 'v.fields.LoanInformation',
                value: product,
                isSuccess: true,
            },
            {
                key: 'v.fields.LoanInformation',
                value: LoanInformation,
                isSuccess: LoanInformation.Status == 'SUCCESS',
            },
            {
                key: 'v.fields.LoanPaymentInformation',
                value: LoanPaymentInformation,
                isSuccess: LoanPaymentInformation.Status == 'SUCCESS',
            },
        ];
        mappingField.forEach(function (v) {
            component.get(v.key)
                .filter(f => !f.productType)
                .forEach(function (m) {
                    m.value = v.value[m.fieldName];
                    m.class = v.value[m.fieldName] != $A.get('$Label.c.ERR008') ? '' : 'notFound'
                    return m;
                });
            
            component.set(v.key, component.get(v.key));                
        });

        if (result.CoBorrowerInformationStatus == 'SUCCESS') {
            var coBorrwerResult = result.CoBorrowerInformation;
            component.set('v.fields.CoBorrowerInformation', Array.isArray(coBorrwerResult) && coBorrwerResult ? coBorrwerResult.reduce(function (l, v, i) {
                l.push({
                    label: $A.get('$Label.c.Co_Borrower_Name') + ' ' + (i + 1),
                    fieldName: 'Name',
                    value: v.Name,
                    type: 'STRING',
                });
                l.push({
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                    value: v.Relationship,
                    type: 'STRING',
                });
                return l;
            }, []) : [{
                    label: $A.get('$Label.c.Co_Borrower_Name'),
                    fieldName: 'Name',
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                },
            ]);
       } else {
            component.set('v.fields.CoBorrowerInformation', [{
                    label: $A.get('$Label.c.Co_Borrower_Name'),
                    fieldName: 'Name',
                    type: 'STRING',
                    value: $A.get('$Label.c.ERR008'),
                    class: 'notFound',
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                    type: 'STRING',
                    value: $A.get('$Label.c.ERR008'),
                    class: 'notFound',
                },
            ]);
        }

        var InterestPlan = result.InterestPlan ? result.InterestPlan : [];
        component.set('v.InterestPlan.datas', InterestPlan.reduce(function (l, i) {
            l.push({
                'AccountNumber': i.AccountNumber,
                'Period': i.Period,
                'InterestRate': i.InterestRate
            });
            return l;
        }, []));
    },

   
})