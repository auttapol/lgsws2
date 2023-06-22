global class UserLoginHistInsertScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        AppConfig__c cf = AppConfig__c.getValues('UserCode_API');
        String userCodeAPI = (cf == null ? '\'99998\',\'99999\',\'00000\'' : cf.Value__c);


    	String soqlUsr = 'Select ID, Name, UserProfileName__c, UserRoleName__c, username, email, Employee_ID__c, '
                                    +'Segment__c, Reporting_Segment__c, Region__c, Region_Code__c,'
                                    +'Zone__c, Zone_Code__c, RTL_Branch__c, RTL_Branch_Code__c, RTL_Channel__c,'
                                    +'IsActive, LastLoginDate,UserType from User where IsActive = True '
                                    + 'AND UserType = \'Standard\''
                                    + 'AND Employee_ID__c <> NULL AND Employee_ID__c NOT IN ('+userCodeAPI+')';

         if(Test.isRunningTest()){
            soqlUsr += ' LIMIT 20';
        }
                                    

        DailyScheduleBatch usrLoginInsert = new DailyScheduleBatch(soqlUsr
                                                                    ,DailyScheduleBatch.INSERT_USER_LOGIN_HEADER_HISORY_BATCH
                                                                    ,'User_Login_History__c'
                                                                    ,DailyScheduleBatch.INSERT_USER_LOGIN_DETAIL_HISORY_BATCH
                                                                    ,'CRM Admin 2'
                                                                    ,false);

        Id BatchProcessIdForCampExpr = Database.ExecuteBatch(usrLoginInsert);
    }
}