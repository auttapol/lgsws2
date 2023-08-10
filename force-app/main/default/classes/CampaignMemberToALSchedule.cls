public with sharing class CampaignMemberToALSchedule implements Schedulable {
    public CampaignMemberToALSchedule() {

    }

    public void execute(SchedulableContext SC){

        
        System.debug('Datetime.now() --> ' + Datetime.now());

        List<Campaignmember> listCampaign = [SELECT Id FROM Campaignmember WHERE RTL_Contact_Method__c =: 'AL Sales' AND RTL_Is_Interface_Success__c =: false 
                                            AND RTL_Is_Send_To_HPAP__c  =: false AND createReferDate__c != null AND createReferDate__c >= :Datetime.now().addDays(-7)];

        List<String> campaignId = new List<String>();
        if(listCampaign.size() > 0){
            for(Campaignmember cm : listCampaign){
                
                campaignId.add(cm.Id);
            }
        }
        System.debug('campaignId-->' + campaignId.size());

        if (!campaignId.isEmpty()) {
            System.debug('campaignId-->' + campaignId);
            String idString = '(\''+String.join(new List<String>(campaignId), '\',\'')+'\')';
            
            String query = 'SELECT Id,RTL_Campaign_Product_1__c,RTL_Campaign_Product_1__r.Name,RTL_AL_oa_ref_code__c, CampaignId, Campaign.Name,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c, LeadSource, RTL_Product_Name__c, RTL_AL_car_type__c, RTL_AL_car_brand__c, RTL_AL_car_group__c'+
                ',RTL_AL_car_subtype__c, RTL_AL_car_gear__c, RTL_AL_car_year__c, RTL_AL_wanted_amount__c, RTL_AL_max_set_up_amount__c,RTL_AL_normal_price__c '+
                ', RTL_AL_installment_periods__c, RTL_AL_PayPerMonth__c, RTL_AL_DownPercent__c, RTL_AL_DownAmt__c, RTL_AL_installment_amount__c, RTL_AL_available_time__c'+
                ',RTL_AL_ContactZipcode__c, RTL_AL_ContactProvince__c, RTL_AL_ContactDistrict__c, RTL_AL_ContactSubDistrict__c, RTL_AL_contact_channel__c, RTL_AL_IsCarBooked__c'+
                ', RTL_AL_car_bought_from__c, RTL_AL_TentName__c, RTL_Branch_Code__c, RTL_AL_car_plate_no__c, RTL_AL_province_car_plate_no__c, RTL_AL_Showroom__c, LeadId, Lead.RTL_ID_Type__c, Lead.RTL_Citizen_Id__c, Lead.FirstName, Lead.LastName'+
                ', Customer__c, Customer__r.ID_Number_PE__c, Customer__r.ID_Type_PE__c, Customer__r.First_name_PE__c, Customer__r.Last_name_PE__c, Customer__r.Mobile_Number_PE__c,Customer__r.Email_Address_PE__c, RTL_CampHis_Phone__c '+
                ', Customer__r.TMB_Customer_ID_PE__c, RTL_AL_comment__c, LGS_Partner__c, LGS_Lead_Received_Time__c '+
                ', RTL_AL_Interested_Rate__c, LGS_001__c, LGS_002__c, LGS_003__c, LGS_004__c, LGS_005__c, LGS_006__c, LGS_007__c, LGS_008__c, LGS_009__c, LGS_010__c '+
                ', LGS_011__c, LGS_012__c, LGS_013__c, LGS_014__c, LGS_015__c, LGS_016__c, LGS_017__c, LGS_018__c, LGS_019__c, LGS_020__c, WS_Response_Detail__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,Assigned_Agent_ID__c ' +
                ', RTL_TMB_Campaign_Source__c, LGS_Assignment_Code__c, LGS_LinkInfo__c, LGS_BrandCode__c, LGS_BrandShowroomCode__c, LGS_PartnerCode__c, LGS_Child_Campaign_ID__c, RTL_W2L_Campaign_Name__c, Lead_Score__c, Lead_Score_level__c, LGS_VIN_No__c, LGS_File_Upload__c ' +
                ', LGS_Campaign_Start_Date__c ,LGS_Campaign_End_Date__c ' +
                ' FROM Campaignmember ' +  
                'WHERE Id IN ' + idString ;
                            
            System.debug('query-->' + query);
    
            // TagCaseBatch tcb = new TagCaseBatch(query);
            // Database.executeBatch(tcb);
            List<CampaignMember> listCmb = Database.query(query);
            //List<Case> inputlist = new List<Case>();
            System.debug('ALL size ' + listCmb.size());
            CampaignMemberToALBatch cmal = new CampaignMemberToALBatch(listCmb,false,null,null,DateTime.now());
            Database.executeBatch(cmal);

        }
    }
}