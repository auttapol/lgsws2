({
    helperMethod: function () {

    },

    getLastestPerformanceYear: function (component, event, helper) {
        return new Promise(function (reslove, reject) {
            component.set('v.loading', true);
            var channel = component.get('v.channel');
            var branchId = component.get('v.branchCode');

            var action = component.get('c.getLastedPerfomanceYear');
            let years = [
                new Date().getFullYear().toString(),
                (new Date().getFullYear() - 1).toString()
            ];

            action.setParams({
                "branchCode": branchId,
                "channel": channel,
                "years": years,
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.selectedYear', parseInt(result));
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.showToastErrorP3('Get lastest performance year Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject('Cannot get lastest performance year');
                }
            });

            $A.enqueueAction(action);
        });
    },

    setFocusedTabLabel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "P.3" + " (" + component.get('v.branchCode') + ")"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom48",
                iconAlt: "Approval"
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },


    getBranchSectionA: function (component, event, helper) {
        component.set('v.loading', true);
        // var channel = component.get('v.channel');
        // var region = component.get('v.region');
        // var zone = component.get('v.zone');
        var branchId = component.get('v.branchCode');
        var action = component.get('c.getBranchSectionA');
        var year = component.get('v.selectedYear');

        action.setParams({
            "branchCode": branchId,
            "year": year,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var sectionAData = {};
                if (result.length > 0) {
                    sectionAData = result[0];
                }

                if (Object.keys(sectionAData).length > 0) {
                    sectionAData.managerName = this.replaceNullOrUndefiendToDash(sectionAData.T_Performance_Team__r.Branch_Team_Manager__c);
                    sectionAData.branchName = this.replaceNullOrUndefiendToDash(sectionAData.T_Performance_Team__r.Team_Name_TH__c);
                    sectionAData.branchTier = this.replaceNullOrUndefiendToDash(sectionAData.Branch_Tier__c_);
                    sectionAData.branchType = this.replaceNullOrUndefiendToDash(sectionAData.Branch_Type__c);
                    sectionAData.workingDays = this.replaceNullOrUndefiendToDash(sectionAData.Working_Day__c);
                    sectionAData.officeHours = this.replaceNullOrUndefiendToDash(sectionAData.Office_Hour__c);
                    sectionAData.address = this.replaceNullOrUndefiendToDash(sectionAData.Address__c);
                    sectionAData.phoneNumber = this.replaceNullOrUndefiendToDash(sectionAData.Phone__c);
                    sectionAData.totalCustomers = this.numberWithCommas(sectionAData.Total_Customer__c);
                    sectionAData.totalActiveCustomers = this.numberWithCommas(sectionAData.Total_Active_Customer__c);
                    sectionAData.totalMainBankCustomers = this.numberWithCommas(sectionAData.Total_Mainbank_Customer__c);
                    sectionAData.netPromoterScore = this.numberWithCommas(sectionAData.Net_Promoter_Score__c) + '%';
                    sectionAData.branchTransactions = this.numberWithCommas(sectionAData.Branch_Transaction__c);
                    sectionAData.atmTransactions = this.numberWithCommas(sectionAData.ATM_Transaction__c);
                    sectionAData.digitalTransactions = this.numberWithCommas(sectionAData.Digital_Transaction__c);
                    sectionAData.totalTransactions = this.numberWithCommas(sectionAData.Total_Transaction__c);
                } else {
                    sectionAData.managerName = '';
                    sectionAData.Team_Name_TH__c = '';
                    sectionAData.Branch_Tier__c = '';
                    sectionAData.Branch_Type__c = '';
                    sectionAData.Working_Day__c = '';
                    sectionAData.Office_Hour__c = '';
                    sectionAData.Address__c = '';
                    sectionAData.Phone__c = '';
                    sectionAData.totalCustomers = 0;
                    sectionAData.totalActiveCustomers = 0;
                    sectionAData.totalMainBankCustomers = 0;
                    sectionAData.netPromoterScore = 0 + '%';
                    sectionAData.branchTransactions = 0;
                    sectionAData.atmTransactions = 0;
                    sectionAData.digitalTransactions = 0;
                    sectionAData.totalTransactions = 0;
                }
                var monthLst = [
                    { init: 'Jan', month: 'January', field: 'janKPI' },
                    { init: 'Feb', month: 'February', field: 'febKPI' },
                    { init: 'Mar', month: 'March', field: 'marKPI' },
                    { init: 'Apr', month: 'April', field: 'aprKPI' },
                    { init: 'May', month: 'May', field: 'mayKPI' },
                    { init: 'Jun', month: 'June', field: 'junKPI' },
                    { init: 'Jul', month: 'July', field: 'julKPI' },
                    { init: 'Aug', month: 'August', field: 'augKPI' },
                    { init: 'Sep', month: 'September', field: 'sepKPI' },
                    { init: 'Oct', month: 'October', field: 'octKPI' },
                    { init: 'Nov', month: 'November', field: 'novKPI' },
                    { init: 'Dec', month: 'December', field: 'decKPI' },
                ];
                if (sectionAData.Month__c) {
                    var titleMonth = monthLst[parseInt(sectionAData.Month__c, 10) - 1].init + ' ' + component.get('v.selectedYear');
                    component.set('v.titleMonth', titleMonth);
                } else {
                    var titleMonth = '-' + ' ' + component.get('v.selectedYear');
                    component.set('v.titleMonth', titleMonth);
                }

                component.set('v.sectionAData', sectionAData);
                component.set('v.loading', false)
                // set comma number
            } else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastErrorP3('Get BranchSectionA Failed, Message:'+message);
                component.set('v.loading', false);
            }
        });

        $A.enqueueAction(action);

    },

    getBranchInfo: function (component, event, helper) {
        component.set('v.loading', true);
        var channel = component.get('v.channel');
        var region = component.get('v.region');
        var zone = component.get('v.zone');
        var branchId = component.get('v.branchCode');
        var action = component.get('c.getBranchInfo');
        action.setParams({
            "branchCode": branchId,
            "channel": channel,
            "region": region,
            "zone": zone
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // set comma number
                result.totalCustomers = this.numberWithCommas(result.totalCustomers);
                result.totalActiveCustomers = this.numberWithCommas(result.totalActiveCustomers);
                result.totalMainBankCustomers = this.numberWithCommas(result.totalMainBankCustomers);
                result.netPromoterScore = this.numberWithCommas(result.netPromoterScore);
                result.branchTransactions = this.numberWithCommas(result.branchTransactions);
                result.atmTransactions = this.numberWithCommas(result.atmTransactions);
                result.digitalTransactions = this.numberWithCommas(result.digitalTransactions);
                result.totalTransactions = this.numberWithCommas(result.totalTransactions);
                // set offset data 
                component.set('v.offset', result.limitData);
                component.set('v.offsetDisplay', result.limitData);
                component.set('v.branchInfo', result);
                component.set('v.loading', false);
            } else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastErrorP3('Get BranchInfo:'+message);
                component.set('v.loading', false);
            }
        });

        $A.enqueueAction(action);
    },

    replaceNullOrUndefiendToDash: function (text) {
        if (text == null || text == undefined) return '-';
        return text;
    },

    replaceZeroWithEmptyString: function (num) {
        if (num == 0.00) return '';
        return num.toFixed(2);
    },

    getMonthNumberFormat: function (num) {
        var str = "" + num
        var pad = "00"
        var ans = pad.substring(0, pad.length - str.length) + str;
        return ans;
    },

    prepareDataForSectionD: function (component, event, helper) {
        component.set('v.loading', true);
        var channel = component.get('v.channel');
        var year = component.get('v.selectedYear');
        var branchId = component.get('v.branchCode');
        var action = component.get('c.prepareDataForSectionD');
        action.setParams({
            "year": year,
            "channel": channel,
            "branchCode": branchId,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Calculations
                var branchData = [];

                if (result) {
                    this.checkDataLastMonth(component, result);

                    result.forEach(emp => {
                        emp.name = emp.saleInfo.Name;
                        emp.position = '(' + emp.saleInfo.Sale_Type__c + ') ' + emp.saleInfo.Position__c;
                        // Calculate duration join sales                

                        emp.yearOnService = this.calculateYearOnService(emp.saleInfo.Sale_Hire_Date__c) ? parseInt(this.calculateYearOnService(emp.saleInfo.Sale_Hire_Date__c).yearOnServiceNum) : 0;
                        
                        var yearOnServiceData = this.calculateYearOnService(emp.saleInfo.Sale_Hire_Date__c);
                        emp.durationJoin = yearOnServiceData ? yearOnServiceData.yearOnServiceStr : '';

                        emp.yearMonthOnService = yearOnServiceData ? yearOnServiceData.yearMonthOnService : '';


                        // Set 2 fixed point
                        const currentMonthNumber = new Date().getMonth() + 1;

                        // // if current month - 1 don't have sale perf then calculate from sale trans

                        // console.log('emp.currentKPI:', emp.currentKPI);       

                        emp.janKPILabel = this.calculatePerMonth(component, 1, emp) == undefined && this.calculatePerMonth(component, 1, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 1, emp)).toFixed(2);
                        emp.janKPI = this.calculatePerMonth(component, 1, emp) == undefined && this.calculatePerMonth(component, 1, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 1, emp)).toFixed(2) * 1;

                        emp.febKPILabel = this.calculatePerMonth(component, 2, emp) == undefined && this.calculatePerMonth(component, 2, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 2, emp)).toFixed(2);
                        emp.febKPI = this.calculatePerMonth(component, 2, emp) == undefined && this.calculatePerMonth(component, 2, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 2, emp)).toFixed(2) * 1;

                        emp.marKPILabel = this.calculatePerMonth(component, 3, emp) == undefined && this.calculatePerMonth(component, 3, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 3, emp)).toFixed(2);
                        emp.marKPI = this.calculatePerMonth(component, 3, emp) == undefined && this.calculatePerMonth(component, 3, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 3, emp)).toFixed(2) * 1;

                        emp.aprKPILabel = this.calculatePerMonth(component, 4, emp) == undefined && this.calculatePerMonth(component, 4, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 4, emp)).toFixed(2);
                        emp.aprKPI = this.calculatePerMonth(component, 4, emp) == undefined && this.calculatePerMonth(component, 4, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 4, emp)).toFixed(2) * 1;

                        emp.mayKPILabel = this.calculatePerMonth(component, 5, emp) == undefined && this.calculatePerMonth(component, 5, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 5, emp)).toFixed(2);
                        emp.mayKPI = this.calculatePerMonth(component, 5, emp) == undefined && this.calculatePerMonth(component, 5, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 5, emp)).toFixed(2) * 1;
                        
                        emp.junKPILabel = this.calculatePerMonth(component, 6, emp) == undefined && this.calculatePerMonth(component, 6, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 6, emp)).toFixed(2);
                        emp.junKPI = this.calculatePerMonth(component, 6, emp) == undefined && this.calculatePerMonth(component, 6, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 6, emp)).toFixed(2) * 1;

                        emp.julKPILabel = this.calculatePerMonth(component, 7, emp) == undefined && this.calculatePerMonth(component, 7, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 7, emp)).toFixed(2);
                        emp.julKPI = this.calculatePerMonth(component, 7, emp) == undefined && this.calculatePerMonth(component, 7, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 7, emp)).toFixed(2) * 1;

                        emp.augKPILabel = this.calculatePerMonth(component, 8, emp) == undefined && this.calculatePerMonth(component, 8, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 8, emp)).toFixed(2);
                        emp.augKPI = this.calculatePerMonth(component, 8, emp) == undefined && this.calculatePerMonth(component, 8, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 8, emp)).toFixed(2) * 1;

                        emp.sepKPILabel = this.calculatePerMonth(component, 9, emp) == undefined && this.calculatePerMonth(component, 9, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 9, emp)).toFixed(2);
                        emp.sepKPI = this.calculatePerMonth(component, 9, emp) == undefined && this.calculatePerMonth(component, 9, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 9, emp)).toFixed(2) * 1;

                        emp.octKPILabel = this.calculatePerMonth(component, 10, emp) == undefined && this.calculatePerMonth(component, 10, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 10, emp)).toFixed(2);
                        emp.octKPI = this.calculatePerMonth(component, 10, emp) == undefined && this.calculatePerMonth(component, 10, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 10, emp)).toFixed(2) * 1;

                        emp.novKPILabel = this.calculatePerMonth(component, 11, emp) == undefined && this.calculatePerMonth(component, 11, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 11, emp)).toFixed(2);
                        emp.novKPI = this.calculatePerMonth(component, 11, emp) == undefined && this.calculatePerMonth(component, 11, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 11, emp)).toFixed(2) * 1;

                        emp.decKPILabel = this.calculatePerMonth(component, 12, emp) == undefined && this.calculatePerMonth(component, 12, emp) == null ? '' : parseFloat(this.calculatePerMonth(component, 12, emp)).toFixed(2);
                        emp.decKPI = this.calculatePerMonth(component, 12, emp) == undefined && this.calculatePerMonth(component, 12, emp) == null ? null : parseFloat(this.calculatePerMonth(component, 12, emp)).toFixed(2) * 1;

                        var dataLastMonth = component.get('v.dataLastMonth');

                        var monthKPI = ['janKPI', 'febKPI', 'marKPI', 'aprKPI', 'mayKPI', 'junKPI', 'julKPI', 'augKPI', 'sepKPI', 'octKPI', 'novKPI', 'decKPI'];
                        var currentMonthData;

                        currentMonthData = emp[monthKPI[dataLastMonth - 1]] == undefined && emp[monthKPI[dataLastMonth - 1]] == null ? null : emp[monthKPI[dataLastMonth - 1]];

                        // emp.currentKPI = currentMonthData == undefined && currentMonthData == null ? null : parseFloat(currentMonthData).toFixed(2)*1;
                        // emp.currentKPILabel = currentMonthData == undefined && currentMonthData == null ? '' : parseFloat(currentMonthData).toFixed(2);         
                        // console.log('debug current month kpi ******',component.get('v.currentMonthKPI'))
                        var currentKPI = this.getEmpCurrMonthKPI(component, emp.saleInfo.Employee_ID__c);
                        // console.log('debug kpi ******',emp.saleInfo.Id,currentKPI)
                        emp.currentKPI = currentKPI != null && currentKPI != undefined ? parseFloat(currentKPI).toFixed(2) * 1 : null;
                        emp.currentKPILabel = currentKPI != null && currentKPI != undefined ? parseFloat(currentKPI).toFixed(2) : '';
                        emp.yearKPI = this.calculateYearKPI(component, emp) == undefined && this.calculateYearKPI(component, emp) == null ? null : parseFloat(this.calculateYearKPI(component, emp)).toFixed(2) * 1;
                        emp.yearKPILabel = this.calculateYearKPI(component, emp) == undefined && this.calculateYearKPI(component, emp) == null ? '' : parseFloat(this.calculateYearKPI(component, emp)).toFixed(2);

                        /// set yearColor

                        if (emp.yearKPI != null && emp.yearKPI != undefined) {
                            if (emp.yearKPI < 60) emp.yearKPIColor = "#fe4e4e";
                            if (emp.yearKPI >= 60 && emp.yearKPI < 90) emp.yearKPIColor = "#e5c952";
                            if (emp.yearKPI >= 90 && emp.yearKPI < 110) emp.yearKPIColor = "#cefe9b";
                            if (emp.yearKPI >= 110 && emp.yearKPI < 140) emp.yearKPIColor = "#5fcdb2";
                            if (emp.yearKPI >= 140) emp.yearKPIColor = "#379fff";
                        }
                        if (emp.currentKPI != null && emp.currentKPI != undefined) {
                            if (emp.currentKPI < 60) emp.currentKPIColor = "#fe4e4e";
                            if (emp.currentKPI >= 60 && emp.currentKPI < 90) emp.currentKPIColor = "#e5c952";
                            if (emp.currentKPI >= 90 && emp.currentKPI < 110) emp.currentKPIColor = "#cefe9b";
                            if (emp.currentKPI >= 110 && emp.currentKPI < 140) emp.currentKPIColor = "#5fcdb2";
                            if (emp.currentKPI > 140) emp.currentKPIColor = "#379fff";
                        }

                        branchData.push(emp);
                    });
                    // console.log('branchData[6]:', branchData[6].saleTrans[2].Target_Point__c);
                    component.set('v.branchData', branchData);


                    component.set("v.sortAsc", true);
                    // component.set("v.sortField", "position");
                    helper.sortBy(component, "position");
                    component.set("v.sortField", "");

                }
                component.set('v.loading', false)

            }
            else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log('message', message);
                let result = {
                    saleIn: {
                        avgIndividual: 0.00,
                        avgBankwide: 0.00
                    },
                    saleOut: {
                        avgIndividual: 0.00,
                        avgBankwide: 0.00
                    }
                }
                helper.showToastErrorP3('Get prepareDataForSectionD Failed, Message:'+message);
                component.set('v.loading', false);
            }
            component.set('v.loading', false);
        });
        $A.enqueueAction(action);
    },

    numberWithCommas: function (x) {
        if (x) return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return 0;

    },


    getWatermarkHTML: function (component) {
        var action = component.get("c.getWatermarkHTML");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var watermarkHTML = response.getReturnValue();
                // console.log('watermarkHTML: ', watermarkHTML);

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                // console.log('watermarkHTML: ', bg);
                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                helper.showToastErrorP3('Get WatermarkHTML Failed, Message:'+response.error);
                component.set('v.loading', false);
            } else {
                helper.showToastErrorP3('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);
    },

    sortBy: function (component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.branchData");
        sortAsc = sortField != field || !sortAsc; // check asc,dsc  check field repeat
        records.sort(function (a, b) {
            // var t1 = a[field] == b[field],
            //     t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            // return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
            // equal items sort equally
            if (a[field] === b[field]) {
                return 0;
            }
            // nulls sort after anything else
            else if (a[field] === null) {
                return sortAsc ? -1 : 1;
            }
            else if (b[field] === null) {
                return sortAsc ? 1 : -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (sortAsc) {
                return a[field] < b[field] ? -1 : 1;
            }
            // if descending, highest sorts first
            else {
                return a[field] < b[field] ? 1 : -1;
            }
        });

        // console.log('Sort records:', records);
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.branchData.sales", records);
    },

    calculatePerMonth: function (component, numOfMonth, perfArr) {
        let currMonth = new Date().getMonth() + 1;
        let currYear = new Date().getFullYear();
        let currStrPoint = currYear.toString() + currMonth.toString().padStart(2, '0');
        var year = component.get('v.selectedYear');
        let calStrPoint = year + numOfMonth.toString().padStart(2, '0');
        let lastSaleInfoInDB = component.get('v.lastSaleInfoInDB');
        // console.log('calculate per month',calStrPoint)
        let dataLastMonth = component.get('v.dataLastMonth') ? component.get('v.dataLastMonth') : 0;
        let targetLastMonth = component.get('v.targetLastMonth') ? component.get('v.targetLastMonth') : 0;
        let perf;
        let sumActual = 0.00;
        let sumTarget = 0.00;

        // console.log('numOfMonth:',numOfMonth);
        // console.log('perfArr:',perfArr);
        let month = this.getMonthNumberFormat(numOfMonth);
        let dataSalePer;
        let dataSaleTrans;
        let result;

        var date = new Date();
        var currentYear = date.getFullYear();
        var currentMonth = date.getMonth() + 1;
        var currentDate = date.getDate();
        var DaysInMonth = new Date(currentYear, currentMonth, 0).getDate();

        // if(numOfMonth == 5) { // debugging
        //     console.log('debug month may ',numOfMonth,perfArr)
        // }
        if (perfArr.salePerf) {
            dataSalePer = perfArr.salePerf.filter((each, index) => {

                if (each.Month__c == month) {
                    // var lastMonth = month === '0' ? parseInt(month.substring(1)) : parseInt(month)
                    // // console.log('Per month:',month);  
                    // if(lastMonth > dataLastMonth)
                    // {
                    //     dataLastMonth = month === '0' ? parseInt(month.substring(1)) : parseInt(month);
                    // }
                    targetLastMonth = each.Target_Point__c;
                    return each;
                }

            });
        }
        // console.log('dataSalePer:',dataSalePer);
        if (dataSalePer) {
            if (dataSalePer.length > 0) {
                for (let perf of dataSalePer) {
                    sumActual = perf.Financial_Actual_Point__c != null && perf.Financial_Actual_Point__c != undefined ? perf.Financial_Actual_Point__c : sumActual;
                    sumTarget = perf.Target_Point__c != null && perf.Target_Point__c != undefined ? perf.Target_Point__c : sumTarget;
                }
                // console.log('check point',numOfMonth, sumActual,sumTarget);
                perf = sumTarget > 0 ? (sumActual / sumTarget) : perf;
                // dataLastMonth++;
            }
            else {
                if (perfArr.saleTrans) {

                    dataSaleTrans = perfArr.saleTrans.filter((each, index) => {
                        if (each.Month__c == month) {
                            // console.log('Trans each.Month:',each.Month__c);
                            // console.log('Trans month:',month);
                            // console.log('Trans month of value:',parseInt(month));
                            // console.log('Trans currMonth:',currMonth);
                            // console.log('parseInt(month) == currMonth :',parseInt(month) == currMonth);
                                each.Target_Point__c = perfArr.saleTransTarget;
                                return each;
                            }

                        });
                    if (dataSaleTrans) {
                        if (dataSaleTrans.length > 0) {

                            for (let perf of dataSaleTrans) {
                                if (parseInt(month) == currMonth) {
                                    // target / 31 * 29 - 2
                                    if (currentDate > 2) {
                                        perf.Target_Point__c = (perfArr.saleTransTarget / DaysInMonth) * (currentDate - 2);
                                        // each.Target_Point__c = (perfArr.saleTransTarget / DaysInMonth) * (currentDate - 2);
                                        // return each;
                                    } else {
                                        perf.Target_Point__c = 0;
                                    }
                                    // console.log('each in currMonth:',each);
                                }
                                var transMonth = perf.Month__c === '0' ? parseInt(perf.Month__c.substring(1)) : parseInt(perf.Month__c);
                                if (transMonth > dataLastMonth) {
                                    sumActual = perf.Actual_Point__c != null && perf.Actual_Point__c != undefined ? perf.Actual_Point__c : sumActual;
                                    sumTarget = perf.Target_Point__c != null && perf.Target_Point__c != undefined ? perf.Target_Point__c : sumTarget;
                                }
                            }
                            perf = sumTarget > 0 ? (sumActual / sumTarget) : perf;
                        }
                    }
                }
            }
        }

        result = perf != null && perf != undefined ? perf * 100 : result;
        // console.log('result:',result);
        // component.set('v.dataLastMonth',dataLastMonth);
        component.set('v.targetLastMonth', targetLastMonth);
        component.set('v.loading', false)

        var lastPerfInDB = component.get('v.lastPerfInDB');
        var checkPointMonth = currMonth - 2;
        var checkPointStr = currYear + checkPointMonth.toString().padStart(2, '0');
        if (checkPointMonth < 1) {
            checkPointStr = (currYear - 1).toString() + (checkPointMonth + 12).toString();
        }
        
        var checkPointlastSaleInfoInDB = lastSaleInfoInDB.Year__c + lastSaleInfoInDB.Month__c;
        var checkPointLastSaleInfoInOrg = perfArr.saleInfo.Year__c + perfArr.saleInfo.Month__c;
        var isResigned = checkPointLastSaleInfoInOrg < checkPointlastSaleInfoInDB;
        //// check other year **************
        var lastPerfPoint = lastPerfInDB != null ? lastPerfInDB.Year__c + lastPerfInDB.Month__c : null;
        if (calStrPoint > checkPointStr && calStrPoint <= currStrPoint && (result == null || result == undefined)) {
            if ((lastPerfInDB == null || (lastPerfPoint != null && lastPerfPoint <= currStrPoint)) && !isResigned) {
                result = 0;
            }
        }


        return result;
    },

    calculateYearOnService: function (hireDate) {

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;

        var currentYear = yyyy;
        var currentMonth = mm.charAt(0) === '0' ? mm.substring(1) : mm;
        var currentDay = dd.charAt(0) === '0' ? dd.substring(1) : dd;

        var saleHireDate = [];
        var yearToMonth = 0;
        var calMonth = 0;
        var totalMonth = 0;
        var monthOnService = 0;
        var result;
        // console.log('hireDate:',hireDate);
        if (hireDate) {
            saleHireDate = hireDate.split('-');
            // console.log('saleHireDate:',saleHireDate);
            var hireYear = saleHireDate[0];
            var hireMonth = saleHireDate[1].charAt(0) === '0' ? parseInt(saleHireDate[1].substring(1)) : saleHireDate[1];
            var hireDay = saleHireDate[2].charAt(0) === '0' ? parseInt(saleHireDate[2].substring(1)) : saleHireDate[2];
            yearToMonth = ((parseInt(currentYear, 10) - parseInt(hireYear, 10)) * 12);
            calMonth = parseInt(yearToMonth, 10) - parseInt(hireMonth, 10);
            totalMonth = calMonth + parseInt(currentMonth, 10);
            if (parseInt(currentMonth, 10) - parseInt(hireMonth, 10) >= 1) {
                if (parseInt(currentDay, 10) < parseInt(hireDay, 10)) {
                    result = parseFloat((totalMonth - 1) / 12).toFixed(2);
                    monthOnService = (totalMonth - 1) % 12;
                }
                else if (parseInt(currentDay, 10) >= parseInt(hireDay, 10)) {
                    result = parseFloat(totalMonth / 12).toFixed(2);
                    monthOnService = totalMonth % 12;
                }
            }
            else {
                result = parseFloat(totalMonth / 12).toFixed(2);
                monthOnService = totalMonth % 12;
            }

        }

        var date;
        var yearOnService = [];
        var yearOnServiceStr = '';
        var yearMonthOnServiceStr = '';
        if (result) {
            if ((result.toString()).includes('.')) {
                date = (result.toString()).split('.');
                yearOnServiceStr = date[0] + 'Y ' + monthOnService + ' M';
                yearMonthOnServiceStr = date[0].toString().padStart(4,'0') + '_' + monthOnService.toString().padStart(2,'0');
            }
            else {
                yearOnServiceStr = result.toString() + 'Y' + ' 0 M';
                yearMonthOnServiceStr = result.toString().padStart(4,'0') + '_' + '00';
            }
        }
        yearOnService.yearOnServiceStr = yearOnServiceStr;
        yearOnService.yearOnServiceNum = result;
        yearOnService.yearMonthOnService = yearMonthOnServiceStr;

        return yearOnService;
    },

    calculateYearKPI: function (component, saleData) {
        var today = new Date();
        var mm = today.getMonth() + 1; //January is 0!
        var dataLastMonth = component.get('v.dataLastMonth') ? component.get('v.dataLastMonth') : 0;
        var targetLastMonth = component.get('v.targetLastMonth') ? component.get('v.targetLastMonth') : 0;
        var saleTransLastMonth = 0;
        let perf;
        let sumActual = 0.00;
        let sumTarget = 0.00;

        let dataSalePer;
        let dataSaleTrans;
        let result;

        if (saleData.salePerf) {
            dataSalePer = saleData.salePerf.filter((each, index) => {
                return each;
            });
            if (dataSalePer) {
                if (dataSalePer.length > 0) {
                    for (let perf of dataSalePer) {
                        sumActual += perf.Financial_Actual_Point__c ? perf.Financial_Actual_Point__c : 0;
                        sumTarget += perf.Target_Point__c ? perf.Target_Point__c : 0;
                    }
                }
            }
        }
        var branchCode = component.get('v.branchCode');
        var lastSaleInfo = this.getLastSaleInfoByEmpId(component, saleData.saleInfo.Employee_ID__c);
        var checkBranchCode = lastSaleInfo == null ? null : lastSaleInfo.Branch_Code__c;
        if (checkBranchCode != null && branchCode == checkBranchCode) {
            //if current branch = last sale info (sale info did not move) will cal sale trans
            if (saleData.saleTrans) {
                dataSaleTrans = saleData.saleTrans.filter((each, index) => {
                    each.Target_Point__c = saleData.saleTransTarget;
                    return each;
                });

                if (dataSaleTrans) {
                    if (dataSaleTrans.length > 0) {
                        for (let perf of dataSaleTrans) {
                            var month = perf.Month__c === '0' ? parseInt(perf.Month__c.substring(1)) : parseInt(perf.Month__c);
                            if (month > dataLastMonth) {
                                saleTransLastMonth = month;
                                sumActual += perf.Actual_Point__c ? perf.Actual_Point__c : 0;
                                // sumTarget += perf.Target_Point__c ? perf.Target_Point__c : 0; 
                            }
                        }
                    }
                }
            }
            // if (mm - dataLastMonth == 1) {
            //     sumTarget += targetLastMonth;
            // }
            // else if (mm - dataLastMonth >= 2) {
            //     sumTarget += (targetLastMonth * 2);
            // }
            var date = new Date();
            var currentYear = date.getFullYear();
            var currentMonth = date.getMonth() + 1;
            var currentDate = date.getDate();
            var DaysInMonth = new Date(currentYear, currentMonth, 0).getDate();
            var selectedYear = component.get('v.selectedYear');
            
            if(currentMonth == 1) {
                if(selectedYear == currentYear) {
                    if (currentDate > 2) {
                        sumTarget += ((targetLastMonth / DaysInMonth) * (currentDate - 2));
                    }
                } else {
                    if(dataLastMonth > mm) {
                        // ข้ามปี (เมื่อปัจจุบันคือเดือนมกรา)
                        if ((mm+12) - dataLastMonth >= 2) {
                            sumTarget += targetLastMonth;
                        }
                    } else {
                        if (mm - dataLastMonth >= 2) {
                            sumTarget += targetLastMonth;
                        }
                    }
                }
            } else {
                if(selectedYear == currentYear) {
                    if (currentDate > 2) {
                        sumTarget += ((targetLastMonth / DaysInMonth) * (currentDate - 2));
                    }
                }
            }
        }

        
        perf = sumTarget > 0 ? (sumActual / sumTarget) : perf;
        result = perf != null && perf != undefined ? perf * 100 : result;

        return result;
    },

    checkDataLastMonth: function (component, saleData) {
        let dataLastMonth = component.get('v.dataLastMonth') ? component.get('v.dataLastMonth') : 0;
        if (saleData) {
            saleData.filter((sale, index) => {
                if (sale) {
                    var lastMonth = sale.salePerfLastMonth === '0' ? parseInt(sale.salePerfLastMonth.substring(1)) : parseInt(sale.salePerfLastMonth);
                    if (lastMonth > dataLastMonth) {
                        dataLastMonth = lastMonth === '0' ? parseInt(lastMonth.substring(1)) : parseInt(lastMonth);
                    }
                    return sale;
                }


            });
        }
        component.set('v.dataLastMonth', dataLastMonth);
    },

    getGraphData: function (component, helper, branchCode, saleType, channel, availIdvPerfObj, availBankPerfObj, initWrapper, selectedYear) {
        return new Promise(function (reslove, reject) {
            var responseGraphData = { avgIndividual: null, avgBankWide: null };

            if (availBankPerfObj == null || availBankPerfObj.transDateTimeCondition == '') {
                // no performance available in database
                responseGraphData.avgIndividual = null;
                responseGraphData.avgBankWide = null;
                reslove(responseGraphData);
            }

            if (!selectedYear) {
                selectedYear = availBankPerfObj.availPerfYear;
            }

            // var toDay = new Date();
            // var currYear = toDay.getFullYear();
            // var currMonth = String(toDay.getMonth()+1).padStart(2, '0');
            var sumPerfIdvCond = '';
            if (channel == 'Branch') {
                sumPerfIdvCond = ' WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' AND Sale_Branch_Code__c = \'' + branchCode + '\' ' + availIdvPerfObj.perfDateTimeCondition;
            } else {
                sumPerfIdvCond = ' WHERE Channel__c = \'' + channel + '\' AND Sale_Branch_Code__c = \'' + branchCode + '\' ' + availIdvPerfObj.perfDateTimeCondition; //
            }

            helper.getSumPerfAgg(component, sumPerfIdvCond).then((sumPerfIdvObj) => {
                var avgIndividual;
                var avgBankWide;
                var date = new Date();
                var currentYear = date.getFullYear();
                var currentMonth = date.getMonth() + 1;
                var currentDate = date.getDate();
                var DaysInMonth = new Date(currentYear, currentMonth, 0).getDate();
                // if(selectedYear == currYear) {
                if (availIdvPerfObj && availIdvPerfObj.transDateTimeCondition != '') {
                    helper.getSumTrans(component, helper, initWrapper.idvTransWrapper).then((sumTransIdv) => {
                        var sumPerfIdv = sumPerfIdvObj != null && sumPerfIdvObj != undefined ? sumPerfIdvObj.Sum_Act_Point : null;
                        if (sumTransIdv != null || sumPerfIdv != null) {
                            var perfTarget = sumPerfIdvObj.Sum_Target_Point ? sumPerfIdvObj.Sum_Target_Point : 0; //
                            var transTarget = 0;
                            // if(availIdvPerfObj && availIdvPerfObj.transDateTimeCondition != '') {
                            if(selectedYear == currentYear) {
                                if (currentDate > 2) {
                                    transTarget = (availIdvPerfObj.availPerfObj.Target_Point__c / DaysInMonth) * (currentDate - 2);
                                }
                            }
                            

                            if (availIdvPerfObj.targetMultipiler > 1) {
                                transTarget += availIdvPerfObj.availPerfObj.Target_Point__c ? availIdvPerfObj.availPerfObj.Target_Point__c : 0;
                            }
                            // transTarget = availIdvPerfObj.availPerfObj.Target_Point__c * availIdvPerfObj.targetMultipiler;
                            // }

                            sumPerfIdv = sumPerfIdv ? sumPerfIdv : 0;
                            sumTransIdv = sumTransIdv ? sumTransIdv : 0;
							var sumPoint = sumPerfIdv + sumTransIdv;
                            var sumTarget = (transTarget + perfTarget);
                            if (sumTarget <= 0 || sumPoint <= 0) {
                                avgIndividual = null;
                            } else {
                                avgIndividual = (sumPoint / sumTarget) * 100;
                            }

                            // avgIndividual = ((sumPerfIdv + sumTransIdv) / (transTarget + perfTarget)) * 100;
                            // console.log('in then avg individual',avgIndividual);
                        }
                    })
                } else {
                    avgIndividual = null;
                }

                // var avgIndividual = ((sumTransIdv+sumPerfIdv)/sumTargetIdv)*100;
                if (availBankPerfObj && availBankPerfObj.transDateTimeCondition != '') {
                    helper.getSumTrans(component, helper, initWrapper.bankTransWrapper).then((sumTransBank) => {
                        helper.getSumPerf(component, helper, initWrapper.bankPerfWrapper).then((sumPerfBankObj) => {
                            var sumPerfBank = sumPerfBankObj != null ? sumPerfBankObj.Financial_Actual_Point__c : null;
                            if (sumTransBank != null || sumPerfBank != null) {
                                var perfTarget = sumPerfBankObj.Target_Point__c ? sumPerfBankObj.Target_Point__c : 0;
                                var transTarget = 0;
                                // if(availBankPerfObj && avail) {
                                if(selectedYear == currentYear) {
                                    if (currentDate > 2) {
                                        transTarget = (availBankPerfObj.availPerfObj.Target_Point__c / DaysInMonth) * (currentDate - 2);
                                    }
                                }
                                
                                if (availBankPerfObj.targetMultipiler > 1) {
                                    transTarget += availBankPerfObj.availPerfObj.Target_Point__c ? availBankPerfObj.availPerfObj.Target_Point__c : 0;
                                }
                                // transTarget = availBankPerfObj.availPerfObj.Target_Point__c * availBankPerfObj.targetMultipiler;
                                // }
                                sumPerfBank = sumPerfBank ? sumPerfBank : 0;
                                sumTransBank = sumTransBank ? sumTransBank : 0;
								
                    			var sumPoint = sumPerfBank + sumTransBank;
                                var sumTarget = (transTarget + perfTarget);
                                if (sumTarget <= 0 || sumPoint <= 0) {
                                    avgBankWide = null;
                                } else {
                                    avgBankWide = (sumPoint / sumTarget) * 100;
                                }
                                // avgBankWide = ((sumTransBank + sumPerfBank) / (transTarget + perfTarget)) * 100

                            }
                            responseGraphData.avgIndividual = avgIndividual;
                            responseGraphData.avgBankWide = avgBankWide;
                            reslove(responseGraphData);
                        })
                    })
                } else {
                    responseGraphData.avgIndividual = avgIndividual;
                    responseGraphData.avgBankWide = null;
                    reslove(responseGraphData);
                }
            })


        })
    },

    checkPerfIsReceived: function (component, month, year) {
        return new Promise(function (resolve, reject) {
            var action = component.get('c.checkPerfIsReceived');
            action.setParams({
                // "branchCode" : branchCode
                "month": month,
                "year": year
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    resolve(result);
                }
                else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastErrorP3('Get  checkPerfIsReceived Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject(message);
                }
            });

            $A.enqueueAction(action);
        });
    },

    /// new
    newPrepareDataForSectionC: function (component, helper, selectedYear) {
        var branchCode = component.get('v.branchCode');
        // var saleType = component.get('v.saleType');
        var channel = component.get('v.channel');

        if (channel == 'Branch') {
            component.set('v.saleInLoading', true);
            component.set('v.saleOutLoading', true);

            // var inBankAvailPerfObj;
            this.getAvailPerfObj(component, branchCode, channel, 'Sale In', false, selectedYear).then((resultBank) => {
                this.getAvailPerfObj(component, branchCode, channel, 'Sale In', true, selectedYear).then((resultIdv) => {
                    var initWrapper = this.getInitialSumWrapper(branchCode, channel, 'Sale In', resultIdv.transDateTimeCondition, resultBank.transDateTimeCondition, resultBank.perfDateTimeCondition);
                    this.getGraphData(component, helper, branchCode, 'Sale In', channel, resultIdv, resultBank, initWrapper, selectedYear).then((graphData) => {
                        component.set('v.saleInGraph', graphData);
                        component.set('v.saleInLoading', false);
                    });
                })
            });
            this.getAvailPerfObj(component, branchCode, channel, 'Sale Out', false, selectedYear).then((resultBank) => {
                this.getAvailPerfObj(component, branchCode, channel, 'Sale Out', true, selectedYear).then((resultIdv) => {
                    var initWrapper = this.getInitialSumWrapper(branchCode, channel, 'Sale Out', resultIdv.transDateTimeCondition, resultBank.transDateTimeCondition, resultBank.perfDateTimeCondition);
                    this.getGraphData(component, helper, branchCode, 'Sale Out', channel, resultIdv, resultBank, initWrapper, selectedYear).then((graphData) => {
                        component.set('v.saleOutGraph', graphData);
                        component.set('v.saleOutLoading', false);
                    });
                });
            });
        } else {
            component.set('v.rascLoading', true);
            this.getAvailPerfObj(component, branchCode, channel, null, false, selectedYear).then((resultBank) => {
                this.getAvailPerfObj(component, branchCode, channel, null, true, selectedYear).then((resultIdv) => {
                    var initWrapper = this.getInitialSumWrapper(branchCode, channel, null, resultIdv.transDateTimeCondition, resultBank.transDateTimeCondition, resultBank.perfDateTimeCondition);
                    this.getGraphData(component, helper, branchCode, null, channel, resultIdv, resultBank, initWrapper, selectedYear).then((graphData) => {
                        component.set('v.rascGraph', graphData);
                        component.set('v.rascLoading', false);
                    })
                })
            })
        }

    },

    getAvailPerfObj: function (component, branchCode, channel, saleType, isIndividual, selectedYear) {
        return new Promise(function (reslove, reject) {
            if (!selectedYear) {

            }

            var lastAvailPerfQuery = '';
            if (isIndividual) {
                if (channel == 'Branch') {
                    lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' AND Sale_Branch_Code__c = \'' + branchCode + '\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                } else {
                    lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Channel__c = \'' + channel + '\' AND Sale_Branch_Code__c = \'' + branchCode + '\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                }

                // for testing
                // lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+saleType+'\' AND Channel__c = \''+channel+'\' AND Sale_Branch_Code__c = \''+branchCode+'\' AND Year__c = \'2021\' AND Month__c = \'11\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                // lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Channel__c = \''+channel+'\' AND Sale_Branch_Code__c = \''+branchCode+'\' AND Year__c = \'2021\' AND Month__c = \'11\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';

            } else {
                // for bankwide
                if (channel == 'Branch') {
                    lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                } else {
                    lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Channel__c = \'' + channel + '\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                }

                // for testing
                // lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Sale_Type__c = \''+saleType+'\' AND Channel__c = \''+channel+'\' AND Year__c = \'2021\' AND Month__c = \'11\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
                // lastAvailPerfQuery = 'SELECT Year__c, Month__c, SUM(Target_Point__c) Target_Point__c FROM Sale_Performance__c WHERE Channel__c = \''+channel+'\' AND Year__c = \'2021\' AND Month__c = \'11\' GROUP BY Year__c, Month__c ORDER BY Year__c DESC, Month__c DESC LIMIT 1';
            }
            // console.log('get avail perf condition',saleType,isIndividual,lastAvailPerfQuery)
            var action = component.get('c.getAvailPerfObj');
            action.setParams({
                // "branchCode" : branchCode
                "lastAvailPerfQuery": lastAvailPerfQuery,
                "isIndividual": false,
                "selectedYear": selectedYear,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    console.log('message', message);
                    // Display the message
                    helper.showToastErrorP3('Get AvailPerfObj Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject(message)
                }
            });

            $A.enqueueAction(action);
            // public static lastMonthTargetWrapper getLastMonthTarget(List<String> months, String year, String channel, String saleType){
        })
    },

    // getSumPerfAgg : function(component, whereCondition) {
    getSumPerfAgg: function (component, whereCondition) {
        return new Promise(function (reslove, reject) {
            // var whereCondition = ''
            var action = component.get('c.sumPerfAgg');
            action.setParams({
                // "branchCode" : branchCode
                "whereCondition": whereCondition,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastErrorP3('Get sumPerfAgg Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject(message);
                    // Display the message
                    // component.set('v.loaded', false)
                }
            });
            $A.enqueueAction(action);
        });
    },

    getInitialSumWrapper: function (branchCode, channel, saleType, idvTransTimeCondition, bankTransTimeCondition, bankPerfTimeCondition) {
        let sumTransIdvWrapper = {
            sumTrans: null,
            sumBranchTransQueryCond: '',
            lastRecordId: null,
            isEndRecord: false,
            sumPerfPoint: null,
            totalTarget: null,
            newAvgBankWide: null,
        };

        let sumTransBankWideWrapper = {
            sumTrans: null,
            sumBranchTransQueryCond: '',
            lastRecordId: null,
            isEndRecord: false,
            sumPerfPoint: null,
            totalTarget: null,
            newAvgBankWide: null,
        };

        let sumPerfBankWideWrapper = {
            salePerfBank: null,
            sumQueryCond: '',
            lastRecordId: null,
            isEndRecord: false,
        };

        if (channel == 'Branch') {
            sumTransIdvWrapper.sumBranchTransQueryCond = ' WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' AND Sale_Team__c = \'' + branchCode + '\' '
                + idvTransTimeCondition;

            sumTransBankWideWrapper.sumBranchTransQueryCond = ' WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' '
                + bankTransTimeCondition;

            sumPerfBankWideWrapper.sumQueryCond = 'WHERE Sale_Type__c = \'' + saleType + '\' AND Channel__c = \'' + channel + '\' '
                + bankPerfTimeCondition;
        } else {
            sumTransIdvWrapper.sumBranchTransQueryCond = ' WHERE Channel__c = \'' + channel + '\' AND Sale_Team__c = \'' + branchCode + '\' '
                + idvTransTimeCondition;

            sumTransBankWideWrapper.sumBranchTransQueryCond = ' WHERE Channel__c = \'' + channel + '\' '
                + bankTransTimeCondition;

            sumPerfBankWideWrapper.sumQueryCond = 'WHERE Channel__c = \'' + channel + '\' '
                + bankPerfTimeCondition;
        }

        var wrapper = { idvTransWrapper: sumTransIdvWrapper, bankTransWrapper: sumTransBankWideWrapper, bankPerfWrapper: sumPerfBankWideWrapper };
        return wrapper;
    },

    getSumTrans: function (component, helper, sumTransWrapper) {
        return new Promise(function (resolve, reject) {
            var action = component.get('c.sumBankWideTrans');
            action.setParams({
                // "branchCode" : branchCode
                "sumTransObj": sumTransWrapper
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.isSumBankWideSuccess', result.isEndRecord);
                    if (result.isEndRecord) {
                        resolve(result.sumTrans.Actual_Point__c);

                    } else {
                        helper.getSumTrans(component, helper, result).then((result2) => {
                            resolve(result2);
                        })
                    }
                    //     helper.recallSumBankWideTrans(component, helper, result);
                }
                else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastErrorP3('Get SumTrans Failed, Message:'+message);
                    component.set('v.loading', false);
                    // Display the message
                    // component.set('v.loaded', false)
                    reject(message);
                }
            });

            $A.enqueueAction(action);
        });
    },

    getSumPerf: function (component, helper, sumPerfWrapper) {
        return new Promise(function (reslove, reject) {
            var action = component.get('c.sumBankWidePerf');
            action.setParams({
                // "branchCode" : branchCode
                "sumPerfObj": sumPerfWrapper
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                // component.set('v.loading',false);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    // component.set('v.isSumBankWideSuccess',result.isEndRecord);
                    if (result.isEndRecord) {
                        reslove(result.salePerfBank);
                    } else {
                        helper.getSumPerf(component, helper, result).then((result2) => {
                            reslove(result2);
                        })
                    }
                    //     helper.recallSumBankWideTrans(component, helper, result);
                }
                else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastErrorP3('Get sumPerf, Message:'+message);
                    component.set('v.loading', false);
                    reject(message);
                    // Display the message
                    // component.set('v.loaded', false)
                }
            });

            $A.enqueueAction(action);
        });
    },

    getCurrentMonthKPI: function (component, event, helper) {
        return new Promise(function (reslove, reject) {
            component.set('v.loading', true);
            var selectedYear = component.get('v.selectedYear');
            var branchCode = component.get('v.branchCode');

            var action = component.get('c.getCurrentMonthKPI');
            //  let years = [
            //      new Date().getFullYear().toString(),
            //      (new Date().getFullYear() - 1).toString()
            //  ];

            action.setParams({
                "branchCode": branchCode,
                "selectedYear": selectedYear,
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.currentMonthKPI', result);
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.showToastErrorP3('Get current month KPI Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject('Get current month KPI failed');
                }
            });

            $A.enqueueAction(action);
        });
    },

    getEmpCurrMonthKPI: function (component, empId) {
        var currMonthKPILst = component.get('v.currentMonthKPI');
        if (currMonthKPILst){
           for (var i = 0; i < currMonthKPILst.length; i++) {
            if (currMonthKPILst[i].empId == empId) {
                return currMonthKPILst[i].curMonthKPI;
            }
        } 
        }
        
        return null;
    },

    getLastSaleInfo: function (component) {
        return new Promise(function (reslove, reject) {
            component.set('v.loading', true);
            // var selectedYear = component.get('v.selectedYear');
            var branchCode = component.get('v.branchCode');

            var action = component.get('c.getLastSaleInfo');
            //  let years = [
            //      new Date().getFullYear().toString(),
            //      (new Date().getFullYear() - 1).toString()
            //  ];

            action.setParams({
                "branchCode": branchCode,
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.lastSaleInfo', result);
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.showToastErrorP3('Get last sale info Failed, Message:'+message);
                    component.set('v.loading', false);
                    reject('Get last sale info failed');
                }
            });

            $A.enqueueAction(action);
        });
    },

    getLastSaleInfoByEmpId: function (component, empId) {
        var lastSaleInfoList = component.get('v.lastSaleInfo');
        for (var i = 0; i < lastSaleInfoList.length; i++) {
            if (lastSaleInfoList[i].Employee_ID__c == empId) {
                return lastSaleInfoList[i]
            }
        }
        return null;
    },

    checkLastPerf: function (component, event, helper) {
        return new Promise(function (reslove, reject) {
            var action = component.get('c.checkLastPerf');
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.lastPerfInDB', result);
                    reslove(result);
                } else {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    helper.showToastErrorP3('Get checkLastPerf, Message:'+message);
                    component.set('v.loading', false);
                    reject(message);
                }
            });

            $A.enqueueAction(action);
        });
    },

    getSharePointLink: function (component) {
        var action = component.get('c.getSharePointLink');// get function at apex
        var branchCode = component.get('v.branchCode');
        // action.setParams({
        // });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    result.forEach(obj => {
                        if (obj.SharePoint_Type__c == 'Help') {
                            component.set('v.helpLink', obj.URL_Link__c);
                        } else {
                            component.set('v.summaryLink', obj.URL_Link__c.replaceAll('$branchcode;',branchCode));
                        }
                    });
                }
                /* component.set('v.loaded', false); */
            }
            else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastErrorP3('Get Sharepoint Link Failed, Message:'+message);
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);

    },

    getLastSaleInfoInDB : function(component) {
        var action = component.get('c.checkLastSaleInfo');// get function at apex
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.lastSaleInfoInDB',result);
                /* component.set('v.loaded', false); */
            }
            else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastErrorP3('Get last sale info in DB Failed, Message:'+message);
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);
    },
    showToastErrorP3 : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error",
            "message": msg
        });
        toastEvent.fire();
    }
})