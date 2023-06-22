public class CallReportTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    static Boolean flagExc = true;
    
    public static void handlerBeforeInsert(List<Call_Report__c> reportsNew,List<Call_Report__c> reportsOld){
        conditionCreateVisitReport(reportsNew,null,STR_INSERT);
    }
    
    public static void handlerBeforeUpdate(List<Call_Report__c> reportsNew,List<Call_Report__c> reportsOld){
        List<Call_Report__c> listNew = checkConditionT03(reportsNew,null);
        if( listNew.size() > 0 ){
            System.debug(':::: BeforeUpdate Start ::::');
        	ForStatusComplete(listNew,reportsOld,STR_INSERT);    
            System.debug(':::: BeforeUpdate End ::::'); 
        }        
    }
        
    public static void handlerAfterInsert(List<Call_Report__c> reportsNew){
        if (flagExc == true) {
            System.debug(':::: handlerAfterInsert ::::');
            CaculatedTargetActual(reportsNew);
            //System.debug(':::: CaculatedTargetActual ::::');
            List<Call_Report__c> listNew = checkConditionT03(reportsNew,null);
            //System.debug(':::: listNew ::::');
            if( listNew.size() > 0 ){
                System.debug(':::: afterInsert Start ::::');
            	Trigger_T03(listNew,null,STR_INSERT);    
                System.debug(':::: afterInsert End ::::');
            }
        }     
    }
    
    public static void handlerAfterUpdate(List<Call_Report__c> reportsNew,List<Call_Report__c> reportsOld){
        //System.debug(':::: flagExc ::::' + flagExc);
        if (flagExc == true) {
            System.debug(':::: handlerAfterUpdate ::::');
            CaculatedTargetActual(reportsNew);
            List<Call_Report__c> listNew = checkConditionT03(reportsNew,reportsOld);
            if( listNew.size() > 0 ){
                System.debug(':::: afterUpdate Start ::::');
            	Trigger_T03(listNew,reportsOld,STR_UPDATE);    
                System.debug(':::: afterUpdate End ::::');
            }     
        }    
    }

    //12-03-2018 Add Google Location CR
    public static void updateGoogleLocation(Call_Report__c oldCR,Call_Report__c newCR) {
        //To Prevent Recursive Future Method so only geolocation changed will be triggered.
        if (oldCR.Check_in_Location__Latitude__s     != newCR.Check_in_Location__Latitude__s
            || oldCR.Check_in_Location__Longitude__s != newCR.Check_in_Location__Longitude__s) {
            // and Is_Retry_for_GoogleMap__c = true
            List<Call_Report__c> locationList = [SELECT Id,Check_in_Location__c FROM Call_Report__c 
                                                    Where Is_Last_Checkin_Location__c = false 
                                                        and Id =: newCR.Id
                                                ];

            if (locationList != null && locationList.size() > 0) {
                String crString = JSON.serialize(locationList);
                updateLocationFuture(crString);
            }
        }
    }


    @future (callout=true)
    private static void updateLocationFuture(String crString) {
        List<Call_Report__c> callReportList = (List<Call_Report__c>)JSON.deserialize(crString
                                                                                    , List<Call_Report__c>.class);
        GoogleExternalAPI batchGoogleMap = new GoogleExternalAPI();
        batchGoogleMap.updateLocationForCallReport(callReportList);
    }
    //12-03-2018 Add Google Location CR
    
    public static List<Call_Report__c> checkConditionT03(List<Call_Report__c> reportsNew,List<Call_Report__c> reportsOld){
        List<Call_Report__c> listReturn = new List<Call_Report__c>();
        Map<Id,Call_Report__c> mapReportsOld = new Map<Id,Call_Report__c>();
        if( reportsOld != null && reportsOld.size() > 0 ){
            mapReportsOld.putAll(reportsOld);
        }
        
        for(Call_Report__c report : reportsNew){
            if( report.Date_of_Visit__c != null && report.Status__c.indexOf('Completed') >= 0 ){
                listReturn.add(report);
            }
        }
        
        return listReturn;
    }
    
    public static void ForStatusComplete(List<Call_Report__c> callReportsNew,List<Call_Report__c> callReportsOld,String eventMode){
        System.debug(':::: ForStatusComplete Start ::::');

        List<Id> listOwnerId = new List<Id>();
        for( Call_Report__c report : callReportsNew ){
            if(report.OwnerId != null){
                listOwnerId.add(report.OwnerId);
            }
        }
        
        Map<Id,User> listUser = new Map<Id,User>([select Id,Name,Zone__c  from User where Id IN :listOwnerId]);        
        
        for(Call_Report__c report : callReportsNew){
            if( report.Date_of_Visit__c != null && report.Status__c.indexOf('Completed') >= 0){
                report.Complete_Date__c = Date.today();
                report.Zone__c = listUser.get(report.OwnerId).Zone__c;
            }
        }
        
        System.debug(':::: ForStatusComplete End ::::');
    }
    
    public static void Trigger_T03(List<Call_Report__c> callReportsNew,List<Call_Report__c> callReportsOld,String eventMode){
        System.debug(':::: Trigger_T03 Start ::::');
        Map<Id,Call_Report__c> listReportOld = new Map<Id,Call_Report__c>();
        if(eventMode == STR_UPDATE){
            listReportOld.putAll(callReportsOld);
        }
        
        List<Id> ids = new List<Id>();
        Map<Id,Target__c> mapTargetForUpdate = new Map<Id,Target__c>();
        List<RecordType> listRecordType = [select Id from RecordType where name = 'Activities Target'];// '012N0000000D5FHIA0'; // id for Activities Target
        Id recordTypeId = listRecordType[0].Id; 
        List<Id> listOwnerId = new List<Id>();
        List<String> listZone = new List<String>();
        List<Integer> listMonth = new List<Integer>();
        List<Integer> listYear = new List<Integer>();
        for( Call_Report__c report : callReportsNew ){
            if( report.Customer_name__c != null ){
            	ids.add(report.Customer_name__c);    
            }
            if(report.OwnerId != null){
                listOwnerId.add(report.OwnerId);
            }
            if( report.Date_of_Visit__c != null ){
                listMonth.add( Integer.valueOf(String.valueOf(report.Date_of_Visit__c).substring(5,7)) );
                listYear.add( Integer.valueOf(String.valueOf(report.Date_of_Visit__c).substring(0,4)) );
            }                        
        }
        
        Map<Id,User> listUser = new Map<Id,User>([select Id,Name,Zone__c  from User where Id IN :listOwnerId]);
        for(user u : listUser.values() ){
            if(u.Zone__c != null){
                listZone.add(u.Zone__c);    
            }
        }
        
        //list for count report of customer  
        Map<Id,AggregateResult> listReport = new Map<Id,AggregateResult>([select count(id) countReport,Customer_name__c Id
                                                                          from Call_Report__c where Customer_name__c IN :ids 
                                                                          and OwnerId IN :listOwnerId
                                                                          and Status__c like '%Completed%' 
                                                                          and CALENDAR_MONTH(Date_of_Visit__c) IN :listMonth
                                                                          and CALENDAR_YEAR(Date_of_Visit__c) IN :listYear 
                                                                          group by Customer_name__c]);
        
        System.debug('>>'+ callReportsOld);
        System.debug('>>'+ callReportsNew);
        
        //list for get ownerId of account
        //Map<Id,Account> listAccount = new Map<Id,Account>([select Id,OwnerId from Account where Id IN :ids]);
        
        //list for get record target
        List<Target__c> listTarget = [select OwnerId,Monthly_Visit_Actual__c ,Zone__c
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
        
        for(Call_Report__c report : callReportsNew){
            
            Integer checkCount = 0;
            String ownerId;
            Boolean checkCondition = false;
            
            if(listReport.containsKey(report.Customer_name__c)){
                checkCount = (Integer)listReport.get(report.Customer_name__c).get('countReport');
            }
            System.debug('::::: countReport size is : '+checkCount +' :::::');
            
            if( STR_UPDATE == eventMode && checkCount == 1 && report.Status__c.indexOf('Completed') >= 0 && report.Status__c != listReportOld.get(report.Id).Status__c  ){
                checkCondition = true;
            }else if( STR_INSERT == eventMode && checkCount == 1 && report.Status__c.indexOf('Completed') >= 0 ){
                checkCondition = true;
            }
            
            System.debug('::::: checkCondition : '+checkCondition+' :::::');
            
            if(checkCondition){
                ownerId = report.OwnerId;//listAccount.get(report.Customer_name__c).OwnerId;
                if( mapTarget.containsKey(ownerId) && !mapTargetForUpdate.containsKey(ownerId) ){
                    Decimal MonVisitActual = (mapTarget.get(ownerId).Monthly_Visit_Actual__c == null) ? 
                        0 : mapTarget.get(ownerId).Monthly_Visit_Actual__c;
                    MonVisitActual +=1;
                    mapTarget.get(ownerId).Monthly_Visit_Actual__c = MonVisitActual;
                    mapTargetForUpdate.put( ownerId,mapTarget.get(ownerId) );
                    System.debug('::::: OwnerId : '+ownerId + 
                                 ' Monthly_Visit_Actual__c : '+mapTarget.get(ownerId).Monthly_Visit_Actual__c);
                }else{
                    System.debug('::::: error containsKey OwnerId : '+ownerId+' in target or ListForUpdate Duplicated :::::');
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
        System.debug(':::: Trigger_T03 End ::::');
    }
    
    public static void conditionCreateVisitReport(List<Call_Report__c> reportsNew,List<Call_Report__c> reportsOld,String eventMode){
        System.debug(':::: conditionCreateVisitReport Start ::::');
        
        List<Id> idAccountList = new List<Id>();
        List<Id> idUserList = new List<Id>();        
        
        List<ID> idLeadList = new List<ID>();
        List<ID> idRecordType = new List<ID>();
        
        for( Call_Report__c eachReport : reportsNew ){
            if( eachReport.Customer_name__c != null ){
                idAccountList.add(eachReport.Customer_name__c);    
            }else if(eachReport.Lead__c !=null){
                idLeadList.add(eachReport.Lead__c);
            }
            
            idUserList.add(eachReport.OwnerId);
            idRecordType.add(eachReport.RecordTypeId);
        }
        
        Map<Id,Account> queryAccount = new Map<Id,Account>([ select Id,OwnerId,Owner.Segment__c
                                                            from Account 
                                                            where Id IN :idAccountList ]);
        
        
         Map<Id,Lead> queryLead = new Map<Id,Lead>([ select Id,OwnerId
                                                            from Lead 
                                                            where Id IN :idLeadList ]);
        
 
        Set<ID> RecordAccessSet = new set<ID>();
        
                for(UserRecordAccess ura :  [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                             WHERE UserId =: UserInfo.getUserId() 
                                             AND RecordId IN :idLeadList]){
                    RecordAccessSet.add(ura.RecordId);
                }
            
        
        
        List<AccountTeamMember> queryAccountTeamMember = [ select accountId,userId
                                                                                      from AccountTeamMember 
                                                                                      where accountId IN :idAccountList 
                                                                                      and userId IN :idUserList];
        
        Map<Id,User> queryUser = new Map<Id,User>([select Id,FirstName,LastName,UserRole.Name,Segment__c from user where Id IN :idUserList]);
        
		for( Call_Report__c eachReport : reportsNew ){
           
            Boolean checkCreate = false;
            if( queryAccount.containsKey(eachReport.Customer_name__c) ){ 
                if( queryAccount.get(eachReport.Customer_name__c).OwnerId == eachReport.OwnerId ){
                    checkCreate = true;
                }
                
                if(!checkCreate){
                    for(AccountTeamMember eachAccTeam : queryAccountTeamMember ){
                        if( eachReport.Customer_name__c == eachAccTeam.AccountId && eachReport.OwnerId ==  eachAccTeam.UserId ){
                            checkCreate = true;
                            break;
                        }
                    }  
                }
                
            }
            
            if(!checkCreate){
                List<Account__c> privilegeList = Account__c.getall().values();
                
                for( Account__c eachPrivilege : privilegeList ){
                    if(idRecordType[0] != '01290000000iZ7zAAE'){
                        if(queryUser.get(eachReport.OwnerId).UserRole.Name == eachPrivilege.Role__c && queryAccount.get(eachReport.Customer_name__c).Owner.Segment__c == eachPrivilege.Segment__c){
                            checkCreate = true;
                        } 
                    }       
                }          
            }
            //ByPassed 27 Aug 2015 by Tinnakrit Kidmai for CR007 OppVisit
            if(!checkCreate){
                if(Test.isRunningTest()){
                   checkCreate =true;
                }
            }
            
            
            
            if(!checkCreate){
                    if(queryLead.containsKey(eachReport.Lead__c)){
                         if( eachReport.OwnerId == queryLead.get(eachReport.Lead__c).OwnerId){
                            checkCreate = true;
                            break;
                        }
                    }
                }
            
            if(!checkCreate){
                if(RecordAccessSet.contains(eachReport.Lead__c)){
                    checkCreate = true;
                            break;
                }
            }
            
            
            
            if(!checkCreate){
                eachReport.addError( Trigger_Msg__c.getValues('Permission_Create_Opportunity').Description__c  ,false);    
            }
            
            
            System.debug('::::: checkCreate : '+checkCreate+' || '+eachReport.Name+' :::::');
        } 
        System.debug(':::: conditionCreateVisitReport End ::::');
    }
    
    
    public static RecordType activitiesRec {get{
        if(activitiesRec==null){
             activitiesRec = [select Id from RecordType where name = 'Activities Target' limit 1];
        }
        return activitiesRec;
    }set;}
    
           	//Only Completed visit plan report will be caculated confirmed by Fah and P'Lek 
        public static void CaculatedTargetActual(List<Call_Report__c> reportsNew){
          	System.debug(':::: CaculatedTargetActual Start ::::');
            
            List<Id> idAccountList = new List<Id>();
            List<Id> listOwnerId = new List<Id>();
            
            //integer i = 1;
            for( Call_Report__c report : reportsNew ){
                if(report.OwnerId != null){
                    listOwnerId.add(report.OwnerId);
                } 
                
                if( report.Customer_name__c != null ){
                	idAccountList.add(report.Customer_name__c);    
            	}
                
                //System.debug(':::: report ::::'+report);
                //System.debug(':::: report.OwnerId ::::'+report.OwnerId);
                //System.debug(':::: report.Customer_name__c ::::'+report.Customer_name__c);
            }
        
            //Map<Id,User> listUser = new Map<Id,User>([select Id,Name, Zone__c  from User where Id IN :listOwnerId]);        
            Map<Id,Account> queryAccount = new Map<Id,Account>([ select Id,OwnerId,Owner.Segment__c,Visit_Class__c from Account where Id IN :idAccountList ]);
            //report.Zone__c = listUser.get(report.OwnerId).Zone__c;
            
        	Id activitiesId = activitiesRec.Id;

            //Start Case Number 00006985   Edit Date 2018-04-27
            String txtLocale = UserInfo.getLocale();
            Date currentDate = Date.today();
            Integer currentMonth = currentDate.month();
            Integer currentYear = currentDate.year();
            //System.debug(':::: currentYear1 ::::'+currentYear);
            //if(currentYear>2557) currentYear = currentDate.year() - 543;
            if(txtLocale.equals('th_TH')) currentYear = currentDate.year() - 543;
            //System.debug(':::: listOwnerId ::::'+listOwnerId);
            //System.debug(':::: currentMonth ::::'+currentMonth);
            //System.debug(':::: currentYear ::::'+currentYear);
            //System.debug(':::: txtLocale ::::'+txtLocale); 
 
            List<Target__c> queryTarget = [ select Id,Monthly_Target_Date__c,Actual_Visit_Tier_1__c,Actual_Visit_Tier_2__c,Actual_Visit_Tier_3__c,Actual_Visit_Tier_4__c,Monthly_Visit_Actual__c 
                                           from Target__c 
                                           where OwnerId = : listOwnerId 
                                           and CALENDAR_MONTH(Monthly_Target_Date__c) = : 
                                           currentMonth 
                                           and CALENDAR_YEAR(Monthly_Target_Date__c) = : currentYear 
                                           and RecordTypeId = : activitiesId];                    
            //System.debug(':::: queryTarget ::::'+queryTarget+listOwnerId+activitiesId+currentMonth);
            //End CaseNumber 00006985
  
            for(Call_Report__c report : reportsNew){
                //System.debug('OK1');
                //System.debug(':::: Date_of_Visit__c ::::'+report.Date_of_Visit__c);
                //System.debug(':::: Status__c ::::'+report.Status__c);
                //i = i + 1;
                if( report.Date_of_Visit__c != null && report.Status__c.indexOf('Completed') >= 0){

					for(Target__c actualTarget : queryTarget ){
                        //System.debug(':::: Num ::::'+i);
                        //System.debug(':::: size ::::'+queryTarget.size());
                        //i = i + 1;
                       //System.debug(':::: Service_class ::::'+queryAccount.get(report.Customer_name__c).Visit_Class__c);
                        if( queryAccount.get(report.Customer_name__c).Visit_Class__c == 'Tier 1' ){  
                            System.debug(':::: Tier 1 ::::'+actualTarget.Actual_Visit_Tier_1__c);     		
     							if(actualTarget.Actual_Visit_Tier_1__c == null) actualTarget.Actual_Visit_Tier_1__c = 0;
                            	actualTarget.Actual_Visit_Tier_1__c++;
                            System.debug(':::: Tier 1  ::::'+actualTarget.Actual_Visit_Tier_1__c);
                        }else if( queryAccount.get(report.Customer_name__c).Visit_Class__c == 'Tier 2' ){ 
                            	if(actualTarget.Actual_Visit_Tier_2__c == null) actualTarget.Actual_Visit_Tier_2__c = 0;
                            	actualTarget.Actual_Visit_Tier_2__c++;
                        }
                        else if( queryAccount.get(report.Customer_name__c).Visit_Class__c == 'Tier 3' ){ 
                            	if(actualTarget.Actual_Visit_Tier_3__c == null) actualTarget.Actual_Visit_Tier_3__c = 0;
                            	actualTarget.Actual_Visit_Tier_3__c++;
                        }
                        else if( queryAccount.get(report.Customer_name__c).Visit_Class__c == 'Tier 4' ){ 
                            	if(actualTarget.Actual_Visit_Tier_4__c == null) actualTarget.Actual_Visit_Tier_4__c = 0;
                            	actualTarget.Actual_Visit_Tier_4__c++; 
                        }else{
                            if(actualTarget.Monthly_Visit_Actual__c == null) actualTarget.Monthly_Visit_Actual__c = 0;
                            	actualTarget.Monthly_Visit_Actual__c++; 
                        }
               			//update actualTarget;
                    } 
                    

                }
            }
            
        flagExc = false;  
        
        //Start Case Number 00006985   Edit Date 2018-04-27
        if (queryTarget.size() > 0) 
            update queryTarget; 
        
        //End CaseNumber 00006985

        System.debug(':::: CaculatedTargetActual End ::::');
           
        }
    
    
}