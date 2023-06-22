({ 
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    generateSelectOpts: function(component , helper){
        var today = new Date();
        var lastYear = new Date();
        lastYear.setMonth(lastYear.getMonth() + 11);
        var monthString = today.getMonth() +1 <= 10 ? "0" + (today.getMonth() +1).toString() : (today.getMonth() +1).toString();
        var optsYear = [];
        optsYear.push( {
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

        component.set("v.selectYearOpts", selectYear.opts);
        component.set("v.selectYear", selectYear.selected);

        var monthOptsArray = [
            { id: '0', label: 'All' }
        ];

        for (var i = 1; i <= 12; i++) {
            var iString = i <= 10 ? "0" + i.toString() : i.toString();
            var nextYearMonth = { id: iString, label: helper.getMonthName(i-1, true) };
            monthOptsArray.push(nextYearMonth);
        }

        var selectMonth = {
            selected: '0',
            opts: monthOptsArray
        };

        component.set("v.selectMonthOpts", selectMonth.opts);
        component.set("v.selectMonth", selectMonth.selected);
        
        var prodDomainOpts = {
            selected: '',
            opts: [
                { id: '', label: 'All', selected: true},
                { id: 'Transactional Banking', label: 'Transactional Banking'},
                { id: 'Deposit & Investment', label: 'Deposit & Investment'},
                { id: 'Funding & Borrowing', label: 'Funding & Borrowing'},
                { id: 'Risk Protection', label: 'Risk Protection'},
            ]
        };
        
        component.set('v.ProdDomainOpts', prodDomainOpts.opts);
        component.set('v.selectedPrdDomain', prodDomainOpts.selected);

        var stageOpts = {
            selected: 'all',
            opts: [
                { id: 'all', label: 'All', selected: true},
                { id: 'Analysis', label: 'Analysis'},
                { id: 'Develop & Propose Solution', label: 'Develop & Propose Solution'},
                { id: 'Follow Up', label: 'Follow Up'},
                { id: 'Closed Lost', label: 'Closed Lost'},
                { id: 'Closed Won', label: 'Closed Won'},
                { id: 'Submitted to Insurance', label: 'Submitted to Insurance'},
                { id: 'Submitted to TPT', label: 'Submitted to TPT'},
                { id: 'Submitted to Branch', label: 'Submitted to Branch'},
                { id: 'Submitted to Partner', label: 'Submitted to Partner'},
                { id: 'Approval Process', label: 'Approval Process'},
                { id: 'CA-Prep', label: 'CA-Prep'},
                { id: 'Cancelled', label: 'Cancelled'},
                { id: 'Rejected', label: 'Rejected'},
                { id: 'Post Approval', label: 'Post Approval'},
                { id: 'Rejected waiting Appeal', label: 'Rejected waiting Appeal'},
                { id: 'Submit to Credit Process', label: 'Submit to Credit Process'},
                // { id: 'Set Up', label: 'Set Up'},
                // { id: 'Issued by centralize', label: 'Issued by centralize'},
                // { id: 'Issued', label: 'Issued'},
                // { id: 'Issued by Branch', label: 'Issued by Branch'},
                // { id: 'Issued by Partner', label: 'Issued by Partner'},
                { id: 'On Process', label: 'On Process'},
                { id: 'Preparing Doc', label: 'Preparing Doc'},
            ]
        };

        component.set('v.stageOpts', stageOpts.opts);
        component.set('v.selectedStage', stageOpts.selected);
        
        var probOpts = {
            selected: '',
            opts: [
                { id: '', label: 'All', selected: true},
                { id: 'High', label: 'High'},
                { id: 'Medium', label: 'Medium'},
                { id: 'Low', label: 'Low'},
                { id: 'Cancelled', label: 'Cancelled'},
            ]
        };
        component.set('v.probOpts', probOpts.opts);
        component.set('v.selectedProb', probOpts.selected);
    },

    generateTeamSelectOption: function (component, helper){
        var mapPortTeam = helper.parseObj(component.get('v.mapPortTeam'));
        var selectedPort = component.get('v.selectedPort');
        var teamOpts = [];

        if (selectedPort == 'My Customer' || selectedPort == 'My Team') {
            component.set('v.disable', true);
        } else {
            component.set('v.disable', false);
        }
        Object.keys(mapPortTeam[selectedPort]).forEach(function eachKey(key){
            if(Object.keys(mapPortTeam[selectedPort]).length === 1){
                teamOpts.push({'label': mapPortTeam[selectedPort][key], 'value': key});
                component.set('v.selectedTeamList', key);
                component.set('v.searchTeam', mapPortTeam[selectedPort][key]);
            }else{
                teamOpts.push({'label': mapPortTeam[selectedPort][key], 'value': key});
                component.set('v.selectedTeamList', []);
                component.set('v.searchTeam', '');
            }
        });

        teamOpts.sort((a,b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0)); 
        component.set('v.teamOpts', teamOpts);
    },
    
    getMonthName: function (monthNumber , fullname) {
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
            'December',
        ]
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
        if(fullname) return monthFullNames[monthNumber];
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

        for (var i = 0 ; i < week ; i++) {
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

	getNewDealData : function(component, result) {
        const mapVariableField = [];
        
		result.forEach(res => {
			var data = {
                Id: res.Id,
                name: res.Customer__r.Name,
				nameTh: res.Customer__r.RTL_Customer_Name_TH__c,
				groupName: res.Customer__r.Group__r ? res.Customer__r.Group__r.Name : '',
				team: res.Customer__r.Sub_Segment2__c,
				opportunity: res.Opportunity__r.Name,
				stage:  res.Opportunity__r.StageName,
				oppApplicationStatus: res.Opportunity__r.Application_Status__c,
				expectedCompleteDate: res.Opportunity__r.CloseDate,
				product: res.Product__r ? res.Product__r.Name : '',
				limitVolume: res.OpportunityLineItem_Limit_Volume__c,
				prop: res.Probability__c,
				incomeType: res.Income_Type__c,
				recurringType: res.Recurring_Type__c,
				frequency: res.Frequency__c,
				expectedStartYear: res.Expected_Start_Year__c,
				expectedStartMonth: res.Expected_Start_Month__c,
				utilization: (res.Utilization_Percent__c == '') ? null : res.Utilization_Percent__c,
                NIMfeeRate: res.NIM_Fee_rate__c,
                startingVolume: (res.Volume__c == '') ? 0 : res.Volume__c,
                mainDealForecast: res.Main_Deal_forecast__c,
				remark: res.Remark__c,
                lastUpdatedBy: res.Last_Adjustment_By__r ? res.Last_Adjustment_By__r.Name : '',
                lastUpdated: res.Last_Update_Adjustment__c,
                subDealForecast: [],
                customerId: res.Customer__c,
                opportunityId: res.Opportunity__c,
                productId: res.Product__c,
                opportunityProductId: res.Opportunity_Product_Id__c,
                opportunityRecordType: res.Opportunity__r.RecordType.Name,
            	ThisYearExpectedBalance:res.This_Year_Expected_Balance__c

            }
			mapVariableField.push(data);
        });
        
        var group = mapVariableField.reduce((r, a) => {
            r[a.mainDealForecast] = [...r[a.mainDealForecast] || [], a];
            return r;
           }, {});

        var mainDealForecast = [];
        mapVariableField.forEach((member) => {
            for (const [key, value] of Object.entries(group)) {
                if (member.Id == key) {
                    member.subDealForecast = value
                }
            }
            
            if(member.mainDealForecast == undefined || member.mainDealForecast == null) {
                mainDealForecast.push(member)
            }
        })
        mainDealForecast.sort((a,b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0)); 
		return mainDealForecast;
    },

    getRecord : function(component, helper) {
        var month = parseInt(component.get('v.selectMonth'));
        var year = parseInt(component.get('v.selectYear'));
        var searchAcct = component.get('v.searchAcct');
        var searchAcctId = searchAcct ? searchAcct.Id : '';
        var productDomain = component.get('v.selectedPrdDomain');
        var stage = component.get('v.selectedStage');
        var port = component.get('v.selectedPort');
        var prob = component.get('v.selectedProb');
        var searchTeam = component.get('v.selectedTeamList');;
        var searchGroup = component.get('v.searchGroup');
        var searchGroupId = searchGroup ? searchGroup.Id : '';

        var action = component.get('c.getDealForecast');

        action.setParams({
            month: month,
            year: year,
            accId: searchAcctId,
            productDomain: productDomain,
            searchGroup: searchGroupId,
            searchTeam: searchTeam,
            stage: stage,
            port: port,
            prob: prob
        });

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && component.isValid()) {
                var listNewDeal = helper.getNewDealData(component, response.getReturnValue());
                component.set('v.mydata', listNewDeal);
                component.set('v.allDataLength', listNewDeal.length);
                component.set('v.isLoading', false);
            }else if (response.getState() === 'ERROR') {
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

        if(component.get('v.searchTeam') != ''){
            $A.enqueueAction(action);
        }else{
            component.set('v.isLoading', false);
        }
        
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