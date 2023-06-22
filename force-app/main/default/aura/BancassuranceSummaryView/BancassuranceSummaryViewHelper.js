({
    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    GetBancassurance: function(component, helper, round){
        const bancass = new Promise((resolve, reject) => {
            const sendToParent = new Map();
            var action = component.get('c.getBancAssuranceData');
            action.setParams({
                "rmId": helper.getTMBCustID(component).substring(12),
                "recordId": component.get('v.account.Id'),
                "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
            });
            action.setCallback(this, function (response) {
            
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if(result.Message != null || result.StatusCode != null){
                        sendToParent.set('BancassuranceSummaryView', result);
                        resolve(sendToParent);
                    }
                    else {

                        if(result.Status.StatusCode != '200'){
                            if(result.Status.StatusCode == '401' && round < component.get("v.numOfRetryTime")){
                                round++;
                                setTimeout(() => {
                                    helper.GetBancassurance(component, helper, round);
                                }, component.get("v.retrySetTimeOut"));
                            }
                            else if(result.Status.StatusCode == '401' && round == component.get("v.numOfRetryTime")){
                                const prepMessage = result.Status
                                sendToParent.set('BancassuranceSummaryView', prepMessage);
                                resolve(sendToParent);
                            }
                            else {
                                sendToParent.set('BancassuranceSummaryView', result.Status);
                                resolve(sendToParent);
                            }
                        }
                        else{
                            let dataList = [];
                            const DataSets = result.GetBancassuranceAccountResponse;
                            let data = DataSets.find(function (f) {
                                return f;
                            });
                            if(DataSets.length > 0 || data != undefined){
                                DataSets.forEach(each => {
                                    dataList.push(each);
                                });
                            }   
                            const finalData = helper.parseMappaing(component, dataList);
                            finalData.then((finish) => {
                                const returnData = helper.parseSummarizeProduct(component, helper, finish);
                                returnData.then((data) => {
                                    sendToParent.set('BancassuranceSummaryView', data);
                                    resolve(sendToParent);
                                })
                            })
                        }
                    } 
                }
                else if(state == 'ERROR'){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        }
                        sendToParent.set('BancassuranceSummaryView', 'error');
                        resolve(sendToParent);
                    }
                }
                else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message);
                    });
                }
            });
            $A.enqueueAction(action);
        });

        bancass.then((sendToparant) => {
            var parentComponent = component.get("v.parent");                         
		    parentComponent.handleReturnData(sendToparant);
        });
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var seq6List = helper.separateGrp(datas, '6');
            var otherList = helper.separateGrp(datas, 'OTHERS');
            const parse6 = helper.parseGroup6(component, helper, seq6List);
            parse6.then((sq6Obj) => {
                var grpOtherObj = helper.parseOthers(otherList);
                resolve([sq6Obj, grpOtherObj])
            })
        });
    },

    parseOthers: function(otherList){
        let isError = false;
        let account = [];
        otherList.forEach((e) => {
            if(!account.includes(e.POLICY_NO)){
                account.push(e.POLICY_NO);
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

    parseGroup6: function(component, helper, sq6){
        return new Promise((resolve, reject) => {
            let isError = false;
            let account = [];
            let prod = [];
            const outStandingList = [0];
            const odLimitList = [0];
            sq6.forEach((e) => {
                if(!account.includes(e.POLICY_NO)){
                    account.push(e.POLICY_NO);
                    account = account.filter(x => x !== undefined);
                }
                if(!prod.includes(e.ProductName)){
                    prod.push(e.ProductName);
                    prod = prod.filter(x => x !== undefined);
                }
                if(e.isError == true){
                    isError = true;
                }
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
                    SeqGrp: '6',
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
                'isEncrypt': false,
                'seqGrp': '6',
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

    parseBancassuranceProduct: function (component, list) {
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': i.Type,
                'Tag': i.Tag,
                'TabName': i.TabName,
                'link': i.link,
                'SeqGrp': i.SeqGrp,
                'POLICY_NO': i.POLICY_NO,
                'PRODUCT_GROUP': i.PRODUCT_GROUP,
                'ProductName': i.ProductName,
                'POLICY_NAME': i.POLICY_NAME,
                'COMPANY_NAME': i.COMPANY_NAME,
                'EFFECTIVE_DATE': i.EFFECTIVE_DATE,
                'STATUS': i.STATUS,
                'SUM_INSURE': i.SUM_INSURE,
                'PREMIUM': i.PREMIUM,
                'EXPIRY_DATE': i.EXPIRY_DATE,
                'Hidden': i.Hidden
            });
            return l;
        }, []) : [];
    },


    parseMappaing: function (component, data) {
        return new Promise((resolve, reject) => {
            const finalData = data.reduce((list, product, index) => {
                if(product.POLICY_NO == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    let columns = component.get('v.bancassuranceProduct.columns');
                    columns[0] = {
                        label: $A.get('$Label.c.Policy_No'),
                        fieldName: 'POLICY_NO',
                        type: 'text',
                        cellAttributes: {
                            class: {
                                fieldName: 'ERROR'
                            },
                            alignment: 'left'
                        },
                        isAccessible: 'isAccessibleCusHoldHig',
                        fixedWidth: 100,
                    },
                    component.set('v.bancassuranceProduct.columns', columns);
                }
                if(product.PREMIUM == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    let columns = component.get('v.bancassuranceProduct.columns');
                    columns[7] = {
                        label: $A.get('$Label.c.AFYP'),
                        fieldName: 'PREMIUM',
                        type: 'text',
                        isAccessible: 'isAccessibleCusHoldHig',
                        initialWidth: 120
                    }
                    component.set('v.bancassuranceProduct.columns', columns);
                }
                if(product.PREMIUM == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    let columns = component.get('v.bancassuranceProduct.columns');
                    columns[6] = {
                        label: $A.get('$Label.c.Sum_Insure'),
                        fieldName: 'SUM_INSURE',
                        type: 'text',
                        isAccessible: 'isAccessibleCusHoldHig',
                        initialWidth: 120
                    }
                    component.set('v.bancassuranceProduct.columns', columns);
                }
                list.push({
                    'Type': product.Type,
                    'Tag': product.Tag,
                    'TabName': product.TabName,
                    'link': product.link,
                    'SeqGrp': product.SeqGrp,
                    'POLICY_NO': product.POLICY_NO,
                    'PRODUCT_GROUP': product.PRODUCT_GROUP,
                    'ProductName': product.ProductName,
                    'POLICY_NAME': product.POLICY_NAME,
                    'COMPANY_NAME': product.COMPANY_NAME,
                    'EFFECTIVE_DATE': product.EFFECTIVE_DATE,
                    'STATUS': product.STATUS,
                    'SUM_INSURE': product.SUM_INSURE,
                    'PREMIUM': product.PREMIUM,
                    'EXPIRY_DATE': product.EXPIRY_DATE,
                    'Hidden': product.Hidden
                });
                return list;
            }, []);
            component.set('v.bancassuranceProduct.datas', finalData);
            resolve(finalData);
        });

        // component.set('v.bancassuranceProduct.datas', data
            // .reduce((list, product, index) => {
                // if(product.POLICY_NO == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    // let columns = component.get('v.bancassuranceProduct.columns');
                    // columns[0] = {
                        // label: $A.get('$Label.c.Policy_No'),
                        // fieldName: 'POLICY_NO',
                        // type: 'text',
                        // cellAttributes: {
                            // class: {
                                // fieldName: 'ERROR'
                            // },
                            // alignment: 'left'
                        // },
                        // isAccessible: 'isAccessibleCusHoldHig',
                        // fixedWidth: 100,
                    // },
                    // component.set('v.bancassuranceProduct.columns', columns);
                // }
                // if(product.PREMIUM == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    // let columns = component.get('v.bancassuranceProduct.columns');
                    // columns[7] = {
                        // label: $A.get('$Label.c.AFYP'),
                        // fieldName: 'PREMIUM',
                        // type: 'text',
                        // isAccessible: 'isAccessibleCusHoldHig',
                        // initialWidth: 120
                    // }
                    // component.set('v.bancassuranceProduct.columns', columns);
                // }
                // if(product.PREMIUM == $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    // let columns = component.get('v.bancassuranceProduct.columns');
                    // columns[6] = {
                        // label: $A.get('$Label.c.Sum_Insure'),
                        // fieldName: 'SUM_INSURE',
                        // type: 'text',
                        // isAccessible: 'isAccessibleCusHoldHig',
                        // initialWidth: 120
                    // }
                    // component.set('v.bancassuranceProduct.columns', columns);
                // }
                // list.push({
                    // 'Type': product.Type,
                    // 'Tag': product.Tag,
                    // 'TabName': product.TabName,
                    // 'link': product.link,
                    // 'SeqGrp': product.SeqGrp,
                    // 'POLICY_NO': product.POLICY_NO,
                    // 'PRODUCT_GROUP': product.PRODUCT_GROUP,
                    // 'ProductName': product.ProductName,
                    // 'POLICY_NAME': product.POLICY_NAME,
                    // 'COMPANY_NAME': product.COMPANY_NAME,
                    // 'EFFECTIVE_DATE': product.EFFECTIVE_DATE,
                    // 'STATUS': product.STATUS,
                    // 'SUM_INSURE': product.SUM_INSURE,
                    // 'PREMIUM': product.PREMIUM,
                    // 'EXPIRY_DATE': product.EXPIRY_DATE,
                    // 'Hidden': product.Hidden
                // });
                // return list;
            // }, []));
    },
})