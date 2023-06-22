({
    onInit : function(component, event, helper) {
        helper.generateSelectOption(component, helper);
        component.set('v.hasGraphData',false);
        component.set('v.openGraph',false);
        component.set('v.CustomerPortOpts', [{id: 'none', label: '-- None --', selected: true}]);

        var action = component.get('c.getCustomerPort');
        var action2 = component.get('c.getUserForecastReportRole');

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                var result = JSON.parse(response.getReturnValue());
                var opts = [];
                
                if(Object.keys(result).length != 0){
                    Object.keys(result).forEach(function eachKey(key) { 
                        if(Object.keys(result).indexOf(key) === 0){
                            opts.push({id: key, label: key, selected: true});
                            component.set('v.selectedCustomerPort', key);
                        }else{
                            opts.push({id: key, label: key});
                        }
                    });
    
                    component.set('v.mapPortTeam', result);
                    component.set('v.CustomerPortOpts', opts);

                    helper.generateTeamOption(component, helper);
                    helper.updateFilterlabel(component);
                }else{
                    component.set('v.isLoading', false);
                }
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
                component.set("v.isLoading", false);
            } else {
                console.error(response);
            }
        });

        action2.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                var result = response.getReturnValue();
                component.set('v.userForecastRole', result);
            }else if (response.getState() === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
                component.set("v.isLoading", false);
            } else {
                console.error(response);
            }
        });

        $A.enqueueAction(action);
        $A.enqueueAction(action2);
    },
    Graph: function (component, event, helper) {
        component.set('v.openGraph',true);
    }
    ,
    generateReport: function (component, event, helper) {
        component.set('v.openGraph',false);
        component.set('v.hasGraphData',false);
        component.set('v.isLoading', true);
        component.set("v.exportCSVData", []);
        var selectedReport = component.get('v.selectedReport');
        var selectedCustomerPort = component.get('v.selectedCustomerPort');
        var searchTeam = helper.parseObj(component.get('v.selectedTeamList'));
        var selectedProductGroup = component.get('v.selectedProductGroup');
        var selectedYear = component.get('v.selectedYear');
        component.find('teamInput').showHelpMessageIfInvalid();

        if(component.get('v.searchTeam') == '') {
            component.set('v.isLoading', false);
            helper.displayToast('error', 'Please select team.');
        }else{
            if(component.get('v.selectedReport') == 'Forecast Volume' || component.get('v.selectedReport') == 'NI Projection by Initiative Report'){
                component.set('v.isLoading', true)
                component.set('v.selectedReportId' , '');
                var report1Param ={
                    selectedYear : selectedYear,
                    selectedCustomerPort : selectedCustomerPort,
                    searchTeam : searchTeam ,
                    selectedProductGroup : (selectedProductGroup == "Credit" || selectedProductGroup =="Deposit") ? selectedProductGroup : '' ,
                };
                component.set('v.report1Param',report1Param);
                component.set('v.selectedReportId' , component.get('v.ReportOpts').find(opt => opt.label == selectedReport).id);
            } else if (component.get('v.selectedReport') == 'Loan Report' || component.get('v.selectedReport') == 'Deposit Report') {    
                component.set('v.isLoading', true)
                component.set('v.selectedReportId' , '');
                var reportParam ={
                    selectedYear : selectedYear,
                    CustomerPort : selectedCustomerPort,
                    searchTeam : searchTeam ,
                };
                component.set('v.reportParam',reportParam);
                component.set('v.selectedReportId' , component.get('v.ReportOpts').find(opt => opt.label == selectedReport).id);
            }
                
            
        }
    },

    onChangeSelectReport: function(component, event, helper) {
        helper.generateProductGroupOption(component, helper);
        helper.updateFilterlabel(component);
    },

    showSelectTeam: function(component, event, helper){
        component.set('v.selectedTeamListtmp', component.get('v.selectedTeamList'));
        var port = component.get('v.selectedCustomerPort');
        if (port == 'My Customer' || port == 'My Team') {
            component.find('teamInput').set('v.disabled',true);
        } else {
            component.find('teamInput').set('v.disabled',false);
            component.set('v.showTeamSelect', true);
        }
    },

    closeSelectTeamModel: function(component, event, helper){
        component.set('v.selectedTeamList', component.get('v.selectedTeamListtmp'));
        component.set('v.showTeamSelect', false);
    },

    selectTeamOption: function(component, event, helper){
        var selectedTeam = component.get('v.selectedTeamList');
        var teamOpts = component.get('v.teamOpts');
        
        var selectedTeamstr = selectedTeam.reduce(function(result, item){
            result = result == '' ? result.concat(teamOpts.find(opt => opt.value == item).label) : result.concat(', ', teamOpts.find(opt => opt.value == item).label);
            return result;
        }, '');

        component.set('v.searchTeam', selectedTeamstr);
        component.set('v.showTeamSelect', false);
        helper.updateFilterlabel(component);
        component.find('teamInput').showHelpMessageIfInvalid();
    },

    onChangePort: function(component, event, helper){
        helper.generateTeamOption(component, helper);
        var port = component.get('v.selectedCustomerPort');
        if (port == 'My Customer' || port == 'My Team') {
            component.find('teamInput').set('v.disabled',true);
        }else{
            component.find('teamInput').set('v.disabled',false);
        }
        helper.updateFilterlabel(component);
    },

    updateFilterlabel: function(component, event, helper){
        helper.updateFilterlabel(component);
    },

    exportCSV: function (component, event, helper) {
        var params = event.getParam('arguments');
        var param1 = helper.parseObj(params.param1);
        var reportName = params.reportName + '.csv';
        var hasData = (param1.length == 0 || param1 == null) ? false : true;

        component.set('v.exportCSVData', param1);
        component.set('v.exportCSVisHasData', hasData);
        component.set('v.reportName', reportName);
    }
})