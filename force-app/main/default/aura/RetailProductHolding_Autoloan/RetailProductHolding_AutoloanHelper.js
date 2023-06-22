({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    isEmployee: function (component) {
        console.log('Is Employee : '+component.get('v.account.RTL_Is_Employee__c'));
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
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
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    setHeaderColumns: function (component) {
        // Defualt value datas
        component.set('v.product.datas', []);
        component.set('v.product.columns', [{
            label: $A.get("$Label.c.HP_Account_No"),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedHP_Account_No'
                },
                title: {
                    fieldName: 'MarkedHP_Account_No'
                },
                name: {
                    fieldName: 'MarkedHP_Account_No'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'left',
            },
            isAccessible: 'isAccessibleCusHoldHig',
            fixedWidth: 120,
        }, {
            label: $A.get("$Label.c.Status_AutoLoan"),
            fieldName: 'Status_AutoLoan',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'left',
            },
            isAccessible: 'isAccessibleCusHoldLow',
            fixedWidth: 200,
        }, {
            label: $A.get("$Label.c.HP_Amount"),
            fieldName: 'HP_Amount',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right',
            },
            isAccessible: 'isAccessibleCusHoldMid',
            //fixedWidth: 150,
        }, {
            label: $A.get("$Label.c.Outstanding_Amount"),
            fieldName: 'Outstanding_Amount',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            //fixedWidth: 200,
        }, {
            label: $A.get("$Label.c.Installment_Amount"),
            fieldName: 'Installment_Amount',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            //fixedWidth: 150,
        },
        {
            label: $A.get("$Label.c.Remain_Period"),
            fieldName: 'Remain_Period',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            fixedWidth: 110,
        },
        {
            label: $A.get("$Label.c.Contract_Period"),
            fieldName: 'Contract_Period',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            fixedWidth: 110,
        },
        {
            label: $A.get("$Label.c.Paid_Period"),
            fieldName: 'Paid_Period',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            fixedWidth: 110,
        },
        {
            label: $A.get("$Label.c.Overdue_Amount"),
            fieldName: 'MarkedOverdue_Amount',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            //fixedWidth: 140
        },
        {
            label: $A.get("$Label.c.HUB"),
            fieldName: 'HUB',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                // alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
            fixedWidth: 110,
        },
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : 140;
            }
            return m;
        }));
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
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },

    callProduct: function (component, event, helper, round) {
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
                // console.log(result);
                component.set('v.isTimeout', result.isTimeout ? true : false);
                component.set('v.isError', result.isError || result.isThrow ? true : false);
                helper.parseMappaing(component, result.Output ? result.Output : [],helper);
                // TODO Get product name callout to service detail
                
                if(result.HTTPStatusCode == "401" && round < component.get("v.numOfRetryTime")){

                    round++;
                    setTimeout(() => {
                        console.log('retry  AutoLoan_HpFleetHpList round: ', round, '| ', new Date());

                        helper.callProduct(component, event, helper, round);
                    }, component.get("v.retrySetTimeOut"));
                    
                }else{
                    helper.stopSpinner(component);

                    let productsDetail = component.get('v.product.datas').reduce(function (l, i) {
                        // console.log('callProrductDetail | i : ' ,i)
                        l.push(helper.callAutoLoanHpFleetHpDetail(component, i , 0));
                        return l;
                    }, []);

                    helper.promiseData(component, helper, event, productsDetail, 0);

                    helper.fireEventStatus(component, event, typeof result.isThrow === 'boolean' ? (!result.isThrow) : true);
                }
            } else {
                helper.fireEventStatus(component, event, false);
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
                helper.stopSpinner(component);
            }
        });

        var accessibleCusHold = component.get('v.accessibleCusHold');

        if (accessibleCusHold.isAccessibleCusHoldHig || accessibleCusHold.isAccessibleCusHoldMid || accessibleCusHold.isAccessibleCusHoldLow) {
            $A.enqueueAction(action);
        } else {
            helper.stopSpinner(component);
        }
    },

    promiseData : function(component, helper, event, listProduct, round){
        return Promise.all(listProduct).then(function (products) {
            // console.log('promiseData | products : ' , products);
            round++;

            var productsToRetry = products.filter(f => f.ERROR != undefined && f.ERROR.includes("retry"));
            // console.log('promiseData | productsToRetry : ' , productsToRetry);

            if(productsToRetry.length > 0 && round <= component.get("v.numOfRetryTime")){
                // console.log('Retry products round : ',round);
                var productsDetail = products.reduce(function (l, i) {
                    if(f.ERROR != undefined && i.ERROR1.includes("retry")){
                        l.push(helper.callAutoLoanHpFleetHpDetail(component, i, round));
                    }else{
                        l.push(i);
                    }
                    return l;
                }, []);
    
                setTimeout(() => {
                    helper.promiseData(component, helper, productsDetail, round);
                }, component.get("v.retrySetTimeOut"));
            }else{
                component.set('v.product.datas', component.get('v.product.datas').map((m, index) => {
                    m.ProductName = products[index][m.HP_Account_No] ? products[index][m.HP_Account_No].ProductCode : ''
                    return m;
                }));
            }
        }, function (error) {
            console.log('Error: ', error);
        }).catch(function (error) {
            console.log(error);
        });
    },

    callAutoLoanHpFleetHpDetail: function (component, product, round) {
        // console.log('callAutoLoanHpFleetHpDetail | product: ' , product);
        return new Promise((res, rej) => {

            var action = component.get('c.getProduct');

            action.setParams({
                'endpoint': 'callout:AutoLoan_HpFleetHpDetail',
                'callback': 'callbackHpFleetHpDetail',
                'body': JSON.stringify({
                    "Company": component.get('v.company'),
                    "ContractNo": product.HP_Account_No,
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
                // console.log('callAutoLoanHpFleetHpDetail | state : ',state)
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    // console.log('callAutoLoanHpFleetHpDetail | result : ',result)
                    if(result.HTTPStatusCode == "401" && round <= component.get("v.numOfRetryTime")){
                        // console.log('callAutoLoanHpFleetHpDetail | result.HTTPStatusCode == "401" && round <= component.get("v.numOfRetryTime")');
                        let obj = {};
                        obj[product.ERROR] = 'retry';
                        res(obj);
                        // console.log('callProrductDetail | obj (if): ' ,obj);
                    }else{
                        // console.log('callAutoLoanHpFleetHpDetail | else');
                        let obj = {};
                        obj[product.HP_Account_No] = component.find('methodUtils') ? component.find('methodUtils').getValueReference('Output.0', result) : '';
                        res(obj);
                        // console.log('callProrductDetail | obj (else): ' ,obj);
                    }
                } else {
                    var errors = response.getError();
                    // console.log('callAutoLoanHpFleetHpDetail | errors : ',errors); 
                    errors.forEach(error => console.log(error.message));
                    rej(errors);
                }
            });

            $A.enqueueAction(action);
        })
    },

    fireEventStatus: function (component, event, isSuccess) {
        var event = component.getEvent("RetailProductHoldingEvent");
        event.setParams({
            "productType": component.get('v.auraId'),
            "isSuccess": isSuccess == true ? true : false
        });
        event.fire();
    },
    parseMappaing: function (component, data,helper) {
        var methodUtils = component.find('methodUtils');
        // unmasked autoloan
        var IsUnmasked = component.get("v.unmasked");
        var IsALLogic = IsUnmasked == null || IsUnmasked['AutoLoan_Section'] == undefined;
        var IsInstallmentAmount = false;
        var IsOutstandingAmount = false;
        var IsHPTotalAmount = false;
        var IsOverdueAmount = false;
        var markedHPTotal;
        var markedOutstanding;
        var markedInstallment;

        if (!IsALLogic) {
            IsInstallmentAmount = IsUnmasked['AutoLoan_Section']['Installment_Amount'];
            IsOutstandingAmount = IsUnmasked['AutoLoan_Section']['Outstanding_Amount'];
            IsHPTotalAmount = IsUnmasked['AutoLoan_Section']['HP_Amount'];
            IsOverdueAmount = IsUnmasked['AutoLoan_Section']['MarkedOverdue_Amount'];
        }

       
        component.set('v.product.datas', data
            .reduce((list, product, index) => {
                markedHPTotal = IsALLogic ? methodUtils.markAmount(product.HPTotalAmount) : !IsHPTotalAmount ? methodUtils.markAmount(product.HPTotalAmount) : Number(product.HPTotalAmount).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                markedOutstanding =component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) : IsALLogic ? methodUtils.markAmount(product.OutstandingAmount) : (!IsOutstandingAmount) ? methodUtils.markAmount(product.OutstandingAmount) : Number(product.OutstandingAmount).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
                markedInstallment = IsALLogic ? methodUtils.markAmount(product.Installment) : (!IsInstallmentAmount) ? methodUtils.markAmount(product.Installment) : Number(product.Installment).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        
                list.push({
                    'SeqGrp': 'AutoLoan',
                    'Outstanding': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? 0 : parseFloat(product.OutstandingAmount),
                    'ODLimit': parseFloat(product.HPTotalAmount),
                    'No': index + 1,
                    'HP_Account_No': product.ContractNo,
                    'MarkedHP_Account_No': methodUtils.markAccountNo(product.ContractNo, 'xxxxxxxyyyyy'.substr(12 - `${product.ContractNo}`.length ? 12 - `${product.ContractNo}`.length : 0)),
                    // "ContractStatusCode": product.ContractStatusCode,
                    'Status_AutoLoan': `${product.ContractStatusCode ? product.ContractStatusCode : ''} - ${product.ContractStatusName ? product.ContractStatusName : ''}`,
                    // unmasked 
                    'HP_Amount': helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : markedHPTotal,
                    // 'HP_Amount': Number(product.HPTotalAmount).toLocaleString("en-Us", { minimumFractionDigits: 2 }),
                    // 'HPNetAmount': product.HPNetAmount,
                    // unmasked
                    'Outstanding_Amount': helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : markedOutstanding,
                    // 'Outstanding_Amount': Number(product.OutstandingAmount).toLocaleString("en-Us", { minimumFractionDigits: 2 }),
                    'Installment_Amount':  helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : markedInstallment,
                    // 'Installment_Amount': Number(product.Installment).toLocaleString("en-Us", { minimumFractionDigits: 2 }),
                    'Remain_Period': product.NumberOfInstallmentBalance,
                    'Contract_Period': product.TotalInstallments,
                    'Paid_Period': product.CurrentOfInstallments,
                    'Overdue_No': product.OverdueNo,
                    'MarkedOverdue_Amount': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) : IsALLogic ? methodUtils.markAmount(product.OverdueAmount) : (!IsOverdueAmount) ? methodUtils.markAmount(product.OverdueAmount) : Number(product.OverdueAmount).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                    // 'MarkedOverdue_Amount': Number(product.OverdueAmount).toLocaleString("en-Us", { minimumFractionDigits: 2 }),
                    'Overdue_Amount': product.OverdueAmount,
                    'HUB': product.Channel,
                    'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                });
                return list;
            }, []));
    },
    getIsUnmaskData: function (component, helper) {
        var action = component.get('c.getUnmaskBalance');
        var returnValue = "{}";
        var jsonData;
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            jsonData = JSON.parse(returnValue);
            component.set('v.unmasked', jsonData);

        });

        $A.enqueueAction(action);
    },

})