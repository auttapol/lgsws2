({
    doInit: function (component, event, helper) {
        component.set('v.fields', [
            'TMB_Customer_ID_PE__c',
            'Name',
            'Core_Banking_Suggested_Segment__c'
        ]);
        
        var action = component.get("c.getAccount");
        var accId = component.get("v.recordId");
        action.setParams({
            accId: accId
        });
        action.setCallback(this, function (response) {
            // component.set("v.permission_no", true);
            if (response.getReturnValue().Id == null) {
            // if (true) {
                component.set("v.permission_no", true);
                component.set("v.show_mb_sec", false);
            } else {
                var Main_Bank_Group_1_Name__c = response.getReturnValue().Main_Bank_Group_1_Name__c;
                var Main_Bank_Group1_Value__c = response.getReturnValue().Main_Bank_Group1_Value__c;
                var Main_Bank_Group2_Name__c = response.getReturnValue().Main_Bank_Group2_Name__c;
                var Main_Bank_Group2_Value__c = response.getReturnValue().Main_Bank_Group2_Value__c;
                var Main_Bank_Group3_Name__c = response.getReturnValue().Main_Bank_Group3_Name__c;
                var Main_Bank_Group3_Value__c = response.getReturnValue().Main_Bank_Group3_Value__c;
                var Main_Bank_Group4_Name__c = response.getReturnValue().Main_Bank_Group4_Name__c;
                var Main_Bank_Group4_Value__c = response.getReturnValue().Main_Bank_Group4_Value__c;
                var Main_Bank_Group5_Name__c = response.getReturnValue().Main_Bank_Group5_Name__c;
                var Main_Bank_Group5_Value__c = response.getReturnValue().Main_Bank_Group5_Value__c;

                var mb_yn = response.getReturnValue().RTL_Primary_Banking_All_Free_Benefit__c;
                var detail = response.getReturnValue().RTL_Main_Bank_Desc__c;
                var period = response.getReturnValue().Mainbank_Campaign_Period__c;
                // var showSection = false
                // var date = new Date();

                if (period) {
                    var dt = new Date(period);
                    var getMonth = dt.getMonth() + 1;
                    var dt_current = new Date();
                    var getMonthCurrent = dt_current.getMonth() + 1;


                    if (getMonth == getMonthCurrent) {
                        component.set("v.show_mb_sec", true);
                    }
                }
              
                if (mb_yn == true) {
                    if (response.getReturnValue().Id == null) {
                        component.set("v.mb_yn", '***');
                    } else {
                        component.set("v.mb_yn", 'Yes');
                    }
                    component.set("v.show_mb_yn", true);
                } else {
                    if (response.getReturnValue().Id == null) {
                        component.set("v.mb_yn", '***');
                    } else {
                        component.set("v.mb_yn", 'No');
                    }

                    component.set("v.show_mb_yn", false);
                }
                if (detail) {
                    if (response.getReturnValue().Id == null) {
                        const p = detail;
                        const regex = /[\D\d]/ig;

                        component.set("v.detail", p.replaceAll(regex, '*'));
                    } else {
                        component.set("v.detail", detail);
                    }
                } else {
                    component.set("v.detail", $A.get("$Label.c.no_mainbank_desc"));
                }
      
                if (Main_Bank_Group1_Value__c) {
                    var jsonList = [];
                    Main_Bank_Group1_Value__c = replaceSpecialChar(Main_Bank_Group1_Value__c);
                    var mb_group_1 = Main_Bank_Group1_Value__c.split('|');
                    for (var i = 0; i < mb_group_1.length; i++) {
                        var textSplit = mb_group_1[i].split(':');
                        var textJson = '{"Name":"' + addslashes(textSplit[0]) + '",' + '"Value":"' + addslashes(textSplit[1]) + '"}';

                        var obj = JSON.parse(textJson);
                        jsonList.push(obj);
                    }
                    if (Main_Bank_Group1_Value__c) {
                        component.set("v.mb_show_1", true);
                    }
                    component.set("v.mb_val_1", jsonList);
                    component.set("v.mb_name_1", Main_Bank_Group_1_Name__c);
                }
           
                if (Main_Bank_Group2_Value__c) {
                    var jsonList = [];
                    Main_Bank_Group2_Value__c = replaceSpecialChar(Main_Bank_Group2_Value__c);
                    var mb_group_2 = Main_Bank_Group2_Value__c.split('|');
                    for (var i = 0; i < mb_group_2.length; i++) {
                        var textSplit = mb_group_2[i].split(':');
                        var textJson = '{"Name":"' + addslashes(textSplit[0]) + '",' + '"Value":"' + addslashes(textSplit[1]) + '"}';
                        var obj = JSON.parse(textJson);
                        jsonList.push(obj);
                    }
                    if (Main_Bank_Group2_Value__c) {
                        component.set("v.mb_show_2", true);
                    }
                    component.set("v.mb_val_2", jsonList);
                    component.set("v.mb_name_2", Main_Bank_Group2_Name__c);
                }
              
                if (Main_Bank_Group3_Value__c) {
                    var jsonList = [];
                    Main_Bank_Group3_Value__c = replaceSpecialChar(Main_Bank_Group3_Value__c);
                    var mb_group_3 = Main_Bank_Group3_Value__c.split('|');
                    for (var i = 0; i < mb_group_3.length; i++) {
                        var textSplit = mb_group_3[i].split(':');
                        var textJson = '{"Name":"' + addslashes(textSplit[0]) + '",' + '"Value":"' + addslashes(textSplit[1]) + '"}';
                        var obj = JSON.parse(textJson);
                        jsonList.push(obj);
                    }
                    if (Main_Bank_Group3_Value__c) {
                        component.set("v.mb_show_3", true);
                    }
                    component.set("v.mb_val_3", jsonList);
                    component.set("v.mb_name_3", Main_Bank_Group3_Name__c);
                }
                if (Main_Bank_Group4_Value__c) {
                    var jsonList = [];
                    Main_Bank_Group4_Value__c = replaceSpecialChar(Main_Bank_Group4_Value__c);
                    var mb_group_4 = Main_Bank_Group4_Value__c.split('|');
                    for (var i = 0; i < mb_group_4.length; i++) {
                        var textSplit = mb_group_4[i].split(':');
                        var textJson = '{"Name":"' + addslashes(textSplit[0]) + '",' + '"Value":"' + addslashes(textSplit[1]) + '"}';
                        var obj = JSON.parse(textJson);
                        jsonList.push(obj);
                    }
                    if (Main_Bank_Group4_Value__c) {
                        component.set("v.mb_show_4", true);
                    }
                    component.set("v.mb_val_4", jsonList);
                    component.set("v.mb_name_4", Main_Bank_Group4_Name__c);
                }
                if (Main_Bank_Group5_Value__c) {
                    var jsonList = [];
                    Main_Bank_Group5_Value__c = replaceSpecialChar(Main_Bank_Group5_Value__c);
                    var mb_group_5 = Main_Bank_Group5_Value__c.split('|');
                    for (var i = 0; i < mb_group_5.length; i++) {
                        var textSplit = mb_group_5[i].split(':');
                        var textJson = '{"Name":"' + addslashes(textSplit[0]) + '",' + '"Value":"' + addslashes(textSplit[1]) + '"}';
                        var obj = JSON.parse(textJson);
                        jsonList.push(obj);
                    }
                    if (Main_Bank_Group5_Value__c) {
                        component.set("v.mb_show_5", true);
                    }
                    component.set("v.mb_val_5", jsonList);
                    component.set("v.mb_name_5", Main_Bank_Group5_Name__c);
                }

                // component.set("v.show_mb_sec", true);
                response.getReturnValue()
                component.set("v.rec", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

        function replaceSpecialChar(str) {
            //prevent HTML tag, HTML entities, tap, new line
            return str.replace(/(<([""^>]+)>)/gi, "").replace(/\s+/g, " ").replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "'").replace(/&#039;/g, '"');
        }

        function addslashes(string) {
            return string.replace(/\\/g, '\\\\').
                replace(/\u0008/g, '\\b').
                replace(/\t/g, '\\t').
                replace(/\n/g, '\\n').
                replace(/\f/g, '\\f').
                replace(/\r/g, '\\r').
                replace(/"/g, "\\\"");
        }

        helper.runInitialize(component, event, helper);
    },

    handleProfileName: function (component, event, helper) {
        helper.runInitialize(component, event, helper);
    }
})