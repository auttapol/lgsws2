({
    onInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find("navService");

        var pageReference = component.get('v.pageReference');
        var _action = component.get('v.action') ? component.get('v.action') : pageReference.state.c__action;
        var _recordId = component.get('v.recordId') ? component.get('v.recordId') : pageReference.state.c__recordId;
        var _url = component.get('v.url') ? component.get('v.url') : pageReference.state.c__url;
        var _replace = component.get('v.replace') ? component.get('v.replace') : pageReference.state.c__replace;
        var _theme = component.get('v.isMobile') == true ? 'Theme4t' : pageReference.state.c__theme;
        var isConsoleApp;
        
        workspaceAPI.isConsoleNavigation().then(function(response) {
            isConsoleApp = response;
            
            if (component.get('v.isRunInit')) {
                if (_theme == 'Theme4t') {
                    // For Saleforce one application
                    switch (_action) {
                        case 'openTabUrl':
                            navService.navigate({
                                "type": "standard__webPage",
                                "attributes": {
                                    "url": _url
                                }
                            }, _replace);
                            break;
                        default:
                            break;
                    }
                }else if(isConsoleApp){
                    helper.doWorkspaceAPIforVF(component, event, helper);    
                } else {
                    // For Saleforce Lightning Experience Application
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": _url
                    });
                    urlEvent.fire();   
                }
            }
        })
        .catch(function(error) {
            console.error(error);
        });
    }
})