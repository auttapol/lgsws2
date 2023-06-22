global without sharing class Create_Case_Inquiry_Controller {
    
    global class PicklistWrapper{
        @AuraEnabled
        global Set<String> keyPTASegment{get;set;}
        @AuraEnabled
        global Map<String,Set<PicklistOption>> mapSVTMlvl1{get;set;}
        @AuraEnabled
        global Map<String,Set<PicklistOption>> mapSVTMlvl2{get;set;}
        @AuraEnabled
        global Map<String,Set<PicklistOption>> mapSVTMlvl3{get;set;}
        @AuraEnabled
        global Map<String,Set<PicklistOption>> mapSVTMlvl4{get;set;}
        @AuraEnabled
        global Map<String,Service_Type_Matrix__c> mapSVTM{get;set;}
    }

    public class PicklistOption{
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String label{get;set;}
    }

    @AuraEnabled
    public static PicklistWrapper getServiceTypeMatrix (){
        PicklistWrapper wrapper = new PicklistWrapper();
        List<Service_Type_Matrix__c> stm = new List<Service_Type_Matrix__c>([SELECT Id, Segment__c, 
        Service_Level1__c, Service_Level2__c, Service_Level3__c, Service_Level4__c,SMS_Code_Resolution_1__c, SMS_Code_Resolution_2__c,
        SMS_Code_Resolved__c, Service_Template__c, Resolution_2__c, Resolution_1__c,Journey__c,Validate_Code__c,Problem_Type__c 
        FROM Service_Type_Matrix__c WHERE Service_Level1__c = 'Inquiry' AND Active__c = true order by Service_Level1__c asc,Service_Level2__c asc,Service_Level3__c asc, Service_Level4__c asc]);
        Set<String> keySegment = new Set<String>();
        Map<String,PicklistOption> mapSegment = new Map<String,PicklistOption>();
        Map<String,Set<PicklistOption>> keySVTMlvl1 = new Map<String,Set<PicklistOption>>();
        Map<String,Set<PicklistOption>> keySVTMlvl2 = new Map<String,Set<PicklistOption>>();
        Map<String,Set<PicklistOption>> keySVTMlvl3 = new Map<String,Set<PicklistOption>>();
        Map<String,Set<PicklistOption>> keySVTMlvl4 = new Map<String,Set<PicklistOption>>();
        Map<String,Service_Type_Matrix__c> SVTM = new Map<String,Service_Type_Matrix__c>();
        for(Service_Type_Matrix__c m : stm){
            if (keySVTMlvl1.containsKey(m.Segment__c)){
                Boolean isExisting = false; // check have no in set
                Set<PicklistOption> tmpSet = keySVTMlvl1.get(m.Segment__c);
                for (PicklistOption picklist : tmpSet){
                    if (picklist.value == m.Service_Level1__c){
                        isExisting = true;
                        break;
                    }
                }
                if (!isExisting){
                    PicklistOption pl = new PicklistOption();
                    pl.value = m.Service_Level1__c;
                    pl.label = m.Service_Level1__c;
                    tmpSet.add(pl);
                }
            }else {
                Set<PicklistOption> tmpSet = new Set<PicklistOption>();
                PicklistOption pl = new PicklistOption();
                pl.value = m.Service_Level1__c;
                pl.label = m.Service_Level1__c;
                tmpSet.add(pl);
                keySVTMlvl1.put(m.Segment__c,tmpSet);

                keySegment.add(m.Segment__c);
            }
            if (keySVTMlvl2.containsKey(m.Service_Level1__c+':'+m.Segment__c)){
                Boolean isExisting = false; // check have no in set
                Set<PicklistOption> tmpSet = keySVTMlvl2.get(m.Service_Level1__c+':'+m.Segment__c);
                for (PicklistOption picklist : tmpSet){
                    if (picklist.value == m.Service_Level2__c){
                        isExisting = true;
                        break;
                    }
                }
                if (!isExisting){
                    PicklistOption pl = new PicklistOption();
                    pl.value = m.Service_Level2__c;
                    pl.label = m.Service_Level2__c;
                    tmpSet.add(pl);
                }
            }else {
                Set<PicklistOption> tmpSet = new Set<PicklistOption>();
                PicklistOption pl = new PicklistOption();
                pl.value = m.Service_Level2__c;
                pl.label = m.Service_Level2__c;
                tmpSet.add(pl);
                keySVTMlvl2.put(m.Service_Level1__c+':'+m.Segment__c,tmpSet);
            }
            if (keySVTMlvl3.containsKey(m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c)){
                Boolean isExisting = false; // check have no in set
                Set<PicklistOption> tmpSet = keySVTMlvl3.get(m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c);
                for (PicklistOption picklist : tmpSet){
                    if (picklist.value == m.Service_Level3__c){
                        isExisting = true;
                        break;
                    }
                }
                if (!isExisting){
                    PicklistOption pl = new PicklistOption();
                    pl.value = m.Service_Level3__c;
                    pl.label = m.Service_Level3__c;
                    tmpSet.add(pl);
                }
            }else {
                Set<PicklistOption> tmpSet = new Set<PicklistOption>();
                PicklistOption pl = new PicklistOption();
                pl.value = m.Service_Level3__c;
                pl.label = m.Service_Level3__c;
                tmpSet.add(pl);
                keySVTMlvl3.put(m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c,tmpSet);
            }
            if (keySVTMlvl4.containsKey(m.Service_Level3__c+':'+m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c)){
                Boolean isExisting = false; // check have no in set
                Set<PicklistOption> tmpSet = keySVTMlvl4.get(m.Service_Level3__c+':'+m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c);
                for (PicklistOption picklist : tmpSet){
                    if (picklist.value == m.Service_Level3__c){
                        isExisting = true;
                        break;
                    }
                }
                if (!isExisting){
                    PicklistOption pl = new PicklistOption();
                    pl.value = m.Service_Level4__c;
                    pl.label = m.Service_Level4__c;
                    tmpSet.add(pl);
                }
            }else {
                Set<PicklistOption> tmpSet = new Set<PicklistOption>();
                PicklistOption pl = new PicklistOption();
                pl.value = m.Service_Level4__c;
                pl.label = m.Service_Level4__c;
                tmpSet.add(pl);
                keySVTMlvl4.put(m.Service_Level3__c+':'+m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c,tmpSet);
            }
            SVTM.put(m.Service_Level4__c+':'+m.Service_Level3__c+':'+m.Service_Level2__c+':'+m.Service_Level1__c+':'+m.Segment__c,m);
        }

        wrapper.keyPTASegment = keySegment;
        wrapper.mapSVTMlvl1 = keySVTMlvl1;
        wrapper.mapSVTMlvl2 = keySVTMlvl2;
        wrapper.mapSVTMlvl3 = keySVTMlvl3;
        wrapper.mapSVTMlvl4 = keySVTMlvl4;
        wrapper.mapSVTM = SVTM;
        return wrapper;
    }

    @AuraEnabled
    public static List<Case> saveRecord(List<Case> caseList,Task taskObj){
        try {
            System.Debug('caseList: '+caseList);
            System.Debug('taskObj: '+taskObj);
            insert caseList;
            
            List<Task> updateTask = new List<Task>();
            if(taskObj != null)
            {
                if(taskObj.WhatId == null && taskObj.Id != null)
                {   
                    Task newTask = new Task();
                    newTask.Id = taskObj.Id;
                    newTask.WhatId = caseList.size() > 0? caseList[0].AccountId : null;
                    updateTask.add(newTask);
                }
            }
            if(updateTask.size() > 0)
            {
                update updateTask;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return caseList;
    }
    @AuraEnabled
    public static Task mappingCallLog() {
        Task callTask = new Task();
        try {
            User currentUser = [Select ID, Employee_ID__c from User where username = : userinfo.getUserName() limit 1];
            String userName = UserInfo.getUserName();
            String userId = currentUser.Employee_ID__c;
            List<Task> callTaskList =  [select ID, Call_Agent_Id__c, Call_Log_ID__c, Call_Start_Datetime__c, Call_Number__c,
                            recordtypeID, CreatedDate from Task WHERE Call_Agent_Id__c = :userId
                            AND CreatedDate >= : Datetime.now().addHours(-1)
                            AND RecordType.Name  = 'Call Log Record Type' AND Call_Log_ID__c != null
                            ORDER BY CreatedDate DESC LIMIT 1 ];
            System.Debug('callTaskList:'+callTaskList);
            if (callTaskList.size() > 0){
                callTask = callTaskList[0];
            }
            else {
                System.Debug('IS NULL');
            }
            return callTask;

        } catch (exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}