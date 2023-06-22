({
    onInit : function(component, event, helper) {
        var groupingByRM = helper.parseObj(component.get('v.groupingByRM'));
        var userProfile = component.get('v.userProfile');
        var team = groupingByRM[0].team
        var rm = groupingByRM[0].rm
        component.set('v.team', team)
        component.set('v.rm', rm)

        var target = groupingByRM[6]
        var endingBal = groupingByRM.slice(0, 3)
        var avgBal = groupingByRM.slice(3, 6)
        var niBal = groupingByRM.slice(6, 9)
        var InterestBal = groupingByRM.slice(9, 12)
        var ftpBal = groupingByRM.slice(12, 15)


        endingBal = helper.setEndingData(component, helper, endingBal);
        endingBal = helper.endingBalMillionUnit(component, helper, endingBal);
        
        var reportYear = parseInt(component.get('v.reportYear'));
        var today  = new Date();
        var year = today.getFullYear();
        var month = 0;

        if(reportYear == year) {
            month = today.getMonth();
        } else if(reportYear > year) {
            month = 0
    	} else {
            month = 11;
        }

        avgBal = helper.calTotalAvg(component, helper, helper.parseObj(avgBal), reportYear, month);
        avgBal = helper.avgBalMillionUnit(component, helper, avgBal);

        var nimDBal = helper.setDefaultData(component, helper, '%NIMd');
        var costOfDepositBal = helper.setDefaultData(component, helper, '%Cost of Deposit');
        var fundCreditBal = helper.setDefaultData(component, helper, '%Fund Credit');

        nimDBal = helper.setValuePercentData(component, helper, avgBal, niBal, nimDBal, '%NIMd', reportYear);
        costOfDepositBal = helper.setValuePercentData(component, helper, avgBal, InterestBal, costOfDepositBal, '%Cost of Deposit', reportYear);
        fundCreditBal = helper.setValuePercentData(component, helper, avgBal, ftpBal, fundCreditBal, '%Fund Credit', reportYear);

        for (let index = 0; index < 3; index++) {
            niBal[index] = helper.sumTotal(component, helper, niBal[index], reportYear, month)
            InterestBal[index] = helper.sumTotal(component, helper, InterestBal[index], reportYear, month)
            ftpBal[index] = helper.sumTotal(component, helper, ftpBal[index], reportYear, month)

            nimDBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], niBal[index], nimDBal[index], reportYear, month)
            costOfDepositBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], InterestBal[index], costOfDepositBal[index], reportYear, month)
            fundCreditBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], ftpBal[index], fundCreditBal[index], reportYear, month)
        }
        var valueBal = endingBal.concat(avgBal);
        
        if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
            niBal[0] = helper.setValueTarget(component, helper, niBal[0], target);
            niBal = helper.valueArrMillionUnit(component, helper, niBal, 'NI');
            nimDBal = helper.valueArrMillionUnit(component, helper, nimDBal, '%NIMd');
            costOfDepositBal = helper.valueArrMillionUnit(component, helper, costOfDepositBal, '%Cost of Deposit');
            fundCreditBal = helper.valueArrMillionUnit(component, helper, fundCreditBal, '%Fund Credit');
            InterestBal = helper.valueArrMillionUnit(component, helper, InterestBal, 'Interest_Income');
            ftpBal = helper.valueArrMillionUnit(component, helper, ftpBal, 'FTP');
            
            valueBal = valueBal.concat(niBal);
            valueBal = valueBal.concat(nimDBal);
            valueBal = valueBal.concat(costOfDepositBal);
            valueBal = valueBal.concat(fundCreditBal);
            valueBal = valueBal.concat(InterestBal);
            valueBal = valueBal.concat(ftpBal);
        }
        
        valueBal.forEach(element => {
            element['lastYearTitle'] = helper.numberWithCommas(element.lastYear);
            element['janTitle'] = helper.numberWithCommas(element.jan);
            element['febTitle'] = helper.numberWithCommas(element.feb);
            element['marTitle'] = helper.numberWithCommas(element.mar);
            element['aprTitle'] = helper.numberWithCommas(element.apr);
            element['mayTitle'] = helper.numberWithCommas(element.may);
            element['junTitle'] = helper.numberWithCommas(element.jun);
            element['julTitle'] = helper.numberWithCommas(element.jul);
            element['augTitle'] = helper.numberWithCommas(element.aug);
            element['sepTitle'] = helper.numberWithCommas(element.sep);
            element['octTitle'] = helper.numberWithCommas(element.oct);
            element['novTitle'] = helper.numberWithCommas(element.nov);
            element['decTitle'] = helper.numberWithCommas(element.dec);
            element['totalTitle']= helper.numberWithCommas(element.total);
            element['ytdTitle'] = helper.numberWithCommas(element.ytd);
            element['yoyTitle'] = helper.numberWithCommas(element.yoy);

            // target
            if(element.product == 'NIId') {
                element['originVarianceTitle'] = helper.numberWithCommas(element.originVarianceFull);
                element['originArchieveTitle'] = helper.numberWithCommas(element.originArchieveFull);
                element['originFYTargetTitle'] = helper.numberWithCommas(element.originFYTargetFull);
    
                if(month >= 3) {
                    element['firstTargetVarianceTitle'] = helper.numberWithCommas(element.firstTargetVarianceFull);
                    element['firstTargetArchieveTitle'] = helper.numberWithCommas(element.firstTargetArchieveFull);
                    element['firstTargetFYTargetTitle'] = helper.numberWithCommas(element.firstTargetFYTargetFull);
                }
                if(month >= 6) {
                    element['secondTargetVarianceTitle'] = helper.numberWithCommas(element.secondTargetVarianceFull);
                    element['secondTargetArchieveTitle'] = helper.numberWithCommas(element.secondTargetArchieveFull);
                    element['secondTargetFYTargetTitle'] = helper.numberWithCommas(element.secondTargetFYTargetFull);
                }
                if(month >= 9) {
                    element['thirdTargetVarianceTitle'] = helper.numberWithCommas(element.thirdTargetVarianceFull);
                    element['thirdTargetArchieveTitle'] = helper.numberWithCommas(element.thirdTargetArchieveFull);
                    element['thirdTargetFYTargetTitle'] = helper.numberWithCommas(element.thirdTargetFYTargetFull);
                }
            }
        } , valueBal);


        component.set('v.valueBal', helper.parseObj(valueBal));
        component.set('v.endingBal', helper.parseObj(endingBal));
        component.set('v.avgBal', helper.parseObj(avgBal));

        var p = component.get("v.parent");
        var jsonForCSV = component.get('v.jsonForCSV')
        p.exportCSV(helper.parseObj(jsonForCSV));
    },
})