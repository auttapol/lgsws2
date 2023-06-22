({
    onInit: function (component, event, helper) {
        helper.setHeader(component, helper);
        helper.getRec(component, helper);
        component.set('v.teamTotalRow', null);

        var productGroup = [
            {
                product: 'CASA',
                isSub: true
            },
            {
                product: 'Non-CASA',
                isSub: true
            },
            {
                product: 'Avg Balance',
                isSub: false
            },
            {
                product: 'CASA',
                isSub: true
            },
            {
                product: 'Non-CASA',
                isSub: true
            },
        ];
        component.set('v.productGroup', productGroup);
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
        p.exportCSV(helper.parseObj(jsonForCSV), 'Deposit_Report[' + dateFormat + ']');
    }
})