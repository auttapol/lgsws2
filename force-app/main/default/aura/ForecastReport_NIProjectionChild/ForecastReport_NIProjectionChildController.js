({
    getReport : function(component, event, helper) {
        if (component.get('v.groupByRM') != null) {
            var groupByRM = helper.parseObj(component.get('v.groupByRM'));
        }else if(component.get('v.groupByTeam') != null){
            var groupByRM = helper.parseObj(component.get('v.groupByTeam'));
        }else{
            var groupByRM = helper.parseObj(component.get('v.groupByRegion'));
        }
        // export CSV
        // console.log(groupByRM);
        var groupByRegion = component.get('v.groupByRegion')
        var team = (component.get('v.groupByRM') != null) ? groupByRM.cube1[0].Customer__r.Owner.Zone__c : (component.get('v.groupByTeam') != null) ? groupByRM.cube1[0].Customer__r.Owner.Zone__c : groupByRegion.region
        var rm = (component.get('v.groupByRM') != null) ? groupByRM.cube1[0].Customer__r.Owner.Name : (component.get('v.groupByTeam') != null) ? 'Team Total' : 'Region Total'
        component.set('v.team', team)
        component.set('v.rm', rm)
        helper.setFee(component , helper, helper.mapTemplate(groupByRM.allFee), groupByRM.cube1, groupByRM.cube1LY, groupByRM.target);
        component.set('v.newDeal' , groupByRM.newDeal);
    },
    exportCSV: function (component, event, helper) {
        var params = event.getParam('arguments');
        var param1 = helper.parseObj(params.param1);
        var jsonForCSV = helper.parseObj(component.get("v.jsonCSV"));
        jsonForCSV = jsonForCSV.concat(param1);
        component.set("v.jsonCSV", jsonForCSV)
        var p = component.get("v.parent");
        p.exportCSV(helper.parseObj(jsonForCSV));
    }
})