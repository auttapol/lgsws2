({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component, $A.get('$Label.c.Details_of_Investment_Product'));
        component.set('v.fields.InvestmentInfo', [{
            label: $A.get('$Label.c.Unit_Holder_No'),
            fieldName: 'UnitHolderNo',
        }, {
            label: $A.get('$Label.c.Product_Name'),
            fieldName: 'ProductName',
        }, {
            label: $A.get('$Label.c.Asset_Class'),
            fieldName: 'AssetClass',
        }, {
            label: $A.get('$Label.c.Product_Sub_Group'),
            fieldName: 'SubProductGroup',
        }, {
            fieldName: '',
        }, {
            label: $A.get('$Label.c.Issuer_Fund_House'),
            fieldName: 'IssuerFundHouse',
        }, {
            label: $A.get('$Label.c.Number_of_unit'),
            fieldName: 'NumberOfUnit',
            type: 'NUMBER'
        }, {
            label: $A.get('$Label.c.Cost_of_Investment'),
            fieldName: 'CostOfInvestment',
            type: 'NUMBER'
        }, {
            label: $A.get('$Label.c.Market_Value'),
            fieldName: 'MarketValue',
            type: 'NUMBER'
        }, {
            label: $A.get('$Label.c.Average_cost_per_unit'),
            fieldName: 'AverageCostPerUnit',
            type: 'NUMBER4'
        }, {
            label: $A.get('$Label.c.NAV_Unit'),
            fieldName: 'NAVUnit',
            type: 'NUMBER4'
        }, {
            label: $A.get('$Label.c.Unrealized_G_L'),
            fieldName: 'UnrealizedGL',
            type: 'NUMBER'
        }, {
            label: $A.get('$Label.c.AIP_instruction'),
            fieldName: 'AipInstruction',
        }, {
            label: $A.get('$Label.c.percent_of_Unrealized_G_L'),
            fieldName: 'UnrealizedGLPerc',
            type: 'PERCENT'
        }].map(function (i) {
            i.isAccessible = i.fieldName ? true : false;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.AutoInvestmentPlan.columns', [{
            label: $A.get('$Label.c.AIP_Since_Date'),
            fieldName: 'SinceDate',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
        }, {
            label: $A.get('$Label.c.AIP_Created_Channel'),
            fieldName: 'CreatedChannel',
            type: 'text',
        }, {
            label: $A.get('$Label.c.AIP_frequency'),
            fieldName: 'Frequency',
            type: 'text',
        }, {
            label: $A.get('$Label.c.AIP_date'),
            fieldName: 'Date',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            }
        }, {
            label: $A.get('$Label.c.AIP_balance'),
            fieldName: 'Balance',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Saving_account_bundling'),
            fieldName: 'SavingAccountBundling',
            type: 'text',
        }, ]);

        component.set('v.InvestmentTransaction.columns', [{
            label: $A.get('$Label.c.Settlement_Date'),
            fieldName: 'SettlementDate',
            // type: 'text',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            },
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
        }, {
            label: $A.get('$Label.c.Trn_Type'),
            fieldName: 'TransactionType',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Interact_Channel'),
            fieldName: 'InteractChannel',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Unit_Movement'),
            fieldName: 'UnitMovement',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Trn_Value'),
            fieldName: 'TransactionValue',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Value_Per_Unit'),
            fieldName: 'ValuePerUnit',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Status'),
            fieldName: 'Statue',
            type: 'text',
        }, ]);

        // helper.getInvestmentAccountList(component, event, helper);
        helper.getInvestmentAccountDetail(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);
        window.scrollTo(0, 0);
    },
})