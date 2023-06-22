({
    doInit: function (component, event, helper) {
        helper.getIsUnmaskData(component,helper);
        helper.mapColumn(component, event, helper);
        helper.execAccessibleCusHold(component, event, helper);
        helper.getALDXWFMdt(component, event, helper);
        helper.callProduct(component, event, helper);
        helper.doWorkspaceAPI(component);
    },
    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
    },
    doWorkspaceAPI: function (component) {
        var tabName = component.get('v.fields.HpInformation').find(f => f.fieldName == 'ContractNo').value ||
            component.get('v.markedcontractNo');

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: tabName,
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:product",
                iconAlt: tabName,
            });
        }).catch(function (error) {
            console.log(error);
        });
    },

    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },
    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },
    execAccessibleCusHold: function (component, event, helper) {
        if (component.get('v.accountType') === 'Commercial' &&
            Object.keys(component.get('v.accessibleCusHold')).length > 0) {
            [
                'v.fields.HpInformation',
                'v.fields.Guarantor',
            ].forEach(e => {
                component.set(e, component.get(e).map(function (m) {
                    m.fieldName = m.isAccessible ? (component.get(`v.accessibleCusHold.${m.isAccessible}`) ? m.fieldName : 'Hidden') : m.fieldName;
                    m.type = m.fieldName == 'Hidden' ? 'STRING' : m.type;
                    // m.value = m.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : '';
                    return m;
                }));
            });
        }
    },
    callProduct: function (component, event, helper) {
        helper.startSpinner(component);
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_HpFleetHpDetail',
            'callback': 'callbackHpFleetHpDetail',
            'body': JSON.stringify({
                "Company": component.get('v.company'),
                "ContractNo": component.get('v.contractNo'),
                "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
            }),
            'service': 'CoreHP',
            'state': {
                'service': 'CoreHP',
                'recordId': component.get('v.recordId'),
                'tmbCustId': component.get('v.tmbCustId'),
                'sectionName': 'CommCust:Customer Product Holding (High)',
                'accountType': component.get('v.accountType')
            },
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.error.messages.FleetHP.label', $A.get('$Label.c.Auto_Loan_HP_Fleet_HP'));
                component.set('v.error.messages.FleetHP.isError', result['isError'] || result['isThrow'] ? true : false);
                component.set('v.error.messages.FleetHP.isTimeout', result['isTimeout'] ? true : false);

                helper.handleAlertError(component);
                helper.mapData(component, result.Output ? result.Output[0] : {},helper);
                helper.stopSpinner(component);

            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log('error: ', error.message);
                });

                component.set('v.error.messages.AutoLoan_HP.isError', true);
                helper.handleErrorMessage(component, event, helper);
                helper.stopSpinner(component);
            }
        });
        //$A.enqueueAction(helper.callIsALGuarantorMdt(component, action));
        $A.enqueueAction(action);
    },
    callIsALGuarantorMdt: function (component, callbackAction) {
        var action = component.get('c.getIsALGuarantorMdt');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.isMark', result ? !result : component.get('v.isMark'));
                $A.enqueueAction(callbackAction);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        return action;
    },
    getALDXWFMdt: function (component, event, helper) {
        var action = component.get('c.getALDXWFMdt');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.alds_wf', result);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        $A.enqueueAction(action);
    },
    mapColumn: function (component, event, helper) {
        //HP Detail
        component.set('v.fields.HpInformation', [{
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.HP_Account_No'),
            fieldName: 'ContractNo',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldHig',
            label: $A.get('$Label.c.HUB'),
            fieldName: 'HubOwnerName',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.HP_Customer_ID'),
            fieldName: 'CustomerCode',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Auto_Loan_Product_Name'),
            fieldName: 'ProductCode',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Contract_Date'),
            fieldName: 'ContractDate10',
            // type: 'DATE'
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Contract_Last_Due_Date'),
            fieldName: 'LastDueDate',
            // type: 'DATE'
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldHig',
            label: $A.get('$Label.c.Dealer'),
            fieldName: 'DealerName',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldHig',
            label: $A.get('$Label.c.AO_Name'),
            fieldName: 'MarketingOfficerName',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldHig',
            label: $A.get('$Label.c.Car_Price'),
            fieldName: 'CarpriceAmt',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Down_Amount'),
            fieldName: 'CarDownAmt',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Financial_Amount'),
            fieldName: 'FinancialAmount',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Due_Date'),
            fieldName: 'DueDay',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Installment_Amount'),
            fieldName: 'InstallmentAmount',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldHig',
            label: $A.get('$Label.c.Paid_By'),
            fieldName: 'PaymentMethodDesc',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Interested_Rate'),
            fieldName: 'InterestedRate',
            // type: 'INTEGER'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Contract_First_Due_Date'),
            fieldName: 'FirstInstallmentDate10',
            // type: 'DATE'
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Contract_Period'),
            fieldName: 'TotalInstallments',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Outstanding_Amount'),
            fieldName: 'OutstandingAmount',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Paid_Period'),
            fieldName: 'CurrentOfInstallments',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Status_AutoLoan'),
            fieldName: 'ContractStatusCode',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Remain_Period'),
            fieldName: 'NumberOfInstallmentBalance',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Year'),
            fieldName: 'CarYear',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Brand_Model'),
            fieldName: 'CarBrandName',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Car_Type'),
            fieldName: 'CarTypeDesc',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Color'),
            fieldName: 'CarColorName',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Plate_No'),
            fieldName: 'CarRegno',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Car_Product_Type'),
            fieldName: 'ProductCarType',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Province'),
            fieldName: 'CarRegProv',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.HP_Amount'),
            fieldName: 'HPTotalAmount',
            // type: 'NUMBER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.SN_Body'),
            fieldName: 'CarChasis',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Overdue_Amount'),
            fieldName: 'OverdueAmount',
            // type: 'INTEGER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.SN_Engine'),
            fieldName: 'CarEngno',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Penalty_Amount'),
            fieldName: 'PenaltyAmount',
            // type: 'INTEGER',
            masking: true,
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Engine_cc'),
            fieldName: 'CarEngineSize',
            type: 'STRING'
        }, {
            isAccessible: 'isAccessibleCusHoldLow',
            label: $A.get('$Label.c.Overdue_No'),
            fieldName: 'OverdueNo',
            type: 'STRING'
        }].map(m => {
            m.type = m.type ? m.type : 'STRING';
            return m;
        }))

        // Guarantor
        var guarantorDatas = [];
        for (let i = 0; i < 4; i++) {
            guarantorDatas.push({
                label: $A.get('$Label.c.Guarantor_Name') + ' ' + (i + 1),
                fieldName: 'GuarantorName' + (i + 1),
                type: 'STRING',
                isAccessible: '',
            }, {
                label: $A.get('$Label.c.ID_Number'),
                fieldName: 'GuarantorIDNo' + (i + 1),
                type: 'STRING',
                isAccessible: '',
            }, {
                label: $A.get('$Label.c.Birth_Date'),
                fieldName: 'GuarantorBD' + (i + 1),
                type: 'STRING',
                isAccessible: '',
            }, {
                label: '',
                fieldName: '',
                class: 'slds-hide'
            });
        }
        component.set('v.fields.Guarantor', guarantorDatas);

    },
    mapData: function (component, data, helper) {
        var methodUtils = component.find('methodUtils');

        component.set('v.result', data);
        var hpDatas = component.get('v.fields.HpInformation');
        var guarantorDatas = component.get('v.fields.Guarantor');
        var isError = component.get('v.error.state');

        // Unmask mapping
        var unmasked = component.get("v.unmasked");
        var AutoLoanDetail = unmasked != null ? unmasked["AutoLoan_Detail"]:null;
        if(unmasked != null && !helper.isEmployee(component)){
            hpDatas.forEach(function(a){
                AutoLoanDetail.forEach(function(b){
                    if(a.fieldName == b.field){
                        a.masking = !b.unmasked;
                        a.toDigitformat = b.unmasked;
                    }
                });
            });
        }

        hpDatas.forEach(item => {
            item.class = isError ? `${item.class || ''} erorrProduct` : `${item.class || ''}`.replace(/( erorrProduct)/g, '');
            item.value = isError ? `${$A.get('$Label.c.ERR008')}` : (item.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : component.get(`v.result.${item.fieldName}`));
        });
        if (!isError) {
            hpDatas.find(f => f.fieldName == 'ContractStatusCode').value = `${component.get(`v.result.ContractStatusCode`)} - ${component.get(`v.result.ContractStatusName`)}`;
            hpDatas.find(f => f.fieldName == 'CarBrandName').value = `${component.get(`v.result.CarBrandName`)} ${component.get(`v.result.CarModel`)}`;
            hpDatas.find(f => f.fieldName == 'ContractNo').value = component.get(`v.result.ContractNo`) ?
                methodUtils.markAccountNo(component.get(`v.result.ContractNo`), 'xxxxxxxyyyyy'.substr(12 - `${component.get(`v.result.ContractNo`)}`.length ? 12 - `${component.get(`v.result.ContractNo`)}`.length : 0)) :
                component.get('v.markedcontractNo');
            hpDatas.filter(f => f.masking)
                .forEach(item => {
                    item.value = item.fieldName == 'Hidden' ? item.value : methodUtils.markAmount(item.value);
                });
            // Unmasking to digitFormat
            hpDatas.filter(f => f.toDigitformat)
                .forEach( item =>{
                    item.value = isNaN(Number(item.value))?item.value: Number(item.value).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                });
            // ALDX WF Status code
            if (component.get(`v.alds_wf.${component.get(`v.result.ContractStatusCode`)}`)) {
                hpDatas.find(f => f.fieldName == 'OutstandingAmount').value = component.get(`v.alds_wf.${component.get(`v.result.ContractStatusCode`)}.WARNING_MESSAGE__c`);
                hpDatas.find(f => f.fieldName == 'OverdueAmount').value = component.get(`v.alds_wf.${component.get(`v.result.ContractStatusCode`)}.WARNING_MESSAGE__c`);
                hpDatas.find(f => f.fieldName == 'PenaltyAmount').value = component.get(`v.alds_wf.${component.get(`v.result.ContractStatusCode`)}.WARNING_MESSAGE__c`);
            }

            if(helper.isEmployee(component) == true){
                hpDatas.find(f => f.fieldName == 'OutstandingAmount').value = $A.get('$Label.c.Data_Condition_Hidden_Text');
                hpDatas.find(f => f.fieldName == 'InstallmentAmount').value = $A.get('$Label.c.Data_Condition_Hidden_Text');
                hpDatas.find(f => f.fieldName == 'HPTotalAmount').value = $A.get('$Label.c.Data_Condition_Hidden_Text');

            }
            this.doWorkspaceAPI(component);
        }

        guarantorDatas.forEach(item => {
            item.class = isError ? `${item.class || ''} erorrProduct` : `${item.class || ''}`.replace(/( erorrProduct)/g, '');
            item.value = isError ? `${$A.get('$Label.c.ERR008')}` : (item.fieldName == 'Hidden' ? $A.get('$Label.c.Data_Condition_Hidden_Text') : component.get(`v.result.${item.fieldName}`));
        });
        guarantorDatas
            .filter(f => f.label == $A.get('$Label.c.ID_Number') && f.value && !isError)
            .forEach(e => {
                /* SCR0527572 Remove markup xxx for id number on front-end */
                /* e.value = component.get('v.isMark') && e.fieldName != 'Hidden' ?
                     'xxx' + `${e.value}`.slice(`${e.value}`.length - 3, `${e.value}`.length) :
                     `${e.value}`*/
               

            });

        component.set('v.fields.HpInformation', hpDatas);
        component.set('v.fields.Guarantor', guarantorDatas);
    },

    handleAlertError: function (component) {
        var helper = this;
        var error = component.get('v.error');
        component.set('v.error.herfLink', '');
        component.set('v.error.retry', '');
        component.set('v.error.message', '');
        component.set('v.error.state', Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isError || error.messages[i].isTimeout, false));

        if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isTimeout, false)) {
            helper.handleRetry(component);
        } else if (Object.keys(error.messages).reduce((l, i) => l || error.messages[i].isError, false)) {
            helper.handleErrorMessage(component);
        }
    },
    handleErrorMessage: function (component, event, helper) {
        var error = component.get('v.error');
        $A.createComponents(
            [
                ["aura:html", {
                    tag: "div",
                    body: `${$A.get('$Label.c.ERR001_ProductHolding')}\n${$A.get('$Label.c.ERR001_DetailBelow')}\n`
                }]
            ].concat(Object.keys(error.messages)
                .filter(f => error.messages[f].isError)
                .reduce((l, productType, index, arrays) => {
                    l.push(["aura:html", {
                        tag: "a",
                        HTMLAttributes: {
                            name: `${productType}Href`,
                            class: 'erorrProduct',
                            onclick: component.getReference('c.handleClickHref')
                        },
                        body: `${error.messages[productType].label}${arrays.length - 1 > index ? ', ':''}`,
                    }]);
                    return l;
                }, [])),
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.message', cmp);
                }
            }
        );
    },
    handleRetry: function (component) {
        var error = component.get('v.error');
        var Product_Holding_Refresh = $A.get('$Label.c.Product_Holding_Refresh');
        var messageTimeoutLink = Product_Holding_Refresh.split('{0}');

        component.set('v.error.message',
            Object.keys(error.messages).some(key => error.messages[key].isError) && Object.keys(error.messages).some(key => error.messages[key].isTimeout) ?
            `${$A.get('$Label.c.Error_Persists_Contact')}` : '');

        $A.createComponents(
            [
                ["aura:html", {
                    tag: "span",
                    body: component.get('v.error.message') ?
                        `${$A.get('$Label.c.ERR001_ProductHoldingV2')} ` : `${$A.get('$Label.c.Auto_Loan_Product_holding_Request_Timeout')} `,
                }],
            ]
            .concat(Object.keys(error.messages)
                .filter(f => error.messages[f].isTimeout)
                .reduce((l, productType, index, arrays) => {
                    l.push(["aura:html", {
                        tag: "a",
                        HTMLAttributes: {
                            name: `${productType}Href`,
                            class: 'erorrProduct',
                            onclick: component.getReference('c.handleClickHref')
                        },
                        body: `${error.messages[productType].label}${arrays.length - 1 > index ? ', ':''}`,
                    }]);
                    return l;
                }, [])),
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.herfLink', cmp);
                }
            }
        );
        $A.createComponents(
            [
                ["aura:html", {
                    tag: "span",
                    body: messageTimeoutLink[0]
                }],
                ["aura:html", {
                    tag: "a",
                    HTMLAttributes: {
                        name: 'refreshView',
                        onclick: component.getReference('c.handleRefreshView')
                    },
                    body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
                }],
                ["aura:html", {
                    tag: "span",
                    body: messageTimeoutLink[1]
                }],
            ],
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.error.retry', cmp);
                }
            }
        );

    },getIsUnmaskData : function(component,helper){
        var action = component.get('c.getUnmaskBalance');
        var returnValue = "{}";
        var jsonData;
        action.setCallback(this,function(response){
            returnValue = response.getReturnValue();
            jsonData = JSON.parse(returnValue);
            component.set('v.unmasked',jsonData);
        });

        $A.enqueueAction(action);
    },


})