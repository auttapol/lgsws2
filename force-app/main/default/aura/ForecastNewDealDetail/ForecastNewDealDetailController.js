({
    onPageReferenceChange: function(component, event, helper) {
        component.set("v.isLoading",true);
        var myPageRef = component.get("v.pageReference");
        var id = myPageRef.state.c__id;
        var dealForecastId = myPageRef.state.c__dealForecastId;
        component.set("v.id", id);
        component.set("v.dealForecastId", dealForecastId);
        
        var action = component.get("c.getDealForecastDetail");
        
        action.setParams({
            Id: dealForecastId
        });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {
                var res = response.getReturnValue();
                if (Object.keys(res).length != 0) {
                    if ((res.dealForecastList).length > 0) {
                        var detail = helper.setData(
                        component,
                        helper,
                        res.dealForecastList[0]
                        );
                        component.set("v.dealForecastDetail", detail);
                    } 
                    if ((res.monthlyForecastList).length > 0 && (res.RTSECredit).length > 0) {
                        var monthlyForecastList = helper.setMonthlyForecast(component, helper, res.monthlyForecastList, res.dealForecastList[0]);
                        component.set('v.monthlyForecastList', monthlyForecastList);
                        component.set("v.RTSECredit", res.RTSECredit);
                        var volumeList = monthlyForecastList.map((a, i) => {
                            if(i == 0) return a.Ending_Balance__c
                              else return a.Ending_Balance__c - monthlyForecastList[i-1].Ending_Balance__c
                        })
                        component.set("v.dumpVolumeData", volumeList);
                        helper.setVolumeData(component, helper, detail, volumeList, res.RTSECredit, monthlyForecastList);
                    }
                }
                component.set("v.isLoading",false);
            }
        });

        $A.enqueueAction(action);

    },
    saveEditedData: function (component, event, helper) {
        var MonthlyForecastDataList = helper.setMonthlyForecastData(component);
        var dealForecastDetail = component.get("v.dealForecastDetail");
        var startMonth = component.get('v.monthNumber');

        if(dealForecastDetail.startMonth == null || dealForecastDetail.startYear == null) {
            var eventToast = $A.get("e.force:showToast");
            eventToast.setParams({
                "type":'error',
                "message": $A.get('$Label.c.please_fill_in_expected_start_date')
            });
            eventToast.fire();
        } else {

            var canSave = helper.setDataAfterChange(component, helper);
            helper.setEditData(component, helper);
            
            if(canSave) {
                component.set("v.isLoading",true);
                var action = component.get("c.saveMonthlyForecastRecord");
                action.setParams({
                    MFI: MonthlyForecastDataList,
                    startMonth : startMonth
                });
            
                action.setCallback(this, function (response) {
                    var eventToast = $A.get("e.force:showToast");
                    if (response.getState() === "SUCCESS" && component.isValid()) {
                        component.set( "v.editMode", false ); 
                        eventToast.setParams({
                            "title":'Success',
                            "type":'success',
                            "message":'Record updated successfully.'
                            });
                        eventToast.fire(); 
                        
                        var target = component.find('isDaft');
                        component.set('v.showSaveBtn', false);
                        component.set('v.isDaft', false);
                        $A.util.removeClass(target, 'slds-is-edited');
            
                    } else {
                        eventToast.setParams({
                            "title":'error',
                            "type":'error',
                            "message": (response.getError().message) 
                        });
                        eventToast.fire();
                    }
                });
                
                component.set("v.isLoading",false);
                $A.enqueueAction(action);
            } else {
                var eventToast = $A.get("e.force:showToast");
                eventToast.setParams({
                    "type":'error',
                    "message": $A.get('$Label.c.Starting_volume_cannot_be_greater')
                });
                eventToast.fire();
            }
        }
        

    },
    onChange: function (component, event, helper) {
		var isDaft = component.get('v.isDaft');
		if (!isDaft) {
			var target = component.find('isDaft');
			component.set('v.showSaveBtn', true);
			component.set('v.isDaft', true);
            $A.util.addClass(target, 'slds-is-edited');
        }
	},

	showEdit: function (component, event, helper) {
        var name = event.target.getAttribute('data-value');
        var buttonName = name + 'EditButton';
        var target = component.find(buttonName);
        $A.util.removeClass(target, 'slds-hidden');
	},
    hideEdit: function (component, event, helper) {
		var name = event.target.getAttribute('data-value');
		var buttonName = name + 'EditButton';
		var target = component.find(buttonName);
		$A.util.addClass(target, 'slds-hidden');
    },
    EditName: function (component, event, helper) {
        var FieldName = event.target.getAttribute('data-value');
        var attr = 'v.' + FieldName + 'EditMode';
        component.set(attr, true);
        var FieldAuraId = FieldName + 'id';
        setTimeout(function () {
            component.find(FieldAuraId).focus();
        }, 100);
	},
	closeNameBox: function (component, event, helper) {
        var canSave = helper.setDataAfterChange(component, helper);
        helper.setEditData(component, helper);
        if(canSave) {
            component.set("v.Volume1EditMode",false);
            component.set("v.Volume2EditMode",false);
            component.set("v.Volume3EditMode",false);
            component.set("v.Volume4EditMode",false);
            component.set("v.Volume5EditMode",false);
            component.set("v.Volume6EditMode",false);
            component.set("v.Volume7EditMode",false);
            component.set("v.Volume8EditMode",false);
            component.set("v.Volume9EditMode",false);
            component.set("v.Volume10EditMode",false);
            component.set("v.Volume11EditMode",false);
            component.set("v.Volume12EditMode",false);
        } else {
            var eventToast = $A.get("e.force:showToast");
            eventToast.setParams({
                "type":'error',
                "message": $A.get('$Label.c.Starting_volume_cannot_be_greater')
            });
            eventToast.fire();
        }
      
    },
    cancelEditedData: function (component, event, helper) {
        var detail = component.get("v.dealForecastDetail");
        var RTSECredit = component.get("v.RTSECredit");
        var volumeList = component.get("v.dumpVolumeData");
        var monthlyForecastList = component.get('v.monthlyForecastList');

        helper.setVolumeData(component, helper, detail, volumeList, RTSECredit, monthlyForecastList);

        var target = component.find('isDaft');
        component.set('v.showSaveBtn', false);
        component.set('v.isDaft', false);
        $A.util.removeClass(target, 'slds-is-edited');

        component.set("v.Volume1EditMode",false);
        component.set("v.Volume2EditMode",false);
        component.set("v.Volume3EditMode",false);
        component.set("v.Volume4EditMode",false);
        component.set("v.Volume5EditMode",false);
        component.set("v.Volume6EditMode",false);
        component.set("v.Volume7EditMode",false);
        component.set("v.Volume8EditMode",false);
        component.set("v.Volume9EditMode",false);
        component.set("v.Volume10EditMode",false);
        component.set("v.Volume11EditMode",false);
        component.set("v.Volume12EditMode",false);
    }
})