public class MonthlyForecastInputTriggerHandler {
    final static Id RTExistingRepay {
        get{
            if(RTExistingRepay == null){
                RTExistingRepay = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
            }
            return RTExistingRepay;
        }set;
    }

    final static Id RTExistingFee {
        get{
            if(RTExistingFee == null){
                RTExistingFee = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Fee').getRecordTypeId();
            }
            return RTExistingFee;
        }set;
    }

    final static Id RTDrawdown {
        get{
            if(RTDrawdown == null){
                RTDrawdown = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Drawdown').getRecordTypeId();
            }
            return RTDrawdown;
        }set;
    }

    // final static Id RTNewdeal {
    //     get{
    //         if(RTNewdeal == null){
    //             RTNewdeal = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('New Deal').getRecordTypeId();
    //         }
    //         return RTNewdeal;
    //     }set;
    // }

    public static void BeforeInsert(List<Monthly_Forecast_Input__c> mapNew){
        for(Monthly_Forecast_Input__c mfi : mapNew){
            if(mfi.isSkipUpdateCUBE__c){
                mfi.isSkipUpdateCUBE__c = false;
            }
        }
    }

    public static void afterInsert(Map<Id, Monthly_Forecast_Input__c> mapNew){
        System.debug('::: Start afterInsert :::');
        List<Monthly_Forecast_Input__c> mfiExistingRepayNewLst = new List<Monthly_Forecast_Input__c>();
        List<Monthly_Forecast_Input__c> mfiExistingFeeNewLst = new List<Monthly_Forecast_Input__c>();
        List<Monthly_Forecast_Input__c> mfiDrawdownNewLst = new List<Monthly_Forecast_Input__c>();
        // List<Monthly_Forecast_Input__c> mfiNewdealNewLst = new List<Monthly_Forecast_Input__c>();

        if(mapNew != null){
            for(Monthly_Forecast_Input__c mfi : mapNew.values()){
                if(mfi.recordtypeId == RTExistingRepay){
                    mfiExistingRepayNewLst.add(mfi);
                }else if(mfi.recordtypeId == RTExistingFee){
                    mfiExistingFeeNewLst.add(mfi);
                }else if(mfi.recordtypeId == RTDrawdown){
                    mfiDrawdownNewLst.add(mfi);
                }
                // if(mfi.recordtypeId == RTNewdeal){
                //     mfiNewdealNewLst.add(mfi);
                // }
            }
        }

        if(mfiExistingRepayNewLst.size() > 0) generateForecastCube1data(mfiExistingRepayNewLst);
        if(mfiExistingFeeNewLst.size() > 0) generateForecastCube2data(mfiExistingFeeNewLst);

        System.debug('::: End afterInsert :::');
    }

    public static void afterUpdate(Map<Id, Monthly_Forecast_Input__c> mapOld, Map<Id, Monthly_Forecast_Input__c> mapNew){
        System.debug('::: Start afterUpdate :::');
        List<Monthly_Forecast_Input__c> mfiExistingRepayNewLst = new List<Monthly_Forecast_Input__c>();
        List<Monthly_Forecast_Input__c> mfiExistingFeeNewLst = new List<Monthly_Forecast_Input__c>();
        List<Monthly_Forecast_Input__c> mfiDrawdownNewLst = new List<Monthly_Forecast_Input__c>();

        Set<Id> mfiUpdateSkipCUBEFlag = new Set<Id>();
        // List<Monthly_Forecast_Input__c> mfiNewdealNewLst = new List<Monthly_Forecast_Input__c>();

        if(mapNew != null){
            for(Monthly_Forecast_Input__c mfi : mapNew.values()){
                if(mfi.recordtypeId == RTExistingRepay){
                    if(mfi.Last_Month_Forecast__c == mapOld.get(mfi.id)?.Last_Month_Forecast__c){
                        if(mfi.isSkipUpdateCUBE__c){
                            // mfi.isSkipUpdateCUBE__c = false;
                            mfiUpdateSkipCUBEFlag.add(mfi.Id);
                        }else if(mfi.isSkipUpdateCUBE__c == false && mfi.isSkipUpdateCUBE__c == mapOld.get(mfi.id)?.isSkipUpdateCUBE__c){
                            mfiExistingRepayNewLst.add(mfi);
                        }
                    }
                }else if(mfi.recordtypeId == RTExistingFee){
                    mfiExistingFeeNewLst.add(mfi);
                }else if(mfi.recordtypeId == RTDrawdown){
                    mfiDrawdownNewLst.add(mfi);
                }
                // if(mfi.recordtypeId == RTNewdeal){
                //     mfiNewdealNewLst.add(mfi);
                // }
            }
        }

        List<Monthly_Forecast_Input__c> mfitoupdateCude1lst = new List<Monthly_Forecast_Input__c>();
        mfitoupdateCude1lst.addALl(mfiExistingRepayNewLst);
        mfitoupdateCude1lst.addALl(mfiDrawdownNewLst);

        if(mfitoupdateCude1lst.size() > 0) updateDataToForecastCUBE1(mfitoupdateCude1lst, mapOld);
        if(mfiExistingFeeNewLst.size() > 0) updateDataCUBE2(mfiExistingFeeNewLst, mapOld);
        if(mfiUpdateSkipCUBEFlag.size() > 0) updateSkipCUBEFlag(mfiUpdateSkipCUBEFlag);

        System.debug('::: End afterUpdate :::');
    }

