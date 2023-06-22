public class LogACallMobileController {
	public Task task;
    public Task TaskReminder {get;set;}
    public String Subject {get;set;}
    public boolean isSave{get;set;}
    public boolean isLigthning {get;set;}
    
   // public String ReminderTimeStr {get;set;}
    //public Time ReminderTime {get;set;}
    private String objType,WhatID;
    public string todayActivityDateStr {get;set;}
    public string ActivityDateHidden {get;set;}
    

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
    public LogACallMobileController(ApexPages.StandardController controller){
        string theme=UserInfo.getUiThemeDisplayed();
        if(theme!='Theme4t' ||theme!='Theme4u' ){
            isLigthning = true;
        }else{
            isLigthning = false;
        }
        Date currActivityDate = Date.today();
        if(UserInfo.getLocale() == 'th_TH'){
        todayActivityDateStr = String.valueOf(currActivityDate.year()-543) + '-' + (String.valueOf(currActivityDate.month()).length() < 2 ? '0' + String.valueOf(currActivityDate.month() ) : String.valueOf(currActivityDate.month())) + '-' + (String.valueOf(currActivityDate.day()).length() < 2 ? '0' + String.valueOf(currActivityDate.day()) : String.valueOf(currActivityDate.day()));
        }else{
        todayActivityDateStr = String.valueOf(currActivityDate.year()) + '-' + (String.valueOf(currActivityDate.month()).length() < 2 ? '0' + String.valueOf(currActivityDate.month()) : String.valueOf(currActivityDate.month())) + '-' + (String.valueOf(currActivityDate.day()).length() < 2 ? '0' + String.valueOf(currActivityDate.day()) : String.valueOf(currActivityDate.day()));
        }
        System.debug(todayActivityDateStr);
        TaskReminder = new Task();
        TaskReminder.Status = 'Not Started';
        standardController = controller;        
        task = (task)standardController.getRecord();
        task.Status = 'Completed';
        String whoid = ApexPages.currentPage().getParameters().get('who_id');
        String whatid = ApexPages.currentPage().getParameters().get('what_id');
        System.debug('idtype : '+whoid+' whatid : '+whatid);
        if(whoid ==null || whoid == ''){
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

        System.debug('ActivityDate : '+Task.ActivityDate+ '  : '+Task.ReminderDate__c);
		
        TaskReminder.OwnerId = Userinfo.getUserId();
        TaskReminder.Subject = '';
        TaskReminder.ActivityDate = null;
        TaskReminder.Priority = 'Normal';
        //TaskReminder.ReminderDate__c = System.today();
        isSave=false;
    }     
    
    public List<SelectOption> getSubjects() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Call','Call'));
            options.add(new SelectOption('Send Letter','Send Letter'));
            options.add(new SelectOption('Send Quote','Send Quote'));
			options.add(new SelectOption('Other','Other'));
            return options;
        }
    
        public List<SelectOption> getSubjects2() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('',''));
            options.add(new SelectOption('Call','Call'));
            options.add(new SelectOption('Send Letter','Send Letter'));
            options.add(new SelectOption('Send Quote','Send Quote'));
			options.add(new SelectOption('Other','Other'));
            return options;
        }
    
/*    public List<SelectOption> getTimes() {
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
        }  */
    


    public void save(){
        String currentDate = Apexpages.currentPage().getParameters().get('currentDate');
        System.debug(currentDate);
        task.ActivityDate = Date.valueOf(currentDate);

        insert task;
        isSave=true;
/*        System.debug('TaskReminder.Subject : '+TaskReminder.Subject );
        System.debug('TaskReminder.ActivityDate : '+TaskReminder.ActivityDate );
        //System.debug(TaskReminder.ActivityDate != String.valueOf(System.today()) );
        System.debug('System.today() : '+System.today()); 
        System.debug('TaskReminder.Description : '+TaskReminder.Description );
        System.debug(TaskReminder.Description != null);

        System.debug('TaskReminder.status : '+TaskReminder.status );
         System.debug(TaskReminder.status !='Not Started');
        System.debug('TaskReminder.Priority : '+TaskReminder.Priority );
        System.debug(TaskReminder.Priority != 'Normal'); 
        
        System.debug('TaskReminder.IsReminderSet : '+TaskReminder.IsReminderSet );  */
       /* DateTime dt = System.Today();
        String dateStr =  dt.format('yyyy-MM-dd') ;
        String ActDate= String.valueOf(TaskReminder.ActivityDate);*/
   		//String todaydt = String.valueOf(dt) ;
        System.debug('Subject2  : '+ TaskReminder.Subject );
        //DateTime mydate = DateTime.parse(TaskReminder.ActivityDate);
        //System.debug('TaskReminder.ActivityDate : '+ ActDate);
         
        //if(TaskReminder.IsReminderSet||TaskReminder.Subject != 'Call'|| ActDate != dateStr ||TaskReminder.status !='Not Started' ||TaskReminder.Priority != 'Normal' || TaskReminder.Description != null ){
       if(TaskReminder.Subject != null){
        System.debug('FollowUpTask: Process');
     /*   if(TaskReminder.IsReminderSet){
            
            List<String> splitTime = reminderTimeStr.split(':');
            ReminderTime = Time.newInstance(Integer.valueof(splitTime.get(0)), Integer.valueof(splitTime.get(1)), 0, 0);
            Datetime reminder = Datetime.newInstance(task.ReminderDate__c.year(), task.ReminderDate__c.month(),task.ReminderDate__c.day(), ReminderTime.hour(), ReminderTime.minute(), ReminderTime.second());
            // task.IsReminderSet = true;
            TaskReminder.ReminderDateTime =reminder;
            
        } */
        TaskReminder.WhoId = task.WhoId;        
        insert TaskReminder;
        
        }   
       //System.debug(task);  
               //PageReference taskpage = new ApexPages.StandardController(TaskReminder).view();
        //taskpage.setRedirect(true);
       // return taskpage;
    }
    
	    
}