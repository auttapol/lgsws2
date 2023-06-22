public class TaskTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    static Map<ID,Schema.RecordTypeInfo> rt_Map = Task.sObjectType.getDescribe().getRecordTypeInfosById();


    public static void handlerBeforeInsert(List<Task> tasksNew){
        List<Task> commercialTask = new List<Task>();
        for(Task t : tasksNew){
            if(!rt_map.get(t.recordTypeID).getName().containsIgnoreCase('Retail')){
                commercialTask.add(t);
            }
        }
        stampCustomerName(commercialTask); 
        
        assignReferralToTask(tasksNew);

        System.debug('new task ' + tasksNew.size());    
    }
    
    public static void handlerAfterInsert(List<Task> tasksNew){
        List<Task> listNew = checkConditionT02(tasksNew,null);
        if( listNew.size() > 0 ){
        	Trigger_T02( listNew ,null,STR_INSERT);    
        }
    }
    
    public static List<Task> checkConditionT02(List<Task> tasksNew,List<Task> tasksOld){
        List<Task> listReturn = new List<Task>();
        Map<Id,Task> mapTasksOld = new Map<Id,Task>();
        if( tasksOld != null && tasksOld.size() > 0 ){
            mapTasksOld.putAll(tasksOld);
        }
        
        for( Task t : tasksNew ){
            if( t.ActivityDate != null && t.Subject == 'Call' ){ 
                listReturn.add(t);
            }
        }
        
        return listReturn;
    }
    
    public static void Trigger_T02(List<Task> tasksNew,List<Task> tasksOld,String eventMode){
        System.debug(':::: Trigger_T02 Start ::::');
        List<Id> ids = new List<Id>();
        List<RecordType> listRecordType = [select Id from RecordType where name = 'Activities Target'];// '012N0000000D5FHIA0'; // id for Activities Target
        Id recordTypeId = listRecordType[0].Id; 
        Map<Id,Target__c> mapTargetForUpdate = new Map<Id,Target__c>();
        List<Id> listOwnerId = new List<Id>();
        List<String> listZone = new List<String>();
        List<Integer> listMonth = new List<Integer>();
        List<Integer> listYear = new List<Integer>();
        List<String> listMonthString = new List<String>();
        List<String> listYearString = new List<String>();
        for( Task t : tasksNew ){
            if(t.AccountId != null){
                ids.add(t.AccountId);
            }
            if(t.OwnerId != null){
                listOwnerId.add(t.OwnerId);
            }
            if(t.ActivityDate != null){
                listMonth.add( Integer.valueOf(String.valueOf(t.ActivityDate).substring(5,7)) );
                listYear.add( Integer.valueOf(String.valueOf(t.ActivityDate).substring(0,4)) );
                listMonthString.add( String.valueOf(Integer.valueOf(String.valueOf(t.ActivityDate).substring(5,7)) ) );
                listYearString.add( String.valueOf(Integer.valueOf(String.valueOf(t.ActivityDate).substring(0,4)) ) );
            }
        }
        
        Map<Id,User> listUser = new Map<Id,User>([select Id,Name,Zone__c  from User where Id IN :listOwnerId]);
        for(user u : listUser.values() ){
            if(u.Zone__c != null){
                listZone.add(u.Zone__c);    
            }
        }      
        Map<Id,Account> listAccount = new Map<Id,Account>([select Id,(SELECT ActivityDate
                                                                      FROM Tasks 
                                                                      WHERE Due_Date_M__c IN :listMonthString
                                                                      and Due_Date_Y__c IN :listYearString
                                                                      and Subject = 'Call'
                                                                      and OwnerId IN :listOwnerId
                                                                      and (Not RecordType.Name like '%Retail%'))  //Edit By: Danudath 3-11-2016
                                                           from account 
                                                           where Id IN :ids]);
        //System.debug('::>'+tasksNew);
        //System.debug('A ::>'+listAccount); 
        

        List<Target__c> listTarget = [select OwnerId,Monthly_Contacted_Actual__c,Zone__c
                                      from Target__c 
                                      where CALENDAR_MONTH(Monthly_Target_date__c) IN :listMonth
                                      and CALENDAR_YEAR(Monthly_Target_date__c) IN :listYear
                                      and OwnerId IN :listOwnerId
                                      and Zone__c IN :listZone
                                      and RecordTypeId = :recordTypeId];
        Map<String,Target__c> mapTarget = new Map<String,Target__c>();
        for( Target__c t : listTarget ){
            mapTarget.put(t.OwnerId,t);
        }        
        //System.debug('>>'+mapTarget);
        for( Task t : tasksNew ){
            Integer countFirstLogACall = 0;
            if(listAccount.containsKey(t.AccountId)){
                countFirstLogACall = listAccount.get(t.AccountId).Tasks.size();
            }
            
            System.debug('::::: task size is : '+countFirstLogACall +' :::::');
            if( t.ActivityDate != null && countFirstLogACall == 1 && t.Subject == 'Call' ){                
                String ownerId = t.OwnerId;//listAccount.get(t.AccountId).OwnerId;
                if( mapTarget.containsKey(ownerId) && !mapTargetForUpdate.containsKey(ownerId) ){
                    Decimal MonContActual = ( mapTarget.get(ownerId).Monthly_Contacted_Actual__c == null ) 
                        ? 0 : mapTarget.get(ownerId).Monthly_Contacted_Actual__c;
                    MonContActual += 1;
                    mapTarget.get(ownerId).Monthly_Contacted_Actual__c = MonContActual;
                    mapTargetForUpdate.put( ownerId , mapTarget.get(ownerId) );
                    System.debug('::::: OwnerId : '+ownerId + 
                                 ' Monthly_Contacted_Actual__c : '+mapTarget.get(ownerId).Monthly_Contacted_Actual__c);
                }else{
                    System.debug('::::: OwnerId : '+ownerId+' error contanskey in Target Or mapTargetForUpdate is duplicated ');
                }
            }
        }
        
        if(mapTargetForUpdate.size() > 0){
            try{
                update mapTargetForUpdate.values();
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        }
        
        System.debug('::::: List for update '+mapTargetForUpdate.size()+' row :::::');
        System.debug(':::: Trigger_T02 End ::::');        
    }
    //SME Call Me Now
    public static void assignReferralToTask(List<Task> newList){
        Set<Id> whatIdSet = new Set<Id>();
        Map<Id,RTL_Referral__c> referralMap;
        //loop through all new task to keep whatid in set
        for(Task t : newList){
            if(t.whatId != null){
                whatIdSet.add(t.whatId);
                System.debug('WHAT ID ::: '+t.whatId);
            }
        }

        //query referral from whatId
        referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,Name FROM RTL_Referral__c WHERE Id IN:whatIdSet]);

        for(Task t : newList){
            //If what id is refrral
            if(referralMap.containsKey(t.whatId)){
                //stamp on referral lookup field
                t.RTL_Referral__c = t.whatId;
            }
        }


    }

    public static void stampCustomerName(List<Task> newList){
        Set<Id> leadIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Lead> leadMap;
        Map<Id,Account> accountMap;
        for(Task t : newList){
            if(t.whoId != null){
                leadIdSet.add(t.WhoId);
            }else if(t.whatId != null){
                accountIdSet.add(t.WhatId);
            }
        }

        leadMap = new Map<Id,Lead>([Select ID, Company from Lead where ID IN : leadIdSet]);
        accountMap = new Map<Id,Account>([Select ID, Name from Account where ID IN : accountIdSet]);

        for(Task t : newList){
            if(t.whoId != null && leadMap.containsKey(t.whoId)){
                t.Customer_Name__c = leadMap.get(t.whoId).company;
            }else if(t.whatId != null && accountMap.containsKey(t.whatId)){
                t.Customer_Name__c = accountMap.get(t.whatId).Name;         
            }
        }
    }
}