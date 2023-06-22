({

    numberWithCommas: function (x) {
        var parts = x.toString().split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join(".");
    },

    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    callgetInvestmentlist: function(component, event, helper, result){
        component.set('v.investmentProduct.datas', helper.parseInvestmentProduct(component, result.InvestmentAccount.map(function (m) {
            m.UnitHolderNo = m.UnitHoldNo;
            m.FundCode = '';
            m.ProductName = $A.get('$Label.c.Loading');
            m.MarketValue = '';
            m.UnrealizedGL = '';
            m.IsEncrypt = m.IsEncrypt;
            return m;
        })));
        var osc06lst = component.get('v.investmentProduct.datas').reduce(function (l, i) {
            l.push(helper.callProductOSC06List(component, helper, i, 0));
            return l;
        }, []);
        helper.promiseData(component, helper, 'InvestmentAccount', osc06lst, 0);
    },

    doInitErrorMessageControl: function (component, event, helper) {
        var errorMessageControlObj = {
            showMessage: false,
            someInfoError: false,
            noTmbcust: false,
            message: '',
            productName: {
                Investment: $A.get('$Label.c.Investment_Product_Details'),
                retry: ''
            },
            productTag: {
                Investment: 'Investment_Product_Details',
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
                Investment: false,
            },
            error: {
                Investment: false,
            },
            products: [],
            productErrors: {},
            noAuthorized: false,
            hrefList: ''
        }
        component.set("v.errorMessageControl", errorMessageControlObj);
    },

    parseInvestmentProduct: function (component, list) {
        // fieldName => UnitHolderNo is accessible or not
        var UnitHolderNo_FieldInfo = component.get('v.investmentProduct.columns').find(function (f) {
            return f.typeAttributes && f.typeAttributes.label.fieldName == 'UnitHolderNo';
            // return f.typeAttributes && f.typeAttributes.label.fieldName == 'DisplayUnitHolderNo';
        });

        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Investment_Product_Details'),
                'Tag': 'Investment_Product_Details',
                'TabName': i.UnitHolderNo,
                // 'link': i.UnitHolderNo && i.FundCode ? '/one/one.app#' + btoa(JSON.stringify({
                    // "componentDef": "c:InvestmentProductDetailNewView",
                    // "attributes": {
                        // "recordId": component.get('v.account.Id'),
                        // "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        // 'UnitHolderNo': i.UnitHolderNo,
                        // 'FundCode': i.FundCode,
                    // }
                // })) : '',
                'link': i.link ? i.link : '',
                'SeqGrp': i.SeqGrp,
                'UnitHolderNo': i.UnitHolderNo,
                'FundCode': i.FundCode,
                'ProductName': i.ProductName,
                'AssetClass': i.AssetClass,
                // 'AssetClass': i.DisplayAssetClass,
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
                'UnitHolderNoClass': UnitHolderNo_FieldInfo.fieldName != 'Hidden' && i.isError ? 'notFound' : '',
                'ERROR': i.isError ? 'notFound' : '',
                'IsEncrypt': i.AccessHigh == true ? false : true,
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },


    callProductOSC06List: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getInvestmentAccountList');
            action.setParams({
                'unitHolderNo': product.UnitHolderNo,
                'recordId': component.get('v.account.Id'),
                'tmbCustId': component.get('v.account.TMB_Customer_ID_PE__c'),
                'isEncrypt': product.IsEncrypt
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var UnitHolderNo = product.UnitHolderNo;
                    var productList = [];

                    if (result && !['404', '500'].includes(result.Status.StatusCode) && result.InvestmentAccount.length > 0) {

                        result.InvestmentAccount.forEach((e) => {
                            productList.push({
                                'isError': e.isError == 'true',
                                'SeqGrp' : e.SeqGrp,
                                'UnitHolderNo' : e.UnitHolderNo,
                                'FundCode' : e.FundCode,
                                'ProductName' : e.ProductName,
                                'AssetClass' : e.AssetClass,
                                'IssuerFundHouse' : e.IssuerFundHouse,
                                'NumberOfUnit' : e.NumberOfUnit == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.NumberOfUnit),
                                'NavUnit' : e.NavUnit == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.NavUnit),
                                'CostOfInvestment' : e.CostOfInvestment == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.CostOfInvestment),
                                'AverageCostPerUnit' : e.AverageCostPerUnit == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.AverageCostPerUnit),
                                'UnrealizedGL' : e.UnrealizedGL == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.UnrealizedGL),
                                'UnrealizedGLPerc' : e.UnrealizedGLPerc == $A.get('$Label.c.Data_Condition_Hidden_Text') ? $A.get('$Label.c.Data_Condition_Hidden_Text') : parseFloat(e.UnrealizedGLPerc),
                                'link' : e.link,
                                'ERROR' : e.ERROR,
                                'UnitHolderNoClass': e.UnitHolderNoClass,
                                'Params': e.Params,
                                'ProductName': e.ProductName,
                                'UnitLtf5y': e.UnitLtf5y == 'true',
                                'convertedOpenedDate': e.convertedOpenedDate,
                                'MarketValue' : isNaN(e.MarketValue) ? e.MarketValue : parseFloat(e.MarketValue),
                            });
                        });
                    }
                    else if (result.Status.StatusCode == '401' && round < component.get("v.numOfRetryTime")) {
                        product.ERROR = 'retry InvestmentAccount';
                        product.isError = true;
                    } 
                    else {
                        component.set('v.hasErrorRecord', true);
                        const bodyObj = JSON.parse(result.State.body);
                        UnitHolderNo = bodyObj['GetInvestmentAccountRequest']['UnitHolderNo'];
                        product.SeqGrp = 'OTHERS';
                        product.UnitHolderNoClass = 'notFound';
                        product.ERROR = 'notFound';
                        product.isError = true;
                        product.ProductName = result.Status.StatusCode == "200"  ? $A.get('$Label.c.INT_Investment_Record_Not_Found') : $A.get('$Label.c.ERR008');
                        // product.DisplayProductName = result.Status.StatusCode == "200"  ? $A.get('$Label.c.INT_Investment_Record_Not_Found') : $A.get('$Label.c.ERR008');
                        if (result.Status.StatusCode == "500") {
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

                    // component.set('v.investmentProduct.datas', component.get('v.investmentProduct.datas'));

                    res(productList.length > 0 ? productList : product);
                } 
                else if (state === "ERROR") {
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        }
                        component.set('v.errorMessageControl.error.Investment', true);
                    }
                }
                else {
                    var errors = response.getError();
                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });
            $A.enqueueAction(action);
        }));
    },

    promiseData: function (component, helper, cmpRetryName, listProduct, round) {
        const InvestmentAccName = 'InvestmentAccount';
        //For InvestmentAccount 
        var thisObject = this;
        var graphProductAP = [];
        Promise.all(listProduct).then(function (products) {
            round++;
            if (cmpRetryName.includes(InvestmentAccName)) {
                var investmentToRetry = products.filter(f => f.isError == true && f.ERROR.includes(InvestmentAccName));

                if (investmentToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    var InvestmentProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR == 'retry InvestmentAccount') {
                            l.push(helper.callProductOSC06List(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, [])

                    setTimeout(() => {
                        helper.promiseData(component, helper, cmpRetryName, InvestmentProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    products = products.reduce(function (list, item) {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                        return list;
                    }, []);
 
                    var productAP = products.reduce(function (list, item) {
                        if (item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);
 
                    var productPT = products.reduce(function (list, item) {
                        if (!item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);
 
                    var productLTF = products.reduce(function (list, item) {
                        if (item.AssetClass == 'LTF' || item.AssetClass == 'RMF' || item.AssetClass == 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);
 
                    // AP
                    productAP = helper.sumTotalEachUnitHolderInvestmentProduct(component, productAP);
                    productAP = helper.calculatePercentWeightPerPort(productAP);
                    component.set('v.investmentProduct.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, products)));
                    // component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
                    if(component.get('v.hiddenHigh') == true || component.get('v.hiddenLow') == true){
                        helper.genHiddenDataTable(component, helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)), 'investmentProductAP');
                    }
                    else{
                        component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
                    }

                    // PT
                    productPT = helper.sumTotalEachAssetClassInvestmentProduct(component, productPT);
                    productPT = helper.calculatePercentWeight(productPT);
                    if(component.get('v.hiddenHigh') == true || component.get('v.hiddenLow') == true){
                        helper.genHiddenDataTable(component, helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productPT)), 'investmentProductPT');
                    }
                    else{
                        component.set('v.investmentProductPT.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productPT)));
                    }
 
                    // LTF
                    productLTF = helper.sumTotalEachAssetClassInvestmentProduct(component, productLTF);
                    productLTF = helper.calculatePercentWeight(productLTF);
                    // component.set('v.investmentProductLTF.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productLTF)));
                    if(component.get('v.hiddenHigh') == true || component.get('v.hiddenLow') == true){
                        helper.genHiddenDataTable(component, helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productLTF)), 'investmentProductLTF');
                    }
                    else{
                        component.set('v.investmentProductLTF.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productLTF)));
                    }
                }
            }

            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            if(component.get('v.errorMessageControl.timeout.Investment') == true){
                sendToParent.set('InvestmentProductSummaryViewStatus', "timeout");
            }
            else if(component.get('v.errorMessageControl.error.Investment') == true || component.get('v.hasErrorRecord') == true){
                sendToParent.set('InvestmentProductSummaryViewStatus', "error");
            }
            else {
                sendToParent.set('InvestmentProductSummaryViewStatus', "success");
            }
            const finalData = helper.parseSummarizeProduct(component, helper, component.get('v.investmentProduct.datas'));
            finalData.then((data) => {
                sendToParent.set('InvestmentProductSummaryView', data);
                parentComponent.handleReturnData(sendToParent);
            });
        });
    },

    parseSummarizeProduct: function(component, helper, datas){
        return new Promise((resolve, reject) => {
            var seq5List = helper.separateGrp(datas, '5');
            var otherList = helper.separateGrp(datas, 'OTHERS');
            var grp5fun = helper.parseGroup5(component, helper, seq5List);
            grp5fun.then((grp5obj) => {
                var grpOtherObj = helper.parseOthers(otherList);
                resolve([grp5obj, grpOtherObj])
            });
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
        let isError = false;
        let account = [];
        let prod = [];
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
            Hidden: '***********'
        }
        return otherObj;
    },

    parseGroup5: function(component, helper, sq5){
        return new Promise((resolve, reject) => {
            let isError = false;
            let account = [];
            let prod = [];
            let outStandingList = [0];
            let odLimitList = [0];
            sq5.forEach((e) => {
                if(!account.includes(e.UnitHolderNo)){
                    account.push(e.UnitHolderNo);
                    account = account.filter(x => x !== undefined);
                }
                if(!prod.includes(e.ProductName)){
                    prod.push(e.ProductName);
                    prod = prod.filter(x => x !== undefined);
                }
                if(e.isError == true){
                    isError = true;
                }
                outStandingList.push(e.MarketValue == undefined ? 0 : e.MarketValue);
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
                    SeqGrp: '5',
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
                'seqGrp': '5',
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

    sumTotalEachAssetClassInvestmentProduct: function (component, products) {
        var sumTotal = [];
        var totalCostOfInvestment = 0;
        var totalMarketValue = 0;
        var totalUnrealizedGL = 0;
        var totalUnrealizedGLPerc = 0;
        for (let i = 0; i < products.length; i++) {
            var index = sumTotal.findIndex((m) => {
                return (m.AssetClass == products[i].AssetClass && m.ProductName == 'Total')
            });
            if (products[i].AssetClass != '' && products[i].AssetClass != null && products[i].AssetClass != $A.get('$Label.c.Data_Condition_Hidden_Text')) {
                if (index === -1) {
                    sumTotal.push({
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': '',
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': products[i].AssetClass,
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': products[i].MarketValue,
                        'UnrealizedGL': products[i].UnrealizedGL,
                        'UnrealizedGLPerc': (products[i].UnrealizedGL / products[i].CostOfInvestment) * 100,
                        'PercentWeight': '',
                    });
                } else {
                    sumTotal[index] = {
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': '',
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': products[i].AssetClass,
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': sumTotal[index].CostOfInvestment + products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': sumTotal[index].MarketValue + products[i].MarketValue,
                        'UnrealizedGL': sumTotal[index].UnrealizedGL + products[i].UnrealizedGL,
                        'UnrealizedGLPerc': ((sumTotal[index].UnrealizedGL + products[i].UnrealizedGL) /
                            (sumTotal[index].CostOfInvestment + products[i].CostOfInvestment)) *
                            100,
                        'PercentWeight': '',
                    };
                }

                totalCostOfInvestment = totalCostOfInvestment + products[i].CostOfInvestment;
                totalMarketValue = totalMarketValue + products[i].MarketValue;
                totalUnrealizedGL = totalUnrealizedGL + products[i].UnrealizedGL;
                totalUnrealizedGLPerc = (totalUnrealizedGL / totalCostOfInvestment) * 100;
            }
        }

        sumTotal.push({
            'Type': $A.get('$Label.c.Investment_Product_Details'),
            'UnitHolderNo': '',
            'FundCode': '',
            'ProductName': 'Total',
            'AssetClass': 'ALL Total',
            'IssuerFundHouse': '',
            'NumberOfUnit': '',
            'NavUnit': '',
            'CostOfInvestment': totalCostOfInvestment,
            'AverageCostPerUnit': '',
            'MarketValue': totalMarketValue,
            'UnrealizedGL': totalUnrealizedGL,
            'UnrealizedGLPerc': totalUnrealizedGLPerc,
            'PercentWeight': '',
        });


        return products.concat(sumTotal);
    },

    calculatePercentWeight: function (products) {
        var indexOfAllTotal = products.findIndex((m) => {
            return (m.AssetClass == 'ALL Total' || m.UnitHolderNo == 'ALL Total')
        });
        var totalCostOfInvestment = products[indexOfAllTotal].CostOfInvestment;
        for (let i = 0; i < products.length; i++) {
            // if (products[i].AssetClass != 'ALL Total' && products[i].UnitHolderNo != 'ALL Total') {
            products[i].PercentWeight = (products[i].CostOfInvestment / totalCostOfInvestment) * 100;
            // }
        }

        return products;
    },

    calculatePercentWeightPerPort: function (products) {
        for (let i = 0; i < products.length; i++) {
            var indexOfTotal = products.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo && m.ProductName == 'Total')
            });
            var totalCostOfInvestment = products[indexOfTotal].CostOfInvestment;
            products[i].PercentWeight = (products[i].CostOfInvestment / totalCostOfInvestment) * 100;
        }

        return products;
    },

    sortInvestmentProduct2: function (products) {
        // "Asset Class(ASC)" then "Market Value(DESC)" then "Unit Holder No.(ASC)" then "Product Name (ASC)"
        return products.sort(function (a, b) {
            var returnValue = 0;
            if (a.UnitHolderNo == b.UnitHolderNo) {
                if (a.AssetClass == b.AssetClass) {
                    if (a.MarketValue == b.MarketValue) {
                        // Product Name (ASC)
                        if (a.ProductName > b.ProductName) {
                            returnValue = 1;
                        } else if (a.ProductName < b.ProductName) {
                            returnValue = -1;
                        }
                    }
                    // Market Value.(DESC)
                    if (a.MarketValue < b.MarketValue) {
                        returnValue = 1;
                    } else if (a.MarketValue < b.MarketValue) {
                        returnValue = -1;
                    }
                }
                // AssetClass (ASC)
                if (a.AssetClass > b.AssetClass) {
                    returnValue = 1;
                } else if (a.AssetClass < b.AssetClass) {
                    returnValue = -1;
                }
                // Move #N/A be bottom
                if (a.AssetClass == '#N/A' && b.AssetClass != '#N/A') {
                    returnValue = 1;
                } else if (a.AssetClass != '#N/A' && b.AssetClass == '#N/A') {
                    returnValue = -1;
                }
                // Move #N/A be bottom
                if (!a.AssetClass && b.AssetClass) {
                    returnValue = 1;
                } else if (a.AssetClass && !b.AssetClass) {
                    returnValue = -1;
                }
                // Move isError bottom
                if (a.isError && !b.isError) {
                    returnValue = 1;
                } else if (!a.isError && b.isError) {
                    returnValue = -1;
                }
                if (b.ProductName == 'Total') {
                    returnValue = 1;
                } else if (a.ProductName == 'Total') {
                    returnValue = -1;
                }
            }
            // UnitHolderNo (ASC)
            if (a.UnitHolderNo > b.UnitHolderNo) {
                returnValue = 1;
            } else if (a.UnitHolderNo < b.UnitHolderNo) {
                returnValue = -1;
            }
            if (b.UnitHolderNo == 'ALL Total') {
                returnValue = -1;
            } else if (a.UnitHolderNo == 'ALL Total') {
                returnValue = 1;
            }
            return returnValue;
        });
    },

    sortInvestmentProduct: function (products) {
        // "Asset Class(ASC)" then "Market Value(DESC)" then "Unit Holder No.(ASC)" then "Product Name (ASC)"
        return products.sort(function (a, b) {
            var returnValue = 0;
            if (a.AssetClass == b.AssetClass) {
                if (a.MarketValue == b.MarketValue) {
                    if (a.UnitHolderNo == b.UnitHolderNo) {
                        // Product Name (ASC)
                        if (a.ProductName > b.ProductName) {
                            returnValue = 1;
                        } else if (a.ProductName < b.ProductName) {
                            returnValue = -1;
                        }
                    }
                    // Unit Holder No.(ASC)
                    if (a.UnitHolderNo > b.UnitHolderNo) {
                        returnValue = 1;
                    } else if (a.UnitHolderNo < b.UnitHolderNo) {
                        returnValue = -1;
                    }
                }
                // Market Value(DESC)
                if (a.MarketValue < b.MarketValue) {
                    returnValue = 1;
                } else if (a.MarketValue > b.MarketValue) {
                    returnValue = -1;
                }

                if (b.ProductName == 'Total') {
                    returnValue = 1;
                } else if (a.ProductName == 'Total') {
                    returnValue = -1;
                }
            }
            // Asset Class(ASC)
            if (a.AssetClass > b.AssetClass) {
                returnValue = 1;
            } else if (a.AssetClass < b.AssetClass) {
                returnValue = -1;
            }
            // Move #N/A be bottom
            if (a.AssetClass == '#N/A' && b.AssetClass != '#N/A') {
                returnValue = 1;
            } else if (a.AssetClass != '#N/A' && b.AssetClass == '#N/A') {
                returnValue = -1;
            }
            // Move #N/A be bottom
            if (!a.AssetClass && b.AssetClass) {
                returnValue = 1;
            } else if (a.AssetClass && !b.AssetClass) {
                returnValue = -1;
            }
            // Move isError bottom
            if (a.isError && !b.isError) {
                returnValue = 1;
            } else if (!a.isError && b.isError) {
                returnValue = -1;
            }
            if (b.AssetClass == 'ALL Total') {
                returnValue = -1;
            } else if (a.AssetClass == 'ALL Total') {
                returnValue = 1;
            }
            return returnValue;
        });
    },

    sumTotalEachUnitHolderInvestmentProduct: function (component, products) {
        var sumTotal = [];
        var totalCostOfInvestment = 0;
        var totalMarketValue = 0;
        var totalUnrealizedGL = 0;
        var totalUnrealizedGLPerc = 0;
        for (let i = 0; i < products.length; i++) {
            var index = sumTotal.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo && m.ProductName == 'Total')
            });
            if (products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) {
                if (index === -1) {
                    sumTotal.push({
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': '',
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment':  products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': products[i].MarketValue,
                        'UnrealizedGL': products[i].UnrealizedGL,
                        'UnrealizedGLPerc': (products[i].UnrealizedGL / products[i].CostOfInvestment) * 100,
                        'PercentWeight': '',
                    });
                } else {
                    sumTotal[index] = {
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': '',
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': sumTotal[index].CostOfInvestment + products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': sumTotal[index].MarketValue + products[i].MarketValue,
                        'UnrealizedGL': sumTotal[index].UnrealizedGL + products[i].UnrealizedGL,
                        'UnrealizedGLPerc': ((sumTotal[index].UnrealizedGL + products[i].UnrealizedGL) /
                            (sumTotal[index].CostOfInvestment + products[i].CostOfInvestment)) *
                            100,
                        'PercentWeight': '',
                    };
                }

                totalCostOfInvestment = totalCostOfInvestment + products[i].CostOfInvestment;
                totalMarketValue =  totalMarketValue + products[i].MarketValue;
                totalUnrealizedGL = totalUnrealizedGL + products[i].UnrealizedGL;
                totalUnrealizedGLPerc =  (totalUnrealizedGL / totalCostOfInvestment) * 100 ;
            }
        }

        sumTotal.push({
            'Type': $A.get('$Label.c.Investment_Product_Details'),
            'UnitHolderNo': 'ALL Total',
            'FundCode': '',
            'ProductName': 'Total',
            'AssetClass': '',
            'IssuerFundHouse': '',
            'NumberOfUnit': '',
            'NavUnit': '',
            'CostOfInvestment': totalCostOfInvestment,
            'AverageCostPerUnit': '',
            'MarketValue':  totalMarketValue,
            'UnrealizedGL': totalUnrealizedGL,
            'UnrealizedGLPerc': totalUnrealizedGLPerc,
            'PercentWeight': '',
        });
        return products.concat(sumTotal);
    },

    genHiddenDataTable : function(component, datas, table){
        let hideUnitHolder = false;
        let arrColumn = [];
        let columns =  component.get(`v.${table}.columns`);
        const fieldAccess = JSON.parse(component.get('v.fieldAccessible'));
        datas.forEach(element => {
            element.AssetClass = fieldAccess['Investment_AssetClass'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.AssetClass;
            element.ProductName = fieldAccess['Investment_ProductName'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.ProductName;
            element.UnitHolderNo = fieldAccess['Investment_UnitHolderNo'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.UnitHolderNo;
            if(fieldAccess['Investment_UnitHolderNo'] == false){
                hideUnitHolder = true;
            }
            element.IssuerFundHouse = fieldAccess['Investment_IssuerFundHouse'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.IssuerFundHouse;
            element.NumberOfUnit = fieldAccess['Investment_NumberOfUnit'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.NumberOfUnit;
            element.NavUnit = fieldAccess['Investment_NavUnit'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.NavUnit;
            element.CostOfInvestment = fieldAccess['Investment_CostOfInvestment'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.CostOfInvestment;
            element.AverageCostPerUnit = fieldAccess['Investment_AverageCostPerUnit'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.AverageCostPerUnit;
            element.MarketValue = fieldAccess['Investment_MarketValue'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.MarketValue;
            element.UnrealizedGL = fieldAccess['Investment_UnrealizedGL'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.UnrealizedGL;
            element.UnrealizedGLPerc = fieldAccess['Investment_UnrealizedGLPerc'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.UnrealizedGLPerc;
            element.PercentWeight = fieldAccess['Investment_PercentWeight'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : element.PercentWeight;
        });
        if(component.get('v.hiddenHigh') == true){
            columns.forEach((e) => {
                if(e.type == 'button'){
                    e = {
                        label: $A.get('$Label.c.Unit_Holder_No'),
                        fieldName: 'UnitHolderNo',
                        wrapText: true,
                        type: 'text',
                        cellAttributes: {alignment: 'left'},
                        fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
                    }
                }
                else{
                    e.type = 'text';
                }
                arrColumn.push(e);
            });
        }
        else if(component.get('v.hiddenLow') == true && component.get('v.hiddenHigh') == false){
            datas.forEach((e) => {
                e.ProductName = $A.get('$Label.c.Data_Condition_Hidden_Text');
            });
            columns.forEach((e) => {
                arrColumn.push(e);
            });
        }
        // if(component.get('v.hiddenLow') == true){
            // datas.forEach((e) => {
                // e.ProductName = $A.get('$Label.c.Data_Condition_Hidden_Text');
            // })
        // }
        component.set(`v.${table}.columns`, arrColumn);
        component.set(`v.${table}.datas`, datas);
    },

    getAccessibleCusHold: function (component, event, helper) {
        var action = component.get('c.getAccessibleCustHolding');
        action.setParams({
            'accountId': component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.accessibleCusHold', JSON.stringify(result));
                const accessible = JSON.parse(JSON.stringify(result));
                if(accessible['isAccessibleCusHoldLow'] == false){
                    component.set('v.hiddenLow', true);
                }
                if(accessible['isAccessibleCusHoldHig'] == false){
                    component.set('v.hiddenHigh', true);
                }
            }
            else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
            }
        });
        $A.enqueueAction(action);
    },

    getFieldAccessibility: function (component, event, helper) {
        return new Promise((resolve, reject) => {
            var action = component.get('c.getFieldVisibilityByPage');
            action.setParams({
                'recordId': component.get('v.recordId'),
                'pageName': 'RetailProductHoldingSummary'
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    resolve(JSON.stringify(result));
                }
                else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message)
                    });
                    reject(error.message);
                }
            });
            $A.enqueueAction(action);
        });
    },

    replaceAt: function (value, index, replacement) {
        return value.substr(0, index) + replacement + value.substr(index + replacement.length);
    },
})