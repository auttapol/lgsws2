public with sharing class RTL_CampaignTriggerHandler {

    public static void checkDuplicateName(list<campaign> listNewCampaign, list<campaign> listOldCampaign) {
       
        //================= Process to filter only Changed name campaign to check duplicate name ===========
        map<Id, Campaign> mapOldCampaignName = new map<Id, Campaign>();
        for (campaign oc : listOldCampaign) {
            mapOldCampaignName.put(oc.id, oc);
        }

        List<Campaign> newChangeNameCampaign = new List<Campaign>();
        List<Campaign> oldChangeNameCampaign = new List<Campaign>();

        for (campaign nc : listNewCampaign) {
            
            campaign oc = mapOldCampaignName.get(nc.id);
            if(  oc == null || nc.name != oc.name )
            {
                newChangeNameCampaign.add(nc);
                if( oc != null )
                {
                    oldChangeNameCampaign.add(oc);
                }
            }
        }

        //============== Start check duplicate for changed name campaign ================
        if( newChangeNameCampaign.size() > 0 )
        {
            boolean error = false;
            Set<ID> camDupId = new Set<ID>();
            Set<String> camDupName = new Set<String>();

            set<string> listCheckCampaignNameDuplicate = new set<string>();
            for (campaign c : newChangeNameCampaign) { // new list campaign name duplicate
                if (listCheckCampaignNameDuplicate.contains(c.name))
                {
                    error = true;
                    camDupName.add(c.name);
                    camDupId.add(c.id);
                }
                listCheckCampaignNameDuplicate.add(c.name);
            }

            map<string, string> mapOldChangeNameCampaignName = new map<string, string>();
            for (campaign oc : oldChangeNameCampaign) {
                mapOldChangeNameCampaignName.put(oc.id, oc.name);
            }

            set<string> listCampaignName = new set<string>();
            for (campaign c : newChangeNameCampaign) {
                if (c.name != mapOldChangeNameCampaignName.get(c.id))
                    listCampaignName.add(c.name);
            }

            integer found = [select count() from campaign where name in : listCampaignName];
            if (found > 0) error = true;

            if (error)
            {
                List<Campaign> errCams = [select id,name from campaign where name in : listCampaignName];

                for( Campaign ec : errCams )
                {
                    camDupId.add(ec.id);
                    camDupName.add(ec.name);
                }

                for( Campaign cam : listNewCampaign )
                {
                     if( camDupId.contains(cam.id) || camDupName.contains(cam.name) )
                     {
                        cam.name.addError(status_code__c.getValues('8002').status_message__c);
                          
                     }
                }
                //listNewCampaign.get(0).name.addError(status_code__c.getValues('8002').status_message__c);
            }
                
        }
    }


}