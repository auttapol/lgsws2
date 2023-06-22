({
    onInit: function (component, event, helper) {
        helper.initializeCompanies(component);
        // helper.getVFBaseURL(component, event, helper);
        helper.getLimitOffsetRecord(component, event, helper);
    },
    handleHeaderAction: function (component, event, helper) {
        console.log(helper.parseObj(event.getParams()));

        // Retrieves the name of the selected filter
        var actionName = event.getParam('action').name;
        // Retrieves the current column definition
        // based on the selected filter
        var colDef = event.getParam('columnDefinition');

        console.log(actionName, colDef);
    },
    handleRowAction: function (component, event, helper) {
        var companySelected = event.getParams();
        component.set('v.companySelected', companySelected.selectedRows[0]);
        var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
        compEvent.setParams({
            "isSuccess": true,
            "type": 'clickSelected'
        });
        compEvent.fire();
    },
    handlerSearchingCompany: function (component, event, helper) {
        // component.get('v.vfHost') ? helper.getCompanyList(component, event, helper) : '';
        helper.getCompanyList(component, event, helper)
    },
    handlerSubmitSelected: function (component, event, helper) {
        helper.getCompanyDetail(component, event, helper);
    },
    handlerColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, event, helper, fieldName, sortDirection);
    },
    /* javaScript function for pagination */
    navigation: function (component, event, helper) {
        var whichBtn = event.getSource().get("v.name");
        if (whichBtn === 'first') {
            // component.set("v.currentPage", component.get("v.currentPage") + 1);
            component.set("v.currentPage", 1);
            helper.reDataTablePagination(component, event, helper);
        } else if (whichBtn === 'last') {
            // component.set("v.currentPage", component.get("v.currentPage") - 1);
            component.set("v.currentPage", component.get("v.totalPagesCount"));
            helper.reDataTablePagination(component, event, helper);
        } else {
            component.set("v.currentPage", whichBtn);
            helper.reDataTablePagination(component, event, helper);
        }
    },
})