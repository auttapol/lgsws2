public class LeadTriggerHandler {

    public LeadTriggerHandler()
    {
    
    }
    
    public static void updatePrimaryCampaign(list<lead> listNewLead, list<lead> listOldLead)
    {
    
        /*** for commercial only (exclude retail) ***/
        /*
        list<lead> listNewLead = new list<lead>();
        set<string> setRecordTypeId = new set<string>();
        for (recordtype r : [select id from recordtype where name like '%commercial%'])
        {
            setRecordTypeId.add(r.id);
        }
        
        for (lead l : listNewLeadtemp)
        {
            if (setRecordTypeId.contains(l.recordtypeId))
                listNewLead.add(l);
        }
        */
        /*** for commercial only (exclude retail) ***/
        
        /*
        list<CampaignMember> newCampHis = new list<CampaignMember>();
        map<string,string> mapOldCampaign = new map<string,string>();
        Set<ID> CampaignID = new Set<ID>();
        List<Lead> LeadCampaignChanged = new List<Lead>();
        for (lead l : listOldLead)
        {
            mapOldCampaign.put(l.id,l.Primary_Campaign__c);
        }
        
        for (lead l : listNewLead)
        {
            if (l.Primary_Campaign__c != null)
            {
                if (l.Primary_Campaign__c != mapOldCampaign.get(l.id))
                {
                    CampaignID.add(l.Primary_Campaign__c);
                    LeadCampaignChanged.add(l);
                }
            }
        }
        
        Map<ID,Campaign> CampaignMap = new Map<ID,Campaign>();
        for(Campaign camp : [select id from Campaign where id IN:CampaignID]){
            CampaignMap.put(camp.id,camp);
        }
        
        for(Lead leadRec : LeadCampaignChanged){
            if(campaignMap.containsKey(leadRec.Primary_Campaign__c)){
                newCampHis.add(new CampaignMember(LeadId = leadRec.id, CampaignId = CampaignMap.get(leadRec.Primary_Campaign__c).id));
            }
            
        }
        */
        

        try {
            
            list<lead> listChangeLead = new list<lead>();
            list<CampaignMember> newCampHis = new list<CampaignMember>();
            map<string,string> mapOldCampaign = new map<string,string>();
            
            for (lead l : listOldLead)
            {
                mapOldCampaign.put(l.id,l.Primary_Campaign__c);
            }
            
            for (lead l : listNewLead)
            {
                if (l.IsUpdateFromLead__c)
                {
                    if (l.Primary_Campaign__c != mapOldCampaign.get(l.id))
                    {
                        listChangeLead.add(l);
                    }
                }
            }
            
            for (lead l : listChangeLead)
            {
                newCampHis.add(new CampaignMember(LeadId = l.id, CampaignId = l.Primary_Campaign__c));
            }
            
            if (newCampHis.size() > 0) insert newCampHis;
          
        }catch(exception ex){
            system.debug(ex);
        }

    }
    
    public static void afterChangeOwnerLead(list<lead> newLead, list<lead> oldLead)
    {
    
        /*** for commercial only (exclude retail) ***/
        /*
        list<lead> newLead = new list<lead>();
        set<string> setRecordTypeId = new set<string>();
        for (recordtype r : [select id from recordtype where name like '%commercial%'])
        {
            setRecordTypeId.add(r.id);
        }
        
        for (lead l : newLeadTemp)
        {
            if (setRecordTypeId.contains(l.recordtypeId))
                newLead.add(l);
        }
        */
        /*** for commercial only (exclude retail) ***/
    
        try {
        
            list<string> listLeadId = new list<string>();
            map<string,string> mapLeadOwnerId = new map<string,string>();
            list<Call_Report__c> listVisitReport = new list<Call_Report__c>();
            list<Task> listTask = new list<Task>();
            
            for (lead l: newLead)
            {
                for (lead ol: oldLead)
                {               
                    if (ol.id == l.id && ol.ownerid != l.ownerid)
                    {
                        listLeadId.add(l.id);
                        mapLeadOwnerId.put(l.id,l.ownerid);
                    }
                }
            }
            
            for (Call_Report__c c : [select id,ownerid,lead__c from Call_Report__c where lead__c in: listLeadId and status__c = '1 - Open'])
            {
                c.ownerid = mapLeadOwnerId.get(c.lead__c);
                listVisitReport.add(c);
            }
            
            for (Task t : [select id,ownerid,whoid from task where whoid in: listLeadId and IsClosed = false])
            {
                t.ownerid = mapLeadOwnerId.get(t.whoid);
                listTask.add(t);
            }
            
            update listVisitReport;
            update listTask;
            
        }catch(exception ex){
            system.debug(ex);
        }
        
    }

}