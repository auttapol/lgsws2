({
    setData : function(component, helper, data) {
        if (data.Expected_Start_Month__c == null || data.Expected_Start_Year__c == null || data.NIM_Fee_rate__c == null) {
            var eventToast = $A.get("e.force:showToast");
            eventToast.setParams({
                "type":'error',
                "message": $A.get('$Label.c.please_fill_in_expected_start_date')
            });
            eventToast.fire();
            var emptyList = ['','','','','','','','','','','',''];
            var header =  [
                {label: 'JAN', fieldName: 'jan'},
                {label: 'FEB', fieldName: 'feb'},
                {label: 'MAR', fieldName: 'mar'},
                {label: 'APR', fieldName: 'apr'},
                {label: 'MAY', fieldName: 'may'},
                {label: 'JUN', fieldName: 'jun'},
                {label: 'JUL', fieldName: 'jul'},
                {label: 'AUG', fieldName: 'aug'},
                {label: 'SEP', fieldName: 'sep'},
                {label: 'OCT', fieldName: 'oct'},
                {label: 'NOV', fieldName: 'nov'},
                {label: 'DEC', fieldName: 'dec'},
            ];

            var volumeData = new Object();
            var key = 'volume';
            emptyList.forEach((element, index) => {
                volumeData[key + (index+1)] = element;
            });

            header.unshift({label: '', fieldName: 'header'});
            header.push({label: 'TOTAL', fieldName: 'total'});
            component.set('v.columns', header);
            component.set("v.volumeData", volumeData);
            component.set("v.endingData", emptyList);
            component.set("v.incomeData", emptyList);
            component.set("v.canEdit", false);
        }
        var month = (data.Expected_Start_Month__c == null) ? 'Jan' : data.Expected_Start_Month__c;
        var year = (data.Expected_Start_Year__c == null) ? new Date().getFullYear() : parseInt(data.Expected_Start_Year__c);
        component.set('v.lastMonthNumber', 13 - helper.getNumOfMonth(month));
        component.set('v.monthNumber', helper.getNumOfMonth(month));
        component.set('v.yearNumber', year);
        component.set('v.isAdjustFirstMonth', (data.Income_Type__c) != null && ((data.Income_Type__c).includes('Fee') || (data.Income_Type__c).includes('Supply Chain')) ? true : false);
        component.set('v.NimFee', data.NIM_Fee_rate__c);
        component.set('v.incomeType', data.Income_Type__c);
        component.set('v.frequency', data.Frequency__c);
        component.set('v.recurringType', data.Recurring_Type__c);
        component.set('v.limitVolume', data.OpportunityLineItem_Limit_Volume__c);
        component.set('v.totalyear', 0);
        
        var startMonth = ("0" + (helper.getNumOfMonth(data.Expected_Start_Month__c))).slice(-2);
        var detail = {
            oppId: data.Opportunity__c != null ? data.Opportunity__c : '',
            oppName: data.Opportunity__r != null ? data.Opportunity__r.Name : '',
            productName: data.Product__r != null ? data.Product__r.Name : '',
            completeDate: data.Opportunity__r.CloseDate != null ? data.Opportunity__r.CloseDate : '',
            yearExpected: data.Opportunity__r.This_Year_Expected_Revenue__c != null ? data.Opportunity__r.This_Year_Expected_Revenue__c : '',
            startMonth: data.Expected_Start_Month__c,
            startYear: data.Expected_Start_Year__c,
            startDate: (data.Expected_Start_Month__c && data.Expected_Start_Year__c) ? startMonth + '/' + data.Expected_Start_Year__c : '',
            remark: data.Remark__c,
            prop: data.Probability__c,
            NIM_Fee: data.NIM_Fee_rate__c,
            recurringType: data.Recurring_Type__c,
            frequency: data.Frequency__c,
            incomeType: data.Income_Type__c,
            limitVolume: data.OpportunityLineItem_Limit_Volume__c,
            utilization: data.Utilization_Percent__c,
            recordTypeId: data.Opportunity__r != null ? data.Opportunity__r.RecordTypeId : '',
            productRemark: data.Product__r != null ? data.Product__r.Remark__c : '',
        }

        return detail;
    },
    getNumOfMonth: function (month) {
        var monthName = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
        ];

        return monthName.indexOf(month) + 1;
    },

    setVolumeData: function(component, helper, dealForecastData, volumeList, SeCreditId, monthlyForecastList) {
        var startMonth = dealForecastData.startMonth ? helper.getNumOfMonth(dealForecastData.startMonth) : 0;
        var startYear = dealForecastData.startYear;
        var today = $A.localizationService.formatDate(new Date(), "YYYY");
        volumeList = volumeList.length == 0 ? [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] : volumeList;
        var endingList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        var incomeList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        var header =  [
            {label: 'JAN', fieldName: 'jan'},
            {label: 'FEB', fieldName: 'feb'},
            {label: 'MAR', fieldName: 'mar'},
            {label: 'APR', fieldName: 'apr'},
            {label: 'MAY', fieldName: 'may'},
            {label: 'JUN', fieldName: 'jun'},
            {label: 'JUL', fieldName: 'jul'},
            {label: 'AUG', fieldName: 'aug'},
            {label: 'SEP', fieldName: 'sep'},
            {label: 'OCT', fieldName: 'oct'},
            {label: 'NOV', fieldName: 'nov'},
            {label: 'DEC', fieldName: 'dec'},
        ];
        var startMonthIndex = 0;
        var lastMonthIndex = 13 - startMonth;
        var monthHeader = [];
        if (startMonth != 0) {
            var limitVolume = dealForecastData.limitVolume ? dealForecastData.limitVolume : 0;
            var utilization = dealForecastData.utilization ? (dealForecastData.utilization / 100) : 0;
            var sumIncome = 0;

            for (let index = 0; index < 12; index++) {
                var isSEcredit = SeCreditId.find(element => element == dealForecastData.recordTypeId);
                if (index == 0) {
                    volumeList[index] = volumeList.length == 0 ? limitVolume * utilization : volumeList[index];
                    
                } else if (index > 0) {
                    if (isSEcredit != undefined && dealForecastData.productRemark == 'ST loan') {
                        volumeList[index] = volumeList.length == 0 ? limitVolume * 0.05 : volumeList[index];
                    }
                    
                    volumeList[index] = volumeList.length == 0 ? 0 : volumeList[index];
                } 
                if (index >= startMonth - 1) {
                    monthHeader[startMonthIndex] = header[index];
                    startMonthIndex++;
                } else {
                    monthHeader[lastMonthIndex] = header[index];
                    lastMonthIndex++;
                }
                endingList[index] = monthlyForecastList[index].Ending_Balance__c != null ? monthlyForecastList[index].Ending_Balance__c : 0;
                incomeList[index] = monthlyForecastList[index].NI__c != null ? monthlyForecastList[index].NI__c : 0;
                sumIncome += parseFloat(incomeList[index])
            }
            endingList[12] = endingList[11];
            incomeList[12] = sumIncome;
        } else {
            monthHeader = header;
        }
        var volumeData = new Object();
        var key = 'volume';
        volumeList.forEach((element, index) => {
            volumeData[key + (index+1)] = element;
        });
        if(startMonth != 1 && today == startYear){
            var monthYearTotal = [];
            var sumIncome = 0;
            var endingListTotalYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            var incomeListTotalYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            var start = startMonth-1;
            let index = 0;
            while(start != 0){
                if(index != 12 - start){
                    monthYearTotal.push(monthHeader[index]);
                    index++;
                    if(index >= 12){
                        break;
                    }
                }else{
                    monthYearTotal.push({label: 'TOTAL ' + startYear , fieldName: 'total'});
                    start = -1;
                }
            }
            for(let index = 0; index < 14; index ++){
                if(index == 13 - startMonth){
                    endingListTotalYear[index] = endingList[index-1] ;
                    incomeListTotalYear[index] = sumIncome;
                }else if(index > 13 - startMonth){
                    endingListTotalYear[index] = endingList[index];
                    incomeListTotalYear[index] = incomeList[index-1];
                }else{
                    endingListTotalYear[index] = endingList[index];
                    incomeListTotalYear[index] = incomeList[index];
                }
                sumIncome += parseFloat(incomeList[index])
            }
            endingListTotalYear[13] = endingListTotalYear[12];
            monthHeader = monthYearTotal;
            endingList = endingListTotalYear;
            incomeList = incomeListTotalYear;
        }
        if(startMonth != 0 && today < startYear){
            monthHeader.unshift({label: 'Total '+today, fieldName: 'Total'});
            endingList.unshift(0);
            incomeList.unshift(0);
        }
        monthHeader.unshift({label: '', fieldName: 'header'});
        monthHeader.push({label: 'TOTAL', fieldName: 'total'});
        component.set('v.columns', monthHeader);
        component.set("v.volumeData", volumeData);
        component.set("v.endingData", endingList);
        component.set("v.incomeData", incomeList);
        if(startMonth != 0 && today == startYear){
            component.set('v.totalyear', 1);
        }else if(startMonth != 0 && today < startYear){
            component.set('v.totalyear', 2);
        }

        helper.setEditData(component, helper);

    },
    setEditData : function(component, helper) {
        var volume1 = component.get("v.volumeData.volume1");
        var volume2 = component.get("v.volumeData.volume2");
        var volume3 = component.get("v.volumeData.volume3");
        var volume4 = component.get("v.volumeData.volume4");
        var volume5 = component.get("v.volumeData.volume5");
        var volume6 = component.get("v.volumeData.volume6");
        var volume7 = component.get("v.volumeData.volume7");
        var volume8 = component.get("v.volumeData.volume8");
        var volume9 = component.get("v.volumeData.volume9");
        var volume10 = component.get("v.volumeData.volume10");
        var volume11 = component.get("v.volumeData.volume11");
        var volume12 = component.get("v.volumeData.volume12");

        component.set("v.InputNumber.Volume1Edited",volume1);
        component.set("v.InputNumber.Volume2Edited",volume2);
        component.set("v.InputNumber.Volume3Edited",volume3);
        component.set("v.InputNumber.Volume4Edited",volume4);
        component.set("v.InputNumber.Volume5Edited",volume5);
        component.set("v.InputNumber.Volume6Edited",volume6);
        component.set("v.InputNumber.Volume7Edited",volume7);
        component.set("v.InputNumber.Volume8Edited",volume8);
        component.set("v.InputNumber.Volume9Edited",volume9);
        component.set("v.InputNumber.Volume10Edited",volume10);
        component.set("v.InputNumber.Volume11Edited",volume11);
        component.set("v.InputNumber.Volume12Edited",volume12);
    },
    
    setDataAfterChange : function(component, helper) {
        var volumeData = new Object();;
        var VolumeEdited = component.get("v.InputNumber");
        var limitVolume = component.get("v.limitVolume");
        var startYear = component.get('v.yearNumber');
        var startMonth = component.get('v.monthNumber');
        var NIM_Fee = component.get('v.NimFee') ? (component.get('v.NimFee') / 100) : 0;
        var incomeType = component.get('v.incomeType');
        var frequency = component.get('v.frequency');
        var recurringType = component.get('v.recurringType');
        var today = $A.localizationService.formatDate(new Date(), "YYYY");
        var isLeapYear = startYear % 400 === 0 || (startYear % 100 !== 0 && startYear % 4 === 0);
        var dayOfYear = isLeapYear ? 366 : 365;
        var startDate = new Date(startYear, startMonth, 1);
        var endingList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        var incomeList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        var endingListTotalYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var incomeListTotalYear = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var sumIncome = 0;
        var sumVolume = 0;

        for (let index = 0; index < 12; index++) {
            var dayOfMonth = new Date(startDate.getYear(),startDate.getMonth(),0).getDate();
            volumeData['volume' + (index+1)] = (VolumeEdited['Volume' + (index+1) + 'Edited'] == null ? 0 : VolumeEdited['Volume' + (index+1) + 'Edited']);
            
            sumVolume += volumeData['volume' + (index+1)];
            endingList[index] = (index != 12) ? sumVolume : 0;

            if (incomeType != null) {
                if (incomeType.includes('Fee') || incomeType.includes('Supply Chain')) {
                    if (recurringType == 'Recurring') {
                        if (frequency == 'Monthly') {
                            incomeList[index] = endingList[index] * NIM_Fee / 12;
                        } else if (frequency == 'Quarterly') {
                            if (index % 3 == 0) {                                
                                incomeList[index] = endingList[index] * NIM_Fee / 4;
                            } else {
                                incomeList[index] = 0;
                            }
                        } else if (frequency == 'Biyearly') {
                            if (index % 6 == 0) {                                
                                incomeList[index] = endingList[index] * NIM_Fee / 2;
                            } else {
                                incomeList[index] = 0;
                            }
                        } else if (frequency == 'Yearly') {
                            if (index == 0) {                                 
                                incomeList[index] = endingList[index] * NIM_Fee;
                            } else {
                                incomeList[index] = 0;
                            }
                        }
                    } else if (recurringType == 'One-off') {
                        if (index == 0) {                                
                            incomeList[index] = endingList[index] * NIM_Fee;
                        } else {
                            incomeList[index] = 0;
                        }
                    }
                } else {
                    incomeList[index] = endingList[index] * ((NIM_Fee / dayOfYear) * dayOfMonth);
                }
            }
            sumIncome += incomeList[index]
            startDate.setMonth(startDate.getMonth() + 1);
        }
        incomeList[12] = sumIncome;
        endingList[12] = endingList[11];
        if(startMonth != 1 && today == startYear){
            sumIncome = 0;
            for(let index = 0; index < 14; index ++){
                if(index == 13 - startMonth ){
                    endingListTotalYear[index] = endingList[index-1];
                    incomeListTotalYear[index] = sumIncome;
                }else if(index >= startMonth){
                    endingListTotalYear[index] = endingList[index];
                    incomeListTotalYear[index] = incomeList[index-1];
                }else{
                    endingListTotalYear[index] = endingList[index];
                    incomeListTotalYear[index] = incomeList[index];
                }
                sumIncome += parseFloat(incomeList[index])
            }
            endingListTotalYear[13] = endingListTotalYear[12];
            endingList = endingListTotalYear;
            incomeList = incomeListTotalYear;
        }
        component.set("v.volumeData", volumeData);
        component.set("v.endingData", endingList);
        component.set("v.incomeData", incomeList);

        return (sumVolume > limitVolume) ? false : true;
    },
    setMonthlyForecast: function(companant, helper, monthlyForecastList, dealForecast) {
        monthlyForecastList.sort(function(a, b) {
            var yearA = parseInt(a.Year__c);
            var yearB = parseInt(b.Year__c);

            var monthA = parseInt(a.Month__c);
            var monthB = parseInt(b.Month__c);

            if (yearA < yearB) {
                return -1;
            }
            if (yearA == yearB) {
                if (monthA < monthB) {
                    return -1;
                }
                if (monthA > monthB) {
                    return 1;
                }
            }
            if (yearA > yearB) {
                return 1;
            }
            
            // names must be equal
            return 0;
        });
        if (dealForecast.Expected_Start_Month__c != null || dealForecast.Expected_Start_Year__c != null) {
            var month = ("0" + (helper.getNumOfMonth(dealForecast.Expected_Start_Month__c))).slice(-2);
            var startDateIndex = monthlyForecastList.findIndex(                            
                (element) => element.Month__c == month && element.Year__c == dealForecast.Expected_Start_Year__c
            ); 
        }

        monthlyForecastList = monthlyForecastList.slice(startDateIndex, startDateIndex + 13);

        return monthlyForecastList;
    },
    setMonthlyForecastData: function (component) {
        var monthlyForecastList = component.get('v.monthlyForecastList');
        var endingData = component.get('v.endingData');
        var incomeData = component.get('v.incomeData');
        var startMonth = component.get('v.monthNumber');

        var MonthlyForecastDataList = [];
        monthlyForecastList.forEach((element, index) => {
            var MonthlyForecastData = new Object();
            if(index != 13 - startMonth){
                MonthlyForecastData.Id = element.Id;
                MonthlyForecastData.Deal_Forecast_Income__c = element.Deal_Forecast_Income__c;
                MonthlyForecastData.Ending_Balance__c = endingData[index];
                MonthlyForecastData.NI__c = incomeData[index];
            }else{
                MonthlyForecastData.Id = element.Id;
                MonthlyForecastData.Deal_Forecast_Income__c = element.Deal_Forecast_Income__c;
                MonthlyForecastData.Ending_Balance__c = endingData[index+1];
                MonthlyForecastData.NI__c = incomeData[index+1];
            }
            MonthlyForecastDataList.push(MonthlyForecastData);
        });
        return MonthlyForecastDataList;
    },
})