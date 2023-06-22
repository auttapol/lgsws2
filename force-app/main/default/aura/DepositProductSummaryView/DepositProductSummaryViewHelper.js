({
    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
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
    
    doInitDepositProduct: function (component, event, helper) {
       component.set('v.depositProduct.columns', [{
            label: $A.get('$Label.c.Account_Number'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
                title: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
                name: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }

            },
            initialWidth: component.get('v.theme') == 'Theme4t' ? 260 : 280,
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1',
                    fieldName: 'ERROR2'

                }
            },
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                    , fieldName: 'ERROR2'

                }
            },
        },
        {
            label: $A.get('$Label.c.Status'),
            fieldName: 'Status',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                    , fieldName: 'ERROR2'

                }
            },
        }, {
            label: $A.get('$Label.c.Ledger_Balance_Deposit'),
            fieldName: 'MarkedLedgerBalance',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERRORLedger'
                }
            },
        }, {
            label: $A.get('$Label.c.Avg_Outstanding_MTD'),
            fieldName: 'MarkedAvgOutStanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
        }, {
            label: $A.get('$Label.c.Available_Balance_Deposit'),
            fieldName: 'MarkedOutStanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
        }, {
            label: $A.get('$Label.c.Other'),
            fieldName: 'Other',
            type: 'text',
            //fixedWidth: 60,
            initialWidth: 85,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
        }, {
            label: $A.get('$Label.c.Has_Joint'),
            fieldName: 'HasJoint',
            type: 'text',
            initialWidth: 85,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
        },
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.initialWidth = ['SubProductGroup', 'ProductName', 'Status'].includes(m.fieldName) ? 160 : 140;
            }
            return m;
        }));
        if(component.get('v.allowCallChild') == false){
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('DepositProductSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }
    },
    getIsUnmaskData: function (component, helper) {
        var action = component.get('c.getUnmaskBalance');
        action.setParams({
            'sectionUnmask': 'Deposit_Section'
        })
        var returnValue = "{}";
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            component.set('v.unmasked', returnValue);
        });

        $A.enqueueAction(action);
    },
     getRedProductcodeList: function (component, helper, product) {
        var listMainBankProduct = [];
        var action = component.get('c.getRedProductcode');
        action.setParams({});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                for (var indexmdt = 0; indexmdt < result.length; indexmdt++) {
                    listMainBankProduct.push(result[indexmdt].Product_Code__c);
                }
                component.set('v.mainBankProductCode', listMainBankProduct);
            }
        });
        $A.enqueueAction(action);

    },
    doInitErrorMessageControl: function (component, event, helper) {
        var errorMessageControlObj = {
            showMessage: false,
            someInfoError: false,
            noTmbcust: false,
            message: '',
            productName: {
                Deposit: $A.get('$Label.c.Deposit_Product_Details'),
                retry: ''
            },
            productTag: {
                Deposit: 'Deposit_Product_Details',
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
                Deposit: false,
            },
            error: {
                Deposit: false,
            },
            products: [],
            productErrors: {},
            noAuthorized: false,
            hrefList: ''
        }
        component.set("v.errorMessageControl", errorMessageControlObj);
    },

    getProductOSC02: function(component,helper){
        const depositProductList = component.get('v.resultFrom01').DepositAccount ? component.get('v.resultFrom01').DepositAccount : [];
        if(depositProductList.length > 0){
            component.set('v.depositProduct.datas', helper.parseDepositProduct(component, depositProductList.map(function (m) {
                if( m.MarkedLedgerBalance != $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    m.MarkedLedgerBalance = $A.get('$Label.c.Loading');
                    m.MarkedAvgOutStanding = '';
                    m.MarkedOutStanding = '';
                }
                return m;
            })));
    
            var osc02lst = depositProductList.reduce(function (l, i) {
                l.push(helper.callProductOSC02(component, helper, i, 0));
                return l;
            }, []);
    
            helper.promiseData(component, helper, osc02lst, 0);
           
        }else{
            component.set('v.depositProduct.datas', []);
            const sendToParent = new Map();
            sendToParent.set('DepositProductSummaryView', "default");
            var parentComponent = component.get("v.parent");                         
            parentComponent.handleReturnData(sendToParent);
        }
    },

    parseDepositProduct: function (component, list, fromWhere) {
        return list ? list.reduce(function (l, i, index) {

            if(i.MarkedDepositAccountNumber == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                let columns = component.get('v.depositProduct.columns');
                columns[0] = {
                    label: $A.get("$Label.c.Account_Number"),
                    fieldName: 'MarkedDepositAccountNumber',
                    type: 'text',
                    cellAttributes: {
                        class: {
                            fieldName: 'ERROR'
                        },
                        alignment: 'left'
                    },
                    fixedWidth: 110,
                },
                component.set('v.depositProduct.columns', columns);
            }

            l.push({
                'Type': $A.get('$Label.c.Deposit_Product_Details'),
                'Tag': 'Deposit_Product_Details',
                'TabName': i.MarkedDepositAccountNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedLedgerBalance != $A.get('$Label.c.Loading') ? i.Link : '',
                'SeqGrp': i.SeqGrp,
                'Fiident': i.Fiident,
                'AccountNumber': i.DepositAccountNumber,
                'AccountType': i.DepositProductCode,
                'ProductType': i.ProductType,
                'DepositAccountNumber': i.DepositAccountNumber,
                'MarkedDepositAccountNumber': i.MarkedDepositAccountNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'MaskedProductName': i.MaskedProductName,
                'MaskedSubProductGroup': i.MaskedSubProductGroup,
                'Status': i.Status,
                'MarkedLedgerBalance': i.MarkedLedgerBalance,
                'MarkedAvgOutStanding':i.MarkedAvgOutStanding,
                'MarkedOutStanding': i.MarkedOutStanding,
                'ODLimit': i.ODLimit,
                'OutStanding': i.OutStanding,
                'LedgerBalance': i.LedgerBalance,
                'Other': i.Other,
                'HasJoint': i.HasJoint,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.isError ? 'notFound' : i.checkAllFree ? 'notFound' : '',
                'ERRORLedger': i.checkAllFree ? 'notFoundLedger' : '',
                'isError': i.isError,
                'isAllFreeMin': i.checkAllFree ? 'ShowRed' : 'false'
            });
            return l;
        }, []) : [];
    },

    sortDepositProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            // returnValue = a.Status != 'NOTFND' && b.Status == 'NOTFND' ? -1 : (a.Status != 'NOTFND' && b.Status == 'NOTFND' ? 1 : 0);
            return returnValue;
        });
    },

    callProductOSC02: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getDepositProductDetail');
            action.setParams({
                'depositProduct': product,
                "RMID": helper.getTMBCustID(component).substring(12),
                'tmbCustId': helper.getTMBCustID(component),
                'mapUnmasked': component.get('v.unmasked'),
                'recordId' : component.get('v.recordId'),
                'fieldAccessMap' : component.get('v.fieldAccessMap'),
                'isEmployee' : helper.isEmployee(component),
                'listProdMDT' : component.get('v.mainBankProductCode')
            });

            action.setCallback(this, function (response) {
                var state = response.getState();

                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result && result.DepositAccount && !['404', '500'].includes(result.StatusCode)) {
                        var depositProduct = result.DepositAccount;
                        product.isError = depositProduct.isError;
                        product.MarkedLedgerBalance = depositProduct.MarkedLedgerBalance;
                        product.MarkedAvgOutStanding = depositProduct.MarkedAvgOutStanding;
                        product.MarkedOutStanding = depositProduct.MarkedOutStanding;
                        product.ODLimit = depositProduct.ODLimit;
                        product.OutStanding = depositProduct.OutStanding;
                        product.LedgerBalance = depositProduct.LedgerBalance;
                        product.AvgOutStanding = depositProduct.AvgOutStanding;
                        product.ERROR1 = !product.isError ? '' : 'notFound';
                        product.ERROR2 = !product.isError ? '' : 'notFound';
                        product.SeqGrp = product.SeqGrp ? product.SeqGrp : 'OTHERS';
                        product.ProductCodeMainBank = depositProduct.ProductCodeMainBank;
                        product.Link = depositProduct.Link;
                        product.checkAllFree = depositProduct.checkAllFree;
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

                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Deposit', true);
                        } else {
                            component.set('v.errorMessageControl.error.Deposit', true);
                        }
                    }

                    product.result = result;
                    component.set('v.depositProduct.datas', component.get('v.depositProduct.datas'));
                    res(product);

                } else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log('get error', error.message);
                    });
                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                }
            })
            if (product.ERROR1 != 'notFound') {
                $A.enqueueAction(action) ;
            } else {

                product.MarkedLedgerBalance = '';
                product.SeqGrp = 'OTHERS';
                product.isError = true;
                product.SubProductGroup = $A.get('$Label.c.ERR008');
                res(product)
            }
        }));
    },

    promiseData: function (component, helper, listProduct, round) {
        
        Promise.all(listProduct).then(function (products) {

            round++;
            var depositAccToRetry = products.filter(f => f.isError == true && f.ERROR1.includes('DepositAccount'));
            if (depositAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                var DepositAccProducts = products.reduce(function (l, i) {
                    if (i.isError == true && i.ERROR1.includes('retry')) {
                        l.push(helper.callProductOSC02(component, helper, i, round));
                    } else {
                        l.push(i);
                    }
                    return l;
                }, []);

                setTimeout(() => {
                    helper.promiseData(component, helper, DepositAccProducts, round);
                }, component.get("v.retrySetTimeOut"));

            } else {
                var parentComponent = component.get("v.parent");                         
                component.set('v.depositProduct.datas', helper.sortDepositProduct(helper.parseDepositProduct(component, products)));

                const sendToParent = new Map();                       
                if(component.get('v.errorMessageControl.timeout.Deposit') == true){
                    sendToParent.set('DepositProductSummaryView', "timeout");
                    parentComponent.handleReturnData(sendToParent);
                }
                else if(component.get('v.errorMessageControl.error.Deposit') == true){
                    sendToParent.set('DepositProductSummaryView', "error");
                    parentComponent.handleReturnData(sendToParent);
                }
                else {
                    const parseSum = helper.parseSummarizeProduct(component, helper, component.get('v.depositProduct.datas'));
                    parseSum.then((returnData) => {
                        sendToParent.set('DepositProductSummaryView', returnData);
                        parentComponent.handleReturnData(sendToParent);
                    })
                }
            }
        }).catch(function (error) {
            console.error(error);
        }); 
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var firstList = helper.separateGrp(datas, '1');
            var secondList = helper.separateGrp(datas, '2');
            var otherList = helper.separateGrp(datas, 'OTHERS');
            var parseSeventh = helper.parseFirstAndSecondObj(component, helper, firstList, '1');
            parseSeventh.then((seventObj) => {
                var parseEight = helper.parseFirstAndSecondObj(component, helper, secondList, '2');
                parseEight.then((eightObj) => {
                    var otherObj = helper.parseOthers(otherList);
                    resolve([seventObj, eightObj, otherObj])
                })
            })
        });
    },

    parseFirstAndSecondObj: function(component, helper, topassList, seqGrp){
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
                    AUM: sumMap['AUM'],
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
            if(e.isError == true){
                isError = true;
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
})