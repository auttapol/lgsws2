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
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.message', errMsg);
    },

    displaySubErrorMessage: function (component, title, errMsg, type) {
        component.set('v.error.state', true);
        component.set('v.error.title', title ? title : 'Warning!');
        component.set('v.error.messages.' + type, errMsg);
    },

    startSpinner: function (component) {
        component.set('v.isLoading', true);
    },

    stopSpinner: function (component) {
        component.set('v.isLoading', false);
    },

    replaceAt: function (value, index, replacement) {
        return value.substr(0, index) + replacement + value.substr(index + replacement.length);
    },

    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var tmbCustId = component.get('v.tmbCustId');
        var theme = component.get('v.theme');
        var pageReference = component.get("v.pageReference");

        component.set('v.recordId', recordId ? recordId : (pageReference ? pageReference.state.c__recordId : ''));
        component.set('v.tmbCustId', tmbCustId ? tmbCustId : (pageReference ? pageReference.state.c__TMB_Cust_Id : ''));
        component.set('v.theme', theme ? theme : (pageReference ? pageReference.state.c__theme : ''));

        helper.doWorkspaceAPI(component);
    },

    doWorkspaceAPI: function (component, event, helper) {
        var tabName = $A.get('$Label.c.Product_Holding');
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

    doInitProductSummarized: function (component, event, helper) {
        component.set('v.productSummarized.isLoading', true);
        component.set('v.productSummarized.columns', [{
            label: $A.get("$Label.c.Product_Group"),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'Product_Group'
                },
                title: {
                    fieldName: 'Product_Group'
                },
                name: {
                    fieldName: 'Product_Group'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 300,
            //initialWidth: component.get('v.theme') == 'Theme4t' ? 250 : 300,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Number_of_Product"),
            fieldName: 'Number_of_Product',
            type: 'number',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'center',
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Number_of_Account"),
            fieldName: 'Number_of_Account',
            type: 'number',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'center',
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get("$Label.c.Outstanding"),
            fieldName: 'MarkedOutstanding',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get("$Label.c.Limit_ODLimit"),
            fieldName: 'MarkedODLimit',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                },
                alignment: 'right'
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                m.fixedWidth = window.innerWidth <= 425 ? 110 : null;
            }
            return m;
        }));
    },

    doInitDepositProduct: function (component, event, helper) {
        component.set('v.depositProduct.isLoading', true);
        component.set('v.depositProduct.columns', [{
            label: $A.get('$Label.c.Account_Number'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
                title: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
                name: {
                    fieldName: 'MarkedDepositAccountNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }

            },
            //fixedWidth: component.get('v.theme') == 'Theme4t' ? 200 : 300,
            initialWidth: component.get('v.theme') == 'Theme4t' ? 260 : 280,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1',
                    fieldName: 'ERROR2'

                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                    , fieldName: 'ERROR2'

                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        },
        {
            label: $A.get('$Label.c.Status'),
            fieldName: 'Status',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                    , fieldName: 'ERROR2'

                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Ledger_Balance_Deposit'),
            fieldName: 'MarkedLedgerBalance',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERRORLedger'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get('$Label.c.Avg_Outstanding_MTD'),
            fieldName: 'MarkedAvgOutStanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get('$Label.c.Available_Balance_Deposit'),
            fieldName: 'MarkedOutStanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get('$Label.c.Other'),
            fieldName: 'Other',
            type: 'text',
            //fixedWidth: 60,
            initialWidth: 85,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Has_Joint'),
            fieldName: 'HasJoint',
            type: 'text',
            //fixedWidth: 80,
            initialWidth: 85,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        },
        ].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = ['SubProductGroup', 'ProductName', 'Status'].includes(m.fieldName) ? 160 : 140;
                m.initialWidth = ['SubProductGroup', 'ProductName', 'Status'].includes(m.fieldName) ? 160 : 140;
            }
            return m;
        }));
    },

    doInitCreditCardRDCProduct: function (component, event, helper) {
        component.set('v.creditCardRDCProduct.isLoading', true);
        component.set('v.creditCardRDCProduct.columns', [{
            label: $A.get('$Label.c.Card_Number'),
            type: 'button',
            fieldName: 'MarkedCardNumber',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedCardNumber'
                },
                title: {
                    fieldName: 'MarkedCardNumber'
                },
                name: {
                    fieldName: 'MarkedCardNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 200,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            // fixedWidth: 120,
            //initialWidth: component.get('v.theme') == 'Theme4t' ? 250 : 250,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 250,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 360,
            //initialWidth: component.get('v.theme') == 'Theme4t' ? 300 : 300,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Card_Role'),
            fieldName: 'CardRole',
            type: 'text',
							
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Card_Active_Flag'),
            fieldName: 'CardActive',
            type: 'text',
							
            cellAttributes: {
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Credit_Line'),
            fieldName: 'MaskedCreditLine',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Outstanding_Credit'),
            fieldName: 'MarkedOutstanding',
							
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get('$Label.c.Limit'),
            fieldName: 'MarkedVLimit',
							
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = ['MarkedCardNumber', 'ProductName', ].includes(m.fieldName) ? 180 : (!['MarkedOutstanding', 'MarkedVLimit'].includes(m.fieldName) ? 120 : null);
                m.initialWidth = ['CardRole', 'CardActive', 'MaskedCreditLine', 'MarkedOutstanding', 'MarkedVLimit'].includes(m.fieldName) ? 120 : 200;
            }
            return m;
        }));
    },

    doInitLoanProduct: function (component, event, helper) {
        component.set('v.loanProduct.isLoading', true);
        component.set('v.loanProduct.columns', [
        {
            label: $A.get('$Label.c.Account_Number'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
                title: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
                name: {
                    fieldName: 'MarkedLoanAccountNumber'
                },
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR1'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Status'),
            fieldName: 'Status',
            type: 'text',
            fixedWidth: 100,
            //initialWidth: 80,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Outstanding_Deposit'),
            fieldName: 'MarkedOutstanding',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldMid',
        }, {
            label: $A.get('$Label.c.Limit'),
            fieldName: 'MarkedVLimit',
            type: 'text',
            cellAttributes: {
                alignment: 'right',
                class: {
                    fieldName: 'ERROR2'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Contract_End_Date'),
            fieldName: 'convertedMaturityDate',
            type: 'text',
            //fixedWidth: 120,
            initialWidth: 130,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Has_Co_borrower'),
            fieldName: 'HasCoBorrower',
            type: 'text',
            //fixedWidth: 120,
            initialWidth: 130,
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = ['SubProductGroup', 'ProductName', ].includes(m.fieldName) ? 170 : 115;
                m.initialWidth = ['SubProductGroup', 'ProductName'].includes(m.fieldName) ? 260 : 120;
            }
            return m;
        }));

    },

    doInitBancassuranceProduct: function (component, event, helper) {
        component.set('v.bancassuranceProduct.isLoading', true);
        component.set('v.bancassuranceProduct.columns', [{
            label: $A.get('$Label.c.Policy_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'POLICY_NO'
                },
                title: {
                    fieldName: 'POLICY_NO'
                },
                name: {
                    fieldName: 'POLICY_NO'
                },
            },
            fixedWidth: 180,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'PRODUCT_GROUP',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'POLICY_NAME',
            type: 'text',
            wrapText: true,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Insurance_Company'),
            fieldName: 'COMPANY_NAME',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Opened_Date'),
            fieldName: 'EFFECTIVE_DATE',
            type: 'text',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Status'),
            fieldName: 'STATUS',
            type: 'text',
            fixedWidth: 90,
            //initialWidth: 80,
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Sum_Insure'),
            fieldName: 'SUM_INSURE',
            type: 'number',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.AFYP'),
            fieldName: 'PREMIUM',
            type: 'number',
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Expiry_Date'),
            fieldName: 'EXPIRY_DATE',
            type: 'text',
            fixedWidth: 130,
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = ['PRODUCT_GROUP', 'POLICY_NAME', 'COMPANY_NAME'].includes(m.fieldName) ? 160 : 120;
                m.initialWidth = ['PRODUCT_GROUP', 'POLICY_NAME', 'COMPANY_NAME'].includes(m.fieldName) ? 190 : 120;
            }
            return m;
        }));
    },

    doInitInvestmentProduct: function (component, event, helper) {
        component.set('v.investmentProduct.isLoading', true);
        component.set('v.investmentProduct.columns', [{
            label: $A.get('$Label.c.Unit_Holder_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'UnitHolderNo'
                },
                title: {
                    fieldName: 'UnitHolderNo'
                },
                name: {
                    fieldName: 'UnitHolderNo'
                },
            },
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'UnitHolderNoClass'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Asset_Class'),
            fieldName: 'AssetClass',
            type: 'text',
            cellAttributes: {
                alignment: 'left'
            },
            //fixedWidth: 100,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 180 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 240 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Issuer_Fund_House'),
            fieldName: 'IssuerFundHouse',
            type: 'text',
            cellAttributes: {
                alignment: 'center'
            },
            fixedWidth: 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Number_of_unit'),
            fieldName: 'NumberOfUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.NAV_Unit'),
            fieldName: 'NavUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Cost_of_Investment'),
            fieldName: 'CostOfInvestment',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Average_cost_per_unit_summary'),
            fieldName: 'AverageCostPerUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Market_Value'),
            fieldName: 'MarketValue',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Unrealized_G_L'),
            fieldName: 'UnrealizedGL',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.percent_of_Unrealized_G_L'),
            fieldName: 'UnrealizedGLPerc',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.perc_Weight'),
            fieldName: 'PercentWeight',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = 100;
                m.initialWidth = 115;
            }
            return m;
        }));
        // AP
        component.set('v.investmentProductAP.columns', [{
            label: $A.get('$Label.c.Unit_Holder_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'UnitHolderNo'
                },
                title: {
                    fieldName: 'UnitHolderNo'
                },
                name: {
                    fieldName: 'UnitHolderNo'
                },
            },
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'UnitHolderNoClass'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        },  {
            label: $A.get('$Label.c.Asset_Class'),
            fieldName: 'AssetClass',
            type: 'text',
            cellAttributes: {
                alignment: 'left'
            },
            //fixedWidth: 100,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 120 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Issuer_Fund_House'),
            fieldName: 'IssuerFundHouse',
            type: 'text',
            cellAttributes: {
                alignment: 'center'
            },
            //fixedWidth: 100,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 120 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Number_of_unit'),
            fieldName: 'NumberOfUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.NAV_Unit'),
            fieldName: 'NavUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Cost_of_Investment'),
            fieldName: 'CostOfInvestment',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Average_cost_per_unit_summary'),
            fieldName: 'AverageCostPerUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Market_Value'),
            fieldName: 'MarketValue',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Unrealized_G_L'),
            fieldName: 'UnrealizedGL',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.percent_of_Unrealized_G_L'),
            fieldName: 'UnrealizedGLPerc',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.perc_Weight'),
            fieldName: 'PercentWeight',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = 100;
                m.initialWidth = 100;
            }
            return m;
        }));
        // PT
        component.set('v.investmentProductPT.columns', [{
            label: $A.get('$Label.c.Asset_Class'),
            fieldName: 'AssetClass',
            type: 'text',
            cellAttributes: {
                alignment: 'left'
            },
            //fixedWidth: 100,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 125 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Unit_Holder_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'UnitHolderNo'
                },
                title: {
                    fieldName: 'UnitHolderNo'
                },
                name: {
                    fieldName: 'UnitHolderNo'
                },
            },
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'UnitHolderNoClass'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Issuer_Fund_House'),
            fieldName: 'IssuerFundHouse',
            type: 'text',
            cellAttributes: {
                alignment: 'center'
            },
            fixedWidth: 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Number_of_unit'),
            fieldName: 'NumberOfUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.NAV_Unit'),
            fieldName: 'NavUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Cost_of_Investment'),
            fieldName: 'CostOfInvestment',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Average_cost_per_unit_summary'),
            fieldName: 'AverageCostPerUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Market_Value'),
            fieldName: 'MarketValue',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Unrealized_G_L'),
            fieldName: 'UnrealizedGL',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.percent_of_Unrealized_G_L'),
            fieldName: 'UnrealizedGLPerc',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.perc_Weight'),
            fieldName: 'PercentWeight',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = 100;
                m.initialWidth = 100;
            }
            return m;
        }));
        // LTF
        component.set('v.investmentProductLTF.columns', [{
            label: $A.get('$Label.c.Asset_Class'),
            fieldName: 'AssetClass',
            type: 'text',
            cellAttributes: {
                alignment: 'left'
            },
            //fixedWidth: 100,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 125 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
            isAccessible: 'isAccessibleCusHoldLow',
        }, {
            label: $A.get('$Label.c.Unit_Holder_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'UnitHolderNo'
                },
                title: {
                    fieldName: 'UnitHolderNo'
                },
                name: {
                    fieldName: 'UnitHolderNo'
                },
            },
            //fixedWidth: 180,
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 220 : 180,
            cellAttributes: {
                class: {
                    fieldName: 'UnitHolderNoClass'
                }
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Issuer_Fund_House'),
            fieldName: 'IssuerFundHouse',
            type: 'text',
            cellAttributes: {
                alignment: 'center'
            },
            fixedWidth: 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Number_of_unit'),
            fieldName: 'NumberOfUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.NAV_Unit'),
            fieldName: 'NavUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Cost_of_Investment'),
            fieldName: 'CostOfInvestment',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Average_cost_per_unit_summary'),
            fieldName: 'AverageCostPerUnit',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '4',
                maximumFractionDigits: '4'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Market_Value'),
            fieldName: 'MarketValue',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Unrealized_G_L'),
            fieldName: 'UnrealizedGL',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.percent_of_Unrealized_G_L'),
            fieldName: 'UnrealizedGLPerc',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.perc_Weight'),
            fieldName: 'PercentWeight',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: '2',
                maximumFractionDigits: '2'
            },
            isAccessible: 'isAccessibleCusHoldHig',
        }].map(function (m) {
            if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                //m.fixedWidth = 100;
                m.initialWidth = 100;
            }
            return m;
        }));
    },

    doInitErrorMessageControl: function (component, event, helper) {
        var errorMessageControlObj = {
            showMessage: false,
            someInfoError: false,
            noTmbcust: false,
            message: '',
            productName: {
                OSC: $A.get('$Label.c.Deposit_Product_Details') + ', ' + $A.get('$Label.c.Loan_Product_Details') + ', ' + $A.get('$Label.c.Investment_Product_Details') + ' ',
                Deposit: $A.get('$Label.c.Deposit_Product_Details'),
                CardBal: $A.get('$Label.c.Credit_Card_RDC_Product_Details'),
                Loan: $A.get('$Label.c.Loan_Product_Details'),
                Bancassurance: $A.get('$Label.c.Bancassurance_Product_Details'),
                Investment: $A.get('$Label.c.Investment_Product_Details'),
                retry: ''
            },
            productTag: {
                // OSC: $A.get('$Label.c.Deposit_Product_Details') + ', ' + $A.get('$Label.c.Loan_Product_Details') + ', ' + $A.get('$Label.c.Investment_Product_Details') + ' ',
                Deposit: 'Deposit_Product_Details',
                CardBal: 'Credit_Card_RDC_Product_Details',
                Loan: 'Loan_Product_Details',
                Bancassurance: 'Bancassurance_Product_Details',
                Investment: 'Investment_Product_Details',
            },
            isShowMessage: {
                Snow: false,
                Retry: false,
                Info: false
            },
            messages: {
                Snow: $A.get('$Label.c.ERR001_ProductHolding'),
                Retry: '',
                Info: $A.get('$Label.c.INT_Investment_Incomplete_Info'),
                tryContact: $A.get('$Label.c.Error_Persists_Contact'),
            },
            timeout: {
                OSC: false,
                Deposit: false,
                CardBal: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
            },
            error: {
                OSC: false,
                Deposit: false,
                CardBal: false,
                Loan: false,
                Bancassurance: false,
                Investment: false,
            },
            retry: {
                OSC: false,
                CardBal: false,
                Bancassurance: false
            },
            products: [],
            productErrors: {},
            noAuthorized: false,
            hrefList: ''
        }
        component.set("v.errorMessageControl", errorMessageControlObj);
    },

    getSuitability: function (component) {
        return component.get('v.account.RTL_Suitability__c') ? component.get('v.account.RTL_Suitability__c') : '0';
    },

    getInvestmentModel: function (component, event, helper) {
        var suitability = helper.getSuitability(component);
        if (suitability != '0') {
            var action = component.get('c.getInvestmentModel');
            action.setParams({
                "suitability": suitability
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var graphPTRecommend = [];
                    for (let i = 0; i < result.length; i++) {
                        var eachAsset = [];
                        eachAsset.push(result[i].Asset_Class__c);
                        eachAsset.push(result[i].FUND_TARGET_WGT__c);
                        graphPTRecommend.push(eachAsset);
                    }

                    component.set('v.investmentPTGraphRecommend', graphPTRecommend);
                }
            });
            $A.enqueueAction(action);
        }
    },

    getTMBCustID: function (component) {
        return component.get('v.account.TMB_Customer_ID_PE__c') ? component.get('v.account.TMB_Customer_ID_PE__c') : component.get('v.tmbCustId');
    },

    isEmployee: function (component) {
        return component.get('v.account.RTL_Is_Employee__c') ? true : false;
    },

    resetData: function (component) {
        component.set('v.depositProduct.datas', []);
        component.set('v.creditCardRDCProduct.datas', []);
        component.set('v.loanProduct.datas', []);
        component.set('v.bancassuranceProduct.datas', []);
        component.set('v.investmentProduct.datas', []);
    },

    resetDataOSC: function (component) {
        component.set('v.depositProduct.datas', []);
        component.set('v.loanProduct.datas', []);
        // component.set('v.bancassuranceProduct.datas', []);
        component.set('v.investmentProduct.datas', []);
    },

    setIsLoadingProduct: function (component, status) {
        component.set('v.productSummarized.isLoading', status);
        component.set('v.depositProduct.isLoading', status);
        component.set('v.creditCardRDCProduct.isLoading', status);
        component.set('v.loanProduct.isLoading', status);
        component.set('v.bancassuranceProduct.isLoading', status);
        component.set('v.investmentProduct.isLoading', status);
    },

    setIsLoadingProductOSC: function (component, status) {
        component.set('v.productSummarized.isLoading', status);
        component.set('v.depositProduct.isLoading', status);
        component.set('v.loanProduct.isLoading', status);
        // component.set('v.bancassuranceProduct.isLoading', status);
        component.set('v.investmentProduct.isLoading', status);
    },

    checkIsSuccess: function (component) {
        component.set('v.isSuccess', !(
            component.get('v.depositProduct.isLoading') ||
            component.get('v.creditCardRDCProduct.isLoading') ||
            component.get('v.loanProduct.isLoading') ||
            component.get('v.bancassuranceProduct.isLoading') ||
            component.get('v.investmentProduct.isLoading') || [...new Set(component.get('v.errorMessageControl.products'))].reduce((l, productType) => l || (component.find(productType) && component.find(productType).get('v.isLoading')), false)
        ));
    },

    checkIsShowError: function (component) {
        component.set('v.error.state', (
            component.get('v.error.message') != '' ||
            component.get('v.error.messages.OSC01') != '' ||
            component.get('v.error.messages.CardBal') != ''
        ));
    },

    checkIsShowErrorAfterChoice: function (component, errorObj) {
        component.set('v.error.state', (
            errorObj.isShowMessage.Info ||
            errorObj.isShowMessage.Retry ||
            errorObj.isShowMessage.Snow ||
            errorObj.noAuthorized
        ));
    },

    getAccessibleCusHold: function (component, event, helper) {
        var action = component.get('c.getAccessibleCusHold');
        action.setParams({
            'accountId': component.get('v.recordId')
        });

        /*
        BAU Issue - 00009607 (INC0116910)
        Fix by - Narathip IIG 20200407
        action.setStorable(); -> remove for fix bug caching client browser
        */
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // handler on change to callout service initial
                component.set('v.accessibleCusHold', result);
                var accessibleCusHold = component.get('v.accessibleCusHold');
                [
                    'v.productSummarized.columns',
                    'v.depositProduct.columns',
                    'v.creditCardRDCProduct.columns',
                    'v.loanProduct.columns',
                    'v.bancassuranceProduct.columns',
                    'v.investmentProduct.columns',
                    'v.investmentProductAP.columns',
                    'v.investmentProductPT.columns',
                    'v.investmentProductLTF.columns',
                ].forEach(function (v) {
                    // default value for product type (header) configiuation
                    if (!component.get(v)) {
                        switch (v) {
                            case 'v.productSummarized.columns':
                                helper.doInitProductSummarized(component, event, helper);
                                break;
                            case 'v.depositProduct.columns':
                                helper.doInitDepositProduct(component, event, helper);
                                break;
                            case 'v.creditCardRDCProduct.columns':
                                helper.doInitCreditCardRDCProduct(component, event, helper);
                                break;
                            case 'v.loanProduct.columns':
                                helper.doInitLoanProduct(component, event, helper);
                                break;
                            case 'v.bancassuranceProduct.columns':
                                helper.doInitBancassuranceProduct(component, event, helper);
                                break;
                            case 'v.investmentProduct.columns':
                                helper.doInitInvestmentProduct(component, event, helper);
                                break;
                            default:
                                break;
                        }
                    }

                    if (component.get(v)) {
                        component.set(v, component.get(v).map(function (m) {
                            m.fieldName = accessibleCusHold[m.isAccessible] ? m.fieldName : 'Hidden';
                            m.type = m.fieldName == 'Hidden' ? 'text' : m.type;
                            return m;
                        }));
                    }
                });
                // handler on initial summary data
                component.set('v.productSummarized.datas', helper.parseSummarizedProduct(component));
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
            }
        });
        $A.enqueueAction(action);
    },

    callProductOSC02: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getProduct');
            action.setParams({
                'endpoint': 'callout:OSC02',
                'callback': 'callbackOSC02',
                'body': JSON.stringify({
                    "GetDepositAccountRequest": {
                        "RMID": helper.getTMBCustID(component).substring(12),
                        "FIIdent": product.Fiident,
                        "AccountNumber": product.DepositAccountNumber,
                        "AccountType": product.AccountType,
                        "ProductType": product.ProductType,
                    }
                }),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result && result.DepositeProduct && !['404', '500'].includes(result.StatusCode)) {
                        product.isError = result.GetDepositAccountResponse.AcctInqRs.Status.Severity.includes('Error') ? true : false;
                        product.MarkedLedgerBalance = !product.isError ? result.DepositeProduct.MarkedLedgerBalance : $A.get('$Label.c.ERR008');
                        product.MarkedAvgOutStanding = !product.isError ? result.DepositeProduct.MarkedAvgOutStanding : $A.get('$Label.c.ERR008');
                        product.MarkedOutStanding = !product.isError ? result.DepositeProduct.MarkedOutStanding : $A.get('$Label.c.ERR008');
                        product.ODLimit = result.DepositeProduct.ODLimit;
                        product.OutStanding = result.DepositeProduct.OutStanding;
                        product.LedgerBalance = result.DepositeProduct.LedgerBalance;
                        // unmasking set avgOutStanding
                        product.AvgOutStanding = result.DepositeProduct.AvgOutStanding;
                        product.ERROR1 = !product.isError ? '' : 'notFound';
                        product.ERROR2 = !product.isError ? '' : 'notFound';
                        product.SeqGrp = product.SeqGrp ? product.SeqGrp : 'OTHERS';
                        product.productCodeMainbank = !product.isError ? result.GetDepositAccountDetailResponse.Result.DepositAccount.ProductCode : '';

                        product.link = '/one/one.app#' + btoa(JSON.stringify({
                            "componentDef": "c:DepositProductDetailsView",
                            "attributes": {
                                "recordId": component.get('v.account.Id'),
                                "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                'AccountNumber': product.DepositAccountNumber,
                                'FIIdent': product.Fiident,
                                "AccountType": product.AccountType ? product.AccountType : product.DepositProductCode,
                                "ProductType": product.ProductType,
                                'product': btoa(encodeURIComponent(JSON.stringify({
                                    'SeqGrp': product.SeqGrp,
                                    'Fiident': product.Fiident,
                                    'AccountNumber': product.DepositAccountNumber,
                                    'AccountType': product.DepositProductCode,
                                    'ProductType': product.ProductType,
                                    'DepositAccountNumber': product.DepositAccountNumber,
                                    'MarkedDepositAccountNumber': product.MarkedDepositAccountNumber,
                                    'SubProductGroup': product.SubProductGroup,
                                    'ProductName': product.ProductName,
                                    'HasJoint': product.HasJoint,
                                })))
                            }
                        }));
                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        product.ERROR1 = 'retry DepositAccount';
                        product.ERROR2 = '401';
                        product.isError = true;

                    } else {
                        product.MarkedLedgerBalance = '';
                        product.SeqGrp = 'OTHERS';
                        product.ERROR1 = 'notFound';
                        product.ERROR2 = 'notFound';
                        product.isError = true;
                        product.ProductName = '';
                        product.SubProductGroup = $A.get('$Label.c.ERR008');
                        product.Status = '';
                        product.HasJoint = '';

                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Deposit', true);
                        } else {
                            component.set('v.errorMessageControl.error.Deposit', true);
                        }
                    }

                    product.result = result;
                    component.set('v.depositProduct.datas', component.get('v.depositProduct.datas'));
                    res(product);

                } else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log('get error', error.message);
                    });
                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });
            if (product.ERROR1 != 'notFound') {
                $A.enqueueAction(action);
            } else {
                product.MarkedLedgerBalance = '';
                product.SeqGrp = 'OTHERS';
                product.isError = true;
                product.SubProductGroup = $A.get('$Label.c.ERR008');
                res(product)
            }
        }));
    },
    //M8
    callGetCreditCardsBalance: function (component, helper, more_records, search_keys, creditcard_list, round) {
        return new Promise($A.getCallback(function (res, rej) {
            let requestBody = {
                "query": {
                    "rm_id": helper.getTMBCustID(component),
                    "more_records": more_records,
                    "search_keys": search_keys,
                    "user_interface": "",
                }
            };
            var action = component.get('c.getProductSCSCreditCard');
            action.setParams({
                'endpoint': 'callout:get_cards_balances',
                'body': JSON.stringify(requestBody),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var errorCreditBal = {
                    ERROR1: 'notFound',
                    MarkedOutstanding: '-',
                    MarkedVLimit: '-',
                    CreditLine: '-',
                    SubProductGroup: $A.get('$Label.c.ERR008'),
                    isError: true,
                }
                var state = response.getState();
                try {
                    var result = response.getReturnValue();
                    var responseText = result;
                    responseText = responseText + 'String';
                    if (creditcard_list == null) {
                        creditcard_list = [];
                    }
                    component.set('v.creditCardRDCProduct.isLoading', false);
                    if (component.isValid() && state === 'SUCCESS' && !responseText.includes('UNABLE_TO_LOCK_ROW')) {
                        if (result.error_status) {
                            if (!helper.errorCodeSCSIncludes('CIF0003', result.error_status) && !helper.errorCodeSCSIncludes('500', result.error_status)) {
                                creditcard_list.push(errorCreditBal);
                            }
                            component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                            rej(creditcard_list);
                        } else if (result.Status) {
                            if (result.Status.StatusCode == 500 && result.Status.StatusDesc.includes('Timeout')) {
                                component.set('v.errorMessageControl.timeout.CardBal', true);
                            } else if (result.Status.StatusCode == 401 && round < component.get("v.numOfRetryTime")) {
                                component.set('v.creditCardRDCProduct.isLoading', true);
                                round++;
                                window.setTimeout(
                                    $A.getCallback(function () {
                                        helper.callGetCreditCardsBalance(component, helper, more_records, search_keys, creditcard_list, round);
                                    }), component.get("v.retrySetTimeOut")
                                );
                            } else {
                                component.set('v.creditCardRDCProduct.isLoading', false);
                                component.set('v.errorMessageControl.error.CardBal', true);
                            }
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                            rej(creditcard_list);
                        } else {
                            if (result && result.CreditCardAccounts && result.CreditCardAccounts.length > 0) {
                                var CreditCardAccBalAccs = result.CreditCardAccounts;
                                component.set('v.creditCardRDCProduct.isLoading', false);
                                CreditCardAccBalAccs.forEach((e, i) => {
                                    if (e.isError === false) {
                                        // e.CardRole = $A.get('$Label.c.Loading');
                                        // e.CardPLoan = '';
                                        // e.CardActive = '';
                                        e.ERROR1 = '';
                                        e.ERROR2 = !e.isError ? '' : 'notFound';
                                        e.account_id = result.result.credit_card[i].account_id;
                                        e.link = '/one/one.app#' + btoa(JSON.stringify({
                                            "componentDef": "c:CreditCardDetailsView",
                                            "attributes": {
                                                "recordId": component.get('v.account.Id'),
                                                "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                                'CardNumber': e.CardNumber,
                                                'CreditCardType': e.CreditCardType,
                                                'account_id': e.account_id,
                                                'product': btoa(encodeURIComponent(JSON.stringify({
                                                    'SeqGrp': e.SeqGrp,
                                                    'CardNumber': e.CardNumber,
                                                    'CreditCardType': e.CreditCardType,
                                                    'MarkedCardNumber': e.MarkedCardNumber,
                                                    'SubProductGroup': e.SubProductGroup,
                                                    'ProductName': e.ProductName,
                                                    'ProductType': e.ProductType,
                                                    // 'UsageStatus': product.UsageStatus,
                                                    // 'Status': product.Status,
                                                    'MarkedOutstanding': e.MarkedOutstanding,
                                                    'MarkedVLimit': e.MarkedVLimit,
                                                    'VLimit': e.VLimit,
                                                    'Outstanding': e.Outstanding,
                                                }))),
                                            }
                                        }));
                                        // if (e.isOther === true) {
                                        //     e.ERROR1 = 'notFound';
                                        //     e.isError = true;
                                        //     // e.SubProductGroup = $A.get('$Label.c.ERR008');
                                        //     // e.SeqGrp = 'OTHERS';
                                        // }
                                    } else {
                                        // e.SeqGrp = 'OTHERS';
                                        e.ERROR1 = 'notFound';
                                        e.isError = true;
                                        // e.ERROR2 = 'notFound';
                                        // e.ProductName = '';
                                        e.SubProductGroup = $A.get('$Label.c.ERR008');
                                        // e.Status = '';
                                    }
                                    creditcard_list.push(e);
                                });
                                component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                                res(creditcard_list);
                            } else if (!result) {
                                creditcard_list.push(errorCreditBal);
                                component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                                rej(creditcard_list);
                            }
                            if (result.result && result.result.more_records && result.result.more_records == 'Y' && result.result.search_keys != '') {
                                component.set('v.creditCardRDCProduct.isLoading', true);
                                helper.callGetCreditCardsBalance(component, helper, result.result.more_records, result.result.search_keys, creditcard_list, round);
                                component.set('v.creditCardRDCProduct.isLoading', false);
                                res(creditcard_list);
                            }
                            if (result.includes('Timeout') || result.includes('เรียกดูข้อมูลอีกครั้ง')) {
                                component.set('v.errorMessageControl.timeout.CardBal', true);
                                rej(creditcard_list);
                            }
                            if (result.includes('Response Decrypt is Null')) {
                                component.set('v.errorMessageControl.error.CardBal', true);
                                rej(creditcard_list);
                            }
                        }
                    } else if ((response.getReturnValue() == null || responseText.includes('UNABLE_TO_LOCK_ROW')) && !component.get('v.isAutoRetryCreditCard')) {
                        component.set('v.isAutoRetryCreditCard', true);
                        // let temCreditIsLoading = component.get('v.creditCardRDCProduct.isLoading');
                        // helper.setIsLoadingProduct(component, true);
                        // component.set('v.creditCardRDCProduct.isLoading', temCreditIsLoading);
                        component.set('v.creditCardRDCProduct.isLoading', true);
                        helper.callGetCreditCardsBalance(component, helper, more_records, search_keys, creditcard_list, round);
                        component.set('v.creditCardRDCProduct.isLoading', false);
                        res('Retry First time');
                    } else {
                        creditcard_list.push(errorCreditBal);
                        component.set('v.creditCardRDCProduct.isLoading', false);
                        component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                        rej('UNSUCCESS');
                    }
                } catch (error) {
                    try {
                        if (response.getReturnValue() && !['Read timed out', 'timeout', 'Timeout', 'พบปัญหาในการเรียกดูข้อมูลครั้งนี้'].some(substring => response.getReturnValue().includes(substring))) {
                            creditcard_list.push(errorCreditBal);
                            component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                        } else {
                            component.set('v.errorMessageControl.timeout.CardBal', true);
                            helper.displaySubErrorMessage(component, 'Warning!', '', 'CardBal');
                        }
                    } catch (error2) {
                        console.log('Callback credit cards Balance is error2 ', error2);
                    }

                    console.log('Callback credit cards Balance is error ', error);
                    rej(error);
                }
            });
            $A.enqueueAction(action);
        }));

    },
    //M8
    GetCreditCard: function (component, helper, more_records, search_keys, creditcard_list, round) {
        /*return new Promise($A.getCallback(function (res, rej) {
            var accessibleCusHold = component.get('v.accessibleCusHold');
            if (accessibleCusHold.isAccessibleCusHoldHig || accessibleCusHold.isAccessibleCusHoldMid || accessibleCusHold.isAccessibleCusHoldLow) {
                try {
                    helper.callGetCreditCardsBalance(component, helper, 'N', '', null, round)
                        .then(function (callProduct) {
                            return 'Success';
                        },
                            function (error) {
                                return 'Unsuccess';
                            }
                        )
                        .catch(function (error) {
                            return 'Error';
                        })
                        .then(function (PromiseMessage) {
                            // component.set('v.creditCardRDCProduct.isLoading', false);
                            helper.checkIsSuccess(component);
                            helper.calculateSummarizedProduct(component, helper);
                            helper.choiceErrorHandle(component, helper);
                            res('Pass');
                        });
                } catch (error) {
                    helper.choiceErrorHandle(component, helper);
                    rej('Fail');
                }
            }
        }))*/
        component.set('v.creditCardRDCProduct.isLoading', true);

        var accessibleCusHold = component.get('v.accessibleCusHold');

        if (accessibleCusHold && (accessibleCusHold.isAccessibleCusHoldHig || accessibleCusHold.isAccessibleCusHoldMid || accessibleCusHold.isAccessibleCusHoldLow)) {

            let requestBody = {
                "query": {
                    "rm_id": helper.getTMBCustID(component),
                    "more_records": more_records,
                    "search_keys": search_keys,
                    "user_interface": '',
                }
            };

            var action = component.get('c.getProductSCSCreditCard');

            action.setParams({
                'endpoint': 'callout:get_cards_balances',
                'body': JSON.stringify(requestBody),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var errorCreditBal = {
                    ERROR1: 'notFound',
                    MarkedOutstanding: '-',
                    MarkedVLimit: '-',
                    CreditLine: '-',
                    SubProductGroup: $A.get('$Label.c.ERR008'),
                    isError: true,
                }

                var state = response.getState();
                var result = response.getReturnValue();

                var responseText = result;

                responseText = responseText + 'String';

                if (creditcard_list == null) {
                    creditcard_list = [];
                }

                if (component.isValid() && state === 'SUCCESS' && !responseText.includes('UNABLE_TO_LOCK_ROW')) {
                    if (result.error_status) {
                        component.set('v.creditCardRDCProduct.isLoading', false);

                        if (!helper.errorCodeSCSIncludes('CIF0003', result.error_status) && !helper.errorCodeSCSIncludes('500', result.error_status)) {
                            creditcard_list.push(errorCreditBal);
                        }

                        component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                    } else if (result.Status) {
                        if (result.Status.StatusCode == 500 && result.Status.StatusDesc.includes('Timeout')) {
                            component.set('v.creditCardRDCProduct.isLoading', false);
                            component.set('v.errorMessageControl.timeout.CardBal', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                        } else if (result.Status.StatusCode == 401 && round < component.get("v.numOfRetryTime")) {

                            round++;

                            setTimeout(function () {
                                helper.GetCreditCard(component, helper, 'N', '', null, round
                                )
                            }, component.get("v.retrySetTimeOut"));
                        } else {
                            component.set('v.creditCardRDCProduct.isLoading', false);
                            component.set('v.errorMessageControl.error.CardBal', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                        }
                    } else {
                        if (result && result.CreditCardAccounts && result.CreditCardAccounts.length > 0) {
                            component.set('v.creditCardRDCProduct.isLoading', false);

                            var CreditCardAccBalAccs = result.CreditCardAccounts;

                            CreditCardAccBalAccs.forEach((e, i) => {
                                if (e.isError === false) {
                                    e.ERROR1 = '';
                                    e.ERROR2 = !e.isError ? '' : 'notFound';
                                    e.account_id = result.result.credit_card[i].account_id;
                                    e.link = '/one/one.app#' + btoa(JSON.stringify({
                                        "componentDef": "c:CreditCardDetailsView",
                                        "attributes": {
                                            "recordId": component.get('v.account.Id'),
                                            "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                            'CardNumber': e.CardNumber,
                                            'CreditCardType': e.CreditCardType,
                                            'account_id': e.account_id,
                                            'product': btoa(encodeURIComponent(JSON.stringify({
                                                'SeqGrp': e.SeqGrp,
                                                'CardNumber': e.CardNumber,
                                                'CreditCardType': e.CreditCardType,
                                                'MarkedCardNumber': e.MarkedCardNumber,
                                                'SubProductGroup': e.SubProductGroup,
                                                'ProductName': e.ProductName,
                                                'ProductType': e.ProductType,
                                                'MarkedOutstanding': e.MarkedOutstanding,
                                                'MarkedVLimit': e.MarkedVLimit,
                                                'VLimit': e.VLimit,
                                                'Outstanding': e.Outstanding,
                                            }))),
                                        }
                                    }));
                                } else {
                                    e.ERROR1 = 'notFound';
                                    e.isError = true;
                                    e.SubProductGroup = $A.get('$Label.c.ERR008');
                                }
                                creditcard_list.push(e);
                            });
                            component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));

                        } else if (!result) {
                            component.set('v.creditCardRDCProduct.isLoading', false);
                            creditcard_list.push(errorCreditBal);
                            component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                        }

                        if (result.result && result.result.more_records && result.result.more_records == 'Y' && result.result.search_keys != '') {
                            helper.GetCreditCard(component, helper, result.result.more_records, result.result.search_keys, creditcard_list, round);
                        }

                        if (responseText.includes('Timeout') || responseText.includes('เรียกดูข้อมูลอีกครั้ง')) {
                            component.set('v.creditCardRDCProduct.isLoading', false);
                            component.set('v.errorMessageControl.timeout.CardBal', true);
                        }

                        if (responseText.includes('Response Decrypt is Null')) {
                            component.set('v.creditCardRDCProduct.isLoading', false);
                            component.set('v.errorMessageControl.error.CardBal', true);
                        }
                    }
                } else if ((response.getReturnValue() == null || responseText.includes('UNABLE_TO_LOCK_ROW')) && !component.get('v.isAutoRetryCreditCard')) {
                    component.set('v.isAutoRetryCreditCard', true);
                    helper.GetCreditCard(component, helper, more_records, search_keys, creditcard_list, round);
                } else {
                    component.set('v.creditCardRDCProduct.isLoading', false);
                    creditcard_list.push(errorCreditBal);
                    component.set('v.creditCardRDCProduct.datas', helper.sortCreditRDCProduct(helper.parseCreditCardSCSProduct(component, creditcard_list,helper)));
                }
            });

            $A.enqueueAction(action);
        }
    },

	//Get Bancassurance
    GetBancassurance: function (component, helper, round) {
        var accessibleCusHold = component.get('v.accessibleCusHold');

        if (accessibleCusHold && (accessibleCusHold.isAccessibleCusHoldHig || accessibleCusHold.isAccessibleCusHoldMid || accessibleCusHold.isAccessibleCusHoldLow)) {

            /*var BA_Datas = [{
                AFYP: 0,
                Params: "",
                PolicyNo: "",
                SumInsure: 0,
                convertedExpiryDate: "",
                convertedOpenedDate: ""
            }];*/

            var action = component.get('c.getProduct');

            action.setParams({
                'endpoint': 'callout:OSC05_List',
                'callback': 'callbackOSC05',
                'body': JSON.stringify({
                    "GetBancassuranceAccountRequest": {
                        "RMID": helper.getTMBCustID(component).substring(12),
                    }
                }),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var DataSets = result.GetBancassuranceAccountResponse && result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse ? result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets : [];

                    if (result.StatusCode && (result.StatusCode != "200" || result.StatusCode != 200)) {
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Bancassurance', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                            
                            let dataList = [];
                            let data = DataSets.find(function (f) {
                                return f;
                            });
                            if(DataSets.length > 0 || data != undefined){
                                dataList.push(data);
                            }
                            component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                            component.set('v.bancassuranceProduct.isLoading', false);
                            
                            helper.checkIsSuccess(component);
                            helper.calculateSummarizedProduct(component, helper);
                            helper.choiceErrorHandle(component, helper);

                        } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                            round++;

                            setTimeout(() => {
                                helper.GetBancassurance(component, helper, round);
                            }, component.get("v.retrySetTimeOut"));

                        } else {
                            component.set('v.errorMessageControl.error.Bancassurance', true);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);

                            let dataList = [];
                            let data = DataSets.find(function (f) {
                                return f;
                            });

                            if(DataSets.length > 0 || data != undefined){
                                dataList.push(data);
                            }
                            component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                            component.set('v.bancassuranceProduct.isLoading', false);
                            
                            helper.checkIsSuccess(component);
                            helper.calculateSummarizedProduct(component, helper);
                            helper.choiceErrorHandle(component, helper);

                            // component.set('v.bancassuranceProduct.isLoading', false);
                            // component.set('v.errorMessageControl.error.Bancassurance', true);

                            // helper.choiceErrorHandle(component, helper);
                            // helper.displayErrorMessage(component, 'Warning!', result.Message);
                        }

                    } else {

                        let dataList = [];
                        let data = DataSets.find(function (f) {
                            return f;
                        });
                        if(DataSets.length > 0 || data != undefined){
                            DataSets.forEach(each => {
                                dataList.push(each);
                            });
                        }
                        component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                        component.set('v.bancassuranceProduct.isLoading', false);
                        
                        helper.checkIsSuccess(component);
                        helper.calculateSummarizedProduct(component, helper);
                        helper.choiceErrorHandle(component, helper);
                    }

                    /*let dataList = [];
                    let data = DataSets.find(function (f) {
                        return f;
                    });

                    if(DataSets.length > 0 || data != undefined){
                       dataList.push(data);
                    }
                    
                    component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, dataList));
                    component.set('v.bancassuranceProduct.isLoading', false);
                    
                    helper.checkIsSuccess(component);
                    helper.calculateSummarizedProduct(component, helper);
                    helper.choiceErrorHandle(component, helper);*/


                } else {
                    var errors = response.getError();
                    
                    /*errors.forEach(function (error) {
                    });

                    rej(errors.find(function (f) {
                        return f;
                    }).message);*/

                    console.log('Error: BancassuranceAccount', errors);
                    component.set('v.bancassuranceProduct.isLoading', false);
                    helper.choiceErrorHandle(component, helper);
                }
            });

            $A.enqueueAction(action);

            //     Promise.all(BA_Datas.reduce(function (l, i) {
            //         l.push(helper.callProductOSC05(component, helper, round));
            //         return l;
            //     }, [])).then(function (products) {
            //         component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, products.find(function (f) {
            //             return f;
            //         })));
            //         //component.set('v.bancassuranceProduct.isLoading', false);
            //         helper.checkIsSuccess(component);
            //         helper.calculateSummarizedProduct(component, helper);
            //        helper.choiceErrorHandle(component, helper);
            //     },
            //         function (error) {
            //             component.set('v.bancassuranceProduct.isLoading', false);
            //            
            //             helper.choiceErrorHandle(component, helper);
            //         }).catch(function (error) {
            //             helper.choiceErrorHandle(component, helper);
            //         });
        } //else {

            //component.set('v.bancassuranceProduct.isLoading', false);
            //component.set('v.errorMessageControl.error.Bancassurance', true);

            //helper.choiceErrorHandle(component, helper);
        //}
    },

    callProductOSC04: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getProduct');

            action.setParams({
                'endpoint': 'callout:OSC04',
                'callback': 'callbackOSC04',
                'body': JSON.stringify({
                    "GetLoanAccountRequest": {
                        "RMID": helper.getTMBCustID(component).substring(12),
                        "FIIdent": product.Fiident,
                        "AccountNumber": product.AccountNumber,
                        "AccountType": product.AccountType,
                        "ProductType": ""
                    }
                }),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result && !['404', '500'].includes(result.StatusCode) && result.LoanAccount) {
                        var markedVLimit = !product.isError && (result.LoanAccount.VLimit || result.LoanAccount.VLimit === 0) ? result.LoanAccount.VLimit.toLocaleString('en-US', {
                            style: 'decimal',
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 0
                        }) : $A.get('$Label.c.ERR008');
                        product.isError = result.GetLoanAccountResponse.AcctInqRs.Status.Severity.includes('Error') ? true : false;
                        product.VLimit = result.LoanAccount.VLimit;
                        product.Outstanding = result.LoanAccount.Outstanding;
                        product.MuturityDate = result.LoanAccount.MuturityDate;
                        product.MarkedVLimit = helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : markedVLimit;
                        product.MarkedOutstanding = !product.isError ? helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') :result.LoanAccount.MarkedOutstanding : $A.get('$Label.c.ERR008');


                        product.convertedMaturityDate = result.LoanAccount.convertedMaturityDate;
                        product.ERROR2 = !product.isError ? '' : 'notFound';
                        product.SeqGrp = product.SeqGrp ? product.SeqGrp : 'OTHERS';

                        product.link = '/one/one.app#' + btoa(JSON.stringify({
                            "componentDef": "c:LoanProductDetailsView",
                            "attributes": {
                                "recordId": component.get('v.account.Id'),
                                "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                "RMID": component.get('v.account.TMB_Customer_ID_PE__c').substring(12),
                                "Fiident": product.Fiident,
                                "AccountNumber": product.AccountNumber ? product.AccountNumber : product.LoanAccountNumber,
                                "AccountType": product.AccountType ? product.AccountType : product.ProductType,
                                "ProductType": "",
                                "product": btoa(encodeURIComponent(JSON.stringify({
                                    'Fiident': product.Fiident,
                                    'AccountNumber': product.AccountNumber,
                                    'AccountType': product.AccountType,
                                    'MarkedLoanAccountNumber': product.MarkedLoanAccountNumber,
                                    'SubProductGroup': product.SubProductGroup,
                                    'ProductName': product.ProductName,
                                    'Status': product.Status,
                                    'VLimit': product.VLimit,
                                    'Outstanding': product.Outstanding,
                                    'MarkedOutstanding': product.MarkedOutstanding,
                                    'MarkedVLimit': product.MarkedVLimit,
                                    'convertedMaturityDate': product.convertedMaturityDate,
                                    'MuturityDate': product.MuturityDate,
                                    'HasCoBorrower': product.HasCoBorrower,
                                })))
                            }
                        }));
                    } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                        //product.ERROR1 = 'retry';
                        product.ERROR1 = 'retry LoanAccount';
                        product.ERROR2 = '401';
                        product.isError = true;
                    } else {
                        product.MarkedOutstanding = '';
                        product.SeqGrp = 'OTHERS';
                        product.ERROR1 = 'notFound';
                        product.ERROR2 = 'notFound';
                        product.isError = true;
                        product.ProductName = '';
                        product.SubProductGroup = $A.get('$Label.c.ERR008');
                        product.Status = '';
                        product.HasCoBorrower = '';
                        // if (result && ['500', '2000', 2000].includes(result.StatusCode)) {
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Loan', true);
                        } else {
                            component.set('v.errorMessageControl.error.Loan', true);
                        }
                    }

                    product.result = result;
                    component.set('v.loanProduct.datas', component.get('v.loanProduct.datas'));
                    res(product);

                } else {
                    var errors = response.getError();

                    errors.forEach(function (error) {
                        console.log(error.message)
                    });

                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });

            if (product.ERROR1 != 'notFound') {
                $A.enqueueAction(action);
            } else {
                product.MarkedOutstanding = '';
                product.SeqGrp = 'OTHERS';
                product.isError = true;
                product.SubProductGroup = $A.get('$Label.c.ERR008');
                res(product)
            }
        }));
    },

    callProductOSC05: function (component, helper, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getProduct');
            action.setParams({
                'endpoint': 'callout:OSC05_List',
                'callback': 'callbackOSC05',
                'body': JSON.stringify({
                    "GetBancassuranceAccountRequest": {
                        "RMID": helper.getTMBCustID(component).substring(12),
                    }
                }),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var DataSets = result.GetBancassuranceAccountResponse && result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse ? result.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets : [];
                    component.set('v.bancassuranceProduct.isLoading', false);
                    if (result.StatusCode && (result.StatusCode != "200" || result.StatusCode != 200)) {
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Bancassurance', true);
                            // component.set('v.errerrorMessageControl.messages.Retry', result.Message);          
                        } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                            component.set('v.bancassuranceProduct.isLoading', true);
                            round++;
                            window.setTimeout(
                                $A.getCallback(function () {
                                    helper.callProductOSC05(component, helper, round)
                                }), component.get("v.retrySetTimeOut")
                            );
                        } else {
                            component.set('v.bancassuranceProduct.isLoading', false);
                            component.set('v.errorMessageControl.error.Bancassurance', true);
                            // component.set('v.errerrorMessageControl.messages.Snow', result.Message);
                        }
                        helper.displayErrorMessage(component, 'Warning!', result.Message);
                    }
                    res(DataSets.length > 0 ? DataSets : []);
                } else {
                    var errors = response.getError();
                    errors.forEach(function (error) {
                        console.log(error.message)
                    });
                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                    component.set('v.bancassuranceProduct.isLoading', false);
                }
            });
            $A.enqueueAction(action);
        }));
    },

    callProductOSC06List: function (component, helper, product, round) {
        return new Promise($A.getCallback(function (res, rej) {
            var action = component.get('c.getProduct');

            action.setParams({
                'endpoint': 'callout:OSC06_List',
                'callback': 'callbackOSC06List',
                'body': JSON.stringify({
                    "GetInvestmentAccountRequest": {
                        "UnitHolderNo": product.UnitHolderNo
                    }
                }),
                'tmbCustId': helper.getTMBCustID(component),
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    var UnitHolderNo = product.UnitHolderNo;
                    var productList = [];

                    if (result && !['404', '500'].includes(result.StatusCode) && result.GetInvestmentAccountResponse && result.InvestmentAccount.length > 0) {
                        productList = result.InvestmentAccount.map(function (productObj) {
                            productObj.isError = !productObj.UnitHolderNo;
                            productObj.SeqGrp = !productObj.isError && productObj.ProductName != '#N/A' ? productObj.SeqGrp : 'OTHERS';
                            productObj.UnitHolderNo = !productObj.isError ? productObj.UnitHolderNo : UnitHolderNo;
                            productObj.FundCode = !productObj.isError ? productObj.FundCode : '';
                            productObj.ProductName = !productObj.isError ? productObj.ProductName : $A.get('$Label.c.ERR008');
                            productObj.AssetClass = !productObj.isError ? productObj.AssetClass : ''
                            productObj.IssuerFundHouse = !productObj.isError ? productObj.IssuerFundHouse : ''

                            productObj.NumberOfUnit = !productObj.isError ? productObj.NumberOfUnit : ''
                            productObj.NavUnit = !productObj.isError ? productObj.NavUnit : ''
                            productObj.CostOfInvestment = !productObj.isError ? productObj.CostOfInvestment : ''
                            productObj.AverageCostPerUnit = !productObj.isError ? parseFloat(productObj.AverageCostPerUnit) : ''
                            productObj.MarketValue = !productObj.isError ? productObj.MarketValue : ''
                            productObj.UnrealizedGL = !productObj.isError ? productObj.UnrealizedGL : ''
                            productObj.UnrealizedGLPerc = !productObj.isError ? productObj.UnrealizedGLPerc : ''

                            productObj.link = !productObj.isError ? '/one/one.app#' + btoa(JSON.stringify({
                                "componentDef": "c:InvestmentProductDetailView",
                                "attributes": {
                                    "recordId": component.get('v.account.Id'),
                                    "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                                    'UnitHolderNo': productObj.UnitHolderNo,
                                    'FundCode': productObj.FundCode,
                                }
                            })) : '';

                            productObj.ERROR = productObj.isError ? 'notFound' : '';
                            productObj.UnitHolderNoClass = productObj.isError ? 'notFound' : '';
                            return productObj;
                        });
                    } else if (result.StatusCode == '401' && round < component.get("v.numOfRetryTime")) {
                        //product.ERROR = 'retry';
                        product.ERROR = 'retry InvestmentAccount';
                        product.isError = true;
                    } else {
                        product.SeqGrp = 'OTHERS';
                        product.UnitHolderNoClass = 'notFound';
                        product.ERROR = 'notFound';
                        product.isError = true;
                        product.ProductName = result.StatusCode == "200" && result.InvestmentAccountStatusCode == "200" ? $A.get('$Label.c.INT_Investment_Record_Not_Found') : $A.get('$Label.c.ERR008');
                        if (result.Timeout) {
                            component.set('v.errorMessageControl.timeout.Investment', true);
                        } else {
                            component.set('v.errorMessageControl.error.Investment', true);
                        }
                    }

                    product.UnitHolderNo = UnitHolderNo;
                    product.result = helper.parseObj(result);

                    var selfIndex = component.get('v.investmentProduct.datas').findIndex(function (f) {
                        return f.UnitHolderNo == UnitHolderNo;
                    });

                    var isFirst = productList.length > 0 ? 1 : 0;

                    productList.forEach(function (v) {
                        component.get('v.investmentProduct.datas').splice(selfIndex != -1 ? selfIndex : 0, isFirst, productList.length > 0 ? v : product);
                        isFirst = 0;
                    })

                    component.set('v.investmentProduct.datas', component.get('v.investmentProduct.datas'));

                    res(productList.length > 0 ? productList : product);
                } else {
                    var errors = response.getError();

                    errors.forEach(function (error) {
                        console.log(error.message)
                    });

                    rej(errors.find(function (f) {
                        return f;
                    }).message);
                }
            });
            $A.enqueueAction(action);
        }));
    },

    promiseOSC02: function (component, helper, osc02lst, round) {
        Promise.all(osc02lst).then(function (products) {
            component.set('v.depositProduct.datas', helper.sortDepositProduct(helper.parseDepositProduct(component, products)));

            round++;

            var needretryOSC02 = products.filter(f => f.isError == true && f.ERROR1 == 'retry');

            var retryOSC02 = products.reduce(function (l, i) {
                if (i.isError == true && i.ERROR1 == 'retry') {
                    l.push(helper.callProductOSC02(component, helper, i, round));
                } else {
                    l.push(i);
                }
                return l;
            }, [])

            if (needretryOSC02.length > 0 && round <= component.get("v.numOfRetryTime")) {
                setTimeout(() => {
                    helper.promiseOSC02(component, helper, retryOSC02, round);
                }, component.get("v.retrySetTimeOut"));
            } else {
                component.set('v.depositProduct.isLoading', false);
                helper.checkIsSuccess(component);
                helper.calculateSummarizedProduct(component, helper);
            }
        }, function (error) {
            component.set('v.depositProduct.isLoading', false);
            console.log('Error: DepositAccount', error);
        }).catch(function (error) {
            console.log(error);
        });
    },

    promiseOSC04: function (component, helper, osc04lst, round) {
        Promise.all(osc04lst).then(function (products) {
            component.set('v.loanProduct.datas', helper.sortLoanProduct(helper.parseLoanProduct(component, products,helper)));

            round++;

            var needRetryOSC04 = products.filter(f => f.isError == true && f.ERROR1 == 'retry');

            var retryOSC04 = products.reduce(function (l, i) {
                if (i.isError == true && i.ERROR1 == 'retry') {
                    l.push(helper.callProductOSC04(component, helper, i, round));
                } else {
                    l.push(i);
                }
                return l;
            }, []);

            if (needRetryOSC04.length > 0 && round <= component.get("v.numOfRetryTime")) {
                setTimeout(() => {
                    helper.promiseOSC04(component, helper, retryOSC04, round);
                }, component.get("v.retrySetTimeOut"));
            } else {
                component.set('v.loanProduct.isLoading', false);

                helper.checkIsSuccess(component);
                helper.calculateSummarizedProduct(component, helper);
            }
        }, function (error) {
            console.log('Error: LoanAccount', error);
            component.set('v.loanProduct.isLoading', false);
        }).catch(function (error) {
            console.log(error);
        });
    },

    promiseOSC06: function (component, helper, osc06lst, round) {
        var thisObject = this;
        var graphProductAP = [];
        var graphProductPT = [];
        var graphProductLTF = [];

        Promise.all(osc06lst).then(function (products) {
            round++;

            var needRetryOSC06 = products.filter(f => f.isError == true && f.ERROR == 'retry');

            var retryOSC06 = products.reduce(function (l, i) {
                if (i.isError == true && i.ERROR == 'retry') {
                    l.push(helper.callProductOSC06List(component, helper, i, round));
                } else {
                    l.push(i);
                }
                return l;
            }, [])

            if (needRetryOSC06.length > 0 && round <= component.get("v.numOfRetryTime")) {
                setTimeout(() => {
                    helper.promiseOSC06(component, helper, retryOSC06, round);
                }, component.get("v.retrySetTimeOut"));
            } else {
                products = products.reduce(function (list, item) {
                    if (Array.isArray(item)) {
                        list = list.concat(item);
                    } else {
                        list.push(item);
                    }
                    return list;
                }, []);

                var productAP = products.reduce(function (list, item) {
                    if (item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                    }
                    return list;
                }, []);

                var productPT = products.reduce(function (list, item) {
                    if (!item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                    }
                    return list;
                }, []);

                var productLTF = products.reduce(function (list, item) {
                    if (item.AssetClass == 'LTF' || item.AssetClass == 'RMF' || item.AssetClass == 'SSF') {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                    }
                    return list;
                }, []);

                // AP
                var graphProductAPList = helper.groupEachUnitHolderDataForChart(productAP);

                graphProductAP = helper.sumTotalEachAssetClassInvForGraph(productAP);

                graphProductAPList.push({
                    'UnitHolderNo': component.get('v.AllPort'),
                    'Summary': graphProductAP
                });
                // var selectOptionAP = helper.getEachUnitHolderPicklist(component, productAP);
                var selectOptionAP = helper.getEachUnitHolderPicklist2(component, graphProductAPList);
                productAP = helper.sumTotalEachUnitHolderInvestmentProduct(productAP);
                // graphProductAP = helper.getTotalEachUnitHolderInvForGraph(productAP);
                productAP = helper.calculatePercentWeightPerPort(productAP);
                var productAPGroup = helper.groupEachUnitHolderData(component, productAP);
                component.set('v.investmentProduct.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, products)));
                component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
                component.set('v.investmentOptionsAP', selectOptionAP);
                component.set('v.investmentSelectedValueAP', 0);
                component.set('v.investmentAPGraphList', graphProductAPList);
                component.set('v.investmentAPGroup', productAPGroup);
                // component.set('v.investmentSelectedValueAP', selectOptionAP.length - 1);

                // PT
                var graphProductPTList = helper.groupEachUnitHolderDataForChart(productPT);
                // var selectOptionPT = helper.getEachUnitHolderPicklist(component, productPT);
                productPT = helper.sumTotalEachAssetClassInvestmentProduct(productPT);
                graphProductPT = helper.getTotalEachAssetClassInvForGraph(productPT);
                graphProductPT = helper.sortAssetClassFollowRecommend(component, graphProductPT, component.get('v.investmentPTGraphRecommend'));
                graphProductPTList.push({
                    'UnitHolderNo': component.get('v.AllPort'),
                    'Summary': graphProductPT
                });
                var selectOptionPT = helper.getEachUnitHolderPicklist2(component, graphProductPTList);
                productPT = helper.calculatePercentWeight(productPT);
                component.set('v.investmentProductPT.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productPT)));
                component.set('v.investmentOptionsPT', selectOptionPT);
                component.set('v.investmentSelectedValuePT', 0);
                component.set('v.investmentPTGraphList', graphProductPTList);
                // component.set('v.investmentSelectedValuePT',selectOptionPT.length - 1);

                // LTF
                productLTF = helper.sumTotalEachAssetClassInvestmentProduct(productLTF);
                graphProductLTF = helper.getTotalEachAssetClassInvForGraph(productLTF);
                productLTF = helper.calculatePercentWeight(productLTF);
                component.set('v.investmentProductLTF.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productLTF)));
                component.set('v.investmentLTFGraph', graphProductLTF);

                component.set('v.investmentProduct.isLoading', false);

                helper.checkIsSuccess(component);
                helper.calculateSummarizedProduct(component, helper);

                thisObject.generateGraphAP(component, graphProductAPList, component.get('v.AllPort'));
                thisObject.generateGraphPT(component, graphProductPTList, component.get('v.AllPort'));
                thisObject.generateGraphPTRec(component, component.get('v.investmentPTGraphRecommend'), 'donut');
                thisObject.generateGraphLTF(component, graphProductLTF, 'donut');
            }
        }, function (error) {
            component.set('v.investmentProduct.isLoading', false);
            console.log('Error: InvestmentAccount', error);
        }).catch(function (error) {
            console.log(error);
        });
    },

    promiseData: function (component, helper, cmpRetryName, listProduct, round) {
        const depositAccName = 'DepositAccount';
        const loanAccName = 'LoanAccount';
        const InvestmentAccName = 'InvestmentAccount';
        //For InvestmentAccount 
        var thisObject = this;
        var graphProductAP = [];
        var graphProductPT = [];
        var graphProductLTF = [];
        
        Promise.all(listProduct).then(function (products) {
            round++;

            if (cmpRetryName.includes(depositAccName)) {
                var depositAccToRetry = products.filter(f => f.isError == true && f.ERROR1.includes(depositAccName));

                if (depositAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {

                    var depositAccProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR1.includes('retry')) {
                            l.push(helper.callProductOSC02(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, []);

                    setTimeout(() => {
                        helper.promiseData(component, helper, cmpRetryName, depositAccProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    // component.set('v.depositProduct.datas', helper.sortDepositProduct(helper.parseDepositProduct(component, products)));
                    component.set('v.depositProduct.datas', helper.sortDepositProduct(component.get('v.depositProduct.datas')));
                    component.set('v.depositProduct.isLoading', false);
                    helper.checkIsSuccess(component);
                    helper.calculateSummarizedProduct(component, helper);
                }

            } else if (cmpRetryName.includes(loanAccName)) {
                var loanAccToRetry = products.filter(f => f.isError == true && f.ERROR1.includes(loanAccName));

                if (loanAccToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    var LoanAccProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR1.includes('retry')) {
                            l.push(helper.callProductOSC04(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, []);

                    setTimeout(() => {
                        helper.promiseData(component, helper, cmpRetryName, LoanAccProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    component.set('v.loanProduct.datas', helper.sortLoanProduct(helper.parseLoanProduct(component, products,helper)));
                    component.set('v.loanProduct.isLoading', false);
                    helper.checkIsSuccess(component);
                    helper.calculateSummarizedProduct(component, helper);
                }

            } else if (cmpRetryName.includes(InvestmentAccName)) {
                var investmentToRetry = products.filter(f => f.isError == true && f.ERROR.includes(InvestmentAccName));

                if (investmentToRetry.length > 0 && round <= component.get("v.numOfRetryTime")) {
                    var InvestmentProducts = products.reduce(function (l, i) {
                        if (i.isError == true && i.ERROR == 'retry InvestmentAccount') {
                            l.push(helper.callProductOSC06List(component, helper, i, round));
                        } else {
                            l.push(i);
                        }
                        return l;
                    }, [])

                    setTimeout(() => {
                        helper.promiseData(component, helper, cmpRetryName, InvestmentProducts, round);
                    }, component.get("v.retrySetTimeOut"));

                } else {
                    products = products.reduce(function (list, item) {
                        if (Array.isArray(item)) {
                            list = list.concat(item);
                        } else {
                            list.push(item);
                        }
                        return list;
                    }, []);

                    var productAP = products.reduce(function (list, item) {
                        if (item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);

                    var productPT = products.reduce(function (list, item) {
                        if (!item.UnitHolderNo.includes('AP00') && item.AssetClass != 'LTF' && item.AssetClass != 'RMF' && item.AssetClass != 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);

                    var productLTF = products.reduce(function (list, item) {
                        if (item.AssetClass == 'LTF' || item.AssetClass == 'RMF' || item.AssetClass == 'SSF') {
                            if (Array.isArray(item)) {
                                list = list.concat(item);
                            } else {
                                list.push(item);
                            }
                        }
                        return list;
                    }, []);

                    // AP
                    var graphProductAPList = helper.groupEachUnitHolderDataForChart(productAP);

                    graphProductAP = helper.sumTotalEachAssetClassInvForGraph(productAP);

                    graphProductAPList.push({
                        'UnitHolderNo': component.get('v.AllPort'),
                        'Summary': graphProductAP
                    });
                    // var selectOptionAP = helper.getEachUnitHolderPicklist(component, productAP);
                    var selectOptionAP = helper.getEachUnitHolderPicklist2(component, graphProductAPList);
                    productAP = helper.sumTotalEachUnitHolderInvestmentProduct(productAP);
                    // graphProductAP = helper.getTotalEachUnitHolderInvForGraph(productAP);
                    productAP = helper.calculatePercentWeightPerPort(productAP);
                    var productAPGroup = helper.groupEachUnitHolderData(component, productAP);
                    component.set('v.investmentProduct.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, products)));
                    component.set('v.investmentProductAP.datas', helper.sortInvestmentProduct2(helper.parseInvestmentProduct(component, productAP)));
                    component.set('v.investmentOptionsAP', selectOptionAP);
                    component.set('v.investmentSelectedValueAP', 0);
                    component.set('v.investmentAPGraphList', graphProductAPList);
                    component.set('v.investmentAPGroup', productAPGroup);
                    // component.set('v.investmentSelectedValueAP', selectOptionAP.length - 1);

                    // PT
                    var graphProductPTList = helper.groupEachUnitHolderDataForChart(productPT);
                    // var selectOptionPT = helper.getEachUnitHolderPicklist(component, productPT);
                    productPT = helper.sumTotalEachAssetClassInvestmentProduct(productPT);
                    graphProductPT = helper.getTotalEachAssetClassInvForGraph(productPT);
                    graphProductPT = helper.sortAssetClassFollowRecommend(component, graphProductPT, component.get('v.investmentPTGraphRecommend'));
                    graphProductPTList.push({
                        'UnitHolderNo': component.get('v.AllPort'),
                        'Summary': graphProductPT
                    });
                    var selectOptionPT = helper.getEachUnitHolderPicklist2(component, graphProductPTList);
                    productPT = helper.calculatePercentWeight(productPT);
                    component.set('v.investmentProductPT.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productPT)));
                    component.set('v.investmentOptionsPT', selectOptionPT);
                    component.set('v.investmentSelectedValuePT', 0);
                    component.set('v.investmentPTGraphList', graphProductPTList);
                    // component.set('v.investmentSelectedValuePT',selectOptionPT.length - 1);

                    // LTF
                    productLTF = helper.sumTotalEachAssetClassInvestmentProduct(productLTF);
                    graphProductLTF = helper.getTotalEachAssetClassInvForGraph(productLTF);
                    productLTF = helper.calculatePercentWeight(productLTF);
                    component.set('v.investmentProductLTF.datas', helper.sortInvestmentProduct(helper.parseInvestmentProduct(component, productLTF)));
                    component.set('v.investmentLTFGraph', graphProductLTF);

                    component.set('v.investmentProduct.isLoading', false);

                    helper.checkIsSuccess(component);
                    helper.calculateSummarizedProduct(component, helper);

                    thisObject.generateGraphAP(component, graphProductAPList, component.get('v.AllPort'));
                    thisObject.generateGraphPT(component, graphProductPTList, component.get('v.AllPort'));
                    thisObject.generateGraphPTRec(component, component.get('v.investmentPTGraphRecommend'), 'donut');
                    thisObject.generateGraphLTF(component, graphProductLTF, 'donut');
                }
            }
        }, function (error) {
            console.log('Error: ' + cmpRetryName, error);
            if (cmpRetryName.includes(depositAccName)) {
                component.set('v.depositProduct.isLoading', false);
            } else if (cmpRetryName.includes(loanAccName)) {
                component.set('v.loanProduct.isLoading', false);
            } else if (cmpRetryName.includes(InvestmentAccName)) {
                component.set('v.investmentProduct.isLoading', false);
            }
        }).catch(function (error) {
            console.error(error);
        });
    },

    callProduct: function (component, event, helper, round) {
        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:OSC01',
            'callback': 'callbackOSC01',
            'body': JSON.stringify({
                "GetCustomerAccountRequest": {
                    "RMID": helper.getTMBCustID(component).substring(14),
                    "FIIdent": helper.getTMBCustID(component).substring(0, 16)
                }
            }),
            'tmbCustId': helper.getTMBCustID(component),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();

                var accessibleCusHold = component.get('v.accessibleCusHold');
                if (accessibleCusHold.isAccessibleCusHoldHig || accessibleCusHold.isAccessibleCusHoldMid || accessibleCusHold.isAccessibleCusHoldLow) {
                    if (result) {
                        // helper.resetData(component);
                        if (result.Timeout) {
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                            // helper.displayToast('error', result.Message)
                            // timeout message
                            component.set('v.errorMessageControl.timeout.OSC', true);
                            helper.setIsLoadingProductOSC(component, false);
                        } else if (result.StatusCode == "401" && round < component.get("v.numOfRetryTime")) {
                            round++;

                            setTimeout(() => {
                                helper.callProduct(component, event, helper, round);
                            }, component.get("v.retrySetTimeOut"));

                        } else if ((result.StatusCode == "401") || (result.Message && (result.Message.includes('Sorry, some error occurred') || result.Message.includes('SNOW')))) {
                            helper.setIsLoadingProductOSC(component, false);
                            component.set('v.errorMessageControl.error.OSC', true);
                            component.set('v.errorMessageControl.message', result.Message);
                            helper.displayErrorMessage(component, 'Warning!', result.Message);
                        } else if (result.Message && result.Message.includes($A.get("$Label.c.INT_No_Active_Product"))) { //BAU11438_INC0179846                                                       
                            helper.setIsLoadingProductOSC(component, false);
                        }

                        if (result.DepositAccount) {
                            component.set('v.depositProduct.datas', helper.parseDepositProduct(component, result.DepositAccount.map(function (m) {
                                m.MarkedLedgerBalance = $A.get('$Label.c.Loading');
                                m.MarkedAvgOutStanding = '';
                                m.MarkedOutStanding = '';
                                return m;
                            })));

                            var OSC02lst = component.get('v.depositProduct.datas').reduce(function (l, i) {
                                l.push(helper.callProductOSC02(component, helper, i, 0));
                                return l;
                            }, []);

                            //helper.promiseOSC02(component, helper, OSC02lst, 0);
                            helper.promiseData(component, helper, 'DepositAccount', OSC02lst, 0);
                        }

                        if (result.LoanAccount) {
                            component.set('v.loanProduct.datas', helper.parseLoanProduct(component, result.LoanAccount.map(function (m) {
                                m.ERROR1 = m.Status != 'UNKNOWN' ? '' : 'notFound';
                                m.MarkedOutstanding = $A.get('$Label.c.Loading');
                                m.MarkedVLimit = '';
                                return m;
                            }),helper));

                            var osc04lst = component.get('v.loanProduct.datas').reduce(function (l, i) {
                                l.push(helper.callProductOSC04(component, helper, i, 0));
                                return l;
                            }, []);

                            //helper.promiseOSC04(component, helper, osc04lst, 0);
                            helper.promiseData(component, helper, 'LoanAccount', osc04lst, 0);
                        }

                        if (result.InvestmentAccount) {
                            component.set('v.investmentProduct.datas', helper.parseInvestmentProduct(component, result.InvestmentAccount.map(function (m) {
                                m.UnitHolderNo = m.UnitHoldNo;
                                m.FundCode = '';
                                m.ProductName = $A.get('$Label.c.Loading');
                                m.MarketValue = '';
                                m.UnrealizedGL = '';
                                return m;
                            })));

                            var osc06lst = component.get('v.investmentProduct.datas').reduce(function (l, i) {
                                l.push(helper.callProductOSC06List(component, helper, i, 0));
                                return l;
                            }, []);
                            //helper.promiseOSC06(component, helper, osc06lst, 0)
                            helper.promiseData(component, helper, 'InvestmentAccount', osc06lst, 0);
                        }

                        // if (result.BancassuranceAccount) {
                        //     Promise.all(result.BancassuranceAccount.reduce(function (l, i) {
                        //         l.push(helper.callProductOSC05(component, helper));
                        //         return l;
                        //     }, [])).then(function (products) {
                        //             component.set('v.bancassuranceProduct.datas', helper.parseBancassuranceProduct(component, products.find(function (f) {
                        //                 return f;
                        //             })));
                        //             component.set('v.bancassuranceProduct.isLoading', false);
                        //             helper.checkIsSuccess(component);

                        //             helper.calculateSummarizedProduct(component, helper);
                        //         },
                        //         function (error) {
                        //             component.set('v.bancassuranceProduct.isLoading', false);
                        //         }).catch(function (error) {
                        //     });
                        // }
                    }
                } else {
                    helper.setIsLoadingProduct(component, false);
                    helper.displayErrorMessage(component, 'Warning!', $A.get('$Label.c.Data_Condition_NotAuthorizedMsg'));
                    component.set('v.errorMessageControl.noAuthorized', true);
                }
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message)
                });
                if ((errors[0].message == undefined || errors[0].message.includes('UNABLE_TO_LOCK_ROW')) && !component.get('v.isAutoRetryOSC01')) {
                    component.set('v.isAutoRetryOSC01', true);
                    helper.setIsLoadingProductOSC(component, true);
                    helper.callProduct(component, event, helper, round);
                } else {
                    helper.setIsLoadingProductOSC(component, false);
                }
            }
            helper.choiceErrorHandle(component, helper);
        });
        $A.enqueueAction(action);
    },

    calculateSummarizedProduct: function (component, helper) {
        var products = component.get('v.depositProduct.datas')
            .concat(component.get('v.creditCardRDCProduct.datas'))
            .concat(component.get('v.loanProduct.datas'))
            .concat(component.get('v.bancassuranceProduct.datas'))
            .concat(component.get('v.investmentProduct.datas'));
        // Dynamic get product
        var keyProduct = [...new Set(component.get('v.errorMessageControl.products'))];
        keyProduct.forEach(e => {
            var childCmp = component.find(e);
            if (childCmp) {
                products = products.concat(childCmp.getProducts())
            };
        });

        component.set('v.productSummarized.datas', helper.parseSummarizedProduct(component, products));
    },

    parseSummarizedProduct: function (component, list) {
        var helper = this;

        // Mapping variable field calculate Summary product holding
        const mappingField = {
            '1': {
                NumOfAccocunt: 'AccountNumber',
                NumOfProduct: 'ProductName',
                OutStanding: 'LedgerBalance',
                ODLimit: 'ODLimit'
            },
            '2': {
                NumOfAccocunt: 'AccountNumber',
                NumOfProduct: 'ProductName',
                OutStanding: 'LedgerBalance',
                ODLimit: 'ODLimit'
            },
            '3': {
                NumOfAccocunt: 'CardNumber',
                NumOfProduct: 'ProductName',
                OutStanding: 'Outstanding',
                ODLimit: 'VLimit'
            },
            '5': {
                NumOfAccocunt: 'UnitHolderNo',
                NumOfProduct: 'ProductName',
                OutStanding: 'MarketValue'
            },
            '6': {
                NumOfAccocunt: 'POLICY_NO',
                NumOfProduct: 'ProductName',
            },
            '7': {
                NumOfAccocunt: 'AccountNumber',
                NumOfProduct: 'ProductName',
                OutStanding: 'Outstanding',
                ODLimit: 'VLimit'
            },
            '8': {
                NumOfAccocunt: 'AccountNumber',
                NumOfProduct: 'ProductName',
                OutStanding: 'Outstanding',
                ODLimit: 'VLimit'
            },
            'AutoLoan': {
                NumOfAccocunt: 'HP_Account_No',
                NumOfProduct: 'ProductName',
                OutStanding: 'Outstanding',
                ODLimit: 'ODLimit'
            },
            'OTHERS': {
                NumOfAccocunt: ['UnitHolderNo', 'POLICY_NO', 'AccountNumber', 'CardNumber'],
                NumOfProduct: 'ProductName',
                OutStanding: ['OutStanding', 'Outstanding', 'MarketValue', 'LedgerBalance'],
                ODLimit: ['ODLimit', 'VLimit']
            },
        };

        return [{
            'Product_Group': 'Transactional Deposit',
            'SeqGrp': '1',
            'Tag': 'Deposit_Product_Details'
        },
        {
            'Product_Group': 'Non Transactional Deposit',
            'SeqGrp': '2',
            'Tag': 'Deposit_Product_Details'
        },
        {
            'Product_Group': 'Credit Card',
            'SeqGrp': '3',
            'Tag': 'Credit_Card_RDC_Product_Details'
        },
        {
            'Product_Group': 'Mutual Fund',
            'SeqGrp': '5',
            'Tag': 'Investment_Product_Details'
        },
        {
            'Product_Group': 'Bancassurance',
            'SeqGrp': '6',
            'Tag': 'Bancassurance_Product_Details'
        },
        {
            'Product_Group': 'Personal Loan',
            'SeqGrp': '7',
            'Tag': 'Loan_Product_Details'
        },
        {
            'Product_Group': 'Secured Loan',
            'SeqGrp': '8',
            'Tag': 'Loan_Product_Details'
        },
        {
            'Product_Group': 'Auto Loan',
            'SeqGrp': 'AutoLoan',
            'Tag': 'AutoLoan_Product_Details'
        },
        {
            'Product_Group': 'Others',
            'SeqGrp': 'OTHERS',
        },
        ].map(function (m) {
            // filter product group
            var thisProduct = list ? list.filter(function (f) {
                return f.SeqGrp == m.SeqGrp;
            }) : [];

            // In SeqGrp, Check erorr to display red text on Product group 
            m.ERROR = m.SeqGrp != 'OTHERS' && thisProduct.some(function (i) {
                return i.isError;
            }) ? 'notFound' : '';

            // Number of Account
            m.Number_of_Account = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                if (!l.find(function (f) {
                    return f[mappingField[m.SeqGrp].NumOfAccocunt] == i[mappingField[m.SeqGrp].NumOfAccocunt];
                })) {
                    l.push(i);
                }
                return l;
            }, []).length : thisProduct.reduce(function (l, i) {
                mappingField[m.SeqGrp].NumOfAccocunt.forEach(function (v) {
                    if (i[v] && !l.find(function (s) {
                        return s[v] == i[v];
                    })) {
                        l.push(i);
                    }
                });
                return l;
            }, []).length;

            // Number of Product
            m.Number_of_Product = thisProduct.reduce(function (l, i) {
                if (
                    !l.find(function (f) {
                        return f[mappingField[m.SeqGrp].NumOfProduct] == i[mappingField[m.SeqGrp].NumOfProduct];
                    }) ||
                    i[mappingField[m.SeqGrp].NumOfProduct] == '#N/A' ||
                    !i[mappingField[m.SeqGrp].NumOfProduct] ||
                    i.isError) {
                    l.push(i);
                }
                return l;
            }, []).length;

            // Outstanding
            m.Outstanding = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                l += i[mappingField[m.SeqGrp].OutStanding] ? i[mappingField[m.SeqGrp].OutStanding] : 0;
                return l;
            }, 0) : thisProduct.reduce(function (l, i) {
                l += mappingField[m.SeqGrp].OutStanding.reduce(function (y, x) {
                    // No calculate deposit "OutStading" key
                    if (i.Tag == 'Deposit_Product_Details' && x == 'OutStanding') return y;
                    return y + (i[x] ? i[x] : 0);
                }, 0);
                return l;
            }, 0);

            // Limit / OD Limit
            m.Limit_ODLimit = m.SeqGrp != 'OTHERS' ? thisProduct.reduce(function (l, i) {
                l += i[mappingField[m.SeqGrp].ODLimit] ? i[mappingField[m.SeqGrp].ODLimit] : 0;
                return l;
            }, 0) : thisProduct.reduce(function (l, i) {
                l += mappingField[m.SeqGrp].ODLimit.reduce(function (y, x) {
                    return y + (i[x] ? i[x] : 0);
                }, 0);
                return l;
            }, 0);
            return m;
        }).reduce(function (l, i, index) {
            var MarkedOutstanding = i.Outstanding.toLocaleString('en-US', {
                style: 'decimal',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            });
            MarkedOutstanding = helper.replaceAt(MarkedOutstanding, MarkedOutstanding.length - 2, 'xx')
            var MarkedODLimit = i.Limit_ODLimit.toLocaleString('en-US', {
                style: 'decimal',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            });

            // Unmasked Product Holding
            var IsUnmasked = component.get("v.unmasked");
            var IsOutStanding;
            var IsODLimit;
            var IsOutStandingLimit = IsUnmasked == null || IsUnmasked["Summary_Section"] == undefined;
            if (!IsOutStandingLimit) {
                IsOutStanding = IsUnmasked["Summary_Section"]["SummaryString"];
                IsODLimit = IsUnmasked["Summary_Section"]["SummaryODLimit"];
            }

            MarkedOutstanding = i.Outstanding == 0 ? '-' : (IsOutStandingLimit ? MarkedOutstanding : (!IsOutStanding ? MarkedOutstanding : i.Outstanding.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })));
            MarkedODLimit = i.Limit_ODLimit == 0 ? '-' : (IsOutStandingLimit ? MarkedODLimit : (!IsODLimit ? MarkedODLimit : i.Limit_ODLimit.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })));

            l.push({
                'ERROR': i.ERROR,
                'SeqGrp': i.SeqGrp,
                'Tag': i.Tag,
                'Product_Group': i.Product_Group,
                'Number_of_Product': i.Number_of_Product,
                'Number_of_Account': i.Number_of_Account,
                'Outstanding': i.Outstanding,
                'Limit_ODLimit': i.Limit_ODLimit,
                // 'MarkedOutstanding': helper.isEmployee(component) && i.SeqGrp == '1' ? 'xxx' : (i.Outstanding == 0 ? '-' : IsOutStandingLimit ? MarkedOutstanding : !IsOutStanding ? MarkedOutstanding :i.Outstanding.toLocaleString("en-US",{minimumFractionDigits: 2,maximumFractionDigits: 2})),
                // 'MarkedODLimit': helper.isEmployee(component) && i.SeqGrp == '3' ? 'xxx' : (i.Limit_ODLimit == 0 ? '-' : IsOutStandingLimit ? MarkedODLimit : !IsODLimit ? MarkedODLimit : i.Limit_ODLimit.toLocaleString("en-US",{minimumFractionDigits: 2,maximumFractionDigits: 2})),
                'MarkedOutstanding': (helper.isEmployee(component) && (i.SeqGrp == '1'|| i.SeqGrp == '3' || i.SeqGrp == '7' || i.SeqGrp == '8' || i.SeqGrp == 'AutoLoan' )) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : MarkedOutstanding,
                'MarkedODLimit': (helper.isEmployee(component) && (i.SeqGrp == '3' || i.SeqGrp == '7' || i.SeqGrp == '8' || i.SeqGrp == 'AutoLoan')) ?  $A.get('$Label.c.Data_Condition_Hidden_Text') : MarkedODLimit,
                
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            });
            return l;
        }, []);
    },

    parseDepositProduct: function (component, list) {
        return list ? list.reduce(function (l, i, index) {
            var checkAllFree = false;
            var listProdMDT = component.get('v.mainBankProductCode');
            
            if (i.productCodeMainbank != undefined) {
                for (var indexmdt = 0; indexmdt < listProdMDT.length; indexmdt++) {
                    if (i.productCodeMainbank == listProdMDT[indexmdt].Product_Code__c && i.OutStanding < 5000) { //
                        checkAllFree = true;
                    }
                }
            }
            // unmasked deposit dormant
            var status = i.Status.toLowerCase();
            const dormant = "dormant";
            var IsAccountDormant = (status.trim().length) > 0 ? status.includes(dormant) : "dormant";
            var IsUnmasked = component.get("v.unmasked");
            var IsLedgerBalance = false;
            var IsAvgOutStanding = false;
            var IsOutStanding = false;
            var IsDepositLogic = false;
            IsDepositLogic = IsUnmasked == null || IsUnmasked["Deposit_Section"] == undefined;
            if (!IsDepositLogic) {
                IsLedgerBalance = IsUnmasked["Deposit_Section"]["MarkedLedgerBalance"];
                IsAvgOutStanding = IsUnmasked["Deposit_Section"]["MarkedAvgOutStanding"];
                IsOutStanding = IsUnmasked["Deposit_Section"]["MarkedOutStanding"];
            }

            l.push({
                'Type': $A.get('$Label.c.Deposit_Product_Details'),
                'Tag': 'Deposit_Product_Details',
                'TabName': i.MarkedDepositAccountNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedLedgerBalance != $A.get('$Label.c.Loading') ? '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:DepositProductDetailsView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        'AccountNumber': i.DepositAccountNumber,
                        'FIIdent': i.Fiident,
                        "AccountType": i.AccountType ? i.AccountType : i.DepositProductCode,
                        "ProductType": i.ProductType,

                        'product': btoa(encodeURIComponent(JSON.stringify({
                            'SeqGrp': i.SeqGrp,
                            'Fiident': i.Fiident,
                            'AccountNumber': i.DepositAccountNumber,
                            'AccountType': i.DepositProductCode,
                            'ProductType': i.ProductType,
                            'DepositAccountNumber': i.DepositAccountNumber,
                            'MarkedDepositAccountNumber': i.MarkedDepositAccountNumber,
                            'SubProductGroup': i.SubProductGroup,
                            'ProductName': i.ProductName,
                            'HasJoint': i.HasJoint,
                        })))
                    }
                })) : '',
                'SeqGrp': i.SeqGrp,
                'Fiident': i.Fiident,
                'AccountNumber': i.DepositAccountNumber,
                'AccountType': i.DepositProductCode,
                'ProductType': i.ProductType,
                'DepositAccountNumber': i.DepositAccountNumber,
                'MarkedDepositAccountNumber': i.MarkedDepositAccountNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'Status': i.Status,
                'MarkedLedgerBalance': IsDepositLogic ? i.MarkedLedgerBalance : (IsAccountDormant) ? i.MarkedLedgerBalance : (!IsLedgerBalance ? i.MarkedLedgerBalance : i.LedgerBalance.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })),   // Unmaskd Deposit Account
                'MarkedAvgOutStanding': IsDepositLogic ? i.MarkedAvgOutStanding : (IsAccountDormant) ? i.MarkedAvgOutStanding : (!IsAvgOutStanding ? i.MarkedAvgOutStanding : i.AvgOutStanding.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })), // Unmaskd Deposit Account
                'MarkedOutStanding': IsDepositLogic ? i.MarkedOutStanding : (IsAccountDormant) ? i.MarkedOutStanding : (!IsOutStanding) ? i.MarkedOutStanding : i.OutStanding.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),       // Unmaskd Deposit Account
                'ODLimit': i.ODLimit,
                'OutStanding': i.OutStanding,
                'LedgerBalance': i.LedgerBalance,
                //'AvgOutStanding' : i.AvgOutStanding,
                'Other': i.Other,
                'HasJoint': i.HasJoint,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                // 'ERROR2': i.ERROR2,
                // 'ERROR1': 'notFound',
                //'ERROR2': 'notFound',
                //atkบัญชี ทีเอ็มบี ออลล์ ฟรี
                //'ERROR2' : i.OutStanding < 5000 && i.ProductName=='บัญชี ทีทีบี ออลล์ฟรี' ? 'notFound' : '',
                //'ERRORLedger' : i.OutStanding < 5000 && i.ProductName=='บัญชี ทีทีบี ออลล์ฟรี' ? 'notFoundLedger' : '',
                //i.DepositProductCode

                //atk
                // 'ERROR2' : i.OutStanding < 5000 && i.productCodeMainbank=='ST225' ? 'notFound' : '',
                // 'ERRORLedger' : i.OutStanding < 5000 && i.productCodeMainbank=='ST225' ? 'notFoundLedger' : '',

                // 'isError': i.isError,
                // 'isAllFreeMin' : i.OutStanding < 5000 && i.productCodeMainbank=='ST225' ? 'ShowRed' : 'false'
                'ERROR2': checkAllFree ? 'notFound' : '',
                'ERRORLedger': checkAllFree ? 'notFoundLedger' : '',

                'isError': i.isError,
                'isAllFreeMin': checkAllFree ? 'ShowRed' : 'false'
                // isAllFreeMin : '5000'
            });
            return l;
        }, []) : [];
    },

    //M8 credit card
    parseCreditCardSCSProduct: function (component, list, helper) {
        var IsUnmasked = component.get("v.unmasked");
        var IsCreditLogic = IsUnmasked == null || IsUnmasked["CreditCard_Section"] == undefined;
        var IsOutStanding = false;
        var IsLimit = false;
        var IsMaskedCreditLine = false;

        if (!IsCreditLogic) {
            IsOutStanding = IsUnmasked["CreditCard_Section"]["MarkedOutstanding"];
            IsLimit = IsUnmasked["CreditCard_Section"]["MarkedVLimit"];
            IsMaskedCreditLine = IsUnmasked["CreditCard_Section"]["MaskedCreditLine"];
        }
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Credit_Card_RDC_Product_Details'),
                'Tag': 'Credit_Card_RDC_Product_Details',
                'TabName': i.MarkedCardNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedOutstanding != $A.get('$Label.c.Loading') ? '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:CreditCardDetailsView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        'CardNumber': i.CardNumber,
                        'CreditCardType': i.CreditCardType,
                        'account_id': i.account_id,
                        'product': btoa(encodeURIComponent(JSON.stringify({
                            'SeqGrp': i.SeqGrp,
                            'CardNumber': i.CardNumber,
                            'CreditCardType': i.CreditCardType,
                            'MarkedCardNumber': i.MarkedCardNumber,
                            'SubProductGroup': i.SubProductGroup,
                            'ProductName': i.ProductName,
                            'ProductType': i.ProductType,
                            // 'UsageStatus': i.UsageStatus,
                            'Status': i.Status,
                            'MarkedOutstanding': i.MarkedOutstanding,
                            'MarkedVLimit': i.MarkedVLimit,
                            'VLimit': i.VLimit,
                            'Outstanding': i.Outstanding,
                        }))),
                    }
                })) : '',
                'SeqGrp': i.SeqGrp,
                'CardNumber': i.CardNumber,
                'CreditCardType': i.CreditCardType,
                'MarkedCardNumber': i.MarkedCardNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'ProductType': i.ProductType,
                // 'UsageStatus': i.UsageStatus,
                'Status': i.Status,
                // unmasked credit card
                'MarkedOutstanding': helper.isEmployee(component)? $A.get('$Label.c.Data_Condition_Hidden_Text') : IsCreditLogic ? i.MarkedOutstanding : !IsOutStanding ? i.MarkedOutstanding : i.Outstanding.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'MarkedVLimit': helper.isEmployee(component)? $A.get('$Label.c.Data_Condition_Hidden_Text') : IsCreditLogic ? i.MarkedVLimit : !IsLimit ? i.MarkedVLimit : i.VLimit.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'VLimit': i.VLimit,
                'Outstanding': i.Outstanding,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2,
                'isError': i.isError,
                'account_id': i.account_id,
                'CardRole': i.CardRole,
                'CardPLoan': i.CardPLoan,
                'CardActive': i.CardActive,
                'CreditLine': i.CreditLine,
                // unmasked credit card
                'MaskedCreditLine': helper.isEmployee(component)? $A.get('$Label.c.Data_Condition_Hidden_Text') : IsCreditLogic ? i.MaskedCreditLine : !IsMaskedCreditLine ? i.MaskedCreditLine : Number(i.CreditLine).toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            });
            return l;
        }, []) : [];
    },

    parseCreditCardRDCProduct: function (component, list) {
        var IsUnmasked = component.get("v.unmasked");
        var IsCreditLogic = IsUnmasked == null || IsUnmasked["CreditCard_Section"] == undefined;
        var IsOutStanding = false;
        var IsLimit = false;
        var IsMaskedCreditLine = false;

        if (!IsCreditLogic) {
            IsOutStanding = IsUnmasked["CreditCard_Section"]["MarkedOutstanding"];
            IsLimit = IsUnmasked["CreditCard_Section"]["MarkedVLimit"];
        }

        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Credit_Card_RDC_Product_Details'),
                'Tag': 'Credit_Card_RDC_Product_Details',
                'TabName': i.MarkedCardNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedOutstanding != $A.get('$Label.c.Loading') ? '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:CreditCardDetailsView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        'CardNumber': i.CardNumber,
                        'CreditCardType': i.CreditCardType,
                        'product': btoa(encodeURIComponent(JSON.stringify({
                            'SeqGrp': i.SeqGrp,
                            'CardNumber': i.CardNumber,
                            'CreditCardType': i.CreditCardType,
                            'MarkedCardNumber': i.MarkedCardNumber,
                            'SubProductGroup': i.SubProductGroup,
                            'ProductName': i.ProductName,
                            'ProductType': i.ProductType,
                            'UsageStatus': i.UsageStatus,
                            'Status': i.Status,
                            'MarkedOutstanding': i.MarkedOutstanding,
                            'MarkedVLimit': i.MarkedVLimit,
                            'VLimit': i.VLimit,
                            'Outstanding': i.Outstanding,
                        }))),
                    }
                })) : '',
                'SeqGrp': i.SeqGrp,
                'CardNumber': i.CardNumber,
                'CreditCardType': i.CreditCardType,
                'MarkedCardNumber': i.MarkedCardNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'ProductType': i.ProductType,
                'UsageStatus': i.UsageStatus,
                'Status': i.Status,
                // unmasked Ready credit card
                'MarkedOutstanding': IsCreditLogic ? i.MarkedOutstanding : !IsOutStanding ? i.MarkedOutstanding : i.Outstanding.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'MarkedVLimit': IsCreditLogic ? i.MarkedVLimit : !IsLimit ? i.MarkedVLimit : i.VLimit.toLocaleString("en-Us", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'VLimit': i.VLimit,
                'Outstanding': i.Outstanding,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2,
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },

    parseLoanProduct: function (component, list, helper) {
        var IsUnmasked = component.get("v.unmasked");
        var IsLoanLogic = IsUnmasked == null || IsUnmasked["Loan_Section"] == undefined;
        var IsOutStanding = false;
        var IsLimit = false;
        if (!IsLoanLogic) {
            IsOutStanding = IsUnmasked["Loan_Section"]["MarkedOutstanding"];
            IsLimit = IsUnmasked["Loan_Section"]["MarkedVLimit"];
        }
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Loan_Product_Details'),
                'Tag': 'Loan_Product_Details',
                'TabName': i.MarkedLoanAccountNumber,
                'link': i.ERROR1 != 'notFound' && i.MarkedOutstanding != $A.get('$Label.c.Loading') ? '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:LoanProductDetailsView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        "RMID": component.get('v.account.TMB_Customer_ID_PE__c').substring(12),
                        "Fiident": i.Fiident,
                        "AccountNumber": i.AccountNumber ? i.AccountNumber : i.LoanAccountNumber,
                        "AccountType": i.AccountType ? i.AccountType : i.ProductType,
                        "ProductType": "",
                        'SeqGrp': i.SeqGrp,
                        "product": btoa(encodeURIComponent(JSON.stringify({
                            'Fiident': i.Fiident,
                            'AccountNumber': i.AccountNumber,
                            'AccountType': i.AccountType,
                            'MarkedLoanAccountNumber': i.MarkedLoanAccountNumber,
                            'SubProductGroup': i.SubProductGroup,
                            'ProductName': i.ProductName,
                            'Status': i.Status,
                            'VLimit': i.VLimit,
                            'Outstanding': i.Outstanding,
                            'MarkedOutstanding': i.MarkedOutstanding,
                            'MarkedVLimit': i.MarkedVLimit,
                            'convertedMaturityDate': i.convertedMaturityDate,
                            'MuturityDate': i.MuturityDate,
                            'HasCoBorrower': i.HasCoBorrower,
                        })))
                    }
                })) : '',
                'SeqGrp': i.SeqGrp,
                'LoanAccountNumber': i.LoanAccountNumber,
                'ProductType': i.ProductType,
                'Fiident': i.Fiident,
                'AccountNumber': i.LoanAccountNumber,
                'AccountType': i.ProductType,
                'MarkedLoanAccountNumber': i.MarkedLoanAccountNumber,
                'SubProductGroup': i.SubProductGroup,
                'ProductName': i.ProductName,
                'Status': i.Status,
                'VLimit': i.VLimit,
                'Outstanding': i.Outstanding,
                // Unmasked Loan
                'MarkedOutstanding': helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') :IsLoanLogic ? i.MarkedOutstanding : !IsOutStanding ? i.MarkedOutstanding : i.Outstanding.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'MarkedVLimit': helper.isEmployee(component) ? $A.get('$Label.c.Data_Condition_Hidden_Text') : IsLoanLogic ? i.MarkedVLimit : !IsLimit ? i.MarkedVLimit : i.VLimit.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                'convertedMaturityDate': i.convertedMaturityDate,
                'MuturityDate': i.MuturityDate,
                'HasCoBorrower': i.HasCoBorrower,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'ERROR1': i.ERROR1,
                'ERROR2': i.ERROR2,
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },

    parseBancassuranceProduct: function (component, list) {
        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Bancassurance_Product_Details'),
                'Tag': 'Bancassurance_Product_Details',
                'TabName': i.POLICY_NO,
                'link': '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:BancassuranceProductView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        "RMID": component.get('v.account.TMB_Customer_ID_PE__c').substring(12),
                        'PolicyNumber': i.POLICY_NO,
                    }
                })),
                'SeqGrp': '6',
                'POLICY_NO': i.POLICY_NO,
                'PRODUCT_GROUP': i.PRODUCT_GROUP,
                'ProductName': i.POLICY_NAME,
                'POLICY_NAME': i.POLICY_NAME,
                'COMPANY_NAME': i.COMPANY_NAME,
                'EFFECTIVE_DATE': i.EFFECTIVE_DATE,
                'STATUS': i.STATUS,
                'SUM_INSURE': i.SUM_INSURE,
                'PREMIUM': i.PREMIUM,
                'EXPIRY_DATE': i.EXPIRY_DATE,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text')
            });
            return l;
        }, []) : [];
    },

    parseInvestmentProduct: function (component, list) {
        // fieldName => UnitHolderNo is accessible or not
        var UnitHolderNo_FieldInfo = component.get('v.investmentProduct.columns').find(function (f) {
            return f.typeAttributes && f.typeAttributes.label.fieldName == 'UnitHolderNo';
        });

        return list ? list.reduce(function (l, i) {
            l.push({
                'Type': $A.get('$Label.c.Investment_Product_Details'),
                'Tag': 'Investment_Product_Details',
                'TabName': i.UnitHolderNo,
                'link': i.UnitHolderNo && i.FundCode ? '/one/one.app#' + btoa(JSON.stringify({
                    "componentDef": "c:InvestmentProductDetailView",
                    "attributes": {
                        "recordId": component.get('v.account.Id'),
                        "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
                        'UnitHolderNo': i.UnitHolderNo,
                        'FundCode': i.FundCode,
                    }
                })) : '',
                'SeqGrp': i.SeqGrp,
                'UnitHolderNo': i.UnitHolderNo,
                'FundCode': i.FundCode,
                'ProductName': i.ProductName,
                'AssetClass': i.AssetClass,
                'IssuerFundHouse': i.IssuerFundHouse,
                'NumberOfUnit': i.isError ? '' : i.NumberOfUnit,
                'NavUnit': i.isError ? '' : i.NavUnit,
                'CostOfInvestment': i.isError ? '' : i.CostOfInvestment,
                'AverageCostPerUnit': i.isError ? '' : i.AverageCostPerUnit,
                'MarketValue': i.isError ? '' : i.MarketValue,
                'UnrealizedGL': i.isError ? '' : i.UnrealizedGL,
                'UnrealizedGLPerc': i.isError ? '' : i.UnrealizedGLPerc,
                'PercentWeight': i.isError ? '' : i.PercentWeight,
                'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
                'UnitHolderNoClass': UnitHolderNo_FieldInfo.fieldName != 'Hidden' && i.isError ? 'notFound' : '',
                'ERROR': i.isError ? 'notFound' : '',
                'isError': i.isError,
            });
            return l;
        }, []) : [];
    },

    // parseInvestmentProductAP: function (component, list) {
    //     // fieldName => UnitHolderNo is accessible or not
    //     var UnitHolderNo_FieldInfo = component.get('v.investmentProductAP.columns').find(function (f) {
    //         return f.typeAttributes && f.typeAttributes.label.fieldName == 'UnitHolderNo';
    //     });

    //     return list ? list.reduce(function (l, i) {
    //         if (i.UnitHolderNo.includes('AP00')
    //             && i.AssetClass != 'LTF'
    //             && i.AssetClass != 'RMF') {
    //             l.push({
    //                 'Type': $A.get('$Label.c.Investment_Product_Details'),
    //                 'Tag': 'Investment_Product_Details',
    //                 'TabName': i.UnitHolderNo,
    //                 'link': i.UnitHolderNo && i.FundCode ? '/one/one.app#' + btoa(JSON.stringify({
    //                     "componentDef": "c:InvestmentProductDetailView",
    //                     "attributes": {
    //                         "recordId": component.get('v.account.Id'),
    //                         "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
    //                         'UnitHolderNo': i.UnitHolderNo,
    //                         'FundCode': i.FundCode,
    //                     }
    //                 })) : '',
    //                 'SeqGrp': i.SeqGrp,
    //                 'UnitHolderNo': i.UnitHolderNo,
    //                 'FundCode': i.FundCode,
    //                 'ProductName': i.ProductName,
    //                 'AssetClass': i.AssetClass,
    //                 'IssuerFundHouse': i.IssuerFundHouse,
    //                 'NumberOfUnit': i.isError ? '' : i.NumberOfUnit,
    //                 'NavUnit': i.isError ? '' : i.NavUnit,
    //                 'CostOfInvestment': i.isError ? '' : i.CostOfInvestment,
    //                 'AverageCostPerUnit': i.isError ? '' : i.AverageCostPerUnit,
    //                 'MarketValue': i.isError ? '' : i.MarketValue,
    //                 'UnrealizedGL': i.isError ? '' : i.UnrealizedGL,
    //                 'UnrealizedGLPerc': i.isError ? '' : i.UnrealizedGLPerc,
    //                 'PercentWeight': i.isError ? '' : i.PercentWeight,
    //                 'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
    //                 'UnitHolderNoClass': UnitHolderNo_FieldInfo.fieldName != 'Hidden' && i.isError ? 'notFound' : '',
    //                 'ERROR': i.isError ? 'notFound' : '',
    //                 'isError': i.isError,
    //             });
    //         }
    //         return l;
    //     }, []) : [];
    // },
    // parseInvestmentProductPT: function (component, list) {
    //     // fieldName => UnitHolderNo is accessible or not
    //     var UnitHolderNo_FieldInfo = component.get('v.investmentProductPT.columns').find(function (f) {
    //         return f.typeAttributes && f.typeAttributes.label.fieldName == 'UnitHolderNo';
    //     });

    //     return list ? list.reduce(function (l, i) {
    //         if (!i.UnitHolderNo.includes('AP00')
    //             && i.AssetClass != 'LTF'
    //             && i.AssetClass != 'RMF') {
    //             l.push({
    //                 'Type': $A.get('$Label.c.Investment_Product_Details'),
    //                 'Tag': 'Investment_Product_Details',
    //                 'TabName': i.UnitHolderNo,
    //                 'link': i.UnitHolderNo && i.FundCode ? '/one/one.app#' + btoa(JSON.stringify({
    //                     "componentDef": "c:InvestmentProductDetailView",
    //                     "attributes": {
    //                         "recordId": component.get('v.account.Id'),
    //                         "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
    //                         'UnitHolderNo': i.UnitHolderNo,
    //                         'FundCode': i.FundCode,
    //                     }
    //                 })) : '',
    //                 'SeqGrp': i.SeqGrp,
    //                 'AssetClass': i.AssetClass,
    //                 'FundCode': i.FundCode,
    //                 'ProductName': i.ProductName,
    //                 'UnitHolderNo': i.UnitHolderNo,
    //                 'IssuerFundHouse': i.IssuerFundHouse,
    //                 'NumberOfUnit': i.isError ? '' : i.NumberOfUnit,
    //                 'NavUnit': i.isError ? '' : i.NavUnit,
    //                 'CostOfInvestment': i.isError ? '' : i.CostOfInvestment,
    //                 'AverageCostPerUnit': i.isError ? '' : i.AverageCostPerUnit,
    //                 'MarketValue': i.isError ? '' : i.MarketValue,
    //                 'UnrealizedGL': i.isError ? '' : i.UnrealizedGL,
    //                 'UnrealizedGLPerc': i.isError ? '' : i.UnrealizedGLPerc,
    //                 'PercentWeight': i.isError ? '' : i.PercentWeight,
    //                 'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
    //                 'UnitHolderNoClass': UnitHolderNo_FieldInfo.fieldName != 'Hidden' && i.isError ? 'notFound' : '',
    //                 'ERROR': i.isError ? 'notFound' : '',
    //                 'isError': i.isError,
    //             });
    //         }
    //         return l;
    //     }, []) : [];
    // },
    // parseInvestmentProductLTF: function (component, list) {
    //     // fieldName => UnitHolderNo is accessible or not
    //     var UnitHolderNo_FieldInfo = component.get('v.investmentProductLTF.columns').find(function (f) {
    //         return f.typeAttributes && f.typeAttributes.label.fieldName == 'UnitHolderNo';
    //     });

    //     return list ? list.reduce(function (l, i) {
    //         if (i.AssetClass == 'LTF' || i.AssetClass == 'RMF') {
    //             l.push({
    //                 'Type': $A.get('$Label.c.Investment_Product_Details'),
    //                 'Tag': 'Investment_Product_Details',
    //                 'TabName': i.UnitHolderNo,
    //                 'link': i.UnitHolderNo && i.FundCode ? '/one/one.app#' + btoa(JSON.stringify({
    //                     "componentDef": "c:InvestmentProductDetailView",
    //                     "attributes": {
    //                         "recordId": component.get('v.account.Id'),
    //                         "tmbCustId": component.get('v.account.TMB_Customer_ID_PE__c'),
    //                         'UnitHolderNo': i.UnitHolderNo,
    //                         'FundCode': i.FundCode,
    //                     }
    //                 })) : '',
    //                 'SeqGrp': i.SeqGrp,
    //                 'AssetClass': i.AssetClass,
    //                 'FundCode': i.FundCode,
    //                 'ProductName': i.ProductName,
    //                 'UnitHolderNo': i.UnitHolderNo,
    //                 'IssuerFundHouse': i.IssuerFundHouse,
    //                 'NumberOfUnit': i.isError ? '' : i.NumberOfUnit,
    //                 'NavUnit': i.isError ? '' : i.NavUnit,
    //                 'CostOfInvestment': i.isError ? '' : i.CostOfInvestment,
    //                 'AverageCostPerUnit': i.isError ? '' : i.AverageCostPerUnit,
    //                 'MarketValue': i.isError ? '' : i.MarketValue,
    //                 'UnrealizedGL': i.isError ? '' : i.UnrealizedGL,
    //                 'UnrealizedGLPerc': i.isError ? '' : i.UnrealizedGLPerc,
    //                 'PercentWeight': i.isError ? '' : i.PercentWeight,
    //                 'Hidden': $A.get('$Label.c.Data_Condition_Hidden_Text'),
    //                 'UnitHolderNoClass': UnitHolderNo_FieldInfo.fieldName != 'Hidden' && i.isError ? 'notFound' : '',
    //                 'ERROR': i.isError ? 'notFound' : '',
    //                 'isError': i.isError,
    //             });
    //         }
    //         return l;
    //     }, []) : [];
    // },

    sortInvestmentProduct2: function (products) {
        // "Asset Class(ASC)" then "Market Value(DESC)" then "Unit Holder No.(ASC)" then "Product Name (ASC)"
        return products.sort(function (a, b) {
            var returnValue = 0;
            if (a.UnitHolderNo == b.UnitHolderNo) {
                if (a.AssetClass == b.AssetClass) {
                    if (a.MarketValue == b.MarketValue) {
                        // Product Name (ASC)
                        if (a.ProductName > b.ProductName) {
                            returnValue = 1;
                        } else if (a.ProductName < b.ProductName) {
                            returnValue = -1;
                        }
                    }
                    // Market Value.(DESC)
                    if (a.MarketValue < b.MarketValue) {
                        returnValue = 1;
                    } else if (a.MarketValue < b.MarketValue) {
                        returnValue = -1;
                    }
                }
                // AssetClass (ASC)
                if (a.AssetClass > b.AssetClass) {
                    returnValue = 1;
                } else if (a.AssetClass < b.AssetClass) {
                    returnValue = -1;
                }
                // Move #N/A be bottom
                if (a.AssetClass == '#N/A' && b.AssetClass != '#N/A') {
                    returnValue = 1;
                } else if (a.AssetClass != '#N/A' && b.AssetClass == '#N/A') {
                    returnValue = -1;
                }
                // Move #N/A be bottom
                if (!a.AssetClass && b.AssetClass) {
                    returnValue = 1;
                } else if (a.AssetClass && !b.AssetClass) {
                    returnValue = -1;
                }
                // Move isError bottom
                if (a.isError && !b.isError) {
                    returnValue = 1;
                } else if (!a.isError && b.isError) {
                    returnValue = -1;
                }
                if (b.ProductName == 'Total') {
                    returnValue = 1;
                } else if (a.ProductName == 'Total') {
                    returnValue = -1;
                }
            }
            // UnitHolderNo (ASC)
            if (a.UnitHolderNo > b.UnitHolderNo) {
                returnValue = 1;
            } else if (a.UnitHolderNo < b.UnitHolderNo) {
                returnValue = -1;
            }
            if (b.UnitHolderNo == 'ALL Total') {
                returnValue = -1;
            } else if (a.UnitHolderNo == 'ALL Total') {
                returnValue = 1;
            }
            return returnValue;
        });
    },

    sortInvestmentProduct: function (products) {
        // "Asset Class(ASC)" then "Market Value(DESC)" then "Unit Holder No.(ASC)" then "Product Name (ASC)"
        return products.sort(function (a, b) {
            var returnValue = 0;
            if (a.AssetClass == b.AssetClass) {
                if (a.MarketValue == b.MarketValue) {
                    if (a.UnitHolderNo == b.UnitHolderNo) {
                        // Product Name (ASC)
                        if (a.ProductName > b.ProductName) {
                            returnValue = 1;
                        } else if (a.ProductName < b.ProductName) {
                            returnValue = -1;
                        }
                    }
                    // Unit Holder No.(ASC)
                    if (a.UnitHolderNo > b.UnitHolderNo) {
                        returnValue = 1;
                    } else if (a.UnitHolderNo < b.UnitHolderNo) {
                        returnValue = -1;
                    }
                }
                // Market Value(DESC)
                if (a.MarketValue < b.MarketValue) {
                    returnValue = 1;
                } else if (a.MarketValue > b.MarketValue) {
                    returnValue = -1;
                }

                if (b.ProductName == 'Total') {
                    returnValue = 1;
                } else if (a.ProductName == 'Total') {
                    returnValue = -1;
                }
            }
            // Asset Class(ASC)
            if (a.AssetClass > b.AssetClass) {
                returnValue = 1;
            } else if (a.AssetClass < b.AssetClass) {
                returnValue = -1;
            }
            // Move #N/A be bottom
            if (a.AssetClass == '#N/A' && b.AssetClass != '#N/A') {
                returnValue = 1;
            } else if (a.AssetClass != '#N/A' && b.AssetClass == '#N/A') {
                returnValue = -1;
            }
            // Move #N/A be bottom
            if (!a.AssetClass && b.AssetClass) {
                returnValue = 1;
            } else if (a.AssetClass && !b.AssetClass) {
                returnValue = -1;
            }
            // Move isError bottom
            if (a.isError && !b.isError) {
                returnValue = 1;
            } else if (!a.isError && b.isError) {
                returnValue = -1;
            }
            if (b.AssetClass == 'ALL Total') {
                returnValue = -1;
            } else if (a.AssetClass == 'ALL Total') {
                returnValue = 1;
            }
            return returnValue;
        });
    },

    getEachUnitHolderPicklist: function (component, products) {
        var dropdownList = [];
        var idNumber = 0;

        // Add All Port first.
        dropdownList.push({
            id: 0,
            label: component.get('v.AllPort'),
            selected: true
        });
        idNumber = idNumber + 1;

        for (let i = 0; i < products.length; i++) {
            var index = dropdownList.findIndex((m) => {
                return (m.label == products[i].UnitHolderNo)
            });
            if (products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) {
                if (index === -1) {
                    dropdownList.push({
                        id: idNumber,
                        label: products[i].UnitHolderNo
                    });

                    idNumber = idNumber + 1;
                }
            }
        }

        return dropdownList;
    },

    getEachUnitHolderPicklist2: function (component, graphProductList) {
        var dropdownList = [];
        var idNumber = 0;
        var allPort = component.get('v.AllPort');

        // Add All Port first.
        dropdownList.push({
            id: 0,
            label: allPort,
            selected: true
        });
        idNumber = idNumber + 1;

        for (let i = 0; i < graphProductList.length; i++) {
            if (graphProductList[i].UnitHolderNo != allPort) {
                dropdownList.push({
                    id: idNumber,
                    label: graphProductList[i].UnitHolderNo
                });
            }
            idNumber = idNumber + 1;
        }

        return dropdownList;
    },

    sumTotalEachUnitHolderInvestmentProduct: function (products) {
        var sumTotal = [];
        var totalCostOfInvestment = 0;
        var totalMarketValue = 0;
        var totalUnrealizedGL = 0;
        var totalUnrealizedGLPerc = 0;
        for (let i = 0; i < products.length; i++) {
            var index = sumTotal.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo && m.ProductName == 'Total')
            });
            if (products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) {
                if (index === -1) {
                    sumTotal.push({
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': '',
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': products[i].MarketValue,
                        'UnrealizedGL': products[i].UnrealizedGL,
                        'UnrealizedGLPerc': (products[i].UnrealizedGL / products[i].CostOfInvestment) * 100,
                        'PercentWeight': ''
                    });
                } else {
                    sumTotal[index] = {
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': '',
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': sumTotal[index].CostOfInvestment + products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': sumTotal[index].MarketValue + products[i].MarketValue,
                        'UnrealizedGL': sumTotal[index].UnrealizedGL + products[i].UnrealizedGL,
                        'UnrealizedGLPerc': ((sumTotal[index].UnrealizedGL + products[i].UnrealizedGL) /
                            (sumTotal[index].CostOfInvestment + products[i].CostOfInvestment)) *
                            100,
                        'PercentWeight': ''
                    };
                }

                totalCostOfInvestment = totalCostOfInvestment + products[i].CostOfInvestment;
                totalMarketValue = totalMarketValue + products[i].MarketValue;
                totalUnrealizedGL = totalUnrealizedGL + products[i].UnrealizedGL;
                totalUnrealizedGLPerc = (totalUnrealizedGL / totalCostOfInvestment) * 100;
            }
        }

        sumTotal.push({
            'Type': $A.get('$Label.c.Investment_Product_Details'),
            'UnitHolderNo': 'ALL Total',
            'FundCode': '',
            'ProductName': 'Total',
            'AssetClass': '',
            'IssuerFundHouse': '',
            'NumberOfUnit': '',
            'NavUnit': '',
            'CostOfInvestment': totalCostOfInvestment,
            'AverageCostPerUnit': '',
            'MarketValue': totalMarketValue,
            'UnrealizedGL': totalUnrealizedGL,
            'UnrealizedGLPerc': totalUnrealizedGLPerc,
            'PercentWeight': ''
        });

        return products.concat(sumTotal);
    },

    sumTotalEachAssetClassInvestmentProduct: function (products) {
        var sumTotal = [];
        var totalCostOfInvestment = 0;
        var totalMarketValue = 0;
        var totalUnrealizedGL = 0;
        var totalUnrealizedGLPerc = 0;
        for (let i = 0; i < products.length; i++) {
            var index = sumTotal.findIndex((m) => {
                return (m.AssetClass == products[i].AssetClass && m.ProductName == 'Total')
            });
            if (products[i].AssetClass != '' && products[i].AssetClass != null) {
                if (index === -1) {
                    sumTotal.push({
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': '',
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': products[i].AssetClass,
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': products[i].MarketValue,
                        'UnrealizedGL': products[i].UnrealizedGL,
                        'UnrealizedGLPerc': (products[i].UnrealizedGL / products[i].CostOfInvestment) * 100,
                        'PercentWeight': ''
                    });
                } else {
                    sumTotal[index] = {
                        'Type': $A.get('$Label.c.Investment_Product_Details'),
                        'UnitHolderNo': '',
                        'FundCode': '',
                        'ProductName': 'Total',
                        'AssetClass': products[i].AssetClass,
                        'IssuerFundHouse': '',
                        'NumberOfUnit': '',
                        'NavUnit': '',
                        'CostOfInvestment': sumTotal[index].CostOfInvestment + products[i].CostOfInvestment,
                        'AverageCostPerUnit': '',
                        'MarketValue': sumTotal[index].MarketValue + products[i].MarketValue,
                        'UnrealizedGL': sumTotal[index].UnrealizedGL + products[i].UnrealizedGL,
                        'UnrealizedGLPerc': ((sumTotal[index].UnrealizedGL + products[i].UnrealizedGL) /
                            (sumTotal[index].CostOfInvestment + products[i].CostOfInvestment)) *
                            100,
                        'PercentWeight': ''
                    };
                }

                totalCostOfInvestment = totalCostOfInvestment + products[i].CostOfInvestment;
                totalMarketValue = totalMarketValue + products[i].MarketValue;
                totalUnrealizedGL = totalUnrealizedGL + products[i].UnrealizedGL;
                totalUnrealizedGLPerc = (totalUnrealizedGL / totalCostOfInvestment) * 100;
            }
        }

        sumTotal.push({
            'Type': $A.get('$Label.c.Investment_Product_Details'),
            'UnitHolderNo': '',
            'FundCode': '',
            'ProductName': 'Total',
            'AssetClass': 'ALL Total',
            'IssuerFundHouse': '',
            'NumberOfUnit': '',
            'NavUnit': '',
            'CostOfInvestment': totalCostOfInvestment,
            'AverageCostPerUnit': '',
            'MarketValue': totalMarketValue,
            'UnrealizedGL': totalUnrealizedGL,
            'UnrealizedGLPerc': totalUnrealizedGLPerc,
            'PercentWeight': ''
        });


        return products.concat(sumTotal);
    },

    groupEachUnitHolderDataForChart: function (products) {
        var finalList = [];
        var allTotal = [];

        for (let i = 0; i < products.length; i++) {
            var index = finalList.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo)
            });
            if ((products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) &&
                (products[i].AssetClass != '' && products[i].AssetClass != null)) {
                var costOfInvestment = 0;
                if (products[i].CostOfInvestment != '' && products[i].CostOfInvestment != null) {
                    costOfInvestment = products[i].CostOfInvestment;
                }
                if (index === -1) {
                    var sumTotal = [];
                    var newUnitHolder = [];
                    newUnitHolder.push(products[i].AssetClass, costOfInvestment);
                    sumTotal.push(newUnitHolder);

                    finalList.push({
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'Summary': sumTotal
                    });
                } else {
                    var indexAsset = finalList[index].Summary.findIndex((m) => {
                        return (m[0] == products[i].AssetClass)
                    });
                    if (indexAsset === -1) {
                        var newAssetClass = [];
                        newAssetClass.push(products[i].AssetClass, costOfInvestment);
                        finalList[index].Summary.push(newAssetClass);
                    } else {
                        finalList[index].Summary[indexAsset][1] = finalList[index].Summary[indexAsset][1] + costOfInvestment;
                    }
                }

                // Calculate all Total of each UnitHolder.
                if (allTotal.length > 0) {
                    var unitHolderIndex = allTotal.findIndex((m) => {
                        return (m[0] == products[i].UnitHolderNo)
                    });
                    if (unitHolderIndex != -1) {
                        allTotal[unitHolderIndex][1] = allTotal[unitHolderIndex][1] + costOfInvestment;
                    } else {
                        var eachTotal = [];
                        eachTotal.push(products[i].UnitHolderNo);
                        eachTotal.push(costOfInvestment);
                        allTotal.push(eachTotal);
                    }
                } else {
                    var eachTotal = [];
                    eachTotal.push(products[i].UnitHolderNo);
                    eachTotal.push(costOfInvestment);
                    allTotal.push(eachTotal);
                }
            }
        }

        for (let i = 0; i < finalList.length; i++) {
            for (let j = 0; j < finalList[i].Summary.length; j++) {
                var unitHolderIndex = allTotal.findIndex((m) => {
                    return (m[0] == finalList[i].UnitHolderNo)
                });
                var percent = 0;
                if (unitHolderIndex != -1) {
                    percent = parseFloat((finalList[i].Summary[j][1] * 100) / allTotal[unitHolderIndex][1]).toFixed(2);
                }
                finalList[i].Summary[j][0] = finalList[i].Summary[j][0] + ": " +
                    this.numberWithCommas(parseFloat(finalList[i].Summary[j][1]).toFixed(2)) + "฿(" +
                    percent + "%)";
                finalList[i].Summary[j][1] = parseFloat(finalList[i].Summary[j][1]).toFixed(2);
            }
        }

        return finalList;
    },

    groupEachUnitHolderData: function (component, products) {
        var finalList = [];
        var allTotal = [];

        for (let i = 0; i < products.length; i++) {
            var index = finalList.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo)
            });
            if ((products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) &&
                ((products[i].AssetClass != '' && products[i].AssetClass != null) ||
                    products[i].ProductName.includes('Total'))
            ) {
                if (index === -1) {
                    var newUnitHolder = [];
                    newUnitHolder.push(products[i]);

                    finalList.push({
                        'UnitHolderNo': products[i].UnitHolderNo,
                        'Data': newUnitHolder
                    });
                } else {
                    finalList[index].Data.push(products[i]);
                }
            }

            allTotal.push(products[i]);
        }

        finalList.push({
            'UnitHolderNo': component.get('v.AllPort'),
            'Data': allTotal
        });

        // for (let i = 0; i < finalList.length; i++){
        //     for(let j = 0; j < finalList[i].Summary.length; j++){
        //         finalList[i].Summary[j][0] = finalList[i].Summary[j][0] + ": "
        //                                     + this.numberWithCommas(parseFloat(finalList[i].Summary[j][1]).toFixed(2)) + "à¸¿";
        //         finalList[i].Summary[j][1] = parseFloat(finalList[i].Summary[j][1]).toFixed(2);
        //     }
        // }

        return finalList;
    },

    numberWithCommas: function (x) {
        var parts = x.toString().split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return parts.join(".");
    },

    sumTotalEachAssetClassInvForGraph: function (products) {
        var sumTotal = [];
        var allTotal = 0;
        for (let i = 0; i < products.length; i++) {
            var index = sumTotal.findIndex((m) => {
                return (m[0] == products[i].AssetClass)
            });
            if (products[i].AssetClass != '' && products[i].AssetClass != null) {
                if (index === -1) {
                    var eachTotal = [];
                    eachTotal.push(products[i].AssetClass, parseFloat(products[i].CostOfInvestment));
                    sumTotal.push(eachTotal);
                } else {
                    sumTotal[index][1] = sumTotal[index][1] + products[i].CostOfInvestment;
                }

                if (products[i].CostOfInvestment > 0) {
                    allTotal = allTotal + products[i].CostOfInvestment;
                }
            }
        }

        for (let i = 0; i < sumTotal.length; i++) {
            sumTotal[i][0] = sumTotal[i][0] + ": " + this.numberWithCommas(parseFloat(sumTotal[i][1]).toFixed(2)) + "฿(" +
                parseFloat((sumTotal[i][1] * 100) / allTotal).toFixed(2) + "%)";
            sumTotal[i][1] = parseFloat(sumTotal[i][1]).toFixed(2);
        }

        return sumTotal;
    },

    getTotalEachUnitHolderInvForGraph: function (products) {
        var sumTotal = [];
        var allTotal = 0;
        for (let i = 0; i < products.length; i++) {
            var productIndex = products.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo && m.ProductName == 'Total')
            });
            var sumIndex = sumTotal.findIndex((m) => {
                return (m[0] == products[i].UnitHolderNo)
            });
            if (products[i].UnitHolderNo != '' && products[i].UnitHolderNo != null) {
                if (sumIndex === -1 && products[productIndex].UnitHolderNo != 'ALL Total') {
                    var eachTotal = [];
                    eachTotal.push(products[productIndex].UnitHolderNo, parseFloat(products[productIndex].CostOfInvestment).toFixed(2));
                    sumTotal.push(eachTotal);
                    if (products[productIndex].CostOfInvestment > 0) {
                        allTotal = allTotal + products[productIndex].CostOfInvestment;
                    }
                }
            }
        }

        for (let i = 0; i < sumTotal.length; i++) {
            sumTotal[i][0] = sumTotal[i][0] + ": " + this.numberWithCommas(sumTotal[i][1]) + "฿(" +
                parseFloat((sumTotal[i][1] * 100) / allTotal).toFixed(2) + "%)";
        }

        return sumTotal;
    },

    getTotalEachAssetClassInvForGraph: function (products) {
        var sumTotal = [];
        var allTotal = 0;
        for (let i = 0; i < products.length; i++) {
            var productIndex = products.findIndex((m) => {
                return (m.AssetClass == products[i].AssetClass && m.ProductName == 'Total')
            });
            var sumIndex = sumTotal.findIndex((m) => {
                return (m[0] == products[i].AssetClass)
            });
            if (products[i].AssetClass != '' && products[i].AssetClass != null) {
                if (sumIndex === -1 && products[productIndex].AssetClass != 'ALL Total') {
                    var eachTotal = [];
                    eachTotal.push(products[productIndex].AssetClass, parseFloat(products[productIndex].CostOfInvestment).toFixed(2));
                    sumTotal.push(eachTotal);
                    if (products[productIndex].CostOfInvestment > 0) {
                        allTotal = allTotal + products[productIndex].CostOfInvestment;
                    }
                }
            }
        }

        for (let i = 0; i < sumTotal.length; i++) {
            sumTotal[i][0] = sumTotal[i][0] + ": " + this.numberWithCommas(sumTotal[i][1]) + "฿(" +
                parseFloat((sumTotal[i][1] * 100) / allTotal).toFixed(2) + "%)";
        }

        return sumTotal;
    },

    sortAssetClassFollowRecommend: function (component, graphProducts, recommendSort) {
        var finalData = [];
        var recommendList = [];
        for (let i = 0; i < graphProducts.length; i++) {
            var nameTemp = graphProducts[i][0];
            var assetClassName = nameTemp.substring(0, nameTemp.indexOf(':'));
            var productIndex = recommendSort.findIndex((m) => {
                return (m[0].toLowerCase() == assetClassName.toLowerCase())
            });
            if (productIndex != -1) {
                finalData.push(graphProducts[i]);
                recommendList.push(recommendSort[productIndex]);
            }
        }

        // Add the rest of data that not include in recommendList data yet.
        for (let i = 0; i < recommendSort.length; i++) {
            var Index = recommendList.findIndex((m) => {
                return (m[0] == recommendSort[i][0])
            });
            if (Index === -1) {
                recommendList.push(recommendSort[i]);
                var recommendTemp = [];
                recommendTemp.push(recommendSort[i][0] + ': 0.00฿(0%)');
                recommendTemp.push(0);
                finalData.push(recommendTemp);
            }
        }

        // Add the rest of data that not include in final data yet.
        for (let i = 0; i < graphProducts.length; i++) {
            var Index = finalData.findIndex((m) => {
                return (m[0] == graphProducts[i][0])
            });
            if (Index === -1) {
                finalData.push(graphProducts[i]);
            }
        }

        for (let i = 0; i < recommendList.length; i++) {
            recommendList[i][0] = recommendList[i][0] + ": " + recommendList[i][1] + "%";
        }

        component.set('v.investmentPTGraphRecommend', recommendList);

        return finalData;
    },

    generateGraphAP: function (component, listdata, selectUnitHolder) {
        var thisObject = this;
        var type = 'donut';
        var initialData = new Map();
        var selectedIndex = listdata.findIndex((m) => {
            return (m.UnitHolderNo == selectUnitHolder)
        });
        var data = listdata[selectedIndex].Summary;
        if (Array.isArray(data) && data.length) {
            var graph = c3.generate({
                // bindto: thisObject.template.querySelector('.chart-canvas'),
                // bindto: component.getElement().querySelector('.chart-canvas'),
                bindto: component.find('graphAP').getElement().querySelector('.chart-AP'),
                data: {
                    columns: initialData,
                    type: type.toLowerCase(),
                    labels: true
                    // onclick: function (d, i) {
                    //     var prod = d.name;
                    //     prod = prod.replace(/ /g,'%20');
                    //     // component.set('v.productGroup', prod);
                    //     thisObject.openReportTabHelper(component, prod);
                    // }
                },
                size: {
                    height: 200,
                },
                color: {
                    pattern: ['#cc2196', '#5bc0de', '#cc9900', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a', '#C0C0C0', '#800000', '#808000', '#008080', '#808080', '#663300', '#ccff66', '#993399', '#669900', '#0099cc', '#669999']
                },
                pie: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    }
                },
                donut: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    },
                    // title: d3.format(',')() + ' ฿'
                },
                interaction: {
                    enabled: true
                },
                // tooltip: {
                //     format: {
                //         // title: function (d) { return 'Value ' + d; },
                //         value: function (value, ratio, id) {
                //             var format = d3.format(','); //: d3.format('$');
                //             return format(value);
                //         }
                //     }
                // },
                legend: {
                    show: true,
                    position: 'right'
                }
            });

            setTimeout(function () {
                if (graph) {
                    graph.load({
                        columns: data
                    });
                }
            }, 500);
        }
    },

    generateGraphPTRec: function (component, listdata, type) {
        var thisObject = this;
        var initialData = new Map();
        if (Array.isArray(listdata) && listdata.length) {
            var graph = c3.generate({
                // bindto: thisObject.template.querySelector('.chart-canvas'),
                // bindto: component.getElement().querySelector('.chart-canvas'),
                bindto: component.find('graphPT').getElement().querySelector('.chart-PTRec'),
                data: {
                    columns: initialData,
                    type: type.toLowerCase(),
                    labels: true
                    // onclick: function (d, i) {
                    //     var prod = d.name;
                    //     prod = prod.replace(/ /g,'%20');
                    //     // component.set('v.productGroup', prod);
                    //     thisObject.openReportTabHelper(component, prod);
                    // }
                },
                size: {
                    height: 230,
                    width: 400
                },
                color: {
                    pattern: ['#cc2196', '#5bc0de', '#cc9900', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a', '#C0C0C0', '#800000', '#808000', '#008080', '#808080', '#663300', '#ccff66', '#993399', '#669900', '#0099cc', '#669999']
                },
                pie: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    }
                },
                donut: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    },
                    // title: d3.format(',')() + ' ฿'
                },
                interaction: {
                    enabled: true
                },
                // tooltip: {
                //     format: {
                //         // title: function (d) { return 'Value ' + d; },
                //         value: function (value, ratio, id) {
                //             var format = d3.format(','); //: d3.format('$');
                //             return format(value);
                //         }
                //     }
                // },
                legend: {
                    show: true,
                    position: 'right'
                }
            });

            setTimeout(function () {
                if (graph) {
                    graph.load({
                        columns: listdata
                    });
                }
            }, 500);
        }
    },

    generateGraphPT: function (component, listdata, selectUnitHolder) {
        var thisObject = this;
        var type = 'donut';
        var initialData = new Map();
        var selectedIndex = listdata.findIndex((m) => {
            return (m.UnitHolderNo == selectUnitHolder)
        });
        var data = listdata[selectedIndex].Summary;
        if (Array.isArray(data) && data.length) {
            var graph = c3.generate({
                // bindto: thisObject.template.querySelector('.chart-canvas'),
                // bindto: component.getElement().querySelector('.chart-canvas'),
                bindto: component.find('graphPT').getElement().querySelector('.chart-PT'),
                data: {
                    columns: initialData,
                    type: type.toLowerCase(),
                    labels: true
                    // onclick: function (d, i) {
                    //     var prod = d.name;
                    //     prod = prod.replace(/ /g,'%20');
                    //     // component.set('v.productGroup', prod);
                    //     thisObject.openReportTabHelper(component, prod);
                    // }
                },
                size: {
                    height: 250,
                    width: 800
                },
                color: {
                    pattern: ['#cc2196', '#5bc0de', '#cc9900', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a', '#C0C0C0', '#800000', '#808000', '#008080', '#808080', '#663300', '#ccff66', '#993399', '#669900', '#0099cc', '#669999']
                },
                pie: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    }
                },
                donut: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    },
                    // title: d3.format(',')() + ' ฿'
                },
                interaction: {
                    enabled: true
                },
                // tooltip: {
                //     format: {
                //         // title: function (d) { return 'Value ' + d; },
                //         value: function (value, ratio, id) {
                //             var format = d3.format(','); //: d3.format('$');
                //             return format(value);
                //         }
                //     }
                // },
                legend: {
                    show: true,
                    position: 'right'
                }
            });

            setTimeout(function () {
                if (graph) {
                    graph.load({
                        columns: data
                    });
                }
            }, 500);
        }
    },

    generateGraphLTF: function (component, listdata, type) {
        var thisObject = this;
        var initialData = new Map();

        if (Array.isArray(listdata) && listdata.length) {
            var graph = c3.generate({
                // bindto: thisObject.template.querySelector('.chart-canvas'),
                // bindto: component.getElement().querySelector('.chart-canvas'),
                bindto: component.find('graphLTF').getElement().querySelector('.chart-LTF'),
                data: {
                    columns: initialData,
                    type: type.toLowerCase(),
                    labels: true
                    // onclick: function (d, i) {
                    //     var prod = d.name;
                    //     prod = prod.replace(/ /g,'%20');
                    //     // component.set('v.productGroup', prod);
                    //     thisObject.openReportTabHelper(component, prod);
                    // }
                },
                size: {
                    height: 200,
                },
                color: {
                    pattern: ['#cc2196', '#5bc0de', '#cc9900', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a', '#C0C0C0', '#800000', '#808000', '#008080', '#808080', '#663300', '#ccff66', '#993399', '#669900', '#0099cc', '#669999']
                },
                pie: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    }
                },
                donut: {
                    label: {
                        format: function (value, ratio, id, name) {
                            return d3.format('0.2%')(ratio);
                        }
                    },
                    // title: d3.format(',')() + ' ฿'
                },
                interaction: {
                    enabled: true
                },
                // tooltip: {
                //     format: {
                //         // title: function (d) { return 'Value ' + d; },
                //         value: function (value, ratio, id) {
                //             var format = d3.format(','); //: d3.format('$');
                //             return format(value);
                //         }
                //     }
                // },
                legend: {
                    show: true,
                    position: 'right'
                }
            });

            setTimeout(function () {
                if (graph) {
                    graph.load({
                        columns: listdata
                    });
                }
            }, 500);
        }
    },

    calculatePercentWeight: function (products) {
        var indexOfAllTotal = products.findIndex((m) => {
            return (m.AssetClass == 'ALL Total' || m.UnitHolderNo == 'ALL Total')
        });
        var totalCostOfInvestment = products[indexOfAllTotal].CostOfInvestment;
        for (let i = 0; i < products.length; i++) {
            // if (products[i].AssetClass != 'ALL Total' && products[i].UnitHolderNo != 'ALL Total') {
            products[i].PercentWeight = (products[i].CostOfInvestment / totalCostOfInvestment) * 100;
            // }
        }

        return products;
    },

    calculatePercentWeightPerPort: function (products) {
        // var indexOfAllTotal = products.findIndex((m) => {return (m.AssetClass == 'ALL Total' || m.UnitHolderNo == 'ALL Total')});
        // var totalCostOfInvestment = products[indexOfAllTotal].CostOfInvestment;
        for (let i = 0; i < products.length; i++) {
            var indexOfTotal = products.findIndex((m) => {
                return (m.UnitHolderNo == products[i].UnitHolderNo && m.ProductName == 'Total')
            });
            var totalCostOfInvestment = products[indexOfTotal].CostOfInvestment;
            products[i].PercentWeight = (products[i].CostOfInvestment / totalCostOfInvestment) * 100;
        }

        return products;
    },

    sortDepositProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            // returnValue = a.Status != 'NOTFND' && b.Status == 'NOTFND' ? -1 : (a.Status != 'NOTFND' && b.Status == 'NOTFND' ? 1 : 0);
            return returnValue;
        });
    },

    sortCreditRDCProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            returnValue = a.Status == 'NOTFND' && b.Status != 'NOTFND' ? 1 : (a.Status != 'NOTFND' && b.Status == 'NOTFND' ? -1 : 0);
            return returnValue;
        });
    },

    sortLoanProduct: function (products) {
        return products.sort(function (a, b) {
            var returnValue = a.isError && !b.isError ? 1 : (!a.isError && b.isError ? -1 : 0);
            // returnValue = a.Status != 'NOTFND' && b.Status == 'NOTFND' ? -1 : (a.Status != 'NOTFND' && b.Status == 'NOTFND' ? 1 : 0);
            return returnValue;
        });
    },

    getNumberOfAccount: function (products) {
        return products.reduce(function (l, i) {
            return l + i.Number_of_Account;
        }, 0);
    },

    getTotalDepositeOutstanding: function (products) {
        return products.filter(function (f) {
            // SeqGrp => product group
            return ['1', '2', '5'].includes(f.SeqGrp);
        }).reduce(function (l, i) {
            return l + (i.Outstanding ? i.Outstanding : 0);
        }, 0);
    },

    getWatermarkHTML: function (component) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var watermarkHTML = response.getReturnValue();

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if (state === 'ERROR') {
                console.log('error: ', response.error);
            } else {
                console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    errorCodeSCSIncludes: function (error_code, error_status) {
        var isInclude = false;
        error_status.forEach((e, i) => {
            if (e.error_code == error_code) {
                isInclude = true;
            }
        });
        return isInclude;
    },

    choiceErrorHandle: function (component, helper) {
        var errorControlObj = component.get('v.errorMessageControl');
        let checkObj = errorControlObj.timeout;
        errorControlObj.isShowMessage.Retry = helper.checkedServiceFromErrorMessageControl(checkObj);
        var componentRetry = [];
        if (errorControlObj.isShowMessage.Retry) {
            errorControlObj.retry.OSC = checkObj.Deposit || checkObj.Investment || checkObj.Loan || checkObj.OSC;
            errorControlObj.retry.CardBal = checkObj.CardBal;
            errorControlObj.retry.Bancassurance = checkObj.Bancassurance;
            if (errorControlObj.timeout.OSC) {
                componentRetry.push(helper.createComponentProductReference(component, true, errorControlObj.productTag.Deposit, errorControlObj.productName.Deposit, 'onClickDeposit'));
                componentRetry.push(helper.createComponentProductReference(component, true, errorControlObj.productTag.Loan, errorControlObj.productName.Loan, 'onClickLoan'));
                componentRetry.push(helper.createComponentProductReference(component, true, errorControlObj.productTag.Investment, errorControlObj.productName.Investment, 'onClickInvestment'));
            } else {
                componentRetry.push(helper.createComponentProductReference(component, errorControlObj.timeout.Deposit, errorControlObj.productTag.Deposit, errorControlObj.productName.Deposit, 'onClickDeposit'));
                componentRetry.push(helper.createComponentProductReference(component, errorControlObj.timeout.Loan, errorControlObj.productTag.Loan, errorControlObj.productName.Loan, 'onClickLoan'));
                componentRetry.push(helper.createComponentProductReference(component, errorControlObj.timeout.Investment, errorControlObj.productTag.Investment, errorControlObj.productName.Investment, 'onClickInvestment'));
            }
            componentRetry.push(helper.createComponentProductReference(component, errorControlObj.timeout.CardBal, errorControlObj.productTag.CardBal, errorControlObj.productName.CardBal, 'onClickCreditCard'));
            componentRetry.push(helper.createComponentProductReference(component, errorControlObj.timeout.Bancassurance, errorControlObj.productTag.Bancassurance, errorControlObj.productName.Bancassurance, 'onClickBancassurance'));

            [...new Set(errorControlObj.products)].forEach(e => {
                componentRetry.push(helper.createComponentProductReference(
                    component,
                    errorControlObj.timeout[e],
                    errorControlObj.productTag[e],
                    errorControlObj.productName[e],
                    'onClickHref'
                ));
            });
            helper.setComponentRetry(component, $A.get('$Label.c.Product_Holding_ReRequest_v3'), componentRetry);
        }
        errorControlObj.isShowMessage.Snow = helper.checkedServiceFromErrorMessageControl(errorControlObj.error);
        errorControlObj.showMessage = errorControlObj.message ? true : false;
        // errorControlObj need to use and change in setInfoMessage
        component.set('v.errorMessageControl', errorControlObj);
        component.set('v.errorMessage', errorControlObj.message);
        helper.setInfoMessage(component, helper);
        //
        errorControlObj = component.get('v.errorMessageControl');
        errorControlObj.isShowMessage.Info = errorControlObj.someInfoError && !(errorControlObj.isShowMessage.Retry) ? true : false;
        component.set('v.errorMessageControl', errorControlObj);
        component.set('v.errorMessage', errorControlObj.message);
        helper.checkIsShowErrorAfterChoice(component, errorControlObj);
    },

    resetErrorControlByTypefunction: function (component, helper, type) {
        component.set('v.errorMessageControl.timeout.' + type, false);
        if (type = 'OSC') {
            component.set('v.errorMessageControl.timeout.Deposit', false);
            component.set('v.errorMessageControl.timeout.Loan', false);
            component.set('v.errorMessageControl.timeout.Investment', false);
        }
        component.set('v.errorMessageControl.showMessage', false);
    },

    setInfoMessage: function (component, helper) {
        var errorControlObj = component.get('v.errorMessageControl');
        if (errorControlObj.error.OSC) {
            var DepositProduct = {
                isError: true,
                Tag: "Deposit_Product_Details",
                Type: errorControlObj.productName.Deposit
            };
            var LoanProduct = {
                isError: true,
                Tag: "Loan_Product_Details",
                Type: errorControlObj.productName.Loan
            };
            var InvestmentProduct = {
                isError: true,
                Tag: "Investment_Product_Details",
                Type: errorControlObj.productName.Investment
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.DepositProduct = DepositProduct;
            productErrors.LoanProduct = LoanProduct;
            productErrors.InvestmentProduct = InvestmentProduct;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }
        if (errorControlObj.error.Bancassurance) {
            var BancassuranceProduct = {
                isError: true,
                Tag: "Bancassurance_Product_Details",
                Type: errorControlObj.productName.Bancassurance
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.BancassuranceProduct = BancassuranceProduct;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }
        if (errorControlObj.error.CardBal) {
            var CreditCardProduct = {
                isError: true,
                Tag: "Credit_Card_RDC_Product_Details",
                Type: errorControlObj.productName.CardBal
            };
            var productErrors = component.get('v.errorMessageControl.productErrors');
            productErrors.CreditCardProduct = CreditCardProduct;
            component.set('v.errorMessageControl.productErrors', productErrors);
        }

        var list = Object.keys(component.get('v.errorMessageControl.productErrors')).reduce((lst, key) => {
            lst.push(component.get(`v.errorMessageControl.productErrors.${key}`));
            return lst;
        }, [].concat(component.get('v.depositProduct.datas')
            .concat(component.get('v.creditCardRDCProduct.datas'))
            .concat(component.get('v.loanProduct.datas'))
            .concat(component.get('v.bancassuranceProduct.datas'))
            .concat(component.get('v.investmentProduct.datas'))));

        if (list.some(s => s.isError ? s.isError : false) || list.some(s => s.isTimeout ? s.isTimeout : false)) {
            component.set('v.errorMessageControl.someInfoError', true);
            helper.displaySubErrorMessage(component, 'Warning!', $A.get('$Label.c.INT_Investment_Incomplete_Info'), 'someInfoError');

            $A.createComponents(
                list.filter(function (f) {
                    return f.isError;
                })
                    .reduce(function (l, i) {
                        var isNotDuplicateProductGroup = !l.find(function (f) {
                            return f.Tag == i.Tag;
                        });
                        if (isNotDuplicateProductGroup) {
                            l.push(i);
                        }
                        return l;
                    }, [])
                    .reduce(function (l, i, index, arrays) {
                        l.push([
                            "aura:html", {
                                tag: "a",
                                HTMLAttributes: {
                                    class: 'notFound',
                                    name: i.Tag,
                                    onclick: component.getReference("c.onClickHref")
                                },
                                body: index < arrays.length - 1 ? i.Type + ', ' : i.Type,
                            }
                        ])
                        return l;
                    }, []),
                function (cmp, status, errorMessage) {
                    if (status === "SUCCESS") {
                        component.set('v.error.hrefList',
                            !helper.checkedServiceFromErrorMessageControl(errorControlObj.timeout) ?
                                cmp : ''
                        );
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    },

    setComponentRetry: function (component, message, componentRetry) {
        var messageTimeout = message.split('{1}');
        var messageTimeoutLink = messageTimeout[1].split('{0}');
        var componentMessage = [];
        component.set('v.errorMessageControl.messages.Retry', '');
        var componentComma = ["aura:html", {
            tag: "span",
            HTMLAttributes: {
                class: 'redText'
            },
            body: ', '
        }];
        var isNeedComma = false;
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeout[0]
        }]);
        componentRetry.forEach(e => {
            if (e[0]) {
                if (isNeedComma) {
                    componentMessage.push(componentComma);
                }
                componentMessage.push(e);
                isNeedComma = true;
            }
        });
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeoutLink[0]
        }]);
        componentMessage.push(["aura:html", {
            tag: "a",
            HTMLAttributes: {
                name: 'refreshView',
                onclick: component.getReference("c.onClickRetry")
            },
            body: $A.get("$Locale.language") == 'th' ? 'คลิกที่นี่' : 'Click Here',
        }]);
        componentMessage.push(["aura:html", {
            tag: "span",
            body: messageTimeoutLink[1]
        }]);
        $A.createComponents(
            componentMessage,
            function (cmp, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.errorMessageControl.messages.Retry', cmp);
                }
            }
        );
    },

    retryCreditcard: function (component, event, helper, round) {
        component.set('v.creditCardRDCProduct.datas', []);
        component.set('v.error.messages.CardBal', '');
        // component.set('v.error.messages.OSC01', '');
        component.set('v.error.message', '');
        // component.set('v.error.hrefList', '');
        component.set('v.isSuccess', false);
        // component.set('v.error.state', false);
        component.set('v.creditCardRDCProduct.isLoading', true);
        helper.checkIsShowError(component);
        helper.resetErrorControlByTypefunction(component, helper, 'CardBal');
        helper.GetCreditCard(component, helper, round);
    },

    retryBancassurance: function (component, helper, round) {
        component.set('v.bancassuranceProduct.datas', []);
        component.set('v.error.messages.Bancassurance', '');
        component.set('v.error.message', '');
        component.set('v.isSuccess', false);
        component.set('v.bancassuranceProduct.isLoading', true);
        helper.checkIsShowError(component);
        helper.resetErrorControlByTypefunction(component, helper, 'Bancassurance');
        helper.GetBancassurance(component, helper, round);
    },

    retryOSC01: function (component, event, helper, round) {
        helper.resetDataOSC(component);
        component.set('v.error.messages.OSC01', '');
        component.set('v.error.message', '');
        component.set('v.isSuccess', false);
        helper.setIsLoadingProductOSC(component, true);
        helper.checkIsShowError(component);
        helper.resetErrorControlByTypefunction(component, helper, 'OSC');
        helper.callProduct(component, event, helper, round);
    },

    checkedServiceFromErrorMessageControl: function (checkObject) {
        return Object.keys(checkObject).reduce((l, key) => l || checkObject[key], false);
        // return checkObject.Bancassurance || checkObject.CardBal || checkObject.Deposit || checkObject.Investment || checkObject.Loan || checkObject.OSC;
    },

    calloutProductTag: function (component, prouductTag) {
        var helper = this;
        var childProduct = component.find(prouductTag);
        if (childProduct) childProduct.calloutService();
    },

    createComponentProductReference: function (component, isCreate, Tag, Type, onClickProduct) {
        if (isCreate) {
            return [
                "aura:html", {
                    tag: "a",
                    HTMLAttributes: {
                        // style: 'display: block;',
                        class: 'notFound',
                        name: Tag,
                        'data-namehref': onClickProduct,
                        onclick: component.getReference('c.onClickHref')
                    },
                    body: Type,
                }
            ];
        }
        return [];
    },

    getRedProductcodeList: function (component, helper, product) {
        var action = component.get('c.getRedProductcode');
        action.setParams({});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                //console.dir('result :' + result);
                component.set('v.mainBankProductCode', result);
            }
            else {
            }
        });
        $A.enqueueAction(action);

    },

    getIsUnmaskData: function (component, helper) {
        var action = component.get('c.getUnmaskBalance');
        var returnValue = "{}";
        var jsonData;
        action.setCallback(this, function (response) {
            returnValue = response.getReturnValue();
            jsonData = JSON.parse(returnValue);
            component.set('v.unmasked', jsonData);
        });

        $A.enqueueAction(action);
    },
})