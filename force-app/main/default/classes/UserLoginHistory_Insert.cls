global class UserLoginHistory_Insert implements schedulable{

    private Integer BATCHSIZE = 500;

    global void execute(SchedulableContext sc){

        UserLoginHistoryBatch_Insert batch = new  UserLoginHistoryBatch_Insert();
        Id BatchProcessIdForInt = Database.ExecuteBatch(batch,BATCHSIZE);
        
        // [2020-03-27] Old version remove
        // UserLoginHistoryLog__c ScheduleLog = new UserLoginHistoryLog__c();
        // list<UserLoginHistoryLog__c> ListLog = [select id
        //                                                , DeleteLoginHistoryAmount__c
        //                                                , DeleteUserLoginHistoryAmount__c
        //                                                , isError__c
        //                                                , Log_Date__c
        //                                                , Log_Description__c
        //                                                , LoginAmount__c
        //                                                , UserAmount__c
        //                                         from UserLoginHistoryLog__c where Log_Date__c =: system.today()];
        
        // if (ListLog.size() > 0){
        //     ScheduleLog = ListLog.get(0);   
        // }else{
        //     ScheduleLog.Log_Date__c = system.today();
        // }
        // if (ScheduleLog.Log_Description__c == null) ScheduleLog.Log_Description__c = '';
        // integer limitRemain = 9990;
        // integer counter = limitRemain;
        // string idUserRemain = '';
        // string idLoginHistoryRemain = '';
        // boolean sendMail = false;
        // string bodyMail = '';
    
        // try {
        //     //Select all active user
        //     List<User> userLog = [Select ID, Name, UserProfileName__c, UserRoleName__c, username, email, Employee_ID__c,
        //                             Segment__c, Reporting_Segment__c, Region__c, Region_Code__c,
        //                             Zone__c, Zone_Code__c, RTL_Branch__c, RTL_Branch_Code__c, RTL_Channel__c,
        //                             IsActive, LastLoginDate,UserType from User where IsActive =: True AND Employee_ID__c NOT IN ('99998','99999','00000')];  
        //     List<User_Login_History__c> newUserLogList = New  List<User_Login_History__c>();
        //     List<String> ExternalId = new List<String>();
        //     Map<ID,User> uMap = New Map<ID,User>();
        //     Set<ID> userID = New Set<Id>();
        //     for(User u : userLog){
        //          userID.add(u.id);
        //         counter--;
        //         if (counter >= 0){
                
        //             User_Login_History__c newUserLog = New User_Login_History__c();
        //             newUserLog.Name = u.Name;
        //             newUserLog.Active__c = u.IsActive;
        //             newUserlog.Profile__c = u.UserProfileName__c;
        //             newUserLog.Role__c = u.UserRoleName__c;
        //             newUserLog.Employee_ID__c = u.Employee_ID__c;
        //             newUserLog.Email__c = u.Email;           
        //             newUserLog.Segment__c = u.Segment__c;
        //             newUserLog.Reporting_Segment__c = u.Reporting_Segment__c;
        //             newUserLog.Region_Group__c = u.Region__c;
        //             newUserLog.Region_Code_Group_Code__c = u.Region_Code__c;
        //             newUserLog.Zone_Team__c = u.Zone__c;
        //             newUserLog.Zone_Code_Team_Code__c = u.Zone_Code__c;
        //             newUserLog.Branch_Team_Name_Code__c = u.RTL_Branch__c;
        //             newUserLog.Branch_Team_Code__c = u.RTL_Branch_Code__c;
        //             newUserLog.Channel__c = u.RTL_Channel__C;
        //             newUserLog.Date__c = System.today();            
        //             if(u.UserType != 'Standard'){
        //                 //Not assign owner, it will aotu to system admin 
        //             }else{
        //                 //newUserLog.OwnerId = u.id; 
        //                 uMap.put(u.id, u); //Add only user Standard to map for use in next query  
        //             }   
        //             newUserLog.Username__c = u.username; 
        //             newUserLog.External_ID__c = u.id+ String.valueOf(system.today());
        //             //Add all today external ID to list
        //             ExternalId.add(u.id+ String.valueOf(system.today())); 
                    
        //             Date loginDate;
        //             if(u.LastLoginDate != null ){
        //                 loginDate = date.newinstance(u.LastLoginDate.year(), u.LastLoginDate.month(), u.LastLoginDate.day());
                    
        //                 if(loginDate == System.today()){
        //                     newUserLog.IsLogin__c = True;                 
        //                 }else{
        //                     newUserLog.IsLogin__c = False;
        //                 }
        //             }else{
        //                 newUserLog.IsLogin__c = False;   
        //             }
        //             newUserLog.Last_Login_Time__c = u.LastLoginDate ;       
        //             newUserLogList.add(newUserLog);
                    
        //         }else{
        //             idUserRemain += u.id+';';
        //         }
                
        //     }// End for loop
        //     if(newUserLogList.size() > 0){
        //         ScheduleLog.UserAmount__c = newUserLogList.size(); 
        //         integer limitBalance = limitRemain - newUserLogList.size();
        //         if (limitBalance >= 0){
        //             insert newUserLogList; 
        //             ScheduleLog.Log_Description__c += '| Success Insert User_Login_History__c ';                   
        //         }
        //         /*else{
        //             ScheduleLog.isError__c = true;
        //             ScheduleLog.Log_Description__c += '| Over Limit - Insert User_Login_History__c size = '+newUserLogList.size();
        //             sendMail = true;
        //             bodyMail = ScheduleLog.Log_Description__c;
        //         }
        //         */
        //     }else{
        //         ScheduleLog.Log_Description__c += '| Success Insert User_Login_History__c Amount = 0 ';
        //         ScheduleLog.UserAmount__c = 0;
        //     }
            
        //     if (idUserRemain != ''){
        //         ScheduleLog.Log_Description__c += '| Over Limit - Remain User ID : ' + idUserRemain;
        //         sendMail = true;
        //         bodyMail += 'Over Limit - Remain User Id : <br/>' + idUserRemain;
        //     }


        //     limitRemain = limitRemain - Limits.getDMLRows();
        //     counter = limitRemain;
         
           
        //     //Select all record just created
        //     List<User_Login_History__c> mapUserLog = [Select ID,External_ID__c from User_Login_History__c where External_ID__c in: ExternalId ];
        //     Map<String, ID> mapID = New Map<String,ID>();
        //     if(mapUserLog.size() > 0){
        //         for(User_Login_History__c addMap : mapUserLog){
        //             mapID.put(addMap.External_ID__c, addMap.id);
        //         }
        //     }
            
        //     //Select all login today history
        //     List<LoginHistory> loginHistories = [SELECT ApiType,
        //                             ApiVersion,
        //                             Application,
        //                             Browser,
        //                             ClientVersion,
        //                             Id,
        //                             LoginTime,
        //                             LoginType,
        //                             LoginUrl,
        //                             Platform,
        //                             SourceIp,
        //                             Status,
        //                             UserId
        //                     FROM LoginHistory 
        //                     WHERE LoginTime > YESTERDAY AND UserID IN: userID
        //                     ];                                           
            
        //     List<Login_History__c> loginList = New List<Login_History__c>();
           
        //     for(LoginHistory loginH : loginHistories){
            
        //         counter--;
        //         if (counter >= 0){
                    
        //             Login_History__c loginP = new Login_History__c();
        //             loginP.Name = loginP.Id;
        //             loginP.ApiType__c = loginH.ApiType;
        //             loginP.ApiVersion__c = loginH.ApiVersion;
        //             loginP.Application__c = loginH.Application;
        //             loginP.Browser__c = loginH.Browser;
        //             loginP.ClientVersion__c = loginH.ClientVersion;
        //             loginP.LoginTime__c = loginH.LoginTime;
        //             loginP.LoginType__c = loginH.LoginType;
        //             loginP.Login_URL__c = loginH.LoginUrl;
        //             loginP.Platform__c = loginH.Platform;
        //             loginP.Source_IP__c = loginH.SourceIp;
        //             loginP.Status__c = loginH.status;
        //             loginP.CreateDate_Date__c = system.today();
        //             //Check only user salesforce license, because cannot assing log to Chatter free user
        //             if(uMap.get(loginH.UserId) != null ){
        //                 //loginP.OwnerId = loginH.UserId;              
        //             } 
        //             loginP.User_Login_History__c = mapID.get(loginH.UserId + String.valueOf(system.today()));            
        //             loginList.add(loginP);       
                    
        //         }else{
        //             idLoginHistoryRemain += loginH.id+';';
        //         }    
        //     }
                
        //     if(loginList.size() > 0){            
        //         ScheduleLog.LoginAmount__c = loginList.size(); 
        //         integer limitBalance = limitRemain - loginList.size();
        //         if (limitBalance >= 0){
        //             insert loginList; 
        //             ScheduleLog.Log_Description__c += '| Success Insert Login_History__c ';
        //         }
        //         /*else{
        //             ScheduleLog.isError__c = true;
        //             ScheduleLog.Log_Description__c += '| Over Limit - Insert Login_History__c size = '+loginList.size();
        //             sendMail = true;
        //             bodyMail = ScheduleLog.Log_Description__c;
        //         }
        //         */
        //     }else{
        //         ScheduleLog.Log_Description__c += '| Success Insert Login_History__c Amount = 0 ';
        //         ScheduleLog.LoginAmount__c = 0;
        //     }  
            
        //     if (idLoginHistoryRemain != ''){
        //         ScheduleLog.Log_Description__c += '| Over Limit -  Remain Login History ID : ' + idLoginHistoryRemain;
        //         sendMail = true;
        //         bodyMail += '<br/>Over Limit - Remain Login History ID : <br/>' + idLoginHistoryRemain;
        //     }
            
            
        //     upsert ScheduleLog;
        // }catch(exception ex){
        //     ScheduleLog.isError__c = true;
        //     ScheduleLog.Log_Description__c = 'Insert Error Exception Line : '+ex.getLineNumber()+' , Message : '+ex.getMessage();
        //     upsert ScheduleLog;
        //     sendMail = true;
        //     bodyMail = ScheduleLog.Log_Description__c;
        // } 
        
        // if (sendMail){
            
        //     list<Messaging.SingleEmailMessage> ListEmail = new list<Messaging.SingleEmailMessage>();
            
        //     try {
                
        //         List<string> emails  = new List<string>();
        //         AppConfig__c appEmail = AppConfig__c.getValues('UserLoginHistoryEmail');
        //         if (null != appEmail) {
        //             emails.addAll(appEmail.Value__c.split(';'));
        //         }
        //         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //         mail.setToAddresses(emails);
        //         mail.setSubject('Schedule Job Insert User Login History Problem');
        //         mail.setHtmlBody(bodyMail);  
        //         mail.setSenderDisplayName('Salesforce Schedule Job System');
                
        //         ListEmail.add(mail);
                
        //     }catch(exception ex){
        //         system.debug(ex.getMessage());
        //     }
            
        //     Messaging.sendEmail(ListEmail);
        // }
        // End Old version

        
    }

}