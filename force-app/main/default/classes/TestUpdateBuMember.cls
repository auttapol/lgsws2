@isTest
public class TestUpdateBuMember {
    public TestUpdateBuMember(){
    }

    /* 
        Test Method for Class UpdateBuMember
    */
    @IsTest static void UpdateBuMember_Test(){
        Id RTL_BRANCH_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;

        // [1] Initial UserRole
        UserRole Role_Parent = new UserRole();
        UserRole Role_Child = new UserRole();
        UserRole Role_Other = new UserRole();
        
        Role_Parent.Name = 'Role_Parent';
        Role_Child.Name = 'Role_Child';
        Role_Other.Name = 'Role_Other';
        
        insert Role_Parent;
        Role_Child.ParentRoleId = Role_Parent.Id;
        insert Role_Child;
        insert Role_Other;
        
        List<UserRole> user_roledata = [SELECT Id,Name,ParentRoleId FROM UserRole Where Name IN('Role_Parent','Role_Child')];
        // for(UserRole usr : user_roledata){
        //     System.debug( '---------------------'+usr.name+'-----------------'+usr.ParentRoleId);
        // } 
        
        // [2] Initial User
        List<User> list_user = new List<User>();
        User tmp_user = new User();
        Id tmpId; 
        for(integer i=0; i<15; i++){
            if( math.mod(i,3) == 0 && i <= 12){
                tmpId = Role_Parent.Id;
            }else if( math.mod(i,3) == 1 && i <= 12){
                tmpId = Role_Child.Id;
            }else if( math.mod(i,3) == 2 && i <= 12){
                tmpId = Role_Other.Id;
            }else{
                tmpId = null;   // there are 3 employee is not have a role and member must be a member of group
            }

            tmp_user = new User();
            tmp_user = new User(FirstName='retail_'+i, LastName='test bu_member_'+i, 
            UserName='rtl_testuser_'+i+'@tmb.com',
            Email='rtl_testuser_'+i+'@tmb.com', Alias='User'+i,
            LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1',
            UserRoleId= tmpId,
            ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
            Employee_ID__c='RTL'+String.valueOf(i).leftPad(3,'0'));
            
            list_user.add(tmp_user);
        }
        insert list_user;

        List<User> ud = [select Id,firstName,Name from User where email like 'rtl_testuser%' order by Employee_ID__c asc];
        // for(User ux : ud){
        //     System.debug('------ ux firstName | '+ux.firstName);
        // }
        //System.debug('--- User query size --- :'+ud.size() );       

        // [3] initial Group
        //SELECT Email,Id,Name,RelatedId,Type FROM Group
        Group groupTestRole = new Group();    
        Group groupTestRoleAndSub = new Group();
        Group groupTestUser = new Group();
        Group groupOnlyRole = new Group();
        Group groupOnlyRoleAndSub = new Group();
        Group groupTestSample = new Group();
        
        groupTestRole.Name = 'Group Test Role';
        groupTestRole.Type = 'Queue';
        groupTestRole.Email = 'grouptestrole@tmbbank.com';
        insert groupTestRole;

        groupTestRoleAndSub.Name = 'Group Test Role and Sub';
        groupTestRoleAndSub.Type = 'Queue';
        groupTestRoleAndSub.Email = 'grouptestroleandsub@tmbbank.com';
        insert groupTestRoleAndSub;

        groupTestUser.Name = 'Group Test User';
        groupTestUser.Type = 'Queue';
        groupTestUser.Email = 'grouptestother@tmbbank.com';
        insert groupTestUser;

        groupOnlyRole.Name = 'Group Test Only Role';
        groupOnlyRole.Type = 'Queue';
        groupOnlyRole.Email = 'grouptestonlyrole@tmbbank.com';
        insert groupOnlyRole;

        groupOnlyRoleAndSub.Name = 'Group Test Only Role And Sub';
        groupOnlyRoleAndSub.Type = 'Queue';
        groupOnlyRoleAndSub.Email = 'grouptestnlyroleandsub@tmbbank.com';
        insert groupOnlyRoleAndSub;

        groupTestSample.Name = 'A Group Test Sample';
        groupTestSample.Type = 'Queue';
        groupTestSample.Email = 'grouptestsample@tmbbank.com';
        insert groupTestSample;


        list<Group> list_g = [select id,Name,Type,Email,RelatedId from Group where Email like 'grouptest%'];
        
        //list<Group> list_gg = [select id,Name,Type,Email,RelatedId from Group where type IN('Role','RoleAndSubordinates') and RelatedId IN(Role_Parent.Id,Role_Child.Id,Role_Other.Id)];
        String query = 'select id,Name,Type,Email,RelatedId from Group where type IN(\'Role\',\'RoleAndSubordinates\') and RelatedId IN(\''+Role_Parent.Id+'\',\''+Role_Child.Id+'\',\''+Role_Other.Id+'\')';
        // System.debug('xxxxxxxxxxxxxxxxxxxxxxxxx');
        // System.debug(query);
        // System.debug('xxxxxxxxxxxxxxxxxxxxxxxxx');
        list<Group> list_gg = Database.query(query);

        Map<Id,Id> map_roleIdGroupId = new Map<Id,Id>(); // Map <RoleId,GroupId>  ---> Type == Role
        Map<Id,Id> map_roleAndSubIdGroupId = new Map<Id,Id>(); // Map <RoleId,GroupId>  ---> Type == RoleAndSubordinates          
        
        // System.debug('----- groupTestRole.Id : -----'+groupTestRole.Id);
        // System.debug('----- groupTestRoleAndSub.Id : -----'+groupTestRoleAndSub.Id);
        // System.debug('----- groupTestUser.Id : -----'+groupTestUser.Id);

        for(Group g : list_gg){
            if(g.Type == 'Role'){
                map_roleIdGroupId.put(g.RelatedId,g.Id);
                //System.debug(' Group Type Role ,Sub :   '+g);
            }else if(g.Type == 'RoleAndSubordinates'){
                map_roleAndSubIdGroupId.put(g.RelatedId,g.Id);
            }
        }

        // [4] initial Group Member
        
        //SELECT GroupId,Id,UserOrGroupId FROM GroupMember
        list<GroupMember> list_gm = new List<GroupMember>();
        GroupMember tmpGm = new GroupMember();

        // Add Group Member 1
        // GM 1.1 Role Parent
        tmpGm.GroupId = groupTestRole.Id; 
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Parent.Id );
        list_gm.add( tmpGm );
        // GM 1.2 Rold Child
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Child.Id );
        list_gm.add( tmpGm );
        // GM 1.3 User Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(12).Id; // user 12,13,14(Role Other)
        list_gm.add(tmpGm);
        // GM 1.4 User Parent Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(2).Id; // user 2, 5, 8, 11 Parent Role
        list_gm.add(tmpGm);
        // GM 1.5 User Child Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(0).Id; // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);

        // GM 1.5.1 User Child Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(3).Id; // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);
                
        // GM 1.6 User Other Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(1).Id; // user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);                

        // GM 1.6.1 User Other Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(4).Id; // user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);                

        //GM 2 Add Group Member 2
        // GM 2.1 Role and Sub (Role Parent)
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Parent.Id );
        list_gm.add(tmpGm);                

        // GM 2.2 Role and Sub (Role Child)
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Child.Id );
        list_gm.add(tmpGm);                

        // GM 2.3 User Child 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(6).Id;  // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);
        
        // GM 2.3.1 User Child 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(9).Id;  // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);

        // GM 2.4 User Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(13).Id; // user 12,13,14 No Role
        list_gm.add(tmpGm);

        // GM 2.4.1 User Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);        

        // GM 2.5 User Role Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(7).Id; //user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);        

        // GM 2.5.1 User Role Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(10).Id; //user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm); 
        
        // Add Group Member 3
        // GM 3.1 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(12).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);               
        // GM 3.1.1 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(13).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);   
        // GM 3.1.2 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);
        
        // GM 3.2 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(1).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);               

        // GM 3.2.1 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(4).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);                   

        // GM 3.2.2 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(7).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);           

        // GM 3.2.3 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(10).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);
        
        // GM 4. Member Only Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupOnlyRole.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Child.Id );
        list_gm.add(tmpGm);

        // GM 5. Member Only Role and Sub
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupOnlyRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Parent.Id );
        list_gm.add(tmpGm);

        // GM 6. Group Test Sameple
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestSample.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id;
        list_gm.add(tmpGm);

        // GM 6.1 Group Test Sample Test ReOrderInsert
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestSample.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Other.Id );
        list_gm.add(tmpGm);

        insert list_gm;
        
        // System.debug( '----- list Group Member 0(Id) -----'+ list_gm.get(0).Id );
        // System.debug( '----- list Group Member 1(Id) -----'+ list_gm.get(1).Id );
        // System.debug( '----- list Group Member 2(Id) -----'+ list_gm.get(2).Id );
        
        // [5] Initial QueueSobject
        //SELECT Id,QueueId,SobjectType FROM QueueSobject
        List<QueueSobject> list_queueSO = new List<QueueSobject>();
        QueueSobject tmp_queueSO = new QueueSobject();
    
        tmp_queueSO.QueueId = groupTestRole.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestRoleAndSub.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestUser.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupOnlyRole.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupOnlyRoleAndSub.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestSample.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        insert list_queueSO;

        // [6] initial BU Member
        User SYS_ADMIN = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        //system.runAs(SYS_ADMIN) 
        BU_Member__c tmpBuMember = new BU_Member__c();
        Datetime yesterday = Datetime.now().addDays(-1);

        tmpBuMember.Name = 'Test BU Name';
        tmpBuMember.BU_Email__c = 'testmyemail@tmbbank.com';
        tmpBuMember.External_ID__c = '001_ExernalId';
        tmpBuMember.Member_Name__c = ud.get(14).Id;
        tmpBuMember.Supported_Objects__c = 'Case';
        //tmpBuMember.createddate = yesterday;
        //tmpBuMember.lastModifiedDate = yesterday;
        system.runAs(SYS_ADMIN){
            insert tmpBuMember;
            Test.setCreatedDate(tmpBuMember.Id, yesterday);
        }


        list<BU_Member__c> list_buMem = [select id,createddate,LastModifiedDate from BU_Member__c where BU_Email__c like 'testmyemail%'];
        // for(BU_Member__c buMem : list_buMem){
        //     System.debug('------------ createdDate      : '+buMem.createddate);
        //     System.debug('------------ lastModifiedDate : '+buMem.createddate);
        // }

        Test.StartTest();
        Database.executeBatch(new UpdateBuMember(),200);
        Test.StopTest();
        
    }


    @IsTest static void DeleteBuMember_Test(){
        Id RTL_BRANCH_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;

        // [1] Initial UserRole
        UserRole Role_Parent = new UserRole();
        UserRole Role_Child = new UserRole();
        UserRole Role_Other = new UserRole();

        Role_Parent.Name = 'Role_Parent';
        Role_Child.Name = 'Role_Child';
        Role_Other.Name = 'Role_Other';

        insert Role_Parent;
        Role_Child.ParentRoleId = Role_Parent.Id;
        insert Role_Child;
        insert Role_Other;

        List<UserRole> user_roledata = [SELECT Id,Name,ParentRoleId FROM UserRole Where Name IN('Role_Parent','Role_Child')];
        // for(UserRole usr : user_roledata){
        //     System.debug( '---------------------'+usr.name+'-----------------'+usr.ParentRoleId);
        // } 

        // [2] Initial User
        List<User> list_user = new List<User>();
        User tmp_user = new User();
        Id tmpId; 
        for(integer i=0; i<15; i++){
            if( math.mod(i,3) == 0 && i <= 12){
                tmpId = Role_Parent.Id;
            }else if( math.mod(i,3) == 1 && i <= 12){
                tmpId = Role_Child.Id;
            }else if( math.mod(i,3) == 2 && i <= 12){
                tmpId = Role_Other.Id;
            }else{
                tmpId = null;   // there are 3 employee is not have a role and member must be a member of group
            }

            tmp_user = new User();
            tmp_user = new User(FirstName='retail_'+i, LastName='test bu_member_'+i, 
            UserName='rtl_testuser_'+i+'@tmb.com',
            Email='rtl_testuser_'+i+'@tmb.com', Alias='User'+i,
            LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1',
            UserRoleId= tmpId,
            ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
            Employee_ID__c='RTL'+String.valueOf(i).leftPad(3,'0'));
            
            list_user.add(tmp_user);
        }
        insert list_user;

        List<User> ud = [select Id,firstName,Name from User where email like 'rtl_testuser%' order by Employee_ID__c asc];
        // for(User ux : ud){
        //     System.debug('------ ux firstName | '+ux.firstName);
        // }
        //System.debug('--- User query size --- :'+ud.size() );       

        // [3] initial Group
        //SELECT Email,Id,Name,RelatedId,Type FROM Group
        Group groupTestRole = new Group();    
        Group groupTestRoleAndSub = new Group();
        Group groupTestUser = new Group();
        Group groupOnlyRole = new Group();
        Group groupOnlyRoleAndSub = new Group();
        Group groupTestSample = new Group();

        groupTestRole.Name = 'Group Test Role';
        groupTestRole.Type = 'Queue';
        groupTestRole.Email = 'grouptestrole@tmbbank.com';
        insert groupTestRole;

        groupTestRoleAndSub.Name = 'Group Test Role and Sub';
        groupTestRoleAndSub.Type = 'Queue';
        groupTestRoleAndSub.Email = 'grouptestroleandsub@tmbbank.com';
        insert groupTestRoleAndSub;

        groupTestUser.Name = 'Group Test User';
        groupTestUser.Type = 'Queue';
        groupTestUser.Email = 'grouptestother@tmbbank.com';
        insert groupTestUser;

        groupOnlyRole.Name = 'Group Test Only Role';
        groupOnlyRole.Type = 'Queue';
        groupOnlyRole.Email = 'grouptestonlyrole@tmbbank.com';
        insert groupOnlyRole;

        groupOnlyRoleAndSub.Name = 'Group Test Only Role And Sub';
        groupOnlyRoleAndSub.Type = 'Queue';
        groupOnlyRoleAndSub.Email = 'grouptestnlyroleandsub@tmbbank.com';
        insert groupOnlyRoleAndSub;

        groupTestSample.Name = 'A Group Test Sample';
        groupTestSample.Type = 'Queue';
        groupTestSample.Email = 'grouptestsample@tmbbank.com';
        insert groupTestSample;


        list<Group> list_g = [select id,Name,Type,Email,RelatedId from Group where Email like 'grouptest%'];

        //list<Group> list_gg = [select id,Name,Type,Email,RelatedId from Group where type IN('Role','RoleAndSubordinates') and RelatedId IN(Role_Parent.Id,Role_Child.Id,Role_Other.Id)];
        String query = 'select id,Name,Type,Email,RelatedId from Group where type IN(\'Role\',\'RoleAndSubordinates\') and RelatedId IN(\''+Role_Parent.Id+'\',\''+Role_Child.Id+'\',\''+Role_Other.Id+'\')';
        // System.debug('xxxxxxxxxxxxxxxxxxxxxxxxx');
        // System.debug(query);
        // System.debug('xxxxxxxxxxxxxxxxxxxxxxxxx');
        list<Group> list_gg = Database.query(query);

        Map<Id,Id> map_roleIdGroupId = new Map<Id,Id>(); // Map <RoleId,GroupId>  ---> Type == Role
        Map<Id,Id> map_roleAndSubIdGroupId = new Map<Id,Id>(); // Map <RoleId,GroupId>  ---> Type == RoleAndSubordinates          

        // System.debug('----- groupTestRole.Id : -----'+groupTestRole.Id);
        // System.debug('----- groupTestRoleAndSub.Id : -----'+groupTestRoleAndSub.Id);
        // System.debug('----- groupTestUser.Id : -----'+groupTestUser.Id);

        for(Group g : list_gg){
            if(g.Type == 'Role'){
                map_roleIdGroupId.put(g.RelatedId,g.Id);
                //System.debug(' Group Type Role ,Sub :   '+g);
            }else if(g.Type == 'RoleAndSubordinates'){
                map_roleAndSubIdGroupId.put(g.RelatedId,g.Id);
            }
        }

        // [4] initial Group Member

        //SELECT GroupId,Id,UserOrGroupId FROM GroupMember
        list<GroupMember> list_gm = new List<GroupMember>();
        GroupMember tmpGm = new GroupMember();

        // Add Group Member 1
        // GM 1.1 Role Parent
        tmpGm.GroupId = groupTestRole.Id; 
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Parent.Id );
        list_gm.add( tmpGm );
        // GM 1.2 Rold Child
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Child.Id );
        list_gm.add( tmpGm );
        // GM 1.3 User Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(12).Id; // user 12,13,14(Role Other)
        list_gm.add(tmpGm);
        // GM 1.4 User Parent Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(2).Id; // user 2, 5, 8, 11 Parent Role
        list_gm.add(tmpGm);
        // GM 1.5 User Child Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(0).Id; // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);

        // GM 1.5.1 User Child Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(3).Id; // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);
                
        // GM 1.6 User Other Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(1).Id; // user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);                

        // GM 1.6.1 User Other Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRole.Id;
        tmpGm.UserOrGroupId = ud.get(4).Id; // user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);                

        //GM 2 Add Group Member 2
        // GM 2.1 Role and Sub (Role Parent)
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Parent.Id );
        list_gm.add(tmpGm);                

        // GM 2.2 Role and Sub (Role Child)
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Child.Id );
        list_gm.add(tmpGm);                

        // GM 2.3 User Child 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(6).Id;  // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);

        // GM 2.3.1 User Child 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(9).Id;  // user 0, 3, 6, 9 Child Role
        list_gm.add(tmpGm);

        // GM 2.4 User Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(13).Id; // user 12,13,14 No Role
        list_gm.add(tmpGm);

        // GM 2.4.1 User Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);        

        // GM 2.5 User Role Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(7).Id; //user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm);        

        // GM 2.5.1 User Role Other 
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestRoleAndSub.Id;
        tmpGm.UserOrGroupId = ud.get(10).Id; //user 1, 4, 7, 10 Other Role
        list_gm.add(tmpGm); 

        // Add Group Member 3
        // GM 3.1 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(12).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);               
        // GM 3.1.1 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(13).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);   
        // GM 3.1.2 No Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id; // user 12,13,14 No Role 
        list_gm.add(tmpGm);

        // GM 3.2 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(1).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);               

        // GM 3.2.1 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(4).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);                   

        // GM 3.2.2 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(7).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);           

        // GM 3.2.3 Role Other
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestUser.Id;
        tmpGm.UserOrGroupId = ud.get(10).Id; // user 1, 4, 7, 10 Role Other 
        list_gm.add(tmpGm);

        // GM 4. Member Only Role
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupOnlyRole.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Child.Id );
        list_gm.add(tmpGm);

        // GM 5. Member Only Role and Sub
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupOnlyRoleAndSub.Id;
        tmpGm.UserOrGroupId = map_roleAndSubIdGroupId.get( Role_Parent.Id );
        list_gm.add(tmpGm);

        // GM 6. Group Test Sameple
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestSample.Id;
        tmpGm.UserOrGroupId = ud.get(14).Id;
        list_gm.add(tmpGm);

        // GM 6.1 Group Test Sample Test ReOrderInsert
        tmpGm = new GroupMember();
        tmpGm.GroupId = groupTestSample.Id;
        tmpGm.UserOrGroupId = map_roleIdGroupId.get( Role_Other.Id );
        list_gm.add(tmpGm);

        insert list_gm;

        // System.debug( '----- list Group Member 0(Id) -----'+ list_gm.get(0).Id );
        // System.debug( '----- list Group Member 1(Id) -----'+ list_gm.get(1).Id );
        // System.debug( '----- list Group Member 2(Id) -----'+ list_gm.get(2).Id );

        // [5] Initial QueueSobject
        //SELECT Id,QueueId,SobjectType FROM QueueSobject
        List<QueueSobject> list_queueSO = new List<QueueSobject>();
        QueueSobject tmp_queueSO = new QueueSobject();

        tmp_queueSO.QueueId = groupTestRole.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestRoleAndSub.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestUser.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupOnlyRole.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupOnlyRoleAndSub.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        tmp_queueSO = new QueueSobject();
        tmp_queueSO.QueueId = groupTestSample.Id;
        tmp_queueSO.SobjectType = 'Case';
        list_queueSO.add( tmp_queueSO );

        insert list_queueSO;

        // [6] initial BU Member
        User SYS_ADMIN = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        //system.runAs(SYS_ADMIN) 
        BU_Member__c tmpBuMember = new BU_Member__c();
        Datetime yesterday = Datetime.now().addDays(-1);

        tmpBuMember.Name = 'Test BU Name';
        tmpBuMember.BU_Email__c = 'testmyemail@tmbbank.com';
        tmpBuMember.External_ID__c = '001_ExernalId';
        tmpBuMember.Member_Name__c = ud.get(14).Id;
        tmpBuMember.Supported_Objects__c = 'Case';
        //tmpBuMember.createddate = yesterday;
        //tmpBuMember.lastModifiedDate = yesterday;
        system.runAs(SYS_ADMIN){
            insert tmpBuMember;
            Test.setCreatedDate(tmpBuMember.Id, yesterday);
        }
        


        //list<BU_Member__c> list_buMem = [select id,createddate,LastModifiedDate from BU_Member__c where BU_Email__c like 'testmyemail%'];
        // for(BU_Member__c buMem : list_buMem){
        //     System.debug('------------ createdDate      : '+buMem.createddate);
        //     System.debug('------------ lastModifiedDate : '+buMem.createddate);
        // }


        Test.StartTest();
        Database.executeBatch(new DeleteBuMember(),200);
        Test.StopTest();
    }

    /*
        Test Method for Class UpdateBuMemberBatchScheduled
    */
    @isTest static void UpdateBuMemberBatchScheduled_Test(){
        //Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
        String cron = '0 0 0 1 1 ? 2077';
        test.StartTest();
 
    // Schedule the test job
      String jobId = System.schedule('UpdateBuMemberBatchScheduled',cron, 
         new UpdateBuMemberBatchScheduled());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(cron, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2077-01-01 00:00:00', 
         String.valueOf(ct.NextFireTime));
         
        test.StopTest();
    }
    
}