    public static void updateSkipCUBEFlag(Set<Id> mfiIdList){
        List<Monthly_Forecast_Input__c> mfilst = [SELECT Id, isSkipUpdateCUBE__c FROM Monthly_Forecast_Input__c WHERE Id IN :mfiIdList];

        for(Monthly_Forecast_Input__c mfi : mfilst){
            mfi.isSkipUpdateCUBE__c = false;
        }

        update mfilst;
    }

    public static void updateDataToForecastCUBE1(List<Monthly_Forecast_Input__c> mfilst, Map<Id, Monthly_Forecast_Input__c> mapOld){
        System.debug('updateDataToForecastCUBE1:::::');
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        Set<String> monthSet = new Set<String>();
        Set<String> yearSet = new Set<String>();
        Set<Id> acctIdSet = new Set<Id>();
        Set<Id> prdIdSet = new Set<Id>();
        Boolean isUpdateCUBE = false;

        for(Monthly_Forecast_Input__c mfi : mfilst){
            Boolean cond1 = mfi.Ending_Balance__c != mapOld.get(mfi.Id).Ending_Balance__c;
            Boolean cond2 = mfi.Current_Ending_Balance__c != mapOld.get(mfi.Id).Current_Ending_Balance__c;
            Boolean cond3 = mfi.Average_Balance__c != mapOld.get(mfi.Id).Average_Balance__c;
            Boolean cond4 = mfi.NI_Formula__c != mapOld.get(mfi.Id).NI_Formula__c;
            Boolean cond5 = mfi.FTP__c != mapOld.get(mfi.Id).FTP__c;
            Boolean cond6 = mfi.Interest_Income__c != mapOld.get(mfi.Id).Interest_Income__c;
            if(cond1 || cond2 || cond3 || cond4 || cond5 || cond6){
                isUpdateCUBE = true;
                monthSet.add(mfi.Month__c);
                yearSet.add(mfi.Year__c);
                acctIdSet.add(mfi.Customer__c);
                prdIdSet.add(mfi.Product__c);
            }
        }
        System.debug('acctIdSet:' + acctIdSet);
        System.debug('prdIdSet:' + prdIdSet);
        System.debug('yearSet:' + yearSet);
        System.debug('monthSet' + monthSet);
        System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());

