global class UserLoginHistory_Delete implements schedulable{

    global void execute(SchedulableContext sc){

        UserLoginHistoryLog__c ScheduleLog = new UserLoginHistoryLog__c();
        integer limitRemain = 9990;
        Date dDel = System.Today() - 45; 
        boolean sendMail = false;
        string bodyMail = '';      

        try {   

            list<UserLoginHistoryLog__c> delLog = [select id from UserLoginHistoryLog__c where log_date__C <: dDel];
            delete delLog;
    
            list<UserLoginHistoryLog__c> ListLog = [select id
                                                           , DeleteLoginHistoryAmount__c
                                                           , DeleteUserLoginHistoryAmount__c
                                                           , isError__c
                                                           , Log_Date__c
                                                           , Log_Description__c
                                                           , LoginAmount__c
                                                           , UserAmount__c
                                                    from UserLoginHistoryLog__c where Log_Date__c =: system.today()];
            
            if (ListLog.size() > 0){
                ScheduleLog = ListLog.get(0);   
            }else{
                ScheduleLog.Log_Date__c = system.today();
            }
            if (ScheduleLog.Log_Description__c == null) ScheduleLog.Log_Description__c = '';
            
        
            //Delete all records histories pass 45 days        
            List<User_Login_History__c> delHis = [Select ID, Name from User_Login_History__c where Date__c <: dDel limit 24000];           
            if(delHis.size() > 0){
                integer limitBalance = limitRemain - delHis.size();
                if (limitBalance >= 0){
                    ScheduleLog.DeleteUserLoginHistoryAmount__c = delHis.size();
                    Delete delHis;
                    ScheduleLog.Log_Description__c += ' | Success Delete User_Login_History__c ';
                }else{
                    ScheduleLog.isError__c = true;
                    ScheduleLog.Log_Description__c += ' | Over Limit - Delete User_Login_History__c size = '+delHis.size();
                    sendMail = true;
                    bodyMail = 'Over Limit - Delete User_Login_History__c size = '+delHis.size();
                }
            }else{
                ScheduleLog.Log_Description__c += '| Success Delete User_Login_History__c Amount = 0 ';
                ScheduleLog.DeleteUserLoginHistoryAmount__c = 0;
            }
            

            limitRemain = limitRemain - Limits.getDMLRows();

            
            List<Login_History__c> delLoginH = [Select ID, Name from Login_History__c where CreateDate_Date__c <: dDel limit 24000];
            if(delLoginH.size() > 0){
                integer limitBalance = limitRemain - delLoginH.size();
                if (limitBalance >= 0){
                    ScheduleLog.DeleteLoginHistoryAmount__c = delLoginH.size();
                    Delete delLoginH;
                    ScheduleLog.Log_Description__c += ' | Success Delete Login_History__c ';
                }else{
                    ScheduleLog.isError__c = true;
                    ScheduleLog.Log_Description__c += ' | Over Limit - Delete Login_History__c size = '+delLoginH.size();
                    sendMail = true;
                    bodyMail += '<br/>Over Limit - Delete Login_History__c size = '+delLoginH.size();
                }
            }else{
                ScheduleLog.Log_Description__c += '| Success Delete Login_History__c Amount = 0 ';
                ScheduleLog.DeleteLoginHistoryAmount__c = 0;
            }
            
            upsert ScheduleLog;
        }catch(exception ex){
            ScheduleLog.isError__c = true;
            ScheduleLog.Log_Description__c = 'Delete Error Exception Line : '+ex.getLineNumber()+' , Message : '+ex.getMessage();
            upsert ScheduleLog;
            sendMail = true;
            bodyMail = ScheduleLog.Log_Description__c;
        }
       
        if (sendMail){
            
            list<Messaging.SingleEmailMessage> ListEmail = new list<Messaging.SingleEmailMessage>();
            
            try {
                
                List<string> emails  = new List<string>();
                AppConfig__c appEmail = AppConfig__c.getValues('UserLoginHistoryEmail');
                if (null != appEmail) {
                    emails.addAll(appEmail.Value__c.split(';'));
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                mail.setToAddresses(emails);
                mail.setSubject('Schedule Job Delete User Login History Problem');
                mail.setHtmlBody(bodyMail);  
                mail.setSenderDisplayName('Salesforce Schedule Job System');
                
                ListEmail.add(mail);
                
            }catch(exception ex){
                system.debug(ex.getMessage());
            }
            
            Messaging.sendEmail(ListEmail);
        }
    }

}