({
    getRegionCodeAndName: function (component, event, helper) {
        var action = component.get('c.getRegionCodeAndName');

        console.log("channel in getRegionCodeAndName: ", component.get('v.channel'));
        action.setParams({
            "channel": component.get('v.channel')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var regionList = [];
                // console.log('region:', result);
                result.forEach((region, index) => {
                    var item = {
                        "label": region,
                        "value": region
                    };
                    regionList.push(item);
                });
                // component.set('v.regionList', regionList.sort(function (a, b) { return a.value - b.value; }));
                component.set('v.regionList', regionList);
                console.log("regionList: ", regionList);
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
    },
    getZoneCodeAndName: function (component, event, helper, region) {
        var action = component.get('c.getZoneCodeAndName');
        action.setParams({
            "channel": component.get('v.channel'),
            "region": region
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log('zone:', result);
                var zoneList = [];
                result.forEach((zone, index) => {
                    var item = {
                        "label": zone,
                        "value": zone
                    };
                    zoneList.push(item);
                });
                // component.set('v.zoneList', zoneList.sort(function (a, b) { return a.value - b.value; }));
                component.set('v.zoneList', zoneList);
                // console.log("zoneList: ", zoneList);
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
    },
    // new add
    getBranchCodeAndName: function (component, event, helper, zone) {
        var action = component.get('c.getBranchCodeAndName');
        action.setParams({
            "channel": component.get('v.channel'),
            "region": component.get('v.region'),
            "zone": component.get('v.zone')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log('codeAndName:', result);
                var codeAndNameList = [];
                result.forEach((codeAndName, index) => {
                    var item = {
                        "label": codeAndName,
                        "value": codeAndName
                    };
                    codeAndNameList.push(item);
                });
                // component.set('v.branchCode_BranchNameList', codeAndNameList.sort((a,b) => (a.value > b.value) ? 1 : ((b.value > a.value) ? -1 : 0)));
                component.set('v.branchCode_BranchNameList', codeAndNameList);
                // console.log("codeAndNameList: ", codeAndNameList);

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
    },

    setFocusedTabLabel: function (component, event, helper) {
        // var empId = component.get('v.selectedEmpId');
        // console.log('set focus' + empId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            // console.log('response.tabId = ' + response.tabId);
            // console.log('response = ' + response.tabId);

            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "T-Performance Landing Page"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom48",
                iconAlt: "Approval"
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    getChannel: function (component, event, helper) {
        //************************************************ System Admin  **************************************
        if ((component.get('v.userObj.user.Profile.Name')).includes('System Admin')) {
            var action = component.get('c.getChannel');
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var channelList = [];
                    console.log('channel:', result);

                    result.forEach((channel, index) => {
                        var item = {
                            "label": channel,
                            "value": channel
                        };
                        channelList.push(item);
                    });
                    // component.set('v.channel', 'Branch');

                    // component.set('v.channelList', channelList.sort((a,b) => (a.value > b.value) ? 1 : ((b.value > a.value) ? -1 : 0)));
                    component.set('v.channelList', channelList);
                    // ทำไม Set channel ตรงนี้แล้ว region มันเพี้ยน
                    // component.set('v.channel', channelList[0].value);

                    // Print
                    // console.log("v.channelSystemAdmin: ", component.get('v.channel'));
                    // // component.set('v.channel', 'Branch');
                    // console.log("channelList: ", channelList);
                    // console.log("channelList[0]: ", channelList[0].value);


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
        //************************************************ Other  **************************************
        else {

            // console.log('v.userObj.user.Profile.Name: ', component.get('v.userObj.user.Profile.Name'))
            // console.log("(component.get('v.userObj.user.Profile.Name')).contains('System Admin') :", (component.get('v.userObj.user.Profile.Name')).includes('System Admin'))
            var userChannelList = component.get('v.userObj.userChannel').split(";");
            // console.log('userChannelList: ', userChannelList);
            var channelList = [];
            userChannelList.forEach((channel, index) => {
                var item = {
                    "label": channel.trim(),
                    "value": channel.trim()
                };
                channelList.push(item);
            });
            component.set('v.channelList', channelList.sort((a,b) => (a.value > b.value) ? 1 : ((b.value > a.value) ? -1 : 0)));
            // ทำไม Set channel ตรงนี้แล้ว region มันเพี้ยน
            // component.set('v.channel', channelList[0].value);

            // Print
            console.log("v.channelList: ", component.get('v.channelList'));
            // console.log("channelList: ", channelList);
            // console.log("channelList[0]: ", channelList[0]);
        }
    },



})