public class VisitPlanTriggerHandler {

    static String dtFormat = 'yyyy-MM-dd-HH:mm:ss';
    static String dFormat ='EEEEE dd/MM/yyyy';
    
     public static TimeZone tz{get{
        
        if(tz ==null){
            tz  = UserInfo.getTimeZone();
        }
        return tz;
    }set;}
    

    public static void createEvents(List<Call_Report__c> newList){
        List<Event> insertEventList = new List<Event>();
        List<Call_Report__c> visitplanList = [SELECT ID,Main_purpose__c,Lead__c,Lead__r.Company,
                                              Customer_name__c,OwnerId,Customer_name__r.Name,
                                               Start_Visit_Time__c ,Date_of_Visit__c,
                                              End_Visit_Time__c, Meeting_Place__c
                                             FROM Call_Report__c WHERE ID IN:newList];
        
        for(Call_Report__c visit : visitplanList){
            Event evnt = new Event();
            evnt.Visit_Plan_report__c = visit.id;
            evnt.OwnerId = visit.OwnerId;
            evnt.Location = visit.Meeting_Place__c;
            String custname ='';
           
            
            
            if(visit.Lead__c !=null){
                 custname = visit.Lead__r.Company==null?'':visit.Lead__r.Company+' - ';
            }else{
                 custname = visit.Customer_name__r.Name==null?'':visit.Customer_name__r.Name+' - '; 
            }
            
            
             if(custName.length()>100){
                custname = custname.substring(0,100);
            }
            
            
            if(visit.Main_purpose__c!=null){
                evnt.Subject = custname+visit.Main_purpose__c;
            }else{
                evnt.Subject = custname+'Meeting';
            }
            
           
            
            DateTime startDT;
            
            
            
            
            if(visit.Start_Visit_Time__c !=null ){
                String visittime = visit.Start_Visit_Time__c;
                List<String> hourMinute = visittime.split(':');
                startDT = datetime.newInstance (visit.Date_of_Visit__c.Year(),
                                                    visit.Date_of_Visit__c.Month(),
                                                    visit.Date_of_Visit__c.Day(),
                                               Integer.valueOf(hourMinute.get(0)),
                                               Integer.valueOf(hourMinute.get(1)),0);
                
                 
                 evnt.StartDateTime = startDT;
                if(visit.End_Visit_Time__c ==null){
                    evnt.EndDateTime =startDT.addHours(1);
                }
                
            }
            
            else{
                if(visit.End_Visit_Time__c  ==null){
                 startDT = datetime.newInstance (visit.Date_of_Visit__c.Year(),
                                                    visit.Date_of_Visit__c.Month(),
                                                    visit.Date_of_Visit__c.Day(),9,0,0);
                
                 evnt.StartDateTime = startDT;
                 evnt.EndDateTime =startDT.addHours(1);
                    
                  
                }
                 
            }
            
            if(visit.End_Visit_Time__c  !=null ){
                 
                String visittime = visit.End_Visit_Time__c ;
                List<String> hourMinute = visittime.split(':');
                 DateTime endtime = datetime.newInstance (visit.Date_of_Visit__c.Year(),
                                                    visit.Date_of_Visit__c.Month(),
                                                    visit.Date_of_Visit__c.Day()
                                                             ,Integer.valueOf(hourMinute.get(0))
                                                             ,Integer.valueOf(hourMinute.get(1))
                                                             ,0);
                
                  
                  evnt.EndDateTime = endtime;
                
                
                
                
                  
                if(visit.Start_Visit_Time__c ==null){
                   evnt.StartDateTime =startDT.addHours(-1);
                }
                 
                
            }
            
            else{
                if(visit.Start_Visit_Time__c !=null){
                     evnt.EndDateTime =startDT.addHours(1);
                     
                }
            }
            if(evnt.StartDateTime >= evnt.EndDateTime){
                //evnt.addError( Status_Code__c.GetValues('7007').Status_Message__c);
            }
            else{
                
                 evnt.Visit_Plan_Report__c = visit.id;
                 evnt.ActivityDate = visit.Date_of_Visit__c;
        
                 insertEventList.add(evnt);
            }
        }
        
            insert insertEventList;
        
        
        
    }

    
    public static void updateEvents(Map<ID,Call_Report__c> oldmap,List<Call_Report__c> TriggerNew){
        Set<ID> VisitPlanIDSet = new Set<ID>();
        Set<ID> VisitPlanUpdateSet = new Set<ID>();
        Set<ID> VisitPlanChangeOwnerSet = new Set<ID>();
        Map<ID,ID> VisitPlanNewOwnerMap = new Map<Id,ID>();
        Map<Id,Call_report__C> visitPlanMap = new Map<ID,Call_report__C>();
        for(Call_Report__c visit : TriggerNew){
            Call_report__c oldvisit = oldmap.get(visit.id);
            if(visit.Status__c=='3 - Cancel'){
                VisitPlanIDSet.add(visit.id);
            }else if (visit.Main_purpose__c != oldvisit.Main_purpose__c
                     ||visit.Date_of_Visit__c != oldvisit.Date_of_Visit__c
                     ||visit.Start_Visit_Time__c != oldvisit.Start_Visit_Time__c
                     ||visit.End_Visit_Time__c != oldvisit.End_Visit_Time__c
                     ||visit.Meeting_Place__c != oldvisit.Meeting_Place__c){
                         visitPlanMap.put(visit.id,visit);
                VisitPlanUpdateSet.add(visit.id);
            }else if (visit.ownerid != oldvisit.ownerid){
                      VisitPlanChangeOwnerSet.add(visit.id);   
                VisitPlanNewOwnerMap.put(visit.id,visit.ownerId);
            }
            
        }
        
        
        //Change Owner
        //
        
        if(VisitPlanChangeOwnerSet.size()>0){
            List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,IsChild,subject,WhatID  
                       FROM Event WHERE Visit_Plan_Report__c IN: VisitPlanChangeOwnerSet AND IsChild =false];
            
            Map<ID,List<EventRelation>> ExistingTmbpartyMap = new Map<ID,List<EventRelation>>();
            
                    //Query EventRelation 
                List<EventRelation> EvntReList = [SELECT ID,EventID,RelationID  FROM EventRelation
                                                     WHERE EventID IN: evntList];
            
                    //Query Tmb CounterParty
                    //
                
           
            Map<ID,List<Visit_Plan_Invitee__c>> ExistingInviteeMap = new Map<ID,List<Visit_Plan_Invitee__c>>();
            
            for(Visit_Plan_Invitee__c invitee : [SELECT TMB_Person__c,TMB_Person__r.id,
                                               Visit_Plan_Report__c,
                                              Visit_Plan_Report__r.OwnerID 
                                                             FROM Visit_Plan_Invitee__c
                                                             WHERE Visit_Plan_Report__c IN:VisitPlanChangeOwnerSet]){
                                                                 
                if(ExistingInviteeMap.containsKey(invitee.Visit_Plan_Report__c)){
                    ExistingInviteeMap.get(invitee.Visit_Plan_Report__c).add(invitee);
                }else{
                    List<Visit_Plan_Invitee__c> relationList = new List<Visit_Plan_Invitee__c>();
                    relationList.add(invitee);
                    ExistingInviteeMap.put(invitee.Visit_Plan_Report__c,relationList);
                }                                              
                
            }
            
            for(EventRelation evntR : EvntReList){
                if(ExistingTmbpartyMap.containsKey(evntR.EventID)){
                    ExistingTmbpartyMap.get(evntR.EventID).add(evntR);
                }else{
                    List<EventRelation> relationList = new List<EventRelation>();
                    relationList.add(evntR);
                    ExistingTmbpartyMap.put(evntR.EventID,relationList);
                }
            }
            
            List<EventRelation> deleteRelationList = new List<EventRelation>();
            List<Visit_Plan_Invitee__c> deleteinviteeList = new List<Visit_Plan_Invitee__c>();
            for(Event evnt : evntList){
                if(ExistingTmbpartyMap.containsKey(evnt.id)){
                    for(EventRelation evntR : ExistingTmbpartyMap.get(evnt.id)){
                        if(evntR.RelationId == visitPlanNewOwnerMap.get(evnt.Visit_Plan_Report__c)){
                           deleteRelationList.add(evntR); 
                        }
                    }
                }
                
                if(ExistingInviteeMap.containsKey(evnt.Visit_Plan_Report__c)){
                    for(Visit_Plan_Invitee__c invitee : ExistingInviteeMap.get(evnt.Visit_Plan_Report__c)){
                        if(invitee.TMB_Person__c == visitPlanNewOwnerMap.get(evnt.Visit_Plan_Report__c)){
                            deleteinviteeList.add(invitee);
                        }
                    }
                }
                
                
                    evnt.OwnerId = visitPlanNewOwnerMap.get(evnt.Visit_Plan_Report__c);
                
                
            }
            
            delete deleteinviteeList;
            delete deleteRelationList;
            update evntlist;
            
        }
        
        
        
        
        
