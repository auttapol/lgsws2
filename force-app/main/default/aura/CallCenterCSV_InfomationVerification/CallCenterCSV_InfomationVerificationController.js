({
    onInit: function (component, event, helper) {
        component.set('v.fieldsVerify', [{
                'name': 'CCPIN_Verification_Type',
                'readonly': true,
                'value': '',
                'label': $A.get('$Label.c.CCPIN_Verification_Type'),
                'style': '',
            },
            {
                'name': 'CCPIN_Verify_By',	
                'readonly': true,	
                'value': '',	
                'label': $A.get('$Label.c.CCPIN_Verify_By'),	
                'style': '',	
            },
            {
                'name': 'CCPIN_Verification_Result',
                'readonly': true,
                'value': '',
                'label': $A.get('$Label.c.CCPIN_Verification_Result'),
                'style': '',
            },
            {
                'name': 'CCPIN_Verification_Xfer_Label',
                'readonly': true,
                'value': '',
                'label': $A.get('$Label.c.CCPIN_Verification_Xfer_Label'),
                'style': '',
            },
            {
                'name': 'CCPIN_Verification_Status',
                'readonly': true,
                'value': '',
                'label': $A.get('$Label.c.CCPIN_Verification_Status'),
                'style': '',
            },
            {
                'name': 'CCPIN_Verification_FailReason',
                'readonly': true,
                'value': '',
                'label': $A.get('$Label.c.CCPIN_Verification_FailReason'),
                'style': '',
            },
            {
                'name': 'Verification_Action',
                'readonly': false,
                'class': 'noPaddingLeft',
                'value': '',
                'style': '',
            },

        ]);
                                         
		var appEvent = $A.get("e.c:ccpageProxyEvent");
        var sfidForTab = component.get('v.recordId');
        var verf_hist_id = 'ready';
        appEvent.setParams({
            'recordId': sfidForTab,
            'verifycode': verf_hist_id,
        });
        
        appEvent.fire();
                                         
        helper.runInit(component, event, helper);
    },
    handleEventccpageProxy: function (component, event, helper) {
        // var param = 'c__vercode';
        // var verId = decodeURIComponent((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
        var verId = event.getParam('verifycode');
        var recordId = event.getParam('recordId');
        if (verId && component.get('v.recordId') == recordId) {
            helper.actionVerification(component, verId);
        }
    },
    openCXM: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var CXM = component.get('v.CXMObj');
        var focustabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log('tabId: ', response.tabId);
            focustabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focustabId,
                url: '/lightning/r/CXM_Survey__c/' + CXM.Id + '/view',
                focus: true
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
   openComplaint: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recordId = event.target.id;
        var focustabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log('tabId: ', response.tabId);
            focustabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focustabId,
                url: '/lightning/r/Case/' + recordId + '/view',
                focus: true
            });
        }).catch(function (error) {
            console.log(error);
        });
    }
})