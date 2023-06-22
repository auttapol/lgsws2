({
    doInitErrorMessageControl: function (component, event, helper) {
        var errorMessageControlObj = {
            showMessage: false,
            someInfoError: false,
            noTmbcust: false,
            message: '',
            productName: {
                OSC: $A.get('$Label.c.Deposit_Product_Details') + ', ' + $A.get('$Label.c.Loan_Product_Details') + ', ' + $A.get('$Label.c.Investment_Product_Details') + ' ',
                Deposit: $A.get('$Label.c.Deposit_Product_Details'),
                Loan: $A.get('$Label.c.Loan_Product_Details'),
                Bancassurance: $A.get('$Label.c.Bancassurance_Product_Details'),
                Investment: $A.get('$Label.c.Investment_Product_Details'),
                AutoLoan : $A.get('$Label.c.Auto_loan_HP'),
                retry: ''
            },
            productTag: {
                OSC: $A.get('$Label.c.Deposit_Product_Details') + ', ' + $A.get('$Label.c.Loan_Product_Details') + ', ' + $A.get('$Label.c.Investment_Product_Details') + ' ',
                Deposit: 'Deposit_Product_Details',
                Loan: 'Loan_Product_Details',
                Bancassurance: 'Bancassurance_Product_Details',
                Investment: 'Investment_Product_Details',
                AutoLoan : 'Auto_Loan_Product_Details'
            },
            isShowMessage: {
                Snow: false,
                Retry: false,
                Info: false
            },
            messages: {
                Snow: $A.get('$Label.c.ERR001_ProductHolding'),
                Retry: '',
                Info: $A.get('$Label.c.INT_Investment_Incomplete_Info'),
                tryContact: $A.get('$Label.c.Error_Persists_Contact'),
            },
            timeout: {
                OSC: false,
                Deposit: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
                AutoLoan: false
            },
            error: {
                OSC: false,
                Deposit: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
                AutoLoan: false
            },
            retry: {
                OSC: false,
                Bancassurance: false,
                AutoLoan: false
            },
            products: [],
            productErrors: {
                DepositProduct          : {},
                LoanProduct             : {},
                InvestmentProduct       : {},
                BancassuranceProduct    : {},
                AutoLoan                : {},
            },
            noAuthorized: false,
            hrefList: ''
        }
        component.set("v.errorMessageControl", errorMessageControlObj);
    },

    getALDXWFMdt: function (component, event, helper) {
        return new Promise($A.getCallback(function (resolve, reject) { 

            var action = component.get('c.getALDXWFMdt');
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(result);
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });

            $A.enqueueAction(action);
        }));
    },

    getCoreHPCompany: function (component, event, helper) {

        return new Promise($A.getCallback(function (resolve, reject) { 

            var action = component.get('c.getAppConfigMdtByKey');
            action.setParams({
                'key': 'CoreHP_Company'
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(result);
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });

            $A.enqueueAction(action);
        }));
    },

    getRedProductcodeList: function (component, helper) {

        return new Promise($A.getCallback(function (resolve, reject) { 
            var action = component.get('c.getRedProductcode');
            action.setParams({});
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(result);
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        }));
    },
    /*Connect to Apex Class */

    /*START list of callout*/
    //DONE - Customer Account
    calloutCustomerAccount : function(component ,helper, round){
        
        var action = component.get('c.getProduct');
        var body     = {
            "GetCustomerAccountRequest": {
                "RMID"      : helper.getTTBCustomerId(component).substring(14),
                "FIIdent"   : helper.getTTBCustomerId(component).substring(0, 16)
            }
        };

        console.log('customer Id = ' + helper.getTTBCustomerId(component));
        action.setParams({
            'endpoint':  'callout:OSC01',
            'callback': 'advisory_callbackOSC01',
            'body': JSON.stringify(body),
            'ttbCustomerId': helper.getTTBCustomerId(component),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('calloutCustomerAccount');
                console.log(response.getReturnValue()); //To comment
            if (component.isValid() && state === "SUCCESS") {
                
                var result = response.getReturnValue();

                if (result.Timeout) {
                    helper.displayErrorMessage(component, 'Warning!', result.Message);
                    // timeout message
                    component.set('v.errorMessageControl.timeout.OSC', true);
                    helper.setIsLoadingProductOSC(component, false, true, true);
                } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                    round++;
                    console.log('retry  callProduct round: ', round, '| ', new Date());
                    setTimeout(() => {
                        helper.calloutCustomerAccount(component, helper, round);
                    }, component.get("v.retrySetTimeOut"));

                } else if ((result.StatusCode == "401") || (result.Message && (result.Message.toString().includes('Sorry, some error occurred') || result.Message.toString().includes('SNOW')))) {
                    helper.setIsLoadingProductOSC(component, false, true, true);
                    component.set('v.errorMessageControl.error.OSC', true);
                    component.set('v.errorMessageControl.message', result.Message);
                    helper.displayErrorMessage(component, 'Warning!', result.Message);
                } else if (result.Message && result.Message.toString().includes($A.get("$Label.c.INT_No_Active_Product"))) { //BAU11438_INC0179846                                                       
                    helper.setIsLoadingProductOSC(component, false, true, false);
                }

                if (result.DepositAccount) {

                    component.set('v.depositProduct.datas', helper.parseDepositProduct(component, result.DepositAccount.map(function (m) {
                        m.MarkedLedgerBalance = $A.get('$Label.c.Loading');
                        m.MarkedAvgOutStanding = '';
                        m.MarkedOutStanding = '';
                        return m;
                    })));
                    console.log('here');
                    console.log(component.get('v.depositProduct.datas'));
                    var OSC02lst = component.get('v.depositProduct.datas').reduce(function (l, i) {
                        l.push(helper.calloutDepositAccount(component, helper, i, 0));
                        return l;
                    }, []);

                    helper.promiseCustomerAccountData(component, helper, 'DepositAccount', OSC02lst, 0);
                }

                if (result.LoanAccount) {
                    component.set('v.loanProduct.datas', helper.parseLoanProduct(component, result.LoanAccount.map(function (m) {
                        m.ERROR1 = m.Status != 'UNKNOWN' ? '' : 'notFound';
                        m.MarkedOutstanding = $A.get('$Label.c.Loading');
                        m.MarkedVLimit = '';
                        return m;
                    })));

                    var osc04lst = component.get('v.loanProduct.datas').reduce(function (l, i) {
                        l.push(helper.calloutLoanAccount(component, helper, i, 0));
                        return l;
                    }, []);
                    helper.promiseCustomerAccountData(component, helper, 'LoanAccount', osc04lst, 0);
                }

                if (result.InvestmentAccount) {
                    component.set('v.investmentProduct.datas', helper.parseInvestmentProduct(component, result.InvestmentAccount.map(function (m) {
                        m.UnitHolderNo = m.UnitHoldNo;
                        m.FundCode = '';
                        m.ProductName = $A.get('$Label.c.Loading');
                        m.MarketValue = '';
                        m.UnrealizedGL = '';
                        return m;
                    })));

                    var osc06lst = component.get('v.investmentProduct.datas').reduce(function (l, i) {
                        l.push(helper.calloutInvestmentAccount(component, helper, i, 0));
                        return l;
                    }, []);
                    helper.promiseCustomerAccountData(component, helper, 'InvestmentAccount', osc06lst, 0);
                }
            }
            else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
                if ((errors[0].message == undefined || errors[0].message.toString().includes('UNABLE_TO_LOCK_ROW')) && !component.get('v.isAutoRetryOSC01')) {
                    component.set('v.isAutoRetryOSC01', true);
                    helper.setIsLoadingProductOSC(component, true, false, false);
                    helper.calloutCustomerAccount(component, helper, round);
                } else {
                    helper.setIsLoadingProductOSC(component, false, true, true);
                }

                helper.choiceErrorHandle(component, helper);
            }

            
        });

        $A.enqueueAction(action);
    },

    //DONE - BancassuranceAccount
    calloutBancassuranceAccount : function(component ,helper, round){
        var action = component.get('c.getProduct');
        var body     = {
            "GetBancassuranceAccountRequest": {
                "RMID"      : helper.getTTBCustomerId(component).substring(12)
            }
        };

        console.log('calloutBancassuranceAccount ==> '+ helper.getTTBCustomerId(component));
        return new Promise($A.getCallback(function (resolve, reject) { 
            action.setParams({
                'endpoint':  'callout:OSC05_List',
                'callback': 'advisory_callbackOSC05',
                'body': JSON.stringify(body),
                'ttbCustomerId': helper.getTTBCustomerId(component),
            });

            action.setCallback(this, function (response) {
               var state = response.getState();
               console.log('calloutBancassuranceAccount');
                    console.log(response.getReturnValue()); //To comment

                if (component.isValid() && state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    var DataSets = result.GetBancassuranceAccountResponse && result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse ? result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets : [];
                    console.log('calloutBancassuranceAccount | DataSets : ', DataSets);

                    if (result.StatusCode && (result.StatusCode != "200" || result.StatusCode != 200)) {
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Bancassurance', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                            
                            let dataList = [];
                            let data = DataSets.find(function (f) {
                                return f;
                            });
                            console.log('GetBancassurance | data : ', data);
                            if(DataSets.length > 0 || data != undefined){
                                dataList.push(data);
                            }
                            console.log('GetBancassurance | dataList : ', dataList);
                            component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                            component.set('v.bancassuranceProduct.isLoading', false);
                            component.set('v.bancassuranceProduct.isDone', true);
                            component.set('v.bancassuranceProduct.isError', true);
                            
                            helper.choiceErrorHandle(component, helper);

                        } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                            round++;
                            console.log('retry  calloutBancassuranceAccount round: ', round, '| ', new Date());

                            setTimeout(() => {
                                helper.calloutBancassuranceAccount(component, helper, round);
                            }, component.get("v.retrySetTimeOut"));

                        } else {
                            component.set('v.errorMessageControl.error.Bancassurance', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);

                            let dataList = [];
                            let data = DataSets.find(function (f) {
                                return f;
                            });
                            console.log('calloutBancassuranceAccount | data : ', data);
                            if(DataSets.length > 0 || data != undefined){
                                dataList.push(data);
                            }
                            console.log('calloutBancassuranceAccount | dataList : ', dataList);
                            component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                            component.set('v.bancassuranceProduct.isLoading', false);
                            component.set('v.bancassuranceProduct.isDone', true);
                            component.set('v.bancassuranceProduct.isError', true);
                            helper.choiceErrorHandle(component, helper);
                        }

                    } else {

                        let dataList = [];
                        let data = DataSets.find(function (f) {
                            return f;
                        });
                        console.log('calloutBancassuranceAccount | data : ', data);
                        if(DataSets.length > 0 || data != undefined){
                           dataList.push(data);
                        }
                        console.log('calloutBancassuranceAccount | dataList : ', dataList);
                        component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                        component.set('v.bancassuranceProduct.isLoading', false);
                        
                        component.set('v.bancassuranceProduct.isDone', true);
                        component.set('v.bancassuranceProduct.isError',false);
                        helper.choiceErrorHandle(component, helper);

                        resolve(result);
                    }
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    console.log('Error: BancassuranceAccount', errors);
                    component.set('v.bancassuranceProduct.isLoading', false);
                    component.set('v.bancassuranceProduct.isDone', true);
                    component.set('v.bancassuranceProduct.isError', true);
                    helper.choiceErrorHandle(component, helper);
                    reject(response.getError()[0]);
                }
            });

            $A.enqueueAction(action);
        }));
    },

    //DONE - Auto Loan
    calloutAutoLoan: function(component ,helper, round){
        component.set('v.autoLoanProduct.isLoading', true);
        return new Promise($A.getCallback(function (resolve, reject) { 
            console.log('------ calloutAutoLoan ------');
            var action = component.get('c.getAutoLoanProduct');

            action.setParams({
                'endpoint': 'callout:AutoLoan_HpFleetHpList',
                'callback': 'advisory_callbackAutoLoan',
                'body': JSON.stringify({
                    "Company": component.get('v.company'),
                    "RMID": helper.getTTBCustomerId(component),
                    "HPType": "HP",
                    "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                    "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
                }),
                'service': 'CoreHP',
                'state': {
                    'service': 'CoreHP',
                    'recordId': component.get("v.customerId"),
                    'tmbCustId': helper.getTTBCustomerId(component)
                },
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('calloutAutoLoan');
                console.log(response.getReturnValue()); //To comment
                if (component.isValid() && state === "SUCCESS") {
                    
                    var result = response.getReturnValue();

                    if(result.isTimeout){
                        component.set('v.errorMessageControl.timeout.AutoLoan', true);
                        component.set("v.autoLoanProduct.isLoading", false);
                        component.set('v.autoLoanProduct.isDone', true);
                        component.set('v.autoLoanProduct.isError', true);
                    }else if(result.isError || result.isThrow){
                        if(round < component.get("v.numOfRetryTime")){
                            component.set("v.autoLoanProduct.isLoading", true);
                            component.set('v.autoLoanProduct.isDone', false);
                            component.set('v.autoLoanProduct.isError', false);
                            round++;
                                setTimeout(() => {
                                    console.log('retry AutoLoan_HpFleetHpList round: ', round, '| ', new Date());
                                    helper.calloutAutoLoan(component, helper, round);
                            }, component.get("v.retrySetTimeOut"));
                        }else{
                            component.set('v.errorMessageControl.error.AutoLoan', true);
                            component.set("v.autoLoanProduct.isLoading", false);
                            component.set('v.autoLoanProduct.isDone', true);
                            component.set('v.autoLoanProduct.isError', true);
                        }
                    }else{
                        helper.parseAutoLoanListMappaing(component, result.Output ? result.Output : []);
                        component.set("v.autoLoanProduct.isLoading", false);
                        if(result.RES && result.RES.RESPONSECODE != "HP020"){
                            let productsDetail = component.get('v.autoLoanProduct.datas').reduce(function (l, i) {
                                // console.log('callProrductDetail | i : ' ,i)
                                l.push(helper.callAutoLoanHpFleetHpDetail(component, i , 0));
                                return l;
                            }, []);
        
                            helper.promiseAutoLoanData(component, helper, productsDetail, 0);
                        }else{
                            component.set("v.autoLoanProduct.isLoading", false);
                            component.set('v.autoLoanProduct.isDone', true);
                            component.set('v.autoLoanProduct.isError', false);
                            helper.parseAutoLoanListMappaing(component, result.Output ? result.Output : []);
                        }
                    }
                    helper.choiceErrorHandle(component, helper);
                    resolve(result);
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    component.set("v.autoLoanProduct.isLoading", false);
                    component.set('v.autoLoanProduct.isDone', true);
                    component.set('v.autoLoanProduct.isError', true);
                    helper.choiceErrorHandle(component, helper);
                    reject(errors[0]);
                }
            });

            $A.enqueueAction(action);
        }));
    },
    
    //DONE - AutoLoan Product Detail
    callAutoLoanHpFleetHpDetail: function (component, product, round) {
        // console.log('callAutoLoanHpFleetHpDetail | product: ' , product);
        return new Promise((res, rej) => {

            var action = component.get('c.getAutoLoanProduct');

            action.setParams({
                'endpoint': 'callout:AutoLoan_HpFleetHpDetail',
                'callback': 'advisory_callbackHpFleetHpDetail',
                'body': JSON.stringify({
                    "Company": component.get('v.company'),
                    "ContractNo": product.HP_Account_No,
                    "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                    "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
                }),
                'service': 'CoreHP',
                'state': {
                    'service': 'CoreHP',
                    'recordId':  component.get("v.customerId"),
                    'tmbCustId': helper.getTTBCustomerId(component)
                },
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                
                console.log('callAutoLoanHpFleetHpDetail');
                console.log(response.getReturnValue()); //To comment

                if (component.isValid() && state === 'SUCCESS') {

                    var result = response.getReturnValue();
                    if(result.HTTPStatusCode == "401" && round <= component.get("v.numOfRetryTime")){
                        let obj = {};
                        obj[product.ERROR] = 'retry';
                        res(obj);
                    }else{
                        let obj = {};
                        obj[product.HP_Account_No] =helper.getValueReference('Output.0', result);
                        
                        component.set("v.autoLoanProduct.isLoading", false);
                        component.set('v.autoLoanProduct.isDone', true);
                        component.set('v.autoLoanProduct.isError', false);
                        res(obj);
                    }
                } else {
                    var errors = response.getError(); 
                    errors.forEach(error => console.log(error.message));
                    component.set("v.autoLoanProduct.isLoading", false);
                    component.set('v.autoLoanProduct.isDone', true);
                    component.set('v.autoLoanProduct.isError', true);
                    rej(errors);
                }
            });

            $A.enqueueAction(action);
        })
    },

    //DONE - Deposit Account
    calloutDepositAccount : function(component ,helper, product, round){      
        return new Promise($A.getCallback(function (resolve, reject) { 
            
            console.log('calloutDepositAccount ==>');
            // console.log(product);
            var action = component.get('c.getProduct');
            var body     = {
                "GetDepositAccountRequest": {
                    "RMID": helper.getTTBCustomerId(component).substring(12),
                    "FIIdent": product.Fiident,
                    "AccountNumber": product.DepositAccountNumber,
                    "AccountType": product.AccountType,
                    "ProductType": product.ProductType,
                }
            };

            action.setParams({
                'endpoint':  'callout:OSC02',
                'callback': 'advisory_callbackOSC02',
                'body': JSON.stringify(body),
                'ttbCustomerId': helper.getTTBCustomerId(component),
            });

            action.setCallback(this, function (response) {
                console.log('calloutDepositAccount');
                console.log(response.getReturnValue()); //To comment
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    

                    var result = response.getReturnValue();
                    if (result && result.DepositeProduct && !['404', '500'].toString().includes(result.StatusCode)) {
                        //console.log('callProductOSC02 | result && result.DepositeProduct && ![\'404\', \'500\'].toString().includes(result.StatusCode)');
                        product.isError = result.GetDepositAccountResponse.AcctInqRs.Status.Severity.toString().includes('Error') ? true : false;
                        product.ODLimit = result.DepositeProduct.ODLimit;
                        product.OutStanding = result.DepositeProduct.OutStanding;
                        product.LedgerBalance = result.DepositeProduct.LedgerBalance;
                        product.AvgOutStanding = result.DepositeProduct.AvgOutStanding;
                        product.ERROR2 = !product.isError ? '' : 'notFound';
                        product.SeqGrp = product.SeqGrp ? product.SeqGrp : 'OTHERS';
                        product.productCodeMainbank = result.GetDepositAccountDetailResponse.Result.DepositAccount.ProductCode;

                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        product.ERROR1 = 'retry DepositAccount';
                        product.ERROR2 = '401';
                        product.isError = true;
                    } else {
                        product.MarkedLedgerBalance = '';
                        product.SeqGrp = 'OTHERS';
                        product.ERROR1 = 'notFound';
                        product.ERROR2 = 'notFound';
                        product.isError = true;
                        product.ProductName = '';
                        product.SubProductGroup = $A.get('$Label.c.ERR008');
                        product.Status = '';
                        product.HasJoint = '';
                        component.set('v.depositProduct.isDone', true);
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Deposit', true);
                        } else {
                            component.set('v.errorMessageControl.error.Deposit', true);
                        }
                    }

                    product.result = result;
                    component.set('v.depositProduct.datas', component.get('v.depositProduct.datas'));
                    resolve(product);
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log('get error', error.message);
                    });
                    reject(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });

            if (product.ERROR1 != 'notFound') {
                $A.enqueueAction(action);
            } else {
                product.MarkedLedgerBalance = '';
                product.SeqGrp = 'OTHERS';
                product.isError = true;
                product.SubProductGroup = $A.get('$Label.c.ERR008');
                resolve(product)
            }
        }));
    },

    //DONE - Loan Account
    calloutLoanAccount : function(component ,helper, product, round){
        console.log('calloutLoanAccount ==> '+ helper.getTTBCustomerId(component));
        var action = component.get('c.getProduct');
        var body     = {
            "GetLoanAccountRequest": {
                "RMID": helper.getTTBCustomerId(component).substring(12),
                "FIIdent": product.Fiident,
                "AccountNumber": product.AccountNumber,
                "AccountType": product.AccountType,
                "ProductType": ""
            }
        };

        return new Promise($A.getCallback(function (resolve, reject) { 
            action.setParams({
                'endpoint':  'callout:OSC04',
                'callback': 'advisory_callbackOSC04',
                'body': JSON.stringify(body),
                'ttbCustomerId': helper.getTTBCustomerId(component),
            });

            action.setCallback(this, function (response) {
                
                console.log('calloutLoanAccount');
                console.log(response.getReturnValue()); //To comment
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result && !['404', '500'].toString().includes(result.StatusCode) && result.LoanAccount) {
                        // console.log('callProductOSC04 | result && ![\'404\', \'500\'].toString().includes(result.StatusCode) && result.LoanAccount');
                        product.isError = result.GetLoanAccountResponse.AcctInqRs.Status.Severity.toString().includes('Error') ? true : false;
                        product.VLimit = result.LoanAccount.VLimit;
                        product.Outstanding = result.LoanAccount.Outstanding;
                        product.MuturityDate = result.LoanAccount.MuturityDate;
                        // product.MarkedVLimit = !product.isError && (result.LoanAccount.VLimit || result.LoanAccount.VLimit === 0) ? result.LoanAccount.VLimit.toLocaleString('en-US', {
                        //     style: 'decimal',
                        //     minimumFractionDigits: 0,
                        //     maximumFractionDigits: 0
                        // }) : $A.get('$Label.c.ERR008');
                        // product.MarkedOutstanding = !product.isError ? result.LoanAccount.MarkedOutstanding : $A.get('$Label.c.ERR008');

                        product.convertedMaturityDate = result.LoanAccount.convertedMaturityDate;
                        product.ERROR2 = !product.isError ? '' : 'notFound';
                        product.SeqGrp = product.SeqGrp ? product.SeqGrp : 'OTHERS';
                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        // console.log('callProductOSC04 | result.StatusCode == "401" && round < component.get("v.numOfRetryTime")');
                        //product.ERROR1 = 'retry';
                        product.ERROR1 = 'retry LoanAccount';
                        product.ERROR2 = '401';
                        product.isError = true;
                    } else {
                        // console.log('callProductOSC04 | else');
                        product.MarkedOutstanding = '';
                        product.SeqGrp = 'OTHERS';
                        product.ERROR1 = 'notFound';
                        product.ERROR2 = 'notFound';
                        product.isError = true;
                        product.ProductName = '';
                        product.SubProductGroup = $A.get('$Label.c.ERR008');
                        product.Status = '';
                        product.HasCoBorrower = '';
                        component.set('v.loanProduct.isDone', true);
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Loan', true);
                        } else {
                            component.set('v.errorMessageControl.error.Loan', true);
                        }
                    }

                    product.result = result;
                    component.set('v.loanProduct.datas', component.get('v.loanProduct.datas'));
                    resolve(product);
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();

                    errors.forEach(function (error) {
                        console.log(error.message)
                    });

                    reject(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });

            if (product.ERROR1 != 'notFound') {
                $A.enqueueAction(action);
            } else {
                product.MarkedOutstanding = '';
                product.SeqGrp = 'OTHERS';
                product.isError = true;
                product.SubProductGroup = $A.get('$Label.c.ERR008');
                resolve(product)
            }
        }));
    },

    //DONE - Investment Account
    calloutInvestmentAccount : function(component ,helper, product, round){
        console.log('calloutInvestmentAccount ==> '+ helper.getTTBCustomerId(component));
        var action = component.get('c.getProduct');
        var body     = {
            "GetInvestmentAccountRequest": {
                "UnitHolderNo": product.UnitHolderNo
            }
        };

        return new Promise($A.getCallback(function (resolve, reject) { 
            action.setParams({
                'endpoint':  'callout:OSC06_List',
                'callback': 'advisory_callbackOSC06List',
                'body': JSON.stringify(body),
                'ttbCustomerId': helper.getTTBCustomerId(component),
            });

            action.setCallback(this, function (response) {
               var state = response.getState();
               
               console.log('calloutInvestmentAccount');
               console.log(response.getReturnValue()); //To comment
                if (component.isValid() && state === "SUCCESS") {

                    var result = response.getReturnValue();
                    var UnitHolderNo = product.UnitHolderNo;
                    var productList = [];

                    if (result && !['404', '500'].includes(result.StatusCode) && result.GetInvestmentAccountResponse && result.InvestmentAccount.length > 0) {
                        // console.log('callProductOSC06List | if(result && ![\'404\', \'500\'].toString().includes(result.StatusCode))...');
                        // return product list
                        productList = result.InvestmentAccount.map(function (productObj) {
                            productObj.isError = !productObj.UnitHolderNo;
                            productObj.SeqGrp = !productObj.isError && productObj.ProductName != '#N/A' ? productObj.SeqGrp : 'OTHERS';
                            productObj.UnitHolderNo = !productObj.isError ? productObj.UnitHolderNo : UnitHolderNo;
                            productObj.FundCode = !productObj.isError ? productObj.FundCode : '';
                            productObj.ProductName = !productObj.isError ? productObj.ProductName : $A.get('$Label.c.ERR008');
                            productObj.AssetClass = !productObj.isError ? productObj.AssetClass : ''
                            productObj.IssuerFundHouse = !productObj.isError ? productObj.IssuerFundHouse : ''

                            productObj.NumberOfUnit = !productObj.isError ? productObj.NumberOfUnit : ''
                            productObj.NavUnit = !productObj.isError ? productObj.NavUnit : ''
                            productObj.CostOfInvestment = !productObj.isError ? productObj.CostOfInvestment : ''
                            productObj.AverageCostPerUnit = !productObj.isError ? parseFloat(productObj.AverageCostPerUnit) : ''
                            productObj.MarketValue = !productObj.isError ? productObj.MarketValue : ''
                            productObj.UnrealizedGL = !productObj.isError ? productObj.UnrealizedGL : ''
                            productObj.UnrealizedGLPerc = !productObj.isError ? productObj.UnrealizedGLPerc : ''

                            productObj.ERROR = productObj.isError ? 'notFound' : '';
                            productObj.UnitHolderNoClass = productObj.isError ? 'notFound' : '';
                            // console.log('callProductOSC06List | return productObj : ' , productObj);
                            return productObj;
                        });
                    } else if (result.StatusCode == '401' && round < component.get("v.numOfRetryTime")) {
                        // console.log('callProductOSC06List | if( result.StatusCode == \'401\' && round < component.get("v.numOfRetryTime")');
                        //product.ERROR = 'retry';
                        product.ERROR = 'retry InvestmentAccount';
                        product.isError = true;
                    } else {
                        product.SeqGrp = 'OTHERS';
                        product.UnitHolderNoClass = 'notFound';
                        product.ERROR = 'notFound';
                        product.isError = true;
                        product.ProductName = result.StatusCode == "200" && result.InvestmentAccountStatusCode == "200" ? $A.get('$Label.c.INT_Investment_Record_Not_Found') : $A.get('$Label.c.ERR008');
                        component.set('v.investmentProduct.isDone', true);
                        component.set('v.investmentProduct.isError', true);
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Investment', true);
                        } else {
                            component.set('v.errorMessageControl.error.Investment', true);
                        }
                    }

                    product.UnitHolderNo = UnitHolderNo;
                    product.result = helper.parseObj(result);

                    var selfIndex = component.get('v.investmentProduct.datas').findIndex(function (f) {
                        return f.UnitHolderNo == UnitHolderNo;
                    });

                    var isFirst = productList.length > 0 ? 1 : 0;

                    productList.forEach(function (v) {
                        component.get('v.investmentProduct.datas').splice(selfIndex != -1 ? selfIndex : 0, isFirst, productList.length > 0 ? v : product);
                        isFirst = 0;
                    })

                    component.set('v.investmentProduct.datas', component.get('v.investmentProduct.datas'));

                    resolve(productList.length > 0 ? productList : product);
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();

                    errors.forEach(function (error) {
                        console.log(error.message)
                    });

                    reject(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });

            $A.enqueueAction(action);
        }));
    },

    /*END List of callout*/

    //DONE - Promise Data
    promiseCustomerAccountData: function (component, helper, cmpRetryName, listProduct, round) {
        const depositAccName = 'DepositAccount';
        const loanAccName = 'LoanAccount';
        const InvestmentAccName = 'InvestmentAccount';

        Promise.all(listProduct).then(function (products) {
            //console.log('promiseCustomerAccountData | ' + cmpRetryName + ' | products : ' , products);
            round++;

            if (cmpRetryName.toString().includes(depositAccName)) {
                var depositAccToRetry = products.filter(f => f.isError == true && f.ERROR1.toString().includes(depositAccName));
                // console.log('promiseCustomerAccountData |  depositAccToRetry : ' , depositAccToRetry);

                if (depositAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    // console.log('promiseCustomerAccountData | Retry ' + cmpRetryName + ' round : ' + round);

                    var depositAccProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR1.toString().includes('retry')) {
                            l.push(helper.calloutDepositAccount(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, []);

                    setTimeout(() => {
                        helper.promiseCustomerAccountData(component, helper, cmpRetryName, depositAccProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    // console.log('promiseCustomerAccountData | ' + cmpRetryName + ' success');
                    component.set('v.depositProduct.datas', helper.parseDepositProduct(component, products));
                    component.set('v.depositProduct.isLoading', false);
                    component.set('v.depositProduct.isDone', true);
                    helper.checkIsSuccess(component);
                }
            } else if (cmpRetryName.toString().includes(loanAccName)) {
                var loanAccToRetry = products.filter(f => f.isError == true && f.ERROR1.toString().includes(loanAccName));
                // console.log('promiseCustomerAccountData | loanAccToRetry : ' , loanAccToRetry);

                if (loanAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    // console.log('promiseCustomerAccountData | Retry ' + cmpRetryName + ' round : ' + round);

                    var LoanAccProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR1.toString().includes('retry')) {
                            l.push(helper.calloutLoanAccount(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, []);

                    setTimeout(() => {
                        helper.promiseCustomerAccountData(component, helper, cmpRetryName, LoanAccProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    // console.log('promiseCustomerAccountData | ' + cmpRetryName + ' success');
                    component.set('v.loanProduct.datas', products);
                    component.set('v.loanProduct.isLoading', false);
                    component.set('v.loanProduct.isDone', true);
                    helper.checkIsSuccess(component);
                }

            } else if (cmpRetryName.toString().includes(InvestmentAccName)) {
                var investmentToRetry = products.filter(f => f.isError == true && f.ERROR.toString().includes(InvestmentAccName));
                // console.log('promiseCustomerAccountData | investmentToRetry : ' , investmentToRetry);

                if (investmentToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    // console.log('promiseCustomerAccountData | Retry ' + cmpRetryName + ' round : ' + round);

                    var InvestmentProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR == 'retry InvestmentAccount') {
                            l.push(helper.calloutInvestmentAccount(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, [])

                    setTimeout(() => {
                        helper.promiseCustomerAccountData(component, helper, cmpRetryName, InvestmentProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    // console.log('promiseCustomerAccountData | ' + cmpRetryName + ' success');    
                    products = products.reduce(function (list, item) {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                        return list;
                    }, []);
                    component.set('v.investmentProduct.datas',products);
                    component.set('v.investmentProduct.isLoading', false);
                    component.set('v.investmentProduct.isDone', true);
                    helper.checkIsSuccess(component);
                }
            }

            helper.choiceErrorHandle(component, helper);
        }, function (error) {
            console.log('Error: ' + cmpRetryName, error);
            if (cmpRetryName.toString().includes(depositAccName)) {
                component.set('v.depositProduct.isLoading', false);
                component.set('v.depositProduct.isDone', true);
                component.set('v.depositProduct.isError', true);
            } else if (cmpRetryName.toString().includes(loanAccName)) {
                component.set('v.loanProduct.isLoading', false);
                component.set('v.loanProduct.isDone', true);
                component.set('v.loanProduct.isError', true);
            } else if (cmpRetryName.toString().includes(InvestmentAccName)) {
                component.set('v.investmentProduct.isLoading', false);
                component.set('v.investmentProduct.isDone', true);
                component.set('v.investmentProduct.isError', true);
            }
            helper.choiceErrorHandle(component, helper);
        }).catch(function (error) {
            console.log('Error2: ' + cmpRetryName, error);
            if (cmpRetryName.toString().includes(depositAccName)) {
                component.set('v.depositProduct.isLoading', false);
                component.set('v.depositProduct.isDone', true);
                component.set('v.depositProduct.isError', true);
            } else if (cmpRetryName.toString().includes(loanAccName)) {
                component.set('v.loanProduct.isLoading', false);
                component.set('v.loanProduct.isDone', true);
                component.set('v.loanProduct.isError', true);
            } else if (cmpRetryName.toString().includes(InvestmentAccName)) {
                component.set('v.investmentProduct.isLoading', false);
                component.set('v.investmentProduct.isDone', true);
                component.set('v.investmentProduct.isError', true);
            }
            helper.choiceErrorHandle(component, helper);
        });
    },

    promiseAutoLoanData : function(component, helper, listProduct, round){
        return Promise.all(listProduct).then(function (products) {
            

            var productsToRetry = products.filter(f => f.ERROR != undefined && f.ERROR.toString().includes("retry"));

            if(productsToRetry.length > 0 && round <= component.get("v.numOfRetryTime")){
                // console.log('Retry products round : ',round);
                round++;
                var productsDetail = products.reduce(function (l, i) {
                    if(f.ERROR != undefined && i.ERROR1.toString().includes("retry")){
                        l.push(helper.callAutoLoanHpFleetHpDetail(component, i, round));
                    }else{
                        l.push(i);
                    }
                    return l;
                }, []);
    
                setTimeout(() => {
                    helper.promiseAutoLoanData(component, helper, productsDetail, round);
                }, component.get("v.retrySetTimeOut"));
            }else{
                component.set('v.autoLoanProduct.isDone', true);
                component.set('v.autoLoanProduct.isLoading', false);
                component.set('v.autoLoanProduct.datas', component.get('v.autoLoanProduct.datas').map((m, index) => {
                    m.ProductName = products[index][m.HP_Account_No] ? products[index][m.HP_Account_No].ProductCode : ''
                    return m;
                }));
                helper.checkIsSuccess(component);
            }
        }, function (error) {
            console.log('Error: ', error);
            component.set('v.autoLoanProduct.isDone', true);
            component.set('v.autoLoanProduct.isLoading', false);
            component.set('v.autoLoanProduct.isError', true);
        }).catch(function (error) {
            console.log(error);
            component.set('v.autoLoanProduct.isDone', true);
            component.set('v.autoLoanProduct.isLoading', false);
            component.set('v.autoLoanProduct.isError', true);
        });
    },

    /* parse data */
    parseDepositProduct: function (component, list) {
        return list ? list.reduce(function (l, i, index) {
            var checkAllFree = false;
            var listProdMDT = component.get('v.mainBankProductCode');
            if (i.productCodeMainbank != undefined) {
                // console.log('productCodeMainbank != null');
                for (var indexmdt = 0; indexmdt < listProdMDT.length; indexmdt++) {

                    if (i.productCodeMainbank == listProdMDT[indexmdt].Product_Code__c && i.OutStanding < 5000) { //
                        checkAllFree = true;
                    }
                }
            }
            // unmasked deposit dormant
            console.log('each product =' );
            console.log(i);
            l.push({
                'Type': $A.get('$Label.c.Deposit_Product_Details'),
                'Tag': 'Deposit_Product_Details',
                'SeqGrp': i.SeqGrp,
                'Fiident': i.Fiident,
                'AccountNumber': i.DepositAccountNumber,
                'AccountType': i.DepositProductCode,
                'ProductType': i.ProductType,
                'DepositAccountNumber': i.DepositAccountNumber,
                'MarkedDepositAccountNumber': i.MarkedDepositAccountNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'DepositProductCode' : i.DepositProductCode,
                'Status': i.Status,
                'ODLimit': i.ODLimit,
                'OutStanding': i.OutStanding,
                'LedgerBalance': i.LedgerBalance,
                'Other': i.Other,
                'HasJoint': i.HasJoint,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': checkAllFree ? 'notFound' : '',
                'ERRORLedger': checkAllFree ? 'notFoundLedger' : '',

                'isError': i.isError,
                'isAllFreeMin': checkAllFree ? 'ShowRed' : 'false'
            });
            return l;
        }, []) : [];
    },

    parseLoanProduct: function (component, list) {
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Loan_Product_Details'),
                'Tag': 'Loan_Product_Details',
                'SeqGrp': i.SeqGrp,
                'LoanAccountNumber': i.LoanAccountNumber,
                'ProductType': i.ProductType,
                'Fiident': i.Fiident,
                'AccountNumber': i.LoanAccountNumber,
                'AccountType': i.ProductType,
                'MarkedLoanAccountNumber': i.MarkedLoanAccountNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'ProductCode' : i.ProductCode,
                'Status': i.Status,
                'VLimit': i.VLimit,
                'Outstanding': i.Outstanding,
                'convertedMaturityDate': i.convertedMaturityDate,
                'MuturityDate': i.MuturityDate,
                'HasCoBorrower': i.HasCoBorrower,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2,
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },

    parseBancassuranceProduct: function (component, list) {
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Bancassurance_Product_Details'),
                'Tag': 'Bancassurance_Product_Details',
                'SeqGrp': '6',
                'POLICY_NO': i.POLICY_NO,
                'PRODUCT_GROUP': i.PRODUCT_GROUP,
                'ProductName': i.POLICY_NAME,
                'POLICY_NAME': i.POLICY_NAME,
                'INSURE_TYPE': i.INSURE_TYPE,
                'COMPANY_NAME': i.COMPANY_NAME,
                'EFFECTIVE_DATE': i.EFFECTIVE_DATE,
                'STATUS': i.STATUS,
                'SUM_INSURE': i.SUM_INSURE,
                'PREMIUM': i.PREMIUM,
                'EXPIRY_DATE': i.EXPIRY_DATE,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            });
            return l;
        }, []) : [];
    },

    parseInvestmentProduct: function (component, list) {
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Investment_Product_Details'),
                'Tag': 'Investment_Product_Details',
                'SeqGrp': i.SeqGrp,
                'UnitHolderNo': i.UnitHolderNo,
                'FundCode': i.FundCode,
                'ProductName': i.ProductName,
                'AssetClass': i.AssetClass,
                'IssuerFundHouse': i.IssuerFundHouse,
                'NumberOfUnit': i.isError ? '' : i.NumberOfUnit,
                'NavUnit': i.isError ? '' : i.NavUnit,
                'CostOfInvestment': i.isError ? '' : i.CostOfInvestment,
                'AverageCostPerUnit': i.isError ? '' : i.AverageCostPerUnit,
                'MarketValue': i.isError ? '' : i.MarketValue,
                'UnrealizedGL': i.isError ? '' : i.UnrealizedGL,
                'UnrealizedGLPerc': i.isError ? '' : i.UnrealizedGLPerc,
                'PercentWeight': i.isError ? '' : i.PercentWeight,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'UnitHolderNoClass': i.isError ? 'notFound' : '',
                'ERROR': i.isError ? 'notFound' : '',
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },

    parseAutoLoanListMappaing: function (component, data) {
        component.set('v.autoLoanProduct.datas', data
            .reduce((list, product, index) => {
                list.push({
                    'Type': 'Auto_Loan_Product_Details',
                    'Tag': 'Auto_Loan_Product_Details',
                    'SeqGrp': 'AutoLoan',
                    'Outstanding': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? 0 : parseFloat(product.OutstandingAmount),
                    'ODLimit': parseFloat(product.HPTotalAmount),
                    'No': index + 1,
                    'HP_Account_No': product.ContractNo,
                    'Status_AutoLoan': `${product.ContractStatusCode ? product.ContractStatusCode : ''} - ${product.ContractStatusName ? product.ContractStatusName : ''}`,
                    // unmasked 
                    'ProductCarType' : product.ProductCarType,
                    'ProductCode': product.ProductCode,
                    'HP_Amount': parseFloat(product.HPTotalAmount),
                    'Outstanding_Amount': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) :  Number(product.OutstandingAmount).toLocaleString("en-Us"),
                    'Installment_Amount': Number(product.Installment).toLocaleString("en-Us"),
                    'Remain_Period': product.NumberOfInstallmentBalance,
                    'Contract_Period': product.TotalInstallments,
                    'Paid_Period': product.CurrentOfInstallments,
                    'Overdue_No': product.OverdueNo,
                    'MarkedOverdue_Amount': component.get(`v.alds_wf.${product.ContractStatusCode}`) ? component.get(`v.alds_wf.${product.ContractStatusCode}.WARNING_MESSAGE__c`) :  Number(product.OverdueAmount).toLocaleString("en-Us"),
                    'Overdue_Amount': product.OverdueAmount,
                    'HUB': product.Channel,
                    'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                });
                return list;
            }, []));
    },

    errorCodeSCSIncludes: function (error_code, error_status) {
        var isInclude = false;
        // console.log('Check if error_code ==', error_code);
        error_status.forEach((e, i) => {
            if (e.error_code == error_code) {
                isInclude = true;
            }
            // console.log('error :', e.error_code, '==', error_code, 'is', isInclude);
        });
        return isInclude;
    },

    checkIsSuccess: function (component) {
        var isDoneLoading = !(
            component.get('v.depositProduct.isLoading') ||
            component.get('v.loanProduct.isLoading') ||
            component.get('v.bancassuranceProduct.isLoading') ||
            component.get('v.investmentProduct.isLoading') ||
            component.get('v.autoLoanProduct.isLoading')|| 
            [...new Set(component.get('v.errorMessageControl.products'))].reduce((l, productType) => l || (component.find(productType) && component.find(productType).get('v.isLoading')), false)
        );

        var isError = false;
        var isErrorState = component.get('v.error.state');
        var productErrors = component.get('v.errorMessageControl.productErrors');

        console.log('Check  Is Success');
        if(JSON.stringify(productErrors) != '{"DepositProduct":{},"LoanProduct":{},"InvestmentProduct":{},"BancassuranceProduct":{},"AutoLoan":{}}'){
            console.log('check product error');
            if(productErrors.DepositProduct){
                var isErrorDeposit = productErrors.DepositProduct.isError || productErrors.DepositProduct.isSomeError;
                component.set("v.depositProduct.isError", isErrorDeposit);
                isError = isErrorDeposit;
            }
    
            if(productErrors.LoanProduct){
                var isErrorLoan = productErrors.LoanProduct.isError || productErrors.LoanProduct.isSomeError;
                component.set("v.loanProduct.isError", isErrorLoan);
                isError = isErrorLoan;
            }
    
            if(productErrors.InvestmentProduct){
                var isErrorInvestment = productErrors.InvestmentProduct.isError || productErrors.InvestmentProduct.isSomeError;
                component.set("v.investmentProduct.isError", isErrorInvestment);
                isError = isErrorInvestment;
            }
    
            if(productErrors.BancassuranceProduct){
                var isErrorBanca = productErrors.BancassuranceProduct.isError || productErrors.BancassuranceProduct.isSomeError;
                component.set("v.bancassuranceProduct.isError", isErrorBanca);
                isError = isErrorBanca;
            }
    
            if(productErrors.AutoLoan){
                var isErrorAutoLoan = productErrors.AutoLoan.isError || productErrors.AutoLoan.isSomeError;
                component.set("v.autoLoanProduct.isError", isErrorAutoLoan);
                isError = isErrorAutoLoan;
            }
        }else{
            isError = (component.get('v.depositProduct.isError') ||
            component.get('v.loanProduct.isError') ||
            component.get('v.bancassuranceProduct.isError') ||
            component.get('v.investmentProduct.isError') ||
            component.get('v.autoLoanProduct.isError'))
        }
        var isSuccess =  isDoneLoading && !isError && !isErrorState;
        var isShowRetry = isDoneLoading && !isSuccess;
        component.set('v.isSuccess',isSuccess);
        component.set('v.showRetry', isShowRetry);

    },

    setIsLoadingProductOSC: function (component, status, isDone, isError) {
        console.log('----- handle cannot sync -----');
        component.set('v.depositProduct.isLoading', status);
        component.set('v.loanProduct.isLoading', status);
        component.set('v.investmentProduct.isLoading', status);

        component.set('v.depositProduct.isDone', isDone);
        component.set('v.loanProduct.isDone', isDone);
        component.set('v.investmentProduct.isDone', isDone);

        
        component.set('v.depositProduct.isError', isError);
        component.set('v.loanProduct.isError', isError);
        component.set('v.investmentProduct.isError', isError);
    },

    getTTBCustomerId: function (component) {
        //console.log(component.get('v.tmbCustId'));
        // return component.get('v.planningRecord.ttb_Customer_ID__c') ? component.get('v.planningRecord.ttb_Customer_ID__c') : component.get('v.tmbCustId');
        return component.get('v.tmbCustId');
    },

    displayErrorMessage: function (component, title, errMsg) {
        console.log('------ display error message ------');
        console.log(title);
        console.log(errMsg);
        component.set('v.error.state', true);
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.message', errMsg);
    },

    getValueReference : function (path, obj)  {
        let key = path.split('.')[0];
        if (path.toString().includes('.') && obj[key]) {
            return getValueReference(path.split('.').slice(1).join('.'), obj[key]);
        }
        return obj[key];
    },

    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    checkedServiceFromErrorMessageControl: function (checkObject) {
        return Object.keys(checkObject).reduce((l, key) => l || checkObject[key], false);
    },

    choiceErrorHandle: function (component, helper) {
        var errorControlObj = component.get('v.errorMessageControl');
        let checkObj = errorControlObj.timeout;
        errorControlObj.isShowMessage.Retry = helper.checkedServiceFromErrorMessageControl(checkObj);
        var componentRetry = [];

        if (errorControlObj.isShowMessage.Retry) {
            errorControlObj.retry.OSC = checkObj.Deposit || checkObj.Investment || checkObj.Loan || checkObj.OSC;
            errorControlObj.retry.Bancassurance = checkObj.Bancassurance;
            errorControlObj.retry.AutoLoan = checkObj.AutoLoan;
           

            [...new Set(errorControlObj.products)].forEach(e => {
                componentRetry.push(helper.createComponentProductReference(
                    component,
                    errorControlObj.timeout[e],
                    errorControlObj.productTag[e],
                    errorControlObj.productName[e],
                    'onClickHref'
                ));
            });
            component.set("v.showRetry", true);
            helper.setComponentRetry(component, $A.get('$Label.c.Product_Holding_ReRequest_v3'), componentRetry);
        }
        errorControlObj.isShowMessage.Snow = helper.checkedServiceFromErrorMessageControl(errorControlObj.error);
        errorControlObj.showMessage = errorControlObj.message ? true : false;
        component.set('v.errorMessageControl', errorControlObj);
        component.set('v.errorMessage', errorControlObj.message);
        helper.setInfoMessage(component, helper);

        errorControlObj = component.get('v.errorMessageControl');
        errorControlObj.isShowMessage.Info = errorControlObj.someInfoError && !(errorControlObj.isShowMessage.Retry) ? true : false;
        component.set('v.errorMessageControl', errorControlObj);
        component.set('v.errorMessage', errorControlObj.message);
        helper.checkIsShowErrorAfterChoice(component, errorControlObj);
        helper.checkIsSuccess(component);
    },

    setComponentRetry: function (component, message, componentRetry) {
        var messageTimeout = message.split('{1}');
        var messageTimeoutLink = messageTimeout[1].split('{0}');
        var componentMessage = [];
        component.set('v.errorMessageControl.messages.Retry', '');
        var componentComma = ["aura:html", {
            tag: "span",
            HTMLAttributes: {
                class: 'redText'
            },
            body: ', '
        }];
        var isNeedComma = false;
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeout[0]
        }]);
        componentRetry.forEach(e => {
            if (e[0]) {
                // console.log('componentRetry', e);
                if (isNeedComma) {
                    componentMessage.push(componentComma);
                }
                componentMessage.push(e);
                isNeedComma = true;
            }
        });
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeoutLink[0]
        }]);
        componentMessage.push(["aura:html", {
            tag: "a",
            HTMLAttributes: {
                name: 'refreshView',
                onclick: component.getReference("c.onClickRetry")
            },
            body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
        }]);
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeoutLink[1]
        }]);
        // console.log('componentMessage', componentMessage);
        $A.createComponents(
            componentMessage,
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.errorMessageControl.messages.Retry', cmp);
                }
            }
        );
    },

    setInfoMessage: function (component, helper) {
        var errorControlObj = component.get('v.errorMessageControl');
        if (errorControlObj.error.OSC) {
            var DepositProduct = {
                isError: true,
                isSomeError : false,
                Tag: "Deposit_Product_Details",
                Type: errorControlObj.productName.Deposit
            };
            var LoanProduct = {
                isError: true,
                isSomeError : false,
                Tag: "Loan_Product_Details",
                Type: errorControlObj.productName.Loan
            };
            var InvestmentProduct = {
                isError: true,
                isSomeError : false,
                Tag: "Investment_Product_Details",
                Type: errorControlObj.productName.Investment
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.DepositProduct = DepositProduct;
            productErrors.LoanProduct = LoanProduct;
            productErrors.InvestmentProduct = InvestmentProduct;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }
        if (errorControlObj.error.Bancassurance) {
            var BancassuranceProduct = {
                isError: true,
                isSomeError : false,
                Tag: "Bancassurance_Product_Details",
                Type: errorControlObj.productName.Bancassurance
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.BancassuranceProduct = BancassuranceProduct;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }

        if(errorControlObj.error.AutoLoan){
            var AutoLoan = {
                isError: true,
                isSomeError : false,
                Tag: "Auto_Loan_Product_Details",
                Type: errorControlObj.productName.AutoLoan
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.AutoLoan = AutoLoan;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }


        var updated_productErrors = component.get('v.errorMessageControl.productErrors');

        //for individual retry for each product
        var list = Object.keys(component.get('v.errorMessageControl.productErrors')).reduce((lst, key) => {
            lst.push(component.get(`v.errorMessageControl.productErrors.${key}`));
            return lst;
        }, [].concat(component.get('v.depositProduct.datas')
            .concat(component.get('v.creditCardRDCProduct.datas'))
            .concat(component.get('v.loanProduct.datas'))
            .concat(component.get('v.bancassuranceProduct.datas'))
            .concat(component.get('v.investmentProduct.datas'))
            .concat(component.get('v.autoLoanProduct.datas'))));

        // if (list.some(s => s.isError ? s.isError : false) || list.some(s => s.isTimeout ? s.isTimeout : false)) {
        //     if(s.Tag == 'Deposit_Product_Details'){
        //         updated_productErrors.DepositProduct.isSomeError = true; 
        //     }else if(s.Tag == 'Loan_Product_Details'){
        //         updated_productErrors.LoanProduct.isSomeError = true; 
        //     }else if(s.Tag == 'Bancassurance_Product_Details'){
        //         updated_productErrors.BancassuranceProduct.isSomeError = true; 
        //     }else if(s.Tag == 'Investment_Product_Details'){
        //         updated_productErrors.InvestmentProduct.isSomeError = true; 
        //     }else if(s.Tag == 'Auto_Loan_Product_Details'){
        //         updated_productErrors.AutoLoan.isSomeError = true; 
        //     }
        //     component.set('v.errorMessageControl.someInfoError', true);
        //     helper.displaySubErrorMessage(component, 'Warning!', $A.get('$Label.c.INT_Investment_Incomplete_Info'), 'someInfoError');
        // }

        component.set("v.errorMessageControl.productErrors", updated_productErrors);
    },

    displaySubErrorMessage: function (component, title, errMsg, type) {
        component.set('v.error.state', true);
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.messages.' + type, errMsg);
    },

    checkIsShowError: function (component) {
        component.set('v.error.state', (
            component.get('v.error.message') != '' ||
            component.get('v.error.messages.OSC01') != '' ||
            component.get('v.error.messages.Bancassurance') != '' ||
            component.get('v.error.messages.AutoLoan') != ''
            
        ));
    },

    checkIsShowErrorAfterChoice: function (component, errorObj) {
        component.set('v.error.state', (
            errorObj.isShowMessage.Info ||
            errorObj.isShowMessage.Retry ||
            errorObj.isShowMessage.Snow ||
            errorObj.noAuthorized
        ));
    },

    createAdvisoryPlanning : function(component, isHadProductHolding, planningItemList){
        console.log(component.get("v.recordId"));
        console.log('isHadProductHolding = ' + isHadProductHolding);
        console.log(JSON.stringify(planningItemList));
        
        return new Promise($A.getCallback(function (resolve, reject) { 

            var action = component.get('c.createAdvisoryPlanningItemHolding');
            action.setParams({
                'advisoryId': component.get("v.recordId"),
                'isHasProductHolding' : isHadProductHolding,
                'planningItemWrapperList' : planningItemList
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(result);
                } else {
                    var errors = response.getError();
                    reject(errors);
                }
            });

            $A.enqueueAction(action);
        }));
    },
    showToast : function(component, title, message, mode, toastType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : mode,
            "type" : toastType,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    parseProductHoldingToPlanning : function(component, helper){
        var depositList = component.get('v.depositProduct.datas');
        var investmentList = component.get('v.investmentProduct.datas');
        var loanList = component.get('v.loanProduct.datas');
        var bancassuranceList = component.get('v.bancassuranceProduct.datas');
        var autoLoanList = component.get('v.autoLoanProduct.datas');

        var returnList = [];
        var riskList   = [];
        var expenseList= [];

        var return_total_baseline = 0;
        var return_total_target   = 0;
        var risk_total_baseline   = 0;
        var risk_total_target     = 0;
        var expense_total_baseline = 0;
        var expense_total_target  = 0;
         
        //DONE DEPOSIT
        if(depositList && depositList.length > 0){
            for(var eachDeposit of depositList){
                var productName     = eachDeposit.ProductName;
                var productCode     = eachDeposit.DepositProductCode;
                var baselineAmount  = eachDeposit.OutStanding;
                var targetAmount    = eachDeposit.OutStanding;
                var planningItem    = helper.createAdvisoryPlanningItem('Return', 'DEPOSIT', eachDeposit.SubProductGroup, productName, productCode, baselineAmount, targetAmount);
                returnList.push(planningItem);
                return_total_baseline += parseFloat(baselineAmount);
                return_total_target   += parseFloat(targetAmount);
            }
        }
        //DONE - INVESTMENT
        if(investmentList && investmentList.length > 0){
            for(var eachInvestment of investmentList){
                var productName     = eachInvestment.ProductName;
                var productCode     = eachInvestment.FundCode;
                var baselineAmount  = eachInvestment.MarketValue;
                var targetAmount    = eachInvestment.MarketValue;
                var subGroup        = eachInvestment.SubProductGroup;
                subGroup            = ((subGroup) ? subGroup + '-' : '' )+ ((eachInvestment.AssetClass) ? eachInvestment.AssetClass : '');
                var planningItem    = helper.createAdvisoryPlanningItem('Return', 'INVESTMENT', subGroup , productName, productCode, baselineAmount, targetAmount);
                returnList.push(planningItem);
                return_total_baseline += parseFloat(baselineAmount);
                return_total_target   += parseFloat(targetAmount);
            }
        }

        //Expense & Liquidity - Loan
        if(loanList && loanList.length > 0){
            for(var eachLoan of loanList){
                var productName     = eachLoan.ProductName;
                var productCode     = eachLoan.ProductCode;
                var baselineAmount  = eachLoan.Outstanding;
                var targetAmount    = eachLoan.Outstanding;
                var planningItem    = helper.createAdvisoryPlanningItem('Expense & Liquidity', 'LOAN', eachLoan.SubProductGroup ,productName, productCode, baselineAmount, targetAmount);
                expenseList.push(planningItem);
                expense_total_baseline += parseFloat(baselineAmount);
                expense_total_target   += parseFloat(targetAmount);
            }
        }
        //Expense & Liquidity - Auto Loan
        if(autoLoanList && autoLoanList.length > 0){
            for(var autoLoan of autoLoanList){
                var productName = autoLoan.ProductCarType;
                var productCode = autoLoan.ProductCode;
                var baselineAmount = autoLoan.Outstanding;
                var targetAmount   = autoLoan.Outstanding;
                var planningItem    = helper.createAdvisoryPlanningItem('Expense & Liquidity', 'AUTO LOAN', '', productName, productCode, baselineAmount, targetAmount);
                expenseList.push(planningItem);
                expense_total_baseline += parseFloat(baselineAmount);
                expense_total_target   += parseFloat(targetAmount);
            }
        }

        //Risk
        if(bancassuranceList && bancassuranceList.length > 0){
            for(var eachInsurance of bancassuranceList){
                var productName  = eachInsurance.ProductName;
                var productCode = eachInsurance.INSURE_TYPE;
                var baselineAmount = eachInsurance.SUM_INSURE;
                var targetAmount   = eachInsurance.SUM_INSURE;
                var planningItem    = helper.createAdvisoryPlanningItem('Risk', 'BANCASSURANCE', '', productName, productCode, baselineAmount, targetAmount);
                riskList.push(planningItem);
                risk_total_baseline += baselineAmount;
                risk_total_target   += targetAmount
            }
        }

        
        //cal allocation %
        var finalAdvisoryItemList = [];
        if(returnList && returnList.length > 0){
            for(var eachReturn of returnList){
                if(return_total_baseline > 0) eachReturn.baselineAllocation = (parseFloat(eachReturn.baselineAmount) / parseFloat(return_total_baseline)).toFixed(4);
                if(return_total_target > 0) eachReturn.targetAllocation = (parseFloat(eachReturn.targetAmount) / parseFloat(return_total_target)).toFixed(4);
                finalAdvisoryItemList.push(eachReturn);
            }
        }

        if(expenseList && expenseList.length > 0){
            for(var eachExpense of expenseList){
                if(expense_total_baseline > 0) eachExpense.baselineAllocation = (parseFloat(eachExpense.baselineAmount) / parseFloat(expense_total_baseline)).toFixed(4);
                if(expense_total_target > 0) eachExpense.targetAllocation = (parseFloat(eachExpense.targetAmount) / parseFloat(expense_total_target)).toFixed(4);
                finalAdvisoryItemList.push(eachExpense);
            }
        }

        if(riskList && riskList.length > 0){
            for(var eachRisk of riskList){
                if(risk_total_baseline > 0) eachRisk.baselineAllocation = (parseFloat(eachRisk.baselineAmount) / parseFloat(risk_total_baseline)).toFixed(4);
                if(risk_total_target > 0) eachRisk.targetAllocation   = (parseFloat(eachRisk.targetAmount) / parseFloat(risk_total_target)).toFixed(4);
                finalAdvisoryItemList.push(eachRisk);
            }
        }

        return finalAdvisoryItemList;

    },

    createAdvisoryPlanningItem : function(itemType, family, subGroup, productName, productCode, baselineAmount, targetAmount){
        return {
            itemType : itemType,
            productName :  productName,
            family   : family,
            subGroup : subGroup,
            productCode : productCode,
            baselineAmount : (baselineAmount) ? parseFloat(baselineAmount) : 0,
            baselineAllocation :  0,
            targetAmount : (targetAmount) ? parseFloat(targetAmount) : 0,
            targetAllocation : 0
        }
    },
})