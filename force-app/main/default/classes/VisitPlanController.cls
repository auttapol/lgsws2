public with sharing class VisitPlanController {
    public Opportunity opp {get;set;}
    public String OppID {get;set;}
    public Account acct {get;set;}
    public Call_Report__c Callreport {get;set;}
    public string actionDisplay {get;set;}
    public RecordType recordTypeObj {get{
        
        if(recordTypeObj == null){
            List<String> recordTypeNameList = new List<String>();
            /** Need to create list to collect record type name.**/
            Schema.DescribeSObjectResult R = Call_Report__c.SObjectType.getDescribe();
            /** You need to change the object name according to your requirement.**/
            List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
            for( Schema.RecordTypeInfo recordType : RT )
            {
            if(recordType.isAvailable())
             { 
             /** Check if the recordtype is visible for the current user or not. **/
            //if(recordType.Name!='Master' && recordType.Name != 'หลัก') {
            if( recordType.Name.contains('Visit') ){
                system.debug('------- recordType.Name -----'+recordType.Name);
                system.debug('##Test recordType.getRecordTypeID() = '+ recordType.getRecordTypeID());
                recordTypeObj = [SELECT ID,Name from RecordType WHERE ID =: recordType.getRecordTypeID() LIMIT 1];
                system.debug('##Test recordTypeObj = '+ recordTypeObj);
                system.debug('------- recordType Object ----- '+recordTypeObj.Name);
             /** Collect the record type name in list. **/
            }
                
              }
            }
            
            
        }
        
        System.debug(recordTypeObj.Name);
        return recordTypeObj;
    }
                                     set;}
    
    public RecordType LeadRecordType {get{
        if(LeadRecordType ==null){
            LeadRecordType = [SELECT ID,Name,SobjectType from RecordType WHERE
                             Sobjecttype ='Call_Report__c'
                             AND NAME LIKE '%Lead'
                             AND(NOT Name like '%Closed%') LIMIT 1];
            
        }
        return LeadRecordType;
    }set;}

    public List<SelectOption> subpurposeAvailableList { get{
        if(subpurposeAvailableList ==null){
            subpurposeAvailableList = new List<SelectOption>();
        }
        return subpurposeAvailableList;
    }set;}
        public List<SelectOption> subpurposeSelectedList { get{
        if(subpurposeSelectedList ==null){
            subpurposeSelectedList = new List<SelectOption>();
        }
        return subpurposeSelectedList;
    }set;}
    public String ActivityID,AccountID,VisitPlanID,RecordTypeID,retURL;
    public String SobjectId {get;set;}
    public String CallReportID {get;set;}
    public String recordTypeName {get;set;}
    public String IdForCancel {get;set;}
    public boolean isClosed {get
        {
        if(isclosed==null){
            isclosed = false;
        }
                             return isclosed;
                            }set;}
     public String LeadID {get;set;}
    public boolean isSuccess {get;set;}
    public boolean IsCreate {get;set;}  
    public boolean IsLead {get{
        if(IsLead ==null){
            IsLead = false;
        }
        return IsLead;
    }set;} 
    public Integer removeIndex {get;set;}
    ApexPages.StandardController controller;
    public List<Visit_Plan_Invitee__c> VisitPlanInviteeList {get{
        if(VisitPlanInviteeList ==null){
             VisitPlanInviteeList = new List<Visit_Plan_Invitee__c>();
        }
        return VisitPlanInviteeList;
    }set;}
    public List<Visit_Plan_Invitee__c> Inviteeremovelist {get;set;}
    public List<AcctPlanActivity__c> AcctPlanAct {get;set;}
    public string MobileVisitPlanID {get;set;}
    public string MobileOwnerName {get;set;}
    public string MobileRecordTypeName {get;set;}
    public string MobileRecordType {get;set;}
    public string MobileRetUrl {get;set;}
    public String displayMode {get;set;}
    
    public string visitplanIdRedirect {get;set;}
    
    public PageReference redirectToMobile()
    {
        PageReference result = Page.VisitPlanCreateMobileLayout;
        if (MobileVisitPlanID != null && MobileVisitPlanID != '')
            result.getParameters().put('id',MobileVisitPlanID);
        if (MobileRecordType != null && MobileRecordType != '')
            result.getParameters().put('RecordType',MobileRecordType);
     
        result.setRedirect(true); 
        return result;
    }
    
    public VisitPlanController(ApexPages.StandardController controller){
        
        VisitPlanID = ApexPages.currentPage().getParameters().get('id');
        IdForCancel = VisitPlanId;
        OppID =   ApexPages.currentPage().getParameters().get('oppID');
        AccountID =   ApexPages.currentPage().getParameters().get('AccountID');
        ActivityID =   ApexPages.currentPage().getParameters().get('ActivityID');  
        RecordTypeID =   ApexPages.currentPage().getParameters().get('RecordType');
        retURL = ApexPages.currentPage().getParameters().get('CF00N9000000DneE6_lkid'); 
        SobjectId = ApexPages.currentPage().getParameters().get('Sobjectid');
        
         if(SobjectId =='' || SobjectId ==null){
          SobjectId = ApexPages.currentPage().getParameters().get('CF00N9000000ErEps_lkid');
        }
        
        if(retURL =='' || retURL ==null){
          retURL = ApexPages.currentPage().getParameters().get('retURL');
        }
        
        
        //Visit Plan Detail Page
        CallReportID =   ApexPages.currentPage().getParameters().get('CallReportID');
        System.debug('ActivityID : '+ActivityID);
        
        if (string.isBlank(IdForCancel)) IdForCancel = SobjectId;
        System.debug('IdForCancel:'+IdForCancel);
        visitplanIdRedirect = '';
        if(CallReportID!=null && CallReportID!=''){
            Callreport = [SELECT Date_of_Visit__c ,Additional_Party__c,Lead__c,
                          Status__c,Categories__c,OwnerID,Start_Visit_Time__c , End_Visit_Time__c ,
                           Main_purpose__c,Sub_Purpose__c,With_Whom__c,TMB_person__c,
                           Complete_Date__c,Outcome__c,Actual_Visit_Date__c,Customer_name__c,
                           Loss_Incomplete_reason__c,Business_talk_and_opportunity__c,
                           Customer_Counterparty__c,Customer_Counterparty__r.AccountID,
                           Owner.name,RecordType.name,Name,Meeting_Place__c,Rating__c,Next_Step__c
                           
                          FROM Call_Report__c
                          WHERE ID =:CallReportID LIMIT 1];
        }
        
        MobileRecordType = RecordTypeID;
        MobileVisitPlanID = VisitPlanID;
        MobileRetUrl = retUrl;
        displayMode = '';
        actionDisplay = '';
        
        System.debug('MobileRecordType : '+MobileRecordType);
        
        
        System.debug('sObjectID : '+sObjectID);
        
        if(sObjectID!=null && sObjectID!=''){
                String checksObjectType = SobjectId.substring(0,3);
            System.debug(checksObjectType);
            
            if(checksObjectType =='001'){
                IsCreate = true;
                AccountID = SobjectId;
                VisitPlanID=null;
                recordTypeObj = [SELECT ID,Name from RecordType WHERE NAME = 'Visit Plan / Report' LIMIT 1];
            }
            
            else if(checksObjectType =='00Q'){
                 IsCreate = true;
                IsLead = true;
                VisitPlanID=null;
                LeadID = SobjectId;
                recordTypeObj = [SELECT ID,Name from RecordType WHERE NAME = 'Visit Plan for Lead' LIMIT 1];
            }
            
        }
        
        
        IsCreate = false;
        Inviteeremovelist = new List<Visit_Plan_Invitee__c>();
        
        //EditMode
        if(VisitPlanId !=null && VisitplanId !=''){
             Callreport = [SELECT Date_of_Visit__c ,Additional_Party__c,RecordTypeID,Lead__C,
                          Status__c,Categories__c,OwnerID,Start_Visit_Time__c , End_Visit_Time__c ,
                           With_Whom__c,TMB_person__c,Main_purpose__c,Sub_Purpose__c,
                           Complete_Date__c,Outcome__c,Actual_Visit_Date__c,Customer_name__c,
                           Loss_Incomplete_reason__c,Business_talk_and_opportunity__c,
                           Customer_Counterparty__c,Customer_Counterparty__r.AccountID,
                           Owner.name,RecordType.name,nAme,Meeting_Place__c,Rating__c,Next_Step__c
                           
                          FROM Call_Report__c
                          WHERE ID =:VisitPlanID LIMIT 1];
            
            
            
            VisitPlanInviteeList = new List<Visit_Plan_Invitee__c>();
            for(Visit_Plan_Invitee__c visit : [SELECT TMB_Person__c,SEQ__c
                                              FROM Visit_Plan_Invitee__c
                                              WHERE Visit_Plan_Report__c =: VisitPlanID
                                              ORDER BY SEQ__C ASC]){
                                                 
                                                      VisitPlanInviteeList.add(visit);
                                                 
                                                  
                                              }
            
            
            if(CallReport.Lead__c !=null){
                isLead = true;
            }
            MobileVisitPlanID = VisitPlanId;
            MobileOwnerName = Callreport.Owner.Name;
            MobileRecordTypeName = Callreport.RecordType.Name;
            displayMode = 'Edit';
            actionDisplay = 'Updating';
            dependentPicklist();
            System.debug('MobileRecordTypeName : '+MobileRecordTypeName);
            if(MobileRecordTypeName.containsIgnoreCase('Close')){
                isClosed = true;
                
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7004').Status_Message__c));
                }
            else if (CallReport.OwnerID != Userinfo.getUserId()){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7005').Status_Message__c));
                isclosed = true;
                if(CallReport.Lead__c !=null){
                    isLead = true;
                }
                
            }
            
                  
        }
        else{
            
            
            
        this.controller = controller;
        Callreport = new Call_Report__c();
            
        
            //VisitOpptyMode
        if(OppID != null && OppID != ''){
            opp  =   [SELECT AccountID,ID FROM  Opportunity WHERE ID =:OppID LIMIT 1 ];
            AccountID = opp.AccountID;
            recordTypeObj = [SELECT ID,Name from RecordType WHERE NAME = 'Visit Plan / Report' LIMIT 1];
            Callreport.Customer_name__c = opp.AccountID ;
        }
        
        System.debug(recordTypeObj.Name);
        Callreport.RecordTypeID = recordTypeObj.id;   
        MobileRecordTypeName = recordTypeObj.Name;
        RecordType MobileRecordTypeObj = [SELECT ID,Name from RecordType WHERE NAME = 'Visit Plan / Report' LIMIT 1];
        if(string.isBlank(RecordTypeID)){
          Callreport.RecordTypeID = MobileRecordTypeObj.ID;
          MobileRecordTypeName = MobileRecordTypeObj.Name;
        }
        
            //VisitActivityMode
        if(AccountID != null && AccountID != ''){
           acct = [SELECT Id,Name FROM  Account WHERE ID =:AccountID LIMIT 1 ];
            CallReport.Customer_name__c = AccountID;
        }
         if(RecordTypeID != null && RecordTypeID != ''){
           RecordType RecordTypeObjCheck  =   [SELECT ID,Name FROM  RecordType WHERE ID =:RecordTypeID LIMIT 1 ];
             if(RecordTypeObjCheck.Name == 'Visit Plan / Report'){
                isLead = false;                 
             }else if(RecordTypeObjCheck.Name == 'Visit Plan for Lead'){
                 isLead = true; 
             }
            CallReport.RecordTypeId = RecordTypeID;
         }
         else if(isLead){
             CallReport.RecordTypeId = LeadRecordType.id;
         }
         
            //VisitPlan - Activity
         if (ActivityID !=null && ActivityID !=''){
                 system.debug('ActivityID '+ActivityID);
                Set<String> records = new Set<String>();
                for(String key : ActivityID.split(','))
                {
                    records.add(key);
                }
                
                System.debug('records '+records );
                
                AcctPlanAct= [Select Id,Date__c,status__c,CustomerCounterparties__c from AcctPlanActivity__c where Id IN : records ];
                System.debug('AcctPlanAct '+AcctPlanAct);
                
                if(AcctPlanAct.size()==1){
                   AcctPlanActivity__c activity = AcctPlanAct.get(0);
                    
                    List<AcctPlanStakeholder__c> stakeholderList = [SELECT ID,User__c ,AcctPlanActivity__c  
                                                                    FROM AcctPlanStakeholder__c
                                                                   WHERE AcctPlanActivity__c=: activity.id];
                    
                    
                    String status = activity.Status__c;
                    system.debug('status='+status);
                    if(status.containsIgnoreCase('pre board')){
                        status = 'Pre boarding';
                    }else if(status.containsIgnoreCase('on board')){
                        status = 'On-boarding';
                    }else if(status.containsIgnoreCase('post board')){
                        status = 'Post-boarding';
                    }
                    callreport.Categories__c  = status;
                    //callreport.Main_purpose__c = activity.main_purpose__c;
                    //callreport.Sub_purpose__c = activity.Sub_purpose__c;
                    callreport.Customer_Counterparty__c = activity.CustomerCounterparties__c;
                    callreport.Date_of_Visit__c = activity.Date__c;
                    Integer index = 1;
                    for(AcctPlanStakeholder__c stake : stakeholderList){
                       Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
                        invitee.SEQ__c = index;
                        invitee.TMB_Person__c = stake.User__c;
                        invitee.Visit_Plan_Report__c = callreport.id;
                        VisitPlanInviteeList.add(invitee);
                        index++;
                    }
                }
                
                
            }
            
                        
            MobileOwnerName = Userinfo.getName();
            
            
            callReport.status__c = '1 - Open';
            displayMode = 'New';
            actionDisplay = 'Inserting';
            
            //DefaultMode Create
            IsCreate =true;
            Callreport.OwnerId = Userinfo.getUserId();
            //VisitPlanInviteeList = new List<Visit_Plan_Invitee__c>();
            System.debug(AccountID);
            System.debug(retURL);
             if(( AccountID =='' || AccountID ==null)
           &&(retURL !='' && retURL !=null) ){
            String sObjectType = retURl.substring(0,3);
               if(sObjectType=='001'){
                   System.debug(sObjectType);
                     AccountID = retURL;
                     Callreport.Customer_name__c = Accountid;
                   
               }
               
            }
            if(IsLead){
                Lead leadObj = [select id,name,Account__c from Lead where id=:LeadId];
                Callreport.Customer_name__c = leadObj.Account__c;
            }
            if(IsLead){
               Callreport.Lead__c = LeadId; 
            }else if(!IsLead){
                recordTypeObj = [SELECT ID,Name from RecordType WHERE NAME = 'Visit Plan / Report' LIMIT 1];
                Callreport.RecordTypeId = recordTypeObj.id;
            }
        
            
        }
        
        //System.debug('VisitPlanInviteeList: '+VisitPlanInviteeList);
        
    }
    
   
    
    public void addTMBPerson(){
        Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        invitee.SEQ__c = VisitPlanInviteeList.size();
        VisitPlanInviteeList.add(invitee);
    }
    
    
    
    
    public void removeTMBPerson(){
       Visit_Plan_Invitee__c removeInvitee = VisitPlanInviteeList.get(Removeindex);
        if(removeInvitee.id !=null){
            Inviteeremovelist.add(removeInvitee);
        }
        VisitPlanInviteeList.remove(Removeindex);
        List<Visit_Plan_Invitee__c> inviteeTempList = new List<Visit_Plan_Invitee__c>();
        integer rowIndex =0;
        for(Visit_Plan_Invitee__c invitee : VisitPlanInviteeList){
            invitee.SEQ__c = rowIndex;
            inviteeTempList.add(invitee);
            ++RowIndex;
        }
        VisitPlanInviteeList.clear();
        VisitPlanInviteeList.addAll(inviteeTempList);
    }
    
    
    
    
    public LisT<String> selectsubpurpose {get;set;}
    public List<String> removesubpurpose {get;set;}
    public Integer maxLength {get
    {
        if(maxLength==null){
            maxLength = 0;
        }
        return maxLength;
    }set;}
    public void dependentPicklist(){
        System.debug(callReport.Categories__c);
        System.debug(callReport.Main_purpose__c);
       
        //System.debug(recordtypeobj.Name);
        
        
        maxLength = 0;
         subpurposeAvailableList = new List<Selectoption>();
            subpurposeSelectedList = new List<SelectOption>();
        if(callreport.Main_purpose__c !=null){
            
            
             Set<String> subpurposeValueSet = new set<String>();
            //EditMode
                if(Callreport.Sub_Purpose__c !=null){
                    for(String sub : Callreport.Sub_Purpose__c.split(';')){
                        subpurposeValueSet.add(sub);
                    }
                }
            //
            System.debug(subpurposeValueSet);
            
            for(Sub_Purpose_Mapping__c subpur : [SELECT ID
                                            //,Record_Type_Name__c
                                            , Main_purpose__c,Sub_Purpose__c
                             FROM Sub_Purpose_Mapping__c 
                             WHERE Main_Purpose__c =:callreport.Main_purpose__c
                             // AND Record_Type_Name__c=: recordtypeobj.Name
                                                ORDER BY Sub_Purpose__c ASC]){
                                 
                                 if(subpur.Sub_Purpose__c!=null && subpur.Sub_Purpose__c!=''){
                                     if(subpur.Sub_Purpose__c.length()>maxLength){
                                         maxLength =subpur.Sub_Purpose__c.length();
                                     }
                                     if(subpurposeValueSet.contains(subpur.Sub_Purpose__c)){
                                          subpurposeSelectedList.add(new SelectOption(subpur.Sub_Purpose__c,subpur.Sub_Purpose__c)); 
                                     }else{
                                          subpurposeAvailableList.add(new SelectOption(subpur.Sub_Purpose__c,subpur.Sub_Purpose__c));
                                     }
                                    
                                 }
                         
                 }
            System.debug(maxLength);
            
            
        }
        
    }
    
    
    
    public PageReference modalsave(){ 
         
        try{
             boolean isDuplicated = false;
             boolean iscontainOwner = false;
           if(VisitPlanInviteeList.size()>0){ 
                
                Set<ID> checkDupSet = new Set<ID>(); 
               
                    integer row =0;
               
               for(integer i=0;i<VisitPlanInviteeList.size();i++){
                
                if(VisitPlanInviteeList.get(i).TMB_Person__c ==null){
                    
                     VisitPlanInviteeList.remove(i);
                 }  
            }
               
               
                 for(Visit_plan_invitee__c invitee : VisitPlanInviteeList ){
                     
                     if(invitee.TMB_Person__c==null){
                     }else{
                         if(checkDupSet.contains(invitee.TMB_Person__c)){
                            isDuplicated =true;
                         }else{
                            checkDupSet.add(invitee.TMB_Person__c); 
                         }
                         
                         if(invitee.TMB_Person__c == Callreport.OwnerID){
                             iscontainOwner = true;
                         }
                     }
                   row++;  
                
                }
            
               }
            
            system.debug('callreport.Start_Visit_Time__c='+callreport.Start_Visit_Time__c);
             if(callreport.Start_Visit_Time__c==null && callreport.End_Visit_Time__c ==null){
                    callreport.Start_Visit_Time__c='9:00';
                    callreport.End_Visit_Time__c='10:00';
                }
                if(callreport.Start_Visit_Time__c!=null && callreport.End_Visit_Time__c ==null){
                    
                    Integer StartHour = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(0));
                    Integer StartMinute = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(1));
                    String plusThirtyMinutes;
                    if(StartMinute==30){
                        plusThirtyMinutes = String.ValueOf(startHour+1)+':00';
                    }else{
                         plusThirtyMinutes = String.ValueOf(startHour)+':30';
                    }
                    callreport.End_Visit_Time__c=plusThirtyMinutes;
                }
                
                if(callreport.Start_Visit_Time__c==null && callreport.End_Visit_Time__c !=null){
                   Integer EndHour = Integer.valueOf(callreport.End_Visit_Time__c.split(':').get(0));
                    Integer EndMinute = Integer.valueOf(callreport.End_Visit_Time__c.split(':').get(1));
                    String minusThirtyMinutes;
                    if(EndMinute==30){
                        minusThirtyMinutes = String.ValueOf(EndHour)+':00';
                    }else{
                         minusThirtyMinutes = String.ValueOf(EndHour-1)+':30';
                    }
                    callreport.Start_Visit_Time__c=minusThirtyMinutes;
                    
                }
            
            if(callreport.Start_Visit_Time__c == callreport.End_Visit_Time__c ){
                    Integer StartHour = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(0));
                    Integer StartMinute = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(1));
                    String plusThirtyMinutes;
                    if(StartMinute==30){
                        plusThirtyMinutes = String.ValueOf(startHour+1)+':00';
                    }else{
                         plusThirtyMinutes = String.ValueOf(startHour)+':30';
                    }
                    callreport.End_Visit_Time__c=plusThirtyMinutes;
            }
            
            
            List<String> startsplit = callreport.Start_Visit_Time__c.split(':');
            List<String> endsplit = callreport.End_Visit_Time__c.split(':');
            Time StarttimeT = Time.newInstance( Integer.valueOF(startsplit.get(0)), 
                                              Integer.valueOF(startsplit.get(1)), 0, 0);
            Time EndTimeT = Time.newInstance(Integer.valueOF(endsplit.get(0)), 
                                              Integer.valueOF(endsplit.get(1)), 0, 0);
            
            
           
            System.debug(CallReport.Start_Visit_Time__c);
            System.debug(CallReport.End_Visit_Time__c);
            
            
            if(Callreport.Customer_name__c ==null && !IsLead){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7001').Status_Message__c));
            } 
            else if(Callreport.Lead__c ==null && IsLead){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead is required'));
            } 
            
            else if (isDuplicated){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7002').Status_Message__c));
               
            }else if (iscontainOwner){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7003').Status_Message__c));
            
            }else{
                System.debug('CallReport.Sub_Purpose__c : '+CallReport.Sub_Purpose__c);
                system.debug(subpurposeSelectedList);
                // String subpurpose = '';
                // Integer index =1;
                // for(SelectOption selected : subpurposeSelectedList){
                //     subpurpose += selected.getValue();
                //     if(index != subpurposeSelectedList.size()){
                //         subpurpose += '; ';
                //     }
                // }
                
                //  CallReport.Sub_Purpose__c = subpurpose;
               
            if(IsCreate){
                
               
                
                
             insert callreport;
            }else{
               update callreport; 
            }
            
               if(!isDuplicated && !iscontainOwner){
                  List<Visit_plan_invitee__c> insertInviteList = new List<Visit_plan_invitee__c>();
                  List<Visit_plan_invitee__c> updateinviteList = new List<Visit_plan_invitee__c>();
                   
                   for(Visit_plan_invitee__c invitee : VisitPlanInviteeList ){
                         
                       if(invitee.TMB_Person__c !=null){
                            if(invitee.id ==null){
                              invitee.Visit_Plan_Report__c = callreport.id;
                            insertInviteList.add(invitee);
                            }else{
                                updateinviteList.add(invitee);
                            }
                       }
                        
                    }
                   
                   if(Inviteeremovelist.size()>0){
                        delete Inviteeremovelist;
                
                    }
                  
                   System.debug(insertInviteList);
                   if(insertInviteList.size()>0){
                        insert insertInviteList;
                
                    }
                   System.debug(updateinviteList);
                   if(updateinviteList.size()>0){
                        update updateinviteList;
                
                    }
                  
               }
            
            

            
            
            if(ActivityID!='' && ActivityID!=null){  
             /*   system.debug('Update Activity ');
                system.debug('ActivityID '+ActivityID);
                Set<String> records = new Set<String>();
                for(String key : ActivityID.split(','))
                {
                    records.add(key);
                }
                
                System.debug('records '+records );
                
                List<AcctPlanActivity__c> AcctPlanAct= [Select Id from AcctPlanActivity__c where Id IN : records ];
                System.debug('AcctPlanAct '+AcctPlanAct);
                System.debug('callreport.id '+callreport.id); */
                for(AcctPlanActivity__c act : AcctPlanAct){
                    act.Visit_Plan_Report__c = callreport.id ;
                    update  act ;
                }
                PageReference pr = Page.CallReportViewDetail;
                pr.setRedirect(true);
                pr.getParameters().put('CallReportID',CallReport.id);
                pr.getParameters().put('&isdtp=vw',null);
                return pr;
    
                isSuccess = true;
            }else if(OppID != null && OppID != ''){
                Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c ();
                visitopp.Customer__c = CallReport.id;
                visitopp.Opportunity__c = opp.id;
                
                insert visitopp;
                              
            } 
            PageReference visitpage = new ApexPages.StandardController(CallReport).view();
                visitpage.setRedirect(true);
                return visitpage;
             /*PageReference visitpage = new ApexPages.StandardController(CallReport).view();
                visitpage.setRedirect(true);
                return visitpage;*/
            
            }
        }catch(DMLException E){
            String errormessage = e.getMessage().split(',').get(1).replace(': []','');
            System.debug('errormessage : '+errormessage);
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errormessage));
            
            
        }
        return null;
    }
    
    public void modalsaveMobile(){ 

        try{
            boolean isDuplicated = false;
            boolean iscontainOwner = false;
            
            if(VisitPlanInviteeList.size()>0){ 
                    
                Set<ID> checkDupSet = new Set<ID>(); 
                integer row =0;
                
                for(integer i=0;i<VisitPlanInviteeList.size();i++)
                {
                    if(VisitPlanInviteeList.get(i).TMB_Person__c ==null){
                        VisitPlanInviteeList.remove(i);
                    }  
                }
                
                for(Visit_plan_invitee__c invitee : VisitPlanInviteeList )
                {
                    if(invitee.TMB_Person__c==null){
                    
                    }else{
                        if(checkDupSet.contains(invitee.TMB_Person__c)){
                            isDuplicated =true;
                        }else{
                            checkDupSet.add(invitee.TMB_Person__c); 
                        }
                    
                        if(invitee.TMB_Person__c == Callreport.OwnerID){
                            iscontainOwner = true;
                        }
                    }
                    row++;
                }  
            }
                
                
           
             if(callreport.Start_Visit_Time__c==null && callreport.End_Visit_Time__c ==null){
                    callreport.Start_Visit_Time__c='9:00';
                    callreport.End_Visit_Time__c='10:00';
                }
                if(callreport.Start_Visit_Time__c!=null && callreport.End_Visit_Time__c ==null){
                    
                    Integer StartHour = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(0));
                    Integer StartMinute = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(1));
                    String plusThirtyMinutes;
                    if(StartMinute==30){
                        plusThirtyMinutes = String.ValueOf(startHour+1)+':00';
                    }else{
                         plusThirtyMinutes = String.ValueOf(startHour)+':30';
                    }
                    callreport.End_Visit_Time__c=plusThirtyMinutes;
                }
                
                if(callreport.Start_Visit_Time__c==null && callreport.End_Visit_Time__c !=null){
                   Integer EndHour = Integer.valueOf(callreport.End_Visit_Time__c.split(':').get(0));
                    Integer EndMinute = Integer.valueOf(callreport.End_Visit_Time__c.split(':').get(1));
                    String minusThirtyMinutes;
                    if(EndMinute==30){
                        minusThirtyMinutes = String.ValueOf(EndHour)+':00';
                    }else{
                         minusThirtyMinutes = String.ValueOf(EndHour-1)+':30';
                    }
                    callreport.Start_Visit_Time__c=minusThirtyMinutes;
                    
                }
            
            if(callreport.Start_Visit_Time__c == callreport.End_Visit_Time__c ){
                    Integer StartHour = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(0));
                    Integer StartMinute = Integer.valueOf(callreport.Start_Visit_Time__c.split(':').get(1));
                    String plusThirtyMinutes;
                    if(StartMinute==30){
                        plusThirtyMinutes = String.ValueOf(startHour+1)+':00';
                    }else{
                         plusThirtyMinutes = String.ValueOf(startHour)+':30';
                    }
                    callreport.End_Visit_Time__c=plusThirtyMinutes;
            }
            
            
            List<String> startsplit = callreport.Start_Visit_Time__c.split(':');
            List<String> endsplit = callreport.End_Visit_Time__c.split(':');
            Time StarttimeT = Time.newInstance( Integer.valueOF(startsplit.get(0)), 
                                              Integer.valueOF(startsplit.get(1)), 0, 0);
            Time EndTimeT = Time.newInstance(Integer.valueOF(endsplit.get(0)), 
                                              Integer.valueOF(endsplit.get(1)), 0, 0);
            
            
           
            System.debug(CallReport.Start_Visit_Time__c);
            System.debug(CallReport.End_Visit_Time__c);
                
            if(Callreport.Customer_name__c ==null && !IsLead){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7001').Status_Message__c));
            } 
            else if(Callreport.Lead__c ==null && IsLead){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead is required'));
            } 
            else if (isDuplicated){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7002').Status_Message__c));
               
            }else if (iscontainOwner){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('7003').Status_Message__c));
            
            }else{
                    
                String subpurpose = '';
                Integer index =1;
                for(SelectOption selected : subpurposeSelectedList){
                    subpurpose += selected.getValue();
                    if(index != subpurposeSelectedList.size()){
                        subpurpose += '; ';
                    }
                }
                
                CallReport.Sub_Purpose__c = subpurpose;
                   
                if(IsCreate){
                    insert callreport;
                }else{
                    update callreport; 
                }
                
                if(!isDuplicated && !iscontainOwner){
                    List<Visit_plan_invitee__c> insertInviteList = new List<Visit_plan_invitee__c>();
                    List<Visit_plan_invitee__c> updateinviteList = new List<Visit_plan_invitee__c>();
                    
                    for(Visit_plan_invitee__c invitee : VisitPlanInviteeList )
                    {
                
                        if(invitee.TMB_Person__c !=null){
                            if(invitee.id ==null){
                                invitee.Visit_Plan_Report__c = callreport.id;
                                insertInviteList.add(invitee);
                            }else{
                                updateinviteList.add(invitee);
                            }
                        }
                
                    }
                
                    if(Inviteeremovelist.size()>0){
                        delete Inviteeremovelist;
                    }
                
                    System.debug(insertInviteList);
                    if(insertInviteList.size()>0){
                        insert insertInviteList;
                    }
                   
                    System.debug(updateinviteList);
                    if(updateinviteList.size()>0){
                        update updateinviteList;
                    }
                
                }
                
                if(ActivityID!='' && ActivityID!=null)
                {  
                    for(AcctPlanActivity__c act : AcctPlanAct){
                        act.Visit_Plan_Report__c = callreport.id ;
                        update  act ;
                    }
        
                }else if(OppID != null && OppID != ''){
                    Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c ();
                    visitopp.Customer__c = CallReport.id;
                    visitopp.Opportunity__c = opp.id;
                    
                    insert visitopp;
                              
                } 
    
            }
            isSuccess = true;
        }catch(DMLException E){
           // ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
        }

        visitplanIdRedirect = callreport.id;
    }
   
    
    public Pagereference viewPage()
    {
        PageReference viewPage;
        viewPage = new ApexPages.StandardController(CallReport).view();
        //accountCreationPage.getParameters().put('customer_type',CustTypeStr);
        viewPage.setRedirect(true);          
        return viewPage; 
    }    
    
    public Pagereference Cancel(){
        PageReference viewPage;
        system.debug('sObjectID='+sObjectID);
        
        
        if(sObjectID!=null&&sObjectID!=''){
            String checksObjectType = SobjectId.substring(0,3);
            
            System.debug('AccountID='+AccountID);
            System.debug('LeadID='+LeadID);
            
            system.debug('checksObjectType='+checksObjectType);
            
            if(checksObjectType =='001'){
                Account accountObj = [select id,name from Account where id=:AccountID limit 1];
                system.debug('accountObj='+accountObj); 
                viewPage = new ApexPages.StandardController(accountObj).view();
                
            }else if(checksObjectType =='00Q'){
                Lead leadObj = [select id,name from Lead where id=:LeadID limit 1];
                system.debug('leadObj='+leadObj);
                viewPage = new ApexPages.StandardController(leadObj).view();
            }  
        }else if(CallReport != null){
            viewPage = new ApexPages.StandardController(CallReport).view();
        }else{
            viewPage = new PageReference('/a0A/o');  
        } 
        if(OppID != null && OppID != ''){
            viewPage = new ApexPages.StandardController(opp).view();
        }
        viewPage.setRedirect(true);
        return viewPage; 
    }
    
}