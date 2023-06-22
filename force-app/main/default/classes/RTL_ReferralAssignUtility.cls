//////////////////////////////////////
    // RTL_ReferralAssignUtility is an utility class to do referral assignment.
//////////////////////////////////////
global without sharing class RTL_ReferralAssignUtility {
    private static String KEY_ISNULL   = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_ISNULL') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_ISNULL').Value__c : 'IS NULL';

    private static String KEY_NOT_NULL = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_NOTNULL') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_NOTNULL').Value__c : 'IS NOT NULL';

    private static String FOR_SE = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_SE') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_SE').Value__c : 'SE : <100 MB';

    
    private static String FOR_BB = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_BB') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_BB').Value__c : 'BB : 100-1,000 MB';

    
    private static String FOR_CB = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_CB') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_CB').Value__c : 'CB : 1,001-5,000 MB';
    
    private static String FOR_MB = 
                            AppConfig__c.getValues('RTL_Referral_Assignment_MB') != null ?
                            AppConfig__c.getValues('RTL_Referral_Assignment_MB').Value__c : 'MB : >5,000 MB';

    private static List<Group> queueList = [ select Id,Name,DeveloperName from Group where Type = 'Queue' ];
    private static Map<Id,Branch_and_Zone__c> branchAndZoneList = new Map<Id,Branch_and_Zone__c>();
    private static Map<String,RTL_Referral_Default_Assignment__mdt> mapDefaultAssignmentList 
                    = new Map<String,RTL_Referral_Default_Assignment__mdt>();
                    
    private static Map<Id,User> mapUserInActiveList = new Map<Id,User>();


    private static List<String> branchAndZone = new List<String>();
    private static List<Id> recordtypeIdList = new List<Id>();
    private static List<String> recordtypeDevNameList = new List<String>();
    private static Map<String,RecordType> mapRecordTypeByDevName = new Map<String,RecordType>();   

    private static Map<Id,Id> mapRTLAssignmentByRecordTypeId = new Map<Id,Id>();
    private static Map<Id,RTL_Referral_Assignment__c> mapRTLAssignment = new Map<Id,RTL_Referral_Assignment__c>();
    private static List<String> assignUserIdList = new List<String>();


    private static Map<Id,Id> oldOwnerIdMap = new Map<Id,Id>();

    //CR Refer from branch to any channel
    private static BusinessHours callMeNowBusinessHours{
        get{
            if(callMeNowBusinessHours == null ){
                String bhName;
                AppConfig__c cf = AppConfig__c.getValues('CallMeNowBH');
                bhName = (cf == null ? 'Call Me Now' : cf.Value__c);
                List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours WHERE Name =: bhName];
                if(businessHours.size() > 0){
                    callMeNowBusinessHours = businessHours[0];
                }
                
            }
            return callMeNowBusinessHours;

        }set;
    }

    public static Integer SLATime{
        get{
            if(SLATime == null ){
                Integer slaT;
                AppConfig__c cf = AppConfig__c.getValues('SLATime');
                slaT = (cf == null ? 1 : (cf.Value__c == null ? 1 : integer.valueof(cf.Value__c)));

                SLATime = slaT;
                
            }
            return SLATime;

        }set;
    }

    public RTL_ReferralAssignUtility(ApexPages.StandardController stdController){}

    //doReferralReassign is called by RTL_ReferralReassingment_Page.page in order to do reassign rules
    @RemoteAction
    global static RTL_Referral__c doReferralReassign(Id ReferralId) {
        List<Id> refListId = new List<Id>();
        refListId.add(ReferralId);

        doReferralReassignIdList(refListId,true);

        return [SELECT Id
                        ,Owner.Name
                        ,OwnerId
                FROM RTL_Referral__c 
                Where Id = : ReferralId];
    }

    //getReferralReassign is called by RTL_ReferralReassingment_Page.page in order to query info about this referral will be reassigned to whom.
    @RemoteAction
    global static String getReferralReassign(Id ReferralId) {
        List<Id> refListId = new List<Id>();
        refListId.add(ReferralId);

        List<RTL_Referral__c> refList 
                = doReferralReassignIdList(refListId,false);

        if (mapRTLAssignmentByRecordTypeId != null 
            && mapRTLAssignmentByRecordTypeId.size() > 0
            && refList != null && refList.size() > 0) {
            RTL_Referral__c ref = refList.get(0);
            //get old owner id
            Id oldOwnerId = oldOwnerIdMap.get(ref.Id);

            if (oldOwnerId != ref.OwnerId && ref.OwnerId != null) return getReferralOwnerName(ref.OwnerId);
        }

        return null;
    }

    public static List<RTL_Referral__c> doReferralReassignIdList(List<Id> refListId,Boolean isUpdate) {
        return doReferralReassigns(new Set<Id>(refListId),isUpdate);
    }

    public static List<RTL_Referral__c> doReferralReassigns(Set<Id> refListId,Boolean isUpdate) {
        /*List<RTL_Referral__c> refList = [SELECT Id
                                                ,RecordTypeId
                                                ,RTL_Preferred_Branch__r.Name
                                                ,RTL_Account_Name__c
                                                ,RTL_Sales_Amount_Per_Year__c
                                                ,RTL_RM_Owner__c
                                                ,RTL_Owner_Role__c
                                                ,RTL_Phone1__c
                                                ,RTL_RM_Owner_Id__c
                                                ,RTL_Wealth_RM_Id__c
                                                ,Owner.Name
                                                ,OwnerId,RTL_Preferred_Branch__c,RTL_Preferred_Branch_Name__c
                                         FROM RTL_Referral__c 
                                         Where Id in : refListId];*/
        
        String objectName = 'RTL_Referral__c';
        String strQuery = 'select ';
        strQuery += RTL_Utility.queryAllField(objectName);
        strQuery = strQuery.substring(0,strQuery.length()-1);
        String strWhere = ' WHERE Id in :refListId';
        strQuery += ' from '+objectName;
        strQuery += strWhere;
        
        List<RTL_Referral__c> refList = Database.query(strQuery);     
           
        if (refList.size() > 0) {
            doReferralReassign(refList);

            if (isUpdate)
                do_partial_update(refList);
        }

        return refList;
    }
	@TestVisible
    private static String getReferralOwnerName(Id ownerId) {
        Schema.SObjectType objType = ownerId.getSObjectType();
        Schema.DescribeSObjectResult dr = objType.getDescribe();
        String queryString = 'SELECT Id,Name FROM ' + dr.getName() +' WHERE Id = \''+ownerId+'\'';
        sObject[] objDBList = Database.query(queryString);

        if (objDBList != null && objDBList.size() > 0) {
            return (String)objDBList.get(0).get('Name');
        }

        return null;
    }
    
    private static void do_partial_update(List<RTL_Referral__c> refList) {
        Database.SaveResult[] refRetList = Database.update(refList, false);
        for(integer i = 0; i < refList.size() ; i++){
            Database.SaveResult sr = refRetList[i];
            if (!sr.isSuccess()) {
                //System.debug(sr.getErrors());
            }
        }
        
    }

   
    private static void doReferralReassign(List<RTL_Referral__c> refList) {
        //set Referral's Record Type and Referral's PreferBranch
        setRecordTypeAndPreferredBranch(refList);

        //set AssignedUserId based on Referral assignment rules and filter RTL_Reassign_Flag__c = True
        setAssignedUserIdList(refList,true);

        if( mapRTLAssignmentByRecordTypeId.size() > 0 ){            
            mapUserInActiveList = getUserList(assignUserIdList);
            for( User u : mapUserInActiveList.values() ){
                branchAndZone.add( u.RTL_Branch_Code__c );
            }
            
            //create map meta default Assignment
            for( RTL_Referral_Default_Assignment__mdt each : getMetaDefaultAssignment() ){
                mapDefaultAssignmentList.put(each.Referral_record_type__c,each);
            }
            
            // create map branch and zone
            for( Branch_and_Zone__c each : getBranchAndZone(branchAndZone) ){
                branchAndZoneList.put(each.Id,each);
            }
                        
            for( RTL_Referral__c each : refList ){         
                //add old owner id
                oldOwnerIdMap.put(each.Id,each.OwnerId);       

                for( RTL_Referral_Assignment__c eachCond : mapRTLAssignment.values() ){
                    if( each.RecordTypeId == mapRTLAssignmentByRecordTypeId.get(eachCond.Id) ){
                        // if is true Assgin Owner
                        if( checkCriteria2(each, eachCond) ){
                            try{                              
                                each.OwnerId = assignOwner(each,eachCond);    
                                
                                // meta default assignment
                                if( each.OwnerId == null || mapUserInActiveList.containsKey(each.OwnerId) ){
                                    each.OwnerId = assignDefault( each,eachCond );
                                }
                                //set Is_Send_Email__c = true to active Change owner notification Workflow
                                each.Is_Send_Email__c = true;
                                break;
                            }catch( Exception e ){
                                System.debug('error : '+e.getMessage());
                                each.addError('error default assign : '+e.getMessage() );                                
                            }                        
                        }   
                    }
                }
            }
        }
    }
    
    public static CallMeNowDTO doCallService(String referralId, String name, String firstName, String lastName, String interestedProduct, String mobile, String campaign, String subProduct, String channel, String wrapUp, String referralRecordTypeName, String rtlDateTime, Map<String, String> variable){
        CallMeNowDTO callMeNowObj = new CallMeNowDTO();
        DateTime now = System.now();
        String strDateTime;
       
        //CR Refer from branch to any channel

        if(rtlDateTime != '' && rtlDateTime != null){
            strDateTime = rtlDateTime;
        }/*
        SCR0571676 - Referral send to Call Me Now  Edit by ttb Todsapol J. Deploy 19-Jan 2023
        else if (referralRecordTypeName == 'Retail Cross Channel Referral') {
            strDateTime = getNextnBSDate().addHours(7).formatGMT('yyyy-MM-dd HH:mm');
        }*/else{
            strDateTime = now.format('yyyy-MM-dd HH:mm');
        }

        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String consoleURL = '/ui/support/servicedesk/ServiceDeskPage#';

        callMeNowObj.request.setRequestId(referralId);
        callMeNowObj.request.setFirstName(firstName);
        callMeNowObj.request.setLastName(lastName);
        callMeNowObj.request.setProductName(interestedProduct);
        callMeNowObj.request.setMobile(mobile);
        callMeNowObj.request.setCampaign(campaign);
        callMeNowObj.request.setDropLeadDateTime(strDateTime);//'2017-05-18 18:00';
        
        callMeNowObj.request.setVar1(subProduct);
        callMeNowObj.request.setVar2(name);
        callMeNowObj.request.setVar3(variable.get('3'));
        callMeNowObj.request.setVar4(variable.get('4'));
        callMeNowObj.request.setVar5(variable.get('5'));
        callMeNowObj.request.setVar6(variable.get('6'));

        callMeNowObj.request.setURL(sfdcBaseURL+'/'+referralId);
        callMeNowObj.request.setChannel(channel);
        callMeNowObj.request.setRequiredWrapUp(wrapUp);
        
        CallMeNowService.basicAuthCallout(callMeNowObj,name);
        return callMeNowObj;
    }

    public static List<Branch_and_Zone__c> getBranchAndZone(List<String> idList){
        return (List<Branch_and_Zone__c>)queryBranchAndZone(idList);
    }
    
    private static List<SObject> queryBranchAndZone(List<String> IdList){
        try{            
            String objectName = 'Branch_and_Zone__c';
            String strQuery = 'select ';
            strQuery += RTL_Utility.queryAllField(objectName);
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where Id IN :IdList OR Branch_Code__c IN :idList ';
            strQuery += ' from '+objectName;
            strQuery += strWhere;
            return Database.query(strQuery);
            
        }catch(QueryException e){
            return new List<SObject>();  
        }
    }
    
    public static List<RTL_Referral_Default_Assignment__mdt> getMetaDefaultAssignment(){
        return (List<RTL_Referral_Default_Assignment__mdt>)queryMetaDefaultAssignment();
    }
    
    private static List<SObject> queryMetaDefaultAssignment(){
        try{            
            String objectName = 'RTL_Referral_Default_Assignment__mdt';
            String strQuery = 'select ';
            strQuery += RTL_Utility.queryAllField(objectName);
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' ';
            strQuery += ' from '+objectName;
            strQuery += strWhere;
            return Database.query(strQuery);
            
        }catch(QueryException e){
            return new List<SObject>();  
        }
    }

    public static Map<Id,User> getUserList(List<String> idList){
        return getUserList(idList,false);
    }

    
    public static Map<Id,User> getUserList(List<String> idList,Boolean isActive){
        return new Map<Id,User>( [ select Id,RTL_Branch_Code__c 
                                    from User where Id IN 
                                    :idList and IsActive =: isActive ] );
    }
    
    private static List<SObject> queryConditionRTLAssignment(List<String> recordtypeDevNameList
                                                            ,Boolean isReassignment){
        try{            
            String objectName = 'RTL_Referral_Assignment__c';
            String strQuery = 'select ';
            strQuery += RTL_Utility.queryAllField(objectName);
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where RTL_Reassign_Flag__c ='+isReassignment
                                +' and RTL_Active_Flag__c = true and RTL_Referral_Type__c IN :recordtypeDevNameList order by RTL_Referral_Type__c,RTL_Priority__c asc ';
            strQuery += ' from '+objectName;
            strQuery += strWhere;
            return Database.query(strQuery);
            
        }catch(QueryException e){
            return new List<SObject>();  
        }
    }

    public static Boolean checkCriteria2(RTL_Referral__c data,RTL_Referral_Assignment__c cond){
        Boolean criteriaPass = false;
        Boolean criteriaNotNull = false;
        if( RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_1__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_2__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_3__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_4__c) 
           || RTL_Utility.isNotNull(cond.RTL_Referral_Field_Criteria_5__c) ){
               criteriaNotNull = true;
           }


        if( criteriaNotNull && 
            (
               checkCondition2(cond.RTL_Referral_Field_Criteria_1__c,
                               data,
                               cond.RTL_Referral_Field_Value_1__c) 
               && checkCondition2(cond.RTL_Referral_Field_Criteria_2__c,
                               data,
                               cond.RTL_Referral_Field_Value_2__c) 
              && checkCondition2(cond.RTL_Referral_Field_Criteria_3__c,
                               data,
                               cond.RTL_Referral_Field_Value_3__c)
              && checkCondition2(cond.RTL_Referral_Field_Criteria_4__c,
                               data,
                               cond.RTL_Referral_Field_Value_4__c)
              && checkCondition2(cond.RTL_Referral_Field_Criteria_5__c,
                               data,
                               cond.RTL_Referral_Field_Value_5__c)
              )
          ){
            criteriaPass = true;           
        }

       return criteriaPass;
    }
    
    public static Boolean checkCondition2(String cond,SObject data,String condValue){
        if( cond == null || cond == '' ){
            return true;
        }
        System.debug(data.get(cond)+'== equal to'+condValue);
        if( condValue == KEY_NOT_NULL ){
            if( String.valueOf(data.get(cond)) != '' && String.valueOf(data.get(cond)) != null ){
                return true;    
            }    
        }

        if( condValue == KEY_ISNULL ){
            condValue = null;

            if( String.valueOf(data.get(cond)) != condValue ){
                return false;    
            }else {
                return true;
            }
        }   

        if (condValue.replace(' ','') == FOR_SE.replace(' ','')
            && String.valueOf(data.get(cond)) == String.valueOf(FOR_SE)) {
            return true;
        }

        if (condValue.replace(' ','') == FOR_BB.replace(' ','')
            && String.valueOf(data.get(cond)) == String.valueOf(FOR_BB)) {
            return true;
        }

        if (condValue.replace(' ','') == FOR_CB.replace(' ','')
            && String.valueOf(data.get(cond)) == String.valueOf(FOR_CB)) {
            return true;
        }

        if (condValue.replace(' ','') == FOR_MB.replace(' ','')
            && String.valueOf(data.get(cond)) == String.valueOf(FOR_MB)) {
            return true;
        }
        
        if( String.valueOf(data.get(cond)) == condValue ){
        	return true;    
        }
        return false;
    }

    //for set and assign methods
    public static void setRecordTypeAndPreferredBranch(List<RTL_Referral__c> newList) {

        for( RTL_Referral__c each : newList ){
            // get record type
            if( each.RecordTypeId != null ){
                recordtypeIdList.add(each.RecordTypeId);
            }
            if( each.RTL_Preferred_Branch__c != null ){
                branchAndZone.add(each.RTL_Preferred_Branch__c);
            }
        }

        // create map branch and zone
        for( Branch_and_Zone__c each : getBranchAndZone(branchAndZone) ){
            branchAndZoneList.put(each.Id,each);
        }

        // get record type developer name of referral
        for( RecordType each : RTL_Utility.getRecordTypeById(recordtypeIdList).Values() ){
            recordtypeDevNameList.add(each.DeveloperName);
            mapRecordTypeByDevName.put(each.DeveloperName,each);
        }
    }

    public static void setAssignedUserIdList(List<RTL_Referral__c> newList,Boolean isReassign) {
        List<RTL_Referral_Assignment__c> refAssignList 
                                = queryConditionRTLAssignment(recordtypeDevNameList
                                                            ,isReassign
                                                            );


                                            
        for( RTL_Referral_Assignment__c each : refAssignList){
            Id recordTypeId = mapRecordTypeByDevName.get(each.RTL_Referral_Type__c).Id;
            mapRTLAssignmentByRecordTypeId.put(each.Id,recordTypeId );   
            mapRTLAssignment.put(each.Id,each);
            
            if( RTL_Utility.isNotNull(each.RTL_Assigned_User__c) ){
                assignUserIdList.add( each.RTL_Assigned_User__c );    
            }
            if( RTL_Utility.isNotNull(each.RTL_Default_User__c) ){
                assignUserIdList.add( each.RTL_Default_User__c );                 
            }
            for( RTL_Referral__c rfr : newList ){
                try{
                    if( RTL_Utility.isNotNull(each.RTL_Assigned_User_field__c) ){
                        assignUserIdList.add( String.valueOf(rfr.get(each.RTL_Assigned_User_field__c)) );    
                    }
                    if( RTL_Utility.isNotNull(each.RTL_Branch_and_Zone_Queue_User_field__c) ){
                        if( branchAndZoneList.containsKey( rfr.RTL_Preferred_Branch__c ) ){      
                            assignUserIdList.add( String.valueOf(branchAndZoneList.get( rfr.RTL_Preferred_Branch__c ).get(each.RTL_Branch_and_Zone_Queue_User_field__c)) );   
                            //assignUserIdList.add( String.valueOf(rfr.get(each.RTL_Branch_and_Zone_Queue_User_field__c)) );   
                        } 
                    }                    
                }catch( Exception e ){
                    System.debug('error : '+e.getMessage()+' '+e.getLineNumber()+' '+e.getStackTraceString());
                }  
            }     
        }
    }


    public static Id assignOwner( RTL_Referral__c data
                                 ,RTL_Referral_Assignment__c cond){

        String tempOwner = null;
        // 1.1
        if( RTL_Utility.isNotNull(cond.RTL_Assigned_User__c) ){         
            tempOwner = cond.RTL_Assigned_User__c;
            if( !mapUserInActiveList.containsKey(tempOwner) ){
                 return tempOwner;
            }          
        }
        
        // 1.2
        if( RTL_Utility.isNotNull(cond.RTL_Assigned_User_field__c) ){
            tempOwner = String.ValueOf(data.get(cond.RTL_Assigned_User_field__c));

            if( !mapUserInActiveList.containsKey(tempOwner) && tempOwner != null ){
                System.debug('tempOwner active:'+tempOwner);
                return tempOwner; 
            }
        }
        
        // 2.1
        if( RTL_Utility.isNotNull(cond.RTL_Assigned_Queue_Name__c) ){
            for( Group q : queueList ){
                if( q.DeveloperName == cond.RTL_Assigned_Queue_Name__c ){
                    return q.Id;    
                }
            }           
        }
        
        // 2.2
        if( RTL_Utility.isNotNull(cond.RTL_Branch_and_Zone_Queue_User_field__c) ){
            if( branchAndZoneList.containsKey( data.RTL_Preferred_Branch__c ) ){
                tempOwner = String.ValueOf(branchAndZoneList.get( data.RTL_Preferred_Branch__c ).get( cond.RTL_Branch_and_Zone_Queue_User_field__c ));
                if(tempOwner != null){
                    for( Group q : queueList ){
                        if( q.DeveloperName == tempOwner ){
                            return q.Id;    
                        }    
                    }
                    //need to check because tempOwner could be Develop_Name not User ID
                    if( !mapUserInActiveList.containsKey( tempOwner ) ){
                        return tempOwner;  
                    }
                    
                }
                              
            }                       
        }
        
        // 3.1
        if( RTL_Utility.isNotNull(cond.RTL_Default_Queue_Name__c) ){
            for( Group q : queueList ){
                if( q.DeveloperName == cond.RTL_Default_Queue_Name__c ){
                    return q.Id;    
                }
            }
        }
        
        // 3.2
        if( RTL_Utility.isNotNull(cond.RTL_Default_User__c) ){
            tempOwner = cond.RTL_Default_User__c;
            if( !mapUserInActiveList.containsKey( tempOwner ) ){
                return tempOwner;    
            }
        }
        System.debug('Map User Inactive '+mapUserInActiveList);
        // 3.3
        if( cond.RTL_Default_For_BM__c && mapUserInActiveList.containsKey(tempOwner) && tempOwner != null ){
            System.debug('detect inactive');
            return assignForBM( tempOwner, cond );    
        }

        //3.4  -- CR RQ-014 to be able to default to queue/user from referral preferred branch
        if(RTL_Utility.isNotNull(cond.RTL_Default_Branch_Zone_Queue_User_field__c) ){
            if( branchAndZoneList.containsKey( data.RTL_Preferred_Branch__c ) ){
                tempOwner = String.ValueOf(branchAndZoneList.get( data.RTL_Preferred_Branch__c ).get( cond.RTL_Default_Branch_Zone_Queue_User_field__c ));
                if(tempOwner != null){
                    for( Group q : queueList ){
                        if( q.DeveloperName == tempOwner ){
                            return q.Id;    
                        }    
                    }
                    if( !mapUserInActiveList.containsKey( tempOwner ) ){
                        return tempOwner;  
                    }
                    
                }
                              
            }                       
        }
        
        return null;
    }
    
    public static String assignForBM(String data,RTL_Referral_Assignment__c cond){
        for( Branch_and_Zone__c each : branchAndZoneList.values() ){
            //System.debug('map inactive '+mapUserInActiveList.get(data.OwnerId));
            //System.debug('owner id '+data.OwnerId);
            if( each.Branch_Code__c == mapUserInActiveList.get(data).RTL_Branch_Code__c ){
                for( Group q : queueList ){
                    if( q.DeveloperName == each.Branch_Queue_Name__c ){
                        return q.Id;    
                    }    
                }
            }
        }
        return null;
    }
    
    public static String assignDefault(RTL_Referral__c data,RTL_Referral_Assignment__c cond){
        if( mapDefaultAssignmentList.containsKey(cond.RTL_Referral_Type__c) ){
            String defaultQueueName = mapDefaultAssignmentList.get(cond.RTL_Referral_Type__c).Default_Queue_Name__c;    
            for( Group q : queueList ){
                if( q.DeveloperName == defaultQueueName ){
                    return q.Id;    
                }
            }    
        }
        return null;
    }

    public static void setUserInActiveList(Map<Id,User> inMapUserInActiveList){
        mapUserInActiveList = inMapUserInActiveList;
    }

    public static void setDefaultAssignmentList(Map<String,RTL_Referral_Default_Assignment__mdt> inMapDefaultAssignmentList){
        mapDefaultAssignmentList = inMapDefaultAssignmentList;
    }

    public static void setBranchAndZoneList(Map<Id,Branch_and_Zone__c> inBranchAndZoneList){
        branchAndZoneList = inBranchAndZoneList;
    }
    //for set and assign methods

    //CR Flagship : 20 Dec 2018 : Add method to get channel-leadsource mapping
    public static Map<String,String> channelLeadSourceMap{
        get{
            if(channelLeadSourceMap == null){
                channelLeadSourceMap = new Map<String,String>();
                for(Referral_Channel_Leadsource_Mapping__mdt channelLeadSourceObj : [SELECT MasterLabel,Channel__c,Leadsource__c FROM Referral_Channel_Leadsource_Mapping__mdt]){
                    channelLeadSourceMap.put(channelLeadSourceObj.Channel__c,channelLeadSourceObj.Leadsource__c);
                }
                
            }
            return channelLeadSourceMap;
        }
        set;
    }

    public static Datetime getNextnBSDate(){
        Datetime now;
        if(SLATime == 0){
            now = System.now();
        }else{
            Date nowDate = System.now().adddays(SLATime).date();
            now = Datetime.newInstance(nowDate.year(), nowDate.month(), nowDate.day(), 1, 0, 0);
        }


        Datetime nextStart = BusinessHours.nextStartDate(callMeNowBusinessHours.id, now);
        return nextStart;
    }
}