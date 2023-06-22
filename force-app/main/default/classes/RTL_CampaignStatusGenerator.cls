public class RTL_CampaignStatusGenerator 
{

   
   public static Map<String,List<RTL_Campaign_Member_Status_Mapping__mdt>> CampaignMemberStatusMapping{get{

        if(CampaignMemberStatusMapping ==null){
            CampaignMemberStatusMapping = new Map<String,List<RTL_Campaign_Member_Status_Mapping__mdt>>();

            for(RTL_Campaign_Member_Status_Mapping__mdt csm : [SELECT RTL_Campaign_Catgory__c,RTL_Campaign_Member_Status__c,RTL_Contact_Status__c
                                                                ,RTL_Responded_Flag__c,RTL_Default_Flag__c,RTL_Offer_Result__c
                                                                FROM RTL_Campaign_Member_Status_Mapping__mdt]){
                if(!CampaignMemberStatusMapping.containsKey(csm.RTL_Campaign_Catgory__c)){
                    List<RTL_Campaign_Member_Status_Mapping__mdt> campaignMemberStatusList = new List <RTL_Campaign_Member_Status_Mapping__mdt>();
                    campaignMemberStatusList.add(csm);
                    CampaignMemberStatusMapping.put(csm.RTL_Campaign_Catgory__c,campaignMemberStatusList);
                }else{
                    CampaignMemberStatusMapping.get(csm.RTL_Campaign_Catgory__c).add(csm);
                }

            } 
        }

        return CampaignMemberStatusMapping;


    }set;}

    public static Map<String,String> statusDefaultMapping {get{
            if(statusDefaultMapping == null){
                statusDefaultMapping = new Map<String,String>();
                for(String category : CampaignMemberStatusMapping.keyset()){
                    for(RTL_Campaign_Member_Status_Mapping__mdt csm : CampaignMemberStatusMapping.get(category)){
                        if(csm.RTL_Default_Flag__c){
                            statusDefaultMapping.put(category,csm.RTL_Campaign_Member_Status__c.tolowerCase());
                        }
                    }


                }
            }
        return statusDefaultMapping;

        }set;}


    public static Map<String,Map<String,Map<String,String>>> campaignMemberStatusMap {get{
        if(campaignMemberStatusMap ==null ){
           campaignMemberStatusMap = new Map<String,Map<String,Map<String,String>>> (); 

           for(String category : CampaignMemberStatusMapping.keyset()){
                Map<String,Map<String,String>> contactStatusMap = new Map<String,Map<String,String>>();

                for(RTL_Campaign_Member_Status_Mapping__mdt csm : CampaignMemberStatusMapping.get(category)){

                        String offerresult = csm.RTL_Offer_Result__c==null?'Null':csm.RTL_Offer_Result__c;
                        if( !contactStatusMap.containsKey(csm.RTL_Contact_Status__c) )
                        {
                            Map<String,String> campaignMemberStatus = new Map<String,String>();
                            contactStatusMap.put( csm.RTL_Contact_Status__c , campaignMemberStatus );
                        }
                        contactStatusMap.get( csm.RTL_Contact_Status__c ).put( offerresult , csm.RTL_Campaign_Member_Status__c );


                }
                campaignMemberStatusMap.put(category,contactStatusMap);

            }


        }
        return campaignMemberStatusMap;


        }set;}


public static void RTL_GenerateCampaignMemberStatus(List<Campaign> triggernewCampaign, Map<ID,Campaign> triggerOldCampaignMap){

    Map<String,Map<String,CampaignMemberStatus>> existingAllCampaignMemberMapList = new Map<String,Map<String,CampaignMemberStatus>>();
    Map<ID,Integer> CampaignSortOrder =  new Map<ID,Integer>();
    Map<String,Set<String>> campaignMappingValues = new Map<String,Set<String>>();
    //Map<ID,Set<String>> existingCampaignStatus = new Map<Id,Set<String>>();
    Set<Id> camps = new Set<Id>();
    List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> cms2update = new List<CampaignMemberStatus>();
    List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
    Map<Id,Campaign> MapcampiagnRecord = new Map<id,Campaign>();

    
    for(Campaign camp : triggernewCampaign){


         /*   boolean isChange = false;    
           if(triggerOldCampaignMap.containsKey(camp.id)){
                System.debug('camp.RTL_Category__c  : '+camp.RTL_Category__c );
                System.debug('triggerOldCampaignMap: '+triggerOldCampaignMap.get(camp.id).RTL_Category__c);
                if(camp.RTL_Category__c != triggerOldCampaignMap.get(camp.id).RTL_Category__c){
                    isChange =true;
                }
           }else{
            isChange = true;
           }

           if(isChange){*/
             camps.add(camp.Id);
             MapcampiagnRecord.put(camp.id,camp);

         //  }
    }


    for(Campaign childcamp : [SELECT ID,Name,ParentId from Campaign WHERE ParentId IN:camps ]){
        triggernewCampaign.add(childcamp);
         camps.add(childcamp.Id);
         MapcampiagnRecord.put(childcamp.id,childcamp);

    }


    System.debug(camps);
    for(CampaignMemberStatus cms : [select Id,SortOrder, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {

             String cmslabel = cms.label.tolowerCase();    
             
            if(existingAllCampaignMemberMapList.containsKey(cms.CampaignID)){
               
                existingAllCampaignMemberMapList.get(cms.CampaignID).put(cmslabel,cms);
            }else{
                Map<String,CampaignMemberStatus> mapOfStatus = new Map<String,CampaignMemberStatus>();
                mapOfStatus.put(cmslabel,cms);
                existingAllCampaignMemberMapList.put(cms.CampaignID,mapOfStatus);
            }



            if(CampaignSortOrder.containsKey(cms.CampaignID)){
                if(CampaignSortOrder.get(cms.CampaignID)<cms.SortOrder){
                    CampaignSortOrder.put(cms.CampaignID,cms.SortOrder);
                }

            }else{
                CampaignSortOrder.put(cms.CampaignID,cms.SortOrder);
            }
            
    }

    Set<ID> parentCampaignId = new Set<ID>();
    for(Campaign camp : triggernewCampaign){
        if(camp.ParentID !=null){
            parentCampaignId.add(camp.ParentId);
        }
    }

    Map<ID,String> parentCampaignCategoryMap = new Map<ID,String>();
    for(Campaign parentCampaign : [SELECT ID,RTL_Category__c from Campaign WHERE ID IN:parentCampaignId ] ){
        parentCampaignCategoryMap.put(parentCampaign.ID,parentCampaign.RTL_Category__c);
    }




    for(Campaign camp : triggernewCampaign){

         String campaignCategory;
         if(camp.ParentId ==null){
                    campaignCategory = camp.RTL_Category__c;
            }else{
                    campaignCategory = parentCampaignCategoryMap.get(camp.parentID);
            }

         if(CampaignMemberStatusMapping.containskey(campaignCategory)){
                Integer ordercount = 1;

                for(RTL_Campaign_Member_Status_Mapping__mdt csm : CampaignMemberStatusMapping.get(campaignCategory)){

                    if(campaignMappingValues.containsKey(campaignCategory)){
                        campaignMappingValues.get(campaignCategory).add(csm.RTL_Campaign_Member_Status__c.tolowerCase());
                    }else{
                        Set<String> labelSet = new Set<String>();
                        labelSet.add(csm.RTL_Campaign_Member_Status__c.tolowerCase());
                        campaignMappingValues.put(campaignCategory,labelSet);
                    }

                    CampaignMemberStatus cms = new CampaignMemberStatus();
                    cms.CampaignId = camp.id;
                    cms.Label = csm.RTL_Campaign_Member_Status__c;
                    cms.HasResponded = csm.RTL_Responded_Flag__c;

                    cms.SortOrder = CampaignSortOrder.get(camp.id)+ordercount;
                    boolean isDupplicate = false;

                    String newLabel = csm.RTL_Campaign_Member_Status__c.tolowerCase();                    
                    if(existingAllCampaignMemberMapList.containsKey(camp.id)){
                    Map<String,CampaignMemberStatus> existingcampStatus = existingAllCampaignMemberMapList.get(camp.id);

                    if(existingcampStatus.containsKey(newLabel)){
                        isDupplicate = true;
                    }
                    
                    }
                        if(!isDupplicate){
                          cms2Insert.add(cms);
                          ordercount++;
                        }
                    

                   
                }

            }
    }


     if(cms2Insert.size()>0  ){
        insert cms2Insert;  
     }   
          
        
       


    if(cms2Insert.size()>0 ){
       for(CampaignMemberStatus cms : [select Id, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {
            Campaign CampaignRecord = MapcampiagnRecord.get(cms.CampaignID);
            String campaignCategory;
                if(CampaignRecord.ParentId ==null){
                        campaignCategory = CampaignRecord.RTL_Category__c;
                }else{
                        campaignCategory = parentCampaignCategoryMap.get(CampaignRecord.parentID);
                }
                


                if(statusDefaultMapping.containsKey(campaignCategory)){

                    if(cms.Label.tolowerCase() == statusDefaultMapping.get(campaignCategory)){
                        
                        cms.IsDefault = true;
                        
                    }else{
                        cms.IsDefault = false;
                    }
                    cms2update.add(cms);
                }

            if(campaignMappingValues.containskey(campaignCategory)){
                    String csmLabel = cms.Label.tolowerCase();
                    if(!campaignMappingValues.get(campaignCategory).contains(csmLabel)){
                        cms2Delete.add(cms);
                    }
                
            }



       }

       
            update cms2update;
            delete cms2Delete;
        
    }
       
 }




public static void RTL_UpdateCampaignMemberStatus(List<CampaignMember> triggernewCampaignMemberList){

    for(CampaignMember cpmb :  triggernewCampaignMemberList){

        if(campaignMemberStatusMap.containsKey(cpmb.RTL_Campaign_Category_formula__c)){
            Map<String,Map<String,String>> contactStatusMap = campaignMemberStatusMap.get(cpmb.RTL_Campaign_Category_formula__c);

            if(contactStatusMap.containsKey(cpmb.RTL_Contact_Status__c)){
                Map<String,String> campaignstatusMap = contactStatusMap.get(cpmb.RTL_Contact_Status__c);

                if(campaignstatusMap.containsKey(cpmb.RTL_Offer_Result__c)){
                    cpmb.Status = campaignstatusMap.get(cpmb.RTL_Offer_Result__c);
                }
                else 
                {
                    if(  campaignstatusMap.containsKey( 'Null' ) )    
                    {
                        cpmb.Status = campaignstatusMap.get('Null');
                    }
                }
               
            }

        }

    }
    



}




}