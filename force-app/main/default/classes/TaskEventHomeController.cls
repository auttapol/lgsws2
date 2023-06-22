public class TaskEventHomeController { 
    public string TaskRecordType {get;set;}       
    public List<Task> TaskList {get;set;}
    public List<Event> EventList {get;set;}
    public list<calEvent> events {get;set;}
    public list<taskANDevent> taskANDeventList {get;set;}
    public Date NextSixDays {get{return System.today() +6;}set;} 
    public Date halfOfLastMonth {get{
        if(halfOfLastMonth ==null){
            halfOfLastMonth = Date.newInstance(System.today().Year(), System.today().month()-1, 15);
        }
        
        return    halfOfLastMonth;    
    }set;}
    
    public Date halfOfNextMonth {get{
        if(halfOfNextMonth ==null){
            halfOfNextMonth = Date.newInstance(System.today().Year(), System.today().month()+1, 15);
        }
        
        return    halfOfNextMonth;    
    }set;}
    
    public static final integer RECORDPERPAGE = 5;
    
    public integer countNewLead {get{
        if (countNewLead == null){
            countNewLead = 0;
        }
        return countNewLead;
        
    }set;}
    public integer countProductDue {get{
        if (countProductDue == null){
            countProductDue = 0;
        }
        return countProductDue;
    
    }set;}
    public integer countOverdue {get{
        if (countOverdue == null){
            countOverdue = 0;
        }
        return countOverdue;
    
    }set;}
    public integer countDPD {get{
        if (countDPD == null){
            countDPD = 0;
        }
        return countDPD;
        
    }set;}
    /*
    public integer countAcctComplaint {get{
        if (countAcctComplaint == null){
            countAcctComplaint = 0;
        }
        return countAcctComplaint;
        
    }set;} */
    public integer countAcctAnnualReview {get{
        if (countAcctAnnualReview == null){
            countAcctAnnualReview = 0;
        }
        return countAcctAnnualReview;
        
    }set;}
    public integer countNewReferral {get{
        if (countNewReferral == null){
            countNewReferral = 0;
        }
        return countNewReferral;
        
    }set;}
    
    //Count case record
    public integer countCaseNumber{get{        
       if (countCaseNumber == null){
                countCaseNumber = 0;
            }
            return countCaseNumber;
        }set;}
    
    //Show case
    public boolean isShowCase{get{
        if(reportPageCase != ''){
             isShowCase = True;
        }else{
            isShowCase = False;
        }
     return isShowCase;
    } set;}
    
     //Show referral	
    public boolean isShowReferral{get{
        if(reportPageReferral != ''){
             isShowReferral = True;
        }else{
            isShowReferral = False;
        }
     return isShowReferral;
    } set;}
    
    //Show Lead	
    public boolean isShowLead{get{
        if(reportPageLead != ''){
             isShowLead = True;
        }else{
            isShowLead = False;
        }
     return isShowLead;
    } set;}
    
    
      //Show Overdue Activity	
    public boolean isShowOverdueActivity{get{
        if(reportPageOverdue != ''){
             isShowOverdueActivity = True;
        }else{
            isShowOverdueActivity = False;
        }
     return isShowOverdueActivity;
    } set;}
    
    //Show Annual review	
    public boolean isShowAnnual{get{
        if(reportPageAnnual != ''){
             isShowAnnual = True;
        }else{
            isShowAnnual = False;
        }
     return isShowAnnual;
    } set;}
    
    //Show PDP	
    public boolean isShowDPD{get{
        if(reportPageDPD != ''){
             isShowDPD = True;
        }else{
            isShowDPD = False;
        }
     return isShowDPD;
    } set;}  
    
      //Show Product Due	
    public boolean isShowPageProductDue{get{
        if(reportPageProductDue != ''){
             isShowPageProductDue = True;
        }else{
            isShowPageProductDue = False;
        }
     return isShowPageProductDue;
    } set;} 
    

    public string reportPageProductDue {get{
        if (reportPageProductDue == null){
            reportPageProductDue = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select ProductDueReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select ProductDueReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).ProductDueReportName__c != null)
            {
                list<report> res = [select id from Report where name =: rpm.get(0).ProductDueReportName__c]; 
                if (res.size() > 0)
                    //reportPageProductDue = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageProductDue = res.get(0).id;
            }

        }
        return reportPageProductDue;
    }set;}
    
    public string reportPageLead {get{
        if (reportPageLead == null){
            reportPageLead = '';
        
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select LeadReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select LeadReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
            
            if (rpm.size() > 0 && rpm.get(0).LeadReportName__c != null)
            {                               
                list<report> res = [select id from Report where name =: rpm.get(0).LeadReportName__c];  
                if (res.size() > 0)
                    //reportPageLead = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageLead = res.get(0).id;
            }

        }
        return reportPageLead;
    }set;}
    public string reportPageOverdue {get{
        if (reportPageOverdue == null){
            reportPageOverdue = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select OverdueReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select OverdueReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).OverdueReportName__c != null)
            {
                list<report> res = [select id from Report where name =: rpm.get(0).OverdueReportName__c]; 
                if (res.size() > 0)
                    //reportPageOverdue = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageOverdue = res.get(0).id;
            }

        }
        return reportPageOverdue;
    }set;}
    
    public string reportPageAnnual {get{
        if (reportPageAnnual == null){
            reportPageAnnual = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select AnnualReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select AnnualReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).AnnualReportName__c != null)
            {
                list<report> res = [select id from Report where name =: rpm.get(0).AnnualReportName__c];  
                if (res.size() > 0)
                    //reportPageAnnual = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageAnnual = res.get(0).id;
            }
                
        }
        return reportPageAnnual;
    }set;}
    public string reportPageDPD {get{
        if (reportPageDPD == null){
            reportPageDPD = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select DPDReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select DPDReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
            
            if (rpm.size() > 0 && rpm.get(0).DPDReportName__c != null)
            {                               
                list<report> res = [select id from Report where name =: rpm.get(0).DPDReportName__c];  
                if (res.size() > 0)
                    //reportPageDPD = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageDPD = res.get(0).id;
            }
                
        }
        return reportPageDPD;
    }set;}
    /*
    public string reportPageComplaint {get{
        if (reportPageComplaint == null){
            reportPageComplaint = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select ComplaintReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select ComplaintReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
             
            if (rpm.size() > 0 && rpm.get(0).ComplaintReportName__c != null)
            {                              
                list<report> res = [select id from Report where name =: rpm.get(0).ComplaintReportName__c];
                if (res.size() > 0)  
                    //reportPageComplaint = 'window.open("/'+res.get(0).id+'","","width=800, height=600, toolbar=no, scrollbars=yes")';
                    reportPageComplaint = res.get(0).id;
            }
                
        }
        return reportPageComplaint;
    }set;}
    */
    //Show my all open case
     public string reportPageCase {get{
        if (reportPageCase == null){
            reportPageCase = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select CaseReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select CaseReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
             
            if (rpm.size() > 0 && rpm.get(0).CaseReportName__c != null)
            {                              
                list<report> res = [select id from Report where DeveloperName =: rpm.get(0).CaseReportName__c];
                if (res.size() > 0)                    
                    reportPageCase = res.get(0).id;
            }
                
        }
        return reportPageCase;
    }set;}
    

    public string reportPageReferral {get{
        if (reportPageReferral == null){
            reportPageReferral = '';
            
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select ReferralReportName__c  from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select ReferralReportName__c  from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
             
            if (rpm.size() > 0 && rpm.get(0).ReferralReportName__c  != null)
            {                              
                list<report> res = [select id from Report where DeveloperName =: rpm.get(0).ReferralReportName__c ];
                if (res.size() > 0)  
                    reportPageReferral = res.get(0).id;
            }
                
        }
        return reportPageReferral;
    }set;}
    
    public List<sObject> sObjectList {get{
        if(sObjectList ==null){
             sObjectList = new List<sObject>();
        }
        
        return sObjectList;
    }set;}
    public Map<String,list<taskANDevent>> taskANDeventMap {get;set;}
    public List<String> DateSet {get{
        
        if(DateSet ==null){
            DateSet = new List<String>();
            
        }
        
        
        return DateSet;
    }set;}
    
    
    
    String dtFormat = 'd MMM yyyy HH:mm:ss';
    String dFormat ='EEEEE dd/MM/yyyy';
    ///private static final INTEGER LIMITRECORD =7;
    public TimeZone tz{get{
        
        if(tz ==null){
            tz  = UserInfo.getTimeZone();
        }
        return tz;
    }set;}
    public String todaydate {get{
        if(todaydate ==null){
            Datetime todatedateformat = System.today();
                todaydate= todatedateformat.format(dFormat,tz.getDisplayName());
        }
        return todaydate;
        
    }set;}

    public Boolean refreshPage {get; set;}
    public TaskEventHomeController(){
        
        pageLoad();
    }
    
    
    public void pageLoad() {

        Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Task;    
        List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();      

        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.isDefaultRecordTypeMapping() ) {   
                if(!rtInfo.getName().contains('Retail')){    //Edit by: Danudath 03-11-2016                   
                    TaskRecordType = rtInfo.getRecordTypeId();  
                }
            }
        }
       
        events = new list<calEvent>();
        taskANDeventList = new list<taskANDevent>();
        taskANDeventMap = new Map<string,list<taskANDevent>>();
         TaskList = [SELECT ID,OwnerID,ActivityDate,WhoID,WhatID,Status,Subject,Main_Task__c,Sub_Task__c, what.name
                   FROM Task
                   WHERE OwnerID =: Userinfo.getUserId()
                   AND ActivityDate >=: halfOfLastMonth
                   AND ActivityDate <=: halfOfNextMonth
                   ORDER BY ActivityDate ASC ];
       

        EventList = [select Id, Subject, isAllDayEvent,Visit_Plan_Report__c,
                     Visit_Plan_Report__r.Customer_Name__c,
                     Visit_Plan_Report__r.Main_purpose__c,
                     Visit_Plan_Report__r.Sub_Purpose__c,
                     Visit_Plan_Report__r.Customer_Name__r.Name,
                     Visit_Plan_Report__r.id,
                     Visit_Plan_Report__r.Lead__c,
                     Visit_Plan_Report__r.Lead__r.Company,
                     Visit_Plan_Report__r.Date_of_Visit__c ,
                     Visit_Plan_Report__r.start_Visit_Time__c ,
                     Visit_Plan_Report__r.End_Visit_Time__c ,
                     StartDateTime, EndDateTime , ActivityDate , WhatID, what.name, Visit_Status__c 
                          from Event 
                          where OwnerID = :UserInfo.getUserId()
                          AND ActivityDate >=: halfOfLastMonth
                          AND ActivityDate <=: halfOfNextMonth
                         ORDER BY ActivityDate ASC,startDateTime ASC,CreatedDate ASC ];

        for(Event evnt: EventList){
                sObjectList.add(evnt);
            }
            


   for(Task tsk : TaskList){
                 sObjectList.add(tsk);           
        }

        
        for(Sobject sobj : sObjectList){
           
                if(sobj.getSobjectType() == Event.getSobjectType()){
                    AddsEventToWrapper((Event)sobj); 
                   
                }else{
                    AddsTaskToWrapper((Task)sobj);
                }
            
            
        }
        
        if(taskANDeventList.size()>0){
             taskANDeventList.sort();
        Decimal listsize = taskANDeventList.size();
        listsize.setScale(2);
        Decimal perpage = RECORDPERPAGE;
        perpage.setScale(2);
        Decimal rawsize = listsize/perpage;
        Decimal totalsize = rawsize.round(roundingMode.UP);
       
           
        MaxpageNumber = Integer.valueOf(Math.round(totalsize));
            System.debug('MaxpageNumber: '+MaxpageNumber);
            if(totalsize<1 || taskANDeventList.size()==5){
               MaxpageNumber  =0;
            }
        ThisPageActivities(taskANDeventList,pageNumber);
        }
        
        
        //Fix BAU00011994_INC0190256
        /*for (Product_Information_Detail__c pid : [select id, Maturity_Date__c from Product_Information_Detail__c
                                                where customer__r.ownerid =: userinfo.getUserId()])
        {
            if (pid.Maturity_Date__c != null)
            {
                if (system.today().monthsBetween(pid.Maturity_Date__c ) < 4 &&
                    system.today().monthsBetween(pid.Maturity_Date__c ) > -4)
                    countProductDue++;
            }
        }*/     

        Date firstDayOfLast3Month = System.today().addMonths(-3);
        Date firstDayOfMonth = Date.newInstance(firstDayOfLast3Month.year(), firstDayOfLast3Month.month(), 01);
        
        Date firstDayOfNext3Month = System.today().addMonths(3);
        Date lastDay = Date.newInstance(firstDayOfNext3Month.year(), firstDayOfNext3Month.month(), 01);
        Date lastDayOfMonth = lastDay.addDays(Date.daysInMonth(lastDay.year(), lastDay.month()) - 1);

        integer countProductDueUser = [select count() from Product_Information_Detail__c 
                                        where customer__r.ownerid =: userinfo.getUserId() 
                                        and (Maturity_Date__c >=: firstDayOfMonth and Maturity_Date__c <=: lastDayOfMonth)];
        countProductDue = countProductDueUser;

        system.debug('Product Due = '+countProductDue);

        
        integer countNewLeadUser = [select count() from lead where OwnerId = :UserInfo.getUserId() and IsUnreadByOwner = true];  
        list<string> listgroupid = new list<string>();
        if (userInfo.getUserroleId() != null) 
        {
            group g = [select id from group where type = 'Role' and relatedid = :userInfo.getUserroleId()].get(0);
            for (groupmember gm : [select groupid from groupmember where userorgroupid = :g.id])
            {
                listgroupid.add(gm.groupid);
            }
        }
        integer countNewLeadQueue = [select count() from lead where OwnerId in :listgroupid and IsUnreadByOwner = true];
        countNewLead = countNewLeadUser + countNewLeadQueue;
           
        integer countOverdueTask = [select count() from task 
                                    where OwnerID = :UserInfo.getUserId() 
                                          and ActivityDate <: System.Today()
                                          and isClosed = false];
                        
        integer countOverdueEvent = [select count() from event
                                     where OwnerID = :UserInfo.getUserId() 
                                          and ActivityDate <: System.Today()
                                          and visit_status__c = '1 - Open'];
        
        system.debug('Overdue = '+countOverdueTask+' + '+countOverdueEvent);                                  
        countOverdue = countOverdueTask + countOverdueEvent;
        
        //countDPD = [select count() from account where OwnerID = :UserInfo.getUserId() and dpd__c > 0];
        countDPD = [select count() from Product_Information_Detail__c 
                    where customer__r.OwnerID = :UserInfo.getUserId() 
                    and DPD_Date__c > 0];
        system.debug('DPD = '+countDPD);
        
       /* countAcctComplaint = [select count() from account where OwnerID = :UserInfo.getUserId() and Opened_Complaint__c > 0];
        */
        //Query all my open case 
        countCaseNumber = [Select count() from Case where OwnerID = :UserInfo.getUserId() and isclosed = false];
        
        
        for (account act : [select id, Next_Annual_Review_Date__c from account where OwnerID = :UserInfo.getUserId()])
        {
            if (act.Next_Annual_Review_Date__c != null)
            {
                if (system.today().monthsBetween(act.Next_Annual_Review_Date__c) < 4)
                    countAcctAnnualReview++;
            }
        }
        system.debug('Annual Review = '+countAcctAnnualReview);
        
        //CR Referral
        integer countPendingReferral = [select count() from RTL_Referral__c where OwnerId = :UserInfo.getUserId() 
                                        AND (RTL_Stage__c = 'New' OR RTL_Stage__c = 'In progress_Contacted')
                                        AND (RecordType.DeveloperName = 'Refer_to_Commercial' OR RecordType.DeveloperName = 'Refer_Within_Commercial')];  
        
        countNewReferral = countPendingReferral;
        
    }
    
    
    public void AddsTaskToWrapper(Task tsk){
         DateTime startDT = datetime.newInstance(Date.Today().Year(),tsk.ActivityDate.Month(), tsk.ActivityDate.Day());
            calEvent cevent = new calEvent();
            
            cevent.title = tsk.Subject;
            cevent.allDay = false;
            cevent.startString = startDT.format(dtformat);
            //Because this is an all day event that only spans one day, we can leave the send date null
            cevent.endString = '';
            cevent.url = '/' + tsk.Id;
            cevent.className = 'calendar-task';
            cevent.isVisit = true;
            events.add(cevent);
            
        
        if(tsk.ActivityDate >=System.today() 
               && tsk.ActivityDAte <=System.today()+6
             && tsk.Status != 'Completed'
              && tsk.Status != 'Cancel'
              && tsk.Status != 'Reject by RM/RA'){
                  taskANDevent tskNEvent = new taskANDevent();
            tskNEvent.isTask = true;
            tskNEvent.TaskRecord = tsk;
           
                taskANDeventList.add(tskNEvent);
            }
        
           
 
        
        
        
    }
    
    public void AddsEventToWrapper(Event evnt){
         DateTime startDT = evnt.StartDateTime;
                DateTime endDT = evnt.EndDateTime;
                calEvent myEvent = new calEvent();
                 String titlename = evnt.Subject;
                 String substring;
                    if(titlename.length() >40){
                        substring = titlename.substring(0,40);
                    }else{
                        substring = titlename;
                    }
                myEvent.title =substring;
                myEvent.allDay = true;
                myEvent.startString = startDT.format(dtFormat);
                myEvent.endString = endDT.format(dtFormat);
                myEvent.url = '/' + evnt.Visit_Plan_report__c;
                myEvent.className = 'calendar-event';
                myEvent.isVisit = true;
                events.add(myEvent);
             
        
        
        
         if(evnt.ActivityDate >=System.today() 
               && evnt.ActivityDAte <=System.today()+6
              && evnt.Visit_Status__c == '1 - Open'){
              
                  
             taskANDevent tskNEvent = new taskANDevent();
            tskNEvent.isTask = false;
            tskNEvent.EventRecord = evnt;
             if(!evnt.IsAllDayEvent){
                 DateTime correctedStartDateTime = evnt.StartDateTime;
                 System.debug(correctedStartDateTime);
                 tskNevent.EventStartTime =  String.valueof(correctedStartDateTime);
                //tskNEvent.EventStartTime = correctedStartDateTime.format(evnt.StartDateTime.format(),tz.getDisplayName()).split(', ').get(0);
             DateTime correctedEndDateTime = evnt.EndDatetime;
                 System.debug(correctedEndDateTime);
                 tskNevent.EventEndTime = String.valueof(correctedEndDateTime);
                //tskNEvent.EventEndTime = correctedEndDateTime.format(evnt.EndDatetime.format(),tz.getDisplayName()).split(', ').get(0);
     
                 
             }
                    taskANDeventList.add(tskNEvent);     
                  
                  
            }
           
            
    }
    
    public void ThisPageActivities(List<taskANDevent> taskANDeventList,Integer pageNum){
        // page 1 - 0 1 2 3 4
        // page 2 - 5 6 7 8 9
        // page 3 - 10 11 12 13 14
        // page 4 - 15 16 17 18 19
        // 
        
        DateSet = new List<String>();
        taskANDeventMap = new Map<String,list<taskANDevent>>();
        Integer Index = RECORDPERPAGE*pageNum;
            System.debug(taskANDeventList.size());
        for(Integer i=0;i<RECORDPERPAGE;i++){
            System.debug(Index);
            taskANDevent tne = taskANDeventList.get(Index);
             Datetime formatdate;
            if(tne.isTask){
                Task tsk = tne.TaskRecord;
                formatdate = tsk.ActivityDate;
            }else{
                Event evnt = tne.EventRecord;
                formatdate = evnt.ActivityDate;
            }
             String dateOutput= formatdate.format(dFormat,tz.getDisplayName());
                
                     if(dateOutput == todaydate){
                        String target = dateOutput.split(' ').get(0);
                        dateOutput = dateOutput.replace(target, 'Today');
                    }
                
                        String adyear = dateOutput.split('/').get(2);
                         dateOutput = dateOutput.replace(adyear, '2559');
            
            if(taskANDeventMap.containsKey(dateOutput)){
                    taskANDeventMap.get(dateOutput).add(tne);
                }else{
                    list<taskANDevent> listformap =  new list<taskANDevent>();
                    listformap.add(tne);
                    DateSet.add(DateOutPut);
                   taskANDeventMap.put(dateOutput,listformap);
                }
            if((Index+1<taskANDeventList.size())){
                Index++;
            }else{
                break;
            }
            
           
            
        } //end
    }
    
        public PageReference redirecttoNewTask(){
        PageReference ref = new PageReference('/00T/e?');
            ref.setRedirect(true);
            
        return ref;
    }

    
    
    public class taskANDevent implements Comparable{
        public boolean isTask {get;set;}
        public Task taskRecord {get;set;}
        public Event eventRecord {get;set;}
        public String EventStartTime {get;set;}
        public String EventEndTime {get;set;}
        
         public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            taskANDevent compareToDate = (taskANDevent)compareTo;
            Datetime thisActivity = this.isTask?this.Taskrecord.ActivityDate:this.eventRecord.ActivityDate;
            Datetime compareActivity = compareToDate.isTask?compareToDate.Taskrecord.ActivityDate:compareToDate.eventRecord.ActivityDate;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (thisActivity  < compareActivity) {
            // Set return value to a positive value.
               
                    returnValue = -1;
                
            
            } else if (thisActivity > compareActivity) {
            // Set return value to a negative value.
            
                    returnValue = 1;
                
            }else {
                returnValue = -1;
            } 
            
            return returnValue;       
        }
        
        
        
    }
     public class calEvent{
         public String title {get;set;}
         public Boolean allDay {get;set;}
         public String startString {get;set;}
         public String endString {get;set;}
         public String url {get;set;}
         public String className {get;set;}
         public boolean isVisit {get;set;}
    }
    
     public Boolean hasNext {
        get {
            if(
                ((1+pageNumber) < MaxpageNumber)
               &&MaxpageNumber!=0){
                hasNext =true;
            }else{
                hasNext =false;
            }
            
            
         return hasNext;
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            if(pageNumber==0){
                hasPrevious = false;
            }else if (pageNumber <=MaxpageNumber){
                hasPrevious = true;
            }
            
            
          return hasPrevious;
        }
        set;
    }  
    public Integer pageNumber {
        get {
            if(pageNumber==null){
                pageNumber =0;
            }
          return pageNumber;
        }
        set;
    }  
    
    public Integer MaxpageNumber {
        get {
            if(MaxpageNumber==null){
                MaxpageNumber =0;
            }
          return MaxpageNumber;
        }
        set;
    }  

    public void previous() {
        
        ThisPageActivities(taskANDeventList,pageNumber-1);
        pageNumber--;
    }  
    public void next() {
       ThisPageActivities(taskANDeventList,pageNumber+1);
        pageNumber++;
       
    }
    
    
  }