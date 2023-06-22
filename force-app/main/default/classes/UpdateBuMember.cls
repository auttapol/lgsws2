public class UpdateBuMember implements Database.Batchable<sObject>{

    //private Boolean isInit = false;
    private Integer countRound;
    private Map<Id,Map<String,String>> mapQueueData;
    private set<Id> setQueueId;
    private Set<Id> setRoleId;
    private Set<Id> setRoleAndSubId;
    private Map<Id,Id> mapGroupIdRelatedId;
    private Map<Id,Id> mapGroupIdRelatedId_RS;
    private Set<Id> setGroupID; 
    private List<GroupMember> allMember;
    private Map<Id,List<Id>> mapParentRole;
    private Map<Id,String> mapQueueIdSupportObject;

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
 
        String RuntestQuery = 'SELECT Id,Name,Email,UserRoleId,UserRoleName__c,Employee_ID__c FROM User WHERE IsActive = true order by createddate desc limit 3';
        String StandardQuery = 'SELECT Id,Name,Email,UserRoleId,UserRoleName__c,Employee_ID__c FROM User WHERE IsActive = true order by UserRoleId asc';

        query = Test.isRunningTest()? RuntestQuery : StandardQuery; 
        return Database.getQueryLocator(query);
    }

    public void isInitialFirstRun(){
        mapQueueData = mapQueueData = new Map<Id,Map<String,String>>();
        setGroupID = new Set<Id>();
        setQueueId = new Set<Id>();                                 // set all queue
        setRoleId = new Set<Id>();                                  // set all Role
        setRoleAndSubId = new Set<Id>();                            // set all Role and Subordinates
        allMember = new List<GroupMember>();                        // List of All Group Member

        mapGroupIdRelatedId = new Map<Id,Id>();                     // Map<GroupId,RelatedId> for ROle
        mapGroupIdRelatedId_RS= new Map<Id,Id>();

        mapParentRole = new Map<Id,List<Id>>();                     //  Role&Sub <ParentRoleId, List of Child Role Id>

        mapQueueIdSupportObject = new Map<Id,String>();             // Map QueueIdSupportingObject

        countRound = 0;

        //isInit = true;
    }

    public void execute(Database.BatchableContext BC, List<User> scope){        
        isInitialFirstRun();

        //List<User> userList = [SELECT Id,Name,Email,UserRoleId,UserRoleName__c,Employee_ID__c FROM User WHERE IsActive = true];
        List<User> userList = scope;

        List<Group> initialGroup = [Select Id,Name,DeveloperName,Type,RelatedId,Email from Group where Type IN('Queue','Role','RoleAndSubordinates') order by type,DeveloperName];

        List<queueSobject> queueSupportObject = [SELECT Id,queueId,SobjectType FROM queueSobject];



        //List<Group> allGroup = new List<Group>();                   // list all Group
        
        List<GroupMember> memberQueue = new List<GroupMember>();    // list only Type 'Queue' Member
        List<GroupMember> memberRole = new List<GroupMember>();     // list only Type 'Role' Member
        List<GroupMember> memberRoleAndSub = new List<GroupMember>();  // list only Type 'RoleAndSubordinates' Member

        Map<Id,String> mapQueueName = new Map<Id,String>();      // na
        
        Map<String,String> tmpData = new Map<String,String>();

        Map<Id,String> mapUserWithQueue = new Map<Id,String>();  // na


        Map<Id,List<Id>> mapRoleIdUserId = new Map<Id,List<Id>>();  // Map<RoleId,List<UserId>>

        Map<Id, Map<String,List<Id>>> queueEmployee = new Map<Id, Map<String,List<Id>>>(); // { QueueId , {Type(User/RoleName/RoleSub),[User]}  }        
    
        List<BU_Member__c> upsertMember = new List<BU_Member__c>();

        List<Id> tmpUserId = new List<Id>();     // for temp assign to member
        List<Id> tmpUserId_2 = new List<Id>();   // for temp assign to member_2
        List<Id> tmpUserId_3 = new List<Id>();
        Map<Id,List<Id>> tmpMapRoleIdUserId = new Map<Id,List<Id>>();        // tmp
        Map<String,List<Id>> tmpMapId = new Map<String,List<Id>>(); //
        Map<Id, Map<String,List<Id>>> tmpQueueEmployee = new Map<Id, Map<String,List<Id>>>();

        // Variable for find subRole in Role&Subordinate //
        List<UserRole> list_role = [select Id,Name,ParentRoleId from UserRole]; // Role&Sub
        
        Map<Id,List<Id>> tmpMapParentRole = new Map<Id,List<Id>>();     //  Role&Sub
        List<Id> tmpChildRoleId = new List<Id>();                       //  Role&Sub
        Set<Id> tmpSetInit = new Set<Id>();

        // Variable for Queue SObject 
        
        Map<Id,String> tmpMapQueueIdSupportObject = new Map<Id,String>();
        String tmpString;

        // Variable for BU Member
        List<BU_Member__c> list_buMember = new List<BU_Member__c>();
        List<String> uniqueId = new List<String>();
        BU_Member__c tmpBuMember = new BU_Member__c();

        //User
        Map<Id,Map<String,String>> mapUserData = new Map<Id,Map<String,String>>();
        Map<String,String> tmpUserData = new Map<String,String>();

        // Map<Id,Map<String,String> mapQueueData = new Map<Id,<String,String>();
        // Map<String,String> tmpData = new Map<String,String>();
        // loop over group
        
        // --UAN-- This Section can be Class property
        if(initialGroup.size() > 0 && countRound == 0){
            for(Group g: initialGroup){
                tmpData = new Map<String,String>();

                setGroupID.add(g.Id);           
                mapQueueName.put(g.Id, g.Name);
                tmpData.put('Name',g.Name!=null?g.Name:'');
                tmpData.put('Email',g.Email!=null?g.Email:'');
                mapQueueData.put(g.Id,tmpData);  

                //add to group list
                if( g.type == 'Queue'){
                    setQueueId.add(g.Id);       
                }else if(g.type == 'Role'){
                    setRoleId.add(g.Id);        
                    mapGroupIdRelatedId.put(g.Id,g.RelatedId);  
                }else if(g.type == 'RoleAndSubordinates'){      
                    mapGroupIdRelatedId_RS.put(g.Id,g.RelatedId);   
                    setRoleAndSubId.add(g.Id);                      
                }// else do noting
            }
        }


        // loop over user for RoleId and UserId
        for(User iuser : userList){
            tmpUserId = new List<Id>();
            tmpMapRoleIdUserId = new Map<Id,List<Id>>();
            tmpUserData = new Map<String,String>();

            tmpUserData.put('Employee_ID__c',  (iuser.Employee_ID__c != null)?iuser.Employee_ID__c:'');
            mapUserData.put(iuser.Id,tmpUserData);

            if( mapRoleIdUserId.containsKey(iuser.UserRoleId) ){ // Case there are already role in map 
                tmpUserId = mapRoleIdUserId.get(iuser.UserRoleId).clone();
                tmpUserId.add(iuser.Id);                           // Add to list

                tmpMapRoleIdUserId = mapRoleIdUserId;
                tmpMapRoleIdUserId.put(iuser.UserRoleId, tmpUserId); // Replace old list with added list

                mapRoleIdUserId.putAll(tmpMapRoleIdUserId);    // Copy Modify List to Existing List
            }else{ // New Role Id and Add User to Role Id
                tmpUserId.add(iuser.Id);
                mapRoleIdUserId.put(iuser.UserRoleId , tmpUserId);
            }
        }

        // Get Group Member Only Group Type = 'Queue'
        // --UAN-- This Section can be Class property
        if(setGroupID.size() > 0 && countRound == 0){
            allMember = [Select UserOrGroupId, ID, GroupId From GroupMember where GroupId in: setQueueId]; 
        }

        // Doing Role&Subordinate Prepare data //
        // --UAN-- This Section can be Class property
        if(list_role.size() > 0 && countRound == 0){
            for(UserRole roles : list_role){
                tmpMapParentRole = new Map<Id,List<Id>>();
                tmpChildRoleId = new List<Id>(); 
                if( mapParentRole.containsKey( roles.ParentRoleId) ){ // 2st
                    tmpChildRoleId = mapParentRole.get( roles.ParentRoleId ).clone();
                    tmpChildRoleId.add( roles.Id);

                    tmpMapParentRole = mapParentRole;
                    tmpMapParentRole.put(roles.ParentRoleId,tmpChildRoleId);
                    mapParentRole.putAll(tmpMapParentRole);  

                }else{
                    tmpChildRoleId.add(roles.Id);
                    
                    tmpMapParentRole = mapParentRole;
                    tmpMapParentRole.put(roles.ParentRoleId,tmpChildRoleId);
                    mapParentRole.putAll(tmpMapParentRole);
                }
            }
        }

        // loop over queueSObject
        // --UAN-- This Section can be Class property
        if(queueSupportObject.size() > 0 && countRound == 0){
            for(queueSobject queS :queueSupportObject){
                tmpMapQueueIdSupportObject = new Map<Id,String>();
                tmpString = '';
                if( mapQueueIdSupportObject.containsKey(queS.QueueId) ){
                    tmpString = (mapQueueIdSupportObject.get(queS.QueueId).length()>0)? mapQueueIdSupportObject.get( queS.QueueId ) +','+queS.SobjectType : queS.SobjectType;
                    tmpMapQueueIdSupportObject = mapQueueIdSupportObject;
                    tmpMapQueueIdSupportObject.put(queS.QueueId,tmpString);
                    mapQueueIdSupportObject.putAll(tmpMapQueueIdSupportObject);    // ---UAN--- P10
                }else{
                    tmpMapQueueIdSupportObject = mapQueueIdSupportObject;
                    tmpMapQueueIdSupportObject.put(queS.QueueId,queS.SobjectType);
                    mapQueueIdSupportObject.putAll(tmpMapQueueIdSupportObject);
                }
            }
        }

        // finding Group Member
        if(allMember.size() > 0){
			
            for(GroupMember gm : allMember){
                // UserOrGroupId start with 005 is User, start with 00G is Role
                tmpUserId = new List<Id>();
                tmpUserId_2 = new List<Id>();
                tmpUserId_3 = new List<Id>();
                tmpMapId =  new Map<String,List<Id>>();   //Map<String,List<Id>>
                tmpQueueEmployee = new Map<Id, Map<String,List<Id>>>();
                tmpSetInit = new Set<Id>();
                
                
       
                if(String.valueOf(gm.UserOrGroupId).startsWith('005')){     // in case of group Member is User Obj
                    if( queueEmployee.containsKey(gm.GroupId) ){             // there are already value in queueEmployee

                        if( queueEmployee.get(gm.GroupId).containsKey('User')  ){ // there are already get User Map
                        // add to queueEmployee (1.getQueId . 2.getQueType 3.add UserId to List)
                        // for copy and add new map
                            tmpUserId = queueEmployee.get(gm.GroupId).get('User').clone();
                            tmpUserId.add(gm.UserOrGroupId);

                            tmpMapId = queueEmployee.get(gm.GroupId);
                            tmpMapId.put('User',tmpUserId); 

							tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);

                            queueEmployee.putAll(tmpQueueEmployee);

                        }else{  // created new Employee Map 'User'
                            tmpUserId.add(gm.UserOrGroupId);
                            // Clone other data 
                            // Map<Id, Map<String,List<Id>>>
                            tmpMapId = queueEmployee.get(gm.GroupId);
                            tmpMapId.put('User',tmpUserId);

                            tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);

                            queueEmployee.putAll(tmpQueueEmployee);
                            //queueEmployee.get(gm.GroupId).put(tmpMapId);                           
                        }                        
                    }else{     // there have to add new User in queue list                   
                        tmpUserId.add(gm.UserOrGroupId);		
                        tmpMapId = (queueEmployee.get(gm.groupId) != null) ? queueEmployee.get(gm.groupId) : tmpMapId;  
                        tmpMapId.put('User',tmpUserId);
                        queueEmployee.put(gm.GroupId ,tmpMapId);
                    }

                }else if( setRoleId.contains(gm.UserOrGroupId) ){

                    if( queueEmployee.containsKey(gm.GroupId) ){             // there are already value in queueEmployee
                       if( queueEmployee.get(gm.GroupId).containsKey('Role') ){ // there are already get User Map
                            //add to queueEmployee (1.getQueId . 2.getQueType 3.add RoleId)
                             
                            tmpUserId = queueEmployee.get(gm.GroupId).get('Role').clone();
                            tmpUserId.add(mapGroupIdRelatedId.get(gm.UserOrGroupId));    // Add New Role Name from old list

                            tmpUserId_2 = queueEmployee.get(gm.GroupId).get('Role_User')!= null ? queueEmployee.get(gm.GroupId).get('Role_User').clone() : tmpUserId_2;
                             if( mapGroupIdRelatedId.containsKey(gm.UserOrGroupId) && mapRoleIdUserId.containsKey(mapGroupIdRelatedId.get(gm.UserOrGroupId)) ){ 
                                 
                                 tmpUserId_2.addAll( mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId))!=null?mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId)):new List<Id>() );
                            }
                            tmpMapId = queueEmployee.get(gm.GroupId); // add data to group 
                            tmpMapId.put('Role',tmpUserId);  
                            tmpMapId.put('Role_User', tmpUserId_2);

                            tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);
							
                            queueEmployee.putAll(tmpQueueEmployee); 
                        }else{  // created new Employee 'Role'
                            tmpUserId.add( mapGroupIdRelatedId.get(gm.UserOrGroupId) );                            
                            if( mapGroupIdRelatedId.containsKey(gm.UserOrGroupId) && mapRoleIdUserId.containsKey(mapGroupIdRelatedId.get(gm.UserOrGroupId))  ){ 
                                
                                tmpUserId_2.addAll( mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId))!=null?mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId)):new List<Id>() );
                            }
                            tmpMapId = (queueEmployee.get(gm.GroupId)!= NULL)?queueEmployee.get(gm.GroupId):tmpMapId;	
                            tmpMapId.put('Role',tmpUserId);
                            tmpMapId.put('Role_User',tmpUserId_2);

                            tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);
							
                            queueEmployee.putAll(tmpQueueEmployee);
                            
                        }                        
                    }else{     // there have to add new Role in queue list
                        
                        tmpUserId.add( mapGroupIdRelatedId.get(gm.UserOrGroupId) );
						tmpMapId = (queueEmployee.get(gm.GroupId)!= NULL)?queueEmployee.get(gm.GroupId):tmpMapId;					
                        tmpMapId.put('Role',tmpUserId);
                        
                        tmpMapId.put('Role_User', mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId))!=null?mapRoleIdUserId.get(mapGroupIdRelatedId.get(gm.UserOrGroupId)):new List<Id>() );
                        
                        tmpQueueEmployee.putAll(queueEmployee);
						tmpQueueEmployee.put(gm.GroupId,tmpMapId);
						
                        queueEmployee.putAll(tmpQueueEmployee);        
                        
                    }       
                }else if( setRoleAndSubId.contains(gm.UserOrGroupId) ){   // in case of group Member is RoleAndSubOrdinate
                    
                    if( queueEmployee.containsKey(gm.GroupId) ){
                        if( queueEmployee.get(gm.GroupId).containsKey('RoleAndSubordinates') ){
                            tmpUserId = queueEmployee.get(gm.GroupId).get('RoleAndSubordinates').clone();
                            tmpUserId.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );    // Add New Role Name from old list
                            tmpSetInit.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );
                            tmpUserId_2 = queueEmployee.get(gm.GroupId).get('RoleAndSubordinates_User') != null ? queueEmployee.get(gm.GroupId).get('RoleAndSubordinates_User').clone() : tmpUserId_2;
                            
                            tmpUserId_2.addAll( getUserfromSetRoleId( getAllSubRoleIdsMod(mapParentRole,tmpSetInit), mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) ,mapRoleIdUserId ) ); 

                            tmpUserId_3 = queueEmployee.get(gm.GroupId).get('RoleAndSubordinates_Role').clone();
                            tmpUserId_3.addAll( new List<Id>(getAllSubRoleIdsMod(mapParentRole,tmpSetInit)) );

                            tmpMapId = queueEmployee.get(gm.GroupId); // add data to group 
                            tmpMapId.put('RoleAndSubordinates',tmpUserId); 
                            tmpMapId.put('RoleAndSubordinates_User',tmpUserId_2);
                            tmpMapId.put('RoleAndSubordinates_Role',tmpUserId_3);

                            tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);
							
                            queueEmployee.putAll(tmpQueueEmployee);
                        }else{
                            tmpUserId.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );
                            tmpSetInit.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );
                            tmpUserId_2.addAll( getUserfromSetRoleId( getAllSubRoleIdsMod(mapParentRole,tmpSetInit), mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) ,mapRoleIdUserId ) );
                            
                            
                            tmpMapId = (queueEmployee.get(gm.GroupId) != NULL)?queueEmployee.get(gm.GroupId):tmpMapId;
                            tmpMapId.put('RoleAndSubordinates',tmpUserId);
                            tmpMapId.put('RoleAndSubordinates_Role',new List<Id>(getAllSubRoleIdsMod(mapParentRole,tmpSetInit)));
                            tmpMapId.put('RoleAndSubordinates_User',tmpUserId_2);

                            tmpQueueEmployee.putAll(queueEmployee);
                            tmpQueueEmployee.put(gm.GroupId,tmpMapId);
							
                            queueEmployee.putAll(tmpQueueEmployee);
                        }
                    }else{
                        tmpUserId.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );
                        tmpSetInit.add( mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) );
                        tmpMapId = (queueEmployee.get(gm.GroupId) != NULL)?queueEmployee.get(gm.GroupId).clone():tmpMapId;
                        tmpMapId.put('RoleAndSubordinates',tmpUserId);
                        
                        tmpMapId.put('RoleAndSubordinates_Role', new List<Id>(getAllSubRoleIdsMod(mapParentRole,tmpSetInit)));
                        tmpMapId.put('RoleAndSubordinates_User' ,getUserfromSetRoleId( getAllSubRoleIdsMod(mapParentRole,tmpSetInit), mapGroupIdRelatedId_RS.get(gm.UserOrGroupId) ,mapRoleIdUserId ));

                        tmpQueueEmployee.putAll(queueEmployee);
                        tmpQueueEmployee.put(gm.GroupId,tmpMapId);
                        queueEmployee.putAll(tmpQueueEmployee);
                    }
                }
            }
        }

        
        

        List<Id> tmpListIdNull = new List<Id>();
        
        for(Id strId : queueEmployee.keySet()){
            for( String strG : queueEmployee.get(strId).keySet() ){
                for( Id empId : queueEmployee.get(strId).get(strG) ){                

                    tmpBuMember = new BU_Member__c();
                    
                    
                    if( mapUserData.containsKey(empId) ){  
                        if( strG == 'User' && !uniqueId.contains(strId+'_'+empId) ){
                            
                            tmpBuMember.Name = mapQueueData.get(strId).get('Name');
                            tmpBuMember.BU_Email__c = mapQueueData.get(strId).get('Email');
                            //tmpBuMember.External_ID__c = 'U_'+mapQueueData.get(strId).get('Name')+'_'+mapUserData.get(empId).get('Employee_ID__c');
                            // tmpBuMember.External_ID__c = 'U_'+strId+'_'+empId;
                            tmpBuMember.External_ID__c = strId+'_'+empId;
                            tmpBuMember.Member_Name__c = empId;
                            tmpBuMember.Supported_Objects__c = mapQueueIdSupportObject.get(strId);
                            tmpBuMember.Member_Type__c = 'USER'; 
                            list_buMember.add(tmpBuMember);
                            uniqueId.add( strId+'_'+empId );
                        }else if( strG == 'Role_User' && !uniqueId.contains(strId+'_'+empId)){ 
                            
                            tmpBuMember.Name = mapQueueData.get(strId).get('Name');
                            tmpBuMember.BU_Email__c = mapQueueData.get(strId).get('Email');
                            // tmpBuMember.External_ID__c = 'R_'+mapQueueData.get(strId).get('Name')+'_'+mapUserData.get(empId).get('Employee_ID__c');
                            // tmpBuMember.External_ID__c = 'R_'+strId+'_'+empId;
                            tmpBuMember.External_ID__c = strId+'_'+empId;
                            tmpBuMember.Member_Name__c = empId;
                            tmpBuMember.Supported_Objects__c = mapQueueIdSupportObject.get(strId);
                            tmpBuMember.Member_Type__c = 'ROLE';
                            list_buMember.add(tmpBuMember);
                            uniqueId.add( strId+'_'+empId );
                        }else if( strG == 'RoleAndSubordinates_User' && !uniqueId.contains(strId+'_'+empId) ){
                            
                            tmpBuMember.Name = mapQueueData.get(strId).get('Name');
                            tmpBuMember.BU_Email__c = mapQueueData.get(strId).get('Email');
                            //tmpBuMember.External_ID__c = 'RS_'+mapQueueData.get(strId).get('Name')+'_'+mapUserData.get(empId).get('Employee_ID__c');
                            // tmpBuMember.External_ID__c = 'RS_'+strId+'_'+empId;
                            tmpBuMember.External_ID__c = strId+'_'+empId;
                            tmpBuMember.Member_Name__c = empId;
                            tmpBuMember.Supported_Objects__c = mapQueueIdSupportObject.get(strId);
                            tmpBuMember.Member_Type__c = 'ROLE&SUBORDINATES'; 
                            list_buMember.add(tmpBuMember); 
                            uniqueId.add( strId+'_'+empId );
                        }
                    }
                    
                }
            }
        }

        // Upsert BU_Member__c
        Database.UpsertResult[] results;
        try{
            if(list_buMember.size() > 0){
                results = Database.upsert(list_buMember, BU_Member__c.External_ID__c, false);
            }
        }catch(Exception ex){
            System.debug('Cause : '+ex.getCause()+' ,Message : '+ex.getMessage()+', StackTraceString : '+ex.getStackTraceString());
        }finally{
            //System.debug( 'Results size : '+results.size());
            //for( Database.UpsertResult res : results){
            //    for(Database.Error err : res.getErrors()){
            //        System.debug('Field : '+err.getFields()+' , Message : '+err.getMessage());
            //    }
            //}
            //System.debug( 'Count Round : '+countRound );
            countRound++;
        }
         //update scope;
    }

    public void finish(Database.BatchableContext BC){
        // Delete BU_Member__c
        //delete [select Id from BU_Member__c where lastmodifieddate < TODAY];

        String className = DeleteBuMember.class.getName();        
        Integer defaultBatchSize = 2000;
        Integer configBatchSize = 0;

        List<BatchSizeSetting__mdt> buMemberSize = Database.query('Select ApexClassName__c,BatchSize__c from BatchSizeSetting__mdt WHERE ApexClassName__c = :className');
        for( BatchSizeSetting__mdt size  : buMemberSize){
            configBatchSize =  size.BatchSize__c.intValue();
        }
        
        configBatchSize = (configBatchSize == 0 || configBatchSize > 2000)? defaultBatchSize : configBatchSize;

        DeleteBuMember bat = new DeleteBuMember();
        database.executebatch(bat,configBatchSize);
    }
    
    private Set<Id> getAllSubRoleIdsMod(Map<Id,List<Id>> listRoleData,Set<ID> roleIds){
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for( Id idData : findParentRoleIdMod(listRoleData,roleIds) ) {
            currentRoleIds.add(idData);
        }

        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll( getAllSubRoleIdsMod(listRoleData ,currentRoleIds) );
        }

        return currentRoleIds;
    }

    /* Method2 for Role&Subordinate finding [workwith mehtod :getAllSubRoleIdsMod]*/
    private List<Id> findParentRoleIdMod(Map<Id,List<Id>> listRoleData,Set<Id> setRoleId){
        //List<UserRole> returnRoleId = new List<UserRole>();
        List<Id> returnRoleId = new List<Id>();
        for( Id roleId : setRoleId ){        
            //returnRoleId
            if( listRoleData.containsKey(roleId) ){
                returnRoleId.addAll( listRoleData.get(roleId) );
            }
        }
        return returnRoleId;
    }

    private List<Id> getUserfromSetRoleId(Set<Id> subRoleId,Id parentId,Map<Id,List<Id>> mapRoleIdUserIdFn){
        List<Id> returnUserId = new List<Id>();
        subRoleId.add(parentId);
        for(Id subId : SubRoleId){
            if( mapRoleIdUserIdFn.containsKey(subId) ){  // check there is not null 
                returnUserId.addAll( mapRoleIdUserIdFn.get(subId) );
            }
        }
        return returnUserId;
    }

}