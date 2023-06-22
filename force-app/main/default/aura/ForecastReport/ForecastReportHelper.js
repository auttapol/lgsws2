({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    generateSelectOption: function(component, helper){
        var reportOpts = [
            {id: '0', label: 'Forecast Volume', selected: true},
            {id: '1', label: 'Loan Report'},
            {id: '2', label: 'Deposit Report'},
            {id: '3', label: 'NI Projection by Initiative Report'},
        ];

        component.set('v.selectedReport' , 'Forecast Volume');
        component.set('v.ReportOpts' , reportOpts);

        var today = new Date();
        var yearOpts = [
            {id: today.getFullYear().toString(), label: today.getFullYear().toString(), selected: true},
            {id: (today.getFullYear() + 1).toString(), label: (today.getFullYear() + 1).toString()},
        ];

        component.set('v.selectedYear' , today.getFullYear().toString());
        component.set('v.YearOpts' , yearOpts);

        component.set('v.selectedProductGroup' , '');
        helper.generateProductGroupOption(component, helper);
    },

    generateProductGroupOption: function(component, helper){
        var selectedReportId = component.get('v.ReportOpts').find(opt => opt.label == component.get('v.selectedReport')).id;
        var PrdGroupOpts = [{id: '', label: '-- None --', selected: true}];
        var selectedPrdGroup = '';
        var disabled = false;

        if(selectedReportId != ''){
            selectedPrdGroup = 'all';
            PrdGroupOpts = [
                {id: 'all', label: 'All', selected: true},
                {id: 'credit', label: 'Credit'},
                {id: 'deposit', label: 'Deposit'},
            ];

            if(selectedReportId == '1'){
                selectedPrdGroup = 'credit';
                PrdGroupOpts = [{ id: 'credit', label: 'Credit', selected: true}];
                disabled = true;
            }else if(selectedReportId == '2'){
                selectedPrdGroup = 'deposit';
                PrdGroupOpts = [{ id: 'deposit', label: 'Deposit', selected: true}];
                disabled = true;
            }else if(selectedReportId == '3'){
                selectedPrdGroup = 'all';
                PrdGroupOpts = [{id: 'all', label: 'All', selected: true}];
                disabled = true;
            }
        }

        component.set('v.ProductGroupOpts' , PrdGroupOpts);
        component.set('v.selectedProductGroup' , selectedPrdGroup);
        component.set('v.disabledProductGroup' , disabled);
    },

    generateTeamOption: function(component, helper){
        component.set('v.isLoading', false);
        component.set('v.searchTeam', '');
        component.set('v.selectedTeamList', []);

        var mapPortTeam = component.get('v.mapPortTeam');
        var selectedPort = component.get('v.selectedCustomerPort');

        var teamOpts = [];
        

        Object.keys(mapPortTeam[selectedPort]).forEach(function eachKey(key){
            if(key){
                if(Object.keys(mapPortTeam[selectedPort]).length === 1){
                    teamOpts.push({'label': mapPortTeam[selectedPort][key], 'value': key});
                    component.set('v.selectedTeamList', key);
                    component.set('v.searchTeam', mapPortTeam[selectedPort][key]);
                }else{
                    teamOpts.push({'label': mapPortTeam[selectedPort][key], 'value': key});
                }
            }
        });

        teamOpts.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
        if (selectedPort == 'My Customer' || selectedPort == 'My Team') {
            component.find('teamInput').set('v.disabled',true);
            
        }else{
            component.find('teamInput').set('v.disabled',false);
        }
        component.set('v.teamOpts', teamOpts);
    },

    updateFilterlabel: function(component){
        var port = component.get('v.selectedCustomerPort');
        var team = component.get('v.searchTeam');
        var prdgroup = component.get('v.selectedProductGroup');
        var year = component.get('v.selectedYear');
        var filterlabel = 'Filter (' + port +  '; ' + team + '; ' + prdgroup + '; ' + year + ')';

        // component.set('v.filterlabel', filterlabel);
    },

    displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
})