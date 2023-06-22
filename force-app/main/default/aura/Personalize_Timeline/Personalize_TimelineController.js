({
    onInit: function (component, event, helper) {
        helper.setTabTitleLabel(component, event, helper);
        component.set('v.isLoading', true);
        var pageReference = component.get("v.pageReference");
        component.set('v.recordId', pageReference.state.c__recordId);
        const permissionLabelMsg = $A.get('$Label.c.Data_Condition_NotAuthorizedMsg');
        const warningErrorMsg = $A.get('$Label.c.OneApp_Error_Message');
        component.set('v.noPermissionMsg', permissionLabelMsg);
        component.set('v.warningMsg', warningErrorMsg);
        helper.getAccessPermission(component, event, helper);
    },

    retryGetDataFromOneApp: function (component, event, helper) {
        helper.retryGetDataFromOneApp(component, event, helper);
    },

    loadmore: function (component, event, helper) {
       helper.loadmoreData(component, event, helper);
    },

    handleChange: function (component, event, helper) {
        var selectedFilters = component.get('v.selectedFilters');
        var filterValue = component.get('v.filterValue');
        console.log('filterValue:',filterValue);
        var property;

        selectedFilters = JSON.parse(JSON.stringify(selectedFilters));

        var selectedMenuItemValue = event.getParam("value");
        console.log('selectedMenuItemValue:',selectedMenuItemValue);

        // // Find all menu items
        for (property in selectedFilters) 
        {
            var checked = false;
            if(selectedMenuItemValue.length > 0)
            {
                selectedMenuItemValue.forEach(value =>{
                
                    if(value == property)
                    {
                        checked = true;
                    }

                    if(checked)
                    {
                        selectedFilters[property] = checked;
                    }
                    else
                    {
                        selectedFilters[property] = checked;
                    }
                });
            }
            else
            {
                selectedFilters[property] = false;
            }
        }
        console.log('selectedFilters:',selectedFilters);
        component.set('v.selectedFilters', selectedFilters);

    }
})