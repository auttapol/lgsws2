({
    getPerformanceData : function(component, event, helper) {
        component.set('v.loading',true);
        component.set('v.sectionCLoading',true);
        component.set('v.sectionDLoading',true);
        var empId = component.get('v.selectedEmpId');
        var year = component.get('v.selectedYear');
        var month = component.get('v.selectedMonth');
        var period = component.get('v.selectedPeriod');
        var action = component.get('c.getPerformanceDataP1');
        action.setParams({
            // "branchCode" : branchCode
            "empId" : empId,
            "period" : period,
            "year" : year,
            "monthNo" : this.getMonthNo(month)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.loading',false);
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                result.saleInfo.Sale_Hire_Date__c = helper.formatDate(result.saleInfo.Sale_Hire_Date__c);
                component.set('v.saleInfo',result.saleInfo);
                component.set('v.salePerfObj',result.salePerformance);
                component.set('v.financePerf',result.financePerformance);
                component.set('v.appIncentive',result.appIncentive);
                component.set('v.sumFiActPoint',result.sumFiActPoint);
                component.set('v.sumFiTargPoint',result.sumFiTargPoint);
                component.set('v.licenseObj',result.licenses);
                component.set('v.dataAsOfMonth',result.asOfMonth);
                component.set('v.dataAsOfYear',result.asOfYear);

                helper.getSumProductObj(component, helper);
                if(!result.isCalBankwide) {
                    helper.calAvgBankwide(component, helper, result.sumBWTransQueryCond, result.sumBWPerfQueryCond, result.totalTransTargetBW, result.saleResignedMonth, result.saleResignedYear);
                } else {
                    component.set('v.sectionCLoading',false);
                }

                if(!component.get('v.helpLink')) {
                    helper.getSharePointLink(component);
                }
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                if(message == 'ไม่พบข้อมูล User ใน Sale Info') {
                    component.set('v.notifyError',message);
                } else {
                    helper.showToastError('Get performance data P1 failed, Message: '+message);
                }
                component.set('v.loading', false)
                component.set('v.sectionCLoading',false);
                component.set('v.sectionDLoading',false);
            }  
        });
        
        $A.enqueueAction(action);       
    },

    getMonthNo : function(short_month) {
        var monthLst = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        ];
        return monthLst.indexOf(short_month)+1;
    },

    setFocusedTabLabel : function(component, event, helper) {
        var empId = component.get('v.selectedEmpId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "P.1 ("+empId+")"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom48",
                iconAlt: "Approval"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('error: ', response.error);
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get watermark HTML, Message: '+message);
                component.set('v.loading', false)
                component.set('v.sectionCLoading',false);
                component.set('v.sectionDLoading',false);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get watermark HTML, Message: '+message);
                component.set('v.loading', false)
                component.set('v.sectionCLoading',false);
                component.set('v.sectionDLoading',false);
            }
		});
		$A.enqueueAction(action);
	},

    formatDate : function(date) {
        let retDate = date;
        if(date) {
            let dateArr = date.split("-");
            // let retDate = '';
            if(dateArr.length > 2) {
                retDate = dateArr[2]+'/'+dateArr[1]+'/'+dateArr[0];
            }
        }
        return retDate;
    },
    
    getLastAvailDataTime : function(component, event, helper) {
        return new Promise(function(resolve, reject) {
            var empId = component.get('v.selectedEmpId');
            // var year = component.get('v.selectedYear');
            var action = component.get('c.getLastAvailData');
            action.setParams({
                // "branchCode" : branchCode
                "empId" : empId,
                // "selectedYear" : year,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {               
                    var result =  response.getReturnValue();   
                    component.set('v.lastAvailDataTimeObj',result);
                    resolve(result)
                }   
                else{
                    component.set('v.loading', false)
                    component.set('v.sectionCLoading',false);
                    component.set('v.sectionDLoading',false);
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    // component.set('v.loaded', false)
                    if(message == 'ไม่พบข้อมูล User ใน Sale Info') {
                        component.set('v.notifyError',message);
                    } else {
                        helper.showToastError('Get last avail data, Message: '+message);
                    }

                    reject(message);
                }  
            });
            
            $A.enqueueAction(action);    
        });   
    },

    getSharePointLink : function(component){
        var action = component.get('c.getSharePointLink');// get function at apex
        var saleInfo  = component.get('v.saleInfo');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                if(result) {
                    result.forEach(obj => {
                        if(obj.SharePoint_Type__c == 'Help') {
                            component.set('v.helpLink',obj.URL_Link__c);
                        } else {
                            component.set('v.summaryLink',obj.URL_Link__c.replaceAll('$branchcode;',saleInfo.Branch_Code__c));
                        }
                    });
                }
                /* component.set('v.loaded', false); */
            }   
            else{
                component.set('v.loading', false)
                component.set('v.sectionCLoading',false);
                component.set('v.sectionDLoading',false);
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get sharepoint failed, Message: '+message);
            }  
        });
        $A.enqueueAction(action);
    },

        getTargetProductTable : function (component, event, helper){
            var action = component.get('c.getTargetProductTable');// get function at apex
            var empId = component.get('v.selectedEmpId');
            var selectedYear = component.get('v.selectedYear');
            var selectedPeriod = component.get('v.selectedPeriod');
            if (selectedYear == null) {
                var date = new Date();
                selectedYear = date.getFullYear();
            }
            var selectedMonth =  (this.getMonthNo(component.get('v.selectedMonth'))).toString().padStart(2,'0');
            if (selectedMonth == "00" || selectedPeriod == 'year'){
                selectedMonth = null;
            }

            action.setParams({
                "EmployeeId" : empId,
                "year" : selectedYear,
                "month" : selectedMonth
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {               
                    var result =  response.getReturnValue();
                    if (result.productList.length > 0){
                        var grandTotalRecord =  {'totalFinance': "Grand Total" , 'achivement': parseFloat(result.grandTotal).toFixed(2) + '%'};
                        result.productList.forEach(element => {
                            element.achivement = element.achivement == null || element.achivement == undefined ? '' : parseFloat(element.achivement).toFixed(2) + '%';
                            element.successUnit = parseFloat(element.successUnit).toFixed(2) + '%';
                            if(element.weightKPIs != null) {
                                element.weightKPIs = parseFloat(element.weightKPIs).toFixed(2) + '%';
                            }
                            element.targetUnit = helper.floatWithComma(element.targetUnit);
                            element.actualUnit = helper.floatWithComma(element.actualUnit);
                            var subGroupLevel = 0;
                            if(element.subGroupFlag) {
                                subGroupLevel = 1;
                            }
                            
                            element.subGroupLevelClass = 'subGroupLevel' + subGroupLevel;
                        });
                        result.productList.push(grandTotalRecord);
                    }
                    component.set('v.targetProductObj',result);
                }   
                else{
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastError('Get target product failed, Message: '+message);
                    // Display the message
                    component.set('v.loading', false)
                    component.set('v.sectionCLoading',false);
                    component.set('v.sectionDLoading',false);
                    /* reject(message); */
                    
                }  
            });
            
            $A.enqueueAction(action);    
        },

        showToastError : function(msg) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error",
                "message": msg
            });
            toastEvent.fire();
        },

        calAvgBankwide : function(component, helper, saleTransQueryCond, salePerfQueryCond, targetSaleTrans) {
            component.set('v.sectionCLoading',true);
            helper.getSumSaleTransBW(component, helper, saleTransQueryCond).then((sumSaleTransBW) => {
                helper.getSumSalePerfBW(component, helper, salePerfQueryCond).then((sumSalePerfBWObj) => {
                    targetSaleTrans = !targetSaleTrans ? 0 : parseFloat(targetSaleTrans);
                    sumSalePerfBWObj.target = !sumSalePerfBWObj.target ? 0 : sumSalePerfBWObj.target;
                    var sumTarget = targetSaleTrans + sumSalePerfBWObj.target;
                    var currFinancePerf = component.get('v.financePerf');
                    if(sumTarget) {
                        sumSaleTransBW = !sumSaleTransBW ? 0 : sumSaleTransBW;
                        sumSalePerfBWObj.point = !sumSalePerfBWObj.point ? 0 : sumSalePerfBWObj.point;
                        var sumPoint = sumSaleTransBW + sumSalePerfBWObj.point;
                        if(sumPoint > 0) {
                            currFinancePerf.avgBankWide = (sumPoint/sumTarget)*100;
                            component.set('v.financePerf',currFinancePerf);
                        }
                    }
                    component.set('v.sectionCLoading',false);
                }).catch(() => {
                    component.set('v.sectionCLoading',false);
                })
            }).catch(() => {
                component.set('v.sectionCLoading',false);
            })
        },

        getSumSaleTransBW : function(component, helper, saleTransQueryCond) {
            return new Promise(function (resolve, reject) {
                if(saleTransQueryCond == null) {
                    // no sale transaction
                    resolve(0);
                } else {
                var saleTransChunkQueryWrapper = {
                    "chunkSize": 35000,
                    "lastRecordId": null,
                    "isEndRecord": null,
                    "fieldList": "Id, Actual_Point__c",
                    "queryObject": "Sale_Transaction__c",
                    "condition": saleTransQueryCond,
                    "resultRecords": []
                }

                helper.chunkQuery(component,helper,saleTransChunkQueryWrapper, []).then((resultRecords) => {
                    var sumPoint = 0;
                    resultRecords.forEach(records => {
                        if(records.Actual_Point__c) {
                            sumPoint += records.Actual_Point__c; 
                         }
                    });
                    resolve(sumPoint);
                }).catch((error) => {
                    reject(error);
                });
                }
            });
        },

        getSumSalePerfBW : function(component, helper, salePerfQueryCond) {
            return new Promise(function (resolve, reject) {
                var sumPerfObj = { point: 0, target: 0 };
                if(salePerfQueryCond == null) {
                    // no sale perf
                    resolve(sumPerfObj);
                } else {
                    var saleTransChunkQueryWrapper = {
                        "chunkSize": 35000,
                        "lastRecordId": null,
                        "isEndRecord": null,
                        "fieldList": " Id, Financial_Actual_Point__c, Target_Point__c  ",
                        "queryObject": "Sale_Performance__c",
                        "condition": salePerfQueryCond,
                        "resultRecords": []
                    }
    
                    helper.chunkQuery(component,helper,saleTransChunkQueryWrapper, []).then((resultRecords) => {
                        resultRecords.forEach(records => {
                            if(records.Financial_Actual_Point__c) {
                                sumPerfObj.point += records.Financial_Actual_Point__c;
                            }
                            
                            if(records.Target_Point__c) {
                                sumPerfObj.target += records.Target_Point__c;
                            }
                        });
                        resolve(sumPerfObj);
                    }).catch((error) => {
                        reject(error);
                    });
                }
            });
        },

        getSumProductObj : function(component, helper) {
            return new Promise(function (resolve, reject) {
                component.set('v.sectionDLoading',true);
                var empId = component.get('v.selectedEmpId');
                var year = component.get('v.selectedYear');
                var month = component.get('v.selectedMonth');
                var period = component.get('v.selectedPeriod');

                var fieldList = ' Indicator_Name__c, Indicator_Level1__c, Indicator_Level2__c,Actual_Performance__c, Actual_Point__c, Sale_Unit__c,Deduct_Flag__c,Deduct_Date__c,KPI_Date__c,Deduct_Point__c, Employee_ID__c,Indicator_Code_Level1__c,Indicator_Code_Level2__c,Indicator_Code__c ';
                
                var condition = '';
                if(period == 'month') {
                    condition = ' WHERE Employee_ID__c = \''+empId+'\' AND Year__c = \''+year+'\' AND Month__c = \''+helper.getMonthNo(month).toString().padStart(2, '0')+'\'';
                } else {
                    condition = ' WHERE Employee_ID__c = \''+empId+'\' AND Year__c = \''+year+'\' ';
                }

                var productChunkQueryWrapper = {
                    "chunkSize": 35000,
                    "lastRecordId": null,
                    "isEndRecord": null,
                    "fieldList": fieldList,
                    "queryObject": "Sale_Transaction__c",
                    "condition": condition,
                    "resultRecords": []
                }

                helper.chunkQuery(component, helper, productChunkQueryWrapper, []).then((productList) => {

                    productList.sort((a,b) => (a.Indicator_Code_Level1__c+a.Indicator_Code_Level2__c+a.Indicator_Code__c) - (b.Indicator_Code_Level1__c+b.Indicator_Code_Level2__c+b.Indicator_Code__c));
                    
                    var sumProductObj = [];
                    productList.forEach(product => {

                        if(product.Deduct_Point__c == null) {
                            product.Deduct_Point__c = 0;
                        }
            
                        if(product.Actual_Performance__c == null) {
                            product.Actual_Performance__c = 0;
                        }

                        var subObj1Idx = sumProductObj.findIndex(e => e.Name === product.Indicator_Level1__c);
                        if(subObj1Idx > -1) {
                            // existing lv1
                            if(product.Actual_Point__c != null) {
                                sumProductObj[subObj1Idx].SumActualPoint += product.Actual_Point__c;
                            }

                            if(product.Deduct_Point__c != null) {
                                sumProductObj[subObj1Idx].SumDeductPoint += product.Deduct_Point__c;
                            }

                            if(product.Actual_Performance__c != null) {
                                sumProductObj[subObj1Idx].ActualPerformance += product.Actual_Performance__c;
                            }
                            var sumActual = sumProductObj[subObj1Idx].SumActualPoint;
                            var sumDeduct = sumProductObj[subObj1Idx].SumDeductPoint;
                            // var sumPerf = sumProductObj[subObj1Idx].Actual_Performance__c

                            if(sumActual != null && sumDeduct != null) {
                                sumProductObj[subObj1Idx].NetPoint = sumActual - sumDeduct;
                            }
                            

                        } else {
                            // new lv1
                            var subObj = {
                                Data: [],
                                Name: product.Indicator_Level1__c,
                                ActualPerformance: product.Actual_Performance__c,
                                SumActualPoint: product.Actual_Point__c,
                                SumDeductPoint: product.Deduct_Point__c,
                                NetPoint: product.Actual_Point__c - product.Deduct_Point__c,
                            }
                            sumProductObj.push(subObj);
                            subObj1Idx = sumProductObj.length-1;
                        }

                        var subObj2Idx = sumProductObj[subObj1Idx].Data.findIndex(e => e.Name === product.Indicator_Level2__c);
                        if(subObj2Idx > -1) {
                            // existing lv2
                            if(product.Actual_Point__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].SumActualPoint += product.Actual_Point__c;
                            }

                            if(product.Deduct_Point__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].SumDeductPoint += product.Deduct_Point__c;
                            }

                            if(product.Actual_Performance__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].ActualPerformance += product.Actual_Performance__c;
                            }
                            var sumActual = sumProductObj[subObj1Idx].Data[subObj2Idx].SumActualPoint;
                            var sumDeduct = sumProductObj[subObj1Idx].Data[subObj2Idx].SumDeductPoint;

                            if(sumActual != null && sumDeduct != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].NetPoint = sumActual - sumDeduct;
                            }

                        } else {
                            // new lv2
                            var subObj = {
                                Data: [],
                                Name: product.Indicator_Level2__c,
                                ActualPerformance: product.Actual_Performance__c,
                                SumActualPoint: product.Actual_Point__c,
                                SumDeductPoint: product.Deduct_Point__c,
                                NetPoint: product.Actual_Point__c - product.Deduct_Point__c,
                            }
                            sumProductObj[subObj1Idx].Data.push(subObj);
                            subObj2Idx = sumProductObj[subObj1Idx].Data.length-1;
                        }

                        var subObjProductIdx = sumProductObj[subObj1Idx].Data[subObj2Idx].Data.findIndex(e => e.Indicator_Name__c === product.Indicator_Name__c);
                        if(subObjProductIdx > -1) {
                            // existing lv product
                            if(product.Actual_Point__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].Actual_Point__c += product.Actual_Point__c;
                            }

                            if(product.Deduct_Point__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].Deduct_Point__c += product.Deduct_Point__c;
                            }

                            if(product.Actual_Performance__c != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].Actual_Performance__c += product.Actual_Performance__c;
                            }

                            var sumActual = sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].Actual_Point__c;
                            var sumDeduct = sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].Deduct_Point__c;

                            if(sumActual != null && sumDeduct != null) {
                                sumProductObj[subObj1Idx].Data[subObj2Idx].Data[subObjProductIdx].NetPoint = sumActual - sumDeduct;
                            }

                        } else {
                            // new lv product
                            sumProductObj[subObj1Idx].Data[subObj2Idx].Data.push(product); 
                        }
                        
                    })
                    component.set('v.sumProductObj',sumProductObj)
                    component.set('v.sectionDLoading',false);
                    resolve(sumProductObj);
                }).catch((error) => {
                    component.set('v.sectionDLoading',false);
                    helper.showToastError('Get summary product failed, Message: '+error);
                    reject(error);
                })
            })
        },

        chunkQuery : function(component, helper, chunkQueryWrapper, recordsStack) {
            return new Promise(function (reslove, reject) {
                if(recordsStack == null) {
                    recordsStack = [];
                }
                var action = component.get('c.chunkQuery');// get function at apex
                action.setParams({
                    "queryWrapperObj": chunkQueryWrapper
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    // component.set('v.loading',false);
                    if (state === "SUCCESS") {               
                        var result =  response.getReturnValue();
                        if(result.resultRecords.length > 0 && recordsStack != null) {
                            recordsStack = recordsStack.concat(result.resultRecords);
                        }
                        if(!result.isEndRecord) {
                            result.resultRecords = []; //reset result
                            reslove(helper.chunkQuery(component,helper,result,recordsStack));
                        } else {
                            reslove(recordsStack);
                        }
                    }   
                    else{
                        var errors = response.getError();
                        var message = 'Unknown error'; // Default error message
                        // Retrieve the error message sent by the server
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            message = errors[0].message;
                        }
                        helper.showToastError('Chunk query performance failed, Message: '+message);
                        // Display the message
                        component.set('v.loading', false)
                        component.set('v.sectionCLoading',false);
                        component.set('v.sectionDLoading',false);
                        reject(message);
                        /* reject(message); */
                        
                    }  
                });
                
                $A.enqueueAction(action);    
            });
        },

        floatWithComma : function(num) {
            if(num != null && num != undefined) {
                var floatStr = parseFloat(num).toFixed(2);
                var floatStrArr = floatStr.split(".");
                var intWithComma = (+floatStrArr[0]).toLocaleString();
                return intWithComma+'.'+floatStrArr[1];
            }
            return null;
        }
})