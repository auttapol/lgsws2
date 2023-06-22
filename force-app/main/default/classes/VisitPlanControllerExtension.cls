public with sharing class VisitPlanControllerExtension {
    public boolean Showvalue            {get;set;}
    
    public boolean VisitOwner           {get;set;}
    public boolean VisitReportOwner     {get;set;}
    public boolean Visithierarchy       {get;set;}
    public boolean VisitAccTeam         {get;set;}
    public boolean VisitTMBcounterParty {get;set;}
    public boolean IsLeadOwner          {get;set;}
    public boolean IsAccountOwner       {get;set;}
    
    Public list<user> CurrentUserRole   {get;set;}
    Public list<string> OwnerUserRole   {get;set;}
    Public list<string> currentRoleIds  {get;set;}
    Public set<string>  setcurrentIds   {get;set;}
    Public set<string>  setvisitplanIds {get;set;}
    Public string RolesInheirarchy      {get;set;}
    Public string AccountID             {get;set;}
    Public string VisitID               {get;set;}
    Public string VisitOwnerID          {get;set;}
    Public string VisitOwnerReportID    {get;set;}
    Public id currentrecordsId          {get;set;}
    Public id currentuserId             {get;set;}
    Public set<string>TMBcounterId      {get;set;}
    Public set<string>AccteamId         {get;set;}
    Public list<UserRecordAccess> accessList  {get;set;}
    public string apiObjectName {get;set;}
    
    
    public VisitPlanControllerExtension(ApexPages.StandardController controller) {
    
        apiObjectName = controller.getRecord().getSObjectType().getDescribe().getName();
        system.debug(apiObjectName);
    
        Showvalue = False;
        VisitOwner = False;
        VisitReportOwner = False;
        Visithierarchy = False;
        VisitAccTeam = False;
        VisitTMBcounterParty = False;
        IsLeadOwner = False;
        IsAccountOwner = False;
        
        currentrecordsId = ApexPages.currentPage().getParameters().get('id');
        currentuserId = Userinfo.getUserId();
        AccteamId = new set<string>();
        TMBcounterId = new set<string>();
        setcurrentIds = new set<string>();
        setvisitplanIds = new set<string>();
        system.debug('currentrecordsId : '+ currentrecordsId);
        /*if(string.valueof(currentrecordsId).left(3) == 'a0A') 
        {
            
            list<Call_Report__c> VisitAll = [select id,ownerid,Customer_name__c 
                                             from Call_Report__c 
                                             where id =:currentrecordsId];
                for(Call_Report__c visit: VisitAll) {
                    AccountID   =   visit.Customer_name__c;
                    VisitID     =   visit.Id;
                    VisitOwnerID=   visit.OwnerId;
                }
            list<Visit_Plan_Invitee__c> TMBCounterPartyAll = [Select Id,TMB_Person__c,Visit_Plan_Report__c 
                                                              from Visit_Plan_Invitee__c
                                                              where Visit_Plan_Report__c =: VisitID
                                                              and TMB_Person__c != null];
            if(TMBCounterPartyAll.size() > 0) {
                for(Visit_Plan_Invitee__c tmb : TMBCounterPartyAll) {
                    TMBcounterId.add(tmb.TMB_Person__c);
                }
            }
            
            list<AccountTeamMember> accTeam = [select Id,AccountAccessLevel,AccountId,TeamMemberRole,UserId 
                                       from AccountTeamMember 
                                       where AccountId =:AccountID];
            if(accTeam.size() > 0) {
                for(AccountTeamMember acc : accTeam) {
                    AccteamId.add(acc.UserId);
                }
            }
            
            accessList = new list<UserRecordAccess>();
            accessList = [SELECT RecordId,HasAllAccess,HasEditAccess,HasReadAccess  
                          FROM UserRecordAccess 
                          WHERE UserId =: Userinfo.getUserId()
                          AND RecordId =: currentrecordsId];
            
            
        } else if(string.valueof(currentrecordsId).left(3) == 'a1W')
        {*/
            list<Visit_Report__c> visitreport = [select id,OwnerId,Visit_Plan_Report__c
                                                 from Visit_Report__c 
                                                 where id =: currentrecordsId];
            if(visitreport.size() > 0)
            {       
                for(Visit_Report__c vire : visitreport) {
                        setvisitplanIds.add(vire.Visit_Plan_Report__c);
                        VisitOwnerReportID = vire.OwnerId;
                    }
            
                list<Call_Report__c> VisitAll = [select id,ownerid,Customer_name__c 
                                                 , Lead__c
                                                 , Customer_name__r.Ownerid, Lead__r.Ownerid
                                                 from Call_Report__c 
                                                 where id in: setvisitplanIds];
                for(Call_Report__c visit: VisitAll) {
                    AccountID   =   visit.Customer_name__c;
                    VisitID     =   visit.Id;
                    VisitOwnerID=   visit.OwnerId;
                    
                    if ((string.isNotBlank(string.valueof(visit.Customer_name__c)) && userinfo.getUserId() == visit.Customer_name__r.Ownerid)
                    || (string.isNotBlank(string.valueof(visit.Lead__c)) && userinfo.getUserId() == visit.Lead__r.Ownerid)){
                        IsLeadOwner = true;
                        IsAccountOwner = true;
                    }
                }
                
                
        }else{
            list<Call_Report__c> VisitAll = [select id,ownerid,Customer_name__c 
                                             , Lead__c
                                             , Customer_name__r.Ownerid, Lead__r.Ownerid
                                             from Call_Report__c 
                                             where id =:currentrecordsId];
                for(Call_Report__c visit: VisitAll) {
                    AccountID   =   visit.Customer_name__c;
                    VisitID     =   visit.Id;
                    VisitOwnerID=   visit.OwnerId;
                    
                    if ((string.isNotBlank(string.valueof(visit.Customer_name__c)) && userinfo.getUserId() == visit.Customer_name__r.Ownerid)
                    || (string.isNotBlank(string.valueof(visit.Lead__c)) && userinfo.getUserId() == visit.Lead__r.Ownerid)){
                        IsLeadOwner = true;
                        IsAccountOwner = true;
                    }
                }
                
        }   
            list<Visit_Plan_Invitee__c> TMBCounterPartyAll = [Select Id,TMB_Person__c,Visit_Plan_Report__c 
                                                              from Visit_Plan_Invitee__c
                                                              where Visit_Plan_Report__c =: VisitID
                                                              and TMB_Person__c != null];
            if(TMBCounterPartyAll.size() > 0) {
                for(Visit_Plan_Invitee__c tmb : TMBCounterPartyAll) {
                    TMBcounterId.add(tmb.TMB_Person__c);
                }
            }
            
            list<AccountTeamMember> accTeam = [select Id,AccountAccessLevel,AccountId,TeamMemberRole,UserId 
                                       from AccountTeamMember 
                                       where AccountId =:AccountID];
            if(accTeam.size() > 0) {
                for(AccountTeamMember acc : accTeam) {
                    AccteamId.add(acc.UserId);
                }
            }
            
            accessList = new list<UserRecordAccess>();
            accessList = [SELECT RecordId,HasAllAccess,HasEditAccess,HasReadAccess  
                          FROM UserRecordAccess 
                          WHERE UserId =: Userinfo.getUserId()
                          AND RecordId =: currentrecordsId];
        //}
        
    } 
    
    Public void checkrender() {
        /*if(string.valueof(currentrecordsId).left(3) == 'a0A')
        {
            //Check Role hierarchy
            if(accessList.size() > 0) {
                if(accessList.get(0).HasEditAccess == true){
                    Visithierarchy = true;
                }
            }
            
            //Check Account Team
            if(AccteamId.contains(currentuserId)) {
                VisitAccTeam = true;
            }
            
            //Check OwnerId visit plan
            if(VisitOwnerID == currentuserId) {
                VisitOwner = true;
            }
            
            //Check TMB Counter Party
            if(TMBcounterId.contains(currentuserId)) {
                VisitTMBcounterParty = true;
            }
            //Render
            if(Visithierarchy == true || VisitAccTeam == true || VisitOwner == true || VisitTMBcounterParty == true) {
                Showvalue = true;
            }
        } else if(string.valueof(currentrecordsId).left(3) == 'a1W')
        {*/
            //Check Role hierarchy
            if(accessList.size() > 0) {
                if(accessList.get(0).HasEditAccess == true){
                    Visithierarchy = true;
                }
            }
            
            //Check Account Team
            if(AccteamId.contains(currentuserId)) {
                VisitAccTeam = true;
            }
            
            //Check OwnerId visit plan
            if(setvisitplanIds.contains(VisitOwnerID)) {
                VisitOwner = true;
            }
            
            //Check OwnerId Visit Report
            if(VisitOwnerReportID != null){
                if(VisitOwnerReportID == currentuserId) {
                    VisitReportOwner = true;
                }
            }
            
            //Check OwnerId visit plan
            if(VisitOwnerID != null){
                if(VisitOwnerID == currentuserId) {
                    VisitOwner = true;
                }
            }
            
            //Check TMB Counter Party
            if(TMBcounterId.contains(currentuserId)) {
                VisitTMBcounterParty = true;
            }

            //Render
            if(Visithierarchy == true || VisitAccTeam == true || VisitOwner == true || VisitTMBcounterParty == true || VisitReportOwner == true
               || IsLeadOwner == true || IsAccountOwner == true) {
                Showvalue = true;
            } else {
                boolean continueVal = true;
                user u = [select UserRoleId from user where id =: currentuserId];
                string accOwnerRole = '';
                if (apiObjectName == 'Visit_Report__c') {
                
                    visit_report__c vr = [select Owner.UserRoleId
                                            , Visit_plan_report__r.Customer_name__r.Owner.UserRoleId
                                            from visit_report__c where id =: currentrecordsId];
                    if (vr != null) accOwnerRole = vr.Owner.UserRoleId;
                    
                } else if (apiObjectName == 'Call_Report__c') {
                
                    Call_Report__c cr = [select Owner.UserRoleId
                                           , Customer_name__r.Owner.UserRoleId
                                           from Call_Report__c where id =: currentrecordsId];
                    if (cr != null) accOwnerRole = cr.Owner.UserRoleId;
                    
                }
                string currentUserRole = '';
                if (u != null) currentUserRole = u.UserRoleId;
    
                if (currentUserRole != '' && currentUserRole != null)
                {
                    while (continueVal)
                    {
                        string accOwnerParentRole = '';
                        if (accOwnerRole != '' && accOwnerRole != null) {
                            UserRole ur = [select ParentRoleId from UserRole where id =: accOwnerRole];
                            if (ur != null) accOwnerParentRole = ur.ParentRoleId;
                        }
                        
                        if (accOwnerParentRole != '' && accOwnerParentRole != null) {
                            if (accOwnerParentRole != currentUserRole) {
                                accOwnerRole = accOwnerParentRole;
                            } else {
                                Showvalue = true;
                                continueVal = false;
                            }
                        } else {
                            continueVal = false;
                        }
                    }
                }            
            }
            
        //}
    }// End check render
}