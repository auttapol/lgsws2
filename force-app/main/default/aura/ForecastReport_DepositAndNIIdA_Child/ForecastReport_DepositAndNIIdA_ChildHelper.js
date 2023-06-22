({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },

    setEndingData: function (component, helper, endingBal) {
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        
        var reportYear = parseInt(component.get('v.reportYear'));
  
        var key = '';
        if(reportYear == year) {
          if (month > 0) {
            key = (helper.getMonthName(month - 1, 'short')).toLowerCase();
          }       
        } else if(reportYear > year) {
            month = 0
          key = (helper.getMonthName(11, 'short')).toLowerCase();
        }
  
        if(month == 0) {
            endingBal[0].lastYearActual = ''
            endingBal[0].ytd = ''

            endingBal[1].lastYearActual = ''
            endingBal[1].ytd = ''

            endingBal[2].lastYearActual = ''
            endingBal[2].ytd = ''
        } else {
            endingBal[0].lastYearActual = (key == '') ? 0 : endingBal[0][key+'LastYear']
            endingBal[0].ytd =  key == '' ? 0 : endingBal[0][key];

            endingBal[1].lastYearActual = (key == '') ? 0 : endingBal[1][key+'LastYear']
            endingBal[1].ytd =  key == '' ? 0 : endingBal[1][key];

            endingBal[2].lastYearActual = (key == '') ? 0 : endingBal[2][key+'LastYear']
            endingBal[2].ytd =  key == '' ? 0 : endingBal[2][key];        
        }

        endingBal[0].lastYear = endingBal[0].decLastYear
        endingBal[0].total = endingBal[0].dec
        
        
        endingBal[1].lastYear = endingBal[1].decLastYear
        endingBal[1].total = endingBal[1].dec
  
        endingBal[2].lastYear = endingBal[2].decLastYear
        endingBal[2].total = endingBal[2].dec  
            
        return endingBal;
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
            
            totalCurrentYear += (avg[0][keyCurrent] * dayOfCurrentYear[i]);
            totalLastYear += (avg[0][keyLastYear] * dayOfLastYear[i]);
            
            ltCurrentYear += (avg[1][keyCurrent] * dayOfCurrentYear[i]);
            ltLastYear += (avg[1][keyLastYear] * dayOfLastYear[i]);
            
            stCurrentYear += (avg[2][keyCurrent] * dayOfCurrentYear[i]);
            stLastYear += (avg[2][keyLastYear] * dayOfLastYear[i]);
            
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

        if(month == 0) {
            avg[0].ytd = ''
            avg[0].lastYearActual = ''

            avg[1].ytd = ''
            avg[1].lastYearActual = ''

            avg[2].ytd = ''
            avg[2].lastYearActual = ''
        } else {
            avg[0].ytd = (totalActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : totalActualCurrentYear / actualTotalDayCurrentYear;
            avg[0].lastYearActual = (totalActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : totalActualLastYear / actualTotalDayLastYear;

            avg[1].ytd = (ltActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : ltActualCurrentYear / actualTotalDayCurrentYear;
            avg[1].lastYearActual = (ltActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : ltActualLastYear / actualTotalDayLastYear;

            avg[2].ytd = (stActualCurrentYear == 0 || actualTotalDayCurrentYear == 0) ? 0 : stActualCurrentYear / actualTotalDayCurrentYear;
            avg[2].lastYearActual = (stActualLastYear == 0 || actualTotalDayLastYear == 0) ? 0 : stActualLastYear / actualTotalDayLastYear;
        }

        avg[0].lastYear = (totalLastYear == 0 || totalDayLastYear == 0) ? 0 : totalLastYear / totalDayLastYear;
        avg[0].total = (totalCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : totalCurrentYear / totalDayCurrentYear;

        avg[1].lastYear = (ltLastYear == 0 || totalDayLastYear == 0) ? 0 : ltLastYear / totalDayLastYear;
        avg[1].total = (ltCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : ltCurrentYear / totalDayCurrentYear;

        avg[2].lastYear = (stLastYear == 0 || totalDayLastYear == 0) ? 0 : stLastYear / totalDayLastYear;
        avg[2].total = (stCurrentYear == 0 || totalDayCurrentYear == 0) ? 0 : stCurrentYear / totalDayCurrentYear;
        

        return avg;
    },
    
    endingBalMillionUnit: function(component, helper, endingBal) {
        var jsonForCSV = component.get('v.jsonForCSV')
        endingBal.forEach(element => {
            if(element != null && element.product == 'Ending Balance') {
                endingBal[0].lastYearMillionUnit = (endingBal[0].lastYear / 10 ** 6).toFixed(2);
                endingBal[0].janMillionUnit = (endingBal[0].jan / 10 ** 6).toFixed(2);
                endingBal[0].febMillionUnit = (endingBal[0].feb / 10 ** 6).toFixed(2);
                endingBal[0].marMillionUnit = (endingBal[0].mar / 10 ** 6).toFixed(2);
                endingBal[0].aprMillionUnit = (endingBal[0].apr / 10 ** 6).toFixed(2);
                endingBal[0].mayMillionUnit = (endingBal[0].may / 10 ** 6).toFixed(2);
                endingBal[0].junMillionUnit = (endingBal[0].jun / 10 ** 6).toFixed(2);
                endingBal[0].julMillionUnit = (endingBal[0].jul / 10 ** 6).toFixed(2);
                endingBal[0].augMillionUnit = (endingBal[0].aug / 10 ** 6).toFixed(2);
                endingBal[0].sepMillionUnit = (endingBal[0].sep / 10 ** 6).toFixed(2);
                endingBal[0].octMillionUnit = (endingBal[0].oct / 10 ** 6).toFixed(2);
                endingBal[0].novMillionUnit = (endingBal[0].nov / 10 ** 6).toFixed(2);
                endingBal[0].decMillionUnit = (endingBal[0].dec / 10 ** 6).toFixed(2);
                endingBal[0].totalMillionUnit = (endingBal[0].total / 10 ** 6).toFixed(2);
                endingBal[0].ytdMillionUnit = (endingBal[0].ytd == 0 || endingBal[0].ytd == '') ? endingBal[0].ytd : (endingBal[0].ytd / 10 ** 6).toFixed(2);

                if(endingBal[0].ytd === '') {
                    endingBal[0].yoy = ''
                    endingBal[0].yoyMillionUnit = ''
                } else {
                    endingBal[0].yoy = (endingBal[0].ytd == 0 || endingBal[0].lastYearActual == 0) ? 0 : ((endingBal[0].ytd / endingBal[0].lastYearActual) * 100);
                    endingBal[0].yoyMillionUnit = (endingBal[0].ytd == 0 || endingBal[0].lastYearActual == 0) ? 0 : (endingBal[0].ytd / endingBal[0].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, endingBal[0]))
            }
            
            if (element != null && element.product == 'CASA') {
                endingBal[1].lastYearMillionUnit = (endingBal[1].lastYear / 10 ** 6).toFixed(2);
                endingBal[1].janMillionUnit = (endingBal[1].jan / 10 ** 6).toFixed(2);
                endingBal[1].febMillionUnit = (endingBal[1].feb / 10 ** 6).toFixed(2);
                endingBal[1].marMillionUnit = (endingBal[1].mar / 10 ** 6).toFixed(2);
                endingBal[1].aprMillionUnit = (endingBal[1].apr / 10 ** 6).toFixed(2);
                endingBal[1].mayMillionUnit = (endingBal[1].may / 10 ** 6).toFixed(2);
                endingBal[1].junMillionUnit = (endingBal[1].jun / 10 ** 6).toFixed(2);
                endingBal[1].julMillionUnit = (endingBal[1].jul / 10 ** 6).toFixed(2);
                endingBal[1].augMillionUnit = (endingBal[1].aug / 10 ** 6).toFixed(2);
                endingBal[1].sepMillionUnit = (endingBal[1].sep / 10 ** 6).toFixed(2);
                endingBal[1].octMillionUnit = (endingBal[1].oct / 10 ** 6).toFixed(2);
                endingBal[1].novMillionUnit = (endingBal[1].nov / 10 ** 6).toFixed(2);
                endingBal[1].decMillionUnit = (endingBal[1].dec / 10 ** 6).toFixed(2);
                endingBal[1].totalMillionUnit = (endingBal[1].total / 10 ** 6).toFixed(2);
                endingBal[1].ytdMillionUnit = (endingBal[1].ytd == 0 || endingBal[1].ytd == '') ? endingBal[1].ytd : (endingBal[1].ytd / 10 ** 6).toFixed(2);

                if(endingBal[1].ytd === '') {
                    endingBal[1].yoy = ''
                    endingBal[1].yoyMillionUnit = ''
                } else {
                    endingBal[1].yoy = (endingBal[1].ytd == 0 || endingBal[1].lastYearActual == 0) ? 0 : ((endingBal[1].ytd / endingBal[1].lastYearActual) * 100);
                    endingBal[1].yoyMillionUnit = (endingBal[1].ytd == 0 || endingBal[1].lastYearActual == 0) ? 0 : (endingBal[1].ytd / endingBal[1].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, endingBal[1]))
            }
            
            if (element != null && element.product == 'Non-CASA') {
                endingBal[2].lastYearMillionUnit = (endingBal[2].lastYear / 10 ** 6).toFixed(2);
                endingBal[2].janMillionUnit = (endingBal[2].jan / 10 ** 6).toFixed(2);
                endingBal[2].febMillionUnit = (endingBal[2].feb / 10 ** 6).toFixed(2);
                endingBal[2].marMillionUnit = (endingBal[2].mar / 10 ** 6).toFixed(2);
                endingBal[2].aprMillionUnit = (endingBal[2].apr / 10 ** 6).toFixed(2);
                endingBal[2].mayMillionUnit = (endingBal[2].may / 10 ** 6).toFixed(2);
                endingBal[2].junMillionUnit = (endingBal[2].jun / 10 ** 6).toFixed(2);
                endingBal[2].julMillionUnit = (endingBal[2].jul / 10 ** 6).toFixed(2);
                endingBal[2].augMillionUnit = (endingBal[2].aug / 10 ** 6).toFixed(2);
                endingBal[2].sepMillionUnit = (endingBal[2].sep / 10 ** 6).toFixed(2);
                endingBal[2].octMillionUnit = (endingBal[2].oct / 10 ** 6).toFixed(2);
                endingBal[2].novMillionUnit = (endingBal[2].nov / 10 ** 6).toFixed(2);
                endingBal[2].decMillionUnit = (endingBal[2].dec / 10 ** 6).toFixed(2);
                endingBal[2].totalMillionUnit = (endingBal[2].total / 10 ** 6).toFixed(2);
                endingBal[2].ytdMillionUnit = (endingBal[2].ytd == 0 || endingBal[2].ytd == '') ? endingBal[2].ytd : (endingBal[2].ytd / 10 ** 6).toFixed(2);

                if(endingBal[2].ytd === '') {
                    endingBal[2].yoy = ''
                    endingBal[2].yoyMillionUnit = ''
                } else {
                    endingBal[2].yoy = (endingBal[2].ytd == 0 || endingBal[2].lastYearActual == 0) ? 0 : ((endingBal[2].ytd / endingBal[2].lastYearActual) * 100);
                    endingBal[2].yoyMillionUnit = (endingBal[2].ytd == 0 || endingBal[2].lastYearActual == 0) ? 0 : (endingBal[2].ytd / endingBal[2].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, endingBal[2]))
            }
        });
        component.set('v.jsonForCSV', jsonForCSV)
        return endingBal;
    },

    avgBalMillionUnit: function(component, helper, avgBal) {
        var jsonForCSV = component.get('v.jsonForCSV')
        avgBal.forEach(element => {
            if(element != null && element.product == 'Avg Balance') {
                avgBal[0].lastYearMillionUnit = (avgBal[0].lastYear / 10 ** 6).toFixed(2);
                avgBal[0].janMillionUnit = (avgBal[0].jan / 10 ** 6).toFixed(2);
                avgBal[0].febMillionUnit = (avgBal[0].feb / 10 ** 6).toFixed(2);
                avgBal[0].marMillionUnit = (avgBal[0].mar / 10 ** 6).toFixed(2);
                avgBal[0].aprMillionUnit = (avgBal[0].apr / 10 ** 6).toFixed(2);
                avgBal[0].mayMillionUnit = (avgBal[0].may / 10 ** 6).toFixed(2);
                avgBal[0].junMillionUnit = (avgBal[0].jun / 10 ** 6).toFixed(2);
                avgBal[0].julMillionUnit = (avgBal[0].jul / 10 ** 6).toFixed(2);
                avgBal[0].augMillionUnit = (avgBal[0].aug / 10 ** 6).toFixed(2);
                avgBal[0].sepMillionUnit = (avgBal[0].sep / 10 ** 6).toFixed(2);
                avgBal[0].octMillionUnit = (avgBal[0].oct / 10 ** 6).toFixed(2);
                avgBal[0].novMillionUnit = (avgBal[0].nov / 10 ** 6).toFixed(2);
                avgBal[0].decMillionUnit = (avgBal[0].dec / 10 ** 6).toFixed(2);
                avgBal[0].totalMillionUnit = (avgBal[0].total / 10 ** 6).toFixed(2);
                avgBal[0].ytdMillionUnit = (avgBal[0].ytd == 0 || avgBal[0].ytd == '') ? avgBal[0].ytd : (avgBal[0].ytd / 10 ** 6).toFixed(2);

                if(avgBal[0].ytd === '') {
                    avgBal[0].yoy = ''
                    avgBal[0].yoyMillionUnit = ''
                } else {
                    avgBal[0].yoy = (avgBal[0].ytd == 0 || avgBal[0].lastYearActual == 0) ? 0 : ((avgBal[0].ytd / avgBal[0].lastYearActual) * 100);
                    avgBal[0].yoyMillionUnit = (avgBal[0].ytd == 0 || avgBal[0].lastYearActual == 0) ? 0 : (avgBal[0].ytd / avgBal[0].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, avgBal[0]))
            }
            
            if (element != null && element.product == 'CASA') {
                avgBal[1].lastYearMillionUnit = (avgBal[1].lastYear / 10 ** 6).toFixed(2);
                avgBal[1].janMillionUnit = (avgBal[1].jan / 10 ** 6).toFixed(2);
                avgBal[1].febMillionUnit = (avgBal[1].feb / 10 ** 6).toFixed(2);
                avgBal[1].marMillionUnit = (avgBal[1].mar / 10 ** 6).toFixed(2);
                avgBal[1].aprMillionUnit = (avgBal[1].apr / 10 ** 6).toFixed(2);
                avgBal[1].mayMillionUnit = (avgBal[1].may / 10 ** 6).toFixed(2);
                avgBal[1].junMillionUnit = (avgBal[1].jun / 10 ** 6).toFixed(2);
                avgBal[1].julMillionUnit = (avgBal[1].jul / 10 ** 6).toFixed(2);
                avgBal[1].augMillionUnit = (avgBal[1].aug / 10 ** 6).toFixed(2);
                avgBal[1].sepMillionUnit = (avgBal[1].sep / 10 ** 6).toFixed(2);
                avgBal[1].octMillionUnit = (avgBal[1].oct / 10 ** 6).toFixed(2);
                avgBal[1].novMillionUnit = (avgBal[1].nov / 10 ** 6).toFixed(2);
                avgBal[1].decMillionUnit = (avgBal[1].dec / 10 ** 6).toFixed(2);
                avgBal[1].totalMillionUnit = (avgBal[1].total / 10 ** 6).toFixed(2);
                avgBal[1].ytdMillionUnit = (avgBal[1].ytd == 0 || avgBal[1].ytd == '') ? avgBal[1].ytd : (avgBal[1].ytd / 10 ** 6).toFixed(2);

                if(avgBal[1].ytd === '') {
                    avgBal[1].yoy = ''
                    avgBal[1].yoyMillionUnit = ''
                } else {
                    avgBal[1].yoy = (avgBal[1].ytd == 0 || avgBal[1].lastYearActual == 0) ? 0 : ((avgBal[1].ytd / avgBal[1].lastYearActual) * 100);
                    avgBal[1].yoyMillionUnit = (avgBal[1].ytd == 0 || avgBal[1].lastYearActual == 0) ? 0 : (avgBal[1].ytd / avgBal[1].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, avgBal[1]))
            }
            
            if (element != null && element.product == 'Non-CASA') {
                avgBal[2].lastYearMillionUnit = (avgBal[2].lastYear / 10 ** 6).toFixed(2);
                avgBal[2].janMillionUnit = (avgBal[2].jan / 10 ** 6).toFixed(2);
                avgBal[2].febMillionUnit = (avgBal[2].feb / 10 ** 6).toFixed(2);
                avgBal[2].marMillionUnit = (avgBal[2].mar / 10 ** 6).toFixed(2);
                avgBal[2].aprMillionUnit = (avgBal[2].apr / 10 ** 6).toFixed(2);
                avgBal[2].mayMillionUnit = (avgBal[2].may / 10 ** 6).toFixed(2);
                avgBal[2].junMillionUnit = (avgBal[2].jun / 10 ** 6).toFixed(2);
                avgBal[2].julMillionUnit = (avgBal[2].jul / 10 ** 6).toFixed(2);
                avgBal[2].augMillionUnit = (avgBal[2].aug / 10 ** 6).toFixed(2);
                avgBal[2].sepMillionUnit = (avgBal[2].sep / 10 ** 6).toFixed(2);
                avgBal[2].octMillionUnit = (avgBal[2].oct / 10 ** 6).toFixed(2);
                avgBal[2].novMillionUnit = (avgBal[2].nov / 10 ** 6).toFixed(2);
                avgBal[2].decMillionUnit = (avgBal[2].dec / 10 ** 6).toFixed(2);
                avgBal[2].totalMillionUnit = (avgBal[2].total / 10 ** 6).toFixed(2);
                avgBal[2].ytdMillionUnit = (avgBal[2].ytd == 0 || avgBal[2].ytd == '') ? avgBal[2].ytd : (avgBal[2].ytd / 10 ** 6).toFixed(2);

                if(avgBal[2].ytd === '') {
                    avgBal[2].yoy = ''
                    avgBal[2].yoyMillionUnit = ''
                } else {
                    avgBal[2].yoy = (avgBal[2].ytd == 0 || avgBal[2].lastYearActual == 0) ? 0 : ((avgBal[2].ytd / avgBal[2].lastYearActual) * 100);
                    avgBal[2].yoyMillionUnit = (avgBal[2].ytd == 0 || avgBal[2].lastYearActual == 0) ? 0 : (avgBal[2].ytd / avgBal[2].lastYearActual);
                }
                jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, avgBal[2]))
            }
        });
        component.set('v.jsonForCSV', jsonForCSV)
        return avgBal;
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

    isLeapYear: function (year) {
        return year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0);
    },

    sumTotal: function (component, helper, obj, year, month) {
        var total = 0;
        var ytd = 0;
        var lastYear = 0;
        var lastYearActual = 0;

        for(var i = 0; i < 12; i++) {
            var keyCurrent = (helper.getMonthName(i, 'short')).toLowerCase();
            var keyLastYear = keyCurrent + 'LastYear';

            total += obj[keyCurrent];
            lastYear += obj[keyLastYear];

            if(i == month - 1) {
                ytd = total;
                lastYearActual = lastYear;
            }
        }

        if(month == 0) {
            obj.ytd = ''
            obj.lastYearActual = ''
        } else {
            obj.ytd = ytd;
            obj.lastYearActual = lastYearActual;
        }
        obj.lastYear = lastYear;
        obj.total = total;

        return obj;
    },

    sumTotalPerccent: function (component, helper, avg, valueArr, valuePercent, year, month) {
        var dayOfCurrentYear = [31, (helper.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        var dayOfLastYear = [31, (helper.isLeapYear(year - 1) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        var totalAvg = 0;
        var totalValue = 0;
        var totalAvgLastyear = 0;
        var totalValueLastyear = 0;
        var ytd = 0;
        var lastYearActual = 0;
        var totalDayCurrentYear = 0;
        var totalDayLastYear = 0;

        for(var i = 0; i < 12; i++) {
            var keyCurrent = (helper.getMonthName(i, 'short')).toLowerCase();
            var keyLastYear = keyCurrent + 'LastYear';

            // total = (obj[keyCurrent] * dayOfCurrentYear[i]);
            // lastYear = (obj[keyLastYear] * dayOfLastYear[i]);
            totalAvg += avg[keyCurrent];
            totalValue += valueArr[keyCurrent];

            totalAvgLastyear += avg[keyLastYear];
            totalValueLastyear += valueArr[keyLastYear];

            totalDayCurrentYear += dayOfCurrentYear[i];
            totalDayLastYear += dayOfLastYear[i];

            if(i == month - 1) {
                ytd = (totalValue == 0 || totalAvg == 0) ? 0 : ((totalValue / totalAvg) / totalDayCurrentYear) * (helper.isLeapYear(year) ? 366 : 365);
                lastYearActual = (totalValueLastyear == 0 || totalAvgLastyear == 0) ? 0 : ((totalValueLastyear / totalAvgLastyear) / totalDayLastYear) * (helper.isLeapYear(year - 1) ? 366 : 365);
            }
        }

        if(month == 0) {
            valuePercent.ytd = ''
            valuePercent.lastYearActual = ''
        } else {
            valuePercent.ytd = ytd * 100;
            valuePercent.lastYearActual = lastYearActual * 100;
        }
        valuePercent.lastYear = (avg.lastYear == 0 || valueArr.lastYear == 0) ? 0 : (valueArr.lastYear / avg.lastYear) * 100;
        valuePercent.total = (avg.total == 0 || valueArr.total == 0) ? 0 : (valueArr.total / avg.total) * 100;

        return valuePercent;
    },

    setDefaultData: function (component, helper, keyword) {
        var isPercent = keyword.includes('%');
        var valueArr = [];
        var rowType = helper.getRowType(keyword);
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        
        var reportYear = parseInt(component.get('v.reportYear'));

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
        };

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
        };

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
        };

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

            component.set('v.isFirstTarget', true);
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

            component.set('v.isSecondTarget', true);
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

            component.set('v.isThirdTarget', true);
        }

        return valueArr;
    },

    setValueData: function (component, helper, data2a, valueArr, keyword) {
        var rowType = helper.getRowType(keyword);
        valueArr.forEach(element => {
            if(element != null && element.product == rowType[0]) {
                valueArr[0].jan = valueArr[0].jan + parseFloat(data2a[keyword + '_01__c']);
                valueArr[0].feb = valueArr[0].feb + parseFloat(data2a[keyword + '_02__c']);
                valueArr[0].mar = valueArr[0].mar + parseFloat(data2a[keyword + '_03__c']);
                valueArr[0].apr = valueArr[0].apr + parseFloat(data2a[keyword + '_04__c']);
                valueArr[0].may = valueArr[0].may + parseFloat(data2a[keyword + '_05__c']);
                valueArr[0].jun = valueArr[0].jun + parseFloat(data2a[keyword + '_06__c']);
                valueArr[0].jul = valueArr[0].jul + parseFloat(data2a[keyword + '_07__c']);
                valueArr[0].aug = valueArr[0].aug + parseFloat(data2a[keyword + '_08__c']);
                valueArr[0].sep = valueArr[0].sep + parseFloat(data2a[keyword + '_09__c']);
                valueArr[0].oct = valueArr[0].oct + parseFloat(data2a[keyword + '_10__c']);
                valueArr[0].nov = valueArr[0].nov + parseFloat(data2a[keyword + '_11__c']);
                valueArr[0].dec = valueArr[0].dec + parseFloat(data2a[keyword + '_12__c']);

                if (data2a.Last_Year_Forecast_Cube_1__r != null) {
                    valueArr[0].janLastYear = valueArr[0].janLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_01__c']);
                    valueArr[0].febLastYear = valueArr[0].febLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_02__c']);
                    valueArr[0].marLastYear = valueArr[0].marLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_03__c']);
                    valueArr[0].aprLastYear = valueArr[0].aprLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_04__c']);
                    valueArr[0].mayLastYear = valueArr[0].mayLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_05__c']);
                    valueArr[0].junLastYear = valueArr[0].junLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_06__c']);
                    valueArr[0].julLastYear = valueArr[0].julLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_07__c']);
                    valueArr[0].augLastYear = valueArr[0].augLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_08__c']);
                    valueArr[0].sepLastYear = valueArr[0].sepLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_09__c']);
                    valueArr[0].octLastYear = valueArr[0].octLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_10__c']);
                    valueArr[0].novLastYear = valueArr[0].novLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_11__c']);
                    valueArr[0].decLastYear = valueArr[0].decLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_12__c']);
                }
            }
            
            if (element != null && (element.product == rowType[1] && data2a.Product__r.Remark__c == 'CASA')) {
                valueArr[1].jan = valueArr[1].jan + parseFloat(data2a[keyword + '_01__c']);
                valueArr[1].feb = valueArr[1].feb + parseFloat(data2a[keyword + '_02__c']);
                valueArr[1].mar = valueArr[1].mar + parseFloat(data2a[keyword + '_03__c']);
                valueArr[1].apr = valueArr[1].apr + parseFloat(data2a[keyword + '_04__c']);
                valueArr[1].may = valueArr[1].may + parseFloat(data2a[keyword + '_05__c']);
                valueArr[1].jun = valueArr[1].jun + parseFloat(data2a[keyword + '_06__c']);
                valueArr[1].jul = valueArr[1].jul + parseFloat(data2a[keyword + '_07__c']);
                valueArr[1].aug = valueArr[1].aug + parseFloat(data2a[keyword + '_08__c']);
                valueArr[1].sep = valueArr[1].sep + parseFloat(data2a[keyword + '_09__c']);
                valueArr[1].oct = valueArr[1].oct + parseFloat(data2a[keyword + '_10__c']);
                valueArr[1].nov = valueArr[1].nov + parseFloat(data2a[keyword + '_11__c']);
                valueArr[1].dec = valueArr[1].dec + parseFloat(data2a[keyword + '_12__c']);

                if (data2a.Last_Year_Forecast_Cube_1__r != null) {
                    valueArr[1].janLastYear = valueArr[1].janLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_01__c']);
                    valueArr[1].febLastYear = valueArr[1].febLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_02__c']);
                    valueArr[1].marLastYear = valueArr[1].marLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_03__c']);
                    valueArr[1].aprLastYear = valueArr[1].aprLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_04__c']);
                    valueArr[1].mayLastYear = valueArr[1].mayLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_05__c']);
                    valueArr[1].junLastYear = valueArr[1].junLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_06__c']);
                    valueArr[1].julLastYear = valueArr[1].julLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_07__c']);
                    valueArr[1].augLastYear = valueArr[1].augLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_08__c']);
                    valueArr[1].sepLastYear = valueArr[1].sepLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_09__c']);
                    valueArr[1].octLastYear = valueArr[1].octLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_10__c']);
                    valueArr[1].novLastYear = valueArr[1].novLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_11__c']);
                    valueArr[1].decLastYear = valueArr[1].decLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_12__c']);
                }
            }
            
            if (element != null && (element.product == rowType[2] && data2a.Product__r.Remark__c == 'non-CASA')) {
                valueArr[2].jan = valueArr[2].jan + parseFloat(data2a[keyword + '_01__c']);
                valueArr[2].feb = valueArr[2].feb + parseFloat(data2a[keyword + '_02__c']);
                valueArr[2].mar = valueArr[2].mar + parseFloat(data2a[keyword + '_03__c']);
                valueArr[2].apr = valueArr[2].apr + parseFloat(data2a[keyword + '_04__c']);
                valueArr[2].may = valueArr[2].may + parseFloat(data2a[keyword + '_05__c']);
                valueArr[2].jun = valueArr[2].jun + parseFloat(data2a[keyword + '_06__c']);
                valueArr[2].jul = valueArr[2].jul + parseFloat(data2a[keyword + '_07__c']);
                valueArr[2].aug = valueArr[2].aug + parseFloat(data2a[keyword + '_08__c']);
                valueArr[2].sep = valueArr[2].sep + parseFloat(data2a[keyword + '_09__c']);
                valueArr[2].oct = valueArr[2].oct + parseFloat(data2a[keyword + '_10__c']);
                valueArr[2].nov = valueArr[2].nov + parseFloat(data2a[keyword + '_11__c']);
                valueArr[2].dec = valueArr[2].dec + parseFloat(data2a[keyword + '_12__c']);

                if (data2a.Last_Year_Forecast_Cube_1__r != null) {
                    valueArr[2].janLastYear = valueArr[2].janLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_01__c']);
                    valueArr[2].febLastYear = valueArr[2].febLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_02__c']);
                    valueArr[2].marLastYear = valueArr[2].marLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_03__c']);
                    valueArr[2].aprLastYear = valueArr[2].aprLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_04__c']);
                    valueArr[2].mayLastYear = valueArr[2].mayLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_05__c']);
                    valueArr[2].junLastYear = valueArr[2].junLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_06__c']);
                    valueArr[2].julLastYear = valueArr[2].julLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_07__c']);
                    valueArr[2].augLastYear = valueArr[2].augLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_08__c']);
                    valueArr[2].sepLastYear = valueArr[2].sepLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_09__c']);
                    valueArr[2].octLastYear = valueArr[2].octLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_10__c']);
                    valueArr[2].novLastYear = valueArr[2].novLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_11__c']);
                    valueArr[2].decLastYear = valueArr[2].decLastYear + parseFloat(data2a.Last_Year_Forecast_Cube_1__r[keyword + '_12__c']);
                }
            }
        });
    
        return valueArr;
    },

    setValuePercentData: function (component, helper, avg, valueArr, valuePercent, keyword, year) {
        var rowType = helper.getRowType(keyword);
        var dayOfYear = helper.isLeapYear(year) ? 366 : 365;
        var dayOfLastYear = helper.isLeapYear(year - 1) ? 366 : 365;

        valuePercent.forEach(element => {
            if(element != null && element.product == rowType[0]) {
                valuePercent[0].jan = (valueArr[0].jan == 0 || avg[0].jan == 0) ? 0 : (((valueArr[0].jan / avg[0].jan) / 31) * dayOfYear) * 100;
                valuePercent[0].feb = (valueArr[0].feb == 0 || avg[0].feb == 0) ? 0 : (((valueArr[0].feb / avg[0].feb) / (helper.isLeapYear(year) ? 29 : 28)) * dayOfYear) * 100;
                valuePercent[0].mar = (valueArr[0].mar == 0 || avg[0].mar == 0) ? 0 : (((valueArr[0].mar / avg[0].mar) / 31) * dayOfYear) * 100;
                valuePercent[0].apr = (valueArr[0].apr == 0 || avg[0].apr == 0) ? 0 : (((valueArr[0].apr / avg[0].apr) / 30) * dayOfYear) * 100;
                valuePercent[0].may = (valueArr[0].may == 0 || avg[0].may == 0) ? 0 : (((valueArr[0].may / avg[0].may) / 31) * dayOfYear) * 100;
                valuePercent[0].jun = (valueArr[0].jun == 0 || avg[0].jun == 0) ? 0 : (((valueArr[0].jun / avg[0].jun) / 30) * dayOfYear) * 100;
                valuePercent[0].jul = (valueArr[0].jul == 0 || avg[0].jul == 0) ? 0 : (((valueArr[0].jul / avg[0].jul) / 31) * dayOfYear) * 100;
                valuePercent[0].aug = (valueArr[0].aug == 0 || avg[0].aug == 0) ? 0 : (((valueArr[0].aug / avg[0].aug) / 31) * dayOfYear) * 100;
                valuePercent[0].sep = (valueArr[0].sep == 0 || avg[0].sep == 0) ? 0 : (((valueArr[0].sep / avg[0].sep) / 30) * dayOfYear) * 100;
                valuePercent[0].oct = (valueArr[0].oct == 0 || avg[0].oct == 0) ? 0 : (((valueArr[0].oct / avg[0].oct) / 31) * dayOfYear) * 100;
                valuePercent[0].nov = (valueArr[0].nov == 0 || avg[0].nov == 0) ? 0 : (((valueArr[0].nov / avg[0].nov) / 30) * dayOfYear) * 100;
                valuePercent[0].dec = (valueArr[0].dec == 0 || avg[0].dec == 0) ? 0 : (((valueArr[0].dec / avg[0].dec) / 31) * dayOfYear) * 100;
            
                // last year
                valuePercent[0].janLastYear = (valueArr[0].janLastYear == 0 || avg[0].janLastYear == 0) ? 0 : (((valueArr[0].janLastYear / avg[0].janLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].febLastYear = (valueArr[0].febLastYear == 0 || avg[0].febLastYear == 0) ? 0 : (((valueArr[0].febLastYear / avg[0].febLastYear) / (helper.isLeapYear(year - 1) ? 29 : 28)) * dayOfLastYear) * 100;
                valuePercent[0].marLastYear = (valueArr[0].marLastYear == 0 || avg[0].marLastYear == 0) ? 0 : (((valueArr[0].marLastYear / avg[0].marLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].aprLastYear = (valueArr[0].aprLastYear == 0 || avg[0].aprLastYear == 0) ? 0 : (((valueArr[0].aprLastYear / avg[0].aprLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[0].mayLastYear = (valueArr[0].mayLastYear == 0 || avg[0].mayLastYear == 0) ? 0 : (((valueArr[0].mayLastYear / avg[0].mayLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].junLastYear = (valueArr[0].junLastYear == 0 || avg[0].junLastYear == 0) ? 0 : (((valueArr[0].junLastYear / avg[0].junLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[0].julLastYear = (valueArr[0].julLastYear == 0 || avg[0].julLastYear == 0) ? 0 : (((valueArr[0].julLastYear / avg[0].julLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].augLastYear = (valueArr[0].augLastYear == 0 || avg[0].augLastYear == 0) ? 0 : (((valueArr[0].augLastYear / avg[0].augLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].sepLastYear = (valueArr[0].sepLastYear == 0 || avg[0].sepLastYear == 0) ? 0 : (((valueArr[0].sepLastYear / avg[0].sepLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[0].octLastYear = (valueArr[0].octLastYear == 0 || avg[0].octLastYear == 0) ? 0 : (((valueArr[0].octLastYear / avg[0].octLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[0].novLastYear = (valueArr[0].novLastYear == 0 || avg[0].novLastYear == 0) ? 0 : (((valueArr[0].novLastYear / avg[0].novLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[0].decLastYear = (valueArr[0].decLastYear == 0 || avg[0].decLastYear == 0) ? 0 : (((valueArr[0].decLastYear / avg[0].decLastYear) / 31) * dayOfLastYear) * 100;
            }

            if(element != null && element.product == rowType[1]) {
                valuePercent[1].jan = (valueArr[1].jan == 0 || avg[1].jan == 0) ? 0 : (((valueArr[1].jan / avg[1].jan) / 31) * dayOfYear) * 100;
                valuePercent[1].feb = (valueArr[1].feb == 0 || avg[1].feb == 0) ? 0 : (((valueArr[1].feb / avg[1].feb) / (helper.isLeapYear(year) ? 29 : 28)) * dayOfYear) * 100;
                valuePercent[1].mar = (valueArr[1].mar == 0 || avg[1].mar == 0) ? 0 : (((valueArr[1].mar / avg[1].mar) / 31) * dayOfYear) * 100;
                valuePercent[1].apr = (valueArr[1].apr == 0 || avg[1].apr == 0) ? 0 : (((valueArr[1].apr / avg[1].apr) / 30) * dayOfYear) * 100;
                valuePercent[1].may = (valueArr[1].may == 0 || avg[1].may == 0) ? 0 : (((valueArr[1].may / avg[1].may) / 31) * dayOfYear) * 100;
                valuePercent[1].jun = (valueArr[1].jun == 0 || avg[1].jun == 0) ? 0 : (((valueArr[1].jun / avg[1].jun) / 30) * dayOfYear) * 100;
                valuePercent[1].jul = (valueArr[1].jul == 0 || avg[1].jul == 0) ? 0 : (((valueArr[1].jul / avg[1].jul) / 31) * dayOfYear) * 100;
                valuePercent[1].aug = (valueArr[1].aug == 0 || avg[1].aug == 0) ? 0 : (((valueArr[1].aug / avg[1].aug) / 31) * dayOfYear) * 100;
                valuePercent[1].sep = (valueArr[1].sep == 0 || avg[1].sep == 0) ? 0 : (((valueArr[1].sep / avg[1].sep) / 30) * dayOfYear) * 100;
                valuePercent[1].oct = (valueArr[1].oct == 0 || avg[1].oct == 0) ? 0 : (((valueArr[1].oct / avg[1].oct) / 31) * dayOfYear) * 100;
                valuePercent[1].nov = (valueArr[1].nov == 0 || avg[1].nov == 0) ? 0 : (((valueArr[1].nov / avg[1].nov) / 30) * dayOfYear) * 100;
                valuePercent[1].dec = (valueArr[1].dec == 0 || avg[1].dec == 0) ? 0 : (((valueArr[1].dec / avg[1].dec) / 31) * dayOfYear) * 100;

                // last year
                valuePercent[1].janLastYear = (valueArr[1].janLastYear == 0 || avg[1].janLastYear == 0) ? 0 : (((valueArr[1].janLastYear / avg[1].janLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].febLastYear = (valueArr[1].febLastYear == 0 || avg[1].febLastYear == 0) ? 0 : (((valueArr[1].febLastYear / avg[1].febLastYear) / (helper.isLeapYear(year - 1) ? 29 : 28)) * dayOfLastYear) * 100;
                valuePercent[1].marLastYear = (valueArr[1].marLastYear == 0 || avg[1].marLastYear == 0) ? 0 : (((valueArr[1].marLastYear / avg[1].marLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].aprLastYear = (valueArr[1].aprLastYear == 0 || avg[1].aprLastYear == 0) ? 0 : (((valueArr[1].aprLastYear / avg[1].aprLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[1].mayLastYear = (valueArr[1].mayLastYear == 0 || avg[1].mayLastYear == 0) ? 0 : (((valueArr[1].mayLastYear / avg[1].mayLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].junLastYear = (valueArr[1].junLastYear == 0 || avg[1].junLastYear == 0) ? 0 : (((valueArr[1].junLastYear / avg[1].junLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[1].julLastYear = (valueArr[1].julLastYear == 0 || avg[1].julLastYear == 0) ? 0 : (((valueArr[1].julLastYear / avg[1].julLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].augLastYear = (valueArr[1].augLastYear == 0 || avg[1].augLastYear == 0) ? 0 : (((valueArr[1].augLastYear / avg[1].augLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].sepLastYear = (valueArr[1].sepLastYear == 0 || avg[1].sepLastYear == 0) ? 0 : (((valueArr[1].sepLastYear / avg[1].sepLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[1].octLastYear = (valueArr[1].octLastYear == 0 || avg[1].octLastYear == 0) ? 0 : (((valueArr[1].octLastYear / avg[1].octLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[1].novLastYear = (valueArr[1].novLastYear == 0 || avg[1].novLastYear == 0) ? 0 : (((valueArr[1].novLastYear / avg[1].novLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[1].decLastYear = (valueArr[1].decLastYear == 0 || avg[1].decLastYear == 0) ? 0 : (((valueArr[1].decLastYear / avg[1].decLastYear) / 31) * dayOfLastYear) * 100;
            }

            if(element != null && element.product == rowType[2]) {
                valuePercent[2].jan = (valueArr[2].jan == 0 || avg[2].jan == 0) ? 0 : (((valueArr[2].jan / avg[2].jan) / 31) * dayOfYear) * 100;
                valuePercent[2].feb = (valueArr[2].feb == 0 || avg[2].feb == 0) ? 0 : (((valueArr[2].feb / avg[2].feb) / (helper.isLeapYear(year) ? 29 : 28)) * dayOfYear) * 100;
                valuePercent[2].mar = (valueArr[2].mar == 0 || avg[2].mar == 0) ? 0 : (((valueArr[2].mar / avg[2].mar) / 31) * dayOfYear) * 100;
                valuePercent[2].apr = (valueArr[2].apr == 0 || avg[2].apr == 0) ? 0 : (((valueArr[2].apr / avg[2].apr) / 30) * dayOfYear) * 100;
                valuePercent[2].may = (valueArr[2].may == 0 || avg[2].may == 0) ? 0 : (((valueArr[2].may / avg[2].may) / 31) * dayOfYear) * 100;
                valuePercent[2].jun = (valueArr[2].jun == 0 || avg[2].jun == 0) ? 0 : (((valueArr[2].jun / avg[2].jun) / 30) * dayOfYear) * 100;
                valuePercent[2].jul = (valueArr[2].jul == 0 || avg[2].jul == 0) ? 0 : (((valueArr[2].jul / avg[2].jul) / 31) * dayOfYear) * 100;
                valuePercent[2].aug = (valueArr[2].aug == 0 || avg[2].aug == 0) ? 0 : (((valueArr[2].aug / avg[2].aug) / 31) * dayOfYear) * 100;
                valuePercent[2].sep = (valueArr[2].sep == 0 || avg[2].sep == 0) ? 0 : (((valueArr[2].sep / avg[2].sep) / 30) * dayOfYear) * 100;
                valuePercent[2].oct = (valueArr[2].oct == 0 || avg[2].oct == 0) ? 0 : (((valueArr[2].oct / avg[2].oct) / 31) * dayOfYear) * 100;
                valuePercent[2].nov = (valueArr[2].nov == 0 || avg[2].nov == 0) ? 0 : (((valueArr[2].nov / avg[2].nov) / 30) * dayOfYear) * 100;
                valuePercent[2].dec = (valueArr[2].dec == 0 || avg[2].dec == 0) ? 0 : (((valueArr[2].dec / avg[2].dec) / 31) * dayOfYear) * 100;

                // last year
                valuePercent[2].janLastYear = (valueArr[2].janLastYear == 0 || avg[2].janLastYear == 0) ? 0 : (((valueArr[2].janLastYear / avg[2].janLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].febLastYear = (valueArr[2].febLastYear == 0 || avg[2].febLastYear == 0) ? 0 : (((valueArr[2].febLastYear / avg[2].febLastYear) / (helper.isLeapYear(year - 1) ? 29 : 28)) * dayOfLastYear) * 100;
                valuePercent[2].marLastYear = (valueArr[2].marLastYear == 0 || avg[2].marLastYear == 0) ? 0 : (((valueArr[2].marLastYear / avg[2].marLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].aprLastYear = (valueArr[2].aprLastYear == 0 || avg[2].aprLastYear == 0) ? 0 : (((valueArr[2].aprLastYear / avg[2].aprLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[2].mayLastYear = (valueArr[2].mayLastYear == 0 || avg[2].mayLastYear == 0) ? 0 : (((valueArr[2].mayLastYear / avg[2].mayLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].junLastYear = (valueArr[2].junLastYear == 0 || avg[2].junLastYear == 0) ? 0 : (((valueArr[2].junLastYear / avg[2].junLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[2].julLastYear = (valueArr[2].julLastYear == 0 || avg[2].julLastYear == 0) ? 0 : (((valueArr[2].julLastYear / avg[2].julLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].augLastYear = (valueArr[2].augLastYear == 0 || avg[2].augLastYear == 0) ? 0 : (((valueArr[2].augLastYear / avg[2].augLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].sepLastYear = (valueArr[2].sepLastYear == 0 || avg[2].sepLastYear == 0) ? 0 : (((valueArr[2].sepLastYear / avg[2].sepLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[2].octLastYear = (valueArr[2].octLastYear == 0 || avg[2].octLastYear == 0) ? 0 : (((valueArr[2].octLastYear / avg[2].octLastYear) / 31) * dayOfLastYear) * 100;
                valuePercent[2].novLastYear = (valueArr[2].novLastYear == 0 || avg[2].novLastYear == 0) ? 0 : (((valueArr[2].novLastYear / avg[2].novLastYear) / 30) * dayOfLastYear) * 100;
                valuePercent[2].decLastYear = (valueArr[2].decLastYear == 0 || avg[2].decLastYear == 0) ? 0 : (((valueArr[2].decLastYear / avg[2].decLastYear) / 31) * dayOfLastYear) * 100;
            }
        });
    
        return valuePercent;
    },

    setValueTarget: function (component, helper, niBal, totalTarget) {
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        
        var reportYear = parseInt(component.get('v.reportYear'));

        if(reportYear == year) {
            month = today.getMonth();
        } else {
            month = 0;
        }
        if(totalTarget.originFYTarget === '') {
            niBal.originVarianceFull = ''
            niBal.originArchieveFull = ''
            niBal.originFYTargetFull = ''

            niBal.originVariance = ''
            niBal.originArchieve = ''
            niBal.originFYTarget = ''
        } else {
            niBal.originVarianceFull = (month == 0) ? 0 : niBal.ytd - (totalTarget.originFYTarget/12 * month)
            niBal.originArchieveFull = (month == 0 || totalTarget.originFYTarget == 0) ? 0 : (niBal.ytd/(totalTarget.originFYTarget * month / 12)) * 100
            niBal.originFYTargetFull = totalTarget.originFYTarget
    
            niBal.originVariance = (month == 0 || niBal.originVarianceFull == 0) ? 0 : (niBal.originVarianceFull / 10 ** 6).toFixed(2)
            niBal.originArchieve = (month == 0 || niBal.originArchieveFull == 0 || niBal.ytd == 0) ? 0 : (niBal.originArchieveFull / 100)
            niBal.originFYTarget = (niBal.originFYTargetFull == 0 || niBal.originFYTargetFull == null) ? 0 : (niBal.originFYTargetFull / 10 ** 6).toFixed(2)
        }


        if(month >= 3) {
            if(totalTarget.firstTargetFYTarget === '') {
                niBal.firstTargetVarianceFull = ''
                niBal.firstTargetArchieveFull = ''
                niBal.firstTargetFYTargetFull = ''
    
                niBal.firstTargetVariance = ''
                niBal.firstTargetArchieve = ''
                niBal.firstTargetFYTarget = ''
            } else {
                niBal.firstTargetVarianceFull = (month == 0) ? 0 : niBal.ytd - (totalTarget.firstTargetFYTarget/12 * month)
                niBal.firstTargetArchieveFull = (month == 0 || totalTarget.firstTargetFYTarget == 0) ? 0 : (niBal.ytd/(totalTarget.firstTargetFYTarget * month / 12)) * 100
                niBal.firstTargetFYTargetFull = (totalTarget.firstTargetFYTarget == 0 || totalTarget.firstTargetFYTarget == null) ? 0 : totalTarget.firstTargetFYTarget

                niBal.firstTargetVariance = (month == 0 || niBal.firstTargetVarianceFull == 0) ? 0 : (niBal.firstTargetVarianceFull / 10 ** 6).toFixed(2)
                niBal.firstTargetArchieve = (month == 0 || niBal.firstTargetArchieveFull == 0) ? 0 : (niBal.firstTargetArchieveFull / 100)
                niBal.firstTargetFYTarget = (niBal.firstTargetFYTargetFull == 0 || niBal.firstTargetFYTargetFull == null) ? 0 : (niBal.firstTargetFYTargetFull / 10 ** 6).toFixed(2)
            }
        }
        if(month >= 6) {
            if(totalTarget.secondTargetFYTarget === '') {
                niBal.secondTargetVarianceFull = ''
                niBal.secondTargetArchieveFull = ''
                niBal.secondTargetFYTargetFull = ''
    
                niBal.secondTargetVariance = ''
                niBal.secondTargetArchieve = ''
                niBal.secondTargetFYTarget = ''
            } else {
                niBal.secondTargetVarianceFull = (month == 0) ? 0 : niBal.ytd - (totalTarget.secondTargetFYTarget/12 * month)
                niBal.secondTargetArchieveFull = (month == 0 || totalTarget.secondTargetFYTarget == 0) ? 0 : (niBal.ytd/(totalTarget.secondTargetFYTarget * month / 12)) * 100
                niBal.secondTargetFYTargetFull = (totalTarget.secondTargetFYTarget == 0 || totalTarget.secondTargetFYTarget == null) ? 0 : totalTarget.secondTargetFYTarget
    
                niBal.secondTargetVariance = (month == 0 || niBal.secondTargetVarianceFull == 0) ? 0 : (niBal.secondTargetVarianceFull / 10 ** 6).toFixed(2)
                niBal.secondTargetArchieve = (month == 0 || niBal.secondTargetArchieveFull == 0) ? 0 : (niBal.secondTargetArchieveFull / 100)
                niBal.secondTargetFYTarget = (niBal.secondTargetFYTargetFull == 0 || niBal.secondTargetFYTargetFull == null) ? 0 : (niBal.secondTargetFYTargetFull / 10 ** 6).toFixed(2)
            }
        }
        if(month >= 9) {
            if(totalTarget.thirdTargetFYTarget === '') {
                niBal.thirdTargetVarianceFull = ''
                niBal.thirdTargetArchieveFull = ''
                niBal.thirdTargetFYTargetFull = ''
    
                niBal.thirdTargetVariance = ''
                niBal.thirdTargetArchieve = ''
                niBal.thirdTargetFYTarget = ''
            } else {
                niBal.thirdTargetVarianceFull = (month == 0 || totalTarget.thirdTargetFYTarget == 0) ? 0 : niBal.ytd - (totalTarget.thirdTargetFYTarget/12 * month)
                niBal.thirdTargetArchieveFull = (month == 0 || totalTarget.thirdTargetFYTarget == 0) ? 0 : (niBal.ytd/(totalTarget.thirdTargetFYTarget * month / 12)) * 100
                niBal.thirdTargetFYTargetFull = (totalTarget.thirdTargetFYTarget == 0 || totalTarget.thirdTargetFYTarget == null) ? 0 : totalTarget.thirdTargetFYTarget
    
                niBal.thirdTargetVariance = (month == 0 || niBal.thirdTargetVarianceFull == 0) ? 0 : (niBal.thirdTargetVarianceFull / 10 ** 6).toFixed(2)
                niBal.thirdTargetArchieve = (month == 0 || niBal.thirdTargetArchieveFull == 0) ? '' : (niBal.thirdTargetArchieveFull / 100)
                niBal.thirdTargetFYTarget = (niBal.thirdTargetFYTargetFull == 0 || niBal.thirdTargetFYTargetFull == null) ? 0 : (niBal.thirdTargetFYTargetFull / 10 ** 6).toFixed(2)
            }
        }

        return niBal
    },

    valueArrMillionUnit: function(component, helper, valueArr, keyword) {
        var jsonForCSV = component.get('v.jsonForCSV')
        var rowType = helper.getRowType(keyword);
        valueArr.forEach(element => {
            if(keyword.includes('%')) {
                if(element != null && element.product == rowType[0]) {
                    valueArr[0].lastYearMillionUnit = valueArr[0].lastYear == 0 ? 0 : (valueArr[0].lastYear / 100)
                    valueArr[0].janMillionUnit = valueArr[0].jan == 0 ? 0 : (valueArr[0].jan / 100)
                    valueArr[0].febMillionUnit = valueArr[0].feb == 0 ? 0 : (valueArr[0].feb / 100)
                    valueArr[0].marMillionUnit = valueArr[0].mar == 0 ? 0 : (valueArr[0].mar / 100)
                    valueArr[0].aprMillionUnit = valueArr[0].apr == 0 ? 0 : (valueArr[0].apr / 100)
                    valueArr[0].mayMillionUnit = valueArr[0].may == 0 ? 0 : (valueArr[0].may / 100)
                    valueArr[0].junMillionUnit = valueArr[0].jun == 0 ? 0 : (valueArr[0].jun / 100)
                    valueArr[0].julMillionUnit = valueArr[0].jul == 0 ? 0 : (valueArr[0].jul / 100)
                    valueArr[0].augMillionUnit = valueArr[0].aug == 0 ? 0 : (valueArr[0].aug / 100)
                    valueArr[0].sepMillionUnit = valueArr[0].sep == 0 ? 0 : (valueArr[0].sep / 100)
                    valueArr[0].octMillionUnit = valueArr[0].oct == 0 ? 0 : (valueArr[0].oct / 100)
                    valueArr[0].novMillionUnit = valueArr[0].nov == 0 ? 0 : (valueArr[0].nov / 100)
                    valueArr[0].decMillionUnit = valueArr[0].dec == 0 ? 0 : (valueArr[0].dec / 100)
                    valueArr[0].totalMillionUnit = valueArr[0].total == 0 ? 0 : (valueArr[0].total / 100)
                    valueArr[0].ytdMillionUnit = (valueArr[0].ytd == 0 || valueArr[0].ytd == '') ? valueArr[0].ytd : (valueArr[0].ytd / 100);

                    if(valueArr[0].ytd === '') {
                        valueArr[0].yoy = ''
                        valueArr[0].yoyMillionUnit = ''
                    } else {
                        valueArr[0].yoy = (valueArr[0].ytd == 0 || valueArr[0].lastYearActual == 0) ? 0 : ((valueArr[0].ytd / valueArr[0].lastYearActual) * 100);
                        valueArr[0].yoyMillionUnit = (valueArr[0].ytd == 0 || valueArr[0].lastYearActual == 0) ? 0 : (valueArr[0].ytd / valueArr[0].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[0]))
                }
                
                if(element != null && element.product == rowType[1]) {
                    valueArr[1].lastYearMillionUnit = valueArr[1].lastYear == 0 ? 0 : (valueArr[1].lastYear / 100)
                    valueArr[1].janMillionUnit = valueArr[1].jan == 0 ? 0 : (valueArr[1].jan / 100)
                    valueArr[1].febMillionUnit = valueArr[1].feb == 0 ? 0 : (valueArr[1].feb / 100)
                    valueArr[1].marMillionUnit = valueArr[1].mar == 0 ? 0 : (valueArr[1].mar / 100)
                    valueArr[1].aprMillionUnit = valueArr[1].apr == 0 ? 0 : (valueArr[1].apr / 100)
                    valueArr[1].mayMillionUnit = valueArr[1].may == 0 ? 0 : (valueArr[1].may / 100)
                    valueArr[1].junMillionUnit = valueArr[1].jun == 0 ? 0 : (valueArr[1].jun / 100)
                    valueArr[1].julMillionUnit = valueArr[1].jul == 0 ? 0 : (valueArr[1].jul / 100)
                    valueArr[1].augMillionUnit = valueArr[1].aug == 0 ? 0 : (valueArr[1].aug / 100)
                    valueArr[1].sepMillionUnit = valueArr[1].sep == 0 ? 0 : (valueArr[1].sep / 100)
                    valueArr[1].octMillionUnit = valueArr[1].oct == 0 ? 0 : (valueArr[1].oct / 100)
                    valueArr[1].novMillionUnit = valueArr[1].nov == 0 ? 0 : (valueArr[1].nov / 100)
                    valueArr[1].decMillionUnit = valueArr[1].dec == 0 ? 0 : (valueArr[1].dec / 100)
                    valueArr[1].totalMillionUnit = valueArr[1].total == 0 ? 0 : (valueArr[1].total / 100)
                    valueArr[1].ytdMillionUnit = (valueArr[1].ytd == 0 || valueArr[1].ytd == '') ? valueArr[1].ytd : (valueArr[1].ytd / 100);

                    if(valueArr[1].ytd === '') {
                        valueArr[1].yoy = ''
                        valueArr[1].yoyMillionUnit = ''
                    } else {
                        valueArr[1].yoy = (valueArr[1].ytd == 0 || valueArr[1].lastYearActual == 0) ? 0 : ((valueArr[1].ytd / valueArr[1].lastYearActual) * 100);
                        valueArr[1].yoyMillionUnit = (valueArr[1].ytd == 0 || valueArr[1].lastYearActual == 0) ? 0 : (valueArr[1].ytd / valueArr[1].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[1]))
                }
                
                if(element != null && element.product == rowType[2]) {
                    valueArr[2].lastYearMillionUnit = valueArr[2].lastYear == 0 ? 0 : (valueArr[2].lastYear / 100)
                    valueArr[2].janMillionUnit = valueArr[2].jan == 0 ? 0 : (valueArr[2].jan / 100)
                    valueArr[2].febMillionUnit = valueArr[2].feb == 0 ? 0 : (valueArr[2].feb / 100)
                    valueArr[2].marMillionUnit = valueArr[2].mar == 0 ? 0 : (valueArr[2].mar / 100)
                    valueArr[2].aprMillionUnit = valueArr[2].apr == 0 ? 0 : (valueArr[2].apr / 100)
                    valueArr[2].mayMillionUnit = valueArr[2].may == 0 ? 0 : (valueArr[2].may / 100)
                    valueArr[2].junMillionUnit = valueArr[2].jun == 0 ? 0 : (valueArr[2].jun / 100)
                    valueArr[2].julMillionUnit = valueArr[2].jul == 0 ? 0 : (valueArr[2].jul / 100)
                    valueArr[2].augMillionUnit = valueArr[2].aug == 0 ? 0 : (valueArr[2].aug / 100)
                    valueArr[2].sepMillionUnit = valueArr[2].sep == 0 ? 0 : (valueArr[2].sep / 100)
                    valueArr[2].octMillionUnit = valueArr[2].oct == 0 ? 0 : (valueArr[2].oct / 100)
                    valueArr[2].novMillionUnit = valueArr[2].nov == 0 ? 0 : (valueArr[2].nov / 100)
                    valueArr[2].decMillionUnit = valueArr[2].dec == 0 ? 0 : (valueArr[2].dec / 100)
                    valueArr[2].totalMillionUnit = valueArr[2].total == 0 ? 0 : (valueArr[2].total / 100)
                    valueArr[2].ytdMillionUnit = (valueArr[2].ytd == 0 || valueArr[2].ytd == '') ? valueArr[2].ytd : (valueArr[2].ytd / 100);

                    if(valueArr[2].ytd === '') {
                        valueArr[2].yoy = ''
                        valueArr[2].yoyMillionUnit = ''
                    } else {
                        valueArr[2].yoy = (valueArr[2].ytd == 0 || valueArr[2].lastYearActual == 0) ? 0 : ((valueArr[2].ytd / valueArr[2].lastYearActual) * 100);
                        valueArr[2].yoyMillionUnit = (valueArr[2].ytd == 0 || valueArr[2].lastYearActual == 0) ? 0 : (valueArr[2].ytd / valueArr[2].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[2]))
                }
            } else {
                if(element != null && element.product == rowType[0]) {
                    valueArr[0].lastYearMillionUnit = (valueArr[0].lastYear / 10 ** 6).toFixed(2);
                    valueArr[0].janMillionUnit = (valueArr[0].jan / 10 ** 6).toFixed(2);
                    valueArr[0].febMillionUnit = (valueArr[0].feb / 10 ** 6).toFixed(2);
                    valueArr[0].marMillionUnit = (valueArr[0].mar / 10 ** 6).toFixed(2);
                    valueArr[0].aprMillionUnit = (valueArr[0].apr / 10 ** 6).toFixed(2);
                    valueArr[0].mayMillionUnit = (valueArr[0].may / 10 ** 6).toFixed(2);
                    valueArr[0].junMillionUnit = (valueArr[0].jun / 10 ** 6).toFixed(2);
                    valueArr[0].julMillionUnit = (valueArr[0].jul / 10 ** 6).toFixed(2);
                    valueArr[0].augMillionUnit = (valueArr[0].aug / 10 ** 6).toFixed(2);
                    valueArr[0].sepMillionUnit = (valueArr[0].sep / 10 ** 6).toFixed(2);
                    valueArr[0].octMillionUnit = (valueArr[0].oct / 10 ** 6).toFixed(2);
                    valueArr[0].novMillionUnit = (valueArr[0].nov / 10 ** 6).toFixed(2);
                    valueArr[0].decMillionUnit = (valueArr[0].dec / 10 ** 6).toFixed(2);
                    valueArr[0].totalMillionUnit = (valueArr[0].total / 10 ** 6).toFixed(2);
                    valueArr[0].ytdMillionUnit = (valueArr[0].ytd == 0 || valueArr[0].ytd == '') ? valueArr[0].ytd : (valueArr[0].ytd / 10 ** 6).toFixed(2);

                    if(valueArr[0].ytd === '') {
                        valueArr[0].yoy = ''
                        valueArr[0].yoyMillionUnit = ''
                    } else {
                        valueArr[0].yoy = (valueArr[0].ytd == 0 || valueArr[0].lastYearActual == 0) ? 0 : ((valueArr[0].ytd / valueArr[0].lastYearActual) * 100);
                        valueArr[0].yoyMillionUnit = (valueArr[0].ytd == 0 || valueArr[0].lastYearActual == 0) ? 0 : (valueArr[0].ytd / valueArr[0].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[0]))
                }
                
                if(element != null && element.product == rowType[1]) {
                    valueArr[1].lastYearMillionUnit = (valueArr[1].lastYear / 10 ** 6).toFixed(2);
                    valueArr[1].janMillionUnit = (valueArr[1].jan / 10 ** 6).toFixed(2);
                    valueArr[1].febMillionUnit = (valueArr[1].feb / 10 ** 6).toFixed(2);
                    valueArr[1].marMillionUnit = (valueArr[1].mar / 10 ** 6).toFixed(2);
                    valueArr[1].aprMillionUnit = (valueArr[1].apr / 10 ** 6).toFixed(2);
                    valueArr[1].mayMillionUnit = (valueArr[1].may / 10 ** 6).toFixed(2);
                    valueArr[1].junMillionUnit = (valueArr[1].jun / 10 ** 6).toFixed(2);
                    valueArr[1].julMillionUnit = (valueArr[1].jul / 10 ** 6).toFixed(2);
                    valueArr[1].augMillionUnit = (valueArr[1].aug / 10 ** 6).toFixed(2);
                    valueArr[1].sepMillionUnit = (valueArr[1].sep / 10 ** 6).toFixed(2);
                    valueArr[1].octMillionUnit = (valueArr[1].oct / 10 ** 6).toFixed(2);
                    valueArr[1].novMillionUnit = (valueArr[1].nov / 10 ** 6).toFixed(2);
                    valueArr[1].decMillionUnit = (valueArr[1].dec / 10 ** 6).toFixed(2);
                    valueArr[1].totalMillionUnit = (valueArr[1].total / 10 ** 6).toFixed(2);
                    valueArr[1].ytdMillionUnit = (valueArr[1].ytd == 0 || valueArr[1].ytd == '') ? valueArr[1].ytd : (valueArr[1].ytd / 10 ** 6).toFixed(2);

                    if(valueArr[1].ytd === '') {
                        valueArr[1].yoy = ''
                        valueArr[1].yoyMillionUnit = ''
                    } else {
                        valueArr[1].yoy = (valueArr[1].ytd == 0 || valueArr[1].lastYearActual == 0) ? 0 : ((valueArr[1].ytd / valueArr[1].lastYearActual) * 100);
                        valueArr[1].yoyMillionUnit = (valueArr[1].ytd == 0 || valueArr[1].lastYearActual == 0) ? 0 : (valueArr[1].ytd / valueArr[1].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[1]))
                }
                
                if(element != null && element.product == rowType[2]) {
                    valueArr[2].lastYearMillionUnit = (valueArr[2].lastYear / 10 ** 6).toFixed(2);
                    valueArr[2].janMillionUnit = (valueArr[2].jan / 10 ** 6).toFixed(2);
                    valueArr[2].febMillionUnit = (valueArr[2].feb / 10 ** 6).toFixed(2);
                    valueArr[2].marMillionUnit = (valueArr[2].mar / 10 ** 6).toFixed(2);
                    valueArr[2].aprMillionUnit = (valueArr[2].apr / 10 ** 6).toFixed(2);
                    valueArr[2].mayMillionUnit = (valueArr[2].may / 10 ** 6).toFixed(2);
                    valueArr[2].junMillionUnit = (valueArr[2].jun / 10 ** 6).toFixed(2);
                    valueArr[2].julMillionUnit = (valueArr[2].jul / 10 ** 6).toFixed(2);
                    valueArr[2].augMillionUnit = (valueArr[2].aug / 10 ** 6).toFixed(2);
                    valueArr[2].sepMillionUnit = (valueArr[2].sep / 10 ** 6).toFixed(2);
                    valueArr[2].octMillionUnit = (valueArr[2].oct / 10 ** 6).toFixed(2);
                    valueArr[2].novMillionUnit = (valueArr[2].nov / 10 ** 6).toFixed(2);
                    valueArr[2].decMillionUnit = (valueArr[2].dec / 10 ** 6).toFixed(2);
                    valueArr[2].totalMillionUnit = (valueArr[2].total / 10 ** 6).toFixed(2);
                    valueArr[2].ytdMillionUnit = (valueArr[2].ytd == 0 || valueArr[2].ytd == '') ? valueArr[2].ytd : (valueArr[2].ytd / 10 ** 6).toFixed(2);

                    if(valueArr[2].ytd === '') {
                        valueArr[2].yoy = ''
                        valueArr[2].yoyMillionUnit = ''
                    } else {
                        valueArr[2].yoy = (valueArr[2].ytd == 0 || valueArr[2].lastYearActual == 0) ? 0 : ((valueArr[2].ytd / valueArr[2].lastYearActual) * 100);
                        valueArr[2].yoyMillionUnit = (valueArr[2].ytd == 0 || valueArr[2].lastYearActual == 0) ? 0 : (valueArr[2].ytd / valueArr[2].lastYearActual);
                    }
                    jsonForCSV = jsonForCSV.concat(helper.setJSONData(component, helper, valueArr[2]))
                }
            }
        });
        component.set('v.jsonForCSV', jsonForCSV)
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
    setJSONData: function (component, helper, element) {
        var userProfile = component.get('v.userProfile');
        var team = component.get('v.team');
        var rm = component.get('v.rm');
        var today  = new Date();
        var month = today.getMonth();
        var year = today.getFullYear();
        
        var reportYear = parseInt(component.get('v.reportYear'));
    
        if(reportYear == year) {
          month = today.getMonth();
        } else {
            month = 0;
        }
    
        var totalColumn = 'Y' + reportYear + ' (FC)'
        var lastYearColumn = 'Lastyear (' + (reportYear - 1) + ')'

        if(reportYear != year) {
            month = 0;
        }
        var monthName = month == 0 ? '' : helper.getMonthName(month - 1, 'full');
        var ytdColumn = 'YTD ' + (monthName == '' ? '' : '(As of ' + monthName + ')');
        
        var monthsColumn = []

        for (let i = 0; i < 12; i++) {
            // monthsColumn[i] = 
            if(reportYear == year) {
                if (i < month) {
                    monthsColumn[i] = helper.getMonthName(i, 'short').concat(' (A)');
                } else {
                    monthsColumn[i] = helper.getMonthName(i, 'short').concat(' (E)');
                }
            } else if(reportYear > year) {
                monthsColumn[i] = helper.getMonthName(i, 'short').concat(' (E)');
            } else {
                monthsColumn[i] = helper.getMonthName(i, 'short').concat(' (A)');
            }
        }

        var obj = {}
        obj['Team'] = team
        // if (userProfile != 'GroupHead' && userProfile != 'System Administrator') {
          obj['RM'] = rm
        // }
        obj['Product'] = element.product
        if (element.isPercent == true) {
            obj[lastYearColumn] = helper.numberWithDecimal(element.lastYearMillionUnit * 100) + '%'
            obj[monthsColumn[0]] = helper.numberWithDecimal(element.janMillionUnit * 100) + '%'
            obj[monthsColumn[1]] = helper.numberWithDecimal(element.febMillionUnit * 100) + '%'
            obj[monthsColumn[2]] = helper.numberWithDecimal(element.marMillionUnit * 100) + '%'
            obj[monthsColumn[3]] = helper.numberWithDecimal(element.aprMillionUnit * 100) + '%'
            obj[monthsColumn[4]] = helper.numberWithDecimal(element.mayMillionUnit * 100) + '%'
            obj[monthsColumn[5]] = helper.numberWithDecimal(element.junMillionUnit * 100) + '%'
            obj[monthsColumn[6]] = helper.numberWithDecimal(element.julMillionUnit * 100) + '%'
            obj[monthsColumn[7]] = helper.numberWithDecimal(element.augMillionUnit * 100) + '%'
            obj[monthsColumn[8]] = helper.numberWithDecimal(element.sepMillionUnit * 100) + '%'
            obj[monthsColumn[9]] = helper.numberWithDecimal(element.octMillionUnit * 100) + '%'
            obj[monthsColumn[10]] = helper.numberWithDecimal(element.novMillionUnit * 100) + '%'
            obj[monthsColumn[11]] = helper.numberWithDecimal(element.decMillionUnit * 100) + '%'
            obj[totalColumn] = helper.numberWithDecimal(element.totalMillionUnit * 100) + '%'
            obj[ytdColumn] = (element.ytd === '') ? '' : helper.numberWithDecimal(element.ytd)
        } else {
          obj[lastYearColumn] = helper.numberWithDecimal(element.lastYear)
          obj[monthsColumn[0]] = helper.numberWithDecimal(element.jan)
          obj[monthsColumn[1]] = helper.numberWithDecimal(element.feb)
          obj[monthsColumn[2]] = helper.numberWithDecimal(element.mar)
          obj[monthsColumn[3]] = helper.numberWithDecimal(element.apr)
          obj[monthsColumn[4]] = helper.numberWithDecimal(element.may)
          obj[monthsColumn[5]] = helper.numberWithDecimal(element.jun)
          obj[monthsColumn[6]] = helper.numberWithDecimal(element.jul)
          obj[monthsColumn[7]] = helper.numberWithDecimal(element.aug)
          obj[monthsColumn[8]] = helper.numberWithDecimal(element.sep)
          obj[monthsColumn[9]] = helper.numberWithDecimal(element.oct)
          obj[monthsColumn[10]] = helper.numberWithDecimal(element.nov)
          obj[monthsColumn[11]] = helper.numberWithDecimal(element.dec)
          obj[totalColumn] = helper.numberWithDecimal(element.total)
          obj[ytdColumn] = helper.numberWithDecimal(element.ytd)
        }
        obj['%YOY'] = (element.yoyMillionUnit === '') ? '' : helper.numberWithDecimal(element.yoyMillionUnit * 100) + '%'
    
        if (userProfile == 'GroupHead' || userProfile == 'System Administrator') {
            obj['Original target (' + reportYear + '): Variance'] = (element.product != 'NIId' || element.originVarianceFull ==='') ? '' : helper.numberWithDecimal(element.originVarianceFull)
            obj['Original target (' + reportYear + '): % Archieve (YTD)'] = (element.product != 'NIId' || element.originArchieve === '') ? '' : helper.numberWithDecimal(element.originArchieve * 100) + '%'
            obj['Original target (' + reportYear + '): FY Target'] = (element.product != 'NIId' || element.originFYTargetFull ==='') ? '' : helper.numberWithDecimal(element.originFYTargetFull)
            if (month >= 3) {
              obj['3+9F target(' + reportYear + '): Variance'] = (element.product != 'NIId' || element.firstTargetVarianceFull === '') ? '' : helper.numberWithDecimal(element.firstTargetVarianceFull)
              obj['3+9F target (' + reportYear + '): % Archieve (YTD)'] = (element.product != 'NIId' || element.firstTargetArchieve === '') ? '' : helper.numberWithDecimal(element.firstTargetArchieve * 100) + '%'
              obj['3+9F target (' + reportYear + '): FY Target'] = (element.product != 'NIId' || element.firstTargetFYTargetFull === '') ? '' : helper.numberWithDecimal(element.firstTargetFYTargetFull)
            }
            if (month >= 6) {
              obj['6+6F target(' + reportYear + '): Variance'] = (element.product != 'NIId' || element.secondTargetVarianceFull === '') ? '' : helper.numberWithDecimal(element.secondTargetVarianceFull)
              obj['6+6F target (' + reportYear + '): % Archieve (YTD)'] = (element.product != 'NIId' || element.secondTargetArchieve === '') ? '' : helper.numberWithDecimal(element.secondTargetArchieve * 100) + '%'
              obj['6+6F target (' + reportYear + '): FY Target'] = (element.product != 'NIId' || element.secondTargetFYTargetFull === '') ? '' : helper.numberWithDecimal(element.secondTargetFYTargetFull)
            }
            if (month >= 9) {
              obj['9+3F target(' + reportYear + '): Variance'] = (element.product != 'NIId' || element.thirdTargetVarianceFull === '') ? '' : helper.numberWithDecimal(element.thirdTargetVarianceFull)
              obj['9+3F target (' + reportYear + '): % Archieve (YTD)'] = (element.product != 'NIId' || element.thirdTargetArchieve === '') ? '' : helper.numberWithDecimal(element.thirdTargetArchieve * 100) + '%'
              obj['9+3F target (' + reportYear + '): FY Target'] = (element.product != 'NIId' || element.thirdTargetFYTargetFull === '') ? '' : helper.numberWithDecimal(element.thirdTargetFYTargetFull)
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
})