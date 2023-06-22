({
    
    init: function (component, helper) {
        
        let getDiff = (inDate, outDate) => {
            let years, months, days;
            
            inDate = moment(inDate);
            outDate = moment(outDate);
            
            years = outDate.diff(inDate, 'year');
            inDate.add(years, 'years');
        
            months = outDate.diff(inDate, 'months');
            inDate.add(months, 'months');
        
            days = outDate.diff(inDate, 'days');
        
            return {
                days: days,
                months: months,
                years: years
            };
            },
        
        getDiffFormatted = d =>
        {
            var text = '';
            if(`${d.years}` <= 0 &&`${d.months}` <= 0 &&`${d.days}` <= 0 ){
                text = '0 วัน';
            }else{
                if(`${d.years}` != 0){
                    text+=`${d.years} ปี ` 
                }
                if(`${d.months}` != 0){
                    text+=`${d.months} เดือน `
                }
                if(`${d.days}` != 0){
                    text+=`${d.days} วัน`
                }  
            }
            return text;
        };

        var theme = component.get('v.theme');
        var pageReference = component.get("v.pageReference");
        component.set('v.theme', theme ? theme : (pageReference ? pageReference.state.c__theme : ''));
        var RecordId = component.get('v.recordId');
        var action = component.get('c.getSubDebtTransaction');
        action.setParams({
            recordId: RecordId
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var AccessHigh = false;
                var AccessLow = false;
                var resp = response.getReturnValue();
                for(var i=0;i<resp.length;i++){
                    if(resp[i].IssueDate != $A.get('$Label.c.Data_Condition_Hidden_Text')){
                        AccessHigh = true;
                    }
                    // if(resp[i].SubDebtTransactionName != $A.get('$Label.c.Data_Condition_Hidden_Text')){
                    //     AccessLow = true;
                    // }
                    if(resp[i].RemainDate != null && resp[i].RemainDate != $A.get('$Label.c.Data_Condition_Hidden_Text')){
                                               
                        var today = new Date();
                        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
                        let diff = getDiff(date, resp[i].MaturityDate);
                        resp[i].RemainDate = getDiffFormatted(diff);
                    }

                    var SubDebtname = resp[i].SubDebtTransactionName;
                    let result = SubDebtname.substring(0,SubDebtname.length/2);
                    let result2 = SubDebtname.substring(SubDebtname.length/2,SubDebtname.length);  
                    resp[i].SubDebtTransactionName = result + '\n' + result2;
                }
                var data = resp;
                component.set('v.data', data);
            } else {
            }
            var dateType;
            var currencyType;
            var numType;
            if(AccessHigh ){
                dateType = 'date-local';
                currencyType = 'currency';
                numType = 'number';
            }else{
                dateType = 'text';
                currencyType = 'text';
                numType = 'text';
            }

            component.set('v.columns', [
            {
                label: $A.get('$Label.c.Sub_Debt_Transaction_Name'), 
                fieldName: 'SubDebtTransactionName',
                fixedWidth: component.get('v.theme') == 'Theme4t' ? 250 : 275,
                wrapText:true ,
                type: 'text',
                typeAttributes:{
                    variant: 'base',
                    label: {
                        fieldName: 'SubDebtTransactionName'
                    },
                    title: {
                        fieldName: 'SubDebtTransactionName'
                    },
                    name: {
                        fieldName: 'SubDebtTransactionName'
                    },
                }
            },{
                label: $A.get('$Label.c.Sub_Debt_Product_ID'), 
                fieldName: 'ProductID', 
                type: 'text', 
                fixedWidth: 100,
                wrapText: true
            },{
                label: $A.get('$Label.c.Sub_Debt_Name'), 
                fieldName: 'Name', 
                type: 'text',
                wrapText: true,
                fixedWidth: component.get('v.theme') == 'Theme4t' ? 350 : 400
            },{
                label: $A.get('$Label.c.Sub_Debt_Term'), 
                fieldName: 'Term', 
                type: 'text'
                    // initialWidth: component.get('v.theme') == 'Theme4t' ? 100 : 1,
            },{
                label: $A.get('$Label.c.Sub_Debt_Issue_Date'), 
                fieldName: 'IssueDate', 
                    // initialWidth: component.get('v.theme') == 'Theme4t' ? 100 : 100,
                type: dateType,typeAttributes:{
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit"
                }, cellAttributes: {
                    alignment: 'left'
                }
            },{
                label: $A.get('$Label.c.Sub_Debt_Unit'), 
                fieldName: 'Unit', 
                type: numType
                    // ,initialWidth: component.get('v.theme') == 'Theme4t' ? 70 : 80
            },{
                label: $A.get('$Label.c.Sub_Debt_Amount'), 
                fieldName: 'Amount', 
                type: numType,
                // initialWidth: component.get('v.theme') == 'Theme4t' ? 70 : 100,
                typeAttributes: {
                    minimumFractionDigits: '2',
                    maximumFractionDigits: '2'
                }
            },{
                label: $A.get('$Label.c.Sub_Debt_Interest_Rate'), 
                fieldName: 'InterestRate', 
                type: 'text'
            },{
                label: $A.get('$Label.c.Sub_Debt_Maturity_Date'), 
                fieldName: 'MaturityDate', 
                type: dateType,
                typeAttributes:{
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit"
                }, cellAttributes: {
                    alignment: 'left'
                } 
            },{
                label: $A.get('$Label.c.Sub_Debt_Remain_Date'),
                fieldName: 'RemainDate', 
                type: 'Text',
                fixedWidth:150
            }].map(function (m) {
                if (!m.fixedWidth && component.get('v.theme') == 'Theme4t') {
                    //m.fixedWidth = 100;
                    m.initialWidth = 100;
                }
                return m;
            }));
            component.set('v.isLoading', false);
        })
        $A.enqueueAction(action);


     
    },
})