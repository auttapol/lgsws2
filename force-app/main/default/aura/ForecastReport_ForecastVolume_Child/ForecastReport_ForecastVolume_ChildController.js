({
    onInit : function(component, event, helper) {
        var groupingByRMObj = helper.parseObj(component.get('v.groupingByRM')) != null ? helper.parseObj(component.get('v.groupingByRM')) : helper.parseObj(component.get('v.groupingByTeam')) != null ? helper.parseObj(component.get('v.groupingByTeam')) : helper.parseObj(component.get('v.groupingByReg'));
        var lastYearData = groupingByRMObj.LYData;
        var groupingByRM = groupingByRMObj.data;
        var priorityProduct = component.get('v.priorityProduct');
        var userProfile = component.get('v.userProfile');
        var tempGroupCube = [];
        let mapGroupCube = new Map();
        var onlyCreditCurrent = 0;
        var team = groupingByRM[0].Customer__r.Owner != null ? groupingByRM[0].Customer__r.Owner.Zone__c : '';
        var rm =  groupingByRM[0].Customer__r.Owner != null ? groupingByRM[0].Customer__r.Owner.Name : '';
        var jsonForCSV = []

        var totalRow = {
            RM_Name : groupingByRM[0].Customer__r.Owner.Name,
            regionName : groupingByRM[0].Customer__r.Owner.Region__c,
            OwnerId : groupingByRM[0].Customer__r.OwnerId,
            Team_Code__c : groupingByRM[0].Customer__r.Owner.Zone__c,
            Product_Group : 'Total (Exclude LG & TF lia)',
            Limit__c : 0 ,
            Last_Year_Ending__c : 0 ,
            Ending_Balance_01__c : 0 ,
            Ending_Balance_02__c : 0 ,
            Ending_Balance_03__c : 0 ,
            Ending_Balance_04__c : 0 ,
            Ending_Balance_05__c : 0 ,
            Ending_Balance_06__c : 0 ,
            Ending_Balance_07__c : 0 ,
            Ending_Balance_08__c : 0 ,
            Ending_Balance_09__c : 0 ,
            Ending_Balance_10__c : 0 ,
            Ending_Balance_11__c : 0 ,
            Ending_Balance_12__c : 0 ,
            Current_Balance__c : 0 ,
            Projection__c : 0 ,
            Variance__c : 0 ,
            MTD__c : 0 ,
            MoM__c : 0 ,
            YTD__c : 0 ,

        };

        // var tempCube = {
        //     RM_Name : groupingByRM[0].Customer__r.Owner.Name,
        //     regionName : groupingByRM[0].Customer__r.Owner.Region__c,
        //     OwnerId : groupingByRM[0].Customer__r.OwnerId,
        //     Team_Code__c : groupingByRM[0].Customer__r.Owner.Zone__c,
        //     Limit__c : 0 ,
        //     Last_Year_Ending__c : 0 ,
        //     Ending_Balance_01__c : 0 ,
        //     Ending_Balance_02__c : 0 ,
        //     Ending_Balance_03__c : 0 ,
        //     Ending_Balance_04__c : 0 ,
        //     Ending_Balance_05__c : 0 ,
        //     Ending_Balance_06__c : 0 ,
        //     Ending_Balance_07__c : 0 ,
        //     Ending_Balance_08__c : 0 ,
        //     Ending_Balance_09__c : 0 ,
        //     Ending_Balance_10__c : 0 ,
        //     Ending_Balance_11__c : 0 ,
        //     Ending_Balance_12__c : 0 ,
        //     Current_Balance__c : 0 ,
        //     Projection__c : 0 ,
        //     Variance__c : 0 ,
        //     MTD__c : 0 ,
        //     MoM__c : 0 ,
        //     YTD__c : 0 ,

        // };

        // LY
        if(lastYearData != null){
            lastYearData.forEach(LYData => {
                if (LYData) {
                    var tempCube = mapGroupCube.has(LYData.Product__r.Financial_Product_Group_Name__c) ? mapGroupCube.get(LYData.Product__r.Financial_Product_Group_Name__c) : {};
                    tempCube['Last_Year_Ending__c'] = tempCube['Last_Year_Ending__c'] != null ? (parseFloat(tempCube['Last_Year_Ending__c']) + (LYData.Ending_Balance_12__c )) : (LYData.Ending_Balance_12__c);
                    tempCube['RM__Name'] = LYData.Customer__r.Owner.Name;
                    tempCube['Team_Code__c'] = LYData.Customer__r.Owner.Zone__c ;
                    tempCube['OwnerId'] = LYData.Customer__r.OwnerId ;
                    tempCube['Product__Financial_Product_Group_Name__c'] = LYData.Product__r.Financial_Product_Group_Name__c;
                    tempCube['Financial_Product_Domain__c'] = LYData.Product__r.Financial_Product_Domain__c
                    if(LYData.Product__r.Forecast_NIIc_NIId_Flag__c ){
                    totalRow.Last_Year_Ending__c += LYData.Ending_Balance_12__c;
                    }
                    tempCube['isHaveSelectedYear'] = tempCube['isHaveSelectedYear'] ? tempCube['isHaveSelectedYear'] : false ;
                    mapGroupCube.set(LYData.Product__r.Financial_Product_Group_Name__c, tempCube);
                    
                }
                else{
                    totalRow.Last_Year_Ending__c ? totalRow.Last_Year_Ending__c = totalRow.Last_Year_Ending__c : totalRow.Last_Year_Ending__c = 0;

                }
            });
        }

        for(var i = 0 ; i < groupingByRM.length ; i++){
            var tempCube = mapGroupCube.has(groupingByRM[i].Product__r.Financial_Product_Group_Name__c) ? mapGroupCube.get(groupingByRM[i].Product__r.Financial_Product_Group_Name__c) : {};
            tempCube['RM__Name'] = groupingByRM[i].Customer__r.Owner.Name;
            tempCube['Team_Code__c'] = groupingByRM[i].Customer__r.Owner.Zone__c ;
            tempCube['OwnerId'] = groupingByRM[i].Customer__r.OwnerId ;
            tempCube['Product__Financial_Product_Group_Name__c'] = groupingByRM[i].Product__r.Financial_Product_Group_Name__c;
            tempCube['Financial_Product_Domain__c'] = groupingByRM[i].Product__r.Financial_Product_Domain__c
            tempCube['isHaveSelectedYear'] = true;
            tempCube['Limit__c'] = tempCube['Limit__c'] != null ? (parseFloat(tempCube['Limit__c']) + (groupingByRM[i].Limit__c )) : (groupingByRM[i].Limit__c );
            tempCube['Ending_Balance_01__c'] = tempCube['Ending_Balance_01__c'] != null ? (parseFloat(tempCube['Ending_Balance_01__c']) + (groupingByRM[i].Ending_Balance_01__c )) : (groupingByRM[i].Ending_Balance_01__c);
            tempCube['Ending_Balance_02__c'] = tempCube['Ending_Balance_02__c'] != null ? (parseFloat(tempCube['Ending_Balance_02__c']) + (groupingByRM[i].Ending_Balance_02__c )) : (groupingByRM[i].Ending_Balance_02__c);
            tempCube['Ending_Balance_03__c'] = tempCube['Ending_Balance_03__c'] != null ? (parseFloat(tempCube['Ending_Balance_03__c']) + (groupingByRM[i].Ending_Balance_03__c )) : (groupingByRM[i].Ending_Balance_03__c);
            tempCube['Ending_Balance_04__c'] = tempCube['Ending_Balance_04__c'] != null ? (parseFloat(tempCube['Ending_Balance_04__c']) + (groupingByRM[i].Ending_Balance_04__c )) : (groupingByRM[i].Ending_Balance_04__c);
            tempCube['Ending_Balance_05__c'] = tempCube['Ending_Balance_05__c'] != null ? (parseFloat(tempCube['Ending_Balance_05__c']) + (groupingByRM[i].Ending_Balance_05__c )) : (groupingByRM[i].Ending_Balance_05__c);
            tempCube['Ending_Balance_06__c'] = tempCube['Ending_Balance_06__c'] != null ? (parseFloat(tempCube['Ending_Balance_06__c']) + (groupingByRM[i].Ending_Balance_06__c )) : (groupingByRM[i].Ending_Balance_06__c);
            tempCube['Ending_Balance_07__c'] = tempCube['Ending_Balance_07__c'] != null ? (parseFloat(tempCube['Ending_Balance_07__c']) + (groupingByRM[i].Ending_Balance_07__c )) : (groupingByRM[i].Ending_Balance_07__c);
            tempCube['Ending_Balance_08__c'] = tempCube['Ending_Balance_08__c'] != null ? (parseFloat(tempCube['Ending_Balance_08__c']) + (groupingByRM[i].Ending_Balance_08__c )) : (groupingByRM[i].Ending_Balance_08__c);
            tempCube['Ending_Balance_09__c'] = tempCube['Ending_Balance_09__c'] != null ? (parseFloat(tempCube['Ending_Balance_09__c']) + (groupingByRM[i].Ending_Balance_09__c )) : (groupingByRM[i].Ending_Balance_09__c);
            tempCube['Ending_Balance_10__c'] = tempCube['Ending_Balance_10__c'] != null ? (parseFloat(tempCube['Ending_Balance_10__c']) + (groupingByRM[i].Ending_Balance_10__c )) : (groupingByRM[i].Ending_Balance_10__c);
            tempCube['Ending_Balance_11__c'] = tempCube['Ending_Balance_11__c'] != null ? (parseFloat(tempCube['Ending_Balance_11__c']) + (groupingByRM[i].Ending_Balance_11__c )) : (groupingByRM[i].Ending_Balance_11__c);
            tempCube['Ending_Balance_12__c'] = tempCube['Ending_Balance_12__c'] != null ? (parseFloat(tempCube['Ending_Balance_12__c']) + (groupingByRM[i].Ending_Balance_12__c )) : (groupingByRM[i].Ending_Balance_12__c);
            tempCube['Current_Balance__c'] = tempCube['Current_Balance__c'] != null ? (parseFloat(tempCube['Current_Balance__c']) + (groupingByRM[i].Current_Balance__c )) : (groupingByRM[i].Current_Balance__c);
            tempCube['Projection__c'] = tempCube['Projection__c'] != null ? (parseFloat(tempCube['Projection__c']) + (groupingByRM[i].Projection__c )) : (groupingByRM[i].Projection__c);
            tempCube['Variance__c'] = tempCube['Variance__c'] != null ? (parseFloat(tempCube['Variance__c']) + (groupingByRM[i].Variance__c )) : (groupingByRM[i].Variance__c);
            tempCube['MTD__c'] = tempCube['MTD__c'] != null ? (parseFloat(tempCube['MTD__c']) + (groupingByRM[i].MTD__c )) : (groupingByRM[i].MTD__c);
            tempCube['MoM__c'] = tempCube['MoM__c'] != null ? (parseFloat(tempCube['MoM__c']) + (groupingByRM[i].MoM__c )) : (groupingByRM[i].MoM__c);
            tempCube['Utilized'] = tempCube.Limit__c != 0 ? parseFloat(tempCube.Current_Balance__c) / parseFloat(tempCube.Limit__c) : 0;

            if(groupingByRM[i].Product__r.Forecast_NIIc_NIId_Flag__c ){
                totalRow.Limit__c += groupingByRM[i].Limit__c;
                totalRow.Ending_Balance_01__c += groupingByRM[i].Ending_Balance_01__c;
                totalRow.Ending_Balance_02__c += groupingByRM[i].Ending_Balance_02__c;
                totalRow.Ending_Balance_03__c += groupingByRM[i].Ending_Balance_03__c;
                totalRow.Ending_Balance_04__c += groupingByRM[i].Ending_Balance_04__c;
                totalRow.Ending_Balance_05__c += groupingByRM[i].Ending_Balance_05__c;
                totalRow.Ending_Balance_06__c += groupingByRM[i].Ending_Balance_06__c;
                totalRow.Ending_Balance_07__c += groupingByRM[i].Ending_Balance_07__c;
                totalRow.Ending_Balance_08__c += groupingByRM[i].Ending_Balance_08__c;
                totalRow.Ending_Balance_09__c += groupingByRM[i].Ending_Balance_09__c;
                totalRow.Ending_Balance_10__c += groupingByRM[i].Ending_Balance_10__c;
                totalRow.Ending_Balance_11__c += groupingByRM[i].Ending_Balance_11__c;
                totalRow.Ending_Balance_12__c += groupingByRM[i].Ending_Balance_12__c;
                totalRow.Current_Balance__c += groupingByRM[i].Current_Balance__c;
                onlyCreditCurrent += groupingByRM[i].Product__r.Financial_Product_Domain__c == 'Credit' ? groupingByRM[i].Current_Balance__c: 0;
                totalRow.Projection__c += groupingByRM[i].Projection__c;
                totalRow.Variance__c += groupingByRM[i].Variance__c;
                totalRow.MTD__c += groupingByRM[i].MTD__c;
                totalRow.MoM__c += groupingByRM[i].MoM__c;
            }
            
            mapGroupCube.set(groupingByRM[i].Product__r.Financial_Product_Group_Name__c, tempCube);
        }

        var showTempCube = [];
        var year =component.get('v.year');
        var today = new Date();
        var isNextYear = year > today.getFullYear();
        mapGroupCube.forEach(function(value, key) {
            if(value.isHaveSelectedYear){
                value['YTD__c'] = value.Last_Year_Ending__c ? value.Current_Balance__c -  value.Last_Year_Ending__c : value.Current_Balance__c;

                value.YTD__c = isNextYear ? '' : value.YTD__c;
                tempGroupCube.push(value);
                var inMillion={};
                value.Limit__c ? inMillion['Limit_inBaht'] = helper.numberWithCommas(value.Limit__c) : inMillion['Limit_inBaht'] = helper.numberWithCommas(0) ;
                value.Last_Year_Ending__c ?  inMillion['Last_Year_Ending_inBaht'] = helper.numberWithCommas(value.Last_Year_Ending__c) : inMillion['Last_Year_Ending_inBaht'] = helper.numberWithCommas(0);
                inMillion['Ending_Balance_01_inBaht'] = helper.numberWithCommas(value.Ending_Balance_01__c);
                inMillion['Ending_Balance_02_inBaht'] = helper.numberWithCommas(value.Ending_Balance_02__c);
                inMillion['Ending_Balance_03_inBaht'] = helper.numberWithCommas(value.Ending_Balance_03__c);
                inMillion['Ending_Balance_04_inBaht'] = helper.numberWithCommas(value.Ending_Balance_04__c);
                inMillion['Ending_Balance_05_inBaht'] = helper.numberWithCommas(value.Ending_Balance_05__c);
                inMillion['Ending_Balance_06_inBaht'] = helper.numberWithCommas(value.Ending_Balance_06__c);
                inMillion['Ending_Balance_07_inBaht'] = helper.numberWithCommas(value.Ending_Balance_07__c);
                inMillion['Ending_Balance_08_inBaht'] = helper.numberWithCommas(value.Ending_Balance_08__c);
                inMillion['Ending_Balance_09_inBaht'] = helper.numberWithCommas(value.Ending_Balance_09__c);
                inMillion['Ending_Balance_10_inBaht'] = helper.numberWithCommas(value.Ending_Balance_10__c);
                inMillion['Ending_Balance_11_inBaht'] = helper.numberWithCommas(value.Ending_Balance_11__c);
                inMillion['Ending_Balance_12_inBaht'] = helper.numberWithCommas(value.Ending_Balance_12__c);
                
                inMillion['Current_Balance_inBaht'] = helper.numberWithCommas(value.Current_Balance__c);
                inMillion['Projection_inBaht'] = helper.numberWithCommas(value.Projection__c);
                inMillion['MTD_inBaht'] = helper.numberWithCommas(value.MTD__c);
                inMillion['MoM_inBaht'] = helper.numberWithCommas(value.MoM__c);
                inMillion['YTD_inBaht'] = isNextYear ? '' : helper.numberWithCommas(value.YTD__c);
                inMillion['Variance_inBaht'] = helper.numberWithCommas(value.Variance__c);
                inMillion['Team_Code__c'] = value.Team_Code__c;
                inMillion['RM__Name'] = value.RM__Name;
                inMillion['OwnerId'] = value.OwnerId;
                inMillion['Financial_Product_Domain__c'] = value.Financial_Product_Domain__c;
                inMillion['Product__Financial_Product_Group_Name__c'] = value.Product__Financial_Product_Group_Name__c;
                
                inMillion['Limit__c'] = value.Limit__c;
                inMillion['Current_Balance__c'] = value.Current_Balance__c;
                inMillion['Last_Year_Ending__c'] = value.Last_Year_Ending__c;
                inMillion['Ending_Balance_01__c'] = value.Ending_Balance_01__c;
                inMillion['Ending_Balance_02__c'] = value.Ending_Balance_02__c;
                inMillion['Ending_Balance_03__c'] = value.Ending_Balance_03__c;
                inMillion['Ending_Balance_04__c'] = value.Ending_Balance_04__c;
                inMillion['Ending_Balance_05__c'] = value.Ending_Balance_05__c;
                inMillion['Ending_Balance_06__c'] = value.Ending_Balance_06__c;
                inMillion['Ending_Balance_07__c'] = value.Ending_Balance_07__c;
                inMillion['Ending_Balance_08__c'] = value.Ending_Balance_08__c;
                inMillion['Ending_Balance_09__c'] = value.Ending_Balance_09__c;
                inMillion['Ending_Balance_10__c'] = value.Ending_Balance_10__c;
                inMillion['Ending_Balance_11__c'] = value.Ending_Balance_11__c;
                inMillion['Ending_Balance_12__c'] = value.Ending_Balance_12__c;
                inMillion['Projection__c'] = value.Projection__c;
                inMillion['Variance__c'] = value.Variance__c;
                inMillion['MTD__c'] = value.MTD__c;
                inMillion['MoM__c'] = value.MoM__c;
                inMillion['YTD__c'] = isNextYear ? '' : value.YTD__c;
                
                inMillion['Limit_inmil'] = value.Limit__c / 10**6 ;
                inMillion['Current_Balance_inmil'] = value.Current_Balance__c / 10**6 ;
                inMillion['Last_Year_Ending_inmil'] = value.Last_Year_Ending__c / 10**6 ;
                inMillion['Ending_Balance_01_inmil'] = value.Ending_Balance_01__c / 10**6 ;
                inMillion['Ending_Balance_02_inmil'] = value.Ending_Balance_02__c / 10**6 ;
                inMillion['Ending_Balance_03_inmil'] = value.Ending_Balance_03__c / 10**6 ;
                inMillion['Ending_Balance_04_inmil'] = value.Ending_Balance_04__c / 10**6 ;
                inMillion['Ending_Balance_05_inmil'] = value.Ending_Balance_05__c / 10**6 ;
                inMillion['Ending_Balance_06_inmil'] = value.Ending_Balance_06__c / 10**6 ;
                inMillion['Ending_Balance_07_inmil'] = value.Ending_Balance_07__c / 10**6 ;
                inMillion['Ending_Balance_08_inmil'] = value.Ending_Balance_08__c / 10**6 ;
                inMillion['Ending_Balance_09_inmil'] = value.Ending_Balance_09__c / 10**6 ;
                inMillion['Ending_Balance_10_inmil'] = value.Ending_Balance_10__c / 10**6 ;
                inMillion['Ending_Balance_11_inmil'] = value.Ending_Balance_11__c / 10**6 ;
                inMillion['Ending_Balance_12_inmil'] = value.Ending_Balance_12__c / 10**6 ;
                inMillion['Projection_inmil'] = value.Projection__c / 10**6 ;
                inMillion['Variance_inmil'] = value.Variance__c / 10**6 ;
                inMillion['MTD_inmil'] = value.MTD__c / 10**6 ;
                inMillion['MoM_inmil'] = value.MoM__c / 10**6 ;
                inMillion['YTD_inmil'] = isNextYear ? '' : value.YTD__c / 10**6 ;

                inMillion['Utilized'] = value.Utilized;
                inMillion['UtilizedPercent'] = helper.numberWithCommas((value.Utilized * 100));
                showTempCube.push(inMillion);
            }
        });

        showTempCube = helper.prioritySorting(showTempCube,priorityProduct);
        if (helper.parseObj(component.get('v.groupingByRM')) != null && userProfile != 'GroupHead') jsonForCSV.push(helper.setJSONData(component, helper, showTempCube[0], team, rm , year))
        for (var i = 1; i < showTempCube.length; i++) {
            if (helper.parseObj(component.get('v.groupingByRM')) != null && userProfile != 'GroupHead') jsonForCSV.push(helper.setJSONData(component, helper, showTempCube[i], team, rm , year))
            showTempCube[i].Team_Code__c = '';
            showTempCube[i].RM__Name = '';
        }
        var showTotalRow ={};
        
        totalRow.YTD__c = totalRow.Current_Balance__c - totalRow.Last_Year_Ending__c;
        totalRow.YTD__c =  isNextYear ? '' : totalRow.YTD__c;
        totalRow['Utilized'] = totalRow.Limit__c != 0 ? totalRow.Current_Balance__c / totalRow.Limit__c : 0;
        totalRow['onlyCreditCurrent'] = onlyCreditCurrent;
        showTotalRow['RM_Name'] = totalRow.RM_Name;
        showTotalRow['Product_Group'] = totalRow.Product_Group
        showTotalRow['regionName'] = totalRow.regionName;
        showTotalRow['Team_Code__c'] = totalRow.Team_Code__c;
        showTotalRow['Limit__c'] = (totalRow.Limit__c / 10**6);
        showTotalRow['Last_Year_Ending__c'] = (totalRow.Last_Year_Ending__c / 10**6);
        showTotalRow['Ending_Balance_01__c'] = (totalRow.Ending_Balance_01__c / 10**6);
        showTotalRow['Ending_Balance_02__c'] = (totalRow.Ending_Balance_02__c / 10**6);
        showTotalRow['Ending_Balance_03__c'] = (totalRow.Ending_Balance_03__c / 10**6);
        showTotalRow['Ending_Balance_04__c'] = (totalRow.Ending_Balance_04__c / 10**6);
        showTotalRow['Ending_Balance_05__c'] = (totalRow.Ending_Balance_05__c / 10**6);
        showTotalRow['Ending_Balance_06__c'] = (totalRow.Ending_Balance_06__c / 10**6);
        showTotalRow['Ending_Balance_07__c'] = (totalRow.Ending_Balance_07__c / 10**6);
        showTotalRow['Ending_Balance_08__c'] = (totalRow.Ending_Balance_08__c / 10**6);
        showTotalRow['Ending_Balance_09__c'] = (totalRow.Ending_Balance_09__c / 10**6);
        showTotalRow['Ending_Balance_10__c'] = (totalRow.Ending_Balance_10__c / 10**6);
        showTotalRow['Ending_Balance_11__c'] = (totalRow.Ending_Balance_11__c / 10**6);
        showTotalRow['Ending_Balance_12__c'] = (totalRow.Ending_Balance_12__c / 10**6);
        showTotalRow['Current_Balance__c'] = (totalRow.Current_Balance__c / 10**6);
        showTotalRow['Projection__c'] = (totalRow.Projection__c / 10**6);
        showTotalRow['Variance__c'] = (totalRow.Variance__c / 10**6);
        showTotalRow['MTD__c'] = (totalRow.MTD__c / 10**6);
        showTotalRow['MoM__c'] = (totalRow.MoM__c / 10**6);
        showTotalRow['YTD__c'] = isNextYear ? '' : (totalRow.YTD__c / 10**6);
        showTotalRow['Utilized'] = totalRow['Utilized'];

        showTotalRow['Limit_inBaht'] = helper.numberWithCommas(totalRow.Limit__c);
        showTotalRow['Last_Year_Ending_inBaht'] = helper.numberWithCommas(totalRow.Last_Year_Ending__c);
        showTotalRow['Ending_Balance_01_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_01__c);
        showTotalRow['Ending_Balance_02_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_02__c);
        showTotalRow['Ending_Balance_03_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_03__c);
        showTotalRow['Ending_Balance_04_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_04__c);
        showTotalRow['Ending_Balance_05_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_05__c);
        showTotalRow['Ending_Balance_06_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_06__c);
        showTotalRow['Ending_Balance_07_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_07__c);
        showTotalRow['Ending_Balance_08_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_08__c);
        showTotalRow['Ending_Balance_09_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_09__c);
        showTotalRow['Ending_Balance_10_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_10__c);
        showTotalRow['Ending_Balance_11_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_11__c);
        showTotalRow['Ending_Balance_12_inBaht'] = helper.numberWithCommas(totalRow.Ending_Balance_12__c);
        showTotalRow['Current_Balance_inBaht'] = helper.numberWithCommas(totalRow.Current_Balance__c);
        showTotalRow['Projection_inBaht'] = helper.numberWithCommas(totalRow.Projection__c);
        showTotalRow['Variance_inBaht'] = helper.numberWithCommas(totalRow.Variance__c);
        showTotalRow['MTD_inBaht'] = helper.numberWithCommas(totalRow.MTD__c);
        showTotalRow['MoM_inBaht'] = helper.numberWithCommas(totalRow.MoM__c);
        showTotalRow['YTD_inBaht'] = isNextYear ? '' : helper.numberWithCommas(totalRow.YTD__c);
        showTotalRow['UtilizedPercent'] = helper.numberWithCommas((totalRow.Utilized * 100));
        var p = component.get("v.parent");
        if(userProfile != 'GroupHead' && helper.parseObj(component.get('v.groupingByRM')) != null) {
            jsonForCSV.push(helper.setJSONData( component, helper, totalRow, team, rm ,year))
        }
        if (userProfile != 'RM' && helper.parseObj(component.get('v.groupingByTeam')) != null) {
            jsonForCSV.push(helper.setJSONData( component, helper, totalRow, team, 'Team Total',year))
        }
        if ((userProfile == 'GroupHead' || userProfile == 'System Administrator') && (helper.parseObj(component.get('v.groupingByReg')) != null)) {
            jsonForCSV.push(helper.setJSONData( component, helper, totalRow, totalRow.regionName, 'Region Total',year))
        }
        p.exportCSV(helper.parseObj(jsonForCSV));

        // p.sumGroupTotalRow(totalRow);
        if (helper.parseObj(component.get('v.groupingByRM')) != null) {
            component.set('v.groupingByRM', showTempCube);
        }
        component.set('v.totalRow', showTotalRow);
    }
})