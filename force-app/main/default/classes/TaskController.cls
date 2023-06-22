public class TaskController {
    //public Task task;
    public Task TaskReminder {get;set;}
    public String Subject {get;set;}
    public String ReminderTimeStr {get;set;}
    public Time ReminderTime {get;set;}
    public String objType,WhatID;
    public String ActivityID {get;set;}
    public List<AcctPlanActivity__c> AcctPlanAct {get;set;}
    public boolean isSuccess {get;set;}
    public Id recType {get;set;}

    public String getObjectType() {
          return(this.objType);
    }
    public String setObjectType(String newObj) {
        this.objType = newObj;
        return(this.objType);
    }
    
    public String getWhatID(){
         return(this.WhatID);
    }
    
   public String setWhatID(String What) {
        this.WhatID = What;
        return(this.Whatid);
    }
    

    private ApexPages.StandardController standardController;    
    public TaskController (ApexPages.StandardController controller){
    
    User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
         System.debug('user : '+us);
         string segment = us.Segment__c;
         //String recordTypeName='';
         
         if(segment == 'CB' || segment == 'MB' ){
         //recordTypeName = '%WBG%';
        recType= [SELECT Id,IsActive,Name,SobjectType FROM RecordType where IsActive= true and SobjectType= 'Task' and Name like '%WBG%' limit 1].Id;
        }else{
        recType= [SELECT Id,IsActive,Name,SobjectType FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%WBG%') and (NOT Name like '%Retail%') and Name = 'Task Record type' limit 1].Id;
        }
    
        TaskReminder = new Task();
        TaskReminder.RecordTypeId =recType;
        TaskReminder.Status = 'Not Started';
        standardController = controller;        
        //task = (task)standardController.getRecord();
        //task.Status = 'Completed';
        //String whoid = ApexPages.currentPage().getParameters().get('who_id');
        //AccountID =   ApexPages.currentPage().getParameters().get('AccountID');
         ActivityID =   ApexPages.currentPage().getParameters().get('ActivityID');
        //String whatid = ApexPages.currentPage().getParameters().get('AccountID');
        TaskReminder.WhatId = ApexPages.currentPage().getParameters().get('AccountID');
        //System.debug('idtype : '+whoid+' whatid : '+whatid);
        /*if(whoid ==null || whoid == ''){
             task.WhatId = ApexPages.currentPage().getParameters().get('what_id');
           TaskReminder.WhatId = ApexPages.currentPage().getParameters().get('what_id');
        }else{
              task.WhatId = ApexPages.currentPage().getParameters().get('what_id');
           TaskReminder.WhatId = ApexPages.currentPage().getParameters().get('what_id');
            
              task.whoid = ApexPages.currentPage().getParameters().get('who_id');
           TaskReminder.whoid = ApexPages.currentPage().getParameters().get('whoid');
            System.debug('Task : '+Task.Whatid+ '  : '+Task.Whoid);
        }

        task.OwnerId = Userinfo.getUserId();
        task.Subject = 'Call';
        task.ActivityDate = System.today();
        task.Priority = 'Normal';
        task.ReminderDate__c = System.today();
        */
        
        TaskReminder.OwnerId = Userinfo.getUserId();
        TaskReminder.Subject = 'Call';
        TaskReminder.ActivityDate = System.today();
        TaskReminder.Priority = 'Normal';
        TaskReminder.IsReminderSet = true;
        TaskReminder.ReminderDate__c = System.today();
        
        if (ActivityID !=null && ActivityID !=''){
            system.debug('ActivityID '+ActivityID);
            Set<String> records = new Set<String>();
            for(String key : ActivityID.split(','))
            {
                records.add(key);
            }
            
            System.debug('records '+records );
            
            AcctPlanAct= [Select Id,Date__c,Group__c,Activities__c,Other__c from AcctPlanActivity__c where Id IN : records ];
            System.debug('AcctPlanAct '+AcctPlanAct);
            
            if(AcctPlanAct.size()==1){
                AcctPlanActivity__c activity = AcctPlanAct.get(0);
                String other = '';
                if(activity.Other__c != null){
                    other = '('+activity.Other__c+')';
                }
                TaskReminder.Subject = activity.Group__c +' '+ activity.Activities__c +' '+ other ;
                TaskReminder.ActivityDate = activity.Date__c;
            }
            
            
        }
            
           
    }     
    
    public List<SelectOption> getSubjects() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Call','Call'));
            options.add(new SelectOption('Send Letter','Send Letter'));
            options.add(new SelectOption('Send Quote','Send Quote'));
            options.add(new SelectOption('Other','Other'));
            return options;
        }
    public List<SelectOption> getTimes() {
            List<SelectOption> options = new List<SelectOption>();
            Time Starttime = Time.newInstance(0, 0, 0, 0);
       

            for(integer i=0;i<48;i++){
                Time Settime = Time.NewInstance(Starttime.hour(),Starttime.minute()+(30*i),Starttime.second(),Starttime.millisecond());
                String hour = String.valueOf(Settime.hour());
                String minute = String.valueOf(Settime.minute());
                if(hour.length() ==1){
                    hour = '0'+hour;
                }
                if(minute.length() ==1){
                    minute = '0'+minute;
                }
               options.add(new SelectOption(Settime+'',hour+':'+minute)); 
            }
        
            return options;
        }
    
    public PageReference save(){
        
       //insert task;
        if(TaskReminder.IsReminderSet){
       
             List<String> splitTime = reminderTimeStr.split(':');
            ReminderTime = Time.newInstance(Integer.valueof(splitTime.get(0)), Integer.valueof(splitTime.get(1)), 0, 0);
            Datetime reminder = Datetime.newInstance(TaskReminder.ReminderDate__c.year(), TaskReminder.ReminderDate__c.month(),TaskReminder.ReminderDate__c.day(), ReminderTime.hour(), ReminderTime.minute(), ReminderTime.second());
            TaskReminder.IsReminderSet = true;
            TaskReminder.ReminderDateTime =reminder;
            
        }
        //System.debug(task);
        insert TaskReminder;

         if(ActivityID.length() !=0 || ActivityID!='' || ActivityID!=null){  
         Set<String> records = new Set<String>();
            for(String key : ActivityID.split(','))
            {
            records.add(key);
            }
            System.debug('records '+records );
         
            system.debug('Update Activity ');
               List<AcctPlanActivity__c> AcctPlanAct= [Select Id from AcctPlanActivity__c where Id IN : records ];
               for(AcctPlanActivity__c act : AcctPlanAct){
               act.TaskId__c= TaskReminder.id ;
               update  act;
               }
        }    
        
        PageReference taskpage = new ApexPages.StandardController(TaskReminder).view();
        taskpage.setRedirect(true);
        return taskpage;
    }
    
    public void modalsave(){
        
       //insert task;
        if(TaskReminder.IsReminderSet){
       
             List<String> splitTime = reminderTimeStr.split(':');
            ReminderTime = Time.newInstance(Integer.valueof(splitTime.get(0)), Integer.valueof(splitTime.get(1)), 0, 0);
            Datetime reminder = Datetime.newInstance(TaskReminder.ReminderDate__c.year(), TaskReminder.ReminderDate__c.month(),TaskReminder.ReminderDate__c.day(), ReminderTime.hour(), ReminderTime.minute(), ReminderTime.second());
            TaskReminder.IsReminderSet = true;
            TaskReminder.ReminderDateTime =reminder;
            
        }
        //System.debug(task);
        insert TaskReminder;

         if(ActivityID.length() !=0 || ActivityID!='' || ActivityID!=null){  
         Set<String> records = new Set<String>();
            for(String key : ActivityID.split(','))
            {
            records.add(key);
            }
            System.debug('records '+records );
         
            system.debug('Update Activity ');
               List<AcctPlanActivity__c> AcctPlanAct= [Select Id from AcctPlanActivity__c where Id IN : records ];
               for(AcctPlanActivity__c act : AcctPlanAct){
               act.TaskId__c= TaskReminder.id ;
               update  act;
               }
        }    
        
        isSuccess = true;
    }
    

    
        
}