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

    displayErrorMessage: function (component, title, errMsg) {
        component.set('v.error.state', true);
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.message', errMsg);
    },

    displaySubErrorMessage: function (component, title, errMsg, type) {
        component.set('v.error.state', true);
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.messages.' + type, errMsg);
    },

    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },

    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },

    replaceAt: function (value, index, replacement) {
        return value.substr(0, index) + replacement + value.substr(index + replacement.length);
    },

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    doInit: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");

        var recordId = component.get('v.recordId');
        var tmbCustId = component.get('v.tmbCustId');
        var theme = component.get('v.theme');

        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));

        // component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
        component.set('v.tmbCustId', tmbCustId ? tmbCustId : (pageReference ? pageReference.state.c__TMB_Cust_Id : ''));
        component.set('v.theme', theme ? theme : (pageReference ? pageReference.state.c__theme : ''));
        
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);

        helper.doWorkspaceAPI(component);
        helper.getCustomerData(component, event, helper);
        helper.getEncrypt0(component, event, helper);
    },

    getEncrypt0: function (component, event, helper){
        var action = component.get('c.get0EncryptString');

        action.setParams({
            'val': 0,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.zeroEncryptString', result);
            }else if(state === 'ERROR'){
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },

    getCustomerData: function (component, event, helper){
        var action = component.get('c.getAccount');

        action.setParams({
            'recId': component.get('v.recordId'),
            'fields': ['Name', 'TMB_Customer_ID_PE__c', 'RTL_Is_Employee__c', 'RTL_Suitability__c'],
            'trans_fields': []
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.account', result);
            }else if(state === 'ERROR'){
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    
    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
    },

    doInitErrorMessageControl: function (component, event, helper) {
        var errorMessageControlObj = {
            showMessage: false,
            someInfoError: false,
            noTmbcust: false,
            message: '',
            productName: {
                OSC: $A.get('$Label.c.Deposit_Product_Details') + ', ' + $A.get('$Label.c.Loan_Product_Details') + ', ' + $A.get('$Label.c.Investment_Product_Details') + ' ',
                Deposit: $A.get('$Label.c.Deposit_Product_Details'),
                CardBal: $A.get('$Label.c.Credit_Card_RDC_Product_Details'),
                Loan: $A.get('$Label.c.Loan_Product_Details'),
                Bancassurance: $A.get('$Label.c.Bancassurance_Product_Details'),
                Investment: $A.get('$Label.c.Investment_Product_Details'),
                retry: ''
            },
            productTag: {
                Deposit: 'Deposit_Product_Details',
                CardBal: 'Credit_Card_RDC_Product_Details',
                Loan: 'Loan_Product_Details',
                Bancassurance: 'Bancassurance_Product_Details',
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
                OSC: false,
                Deposit: false,
                CardBal: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
            },
            error: {
                OSC: false,
                Deposit: false,
                CardBal: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
            },
            retry: {
                OSC: false,
                CardBal: false,
                Bancassurance: false
            },
            products: [],
            productErrors: {},
            noAuthorized: false,
            hrefList: ''
        }
        component.set("v.errorMessageControl", errorMessageControlObj);
    },

    doInitProductSummarized: function (component, event, helper) {
        component.set('v.productSummarized.isLoading', true);
        component.set('v.depositProduct.isLoading', true);
        component.set('v.creditCardRDCProduct.isLoading', true);
        component.set('v.autoLoanProduct.isLoading', true);
        component.set('v.bancassuranceProduct.isLoading', true);
        component.set('v.investmentProduct.isLoading', true);
        component.set('v.productSummarized.columns', [{
            label: $A.get("$Label.c.Product_Group"),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'Product_Group'
                },
                title: {
                    fieldName: 'Product_Group'
                },
                name: {
                    fieldName: 'Product_Group'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 300,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Number_of_Product"),
            fieldName: 'Number_of_Product',
            type: 'number',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'center',
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Number_of_Account"),
            fieldName: 'Number_of_Account',
            type: 'number',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'center',
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Outstanding"),
            fieldName: 'MarkedOutstanding',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get("$Label.c.Limit_ODLimit"),
            fieldName: 'MarkedODLimit',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : null;
            }
            return m;
        })); 
    },

    checkIsReadyToSum: function(component, event, helper){
        let arr = component.get('v.errorSection').split(',');
        let errorSectionList = [];
        let index = 0;
        arr.forEach((e) => {
            if(index < arr.length - 1){
                errorSectionList.push(e);
            }
            index++;
        });
            component.set('v.lengthOfErrorList', errorSectionList.length);
            if(errorSectionList.includes('Deposit_Product_Details')){
                helper.genRedErrorSection(component, 'Deposit_Product_Details', $A.get('$Label.c.Deposit_Product_Details'), 'DopositProdError');
            }
            if(errorSectionList.includes('Credit_Card_RDC_Product_Details')){
                helper.genRedErrorSection(component, 'Credit_Card_RDC_Product_Details', $A.get('$Label.c.Credit_Card_RDC_Product_Details'), 'CreditCardProdError');
            }
            if(errorSectionList.includes('Loan_Product_Details')){
                helper.genRedErrorSection(component, 'Loan_Product_Details', $A.get('$Label.c.Loan_Product_Details'), 'loanError');
            }
            if(errorSectionList.includes('AutoLoan_Product_Details')){
                helper.genRedErrorSection(component, 'AutoLoan_Product_Details', $A.get('$Label.c.Auto_loan_HP'), 'AutoloanError');
            }
            if(errorSectionList.includes('Bancassurance_Product_Details')){
                helper.genRedErrorSection(component, 'Bancassurance_Product_Details',  $A.get('$Label.c.Bancassurance_Product_Details'), 'bancAssuranceError');
            }
            if(errorSectionList.includes('Investment_Product_Details')){
                helper.genRedErrorSection(component, 'Investment_Product_Details', $A.get('$Label.c.Investment_Product_Details'), 'InvestmentProdError');
            }
            helper.calculateSummarizedProduct(component, helper);
    },


    calculateSummarizedProduct: function (component, helper) {
        if(component.get('v.depositProductReturn') == true && component.get('v.autoLoanReturn') == true && component.get('v.bancassuranceReturn') == true && component.get('v.loanProductReturn') == true && component.get('v.creditCardRDCProductReturn') == true && component.get('v.investmentProductReturn') == true){
            var products = component.get('v.depositProduct.datas')
                        .concat(component.get('v.creditCardRDCProduct.datas'))
                        .concat(component.get('v.investmentProduct.datas'))
                        .concat(component.get('v.bancassuranceProduct.datas'))
                        .concat(component.get('v.loanProduct.datas'))
                        .concat(component.get('v.autoLoanProduct.datas'));
            let finalDatas = helper.genFinalDatas(component, products);
            const accessible = JSON.parse(component.get('v.accessibleCusHold'));
            if(accessible['isAccessibleCusHoldLow'] == true){
                helper.genHiddenTable(component, helper, finalDatas);
            }
            else{
                component.set('v.productSummarized.datas', finalDatas);
            }
            component.set('v.productSummarized.isLoading', false);
            helper.updateAUMData(component, helper, finalDatas);
        }
    },

    genFinalDatas: function(component, products){
        const fieldAccess = JSON.parse(component.get('v.fieldAccess'));
        let Number_of_Account = 0;
        let Number_of_Product = 0;
        products.forEach((item, index, object) => {
            if(item.SeqGrp == 'OTHERS'){
                Number_of_Account += item.Number_of_Account;
                Number_of_Product += item.Number_of_Product;
                object.splice(index, 1);
            }
        });
        const otherObj = {
            ERROR: '',
            SeqGrp: 'OTHERS',
            Product_Group: 'Others',
            Number_of_Product: fieldAccess['ProductSum_Number_of_Product'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : Number_of_Account,
            Number_of_Account: fieldAccess['ProductSum_Number_of_Account'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : Number_of_Account,
            MarkedOutstanding: fieldAccess['ProductSum_MarkedOutstanding'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '-',
            MarkedODLimit: fieldAccess['ProductSum_MarkedODLimit'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '-',
            Hidden: $A.get('$Label.c.Data_Condition_Hidden_Text'),
            Number_of_Account_AUM: Number_of_Account
        };
        
        products.push(otherObj);
        return products;
    },

    genHiddenTable: function(component, helper, finalDatas){
        const fieldAccess = JSON.parse(component.get('v.fieldAccess'));
        const columns = component.get('v.productSummarized.columns');
        let hideProdGroup = false;
        let hideNumProd = false;
        let hideNumAcc = false;
        let hideMaredOut = false;
        let hideMardOd = false;
        let arrColumn = [];
        finalDatas.forEach((e) => {
            e.Product_Group = fieldAccess['ProductSum_Product_Group'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : e.Product_Group;
            if(fieldAccess['ProductSum_Product_Group'] == false){
                hideProdGroup = true;
            }
            e.Number_of_Product = fieldAccess['ProductSum_Number_of_Product'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : e.Number_of_Product;
            if(fieldAccess['ProductSum_Number_of_Product'] == false){
                hideNumProd = true;
            }
            e.Number_of_Account = fieldAccess['ProductSum_Number_of_Account'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : e.Number_of_Account;
            if(fieldAccess['ProductSum_Number_of_Account'] == false){
                hideNumAcc = true;
            }
            e.MarkedOutstanding = fieldAccess['ProductSum_MarkedOutstanding'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : e.MarkedOutstanding;
            if(fieldAccess['ProductSum_MarkedOutstanding'] == false){
                hideMaredOut = true;
            }
            e.MarkedODLimit = fieldAccess['ProductSum_MarkedODLimit'] == false ? $A.get('$Label.c.Data_Condition_Hidden_Text') : e.MarkedODLimit;
            if(fieldAccess['ProductSum_MarkedODLimit'] == false){
                hideMardOd = true;
            }
        });
        columns.forEach((e) => {
            if(e.label == $A.get("$Label.c.Product_Group")){
                e = hideProdGroup == true ? {
                    label: $A.get("$Label.c.Product_Group"),
                    fieldName: 'Product_Group',
                    type: 'text',
                    cellAttributes: {
                        class: {
                            fieldName: 'ERROR'
                        },
                        alignment: 'left'
                    },
                } : e;
            }
            else if(e.label == $A.get("$Label.c.Number_of_Product")){
                e.type = hideNumProd == true ? 'text' : e.type;
            }
            else if(e.label == $A.get("$Label.c.Limit_ODLimit")){
                e.type = hideMardOd == true ? 'text' : e.type;
            }
            else if(e.label == $A.get("$Label.c.Outstanding")){
                e.type = hideMaredOut == true ? 'text' : e.type;
            }
            else if(e.label == $A.get("$Label.c.Number_of_Account")){
                e.type = hideNumAcc == true ? 'text' : e.type;
            }
            arrColumn.push(e);
        })
        component.set('v.productSummarized.datas', finalDatas);
        component.set('v.productSummarized.columns', arrColumn);
    },

    doWorkspaceAPI: function (component, event, helper) {
        var tabName = $A.get('$Label.c.Product_Holding');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:product",
                iconAlt: tabName,
            });

        }).catch(function (error) {
            console.log(error);
        });
    },

    callProduct: function (component, event, helper, round) {

        var action = component.get('c.getProduct');
        action.setParams({
            "recordId": component.get('v.account.Id'),
            "rmId": helper.getTMBCustID(component).substring(14),
            "FiiDent": helper.getTMBCustID(component).substring(0, 16),
            'tmbCustId': helper.getTMBCustID(component),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    if (result.StatusCode == '500') {
                        component.find('investmentSummaryView').set('v.resultFrom01', result);
                        component.find('loanProductSummaryView').set('v.resultFrom01', result);
                        // component.find('depositProductSummaryView').set('v.resultFrom01', result);
                        helper.displayErrorMessage(component, 'Warning!', result.Message);
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        component.set('v.errorMessageControl.isShowMessage.Info', true);
                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        round++;
                        // console.log('retry  callProduct round: ', round, '| ', new Date());
                        setTimeout(() => {
                            helper.callProduct(component, event, helper, round);
                        }, component.get("v.retrySetTimeOut"));
                    } else if ((result.StatusCode == "401") || (result.Message && (result.Message.includes('Sorry, some error occurred') || result.Message.includes('SNOW')))) {
                        component.find('investmentSummaryView').set('v.resultFrom01', result);
                        component.find('loanProductSummaryView').set('v.resultFrom01', result);
                        component.find('depositProductSummaryView').set('v.resultFrom01', result);
                        component.set('v.errorMessageControl.error.OSC', true);
                        component.set('v.errorMessageControl.message', result.Message);
                        helper.displayErrorMessage(component, 'Warning!', result.Message);
                    } else if (result.Message && result.Message.includes($A.get("$Label.c.INT_No_Active_Product"))) { //BAU11438_INC0179846                                                       
                        component.set('v.depositProduct.isLoading', false);
                        component.set('v.loanProduct.isLoading', false);
                        component.set('v.investmentProduct.isLoading', false);
                        component.set('v.productSummarized.isLoading', false);
                    }
                    else{
                        component.find('investmentSummaryView').set('v.resultFrom01', result);
                        component.find('loanProductSummaryView').set('v.resultFrom01', result);
                        component.find('depositProductSummaryView').set('v.resultFrom01', result);
                        component.set('v.result', result);
                        component.set('v.haveOSC01Result', true);
                    }
                        
                } else {
                    helper.setIsLoadingProduct(component, false);
                    helper.displayErrorMessage(component, 'Warning!', $A.get('$Label.c.Data_Condition_NotAuthorizedMsg'));
                    component.set('v.errorMessageControl.noAuthorized', true);
                }
            } 
            else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
            }
            else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
                if ((errors[0].message == undefined || errors[0].message.includes('UNABLE_TO_LOCK_ROW')) && !component.get('v.isAutoRetryOSC01')) {
                    component.set('v.isAutoRetryOSC01', true);
                    helper.callProduct(component, event, helper, round);
                }
            }
        });
        $A.enqueueAction(action);
    },

    genRedErrorSection: function(component, tag, body, attr){
        const len = component.get('v.lengthOfErrorList') - 1;
        $A.createComponent("aura:html", {
            tag: "a",
            HTMLAttributes: {
                class: 'notFound',
                name: tag,
                onclick: component.getReference("c.handleErrorSectionAfterClick")
            },
            // body: body + ' ' ,
            body:  len > 0 ? body + ', ' : body,
        },  function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set(`v.${attr}`,cmp);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set('v.lengthOfErrorList', len);
    },

    checkedServiceFromErrorMessageControl: function (checkObject) {
        return Object.keys(checkObject).reduce((l, key) => l || checkObject[key], false);
        // return checkObject.Bancassurance || checkObject.CardBal || checkObject.Deposit || checkObject.Investment || checkObject.Loan || checkObject.OSC;
    },

    createComponentProductReference: function (component, isCreate, Tag, Type, onClickProduct) {
        if (isCreate) {
            return [
                "aura:html", {
                    tag: "a",
                    HTMLAttributes: {
                        // style: 'display: block;',
                        class: 'notFound',
                        name: Tag,
                        'data-namehref': onClickProduct,
                        onclick: component.getReference('c.onClickHref')
                    },
                    body: Type,
                }
            ];
        }
        return [];
    },

    getAccessibleCusHold: function (component, event, helper) {
        return new Promise((resolve, reject) => {
            var action = component.get('c.getAccessibleCustHolding');
            action.setParams({
                'accountId': component.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    component.set('v.accessibleCusHold', JSON.stringify(result));
                    if(result['isAccessibleCusHoldLow'] == true){
                        component.set('v.allowCallChild', true);
                    }
                    else{
                        component.set('v.allowCallChild', false);
                    }
                    resolve(result);
                }
                else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message)
                    });
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        });
    },

    getFieldVisibility: function(component, event, helper){
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
                    component.set('v.fieldAccess', JSON.stringify(result));
                    resolve(result);
                }
                else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message)
                    });
                    reject(errors);
                }
            });
            $A.enqueueAction(action);
        });
    },

    getIsUnmaskData: function (component, helper) {
        var action = component.get('c.getAllUnmaskBalance');
        var returnValue = "{}";
        var jsonData;
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            jsonData = JSON.parse(returnValue);
            component.set('v.unmasked', jsonData);
        });

        $A.enqueueAction(action);
    },

    genDefaultEachSeqGrp: function(component, event, helper){
        component.set('v.seq1default', [
            {
                "ERROR":"",
                "SeqGrp":"1",
                "Tag":"Deposit_Product_Details",
                "Product_Group":"Transactional Deposit",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "MarkedODLimit":"-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "AUM": component.get('v.zeroEncryptString'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq2default', [
            {
                "ERROR":"",
                "SeqGrp":"2",
                "Tag":"Deposit_Product_Details",
                "Product_Group":"Non Transactional Deposit",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding":"-",
                "MarkedODLimit":"-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "AUM": component.get('v.zeroEncryptString'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq3default', [
            {
                "ERROR":"",
                "SeqGrp":"3",
                "Tag":"Credit_Card_RDC_Product_Details",
                "Product_Group":"Credit Card",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "MarkedODLimit": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq5default', [
            {
                "ERROR":"",
                "SeqGrp":"5",
                "Tag":"Investment_Product_Details",
                "Product_Group":"Mutual Fund",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": "-",
                "MarkedODLimit":"-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "AUM": component.get('v.zeroEncryptString'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq6default', [
            {
                "ERROR":"",
                "SeqGrp":"6",
                "Tag":"Bancassurance_Product_Details",
                "Product_Group":"Bancassurance",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding":"-",
                "MarkedODLimit":"-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq7default', [
            {
                "ERROR":"",
                "SeqGrp":"7",
                "Tag":"Loan_Product_Details",
                "Product_Group":"Personal Loan",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "MarkedODLimit": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seq8default', [
            {
                "ERROR":"",
                "SeqGrp":"8",
                "Tag":"Loan_Product_Details",
                "Product_Group":"Secured Loan",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "MarkedODLimit": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seqAutodefault', [
            {
                "ERROR":"",
                "SeqGrp":"AutoLoan",
                "Tag":"AutoLoan_Product_Details",
                "Product_Group":"Auto Loan",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "MarkedODLimit": helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : "-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": component.get('v.zeroEncryptString')
            }]
        );

        component.set('v.seqOtherdefault', [
            {
                "ERROR":"",
                "SeqGrp":"OTHERS",
                "Product_Group":"Others",
                "Number_of_Product":0,
                "Number_of_Account":0,
                "MarkedOutstanding":"-",
                "MarkedODLimit":"-",
                "Hidden":$A.get('$Label.c.Data_Condition_Hidden_Text'),
                "Number_of_Account_AUM": 0
            }]
        );
    },

    updateAUMData: function (component, helper, dataForAUM) {
        var action = component.get('c.updateAUMField');
        action.setParams({
            'recordId': component.get('v.recordId'),
            'dataList': dataForAUM,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
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

       // parseSummarizedProduct: function (component, list) {
        // var helper = this;
// 
        // const mappingField = {
            // '1': {
                // NumOfAccocunt: 'AccountNumber',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'LedgerBalance',
                // ODLimit: 'ODLimit'
            // },
            // '2': {
                // NumOfAccocunt: 'AccountNumber',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'LedgerBalance',
                // ODLimit: 'ODLimit'
            // },
            // '3': {
                // NumOfAccocunt: 'CardNumber',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'Outstanding',
                // ODLimit: 'VLimit'
            // },
            // '5': {
                // NumOfAccocunt: 'UnitHolderNo',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'MarketValue'
            // },
            // '6': {
                // NumOfAccocunt: 'POLICY_NO',
                // NumOfProduct: 'ProductName',
            // },
            // '7': {
                // NumOfAccocunt: 'AccountNumber',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'Outstanding',
                // ODLimit: 'VLimit'
            // },
            // '8': {
                // NumOfAccocunt: 'AccountNumber',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'Outstanding',
                // ODLimit: 'VLimit'
            // },
            // 'AutoLoan': {
                // NumOfAccocunt: 'HP_Account_No',
                // NumOfProduct: 'ProductName',
                // OutStanding: 'Outstanding',
                // ODLimit: 'ODLimit'
            // },
            // 'OTHERS': {
                // NumOfAccocunt: ['UnitHolderNo', 'POLICY_NO', 'AccountNumber', 'CardNumber'],
                // NumOfProduct: 'ProductName',
                // OutStanding: ['OutStanding', 'Outstanding', 'MarketValue', 'LedgerBalance'],
                // ODLimit: ['ODLimit', 'VLimit']
            // },
        // };
// 
// 
        // const finalObj =  [
            // {
                // 'Product_Group': 'Transactional Deposit',
                // 'SeqGrp': '1',
                // 'Tag': 'Deposit_Product_Details'
            // },
            // {
                // 'Product_Group': 'Non Transactional Deposit',
                // 'SeqGrp': '2',
                // 'Tag': 'Deposit_Product_Details'
            // },
            // {
                // 'Product_Group': 'Credit Card',
                // 'SeqGrp': '3',
                // 'Tag': 'Credit_Card_RDC_Product_Details'
            // },
            // {
                // 'Product_Group': 'Mutual Fund',
                // 'SeqGrp': '5',
                // 'Tag': 'Investment_Product_Details'
            // },
            // {
                // 'Product_Group': 'Bancassurance',
                // 'SeqGrp': '6',
                // 'Tag': 'Bancassurance_Product_Details'
            // },
            // {
                // 'Product_Group': 'Personal Loan',
                // 'SeqGrp': '7',
                // 'Tag': 'Loan_Product_Details'
            // },
            // {
                // 'Product_Group': 'Secured Loan',
                // 'SeqGrp': '8',
                // 'Tag': 'Loan_Product_Details'
            // },
            // {
                // 'Product_Group': 'Auto Loan',
                // 'SeqGrp': 'AutoLoan',
                // 'Tag': 'AutoLoan_Product_Details'
            // },
            // {
                // 'Product_Group': 'Others',
                // 'SeqGrp': 'OTHERS',
            // },
        // ].map(function (m) {
            // var thisProduct = list[0] != undefined ? list.filter(function (f) {
                // return f.SeqGrp == m.SeqGrp;
            // }) : [];
// 
            // m.ERROR = m.SeqGrp != 'OTHERS' && thisProduct.some(function (i) {
                // return i.isError;
            // }) ? 'notFound' : '';
// 
            // m.Number_of_Account = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                // if (!l.find(function (f) {
                    // return f[mappingField[m.SeqGrp].NumOfAccocunt] == i[mappingField[m.SeqGrp].NumOfAccocunt];
                // })) {
                    // l.push(i);
                    // console.log('Number of Account : '+l);
                // }
                // return l;
            // }, []).length : thisProduct.reduce(function (l, i) {
                // mappingField[m.SeqGrp].NumOfAccocunt.forEach(function (v) {
                    // if (i[v] && !l.find(function (s) {
                        // return s[v] == i[v];
                    // })) {
                        // l.push(i);
                    // }
                // });
                // return l;
            // }, []).length;
// 
            // m.Number_of_Product = thisProduct.reduce(function (l, i) {
                // if (
                    // !l.find(function (f) {
                        // return f[mappingField[m.SeqGrp].NumOfProduct] == i[mappingField[m.SeqGrp].NumOfProduct];
                    // }) ||
                    // i[mappingField[m.SeqGrp].NumOfProduct] == '#N/A' ||
                    // !i[mappingField[m.SeqGrp].NumOfProduct] ||
                    // i.isError) {
                    // l.push(i);
                // }
                // return l;
            // }, []).length;
// 
            // m.Outstanding = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                // console.log('Not Others');
                // console.log('Tag :'+i.Tag);
                // console.log('Sum Outstanding :'+l);
                // l += i[mappingField[m.SeqGrp].OutStanding] ? i[mappingField[m.SeqGrp].OutStanding] : 0;
                // return l;
            // }, 0) : thisProduct.reduce(function (l, i) {
                // console.log('Not Other : '+JSON.stringify(mappingField[m.SeqGrp].OutStanding));
                // l += mappingField[m.SeqGrp].OutStanding.reduce(function (y, x) {
                    // console.log('x :'+x);
                    // console.log('Sum Outstanding :'+l);
                    // if (i.Tag == 'Deposit_Product_Details' && x == 'OutStanding') return y;
                    // return y + (i[x] ? i[x] : 0);
                // }, 0);
                // console.log('Others');
// 
                // return l;
            // }, 0);
// 
            // m.Limit_ODLimit = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                // l += i[mappingField[m.SeqGrp].ODLimit] ? i[mappingField[m.SeqGrp].ODLimit] : 0;
                // return l;
            // }, 0) : thisProduct.reduce(function (l, i) {
                // l += mappingField[m.SeqGrp].ODLimit.reduce(function (y, x) {
                    // return y + (i[x] ? i[x] : 0);
                // }, 0);
                // return l;
            // }, 0);
            // return m;
        // }).reduce(function (l, i, index) {
            // var MarkedOutstanding = i.Outstanding.toLocaleString('en-US', {
                // style: 'decimal',
                // minimumFractionDigits: 0,
                // maximumFractionDigits: 0
            // });
            // MarkedOutstanding = helper.replaceAt(MarkedOutstanding, MarkedOutstanding.length - 2, 'xx')
            // var MarkedODLimit = i.Limit_ODLimit.toLocaleString('en-US', {
                // style: 'decimal',
                // minimumFractionDigits: 0,
                // maximumFractionDigits: 0
            // });
// 
            // var IsUnmasked = component.get("v.unmasked");
            // var IsOutStanding;
            // var IsODLimit;
            // var IsOutStandingLimit = IsUnmasked == null || IsUnmasked["Summary_Section"] == undefined;
            // if (!IsOutStandingLimit) {
                // IsOutStanding = IsUnmasked["Summary_Section"]["SummaryString"];
                // IsODLimit = IsUnmasked["Summary_Section"]["SummaryODLimit"];
            // }
// 
            // MarkedOutstanding = i.Outstanding == 0 ? '-' : (IsOutStandingLimit ? MarkedOutstanding : (!IsOutStanding ? MarkedOutstanding : i.Outstanding.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })));
            // MarkedODLimit = i.Limit_ODLimit == 0 ? '-' : (IsOutStandingLimit ? MarkedODLimit : (!IsODLimit ? MarkedODLimit : i.Limit_ODLimit.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })));
// 
            // l.push({
                // 'ERROR': i.ERROR,
                // 'SeqGrp': i.SeqGrp,
                // 'Tag': i.Tag,
                // 'Product_Group': i.Product_Group,
                // 'Number_of_Product': i.Number_of_Product,
                // 'Number_of_Account': i.Number_of_Account,
                // 'MarkedOutstanding': (helper.isEmployee(component) && (i.SeqGrp == '1'|| i.SeqGrp == '3' || i.SeqGrp == '7' || i.SeqGrp == '8' || i.SeqGrp == 'AutoLoan' )) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : MarkedOutstanding,
                // 'MarkedODLimit': (helper.isEmployee(component) && (i.SeqGrp == '3' || i.SeqGrp == '7' || i.SeqGrp == '8' || i.SeqGrp == 'AutoLoan')) ?  $A.get('$Label.c.Data_Condition_Hidden_Text') : MarkedODLimit,
                // 'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            // });
            // return l;
        // }, []);
        // console.log(JSON.stringify(finalObj));
        // return finalObj;
    // },

})