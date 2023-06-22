public class OpportunityTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    
    static String Stage_CaPrep = 'CA-Prep';
    static String Stage_ApprovalProcess = 'Approval Process';
    static String Stage_PostApproval = 'Post Approval';
    static String Stage_LimitSetup = 'Limit Setup';
    
    static boolean isSendMail = false;
    
    public static Map<String,Pricebook2> pricebookmap{get
    {
        if(pricebookmap ==null){
            pricebookmap= new Map<String,Pricebook2>();
            for(Pricebook2 R : [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC]){
                   pricebookmap.put(r.Name,r);
                }
        }
        return pricebookmap;
        
    }set;}
                
    public static User currentUser {get{
        if(currentUser==null){
            currentUser =[ select Id,Region__c,Zone__c,Segment__c from User where Id = :UserInfo.getUserId() ];
    
        }
        
        return currentUser;
        
    }set;}
    
    
    public static List<RecordType> recordTypeList {get{
        if(recordTypeList==null){
           recordTypeList = [ select Id,Name 
                                           from RecordType 
                                           where Name IN ('SE Credit Product','WBG Credit Product','SE Credit Product2','WBG Credit Product2'
                                                          ,'Non-credit Product','Non-credit Product2'
                                                          ,'SE Credit Product3')
                                          and SobjectType = 'Opportunity'];
        }
        
        return recordTypeList;
        
    }set;}  
    
    
    public static List<Opportunity_Stage_Mapping__c> OppstageList {get
    {
        if(OppstageList ==null){
           OppstageList = [SELECT Name,Application_status__c,Opportunity_Type__c,Stage__c,Host_System__c,Result__c
                                                   FROM Opportunity_Stage_Mapping__c];
        }
        return OppstageList;
    }
                                                                   set;}
    
    public static map<string,decimal> mapOpportunityStage {
    get
    {
        if(mapOpportunityStage == null){
            mapOpportunityStage = new map<string,decimal>();
            for (opportunityStage os : [select MasterLabel,defaultProbability from opportunityStage where IsActive = true])
            {
                mapOpportunityStage.put(os.MasterLabel, os.defaultProbability);
            }
        }
        return mapOpportunityStage;
    }
    set;}

    //CR E-Onboarding Dev:Mr.Tay
    public static Map<String, Opportunity_Stage_Mapping_Switch__mdt> OpportunityStageSwitchMap{
        get{
            if(OpportunityStageSwitchMap == null){
                OpportunityStageSwitchMap = new Map<String, Opportunity_Stage_Mapping_Switch__mdt>();

                for(Opportunity_Stage_Mapping_Switch__mdt optyMapSwitch : [SELECT Host_System__c, Use_Mapping__c FROM Opportunity_Stage_Mapping_Switch__mdt]){
                    String HostSys = optyMapSwitch.Host_System__c;
                    if(HostSys !=  null){
                        HostSys = HostSys.toLowerCase();
                    }

                    OpportunityStageSwitchMap.put(HostSys, optyMapSwitch);
                }
            }
            return OpportunityStageSwitchMap;
        }
        set;
    }
    
    public static void handleBeforeInsert(List<Opportunity> oppsNew){
        CAID.checkGenerateCAID(oppsNew,null,STR_INSERT);    
        conditionCreateOpportunity(oppsNew,null,STR_INSERT);
        
    }
    
    public static void handleBeforeUpdate(List<Opportunity> oppsNew,List<Opportunity> oppsOld){
        //CR E-Onboarding Dev:Mr.Tay
        List<Opportunity> oopsNewToMapStage = new List<Opportunity>();

        // Insert for support case close lost.
        for(Opportunity o : oppsNew){
            if(o.Host_System__c == null || !OpportunityStageSwitchMap.containsKey(o.Host_System__c.toLowerCase()) || OpportunityStageSwitchMap.get(o.Host_System__c.toLowerCase()).Use_Mapping__c){
                if(o.StageName == 'Closed Lost'){
                    o.Application_Status__c = null;
                }
                oopsNewToMapStage.add(o);
            }
        }
        // End
        stageMappingstageChange(oopsNewToMapStage,oppsOld,STR_UPDATE);
        List<Opportunity> listNew = checkConditionStageName(oppsNew,oppsOld,Stage_CaPrep);
        if( listNew.size() > 0 ){
            System.debug(':::: updateOpportunityData Start ::::');
            updateOpportunityData(listNew, oppsOld, STR_UPDATE,Stage_CaPrep);
            System.debug(':::: updateOpportunityData End ::::');  
        }
        /*
        listNew = checkConditionChangeOwner(oppsNew,oppsOld);
        if( listNew.size() > 0 ){
            changeOwnerOpportunity(listNew,oppsOld,STR_UPDATE);
        }*/
        listNew = checkConditionStageChange(oppsNew,oppsOld);
        if( listNew.size() > 0 ){
            stageChange(listNew,oppsOld,STR_UPDATE);
        }
        
    }

    public static void handleAfterInsert(List<Opportunity> oppsNew){
      insertOpportunityTeam(oppsNew);
    }
    
    public static void handleAfterUpdate(List<Opportunity> oppsNew,List<Opportunity> oppsOld){
    
        Trigger_T07(oppsNew,oppsOld,STR_UPDATE);
        Trigger_T08(oppsNew,oppsOld,STR_UPDATE);
        Trigger_T09(oppsNew,oppsOld,STR_UPDATE);
        Trigger_T10(oppsNew,oppsOld,STR_UPDATE);

        updateOpportunityCampaign(oppsNew,oppsOld);
        updateCampaignCloseWon(oppsNew,oppsOld);
      
        IsStageOrStatusChangedAfterSubmit(oppsNew,oppsOld);
    }

    public static void handleAfterUpdate(Map<Id,Opportunity> oldMap , Map<Id,Opportunity> newMap){
      addOpportunityTeam(oldMap,newMap);
    }
    
    /*
    public static List<Opportunity> checkConditionChangeOwner(List<Opportunity> oppsNew,List<Opportunity> oppsOld){
        List<Opportunity> listReturn = new List<Opportunity>();
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        if( oppsOld != null && oppsOld.size() > 0 ){
            mapOppsOld.putAll(oppsOld);
        }
        for(Opportunity opp : oppsNew){
            if( opp.OwnerId != mapOppsOld.get(opp.Id).OwnerId ){//&& opp.Trigger_Flag__c                
                listReturn.add(opp);
            }else{
                //opp.Trigger_Flag__c = false;
            }
        }
        return listReturn;
    }*/
    
     public static List<Opportunity> checkConditionStageChange(List<Opportunity> oppsNew,List<Opportunity> oppsOld){
        List<Opportunity> listReturn = new List<Opportunity>();
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        if( oppsOld != null && oppsOld.size() > 0 ){
            mapOppsOld.putAll(oppsOld);
        }
        for(Opportunity opp : oppsNew){
            if( opp.StageName != mapOppsOld.get(opp.Id).StageName ){               
                listReturn.add(opp);
            }
        }
        return listReturn;
    }
    
    public static List<Opportunity> checkConditionStageName(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String StageName){
        List<Opportunity> listReturn = new List<Opportunity>();
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        if( oppsOld != null && oppsOld.size() > 0 ){
            mapOppsOld.putAll(oppsOld);
        }
        
        for(Opportunity opp : oppsNew){
            Boolean checkCondition = false;
            if( mapOppsOld.get(opp.Id).StageName != opp.StageName 
               && opp.StageName == StageName && StageName != Stage_LimitSetup ){
                   checkCondition = true;
            }else if( StageName == Stage_LimitSetup  
                        && mapOppsOld.get(opp.Id).StageName != opp.StageName 
                        && opp.StageName == StageName 
                        && mapOppsOld.get(opp.Id).StageName == Stage_PostApproval){
                            checkCondition = true;
            }           
            
            if(checkCondition){
                listReturn.add(opp);
            }
        }
        return listReturn;
    }
    
    public static void Trigger_T07(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        List<Opportunity> listNew = checkConditionStageName(oppsNew,oppsOld,Stage_CaPrep);
        if( listNew.size() > 0 ){
            System.debug(':::: Trigger_T07 Start ::::');
            //System.debug('mix old : '+oppsOld);
            //System.debug('mix new : '+oppsNew);
            updateTargetByOppStatus(listNew, oppsOld, eventMode,Stage_CaPrep);
            System.debug(':::: Trigger_T07 End ::::');  
        }
    }
    
    public static void Trigger_T08(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        List<Opportunity> listNew = checkConditionStageName(oppsNew,oppsOld,Stage_ApprovalProcess);
        if( listNew.size() > 0 ){
            System.debug(':::: Trigger_T08 Start ::::');
            updateTargetByOppStatus(listNew, oppsOld, eventMode,Stage_ApprovalProcess);
            System.debug(':::: Trigger_T08 End ::::');  
        }
    }
    
    public static void Trigger_T09(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        List<Opportunity> listNew = checkConditionStageName(oppsNew,oppsOld,Stage_PostApproval);
        if( listNew.size() > 0 ){
            System.debug(':::: Trigger_T09 Start ::::');
            updateTargetByOppStatus(listNew, oppsOld, eventMode,Stage_PostApproval);
            System.debug(':::: Trigger_T09 End ::::');  
        }
    }
    
    public static void Trigger_T10(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        List<Opportunity> listNew = checkConditionStageName(oppsNew,oppsOld,Stage_LimitSetup);
        if( listNew.size() > 0 ){
            System.debug(':::: Trigger_T10 Start ::::');
            updateTargetByOppStatus(listNew, oppsOld, eventMode,Stage_LimitSetup);
            System.debug(':::: Trigger_T10 End ::::');  
        }
    }
    
    public static void updateTargetByOppStatus(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode,String stageName){
        Map<Id,Opportunity> listOppsOld = new Map<Id,Opportunity>();
        if(eventMode == STR_UPDATE){
            listOppsOld.putAll(oppsOld);
        }
        
        List<Id> ids = new List<Id>();
        List<Id> listOwnerId = new List<Id>();
        Map<Id,Target__c> mapTargetForUpdate = new Map<Id,Target__c>();
        List<RecordType> listRecordType = [select Id from RecordType where name = 'Activities Target'];
        // '012N0000000D5FHIA0'; // id for Activities Target
        Id recordTypeId = listRecordType[0].Id; 
        String strMonthlyActual = '';
        String strMonthlyAmount = '';
        List<String> listZone = new List<String>();
        List<Integer> listMonth = new List<Integer>();
        List<Integer> listYear = new List<Integer>();
        
        for(Opportunity opp : oppsNew){
            if( listOppsOld.get(opp.Id).StageName != opp.StageName 
               && opp.StageName == StageName){
                   if(opp.Id != null){
                       ids.add(opp.Id);
                   }
                   if(opp.OwnerId != null){
                       listOwnerId.add(opp.OwnerId);    
                   }
                   
                   if( stageName == Stage_CaPrep ){
                       strMonthlyActual = 'Monthly_Close_Sales_Actual__c';
                       strMonthlyAmount = 'Monthly_Close_Sales_Amount__c';
                       if( opp.CA_Prep_Start_Date__c != null ){
                           listMonth.add( Integer.valueOf(String.valueOf(opp.CA_Prep_Start_Date__c).substring(5,7)) );
                           listYear.add( Integer.valueOf(String.valueOf(opp.CA_Prep_Start_Date__c).substring(0,4)) );
                       }
                   }else if( stageName == Stage_ApprovalProcess ){           
                       strMonthlyActual = 'Monthly_App_In_Actual__c';
                       strMonthlyAmount = 'Monthly_App_In_Amount__c';
                       if( opp.Approval_Process_Date__c != null ){
                           listMonth.add( Integer.valueOf(String.valueOf(opp.Approval_Process_Date__c).substring(5,7)) );
                           listYear.add( Integer.valueOf(String.valueOf(opp.Approval_Process_Date__c).substring(0,4)) );
                       }
                   }else if( stageName == Stage_PostApproval ){           
                       strMonthlyActual = 'Monthly_Approved_Actual__c';
                       strMonthlyAmount = 'Monthly_Approved_Amount__c';
                       if( opp.Post_Approval_Date__c != null ){
                           listMonth.add( Integer.valueOf(String.valueOf(opp.Post_Approval_Date__c).substring(5,7)) );
                           listYear.add( Integer.valueOf(String.valueOf(opp.Post_Approval_Date__c).substring(0,4)) );
                       }
                   }else if( stageName == Stage_LimitSetup ){           
                       strMonthlyActual = 'Monthly_Set_Up_Actual__c';
                       strMonthlyAmount = 'Monthly_Set_Up_Amount__c';
                       if( opp.Complete_Date__c != null ){
                           listMonth.add( Integer.valueOf(String.valueOf(opp.Complete_Date__c).substring(5,7)) );
                           listYear.add( Integer.valueOf(String.valueOf(opp.Complete_Date__c).substring(0,4)) );
                       }
                   }
                   
               }    
        }
        
        Map<Id,User> listUser = new Map<Id,User>([select Id,Name,Zone__c  from User where Id IN :listOwnerId]);
        for(user u : listUser.values() ){
            if(u.Zone__c != null){
                listZone.add(u.Zone__c);    
            }
        }
        
        Map<Id,AggregateResult> listOppHis = new Map<Id,AggregateResult>([select count(id) countOpp,OpportunityId Id
                                                                          from OpportunityHistory 
                                                                          where OpportunityId IN :ids 
                                                                          and StageName = :stageName
                                                                          group by OpportunityId]);
        System.debug('::>'+listOppHis);
        //list for get record target
        List<Target__c> listTarget = new List<Target__c>();
        
        String queryTarget = 'select Zone__c,OwnerId,'+strMonthlyActual+','+strMonthlyAmount +' '+
            'from Target__c where CALENDAR_MONTH(Monthly_Target_date__c) IN :listMonth '+
            'and CALENDAR_YEAR(Monthly_Target_date__c) IN :listYear and OwnerId IN :listOwnerId '+
            'and Zone__c IN :listZone '+
            'and RecordTypeId = :recordTypeId';
        
        //System.debug(queryTarget);
        
        listTarget = Database.query(queryTarget);
        
        Map<String,Target__c> mapTarget = new Map<String,Target__c>();
        for( Target__c t : listTarget ){
            mapTarget.put(t.OwnerId,t);
        }
        System.debug('listtarget : '+listTarget);
        
        for(Opportunity opp : oppsNew){
          //System.debug('Opp : ' + opp);    
            Boolean checkCondition = false;
            if( listOppsOld.get(opp.Id).StageName != opp.StageName 
               && opp.StageName == StageName && StageName != Stage_LimitSetup ){
                   checkCondition = true;
            }else if( StageName == Stage_LimitSetup  
                        && listOppsOld.get(opp.Id).StageName != opp.StageName 
                        && opp.StageName == StageName 
                        && listOppsOld.get(opp.Id).StageName == Stage_PostApproval){
                            checkCondition = true;
            }
            if( checkCondition ){
                   Integer countOpp = 0;
                   if( listOppHis.containsKey(opp.Id) ){
                       countOpp = (Integer)listOppHis.get(opp.Id).get('countOpp');
                   }else{
                       System.debug('::::: OwnerId : '+opp.OwnerId+' error containsKey in OppHistory');
                   }
                   
                   System.debug('::::: countOpp size is : '+countOpp +' :::::');
                   if( countOpp == 1 ){
                       if( mapTarget.containsKey(opp.OwnerId) && !mapTargetForUpdate.containsKey(opp.OwnerId) ){
                           Decimal AppAmount = (opp.Approved_Amount__c == null) ? 0 : opp.Approved_Amount__c;
                           Decimal MonActual = (mapTarget.get(opp.OwnerId).get(strMonthlyActual) == null) ? 
                               0 : (Decimal)mapTarget.get(opp.OwnerId).get(strMonthlyActual);
                           Decimal MonAmount = (mapTarget.get(opp.OwnerId).get(strMonthlyAmount) == null) ?
                               0 : (Decimal)mapTarget.get(opp.OwnerId).get(strMonthlyAmount);
                           
                           MonActual += 1;
                           MonAmount += AppAmount;
                           
                           if( stageName == Stage_CaPrep ){
                               mapTarget.get(opp.OwnerId).Monthly_Close_Sales_Actual__c = MonActual;
                               mapTarget.get(opp.OwnerId).Monthly_Close_Sales_Amount__c = MonAmount;
                           }else if( stageName == Stage_ApprovalProcess ){           
                               mapTarget.get(opp.OwnerId).Monthly_App_In_Actual__c = MonActual;
                               mapTarget.get(opp.OwnerId).Monthly_App_In_Amount__c = MonAmount;
                           }else if( stageName == Stage_PostApproval ){           
                               mapTarget.get(opp.OwnerId).Monthly_Approved_Actual__c = MonActual;
                               mapTarget.get(opp.OwnerId).Monthly_Approved_Amount__c = MonAmount;
                           }else if( stageName == Stage_LimitSetup ){           
                               mapTarget.get(opp.OwnerId).Monthly_Set_Up_Actual__c = MonActual;
                               mapTarget.get(opp.OwnerId).Monthly_Set_Up_Amount__c = MonAmount;
                           }

                           mapTargetForUpdate.put( opp.OwnerId,mapTarget.get(opp.OwnerId) ); 
                           System.debug('::::: OwnerId : '+opp.OwnerId+' '+strMonthlyActual+' : '+ mapTarget.get(opp.OwnerId).get(strMonthlyActual)+' :::::');
                           System.debug('::::: OwnerId : '+opp.OwnerId+' '+strMonthlyAmount+' : '+ mapTarget.get(opp.OwnerId).get(strMonthlyAmount)+' :::::');
                       }else{
                           System.debug('::::: OwnerId : '+opp.OwnerId+' error containsKey in Target Or mapTargetForUpdate is Duplicated');
                       }
                       
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
    }
    
    public static void conditionCreateOpportunity(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        System.debug(':::: conditionCreateOpportunity Start ::::');
        
        Set<Id> idAccountList = new Set<Id>();
        Set<Id> idUserList = new Set<Id>();        
        
        for( Opportunity eachOpp : oppsNew ){
            System.debug('Pricebook2 : '+eachopp.Pricebook2Id);
            if( eachOpp.AccountId != null ){
                idAccountList.add(eachOpp.AccountId);
            }
            
            idUserList.add(eachOpp.OwnerId);
        }
        
        Map<Id,Account> queryAccount = new Map<Id,Account>([ select Id,OwnerId,Owner.Segment__c
                                                            from Account 
                                                            where Id IN :idAccountList ]);
        
        List<AccountTeamMember> queryAccountTeamMember = [ select accountId,userId
                                                                                      from AccountTeamMember 
                                                                                      where accountId IN :idAccountList 
                                                                                      and userId IN :idUserList];
        
        Map<Id,User> queryUser = new Map<Id,User>([select Id,UserRole.Name,Segment__c from user where Id IN :idUserList]);
        
        Pricebook2 standardPricebook = new Pricebook2(); 
        if( Test.isRunningTest() ){
            standardPricebook.Id = Test.getStandardPricebookId();
        }else{
            try{
          
               
          //User us = [SELECT ID,Segment__c FROM User 
           //                                        WHERE ID=:UserInfo.getUserId() LIMIT 1];
     // System.debug('user : '+us);
          
                if(currentUser.Segment__c != null && Price_book_access__c.GetValues(currentUser.Segment__c) != null){
                    //standardPricebook.id = pricebookmap.get('SE Price Book').id;
                    standardPricebook.id = pricebookmap.get(Price_book_access__c.GetValues(currentUser.Segment__c).PricebookItem__c).id;
                }else if(currentUser.Segment__c != null && Price_book_access__c.GetValues(currentUser.Segment__c) == null){
                    oppsNew.get(0).addError(status_code__c.getValues('8017').status_message__c);               
                }else{ 
                    standardPricebook.id = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
                }
                
               
              System.debug('Picked : '+standardPricebook);
                
            }catch(QueryException e){
                System.debug('error select std pricebook : '+e);
            }               
        }
        

    for( Opportunity eachOpp : oppsNew ){
            Boolean checkCreate = false;           
            if( eachOpp.Pricebook2Id == null ){
                eachOpp.Pricebook2Id = standardPricebook.Id;
            }
            System.debug('standardPricebook : '+standardPricebook);
            System.debug('eachOpp.Pricebook2Id : '+eachOpp.Pricebook2Id);
            System.debug('eachOpp : '+eachOpp);
            if( queryAccount.containsKey(eachOpp.AccountId) ){                
                if( queryAccount.get(eachOpp.AccountId).OwnerId == eachOpp.OwnerId ){
                    checkCreate = true;
                }
                
                if(!checkCreate){
                    for(AccountTeamMember eachAccTeam : queryAccountTeamMember ){
                        if( eachOpp.AccountId == eachAccTeam.AccountId && eachOpp.OwnerId ==  eachAccTeam.UserId ){
                            checkCreate = true;
                            break;
                        }
                    }  
                }
            }
            
            if(!checkCreate){
                
                List<Account__c> privilegeList = Account__c.getall().values();
                
                for( Account__c eachPrivilege : privilegeList ){
                    if( queryUser.containsKey(eachOpp.OwnerId) && queryAccount.containsKey(eachOpp.AccountId)){
                        if(queryUser.get(eachOpp.OwnerId).UserRole.Name == eachPrivilege.Role__c 
                          && queryAccount.get(eachOpp.AccountId).Owner.Segment__c == eachPrivilege.Segment__c){
                            checkCreate = true;
                        } 
                    }                    
                }
                
                /*if( queryUser.get(eachOpp.OwnerId).UserRole.Name == Account__c.getValues('Privilege_RMC').Role__c &&
                  queryAccount.get(eachOpp.AccountId).Owner.Segment__c == Account__c.getValues('Privilege_RMC').Segment__c ){
                    checkCreate = true;
                } */               
            }
            
            if(!checkCreate){
                eachOpp.addError( Trigger_Msg__c.getValues('Permission_Create_Opportunity').Description__c  ,false);    
            }
            System.debug('::::: checkCreate : '+checkCreate+' || '+eachOpp.Name+' :::::');
        }        
        
        
        System.debug(':::: conditionCreateOpportunity End ::::');
    }
    
    public static void updateOpportunityData(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode,String stageName){
        //User queryUser = [ select Id,Region__c,Zone__c,Segment__c from User where Id = :UserInfo.getUserId() ];
        
        
        Id recordIdSECreditProduct;
        Id recordIdWBGCreditProduct;
        Id recordIdSECreditProduct2;
        Id recordIdWBGCreditProduct2;
        
        for( RecordType eachRecordType : recordTypeList ){
            if( eachRecordType.Name == 'SE Credit Product' ){
                recordIdSECreditProduct = eachRecordType.Id;
            }else if( eachRecordType.Name == 'WBG Credit Product' ){
                recordIdWBGCreditProduct = eachRecordType.Id;
            }else if( eachRecordType.Name == 'SE Credit Product2' ){
                recordIdSECreditProduct2 = eachRecordType.Id;
            }else if( eachRecordType.Name == 'WBG Credit Product2' ){
                recordIdWBGCreditProduct2 = eachRecordType.Id;
            }
        }
        
        for(Opportunity eachOpp : oppsNew ){
            if( eachOpp.StageName == Stage_CaPrep ){
                eachOpp.Check_CA_Prep__c = false;
                eachOpp.Submitted_Region__c = currentUser.Region__c ;
                eachOpp.Submitted_Segment__c = currentUser.Zone__c;
                eachOpp.Submitted_Zone__c = currentUser.Segment__c;
                if( eachOpp.RecordTypeId == recordIdSECreditProduct ){
                    eachOpp.RecordTypeId = recordIdSECreditProduct2;
                }else if( eachOpp.RecordTypeId == recordIdWBGCreditProduct ){
                    eachOpp.RecordTypeId = recordIdWBGCreditProduct2;
                }
            }
        }
        System.debug('updateOpportunityData : '+oppsNew);        
    }
    /*
    public static void changeOwnerOpportunity(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        System.debug('::::: changeOwnerOpportunity Start :::::');
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        if( oppsOld.size() > 0 && oppsOld != null ){
            mapOppsOld.putAll(oppsOld);
        }
        for( Opportunity eachOpp : oppsNew ){
            if( eachOpp.StageName == 'Open' ){
                //eachOpp.PrevOwnerId__c = eachOpp.OwnerId;
            }else{
                //eachOpp.OwnerId = eachOpp.PrevOwnerId__c;
            }
            //eachOpp.OwnerId = mapOppsOld.get(eachOpp.Id).OwnerId;
            //eachOpp.Trigger_flag__c = false;
        }
        System.debug(':::: Opportunity Reverse Owner size of '+oppsNew.size()+' row ::::');
        System.debug('::::: changeOwnerOpportunity End :::::');
    }   */
    
    public static void stageChange(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        System.debug('::::: stageChange Start :::::');
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        if( oppsOld.size() > 0 && oppsOld != null ){
            mapOppsOld.putAll(oppsOld);
        }
        for( Opportunity eachOpp : oppsNew ){
            eachOpp.PrevOwnerId__c = eachOpp.OwnerId;
        }
        System.debug('::::: stageChange End :::::');
    }
    
    public static void stageMappingstageChange(List<Opportunity> oppsNew,List<Opportunity> oppsOld,String eventMode){
        Map<String,String> CreditMapping = new Map<String,String>();
        Map<String,String> NonCreditMapping = new Map<String,String>();
        Map<String,String> SLSMapping = new Map<String,String>();
        List<opportunity> listOppStageMappingNotFound = new List<opportunity>();
        
        for(Opportunity_Stage_Mapping__c  oppmap : OppstageList){

        
           String LowerApplicationStatus = (oppmap.Application_status__c!=null) ? oppmap.Application_status__c : '';
           if (string.isNotBlank(oppmap.Host_System__c)){
               LowerApplicationStatus += oppmap.Host_System__c;
           }
           if (string.isNotBlank(oppmap.Result__c)){
               LowerApplicationStatus += oppmap.Result__c;
           }
          
           if(oppmap.Opportunity_Type__c =='Credit'){
               CreditMapping.put(LowerApplicationStatus.toLowerCase(),oppmap.Stage__c );
           }else if(oppmap.Opportunity_Type__c =='Non-Credit'){
               NonCreditMapping.put(LowerApplicationStatus.toLowerCase(),oppmap.Stage__c );
           }   
           
           string stageSLS = '';
           string stageSLSName = (oppmap.Stage__c != null) ? oppmap.Stage__c : '';
           stageSLS += (oppmap.Host_System__c != null) ? oppmap.Host_System__c : '';
           stageSLS += (oppmap.Application_status__c != null) ? oppmap.Application_status__c : '';
           stageSLS += (oppmap.Result__c != null) ? oppmap.Result__c : '';
           if (stageSLS != '' && stageSLSName != ''){
               SLSMapping.put(stageSLS,stageSLSName);
           }
                     
        }
        Map<ID,Opportunity> oldOppMap = new Map<ID,Opportunity>();
        
        for(Opportunity eachOldOpp : oppsOld){
             
            oldOppMap.put(eachOldOpp.id,eachOldOpp); 
        }
        
        map<string,string> mapRecordType = new map<string,string>();
        map<string,string> mapNameRecordType = new map<string,string>();
        for (recordtype r : recordTypeList)
        {
            mapRecordType.put(r.id,r.name);
            mapNameRecordType.put(r.name,r.id);
        }
        //system.debug(oppsOld);
        //System.debug(oppsNew);

        for( Opportunity eachOpp : oppsNew )
        {
            //System.debug('EachOPP : '+eachOpp);
            //System.debug('eachOpp.recordtypeid'+eachOpp.recordtypeid);
            //System.debug('oldOppMap.get(eachOpp.id).recordtypeid :'+oldOppMap.get(eachOpp.id).recordtypeid);   

            if (eachOpp.recordtypeid == oldOppMap.get(eachOpp.id).recordtypeid)
            {
        
               if(mapRecordType.get(eachOpp.recordtypeid) == 'SE Credit Product2' ||
                  mapRecordType.get(eachOpp.recordtypeid) == 'WBG Credit Product2' ||
                  mapRecordType.get(eachOpp.recordtypeid) == 'Non-credit Product2' )
               {
                  
                    //System.debug('AppStatus : '+eachOpp.Application_Status__c != oldOppMap.get(eachOpp.id).Application_Status__c);
                    //System.debug('Opportunity_Type_Formula__c: '+eachOpp.Opportunity_Type_Formula__c);
                    //System.debug('Application_Status__c : '+eachOpp.Application_Status__c);
                  
                    //**** old logic -> exclude SLS to host app trigger ****//
                    //if(eachOpp.Application_Status__c != oldOppMap.get(eachOpp.id).Application_Status__c && eachOpp.Host_System__c != 'SLS')
                    //**** old logic -> exclude SLS to host app trigger ****//
                    if((eachOpp.Application_Status__c != oldOppMap.get(eachOpp.id).Application_Status__c && eachOpp.Host_System__c != 'SLS')
                    || (((eachOpp.Application_Status__c != oldOppMap.get(eachOpp.id).Application_Status__c)
                        || (eachOpp.Host_Result__c != oldOppMap.get(eachOpp.id).Host_Result__c))
                        && eachOpp.Host_System__c == 'SLS'))
                    {
                    //Start Mapping
                    //
                        //**** old logic -> exclude SLS to host app trigger ****//
                        //if(eachOpp.Application_Status__c !=null && eachOpp.Application_Status__c !=''){
                        //**** old logic -> exclude SLS to host app trigger ****//
                        if((eachOpp.Application_Status__c !=null && eachOpp.Application_Status__c !='' && eachOpp.Host_System__c != 'SLS')
                        || eachOpp.Host_System__c == 'SLS')
                        {
                            String LowerApplicationStatus = (eachOpp.Application_status__c!=null) ? eachOpp.Application_status__c.toLowerCase() : '';
                            if(string.isNotBlank(eachOpp.Host_System__c)){
                                LowerApplicationStatus += eachOpp.Host_System__c.toLowerCase();
                            }
                            if(string.isNotBlank(eachOpp.Host_Result__c)){
                                LowerApplicationStatus += eachOpp.Host_Result__c.toLowerCase();
                            }
                           
                            if(eachOpp.Opportunity_Type_Formula__c =='Credit' && CreditMapping.containsKey(LowerApplicationStatus)){
                                eachOpp.StageName = CreditMapping.get(LowerApplicationStatus);
                            }else if(eachOpp.Opportunity_Type_Formula__c =='Non-credit' && NonCreditMapping.containsKey(LowerApplicationStatus)){
                                eachOpp.StageName = NonCreditMapping.get(LowerApplicationStatus);
                            }else{
                                if (eachOpp.Host_System__c == 'SLS'){
                                    listOppStageMappingNotFound.add(eachOpp);  
                                } else {
                                    eachOpp.addError('This application status does not match in the system. Please select another value.');
                                }
                            }
                            
                        
                        }else{
                            //system.debug('Hello world');
                            //system.debug(eachOpp.stagename);
                            if (eachOpp.stagename != 'Closed Lost') {
                                eachOpp.addError('Application status cannot be null.');
                            }
                        }
                    //
                    //Stop Mapping
                      
                    }
                
                }else if(eachOpp.Host_System__c == 'SLS' && eachOpp.Probability != 100){
                    string oppStageInput = '';
                    oppStageInput += (eachOpp.Host_System__c != null) ? eachOpp.Host_System__c : '';
                    oppStageInput += (eachOpp.Application_Status__c != null) ? eachOpp.Application_Status__c : '';
                    oppStageInput += (eachOpp.Host_Result__c != null) ? eachOpp.Host_Result__c : '';
                    string stageResult = SLSMapping.get(oppStageInput);
                    
                    if (stageResult != null && stageResult != ''){
                        eachOpp.stageName = stageResult;
                        if (mapOpportunityStage.get(stageResult) != null){
                            if (mapOpportunityStage.get(stageResult) >= 95){
                                eachOpp.recordTypeid = mapNameRecordType.get('SE Credit Product3');
                            }else if (mapOpportunityStage.get(stageResult) < 95){
                                eachOpp.recordTypeid = mapNameRecordType.get('SE Credit Product2');
                            }
                            eachOpp.Reason_of_Lost__c = '';
                        }
                    }
                
                /* For next BAU after 2017-06-13 (Can Backward from CloseWon by using Workbench) ******
                }else if(eachOpp.Host_System__c == 'SLS'){
                
                    if (eachOpp.Probability == 100 && oldOppMap.get(eachOpp.id).Probability < 100){
                    
                    }else{
                    
                        if (   (eachOpp.Host_System__c != oldOppMap.get(eachOpp.id).Host_System__c)
                            || (eachOpp.Application_Status__c != oldOppMap.get(eachOpp.id).Application_Status__c)
                            || (eachOpp.Host_Result__c != oldOppMap.get(eachOpp.id).Host_Result__c)){
                        
                            string oppStageInput = '';
                            oppStageInput += (eachOpp.Host_System__c != null) ? eachOpp.Host_System__c : '';
                            oppStageInput += (eachOpp.Application_Status__c != null) ? eachOpp.Application_Status__c : '';
                            oppStageInput += (eachOpp.Host_Result__c != null) ? eachOpp.Host_Result__c : '';
                            string stageResult = SLSMapping.get(oppStageInput);
                            
                            if (stageResult != null && stageResult != ''){
                                eachOpp.stageName = stageResult;
                                if (mapOpportunityStage.get(stageResult) != null){
                                    if (mapOpportunityStage.get(stageResult) >= 95){
                                        eachOpp.recordTypeid = mapNameRecordType.get('SE Credit Product3');
                                    }else if (mapOpportunityStage.get(stageResult) < 95){
                                        eachOpp.recordTypeid = mapNameRecordType.get('SE Credit Product2');
                                    }
                                    eachOpp.Reason_of_Lost__c = '';
                                }
                            }
                            
                        }
                        
                    }
                */
                        
                }else{
                    //eachOpp.addError('Cannot update application status unless you have submitted');
                }
                
            }

            if (eachOpp.IsClosed) eachOpp.Complete_Date__c = Date.today();
            
        }
        
        if (listOppStageMappingNotFound.size() > 0){
            //system.debug(listOppStageMappingNotFound);
            SLOSEmailService.emailOppStageMappingNotFound(listOppStageMappingNotFound);
        }
        
        
    }

    public static void updateCampaignRevenue(List<Opportunity> ListOpportunity)
    {
        system.debug('opportunity trigger : updateCampaignRevenue start');

        Set<String> ListOppID = new Set<String>();
        for (Opportunity o : ListOpportunity)
        {
            ListOppID.add(o.ID);
        }

        if (ListOppID.size() > 0) {

            Set<String> ListCampaignID = new Set<String>();
            Set<String> ListParentCampaignID = new Set<String>();
            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Map<Id,Campaign> mapParentCampaign = new Map<Id,Campaign>();
            
            for (Opportunity o : [select ID, CampaignID
                                  , Campaign.FullDealExpectedRevenueOpportunities__c
                                  , Campaign.HierarchyFullDealExpectedRevenueOpty__c
                                  , Lead_Expect_Revenue__c
                                  from Opportunity where ID in: ListOppID])
            {

                if (string.isNotBlank(o.CampaignID)) ListCampaignID.add(o.CampaignID);

                if (mapCampaign.get(o.CampaignID) == null) {
                    Campaign campObj = new Campaign();
                    campObj.ID = o.CampaignID;
                    campObj.FullDealExpectedRevenueOpportunities__c = ((o.Campaign.FullDealExpectedRevenueOpportunities__c != null) ? o.Campaign.FullDealExpectedRevenueOpportunities__c : 0.00) + ((o.Lead_Expect_Revenue__c != null) ? o.Lead_Expect_Revenue__c : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((o.Campaign.HierarchyFullDealExpectedRevenueOpty__c != null) ? o.Campaign.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + ((o.Lead_Expect_Revenue__c != null) ? o.Lead_Expect_Revenue__c : 0.00);

                    mapCampaign.put(o.CampaignID, campObj);
                } else {
                    Campaign campObj = mapCampaign.get(o.CampaignID);
                    campObj.FullDealExpectedRevenueOpportunities__c = ((campObj.FullDealExpectedRevenueOpportunities__c != null) ? campObj.FullDealExpectedRevenueOpportunities__c : 0.00) + ((o.Lead_Expect_Revenue__c != null) ? o.Lead_Expect_Revenue__c : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((campObj.HierarchyFullDealExpectedRevenueOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + ((o.Lead_Expect_Revenue__c != null) ? o.Lead_Expect_Revenue__c : 0.00);

                    mapCampaign.put(o.CampaignID, campObj);
                }

            }

            List<Campaign> listUpdateCampaign = new List<Campaign>();

            for (String cid : ListCampaignID)
            {
                if (mapCampaign.get(cid) != null) {
                    listUpdateCampaign.add(mapCampaign.get(cid));
                }
            }

            try {
                if (listUpdateCampaign.size() > 0)
                    update listUpdateCampaign;
            } catch (exception ex) {
                system.debug('opportunity trigger Error Line '+ ex.getLinenumber() +' : '+ ex.getMessage());
            }

        }

        system.debug('opportunity trigger : updateCampaignRevenue end');

    }

    public static void updateOpportunityCampaign(List<Opportunity> ListNewOpty, List<Opportunity> ListOldOpty)
    {
        system.debug('opportunity trigger : updateOpportunityCampaign start');

        Map<Id,Opportunity> mapOld = new Map<Id,Opportunity>();
        mapOld.putAll(ListOldOpty);
        Set<String> ListNewCampgignID = new Set<String>();
        Set<String> ListOldCampaignID = new Set<String>();
        Map<Id,Decimal> mapFullYear = new Map<Id,Decimal>();
        Map<Id,Decimal> mapThisYear = new Map<Id,Decimal>();

        Boolean IsChangeVal = false;

        if (ListNewOpty.size () == 0) {
            IsChangeVal = true;
        } else {
            for (Opportunity o : ListNewOpty)
            {
                if (o.Expected_Revenue_Input__c != mapOld.get(o.ID).Expected_Revenue_Input__c
                 || o.This_Year_Expected_Revenue__c != mapOld.get(o.ID).This_Year_Expected_Revenue__c
                 || o.CampaignID != mapOld.get(o.ID).CampaignID)
                    IsChangeVal = true;
            }
        }

        if (IsChangeVal) {

            if (ListNewOpty.size() == 0) {

                for (Opportunity o : ListOldOpty)
                {
                    if (mapOld.get(o.ID).CampaignID != null) {
                        ListOldCampaignID.add(mapOld.get(o.ID).CampaignID);
                        if (mapFullYear.get(mapOld.get(o.ID).CampaignID) == null) {
                            decimal total = ((mapOld.get(o.ID).Expected_Revenue_Input__c != null) ? mapOld.get(o.ID).Expected_Revenue_Input__c : 0.00);
                            mapFullYear.put(mapOld.get(o.ID).CampaignID, total);
                        } else {
                            decimal total = mapFullYear.get(mapOld.get(o.ID).CampaignID) + ((mapOld.get(o.ID).Expected_Revenue_Input__c != null) ? mapOld.get(o.ID).Expected_Revenue_Input__c : 0.00);
                            mapFullYear.put(mapOld.get(o.ID).CampaignID, total);
                        }

                        if (mapThisYear.get(mapOld.get(o.ID).CampaignID) == null) {
                            decimal total = ((mapOld.get(o.ID).This_Year_Expected_Revenue__c != null) ? mapOld.get(o.ID).This_Year_Expected_Revenue__c : 0.00);
                            mapThisYear.put(mapOld.get(o.ID).CampaignID, total);
                        } else {
                            decimal total = mapThisYear.get(mapOld.get(o.ID).CampaignID) + ((mapOld.get(o.ID).This_Year_Expected_Revenue__c != null) ? mapOld.get(o.ID).This_Year_Expected_Revenue__c : 0.00);
                            mapThisYear.put(mapOld.get(o.ID).CampaignID, total);
                        }
                    }
                }

            } else {

                for (Opportunity o : ListNewOpty)
                {
                    if (o.CampaignID != mapOld.get(o.ID).CampaignID) {
                        if (mapOld.get(o.ID).CampaignID != null) ListOldCampaignID.add(mapOld.get(o.ID).CampaignID);
                        if (o.CampaignID != null) ListNewCampgignID.add(o.CampaignID);

                        if (mapOld.get(o.ID).CampaignID != null) {
                            if (mapFullYear.get(mapOld.get(o.ID).CampaignID) == null) {
                                decimal total = ((mapOld.get(o.ID).Expected_Revenue_Input__c != null) ? mapOld.get(o.ID).Expected_Revenue_Input__c : 0.00);
                                mapFullYear.put(mapOld.get(o.ID).CampaignID, total);
                            } else {
                                decimal total = mapFullYear.get(mapOld.get(o.ID).CampaignID) + ((mapOld.get(o.ID).Expected_Revenue_Input__c != null) ? mapOld.get(o.ID).Expected_Revenue_Input__c : 0.00);
                                mapFullYear.put(mapOld.get(o.ID).CampaignID, total);
                            }

                            if (mapThisYear.get(mapOld.get(o.ID).CampaignID) == null) {
                                decimal total = ((mapOld.get(o.ID).This_Year_Expected_Revenue__c != null) ? mapOld.get(o.ID).This_Year_Expected_Revenue__c : 0.00);
                                mapThisYear.put(mapOld.get(o.ID).CampaignID, total);
                            } else {
                                decimal total = mapThisYear.get(mapOld.get(o.ID).CampaignID) + ((mapOld.get(o.ID).This_Year_Expected_Revenue__c != null) ? mapOld.get(o.ID).This_Year_Expected_Revenue__c : 0.00);
                                mapThisYear.put(mapOld.get(o.ID).CampaignID, total);
                            }
                        }

                        if (o.CampaignID != null) {
                            if (mapFullYear.get(o.CampaignID) == null) {
                                decimal total = ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                                mapFullYear.put(o.CampaignID, total);
                            } else {
                                decimal total = mapFullYear.get(o.CampaignID) + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                                mapFullYear.put(o.CampaignID, total);
                            }

                            if (mapThisYear.get(o.CampaignID) == null) {
                                decimal total = ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                                mapThisYear.put(o.CampaignID, total);
                            } else {
                                decimal total = mapThisYear.get(o.CampaignID) + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                                mapThisYear.put(o.CampaignID, total);
                            }
                        }
                    }
                }
            }

            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Set<String> ListCampaignID = new Set<String>();
            List<Campaign> listUpdateCampaign = new List<Campaign>();

            for (Campaign c : [select ID
                                      , FullDealExpectedRevenueOpportunities__c, HierarchyFullDealExpectedRevenueOpty__c
                                      , ThisYearExpectedRevenueOpportunities__c, HierarchyThisYearExpectedRevenueOpty__c
                                      from Campaign where ID in: ListOldCampaignID])
            {
                ListCampaignID.add(c.ID);

                if (mapCampaign.get(c.ID) == null) {
                    Campaign campObj = new Campaign();
                    campObj.ID = c.ID;

                    campObj.FullDealExpectedRevenueOpportunities__c = ((c.FullDealExpectedRevenueOpportunities__c != null) ? c.FullDealExpectedRevenueOpportunities__c : 0.00) - ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.ThisYearExpectedRevenueOpportunities__c = ((c.ThisYearExpectedRevenueOpportunities__c != null) ? c.ThisYearExpectedRevenueOpportunities__c : 0.00) - ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00) - ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueOpty__c = ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00) - ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);

                    mapCampaign.put(c.ID, campObj);
                } else {
                    Campaign campObj = mapCampaign.get(c.ID);
                    campObj.ID = c.ID;

                    campObj.FullDealExpectedRevenueOpportunities__c = ((campObj.FullDealExpectedRevenueOpportunities__c != null) ? campObj.FullDealExpectedRevenueOpportunities__c : 0.00) - ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.ThisYearExpectedRevenueOpportunities__c = ((campObj.ThisYearExpectedRevenueOpportunities__c != null) ? campObj.ThisYearExpectedRevenueOpportunities__c : 0.00) - ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((campObj.HierarchyFullDealExpectedRevenueOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueOpty__c : 0.00) - ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueOpty__c = ((campObj.HierarchyThisYearExpectedRevenueOpty__c != null) ? campObj.HierarchyThisYearExpectedRevenueOpty__c : 0.00) - ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);

                    mapCampaign.put(c.ID, campObj);
                }
            }

            for (Campaign c : [select ID
                                      , FullDealExpectedRevenueOpportunities__c, HierarchyFullDealExpectedRevenueOpty__c
                                      , ThisYearExpectedRevenueOpportunities__c, HierarchyThisYearExpectedRevenueOpty__c
                                      from Campaign where ID in: ListNewCampgignID])
            {
                ListCampaignID.add(c.ID);

                if (mapCampaign.get(c.ID) == null) {
                    Campaign campObj = new Campaign();
                    campObj.ID = c.ID;

                    campObj.FullDealExpectedRevenueOpportunities__c = ((c.FullDealExpectedRevenueOpportunities__c != null) ? c.FullDealExpectedRevenueOpportunities__c : 0.00) + ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.ThisYearExpectedRevenueOpportunities__c = ((c.ThisYearExpectedRevenueOpportunities__c != null) ? c.ThisYearExpectedRevenueOpportunities__c : 0.00) + ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueOpty__c = ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00) + ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);

                    mapCampaign.put(c.ID, campObj);
                } else {
                    Campaign campObj = mapCampaign.get(c.ID);
                    campObj.ID = c.ID;

                    campObj.FullDealExpectedRevenueOpportunities__c = ((campObj.FullDealExpectedRevenueOpportunities__c != null) ? campObj.FullDealExpectedRevenueOpportunities__c : 0.00) + ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.ThisYearExpectedRevenueOpportunities__c = ((campObj.ThisYearExpectedRevenueOpportunities__c != null) ? campObj.ThisYearExpectedRevenueOpportunities__c : 0.00) + ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueOpty__c = ((campObj.HierarchyFullDealExpectedRevenueOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + ((mapFullYear.get(c.id) != null) ? mapFullYear.get(c.id) : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueOpty__c = ((campObj.HierarchyThisYearExpectedRevenueOpty__c != null) ? campObj.HierarchyThisYearExpectedRevenueOpty__c : 0.00) + ((mapThisYear.get(c.id) != null) ? mapThisYear.get(c.id) : 0.00);

                    mapCampaign.put(c.ID, campObj);
                }
            }

            for (String cid : ListCampaignID)
            {
                if (mapCampaign.get(cid) != null) {
                    listUpdateCampaign.add(mapCampaign.get(cid));
                }
            }
            System.debug('LIST UPDATE CAMPAIGN :: '+listUpdateCampaign);
            try {

                if (listUpdateCampaign.size() > 0)
                    update listUpdateCampaign;
            } catch (exception ex) {
                system.debug('opportunity trigger updateOpportunityCampaign Error Line '+ ex.getLineNumber() + ' : ' + ex.getMessage());
            }

        }

        system.debug('opportunity trigger : updateOpportunityCampaign end');
    }

    public static void updateCampaignCloseWon(List<Opportunity> ListNewOpty, List<Opportunity> ListOldOpty)
    {
        system.debug('opportunity trigger : updateCampaignCloseWon start');

        Map<Id,Opportunity> mapOld = new Map<Id,Opportunity>();
        mapOld.putAll(ListOldOpty);
        Set<String> ListOpportunityID = new Set<String>();

        for (Opportunity o : ListNewOpty)
        {
            if (o.IsWon == true && mapOld.get(o.ID).IsWon == false) {
                ListOpportunityID.add(o.ID);
            }
        }

        if (ListOpportunityID.size() > 0) {

            Map<Id,Campaign> mapCampaign = new Map<Id,Campaign>();
            Set<String> ListCampaignID = new Set<String>();
            List<Campaign> listUpdateCampaign = new List<Campaign>();

            for (Opportunity o : [Select Id, CampaignID
                                         , Campaign.FullDealExpectedRevenueWONOpty__c, Campaign.ThisYearExpectedRevenueWONOpty__c
                                         , Campaign.HierarchyFullDealExpectedRevenueWONOpty__c, Campaign.HierarchyThisYearExpectedRevenueWONOpty__c
                                         , Expected_Revenue_Input__c
                                         , This_Year_Expected_Revenue__c
                                         from Opportunity where ID in: ListOpportunityID])
            {
                ListCampaignID.add(o.CampaignID);

                if (mapCampaign.get(o.CampaignID) == null) {
                    Campaign campObj = new Campaign();
                    campObj.ID = o.CampaignID;

                    campObj.FullDealExpectedRevenueWONOpty__c = ((o.Campaign.FullDealExpectedRevenueWONOpty__c != null) ? o.Campaign.FullDealExpectedRevenueWONOpty__c : 0.00) + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                    campObj.ThisYearExpectedRevenueWONOpty__c = ((o.Campaign.ThisYearExpectedRevenueWONOpty__c != null) ? o.Campaign.ThisYearExpectedRevenueWONOpty__c : 0.00) + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueWONOpty__c = ((o.Campaign.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? o.Campaign.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueWONOpty__c = ((o.Campaign.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? o.Campaign.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);

                    mapCampaign.put(o.CampaignID, campObj);
                } else {
                    Campaign campObj = mapCampaign.get(o.CampaignID);

                    campObj.FullDealExpectedRevenueWONOpty__c = ((campObj.FullDealExpectedRevenueWONOpty__c != null) ? campObj.FullDealExpectedRevenueWONOpty__c : 0.00) + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                    campObj.ThisYearExpectedRevenueWONOpty__c = ((campObj.ThisYearExpectedRevenueWONOpty__c != null) ? campObj.ThisYearExpectedRevenueWONOpty__c : 0.00) + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);
                    campObj.HierarchyFullDealExpectedRevenueWONOpty__c = ((campObj.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? campObj.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) + ((o.Expected_Revenue_Input__c != null) ? o.Expected_Revenue_Input__c : 0.00);
                    campObj.HierarchyThisYearExpectedRevenueWONOpty__c = ((campObj.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? campObj.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) + ((o.This_Year_Expected_Revenue__c != null) ? o.This_Year_Expected_Revenue__c : 0.00);

                    mapCampaign.put(o.CampaignID, campObj);
                }
            }

            for (String cid : ListCampaignID)
            {
                if (mapCampaign.get(cid) != null) {
                    listUpdateCampaign.add(mapCampaign.get(cid));
                }
            }

            try {

                if (listUpdateCampaign.size() > 0)
                    update listUpdateCampaign;
            } catch (exception ex) {
                system.debug('opportunity trigger updateCampaignCloseWon Error Line '+ ex.getLineNumber() + ' : ' + ex.getMessage());
            }

        }

        system.debug('opportunity trigger : updateCampaignCloseWon end');

    }
    
    public static void IsStageOrStatusChangedAfterSubmit(List<Opportunity> oppsNew,List<Opportunity> oppsOld){
    
        String IsSendWhenOppStageChange = '';
        if (!Test.isRunningTest())
            IsSendWhenOppStageChange = appConfig__c.getValues('Send email when opty stage change').Value__c;
        String IsSendWhenAppStatusChange = '';
        if (!Test.isRunningTest())
            IsSendWhenAppStatusChange = appConfig__c.getValues('Send email when app status change').Value__c;
        List<String> ListRecordTypeSendEmail = new List<String>();
        if (!Test.isRunningTest())
            ListRecordTypeSendEmail = appConfig__c.getValues('Recordtype email notification').Value__c.Split(';');
            
        List<Opportunity> listReturn = new List<Opportunity>();
        Map<Id,Opportunity> mapOppsOld = new Map<Id,Opportunity>();
        List<String> ListOpportunityID = new List<String>();
        if( oppsOld != null && oppsOld.size() > 0 ){
            mapOppsOld.putAll(oppsOld);
        }
        map<string,string> mapRecordType = new map<string,string>();
        for (recordtype r : recordTypeList)
        {
            mapRecordType.put(r.id,r.name);
        }
        for(Opportunity opp : oppsNew){
//            if (mapRecordType.get(opp.recordtypeid) == 'SE Credit Product2'
//             || mapRecordType.get(opp.recordtypeid) == 'SE Credit Product3'){
            boolean isRecordtypeInList = false;
            for (string s : ListRecordTypeSendEmail)
            {
                if (mapRecordType.get(opp.recordtypeid) == s)
                    isRecordtypeInList = true;
            }
            if (isRecordtypeInList){
                if( opp.StageName != mapOppsOld.get(opp.Id).StageName && IsSendWhenOppStageChange.toLowerCase().contains('true')){                        
                    ListOpportunityID.add(opp.ID);
                }else if( opp.Application_Status__c != mapOppsOld.get(opp.Id).Application_Status__c && IsSendWhenAppStatusChange.toLowerCase().contains('true')){
                    ListOpportunityID.add(opp.ID);
                }
            }
        }
       
        if (ListOpportunityID.size() > 0) {
            List<Opportunity> listSendEmailOpty = [select id,stageName,accountid,owner.email from opportunity where id in: ListOpportunityID];
            if (listSendEmailOpty.size() > 0 && !isSendMail){
                SLOSEmailService.emailAfterStageChange(listSendEmailOpty);
                isSendMail = true;
            }
        }
    }

    public static void addOpportunityTeam(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        List<Opportunity> opportunityWithReferral = new List<Opportunity>();
        for(Id oppId : newMap.keySet()){
            Opportunity oldOpp = oldMap.get(oppId);
            Opportunity newOpp = newMap.get(oppId);
            if(oldOpp.RTL_Referral__c != newOpp.RTL_Referral__c){
                opportunityWithReferral.add(newOpp);
            }
        }
        insertOpportunityTeam(opportunityWithReferral);        
    }

    public static void insertOpportunityTeam(List<Opportunity> oppList){
      List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
      Set<Id> referralIdSet = new Set<Id>();
      Map<Id,RTL_Referral__c> referralMap;
      for(Opportunity opty : oppList){
        if(opty.RTL_Referral__c != null){
          referralIdSet.add(opty.RTL_Referral__c);
        }
      }

      if(referralIdSet.size() > 0){
        referralMap = new Map<Id,RTL_Referral__c>([SELECT Id,RTL_Stage__c,RTL_Employee_Name__c,RTL_EmployeeId__c,RTL_Branch__c,RTL_Account_Name__c,OwnerId,CreatedDate,CreatedById,
                                                            RTL_Refer_Branch_Name__c,RTL_Type__c,RecordType.DeveloperName,RTL_Preferred_Branch__r.IsActive__c,RTL_Channel_Segment__c  FROM RTL_Referral__c WHERE ID IN:referralIdSet]);
      }

      for(Opportunity opty : oppList){
        if(opty.RTL_Referral__c != null){
          if(referralMap.containsKey(opty.RTL_Referral__c)){
            RTL_Referral__c referral = referralMap.get(opty.RTL_Referral__c);
            oppTeamMemberList.add(createopptyTeamOpportunityTeam(opty.id,referral.CreatedById,'Referral Creator','Read'));
          }
        }
      }

      if(oppTeamMemberList.size() > 0){
        //insert oppTeamMemberList;
        Database.Saveresult[] dbSave1 = Database.insert(oppTeamMemberList, false); 
    	for (Database.Saveresult recSave : dbSave1) { 
       		if (recSave.isSuccess()) { 
 				System.debug('Successfully insert opportunity team member');  
          
       		} else { 
        		Database.Error eMsg = recSave.getErrors()[0]; 
        		System.debug('.............Insert for OpportunityTeamMember failed ');  
        		System.debug('.............The DB returned the following error for the above record: ' + eMsg);
       		}
    	}
      }

    }

    public static OpportunityTeamMember createopptyTeamOpportunityTeam(String oppId,String userId,String role,String accessLevel){
      OpportunityTeamMember optyTeam = new OpportunityTeamMember ();
      optyTeam.OpportunityId = oppId;
      optyTeam.UserId = userId;
      optyTeam.TeamMemberRole = role;
      return optyTeam;
    }
    
}