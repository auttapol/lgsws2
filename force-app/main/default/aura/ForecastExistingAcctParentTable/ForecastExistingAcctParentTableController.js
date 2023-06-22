({
    onInit: function (component, event, helper) {
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth();
        component.set('v.PortOpts', [{id: 'none', label: '-- None --', selected: true}]);
        component.set('v.asOfDate','('+(today.getDate() -1) +'-'+helper.getMonthName(today.getMonth())+'-'+today.getFullYear()+')');
        var action = component.get('c.getUserPortOptionPermission');

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                var result = JSON.parse(response.getReturnValue());
                var opts = [];
                
                if(Object.keys(result).length != 0){
                    Object.keys(result).forEach(function eachKey(key) { 
                        if(Object.keys(result).indexOf(key) === 0){
                            opts.push({id: key, label: key, selected: true});
                            component.set('v.selectedPort', key);
                        }else{
                            opts.push({id: key, label: key});
                        }
                    });
    
                    component.set('v.mapPortTeam', result);
                    component.set('v.PortOpts', opts);
    
                    helper.generateTeamSelectOption(component, helper);
                    helper.generateSelectOpts(component , helper);
                    helper.genMonthHeader(component, event, helper);
                    helper.getRecord(component, helper, year, month, '');
                }else{
                    component.set('v.isLoading', false);
                }
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayToast('error', errors[0].message);
                    }
                }
                component.set('v.isLoading', false);
            } else {
                console.error(response);
                component.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
    },

    clearFilter: function (component, event, helper) {
        component.find('customLookupGroup').set('v.SearchKeyWord','');
        component.find('customLookupCustomer').set('v.SearchKeyWord','');
        component.set('v.searchAcct','');
        component.set('v.searchGroup','');
        component.set('v.searchTeam','');
        component.set('v.isAdjustedItem', false);
        component.set('v.isMatured', false);

        var mapPortTeam = component.get('v.mapPortTeam');
        var opts = [];
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth();

        Object.keys(mapPortTeam).forEach(function eachKey(key) { 
            if(Object.keys(mapPortTeam).indexOf(key) === 0){
                opts.push({id: key, label: key, selected: true});
                component.set('v.selectedPort', key);
            }else{
                opts.push({id: key, label: key});
            }
        });

        component.set('v.PortOpts', opts);
        
        helper.generateSelectOpts(component,helper);
        helper.generateTeamSelectOption(component, helper);
        helper.getRecord(component, helper, year, month, '');
    },

    onProductDomainChange: function(component, event, helper){
        if(component.get('v.selectedPrdDomain') == 'Deposit'){
            var prdGroupOpts = {
                selected: '',
                opts: [
                    { id: '', label: 'All', selected: true},
                    { id: 'CA', label: 'CA' },
                    { id: 'FCD', label: 'FCD'},
                    { id: 'FCD CASA', label: 'FCD CASA'},
                    { id: 'LT BE', label: 'LT BE'},
                    { id: 'OneBank', label: 'OneBank'},
                    { id: 'SA', label: 'SA'},
                    { id: 'SHigh', label: 'SHigh'},
                    { id: 'ST BE', label: 'ST BE'},
                    { id: 'TD', label: 'TD'},
                ]
            };
        }
        else if(component.get('v.selectedPrdDomain') == 'Credit'){
            var prdGroupOpts = {
                selected: '',
                opts: [
                    { id: '', label: 'All', selected: true},
                    { id: 'Credit Card', label: 'Credit Card'},
                    { id: 'Fleet Card', label: 'Fleet Card'},
                    { id: 'LG', label: 'LG'},
                    { id: 'LT Loan', label: 'LT Loan'},
                    { id: 'Military', label: 'Military'},
                    { id: 'OD', label: 'OD'},
                    { id: 'OD for Buyer', label: 'OD for Buyer'},
                    { id: 'PN', label: 'PN'},
                    { id: 'TF LIABILITY (Inter)', label: 'TF LIABILITY (Inter)'},
                    { id: 'Trade Finance (Domestic)', label: 'Trade Finance (Domestic)'},
                    { id: 'Trade Finance (Inter)', label: 'Trade Finance (Inter)'},
                ]
            };
        }else{
            var prdGroupOpts = {
                selected: '',
                opts: [
                    { id: '', label: '-- None --', selected: true},
                ]
            };
        }
        component.set('v.PrdGroupOpts', prdGroupOpts.opts);
        component.set('v.selectedPrdGroup', prdGroupOpts.selected);
    },

    onYearChange: function(component, event, helper){
        var today = new Date();
        var year = parseInt(component.get('v.selectYear'));
        var optsArray = [];
        if(today.getFullYear() < year){
            for(var i = 1 ;i <= today.getMonth(); i++ ){
                var monthString = i <= 10 ? '0'+i.toString() : i.toString();
                var nextYearMonth = {id: monthString , label : helper.getMonthName(i-1 ,true)};
                optsArray.push(nextYearMonth);
            }
        }else{
            for(var i = 1 ;i <= 12; i++ ){
                var monthString = i <= 10 ? '0'+i.toString() : i.toString();
                var nextYearMonth = {id: monthString , label : helper.getMonthName(i-1 ,true)};
                optsArray.push(nextYearMonth);
            }
        }
        
        var selectMonth = {
            selected: '01',
            opts : optsArray
        };
        selectMonth.opts[0].selected = true;
        component.set('v.selectMonthOpts', selectMonth.opts);
        component.set('v.selectMonth', selectMonth.selected);
    },

    doSearch: function (component, event, helper) {
        component.set('v.isLoading', true);
        component.find('teamInput').showHelpMessageIfInvalid();
        if(component.get('v.searchTeam') != ''){
            component.set('v.allData');
            helper.genMonthHeader(component, event, helper);
            helper.getRecord(component, helper);
        }else{
            helper.displayToast('error', 'Please select team.');
            component.set('v.isLoading', false);
        }
    },


    checkIsShow: function (component, event, helper) {
        var allDataLenght = component.get('v.allDataLenght');
        allDataLenght -- ;
        component.set('v.isHasShowedRec',allDataLenght > 0);
        component.set('v.allDataLenght',allDataLenght);
        if(allDataLenght <=0 ) component.set('v.allData',[]);
    }
    ,
    showSelectTeam: function(component, event, helper){
        component.set('v.selectedTeamListtmp', component.get('v.selectedTeamList'));
        var port = component.get('v.selectedPort');
        if (port == 'My Customer' || port == 'My Team') {
            component.set('v.disable', true);
        } else {
            component.set('v.disable', false);
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

        component.find('teamInput').showHelpMessageIfInvalid();
    },

    onChangePort: function(component, event, helper){
        helper.generateTeamSelectOption(component, helper);
        if (component.get('v.selectedPort') == 'My Customer' || component.get('v.selectedPort') == 'My Team') {
            component.find('teamInput').set('v.disabled',true);
            
        }else{
            component.find('teamInput').set('v.disabled',false);
        }
    }
});