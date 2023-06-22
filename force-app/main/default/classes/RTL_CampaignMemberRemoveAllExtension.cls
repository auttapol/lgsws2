public class RTL_CampaignMemberRemoveAllExtension {
    public String CampaignID {get;set;}
    public transient List<CampaignMember> CampaignMemberList {get;set;}
    public transient List<CampaignMember> CampaignMemberUsedList {get;set;}
    public Integer campaignMemberSize {get;set;}
    public Integer campaignMemberAlreadyContactSize {get;set;}
    public String RemoveMenus {get;set;}
    public Boolean IsBatchInprogress {get;set;} //for go to batch when removed member success ,used on vf
    public Boolean isLocalExcusiveCampaign {get;set;}
    public List<RTL_Campaign_Member_Status_Mapping__mdt> listUsedStatus {get;set;}
    public string [] statusUnused {get;set;}
    public string [] statusUnusedforquery {get;set;}

    
    public RTL_CampaignMemberRemoveAllExtension (ApexPages.StandardController controller){
        
        isLocalExcusiveCampaign = false;
        IsBatchInprogress = false;
        CampaignID = ApexPages.currentPage().getParameters().get('id');

        isLocalExcusiveCampaign = checkRecordType(CampaignID);
        
        if(isLocalExcusiveCampaign){
            listUsedStatus = [select RTL_Contact_Status__c from RTL_Campaign_Member_Status_Mapping__mdt where RTL_Contact_Status__c = 'New'];
            statusUnused = new List<String>();
            statusUnusedforquery = new List<String>();
            for(RTL_Campaign_Member_Status_Mapping__mdt s : listUsedStatus){
                string st = '\''+s.RTL_Contact_Status__c+'\'';
                statusUnused.add(s.RTL_Contact_Status__c);
                statusUnusedforquery.add(st);
            }
            
            CampaignMemberList = [Select id
                                  FROM CampaignMember
                                  where CampaignID =:CampaignID];
            system.debug('CampaignMemberList : '+CampaignMemberList.size());
            
            CampaignMemberUsedList = [SELECT Id
                                        FROM CampaignMember 
                                        where (RTL_Contact_Status__c not in :statusUnused and RTL_Contact_Status__c !=null)
                                        and CampaignID =:CampaignID];

            system.debug('CampaignMemberUsedList : '+CampaignMemberUsedList.size());
            
            campaignMemberSize = CampaignMemberList.size();
            campaignMemberAlreadyContactSize = CampaignMemberUsedList.size();
            }else{
                system.debug('This campaign is not local exclusive campaign.');
            }
        
        
    }
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('unused',System.Label.RTL_Campaign_Member_Remove_unused));
        options.add(new SelectOption('all',System.Label.RTL_Campaign_Member_Remove_all));
        return options;
    }
    public PageReference saveToDel(){
        system.debug('RemoveMenus : '+RemoveMenus);
        string query;
        if(RemoveMenus == 'all'){
            query = 'select ID,RTL_Marketing_Code__c,Createddate,CampaignId,Campaign.name ,Type, ContactId, LeadId from CampaignMember where CampaignID = \''+CampaignID+'\'';
        }else if(RemoveMenus == 'unused'){
            query = 'select ID,RTL_Marketing_Code__c,Createddate,CampaignId,Campaign.name ,Type, ContactId, LeadId from CampaignMember where CampaignID = \''+CampaignID+'\' and (RTL_Contact_Status__c in '+statusUnusedforquery+' or RTL_Contact_Status__c = null)';
        }
        
        system.debug('query: '+query);
        
        //-----Batch Backup Campaign Member to Temp Object before delete-----//
        
        RTL_CampaignMemberInsertTempObjectBatch insertCampaignMembertoTemp = new RTL_CampaignMemberInsertTempObjectBatch(query,CampaignID);
        Id BatchProcessId = Database.ExecuteBatch(insertCampaignMembertoTemp,1000);
        
        //------End Backup Batch-------//

        //------Batch Delete Campaign Member-----//
        //RTL_CampaignMemberRemoveAllBatch deleteCampaignMember = new RTL_CampaignMemberRemoveAllBatch(query,CampaignID);
        //Id BatchProcessId = Database.ExecuteBatch(deleteCampaignMember,1000);
        //------End Delete Batch-------//

        if((campaignMemberSize == campaignMemberAlreadyContactSize) 
            && campaignMemberSize > 0
            && RemoveMenus == 'unused'){
            IsBatchInprogress = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Remove_ERR001));
        }else if(campaignMemberSize == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Remove_ERR003));
        }
        else{
            IsBatchInprogress = true;
        }
        return null;
    }
    public PageReference cancel(){
        PageReference detailpage;
        detailpage = new PageReference('/'+CampaignID+'?isdtp=vw'); 
        detailpage.setRedirect(true);
        return detailpage;
        //return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    public Pagereference back() {
        PageReference detailpage;
        detailpage = new PageReference('/'+CampaignID+'?isdtp=vw'); 
        detailpage.setRedirect(true);
        return detailpage;
       // return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));

    }

    public Boolean checkRecordType(ID CampaignID) {
        boolean isLocalExcusive = false;
        List<RecordType> campaignRecordType = new List<RecordType>();
        List<Campaign> campaign = new List<Campaign>();

        campaign = [Select recordtypeId from campaign where id =: CampaignID];


        campaignRecordType = [SELECT ID, Name, DeveloperName
                FROM Recordtype
                WHERE sObjectType = 'Campaign'
                AND (NOT DeveloperName LIKE '%Commercial%')
                AND (DeveloperName like '%Local_Exclusive%')
                AND id =: campaign.get(0).recordtypeId];

        isLocalExcusive = (campaignRecordType.size()>0)? true : false;

        return isLocalExcusive;


    }

}