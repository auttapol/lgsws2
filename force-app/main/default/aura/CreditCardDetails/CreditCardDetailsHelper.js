({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
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
    displayErrorMessage: function (component, title, errMsg) {
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
    doWorkspaceAPI: function (component, tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.getTabInfo({
                tabId: tabId
            }).then(function (response) {
                if (response.isSubtab) {
                    workspaceAPI.setTabLabel({
                        tabId: response.tabId,
                        label: tabName,
                    });
                    workspaceAPI.setTabIcon({
                        tabId: response.tabId,
                        icon: "standard:product",
                        iconAlt: tabName,
                    });
                }
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    CheckErrorMsg: function (component, helper, allRes) {
        var allRejected = allRes.filter(eachRes => eachRes.status == 'rejected');
        var allReason = allRejected.map(eachReason => eachReason.reason);
        var haveRejected = allRes.map(eachRes => eachRes.status == 'rejected' ? eachRes.reason : '' );
        var isServiceErr = allReason.some(res => res.includes('SNOW'))
        if (isServiceErr) {
            var error = $A.get('$Label.c.ERR001');
            helper.displayErrorMessage(component, 'Warning!', error);
        } else {
            var isTimeout = ['Read timed out', 'timeout', 'Timeout', '{0}'].some(substring => {
                return allReason.some(res => res.includes(substring))
            })
            var isNotFound = ['not found','No Active'].some(substring => {
                return allReason.some(res => res.includes(substring))
            })
            if (isNotFound) {
                var error = $A.get('$Label.c.INT_No_Active_Product');
                helper.displayErrorMessage(component, 'Warning!', error);
            } else {
                if(isTimeout) {
                    var isIndexTimeout =  haveRejected.map(res => { return res.includes('{0}') ? true : false })
                    var onRety;
                    if(isIndexTimeout[0] && !isIndexTimeout[1] && !isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetcard");
                    } else if(!isIndexTimeout[0] && isIndexTimeout[1] && !isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetunbilled");
                    } else if(!isIndexTimeout[0] && !isIndexTimeout[1] && isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetsummary");
                    } else if(isIndexTimeout[0] && isIndexTimeout[1] && !isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetcardAndGetUnbilled");
                    } else if(isIndexTimeout[0] && !isIndexTimeout[1] && isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetcardAndGetSummary");
                    } else if(!isIndexTimeout[0] && isIndexTimeout[1] && isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryGetUnbilledAndGetSummary");
                    } else if(isIndexTimeout[0] && isIndexTimeout[1] && isIndexTimeout[2]) {
                        onRety = component.getReference("c.onRetryCreditCard");
                    }

                    var error = $A.get('$Label.c.Product_Holding_ReRequest_v2');
                    var messageTimeout = error.split('{0}');
                    $A.createComponents(
                        [
                            ["aura:html", {
                                tag: "span",
                                body: messageTimeout[0]
                            }],
                            ["aura:html", {
                                tag: "a",
                                HTMLAttributes: {
                                    name: 'refreshView',
                                    onclick: onRety
                                },
                                body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
                            }],
                            ["aura:html", {
                                tag: "span",
                                body: messageTimeout[1]
                            }],
                        ],
                        function (cmp, status, errorMessage) {
                            if (status === "SUCCESS") {
                                // helper.displayErrorMessage(component, 'Warning!', cmp);
                                helper.displayErrorMessage(component, 'Warning!', cmp);
                            }
                        });
                }
            } 
        }
    },

    getCreditCardDetailsView: function (component, event, helper) {
        helper.startSpinner(component);
        var tmbCustId = component.get('v.tmbCustId');       
        
        // unmask creditcard
        var promiseGetCard = helper.callGetCardService(component, helper, tmbCustId);
        var promiseGetUnbilled = helper.callGetUnbilledService(component, helper, tmbCustId);
        var promiseGetSummary = helper.callGetSummaryService(component, helper, tmbCustId);
        Promise.allSettled([promiseGetCard, promiseGetUnbilled, promiseGetSummary])
        .then(function (callProduct) {
            helper.CheckErrorMsg(component, helper, callProduct);
            return 'Success';
            }
        )
        .catch(function (error) {
            return 'Error';
        })
        .then(function (PromiseMessage) {
            helper.stopSpinner(component);
        });
    },

    GetCardData: function (component, event, helper) {
        var tmbCustId = component.get('v.tmbCustId');
        helper.startSpinner(component);
        try {
            helper.callGetCardService(component, helper, tmbCustId)
            .then(function (callProduct) {
                helper.CheckErrorMsg(component, helper, callProduct);
                return 'Success';
                },
                function (error) {
                return 'Unsuccess';
                }
            )
            .catch(function (error) {
                return 'Error';
            })
            .then(function (PromiseMessage) {
                helper.stopSpinner(component);
            });
        } catch (error) {
            console.log('GetCard Promise try error', error);
        }
    },

    GetUnbilledData: function (component, event, helper) {
        var tmbCustId = component.get('v.tmbCustId');
        helper.startSpinner(component);
        try {
            helper.callGetUnbilledService(component, helper, tmbCustId)
            .then(function (callProduct) {
                helper.CheckErrorMsg(component, helper, callProduct);
                return 'Success';
                },
                function (error) {
                return 'Unsuccess';
                }
            )
            .catch(function (error) {
                return 'Error';
            })
            .then(function (PromiseMessage) {
                helper.stopSpinner(component);
            });
        } catch (error) {
            console.log('GetCardUnbilled Promise try error', error);
        }
    },

    GetSummaryData: function (component, event, helper) {
        var tmbCustId = component.get('v.tmbCustId');
        helper.startSpinner(component);
        try {
            helper.callGetSummaryService(component, helper, tmbCustId)
            .then(function (callProduct) {
                helper.CheckErrorMsg(component, helper, callProduct);
                return 'Success';
                },
                function (error) {
                return 'Unsuccess';
                }
            )
            .catch(function (error) {
                return 'Error';
            })
            .then(function (PromiseMessage) {
                helper.stopSpinner(component);
            });
        } catch (error) {
            console.log('GetSummary Promise try error', error);
        }
    },

    callGetCardService: function (component, helper, tmbCustId) {
        return new Promise($A.getCallback(function (res,rej) {
            var actionGetcard = component.get('c.getSCSCreditCard');
            actionGetcard.setParams({
                "account_id": component.get('v.account_id'),
                "tmbCustId": tmbCustId,
                "recordId" : component.get('v.recordId')
            });
            // var getCardData = {};
            actionGetcard.setCallback(this, function (response) {
                var state = response.getState();
                //test mock data
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var getCardData = result.result;
                    if(!result.Message){
                        getCardData.credit_card.balance_points.point_remain = parseFloat(getCardData.credit_card.balance_points.point_remain);
                        getCardData.credit_card.balance_points.expiry_points = parseFloat(getCardData.credit_card.balance_points.expiry_points);
                        getCardData.credit_card.card_balances.balance_credit_limit.available_to_transfer = parseFloat(getCardData.credit_card.card_balances.balance_credit_limit.available_to_transfer);
                        getCardData.credit_card.card_balances.balance_credit_limit.current = parseFloat(getCardData.credit_card.card_balances.balance_credit_limit.current);
                        getCardData.credit_card.card_balances.balance_credit_limit.total = parseFloat(getCardData.credit_card.card_balances.balance_credit_limit.total);
                        getCardData.credit_card.card_balances.current_balance = parseFloat(getCardData.credit_card.card_balances.current_balance);
                        getCardData.credit_card.card_credit_limit.temporary_credit_limit.amounts = parseFloat(getCardData.credit_card.card_credit_limit.temporary_credit_limit.amounts);
                        getCardData.credit_card.card_info.billing_cycle = parseFloat(getCardData.credit_card.card_info.billing_cycle);
                        getCardData.credit_card.card_status.stop_code = parseFloat(getCardData.credit_card.card_status.stop_code);
                        getCardData.credit_card.direct_deposit_account = parseFloat(getCardData.credit_card.direct_deposit_account);
                    }
                    

                    if (getCardData) {
                        helper.setCreditDetail(component, helper, getCardData, tmbCustId)
                        .then(function (callProduct) {
                            res(getCardData);
                            return 'Success';
                        }
                        )
                        .catch(function (error) {
                            return 'Error';
                        })
                    }
                    else {
                        var error = '';
                        var errorSavelogOrTimeout = false;
                        if (typeof result == 'string') {
                            var isTimeout = ['Read timed out', 'timeout', 'Timeout', '{0}'].some(substring => {
                                return result.includes(substring)
                            })
                            if (isTimeout) {
                                error = result;
                                errorSavelogOrTimeout = true;
                            } else if(result.includes('UNABLE_TO_LOCK_ROW')) {
                                errorSavelogOrTimeout = true;
                                helper.callGetCardService(component, helper, tmbCustId)
                                .then(function (callProduct) {
                                    res('Retry 1st time')
                                    return 'Success';
                                    },
                                    function (error) {
                                    rej(error)
                                    return 'Unsuccess';
                                    }
                                )
                                .catch(function (error) {
                                    rej($A.get('$Label.c.ERR001'))
                                    return 'Error';
                                })
                            }
                        } else {
                            error = result.Message;
                        }
                        // var error = $A.get('$Label.c.Product_Holding_Credit_Card_ReRequest');
                        if (!errorSavelogOrTimeout && !error) {
                            var error = $A.get('$Label.c.ERR001');
                        }
                        if (error != '') {
                            rej(error);
                        }
                    }
                } else {
                    // helper.setCreditDetail(component, helper, mockDataGetCard, tmbCustId);
                    var errorMsg = $A.get('$Label.c.ERR001');
                    rej(errorMsg);
                    // helper.stopSpinner(component);
                    var errors = response.getError();
                    helper.displayToast('error', errorMsg);
                    helper.displayErrorMessage(component, 'Warning!', errorMsg);
                    errors.forEach(function (error) {
                        console.log(error.message);
                    });
                }
            });
            $A.enqueueAction(actionGetcard);
        }));
    },

    callGetUnbilledService: function (component, helper, tmbCustId) {
        return new Promise($A.getCallback(function (res,rej) {
            var actionGetunbilled = component.get('c.getUnbilCreditCard');
                actionGetunbilled.setParams({
                    "account_id": component.get('v.account_id'),
                    "recordId": component.get('v.recordId'),
                    "tmbCustId": tmbCustId,
                });
                actionGetunbilled.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === 'SUCCESS') {
                        var result = response.getReturnValue();
                        var status = result.status;
                        if (status && status.status_code != 1) {
                            helper.generateUnbilledValue(component, helper, result);
                            res(result);
                        }
                        else {
                            var error = ''
                            var errorSavelogOrTimeout = false;
                            if (typeof result == 'string') {
                                var isTimeout = ['Read timed out', 'timeout', 'Timeout', '{0}'].some(substring => {
                                    return result.includes(substring)
                                })
                                if (isTimeout) {
                                    error = result;
                                    errorSavelogOrTimeout = true;
                                } else if(result.includes('UNABLE_TO_LOCK_ROW')) {
                                    errorSavelogOrTimeout = true;
                                    helper.callGetUnbilledService(component, helper, tmbCustId)
                                    .then(function (callProduct) {
                                        res('Retry 1st time')
                                        return 'Success';
                                        },
                                        function (error) {
                                        rej(error)
                                        return 'Unsuccess';
                                        }
                                    )
                                    .catch(function (error) {
                                        rej($A.get('$Label.c.ERR001'))
                                        return 'Error';
                                    })
                                }
                            } else {
                                error = result.Message;
                            }
                            // var error = $A.get('$Label.c.Product_Holding_Credit_Card_ReRequest');
                            if (!errorSavelogOrTimeout && !error) {
                                var error = $A.get('$Label.c.ERR001');
                            }
                            if (error != '') {
                                rej(error);
                            }
                        }
                    } else {
                        var errorMsg = $A.get('$Label.c.ERR001');
                        rej(errorMsg);
                        var errors = response.getError();
                        helper.displayToast('error', errorMsg);
                        helper.displayErrorMessage(component, 'Warning!', errorMsg);
                        errors.forEach(function (error) {
                            console.log(error.message);
                        });
                    }
                });
                $A.enqueueAction(actionGetunbilled);
        }))
    },

    
    callGetSummaryService: function (component, helper, tmbCustId) {
        return new Promise($A.getCallback(function (res,rej) {
            var actionGetsummary = component.get('c.getSummaryCreditCardData');
            actionGetsummary.setParams({
                "accountId": component.get('v.account_id'),
                'tmbCustId': tmbCustId,
                "recordId": component.get('v.recordId')
            });
            actionGetsummary.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var status_code = (result.status.code) ? result.status.code : "1";
                    if(result.creditCardInfo && !(Array.isArray(result.creditCardInfo))) {
                        result = result.creditCardInfo
                        helper.generatePayPlanRecordValue(component, helper, result);
                        res(result);
                    }
                    else if (result.status != null && (result.status.code == "201" || result.status.description.includes("record not found"))) {
                        result.paymentBehavior = '';
                        result.usageBehavior = '';
                        result.numberOfNonInterestChargeTransactions = '',
                        result.amountOfNonInterestChargeTransactions = '',
                        result.numberOfInterestChargeTransactions = '',
                        result.amountOfInterestChargeTransactions = '',
                        result.totalNumberOfTransactions = '',
                        result.totalAmountOfTransactions = '',
                        helper.generatePayPlanRecordValue(component, helper, result);
                        res(result);
                    }
                    else {
                        var error = ''
                        var errorSavelogOrTimeout = false;
                        if (typeof result == 'string') {
                            var isTimeout = ['Read timed out', 'timeout', 'Timeout', '{0}'].some(substring => {
                                return result.includes(substring)
                            })
                            if (isTimeout) {
                                error = result
                                errorSavelogOrTimeout = true;
                            } else if(result.includes('UNABLE_TO_LOCK_ROW')) {
                                errorSavelogOrTimeout = true;
                                helper.callGetSummaryService(component, helper, tmbCustId)
                                .then(function (callProduct) {
                                    res('Retry 1st time')
                                    return 'Success';
                                    },
                                    function (error) {
                                    rej(error)
                                    return 'Unsuccess';
                                    }
                                )
                                .catch(function (error) {
                                    rej($A.get('$Label.c.ERR001'))
                                    return 'Error';
                                })
                            }
                        } else {
                            error = ((result.Message) ? result.Message: result.status.description);
                        }
                        // var error = $A.get('$Label.c.Product_Holding_Credit_Card_ReRequest');
                        if (!errorSavelogOrTimeout && error == '') {
                            var error = $A.get('$Label.c.ERR001');
                        }
                        if (error != '') {
                            rej(error);
                        }
                    }
                } else {
                    var errorMsg = $A.get('$Label.c.ERR001')
                    rej(errorMsg);
                    var errors = response.getError();
                    helper.displayToast('error', errorMsg);
                    helper.displayErrorMessage(component, 'Warning!', errorMsg);
                    errors.forEach(function (error) {
                        console.log(error.message);
                    });
                }
            });
            $A.enqueueAction(actionGetsummary);
        }));
    },
    
    generateValue: function (component, helper, result) {
        helper.doWorkspaceAPI(component, component.get('v.product').MarkedCardNumber);
        var CreditCardRDCProduct = new Object();
        var isEmployee = false;
        var markedCreditLimit = '-'
        var markedCurrentBalance = '-'
        // result = result.credit_card;
        if(result.CreditCardRDCProduct) {
            CreditCardRDCProduct = result.CreditCardRDCProduct;
            isEmployee = CreditCardRDCProduct.isEmployee;
            markedCreditLimit = CreditCardRDCProduct.MarkedCreditLimit;
            markedCurrentBalance = CreditCardRDCProduct.MarkedCurrentBalance;
        } else {
            var error = $A.get('$Label.c.ERR001');
            helper.displayErrorMessage(component, 'Warning!', error);
        }
        // var isEmployee = true;
        result = {
            'CycleCut':        result.credit_card.card_info.billing_cycle,
            'CardExpiryDate':  result.credit_card.card_info.expired_by,
            'OpenedDate':      result.credit_card.card_info.created_date,
            'TemporaryLine': (result.credit_card.card_credit_limit.temporary_credit_limit.amounts).toLocaleString(),
            'RewardPoints': (result.credit_card.balance_points.point_remain).toLocaleString(),
            'NextExpiredPointOn': result.credit_card.balance_points.expiry_date,
            'NextExpiredPoints': (result.credit_card.balance_points.expiry_points).toLocaleString(),
            'PreviousExpiryDate': (result.credit_card.card_status.previous_expiry_date),
            'AcknowledgementDate': result.credit_card.card_status.activated_date,
            'UsageStatus':'',
            'MarkedCreditLimit': markedCreditLimit,
            'MarkedCurrentBalance': markedCurrentBalance,
            'LastPaymentDate': result.credit_card.card_balances.last_payment_date,
            // 'OpenedDate': helper.setDateFormat(result.credit_card.card_info.created_date),
            // 'LastPaymentDate': helper.setDateFormat(result.credit_card.card_balances.last_payment_date),
            // 'NextExpiredPointOn': helper.setDateFormat(result.credit_card.balance_points.expiry_date),
            // 'AcknowledgementDate': helper.setDateFormat(result.credit_card.card_status.activated_date),
        }       
        const mapVariableField = [
            {
                key: 'v.fields.CreditCardInfo',
                value: CreditCardRDCProduct
            },
            {
                key: 'v.fields.CreditCardInfo',
                value: result
            },
        ];
        helper.mapFields(component, helper, mapVariableField);
    },

    generatePayPlanRecordValue: function (component, helper, result) {
        helper.doWorkspaceAPI(component, component.get('v.product').MarkedCardNumber);
        var PayPlanRecord = {
            'NumberOfNonInterestChargeTransactions': (result.numberOfNonInterestChargeTransactions == '') ? '' : ((Number(result.numberOfNonInterestChargeTransactions)).toLocaleString()),
            'AmountOfNonInterestChargeTransactions': (result.amountOfNonInterestChargeTransactions == '') ? '' : ((Number(result.amountOfNonInterestChargeTransactions)).toLocaleString()),
            'NumberOfInterestChargeTransactions': (result.numberOfInterestChargeTransactions == '') ? '' : ((Number(result.numberOfInterestChargeTransactions)).toLocaleString()),
            'AmountOfInterestChargeTransactions': (result.amountOfInterestChargeTransactions == '') ? '' : ((Number(result.amountOfInterestChargeTransactions)).toLocaleString()),
            'TotalNumberOfTransactions': (result.totalNumberOfTransactions == '') ? '' : ((Number(result.totalNumberOfTransactions)).toLocaleString()),
            'TotalAmountOfTransactions': (result.totalAmountOfTransactions == '') ? '' : ((Number(result.totalAmountOfTransactions)).toLocaleString()),
        };
        result = {
            'PaymentBehavior': result.paymentBehavior,
            'UsageBehavior': result.usageBehavior
        }
        const mapVariableField = [
            {
                key: 'v.fields.CreditCardInfo',
                value: result
            },
            {
                key: 'v.fields.PayPlanRecord',
                value: PayPlanRecord
            },
        ];
        helper.mapFields(component, helper, mapVariableField);
    },

    generateUnbilledValue: function (component, helper, result) {
        helper.doWorkspaceAPI(component, component.get('v.product').MarkedCardNumber);
        result = {
            // 'PaymentDue': helper.setDateFormat(result.card_statement.due_date),
            'PaymentDue': result.card_statement.due_date,
            // ERROR1 : 'notFound',
            // isError : true,
            // 'PaymentDue': null
        }
        const mapVariableField = [
            {
                key: 'v.fields.CreditCardInfo',
                value: result
            },
        ];
        helper.mapFields(component, helper, mapVariableField);
    },
    makeValue: function (component, key, field) {
        var action = component.get('c.getMakeValue');
        action.setParams({
            'functionName': field.funcName,
            'value': field.valueTemp
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.get(key).find(function (f) {
                        return f.fieldName == field.fieldName;
                    }).value = result;
                    component.set('v.fields', component.get('v.fields'));
                }
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });

        if (field.valueTemp)
            $A.enqueueAction(action);
    },
    setCreditDetail: function (component, helper, data, tmbCustId) {
        return new Promise($A.getCallback(function (res) {
            var action = component.get('c.getCreditFormat');
            action.setParams({
                data: data,
                tmbCustId: tmbCustId,
                recordId: component.get('v.recordId'),
            });
            // Set up the callback
            action.setCallback(this, function(actionResult) {
                var result = actionResult.getReturnValue();
                if(result) {
                    helper.generateValue(component, helper, result);
                } else {
                    helper.generateValue(component, helper, data);
                }
                res('DONE');
            });
            $A.enqueueAction(action);
        }));

    },
    mapFields: function (component, helper, mapVariableField) {
        mapVariableField.forEach(function (v) {
            component.set(v.key, component.get(v.key).map(function (i) {
                if (i.type == 'PARSE') {
                    i.valueTemp = v.value[i.fieldKey];
                    helper.makeValue(component, v.key, i);
                } else if (v.value.hasOwnProperty(i.fieldName)) {                    
                    i.value = v.value[i.fieldName];
                    // i.value = i.value && i.type == 'DATE' ? (new Date(i.value.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g))).toLocaleDateString('en-EN') : i.value;
                }
                // Unmask CreditCard
                if(i.fieldName == "CurrentBalance" || i.fieldName == "CreditLimit"){
                    i.value = (typeof(i.value) == "string" && !isNaN(Number(i.value))) ? Number(i.value) : i.value;
                    i.value = !isNaN(i.value)?i.value.toLocaleString("en-US",{minimumFractionDigits: 2,maximumFractionDigits: 2}):i.value;
                 }

                return i;
            }));
        });
    },

    setDateFormat: function (value) {
        if (value == '' || value == '0000-00-00') {
            return ""
        } 
        return $A.localizationService.formatDate(value, "DD/MM/YYYY")
    },

    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermark");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
    
})