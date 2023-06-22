({    
    getRegionName : function (component,teamName) {
        var action = component.get("c.getRegionZoneName");
        action.setParams({
            teamName : teamName,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {
                var result = response.getReturnValue();
                component.set('v.userRegion', result != null ? result.Region_Group_Name__c : 0 );
            } else {
                helper.displayToast('error', response.getError().message);
            }
        });
        
        $A.enqueueAction(action);
    },
    parseObj: function (objFields) {
      return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    setColumn: function (cmp,helper){
        var today = new Date();
        var year = (cmp.get('v.report1Param')).selectedYear;
        cmp.set('v.year',parseInt(year));
        var columns = [
            {
                fieldName: 'JanEndingBal',
                label: 'Ending Bal.',
                label2: 'Jan ' + helper.checkAcual(0,year)
            },
            {
                fieldName: 'FebEndingBal',
                label: 'Ending Bal. ',
                label2: 'Feb ' + helper.checkAcual(1,year)
            },
            {
                fieldName: 'MarEndingBal',
                label: 'Ending Bal.',
                label2: 'Mar ' + helper.checkAcual(2,year)
            },
            {
                fieldName : 'AprEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Apr ' + helper.checkAcual(3,year)
            },
            {
                fieldName : 'MayEndingBal' ,
                label: 'Ending Bal.',
                label2: 'May ' + helper.checkAcual(4,year)
            },
            {
                fieldName : 'JunEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Jun ' + helper.checkAcual(5,year)
            },
            {
                fieldName : 'JulyEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Jul ' + helper.checkAcual(6,year)
            },
            {
                fieldName : 'AugEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Aug ' + helper.checkAcual(7,year)
            },
            {
                fieldName : 'SepEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Sep ' + helper.checkAcual(8,year)
            },
            {
                fieldName : 'OctEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Oct ' + helper.checkAcual(9,year)
            },
            {
                fieldName : 'NovEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Nov ' + helper.checkAcual(10,year)
            },
            {
                fieldName : 'DecEndingBal' ,
                label: 'Ending Bal.',
                label2: 'Dec ' + helper.checkAcual(11,year)
            },
        ];
        var yesterday = new Date();
        var thisYear = yesterday.getFullYear();
        
        yesterday.setDate(yesterday.getDate() - 1);
        var suffixColumb =
            {
                LastYear : '('+(parseInt(year) - 1).toString()+')',
                ActualEndingBalance: year > thisYear ? '' :'(' + (yesterday.getDate()).toString() + ' ' + helper.getShortMonthName(yesterday.getMonth()) + '\'' + (yesterday.getFullYear()).toString().slice(-2) + ')',
                ProjectedEndingBalance: year > thisYear ? '' :'(' + helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2) + ')',
                Variance: year > thisYear ? '' :'(' + helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2) + ')',
                MTD: year > thisYear ? '' :'(' + helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2) + ')',
                MoM: year > thisYear ? '' :'(' + helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2) + ')',
                YTD: year > thisYear ? '' :'(' + helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2) + ')',
            };
        cmp.set('v.suffixHeaderColumb', suffixColumb);
        cmp.set('v.monthColumns', columns);
        var groupedData = helper.groupingData(helper.parseObj(cmp.get('v.Cube1Data')));
        var LYgroupedData = helper.groupingData(helper.parseObj(cmp.get('v.LYCube1Data')));
        var mapTeamArray = new Map();
        var mapRegArray = new Map();
        var groupedTeamArray = [];
        var groupedRegArray = [];
        for (var i = 0; i < Object.keys(groupedData).length; i++) {

            if(mapTeamArray.has(groupedData[Object.keys(groupedData)[i]][0].Customer__r.Owner.Zone__c)){
                var teamObj = mapTeamArray.get(groupedData[Object.keys(groupedData)[i]][0].Customer__r.Owner.Zone__c)
                teamObj.groupedByRM.push({data : groupedData[Object.keys(groupedData)[i]] ,LYData : LYgroupedData[Object.keys(groupedData)[i]]});
                teamObj.teamAllData.data = teamObj.teamAllData.data.concat(groupedData[Object.keys(groupedData)[i]]);
                teamObj.teamAllData.LYData = teamObj.teamAllData.LYData.concat(LYgroupedData[Object.keys(groupedData)[i]]);

                mapTeamArray.set(teamObj.Team,teamObj);
            }else{
                var teamObj = {};
                var rmGroupArray = [];
                var teamAllData = {data :[],LYData:[]};
                var rmObj={
                    data : groupedData[Object.keys(groupedData)[i]],
                    LYData : LYgroupedData[Object.keys(groupedData)[i]],
                    }
                rmGroupArray.push(rmObj);
                teamAllData.data = teamAllData.data.concat(groupedData[Object.keys(groupedData)[i]]);
                teamAllData.LYData = teamAllData.LYData.concat(LYgroupedData[Object.keys(groupedData)[i]]);
                teamObj = {
                    region: groupedData[Object.keys(groupedData)[i]][0].Customer__r.Owner.Region__c,
                    Team: groupedData[Object.keys(groupedData)[i]][0].Customer__r.Owner.Zone__c,
                    groupedByRM : rmGroupArray,
                    teamAllData : teamAllData
                }
                mapTeamArray.set(teamObj.Team,teamObj);
            }

        }
        for (var key of mapTeamArray.keys()) {
            var sortRm = mapTeamArray.get(key);
            sortRm.groupedByRM.sort(function (a, b) {
                var nameA = a.data[0].Customer__r.Owner.Name.toUpperCase();
                var nameB = b.data[0].Customer__r.Owner.Name.toUpperCase();
                if (nameA < nameB) {
                  return -1;
                }
                if (nameA > nameB) {
                  return 1;
                }
            });
            groupedTeamArray.push(sortRm);
        }
        groupedTeamArray.forEach(groupedTeam => {
            if (mapRegArray.has(groupedTeam.region)) {
                var regObj = mapRegArray.get(groupedTeam.region);
                regObj.teamArray.push(groupedTeam);
                regObj.regionData.data = regObj.regionData.data.concat(groupedTeam.teamAllData.data);
                regObj.regionData.LYData = regObj.regionData.LYData.concat(groupedTeam.teamAllData.LYData);
                mapRegArray.set(groupedTeam.region,regObj);
            }else{
                var regObj = {
                    region : groupedTeam.region,
                    teamArray : [groupedTeam],
                    regionData : {data :groupedTeam.teamAllData.data , LYData :groupedTeam.teamAllData.LYData}
                }
                mapRegArray.set(groupedTeam.region,regObj);
            }
        });
        for (var key of mapRegArray.keys()) {
            var sortTeam = mapRegArray.get(key);
            sortTeam.teamArray.sort(function (a, b) {
                var nameA = a.Team.toUpperCase();
                var nameB = b.Team.toUpperCase();
                if (nameA < nameB) {
                  return -1;
                }
                if (nameA > nameB) {
                  return 1;
                }
              });
            groupedRegArray.push(sortTeam);
        }
        groupedRegArray.sort(function (a, b) {
            var nameA = a.region.toUpperCase();
            var nameB = b.region.toUpperCase();
            if (nameA < nameB) {
              return -1;
            }
            if (nameA > nameB) {
              return 1;
            }
          });
        cmp.set('v.groupedData',groupedRegArray);
        
    },

    groupingData: function (result) {
        var grouped ={};
        
        result.forEach((data) => {
        var key = data.Customer__r.OwnerId;
        grouped[key] = grouped[key] ? grouped[key] : [];
        grouped[key].push(data);
        });
        return grouped;
    },
    
    getRec : function(component,helper,event){
        var report1Param = component.get('v.report1Param');
        var action = component.get("c.getCube1Report");
        var selectedProductGroup = report1Param.selectedProductGroup;
        action.setParams({
            strYear : report1Param.selectedYear,
            CustomerPort : report1Param.selectedCustomerPort,
            searchTeam : report1Param.searchTeam ,
            selectedProductGroup : (selectedProductGroup == "Credit" || selectedProductGroup =="Deposit") ? selectedProductGroup : '' ,
        });
        action.setCallback(this, function (response) {
            component.set('v.isLoading', true)
            if (response.getState() === "SUCCESS" && component.isValid()) {
                var result = response.getReturnValue();
                component.set('v.Cube1Data',result.listCube1);
                component.set('v.LYCube1Data',result.LastYearlistCube1);
                
                component.set('v.priorityProduct',result.priorityProduct);
                if (result.currentUser.Zone_Code__c) {
                    helper.getRegionName(component ,result.currentUser.Zone_Code__c);
                }
                
                component.set('v.isLoading', false);
                (result.listCube1 == null || result.listCube1.length == 0) ? component.set('v.hasRec',false) : component.set('v.hasRec',true);
                // component.set('v.userProfile',result.userProfile);
                
                component.set("v.jsonForCSV", []);
                helper.setColumn(component,helper);
            } else {
                helper.displayToast('error', response.getError().message);
            }
        });
        $A.enqueueAction(action);
    },

    calculateRegionTotal : function(component,helper,params){
        var regionTotal = component.get('v.regionTotalRow');
        if (params) {
          var param1 = helper.parseObj(params.param1);
          if (regionTotal != null) {
            regionTotal.Limit__c = parseFloat(param1.Limit__c) + parseFloat(regionTotal.Limit__c);
            regionTotal.Last_Year_Ending__c = parseFloat(param1.Last_Year_Ending__c) + parseFloat(regionTotal.Last_Year_Ending__c);
            regionTotal.Ending_Balance_01__c = parseFloat(param1.Ending_Balance_01__c) + parseFloat(regionTotal.Ending_Balance_01__c);
            regionTotal.Ending_Balance_02__c = parseFloat(param1.Ending_Balance_02__c) + parseFloat(regionTotal.Ending_Balance_02__c);
            regionTotal.Ending_Balance_03__c = parseFloat(param1.Ending_Balance_03__c) + parseFloat(regionTotal.Ending_Balance_03__c);
            regionTotal.Ending_Balance_04__c = parseFloat(param1.Ending_Balance_04__c) + parseFloat(regionTotal.Ending_Balance_04__c);
            regionTotal.Ending_Balance_05__c = parseFloat(param1.Ending_Balance_05__c) + parseFloat(regionTotal.Ending_Balance_05__c);
            regionTotal.Ending_Balance_06__c = parseFloat(param1.Ending_Balance_06__c) + parseFloat(regionTotal.Ending_Balance_06__c);
            regionTotal.Ending_Balance_07__c = parseFloat(param1.Ending_Balance_07__c) + parseFloat(regionTotal.Ending_Balance_07__c);
            regionTotal.Ending_Balance_08__c = parseFloat(param1.Ending_Balance_08__c) + parseFloat(regionTotal.Ending_Balance_08__c);
            regionTotal.Ending_Balance_09__c = parseFloat(param1.Ending_Balance_09__c) + parseFloat(regionTotal.Ending_Balance_09__c);
            regionTotal.Ending_Balance_10__c = parseFloat(param1.Ending_Balance_10__c) + parseFloat(regionTotal.Ending_Balance_10__c);
            regionTotal.Ending_Balance_11__c = parseFloat(param1.Ending_Balance_11__c) + parseFloat(regionTotal.Ending_Balance_11__c);
            regionTotal.Ending_Balance_12__c = parseFloat(param1.Ending_Balance_12__c) + parseFloat(regionTotal.Ending_Balance_12__c);
            regionTotal.Current_Balance__c = parseFloat(param1.Current_Balance__c) + parseFloat(regionTotal.Current_Balance__c);
            regionTotal.Projection__c = parseFloat(param1.Projection__c) + parseFloat(regionTotal.Projection__c);
            regionTotal.Variance__c = parseFloat(param1.Variance__c) + parseFloat(regionTotal.Variance__c);
            regionTotal.MTD__c = parseFloat(param1.MTD__c) + parseFloat(regionTotal.MTD__c);
            regionTotal.MoM__c = parseFloat(param1.MoM__c) + parseFloat(regionTotal.MoM__c);
            regionTotal.YTD__c = parseFloat(param1.YTD__c) + parseFloat(regionTotal.YTD__c);
            regionTotal.onlyCreditCurrent = parseFloat(param1.onlyCreditCurrent) + parseFloat(regionTotal.onlyCreditCurrent);
            regionTotal.Utilized = parseFloat(regionTotal.onlyCreditCurrent / (10**6)) / parseFloat(regionTotal.Limit__c);    
          }else{
            regionTotal = param1;
            regionTotal.Product_Group = 'Region Total';
            regionTotal.Utilized = (regionTotal.onlyCreditCurrent != null ? parseFloat(regionTotal.onlyCreditCurrent / (10 ** 6)) : 0) / parseFloat(regionTotal.Limit__c);    
          }
        }
        component.set('v.regionTotalRow',regionTotal);
      },


    getShortMonthName : function(monthNumber){
        var shortMonthName =[
            'Jan' ,'Feb' , 'Mar' , 'Apr' , 'May' , 'Jun' ,'Jul' ,'Aug','Sep','Oct','Nov','Dec'
        ]
        return shortMonthName[monthNumber];
    },

    checkAcual: function(monthNumber,year){
        var today = new Date();
        var monthEndBal = new Date(parseInt(year),monthNumber + 1 ,1);
        if(today >= monthEndBal){
            return '(A)';
        }
        else{
            return '(E)';
        }
    },
    displayToast: function (type, message) {
      var duration = 5000;
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        key: type,
        type: type,
        message: message,
        duration: duration
      });
      toastEvent.fire();
    },

})