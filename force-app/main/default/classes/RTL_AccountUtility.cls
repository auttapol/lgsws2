public class RTL_AccountUtility {

    static final Integer MAX_FIRSTNAME_LENGTH = 22;
    
    public static List<User> activeuser {
        get
        {
            if(activeuser == null){ 
                activeuser = [select Id,name,Employee_ID__c, RTL_Branch_Code__c ,isActive,Title,
                                      ManagerId, Manager.isActive, Manager.name 
                             from user];
            }
            return activeuser;
            
        }set;
    }

    public static Map<Id,UserRole> allUserRoleMap {
        get
        {
            if(allUserRoleMap == null){ 
                //allUserRoleMap [select Id, ParentRoleId from UserRole]
                allUserRoleMap = new Map<ID, UserRole>([SELECT  Id, ParentRoleId FROM UserRole]);
            }
            return allUserRoleMap;
            
        }set;
    }
    
    
    
    /*
    Method for Auto Create Commercial Contact from Commercial Account
    */
    public static void createCommercialContactFromAccount( Map<ID,Account> newAccountMap)
    {

        List<Account> newAccountList = newAccountMap.values();

        Id contactRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Retail Contact').getRecordTypeId();
        Id accountExistingCustomerRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
        List<Contact> nContacts = new List<Contact>();
        //List<Contact> uContacts = new List<Contact>();

        for(Account acct : newAccountList)
        {
            if( acct.RecordTypeId == accountExistingCustomerRT )
            {
                Contact nc = autoNewContactFromAccount(acct,contactRT);
                nContacts.add(nc);
            }
        }

        if(nContacts.size() > 0)
        {
            //insert nContacts;
            Database.SaveResult[] insertResult = Database.insert(nContacts,false);
            Database.SaveResult[] insertFailedResult = new Database.SaveResult[]{};

            for (Integer i = 0; i < insertResult.size(); i++) {
                if( !insertResult.get(i).isSuccess() )
                {
                    insertFailedResult.add( insertResult.get(i) );
                }
            }

            if( insertFailedResult.size() > 0 )
            {
                system.debug('Auto Create Contact Error[Insert new record]: '+insertFailedResult);
            }

        }


    }

    public static Contact fillerFirstAndLastName(Account acct, Contact ct){
    if( acct.Last_name_PE__c == null || acct.Last_name_PE__c == '' )
        {
         ct.LastName = '-';
        ct.Last_Name__c = '-';
        }
        else
        {
        ct.LastName = acct.Last_name_PE__c;
            ct.Last_Name__c = acct.Last_name_PE__c;
        }


         if( acct.First_name_PE__c != null )
         {
         if( acct.First_name_PE__c.length() > MAX_FIRSTNAME_LENGTH )
           {
             ct.FirstName = acct.First_name_PE__c.substring(0,MAX_FIRSTNAME_LENGTH);
      }
          else
        {
             ct.FirstName = acct.First_name_PE__c;
            }
         }

       ct.Email = acct.Email_Address_PE__c;
       ct.MobilePhone = acct.Mobile_Number_PE__c;

        return ct;
    }
    /*
    Method for Auto Update Commercial Contact from Commercial Account
    */
    public static void updateCommercialContactFromAccount(List<Account> newAccountList,List<Account> oldAccountList)
    {
        Id contactRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Retail Contact').getRecordTypeId();
        Id accountExistingCustomerRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Map<Id,Account> listAccsOld = new Map<Id,Account>();
        listAccsOld.putall(oldAccountList);

        Map<Id,Account> uAccounts = new Map<Id,Account>{};
        Map<Id,Account> oAccounts = new Map<Id,Account>{};



        for(Account acct : newAccountList)
        {

            Account nAcct = acct;
            Account oAcct = listAccsOld.get(acct.Id);

            if( acct.RecordTypeId != accountExistingCustomerRT )
            {
                continue;
            }

            // Field changed
            boolean updateContact = nAcct.Email_Address_PE__c != oAcct.Email_Address_PE__c || nAcct.First_name_PE__c != oAcct.First_name_PE__c || nAcct.Last_name_PE__c != oAcct.Last_name_PE__c || nAcct.Mobile_Number_PE__c != oAcct.Mobile_Number_PE__c;
            // Stage first changed
            boolean stageChange = (nAcct.Account_Type__c == 'Existing Customer' || nAcct.Account_Type__c == 'Retail Customer') && (oAcct.Account_Type__c != 'Existing Customer' && oAcct.Account_Type__c != 'Retail Customer');

            if( acct.Customer_Type__c == 'Individual' )
            {
                if( updateContact || stageChange )
                {
                    uAccounts.put(nAcct.Id, nAcct);
                    oAccounts.put(nAcct.Id, oAcct);
                }
            }
        }

        //=========== Update/Create Contact Process ======================
        List<Contact> uContacts = new List<Contact>{};
        Map<ID,Contact> accountContactTmbCustId = new Map<ID,Contact>();
        Map<ID,Contact> accountContactName = new Map<ID,Contact>();

        if(uAccounts.size() > 0){
            uContacts = [SELECT Id, AccountId, Email, MobilePhone, FirstName, LastName, TMB_Customer_ID__c, IsActive__c, Recordtype.Name FROM Contact WHERE AccountId IN :uAccounts.keySet()];

            for(Contact contact: uContacts) {
                if(contact.Recordtype.Name == 'Core bank' && !contact.IsActive__c) continue;
                Account account = uAccounts.get(contact.AccountId);
                Account accountOld = oAccounts.get(contact.AccountId);

                Boolean newNameMatch = contact.LastName == account.Last_name_PE__c && contact.FirstName == account.First_name_PE__c;
                Boolean oldNameMatch = contact.LastName == accountOld.Last_name_PE__c && contact.FirstName == accountOld.First_name_PE__c;

                // Check for match TMB cust ID
                if( contact.TMB_Customer_ID__c == account.TMB_Customer_ID_PE__c )
                {
                    if( ! accountContactTmbCustId.containsKey( account.id ) )
                    {
                        accountContactTmbCustId.put( account.id , contact );
                    }
                }
                // Check if First Name/ Last Name match
                else if( newNameMatch || oldNameMatch )
                {
                    if( ! accountContactName.containsKey( account.id ) )
                    {
                        accountContactName.put( account.id , contact );
                    }
                }

            }

        }

        List<Contact> updateContacts = new List<Contact>();
        List<Contact> newContact = new List<Contact>();

        List<Account> updatedAccountList = uAccounts.values();

        if( updatedAccountList.size() > 0 )
        {
            for(Account acct : updatedAccountList)
            {
                // If tmb cust id on contact already existing
                if( accountContactTmbCustId.containsKey( acct.id ) )
                {
                    Contact ct = accountContactTmbCustId.get(acct.id);
                    //ct.LastName = acct.Last_name_PE__c;
                    //ct.FirstName = acct.First_name_PE__c;

                    //new Method by Nong
                    ct = fillerFirstAndLastName(acct, ct);

                    updateContacts.add(ct);
                }
                // If tmb contact with same name as account present
                else if ( accountContactName.containsKey( acct.id ) )
                {
                    Contact ct = accountContactName.get(acct.id);
                    ct.TMB_Customer_ID__c = acct.TMB_Customer_ID_PE__c;
                    //ct.LastName = acct.Last_name_PE__c;
                    //ct.FirstName = acct.First_name_PE__c;

                    ct = fillerFirstAndLastName(acct, ct);

                    updateContacts.add(ct);
                }
                // If no suitable contact present , create new contact
                else
                {
                    Contact ct = autoNewContactFromAccount(acct,contactRT);
                    newContact.add(ct);
                }


            }
        }

        if( updateContacts.size() > 0 )
        {
            //update updateContacts;
            Database.SaveResult[] updateResult = Database.update(updateContacts,false);
            Database.SaveResult[] updateFailedResult = new Database.SaveResult[]{};

            for (Integer i = 0; i < updateResult.size(); i++) {
                if( !updateResult.get(i).isSuccess() )
                {
                    updateFailedResult.add( updateResult.get(i) );
                }
            }

            if( updateFailedResult.size() > 0 )
            {
                system.debug('Auto Create Contact Error[Update existing]: '+updateFailedResult);
            }
        }

        if( newContact.size() > 0 )
        {
            //insert newContact;
            Database.SaveResult[] insertResult = Database.insert(newContact,false);
            Database.SaveResult[] insertFailedResult = new Database.SaveResult[]{};

            for (Integer i = 0; i < insertResult.size(); i++) {
                if( !insertResult.get(i).isSuccess() )
                {
                    insertFailedResult.add( insertResult.get(i) );
                }
            }

            if( insertFailedResult.size() > 0 )
            {
                system.debug('Auto Create Contact Error[Insert new record]: '+insertFailedResult);
            }
        }

    }

    public static Contact autoNewContactFromAccount(Account acct, Id contactRT)
    {
        //System.debug('autoNewContactFromAccount - '+acct.Last_name_PE__c);
        Contact contact = new Contact();
        contact.AccountId = acct.Id;
        contact.Account__c = acct.Id;
        contact.RecordTypeId = contactRT;
        contact.TMB_Customer_ID__c = acct.TMB_Customer_ID_PE__c;

        contact = fillerFirstAndLastName(acct, contact);

        return contact;

    }

    public static Boolean verifyFieldSecurity(String SectionName , String UserProfileName , Id objId )
    {
        if( objId != null )
        {

         //   sObject obj = Database.query( ' SELECT id,recordTypeId,recordType.name,name FROM ' + objId.getsobjecttype() +' WHERE id = :objId '  );

        // String strRecordTypeId = (String)obj.get('recordTypeId');
        //    String recordTypeName =  objId.getsobjecttype().getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
            
            //system.debug( recordTypeName );
            String recordTypeName = '';
            String accessLevel = getAccountDataSecurity(SectionName,UserProfileName,recordTypeName );
            Boolean isVisible = getAccountAccessibility( objId , accessLevel );

            return isVisible; 
        }
        else 
        {
            return false;
        }
    }

    
    public static String getAccountDataSecurity(String section,String userProfile, String recordTypeName)
    {
        
        String accessType = '';
        try
        {
            // Latest requirement ignore query of record type
            Data_Security_Matrix__c dsm = [SELECT Profile_Name__c, Section_Name__c, Access_Type__c 
                    FROM Data_Security_Matrix__c 
                    WHERE Profile_Name__c =:userProfile 
                    //AND Record_Type__c = :recordTypeName
                    AND Section_Name__c = :section
                    LIMIT 1
                    ];
            accessType = dsm.Access_Type__c;
            
        }
        catch (Exception e)
        {
            //*** In case of not found or any error occured, set visible status to no access
            //sm.accessType = 'All';
            accessType = 'No Access';
        }
        
        return accessType;
    }
    
    public static boolean getAccountAccessibility(Id objId,String accessType)
    {
        
        Boolean isVisible = false;        
        
        if( accessType == 'All' )
        {
            isVisible = true;
        }
        else if ( accessType == 'No Access' )
        {
            isVisible = false;
        }
        else if ( accessType == 'Authorize Only' )
        {
            isVisible = SecurityScan.verifyForAuth(objId);
        }
        
        return isVisible;
    }
    
    public static List<Id> getAccountTeamMeammer(Id accId)
    {
    //Get User Id from AccountTeamMember which AccountId matches
List<Id> teamMemberId = new List<Id>();
        for ( AccountTeamMember atc : [select AccountId,UserId,AccountAccessLevel
                                       FROM AccountTeamMember WHERE AccountId =:accId ]){
            if( atc.AccountAccessLevel == 'Read' || atc.AccountAccessLevel == 'Edit' )
            {
                teamMemberId.add(atc.UserId);
            }
        }
        return teamMemberId;
    }
    
    public static List<Id> getAccountShare(Id accId)
    {
        List<Id> accountShareMemberId = new List<Id>();
    for ( AccountShare accShare : [SELECT Id, UserOrGroupId, AccountId, AccountAccessLevel
              FROM AccountShare WHERE AccountId =: accId ] )
        {
            accountShareMemberId.add( accShare.UserOrGroupId );
        }
        
        return accountShareMemberId;
    }
    
    /*
    public static boolean getAccountAccessibility(Account acc,String accessType)
    {
        Boolean isVisible = false;
        
        if( accessType == 'All' )
        {
            isVisible = true;
        }
        else if ( accessType == 'No Access' )
        {
            isVisible = false;
        }
        else if ( accessType == 'Authorize Only' )
        {
            
            Id UserId = UserInfo.getUserId();
            User cu = new User();

            try{
                cu = [SELECT Id,name,Employee_ID__c,UserRoleId ,UserRole.name  FROM User WHERE id = :UserId ];
            }
            catch (Exception e)
            {
                // No user found mean 
                
                isVisible = false;
                return isVisible;
            }

            List<Id> accountOwnerList = new List<Id>();

            //Get Account owner 
            if( acc.OwnerId != null )
            {
                accountOwnerList.add(acc.OwnerId);
            }

            //Get EMP/BR Code
            if( acc.RTL_RM_Name__c != null )
            {
                List<User> tempUL = [SELECT Id,name,Employee_ID__c FROM User WHERE Employee_ID__c = :acc.RTL_RM_Name__c ];

                if( tempUL.size() > 0 )
                {
                    accountOwnerList.add( tempUL.get(0).id );
                }
            }

            //Get User Id from AccountTeamMember which AccountId matches

            for ( AccountTeamMember atc : [select AccountId,UserId,AccountAccessLevel
                    FROM AccountTeamMember WHERE AccountId =:acc.id ]){
                if( atc.AccountAccessLevel == 'Read' || atc.AccountAccessLevel == 'Edit' )
                {
                    accountOwnerList.add(atc.UserId);
                }
            }

            Map<Id,User> mul = new Map<Id,User>( [ SELECT id,name, UserRoleId ,UserRole.name, UserRole.ParentRoleId
                FROM User WHERE id in :accountOwnerList ] );

            //system.debug('gade: '+mul);       

            // Check if current User existing in User list 
            // Owner , EMP Code or team member
            if( mul.containsKey(UserId) )
            {
                isVisible = true;
            }
            // Else then check for Hiughter role hierachy
            else
            {
                Id currentRoleId = cu.UserRoleId;

                Set<ID> allParentRoles = new Set<Id>();
                Set<ID> setChildRoles = new Set<Id>();

                for( User acessU : mul.values() )
                {
                    //system.debug('a: ' + getParentRoleId( acessU.UserRoleId ) );
                    //allParentRoles.addAll( getParentRoleId( acessU.UserRoleId ) );
                    if( acessU.UserRoleId != null )
                    {
                        setChildRoles.add(acessU.UserRoleId);
                    }
                }

                // system.debug('a: ' + setChildRoles);
                allParentRoles = getParentRoleId( setChildRoles );

                // currentRole
                // system.debug('a: ' + currentRoleId );
                // system.debug('b: ' + allParentRoles );

                if( allParentRoles.contains(currentRoleId) )
                {
                    isVisible = true;
                }
                else
                {
                    isVisible = false;
                }
            }
        }
        
        return isVisible;
      
    }
    */
   

    
    public static Set<ID> getParentRoleId(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        
        // get all of the parent roles.
        // for(UserRole ur :[select Id, ParentRoleId from UserRole where Id IN: roleIds]) {
        //    currentRoleIds.add(ur.ParentRoleId);
        // }
       
        
        for( ID roleId : roleIds )
        {
            if( allUserRoleMap.containsKey(roleId) )
            {
            	ID parentRoleId = allUserRoleMap.get(roleId).ParentRoleId;
                currentRoleIds.add(parentRoleId);
            }
        }
        
        // system.debug('currentRoleIds: ' + currentRoleIds);
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getParentRoleId(currentRoleIds));
        }
    
        return currentRoleIds;
    }

    public static String getWealth_RM(Account accRM){
        Map<String,List<User>> branchCodeUserMap = new Map<String,List<User>>();
        Map<String,User> empCodeUserMap = new Map<String,User>();
        
        branchCodeUserMap = AccountUtility.getBranchCodeUserMap();
        empCodeUserMap = AccountUtility.getEmpCodeUserMap();
        
        String branchManagerTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager').RTL_Value__c;
        String Wealth_RM_ID = null;
        User newWealthRM;
        User manager;
        
        try{
            if( accRM.RTL_RM_Name__c != null ){
                string empBrCode = accRM.RTL_RM_Name__c;

                //If EMP/BR Code starts with 00 , find User with this branch code and is a branch manager
                if(empBrCode.startsWith('00')){
                    empBrCode = empBrCode.substring(2);
                    if(accRM.RTL_Assigned_BRC__c != null) {
                        if(mapUserById.containsKey(accRM.RTL_Assigned_BRC__c)) {
                            User assignBRC =  mapUserById.get(accRM.RTL_Assigned_BRC__c);
                            if(assignBRC.IsActive) {
                                newWealthRM = assignBRC;
                                Wealth_RM_ID = newWealthRM.Id;
                            }
                        }
                    } else if(accRM.RTL_Most_Operating_Branch__c != null) {
                        if(mapBranchZoneById.containsKey(accRM.RTL_Most_Operating_Branch__c)) {
                            Branch_and_zone__c branchZone = mapBranchZoneById.get(accRM.RTL_Most_Operating_Branch__c);
                            if(branchZone.RTL_Branch_Manager_User__r != null && branchZone.RTL_Branch_Manager_User__r.IsActive)
                            {
                                Wealth_RM_ID = branchZone.RTL_Branch_Manager_User__c;
                            }
                        }
                    } 
                }
                //else find a User with EMP/BR = Employee_Id   
                else{
                    if(empCodeUserMap.containsKey(empBrCode)){
                        newWealthRM = empCodeUserMap.get(empBrCode);
                        Wealth_RM_ID = newWealthRM.Id;
                    }
                } 
            }
        }catch(Exception e){
            System.debug('getWealth_RM error = ' + e.getMessage() + ' line ' + e.getLineNumber() );
        }
        return Wealth_RM_ID;
    }
    
    public static List<Account> getAccountwithRM_Name(Set<Id> accountId){
        List<Account> acctRM = [SELECT ID,Name,RTL_RM_Name__c FROM Account WHERE RTL_RM_Name__c != null AND ID IN :accountId];
        return acctRM;
    }

    public static Map<Id,User> mapUserById {
        get;set;
    }
    
    public static Map<Id,User> generateUserMapId(Set<Id> userId){
        if(userId.size() > 0 && mapUserById == null) {
            mapUserById = new Map<Id, User>([SELECT ID,Name,Employee_ID__c,IsActive,ManagerId,Manager.IsActive FROM User WHERE ID IN :userId]);
        }
        return mapUserById;
    }

    public static Map<Id,Branch_and_Zone__c> mapBranchZoneById {
        get;set;
    }

    public static Map<Id,Branch_and_Zone__c> generateBranchZoneMapId(Set<Id> branchZoneId){
        if(branchZoneId.size() > 0 && mapBranchZoneById == null) {
            mapBranchZoneById = new Map<Id, Branch_and_Zone__c>([SELECT Id, Name, Branch_Code__c, RTL_Branch_Manager_User__c, RTL_Branch_Manager_User__r.Name, RTL_Branch_Manager_User__r.IsActive FROM Branch_and_Zone__c WHERE ID IN :branchZoneId]);
        }
        return mapBranchZoneById;
    }
}