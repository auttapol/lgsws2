public class CampaignMemberTriggerHandler {

    public static void addLeadToCampaingMember(list<campaignMember> listCampMember)
    {
        try {
            set<string> setLeadID = new set<string>();
            set<string> setCampaignID = new set<string>();
            map<string,string> mapLeadCampaign = new map<string,string>();
            boolean checkFlag = true;
            
            for (campaignMember c : listCampMember)
            {
                setLeadID.add(c.LeadID);
                setCampaignID.add(c.CampaignID);
                mapLeadCampaign.put(c.LeadID,c.CampaignID);
            }
            
            
            list<Lead> listLead = new list<Lead>();
            list<Campaign_Product__c> listCampaignProduct = new list<Campaign_Product__c>();
            list<product_interest__c> listProductInterest = new list<product_interest__c>();
            
            for (Lead l : [select id,primary_campaign__c,IsUpdateFromLead__c from lead where id in : setLeadID])
            {
                if (!l.IsUpdateFromLead__c) checkFlag = false;
                l.primary_campaign__c = mapLeadCampaign.get(l.id);
                l.IsUpdateFromLead__c = false;
                listLead.add(l);
            }
            for (Campaign_Product__c p : [select Product__c, Opportunity_Type__c, Amount__c, Campaign__c
                                                from Campaign_Product__c where Campaign__c in: setCampaignID])
            {
                listCampaignProduct.add(p);
            }
                      
            if (checkFlag)
            {
                
                for (Lead l : listLead)
                {
                    string campaignID = mapLeadCampaign.get(l.id);
                    for (Campaign_Product__c cp : listCampaignProduct)
                    {
                        if (cp.Campaign__c == campaignID && l.recordType.Name != 'Digital Channel' )
                        {
                            Product_interest__c pi = new Product_Interest__c(Lead__c = l.id, Product__c = cp.Product__c
                                , Opportunity_Type__c = cp.Opportunity_Type__c, Amount__c = cp.Amount__c);
                            listProductInterest.add(pi);
                        }
                    }
                }
                system.debug(listProductInterest); 
                system.debug(listLead);              
                update listLead;
                insert listProductInterest; 
                
            }
            
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
    
    
    
    
        /*
        set<string> listLeadId = new set<string>();
        list<Product_Interest__c> listProductInterest = new list<Product_Interest__c>();
        list<lead> listUpdateLead = new list<lead>();
        
        //string campaignId = listCampMember.get(0).campaignId;
        map<string,string> campaignMapId = new map<string,string>();
        list<string> listCampaignID = new list<string>();
        List<String> listOfLeadID = new List<String>();
        for(campaignMember c : listCampMember)
        {
            campaignMapId.put(c.leadID,c.campaignID);
            listCampaignID.add(c.campaignID);
            listOfLeadID.add(c.LeadID);
        }
        
        list<Campaign_Product__c> listCampaignProduct = [select Product__c, Opportunity_Type__c, Amount__c, Campaign__c
                                          from Campaign_Product__c where Campaign__c in: listCampaignID];
        //                                  from Campaign_Product__c where Campaign__c =: campaignId];
        
        List<Lead> listLead = [SELECT ID,Primary_Campaign__c from Lead WHERE ID IN: listofLeadId];
        set<ID> InvalidLead = new Set<ID>();
        for(Lead leadRec : listLead){
            if(leadRec.Primary_Campaign__c !=null){
                InvalidLead.add(LeadRec.id);
            }
        }
        
        
        for (campaignMember c : listCampMember)
        {
            if(!InvalidLead.contains(c.LeadId)){
                listLeadId.add(c.LeadID);
            }
        }
        

            for (string leadId : listLeadId)
            {
                listUpdateLead.add(new Lead(id = leadId, Primary_Campaign__c = campaignMapId.get(leadId)));
                for (Campaign_Product__c c : listCampaignProduct)
                {
                    if (c.Campaign__c == campaignMapId.get(leadId))
                    {
                        Product_Interest__c pi = new Product_Interest__c(Lead__c = leadId, Product__c = c.Product__c
                            , Opportunity_Type__c = c.Opportunity_Type__c, Amount__c = c.Amount__c);
                        listProductInterest.add(pi);
                    }
                }
            }
            
            system.debug(listProductInterest);
            system.debug(listUpdateLead);
            
            try {
                insert listProductInterest;
                update listUpdateLead;
            }catch(exception ex){
                system.debug(ex);
            }
        */
    }
    
    public static void checkPrimaryCampaign(list<campaignMember> listCampMember)
    {
        set<string> setLeadID = new set<string>();
        set<string> setCampaignID = new set<string>();
        Set<String> ExisitngCmember = new Set<String>();
        
        for (campaignMember c : listCampMember)
        {
            setLeadID.add(c.leadid);
            setCampaignID.add(c.campaignID);
        }

        for (campaignMember c: [select LeadId, Lead.name ,CampaignId
                                from campaignMember 
                                where LeadId in: setLeadID
                                and CampaignId not in : setCampaignID])
        {
            if (c.LeadID != null) ExisitngCmember.add(c.LeadId);
        }
        
        for(campaignMember c : listCampMember){
            if(ExisitngCmember.Contains(c.LeadId)){
                c.Firstname.addError(status_code__c.getValues('8003').status_message__c);
            }
        }
        
        
        
        /*
        string campaignId = listCampMember.get(0).campaignId;
        list<string> listLeadId = new list<string>();
        //string errorText = '';
        boolean errorCheck = false;
        integer n = 0;
        
        for (campaignMember c : listCampMember)
        {
            listLeadId.add(c.LeadId);
        }
        
        for (campaignMember c: [select LeadId, Lead.name 
                                from campaignMember 
                                where LeadId in: listLeadId 
                                and CampaignId !=: campaignId])
        {
            //errorText = ' - '+c.Lead.name+'<br/>';
            errorCheck = true;
        }
        //if (errorText != '')
        if (errorCheck)
            listCampMember.get(0).Firstname.addError(status_code__c.getValues('8003').status_message__c);
            //listCampMember.get(0).Firstname.addError('The lead below is belong to another campaign, please create new lead<br/>'+errorText);
        */
    }
    
    public static void deleteCampaignMember(list<campaignMember> listCampMember)
    {
        try {
            list<string> listLeadId = new list<string>();
            list<lead> listLead = new list<lead>();
            
            for (campaignMember c : listCampMember)
            {
                listLeadId.add(c.LeadID);
            }
            
            for (Lead l : [select id, primary_campaign__c from Lead where id in: listLeadId])
            {
                l.primary_campaign__c = null;
                l.IsUpdateFromLead__c = true;
                listLead.add(l);
            }
            update listLead;
        }catch(exception ex){
            system.debug(ex);
        }
    }

    public static void UpdateLeadWithCampaignMember(list<campaignMember> listCampMember) 
    {
        try {
            set<string> setLeadID = new set<string>();
            map<string,string> mapLeadCampaign = new map<string,string>();
            map<string,string> mapCampaignReason = new map<string,string>();
            map<string,string> mapCampaignStatus = new map<string,string>();
            list<lead> listLead = new list<lead>();
            
            for (campaignMember c : listCampMember)
            {
                if (c.RTL_Channel_Outbound__c == true) 
                {
                    setLeadID.add(c.LeadID);
                    mapLeadCampaign.put(c.LeadID,c.CampaignID);
                    mapCampaignReason.put(c.CampaignID,c.RTL_Reason__c);
                    mapCampaignStatus.put(c.CampaignID,c.RTL_Contact_Status__c);
                }
            }
            
            for (Lead l : [select id, RTL_Reason__c, Status from Lead where id in: setLeadID])
            {
                l.RTL_Reason__c = mapCampaignReason.get(mapLeadCampaign.get(l.id));
                l.Status = mapCampaignStatus.get(mapLeadCampaign.get(l.id));
                listLead.add(l);
            }
            update listLead;
        }catch(exception ex){
            system.debug(ex);
        }
    }
}