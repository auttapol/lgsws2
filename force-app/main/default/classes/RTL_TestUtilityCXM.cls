@isTest
public with sharing class RTL_TestUtilityCXM { 
    static {
        createCXMEndpointCustomSetting();
    } 

    private static void createCXMEndpointCustomSetting(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_ENDPOINT';
        Aconfig.Value__c = 'https://sfmashupservices.fortestclass.com/common/CXM_FORTEST/UAT_FORTEST/CXMGateway/ForwardTaskEvent';        
        apps.add(Aconfig);

        insert apps;
    }

    public static Task cxmCreateTask(Boolean doInsert) {
                
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        
        Task taskObj = new Task();
        taskObj.RecordTypeId = '01290000000iZYVAA2';
        taskObj.RTL_Task_Subject__c = 'Portfolio Review';
        taskObj.RTL_Task_Created_Zone_Code__c = retailUser.Zone_Code__c;
        taskObj.RTL_Task_Created_Region_Code__c = retailUser.Region_Code__c;
        taskObj.RTL_Task_Created_Emp_Id__c = retailUser.Employee_Id__c;
        taskObj.RTL_Task_Created_Channel__c = retailUser.RTL_Channel__c;
        taskObj.RTL_Task_Created_Branch_Code__c = retailUser.RTL_Branch_Code__c;
        taskObj.OwnerId = retailUser.Id;
        taskObj.ActivityDate = datetime.now().date();
        if(doInsert) {
            insert taskObj;
        }
        
        return taskObj;
    }
    
    public static void cxmUpdateTask(Task taskObj) {
                
        taskObj.RTL_Task_Subject__c = 'Call Visit';
        taskObj.ActivityDate = datetime.now().addDays(1).date();
        
        update taskObj;
    }
    
    
    public static Event cxmCreateEvent(Boolean doInsert) {
                
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        
        Event eventObj = new Event();
        eventObj.RecordTypeId = '01290000000iZYJAA2';
        eventObj.RTL_Event_Subject__c = 'Portfolio Review';
        eventObj.RTL_Event_Created_Zone_Code__c = retailUser.Zone_Code__c; //'7840';
        eventObj.RTL_Event_Created_Region_Code__c = retailUser.Region_Code__c; //'7800';
        eventObj.RTL_Event_Created_Emp_Id__c = retailUser.Employee_Id__c; //'44266';
        eventObj.RTL_Event_Created_Channel__c = retailUser.RTL_Channel__c; //'Branch';
        eventObj.RTL_Event_Created_Branch_Code__c = retailUser.RTL_Branch_Code__c; //'520';
        //eventObj.WhatId = acct.id;
        eventObj.OwnerId = retailUser.Id;//'00590000006SI35AAG';//'0050l000000IQch';
        eventObj.StartDateTime = datetime.now();
        eventObj.EndDateTime = datetime.now().addHours(1);
        if(doInsert) {
            insert eventObj;
        }
        
        return eventObj;
    }
    
    public static void cxmUpdateEvent(Event eventObj) {
                
        eventObj.RTL_Event_Subject__c = 'Call Visit';
        eventObj.StartDateTime = datetime.now().addHours(1);
        eventObj.EndDateTime = datetime.now().addHours(2);
        
        update eventObj;
    }

}