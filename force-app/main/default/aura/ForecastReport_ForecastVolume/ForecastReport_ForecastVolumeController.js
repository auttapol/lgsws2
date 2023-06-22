({
    getReport: function (component, event, helper) {
      var year = (component.get('v.report1Param')).selectedYear;
      component.set('v.year',parseInt(year));
      component.set("v.teamTotalRow", null);
      component.set("v.regionTotalRow", null);
      component.set('v.groupedData');
      helper.getRec(component, helper, event);
    },

    sumRegion:function(component, event, helper){
      var params = event.getParam("arguments");
      
      helper.calculateRegionTotal(component,helper,params);
    }
    ,
  
    sumGroupTotalRow: function (component, event, helper) {
      var allTeamTotalRow = helper.parseObj(component.get("v.teamTotalRow"));
      var userProfile = component.get('v.userProfile');
      var jsonTotal = [];
      var groupedData = helper.parseObj(component.get('v.groupedData'));
      var jsonForCSV = helper.parseObj(component.get("v.jsonForCSV"));
      var params = event.getParam("arguments");
      var keyTeam = [];
      // if (params) {
      //   helper.calculateRegionTotal(component,helper,params);
      //   var param1 = helper.parseObj(params.param1);
      //   if (allTeamTotalRow != null) {
      //     allTeamTotalRow.forEach((teamTotalRow) => {
      //       if (param1.Team_Code__c == teamTotalRow.Team_Code__c) {
      //         keyTeam.push(teamTotalRow.Team_Code__c);
      //         teamTotalRow.Limit__c = (
      //           parseFloat(param1.Limit__c) + parseFloat(teamTotalRow.Limit__c)
      //         ).toFixed(2);
      //         teamTotalRow.Last_Year_Ending__c = (
      //           parseFloat(param1.Last_Year_Ending__c) +
      //           parseFloat(teamTotalRow.Last_Year_Ending__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_01__c = (
      //           parseFloat(param1.Ending_Balance_01__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_01__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_02__c = (
      //           parseFloat(param1.Ending_Balance_02__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_02__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_03__c = (
      //           parseFloat(param1.Ending_Balance_03__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_03__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_04__c = (
      //           parseFloat(param1.Ending_Balance_04__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_04__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_05__c = (
      //           parseFloat(param1.Ending_Balance_05__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_05__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_06__c = (
      //           parseFloat(param1.Ending_Balance_06__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_06__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_07__c = (
      //           parseFloat(param1.Ending_Balance_07__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_07__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_08__c = (
      //           parseFloat(param1.Ending_Balance_08__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_08__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_09__c = (
      //           parseFloat(param1.Ending_Balance_09__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_09__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_10__c = (
      //           parseFloat(param1.Ending_Balance_10__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_10__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_11__c = (
      //           parseFloat(param1.Ending_Balance_11__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_11__c)
      //         ).toFixed(2);
      //         teamTotalRow.Ending_Balance_12__c = (
      //           parseFloat(param1.Ending_Balance_12__c) +
      //           parseFloat(teamTotalRow.Ending_Balance_12__c)
      //         ).toFixed(2);
      //         teamTotalRow.Current_Balance__c = (
      //           parseFloat(param1.Current_Balance__c) +
      //           parseFloat(teamTotalRow.Current_Balance__c)
      //         ).toFixed(2);
      //         teamTotalRow.Projection__c = (
      //           parseFloat(param1.Projection__c) +
      //           parseFloat(teamTotalRow.Projection__c)
      //         ).toFixed(2);
      //         teamTotalRow.Variance__c = (
      //           parseFloat(param1.Variance__c) +
      //           parseFloat(teamTotalRow.Variance__c)
      //         ).toFixed(2);
      //         teamTotalRow.MTD__c = (
      //           parseFloat(param1.MTD__c) + parseFloat(teamTotalRow.MTD__c)
      //         ).toFixed(2);
      //         teamTotalRow.MoM__c = (
      //           parseFloat(param1.MoM__c) + parseFloat(teamTotalRow.MoM__c)
      //         ).toFixed(2);
      //         teamTotalRow.YTD__c = (
      //           parseFloat(param1.YTD__c) + parseFloat(teamTotalRow.YTD__c)
      //         ).toFixed(2);
      //         teamTotalRow.onlyCreditCurrent = (
      //           parseFloat(param1.onlyCreditCurrent) + parseFloat(teamTotalRow.onlyCreditCurrent)
      //         ).toFixed(2);
      //         teamTotalRow.Utilized =
      //           parseFloat(teamTotalRow.onlyCreditCurrent / (10**6)) /
      //           parseFloat(teamTotalRow.Limit__c);
      //       }
      //       jsonTotal.push(helper.setJSONData(teamTotalRow))
      //     }, allTeamTotalRow);
      //   }
      //   if (!keyTeam.includes(param1.Team_Code__c)) {
      //     allTeamTotalRow = allTeamTotalRow != null ? allTeamTotalRow : [];
      //     param1.Product_Group = "Team Total";
      //     param1.Utilized =
      //     (param1.onlyCreditCurrent != null ? parseFloat(param1.onlyCreditCurrent / (10 ** 6)) : 0) /
      //       parseFloat(param1.Limit__c);
      //     allTeamTotalRow.push(param1);
      //   }
      //   allTeamTotalRow.forEach(TeamTotal => {
      //     groupedData.forEach(data => {
      //       if(TeamTotal.Team_Code__c == data.Team){
      //         data['TeamTotal'] = TeamTotal;
      //       }
      //     },groupedData);
      //   });
      // }
      // var regionTotal = component.get('v.regionTotalRow');
      // if (userProfile == 'GroupHead') jsonTotal.push(helper.setJSONData(regionTotal))
      // jsonForCSV = jsonForCSV.concat(jsonTotal);
      // var today = new Date()
      // var dateFormat = (today.toLocaleDateString('en-GB').split('/')).join('-')
      // var p = component.get("v.parent");
      // p.exportCSV(helper.parseObj(jsonForCSV), 'Forecast_Volume_Report[' + dateFormat + ']');
      component.set("v.teamTotalRow", allTeamTotalRow);
    },
  
    onProfileChange: function (component, event, helper) {
      component.set('v.userProfile',component.find('profileSelect').get('v.value'));
    },
    exportCSV: function (component, event, helper) {
      var params = event.getParam('arguments');
      var param1 = helper.parseObj(params.param1);
      var jsonForCSV = helper.parseObj(component.get("v.jsonForCSV"));
      jsonForCSV = jsonForCSV.concat(param1);
      component.set("v.jsonForCSV", jsonForCSV)

      var today = new Date()
      var dateFormat = (today.toLocaleDateString('en-GB').split('/')).join('-')
      var p = component.get("v.parent");
      p.exportCSV(helper.parseObj(jsonForCSV), 'Forecast_Volume_Report[' + dateFormat + ']');
  }
  });