         //Update Event
         //
         //
         System.debug('VisitPlanUpdateSet :'+VisitPlanUpdateSet);
        if(VisitPlanUpdateSet.size()>0){
           /* List<Call_Report__c> visitplanList = [SELECT ID,Main_purpose__c,
                                              Customer_name__c,OwnerId,Customer_name__r.Name,
                                               Start_Visit_Time__c ,Date_of_Visit__c,
                                              End_Visit_Time__c
                                             FROM Call_Report__c WHERE ID IN:VisitPlanUpdateSet];
            Map<Id,Call_report__C> visitPlanMap = new Map<ID,Call_report__C>();
            for(Call_report__c visit : visitplanList){
                visitPlanMap.put(visit.id,visit);
            }*/
            
            List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,IsChild,subject,WhatID
                                   
                       FROM Event WHERE Visit_Plan_Report__c IN: VisitPlanUpdateSet AND IsChild =false];
            
            for(Event evnt :  evntList){
                Call_report__c visit =  visitPlanMap.get(evnt.Visit_Plan_Report__c);
              //String custname = visit.Customer_name__r.Name==null?'':visit.Customer_name__r.Name+' - ';
              String custname='';
                if(visit.Lead__c !=null){
                    custname = [select Company from Lead where id =: visit.Lead__c].Company;
                }else{
                   custname = [select name from account where id =: visit.Customer_name__c].name;
                }
                
              custname = custname==null ? '' : custname+' - ';
                if(visit.Main_purpose__c!=null){
                    evnt.Subject = custname+visit.Main_purpose__c;
                }else{
                    evnt.Subject = custname+'Meeting';
                }
                
                evnt.Visit_Plan_Report__c = visit.id;
                
                //Update Meeting Place
                if(visit.Meeting_Place__c != null ){
                    evnt.Location = visit.Meeting_Place__c;
                }
                
                //Assign Time
              
                DateTime startDT;
                            if(visit.Start_Visit_Time__c !=null ){
                            String visittime = visit.Start_Visit_Time__c;
                            List<String> hourMinute = visittime.split(':');
                               System.debug('hourMinute : '+hourMinute);
                            startDT = DateTime.newInstance (visit.Date_of_Visit__c.Year(),
                                                                visit.Date_of_Visit__c.Month(),
                                                                visit.Date_of_Visit__c.Day(),
                                                           Integer.valueOf(hourMinute.get(0)),
                                                           Integer.valueOf(hourMinute.get(1)),0);
                                System.debug('dateOutput : '+startDT);
                             evnt.StartDateTime = startDT;
                            if(visit.End_Visit_Time__c ==null){
                                evnt.EndDateTime =startDT.addHours(1);
                            }
                                
                                System.debug('evnt.StartDateTime : '+evnt.StartDateTime);
                            
                        }
                        
                        else{
                            if(visit.End_Visit_Time__c  ==null){
                             startDT = datetime.newInstance (visit.Date_of_Visit__c.Year(),
                                                                visit.Date_of_Visit__c.Month(),
                                                                visit.Date_of_Visit__c.Day(),9,0,0);
                            
                             evnt.StartDateTime = startDT;
                             evnt.EndDateTime =startDT.addHours(1);
                                
                              
                            }
                             
                        }
                        
                        if(visit.End_Visit_Time__c  !=null ){
                             
                            String visittime = visit.End_Visit_Time__c ;
                            List<String> hourMinute = visittime.split(':');
                             DateTime endtime = datetime.newInstance (visit.Date_of_Visit__c.Year(),
                                                                visit.Date_of_Visit__c.Month(),
                                                                visit.Date_of_Visit__c.Day()
                                                                         ,Integer.valueOf(hourMinute.get(0))
                                                                         ,Integer.valueOf(hourMinute.get(1))
                                                                         ,0);
                              evnt.EndDateTime = endtime;
                              
                            if(visit.Start_Visit_Time__c ==null){
                               evnt.StartDateTime =startDT.addHours(-1);
                            }
                             
                            
                        }
                        
                        else{
                            if(visit.Start_Visit_Time__c !=null){
                                 evnt.EndDateTime =startDT.addHours(1);
                                 
                            }
                        }
                //
                //Assign Time
                
            
            }
            
