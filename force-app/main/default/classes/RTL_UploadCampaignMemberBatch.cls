global class RTL_UploadCampaignMemberBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts {

	public String ucmLID {get;set;}
    public String ucmbId {get;set;}
    private String campaignName = '';

	private RTL_Upload_Campaign_Member_Logs__c ucml ;
    private RTL_Upload_Campaign_Member_Batch__c ucmb;

    public transient Map<String,Branch_and_Zone__c> branchMap {get;set;}
    public transient Map<String,Contact> TMBCustMap {get;set;}
    public transient Map<String,User> TMBUserMap {get;set;}
    public transient Map<String,String> TMBQueueMap {get;set;}
    
    public transient Set<String> BranchSet {get;set;}
    public transient Set<String> TMBQueueSet {get;set;}
    public transient Set<String> TMBCustSet {get;set;}
    public transient Set<String> TMBUserSet {get;set;}
    public transient Set<String> RetailProductSet {get;set;}


    public transient Set<String> retailProductsNameSet {get;set;}
    public transient Set<String> retailProductsSubGroupSet {get;set;}
    //public transient List<String> retailProductsGroupSet {get;set;}

    public transient Map<String,RTL_product_master__c > RetailProductMap {get;set;}
    public transient Map<String,String> RetailProductSubGroupMap {get;set;}

    //public transient Map<String,String > RetailProductGroupMap {get;set;}

   
    global Integer total = 0;


    /**
    *   uploadCampaignMemberLog - Campaign Member Log 
    *   uploadCampaignMemBatchList - List of Campaign Member Bacth that being processed from previous chained job(RTL_UploadCampaignMemberImportBatch.cls)
    **/
	global RTL_UploadCampaignMemberBatch(RTL_Upload_Campaign_Member_Logs__c uploadCampaignMemberLog , RTL_Upload_Campaign_Member_Batch__c uploadCampaignMemberBatch ) {
		        
        ucml = uploadCampaignMemberLog;
		ucmLID = uploadCampaignMemberLog.id;	

        ucmb = uploadCampaignMemberBatch;
        ucmbId = uploadCampaignMemberBatch.id;	

        if( ucml.RTL_Campaign__c != null )
        {
            String camId = ucml.RTL_Campaign__c;
            Campaign cam = [SELECT Id,Name FROM Campaign WHERE id=:camId ];
            campaignName = cam.Name;
        }
	}
	

	// Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){  

	// Batch query members in previous batch job getting campaign member to process save to SalesForce
    	return Database.getQueryLocator([
            SELECT CreatedById,CreatedDate,Id,LastModifiedById,LastModifiedDate,Name,
            RTL_leadOwner__c,RTL_CHANNEL_DM__c,RTL_CHANNEL_OB__c,RTL_CHANNEL_SMS__c,
            RTL_CHANNEL_EDM__c,RTL_CHANNEL_BRANCH__c,RTL_CHANNEL_MIB__c,RTL_CHANNEL_OBD__c,
            RTL_AssignedBranch__c ,RTL_AssignedRM__c,RTL_TMBCustID__c,RTL_Title__c,
            RTL_FirstName__c,RTL_LastName__c,RTL_GENDER__c,RTL_AGE__c,RTL_ID_Type__c,
            RTL_ADDRESS1__c,RTL_ADDRESS2__c,RTL_ADDRESS3__c,RTL_PROVINCE__c,RTL_ZIPCODE__c,
            RTL_MOBILEPHONE__c,RTL_HOMEPHONE__c,RTL_INCOME__c,RTL_OCCUPATION__c,RTL_Email_Address__c,RTL_FB_ID__c,
            // RTL_FB_EMAIL__c,
            RTL_Segment__c,RTL_COST_PER_LEAD__c,RTL_SOURCE__c,
            RTL_UPDATE_DATE__c,RTL_PRODUCT_OFFER__c,RTL_REGISTER_DATE__c,RTL_DATA_SOURCE__c,
            RTL_PROMOTION__c,RTL_TARGET__c,RTL_PRODUCT_FEATURE__c,RTL_REMARK1__c,RTL_REMARK2__c,
            RTL_Row_No__c,RTL_CampaignID__c,RTL_ImportStatus__c,RTL_CHANNEL_OTHER__c,RTL_Citizen_ID__c,
            RTL_Rating__c
            , LeadSource__c , RTL_Source_Reference__c, RTL_TMB_Campaign_Source__c, RTL_TMB_Campaign_Reference__c,RTL_Customer_Segment__c
            ,RTL_Web_Unique_ID__c
            FROM RTL_Upload_Campaign_Members__c 
            WHERE RTL_Upload_Campaign_Member_Batch__c = : ucmbId
            ORDER BY RTL_Row_No__c ASC
        ]);
    }

     // Execute Logic
    global void execute(Database.BatchableContext BC, List<RTL_Upload_Campaign_Members__c> scope){
        RTL_InterestedProductTriggerHandler.isCampMemberBatch = true;

    	// Mapping for User.RTL_Zone_Code__c , Branch_and_Zone__c.ID     	
    	branchmap = new Map<String,Branch_and_Zone__c>();  
    	
    	// Mapping TMB Account.ID , Account sObject   
        TMBCustMap = new Map<String,Contact>();
        
        // Mapping User.Employee_ID__c , User.ID
        TMBUserMap = new Map<String,User>();
        
        // Mapping Group.Name , Group.ID
        TMBQueueMap = new Map<String,String >();

        // Map Product name with Master object
        RetailProductMap = new Map<String,RTL_product_master__c >();
        RetailProductSubGroupMap = new Map<String,String>();
        
        // Set of Assing Branch (Which existing in this set)
        BranchSet = new Set<String>();
        
        // Set of TMB Cust Id (Which existing in this set)
        TMBCustSet = new Set<String>();
        
        // Set of lead owner lenght > 5 [User for lead owner of campaign member]  (Which existing in this set)
        TMBUserSet = new Set<String>();
        
        // Set of lead owner lenght < 5 [User for lead owner of campaign member] (Which existing in this set)
        TMBQueueSet = new Set<String>();
        
        // Set of all product offering 1-5  (Which existing in this set)
        RetailProductSet = new Set<String>();

        retailProductsNameSet = new Set<String>();
        retailProductsSubGroupSet = new Set<String>();


		//==== Prepare data to list for mapping the query data
        for(RTL_Upload_Campaign_Members__c ucm : scope){

            if( ucm.RTL_ImportStatus__c != null && ucm.RTL_ImportStatus__c != '' )
            {
                continue;
            }


			// Record has TMB Cust ID
            if(ucm.RTL_TMBCustID__c !=null && ucm.RTL_TMBCustID__c !=''){
            	
            	TMBCustSet.add(ucm.RTL_TMBCustID__c);
            // Record don't has TMB Cust ID	
            }else{

				// If Lead owner existing
            	if(ucm.RTL_leadOwner__c !=null && ucm.RTL_leadOwner__c !=''){
                     // Length == 5 - Emploe
                    if(ucm.RTL_leadOwner__c.length() ==5){
                       TMBUserSet.add(ucm.RTL_leadOwner__c);
                    }else{ // Length > 5 - group (queue)
                       TMBQueueSet.add(ucm.RTL_leadOwner__c);
                    } 
                 }
            }

            // Also add User Id for Assigned RM/Agent
            if(ucm.RTL_AssignedRM__c !=null && ucm.RTL_AssignedRM__c !=''){
                TMBUserSet.add(ucm.RTL_AssignedRM__c);
            }

			// If Assinged Branch existing
            if(ucm.RTL_AssignedBranch__c !=null && ucm.RTL_AssignedBranch__c !='' ){
            	Branchset.add(ucm.RTL_AssignedBranch__c);
            }

            // =================== OFFER PRODUCT==================================
            String productOfferString = ucm.RTL_PRODUCT_OFFER__c;

            List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(productOfferString);

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
                //else if ( productItem.get(0) == '1' )
                //{
                //    retailProductsGroupSet.add(productItem.get(1));
                //}
                
            }


            //=======================================================

        }
        // End for
        
		//Query Branch and Zone - WHERE IN AssignedBranch Code
        if(BranchSet.size() > 0){
            for(Branch_and_Zone__c branch : [SELECT id,
                    Branch_Code__c,RTL_Region_Code__c,RTL_Zone_Code__c
                    from Branch_and_Zone__c 
                    WHERE Branch_Code__c IN :BranchSet
                    AND IsActive__c = true
                    //OR RTL_Zone_Code__c IN :BranchSet 
                ]){
                branchmap.put(branch.Branch_Code__c,branch);
            }
        }
                
        //Query Existing Customer through TMB Cust ID
        if(TMBCustSet.size() > 0){
            for(Contact ct : [SELECT ID,TMB_Customer_ID__c,Account.id  from Contact WHERE TMB_Customer_ID__c IN:TMBCustSet]){
                TMBCustMap.put(ct.TMB_Customer_ID__c,ct);
            }
        }

        //Query Users which related with LeadOwner or Assigned RM
        if(TMBUserSet.size() > 0){
            for(User us : [SELECT ID,Employee_ID__c,
                        RTL_Branch_Code__c,Region_Code__c,Zone_Code__c
                        from User 
                        WHERE Employee_ID__c IN:TMBUserSet
                        AND IsActive = true
                        ]){
                TMBUserMap.put(us.Employee_ID__c,us);
            }
        }

        //Query Queues
        if(TMBQueueSet.size() > 0){
            for(Group gro : [select Id,Name from Group where Type = 'Queue' AND Name IN:TMBQueueSet]){
                TMBQueueMap.put(gro.Name,gro.id);
            }
        }

        // =================== OFFER PRODUCT==================================
        if(retailProductsNameSet.size() > 0){
            for(RTL_product_master__c pm : [select Id,RTL_Product2_Name__c ,
                Product_Sub_group__c,Product_Group__c,Active__c,Name
                FROM RTL_product_master__c 
                WHERE Active__c = true 
                AND Name IN: retailProductsNameSet ]){
                RetailProductMap.put(pm.Name,pm);
            }
        }

        if(retailProductsSubGroupSet.size() > 0){

            for(AggregateResult agResult : [select Product_Group__c,Product_Sub_group__c
                            from RTL_product_master__c 
                            where Active__c = true AND Product_Sub_group__c IN: retailProductsSubGroupSet 
                            GROUP BY Product_Group__c,Product_Sub_group__c 
                        ]){
                String subGroupName =  (String)agResult.get('Product_Sub_group__c');

                RetailProductSubGroupMap.put( subGroupName.tolowercase() ,(String)agResult.get('Product_Group__c'));
            }
        }

        
        //================ Save Processing ==================
        // Save to campaign member
        if( ucmL.RTL_Campaign__c != null )
        {
        	saveCampaignMember(scope);
        }
        else // Save as lead
        {
        	saveLead(scope);
        }
                
        //================ End Save Processing ==============
    }


    global void finish(Database.BatchableContext BC){

        
        RTL_UploadCampaignMemberGenerateLogBatch ucmglBatch = new RTL_UploadCampaignMemberGenerateLogBatch(ucml,ucmb);
        Database.executeBatch(ucmglBatch);
        
        //sendNotificationEmail();


    }
   
    private void saveCampaignMember(List<RTL_Upload_Campaign_Members__c> scope)
    {
      	List<CampaignMember> CampaignMemberforexisting = new List<CampaignMember>();        
        List<CampaignMember> CampaignMemberfornew = new List<CampaignMember>();
        
        List<Lead> newLeadInsertList = new List<Lead>();

        
        List<RTL_Upload_Campaign_Members__c> ucmLExistingList = new  List<RTL_Upload_Campaign_Members__c>();
        List<RTL_Upload_Campaign_Members__c> ucmLNewList = new  List<RTL_Upload_Campaign_Members__c>();
        
        //Map<Integer,Lead> leadMap = new Map<Integer,Lead>();
        Map<Integer,List<RTL_Interested_products_c__c>> interestedProductGroupMap = new Map<Integer,List<RTL_Interested_products_c__c>>();

        //Map<Integer,CampaignMember> campaignMemberwMap = new Map<Integer,CampaignMember>();

        Integer idx = 0;
        Integer idxLead = 0;
                        
        // Save data to campaing member
        for(RTL_Upload_Campaign_Members__c ucm : scope){

            if( ucm.RTL_ImportStatus__c != null && ucm.RTL_ImportStatus__c != '' )
            {
                continue;
            }
        	
        	//boolean isExisting = false;
        	CampaignMember CampMem = new CampaignMember();
            //CampMem.RecordTypeId = campaignMemberDefaultRecordTypeId;

			// ========= Save general data to Campaign Member ========================
			// Assing Member to Campaign
            campMem.CampaignID = ucm.RTL_CampaignID__c;
            
            campMem.RTL_Channel_DirectMail__c = (ucm.RTL_CHANNEL_DM__c == 'Y') ? true : false;
            campMem.RTL_Channel_Outbound__c = (ucm.RTL_CHANNEL_OB__c == 'Y') ? true : false;
            campMem.RTL_Channel_SMS__c = (ucm.RTL_CHANNEL_SMS__c == 'Y') ? true : false;
            campMem.RTL_Channel_Edm__c = (ucm.RTL_CHANNEL_EDM__c == 'Y') ? true : false;
            campMem.RTL_Channel_Branch__c  = (ucm.RTL_CHANNEL_BRANCH__c == 'Y') ? true : false;
            campMem.RTL_Channel_MIB__c = (ucm.RTL_CHANNEL_MIB__c == 'Y') ? true : false;
            campMem.RTL_Channel_OBD__c = (ucm.RTL_CHANNEL_OBD__c == 'Y') ? true : false;
            campMem.RTL_Channel_Other__c = (ucm.RTL_CHANNEL_OTHER__c == 'Y') ? true : false;

            // Assing Branch ID (From branch Code)
            // Use Assinged Agent first if existng both
            if(ucm.RTL_AssignedRM__c !=null && ucm.RTL_AssignedRM__c !=''){

                if( TMBUserMap.containskey(ucm.RTL_AssignedRM__c) )
                {
                    User u = TMBUserMap.get(ucm.RTL_AssignedRM__c);

                    campMem.RTL_Assigned_Agent__c = u.id;
                    campMem.RTL_Branch_Team_Name_Code_Rpt__c = u.RTL_Branch_Code__c;
                    campMem.RTL_Assigned_Region_Code_Rpt__c = u.Region_Code__c;
                    campMem.RTL_Assigned_Zone_Rpt__c = u.Zone_Code__c;  
                }
            }
            else if(ucm.RTL_AssignedBranch__c !=null && ucm.RTL_AssignedBranch__c !='' 
                && branchmap.containskey(ucm.RTL_AssignedBranch__c) ){

                if( branchmap.containskey(ucm.RTL_AssignedBranch__c) )
                {
                    Branch_and_Zone__c bz = branchmap.get(ucm.RTL_AssignedBranch__c);

                    campMem.RTL_Assigned_Branch__c = bz.id;   
                    campMem.RTL_Branch_Team_Name_Code_Rpt__c = bz.Branch_Code__c;
                    campMem.RTL_Assigned_Region_Code_Rpt__c = bz.RTL_Region_Code__c;
                    campMem.RTL_Assigned_Zone_Rpt__c = bz.RTL_Zone_Code__c;          
                }  
            }

            campMem.RTL_CampHis_Phone__c = ucm.RTL_MOBILEPHONE__c;

            campMem.RTL_Segmentation__c = ucm.RTL_Segment__c;
            //campMem.RTL_Segment__c = ucm.RTL_Segment__c;

            //========== Stamp Update and Register Date ====================
            try
            {
                campMem.RTL_Update_Date__c = date.valueOf(ucm.RTL_Update_Date__c);
            }
            catch (Exception e)
            {
                campMem.RTL_Update_Date__c = null;
            }  

            try
            {
                campMem.RTL_Register_Date__c =  date.valueOf(ucm.RTL_REGISTER_DATE__c);
            }
            catch (Exception e)
            {
                campMem.RTL_Register_Date__c = null;
            }  
       
            //campMem.RTL_Update_Date__c = ucm.RTL_Update_Date__c;
            //campMem.RTL_Register_Date__c = ucm.RTL_REGISTER_DATE__c
           

            campMem.RTL_Data_Source__c = ucm.RTL_DATA_SOURCE__c;
            campMem.RTL_Promotion__c = ucm.RTL_PROMOTION__c;
            campMem.RTL_Target__c = ucm.RTL_TARGET__c;
            campMem.RTL_Product_Feature__c = ucm.RTL_PRODUCT_FEATURE__c;
            campMem.RTL_Remark__c = ucm.RTL_REMARK1__c;
            campMem.RTL_Remark_2__c = ucm.RTL_REMARK2__c;
            campMem.RTL_Contact_Status__c = 'new';

            // campMem.LeadSource = ucm.LeadSource__c;

            campMem.RTL_TMB_Campaign_Source__c = ucm.RTL_TMB_Campaign_Source__c;
            campMem.RTL_TMB_Campaign_Reference__c = ucm.RTL_TMB_Campaign_Reference__c;
            campMem.RTL_Lead_Group__c = ucm.RTL_Customer_Segment__c;

            
            campMem.RTL_Products_Offer_String__c = ucm.RTL_PRODUCT_OFFER__c;

            String productOfferString = ucm.RTL_PRODUCT_OFFER__c;
            //***** Change to process product offer via Trigger ****
            //String productOfferString = ucm.RTL_PRODUCT_OFFER__c;
            //List<List<String>> productOfferResultList = RTL_UploadCampaignMemberCreateLead.generateProductOfferList(productOfferString,RetailProductMap,RetailProductSubGroupMap);

            //Integer count = 0;

            
            //for( List<String> productOfferItem : productOfferResultList  )
            //{
            //    count++;

            //    String groupName = productOfferItem.get(0);
            //    String subGroupName = productOfferItem.get(1);
            //    String retailProductId = productOfferItem.get(2);

            //    CampMem.put('RTL_Product_Group_'+count+'__c', groupName );
            //    CampMem.put('RTL_Sub_Group_'+count+'__c', subGroupName );
            //    CampMem.put('RTL_Campaign_Product_'+count+'__c', retailProductId );   

            //}
            //***** Change to process product offer via Trigger ****

            /* 
                Project Name		    AL Integration-Manual Upload Campaign Member		
                System Name		        CRM Salesforce		
                Project Executive				
                Project Manager				
                Business Analyst		K. Napaporn Pichetjaras		
                Distributed Date		19-Nov-2020		
                1. Enhance function Upload Campaign Member.
            */
            CampMem.RTL_Web_Unique_ID__c = ucm.RTL_Web_Unique_ID__c;

			//================= Assign Member to Contact / Lead base on type ===============================
			//Check for Existing - Contact

            if(ucm.RTL_TMBCustID__c !=null && ucm.RTL_TMBCustID__c !=''){
            	
            	//isExisting = true;
            	
            	if(TMBCustMap.containsKey(ucm.RTL_TMBCustID__c)){
            		
                    Contact custContact = TMBCustMap.get(ucm.RTL_TMBCustID__c);
                    CampMem.ContactId = custContact.id;
                    //CampMem.Customer__c = custContact.Account.id;					
            	}
            	
            	ucm.RTL_ImportToType__c = 'Contact';
            	ucmLExistingList.add(ucm);

            	CampaignMemberforexisting.add(campMem);
            	
    
            }else{ // If not , create record as Lead 

            	Lead leadRec = RTL_UploadCampaignMemberCreateLead.createLeadFromCampaignMember(ucm,TMBUserMap,TMBQueueMap,campaignName);
                newLeadInsertList.add(Leadrec);
                
                ucm.RTL_ImportToType__c = 'Lead';
                ucmLNewList.add(ucm);

                CampaignMemberfornew.add(campMem);
            	
                List<RTL_Interested_products_c__c> productInterestedResultList = RTL_UploadCampaignMemberCreateLead.generateProductInterestedList(productOfferString,RetailProductMap);
                interestedProductGroupMap.put(idxLead,productInterestedResultList);

                idxLead++;

            }


			//========== Finish loop =======================
			
            idx++;
        }
		
		
		//------------------------- Member type Contact -----------------------------------
        // =========== insert CampaignMemberforexisting for existing contact ========
        Database.SaveResult[] lsrforExisting = Database.insert(CampaignMemberforexisting,false);
        
        // Process to loop and update import status back to Upload Campaign Member
        for (Integer i = 0; i < lsrforExisting.size(); i++) {
        	
        	if( lsrforExisting.get(i).isSuccess() )
        	{
        		ucmLExistingList[i].RTL_ImportToCampaignMemberID__c =  lsrforExisting.get(i).getId();
        		ucmLExistingList[i].RTL_ImportStatusDescription__c = 'Import Campaing member(Contact) Success';
        		ucmLExistingList[i].RTL_ImportStatus__c = 'Success';
        	}
        	else
        	{
        		Database.Error error = lsrforExisting.get(i).getErrors().get(0);

                String errMsg = error.getMessage();
                // Check and replace error text for tmb id is null
                if(  errMsg.containsIgnoreCase( 'Attempted to add a campaign member where either the member id' ) )
                {
                    errMsg = 'TMB_CUST_ID is invalid';
                }


        		ucmLExistingList[i].RTL_ImportToCampaignMemberID__c = '';
        		ucmLExistingList[i].RTL_ImportStatusDescription__c = errMsg;
        		ucmLExistingList[i].RTL_ImportStatus__c = 'Failed';
        	}
        	
        }
        update ucmLExistingList;
        
        
        
        //------------------------- Member type Lead -----------------------------------
        // Create lead for not exiting customer
        Database.SaveResult[] lsrforLead;

        if(newLeadInsertList.size() > 0){
        	//insert newLeadInsertList;
        	lsrforLead = Database.insert(newLeadInsertList,false);        	
        }

        // Create interested Product for Lead

        List<RTL_Interested_products_c__c> insertProductInterestedList = new List<RTL_Interested_products_c__c>();
        for( Integer leadKey : interestedProductGroupMap.keySet() )
        {
            // Get Lead ID from inserted Lead
            String leadKeyId = newLeadInsertList.get(leadKey).id;
            if( leadKeyId != null &&  leadKeyId != '' )
            {
                List<RTL_Interested_products_c__c> productInterestedList = interestedProductGroupMap.get(leadKey);

                for( RTL_Interested_products_c__c productInterestedItem  : productInterestedList )
                {
                    productInterestedItem.Campaign_Code__c = (ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != '' && ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != null )?ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c:ucmL.RTL_Campaign__r.RTL_Campaign_Code_9_digits__c;
                    productInterestedItem.Campaign_Name__c = ucmL.RTL_Campaign__r.Name;
                    productInterestedItem.Lead__c = leadKeyId;
                    insertProductInterestedList.add(productInterestedItem);
                }
            }
        }

        Database.SaveResult[] ipResult = Database.insert(insertProductInterestedList,false);

		// =========== insert CampaignMemberfornew for Lead ========
		// Not existing customer add as Lead
        integer index=0;
        for(Lead lrec : newLeadInsertList){
        	       	
        	CampaignMember campmemNew = CampaignMemberfornew.get(index);
        	campmemNew.LeadID = newLeadInsertList.get(index).id;
        	index++;
        }
		
        //insert CampaignMemberfornew;
        Database.SaveResult[] lsrforNew = Database.insert(CampaignMemberfornew,false);
	
        // Process to loop and update import status back to Upload Campaign Member
        for (Integer i = 0; i < lsrforNew.size(); i++) {
        	
			if( lsrforNew.get(i).isSuccess() )
        	{
                ucmLNewList[i].RTL_Lead__c =  CampaignMemberfornew[i].LeadID;
        		ucmLNewList[i].RTL_ImportToCampaignMemberID__c =  lsrforNew.get(i).getId();
        		ucmLNewList[i].RTL_ImportStatusDescription__c = 'Import Campaing member(Lead) Success';
        		ucmLNewList[i].RTL_ImportStatus__c = 'Success';
        	}
        	else
        	{
        		String errorMessage = '';
                // In case lead insert failed , add error for lead insert instead

                if( lsrforLead.get(i).isSuccess() == false )
                {
                    Database.Error error = lsrforLead.get(i).getErrors().get(0);
                    errorMessage = 'Lead save error: ' + error.getMessage();
                }
                else 
                {
                    Database.Error error = lsrforNew.get(i).getErrors().get(0);
                    errorMessage = 'Campaign Member save error: ' + error.getMessage();
                    
                }

                ucmLNewList[i].RTL_ImportToCampaignMemberID__c = '';
                ucmLNewList[i].RTL_ImportStatusDescription__c = errorMessage;
                ucmLNewList[i].RTL_ImportStatus__c = 'Failed';

        		
        	}
        	
        }
        
        update ucmLNewList;
    }
    

    private void saveLead(List<RTL_Upload_Campaign_Members__c> scope)
    {
          
        List<Lead> newLeadInsertList = new List<Lead>();
		List<RTL_Upload_Campaign_Members__c> ucmLNewList = new  List<RTL_Upload_Campaign_Members__c>();
		List<RTL_Upload_Campaign_Members__c> ucmLIgnoreList = new  List<RTL_Upload_Campaign_Members__c>();
		
        //Map<Integer,Lead> leadMap = new Map<Integer,Lead>();
        Map<Integer,List<RTL_Interested_products_c__c>> interestedProductGroupMap = new Map<Integer,List<RTL_Interested_products_c__c>>();
                
        Integer idx=0;  
        Integer idxLead=0;  
        // Save data to campaing member
        for(RTL_Upload_Campaign_Members__c ucm : scope){
        	
            if( ucm.RTL_ImportStatus__c != null && ucm.RTL_ImportStatus__c != '' )
            {
                continue;
            }

          	//================= Assign Member to Contact / Lead base on type ===============================
			//Check for Existing - skip this row
            if(ucm.RTL_TMBCustID__c !=null && ucm.RTL_TMBCustID__c !=''){
            	
            	ucm.RTL_ImportToType__c = 'Lead';
            	ucm.RTL_ImportStatusDescription__c = 'Ignore TMB customer record because of no Campaing selected';
        		ucm.RTL_ImportStatus__c = 'Failed';
            	ucmLIgnoreList.add(ucm);
				continue;
    
            }else{
            	            	
            	 
            	Lead leadRec = RTL_UploadCampaignMemberCreateLead.createLeadFromCampaignMember(ucm,TMBUserMap,TMBQueueMap,campaignName);
            	
                newLeadInsertList.add(leadRec);

                //leadMap.put(idx,leadRec);
                
                ucm.RTL_ImportToType__c = 'Lead';

            	ucmLNewList.add(ucm);
                String productOfferString = ucm.RTL_PRODUCT_OFFER__c;

                List<RTL_Interested_products_c__c> productInterestedResultList = RTL_UploadCampaignMemberCreateLead.generateProductInterestedList(productOfferString,RetailProductMap);
                interestedProductGroupMap.put(idxLead,productInterestedResultList);
                idxLead++;

            }
			
			//========== Finish loop =======================
			
            idx++;
        }
		
		// Update ignore record status to upload member
		
		update ucmLIgnoreList; 

        //------------------------- Member type Lead -----------------------------------
        // Create lead for not exiting customer
        if(newLeadInsertList.size()>0){
        	//insert newLeadInsertList;
        	Database.SaveResult[] lsrforLead = Database.insert(newLeadInsertList,false);  
        	
        	// Process to loop and update import status back to Upload Campaign Member
	        for (Integer i = 0; i < lsrforLead.size(); i++) {
	        	
				if( lsrforLead.get(i).isSuccess() )
	        	{
                    ucmLNewList[i].RTL_Lead__c =  lsrforLead.get(i).getId();
	        		ucmLNewList[i].RTL_ImportToCampaignMemberID__c =  '';
	        		ucmLNewList[i].RTL_ImportStatusDescription__c = 'Import Lead Success';
	        		ucmLNewList[i].RTL_ImportStatus__c = 'Success';
	        	}
	        	else
	        	{
	        		Database.Error error = lsrforLead.get(i).getErrors().get(0);
	        		
	        		ucmLNewList[i].RTL_ImportToCampaignMemberID__c = '';
	        		ucmLNewList[i].RTL_ImportStatusDescription__c = error.getMessage();
	        		ucmLNewList[i].RTL_ImportStatus__c = 'Failed';
	        	}
	        	
	        }
	        
	        update ucmLNewList;   
        	      	
        }

        // Create interested Product for Lead

        List<RTL_Interested_products_c__c> insertProductInterestedList = new List<RTL_Interested_products_c__c>();
        for( Integer leadKey : interestedProductGroupMap.keySet() )
        {
            // Get Lead ID from inserted Lead
            String leadKeyId = newLeadInsertList.get(leadKey).id;
            if( leadKeyId != null &&  leadKeyId != '' )
            {
                List<RTL_Interested_products_c__c> productInterestedList = interestedProductGroupMap.get(leadKey);

                for( RTL_Interested_products_c__c productInterestedItem  : productInterestedList )
                {
                    productInterestedItem.Campaign_Code__c = (ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != '' && ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != null )?ucmL.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c:ucmL.RTL_Campaign__r.RTL_Campaign_Code_9_digits__c;
                    productInterestedItem.Campaign_Name__c = ucmL.RTL_Campaign__r.Name;
                    productInterestedItem.Lead__c = leadKeyId;
                    insertProductInterestedList.add(productInterestedItem);
                }
            }
        }

        Database.SaveResult[] ipResult = Database.insert(insertProductInterestedList,false);


    }

    
    
}