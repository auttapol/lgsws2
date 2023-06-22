({
    onInit: function (component, event, helper) {
        component.set('v.bancassuranceProduct.isLoading', true);
        component.set('v.autoLoanProduct.isLoading', true);
        component.set('v.loanProduct.isLoading', true);
        component.set('v.depositProduct.isLoading', true);

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

        helper.doInit(component, event, helper);
        helper.doInitProductSummarized(component, event, helper);
        helper.doInitErrorMessageControl(component, event, helper);
    },

    handlerAccount: function(component, event, helper){
        component.set('v.accountChanged', true);
        helper.genDefaultEachSeqGrp(component, event, helper);
    },

    handlerRecordId: function(component, event, helper){
        helper.getIsUnmaskData(component, helper);
        const accessCustHOld = helper.getAccessibleCusHold(component, event, helper);
        accessCustHOld.then((data) => {
            const fieldVerify = helper.getFieldVisibility(component, event, helper);
            fieldVerify.then((data) => {
                component.set('v.readyToCallProduct', true);
            })
        });
    },
    
    handleIsAccess: function(component, event, helper){
        const isCallChild = component.get('v.allowCallChild');
        const defaultTable = component.get('v.seq1default')
                            .concat(component.get('v.seq2default'))
                            .concat(component.get('v.seq3default'))
                            .concat(component.get('v.seq5default'))
                            .concat(component.get('v.seq6default'))
                            .concat(component.get('v.seq7default'))
                            .concat(component.get('v.seq8default'))
                            .concat(component.get('v.seqAutodefault'))
                            .concat(component.get('v.seqOtherdefault'));
        helper.genHiddenTable(component, helper, defaultTable);
        if(isCallChild == true){
            component.set('v.productSummarized.datas', defaultTable);
            helper.callProduct(component, event, helper, 0);
        }
        else{
            helper.displayErrorMessage(component, 'Warning!', $A.get('$Label.c.Data_Condition_NotAuthorizedMsg'));
            component.set('v.errorMessageControl.noAuthorized', true);
            component.set('v.productSummarized.isLoading', false);
        }
    },

    handleReturnData: function(component, event, helper){
        let errorSet = [];
        const getResult = new Promise((resolve, reject) => {
            var params = event.getParam('arguments');
            resolve(params.returnData);
        });
        getResult.then((data) => {
            let errorSectionList = '';
            errorSectionList += component.get('v.errorSection');
            for(const key of data.keys()){
                if(key == 'DepositProductSummaryView'){
                    component.set('v.depositProduct.isLoading', false);
                    component.set('v.depositProductReturn', true);
                    if(data.get(key) == 'error' || data.get(key) == 'timeout'){
                        errorSet.push('Deposit_Product_Details');
                        errorSectionList += 'Deposit_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                        const defaultLoan = component.get('v.seq1default')
                                            .concat(component.get('v.seq2default'))
                                            .concat(component.get('v.seqOtherdefault'));
                        component.set('v.depositProduct.datas', defaultLoan);
                    }
                    else if(data.get(key) == 'default'){
                         const defaultLoan = component.get('v.seq1default')
                                            .concat(component.get('v.seq2default'))
                                            .concat(component.get('v.seqOtherdefault'));
                        component.set('v.depositProduct.datas', defaultLoan);
                    }
                    else{
                        component.set('v.depositProduct.datas', data.get('DepositProductSummaryView'));
                    }
                } 
                if(key == 'CreditProductSummaryView'){
                    component.set('v.creditCardRDCProduct.isLoading', false);
                    component.set('v.creditCardRDCProductReturn', true);
                    if(data.get(key) == 'error' || data.get(key) == 'timeout'){
                        errorSet.push('Credit_Card_RDC_Product_Details');
                        errorSectionList += 'Credit_Card_RDC_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                        const defaultAuto = component.get('v.seq3default').concat(component.get('v.seqOtherdefault'));
                        component.set('v.creditCardRDCProduct.datas', defaultAuto);
                    }
                    else if(data.get(key) == 'CIF0003' || data.get(key) == []){
                        const defaultAuto = component.get('v.seq3default').concat(component.get('v.seqOtherdefault'));
                        component.set('v.creditCardRDCProduct.datas', defaultAuto);
                    }
                    else{
                        component.set('v.creditCardRDCProduct.datas', data.get('CreditProductSummaryView'));
                    }
                }
                if(key == 'LoanProductSummaryView'){
                    component.set('v.loanProduct.isLoading', false);
                    component.set('v.loanProductReturn', true);
                    if(data.get(key) == 'error' || data.get(key) == 'timeout'){
                        errorSet.push('Loan_Product_Details');
                        errorSectionList += 'Loan_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                        const defaultLoan = component.get('v.seq7default')
                                            .concat(component.get('v.seq8default'))
                                            .concat(component.get('v.seqOtherdefault'));
                        component.set('v.loanProduct.datas', defaultLoan);
                    }
                    else if(data.get(key) == []){
                        const defaultLoan = component.get('v.seq7default')
                                            .concat(component.get('v.seq8default'))
                                            .concat(component.get('v.seqOtherdefault'));
                       component.set('v.depositProduct.datas', defaultLoan);
                   }
                    else{
                        component.set('v.loanProduct.datas', data.get('LoanProductSummaryView'));
                    }
                }
                if(key == 'AutoLoanProductSummaryView'){
                    component.set('v.autoLoanReturn', true);
                    component.set('v.autoLoanProduct.isLoading', false);
                    if(data.get(key) == 'error' || data.get(key) == 'timeout'){
                        errorSet.push('AutoLoan_Product_Details');
                        errorSectionList += 'AutoLoan_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                        const defaultAuto = component.get('v.seqAutodefault').concat(component.get('v.seqOtherdefault'));
                        component.set('v.autoLoanProduct.datas', defaultAuto);
                    }
                    else if(data.get(key) == "default"){
                        const defaultAuto = component.get('v.seqAutodefault').concat(component.get('v.seqOtherdefault'));
                       component.set('v.depositProduct.datas', defaultAuto);
                   }
                    else{
                        component.set('v.autoLoanProduct.datas', data.get('AutoLoanProductSummaryView'));
                    }
                }
                if(key == 'BancassuranceSummaryView'){
                    component.set('v.bancassuranceProduct.isLoading', false);
                    component.set('v.bancassuranceReturn', true);
                    if(data.get(key).StatusDesc != null || data.get(key) == 'error'){
                        errorSet.push('Bancassurance_Product_Details');
                        errorSectionList += 'Bancassurance_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        component.set('v.errorMessageControl.messages.Info', data.get(key).StatusDesc);
                        component.set('v.errorMessageControl.isShowMessage.Info', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                        const defaultBA = component.get('v.seq6default').concat(component.get('v.seqOtherdefault'));
                        component.set('v.bancassuranceProduct.datas', defaultBA);
                    }
                    else if(data.get(key) == []){
                        const defaultBA = component.get('v.seq6default').concat(component.get('v.seqOtherdefault'));
                       component.set('v.depositProduct.datas', defaultBA);
                   }
                    else{
                        component.set('v.bancassuranceProduct.datas', data.get('BancassuranceSummaryView'));
                    }
                }
                if(key == 'InvestmentProductSummaryView'){
                    component.set('v.investmentProduct.isLoading', false);
                    component.set('v.investmentProductReturn', true);
                    if(data.get(key) == 'default'){
                        const defaultInvest = component.get('v.seq5default').concat(component.get('v.seqOtherdefault'));
                        component.set('v.investmentProduct.datas', defaultInvest);
                    }
                    else{
                        component.set('v.investmentProduct.datas', data.get('InvestmentProductSummaryView'));
                    }
                }
                if(key == 'InvestmentProductSummaryViewStatus'){
                    if(data.get(key) == 'error' || data.get(key) == 'timeout'){
                        errorSet.push('Investment_Product_Details');
                        errorSectionList += 'Investment_Product_Details,';
                        component.set('v.errorMessageControl.isShowMessage.Snow', true);
                        helper.displayErrorMessage(component, 'Warning!', '');
                    }
                }
                component.set('v.errorSection', errorSectionList);
                if(component.get('v.allowCallChild') == true){
                    helper.checkIsReadyToSum(component, event, helper);
                }
            }
        });
    },

    handleErrorSectionAfterClick: function(component, event, helper){
        var theme = component.get('v.theme');
        var selfcmp;
        if(event.srcElement.outerText.includes($A.get('$Label.c.Bancassurance_Product_Details'))){
            selfcmp = component.find('Bancassurance_Product_Details');
        }
        else if(event.srcElement.outerText.includes($A.get('$Label.c.Deposit_Product_Details'))){
            selfcmp = component.find('Deposit_Product_Details');
        }
        else if(event.srcElement.outerText.includes($A.get('$Label.c.Loan_Product_Details'))){
            selfcmp = component.find('Loan_Product_Details');
        }
        else if(event.srcElement.outerText.includes($A.get('$Label.c.Auto_loan_HP'))){
            selfcmp = component.find('AutoLoan_Product_Details');
        }
        else if(event.srcElement.outerText.includes($A.get('$Label.c.Investment_Product_Details'))){
            selfcmp = component.find('Investment_Product_Details');
        }
        else if(event.srcElement.outerText.includes($A.get('$Label.c.Credit_Card_RDC_Product_Details'))){
            selfcmp = component.find('Credit_Card_RDC_Product_Details');
        }
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

    onClickHref: function (component, event, helper) {
        var theme = component.get('v.theme');
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

    onSummaryClickHref: function (component, event, helper) {
        var row = event.getParam('row');
        var theme = component.get('v.theme');
        if(row.Tag){
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
})