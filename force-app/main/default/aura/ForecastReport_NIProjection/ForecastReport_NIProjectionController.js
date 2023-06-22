({
    getReport : function(component, event, helper) {
        component.set('v.groupedRegArray',null);
        helper.getRec(component, helper, event);
        helper.setColumn(component, helper, event);
    },
    openModel : function(component, event, helper) {
        component.set('v.isModalOpen',true);
    },
    exportCSV: function (component, event, helper) {
        var params = event.getParam('arguments');
        var param1 = helper.parseObj(params.param1);
        var jsonForCSV = helper.parseObj(component.get("v.jsonForCSV"));
        jsonForCSV = jsonForCSV.concat(param1);
        component.set("v.jsonForCSV", jsonForCSV)
  
        var today = new Date()
        var dateFormat = (today.toLocaleDateString('en-GB').split('/')).join('-')
        var p = component.get("v.parent");
        p.exportCSV(helper.parseObj(jsonForCSV), 'NI_Projection_By_Initiative_Report[' + dateFormat + ']');
    }
})