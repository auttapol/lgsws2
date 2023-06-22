global with sharing class newDealSummaryCtl {
    
    public newDealSummaryCtl() {

    }

    @AuraEnabled (cacheable=true)
    public static Integer getCurrentFYYear(){
        return System.Today().Year();
    }


    @AuraEnabled (cacheable=true)
    public static monthStructure monthHeader(){

        monthStructure monthH = New monthStructure();
        DateTime pointer;
        Integer Year;
        Integer currentYear;
        Integer currentMonth;

        pointer = DateTime.now();      
        Year = pointer.Year();
        currentYear = pointer.Year();
        currentMonth = pointer.month();
        monthH.monthName1 = pointer.format('MMM') + '\' '+ Year;
        
        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);      
        if(Year == currentYear){            
            monthH.monthName2 = pointer.format('MMM') + '\' '+ Year;
        }
        

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName3 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName4 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName5 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName6 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName7 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName8 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName9 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName10 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName11 = pointer.format('MMM') + '\' '+ Year;
        }

        currentMonth  = currentMonth + 1;
        if(currentMonth == 13){
            currentMonth = 1 ;
            Year = Year + 1;
        }
        pointer = DateTime.newInstance(Year, currentMonth, 1);
        if(Year == currentYear){
            monthH.monthName12 = pointer.format('MMM') + '\' '+ Year;      
        }

        return monthH;


    }        


    @AuraEnabled (cacheable=true)
    global static List<newDealSummaryStructure> getNewDealForecast(String appStatusKey){  //Integer offset, Integer limitRow
        //system.debug('**appStatusKey = '+ appStatusKey);

        Integer currentMonth =  System.Today().Month();
        Integer currentYear = System.Today().Year();
        Date startDateCurrentMonth = date.newinstance(currentYear, currentMonth, 1);
        Date endDateOfYear = date.newinstance(currentYear, 12, 31);

        totalNiStructure totalNI = new totalNiStructure();

        //get all user under role hierarchy
        User gurs = [Select Id, UserRoleId from user where id =: UserInfo.getUserId()];
        List<UserRole> userroleList = [Select Id, ParentRoleId from UserRole];

        Set<Id> userRoleIdSet = new Set<Id>();
        userRoleIdSet.add(gurs.UserRoleId);

        userRoleIdSet = getAllSubRoleIds(userRoleIdSet, userroleList);

        List<User> userList = [Select Id, UserRoleId, isActive from user where UserRoleId IN: userRoleIdSet AND isActive = true];
        Set<ID> userIdSet = New Set<Id>();
        userIdSet.add(gurs.id); //Add current user id

        //Add all user under role hierarchy
        if(userList.size() > 0){
            for(User u: userList){
                userIdSet.add(u.Id);
            }
        }
        
        Set<Id> opptyIDSet = New Set<Id>();
        List<Opportunity> opptyList = New List<Opportunity>();

        list<Deal_Forecast_Income__c> dealForecastList = New List<Deal_Forecast_Income__c>();
        if(appStatusKey == 'All Pipeline' || appStatusKey == null || appStatusKey == ''){
			
            opptyList = [Select Id, Name,Probability, Application_Status__c from Opportunity where OwnerID IN: userIdSet
            AND Probability >= 1 AND Probability <= 99 AND 
            (Opportunity_Type_Formula__c =: 'Non-Credit' OR Opportunity_Type_Formula__c =: 'Credit' ) 
            AND (CreatedDate = LAST_N_DAYS:90 OR CALENDAR_YEAR(CreatedDate) =: currentYear)];
          
            if(opptyList.size() > 0){
                for(Opportunity oppty : opptyList){
                    opptyIDSet.add(oppty.Id);
                }
                opptyList = null; //Clear after use
            }

            dealForecastList = [Select Id, Income_Type__c,NI_Amount__c,Opp_App_Status__c,RM_Owner_Name__c,
                RM_Owner_Team__c,TMB_Short_ID__c,Probability__c,NIM_Fee_rate__c,Expected_Start_Month__c,Expected_Start_Year__c,
                OpportunityLineItem_Limit_Volume__c ,Opportunity__r.Name, Customer__r.Name,
                Product__r.Name, Utilization_Percent__c from Deal_Forecast_Income__c 
                WHERE Opportunity__c IN: opptyIDSet ORDER BY RM_Owner_Team__c ASC NULLS LAST ]; //limit :limitRow  offset :offset
               
        
        }else if(appStatusKey == 'All Null Status'){

            opptyList = [Select Id, Name,Probability, Application_Status__c from Opportunity where OwnerID IN: userIdSet
            AND (Application_Status__c =: null OR Application_Status__c =: '') AND 
            (Opportunity_Type_Formula__c =: 'Non-Credit' OR Opportunity_Type_Formula__c =: 'Credit' ) 
            AND (CreatedDate = LAST_N_DAYS:90 OR CALENDAR_YEAR(CreatedDate) =: currentYear)];
            if(opptyList.size() > 0){
                for(Opportunity oppty : opptyList){
                    opptyIDSet.add(oppty.Id);
                }
                opptyList = null; //Clear after use

            }

            dealForecastList = [Select Id, Income_Type__c,NI_Amount__c,Opp_App_Status__c,RM_Owner_Name__c,
                RM_Owner_Team__c,TMB_Short_ID__c,Probability__c,NIM_Fee_rate__c,Expected_Start_Month__c,Expected_Start_Year__c,
                OpportunityLineItem_Limit_Volume__c ,Opportunity__r.Name, Customer__r.Name, 
                Product__r.Name, Utilization_Percent__c from Deal_Forecast_Income__c 
                WHERE Opportunity__c IN: opptyIDSet //AND Last_Update_Adjustment__c >=: startDateCurrentMonth 
                ORDER BY RM_Owner_Team__c ASC NULLS LAST]; //limit :limitRow  offset :offset
        
        }else{

            opptyList = [Select Id, Name,Probability, Application_Status__c from Opportunity where OwnerID IN: userIdSet
            AND Application_Status__c =: appStatusKey AND (CreatedDate = LAST_N_DAYS:90 OR CALENDAR_YEAR(CreatedDate) =: currentYear)];
            if(opptyList.size() > 0){
                for(Opportunity oppty : opptyList){
                    opptyIDSet.add(oppty.Id);
                }
                opptyList = null; //Clear after use
            }

            dealForecastList = [Select Id, Income_Type__c,NI_Amount__c,Opp_App_Status__c,RM_Owner_Name__c,
                RM_Owner_Team__c,TMB_Short_ID__c,Probability__c,NIM_Fee_rate__c,Expected_Start_Month__c,Expected_Start_Year__c,
                OpportunityLineItem_Limit_Volume__c ,Opportunity__r.Name, Customer__r.Name, 
                Product__r.Name, Utilization_Percent__c from Deal_Forecast_Income__c 
                WHERE Opportunity__c IN: opptyIDSet //AND Last_Update_Adjustment__c >=: startDateCurrentMonth 
                ORDER BY RM_Owner_Team__c ASC NULLS LAST]; //limit :limitRow  offset :offset
        
        }

        opptyIDSet = null; //Clear after use


        Set<Id> dealForInSet_id = new Set<Id>();
        if(dealForecastList.size() > 0){
            for(Deal_Forecast_Income__c dForCast : dealForecastList){
                dealForInSet_id.add(dForCast.Id);
            }
        }     

        List<Monthly_Forecast_Input__c> monhtlyInputlist = new List<Monthly_Forecast_Input__c>();
        monhtlyInputlist = [Select ID, NI__c, Year__c, Deal_Forecast_Income__c, adjustMonthYear__c from Monthly_Forecast_Input__c 
                            where Deal_Forecast_Income__c IN: dealForInSet_id
                            AND adjustMonthYear__c >=:startDateCurrentMonth AND adjustMonthYear__c <=: endDateOfYear];
        
        Map<Id,List<Monthly_Forecast_Input__c>> mapMonthlyForcast = New Map<Id,List<Monthly_Forecast_Input__c>>();
        
        if(monhtlyInputlist.size() > 0){
            for(Monthly_Forecast_Input__c mForIn : monhtlyInputlist){

                if (mapMonthlyForcast.containsKey(mForIn.Deal_Forecast_Income__c)){
                    mapMonthlyForcast.get(mForIn.Deal_Forecast_Income__c).add(mForIn);
                }else{
                    mapMonthlyForcast.put(mForIn.Deal_Forecast_Income__c,new List<Monthly_Forecast_Input__c>());
                    mapMonthlyForcast.get(mForIn.Deal_Forecast_Income__c).add(mForIn);
                }

            }
        }
       
        monthStructure monthValue = monthHeader();        
        
        List<newDealSummaryStructure> dealForCList = new List<newDealSummaryStructure>();
        if(dealForecastList.size() > 0){
            integer i = 0;
            for( Deal_Forecast_Income__c dealF :  dealForecastList){
                i++;
                newDealSummaryStructure dealForeCast = new newDealSummaryStructure();
                dealForeCast.recordId = dealF.Id;
                dealForeCast.rmTeamname = dealF.RM_Owner_Team__c;
                dealForeCast.rmName = dealF.RM_Owner_Name__c;
                dealForeCast.tmbShortId = dealF.TMB_Short_ID__c;
                dealForeCast.customerName = dealF.Customer__r.Name;
                dealForeCast.opportunityName = dealF.Opportunity__r.Name;
                dealForeCast.productName = dealF.Product__r.Name;
                dealForeCast.probability = dealF.Probability__c;
                dealForeCast.incomeType = dealF.Income_Type__c;
                dealForeCast.nimFeeRate = dealF.NIM_Fee_rate__c;
                dealForeCast.limitVolume = dealF.OpportunityLineItem_Limit_Volume__c;
                dealForeCast.percentUtilization   =  dealF.Utilization_Percent__c;            
                dealForeCast.status = dealF.Opp_App_Status__c;               

                List<Monthly_Forecast_Input__c> monthly12 = New List<Monthly_Forecast_Input__c>();   
                if(mapMonthlyForcast.get(dealF.Id) != null){
                    monthly12 = mapMonthlyForcast.get(dealF.Id);
                }             
                
                try{
                if(monthly12.size() > 0){
                    for(Monthly_Forecast_Input__c mounthInput : monthly12){                        
                        if(mounthInput.NI__c == null){
                                mounthInput.NI__c = 0;
                         }
                         if(dealForeCast.expectedIncome == null){
                                dealForeCast.expectedIncome = 0;
                         }
                        if(mounthInput.Year__c == String.valueOf(currentYear)){                                                       
                            dealForeCast.expectedIncome = dealForeCast.expectedIncome + mounthInput.NI__c;
                        }

                        Integer year = mounthInput.adjustMonthYear__c.year();
                        Integer month = mounthInput.adjustMonthYear__c.month();
                        Integer day = mounthInput.adjustMonthYear__c.day();
                        DateTime pointerDate = Datetime.newInstance(year, month, day, 0, 0, 0);
                        Integer pointerYear = pointerDate.Year();
                        String monthName = pointerDate.format('MMM') + '\' '+ pointerYear;
                        
                        dealForeCast.expectedIncome = dealForeCast.expectedIncome.setScale(2);
                        if(monthValue.monthName1 == monthName){
                            dealForeCast.month1 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth1 == null){
                                totalNI.totalNiMonth1 = 0;
                            }
                            totalNI.totalNiMonth1 = totalNI.totalNiMonth1 + dealForeCast.month1;
                        }else if(monthValue.monthName2 == monthName){
                            dealForeCast.month2 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth2 == null){
                                totalNI.totalNiMonth2 = 0;
                            }
                            totalNI.totalNiMonth2 = totalNI.totalNiMonth2 + dealForeCast.month2;
                        }else if(monthValue.monthName3 == monthName){
                            dealForeCast.month3 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth3 == null){
                                totalNI.totalNiMonth3 = 0;
                            }
                            totalNI.totalNiMonth3 = totalNI.totalNiMonth3 + dealForeCast.month3;
                        }else if(monthValue.monthName4 == monthName){
                            dealForeCast.month4 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth4 == null){
                                totalNI.totalNiMonth4 = 0;
                            }
                            totalNI.totalNiMonth4 = totalNI.totalNiMonth4 + dealForeCast.month4;
                        }else if(monthValue.monthName5 == monthName){
                            dealForeCast.month5 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth5 == null){
                                totalNI.totalNiMonth5 = 0;
                            }
                            totalNI.totalNiMonth5 = totalNI.totalNiMonth5 + dealForeCast.month5;
                        }else if(monthValue.monthName6 == monthName){
                            dealForeCast.month6 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth6 == null){
                                totalNI.totalNiMonth6 = 0;
                            }
                            totalNI.totalNiMonth6 = totalNI.totalNiMonth6 + dealForeCast.month6;
                        }else if(monthValue.monthName7 == monthName){
                            dealForeCast.month7 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth7 == null){
                                totalNI.totalNiMonth7 = 0;
                            }
                            totalNI.totalNiMonth7 = totalNI.totalNiMonth7 + dealForeCast.month7;
                        }else if(monthValue.monthName8 == monthName){
                            dealForeCast.month8 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth8 == null){
                                totalNI.totalNiMonth8 = 0;
                            }
                            totalNI.totalNiMonth8 = totalNI.totalNiMonth8 + dealForeCast.month8;
                        }else if(monthValue.monthName9 == monthName){
                            dealForeCast.month9 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth9 == null){
                                totalNI.totalNiMonth9 = 0;
                            }
                            totalNI.totalNiMonth9 = totalNI.totalNiMonth9 + dealForeCast.month9;
                        }else if(monthValue.monthName10 == monthName){
                            dealForeCast.month10 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth10 == null){
                                totalNI.totalNiMonth10 = 0;
                            }
                            totalNI.totalNiMonth10 = totalNI.totalNiMonth10 + dealForeCast.month10;
                        }else if(monthValue.monthName11 == monthName){
                            dealForeCast.month11= mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth11 == null){
                                totalNI.totalNiMonth11 = 0;
                            }
                            totalNI.totalNiMonth11 = totalNI.totalNiMonth11 + dealForeCast.month11;
                        }else if(monthValue.monthName12 == monthName){
                            dealForeCast.month12 = mounthInput.NI__c.setScale(2);
                            if(totalNI.totalNiMonth12 == null){
                                totalNI.totalNiMonth12 = 0;
                            }
                            totalNI.totalNiMonth12 = totalNI.totalNiMonth12 + dealForeCast.month12;
                        }  
                    }
                	} 
                 }catch(exception e){
                    system.debug('**Error = '+ e.getMessage());
    
                }
                
                if(i == dealForecastList.size()){
                    dealForeCast.sumTotalNI = totalNI; 
                }                               
                dealForCList.add(dealForeCast);

           }

        }
        //system.debug('#### dealForCList size = '+ dealForCList.size());
        return dealForCList;
    }  


    @AuraEnabled (cacheable=true)
    public static List<String> fetchOppAppStatus(){

        List<String> OppAppStatusValueList = New List<String>();
        list<Opportunity_Opp_App_Status__mdt> OppAppStatusList = [Select ID,Order__c, DeveloperName,Opp_App_Status__c from Opportunity_Opp_App_Status__mdt
        ORDER BY Order__c ASC];
        OppAppStatusValueList.add('All Pipeline'); //Add default value
        if(OppAppStatusList.size() > 0){
            for(Opportunity_Opp_App_Status__mdt oppAppStatus : OppAppStatusList){
                OppAppStatusValueList.add(oppAppStatus.Opp_App_Status__c);
            }
        }
        OppAppStatusValueList.add('All Null Status'); //Add default value 

        //system.debug('#### OppAppStatusValueList size = '+ OppAppStatusValueList.size());
        return OppAppStatusValueList;
    }


    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds, List<UserRole> userroleList) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRoleV : userroleList){       
            if(roleIds.contains(userRoleV.ParentRoleID) ){
                currentRoleIds.add(userRoleV.Id);
            }
           
        }       

        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds, userroleList));
        }
    
        return currentRoleIds;
    }


    //Structure for display table   
    global class newDealSummaryStructure{
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String rmTeamname{get;set;}
        @AuraEnabled
        public String rmName{get;set;}
        @AuraEnabled
        public String tmbShortId{get;set;}
        @AuraEnabled
        public String customerName{get;set;}
        @AuraEnabled
        public String opportunityName{get;set;}
        @AuraEnabled
        public String productName{get;set;}
        @AuraEnabled
        public String probability{get;set;}
        @AuraEnabled
        public String incomeType{get;set;}
        @AuraEnabled
        public Decimal nimFeeRate{get;set;}
        @AuraEnabled
        public Decimal limitVolume{get;set;}
        @AuraEnabled
        public Decimal percentUtilization{get;set;}
        @AuraEnabled
        public Decimal expectedIncome{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public Decimal month1{get;set;}
        @AuraEnabled
        public Decimal month2{get;set;}
        @AuraEnabled
        public Decimal month3{get;set;}
        @AuraEnabled
        public Decimal month4{get;set;}
        @AuraEnabled
        public Decimal month5{get;set;}
        @AuraEnabled
        public Decimal month6{get;set;}
        @AuraEnabled
        public Decimal month7{get;set;}
        @AuraEnabled
        public Decimal month8{get;set;}
        @AuraEnabled
        public Decimal month9{get;set;}
        @AuraEnabled
        public Decimal month10{get;set;}
        @AuraEnabled
        public Decimal month11{get;set;}
        @AuraEnabled
        public Decimal month12{get;set;}

        @AuraEnabled
        public totalNiStructure sumTotalNI{get; set;}
    }

    //Structure month header for display table    
    global class monthStructure{
        @AuraEnabled
        public String monthName1{get;set;}
        @AuraEnabled
        public String monthName2{get;set;}
        @AuraEnabled
        public String monthName3{get;set;}
        @AuraEnabled
        public String monthName4{get;set;}
        @AuraEnabled
        public String monthName5{get;set;}
        @AuraEnabled
        public String monthName6{get;set;}
        @AuraEnabled
        public String monthName7{get;set;}
        @AuraEnabled
        public String monthName8{get;set;}
        @AuraEnabled
        public String monthName9{get;set;}
        @AuraEnabled
        public String monthName10{get;set;}
        @AuraEnabled
        public String monthName11{get;set;}
        @AuraEnabled
        public String monthName12{get;set;}
    }

   
    global class totalNiStructure{
        @AuraEnabled
        public Decimal totalNiMonth1{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth2{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth3{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth4{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth5{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth6{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth7{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth8{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth9{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth10{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth11{get;set;}
        @AuraEnabled
        public Decimal totalNiMonth12{get;set;}

    }

}