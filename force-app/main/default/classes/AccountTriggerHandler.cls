public class AccountTriggerHandler {    

    //@TestVisible public static Boolean bypassTrigger = false;

    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    // public static List<User> activeuser {
    //     get
    //     {
    //         if(activeuser == null){ 
    //             activeuser = [select id,Employee_ID__c,IsActive,Profile.Name from user];
    //         }
    //         return activeuser;
            
    //     }set;
    // }

    public static User sfextapi{
        get{
            if(sfextapi == null){
                AppConfig__c temp = AppConfig__c.getValues('sfextapi');
                if(temp == null){
                    sfextapi = [SELECT Id FROM User WHERE Name = 'sfextapi' LIMIT 1];
                }else{
                    sfextapi = [SELECT Id FROM User WHERE Name =: temp.Value__c LIMIT 1];
                }
            }
            return sfextapi;
        }
        set;
    }

    public static map<String, Sub_Segment_Mapping__c> mapsubSegmentMapping {
        get{
            if(mapsubSegmentMapping == null){
                mapsubSegmentMapping = new map<String, Sub_Segment_Mapping__c>();
                for(Sub_Segment_Mapping__c subSegmap : [SELECT Id, Region_Group__c, Region_Code_Group_Code__c, Zone_Team__c, Zone_Code_Team_Code__c, Sub_Segment_Code__c FROM Sub_Segment_Mapping__c]){
                    mapsubSegmentMapping.put(subSegmap.Zone_Code_Team_Code__c, subSegmap);
                }
            }
            return mapsubSegmentMapping;
        }set;
    }
      
    // NOTE :  When we codding in Before Context we not use update in Accout list because it will update autometically!!!
    public static void handleBeforeInsert(List<Account> accsNew){
        //if (bypassTrigger) return;

        User currentUser = [SELECT ID,employee_id__c FROM USER WHERE ID =: Userinfo.getUserId()];

        //  map<Id,User> mapOwnerIdWithId = new map<Id,User>();
        // for (user u: activeuser){
            
        //     mapOwnerIdWithId.put(u.id, u);
        // }        
        List<String> listIds = new List<String>();
        Set<Id> setAssignBRCUser = new Set<Id>();
        Set<Id> setBranchZoneId = new Set<Id>();
        for(account acct : accsNew){
            listIds.add(acct.OwnerId);
            setAssignBRCUser.add(acct.RTL_Assigned_BRC__c);
            setBranchZoneId.add(acct.RTL_Most_Operating_Branch__c);
            
        }      
        if(setAssignBRCUser.size() > 0 && RTL_AccountUtility.mapUserById == null) {
            RTL_AccountUtility.generateUserMapId(setAssignBRCUser);
        }

        if(setBranchZoneId.size() > 0 && RTL_AccountUtility.mapBranchZoneById == null) {
            RTL_AccountUtility.generateBranchZoneMapId(setBranchZoneId);
        }
        
        AccountUtilityForConvertLead.listUserId = listIds;

        for(account acct : accsNew){
           acct.Owner_name_ID__c = currentUser.employee_id__c;
            // Start update new CR wealth field  
           if(acct.OwnerId != null){
                //acct.OwnerId = AccountUtility.getCommercial_RM(acct.OwnerId);
                acct.RTL_Commercial_RM__c = AccountUtilityForConvertLead.getCommercial_RM(acct.OwnerId);
           }

           if(acct.RTL_RM_Name__c != null){
                acct.RTL_Wealth_RM__c = RTL_AccountUtility.getWealth_RM(acct);
            }

        }

    }

    public static boolean isWFUpdate {get;set;}

    public static void handleBeforeUpdate(List<Account> accsNew,List<Account> accsOld){
        //if (bypassTrigger) return;

        List<String> listIds = new List<String>();
        for(account acct : accsNew){
            listIds.add(acct.OwnerId);
        }      
        
        AccountUtilityForConvertLead.listUserId = listIds;
        
        changeOwnerRetailToCommercial(accsNew,accsOld);

        isWFUpdate = false;
        map<Id,Account> mapAccsOldcheck = new map<Id,Account>();
        mapAccsOldCheck.putAll(accsOld);
        List<Account> ListAccsAfterCheckChangeOwner = new List<Account>();
        Set<Account> calculateSubSegmentset = new Set<Account>();

        set<string> oldOwnerId = new set<string>();
        for (account tmpold : accsOld)
        {
            oldOwnerId.add(tmpold.ownerid);
        }
        
        List<String> ids = new List<String>();
        for( Account acc : accsNew ){
            ids.add(acc.Id);
        }

        list<task> queryTask = [select id,accountid,ownerId from task where isClosed = false 
                        and IsRecurrence =true and accountid in: ids and ownerid in: oldOwnerId];
        List<String> accsIds = new List<String>();
        for(task t : queryTask){
            if(!accsIds.contains(t.AccountId)){
                accsIds.add(t.AccountId);
            }
        }

        Set<Id> setAssignBRCUser = new Set<Id>();
        Set<Id> setBranchZoneId = new Set<Id>();
        for(Account acc : accsNew) {
            setAssignBRCUser.add(acc.RTL_Assigned_BRC__c);
            setBranchZoneId.add(acc.RTL_Most_Operating_Branch__c);
        }

        if(setAssignBRCUser.size() > 0 && RTL_AccountUtility.mapUserById == null) {
            RTL_AccountUtility.generateUserMapId(setAssignBRCUser);
        }

        if(setBranchZoneId.size() > 0 && RTL_AccountUtility.mapBranchZoneById == null) {
            RTL_AccountUtility.generateBranchZoneMapId(setBranchZoneId);
        }

        for (Account acn : accsNew)
        {
            if (acn.ownerID != mapAccsOldCheck.get(acn.ID).ownerID){

                if(System.isBatch()){
                    if(accsIds.contains(acn.Id)){
                        acn.FoundRecurringDate__c = DateTime.now().date();
                    }
                }

                ListAccsAfterCheckChangeOwner.add(mapAccsOldCheck.get(acn.ID));

                if (acn.IsWFUpdate__c == true){
                    //                   ListAccsAfterCheckChangeOwner.add(mapAccsOldCheck.get(acn.ID));
                    acn.IsWFUpdate__c = false;
                    isWFUpdate = true;
                }
            } else {
                isWFUpdate = true;
            }
            
            Account nAcct = acn;
            Account oAcct =  mapAccsOldCheck.get(acn.ID);
            boolean rmUpdated = (nAcct.RTL_RM_Name__c != oAcct.RTL_RM_Name__c) || (nAcct.RTL_Assigned_BRC__c != oAcct.RTL_Assigned_BRC__c) || (nAcct.RTL_Most_Operating_Branch__c != oAcct.RTL_Most_Operating_Branch__c);
            if(rmUpdated){
                acn.RTL_Wealth_RM__c = RTL_AccountUtility.getWealth_RM(acn);
            }
            
            boolean isUpdateOwner = nAcct.OwnerId != oAcct.OwnerId;
            if(isUpdateOwner){
                acn.RTL_Commercial_RM__c = AccountUtilityForConvertLead.getCommercial_RM(acn.OwnerId); 
                calculateSubSegmentset.add(acn);
            }
            
            // [2020-05-28] update RTL_BRC_Updated_Date__c once RTL_Assigned_BRC__c got update.
            if(acn.RTL_Assigned_BRC__c != mapAccsOldCheck.get(acn.Id).RTL_Assigned_BRC__c){
                acn.RTL_BRC_Updated_Date__c = System.today();
            }

            //[2020-10-21] CR Custbase to calculate sub segment.
            if(acn.Change_to_be_segment__c != mapAccsOldCheck.get(acn.ID).Change_to_be_segment__c){
                if(acn.Change_to_be_segment__c != null) calculateSubSegmentset.add(acn);
            }
        }

        if (ListAccsAfterCheckChangeOwner.size() > 0){
            keepAccountTeam(ListAccsAfterCheckChangeOwner);
        }

        if(calculateSubSegmentset.size() > 0){
            calculateSubSegment(calculateSubSegmentset);
        }

        // if (isWFUpdate) {
        
//            if (ListAccsAfterCheckChangeOwner.size() > 0){
//                keepAccountTeam(ListAccsAfterCheckChangeOwner);              
//            }
            
            //Mr.Tay Comment 08/08/19 Move process to new object (ChangeOwmnerHistory) Triggers
            // list<account> listNew = checkConditionT05(accsNew,accsOld);
            // if( listNew.size() > 0 ){
            //     Trigger_T05( listNew ,accsOld,STR_UPDATE);    
            // }                  
      
        // }
    }
    
    public static void handleAfterUpdate(List<Account> accsNew,List<Account> accsOld){
        //if (bypassTrigger) return;

        if (isWFUpdate){
            List<Account> listNew = checkConditionT06(accsNew,accsOld);
            
            if( listNew.size() > 0 ){
                
                //system.debug( Logginglevel.ERROR, 'Start' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
                Trigger_T06( listNew ,accsOld,STR_UPDATE); 
                //system.debug( Logginglevel.ERROR, 'T06' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
                ChangeOwnerAcctplan(listNew ,accsOld,STR_UPDATE); 
                //system.debug( Logginglevel.ERROR, 'ChangeOwnerAcctplan' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
                changeOwnerExecutive(listNew ,accsOld,STR_UPDATE);
                //system.debug( Logginglevel.ERROR, 'changeOwnerExecutive' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
            }   
          
        }

        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        if (accsOld.size() > 0)
            listAccsOld.putAll(accsOld);
        
        List<string> ListAccountChangeID = new List<string>();
        for(Account acc : accsNew){
            if( acc.OwnerId != listAccsOld.get(acc.Id).OwnerId ){
                ListAccountChangeID.add(acc.id);
            }
        }
        
        if (ListAccountChangeID.size() > 0)
            checkInsertAccountTeam(ListAccountChangeID);

        // Auto update Contact
        RTL_AccountUtility.updateCommercialContactFromAccount(accsNew,accsOld);
        
    } 
    /* Method : checkCondition T01 
    *  Release / Module: R1.1 / Prospect Reassignment
    *  Comment: Fah / 2016-09-08
    *  Description: Get the record with re-assign prospect is changed to Yes, and Suggested Sub segment is not null
    *  Remark: No longer meet the criteria since R8 implementing
    */
    
    /*comment 2016-12-06 no use
    public static List<Account> checkConditionT01(List<Account> accsNew,List<Account> accsOld){
        List<Account> listReturn = new List<Account>();
        Map<Id,Account> mapAccsOld = new Map<Id,Account>();
        if( accsOld != null && accsOld.size() > 0 ){
            mapAccsOld.putAll(accsOld);
        }
                
        for(Account acc : accsNew){
            if( (acc.Re_assign_prospect__c == 'yes' && acc.Re_assign_prospect__c != mapAccsOld.get(acc.Id).Re_assign_prospect__c)
               && ( acc.Account_Type__c == 'Prospect' || acc.Account_Type__c == 'Qualified Prospect' )
               && acc.Suggested_Sub_Segment__c != ''){
                   listReturn.add(acc);
               }
        }
        return listReturn;
    }
    */
    
    /*
    public static List<Account> checkConditionT04(List<Account> accsNew,List<Account> accsOld){
        List<Account> listReturn = new List<Account>();
        Map<Id,Account> mapAccsOld = new Map<Id,Account>();
        if( accsOld != null && accsOld.size() > 0 ){
            mapAccsOld.putAll(accsOld);
        }
        
        for(Account acc : accsNew){
            if( acc.Account_Type__c == 'Qualified Prospect' && acc.Account_Type__c != mapAccsOld.get(acc.Id).Account_Type__c){
                listReturn.add(acc);
            }
        }
        return listReturn;
    }
    */

    /* Method : checkCondition T05
    *  Release / Module: R1.1 / Change owner for Exising Customer
    *  Comment: Fah / 2016-09-08
    *  Description: Get the record with Account Approval status is changed to Final Approved
    *  Remark: 
    */
    //Mr.Tay Comment 08/08/19 Move process to new object (ChangeOwmnerHistory) Triggers
    // public static List<Account> checkConditionT05(List<Account> accsNew,List<Account> accsOld){
    //     List<Account> listReturn = new List<Account>();
    //     Map<Id,Account> mapAccsOld = new Map<Id,Account>();
    //     if( accsOld != null && accsOld.size() > 0 ){
    //         mapAccsOld.putAll(accsOld);
    //     }
        
    //     for(Account acc : accsNew){
    //         if(acc.Account_Approval_Status__c == 'Final Approved' 
    //            && acc.Account_Approval_Status__c != mapAccsOld.get(acc.Id).Account_Approval_Status__c){
    //             listReturn.add(acc);
    //         }
    //     }
    //     return listReturn;
    // }

    /* Method : checkCondition T06
    *  Release / Module: R1.1 / Change owner 
    *  Comment: Fah / 2016-09-08
    *  Description: Get the record that the owner is changed
    *  Remark: 
    */
    public static List<Account> checkConditionT06(List<Account> accsNew,List<Account> accsOld){
        List<Account> listReturn = new List<Account>();
        Map<Id,Account> mapAccsOld = new Map<Id,Account>();
        if( accsOld != null && accsOld.size() > 0 ){
            mapAccsOld.putAll(accsOld);
        }
        
        for(Account acc : accsNew){
            if( acc.OwnerId != mapAccsOld.get(acc.Id).OwnerId ){
                listReturn.add(acc);
            }
        }
        return listReturn;
    }

    /* Method : Trigger_T01
    *  Release / Module: R1.1 / Prospect ressignment
    *  Comment: Fah / 2016-09-08
    *  Description: Change the owner of the record picked up from Prospect reassignment custom setting
    *  Remark: No longer use since R8 implementing
    */
    
    /*comment 2016-12-06 no use
    public static void Trigger_T01(List<Account> accsNew,List<Account> accsOld,String eventMode){
        System.debug(':::: Trigger_T01 Start ::::');
        List<Account> listAccNew = new List<Account>();
        Map<String,String> listSuggestedSubSegment = new Map<String,String>();
        List<Prospect_Owner_Assignment__c> listTMBStaffID =  Prospect_Owner_Assignment__c.getall().values();    
        List<User> listUser = [select Id,Employee_ID__c from User];
        Map<String,String> listEmployeeId = new Map<String,String>();
        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        if( eventMode == STR_UPDATE ){
            listAccsOld.putAll(accsOld);    
        }
        
        for (Prospect_Owner_Assignment__c poa : listTMBStaffID){
            if(poa.Name != null && poa.TMB_Staff_ID__c != null){
                listSuggestedSubSegment.put(poa.Name, poa.TMB_Staff_ID__c);
            }
        }
        
        for (User u : listUser){
            if(u.Employee_ID__c != null){
                listEmployeeId.put(u.Employee_ID__c, u.Id);
            }
            
        }
        
        //System.debug(':: '+listSuggestedSubSegment);
        
        for(Account acc : accsNew){
            if( (acc.Re_assign_prospect__c == 'yes' && acc.Re_assign_prospect__c != listAccsOld.get(acc.Id).Re_assign_prospect__c)
               && ( acc.Account_Type__c == 'Prospect' || acc.Account_Type__c == 'Qualified Prospect' )
               && acc.Suggested_Sub_Segment__c != ''){
                   detectError = false;
                   errorException = '';
                   String tmbId = '';
                   Id userId;
                   
                   //System.debug('::::: '+acc.Id +' | '+acc.Name + ' | '+acc.Suggested_Sub_Segment__c);
                   //System.debug('::::: detail input : '+acc);
                   if( listSuggestedSubSegment.containsKey(acc.Suggested_Sub_Segment__c) ){
                       tmbId = listSuggestedSubSegment.get(acc.Suggested_Sub_Segment__c);
                   }else{
                       detectError = true;
                       errorException = 'error containsKey Suggested_Sub_Segment__c : '+acc.Suggested_Sub_Segment__c;
                       acc.Re_assign_prospect__c = 'No';
                       acc.addError( Trigger_Msg__c.getValues('Not_Found_Suggested_Segment').Description__c  ,false); 
                       
                   }
                   
                   if( listEmployeeId.containsKey(tmbId) ){
                       userId = listEmployeeId.get(tmbId);
                   }else{
                       detectError = true;
                       errorException = 'error containsKey tmbId : '+tmbId;
                   }
                   
                   if( !detectError ){
                       acc.OwnerId = userId;
                       acc.Owner_change_notification__c = true;
                       //listAccNew.add(acc);    
                       System.debug('::::: Account Id : '+acc.id +' : Owner Change !! :::::');
                       System.debug('::::: Account Id Old : '+acc.id +' : '+listAccsOld.get(acc.Id).OwnerId+' , '+listAccsOld.get(acc.Id).Owner_change_notification__c+' :::::');
                       System.debug('::::: Account Id New : '+acc.id +' : '+acc.OwnerId+' , '+acc.Owner_change_notification__c+' :::::');
                   }else{
                       System.debug('::::: Account Id : '+acc.id +' : '+errorException+' :::::');
                   }             
               }
        }
        
        //if(listAccNew.size() > 0){
        // update listAccNew; // <===   Not Do this !!  if we want to update in same object in trigger we not update  list like this . Force.com will take care for us
        // }
        //System.debug('::::: List for update '+listAccNew.size()+' row :::::');
        System.debug(':::: Trigger_T01 End ::::');
    }
    */
    
    /*
    public static void Trigger_T04(List<Account> accsNew,List<Account> accsOld,String eventMode){
        System.debug(':::: Trigger_T04 Start ::::');
        List<Id> ids = new List<Id>();
        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        if( eventMode == STR_UPDATE ){
            listAccsOld.putAll(accsOld);
        }
        for( Account acc : accsNew ){
            ids.add(acc.Id);
        }
        
        Map<Id,AggregateResult> listOpp = new Map<Id,AggregateResult>([select AccountId Id,count(id) counts
                                                                       from Opportunity 
                                                                       where AccountId IN :ids group by AccountId]);
        Map<Id,AggregateResult> listLogACall = new Map<Id,AggregateResult>([select AccountId Id,count(id) counts 
                                                                            from Task
                                                                            where Subject = 'Call' and AccountId IN :ids group by AccountId]);
        Map<Id,AggregateResult> listVisitReport = new Map<Id,AggregateResult>([select Customer_name__c Id,count(id) counts
                                                                               FROM Call_Report__c 
                                                                               WHERE Customer_name__c IN :ids group by Customer_name__c]);
        
        for(Account acc : accsNew){
            if( acc.Account_Type__c == 'Qualified Prospect' && acc.Account_Type__c != listAccsOld.get(acc.Id).Account_Type__c){
                Integer countOpp = 0;
                Integer countLogACall = 0;
                Integer countVisitReport = 0;
                
                if( listOpp.containsKey(acc.Id) ){
                    countOpp = (Integer)listOpp.get(acc.Id).get('counts');
                }
                if( listLogACall.containsKey(acc.Id) ){
                    countLogACall = (Integer)listLogACall.get(acc.Id).get('counts');
                }
                if( listVisitReport.containsKey(acc.Id) ){
                    countVisitReport = (Integer)listVisitReport.get(acc.Id).get('counts');
                }
                
                if( countOpp != 0 && ( countLogACall != 0 || countVisitReport  !=0) ){
                    acc.Account_Type__c = 'Qualified Prospect';
                    acc.Prospect_Converted_Date__c = Date.today();
                    System.debug('::::: Converted Date Success : ' + Date.today()+' :::::');
                }
                System.debug('::::: AccountId is : '+acc.Id+' Opp :' +countOpp+ ' , LogACall : '+countLogACall+' , VisitReport : '+countVisitReport+' :::::');
            }
        }
        System.debug(':::: Trigger_T04 End ::::');
    }
    */
    /* Method : Trigger_T05
    *  Release / Module: R1.1 / Change owner of Existing customer through Approval process
    *  Comment: Fah / 2016-09-08
    *  Description: Change the owner for Existing Customer after manager approved
    *  Remark:
    */
    //Mr.Tay Comment 08/08/19 Move process to new object (ChangeOwmnerHistory) Triggers
    // public static void Trigger_T05(List<Account> accsNew,List<Account> accsOld,String eventMode){
    //     System.debug(':::: Trigger_T05 Start ::::');
    //     Map<Id,Account> listAccsOld = new Map<Id,Account>();
    //     if( eventMode == STR_UPDATE ){
    //         listAccsOld.putAll(accsOld);
    //     }
    //     for(Account acc : accsNew){
    //         if(acc.Account_Approval_Status__c == 'Final Approved' && acc.Change_Owner_Cross_Segment_flag__c == false
    //            && acc.Account_Approval_Status__c != listAccsOld.get(acc.Id).Account_Approval_Status__c){
    //                 acc.OwnerId = acc.Change_to_owner__c;
    //                 // acc.Owner_change_notification__c = true; //Fah comment 23-02-15
    //                 //acc.Change_to_owner__c = null;
    //            }
    //     }
        
    //     System.debug(':::: Trigger_T05 End ::::');
    // }
    

    /* Method : Trigger_T06
    *  Release / Module: R1.1 / Change owner on Account
    *  Comment: Fah / 2016-09-08
    *  Description: Move the related records (Visit Plan/Report, Opportunity, ) when the account owner is changed
    *  Remark: 
    */
    public static void Trigger_T06(List<Account> accsNew,List<Account> accsOld,String eventMode){
        System.debug(':::: Trigger_T06 Start ::::');
        List<Id> ids = new List<Id>();
        List<Opportunity> listOppForUpdate = new List<Opportunity>();
        List<Call_Report__c> listReportForUpdate = new List<Call_Report__c>();
        List<Call_Report__Share> callReportShareForInsert = new List<Call_Report__Share>();
        list<task> listTaskForUpdate = new list<task>();
        
        set<string> oldOwnerId = new set<string>();
        for (account tmpold : accsOld)
        {
            oldOwnerId.add(tmpold.ownerid);
        }
        
        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        if( eventMode == STR_UPDATE ){
            listAccsOld.putAll(accsOld);
        }
        for( Account acc : accsNew ){
            ids.add(acc.Id);
        }
        
        /*
        List<string> ListOpenStageName = new List<string>();
        for (opportunityStage o : [select MasterLabel from opportunityStage where isActive = true and isClosed = false])
        {
            ListOpenStageName.add(o.MasterLabel);
        }
        */
        
        List<Opportunity> listOpps = [select Id,AccountId, OwnerId ,PrevOwnerId__c, LeadSource
                                     from Opportunity 
                                     where AccountId IN :ids
                                     and isClosed = false];
                                     //and StageName IN: ListOpenStageName];
                                     //and StageName IN ('Analysis','Develop & Propose Solution','Follow Up')];
        /*                            
        Map<String,Opportunity> mapOpps = new Map<String,Opportunity>();
        for(Opportunity opp : listOpps){
            if(opp.AccountId != null){
                mapOpps.put(opp.AccountId,opp);
            }  
        }
        */
        /*
        List<Opportunity> listForUpdateReverse = new List<Opportunity>(); 
        List<Opportunity> listOppsReverse = [select Id,AccountId, OwnerId ,PrevOwnerId__c
                                     from Opportunity 
                                     where AccountId IN :ids
                                     and isClosed = false
                                     and StageName NOT IN: ListOpenStageName];
                                     //and StageName NOT IN ('Analysis','Develop & Propose Solution','Follow Up')];
        */
        List<Call_Report__c> listReports = [select Id,Customer_name__c,OwnerId
                                            from Call_Report__c 
                                            where Status__c like '%Open%' 
                                            and Customer_name__c IN :ids];
        Map<String,Call_Report__c> mapReports = new Map<String,Call_Report__c>();
        for(Call_Report__c report : listReports){
            if(report.Customer_name__c != null){
                mapReports.put(report.Customer_name__c,report);
            }            
        }

        /* Fah: 2016-09-08 
         * No longer use: call report is changed the sharing model to Public-read
         *
        List<Call_Report__c> queryCallReport = [select Id,Customer_name__c,OwnerId
                                            from Call_Report__c 
                                            where (not Status__c like '%Open%')
                                            and Customer_name__c IN :ids];
        */

        list<task> queryTask = [select id,accountid,ownerId from task where isClosed = false 
                        and IsRecurrence =false and accountid in: ids and ownerid in: oldOwnerId];

        for(Account acc : accsNew){
            // if change owner
            if( acc.OwnerId != listAccsOld.get(acc.Id).OwnerId ){
            
                /*
                for( Opportunity o : listOppsReverse ){
                    if( o.AccountId == acc.Id && o.ownerid == listAccsOld.get(acc.Id).ownerid){
                        //o.OwnerId = listAccsOld.get(acc.Id).OwnerId;
                        o.Trigger_Flag__c = true;
                        o.ownerId = o.PrevOwnerId__c; 
                        listOppForUpdate.add(o);
                        //listForUpdateReverse.add(o);
                    }
                }
                */
                
                for( Opportunity o : listOpps ){
                    if( o.AccountId == acc.Id && (o.ownerid == listAccsOld.get(acc.Id).ownerid || (o.ownerid == sfextapi.Id && o.LeadSource == 'OLAP'))){

                        //Add Code to prevent recursive call for oppty trigger
                        //By  ignore already same data to be updated

                        //if( o.OwnerId != acc.OwnerId || o.Trigger_Flag__c != true )
                        //{
                            o.OwnerId = acc.OwnerId;
                            o.Trigger_Flag__c = true; 
                        o.Is_Allow_Edit__c = true;
                            listOppForUpdate.add(o);
                            System.debug('::::: List Opp : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                        //}
                    }
                }
                
                /*if( mapOpps.containsKey(acc.Id) ){
                    mapOpps.get(acc.Id).OwnerId = acc.OwnerId;
                    listOppForUpdate.add( mapOpps.get(acc.Id) );
                    System.debug('::::: List Opp : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                }else{
                    System.debug('::::: List Opp : error containsKey '+acc.Id+' :::::');
                }*/
                
                for(Call_Report__c r : listReports){
                    if( r.Customer_name__c == acc.Id && r.ownerid == listAccsOld.get(acc.Id).ownerid){
                        r.OwnerId = acc.OwnerId;
                        listReportForUpdate.add(r);
                        System.debug('::::: List Report : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                    }
                }
                
                /*
                for( Call_Report__c eachCallReport : queryCallReport ){                    
                    if( eachCallReport.Customer_name__c == acc.Id && eachCallReport.ownerid == listAccsOld.get(acc.Id).ownerid){ 
                        Call_Report__Share callReportShare = new Call_Report__Share();
                        callReportShare.ParentId = eachCallReport.Id;
                        callReportShare.UserOrGroupId = acc.OwnerId;
                        callReportShare.AccessLevel = 'Read';
                        callReportShare.RowCause = Schema.Call_Report__Share.RowCause.Manual;
                        callReportShareForInsert.add(callReportShare);
                        System.debug('::::: callReportShare : '+callReportShare+' :::::');
                    }
                }
                */
                
                /*if( mapReports.containsKey(acc.Id) ){
                    mapReports.get(acc.Id).OwnerId = acc.OwnerId;
                    listReportForUpdate.add( mapReports.get(acc.Id) );
                    System.debug('::::: List Report : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                }else{
                    System.debug('::::: List Report : error containsKey '+acc.Id+' :::::');
                }*/
                
                for (task t : queryTask)
                {
                    if(t.accountid == acc.id && t.ownerid == listAccsOld.get(acc.Id).ownerid)
                    {
                        t.ownerid = acc.ownerid;
                        listTaskForUpdate.add(t);
                        system.debug('::::: Task : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                    }
                }
                
            }
        }
        /*
        if(listForUpdateReverse.size() > 0){
            try{
                update listForUpdateReverse;    
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        } */          
        
        if(listOppForUpdate.size() > 0){
            try{
//                update listOppForUpdate;    
                //system.debug(Logginglevel.ERROR, 'oppty update in Account Trigger: ' + listOppForUpdate.size() );
                //system.debug( Logginglevel.ERROR,  'T06 - before: listOppForUpdate' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
                Database.Update(listOppForUpdate, false);
                //system.debug( Logginglevel.ERROR,  'T06 - after: listOppForUpdate' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        }
        
        if(listReportForUpdate.size() > 0){
            try{
//                update listReportForUpdate;
                Database.Update(listReportForUpdate, false);
                //system.debug( Logginglevel.ERROR, 'T06 - listReportForUpdate' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }            
        }        

        /* Fah: 2016-09-08 
         * No longer use: call report is changed the sharing model to Public-read
         *
        System.debug('::::: callReportShareForInsert update size of '+callReportShareForInsert.size()+' row:::::');
        if( callReportShareForInsert.size() > 0 ){
            try{
              //  insert callReportShareForInsert;
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        }
        */

        if (listTaskForUpdate.size() > 0)
        {
            try{
//                update listTaskForUpdate;
                Database.Update(listTaskForUpdate, false);
                //system.debug( Logginglevel.ERROR, 'T06 - listTaskForUpdate' + ' Usage: '  +Limits.getCpuTime()  + '/' + Limits.getLimitCpuTime()  );
            }catch(DmlException ex){
                system.debug('error : '+ex.getMessage());
            }
        }
        
        System.debug('::::: ListOpp for update '+listOppForUpdate.size()+' row :::::');
        //System.debug('::::: ListOppReverse for update '+listForUpdateReverse.size()+' row :::::');
        System.debug('::::: ListReport for update '+listReportForUpdate.size()+' row :::::');
        System.debug('::::: LstTask for update '+listTaskForUpdate.size()+' row :::::');
        
        System.debug(':::: Trigger_T06 End ::::');
        
    }

    
    
    /* Method : ChangeOwnerAcctplan
    *  Release / Module: R1.1 / Change owner AccountPlan
    *  Comment: Fah / 2016-09-08
    *  Description: Change account plan owner after account owner change
    *  Remark: 
    */
     public static void ChangeOwnerAcctplan(List<Account> accsNew,List<Account> accsOld,String eventMode){
        System.debug(':::: ChangeOwnerAcctplan Start ::::');
        List<Id> ids = new List<Id>();
         List<AcctPlanWallet__c> listwalletForUpdate = new List<AcctPlanWallet__c>();       
         List<AcctPlanContribution__c> listContributionForUpdate = new List<AcctPlanContribution__c>();     
        List<AcctPlanWalletByDomain__c> listWalletbyDomainUpdate = new  List<AcctPlanWalletByDomain__c> ();
        List<AcctPlanCompanyProfile__c> listComForUpdate = new List<AcctPlanCompanyProfile__c>();
        List<AcctPlanCompanyPort__c> listComPortForUpdate = new List<AcctPlanCompanyPort__c>();
        List<Lead> listLeadForUpdate = new List<Lead>();
//        List<string> ListAccountChangeID = new List<string>();         
        
        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        
        if( eventMode == STR_UPDATE ){
            listAccsOld.putAll(accsOld);
        }
        for( Account acc : accsNew ){
            ids.add(acc.Id);
        }
        System.debug(':::: ids ::::'+ids);
         
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();
        Integer currentYear = currentDate.year();
        if(currentYear>2557) currentYear = currentDate.year() - 543;

        System.debug(':::: currentMonth ::::'+currentMonth);
        System.debug(':::: currentYear ::::'+currentYear);
        
        String YearStr = String.ValueOf(currentYear);
        
        List<AcctPlanCompanyProfile__c> listCompany = [SELECT Account__c,OwnerId,Year__c,Status__c,isPendingForApproval__C FROM AcctPlanCompanyProfile__c where Account__c IN :ids and Year__c  >=: YearStr ] ;
          Map<ID,List<AcctPlanCompanyProfile__c>> mapCompany = new Map<ID,List<AcctPlanCompanyProfile__c>>();
          for(AcctPlanCompanyProfile__c item :listCompany){
                if(mapCompany.containsKey(item.Account__c)){
                    mapCompany.get(item.Account__c).add(item);
                }else{
                    List<AcctPlanCompanyProfile__c> acctcomList = new List<AcctPlanCompanyProfile__c>();
                    acctcomList.add(item);
                    mapCompany.put(item.Account__c,acctcomList);
                }
          }

        
        List<AcctPlanCompanyPort__c> listCompanyPort = [SELECT Id,Account__c,OwnerId FROM AcctPlanCompanyPort__c where Account__c IN :ids and Account_Plan_Portfolio__r.Year__c  >=: YearStr] ;
        Map<ID,List<AcctPlanCompanyPort__c>> mapCompanyPort = new Map<ID,List<AcctPlanCompanyPort__c>>();
          for(AcctPlanCompanyPort__c item :listCompanyPort){
                if(mapCompanyPort.containsKey(item.Account__c)){
                    mapCompanyPort.get(item.Account__c).add(item);
                }else{
                    List<AcctPlanCompanyPort__c> acctcomPortList = new List<AcctPlanCompanyPort__c>();
                    acctcomPortList.add(item);
                    mapCompanyPort.put(item.Account__c,acctcomPortList);
                }
          }

        //List<Lead> listLead = [select id,ownerid,Account__c from lead where Account__c in: ids and status in ('Open','Passed Prescreening','Contacted')];
        //list<recordtype> objRecordType = [select id,name from recordtype where name = 'Commercial Account'];
        //List<Lead> listLead = [select id,ownerid,Account__c from lead where Account__c in: ids and recordtypeid =: objRecordType.get(0).id];
        /*** to avoid too many soql ***/
         List<AcctPlanWallet__c> listWallet = [SELECT ID,AcctPlanCompanyProfile__c,OwnerID      
         from AcctPlanWallet__c WHERE AcctPlanCompanyProfile__c IN: listCompany ];      
         Map<ID,AcctPlanWallet__c> mapwallet = new Map<ID,AcctPlanWallet__c>();     
         List<id> walletIds = new List<id>();       
         for(AcctPlanWallet__c wallet : listWallet){        
            mapwallet.put(wallet.AcctPlanCompanyProfile__c,wallet);     
            walletIds.add(wallet.id);       
         }
         
        Id objRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
        List<Lead> listLead = [select id,ownerid,Account__c from lead where Account__c in: ids and recordtypeid =: objRecordType]; 
        Map<ID,List<Lead>> mapLead = new Map<ID,List<Lead>>();
          for(Lead item : listLead){
                if(mapLead.containsKey(item.Account__c)){
                    mapLead.get(item.Account__c).add(item);
                }else{
                    List<Lead> leadList = new List<Lead>();
                    leadList.add(item);
                    mapLead.put(item.Account__c,leadList);
                }
          }

        System.debug(':::: listCompany ::::'+listCompany.size());
        System.debug(':::: listCompanyPort ::::'+listCompanyPort.size());
         
         /*========= Change Owner : Jantanee Saetung ==========*/       
        List<AcctPlanContribution__c> listContribution = [SELECT Id,Account_Plan_Company_Profile__r.Account__c,Account_Plan_Company_Profile__r.Year__c,OwnerId FROM AcctPlanContribution__c where Account_Plan_Company_Profile__r.Account__c IN :ids and Account_Plan_Company_Profile__r.Year__c  >=: YearStr] ;        
        List<AcctPlanWalletByDomain__c> listWalletByDomain = [SELECT Id,AcctPlanWallet__c,AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c,OwnerId FROM AcctPlanWalletByDomain__c where AcctPlanWallet__c IN :walletIds ] ;
         
         Map<ID,List<AcctPlanContribution__c>> mapContributuion = new Map<ID,List<AcctPlanContribution__c>>();
          for(AcctPlanContribution__c item :listContribution){
                if(mapContributuion.containsKey(item.Account_Plan_Company_Profile__r.Account__c)){
                    mapContributuion.get(item.Account_Plan_Company_Profile__r.Account__c).add(item);
                }else{
                    List<AcctPlanContribution__c> acctContributiontList = new List<AcctPlanContribution__c>();
                    acctContributiontList.add(item);
                    mapContributuion.put(item.Account_Plan_Company_Profile__r.Account__c,acctContributiontList);
                }
          }

          Map<ID,List<AcctPlanWalletByDomain__c>> mapWalletDomain = new Map<ID,List<AcctPlanWalletByDomain__c>>();
          for(AcctPlanWalletByDomain__c item :listWalletByDomain){
                if(mapWalletDomain.containsKey(item.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c)){
                    mapWalletDomain.get(item.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c).add(item);
                }else{
                    List<AcctPlanWalletByDomain__c> walletDoaminList = new List<AcctPlanWalletByDomain__c>();
                    walletDoaminList.add(item);
                    mapWalletDomain.put(item.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c,walletDoaminList);
                }
          }

System.debug(':::: mapwallet ::::'+mapwallet.size());
System.debug(':::: mapCompany ::::'+mapCompany.size());
System.debug(':::: mapCompanyPort ::::'+mapCompanyPort.size());
System.debug(':::: mapContributuion ::::'+mapContributuion.size());
System.debug(':::: mapWalletDomain ::::'+mapWalletDomain.size());

     Set<String> TargetObjectIDList = new Set<String>();
         
        for(Account acc : accsNew){
            // if change owner
            System.debug(':::: mapwallet ::::'+mapwallet.get(acc.id));
            System.debug(':::: mapCompany ::::'+mapCompany.get(acc.id));
            System.debug(':::: mapCompanyPort ::::'+mapCompanyPort.get(acc.id));
            System.debug(':::: mapContributuion ::::'+mapContributuion.get(acc.id));
            System.debug(':::: mapWalletDomain ::::'+mapWalletDomain.get(acc.id));
            if( acc.OwnerId != listAccsOld.get(acc.Id).OwnerId ){

                if(mapCompany.containsKey(acc.id)){
                    for( AcctPlanCompanyProfile__c com : mapCompany.get(acc.id) ){
                        if( com.Account__c == acc.Id ){
                            com.ownerId = acc.OwnerId;              
                            listcomForUpdate.add(com);
                            System.debug('::::: List Com : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                            if(mapwallet.containsKey(com.id)){      
                             AcctPlanWallet__c wallet = mapwallet.get(com.id);      
                             wallet.OwnerID = acc.OwnerId;      
                             listwalletForUpdate.add(wallet);       
                           }
                        }
                    }
                }
                
                /*========= Fix bug Expected NI Step 0 : Jantanee Saetung ==========*/
                if(mapCompanyPort.containsKey(acc.id)){
                    for( AcctPlanCompanyPort__c com : mapCompanyPort.get(acc.id) ){
                        if( com.Account__c == acc.Id ){
                            com.ownerId = acc.OwnerId;
                            listcomPortForUpdate.add(com);
                            System.debug('::::: List Com Port : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');
                        }
                    }
                }
                
                /*** R8 change account owner -> change lead owner ***/
                if(mapLead.containsKey(acc.id)){
                    for (lead l : mapLead.get(acc.id))    
                    {
                        if (l.Account__c == acc.id && l.ownerid == listAccsOld.get(acc.Id).ownerid)
                        {
                            l.ownerid = acc.ownerid;
                            listLeadForUpdate.add(l);
                            system.debug('::::: List Lead : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.ownerid+' :::::');
                        }
                    }
                }
                
                /*========= Change Owner : Jantanee Saetung ==========*/        
    
                //Contribution      
                if(mapContributuion.containsKey(acc.id)){
                    for( AcctPlanContribution__c c : mapContributuion.get(acc.id) ){        
                        if( c.Account_Plan_Company_Profile__r.Account__c == acc.Id ){       
                            c.ownerId = acc.OwnerId;        
                            listContributionForUpdate.add(c);       
                            System.debug('::::: List Com Port : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');        
                        }       
                    }   
                }   

                //Wallet by Domain      
                if(mapWalletDomain.containsKey(acc.id)){
                    for( AcctPlanWalletByDomain__c wd : mapWalletDomain.get(acc.id) ){      
                        if( wd.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c == acc.Id ){      
                            wd.ownerId = acc.OwnerId;       
                            listWalletbyDomainUpdate.add(wd);       
                            System.debug('::::: List Com Port : Change Owner '+listAccsOld.get(acc.Id).OwnerId+' to '+acc.OwnerId+' :::::');        
                        }
                    }
                }

                
//                ListAccountChangeID.add(acc.id);
            }
                
            }
            
        
//        checkInsertAccountTeam(ListAccountChangeID);
      
        if(listComForUpdate.size() > 0 || listLeadForUpdate.size() > 0 || listComPortForUpdate.size()>0
          || listwalletForUpdate.size()>0 || listContributionForUpdate.size()>0 || listWalletbyDomainUpdate.size()>0){
            try{


//                update listComForUpdate;  
//                update listComPortForUpdate;
//                update listLeadForUpdate;  
//                update listwalletForUpdate;         
//                update listContributionForUpdate;       
//                update listWalletbyDomainUpdate;
                Database.Update(listComForUpdate, false);
                Database.Update(listComPortForUpdate, false);
                Database.Update(listLeadForUpdate, false);
                Database.Update(listwalletForUpdate, false);
                Database.Update(listContributionForUpdate, false);
                Database.Update(listWalletbyDomainUpdate, false);
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        }
        

        
        System.debug('::::: ListCompanyProfile for update '+listComForUpdate.size()+' row :::::');
        
        System.debug(':::: ChangeOwnerAcctplan End ::::');
        
    }
 
    /* Method : keepAccountTeam
    *  Release / Module: CR-148708-2016-002 change owner / Change owner CR
    *  Comment: Fah / 2016-09-08
    *  Description: 
    *  Remark: 
    */
    public static list<accountTeamMember> ListAccountTeam {get;set;}
    public static list<accountShare> ListAccountShare {get;set;}
    public static list<opportunityTeamMember> ListOpportunityTeam {get;set;}
    public static list<opportunityShare> ListOpportunityShare {get;set;}
    public static integer countAccTeam {get;set;}
    public static integer countOppTeam {get;set;}
    public static void keepAccountTeam(List<Account> listAccount)
    {
        ListAccountTeam = new list<accountTeamMember>();
        ListAccountShare = new list<accountShare>();
        ListOpportunityTeam = new list<opportunityTeamMember>();
        ListOpportunityShare = new list<opportunityShare>();
        countAccTeam = 0;
        countOppTeam = 0;

        list<string> listAccId = new list<string>();
        list<string> listOppId = new list<string>();
        
        for (account a: listAccount)
        {
            listAccId.add(a.id);
        }
        for (accountTeamMember atm : [select accountid,userid,teammemberrole 
                                      from accountteammember where accountid in: listAccId])
        {
            //mapListAccountTeam.put(atm.accountid+atm.userid,atm);
            accountTeamMember n_atm = new accountTeamMember();
            n_atm.accountid = atm.accountid;
            n_atm.userid = atm.userid;
            n_atm.teammemberrole = atm.teammemberrole;
            ListAccountTeam.add(n_atm);
            countAccTeam++;
        }
        for (accountShare acs : [select accountid,userOrgroupid,accountaccesslevel,opportunityaccesslevel,caseaccesslevel,contactaccesslevel,rowcause 
                                 from accountshare where accountid in: listAccId and rowcause = 'Team'])
        {
            //mapListAccountShare.put(atm.accountid+atm.userOrgroupid,acs);
            accountShare n_acs = new accountShare();
            n_acs.accountid = acs.accountid;
            n_acs.userOrgroupid = acs.userOrgroupid;
            n_acs.accountaccesslevel = acs.accountaccesslevel;
            n_acs.opportunityaccesslevel = acs.opportunityaccesslevel;
            n_acs.caseaccesslevel = acs.caseaccesslevel;
            //n_acs.contactaccesslevel = acs.contactaccesslevel;
            //n_acs.rowcause = acs.rowcause;
            ListAccountShare.add(n_acs);
        }
        
        
        for(Opportunity op : [select Id from Opportunity where AccountId IN :listAccId and isClosed = false])
        {
            listOppId.add(op.Id);
        }
        for (opportunityTeamMember otm : [select opportunityid,userid,teammemberrole 
                                          from opportunityTeamMember where opportunityid in: listOppId])
        {
            opportunityTeamMember n_otm= new opportunityTeamMember();
            n_otm.opportunityid = otm.opportunityid;
            n_otm.userid = otm.userid;
            n_otm.teammemberrole = otm.teammemberrole;
            ListOpportunityTeam.add(n_otm);
            countOppTeam++;
        }
        for (opportunityShare ops : [select opportunityid,userOrgroupid,opportunityaccesslevel,rowcause 
                                     from opportunityShare where opportunityid in: listOppId and rowcause = 'Team'])
        {
            //mapListAccountShare.put(atm.accountid+atm.userOrgroupid,acs);
            opportunityShare n_ops = new opportunityShare();
            n_ops.opportunityid = ops.opportunityid;
            n_ops.userOrgroupid = ops.userOrgroupid;
            n_ops.opportunityaccesslevel = ops.opportunityaccesslevel;
            ListOpportunityShare.add(n_ops);
        }
        
    }

    /* Method : checkInsertAccountTeam
    *  Release / Module: CR-148708-2016-002 change owner / Change owner CR
    *  Comment: Fah / 2016-09-08
    *  Description: 
    *  Remark: 
    */
    public static void checkInsertAccountTeam(List<string> listAccId)
    {
    
        try {
        
            if (!Test.isRunningTest())
            {
                integer count_atm = [select count() from accountTeamMember where accountid in: listAccId];
                if (count_atm != countAccTeam)
                {
                    insert ListAccountTeam;
                    insert ListAccountShare;
                }
                
                List<string> listOppId = new List<string>();
                for(Opportunity op : [select Id from Opportunity where AccountId IN :listAccId and isClosed = false])
                {
                    listOppId.add(op.Id);
                }
                
                integer count_otm = [select count() from opportunityTeamMember where opportunityId in: listOppId];
                if (count_otm != countOppTeam)
                {
                    insert ListOpportunityTeam;
                    insert ListOpportunityShare;
                }
            }
            
            
        } catch(exception ex) {
            system.debug('error : '+ex.getMessage());
        }        
        
    }

    /*** Change Owner Executive Summary follow by Change Account owner by Jittramas 3/10/2016 ***/
    public static void changeOwnerExecutive(List<Account> accsNew,List<Account> accsOld,String eventMode){
        System.debug(':::: changeOwnerExecutive Start ::::');
        List<Executive_Summary__c> execToUpdate = new List<Executive_Summary__c>();
        Set<Id> accIds = new Set<Id>();
        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        
        if( eventMode == STR_UPDATE ){
            listAccsOld.putAll(accsOld);
        }
        for(Account acc : accsNew){
            accIds.add(acc.Id);
        }
        
        //List<Executive_Summary__c> listExec = new List<Executive_Summary__c>([SELECT Id,OwnerId,Team_Head__c FROM Executive_Summary__c WHERE Customer_Name__c IN:accIds]);

        Map<Id,List<Executive_Summary__c>> execMap = new  Map<Id,List<Executive_Summary__c>>();
        List<Account> listAggregateAccount = [SELECT Id,(select id,Ownerid from Executive_Report__r) FROM account where id IN:accIds];
        
        for (Account ac : listAggregateAccount)
        {
            execMap.put(ac.id,ac.executive_report__r);
        }
 
        for(Account acc : accsNew){
            if(acc.OwnerId != listAccsOld.get(acc.Id).OwnerId){
                List<Executive_Summary__c> exeForAccList = execMap.get(acc.Id);
                for(Executive_Summary__c exec : exeForAccList){
                    exec.OwnerId = acc.OwnerId;
                    execToUpdate.add(exec);
                }
            }
        }
        
        /*
        for(Account acc : accsNew){
            if(acc.OwnerId != listAccsOld.get(acc.Id).OwnerId){
                for(Executive_Summary__c exec : listExec){
                    exec.OwnerId = acc.OwnerId;
                    If(listExec != execToUpdate){
                        execToUpdate.add(exec);
                    }
                }
            }
        }
        */
        
        system.debug('## execToUpdate : '+execToUpdate);
        if(execToUpdate.size() > 0){
            try{
//                update execToUpdate;
                Database.Update(execToUpdate, false);
            }catch(DmlException ex){
                System.debug('DML error : '+ex.getMessage());        
            }
        }


        System.debug(':::: changeOwnerExecutive End ::::');
    }



    /* Method : Recall Account Plan Approval Process
    *  Release / Module: Account Plan 5.2
    *  Comment: Muu 21 Dec 2016
    *  Description: 
    *  Remark: 
    */


   
    /* Method : Change Owner Retail To Commercial
    *  Release / Module: CR - Prospect Retail to Commercial
    *  Comment: DA, May 2016
    *  Description: Fixed for Prospect Retail to Commercial customer
    *  Remark: 

    */
    /*
    Unused this code due to refactoring INC0044781_CHANGE_ACCOUNT_OWNER_ONLY_SFADMRTL
    public static void changeOwnerRetailToCommercial(List<Account> accsNew,List<Account> accsOld){
        
        System.debug(':::: change owner retail to commercial start ::::');
        
        List<Account> listReturn = new List<Account>();
        Map<Id,Account> mapAccsOld = new Map<Id,Account>();
        if( accsOld != null && accsOld.size() > 0 ){
            mapAccsOld.putAll(accsOld);
        }
        
        map<string,User> mapOwnerId = new map<string,User>();

     //   List <user> activeuser = [select id,Employee_ID__c,IsActive from user];
        for (user u: activeuser){
            mapOwnerId.put(u.employee_id__c, u);

        }              
        
        string retailSegment = AppConfig__c.getValues('FilterRetailSegment').Value__c; //'5|6|7|8|9'
        Set<String> filterRetailSegment = New Set<String>();
        filterRetailSegment.addAll(retailSegment.split('\\|'));
        





        for(Account acn : accsNew){
            string oldSegment = mapAccsOld.get(acn.Id).Segment_crm__c;            


            if(acn.Segment_crm__c != oldSegment){           
                System.debug(':: change owner retail to commercial (old Owner ID) ::' + mapAccsOld.get(acn.Id).OwnerId);                
                     
                for(string retail_sm:filterRetailSegment){ 
                                            
                    if(!string.isBlank(oldSegment) && (oldSegment==retail_sm) && !filterRetailSegment.contains(acn.Segment_crm__c)){    
                          
                       string newOwnerId = mapOwnerId.get(AppConfig__c.getValues('DefaultOwner').Value__c).Id;
                        if(mapOwnerId.get(acn.TMB_Employee_ID__c) != null) {
                            
                            Boolean ownerIsActive = mapOwnerId.get(acn.TMB_Employee_ID__c).IsActive;
                            string ownerId = mapOwnerId.get(acn.TMB_Employee_ID__c).Id; 
                            
                            if(!string.isBlank(ownerId) && ownerIsActive) {
                                newOwnerId = ownerId;                                
                            }

                        }                             
                        acn.OwnerId = newOwnerId;
                    }
                }   
            }
        }
        
        System.debug(':::: change owner retail to commercial end ::::');        
    }*/
    //this code is to refactor for INC0044781_CHANGE_ACCOUNT_OWNER_ONLY_SFADMRTL

    

    public static void changeOwnerRetailToCommercial(List<Account> accsNew,List<Account> accsOld){

        List<String> listIds = new List<String>();
        for(Account a : accsNew){
            listIds.add(a.TMB_Employee_ID__c);
        }

        String defaultOwner = AppConfig__c.getValues('DefaultOwner').Value__c;

        Map<Id,User> mapOwnerMap = new Map<Id, User>([select id
                                                        //,Name
                                                        ,Employee_ID__c
                                                        //,IsActive
                                                        ,Username
                                                        from User 
                                                        where IsActive = true and (Employee_ID__c IN: listIds or Employee_ID__c =: defaultOwner)]);
        
        System.debug(':::: change owner retail to commercial start ::::');
        
        List<Account> listReturn = new List<Account>();
        Map<Id,Account> mapAccsOld = new Map<Id,Account>();
        Set<Account> calculateSubSegmentset = new Set<Account>();

        if( accsOld != null && accsOld.size() > 0 ){
            mapAccsOld.putAll(accsOld);
        }
    
		
        //mapOwerId is Map for Active user between employee_id__c and user obj.
        Map<String,User> mapOwnerId = new Map<String,User>();

        for (Id uId: mapOwnerMap.keySet()){
            User u = mapOwnerMap.get(uId);
            mapOwnerId.put(u.employee_id__c, u);
        }      

        string defaultOwnerId = mapOwnerId.get(defaultOwner).Id;        
        
        string retailSegment = AppConfig__c.getValues('FilterRetailSegment').Value__c; //'5|6|7|8|9'
        Set<String> filterRetailSegment = New Set<String>();
        filterRetailSegment.addAll(retailSegment.split('\\|'));
        
        for(Account acn : accsNew){
            string oldSegment = mapAccsOld.get(acn.Id).Segment_crm__c;  
            string old_OwnerId = mapAccsOld.get(acn.Id).OwnerId;
            if(acn.Segment_crm__c != oldSegment){   //change account segment     
                System.debug(':: change owner retail to commercial (old Owner ID) ::' + mapAccsOld.get(acn.Id).OwnerId);    
                calculateSubSegmentset.add(acn);
                if(!string.isBlank(oldSegment) && (filterRetailSegment.contains(oldSegment)) 
                        && !filterRetailSegment.contains(acn.Segment_crm__c))
                { 
                        String newOwnerId = defaultOwnerId;

                        if(acn.TMB_Employee_ID__c != null && mapOwnerId.containsKey(acn.TMB_Employee_ID__c)) {
                            string ownerId = mapOwnerId.get(acn.TMB_Employee_ID__c).Id; 
                            newOwnerId = ownerId; 
                        }        


                        if (isEnableToChangeOwner(acn,mapOwnerMap)) acn.OwnerId = newOwnerId;
                }
            }
            
        }

        if(calculateSubSegmentset.size() > 0){
            reCalculateSubSegmentset(calculateSubSegmentset);
        }
        
        System.debug(':::: change owner retail to commercial end ::::');        
    }

    private static Boolean isEnableToChangeOwner(Account acn
                                                 ,Map<Id,User> ownerMap) {

        User user = ownerMap.get(acn.OwnerId);

        if (user != null && !user.Username.contains('sfadmrtl@tmbbank.com')) {
            //not change owner if existing account owner is active and is not contain 'sfadmrtl@tmbbank.com'
            return false;
        }
        //change owner when old owner contains sfadmrtl@tmbbank.com
        return true;
    }
    //this code is to refactor for INC0044781_CHANGE_ACCOUNT_OWNER_ONLY_SFADMRTL


    public static void handleAfterInsert(List<Account> accsNew){
        //if (bypassTrigger) return;

        // Auto Create Contact for existing , individual commercial account
        Map<ID,Account> commercialAccounts = new Map<ID,Account>();
        for( Account acct : accsNew )
        {
            if( acct.Account_Type__c == 'Existing Customer' && acct.Customer_Type__c == 'Individual' )
            {
                commercialAccounts.put(acct.id,acct);
            }
        }
        
        RTL_AccountUtility.createCommercialContactFromAccount(commercialAccounts);
    }

    public static void calculateSubSegment(Set<Account> acctSet){
        for(Account acct : acctSet){
            if(acct.RTL_RecordType_DevName__c == 'Existing_Customer'){
                String ownerZoneCode = AccountUtility.userMap.get(acct.OwnerId)?.Zone_Code__c;
                String prefixSubseg = acct.Change_to_be_segment__c == null ? acct.Segment_crm__c : acct.Change_to_be_segment__c == 'MB' ? '1' : acct.Change_to_be_segment__c == 'CB' ? '2' : acct.Change_to_be_segment__c == 'BB' ? '3' : acct.Change_to_be_segment__c == 'SE' ? '4' : acct.Segment_crm__c;
                if(mapsubSegmentMapping.containsKey(ownerZoneCode)){
                    acct.To_Be_Sub_Segment__c = prefixSubseg + mapsubSegmentMapping.get(ownerZoneCode).Sub_Segment_Code__c;
                }else{
                    acct.To_Be_Sub_Segment__c = prefixSubseg + '00';
                }
                acct.Last_Calculated_Sub_Segment__c = Datetime.now();
            }
        }
    }

    public static void reCalculateSubSegmentset(Set<Account> acctSet){
        for(Account acct : acctSet){
            if(acct.RTL_RecordType_DevName__c == 'Existing_Customer'){
                String ownerZoneCode = AccountUtility.userMap.get(acct.OwnerId)?.Zone_Code__c;
                String prefixSubseg = acct.Segment_crm__c;

                if(mapsubSegmentMapping.containsKey(ownerZoneCode)){
                    acct.Sub_segment__c = prefixSubseg + mapsubSegmentMapping.get(ownerZoneCode).Sub_Segment_Code__c;
                }else{
                    acct.Sub_segment__c = prefixSubseg + '00';
                }
            }
        }
    }
}