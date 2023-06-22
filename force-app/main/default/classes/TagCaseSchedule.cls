global without sharing class TagCaseSchedule implements Schedulable {

    public static Integer CALL_LASTTIME{
        get{
            Integer DEFAULT_LASTTIME = -15;
            if(CALL_LASTTIME == null){
                try{
                    CALL_LASTTIME = DEFAULT_LASTTIME;
                    List<App_Config__mdt> scheduleRuntime = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'TagBatch_Schedule_Runtime'];           
                        if (scheduleRuntime != null && scheduleRuntime.size() > 0) {
                            CALL_LASTTIME = -Integer.valueOf(scheduleRuntime.get(0).Value__c);
                        }           
                        
                    }catch( Exception e ){
                        CALL_LASTTIME = DEFAULT_LASTTIME;
                    }
            }
            return CALL_LASTTIME;
            
        }set;
    }

    public TagCaseSchedule() {

    }

    //Schedulable Execute
    global void execute(SchedulableContext SC){
        /*
        List<Task> listTask = [SELECT Id, Call_Log_ID__c FROM Task WHERE Call_End_Time__c  != null AND CreatedDate = TODAY];
        
        List<String> idList = new List<String>();
        if(listTask.size() > 0){
            for(Task t : listTask){
                idList.add(t.Call_Log_ID__c);
            }
        }

        String idString = '(\''+String.join(idList, '\',\'')+'\')';
        //Within last 30 minutes - Batch runs every 15 minutes
        String timeRange = Datetime.now().addMinutes(-30).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = 'SELECT Id, Call_Log_ID__c, Owner_Employee_ID__c, CaseNumber, Category__c'+
                        ', Sub_Category__c, Product_Category__c, Issue__c, LastModifiedDate, Created_Email__c, Created_ID__c '+
                        'FROM Case '+
                        'WHERE LastModifiedDate > '+timeRange+ 
                        ' AND Call_Log_ID__c IN '+idString+
                        ' ORDER BY CreatedDate ASC';
        */


        /* Fixed for create case between call and create case after call */
        Integer lastTime = CALL_LASTTIME;
        Set<String> uniqueCallLogId = new Set<String>();
        
        System.debug('Datetime.now() --> ' + Datetime.now());

        // 1. Find case with end call in last 10 mins
        List<Task> listTask1 = [SELECT Id, Call_Log_ID__c FROM Task WHERE Call_End_Time__c != null AND Call_Log_ID__c != null AND LastModifiedDate > :Datetime.now().addMinutes(lastTime) AND RTL_Channel__c = 'Inbound Call'];
        
        List<String> idList = new List<String>();
        if(listTask1.size() > 0){
            for(Task t : listTask1){
                
                uniqueCallLogId.add(t.Call_Log_ID__c);
            }
            System.debug('Case 1 :: uniqueCallLogId-->' + uniqueCallLogId);
        }

        // 2. Find case with last modified in last 10 mins and call log id is not null and call log id have end time
        List<Case> caseList = [SELECT Id, Call_Log_ID__c, LastModifiedDate FROM Case WHERE Call_Log_ID__c != null AND LastModifiedDate > :Datetime.now().addMinutes(lastTime)];
        Set<String> caseCallIdList = new Set<String>();
        if(!caseList.isEmpty()){
            for(Case c : caseList){
                caseCallIdList.add(c.Call_Log_ID__c);
            }
            System.debug('Selected case for last modify from ' + Datetime.now().addMinutes(lastTime) + '-->' + caseCallIdList);
        }

        List<Task> listTask2 = [SELECT Id, Call_Log_ID__c, LastModifiedDate FROM Task WHERE Call_Log_ID__c in :caseCallIdList and Call_End_Time__c != null AND RTL_Channel__c = 'Inbound Call'];
        if(!caseList.isEmpty()){
            for(Task t : listTask2){
                
                uniqueCallLogId.add(t.Call_Log_ID__c);
            }

            System.debug('Case 2 :: uniqueCallLogId-->' + uniqueCallLogId);
        }

        if (!uniqueCallLogId.isEmpty()) {
            System.debug('uniqueCallLogId-->' + uniqueCallLogId);
            String idString = '(\''+String.join(new List<String>(uniqueCallLogId), '\',\'')+'\')';
            //Within last 30 minutes - Batch runs every 15 minutes
            
            String query = 'SELECT Id, Call_Log_ID__c, Owner_Employee_ID__c, CaseNumber, Category__c'+
                            ', Sub_Category__c, Product_Category__c, Issue__c, LastModifiedDate, Created_Email__c, Created_ID__c '+
                            'FROM Case '+
                            'WHERE Call_Log_ID__c IN '+idString+
                            ' ORDER BY CreatedDate ASC';

            System.debug('query-->' + query);

            List<Case> listcase = Database.query(query);
            //List<Case> inputlist = new List<Case>();
            System.debug('ALL size ' + listcase.size());
            
            Decimal roundPerSize = listcase.size() < 100 ? 1 : Decimal.valueOf(listcase.size()).divide(100, 2);
            Integer num = Integer.valueOf(roundPerSize);
            if(roundPerSize/num != 1){
                num++;
            }
            system.debug('Size/100 = '+ roundPerSize);
            system.debug('Round = ' + num);
         
            for(Integer i = 0 ; i<num ; i++){
                List<Case> inputlist = new List<Case>();

                Integer limitSize = 100;
                if(listcase.size() < 100){
                    limitSize = listcase.size();
                }
                System.debug('listcase size :' + limitSize);
                    for(Integer j = 0 ; j < limitSize ; j++){
                        System.debug(j + 'listcase ' + listcase[j]);
                        inputlist.add(listcase[j]);
                }
                System.debug('end');
                
                    for(Integer j = limitSize-1 ; j >= 0 ; j--){
                        System.debug(j + 'listcase ');
                        listcase.remove(j);
                }
                TagCaseBatch tcb = new TagCaseBatch(inputlist);
                Database.executeBatch(tcb);                
            }
  
        } 
    }
}