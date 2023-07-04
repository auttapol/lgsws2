public without sharing class RTL_CampaignMemberExtension {
    public String primaryTab {get;set;}
    public void setTabId() {
        // this.primaryTab = tabId;
        System.debug(this.primaryTab);
    }
    // static final String INT06_SERVICE_NAME = 'RetriveCampaignMember';
    // static final String SF_ERROR_CODE = 'Salesforce Error';
    public CampaignMember currentObject {get;set;}

    public Campaign campaignData{get;set;}
    public Account accountData{get;set;}
    public Contact contactData{get;set;}
    public User userOutbound{get;set;}
    public String campaignChannelFormula{get;set;}
    private String tmbCustId;
    private String markettingCode;

    List<string> conditions = new List<string>();
    //Telephony Outbound
    public Account existingCustomer {get;set;}

    //------------------------ RQ013 ------------------------

    public class lookupWrapper {
        public String Name{get;set;}
        public String Id{get;set;}
        public Map<String, String> extraValue{get;set;}
        public String extraValueStr{get;set;}
    }

    public String searchField {get; set;}
    public String query {get; set;}
    public List<lookupWrapper> sObj {get; set;}
    public Integer sObjSize {get; set;}
    public Boolean doneLookup {get; set;}    
    public String ObjectName {get; set;}   
    public String nameField {get; set;}   
    public String searchCondition {get; set;}   
    public String extraField {get; set;}  
    public List<String> extraFields {get; set;}  
    public Map<String, String> showFields {get; set;}   
    public String objectLabel {get; set;} 
    public String errorMsg {get; set;}
    //------------------------LGSWS2-------------------------
    public String selectedOption { get; set; }
    public String selectedValue { get; set; }
    public String leadListmin { get; set; }
    public List<SelectOption> options { get; set; }
    public Map<String, String> leadMin {get; set;}   
    public Map<String,String> myMap { get; set; }
    //------------------------ RQ013 ------------------------

    public Lead objLead {get;set;}
    public String contactName {get;set;}
    public Id contactid {get;set;}
    public String contactStatus {get;set;}
    public String lastContactStatus {get;set;}
    private String LABEL_INTEREST = 'Interested';
    private String LABEL_NOT_INTEREST = 'Not Interested';
    private String LABEL_CONTACT = 'Contact';
    private String LABEL_CONTACT_W_C = 'Contact (Walk-in/Call-in)';
    private Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt> mapConfRecordType = new Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt>();
    private Map<String,RecordType> mapRecordType = new Map<String,RecordType>();
    private User usInfo = [ select Id,Name,RTL_Channel__c,Region__c,Zone__c,RTL_Branch__c 
                            from User 
                            where Id = :UserInfo.getUserId() limit 1 ];
    public List<CampaignProductInterestedWrapper> createOppList {
        get
        {
            if(createOppList == null){
                createOppList = new List<CampaignProductInterestedWrapper>();
            }
            return createOppList;
            
        }set;
    }
    public List<Campaign> activeCampaignList {
        get
        {
            if(activeCampaignList == null){
                activeCampaignList = new List<Campaign>();
            }
            return activeCampaignList;
            
        }set;
    }
    List<Opportunity> oppList = new List<Opportunity>();    
    ApexPages.standardController m_sc = null;

    public List<FulfillmentWrapper> fulfillmentList {
        get
        {
            if(fulfillmentList == null){
                fulfillmentList = new List<FulfillmentWrapper>();
            }
            return fulfillmentList;
            
        }set;
    }
    public static List<Lead_Score_Level__c> leadScore {
        get
        {
            if(leadScore == null){
                leadScore = new List<Lead_Score_Level__c>();
                leadScore = [SELECT Name, Score_Min__c FROM Lead_Score_Level__c order by Score_Min__c asc];
            }
            return leadScore;
            
        }set;
    }
    public static User currentUser{
    get{
        if(currentUser ==null){
            currentUser = [SELECT Id,Name,Employee_ID__c ,Segment__c ,Reporting_Segment__c ,
                                    Region__c ,Region_Code__c ,Zone__c ,Zone_Code__c ,RTL_Branch_Code__c ,
                                    RTL_Branch__c ,RTL_Channel__c,UserRole.Name,Profile.Name
                            FROM User
                           WHERE Id =: System.UserInfo.getUserId()];
        }
        return currentUser;
        
    }set;} 
    

    public Integer fulfillmentPage {get;set;}
    public Boolean disablePreviousfulfillment {get;set;}
    public Boolean disableNextfulfillment {get;set;}
    public List<Integer> fulfillmentPageList {get;set;}
    public List<Integer> listItem {get;set;}

    public void pagination(List<Integer> totalPageList,Integer clickPage){
        Boolean checkDot = true;
        Set<String> duplicate = new Set<String>();
        listItem = new List<Integer>();
        for(Integer numberItem : totalPageList){
            Integer value = Math.abs(clickPage-numberItem);
            if(totalPageList.size()<10){
                listItem.add(numberItem);
            }
            else{
                if(numberItem<4 || numberItem>totalPageList.size()-3){
                    listItem.add(numberItem);
                    checkDot=true;
                }
                else{
                    if(value<3){
                        if(duplicate.add(String.valueOf(numberItem))==true){
                            listItem.add(numberItem);
                            checkDot=true;
                        }
                    }
                    else{
                        if(checkDot){
                            listItem.add(-1);
                            checkDot=false;
                        }
                    }
                }
            }
        }
    }

    private Integer fulfillmentItemPerPage {
        get{
            if( fulfillmentItemPerPage == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,FulfillmentDisplay__c
                from RTL_Campaign_History_Setting__mdt 
                where DeveloperName = 'Campaign_Display_Setting'];

                fulfillmentItemPerPage = integer.valueOf(chMeta.FulfillmentDisplay__c);
            }
            return fulfillmentItemPerPage;
        }
        set;
    }

    private Boolean nextStepCreateOpp = false;
    public boolean isSaveSucess{get;set;}
    public boolean isContactStatusNew{get;set;}
    public boolean isRetailUser{get;set;}
    public boolean isCampaignActive{get;set;}
    private String saveErrorMessage = '';
    private String preloadErrorMessage = '';
    private String requestBody;

    private Integer calloutTimeoutSecond{
        get{
            if( calloutTimeoutSecond == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,CalloutTimeoutSecond__c
                from RTL_Campaign_History_Setting__mdt 
                where DeveloperName = 'Campaign_Display_Setting'];

                calloutTimeoutSecond = (Integer)chMeta.CalloutTimeoutSecond__c;
            }
            return calloutTimeoutSecond;
        }
        set;
    }

    private Datetime startCallINT06;
    private Datetime endCallINT06;

    public List<RTL_CampaignProductInterestedWrapper> CreateOpytyList {
        get
        {
            if(CreateOpytyList == null){
                CreateOpytyList = new List<RTL_CampaignProductInterestedWrapper>();
            }
            return CreateOpytyList;
            
        }set;
    }
    public List<String> ALPrdNameSet {
        get{
            if(ALPrdNameSet == null){
                ALPrdNameSet = new List<String>();
                List<AL_screen_Product_Name__mdt> prdHLCALlst = AL_screen_Product_Name__mdt.getAll().values();

                for (AL_screen_Product_Name__mdt prd : prdHLCALlst) {
                    ALPrdNameSet.add(prd.Product_Name__c);
                }
            }
            return ALPrdNameSet;
        }
        set;
    }
    public RTL_CampaignMemberExtension(ApexPages.StandardController stdController) {
        myMap = getLeadScoreData();
        // -- Custom Lookup --
        doneLookup = false;
        sObjSize = 0;
        showFields = new Map<String,String>();
        ObjectName = 'RTL_Product_Master__c';
        // ObjectName = Apexpages.currentPage().getParameters().get('ObjectName');
        // condition = Apexpages.currentPage().getParameters().get('condition') != null ? EncodingUtil.urlDecode(Apexpages.currentPage().getParameters().get('condition'), 'UTF-8') : '';
        // index = Apexpages.currentPage().getParameters().get('index');
        searchField = 'NAME FIELDS';
        searchCondition = '';
		System.debug('ObjectName:'+ObjectName);
        System.debug('errorMsg:'+errorMsg);
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{ObjectName}); 
        objectLabel = describeSobjectsResult[0].getLabelPlural();

        // System.debug('condition:'+condition);
        // List<Custom_Lookup_VF_Setting__mdt> lookupSetting = [SELECT label,ObjectName__c,FieldName__c,Condition__c FROM Custom_Lookup_VF_Setting__mdt WHERE ObjectName__c =: ObjectName LIMIT 1];
        // System.debug('condition:'+lookupSetting);
        // if(lookupSetting.size() > 0)
        // {
        //     nameField = lookupSetting[0].FieldName__c != null ? lookupSetting[0].FieldName__c : '';
        //     extraField = lookupSetting[0].FieldName__c != null ? lookupSetting[0].FieldName__c : '';
        //     if(condition == null && condition == '' )
        //     {
        //         condition = lookupSetting[0].Condition__c;
        //     }          
        // }
        // if(Apexpages.currentPage().getParameters().get('searchValue') != null)
        // {
        //     query = Apexpages.currentPage().getParameters().get('searchValue');          
        // }
        // if(query != null && query != '')
        // {
        //     runQuery();
        // }
        // else {
        //     doneLookup = true;
        // }

        // -- Custom Lookup --
        m_sc = stdController;
        objLead = new Lead();
        currentObject = (CampaignMember)stdController.getRecord();
        isRetailUser = false;
        isCampaignActive = false;
        fulfillmentPage = 1;
        
        markettingCode = apexpages.currentpage().getparameters().get('mcode');
        tmbCustId = apexpages.currentpage().getparameters().get('tmbid');
		
         system.debug('currentObject ::'+currentObject);
         
        if( currentObject.Id != null ){

            //Get Campaign Member on Salesforce by campaignmember id
            currentObject = getCampaignMember(currentObject.Id).get(0);
            campaignData = currentObject.campaign;
            contactData = currentObject.contact;
            campaignChannelFormula = currentObject.RTL_Campaign_Channel_formula__c;

            //Get last contact status with TH language
            currentObject = getCampaignMember(currentObject.Id).get(0);
            lastContactStatus = RTL_Utility.transLastContactStatus(currentObject.RTL_Last_Contact_Status__c);//last contact status on edit campaign member page
            system.debug('member : '+currentObject);
            checkCampaignStatus();
            checkCampaignChannel();
            leadScoreLevelList();

            if (currentObject.RTL_Promotion__c != null) {
                //System.debug('currentObject.RTL_Promotion__c-->' +  currentObject.RTL_Promotion__c.indexOf('^'));
            	currentObject.RTL_Promotion__c = currentObject.RTL_Promotion__c.replace('^', '<br>');
            }
            // if(!String.isEmpty(currentObject.RTL_Campaign_Product_1__c)){ 
                // conditions.add('RTL_Campaign_Product_1__c =\'' +currentObject.RTL_Campaign_Product_1__c +'\' ');
                conditions.add('RTL_Campaign_Product_1__c =\'CYC\' ');
                system.debug('Product Name' + currentObject.RTL_Campaign_Product_1__c);
            // }           

        }else{

            //New instance when campaignmember id not found 
            currentObject = new CampaignMember();
            currentObject.RTL_Marketing_Code__c  = markettingCode;

            try{
                accountData = [SELECT id,name,TMB_Customer_ID_PE__c FROM ACCOUNT WHERE TMB_Customer_ID_PE__c =:tmbCustId ];    
            }
            catch (exception e)
            {
                // exception not found account
                system.debug(e.getMessage());
            }

            try{
                contactData = [SELECT id,name,TMB_Customer_ID__c,account.name,AccountId 
                               FROM CONTACT 
                               WHERE TMB_Customer_ID__c =:tmbCustId ];    

                currentObject.ContactId = contactData.id;
                currentObject.Contact = contactData;
            }
            catch (exception e)
            {
                // exception not found account
                system.debug(e.getMessage());
            }

            // If no marketting code, ignore campaign member id check
            if( markettingCode == '' || markettingCode == null )
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003)); 
            }

            // Ignore check for active campaign *** Temp ***
            // isCampaignActive = true;
            
        }

        //get lead when campaign member type lead and is not convert
        if( contactData == null && currentObject.LeadId != null && !objLead.IsConverted){
            objLead = getLead(currentObject.LeadId);
        }    
        
        //Mapping Product group with record type
        for(RTL_NBO_Product_Record_Type_Mapping__mdt each : getConfRecordType() ){
            string productgroup = each.RTL_Product_Group__c;
            productgroup = productgroup.touppercase();
            mapConfRecordType.put(productgroup,each);
        }


        //Get Opportunity record type
        for(RecordType each : getRecordTypeOpportunity() ){
            mapRecordType.put(each.DeveloperName,each);
        }

        //Check User is retail user for show edit button
        if(currentUser.Profile.Name.containsIgnoreCase('Retail') || currentUser.Profile.Name.containsIgnoreCase('System')){
            isRetailUser = true;
        }

        //Get Fulfillment Data
        if( contactData != null && contactData.TMB_Customer_ID__c != null && currentObject.Campaign.RTL_Campaign_Code_10_digits__c != null){
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,currentObject.Campaign.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }else{
            currentObject.Fulfillment_Status__c = 'N/A';
        }
        
    }

    //public PageReference apexSave(){
    public Object apexSave(){

        saveErrorMessage = '';
        Boolean isInterestOrNotInterest = false;

        if( currentObject.RTL_Contact_Status__c == '' || currentObject.RTL_Contact_Status__c == 'New' )
        {
            saveErrorMessage = Label.RTL_CampaignMemberEdit_ContactStatus_ErrMsg;
            isSaveSucess = false;
            return null;
        }
        
        for( Integer i = 1 ; i <= 5 ; i++ ){

            // Check to ignore already converted product
            if( currentObject.get('RTL_RelatedOpportunity_'+i+'__c') != null )
            {
                continue;
            }
            // ignore none group even offer result have value
            if( currentObject.get('RTL_Product_Group_'+i+'__c') == null || currentObject.get('RTL_Product_Group_'+i+'__c') == '' )
            {
                 continue;
            }

            // Check if offer result is interested and not create opportunity yet
            if( currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_NOT_INTEREST 
                &&  ( currentObject.get('RTL_Reason_'+i+'__c') == null || currentObject.get('RTL_Reason_'+i+'__c') == '' ) ){
                
                    List<String> fillers = new String[]{ String.valueOf(i) };
                    saveErrorMessage =  String.format( Label.RTL_CampaignMemberEdit_OfferStatus_ErrMsg , fillers );
                    isSaveSucess = false;
                    return null;
            }
        }

        for( Integer i = 1 ; i <= 5 ; i++ ){

            // Check to ignore already converted product
            if( currentObject.get('RTL_RelatedOpportunity_'+i+'__c') != null )
            {
                continue;
            }
            // ignore none group even offer result have value
            if( currentObject.get('RTL_Product_Group_'+i+'__c') == null || currentObject.get('RTL_Product_Group_'+i+'__c') == '' )
            {
                 continue;
            }

            // Check if offer result is interested and not create opportunity yet
            if( currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_INTEREST 
                &&  ( currentObject.get('RTL_Reason_'+i+'__c') != null && currentObject.get('RTL_Reason_'+i+'__c') != '' ) ){
                
                    List<String> fillers = new String[]{ String.valueOf(i) };
                    saveErrorMessage =  String.format( Label.RTL_CampaignMemberEdit_OfferStatus_Interested_ErrMsg , fillers );
                    isSaveSucess = false;
                    return null;
            }
        }

        for( Integer i = 1 ; i <= 5 ; i++ ){

            // ignore none group even offer result have value
            if( currentObject.get('RTL_Product_Group_'+i+'__c') == null || currentObject.get('RTL_Product_Group_'+i+'__c') == '' )
            {
                 continue;
            }

            if( currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_INTEREST 
            || currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_NOT_INTEREST  ){
                isInterestOrNotInterest = true;
            }
        }

        if(isInterestOrNotInterest)
        {
            if( currentObject.RTL_Contact_Status__c != LABEL_CONTACT 
            && currentObject.RTL_Contact_Status__c != LABEL_CONTACT_W_C )
            {
                saveErrorMessage = Label.RTL_CampaignMemberEdit_ContactStatusAndOfferResult_ErrMsg;
                isSaveSucess = false;
                return null;
            }
        }


        // Set Lead Ownder
        setLeadOwner();

        Savepoint sp = Database.setSavepoint();       

        //set contact result information 
        currentobject.RTL_Contact_Staff_Name__r = (currentobject.RTL_Contact_Staff_Name__r==null) ? null : usInfo;
        currentobject.RTL_Contact_Staff_Name__c = usInfo.Id;
        currentobject.RTL_Contact_Region_Group_Head__c = usInfo.Region__c;
        currentobject.RTL_Contact_Zone_Group__c = usInfo.Zone__c;
        currentobject.RTL_Contact_Branch_Team_Name_Code__c = usInfo.RTL_Branch__c;
        currentobject.RTL_Contact_Channel__c = usInfo.RTL_Channel__c;
        currentobject.RTL_Contact_Date_Time__c = System.now();
        currentobject.RTL_Contact_Date__c = System.today();

        //check contact status before update campaign member
        isContactStatusNew = false;

        if(currentobject.RTL_Contact_Status__c == 'New'){
            isContactStatusNew = true;
        }
        
        nextStepCreateOpp = false;
        for( Integer i = 1 ; i <= 5 ; i++ ){

            // ignore none group even offer result have value
            if( currentObject.get('RTL_Product_Group_'+i+'__c') == null || currentObject.get('RTL_Product_Group_'+i+'__c') == '' )
            {
                 continue;
            }
            // Check if offer result is interested and not create opportunity yet
            if( currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_INTEREST 
                &&  currentObject.get('RTL_RelatedOpportunity_'+i+'__c') == null ){
                nextStepCreateOpp = true;
                break;
            }
        }

        if( nextStepCreateOpp ){
            isSaveSucess = false;
            return null;
        }

        // system.debug('Campaign member : '+currentObject);

        try{
            String store;
            boolean updateCampaignmember = updateCampaignMember();
            if(!updateCampaignmember){
                store = currentObject.RTL_Products_Offer_String__c;
                currentObject.RTL_Products_Offer_String__c = null;
                insert currentObject;
                updateProductOfferString(currentObject,store);
                saveLogCampaignmember(currentObject);
            }
                    
            // Check to ignore update lead when  Campaign member already converted
            if( currentObject.ContactId==null && currentObject.LeadId != null && !objLead.IsConverted ){
                if( currentobject.RTL_Contact_Status__c == 'Contact' ){
                    objLead.Status = 'Contacted';
                }
                update objLead;
            }

            isSaveSucess = true;
            return null;
            
            
        }catch( DMLEXception e ){
            Database.rollback(sp);

            Integer numErrors = e.getNumDml();

            for(Integer i=0;i<numErrors;i++) {
                saveErrorMessage += e.getDmlMessage(i); 
            }

            system.debug('CPM : Update - '+saveErrorMessage+e.getMessage() +' ['+e.getLineNumber()+']'+e.getStackTraceString());
            isSaveSucess = false;
            return null;
            
        }       

    }

    ////set value
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
    //store data for change value in productofferstring to null before insert
    //public void storeData(CampaignMember productoffer){
    //    String store = productoffer.RTL_Products_Offer_String__c;
    //    system.debug('xxxstore: '+store);
    //    productoffer.RTL_Products_Offer_String__c = null;
    //    system.debug('xxx productoffer.RTL_Products_Offer_String__c: '+ productoffer.RTL_Products_Offer_String__c);
    //}
    //Update product offer string later , after insert to avoid trigger
    private void updateProductOfferString(CampaignMember camMem,String storeData){
        if(storeData!=null){
            camMem.RTL_Products_Offer_String__c = storeData;
            update camMem;
        }
    }
    //save log to RTL_Campaign_Member_History__c.
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
    //setting value
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
    // PageReference method to perform redirection base on save logic
    public PageReference redirectAfterSave(){
        if( isSaveSucess )
        {
            currentObject = getCampaignMember(currentObject.Id).get(0);  
            lastContactStatus = RTL_Utility.transLastContactStatus(currentObject.RTL_Last_Contact_Status__c);

            return Page.RTL_ViewCampaignMember;
        }
        else 
        {
            if( nextStepCreateOpp )
            {

                nextStepCreateOpp = false;
                return nextPageCreateOpportunity();
            }

            addErrorMessage();

            return null;    
        }
    }

    private void addErrorMessage()
    {
        if( saveErrorMessage != '' )
        {
            system.debug('CRM : saveErrorMessage - '+ saveErrorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002));    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, saveErrorMessage));         
        }

        if( preloadErrorMessage != '' )
        {
            system.debug('CRM : saveErrorMessage - '+ preloadErrorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, preloadErrorMessage));        
        }
    }


    public PageReference apexCreateOpportunity(){
        Savepoint sp = Database.setSavepoint();
        oppList = new List<Opportunity>();
        Id accId = currentObject.Contact.AccountId;
        Id conId;
        Boolean chkDup = true;
        Map<String,Account> accountSet = new Map<String,Account>();
        
        
        //TAY CODE HERE 4/5/2018 -------START-------
        if(currentObject.ContactId==null && objLead.Id != null && !objLead.IsConverted){
            chkDup = false;
            try {
                //Outbound Existing Customer
                if(currentObject.Customer__c == null)
                {
                    for(Account acct : [Select Id,ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c from Account where RTL_NID__c = :getNID(objLead.RTL_Citizen_Id__c)]){
                        accountSet.put(acct.ID_Type_PE__c+acct.ID_Number_PE__c,acct);    
                    }

                    List<List<sObject>> searchList = [FIND :objLead.RTL_Mobile_Number__c IN ALL FIELDS RETURNING Account(Id, name, TMB_Customer_ID_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name)];
                    List<Account> acctsMobile = (List<Account>)searchList[0];

                    if(objLead.RTL_ID_Type__c == 'Other ID' && (accountSet.containsKey(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c) || acctsMobile.size() > 0)){
                        chkDup = true;
                    }else if(objLead.RTL_ID_Type__c != 'Other ID' && (accountSet.containsKey(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c))){
                        chkDup = true;
                    }

                    if(chkDup){
                        PageReference pg = Page.RTL_DuplicateAccountCampaignMember;

                        for (CampaignProductInterestedWrapper each : createOppList) {
                            System.debug(each);
                            CreateOpytyList.add(new RTL_CampaignProductInterestedWrapper(each.numberOfProduct, each.rowNum, each.apiProductGroup, each.apiProductSubGroup, each.apiProductId, each.apiProductName, each.objOpp, each.viewSubGroup, each.viewProductName));
                            // System.debug(each.numberOfProduct);
                        }

                        return pg;
                    }
                }
                chkDup = true;
                
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('CRM : '+e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
                return null;
            }
            chkDup = true;
        }
        //TAY CODE HERE 4/5/2018 -------STOP-------
         
        try{          
            updateCampaignMember();  
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage());
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002));            
            return null;
        }

        try{ 

            if( currentObject.ContactId==null && objLead.Id != null && !objLead.IsConverted ){

            // //Telephony Outbound Check for existing customer
            if(currentObject.Customer__c != null)
            {
                existingCustomer = [SELECT Id, Name, Mobile_Number_PE__c, ID_Number_PE__c, ID_Type_PE__c FROM Account WHERE Id =: currentObject.Customer__c LIMIT 1];
                if(objLead.RTL_ID_Type__c == null)
                {
                    objLead.RTL_ID_Type__c = existingCustomer.ID_Type_PE__c;
                }
                if(objLead.RTL_Citizen_Id__c == null)
                {
                    objLead.RTL_Citizen_Id__c = existingCustomer.ID_Number_PE__c;
                }
                if(objLead.RTL_Mobile_Number__c == null)
                {
                    objLead.RTL_Mobile_Number__c = existingCustomer.Mobile_Number_PE__c;
                }
            }
                System.debug('Convert Lead Step : Lead => '+objLead.Id);
                // FOR SKIP CHECK UP CONVERT LEAD
                objLead.RTL_Allow_Convert_Lead__c = true;
                objLead.Status = 'Qualified';

                if( !validateLead(objLead,objLead) ){
                    Database.rollback(sp);
                    return null;
                }

                update objLead;

                // Outbound Existing Customer
                if(currentObject.Customer__c != null)
                {
                    chkDup = true;
                    
                    accId = existingCustomer.Id;
                    List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
                                                    FROM Contact WHERE AccountID =: accId
                                                    ];
                    for(contact existingCon : ExistingConList){
                        conId = existingCon.Id;
                        contactid = conId;//for redirect page                        
                    }
                }
                else
                {
                    // Map<String,Account> accountSet = new Map<String,Account>();
                    if(accountSet == null){
                        accountSet = new Map<String,Account>();
                        for(Account acct : [Select Id,ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c from Account where RTL_NID__c = :getNID(objLead.RTL_Citizen_Id__c)]){
                            accountSet.put(acct.ID_Type_PE__c+acct.ID_Number_PE__c,acct);    
                        }
                    }

                    if( accountSet.containsKey(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c) ){
                        chkDup = true;
                        accId = accountSet.get(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c).Id;

                        List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
                                                    FROM Contact WHERE AccountID =: accId
                                                    ];
                        for(contact existingCon : ExistingConList){
                            conId = existingCon.Id;
                            contactid = conId;//for redirect page                        
                        }

                    }  
                }                    
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(objLead.id);
                if( chkDup ){
                    lc.setAccountId(accId);
                    lc.setContactId(conId);
                }
                
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
            }                    
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
            return null;
        }

        // create opp line
        Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();

        if( createOppList.size() > 0 ){            
            for( CampaignProductInterestedWrapper each : createOppList ){
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
                // System.debug(currentObject.LeadSource);
                // System.debug(currentObject.RTL_TMB_Campaign_Source__c);
                // System.debug(currentObject.RTL_TMB_Campaign_Reference__c);
                if(currentObject.RTL_Marketing_Code__c != null)
                {
                    newOpp.Marketing_Code__c = currentObject.RTL_Marketing_Code__c;
                }
                if(currentObject.RTL_Web_Unique_ID__c != null)
                {
                    newOpp.RTL_Web_Unique_ID__c = currentObject.RTL_Web_Unique_ID__c;
                }
                
                /*
                    Project: AL Integration
                    Description: Mapping fields Auto loan create campaign member
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
                newOpp.LGS_Assignment_Code__c = currentObject.LGS_Assignment_Code__c;
                newOpp.LGS_LinkInfo__c = currentObject.LGS_LinkInfo__c;
                newOpp.LGS_BrandCode__c = currentObject.LGS_BrandCode__c;
                newOpp.LGS_BrandShowroomCode__c = currentObject.LGS_BrandShowroomCode__c;
                newOpp.LGS_PartnerCode__c = currentObject.LGS_PartnerCode__c;
                // newOpp.RTL_Campaign_Name__c = currentObject.RTL_W2L_Campaign_Name__c;
                newOpp.Lead_Score__c = currentObject.Lead_Score__c;
                newOpp.Lead_Score_level__c = currentObject.Lead_Score_level__c;
                newOpp.LGS_VIN_No__c = currentObject.LGS_VIN_No__c;
                newOpp.LGS_File_Upload__c = currentObject.LGS_File_Upload__c;
                newOpp.LGS_Campaign_Start_Date__c = currentObject.LGS_Campaign_Start_Date__c;
                newOpp.LGS_Campaign_End_Date__c = currentObject.LGS_Campaign_End_Date__c;
                newOpp.LGS_Child_Campaign_ID__c = currentObject.LGS_Child_Campaign_ID__c;
                newOpp.Car_Reference_No__c = currentObject.Car_Reference_No__c;
                newOpp.RTL_W2L_Campaign_Name__c = currentObject.RTL_W2L_Campaign_Name__c;

                Integer numberOfProduct =  each.numberOfProduct;
                productNoOpptyMap.put( numberOfProduct, newOpp );

            }
        }

        try{
            if( productNoOpptyMap.values().size() > 0 )
            {
                system.debug('productNoOpptyMap'+productNoOpptyMap);
                insert productNoOpptyMap.values();
                oppList = productNoOpptyMap.values();
            }
            
        }catch( DMLEXception e){
            Database.rollback(sp);
            System.debug('CPM : '+e.getMessage());
            System.debug('DML Message : '+e.getDmlMessage(0));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
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
                return null;
            }

        }
        System.debug('NUMBER SOQL 4  : ' + Limits.getQueries());
        return nextPageViewOpportunity();

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


    private void checkCampaignStatus()
    {
        if(currentObject.Campaign != null){
            activeCampaignList = getActiveCampaign(currentObject.campaignid);
            if(RTL_CampaignMemberUtil.checkActiveCampaign(activeCampaignList.get(0),currentObject)){
                isCampaignActive = true;
            }else{
                preloadErrorMessage = System.Label.RTL_CampaignMemberEdit_ERR003;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003));    
            }
        }else{
            preloadErrorMessage = System.Label.RTL_CampaignMemberEdit_ERR003;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003)); 
        }
    }

    private void setLeadOwner()
    {

        if( currentObject.contactid == null && currentObject.LeadId != null && !objLead.IsConverted )
        {
            //Check if Owner is not User
            List<User> userOwner = [SELECT id FROM User WHERE id=:objLead.OwnerId];

            if( userOwner.size() == 0 )
            {
                //Set Lead Owner to  Current User
                objLead.OwnerId = UserInfo.getUserId();
            }
        }
    } 

    private Boolean validateLead(Lead leadObj, Lead oldLeadObj){ 
        Boolean returnChk = true;
        if (oldLeadObj.Status != 'Qualified'){//check if the lead status was Qualified
            returnChk = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.LeadError_QualifiedBeforeConversion ));            
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

    public String getNID (String idNumber) {
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }

    public PageReference backPageEditCampaignMember(){
        // reset value
        for( CampaignProductInterestedWrapper each : createOppList ){
            if( !each.viewSubGroup ){
                currentobject.put(each.apiProductSubGroup,null);
            }
            if( !each.viewProductName ){
                currentobject.put(each.apiProductId,null);
            }
        }
        return Page.RTL_CampaignMemberEdit;
    }

    public PageReference nextPageCreateOpportunity(){
        // get new value
        createOppList = getCampaignProductInterested();
        return Page.RTL_CampaignMemberCreateOpportunity;
    }

    public PageReference nextPageViewOpportunity(){
        return Page.RTL_CampaignMemberViewOpportunity;
    }

    public void defaultContactStatus(){
        if(currentobject.RTL_Contact_Status__c==null){
            currentobject.RTL_Contact_Status__c = 'New';
        }
    }

    public PageReference editCampaignMemberButton(){
        
        if(isCampaignActive){
            PageReference returnPage = Page.RTL_CampaignMemberEdit;
            
            if( currentObject.Id != null )
            {
                //put campaignmember id to edit page
                returnPage.getParameters().put('id',currentObject.Id);
            }
            else
            {
                //put marketing code and tmb cust id to edit page
                returnPage.getParameters().put('mcode',currentObject.RTL_Marketing_Code__c);
                returnPage.getParameters().put('tmbid',tmbCustId);
            }

            returnPage.setRedirect(true);
            return returnPage;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003)); 
            return Page.RTL_ViewCampaignMember;
        }
    }

    public PageReference close(){

        PageReference returnPage = Page.RTL_ViewCampaignMember;
        
         try{
             if(currentObject.id!=null){
                 CampaignMember cm = [Select id from Campaignmember where contactid =:contactid
                                     and contactid!= null and campaignid =:currentObject.campaignid limit 1];
                 system.debug('merge campaign member : '+cm);
                 if(cm!=null){
                     currentObject = getCampaignMember(cm.Id).get(0);
                 }else{
                     currentObject = getCampaignMember(currentObject.Id).get(0);
                 }               
             }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMemberEdit_ERR003)); 
             }
         }catch(Exception e){
             returnPage = new PageReference('/'+currentObject.Id);  
         }

             if( currentObject.Id != null )
             {
                 returnPage.getParameters().put('id',currentObject.Id);
             }
             else
             {
                  returnPage.getParameters().put('mcode',markettingCode);
                  returnPage.getParameters().put('tmbid',tmbCustId);
             }

             returnPage.setRedirect(true);
         return returnPage;
    }
    
    public PageReference closeWithSalesApp(){
        PageReference returnPage = Page.RTL_ViewCampaignMember;
        saveErrorMessage = System.Label.RTL_CampaignMemberEdit_ERR004;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.RTL_CampaignMemberEdit_ERR004)); 
        return returnPage;
    }

    public PageReference canceltoview(){
       PageReference returnPage = Page.RTL_ViewCampaignMember;
       //currentObject = getCampaignMember(currentObject.Id).get(0);
       system.debug('When cencel on edit page : '+ currentObject);
       if( currentObject.Id != null )
       {
            returnPage.getParameters().put('id',currentObject.Id);
       }
       else
       {
            returnPage.getParameters().put('mcode',currentObject.RTL_Marketing_Code__c);
            returnPage.getParameters().put('tmbid',tmbCustId);
       }

       returnPage.setRedirect(true);
       return returnPage;
    }
    
    public List<CampaignProductWrapper> getCampaignProduct(){
        List<CampaignProductWrapper> returnList = new List<CampaignProductWrapper>();
        Integer count = 1;
        for( Integer i = 1 ; i <= 5 ; i++ ){
            Boolean readOnly = (currentObject.get('RTL_RelatedOpportunity_'+i+'__c') == null) ? false : true;
            if( currentObject.get('RTL_Product_Group_'+i+'__c') != null
            || currentObject.get('RTL_Sub_Group_'+i+'__c') != null
            || currentObject.get('RTL_Campaign_Product_'+i+'__c') != null ){
                returnList.add( new CampaignProductWrapper(count++,
                'RTL_Product_Group_'+i+'__c',
                'RTL_Sub_Group_'+i+'__c',
                'RTL_Campaign_Product_'+i+'__c',
                'RTL_Campaign_Product_'+i+'__r.Name',
                'RTL_OfferResult_Product_'+i+'__c',
                'RTL_Reason_'+i+'__c',
                'RTL_RelatedOpportunity_'+i+'__c',
                readOnly
                ) );
            }
        }
        return returnList;
    }

    public List<CampaignProductInterestedWrapper> getCampaignProductInterested(){
        List<CampaignProductInterestedWrapper> returnList = new List<CampaignProductInterestedWrapper>();
        Integer count = 1;
        for( Integer i = 1 ; i <= 5 ; i++ ){
            Boolean viewSubGroup = (currentObject.get('RTL_Sub_Group_'+i+'__c') == null) ? false : true;
            Boolean viewProductName = (currentObject.get('RTL_Campaign_Product_'+i+'__c') == null) ? false : true;
            system.debug('currentObject : '+ currentObject.Id);
            // Now get product to create opportunities only not converted product
            if( currentObject.get('RTL_OfferResult_Product_'+i+'__c') == LABEL_INTEREST
                &&  currentObject.get('RTL_RelatedOpportunity_'+i+'__c') == null 
                && currentObject.get('RTL_Product_Group_'+i+'__c')!=null){

                Opportunity objOpp = new Opportunity();
                String productGroup = String.valueOf(currentObject.get('RTL_Product_Group_'+i+'__c'));
                //--- RQ013 ---
                String productName;
                if(i == 1)
                {
                    productName = String.valueOf(currentObject.RTL_Campaign_Product_1__r.Name);

                }
                else if(i == 2)
                {
                    productName = String.valueOf(currentObject.RTL_Campaign_Product_2__r.Name);
                }
                else if(i == 3)
                {
                    productName = String.valueOf(currentObject.RTL_Campaign_Product_3__r.Name);
                }
                else if(i == 4)
                {
                    productName = String.valueOf(currentObject.RTL_Campaign_Product_4__r.Name);
                }
                else if(i == 5)
                {
                    productName = String.valueOf(currentObject.RTL_Campaign_Product_5__r.Name);
                }
                system.debug('productGroup'+productGroup);
                system.debug('mapConfRecordType'+mapConfRecordType);
                if( mapConfRecordType.containsKey( productGroup ) ){
                    String recordTypeByProductGroup = mapConfRecordType.get( productGroup ).RTL_Record_Type_DevName__c;
                    system.debug('objOpp'+objOpp);
                    objOpp.StageName = mapConfRecordType.get( productGroup ).Default_Stage__c;
                    objOpp.RTL_Status__c = 'Open';//Default Opp status
                    if( mapRecordType.containsKey( recordTypeByProductGroup ) ){
                        objOpp.RecordTypeId = mapRecordType.get( recordTypeByProductGroup ).Id;                                                     
                    }                    
                }
                
                CampaignProductInterestedWrapper intProduct = new CampaignProductInterestedWrapper(count++,
                    'RTL_Product_Group_'+i+'__c',
                    'RTL_Sub_Group_'+i+'__c',
                    'RTL_Campaign_Product_'+i+'__c',
                    'RTL_Campaign_Product_'+i+'__r.Name',
                    objOpp,
                    viewSubGroup,
                    viewProductName,
                    productName
                );

                intProduct.numberOfProduct = i;

                returnList.add( intProduct );                
            }
        }
        
        return returnList;
    }

    public void createInterestedProduct(Lead leadObj){

        if(createOppList.size() > 0){
            Id productId = (Id) currentObject.get(createOppList.get(0).apiProductId);
            system.debug('Product for new opp id : '+productid);
            if(productId != null){
                RTL_Interested_products_c__c interestedProduct = new RTL_Interested_products_c__c();
                interestedProduct.Is_Primary__c = true;
                interestedProduct.Lead__c = currentObject.LeadId;
                interestedProduct.Product_Name__c = productId;
                insert interestedProduct;
            }

        }
    }

    public List<Opportunity> getOpportunityList(){
        List<Opportunity> returnList = [select Id,Name,AccountId,Account.Name,RTL_Product_Name__r.Name,RTL_Product_Name__c,StageName,RTL_Status__c,Amount,CloseDate,Owner.Name
        from Opportunity where Id IN :oppList];
        if( returnList.size() > 0 ){
            contactName = returnList.get(0).Account.Name;
        }
        return returnList;
    }    

    public List<RTL_NBO_Product_Record_Type_Mapping__mdt> getConfRecordType(){
        return [select Id,DeveloperName,Default_Stage__c,RTL_Product_Group__c,RTL_Record_Type_DevName__c from RTL_NBO_Product_Record_Type_Mapping__mdt];
    }

    public List<RecordType> getRecordTypeOpportunity(){
        return [select Id,DeveloperName,Name from RecordType where SObjectType = 'Opportunity'];
    }
    public Lead getLead(Id inputId){
        return [select Id,Name,FirstName, Salutation,LastName,RTL_Mobile_Number__c,RTL_ID_Type__c,RTL_Citizen_Id__c,Status,
        IsConverted,ConvertedAccountId,OwnerId, RTL_W2L_Loan_Request_Type__c, RTL_W2L_Source_Collateral_Type__c
         from Lead where Id = :inputId];
    }

    public List<Campaign> getActiveCampaign(Id inputId){
        return [SELECT Id, Name, RecordTypeId, Status,Approvedflag__c ,RecordType.DeveloperName
                FROM Campaign 
                where Id = :inputId];
    }

    public List<CampaignMember> getCampaignMember(Id inputId){
        return (List<CampaignMember>)queryCampaignMember(inputId);
    }
    
    public List<SObject> queryCampaignMember(Id inputId){
        try{            
            String objectName = 'CampaignMember';
            // select other field
            String strQuery = 'select Customer__r.Name,RTL_Contact_Staff_Name__r.Name,Contact.Name,Campaign.Name,Lead.Name,Contact.AccountId,Campaign.RTL_Campaign_Code_10_digits__c,Contact.TMB_Customer_ID__c, ';
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

    //========================== Get Fulfillment ==============================//

    public List<RTL_Fulfillment__c> getFulfillment(String cusid,String campaigncode,integer pageNo){
        //integer pageNo=1;
        return (List<RTL_Fulfillment__c>)queryFulfillment(cusid,campaigncode,pageNo);
    }

    public List<SObject> queryFulfillment(String cusid,String campaigncode,Integer pageNo){
        try{ 

            Integer rowLimit =  fulfillmentItemPerPage;
            Integer rowOffset = (pageNo-1)*rowLimit;

            system.debug('cusid'+cusid+'campaigncode'+campaigncode);           
            String objectName = 'RTL_Fulfillment__c';
            // select other field
            String strQuery = 'select RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,RTL_Campaign__r.Name,RTL_Customer__r.Name,RTL_Customer__r.id, RTL_Campaign__r.id,';
            strQuery += queryAllField(objectName);
            strQuery = strQuery.substring(0,strQuery.length()-1);
            String strWhere = ' where ';
            // check TMB Customer ID and Campaign Code
            strWhere += 'RTL_Customer__r.TMB_Customer_ID_PE__c =: cusid and RTL_Campaign__r.RTL_Campaign_Code_10_digits__c =: campaigncode';
            strQuery += ' from '+objectName;
            strQuery += strWhere;
            strQuery += ' LIMIT :rowLimit OFFSET :rowOffset';
            system.debug(strQuery+' > limit row'+rowLimit+' ,offset '+rowOffset);
            

            String strQuery2 = 'select count() ';
            strQuery2 = strQuery2.substring(0,strQuery2.length()-1);
            String strWhere2 = ' where ';
            // check TMB Customer ID and Campaign Code
            strWhere2 += 'RTL_Customer__r.TMB_Customer_ID_PE__c =: cusid and RTL_Campaign__r.RTL_Campaign_Code_10_digits__c =: campaigncode';
            strQuery2 += ' from '+objectName;
            strQuery2 += strWhere2;

            system.debug(strQuery2+' > limit row'+rowLimit+' ,offset '+rowOffset);

            Integer countTotalRecords = Database.countQuery(strQuery2);

            disablePreviousfulfillment = false;
            disableNextfulfillment = false;
            if( pageNo == 1)
            {
                disablePreviousfulfillment = true;

            }

            if( pageNo*rowLimit >= countTotalRecords )
            {
                disableNextfulfillment = true;
            }


            fulfillmentPageList = new List<Integer>();
            Integer count = 1;
            fulfillmentPageList.add(count);
            while ( count*rowLimit < countTotalRecords ) {
                count++;
                fulfillmentPageList.add(count);
            }
            pagination(fulfillmentPageList,pageNo);

            return Database.query(strQuery);
            
        }catch(QueryException e){
            return new List<SObject>();  
        }
    }

    public List<FulfillmentWrapper> getFulfillmentList(String cusid,String campaigncode,integer pageNo){

        List<FulfillmentWrapper> returnList = new List<FulfillmentWrapper>();
        Integer count = 1;
        List<RTL_Fulfillment__c> fulfillmentlist = getFulfillment(cusid,campaigncode,pageNo);
        RTL_Fulfillment_Type_Mapping__mdt fulfillmentType = new RTL_Fulfillment_Type_Mapping__mdt();

        system.debug('CPM : fulfillmentlist - '+fulfillmentlist);   

        //Mapping Status code with desc       
        if(fulfillmentlist.size() > 0){
            for(RTL_Fulfillment__c f : fulfillmentlist){

                string statusCode;
                statusCode = RTL_CampaignMemberUtil.getFulfillmentCodeWithDesc(f.RTL_Fulfillment_Status__c,f.RTL_Fulfillment_Type__c);

                returnList.add(new FulfillmentWrapper(count,
                    f.RTL_Delivery_Date__c,
                    f.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,
                    f.RTL_Campaign__r.Name,
                    f.RTL_Fulfillment_Type__c,
                    f.RTL_Description__c,
                    f.RTL_Account_ID__c,
                    f.RTL_PCI_Card_NO__c,
                    f.RTL_Amount__c,
                    statusCode));

                count++;
            }

        }

        //get fulfillment status
        if(campaigncode!=null){
            currentObject.Fulfillment_Status__c = RTL_CampaignmemberUtil.getFulfillmentStatus(cusid,campaigncode);
        }

        return returnList;
    }

    public PageReference previousFulfillment()
    {
        fulfillmentPage--;
        if( contactData != null && contactData.TMB_Customer_ID__c != null && currentObject.Campaign.RTL_Campaign_Code_10_digits__c != null){
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,currentObject.Campaign.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }else{
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,campaignData.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }
        return null;
    }

    public PageReference nextFulfillment()
    {
        fulfillmentPage++;
        if( contactData != null && contactData.TMB_Customer_ID__c != null && currentObject.Campaign.RTL_Campaign_Code_10_digits__c != null){
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,currentObject.Campaign.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }else{
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,campaignData.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }

        system.debug('fulfillmentList'+fulfillmentList);
        system.debug('fulfillmentPage : '+fulfillmentPage);
        return null;
    }

    public PageReference navigateFulfillment()
    {
        if( contactData != null && contactData.TMB_Customer_ID__c != null && currentObject.Campaign.RTL_Campaign_Code_10_digits__c != null){
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,currentObject.Campaign.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }else{
            fulfillmentList = getFulfillmentList(contactData.TMB_Customer_ID__c,campaignData.RTL_Campaign_Code_10_digits__c,fulfillmentPage);
        }
        return null;
    }

    //========================== End Fulfillment ==============================//

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

    public class CampaignProductWrapper{
        public Integer rowNum {get;set;}
        public String apiProductGroup {get;set;}
        public String apiProductSubGroup {get;set;}
        public String apiProductId {get;set;}
        public String apiProductName {get;set;}
        public String apiOfferResult {get;set;}
        public String apiReason {get;set;}
        public String apiOpportunity {get;set;}
        public Boolean readOnly {get;set;}
        public CampaignProductWrapper(Integer rowNum,String apiProductGroup,String apiProductSubGroup,String apiProductId,String apiProductName,
            String apiOfferResult,String apiReason,String apiOpportunity,Boolean readOnly){
            this.rowNum = rowNum;
            this.apiProductGroup = apiProductGroup;
            this.apiProductSubGroup = apiProductSubGroup;
            this.apiProductId = apiProductId;
            this.apiProductName = apiProductName;
            this.apiOfferResult = apiOfferResult;
            this.apiReason = apiReason;
            this.apiOpportunity = apiOpportunity;
            // this.apiReason = apiReason;
            this.readOnly = readOnly;
        }
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
        public String productNameValue {get;set;}
        
        public CampaignProductInterestedWrapper(Integer rowNum,String apiProductGroup,String apiProductSubGroup,
            String apiProductId,String apiProductName,Opportunity objOpp,Boolean viewSubGroup,Boolean viewProductName, String productNameValue){
            this.rowNum = rowNum;
            this.apiProductGroup = apiProductGroup;
            this.apiProductSubGroup = apiProductSubGroup;
            this.apiProductId = apiProductId;
            this.apiProductName = apiProductName;
            this.objOpp = objOpp;
            this.viewSubGroup = viewSubGroup;
            this.viewProductName = viewProductName;
            this.productNameValue = productNameValue;
        }
    }

    public class FulfillmentWrapper{
        public Integer rowNum {get;set;}
        public Date apiProcessDate {get;set;}
        public String apiCampaignCode {get;set;}
        public String apiCampaignName {get;set;}
        public String apiFulfillmentType {get;set;}
        public String apiDescription {get;set;}
        public String apiAccountId {get;set;}
        public String apiCardNo {get;set;}
        public Decimal apiAmount {get;set;}
        public String apiStatus {get;set;}
        public FulfillmentWrapper(Integer rowNum,Date apiProcessDate,String apiCampaignCode,String apiCampaignName,String apiFulfillmentType,
            String apiDescription,String apiAccountId,String apiCardNo,Decimal apiAmount,String apiStatus){
            this.rowNum = rowNum;
            this.apiProcessDate = apiProcessDate;
            this.apiCampaignCode = apiCampaignCode;
            this.apiCampaignName = apiCampaignName;
            this.apiFulfillmentType = apiFulfillmentType;
            this.apiDescription = apiDescription;
            this.apiAccountId = apiAccountId;
            this.apiCardNo = apiCardNo;
            this.apiAmount = apiAmount;
            this.apiStatus = apiStatus;
        }
    }

     //========================== INT Section ==============================
    public Object requestCampaignData() 
    {
        
        //Check if Marketting code is null, skip request call
        if( currentObject.RTL_Marketing_Code__c == null || currentObject.RTL_Marketing_Code__c == '' )
        {
            // Add error message if existing from previous save 
            addErrorMessage();
            return null;
        }


        System.debug('==== start callout ============');
        startCallINT06 = system.now();

        // Create callout request
        HttpRequest req = new HttpRequest();

        try{

            Integer startPage =1;
            Integer endPage =  1;

            String startDate =  Datetime.now().addYears(-2).format('yyyy-MM-dd');
            String endDate = Datetime.now().format('yyyy-MM-dd');

            requestBody = '<CampaignMemberRequest>\n'+
                '<CampaignMember>\n'+
                    '<CustID>'+tmbCustId+'</CustID>\n'+
                    '<CampStartDate>'+ startDate +'</CampStartDate>\n'+
                    '<CampEndDate>'+ endDate +'</CampEndDate>\n'+
                    '<MarketingCode>'+currentObject.RTL_Marketing_Code__c+'</MarketingCode>\n'+
                    '<StartRow>'+startPage+'</StartRow>\n'+
                    '<EndRow>'+endPage+'</EndRow>\n'+
                '</CampaignMember>\n'+
            '</CampaignMemberRequest>';

            system.debug('requestINT06: ' + requestBody);

              req.setMethod('POST');
              //req.setHeader('Content-Type', 'application/json');
              req.setEndpoint(endpointInt06);
              req.setBody(requestBody);

            //============= test for connection ===================
            Http h = new Http();
            HttpRequest reqTest = new HttpRequest();
            reqTest.setEndpoint(endpointInt06);
            reqTest.setMethod('POST');
            HttpResponse resTest = h.send(reqTest);
            //============ throw error if endpoint not available ===========
        }
        catch(Exception e) {

            endCallINT06 = system.now();
            // exclusiveCalloutSuccess = false;

            String errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            String errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';

            String erStatus = '';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
            erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));

            Account accountObj = new Account();
            String rmId = currentObject.RTL_Marketing_Code__c;
            //   String customerName;
            if(currentObject.Contact.Account != null)
            {
                accountObj = currentObject.Contact.Account;
                //   customerName = accountObj.Name;
            }
            String resultBody = '';

            RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
                accountObj.id ,requestBody , resultBody  , startCallINT06 ,endCallINT06 );

            System.debug(e.getMessage());
            return null;
        } 

        Continuation con = new Continuation(calloutTimeoutSecond);
        con.continuationMethod='processResponse';
        this.requestLabel = con.addHttpRequest(req);
        return con;  
    }

    public Object processResponse() {   
        // Add error message if existing from previous save 
        addErrorMessage();

        endCallINT06 = system.now();

        system.debug('==== start process response ============');
        String resultBody = '';
        String errorCodeText = '';
        String errorDescText = '';

      Account accountObj = new Account();
      String rmId = currentObject.RTL_Marketing_Code__c;
    //   String customerName;
      if(currentObject.Contact.Account != null)
      {
          accountObj =  currentObject.Contact.Account;
        //   customerName = accountObj.Name;
      }

      try
      {
          
        // Get the response by using the unique label
        HttpResponse response = Continuation.getResponse(this.requestLabel);

        if( response == null ) 
        { 
            errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            errorDescText = RTL_CampaignUtil.INT06_NO_RESPONSE_ERROR;
            exclusiveCalloutSuccess = false;
            exclusiveCalloutError = errorCodeText;
            exclusiveCalloutErrorDesc = errorDescText;

            String erStatus = '';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
            erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));
        }
        else if( response.getStatusCode() != 200 )
        {
            errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            errorDescText = response.getStatus() + '(' + response.getStatusCode() + ')'; 
            exclusiveCalloutSuccess = false;
            exclusiveCalloutError = errorCodeText;
            exclusiveCalloutErrorDesc = errorDescText;

            String erStatus = '';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
            erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));
        }
        else
        {

            // Set the result variable that is displayed on the Visualforce page
            resultBody = response.getBody();

            system.debug( Logginglevel.ERROR, 'INT06:'+resultBody);

            Dom.Document doc = new Dom.Document();
            doc.load(resultBody);

            Dom.XMLNode root = doc.getRootElement();

            Dom.XMLNode header = root.getChildElement('Header', null);
            //Dom.XMLNode errorCode = header.getChildElement('ErrorCode', null);

            errorCodeText =  header.getChildElement('ErrorCode', null).getText();
            errorDescText =  header.getChildElement('ErrorDescription', null).getText();
            String errorStatusText =  header.getChildElement('ErrorStatus', null).getText();

            system.debug('errorStatusText : '+errorStatusText);
            
            if( errorStatusText == 'fail' ) 
            {
                    exclusiveCalloutSuccess = false;
                    exclusiveCalloutError = errorCodeText;
                    exclusiveCalloutErrorDesc = errorDescText;
                
                    String erStatus = '';
                    erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
                    erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
                    erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));
                    // RTL_CampaignUtil.insertOnlineLog( errorCodeText,errorDescText, rmId , 'INT06' , customerName );

            }
            else 
            {
                errorCodeText = '';
                errorDescText = '';
                exclusiveCalloutSuccess = true; 
                /*------------------------------Start edit 1 ------------------------------*/
                    Dom.XMLNode cmList = root.getChildElement('CampaignMemberList', null);
                    Dom.XMLNode cm = cmList.getChildElement('CampaignMember', null);
                    if( cm != null )
                    {
                
                        campaignMemberResponse = new CampaignMemberResponseObject();
                        campaignMemberResponse.campaigncode = cm.getChildElement('CampaignCode', null).getText().trim();
                        campaignMemberResponse.marketingcode = cm.getChildElement('MarketingCode', null).getText().trim();
                        campaignMemberResponse.productofferstring = cm.getChildElement('ProductOfferString', null).getText().trim();
                        campaignMemberResponse.campaignchannel = cm.getChildElement('CampaignChannel', null).getText().trim();
                        campaignMemberResponse.mobilenumber = cm.getChildElement('MobileNumber', null).getText().trim();
                        campaignMemberResponse.updatedate = cm.getChildElement('UpdateDate', null).getText().trim();
                        campaignMemberResponse.resultcontact = cm.getChildElement('ResultContact', null).getText().trim();
                        campaignMemberResponse.agentid = cm.getChildElement('AgentID', null).getText().trim();
                        campaignMemberResponse.resultdetail = cm.getChildElement('ResultDetail', null).getText().trim();
                        campaignMemberResponse.offerresult = cm.getChildElement('OfferResult', null).getText().trim();
                        // campaignMemberResponse.contactdate = cm.getChildElement('ContactDate', null).getText().trim();
                        campaignMemberResponse.reason = cm.getChildElement('Reason', null).getText().trim();
                        campaignMemberResponse.smsmessage = cm.getChildElement('SmsMessage', null).getText().trim();
                        campaignMemberResponse.smscontent = cm.getChildElement('SmsContent', null).getText().trim();
                        campaignMemberResponse.registerdateText = cm.getChildElement('RegisterDate', null).getText().trim();
                        campaignMemberResponse.displayflagText = cm.getChildElement('DisplayFlag', null).getText().trim();
                        campaignMemberResponse.displaydateText = cm.getChildElement('DisplayDate', null).getText().trim();
                        campaignMemberResponse.clickflagText = cm.getChildElement('ClickFlag', null).getText().trim();
                        campaignMemberResponse.clickdateText = cm.getChildElement('ClickDate', null).getText().trim();
                        campaignMemberResponse.emailsenddateText = cm.getChildElement('EmailSendDate', null).getText().trim();
                        campaignMemberResponse.emailrejectdateText = cm.getChildElement('EmailRejectDate', null).getText().trim();
                        campaignMemberResponse.emailopenflagText = cm.getChildElement('EmailOpenFlag', null).getText().trim();
                        campaignMemberResponse.emailopendateText = cm.getChildElement('EmailOpenDate', null).getText().trim();
                        campaignMemberResponse.emailclickflagText = cm.getChildElement('EmailClickFlag', null).getText().trim();
                        campaignMemberResponse.emailclickdateText = cm.getChildElement('EmailClickDate', null).getText().trim();
                        campaignMemberResponse.contactsubstatus= cm.getChildElement('ContactSubStatus', null).getText().trim();
                        campaignMemberResponse.offersubresult = cm.getChildElement('OfferSubResult', null).getText().trim();
                        
                        campaignMemberResponse.resultbusiness = cm.getChildElement('ResultBusiness', null).getText().trim();
                        campaignMemberResponse.contactdateText = cm.getChildElement('ContactDate', null).getText().trim();
                        campaignMemberResponse.personalizedMessage = cm.getChildElement('PersonalizedMessage', null).getText().trim();

                        userOutbound = new User();
                        try
                        {
                            if(campaignMemberResponse.agentid !=null && campaignMemberResponse.agentid !=''){
                                userOutbound = [SELECT id,name,RTL_Branch_Code__c,Zone_Code__c,Employee_ID__c
                                    FROM User WHERE Employee_ID__c = :campaignMemberResponse.agentid limit 1 ];
                            }

                        }catch (exception e)
                        {
                            system.debug(e);
                            //Exception if query no row
                        }

                        //CR PersonalizedMessage
                        if(campaignMemberResponse.personalizedMessage !=null){
                            currentObject.RTL_Personalized_Message__c = campaignMemberResponse.personalizedMessage;
                        }

                        if(currentObject.id == null)
                        {
                            currentObject.RTL_CampHis_Phone__c = campaignMemberResponse.mobilenumber;
                            currentObject.RTL_Marketing_Code__c = campaignMemberResponse.marketingcode;

                            campaignData = new Campaign(); 
                            try
                            {
                                campaignData = [SELECT id,name,RTL_Campaign_Code_10_digits__c,RTL_Campaign_Start_Date__c
                                        FROM Campaign WHERE RTL_Campaign_Code_10_digits__c = :campaignMemberResponse.campaigncode limit 1 ];
                            }
                            catch (exception e)
                            {
                                //Exception if query no row
                            }
                            currentObject.campaign = campaignData;
                            currentObject.campaignId = campaignData.id;

                            checkCampaignStatus();


                            //get fulfillment
                            string tmbcusid = '';
                            if( contactData != null )
                            {
                                tmbcusid = contactData.TMB_Customer_ID__c;
                            }
                            string campaigncode = campaignData.RTL_Campaign_Code_10_digits__c;
                            fulfillmentList = getFulfillmentList(tmbcusid,campaigncode,fulfillmentPage);
                            
                            


                            campaignChannelFormula =  campaignMemberResponse.campaignchannel;

                            checkCampaignChannel();
                            //cm_r.campaignchannel
                            Set<String> channelList = new  Set<String>();

                            for( String campaignChannel : campaignMemberResponse.campaignchannel.Split(',') )
                            {
                                channelList.add( campaignChannel.trim() );
                            }

                            Set<String> objectFields = Schema.SObjectType.CampaignMember.fields.getMap().keySet();
                            
                            if(channelList.size()>0){
                                for(RTL_CAMPAIGN_CHANNEL_INT06_MAP__mdt channelValue : [select Id,RTL_CHANNEL_FIELD_NAME__c,RTL_MDM_CAMPAIGN_CHANNEL_VALUE__c
                                                    FROM RTL_CAMPAIGN_CHANNEL_INT06_MAP__mdt
                                                    WHERE RTL_MDM_CAMPAIGN_CHANNEL_VALUE__c IN: channelList]){
                                    
                                    if(objectFields.contains(channelValue.RTL_CHANNEL_FIELD_NAME__c)) {
                                        currentObject.put(channelValue.RTL_CHANNEL_FIELD_NAME__c,true);
                                    }
                                    
                                }                              
                            }

                            String productOfferString = campaignMemberResponse.productofferstring;
                            if(productOfferString!=null){
                                currentObject.RTL_Products_Offer_String__c = productOfferString;
                            }

                            Set<String> retailProductsNameSet = new Set<String>();
                            Set<String> retailProductsSubGroupSet = new Set<String>();

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
                            }

                            Map<String,String> RetailProductSubGroupMap = new  Map<String,String>();

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

                            Map<String,RTL_product_master__c > RetailProductNameMap = new Map<String,RTL_product_master__c >();
                            Map<String,RTL_product_master__c > RetailProductIDMap = new Map<String,RTL_product_master__c >();
                            
                            if(retailProductsNameSet.size()>0){
                                for(RTL_product_master__c pm : [select Id,RTL_Product2_Name__c ,
                                    Product_Sub_group__c,Product_Group__c,Active__c,Name
                                    FROM RTL_product_master__c 
                                    WHERE Active__c = true 
                                    AND Name LIKE: retailProductsNameSet ]){
        
                                    
                                    RetailProductNameMap.put( pm.Name,pm);
                                    //Also add upper and lowwer case to get more possible map from product offer string in case name if not all upper
                                    // RetailProductNameMap.put( pm.Name.tolowercase(),pm);
                                    // RetailProductNameMap.put( pm.Name.touppercase() ,pm);
                                    RetailProductIDMap.put( pm.Id ,pm);
                                }
                            }

                            List<List<String>> productOfferResultList = RTL_UploadCampaignMemberCreateLead.generateProductOfferList(productOfferString,RetailProductNameMap,RetailProductSubGroupMap);
                
                            Integer i = 0;
                            for( List<String> offerResutl : productOfferResultList )
                            {
                                i++;
                                RTL_product_master__c prod = (RTL_product_master__c)RetailProductIDMap.get(offerResutl.get(2));

                                if( offerResutl.get(0) != '' )
                                {
                                    currentObject.put('RTL_Product_Group_'+i+'__c', offerResutl.get(0) );
                                }


                                if( offerResutl.get(1) != '' )
                                {
                                    currentObject.put('RTL_Sub_Group_'+i+'__c', offerResutl.get(1) );
                                }


                                if( offerResutl.get(2) != '' )
                                {
                                    currentObject.put('RTL_Campaign_Product_'+i+'__c', offerResutl.get(2) ); 
                                }

                                if( prod != null )
                                {

                                    if( i == 1 )
                                    {
                                        currentObject.RTL_Campaign_Product_1__r = prod;
                                    }
                                    else if (i == 2)
                                    {
                                        currentObject.RTL_Campaign_Product_2__r = prod;
                                    }
                                    else if (i == 3)
                                    {
                                        currentObject.RTL_Campaign_Product_3__r = prod;
                                    }
                                    else if (i == 4)
                                    {
                                        currentObject.RTL_Campaign_Product_4__r = prod;
                                    }
                                    else if (i == 5)
                                    {
                                        currentObject.RTL_Campaign_Product_5__r = prod;
                                    }
                                }

                            }

                        }
                    }
            }                
        }

      }
      catch(Exception e) {
            System.debug(' INT06 Error: '+e.getMessage());

            errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';

            exclusiveCalloutSuccess = false;
            exclusiveCalloutError = errorCodeText;
            exclusiveCalloutErrorDesc = errorDescText;
            // system.debug('hello Tae');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.RTL_CampaignMemberEdit_ERR003));
            String erStatus = '';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
            erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));

            // RTL_CampaignUtil.insertOnlineLog( errorCodeText,errorDescText, rmId , 'INT06' , customerName );
        }

        RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
            accountObj.id ,requestBody , resultBody , startCallINT06 ,endCallINT06 );

        return null;
    }
    
    private String endpointInt06{
        get{
            if( endpointInt06 == null )
            {
                RTL_Campaign_Endpoint__c endpointSetting = RTL_Campaign_Endpoint__c.getValues('Campaign TO HQ INT06');
                if( endpointSetting != null )
                {
                     endpointInt06 = endpointSetting.RTL_Endpoint__c;
                }
            }
            return endpointInt06;
        }
        set;
    }

    Class CampaignMemberResponseObject{
        public String campaigncode{get;set;}
        public String marketingcode{get;set;}
        public String productofferstring{get;set;}
        public String campaignchannel{get;set;}
        public String mobilenumber{get;set;}
        public String updatedate{get;set;}
        public String resultcontact{get;set;}
        public String agentid{get;set;}
        public String resultdetail{get;set;}
        public String resultdetailWebText{
            get{
                return replaceSpecialChar(resultdetail);
            }
            set;
        }

        public String offerresult{get;set;}
        public String reason{get;set;}
        public String smsmessage{get;set;}
        public String smsmessageWebText{
            get{
                return replaceSpecialChar(smsmessage);
            }
            set;
        }
        public String smscontent{get;set;}
        public String smscontentWebText{
            get{
                return replaceSpecialChar(smscontent);
            }
            set;
        }
        public String registerdateText{get;set;}
        public DateTime registerdate{
                get{
                    return parseDateTime(registerdateText);
                }
                set;
            }
        public String registerdateFormatted{
                get{
                    if(  parseDateTime(registerdateText)  != null)
                    {
                    	return parseDateTime(registerdateText).addHours(-7).format();
                    }
                    else
                    {
                        return '';
                    }
                }
                set;
            }
        public String displayflagText{get;set;}
        /*public Boolean displayflag{
            get{
                return parseFlag(displayflagText);
            }
            set;
        }*/
        public String displaydateText{get;set;}
        public Date displaydate{
                get{
                    return parseDate(displaydateText);
                }
                set;
            }
        public String clickflagText{get;set;}
        /*public Boolean clickflag{
            get{
                return parseFlag(clickflagText);
            }
            set;
        }*/
        public String clickdateText{get;set;}
        public Date clickdate{
                get{
                    return parseDate(clickdateText);
                }
                set;
            }
        public String emailsenddateText{get;set;}
        public Date emailsenddate{
                get{
                    return parseDate(emailsenddateText);
                }
                set;
            }
        public String emailrejectdateText{get;set;}
        public Date emailrejectdate{
                get{
                    return parseDate(emailrejectdateText);
                }
                set;
            }
        public String emailopenflagText{get;set;}
        /*public Boolean emailopenflag{
            get{
                return parseFlag(emailopenflagText);
            }
            set;
        }*/
        public String emailopendateText{get;set;}
        public Date emailopendate{
                get{
                    return parseDate(emailopendateText);
                }
                set;
            }
        public String emailclickflagText{get;set;}
        /*public Boolean emailclickflag{
            get{
                return parseFlag(emailclickflagText);
            }
            set;
        }*/
        public String emailclickdateText{get;set;}
        public Date emailclickdate{
                get{
                    return parseDate(emailclickdateText);
                }
                set;
            }
        public String contactsubstatus{get;set;}
        public String offersubresult{get;set;}
        public String resultbusiness{get;set;}
        public String resultbusinessWebText{
            get{
                return replaceSpecialChar(resultbusiness);
            }
            set;
        }
        public String contactdateText{get;set;}
        public DateTime contactdate{
                get{
                    return parseDateTime(contactdateText);
                }
                set;
            }
        public String contactdateFormatted{
                get{
                    
                     if( parseDateTime(contactdateText) != null)
                    {
                    	 return parseDateTime(contactdateText).addHours(-7).format();
                    }
                    else
                    {
                        return '';
                    }
                    
                }
                set;
            }

        private DateTime parseDateTime(String dateTimeText)
        {
            try{
                if( dateTimeText != null && dateTimeText != '' )
                {
                    return DateTime.valueOfGMT(dateTimeText.replace('T',' '));
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }

        Private Map<String,String> escapeString = new Map<String,String>{
            '\\"' => '"',
            '\\r\\n' => '<br />',
            '\\n' => '<br />'
        };

        private String replaceSpecialChar(String content)
        {

            for( String target : escapeString.keyset() )
            {
                String replacement = escapeString.get(target);

                content = content.replace(target,replacement);
            }
         
            return content;
        }

        /*private Boolean parseFlag(String flagText){
            if(flagText=='1'){
                return true;
            }else{
                return false;
            }
        }*/

        private Date parseDate(String dateText)
        {
            try{
                if( dateText != null && dateText != '' )
                {
                    return Date.valueOf(dateText.replace('T',' '));
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }
        public String personalizedMessage{get;set;}//phase2 new fields
        
    }

    public static CampaignMemberResponseObject  campaignMemberResponse {get;set;}

    private String requestLabel;

    public Boolean exclusiveCalloutSuccess{
        get{
            if( exclusiveCalloutSuccess == null )
            {
                exclusiveCalloutSuccess = true;
            }
            return exclusiveCalloutSuccess;
        }
        set;
    }

    public String exclusiveCalloutError{get;set;}
    public String exclusiveCalloutErrorDesc{get;set;}

    //========================== INT Section ==============================

    public String getCampaingNameEscaped()
    {
        String campaingName = '';
        if( currentObject != null )
        {
            if( currentObject.campaign.name != null )
            {
                //campaingName = String.escapeSingleQuotes( currentObject.campaign.name.escapeJava());
                campaingName = String.escapeSingleQuotes( currentObject.campaign.name );
            }

        }

        system.debug('campaingName'+campaingName);
        return campaingName;
    }


    //------------------- Telephony Outbound --------------------------

    public List<CM_OB_Sell_Permission__mdt> cmOBSellPermissionList {
        get
        {
            if(cmOBSellPermissionList == null){
                cmOBSellPermissionList = [SELECT Id,MasterLabel,Allow_To_Sell__c,Profile__c FROM CM_OB_Sell_Permission__mdt WHERE Profile__c =: 'Campaign Member Branch'];
            }
            return cmOBSellPermissionList;
            
        }set;
    }

    private void checkCampaignChannel()
    {
        Boolean isCampaignMemberCanSell = true;
        Boolean isMatch = false;
        if(campaignChannelFormula != null){   
            for(CM_OB_Sell_Permission__mdt cmOBPermission : cmOBSellPermissionList)
            {
                if(campaignChannelFormula.toUpperCase() == cmOBPermission.MasterLabel.toUpperCase())
                {
                    isCampaignMemberCanSell = cmOBPermission.Allow_To_Sell__c;
                    isMatch = true;
                }
            }
            System.debug('isCampaignMemberCanSell:'+isCampaignMemberCanSell);
            if(!isCampaignMemberCanSell && isMatch){
                isCampaignActive = false;
                preloadErrorMessage = System.Label.RTL_CampaignMember_CampaignMember_CanNotSell;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,System.Label.RTL_CampaignMember_CampaignMember_CanNotSell));    
            }
        }
    }

	// executes the search
    public PageReference runQuery() {
 
        try {
            if(query.length() >= 2)
            {
                errorMsg = null;
                nameField = 'Name,Description__c,Product_Group__c,Product_Sub_group__c,Product_Code__c';
                // condition = 'WHERE Active__c = true AND RTL_Product_Group_Upper__c = ';
                extraField = nameField;
                System.debug('searchCondition:'+searchCondition);
                String searchQuery = 'FIND \'' + query + '\' IN '+ searchField +' RETURNING ' + ObjectName + '(' + nameField + ' ' + searchCondition + ')' + ' Limit 30';
                System.debug('query => '+searchQuery);
                List<List<sObject>> searchList = search.query(searchQuery);
                System.debug('searchList => '+searchList);

                extraFields = extraField != null ? extraField.split(',') : null;
                List < lookupWrapper > returnList = new List < lookupWrapper > ();
                for (List<sObject> sObjList : searchList) {
                    for (sObject obj : sObjList) {
                        System.debug('obj => '+obj);
                        lookupWrapper res = new lookupWrapper();
                        res.Id = obj.Id;
                        res.Name = String.valueOf(obj.get('Name'));
                        res.extraValue = null;
                        if(extraFields != null) {
                            res.extraValue = new Map<String, String>();
                            for(String fname : extraFields) {
                                res.extraValue.put(fname, String.valueOf(obj.get(fname)));
                               
                            }
                        }
                        res.extraValueStr = JSON.serialize(res.extraValue);
                        returnList.add(res);
                    }
                }
                sObj = returnList;
                sObjSize = returnList.size();
                doneLookup = true;
                System.debug('sObjSize => '+sObjSize);
                System.debug('returnList => '+returnList);
                // System.debug('extraValue### => '+JSON.serialize(returnList[0].extraValue));

                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjSchema = schemaMap.get(ObjectName);
                Map<String, Schema.SObjectField> fieldMap = sObjSchema.getDescribe().fields.getMap();
                
                for (String fieldName: extraFields) 
                {      
                    System.debug('##Field API Name='+fieldName);
                    //It provides to get the object fields label.
                    if(fieldMap.containsKey(fieldName))
                    {
                        System.debug('##fieldMap='+fieldMap.get(fieldName).getDescribe().getLabel());
                        showFields.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                    }
                    for(lookupWrapper obj : sObj)
                    {
                        if(!obj.extraValue.containsKey(fieldName))
                        {
                            obj.extraValue.put(fieldName,'');
                            System.debug('##obj.extraValue='+obj.extraValue);
                        }
                    }
                }

                System.debug('##showFields='+showFields);
                extraFields.remove(0);
                System.debug('##extraFields='+extraFields);
                // System.debug('doneLookup:'+doneLookup);
                // System.debug('errorMsg:'+errorMsg);
            }
            else {
                sObj = null;
                doneLookup = true;
                sObjSize = 0;
                errorMsg = 'Error: Please enter a search string at least 2 characters long.';
                System.debug('doneLookup:'+doneLookup);
            }
            return null;
        } catch (Exception e) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Please enter a search string at least 2 characters long.'));
            errorMsg = e.getMessage();
            return null;
        }
    }

    public void selectRadio()
    {
        searchField = System.currentPagereference().getParameters().get('searchField');
        // System.debug('searchField:'+searchField);
    }   
    public void clearLookupSearch()
    {
        sObj = null;
        sObjSize = 0;
        errorMsg = '';
    }   

    public void leadScoreLevelList() {
        options = new List<SelectOption>();
        System.debug('leadScore:'+leadScore);

        for (Lead_Score_Level__c obj : leadScore) {
            options.add(new SelectOption(obj.Name,obj.Name));
        }
        System.debug('options:'+options);
    }
    public void test123() {

        string passedParam1 = Apexpages.currentPage().getParameters().get('leadScoreData');
        string passedParam2 = system.CurrentPageReference().getParameters().get('leadScoreData');
        System.debug(passedParam1);
        System.debug(passedParam2);
    }
    public Map<String, String> getLeadScoreData() {
        Map<String, String> myMap2 = new Map<String, String>();
        // Add data to the map
        for (Lead_Score_Level__c obj : leadScore) {
            myMap2.put(obj.Name, String.valueOf(obj.Score_Min__c));
        }
        System.debug('myMap:'+myMap2);

        return myMap2;
    }
    // public List<Lead_Score_Level__c> getLeadScoreData(){
    //     getLeadScoreData = [SELECT Name, Score_Min__c FROM Lead_Score_Level__c order by Score_Min__c asc];

    //     return getLeadScoreData;
    // }
    public String getSelectedOptionLabel() {
        System.debug(':Start getSelectedOptionLabel:');
        System.debug(':selectedOption:'+selectedOption);
        for (SelectOption option : options) {
            if (option.getValue().equals(selectedOption)) {
                System.debug(':selectedOption:'+option.getLabel());
                return option.getLabel();
            }
        }
        return null;
    }
    
    public void handleselectedValue(){
        String var3 = ApexPages.currentPage().getParameters().get('selectedValueParam');
        System.debug(':Start changeLeadScore:');

        System.debug(':var3:'+ var3);
        System.debug(':currentObject.RTL_Lead_Score_Flag__c:'+ currentObject.RTL_Lead_Score_Flag__c);
        for (Lead_Score_Level__c obj : leadScore) {
            System.debug('obj.Name'+ obj.Name);
            System.debug(':selectedValue:'+ selectedValue);
            if (obj.Name == selectedValue) {
                currentObject.Lead_Score__c = obj.Score_Min__c;
                currentObject.Lead_Score_Level__c = obj.Name;
                currentObject.RTL_Lead_Score_Flag__c = true;
            }
        }
        // Decimal score = Decimal.valueOf(newLeadScore);
        // currentObject.Lead_Score__c = score;
        // currentObject.Lead_Score_Level__c = newLeadScoreLevel;
    }
    // public void changeLeadScore(String newLeadScore, String newLeadScoreLevel){
    //     Decimal score = Decimal.valueOf(newLeadScore);
    //     currentObject.Lead_Score__c = score;
    //     currentObject.Lead_Score_Level__c = newLeadScoreLevel;
    // }
}