public with sharing class RTL_NBOHistoryProductTriggerHandler extends TriggerHandler {
    // only do beforeInsert/beforeUpdate validation in trigger if it's not from backend
    // backend insertion/update will be done by apex batch job (RTL_BatchNBOPostProcess)
    public static Id RTL_API_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Retail Integration API Only' LIMIT 1].Id;
    public static Id CURRENT_PROFILE_ID = UserInfo.getProfileId();
    public static String LABEL_CONTACT_W_C = 'Contact (Walk-in/Call-in)';
    private static List<RTL_NBO_History_Product__c> nboHistoryProductListforUpdate = new List<RTL_NBO_History_Product__c>();
    private static List<CampaignMember> updateCampaignmemberList = new List<CampaignMember>();
    private static User usInfo = [ select Id,Name,RTL_Channel__c,Region__c,Zone__c,RTL_Branch__c 
                        from User 
                        where Id = :UserInfo.getUserId() limit 1 ];

    public RTL_NBOHistoryProductTriggerHandler() {
        if (Test.isRunningTest()) {
            this.setMaxLoopCount(100);
        } else {
            this.setMaxLoopCount(1000);
        }

        System.Debug( 'TMB: -> RTL_NBOHistoryProductTriggerHandler Invoked' );
    }

    protected override void beforeInsert(List<SObject> nboHistoryProductList) {
        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler start of beforeInsert');

        preProcessNBOProduct(nboHistoryProductList, false);

        //Check nbo product matching campaign member product
        updateCampaignMemberProduct(nboHistoryProductList,true,false);

        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler end of beforeInsert');
    }

    protected override void beforeUpdate(map<id, sObject> oldMap, map<id, sObject> newMap) {
        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler start of beforeUpdate');

        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        User loggedInUser = [SELECT Id,Name,Region_Code__c ,Zone_Code__c,RTL_Branch_Code__c FROM User WHERE id=:UserInfo.getUserId()];
        for (Id lId:newMap.keySet()){
            RTL_NBO_History_Product__c oldProduct = (RTL_NBO_History_Product__c)oldMap.get(lId);
            RTL_NBO_History_Product__c newProduct = (RTL_NBO_History_Product__c)newMap.get(lId);
           
            // Only validate the product if there is change of product name/group/subgroup
            if (RTL_Utility.toLowerCase(oldProduct.RTL_Product__c) != RTL_Utility.toLowerCase(newProduct.RTL_Product__c)
                    || RTL_Utility.toLowerCase(oldProduct.RTL_Product_Group__c) != RTL_Utility.toLowerCase(newProduct.RTL_Product_Group__c)
                    || RTL_Utility.toLowerCase(oldProduct.RTL_Product_SubGroup__c) != RTL_Utility.toLowerCase(newProduct.RTL_Product_SubGroup__c)) {
                nboHistoryProductList.add(newProduct);
            }
            //If previous status is rejected and change to others , clear the reject reason
            if(oldProduct.RTL_Status__c == 'Rejected' && newProduct.RTL_Status__c != 'Rejected'){
                newProduct.RTL_Reject_Reason__c = '';
            }
        }
        if (nboHistoryProductList.size() > 0) {
            preProcessNBOProduct(nboHistoryProductList, true);
        }

        updateCampaignMemberProduct(nboHistoryProductList,false,true);

       

        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler end of beforeInsert');
    }

    protected override void afterUpdate(map<id, sObject> oldMap, map<id, sObject> newMap) {
        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler start of afterUpdate');

        postProcessNBO(newMap);


        for (Id lId:newMap.keySet()){
            RTL_NBO_History_Product__c newProduct = (RTL_NBO_History_Product__c)newMap.get(lId);
            nboHistoryProductListforUpdate.add(newProduct);

        }

        updateCampaignMemberProduct(nboHistoryProductListforUpdate,false,false);
        


        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler end of afterUpdate');
    }

    protected override void afterInsert(map<id, SObject> newMap) {
        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler start of afterInsert');

        postProcessNBO(newMap);

        System.Debug('TMB: -> RTL_NBOHistoryProductTriggerHandler end of afterInsert');
    }

    private static void preProcessNBOProduct(List<RTL_NBO_History_Product__c> nboHistoryProductList, boolean isUpdate) {
        //if (RTL_API_PROFILE_ID != CURRENT_PROFILE_ID) {
        RTL_Utility.validNBOProduct(nboHistoryProductList, isUpdate);
        //}
    }

    private static void postProcessNBO(map<id, sObject> newMap) {
        RTL_NBO_History_Product__c newProduct = null;
        List<RTL_NBO_History__c> nboToUpdateList = new List<RTL_NBO_History__c>();
        RTL_NBO_History__c nboToUpdate = null;
        Set<Id> nboIdList = new Set<Id>();//get the list of unique NBO Id
        for (Id lId : newMap.keySet()) {
            newProduct = (RTL_NBO_History_Product__c)newMap.get(lId);
            nboIdList.add(newProduct.RTL_Related_NBO__c);
        }

        for (RTL_NBO_History__c nbo : [Select Id from RTL_NBO_History__c where Id in :nboIdList]) {
            if (RTL_API_PROFILE_ID != CURRENT_PROFILE_ID) {//don't update if the update is from customer interaction
                nbo.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now();
            }
            //update if any change to NBO product for purging
            nbo.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
            nboToUpdateList.add(nbo);
        }

        // for any insertion/update of NBO product update NBO RTL_NBO_Product_Latest_Modified_Date__c with latest date, purging purpose
        //Update the list of NBO History
        if (nboToUpdateList.size() > 0) {
            Database.SaveResult[] lsr = Database.update(nboToUpdateList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated NBO History with ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating NBO History. Error Message is: ' + err.getMessage());
                    }
                }
            }
        }
    }


    //Phase2 Campaign
    private static List<RTL_NBO_History_Product__c> updateCampaignMemberProduct(List<RTL_NBO_History_Product__c> nboHistoryProductList,Boolean isInsert,Boolean isBeforeUpdate) {
        system.debug('NBO Product : before update Campaign member product');
        
        List<RTL_NBO_History__c> mapCampaignWithNBO = new List<RTL_NBO_History__c>();
        Map<String,CampaignMember> mapCampaignMember = new Map<String,CampaignMember>();
        Map<Id,RTL_NBO_History_Product__c> mapNBOProduct = new Map<Id,RTL_NBO_History_Product__c>();
        Set<Id> nboIdList = new Set<Id>();//get the list of unique NBO Id
        Set<Id> campaignIdList = new Set<Id>();

        Set<String> campaignCustIdList = new Set<String>();

        Set<String> nboProductNameSet = new Set<String>();
        Map<Id,Campaign> mapCampaignActive =  new Map<Id,Campaign>();


        if(nboHistoryProductList.size() > 0){

            //Set NBO Id
            for(RTL_NBO_History_Product__c nbop : nboHistoryProductList){
                nboIdList.add(nbop.RTL_Related_NBO__c);
                if(nbop.RTL_Product__c!=null){
                    nboProductNameSet.add(nbop.RTL_Product__c);
                }
                mapNBOProduct.put(nbop.id, nbop);
            }

            //Map Campaign Id with NBO
            for (RTL_NBO_History__c nbo : [Select Id, RTL_Campaign__c, RTL_TMB_Customer_ID_PE__c from RTL_NBO_History__c where Id in :nboIdList and RTL_Campaign__c!=null]) {
                mapCampaignWithNBO.add(nbo);
                campaignIdList.add(nbo.RTL_Campaign__c);
                campaignCustIdList.add(nbo.RTL_TMB_Customer_ID_PE__c);
            }

            for(Campaign c : [Select Id, Name, RecordTypeId, Status,Approvedflag__c ,RecordType.DeveloperName
                      FROM Campaign 
                      Where Id in:campaignIdList]){
              mapCampaignActive.put(c.id,c);
            }

            if(mapCampaignWithNBO.size() > 0){

                for(CampaignMember cm : [SELECT Id, LeadId, ContactId,
                                 //Product Group
                                 RTL_Product_Group_1__c,
                                 RTL_Product_Group_2__c,
                                 RTL_Product_Group_3__c,
                                 RTL_Product_Group_4__c,
                                 RTL_Product_Group_5__c,
                                 //Sub group
                                 RTL_Sub_Group_1__c,
                                 RTL_Sub_Group_2__c,
                                 RTL_Sub_Group_3__c,
                                 RTL_Sub_Group_4__c,
                                 RTL_Sub_Group_5__c,
                                 //Product
                                 RTL_Campaign_Product_1__c,
                                 RTL_Campaign_Product_2__c,
                                 RTL_Campaign_Product_3__c,
                                 RTL_Campaign_Product_4__c,
                                 RTL_Campaign_Product_5__c,
                                 RTL_Campaign_Product_1__r.name,
                                 RTL_Campaign_Product_2__r.name,
                                 RTL_Campaign_Product_3__r.name,
                                 RTL_Campaign_Product_4__r.name,
                                 RTL_Campaign_Product_5__r.name,
                                 //offer result
                                 RTL_OfferResult_Product_1__c,
                                 RTL_OfferResult_Product_2__c,
                                 RTL_OfferResult_Product_3__c,
                                 RTL_OfferResult_Product_4__c,
                                 RTL_OfferResult_Product_5__c,
                                 //Reason not interested
                                 RTL_Reason_1__c,
                                 RTL_Reason_2__c,
                                 RTL_Reason_3__c,
                                 RTL_Reason_4__c,
                                 RTL_Reason_5__c,
                                 RTL_TMB_Cust_ID__c,

                                 //Related Opportunity
                                 RTL_RelatedOpportunity_1__c,
                                 RTL_RelatedOpportunity_2__c,
                                 RTL_RelatedOpportunity_3__c,
                                 RTL_RelatedOpportunity_4__c,
                                 RTL_RelatedOpportunity_5__c,

                                 //Contact Session
                                 RTL_Contact_Staff_Name__c,
                                 RTL_Contact_Branch_Team_Name_Code__c,
                                 RTL_Contact_Zone_Group__c,
                                 RTL_Contact_Region_Group_Head__c,
                                 RTL_Contact_Channel__c,
                                 RTL_Contact_Date_Time__c,
                                 RTL_Contact_Status__c,
                                 RTL_Last_Contact_Status__c,

                                 CampaignId
                                 FROM CampaignMember where CampaignId in:campaignIdList 
                                 and RTL_TMB_Cust_ID__c in: campaignCustIdList
                                 ]){
                    mapCampaignMember.put(cm.RTL_TMB_Cust_ID__c,cm);

                }

                //system.debug('NBO : mapCampaignWithNBO : '+mapCampaignWithNBO);
                //system.debug('NBO : mapCampaignMember : '+mapCampaignMember);
                //system.debug('NBO : mapNBOProduct : '+mapNBOProduct);
                //system.debug('NBO : mapCampaignActive : '+mapCampaignActive);

                if(!isInsert){
                    system.debug('NBO : Update status with campaign');



                    if(mapCampaignMember.size() > 0){

                        for(RTL_NBO_History_Product__c nbop : nboHistoryProductList){
                            //Mapping NBO Product and Campaign member
                            for(CampaignMember cm : mapCampaignMember.values()){
                              RTL_NBO_History__c nbo = new RTL_NBO_History__c();
                              string tmbCus = cm.RTL_TMB_Cust_ID__c;
                              Boolean changeStatus = false;

                              //Check TMB Customer match
                              if(tmbCus != null){
                                  for(RTL_NBO_History__c n : mapCampaignWithNBO){
                                      if(tmbCus == n.RTL_TMB_Customer_ID_PE__c && cm.campaignid == n.RTL_Campaign__c){
                                          nbo = n;
                                          break;
                                      }
                                  }

                                  //Check NBO Mapping
                                  if(nbo != null){
                                        if(nbop.RTL_Related_NBO__c == nbo.id){

                                            boolean campaignIsActive = false;

                                            //Check Active Campaign
                                            Campaign camp = mapCampaignActive.get(cm.campaignid);

                                            if(camp!=null){
                                                campaignIsActive = RTL_CampaignMemberUtil.checkActiveCampaign(camp,cm);
                                            }
                                              
                                            if(!campaignIsActive){
                                                nbop.addError(System.Label.RTL_NBO_Campaign_ERR001);
                                                break;
                                            }

                                            //check for skip when before update nbo product
                                            if(!isBeforeUpdate){

                                                //Check Product name
                                                if (nbop.RTL_Product__c != null ) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                        if(cm.get('RTL_Campaign_Product_' + i + '__c')!=null){
                                                            string cmProductName = (String) cm.getSobject('RTL_Campaign_Product_' +i+ '__r').get('Name');
                                                            if(cmProductName != null && nbop.RTL_Product__c.equalsIgnoreCase(cmProductName)){
                                                                if (nbop.RTL_Status__c == 'Accepted' ) {
                                                                    cm.RTL_Contact_Status__c = 'Contact';
                                                                    cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                    cm.put('RTL_Reason_' + i + '__c', null);

                                                                    //stamp related opp when accepted NBO
                                                                    if(nbop.RTL_Opportunity__c !=null){
                                                                        cm.put('RTL_RelatedOpportunity_'+i+'__c',nbop.RTL_Opportunity__c);
                                                                    }

                                                                } else if (nbop.RTL_Status__c == 'Rejected') {
                                                                    cm.RTL_Contact_Status__c = 'Contact';
                                                                    cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                    cm.put('RTL_Reason_' + i + '__c',nbop.RTL_Reject_Reason__c);


                                                                } else if (nbop.RTL_Status__c == 'Pending') {
                                                                    cm.RTL_Contact_Status__c = 'Contact';
                                                                    cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                    cm.put('RTL_Reason_' + i + '__c', null);
                                                                    
                                                                } else if (nbop.RTL_Status__c == 'New'){
                                                                    cm.RTL_Contact_Status__c = 'Contact';
                                                                    cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                    cm.put('RTL_Reason_' + i + '__c', null);
                                                                }

                                                                changeStatus = true;
                                                                break;
                                                            } 
                                                        }
                                                    }
                                                } 

                                                

                                                //Check Product sub group
                                                else if (nbop.RTL_Product_SubGroup__c != null && !changeStatus) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                        string cmProductSubGroup = String.valueOf(cm.get('RTL_Sub_Group_' + i + '__c'));
                                                        if(cmProductSubGroup != null && nbop.RTL_Product_SubGroup__c.equalsIgnoreCase(cmProductSubGroup)){
                                                            if (nbop.RTL_Status__c == 'Accepted' ) {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);

                                                                //stamp related opp when accepted NBO
                                                                if(nbop.RTL_Opportunity__c !=null){
                                                                    cm.put('RTL_RelatedOpportunity_'+i+'__c',nbop.RTL_Opportunity__c);
                                                                }

                                                            } else if (nbop.RTL_Status__c == 'Rejected') {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c',nbop.RTL_Reject_Reason__c);


                                                            } else if (nbop.RTL_Status__c == 'Pending') {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);
                                                                
                                                            } else if (nbop.RTL_Status__c == 'New'){
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);
                                                            }

                                                            changeStatus = true;
                                                            break;
                                                        }
                                                    }

                                                } 


                                                //Check Product group
                                                else if (nbop.RTL_Product_Group__c != null && !changeStatus) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                        string cmProductGroup = String.valueOf(cm.get('RTL_Product_Group_' + i + '__c'));
                                                        if(cmProductGroup != null && nbop.RTL_Product_Group__c.equalsIgnoreCase(cmProductGroup)){
                                                            if (nbop.RTL_Status__c == 'Accepted' ) {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);

                                                                //stamp related opp when accepted NBO
                                                                if(nbop.RTL_Opportunity__c !=null){
                                                                    cm.put('RTL_RelatedOpportunity_'+i+'__c',nbop.RTL_Opportunity__c);
                                                                }

                                                            } else if (nbop.RTL_Status__c == 'Rejected') {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c',nbop.RTL_Reject_Reason__c);


                                                            } else if (nbop.RTL_Status__c == 'Pending') {
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);
                                                                
                                                            } else if (nbop.RTL_Status__c == 'New'){
                                                                cm.RTL_Contact_Status__c = 'Contact';
                                                                cm.put('RTL_OfferResult_Product_' + i + '__c', offerResultStatus(nbop.RTL_Status__c));
                                                                cm.put('RTL_Reason_' + i + '__c', null);
                                                            }

                                                            changeStatus = true;
                                                            break;
                                                        }
                                                    }

                                                } 

                                                if(changeStatus){

                                                    datetime currentDt = datetime.now();
                                                    cm.RTL_Contact_Staff_Name__c = usInfo.id;
                                                    cm.RTL_Contact_Branch_Team_Name_Code__c = usInfo.RTL_Branch__c;
                                                    cm.RTL_Contact_Zone_Group__c = usInfo.Zone__c;
                                                    cm.RTL_Contact_Region_Group_Head__c = usInfo.Region__c;
                                                    cm.RTL_Contact_Channel__c = usInfo.RTL_Channel__c;
                                                    cm.RTL_Contact_Date_Time__c = currentDt;
                                                    cm.RTL_Contact_Status__c = LABEL_CONTACT_W_C;
                                                    cm.RTL_Last_Contact_Status__c = LABEL_CONTACT_W_C+';;'+System.now().format();

                                                    updateCampaignmemberList.add(cm);
                                                }
                                            }

                                        } 

                                    }
                                }
                            }   
                        }

                     //NBO relate campaign but it doesn't have campaign member.   
                    }else{
                        System.debug('NBO : Before Update NBO Check Campaign On Hold.');
                        for(RTL_NBO_History_Product__c nbop : nboHistoryProductList){
                            boolean campaignOnHold = false;
                            Id campid = null;

                            if(nbop.RTL_Related_NBO__c!=null){
                                for(RTL_NBO_History__c n : mapCampaignWithNBO){
                                    if(nbop.RTL_Related_NBO__c == n.id && n.RTL_Campaign__c != null){
                                        campid = n.RTL_Campaign__c;
                                        break;
                                    }
                                }
                                if(campid!=null){
                                    //Check Active Campaign
                                    Campaign camp = mapCampaignActive.get(campid);

                                    if(camp!=null){
                                        if(camp.Status == 'On Hold'){
                                            campaignOnHold = true;
                                        }
                                    }

                                    if(campaignOnHold){
                                        nbop.addError(System.Label.RTL_NBO_Campaign_ERR001);
                                        break;
                                    }
                                }     
                            }
                        }
                    }

                    try {
                        system.debug('NBO : Update Campaigm member : '+updateCampaignmemberList);

                        if(updateCampaignmemberList.size() > 0 && !isBeforeUpdate && TriggerHandler.runOnce()){
                          update updateCampaignmemberList;
                        }
                        

                    } catch (Exception e) {
                        system.debug(e);
                    }
                }else{

                    //check for skip when before update nbo product
                    if(!isBeforeUpdate){

                        //---Assign NBO Product status matching Campaign Member Product---////
                        system.debug('NBO : Before Insert NBO status with campaign');
                        Map<Id,RTL_product_master__c> mapProductName = new Map<Id,RTL_product_master__c>();
                        //Get Product 
                        if(nboProductNameSet.size() > 0){
                          for(RTL_product_master__c p :[select id,name from RTL_product_master__c where name in: nboProductNameSet]){
                            mapProductName.put(p.id, p);
                          }

                        }

                        if(mapCampaignMember.size() > 0){
                           for(RTL_NBO_History_Product__c nbop : nboHistoryProductList){
                                for(CampaignMember cm : mapCampaignMember.values()){

                                    boolean campaignIsActive = false;

                                    //Check Active Campaign
                                    Campaign camp = mapCampaignActive.get(cm.campaignid);
                                    if(camp!=null){
                                        campaignIsActive = RTL_CampaignMemberUtil.checkActiveCampaign(camp,cm);
                                    }
                                      
                                    /*if(!campaignIsActive){
                                        nbop.addError(System.Label.RTL_CampaignMemberEdit_ERR003);
                                        break;
                                    }*/

                                    RTL_NBO_History__c nbo = new RTL_NBO_History__c();
                                    string tmbCus = cm.RTL_TMB_Cust_ID__c;
                                    
                                    //Check TMB Customer match
                                    if(tmbCus != null && campaignIsActive){
                                        for(RTL_NBO_History__c n : mapCampaignWithNBO){
                                            if(tmbCus == n.RTL_TMB_Customer_ID_PE__c  && cm.campaignid == n.RTL_Campaign__c){
                                                nbo = n;
                                                break;
                                            }
                                        }

                                        //Check NBO Mapping
                                        if(nbo != null){
                                       
                                            Boolean changeStatus = false;
                                            string statusNBO = null;

                                            if(nbop.RTL_Related_NBO__c == nbo.id){
                                                
                                                //Check Product Name
                                                if (nbop.RTL_Product__c != null) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                      //find product name in campaign member
                                                      Id campaignProduct = (id) cm.get('RTL_Campaign_Product_' + i + '__c');
                                                      string campaignMemberProductName = (campaignProduct !=null && mapProductName.get(campaignProduct)!=null)? mapProductName.get(campaignProduct).name : null;
                                                      if( campaignMemberProductName != null 
                                                        && nbop.RTL_Product__c.equalsIgnoreCase(campaignMemberProductName) 
                                                        && cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){
                                                        statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                                                        if(statusNBO != null){
                                                             nbop.RTL_Status__c = statusNBO;
                                                             if(statusNBO.equalsIgnoreCase('Rejected')){
                                                                nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO
                                                             }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                                                nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                                                             }

                                                            changeStatus = true;
                                                            break;
                                                        }
                                                      }
                                                    }
                                                }

                                                //Check Product Sup Group
                                                 else if (nbop.RTL_Product_SubGroup__c != null && !changeStatus) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                      string campaignMemberSubGroup = String.valueOf(cm.get('RTL_Sub_Group_' + i + '__c'));
                                                      if(campaignMemberSubGroup != null 
                                                        && nbop.RTL_Product_SubGroup__c.equalsIgnoreCase(campaignMemberSubGroup)
                                                        && cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){

                                                        statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                                                        if(statusNBO != null){
                                                             nbop.RTL_Status__c = statusNBO;
                                                             if(statusNBO.equalsIgnoreCase('Rejected')){
                                                                nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO
                                                             }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                                                nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                                                             }

                                                            changeStatus = true;
                                                            break;
                                                        }
                                                        
                                                      }
                                                    }
                                                }

                                                

                                                //Check Product group
                                                else if (nbop.RTL_Product_Group__c != null  && !changeStatus) {
                                                    for (integer i = 1; i <= 5; i++) {
                                                        string cmProductGroup = String.valueOf(cm.get('RTL_Product_Group_' + i + '__c'));
                                                        if(cmProductGroup != null 
                                                            && nbop.RTL_Product_Group__c.equalsIgnoreCase(cmProductGroup)
                                                            && cm.get('RTL_OfferResult_Product_' + i + '__c') !=null){
                                                            statusNBO = checkNBOStatusWithCampaignMember(String.valueOf(cm.get('RTL_OfferResult_Product_' + i + '__c')));
                                                            if(statusNBO != null){
                                                                 nbop.RTL_Status__c = statusNBO;
                                                                 if(statusNBO.equalsIgnoreCase('Rejected')){
                                                                    nbop.RTL_Reject_Reason__c = String.valueOf(cm.get('RTL_Reason_' + i + '__c'));//Map reason NBO 
                                                                 }else if(statusNBO.equalsIgnoreCase('Accepted')){
                                                                    nbop.RTL_Opportunity__c = (id) cm.get('RTL_RelatedOpportunity_' + i + '__c');
                                                                 }

                                                                changeStatus = true;
                                                                break;
                                                            }

                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return nboHistoryProductList;
    }

    public static String offerResultStatus(string s){
        string status = null;
        if(s!=null){
            if(s.equalsIgnoreCase('Accepted')){
                status = 'Interested';
            }else if(s.equalsIgnoreCase('Rejected')){
                status = 'Not Interested';
            }else if(s.equalsIgnoreCase('Pending')){
                status = null;
            }else if(s.equalsIgnoreCase('New')){
                status = null;
            }
        }

        return status;
    } 
    public static String checkNBOStatusWithCampaignMember(string s){
          string status = null;

          if(s!=null){
            if(s.equalsIgnoreCase('Interested')){
                status = 'Accepted';
            }else if(s.equalsIgnoreCase('Not Interested')){
                status = 'Rejected';
            }/*else if(s.equalsIgnoreCase('N/A')){
                status = 'New';
            }*/

          }else{
            status = 'Pending';
          }

        return status;
    }


    //End Phase2 Campaign
}