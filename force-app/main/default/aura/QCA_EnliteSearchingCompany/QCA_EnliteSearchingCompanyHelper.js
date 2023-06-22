({
    displayToast: function (component, type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    parseObj: function (objFields) {
        return JSON.parse(JSON.stringify(objFields));
    },
    startSpinner: function (component, type) {
        component.set('v.showErrorMessage', false);
        var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
        compEvent.setParams({
            "isSuccess": true,
            "type": type
        });
        compEvent.fire();
        component.set('v.showSpinnerLoading', true);
    },
    stopSpinner: function (component, type) {
        var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
        compEvent.setParams({
            "isSuccess": false,
            "type": type
        });
        compEvent.fire();
        component.set('v.showSpinnerLoading', false);
    },
    initializeCompanies: function (component) {
        component.set('v.companies.columns', [{
                label: 'Company Name',
                fieldName: 'NAME_TH',
                type: 'text',
                sortable: true,
                fixedWidth: 360
            },
            {
                label: 'ID Number',
                fieldName: 'REGISTRATION_ID',
                type: 'text',
                sortable: true,
            }
        ]);
        component.set('v.companies.data', []);
        component.set('v.companies.display', []);
        var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
        compEvent.setParams({
            "isSuccess": false,
            "type": 'clickSelected'
        });
        compEvent.fire();
    },
    displayErrorMeassge: function (component, event, errors, isDisplay) {
        if (isDisplay) {
            component.set('v.errorMessageList', errors.reduce((listError, error) => {
                listError.push({
                    'errorHeader': error.header,
                    'errorMessage': error.message,
                });
                return listError;
            }, []));
        }
        component.set('v.showErrorMessage', isDisplay);
    },
    getVFBaseURL: function (component, event, helper) {
        helper.startSpinner(component, 'spinnerSelected')
        var action = component.get('c.getVFBaseURL');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.vfHost', result[1]);
                helper.addEventListenerCompanies(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    getLimitOffsetRecord: function (component, event, helper) {
        var action = component.get('c.getLimitOffsetRecord');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.limitOffsetRecord', result);
            }
        });
        $A.enqueueAction(action);
    },
    addEventListenerCompanies: function (component, event, helper) {
        window.addEventListener("message", function (event) {
            var vfHost = component.get('v.vfHost') ? component.get('v.vfHost') : '';
            if (event.origin.toLowerCase() !== vfHost.toLowerCase()) {
                // Not the expected origin: reject message
                return;
            }
            // Only handle messages we are interested in
            if (event.data.topic === "smartbdm.com.tmbbank.onloading") {
                helper.stopSpinner(component, 'spinnerSelected')
            } else if (event.data.topic === "smartbdm.com.tmbbank.companylist") {
                helper.stopSpinner(component, 'inputSearched');
                var response = event.data.result ? event.data.result : null;
                if (response.isSuccess) helper.rerenderCompanyTable(component, helper, response.companyList);
                else {
                    component.set('v.companies.data', []);
                    component.set("v.totalRecordsCount", component.get('v.companies.data').length);
                    component.set('v.showDataCompanies', false);
                    var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
                    compEvent.setParams({
                        "isSuccess": response.isSuccess,
                        "type": 'errorMessage',
                        "errorMessage": response.errorMessage, // $A.get("$Label.c.Error_message_searching_input")
                    });
                    compEvent.fire();
                }
            } else if (event.data.topic === "smartbdm.com.tmbbank.companydetail") {
                var response = event.data.result ? event.data.result : null;
                if (response.isSuccess) {
                    component.set('v.companyDetailSelected', response.companyDetail)
                    var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
                    compEvent.setParams({
                        "companyDetail": response
                    });
                    compEvent.fire();
                } else {
                    // helper.displayToast(component, 'error', response.errorMessage);
                    helper.displayErrorMeassge(component, event, [{
                        'header': '',
                        'message': response.errorMessage
                    }], true);
                    helper.stopSpinner(component, 'spinnerSelected');
                }
            }
        }, false);
    },
    rerenderCompanyTable: function (component, helper, response) {
        helper.initializeCompanies(component);
        var companies = response.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs;
        var size = companies && companies.length > 0 ? companies[0].Value.length : 0;
        var rObj = [];
        for (var i = 0; i < size && i < component.get('v.limitOffsetRecord'); i++) {
            var tmp = {};
            for (var j = 0; j < companies.length; j++) {
                if (companies[j].ResultDesc) tmp[companies[j].ResultDesc] = companies[j].Value[i];
            }
            rObj.push(tmp);
        }
        component.set('v.companies.data', rObj);
        component.set('v.showDataCompanies', rObj.length > 0);

        //Pagination
        if (rObj.length > 0) {
            var companiesData = component.get('v.companies.data');
            var pageSize = component.get("v.pageSize");
            var totalLength = companiesData.length;
            component.set("v.currentPage", 1); // to default
            component.set("v.totalRecordsCount", totalLength);
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
            component.set('v.companies.display', companiesData.reduce((list, item) => {
                if (list.length == pageSize) return list;
                list.push({
                    'NAME_TH': item.NAME_TH,
                    'NAME_EN': item.NAME_EN,
                    'REGISTRATION_ID': item.REGISTRATION_ID,
                    'FS_YEAR': item.FS_YEAR
                });
                return list;
            }, []));
            // helper.rePagination(component);
        }
    },
    getCompanyList: function (component, event, helper) {
        // var vfHost = component.get("v.vfHost");
        // if (vfHost) {
        //     helper.startSpinner(component, 'inputSearched');
        //     var params = event.getParam('arguments');
        //     var vf = component.find("vfFrame").getElement().contentWindow;
        //     vf.postMessage({
        //         topic: "smartbdm.com.tmbbank.companylist",
        //         'searchKey': params.key,
        //     }, vfHost);
        // }

        helper.startSpinner(component, 'inputSearched');
        var params = event.getParam('arguments');
        var action = component.get('c.startCallGetCompanyListServiceContinuation');
        action.setParams({
            'searchCompanyKey': params.key,
            'combineTable': false
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.isSuccess) {
                    helper.rerenderCompanyTable(component, helper, result.tempCompanyList);
                    var companies = result.tempCompanyList.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs;
                    if (companies.length == 0) {
                        var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
                        compEvent.setParams({
                            "isSuccess": false,
                            "type": 'errorMessage',
                            "errorMessage": $A.get("$Label.c.Error_message_not_found_information")
                        });
                        compEvent.fire();
                    }
                } else {
                    var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
                    compEvent.setParams({
                        "isSuccess": result.isSuccess,
                        "type": 'errorMessage',
                        "errorMessage": result.errorMessage, // $A.get("$Label.c.Error_message_searching_input")
                    });
                    compEvent.fire();
                    component.set('v.companies.display', []);
                    component.set("v.totalRecordsCount", 0);
                    component.set('v.showDataCompanies', false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.displayToast(component, "Error", "Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.stopSpinner(component, 'inputSearched');
        });
        $A.enqueueAction(action);
    },
    getCompanyDetail: function (component, event, helper) {
        // var vfHost = component.get("v.vfHost");
        // if (vfHost) {
        //     helper.startSpinner(component, 'spinnerSelected');
        //     var params = component.get('v.companySelected');
        //     var vf = component.find("vfFrame").getElement().contentWindow;
        //     vf.postMessage({
        //         topic: "smartbdm.com.tmbbank.companydetail",
        //         'registerId': params.REGISTRATION_ID,
        //     }, vfHost);
        // }

        helper.startSpinner(component, 'spinnerSelected');
        var actionForFiscalYear = component.get('c.startCallGetCompanyListServiceContinuation');
        var action = component.get('c.startCallGetCompanyDetailService');
        var params = component.get('v.companySelected');
        var fiscalYear;
        actionForFiscalYear.setParams({
            'searchCompanyKey': params.REGISTRATION_ID,
            'combineTable': true
        });
        actionForFiscalYear.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var companies = result.isSuccess ? result.tempCompanyList.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs : [];
                var size = companies && companies.length > 0 ? companies[0].Value.length : 0;
                var rObj = [];
                for (var i = 0; i < size && i < component.get('v.limitOffsetRecord'); i++) {
                    var tmp = {};
                    for (var j = 0; j < companies.length; j++) {
                        if (companies[j].ResultDesc) tmp[companies[j].ResultDesc] = companies[j].Value[i];
                    }
                    rObj.push(tmp);
                }

                if (rObj.length > 0) {
                    action.setParams({
                        'registerId': params.REGISTRATION_ID,
                        'fiscalYear': rObj[0].FS_YEAR
                    });
                    $A.enqueueAction(action);
                } else {
                    helper.displayErrorMeassge(component, event, [{
                        'header': '',
                        'message': $A.get("$Label.c.Other_Error")
                    }], true);
                    helper.stopSpinner(component, 'spinnerSelected');
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.displayToast(component, "Error", "Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        action.setParams({
            'registerId': params.REGISTRATION_ID,
            'fiscalYear': fiscalYear
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.isSuccess) {
                    component.set('v.companyDetailSelected', result.tempCompanyDetailAccount)
                    var compEvent = component.getEvent("varHandlerSearchingCompanyEvent");
                    compEvent.setParams({
                        "companyDetail": result.tempCompanyDetailAccount
                    });
                    compEvent.fire();
                } else {
                    // helper.displayToast(component, 'error', result.errorMessage);
                    helper.displayErrorMeassge(component, event, [{
                        'header': '',
                        'message': result.errorMessage ? result.errorMessage : $A.get("$Label.c.Timeout_message")
                    }], true);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.displayToast(component, "Error", "Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.stopSpinner(component, 'spinnerSelected');
        });

        // Initial start callout service get Company list
        $A.enqueueAction(actionForFiscalYear);
    },
    sortData: function (component, event, helper, fieldName, sortDirection) {
        var data = component.get("v.companies.data");
        // var data = component.get("v.companies.display");

        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        // component.set("v.companies.display", data);
        helper.reDataTablePagination(component, event, helper);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x[field])
            } :
            function (x) {
                return x[field]
            };
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    reDataTablePagination: function (component, event, helper) {
        var companiesDisplay = [];
        var companies = component.get("v.companies.data");
        var currentPage = component.get("v.currentPage");
        var pageSize = component.get("v.pageSize");
        var init = currentPage - 1;
        var to = currentPage * pageSize;
        for (var i = init * pageSize; i < to && i < companies.length; i++) {
            companiesDisplay.push(companies[i]);
        }
        component.set('v.companies.display', companiesDisplay);
        // helper.rePagination(component);
    },
    rePagination: function (component, event, helper) {
        var currentPage = component.get('v.currentPage');
        var totalPagesCount = component.get("v.totalPagesCount");
        var noPageList = [1, totalPagesCount];
        var start = Math.ceil(noPageList.length / 2);
        for (var i = currentPage - 1; i >= currentPage - 1 && i <= currentPage + 1; i++) {
            if (i > 1 && i < totalPagesCount) {
                noPageList.splice(start, 0, i);
                start++;
            }
        }
        component.set("v.NoPage", noPageList);
    }
})