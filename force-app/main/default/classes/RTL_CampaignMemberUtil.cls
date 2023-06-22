public without sharing class RTL_CampaignMemberUtil {


    static final String PENDING_TEXT = 'Pending';
    static final String CONTACT_STATUS_NEW = 'New';
    static final String CONTACT_STATUS_UNUSED = 'Unused';
    /**
    * Get Campaign Member Default Record Type
    **/
    private static String campaignMemberDefaultRecordTypeId {
        get{
                if(campaignMemberDefaultRecordTypeId==null){

                    try {
                        RTL_Campaign_Member_Default_Record_Type__mdt cmdrtId = [select id,
                            RTL_Default_Record_Type_Name__c
                            from RTL_Campaign_Member_Default_Record_Type__mdt 
                            where MasterLabel = 'Default'];

                        String recordTypeName = cmdrtId.RTL_Default_Record_Type_Name__c;

                        RecordType rc = [SELECT Id
                        FROM RecordType
                        WHERE sObjectType = 'CampaignMember'
                        AND name = :recordTypeName
                        ];

                        campaignMemberDefaultRecordTypeId = rc.id;
                        
                    } catch(Exception e) {
                        System.debug(e.getMessage());
                        campaignMemberDefaultRecordTypeId = null;
                    }
            }
            return CampaignMemberDefaultRecordTypeId;
        }
        set;
    }

    /**
    * Set Campaign CampaignMemberRecordTypeId to default value
    * This method called on Campaign Trigger (Before Update , Before Insert)
    **/
    public static void setCampaignMemberRecordTypeId(List<Campaign> triggerNewCampaignList)
    {
        
        for(Campaign cam : triggerNewCampaignList)
        {
            if(cam.RTL_Campaign_Channel__c == '2 Outbound DealerDistributorNetwork')
            {
                cam.CampaignMemberRecordTypeId = Schema.Sobjecttype.CampaignMember.getRecordTypeInfosByName().get('Retail Campaign Member').getRecordTypeId();
            }
            else 
            {
                cam.CampaignMemberRecordTypeId = campaignMemberDefaultRecordTypeId;
            }
        }

    }

    /**
    * Set Campaign Member's Offer product from MDM data (Long single String format)
    * This method called on Campaign Member Trigger (Before Update , Before Insert)
    **/
    public static void RTL_SaveProductsOffer(List<CampaignMember> triggernewCampaignMemberList){

        Set<String> retailProductsNameSet = new Set<String> ();
        Set<String> retailProductsSubGroupSet = new Set<String> ();

        Map<String,RTL_product_master__c> RetailProductMap = new Map<String,RTL_product_master__c >();
        Map<String,String> RetailProductSubGroupMap = new  Map<String,String>();

        for(CampaignMember camMem : triggernewCampaignMemberList){

            List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(camMem.RTL_Products_Offer_String__c);

            for( List<String> productItem : productsOffer  )
            {
                if( productItem.get(0) == '3' )
                {
                    retailProductsNameSet.add(productItem.get(1));
                }
                else if ( productItem.get(0) == '2' )
                {
                    retailProductsSubGroupSet.add(productItem.get(1));
                }
                
            }
        }

        // =================== OFFER PRODUCT==================================
        if(retailProductsNameSet.size()>0){
            for(RTL_product_master__c pm : [select Id,RTL_Product2_Name__c ,
                Product_Sub_group__c,Product_Group__c,Active__c,Name
                FROM RTL_product_master__c 
                WHERE Active__c = true 
                AND Name IN: retailProductsNameSet ]){
                RetailProductMap.put(pm.Name,pm);
            }
        }

        if(retailProductsSubGroupSet.size()>0){

            for(AggregateResult agResult : [select Product_Group__c,Product_Sub_group__c
                            from RTL_product_master__c 
                            where Active__c = true AND Product_Sub_group__c IN: retailProductsSubGroupSet 
                            GROUP BY Product_Group__c,Product_Sub_group__c 
                        ]){
                String subGroupName =  (String)agResult.get('Product_Sub_group__c');

                RetailProductSubGroupMap.put( subGroupName.tolowercase() ,(String)agResult.get('Product_Group__c'));
            }
        }

        for(CampaignMember camMem : triggernewCampaignMemberList){

            List<List<String>> productOfferResultList = RTL_UploadCampaignMemberCreateLead.generateProductOfferList(camMem.RTL_Products_Offer_String__c,RetailProductMap,RetailProductSubGroupMap);

            Integer count = 0;

            for( List<String> productOfferItem : productOfferResultList  )
            {
                count++;

                String groupName = productOfferItem.get(0);
                String subGroupName = productOfferItem.get(1);
                String retailProductId = productOfferItem.get(2);

                camMem.put('RTL_Product_Group_'+count+'__c', groupName );
                
                camMem.put('RTL_Sub_Group_'+count+'__c', subGroupName );
                camMem.put('RTL_Campaign_Product_'+count+'__c', retailProductId );   

            }
        }
    }

    public static void RTL_UpdateCampaignMemberAssigned(List<CampaignMember> triggernewCampaignMemberList,Map<ID,CampaignMember> triggerOldCampaignMemberList){

        List<CampaignMember> branchList = new List<CampaignMember>();
        List<CampaignMember> agentList = new List<CampaignMember>();

        List<String> branchItem = new List<String>();
        List<String> agentItem = new List<String>();
                
        for(CampaignMember camMem : triggernewCampaignMemberList){
            String newAssignedAgent = camMem.RTL_Assigned_Agent__c;
            String newAssignedBranch = camMem.RTL_Assigned_Branch__c;
            String oldAssignedAgent = null;
            String oldAssignedBranch = null;

            if(triggerOldCampaignMemberList.containsKey(camMem.Id)){
                CampaignMember camMemOld = triggerOldCampaignMemberList.get(camMem.Id);
                oldAssignedAgent = camMemOld.RTL_Assigned_Agent__c;
                oldAssignedBranch = camMemOld.RTL_Assigned_Branch__c;
            }
                if( newAssignedAgent != null && newAssignedAgent != oldAssignedAgent){
                    //if(newAssignedAgent != null){
                        agentItem.add(newAssignedAgent); 
                        agentList.add(camMem);

                    //}
                }else if( newAssignedBranch != null && newAssignedBranch != oldAssignedBranch){
                        //if(newAssignedBranch != null){
                            branchItem.add(newAssignedBranch);
                            branchList.add(camMem);
                        //}
                }
        }
 
        if(branchItem.size() > 0){
            Map<Id, Branch_and_Zone__c> branchAndZoneLists = new Map<Id, Branch_and_Zone__c>([SELECT Id, Branch_Code__c, RTL_Zone_Code__c, RTL_Region_Code__c FROM Branch_and_Zone__c where Id in:branchItem]);
        
            for(CampaignMember newCamMemBranch: branchList ){
                Branch_and_Zone__c branchAndZoneById = branchAndZoneLists.get(newCamMemBranch.RTL_Assigned_Branch__c);
                newCamMemBranch.RTL_Branch_Team_Name_Code_Rpt__c = branchAndZoneById.Branch_Code__c;
                newCamMemBranch.RTL_Assigned_Region_Code_Rpt__c = branchAndZoneById.RTL_Region_Code__c;

                if( branchAndZoneById.RTL_Zone_Code__c != null &&  branchAndZoneById.RTL_Zone_Code__c.length() > 4 )
                {
                    newCamMemBranch.RTL_Assigned_Zone_Rpt__c = branchAndZoneById.RTL_Zone_Code__c.substring(0,4);
                }
                else 
                {
                    newCamMemBranch.RTL_Assigned_Zone_Rpt__c = branchAndZoneById.RTL_Zone_Code__c;    
                }

                // for assigned branch - clead assigned agent
                newCamMemBranch.RTL_Assigned_Agent__c = null;
                
            }
        }

        if(agentItem.size() > 0){
            Map<Id, User> userLists = new Map<Id, User>([SELECT Id, RTL_Branch_Code__c ,Zone_Code__c, Region_Code__c FROM User WHERE Id in:agentItem]);

            Set<String> userBranchCodeMap = new Set<String>();
            //Get branch ID from Branch Code
            for(User u : userLists.values() ) 
            {
                userBranchCodeMap.add( u.RTL_Branch_Code__c );
            }

            List<Branch_and_Zone__c> branchs = [SELECT Id,Branch_Code__c FROM Branch_and_Zone__c WHERE Branch_Code__c in:userBranchCodeMap];
            Map<String,ID> branchCodeIdMap = new Map<String,ID>();

            for(Branch_and_Zone__c bz : branchs )
            {
                branchCodeIdMap.put(bz.Branch_Code__c,bz.id);
            }

            for(CampaignMember newCamMemAgent: agentList ){

                User userById = userLists.get(newCamMemAgent.RTL_Assigned_Agent__c);
                newCamMemAgent.RTL_Branch_Team_Name_Code_Rpt__c = userById.RTL_Branch_Code__c;
                newCamMemAgent.RTL_Assigned_Region_Code_Rpt__c = userById.Region_Code__c;

                newCamMemAgent.RTL_Assigned_Zone_Rpt__c = userById.Zone_Code__c;
                //if( userById.Zone_Code__c != null && userById.Zone_Code__c.length() > 4 )
                //{
                //    newCamMemAgent.RTL_Assigned_Zone_Rpt__c = userById.Zone_Code__c.substring(0,4);
                //}
                //else 
                //{
                //    newCamMemAgent.RTL_Assigned_Zone_Rpt__c = userById.Zone_Code__c;
                //}
                
                //Also add assigned branch from User's Branch 
                // Null also accept for this case

                if( branchCodeIdMap.containsKey( userById.RTL_Branch_Code__c ) )
                {
                    newCamMemAgent.RTL_Assigned_Branch__c = branchCodeIdMap.get(userById.RTL_Branch_Code__c);
                }
                else 
                {
                    newCamMemAgent.RTL_Assigned_Branch__c = null;
                }

            }
        }
        
    }

    // Move code to updateExpiredCampaignMemberDataBatch
    //public static void RTL_UpdateContactStatus(List<Campaign> triggerNewCampaignList, Map<Id,Campaign> oldCampaignMap)
    //{
    //    List<Id> camMemId = new List<Id>();
    //    for(Campaign camList : triggerNewCampaignList){
    //         String camOldId = '';

    //        if(oldCampaignMap.containsKey(camList.Id)){
    //            Campaign camOld = oldCampaignMap.get(camList.Id);
    //            camOldId = camOld.Status;
    //        }

    //        if(camList.Status == 'Expired' && camOldId != 'Expired'){
    //            camMemId.add(camList.Id);
    //        }
    //    }

    //    if(camMemId.size() > 0){
    //        List<CampaignMember> camMemLists = [SELECT Id,RTL_Contact_Status__c FROM campaignmember WHERE RTL_Contact_Status__c='New' and campaign.id in:camMemId];
    //        if(camMemLists.size() > 0){
    //            for(CampaignMember camMem : camMemLists){
    //                camMem.RTL_Contact_Status__c = 'Unused';
    //            }
    //            update camMemLists;
    //        }
    //    }
    //}

 public static void RTL_UpdateMarkettingCode(List<CampaignMember> triggerNewCampaignMemberList)
    {
        //======== Remove running no read+update from Custom Setting ===============
        //RTL_CampaignMember_Running_No__c runningNo = [SELECT Name,Running_No__c 
        //    FROM RTL_CampaignMember_Running_No__c 
        //    WHERE Name = 'Campaign Member Running No' LIMIT 1 FOR UPDATE ];

        //MAP<ID,String> campaignCodeMap = new MAP<ID,String>();
        Set<ID> camIdList = new Set<ID>();
        for( CampaignMember cm : triggerNewCampaignMemberList )
        {
            camIdList.add(cm.CampaignId);
            
            //campaignCodeMap.put( cm.CampaignId , cm.RTL_Campaign_Code_10_digits__c );
        }

        Map<ID,Campaign> campaignMap = new Map<ID,Campaign>([SELECT ID,RTL_Campaign_Code_10_digits__c,
            Parent.RTL_Campaign_Type__c , RTL_TotalMembersinHierarchy__c
            FROM Campaign WHERE Id in :camIdList ]);

        Map<ID,Integer> countValueMap = new Map<ID,Integer>();
        
        for( ID camId : campaignMap.keySet() )
        {
            Integer intCm = Integer.ValueOf(campaignMap.get(camId).RTL_TotalMembersinHierarchy__c);
            countValueMap.put(camId,intCm);
        }

        //======== Remove running no read+update from Custom Setting ===============
        //Integer runningNoInt = Integer.ValueOf(runningNo.Running_No__c);
        //Integer oldRunningNoInt = runningNoInt;
        
        //String running =  String.ValueOf(runningNoInt).leftPad(10 ,'0'); 

        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String rdString = '';
        String codeText = '';

        for (Integer c=0;c<2;c++)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            codeText += chars.substring(idx, idx+1);
        }

        for( CampaignMember cm : triggerNewCampaignMemberList )
        {
            String campaignType = campaignMap.get( cm.CampaignId ).Parent.RTL_Campaign_Type__c;
            

            //if( campaignType == 'Mass' || campaignType == 'Local Exclusive' )
            //{
                if( ( cm.RTL_Marketing_Code__c == '' || cm.RTL_Marketing_Code__c == null ) && ( cm.RTL_Web_Unique_ID__c == '' || cm.RTL_Web_Unique_ID__c == null ) )
                {
                    String codeCountMember = String.ValueOf(countValueMap.get(cm.CampaignId)+1).leftPad(8 ,'0');
                    Integer newCountMem = countValueMap.get(cm.CampaignId)+1;
                    //runningNoInt++;
                    //running = String.ValueOf(runningNoInt).leftPad(10 ,'0');
                    String campaignCode = campaignMap.get( cm.CampaignId ).RTL_Campaign_Code_10_digits__c;
                    //cm.RTL_Marketing_Code__c = campaignCode+running;
                    cm.RTL_Marketing_Code__c = campaignCode+codeText+codeCountMember;
                    countValueMap.put(cm.CampaignId,newCountMem);
                }

            //}
        }

        //======== Remove running no read+update from Custom Setting ===============
        //if( oldRunningNoInt != runningNoInt )
        //{
        //    runningNo.Running_No__c = running;
        //    update runningNo;
        //}
    }

    public static void RTL_UpdateCustomer(List<CampaignMember> triggerNewCampaignMemberList)
    {
        List<ID> contactIdList = new List<ID>();
        for( CampaignMember cm : triggerNewCampaignMemberList )
        {
            if( cm.ContactId != null )
            {
                contactIdList.add(cm.ContactId);
            }
        }
        Map<ID,Contact> contactMap = new Map<ID,Contact>([ SELECT id,Account.id From Contact 
            WHERE id in :contactIdList ]);

        for( CampaignMember cm : triggerNewCampaignMemberList )
        {
            if( cm.ContactId != null )
            {
                Contact c = contactMap.get( cm.ContactId );
                cm.Customer__c = c.Account.Id;
            }
        }
    }

    /*
    Trigger to update Lead Owner Id base on CampaignMember assigned Agent/Branch
    */
    public static void updateLeadOwnerIdFromCampaign(List<CampaignMember> triggerNewCampaignMemberList)
    {
        List<CampaignMember> leadTypeCampaignMemberList = new List<CampaignMember>();

        for( CampaignMember cmOrg : triggerNewCampaignMemberList )
        {
            if( cmOrg.LeadId != null )
            {
                if( cmOrg.RTL_Assigned_Branch__c != null || cmOrg.RTL_Assigned_Agent__c != null )
                {
                    leadTypeCampaignMemberList.add(cmOrg);
                }
            }
        }

        if( leadTypeCampaignMemberList.size() > 0 )
        {
            MAP<ID,ID> LeadQueueORUserMap = new MAP<ID,ID>();

            SET<ID> branchZoneIdList = new SET<ID>();
            for(CampaignMember cm : leadTypeCampaignMemberList )
            {
                if( cm.RTL_Assigned_Branch__c != null )
                {
                    branchZoneIdList.add(cm.RTL_Assigned_Branch__c);
                } 
            }

            MAP<ID,String> branchQueueDevNameMap = new MAP<ID,String>();
            MAP<String,ID> queueDevNameBranchMap = new MAP<String,ID>();
            List<Branch_and_Zone__c> bzList = [ SELECT id,Branch_Code__c
                    from Branch_and_Zone__c 
                    WHERE id IN :branchZoneIdList ];

            for( Branch_and_Zone__c bz : bzList )
            {
                String devName = 'RTL_' + bz.Branch_Code__c;
                String devName2 = 'RTLQ_' + bz.Branch_Code__c;
                //branchQueueDevNameMap.put( bz.id,devName )
                queueDevNameBranchMap.put( devName,bz.id );
                queueDevNameBranchMap.put( devName2,bz.id );
            }

            MAP<ID,ID> bracnhGroupMap = new MAP<ID,ID>();
            List<Group> groupList = [ Select Id, DeveloperName from Group where Type = 'Queue' AND DeveloperName in :queueDevNameBranchMap.keySet() ];
            for(Group gp : groupList)
            {
                ID branchZoneId = queueDevNameBranchMap.get(gp.DeveloperName);
                bracnhGroupMap.put( branchZoneId , gp.id );
            }

            for(CampaignMember cm : leadTypeCampaignMemberList )
            {
                // Because if assigned agent defined, trigger will auto stamp assigned branch
                // So now check is assinged agent not null first
                if( cm.RTL_Assigned_Agent__c != null )
                {
                    ID agentId = cm.RTL_Assigned_Agent__c;
                    LeadQueueORUserMap.put(cm.LeadID , agentId);
                }
                else if( cm.RTL_Assigned_Branch__c != null )
                {
                    ID queueId = bracnhGroupMap.get(cm.RTL_Assigned_Branch__c);
                    LeadQueueORUserMap.put(cm.LeadID , queueId );
                }
            }

            // Update lead to Queue/Agent on Owner
            if( LeadQueueORUserMap.size() > 0 )
            {
                //LeadQueueORUserMap

                List<Lead> leadList = [SELECT id,OwnerId FROM Lead WHERE id in :LeadQueueORUserMap.keySet() ];

                for( Lead ld : leadList )
                {
                    ld.OwnerId = LeadQueueORUserMap.get(ld.id);
                }
                Database.SaveResult[] srList = Database.update(leadList, false);

            }

            
        }

    }

    public static void updateExpiredCampaignMemberDataBatch(List<Campaign> triggernewCampaign, Map<ID,Campaign> triggerOldCampaignMap)
    {
        // Get all changed status campaign ID
        List<ID> expiringCampaignId = new List<ID>();
        for(Campaign newCam : triggernewCampaign)
        {
            Campaign oldCam = triggerOldCampaignMap.get(newCam.id);

            if( newCam.Status == 'Expired' && oldCam.Status != 'Expired' )
            {
                expiringCampaignId.add(newCam.id);
            }
        }

        if( expiringCampaignId.size() > 0 )
        {

            // If called inb futured or batch - call normal method instead
            if( System.isFuture() || System.isBatch() )
            {
                //system.debug('xxx: call in future/batch');
                // Not to call update campaign member if called by 
                //updateExpiredCampaignMemberData(expiringCampaignId); 
            } 
            else // If not in future or batch -> call in batch
            {
                //system.debug('xxx: call in not future/batch');
                RTL_UpdateCampaignMemberOfferResultBatch ucmorBatch = new RTL_UpdateCampaignMemberOfferResultBatch(expiringCampaignId);
                Database.executeBatch(ucmorBatch);  
            }
        }

    }

    //this method for skip check campaign active 
    public static boolean checkActiveCampaign(Campaign camp,CampaignMember cm){
        Boolean campaignIsActive = false;

        if(camp.status != 'Expired' && camp.status != 'On Hold' && camp.status != 'Cancelled' && camp.Approvedflag__c){
          campaignIsActive = true;
        }
        else if(cm.RTL_Contact_Status__c != 'New' && cm.RTL_Contact_Status__c != null && cm.RTL_Contact_Status__c != '' && camp.status == 'On Hold'){
          campaignIsActive = true;
        }else if(camp.RecordType.DeveloperName == 'Dummy_Campaign'){
          campaignIsActive = true;
        }


        system.debug('campaignIsActive : '+campaignIsActive);

        return campaignIsActive;

    }

    public static void RTL_StampLeadName(List<CampaignMember> triggernewCampaignMemberList,Map<ID,CampaignMember> triggerOldCampaignMemberList)
    {
        for( CampaignMember cm : triggernewCampaignMemberList )
        {
            if( cm.ContactId == null )
            {
                if(  cm.LeadId != null && cm.RTL_Lead_Name__c != cm.LeadId )
                {
                    cm.RTL_Lead_Name__c = cm.LeadId;
                }
            }
            else
            {
                cm.RTL_Lead_Name__c = null;
            }
        }
    }

    //This method for get fulfillment status code with description
    public static String getFulfillmentCodeWithDesc (String fftypecode,String fftype){
        Map<String,RTL_Fulfillment_Type_Mapping__mdt> mapFulfillmentType = new Map<String,RTL_Fulfillment_Type_Mapping__mdt>();
        //Mapping FF Status code with Fulfillment type
        for(RTL_Fulfillment_Type_Mapping__mdt ft : listFulfillmentType()){
            if(ft.RTL_Fulfillment_Type_Code__c != null){
                mapFulfillmentType.put(ft.RTL_Fulfillment_Type_Code__c,ft);
            } 
        }

        string statusCode;

        if(mapFulfillmentType.get(fftypecode)!=null){
                statusCode = (fftypecode!=null)?fftypecode+' - '+mapFulfillmentType.get(fftypecode).RTL_Description__c:System.Label.RTL_Fulfillment_Processing;
        }else if(fftype != null){
            for(RTL_Fulfillment_Type_Mapping__mdt ft : listFulfillmentType()){
                if(fftype.equalsignorecase(ft.RTL_Fulfillment_Type_Name__c)){
                    statusCode = ft.RTL_Description__c;
                    break;
                }else{
                    statusCode = System.Label.RTL_Fulfillment_Processing;
                }
            }
        }else{
            statusCode = System.Label.RTL_Fulfillment_Processing;
        }

        return statusCode;

    }

    public static String getFulfillmentStatus (String cusid,String campaigncode){
        string ffStatus;
        string campaignSubtype;
        if(campaigncode!=null){
            List<RTL_Fulfillment__c> fulfillmentSource = [Select RTL_Fulfillment_Status__c,RTL_campaign__r.RTL_Fulfillment_DateTime__c ,RTL_campaign__r.RTL_Fulfillment_End_Date__c
                                                        ,RTL_campaign__r.RTL_Campaign_Sub_Type_child2__c ,RTL_Customer__r.TMB_Customer_ID_PE__c
                                                     from RTL_Fulfillment__c 
                                                     where RTL_Campaign__r.RTL_Campaign_Code_10_digits__c=:campaigncode];
            Map<String,Campaign> mapCampaignCode  = new Map<String,Campaign>();
            for(Campaign c : [Select id,RTL_Campaign_Code_10_digits__c,RTL_Campaign_Sub_Type_child2__c ,RTL_Fulfillment_End_Date__c,RTL_Fulfillment_DateTime__c 
                                from Campaign where RTL_Campaign_Code_10_digits__c =:campaigncode]){
                mapCampaignCode.put(c.RTL_Campaign_Code_10_digits__c, c);
            }
            campaignSubtype = mapCampaignCode.get(campaigncode).RTL_Campaign_Sub_Type_child2__c;

            if(mapCampaignCode.get(campaigncode).RTL_Campaign_Sub_Type_child2__c != null){
                campaignSubtype = mapCampaignCode.get(campaigncode).RTL_Campaign_Sub_Type_child2__c.split(' ').get(1);
            }

            //campaign sub type has fulfillment
            if(campaignSubtype  != null && 
                campaignSubtype == 'HasCampaignFulfillment'){

                //campaign between fulfillment date or fulfillment date is blank
                if(System.Today() >= mapCampaignCode.get(campaigncode).RTL_Fulfillment_DateTime__c || mapCampaignCode.get(campaigncode).RTL_Fulfillment_DateTime__c == null ){
                    //campaign has fulfillment record
                    if(fulfillmentSource.size() > 0 ){
                        for(RTL_Fulfillment__c f : fulfillmentSource){
                            //fulfillment same tmb cus
                            if(f.RTL_Customer__r.TMB_Customer_ID_PE__c==cusid){
                                ffStatus = 'Completed';
                                break;
                            } 
                        }
                    }
                }
                
                if(ffStatus == null){
                    //fulfillment late
                    if(mapCampaignCode.get(campaigncode).RTL_Fulfillment_End_Date__c !=null &&
                        System.Today() > mapCampaignCode.get(campaigncode).RTL_Fulfillment_End_Date__c){ 
                        ffStatus = 'Not eligible';
                    }else{
                        ffStatus = 'Pending'; 
                    }
                }
                
            }else{
                ffStatus = 'N/A';
            }
        }

        return ffStatus;
    }

    //This method for get all fulfillment type mapping list
    public static List<RTL_Fulfillment_Type_Mapping__mdt> listFulfillmentType(){
        List<RTL_Fulfillment_Type_Mapping__mdt> fulfillmentTypeMappingList = [select Id,RTL_Status_Code__c,
                                                    RTL_Fulfillment_Type_Name__c,
                                                    RTL_Fulfillment_Type_Code__c,
                                                    RTL_Description__c,
                                                    RTL_Success_Status__c
                                                    from RTL_Fulfillment_Type_Mapping__mdt];

        return fulfillmentTypeMappingList;
    }

}