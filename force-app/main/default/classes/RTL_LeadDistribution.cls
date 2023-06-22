public with sharing class RTL_LeadDistribution {
    public static String endpoint ;
    public static String privateKey ;
    public static String keyAPI ;
    public static String mapEndpoint ;
    // @future(callout=true)
    public static void mappingleadDistribution(List<CampaignMember> cmList, Map<Id,String> mapLeadwithintegrationtype){
        try {
            List<Distribute_Mapping__mdt> distributeMapping = [SELECT Integration_Type__c,Name_Credentials__c,Integration_System_Name__c FROM Distribute_Mapping__mdt WHERE Integration_Type__c IN :mapLeadwithintegrationtype.values()];
            
            System.debug('distributeMapping-->' + distributeMapping);
            
            String getSysName ;
            for (Distribute_Mapping__mdt mapping : distributeMapping) {
                // getName.put(mapping.Id,mapping.Name_Credentials__c);
                mapEndpoint = mapping.Name_Credentials__c;//RTL_AL_SubmitApp_HPAP
                getSysName=mapping.Integration_System_Name__c;//HPAPAPI
            }
            List<Integration_System__mdt> integrationSystemMap = [SELECT QualifiedApiName,Key_API__c FROM Integration_System__mdt WHERE QualifiedApiName =:getSysName];
            System.debug('integrationSystemMap-->' + integrationSystemMap);
            for (Integration_System__mdt inteMap : integrationSystemMap) {
                keyApi = inteMap.Key_API__c;
            }

            System.debug('mapEndpoint-->' + mapEndpoint);
            System.debug('keyAPI-->' + keyAPI);
            List<String> campagignID = new List<String>();
            if(cmList.size() > 0)
            {
                for(Campaignmember cm : cmList)
                {
                  campagignID.add(cm.Id);
                }
            }
            System.debug('campagignID-->' + campagignID.size());
      
            if (!campagignID.isEmpty()) 
            {
              System.debug('campagignID-->' + campagignID);
              String idString = '(\''+String.join(new List<String>(campagignID), '\',\'')+'\')';
      
              String query = 'SELECT Id,RTL_Campaign_Product_1__c,RTL_Campaign_Product_1__r.Name,RTL_AL_oa_ref_code__c, CampaignId, Campaign.Name,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c, LeadSource, RTL_Product_Name__c, RTL_AL_car_type__c, RTL_AL_car_brand__c, RTL_AL_car_group__c'+
              ',RTL_AL_car_subtype__c, RTL_AL_car_gear__c, RTL_AL_car_year__c, RTL_AL_wanted_amount__c, RTL_AL_max_set_up_amount__c,RTL_AL_normal_price__c '+
              ', RTL_AL_installment_periods__c, RTL_AL_PayPerMonth__c, RTL_AL_DownPercent__c, RTL_AL_DownAmt__c, RTL_AL_installment_amount__c, RTL_AL_available_time__c'+
              ',RTL_AL_ContactZipcode__c, RTL_AL_ContactProvince__c, RTL_AL_ContactDistrict__c, RTL_AL_ContactSubDistrict__c, RTL_AL_contact_channel__c, RTL_AL_IsCarBooked__c'+
              ', RTL_AL_car_bought_from__c, RTL_AL_TentName__c, RTL_Branch_Code__c, RTL_AL_car_plate_no__c, RTL_AL_province_car_plate_no__c, RTL_AL_Showroom__c, LeadId, Lead.RTL_ID_Type__c, Lead.RTL_Citizen_Id__c, Lead.FirstName, Lead.LastName'+
              ', Customer__c, Customer__r.ID_Number_PE__c, Customer__r.ID_Type_PE__c, Customer__r.First_name_PE__c, Customer__r.Last_name_PE__c, Customer__r.Mobile_Number_PE__c,Customer__r.Email_Address_PE__c, RTL_CampHis_Phone__c '+
              ', Customer__r.TMB_Customer_ID_PE__c, RTL_AL_comment__c, LGS_Partner__c, LGS_Lead_Received_Time__c , LGS_Assign_Rule__c, LGS_Car_Brand_Showroom_ID__c, LGS_Dealer_Showroom_ID__c '+
              ', RTL_AL_Interested_Rate__c, LGS_001__c, LGS_002__c, LGS_003__c, LGS_004__c, LGS_005__c, LGS_006__c, LGS_007__c, LGS_008__c, LGS_009__c, LGS_010__c '+
              ', LGS_011__c, LGS_012__c, LGS_013__c, LGS_014__c, LGS_015__c, LGS_016__c, LGS_017__c, LGS_018__c, LGS_019__c, LGS_020__c, WS_Response_Detail__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,Assigned_Agent_ID__c ' +
              ', RTL_TMB_Campaign_Source__c, LGS_Assignment_Code__c, LGS_LinkInfo__c, LGS_BrandCode__c, LGS_BrandShowroomCode__c, LGS_PartnerCode__c, LGS_Child_Campaign_ID__c, RTL_W2L_Campaign_Name__c, Lead_Score__c, Lead_Score_level__c, LGS_VIN_No__c, LGS_File_Upload__c ' +
              ', LGS_Campaign_Start_Date__c ,LGS_Campaign_End_Date__c ' +
              ' FROM Campaignmember ' +  
              'WHERE Id IN ' + idString ;
      
              System.debug('query-->' + query);
      
              List<CampaignMember> listCmb = Database.query(query);
      
              System.debug('ALL size ' + listCmb.size());
              RTL_Distribute_CM_Batch cmal = new RTL_Distribute_CM_Batch(listCmb,true,null,null,DateTime.now(),mapEndpoint,keyAPI);
              Database.executeBatch(cmal);
            }

        } catch (Exception e) {
            System.debug(e);
            System.debug('LeadDistribution');
            System.debug('Error message --> ' + e.getMessage() + ' Line:' +e.getLineNumber());
        }
    }
}