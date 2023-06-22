public without sharing class RTL_CampaignMemberTriggerHandler{
  private static List<CampaignMember> campaignmemberchangedStatusList = new List<CampaignMember>();
  private static Map<Id,RTL_NBO_History_Product__c> updateNBOProductList = new Map<Id,RTL_NBO_History_Product__c>();
  private static FINAL App_Config__mdt CONTACTCENTER = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Contact Center']; 
  private static FINAL App_Config__mdt OUTBOUND = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Outbound']; 
  private static FINAL App_Config__mdt TMBADMINVALUES = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'TMB Admin']; 
  private static FINAL App_Config__mdt TMBADMINNISTRATOR = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'TMB Administrator']; 
  private static FINAL App_Config__mdt BRANCH = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Branch']; 

  private static List<String> fieldTrackingList {get{
      if (fieldTrackingList == null) {
        fieldTrackingList = new List<String>();
        fieldTrackingList.add('RTL_Contact_Status__c');
        fieldTrackingList.add('RTL_Reason__c');
        //Telephony Outbound
        fieldTrackingList.add('Avaya_Completion_Code__c');

        fieldTrackingList.add('RTL_Assigned_Agent__c');
        fieldTrackingList.add('RTL_Assigned_Branch__c');
        fieldTrackingList.add('RTL_Branch_Team_Name_Code_Rpt__c');
        fieldTrackingList.add('RTL_Assigned_Region_Code_Rpt__c');
        fieldTrackingList.add('RTL_Assigned_Zone_Rpt__c');

        fieldTrackingList.add('RTL_Contact_Channel__c');
        fieldTrackingList.add('RTL_Contact_Branch_Team_Name_Code__c');
        fieldTrackingList.add('RTL_Contact_Zone_Group__c');
        fieldTrackingList.add('RTL_Contact_Region_Group_Head__c');
        //fieldTrackingList.add('RTL_Contact_Staff_ID__c');
        fieldTrackingList.add('RTL_Contact_Staff_Name__c');
  
        fieldTrackingList.add('Status');
        fieldTrackingList.add('RTL_Invitation_Status__c');
        fieldTrackingList.add('RTL_Attendant_Status__c');
        fieldTrackingList.add('RTL_Offer_Result_Eng__c');
        //fieldTrackingList.add('RTL_Offer_Result__c');

      }
      return fieldTrackingList;

    } set;
  }

  private static List<String> fieldCampaignProductList {get{
      if (fieldCampaignProductList == null) {
        fieldCampaignProductList = new List<String>();

        //Track Product Campaign Member

        fieldCampaignProductList.add('RTL_OfferResult_Product_1__c');
        fieldCampaignProductList.add('RTL_OfferResult_Product_2__c');
        fieldCampaignProductList.add('RTL_OfferResult_Product_3__c');
        fieldCampaignProductList.add('RTL_OfferResult_Product_4__c');
        fieldCampaignProductList.add('RTL_OfferResult_Product_5__c');

        fieldCampaignProductList.add('RTL_RelatedOpportunity_1__c');
        fieldCampaignProductList.add('RTL_RelatedOpportunity_2__c');
        fieldCampaignProductList.add('RTL_RelatedOpportunity_3__c');
        fieldCampaignProductList.add('RTL_RelatedOpportunity_4__c');
        fieldCampaignProductList.add('RTL_RelatedOpportunity_5__c');

        fieldCampaignProductList.add('RTL_Reason_1__c');
        fieldCampaignProductList.add('RTL_Reason_2__c');
        fieldCampaignProductList.add('RTL_Reason_3__c');
        fieldCampaignProductList.add('RTL_Reason_4__c');
        fieldCampaignProductList.add('RTL_Reason_5__c');
          
        //update this field when insert/update campaign member.  
        fieldCampaignProductList.add('RTL_Products_Offer_String__c');

      }
      return fieldCampaignProductList;

    } set;
  }

  public static List<String> getFieldTracking()
  {
    return fieldTrackingList;
  }

  public static Map<String, String> fieldLabelMap {get{
      if (fieldLabelMap == null) {
        fieldLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('CampaignMember');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
          fieldLabelMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }
      }

      return fieldLabelMap;
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
  private static Map<String, Id> branchCodeMap {get{
      if (branchCodeMap == null) {
        branchCodeMap = new Map<String, Id>();
      }
      return branchCodeMap;
    } set;
  }
  private static Map<ID, String> contactNameMap {get{
      if (contactNameMap == null) {
        contactNameMap = new Map<ID, String>();
      }
      return contactNameMap;
    } set;
  }


  public static void OnAfterUpdate(List<CampaignMember> newList, Map<Id, CampaignMember> oldMap) {

    system.debug('CPM : AfterUpdateTrigger excute');

    List<CampaignMember> campaignmemberchangedList = new List<CampaignMember>();

    //---------Update NBO Status----------//

    //boolean isProductStatusChange = false;

    for (CampaignMember cpm : newList) {
      CampaignMember oldCamMem = oldmap.get(cpm.id);

      //Check product field values
      for (String fieldName : fieldCampaignProductList) {
        if (cpm.get(fieldName) != oldCamMem.get(fieldName)) {
          campaignmemberchangedStatusList.add(cpm);
        }
      }
    }

    if (campaignmemberchangedStatusList.size() > 0) {
        //system.debug('CPM : campaignmemberchangedStatusList '+newList);
        //if(TriggerHandler.runOnce()){
          updateStatusNBOProduct(newList);
        //}
    }

    //-----End Update NBO Status----------//

    Set<String> empIDSet = new Set<String>();

    for (CampaignMember cpm : newList) {
      CampaignMember oldCamMem = oldmap.get(cpm.id);

      //Check field values
      boolean isFieldTrackingChange = false;

      for (String fieldName : fieldTrackingList) {
        if (cpm.get(fieldName) != oldCamMem.get(fieldName)) {
          isFieldTrackingChange = true;
          String oldvalue;
          String newvalue;

          oldvalue = String.valueof(oldCamMem.get(fieldName));
          newvalue = String.valueof(cpm.get(fieldName));
          settingValueTranformation(oldvalue);
          settingValueTranformation(newvalue);

          // Tracking for contact staff's emp id
          //if( fieldName == 'RTL_Contact_Staff_ID__c' )
          //{
          //  empIDSet.add(oldvalue);
          //  empIDSet.add(newvalue);
          //}

        }
      }

        
      if (isFieldTrackingChange) {
        campaignmemberchangedList.add(cpm);
      }

    }

    if (campaignmemberchangedList.size() > 0) {


      //System.debug('userIDset: ' + userIDset);

      if (userIDset.size() > 0) {
        for (User us : [SELECT ID, FirstName, LastName from USER WHERE ID IN:userIDset ]) {
          userNameMap.put(us.id, (us.FirstName != null ? us.FirstName : '') + ' ' + us.LastName);
        }
      }

      Map<String, String> userEmpIDNameMap = new Map<String, String>();
      if (empIDSet.size() > 0) {
        for (User us : [SELECT ID, FirstName, LastName,Employee_ID__c from USER WHERE Employee_ID__c IN:empIDSet ]) {
          userEmpIDNameMap.put(us.Employee_ID__c, us.FirstName + ' ' + us.LastName);
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

      Set<ID> campaignmemberChangedIDSet = new Set<ID>();
      List<RTL_Campaign_Member_History__c> insertHistoryList = new List<RTL_Campaign_Member_History__c>();
      for (CampaignMember changedRecord : campaignmemberchangedList) {
        //if(!changedRecord.RTL_isBatchUpdateCampaignMember__c){//skip insert log for migrate campaign member response
          RTL_Campaign_Member_History__c cmh = new RTL_Campaign_Member_History__c();
          cmh.RTL_Campaign_Member_ID__c = changedRecord.id;
          cmh.RTL_Campaign__c = changedRecord.CampaignId;
          cmh.RTL_Modified_By__c = changedRecord.LastmodifiedByID;
          cmh.RTL_Date__c = changedRecord.LastModifiedDate;

          if (changedRecord.LeadID != null ) {
            cmh.RTL_Lead__c = changedRecord.LeadID;
          } else if (changedRecord.ContactID != null) {
            cmh.RTL_Contact__c = changedRecord.ContactID;
          }

          campaignmemberChangedIDSet.add(changedRecord.id);
          insertHistoryList.add(cmh);
        //}
      }

      if(insertHistoryList.size() > 0){
        insert insertHistoryList;
      }

      Map<ID, RTL_Campaign_Member_History__c> campaignmemberwithHistoryMap = new Map<ID, RTL_Campaign_Member_History__c>();
      
      //Case Non Selective
      /*for (RTL_Campaign_Member_History__c eachCMH : [SELECT ID, RTL_Campaign_Member_ID__c
           FROM RTL_Campaign_Member_History__c
           WHERE RTL_Campaign_Member_ID__c IN: campaignmemberChangedIDSet ORDER BY RTL_Date__c ASC  ]) {
        campaignmemberwithHistoryMap.put(eachCMH.RTL_Campaign_Member_ID__c, eachCMH);
      }*/

      for(RTL_Campaign_Member_History__c eachCMH :insertHistoryList){
        campaignmemberwithHistoryMap.put(eachCMH.RTL_Campaign_Member_ID__c, eachCMH);
      }

      List<RTL_Campaign_Member_History_detail__c> insertHistoryDetailList = new List<RTL_Campaign_Member_History_detail__c>();
      List<RTL_Campaign_Member_History__c> updateCampaignMemberHistoryList = new List<RTL_Campaign_Member_History__c>();


      for (CampaignMember changedRecord : campaignmemberchangedList) {
       // if(!changedRecord.RTL_isBatchUpdateCampaignMember__c){//skip insert log for migrate campaign member response
          CampaignMember oldCamMem = oldmap.get(changedRecord.id);
          RTL_Campaign_Member_History__c cmh = campaignmemberwithHistoryMap.get(changedRecord.id);
          // String ActionRichText ='';


          //ActionRichText += 'Update ';
          Integer index = 1;
          for (String fieldName : fieldTrackingList) {
            string oldvalue;
            string newvalue;
            if (changedRecord.get(fieldName) != oldCamMem.get(fieldName)) {

              RTL_Campaign_Member_History_detail__c  cmhd = new RTL_Campaign_Member_History_detail__c();

              cmhd.RTL_Campaign_Member_History__c = cmh.id;
              
              //string fieldnamelowercase = fieldName.toLowerCase();
              //cmhd.RTL_Field_Name__c = fieldLabelMap.get(fieldnamelowercase);
              
              // Change to stamp API name Field
              cmhd.RTL_Field_Name__c =  fieldName;


              if(fieldName == 'RTL_Reason__c' || fieldName == 'RTL_Contact_Status__c' || fieldName == 'Status'
                || fieldName == 'RTL_Invitation_Status__c' || fieldName == 'RTL_Attendant_Status__c'  ){
                
                // Change to stamp API pick list name
                oldvalue = String.valueof(oldCamMem.get(fieldName));
                newvalue = String.valueof(changedRecord.get(fieldName));

                //check label picklist
                //oldvalue = RTL_Utility.getLabelPicklist(String.valueof(oldCamMem.get(fieldName)),fieldName,'CampaignMember');
                //newvalue = RTL_Utility.getLabelPicklist(String.valueof(changedRecord.get(fieldName)),fieldName,'CampaignMember');
              }
              else{
                oldvalue = String.valueof(oldCamMem.get(fieldName));
                newvalue = String.valueof(changedRecord.get(fieldName));
              }
              cmhd.RTL_Field_Old_Value__c = retrieveValueTranformation(oldvalue);
              cmhd.RTL_Field_New_Value__c = retrieveValueTranformation(newvalue);
              insertHistoryDetailList.add(cmhd);
            }
          }
          updateCampaignMemberHistoryList.add(cmh);
        //}
      }

      insert insertHistoryDetailList;
      update updateCampaignMemberHistoryList;

    }

  }

  public static void OnAfterInsert(List<CampaignMember> newList) {
    // Check and update Lead of campaign member after success created campaign member
    RTL_CampaignMemberUtil.updateLeadOwnerIdFromCampaign(newList);

    // Stamp Campaign Member URL
    List<CampaignMember> campaignMemberListforUpdate = new List<CampaignMember>();
    CampaignMember campaignMember = null;
    Campaign campaign = null;
    for (CampaignMember campaignMemberAfterInsert : [select Id, Campaign_Member_URL__c, RTL_Contact_Status__c,CampaignId, Campaign.status, Campaign.Approvedflag__c from CampaignMember where Id in :newList]) {
      campaign = new Campaign(Id=campaignMemberAfterInsert.CampaignId,
                             status=campaignMemberAfterInsert.Campaign.status);
      campaign.Approvedflag__c = campaignMemberAfterInsert.Campaign.Approvedflag__c;

      if(RTL_CampaignMemberUtil.checkActiveCampaign(campaign, campaignMemberAfterInsert)){
        Blob cmUrl = Blob.valueOf('{"componentDef":"c:CampaignMember_Main","attributes":{"recordId":"' + campaignMemberAfterInsert.Id + '","mode":"Edit"},"state":{}}');
        String encUrl = EncodingUtil.base64Encode(cmUrl);
        campaignMemberAfterInsert.Campaign_Member_URL__c = URL.getSalesforceBaseURL().toExternalForm() + '/one/one.app#' + encUrl;
        campaignMemberAfterInsert.Campaign_Member_Link2__c = URL.getSalesforceBaseURL().toExternalForm() + '/one/one.app#' + encUrl;
        campaignMemberListforUpdate.add(campaignMemberAfterInsert);
      }
    }
  
    update campaignMemberListforUpdate;
    
    // List<CampaignMember> campaignMemberToALList = new  List<CampaignMember>();
    // for(CampaignMember cm : newList)
    // {
    //     if(cm.RTL_Contact_Method__c == 'AL Sales')
    //     {
    //         campaignMemberToALList.add(cm);
    //     }
    // }

    // if(campaignMemberToALList.size() > 0)
    // {
    //     RTL_AL_CampaignMemberToAL.sendCampaignMemberToAL(campaignMemberToALList);
    // }

  }

  public static void settingValueTranformation(String IdValue) {

    if (IdValue != null && IdValue != '') {

      if (IdValue.length() == 15 || IdValue.length() == 18) {
        string keyprefix = IdValue.substring(0, 3);
        if (prefixSobjectMap.containsKey(keyprefix)) {
          // String prefixSobject = prefixSobjectMap.get(keyprefix);
          String prefixSobject = ((Id)IdValue).getSObjectType().getDescribe().getName().toLowerCase();

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

  public static String retrieveValueTranformation(String IDvalue) {
    String newtransfromvalue = '';
    if (IDvalue != null && IDvalue != '') {
      if (IDvalue.length() == 15 || IDvalue.length() == 18) {
        string keyprefix = IDvalue.substring(0, 3);
        if (prefixSobjectMap.containsKey(keyprefix)) {
          //   String prefixSobject = prefixSobjectMap.get(keyprefix);
          String prefixSobject = ((Id)IdValue).getSObjectType().getDescribe().getName().toLowerCase();

          if (prefixSobject == 'user'  && userNameMap.containskey(IDvalue)) {
            newtransfromvalue = userNameMap.get(IDvalue);
          } else if (prefixSobject == 'branch_and_zone__c'  && branchNameMap.containskey(IDvalue)) {
            newtransfromvalue = branchNameMap.get(IDvalue);
          } else if (prefixSobject == 'contact' && contactNameMap.containskey(IDvalue)) {
            newtransfromvalue = contactNameMap.get(IDvalue);
          }

        }
        else 
        {
          newtransfromvalue = IDvalue;
        }
      } else {
        newtransfromvalue = IDvalue;
      }
    }



    return newtransfromvalue;

  }

  // CR Web-drop-lead
  public static void beforeInsert(List<CampaignMember> newList){
    system.debug('CPM : beforeInsert start');
    //system.debug('CPM : newList' + newList);
        List<CampaignMember> listcmToCalculate = new List<CampaignMember>();
        RTL_AssignmentCriteriaService assignmentService = new RTL_AssignmentCriteriaService();
        Set<Id> leadIdSet = new Set<Id>();
        Set<String> branchNameSet = new Set<String>();
        Map<Id,Lead> leadMap;
        User tmbAdmin = [SELECT ID,Name FROM User WHERE Name = 'TMB Administrator'];
        List<CampaignMember> dropLeadCampaignMember = new List<CampaignMember>();
        List<RTL_Channel_Code_Mapping__mdt> channelCodeMapping = [SELECT Id, RTL_Lead_Group__c, 
                                  RTL_Campaign_Lead_Source__c, 
                                  RTL_Channel_Code__c, 
                                  RTL_Campaign_Reference__c, 
                                  DeveloperName, 
                                  MasterLabel, Label 
                                  FROM RTL_Channel_Code_Mapping__mdt];

        //Put all retail product master to map for later retrieval
        Map<String, RTL_product_master__c> productMap = new Map<String, RTL_product_master__c>();
        for(RTL_product_master__c product : [Select Id, Name, Product_Group__c, Product_Sub_group__c 
                                                         from RTL_product_master__c WHERE Active__c = true order by Name, Product_Group__c desc]) {
            productMap.put(product.Name, product);                                                            
        }

        for(CampaignMember campaignMemberObj : newList){
            if(campaignMemberObj.leadId != null){
                leadIdSet.add(campaignMemberObj.leadId);
            }

            if(campaignMemberObj.RTL_Register_Date__c==null){
              campaignMemberObj.RTL_Register_Date__c = system.today();
            }

            if(campaignMemberObj.RTL_Branch_Code__c != null){
              branchNameSet.add(campaignMemberObj.RTL_Branch_Code__c);
            }
            if(campaignMemberObj.Scoring_Condition_Id__c != null){
              listcmToCalculate.add(campaignMemberObj);
            }
        }
        if(leadIdSet.size() > 0){
            leadMap = new Map<Id,Lead>([SELECT Id,Name,RTL_Branch_Name__c,RTL_TMB_Campaign_Reference__c,
                                              RTL_TMB_Campaign_Source__c,RTL_Customer_Segment__c,
                                              RTL_Product_Name__c,RTL_Web_Unique_ID_c__c,OwnerId,
                                              Owner.Name,RTL_Branch_Code_Rpt__c,
                                              RTL_W2L_Calculated_Amount__c,
                                              RTL_W2L_Calculated_Loan_Period__c,
                                              RTL_W2L_Calculated_No_of_Installments__c,
                                              RTL_W2L_Has_Co_Borrower__c,
                                              RTL_INTERESTS__c,
                                              RTL_Mobile_Number__c,
                                              RTL_Register_Date__c,
                                              RTL_AccountID__c,
                                              RTL_Lead_Assigned_By_Rule__c,
                                              RTL_Lead_Assigned_By_Rule__r.RTL_IsAssign_Campaign__c,
                                              RTL_W2L_Transfer_Period__c
                                              FROM Lead WHERE Id IN : leadIdSet]);
            //add all branch code from lead
            for(Lead l : leadMap.values()){
              if(l.RTL_Branch_Code_Rpt__c !=null){
                branchNameSet.add(l.RTL_Branch_Code_Rpt__c);
              }

            }

            
        }

        //query branch into branchMap
        if (branchNameSet.size() > 0) {
          for (Branch_and_Zone__c baz : [SELECT ID, Branch_Code__c from branch_and_zone__c Where Branch_Code__c IN:branchNameSet and isActive__c = true]) {
            branchCodeMap.put(baz.Branch_Code__c, baz.Id);
          }
        }

        for(CampaignMember campaignMemberObj : newList){
          if(campaignMemberObj.leadId != null){
            
            Lead leadObj = leadMap.get(campaignMemberObj.leadId);
            if(leadObj.RTL_Lead_Assigned_By_Rule__c != null && leadObj.RTL_Lead_Assigned_By_Rule__r.RTL_IsAssign_Campaign__c == true){
              dropLeadCampaignMember.add(campaignMemberObj);
            }
          }else{
            if(new List<String> { 'Web', 'ATM Request', 'Call me now', 'O2O Web' }.contains(campaignMemberObj.RTL_TMB_Campaign_Source__c)){
              dropLeadCampaignMember.add(campaignMemberObj);
            }
          }
        }
        
        for(CampaignMember campaignMemberObj : dropLeadCampaignMember){
          if(campaignMemberObj.RTL_Assigned_Channel__c == null){

            if(campaignMemberObj.leadId != null){
                Lead leadObj = leadMap.get(campaignMemberObj.leadId);
                //system.debug('Lead map :'+leadObj);
                campaignMemberObj.RTL_TMB_Campaign_Reference__c = leadObj.RTL_TMB_Campaign_Reference__c;
                campaignMemberObj.RTL_TMB_Campaign_Source__c = leadObj.RTL_TMB_Campaign_Source__c;
                campaignMemberObj.RTL_Lead_Group__c = leadObj.RTL_Customer_Segment__c;
                campaignMemberObj.RTL_Product_Name__c = leadObj.RTL_Product_Name__c;
                campaignMemberObj.RTL_Web_Unique_ID__c = leadObj.RTL_Web_Unique_ID_c__c;
                campaignMemberObj.RTL_Originate_Branch__c = leadObj.RTL_Branch_Name__c;
                campaignMemberObj.RTL_CampHis_Phone__c = leadObj.RTL_Mobile_Number__c;
                campaignMemberObj.RTL_Register_Date__c = leadObj.RTL_Register_Date__c;
                campaignMemberObj.RTL_AccountId__c = leadObj.RTL_AccountId__c;

                //concat product features
                campaignMemberObj.RTL_Product_Feature__c = concatProductFeatures(leadObj);
                
                 if(leadObj.Owner.Name != null && leadObj.Owner.Name.contains(CONTACTCENTER.Value__c)){
                    campaignMemberObj.RTL_Assigned_Channel__c = OUTBOUND.Value__c;
                    campaignMemberObj.RTL_Channel_Outbound__c = true;
                }else if(leadObj.Owner.Name != null && leadObj.Owner.Name.contains(TMBADMINNISTRATOR.Value__c)){
                    //campaignMemberObj.RTL_Assigned_Channel__c = TMBADMINVALUES.Value__c;
                    //campaignMemberObj.RTL_Assigned_Agent__c = leadObj.OwnerId;
                }else if(leadObj.OwnerId.getSObjectType().getDescribe().getName().toLowerCase() == 'user'){
                    campaignMemberObj.RTL_Assigned_Agent__c = leadObj.OwnerId;
                    if(LeadAssignmentUtil.mapIdUser.containsKey(leadObj.OwnerId) && LeadAssignmentUtil.mapIdUser.get(leadObj.OwnerId).RTL_Channel__c == BRANCH.Value__c){
                        campaignMemberObj.RTL_Assigned_Channel__c = BRANCH.Value__c;
                        campaignMemberObj.RTL_Channel_Branch__c = true;
                    }
                }else{
                    //campaignMemberObj.RTL_Assigned_Channel__c = leadObj.RTL_Branch_Name__c;
                    campaignMemberObj.RTL_Assigned_Channel__c = BRANCH.Value__c;
                    campaignMemberObj.RTL_Channel_Branch__c = true;
                    //Add logic to attach branch and zone object to campaign member
                    if(leadObj.RTL_Branch_Code_Rpt__c !=null){
                       Id branchCodeid = branchCodeMap.get(leadObj.RTL_Branch_Code_Rpt__c);
                       campaignMemberObj.RTL_Assigned_Branch__c = (branchCodeid!=null)?branchCodeid:null;
                    }
                }
                
            }else{
                String campaignRef = campaignMemberObj.RTL_TMB_Campaign_Reference__c;
                String zipCode = campaignMemberObj.RTL_Source_ZipCode__c;
                String productName = campaignMemberObj.RTL_Product_Name__c;
                String branchCode = campaignMemberObj.RTL_Branch_Code__c;

                String assignedChannel = assignmentService.assignmentCriteria(campaignRef,zipCode,productName,false,branchCode); 
                campaignMemberObj.RTL_Assigned_Channel__c = assignedChannel;
                campaignMemberObj.RTL_Originate_Branch__c = branchCode;
                
                if(assignedChannel == OUTBOUND.Value__c){
                  campaignMemberObj.RTL_Channel_Outbound__c = true;
                }else if(assignedChannel == TMBADMINVALUES.Value__c){
                  //Assign to TMB Admin
                  //campaignMemberObj.RTL_Assigned_Agent__c = tmbAdmin.Id;
                }else{
                  campaignMemberObj.RTL_Channel_Branch__c = true;
                  campaignMemberObj.RTL_Assigned_Channel__c = BRANCH.Value__c;
                  //Add logic to attach branch and zone object to campaign member
                  if(branchCode !=null){
                    Id branchCodeid = branchCodeMap.get(branchCode);
                    System.debug('branchCode :: '+branchCode);
                    System.debug('branchCodeMap :: '+branchCodeMap);
                    System.debug('branch Code Id :: '+branchCodeid);
                    campaignMemberObj.RTL_Assigned_Branch__c = (branchCodeid!=null)?branchCodeid:null;
                  }
                }
                
            }

            //Split Product
            System.debug('campaignMemberObj.RTL_Product_Name__c: ' + campaignMemberObj.RTL_Product_Name__c);
            if(campaignMemberObj.RTL_Product_Name__c!=null){

              string productset = campaignMemberObj.RTL_Product_Name__c;
              List<String> productNameList = null;
              productNameList = productset.split(';');
              integer count = 0;
              if(productNameList.size() <=5){
                for(integer i=0;i<productNameList.size();i++){
                  //system.debug(productNameList.get(i));
                  string product = productNameList.get(i);
                  if(product!=null){
                    RTL_product_master__c productDetail = productMap.get(product);
                    if(productDetail!= null){
                      count++;
                      campaignMemberObj.put('RTL_Campaign_Product_' + count + '__c', productDetail.id);
                      campaignMemberObj.put('RTL_Product_Group_' + count + '__c', productDetail.Product_Group__c);
                      campaignMemberObj.put('RTL_Sub_Group_' + count + '__c',productDetail.Product_Sub_group__c);
                    }else{
                      system.debug('CPM : Product not found.');
                    }

                  }
                }
              }else{
                system.debug('CPM : Product name split more than 5.');
              }

              if(channelCodeMapping.size() > 0){
                Lead leadObj = campaignMemberObj.leadId != null ? leadMap.get(campaignMemberObj.leadId) : null;
                campaignMemberObj.RTL_Remark__c = concatRemark(channelCodeMapping,campaignMemberObj, leadObj);
              }

              /*
                Project: AL Integration
                Description: Mapping fields Auto loan create campaign member
                Editor: Narathip Santhip
                Date modified: 20201014
              */
              if(new List<String>{'O2O Web', 'MIS'}.contains(campaignMemberObj.RTL_Lead_Group__c)) {
                // 1. Line1 = 'ยี่ห้อ' + RTL_AL_car_brand__c | '' + RTL_AL_car_group__c | 'รุ่นย่อย' + RTL_AL_car_subtype__c | 'เกียร์' + RTL_AL_car_gear__c | 'ป้ายทะเบียนรถ' + RTL_AL_car_plate_no__c
                // 2. Line2 = 'ค่างวดต่อเดือน' + RTL_AL_installment_amount__c | 'ระยะเวลาผ่อนชำระ' + RTL_AL_installment_periods__c | 'วงเงินสูงสุด (บาท)' + RTL_AL_max_set_up_amount__c | 'ราคากลาง(บาท)' + RTL_AL_normal_price__c | 'ยอดจัด / วงเงินที่ต้องการ' + RTL_AL_wanted_amount__c
                Map<String, String> fieldsTranslate = new Map<String, String>{
                    'RTL_AL_car_brand__c' => 'ยี่ห้อ',
                    'RTL_AL_car_group__c' => 'รุ่น',
                    'RTL_AL_car_subtype__c' => 'รุ่นย่อย',
                    'RTL_AL_car_gear__c' => 'เกียร์',
                    'RTL_AL_car_plate_no__c' => 'ป้ายทะเบียนรถ',
                    'RTL_AL_installment_amount__c' => 'ค่างวดต่อเดือน',
                    'RTL_AL_installment_periods__c' => 'ระยะเวลาผ่อนชำระ (เดือน)',
                    'RTL_AL_max_set_up_amount__c' => 'วงเงินสูงสุด (บาท)',
                    'RTL_AL_normal_price__c' => 'ราคากลาง(บาท)',
                    'RTL_AL_wanted_amount__c' => 'ยอดจัด / วงเงินที่ต้องการ'
                };
                List<String> line1 = new List<String>();
                List<String> line2 = new List<String>();
                for (String fields : new List<String>{ 'RTL_AL_car_brand__c','RTL_AL_car_group__c','RTL_AL_car_subtype__c','RTL_AL_car_gear__c','RTL_AL_car_plate_no__c' }) {
                    line1.add(String.format('{0} {1}', new List<Object>{
                        fieldsTranslate.get(fields),
                        campaignMemberObj.get(fields) instanceof Decimal ? Decimal.valueOf(String.valueOf(campaignMemberObj.get(fields))).format() : campaignMemberObj.get(fields)
                    }));
                }
                for (String fields : new List<String>{ 'RTL_AL_installment_amount__c','RTL_AL_installment_periods__c','RTL_AL_max_set_up_amount__c','RTL_AL_normal_price__c','RTL_AL_wanted_amount__c' }) {
                    line2.add(String.format('{0} {1}', new List<Object>{
                        fieldsTranslate.get(fields),
                        campaignMemberObj.get(fields) instanceof Decimal ? Decimal.valueOf(String.valueOf(campaignMemberObj.get(fields))).format() : campaignMemberObj.get(fields)
                    }));
                }

                String AL_Remark = String.format('{0}\r\n<br/>{1}', new List<String>{
                    String.join(line1, ' | '), String.join(line2, ' | ')
                });
                campaignMemberObj.RTL_Remark__c = String.format('{0}\r\n<br/>{1}', new List<Object>{
                  campaignMemberObj.RTL_Remark__c, // Remark old value
                  AL_Remark
                });

              }

              /* AL Droplead enhancement for TTB Web */
              System.debug('Lead remark --> ' + campaignMemberObj.RTL_Lead_Remark__c);
              if (String.isNotEmpty(campaignMemberObj.RTL_Lead_Remark__c)) {
                campaignMemberObj.RTL_Remark__c = String.format('{0}<br/><br/>{1}', new List<Object>{
                  campaignMemberObj.RTL_Remark__c, // Remark old value
                  campaignMemberObj.RTL_Lead_Remark__c
                });
              }

            }
          }
          system.debug('CRM : campaign mapping lead : '+campaignMemberObj);
        }
        if(listcmToCalculate.size() > 0 && listcmToCalculate.size() == 1 && newList.size() == 1){
          System.debug('call LeadScoreCalculate beforeInsert!');
          CampaignMember cmUpdatedScore = new CampaignMember();
          cmUpdatedScore = LeadScoreCalculation.LeadScoreCalculate(listcmToCalculate[0]);
          for(CampaignMember cm : newList){
              cm.Lead_Score__c = cmUpdatedScore.Lead_Score__c;
              cm.Lead_Score_Level__c = cmUpdatedScore.Lead_Score_Level__c;
            
          }
        }
        system.debug('CPM : beforeInsert end');
  }

  public static String concatRemark(List<RTL_Channel_Code_Mapping__mdt> channelCodeMapping,CampaignMember c, Lead lead){
    //Date d = date.today();
    Date d = c.RTL_Register_Date__c;
    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('d/MM/yyyy');

    String productName = c.RTL_Product_Name__c;
    productName = productName.replaceAll(';', '/');
    string remark = '';
    String leadW2LtransferPre = lead == null ? '' : lead.RTL_W2L_Transfer_Period__c;

    List<String> remarkParam;
    remarkParam = new String[]{ productName,c.RTL_TMB_Campaign_Source__c,dt,findChannelCode(channelCodeMapping,c.RTL_Lead_Group__c,c.RTL_TMB_Campaign_Source__c), c.RTL_Income__c, leadW2LtransferPre};
    remark = String.format(Label.RTL_WebDropLead_Remark,remarkParam);

    if(c.RTL_Product_Feature__c != null && c.RTL_Product_Feature__c != ''){
      remarkParam = new String[]{ productName,c.RTL_TMB_Campaign_Source__c,dt,c.RTL_Product_Feature__c,findChannelCode(channelCodeMapping,c.RTL_Lead_Group__c,c.RTL_TMB_Campaign_Source__c)};
      remark = String.format(Label.RTL_WebDropLead_HLCAL_Remark,remarkParam);
    }

    remark = remark.length() > 255 ? remark.substring(0, 254) : remark;
    return remark;
  }

  public static String concatProductFeatures(Lead l){
    string productfeature = '';
    string amount = (l.RTL_W2L_Calculated_Amount__c!=null)?l.RTL_W2L_Calculated_Amount__c:'';
    string interests = (l.RTL_INTERESTS__c!=null)?l.RTL_INTERESTS__c:'';
    string loanperiod = (l.RTL_W2L_Calculated_Loan_Period__c!=null)?l.RTL_W2L_Calculated_Loan_Period__c:'';
    string noofinstallment = (l.RTL_W2L_Calculated_No_of_Installments__c!=null)?l.RTL_W2L_Calculated_No_of_Installments__c:'';
    string borrower = (l.RTL_W2L_Has_Co_Borrower__c!=null)?''+l.RTL_W2L_Has_Co_Borrower__c:'';

    if(amount!=''&&interests!=''&&loanperiod!=''&&noofinstallment!=''&&borrower!=''){
      List<String> productfeatureParam = new String[]{amount,interests,loanperiod,noofinstallment,borrower};
      productfeature = String.format(Label.RTL_WebDropLead_Product_Features,productfeatureParam);
    }

    return productfeature;
  }

  public static String findChannelCode (List<RTL_Channel_Code_Mapping__mdt> channelCodeMapping,string leadgroup,string source){
    string code;
    if(channelCodeMapping.size() > 0){
      for(RTL_Channel_Code_Mapping__mdt cc : channelCodeMapping){
        if(leadgroup == cc.RTL_Lead_Group__c && source == cc.RTL_Campaign_Lead_Source__c){
          code = cc.RTL_Channel_Code__c;
          break;
        }
      }
    }

    return code;
  }

  public static void beforeUpdate(List<CampaignMember> newList,Map<ID,CampaignMember> oldList) {

    system.debug('CPM : BeforeUpdateTrigger excute');

    Set<Id> campaignIdSet = new Set<Id>();
    List<CampaignMember> campaignMemIdSet = new List<CampaignMember>();

    for(CampaignMember cm : newList){
      if(cm.CampaignId != null){
        campaignIdSet.add(cm.CampaignId);
      }
    }

    Map<Id,Campaign> mapCampaign =  new Map<Id,Campaign>();

    for(Campaign c : [Select Id, Name, RecordTypeId, Status,Approvedflag__c ,RecordType.DeveloperName
              FROM Campaign 
              where Id in:campaignIdSet]){//status not in ('Expired','On Hold','Cancelled')  and Approvedflag__c = true and
      mapCampaign.put(c.id,c);
    }

    string errorMessage = System.Label.RTL_CampaignMemberEdit_ERR003;

    //Update Campaign member status if offer result and contact status is changed.
    updateCampaignStatus(newList,oldList);
    
    //Check campaign active before update campaign member
    for(CampaignMember cm : newList){
      Boolean campaignIsActive = false;

        Campaign camp = mapCampaign.get(cm.campaignid);
        //if((cm.RTL_Last_Contact_Status__c != null && cm.RTL_Last_Contact_Status__c != '') || mapCampaign.size() > 0 ){

        if(RTL_CampaignMemberUtil.checkActiveCampaign(camp,cm)){
          campaignIsActive = true;
        }
        else if(cm.RTL_Assigned_Branch__c != oldList.get(cm.id).RTL_Assigned_Branch__c ||   
          cm.RTL_Assigned_Agent__c != oldList.get(cm.id).RTL_Assigned_Agent__c ){
          
          //For reassign can change 
          campaignIsActive = true;
        }
        
        //Update Reason of not interest to new field	
        for(Integer i = 1; i <= 5; i++)	
        {	
          if(cm.get('RTL_Reason_' +i+ '__c') != null)	
          {	
            cm.put('Not_Interest_Reason' +i+ '__c',cm.get('RTL_Reason_' +i+ '__c'));	
          }	
        }

      if( cm.RTL_isBatchUpdateCampaignMember__c == false){
        if(!campaignIsActive){
          cm.addError(errorMessage); 
          system.debug('CPM : '+errorMessage);
        }

      }

      cm.RTL_isBatchUpdateCampaignMember__c = false;
      if(cm.Scoring_Condition_Id__c != null && cm.RTL_Lead_Score_Flag__c == false && cm.RTL_Is_Send_To_HPAP__c == false && cm.LeadId != null){
        campaignMemIdSet.add(cm);
      }
      
    }
    
    if(campaignMemIdSet.size() > 0 && campaignMemIdSet.size() == 1 && newList.size() == 1){
      CampaignMember cmUpdatedScore = new CampaignMember();
      System.debug('call LeadScoreCalculate beforeUpdate!');
      cmUpdatedScore = LeadScoreCalculation.LeadScoreCalculate(campaignMemIdSet[0]);
      for(CampaignMember cm : newList){
        if(campaignMemIdSet[0].Id == cm.Id){
          cm.Lead_Score__c = cmUpdatedScore.Lead_Score__c;
          cm.Lead_Score_Level__c = cmUpdatedScore.Lead_Score_Level__c;
        }
      }
    }

    system.debug('CPM : BeforeUpdateTrigger excute');
  }

  public static void updateCampaignStatus(List<CampaignMember> newList,Map<ID,CampaignMember> oldList) {
    //system.debug('CPM : before update campaign member status  : '+newList);

    List<RTL_Campaign_Member_Status_Mapping__mdt> listcampaignstatus = [SELECT RTL_Offer_Result__c, 
                                                                        RTL_Contact_Status__c, 
                                                                        RTL_Campaign_Member_Status__c, 
                                                                        RTL_Campaign_Catgory__c, 
                                                                        Id, DeveloperName, 
                                                                        MasterLabel, Label 
                                                                        FROM RTL_Campaign_Member_Status_Mapping__mdt];

    for(CampaignMember c : newList){
        //if(c.RTL_Contact_Status__c != oldList.get(c.id).RTL_Contact_Status__c ||
          //c.RTL_Offer_Result_Eng__c != oldList.get(c.id).RTL_Offer_Result_Eng__c){
            for(RTL_Campaign_Member_Status_Mapping__mdt s : listcampaignstatus){
              if(c.RTL_Campaign_Category_formula__c!=null && c.RTL_Campaign_Category_formula__c.equalsIgnoreCase(s.RTL_Campaign_Catgory__c) && 
                c.RTL_Contact_Status__c!= null && c.RTL_Contact_Status__c.equalsIgnoreCase(s.RTL_Contact_Status__c) &&
                c.RTL_Offer_Result_Eng__c != null && c.RTL_Offer_Result_Eng__c.equalsIgnoreCase(s.RTL_Offer_Result__c)){

                c.Status = s.RTL_Campaign_Member_Status__c;

              }

            }
        //}
    }                        

    //system.debug('CPM : after update campaign member status  '+newList);


  }

  public static void updateStatusNBOProduct(List<CampaignMember> newList) {
    system.debug('CPM : before update NBO product  : '+newList);

    Set<Id> campaignIdSet = new Set<Id>();
    Set<Id> campaignProductIdSet = new Set<Id>();
    Set<Id> customerIdSet = new Set<Id>();
    Set<Id> nboIdSet = new Set<Id>();
    Map<Id,CampaignMember> newCamapignMemberMap = new Map<Id,CampaignMember>();
    Map<Id,RTL_product_master__c> mapProductName = new Map<Id,RTL_product_master__c>();
    Map<Id,RTL_NBO_History__c> mapNBO = new Map<Id,RTL_NBO_History__c>();
    Map<Id,RTL_NBO_History_Product__c> mapNBOProduct = new Map<Id,RTL_NBO_History_Product__c>();

    for(CampaignMember cm : newList){
      campaignIdSet.add(cm.CampaignId);
      customerIdSet.add(cm.Customer__c);
      newCamapignMemberMap.put(cm.CampaignId,cm);
      
      //Get Product Id
      for(integer i = 1; i <= 5; i++){
          id pId = (Id) cm.get('RTL_Campaign_Product_' +i+ '__c');
          campaignProductIdSet.add(pId);
      }
    }

    //Get Product 
    if(campaignProductIdSet.size() > 0){
      for(RTL_product_master__c p :[select id,name from RTL_product_master__c where id in: campaignProductIdSet]){
        mapProductName.put(p.id, p);
      }

    }

    //Get NBO History that mapping Campaign
    if(campaignIdSet.size() > 0 || customerIdSet.size() > 0){
      for(RTL_NBO_History__c nbo : [Select Id,RTL_Campaign__c,RTL_Customer_Name__c from RTL_NBO_History__c where RTL_Campaign__c in :campaignIdSet and RTL_Customer_Name__c in: customerIdSet]){//
        //nboIdSet.add(nbo.id);
        mapNBO.put(nbo.id,nbo);
      }
    }
    
    if(mapNBO.size() > 0){
      for(RTL_NBO_History_Product__c nbop : [Select id,
                  RTL_Product__c,
                  RTL_Product_Group__c,
                  RTL_Product_SubGroup__c,
                  RTL_Status__c,
                  RTL_Reject_Reason__c,
                  RTL_Related_NBO__c
                  from RTL_NBO_History_Product__c 
                  where RTL_Related_NBO__c in: mapNBO.keyset()]){
        mapNBOProduct.put(nbop.id,nbop);
      }

      system.debug('CPM : newCamapignMemberMap'+newCamapignMemberMap);
      system.debug('CPM : mapNBO'+mapNBO);
      system.debug('CPM : mapNBOProduct'+mapNBOProduct);

      //List<RTL_NBO_History_Product__c> updateNBOProductList = new List<RTL_NBO_History_Product__c>();

      if(mapNBOProduct.size() > 0){
        for(RTL_NBO_History_Product__c nbop : mapNBOProduct.values()){
            RTL_NBO_History__c nbo = new RTL_NBO_History__c();
           
            string statusNBO = null;


            //Get NBO
            nbo = mapNBO.get(nbop.RTL_Related_NBO__c);
            system.debug(nbo);

            if(nbo != null){
              for(CampaignMember cm : newCamapignMemberMap.values()){
                 Boolean changeStatus = false;
                 Boolean productchecked = false;
                 Boolean subgroupchecked = false;

                //Check Campaign Member match
                if(nbo.RTL_Campaign__c == cm.CampaignId &&
                  nbo.RTL_Customer_Name__c == cm.Customer__c){

                  //Check Product Name
                  if (nbop.RTL_Product__c != null ) {
                    for (integer i = 1; i <= 5; i++) {
                      //find product name in campaign member
                      Id campaignProduct = (id) cm.get('RTL_Campaign_Product_' + i + '__c');
                      string campaignMemberProductName = (campaignProduct !=null)? mapProductName.get(campaignProduct).name : null;

                      if( campaignMemberProductName != null 
                        && nbop.RTL_Product__c.equalsIgnoreCase(campaignMemberProductName)){
                          //check offer result
                          if(cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){
                            statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                            if(statusNBO != null){
                                 nbop.RTL_Status__c = statusNBO;
                                 if(statusNBO.equalsIgnoreCase('Rejected')){
                                    nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO
                                 }else if(statusNBO.equalsIgnoreCase('Pending')){
                                    nbop.RTL_Reject_Reason__c = null;
                                  }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                    nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                                 }

                                changeStatus = true;
                                break;
                            }
                            //offer result is null
                          }else{
                            if(nbop.RTL_Status__c!=null && nbop.RTL_Status__c!='New'){
                              nbop.RTL_Status__c = 'Pending';
                              nbop.RTL_Reject_Reason__c = null;
                              changeStatus = true;
                              break;
                            }
                          }
                      }

                    }
                  }

                  //Check Product Sup Group
                  else if (nbop.RTL_Product_SubGroup__c != null && !changeStatus ) {
                    for (integer i = 1; i <= 5; i++) {
                      string campaignMemberSubGroup = String.valueOf(cm.get('RTL_Sub_Group_' + i + '__c'));
                      if(campaignMemberSubGroup != null 
                        && nbop.RTL_Product_SubGroup__c.equalsIgnoreCase(campaignMemberSubGroup)){

                        //check offer result
                        if(cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){
                          statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                          if(statusNBO != null){
                               nbop.RTL_Status__c = statusNBO;
                               if(statusNBO.equalsIgnoreCase('Rejected')){
                                  nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO
                               }else if(statusNBO.equalsIgnoreCase('Pending')){
                                  nbop.RTL_Reject_Reason__c = null;
                                }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                  nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                               }

                              changeStatus = true;
                              break;
                          }
                          //offer result is null
                        }else{
                            if(nbop.RTL_Status__c!=null && nbop.RTL_Status__c!='New'){
                              nbop.RTL_Status__c = 'Pending';
                              nbop.RTL_Reject_Reason__c = null;
                              changeStatus = true;
                              break;
                            }
                        }

                        
                        
                      }
                    }
                  }

                  //Check Product Group
                  else if (nbop.RTL_Product_Group__c != null && !changeStatus ) {
                    for (integer i = 1; i <= 5; i++) {
                      string campaignMemberProductGroup = String.valueOf(cm.get('RTL_Product_Group_' + i + '__c'));
                      system.debug(campaignMemberProductGroup);
                      if(campaignMemberProductGroup != null 
                        && nbop.RTL_Product_Group__c.equalsIgnoreCase(campaignMemberProductGroup)){

                        //check offer result
                        if(cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){
                          statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                          if(statusNBO != null){
                               nbop.RTL_Status__c = statusNBO;
                               if(statusNBO.equalsIgnoreCase('Rejected')){
                                  nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO 
                               }else if(statusNBO.equalsIgnoreCase('Pending')){
                                  nbop.RTL_Reject_Reason__c = null;
                                }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                  nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                               }

                            changeStatus = true;
                            break;
                          }
                        //offer result is null
                        }else{
                            if(nbop.RTL_Status__c!=null && nbop.RTL_Status__c!='New'){
                              nbop.RTL_Status__c = 'Pending';
                              nbop.RTL_Reject_Reason__c = null;
                              changeStatus = true;
                              break;
                            }
                        } 
                      }
                    }
                  }

                  if(changeStatus){
                    updateNBOProductList.put(nbop.id,nbop);
                  }
                }
              }
            }
        }

        try{
          system.debug('CPM : Update NBO' + updateNBOProductList);
          if(updateNBOProductList.size() > 0){
            update updateNBOProductList.values();
          }
        }catch(exception e){
          system.debug(e);
        }

      }

    }

  }

  public static String checkNBOStatusWithCampaignMember(string s){
      string status = null;

      if(s!=null){
        if(s.equalsIgnoreCase('Interested')){
            status = 'Accepted';
        }else if(s.equalsIgnoreCase('Not Interested')){
            status = 'Rejected';
        }else if(s.equalsIgnoreCase('N/A')){
            status = 'Pending';
        }

      }else{
        status = 'Pending';
      }

    return status;
  }

  public static void updateCampaignSubsidaryChannel(list<campaignMember> listCampMember){
    try{
        System.debug('start');
        List<Id> campaignIdList = new List<Id>();
        for(campaignMember i : listCampMember){
            campaignIdList.add(i.CampaignId);
        }
        Map<Id, Campaign> mapCampSubId = new Map<Id, Campaign>([SELECT Id FROM Campaign WHERE Id IN :campaignIdList AND RTL_Campaign_Channel__c='9 Subsidiary']);
        System.debug(mapCampSubId);
        for(campaignMember cm : listCampMember){
            System.debug(cm.RTL_Channel_Outbound__c);
            System.debug(mapCampSubId.containsKey(cm.CampaignId));

            if(mapCampSubId.containsKey(cm.CampaignId) && cm.RTL_Channel_Outbound__c == true){
                cm.RTL_Channel_Outbound__c = false;
                cm.RTL_Channel_Subsidiary__c = true;
            }
        }
        System.debug('end');
    }catch(exception ex){
        System.debug(ex);
    }
}

}