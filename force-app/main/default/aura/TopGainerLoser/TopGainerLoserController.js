({
    onInit: function (component, event, helper) {
        // validate dulplicate page  
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
            workspaceAPI.getTabInfo({
                tabId: primaryTab
            }).then(function (response) {
                var subTab = response.subtabs.filter(function (f) {
                    return f.pageReference.attributes.componentName == "c__CallCenterCSV_ProductHolding";
                });
                if (subTab.length > 1) {
                    workspaceAPI.focusTab({
                        tabId: subTab.find(function (f) {
                            return f;
                        }).tabId
                    });
                    workspaceAPI.closeTab({
                        tabId: tabId
                    });
                }
            });
        })
            .catch(function (error) {
                console.log(helper.parseObj(error));
            });

        helper.getIsUnmaskData(component, helper);
        helper.doInit(component, event, helper);
        // helper.getRedProductcodeList(component, event, helper);
        // helper.doInitProductSummarized(component, event, helper);
        // helper.doInitDepositProduct(component, event, helper);
        // helper.doInitCreditCardRDCProduct(component, event, helper);
        // helper.doInitLoanProduct(component, event, helper);
        // helper.doInitBancassuranceProduct(component, event, helper);
        helper.doInitInvestmentProduct(component, event, helper);
        helper.doInitErrorMessageControl(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
    },
    handlerAccount: function (component, event, helper) {
        if (component.get('v.isOnce')) {
            component.set('v.isOnce', false);

            window.addEventListener("offline", function (event) {
                // helper.displayToast(component, 'warning', 'Offline');
                component.set('v.isOnline', false);
            });

            // Add event listener online to detect network recovery.
            window.addEventListener("online", function (event) {
                event.preventDefault();
                // helper.displayToast(component, 'success', 'Online');
                component.set('v.isOnline', true);
                helper.checkIsSuccess(component);
            });

            // handler to callout service
            if (!component.get('v.recordId')) {
                var recordId = component.get('v.recordId');
                var pageReference = component.get("v.pageReference");
                component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
            }
            component.set('v.tmbCustId', helper.getTMBCustID(component));

            helper.getAccessibleCusHoldHelper(component, event, helper);

            // handler to get Investment Model.
            helper.getInvestmentModel(component, event, helper);
        }
    },
    calloutService: function (component, event, helper) {
        // Callout service initial
        if (helper.getTMBCustID(component)) {
            helper.resetData(component);
            helper.callProduct(component, event, helper);
            helper.GetCreditCard(component, helper);
            helper.calloutProductTag(component, 'RetailProductHolding_Autoloan'); // Auto Loan detail
         //   helper.GetBancassurance(component, helper);
        } else {
            var noTMBCustIDMessage = $A.get('$Label.c.INT_No_Active_Product')
            component.set('v.errorMessageControl.noTmbcust', true);
            helper.displayErrorMessage(component, 'Warning!', noTMBCustIDMessage);
            helper.displayToast('error', noTMBCustIDMessage)
            helper.setIsLoadingProduct(component, false);
        }
    },
    // selectAPChange: function (component, event, helper) {
    //     // Plot new chart while select Investment UnitHolder.
    //     var investmentAPGraphList = component.get('v.investmentAPGraphList');
    //     var investmentSelectedValueAP = component.find('investOpAP').get('v.value');
    //     var investmentAPGroup = component.get('v.investmentAPGroup');
    //     var index = investmentAPGroup.findIndex((m) => {
    //         return (m.UnitHolderNo == investmentSelectedValueAP)
    //     });
    //     var productAP = investmentAPGroup[index].Data;
    //     component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
    //     helper.generateGraphAP(component, investmentAPGraphList, investmentSelectedValueAP);
    // },
    // selectPTChange: function (component, event, helper) {
    //     // Plot new chart while select Investment UnitHolder.
    //     var investmentPTGraphList = component.get('v.investmentPTGraphList');
    //     var investmentSelectedValuePT = component.find('investOpPT').get('v.value');
    //     helper.generateGraphPT(component, investmentPTGraphList, investmentSelectedValuePT);
    // },
    // refreshChartPT: function (component, event, helper) {
    //     // Re-Plot chart while click refresh button.
    //     var investmentPTGraphList = component.get('v.investmentPTGraphList');
    //     var investmentSelectedValuePT = component.get('v.AllPort');
    //     helper.generateGraphPT(component, investmentPTGraphList, investmentSelectedValuePT);

    //     // Plot new chart reommend.
    //     helper.generateGraphPTRec(component, component.get('v.investmentPTGraphRecommend'), 'donut');
    // },
    // refreshChartLTF: function (component, event, helper) {
    //     // Re-Plot chart while click refresh button.
    //     var investmentLTFGraph = component.get('v.investmentLTFGraph');
    //     helper.generateGraphLTF(component, investmentLTFGraph, 'donut');
    // },
    onSuccess: function (component, event, helper) {
        if (component.get('v.isSuccess')) {
            helper.calculateSummarizedProduct(component, helper);
            component.set('v.productSummarized.isLoading', false);

            var action = component.get('c.UpdateTotalAccountsAndSumOfDepesite');
            action.setParams({
                'accountId': component.get('v.recordId'),
                'noOfProduct': helper.getNumberOfAccount(component.get('v.productSummarized.datas')),
                'sumOfTotalDepositeOutstanding': Math.round(helper.getTotalDepositeOutstanding(component.get('v.productSummarized.datas'))),
            });

            $A.enqueueAction(action);

        }
        helper.choiceErrorHandle(component, helper);
    },
    onRefreshView: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    // onRetryCreditcard: function (component, event, helper) {
    //     component.set('v.creditCardRDCProduct.datas', []);
    //     component.set('v.error.messages.CardBal', '');
    //     // component.set('v.error.messages.OSC01', '');
    //     component.set('v.error.message', '');
    //     // component.set('v.error.hrefList', '');
    //     component.set('v.isSuccess', false);
    //     // component.set('v.error.state', false);
    //     component.set('v.creditCardRDCProduct.isLoading', true);
    //     helper.checkIsShowError(component);
    //     helper.resetErrorControlByTypefunction(component, helper, 'CardBal');
    //     helper.GetCreditCard(component, helper);
    // },
    // onRetryBancassurance: function (component, event, helper) {
    //     component.set('v.bancassuranceProduct.datas', []);
    //     component.set('v.error.messages.Bancassurance', '');
    //     component.set('v.error.message', '');
    //     component.set('v.isSuccess', false);
    //     component.set('v.bancassuranceProduct.isLoading', true);
    //     helper.checkIsShowError(component);
    //     helper.resetErrorControlByTypefunction(component, helper, 'Bancassurance');
    //     helper.GetBancassurance(component, helper);
    // },
    handleChildEvent: function (component, event, helper) {
        var params = event.getParams();
        var productEvent = component.find(params.productType);
        if (productEvent) {
            var error = productEvent.getError();
            var errorMessageControl = component.get('v.errorMessageControl');
            errorMessageControl['products'].push(params.productType);
            errorMessageControl['productErrors'][params.productType] = error;
            errorMessageControl['productName'][params.productType] = error.Type ? error.Type : '';
            errorMessageControl['productTag'][params.productType] = error.Tag ? error.Tag : '';
            errorMessageControl['timeout'][params.productType] = error.isTimeout ? true : false;
            errorMessageControl['error'][params.productType] = error.isError ? true : false;
            errorMessageControl['retry'][params.productType] = error.isTimeout ? true : false;
            component.set('v.errorMessageControl', component.get('v.errorMessageControl'));
            helper.choiceErrorHandle(component, helper);
            helper.checkIsSuccess(component);
            helper.calculateSummarizedProduct(component, helper);
        }
    },
    onClickRetry: function (component, event, helper) {
        var productRetry = component.get('v.errorMessageControl.products');
        var isRetry = component.get('v.errorMessageControl.retry');
        component.set('v.errorMessageControl.messages.Retry', '');
        component.set('v.errorMessageControl', component.get('v.errorMessageControl'));
        // console.log('retry Obj', helper.parseObj(isRetry));
        if (isRetry.OSC) {
            // console.log('retry OSC');
            helper.retryOSC01(component, event, helper);
        }
        if (isRetry.CardBal) {
            // console.log('retry cardBal');
            helper.retryCreditcard(component, event, helper);
        }
        if (isRetry.Bancassurance) {
            // console.log('retry Bancassurance');
            helper.retryBancassurance(component, event, helper);
        }

        // Dynamic call out service
        [...new Set(productRetry)].forEach(prouductTag => {
            if (isRetry[prouductTag]) helper.calloutProductTag(component, prouductTag);
        })
    },
    onClickHref: function (component, event, helper) {
        var theme = component.get('v.theme')
        var selfcmp = component.find(event.srcElement.name);
        if (selfcmp)
            if (theme == 'Theme3' || theme == 'Theme4d') {
                selfcmp.getElement().scrollIntoView({
                    block: 'start',
                    behavior: "smooth"
                });
            } else {
                component.find('scrollerWrapper').scrollTo('custom', 0, selfcmp.getElement().offsetTop);
            }
    },
    onSummaryClickHref: function (component, event, helper) {
        var row = event.getParam('row');
        var theme = component.get('v.theme');
        if (row.Tag) {
            if (theme == 'Theme3' || theme == 'Theme4d') {
                component.find(row.Tag).getElement().scrollIntoView({
                    block: 'start',
                    behavior: "smooth"
                });
            } else {
                component.find('scrollerWrapper').scrollTo('custom', 0, component.find(row.Tag).getElement().offsetTop);

            }
        }
    },
    onViewClickHref: function (component, event, helper) {
        var row = event.getParam('row');
        if (!row.isError && row.link) {
            var theme = component.get('v.theme');
            if (theme == 'Theme3') {
                var appEvent = $A.get("e.c:CallCenterCSV_ProductHoldingEvent");
                appEvent.setParams({
                    'componentName': row.Tag,
                    'tabName': row.TabName,
                    'params': row.link.replace('/one/one.app#', '')
                });
                appEvent.fire();
            } else if (theme == 'Theme4t' || theme == 'Theme4d') {
                var navService = component.find('navService');
                navService.navigate({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": row.link
                    }
                }, false);
            } else {
                // Theme4u
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: row.link,
                        focus: true
                    });
                })
                    .catch(function (error) {
                        console.log(error);
                    });
            }
        }
    },
  
})