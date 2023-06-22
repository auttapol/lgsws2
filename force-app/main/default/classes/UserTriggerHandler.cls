public class UserTriggerHandler {
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    //static Id sfadmId = [SELECT Id FROM User WHERE Name = 'sfadm System Account'].Id;

    public static Id sfadmId {
        get
        {
            if(sfadmId == null){
                sfadmId = [SELECT Id FROM User WHERE Name = 'sfadm System Account'].Id;
            }
            return sfadmId;
            
        }set;
    }

    public static List<Trigger_Msg__c> TriggerMsgList {
        get
        {
            if(TriggerMsgList == null){
                TriggerMsgList = [SELECT NAME,Description__c FROM Trigger_Msg__c 
                                                  WHERE Name ='User_trigger_error_change'
                                                  OR Name = 'User_trigger_error_insert'];
            }
            return TriggerMsgList;
            
        }set;
    }


    //Static List<Trigger_Msg__c> TriggerMsgList = [SELECT NAME,Description__c FROM Trigger_Msg__c 
    //                                              WHERE Name ='User_trigger_error_change'
    //                                              OR Name = 'User_trigger_error_insert'];
    // NOTE :  When we codding in Before Context we not use update in Accout list because it will update autometically!!!
    
    public static list<User_Permission__c> userPermissionList {
        get
        {
            if(userPermissionList == null){
                userPermissionList = [Select ID, Permission_Name__c, Permission_API__c, Profile_Name__c, Profile_ID__c from User_Permission__c];
            }
            return userPermissionList;
            
        }set;
    }

    public static list<User_Permission_Field_Set__c> userFieldlist {
        get
        {
            if(userFieldlist == null){
                userFieldlist = [Select ID, User_Field_API__c, User_Field_Label__c from User_Permission_Field_Set__c];
            }
            return userFieldlist;
            
        }set;
    }

    public static Map<String,List<Title_and_Product_Group_Mapping__c>> titleProductMap {
        get{
            if(titleProductMap == null){
                // Create Title Product Map
                titleProductMap = new Map<String,List<Title_and_Product_Group_Mapping__c>>();
                for (Title_and_Product_Group_Mapping__c TP : [SELECT Name, Title__c , Product_Group__c, LastModifiedById,  Active__c FROM Title_and_Product_Group_Mapping__c WHERE Active__c = true]) {
                    List<Title_and_Product_Group_Mapping__c> titleProductListAdd = new List<Title_and_Product_Group_Mapping__c>();
                    if(titleProductMap.containsKey(TP.Title__c)){
                        titleProductListAdd = titleProductMap.get(TP.Title__c);
                    }
                    titleProductListAdd.add(TP);
                    titleProductMap.put(TP.Title__c, titleProductListAdd);
                }//Create Title Product Map
                // System.debug('titleProductMap: '+titleProductMap);
            }
            return titleProductMap;
        }
        set;
    }

            
            


    //static list<User_Permission__c> userPermissionList = [Select ID, Permission_Name__c, Permission_API__c, Profile_Name__c, Profile_ID__c from User_Permission__c];
    //static list<User_Permission_Field_Set__c> userFieldlist = [Select ID, User_Field_API__c, User_Field_Label__c from User_Permission_Field_Set__c];
    static Map<String,String> permissionMap = New Map<String, String>();
    Static Map<String,ID> Knowledge_User = New Map<String,ID>(); 
    Static Map<String,ID> Live_Agent_User = New Map<String,ID>();
    Static List<Profile> userProfileList = [Select ID, Name from Profile];
    
    public static void handleBeforeInsert(List<User> usersNew)
    {
        
        boolean ch = false;
        for (ObjUserPermission__c oup : ObjUserPermission__c.getAll().values())
        {
            if(oup.Set_ID__c == UserInfo.getUserId() || oup.Set_ID__c == UserInfo.getProfileId() || oup.Name == UserInfo.getUserName())
            {
                ch = true;
                break;
            }
        }
        
        if(!ch)
        {
            system.debug('Get Data from Custom setting 1');
            for(User uses : usersNew)
            {
                for(Trigger_Msg__c msg : TriggerMsgList){
                    if(msg.Name == 'User_trigger_error_insert'){
                      uses.addError(msg.Description__c); 
                    }
                }
               
                break;
            }
        }
        
        for(User u : usersNew){
            u.IsDataChange__c = true;
        }
        
         //Update user permission for KnowledgeUser and LiveAgentUser
        mapPermission();
        updatePermission(usersNew);
        
    }
    
    public static void handleBeforeUpdate(List<User> usersNew,Map<Id,User> usersOldMap)
    {
        boolean ch = false;
        for (ObjUserPermission__c oup : ObjUserPermission__c.getAll().values())
        {
            if(oup.Set_ID__c == UserInfo.getUserId() || oup.Set_ID__c == UserInfo.getProfileId() || oup.Name == UserInfo.getUserName() || usersNew[0].Allow_Update_Flag__c == true)
            {
                ch = true;
                usersNew[0].Allow_Update_Flag__c = false;
                break;
            }
        }
        if(!ch)
        {
            system.debug('Get Data from Custom setting 2');
            for(User uses : usersNew)
            {
                for(Trigger_Msg__c msg : TriggerMsgList){
                    if(msg.Name == 'User_trigger_error_change'){
                      uses.addError(msg.Description__c); 
                    }
                }
                break;
            }
        }
        updateUserByIDM(usersNew);
        compareInformation(usersNew, usersOldMap);
        
        /*** CANCLE AS OF 10/03/2017 : BACK TO IDM RECONCILE SOLUTION***/
        //updateUserforInactive(usersNew,usersOldMap);
        
        //Update user permission for KnowledgeUser and LiveAgentUser
        mapPermission();
        updatePermission(usersNew);
            
    }

    public static void handleAfterInsert(Map<Id,User> mapUserNew,List<User> usersOld){
        upsertSpecialistProduct(mapUserNew.keySet());
    }

    public static void handleAfterUpdate(List<User> usersNew,Map<Id,User> mapUserOld){
        // Check Title Change
        Set<Id> titleUsersIdlst = new Set<Id>();
        for (User eachUser : usersNew) {
            if (eachUser.Title != mapUserOld.get(eachUser.Id).Title || eachUser.RTL_Branch_Code__c != mapUserOld.get(eachUser.Id).RTL_Branch_Code__c) {
                titleUsersIdlst.add(eachUser.Id);
            }
        }
        if (titleUsersIdlst.size() != 0) {
            upsertSpecialistProduct(titleUsersIdlst);
        }

    }

    @future
    public static void upsertSpecialistProduct(Set<Id> IdLst){
        List<User> usersNew = [SELECT Id, Title, RTL_Branch_Code__c, Employee_ID__c FROM User WHERE Id IN :IdLst];

        if(usersNew.size() > 0){
            List<Specialist_and_Product_Group_Mapping__c> upsertSpecialistProductList = new List<Specialist_and_Product_Group_Mapping__c>();
            for (User eachUser : usersNew) {
                if(titleProductMap.containsKey(eachUser.Title) && eachUser.RTL_Branch_Code__c != '' && eachUser.RTL_Branch_Code__c != null){
                    List<Title_and_Product_Group_Mapping__c> titleProductListOfUser = titleProductMap.get(eachUser.Title);
                    for (Title_and_Product_Group_Mapping__c TP : titleProductListOfUser) {
                        Specialist_and_Product_Group_Mapping__c newSpecialistAndProduct = new Specialist_and_Product_Group_Mapping__c();
                        newSpecialistAndProduct.Title__c = TP.Title__c;
                        newSpecialistAndProduct.Product_Group__c = TP.Product_Group__c;
                        newSpecialistAndProduct.Branch_Code__c = eachUser.RTL_Branch_Code__c;
                        newSpecialistAndProduct.External_Key__c = eachUser.RTL_Branch_Code__c+eachUser.Employee_ID__c+TP.Product_Group__c;
                        newSpecialistAndProduct.Agent__c = eachUser.ID;
                        newSpecialistAndProduct.Title_and_Product_Group_Mapping__c = TP.ID;
    
                        upsertSpecialistProductList.add(newSpecialistAndProduct);
                    }
                }
            }
            if(upsertSpecialistProductList.size() > 0) upsert upsertSpecialistProductList External_Key__c;
        }
    }
    
    /*** HCM Project : Keep ManagerID in Manager_Employee_ID__c for trigger IDMUserBatch***/    
    public static void updateUserByIDM(List<User> usersNew){
        List<String> managerList = new List<String>();
        List<User> userList = new List<User>();
        //run as sfadm
        if(UserInfo.getUserId() == sfadmId){       
            for(User user : usersNew){
                //get temp manager id == null 
                if(user.Manager_Employee_ID__c == null && user.ManagerId != null){
                    userList.add(user);
                    managerList.add(user.ManagerId);
                }
            }
            //find manager employee Id 
            List<User> managerUser = new List<User>([SELECT Id,Employee_ID__c FROM User WHERE Id IN: managerList]);
            for(User user : userList){
                for(User manager : managerUser){
                    //update Manager_Employee_ID__c
                    user.Manager_Employee_ID__c = manager.Employee_ID__c;
                }
            }
        }
        else{
            system.debug('## update by other user');
        }
        
    }   
   
    
    /**** Add Condition 2017-07-20 (CR HCM) ****/
    public static void compareInformation (List<User> usersNew,Map<Id,User> mapUserOld)
    {        
        for (user u : usersNew)
        {
            /**   CR HCM Add Condition 12/12/2017 START **/
            if( !u.IsActive && u.IsDataChange__c ){
                u.IsDataChange__c = false;
            }
            /**   CR HCM Add Condition 12/12/2017 END **/
            
            if (u.IsActive && mapUserOld.get(u.Id).IsActive == false) u.IsDataChange__c = true; //Add Condition from Case No. 00007319
            if (u.UserRoleID != mapUserOld.get(u.Id).UserRoleID) u.IsDataChange__c = true;
            if (u.ProfileId != mapUserOld.get(u.Id).ProfileId) u.IsDataChange__c = true;
            if (u.Segment__c != mapUserOld.get(u.Id).Segment__c) u.IsDataChange__c = true;
            if (u.Reporting_Segment__c != mapUserOld.get(u.Id).Reporting_Segment__c) u.IsDataChange__c = true;
            if (u.Region__c != mapUserOld.get(u.Id).Region__c) u.IsDataChange__c = true;
            if (u.Region_Code__c != mapUserOld.get(u.Id).Region_Code__c) u.IsDataChange__c = true;
            if (u.Zone__c != mapUserOld.get(u.Id).Zone__c) u.IsDataChange__c = true;
            if (u.Zone_Code__c != mapUserOld.get(u.Id).Zone_Code__c) u.IsDataChange__c = true;
            if (u.Title != mapUserOld.get(u.Id).Title) u.IsDataChange__c = true;
            if (u.RTL_Channel__c != mapUserOld.get(u.Id).RTL_Channel__c) u.IsDataChange__c = true;
            if (u.RTL_Branch__c != mapUserOld.get(u.Id).RTL_Branch__c) u.IsDataChange__c = true;
            if (u.RTL_Branch_Code__c != mapUserOld.get(u.Id).RTL_Branch_Code__c) u.IsDataChange__c = true;
            if (u.TimeZoneSidKey != mapUserOld.get(u.Id).TimeZoneSidKey) u.IsDataChange__c = true;
            if (u.LocaleSidKey != mapUserOld.get(u.Id).LocaleSidKey) u.IsDataChange__c = true;
            if (u.EmailEncodingKey != mapUserOld.get(u.Id).EmailEncodingKey) u.IsDataChange__c = true;
            if (u.LanguageLocaleKey != mapUserOld.get(u.Id).LanguageLocaleKey) u.IsDataChange__c = true;
            //if (u.UserPreferencesHideS1BrowserUI != mapUserOld.get(u.Id).UserPreferencesHideS1BrowserUI) u.IsDataChange__c = true;
            if (u.UserPermissionsSupportUser != mapUserOld.get(u.Id).UserPermissionsSupportUser) u.IsDataChange__c = true;
            if (u.UserPermissionsMarketingUser != mapUserOld.get(u.Id).UserPermissionsMarketingUser) u.IsDataChange__c = true;
            if (u.Employee_ID__c != mapUserOld.get(u.Id).Employee_ID__c) u.IsDataChange__c = true;
            if (u.Username != mapUserOld.get(u.Id).Username) u.IsDataChange__c = true;
            if (u.FederationIdentifier  != mapUserOld.get(u.Id).FederationIdentifier) u.IsDataChange__c = true;
            if (u.Email != mapUserOld.get(u.Id).Email) u.IsDataChange__c = true;
            if (u.FirstName != mapUserOld.get(u.Id).FirstName) u.IsDataChange__c = true;
            if (u.LastName != mapUserOld.get(u.Id).LastName) u.IsDataChange__c = true;
            if (u.Alias != mapUserOld.get(u.Id).Alias) u.IsDataChange__c = true;
            //if (u.IsActive != mapUserOld.get(u.Id).IsActive) u.IsDataChange__c = true;
            if (u.CommunityNickname != mapUserOld.get(u.Id).CommunityNickname) u.IsDataChange__c = true;
            if (u.Manager_Employee_ID__c != mapUserOld.get(u.Id).Manager_Employee_ID__c) u.IsDataChange__c = true;
            if (u.Phone != mapUserOld.get(u.Id).Phone) u.IsDataChange__c = true;
            if (u.MobilePhone != mapUserOld.get(u.Id).MobilePhone) u.IsDataChange__c = true;
            
            if (mapUserOld.get(u.Id).IsActive == false && u.IsDataChange__c) u.IsActive = true;
        }
        
    }
    /**** Add Condition 2017-07-20 (CR HCM) ****/
    
    
    //Mapping user permission to update Knowledge User and Live Agent User
    public static void mapPermission(){
       if(userPermissionList.size() > 0){
            for(User_Permission__c uPer : userPermissionList){ 
                String keyMap = String.valueOf(uPer.Profile_ID__c).left(15) + uPer.Permission_API__c;
                keyMap = keyMap.replaceAll(' ', '');
                permissionMap.put(keyMap, uPer.Permission_API__c);
            }
            
        }       
    }
    
    //Update user permission to update Knowledge User and Live Agent User
    public static void updatePermission(List<user> usersNew){
        for(User uNew : usersNew){
            SObject Urecord = uNew; 
            try{
                //String userProfileName = mapProfileName.get(uNew.ProfileId);
                String keyCheck = '';
                if(userFieldlist.size() > 0){
                      for(User_Permission_Field_Set__c userField : userFieldlist){                                             
                           keyCheck = String.valueOf(uNew.ProfileId).left(15)+ userField.User_Field_API__c;
                           keyCheck = keyCheck.replaceAll(' ', '');
                           String fieldAPI = permissionMap.get(keyCheck);
                           if(fieldAPI != null){
                               Urecord.put(userField.User_Field_API__c,True);
                           }else{
                               Urecord.put(userField.User_Field_API__c,False);
                             
                           } 
                      }
                }                
            
            }catch(exception e){
                //Do not thing
            }
        }
    }    
}