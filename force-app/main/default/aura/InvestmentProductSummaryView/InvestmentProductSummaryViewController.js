({
    doInit : function(component, event, helper){
        helper.getAccessibleCusHold(component, event, helper);
        component.set('v.investmentProduct.columns', [{
            label: $A.get('$Label.c.Unit_Holder_No'),
            type: 'button',
            typeAttributes: {
                variant: 'base',
                label: {
                    // fieldName: 'DisplayUnitHolderNo'
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
            // fieldName: 'DisplayAssetClass',
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
            // fieldName: 'DisplayAssetClass',
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
            // fieldName: 'DisplayAssetClass',
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
            // fieldName: 'DisplayAssetClass',
            type: 'text',
            cellAttributes: {
                alignment: 'left'
            },
            fixedWidth: component.get('v.theme') == 'Theme4t' ? 125 : 100,
            isAccessible: 'isAccessibleCusHoldHig',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
            type: 'text',
            wrapText: true,
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
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);

        if(component.get('v.allowCallChild') == false){
            var parentComponent = component.get("v.parent");   
            const sendToParent = new Map();
            sendToParent.set('InvestmentProductSummaryViewStatus', "success");
            sendToParent.set('InvestmentProductSummaryView', 'default');
            parentComponent.handleReturnData(sendToParent);
        }
    },

    handlerAccount : function(component, event, helper) {
        const fieldAccess = helper.getFieldAccessibility(component, event, helper);
        fieldAccess.then((data) => {
            component.set('v.fieldAccessible', data);
            helper.doInitErrorMessageControl(component, event, helper);
            const resultFrom01 = component.get('v.resultFrom01');
            if(resultFrom01.StatusCode != null ){
                var parentComponent = component.get("v.parent");   
                const sendToParent = new Map();
                sendToParent.set('InvestmentProductSummaryViewStatus', "error");
                sendToParent.set('InvestmentProductSummaryView', 'default');
                parentComponent.handleReturnData(sendToParent);
            }
            else{
                helper.callgetInvestmentlist(component, event, helper, component.get('v.resultFrom01'));
            }
        });
    },

    onViewClickHref: function (component, event, helper) {
        var row = event.getParam('row');
        if (!row.isError && row.link) {
            var theme = component.get('v.theme');
            if (theme == 'Theme3') {
                var appEvent = $A.get("e.c:CallCenterCSV_ProductHoldingEvent");
                appEvent.setParams({
                    'componentName': row.Tag,
                    'tabName': row.TabName,
                    'params': row.link.replace('/one/one.app#', '')
                });
                appEvent.fire();
            } else if (theme == 'Theme4t' || theme == 'Theme4d') {
                var navService = component.find('navService');
                navService.navigate({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": row.link
                    }
                }, false);
            } else {
                // Theme4u
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    workspaceAPI.openSubtab({
                        parentTabId: tabId,
                        url: row.link,
                        focus: true
                    });
                })
                    .catch(function (error) {
                        console.log(error);
                    });
            }
        }
    },
})