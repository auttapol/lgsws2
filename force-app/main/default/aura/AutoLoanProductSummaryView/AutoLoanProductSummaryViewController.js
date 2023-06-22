({
    // handlerAccount: function (component, event, helper) {
    onInit: function (component, event, helper) {
        helper.getWatermarkHTML(component);
        helper.setHeaderColumns(component);
        if(component.get('v.allowCallChild') == true){
            // helper.getALDXWFMdt(component, event, helper);
            helper.getCoreHPCompany(component, event, helper);
            //get constants retry
            var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
            var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
            component.set("v.retrySetTimeOut", retrySetTimeOut);
            component.set("v.numOfRetryTime", numOfRetryTime);
        }
        else{
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('AutoLoanProductSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }
    },

    handleCompanyChange: function (component, event, helper){
        helper.callProduct(component, event, helper, 0);
    },

    getProducts: function (component, event, helper) {
        return component.get('v.product.datas');
    },

    onClickAction: function (component, event, helper) {
        var row = event.getParam('row');
        var navService = component.find('navService');
        navService.navigate({
            "type": "standard__webPage",
            "attributes": {
                "url": row.link
            }
            // "attributes": {
                // "url": '/one/one.app#' + btoa(JSON.stringify({
                    // "componentDef": "c:CommercialAutoLoan_HPFeetHPDetail",
                    // "attributes": {
                        // "recordId": component.get('v.recordId'),
                        // "tmbCustId": component.get('v.tmbCustId'),
                        // "accessibleCusHold": component.get('v.accessibleCusHold'),
                        // "company": component.get('v.company'),
                        // "contractNo": row.HP_Account_No,
                        // "markedcontractNo": row.MarkedHP_Account_No,
                        // "accountType": "Retail",
                    // }
                // }))
            // }
        }, false);
    },

})