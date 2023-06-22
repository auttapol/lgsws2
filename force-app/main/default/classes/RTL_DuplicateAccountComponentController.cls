public without sharing class RTL_DuplicateAccountComponentController {
	public CampaignMember currentObject {get;set;}
	public Id accId {get;set;}
    public Account acct {get;set;}

    private String LABEL_INTEREST = 'Interested';
    private Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt> mapConfRecordType = new Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt>();
    private Map<String,RecordType> mapRecordType = new Map<String,RecordType>();

	public Boolean showErrorMessagePage {get; set;}
	public Boolean showSelectAccountPage {get; set;}
	public Boolean CreateOpptyDone {get; set;}

    public Boolean isConvertSuccess {get; set;}

	List<Opportunity> oppList = new List<Opportunity>();
	List<Opportunity> OpportunityList = new List<Opportunity>();

	public Id contactid {get;set;}
    public String contactName {get;set;}

	public Lead objLead {
		get{
			if(objLead != null){
				return objLead;
			}

			if(currentObject != null){
				objLead = getLead(currentObject.LeadId);
			}

			return objLead;
		}
	set;}

	DuplicateAccountController DupAccCtr;
	
	public List<Account> DupAccounts {
		get{
			if(DupAccounts != null){
				return DupAccounts;
			}

			if(currentObject != null){
				// DupAccCtr = new DuplicateAccountController(currentObject.LeadId);
                DupAccCtr = new DuplicateAccountController(objLead.RTL_Citizen_Id__c, objLead.RTL_ID_Type__c, objLead.RTL_Mobile_Number__c);
			}else if(currentObject == null && objLead != null){
                DupAccCtr = new DuplicateAccountController(objLead.Id);
            }

			DupAccounts = DupAccCtr.accounts;
			return DupAccounts;
		}
		set;
	}
    
    public Boolean isFromLeadDetail{
        get{
            return (currentObject == null && objLead != null);
        }
        set;
    }

    public List<RTL_CampaignProductInterestedWrapper> createOppList {
        get
        {
            if(createOppList == null){
                createOppList = new List<RTL_CampaignProductInterestedWrapper>();
            }
            return createOppList;
            
        }set;
    }

    private static Set<ID> userIDset {get{
        if (userIDSet == null) {
            userIDset = new Set<ID>();
        }
        return userIdSet;
        } set;
    }
    
    private static Set<ID> branchIDset {get{
        if (branchIDset == null) {
            branchIDset = new Set<ID>();
        }
        return branchIDset;
        } set;
    }
    
    private static Set<ID> contactIDset {get{
        if (contactIDset == null) {
            contactIDset = new Set<ID>();
        }
        return contactIDset;
        } set;
    }

    private static Map<ID, String> userNameMap {get{
        if (userNameMap == null) {
            userNameMap = new Map<ID, String>();
        }
        return userNameMap;
        } set;
    }
  
    private static Map<ID, String> branchNameMap {get{
        if (branchNameMap == null) {
            branchNameMap = new Map<ID, String>();
        }
        return branchNameMap;
        } set;
    }
  
    private static Map<ID, String> contactNameMap {get{
        if (contactNameMap == null) {
            contactNameMap = new Map<ID, String>();
        }
        return contactNameMap;
        } set;
    }

    private static Map<String, String> prefixSobjectMap {get{
        if (prefixSobjectMap == null) {
            prefixSobjectMap = new Map<String, String>();
            Map<String, Schema.SobjectType> describe = Schema.getGlobalDescribe();
            for (String s : describe.keyset()) {
                prefixSobjectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
            }
        }
        return prefixSobjectMap;
        } set;
    }

    public class CampaignProductInterestedWrapper{
        public Integer numberOfProduct {get;set;}
        public Integer rowNum {get;set;}
        public String apiProductGroup {get;set;}
        public String apiProductSubGroup {get;set;}
        public String apiProductId {get;set;}
        public String apiProductName {get;set;}
        public Opportunity objOpp {get;set;}
        public Boolean viewSubGroup {get;set;}
        public Boolean viewProductName {get;set;}
        
        public CampaignProductInterestedWrapper(Integer rowNum,String apiProductGroup,String apiProductSubGroup,
            String apiProductId,String apiProductName,Opportunity objOpp,Boolean viewSubGroup,Boolean viewProductName){
            this.rowNum = rowNum;
            this.apiProductGroup = apiProductGroup;
            this.apiProductSubGroup = apiProductSubGroup;
            this.apiProductId = apiProductId;
            this.apiProductName = apiProductName;
            this.objOpp = objOpp;
            this.viewSubGroup = viewSubGroup;
            this.viewProductName = viewProductName;
        }
    }

    //****************************** CONSTRUCTIOR *******************************
	public RTL_DuplicateAccountComponentController() {
		showSelectAcc();
        isConvertSuccess = false;
        if(currentObject != null){
            for(RTL_NBO_Product_Record_Type_Mapping__mdt each : getConfRecordType() ){
                string productgroup = each.RTL_Product_Group__c;
                productgroup = productgroup.touppercase();
                mapConfRecordType.put(productgroup,each);
            }

            for(RecordType each : getRecordTypeOpportunity() ){
                mapRecordType.put(each.DeveloperName,each);
            }
        }else if(objLead != null && currentobject == null){
            System.debug('isFromLeadDetail');
            System.debug(isFromLeadDetail);
            System.debug('DupAccounts');
            System.debug(DupAccounts);
        }
	}

    //****************************** BUTTON FUNCTION *******************************
    public PageReference close(){
        PageReference returnPage = Page.RTL_ViewCampaignMember;
        try{
            if(currentObject.id!=null){
                CampaignMember cm = [SELECT id FROM Campaignmember WHERE contactid =: contactid
                                     AND contactid!= null AND campaignid =: currentObject.campaignid LIMIT 1];
                system.debug('merge campaign member : '+cm);
                if(cm != null){
                    currentObject = getCampaignMember(cm.Id).get(0);
                }else{
                    currentObject = getCampaignMember(currentObject.Id).get(0);
                }               
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003)); 
                //	Cannot edit Campaign Member record. The campaign is currently inactive.
            }

        }catch(Exception e){
            returnPage = new PageReference('/' + currentObject.Id);  
        }

        if( currentObject.Id != null ){
            returnPage.getParameters().put('id',currentObject.Id);
        }
        else{
            // returnPage.getParameters().put('mcode', markettingCode);
            // returnPage.getParameters().put('tmbid', tmbCustId);
        }

        returnPage.setRedirect(true);
        return returnPage;
    }

	public void ClickMerge(){
		PageReference pg;

		if(String.isBlank(accId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.RTL_Unselected_Account_Error_Message));
            //	Please Select Account Below.
			showErrMsgPage();

		}else{
            if(CheckDupAccountMerge()){
                if(isFromLeadDetail){
                    MergeConvertLeadDetail();
                }else{
                    MergeConvertLeadCAMPAIGN();
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.RTL_Merge_Account_Error_Message));
                //	Customer with the same ID Type/ID Number is found on System. Unable to merge a new prospect.
                showErrMsgPage();
            }
        }
    }

	public PageReference CreateNewAccount() {
        System.debug('ClickNewAccount');
        System.debug('isFromLeadDetail');
        System.debug(isFromLeadDetail);

		PageReference pg;

		if(CheckDupAccount()){
			//Create Acc and convert lead
			System.debug('Ready to Convert Lead');
            if(isFromLeadDetail){
                // isConvertSuccess = true;
                return NewConvertLeadDetail();
            }else{
                return NewAccConvertLeadCAMPAIGN();
            }
		}else{
			//Go to Error page
			System.debug('ERROR PAGE');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.RTL_Create_Account_Error_Message));
            //	Customer with the same ID Type/ID Number is found on System. Unable to create a new prospect.
			showErrMsgPage();
			return null;
		}
		return pg;
    }

    public PageReference ClickBack(){
        System.debug('ClickBack');
        System.debug('isFromLeadDetail');
        System.debug(isFromLeadDetail);

        if(isFromLeadDetail){
            PageReference pg = new PageReference('/' + objLead.Id);
            return pg;
        }else{
            return backPageCreateOpportunity();
        }
    }


    //******************************* CORE FUNCTION *******************************
    //***** CREATE NEW ACCOUNT FOR CONVERT LEAD FROM LEAD DETAIL PAGE*****
    public PageReference NewConvertLeadDetail(){
        Id conId;

        Savepoint sp = Database.setSavepoint();

        try{ 
            if( objLead.Id != null && !objLead.IsConverted ){
                System.debug('Convert Lead Step (CREATE NEW ACCOUNT LEAD DETAIL PAGE) : Lead => '+ objLead.Id);
                
                // FOR SKIP CHECK UP CONVERT LEAD
                objLead.RTL_Allow_Convert_Lead__c = true;
                objLead.Status = 'Qualified';

                update objLead;

                //GET convertStatus
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();
                
                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(false);
                lc.setLeadId(objLead.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
                acct = getAccount();
                System.debug('Convert Lead finish : Account => '+ accId);
                isConvertSuccess = true;
            }              
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Common_error_message));
            //ไม่สามารถทำการแปลงรายชื่อเป้าหมายได้ กรุณาลองอีกครั้ง หรือติดต่อ Admin ของระบบ
            
            showErrMsgPage();
            
            return null;
        }
        return null;
    }

    //***** MERGE ACCOUNT FOR CONVERT LEAD FROM LEAD DETAIL PAGE*****
    public void MergeConvertLeadDetail(){
        Id conId;

        Savepoint sp = Database.setSavepoint();

        try{ 
            if( objLead.Id != null && !objLead.IsConverted ){
                System.debug('Convert Lead Step (MERGE ACCOUNT LEAD DETAIL PAGE) : Lead => '+ objLead.Id);
                
                // FOR SKIP CHECK UP CONVERT LEAD
                objLead.RTL_Allow_Convert_Lead__c = true;
                objLead.Status = 'Qualified';

                update objLead;

                //GET CONTACT
				List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
											FROM Contact WHERE AccountID =: accId
											];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;
				}

                //GET convertStatus
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();
                
                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(false);
                lc.setLeadId(objLead.id);
				lc.setAccountId(accId);
                System.debug('accId : ' + accId);
				lc.setContactId(conId);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();

                System.debug('Convert Lead finish : Account => '+ accId);
                isConvertSuccess = true;
            }              
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : ' + e.getMessage());
            System.debug('CRM : ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Common_error_message ));
            //ไม่สามารถทำการแปลงรายชื่อเป้าหมายได้ กรุณาลองอีกครั้ง หรือติดต่อ Admin ของระบบ
            
            showErrMsgPage();
            
            // return null;
        }
        // return null;
    }

    //***** MERGE ACCOUNT FOR CONVERT LEAD FROM EDIT CAMPAIGN MEMBER*****
	public PageReference MergeConvertLeadCAMPAIGN(){
        Savepoint sp = Database.setSavepoint();
        oppList = new List<Opportunity>();
        Id conId;

        //UPDATE CAMPAIGN MEMBER
        try{          
            updateCampaignMember();  
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002));
            //Update campaign member fail.
            
            showErrMsgPage();    
            
            return null;
        }

        try{ 
            if( currentObject.ContactId == null && objLead.Id != null && !objLead.IsConverted ){
                System.debug('Convert Lead Step (MERGE ACCOUNT LEAD DETAIL PAGE) : Lead => '+ objLead.Id);

                // FOR SKIP CHECK UP CONVERT LEAD
                objLead.RTL_Allow_Convert_Lead__c = true;
                objLead.Status = 'Qualified';

                if( !validateLead(objLead,objLead) ){
                    Database.rollback(sp);
                    return null;
                }

                update objLead;

				List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
											FROM Contact WHERE AccountID =: accId
											];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;
					contactid = conId;//for redirect page                        
				}

                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(objLead.id);
				lc.setAccountId(accId);
				lc.setContactId(conId);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
            }                    
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage());
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
            //Update campaign member fail.
            
            showErrMsgPage();  
            return null;
        }

        //Create Opportunity step
        Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();

        System.debug('Create Opportunity step');
        System.debug('createOppList : ' + createOppList);

        if( createOppList.size() > 0 ){            
            for( RTL_CampaignProductInterestedWrapper each : createOppList ){
                Opportunity newOpp = new Opportunity();
                newOpp = each.objOpp;
                newOpp.RTL_Product_Group__c = String.valueOf(currentObject.get(each.apiProductGroup));
                newOpp.RTL_Prod_SubGrp__c = String.valueOf(currentObject.get(each.apiProductSubGroup));
                newOpp.RTL_Product_Name__c = String.valueOf(currentObject.get(each.apiProductId));
                newOpp.AccountId = accId;    
                newOpp.CampaignId = currentObject.CampaignId;
                newOpp.RTL_Campaign_Code__c = currentObject.Campaign.RTL_Campaign_Code_10_digits__c;
                newOpp.RTL_Campaign_Name__c = currentObject.Campaign.Name;
                newOpp.RTL_Campaign_Start_Date__c = currentObject.Campaign.RTL_Campaign_Start_Date__c;     
                newOpp.RTL_Is_Create_From_Campaign_Member__c = true; //for except validation rule when create opp
                //TAY CODE 2020-05-25 CR Redesign Droplead retail 
                newOpp.RTL_Campaign_Lead_Source__c = currentObject.RTL_TMB_Campaign_Source__c;
                newOpp.RTL_Campaign_Lead_Reference__c = currentObject.RTL_TMB_Campaign_Reference__c;
                newOpp.LeadSource = currentObject.LeadSource;         
                
                /*
                    Project: AL Integration
                    Description: Mapping fields Auto loan create opportunity
                    Editor: Narathip Santhip
                    Date modified: 20201014
                 */
                newOpp.RTL_AL_available_time__c = currentObject.RTL_AL_available_time__c;
                newOpp.RTL_AL_car_bought_from__c = currentObject.RTL_AL_car_bought_from__c;
                newOpp.RTL_AL_car_brand__c = currentObject.RTL_AL_car_brand__c;
                newOpp.RTL_AL_car_gear__c = currentObject.RTL_AL_car_gear__c;
                newOpp.RTL_AL_car_group__c = currentObject.RTL_AL_car_group__c;
                newOpp.RTL_AL_car_plate_no__c = currentObject.RTL_AL_car_plate_no__c;
                newOpp.RTL_AL_car_subtype__c = currentObject.RTL_AL_car_subtype__c;
                newOpp.RTL_AL_car_type__c = currentObject.RTL_AL_car_type__c;
                newOpp.RTL_AL_car_year__c = currentObject.RTL_AL_car_year__c;
                newOpp.RTL_AL_comment__c = currentObject.RTL_AL_comment__c;
                newOpp.RTL_AL_contact_channel__c = currentObject.RTL_AL_contact_channel__c;
                newOpp.RTL_AL_ContactDistrict__c = currentObject.RTL_AL_ContactDistrict__c;
                newOpp.RTL_AL_ContactProvince__c = currentObject.RTL_AL_ContactProvince__c;
                newOpp.RTL_AL_ContactSubDistrict__c = currentObject.RTL_AL_ContactSubDistrict__c;
                newOpp.RTL_AL_ContactZipcode__c = currentObject.RTL_AL_ContactZipcode__c;
                newOpp.RTL_AL_installment_amount__c = currentObject.RTL_AL_installment_amount__c;
                newOpp.RTL_AL_installment_periods__c = currentObject.RTL_AL_installment_periods__c;
                newOpp.RTL_AL_Interested_Rate__c = currentObject.RTL_AL_Interested_Rate__c;
                newOpp.RTL_AL_max_set_up_amount__c = currentObject.RTL_AL_max_set_up_amount__c;
                newOpp.RTL_AL_normal_price__c = currentObject.RTL_AL_normal_price__c;
                newOpp.RTL_AL_oa_ref_code__c = currentObject.RTL_AL_oa_ref_code__c;
                newOpp.RTL_AL_wanted_amount__c = currentObject.RTL_AL_wanted_amount__c;

                Integer numberOfProduct =  each.numberOfProduct;
                productNoOpptyMap.put( numberOfProduct, newOpp );

            }
        }

        system.debug('productNoOpptyMap : ' + productNoOpptyMap);
        
        try{
            if( productNoOpptyMap.values().size() > 0 )
            {
                system.debug('productNoOpptyMap'+productNoOpptyMap);
                insert productNoOpptyMap.values();
                oppList = productNoOpptyMap.values();
            }
            
        }catch( DMLEXception e){
            Database.rollback(sp);
            System.debug('CPM : ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
            //Update campaign member fail.
            
            showErrMsgPage();
            
            return null;
        }

        if( productNoOpptyMap.keySet().size() > 0 )
        {
            for( Integer i : productNoOpptyMap.keySet() )
            {
                Opportunity objOpp = productNoOpptyMap.get(i);

                currentObject.put('RTL_RelatedOpportunity_'+i+'__c',objOpp.id); 

                // Auto add product to campaign member
                currentObject.put('RTL_Product_Group_'+i+'__c', objOpp.RTL_Product_Group__c );
                currentObject.put('RTL_Sub_Group_'+i+'__c', objOpp.RTL_Prod_SubGrp__c);
                currentObject.put('RTL_Campaign_Product_'+i+'__c', objOpp.RTL_Product_Name__c );
                currentObject.put('RTL_Reason_'+i+'__c',null); 
            }

            try{
                if(currentObject.id != null){
                    update currentObject;
                }else{
                    system.debug('Insert Campaign member : '+currentObject);
                    String store = currentObject.RTL_Products_Offer_String__c;
                    currentObject.RTL_Products_Offer_String__c = null;
                    
                    insert currentObject;
                    updateProductOfferString(currentObject,store);
                    saveLogCampaignmember(currentObject);
                }
                
            }catch( Exception e ){
                Database.rollback(sp);
                System.debug(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
                //Update campaign member fail.
                
                showErrMsgPage();
                
                return null;
            }
        }

        OpportunityList = getOpportunityList();
        showCreateOptyDone();
        return null;
    }

    public PageReference NewAccConvertLeadCAMPAIGN(){
        Savepoint sp = Database.setSavepoint();
        oppList = new List<Opportunity>();
        Id conId;

        //UPDATE CAMPAIGN MEMBER
        try{          
            updateCampaignMember();  
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002));
            //Update campaign member fail.
            
            showErrMsgPage();    
            
            return null;
        }

        try{ 
            if( currentObject.ContactId == null && objLead.Id != null && !objLead.IsConverted ){
                System.debug('Convert Lead Step (NEW ACCOUNT LEAD DETAIL PAGE) : Lead => '+ objLead.Id);

                // FOR SKIP CHECK UP CONVERT LEAD
                objLead.RTL_Allow_Convert_Lead__c = true;
                objLead.Status = 'Qualified';

                if( !validateLead(objLead,objLead) ){
                    Database.rollback(sp);
                    return null;
                }

                update objLead;

                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(objLead.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                conId = lcr.getContactId();
                accId = lcr.getAccountId();
            }                    
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage());
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
            //Update campaign member fail.
            
            showErrMsgPage();  
            return null;
        }

        //Create Opportunity step
        Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();

        System.debug('Create Opportunity step');
        System.debug('createOppList : ' + createOppList);

        if( createOppList.size() > 0 ){            
            for( RTL_CampaignProductInterestedWrapper each : createOppList ){
                Opportunity newOpp = new Opportunity();
                newOpp = each.objOpp;
                newOpp.RTL_Product_Group__c = String.valueOf(currentObject.get(each.apiProductGroup));
                newOpp.RTL_Prod_SubGrp__c = String.valueOf(currentObject.get(each.apiProductSubGroup));
                newOpp.RTL_Product_Name__c = String.valueOf(currentObject.get(each.apiProductId));                
                newOpp.AccountId = accId;    
                newOpp.CampaignId = currentObject.CampaignId;
                newOpp.RTL_Campaign_Code__c = currentObject.Campaign.RTL_Campaign_Code_10_digits__c;
                newOpp.RTL_Campaign_Name__c = currentObject.Campaign.Name;
                newOpp.RTL_Campaign_Start_Date__c = currentObject.Campaign.RTL_Campaign_Start_Date__c;     
                newOpp.RTL_Is_Create_From_Campaign_Member__c = true; //for except validation rule when create opp
                //TAY CODE 2020-05-25 CR Redesign Droplead retail 
                newOpp.RTL_Campaign_Lead_Source__c = currentObject.RTL_TMB_Campaign_Source__c;
                newOpp.RTL_Campaign_Lead_Reference__c = currentObject.RTL_TMB_Campaign_Reference__c;
                newOpp.LeadSource = currentObject.LeadSource;
                
                /*
                    Project: AL Integration
                    Description: Mapping fields Auto loan create opportunity
                    Editor: Narathip Santhip
                    Date modified: 20201014
                 */
                newOpp.RTL_AL_available_time__c = currentObject.RTL_AL_available_time__c;
                newOpp.RTL_AL_car_bought_from__c = currentObject.RTL_AL_car_bought_from__c;
                newOpp.RTL_AL_car_brand__c = currentObject.RTL_AL_car_brand__c;
                newOpp.RTL_AL_car_gear__c = currentObject.RTL_AL_car_gear__c;
                newOpp.RTL_AL_car_group__c = currentObject.RTL_AL_car_group__c;
                newOpp.RTL_AL_car_plate_no__c = currentObject.RTL_AL_car_plate_no__c;
                newOpp.RTL_AL_car_subtype__c = currentObject.RTL_AL_car_subtype__c;
                newOpp.RTL_AL_car_type__c = currentObject.RTL_AL_car_type__c;
                newOpp.RTL_AL_car_year__c = currentObject.RTL_AL_car_year__c;
                newOpp.RTL_AL_comment__c = currentObject.RTL_AL_comment__c;
                newOpp.RTL_AL_contact_channel__c = currentObject.RTL_AL_contact_channel__c;
                newOpp.RTL_AL_ContactDistrict__c = currentObject.RTL_AL_ContactDistrict__c;
                newOpp.RTL_AL_ContactProvince__c = currentObject.RTL_AL_ContactProvince__c;
                newOpp.RTL_AL_ContactSubDistrict__c = currentObject.RTL_AL_ContactSubDistrict__c;
                newOpp.RTL_AL_ContactZipcode__c = currentObject.RTL_AL_ContactZipcode__c;
                newOpp.RTL_AL_installment_amount__c = currentObject.RTL_AL_installment_amount__c;
                newOpp.RTL_AL_installment_periods__c = currentObject.RTL_AL_installment_periods__c;
                newOpp.RTL_AL_Interested_Rate__c = currentObject.RTL_AL_Interested_Rate__c;
                newOpp.RTL_AL_max_set_up_amount__c = currentObject.RTL_AL_max_set_up_amount__c;
                newOpp.RTL_AL_normal_price__c = currentObject.RTL_AL_normal_price__c;
                newOpp.RTL_AL_oa_ref_code__c = currentObject.RTL_AL_oa_ref_code__c;
                newOpp.RTL_AL_wanted_amount__c = currentObject.RTL_AL_wanted_amount__c;
                
                Integer numberOfProduct =  each.numberOfProduct;
                productNoOpptyMap.put( numberOfProduct, newOpp );

            }
        }

        system.debug('productNoOpptyMap : ' + productNoOpptyMap);
        
        try{
            if( productNoOpptyMap.values().size() > 0 )
            {
                system.debug('productNoOpptyMap'+productNoOpptyMap);
                insert productNoOpptyMap.values();
                oppList = productNoOpptyMap.values();
            }
            
        }catch( DMLEXception e){
            Database.rollback(sp);
            System.debug('CPM : ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
            //Update campaign member fail.
            
            showErrMsgPage();
            
            return null;
        }

        if( productNoOpptyMap.keySet().size() > 0 )
        {
            for( Integer i : productNoOpptyMap.keySet() )
            {
                Opportunity objOpp = productNoOpptyMap.get(i);

                currentObject.put('RTL_RelatedOpportunity_'+i+'__c',objOpp.id); 

                // Auto add product to campaign member
                currentObject.put('RTL_Product_Group_'+i+'__c', objOpp.RTL_Product_Group__c );
                currentObject.put('RTL_Sub_Group_'+i+'__c', objOpp.RTL_Prod_SubGrp__c);
                currentObject.put('RTL_Campaign_Product_'+i+'__c', objOpp.RTL_Product_Name__c );
                currentObject.put('RTL_Reason_'+i+'__c',null); 
            }

            try{
                if(currentObject.id != null){
                    update currentObject;
                }else{
                    system.debug('Insert Campaign member : '+currentObject);
                    String store = currentObject.RTL_Products_Offer_String__c;
                    currentObject.RTL_Products_Offer_String__c = null;
                    
                    insert currentObject;
                    updateProductOfferString(currentObject,store);
                    saveLogCampaignmember(currentObject);
                }
                
            }catch( Exception e ){
                Database.rollback(sp);
                System.debug(e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
                //Update campaign member fail.
                
                showErrMsgPage();
                
                return null;
            }
        }

        OpportunityList = getOpportunityList();
        showCreateOptyDone();
        return null;
    }

    //****************** RESOURCE FUNCTION **********************
    public Account getAccount(){
        if(accId != null){
            return [SELECT Id, Name FROM ACCOUNT WHERE Id = :accId LIMIT 1];
        }
        return null;
    }

    public List<Opportunity> getOpportunityList(){
        List<Opportunity> returnList = [select Id,Name,AccountId,Account.Name,RTL_Product_Name__r.Name,RTL_Product_Name__c,StageName,RTL_Status__c,Amount,CloseDate,Owner.Name
        from Opportunity where Id IN :oppList];
        if( returnList.size() > 0 ){
            contactName = returnList.get(0).Account.Name;
        }
        System.debug('contactName');
        System.debug(contactName);

        System.debug('returnList');
        System.debug(returnList);
        return returnList;
    }

    private void saveLogCampaignmember(CampaignMember camMem){
        
        for (String fieldName : RTL_CampaignMemberTriggerHandler.getFieldTracking()) {
            if(camMem.get(fieldName) != null) {
                String newvalue;
                newvalue = String.valueof(camMem.get(fieldName));
                settingValueTranformation(newvalue);
                if (userIDset.size() > 0) {
                    for (User us : [SELECT ID, FirstName, LastName from USER WHERE ID IN:userIDset ]) {
                        userNameMap.put(us.id, us.FirstName + ' ' + us.LastName);
                    }
                }
                if (branchIDset.size() > 0) {
                    for (Branch_and_Zone__c baz : [SELECT ID, Name from branch_and_zone__c WHERE ID IN:branchIDset]) {
                      branchNameMap.put(baz.id, baz.Name);
                    }
                }
                if (contactIDset.size() > 0) {
                    for (Contact con : [SELECT ID, FirstName, LastName from Contact WHERE ID IN:contactIDset]) {
                      contactNameMap.put(con.id, con.FirstName + ' ' + con.LastName);
                    }
                }
            }
        }

        Set<String> empIDSet = new Set<String>();
        Set<ID> campaignmemberChangedIDSet = new Set<ID>();

        RTL_Campaign_Member_History__c camh = new RTL_Campaign_Member_History__c();
        camh.RTL_Campaign_Member_ID__c = camMem.id;
        camh.RTL_Campaign__c = camMem.CampaignId;
        camh.RTL_Modified_By__c = UserInfo.getUserId();            
        camh.RTL_Date__c = System.now();

        if (camMem.LeadID != null ) {
            camh.RTL_Lead__c = camMem.LeadID;
        } else if (camMem.ContactID != null) {
            camh.RTL_Contact__c = camMem.ContactID;
        }

        campaignmemberChangedIDSet.add(camMem.id);

        insert camh;
        //END saveLogHistory

        List<RTL_Campaign_Member_History_detail__c> insertHistoryDetailList = new List<RTL_Campaign_Member_History_detail__c>();

        for (String fieldName : RTL_CampaignMemberTriggerHandler.getFieldTracking()) {
            string oldvalue=null;
            string newvalue;
            if (camMem.get(fieldName) != null) {
                RTL_Campaign_Member_History_detail__c  cmhd = new RTL_Campaign_Member_History_detail__c();
                cmhd.RTL_Campaign_Member_History__c = camh.id;
                cmhd.RTL_Field_Name__c =  fieldName;
                newvalue = String.valueof(camMem.get(fieldName));

                if(fieldName == 'RTL_Assigned_Agent__c' || fieldName == 'RTL_Contact_Staff_Name__c' || fieldName == 'RTL_Assigned_Branch__c' ){ 
                    cmhd.RTL_Field_Old_Value__c = oldvalue;
                    cmhd.RTL_Field_New_Value__c = retrieveValueTranformation(newvalue);
                }
                else{
                    
                    cmhd.RTL_Field_Old_Value__c = oldvalue;
                    cmhd.RTL_Field_New_Value__c = newvalue;
                }

                insertHistoryDetailList.add(cmhd);
            }
        }
        insert insertHistoryDetailList;
    }

    private Boolean validateLead(Lead leadObj, Lead oldLeadObj){ 
        Boolean returnChk = true;
        if (oldLeadObj.Status != 'Qualified'){//check if the lead status was Qualified
            returnChk = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.LeadError_QualifiedBeforeConversion ));
            //Lead Conversion failed. Lead must be qualified before being converted          
        }else {
            Boolean chkPrimary = false;
            List<RTL_Interested_products_c__c> interestProduct = [SELECT Id,Product_Name__c,Is_Primary__c FROM RTL_Interested_products_c__c 
                          WHERE Lead__c = :leadObj.Id order by Is_Primary__c desc];    
            if( interestProduct.size() > 0 ){                  

                //Get product id for new opp
                Id productId = (Id) currentObject.get(createOppList.get(0).apiProductId);
                system.debug(interestProduct);

                //Check matching product on interested product lead
                for( RTL_Interested_products_c__c each : interestProduct ){

                    if( each.Is_Primary__c ){
                        chkPrimary = each.Is_Primary__c;
                    }
                    
                    if( !chkPrimary ){
                        if( productId!=null && each.Product_Name__c == productId){
                            each.Is_Primary__c = true;
                            chkPrimary = true;
                            system.debug(each);
                            break;
                        }
                    }
                }

                update interestProduct;

                //Not Matching in interested product lead
                if(!chkPrimary){
                    createInterestedProduct(leadObj);
                    system.debug('CPM : Create interested product when product not match.');
                }
                
            }else{
                createInterestedProduct(leadObj);
                system.debug('CPM : Create interested product when product not found.');
            }
        }
        return returnChk;
    }
    
    public void createInterestedProduct(Lead leadObj){
        if(createOppList.size() > 0){
            Id productId = (Id) currentObject.get(createOppList.get(0).apiProductId);
            system.debug('Product for new opp id : '+productid);
            if(productId != null){
                RTL_Interested_products_c__c interestedProduct = new RTL_Interested_products_c__c();
                interestedProduct.Is_Primary__c = true;
                interestedProduct.Lead__c = leadObj.Id;
                interestedProduct.Product_Name__c = productId;
                insert interestedProduct;
            }

        }
    }

    public static String retrieveValueTranformation(String IDvalue){
        String newtransfromvalue = '';
        if (IDvalue != null && IDvalue != '') {
            if(IDvalue.length() == 15 || IDvalue.length() == 18) {
            string keyprefix = IDvalue.substring(0, 3);
                if (prefixSobjectMap.containsKey(keyprefix)){
                    String prefixSobject = prefixSobjectMap.get(keyprefix);
                    if (prefixSobject == 'user'  && userNameMap.containskey(IDvalue)) {
                        newtransfromvalue = userNameMap.get(IDvalue);
                    }
                    else if (prefixSobject == 'branch_and_zone__c'  && branchNameMap.containskey(IDvalue)) {
                        newtransfromvalue = branchNameMap.get(IDvalue);
                    }
                    else if (prefixSobject == 'contact' && contactNameMap.containskey(IDvalue)) {
                        newtransfromvalue = contactNameMap.get(IDvalue);
                    }
                }
            } 
            else{
            newtransfromvalue = IDvalue;
            }
        }
        return newtransfromvalue;
    }

    public static void settingValueTranformation(String IdValue) {
        if (IdValue != null && IdValue != '') {
            if (IdValue.length() == 15 || IdValue.length() == 18) {
                string keyprefix = IdValue.substring(0, 3);
                if (prefixSobjectMap.containsKey(keyprefix)) {
                    String prefixSobject = prefixSobjectMap.get(keyprefix);

                    if (prefixSobject == 'user') {
                    userIDset.add(IdValue);
                    } else if (prefixSobject == 'branch_and_zone__c') {
                    branchIDset.add(IdValue);
                    } else if (prefixSobject == 'contact') {
                    contactIDset.add(IdValue);
                    }

                }
            }
        }
    }

    public Lead getLead(Id inputId){
        System.debug('get lead ' + inputId);
        return [SELECT Id, Name, FirstName, Salutation, LastName, RTL_Mobile_Number__c, RTL_ID_Type__c, RTL_Citizen_Id__c, Status
		, IsConverted, ConvertedAccountId, OwnerId
        FROM Lead WHERE Id = :inputId];
    }

    public List<CampaignMember> getCampaignMember(Id inputId){
        return (List<CampaignMember>)queryCampaignMember(inputId);
    }

    public List<SObject> queryCampaignMember(Id inputId){
        try{            
            String objectName = 'CampaignMember';
            // select other field
            String strQuery = 'select RTL_Contact_Staff_Name__r.Name,Contact.Name,Campaign.Name,Lead.Name,Contact.AccountId,Campaign.RTL_Campaign_Code_10_digits__c,Contact.TMB_Customer_ID__c, ';
            strQuery += 'RTL_Campaign_Product_1__r.Name,RTL_Campaign_Product_2__r.Name,RTL_Campaign_Product_3__r.Name,RTL_Campaign_Product_4__r.Name,RTL_Campaign_Product_5__r.Name,Campaign.RTL_Campaign_Start_Date__c,Lead.IsConverted,Lead.ConvertedAccountId, Contact.account.name,RTL_Assigned_Agent__r.name,';
            //strQuery += 'customer__r.name + ';
            strQuery += queryAllField(objectName);
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where id = :inputId ';
            strQuery += ' from '+objectName;
            strQuery += strWhere;
            //System.debug('strQuery : '+strQuery);
            return Database.query(strQuery);
            
        }catch(QueryException e){
            return new List<SObject>();  
        }
    }

    public Static String queryAllField(String objName) {
        String strQuery = '';
        List<String> q = new List<String>();
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.DescribeSObjectResult r =  m.get(objName).getDescribe();
        List<String>apiNames =  new list<String>();
        for(string apiName : r.fields.getMap().keySet()){
            q.add(apiName);
        }
        for( String s : q ){
            strQuery += s+',';
        }
        return strQuery;
    }

	public boolean updateCampaignMember(){
        currentobject.No_of_Attempts__c = (currentobject.No_of_Attempts__c==null) ? 0 : currentobject.No_of_Attempts__c;
        currentobject.No_of_Attempts__c = ( currentobject.RTL_Contact_Status__c == 'Re-attempt' ) ? currentobject.No_of_Attempts__c+1 : currentobject.No_of_Attempts__c;

        String contactStatus = (currentobject.RTL_Contact_Status__c==null) ? '' : currentobject.RTL_Contact_Status__c;
        String contactStatusReason = (currentobject.RTL_Reason__c==null) ? '' : currentobject.RTL_Reason__c;
        
        currentobject.RTL_Last_Contact_Status__c = contactStatus+';'+contactStatusReason+';'+System.now().format();

        if(currentobject.RTL_Contact_Status__c != 'New' && currentobject.id != null){
            update currentobject;
            return true;
        }else{
            return false;
        }        
    }

	public Boolean CheckDupAccount(){
		try {
			Map<String,Account> accountSet = new Map<String,Account>();

			for(Account acct : [Select Id,ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c from Account where RTL_NID__c = :getNID(objLead.RTL_Citizen_Id__c)]){
				accountSet.put(acct.ID_Type_PE__c+acct.ID_Number_PE__c,acct);    
			}

			if(accountSet.containsKey(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c)){
				return false;
			}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		return true;
	}

    public Boolean CheckDupAccountMerge(){
        if(objLead.RTL_ID_Type__c == 'Other ID'){
            Boolean IDdup = false;
            Boolean Mobdup = false;
            for (Account acc : DupAccounts) {
               System.debug(acc);
                
                /*if(objLead.RTL_ID_Type__c == acc.ID_Type_PE__c && objLead.RTL_Citizen_Id__c == acc.ID_Number_PE__c && objLead.RTL_Mobile_Number__c == acc.Mobile_Number_PE__c){
                    return false;
                }*/
                
                if(objLead.RTL_ID_Type__c == acc.ID_Type_PE__c && objLead.RTL_Citizen_Id__c == acc.ID_Number_PE__c){
                    IDdup = true;
                }
                
                if(objLead.RTL_Mobile_Number__c == acc.Mobile_Number_PE__c){
                    Mobdup = true;
                }                
            }
            if(IDdup && Mobdup){
                return false;
            }
            return true;
        }else{
            return true;
        }
	}

    private void updateProductOfferString(CampaignMember camMem,String storeData){
        if(storeData!=null){
            camMem.RTL_Products_Offer_String__c = storeData;
            update camMem;
        }
    }

    public String getNID (String idNumber) {
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }

    public List<RTL_NBO_Product_Record_Type_Mapping__mdt> getConfRecordType(){
        return [select Id,DeveloperName,Default_Stage__c,RTL_Product_Group__c,RTL_Record_Type_DevName__c from RTL_NBO_Product_Record_Type_Mapping__mdt];
    }

    public List<RecordType> getRecordTypeOpportunity(){
        return [select Id,DeveloperName,Name from RecordType where SObjectType = 'Opportunity'];
    }

    //***************** PAGE CONTROLLER FUNCTION ***************** 

    private void showErrMsgPage(){
        showErrorMessagePage = true;
        CreateOpptyDone = false;
        showSelectAccountPage = false;
    }

    private void showCreateOptyDone(){
        showErrorMessagePage = false;
        CreateOpptyDone = true;
        showSelectAccountPage = false;
    }

    private void showSelectAcc(){
        showErrorMessagePage = false;
        CreateOpptyDone = false;
        showSelectAccountPage = true;
    }

    //*****BACK TO CAMPAIGN MEMBER CREATE OPPOTUNITY PAGE******
	public PageReference backPageCreateOpportunity(){
        return Page.RTL_CampaignMemberCreateOpportunity;
    }

    //*****BACK TO SELECT ACCOUNT PAGE******
	public void backPageSelectAccount(){
        accId = null;
        showSelectAcc();
    }


}