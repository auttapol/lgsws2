({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    setNewDeal: function (component, event, helper) {
        var today = new Date();
        var feeType = [
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
        
        component.set('v.feeType', feeType);

        var newDealList = component.get('v.newDeal');
        var mapIncomeType = new Map();

        if (newDealList != null) {
            newDealList.forEach((data) => {
                if (data.Income_Type__c == 'Front End Fee') {
                    data.Income_Type__c = 'Credit Fee';
                }
                if (data.Income_Type__c == 'Direct CM Fee' || data.Income_Type__c == 'Other CM Fee' ) {
                    data.Income_Type__c = 'CM Fee';
                }

                var key = data.Probability__c + '-' + data.Income_Type__c;
                
                if (mapIncomeType.has(key)) {
                    var newDealGrouped = mapIncomeType.get(key);
                    newDealGrouped['NI_' + data.Month__c] += data.NI_Formula__c;
                    newDealGrouped.Total += data.NI_Formula__c;
                    newDealGrouped['NI_' + data.Month__c +'_show'] = newDealGrouped['NI_' + data.Month__c] / 10**6;
                    newDealGrouped.Total_show = newDealGrouped.Total /10**6;
                    newDealGrouped['NI_' + data.Month__c +'_title'] = helper.numberWithCommas(newDealGrouped['NI_' + data.Month__c]);
                    newDealGrouped.Total_title = helper.numberWithCommas(newDealGrouped.Total);
                    mapIncomeType.set(key, newDealGrouped);
                } else {
                    var newDealGrouped = {
                        NI_01: 0,
                        NI_02: 0,
                        NI_03: 0,
                        NI_04: 0,
                        NI_05: 0,
                        NI_06: 0,
                        NI_07: 0,
                        NI_08: 0,
                        NI_09: 0,
                        NI_10: 0,
                        NI_11: 0,
                        NI_12: 0,
                        Total: 0,
                        NI_01_show: 0,
                        NI_02_show: 0,
                        NI_03_show: 0,
                        NI_04_show: 0,
                        NI_05_show: 0,
                        NI_06_show: 0,
                        NI_07_show: 0,
                        NI_08_show: 0,
                        NI_09_show: 0,
                        NI_10_show: 0,
                        NI_11_show: 0,
                        NI_12_show: 0,
                        Total_show: 0,
                        NI_01_title: 0,
                        NI_02_title: 0,
                        NI_03_title: 0,
                        NI_04_title: 0,
                        NI_05_title: 0,
                        NI_06_title: 0,
                        NI_07_title: 0,
                        NI_08_title: 0,
                        NI_09_title: 0,
                        NI_10_title: 0,
                        NI_11_title: 0,
                        NI_12_title: 0,
                        Total_title: 0,
                    };
                    newDealGrouped['Probability__c'] = data.Probability__c;
                    newDealGrouped['Income_Type__c'] = data.Income_Type__c;
                    newDealGrouped['NI_' + data.Month__c] += data.NI_Formula__c;
                    newDealGrouped.Total += data.NI_Formula__c;
                    
                    newDealGrouped['NI_' + data.Month__c + '_show'] = newDealGrouped['NI_' + data.Month__c]/10**6;
                    newDealGrouped.Total_show = newDealGrouped.Total/10**6;

                    
                    newDealGrouped['NI_' + data.Month__c +'_title'] = helper.numberWithCommas(newDealGrouped['NI_' + data.Month__c]);
                    newDealGrouped.Total_title = helper.numberWithCommas(newDealGrouped.Total);

                    mapIncomeType.set(key, newDealGrouped);
                }
            });
        }

        var probHigh = [];
        var probMed = [];
        var probLow = [];
        var probHighMap = new Map();
        var probMedMap = new Map();
        var probLowMap = new Map();
        var iStr;

        for (var key of mapIncomeType.keys()) {
            var prob = key.split('-')[0];
            var IncomeType = key.split('-')[1];
            if (prob == 'High') {
                probHighMap.set(IncomeType, mapIncomeType.get(key));
            } else if (prob == 'Medium') {
                probMedMap.set(IncomeType, mapIncomeType.get(key));
            } else {
                probLowMap.set(IncomeType, mapIncomeType.get(key));
            }
        }

        var newDealNI = {
            HighNIIc:
                mapIncomeType.get('High-NIIc') != null
                ? mapIncomeType.get('High-NIIc')
                : helper.genNewIncometype('High', 'NIIc'),
            HighNIId:
                mapIncomeType.get('High-NIId') != null
                ? mapIncomeType.get('High-NIId')
                : helper.genNewIncometype('High', 'NIId'),
            MediumNIIc:
                mapIncomeType.get('Medium-NIIc') != null
                ? mapIncomeType.get('Medium-NIIc')
                : helper.genNewIncometype('Medium', 'NIIc'),
            MediumNIId:
                mapIncomeType.get('Medium-NIId') != null
                ? mapIncomeType.get('Medium-NIId')
                : helper.genNewIncometype('Medium', 'NIId'),
            LowNIIc:
                mapIncomeType.get('Low-NIIc') != null
                ? mapIncomeType.get('Low-NIIc')
                : helper.genNewIncometype('Low', 'NIIc'),
            LowNIId:
                mapIncomeType.get('Low-NIId') != null
                ? mapIncomeType.get('Low-NIId')
                : helper.genNewIncometype('Low', 'NIId')
        };

        var totalHigh = helper.genNewIncometype('High', 'Total');
        var totalMed = helper.genNewIncometype('Medium', 'Total');
        var totalLow = helper.genNewIncometype('Low', 'Total');

        feeType.forEach((data) => {
            if (probHighMap.has(data)) {
                probHigh.push(probHighMap.get(data));
            } else {
                var newDealGrouped = helper.genNewIncometype('High', data);
                probHigh.push(newDealGrouped);
            }
            
            if (probMedMap.has(data)) {
                probMed.push(probMedMap.get(data));
            } else {
                var newDealGrouped = helper.genNewIncometype('Medium', data);
                probMed.push(newDealGrouped);
            }
            
            if (probLowMap.has(data)) {
                probLow.push(probLowMap.get(data));
            } else {
                var newDealGrouped = helper.genNewIncometype('Low', data);
                probLow.push(newDealGrouped);
            }
            helper.numberWithCommas
            for (var i = 1; i <= 12; i++) {
                iStr = i < 10 ? '0' + i.toString() : i.toString();
                totalHigh['NI_'+ iStr] += (probHighMap.has(data) ? probHighMap.get(data)['NI_'+iStr] : 0);
                totalMed['NI_'+ iStr] += (probMedMap.has(data) ? probMedMap.get(data)['NI_'+iStr] : 0);
                totalLow['NI_'+ iStr] += (probLowMap.has(data) ? probLowMap.get(data)['NI_'+iStr] : 0);
                totalHigh['Total'] += (probHighMap.has(data) ? probHighMap.get(data)['NI_'+iStr] : 0);
                totalMed['Total'] += (probMedMap.has(data) ? probMedMap.get(data)['NI_'+iStr] : 0);
                totalLow['Total'] += (probLowMap.has(data) ? probLowMap.get(data)['NI_'+iStr] : 0);
                totalHigh['NI_'+ iStr+'_show'] = totalHigh['NI_'+ iStr] / 10**6;
                totalMed['NI_'+ iStr+'_show'] = totalMed['NI_'+ iStr] / 10**6;
                totalLow['NI_'+ iStr+'_show'] = totalLow['NI_'+ iStr] / 10**6;
                totalHigh['NI_'+ iStr+'_title'] = helper.numberWithCommas(totalHigh['NI_'+ iStr]);
                totalMed['NI_'+ iStr+'_title'] = helper.numberWithCommas(totalMed['NI_'+ iStr]);
                totalLow['NI_'+ iStr+'_title'] = helper.numberWithCommas(totalLow['NI_'+ iStr]);
            }
            totalHigh['Total_show'] = totalHigh['Total'] / 10**6;
            totalMed['Total_show'] = totalMed['Total'] /10**6;
            totalLow['Total_show'] = totalLow['Total'] /10**6;
            totalHigh['Total_title'] = helper.numberWithCommas(totalHigh['Total'])
            totalMed['Total_title'] = helper.numberWithCommas(totalMed['Total'])
            totalLow['Total_title'] = helper.numberWithCommas(totalLow['Total'])
        });
		if(today.getFullYear() == component.get('v.Year')){
            for (var i = 1; i <= today.getMonth(); i++) {
                    iStr = i < 10 ? '0' + i.toString() : i.toString();
                    totalHigh['NI_'+iStr] = null;
                    totalMed['NI_'+iStr] = null;
                    totalLow['NI_'+iStr] = null;
                    totalHigh['NI_'+iStr+'_show'] = null;
                    totalMed['NI_'+iStr+'_show'] = null;
                    totalLow['NI_'+iStr+'_show'] = null;
                    probHigh.forEach(fee => {
                        fee['NI_'+iStr] = null;
                        fee['NI_'+iStr+'_show'] = null;
                    });
                    probMed.forEach(fee => {
                        fee['NI_'+iStr] = null;
                        fee['NI_'+iStr+'_show'] = null;
                    });
                    probLow.forEach(fee => {
                        fee['NI_'+iStr] = null;
                        fee['NI_'+iStr+'_show'] = null;
                    });
                }
		}
        
        var newDealFee = {
            High: probHigh,
            totalHigh: totalHigh,
            Medium: probMed,
            totalMed: totalMed,
            Low: probLow,
            totalLow: totalLow
        };

        newDealNI['totalHigh'] = {
            NI_01: newDealFee.totalHigh.NI_01 + newDealNI.HighNIIc.NI_01 +newDealNI.HighNIId.NI_01,
            NI_02: newDealFee.totalHigh.NI_02 + newDealNI.HighNIIc.NI_02 +newDealNI.HighNIId.NI_02,
            NI_03: newDealFee.totalHigh.NI_03 + newDealNI.HighNIIc.NI_03 +newDealNI.HighNIId.NI_03,
            NI_04: newDealFee.totalHigh.NI_04 + newDealNI.HighNIIc.NI_04 +newDealNI.HighNIId.NI_04,
            NI_05: newDealFee.totalHigh.NI_05 + newDealNI.HighNIIc.NI_05 +newDealNI.HighNIId.NI_05,
            NI_06: newDealFee.totalHigh.NI_06 + newDealNI.HighNIIc.NI_06 +newDealNI.HighNIId.NI_06,
            NI_07: newDealFee.totalHigh.NI_07 + newDealNI.HighNIIc.NI_07 +newDealNI.HighNIId.NI_07,
            NI_08: newDealFee.totalHigh.NI_08 + newDealNI.HighNIIc.NI_08 +newDealNI.HighNIId.NI_08,
            NI_09: newDealFee.totalHigh.NI_09 + newDealNI.HighNIIc.NI_09 +newDealNI.HighNIId.NI_09,
            NI_10: newDealFee.totalHigh.NI_10 + newDealNI.HighNIIc.NI_10 +newDealNI.HighNIId.NI_10,
            NI_11: newDealFee.totalHigh.NI_11 + newDealNI.HighNIIc.NI_11 +newDealNI.HighNIId.NI_11,
            NI_12: newDealFee.totalHigh.NI_12 + newDealNI.HighNIIc.NI_12 +newDealNI.HighNIId.NI_12,
            Total: newDealFee.totalHigh.Total + newDealNI.HighNIIc.Total +newDealNI.HighNIId.Total,
        };

        newDealNI['totalMed'] = {
            NI_01: newDealFee.totalMed.NI_01 + newDealNI.MediumNIIc.NI_01 +newDealNI.MediumNIId.NI_01,
            NI_02: newDealFee.totalMed.NI_02 + newDealNI.MediumNIIc.NI_02 +newDealNI.MediumNIId.NI_02,
            NI_03: newDealFee.totalMed.NI_03 + newDealNI.MediumNIIc.NI_03 +newDealNI.MediumNIId.NI_03,
            NI_04: newDealFee.totalMed.NI_04 + newDealNI.MediumNIIc.NI_04 +newDealNI.MediumNIId.NI_04,
            NI_05: newDealFee.totalMed.NI_05 + newDealNI.MediumNIIc.NI_05 +newDealNI.MediumNIId.NI_05,
            NI_06: newDealFee.totalMed.NI_06 + newDealNI.MediumNIIc.NI_06 +newDealNI.MediumNIId.NI_06,
            NI_07: newDealFee.totalMed.NI_07 + newDealNI.MediumNIIc.NI_07 +newDealNI.MediumNIId.NI_07,
            NI_08: newDealFee.totalMed.NI_08 + newDealNI.MediumNIIc.NI_08 +newDealNI.MediumNIId.NI_08,
            NI_09: newDealFee.totalMed.NI_09 + newDealNI.MediumNIIc.NI_09 +newDealNI.MediumNIId.NI_09,
            NI_10: newDealFee.totalMed.NI_10 + newDealNI.MediumNIIc.NI_10 +newDealNI.MediumNIId.NI_10,
            NI_11: newDealFee.totalMed.NI_11 + newDealNI.MediumNIIc.NI_11 +newDealNI.MediumNIId.NI_11,
            NI_12: newDealFee.totalMed.NI_12 + newDealNI.MediumNIIc.NI_12 +newDealNI.MediumNIId.NI_12,
            Total: newDealFee.totalMed.Total + newDealNI.MediumNIIc.Total +newDealNI.MediumNIId.Total,
        };

        newDealNI['totalLow'] = {
            NI_01: newDealFee.totalLow.NI_01 + newDealNI.LowNIIc.NI_01 +newDealNI.LowNIId.NI_01,
            NI_02: newDealFee.totalLow.NI_02 + newDealNI.LowNIIc.NI_02 +newDealNI.LowNIId.NI_02,
            NI_03: newDealFee.totalLow.NI_03 + newDealNI.LowNIIc.NI_03 +newDealNI.LowNIId.NI_03,
            NI_04: newDealFee.totalLow.NI_04 + newDealNI.LowNIIc.NI_04 +newDealNI.LowNIId.NI_04,
            NI_05: newDealFee.totalLow.NI_05 + newDealNI.LowNIIc.NI_05 +newDealNI.LowNIId.NI_05,
            NI_06: newDealFee.totalLow.NI_06 + newDealNI.LowNIIc.NI_06 +newDealNI.LowNIId.NI_06,
            NI_07: newDealFee.totalLow.NI_07 + newDealNI.LowNIIc.NI_07 +newDealNI.LowNIId.NI_07,
            NI_08: newDealFee.totalLow.NI_08 + newDealNI.LowNIIc.NI_08 +newDealNI.LowNIId.NI_08,
            NI_09: newDealFee.totalLow.NI_09 + newDealNI.LowNIIc.NI_09 +newDealNI.LowNIId.NI_09,
            NI_10: newDealFee.totalLow.NI_10 + newDealNI.LowNIIc.NI_10 +newDealNI.LowNIId.NI_10,
            NI_11: newDealFee.totalLow.NI_11 + newDealNI.LowNIIc.NI_11 +newDealNI.LowNIId.NI_11,
            NI_12: newDealFee.totalLow.NI_12 + newDealNI.LowNIIc.NI_12 +newDealNI.LowNIId.NI_12,
            Total: newDealFee.totalLow.Total + newDealNI.LowNIIc.Total +newDealNI.LowNIId.Total,
        };

        newDealNI['totalAll'] = {};
        newDealNI['totalAll'] = {};
        
        newDealNI['totalLow']['Total_show'] = newDealNI['totalLow']['Total'] / 10**6 ;
        newDealNI['totalMed']['Total_show'] = newDealNI['totalMed']['Total'] / 10**6 ;
        newDealNI['totalHigh']['Total_show'] = newDealNI['totalHigh']['Total'] / 10**6 ;
        newDealNI['totalLow']['Total_title'] = helper.numberWithCommas(newDealNI['totalLow']['Total']);
        newDealNI['totalMed']['Total_title'] = helper.numberWithCommas(newDealNI['totalMed']['Total']);
        newDealNI['totalHigh']['Total_title'] = helper.numberWithCommas(newDealNI['totalHigh']['Total']);
        for (var i = 1; i <= 12; i++) {
            iStr = i < 10 ? '0' + i.toString() : i.toString();
            newDealNI['totalLow']['NI_'+iStr+ '_show'] = newDealNI['totalLow']['NI_'+iStr] / 10**6 ;
            newDealNI['totalMed']['NI_'+iStr+ '_show'] = newDealNI['totalMed']['NI_'+iStr] / 10**6 ;
            newDealNI['totalHigh']['NI_'+iStr+ '_show'] = newDealNI['totalHigh']['NI_'+iStr] / 10**6 ;
            newDealNI['totalLow']['NI_'+iStr+ '_title'] = helper.numberWithCommas(newDealNI['totalLow']['NI_'+iStr]);
            newDealNI['totalMed']['NI_'+iStr+ '_title'] = helper.numberWithCommas(newDealNI['totalMed']['NI_'+iStr]);
            newDealNI['totalHigh']['NI_'+iStr+ '_title'] = helper.numberWithCommas(newDealNI['totalHigh']['NI_'+iStr]);
            newDealNI['totalAll']['NI_'+iStr] = newDealNI['totalHigh']['NI_'+iStr] + newDealNI['totalMed']['NI_'+iStr];
            newDealNI['totalAll']['NI_'+iStr+'_show'] = newDealNI['totalAll']['NI_'+iStr] /10**6;
            newDealNI['totalAll']['NI_'+iStr+'_title'] = helper.numberWithCommas(newDealNI['totalAll']['NI_'+iStr]);


            newDealNI['totalAll']['Total'] = newDealNI['totalHigh']['Total'] + newDealNI['totalMed']['Total'];
        }

        newDealNI['totalAll']['Total_show'] = newDealNI['totalAll']['Total'] /10**6;;
        newDealNI['totalAll']['Total_title'] = helper.numberWithCommas(newDealNI['totalAll']['Total']);
        
		if(today.getFullYear() == component.get('v.Year')){
            for (var i = 1; i <= today.getMonth(); i++) {
            iStr = i < 10 ? '0' + i.toString() : i.toString();
            newDealNI.HighNIIc['NI_'+iStr] = null;
            newDealNI.HighNIId['NI_'+iStr] = null;
            newDealNI.MediumNIIc['NI_'+iStr] = null;
            newDealNI.MediumNIId['NI_'+iStr] = null;
            newDealNI.LowNIIc['NI_'+iStr] = null;
            newDealNI.LowNIId['NI_'+iStr] = null;
            newDealNI.HighNIIc['NI_'+iStr+'_show'] = null;
            newDealNI.HighNIId['NI_'+iStr+'_show'] = null;
            newDealNI.MediumNIIc['NI_'+iStr+'_show'] = null;
            newDealNI.MediumNIId['NI_'+iStr+'_show'] = null;
            newDealNI.LowNIIc['NI_'+iStr+'_show'] = null;
            newDealNI.LowNIId['NI_'+iStr+'_show'] = null;
            newDealNI['totalHigh']['NI_'+iStr] = null;
            newDealNI['totalMed']['NI_'+iStr] = null;
            newDealNI['totalLow']['NI_'+iStr] = null;
            newDealNI['totalAll']['NI_'+iStr] = null;
            newDealNI['totalHigh']['NI_'+iStr+'_show'] = null;
            newDealNI['totalMed']['NI_'+iStr+'_show'] = null;
            newDealNI['totalLow']['NI_'+iStr+'_show'] = null;
            newDealNI['totalAll']['NI_'+iStr+'_show'] = null;
        }
        }

        var team = component.get('v.team')
        var rm = component.get('v.rm')

        if(team != undefined || rm != undefined) {
            var jsonTotalAll = helper.setJSONData(component,helper, 'Initiative : High - Medium', newDealNI['totalAll'], team, rm)
            
            // High
            var jsonHigh = []
            jsonHigh = jsonHigh.concat(helper.setJSONData(component,helper, 'Prop-High', newDealNI['totalHigh'], team, rm))
            jsonHigh = jsonHigh.concat(helper.setJSONData(component,helper, 'Prop-High: ' + newDealNI['HighNIIc'].Income_Type__c, newDealNI['HighNIIc'], team, rm))
            jsonHigh = jsonHigh.concat(helper.setJSONData(component,helper, 'Prop-High: ' + newDealNI['HighNIId'].Income_Type__c, newDealNI['HighNIId'], team, rm))
            jsonHigh = jsonHigh.concat(helper.setJSONData(component,helper, 'Prop-High: Fee', newDealFee['totalHigh'], team, rm))

            // Medium
            var jsonMedium = []
            jsonMedium = jsonMedium.concat(helper.setJSONData(component,helper, 'Prop-Medium', newDealNI['totalMed'], team, rm))
            jsonMedium = jsonMedium.concat(helper.setJSONData(component,helper, 'Prop-Medium: ' + newDealNI['MediumNIIc'].Income_Type__c, newDealNI['MediumNIIc'], team, rm))
            jsonMedium = jsonMedium.concat(helper.setJSONData(component,helper, 'Prop-Medium: ' + newDealNI['MediumNIId'].Income_Type__c, newDealNI['MediumNIId'], team, rm))
            jsonMedium = jsonMedium.concat(helper.setJSONData(component,helper, 'Prop-Medium: Fee', newDealFee['totalMed'], team, rm))

            // Low
            var jsonLow = []
            jsonLow = jsonLow.concat(helper.setJSONData(component,helper, 'Prop-Low', newDealNI['totalLow'], team, rm))
            jsonLow = jsonLow.concat(helper.setJSONData(component,helper, 'Prop-Low: ' + newDealNI['LowNIIc'].Income_Type__c, newDealNI['LowNIIc'], team, rm))
            jsonLow = jsonLow.concat(helper.setJSONData(component,helper, 'Prop-Low: ' + newDealNI['LowNIId'].Income_Type__c, newDealNI['LowNIId'], team, rm))
            jsonLow = jsonLow.concat(helper.setJSONData(component,helper, 'Prop-Low: Fee', newDealFee['totalLow'], team, rm))

            for (let index = 0; index < 14; index++) {
                jsonHigh = jsonHigh.concat(helper.setJSONData(component,helper, 'Prop-High: ' + newDealFee['High'][index].Income_Type__c, newDealFee['High'][index], team, rm))
                jsonMedium = jsonMedium.concat(helper.setJSONData(component,helper, 'Prop-Medium: ' + newDealFee['Medium'][index].Income_Type__c, newDealFee['Medium'][index], team, rm))
                jsonLow = jsonLow.concat(helper.setJSONData(component,helper, 'Prop-Low: ' + newDealFee['Low'][index].Income_Type__c, newDealFee['Low'][index], team, rm))
            }

            var jsonForCSV = []
            jsonForCSV = jsonForCSV.concat(jsonTotalAll)
            jsonForCSV = jsonForCSV.concat(jsonHigh)
            jsonForCSV = jsonForCSV.concat(jsonMedium)
            jsonForCSV = jsonForCSV.concat(jsonLow)

            var p = component.get("v.parent");
            p.exportCSV(helper.parseObj(jsonForCSV));
        }

        component.set('v.newDealNI', newDealNI);
        component.set('v.newDealFee', newDealFee);

    },

    genNewIncometype: function (Prob, IncomeType) {
        var newDealGrouped = {
        NI_01: 0,
        NI_02: 0,
        NI_03: 0,
        NI_04: 0,
        NI_05: 0,
        NI_06: 0,
        NI_07: 0,
        NI_08: 0,
        NI_09: 0,
        NI_10: 0,
        NI_11: 0,
        NI_12: 0,
        Total: 0,
        NI_01_show: 0,
        NI_02_show: 0,
        NI_03_show: 0,
        NI_04_show: 0,
        NI_05_show: 0,
        NI_06_show: 0,
        NI_07_show: 0,
        NI_08_show: 0,
        NI_09_show: 0,
        NI_10_show: 0,
        NI_11_show: 0,
        NI_12_show: 0,
        Total_show: 0,
        NI_01_title: 0,
        NI_02_title: 0,
        NI_03_title: 0,
        NI_04_title: 0,
        NI_05_title: 0,
        NI_06_title: 0,
        NI_07_title: 0,
        NI_08_title: 0,
        NI_09_title: 0,
        NI_10_title: 0,
        NI_11_title: 0,
        NI_12_title: 0,
        Total_title: 0,
        };
        newDealGrouped['Probability__c'] = Prob;
        newDealGrouped['Income_Type__c'] = IncomeType;
        return newDealGrouped;
    },
    setJSONData: function(component,helper, product ,data, team, rm) {
        var obj = {}
        var userProfile = component.get('v.userProfile')        
        var month = parseInt(component.get('v.Month'));
        var year = component.get('v.Year') 
        var totalColumn = 'Y' + year + '(FC)'

        obj['Team'] = team
        obj['RM'] = rm
        obj['Product'] = product
        obj['LastYear ('+ (year - 1) +')'] = ''

        obj['Jan '+(month > 0  ? '(A)': '(E)')] = (data.NI_01 == null) ? '' : helper.numberWithDecimal(data.NI_01)
        obj['Feb '+(month > 1  ? '(A)': '(E)')] = (data.NI_02 == null) ? '' : helper.numberWithDecimal(data.NI_02)
        obj['Mar '+(month > 2  ? '(A)': '(E)')] = (data.NI_03 == null) ? '' : helper.numberWithDecimal(data.NI_03)
        obj['Apr '+(month > 3  ? '(A)': '(E)')] = (data.NI_04 == null) ? '' : helper.numberWithDecimal(data.NI_04)
        obj['May '+(month > 4  ? '(A)': '(E)')] = (data.NI_05 == null) ? '' : helper.numberWithDecimal(data.NI_05)
        obj['Jun '+(month > 5  ? '(A)': '(E)')] = (data.NI_06 == null) ? '' : helper.numberWithDecimal(data.NI_06)
        obj['Jul '+(month > 6  ? '(A)': '(E)')] = (data.NI_07 == null) ? '' : helper.numberWithDecimal(data.NI_07)
        obj['Aug '+(month > 7  ? '(A)': '(E)')] = (data.NI_08 == null) ? '' : helper.numberWithDecimal(data.NI_08)
        obj['Sep '+(month > 8  ? '(A)': '(E)')] = (data.NI_09 == null) ? '' : helper.numberWithDecimal(data.NI_09)
        obj['Oct '+(month > 9  ? '(A)': '(E)')] = (data.NI_10 == null) ? '' : helper.numberWithDecimal(data.NI_10)
        obj['Nov '+(month > 10 ? '(A)': '(E)')] = (data.NI_11 == null) ? '' : helper.numberWithDecimal(data.NI_11)
        obj['Dec '+(month > 11 ? '(A)': '(E)')] = (data.NI_12 == null) ? '' : helper.numberWithDecimal(data.NI_12)

        obj[totalColumn] = (data.Total == null) ? '' : helper.numberWithDecimal(data.Total)
        obj['Achieved (%)'] =  ''
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