public with sharing class RTL_CampaignCallListExtension {

    class roleAccessibility{
        public Boolean IsAllowChangeBranch {get;set;}
        public Boolean IsAllowedReAssign {get;set;}
        public String Role {get;set;}
    }

    public roleAccessibility roleAcc {
        get{
            
            if( roleAcc == null )
            {
                String roleName = currentUser.UserRole.Name;

                roleAcc = new roleAccessibility();

                if( roleName != null )
                {
                    List<RTL_Campaign_Reassign_Role_Setting__mdt> crrsList = [SELECT ID,IsAllowChangeBranch__c,IstAllowedReAssign__c,role_name__c,Role_Type__c 
                                                            FROM RTL_Campaign_Reassign_Role_Setting__mdt ];

                    for( RTL_Campaign_Reassign_Role_Setting__mdt crrs : crrsList )
                    {
                        if( roleName.startsWith( crrs.role_name__c ) )
                        {
                            roleAcc.IsAllowChangeBranch = crrs.IsAllowChangeBranch__c;
                            roleAcc.IsAllowedReAssign = crrs.IstAllowedReAssign__c;
                            roleAcc.Role = crrs.Role_Type__c;
                            break;
                        }
                    }
                }
            }

            if( roleAcc.Role == null )
            {
                roleAcc.IsAllowChangeBranch = false;
                roleAcc.IsAllowedReAssign = false;
                roleAcc.Role = '';
            }

            return roleAcc;
            
        }
        set;
    }

    public String CampaignID;
    public String CampaignMemberID {get;set;}
    public String campaignwrapperListJSON {get;set;}
    public CampaignMember CampMemObj {get;set;}
    public CampaignMember camMemReassign {get;set;}
    public transient Map<String,String> campaignMap {get;set;}
    

    public List<SelectOption> userOwnerSelectionList {get{
        if(userOwnerSelectionList == null){
            userOwnerSelectionList = new List<SelectOption>();
            userOwnerSelectionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
            userOwnerSelectionList.add(new SelectOption('My List',Label.RTL_Campaign_CallList_MyList_Option)); 
            userOwnerSelectionList.add(new SelectOption('My team List',Label.RTL_Campaign_CallList_MyTeamList_Option));          
        }
        return userOwnerSelectionList;
    }
    set;}
    public List<SelectOption> offerResultSelectList {get{
        if(offerResultSelectList == null){
            offerResultSelectList = new List<SelectOption>();

            offerResultSelectList.add(new SelectOption(Label.RTL_Campaign_Member_Filter_Offer_Pending, Label.RTL_Campaign_Member_Filter_Offer_Pending ));
            //offerResultSelectList.add(new SelectOption(Label.RTL_Campaign_Member_Filter_Offer_Interest ,Label.RTL_Campaign_Member_Filter_Offer_Interest ));
            offerResultSelectList.add(new SelectOption(Label.RTL_Campaign_Member_Filter_Offer_NotInterest ,Label.RTL_Campaign_Member_Filter_Offer_NotInterest ));
        }
        return offerResultSelectList;
        }set;}

    private Set<ID> retailRecordTypeIDset {
        get{
            if( retailRecordTypeIDset == null )
            {
                retailRecordTypeIDset = new Set<ID>();
                 for(Recordtype perRecordType :  [SELECT ID from Recordtype 
                            WHERE sObjectType ='Campaign'
                            AND (NOT DeveloperName LIKE '%Master%')
                            AND (NOT DeveloperName LIKE '%Dummy%')
                            AND (NOT DeveloperName LIKE '%Commercial%')]){
        
                                retailRecordTypeIDset.add(perRecordType.id); 
                            }
            }

            return retailRecordTypeIDset;
        }
        set;

    }

    public List<SelectOption> CampaignSelectOptionList {get{
            if(CampaignSelectOptionList == null){

                CampaignSelectOptionList = new List<SelectOption>();
                CampaignSelectOptionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));

                // For User not defined in Custom meta data, cannot see campaign member
                if( userType == 'other' )
                {
                    return CampaignSelectOptionList;
                }

                String userId = currentUser.id;

                //Query campaign id which this user can see atlease one member
                String CountQuery ='SELECT Count(id),campaignId,campaign.Name from CampaignMember ';
                CountQuery += 'WHERE Campaign.RecordTypeId IN :retailRecordTypeIDset ';
                CountQuery += 'AND Campaign.Status  != \'Expired\' ';
                CountQuery += 'AND Campaign.isActive = true ';
                //CountQuery += 'AND ( Campaign.isActive = true OR ( Campaign.status = \'On Hold\' AND RTL_Contact_Staff_Name__c != NULL ) ) ';
                CountQuery += 'AND Campaign.RTL_Call_Start_Date__c <= TODAY AND Campaign.RTL_Call_End_Date__c >= TODAY ';

                
                if(  userType == 'Agent' || userType == 'BrancManager')
                {
                    CountQuery += 'AND ( RTL_Assigned_Branch__c = :userBranchId OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ';
                    if( userType == 'Agent'  )
                    {
                        CountQuery += 'AND ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Branch__c = :userBranchId AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ';
                    }
                }
                else if (  userType == 'WM-TL' || userType == 'WM-RM' )
                {
                    String zoneCode = currentUser.Zone_Code__c;
                    CountQuery += 'AND ( RTL_Assigned_Zone_Rpt__c = :zoneCode OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ';
                    if( userType == 'WM-RM'  )
                    {
                        CountQuery += 'AND ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Zone_Rpt__c = :zoneCode AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ';
                    }
                }
                CountQuery += 'Group By campaignId,campaign.Name ';

                //AggregateResult[] groupedResults = Database.query(CountQuery);


                Set<ID> campaignIds = new Set<ID>();
                for (AggregateResult result :  database.query(CountQuery) )
                { 

                    if( (Integer)result.get('expr0') > 0 )
                    {
                        campaignIds.add( (ID)result.get('campaignId') );
                    }
                }
                

                //Set<ID> campaignIds = new Set<ID>();
                //for( AggregateResult gr : groupedResults )
                //{
                //    if( (Integer)gr.get('expr0') > 0 )
                //    {
                //        campaignIds.add( (ID)gr.get('campaignId') );
                //    }
                //}

                //====================

                for(Campaign cp : [SELECT ID,RecordTypeId,Status,isActive,Name 
                                FROM Campaign 
                                WHERE RecordTypeId IN:retailRecordTypeIDset
                                AND Status != 'Expired'
                                //AND isActive=true
                                AND RTL_Call_Start_Date__c <= TODAY AND RTL_Call_End_Date__c >= TODAY
                                AND ID in :campaignIds
                                ORDER BY RTL_Campaign_Order__c ASC ,NAME ASC]){

                    CampaignSelectOptionList.add(new SelectOption(cp.id,cp.Name));
                    
                }
                

            }
            return CampaignSelectOptionList;
        }set;}

    public List<SelectOption> contactStatusSelectionList {get{
        if(contactStatusSelectionList == null){
            contactStatusSelectionList = new List<SelectOption>();
            contactStatusSelectionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));

            Schema.DescribeFieldResult fieldResult = CampaignMember.RTL_Contact_Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            Set<String> availableOptions = new Set<String>{'New', 'Contact', 'Follow-up', 'Re-attempt','Not Contact'};
           /* availableOptions.add('Not Contact');
            availableOptions.add('Close');*/            
            
            for( Schema.PicklistEntry f : ple)
            {
                if( availableOptions.contains( f.getValue() ) )
                {
                    contactStatusSelectionList.add(new SelectOption(f.getValue(), f.getLabel() ));
                }
            }  

            
        }
        return contactStatusSelectionList;
    }
    set;}

    public List<SelectOption> invitationStatusSelectionList {get{
        if(invitationStatusSelectionList == null){
            invitationStatusSelectionList = new List<SelectOption>();
            invitationStatusSelectionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));

            Schema.DescribeFieldResult fieldResult = CampaignMember.RTL_Invitation_Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            //Set<String> availableOptions = new Set<String>{'New', 'Contact', 'Follow-up', 'Re-attempt'};

            for( Schema.PicklistEntry f : ple)
            {
                //if( availableOptions.contains( f.getValue() ) )
                //{
                    invitationStatusSelectionList.add(new SelectOption(f.getValue(), f.getLabel() ));
                //}
            }  

            
        }
        return invitationStatusSelectionList;
    }
    set;}

    //public String selectedOwner {get;set;}
    public boolean isFromCampaign {get;set;}
    public boolean isFromHomeScreen {get;set;}
    public boolean isSearchScreen {get;set;}
    public boolean isRelocateScreen {get;set;}
    public boolean isToggleSelectAll {get;set;}
    public Integer OffsetSize {get;set;}
    private Integer QueryLimit = 50;
    public Integer CountTotalRecords {get;set;}
    public Integer MaxNumoberofRecords {get;set;}
    public Integer StartNumberofRecords {get;set;}
    //public Datetime callEndDate {get;set;}

    // Not implement search cache
    //private RTL_Campaign_CallList_Search_Cache__c searchCache{
    //    get{
    //        if( searchCache ==null )
    //        {
    //            String userId = Userinfo.getUserId();
    //            try {
    //                searchCache = [SELECT id,RTL_User__c,RTL_Call_End_Date__c,
    //                    RTL_Campaign__c,RTL_Contact_Status__c,RTL_Invitation_Status__c,
    //                    RTL_Offer_Result__c,RTL_Owner__c
    //                    FROM RTL_Campaign_CallList_Search_Cache__c 
    //                    WHERE RTL_User__c = :userId
    //                ];
    //            } catch(Exception e) {
    //                searchCache = new RTL_Campaign_CallList_Search_Cache__c();
    //                searchCache.RTL_User__c = userId;
    //            }             
    //        }
    //        return searchCache;   
    //    }
    //    set;
    //}

   

    private string isMyCallList;

    private static final Integer NORECORDPERPAGE = 5;

    public class getPdpaDataWrapper{
        public Integer RowNumber {get;set;}
        public String TMBCustomerID {get;set;}
    }

    public class CampaignMemberWrapper{
        public Integer RowNumber {get;set;}
        public CampaignMember campaignmemberobj {get;set;}
        public boolean isSelected {get;set;}
        public String Title {get;set;}
        public String CompanyName {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String Email {get;set;}
        public String Type {get;set;}
        public String CampaignName {get;set;}
        // For display in table for debug
        public Date CallEndDate{get;set;}
        public String ContactStatus {get;set;}
        public String offerResult {get;set;}
        public String invitationStatus {get;set;}
        public String TMBCustomerID {get;set;}
        public Boolean DoNotContact {get;set;}

        public String getLastContactStatusLabel()
        {
            return RTL_Utility.transLastContactStatus(campaignmemberobj.RTL_Last_Contact_Status__c);
        }
    }


    public  List<CampaignMember> CampaignMemberList {get{
        if(CampaignMemberList ==null){
            CampaignMemberList = new List<CampaignMember>();
        }
        return CampaignMemberList;
        } set;}


    public List<CampaignMemberWrapper> campaignwrapperList {get{
        if(campaignwrapperList ==null){
            campaignwrapperList = new List<CampaignMemberWrapper>();   
        }
        return campaignwrapperList;                                          

    }set;}

    public List<getPdpaDataWrapper> getPdpaDataWrapperList {
        get{
            if(getPdpaDataWrapperList ==null){
                getPdpaDataWrapperList = new List<getPdpaDataWrapper>();   
            }
            return getPdpaDataWrapperList;                                          
        }set;
    }

    public User currentUser{
        get{
            if( currentUser == null )
            {
                currentUser = [SELECT ID,UserRole.Name, User.Profile.Name,
                        RTL_Channel__c,Zone_Code__c, RTL_Branch_Code__c 
                FROM USER WHERE ID =:Userinfo.getUserId() ];
            }
            return currentUser;
        }
        set;
    }
            
    private String userType {
        get{
            if(userType == null)
            {
                //String roleName = currentUser.UserRole.Name;
                
                if( roleAcc.Role != null &&  roleAcc.Role != '' )
                {
                    //if( roleName.startsWith('BR-Sales-Zone') )
                    if( roleAcc.Role == 'BR-Sales-Zone' ) 
                    {
                        userType = 'Agent'; 
                    }
                    //else if( roleName.startsWith('BR-MGR-Zone') )
                    else if( roleAcc.Role == 'BR-MGR-Zone' )
                    {
                        userType = 'BrancManager';
                    }
                    //else if( roleName.startsWith('WM-TL') )
                    else if( roleAcc.Role == 'WM-TL' ) 
                    {
                        userType = 'WM-TL';
                    }
                    //else if( roleName.startsWith('WM-RM') )
                    else if( roleAcc.Role == 'WM-RM' ) 
                    {
                        userType = 'WM-RM';
                    }
                    else if ( roleAcc.Role == 'CRBO' || roleAcc.Role == 'CEO' )
                    {
                        userType = 'SuperUser';
                    }
                    else 
                    {
                        userType = 'other';                        
                    }

                }
                else 
                {
                    userType = 'other';   
                }



            }
            return userType;
        }
        set;
    }

    private String userBranchId {
        get{
            if( userBranchId == null )
            {
                //User currentuser = [SELECT ID,UserRole.Name,
                //        RTL_Channel__c,Zone_Code__c, RTL_Branch_Code__c 
                //        FROM USER WHERE ID =:Userinfo.getUserId() ];

                if(currentuser.RTL_Branch_Code__c !=null){
                    List<Branch_and_Zone__c> BranchZonelist =  [SELECT ID,Branch_Code__c  from Branch_and_zone__c
                                                  WHERE Branch_Code__C =: currentuser.RTL_Branch_Code__c LIMIT 1];
                    if(BranchZonelist.size()>0){
                        Branch_and_Zone__c baz = BranchZonelist.get(0);
                        userBranchId = baz.id;
                    }
                }
            }
            return userBranchId;
        }
        set;
    }

    public String searchcamMemCampaignID{get;set;}
    public String searchcamMemContactStatus{get;set;}
    //public Date searchcamMemEndDate{get;set;}
    public String searchcamMemOfferResult{get;set;}
    public String searchcamMemInvitationStatus{get;set;}
    public String searchselectedOwner{get;set;}

    private String firstSorting;
    private String lastSorting;

    //public string debug {get;set;}

    public RTL_CampaignCallListExtension(ApexPages.StandardController stdController) {


        CampaignID = Apexpages.CurrentPage().getParameters().get('campaignid');
        isMyCallList = Apexpages.CurrentPage().getParameters().get('mylist');

        CampMemObj = new CampaignMember();
        CampMemObj.Campaign = new Campaign();
        CampMemObj.Campaign.RTL_Call_End_Date__c = null;

        camMemReassign = new CampaignMember();
        isFromCampaign =false;
        isFromHomeScreen = false;                             
        isSearchScreen =true;
        isRelocateScreen =false;
        isToggleSelectAll = false;
        OffsetSize = 0;

        searchcamMemOfferResult = Label.RTL_Campaign_Member_Filter_Offer_Pending;

        // When navigate to callist directly , call search cache
        if( CampaignID == null && isMyCallList == null )
        {
            CampMemObj.RTL_Contact_Status__c = '';
            searchcamMemContactStatus='';
           
        }
        else if( isMyCallList == '1' )
        {
            //selectedOwner = 'My List';
            //searchselectedOwner = selectedOwner;
            searchselectedOwner = 'My List';
            CampMemObj.RTL_Contact_Status__c = '';
        }
        else if(CampaignID !=null && CampaignID !='')
        {
            isFromCampaign = true;
            CampMemObj.CampaignID = CampaignID;
            searchcamMemCampaignID = CampaignID;
            searchselectedOwner = 'My team List';
            CampMemObj.RTL_Contact_Status__c = '';
             
        }

        queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
        
    }
    
    public List<CampaignMemberWrapper>  queryPaginateCampaignMemberWrapperList(Integer NoOflimit,String type)
    {
        system.debug('Start Query :: ' + userType);
        if( userType == 'other' )
        {
            return new List<CampaignMemberWrapper> ();
        }

        campaignwrapperList = new List<CampaignMemberWrapper>();
        getPdpaDataWrapperList = new List<getPdpaDataWrapper>();
        String userId = currentUser.id;

        List<String> filterStringList = new List<String>();

        MaxNumoberofRecords = 0;

        String CountQuery ='SELECT Count(id) from CampaignMember ';

        String QueryString = 'SELECT ID,CampaignID,Campaign.Name,LeadID,ContactID,Name,RTL_Contact_Status__c,RTL_Channel__c, ' +
                                                    'RTL_Campaign_Priority__c,RTL_Campaign_Channel_formula__c, '+
                                                    'RTL_Contact_Staff_Name__c,RTL_Invitation_Status__c, ' +
                                                    'RTL_Assigned_Zone_Rpt__c,RTL_Assigned_Agent__r.FirstName,RTL_Assigned_Agent__r.LastName, '+
                                                    'RTL_Contact_Staff_Name__r.FirstName,RTL_Contact_Staff_Name__r.LastName, '+
                                                    'LastModifiedDate,Lead.Status,RTL_Assigned_Agent__c,RTL_Assigned_Branch__c,RTL_Campaign_EndDate__c, '+
                                                    'Status,Lead_Status__c,Lead.Title,Lead.FirstName,Lead.LastName, '+
                                                    'Contact.FirstName,Contact.Lastname,RTL_Offer_Result__c, '+
                                                    'Lead.Name,Contact.Name,Contact.Title,Lead.Company, '+
                                                    'contact.Account.Name,lead.email,contact.email, '+
                                                    'RTL_Segmentation__c,RTL_Last_Contact_Status__c,Campaign.RTL_Call_End_Date__c, '+
                                                    'RTL_Campaign_Member_Sorting_Order__c,RTL_Company_Account__c, '+
                                                    'RTL_Segment__c,RTL_Promotion__c,RTL_Product_Feature__c,customer__c,Customer__r.Name,Contact.TMB_Customer_ID__c '+
                                                    ',RTL_AL_response__c,Customer__r.RTL_Do_Not_Contact__c,Customer__r.DNC_Expired_Date__c,Campaign.Filter_Out_Do_Not_Contact__c '+
                                                    ',RTL_Channel_Subsidiary__c '+
                                                    'from CampaignMember ';

        String suffixQueryString = '';
        // [2021-07-13] Filter do not contact to false
        // filterStringList.add(' (Customer__r.DNC_Expired_Date__c = null OR Customer__r.DNC_Expired_Date__c < TODAY OR Campaign.Filter_Out_Do_Not_Contact__c = \'No\' OR Campaign.Filter_Out_Do_Not_Contact__c = null) ');
        filterStringList.add(' (Not (Campaign.Filter_Out_Do_Not_Contact__c = \'Yes\' And Customer__r.DNC_Expired_Date__c != null And Customer__r.DNC_Expired_Date__c > TODAY)) ');
        if( type == 'next' )
        {
            suffixQueryString = ' ORDER BY RTL_Campaign_Member_Sorting_Order__c ASC NULLS LAST ';
            filterStringList.add(' RTL_Campaign_Member_Sorting_Order__c > :lastSorting ');

        }
        else if ( type == 'previous' )
        {
            suffixQueryString = ' ORDER BY RTL_Campaign_Member_Sorting_Order__c DESC NULLS LAST ';
            filterStringList.add(' RTL_Campaign_Member_Sorting_Order__c < :firstSorting ');
        }
        else  if ( type == 'init' )
        {
            suffixQueryString = ' ORDER BY RTL_Campaign_Member_Sorting_Order__c ASC NULLS LAST ';
        }

        String limitsQueryString = ' LIMIT :NoOflimit';

        if(searchcamMemCampaignID !=null&& searchcamMemCampaignID !=''){
            filterStringList.add(' CampaignID = :searchcamMemCampaignID ');
        }

        if(searchcamMemContactStatus !=null && searchcamMemContactStatus !=''){
            filterStringList.add(' RTL_Contact_Status__c = :searchcamMemContactStatus ');
        }

        //if( searchcamMemEndDate != null )
        //{
        //    filterStringList.add(' Campaign.RTL_Call_End_Date__c <= :searchcamMemEndDate ');
        //}

        if(searchcamMemOfferResult !=null && searchcamMemOfferResult !=''){
            filterStringList.add(' RTL_Offer_Result__c = :searchcamMemOfferResult ');
        }

        if(searchcamMemInvitationStatus !=null && searchcamMemInvitationStatus !=''){
            filterStringList.add(' RTL_Invitation_Status__c = :searchcamMemInvitationStatus ');
        }

        //============= Defualt Filter base on User Type =============

        filterStringList.add(' Campaign.RecordTypeId IN :retailRecordTypeIDset ');
        filterStringList.add(' Campaign.Status  != \'Expired\' ');
        filterStringList.add(' ( Campaign.isActive = true OR ( Campaign.status = \'On Hold\' AND RTL_Contact_Staff_Name__c != NULL ) ) ');
        filterStringList.add(' Campaign.RTL_Call_Start_Date__c <= TODAY AND Campaign.RTL_Call_End_Date__c >= TODAY ');

        // Normal User see only Campaing Member assinged to their branch
        if(  userType == 'Agent' || userType == 'BrancManager')
        {
            filterStringList.add(' ( RTL_Assigned_Branch__c = :userBranchId OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ');
        }
        // Wealth User see only Campaing Member assinged to their zone
        else if (  userType == 'WM-TL' || userType == 'WM-RM' )
        {
            String zoneCode = currentUser.Zone_Code__c;
            filterStringList.add(' ( RTL_Assigned_Zone_Rpt__c = :zoneCode OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ');
            // Wealth team now allowed to see campaign member event it assigned to branch
            //filterStringList.add(' RTL_Assigned_Branch__c = null ');
        }

        if( searchselectedOwner == 'My List' )
        {
            filterStringList.add('( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId )');
        }
        else if (searchselectedOwner == 'My team List')
        {
            if( userType == 'BrancManager' || userType == 'WM-TL'  )
            {
                // No filter , see all Campaign Member from thier zone 
                if( userType == 'BrancManager'  )
                {
                    filterStringList.add(' RTL_Assigned_Branch__c = :userBranchId ');
                }
                else if( userType == 'WM-TL'  )
                {
                    filterStringList.add(' RTL_Assigned_Zone_Rpt__c = :zoneCode ');
                }
            }
            else if( userType == 'Agent' || userType == 'WM-RM'  )
            {
                // Assigned Branch/Zone Must be same as User's 
                if( userType == 'Agent'  )
                {
                    filterStringList.add(' RTL_Assigned_Branch__c = :userBranchId ');
                }
                else if( userType == 'WM-RM'  )
                {
                    filterStringList.add(' RTL_Assigned_Zone_Rpt__c = :zoneCode ');
                }

                filterStringList.add(' RTL_Assigned_Agent__c = null ');
                filterStringList.add(' RTL_Contact_Staff_Name__c = null ');
            }

        }   
        // no select owner , See All - with atleast branch/contact/assigned assing to current user
        else 
        {
            if( userType == 'BrancManager' || userType == 'WM-TL'  )
            {
                // No filter , see all Campaign Member from thier zone 
            }
            else if( userType == 'Agent' || userType == 'WM-RM'  )
            {
                if( userType == 'Agent'  )
                {
                    filterStringList.add(' ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Branch__c = :userBranchId AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ');
                }
                else if( userType == 'WM-RM'  )
                {
                    filterStringList.add(' ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Zone_Rpt__c = :zoneCode AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ');
                }
                //filterStringList.add(' ( RTL_Assigned_Agent__c = null OR ( RTL_Assigned_Agent__c != null  AND ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId ) ) ) ');
                //filterStringList.add(' ( RTL_Assigned_Agent__c = null OR RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId ) ');
            }
        }
      

        
       // if(searchcamMemAssignedBranch!=null && searchcamMemAssignedBranch !=''){
       //     filterStringList.add(' RTL_Assigned_Branch__c = :searchcamMemAssignedBranch ');
       // }
       // if(searchcamMemberType !=null && searchcamMemberType !=''){
       //         if(selectedtype=='Lead'){
       //             filterStringList.add(' LeadID !=null ');
       //         }else if(selectedtype=='Contact'){
       //             filterStringList.add(' ContactID !=null ');
       //         }
       // }
       // if(searchcamMemAssignedAgent !=null && searchcamMemAssignedAgent !=''){
       //     filterStringList.add(' RTL_Assigned_Agent__c = :searchcamMemAssignedAgent ');
       // }


        if(filterStringList.size()>0){
            QueryString +=' WHERE ';
            CountQuery +=' WHERE ';
            integer index = 1;
            for(String filterstr : filterStringList){
                if(index !=1){
                    QueryString += ' AND ';
                    CountQuery += ' AND ';
                }
                QueryString += filterstr;
                CountQuery += filterstr;
                index++;
            }
        }

        if( type == 'init' )
        {
            //countTotalRecords = Database.countQuery(CountQuery);
            countTotalRecords = 0;
            for (AggregateResult result :  database.query(CountQuery) ) countTotalRecords += (Integer)result.get('expr0');
        }

        QueryString += suffixQueryString + limitsQueryString;

        //CampaignMemberList = (List<CampaignMember>)Database.query(QueryString);
        List<CampaignMember> CampaignMemberTmpList = (List<CampaignMember>)Database.query(QueryString);
        System.debug('CountQuery : ' + CountQuery);
        System.debug('QueryString : ' + QueryString);
        // Resort result order then process
        CampaignMemberList = new List<CampaignMember>();
        if( type == 'next' || type == 'init' )
        {
            CampaignMemberList = CampaignMemberTmpList;
            
        }
        else if ( type == 'previous' )
        {
            for(Integer i = CampaignMemberTmpList.size() - 1; i >= 0; i--){
                CampaignMemberList.add(CampaignMemberTmpList[i]);
            }
        }
        
        campaignMap = new Map<String,String>();
        Set<ID> campaignIDSet = new Set<ID>(); 
        System.debug('searchcamMemCampaignID : ' + searchcamMemCampaignID);
        System.debug('lastSorting : ' + lastSorting);
        System.debug('searchcamMemOfferResult : ' + searchcamMemOfferResult);
        System.debug('retailRecordTypeIDset : ' + retailRecordTypeIDset);
        System.debug('userBranchId : ' + userBranchId);
        System.debug('userId : ' + userId);

        System.debug('CampaignMemberTmpList : ' + CampaignMemberTmpList);

        System.debug('CampaignMemberList : ' + CampaignMemberList);

        for(CampaignMember cm : CampaignMemberList){
            System.debug(cm);
            CampaignMemberWrapper cmw = new CampaignMemberWrapper();
            getPdpaDataWrapper pdpaw = new getPdpaDataWrapper();
                cmw.campaignmemberobj = cm;
                cmw.isSelected =false;
                cmw.RowNumber = OffsetSize+MaxNumoberofRecords+1;
                pdpaw.RowNumber = OffsetSize+MaxNumoberofRecords+1;
               
                if(cm.ContactID !=null){
                    cmw.Type = 'Contact';
                    cmw.Title = cm.Contact.Title;
                    cmw.FirstName = cm.Contact.FirstName;
                    cmw.LastName = cm.Contact.LastName;
                    cmw.CompanyName = cm.contact.Account.Name;
                    cmw.Email = cm.contact.email;
                    cmw.TMBCustomerID = cm.Contact.TMB_Customer_ID__c;
                    pdpaw.TMBCustomerID = cm.Contact.TMB_Customer_ID__c;
                }else if(cm.LeadID !=null){
                    cmw.Type = 'Lead';
                    cmw.Title = cm.Lead.Title;
                    cmw.FirstName = cm.Lead.FirstName;
                    cmw.LastName = cm.Lead.LastName;
                    cmw.CompanyName = cm.lead.Company;
                    cmw.Email = cm.Lead.email;
                }
                cmw.DoNotContact = cm.Customer__r.RTL_Do_Not_Contact__c;
                // For debug
                cmw.CallEndDate = cm.Campaign.RTL_Call_End_Date__c;
                cmw.ContactStatus = cm.RTL_Contact_Status__c;
                cmw.offerResult = cm.RTL_Offer_Result__c;
                cmw.invitationStatus = cm.RTL_Invitation_Status__c;

                campaignIDSet.add(cm.CampaignId);
                campaignwrapperList.add(cmw);
                getPdpaDataWrapperList.add(pdpaw);
                MaxNumoberofRecords++;
        }

        for(Campaign camp : [SELECT ID,Name from Campaign WHERE ID IN:campaignIDSet]){
            campaignMap.put(camp.id,camp.name);
        }

        for(CampaignMemberWrapper cpmwp : campaignwrapperList){
                cpmwp.CampaignName = campaignMap.get(cpmwp.campaignmemberobj.CampaignID);
        }

        MaxNumoberofRecords +=OffsetSize;

        if( MaxNumoberofRecords == 0 )
        {
            StartNumberofRecords = 0;
        }
        else 
        {
            StartNumberofRecords = OffsetSize+1;
        }

        if( CampaignMemberList.size() > 0 )
        {
            firstSorting =  CampaignMemberList.get(0).RTL_Campaign_Member_Sorting_Order__c;
            lastSorting = CampaignMemberList.get( CampaignMemberList.size() - 1 ).RTL_Campaign_Member_Sorting_Order__c;

        }
        System.debug('lastSorting : ' + lastSorting);

        campaignwrapperListJSON = JSON.serialize(getPdpaDataWrapperList, true);
        // System.debug(campaignwrapperListJSON);
        return campaignwrapperList;
    }

  


    public void searchCampaignMembers(){


        searchcamMemCampaignID = CampMemObj.CampaignID==null?'':CampMemObj.CampaignID;
        //searchselectedOwner = selectedOwner;
        searchcamMemContactStatus = CampMemObj.RTL_Contact_Status__c==null?'':CampMemObj.RTL_Contact_Status__c;
        //searchcamMemEndDate = CampMemObj.Campaign.RTL_Call_End_Date__c;
        // RTL_Offer_Result__c not writeable , so read data from searchcamMemOfferResult directly in page
        //searchcamMemOfferResult = CampMemObj.RTL_Offer_Result__c==null?'':CampMemObj.RTL_Offer_Result__c;
        searchcamMemInvitationStatus = CampMemObj.RTL_Invitation_Status__c==null?'':CampMemObj.RTL_Invitation_Status__c;


        OffsetSize = 0;
        queryPaginateCampaignMemberWrapperList(QueryLimit,'init');

        

    }

    

    
    public void backbutton(){
            isSearchScreen =true;
            isRelocateScreen =false;
            //queryCampaignMemberWrapperList(QueryLimit, OffsetSize);
            queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
    }
        
    public Pagereference cancel(){
        PageReference detailpage;
        detailpage = new ApexPages.StandardController(CampMemObj).view();
        detailpage.setRedirect(true);          
        return detailpage; 
    }



     public PageReference Next() {
        OffsetSize += QueryLimit;
        //queryCampaignMemberWrapperList(QueryLimit, OffsetSize);
        queryPaginateCampaignMemberWrapperList(QueryLimit,'next');
        return null;
    }
    public PageReference Previous() {
        OffsetSize -= QueryLimit;
        //queryCampaignMemberWrapperList(QueryLimit, OffsetSize);
        queryPaginateCampaignMemberWrapperList(QueryLimit,'previous');
        return null;
    }
  
    public Boolean getDisablePrevious(){
        if(OffsetSize>0){
            return false;
        }
        else return true;
    }
    public Boolean getDisableNext() {
        if (OffsetSize + QueryLimit < countTotalRecords){

            return false;
        }
        else return true;
    }

    @RemoteAction
    public static String getFagPdpa(String tmbCustId){
        if(tmbCustId == null){
            return '';
        }
        return pdpaCalloutUtil.getFagPdpa(tmbCustId, 'PDPA_GET_CONSENT_FAG_CALL_LIST');
    }
}