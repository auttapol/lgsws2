global class RTL_CampaignMemberInsertTempObjectBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    // instance member to retain state across transactions
    global TimeZone tz = UserInfo.getTimeZone();
    global Integer recordsProcessed = 0;
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = datetime.now();
    global Datetime batchStartTime = datetime.now();
    global Datetime batchEndTime = null;
    
    global final String query;
    public final String CampaignID;
    public List<RTL_Deleted_Campaign_Member__c> memberList;
    
    global RTL_CampaignMemberInsertTempObjectBatch(string q,id cid) {
        query = q;
        CampaignID = cid;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        System.Debug('TMB: -> RTL_CampaignMemberInsertTempObjectBatch start of execute');
        system.debug('scope :'+scope.size());

        memberList = new List<RTL_Deleted_Campaign_Member__c>();

        for(CampaignMember cml : scope){
            
            RTL_Deleted_Campaign_Member__c member = new RTL_Deleted_Campaign_Member__c();
            member.RTL_Campaign_Member_ID__c = cml.Id;//for map integration
            member.RTL_Campaign_ID__c  = cml.CampaignId;
            member.RTL_Marketing_Code__c = cml.RTL_Marketing_Code__c;
            member.RTL_Campaign_Member_Created_Date__c = cml.Createddate;
            memberList.add(member);

        }
        
        //insert campaign member to temp object before del campaign member
        if (scope.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(memberList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Campaign Member with ID: ' + sr.getId());
                    recordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error inserting Campaign Member. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            } 
        } 
        
        
        System.Debug('TMB: -> RTL_CampaignMemberInsertTempObjectBatch end of execute');
    
    }
    
    global void finish(Database.BatchableContext BC) {
        //continue to delete campaign member and update temp object
        RTL_CampaignMemberRemoveAllBatch deleteCampaignMember = new RTL_CampaignMemberRemoveAllBatch(CampaignID);
        Id BatchProcessId = Database.ExecuteBatch(deleteCampaignMember,1000);
        
    }
    
}