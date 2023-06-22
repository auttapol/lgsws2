({
    onInit: function (component, event, helper) {
        helper.doWorkspaceAPI(component, event, helper, $A.get('$Label.c.Details_of_Bancassurance_Product'));

        component.set('v.fields.BancassuranceInformation', [{
                label: $A.get('$Label.c.Policy_No'),
                fieldName: 'PolicyNo',
            },
            {
                label: $A.get('$Label.c.Product_Name'),
                fieldName: 'ProductName',
            },
            {
                label: $A.get('$Label.c.BA_Plan'),
                fieldName: 'TMBProductCode',
                type: 'PARSE',
                fieldKey: 'TMBProductCode',
                funcName: 'BAPlan',
            },
            {
                label: $A.get('$Label.c.Product_Type'),
                fieldName: 'ProductType',
            },
            {
                label: $A.get('$Label.c.Effective_Date'),
                fieldName: 'EffectiveDate',
                type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Sum_Insure'),
                fieldName: 'SumInsured',
                type: 'INTEGER',
            },
            {
                label: $A.get('$Label.c.Expiry_Date'),
                fieldName: 'ExpiryDate',
                type: 'DATE',
            },
            {
                label: $A.get('$Label.c.AFYP'),
                fieldName: 'AFYP',
                type: 'INTEGER',
            },
            {
                label: $A.get('$Label.c.Status'),
                fieldName: 'PolicyStatus',
            },
            {
                label: $A.get('$Label.c.Sales'),
                fieldName: 'Sales',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));


        component.set('v.fields.BancassuranceDetails', [{
                label: $A.get('$Label.c.Insurance_Company'),
                fieldName: 'InsuranceCompany',
            },
            {
                label: $A.get('$Label.c.Address'),
                fieldName: 'Address',
                type: 'PARSE',
                fieldKey: 'InsuranceCompany',
                funcName: 'Address',
            },
            {
                label: $A.get('$Label.c.Insurer_contact_number_1'),
                fieldName: 'ContactNumber1',
                type: 'PARSE',
                fieldKey: 'InsuranceCompany',
                funcName: 'ContactNumber1',
            },
            {
                fieldName: '',
            },
            {
                label: $A.get('$Label.c.Insurer_contact_number_2'),
                fieldName: 'ContactNumber2',
                type: 'PARSE',
                fieldKey: 'InsuranceCompany',
                funcName: 'ContactNumber2',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.fields.PaymentInformation', [{
                label: $A.get('$Label.c.Payment_Mode'),
                fieldName: 'PaymentMode',
            },
            {
                label: $A.get('$Label.c.Premium_Amount'),
                fieldName: 'PremiumAmount',
                type: 'INTEGER',
            },
            {
                label: $A.get('$Label.c.Payment_Method_BA'),
                fieldName: 'PaymentMethod',
            },
            {
                label: $A.get('$Label.c.Total_Premium_Paid'),
                fieldName: 'TotalPremiumPaid',
                type: 'INTEGER',
            },
            {
                label: $A.get('$Label.c.Last_Payment_Date'),
                fieldName: 'LastPaymentDate',
                type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Year_of_payment'),
                fieldName: 'YearOfPayment',
            },
            {
                label: $A.get('$Label.c.Next_due_date'),
                fieldName: 'NextDueDate',
                type: 'DATE',
            },
            {
                label: $A.get('$Label.c.No_of_Time_Premium_Paid_This_Year'),
                fieldName: 'NumberOfTimePremiumPaid',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.fields.NextCashBackInformation', [{
                label: $A.get('$Label.c.Next_Cash_Back_Payment_Date'),
                fieldName: 'PaymentDate',
                type: 'DATE',
            },
            {
                label: $A.get('$Label.c.Amount_of_Next_Cash_Back'),
                fieldName: 'Amount',
                type: 'NUMBER',
            },
            {
                label: $A.get('$Label.c.Total_Cash_Back_Paid'),
                fieldName: 'TotalPaid',
                type: 'NUMBER',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.fields.InsuredPropertyAsset', [{
            label: $A.get('$Label.c.Address'),
            fieldName: 'Address',
        }].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.fields.InsuredAutomobileAsset', [{
                label: $A.get('$Label.c.Brand'),
                fieldName: 'Brand',
            },
            {
                label: $A.get('$Label.c.Yr_of_Manufacture'),
                fieldName: 'YearOfManufactured',
            },
            {
                label: $A.get('$Label.c.Model'),
                fieldName: 'Model',
            },
            {
                label: $A.get('$Label.c.Plate_Number'),
                fieldName: 'PlateNumber',
            },
        ].map(function (i) {
            i.isAccessible = true;
            i.type = i.type ? i.type : 'STRING';
            return i;
        }));

        component.set('v.fields.InsuranceClaimRecord.columns', [{
                label: $A.get('$Label.c.Date'),
                fieldName: 'Date',
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
            },
            {
                label: $A.get('$Label.c.Claim_Type'),
                fieldName: 'Type',
            },
            {
                label: $A.get('$Label.c.Description'),
                fieldName: 'Description',
            },
            {
                label: $A.get('$Label.c.Request_Amount'),
                fieldName: 'RequestAmount',
            },
            {
                label: $A.get('$Label.c.Approved_Amount'),
                fieldName: 'ApprovedAmount',
            },
        ]);

        // console.log(helper.parseObj(component.get('v.pageReference')));
        helper.getBancassuranceProduct(component, event, helper);

        // Add Water Mark
        helper.getWatermarkHTML(component);

        window.scrollTo(0, 0);
    },
})