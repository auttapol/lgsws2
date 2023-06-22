({
    doInit: function (component, event, helper) {
        component.set('v.loading',true);
        helper.getData(component, event, helper);
    },

    openTaxCertificate : function(component, event, helper){
        var indexVar =  event.getSource().get("v.value");
        var taxList = component.get('v.taxList');

        var workspaceAPI = component.find("loanTax");

        workspaceAPI.isConsoleNavigation().then(function(response) {
            var isConsoleApp = response;

            if(isConsoleApp){
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                    
                    workspaceAPI.getTabInfo({tabId: primaryTab}).then(function (response){
                        console.log('taxList[indexVar].editConsentUrl: '+taxList[indexVar].editConsentUrl);
                        workspaceAPI.openSubtab({
                            parentTabId: primaryTab,
                            url: taxList[indexVar].editConsentUrl,
                            focus: true
                        });
                    }).catch(function (error) {
                        console.error(JSON.stringify(error));
                    });
                }).catch(function (error) {
                    console.error(JSON.stringify(error));
                });
            } else {

            }
        })
        .catch(function(error) {
            console.error(JSON.stringify(error));
        });
    },

    viewAllTax: function(component, event, helper){
        // var workspaceAPI = component.find("loanTax");
        // workspaceAPI.openTab({
        //     "url": '/lightning/n/AllLoanTax?c__accIdParameter=' + component.get("v.recordId"),
        //     focus: true
        // }).then(function (response) {
        //     workspaceAPI.getTabInfo({
        //         tabId: response
        //     }).then(function (tabInfo) {
        //         console.log("The recordId for this tab is: " + tabInfo.recordId);
        //     });
        // }).catch(function (error) {
        //     console.log(error);
        // });
        var navService = component.find("navService");
        var pageReference = {
    
            "type": "standard__component",
            "attributes": {
                "componentName": "c__LoanTaxCertificateCSV"    
            },    
            "state": {
                "c__accIdParameter": component.get('v.recordId')
                //"lastName": "user"    
            }
        };
        // component.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
           // cmp.set("v.url", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
           // cmp.set("v.url", defaultUrl);
        }));

        event.preventDefault();
        navService.navigate(pageReference);
    }
})