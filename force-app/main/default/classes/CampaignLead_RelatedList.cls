public class CampaignLead_RelatedList {
    
    //public map<string,Campaign> campList {get;set;}
    //public map<string,campaignMember> mapCampMember {get;set;}
    //public list<string> campMemTemp {get;set;}
    //public list<lead> leadTemp {get;set;}
    public integer totalPage {get;set;}
    public integer currentPage {get;set;}
    public decimal recPerPage  = 5;
    public integer startOffset {get;set;}
    public string accid {get;set;}
    public list<lead> listLead {get;set;}
    
    public CampaignLead_RelatedList(ApexPages.standardController sc)
    {
        //leadTemp = new list<lead>();
        account Acc = (account)sc.getRecord();
        accid = Acc.id;
        //leadTemp = [select id from lead where account__c =: Acc.id];
        
        //integer totalRec = [select count() from campaignMember where leadid in: leadTemp];
        integer totalRec = [select count() from lead where account__c =: accid];
        totalPage = integer.valueof((totalRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug(totalPage);
        totalPage = (totalPage < 1) ? 1 : totalPage;
        currentPage = 1;
        startOffset = 0;
        
        //queryCampaignLeadHistory();
        queryLeadHistory();

    }
    
    public void nextPage()
    {
        currentPage = (currentPage != totalPage) ? (currentPage+1) : totalPage;
        startOffset = (currentPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryLeadHistory();
    }
    
    public void previousPage()
    {
        currentPage = (currentPage != 1) ? (currentPage-1) : 1;
        startOffset = (currentPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryLeadHistory();
    }
    
    /*
    public void queryCampaignLeadHistory()
    {
        campMemTemp = new list<string>();
        mapCampMember = new map<string,campaignMember>();
        campList = new map<string,campaign>();
        
        for (campaignMember a : [select campaignId,lead.name,lead.status,leadid,lead.lastmodifieddate from campaignMember 
                                 where leadid in: leadTemp order by lead.lastmodifieddate desc
                                 limit: integer.valueof(recPerPage) offset: startOffset])
        {
            campMemTemp.add(a.campaignId);
            mapCampMember.put(a.campaignId,a);
        }
        for (campaign a : [select id,name,startdate,enddate,isActive,lastmodifieddate from campaign where id in: campMemTemp])
        {
            campList.put(a.id,a);
        }
    }
    */
    
    public void queryLeadHistory()
    {
        listLead = [select id, Primary_Campaign__r.name, Pri_Campaign_Active__c, Pri_Campaign_Start_Date__c, Pri_Campaign_End_Date__c
                    , Status, Name, lastmodifieddate
                    from lead where account__c =: accid order by lastmodifieddate desc
                    limit: integer.valueof(recPerPage) offset: startOffset];
    }
    
}