           System.debug('evntList : '+evntList);
            update evntList;
            
            
        }
        
       
        
        
        //Cancel Events
        if(VisitPlanIDSet.size()>0){
               List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,IsChild,subject,WhatID  
                       FROM Event WHERE Visit_Plan_Report__c IN: VisitPlanIDSet AND IsChild =false];
             delete evntList;
        }
        
        
        
        
    }
    
    public static void deleteEvents(List<Call_Report__c> TriggerOld){
        List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,IsChild,subject,WhatID  
                       FROM Event WHERE Visit_Plan_Report__c IN: TriggerOld AND IsChild =false];     
        delete evntList;
    }

    public static void checkTMBPerson(List<Call_Report__c> TriggerNew,MAp<Id,Call_report__c> oldmap){
       List<Call_Report__c> newList = new List<Call_Report__c>();
       List<Call_Report__c> changeOwnerList = new List<Call_report__c>();
       Map<ID,ID> newOwnerMap = new Map<ID,ID>();
        for(Call_Report__c visit : TriggerNew){
            Call_Report__c oldValue = oldmap.get(visit.id);
            if(oldValue.TMB_person__c != visit.TMB_person__c){
                newList.add(visit);
            }
            
            if(oldValue.OwnerId !=visit.OwnerId){
                changeOwnerList.add(visit);
                newOwnerMap.put(visit.id,visit.OwnerId);
            }
        }
        
        if(newList.size()>0){
            List<Visit_Plan_Invitee__c> VisitPlanList = [SELECT TMB_Person__c,TMB_Person__r.id,
                                               Visit_Plan_Report__c,
                                              Visit_Plan_Report__r.TMB_person__c,
                                              Visit_Plan_Report__r.OwnerID
                                              FROM Visit_Plan_Invitee__c
                                              WHERE Visit_Plan_Report__c IN: newList];
        Map<ID,Set<ID>> VisitTMBPersonMap = new Map<ID,Set<ID>>();
        for(Visit_Plan_Invitee__c invitee : VisitPlanList){
            System.debug(invitee);
            if(VisitTMBPersonMap.containsKey(invitee.Visit_Plan_Report__c)){
                VisitTMBPersonMap.get(invitee.Visit_Plan_Report__c).add(invitee.TMB_Person__r.id);
            }else{
                Set<ID> TMbPersonset = new Set<ID>();
                TMbPersonset.add(invitee.TMB_Person__r.id);
                VisitTMBPersonMap.put(invitee.Visit_Plan_Report__c,TMbPersonset);
            }
        }
        
            System.debug(VisitTMBPersonMap);        
        for(Call_Report__c visitPlan : newList){
            boolean isHasPermission = false;
            if(Userinfo.getUserId() != visitPlan.OwnerId){
                /*if(VisitTMBPersonMap.containsKey(visitPlan.id)){
                    if(VisitTMBPersonMap.get(visitPlan.id).Contains(userinfo.getUserID())){
                      ishasPermission =true;
                    }
                }*/
            }else{
                isHasPermission = true;
            }
            
            if(!isHasPermission){
                 visitPlan.addError( Status_Code__c.GetValues('7008').Status_Message__c);
            }
              
        }
        
        }
        
        
        if(changeOwnerList.size()>0){

            List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,Visit_Plan_Report__r.ID  
                       FROM Event WHERE Visit_Plan_Report__c IN: changeOwnerList AND IsChild =false];
            for(Event evnt : evntList){
                evnt.OwnerId = newOwnerMap.get(evnt.Visit_Plan_Report__r.id);
            }
                 update evntlist;            
        }
         
    }

    public static void checkpermissionTMBCounterParty(Map<ID,Visit_Plan_Invitee__c> oldTMBMap,List<Visit_Plan_Invitee__c> TriggerNew,String operation){
        Set<ID> visitPlanID = new Set<ID>();
        Integer index = 0;
        boolean isAfterProcess = true;
        for(Visit_Plan_Invitee__c invitee : TriggerNew){
            visitPlanID.add(invitee.Visit_Plan_Report__c);
        }
        
        Map<ID,Set<ID>> existingTMBMap = new Map<ID,Set<ID>>();
        Map<ID,Integer> seqMap = new Map<ID,Integer>();        
        for(Visit_Plan_Invitee__c invitee : [SELECT ID,SEQ__C,VISIT_Plan_report__c,VISIT_Plan_report__r.OwnerId,TMB_Person__c from Visit_Plan_Invitee__c
                                            WHERE VISIT_Plan_report__c IN: visitPlanID
                                            ORDER BY SEQ__C ASC]){
                                                if(existingTMBMap.containsKey(invitee.Visit_Plan_Report__c)){
                                                    existingTMBMap.get(invitee.Visit_Plan_Report__c).add(invitee.TMB_Person__c);
                                                    
                                                    if(Integer.valueOf(invitee.SEQ__c) > seqMap.get(invitee.Visit_Plan_Report__c)){
                                                        seqMap.put(invitee.Visit_Plan_Report__c,Integer.valueOf(invitee.SEQ__c)); 
                                                    }
                                                }else{
                                                    Set<ID> tmbset = new Set<ID>();
                                                    tmbset.add(invitee.TMB_Person__c);
                                                    existingTMBMap.put(invitee.Visit_Plan_Report__c,tmbset);
                                                    if(invitee.SEQ__c !=null){
                                                       seqMap.put(invitee.Visit_Plan_Report__c,Integer.valueOf(invitee.SEQ__c)); 
                                                    }
                                                }
            
        }
        
        Map<ID,ID> permissionMap = new Map<ID,ID>();
        for(Call_report__c visitplan : [SELECT ID,OwnerID from Call_report__c where ID IN:visitPlanID]){
            permissionMap.put(visitplan.id,visitPlan.ownerID);
        }
        
         
         for(Visit_Plan_Invitee__c invitee : TriggerNew){
                    //Assign SEQ
                     
              if(operation=='INSERT'){
                 
                    if(invitee.TMB_Person__c == permissionMap.get(invitee.Visit_Plan_Report__c)){
                           
                           invitee.addError( Status_Code__c.GetValues('7003').Status_Message__c);
                           isAfterProcess= false;
                       
               }else if(Userinfo.getUserId() !=permissionMap.get(invitee.Visit_Plan_Report__c)){
                 invitee.addError( Status_Code__c.GetValues('7006').Status_Message__c);
                    isAfterProcess= false;
              }
             else if(existingTMBMap.containskey(invitee.Visit_Plan_Report__c)){
                 if(existingTMBMap.get(invitee.Visit_Plan_Report__c).contains(invitee.TMB_Person__c)&&operation=='INSERT'){
                     invitee.addError( Status_Code__c.GetValues('7002').Status_Message__c);
                        isAfterProcess= false;
                     
                 }
                         
                  }else if (existingTMBMap.containskey(invitee.Visit_Plan_Report__c)&&operation=='UPDATE'){
                     for(ID existing : existingTMBMap.get(invitee.Visit_Plan_Report__c)){
                         if(existing == invitee.ID){
                            invitee.addError( Status_Code__c.GetValues('7002').Status_Message__c); 
                             isAfterProcess= false;
                         }
                     }
                     
                 }
                 
                 
                 
             }
             
                  if(invitee.SEQ__c ==null){
                      if(seqMap.containsKey(invitee.Visit_Plan_Report__c)){
                          
                              invitee.SEQ__C = seqMap.get(invitee.Visit_Plan_Report__c)+1; 
                          
                           
                      }else{
                            invitee.SEQ__C = 0;
                      }
                }
             
             System.debug(invitee.SEQ__c);
            
        }
        
        System.debug('isAfterProcess : '+isAfterProcess);
        if(isAfterProcess){
          // visitInviteeSynch(oldTMBMap,TriggerNew,operation);
        }

    }
    
    
    public static void visitInviteeSynch (Map<ID,Visit_Plan_Invitee__c> oldTMBMap,List<Visit_Plan_Invitee__c> TMBList,String operation){
             //Declare Attributes
         Set<ID> VisitPlanIDSet = new Set<ID>();
         Map<ID,ID> VisitPlanEventMap = new Map<ID,ID>();
        Map<ID,List<Visit_Plan_Invitee__c>> VisitplanInviteeMap = new  Map<ID,List<Visit_Plan_Invitee__c>>();
         Map<Id,List<Event>> VisitPlanChildEventMap = new Map<Id,List<Event>>();
         Map<ID,List<EventRelation>> oldEventRelation = new Map<ID,List<EventRelation>>();
         List<EventRelation> DeleteEventRelation = new List<EventRelation>();
         List<EventRelation> EvntReInsertList = new List<EventRelation>();
         List<Call_Report__Share> createVisitShareList = new  List<Call_Report__Share>();
        List<Call_Report__Share> deleteVisitShareList = new  List<Call_Report__Share>();
        Map<ID,Boolean> VisitplanIsClosedMap = new Map<ID,Boolean>();
        
        
         for(Visit_Plan_Invitee__c tmbperson : TMBList){
        		VisitPlanIDSet.add(tmbperson.Visit_Plan_Report__c);
         }
        
        for(Call_report__c visitplan : [SELECT ID,OutCome__c,RecordTypeID,recordType.Name from
                                       Call_Report__c WHERE ID IN: VisitPlanIDSet]){
            boolean isclosed = false;
                                           if(visitplan.RecordType.Name.containsIgnoreCase('Close')
                                             || visitplan.Outcome__c =='Cancelled'){
                                               isclosed=true;
                                           }
                                           VisitplanIsClosedMap.put(visitPlan.id,isclosed);
        }
        
        
        //Create elements for Visitplan and Inivitees map
        //
        
        for(Visit_Plan_Invitee__c tmbperson : TMBList){
				System.debug(tmbperson.TMB_Person__c);

            if(VisitplanIsClosedMap.get(tmbperson.Visit_Plan_Report__c)){
                // tmbperson.addError( Status_Code__c.GetValues('7010').Status_Message__c); 
            }
            else if(tmbperson.TMB_Person__c==null&& tmbperson.id!=null){
                tmbperson.addError( Status_Code__c.GetValues('7007').Status_Message__c); 
            }else{
                if(tmbperson.TMB_Person__c!=null){
                      
					if(VisitplanInviteeMap.containsKey(tmbperson.Visit_Plan_Report__c)){
                        VisitplanInviteeMap.get(tmbperson.Visit_Plan_Report__c).add(tmbperson);
                    }else{
                        List<Visit_Plan_Invitee__c> invitees = new List<Visit_Plan_Invitee__c>();
                        invitees.add(tmbperson);
                        VisitplanInviteeMap.put(tmbperson.Visit_Plan_Report__c,invitees);
                    }
                }
            }
        }
        
        //Query Visit plan for Apex Sharing
        Map<ID,Call_report__c> visitplanMap = new Map<Id,Call_report__C>([SELECT ID from Call_report__c WHERE ID IN: VisitPlanIDset]);
        
        
        //Query Apex Sharing
        Map<ID,List<Call_Report__Share>> existingVisitSharing = new Map<ID,List<Call_Report__Share>>();
        for(Call_Report__Share sharingrecord : [SELECT ID,
                                        UserOrGroupID,
                                        ParentID
                                        from Call_Report__Share
                                        WHERE parentID IN: VisitPlanIDset
                                               ]){
                                                   
                                                 if(existingVisitSharing.containsKey(sharingrecord.ParentID)){
                										existingVisitSharing.get(sharingrecord.ParentID).add(sharingrecord);
                                                }else{
                                                    List<Call_Report__Share> sharingList = new List<Call_Report__Share>();
                                                    sharingList.add(sharingrecord);
                                                    existingVisitSharing.put(sharingrecord.ParentID,sharingList);
                                                }  
                                                   
                                               }
        
        
        // Query all Event that releated
         List<Event> evntList =[SELECT ID,Visit_Plan_Report__c,IsChild,subject,WhatID  
                       FROM Event WHERE Visit_Plan_Report__c IN: VisitPlanIDSet];

        //Create Eement for parent and child Events
            for(Event evnt : evntList){
                if(!evnt.IsChild){
                VisitPlanEventMap.put(evnt.Visit_Plan_Report__c,evnt.id);
                }else{
                    if(VisitPlanChildEventMap.containsKey(evnt.Visit_Plan_Report__c)){
                        VisitPlanChildEventMap.get(evnt.Visit_Plan_Report__c).add(evnt);
                    }else{
                        List<event> childEventList = new List<event>();
                        childEventList.add(evnt);
                        VisitPlanChildEventMap.put(evnt.Visit_Plan_Report__c,childEventList);
                    }
                }
            }
        
        //Query EventRelation 
        List<EventRelation> EvntReList = [SELECT ID,EventID,RelationID  FROM EventRelation
                                             WHERE EventID IN: evntList];
            
                
            //Create EventRelation Map
            for(EventRelation evntRe : EvntReList){
               
                if(oldEventRelation.containsKey(evntRe.EventID)){
                    oldEventRelation.get(evntRe.EventID).add(evntRe);
                }else{
                    List<EventRelation> EvREList = new List<EventRelation>();
                    EvREList.add(evntRe);
                    oldEventRelation.put(evntRe.EventId,EvREList);
                }
            }
        
         
        
        
        //Create EventRelation and Apex Sharing when VisitPlan Invitee created
        if(operation=='INSERT'){
            
            for(Visit_Plan_Invitee__c tmbperson : TMBList){
                if(tmbperson.TMB_Person__c !=null){
                     EventRelation er = new EventRelation();
                    er.EventId = VisitPlanEventMap.get(tmbperson.Visit_Plan_Report__c);
                    er.RelationId = tmbperson.TMB_Person__c;
                    EvntReInsertList.add(er);
                    
                    
                    //Apex Sharing
                    //
                    Call_Report__Share recordsharing = new Call_Report__Share();
                    recordsharing.UserOrGroupId = tmbperson.TMB_Person__c;
                    recordsharing.AccessLevel  = 'read';
                    recordsharing.ParentId = visitplanMap.get(tmbperson.Visit_Plan_Report__c).id;
                    //recordsharing.RowCause = 'TMB counterparty';
                    createVisitShareList.add(recordsharing);
                    //
                    //
                }
            }
        
       
           
        }
        //Update EventRelation and Apex Sharing when VisitPlan Invitee Changed
        else if(operation=='UPDATE'){ 
            for(Visit_Plan_Invitee__c TMBperson : TMBList){
                Set<ID> ExistingTmbPersonSet = oldTMBMap.keySet();
                
                        if(TMBperson.TMB_Person__c != 
                           oldTMBMap.get(tmbperson.id).TMB_Person__c
                          && TMBperson.TMB_Person__c !=null
                          && !VisitplanIsClosedMap.get(TMBperson.Visit_Plan_Report__c)){
                        ID eventID  = VisitPlanEventMap.get(TMBperson.Visit_Plan_Report__c);
                        //Delete old one
                        for(EventRelation evntRe : oldEventRelation.get(eventID)){
                            if(evntRe.RelationId ==  oldTMBMap.get(tmbperson.id).TMB_Person__c){
                                DeleteEventRelation.add(evntRE);
                            }
                        }
                            //Delete Apex Sharing
                        if(existingVisitSharing.containsKey(TMBperson.Visit_Plan_Report__c)){
                            for(Call_report__Share sharingRecord : existingVisitSharing.get(oldTMBMap.get(tmbperson.id).Visit_Plan_Report__c)){
                                if(sharingRecord.UserOrGroupId== oldTMBMap.get(tmbperson.id).TMB_Person__c){
                                    deleteVisitShareList.add(sharingRecord);
                                }
                            }
                                
                        }
                        //Create new one
                        EventRelation er = new EventRelation();
                        er.EventId = VisitPlanEventMap.get(TMBperson.Visit_Plan_Report__c);
                        er.RelationId = tmbperson.TMB_Person__c;
                        EvntReInsertList.add(er);
                            
                       
                        	//Create Apex Sharing
                            //
                            Call_Report__Share recordsharing = new Call_Report__Share();
                            recordsharing.UserOrGroupId = tmbperson.TMB_Person__c;
                            recordsharing.AccessLevel  = 'read';
                            recordsharing.ParentId = visitplanMap.get(tmbperson.Visit_Plan_Report__c).id;
                            //recordsharing.RowCause = 'TMB counterparty';
                            createVisitShareList.add(recordsharing);
                            //
                            //
                        
                    }
                
            }
            
            
        }
        //Delete EventRelation and Apex Sharing when VisitPlan Invitee Delete
         else if(operation=='DELETE'){ 
          
            for(Visit_Plan_Invitee__c TMBperson : TMBList){
                if(oldEventRelation.containsKey(VisitPlanEventMap.get(TMBperson.Visit_Plan_Report__c))){
                    for(EventRelation evntRe : oldEventRelation.get(VisitPlanEventMap.get(TMBperson.Visit_Plan_Report__c))){
                        if(evntRe.RelationId ==  oldTMBMap.get(tmbperson.id).TMB_Person__c){
                            DeleteEventRelation.add(evntRe);
                        }
                    }
                }
                //Delete Apex Sharing
                        if(existingVisitSharing.containsKey(TMBperson.Visit_Plan_Report__c)){
                            for(Call_report__Share sharingRecord : existingVisitSharing.get(oldTMBMap.get(tmbperson.id).Visit_Plan_Report__c)){
                                if(sharingRecord.UserOrGroupId== oldTMBMap.get(tmbperson.id).TMB_Person__c){
                                    deleteVisitShareList.add(sharingRecord);
                                }
                            }
                                
                        }
               
            }
            
            
         }
        
         System.debug('DeleteEventRelation : '+DeleteEventRelation);
        if(DeleteEventRelation.size()>0){
             delete DeleteEventRelation;
        }
         System.debug('deleteVisitShareList : '+deleteVisitShareList);
        if(deleteVisitShareList.size()>0){
           // delete deleteVisitShareList;
        }
        System.debug('EvntReInsertList : '+EvntReInsertList);
        if(EvntReInsertList.size()>0){
             insert EvntReInsertList; 
        }
        System.debug('createVisitShareList : '+createVisitShareList);
        if(createVisitShareList.size()>0){
            //insert createVisitShareList;
        }
       
        
        
            
        
    }
}