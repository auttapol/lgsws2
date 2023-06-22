({
    doInitCreditCardRDCProduct: function (component, event, helper) {  
        component.set('v.genColumnSuccess', true);      
        component.set('v.creditCardRDCProduct.columns', [{
            label: $A.get('$Label.c.Card_Number'),
            type: 'button',
            fieldName: 'MarkedCardNumber',
            fieldName: '',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedCardNumber'
                },
                title: {
                    fieldName: 'MarkedCardNumber'
                },
                name: {
                    fieldName: 'MarkedCardNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 200,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },            
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 250,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 360,            
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Card_Role'),
            fieldName: 'CardRole',
            type: 'text',
							
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Card_Active_Flag'),
            fieldName: 'CardActive',
            type: 'text',
							
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Credit_Line'),
            fieldName: 'MaskedCreditLine',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Outstanding_Credit'),
            fieldName: 'MarkedOutstanding',
							
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
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
            isAccessible: 'isAccessibleCusHoldMid',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {                
                m.initialWidth = ['CardRole', 'CardActive', 'MaskedCreditLine', 'MarkedOutstanding', 'MarkedVLimit'].includes(m.fieldName) ? 120 : 200;
            }
            return m;
        }));
    },

    genColumnStars: function (component, helper) { 
        let newColumn = [];       
        component.get('v.creditCardRDCProduct.columns').forEach(e => {            
            if(e.label == 'Card Number'){               
                e.fieldName = 'MarkedCardNumber';
                e.type = 'text';
                e.typeAttributes = '';                
            }
            else if(e.label == 'เลขที่บัตร'){
                e.fieldName = 'MarkedCardNumber';
                e.type = 'text';
                e.typeAttributes = ''; 
            }            
            newColumn.push(e);        
        });
        component.set('v.creditCardRDCProduct.columns', newColumn);        
    },

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },
    
    GetCreditCard: function(component, helper, more_records, search_keys, creditcard_list, round) {
        const creditprod = new Promise((resolve, reject) => {
            const sendToParent = new Map();
            var action = component.get('c.callgetCreditCardData');
            action.setParams({                
                "rmId": helper.getTMBCustID(component),
                "more_records": more_records,
                "search_keys": search_keys,
                "user_interface": '',
                "tmbCustId": helper.getTMBCustID(component),
                "recordId": component.get('v.recordId'),
            });
            action.setCallback(this, function (response) {                                
                var state = response.getState();
                var result = response.getReturnValue();
                var responseText = responseText + 'String';
                
                if (creditcard_list == null) {
                    creditcard_list = [];
                }

                if(component.isValid() && state === "SUCCESS" && !responseText.includes('UNABLE_TO_LOCK_ROW')){                                       
                    if(result.error_status) {
                        if (!helper.errorCodeSCSIncludes('CIF0003', result.error_status) && !helper.errorCodeSCSIncludes('500', result.error_status)) {                                                        
                            
                            component.set('v.creditCardRDCProduct.datas', []);
                            sendToParent.set('CreditProductSummaryView', 'CIF0003');
                            resolve(sendToParent);
                        } else {
                            component.set('v.creditCardRDCProduct.datas', []);
                            sendToParent.set('CreditProductSummaryView', 'CIF0003');
                            resolve(sendToParent);
                        }                    
                    }
                    else if (result.Status.StatusCode != '200') {
                        if(result.Status.StatusCode == "500" && result.Status.StatusDesc.includes('Timeout')){                            
                            sendToParent.set('CreditProductSummaryView', 'timeout');
                            resolve(sendToParent);
                        }
                        else if(result.Status.StatusCode == "401" && round < component.get("v.numOfRetryTime")){                                                  
                            round++;
                            setTimeout(() => {
                                helper.GetCreditCard(component, helper, more_records, search_keys, creditcard_list, round);                                
                            }, component.get("v.retrySetTimeOut"));
                        }
                        else if(result.Status.StatusCode == "401" && round == component.get("v.numOfRetryTime")){                            
                            sendToParent.set('CreditProductSummaryView', 'error');
                            resolve(sendToParent);
                        }
                    }
                    else {                                                    
                        
                        if (result && result.Body && result.Body.length > 0) {                                                           
                            
                            var CreditCardAccBalAccs = result.Body;
                            var Starmasked = $A.get('$Label.c.Data_Condition_Hidden_Text');
                            var countIndex = CreditCardAccBalAccs.length;                                                                                           
                            
                            for(var x = 0 ; x < countIndex ; x++){
                                if(CreditCardAccBalAccs[x].MarkedCardNumber == Starmasked){
                                    helper.genColumnStars(component, helper); 
                                    break;
                                }
                            }                            
                    
                            CreditCardAccBalAccs.forEach((e, i) => {
                                if (e.isError === 'false') {
                                    e.isError = e.isError == 'false' ? false : true; 
                                    e.Status = 'Success';
                                    e.ERROR1 = '';
                                    e.ERROR2 = e.isError == false ? '' : 'notFound';
                                    e.account_id = e.account_id;  
                                    // const link = '/one/one.app#' + btoa(JSON.stringify({
                                        // "componentDef": "c:CreditCardDetails",
                                        // "attributes": {
                                            // "recordId": component.get('v.account.Id'),
                                            // "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                            // 'CardNumber': e.CardNumber,
                                            // 'CreditCardType': e.CreditCardType,
                                            // 'account_id': e.account_id,
                                            // 'product': btoa(encodeURIComponent(JSON.stringify({
                                                // 'SeqGrp': e.SeqGrp,
                                                // 'CardNumber': e.CardNumber,
                                                // 'CreditCardType': e.CreditCardType,
                                                // 'MarkedCardNumber': e.MarkedCardNumber,
                                                // 'SubProductGroup': e.SubProductGroup,
                                                // 'ProductName': e.ProductName,
                                                // 'ProductType': e.ProductType,
                                                // 'MarkedOutstanding': e.MarkedOutstanding,
                                                // 'MarkedVLimit': e.MarkedVLimit,
                                                // 'VLimit': e.VLimit,
                                                // 'Outstanding': e.Outstanding,
                                                // 'OutstandingDisplay': e.OutstandingDisplay,
                                            // }))),
                                        // }
                                    // }));          
                                    e.link = e.Link;
                                }
                                else {                                    
                                    sendToParent.set('CreditProductSummaryView', 'error');
                                    resolve(sendToParent);
                                }
                                creditcard_list.push(e);                                
                    
                            });

                            const displayData = helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list));
                            component.set('v.creditCardRDCProduct.datas', displayData);
                            const parseSummarize = helper.parseSummarizeProduct(component, helper, displayData);
                            parseSummarize.then((returnData) => {
                                sendToParent.set('CreditProductSummaryView', returnData);                            
                                resolve(sendToParent);
                            });
                                                                                                                              
                            // sendToParent.set('CreditProductSummaryView', component.get('v.creditCardRDCProduct'));                            
                            // resolve(sendToParent);
                        }
                        else if (!result) {                                                      
                            sendToParent.set('CreditProductSummaryView', 'error');
                            resolve(sendToParent);
                        }

                        // if (result.result && result.result.more_records && result.result.more_records == 'Y' && result.result.search_keys != '') {
                        //     helper.GetCreditCard(component, helper, result.result.more_records, result.result.search_keys, creditcard_list, round);
                        // }
                    }    
                }
                else if (state === "ERROR") {
                    let errors = action.getError();
                    if(errors) {
                        if(errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                            
                            sendToParent.set('CreditProductSummaryView', 'error');
                            resolve(sendToParent);
                        }
                    }
                }
                else {
                    let errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message);
                    });
                    sendToParent.set('CreditProductSummaryView', 'error');
                    resolve(sendToParent);
                }
            });
            $A.enqueueAction(action);
        });

        creditprod.then((sendToParent) => {
            var parentComponent = component.get("v.parent");
            parentComponent.handleReturnData(sendToParent);                        
        })
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var creditList = helper.separateGrp(datas, '3');
            var otherList = helper.separateGrp(datas, 'OTHERS');
            var parseCreditObjFun = helper.parseCreditObj(component, helper, creditList);
            parseCreditObjFun.then((returnObj) => {
                const otherObj = helper.parseOthers(otherList);
                resolve([returnObj, otherObj]);
            });
        });
    },

    parseCreditObj: function(component, helper, creditList){
        return new Promise((resolve, reject) => {
            let isError = false;
            let account = [];
            let prod = [];
            let outStandingList = [0];
            let odLimitList = [0];
            creditList.forEach((e) => {
                if(!account.includes(e.CardNumber)){
                    account.push(e.CardNumber);
                    account = account.filter(x => x !== undefined);
                }
                if(!prod.includes(e.ProductName)){
                    prod.push(e.ProductName);
                    prod = prod.filter(x => x !== undefined);
                }
                if(e.isError == true){
                    isError = true;
                }
                outStandingList.push(e.Outstanding == undefined ? 0 : e.Outstanding);
                odLimitList.push(e.VLimit == undefined ? 0 : e.VLimit);
            });

            const toSumMap = {
                accountList: account,
                productList: prod,
                outStandingList: outStandingList,
                odLimitList: odLimitList
            }
            const prfun = helper.getSumOfMarkedOutstanding(component, toSumMap);
            prfun.then((sumMap) => {
                const returnObj = {
                    ERROR: isError == true ? 'notFound' : '',
                    SeqGrp: '3',
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

    parseOthers: function(otherList){
        let isError = false;
        let account = [];
        otherList.forEach((e) => {
            if(!account.includes(e.UnitHolderNo)){
                account.push(e.UnitHolderNo);
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

    getSumOfMarkedOutstanding: function(component, toSumMap){
        return new Promise((resolve, reject) => {

            var IsUnmasked = component.get("v.unmasked");
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
                'seqGrp': '3',
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
    
    sortCreditRDCProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            returnValue = a.Status == 'NOTFND' && b.Status != 'NOTFND' ? 1 : (a.Status != 'NOTFND' && b.Status == 'NOTFND' ? -1 : 0);
            return returnValue;
        });
    },

    errorCodeSCSIncludes: function (error_code, error_status) {
        var isInclude = false;        
        error_status.forEach((e, i) => {
            if (e.error_code == error_code) {
                isInclude = true;
            }            
        });
        return isInclude;
    },

    parseCreditCardSCSProduct: function (component, list) {
        var Starmasked = $A.get('$Label.c.Data_Condition_Hidden_Text');        
        return list ? list.reduce(function (l, i) {
            const link = i.ERROR1 != 'notFound' && i.MarkedOutstanding != $A.get('$Label.c.Loading') && i.MarkedCardNumber != Starmasked ? '/one/one.app#' + btoa(JSON.stringify({
                "componentDef": "c:CreditCardDetails",
                "attributes": {
                    "recordId": component.get('v.account.Id'),
                    "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                    'CardNumber': i.CardNumber,
                    'CreditCardType': i.CreditCardType,
                    'account_id': i.account_id,
                    'product': i.EncodeProduct
                    // 'product': btoa(encodeURIComponent(JSON.stringify({
                        // 'SeqGrp': i.SeqGrp,
                        // 'CardNumber': i.CardNumber,
                        // 'CreditCardType': i.CreditCardType,
                        // 'MarkedCardNumber': i.MarkedCardNumber,
                        // 'SubProductGroup': i.SubProductGroup,
                        // 'ProductName': i.ProductName,
                        // 'ProductType': i.ProductType,
                        // 'Status': i.Status,
                        // 'MarkedOutstanding': i.MarkedOutstanding,
                        // 'MarkedVLimit': i.MarkedVLimit,
                        // 'VLimit': i.VLimit,
                        // 'Outstanding': i.Outstanding,
                        // 'OutstandingDisplay': i.OutstandingDisplay,                            
                    // }))),
                }
            })) : ''
            l.push({
                'Type': $A.get('$Label.c.Credit_Card_RDC_Product_Details'),
                'Tag': 'Credit_Card_RDC_Product_Details',
                'TabName': i.MarkedCardNumber,
                'link': i.Link,
                'SeqGrp': i.SeqGrp,
                'CardNumber': i.CardNumber,
                'CreditCardType': i.CreditCardType,
                'MarkedCardNumber': i.MarkedCardNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'ProductType': i.ProductType,
                // 'UsageStatus': i.UsageStatus,
                'Status': i.Status,
                // unmasked credit card
                // 'MarkedOutstanding': IsCreditLogic ? i.MarkedOutstanding : !IsOutStanding ? i.MarkedOutstanding : i.Outstanding.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                // 'MarkedVLimit': IsCreditLogic ? i.MarkedVLimit : !IsLimit ? i.MarkedVLimit : i.VLimit.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'MarkedOutstanding': i.MarkedOutstanding,
                'MarkedVLimit': i.MarkedVLimit,
                // 'VLimit': parseFloat(i.VLimit),
                // 'Outstanding': parseFloat(i.Outstanding),
                'VLimit': i.VLimit,
                'Outstanding': i.Outstanding,
                'OutstandingDisplay': i.OutstandingDisplay,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2,
                'isError': i.isError,
                'account_id': i.account_id,
                'CardRole': i.CardRole,
                'CardPLoan': i.CardPLoan,
                'CardActive': i.CardActive,
                // 'CreditLine': i.CreditLine,
                'MaskedCreditLine': i.MaskedCreditLine,
            });
            return l;
        }, []) : [];
    }, 
})