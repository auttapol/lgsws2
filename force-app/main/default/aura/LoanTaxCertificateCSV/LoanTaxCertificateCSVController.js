({
    doInit: function (component, event, helper) {
        component.set('v.loading',true);
        helper.getData(component, event, helper);
    },

    openTaxCertificate : function(component, event, helper){
        var indexVar =  event.target.id;
        var taxList = component.get('v.taxList');

        var workspaceAPI = component.find("workspace");

        workspaceAPI.isConsoleNavigation().then(function(response) {
            var isConsoleApp = response;

            if(isConsoleApp){
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    var primaryTab = tabId.replace(/(_[0-9].*)/g, '');
                    
                    workspaceAPI.getTabInfo({tabId: primaryTab}).then(function (response){
                        workspaceAPI.openSubtab({
                            parentTabId: primaryTab,
                            url: taxList[indexVar].editConsentUrl,
                            focus: true
                        });
                    }).catch(function (error) {
                        console.error(helper.parseObj(error));
                    });
                }).catch(function (error) {
                    console.error(helper.parseObj(error));
                });
            } else {

            }
        })
        .catch(function(error) {
            console.error(error);
        });
    },
})