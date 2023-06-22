({
    onInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.PortOpts', [{id: 'none', label: '-- None --', selected: true}]);
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
                    helper.getRecord(component, helper);
                }else{
                    component.set('v.PortOpts', [{id: 'none', label: '-- None --', selected: true}]);
                    component.set('v.isLoading', false);
                }
            }else if (response.getState() === 'ERROR') {
                var errors = action.getError();
                console.log(errors);
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

        var getFeeRateLinkAction = component.get("c.getFeeRateLink");

        getFeeRateLinkAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.feeRateLink", response.getReturnValue());
            } else {
                console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getFeeRateLinkAction);
    },

    onYearChange: function(component, event, helper){
        var today = new Date();
        var year = parseInt(component.get('v.selectYear'));
        var optsArray = [
            { id: '0', label: 'All' }
        ];
        if(today.getFullYear() < year){
            for(var i = 1 ;i <= today.getMonth(); i++ ){
                var monthString = i <= 10 ? '0'+i.toString() : i.toString();
                var nextYearMonth = {id: monthString , label : helper.getMonthName(i-1 ,true)};
                optsArray.push(nextYearMonth);
            }
        }else if(today.getFullYear() == year){
            for(var i = 1; i <= 12; i++ ){
                var monthString = i <= 10 ? '0'+i.toString() : i.toString();
                var nextYearMonth = {id: monthString , label : helper.getMonthName(i-1 ,true)};
                optsArray.push(nextYearMonth);
            }
        } else {
            for(var i = (today.getMonth() == 0) ? 1 : today.getMonth() + 2; i <= 12; i++ ){
                var monthString = i <= 10 ? '0'+i.toString() : i.toString();
                var nextYearMonth = {id: monthString , label : helper.getMonthName(i-1 ,true)};
                optsArray.push(nextYearMonth);
            }
        }
        
        var selectMonth = {
            selected: '0',
            opts : optsArray
        };
        selectMonth.opts[0].selected = true;
        component.set('v.selectMonthOpts', selectMonth.opts);
        component.set('v.selectMonth', selectMonth.selected);
    },

    clearFilter: function (component, event, helper) {
        var d = new Date();
        component.set('v.searchAcct','');
        component.set('v.selectedTeamList', []);
        component.set('v.searchTeam', '');
        component.set('v.searchGroup', '');
        component.set('v.isAdjustedItem', false);

        var mapPortTeam = component.get('v.mapPortTeam');
        var opts = [];

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

        component.set('v.isLoading', true);
        component.find('teamInput').showHelpMessageIfInvalid();
        
        if(component.get('v.searchTeam') != ''){
            helper.getRecord(component, helper);
        }else{
            helper.displayToast('error', 'Please select team.');
            component.set('v.isLoading', false);
        }
    },

    doSearch: function (component, event, helper) {
        component.set('v.isLoading', true);
        component.find('teamInput').showHelpMessageIfInvalid();
        
        if(component.get('v.searchTeam') != ''){
            helper.getRecord(component, helper);
        }else{
            helper.displayToast('error', 'Please select team.');
            component.set('v.isLoading', false);
        }
    },

    tableOnScroll : function (component, helper) {
        var wrapper1 = component.find('wrapper1');
        var wrapper2 = component.find('wrapper2');

        wrapper1.onscroll = function() {
        wrapper2.scrollLeft = wrapper1.scrollLeft;
        };
        wrapper2.onscroll = function() {
        wrapper1.scrollLeft = wrapper2.scrollLeft;
        };
    },

    closeModel: function(component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    deleteRecord: function(component, event, helper) {
        var recordId = component.get('v.deleteData.Id');

        var DealForecastData = new Object();
        DealForecastData.Id = recordId;
        
        var action = component.get('c.deleteDealForecastRecord');
        
        action.setParams({
        DFI: DealForecastData
        });
        
        action.setCallback(this, function (response) {
        var eventToast = $A.get('e.force:showToast');
        component.set('v.isModalOpen', false);
        if (response.getState() === 'SUCCESS' && component.isValid()) {
            component.set( 'v.editMode', false ); 
            eventToast.setParams({
                'title':'Success',
                'type':'success',
                'message':'Record deleted successfully.'
                });
            eventToast.fire();
            
            var a = component.get('c.doSearch');
            $A.enqueueAction(a);
  
        } else {
          eventToast.setParams({
            'title':'error',
            'type':'error',
            'message': (response.getError().message) 
            });
          eventToast.fire();
        }
      });
    
      $A.enqueueAction(action);
    },

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
    },

    openDealSummary: function(component,  event, helper){
        var workspaceAPI = component.find('workspace');

        workspaceAPI.openConsoleURL({
            url: '/lightning/n/New_Deal_Summary',
            focus: true
        }).catch(function (error) {
            console.log(error);
        });
    },
    checkIsShow: function(component,  event, helper){
        var allDataLength = component.get('v.allDataLength');
        allDataLength--;
        component.set('v.allDataLength', allDataLength);
        if (allDataLength <= 0) component.set('v.mydata', []);
    },
})