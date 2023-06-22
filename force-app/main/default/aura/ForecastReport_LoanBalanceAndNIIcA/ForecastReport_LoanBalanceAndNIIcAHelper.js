({
    setHeader: function (component, helper) {
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();

        var reportYear = parseInt(component.get('v.reportParam.selectedYear'));

        var hearderStart = [
            {
                fieldName: 'team',
                label: 'Team',
                slot: 1
            },
            {
                fieldName: 'rm',
                label: 'RM',
                slot: 1
            },
            {
                fieldName: 'product',
                label: 'Product',
                slot: 1
            },
            {
                fieldName: 'lastYear',
                label: 'Last Year',
                label2: '(' +  (reportYear - 1) +')',
                slot: 1
            }];
        var hearderMonth = [
            {
                fieldName: 'jan',
                label: 'Jan',
                slot: 2
            },
            {
                fieldName: 'feb',
                label: 'Feb',
                slot: 2
            },
            {
                fieldName: 'mar',
                label: 'Mar',
                slot: 2
            },
            {
                fieldName: 'apr',
                label: 'Apr',
                slot: 2
            },
            {
                fieldName: 'may',
                label: 'May',
                slot: 2
            },
            {
                fieldName: 'jun',
                label: 'Jun',
                slot: 2
            },
            {
                fieldName: 'jul',
                label: 'Jul',
                slot: 2
            },
            {
                fieldName: 'aug',
                label: 'Aug',
                slot: 2
            },
            {
                fieldName: 'sep',
                label: 'Sep',
                slot: 2
            },
            {
                fieldName: 'oct',
                label: 'Oct',
                slot: 2
            },
            {
                fieldName: 'nov',
                label: 'Nov',
                slot: 2
            },
            {
                fieldName: 'dec',
                label: 'Dec',
                slot: 2
            }];
        var hearderEnd = [
            {
                fieldName: 'year',
                label: 'Y',
                label2: '(FC)',
                slot: 3
            },
            {
                fieldName: 'YTD',
                label: 'YTD',
                label2: '',
                slot: 3
            },
            {
                fieldName: 'YoY',
                label: '%YoY',
                slot: 3
            },
        ];

        hearderMonth.forEach((element, index) => {
            if(reportYear == year) {
                if (index < month) {
                    element['label'] = element['label'].concat(' (A)');
                } else {
                    element['label'] = element['label'].concat(' (E)');
                }
            } else if(reportYear > year) {
                element['label'] = element['label'].concat(' (E)');
            } else {
                element['label'] = element['label'].concat(' (A)');
            }
        });

        hearderEnd.forEach(element => {
            if(element['fieldName'] == 'year') {
                element['label'] = element['label'].concat(reportYear);
            }
            if (element['fieldName'] == 'YTD') {
                if(reportYear != year) {
                    month = 0;
                }
                var monthName = month == 0 ? '' : helper.getMonthName(month - 1, 'full');
                element['label2'] = monthName == '' ? '' : '(as of ' + element['label2'].concat(monthName) + ')';
            } 

        });

        var columns2a = [];
        columns2a = columns2a.concat(hearderStart);
        columns2a = columns2a.concat(hearderMonth);
        columns2a = columns2a.concat(hearderEnd);

        // target
        var today = new Date();
        var year = today.getFullYear();

        if(reportYear == year) {
            month = today.getMonth();
        } else {
            month = 0;
        }

        var hearderTop = [
            {
                fieldName: 'origin',
                label: 'Original Target (' + reportYear + ')',
                slot: 3
            },
        ];

        var hearderBottom = [
            {
                fieldName: 'originVariance',
                label: 'Variance',
                slot: 3
            },
            {
                fieldName: 'originAchieve',
                label: '% Achieve (YTD)',
                slot: 3
            },
            {
                fieldName: 'originFYTarget',
                label: 'FY Target',
                slot: 3
            },
        ];


        if (month >= 3) {
            var headFirstTop = [{
                fieldName: '39F',
                label: '3+9F Target (' + reportYear + ')',
                slot: 3
            }]

            var headFirstBottom = [
                 {
                    fieldName: '39FVariance',
                    label: 'Variance',
                    slot: 3
                },
                {
                    fieldName: '39FAchieve',
                    label: '% Achieve (YTD)',
                    slot: 3
                },
                {
                    fieldName: '39FFYTarget',
                    label: 'FY Target',
                    slot: 3
                },
            ]

            hearderTop = hearderTop.concat(headFirstTop)
            hearderBottom = hearderBottom.concat(headFirstBottom)
        }

        if (month >= 6) {
            var headSecondTop = [{
                fieldName: '66F',
                label: '6+6F Target (' + reportYear + ')',
                slot: 3
            }]

            var headSecondBottom = [
                 {
                    fieldName: '39FVariance',
                    label: 'Variance',
                    slot: 3
                },
                {
                    fieldName: '39FAchieve',
                    label: '% Achieve (YTD)',
                    slot: 3
                },
                {
                    fieldName: '39FFYTarget',
                    label: 'FY Target',
                    slot: 3
                },
            ]

            hearderTop = hearderTop.concat(headSecondTop)
            hearderBottom = hearderBottom.concat(headSecondBottom)
        }
        if (month >= 9) {
            var headThirdTop = [{
                fieldName: '93F',
                label: '9+3F Target (' + reportYear + ')',
                slot: 3
            }]

            var headThirdBottom = [
                 {
                    fieldName: '93FVariance',
                    label: 'Variance',
                    slot: 3
                },
                {
                    fieldName: '93FAchieve',
                    label: '% Achieve (YTD)',
                    slot: 3
                },
                {
                    fieldName: '93FFYTarget',
                    label: 'FY Target',
                    slot: 3
                },
            ]

            hearderTop = hearderTop.concat(headThirdTop)
            hearderBottom = hearderBottom.concat(headThirdBottom)
        }

        component.set('v.gridColumnsMockTable', columns2a);
        component.set('v.targetColumnsTop', hearderTop);
        component.set('v.targetColumnsBottom', hearderBottom);
    },
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    groupData: function (component, helper, result, lastyear) {
        var grouped = {};
        var groupRm = {};
        var groupRmLastYear ={};
        var groupByRegion ={};
        var target = component.get('v.target')
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        var reportYear = parseInt(component.get('v.reportParam.selectedYear'));
        if(reportYear == year) {
            month = today.getMonth();
          } else {
              month = 0;
          }
        

        result.forEach((data) => {
            var keyRm = data.Customer__r.Owner.Name
            groupRm[keyRm] = groupRm[keyRm] ? groupRm[keyRm] : [];
            groupRm[keyRm].push(data);
        });

        lastyear.forEach((dataLastYear) => {
            var keyRm = dataLastYear.Customer__r.Owner.Name
            groupRmLastYear[keyRm] = groupRmLastYear[keyRm] ? groupRmLastYear[keyRm] : [];
            groupRmLastYear[keyRm].push(dataLastYear);
        });

        groupRm = Object.keys(groupRm).sort().reduce((a, c) => (a[c] = groupRm[c], a), {})
        groupRmLastYear = Object.keys(groupRmLastYear).sort().reduce((a, c) => (a[c] = groupRmLastYear[c], a), {})

        if(Object.keys(groupRm).length < Object.keys(groupRmLastYear).length) {
            grouped = groupRmLastYear
        } else {
            grouped = groupRm
        }
        groupRm = Object.keys(groupRm).sort().reduce((a, c) => (a[c] = groupRm[c], a), {})
        var gruopTeam = {}
        for (var key of Object.keys(grouped)) {
            var endingBal = helper.setDefaultData(component, helper, 'Ending_Balance')
            var avgBal = helper.setDefaultData(component, helper, 'Average_Balance')
            var niBal = helper.setDefaultData(component, helper, 'NI')
            var InterestBal = helper.setDefaultData(component, helper, 'Interest_Income')
            var ftpBal = helper.setDefaultData(component, helper, 'FTP')
            if (key in groupRm) {
                groupRm[key].forEach((rm) => {
                    endingBal[0].team = rm.Customer__r.Owner.Zone__c
                    endingBal[0].rm = rm.Customer__r.Owner.Name
                    endingBal[0].rmId = rm.Customer__r.OwnerId
                    endingBal[0].region = rm.Customer__r.Owner.Region__c
                    endingBal = helper.setValueData(component, helper, rm, endingBal, 'Ending_Balance');
                    avgBal = helper.setValueData(component, helper, rm, avgBal, 'Average_Balance');
                    niBal = helper.setValueData(component, helper, rm, niBal, 'NI')
                    InterestBal = helper.setValueData(component, helper, rm, InterestBal, 'Interest_Income')
                    ftpBal = helper.setValueData(component, helper, rm, ftpBal, 'FTP')
    
                    target.forEach(element => {
                        if(endingBal[0].rm == element.Owner.Name) {
                            niBal[0].originFYTarget = (element.TargetNIIcAmount__c == null || element.TargetNIIcAmount__c == undefined) ? '' : element.TargetNIIcAmount__c
                            if (month >= 3) niBal[0].firstTargetFYTarget = (element.TargetNIIcAmount_3_9__c == null || element.TargetNIIcAmount_3_9__c == undefined) ? '' : element.TargetNIIcAmount_3_9__c 
                            if (month >= 6) niBal[0].secondTargetFYTarget = (element.TargetNIIcAmount_6_6__c == null || element.TargetNIIcAmount_6_6__c == undefined) ? '' : element.TargetNIIcAmount_6_6__c 
                            if (month >= 9) niBal[0].thirdTargetFYTarget = (element.TargetNIIcAmount_9_3__c == null || element.TargetNIIcAmount_9_3__c == undefined) ? '' : element.TargetNIIcAmount_9_3__c 
                        }
                    });
    
                })
            }
            if (key in groupRmLastYear) {
                groupRmLastYear[key].forEach((rmLastyear) => {
                    endingBal[0].team = rmLastyear.Customer__r.Owner.Zone__c
                    endingBal[0].rm = rmLastyear.Customer__r.Owner.Name
                    endingBal[0].rmId = rmLastyear.Customer__r.OwnerId
                    endingBal[0].region = rmLastyear.Customer__r.Owner.Region__c
                    endingBal = helper.setValueLastYearData(component, helper, rmLastyear, endingBal, 'Ending_Balance');
                    avgBal = helper.setValueLastYearData(component, helper, rmLastyear, avgBal, 'Average_Balance');
                    niBal = helper.setValueLastYearData(component, helper, rmLastyear, niBal, 'NI')
                    InterestBal = helper.setValueLastYearData(component, helper, rmLastyear, InterestBal, 'Interest_Income')
                    ftpBal = helper.setValueLastYearData(component, helper, rmLastyear, ftpBal, 'FTP')    
                })
            }
            var valueBal = endingBal.concat(avgBal);
            valueBal = valueBal.concat(niBal);
            valueBal = valueBal.concat(InterestBal);
            valueBal = valueBal.concat(ftpBal);
            groupRm[key] = valueBal


            var keyTeam = groupRm[key][0].team
            gruopTeam[keyTeam] = gruopTeam[keyTeam] ? gruopTeam[keyTeam] : {};
            gruopTeam[keyTeam]['rm'] = gruopTeam[keyTeam]['rm'] ? gruopTeam[keyTeam]['rm'] : [];
            gruopTeam[keyTeam]['rm'].push(groupRm[key]);
        }
        gruopTeam = Object.keys(gruopTeam).sort().reduce((a, c) => (a[c] = gruopTeam[c], a), {}) 
        var groupRegion = {}
        for (var key of Object.keys(gruopTeam)) {
            var endingBal = helper.setDefaultData(component, helper, 'Ending_Balance')
            var avgBal = helper.setDefaultData(component, helper, 'Average_Balance')
            var niBal = helper.setDefaultData(component, helper, 'NI')
            var InterestBal = helper.setDefaultData(component, helper, 'Interest_Income')
            var ftpBal = helper.setDefaultData(component, helper, 'FTP')
            endingBal[0].team = key
            endingBal[0].rm = 'Team Total'
            
            target.forEach(element => {
                if(endingBal[0].team == element.Zone__c) {
                    if(!(element.TargetNIIcAmount__c == null || element.TargetNIIcAmount__c == undefined)) {
                        niBal[0].originFYTarget = (niBal[0].originFYTarget === '' ? 0 : niBal[0].originFYTarget) + element.TargetNIIcAmount__c
                    }
                    if (!(element.TargetNIIcAmount_3_9__c == null || element.TargetNIIcAmount_3_9__c == undefined)) {
                        if (month >= 3) niBal[0].firstTargetFYTarget = (niBal[0].firstTargetFYTarget === '' ? 0 : niBal[0].firstTargetFYTarget) + element.TargetNIIcAmount_3_9__c
                    }
                    if(!(element.TargetNIIcAmount_6_6__c == null || element.TargetNIIcAmount_6_6__c == undefined)) {
                        if (month >= 6) niBal[0].secondTargetFYTarget = (niBal[0].secondTargetFYTarget === '' ? 0 : niBal[0].secondTargetFYTarget) + element.TargetNIIcAmount_6_6__c
                    }
                    if(!(element.TargetNIIcAmount_9_3__c == null || element.TargetNIIcAmount_9_3__c == undefined)) {
                        if (month >= 9) niBal[0].thirdTargetFYTarget = (niBal[0].thirdTargetFYTarget === '' ? 0 : niBal[0].thirdTargetFYTarget) + element.TargetNIIcAmount_9_3__c 
                    }
                }
            });

            var teamTotalRow = endingBal.concat(avgBal);
            teamTotalRow = teamTotalRow.concat(niBal);
            teamTotalRow = teamTotalRow.concat(InterestBal);
            teamTotalRow = teamTotalRow.concat(ftpBal);
            
            var keyRegion = ''
            gruopTeam[key]['rm'].forEach((rm) => {
                teamTotalRow[0].region = rm[0].region
                teamTotalRow[0] = helper.totalValue(teamTotalRow[0], rm[0])
                teamTotalRow[1] = helper.totalValue(teamTotalRow[1], rm[1])
                teamTotalRow[2] = helper.totalValue(teamTotalRow[2], rm[2])
                
                // Avg Bal.
                teamTotalRow[3] = helper.totalValue(teamTotalRow[3], rm[3])
                teamTotalRow[4] = helper.totalValue(teamTotalRow[4], rm[4])
                teamTotalRow[5] = helper.totalValue(teamTotalRow[5], rm[5])
    
                // NI
                teamTotalRow[6] = helper.totalValue(teamTotalRow[6], rm[6])
                teamTotalRow[7] = helper.totalValue(teamTotalRow[7], rm[7])
                teamTotalRow[8] = helper.totalValue(teamTotalRow[8], rm[8])
                teamTotalRow[9] = helper.totalValue(teamTotalRow[9], rm[9])
                teamTotalRow[10] = helper.totalValue(teamTotalRow[10], rm[10])

                // Interest Income 21 - 23 
                teamTotalRow[11] = helper.totalValue(teamTotalRow[11], rm[11])
                teamTotalRow[12] = helper.totalValue(teamTotalRow[12], rm[12])
                teamTotalRow[13] = helper.totalValue(teamTotalRow[13], rm[13])
                                
                // FTP 24 - 26
                teamTotalRow[14] = helper.totalValue(teamTotalRow[14], rm[14])
                teamTotalRow[15] = helper.totalValue(teamTotalRow[15], rm[15])
                teamTotalRow[16] = helper.totalValue(teamTotalRow[16], rm[16])
                
                // teamTotalRow[6].originFYTarget += rm[6].originFYTarget
                // if (month >= 3) teamTotalRow[6].firstTarget += rm[6].firstTarget 
                // if (month >= 3) teamTotalRow[6].secondTarget += rm[6].secondTarget 
                // if (month >= 3) teamTotalRow[6].thirdTarget += rm[6].thirdTarget

                // keyRegion = rm[0].region
                // groupRegion[keyRegion] = groupRegion[keyRegion] ? groupRegion[keyRegion] : {};
                // groupRegion[keyRegion]['rm'] = groupRegion[keyRegion]['rm'] ? groupRegion[keyRegion]['rm'] : [];
                // groupRegion[keyRegion]['rm'].push(rm);
            })
            gruopTeam[key]['team'] = teamTotalRow
            
            keyRegion = gruopTeam[key]['team'][0].region
            groupRegion[keyRegion] = groupRegion[keyRegion] ? groupRegion[keyRegion] : {};
            groupRegion[keyRegion]['team'] = groupRegion[keyRegion]['team'] ? groupRegion[keyRegion]['team'] : [];
            groupRegion[keyRegion]['team'].push(gruopTeam[key]);
            
        }

        groupRegion = Object.keys(groupRegion).sort().reduce((a, c) => (a[c] = groupRegion[c], a), {})
        var allGrouped = []
        for (var key of Object.keys(groupRegion)) {
            var groped = {}
            
            var endingBal = helper.setDefaultData(component, helper, 'Ending_Balance')
            var avgBal = helper.setDefaultData(component, helper, 'Average_Balance')
            var niBal = helper.setDefaultData(component, helper, 'NI')
            var InterestBal = helper.setDefaultData(component, helper, 'Interest_Income')
            var ftpBal = helper.setDefaultData(component, helper, 'FTP')
            // endingBal[0].team = groupRegion[keyRegion]['team'][0]['team'].team
            endingBal[0].rm = 'Region Total'
            
            var regionTotalRow = endingBal.concat(avgBal);
            regionTotalRow = regionTotalRow.concat(niBal);
            regionTotalRow = regionTotalRow.concat(InterestBal);
            regionTotalRow = regionTotalRow.concat(ftpBal);
            
            groupRegion[key]['team'].forEach((team) => {
                team = team['team']
                regionTotalRow[0].team = team[0].region
                regionTotalRow[0] = helper.totalValue(regionTotalRow[0], team[0])
                regionTotalRow[1] = helper.totalValue(regionTotalRow[1], team[1])
                regionTotalRow[2] = helper.totalValue(regionTotalRow[2], team[2])
                
                // Avg Bal.
                regionTotalRow[3] = helper.totalValue(regionTotalRow[3], team[3])
                regionTotalRow[4] = helper.totalValue(regionTotalRow[4], team[4])
                regionTotalRow[5] = helper.totalValue(regionTotalRow[5], team[5])
    
                // NI
                regionTotalRow[6] = helper.totalValue(regionTotalRow[6], team[6])
                regionTotalRow[7] = helper.totalValue(regionTotalRow[7], team[7])
                regionTotalRow[8] = helper.totalValue(regionTotalRow[8], team[8])
                regionTotalRow[9] = helper.totalValue(regionTotalRow[9], team[9])
                regionTotalRow[10] = helper.totalValue(regionTotalRow[10], team[10])

                // Interest Income
                regionTotalRow[11] = helper.totalValue(regionTotalRow[11], team[11])
                regionTotalRow[12] = helper.totalValue(regionTotalRow[12], team[12])
                regionTotalRow[13] = helper.totalValue(regionTotalRow[13], team[13])
                                
                // FTP
                regionTotalRow[14] = helper.totalValue(regionTotalRow[14], team[14])
                regionTotalRow[15] = helper.totalValue(regionTotalRow[15], team[15])
                regionTotalRow[16] = helper.totalValue(regionTotalRow[16], team[16])  

                if(team[6].originFYTarget !== '') {
                	regionTotalRow[6].originFYTarget = (regionTotalRow[6].originFYTarget === '' ? 0 : regionTotalRow[6].originFYTarget) + team[6].originFYTarget
            	}
                if (month >= 3) {
                    if(team[6].firstTargetFYTarget !== '') {
                        regionTotalRow[6].firstTargetFYTarget = (regionTotalRow[6].firstTargetFYTarget === '' ? 0 : regionTotalRow[6].firstTargetFYTarget) + team[6].firstTargetFYTarget
                    }               	
            	}
                if (month >= 6) {
                        if(team[6].secondTargetFYTarget !== '') {
                        regionTotalRow[6].secondTargetFYTarget = (regionTotalRow[6].secondTargetFYTarget === '' ? 0 : regionTotalRow[6].secondTargetFYTarget) + team[6].secondTargetFYTarget
                    }               	
            	}
            	if (month >= 9) {
                    if(team[6].thirdTargetFYTarget !== '') {
                        regionTotalRow[6].thirdTargetFYTarget = (regionTotalRow[6].thirdTargetFYTarget === '' ? 0 : regionTotalRow[6].thirdTargetFYTarget) + team[6].thirdTargetFYTarget
                    }               	
            	}

            })
            // groupRegion[key]['region'] = regionTotalRow
            // groped.rm = groupRegion[key]['rm']
            groped.team = groupRegion[key]['team']
            groped.region = regionTotalRow
            
            allGrouped.push(groped)
        }

        return allGrouped;
    },
    getMonthName: function (month, type) {
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
            'December']
        
        var monthShortNames = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        ]


		return (type == 'full') ? monthFullNames[month] : monthShortNames[month];
    },
    getRec : function(component,helper){
        var reportParam = component.get('v.reportParam');
        var action = component.get("c.getReportByProductGroup");
        action.setParams({
            strYear : reportParam.selectedYear,
            CustomerPort : reportParam.CustomerPort,
            productGroup: 'Credit',
            searchTeam : reportParam.searchTeam
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && component.isValid()) {
                var result = response.getReturnValue();
                component.set('v.Cube1Data',result.listCube1);
                component.set('v.target', result.listTarget)
                var groupedArray = helper.groupData(component, helper, helper.parseObj(result.listCube1), helper.parseObj(result.LastYearlistCube1));
                component.set('v.groupedData',groupedArray);
                if (groupedArray.length > 0) component.set('v.isGrouped', true);
                component.set('v.isLoading', false);
            } else {
                helper.displayToast('error', response.getError().message);
            }
        });
        $A.enqueueAction(action);
    },
    calTotalAvg: function (component, helper, avg, year, month) {
        var dayOfCurrentYear = [31, (helper.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        var dayOfLastYear = [31, (helper.isLeapYear(year - 1) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        var totalCurrentYear = 0;
        var totalLastYear = 0;
        var totalActualCurrentYear = 0;
        var totalActualLastYear = 0;
        
        var ltCurrentYear = 0;
        var ltLastYear = 0;
        var ltActualCurrentYear = 0;
        var ltActualLastYear = 0;
        
        var stCurrentYear = 0;
        var stLastYear = 0;
        var stActualCurrentYear = 0;
        var stActualLastYear = 0;
    
        var actualTotalDayCurrentYear = 0;
        var totalDayCurrentYear = 0;
        var actualTotalDayLastYear  = 0;
        var totalDayLastYear  = 0;
    
        for(var i = 0; i < 12; i++) {
              var keyCurrent = (helper.getMonthName(i, 'short')).toLowerCase();
              var keyLastYear = keyCurrent + 'LastYear';
    
              totalCurrentYear += avg[3][keyCurrent] * dayOfCurrentYear[i];
              totalLastYear += avg[3][keyLastYear] * dayOfLastYear[i];
              
              ltCurrentYear += avg[4][keyCurrent] * dayOfCurrentYear[i];
              ltLastYear += avg[4][keyLastYear] * dayOfLastYear[i];
              
              stCurrentYear += avg[5][keyCurrent] * dayOfCurrentYear[i];
              stLastYear += avg[5][keyLastYear] * dayOfLastYear[i];
    
              totalDayCurrentYear += dayOfCurrentYear[i];
              totalDayLastYear += dayOfLastYear[i];

              if(i == month - 1) {
                totalActualCurrentYear = totalCurrentYear;
                totalActualLastYear = totalLastYear;
    
                ltActualCurrentYear = ltCurrentYear;
                ltActualLastYear = ltLastYear;
    
                stActualCurrentYear = stCurrentYear;
                stActualLastYear = stLastYear;
    
                actualTotalDayCurrentYear = totalDayCurrentYear;
                actualTotalDayLastYear = totalDayLastYear;
              }
          }
    
          avg[3].lastYear = (totalLastYear == 0 || totalDayLastYear == 0) ? 0 : totalLastYear / totalDayLastYear;
          avg[3].total = (totalCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : totalCurrentYear / totalDayCurrentYear;
          avg[3].ytd = (totalActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : totalActualCurrentYear / actualTotalDayCurrentYear;
          avg[3].lastYearActual = (totalActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : totalActualLastYear / actualTotalDayLastYear;
          avg[3].yoy = (avg[3].ytd == 0 || avg[3].lastYearActual == 0) ? '' : ((avg[3].ytd / avg[3].lastYearActual) * 100);
    
          avg[4].lastYear = (ltLastYear == 0 || totalDayLastYear == 0) ? 0 : ltLastYear / totalDayLastYear;
          avg[4].total = (ltCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : ltCurrentYear / totalDayCurrentYear;
          avg[4].ytd = (ltActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : ltActualCurrentYear / actualTotalDayCurrentYear;
          avg[4].lastYearActual = (ltActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : ltActualLastYear / actualTotalDayLastYear;
          avg[4].yoy = (avg[4].ytd == 0 || avg[1].lastYearActual == 0) ? '' : ((avg[4].ytd / avg[4].lastYearActual) * 100);
    
          avg[5].lastYear = (stLastYear == 0 || totalDayLastYear == 0) ? 0 : stLastYear / totalDayLastYear;
          avg[5].total = (stCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : stCurrentYear / totalDayCurrentYear;
          avg[5].ytd = (stActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : stActualCurrentYear / actualTotalDayCurrentYear;
          avg[5].lastYearActual = (stActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : stActualLastYear / actualTotalDayLastYear;
          avg[5].yoy = (avg[5].ytd == 0 || avg[5].lastYearActual == 0) ? '' : ((avg[5].ytd / avg[5].lastYearActual) * 100);
    
          return avg;
      },
      changeToMillionUnit: function (teamTotalRow) {
        teamTotalRow.forEach(element => {
            if(element != null && element.product == 'Ending Balance') {
                teamTotalRow[0].lastYearMillionUnit = (teamTotalRow[0].lastYear / 10 ** 6).toFixed(2)
                teamTotalRow[0].janMillionUnit = (teamTotalRow[0].jan / 10 ** 6).toFixed(2)
                teamTotalRow[0].febMillionUnit = (teamTotalRow[0].feb / 10 ** 6).toFixed(2)
                teamTotalRow[0].marMillionUnit = (teamTotalRow[0].mar / 10 ** 6).toFixed(2)
                teamTotalRow[0].aprMillionUnit = (teamTotalRow[0].apr / 10 ** 6).toFixed(2)
                teamTotalRow[0].mayMillionUnit = (teamTotalRow[0].may / 10 ** 6).toFixed(2)
                teamTotalRow[0].junMillionUnit = (teamTotalRow[0].jun / 10 ** 6).toFixed(2)
                teamTotalRow[0].julMillionUnit = (teamTotalRow[0].jul / 10 ** 6).toFixed(2)
                teamTotalRow[0].augMillionUnit = (teamTotalRow[0].aug / 10 ** 6).toFixed(2)
                teamTotalRow[0].sepMillionUnit = (teamTotalRow[0].sep / 10 ** 6).toFixed(2)
                teamTotalRow[0].octMillionUnit = (teamTotalRow[0].oct / 10 ** 6).toFixed(2)
                teamTotalRow[0].novMillionUnit = (teamTotalRow[0].nov / 10 ** 6).toFixed(2)
                teamTotalRow[0].decMillionUnit = (teamTotalRow[0].dec / 10 ** 6).toFixed(2)
                teamTotalRow[0].totalMillionUnit = (teamTotalRow[0].total / 10 ** 6).toFixed(2)
                teamTotalRow[0].ytdMillionUnit = teamTotalRow[0].ytd == 0 ? '' : (teamTotalRow[0].ytd / 10 ** 6).toFixed(2)
                teamTotalRow[0].yoy = (teamTotalRow[0].ytd == 0 || teamTotalRow[0].lastYearActual == 0) ? '' : ((teamTotalRow[0].ytd / teamTotalRow[0].lastYearActual) * 100)
                teamTotalRow[0].yoyMillionUnit = (teamTotalRow[0].ytd == 0 || teamTotalRow[0].lastYearActual == 0) ? '' : ((teamTotalRow[0].ytd / teamTotalRow[0].lastYearActual) * 100).toFixed(2) + '%';
            }
            
            if (element != null && element.product == 'LT Loan') {
                teamTotalRow[1].lastYearMillionUnit = (teamTotalRow[1].lastYear / 10 ** 6).toFixed(2)
                teamTotalRow[1].janMillionUnit = (teamTotalRow[1].jan / 10 ** 6).toFixed(2)
                teamTotalRow[1].febMillionUnit = (teamTotalRow[1].feb / 10 ** 6).toFixed(2)
                teamTotalRow[1].marMillionUnit = (teamTotalRow[1].mar / 10 ** 6).toFixed(2)
                teamTotalRow[1].aprMillionUnit = (teamTotalRow[1].apr / 10 ** 6).toFixed(2)
                teamTotalRow[1].mayMillionUnit = (teamTotalRow[1].may / 10 ** 6).toFixed(2)
                teamTotalRow[1].junMillionUnit = (teamTotalRow[1].jun / 10 ** 6).toFixed(2)
                teamTotalRow[1].julMillionUnit = (teamTotalRow[1].jul / 10 ** 6).toFixed(2)
                teamTotalRow[1].augMillionUnit = (teamTotalRow[1].aug / 10 ** 6).toFixed(2)
                teamTotalRow[1].sepMillionUnit = (teamTotalRow[1].sep / 10 ** 6).toFixed(2)
                teamTotalRow[1].octMillionUnit = (teamTotalRow[1].oct / 10 ** 6).toFixed(2)
                teamTotalRow[1].novMillionUnit = (teamTotalRow[1].nov / 10 ** 6).toFixed(2)
                teamTotalRow[1].decMillionUnit = (teamTotalRow[1].dec / 10 ** 6).toFixed(2)
                teamTotalRow[1].totalMillionUnit = (teamTotalRow[1].total / 10 ** 6).toFixed(2)
                teamTotalRow[1].ytdMillionUnit = teamTotalRow[1].ytd == 0 ? '' : (teamTotalRow[1].ytd / 10 ** 6).toFixed(2)
                teamTotalRow[1].yoy = (teamTotalRow[1].ytd == 0 || teamTotalRow[1].lastYearActual == 0) ? '' : ((teamTotalRow[1].ytd / teamTotalRow[1].lastYearActual) * 100)
                teamTotalRow[1].yoyMillionUnit = (teamTotalRow[1].ytd == 0 || teamTotalRow[1].lastYearActual == 0) ? '' : ((teamTotalRow[1].ytd / teamTotalRow[1].lastYearActual) * 100).toFixed(2) + '%';
            }
            
            if (element != null && element.product == 'ST Loan') {
              teamTotalRow[2].lastYearMillionUnit = (teamTotalRow[2].lastYear / 10 ** 6).toFixed(2)
              teamTotalRow[2].janMillionUnit = (teamTotalRow[2].jan / 10 ** 6).toFixed(2)
              teamTotalRow[2].febMillionUnit = (teamTotalRow[2].feb / 10 ** 6).toFixed(2)
              teamTotalRow[2].marMillionUnit = (teamTotalRow[2].mar / 10 ** 6).toFixed(2)
              teamTotalRow[2].aprMillionUnit = (teamTotalRow[2].apr / 10 ** 6).toFixed(2)
              teamTotalRow[2].mayMillionUnit = (teamTotalRow[2].may / 10 ** 6).toFixed(2)
              teamTotalRow[2].junMillionUnit = (teamTotalRow[2].jun / 10 ** 6).toFixed(2)
              teamTotalRow[2].julMillionUnit = (teamTotalRow[2].jul / 10 ** 6).toFixed(2)
              teamTotalRow[2].augMillionUnit = (teamTotalRow[2].aug / 10 ** 6).toFixed(2)
              teamTotalRow[2].sepMillionUnit = (teamTotalRow[2].sep / 10 ** 6).toFixed(2)
              teamTotalRow[2].octMillionUnit = (teamTotalRow[2].oct / 10 ** 6).toFixed(2)
              teamTotalRow[2].novMillionUnit = (teamTotalRow[2].nov / 10 ** 6).toFixed(2)
              teamTotalRow[2].decMillionUnit = (teamTotalRow[2].dec / 10 ** 6).toFixed(2)
              teamTotalRow[2].totalMillionUnit = (teamTotalRow[2].total / 10 ** 6).toFixed(2)
              teamTotalRow[2].ytdMillionUnit = teamTotalRow[2].ytd == 0 ? '' : (teamTotalRow[2].ytd / 10 ** 6).toFixed(2)
              teamTotalRow[2].yoy = (teamTotalRow[2].ytd == 0 || teamTotalRow[2].lastYearActual == 0) ? '' : ((teamTotalRow[2].ytd / teamTotalRow[2].lastYearActual) * 100)
              teamTotalRow[2].yoyMillionUnit = (teamTotalRow[2].ytd == 0 || teamTotalRow[2].lastYearActual == 0) ? '' : ((teamTotalRow[2].ytd / teamTotalRow[2].lastYearActual) * 100).toFixed(2) + '%';
            }

            if(element != null && element.product == 'Avg Balance') {
                teamTotalRow[3].lastYearMillionUnit = (teamTotalRow[3].lastYear / 10 ** 6).toFixed(2)
                teamTotalRow[3].janMillionUnit = (teamTotalRow[3].jan / 10 ** 6).toFixed(2)
                teamTotalRow[3].febMillionUnit = (teamTotalRow[3].feb / 10 ** 6).toFixed(2)
                teamTotalRow[3].marMillionUnit = (teamTotalRow[3].mar / 10 ** 6).toFixed(2)
                teamTotalRow[3].aprMillionUnit = (teamTotalRow[3].apr / 10 ** 6).toFixed(2)
                teamTotalRow[3].mayMillionUnit = (teamTotalRow[3].may / 10 ** 6).toFixed(2)
                teamTotalRow[3].junMillionUnit = (teamTotalRow[3].jun / 10 ** 6).toFixed(2)
                teamTotalRow[3].julMillionUnit = (teamTotalRow[3].jul / 10 ** 6).toFixed(2)
                teamTotalRow[3].augMillionUnit = (teamTotalRow[3].aug / 10 ** 6).toFixed(2)
                teamTotalRow[3].sepMillionUnit = (teamTotalRow[3].sep / 10 ** 6).toFixed(2)
                teamTotalRow[3].octMillionUnit = (teamTotalRow[3].oct / 10 ** 6).toFixed(2)
                teamTotalRow[3].novMillionUnit = (teamTotalRow[3].nov / 10 ** 6).toFixed(2)
                teamTotalRow[3].decMillionUnit = (teamTotalRow[3].dec / 10 ** 6).toFixed(2)
                teamTotalRow[3].totalMillionUnit = (teamTotalRow[3].total / 10 ** 6).toFixed(2)
                teamTotalRow[3].ytdMillionUnit = teamTotalRow[3].ytd == 0 ? '' : (teamTotalRow[3].ytd / 10 ** 6).toFixed(2)
                teamTotalRow[3].yoy = (teamTotalRow[3].ytd == 0 || teamTotalRow[3].lastYearActual == 0) ? '' : ((teamTotalRow[3].ytd / teamTotalRow[3].lastYearActual) * 100)
                teamTotalRow[3].yoyMillionUnit = (teamTotalRow[3].ytd == 0 || teamTotalRow[3].lastYearActual == 0) ? '' : ((teamTotalRow[3].ytd / teamTotalRow[3].lastYearActual) * 100).toFixed(2) + '%';
            }
            
            if (element != null && element.product == 'LT Loan') {
                teamTotalRow[4].lastYearMillionUnit = (teamTotalRow[4].lastYear / 10 ** 6).toFixed(2)
                teamTotalRow[4].janMillionUnit = (teamTotalRow[4].jan / 10 ** 6).toFixed(2)
                teamTotalRow[4].febMillionUnit = (teamTotalRow[4].feb / 10 ** 6).toFixed(2)
                teamTotalRow[4].marMillionUnit = (teamTotalRow[4].mar / 10 ** 6).toFixed(2)
                teamTotalRow[4].aprMillionUnit = (teamTotalRow[4].apr / 10 ** 6).toFixed(2)
                teamTotalRow[4].mayMillionUnit = (teamTotalRow[4].may / 10 ** 6).toFixed(2)
                teamTotalRow[4].junMillionUnit = (teamTotalRow[4].jun / 10 ** 6).toFixed(2)
                teamTotalRow[4].julMillionUnit = (teamTotalRow[4].jul / 10 ** 6).toFixed(2)
                teamTotalRow[4].augMillionUnit = (teamTotalRow[4].aug / 10 ** 6).toFixed(2)
                teamTotalRow[4].sepMillionUnit = (teamTotalRow[4].sep / 10 ** 6).toFixed(2)
                teamTotalRow[4].octMillionUnit = (teamTotalRow[4].oct / 10 ** 6).toFixed(2)
                teamTotalRow[4].novMillionUnit = (teamTotalRow[4].nov / 10 ** 6).toFixed(2)
                teamTotalRow[4].decMillionUnit = (teamTotalRow[4].dec / 10 ** 6).toFixed(2)
                teamTotalRow[4].totalMillionUnit = (teamTotalRow[4].total / 10 ** 6).toFixed(2)
                teamTotalRow[4].ytdMillionUnit = teamTotalRow[4].ytd == 0 ? '' : (teamTotalRow[4].ytd / 10 ** 6).toFixed(2)
                teamTotalRow[4].yoy = (teamTotalRow[4].ytd == 0 || teamTotalRow[4].lastYearActual == 0) ? '' : ((teamTotalRow[4].ytd / teamTotalRow[4].lastYearActual) * 100)
                teamTotalRow[4].yoyMillionUnit = (teamTotalRow[4].ytd == 0 || teamTotalRow[4].lastYearActual == 0) ? '' : ((teamTotalRow[4].ytd / teamTotalRow[4].lastYearActual) * 100).toFixed(2) + '%';
            }
            
            if (element != null && element.product == 'ST Loan') {
              teamTotalRow[5].lastYearMillionUnit = (teamTotalRow[5].lastYear / 10 ** 6).toFixed(2)
              teamTotalRow[5].janMillionUnit = (teamTotalRow[5].jan / 10 ** 6).toFixed(2)
              teamTotalRow[5].febMillionUnit = (teamTotalRow[5].feb / 10 ** 6).toFixed(2)
              teamTotalRow[5].marMillionUnit = (teamTotalRow[5].mar / 10 ** 6).toFixed(2)
              teamTotalRow[5].aprMillionUnit = (teamTotalRow[5].apr / 10 ** 6).toFixed(2)
              teamTotalRow[5].mayMillionUnit = (teamTotalRow[5].may / 10 ** 6).toFixed(2)
              teamTotalRow[5].junMillionUnit = (teamTotalRow[5].jun / 10 ** 6).toFixed(2)
              teamTotalRow[5].julMillionUnit = (teamTotalRow[5].jul / 10 ** 6).toFixed(2)
              teamTotalRow[5].augMillionUnit = (teamTotalRow[5].aug / 10 ** 6).toFixed(2)
              teamTotalRow[5].sepMillionUnit = (teamTotalRow[5].sep / 10 ** 6).toFixed(2)
              teamTotalRow[5].octMillionUnit = (teamTotalRow[5].oct / 10 ** 6).toFixed(2)
              teamTotalRow[5].novMillionUnit = (teamTotalRow[5].nov / 10 ** 6).toFixed(2)
              teamTotalRow[5].decMillionUnit = (teamTotalRow[5].dec / 10 ** 6).toFixed(2)
              teamTotalRow[5].totalMillionUnit = (teamTotalRow[5].total / 10 ** 6).toFixed(2)
              teamTotalRow[5].ytdMillionUnit = teamTotalRow[5].ytd == 0 ? '' : (teamTotalRow[5].ytd / 10 ** 6).toFixed(2)
              teamTotalRow[5].yoy = (teamTotalRow[5].ytd == 0 || teamTotalRow[5].lastYearActual == 0) ? '' : ((teamTotalRow[5].ytd / teamTotalRow[5].lastYearActual) * 100);
              teamTotalRow[5].yoyMillionUnit = (teamTotalRow[5].ytd == 0 || teamTotalRow[5].lastYearActual == 0) ? '' : ((teamTotalRow[5].ytd / teamTotalRow[5].lastYearActual) * 100).toFixed(2) + '%';
            }
          });
          return teamTotalRow;
      },
      isLeapYear: function (year) {
        return year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0)
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
    totalEnding: function (total, param) {
        total.lastYear += param.lastYear
        total.jan += param.jan
        total.feb += param.feb
        total.mar += param.mar
        total.apr += param.apr
        total.may += param.may
        total.jun += param.jun
        total.jul += param.jul
        total.aug += param.aug
        total.sep += param.sep
        total.oct += param.oct
        total.nov += param.nov
        total.dec += param.dec
        total.total += param.total
        total.lastYearActual += param.lastYearActual
        total.ytd = key == '' ? 0 : total[key]
        total.yoy = (total == 0 || total.lastYearActual == 0) ? '0%' : ((total.ytd / total.lastYearActual) * 100).toFixed(2) + '%';

        return total
    },
    totalValue: function (total, param) {
        total.jan += param.jan
        total.feb += param.feb
        total.mar += param.mar
        total.apr += param.apr
        total.may += param.may
        total.jun += param.jun
        total.jul += param.jul
        total.aug += param.aug
        total.sep += param.sep
        total.oct += param.oct
        total.nov += param.nov
        total.dec += param.dec
        
        total.janLastYear += param.janLastYear
        total.febLastYear += param.febLastYear
        total.marLastYear += param.marLastYear
        total.aprLastYear += param.aprLastYear
        total.mayLastYear += param.mayLastYear
        total.junLastYear += param.junLastYear
        total.julLastYear += param.julLastYear
        total.augLastYear += param.augLastYear
        total.sepLastYear += param.sepLastYear
        total.octLastYear += param.octLastYear
        total.novLastYear += param.novLastYear
        total.decLastYear += param.decLastYear

        return total
    },
    sumTotal: function (component, helper, obj, year, month) {
        var dayOfCurrentYear = [31, (helper.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        var dayOfLastYear = [31, (helper.isLeapYear(year - 1) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
        var total = 0
        var ytd = 0
        var lastYear = 0
        var lastYearActual = 0
        var totalDayCurrentYear = 0
        var totalDayLastYear = 0
    
        for(var i = 0; i < 12; i++) {
          var keyCurrent = (helper.getMonthName(i, 'short')).toLowerCase();
          var keyLastYear = keyCurrent + 'LastYear';
    
          // total += (obj[keyCurrent] * dayOfCurrentYear[i]);
          // lastYear += (obj[keyLastYear] * dayOfLastYear[i]);
          total += obj[keyCurrent]
          lastYear += obj[keyLastYear]
    
          totalDayCurrentYear += dayOfCurrentYear[i];
          totalDayLastYear += dayOfLastYear[i];
    
          if(i == month - 1) {
            ytd = total;
            lastYearActual = lastYear;
          }
        }
    
        obj.lastYear = lastYear
        obj.total = total
        obj.ytd = ytd
        obj.lastYearActual = lastYearActual
    
        return obj
      },
      sumTotalPerccent: function (component, helper, avg, valueArr, valuePercent, year, month) {
        var dayOfCurrentYear = [31, (helper.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        var dayOfLastYear = [31, (helper.isLeapYear(year - 1) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
        var totalAvg = 0
        var totalValue = 0
        var totalAvgLastyear = 0
        var totalValueLastyear = 0
        var ytd = 0
        var lastYearActual = 0
        var totalDayCurrentYear = 0
        var totalDayLastYear = 0
    
        for(var i = 0; i < 12; i++) {
          var keyCurrent = (helper.getMonthName(i, 'short')).toLowerCase();
          var keyLastYear = keyCurrent + 'LastYear';
    
          // total = (obj[keyCurrent] * dayOfCurrentYear[i]);
          // lastYear = (obj[keyLastYear] * dayOfLastYear[i]);
          totalAvg += avg[keyCurrent]
          totalValue += valueArr[keyCurrent]
    
          totalAvgLastyear += avg[keyLastYear]
          totalValueLastyear += valueArr[keyLastYear]
    
          totalDayCurrentYear += dayOfCurrentYear[i];
          totalDayLastYear += dayOfLastYear[i];
    
          if(i == month - 1) {
            ytd = (totalValue == 0 || totalAvg == 0) ? 0 : ((totalValue / totalAvg) / totalDayCurrentYear) * (helper.isLeapYear(year) ? 366 : 365);
            lastYearActual = (totalValueLastyear == 0 || totalAvgLastyear == 0) ? 0 : ((totalValueLastyear / totalAvgLastyear) / totalDayLastYear) * (helper.isLeapYear(year - 1) ? 366 : 365);
          }
        }
    
        valuePercent.lastYear = (avg.lastYear == 0 || valueArr.lastYear == 0) ? 0 : (valueArr.lastYear / avg.lastYear) * 100
        valuePercent.total = (avg.total == 0 || valueArr.total == 0) ? 0 :(valueArr.total / avg.total) * 100
        valuePercent.ytd = ytd * 100
        valuePercent.lastYearActual = lastYearActual * 100
    
        return valuePercent
    },
    calLTPortion: function (component, helper, LTPortion, endingAll, endingLT) {
        LTPortion.lastYear = (endingLT.lastYear == 0 || endingAll.lastYear == 0) ? 0 : (endingLT.lastYear / endingAll.lastYear) * 100
        LTPortion.jan = (endingLT.jan == 0 || endingAll.jan == 0) ? 0 : (endingLT.jan / endingAll.jan) * 100
        LTPortion.feb = (endingLT.feb == 0 || endingAll.feb == 0) ? 0 : (endingLT.feb / endingAll.feb) * 100
        LTPortion.mar = (endingLT.mar == 0 || endingAll.mar == 0) ? 0 : (endingLT.mar / endingAll.mar) * 100
        LTPortion.apr = (endingLT.apr == 0 || endingAll.apr == 0) ? 0 : (endingLT.apr / endingAll.apr) * 100
        LTPortion.may = (endingLT.may == 0 || endingAll.may == 0) ? 0 : (endingLT.may / endingAll.may) * 100
        LTPortion.jun = (endingLT.jun == 0 || endingAll.jun == 0) ? 0 : (endingLT.jun / endingAll.jun) * 100
        LTPortion.jul = (endingLT.jul == 0 || endingAll.jul == 0) ? 0 : (endingLT.jul / endingAll.jul) * 100
        LTPortion.aug = (endingLT.aug == 0 || endingAll.aug == 0) ? 0 : (endingLT.aug / endingAll.aug) * 100
        LTPortion.sep = (endingLT.sep == 0 || endingAll.sep == 0) ? 0 : (endingLT.sep / endingAll.sep) * 100
        LTPortion.oct = (endingLT.oct == 0 || endingAll.oct == 0) ? 0 : (endingLT.oct / endingAll.oct) * 100
        LTPortion.nov = (endingLT.nov == 0 || endingAll.nov == 0) ? 0 : (endingLT.nov / endingAll.nov) * 100
        LTPortion.dec = (endingLT.dec == 0 || endingAll.dec == 0) ? 0 : (endingLT.dec / endingAll.dec) * 100
        LTPortion.total = (endingLT.total == 0 || endingAll.total == 0) ? 0 : (endingLT.total / endingAll.total) * 100
        LTPortion.lastYearActual = (endingLT.lastYearActual == 0 || endingAll.lastYearActual == 0) ? 0 : (endingLT.lastYearActual / endingAll.lastYearActual) * 100
        LTPortion.ytd = (endingLT.ytd == 0 || endingAll.ytd == 0) ? 0 : (endingLT.ytd / endingAll.ytd) * 100
        LTPortion.yoy = (LTPortion.ytd == 0 || LTPortion.lastYearActual == 0) ? '' : ((LTPortion.ytd / LTPortion.lastYearActual) * 100)
            
        return LTPortion
    },
    setDefaultData: function (component, helper, keyword) {
        var isPercent = keyword.includes('%');
        var valueArr = []
        var rowType = helper.getRowType(keyword);
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        
        var reportYear = parseInt(component.get('v.reportParam.selectedYear'));
        valueArr[0] = {
          rm: '',
          team: '',
          product: rowType[0],
          isSub: false,
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
          isPercent: isPercent,
          originVariance: '',
          originArchieve: '',
          originFYTarget: '',
        }
    
        valueArr[1] = {
            rm: '',
            team: '',
            product: rowType[1],
            isSub: true,
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
            isPercent: isPercent,
            originVariance: '',
            originArchieve: '',
            originFYTarget: '',
        }
    
        valueArr[2] = {
            rm: '',
            team: '',
            product: rowType[2],
            isSub: true,
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
            isPercent: isPercent,
            originVariance: '',
            originArchieve: '',
            originFYTarget: '',
        }
    
        if (keyword == 'NI') {
          valueArr[3] = {
            rm: '',
            team: '',
            product: rowType[3],
            isSub: true,
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
            isPercent: isPercent,
            originVariance: '',
            originArchieve: '',
            originFYTarget: '',
          }
    
          valueArr[4] = {
            rm: '',
            team: '',
            product: rowType[4],
            isSub: true,
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
            isPercent: isPercent,
            originVariance: '',
            originArchieve: '',
            originFYTarget: '',
          }
        }
    
        if(reportYear == year) {
          month = today.getMonth();
        } else {
            month = 0;
        }
    
        if (month >= 3) {
          var firstTarget = {
            firstTargetVariance: '',
            firstTargetArchieve: '',
            firstTargetFYTarget: ''
          }
    
          valueArr[0] = Object.assign(valueArr[0], firstTarget);
          valueArr[1] = Object.assign(valueArr[1], firstTarget);
          valueArr[2] = Object.assign(valueArr[2], firstTarget);
    
          if (keyword == 'NI') {
            valueArr[3] = Object.assign(valueArr[3], firstTarget);
            valueArr[4] = Object.assign(valueArr[4], firstTarget);
          }
        }
        if (month >= 6) {
          var secondTarget = {
            secondTargetVariance: '',
            secondTargetArchieve: '',
            secondTargetFYTarget: ''
          }
    
          valueArr[0] = Object.assign(valueArr[0], secondTarget);
          valueArr[1] = Object.assign(valueArr[1], secondTarget);
          valueArr[2] = Object.assign(valueArr[2], secondTarget);
    
          if (keyword == 'NI') {
            valueArr[3] = Object.assign(valueArr[3], secondTarget);
            valueArr[4] = Object.assign(valueArr[4], secondTarget);
          }
        }
        if (month >= 9) {
          var thirdTarget = {
            thirdTargetVariance: '',
            thirdTargetArchieve: '',
            thirdTargetFYTarget: ''
          }
    
          valueArr[0] = Object.assign(valueArr[0], thirdTarget);
          valueArr[1] = Object.assign(valueArr[1], thirdTarget);
          valueArr[2] = Object.assign(valueArr[2], thirdTarget);
    
          if (keyword == 'NI') {
            valueArr[3] = Object.assign(valueArr[3], thirdTarget);
            valueArr[4] = Object.assign(valueArr[4], thirdTarget);
          }
        }
    
        return valueArr
    },
    setValueData: function (component, helper, data2a, valueArr, keyword) {
        var rowType = helper.getRowType(keyword);
        valueArr.forEach(element => {
          if(element != null && element.product == rowType[0]) {
            valueArr[0].jan = valueArr[0].jan + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[0].feb = valueArr[0].feb + parseFloat(data2a[keyword + '_02__c'])
            valueArr[0].mar = valueArr[0].mar + parseFloat(data2a[keyword + '_03__c'])
            valueArr[0].apr = valueArr[0].apr + parseFloat(data2a[keyword + '_04__c'])
            valueArr[0].may = valueArr[0].may + parseFloat(data2a[keyword + '_05__c'])
            valueArr[0].jun = valueArr[0].jun + parseFloat(data2a[keyword + '_06__c'])
            valueArr[0].jul = valueArr[0].jul + parseFloat(data2a[keyword + '_07__c'])
            valueArr[0].aug = valueArr[0].aug + parseFloat(data2a[keyword + '_08__c'])
            valueArr[0].sep = valueArr[0].sep + parseFloat(data2a[keyword + '_09__c'])
            valueArr[0].oct = valueArr[0].oct + parseFloat(data2a[keyword + '_10__c'])
            valueArr[0].nov = valueArr[0].nov + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[0].dec = valueArr[0].dec + parseFloat(data2a[keyword + '_12__c']) 
          }
          
          if (element != null && (element.product == rowType[1] && data2a.Product__r.Remark__c == 'LT loan')) {
            valueArr[1].jan = valueArr[1].jan + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[1].feb = valueArr[1].feb + parseFloat(data2a[keyword + '_02__c'])
            valueArr[1].mar = valueArr[1].mar + parseFloat(data2a[keyword + '_03__c'])
            valueArr[1].apr = valueArr[1].apr + parseFloat(data2a[keyword + '_04__c'])
            valueArr[1].may = valueArr[1].may + parseFloat(data2a[keyword + '_05__c'])
            valueArr[1].jun = valueArr[1].jun + parseFloat(data2a[keyword + '_06__c'])
            valueArr[1].jul = valueArr[1].jul + parseFloat(data2a[keyword + '_07__c'])
            valueArr[1].aug = valueArr[1].aug + parseFloat(data2a[keyword + '_08__c'])
            valueArr[1].sep = valueArr[1].sep + parseFloat(data2a[keyword + '_09__c'])
            valueArr[1].oct = valueArr[1].oct + parseFloat(data2a[keyword + '_10__c'])
            valueArr[1].nov = valueArr[1].nov + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[1].dec = valueArr[1].dec + parseFloat(data2a[keyword + '_12__c']) 
          }
          
          if (element != null && (element.product == rowType[2] && data2a.Product__r.Remark__c == 'ST loan')) {
            valueArr[2].jan = valueArr[2].jan + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[2].feb = valueArr[2].feb + parseFloat(data2a[keyword + '_02__c'])
            valueArr[2].mar = valueArr[2].mar + parseFloat(data2a[keyword + '_03__c'])
            valueArr[2].apr = valueArr[2].apr + parseFloat(data2a[keyword + '_04__c'])
            valueArr[2].may = valueArr[2].may + parseFloat(data2a[keyword + '_05__c'])
            valueArr[2].jun = valueArr[2].jun + parseFloat(data2a[keyword + '_06__c'])
            valueArr[2].jul = valueArr[2].jul + parseFloat(data2a[keyword + '_07__c'])
            valueArr[2].aug = valueArr[2].aug + parseFloat(data2a[keyword + '_08__c'])
            valueArr[2].sep = valueArr[2].sep + parseFloat(data2a[keyword + '_09__c'])
            valueArr[2].oct = valueArr[2].oct + parseFloat(data2a[keyword + '_10__c'])
            valueArr[2].nov = valueArr[2].nov + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[2].dec = valueArr[2].dec + parseFloat(data2a[keyword + '_12__c']) 
          }
          if (keyword == 'NI') {
            if (element != null && (element.product == rowType[4] && data2a.Product__r.Sub_Remark__c == 'Trade')) {
              valueArr[4].jan = valueArr[4].jan + parseFloat(data2a[keyword + '_01__c']) 
              valueArr[4].feb = valueArr[4].feb + parseFloat(data2a[keyword + '_02__c'])
              valueArr[4].mar = valueArr[4].mar + parseFloat(data2a[keyword + '_03__c'])
              valueArr[4].apr = valueArr[4].apr + parseFloat(data2a[keyword + '_04__c'])
              valueArr[4].may = valueArr[4].may + parseFloat(data2a[keyword + '_05__c'])
              valueArr[4].jun = valueArr[4].jun + parseFloat(data2a[keyword + '_06__c'])
              valueArr[4].jul = valueArr[4].jul + parseFloat(data2a[keyword + '_07__c'])
              valueArr[4].aug = valueArr[4].aug + parseFloat(data2a[keyword + '_08__c'])
              valueArr[4].sep = valueArr[4].sep + parseFloat(data2a[keyword + '_09__c'])
              valueArr[4].oct = valueArr[4].oct + parseFloat(data2a[keyword + '_10__c'])
              valueArr[4].nov = valueArr[4].nov + parseFloat(data2a[keyword + '_11__c']) 
              valueArr[4].dec = valueArr[4].dec + parseFloat(data2a[keyword + '_12__c']) 
            }
    
            // st - trade
            if (element != null && (element.product == rowType[3])) {
              valueArr[3].jan = valueArr[2].jan - valueArr[4].jan
              valueArr[3].feb = valueArr[2].feb - valueArr[4].feb
              valueArr[3].mar = valueArr[2].mar - valueArr[4].mar
              valueArr[3].apr = valueArr[2].apr - valueArr[4].apr
              valueArr[3].may = valueArr[2].may - valueArr[4].may
              valueArr[3].jun = valueArr[2].jun - valueArr[4].jun
              valueArr[3].jul = valueArr[2].jul - valueArr[4].jul
              valueArr[3].aug = valueArr[2].aug - valueArr[4].aug
              valueArr[3].sep = valueArr[2].sep - valueArr[4].sep
              valueArr[3].oct = valueArr[2].oct - valueArr[4].oct
              valueArr[3].nov = valueArr[2].nov - valueArr[4].nov
              valueArr[3].dec = valueArr[2].dec - valueArr[4].dec
            }
          }
        });
      
        return valueArr;
      },

      setValueLastYearData: function (component, helper, data2a, valueArr, keyword) {
        var rowType = helper.getRowType(keyword);
        valueArr.forEach(element => {
          if(element != null && element.product == rowType[0]) {
            valueArr[0].janLastYear = valueArr[0].janLastYear + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[0].febLastYear = valueArr[0].febLastYear + parseFloat(data2a[keyword + '_02__c'])
            valueArr[0].marLastYear = valueArr[0].marLastYear + parseFloat(data2a[keyword + '_03__c'])
            valueArr[0].aprLastYear = valueArr[0].aprLastYear + parseFloat(data2a[keyword + '_04__c'])
            valueArr[0].mayLastYear = valueArr[0].mayLastYear + parseFloat(data2a[keyword + '_05__c'])
            valueArr[0].junLastYear = valueArr[0].junLastYear + parseFloat(data2a[keyword + '_06__c'])
            valueArr[0].julLastYear = valueArr[0].julLastYear + parseFloat(data2a[keyword + '_07__c'])
            valueArr[0].augLastYear = valueArr[0].augLastYear + parseFloat(data2a[keyword + '_08__c'])
            valueArr[0].sepLastYear = valueArr[0].sepLastYear + parseFloat(data2a[keyword + '_09__c'])
            valueArr[0].octLastYear = valueArr[0].octLastYear + parseFloat(data2a[keyword + '_10__c'])
            valueArr[0].novLastYear = valueArr[0].novLastYear + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[0].decLastYear = valueArr[0].decLastYear + parseFloat(data2a[keyword + '_12__c']) 
          }
          
          if (element != null && (element.product == rowType[1] && data2a.Product__r.Remark__c == 'LT loan')) {
            valueArr[1].janLastYear = valueArr[1].janLastYear + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[1].febLastYear = valueArr[1].febLastYear + parseFloat(data2a[keyword + '_02__c'])
            valueArr[1].marLastYear = valueArr[1].marLastYear + parseFloat(data2a[keyword + '_03__c'])
            valueArr[1].aprLastYear = valueArr[1].aprLastYear + parseFloat(data2a[keyword + '_04__c'])
            valueArr[1].mayLastYear = valueArr[1].mayLastYear + parseFloat(data2a[keyword + '_05__c'])
            valueArr[1].junLastYear = valueArr[1].junLastYear + parseFloat(data2a[keyword + '_06__c'])
            valueArr[1].julLastYear = valueArr[1].julLastYear + parseFloat(data2a[keyword + '_07__c'])
            valueArr[1].augLastYear = valueArr[1].augLastYear + parseFloat(data2a[keyword + '_08__c'])
            valueArr[1].sepLastYear = valueArr[1].sepLastYear + parseFloat(data2a[keyword + '_09__c'])
            valueArr[1].octLastYear = valueArr[1].octLastYear + parseFloat(data2a[keyword + '_10__c'])
            valueArr[1].novLastYear = valueArr[1].novLastYear + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[1].decLastYear = valueArr[1].decLastYear + parseFloat(data2a[keyword + '_12__c']) 
          }
          
          if (element != null && (element.product == rowType[2] && data2a.Product__r.Remark__c == 'ST loan')) {
            valueArr[2].janLastYear = valueArr[2].janLastYear + parseFloat(data2a[keyword + '_01__c']) 
            valueArr[2].febLastYear = valueArr[2].febLastYear + parseFloat(data2a[keyword + '_02__c'])
            valueArr[2].marLastYear = valueArr[2].marLastYear + parseFloat(data2a[keyword + '_03__c'])
            valueArr[2].aprLastYear = valueArr[2].aprLastYear + parseFloat(data2a[keyword + '_04__c'])
            valueArr[2].mayLastYear = valueArr[2].mayLastYear + parseFloat(data2a[keyword + '_05__c'])
            valueArr[2].junLastYear = valueArr[2].junLastYear + parseFloat(data2a[keyword + '_06__c'])
            valueArr[2].julLastYear = valueArr[2].julLastYear + parseFloat(data2a[keyword + '_07__c'])
            valueArr[2].augLastYear = valueArr[2].augLastYear + parseFloat(data2a[keyword + '_08__c'])
            valueArr[2].sepLastYear = valueArr[2].sepLastYear + parseFloat(data2a[keyword + '_09__c'])
            valueArr[2].octLastYear = valueArr[2].octLastYear + parseFloat(data2a[keyword + '_10__c'])
            valueArr[2].novLastYear = valueArr[2].novLastYear + parseFloat(data2a[keyword + '_11__c']) 
            valueArr[2].decLastYear = valueArr[2].decLastYear + parseFloat(data2a[keyword + '_12__c']) 
          }
          if (keyword == 'NI') {
            if (element != null && (element.product == rowType[4] && data2a.Product__r.Sub_Remark__c == 'Trade')) {
                valueArr[4].janLastYear = valueArr[4].janLastYear + parseFloat(data2a[keyword + '_01__c']) 
                valueArr[4].febLastYear = valueArr[4].febLastYear + parseFloat(data2a[keyword + '_02__c'])
                valueArr[4].marLastYear = valueArr[4].marLastYear + parseFloat(data2a[keyword + '_03__c'])
                valueArr[4].aprLastYear = valueArr[4].aprLastYear + parseFloat(data2a[keyword + '_04__c'])
                valueArr[4].mayLastYear = valueArr[4].mayLastYear + parseFloat(data2a[keyword + '_05__c'])
                valueArr[4].junLastYear = valueArr[4].junLastYear + parseFloat(data2a[keyword + '_06__c'])
                valueArr[4].julLastYear = valueArr[4].julLastYear + parseFloat(data2a[keyword + '_07__c'])
                valueArr[4].augLastYear = valueArr[4].augLastYear + parseFloat(data2a[keyword + '_08__c'])
                valueArr[4].sepLastYear = valueArr[4].sepLastYear + parseFloat(data2a[keyword + '_09__c'])
                valueArr[4].octLastYear = valueArr[4].octLastYear + parseFloat(data2a[keyword + '_10__c'])
                valueArr[4].novLastYear = valueArr[4].novLastYear + parseFloat(data2a[keyword + '_11__c']) 
                valueArr[4].decLastYear = valueArr[4].decLastYear + parseFloat(data2a[keyword + '_12__c']) 
            }
    
            // st - trade
            if (element != null && (element.product == rowType[3])) {
              valueArr[3].janLastYear = valueArr[2].janLastYear - valueArr[4].janLastYear
              valueArr[3].febLastYear = valueArr[2].febLastYear - valueArr[4].febLastYear
              valueArr[3].marLastYear = valueArr[2].marLastYear - valueArr[4].marLastYear
              valueArr[3].aprLastYear = valueArr[2].aprLastYear - valueArr[4].aprLastYear
              valueArr[3].mayLastYear = valueArr[2].mayLastYear - valueArr[4].mayLastYear
              valueArr[3].junLastYear = valueArr[2].junLastYear - valueArr[4].junLastYear
              valueArr[3].julLastYear = valueArr[2].julLastYear - valueArr[4].julLastYear
              valueArr[3].augLastYear = valueArr[2].augLastYear - valueArr[4].augLastYear
              valueArr[3].sepLastYear = valueArr[2].sepLastYear - valueArr[4].sepLastYear
              valueArr[3].octLastYear = valueArr[2].octLastYear - valueArr[4].octLastYear
              valueArr[3].novLastYear = valueArr[2].novLastYear - valueArr[4].novLastYear
              valueArr[3].decLastYear = valueArr[2].decLastYear - valueArr[4].decLastYear
            }
          }
        });
      
        return valueArr;
      },
    getRowType: function (key) {
        var rowType = {
          'Ending_Balance': ['Ending Balance', 'LT Loan', 'ST Loan'],
          'Average_Balance': ['Avg Balance', 'LT Loan', 'ST Loan'],
          'NI': ['NIIc', 'LT Loan (NI)', 'ST Loan (NI)', 'ST Loan (NI) - Trade (NI)', 'Trade (NI)'],
          'Interest_Income': ['Interest Income', 'LT Loan', 'ST Loan'],
          'FTP': ['FTP', 'LT Loan', 'ST Loan'],
          '%NIMc': ['%NIMc', 'LT Loan', 'ST Loan'],
          '%Yield': ['%Yield', 'LT Loan', 'ST Loan'],
          '%FTP': ['%FTP', 'LT Loan', 'ST Loan']
        }
        return rowType[key]
    },
    setJSONData: function (teamTotalRow) {
        var arrObj = []
        var team = teamTotalRow[0].team
        var rm = teamTotalRow[0].rm
        teamTotalRow.forEach(element => {
            var obj = {}
            obj['Team'] = team
            obj['RM'] = rm
            obj['Product'] = element.product
            obj['Lastyear'] = (element.lastYear).toFixed(2)
            obj['Jan'] = (element.jan).toFixed(2)
            obj['Feb'] = (element.feb).toFixed(2)
            obj['Mar'] = (element.mar).toFixed(2)
            obj['Apr'] = (element.apr).toFixed(2)
            obj['May'] = (element.may).toFixed(2)
            obj['Jun'] = (element.jun).toFixed(2)
            obj['Jul'] = (element.jul).toFixed(2)
            obj['Aug'] = (element.aug).toFixed(2)
            obj['Sep'] = (element.sep).toFixed(2)
            obj['Oct'] = (element.oct).toFixed(2)
            obj['Nov'] = (element.nov).toFixed(2)
            obj['Dec'] = (element.dec).toFixed(2)
            obj['Total'] = (element.total).toFixed(2)
            obj['YTD'] = (element.ytd).toFixed(2)
            obj['YOY'] = element.yoyMillionUnit

            arrObj.push(obj)
        });
            
        return arrObj
    },
})