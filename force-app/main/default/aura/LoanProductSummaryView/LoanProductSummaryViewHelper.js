({
    doInitLoanProduct: function (component, event, helper) {
        component.set('v.loanProduct.columns', [{
            label: $A.get('$Label.c.Account_Number'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
                title: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
                name: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
        }, {
            label: $A.get('$Label.c.Status'),
            fieldName: 'Status',
            type: 'text',
            fixedWidth: 100,
        }, {
            label: $A.get('$Label.c.Outstanding_Deposit'),
            fieldName: 'MarkedOutstanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
        }, {
            label: $A.get('$Label.c.Limit'),
            fieldName: 'MarkedVLimit',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
        }, {
            label: $A.get('$Label.c.Contract_End_Date'),
            fieldName: 'convertedMaturityDate',
            type: 'text',
            initialWidth: 130,
        }, {
            label: $A.get('$Label.c.Has_Co_borrower'),
            fieldName: 'HasCoBorrower',
            type: 'text',
            initialWidth: 130,
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.initialWidth = ['SubProductGroup', 'ProductName'].includes(m.fieldName) ? 260 : 120;
            }
            return m;
        }));
        if(component.get('v.allowCallChild') == false){
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('LoanProductSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }

    },

    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
    },

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    getFieldVisibility: function (component, event, helper) {
        var action = component.get('c.getFieldVisibilityByPage');
        action.setParams({
            'recordId': component.get('v.recordId'),
            'pageName': 'RetailProductHoldingSummary'
        })
        var returnValue = "{}";
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            component.set('v.fieldAccessMap', returnValue);
        });

        $A.enqueueAction(action);
    },

    getProductOSC04: function(component,helper){
        const loanProductList = component.get('v.resultFrom01').LoanAccount ? component.get('v.resultFrom01').LoanAccount : [];
        component.set('v.loanProduct.datas', helper.parseLoanProduct(component, loanProductList.map(function (m) {
            if(m.MarkedOutstanding != $A.get('$Label.c.Data_Condition_Hidden_Text') && m.MarkedVLimit != $A.get('$Label.c.Data_Condition_Hidden_Text') ){
                m.ERROR1 = m.Status != 'UNKNOWN' ? '' : 'notFound';
                m.MarkedOutstanding = $A.get('$Label.c.Loading');
                m.MarkedVLimit = '';
            }
           
            return m;
        }),helper));
       
        var osc04lst = component.get('v.loanProduct.datas').reduce(function (l, i) {
            l.push(helper.callProductOSC04(component, helper, i, 0));
            return l;
        }, []);

        helper.promiseData(component, helper, osc04lst, 0);
        // helper.promiseData(component, helper, 'LoanAccount', osc04lst, 0);

    
    },

    callProductOSC04: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getLoanProductDetail');
            action.setParams({
                'loanProduct' : product,
                'recordId' : component.get('v.recordId'),
                'rmId' : helper.getTMBCustID(component).substring(12),
                'tmbCustId': helper.getTMBCustID(component),
                'mapUnmasked': component.get('v.unmasked'),
                'fieldAccessMap' : component.get('v.fieldAccessMap'),
                'isEmployee' : helper.isEmployee(component)
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result && !['404', '500'].includes(result.StatusCode) && result.LoanAccount) {
                        var loanResult = result.LoanAccount;
                        product.isError = loanResult.isError
                        product.MarkedVLimit = !loanResult.isError ? loanResult.MarkedVLimit : $A.get('$Label.c.ERR008');
                        product.MarkedOutstanding = !loanResult.isError ? loanResult.MarkedOutstanding : $A.get('$Label.c.ERR008');
                        product.VLimit = loanResult.VLimit;
                        product.Outstanding = loanResult.Outstanding;
                        product.convertedMaturityDate = loanResult.convertedMaturityDate;
                        product.ERROR2 = !loanResult.isError ? '' : 'notFound';
                        product.SeqGrp = loanResult.SeqGrp ? loanResult.SeqGrp : 'OTHERS';
                        product.Link = loanResult.Link;
                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        product.ERROR1 = 'retry LoanAccount';
                        product.ERROR2 = '401';
                        product.isError = true;
                    } else {
                        product.MarkedOutstanding = '';
                        product.MarkedVLimit = '';
                        product.SeqGrp = 'OTHERS';
                        product.ERROR1 = 'notFound';
                        product.ERROR2 = 'notFound';
                        product.isError = true;
                        product.ProductName = '';
                        product.SubProductGroup = $A.get('$Label.c.ERR008');
                        product.Status = '';
                        product.HasCoBorrower = '';
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Loan', true);
                        } else {
                            component.set('v.errorMessageControl.error.Loan', true);
                        }
                    }

                    product.result = result;
                    component.set('v.loanProduct.datas', component.get('v.loanProduct.datas'));
                    res(product);

                } else {
                    var errors = response.getError();

                    errors.forEach(function (error) {
                        console.log(error.message)
                    });

                    rej(errors.find(function (f) {
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
                res(product)
            }
        }));
    },

    promiseData: function (component, helper, listProduct, round) {
        const sendToParent = new Map();

        Promise.all(listProduct).then(function (products) {

            round++;
            var loanAccToRetry = products.filter(f => f.isError == true && f.ERROR1.includes('LoanAccount'));

            if (loanAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                var LoanAccProducts = products.reduce(function (l, i) {
                    if (i.isError == true && i.ERROR1.includes('retry')) {
                        l.push(helper.callProductOSC04(component, helper, i, round));
                    } else {
                        l.push(i);
                    }
                    return l;
                }, []);

                setTimeout(() => {
                    helper.promiseData(component, helper, LoanAccProducts, round);
                }, component.get("v.retrySetTimeOut"));

            } else {
                var parentComponent = component.get("v.parent");                         
                const displayData = helper.sortLoanProduct(helper.parseLoanProduct(component, products));
                component.set('v.loanProduct.datas', displayData);   
                
                if(component.get('v.errorMessageControl.timeout.Loan') == true){
                    sendToParent.set('LoanProductSummaryView', "timeout");
                    parentComponent.handleReturnData(sendToParent);
                }
                else if(component.get('v.errorMessageControl.error.Loan') == true){
                    sendToParent.set('LoanProductSummaryView', "error");
                    parentComponent.handleReturnData(sendToParent);
                }
                else {
                    // sendToParent.set('LoanProductSummaryView', component.get('v.loanProduct'));
                    const parseSum = helper.parseSummarizeProduct(component, helper, displayData);
                    parseSum.then((returnData) => {
                        sendToParent.set('LoanProductSummaryView', returnData);
                        parentComponent.handleReturnData(sendToParent);
                    });
                }
            }
        
        }).catch(function (error) {
            console.error(error);
        });
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var sevenList = helper.separateGrp(datas, '7');
            var eightList = helper.separateGrp(datas, '8');
            var otherList = helper.separateGrp(datas, 'OTHERS');
            var parseSeventh = helper.parseSeventhAndEigthObj(component, helper, sevenList, '7');
            parseSeventh.then((seventObj) => {
                var parseEight = helper.parseSeventhAndEigthObj(component, helper, eightList, '8');
                parseEight.then((eightObj) => {
                    var otherObj = helper.parseOthers(otherList);
                    resolve([seventObj, eightObj, otherObj])
                })
            })
        });
    },

    parseSeventhAndEigthObj: function(component, helper, topassList, seqGrp){
        return new Promise((resolve, reject) => {
            let isError = false;
            let account = [];
            let prod = [];
            let outStandingList = [0];
            let odLimitList = [0];
            topassList.forEach((e) => {
                if(!account.includes(e.AccountNumber)){
                    account.push(e.AccountNumber);
                    account = account.filter(x => x !== undefined);
                }
                if(!prod.includes(e.ProductName)){
                    prod.push(e.ProductName);
                    prod = prod.filter(x => x !== undefined);
                }
                if(e.isError == true){
                    isError = true;
                }
                outStandingList.push(e.OutStanding == undefined ? 0 : e.OutStanding);
                odLimitList.push(e.ODLimit == undefined ? 0 : e.ODLimit);
            });
            const toSumMap = {
                accountList: account,
                productList: prod,
                outStandingList: outStandingList,
                odLimitList: odLimitList
            }
            const prfun = helper.getSumOfMarkedOutstanding(component, toSumMap, seqGrp);
            prfun.then((sumMap) => {
                const returnObj = {
                    ERROR: isError == true ? 'notFound' : '',
                    SeqGrp: seqGrp,
                    Tag: sumMap['Tag'],
                    Product_Group: sumMap['Product_Group'],
                    Number_of_Product: sumMap['Number_of_Product'],
                    Number_of_Account: sumMap['Number_of_Account'],
                    MarkedOutstanding: sumMap['MarkedOutstanding'],
                    MarkedODLimit: sumMap['MarkedODLimit'],
                    Hidden: $A.get('$Label.c.Data_Condition_Hidden_Text'),
                    Number_of_Account_AUM: sumMap['Number_of_Account_AUM']
                }
                resolve(returnObj);
            });
        });
    },

    getSumOfMarkedOutstanding: function(component, toSumMap, seqGrp){
        return new Promise((resolve, reject) => {

            var IsUnmasked = component.get("v.unmaskedFromParent");
            var IsOutStanding = null;
            var IsODLimit = null;
            var IsOutStandingLimit = IsUnmasked == null || IsUnmasked["Summary_Section"] == undefined;
            if (!IsOutStandingLimit) {
                IsOutStanding = IsUnmasked["Summary_Section"]["SummaryString"];
                IsODLimit = IsUnmasked["Summary_Section"]["SummaryODLimit"];
            }

            var action = component.get('c.getSummarizedObj');
            action.setParams({
                'recordId': component.get('v.recordId'),
                'tmbCustId': component.get('v.account.TMB_Customer_ID_PE__c'),
                'isEncrypt': true,
                'seqGrp': seqGrp,
                'toSumMap': toSumMap,
                'summaryString': IsOutStanding,
                'summaryODLimit': IsODLimit,
                'isOutStandingLimit': IsOutStandingLimit
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(result);
                }
                else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message)
                    });
                    reject('error at getSummarizedObj');
                }
            });
            $A.enqueueAction(action);
        });
    },

    separateGrp: function(datas, seqNo){
        let seqList = [];
        datas.forEach((e) => {
            if(e.SeqGrp == seqNo){
                seqList.push(e);
            }
        });
        return seqList;
    }, 

    parseOthers: function(otherList){
        let account = [];
        otherList.forEach((e) => {
            if(!account.includes(e.AccountNumber)){
                account.push(e.AccountNumber);
            }
        });
        const otherObj = {
            ERROR: '',
            SeqGrp: 'OTHERS',
            Product_Group: 'Others',
            Number_of_Product: otherList.length,
            Number_of_Account: account.length,
            MarkedOutstanding: '-',
            MarkedODLimit:  '-',
            Hidden: $A.get('$Label.c.Data_Condition_Hidden_Text')
        }
        return otherObj;
    },

    sortLoanProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            return returnValue;
        });
    },

    getIsUnmaskData: function (component, helper) {
        var action = component.get('c.getUnmaskBalance');
        action.setParams({
            'sectionUnmask': 'Loan_Section'
        })
        var returnValue = "{}";
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            
            component.set('v.unmasked', returnValue);
        });

        $A.enqueueAction(action);
    },

    parseLoanProduct: function (component, list, helper) {
        return list ? list.reduce(function (l, i) {
            if(i.MarkedLoanAccountNumber == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                let columns = component.get('v.loanProduct.columns');
                columns[0] = {
                    label: $A.get("$Label.c.Account_Number"),
                    fieldName: 'MarkedLoanAccountNumber',
                    type: 'text',
                    cellAttributes: {
                        class: {
                            fieldName: 'ERROR'
                        },
                        alignment: 'left'
                    },
                    fixedWidth: 110,
                },
                component.set('v.loanProduct.columns', columns);
            }

            l.push({
                'Type': $A.get('$Label.c.Loan_Product_Details'),
                'Tag': 'Loan_Product_Details',
                'TabName': i.MarkedLoanAccountNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedOutstanding != $A.get('$Label.c.Loading') ? i.Link : '',
                'SeqGrp': i.SeqGrp,
                'Fiident': i.FIIdent,
                'AccountNumber': i.AccountNumber,
                'AccountType': i.AccountType,
                'MarkedLoanAccountNumber': i.MarkedLoanAccountNumber,
                'SubProductGroup' : i.SubProductGroup,
                'ProductName' : i.ProductName,
                'ODLimit': i.VLimit,
                'OutStanding': i.Outstanding,
                'Status': i.Status,
                'MarkedOutstanding': i.MarkedOutstanding,
                'MarkedVLimit': i.MarkedVLimit,
                'convertedMaturityDate': i.convertedMaturityDate,
                'HasCoBorrower': i.HasCoBorrower,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2 != undefined ? i.ERROR2 : '',
                'isError': i.isError != undefined ? i.isError : ''
            });
           
            return l;
        }, []) : [];
    },
})