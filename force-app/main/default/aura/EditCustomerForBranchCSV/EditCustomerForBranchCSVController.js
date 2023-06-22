({
    onInit: function (component, event, helper) {
        helper.startSpinner(component);
        var id = component.get('v.recordId');

        component.set('v.FIELDSList', [
            'Hobbies__c',
            'Favorite_Sport__c',
            'RTL_Lifestyle__c',
            'RTL_Preferred_Activity__c',
            'Favorite_Place_Travel__c',
            'Favorite_Music__c',
            'Favorite_Food__c',
            'RTL_Other1__c',
            'RTL_Special_Pref__c',
            'RTL_Life_Objective_1__c',
            'RTL_Life_Objective_2__c',
            'RTL_Life_Objective_3__c',
            'RTL_Other2__c',
            'RTL_Preferred_Contact_Channel__c',
            'RTL_Alternative_Contact_Channel__c',
            'RTL_Alternative_Number__c',
            'RTL_Contact_Person_Name_1__c',
            'RTL_Contact_Person_Name_2__c',
            'RTL_Contact_Person_Number_1__c',
            'RTL_Contact_Person_Number_2__c',
            'RTL_Purpose_for_Contact1__c',
            'RTL_Purpose_of_Contact2__c',
            'RTL_Relationship_Contact_1__c',
            'RTL_Relationship_Contact_2__c'
            ].map(m => {
                return {
                    'fieldName': m
                };
            })
        );

        component.set('v.fields_translate', [
            'Hobbies__c', 
            'Favorite_Sport__c', 
            'RTL_Lifestyle__c', 
            'RTL_Preferred_Activity__c', 
            'Favorite_Place_Travel__c', 
            'Favorite_Music__c', 
            'Favorite_Food__c', 
            'RTL_Other1__c',
            'RTL_Purpose_for_Contact1__c',
            'RTL_Purpose_of_Contact2__c',
            'RTL_Relationship_Contact_1__c',
            'RTL_Relationship_Contact_2__c',
            'RTL_Preferred_Contact_Channel__c',
            'RTL_Alternative_Contact_Channel__c'
        ]);

        helper.getCurrentUserLanguage(component, event, helper);
        helper.getDescribeFieldResult(component, event, helper);
    },
    handleSectionToggle: function (component, event, helper) {
        component.set('v.activeSections', ['A', 'B', 'C', 'D']);
    },

    onCancel : function(component, event, helper){
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

    onSubmit: function(component, event, helper){
        helper.startSpinner(component);
        const looper = new Promise((resolve, reject) => {
            let fieldList = [];
            let fieldValueMap = new Map();
            component.get('v.FIELDSList').forEach(v => {
                if(component.get(`v.dataFields.${v.fieldName}.isAccessible`) == true){
                    fieldList.push(v.fieldName);
                    if(component.get('v.fields_translate').includes(v.fieldName)){
                        let picklistMap ;
                        if(v.fieldName == 'Hobbies__c'){
                            picklistMap = component.get('v.hobbiesMap');
                        }
                        else if(v.fieldName == 'Favorite_Sport__c'){
                            picklistMap = component.get('v.sportsMap');
                        }
                        else if(v.fieldName == 'RTL_Lifestyle__c'){
                            picklistMap = component.get('v.lifestyleMap');
                        }
                        else if(v.fieldName == 'RTL_Preferred_Activity__c'){
                            picklistMap = component.get('v.onAcMap');
                        }
                        else if(v.fieldName == 'Favorite_Place_Travel__c'){
                            picklistMap = component.get('v.travelMap');
                        }
                        else if(v.fieldName == 'Favorite_Music__c'){
                            picklistMap = component.get('v.musicMap');
                        }
                        else if(v.fieldName == 'Favorite_Food__c'){
                            picklistMap = component.get('v.foodMap');
                        }
                        else if(v.fieldName == 'RTL_Other1__c'){
                            picklistMap = component.get('v.other1Map');
                        }
                        else if(v.fieldName == 'RTL_Purpose_for_Contact1__c'){
                            picklistMap = component.get('v.pfc1Map');
                        }
                        else if(v.fieldName == 'RTL_Purpose_of_Contact2__c'){
                            picklistMap = component.get('v.pfc2Map');
                        }
                        else if(v.fieldName == 'RTL_Relationship_Contact_1__c'){
                            picklistMap = component.get('v.relationC1Map');
                        }
                        else if(v.fieldName == 'RTL_Relationship_Contact_2__c'){
                            picklistMap = component.get('v.relationC2Map');
                        }
                        else if(v.fieldName == 'RTL_Preferred_Contact_Channel__c'){
                            picklistMap = component.get('v.preferContactMap');
                        }
                        else if(v.fieldName == 'RTL_Alternative_Contact_Channel__c'){
                            picklistMap = component.get('v.alterContactMap');
                        }
                        const value = component.get(`v.dataFields.${v.fieldName}.value`);
                        let finalVallue = [];
                        Object.keys(picklistMap).forEach(function(key) {
                            if(value.includes(picklistMap[key])){
                                finalVallue.push(key)
                            }
                        });
                        fieldValueMap.set(v.fieldName, finalVallue.join(';'));
                    }
                    else{
                        const value = component.get(`v.dataFields.${v.fieldName}.value`);
                        fieldValueMap.set(v.fieldName, value);
                    }
                }
            });
            fieldValueMap.set('Id', component.get('v.recordId'));
            component.set('v.FieldsUpdateList', fieldList);
            resolve(fieldValueMap);
            reject('error in loop');
        });
        looper.then((mapValue) => {
            helper.sendFieldtoUpdate(component, event, helper, mapValue, component.get('v.FieldsUpdateList'));
        }).catch((error) => {
            console.log(error);
        })
    },

    hobbiesHandleChange: function (component, event) {
        component.set('v.dataFields.Hobbies__c.value', event.getParam('value'));
    },

    sportsHandleChange: function (component, event) {
        component.set('v.dataFields.Favorite_Sport__c.value', event.getParam('value'));
    },

    lifestyleHandleChange: function (component, event) {
        component.set('v.dataFields.RTL_Lifestyle__c.value', event.getParam('value'));
    },

    onAcHandleChange: function (component, event) {
        component.set('v.dataFields.RTL_Preferred_Activity__c.value', event.getParam('value'));
    },

    travelHandleChange: function (component, event) {
        component.set('v.dataFields.Favorite_Place_Travel__c.value', event.getParam('value'));
    },

    musicHandleChange: function (component, event) {
        component.set('v.dataFields.Favorite_Music__c.value', event.getParam('value'));
    },

    foodHandleChange: function (component, event) {
        component.set('v.dataFields.Favorite_Food__c.value', event.getParam('value'));
    },

    other1HandleChange: function (component, event) {
        component.set('v.dataFields.RTL_Other1__c.value', event.getParam('value'));
    },

    onPFC1Change: function (component, event){
        if(component.find('PFC1').get('v.value') == '--None--' || component.find('PFC1').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Purpose_for_Contact1__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Purpose_for_Contact1__c.value', component.find('PFC1').get('v.value'));
        }
    },

    onPOC2Change: function (component, event){
        if(component.find('POC2').get('v.value') == '--None--' || component.find('POC2').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Purpose_of_Contact2__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Purpose_of_Contact2__c.value', component.find('POC2').get('v.value'));
        }
    },

    onRelationC1Change: function (component, event){
        if(component.find('RelationC1').get('v.value') == '--None--' || component.find('RelationC1').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Relationship_Contact_1__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Relationship_Contact_1__c.value', component.find('RelationC1').get('v.value'));
        }
    },

    onRelationC2Change: function (component, event){
        if(component.find('RelationC2').get('v.value') == '--None--' || component.find('RelationC2').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Relationship_Contact_2__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Relationship_Contact_2__c.value', component.find('RelationC2').get('v.value'));
        }
    },

    onPreferContactChange: function (component, event){
        if(component.find('PreferContact').get('v.value') == '--None--' || component.find('PreferContact').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Preferred_Contact_Channel__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Preferred_Contact_Channel__c.value', component.find('PreferContact').get('v.value'));
        }
    },

    onAlterContactChange: function (component, event){
        if(component.find('AlterContact').get('v.value') == '--None--' || component.find('AlterContact').get('v.value') == '--ไม่มี--'){
            component.set('v.dataFields.RTL_Alternative_Contact_Channel__c.value', '');
        }
        else{
            component.set('v.dataFields.RTL_Alternative_Contact_Channel__c.value', component.find('AlterContact').get('v.value'));
        }
    },

})