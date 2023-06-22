({
    getPerformanceData : function(component, event, helper) {
        component.set('v.loading',true);
        var selectedMonth = component.get('v.selectedMonth');
        var selectedYear = component.get('v.selectedYear');
        var empId = component.get('v.selectedEmpId');
        var startRow = component.get("v.start");
        var endRow = component.get("v.end");
        var action = component.get('c.getPerformanceDataP2');
        // var selectedPerfKey = component.get('v.selectedPerfKey');
        // var selectedPerfValue = component.get('v.selectedPerfValue');
        // startRow = 0;
        // endRow = 10;
        // empId = '82827';
        action.setParams({
            "empId" : empId,
            "startRow" : startRow,
            "endRow" : endRow,
            // "keyTypeFilter" : selectedPerfKey,
            // "keyValueFilter" : selectedPerfValue,
            "selectedMonth" : selectedMonth,
            "selectedYear" : selectedYear
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.loading',false);
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                result.saleInfo.Sale_Hire_Date_Display = helper.formatDate(result.saleInfo.Sale_Hire_Date__c);
                // result.saleInfo.Sale_Hire_Date__c = helper.formatDate(result.saleInfo.Sale_Hire_Date__c);
                component.set('v.saleInfo',result.saleInfo);
                // if(result.salesTransaction)
                // {
                //     result.salesTransaction.forEach((dat) => {
                //         dat.KPI_Date__c = helper.formatDate(dat.KPI_Date__c);
                //         dat.Deduct_Date__c = helper.formatDate(dat.Deduct_Date__c);
                //         // dat.Reference_Number2__c = helper.formatDate(dat.Reference_Number2__c);
                //     })
                // }
                // // component.set('v.saleTranList',result.salesTransaction);
                // var saleTransData = this.transformSaleTrans(result.salesTransaction);
                // component.set('v.saleTransData',saleTransData);
                

                component.set('v.appIncentive',result.appIncentive);
                // component.set('v.totalSize',saleTransData.length);
                // // component.set('v.totalSize',result.totalTransRow);
                component.set('v.licenseObj',result.licenses);
                // var newStart = component.get("v.start");
                // var newEnd = component.get("v.end");
                // var newList = saleTransData.slice(newStart-1,newEnd);
                // component.set('v.saleTranList',newList);


                helper.getSharePointLink(component);
                // helper.prepareBranchPerformanceData(component, event, helper, result);
                // helper.prepareBranchProfileData(component, event, helper, result);
                // helper.prepareIndividualPerformanceData(component, event, helper, result);
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError2('Get Performance Failed, Message:'+message);
                component.set('v.loading', false);
            }  
        });
        
        $A.enqueueAction(action);       
    },

    setFocusedTabLabel : function(component, event, helper) {
        var empId = component.get('v.selectedEmpId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "P.2 ("+empId+")"
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
                // console.log('watermarkHTML: ', watermarkHTML);

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\'data:image/svg+xml;base64," + imgEncode + "\')";
                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                helper.showToastError2('Get WatermarkHTML Failed, Message:'+response.error);
                component.set('v.loading', false)
            } else {
                helper.showToastError2('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                component.set('v.loading', false)
            }
		});
		$A.enqueueAction(action);
	},

    // toggleHelper : function(component,event,index) {
    //     var toggleText = component.find("tooltip");
    //     console.log('debug toggle text',toggleText)
    //     $A.util.toggleClass(toggleText[index], "toggle");
    // },

    toggleHelper : function(component,event,id) {
        // var toggleText = component.find(id);
        var toggleText = document.getElementById(id);
        $A.util.toggleClass(toggleText, "toggle");
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

    transformSaleTrans : function(saleTrans) {
        for(var i = 0; i < saleTrans.length; i++) {
            var productString = saleTrans[i].Indicator_Level1__c + (saleTrans[i].Indicator_Level2__c != null ? ' / '+saleTrans[i].Indicator_Level2__c : '') + ' / '+saleTrans[i].Indicator_Name__c;
            // {!salesTrans.Indicator_Level1__c} <aura:if isTrue="{! salesTrans.Indicator_Level2__c != null}"> / {!salesTrans.Indicator_Level2__c}</aura:if> / {!salesTrans.Indicator_Name__c}
            saleTrans[i].productString = productString;
            if(saleTrans[i].Deduct_Flag__c == 'Y') {
                saleTrans[i].Deduct_Date__c = saleTrans[i].KPI_Date__c;
            }
        }
        return saleTrans;
    },

    getSharePointLink : function(component){
        /* component.set('v.loaded',true); */
        // var shareType = component.get('v.shareType');// at cmp
        var action = component.get('c.getSharePointLink');// get function at apex
        var saleInfo  = component.get('v.saleInfo');
        // action.setParams({
        // });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log('state',state);
            if (state === "SUCCESS") {               
                // console.log('status',status)
                var result =  response.getReturnValue();   
                if(result) {
                    result.forEach(obj => {
                        if(obj.SharePoint_Type__c == 'Help') {
                            component.set('v.helpLink',obj.URL_Link__c);
                        } else {
                            // component.set('v.summaryLink',obj.URL_Link__c+saleInfo.Branch_Code__c+'.pdf');
                            component.set('v.summaryLink',obj.URL_Link__c.replaceAll('$branchcode;',saleInfo.Branch_Code__c));
                        }
                    });
                }
                /* component.set('v.loaded', false); */
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError2('Get SharePoint Link Failed, Message:'+message);
                component.set('v.loading', false)
            }  
        });
        $A.enqueueAction(action);  

    },

    getProductList : function(component, helper) {
        component.set('v.sectionBLoading',true);
        var selectedMonth = component.get('v.selectedMonth');
        var selectedYear = component.get('v.selectedYear');
        var empId = component.get('v.selectedEmpId');
        var keyTypeFilter = component.get('v.selectedPerfKey');
        var keyValueFilter = component.get('v.selectedPerfValue');

        var filterStr = '';
        if(keyValueFilter != null) {
            if(keyTypeFilter == 'lv1') {
                filterStr = ' AND Indicator_Level1__c=\''+keyValueFilter+'\' ';
            } else if(keyTypeFilter == 'lv2') {
                filterStr = ' AND Indicator_Level2__c=\''+keyValueFilter+'\' ';
            } else if(keyTypeFilter == 'name') {
                filterStr = ' AND Indicator_Name__c=\''+keyValueFilter+'\' ';
            }
        }

        var fieldList = ' Id, Name, Year__c, Month__c, Sale_Team__c, Zone__c, Region__c, Channel__c, Book_Service_Branch__c, Employee_ID__c, Sale_Name__c, Position__c, Indicator_Code_Level1__c, Indicator_Code_Level2__c, Indicator_Code__c, Indicator_Level1__c, Indicator_Level2__c, Indicator_Name__c, Indicator_Rank__c, Sale_Point_Engine__c, Sale_Volume__c, Sale_Unit__c, Actual_Performance__c, Actual_Point__c, KPI_Date__c, Customer_Number__c, Reference_Number1__c, Reference_Number2__c, Deduct_Date__c, Deduct_Point__c, Deduct_Flag__c, Deduct_Actual_Point__c, Unique_External_Key__c ';
        var condition = '';

        if(selectedMonth == null) {
            // data as of year
            // transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear '+filterStr;
            condition = ' WHERE Year__c = \''+selectedYear+'\' AND Employee_ID__c = \''+empId+'\' '+filterStr+' ';
        } else {
            // data as of month
            var selectedMonthStr = selectedMonth.toString().padStart(2,'0');
            // transRowQuery = 'SELECT COUNT(Id) Trans_Row FROM Sale_Transaction__c WHERE Employee_ID__c =: empId AND Year__c =: selectedYear AND Month__c =: selectedMonthStr '+filterStr;
            condition = ' WHERE Year__c = \''+selectedYear+'\' AND Month__c = \''+selectedMonthStr+'\' AND Employee_ID__c = \''+empId+'\' '+filterStr+' ';
        }

        
        var productListQueryWrapper = {
            "chunkSize": 35000,
            "lastRecordId": null,
            "isEndRecord": null,
            "fieldList": fieldList,
            "queryObject": "Sale_Transaction__c",
            "condition": condition,
            "resultRecords": []
        }

        Array.prototype.multiIndexOf = function (attr, el) { 
            var idxs = [];
            for (var i = this.length - 1; i >= 0; i--) {
                if (this[i][attr] === el) {
                    idxs.unshift(i);
                }
            }
            return idxs;
        };

        helper.chunkQuery(component,helper,productListQueryWrapper, []).then((resultRecords) => {
            // if(result.salesTransaction)
            // {
            var cusNoList = null;
            resultRecords.forEach((dat) => {
                dat.KPI_Date_Display = helper.formatDate(dat.KPI_Date__c);
                // dat.KPI_Date__c = helper.formatDate(dat.KPI_Date__c);
                dat.Deduct_Date_Display = helper.formatDate(dat.Deduct_Date__c);
                // dat.Deduct_Date__c = helper.formatDate(dat.Deduct_Date__c);
                // dat.Reference_Number2__c = helper.formatDate(dat.Reference_Number2__c);

                if(cusNoList == null) {
                    cusNoList = "\'"+dat.Customer_Number__c+"\'";
                } else if(!(cusNoList.includes(dat.Customer_Number__c))) {
                    cusNoList += ',\''+dat.Customer_Number__c+'\'';
                }
            })
            if(cusNoList) {

                helper.getCustomerMapProductList(component, helper, cusNoList).then((cusList) => {
                    cusList.forEach(cus => {
                        var productIdxList = resultRecords.multiIndexOf('Customer_Number__c',cus.TMB_Customer_ID_PE__c);
                        if(productIdxList.length > 0) {
                            productIdxList.forEach(idx => {
                                resultRecords[idx]['CustomerName'] = cus.Name;
                            });
                        }
                    });
                    // }
                    // component.set('v.saleTranList',result.salesTransaction);
                    var saleTransData = this.transformSaleTrans(resultRecords);
                    component.set('v.saleTransData',saleTransData);
                    
    
                    component.set('v.totalSize',saleTransData.length);
    
                    var newStart = component.get("v.start");
                    var newEnd = component.get("v.end");
                    var newList = saleTransData.slice(newStart-1,newEnd);
                    component.set('v.saleTranList',newList);
                    component.set('v.sectionBLoading',false);
                }).catch(() => {
                    component.set('v.sectionBLoading',false);
                })
            } else {
                var saleTransData = this.transformSaleTrans(resultRecords);
                component.set('v.saleTransData',saleTransData);
                
                component.set('v.totalSize',saleTransData.length);

                var newStart = component.get("v.start");
                var newEnd = component.get("v.end");
                var newList = saleTransData.slice(newStart-1,newEnd);
                component.set('v.saleTranList',newList);
                component.set('v.sectionBLoading',false);
            }
            
            
        });
    },


    getCustomerMapProductList : function(component, helper, cusNoList) {
        return new Promise(function (resolve, reject) {
            var cusMapProdQueryWrapper = {
                "chunkSize": 35000,
                "lastRecordId": null,
                "isEndRecord": null,
                "fieldList": " Id, TMB_Customer_ID_PE__c, Name ",
                "queryObject": " Account ",
                "condition": ' WHERE TMB_Customer_ID_PE__c IN('+cusNoList+') ',
                "resultRecords": []
            }
    
            helper.chunkQuery(component,helper,cusMapProdQueryWrapper, []).then((resultRecords) => {
                resolve(resultRecords)
            }).catch((error) => {
                reject(error);
            });
        });
        
    },
    

    chunkQuery : function(component, helper, chunkQueryWrapper, recordsStack) {
        // if(chunkQueryWrapper == null) {
        //     var sumTransBankWideWrapper = component.get('v.sumTransBankWideWrapper');
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
                    helper.showToastError2('Chunk query performance failed, Message: '+message);
                    // Display the message
                    component.set('v.loading', false)
                    component.set('v.sectionBLoading', false)
                    reject(message);
                    /* reject(message); */
                    
                }  
            });
            
            $A.enqueueAction(action);    
        });
    },

    showToastError2 : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error",
            "message": msg
        });
        toastEvent.fire();
    },
})