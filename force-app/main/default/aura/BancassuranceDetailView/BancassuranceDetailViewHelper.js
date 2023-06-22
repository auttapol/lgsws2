({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    displayToast: function (type, message) {
        var duration = type.toLowerCase() == 'error' ? 8000 : 5000;
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });
        toastEvent.fire();
    },
    displayErrorMessage: function (component, title, errMsg) {
        component.set('v.error.state', true);
        component.set('v.error.title', title);
        component.set('v.error.message', errMsg);
    },
    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    doWorkspaceAPI: function (component, tabName) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.getTabInfo({
                tabId: tabId
            }).then(function (response) {
                if (response.isSubtab) {
                    workspaceAPI.setTabLabel({
                        tabId: response.tabId,
                        label: tabName,
                    });
                    workspaceAPI.setTabIcon({
                        tabId: response.tabId,
                        icon: "standard:product",
                        iconAlt: tabName,
                    });
                }
            });
        }).catch(function (error) {
            console.log(error);
        });
    },
    getBancassuranceProduct: function (component, event, helper) {
        helper.startSpinner(component);
        var tmbCustId = component.get('v.tmbCustId');

        var action = component.get('c.getBancDetailData');
        action.setParams({
            "rmId": component.get('v.RMID'),
            "policyNo": component.get('v.PolicyNumber'),
            "recordId": component.get('v.recordId'),
            'tmbCustId': tmbCustId,
        });
        action.setCallback(this, function (response) {

            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    if(result.Status.StatusCode != 200){
                        helper.displayToast('error', result.Status.StatusDesc);
                        helper.displayErrorMessage(component, 'Warning!', result.Status.StatusDesc);
                    }
                    else if (result.StatusDesc) {
                        helper.displayToast('error', result.Message);
                        helper.displayErrorMessage(component, 'Warning!', result.Message);
                    }
                    else if (result.GetBancassuranceAccountDetailResponse.Result.Status != 'SUCCESS'){
                        helper.displayToast('error', result.GetBancassuranceAccountDetailResponse.Result.Message);
                        helper.displayErrorMessage(component, 'Warning!', result.GetBancassuranceAccountDetailResponse.Result.Message);
                    }
                    else {
                        if(result.Authorize == true){
                            helper.generateValue(component, result);
                        }
                        else{
                            helper.genHiddenData(component, result);
                        }
                    }
                }
                helper.stopSpinner(component);
            } else {
                helper.stopSpinner(component);
                var errors = response.getError();
                errors.forEach(function (erorr) {
                    console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    generateValue: function (component, result) {
        var helper = this;
        result = result.GetBancassuranceAccountDetailResponse.Result;
        helper.doWorkspaceAPI(component, result.BancassuranceInformation.PolicyNo);

        const mapVariableField = [{
                key: 'v.fields.BancassuranceInformation',
                value: result.BancassuranceInformation,
                isSuccess: result.BancassuranceInformation.Status == 'SUCCESS'
            },
            {
                key: 'v.fields.BancassuranceDetails',
                value: result.BancassuranceDetails,
                isSuccess: result.BancassuranceInformation.Status == 'SUCCESS'
            },
            {
                key: 'v.fields.PaymentInformation',
                value: result.PaymentInformation,
                isSuccess: result.PaymentInformation.Status == 'SUCCESS'
            },
            {
                key: 'v.fields.NextCashBackInformation',
                value: result.NextCashBackInformation,
                isSuccess: result.NextCashBackInformation.Status == 'SUCCESS'
            },
            {
                key: 'v.fields.InsuredPropertyAsset',
                value: result.InsuredPropertyAsset,
                isSuccess: result.InsuredPropertyAsset.Status == 'SUCCESS'
            },
            {
                key: 'v.fields.InsuredAutomobileAsset',
                value: result.InsuredAutomobileAsset,
                isSuccess: result.InsuredAutomobileAsset.Status == 'SUCCESS'
            },
        ];
        mapVariableField.forEach(function (v) {
            if (v.isSuccess) {
                component.set(v.key, component.get(v.key).map(function (i) {
                    if (i.type == 'PARSE') {
                        i.valueTemp = v.value[i.fieldKey];
                        helper.makeValue(component, v.key, i);
                    } else if (v.value.hasOwnProperty(i.fieldName)) {
                        i.value = v.value[i.fieldName];
                        // i.value = i.value && i.type == 'DATE' ? new Date(i.value.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) : i.value;
                    }
                    i.type = 'STRING';
                    return i;
                }));
            } else {
                var firstCmp = component.get(v.key).find(function (f) {
                    return f;
                });
                firstCmp.value = $A.get('$Label.c.ERR008');
                firstCmp.type = 'STRING';
                firstCmp.class = 'notFound';
                component.set(v.key, component.get(v.key));
            }
        });

        var isSuccessBeneficiaryInformation = result.BeneficiaryInformation.Status == "SUCCESS";
        if (isSuccessBeneficiaryInformation) {
            var Beneficiary = result.BeneficiaryInformation.Beneficiary;
            component.set('v.fields.BeneficiaryInformation', Array.isArray(Beneficiary) && Beneficiary ? Beneficiary.reduce(function (l, v, i) {
                l.push({
                    label: $A.get('$Label.c.Beneficiary_Name') + ' ' + (i + 1),
                    fieldName: 'Name',
                    value: v.Name,
                    isAccessible: true,
                    type: 'STRING',
                });
                l.push({
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                    value: v.Relationship,
                    isAccessible: true,
                    type: 'STRING',
                });
                return l;
            }, []) : [{
                    label: $A.get('$Label.c.Beneficiary_Name'),
                    fieldName: 'Name',
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                },
            ].map(function (i) {
                i.isAccessible = true;
                i.type = i.type ? i.type : 'STRING';
                i.value = Beneficiary ? Beneficiary[i.fieldName] : '';
                return i;
            }));
        } else {
            component.set('v.fields.BeneficiaryInformation', [{
                    label: $A.get('$Label.c.Beneficiary_Name'),
                    fieldName: 'Name',
                    isAccessible: true,
                    value: $A.get('$Label.c.ERR008'),
                    class: 'notFound',
                },
                {
                    label: $A.get('$Label.c.Relationship'),
                    fieldName: 'Relationship',
                },
            ]);
        }

        var isSuccessInsuranceClaimRecord = result.InsuranceClaimRecord.Status == "SUCCESS";
        if (isSuccessInsuranceClaimRecord) {
            var ClaimRecord = result.InsuranceClaimRecord.ClaimRecord;
            ClaimRecord = Array.isArray(ClaimRecord) ? ClaimRecord : (ClaimRecord ? [ClaimRecord] : []);
            component.set('v.fields.InsuranceClaimRecord.datas', ClaimRecord.length > 0 ? ClaimRecord.reduce(function (l, i) {
                l.push({
                    // 'Date': i.TempDate ? new Date(i.TempDate.match(/([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) : '',
                    'Date': i.TempDate,
                    'Type': i.Type,
                    'Description': i.Description,
                    // 'RequestAmount': parseFloat(i.RequestAmount).toLocaleString('en-US'),
                    'RequestAmount': i.RequestAmount,
                    // 'ApprovedAmount': parseFloat(i.ApprovedAmount).toLocaleString('en-US'),
                    'ApprovedAmount': i.ApprovedAmount,
                });
                return l;
            }, []) : []);
        } else {
            var firstCmp = component.get('v.fields.InsuranceClaimRecord.datas').find(function (f) {
                return f;
            });
            firstCmp.type = 'text';
            component.set('v.fields.InsuranceClaimRecord.datas', component.get('v.fields.InsuranceClaimRecord.datas'));
            component.set('v.fields.InsuranceClaimRecord.datas', [{
                'Date': $A.get('$Label.c.ERR008'),
                'ERROR': 'notFound',
            }]);
        }
    },

    genHiddenData : function(component, result){
        component.set('v.fields.BancassuranceInformation', component.get('v.fields.BancassuranceInformation').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.BancassuranceDetails', component.get('v.fields.BancassuranceDetails').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.PaymentInformation', component.get('v.fields.PaymentInformation').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.NextCashBackInformation', component.get('v.fields.NextCashBackInformation').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.InsuredPropertyAsset', component.get('v.fields.InsuredPropertyAsset').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.InsuredAutomobileAsset', component.get('v.fields.InsuredAutomobileAsset').map(function (i) {
            i.value = $A.get('$Label.c.Data_Condition_Hidden_Text');
            i.type= 'STRING';
            return i;
        }));

        component.set('v.fields.BeneficiaryInformation', [{
                label: $A.get('$Label.c.Beneficiary_Name'),
                type: 'STRING',
                fieldName: 'Name',
                isAccessible: true,
                value: $A.get('$Label.c.Data_Condition_Hidden_Text'),
            },
            {
                label: $A.get('$Label.c.Relationship'),
                type: 'STRING',
                fieldName: 'Relationship',
                isAccessible: true,
                value: $A.get('$Label.c.Data_Condition_Hidden_Text'),
            },
        ]);
    },

    makeValue: function (component, key, field) {
        var action = component.get('c.getMakeValue');
        action.setParams({
            'functionName': field.funcName,
            'value': field.valueTemp
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.get(key).find(function (f) {
                        return f.fieldName == field.fieldName;
                    }).value = result;
                    component.set('v.fields', component.get('v.fields'));
                }
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });

        if (field.valueTemp)
            $A.enqueueAction(action);
    },
    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermark");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
            }
		});
		$A.enqueueAction(action);
	},
})