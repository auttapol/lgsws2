//Create by: Danudath Leebandit
//This class for write user login history log who login and not login every day 
global class UserLoginHistory implements Schedulable{

    global void execute(SchedulableContext sc){
        //Delete all records histories pass 45 days
       Date dDel = System.Today() - 45;            
       List<User_Login_History__c> delHis = [Select ID, Name from User_Login_History__c where Date__c <: dDel];           
        if(delHis.size() > 0){
            Delete delHis;
        }
     
       List<Login_History__c> delLoginH = [Select ID, Name from Login_History__c where  CreateDate_Date__c <: dDel];
        if(delLoginH.size() > 0){
            Delete delLoginH;
        } 

         //Select all active user
       List<User> userLog = [Select ID, Name, UserProfileName__c, UserRoleName__c, username, email, Employee_ID__c,
                            Segment__c, Reporting_Segment__c, Region__c, Region_Code__c,
                            Zone__c, Zone_Code__c, RTL_Branch__c, RTL_Branch_Code__c, RTL_Channel__c,
                            IsActive, LastLoginDate,UserType from User where IsActive =: True];  
        
        List<User_Login_History__c> newUserLogList = New  List<User_Login_History__c>();
        List<String> ExternalId = new List<String>();
        Map<ID,User> uMap = New Map<ID,User>();
        for(User u : userLog){
            User_Login_History__c newUserLog = New User_Login_History__c();
            newUserLog.Name = u.Name;
            newUserLog.Active__c = u.IsActive;
            newUserlog.Profile__c = u.UserProfileName__c;
            newUserLog.Role__c = u.UserRoleName__c;
            newUserLog.Employee_ID__c = u.Employee_ID__c;
            newUserLog.Email__c = u.Email;           
            newUserLog.Segment__c = u.Segment__c;
            newUserLog.Reporting_Segment__c = u.Reporting_Segment__c;
            newUserLog.Region_Group__c = u.Region__c;
            newUserLog.Region_Code_Group_Code__c = u.Region_Code__c;
            newUserLog.Zone_Team__c = u.Zone__c;
            newUserLog.Zone_Code_Team_Code__c = u.Zone_Code__c;
            newUserLog.Branch_Team_Name_Code__c = u.RTL_Branch__c;
            newUserLog.Branch_Team_Code__c = u.RTL_Branch_Code__c;
            newUserLog.Channel__c = u.RTL_Channel__C;
            newUserLog.Date__c = System.today();            
            if(u.UserType != 'Standard'){
               //Not assign owner, it will aotu to system admin 
            }else{
               //newUserLog.OwnerId = u.id; 
               uMap.put(u.id, u); //Add only user Standard to map for use in next query  
            }   
            newUserLog.Username__c = u.username; 
            newUserLog.External_ID__c = u.id+ String.valueOf(system.today());
            //Add all today external ID to list
            ExternalId.add(u.id+ String.valueOf(system.today())); 
            
            Date loginDate;
            if(u.LastLoginDate != null ){
                loginDate = date.newinstance(u.LastLoginDate.year(), u.LastLoginDate.month(), u.LastLoginDate.day());
                
                if(loginDate == System.today()){
                    newUserLog.IsLogin__c = True;                 
                }else{
                    newUserLog.IsLogin__c = False;
                }
            }else{
                newUserLog.IsLogin__c = False;   
            }
            newUserLog.Last_Login_Time__c = u.LastLoginDate ;            
            newUserLogList.add(newUserLog);
        }// End for loop
        
        if(newUserLogList.size() > 0){
           insert newUserLogList; 
        } 
        
        //Select all record just created
        List<User_Login_History__c> mapUserLog = [Select ID,External_ID__c from User_Login_History__c where External_ID__c in: ExternalId ];
        Map<String, ID> mapID = New Map<String,ID>();
        if(mapUserLog.size() > 0){
            for(User_Login_History__c addMap : mapUserLog){
                mapID.put(addMap.External_ID__c, addMap.id);
            }
        }
        
         //Select all login today history
        List<LoginHistory> loginHistories = [SELECT ApiType,
                                                    ApiVersion,
                                                    Application,
                                                    Browser,
                                                    ClientVersion,
                                                    Id,
                                                    LoginTime,
                                                    LoginType,
                                                    LoginUrl,
                                                    Platform,
                                                    SourceIp,
                                                    Status,
                                                    UserId
                                            FROM LoginHistory
                                            WHERE LoginTime > YESTERDAY
                                            ];                                           
        
        List<Login_History__c> loginList = New List<Login_History__c>();
        
        for(LoginHistory loginH : loginHistories){
            Login_History__c loginP = new Login_History__c();
            loginP.Name = loginP.Id;
            loginP.ApiType__c = loginH.ApiType;
            loginP.ApiVersion__c = loginH.ApiVersion;
            loginP.Application__c = loginH.Application;
            loginP.Browser__c = loginH.Browser;
            loginP.ClientVersion__c = loginH.ClientVersion;
            loginP.LoginTime__c = loginH.LoginTime;
            loginP.LoginType__c = loginH.LoginType;
            loginP.Login_URL__c = loginH.LoginUrl;
            loginP.Platform__c = loginH.Platform;
            loginP.Source_IP__c = loginH.SourceIp;
            loginP.Status__c = loginH.status;
            loginP.CreateDate_Date__c = system.today();
            //Check only user salesforce license, because cannot assing log to Chatter free user
            if(uMap.get(loginH.UserId) != null ){
                //loginP.OwnerId = loginH.UserId;            	
            } 
            loginP.User_Login_History__c = mapID.get(loginH.UserId + String.valueOf(system.today()));            
            loginList.add(loginP);           
        }
        
        if(loginList.size() > 0){            
            try{
                insert loginList;
            }catch(exception e){                
            }
        }   
    }
}