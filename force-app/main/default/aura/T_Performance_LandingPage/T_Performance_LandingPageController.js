({
    onInit: function (component, event, helper) {

        component.set('v.isChannelDisable', component.get('v.userObj.isChannelDisable'));
        component.set('v.isRegionDisable', component.get('v.userObj.isRegionDisable'));
        component.set('v.isZoneDisable', component.get('v.userObj.isZoneDisable'));
        // console.log('userObj.userChannelList: ',component.get('v.userObj.userChannelList'))
        helper.getChannel(component, event, helper);

        /***************************** Set Channel **********************************************/
        if ((component.get('v.userObj.user.Profile.Name')).includes('System Admin')) {
            component.set('v.channel', 'Branch');
            // component.set('v.channel', component.get('v.channelList[0].value'));
            // console.log('v.channelList: ', component.get('v.channelList'));
            // console.log('v.channelList[0]: ', component.get('v.channelList[0]'));
            // console.log('v.channelList[0].value: ', component.get('v.channelList[0].value'));
        } else {
            component.set('v.channel', component.get('v.userObj.userChannelList[0]'));
        }


        if (component.get('v.userObj.isRegionDisable')) {
            component.set('v.region', component.get('v.userObj.regionCodeName'));
        }
        else {
            helper.getRegionCodeAndName(component, event, helper);
        }
        if (component.get('v.userObj.isZoneDisable')) {
            component.set('v.zone', component.get('v.userObj.zoneCodeName'));
        }
        else {
            helper.getZoneCodeAndName(component, event, helper, component.get('v.region'));
        }

        helper.getBranchCodeAndName(component, event, helper);
        helper.setFocusedTabLabel(component, event, helper);

    },

    viewP4: function (component, event, helper) {

        // console.log("channel", component.get('v.channel'));
        var index = event.getSource().get("v.name");
        var teamList = component.get('v.teamList');
        var branchCode = teamList.length > 0 ? teamList[index].Branch_Team_Code__c : null;
        // console.log('branchCode:', branchCode);

        //  get new params
        var channel = component.get('v.channel');
        var region = component.get('v.region');
        var zone = component.get('v.zone');

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:T_Performance_P4",
            componentAttributes: {
                branchCode: branchCode,
                userType: component.get('v.channel') == 'Branch' ? 'Branch' : 'RASC',
                // new add
                channel: channel,
                region: region,
                zone: zone
            }
        });
        evt.fire();
    },

    handleChannel: function (component, event, helper) {
        var value = event.getSource().get("v.value");
        component.set('v.channel', value);
        // if (value == 'Wealth') {

        // reset value
        component.set('v.region', null);
        component.set('v.zone', null);
        component.set('v.branchCode_BranchName', null);

        helper.getRegionCodeAndName(component, event, helper);
        helper.getBranchCodeAndName(component, event, helper);
    },

    handleRegion: function (component, event, helper) {
        var value = '' ? null : event.getSource().get("v.value");
        // console.log('v.region', value);
        component.set('v.region', value);

        // reset value
        component.set('v.zone', null);
        component.set('v.branchCode_BranchName', null);

        helper.getZoneCodeAndName(component, event, helper, value);
        helper.getBranchCodeAndName(component, event, helper);
    },

    handleZone: function (component, event, helper) {
        var value = '' ? null : event.getSource().get("v.value");
        component.set('v.zone', value);

        // reset value
        component.set('v.branchCode_BranchName', null);

        helper.getBranchCodeAndName(component, event, helper, value); // new add
    },

    // NEW ADD
    handleBranchCode_BranchName: function (component, event, helper) {
        var value = '' ? null : event.getSource().get("v.value");
        component.set('v.branchCode_BranchName', value);
    },

    handleBranchCodeOrNameSearch: function (component, event, helper) {
        var value = '' ? null : event.getParam('value');
        component.set('v.branchCodeOrNameSearch', value);
    },

    searchPerformanceTeam: function (component, event, helper) {
        var channel = component.get('v.channel');
        var region = component.get('v.region');
        var zone = component.get('v.zone');
        var branchCode_BranchName = component.get('v.branchCode_BranchName');
        var branchCodeOrNameSearch = component.get('v.branchCodeOrNameSearch');
        console.log(channel);
        console.log(region);
        console.log(zone);

        var isChannelDisable = component.get('v.isChannelDisable');
        console.log('isChannelDisable:', isChannelDisable);
        var allValid = true;

        if (channel == null || channel == undefined) {
            allValid = false;
        }

        // allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
        //     console.log('inputCmp:', inputCmp.checkValidity());
        //     return inputCmp.checkValidity();      
        // }, true);

        // if (allValid) {
        //     console.log('Ready to submit!');
        // } else {
        //     console.log('Please update the invalid form entries and try again.');
        // }

        if (allValid) {
            var action = component.get('c.searchPerformanceTeamList');

            // new add "branchCode_branchName": branchCode_branchName And "branchCodeOrNameSearch": branchCodeOrNameSearch
            action.setParams({
                "channel": channel,
                "region": region,
                "zone": zone,
                "branchCode_BranchName": branchCode_BranchName,
                "branchCodeOrNameSearch": branchCodeOrNameSearch
            });
            // console.log("channel: ", channel);
            // console.log("region: ", region);
            // console.log("zone: ", zone);
            // console.log("branchCode_BranchName: ", branchCode_BranchName);

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    // console.log('result:', result);
                    // component.set('v.teamList', result.sort(function (a, b) { return a.Branch_Team_Code__c - b.Branch_Team_Code__c; }));
                    component.set('v.teamList', result);
                    // console.log("teamList: ", result);

                    //set searchStatus
                    component.set('v.searchStatus', 'search');

                }
                else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    console.log('message', message);
                    component.set('v.loaded', false)
                }
            });

            $A.enqueueAction(action);
        }
    },

})