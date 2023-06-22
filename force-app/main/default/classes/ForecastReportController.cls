public without sharing class ForecastReportController {
    @AuraEnabled
    public static User currentUser{
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Segment__c, Zone_Code__c, Zone__c, Region_Code__c, UserRoleId, UserRole.Name, ProfileId, Profile.Name FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
            }
            return currentUser;
        }set;
    }

    final static Map<String, Region_and_Zone_Mapping__c> regionZoneMapping {
        get{
            if(regionZoneMapping == null){
                regionZoneMapping = new Map<String, Region_and_Zone_Mapping__c>();
                for (Region_and_Zone_Mapping__c regionZone : [SELECT Id, Team_Zone_Code__c, Team_Zone_Name__c, Region_Group_Code__c, Region_Group_Name__c FROM Region_and_Zone_Mapping__c]) {
                    if(regionZone.Team_Zone_Code__c != null && regionZone.Team_Zone_Code__c != '') regionZoneMapping.put(regionZone.Team_Zone_Code__c, regionZone);
                }
            }
            return regionZoneMapping;
        }set;
    }

    public static List<Forecast_Product_Group_Priority__mdt> priorityProduct{
        get{
            if(priorityProduct == null){
                priorityProduct = [SELECT DeveloperName, MasterLabel, Priority__c, Product_Type__c FROM Forecast_Product_Group_Priority__mdt];
            }
            return priorityProduct;
        }set;
    }

    public static Set<String> GHprofile {
        get{
            if(GHprofile == null){
                GHprofile = new Set<String>();

                AppConfig__c GHconf = AppConfig__c.getValues('Forecast report GH profile');

                if(GHconf != null && GHconf.Value__c != null){
                    for(String str : GHconf.Value__c.split(';')){
                        GHprofile.add(str);
                    }
                }else{
                    GHprofile.add('TMB Group Head Profile');
                    GHprofile.add('TMB SE Group Head Profile');
                    GHprofile.add('TMB BB Group Head Profile');
                    GHprofile.add('TMB SE Regional Manager Profile');
                    GHprofile.add('TMB Commercial Report Specialist Profile');
                    GHprofile.add('TMB BB Sales Management Profile');
                    GHprofile.add('TMB CB/MB Sales Management Profile');
                    GHprofile.add('TMB SE Sales Management Profile');
                }
            }
            return GHprofile;
        }set;
    }

    public static Set<String> THprofile {
        get{
            if(THprofile == null){
                THprofile = new Set<String>();

                AppConfig__c THconf = AppConfig__c.getValues('Forecast report TH profile');

                if(THconf != null && THconf.Value__c != null){
                    for(String str : THconf.Value__c.split(';')){
                        THprofile.add(str);
                    }
                }else{
                    THprofile.add('TMB Team Head Profile');
                    THprofile.add('TMB SE Zone Manager Profile');
                    THprofile.add('TMB Product Analyst Profile');
                    THprofile.add('TMB Product Specialist Profile');
                }
            }
            return THprofile;
        }set;
    }

    public static Set<String> RMprofile {
        get{
            if(RMprofile == null){
                RMprofile = new Set<String>();

                AppConfig__c RMconf = AppConfig__c.getValues('Forecast report RM profile');

                if(RMconf != null && RMconf.Value__c != null){
                    for(String str : RMconf.Value__c.split(';')){
                        RMprofile.add(str);
                    }
                }else{
                    RMprofile.add('TMB RM Profile');
                    RMprofile.add('TMB BDM Profile');
                    RMprofile.add('TMB BDM Profile');
                    RMprofile.add('TMB BB RM Profile');
                    RMprofile.add('TMB RMA Profile');
                    RMprofile.add('TMB ABDM Profile');
                    RMprofile.add('TMB MM Profile');
                }
            }
            return RMprofile;
        }set;
    }

    public class cube1WrapperClass{
        @AuraEnabled
        public List<Forecast_Cube_1__c> listCube1 {get;set;}
        
        @AuraEnabled
        public List<Forecast_Cube_1__c> LastYearlistCube1 {get;set;}
        

        @AuraEnabled
        public User currentUser {get;set;}

        @AuraEnabled
        public String userProfile {get;set;}

        @AuraEnabled
        public List<Forecast_Product_Group_Priority__mdt> priorityProduct{get;set;}
    }

    public class cube1WithTargetWrapperClass{
        @AuraEnabled
        public List<Forecast_Cube_1__c> listCube1 {get;set;}

        @AuraEnabled
        public List<Forecast_Cube_1__c> LastYearlistCube1 {get;set;}


        @AuraEnabled
        public String userProfile {get;set;}

        @AuraEnabled
        public List<Target__c> listTarget{get;set;}
    }

    @AuraEnabled
    public static String getUserForecastReportRole(){
        if (currentUser.Profile.Name == 'System Administrator' || currentUser.Profile.Name == 'TMB System Administrator') return 'System Administrator';
        else if (GHprofile.contains(currentUser.Profile.Name)) return 'GroupHead';
        else if (THprofile.contains(currentUser.Profile.Name)) return 'TeamHead';
        else if (RMprofile.contains(currentUser.Profile.Name)) return 'RM';
        else return '';
    }

    @AuraEnabled
    public static Region_and_Zone_Mapping__c getRegionZoneName(String teamName){
        return regionZoneMapping.get(teamName);
    }

    @AuraEnabled
    public static cube1WithTargetWrapperClass getCUBE1Data(String strYear, String port, List<String> searchTeam, String selectedProductGroup){
        List<Forecast_Cube_1__c> result = new List<Forecast_Cube_1__c>();
        List<Forecast_Cube_1__c> LastYearCube1 = new List<Forecast_Cube_1__c>();

        cube1WithTargetWrapperClass Wrapper = new cube1WithTargetWrapperClass();

        Set<String> searchTeamSet = new Set<String>();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        
        Set<Id> rmSet = new Set<Id>();
        Id currentUserId = currentUser.Id;
        Set<String> searchTeamNameSet = new Set<String>();
        
        if(strYear == null || strYear == '') throw new AuraHandledException('Year is null or blank.');
        if(port == null || port == '') throw new AuraHandledException('Port is null.');
        if(searchTeam == null || searchTeam.size() <= 0) throw new AuraHandledException('RM\'s team is null or empty.');

        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }

        String strYearLY = String.valueOf(integer.valueof(strYear) -1);
        //System.debug('strYearLY::'+strYearLY);
    
        String query = 'SELECT ';
        String queryLY = 'SELECT ';
        
        String fields = ' Year__c, Product__c, Product__r.Forecast_NIIc_NIId_Flag__c , Customer__c, Product__r.Financial_Product_Domain__c , Product__r.Financial_Product_Group_Name__c, Customer__r.OwnerId , Customer__r.Owner.Zone__c, Customer__r.Owner.Name, Customer__r.Owner.Zone_Code__c, Customer__r.Owner.Region__c, Customer__r.Owner.Region_Code__c, Limit__c, Current_Balance__c, Projection__c, MTD__c, Variance__c, MoM__c, ';

        fields += ' Ending_Balance_01__c, Ending_Balance_02__c, Ending_Balance_03__c, Ending_Balance_04__c, Ending_Balance_05__c, Ending_Balance_06__c, Ending_Balance_07__c, Ending_Balance_08__c, Ending_Balance_10__c, Ending_Balance_09__c, Ending_Balance_11__c, Ending_Balance_12__c';
        
        fields += ', Average_Balance_01__c, Average_Balance_02__c, Average_Balance_03__c, Average_Balance_04__c, Average_Balance_05__c, Average_Balance_06__c, Average_Balance_07__c, Average_Balance_08__c, Average_Balance_09__c, Average_Balance_10__c, Average_Balance_11__c, Average_Balance_12__c,';
        
        fields += ' NI_01__c, NI_02__c, NI_03__c, NI_04__c, NI_05__c, NI_06__c, NI_07__c, NI_08__c, NI_09__c, NI_10__c, NI_11__c, NI_12__c,';
        
        fields += ' FTP_01__c, FTP_02__c, FTP_03__c, FTP_04__c, FTP_05__c, FTP_06__c, FTP_07__c, FTP_08__c, FTP_09__c, FTP_10__c, FTP_11__c, FTP_12__c,';
        
        fields += ' Interest_Income_01__c, Interest_Income_02__c, Interest_Income_03__c, Interest_Income_04__c, Interest_Income_05__c, Interest_Income_06__c, Interest_Income_07__c, Interest_Income_08__c, Interest_Income_09__c, Interest_Income_10__c, Interest_Income_11__c, Interest_Income_12__c, ';

        String lastyearFields = 'Last_Year_Forecast_Cube_1__r.Ending_Balance_01__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_02__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_03__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_04__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_05__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_06__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_07__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_08__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_09__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_10__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_11__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_12__c, Last_Year_Forecast_Cube_1__r.Average_Balance_01__c, Last_Year_Forecast_Cube_1__r.Average_Balance_02__c, Last_Year_Forecast_Cube_1__r.Average_Balance_03__c, Last_Year_Forecast_Cube_1__r.Average_Balance_04__c, Last_Year_Forecast_Cube_1__r.Average_Balance_05__c, Last_Year_Forecast_Cube_1__r.Average_Balance_06__c, Last_Year_Forecast_Cube_1__r.Average_Balance_07__c, Last_Year_Forecast_Cube_1__r.Average_Balance_08__c, Last_Year_Forecast_Cube_1__r.Average_Balance_09__c, Last_Year_Forecast_Cube_1__r.Average_Balance_10__c, Last_Year_Forecast_Cube_1__r.Average_Balance_11__c, Last_Year_Forecast_Cube_1__r.Average_Balance_12__c, Last_Year_Forecast_Cube_1__r.NI_01__c, Last_Year_Forecast_Cube_1__r.NI_02__c, Last_Year_Forecast_Cube_1__r.NI_03__c, Last_Year_Forecast_Cube_1__r.NI_04__c, Last_Year_Forecast_Cube_1__r.NI_05__c, Last_Year_Forecast_Cube_1__r.NI_06__c, Last_Year_Forecast_Cube_1__r.NI_07__c, Last_Year_Forecast_Cube_1__r.NI_08__c, Last_Year_Forecast_Cube_1__r.NI_09__c, Last_Year_Forecast_Cube_1__r.NI_10__c, Last_Year_Forecast_Cube_1__r.NI_11__c, Last_Year_Forecast_Cube_1__r.NI_12__c, Last_Year_Forecast_Cube_1__r.FTP_01__c, Last_Year_Forecast_Cube_1__r.FTP_02__c, Last_Year_Forecast_Cube_1__r.FTP_03__c, Last_Year_Forecast_Cube_1__r.FTP_04__c, Last_Year_Forecast_Cube_1__r.FTP_05__c, Last_Year_Forecast_Cube_1__r.FTP_06__c, Last_Year_Forecast_Cube_1__r.FTP_07__c, Last_Year_Forecast_Cube_1__r.FTP_08__c, Last_Year_Forecast_Cube_1__r.FTP_09__c, Last_Year_Forecast_Cube_1__r.FTP_10__c, Last_Year_Forecast_Cube_1__r.FTP_11__c, Last_Year_Forecast_Cube_1__r.FTP_12__c, Last_Year_Forecast_Cube_1__r.Interest_Income_01__c, Last_Year_Forecast_Cube_1__r.Interest_Income_02__c, Last_Year_Forecast_Cube_1__r.Interest_Income_03__c, Last_Year_Forecast_Cube_1__r.Interest_Income_04__c, Last_Year_Forecast_Cube_1__r.Interest_Income_05__c, Last_Year_Forecast_Cube_1__r.Interest_Income_06__c, Last_Year_Forecast_Cube_1__r.Interest_Income_07__c, Last_Year_Forecast_Cube_1__r.Interest_Income_08__c, Last_Year_Forecast_Cube_1__r.Interest_Income_09__c, Last_Year_Forecast_Cube_1__r.Interest_Income_10__c, Last_Year_Forecast_Cube_1__r.Interest_Income_11__c, Last_Year_Forecast_Cube_1__r.Interest_Income_12__c';

        String condition = ' ';

        String order = ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC ';

        if(port != null || port != ''){
            if (port == 'My Customer') {
                condition += ' AND Customer__r.OwnerId = :currentUserId ';
            }else if (port == 'My Team') {
                userSet = getMyteamUser();
                condition +=' AND Customer__r.OwnerId IN :userSet';
            }else if(port == 'My Account Team'){
                Set<Id> userIdSet = new Set<Id>();
                userIdSet.add(currentUser.Id);
                acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
                if(acctTeamacctIdSet.size() <= 0) return Wrapper;
                condition += ' AND Customer__c IN :acctTeamacctIdSet';
            }else if(port == 'Select Team'){

            }else if(port == 'My Team-Account Team'){
                userSet = getMyteamUser();
                acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
                if(acctTeamacctIdSet.size() <= 0) return Wrapper;
                condition += ' AND Customer__c IN :acctTeamacctIdSet';
            }
        }

        if (searchTeamSet != null && searchTeamSet.size() > 0){
            condition +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }

        if (selectedProductGroup != null && selectedProductGroup != ''){
            condition +=' AND Product__r.Financial_Product_Domain__c = :selectedProductGroup ';
        }
        
        String whereYear = ' WHERE Year__c = :strYear';
        String whereLastYear = ' WHERE Year__c = :strYearLY';
        query = query + fields + lastyearFields + ' FROM Forecast_Cube_1__c ' + whereYear + condition + order;
        queryLY = queryLY + fields + lastyearFields + ' FROM Forecast_Cube_1__c ' + whereLastYear + condition + order;

        //System.debug(query);
        //System.debug(queryLY);
        result = Database.query(query);
        LastYearCube1 = Database.query(queryLY);
        
        
        for (Forecast_Cube_1__c cube : result) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cube.Customer__r.Owner.Region__c = 'Other';
                cube.Customer__r.Owner.Zone__c = 'Other';
            }
            cube.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cube.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
            rmSet.add(cube.Customer__r.OwnerID);
        }

        for (Forecast_Cube_1__c cube : LastYearCube1) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cube.Customer__r.Owner.Region__c = 'Other';
                cube.Customer__r.Owner.Zone__c = 'Other';
            }
            cube.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cube.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }
        list<Target__c> Target = getTargetReport4(strYear, port, searchTeamSet);
        Wrapper.listCube1 = result;
        Wrapper.listTarget = Target;
        Wrapper.LastYearlistCube1 = LastYearCube1;
        return Wrapper;
    }

    @AuraEnabled
    public static cube1WrapperClass getCube1Report(String strYear, String CustomerPort, List<String> searchTeam, String selectedProductGroup) {   
        cube1WrapperClass cube1WithUser = new cube1WrapperClass();
        cube1WithUser.listCube1 = new List<Forecast_Cube_1__c>();
        cube1WithUser.LastYearlistCube1 = new List<Forecast_Cube_1__c>();
        cube1WithUser.currentUser = currentUser;
        // cube1WithUser.userProfile = (currentUser.Profile.Name);

        Set<String> searchTeamSet = new Set<String>();
        Set<String> searchTeamNameSet = new Set<String>();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Id currentUserId = currentUser.Id;
        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }
        
        string strLastYear =  String.valueOf(integer.valueof(strYear) -1);
        
        String Fields = 'SELECT Year__c, Product__c, Product__r.Forecast_NIIc_NIId_Flag__c , Customer__c, Product__r.Financial_Product_Domain__c , Product__r.Financial_Product_Group_Name__c, Customer__r.OwnerId , Customer__r.Owner.Zone__c, Customer__r.Owner.Name, Customer__r.Owner.Zone_Code__c, Customer__r.Owner.Region__c, Customer__r.Owner.Region_Code__c, Limit__c, Ending_Balance_01__c, Ending_Balance_02__c, Ending_Balance_03__c, Ending_Balance_04__c, Ending_Balance_05__c, Ending_Balance_06__c, Ending_Balance_07__c, Ending_Balance_08__c, Ending_Balance_10__c, Ending_Balance_09__c, Ending_Balance_11__c, Ending_Balance_12__c,NI_01__c, NI_02__c, NI_03__c, NI_04__c, NI_05__c, NI_06__c, NI_07__c, NI_08__c, NI_09__c, NI_10__c, NI_11__c, NI_12__c, Current_Balance__c, Projection__c, MTD__c, Variance__c, MoM__c FROM Forecast_Cube_1__c ';
        String whereStr = ' ';


        if (CustomerPort == 'My Customer') {
            whereStr += 'AND Customer__r.OwnerId =:currentUserId ';
        } else if (CustomerPort == 'My Team') {
            userSet = getMyteamUser();
            whereStr +=' AND Customer__r.OwnerId IN :userSet';
        } else if(CustomerPort == 'My Account Team'){
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.add(currentUser.Id);
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
            if(acctTeamacctIdSet.size() <= 0) return cube1WithUser;
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        } else if(CustomerPort == 'My Team-Account Team'){
            userSet = getMyteamUser();
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
            if(acctTeamacctIdSet.size() <= 0) return cube1WithUser;
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        }
        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereStr +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }
        if (selectedProductGroup != null && selectedProductGroup != ''){
            whereStr +=' AND Product__r.Financial_Product_Domain__c = :selectedProductGroup ';
        }
        string whereYear = ' WHERE Year__c =:strYear ';
        string whereLastYear = ' WHERE Year__c =:strLastYear ';
        String orderBy = ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC';
        String queryStrCurrent = Fields + whereYear + whereStr + orderBy;
        String LYqueryStrCurrent = Fields + whereLastYear + whereStr + orderBy;
        //System.debug(queryStrCurrent);
        cube1WithUser.priorityProduct = priorityProduct;
        cube1WithUser.listCube1 = Database.query(queryStrCurrent);
        cube1WithUser.LastYearlistCube1 = Database.query(LYqueryStrCurrent);
        
        for (Forecast_Cube_1__c cube : cube1WithUser.listCube1) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cube.Customer__r.Owner.Region__c = 'Other';
                cube.Customer__r.Owner.Zone__c = 'Other';
            }
            cube.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cube.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }
        
        return cube1WithUser;
    }

    @AuraEnabled
    public static list<Monthly_Forecast_Input__c> getNewDealReport4(String strYear ,String CustomerPort, List<String> searchTeam) { 
        String Fields = 'SELECT Customer__r.OwnerId, Customer__r.Owner.Zone__c , Customer__r.Owner.Name ,Customer__r.Owner.Zone_Code__c , NI_Formula__c, Income_Type__c, NIIc__c, NIId__c, NI__c, Probability__c, Last_Month_Ending_Balance__c, Month__c FROM Monthly_Forecast_Input__c ';
        String whereStr = 'WHERE Year__c =:strYear AND RecordType.Name=\'New Deal\' AND Deal_Forecast_Income__r.Start_Utilization_Date__c > TODAY AND Deal_Forecast_Income__r.Opportunity__r.Probability NOT IN (0,100) ';
        Set<String> searchTeamSet = new Set<String>();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Id currentUserId = currentUser.Id;
        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }
        if (CustomerPort == 'My Customer') {
            whereStr += 'AND Customer__r.OwnerId =:currentUserId ';
        } else if (CustomerPort == 'My Team') {
            userSet = getMyteamUser();
            whereStr +=' AND Customer__r.OwnerId IN :userSet';
        } else if(CustomerPort == 'My Account Team'){
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.add(currentUser.Id);
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
            if(acctTeamacctIdSet.size() <= 0) return new list<Monthly_Forecast_Input__c>();
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        } else if(CustomerPort == 'My Team-Account Team'){
            userSet = getMyteamUser();
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
            if(acctTeamacctIdSet.size() <= 0) return new list<Monthly_Forecast_Input__c>();
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        }
        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereStr +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }
        String orderBy = ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC';
        String queryStrCurrent = Fields + whereStr + orderBy;
        list<Monthly_Forecast_Input__c> newdealList = Database.query(queryStrCurrent);
        for (Monthly_Forecast_Input__c MFI : newdealList) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(MFI.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                MFI.Customer__r.Owner.Region__c = 'Other';
                MFI.Customer__r.Owner.Zone__c = 'Other';
            }
            MFI.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            MFI.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }
        return newdealList;
    }

    public static list<Target__c> getTargetReport4(String strYear ,String CustomerPort, Set<String> searchTeamSet) { 
        Integer year = integer.valueof(strYear);
        Id currentUserId = currentUser.Id;
        String currentUserZoneCode = currentUser.Zone_Code__c;
        String Fields = 'SELECT NI_Target_Monthly__c, TargetFeeAmount__c, TargetNIIdAmount__c, TargetNIIcAmount__c, Owner.Name, Round_2_Target_NI_3_9__c, Round_3_Target_NI_6_6__c, Round_4_Target_NI_9_3__c, TargetFeeAmount_3_9__c, TargetFeeAmount_6_6__c, TargetFeeAmount_9_3__c, TargetNIIcAmount_3_9__c, TargetNIIcAmount_6_6__c, TargetNIIcAmount_9_3__c, TargetNIIdAmount_3_9__c, TargetNIIdAmount_6_6__c, TargetNIIdAmount_9_3__c,RM_Team_Code__c, Zone__c FROM Target__c ';
        String wherestr = ' WHERE CALENDAR_YEAR(Monthly_Target_Date__c) =:year AND RecordType.Name = \'NI Target\' ';
        if (CustomerPort != null && CustomerPort != '') {
            if (CustomerPort == 'My Customer') {
                wherestr += ' AND OwnerId = :currentUserId';
            } else if (CustomerPort == 'My Team') {
                wherestr +=' AND RM_Team_Code__c = :currentUserZoneCode';
            } else {
                wherestr +=' AND RM_Team_Code__c IN :searchTeamSet';                    
            }
        }
        String orderBy = '';
        String queryStrCurrent = Fields + whereStr + orderBy;
        //System.debug(queryStrCurrent);
        List<Target__c> listTarget = Database.query(queryStrCurrent);

        for (Target__c cube : listTarget) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.RM_Team_Code__c);
            if(regionZone == null) {
                cube.Zone__c = 'Other';
            }
            cube.Zone__c = regionZone.Team_Zone_Name__c;
        }

        return listTarget;
    }

    @AuraEnabled
    public static list<Forecast_Cube_2__c> getCube2Report4(String strYear ,String CustomerPort, List<String> searchTeam ) {   
        String Fields = 'SELECT Id, Name, Cube2Key__c, Customer__c, Customer__r.OwnerId, Customer__r.Owner.Zone__c, Customer__r.Owner.Zone_Code__c, Income_Type__c, NI_01__c, NI_02__c, NI_03__c, NI_04__c, NI_05__c, NI_06__c, NI_07__c, NI_08__c, NI_09__c, NI_10__c, NI_11__c, NI_12__c, Last_Year_Forecast_Cube_2__c , Year__c, LastModifiedDate ';
        String wherestr = ' FROM Forecast_Cube_2__c WHERE Year__c =:strYear ';
        String lastYear = ' ,Last_Year_Forecast_Cube_2__r.NI_01__c, Last_Year_Forecast_Cube_2__r.NI_02__c, Last_Year_Forecast_Cube_2__r.NI_03__c, Last_Year_Forecast_Cube_2__r.NI_04__c, Last_Year_Forecast_Cube_2__r.NI_05__c, Last_Year_Forecast_Cube_2__r.NI_06__c, Last_Year_Forecast_Cube_2__r.NI_07__c, Last_Year_Forecast_Cube_2__r.NI_08__c, Last_Year_Forecast_Cube_2__r.NI_09__c, Last_Year_Forecast_Cube_2__r.NI_10__c, Last_Year_Forecast_Cube_2__r.NI_11__c, Last_Year_Forecast_Cube_2__r.NI_12__c ';
        Set<String> searchTeamSet = new Set<String>();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Id currentUserId = currentUser.Id;
        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
            }
        }
        if (CustomerPort == 'My Customer') {
            whereStr += 'AND Customer__r.OwnerId =:currentUserId ';
        } else if (CustomerPort == 'My Team') {
            userSet = getMyteamUser();
            whereStr +=' AND Customer__r.OwnerId IN :userSet';
        } else if(CustomerPort == 'My Account Team'){
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.add(currentUser.Id);
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
            if(acctTeamacctIdSet.size() <= 0) return new List<Forecast_Cube_2__c>();
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        } else if(CustomerPort == 'My Team-Account Team'){
            userSet = getMyteamUser();
            acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
            if(acctTeamacctIdSet.size() <= 0) return new list<Forecast_Cube_2__c>();
            whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
        }
        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereStr +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet ';
        }
        
        String order = ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC ';
        String queryStrCurrent = Fields + lastYear + whereStr + order;
        //System.debug(queryStrCurrent);
        List<Forecast_Cube_2__c> listCube2 = Database.query(queryStrCurrent);
        for (Forecast_Cube_2__c cube : listCube2) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cube.Customer__r.Owner.Region__c = 'Other';
                cube.Customer__r.Owner.Zone__c = 'Other';
            }
            cube.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cube.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }
        return listCube2;
    }
    @AuraEnabled
    public static cube1WithTargetWrapperClass getReportByProductGroup(String strYear ,String CustomerPort, List<String> searchTeam, String productGroup) {   
        cube1WithTargetWrapperClass cube1WithUser= new cube1WithTargetWrapperClass();
        // cube1WithUser.userProfile = getUserProfile(currentUser.Profile.Name);
        cube1WithUser.listCube1 = new List<Forecast_Cube_1__c>(); 
        cube1WithUser.LastYearlistCube1 = new List<Forecast_Cube_1__c>();
        cube1WithUser.listTarget = new List<Target__c>();
        Set<String> remark = new Set<String>();
        Set<Id> userSet = new Set<Id>();
        Set<Id> acctTeamacctIdSet = new Set<Id>();
        Set<String> searchTeamSet = new Set<String>();
        Map<String, String> region = new Map<String, String>();
        String targetFields = '';

        if(searchTeam != null && searchTeam.size() > 0){
            for (String team : searchTeam) {
                searchTeamSet.add(team);
                // Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(team);
                // if(regionZone != null) searchTeamNameSet.add(regionZone.Team_Zone_Name__c);
            }
        }

        // List<Region_and_Zone_Mapping__c> regionZone = new List<Region_and_Zone_Mapping__c>([SELECT Id, Team_Zone_Code__c, Team_Zone_Name__c, Region_Group_Code__c, Region_Group_Name__c FROM Region_and_Zone_Mapping__c WHERE Team_Zone_Code__c IN :searchTeamSet]);
        // if(regionZone != null && regionZone.size() > 0){
        //     for (Region_and_Zone_Mapping__c team : regionZone) {
        //         searchTeamNameSet.add(team.Team_Zone_Name__c);
        //         region.put(team.Team_Zone_Name__c, team.Region_Group_Name__c);
        //     }
        // }

        if (productGroup == 'Credit') {
            remark.add('LT Loan');
            remark.add('ST Loan'); 

            targetFields = 'SELECT NI_Target_Monthly__c, TargetNIIcAmount__c, OwnerId, Owner.Name, RM_Team_Code__c, Zone__c, TargetNIIcAmount_3_9__c, TargetNIIcAmount_6_6__c, TargetNIIcAmount_9_3__c FROM Target__c ';
        } else if (productGroup == 'Deposit') {
            remark.add('CASA');
            remark.add('Non-CASA'); 

            targetFields = 'SELECT NI_Target_Monthly__c, TargetNIIdAmount__c, OwnerId, Owner.Name, RM_Team_Code__c, Zone__c, TargetNIIdAmount_3_9__c, TargetNIIdAmount_6_6__c, TargetNIIdAmount_9_3__c FROM Target__c ';
        }
        Integer year = integer.valueof(strYear);
        String strLastYear = String.valueof(year - 1);
        String wherestrTarget = ' WHERE CALENDAR_YEAR(Monthly_Target_Date__c) =:year ';
        //System.debug('strYear:::'+strYear);
        //System.debug('CustomerPort:::'+CustomerPort);
        //System.debug('searchTeam:::'+searchTeam);   
        String currentYear = 'SELECT Customer__r.OwnerId, Customer__r.Owner.Name, Customer__r.Owner.Zone__c, Customer__r.Owner.Zone_Code__c, Customer__r.Owner.Region__c, Customer__r.Owner.Region_Code__c, Year__c, Product__c, Product__r.Remark__c, Product__r.Sub_Remark__c,Customer__c, Limit__c, Ending_Balance_01__c, Ending_Balance_02__c, Ending_Balance_03__c, Ending_Balance_04__c, Ending_Balance_05__c, Ending_Balance_06__c, Ending_Balance_07__c, Ending_Balance_08__c, Ending_Balance_10__c, Ending_Balance_09__c, Ending_Balance_11__c, Ending_Balance_12__c, Average_Balance_01__c, Average_Balance_02__c, Average_Balance_03__c, Average_Balance_04__c, Average_Balance_05__c, Average_Balance_06__c, Average_Balance_07__c, Average_Balance_08__c, Average_Balance_09__c, Average_Balance_10__c, Average_Balance_11__c, Average_Balance_12__c, NI_01__c, NI_02__c, NI_03__c, NI_04__c, NI_05__c, NI_06__c, NI_07__c, NI_08__c, NI_09__c, NI_10__c, NI_11__c, NI_12__c, FTP_01__c, FTP_02__c, FTP_03__c, FTP_04__c, FTP_05__c, FTP_06__c, FTP_07__c, FTP_08__c, FTP_09__c, FTP_10__c, FTP_11__c, FTP_12__c, Interest_Income_01__c, Interest_Income_02__c, Interest_Income_03__c, Interest_Income_04__c, Interest_Income_05__c, Interest_Income_06__c, Interest_Income_07__c, Interest_Income_08__c, Interest_Income_09__c, Interest_Income_10__c, Interest_Income_11__c, Interest_Income_12__c ';
        
        String lastYear = 'SELECT Customer__r.OwnerId, Customer__r.Owner.Name, Customer__r.Owner.Zone__c, Customer__r.Owner.Zone_Code__c, Customer__r.Owner.Region__c, Customer__r.Owner.Region_Code__c, Year__c, Product__c, Product__r.Remark__c, Product__r.Sub_Remark__c,Customer__c, Limit__c, Ending_Balance_01__c, Ending_Balance_02__c, Ending_Balance_03__c, Ending_Balance_04__c, Ending_Balance_05__c, Ending_Balance_06__c, Ending_Balance_07__c, Ending_Balance_08__c, Ending_Balance_10__c, Ending_Balance_09__c, Ending_Balance_11__c, Ending_Balance_12__c, Average_Balance_01__c, Average_Balance_02__c, Average_Balance_03__c, Average_Balance_04__c, Average_Balance_05__c, Average_Balance_06__c, Average_Balance_07__c, Average_Balance_08__c, Average_Balance_09__c, Average_Balance_10__c, Average_Balance_11__c, Average_Balance_12__c, NI_01__c, NI_02__c, NI_03__c, NI_04__c, NI_05__c, NI_06__c, NI_07__c, NI_08__c, NI_09__c, NI_10__c, NI_11__c, NI_12__c, FTP_01__c, FTP_02__c, FTP_03__c, FTP_04__c, FTP_05__c, FTP_06__c, FTP_07__c, FTP_08__c, FTP_09__c, FTP_10__c, FTP_11__c, FTP_12__c, Interest_Income_01__c, Interest_Income_02__c, Interest_Income_03__c, Interest_Income_04__c, Interest_Income_05__c, Interest_Income_06__c, Interest_Income_07__c, Interest_Income_08__c, Interest_Income_09__c, Interest_Income_10__c, Interest_Income_11__c, Interest_Income_12__c ';
        // String lastYear = ' Last_Year_Forecast_Cube_1__r.Ending_Balance_01__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_02__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_03__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_04__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_05__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_06__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_07__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_08__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_10__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_09__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_11__c, Last_Year_Forecast_Cube_1__r.Ending_Balance_12__c, Last_Year_Forecast_Cube_1__r.Average_Balance_01__c, Last_Year_Forecast_Cube_1__r.Average_Balance_02__c, Last_Year_Forecast_Cube_1__r.Average_Balance_03__c, Last_Year_Forecast_Cube_1__r.Average_Balance_04__c, Last_Year_Forecast_Cube_1__r.Average_Balance_05__c, Last_Year_Forecast_Cube_1__r.Average_Balance_06__c, Last_Year_Forecast_Cube_1__r.Average_Balance_07__c, Last_Year_Forecast_Cube_1__r.Average_Balance_08__c, Last_Year_Forecast_Cube_1__r.Average_Balance_09__c, Last_Year_Forecast_Cube_1__r.Average_Balance_10__c, Last_Year_Forecast_Cube_1__r.Average_Balance_11__c, Last_Year_Forecast_Cube_1__r.Average_Balance_12__c, Last_Year_Forecast_Cube_1__r.NI_01__c, Last_Year_Forecast_Cube_1__r.NI_02__c, Last_Year_Forecast_Cube_1__r.NI_03__c, Last_Year_Forecast_Cube_1__r.NI_04__c, Last_Year_Forecast_Cube_1__r.NI_05__c, Last_Year_Forecast_Cube_1__r.NI_06__c, Last_Year_Forecast_Cube_1__r.NI_07__c, Last_Year_Forecast_Cube_1__r.NI_08__c, Last_Year_Forecast_Cube_1__r.NI_09__c, Last_Year_Forecast_Cube_1__r.NI_10__c, Last_Year_Forecast_Cube_1__r.NI_11__c, Last_Year_Forecast_Cube_1__r.NI_12__c, Last_Year_Forecast_Cube_1__r.FTP_01__c, Last_Year_Forecast_Cube_1__r.FTP_02__c, Last_Year_Forecast_Cube_1__r.FTP_03__c, Last_Year_Forecast_Cube_1__r.FTP_04__c, Last_Year_Forecast_Cube_1__r.FTP_05__c, Last_Year_Forecast_Cube_1__r.FTP_06__c, Last_Year_Forecast_Cube_1__r.FTP_07__c, Last_Year_Forecast_Cube_1__r.FTP_08__c, Last_Year_Forecast_Cube_1__r.FTP_09__c, Last_Year_Forecast_Cube_1__r.FTP_10__c, Last_Year_Forecast_Cube_1__r.FTP_11__c, Last_Year_Forecast_Cube_1__r.FTP_12__c, Last_Year_Forecast_Cube_1__r.Interest_Income_01__c, Last_Year_Forecast_Cube_1__r.Interest_Income_02__c, Last_Year_Forecast_Cube_1__r.Interest_Income_03__c, Last_Year_Forecast_Cube_1__r.Interest_Income_04__c, Last_Year_Forecast_Cube_1__r.Interest_Income_05__c, Last_Year_Forecast_Cube_1__r.Interest_Income_06__c, Last_Year_Forecast_Cube_1__r.Interest_Income_07__c, Last_Year_Forecast_Cube_1__r.Interest_Income_08__c, Last_Year_Forecast_Cube_1__r.Interest_Income_09__c, Last_Year_Forecast_Cube_1__r.Interest_Income_10__c, Last_Year_Forecast_Cube_1__r.Interest_Income_11__c, Last_Year_Forecast_Cube_1__r.Interest_Income_12__c ';        

        String Fields = currentYear + 'FROM Forecast_Cube_1__c ';
        String FieldsLastYear = lastYear + 'FROM Forecast_Cube_1__c ';
        String whereStr = 'WHERE Product__r.Financial_Product_Domain__c = :productGroup AND Product__r.Remark__c IN :remark AND Year__c =:strYear ';
        String whereStrLastYear = 'WHERE Product__r.Financial_Product_Domain__c = :productGroup AND Product__r.Remark__c IN :remark AND Year__c =:strLastYear ';
        Id currentUserId = currentUser.Id;
        String currentUserZoneCode = currentUser.Zone_Code__c;
        if (CustomerPort != null && CustomerPort != '') {
            if (CustomerPort == 'My Customer') {
                whereStr += ' AND Customer__r.OwnerId = :currentUserId';
                whereStrLastYear += ' AND Customer__r.OwnerId = :currentUserId';
            } else if (CustomerPort == 'My Team') {
                userSet = getMyteamUser();
                whereStr +=' AND Customer__r.OwnerId IN :userSet';
                whereStrLastYear +=' AND Customer__r.OwnerId IN :userSet';
            } else if(CustomerPort == 'My Account Team'){
                Set<Id> userIdSet = new Set<Id>();
                userIdSet.add(currentUser.Id);
                acctTeamacctIdSet = getAcctTeamAcctIdSet(userIdSet);
                if(acctTeamacctIdSet.size() <= 0) return cube1WithUser;
                whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
                whereStrLastYear += ' AND Customer__c IN :acctTeamacctIdSet';
            } else if(CustomerPort == 'My Team-Account Team'){
                userSet = getMyteamUser();
                acctTeamacctIdSet = getAcctTeamAcctIdSet(userSet);
                if(acctTeamacctIdSet.size() <= 0) return cube1WithUser;
                whereStr += ' AND Customer__c IN :acctTeamacctIdSet';
                whereStrLastYear += ' AND Customer__c IN :acctTeamacctIdSet';
            }
        }
        if (searchTeamSet != null && searchTeamSet.size() > 0){
            whereStr +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet';
            whereStrLastYear +=' AND Customer__r.Owner.Zone_Code__c IN :searchTeamSet';
        }

        whereStr += ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC ';
        whereStrLastYear += ' ORDER BY Customer__r.Owner.Zone_Code__c ASC , Customer__r.Owner.Name ASC ';
        
        String queryStrCurrent = Fields + whereStr;
        //System.debug(queryStrCurrent);
        cube1WithUser.listCube1 = Database.query(queryStrCurrent);

        String queryStrLastYear = FieldsLastYear + whereStrLastYear;
        //System.debug(queryStrLastYear);
        cube1WithUser.LastYearlistCube1 = Database.query(queryStrLastYear);
        
        for (Forecast_Cube_1__c cube : cube1WithUser.listCube1) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cube.Customer__r.Owner.Region__c = 'Other';
                cube.Customer__r.Owner.Zone__c = 'Other';
            }
            cube.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cube.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }

        for (Forecast_Cube_1__c cubeLastYeat : cube1WithUser.LastYearlistCube1) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cubeLastYeat.Customer__r.Owner.Zone_Code__c);
            if(regionZone == null) {
                cubeLastYeat.Customer__r.Owner.Region__c = 'Other';
                cubeLastYeat.Customer__r.Owner.Zone__c = 'Other';
            }
            cubeLastYeat.Customer__r.Owner.Region__c = regionZone.Region_Group_Name__c;
            cubeLastYeat.Customer__r.Owner.Zone__c = regionZone.Team_Zone_Name__c;
        }

        if (CustomerPort != null && CustomerPort != '') {
            if (CustomerPort == 'My Customer') {
                wherestrTarget += ' AND OwnerId = :currentUserId';
            } else if (CustomerPort == 'My Team') {
                wherestrTarget +=' AND RM_Team_Code__c = :currentUserZoneCode';
            } else {
                wherestrTarget +=' AND RM_Team_Code__c IN :searchTeamSet';                    
            }
        }

        String queryStrTarget = targetFields + wherestrTarget;
        //System.debug(queryStrTarget);
        cube1WithUser.listTarget = Database.query(queryStrTarget);

        for (Target__c cube : cube1WithUser.listTarget) {
            Region_and_Zone_Mapping__c regionZone = regionZoneMapping.get(cube.RM_Team_Code__c);
            if(regionZone == null) {
                cube.Zone__c = 'Other';
            }
            cube.Zone__c = regionZone.Team_Zone_Name__c;
        }

        return cube1WithUser;
    }

    @AuraEnabled
    public static string getCustomerPort() {
        return ForecastAdjustmentController.getUserPortOptionPermission();
    }

    public static Set<Id> getMyteamUser(){
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{currentUser.UserRoleId});
        Map<Id,User> users = new Map<Id, User>([SELECT Id, Name FROM User WHERE UserRoleId IN :allSubRoleIds AND isActive = true]);
        users.put(currentUser.Id,currentUser);
        return users.keySet();
    }

    public static Set<Id> getAcctTeamAcctIdSet(Set<Id> userIdSet){
        Set<Id> result = new Set<Id>();

        for(AccountTeamMember acctTeam : [SELECT Id, AccountId, UserId, TeamMemberRole, Title, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel  FROM AccountTeamMember WHERE UserId IN :userIdSet]){
            result.add(acctTeam.AccountId);
        }
        //System.debug(result);
        return result;
    }

    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
    
        return currentRoleIds;
    }
}