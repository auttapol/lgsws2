({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
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

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
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

        if(component.get('v.allowCallChild') == false){
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('AutoLoanProductSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }
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
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },

    callProduct: function (component, event, helper, round) {
        const autoLaonData = new Promise((resolve, reject) => {
            const sendToParent = new Map();
            helper.startSpinner(component, event, helper);
            const accessCust = component.get('v.accessibleCusHold').replaceAll('"', '\\"');
            var action = component.get('c.getAutoloanHpFleetHpList');
            action.setParams({
                "Company": component.get('v.company'),
                "RMID": helper.getTMBCustID(component),
                "HPType": "HP",
                "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, ''),
                "recordId": component.get('v.recordId'),
                'state': {
                    'service': 'CoreHP',
                    'recordId': component.get("v.recordId"),
                    'tmbCustId': component.get("v.tmbCustId")
                },
                // 'accessCustHold': component.get('v.accessibleCusHold')
                'accessCustHold': accessCust
            });
    
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    
                    if(result.HTTPStatusCode == "401" && round < component.get("v.numOfRetryTime")){
     
                        round++;
                        setTimeout(() => {
     
                            helper.callProduct(component, event, helper, round);
                        }, component.get("v.retrySetTimeOut"));
                        
                    }
                    else if(result.HTTPStatusCode == "401" && round == component.get("v.numOfRetryTime")){
                        sendToParent.set('AutoLoanProductSummaryView', 'error');
                        resolve(sendToParent);
                    }
                    else if(result.HTTPStatusCode == "200" && result.Output){
                        const parseMap = helper.parseMappaing(component, result.Output);
                        parseMap.then((displayData) => {
                            const parseSum = helper.parseSummarizeProduct(component, helper, displayData);
                            parseSum.then((returnData) => {
                                sendToParent.set('AutoLoanProductSummaryView', returnData);
                                resolve(sendToParent);
                            })
                        })
                    }
                    else{
                        sendToParent.set('AutoLoanProductSummaryView', 'error');
                        resolve(sendToParent);
    
                    }
                } else {
                    var errors = response.getError();
                    errors.forEach(error => console.log(error.message));
                    sendToParent.set('AutoLoanProductSummaryView', 'error');
                    resolve(sendToParent);
                }
            });
            $A.enqueueAction(action);
        });

        autoLaonData.then((data) => {
            var parentComponent = component.get("v.parent");                         
		    parentComponent.handleReturnData(data);
        });
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var autoLoanList = helper.separateGrp(datas, 'AutoLoan');
            var otherList = helper.separateGrp(datas, 'OTHERS')
            const parseFunction = helper.parseGroupAutoLoan(component, helper, autoLoanList);
            parseFunction.then((returnData) => {
                const otherObj = helper.parseOthers(otherList);
                resolve([returnData, otherObj]);
            });
        });
    },

    parseOthers: function(otherList){
        let isError = false;
        let account = [];
        otherList.forEach((e) => {
            if(!account.includes(e.MarkedHP_Account_No)){
                account.push(e.MarkedHP_Account_No);
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
            Hidden: '***********'
        }
        return otherObj;
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

    parseGroupAutoLoan: function(component, helper, autoLoan){
        return new Promise((resolve, reject) => {
            let isError = false;
            let account = [];
            let prod = [];
            let outStandingList = [0];
            let odLimitList = [0];
            autoLoan.forEach((e) => {
                if(!account.includes(e.MarkedHP_Account_No)){
                    account.push(e.MarkedHP_Account_No);
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
                odLimitList.push(e.ODLimit == undefined ? 0 : e.ODLimit);
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
                    SeqGrp: 'AutoLoan',
                    Tag: sumMap['Tag'],
                    Product_Group: sumMap['Product_Group'],
                    Number_of_Product: sumMap['Number_of_Product'] == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : `${autoLoan.length}`,
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
                'seqGrp': 'AutoLoan',
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

    parseMappaing: function (component, data) {
        return new Promise((resolve, reject) => {
            const displayData = data.reduce((list, product, index) => {
                if(product.MarkedHP_Account_No == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    let columns = component.get('v.product.columns');
                    columns[0] = {
                        label: $A.get("$Label.c.HP_Account_No"),
                        fieldName: 'MarkedHP_Account_No',
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
                    component.set('v.product.columns', columns);
                }
                list.push({
                    'MarkedHP_Account_No': product.MarkedHP_Account_No,
                    'Status_AutoLoan': product.Status_AutoLoan,
                    'HP_Amount': product.HP_Amount,
                    'Outstanding_Amount': product.Outstanding_Amount,
                    'Installment_Amount': product.Installment_Amount,
                    'Remain_Period': product.Remain_Period,
                    'Contract_Period': product.Contract_Period,
                    'Paid_Period': product.Paid_Period,
                    'MarkedOverdue_Amount': product.MarkedOverdue_Amount,
                    'HUB': product.HUB,
    
                    'HP_Account_No': product.HP_Account_No,
                    // 'Overdue_Amount': parseFloat(product.Overdue_Amount),
                    // 'Overdue_No': product.Overdue_No,
                    // 'Outstanding': parseFloat(product.Outstanding),
                    // 'ODLimit': parseFloat(product.ODLimit),
                    // 'No': product.No,
                    'SeqGrp': product.SeqGrp,
                    'Hidden': product.Hidden,
                    'link': product.Link,
                    'Outstanding': product.Outstanding,
                    'ODLimit': product.ODLimit,
                });
                return list;
            }, []);
    
            component.set('v.product.datas', displayData);
            resolve(displayData);
        }); 
    },

    getWatermarkHTML: function (component) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if (state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
})