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
        var niBal = groupingByRM.slice(6, 11)
        var InterestBal = groupingByRM.slice(11, 14)
        var ftpBal = groupingByRM.slice(14, 17)

        var LTPortion = [
            {
                rm: '',
                team: '',
                product: '%LT Portion',
                isSub: false,
                isPercent: true,
                lastYear: 0,
                jan: 0,
                feb: 0,
                mar: 0,
                apr: 0,
                may: 0,
                jun: 0,
                jul: 0,
                aug: 0,
                sep: 0,
                oct: 0,
                nov: 0,
                dec: 0,
                total: 0,
                ytd: 0,
                yoy: '',
                lastYearActual: 0,
                janLastYear: 0,
                febLastYear: 0,
                marLastYear: 0,
                aprLastYear: 0,
                mayLastYear: 0,
                junLastYear: 0,
                julLastYear: 0,
                augLastYear: 0,
                sepLastYear: 0,
                octLastYear: 0,
                novLastYear: 0,
                decLastYear: 0,
                originVariance: '',
                originArchieve: '',
                originFYTarget: '',
                firstTargetVariance: '',
                firstTargetArchieve: '',
                firstTargetFYTarget: '',
                secondTargetVariance: '',
                secondTargetArchieve: '',
                secondTargetFYTarget: '',
                thirdTargetVariance: '',
                thirdTargetArchieve: '',
                thirdTargetFYTarget: ''
            }
        ]
    
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
        
        avgBal = helper.calTotalAvg(component, helper, helper.parseObj(avgBal), reportYear, month)
        avgBal = helper.avgBalMillionUnit(component, helper, avgBal)

        var nimCBal = helper.setDefaultData(component, helper, '%NIMc');
        var yieldBal = helper.setDefaultData(component, helper, '%Yield');
        var ftpPercentBal = helper.setDefaultData(component, helper, '%FTP');
        
        nimCBal = helper.setValuePercentData(component, helper, avgBal, niBal, nimCBal, '%NIMc', reportYear)
        yieldBal = helper.setValuePercentData(component, helper, avgBal, InterestBal, yieldBal, '%Yield', reportYear)
        ftpPercentBal = helper.setValuePercentData(component, helper, avgBal, ftpBal, ftpPercentBal, '%FTP', reportYear)
                
        for (let index = 0; index < 3; index++) {
            niBal[index] = helper.sumTotal(component, helper, niBal[index], reportYear, month)
            InterestBal[index] = helper.sumTotal(component, helper, InterestBal[index], reportYear, month)
            ftpBal[index] = helper.sumTotal(component, helper, ftpBal[index], reportYear, month)
            
            nimCBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], niBal[index], nimCBal[index], reportYear, month)
            yieldBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], InterestBal[index], yieldBal[index], reportYear, month)
            ftpPercentBal[index] = helper.sumTotalPerccent(component, helper, avgBal[index], ftpBal[index], ftpPercentBal[index], reportYear, month)
        }
        niBal[3] = helper.sumTotal(component, helper, niBal[3], reportYear, month)
        niBal[4] = helper.sumTotal(component, helper, niBal[4], reportYear, month)
        
        var valueBal = endingBal.concat(avgBal);
        
        if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
            niBal[0] = helper.setValueTarget(component, helper, niBal[0], target)
            niBal = helper.valueArrMillionUnit(component, helper, niBal, 'NI')
            nimCBal = helper.valueArrMillionUnit(component, helper, nimCBal, '%NIMc')
            yieldBal = helper.valueArrMillionUnit(component, helper, yieldBal, '%Yield')
            ftpPercentBal = helper.valueArrMillionUnit(component, helper, ftpPercentBal, '%FTP')
            var LTPortion = helper.calLTPortion(component, helper, LTPortion, endingBal)
            InterestBal = helper.valueArrMillionUnit(component, helper, InterestBal, 'Interest_Income')
            ftpBal = helper.valueArrMillionUnit(component, helper, ftpBal, 'FTP')
                       
            valueBal = valueBal.concat(niBal);
            valueBal = valueBal.concat(nimCBal);
            valueBal = valueBal.concat(yieldBal);
            valueBal = valueBal.concat(ftpPercentBal);
            valueBal = valueBal.concat(LTPortion);
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
            if(element.product == 'NIIc') {
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


        var p = component.get("v.parent");
        var jsonForCSV = component.get('v.jsonForCSV')
        p.exportCSV(helper.parseObj(jsonForCSV));

    }
})