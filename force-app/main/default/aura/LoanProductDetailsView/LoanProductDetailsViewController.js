({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component, $A.get('$Label.c.Loan_Product_Detail'));

        component.set('v.fields.LoanInformation', [{
                label: $A.get('$Label.c.Account_Number'),
                fieldName: 'MarkedLoanAccountNumber',
            },
            {
                label: $A.get('$Label.c.Product_Name'),
                fieldName: 'ProductName',
            },
            {
                label: $A.get('$Label.c.Open_Date'),
                fieldName: 'OpenDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Product_Sub_Group'),
                fieldName: 'SubProductGroup',
            },
            {
                label: $A.get('$Label.c.Account_Status'),
                fieldName: 'AccountStatus',
            },
            {
                label: $A.get('$Label.c.Campaign_Name'),
                fieldName: 'CampaignName',
            },
            {
                label: $A.get('$Label.c.Has_Co_borrower'),
                fieldName: 'HasCoBorrower',
            },
            {
                label: $A.get('$Label.c.Contract_End_Date'),
                fieldName: 'ContractEndDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Outstanding_Deposit'),
                fieldName: 'MarkedOutstanding',
            },
            {
                label: $A.get('$Label.c.Last_Payment_Date'),
                fieldName: 'LastPaymentDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Loan_Credit_Limit'),
                fieldName: 'MarkedVLimit',
            },
            {
                label: $A.get('$Label.c.Payment_Due_Date'),
                fieldName: 'PaymentDueDate',
                // type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Current_Tenor'),
                fieldName: 'CurrentTenor',
                //type: 'NUMBER',
            },
            {
                label: $A.get('$Label.c.Tenor_Month'),
                fieldName: 'Tenor',
                // type: 'NUMBER',
            },
            {
                label: $A.get('$Label.c.Remain_Period_Detail'),
                fieldName: 'past_due_payment_count',
                // type: 'INTEGER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.past_due_payment_count',
            },
            {
                label: $A.get('$Label.c.Overdue_Amount_Detail'),
                fieldName: 'late_charges_amount',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.total_past_due_amount',
                mask: true,
            },
            {
                label: $A.get('$Label.c.Penalty_Fee_Detail'),
                fieldName: 'total_past_due_amount',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.late_charges_amount',
                mask: true,
            },
            {
                label: $A.get('$Label.c.Collection_Fee_Detail'),
                fieldName: 'fee_due_amount',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.fee_due_amount',
                mask: true,
            },
        ].map(function (i) {
            i.type = i.type ? i.type : 'STRING';
            return i;
        // }).filter(f => f ));
        }).filter(f => component.get('v.SeqGrp') === '7' ? f : !f.productType));

        component.set('v.fields.VehicleInformation', [{
                label: $A.get('$Label.c.Plate_No'),
                fieldName: 'license_no',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.license_no',
            },
            {
                label: $A.get('$Label.c.Car_Description'),
                fieldName: 'car_details',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.car_details',
            },
            {
                label: $A.get('$Label.c.SN_Body'),
                fieldName: 'chasis_no',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.chasis_no',
            },
            {
                label: $A.get('$Label.c.SN_Engine'),
                fieldName: 'engine_no',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.engine_no',
            },
            {
                label: $A.get('$Label.c.Car_Registration_Date'),
                fieldName: 'car_regis_date',
                // type: 'DATE',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.car_regis_date',
            },
            {
                label: $A.get('$Label.c.Appraisal_Price'),
                fieldName: 'committee_price',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.committee_price',
                mask: true,
            },
            {
                label: $A.get('$Label.c.Car_Tax_Date'),
                fieldName: 'tax_due_date',
                // type: 'DATE',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.tax_due_date',
            },
            {
                label: $A.get('$Label.c.Appraisal_Date'),
                fieldName: 'req_date',
                // type: 'DATE',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.req_date',
            },
            {
                label: $A.get('$Label.c.Collateral_Status'),
                fieldName: 'custdn_status_desc',
                // type: 'NUMBER',
                productType: 'CYB',
                referenceKey: 'cyb_product_detail.custdn_status_desc',
            },
        ].map(function (i) {
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));


        var arrays = [];
        for (let index = 0; index < 4; index++) {
            const element = [{
                label: `${$A.get('$Label.c.Guarantor_Name')} ${index + 1}`,
                fieldName: 'c_name',

            }, {
                label: $A.get('$Label.c.ID_Number'),
                fieldName: 'id_no',

            }, {
                label: $A.get('$Label.c.Birth_Date'),
                fieldName: 'id_birth_date',
                // type: 'DATE'
            }, {
                label: '',
                fieldName: '',
                class: 'slds-hide'
            }];
            arrays = arrays.concat(element);
        }
        component.set('v.fields.Guarantor', arrays.map(function (i) {
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        // component.set('v.fields.CoBorrowerInformation', [{
        //         label: $A.get('$Label.c.Co_Borrower_Name'),
        //     },
        //     {
        //         label: $A.get('$Label.c.Relationship'),
        //     },
        // ].map(i => {
        //     i.isAccessible = true;
        //     i.type = i.type ? i.type : 'STRING';
        //     return i;
        // }));

        component.set('v.fields.LoanPaymentInformation', [{
                label: $A.get('$Label.c.Payment_Method_Loan'),
                fieldName: 'PaymentMethod',
                type: 'PARSE',
                fieldKey: 'PaymentMethod',
                funcName: 'translatedPaymentMethod'
            },
            {
                label: $A.get('$Label.c.Payroll_deduction_unit'),
                fieldName: 'PayrollDeductionUnit',
            },
            {
                label: $A.get('$Label.c.Saving_account'),
                fieldName: 'SavingAccount',
                type: 'PARSE',
                fieldKey: 'SavingAccount',
                funcName: 'MarkedSavingAccount'
            },
            {
                label: $A.get('$Label.c.Installment_balance'),
                fieldName: 'InstallmentBalance',
                // type: 'NUMBER'
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.InterestPlan.columns', [{
            label: $A.get('$Label.c.Account_Number'),
            fieldName: 'AccountNumber',
            type: 'text',
            cellAttributes: {
                class: {
                    fieldName: 'ERROR'
                }
            },
        }, {
            label: $A.get('$Label.c.Period'),
            fieldName: 'Period',
            type: 'text',
        }, {
            label: $A.get('$Label.c.Interest_Rate'),
            fieldName: 'InterestRate',
            type: 'text',
        }, ]);

        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set('v.retrySetTimeOut', retrySetTimeOut);
        component.set('v.numOfRetryTime', numOfRetryTime);
        component.set('v.product', helper.decodeObject(component.get('v.product')));
        helper.getLoanProductDetailsView(component, event, helper,0);
        if (component.get('v.SeqGrp') === '7') helper.callCYBProduct(component, event, helper);
        window.scrollTo(0, 0);
    },
    retryCallout: function (component, event, helper) {
        
        if (component.get('v.error.retry').length > 0) {
            [...new Set(component.get('v.error.retry'))].forEach(e => {
                // Remove retry service timeout
                component.set('v.error.retry', component.get('v.error.retry').filter(f => f !== e));
                switch (e) {
                    case 'OSC04':
                        helper.getLoanProductDetailsView(component, event, helper);
                        break;
                    case 'CYB':
                        helper.getLoanProductCYB(component, event, helper);
                        break;
                    case 'Guarantor':
                        helper.getGuarantorCYB(component, event, helper);
                        break;
                    default:
                        break;
                }
            })
        }
    },

    handleClickHref: function (component, event, helper) {
        event.preventDefault();
        var theme = component.get('v.theme');
        if (component.find(event.srcElement.name)) {
            if (theme == 'Theme3' || theme == 'Theme4u') {
                component.find(event.srcElement.name).getElement().scrollIntoView({
                    block: 'start',
                    behavior: "smooth"
                });
            } else {
                component.find('scrollerWrapper').scrollTo('custom', 0, component.find(event.srcElement.name).getElement().offsetTop);
            }
        }
    },
    waterMark: function (component, event, helper) {
        var watermark = component.find('watermark');
        if (watermark && watermark.isValid()) {
            component.set('v.waterMarkImage', watermark.get('v.watermarkHtml'));
        }
    },
})