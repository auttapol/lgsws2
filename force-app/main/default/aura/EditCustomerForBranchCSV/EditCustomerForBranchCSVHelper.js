({

    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    getDescribeFieldResult: function(component, event, helper){
        var action = component.get('c.getDataAfterRefresh');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "fields": component.get('v.FIELDSList').reduce((l, i) => {
                if (i.fieldName && !l.includes(i.fieldName))
                    l.push(i.fieldName);
                return l;
            }, []),
            "fields_translate": ['Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c', 'RTL_Other1__c', 'RTL_Preferred_Contact_Channel__c', 'RTL_Alternative_Contact_Channel__c', 'RTL_Purpose_for_Contact1__c', 'RTL_Purpose_of_Contact2__c', 'RTL_Relationship_Contact_1__c', 'RTL_Relationship_Contact_2__c']
            // "fields_translate": null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const objectInfoField = response.getReturnValue();
                const data = helper.parseObj(objectInfoField);
                component.set('v.dataFields', objectInfoField);
                for(const v of component.get('v.FIELDSList')){
                    if(data[v.fieldName].isAccessible == true){
                        component.set('v.showSubmitButton', true);
                        break;
                    }
                }
                if(data.Hobbies__c.isAccessible == true){
                    helper.getHobbiesPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.Favorite_Sport__c.isAccessible == true){
                    helper.getSportPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Lifestyle__c.isAccessible == true){
                    helper.getlifestylePicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Preferred_Activity__c.isAccessible == true){
                    helper.getOnAcPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.Favorite_Place_Travel__c.isAccessible == true){
                    helper.getTravelPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.Favorite_Music__c.isAccessible == true){
                    helper.getMusicPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.Favorite_Food__c.isAccessible == true){
                    helper.getFoodPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Other1__c.isAccessible == true){
                    helper.getOther1PicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Purpose_for_Contact1__c.isAccessible == true){
                    helper.getPurposeContact1PicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Purpose_of_Contact2__c.isAccessible == true){
                    helper.getPurposeContact2PicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Relationship_Contact_1__c.isAccessible == true){
                    helper.getRelationContact1PicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Relationship_Contact_2__c.isAccessible == true){
                    helper.getRelationContact2PicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Preferred_Contact_Channel__c.isAccessible == true){
                    helper.getPreferContactPicklistValue(component, event, helper, objectInfoField);
                }
                if(data.RTL_Alternative_Contact_Channel__c.isAccessible == true){
                    helper.getAlterContactPicklistValue(component, event, helper, objectInfoField);
                }
            } else {
                var errors = response.getError();
                console.log(errors);
            }
            setTimeout(() => {
                helper.stopSpinner(component);
            }, 2000);
        });
        $A.enqueueAction(action);
    },

    getHobbiesPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getHobbiesValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selectedHobbies = helper.parseObj(objectInfoField).Hobbies__c.value;
                const selectedList = selectedHobbies.split(";");
                const hoblist = [];
                const picklistMap = response.getReturnValue();
                console.log(picklistMap);
                component.set('v.hobbiesMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    hoblist.push(each);
                });
                component.set('v.hobbiesValue', selectedList);
                component.set('v.hobbiesOption', hoblist);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getSportPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getSportValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selectedSports = helper.parseObj(objectInfoField).Favorite_Sport__c.value;
                const selectedList = selectedSports.split(";");
                const sportList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.sportsMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    sportList.push(each);
                });
                component.set('v.sportsValue', selectedList);
                component.set('v.sportsOption', sportList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getlifestylePicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getLifeValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selectedlifestyle = helper.parseObj(objectInfoField).RTL_Lifestyle__c.value;
                const selectedList = selectedlifestyle.split(";");
                const lifeStyleList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.lifestyleMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    lifeStyleList.push(each);
                });
                component.set('v.lifestyleValue', selectedList);
                component.set('v.lifestyleOption', lifeStyleList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getOnAcPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getOnAcValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selectedlifestyle = helper.parseObj(objectInfoField).RTL_Preferred_Activity__c.value;
                const selectedList = selectedlifestyle.split(";");
                const onAcList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.onAcMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    onAcList.push(each);
                });
                component.set('v.onAcValue', selectedList);
                component.set('v.onAcOption', onAcList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getTravelPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getTravelValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selected = helper.parseObj(objectInfoField).Favorite_Place_Travel__c.value;
                const selectedList = selected.split(";");
                const optionList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.travelMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    optionList.push(each);
                });
                component.set('v.travelValue', selectedList);
                component.set('v.travelOption', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },


    getMusicPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getMusicValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selected = helper.parseObj(objectInfoField).Favorite_Music__c.value;
                const selectedList = selected.split(";");
                const optionList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.musicMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    optionList.push(each);
                });
                component.set('v.musicValue', selectedList);
                component.set('v.musicOption', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getFoodPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getFoodValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selected = helper.parseObj(objectInfoField).Favorite_Food__c.value;
                const selectedList = selected.split(";");
                const optionList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.foodMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    optionList.push(each);
                });
                component.set('v.foodValue', selectedList);
                component.set('v.foodOption', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getOther1PicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getOther1ValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                const selected = helper.parseObj(objectInfoField).RTL_Other1__c.value;
                const selectedList = selected.split(";");
                const optionList = [];
                const picklistMap = response.getReturnValue();
                component.set('v.other1Map', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    const each = {
                        'label' : picklistMap[key],
                        'value' : picklistMap[key]
                    }
                    optionList.push(each);
                });
                component.set('v.other1Value', selectedList);
                component.set('v.other1Option', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getPurposeContact1PicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getPurposeContact1ValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Purpose_for_Contact1__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Purpose_for_Contact1__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Purpose_for_Contact1__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Purpose_for_Contact1__c.value;
                    choice.push('--None--');
                }
                const picklistMap = response.getReturnValue();
                component.set('v.pfc1Map', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.pfc1Value', selected);
                component.set('v.pfc1Option', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getPurposeContact2PicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getPurposeContact2ValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Purpose_of_Contact2__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Purpose_of_Contact2__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Purpose_of_Contact2__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Purpose_of_Contact2__c.value;
                    choice.push('--None--');
                }

                const picklistMap = response.getReturnValue();
                component.set('v.pfc2Map', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.poc2Value', selected);
                component.set('v.poc2Option', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getRelationContact1PicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getRelationContact1ValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Relationship_Contact_1__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Relationship_Contact_1__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Relationship_Contact_1__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Relationship_Contact_1__c.value;
                    choice.push('--None--');
                }

                const picklistMap = response.getReturnValue();
                component.set('v.relationC1Map', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.relationC1Value', selected);
                component.set('v.relationC1Option', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getRelationContact2PicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getRelationContact2ValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Relationship_Contact_2__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Relationship_Contact_2__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Relationship_Contact_2__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Relationship_Contact_2__c.value;
                    choice.push('--None--');
                }

                const picklistMap = response.getReturnValue();
                component.set('v.relationC2Map', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.relationC2Value', selected);
                component.set('v.relationC2Option', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },


    getPreferContactPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getPreferContactValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Preferred_Contact_Channel__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Preferred_Contact_Channel__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Preferred_Contact_Channel__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Preferred_Contact_Channel__c.value;
                    choice.push('--None--');
                }

                const picklistMap = response.getReturnValue();
                component.set('v.preferContactMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.preferContactValue', selected);
                component.set('v.preferContactOption', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getAlterContactPicklistValue: function(component, event, helper, objectInfoField){
        var action = component.get('c.getAlterCValuesIntoList');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let selected = '';
                let choice = [];
                let optionList = [];
                if(component.get('v.userLanguage') == 'ไทย'){
                    selected = helper.parseObj(objectInfoField).RTL_Alternative_Contact_Channel__c.value == '' ? '--ไม่มี--' :  helper.parseObj(objectInfoField).RTL_Alternative_Contact_Channel__c.value;
                    choice.push('--ไม่มี--');
                }
                else{
                    selected = helper.parseObj(objectInfoField).RTL_Alternative_Contact_Channel__c.value == '' ? '--None--' :  helper.parseObj(objectInfoField).RTL_Alternative_Contact_Channel__c.value;
                    choice.push('--None--');
                }

                const picklistMap = response.getReturnValue();
                component.set('v.alterContactMap', picklistMap);
                Object.keys(picklistMap).forEach(function(key) {
                    choice.push(picklistMap[key]);
                });
                choice.forEach(v => {
                    if(v == selected){
                        const each = {
                            id : v,
                            label : v,
                            selected : true
                        }
                        optionList.push(each);
                    }
                    else{
                        const each = {
                            id : v,
                            label : v
                        }
                        optionList.push(each);
                    }
                });
                component.set('v.alterContactValue', selected);
                component.set('v.alterContactOption', optionList);
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration,
        });
        toastEvent.fire();
    },


    sendFieldtoUpdate: function(component, event, helper, fieldValueMap, listField){
        const obj = Object.fromEntries(fieldValueMap);
        var action = component.get('c.updateCSVForBranch');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "updateFieldMap": obj,
            "fields": listField
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var parentComponent = component.get("v.parent");                         
		        parentComponent.parentMethod(JSON.stringify(obj));
                //helper.stopSpinner(component);
            }
            else if (state === "ERROR") {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                        helper.handleError(component, event, helper, errors[0].message);
                    }
                }
                helper.stopSpinner(component);
            } else {
                console.error(response);
                helper.stopSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    closeTab: function(component, event, helper){
        var device = $A.get("$Browser.formFactor");
        if (device == 'DESKTOP') {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.openTab({
                        recordId: component.get(`v.recordId`),
                        focus: true
                    }).then((res) => {
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(err => {
                        console.log(err);
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        }
        else{
            var appEvent = $A.get("e.c:RetailCSV_Event");
            appEvent.setParams({
                isRefresh: true,
                recordId: component.get(`v.recordId`),
                fieldUpdate: []
            });
            appEvent.fire(); 
    
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId')
            
            });
            navEvt.fire();
        }
    },

    startSpinner: function (component) {
        component.set('v.isRerender', true);
    },
    stopSpinner: function (component) {
        component.set('v.isRerender', false);
    },

    getCurrentUserLanguage: function(component, event, helper){
        var action = component.get('c.getUserLanguage');
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                component.set('v.userLanguage', response.getReturnValue());
            }
            else if(state == 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        const fixError = 'Error Getting Data';
                        console.error(errors[0].message);
                        helper.displayToast('error', fixError);
                    }
                }
            }
            else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleError: function(component, event, helper, errorMessage){
        const errorArray = errorMessage.split(":");
        const displayMessage = errorArray[1].split(', ')[1];
        const errorAtField = errorArray[2];
        component.set('v.errorMessage', displayMessage);
        if(errorAtField.indexOf('RTL_Lifetime_Code__c') > -1){
            component.set('v.Lifetime_Code_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Special_Pref__c') > -1){
            component.set('v.Special_Pref_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Life_Objective_1__c') > -1){
            component.set('v.Life_Objective_1_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Life_Objective_2__c') > -1){
            component.set('v.Life_Objective_2_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Life_Objective_3__c') > -1){
            component.set('v.Life_Objective_3_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Other2__c') > -1){
            component.set('v.RTL_Other2_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Alternative_Number__c') > -1){
            component.set('v.Alternative_Number_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Contact_Person_Name_1__c') > -1){
            component.set('v.Contact_Person_Name_1_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Contact_Person_Name_2__c') > -1){
            component.set('v.Contact_Person_Name_2_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Contact_Person_Number_1__c') > -1){
            component.set('v.Contact_Person_Number_1_Error', true);
        }
        else if(errorAtField.indexOf('RTL_Contact_Person_Number_2__c') > -1){
            component.set('v.Contact_Person_Number_2_Error', true);
        }
        helper.displayToast('error', displayMessage);
    }

})