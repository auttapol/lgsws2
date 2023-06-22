public with sharing class RTL_CampaignMemberReassignExtension {

    class roleAccessibility{
        public Boolean IsAllowChangeBranch {get;set;}
        public Boolean IsAllowedReAssign {get;set;}
        public String Role {get;set;}
    }
 
    private String CampaignID;
    private String isUnassigned;
    public String CampaignMemberID {get;set;}
    public CampaignMember CampMemObj {get;set;}
    public CampaignMember camMemReassign {get;set;}
    
    public List<SelectOption> CampaignTypeSelectList {get{
        if(CampaignTypeSelectList==null){
            CampaignTypeSelectList = new List<SelectOption>();

            CampaignTypeSelectList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
            CampaignTypeSelectList.add(new SelectOption('Lead',SObjectType.Lead.getLabel() ));
            CampaignTypeSelectList.add(new SelectOption('Contact', SObjectType.Contact.getLabel() ));
        }
        return CampaignTypeSelectList;
        }set;}


    //public List<SelectOption> LeadStatusSelectList {get{
    //    if(LeadStatusSelectList ==null){
    //        LeadStatusSelectList = new List<SelectOption>();
    //        LeadStatusSelectList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
    //        LeadStatusSelectList.add(new SelectOption('Open','Open'));
    //        LeadStatusSelectList.add(new SelectOption('Passed Prescreen','Passed Prescreen'));
    //        LeadStatusSelectList.add(new SelectOption('Contacted','Contacted'));
    //    }

    //    return LeadStatusSelectList;
    //}
    //    set;}

    public List<SelectOption> campaignChannelSelectList {get{
        if(CampaignChannelSelectList == null){
            CampaignChannelSelectList = new List<SelectOption>();
            CampaignChannelSelectList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
            CampaignChannelSelectList.add(new SelectOption('Branch', SObjectType.CampaignMember.fields.RTL_Channel_Branch__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('DirectMail', SObjectType.CampaignMember.fields.RTL_Channel_DirectMail__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('Edm', SObjectType.CampaignMember.fields.RTL_Channel_Edm__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('MIB', SObjectType.CampaignMember.fields.RTL_Channel_MIB__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('OBD', SObjectType.CampaignMember.fields.RTL_Channel_OBD__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('Outbound', SObjectType.CampaignMember.fields.RTL_Channel_Outbound__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('SMS', SObjectType.CampaignMember.fields.RTL_Channel_SMS__c.Label ));
            CampaignChannelSelectList.add(new SelectOption('Subsidiary', SObjectType.CampaignMember.fields.RTL_Channel_Subsidiary__c.Label ));
        }
        return CampaignChannelSelectList;
    }
    set;}



    public Map<String,String> channelfieldMapping {get{

        if(channelfieldMapping==null){
            channelfieldMapping = new Map<String,String>();
            channelfieldMapping.put('Branch','RTL_Channel_Branch__c');
            channelfieldMapping.put('DirectMail','RTL_Channel_DirectMail__c');
            channelfieldMapping.put('Edm','RTL_Channel_Edm__c');
            channelfieldMapping.put('MIB','RTL_Channel_MIB__c');
            channelfieldMapping.put('OBD','RTL_Channel_OBD__c');
            channelfieldMapping.put('Outbound','RTL_Channel_Outbound__c');
            channelfieldMapping.put('SMS','RTL_Channel_SMS__c');




        }   

        return channelfieldMapping;


        }set;}


    public List<SelectOption> contactStatusSelectionList {get{
        if(contactStatusSelectionList == null){
            contactStatusSelectionList = new List<SelectOption>();
            contactStatusSelectionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));

            Schema.DescribeFieldResult fieldResult = CampaignMember.RTL_Contact_Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            //Set<String> availableOptions = new Set<String>{'New', 'Contact', 'Follow-up', 'Re-attempt'};

            for( Schema.PicklistEntry f : ple)
            {
              //  if( availableOptions.contains( f.getValue() ) )
              //  {
                    contactStatusSelectionList.add(new SelectOption(f.getValue(), f.getLabel() ));
              //  }
            }  

            
        }
        return contactStatusSelectionList;
    }
    set;}

    public List<SelectOption> offerResultSelectList {get{
        if(offerResultSelectList == null){
            offerResultSelectList = new List<SelectOption>();
            //offerResultSelectList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
            //offerResultSelectList.add(new SelectOption('Interested', Label.RTL_Campaign_Member_Filter_Offer_Interest ));
            //offerResultSelectList.add(new SelectOption('Not Interested', Label.RTL_Campaign_Member_Filter_Offer_NotInterest ));
            offerResultSelectList.add(new SelectOption('Pending', Label.RTL_Campaign_Member_Filter_Offer_Pending ));

    }
        return offerResultSelectList;
        }set;}

    public List<SelectOption> CampaignSelectOptionList {get{
        if(CampaignSelectOptionList == null){

            Set<ID> retailRecordTypeIDset = new Set<ID>();
            for(Recordtype perRecordType :  [SELECT ID from Recordtype 
                                     WHERE sObjectType ='Campaign'
                                     AND (NOT DeveloperName LIKE '%Master%')
                                     AND (NOT DeveloperName LIKE '%Commercial%')]){
                                        retailRecordTypeIDset.add(perRecordType.id); 
                                     }


            CampaignSelectOptionList = new List<SelectOption>();
            CampaignSelectOptionList.add(new SelectOption('',Label.RTL_Campaign_CallList_Filter_All));
            for(Campaign cp : [SELECT ID,RecordTypeId,isActive,Name FROM Campaign 
                               WHERE isActive=true
                               AND Status != 'Expired'
                               And RecordTypeId IN:retailRecordTypeIDset
                                ORDER BY NAME ASC]){
                //if(retailRecordTypeIDset.contains(cp.RecordTypeID)){
                    CampaignSelectOptionList.add(new SelectOption(cp.id,cp.Name));
                //}
                
            }
            

        }
        return CampaignSelectOptionList;
        }set;}


    public String selectedtype {get;set;}
    public String selectedChannel {get;set;}
    public String selectedreassignChannel {get;set;}
    public string selectedleadstatus {get;set;}
    public String selectedOfferResults {get;set;}
    public String selectedCampaignID {get;set;}
    public boolean isFromCampaign {get;set;}
    public boolean isFromHomeScreen {get;set;}
    public boolean isSearchScreen {get;set;}
    public boolean isRelocateScreen {get;set;}
    public boolean isToggleSelectAll {get;set;}
    public Integer totalSelectedMembers {get;set;}
    public Integer OffsetSize {get;set;}
    private Integer QueryLimit = 400;
    public  Integer CountTotalRecords {get;set;}
    public Integer MaxNumoberofRecords {get;set;}
    public Boolean toggleScript {get;set;}
    public Boolean isReallocateSuccess {get;set;}
    
    

    public Boolean filterUnassignedMember {
        get{
            if( filterUnassignedMember == null )
            {
                filterUnassignedMember = false;
            }
            return filterUnassignedMember;
        }
        set;
    }

    //private static final Integer NORECORDPERPAGE = 5;

    private String firstSorting;
    private String lastSorting;

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

    private String searchcamMemCampaignID;
    private String searchcamMemAssignedZone;
    private String searchcamMemAssignedBranch;
    private String searchcamMemAssignedAgent;
    private String searchcamMemberType;
    private String searchselectedOfferResults;
    private String searchselectedChannel;

    public String searchcamMemContactStatus{get;set;}

    public User currentUser{
        get{
            if( currentUser == null )
            {
                currentUser = [SELECT ID,UserRole.Name,Profile.Name,
                        RTL_Channel__c,Zone_Code__c, RTL_Branch_Code__c 
                FROM USER WHERE ID =:Userinfo.getUserId() ];
            }
            return currentUser;
        }
        set;
    }

    public Boolean isAllowSeeUnassinged {
        get{
            if(isAllowSeeUnassinged == null)
            {
                String profileName = currentUser.Profile.Name;

                List<RTL_Campaign_Reassign_Profile_Setting__mdt> crps = [SELECT ID,Profile_Name__c FROM RTL_Campaign_Reassign_Profile_Setting__mdt WHERE Profile_Name__c =:profileName ];

                if( crps.size() > 0 )
                {
                    isAllowSeeUnassinged = true;
                }
                else 
                {
                    isAllowSeeUnassinged = false;
                }
            }

            return isAllowSeeUnassinged;
        }
        set;}


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

    public Boolean isAllowChangeBranch {
        get{
            if( isAllowChangeBranch == null )
            {
                isAllowChangeBranch = roleAcc.IsAllowChangeBranch;
            }

            return isAllowChangeBranch;
        }
        set;
    }


    //public String userType {
    //    get{
    //        if(userType == null)
    //        {
    //            String roleName = currentUser.UserRole.Name;
                
    //            if( roleName != null )
    //            {
    //                if( roleName == 'CEO' )
    //                {
    //                    userType = 'CEO'; 
    //                    isAllowChangeBranch = true;
    //                }
    //                else if( roleName == 'CRBO' )
    //                {
    //                    userType = 'CRBO'; 
    //                    isAllowChangeBranch = true;
    //                }
    //                else if( roleName == 'BBG' )
    //                {
    //                    userType = 'BBG'; 
    //                    isAllowChangeBranch = true;
    //                }
    //                else if( roleName.startsWith('BR-Sales-Zone') )
    //                {
    //                    userType = 'Agent'; 
    //                    isAllowChangeBranch = false;
    //                }
    //                else if( roleName.startsWith('BR-MGR-Zone') )
    //                {
    //                    userType = 'BranchManager';
    //                    isAllowChangeBranch = false;
    //                }
    //                else if( roleName.startsWith('WM-TL') )
    //                {
    //                    userType = 'WM-TL';
    //                    isAllowChangeBranch = false;
    //                }
    //                else if( roleName.startsWith('WM-RM') )
    //                {
    //                    userType = 'WM-RM';
    //                    isAllowChangeBranch = false;
    //                }
    //                else 
    //                {
    //                    userType = 'other';   
    //                    isAllowChangeBranch = false;                   
    //                }

    //            }
    //            else 
    //            {
    //                userType = 'other';   
    //                isAllowChangeBranch = false;
    //            }
    //        }
    //        return userType;
    //    }
    //    set;
    //}

    private Branch_and_zone__c userBranch {
        get{
            if( userBranch == null )
            {
                if(currentuser.RTL_Branch_Code__c !=null){
                    List<Branch_and_Zone__c> BranchZonelist =  [SELECT ID,Branch_Code__c,RTL_Zone_Code__c  from Branch_and_zone__c
                                                  WHERE Branch_Code__C =: currentuser.RTL_Branch_Code__c LIMIT 1];
                    if(BranchZonelist.size()>0){
                        Branch_and_Zone__c baz = BranchZonelist.get(0);
                        userBranch = baz;
                    }
                }
            }
            return userBranch;
        }
        set;
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public RTL_CampaignMemberReassignExtension(ApexPages.StandardController stdController) {

           CampaignID = Apexpages.CurrentPage().getParameters().get('id');
           isUnassigned = Apexpages.CurrentPage().getParameters().get('unassigned');


            //String userTypeString = userType;
            
            CampMemObj = new CampaignMember();
            //CampMemObj.RTL_Contact_Status__c = '';
            camMemReassign = new CampaignMember();
            isFromCampaign =false;
            isFromHomeScreen = false;                             
            isSearchScreen =true;
            isRelocateScreen =false;
            isToggleSelectAll = false;
            toggleScript = false;
            isReallocateSuccess = false;
            OffsetSize = 0;

            //Set filter default valuse
            searchselectedOfferResults = 'Pending';
            selectedOfferResults = 'Pending';
            searchcamMemContactStatus = 'New';

            if(CampaignID !=null && CampaignID !=''){

                isFromCampaign = true;

                try
                {
                    Campaign cam = [ SELECT id,name FROM Campaign WHERE id =:CampaignID ];
                    CampMemObj.Campaign = cam;
                }
                catch (exception e)
                {
                    CampaignID = null;
                    system.debug('Campaign not found from ID');
                }

                CampMemObj.CampaignID = CampaignID;
                searchcamMemCampaignID = CampaignID;
            }
            else
            {
                isFromHomeScreen = true;           
            }

            if( roleAcc.Role == 'BR-MGR-Zone' )
            {
                if( userBranch != null )
                {
                    CampMemObj.RTL_Assigned_Branch_No_Filter__c = userBranch.Id;
                    searchcamMemAssignedBranch = userBranch.Id;
                    queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
                }
                else 
                {   
                    roleAcc.IsAllowedReAssign = false;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Agent));               
                }
                
                /* For now filter only for branch id */
                //CampMemObj.RTL_Assigned_Zone_Rpt__c = userBranch.RTL_Zone_Code__c;
                //searchcamMemAssignedZone =  userBranch.RTL_Zone_Code__c;

                
            }
            else if( roleAcc.Role == 'WM-TL' ) 
            {
                if( currentuser.Zone_Code__c != null )
                {
                    CampMemObj.RTL_Assigned_Zone_Rpt__c = currentuser.Zone_Code__c;
                    searchcamMemAssignedZone =  currentuser.Zone_Code__c;
                    queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
                }
                else
                {
                    roleAcc.IsAllowedReAssign = false;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Agent));
                }
                
            }

            if( isUnassigned == '1' )
            {
                filterUnassignedMember = true;
            }
            //else if ( roleAcc.Role == 'BR-Sales-Zone' || roleAcc.Role == 'WM-RM' )
            //{
            //    //Not allowed to query

            //    //CampMemObj.RTL_Assigned_Zone_Rpt__c = currentuser.Zone_Code__c;
            //    //CampMemObj.RTL_Assigned_Branch__c = userBranchId;

            //    //searchcamMemAssignedBranch = userBranchId;
                
            //    //searchcamMemAssignedZone = currentuser.Zone_Code__c;
            //    //searchselectedChannel = currentuser.RTL_Channel__c;
            //    //selectedChannel = currentuser.RTL_Channel__c;
            //}


        queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
    }

    public List<CampaignMemberWrapper>  queryPaginateCampaignMemberWrapperList(Integer NoOflimit,String type)
    {

        campaignwrapperList = new List<CampaignMemberWrapper>();
            List<String> filterStringList = new List<String>();
            MaxNumoberofRecords = 0;
            String CountQuery ='SELECT Count(id) from CampaignMember ';
            //String LastIndexQuery = 'SELECT ID,CampaignID,LastModifiedDate,RTL_Contact_Status__c'+
            //',RTL_Campaign_Channel_formula__c,RTL_Assigned_Zone_Rpt__c,RTL_Offer_Result__c'+
            //',RTL_Assigned_Branch__c,RTL_Assigned_Agent__c,RTL_Assigned_Branch_No_Filter__c '+
            //' from CampaignMember ';

            String QueryString = 'SELECT ID,CampaignID,LeadID,ContactID,Name,RTL_Contact_Status__c,RTL_Channel__c,RTL_Campaign_Priority__c,RTL_Campaign_Channel_formula__c, '+
                                                        /*for debug-->*/'RTL_Assigned_Zone_Rpt__c , RTL_Assigned_Branch__r.Name, ' +
                                                        'LastModifiedDate,Lead.Status,RTL_Assigned_Agent__c,RTL_Assigned_Branch__c,RTL_Campaign_EndDate__c, '+
                                                        'Status,Lead_Status__c,Lead.Title,Lead.FirstName,Lead.LastName, '+
                                                        'Contact.FirstName,Contact.Lastname,RTL_Offer_Result__c, '+
                                                        'Lead.Name,Contact.Name,Contact.Title,Lead.Company,RTL_Assigned_Channel__c, '+
                                                        'contact.Account.Name,lead.email,contact.email,Campaign.Name,RTL_Campaign_Member_Sorting_Order__c, '+
                                                        'RTL_Originate_Branch__c,RTL_Product_Name__c,RTL_Assigned_Branch_No_Filter__c,RTL_Channel_Outbound__c '+
                                                        ',Customer__r.DNC_Expired_Date__c,Campaign.Filter_Out_Do_Not_Contact__c ' +
                                                        'from CampaignMember ';
            // ** Temp remark **
            // String suffixQueryString = ' ORDER BY RTL_Campaign_Priority__c ASC NULLS LAST, RTL_Campaign_EndDate__c ASC NULLS LAST '+
            //                            ',Campaign.Name ASC NULLS LAST,RTL_Assigned_Branch__r.Branch_Code__c ASC NULLS LAST  '+
            //                            ', RTL_Assigned_Agent__r.Name ASC NULLS LAST,RTL_Contact_Status__c ASC NULLS LAST '
            //                            ;
            // String newsuffixQueryString = ' ORDER BY RTL_Campaign_Member_Sorting_Order__c ASC NULLS LAST ';
            // String limitsQueryString = ' LIMIT :NoOflimit OFFSET :setOffSetSize ';

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


        filterStringList.add(' Campaign.Status != \'Expired\' ');
        filterStringList.add(' RecordType.DeveloperName = \'Retail_Campaign_Member\' ');

        if(searchcamMemCampaignID !=null&& searchcamMemCampaignID !=''){
            
            filterStringList.add(' CampaignID = :searchcamMemCampaignID ');
        }

       if(searchcamMemContactStatus !=null && searchcamMemContactStatus !=''){
            filterStringList.add(' RTL_Contact_Status__c = :searchcamMemContactStatus ');
        }

        if(searchselectedChannel !=null && searchselectedChannel !=''){
            searchselectedChannel = '%'+searchselectedChannel+'%';
            filterStringList.add(' RTL_Campaign_Channel_formula__c LIKE : searchselectedChannel ');
        }

        if(searchcamMemAssignedZone !=null && searchcamMemAssignedZone !=''){
            filterStringList.add(' RTL_Assigned_Zone_Rpt__c = :searchcamMemAssignedZone ');
        }
        if(searchselectedOfferResults !=null && searchselectedOfferResults !=''){
            filterStringList.add(' RTL_Offer_Result_ENG__c = :searchselectedOfferResults ');
        }
        
        if(searchcamMemberType !=null && searchcamMemberType !=''){
                if(selectedtype=='Lead'){
                    filterStringList.add(' LeadID !=null ');
                }else if(selectedtype=='Contact'){
                    filterStringList.add(' ContactID !=null ');
                }
        }
        

        // Reassign not show outbond campaign member
        filterStringList.add(' RTL_Assigned_Channel__c != \'Outbound\' ');    
        // Not Show Channel Outbound
        filterStringList.add(' RTL_Channel_Outbound__c = false'); 

        if( filterUnassignedMember )
        {                 
            filterStringList.add(' RTL_Assigned_Branch__c = null ');
            filterStringList.add(' RTL_Assigned_Agent__c = null ');
        }
        else 
        {
            if(searchcamMemAssignedBranch!=null && searchcamMemAssignedBranch !=''){
                filterStringList.add(' RTL_Assigned_Branch__c = :searchcamMemAssignedBranch ');
            }
            
            if(searchcamMemAssignedAgent !=null && searchcamMemAssignedAgent !=''){
                filterStringList.add(' RTL_Assigned_Agent__c = :searchcamMemAssignedAgent ');
            }
        }
        


        if(filterStringList.size()>0){
            QueryString +=' WHERE ';
            CountQuery +=' WHERE ';
            //LastIndexQuery +='WHERE ';
            integer index = 1;
            for(String filterstr : filterStringList){
                if(index !=1){
                    QueryString += ' AND ';
                    CountQuery += ' AND ';
                   // LastIndexQuery +='AND ';
                }
                QueryString += filterstr;
                CountQuery += filterstr;
                //LastIndexQuery +=filterstr;
 
                index++;

            }


        }


        if( type == 'init' )
        {
            //countTotalRecords = Database.countQuery(CountQuery);
            countTotalRecords = 0;
            for (AggregateResult result :  database.query(CountQuery) ) countTotalRecords += (Integer)result.get('expr0');
        }

        QueryString +=suffixQueryString+limitsQueryString;
System.debug('QueryString --> ' + QueryString);
        List<CampaignMember> CampaignMemberTmpList = (List<CampaignMember>)Database.query(QueryString);
        
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


        for(CampaignMember cm : CampaignMemberList){
            CampaignMemberWrapper cmw = new CampaignMemberWrapper();
                cmw.campaignmemberobj = cm;
                cmw.isSelected =false;
                cmw.RowNumber = OffsetSize+MaxNumoberofRecords+1;
               
                if(cm.ContactID !=null){
                    cmw.Type = 'Contact';
                    cmw.Title = cm.Contact.Title;
                    cmw.FirstName = cm.Contact.FirstName;
                    cmw.LastName = cm.Contact.LastName;
                    cmw.CompanyName = cm.contact.Account.Name;
                    cmw.Email = cm.contact.email;
                } else if(cm.LeadID !=null){
                    cmw.Type = 'Lead';
                    cmw.Title = cm.Lead.Title;
                    cmw.FirstName = cm.Lead.FirstName;
                    cmw.LastName = cm.Lead.LastName;
                    cmw.CompanyName = cm.lead.Company;
                    cmw.Email = cm.Lead.email;
                }

                campaignwrapperList.add(cmw);
                MaxNumoberofRecords++;
        }

        MaxNumoberofRecords +=OffsetSize;

        if( CampaignMemberList.size() > 0 )
        {
            firstSorting =  CampaignMemberList.get(0).RTL_Campaign_Member_Sorting_Order__c;
            lastSorting = CampaignMemberList.get( CampaignMemberList.size() - 1 ).RTL_Campaign_Member_Sorting_Order__c;
        }


        return campaignwrapperList;
    }

    public void searchCampaignMembers(){

        if(CampMemObj.CampaignID !=null){
            searchcamMemCampaignID = CampMemObj.CampaignID==null?'':CampMemObj.CampaignID;
        }else if (selectedCampaignID !=null && selectedCampaignID !=''){
            searchcamMemCampaignID = selectedCampaignID;
        }else{
            searchcamMemCampaignID = '';
        }

        //searchcamMemContactStatus = CampMemObj.RTL_Contact_Status__c==null?'':CampMemObj.RTL_Contact_Status__c;
        searchcamMemAssignedZone = CampMemObj.RTL_Assigned_Zone_Rpt__c==null?'':CampMemObj.RTL_Assigned_Zone_Rpt__c;
        searchselectedOfferResults = selectedOfferResults;
        searchcamMemAssignedBranch = CampMemObj.RTL_Assigned_Branch_No_Filter__c==null?'':CampMemObj.RTL_Assigned_Branch_No_Filter__c;
        searchcamMemberType = selectedtype;
        searchcamMemAssignedAgent = CampMemObj.RTL_Assigned_Agent__c==null?'':CampMemObj.RTL_Assigned_Agent__c;
        searchselectedChannel = selectedChannel;
        

        OffsetSize = 0;
            
        queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
    }

    public void selectMember(){

        if( !isAllowChangeBranch )
        {
            camMemReassign.RTL_Assigned_Branch__c = CampMemObj.RTL_Assigned_Branch_No_Filter__c;
        }

        List<CampaignMemberWrapper> selectedCampaignMemberWrapperList = new List<CampaignMemberWrapper>();

        for(CampaignMemberWrapper cpmw : campaignwrapperList){

            if(cpmw.isSelected){
                selectedCampaignMemberWrapperList.add(cpmw);
            }

        }


        if(selectedCampaignMemberWrapperList.size()>0){
            totalSelectedMembers = selectedCampaignMemberWrapperList.size();
            isSearchScreen =false;
            isRelocateScreen =true;

            campaignwrapperList = new List<CampaignMemberWrapper>();

            Integer selectedCount = 1;
            for(CampaignMemberWrapper cmw : selectedCampaignMemberWrapperList){
                cmw.RowNumber = selectedCount;
                campaignwrapperList.add(cmw);
                selectedCount++;
            }

            
        }else{
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Campaign));
        }
    }


    public Pagereference reallocateAction(){


        if(camMemReassign.RTL_Assigned_Agent__c ==null && camMemReassign.RTL_Assigned_Branch__c ==null){

            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Input));

            return null;

        }else{

            List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();


            User ReassignedAgent;
            Branch_and_Zone__c ReassignedBranch;

            if(camMemReassign.RTL_Assigned_Agent__c!=null){
                ReassignedAgent = [SELECT ID,RTL_Branch_Code__c,Region_Code__c,Zone_Code__c from User WHERE ID =:camMemReassign.RTL_Assigned_Agent__c LIMIT 1]; 
            }

            //Check if reassigned User are in the same Team/Branch

            Set<String> roles = new Set<String>{'BR-MGR-Zone','WM-TL'};
            if(  roles.contains(roleAcc.Role) )
            {
                if( ReassignedAgent == null )
                {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Input));
                    return null;
                }
                //Check if reassigned User are in the same Team/Branch

                if( roleAcc.Role == 'BR-MGR-Zone' )
                {
                    if( currentUser.RTL_Branch_Code__c != ReassignedAgent.RTL_Branch_Code__c )
                    {
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Agent));
                        return null;
                    }
                }
                else if( roleAcc.Role == 'WM-TL' )
                {
                    if( currentUser.Zone_Code__c != ReassignedAgent.Zone_Code__c )
                    {
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Campaign_Reassign_Invalid_Agent));
                        return null;
                    }
                }

            }

            

            if(camMemReassign.RTL_Assigned_Branch__c!=null){
                ReassignedBranch = [SELECT ID,RTL_Region_Code__c,RTL_Zone_Code__c,Branch_Code__c from Branch_and_Zone__c WHERE ID=: camMemReassign.RTL_Assigned_Branch__c LIMIT 1 ];
            }

            Map<Id,CampaignMember> leadIdCamMemMap = new Map<Id,CampaignMember>();

            for(CampaignMemberWrapper cmw : campaignwrapperList){
                CampaignMember cpm = cmw.campaignmemberobj;

                // Assinged Code move to Trigger
                if(camMemReassign.RTL_Assigned_Agent__c !=null){
                    cpm.RTL_Assigned_Agent__c = ReassignedAgent.id;
                    //cpm.RTL_Branch_Team_Name_Code_Rpt__c = ReassignedAgent.RTL_Branch_Code__c;
                    //cpm.RTL_Assigned_Region_Code_Rpt__c = ReassignedAgent.Region_Code__c;
                    //if( ReassignedAgent.Zone_Code__c.length() > 4 )
                    //{
                    //    cpm.RTL_Assigned_Zone_Rpt__c = ReassignedAgent.Zone_Code__c.substring(0,4) ;
                    //}
                    //else 
                    //{
                    //    cpm.RTL_Assigned_Zone_Rpt__c = ReassignedAgent.Zone_Code__c;    
                    //}


                }else if(camMemReassign.RTL_Assigned_Branch__c !=null){
                    cpm.RTL_Assigned_Branch__c = ReassignedBranch.id;
                    if( camMemReassign.RTL_Assigned_Agent__c == null )
                    {
                        cpm.RTL_Assigned_Agent__c = null;
                    }
                    //cpm.RTL_Branch_Team_Name_Code_Rpt__c = ReassignedBranch.Branch_Code__c;
                    //cpm.RTL_Assigned_Region_Code_Rpt__c = ReassignedBranch.RTL_Region_Code__c;
                    //cpm.RTL_Assigned_Zone_Rpt__c = ReassignedBranch.RTL_Zone_Code__c;
                }

                if(selectedreassignChannel !=null && selectedreassignChannel !=''){
                    //TBD

                    if(channelfieldMapping.containsKey(selectedreassignChannel)){
                        cpm.put(channelfieldMapping.get(selectedreassignChannel),true);
                    }
                }

                // Assign value to not convert Lead only
                if( cpm.ContactID == null && cpm.LeadID !=null)
                {
                    leadIdCamMemMap.put(cpm.LeadID,cpm);
                }

                cpm.RTL_Reassignby__c = Userinfo.getUserId();
                cpm.RTL_Reassigndate__c = DateTime.now();

                updateCampaignMemberList.add(cpm);
            }

            try
            {
                update updateCampaignMemberList;

                //=== In case of Lead, after changing assigned branch/agent ===
                //=== also change lead's owner accordingly ===
                String groupId = '';
                if(camMemReassign.RTL_Assigned_Branch__c !=null)
                {
                    try
                    {
                        String queueName1 = 'RTL_' +  ReassignedBranch.Branch_Code__c;
                        String queueName2 = 'RTLQ_' +  ReassignedBranch.Branch_Code__c;
                        Group groupObject = [SELECT Id FROM Group 
                                        WHERE  type = 'queue'
                                        AND ( developerName =:queueName1 OR 
                                              developerName =:queueName2 )
                                        ];
                        groupId = groupObject.id;
                        
                    }   
                    catch(exception e) 
                    {
                        groupId = '';
                    }
                }


                Set<Id> leadSet = leadIdCamMemMap.keySet();
                List<Lead> updateLeadList = [Select Id,Name,OwnerId FROM Lead Where Id in:leadSet];

                for(Lead leadObj : updateLeadList)
                {
                    CampaignMember camMemObj = leadIdCamMemMap.get( leadObj.id );

                    //In case of reassign to agent, change lead's owner to the new agent.
                    if(camMemReassign.RTL_Assigned_Agent__c !=null)
                    {
                        leadObj.OwnerId = camMemReassign.RTL_Assigned_Agent__c;
                    }
                    // In case of reassign to branch, change lead's owner to the branch's queue.
                    else if(camMemReassign.RTL_Assigned_Branch__c !=null)
                    {
                       if( groupId != '' )
                       {
                           leadObj.OwnerId = groupId;
                       }

                    }
                }
                update updateLeadList;

                toggleScript = true;
                isReallocateSuccess = true;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,Label.RTL_Campaign_Reassign_Success));

                // Need to query campaign member again to update Formular filed value Assigned Chanel
                Map<ID, CampaignMember> mapCamMem = new Map<ID, CampaignMember>([SELECT ID,CampaignID,LeadID,ContactID,Name,RTL_Contact_Status__c,RTL_Channel__c,RTL_Campaign_Priority__c,RTL_Campaign_Channel_formula__c,
                        LastModifiedDate,Lead.Status,RTL_Assigned_Agent__c,RTL_Assigned_Branch__c,RTL_Campaign_EndDate__c,
                        Status,Lead_Status__c,Lead.Title,Lead.FirstName,Lead.LastName, 
                        Contact.FirstName,Contact.Lastname,RTL_Offer_Result__c, 
                        Lead.Name,Contact.Name,Contact.Title,Lead.Company,RTL_Assigned_Channel__c, 
                        contact.Account.Name,lead.email,contact.email,Campaign.Name,
                        RTL_Assigned_Zone_Rpt__c , RTL_Assigned_Branch__r.Name, 
                        RTL_Campaign_Member_Sorting_Order__c , RTL_Product_Name__c , RTL_Originate_Branch__c
                        from CampaignMember
                        WHERE ID IN:updateCampaignMemberList
                        ]);

                for(CampaignMemberWrapper newCmw : campaignwrapperList)
                {
                    CampaignMember cam = mapCamMem.get( newCmw.campaignmemberobj.id );
                    newCmw.campaignmemberobj = cam;                
                }
                
                return null;
            }
            catch (exception e)
            {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));        
                return null;
            }                   
            
        }

    }







        
        public void toggleSelectAll(){
            for(CampaignMemberWrapper cpmw : campaignwrapperList){   

                cpmw.isSelected = isToggleSelectAll;
            }
            
        }




    

    
    public void backbutton(){
        isToggleSelectAll = false;
            isReallocateSuccess = false;
            isSearchScreen =true;
            isRelocateScreen =false;
             queryPaginateCampaignMemberWrapperList(QueryLimit,'init');
    }
        
    public Pagereference cancel(){
        PageReference detailpage = new PageReference('/console');
        //detailpage = new ApexPages.StandardController(CampMemObj).view();
        detailpage.setRedirect(true);          
        return detailpage; 
    }



     public PageReference Next() {
        OffsetSize += QueryLimit;
        queryPaginateCampaignMemberWrapperList(QueryLimit,'next');
        return null;
    }
    public PageReference Previous() {
        OffsetSize -= QueryLimit;
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

    public String getPageMessage()
    {
        String message = '';
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        for(Apexpages.Message msg:msgs){
            message += msg.getDetail() +'\n';
        }

        return message;
    } 

    public Boolean getAllowedReAssign()
    {
        return roleAcc.IsAllowedReAssign;
        //Set<String> roles = new Set<String>{'CEO','CRBO','BBG','BranchManager','WM-TL'};
        //if(  roles.contains(userType) )
        //{
        //    return true;
        //}
        //else 
        //{
        //    return false;
        //}
    }

  
   
}