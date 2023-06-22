({
	parseObj: function (objFields) {
		return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
	},

	prioritySorting: function (dataArray, priorityProduct) {
		
		var mapProduct = new Map();
		var dataSortArray= new Array();
		priorityProduct.forEach((product) => {
			mapProduct.set(product.MasterLabel , product.Priority__c);
		});
		dataArray.forEach((data) => {
			if(mapProduct.get(data.Product__Financial_Product_Group_Name__c)){
				data["Priority__c"] = mapProduct.get(data.Product__Financial_Product_Group_Name__c);
				dataSortArray.push(data);
			}
		});

		dataSortArray.sort(function (a, b) {
			return a.Priority__c - b.Priority__c;
		});
		
		return dataSortArray;
	},	
	setJSONData: function (component, helper, element, team, rm ,year) {
		var monthsColumn = []
		var today = new Date();
		var yesterday = new Date();
		yesterday.setDate(yesterday.getDate() - 1);
		if(year == today.getFullYear()) {
			var ActualEndingBalance = (yesterday.getDate()).toString() + ' ' + helper.getShortMonthName(yesterday.getMonth()) + '\'' + (yesterday.getFullYear()).toString().slice(-2)
			var ProjectedEndingBalance = helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2)
			var Variance = helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2)
			var MTD = helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2)
			var MoM = helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2)
			var YTD = helper.getShortMonthName(today.getMonth()) + '\'' + (year).toString().slice(-2)
		}

		for (let i = 0; i < 12; i++) {
			// monthsColumn[i] = 
			if(year == today.getFullYear()) {
				if (i < today.getMonth()) {
					monthsColumn[i] = helper.getShortMonthName(i).concat(' (A)');
				} else {
					monthsColumn[i] = helper.getShortMonthName(i).concat(' (E)');
				}
			} else if(year > today.getFullYear()) {
				monthsColumn[i] = helper.getShortMonthName(i).concat(' (E)');
			} else {
				monthsColumn[i] = helper.getShortMonthName(i).concat(' (A)');
			}
		}
        
		var obj = {}
		obj['Team'] = team
		obj['RM'] = rm
		obj['Product Group'] = element.Product__Financial_Product_Group_Name__c == null ? element.Product_Group : element.Product__Financial_Product_Group_Name__c
		obj['Limit'] = element.Financial_Product_Domain__c == 'Deposit' ? '' : helper.numberWithDecimal(element.Limit__c)
        obj['Ending Balance LastYear ('+ (year - 1) +')'] = element.Last_Year_Ending__c ? helper.numberWithDecimal(element.Last_Year_Ending__c) : ''
		obj['Ending Balance: ' + monthsColumn[0]] = helper.numberWithDecimal(element.Ending_Balance_01__c)
		obj['Ending Balance: ' + monthsColumn[1]] = helper.numberWithDecimal(element.Ending_Balance_02__c)
		obj['Ending Balance: ' + monthsColumn[2]] = helper.numberWithDecimal(element.Ending_Balance_03__c)
		obj['Ending Balance: ' + monthsColumn[3]] = helper.numberWithDecimal(element.Ending_Balance_04__c)
		obj['Ending Balance: ' + monthsColumn[4]] = helper.numberWithDecimal(element.Ending_Balance_05__c)
		obj['Ending Balance: ' + monthsColumn[5]] = helper.numberWithDecimal(element.Ending_Balance_06__c)
		obj['Ending Balance: ' + monthsColumn[6]] = helper.numberWithDecimal(element.Ending_Balance_07__c)
		obj['Ending Balance: ' + monthsColumn[7]] = helper.numberWithDecimal(element.Ending_Balance_08__c)
		obj['Ending Balance: ' + monthsColumn[8]] = helper.numberWithDecimal(element.Ending_Balance_09__c)
		obj['Ending Balance: ' + monthsColumn[9]] = helper.numberWithDecimal(element.Ending_Balance_10__c)
		obj['Ending Balance: ' + monthsColumn[10]] = helper.numberWithDecimal(element.Ending_Balance_11__c)
		obj['Ending Balance: ' + monthsColumn[11]] = helper.numberWithDecimal(element.Ending_Balance_12__c)
		if(year == today.getFullYear()) {
			obj['Ending Balance Actual (' + ActualEndingBalance + ')'] = helper.numberWithDecimal(element.Current_Balance__c)
			obj['Ending Balance Projected (' + ProjectedEndingBalance + ')'] = helper.numberWithDecimal(element.Projection__c)
			obj['Variance (' + Variance + ')'] = helper.numberWithDecimal(element.Variance__c)
			obj['MTD (' + MTD + ')'] = helper.numberWithDecimal(element.MTD__c)
			obj['MOM (' + MoM + ')'] = helper.numberWithDecimal(element.MoM__c)
			obj['YTD (' + YTD + ')'] = helper.numberWithDecimal(element.YTD__c)
		} else {
			obj['Ending Balance Actual'] = helper.numberWithDecimal(element.Current_Balance__c)
			obj['Ending Balance Projected'] = helper.numberWithDecimal(element.Projection__c)
			obj['Variance'] = (element.Variance__c)
			obj['MTD'] = helper.numberWithDecimal(element.MTD__c)
			obj['MOM'] = helper.numberWithDecimal(element.MoM__c)
			obj['YTD'] = helper.numberWithDecimal(element.YTD__c)
		}
		obj['Utilized (%)'] = (element.Utilized == null || element.Financial_Product_Domain__c == 'Deposit') ? '' : helper.numberWithDecimal(element.Utilized * 100) + '%'
		
		return obj
	},

	getShortMonthName : function(monthNumber){
        var shortMonthName =[
            'Jan' ,'Feb' , 'Mar' , 'Apr' , 'May' , 'Jun' ,'Jul' ,'Aug','Sep','Oct','Nov','Dec'
        ]
        return shortMonthName[monthNumber];
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