        if(isUpdateCUBE && yearSet.size() == 1 && monthSet.size() == 1){
            Map<String, List<Monthly_Forecast_Input__c>> mapmfiToCalculate = new Map<String, List<Monthly_Forecast_Input__c>>();

            String yearStr = new list<string>(yearSet)[0];
            String monthStr = new list<string>(monthSet)[0];

            String yearmonth = yearStr + monthStr + '%';

            for(Monthly_Forecast_Input__c mfi : [SELECT Id, Customer__c, Customer__r.Owner.Zone_Code__c, Product__c, adjustMonthYear__c, Year__c, Month__c, RecordtypeId, Recordtype.Name, Account_Suffix_Ref__c, Limit__c, Ending_Balance__c, Average_Balance__c, NI_Formula__c, Interest_Income__c, FTP__c, Current_Ending_Balance__c, Last_Month_Ending_Balance__c, F_Projected_Balance__c FROM Monthly_Forecast_Input__c WHERE (RecordTypeId = :RTExistingRepay OR RecordTypeId = :RTDrawdown) AND Customer__c IN :acctIdSet AND Product__c IN :prdIdSet AND Year__c IN :yearSet AND Month__c IN :monthSet AND YearMonthAcctSuffRef__c LIKE :yearmonth]){
                String key = '' + mfi.Year__c + mfi.Customer__c + mfi.Product__c;
                if(mapmfiToCalculate.containsKey(key)){
                    mapmfiToCalculate.get(key).add(mfi);
                }else{
                    List<Monthly_Forecast_Input__c> mfitoCallst = new List<Monthly_Forecast_Input__c>();
                    mfitoCallst.add(mfi);
                    mapmfiToCalculate.put(key, mfitoCallst);
                }
            }
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
    
            List<Forecast_Cube_1__c> cubeToUpdate = [SELECT Id, Year__c, Last_Year_Forecast_Cube_1__c, Last_Month_Ending__c, Current_Balance__c, Projection__c, Variance__c, MTD__c, MoM__c, cubeKey__c, Product__c, Customer__c, Limit__c FROM Forecast_Cube_1__c WHERE Customer__c IN :acctIdSet AND Product__c IN :prdIdSet AND Year__c IN :yearSet];
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
            for(Forecast_Cube_1__c cube : cubeToUpdate){
                String key = '' + cube.Year__c + cube.Customer__c + cube.Product__c;
                String lastYearkey = '' + String.valueOf(Integer.valueOf(cube.Year__c) - 1) + cube.Customer__c + cube.Product__c;
                List<Monthly_Forecast_Input__c> mfitoCallst = mapmfiToCalculate.containsKey(key) ? mapmfiToCalculate.get(key) : new List<Monthly_Forecast_Input__c>();

                if(cube.Last_Year_Forecast_Cube_1__c == null){
                    Forecast_Cube_1__c lastmonthCube = new Forecast_Cube_1__c(cubeKey__c = lastYearkey); 
                    cube.Last_Year_Forecast_Cube_1__r = lastmonthCube;
                }

                if(mfitoCallst.size() > 0){
                    for (String month : monthSet) {
                        Decimal totalEndingBal = 0;
                        Decimal totalAvg = 0;
                        Decimal totalni = 0;
                        Decimal totalftp = 0;
                        Decimal totalInterest = 0;
                        Decimal totalLimit = 0;

                        Decimal totalCurrentBal;
                        Decimal totallastmonthBal;
                        Decimal totalprojectedBal;
        
                        for (Monthly_Forecast_Input__c mfi : mfitoCallst) {
                            if(mfi.RecordtypeId == RTExistingRepay){
                                totalEndingBal += mfi.Ending_Balance__c == null ? 0 : mfi.Ending_Balance__c;
                                totalAvg += mfi.Average_Balance__c == null ? 0 : mfi.Average_Balance__c;
                                totalni += mfi.NI_Formula__c == null ? 0 : mfi.NI_Formula__c;
                                totalftp += mfi.FTP__c == null ? 0 : mfi.FTP__c;
                                totalInterest += mfi.Interest_Income__c == null ? 0 : mfi.Interest_Income__c;

                                totalLimit += mfi.Limit__c;
                                
                                if(mfi.adjustMonthYear__c.month() == Date.today().month() && mfi.adjustMonthYear__c.year() == Date.today().year()){
                                    totalCurrentBal = totalCurrentBal == null ? mfi.Current_Ending_Balance__c : totalCurrentBal + mfi.Current_Ending_Balance__c;
                                    totallastmonthBal = totallastmonthBal == null ? mfi.Last_Month_Ending_Balance__c : totallastmonthBal + mfi.Last_Month_Ending_Balance__c;
                                    totalprojectedBal = totalprojectedBal == null ? mfi.Ending_Balance__c == null ? 0 : mfi.Ending_Balance__c : totalprojectedBal + (mfi.Ending_Balance__c == null ? 0 : mfi.Ending_Balance__c);
                                }
                            }else if(mfi.RecordtypeId == RTDrawdown){
                                if(mfi.adjustMonthYear__c >= Date.today()){
                                    totalEndingBal += mfi.Ending_Balance__c == null ? 0 : mfi.Ending_Balance__c;
                                    totalAvg += mfi.Average_Balance__c == null ? 0 : mfi.Average_Balance__c;
                                    totalni += mfi.NI_Formula__c == null ? 0 : mfi.NI_Formula__c;
                                    if(Integer.valueOf(mfi.Month__c) == Date.today().month() && Integer.valueOf(mfi.Year__c) == Date.today().year()){
                                        totalprojectedBal = totalprojectedBal == null ? mfi.Ending_Balance__c : totalprojectedBal + (mfi.Ending_Balance__c == null ? 0 : mfi.Ending_Balance__c);
                                    }
                                }
                            }
                        }
                        
                        cube.put('Ending_Balance_' + month + '__c', totalEndingBal);
                        cube.put('Average_Balance_' + month + '__c', totalAvg);
                        cube.put('NI_' + month + '__c', totalni);
                        cube.put('FTP_' + month + '__c', totalftp);
                        cube.put('Interest_Income_' + month + '__c', totalInterest);
                        cube.Limit__c = totalLimit;

                        cube.Current_Balance__c = totalCurrentBal == null ? cube.Current_Balance__c : totalCurrentBal;
                        cube.Last_Month_Ending__c = totallastmonthBal == null ? cube.Last_Month_Ending__c : totallastmonthBal;
                        cube.Projection__c = totalprojectedBal == null ? cube.Projection__c : totalprojectedBal;
                    }
                    
                    cube.Variance__c = cube.Current_Balance__c - cube.Projection__c;
                    cube.MTD__c = cube.Current_Balance__c - cube.Last_Month_Ending__c;
                    cube.MoM__c = cube.Projection__c - cube.Last_Month_Ending__c;
                }
            }
            // update cubeToUpdate;
            List<Database.SaveResult> srList = Database.update(cubeToUpdate, false);
            List<Forecast_Cube_1__c> reUpdateError = new List<Forecast_Cube_1__c>();

            for (Integer i = 0 ; i < srList.size() ; i++){
                Database.SaveResult sr = srList.get(i);
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getMessage());
                        if (err.getMessage().contains('Foreign key external ID')) {
                            Forecast_Cube_1__c reupdateCube = cubeToUpdate.get(i);
                            reupdateCube.Last_Year_Forecast_Cube_1__r = null;
                            reUpdateError.add(reupdateCube);
                        }
                    }
                }
            }

            if(reUpdateError.size() > 0) update reUpdateError;
            System.debug('Query rows:' + limits.getQueryRows() + ' of ' + limits.getLimitQueryRows());
        }
    }

    public static void updateDataCUBE2(List<Monthly_Forecast_Input__c> mfilst, Map<Id, Monthly_Forecast_Input__c> mapOld){
        List<Monthly_Forecast_Input__c> mfiRecallst = new List<Monthly_Forecast_Input__c>();

        for(Monthly_Forecast_Input__c each : mfilst){
            if(each.NI__c != mapOld.get(each.Id).NI__c && each.Customer__c != null && each.Income_Type__c != null && each.Year__c != null){
                mfiRecallst.add(each);
            }
        }

        if(mfiRecallst.size() > 0) generateForecastCube2data(mfiRecallst);
    }

    public static void generateForecastCube2data(List<Monthly_Forecast_Input__c> mfilst){
        Map<String, Forecast_Cube_2__c> mapCUBE2Key = new Map<String, Forecast_Cube_2__c>();
        Map<String, Forecast_Cube_2__c> createCubelst = new Map<String, Forecast_Cube_2__c>();
        Set<Id> acctIdSet = new Set<Id>();

        for(Monthly_Forecast_Input__c each : mfilst){
            if(each.Customer__c != null && each.Income_Type__c != null){
                acctIdSet.add(each.Customer__c);
            }
        }

        for(Forecast_Cube_2__c cube : [SELECT Id, Last_Year_Forecast_Cube_2__c, Cube2Key__c, Customer__c, Income_Type__c, Year__c FROM Forecast_Cube_2__c WHERE Customer__c IN :acctIdSet]){
            mapCUBE2Key.put(cube.Cube2Key__c, cube);
        }

        for(Monthly_Forecast_Input__c mfi : mfilst){
            if(mfi.Customer__c != null && mfi.Income_Type__c != null && mfi.Year__c != null && mfi.Month__c != null){
                String key = '' + mfi.Year__c + mfi.Customer__c + mfi.Income_Type__c;
                String lastyearkey = '' + String.valueOf(Integer.valueOf(mfi.Year__c) - 1) + mfi.Customer__c + mfi.Income_Type__c;

                if(mapCUBE2Key.containsKey(key)){
                    mapCUBE2Key.get(key).put('NI_' + mfi.Month__c + '__c', mfi.NI__c);
                }else if(!mapCUBE2Key.containsKey(key) && !createCubelst.containsKey(key)){
                    Forecast_Cube_2__c dummycube = populateCube2Data(mfi);
                    
                    if(mapCUBE2Key.containsKey(lastyearkey)){
                        dummycube.Last_Year_Forecast_Cube_2__c = mapCUBE2Key.get(lastyearkey).Id;
                    }

                    createCubelst.put(key, dummycube);
                }else{
                    createCubelst.get(key).put('NI_' + mfi.Month__c + '__c', mfi.NI__c);
                }
            }
        }

        if(mapCUBE2Key.size() > 0) update mapCUBE2Key.values();

        if(createCubelst.size() > 0) insert createCubelst.values();

        List<Forecast_Cube_2__c> cube2UpdateRelate = new List<Forecast_Cube_2__c>();
        List<Forecast_Cube_2__c> checkRelateList =  new List<Forecast_Cube_2__c>();
        checkRelateList.addAll(mapCUBE2Key.values());
        checkRelateList.addAll(createCubelst.values());

        
        for(Forecast_Cube_2__c cube2Relate : checkRelateList){
            if(cube2Relate.Last_Year_Forecast_Cube_2__c == null){
                String key = String.valueOf(Integer.valueOf(cube2Relate.Year__c) - 1) + cube2Relate.Customer__c + cube2Relate.Income_Type__c;

                Forecast_Cube_2__c lastMonthCube = new Forecast_Cube_2__c(Cube2Key__c = key); 
                cube2Relate.Last_Year_Forecast_Cube_2__r = lastMonthCube;
                cube2UpdateRelate.add(cube2Relate);
            }
        }

        if(cube2UpdateRelate.size() > 0) List<Database.SaveResult> srList = Database.update(cube2UpdateRelate, false);
    }

    public static void generateForecastCube1data(List<Monthly_Forecast_Input__c> mfilst){
        Set<Id> acctIdSet = new Set<Id>();
        Set<Id> prdIdSet = new Set<Id>();
        Map<String, Forecast_Cube_1__c> createCubelst = new Map<String, Forecast_Cube_1__c>();

        Map<String, Forecast_Cube_1__c> mapKeyCube = new Map<String, Forecast_Cube_1__c>();

        for(Monthly_Forecast_Input__c each : mfilst){
            if(each.Customer__c != null && each.Product__c != null){
                acctIdSet.add(each.Customer__c);
                prdIdSet.add(each.Product__c);
            }
        }

        for(Forecast_Cube_1__c cube : [SELECT Id, cubeKey__c, Customer__c, Product__c, Year__c FROM Forecast_Cube_1__c WHERE Customer__c IN :acctIdSet AND Product__c IN :prdIdSet]){
            mapKeyCube.put(cube.cubeKey__c, cube);
        }
        
        for(Monthly_Forecast_Input__c mfi : mfilst){
            if(mfi.Customer__c != null && mfi.Product__c != null && mfi.Year__c != null){
                String key = ''  + mfi.Year__c + mfi.Customer__c + mfi.Product__c;
                String lastyearkey = '' + String.valueOf(Integer.valueOf(mfi.Year__c) - 1) + mfi.Customer__c + mfi.Product__c;
                if(!mapKeyCube.containsKey(key) && !createCubelst.containsKey(key)){
                    Forecast_Cube_1__c dummycube = populateCube1Data(mfi);
                    createCubelst.put(key, dummycube);
                }
            }
        }

        if(createCubelst.size() > 0){
            insert createCubelst.values();
        }
    }

    public static Forecast_Cube_1__c populateCube1Data(Monthly_Forecast_Input__c mfi){
        Forecast_Cube_1__c reuslt = new Forecast_Cube_1__c();
        reuslt.cubeKey__c = '' + mfi.Year__c + mfi.Customer__c + mfi.Product__c;
        reuslt.Customer__c = mfi.Customer__c;
        reuslt.Product__c = mfi.Product__c;
        reuslt.Year__c = mfi.Year__c;

        return reuslt;
    }

    public static Forecast_Cube_2__c populateCube2Data(Monthly_Forecast_Input__c mfi){
        Forecast_Cube_2__c reuslt = new Forecast_Cube_2__c();
        reuslt.Cube2Key__c = '' + mfi.Year__c+ mfi.Customer__c + mfi.Income_Type__c ;
        reuslt.Customer__c = mfi.Customer__c;
        reuslt.Income_Type__c = mfi.Income_Type__c;
        reuslt.Year__c = mfi.Year__c;
        reuslt.put('NI_' + mfi.Month__c + '__c', mfi.NI__c);
        return reuslt;
    }
}