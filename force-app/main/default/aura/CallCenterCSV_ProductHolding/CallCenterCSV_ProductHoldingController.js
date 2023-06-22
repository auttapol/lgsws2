({

    onInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var pageReference = component.get("v.pageReference");
        var theme = component.get('v.theme');

        component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
        component.set('v.theme', theme ? theme : (pageReference ? pageReference.state.c__theme : ''));
        component.set('v.openNewProductHolding', true);
    },
    // onInit: function (component, event, helper) {
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getEnclosingTabId().then(function (tabId) {
            // var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
            // workspaceAPI.getTabInfo({
                // tabId: primaryTab
            // }).then(function (response) {
                // var subTab = response.subtabs.filter(function (f) {
                    // return f.pageReference.attributes.componentName == "c__CallCenterCSV_ProductHolding";
                // });
                // if (subTab.length > 1) {
                    // workspaceAPI.focusTab({
                        // tabId: subTab.find(function (f) {
                            // return f;
                        // }).tabId
                    // });
                    // workspaceAPI.closeTab({
                        // tabId: tabId
                    // });
                // }
            // });
        // })
            // .catch(function (error) {
                // console.log(helper.parseObj(error));
            // });
// 
        // helper.getIsUnmaskData(component, helper);
        // helper.doInit(component, event, helper);
        // helper.getRedProductcodeList(component, event, helper);
        // helper.doInitProductSummarized(component, event, helper);
        // helper.doInitDepositProduct(component, event, helper);
        // helper.doInitCreditCardRDCProduct(component, event, helper);
        // helper.doInitLoanProduct(component, event, helper);
        // helper.doInitBancassuranceProduct(component, event, helper);
        // helper.doInitInvestmentProduct(component, event, helper);
        // helper.doInitErrorMessageControl(component, event, helper);
// 
        // helper.getWatermarkHTML(component);
// 
        // var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        // var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        // component.set("v.retrySetTimeOut", retrySetTimeOut);
        // component.set("v.numOfRetryTime", numOfRetryTime);
    // },
    // handlerAccount: function (component, event, helper) {
        // if (component.get('v.isOnce')) {
            // component.set('v.isOnce', false);
// 
            // window.addEventListener("offline", function (event) {
                // component.set('v.isOnline', false);
            // });
// 
            // window.addEventListener("online", function (event) {
                // event.preventDefault();
                // component.set('v.isOnline', true);
                // helper.checkIsSuccess(component);
            // });
// 
            // if (!component.get('v.recordId')) {
                // var recordId = component.get('v.recordId');
                // var pageReference = component.get("v.pageReference");
                // component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
            // }
            // component.set('v.tmbCustId', helper.getTMBCustID(component));
            // console.log('Record Id: ' +recordId);
            // helper.getAccessibleCusHold(component, event, helper);
// 
            // helper.getInvestmentModel(component, event, helper);
        // }
    // },
    // calloutService: function (component, event, helper) {
        // if (helper.getTMBCustID(component)) {
            // helper.resetData(component)
            // helper.callProduct(component, event, helper, 0)
            // helper.GetCreditCard(component, helper, 'N', '', null, 0)
            // helper.calloutProductTag(component, 'RetailProductHolding_Autoloan'); 
            // helper.GetBancassurance(component, helper, 0);
        // } else {
            // var noTMBCustIDMessage = $A.get('$Label.c.INT_No_Active_Product')
            // component.set('v.errorMessageControl.noTmbcust', true);
            // helper.displayErrorMessage(component, 'Warning!', noTMBCustIDMessage);
            // helper.displayToast('error', noTMBCustIDMessage)
            // helper.setIsLoadingProduct(component, false);
        // }
    // },
    // selectAPChange: function (component, event, helper) {
        // var investmentAPGraphList = component.get('v.investmentAPGraphList');
        // var investmentSelectedValueAP = component.find('investOpAP').get('v.value');
        // var investmentAPGroup = component.get('v.investmentAPGroup');
        // var index = investmentAPGroup.findIndex((m) => {
            // return (m.UnitHolderNo == investmentSelectedValueAP)
        // });
        // var productAP = investmentAPGroup[index].Data;
        // component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
        // helper.generateGraphAP(component, investmentAPGraphList, investmentSelectedValueAP);
    // },
    // selectPTChange: function (component, event, helper) {
        // var investmentPTGraphList = component.get('v.investmentPTGraphList');
        // var investmentSelectedValuePT = component.find('investOpPT').get('v.value');
        // helper.generateGraphPT(component, investmentPTGraphList, investmentSelectedValuePT);
    // },
    // refreshChartPT: function (component, event, helper) {
        // var investmentPTGraphList = component.get('v.investmentPTGraphList');
        // var investmentSelectedValuePT = component.get('v.AllPort');
        // helper.generateGraphPT(component, investmentPTGraphList, investmentSelectedValuePT);
// 
        // helper.generateGraphPTRec(component, component.get('v.investmentPTGraphRecommend'), 'donut');
    // },
    // refreshChartLTF: function (component, event, helper) {
        // var investmentLTFGraph = component.get('v.investmentLTFGraph');
        // helper.generateGraphLTF(component, investmentLTFGraph, 'donut');
    // },
    // onSuccess: function (component, event, helper) {
        // if (component.get('v.isSuccess')) {
            // helper.calculateSummarizedProduct(component, helper);
            // component.set('v.productSummarized.isLoading', false);
// 
            // var action = component.get('c.UpdateTotalAccountsAndSumOfDepesite');
            // action.setParams({
                // 'accountId': component.get('v.recordId'),
                // 'noOfProduct': helper.getNumberOfAccount(component.get('v.productSummarized.datas')),
                // 'sumOfTotalDepositeOutstanding': Math.round(helper.getTotalDepositeOutstanding(component.get('v.productSummarized.datas'))),
            // });
            // $A.enqueueAction(action);
// 
        // }
        // helper.choiceErrorHandle(component, helper);
    // },
    // onRefreshView: function (component, event, helper) {
        // $A.get('e.force:refreshView').fire();
    // },
    // onRetryCreditcard: function (component, event, helper) {
        // component.set('v.creditCardRDCProduct.datas', []);
        // component.set('v.error.messages.CardBal', '');
        // component.set('v.error.message', '');
        // component.set('v.isSuccess', false);
        // component.set('v.creditCardRDCProduct.isLoading', true);
        // helper.checkIsShowError(component);
        // helper.resetErrorControlByTypefunction(component, helper, 'CardBal');
        // helper.GetCreditCard(component, helper);
    // },
    // onRetryBancassurance: function (component, event, helper) {
        // component.set('v.bancassuranceProduct.datas', []);
        // component.set('v.error.messages.Bancassurance', '');
        // component.set('v.error.message', '');
        // component.set('v.isSuccess', false);
        // component.set('v.bancassuranceProduct.isLoading', true);
        // helper.checkIsShowError(component);
        // helper.resetErrorControlByTypefunction(component, helper, 'Bancassurance');
        // helper.GetBancassurance(component, helper, 0);
    // },
    // handleChildEvent: function (component, event, helper) {
        // var params = event.getParams();
        // var productEvent = component.find(params.productType);
        // if (productEvent) {
            // var error = productEvent.getError();
            // var errorMessageControl = component.get('v.errorMessageControl');
            // errorMessageControl['products'].push(params.productType);
            // errorMessageControl['productErrors'][params.productType] = error;
            // errorMessageControl['productName'][params.productType] = error.Type ? error.Type : '';
            // errorMessageControl['productTag'][params.productType] = error.Tag ? error.Tag : '';
            // errorMessageControl['timeout'][params.productType] = error.isTimeout ? true : false;
            // errorMessageControl['error'][params.productType] = error.isError ? true : false;
            // errorMessageControl['retry'][params.productType] = error.isTimeout ? true : false;
            // component.set('v.errorMessageControl', component.get('v.errorMessageControl'));
            // helper.choiceErrorHandle(component, helper);
            // helper.checkIsSuccess(component);
            // helper.calculateSummarizedProduct(component, helper);
        // }
    // },
    // onClickRetry: function (component, event, helper) {
        // var productRetry = component.get('v.errorMessageControl.products');
        // var isRetry = component.get('v.errorMessageControl.retry');
        // component.set('v.errorMessageControl.messages.Retry', '');
        // component.set('v.errorMessageControl', component.get('v.errorMessageControl'));
        // if (isRetry.OSC) {
            // helper.retryOSC01(component, event, helper, 0);
        // }
        // if (isRetry.CardBal) {
            // helper.retryCreditcard(component, event, helper, 0);
        // }
        // if (isRetry.Bancassurance) {
            // helper.retryBancassurance(component, helper, 0);
        // }
// 
        // [...new Set(productRetry)].forEach(prouductTag => {
            // if (isRetry[prouductTag]) helper.calloutProductTag(component, prouductTag);
        // })
    // },
    // onClickHref: function (component, event, helper) {
        // var theme = component.get('v.theme')
        // var selfcmp = component.find(event.srcElement.name);
        // if (selfcmp)
            // if (theme == 'Theme3' || theme == 'Theme4d') {
                // selfcmp.getElement().scrollIntoView({
                    // block: 'start',
                    // behavior: "smooth"
                // });
            // } else {
                // component.find('scrollerWrapper').scrollTo('custom', 0, selfcmp.getElement().offsetTop);
            // }
    // },
    // onSummaryClickHref: function (component, event, helper) {
        // var row = event.getParam('row');
        // var theme = component.get('v.theme');
        // if (row.Tag) {
            // if (theme == 'Theme3' || theme == 'Theme4d') {
                // component.find(row.Tag).getElement().scrollIntoView({
                    // block: 'start',
                    // behavior: "smooth"
                // });
            // } else {
                // component.find('scrollerWrapper').scrollTo('custom', 0, component.find(row.Tag).getElement().offsetTop);
// 
            // }
        // }
    // },
    // onViewClickHref: function (component, event, helper) {
        // var row = event.getParam('row');
        // if (!row.isError && row.link) {
            // var theme = component.get('v.theme');
            // if (theme == 'Theme3') {
                // var appEvent = $A.get("e.c:CallCenterCSV_ProductHoldingEvent");
                // appEvent.setParams({
                    // 'componentName': row.Tag,
                    // 'tabName': row.TabName,
                    // 'params': row.link.replace('/one/one.app#', '')
                // });
                // appEvent.fire();
            // } else if (theme == 'Theme4t' || theme == 'Theme4d') {
                // var navService = component.find('navService');
                // navService.navigate({
                    // "type": "standard__webPage",
                    // "attributes": {
                        // "url": row.link
                    // }
                // }, false);
            // } else {
                // var workspaceAPI = component.find("workspace");
                // workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    // workspaceAPI.openSubtab({
                        // parentTabId: tabId,
                        // url: row.link,
                        // focus: true
                    // });
                // })
                    // .catch(function (error) {
                        // console.log(error);
                    // });
            // }
        // }
    // },
})