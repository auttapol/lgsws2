({
	parseObj: function (objFields) {
		return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
	},

	sumdatatoGroupLevel: function (component, event, helper) {
		var currentData = component.get('v.currentData');
		var drawDownData = component.get('v.drawDownData');
		var lastYearData = component.get('v.lastYearData');
		var lastYearDrawDownData = component.get('v.drawDownLastYearData');
		var limit = 0;
		var currentEndingBal = 0;
		var lastYearEndingBal = 0;
		var averageBalance = 0;
		var lastMonthEndingBal = 0;
		var projectedBalance = 0;
		var RepayWeek1 = 0;
		var RepayWeek2 = 0;
		var RepayWeek3 = 0;
		var RepayWeek4 = 0;
		var RepayWeek5 = 0;
		var RepayWeek6 = 0;
		var drawdownWeek1 = 0;
		var drawdownWeek2 = 0;
		var drawdownWeek3 = 0;
		var drawdownWeek4 = 0;
		var drawdownWeek5 = 0;
		var drawdownWeek6 = 0;

		var TempData = {};
		if (currentData) {
			var tempRec = currentData[0];
			TempData = {
				customerId: tempRec.Customer__c ? tempRec.Customer__c : '',
				month: tempRec.Month__c ? tempRec.Month__c : '',
				year: tempRec.Year__c ? tempRec.Year__c : '',
				shortId: tempRec.Customer__r.TMB_Customer_ID_PE__c ? (tempRec.Customer__r.TMB_Customer_ID_PE__c.substring(4)).replace(/^0+/, '') : '',
				nameTh: tempRec.Customer__r.RTL_Customer_Name_TH__c ? tempRec.Customer__r.RTL_Customer_Name_TH__c : '',
				rm: tempRec.Customer__r.OwnerId ? tempRec.Customer__r.Owner.Name ? tempRec.Customer__r.Owner.Name : '' : '',
				groupName: tempRec.Customer__r.Group__r ? tempRec.Customer__r.Group__r.Name ? tempRec.Customer__r.Group__r.Name : '' : '',
				team: tempRec.Team_Code__c ? tempRec.Team_Code__c : '',
				productType: tempRec.Product_Type__c ? tempRec.Product_Type__c : tempRec.Product_Type__c,
				_4G: tempRec.X4G__c ? tempRec.X4G__c : '',

				limit: parseFloat(limit.toFixed(2)),
				limitMillionUnit: parseFloat((limit / 10 ** 6).toFixed(2)),

				currentEndingBalance: parseFloat(currentEndingBal.toFixed(2)),
				currentEndingBalanceMillionUnit: parseFloat((currentEndingBal / 10 ** 6).toFixed(2)),

				lastYearEndingBal: parseFloat(lastYearEndingBal),
				lastYearEndingBalMillionUnit: parseFloat((lastYearEndingBal / 10 ** 6).toFixed(2)),

				averageBalance: parseFloat(averageBalance.toFixed(2)),
				averageBalanceMillionUnit: parseFloat((averageBalance / 10 ** 6).toFixed(2)),

				lastMonthEndingBal: parseFloat(lastMonthEndingBal.toFixed(2)),
				lastMonthEndingBalMillionUnit: parseFloat((lastMonthEndingBal / 10 ** 6).toFixed(2)),

				projectBal: parseFloat(projectedBalance.toFixed(2)),
				projectBalMillionUnit: parseFloat((projectedBalance / 10 ** 6).toFixed(2)),

				repayment1: parseFloat((RepayWeek1 / 10 ** 6).toFixed(2)),
				repayment2: parseFloat((RepayWeek2 / 10 ** 6).toFixed(2)),
				repayment3: parseFloat((RepayWeek3 / 10 ** 6).toFixed(2)),
				repayment4: parseFloat((RepayWeek4 / 10 ** 6).toFixed(2)),
				repayment5: parseFloat((RepayWeek5 / 10 ** 6).toFixed(2)),
				repayment6: parseFloat((RepayWeek6 / 10 ** 6).toFixed(2)),

				drawdown1: parseFloat((drawdownWeek1 / 10 ** 6).toFixed(2)),
				drawdown2: parseFloat((drawdownWeek2 / 10 ** 6).toFixed(2)),
				drawdown3: parseFloat((drawdownWeek3 / 10 ** 6).toFixed(2)),
				drawdown4: parseFloat((drawdownWeek4 / 10 ** 6).toFixed(2)),
				drawdown5: parseFloat((drawdownWeek5 / 10 ** 6).toFixed(2)),
				drawdown6: parseFloat((drawdownWeek6 / 10 ** 6).toFixed(2)),

				lastUpdatedBy: '',
				lastUpdatedDate: '',
			};

			var totalCurrentData = currentData.reduce(function (result, item) {
				result.limit += item.Limit__c ? parseFloat(item.Limit__c) : 0;
				result.currentEndingBal += item.Current_Ending_Balance__c ? parseFloat(item.Current_Ending_Balance__c) : 0;
				result.averageBalance += item.Average_Balance_YTD__c ? parseFloat(item.Average_Balance_YTD__c) : 0;
				result.lastMonthEndingBal += item.Last_Month_Ending_Balance__c ? parseFloat(item.Last_Month_Ending_Balance__c) : 0;
				result.projectedBalance += item.F_Projected_Balance__c ? parseFloat(item.F_Projected_Balance__c) : 0;
				
				result.RepayWeek1 += item.Repay_Due_Amount_Week1__c ? parseFloat(item.Repay_Due_Amount_Week1__c) : 0;
				result.RepayWeek2 += item.Repay_Due_Amount_Week2__c ? parseFloat(item.Repay_Due_Amount_Week2__c) : 0;
				result.RepayWeek3 += item.Repay_Due_Amount_Week3__c ? parseFloat(item.Repay_Due_Amount_Week3__c) : 0;
				result.RepayWeek4 += item.Repay_Due_Amount_Week4__c ? parseFloat(item.Repay_Due_Amount_Week4__c) : 0;
				result.RepayWeek5 += item.Repay_Due_Amount_Week5__c ? parseFloat(item.Repay_Due_Amount_Week5__c) : 0;
				result.RepayWeek6 += item.Repay_Due_Amount_Week6__c ? parseFloat(item.Repay_Due_Amount_Week6__c) : 0;

				if (item.Last_Update_Adjustment__c && (result.lastUpdatedDate == '' || new Date(result.lastUpdatdrawdownWeek1edDate) < new Date(item.Last_Update_Adjustment__c))) {
					result.lastUpdatedBy = item.Last_Adjustment_By__r ? item.Last_Adjustment_By__r.Name ? item.Last_Adjustment_By__r.Name : '' : '';
					result.lastUpdatedDate = item.Last_Update_Adjustment__c ? item.Last_Update_Adjustment__c : '';
				}

				return result;
			}, { limit: 0, currentEndingBal: 0, averageBalance: 0, lastMonthEndingBal: 0, projectedBalance: 0, RepayWeek1: 0, RepayWeek2: 0, RepayWeek3: 0, RepayWeek4: 0, RepayWeek5: 0, RepayWeek6: 0, lastUpdatedBy: '', lastUpdatedDate: '' });

			var totalDrawdownData = drawDownData.reduce(function(result, item){
				result.drawdownWeek1 += item.Drawdown_Rollover_Week1__c ? parseFloat(item.Drawdown_Rollover_Week1__c) : 0;
				result.drawdownWeek2 += item.Drawdown_Rollover_Week2__c ? parseFloat(item.Drawdown_Rollover_Week2__c) : 0;
				result.drawdownWeek3 += item.Drawdown_Rollover_Week3__c ? parseFloat(item.Drawdown_Rollover_Week3__c) : 0;
				result.drawdownWeek4 += item.Drawdown_Rollover_Week4__c ? parseFloat(item.Drawdown_Rollover_Week4__c) : 0;
				result.drawdownWeek5 += item.Drawdown_Rollover_Week5__c ? parseFloat(item.Drawdown_Rollover_Week5__c) : 0;
				result.drawdownWeek6 += item.Drawdown_Rollover_Week6__c ? parseFloat(item.Drawdown_Rollover_Week6__c) : 0;
				
				result.RepayWeek1 += item.Repay_Due_Amount_Week1__c ? parseFloat(item.Repay_Due_Amount_Week1__c) : 0;
				result.RepayWeek2 += item.Repay_Due_Amount_Week2__c ? parseFloat(item.Repay_Due_Amount_Week2__c) : 0;
				result.RepayWeek3 += item.Repay_Due_Amount_Week3__c ? parseFloat(item.Repay_Due_Amount_Week3__c) : 0;
				result.RepayWeek4 += item.Repay_Due_Amount_Week4__c ? parseFloat(item.Repay_Due_Amount_Week4__c) : 0;
				result.RepayWeek5 += item.Repay_Due_Amount_Week5__c ? parseFloat(item.Repay_Due_Amount_Week5__c) : 0;
				result.RepayWeek6 += item.Repay_Due_Amount_Week6__c ? parseFloat(item.Repay_Due_Amount_Week6__c) : 0;

				result.lastMonthEndingBal += item.Last_Month_Ending_Balance__c ? item.Last_Month_Ending_Balance__c : 0;

				result.projectedBalance += item.F_Projected_Balance__c ? parseFloat(item.F_Projected_Balance__c) : 0;

				if (item.Last_Update_Adjustment__c && (result.lastUpdatedDate == '' || new Date(result.lastUpdatdrawdownWeek1edDate) < new Date(item.Last_Update_Adjustment__c))) {
					result.lastUpdatedBy = item.Last_Adjustment_By__r ? item.Last_Adjustment_By__r.Name ? item.Last_Adjustment_By__r.Name : '' : '';
					result.lastUpdatedDate = item.Last_Update_Adjustment__c ? item.Last_Update_Adjustment__c : '';
				}

				return result;
			}, {lastMonthEndingBal: 0, RepayWeek1: 0, RepayWeek2: 0, RepayWeek3: 0, RepayWeek4: 0, RepayWeek5: 0, RepayWeek6: 0,drawdownWeek1: 0, drawdownWeek2: 0, drawdownWeek3: 0, drawdownWeek4: 0, drawdownWeek5: 0, drawdownWeek6: 0, projectedBalance: 0, lastUpdatedBy: '', lastUpdatedDate: '' });

            var totalLastYear = lastYearData.reduce(function(result, item){
				result.currentEndingBal += item.Current_Ending_Balance__c ? parseFloat(item.Current_Ending_Balance__c) : 0;
				result.EndingBalance += item.Ending_Balance__c ? parseFloat(item.Ending_Balance__c) : 0;
				return result;
			}, {EndingBalance: 0, currentEndingBal: 0});

			var totalLastYearDrawdown = lastYearDrawDownData.reduce(function(result, item){
				result.EndingBalance += item.Ending_Balance__c ? parseFloat(item.Ending_Balance__c) : 0;
				return result;
			}, {EndingBalance: 0});

			TempData.limit = parseFloat(totalCurrentData.limit);
			TempData.limitMillionUnit = parseFloat((totalCurrentData.limit / 10 ** 6).toFixed(2));
			TempData.limitWCommas = helper.numberWithCommas(parseFloat(TempData.limit));

			TempData.currentEndingBalance = parseFloat(totalCurrentData.currentEndingBal);
			TempData.currentEndingBalanceMillionUnit = parseFloat((totalCurrentData.currentEndingBal / 10 ** 6).toFixed(2));
			TempData.currentEndingBalanceWCommas = helper.numberWithCommas(parseFloat(TempData.currentEndingBalance));
			
			TempData.lastYearEndingBal = parseFloat(totalLastYear.EndingBalance + totalLastYearDrawdown.EndingBalance);
			TempData.lastYearEndingBalMillionUnit = parseFloat(((totalLastYear.EndingBalance  + totalLastYearDrawdown.EndingBalance) / 10 ** 6).toFixed(2));
			TempData.lastYearEndingBalWCommas = helper.numberWithCommas(parseFloat(TempData.lastYearEndingBal));


			TempData.averageBalance = parseFloat(totalCurrentData.averageBalance.toFixed(2));
			TempData.averageBalanceMillionUnit = parseFloat((totalCurrentData.averageBalance / 10 ** 6).toFixed(2));
			TempData.averageBalanceWCommas = helper.numberWithCommas(parseFloat(TempData.averageBalance));

			TempData.lastMonthEndingBal = parseFloat((totalCurrentData.lastMonthEndingBal + totalDrawdownData.lastMonthEndingBal).toFixed(2));
			TempData.lastMonthEndingBalMillionUnit = parseFloat(((totalCurrentData.lastMonthEndingBal + totalDrawdownData.lastMonthEndingBal) / 10 ** 6).toFixed(2));
			TempData.lastMonthEndingBalWCommas = helper.numberWithCommas(parseFloat(TempData.lastMonthEndingBal));

			TempData.projectBal = parseFloat((totalCurrentData.projectedBalance + totalDrawdownData.projectedBalance).toFixed(2));
			TempData.projectBalMillionUnit = parseFloat(((totalCurrentData.projectedBalance + totalDrawdownData.projectedBalance) / 10 ** 6).toFixed(2));
			TempData.projectBalWCommas = helper.numberWithCommas(parseFloat(TempData.projectBal));

			TempData.repayment1 = parseFloat(((totalCurrentData.RepayWeek1 + totalDrawdownData.RepayWeek1) / 10 ** 6).toFixed(2));
			TempData.repayment2 = parseFloat(((totalCurrentData.RepayWeek2 + totalDrawdownData.RepayWeek2) / 10 ** 6).toFixed(2));
			TempData.repayment3 = parseFloat(((totalCurrentData.RepayWeek3 + totalDrawdownData.RepayWeek3) / 10 ** 6).toFixed(2));
			TempData.repayment4 = parseFloat(((totalCurrentData.RepayWeek4 + totalDrawdownData.RepayWeek4) / 10 ** 6).toFixed(2));
			TempData.repayment5 = parseFloat(((totalCurrentData.RepayWeek5 + totalDrawdownData.RepayWeek5) / 10 ** 6).toFixed(2));
			TempData.repayment6 = parseFloat(((totalCurrentData.RepayWeek6 + totalDrawdownData.RepayWeek6) / 10 ** 6).toFixed(2));

			TempData.repayment1WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek1 + totalDrawdownData.RepayWeek1));
			TempData.repayment2WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek2 + totalDrawdownData.RepayWeek2));
			TempData.repayment3WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek3 + totalDrawdownData.RepayWeek3));
			TempData.repayment4WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek4 + totalDrawdownData.RepayWeek4));
			TempData.repayment5WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek5 + totalDrawdownData.RepayWeek5));
			TempData.repayment6WCommas = helper.numberWithCommas(parseFloat(totalCurrentData.RepayWeek6 + totalDrawdownData.RepayWeek6));
			
			TempData.drawdown1 = parseFloat((totalDrawdownData.drawdownWeek1 / 10 ** 6).toFixed(2));
			TempData.drawdown2 = parseFloat((totalDrawdownData.drawdownWeek2 / 10 ** 6).toFixed(2));
			TempData.drawdown3 = parseFloat((totalDrawdownData.drawdownWeek3 / 10 ** 6).toFixed(2));
			TempData.drawdown4 = parseFloat((totalDrawdownData.drawdownWeek4 / 10 ** 6).toFixed(2));
			TempData.drawdown5 = parseFloat((totalDrawdownData.drawdownWeek5 / 10 ** 6).toFixed(2));
			TempData.drawdown6 = parseFloat((totalDrawdownData.drawdownWeek6 / 10 ** 6).toFixed(2));

			TempData.drawdown1WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek1));
			TempData.drawdown2WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek2));
			TempData.drawdown3WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek3));
			TempData.drawdown4WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek4));
			TempData.drawdown5WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek5));
			TempData.drawdown6WCommas = helper.numberWithCommas(parseFloat(totalDrawdownData.drawdownWeek6));

			TempData.lastUpdatedBy = totalCurrentData.lastUpdatedDate ? totalDrawdownData.lastUpdatedDate ? new Date(totalCurrentData.lastUpdatedDate) > new Date(totalDrawdownData.lastUpdatedDate) ? totalCurrentData.lastUpdatedBy : totalDrawdownData.lastUpdatedBy : totalCurrentData.lastUpdatedBy : totalDrawdownData.lastUpdatedDate ?  totalDrawdownData.lastUpdatedBy : '';
			TempData.lastUpdatedDate = totalCurrentData.lastUpdatedDate ? totalDrawdownData.lastUpdatedDate ? new Date(totalCurrentData.lastUpdatedDate) > new Date(totalDrawdownData.lastUpdatedDate) ? new Date(totalCurrentData.lastUpdatedDate) : new Date(totalDrawdownData.lastUpdatedDate) : new Date(totalCurrentData.lastUpdatedDate) : totalDrawdownData.lastUpdatedDate ?  new Date(totalDrawdownData.lastUpdatedDate) : '';

			component.set('v.DummyRecData', TempData);
			component.set('v.TempRecData', helper.parseObj(TempData));

			if(component.get('v.showAdjustedItem') && TempData.lastUpdatedBy != '' && TempData.lastUpdatedDate != ''){
				component.set('v.isShowRec', true);
			}else if(!component.get('v.showAdjustedItem')){
				component.set('v.isShowRec', true);
			}else{
				var p = component.get("v.parent");
				p.checkIsShow();
			}
		}
	},

	saveSingleRecord: function (component, event, helper) {
		var groupData = component.get('v.groupData');
		var dumrecData = component.get('v.DummyRecData');
		var TempRecData = component.get('v.TempRecData');
		var target = component.find('isDaft');
		var diffRepayrray = [
			(dumrecData.repayment1 - TempRecData.repayment1) * 10 ** 6,
			(dumrecData.repayment2 - TempRecData.repayment2) * 10 ** 6,
			(dumrecData.repayment3 - TempRecData.repayment3) * 10 ** 6,
			(dumrecData.repayment4 - TempRecData.repayment4) * 10 ** 6,
			(dumrecData.repayment5 - TempRecData.repayment5) * 10 ** 6,
			(dumrecData.repayment6 - TempRecData.repayment6) * 10 ** 6,
		];
		var totalTempRepay = 0;
		var totalDumDrawdown = 0;
		for(var i = 1 ;i <= 6 ; i++){
			if(dumrecData['repayment' + i] < 0 || dumrecData['drawdown' + i] < 0){
				if(dumrecData['repayment' + i] < 0){
					if(component.get('v.selectedPrdDomain') == 'Credit'){
						helper.displayToast('error', $A.get("$Label.c.Repayment_must_be_greater_than_zero"));
						$A.util.addClass(target, 'slds-cell-edit slds-has-error');
					}else{
						helper.displayToast('error', $A.get("$Label.c.Due_amount_must_be_greater_than_zero"));
						$A.util.addClass(target, 'slds-cell-edit slds-has-error');
					}
                    component.set('v.isLoading',false);
				}
				if (dumrecData['drawdown' + i] < 0) {
					if(component.get('v.selectedPrdDomain') == 'Credit'){
						helper.displayToast('error', $A.get("$Label.c.Drawdown_must_be_greater_than_zero"));
						$A.util.addClass(target, 'slds-cell-edit slds-has-error');
					}else{
						helper.displayToast('error', $A.get("$Label.c.Rollover_must_be_greater_than_zero"));
						$A.util.addClass(target, 'slds-cell-edit slds-has-error');
					}
                    component.set('v.isLoading',false);
				}
				return false;
			}
			totalTempRepay += TempRecData['repayment' + i] * 10 ** 6;
			totalDumDrawdown += dumrecData['drawdown' + i] * 10 ** 6;
		}
		var isAdjustedDrawdown = !(dumrecData.drawdown1 === TempRecData.drawdown1 && dumrecData.drawdown2 === TempRecData.drawdown2 && dumrecData.drawdown3 === TempRecData.drawdown3 && dumrecData.drawdown4 === TempRecData.drawdown4 && dumrecData.drawdown5 === TempRecData.drawdown5 && dumrecData.drawdown6 === TempRecData.drawdown6);

		var diffDrawDownArr = [
			dumrecData.drawdown1 - TempRecData.drawdown1,
			dumrecData.drawdown2 - TempRecData.drawdown2,
			dumrecData.drawdown3 - TempRecData.drawdown3,
			dumrecData.drawdown4 - TempRecData.drawdown4,
			dumrecData.drawdown5 - TempRecData.drawdown5,
			dumrecData.drawdown6 - TempRecData.drawdown6,
		];
		
		var actionSaveDrawdown = component.get('c.SaveDrawdown');
		var actionSaveRepay = component.get('c.SaveExistingRepayment');
		var period = component.get('v.period');
		var month = parseInt(groupData.Month__c) - 1;
		var year = parseInt(groupData.Year__c);
		var today = new Date();
		var isSave = true;
		var currentData = component.get('v.currentData');
		var drawDownData = component.get('v.drawDownData');
		var totalDiffRepay = diffRepayrray.reduce((each, res) => {
			return res += each;
		}, 0);
		var totalDiffDrawdown = diffDrawDownArr.reduce((each, res) => {
			return res += each;
		}, 0);
		var totalOriginDrawdown  = diffDrawDownArr.reduce((each, res) => {
			return res += each.Total_Drawdown_Rollover__c;
		}, 0);
        var totalOrinaiRepayOnDrawdown  = diffDrawDownArr.reduce((each, res) => {
			return res += each.Total_Repay_Due_Amount__c;
		}, 0);
        if(totalOriginDrawdown - totalOrinaiRepayOnDrawdown + (totalDiffDrawdown*(10**6)) < 0){
            totalDiffRepay += ((totalOrinaiRepayOnDrawdown - totalOriginDrawdown)/(10**6)) - totalDiffDrawdown;
            var toltalChangeEnding = totalOrinaiRepayOnDrawdown - totalOriginDrawdown - (totalDiffDrawdown*(10**6));
            drawDownData.foreach( DDData => {
                var recordChangedEnding ;
                if(DDData.Ending_Balance__c > toltalChangeEnding){
                	
                 	DDData.Ending_Balance__c -= toltalChangeEnding;
					recordChangedEnding = toltalChangeEnding;
                	toltalChangeEnding = 0;
            	}else{
                    toltalChangeEnding -= DDData.Ending_Balance__c;
                    recordChangedEnding = DDData.Ending_Balance__c;
                    DDData.Ending_Balance__c =0;
             	}
                for(var i=0 ;i<=6;i++){
                if(recordChangedEnding > DDData["Repay_Due_Amount_Week"+i+"__c"]){
                    recordChangedEnding -= DDData["Repay_Due_Amount_Week"+i+"__c"];
                	DDData["Repay_Due_Amount_Week"+i+"__c"] = 0;
                 }else{
                   	DDData["Repay_Due_Amount_Week"+i+"__c"] -= toltalChangeEnding;
                    toltalChangeEnding = 0;
                 }
                       
            	}
        	},drawDownData);
        }
		for(var i = 0 ; i < Object.keys(currentData).length ; i++){
			currentData[i]['totalDrumRepay'] = currentData[i].Total_Repay_Due_Amount__c ? currentData[i].Total_Repay_Due_Amount__c : 0;
		}
		for(var i = 0 ; i < Object.keys(drawDownData).length ; i++){
			drawDownData[i]['totalDrumRepay'] = drawDownData[i].Total_Repay_Due_Amount__c ? drawDownData[i].Total_Repay_Due_Amount__c : 0;
		}
		var checkOverBal = false;
		//if(TempRecData.lastMonthEndingBal + totalDumDrawdown >= totalDiffRepay + totalTempRepay){
		//	var checkOverBal = true;
		//}
		if(TempRecData.lastMonthEndingBal + totalDumDrawdown >= totalDiffRepay + totalTempRepay){
				for (var i = 0; i < period.length; i++) {
					var fisrtDateOfWeek = period[i][0] ? new Date(year,month,period[i][0]) : null;
					if (diffRepayrray[i] > 0) {
						currentData = currentData.sort(function (a, b) {
							return (a.Maturity_Date__c > b.Maturity_Date__c) ? 1 : ((b.Maturity_Date__c > a.Maturity_Date__c) ? -1 : 0);
						});

						currentData.forEach(data => {
							var maturityDate = new Date(data.Maturity_Date__c);
							maturityDate.setHours(24);
							var tempBalance = data.Last_Month_Ending_Balance__c;
							var tempRepay = 0;
							// if(maturityDate > today){
								tempRepay = data['Repay_Due_Amount_Week' + (i+1) + '__c'] ? data['Repay_Due_Amount_Week' + (i + 1) + '__c'] : 0;
							// }
							if ((data.Maturity_Date__c == null) && totalDiffRepay != 0) {
								helper.displayToast('error', '$Label.c.Empty_Maturity_Date');
								$A.util.addClass(target, 'slds-cell-edit slds-has-error');
								isSave = false
                            	component.set('v.isLoading',false);
								return ;
							}
							if(/*(maturityDate > fisrtDateOfWeek) && */ tempBalance > data.totalDrumRepay + tempRepay){
								tempBalance -= data.totalDrumRepay;
								if(tempBalance >= diffRepayrray[i] + tempRepay){
									tempBalance -= diffRepayrray[i];
									tempRepay += diffRepayrray[i] ;
									totalDiffRepay -= diffRepayrray[i];
									diffRepayrray[i] = 0;
								}else {
									diffRepayrray[i] = diffRepayrray[i] + tempRepay - tempBalance ;
									tempRepay += tempBalance;
									totalDiffRepay -= tempBalance
									tempBalance = 0;
								}
							}else{
								tempRepay = null;
							}
							data['Repay_Due_Amount_Week' + (i+1) + '__c'] = tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
							data.totalDrumRepay += tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
						
                    	}, currentData);

						drawDownData.forEach(data => {
							var tempBalance = data.Ending_Balance__c;
							var tempRepay = 0;
							// if(maturityDate > today){
								tempRepay = data['Repay_Due_Amount_Week' + (i+1) + '__c'] ? data['Repay_Due_Amount_Week' + (i + 1) + '__c'] : 0;
							// }
							if(tempBalance > data.totalDrumRepay + tempRepay){
								tempBalance -= data.totalDrumRepay;
								if(tempBalance >= diffRepayrray[i] + tempRepay){
									tempBalance -= diffRepayrray[i];
									tempRepay += diffRepayrray[i] ;
									totalDiffRepay -= diffRepayrray[i];
									diffRepayrray[i] = 0;
								}else {
									diffRepayrray[i] = diffRepayrray[i] + tempRepay - tempBalance ;
									tempRepay += tempBalance;
									totalDiffRepay -= tempBalance
									tempBalance = 0;
								}
							}else{
								tempRepay = null;
							}
							data['Repay_Due_Amount_Week' + (i+1) + '__c'] = tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
							data.totalDrumRepay += tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
						
                	}, drawDownData);


					}else if (diffRepayrray[i] < 0) {
						drawDownData.forEach(data => {	
							var tempRepay;
							tempRepay = data['Repay_Due_Amount_Week' + (i+1) + '__c'] ? data['Repay_Due_Amount_Week' + (i + 1) + '__c'] : 0;
		
								if (tempRepay + diffRepayrray[i] < 0 ) {
									diffRepayrray[i] += tempRepay;
									totalDiffRepay -= tempRepay;
									tempRepay = 0;
								}else{
									tempRepay += diffRepayrray[i];
									totalDiffRepay -= diffRepayrray[i];
									diffRepayrray[i] = 0;
								}
							data['Repay_Due_Amount_Week' + (i+1) + '__c'] = tempRepay != null ? tempRepay : data['Repay_Due_Amount_Week' + (i + 1) + '__c'];
							data.totalDrumRepay += tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
						},drawDownData);

						currentData = currentData.sort(function (a, b) {
							return (a.Maturity_Date__c < b.Maturity_Date__c) ? 1 : ((b.Maturity_Date__c < a.Maturity_Date__c) ? -1 : 0);
						});
						currentData.forEach(data => {
							
							var maturityDate = new Date(data.Maturity_Date__c);
							maturityDate.setHours(24);		
							
							if ((data.Maturity_Date__c == null) && totalDiffRepay != 0) {
								helper.displayToast('error', '$Label.c.Empty_Maturity_Date');
								$A.util.addClass(target, 'slds-cell-edit slds-has-error');
								isSave = false
                            	component.set('v.isLoading',false);
								return ;
							}
							var tempRepay;
							//if(maturityDate > today){
								tempRepay = data['Repay_Due_Amount_Week' + (i+1) + '__c'] ? data['Repay_Due_Amount_Week' + (i + 1) + '__c'] : 0;
							//}						

							// if((maturityDate > fisrtDateOfWeek)){
								if (tempRepay + diffRepayrray[i] < 0 ) {
									diffRepayrray[i] += tempRepay;
									totalDiffRepay -= tempRepay;
									tempRepay = 0;
								}else{
									tempRepay += diffRepayrray[i];
									totalDiffRepay -= diffRepayrray[i];
									diffRepayrray[i] = 0;
								}
							// }else{
							// 	tempRepay = null;
							// }
							data['Repay_Due_Amount_Week' + (i+1) + '__c'] = tempRepay != null ? tempRepay : data['Repay_Due_Amount_Week' + (i + 1) + '__c'];
							data.totalDrumRepay += tempRepay ? tempRepay : data['Repay_Due_Amount_Week' + (i+1) + '__c'] ;
						},currentData);
						
					}
				}
				for(var i = 0 ; i < Object.keys(currentData).length ; i++){
					delete currentData[i].totalDrumRepay;
				}
				for(var i = 0 ; i < Object.keys(drawDownData).length ; i++){
					delete drawDownData[i].totalDrumRepay;
				}
				
				if(isSave) $A.enqueueAction(actionSaveRepay);
		}else{
			if(component.get('v.selectedPrdDomain') == 'Credit'){
				helper.displayToast('error', $A.get("$Label.c.Repayment_cannot_be_greater"));
				$A.util.addClass(target, 'slds-cell-edit slds-has-error');
			}else{
				helper.displayToast('error', $A.get("$Label.c.Due_amount_cannot_be_greater"));
				$A.util.addClass(target, 'slds-cell-edit slds-has-error');
			}
            
             component.set('v.isLoading',false);
		}

		actionSaveRepay.setParams({
			'MFIList': Object.values(currentData).concat(Object.values(drawDownData)) ? Object.values(currentData).concat(Object.values(drawDownData)) : null,
			'month': groupData.Month__c,
			'year': groupData.Year__c,
		});

		actionSaveDrawdown.setParams({
			'acctId': groupData.Customer__c ? groupData.Customer__c : null,
			'productType': groupData.Product_Type__c ? groupData.Product_Type__c : null,
			'product': groupData.Product__c ? groupData.Product__c : null,
			'month': groupData.Month__c ? groupData.Month__c : null,
			'year': groupData.Year__c ? groupData.Year__c : null,
			'drawDownW1': dumrecData.drawdown1 === TempRecData.drawdown1 ? null : (dumrecData.drawdown1 * 10 ** 6),
			'drawDownW2': dumrecData.drawdown2 === TempRecData.drawdown2 ? null : (dumrecData.drawdown2 * 10 ** 6),
			'drawDownW3': dumrecData.drawdown3 === TempRecData.drawdown3 ? null : (dumrecData.drawdown3 * 10 ** 6),
			'drawDownW4': dumrecData.drawdown4 === TempRecData.drawdown4 ? null : (dumrecData.drawdown4 * 10 ** 6),
			'drawDownW5': dumrecData.drawdown5 === TempRecData.drawdown5 ? null : (dumrecData.drawdown5 * 10 ** 6),
			'drawDownW6': dumrecData.drawdown6 === TempRecData.drawdown6 ? null : (dumrecData.drawdown6 * 10 ** 6),
		});

		actionSaveDrawdown.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS' && component.isValid()) {
				helper.displayToast('Success', 'Save Successes.');
				var p = component.get('v.parent');
    			p.refreshData();
			}
		});

		actionSaveRepay.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS' && component.isValid()) {
				$A.enqueueAction(actionSaveDrawdown);
			}
		});
	},

	displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
	
	numberWithCommas : function (x) {
		if(x == null) return ''
		var parts = x.toString().split(".");
		parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		parts[1] = (parts[1] == '' || parts[1] == null) ? '00': parts[1];
		return parts.join(".");
	},
})