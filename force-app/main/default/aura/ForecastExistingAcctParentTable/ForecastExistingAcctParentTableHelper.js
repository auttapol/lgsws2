({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    generateSelectOpts: function (component, helper) {
        var today = new Date();
        var lastYear = new Date();

        lastYear.setMonth(lastYear.getMonth() + 11);

        var monthString = today.getMonth() +1 <= 10 ? '0' + (today.getMonth() +1).toString() : (today.getMonth() +1).toString();
        var optsYear = [];

        optsYear.push({
            id: (today.getFullYear() - 1).toString(),
            label: (today.getFullYear() - 1).toString()
        });

        optsYear.push({
            id: today.getFullYear().toString(),
            label: today.getFullYear().toString(),
            selected: true
        });

        if (lastYear.getFullYear() > today.getFullYear()) {
            optsYear.push({
                id: (today.getFullYear() + 1).toString(),
                label: (today.getFullYear() + 1).toString()
            });
        }

        var selectYear = {
            selected: today.getFullYear().toString(),
            opts: optsYear
        };

        component.set('v.selectYearOpts', selectYear.opts);
        component.set('v.selectYear', selectYear.selected);

        var monthOptsArray = [];

        for (var i = 1; i <= 12; i++) {
            var iString = i <= 10 ? '0' + i.toString() : i.toString();
            var nextYearMonth = { id: iString, label: helper.getMonthName(i-1, true) };

            if (monthString == iString) {
                nextYearMonth.selected = true;
            }

            monthOptsArray.push(nextYearMonth);
        }

        var selectMonth = {
            selected: monthString,
            opts: monthOptsArray
        };

        component.set('v.selectMonthOpts', selectMonth.opts);
        component.set('v.selectMonth', selectMonth.selected);

        var prodDomainOpts = {
            selected: 'Credit',
            opts: [
                { id: 'Credit', label: 'Credit' , selected: true},
                { id: 'Deposit', label: 'Deposit' }
            ]
        };

        component.set('v.ProdDomainOpts', prodDomainOpts.opts);
        component.set('v.selectedPrdDomain', prodDomainOpts.selected);

        var prdGroupOpts = {
            selected: '',opts: [
                { id: '', label: 'All', selected: true},
                { id: 'Credit Card', label: 'Credit Card'},
                { id: 'Fleet Card', label: 'Fleet Card'},
                { id: 'LG', label: 'LG'},
                { id: 'LT Loan', label: 'LT Loan'},
                { id: 'Military', label: 'Military'},
                { id: 'OD', label: 'OD'},
                { id: 'OD for Buyer', label: 'OD for Buyer'},
                { id: 'PN', label: 'PN'},
                { id: 'TF LIABILITY (Inter)', label: 'TF LIABILITY (Inter)'},
                { id: 'Trade Finance (Domestic)', label: 'Trade Finance (Domestic)'},
                { id: 'Trade Finance (Inter)', label: 'Trade Finance (Inter)'},
            ]
        };

        component.set('v.PrdGroupOpts', prdGroupOpts.opts);
        component.set('v.selectedPrdGroup', prdGroupOpts.selected);
    },

    generateTeamSelectOption: function (component, helper) {
        var mapPortTeam = helper.parseObj(component.get('v.mapPortTeam'));
        var selectedPort = component.get('v.selectedPort');
        var teamOpts = [];

        Object.keys(mapPortTeam[selectedPort]).forEach(function eachKey(key) {
            if (Object.keys(mapPortTeam[selectedPort]).length === 1) {
                teamOpts.push({ label: mapPortTeam[selectedPort][key], value: key });
                component.set('v.selectedTeamList', key);
                component.set('v.searchTeam', mapPortTeam[selectedPort][key]);
            } else {
                teamOpts.push({ label: mapPortTeam[selectedPort][key], value: key });
                component.set('v.selectedTeamList', []);
                component.set('v.searchTeam', '');
            }
        });

        teamOpts.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0)); 
        
        if (component.get('v.selectedPort') == 'My Customer' || component.get('v.selectedPort') == 'My Team') {
            component.find('teamInput').set('v.disabled',true);
        }else{
            component.find('teamInput').set('v.disabled',false);
        }

        component.set('v.teamOpts', teamOpts);
    },

    genMonthHeader: function (component, event, helper) {
        var month = parseInt(component.get('v.selectMonth') - 1);
        var year = parseInt(component.get('v.selectYear'));
        var period = helper.getPeriod(component, year, month);
        
        component.set('v.isCredit', component.get('v.selectedPrdDomain') == 'Credit' ? true : false);
        component.set('v.currentMonth', helper.getMonthName(month));
        component.set('v.period', period);
    },

    getMonthName: function (monthNumber, fullname) {
        var monthFullNames = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        ];

        var monthNames = new Array(12);
        monthNames[0] = 'Jan';
        monthNames[1] = 'Feb';
        monthNames[2] = 'Mar';
        monthNames[3] = 'Apr';
        monthNames[4] = 'May';
        monthNames[5] = 'June';
        monthNames[6] = 'Jul';
        monthNames[7] = 'Aug';
        monthNames[8] = 'Sep';
        monthNames[9] = 'Oct';
        monthNames[10] = 'Nov';
        monthNames[11] = 'Dec';
        if (fullname) return monthFullNames[monthNumber];
        else return monthNames[monthNumber];
    },

    getPeriod: function (component, year, month_number) {
        var firstOfMonth = new Date(year, month_number, 1);
        var lastOfMonth = new Date(year, month_number + 1, 0).getDate();
        var offsetDate;

        if (firstOfMonth.getDay() != 0) offsetDate = lastOfMonth + firstOfMonth.getDay() - 1;
        else offsetDate = lastOfMonth + firstOfMonth.getDay() + 6;

        var week = Math.ceil(offsetDate / 7);
        var firstDayOfWeek = new Array();
        var lastDayOfWeek = new Array();
        var period = new Array();

        for (var i = 0; i < week; i++) {
            var firstDayTmp;
            var lastDayTmp;
            if (i == 0) {
                firstDayTmp = new Date(year, month_number, 1);
                if (firstDayTmp.getDay() != 0) {
                var tempDate = new Date(firstDayTmp);
                    tempDate.setDate(tempDate.getDate() + (7 - tempDate.getDay()));
                    lastDayTmp = new Date(year, month_number, tempDate.getDate());
                } else {
                    lastDayTmp = new Date(year, month_number, 1);
                }
            } else {
                lastDayTmp = new Date(lastDayOfWeek[i - 1]);

                var temp1stDate = new Date(
                    lastDayTmp.getFullYear(),
                    lastDayTmp.getMonth(),
                    lastDayTmp.getDate() + 1
                );

                if (lastDayOfWeek[i - 1].getDate() + 7 < lastOfMonth) {
                    var tempLastDate = lastDayTmp.getDate() + 7;
                } else {
                    var tempLastDate = lastOfMonth;
                }

                var day1 = temp1stDate.getDate();
                var lastDay = tempLastDate;
                firstDayTmp = new Date(year, month_number, day1);
                lastDayTmp = new Date(year, month_number, lastDay);
            }
            firstDayOfWeek.push(firstDayTmp);
            lastDayOfWeek.push(lastDayTmp);
            period.push([firstDayTmp.getDate(), lastDayTmp.getDate()]);
        }
        component.set('v.week', week);
        return period;
    },

    groupingData: function (result) {
        var grouped = {};
        result.forEach((data) => {
            var key = data.Customer__c + '-' + data.Product_Type__c;
            grouped[key] = grouped[key] ? grouped[key] : [];
            grouped[key].push(data);
        });
        return grouped;
    },

    getRecord: function (component, helper) {
        
        component.set('v.isLoading', true);
        var month = parseInt(component.get('v.selectMonth'));
        var year = parseInt(component.get('v.selectYear'));
        var searchAcct = component.get('v.searchAcct');
        var searchAcctId = searchAcct ? searchAcct.Id : '';
        var searchGroup = component.get('v.searchGroup');
        var searchGroupId = searchGroup ? searchGroup.Id : '';
        var searchTeam = component.get('v.selectedTeamList');
        var prdDomain = component.get('v.selectedPrdDomain');
        var prdGroup = component.get('v.selectedPrdGroup');
        var port = component.get('v.selectedPort');
        var isMatured = component.get('v.isMatured');
        var action = component.get('c.getmonthlyForecastInput'); // Exisgin
        var action2 = component.get('c.getDrawdown'); // Drawdown
        var action3 = component.get('c.getmonthlyForecastInput'); //Last Year Exisgin
        var action4 = component.get('c.getDrawdown'); // Last Year Drawdown

        component.set('v.showLimit', prdDomain == 'Credit' ? true : false);
        // Exisgin
        action.setParams({
            month: month,
            year: year,
            accId: searchAcctId,
            groupId: searchGroupId,
            searchTeam: searchTeam,
            prdDomain: prdDomain,
            prdGroup: prdGroup,
            port: port,
            isMaturedInMonth: isMatured
        });

        // Drawdown
        action2.setParams({
            month: month,
            year: year,
            accId: searchAcctId,
            groupId: searchGroupId,
            searchTeam: searchTeam,
            prdDomain: prdDomain,
            prdGroup: prdGroup,
            port: port,
            isLastyear: false
        });

        //Last Year
        action3.setParams({
            month: 12,
            year: year - 1,
            accId: searchAcctId,
            groupId: searchGroupId,
            searchTeam: searchTeam,
            prdDomain: prdDomain,
            prdGroup: prdGroup,
            port: port,
            isMaturedInMonth: isMatured
        });

        // Last Year Drawdown
        action4.setParams({
            month: 12,
            year: year - 1,
            accId: searchAcctId,
            groupId: searchGroupId,
            searchTeam: searchTeam,
            prdDomain: prdDomain,
            prdGroup: prdGroup,
            port: port,
            isLastyear: true
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var listExiting = helper.groupingData(response.getReturnValue());
                component.set('v.existingdata', listExiting);
                // console.error('existingdata',listExiting);
                $A.enqueueAction(action2);
            } else if (state === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
                component.set('v.isLoading', false);
            } else {
                console.error(response);
                component.set('v.isLoading', false);
            }
        });

        action2.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var listDrawdown = helper.groupingData(response.getReturnValue());
                component.set('v.drawDownData', listDrawdown);
                // console.error('drawDownData',listDrawdown);
                $A.enqueueAction(action3);
            } else if (state === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
                component.set('v.isLoading', false);
            } else {
                console.error(response);
                component.set('v.isLoading', false);
            }
        });

        action3.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var listLastYear = helper.groupingData(response.getReturnValue());
                component.set('v.lastYearData', listLastYear);
                // console.error('lastYearData',listLastYear);
                // helper.groupAllData(component, helper);
                $A.enqueueAction(action4);
            } else if (state === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
                component.set('v.isLoading', false);
            } else {
                console.error(response);
                component.set('v.isLoading', false);
            }
        });

        action4.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var listDrawdown = helper.groupingData(response.getReturnValue());
                component.set('v.drawDownLastYearData', listDrawdown);
                // console.error('drawDownLastYearData',listDrawdown);
                helper.groupAllData(component, helper);
            } else if (state === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
                component.set('v.isLoading', false);
            } else {
                console.error(response);
                component.set('v.isLoading', false);
            }
        });

        if (component.get('v.searchTeam') != '') {
            $A.enqueueAction(action);
        } else {
            component.set('v.isLoading', false);
        }
    },

    groupAllData: function (component, helper) {
        var groupAllData = [];
        var currentData = JSON.parse(JSON.stringify(component.get('v.existingdata')));
        var drawdownData = JSON.parse(JSON.stringify(component.get('v.drawDownData')));
        var lastyearData = JSON.parse(JSON.stringify(component.get('v.lastYearData')));
        var lastyearDrawdownData = JSON.parse(JSON.stringify(component.get('v.drawDownLastYearData')));
        var month = parseInt(component.get('v.selectMonth'));
        var year = parseInt(component.get('v.selectYear'));

        for (var i = 0; i < Object.keys(currentData).length; i++) {
            var data = {
                Customer__c: Object.values(currentData)[i][0].Customer__c,
                Product_Type__c: Object.values(currentData)[i][0].Product_Type__c,
                Product__c: Object.values(currentData)[i][0].Product__c,
                Financial_Product_Group_Name__c : Object.values(currentData)[i][0].Product__r.Financial_Product_Group_Name__c,
                Month__c: month < 10? '0' + (month).toString() : (month).toString(),
                Year__c: year,
                Current: currentData[Object.keys(currentData)[i]] ? currentData[Object.keys(currentData)[i]] : [],
                Drawdown: drawdownData[Object.keys(currentData)[i]] ? drawdownData[Object.keys(currentData)[i]] : [],
                LastYear: lastyearData[Object.keys(currentData)[i]] ? lastyearData[Object.keys(currentData)[i]] : [],
                LastYearDrawDown: lastyearDrawdownData[Object.keys(currentData)[i]]? lastyearDrawdownData[Object.keys(currentData)[i]]: [],
            };
            groupAllData.push(data);
        }
        
        component.set('v.allDataLenght', groupAllData.length);
        helper.prioritySorting(component ,helper, groupAllData);
    },

    prioritySorting: function (component ,helper, dataArray) {
        var action = component.get('c.getpriorityProduct');
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var priorityProductList = response.getReturnValue();
                var mapProduct = new Map();

                priorityProductList.forEach((product) => {
                    mapProduct.set(product.MasterLabel , product.Priority__c);
                });

                dataArray.forEach((data) => {
                    data['Priority__c'] = mapProduct.get(data.Financial_Product_Group_Name__c);
                }, dataArray);

                dataArray.sort(function (a, b) {
                    if(a.Customer__c === b.Customer__c){
                        return a.Priority__c - b.Priority__c;
                    }
                });

                component.set('v.allData', dataArray);
                component.set('v.isLoading', false);
            } else if (state === 'ERROR') {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    }
                }
            } else {
                console.error(response);
            }
        });
        
        $A.enqueueAction(action);
    },

    displayToast: function (type, message) {
        var duration = 5000;
        var toastEvent = $A.get('e.force:showToast');

        toastEvent.setParams({
            key: type,
            type: type,
            message: message,
            duration: duration
        });

        toastEvent.fire();
    },
});