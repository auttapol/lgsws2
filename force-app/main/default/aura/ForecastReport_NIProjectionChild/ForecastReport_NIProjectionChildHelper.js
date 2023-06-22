({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    mapTemplate: function (allFee) {
        var mapTemp = new Map();

        if (allFee != null) {
            allFee.forEach((data) => {
                if (data.Income_Type__c == 'Front End Fee') {
                    data.Income_Type__c = 'Credit Fee';
                }

                if (data.Income_Type__c == 'Direct CM Fee' || data.Income_Type__c == 'Other CM Fee') {
                    data.Income_Type__c = 'CM Fee';
                }

                if (mapTemp.has(data.Income_Type__c)) {
                    var tempData = mapTemp.get(data.Income_Type__c);
                    for (var i = 1; i <= 12; i++) {
                        var iStr = i < 10 ? '0' + i.toString() : i.toString();
                        data['NI_' + iStr + '__c'] += tempData['NI_' + iStr + '__c'];
                        if (data.Last_Year_Forecast_Cube_2__r != null && tempData.Last_Year_Forecast_Cube_2__r != null) {
                            data.Last_Year_Forecast_Cube_2__r['NI_' + iStr + '__c'] += tempData.Last_Year_Forecast_Cube_2__r['NI_' + iStr + '__c'];
                        } else if (data.Last_Year_Forecast_Cube_2__r != null || tempData.Last_Year_Forecast_Cube_2__r != null) {
                            data['Last_Year_Forecast_Cube_2__r'] = data['Last_Year_Forecast_Cube_2__r'] ? data['Last_Year_Forecast_Cube_2__r'] : {};
                            data.Last_Year_Forecast_Cube_2__r['NI_' + iStr + '__c'] = data.Last_Year_Forecast_Cube_2__r != null ? data.Last_Year_Forecast_Cube_2__r['NI_' + iStr + '__c']: tempData.Last_Year_Forecast_Cube_2__r['NI_' + iStr + '__c'];
                        }
                    }
                }
                mapTemp.set(data.Income_Type__c, data);
            });
        }

        var feeNameSet = [
            'TF Fee',
            'FX Fee',
            'Credit Fee',
            'Derivative Fee',
            'IB Fee',
            'CM Fee',
            'EDC Fee',
            'L/G Fee',
            'Fleet Fee',
            'BA Fee',
            'AS Fee',
            'MF Fee',
            'AL Fee',
            'Supply Chain'
        ];

        var newAllFeeTemp = [];

        feeNameSet.forEach((feeName) => {
            if (mapTemp.has(feeName)) {
                newAllFeeTemp.push(mapTemp.get(feeName));
            } else {
                var emptyFee = {
                    Income_Type__c: feeName,
                    NI_01__c: 0,
                    NI_02__c: 0,
                    NI_03__c: 0,
                    NI_04__c: 0,
                    NI_05__c: 0,
                    NI_06__c: 0,
                    NI_07__c: 0,
                    NI_08__c: 0,
                    NI_09__c: 0,
                    NI_10__c: 0,
                    NI_11__c: 0,
                    NI_12__c: 0,
                    Total: 0,
                    YTD: 0
                };
                newAllFeeTemp.push(emptyFee);
            }
        });
        return newAllFeeTemp;
    },

    setFee: function (component, helper, allFee, cube1, cube1LY, targetList) {
        component.set('v.isLoading', true);

        var jsonCSV = component.get('v.jsonCSV')
        var team = component.get('v.team')
        var rm = component.get('v.rm')

        var thisMonth = new Date().getMonth();
        var thisYear = new Date().getFullYear();
        var reportYear = component.get('v.Year');
        if (targetList != null) {
            var target = {
            };

            targetList.forEach((tempTarget) => {

                target.NI_Target_Monthly__c ? (target.NI_Target_Monthly__c += (tempTarget.NI_Target_Monthly__c ? tempTarget.NI_Target_Monthly__c : 0)) : (tempTarget.NI_Target_Monthly__c ? target.NI_Target_Monthly__c = tempTarget.NI_Target_Monthly__c : target.NI_Target_Monthly__c)
                target.TargetFeeAmount__c ? (target.TargetFeeAmount__c += (tempTarget.TargetFeeAmount__c ? tempTarget.TargetFeeAmount__c : 0)) : (tempTarget.TargetFeeAmount__c ? target.TargetFeeAmount__c = tempTarget.TargetFeeAmount__c : target.TargetFeeAmount__c)
                target.TargetNIIdAmount__c ? (target.TargetNIIdAmount__c += (tempTarget.TargetNIIdAmount__c ? tempTarget.TargetNIIdAmount__c : 0)) : (tempTarget.TargetNIIdAmount__c ? target.TargetNIIdAmount__c = tempTarget.TargetNIIdAmount__c : target.TargetNIIdAmount__c)
                target.TargetNIIcAmount__c ? (target.TargetNIIcAmount__c += (tempTarget.TargetNIIcAmount__c ? tempTarget.TargetNIIcAmount__c : 0)) : (tempTarget.TargetNIIcAmount__c ? target.TargetNIIcAmount__c = tempTarget.TargetNIIcAmount__c : target.TargetNIIcAmount__c)
                target.Round_2_Target_NI_3_9__c ? (target.Round_2_Target_NI_3_9__c += (tempTarget.Round_2_Target_NI_3_9__c ? tempTarget.Round_2_Target_NI_3_9__c : 0)) : (tempTarget.Round_2_Target_NI_3_9__c ? target.Round_2_Target_NI_3_9__c = tempTarget.Round_2_Target_NI_3_9__c : target.Round_2_Target_NI_3_9__c)
                target.Round_3_Target_NI_6_6__c ? (target.Round_3_Target_NI_6_6__c += (tempTarget.Round_3_Target_NI_6_6__c ? tempTarget.Round_3_Target_NI_6_6__c : 0)) : (tempTarget.Round_3_Target_NI_6_6__c ? target.Round_3_Target_NI_6_6__c = tempTarget.Round_3_Target_NI_6_6__c : target.Round_3_Target_NI_6_6__c)
                target.Round_4_Target_NI_9_3__c ? (target.Round_4_Target_NI_9_3__c += (tempTarget.Round_4_Target_NI_9_3__c ? tempTarget.Round_4_Target_NI_9_3__c : 0)) : (tempTarget.Round_4_Target_NI_9_3__c ? target.Round_4_Target_NI_9_3__c = tempTarget.Round_4_Target_NI_9_3__c : target.Round_4_Target_NI_9_3__c)
                target.TargetFeeAmount_3_9__c ? (target.TargetFeeAmount_3_9__c += (tempTarget.TargetFeeAmount_3_9__c ? tempTarget.TargetFeeAmount_3_9__c : 0)) : (tempTarget.TargetFeeAmount_3_9__c ? target.TargetFeeAmount_3_9__c = tempTarget.TargetFeeAmount_3_9__c : target.TargetFeeAmount_3_9__c)
                target.TargetFeeAmount_6_6__c ? (target.TargetFeeAmount_6_6__c += (tempTarget.TargetFeeAmount_6_6__c ? tempTarget.TargetFeeAmount_6_6__c : 0)) : (tempTarget.TargetFeeAmount_6_6__c ? target.TargetFeeAmount_6_6__c = tempTarget.TargetFeeAmount_6_6__c : target.TargetFeeAmount_6_6__c)
                target.TargetFeeAmount_9_3__c ? (target.TargetFeeAmount_9_3__c += (tempTarget.TargetFeeAmount_9_3__c ? tempTarget.TargetFeeAmount_9_3__c : 0)) : (tempTarget.TargetFeeAmount_9_3__c ? target.TargetFeeAmount_9_3__c = tempTarget.TargetFeeAmount_9_3__c : target.TargetFeeAmount_9_3__c)
                target.TargetNIIcAmount_3_9__c ? (target.TargetNIIcAmount_3_9__c += (tempTarget.TargetNIIcAmount_3_9__c ? tempTarget.TargetNIIcAmount_3_9__c : 0)) : (tempTarget.TargetNIIcAmount_3_9__c ? target.TargetNIIcAmount_3_9__c = tempTarget.TargetNIIcAmount_3_9__c : target.TargetNIIcAmount_3_9__c)
                target.TargetNIIcAmount_6_6__c ? (target.TargetNIIcAmount_6_6__c += (tempTarget.TargetNIIcAmount_6_6__c ? tempTarget.TargetNIIcAmount_6_6__c : 0)) : (tempTarget.TargetNIIcAmount_6_6__c ? target.TargetNIIcAmount_6_6__c = tempTarget.TargetNIIcAmount_6_6__c : target.TargetNIIcAmount_6_6__c)
                target.TargetNIIcAmount_9_3__c ? (target.TargetNIIcAmount_9_3__c += (tempTarget.TargetNIIcAmount_9_3__c ? tempTarget.TargetNIIcAmount_9_3__c : 0)) : (tempTarget.TargetNIIcAmount_9_3__c ? target.TargetNIIcAmount_9_3__c = tempTarget.TargetNIIcAmount_9_3__c : target.TargetNIIcAmount_9_3__c)
                target.TargetNIIdAmount_3_9__c ? (target.TargetNIIdAmount_3_9__c += (tempTarget.TargetNIIdAmount_3_9__c ? tempTarget.TargetNIIdAmount_3_9__c : 0)) : (tempTarget.TargetNIIdAmount_3_9__c ? target.TargetNIIdAmount_3_9__c = tempTarget.TargetNIIdAmount_3_9__c : target.TargetNIIdAmount_3_9__c)
                target.TargetNIIdAmount_6_6__c ? (target.TargetNIIdAmount_6_6__c += (tempTarget.TargetNIIdAmount_6_6__c ? tempTarget.TargetNIIdAmount_6_6__c : 0)) : (tempTarget.TargetNIIdAmount_6_6__c ? target.TargetNIIdAmount_6_6__c = tempTarget.TargetNIIdAmount_6_6__c : target.TargetNIIdAmount_6_6__c)
                target.TargetNIIdAmount_9_3__c ? (target.TargetNIIdAmount_9_3__c += (tempTarget.TargetNIIdAmount_9_3__c ? tempTarget.TargetNIIdAmount_9_3__c : 0)) : (tempTarget.TargetNIIdAmount_9_3__c ? target.TargetNIIdAmount_9_3__c = tempTarget.TargetNIIdAmount_9_3__c : target.TargetNIIdAmount_9_3__c)
            });

            target.Monthly__c = target.NI_Target_Monthly__c == 0 ? 0 : (target.NI_Target_Monthly__c / 12 );
            target.NI_Target_Monthly__c = (target.NI_Target_Monthly__c);
            target['Monthly_show'] = target.NI_Target_Monthly__c == 0 ? 0 : (target.NI_Target_Monthly__c / 12 / 10 ** 6).toFixed(2);
            target['NI_Target_Monthly_show'] = (target.NI_Target_Monthly__c/ 10 ** 6).toFixed(2);
            target['Monthly_Title'] = helper.numberWithCommas(target.NI_Target_Monthly__c == 0 ? 0 : (target.NI_Target_Monthly__c / 12));
            target['NI_Target_Monthly_Title'] = helper.numberWithCommas(target.NI_Target_Monthly__c);
        }

        var totalFee = {
            Income_Type__c: 'Fee',
            Last_Year: 0,
            NI_01__c: 0,
            NI_02__c: 0,
            NI_03__c: 0,
            NI_04__c: 0,
            NI_05__c: 0,
            NI_06__c: 0,
            NI_07__c: 0,
            NI_08__c: 0,
            NI_09__c: 0,
            NI_10__c: 0,
            NI_11__c: 0,
            NI_12__c: 0,
            Total: 0,
            YTD: 0,
            AchieveFY: 0,
            Last_Year_YTD: 0,
            YOY: 0,
            Variance: 0,
            Achieve: 0,
            FYTarget: (target != null && target.TargetFeeAmount__c != null) ? target.TargetFeeAmount__c : '',
            FYTarget39: (target != null && target.TargetFeeAmount_3_9__c != null) ? target.TargetFeeAmount_3_9__c : '',
            FYTarget66: (target != null && target.TargetFeeAmount_6_6__c != null) ? target.TargetFeeAmount_6_6__c : '',
            FYTarget93: (target != null && target.TargetFeeAmount_9_3__c != null) ? target.TargetFeeAmount_9_3__c : '',
            Variance39: 0,
            Achieve39: 0,
            Variance66: 0,
            Achieve66: 0,
            Variance93: 0,
            Achieve93: 0,
        };

        if (allFee != null) {
            allFee.forEach((fee) => {
                totalFee.NI_01__c += fee.NI_01__c;
                totalFee.NI_02__c += fee.NI_02__c;
                totalFee.NI_03__c += fee.NI_03__c;
                totalFee.NI_04__c += fee.NI_04__c;
                totalFee.NI_05__c += fee.NI_05__c;
                totalFee.NI_06__c += fee.NI_06__c;
                totalFee.NI_07__c += fee.NI_07__c;
                totalFee.NI_08__c += fee.NI_08__c;
                totalFee.NI_09__c += fee.NI_09__c;
                totalFee.NI_10__c += fee.NI_10__c;
                totalFee.NI_11__c += fee.NI_11__c;
                totalFee.NI_12__c += fee.NI_12__c;
                fee['Total'] = 0;
                fee['YTD'] = 0;
                fee['Last_Year_YTD'] = 0;
                fee['Last_Year'] = 0 ;
                for (var i = 1; i <= 12; i++) {
                var monthStr = i < 10 ? '0' + i.toString() : i.toString();
                fee.Total += fee['NI_' + monthStr + '__c'];
                fee.YTD += thisMonth >= i ? fee['NI_' + monthStr + '__c'] : 0;
                if (fee.Last_Year_Forecast_Cube_2__r != null) {
                    
                fee.Last_Year += fee.Last_Year_Forecast_Cube_2__r != null ? fee.Last_Year_Forecast_Cube_2__r['NI_'+ monthStr +'__c'] : 0;
                    fee.Last_Year_YTD +=
                    thisMonth >= i
                        ? fee.Last_Year_Forecast_Cube_2__r['NI_' + monthStr + '__c']
                        : 0;
                }
                fee['NI_' + monthStr + '_show'] = (
                    fee['NI_' + monthStr + '__c'] /
                    10 ** 6
                ).toFixed(2);
                fee['NI_' + monthStr + '_Title'] = helper.numberWithCommas(fee['NI_' + monthStr + '__c']);
                }
                fee.YTD = reportYear > thisYear ? '' : fee.YTD;
                totalFee.Last_Year += fee.Last_Year;
                totalFee.Total += fee.Total;
                totalFee.YTD += fee.YTD;
                totalFee.Last_Year_YTD += fee.Last_Year_YTD;
                fee.YOY = reportYear > thisYear ? '' : fee.Last_Year_YTD != 0 ? fee.YTD / fee.Last_Year_YTD : 0;
                fee['Total_show'] = (fee.Total / 10 ** 6).toFixed(2);
                fee['YTD_show'] =  reportYear > thisYear ? '' : (fee.YTD / 10 ** 6).toFixed(2);
                fee['Last_Year_show'] = (fee.Last_Year / 10 ** 6).toFixed(2);
                
                fee['Total_Title'] = helper.numberWithCommas(fee.Total);
                fee['YTD_Title'] = reportYear > thisYear ? '' : helper.numberWithCommas(fee.YTD);
                fee['YOY_Title'] = reportYear > thisYear ? '' : helper.numberWithCommas(fee.YOY * 100);
                fee['Last_Year_Title'] = helper.numberWithCommas(fee.Last_Year);
                if (parseInt(fee.Year__c) > thisMonth) {
                    
                }
                jsonCSV = jsonCSV.concat(helper.setJSONData(component,helper, 'Fee', fee, team, rm))
            }, allFee);

            totalFee.YTD = reportYear > thisYear ? '' : totalFee.YTD;
            totalFee['YOY'] =  reportYear > thisYear ? '' : (totalFee.Last_Year_YTD != 0 ? totalFee.YTD / totalFee.Last_Year_YTD : 0);
            totalFee['AchieveFY'] = totalFee.FYTarget == '' ? '' : totalFee.FYTarget == 0 ? 0 : (totalFee.YTD / totalFee.FYTarget);
            totalFee['Variance'] = totalFee.FYTarget == '' ? '' : totalFee.YTD - (totalFee.FYTarget / 12) * thisMonth;
            totalFee['Achieve'] = totalFee.FYTarget == '' ? '' : totalFee.FYTarget == 0 ? 0 : ((totalFee.YTD / totalFee.FYTarget) / thisMonth) * 12;
            totalFee['Variance39'] = totalFee.FYTarget39 == '' ? '' : totalFee.YTD - (totalFee.FYTarget39 / 12) * thisMonth;
            totalFee['Achieve39'] = totalFee.FYTarget39 == '' ? '' : totalFee.FYTarget39 == 0 ? 0 : ((totalFee.YTD / totalFee.FYTarget39) / thisMonth) * 12;
            totalFee['Variance66'] = totalFee.FYTarget66 == '' ? '' : totalFee.YTD - (totalFee.FYTarget66 / 12) * thisMonth;
            totalFee['Achieve66'] = totalFee.FYTarget66 == '' ? '' : totalFee.FYTarget66 == 0 ? 0 : ((totalFee.YTD / totalFee.FYTarget66) / thisMonth) * 12;
            totalFee['Variance93'] = totalFee.FYTarget93 == '' ? '' : totalFee.YTD - (totalFee.FYTarget93 / 12) * thisMonth;
            totalFee['Achieve93'] = totalFee.FYTarget93 == '' ? '' : totalFee.FYTarget93 == 0 ? 0 : ((totalFee.YTD / totalFee.FYTarget93) / thisMonth) * 12;

            var showTotalFee = {};

            showTotalFee['Income_Type__c'] = 'Fee';
            showTotalFee['Last_Year'] = (totalFee.Last_Year / 10 ** 6).toFixed(2);
            showTotalFee['Last_Year_Title'] = helper.numberWithCommas(totalFee.Last_Year);
            showTotalFee['NI_01__c'] = (totalFee.NI_01__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_02__c'] = (totalFee.NI_02__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_03__c'] = (totalFee.NI_03__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_04__c'] = (totalFee.NI_04__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_05__c'] = (totalFee.NI_05__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_06__c'] = (totalFee.NI_06__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_07__c'] = (totalFee.NI_07__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_08__c'] = (totalFee.NI_08__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_09__c'] = (totalFee.NI_09__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_10__c'] = (totalFee.NI_10__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_11__c'] = (totalFee.NI_11__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_12__c'] = (totalFee.NI_12__c / 10 ** 6).toFixed(2);
            showTotalFee['NI_01_Title'] = helper.numberWithCommas(totalFee.NI_01__c);
            showTotalFee['NI_02_Title'] = helper.numberWithCommas(totalFee.NI_02__c);
            showTotalFee['NI_03_Title'] = helper.numberWithCommas(totalFee.NI_03__c);
            showTotalFee['NI_04_Title'] = helper.numberWithCommas(totalFee.NI_04__c);
            showTotalFee['NI_05_Title'] = helper.numberWithCommas(totalFee.NI_05__c);
            showTotalFee['NI_06_Title'] = helper.numberWithCommas(totalFee.NI_06__c);
            showTotalFee['NI_07_Title'] = helper.numberWithCommas(totalFee.NI_07__c);
            showTotalFee['NI_08_Title'] = helper.numberWithCommas(totalFee.NI_08__c);
            showTotalFee['NI_09_Title'] = helper.numberWithCommas(totalFee.NI_09__c);
            showTotalFee['NI_10_Title'] = helper.numberWithCommas(totalFee.NI_10__c);
            showTotalFee['NI_11_Title'] = helper.numberWithCommas(totalFee.NI_11__c);
            showTotalFee['NI_12_Title'] = helper.numberWithCommas(totalFee.NI_12__c);
            showTotalFee['Total'] = (totalFee.Total / 10 ** 6).toFixed(2);
            showTotalFee['Total_Title'] = helper.numberWithCommas(totalFee.Total);
            showTotalFee['YOY'] = reportYear > thisYear ? '' : (totalFee.Last_Year_YTD != 0 ? totalFee.YTD / totalFee.Last_Year_YTD : 0);
            showTotalFee['YOY_Title'] = reportYear > thisYear ? '' : (totalFee.Last_Year_YTD != 0 ? helper.numberWithCommas((totalFee.YTD / totalFee.Last_Year_YTD) * 100) : 0);
            showTotalFee['YTD'] = reportYear > thisYear ? '' : ((totalFee.YTD / 10 ** 6).toFixed(2));
            showTotalFee['YTD_Title'] = reportYear > thisYear ? '' : (helper.numberWithCommas(totalFee.YTD));
            showTotalFee['AchieveFY'] = totalFee.FYTarget == '' ? '' : totalFee.FYTarget == 0 ? 0 : (totalFee.YTD / totalFee.FYTarget);
            showTotalFee['AchieveFY_Title'] = totalFee.FYTarget == '' ? '' : helper.numberWithCommas((totalFee.YTD / totalFee.FYTarget) * 100);
            
            showTotalFee['Variance'] = totalFee['Variance'] == '' ? '' :(thisMonth == 0 || totalFee.FYTarget  == 0) ? 0 : ((totalFee.YTD - (totalFee.FYTarget / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
            showTotalFee['Variance_Title'] = totalFee['Variance'] == '' ? '' :helper.numberWithCommas((totalFee.YTD - (totalFee.FYTarget / 12) * thisMonth));

            showTotalFee['Achieve'] = totalFee['Achieve'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget == 0) ? 0 : ((totalFee.YTD / totalFee.FYTarget) / thisMonth) * 12;
            showTotalFee['Achieve_Title'] = totalFee['Achieve'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget == 0) ? 0 : helper.numberWithCommas((((totalFee.YTD / totalFee.FYTarget) / thisMonth) * 12) * 100);
            showTotalFee['FYTarget'] = totalFee['FYTarget'] == '' ? '' :totalFee.FYTarget == null ? '' : (totalFee.FYTarget / 10 ** 6).toFixed(2);
            showTotalFee['FYTarget_Title'] = totalFee['FYTarget'] == '' ? '' :helper.numberWithCommas(totalFee.FYTarget);

            showTotalFee['Variance39'] = totalFee['Variance39'] == '' ? '' :(thisMonth == 0 || totalFee.FYTarget39  == 0) ? 0 : ((totalFee.YTD - (totalFee.FYTarget39 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
            showTotalFee['Variance39_Title'] = totalFee['Variance39'] == '' ? '' :helper.numberWithCommas((totalFee.YTD - (totalFee.FYTarget39 / 12) * thisMonth));

            showTotalFee['Achieve39'] = totalFee['Achieve39'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget39 == 0) ? '' : ((totalFee.YTD / totalFee.FYTarget39) / thisMonth) * 12;
            showTotalFee['Achieve39_Title'] = totalFee['Achieve39'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget39 == 0) ? '' : helper.numberWithCommas((((totalFee.YTD / totalFee.FYTarget39) / thisMonth) * 12) * 100);
            showTotalFee['FYTarget39'] = totalFee['FYTarget39'] == '' ? '' :totalFee.FYTarget39 == null ? '' : (totalFee.FYTarget39 / 10 ** 6).toFixed(2);
            showTotalFee['FYTarget39_Title'] = totalFee['FYTarget39'] == '' ? '' :helper.numberWithCommas(totalFee.FYTarget39);

            showTotalFee['Variance66'] = totalFee['Variance66'] == '' ? '' :(thisMonth == 0 || totalFee.FYTarget66  == 0) ? 0 : ((totalFee.YTD - (totalFee.FYTarget66 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
            showTotalFee['Variance66_Title'] = totalFee['Variance66'] == '' ? '' :helper.numberWithCommas((totalFee.YTD - (totalFee.FYTarget66 / 12) * thisMonth));
            showTotalFee['Achieve66'] = totalFee['Achieve66'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget66 == 0) ? '' : ((totalFee.YTD / totalFee.FYTarget66) / thisMonth) * 12;
            showTotalFee['Achieve66_Title'] = totalFee['Achieve66'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget66 == 0) ? '' : helper.numberWithCommas((((totalFee.YTD / totalFee.FYTarget66) / thisMonth) * 12) * 100);
            showTotalFee['FYTarget66'] = totalFee['FYTarget66'] == '' ? '' :totalFee.FYTarget66 == null ? '' : (totalFee.FYTarget66 / 10 ** 6).toFixed(2);
            showTotalFee['FYTarget66_Title'] = totalFee['FYTarget66'] == '' ? '' :helper.numberWithCommas(totalFee.FYTarget66);

            showTotalFee['Variance93'] = totalFee['Variance93'] == '' ? '' :(thisMonth == 0 || totalFee.FYTarget93  == 0) ? 0 : ((totalFee.YTD - (totalFee.FYTarget93 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
            showTotalFee['Variance93_Title'] = totalFee['Variance93'] == '' ? '' :helper.numberWithCommas((totalFee.YTD - (totalFee.FYTarget93 / 12) * thisMonth));
            showTotalFee['Achieve93'] = totalFee['Achieve93'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget93 == 0) ? '' : ((totalFee.YTD / totalFee.FYTarget93) / thisMonth) * 12;
            showTotalFee['Achieve93_Title'] = totalFee['Achieve93'] === '' ? '' :(totalFee.YTD == 0 || totalFee.FYTarget93 == 0) ? '' : helper.numberWithCommas((((totalFee.YTD / totalFee.FYTarget93) / thisMonth) * 12) * 100);
            showTotalFee['FYTarget93'] = totalFee['FYTarget93'] == '' ? '' :totalFee.FYTarget93 == null ? '' : (totalFee.FYTarget93 / 10 ** 6).toFixed(2);
            showTotalFee['FYTarget93_Title'] = totalFee['FYTarget93'] == '' ? '' :helper.numberWithCommas(totalFee.FYTarget93);

            component.set('v.totalFee', showTotalFee);
            component.set('v.Cube2Data', allFee);

            jsonCSV.unshift(helper.setJSONData(component,helper, 'Fee', totalFee, team, rm)) 
            component.set('v.jsonCSV', helper.parseObj(jsonCSV))
        }
        helper.SumNI(component, helper, cube1, cube1LY, target, totalFee);

        component.set('v.targetList', targetList);
    },

    SumNI: function (component, helper, listCube1 , cube1LY, target, totalFee) {
        var thisMonth = new Date().getMonth();

        var thisYear = new Date().getFullYear();
        var reportYear = component.get('v.Year');
        component.set('v.isLoading', true);

        var sumUpNIId = {
            RM_Name: listCube1[0].Customer__r.Owner.Name,
            Team_Code__c: listCube1[0].Customer__r.Owner.Zone__c,
            Product_Group: 'NIId - DPA',
            Limit__c: 0,
            Last_Year_Ending__c: 0,
            NI_01__c: 0,
            NI_02__c: 0,
            NI_03__c: 0,
            NI_04__c: 0,
            NI_05__c: 0,
            NI_06__c: 0,
            NI_07__c: 0,
            NI_08__c: 0,
            NI_09__c: 0,
            NI_10__c: 0,
            NI_11__c: 0,
            NI_12__c: 0,
            Current_Balance__c: 0,
            YTD: 0,
            Achieved: 0,
            YOY: 0,
            Total_NI: 0,
            Last_Year_YTD: 0,
            FYTarget: (typeof target.TargetNIIdAmount__c === 'undefined') ? null : target.TargetNIIdAmount__c,
            FYTarget39: (typeof target.TargetNIIdAmount_3_9__c === 'undefined') ? null :target.TargetNIIdAmount_3_9__c,
            FYTarget66: (typeof target.TargetNIIdAmount_6_6__c === 'undefined') ? null :target.TargetNIIdAmount_6_6__c,
            FYTarget93: (typeof target.TargetNIIdAmount_9_3__c === 'undefined') ? null :target.TargetNIIdAmount_9_3__c,
        };

        var sumUpNIIc = {
            RM_Name: listCube1[0].Customer__r.Owner.Name,
            Team_Code__c: listCube1[0].Customer__r.Owner.Zone__c,
            Product_Group: 'NIIc (PL)',
            Limit__c: 0,
            Last_Year_Ending__c: 0,
            NI_01__c: 0,
            NI_02__c: 0,
            NI_03__c: 0,
            NI_04__c: 0,
            NI_05__c: 0,
            NI_06__c: 0,
            NI_07__c: 0,
            NI_08__c: 0,
            NI_09__c: 0,
            NI_10__c: 0,
            NI_11__c: 0,
            NI_12__c: 0,
            Current_Balance__c: 0,
            YTD: 0,
            Achieved: 0,
            YOY: 0,
            Total_NI: 0,
            Last_Year_YTD: 0,
            FYTarget: (typeof target.TargetNIIcAmount__c === 'undefined') ? null : target.TargetNIIcAmount__c,
            FYTarget39: (typeof target.TargetNIIcAmount_3_9__c === 'undefined') ? null :target.TargetNIIcAmount_3_9__c,
            FYTarget66: (typeof target.TargetNIIcAmount_6_6__c === 'undefined') ? null :target.TargetNIIcAmount_6_6__c,
            FYTarget93: (typeof target.TargetNIIcAmount_9_3__c === 'undefined') ? null :target.TargetNIIcAmount_9_3__c,
        };

        cube1LY.forEach((thisCube1LY) => {
            if (thisCube1LY.Product__r.Financial_Product_Domain__c == 'Credit') {
                for (var i = 1; i <= 12; i++) {
                    var iStr = i < 10 ? '0' + i.toString() : i.toString();
                    sumUpNIIc.Last_Year_Ending__c += thisCube1LY['NI_'+iStr+'__c'] ;
                    sumUpNIIc.Last_Year_YTD += i <= thisMonth ? thisCube1LY['NI_' + iStr + '__c'] : 0;
                }
            }else{
                for (var i = 1; i <= 12; i++) {
                    var iStr = i < 10 ? '0' + i.toString() : i.toString();
                    sumUpNIId.Last_Year_Ending__c += thisCube1LY['NI_'+iStr+'__c'] ;
                    sumUpNIId.Last_Year_YTD += i <= thisMonth ? thisCube1LY['NI_' + iStr + '__c'] : 0;
                    
                }
            }
        });
        listCube1.forEach((cube1) => {
            if (cube1.Product__r.Financial_Product_Domain__c == 'Credit') {
                sumUpNIIc.Limit__c += cube1.Limit__c != null ? cube1.Limit__c : 0;
                sumUpNIIc.NI_01__c += cube1.NI_01__c != null ? cube1.NI_01__c : 0;
                sumUpNIIc.NI_02__c += cube1.NI_02__c != null ? cube1.NI_02__c : 0;
                sumUpNIIc.NI_03__c += cube1.NI_03__c != null ? cube1.NI_03__c : 0;
                sumUpNIIc.NI_04__c += cube1.NI_04__c != null ? cube1.NI_04__c : 0;
                sumUpNIIc.NI_05__c += cube1.NI_05__c != null ? cube1.NI_05__c : 0;
                sumUpNIIc.NI_06__c += cube1.NI_06__c != null ? cube1.NI_06__c : 0;
                sumUpNIIc.NI_07__c += cube1.NI_07__c != null ? cube1.NI_07__c : 0;
                sumUpNIIc.NI_08__c += cube1.NI_08__c != null ? cube1.NI_08__c : 0;
                sumUpNIIc.NI_09__c += cube1.NI_09__c != null ? cube1.NI_09__c : 0;
                sumUpNIIc.NI_10__c += cube1.NI_10__c != null ? cube1.NI_10__c : 0;
                sumUpNIIc.NI_11__c += cube1.NI_11__c != null ? cube1.NI_11__c : 0;
                sumUpNIIc.NI_12__c += cube1.NI_12__c != null ? cube1.NI_12__c : 0;
                sumUpNIIc.Current_Balance__c += cube1.Current_Balance__c != null ? cube1.Current_Balance__c : 0;
                
            } else {
                sumUpNIId.Limit__c += cube1.Limit__c != null ? cube1.Limit__c : 0;
                sumUpNIId.NI_01__c += cube1.NI_01__c != null ? cube1.NI_01__c : 0;
                sumUpNIId.NI_02__c += cube1.NI_02__c != null ? cube1.NI_02__c : 0;
                sumUpNIId.NI_03__c += cube1.NI_03__c != null ? cube1.NI_03__c : 0;
                sumUpNIId.NI_04__c += cube1.NI_04__c != null ? cube1.NI_04__c : 0;
                sumUpNIId.NI_05__c += cube1.NI_05__c != null ? cube1.NI_05__c : 0;
                sumUpNIId.NI_06__c += cube1.NI_06__c != null ? cube1.NI_06__c : 0;
                sumUpNIId.NI_07__c += cube1.NI_07__c != null ? cube1.NI_07__c : 0;
                sumUpNIId.NI_08__c += cube1.NI_08__c != null ? cube1.NI_08__c : 0;
                sumUpNIId.NI_09__c += cube1.NI_09__c != null ? cube1.NI_09__c : 0;
                sumUpNIId.NI_10__c += cube1.NI_10__c != null ? cube1.NI_10__c : 0;
                sumUpNIId.NI_11__c += cube1.NI_11__c != null ? cube1.NI_11__c : 0;
                sumUpNIId.NI_12__c += cube1.NI_12__c != null ? cube1.NI_12__c : 0;
                sumUpNIId.Current_Balance__c +=
                cube1.Current_Balance__c != null ? cube1.Current_Balance__c : 0;
                
            }
        });

        var showSumUpNIIc = {};
        var showSumUpNIId = {};

        for (var i = 1; i <= 12; i++) {
            var iStr = i < 10 ? '0' + i.toString() : i.toString();
            sumUpNIIc.Total_NI += sumUpNIIc['NI_' + iStr + '__c'];
            sumUpNIIc.YTD += thisMonth >= i ? sumUpNIIc['NI_' + iStr + '__c'] : 0;
            showSumUpNIIc['NI_' + iStr + '_Title'] = helper.numberWithCommas(sumUpNIIc['NI_' + iStr + '__c']);
            showSumUpNIIc['NI_' + iStr + '__c'] = (sumUpNIIc['NI_' + iStr + '__c'] / 10 ** 6 ).toFixed(2);
        }

        for (var i = 1; i <= 12; i++) {
        var iStr = i < 10 ? '0' + i.toString() : i.toString();
        sumUpNIId.Total_NI += sumUpNIId['NI_' + iStr + '__c'];
        sumUpNIId.YTD += thisMonth >= i ? sumUpNIId['NI_' + iStr + '__c'] : 0;
        showSumUpNIId['NI_' + iStr + '_Title'] = helper.numberWithCommas(sumUpNIId['NI_' + iStr + '__c']);
        showSumUpNIId['NI_' + iStr + '__c'] = (sumUpNIId['NI_' + iStr + '__c'] / 10 ** 6 ).toFixed(2);
        }

        sumUpNIIc.YTD = reportYear > thisYear ? '' : sumUpNIIc.YTD;
        sumUpNIIc['YOY'] = reportYear > thisYear ? '' : (sumUpNIIc.Last_Year_YTD != 0 ? sumUpNIIc.YTD / sumUpNIIc.Last_Year_YTD : 0);
        sumUpNIIc['AchieveFY'] = sumUpNIIc.FYTarget !== null ? (sumUpNIIc.FYTarget == 0 ? 0 : (sumUpNIIc.YTD / sumUpNIIc.FYTarget)) : null;
        sumUpNIIc['Achieve'] = sumUpNIIc.FYTarget !== null ? (sumUpNIIc.FYTarget == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget) / thisMonth) * 12) : null;
        sumUpNIIc['Achieve39'] = sumUpNIIc.FYTarget39 !== null ? (sumUpNIIc.FYTarget39 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget39) / thisMonth) * 12) : null;
        sumUpNIIc['Achieve66'] = sumUpNIIc.FYTarget66 !== null ? (sumUpNIIc.FYTarget66 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget66) / thisMonth) * 12) : null;
        sumUpNIIc['Achieve93'] = sumUpNIIc.FYTarget93 !== null ? (sumUpNIIc.FYTarget93 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget93) / thisMonth) * 12) : null;
        sumUpNIIc['Variance'] = sumUpNIIc.FYTarget !== null ? (sumUpNIIc.YTD - (sumUpNIIc.FYTarget / 12) * thisMonth) : null;
        sumUpNIIc['Variance39'] = sumUpNIIc.FYTarget39 !== null ? (sumUpNIIc.YTD - (sumUpNIIc.FYTarget39 / 12) * thisMonth) : null;
        sumUpNIIc['Variance66'] = sumUpNIIc.FYTarget66 !== null ? (sumUpNIIc.YTD - (sumUpNIIc.FYTarget66 / 12) * thisMonth) : null;
        sumUpNIIc['Variance93'] = sumUpNIIc.FYTarget93 !== null ? (sumUpNIIc.YTD - (sumUpNIIc.FYTarget93 / 12) * thisMonth) : null;

        sumUpNIId.YTD = reportYear > thisYear ? '' : sumUpNIId.YTD;
        sumUpNIId['YOY'] = reportYear > thisYear ? '' : (sumUpNIId.Last_Year_YTD != 0 ? sumUpNIId.YTD / sumUpNIId.Last_Year_YTD : 0);
        sumUpNIId['AchieveFY'] = sumUpNIId.FYTarget !== null ? (sumUpNIId.FYTarget == 0 ? 0 : (sumUpNIId.YTD / sumUpNIId.FYTarget)) : null ;
        sumUpNIId['Achieve'] = sumUpNIId.FYTarget !== null ? (sumUpNIId.FYTarget == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget) / thisMonth) * 12) : null ;
        sumUpNIId['Achieve39'] = sumUpNIId.FYTarget39 !== null ? (sumUpNIId.FYTarget39 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget39) / thisMonth) * 12) : null;
        sumUpNIId['Achieve66'] = sumUpNIId.FYTarget66 !== null ? (sumUpNIId.FYTarget66 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget66) / thisMonth) * 12) : null;
        sumUpNIId['Achieve93'] = sumUpNIId.FYTarget93 !== null ? (sumUpNIId.FYTarget93 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget93) / thisMonth) * 12) : null;
        sumUpNIId['Variance'] = sumUpNIId.FYTarget !== null ? (sumUpNIId.YTD - (sumUpNIId.FYTarget / 12) * thisMonth) : null;
        sumUpNIId['Variance39'] = sumUpNIId.FYTarget39 !== null ? (sumUpNIId.YTD - (sumUpNIId.FYTarget39 / 12) * thisMonth) : null;
        sumUpNIId['Variance66'] = sumUpNIId.FYTarget66 !== null ? (sumUpNIId.YTD - (sumUpNIId.FYTarget66 / 12) * thisMonth) : null;
        sumUpNIId['Variance93'] = sumUpNIId.FYTarget93 !== null ? (sumUpNIId.YTD - (sumUpNIId.FYTarget93 / 12) * thisMonth) : null;

        showSumUpNIIc['RM_Name'] = listCube1[0].Customer__r.Owner.Name;
        showSumUpNIIc['OwnerId'] = listCube1[0].Customer__r.OwnerId;
        showSumUpNIIc['Team_Code__c'] = listCube1[0].Customer__r.Owner.Zone__c;
        showSumUpNIIc['Last_Year_Ending__c'] = (sumUpNIIc.Last_Year_Ending__c / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Limit__c'] = (sumUpNIIc.Limit__c / 10 ** 6).toFixed(2);
        showSumUpNIIc['YOY'] = reportYear > thisYear ? '' : (sumUpNIIc.Last_Year_YTD != 0 ? sumUpNIIc.YTD / sumUpNIIc.Last_Year_YTD : 0);
        showSumUpNIIc['YTD'] = reportYear > thisYear ? '' : (sumUpNIIc.YTD / 10 ** 6).toFixed(2);
        showSumUpNIIc['Current_Balance__c'] = (sumUpNIIc.Current_Balance__c / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Total_NI'] = (sumUpNIIc.Total_NI / 10 ** 6).toFixed(2);
        showSumUpNIIc['AchieveFY'] = sumUpNIIc.FYTarget !== null ? (sumUpNIIc.FYTarget == 0 ? 0 : (sumUpNIIc.YTD / sumUpNIIc.FYTarget)) : null;
        showSumUpNIIc['Variance'] = sumUpNIIc.FYTarget == null ? '' : (thisMonth == 0 || sumUpNIIc.FYTarget  == 0) ? 0 : ((sumUpNIIc.YTD - (sumUpNIIc.FYTarget / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Achieve'] = (sumUpNIIc.YTD=== '' || sumUpNIIc.FYTarget == null) ? '' : (sumUpNIIc.FYTarget == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget) / thisMonth) * 12);
        showSumUpNIIc['FYTarget'] = sumUpNIIc.FYTarget == null ? '' :(sumUpNIIc.FYTarget / 10 ** 6).toFixed(2);
        showSumUpNIIc['Variance39'] = sumUpNIIc.FYTarget39 == null ? '' : (thisMonth == 0 || sumUpNIIc.FYTarget39  == 0) ? 0 : ((sumUpNIIc.YTD - (sumUpNIIc.FYTarget39 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Achieve39'] = (sumUpNIIc.YTD=== '' || sumUpNIIc.FYTarget39 == null) ? '' : (sumUpNIIc.FYTarget39 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget39) / thisMonth) * 12);
        showSumUpNIIc['FYTarget39'] = sumUpNIIc.FYTarget39 == null ? '' : (sumUpNIIc.FYTarget39 / 10 ** 6).toFixed(2);
        showSumUpNIIc['Variance66'] = sumUpNIIc.FYTarget66 == null ? '' : (thisMonth == 0 || sumUpNIIc.FYTarget66  == 0) ? 0 : ((sumUpNIIc.YTD - (sumUpNIIc.FYTarget66 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Achieve66'] = (sumUpNIIc.YTD=== '' || sumUpNIIc.FYTarget66 == null) ? '' : (sumUpNIIc.FYTarget66 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget66) / thisMonth) * 12);
        showSumUpNIIc['FYTarget66'] = sumUpNIIc.FYTarget66 == null ? '' : (sumUpNIIc.FYTarget66 / 10 ** 6).toFixed(2);
        showSumUpNIIc['Variance93'] = sumUpNIIc.FYTarget93 == null ? '' : (thisMonth == 0 || sumUpNIIc.FYTarget93  == 0) ? 0 : ((sumUpNIIc.YTD - (sumUpNIIc.FYTarget93 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIIc['Achieve93'] = (sumUpNIIc.YTD=== '' || sumUpNIIc.FYTarget93 == null) ? '' : (sumUpNIIc.FYTarget93 == 0 ? 0 : ((sumUpNIIc.YTD / sumUpNIIc.FYTarget93) / thisMonth) * 12);
        showSumUpNIIc['FYTarget93'] = sumUpNIIc.FYTarget93 == null ? '' : (sumUpNIIc.FYTarget93 / 10 ** 6).toFixed(2);
        showSumUpNIId['RM_Name'] = listCube1[0].Customer__r.Owner.Name;
        showSumUpNIId['Team_Code__c'] = listCube1[0].Customer__r.Owner.Zone__c;
        showSumUpNIId['Last_Year_Ending__c'] = (sumUpNIId.Last_Year_Ending__c / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Limit__c'] = (sumUpNIId.Limit__c / 10 ** 6).toFixed(2);
        showSumUpNIId['YOY'] = reportYear > thisYear ? '' : (sumUpNIId.Last_Year_YTD != 0 ? sumUpNIId.YTD / sumUpNIId.Last_Year_YTD : 0);
        showSumUpNIId['YTD'] = reportYear > thisYear ? '' : (sumUpNIId.YTD / 10 ** 6).toFixed(2);
        showSumUpNIId['Current_Balance__c'] = (sumUpNIId.Current_Balance__c / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Total_NI'] = (sumUpNIId.Total_NI / 10 ** 6).toFixed(2);
        showSumUpNIId['AchieveFY'] = sumUpNIId.FYTarget !== null ? (sumUpNIId.FYTarget == 0 ? 0 : (sumUpNIId.YTD / sumUpNIId.FYTarget)) : null;
        showSumUpNIId['Variance'] = sumUpNIId.FYTarget == null ? '' : (thisMonth == 0 || sumUpNIId.FYTarget  == 0) ? 0 : ((sumUpNIId.YTD - (sumUpNIId.FYTarget / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Achieve'] = (sumUpNIId.YTD=== '' || sumUpNIId.FYTarget == null) ? '' : (sumUpNIId.FYTarget == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget) / thisMonth) * 12);
        showSumUpNIId['FYTarget'] = sumUpNIId.FYTarget == null ? '' :(sumUpNIId.FYTarget / 10 ** 6).toFixed(2);
        showSumUpNIId['Variance39'] = sumUpNIId.FYTarget39 == null ? '' : (thisMonth == 0 || sumUpNIId.FYTarget39  == 0) ? 0 : ((sumUpNIId.YTD - (sumUpNIId.FYTarget39 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Achieve39'] = (sumUpNIId.YTD=== '' || sumUpNIId.FYTarget3 == null) ? '' : (sumUpNIId.FYTarget39 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget39) / thisMonth) * 12);
        showSumUpNIId['FYTarget39'] = sumUpNIId.FYTarget39 == null ? '' : (sumUpNIId.FYTarget39 / 10 ** 6).toFixed(2);
        showSumUpNIId['Variance66'] = sumUpNIId.FYTarget66 == null ? '' : (thisMonth == 0 || sumUpNIId.FYTarget66  == 0) ? 0 : ((sumUpNIId.YTD - (sumUpNIId.FYTarget66 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Achieve66'] = (sumUpNIId.YTD=== '' || sumUpNIId.FYTarget66 == null) ? '' : (sumUpNIId.FYTarget66 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget66) / thisMonth) * 12);
        showSumUpNIId['FYTarget66'] = sumUpNIId.FYTarget66 == null ? '' : (sumUpNIId.FYTarget66 / 10 ** 6).toFixed(2);
        showSumUpNIId['Variance93'] = sumUpNIId.FYTarget93 == null ? '' : (thisMonth == 0 || sumUpNIId.FYTarget93  == 0) ? 0 : ((sumUpNIId.YTD - (sumUpNIId.FYTarget93 / 12) * thisMonth) / 10 ** 6 ).toFixed(2);
        showSumUpNIId['Achieve93'] = (sumUpNIId.YTD=== '' || sumUpNIId.FYTarget93== null ) ? '' : (sumUpNIId.FYTarget93 == 0 ? 0 : ((sumUpNIId.YTD / sumUpNIId.FYTarget93) / thisMonth) * 12);
        showSumUpNIId['FYTarget93'] = sumUpNIId.FYTarget93 == null ? '' : (sumUpNIId.FYTarget93 / 10 ** 6).toFixed(2);

        showSumUpNIIc['Last_Year_Ending_Title'] = helper.numberWithCommas(sumUpNIIc.Last_Year_Ending__c);
        showSumUpNIIc['Limit_Title'] = helper.numberWithCommas(sumUpNIIc.Limit__c);
        showSumUpNIIc['YOY_Title'] = reportYear > thisYear ? '' : (sumUpNIIc.Last_Year_YTD != 0 ? helper.numberWithCommas((sumUpNIIc.YTD / sumUpNIIc.Last_Year_YTD) * 100) : 0);
        showSumUpNIIc['YTD_Title'] = reportYear > thisYear ? '' : (helper.numberWithCommas(sumUpNIIc.YTD));
        showSumUpNIIc['Current_Balance_Title'] = helper.numberWithCommas(sumUpNIIc.Current_Balance__c  );
        showSumUpNIIc['Total_NI_Title'] = helper.numberWithCommas(sumUpNIIc.Total_NI );
        showSumUpNIIc['AchieveFY_Title'] = sumUpNIIc.FYTarget == 0 ? 0 : helper.numberWithCommas((sumUpNIIc.YTD / sumUpNIIc.FYTarget) * 100);
        showSumUpNIIc['Variance_Title'] = helper.numberWithCommas((sumUpNIIc.YTD - (sumUpNIIc.FYTarget / 12) * thisMonth));
        showSumUpNIIc['Achieve_Title'] = sumUpNIIc.FYTarget == 0 ? 0 : helper.numberWithCommas((((sumUpNIIc.YTD / sumUpNIIc.FYTarget) / thisMonth) * 12) * 100);
        showSumUpNIIc['FYTarget_Title'] = helper.numberWithCommas(sumUpNIIc.FYTarget );
        showSumUpNIIc['Variance39_Title'] = helper.numberWithCommas((sumUpNIIc.YTD - (sumUpNIIc.FYTarget39 / 12) * thisMonth)  );
        showSumUpNIIc['Achieve39_Title'] = sumUpNIIc.FYTarget39 == 0 ? 0 : helper.numberWithCommas((((sumUpNIIc.YTD / sumUpNIIc.FYTarget39) / thisMonth) * 12) * 100);
        showSumUpNIIc['FYTarget39_Title'] = helper.numberWithCommas(sumUpNIIc.FYTarget39 );
        showSumUpNIIc['Variance66_Title'] = helper.numberWithCommas((sumUpNIIc.YTD - (sumUpNIIc.FYTarget66 / 12) * thisMonth)  );
        showSumUpNIIc['Achieve66_Title'] = sumUpNIIc.FYTarget66 == 0 ? 0 : helper.numberWithCommas((((sumUpNIIc.YTD / sumUpNIIc.FYTarget66) / thisMonth) * 12) * 100);
        showSumUpNIIc['FYTarget66_Title'] = helper.numberWithCommas(sumUpNIIc.FYTarget66 );
        showSumUpNIIc['Variance93_Title'] = helper.numberWithCommas((sumUpNIIc.YTD - (sumUpNIIc.FYTarget93 / 12) * thisMonth)  );
        showSumUpNIIc['Achieve93_Title'] = sumUpNIIc.FYTarget93 == 0 ? 0 : helper.numberWithCommas((((sumUpNIIc.YTD / sumUpNIIc.FYTarget93) / thisMonth) * 12) * 100);
        showSumUpNIIc['FYTarget93_Title'] = helper.numberWithCommas(sumUpNIIc.FYTarget93 );
        
        showSumUpNIId['Last_Year_Ending_Title'] = helper.numberWithCommas(sumUpNIId.Last_Year_Ending__c);
        showSumUpNIId['Limit_Title'] = helper.numberWithCommas(sumUpNIId.Limit__c);
        showSumUpNIId['YOY_Title'] = reportYear > thisYear ? '' : (sumUpNIId.Last_Year_YTD != 0 ? helper.numberWithCommas((sumUpNIId.YTD / sumUpNIId.Last_Year_YTD) * 100) : 0);
        showSumUpNIId['YTD_Title'] = reportYear > thisYear ? '' : (helper.numberWithCommas(sumUpNIId.YTD));
        showSumUpNIId['Current_Balance_Title'] = helper.numberWithCommas(sumUpNIId.Current_Balance__c  );
        showSumUpNIId['Total_NI_Title'] = helper.numberWithCommas(sumUpNIId.Total_NI );
        showSumUpNIId['AchieveFY_Title'] = sumUpNIId.FYTarget == 0 ? 0 : helper.numberWithCommas((sumUpNIId.YTD / sumUpNIId.FYTarget) * 100);
        showSumUpNIId['Variance_Title'] = helper.numberWithCommas((sumUpNIId.YTD - (sumUpNIId.FYTarget / 12) * thisMonth));
        showSumUpNIId['Achieve_Title'] = sumUpNIId.FYTarget == 0 ? 0 : helper.numberWithCommas((((sumUpNIId.YTD / sumUpNIId.FYTarget) / thisMonth) * 12) * 100);
        showSumUpNIId['FYTarget_Title'] = helper.numberWithCommas(sumUpNIId.FYTarget );
        showSumUpNIId['Variance39_Title'] = helper.numberWithCommas((sumUpNIId.YTD - (sumUpNIId.FYTarget39 / 12) * thisMonth) );
        showSumUpNIId['Achieve39_Title'] = sumUpNIId.FYTarget39 == 0 ? 0 : helper.numberWithCommas((((sumUpNIId.YTD / sumUpNIId.FYTarget39) / thisMonth) * 12) * 100);
        showSumUpNIId['FYTarget39_Title'] = helper.numberWithCommas(sumUpNIId.FYTarget39 );
        showSumUpNIId['Variance66_Title'] = helper.numberWithCommas((sumUpNIId.YTD - (sumUpNIId.FYTarget66 / 12) * thisMonth)  );
        showSumUpNIId['Achieve66_Title'] = sumUpNIId.FYTarget66 == 0 ? 0 : helper.numberWithCommas((((sumUpNIId.YTD / sumUpNIId.FYTarget66) / thisMonth) * 12) * 100);
        showSumUpNIId['FYTarget66_Title'] = helper.numberWithCommas(sumUpNIId.FYTarget66 );
        showSumUpNIId['Variance93_Title'] = helper.numberWithCommas((sumUpNIId.YTD - (sumUpNIId.FYTarget93 / 12) * thisMonth)  );
        showSumUpNIId['Achieve93_Title'] = sumUpNIId.FYTarget93 == 0 ? 0 : helper.numberWithCommas((((sumUpNIId.YTD / sumUpNIId.FYTarget66) / thisMonth) * 12) * 100);
        showSumUpNIId['FYTarget93_Title'] = helper.numberWithCommas(sumUpNIId.FYTarget93 );
        component.set('v.sumUpNIIc', showSumUpNIIc);
        component.set('v.sumUpNIId', showSumUpNIId);

        var totalNI = {
            Last_Year: totalFee.Last_Year + sumUpNIIc.Last_Year_Ending__c + sumUpNIId.Last_Year_Ending__c,
            NI_01__c: totalFee.NI_01__c + sumUpNIIc.NI_01__c + sumUpNIId.NI_01__c,
            NI_02__c: totalFee.NI_02__c + sumUpNIIc.NI_02__c + sumUpNIId.NI_02__c,
            NI_03__c: totalFee.NI_03__c + sumUpNIIc.NI_03__c + sumUpNIId.NI_03__c,
            NI_04__c: totalFee.NI_04__c + sumUpNIIc.NI_04__c + sumUpNIId.NI_04__c,
            NI_05__c: totalFee.NI_05__c + sumUpNIIc.NI_05__c + sumUpNIId.NI_05__c,
            NI_06__c: totalFee.NI_06__c + sumUpNIIc.NI_06__c + sumUpNIId.NI_06__c,
            NI_07__c: totalFee.NI_07__c + sumUpNIIc.NI_07__c + sumUpNIId.NI_07__c,
            NI_08__c: totalFee.NI_08__c + sumUpNIIc.NI_08__c + sumUpNIId.NI_08__c,
            NI_09__c: totalFee.NI_09__c + sumUpNIIc.NI_09__c + sumUpNIId.NI_09__c,
            NI_10__c: totalFee.NI_10__c + sumUpNIIc.NI_10__c + sumUpNIId.NI_10__c,
            NI_11__c: totalFee.NI_11__c + sumUpNIIc.NI_11__c + sumUpNIId.NI_11__c,
            NI_12__c: totalFee.NI_12__c + sumUpNIIc.NI_12__c + sumUpNIId.NI_12__c,
            Total: totalFee.Total + sumUpNIIc.Total_NI + sumUpNIId.Total_NI,
            YTD: 0,
            Achieved: 0,
            YOY: reportYear > thisYear ? '' : (totalFee.Last_Year_YTD + sumUpNIIc.Last_Year_YTD + sumUpNIId.Last_Year_YTD) == 0 ? 0 : ((totalFee.YTD + sumUpNIIc.YTD + sumUpNIId.YTD) / (totalFee.Last_Year_YTD + sumUpNIIc.Last_Year_YTD + sumUpNIId.Last_Year_YTD)),
            Variance: 0,
            AchieveYTD: 0,
            Variance39: 0,
            AchieveYTD39: 0,
            Variance66: 0,
            AchieveYTD66: 0,
            Variance93: 0,
            AchieveYTD93: 0,
            ActualYTD: 0,
            FYTarget: (typeof target.NI_Target_Monthly__c === 'undefined') ? null : target.NI_Target_Monthly__c,
            FYTarget39: (typeof target.Round_2_Target_NI_3_9__c === 'undefined') ? null : target.Round_2_Target_NI_3_9__c,
            FYTarget66: (typeof target.Round_3_Target_NI_6_6__c === 'undefined') ? null : target.Round_3_Target_NI_6_6__c,
            FYTarget93: (typeof target.Round_4_Target_NI_9_3__c === 'undefined') ? null : target.Round_4_Target_NI_9_3__c
        };

        for (var i = 1; i <= 12; i++) {
            iStr = i < 10 ? '0' + i.toString() : i.toString();
            totalNI.YTD += thisMonth >= i ? totalNI['NI_' + iStr + '__c'] : 0;
            totalNI['NI_'+ iStr +'_show'] = (totalNI['NI_'+ iStr +'__c'] / 10**6 ).toFixed(2);
            totalNI['NI_'+ iStr +'_Title'] = helper.numberWithCommas(totalNI['NI_'+ iStr +'__c']);
        }
        totalNI.Achieved = totalNI.FYTarget == null ? null : (totalNI.FYTarget != 0 ? totalNI.YTD / totalNI.FYTarget : 0);
        totalNI.YTD = reportYear > thisYear ? '' :totalNI.YTD;
        totalNI.Variance = totalNI.FYTarget == null ? null : parseFloat(totalNI.YTD) - totalNI.FYTarget * (thisMonth / 12);
        totalNI.Variance39 = totalNI.FYTarget39 == null ? null : parseFloat(totalNI.YTD) - totalNI.FYTarget39 * (thisMonth / 12);
        totalNI.Variance66 = totalNI.FYTarget66 == null ? null : parseFloat(totalNI.YTD) - totalNI.FYTarget66 * (thisMonth / 12);
        totalNI.Variance93 = totalNI.FYTarget93 == null ? null : parseFloat(totalNI.YTD) - totalNI.FYTarget93 * (thisMonth / 12);
        totalNI.AchieveYTD = totalNI.FYTarget == null ? null : (totalNI.FYTarget * thisMonth != 0 ? totalNI.YTD / ((totalNI.FYTarget / 12) * thisMonth) : 0);
        totalNI.AchieveYTD39 = totalNI.FYTarget39 == null ? null : (totalNI.FYTarget39 * thisMonth != 0 ? totalNI.YTD / ((totalNI.FYTarget39 / 12) * thisMonth) : 0);
        totalNI.AchieveYTD66 = totalNI.FYTarget66 == null ? null : (totalNI.FYTarget66 * thisMonth != 0 ? totalNI.YTD / ((totalNI.FYTarget66 / 12) * thisMonth) : 0);
        totalNI.AchieveYTD93 = totalNI.FYTarget93 == null ? null : (totalNI.FYTarget93 * thisMonth != 0 ? totalNI.YTD / ((totalNI.FYTarget93 / 12) * thisMonth) : 0);
        totalNI.ActualYTD = totalNI.YTD;
        totalNI['Last_Year_show'] = (totalNI.Last_Year / 10**6).toFixed(2);
        totalNI['Last_Year_Title'] = helper.numberWithCommas(totalNI.Last_Year);
        
        totalNI['Total_show'] = (totalNI.Total / 10**6).toFixed(2);
        totalNI['YTD_show'] = reportYear > thisYear ? '' : ((totalNI.YTD / 10**6).toFixed(2));
        totalNI['Total_Title'] = helper.numberWithCommas(totalNI.Total);
        totalNI['YTD_Title'] = reportYear > thisYear ? '' : helper.numberWithCommas(totalNI.YTD);
        totalNI['YOY_Title'] = reportYear > thisYear ? '' : helper.numberWithCommas(totalNI.YOY * 100);
        totalNI['Achieved_Title'] = totalNI.FYTarget == null ? '' : (totalNI.FYTarget != 0 ? helper.numberWithCommas((totalNI.YTD / totalNI.FYTarget) * 100) : 0);
        totalNI['Variance_show'] = totalNI.Variance == null ? '' : (totalNI.Variance / 10**6).toFixed(2)
        totalNI['Variance39_show'] = totalNI.Variance39 == null ? '' : (totalNI.Variance39 / 10**6).toFixed(2)
        totalNI['Variance66_show'] = totalNI.Variance66 == null ? '' : (totalNI.Variance66 / 10**6).toFixed(2)
        totalNI['Variance93_show'] = totalNI.Variance93 == null ? '' : (totalNI.Variance93 / 10**6).toFixed(2)
        totalNI['Variance_Title'] = helper.numberWithCommas(totalNI.Variance);
        totalNI['Variance39_Title'] = helper.numberWithCommas(totalNI.Variance39);
        totalNI['Variance66_Title'] = helper.numberWithCommas(totalNI.Variance66);
        totalNI['Variance93_Title'] = helper.numberWithCommas(totalNI.Variance93);
        totalNI['FYTarget_show'] = totalNI.FYTarget == null ? '' : (totalNI.FYTarget / 10**6).toFixed(2);
        totalNI['FYTarget39_show'] = totalNI.FYTarget39 == null ? '' : (totalNI.FYTarget39 / 10**6).toFixed(2);
        totalNI['FYTarget66_show'] = totalNI.FYTarget66 == null ? '' : (totalNI.FYTarget66 / 10**6).toFixed(2);
        totalNI['FYTarget93_show'] = totalNI.FYTarget93 == null ? '' : (totalNI.FYTarget93 / 10**6).toFixed(2);
        totalNI['FYTarget_Title'] = helper.numberWithCommas(totalNI.FYTarget);
        totalNI['FYTarget39_Title'] = helper.numberWithCommas(totalNI.FYTarget39);
        totalNI['FYTarget66_Title'] = helper.numberWithCommas(totalNI.FYTarget66);
        totalNI['FYTarget93_Title'] = helper.numberWithCommas(totalNI.FYTarget93);
        totalNI['AchieveYTD_Title'] = helper.numberWithCommas((totalNI.AchieveYTD) * 100);
        totalNI['AchieveYTD39_Title'] = helper.numberWithCommas((totalNI.AchieveYTD39) * 100);
        totalNI['AchieveYTD66_Title'] = helper.numberWithCommas((totalNI.AchieveYTD66) * 100);
        totalNI['AchieveYTD66_Title'] = helper.numberWithCommas((totalNI.AchieveYTD93) * 100);

        component.set('v.totalNI', totalNI);
        component.set('v.target', target);

        // export CSV
        var team = component.get('v.team')
        var rm = component.get('v.rm')

        var jsonCSV = helper.parseObj(component.get('v.jsonCSV'))
        jsonCSV.unshift(helper.setJSONData(component,helper, 'NIId - DPA', sumUpNIId, team, rm))
        jsonCSV.unshift(helper.setJSONData(component,helper, 'NIIc (PL)', sumUpNIIc, team, rm))
        jsonCSV.unshift(helper.setJSONData(component,helper, 'Total NI', totalNI, team, rm))
        jsonCSV.unshift(helper.setJSONTargetData(component,helper, target, team, rm))
        component.set('v.jsonCSV', jsonCSV)
        component.set('v.isLoading', false);
    },
    setJSONTargetData: function(component, helper, data, team, rm) {
        var obj = {}
        var userProfile = component.get('v.userProfile')        
        var month = parseInt(component.get('v.Month'));
        var year = component.get('v.Year')      

        var totalColumn = 'Y' + year + '(FC)'
        obj['Team'] = team
        obj['RM'] = rm
        obj['Product'] = 'Target By Month'
        obj['LastYear ('+ (year - 1) +')'] = ''

        obj['Jan '+ (month >0  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Feb '+ (month >1  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Mar '+ (month >2  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Apr '+ (month >3  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['May '+ (month >4  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Jun '+ (month >5  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Jul '+ (month >6  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Aug '+ (month >7  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Sep '+ (month >8  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Oct '+ (month >9  ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Nov '+ (month >10 ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''
        obj['Dec '+ (month >11 ? '(A)': '(E)')] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.Monthly__c) ? helper.numberWithDecimal(data.Monthly__c) : ''

        obj[totalColumn] = (data == null || data == undefined) ? '' : helper.numberWithDecimal(data.NI_Target_Monthly__c) ? helper.numberWithDecimal(data.NI_Target_Monthly__c) : ''
        obj['YTD'] = ''
        obj['Achieved (%)'] = ''
        obj['YOY (%)'] = ''

        obj['Original target ('+year+'): Variance'] = ''
        obj['Original target ('+year+'): Achieve'] = ''
        obj['Original target ('+year+'): FYTarget'] = ''
        if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
            if (month >= 3) {
                obj['3+9F target ('+year+'): Variance'] = ''
                obj['3+9F target ('+year+'): Achieve'] = ''
                obj['3+9F target ('+year+'): FYTarget'] = ''
            }
            if (month >= 6) {
                obj['6+6F target ('+year+'): Variance'] = ''
                obj['6+6F target ('+year+'): Achieve'] = ''
                obj['6+6F target ('+year+'): FYTarget'] = ''
            }
            if (month >= 9) {
                obj['9+3F target ('+year+'): Variance'] = ''
                obj['9+3F target ('+year+'): Achieve'] = ''
                obj['9+3F target ('+year+'): FYTarget'] = ''
            }
        }
      
        return obj
    },
    setJSONData: function(component,helper, product, data, team, rm) {
        var obj = {}
        var userProfile = component.get('v.userProfile')
        var year = component.get('v.Year')          
        var month = parseInt(component.get('v.Month'));
        var totalColumn = 'Y' + year + '(FC)'

        obj['Team'] = team
        obj['RM'] = rm
        obj['Product'] = (product == 'Fee') ? data.Income_Type__c : product
        obj['LastYear ('+ (year - 1) +')'] = (product == 'Total NI' || product == 'Fee') ? helper.numberWithDecimal(data.Last_Year) : helper.numberWithDecimal(data.Last_Year_Ending__c)

        obj['Jan '+(month > 0  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_01__c)
        obj['Feb '+(month > 1  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_02__c)
        obj['Mar '+(month > 2  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_03__c)
        obj['Apr '+(month > 3  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_04__c)
        obj['May '+(month > 4  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_05__c)
        obj['Jun '+(month > 5  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_06__c)
        obj['Jul '+(month > 6  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_07__c)
        obj['Aug '+(month > 7  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_08__c)
        obj['Sep '+(month > 8  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_09__c)
        obj['Oct '+(month > 9  ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_10__c)
        obj['Nov '+(month > 10 ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_11__c)
        obj['Dec '+(month > 11 ? '(A)': '(E)')] = helper.numberWithDecimal(data.NI_12__c)

        obj[totalColumn] = (product == 'Total NI' || product == 'Fee') ? helper.numberWithDecimal(data.Total) : helper.numberWithDecimal(data.Total_NI) 
        obj['YTD'] = helper.numberWithDecimal(data.YTD)
        
        if(product == 'Fee') {
            obj['Achieved (%)'] = (data.Income_Type__c == 'Fee') ? (data.AchieveFY === '' ? '' : helper.numberWithDecimal(data.AchieveFY * 100) + '%') : ''
        } else if (product == 'Total NI'){
            obj['Achieved (%)'] = data.Achieved !== null ? helper.numberWithDecimal(data.Achieved * 100) + '%'  : '' 
        } else {
            obj['Achieved (%)'] = data.AchieveFY !== null ? helper.numberWithDecimal(data.AchieveFY * 100) + '%' : ''
        }

        obj['YOY (%)'] = (data.YOY == null || data.YOY === '') ? '' : helper.numberWithDecimal(data.YOY * 100) + '%'

        if(product == 'Fee') {
            obj['Original target ('+year+'): Variance'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve === '' ? '' : helper.numberWithDecimal(data.Variance)
            obj['Original target ('+year+'): Achieve'] = (data.Income_Type__c != 'Fee') ? '' : (data.Achieve === '' ? '' : helper.numberWithDecimal(data.Achieve * 100) + '%')
            obj['Original target ('+year+'): FYTarget'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve === '' ? '' : helper.numberWithDecimal(data.FYTarget)
            if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
                if (month >= 3) {
                    obj['3+9F target ('+year+'): Variance'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve39 === '' ? '' :helper.numberWithDecimal(data.Variance39)
                    obj['3+9F target ('+year+'): Achieve'] = (data.Income_Type__c != 'Fee') ? '' : (data.Achieve39 === '' ? '' : helper.numberWithDecimal(data.Achieve39 * 100) + '%')
                    obj['3+9F target ('+year+'): FYTarget'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve39 === '' ? '' :helper.numberWithDecimal(data.FYTarget39)
                }
                if (month >= 6) {
                    obj['6+6F target ('+year+'): Variance'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve66 === '' ? '' : helper.numberWithDecimal(data.Variance66)
                    obj['6+6F target ('+year+'): Achieve'] = (data.Income_Type__c != 'Fee') ? '' : (data.Achieve66 === '' ? '' : helper.numberWithDecimal(data.Achieve66 * 100) + '%')
                    obj['6+6F target ('+year+'): FYTarget'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve66 === '' ? '' : helper.numberWithDecimal(data.FYTarget66)
                }
                if (month >= 9) {
                    obj['9+3F target ('+year+'): Variance'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve93 === '' ? '' : helper.numberWithDecimal(data.Variance93)
                    obj['9+3F target ('+year+'): Achieve'] = (data.Income_Type__c != 'Fee') ? '' : (data.Achieve93 === '' ? '' : helper.numberWithDecimal(data.Achieve93 * 100) + '%')
                    obj['9+3F target ('+year+'): FYTarget'] = (data.Income_Type__c != 'Fee') ? '' : data.Achieve93 === '' ? '' : helper.numberWithDecimal(data.FYTarget93)
                }
            }
        } else if (product == 'Total NI') {
            obj['Original target ('+year+'): Variance'] = data.Variance !== null ? helper.numberWithDecimal(data.Variance) : ''
            obj['Original target ('+year+'): Achieve'] = data.AchieveYTD !== null ? helper.numberWithDecimal(data.AchieveYTD * 100) + '%' : ''
            obj['Original target ('+year+'): FYTarget'] = data.FYTarget !== null ? helper.numberWithDecimal(data.FYTarget) : ''
            if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
                if (month >= 3) {
                    obj['3+9F target ('+year+'): Variance'] = data.Variance39 !== null ? helper.numberWithDecimal(data.Variance39) : ''
                    obj['3+9F target ('+year+'): Achieve'] = data.AchieveYTD39 !== null? helper.numberWithDecimal(data.AchieveYTD39 * 100) + '%' : ''
                    obj['3+9F target ('+year+'): FYTarget'] = data.FYTarget39 !== null ? helper.numberWithDecimal(data.FYTarget39) : ''
                }
                if (month >= 6) {
                    obj['6+6F target ('+year+'): Variance'] = data.Variance66 !== null ? helper.numberWithDecimal(data.Variance66) : ''
                    obj['6+6F target ('+year+'): Achieve'] = data.AchieveYTD66 !== null ? helper.numberWithDecimal(data.AchieveYTD66 * 100) + '%' : ''
                    obj['6+6F target ('+year+'): FYTarget'] = data.FYTarget66 !== null ? helper.numberWithDecimal(data.FYTarget66) : ''
                }
                if (month >= 9) {
                    obj['9+3F target ('+year+'): Variance'] = data.Variance93 !== null ? helper.numberWithDecimal(data.Variance93) : ''
                    obj['9+3F target ('+year+'): Achieve'] = data.AchieveYTD66 ? helper.numberWithDecimal(data.AchieveYTD66 * 100) + '%' : ''
                    obj['9+3F target ('+year+'): FYTarget'] = data.FYTarget93 !== null ? helper.numberWithDecimal(data.FYTarget93) : ''
                }
            }
        } else {
            obj['Original target ('+year+'): Variance'] = data.Variance !== null ? helper.numberWithDecimal(data.Variance) : ''
            obj['Original target ('+year+'): Achieve'] = data.Achieve !== null ? helper.numberWithDecimal(data.Achieve * 100) + '%' : ''
            obj['Original target ('+year+'): FYTarget'] = data.FYTarget !== null ? helper.numberWithDecimal(data.FYTarget) : ''
            if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
                if (month >= 3) {
                    obj['3+9F target ('+year+'): Variance'] = data.Variance39 !== null ? helper.numberWithDecimal(data.Variance39) : ''
                    obj['3+9F target ('+year+'): Achieve'] = data.Achieve39 !== null ? helper.numberWithDecimal(data.Achieve39 * 100) + '%' : ''
                    obj['3+9F target ('+year+'): FYTarget'] = data.FYTarget39 !== null ? helper.numberWithDecimal(data.FYTarget39) : ''
                }
                if (month >= 6) {
                    obj['6+6F target ('+year+'): Variance'] = data.Variance66 !== null ? helper.numberWithDecimal(data.Variance66) : ''
                    obj['6+6F target ('+year+'): Achieve'] = data.Achieve66 !== null ? helper.numberWithDecimal(data.Achieve66 * 100) + '%' : ''
                    obj['6+6F target ('+year+'): FYTarget'] = data.FYTarget66 !== null ? helper.numberWithDecimal(data.FYTarget66) : ''
                }
                if (month >= 9) {
                    obj['9+3F target ('+year+'): Variance'] = data.Variance93 !== null ? helper.numberWithDecimal(data.Variance93) : ''
                    obj['9+3F target ('+year+'): Achieve'] = data.Achieve93 !== null ? helper.numberWithDecimal(data.Achieve93 * 100) + '%' : ''
                    obj['9+3F target ('+year+'): FYTarget'] = data.FYTarget93 !== null ? helper.numberWithDecimal(data.FYTarget93) : ''
                }
            }
        }
      
        return obj
    },
    
    numberWithCommas : function (x) {
        if(x == null) return ''
        var parts = x.toString().split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        parts[1] = (parts[1] == '' || parts[1] == null) ? '00': parts[1];
        return parts.join(".");
      },
      
    numberWithDecimal : function (n) {
      var result = (n - Math.floor(n)) !== 0; 
      if(result)
          return n;
      else
          return (Math.round((n) * 100) / 100).toFixed(2);
    },
});