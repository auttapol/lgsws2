({
  setColumn: function (component, helper, event) {
    var year = component.get("v.reportParam").selectedYear;
    var suffixText = {
      lastYear : '('+ (parseInt(year) - 1).toString() + ')',
      thisYear : '('+ year + ')',
      totalFC : 'Y'+year+' (FC)',
    };
    var today = new Date();
    (year > today.getFullYear()) ? component.set('v.Month',0) : component.set('v.Month',today.getMonth());
    component.set('v.Year',year);
    var monthList = [
      { label: "JAN " + helper.checkActual(0, year) },
      { label: "FEB " + helper.checkActual(1, year) },
      { label: "MAR " + helper.checkActual(2, year) },
      { label: "APR " + helper.checkActual(3, year) },
      { label: "MAY " + helper.checkActual(4, year) },
      { label: "JUN " + helper.checkActual(5, year) },
      { label: "JUL " + helper.checkActual(6, year) },
      { label: "AUG " + helper.checkActual(7, year) },
      { label: "SEP " + helper.checkActual(8, year) },
      { label: "OCT " + helper.checkActual(9, year) },
      { label: "NOV " + helper.checkActual(10, year) },
      { label: "DEC " + helper.checkActual(11, year) }
    ];
    component.set("v.suffixText", suffixText);
    component.set("v.monthColumn", monthList);
  },

  getRec: function (component, helper, event) {
    var reportParam = component.get("v.reportParam");
    var action = component.get("c.getCube2Report4");
    var action3 = component.get("c.getCUBE1Data");
    var action4 = component.get("c.getNewDealReport4");
    var selectedProductGroup = reportParam.selectedProductGroup;

    action.setParams({
      strYear: reportParam.selectedYear,
      CustomerPort: reportParam.selectedCustomerPort,
      searchTeam: reportParam.searchTeam
    });

    action3.setParams({
      strYear: reportParam.selectedYear,
      port: reportParam.selectedCustomerPort,
      searchTeam: reportParam.searchTeam,
      selectedProductGroup:
        selectedProductGroup == "Credit" || selectedProductGroup == "Deposit"
          ? selectedProductGroup
          : ""
    });

    action4.setParams({
      strYear: reportParam.selectedYear,
      CustomerPort: reportParam.selectedCustomerPort,
      searchTeam: reportParam.searchTeam
    });

    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS" && component.isValid()) {
        var result = response.getReturnValue();
        component.set("v.Cube2Data", result);
        $A.enqueueAction(action3);
      } else {
        helper.displayToast("error", response.getError().message);
      }
    });

    action3.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS" && component.isValid()) {
        var result = response.getReturnValue();
        component.set("v.Cube1Data", result.listCube1);
        component.set("v.targetList", result.listTarget);
        component.set("v.LastYearCube1Data", result.LastYearlistCube1);
        
        $A.enqueueAction(action4);
      } else {
        helper.displayToast("error", response.getError().message);
      }
    });
    action4.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS" && component.isValid()) {
        var result = response.getReturnValue();
        component.set("v.NewDealData", result);
        helper.groupByRM(component, helper, event);
      } else {
        helper.displayToast("error", response.getError().message);
      }
    });
    $A.enqueueAction(action);
  },

  groupByRM: function (component, helper, event) {
    var targetList = component.get("v.targetList");
    var Cube2Data = component.get("v.Cube2Data");
    var Cube1Data = component.get("v.Cube1Data");
    var LastYearCube1Data = component.get("v.LastYearCube1Data");
    var NewDealData = component.get("v.NewDealData");
    var groupByRmArray = [];
    var groupByRmObj = {};
    // var groupByTeamArray = [];
    var groupByTeamObj = {};
    var groupByRegObj = {};
    var feeMap = new Map();
    var cube1Map = new Map();
    var LYcube1Map = new Map();
    var targetMap = new Map();
    var newDealMap = new Map();
    Cube2Data.forEach((fee) => {
      if (feeMap.has(fee.Customer__r.OwnerId)) {
        var feeArray = feeMap.get(fee.Customer__r.OwnerId);
        feeArray.push(fee);
      } else {
        var feeArray = [];
        feeArray.push(fee);
      }
      feeMap.set(fee.Customer__r.OwnerId, feeArray);
    });

    Cube1Data.forEach((data) => {
      if (cube1Map.has(data.Customer__r.OwnerId)) {
        var dataArray = cube1Map.get(data.Customer__r.OwnerId);
        dataArray.push(data);
      } else {
        var dataArray = [];
        dataArray.push(data);
      }
      cube1Map.set(data.Customer__r.OwnerId, dataArray);
    });

    LastYearCube1Data.forEach((data) => {
      if (LYcube1Map.has(data.Customer__r.OwnerId)) {
        var dataArray = LYcube1Map.get(data.Customer__r.OwnerId);
        dataArray.push(data);
      } else {
        var dataArray = [];
        dataArray.push(data);
      }
      LYcube1Map.set(data.Customer__r.OwnerId, dataArray);
    });


    targetList.forEach((data) => {
      if (targetMap.has(data.OwnerId)) {
        var dataArray = targetMap.get(data.OwnerId);
        dataArray.push(data);
      } else {
        var dataArray = [];
        dataArray.push(data);
      }
      targetMap.set(data.OwnerId, dataArray);
    });

    NewDealData.forEach((data) => {
      if (newDealMap.has(data.Customer__r.OwnerId)) {
        var dataArray = newDealMap.get(data.Customer__r.OwnerId);
        dataArray.push(data);
      } else {
        var dataArray = [];
        dataArray.push(data);
      }
      newDealMap.set(data.Customer__r.OwnerId, dataArray);
      
    });

    for (var key of cube1Map.keys()) {
      var team = cube1Map.get(key)[0].Customer__r.Owner.Zone__c;
      var region = cube1Map.get(key)[0].Customer__r.Owner.Region__c;
      var teamCode = cube1Map.get(key)[0].Customer__r.Owner.Zone_Code__c;
      var groupByRm = {
        team: team,
        teamCode: teamCode,
        region : region,
        cube1LY: LYcube1Map.has(key) ? LYcube1Map.get(key) : [],
        allFee: feeMap.has(key) ? feeMap.get(key) : [],
        cube1: cube1Map.get(key),
        target: targetMap.has(key) ? targetMap.get(key) : [],
        newDeal: newDealMap.has(key) ? newDealMap.get(key) : []
      };
      groupByRmObj[cube1Map.get(key)[0].Customer__r.OwnerId] = groupByRm;
      groupByRmArray.push(groupByRm);
    }
    for (var key of Object.keys(groupByRmObj)) {
      var keyTeam = groupByRmObj[key].team;

      groupByTeamObj[keyTeam] = groupByTeamObj[keyTeam] ? groupByTeamObj[keyTeam] : {};
      var RMArray = groupByTeamObj[keyTeam]['RM'] ? groupByTeamObj[keyTeam]['RM'] : [];
      RMArray.push(groupByRmObj[key]);
      
      groupByTeamObj[keyTeam]['RM'] = RMArray;
      groupByTeamObj[keyTeam]['region'] = groupByTeamObj[keyTeam]['region'] ? groupByTeamObj[keyTeam]['region'] : groupByRmObj[key].region;
      groupByTeamObj[keyTeam]['team'] = groupByTeamObj[keyTeam]['team'] ?groupByTeamObj[keyTeam]['team'] : keyTeam;
    }

    for (var key of Object.keys(groupByTeamObj)) {
      groupByTeamObj[key]['RM'].sort(function (a, b) {
        var nameA = a.cube1[0].Customer__r.Owner.Name.toUpperCase();
        var nameB = b.cube1[0].Customer__r.Owner.Name.toUpperCase();
        if (nameA < nameB) {
          return -1;
        }
        if (nameA > nameB) {
          return 1;
        }
    });
      groupByTeamObj[key]['totalTeam'] = groupByTeamObj[key]['totalTeam'] ? groupByTeamObj[key]['totalTeam'] :{};
      groupByTeamObj[key]['totalTeam']['target'] = [];
      groupByTeamObj[key]['totalTeam']['allFee'] =[];
      groupByTeamObj[key]['totalTeam']['cube1'] =[];
      groupByTeamObj[key]['totalTeam']['newDeal'] =[];
      groupByTeamObj[key]['totalTeam']['cube1LY'] = [];
      targetList.forEach(target => {
        groupByTeamObj[key].totalTeam.target = (target.Zone__c == groupByTeamObj[key].team) ? groupByTeamObj[key].totalTeam.target.concat(target) : groupByTeamObj[key].totalTeam.target;
      });
      LastYearCube1Data.forEach(cube1LY => {
        groupByTeamObj[key].totalTeam.cube1LY = (cube1LY.Customer__r.Owner.Zone__c == groupByTeamObj[key].team) ? groupByTeamObj[key].totalTeam.cube1LY.concat(cube1LY) : groupByTeamObj[key].totalTeam.cube1LY;
      })
      Cube1Data.forEach(cube1 => {
        groupByTeamObj[key].totalTeam.cube1 = (cube1.Customer__r.Owner.Zone__c == groupByTeamObj[key].team) ? groupByTeamObj[key].totalTeam.cube1.concat(cube1) : groupByTeamObj[key].totalTeam.cube1;
      })
      Cube2Data.forEach(cube2 => {
        groupByTeamObj[key].totalTeam.allFee = (cube2.Customer__r.Owner.Zone__c == groupByTeamObj[key].team) ? groupByTeamObj[key].totalTeam.allFee.concat(cube2) : groupByTeamObj[key].totalTeam.allFee;
      })
      NewDealData.forEach(newdeal => {
        groupByTeamObj[key].totalTeam.newDeal = (newdeal.Customer__r.Owner.Zone__c == groupByTeamObj[key].team) ? groupByTeamObj[key].totalTeam.newDeal.concat(newdeal) : groupByTeamObj[key].totalTeam.newDeal;
      })
      var keyRegion = groupByTeamObj[key].region;
      groupByRegObj[keyRegion] = groupByRegObj[keyRegion] ? groupByRegObj[keyRegion] : {};
      var RegionTeamArray = groupByRegObj[keyRegion]['teamArray'] ? groupByRegObj[keyRegion]['teamArray'] : [];
      RegionTeamArray.push(groupByTeamObj[key]);
      
      groupByRegObj[keyRegion]['teamArray'] = RegionTeamArray;
      groupByRegObj[keyRegion]['region'] = groupByRegObj[keyRegion]['region'] ? groupByRegObj[keyRegion]['region'] : keyRegion;
      
      groupByRegObj[keyRegion]['regionData'] = groupByRegObj[keyRegion]['regionData'] ? groupByRegObj[keyRegion]['regionData'] : {};
      groupByRegObj[keyRegion]['regionData']['allFee'] = groupByRegObj[keyRegion]['regionData']['allFee'] ? groupByRegObj[keyRegion]['regionData']['allFee'].concat(groupByTeamObj[key]['totalTeam']['allFee']) :groupByTeamObj[key]['totalTeam']['allFee'];
      groupByRegObj[keyRegion]['regionData']['cube1'] = groupByRegObj[keyRegion]['regionData']['cube1'] ? groupByRegObj[keyRegion]['regionData']['cube1'].concat(groupByTeamObj[key]['totalTeam']['cube1']) :groupByTeamObj[key]['totalTeam']['cube1'] ;
      groupByRegObj[keyRegion]['regionData']['newDeal'] = groupByRegObj[keyRegion]['regionData']['newDeal'] ? groupByRegObj[keyRegion]['regionData']['newDeal'].concat(groupByTeamObj[key]['totalTeam']['newDeal']) :groupByTeamObj[key]['totalTeam']['newDeal'] ;
      groupByRegObj[keyRegion]['regionData']['target'] =groupByRegObj[keyRegion]['regionData']['target'] ? groupByRegObj[keyRegion]['regionData']['target'].concat(groupByTeamObj[key]['totalTeam']['target']) :groupByTeamObj[key]['totalTeam']['target'] ;
      groupByRegObj[keyRegion]['regionData']['region'] =groupByRegObj[keyRegion]['regionData']['region'] ? groupByRegObj[keyRegion]['regionData']['region'] : keyRegion ;
      groupByRegObj[keyRegion]['regionData']['cube1LY'] =groupByRegObj[keyRegion]['regionData']['cube1LY'] ? groupByRegObj[keyRegion]['regionData']['cube1LY'].concat(groupByTeamObj[key]['totalTeam']['cube1LY']) :groupByTeamObj[key]['totalTeam']['cube1LY'] ;
    }
    var groupedRegArray =[];
    for (var key of Object.keys(groupByRegObj)) {
      
      groupByRegObj[key]['teamArray'].sort(function (a, b) {
        var nameA = a.team.toUpperCase();
        var nameB = b.team.toUpperCase();
        if (nameA < nameB) {
          return -1;
        }
        if (nameA > nameB) {
          return 1;
        }
    });
        groupedRegArray.push(groupByRegObj[key]);
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
    component.set('v.hasGraphData',groupedRegArray != null && groupedRegArray.length != 0);
      component.set('v.isLoading',false);
    
      component.set('v.groupByRegionArray',groupedRegArray);
  },

  checkActual: function (monthNumber, year) {
    var today = new Date();
    var monthEndBal = new Date(parseInt(year), monthNumber + 1, 1);
    if (today >= monthEndBal) {
      return "(A)";
    } else {
      return "(E)";
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
  parseObj: function (objFields) {
    return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
},
});