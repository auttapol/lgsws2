public class T_PerformanceController {
    
    public class PerformanceWrapper{
        @AuraEnabled
        public Map<String,List<Branch_Performance_by_Pillar__c>> branchPerformance;
        @AuraEnabled
        public List<Team_Profile_and_KPI__c> teamProfile;
        @AuraEnabled
        public List<Sale_Info__c> saleInfo;
        @AuraEnabled
        public List<Sale_Performance__c> salePerformance;
        @AuraEnabled
        public List<Sale_Transaction__c> salesTransaction;
        
    }

    public class UserInfoWrapper{
        @AuraEnabled
        public User user; 
        @AuraEnabled
        public String page; 
        @AuraEnabled
        public String landingPageCriteria; 
        @AuraEnabled
        public String userChannel; 
        @AuraEnabled
        public List<String> userChannelList; 
        @AuraEnabled
        public String regionCodeName; 
        @AuraEnabled
        public String zoneCodeName; 
        @AuraEnabled
        public Boolean isChannelDisable; 
        @AuraEnabled
        public Boolean isRegionDisable; 
        @AuraEnabled
        public Boolean isZoneDisable; 
    }

    public static List<T_Performance_Permission__mdt> tperf_Permission{
        get{
            if(tperf_Permission == null){
                tperf_Permission = [SELECT Label,Channel__c,Landing_Page__c,P1__c,P2__c,P3__c,P4__c,SF_Profile__c,SF_Role__c,isChannelDisable__c,isRegionDisable__c,isZoneDisable__c FROM T_Performance_Permission__mdt];    
            }
            return tperf_Permission;
        }
        set;
    }
    
    @AuraEnabled
    public static UserInfoWrapper getUserInfo(){
        try {
            User user = [SELECT Id, FirstName, LastName, RTL_Branch__c, RTL_Branch_Code__c, UserRoleName__c,RTL_Channel__c,Profile.Name,Employee_ID__c,Region_Code__c,Zone_Code__c FROM User WHERE Id =: UserInfo.getUserId()];
            // List<T_Performance_Team_List__c> teamList = [SELECT Id, Name, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Name__c, Zone_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c, Channel__c , Branch_Team_Code__c, Branch_Team_Name__c
            // FROM T_Performance_Team_List__c WHERE Region_Code__c =: user.Region_Code__c OR Zone_Code__c =: user.Zone_Code__c LIMIT 1];
            List<T_Performance_Team_List__c> teamList = new List<T_Performance_Team_List__c>();
            Set<String> channelSet = new Set<String>();
            List<String> channelList = new List<String>();
            System.debug('Role Name'+user.UserRoleName__c);
            System.debug('Profile Name'+user.Profile.Name);
            
            String page = '';
            String landingPageCriteria = '';
            String userChannel = '';
            List<String> userChannelList = new List<String>();
            Boolean isChannelDisable = false;                     
            Boolean isRegionDisable = false;           
            Boolean isZoneDisable = false; 
            
            // for(T_Performance_Team_List__c tl : teamList)
            // {
            //     channelList.add(tl.Channel__c); 
            // }
            
            // channelList.addAll(channelSet);

            if(user.Profile.Name.contains('System Admin')) {
                System.debug('Role Name:'+user.UserRoleName__c);
                System.debug('Profile Name: '+user.Profile.Name);
                teamList = [SELECT Id, Name, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Name__c, Zone_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c, Channel__c , Branch_Team_Code__c, Branch_Team_Name__c
                FROM T_Performance_Team_List__c WHERE Region_Code__c =: user.Region_Code__c OR Zone_Code__c =: user.Zone_Code__c];

                for(T_Performance_Team_List__c tl : teamList) {
                    channelList.add(tl.Channel__c); 
                }

                page = 'LandingPage';         
                userChannel = 'Branch';
                userChannelList = channelList;
                userChannelList.sort();
            } else {
                for(T_Performance_Permission__mdt p : tperf_Permission)
                {
                    if(user.UserRoleName__c.startsWith(p.SF_Role__c) && user.Profile.Name == p.SF_Profile__c)
                    {
                        System.debug('Role Name'+user.UserRoleName__c);
                        System.debug('Profile Name'+user.Profile.Name);                
                        if(p.Channel__c != null)
                        {
                            user.RTL_Channel__c = p.Channel__c;
                            userChannel = p.Channel__c;
                            userChannelList = (p.Channel__c).split(';');
                            userChannelList.sort();
                        }
                        if(p.Landing_Page__c)
                        {
                            page = 'LandingPage';
                        }
                        else if(p.P4__c)
                        {
                            page = 'P4';
                        }
                        else if(p.P3__c)
                        {
                            page = 'P3';
                        }
                        else if(p.P1__c)
                        {
                            page = 'P1';
                        }
                        else if(p.P2__c)
                        {
                            page = 'P2';
                        }
                        isChannelDisable = p.isChannelDisable__c;                       
                        isRegionDisable = p.isRegionDisable__c;                       
                        isZoneDisable = p.isZoneDisable__c; 

                        if(isRegionDisable) {
                            if(isZoneDisable) {
                                // Emp: use region and zone code
                                teamList = [SELECT Id, Name, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Name__c, Zone_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c, Channel__c , Branch_Team_Code__c, Branch_Team_Name__c
                                FROM T_Performance_Team_List__c WHERE Region_Code__c =: user.Region_Code__c AND Zone_Code__c =: user.Zone_Code__c LIMIT 1];
                            } else {
                                // Head: use only region code
                                teamList = [SELECT Id, Name, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Name__c, Zone_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c, Channel__c , Branch_Team_Code__c, Branch_Team_Name__c
                                FROM T_Performance_Team_List__c WHERE Region_Code__c =: user.Region_Code__c ORDER BY Zone_Code_and_Name__c LIMIT 1];
                            }
                        } else {
                            teamList = [SELECT Id, Name, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Name__c, Zone_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c, Channel__c , Branch_Team_Code__c, Branch_Team_Name__c
                            FROM T_Performance_Team_List__c WHERE Channel__c =: user.RTL_Channel__c ORDER BY Region_Code_and_Name__c, Zone_Code_and_Name__c LIMIT 1];
                        }
                        break;
                    }
                    // else if(user.Profile.Name.contains('System Admin'))
                    // {
                    //     System.debug('Role Name:'+user.UserRoleName__c);
                    //     System.debug('Profile Name: '+user.Profile.Name);
                    //     page = 'LandingPage';         
                    //     userChannel = 'Branch';
                    //     // ไว้มาดูอีกที
                    //     // List<String> getChannelFromTeamList = new List<String>();
                    //     // getChannelFromTeamList = T_PerformanceController.getChannel();
                    //     // System.debug('getChannelFromTeamList: '+getChannelFromTeamList);
                    //     // String userChannelTemp = '';
                    //     // for(Integer i; i<getChannelFromTeamList.size();i++){
                    //     //     if(i+1 == getChannelFromTeamList.size()){
                    //     //         userChannelTemp += getChannelFromTeamList[i];
                    //     //     }else {
                    //     //         userChannelTemp += getChannelFromTeamList[i]+';';
                    //     //     }
                    //     // }
                    //     // System.debug('userChannelTemp: '+userChannelTemp);
                    //     // userChannel = userChannelTemp;     

                    //     // userChannel = 'Branch;Mortgage Loan Sales;Retail Advisory Line;Small Business Sales;Unsecured Lending Line;Wealth Banking';     
                    //     userChannelList = channelList;
                    //     userChannelList.sort();
                    // }
                    
                }
            }
            
                // // NEW ADD : Criteria

                //     // All Channel: Center
                //     if( user.UserRoleName__c.startsWith('CRBO') && user.Profile.Name == 'TMB Retail CRM Specialist' ){
                    //         //name example => Mukda Siriruangpanya But isActive = false
                //         landingPageCriteria = 'All';
                //         isChannelDisable = false;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                //     if( user.UserRoleName__c.startsWith('CRBO') && user.Profile.Name == 'TMB Retail Channel Sales' ){                 
                //         landingPageCriteria = 'All Branch';
                //         isChannelDisable = true;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                    
                //     if( user.UserRoleName__c.startsWith('Region') && user.Profile.Name == 'TMB Retail Channel Sales' ){
                //         landingPageCriteria = 'All Branch Region';
                //         isChannelDisable = true;                       
                //         isRegionDisable = true;                       
                //         isZoneDisable = false; 
                //     }
                //     if( user.UserRoleName__c.contains('Zone') && user.Profile.Name == 'TMB Retail Channel Sales' ){
                        
                //         landingPageCriteria = 'All Branch Region Zone';
                //         isChannelDisable = true;                       
                //         isRegionDisable = true;                       
                //         isZoneDisable = true; 
                //     }
                    
                //     if( user.UserRoleName__c.startsWith('CRBO') && user.Profile.Name == 'TMB Retail Wealth Management' ){
                //         landingPageCriteria = 'All Wealth';
                //         isChannelDisable = true;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                    
                //     if( user.UserRoleName__c.startsWith('WA-TEAM') && user.Profile.Name == 'TMB Retail Wealth Management' ){
                //         landingPageCriteria = 'All Wealth Region';
                //         isChannelDisable = true;                       
                //         isRegionDisable = true;                       
                //         isZoneDisable = false; 
                //     }                
                //     if( user.UserRoleName__c.startsWith('Head of Small Business Sales') && user.Profile.Name == 'TMB SE Group Head Profile' ){
                //         landingPageCriteria = 'All SBO';
                //         isChannelDisable = true;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                //     if( (user.UserRoleName__c.startsWith('SB2 RG') || user.UserRoleName__c.startsWith('SB1')) && user.Profile.Name == 'TMB SE Regional Manager Profile' ){
                //         //name example => no body    
                //         landingPageCriteria = 'All SBO Region';
                //         isChannelDisable = true;                       
                //         isRegionDisable = true;                       
                //         isZoneDisable = false; 
                //     }
                //     if( user.UserRoleName__c.startsWith('Head of Mortgage Loan') && user.Profile.Name == 'TMB Retail Channel Sales' ){  
                //         landingPageCriteria = 'All MortgageLoan';
                //         isChannelDisable = false;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                //     if( user.UserRoleName__c.startsWith('MGL-TH') && user.Profile.Name == 'TMB Retail Channel Sales' ){
                //         landingPageCriteria = 'All MortgageLoan Region';
                //         isChannelDisable = false;                       
                //         isRegionDisable = false;                       
                //         isZoneDisable = false; 
                //     }
                // // }
                // if(user.Profile.Name.contains('System Admin')){
                //     landingPageCriteria = 'All';
                //     isChannelDisable = false;                       
                //     isRegionDisable = false;                       
                //     isZoneDisable = false; 
                // }
                    
            UserInfoWrapper userInfoWrapper = new UserInfoWrapper();
            userInfoWrapper.user = user;
            userInfoWrapper.page = page;
            userInfoWrapper.landingPageCriteria = landingPageCriteria;
            userInfoWrapper.isChannelDisable  = isChannelDisable;                       
            userInfoWrapper.isRegionDisable = isRegionDisable;                       
            userInfoWrapper.isZoneDisable = isZoneDisable; 
            userInfoWrapper.userChannel = userChannel;
            userInfoWrapper.userChannelList = userChannelList;
            
            if(teamList.size() > 0)
            {
                userInfoWrapper.regionCodeName = teamList[0].Region_Code_and_Name__c;
                userInfoWrapper.zoneCodeName = teamList[0].Zone_Code_and_Name__c;
            }  
                                                      
            return userInfoWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> getRegionCodeAndName(String channel){
        try {
            List<T_Performance_Team_List__c> teamList = [SELECT Id, Name, Branch_Team_Code__c, Branch_Team_Name__c, Branch_Team_Manager__c, Channel__c, Region_Code__c, Zone_Code__c, Region_Code_and_Name__c, Zone_Code_and_Name__c
            FROM T_Performance_Team_List__c WHERE Channel__c =: channel Order By Region_Code_and_Name__c];
            Set<String> regionSet = new Set<String>();
            List<String> regionList = new List<String>();
            for(T_Performance_Team_List__c t : teamList)
            {
                regionSet.add(t.Region_Code_and_Name__c);
            }       
            regionList.addAll(regionSet);                                                       
            
            return regionList;  
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> getChannel(){
        try {
            List<T_Performance_Team_List__c> channelAll = [SELECT Id, Name, Branch_Team_Code__c, Branch_Team_Name__c, Branch_Team_Manager__c, Channel__c, Region_Code__c, Zone_Code__c FROM T_Performance_Team_List__c Order By Channel__c];
            Set<String> channelSet = new Set<String>();
            List<String> channelList = new List<String>();
            for(T_Performance_Team_List__c c : channelAll)
            {
                channelSet.add(c.Channel__c);
            }
            channelList.addAll(channelSet);
            System.debug('channelList: '+channelList);                                                      
            return channelList ;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> getBranchCodeAndName(String channel, String region ,String zone){
        try {
            String query = 'SELECT Id, Name, Branch_Team_Code__c, Branch_Team_Name__c, Branch_Team_Manager__c, Channel__c, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c'
            +' FROM T_Performance_Team_List__c'
            +' Where Channel__c =: channel';
            
            if(region != null && region != '')
            {
                region = '%'+region+'%';
                query += ' AND Region_Code_and_Name__c like :region';
            }
            if(zone != null && zone != '')
            {
                zone = '%'+zone+'%';
                System.debug('zone: '+zone);
                query += ' and Zone_Code_and_Name__c like :zone';
            }
            query += ' Order By Branch_Team_Code__c';
            
            
            System.debug('query: '+query);
            List<sObject> sobjList = Database.query(query);
            List<T_Performance_Team_List__c> teamList = (List<T_Performance_Team_List__c>)sobjList;
            
            Set<String> teamCodeAndNameSet = new Set<String>();
            List<String> teamCodeAndNameList = new List<String>();
            for(T_Performance_Team_List__c codeAndName : teamList)
            {
                teamCodeAndNameSet.add(codeAndName.Team_Code_and_Name__c);
            }
            teamCodeAndNameList.addAll(teamCodeAndNameSet);
                                                      
            return teamCodeAndNameList ;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<String> getZoneCodeAndName(String channel,String region){
        try {
            region = '%'+region+'%';
            List<T_Performance_Team_List__c> teamList = [SELECT Id, Name, Branch_Team_Code__c, Branch_Team_Name__c, Branch_Team_Manager__c, Channel__c, Region_Code__c, Zone_Code__c, Zone_Code_and_Name__c, Region_Code_and_Name__c
            FROM T_Performance_Team_List__c WHERE Channel__c =: channel AND Region_Code_and_Name__c Like : region Order By Zone_Code_and_Name__c];
            System.debug('teamList: '+teamList);
            Set<String> zoneSet = new Set<String>();
            List<String> zoneList = new List<String>();
            for(T_Performance_Team_List__c t : teamList)
            {
                zoneSet.add(t.Zone_Code_and_Name__c);
            }    
            zoneList.addAll(zoneSet);
                                                      
            return zoneList;                                                            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<T_Performance_Team_List__c> searchPerformanceTeamList( String channel, String region, String zone, String branchCode_BranchName, String branchCodeOrNameSearch )
    {   
        try 
        {
            String query = 'SELECT Id, Name, Branch_Team_Code__c, Branch_Team_Name__c, Branch_Team_Manager__c, Channel__c, Region_Code__c, Zone_Code__c, Team_Code_and_Name__c, Region_Code_and_Name__c, Zone_Code_and_Name__c' 
            +' FROM T_Performance_Team_List__c'
            +' WHERE Channel__c =: channel';
            System.debug('region:'+region);
            System.debug('zone:'+zone);
            System.debug('branchCode_BranchName:'+branchCode_BranchName); 
            
            if(region != null && region != '')
            {
                region = '%'+region+'%';
                query += ' AND Region_Code_and_Name__c Like :region';
            }
            if(zone != null && zone != '')
            {
                zone = '%'+zone+'%';
                System.debug('zone: '+zone);
                query += ' AND Zone_Code_and_Name__c Like :zone';
            }
            
            if(branchCode_BranchName != null && branchCode_BranchName != ''){
                
                query += ' AND Team_Code_and_Name__c =:branchCode_BranchName';
            }
            if(branchCodeOrNameSearch != null && branchCodeOrNameSearch != ''){
                branchCodeOrNameSearch = '%'+branchCodeOrNameSearch+'%';
                
                query += ' AND ( Branch_Team_Code__c Like :branchCodeOrNameSearch OR Branch_Team_Name__c Like :branchCodeOrNameSearch )';
            }
            
            query += ' Order By Branch_Team_Code__c';
            
            
            System.debug('query:'+query);
            List<sObject> sobjList = Database.query(query);
            System.debug('sobjList:'+sobjList);
            List<T_Performance_Team_List__c> teamLsit = (List<T_Performance_Team_List__c>)sobjList;
                                                                  
            return teamLsit;
            
        } catch (Exception e) {
            System.debug('Error:'+e);
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void insertTermOfUseLog(String status){
        User user =  [SELECT Id,Employee_ID__c,Profile.Name,UserRoleName__c,RTL_Branch_Code__c, Zone_Code__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        
        String branchTeamCode;
        for(T_Performance_Permission__mdt p : tperf_Permission)
        {
            if(user.UserRoleName__c.startsWith(p.SF_Role__c) && user.Profile.Name == p.SF_Profile__c)
            {
                if(p.Channel__c.contains('Branch')) {
                    // use branch code
                    branchTeamCode = user.RTL_Branch_Code__c;
                } else {
                    // use zone code
                    branchTeamCode = user.Zone_Code__c;
                }
            }
        }

        Datetime toDay = Datetime.now();
        Date dateFormat = toDay.date();
        Time timeFormat = Time.newInstance( toDay.hour() //hour
                                            ,toDay.minute() //min
                                            ,toDay.second()                                //sec
                                            ,toDay.millisecond());

        // User userData = getUserData();
        // System.debug('userData'+userData);
        T_Performance_Term_of_use_Log__c log = new   T_Performance_Term_of_use_Log__c();
        log.Emp_Id__c = user.Employee_ID__c;
        log.Date__c = dateFormat;
        log.Time__c = timeFormat;
        log.Branch_Team_code__c = branchTeamCode;
        log.Status__c = status;
        insert log;
        System.debug('log'+log);
    } 

    
    

}