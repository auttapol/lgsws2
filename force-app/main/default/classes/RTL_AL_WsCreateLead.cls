@RestResource(urlMapping='/data/V1.0/sobjects/Lead/*')
global without sharing class RTL_AL_WsCreateLead extends RTL_AL_WebserviceAbstract {
    
    public RTL_AL_WsCreateLead() {}

    private static Map<Id, RTL_Lead_Assignment_Rule__c>  leadAssignmentRule {
        get{
            if(leadAssignmentRule == null){
                leadAssignmentRule = new Map<Id, RTL_Lead_Assignment_Rule__c>([SELECT Id, Name, RTL_Active_Flag__c, RTL_Priority__c, RTL_Lead_Record_Type__c, RTL_Integration_Type__c, RTL_Lead_Field_Criteria_1__c, RTL_Lead_Field_Criteria_2__c, RTL_Lead_Field_Criteria_3__c, RTL_Lead_Field_Criteria_4__c, RTL_Lead_Field_Criteria_5__c, RTL_Lead_Field_Value_1__c, RTL_Lead_Field_Value_2__c, RTL_Lead_Field_Value_3__c, RTL_Lead_Field_Value_4__c, RTL_Lead_Field_Value_5__c, RTL_Assigned_User__c, RTL_Assigned_User_field__c, RTL_Assigned_Queue_Name__c, RTL_Branch_and_Zone_Queue_User_field__c, RTL_Default_Queue_Name__c, RTL_Default_User__c, RTL_IsAssign_Campaign__c, RTL_Assigned_Apex__c, RTL_IsInsertProduct__c FROM RTL_Lead_Assignment_Rule__c WHERE RTL_Active_Flag__c = true ORDER BY RTL_Priority__c]);
            }
            return leadAssignmentRule;
        }
        set{}
    }

    @HttpPost
    global static SCSReqRes httpPostWebservice() {
        Savepoint sp;
        Map<String, String> requestHeader = RestContext.request.headers;
        RestRequest request = RestContext.request;
        Datetime startDate = Datetime.now();
        Lead dropLeadO2O;

        /* Additional get key specific from request */
        String encryptKey = '';
        try {
            encryptKey = getKeyFromSystem(request);
        } catch (WebserviceAbstract.MissingHeaderException e) {
        	encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
        }
        // String encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
        
        String requestBodyDecrypt;
        try {
            sp = Database.setSavepoint();
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
            // if(requestHeader.containsKey('For-Test') ? requestHeader.get('For-Test') == 'DEV' : false) {
            //     requestBodyDecrypt = request.requestBody.toString();
            // }
            dropLeadO2O = !checkIsEmpty(requestBodyDecrypt) ? (Lead)JSON.deserialize(requestBodyDecrypt, Lead.class) : new Lead();
            Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
            List<String> fieldsMissing = new List<String>();
            for (String fieldRequired : new List<String>{ 
                'FirstName',
                'LastName',
                'RTL_Mobile_Number__c',
                'RTL_Product_Name__c',
                'RTL_TMB_Campaign_Source__c',
                'RTL_Customer_Segment__c',
                'RTL_Contact_Method__c',
                // 'RTL_TMB_Campaign_Reference__c',
                'LeadSource',
                'RecordTypeId'
            }) {
                if(checkIsEmpty(dropLeadO2O.get(fieldRequired)) && sObjectField.containsKey(fieldRequired)) {
                    Schema.DescribeFieldResult dfr = sObjectField.get(fieldRequired).getDescribe();
                    String fieldNameAPI = dfr.getName();
                    fieldsMissing.add(String.format('{0}', new List<Object>{ fieldNameAPI }));
                }
            }

            Response response;
            Boolean isSuccess = fieldsMissing.size() == 0;
            System.debug('testdebug');
            System.debug(fieldsMissing);
            System.debug('isSuccess -> ' + isSuccess);
            System.debug('requestBodyDecrypt -> ' + requestBodyDecrypt);
            if(isSuccess){
                /**
                 * AL Ingretaion Phase 2 - checking marketgin code in campaign member for update existing
                 */
                CampaignMember campaignMemberTouch;
                String marketingCode = (String)AbstractCoreClass.getResult('RTL_Marketing_Code__c', JSON.deserializeUntyped(requestBodyDecrypt));
                System.debug('marketingCode -->' + marketingCode);
                if(!checkIsEmpty(marketingCode)) {
                    List<CampaignMember> campaigns = [SELECT Id, RTL_Marketing_Code__c, Name, Customer__c, RTL_TMB_Cust_ID__c,
                        Campaign.Name, LeadOrContactOwner.Name, LeadId, RTL_AL_response__c,
                        RTL_CampHis_Phone__c, RTL_Register_Date__c, 
                        RTL_AL_car_brand__c, RTL_AL_car_subtype__c, RTL_AL_car_year__c, RTL_AL_car_plate_no__c, 
                        RTL_AL_max_set_up_amount__c, RTL_AL_CAMP_EXP_DTE__c, RTL_AL_wanted_amount__c, 
                        RTL_AL_installment_periods__c, RTL_AL_installment_amount__c,
                        RTL_OfferResult_Product_1__c, RTL_OfferResult_Product_2__c, RTL_OfferResult_Product_3__c, RTL_OfferResult_Product_4__c, RTL_OfferResult_Product_5__c,
                        RTL_RelatedOpportunity_1__c, RTL_RelatedOpportunity_2__c, RTL_RelatedOpportunity_3__c, RTL_RelatedOpportunity_4__c, RTL_RelatedOpportunity_5__c,
                        RTL_Contact_Staff_Name__r.Name,RTL_Assigned_Agent__r.Name,RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Name,
                        RTL_AL_contact_channel__c,RTL_AL_Interested_Rate__c,RTL_AL_car_gear__c,RTL_AL_car_group__c,RTL_AL_car_type__c,RTL_AL_normal_price__c,
                        RTL_AL_ILA_AMT__c,RTL_AL_REMN_MTH__c,RTL_AL_OFFR_ILA_AMT__c,RTL_AL_OFFR_ILA_MTH__c,RTL_AL_promotion_detail__c,RTL_Contact_Method__c,LeadSource,
                        RTL_Customer_Segment__c,RTL_TMB_Campaign_Source__c,RTL_Medium__c, RTL_W2L_Campaign_Name__c, RTL_W2L_Term__c, RTL_W2L_Content__c, RTL_Media_Source__c, RTL_Consent__c,
                        // Notification to ...
                        RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Email, RTL_Assigned_Agent__r.Email,RTL_Contact_Staff_Name__r.Email,createReferDate__c,RTL_Integration_System__c
                        FROM CampaignMember 
                        WHERE RTL_Marketing_Code__c = :marketingCode];

                    //System.debug(campaigns.get(0));

                    campaignMemberTouch = campaigns.size() > 0 ? campaigns.get(0) : null;
                    response = responseMsg(
                        campaignMemberTouch != null, 
                        campaignMemberTouch != null ? new List<ErrorDetail>{} : new List<ErrorDetail>{
                            new ErrorDetail(
                                'NOT_FOUND', 
                                'Marketing code dose not found'
                            )
                        }, 
                        (Id)campaignMemberTouch?.Id
                    );
                }
                System.debug('response -->' + response);
                if(checkIsEmpty(marketingCode)) {
                    if(isSuccess) {
                        System.debug('Remark -->' + dropLeadO2O.RTL_Remark__c);
                        dropLeadO2O.RTL_Integration_System__c = requestHeader.get('Integration-System');
                        insert dropLeadO2O;
                        System.debug('testdrop' + dropLeadO2O);
                        
                        List<CampaignMember> listcm = [SELECT Id, RTL_Marketing_Code__c, Name, Customer__c, RTL_TMB_Cust_ID__c,
                        Campaign.Name, LeadOrContactOwner.Name, RTL_AL_response__c,
                        RTL_CampHis_Phone__c, RTL_Register_Date__c, 
                        RTL_AL_car_brand__c, RTL_AL_car_subtype__c, RTL_AL_car_year__c, RTL_AL_car_plate_no__c, 
                        RTL_AL_max_set_up_amount__c, RTL_AL_CAMP_EXP_DTE__c, RTL_AL_wanted_amount__c, 
                        RTL_AL_installment_periods__c, RTL_AL_installment_amount__c,
                        RTL_Contact_Staff_Name__r.Name,RTL_Assigned_Agent__r.Name,RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Name,RTL_Medium__c, RTL_W2L_Campaign_Name__c, RTL_W2L_Term__c, RTL_W2L_Content__c, RTL_Media_Source__c, RTL_Consent__c,
                        RTL_AL_ContactProvince__c,RTL_AL_ContactDistrict__c,RTL_AL_ContactSubDistrict__c,RTL_AL_ContactZipcode__c,
                        // Notification to ...
                        RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Email, RTL_Assigned_Agent__r.Email, RTL_Contact_Staff_Name__r.Email,RTL_Integration_System__c
                        FROM CampaignMember 
                        WHERE LeadId = :dropLeadO2O.Id LIMIT 1];
                        if(listcm.size() > 0){
                            campaignMemberTouch = listcm[0];
                        }
                        System.debug(campaignMemberTouch);

                    }
                    response = responseMsg(
                        isSuccess, 
                        isSuccess ? new List<ErrorDetail>{} : new List<ErrorDetail>{
                            new ErrorDetail(
                                'REQUIRED_FIELD_MISSING', 
                                String.format('Required fields are missing => [{0}]', new List<String>{ String.join(fieldsMissing, ', ') })
                            )
                        }, 
                        (Id)dropLeadO2O.get('Id')
                    );
                }  
                // > If Touch send marketing code to CRM Salesforce then the system found data in campaign member.
                else if(campaignMemberTouch != null) { 
                    campaignMemberTouch.RTL_AL_response__c = dropLeadO2O.RTL_AL_response__c;										            
                    if(campaignMemberTouch.RTL_OfferResult_Product_1__c == 'Not Interested') {
                        campaignMemberTouch.RTL_OfferResult_Product_1__c = null;
                        campaignMemberTouch.RTL_Reason_1__c = null;
                    }
                    if(campaignMemberTouch.RTL_OfferResult_Product_2__c == 'Not Interested') {
                        campaignMemberTouch.RTL_OfferResult_Product_2__c = null;
                        campaignMemberTouch.RTL_Reason_2__c = null;
                    }
                    if(campaignMemberTouch.RTL_OfferResult_Product_3__c == 'Not Interested') {
                        campaignMemberTouch.RTL_OfferResult_Product_3__c = null;
                        campaignMemberTouch.RTL_Reason_3__c = null;
                    }
                    if(campaignMemberTouch.RTL_OfferResult_Product_4__c == 'Not Interested') {
                        campaignMemberTouch.RTL_OfferResult_Product_4__c = null;
                        campaignMemberTouch.RTL_Reason_4__c = null;
                    }
                    if(campaignMemberTouch.RTL_OfferResult_Product_5__c == 'Not Interested') {
                        campaignMemberTouch.RTL_OfferResult_Product_5__c = null;
                        campaignMemberTouch.RTL_Reason_5__c = null;
                    }
                    //update AL Instant loan FR004
                    campaignMemberTouch.RTL_Consent__c =  dropLeadO2O.RTL_Consent__c ;
                    campaignMemberTouch.RTL_Media_Source__c =  dropLeadO2O.RTL_Media_Source__c ;
                    campaignMemberTouch.RTL_Medium__c =  dropLeadO2O.RTL_Medium__c ;
                    campaignMemberTouch.RTL_W2L_Campaign_Name__c =  dropLeadO2O.RTL_W2L_Campaign_Name__c ;
                    campaignMemberTouch.RTL_W2L_Content__c =  dropLeadO2O.RTL_W2L_Content__c ;
                    campaignMemberTouch.RTL_W2L_Term__c =  dropLeadO2O.RTL_W2L_Term__c ;
                    campaignMemberTouch.RTL_Market_Conduct__c = dropLeadO2O.RTL_Market_Conduct__c;
                    campaignMemberTouch.RTL_PDPA__c = dropLeadO2O.RTL_PDPA__c;
                    campaignMemberTouch.RTL_TC__c = dropLeadO2O.RTL_TC__c;
                    campaignMemberTouch.LGS_Partner__c = dropLeadO2O.LGS_Partner__c;
                    campaignMemberTouch.LGS_Lead_Received_Time__c = dropLeadO2O.LGS_Lead_Received_Time__c;
                    campaignMemberTouch.LGS_Assign_Rule__c = dropLeadO2O.LGS_Assign_Rule__c;
                    campaignMemberTouch.LGS_Car_Brand_Showroom_ID__c = dropLeadO2O.LGS_Car_Brand_Showroom_ID__c;
                    campaignMemberTouch.LGS_Dealer_Showroom_ID__c = dropLeadO2O.LGS_Dealer_Showroom_ID__c;
                    campaignMemberTouch.LGS_001__c = dropLeadO2O.LGS_001__c;
                    campaignMemberTouch.LGS_002__c = dropLeadO2O.LGS_002__c;
                    campaignMemberTouch.LGS_003__c = dropLeadO2O.LGS_003__c;
                    campaignMemberTouch.LGS_004__c = dropLeadO2O.LGS_004__c;
                    campaignMemberTouch.LGS_005__c = dropLeadO2O.LGS_005__c;
                    campaignMemberTouch.LGS_006__c = dropLeadO2O.LGS_006__c;
                    campaignMemberTouch.LGS_007__c = dropLeadO2O.LGS_007__c;
                    campaignMemberTouch.LGS_008__c = dropLeadO2O.LGS_008__c;
                    campaignMemberTouch.LGS_009__c = dropLeadO2O.LGS_009__c;
                    campaignMemberTouch.LGS_010__c = dropLeadO2O.LGS_010__c;
                    campaignMemberTouch.LGS_011__c = dropLeadO2O.LGS_011__c;
                    campaignMemberTouch.LGS_012__c = dropLeadO2O.LGS_012__c;
                    campaignMemberTouch.LGS_013__c = dropLeadO2O.LGS_013__c;
                    campaignMemberTouch.LGS_014__c = dropLeadO2O.LGS_014__c;
                    campaignMemberTouch.LGS_015__c = dropLeadO2O.LGS_015__c;
                    campaignMemberTouch.LGS_016__c = dropLeadO2O.LGS_016__c;
                    campaignMemberTouch.LGS_017__c = dropLeadO2O.LGS_017__c;
                    campaignMemberTouch.LGS_018__c = dropLeadO2O.LGS_018__c;
                    campaignMemberTouch.LGS_019__c = dropLeadO2O.LGS_019__c;
                    campaignMemberTouch.LGS_020__c = dropLeadO2O.LGS_020__c;
                    //stamp value from Touch into field in Campaign member
                    campaignMemberTouch.RTL_AL_contact_channel__c =  dropLeadO2O.RTL_AL_contact_channel__c ;          
                    campaignMemberTouch.RTL_AL_Interested_Rate__c =  dropLeadO2O.RTL_AL_Interested_Rate__c ;            
                    campaignMemberTouch.RTL_AL_car_brand__c =  dropLeadO2O.RTL_AL_car_brand__c ;              
                    campaignMemberTouch.RTL_AL_car_gear__c =  dropLeadO2O.RTL_AL_car_gear__c ;               
                    campaignMemberTouch.RTL_AL_car_group__c =  dropLeadO2O.RTL_AL_car_group__c ;              
                    campaignMemberTouch.RTL_AL_car_subtype__c =  dropLeadO2O.RTL_AL_car_subtype__c ;            
                    campaignMemberTouch.RTL_AL_car_type__c =  dropLeadO2O.RTL_AL_car_type__c ;              
                    campaignMemberTouch.RTL_AL_car_year__c =  dropLeadO2O.RTL_AL_car_year__c ;              
                    campaignMemberTouch.RTL_AL_car_plate_no__c =  dropLeadO2O.RTL_AL_car_plate_no__c ;               
                    campaignMemberTouch.RTL_AL_max_set_up_amount__c =  dropLeadO2O.RTL_AL_max_set_up_amount__c ;               
                    campaignMemberTouch.RTL_AL_normal_price__c =  dropLeadO2O.RTL_AL_normal_price__c ;               
                    campaignMemberTouch.RTL_AL_wanted_amount__c =  dropLeadO2O.RTL_AL_wanted_amount__c ;              
                    campaignMemberTouch.RTL_AL_installment_periods__c =  dropLeadO2O.RTL_AL_installment_periods__c ;            
                    campaignMemberTouch.RTL_AL_installment_amount__c =  dropLeadO2O.RTL_AL_installment_amount__c ;             
                    campaignMemberTouch.RTL_AL_ILA_AMT__c =  dropLeadO2O.RTL_AL_ILA_AMT__c ;            
                    campaignMemberTouch.RTL_AL_REMN_MTH__c =  dropLeadO2O.RTL_AL_REMN_MTH__c ;               
                    campaignMemberTouch.RTL_AL_OFFR_ILA_AMT__c =  dropLeadO2O.RTL_AL_OFFR_ILA_AMT__c ;               
                    campaignMemberTouch.RTL_AL_OFFR_ILA_MTH__c =  dropLeadO2O.RTL_AL_OFFR_ILA_MTH__c ;               
                    campaignMemberTouch.RTL_AL_promotion_detail__c =  dropLeadO2O.RTL_AL_promotion_detail__c ;               
                    campaignMemberTouch.RTL_AL_CAMP_EXP_DTE__c =  dropLeadO2O.RTL_AL_CAMP_EXP_DTE__c ;              
                    campaignMemberTouch.RTL_Contact_Method__c =  dropLeadO2O.RTL_Contact_Method__c ;       
                    //Contact Address to campaignmember
                    campaignMemberTouch.RTL_AL_ContactProvince__c =  dropLeadO2O.RTL_AL_ContactProvince__c;
                    campaignMemberTouch.RTL_AL_ContactDistrict__c =  dropLeadO2O.RTL_AL_ContactDistrict__c;
                    campaignMemberTouch.RTL_AL_ContactSubDistrict__c =  dropLeadO2O.RTL_AL_ContactSubDistrict__c;
                    campaignMemberTouch.RTL_AL_ContactZipcode__c =  dropLeadO2O.RTL_AL_ContactZipcode__c; 
                    //campaignMemberTouch.LeadSource =  dropLeadO2O.LeadSource ;             
                    campaignMemberTouch.RTL_Lead_Group__c =  dropLeadO2O.RTL_Customer_Segment__c ;             
                    campaignMemberTouch.RTL_TMB_Campaign_Source__c =  dropLeadO2O.RTL_TMB_Campaign_Source__c ;
                    
                    campaignMemberTouch.RTL_CampHis_Phone__c =  dropLeadO2O.RTL_Mobile_Number__c ;
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(requestBodyDecrypt);
            
                    campaignMemberTouch.RTL_AL_comment__c = dropLeadO2O.RTL_AL_comment__c;
                    campaignMemberTouch.RTL_AL_oa_ref_code__c = dropLeadO2O.RTL_AL_oa_ref_code__c;
                    campaignMemberTouch.RTL_AL_Showroom__c = String.valueOf(jsonMap.get('RTL_AL_Showroom__c'));
                    campaignMemberTouch.RTL_AL_TentName__c = String.valueOf(jsonMap.get('RTL_AL_TentName__c'));
                    campaignMemberTouch.RTL_AL_car_bought_from__c = dropLeadO2O.RTL_AL_car_bought_from__c;
                    campaignMemberTouch.RTL_AL_available_time__c = dropLeadO2O.RTL_AL_available_time__c;
                    //LGS
                    campaignMemberTouch.Scoring_Condition_Id__c = dropLeadO2O.Scoring_Condition_Id__c;
                    campaignMemberTouch.RTL_Integration_System__c = requestHeader.get('Integration-System');
                    campaignMemberTouch.RTL_Partner_Branch_Code__c = dropLeadO2O.RTL_Partner_Branch_Code__c;
                    campaignMemberTouch.RTL_Partner_Employee_Code__c = dropLeadO2O.RTL_Partner_Employee_Code__c;
                    campaignMemberTouch.LGS_Assignment_Code__c = dropLeadO2O.LGS_Assignment_Code__c;
                    campaignMemberTouch.LGS_BrandCode__c = dropLeadO2O.LGS_BrandCode__c;
                    campaignMemberTouch.LGS_BrandShowroomCode__c = dropLeadO2O.LGS_BrandShowroomCode__c;
                    campaignMemberTouch.LGS_PartnerCode__c = dropLeadO2O.LGS_PartnerCode__c;
                    campaignMemberTouch.LGS_LinkInfo__c = dropLeadO2O.LGS_LinkInfo__c;
                    campaignMemberTouch.LGS_File_Upload__c = dropLeadO2O.LGS_File_Upload__c;
                    campaignMemberTouch.Partner_Lead_ID__c = dropLeadO2O.Partner_Lead_ID__c;
                    campaignMemberTouch.LGS_Child_Campaign_ID__c = dropLeadO2O.LGS_Child_Campaign_ID__c;
                    campaignMemberTouch.Car_Reference_No__c = dropLeadO2O.Car_Reference_No__c;
                    campaignMemberTouch.LGS_VIN_No__c = dropLeadO2O.LGS_VIN_No__c;
                    campaignMemberTouch.RTL_AL_DownAmt__c = dropLeadO2O.RTL_AL_DownAmt__c;
                    campaignMemberTouch.RTL_AL_DownPercent__c = dropLeadO2O.RTL_AL_DownPercent__c;
                    campaignMemberTouch.LGS_Campaign_Start_Date__c = dropLeadO2O.LGS_Campaign_Start_Date__c;
                    campaignMemberTouch.LGS_Campaign_End_Date__c = dropLeadO2O.LGS_Campaign_End_Date__c;
                    campaignMemberTouch.RTL_AL_PayPerMonth__c = dropLeadO2O.RTL_AL_PayPerMonth__c;
                    campaignMemberTouch.RTL_AL_IsCarBooked__c = dropLeadO2O.RTL_AL_IsCarBooked__c;
                    campaignMemberTouch.RTL_AL_province_car_plate_no__c = dropLeadO2O.RTL_AL_province_car_plate_no__c;
                    
                    //stamp value into field Remark in Campaign member.					
                    //Value: Line2 1= 'ลูกค้าระบุวงเงินที่ต้องการ' + RTL_AL_wanted_amount__c + 'ระยะเวลาผ่อน (งวด)' + RTL_AL_installment_periods__c + 'ประมาณค่างวด' + RTL_AL_installment_amount__c
                    if(campaignMemberTouch.RTL_TMB_Campaign_Source__c == 'Touch'){
                        campaignMemberTouch.RTL_Remark__c = 'ลูกค้าระบุวงเงินที่ต้องการ ' + campaignMemberTouch.RTL_AL_wanted_amount__c + ' ระยะเวลาผ่อน (งวด) ' + campaignMemberTouch.RTL_AL_installment_periods__c + ' ประมาณค่างวด ' + campaignMemberTouch.RTL_AL_installment_amount__c ;
                    }
                    campaignMemberTouch.WS_Stamp_Date__c = Datetime.now();
                    System.debug(campaignMemberTouch);	
                    if(campaignMemberTouch.RTL_Contact_Method__c == 'AL Sales')
                    {                  
                        if(campaignMemberTouch.createReferDate__c == null){
                            campaignMemberTouch.createReferDate__c = Datetime.now();
                        }
                    }
    
                    update campaignMemberTouch;

                    // LGSWS2
                    
                    List <Lead> newlist = new List<Lead>{dropLeadO2O};
                    Map<Id,String> mapLeadwithIntegrationtype = new Map<Id,String>();
                    LeadAssignmentUtil.assignLeadOwnerByLeadAssignmentrule(newlist);
                    System.debug('Debug11 dropLeadO2O:'+dropLeadO2O.RTL_Lead_Assigned_By_Rule__c);
                    System.debug('Debug11 dropLeadO2O id:'+dropLeadO2O.Id);
                    System.debug('Debug11 dropLeadO2O:'+newlist[0].RTL_Lead_Assigned_By_Rule__c);
                    RTL_Lead_Assignment_Rule__c rule = leadAssignmentRule.containsKey(dropLeadO2O.RTL_Lead_Assigned_By_Rule__c) ? leadAssignmentRule.get(dropLeadO2O.RTL_Lead_Assigned_By_Rule__c) : null;
                    System.debug('Debug11 rule:'+rule);
                    System.debug('Debug11 rule.RTL_Integration_Type__c:'+rule.RTL_Integration_Type__c);
                    if(rule != null && rule.RTL_Integration_Type__c != null && rule.RTL_Integration_Type__c != 'Cisco' && rule.RTL_Integration_Type__c != 'Avaya') {
                        mapLeadwithIntegrationtype.put(dropLeadO2O.Id, rule.RTL_Integration_Type__c);
                    }

                    if(mapLeadwithIntegrationtype.size() > 0){
                        List<CampaignMember> campaignlist = new List<CampaignMember>{campaignMemberTouch};
                        RTL_LeadDistribution.mappingleadDistribution(campaignlist,mapLeadwithIntegrationtype);
                    }
                    // System.debug('campaignMemberTouch.RTL_Contact_Method__c'+campaignMemberTouch.RTL_Contact_Method__c);	
                    // if(campaignMemberTouch.RTL_Contact_Method__c == 'AL Sales')
                    // {                  
                    //     RTL_AL_CampaignMemberToAL.sendCampaignMemberToAL(new List<CampaignMember>{campaignMemberTouch});
                    // }
                    
                }

                /**
                 * AL Integration Phase 2
                 * Checking if system send marketing code in body request
                 */
                if((campaignMemberTouch != null && dropLeadO2O.Id != null) && campaignMemberTouch.RTL_AL_response__c && campaignMemberTouch.RTL_Contact_Method__c != 'AL Sales') {
                    System.debug('Email -->' + JSON.serializePretty(campaignMemberTouch));
                    RTL_AL_NotificationToOwner noti = new RTL_AL_NotificationToOwner(campaignMemberTouch);
                    noti.run();
                }
                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess,
                    '', // customerName
                    isSuccess ? '' : response.getErrorMessage(),
                    //requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', 
                    requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', // msLogId
                    UserInfo.getName(),
                    '',
                    String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                        request.httpMethod, request.resourcePath
                    }) : getServiceName(SERVICENAME.CreateLEAD),
                    AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
                    JSON.serializePretty(response), // Response Body
                    null,
                    startDate,
                    Datetime.now() // End datetime
                );
                return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));
            }else{
                response = responseMsg(
                    isSuccess, 
                    isSuccess ? new List<ErrorDetail>{} : new List<ErrorDetail>{
                        new ErrorDetail(
                            'REQUIRED_FIELD_MISSING', 
                            String.format('Required fields are missing => [{0}]', new List<String>{ String.join(fieldsMissing, ', ') })
                        )
                    }, 
                    (Id)dropLeadO2O.get('Id')
                );
                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess,
                    '', // customerName
                    isSuccess ? '' : response.getErrorMessage(),
                    //requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '',
                    requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', // msLogId
                    UserInfo.getName(),
                    '',
                    String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                        request.httpMethod, request.resourcePath
                    }) : getServiceName(SERVICENAME.CreateLEAD),
                    AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
                    JSON.serializePretty(response), // Response Body
                    null,
                    startDate,
                    Datetime.now() // End datetime
                );
                return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));
            }

        } catch (DmlException e) {
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            Response response = responseMsg(false, new List<ErrorDetail>{ 
                new ErrorDetail(e.getDmlStatusCode(0), errorMsg)
            }, null);
            
            System.debug('Error message --> ' + e.getMessage() + ' Line:' +e.getLineNumber());
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                errorMsg,
                //requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '',
                requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', // msLogId
                UserInfo.getName(),
                '',
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.CreateLEAD),
                AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));
        } catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = getErrorMessageException(e);
            System.debug('Error message --> ' + e.getMessage() + ' Line:' +e.getLineNumber());
            Response response = responseMsg(false, new List<ErrorDetail>{ 
                new ErrorDetail(e.getTypeName(), errorMsg)
            }, null);
            
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                errorMsg,
                //requestHeader.containsKey('Request-UID') ? requestHeader.get('Request-UID') : '', 
                requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '', // msLogId
                UserInfo.getName(),
                '',
                String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{
                    request.httpMethod, request.resourcePath
                }) : getServiceName(SERVICENAME.CreateLEAD),
                AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
                JSON.serializePretty(response), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));
        }
    }
}