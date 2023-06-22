public without sharing class RTL_HomeScreenCallListComponentCtrl {

    //class roleAccessibility{
    //    public Boolean IsAllowChangeBranch {get;set;}
    //    public Boolean IsAllowedReAssign {get;set;}
    //    public String Role {get;set;}
    //}

    //public transient Map<Id,campaignHomeScreenWrapper> mapCampaign {get;set;}
    public transient List<campaignHomeScreenWrapper> listCampaign {get;set;}
    public List<ProcessInstanceWorkItem> itemToApprove {get;set;}
    public transient List<CampaignMember> listPendingCall {get;set;}
    public transient Map<Id,CampaignMember> mapCampaignMember {get;set;}
    public transient List<aggregateresult> allCampaignHasMemberList {get;set;}
    public transient List<aggregateresult> allCampaignMemberList {get;set;}
    public transient List<aggregateresult> pendingCampaignMemberList {get;set;}
    public Set<Id> setCampaignId {get;set;}
    public Map<Id, Recordtype> campaignRecordType {get; set;}
    public Boolean showTable {get;set;}
    public Boolean showPendingCall {get;set;}
    public Boolean showItemToApprove {get;set;}
    public Boolean showReassignButton {get;set;}
    public String callListNavTabLabel {get;set;}
    private String FILTER_OFFER_PENDING = 'Pending';
    public Boolean showAssignBRCButton {get;set;}

    //Wealth Activity 
    public Boolean showPortfolioReviewBtn {get;set;}
    public Boolean showMyActivityBtn {get;set;}

    public String ProtfolioReviewListviewID {get;set;}
    public String MyActivityListviewID {get;set;}
    //Wealth Activity 

    //***  BAU 00007310 - Add offer result value fillter to Call List Home Screen ***
    private String FILTER_OFFER_NOT_INTEREST = 'Not Interested';
        
    //***  BAU 00007310 - Add offer result value fillter to Call List Home Screen ***
    public List<String> offerResultFilter{
        get{
           if( offerResultFilter == null )
             {
                 offerResultFilter = new List<String>();
                 offerResultFilter.add(FILTER_OFFER_PENDING);
                 offerResultFilter.add(FILTER_OFFER_NOT_INTEREST);
             }
            return offerResultFilter;
      }
        set;
    }

    public integer sizeItemCallList {get{
        if (sizeItemCallList == null){
            sizeItemCallList = 0;
        }
        return sizeItemCallList;
        
    }set;}

    public integer sizeItemToApprove {get{
        if (sizeItemToApprove == null){
            sizeItemToApprove = 0;
        }
        return sizeItemToApprove;
        
    }set;}

    public Boolean mapCampaignEmpty {get{

        if (listCampaign == null || listCampaign.isEmpty()){
            mapCampaignEmpty = true;
        }
        return mapCampaignEmpty;
        
    }set;}

    public Profile currentUserProfile {
        get{
            if(currentUserProfile == null){
                return [SELECT id,name FROM profile WHERE id =: userinfo.getprofileID()];
            }
            return currentUserProfile;
        }set;
    }

    //Code Referral
    public integer countNewReferral {get{
        if (countNewReferral == null){
            countNewReferral = 0;
        }
        return countNewReferral;
        
    }set;}
    //Count open case record
    public integer countCaseNumber{get{        
       if (countCaseNumber == null){
                countCaseNumber = 0;
            }
            return countCaseNumber;
        }set;
    }
    
    //Show case
    public boolean isShowCase{get{
        if(reportPageCase != ''){
             isShowCase = True;
        }else{
            isShowCase = False;
        }
     return isShowCase;
    } set;}
    

    public string reportPageReferral {get{
        if (reportPageReferral == null){
            reportPageReferral = '';
            
            profile pro = currentUserProfile;
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                rpm = [select ReferralReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [select ReferralReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).ReferralReportName__c != null)
            {
                list<report> res = [select id from Report where DeveloperName =: rpm.get(0).ReferralReportName__c]; 
                if (res.size() > 0)
                    reportPageReferral = res.get(0).id;
            }

        }
        return reportPageReferral;
    }set;}

    public string reportPortfolioReview {get{
        if (reportPortfolioReview == null){
            reportPortfolioReview = '';
            
            profile pro = currentUserProfile;

            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();

            rpm = [SELECT PortfolioReviewReportName__c FROM ReportProfileMapping__c 
                            WHERE isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [SELECT PortfolioReviewReportName__c FROM ReportProfileMapping__c 
                                           WHERE isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).PortfolioReviewReportName__c != null)
            {
                list<report> res = [SELECT id FROM Report WHERE DeveloperName =: rpm.get(0).PortfolioReviewReportName__c]; 
                if (res.size() > 0)
                    reportPortfolioReview = res.get(0).id;
            }

        }
        return reportPortfolioReview;
    }set;}

    public string reportMyActivity {get{
        if (reportMyActivity == null){
            reportMyActivity = '';
            
            profile pro = currentUserProfile;
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
            rpm = [SELECT MyActivitiesReportName__c FROM ReportProfileMapping__c 
                            where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0)
                rpm = [SELECT MyActivitiesReportName__c FROM ReportProfileMapping__c 
                                           WHERE isActive__c = true and ProfileName__c = 'Default'];
                                           
            if (rpm.size() > 0 && rpm.get(0).MyActivitiesReportName__c != null)
            {
                list<report> res = [SELECT id FROM Report WHERE DeveloperName =: rpm.get(0).MyActivitiesReportName__c]; 
                if (res.size() > 0)
                    reportMyActivity = res.get(0).id;
            }
        }
        return reportMyActivity;
    }set;}  

    /*
    BAU 7461 - Campaign call list issue
    Change field to verify user's branch on campaign member assigned branch
    */
    public User currentUserData{
        get{
            if( currentUserData == null )
            {
                currentUserData = [SELECT ID,UserRole.Name,
                        RTL_Channel__c,Zone_Code__c, RTL_Branch_Code__c 
                FROM USER WHERE ID =:Userinfo.getUserId() ];
            }
            return currentUserData;
        }
        set;
    }

    private String userBranchId {
        get{
            if( userBranchId == null )
            {

                if(currentUserData.RTL_Branch_Code__c !=null){
                    List<Branch_and_Zone__c> BranchZonelist =  [SELECT ID,Branch_Code__c  from Branch_and_zone__c
                                                  WHERE Branch_Code__C =: currentUserData.RTL_Branch_Code__c LIMIT 1];
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

    //Show my all open case
     public string reportPageCase {get{
        if (reportPageCase == null){
            reportPageCase = '';
            profile pro = [select id,name from profile where id =: userinfo.getprofileID()];
            list<ReportProfileMapping__c> rpm = new list<ReportProfileMapping__c>();
                 rpm = [select CaseReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c =: pro.name];
            if (rpm.size() == 0){
                rpm = [select CaseReportName__c from ReportProfileMapping__c 
                                           where isActive__c = true and ProfileName__c = 'Default'];
            }
 
            if (rpm.size() > 0 && rpm.get(0).CaseReportName__c != null)

                {
 
                list<report> res = [select id from Report where DeveloperName =: rpm.get(0).CaseReportName__c]; 
                    if (res.size() > 0){
                        reportPageCase = res.get(0).id;

                    }
                }
        }
        return reportPageCase;
    }set;} 
    
    public RTL_HomeScreenCallListComponentCtrl() {


        //for (DescribeTabSetResult tsr : Schema.describeTabs()) {
        //    // Each tab of the app
        //    for (DescribeTabResult tr : tsr.getTabs()  )
        //    {
        //        if( tr.getName() == 'Call_List' )
        //        {
        //            callListNavTabLabel = tr.getLabel();
        //        }
        //    }            
        //}

        //mapCampaign = new Map<Id,campaignHomeScreenWrapper>();
        itemToApprove = new List<ProcessInstanceWorkItem>();
        listPendingCall = new List<CampaignMember>();
        allCampaignMemberList = new List<aggregateresult>();
        pendingCampaignMemberList = new List<aggregateresult>();
        setCampaignId = new Set<Id>();
        listCampaign = new List<campaignHomeScreenWrapper>();

        showPendingCall = false;
        showItemToApprove = false;
        showReassignButton = false;
        showTable = false;
        mapCampaignEmpty =false;
        showAssignBRCButton = false;

        showPortfolioReviewBtn = false;
        showMyActivityBtn = false;

        Set<String> accessPendingCall = new Set<String>();
        Set<String> accessItemToApprovewithoutTable = new Set<String>();
        Set<String> accessItemToApprovewithTable = new Set<String>();
        Set<String> accessReassignButton = new Set<String>();
        Set<String> accessCampaignTable = new Set<String>();
        Set<String> accessBranchCampaignMember = new Set<String>();
        Set<String> accessZoneCampaignMember = new Set<String>();
        Set<String> accessAssignBRC =  new Set<String>();


        User currentUser = [SELECT Id,Username
                                    ,UserRole.name
                                    ,Profile.name
                                    ,RTL_Branch_Code__c
                                    ,Zone_Code__c 
                            FROM User 
                            where id =: UserInfo.getUserId() limit 1];

        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current User Id: ' + UserInfo.getUserId());
        System.debug('Current User Role'+currentUser.UserRole.name);
        System.debug('Current User Profile'+currentUser.Profile.name);

        //Code P'Fah RTL_Referral__c Object
        countNewReferral = [SELECT count() FROM RTL_Referral__c WHERE 
                            (RTL_Stage__c = 'New' OR RTL_Stage__c = 'In progress_contacted' ) AND 
                            (RTL_IsUserInQueue__c = true OR RTL_Is_Owner__c = true)];  
        //Query all my open case 
        countCaseNumber = [Select count() from Case where OwnerID = :UserInfo.getUserId() and isclosed = false];
        
        //Get manage home button meta
        Map<String,RTL_Home_Campaign_Manage_Button__mdt> homeManageCampaign = new Map<String,RTL_Home_Campaign_Manage_Button__mdt>();
        for (RTL_Home_Campaign_Manage_Button__mdt h : [SELECT Id,Label, CampaignTable__c, 
            ItemToApprove__c, PendingCall__c, Profile__c, Reassign__c, Role__c ,BranchOnly__c,ZoneOnly__c
            FROM RTL_Home_Campaign_Manage_Button__mdt ]) {
            homeManageCampaign.put(h.Label,h);
        }

        system.debug('Home Manage Campaign : '+homeManageCampaign);

        for(RTL_Home_Campaign_Manage_Button__mdt h : homeManageCampaign.values()){
            if(h.PendingCall__c){
                accessPendingCall.add(h.Label);
            }

            if(h.ItemToApprove__c && !h.CampaignTable__c){
                accessItemToApprovewithoutTable.add(h.Label);
            }

            if(h.Reassign__c){
                accessReassignButton.add(h.Label);
            }

            if(h.CampaignTable__c){
                accessCampaignTable.add(h.Label);
            }
            if(h.BranchOnly__c){
                accessBranchCampaignMember.add(h.Label);
            }
            if(h.ZoneOnly__c){
                accessZoneCampaignMember.add(h.Label);
            }
        }
        
        //get permission access assign brc button
        List<Assign_BRC_Permission__mdt> assignBRCRoleList = [Select id, Role_Start_With__c from Assign_BRC_Permission__mdt];
        if(assignBRCRoleList.size() > 0){
            for(Assign_BRC_Permission__mdt aBRC : assignBRCRoleList){
                accessAssignBRC.add(aBRC.Role_Start_With__c);
            }
        }
        if(startsWithAny(currentUser.UserRole.name,accessAssignBRC)){
            showAssignBRCButton = true;
        }


        if(currentUser.UserRole.name != null){
           if(startsWithAny(currentUser.UserRole.name,homeManageCampaign.keySet())||
                startsWithAny(currentUser.Profile.name,homeManageCampaign.keySet())){
            /*if(currentUser.UserRole.name.startsWith('BR-MGR-Zone') || 
                currentUser.UserRole.name.startsWith('BR-Sales-Zone') ||
                currentUser.UserRole.name.startsWith('WM-TL') ||
                currentUser.UserRole.name.startsWith('WM-RM') ||
                currentUser.UserRole.name.startsWith('BBG') ||
                currentUser.Profile.name.startsWith('TMB Retail Marketing Team') ||
                currentUser.Profile.name.startsWith('System Administrator')){*/


                //Get RecordType Child Campaign
                campaignRecordType = new Map<Id, RecordType>([SELECT ID, Name, DeveloperName
                                                            FROM Recordtype
                                                            WHERE sObjectType = 'Campaign'
                                                            AND (NOT DeveloperName LIKE '%Commercial%')
                                                            AND (NOT DeveloperName LIKE '%Master%')
                                                            AND (NOT DeveloperName LIKE '%Dummy%')]);

                //Get item to approve 
                getItemToApprove();
                //Get current user pending call list
                getCampaignMemberPendingCall();

                //Get Campaign has member more than 1
                //getCampaignHasMember();


                //Check Condition branch and zone
                if(startsWithAny(currentUser.Profile.name,accessBranchCampaignMember) || startsWithAny(currentUser.UserRole.name,accessBranchCampaignMember)){
                    if(startsWithAny(currentUser.Profile.name,accessReassignButton) || startsWithAny(currentUser.UserRole.name,accessReassignButton)){
                        showReassignButton = true;
                    }

                    showPendingCall = true;
                    showTable = true;

                    /*
                    BAU 7461 - Campaign call list issue
                    Change field to verify user's branch on campaign member assigned branch
                    */
                    allCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm 
                                                                        from campaignmember 
                                                                        //where RTL_Branch_Team_Name_Code_Rpt__c =: currentUser.RTL_Branch_Code__c
                                                                        where RTL_Assigned_Branch__c = :userBranchId 
                                                                        // [2021-07-13] Filter do not contact to false
                                                                        // And ( Customer__r.DNC_Expired_Date__c = null
                                                                        //       Or Customer__r.DNC_Expired_Date__c < Today
                                                                        //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                                                                        //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                                                                        And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                                                                                   And Customer__r.DNC_Expired_Date__c != null
                                                                                   And Customer__r.DNC_Expired_Date__c > Today))
                                                                        group by campaignId limit 10000]);
                    

                      
                    //***  BAU 00007310 - Add offer result value fillter to Call List Home Screen ***
                    /*
                    BAU 7461 - Campaign call list issue
                    Change field to verify user's branch on campaign member assigned branch
                    */
                    pendingCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm
                                                                            from campaignmember 
                                                                            //Where RTL_Branch_Team_Name_Code_Rpt__c =: currentUser.RTL_Branch_Code__c
                                                                            where RTL_Assigned_Branch__c = :userBranchId 
                                                                            And ( RTL_Assigned_Agent__c = null OR RTL_Assigned_Agent__c = '' )
                                                                            And ( RTL_Contact_Staff_Name__c = null OR RTL_Contact_Staff_Name__c = '' )
                                                                            And ( RTL_Offer_Result_Eng__c in :offerResultFilter )
                                                                            // [2021-07-13] Filter do not contact to false
                                                                            // And ( Customer__r.DNC_Expired_Date__c = null
                                                                            //       Or Customer__r.DNC_Expired_Date__c < Today
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                                                                            And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                                                                                       And Customer__r.DNC_Expired_Date__c != null
                                                                                       And Customer__r.DNC_Expired_Date__c > Today))
                                                                            group by campaignId limit 10000]);


                }else if(startsWithAny(currentUser.Profile.name,accessZoneCampaignMember) || startsWithAny(currentUser.UserRole.name,accessZoneCampaignMember)){
                    if(startsWithAny(currentUser.Profile.name,accessReassignButton) || startsWithAny(currentUser.UserRole.name,accessReassignButton)){
                        showReassignButton = true;
                    }

                    showPendingCall = true;
                    showTable = true;

                    allCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm 
                                                                        from campaignmember 
                                                                        where RTL_Assigned_Zone_Rpt__c =: currentUser.Zone_Code__c
                                                                        // [2021-07-13] Filter do not contact to false
                                                                        // And ( Customer__r.DNC_Expired_Date__c = null
                                                                        //       Or Customer__r.DNC_Expired_Date__c < Today
                                                                        //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                                                                        //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                                                                        And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                                                                                   And Customer__r.DNC_Expired_Date__c != null
                                                                                   And Customer__r.DNC_Expired_Date__c > Today))
                                                                        group by campaignId limit 10000]);
                    
          //***  BAU 00007310 - Add offer result value fillter to Call List Home Screen ***
                    pendingCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm
                                                                            from campaignmember 
                                                                            Where RTL_Assigned_Zone_Rpt__c =: currentUser.Zone_Code__c
                                                                            //And RTL_Contact_Status__c = 'New'
                                                                            And ( RTL_Assigned_Agent__c = null OR RTL_Assigned_Agent__c = '' )
                                                                            And ( RTL_Contact_Staff_Name__c = null OR RTL_Contact_Staff_Name__c = '' )
                                                                            And ( RTL_Offer_Result_Eng__c in :offerResultFilter )
                                                                            // [2021-07-13] Filter do not contact to false
                                                                            // And ( Customer__r.DNC_Expired_Date__c = null
                                                                            //       Or Customer__r.DNC_Expired_Date__c < Today
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                                                                            And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                                                                                       And Customer__r.DNC_Expired_Date__c != null
                                                                                       And Customer__r.DNC_Expired_Date__c > Today))
                                                                            group by campaignId limit 10000]);
                }else if(startsWithAny(currentUser.Profile.name,accessItemToApprovewithoutTable) || startsWithAny(currentUser.UserRole.name,accessItemToApprovewithoutTable)){

                    showItemToApprove = true;

                }else{

                    showPendingCall = true;
                    showItemToApprove = true;
                    showReassignButton = true;
                    showTable = true;


                    allCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm 
                                                                        from campaignmember 
                                                                        group by campaignId limit 10000]);

                    //***  BAU 00007310 - Add offer result value fillter to Call List Home Screen ***
                    pendingCampaignMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm
                                                                            from campaignmember 
                                                                            //Where RTL_Contact_Status__c = 'New'
                                                                            WHERE ( RTL_Assigned_Agent__c = null OR RTL_Assigned_Agent__c = '' )
                                                                            And ( RTL_Contact_Staff_Name__c = null OR RTL_Contact_Staff_Name__c = '' )
                                                                            And ( RTL_Offer_Result_Eng__c in :offerResultFilter )
                                                                            // [2021-07-13] Filter do not contact to false
                                                                            // And ( Customer__r.DNC_Expired_Date__c = null
                                                                            //       Or Customer__r.DNC_Expired_Date__c < Today
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                                                                            //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                                                                            And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                                                                                       And Customer__r.DNC_Expired_Date__c != null
                                                                                       And Customer__r.DNC_Expired_Date__c > Today))
                                                                            group by campaignId limit 10000]);
                }

                Set<Id> tempCampaignId = new Set<Id>();
                String campaignId;

                if(allCampaignMemberList.size() > 0){
                    for(aggregateresult a : allCampaignMemberList){
                        campaignId = String.valueOf(a.get('campaignId'));
                        tempCampaignId.add(campaignId);
                    }
                }

                 //Get Campaign
                List<Campaign> allCampaign = [SELECT Id,name
                                                FROM Campaign 
                                                where IsActive = true 
                                                and RTL_Call_Start_Date__c <= TODAY AND RTL_Call_End_Date__c >= TODAY
                                                and id in: tempCampaignId
                                                and RecordTypeid in:campaignRecordType.values()
                                                order by RTL_Campaign_Order__c limit 100];

                system.debug('Campaign : '+allCampaign.size());

                //Get All Campaign to Wrapper Class
                for(Campaign c : allCampaign){
                    campaignHomeScreenWrapper cam = new campaignHomeScreenWrapper(c.Id,c.Name,0,0);
                    listCampaign.add(cam);
                    //mapCampaign.put(c.id,cam);
                }

                if(startsWithAny(currentUser.Profile.name,accessCampaignTable) || startsWithAny(currentUser.UserRole.name,accessCampaignTable)){
                     //Assign Count of Campaign member all
                    if(allCampaignMemberList.size() > 0){
                        for(aggregateresult a : allCampaignMemberList){  
                            String camId =  String.valueOf(a.get('campaignId'));
                            Integer count = Integer.valueOf(a.get('countcm'));

                            /*if(mapCampaign.get(camId)!=null){
                                if(mapCampaign.get(camId).campaignId == camId){
                                    mapCampaign.get(camId).allCampaignNumber = count;
                                }
                            }*/

                            for(campaignHomeScreenWrapper c : listCampaign){
                                if(c.campaignId == camId){
                                    c.allCampaignNumber = count;
                                }
                            }
                        }

                    }

                    // New count pending logic ** User change to use simple number
                    //String userId = currentUser.id;

                    //String CountQuery ='SELECT campaignId,count(Id) countcm from CampaignMember ';

                    //String offer_result_pending = Label.RTL_Campaign_Member_Filter_Offer_Pending;
                    //List<String> filterStringList = new List<String>();
                    //filterStringList.add(' Campaign.RecordTypeId IN :retailRecordTypeIDset ');
                    //filterStringList.add(' Campaign.Status  != \'Expired\' ');
                    //filterStringList.add(' ( Campaign.isActive = true OR ( Campaign.status = \'On Hold\' AND RTL_Contact_Staff_Name__c != NULL ) ) ');
                    //filterStringList.add(' Campaign.RTL_Call_Start_Date__c <= TODAY AND Campaign.RTL_Call_End_Date__c >= TODAY ');
                    //filterStringList.add(' RTL_Offer_Result__c = :offer_result_pending ');

                    //if(  userType == 'Agent' || userType == 'BrancManager')
                    //{
                    //    filterStringList.add(' ( RTL_Assigned_Branch__c = :userBranchId OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ');
                    //    if( userType == 'Agent'  )
                    //    {
                    //        filterStringList.add(' ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Branch__c = :userBranchId AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ');
                    //    }
                    //}
                    //else if (  userType == 'WM-TL' || userType == 'WM-RM' )
                    //{
                    //    String zoneCode = currentUser.Zone_Code__c;
                    //    filterStringList.add(' ( RTL_Assigned_Zone_Rpt__c = :zoneCode OR RTL_Assigned_Agent__c = :userId OR RTL_Contact_Staff_Name__c = :userId ) ');
                    //    if( userType == 'WM-RM'  )
                    //    {
                    //        filterStringList.add(' ( RTL_Contact_Staff_Name__c = :userId OR RTL_Assigned_Agent__c = :userId OR ( RTL_Assigned_Zone_Rpt__c = :zoneCode AND RTL_Assigned_Agent__c = null AND RTL_Contact_Staff_Name__c = null ) ) ');
                    //    }
                    //}

                    //CountQuery +=' WHERE ';
                    //integer index = 1;
                    //for(String filterstr : filterStringList){
                    //    if(index !=1){
                    //        CountQuery += ' AND ';
                    //    }
                    //    CountQuery += filterstr;
                    //    index++;
                    //}
                    //CountQuery += 'Group By campaignId ';

                    //List<aggregateresult> countTotalRecords = Database.query(CountQuery);

                    

                    //if(countTotalRecords.size() > 0){
                    //    for(aggregateresult a : countTotalRecords){  
                    //        String camId =  String.valueOf(a.get('campaignId'));
                    //        Integer count = Integer.valueOf(a.get('countcm'));

                    //        if(mapCampaign.get(camId)!=null){
                    //            if(mapCampaign.get(camId).campaignId == camId){
                    //                mapCampaign.get(camId).pendingCampaignNumber = count;
                    //            }
                    //        }

                    //    }
                    //}  

                    //userType
 
                    //Assign Count of Campaign member => contact status = New
                    if(pendingCampaignMemberList.size() > 0){
                        for(aggregateresult a : pendingCampaignMemberList){  
                            String camId =  String.valueOf(a.get('campaignId'));
                            Integer count = Integer.valueOf(a.get('countcm'));

                            /*if(mapCampaign.get(camId)!=null){
                                if(mapCampaign.get(camId).campaignId == camId){
                                    mapCampaign.get(camId).pendingCampaignNumber = count;
                                }
                            }*/

                            for(campaignHomeScreenWrapper c : listCampaign){
                                if(c.campaignId == camId){
                                    c.pendingCampaignNumber = count;
                                }
                            }

                        }
                    }

                }

            }else{
                showPendingCall = false;
                showItemToApprove = false;
                showReassignButton = false;
                showTable = false;
            }



        }

        //Get manage home button meta
        Map<String,Home_Manage_Activity_Button__mdt> homeManageActivityBtn = new Map<String,Home_Manage_Activity_Button__mdt>();

        for (Home_Manage_Activity_Button__mdt h : [SELECT Id,Label, My_Activity__c, Portfolio_Review__c,Profile_Name__c FROM Home_Manage_Activity_Button__mdt]) {
            homeManageActivityBtn.put(h.Profile_Name__c,h);
        }


        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId].Name;
        System.debug('profileName!!!!!!!!!!!!!!!!!');
        System.debug(profileName);
        if(homeManageActivityBtn.get(profileName) != null){
            showPortfolioReviewBtn = homeManageActivityBtn.get(profileName).Portfolio_Review__c;
            showMyActivityBtn = homeManageActivityBtn.get(profileName).My_Activity__c;
            if(showPortfolioReviewBtn){
                String PortfolioDeveloperName = UserInfo.getUiThemeDisplayed() == 'Theme3' ? 'Portfolio_Review' : 'Portfolio_Review_Task';
                ProtfolioReviewListviewID = [SELECT Id, Name, SobjectType FROM ListView WHERE DeveloperName = :PortfolioDeveloperName].Id;
                ProtfolioReviewListviewID = UserInfo.getUiThemeDisplayed() == 'Theme3' ? String.valueOf(ProtfolioReviewListviewID).substring(0, 15) : ProtfolioReviewListviewID;
                // ProtfolioReviewListviewID = '00B0l000001NU8E';
            }
            if(showMyActivityBtn){
                String DeveloperName = UserInfo.getUiThemeDisplayed() == 'Theme3' ? 'MyActivities' : 'MyActivities_Task';
                MyActivityListviewID = [SELECT Id, Name, SobjectType FROM ListView WHERE DeveloperName = :DeveloperName].Id;
                MyActivityListviewID = UserInfo.getUiThemeDisplayed() == 'Theme3' ? String.valueOf(MyActivityListviewID).substring(0, 15) : MyActivityListviewID;
                // MyActivityListviewID = '00B90000008KS31';
            }
        }
        
    }

   /* public Set<Id> getCampaignHasMember(){
        allCampaignHasMemberList = new List<aggregateresult>([ select campaignId,count(Id) countcm ,
                                                                campaign.name
                                                                from campaignmember 
                                                                group by campaignId,campaign.name 
                                                                having count(Id) >0
                                                                limit 10000]);
        
        system.debug('allCampaignHasMemberList : '+allCampaignHasMemberList);
        String campaignId;
        for(aggregateresult a : allCampaignHasMemberList){
            campaignId = String.valueOf(a.get('campaignId'));
            setCampaignId.add(campaignId);

        }

        return setCampaignId;

    }*/

    public void getItemToApprove(){
        itemToApprove = [SELECT ProcessInstance.TargetObjectId 
                FROM ProcessInstanceWorkItem 
                WHERE ProcessInstance.Status =: 'Pending' AND
                 ActorId =:UserInfo.getUserId() limit 1000 ];

        if(itemToApprove.size() > 0){
            sizeItemToApprove = itemToApprove.size();
        }else{
            sizeItemToApprove = 0;
        }

    }
    public void getCampaignMemberPendingCall(){
        listPendingCall = [SELECT id 
                    FROM CampaignMember
                    WHERE (RTL_Assigned_Agent__c =: UserInfo.getUserId() 
                    or RTL_Contact_Staff_Name__c =: UserInfo.getUserId()) 
                    and RTL_Offer_Result_Eng__c =: FILTER_OFFER_PENDING
                    and Campaign.RecordTypeid in:campaignRecordType.values()
                    and (Campaign.IsActive = true OR ( Campaign.status = 'On Hold' AND RTL_Contact_Staff_Name__c != NULL ))
                    and Campaign.RTL_Call_Start_Date__c <= TODAY AND Campaign.RTL_Call_End_Date__c >= TODAY
                    // [2021-07-13] Filter do not contact to false
                    // and ( Customer__r.DNC_Expired_Date__c = null
                    //       Or Customer__r.DNC_Expired_Date__c < Today
                    //       Or Campaign.Filter_Out_Do_Not_Contact__c = 'No'
                    //       Or Campaign.Filter_Out_Do_Not_Contact__c = null )
                    And (Not ( Campaign.Filter_Out_Do_Not_Contact__c = 'Yes'
                               And Customer__r.DNC_Expired_Date__c != null
                               And Customer__r.DNC_Expired_Date__c > Today))
                    limit 2000];

        if(listPendingCall.size() > 0){
            sizeItemCallList = listPendingCall.size();
        }else{
            sizeItemCallList = 0;
        }
    }


    public class campaignHomeScreenWrapper{
        public Id campaignId {get;set;}
        public String campaignName {get;set;}
        public Integer allCampaignNumber {get;set;}
        public Integer pendingCampaignNumber {get;set;}

        campaignHomeScreenWrapper(Id campaignId,String campaignName,Integer allCampaignNumber,Integer pendingCampaignNumber){
            this.campaignId = campaignId;
            this.campaignName = campaignName;
            this.allCampaignNumber = allCampaignNumber;
            this.pendingCampaignNumber = pendingCampaignNumber;

        }
    }

    public static Boolean startsWithAny(String input, Set<String> substrings)
    {
        if (input == null) return false;
        String expression = '^(' + String.join(new List<String>(substrings), '|') + ')';
        return Pattern.compile(expression).matcher(input).find();
    }

}