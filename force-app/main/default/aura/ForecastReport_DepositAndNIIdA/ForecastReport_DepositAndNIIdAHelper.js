({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

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
            }
        ];

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
            }
        ];

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
            } else if (element['fieldName'] == 'YTD') {
                if(reportYear != year) {
                    month = 0;
                }
                var monthName = month == 0 ? '' : helper.getMonthName(month - 1, 'full');
                element['label2'] = monthName == '' ? '' : '(as of ' + element['label2'].concat(monthName) + ')';
            } 
        });

        var columns3a = [];
        columns3a = columns3a.concat(hearderStart);
        columns3a = columns3a.concat(hearderMonth);
        columns3a = columns3a.concat(hearderEnd);

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
            }];

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
            ];

            hearderTop = hearderTop.concat(headThirdTop);
            hearderBottom = hearderBottom.concat(headThirdBottom);
        }

        component.set('v.gridColumnsMockTable', columns3a);
        component.set('v.targetColumnsTop', hearderTop);
        component.set('v.targetColumnsBottom', hearderBottom);
    },
    groupData: function (component, helper, result, lastyear) {
        var grouped = {};
        var groupRm = {};
        var groupRmLastYear ={};
        var groupByRegion ={};
        var target = helper.parseObj(component.get('v.target'))
        var allGrouped = []
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
            //console.log('result: ', keyRm)
            groupRm[keyRm] = groupRm[keyRm] ? groupRm[keyRm] : [];
            groupRm[keyRm].push(data);
        });

        lastyear.forEach((dataLastYear) => {
            var keyRm = dataLastYear.Customer__r.Owner.Name
            //console.log('lastyear: ', keyRm)
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
                            niBal[0].originFYTarget = (element.TargetNIIdAmount__c == null || element.TargetNIIdAmount__c == undefined) ? '' : element.TargetNIIdAmount__c
                            if (month >= 3) niBal[0].firstTargetFYTarget = (element.TargetNIIdAmount_3_9__c == null || element.TargetNIIdAmount_3_9__c == undefined) ? '' : element.TargetNIIdAmount_3_9__c 
                            if (month >= 6) niBal[0].secondTargetFYTarget = (element.TargetNIIdAmount_6_6__c == null || element.TargetNIIdAmount_6_6__c == undefined) ? '' : element.TargetNIIdAmount_6_6__c 
                            if (month >= 9) niBal[0].thirdTargetFYTarget = (element.TargetNIIdAmount_9_3__c == null || element.TargetNIIdAmount_9_3__c == undefined) ? '' : element.TargetNIIdAmount_9_3__c 
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
    
                    // target.forEach(element => {
                    //     if(endingBal[0].rm == element.Owner.Name) {
                    //         niBal[0].originFYTarget = (element.TargetNIIdAmount__c == null || element.TargetNIIdAmount__c == undefined) ? '' : element.TargetNIIdAmount__c
                    //         if (month >= 3) niBal[0].firstTargetFYTarget = (element.TargetNIIdAmount_3_9__c == null || element.TargetNIIdAmount_3_9__c == undefined) ? '' : element.TargetNIIdAmount_3_9__c 
                    //         if (month >= 6) niBal[0].secondTargetFYTarget = (element.TargetNIIdAmount_6_6__c == null || element.TargetNIIdAmount_6_6__c == undefined) ? '' : element.TargetNIIdAmount_6_6__c 
                    //         if (month >= 9) niBal[0].thirdTargetFYTarget = (element.TargetNIIdAmount_9_3__c == null || element.TargetNIIdAmount_9_3__c == undefined) ? '' : element.TargetNIIdAmount_9_3__c 
                    //     }
                    // });
    
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
                    if(!(element.TargetNIIdAmount__c == null || element.TargetNIIdAmount__c == undefined)) {
                        niBal[0].originFYTarget = (niBal[0].originFYTarget === '' ? 0 : niBal[0].originFYTarget) + element.TargetNIIdAmount__c
                    }
                    if (!(element.TargetNIIdAmount_3_9__c == null || element.TargetNIIdAmount_3_9__c == undefined)) {
                        if (month >= 3) niBal[0].firstTargetFYTarget = (niBal[0].firstTargetFYTarget === '' ? 0 : niBal[0].firstTargetFYTarget) + element.TargetNIIdAmount_3_9__c
                    }
                    if(!(element.TargetNIIdAmount_6_6__c == null || element.TargetNIIdAmount_6_6__c == undefined)) {
                        if (month >= 6) niBal[0].secondTargetFYTarget = (niBal[0].secondTargetFYTarget === '' ? 0 : niBal[0].secondTargetFYTarget) + element.TargetNIIdAmount_6_6__c
                    }
                    if(!(element.TargetNIIdAmount_9_3__c == null || element.TargetNIIdAmount_9_3__c == undefined)) {
                        if (month >= 9) niBal[0].thirdTargetFYTarget = (niBal[0].thirdTargetFYTarget === '' ? 0 : niBal[0].thirdTargetFYTarget) + element.TargetNIIdAmount_9_3__c 
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

                // Interest Income
                teamTotalRow[9] = helper.totalValue(teamTotalRow[9], rm[9])
                teamTotalRow[10] = helper.totalValue(teamTotalRow[10], rm[10])
                teamTotalRow[11] = helper.totalValue(teamTotalRow[11], rm[11])
                                
                // FTP
                teamTotalRow[12] = helper.totalValue(teamTotalRow[12], rm[12])
                teamTotalRow[13] = helper.totalValue(teamTotalRow[13], rm[13])
                teamTotalRow[14] = helper.totalValue(teamTotalRow[14], rm[14])
                
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
        for (var key of Object.keys(groupRegion)) {
            var groped = {}
            
            var endingBal = helper.setDefaultData(component, helper, 'Ending_Balance')
            var avgBal = helper.setDefaultData(component, helper, 'Average_Balance')
            var niBal = helper.setDefaultData(component, helper, 'NI')
            var InterestBal = helper.setDefaultData(component, helper, 'Interest_Income')
            var ftpBal = helper.setDefaultData(component, helper, 'FTP')
            // endingBal[0].team = groupRegion[keyRegion]['team'][0].team
            endingBal[0].rm = 'Region Total'

            // target.forEach(element => {
            //     if(key == element.Owner.Region__c) {
            //         niBal[0].originFYTarget = element.TargetNIIdAmount__c
            //         if (month >= 3) niBal[0].firstTarget = element.TargetNIIdAmount_3_9__c 
            //         if (month >= 3) niBal[0].secondTarget = element.TargetNIIdAmount_6_6__c 
            //         if (month >= 3) niBal[0].thirdTarget = element.TargetNIIdAmount_9_3__c 
            //     }
            // });
            
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

                // Interest Income
                regionTotalRow[9] = helper.totalValue(regionTotalRow[9], team[9])
                regionTotalRow[10] = helper.totalValue(regionTotalRow[10], team[10])
                regionTotalRow[11] = helper.totalValue(regionTotalRow[11], team[11])
                                
                // FTP
                regionTotalRow[12] = helper.totalValue(regionTotalRow[12], team[12])
                regionTotalRow[13] = helper.totalValue(regionTotalRow[13], team[13])
                regionTotalRow[14] = helper.totalValue(regionTotalRow[14], team[14])  

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
            groped.rm = groupRegion[key]['rm']
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
            'December'
        ];
        
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
        ];

		return (type == 'full') ? monthFullNames[month] : monthShortNames[month];
    },

    getRec : function(component,helper){
        var reportParam = component.get('v.reportParam');
        var action = component.get("c.getReportByProductGroup");

        action.setParams({
            strYear : reportParam.selectedYear,
            CustomerPort : reportParam.CustomerPort,
            productGroup: 'Deposit',
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
          
          if (element != null && (element.product == rowType[1] && data2a.Product__r.Remark__c == 'CASA')) {
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
          
          if (element != null && (element.product == rowType[2] && data2a.Product__r.Remark__c == 'non-CASA')) {
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
          
          if (element != null && (element.product == rowType[1] && data2a.Product__r.Remark__c == 'CASA')) {
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
          
          if (element != null && (element.product == rowType[2] && data2a.Product__r.Remark__c == 'non-CASA')) {
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
        });
      
        return valueArr;
      },
      getRowType: function (key) {
        var rowType = {
            'Ending_Balance': ['Ending Balance', 'CASA', 'Non-CASA'],
            'Average_Balance': ['Avg Balance', 'CASA', 'Non-CASA'],
            'NI': ['NIId', 'CASA', 'Non-CASA'],
            'Interest_Income': ['Interest Income', 'CASA', 'Non-CASA'],
            'FTP': ['FTP', 'CASA', 'Non-CASA'],
            '%NIMd': ['%NIMd', 'CASA', 'Non-CASA'],
            '%Cost of Deposit': ['%Cost of Deposit', 'CASA', 'Non-CASA'],
            '%Fund Credit': ['%Fund Credit', 'CASA', 'Non-CASA']
        }

        return rowType[key];
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