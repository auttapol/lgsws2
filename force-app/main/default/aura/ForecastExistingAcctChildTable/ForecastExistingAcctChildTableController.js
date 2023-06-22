({
	onInit: function (component, event, helper) {
		var groupData = helper.parseObj(component.get('v.groupData'));
        if(groupData){
            component.set('v.currentData', groupData.Current ? groupData.Current : {});
            component.set('v.drawDownData', groupData.Drawdown ? groupData.Drawdown : {});
            component.set('v.lastYearData', groupData.LastYear ? groupData.LastYear : {});
            component.set('v.drawDownLastYearData', groupData.LastYearDrawDown ? groupData.LastYearDrawDown : {});
            helper.sumdatatoGroupLevel(component, event, helper);
        }
	},

	EditData: function (component, event, helper) {
		var groupData = helper.parseObj(component.get('v.groupData'));
		var today=new Date();
		var FieldName = event.target.getAttribute('data-value');
		var words = FieldName.split('-');
		var period = component.get('v.period');
		var week = parseInt(words[1])-1;
		var lastOfWeek=new Date(parseInt(groupData.Year__c) , parseInt(groupData.Month__c)-1 , period[week][1] +1 );

		if(today.getFullYear() < parseInt(groupData.Year__c) || (today.getFullYear() == parseInt(groupData.Year__c) && today.getMonth() <= parseInt(groupData.Month__c)-1) && today < lastOfWeek){
			var attr = 'v.' + words[0] + 'EditMode';
			if (!component.get(attr) && words[0] != 'null') {
				component.set(attr, true);
				var FieldAuraId = words[0] + 'id';
				setTimeout(function () {
					component.find(FieldAuraId).focus();
				}, 100);
			}
		}
	},

	closeInputBox: function (component, event, helper) {
		var target = component.find('isDaft');
		for (var i = 1; i <= 6; i++) {
			var repaymentAttr = 'v.repayment' + i + 'EditMode';
			var drawdownAttr = 'v.drawdown' + i + 'EditMode';
			var dummyrepayment = 'v.DummyRecData.repayment'+i;
			var dummyDrawdown = 'v.DummyRecData.drawdown'+i;
			if(component.get(dummyrepayment) < 0){
				if(component.get('v.selectedPrdDomain') == 'Credit'){
					helper.displayToast('error', $A.get("$Label.c.Repayment_must_be_greater_than_zero"));
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}else{
					helper.displayToast('error', $A.get("$Label.c.Due_amount_must_be_greater_than_zero"));
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}
			}
			if (component.get(dummyDrawdown) < 0) {
				if(component.get('v.selectedPrdDomain') == 'Credit'){
					helper.displayToast('error', $A.get("$Label.c.Drawdown_must_be_greater_than_zero"));
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}else{
					helper.displayToast('error', $A.get("$Label.c.Rollover_must_be_greater_than_zero"));
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}
			}
			component.set(repaymentAttr, false);
			component.set(drawdownAttr, false);
		}
	},

	onChange: function (component, event, helper) {
		var isDaft = component.get('v.isDaft');
		if (!isDaft) {
			var target = component.find('isDaft');
			component.set('v.showSaveChildeBtn', true);
			component.set('v.isDaft', true);
			$A.util.addClass(target, 'slds-is-edited');
		}
	},

	showEdit: function (component, event, helper) {
		var groupData = helper.parseObj(component.get('v.groupData'));
		var today=new Date();
		var name = event.target.getAttribute('data-value');
		var words = name.split('-');
		var period = component.get('v.period');
		var week = parseInt(words[1])-1;
		var lastOfWeek=new Date(parseInt(groupData.Year__c) , parseInt(groupData.Month__c)-1 , period[week][1] +1 );

		if(today.getFullYear() < parseInt(groupData.Year__c) || (today.getFullYear() == parseInt(groupData.Year__c) && today.getMonth() <= parseInt(groupData.Month__c)-1) && today < lastOfWeek){
			var buttonName = words[0] + 'EditButton';
			var target = component.find(buttonName);
			$A.util.removeClass(target, 'slds-hidden');
		}
	},

	hideEdit: function (component, event, helper) {
		var groupData = helper.parseObj(component.get('v.groupData'));
		var today=new Date();
		var name = event.target.getAttribute('data-value');
		var words = name.split('-');
		var period = component.get('v.period');
		var week = parseInt(words[1])-1;
		var lastOfWeek=new Date(parseInt(groupData.Year__c) , parseInt(groupData.Month__c)-1 , period[week][1] +1 );

		if(today.getFullYear() < parseInt(groupData.Year__c) || (today.getFullYear() == parseInt(groupData.Year__c) && today.getMonth() <= parseInt(groupData.Month__c)-1) && today < lastOfWeek){
			var buttonName = words[0] + 'EditButton';
			var target = component.find(buttonName);
			$A.util.addClass(target, 'slds-hidden');
		}
	},

	goToDetail: function (component, event, helper) {
		var workspaceAPI = component.find('workspace');
		workspaceAPI.getAllTabInfo().then(function (response) {
			var primaryTabInfo = response.find(f => f.pageReference.attributes.componentName == 'c__ForecastExistingDetail');
			if(!primaryTabInfo){
				workspaceAPI.openTab({
					pageReference: {
						'type': 'standard__component',
						'attributes': {
							'componentName': 'c__ForecastExistingDetail',
						},
						'state': {
							'c__id': component.get('v.groupData.Customer__c'),
							'c__productType': component.get('v.groupData.Product_Type__c'),
							'c__month': component.get('v.groupData.Month__c'),
							'c__year': component.get('v.groupData.Year__c'),
						}
					},
				}).then((response) => {
					workspaceAPI.setTabLabel({
						tabId: response,
						label: 'Forecast Account Detail',
					});
					workspaceAPI.setTabIcon({
						tabId: response,
						icon: 'standard:product',
						iconAlt: component.get('v.DummyRecData.nameTh')
					});
				}).catch(function (error) {
				});
			}else{
				var tabId = primaryTabInfo.tabId;
				var subtabTabInfo = primaryTabInfo.subtabs.find(f => f.pageReference.state.c__id == component.get('v.groupData.Customer__c') && f.pageReference.state.c__productType == component.get('v.groupData.Product_Type__c') && f.pageReference.state.c__month == component.get('v.groupData.Month__c') && f.pageReference.state.c__year == component.get('v.groupData.Year__c'));
				if(!subtabTabInfo){
					//opennew
					if(primaryTabInfo.pageReference.state.c__id == component.get('v.groupData.Customer__c') && primaryTabInfo.pageReference.state.c__productType == component.get('v.groupData.Product_Type__c') && primaryTabInfo.pageReference.state.c__month == component.get('v.groupData.Month__c') && primaryTabInfo.pageReference.state.c__year == component.get('v.groupData.Year__c')){
						workspaceAPI.closeTab({tabId: tabId}).then(function(response) {
							setTimeout(() => {
								workspaceAPI.openTab({
									pageReference: {
										'type': 'standard__component',
										'attributes': {
											'componentName': 'c__ForecastExistingDetail',
										},
										'state': {
											'c__id': component.get('v.groupData.Customer__c'),
											'c__productType': component.get('v.groupData.Product_Type__c'),
											'c__month': component.get('v.groupData.Month__c'),
											'c__year': component.get('v.groupData.Year__c'),
										}
									},
								}).then((response) => {
									workspaceAPI.setTabLabel({
										tabId: response,
										label: 'Forecast Account Detail',
									});
									workspaceAPI.setTabIcon({
										tabId: response,
										icon: 'standard:product',
										iconAlt: component.get('v.DummyRecData.nameTh')
									});
								}).catch(function (error) {
								});
							}, 500);
						}).catch(function(error) {
						});
					}else{
						workspaceAPI.openSubtab({
							parentTabId: tabId,
							pageReference: {
									'type': 'standard__component',
									'attributes': {
										'componentName': 'c__ForecastExistingDetail',
									},
									'state': {
										'c__id': component.get('v.groupData.Customer__c'),
										'c__productType': component.get('v.groupData.Product_Type__c'),
										'c__month': component.get('v.groupData.Month__c'),
										'c__year': component.get('v.groupData.Year__c'),
									}
							},
							focus: true
						}).then((response) => {
							workspaceAPI.setTabLabel({
								tabId: response,
								label: component.get('v.DummyRecData.nameTh')
							});
							workspaceAPI.setTabIcon({
								tabId: response,
								icon: 'standard:product',
								iconAlt: component.get('v.DummyRecData.nameTh')
							});
						}).catch(function (error) {
						});
					}
				}else{
					//focus GOD.
					workspaceAPI.closeTab({tabId: subtabTabInfo.tabId}).then(function(response) {
						setTimeout(() => {
							workspaceAPI.openSubtab({
								parentTabId: tabId,
								pageReference: {
										'type': 'standard__component',
										'attributes': {
											'componentName': 'c__ForecastExistingDetail',
										},
										'state': {
											'c__id': component.get('v.groupData.Customer__c'),
											'c__productType': component.get('v.groupData.Product_Type__c'),
											'c__month': component.get('v.groupData.Month__c'),
											'c__year': component.get('v.groupData.Year__c'),
										}
								},
								focus: true
							}).then((response) => {
								workspaceAPI.setTabLabel({
									tabId: response,
									label: component.get('v.DummyRecData.nameTh')
								});
								workspaceAPI.setTabIcon({
									tabId: response,
									icon: 'standard:product',
									iconAlt: component.get('v.DummyRecData.nameTh')
								});
							}).catch(function (error) {
							});
						}, 500);
					}).catch(function(error) {
					});
				}
			}
		});
	},

	saveRow: function (component, event, helper) {
		var allDrawDown = 0 ;
        var allrepayment = 0 ;
		var totalOldDD = 0 ;
		var lastmonth = component.get('v.DummyRecData.lastMonthEndingBalMillionUnit');
		var limit = component.get('v.DummyRecData.limitMillionUnit');
        var isOverLimited = false;
       	var target = component.find('isDaft');
		var DummyRecData = component.get('v.DummyRecData');
		var TempRecData = component.get('v.TempRecData');
		var isDDChange = false;
		var isRepayChange = false;
		component.set('v.isLoading',true);
		for (var i = 1; i <= 6; i++) {

			allDrawDown += DummyRecData['drawdown'+i];
            allrepayment += DummyRecData['repayment'+i];
			totalOldDD += TempRecData['drawdown'+i];
            if(allDrawDown - allrepayment + lastmonth > limit) isOverLimited = true;
			if(DummyRecData['drawdown'+i] !== TempRecData['drawdown'+i]) isDDChange = true;
			if(DummyRecData['repayment'+i] !== TempRecData['repayment'+i]) isRepayChange = true;
		}
        if(isDDChange && isRepayChange){
			if(allDrawDown - totalOldDD > 0){
				if(component.get('v.selectedPrdDomain') == 'Credit'){
					helper.displayToast('error', "Please complete Drawdown and save first, then update Repayment.");
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}else{
					helper.displayToast('error', "Please complete Rollover and save first, then update Due amount.");
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}
                component.set('v.isLoading',false);
			}else{
				if(component.get('v.selectedPrdDomain') == 'Credit'){
					helper.displayToast('error', "Please complete Repayment and save first, then update Drawdown.");
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}else{
					helper.displayToast('error', "Please complete Due amount and save first, then update Rollover.");
					$A.util.addClass(target, 'slds-cell-edit slds-has-error');
				}
                component.set('v.isLoading',false);
			}
		}else if(isOverLimited && component.get('v.isModalOpen') == false && component.get('v.isCredit')){
			component.set('v.isModalOpen' , true);
            component.set('v.isLoading',false);
		}else if(component.get('v.isModalOpen') == true){
			helper.saveSingleRecord(component, event, helper);
			component.set('v.isModalOpen' , false);
		}
		else{
			helper.saveSingleRecord(component, event, helper);
		}

	},

	closeModel: function(component, event, helper){
		component.set('v.isModalOpen' , false);

	},
	cancelEdit:function (component, event, helper) {
		var target = component.find('isDaft');
		component.set('v.DummyRecData', helper.parseObj(component.get('v.TempRecData')));
		component.set('v.showSaveChildeBtn', false);
		component.set('v.isDaft', false);
		if($A.util.hasClass(target, "slds-is-edited")) $A.util.removeClass(target, 'slds-is-edited');
		if($A.util.hasClass(target, "slds-cell-edit slds-has-error")) $A.util.removeClass(target, 'slds-cell-edit slds-has-error');
	},
});