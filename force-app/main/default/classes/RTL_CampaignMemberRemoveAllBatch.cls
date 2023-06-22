global class RTL_CampaignMemberRemoveAllBatch implements Database.Batchable<sObject> ,Database.Stateful{
    
    // instance member to retain state across transactions
    global TimeZone tz = UserInfo.getTimeZone();
    global Integer recordsProcessed = 0;
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = datetime.now();
    global Datetime batchStartTime = datetime.now();
    global Datetime batchEndTime = null;
    
    global final String query;
    public String CampaignID {get; set;}
    public Set<String> listIDforDel;
    public string campaignName {get;set;}
    public Integer amountDelCampaignMember {get;set;}
    
    global RTL_CampaignMemberRemoveAllBatch(Id cid) {
        CampaignID = cid;
        amountDelCampaignMember = 0;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([Select RTL_Campaign_ID__c,
                                         RTL_Campaign_Member_ID__c,
                                         RTL_Deleted__c,
                                         RTL_Deleted_Time__c,
                                         RTL_Campaign_Member_Created_Date__c,
                                         RTL_Marketing_Code__c
                                         from RTL_Deleted_Campaign_Member__c
                                         where RTL_Campaign_ID__c = :CampaignID 
                                         order by RTL_Campaign_ID__c]);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<RTL_Deleted_Campaign_Member__c> scope) {

        System.Debug('TMB: -> RTL_CampaignMemberRemoveAllBatch start of execute');
        system.debug('scope :' + scope.size());
        Savepoint sp = Database.setSavepoint();
        listIDforDel = new Set<String>();
        boolean isDeleted = false;
        if (scope.size() > 0) {
            for(RTL_Deleted_Campaign_Member__c dc : scope){
                listIDforDel.add(dc.RTL_Campaign_Member_ID__c);
            }
            system.debug('listIDforDel size : '+listIDforDel.size());
            
            Map<id,Campaignmember> mapCampaignmember = new Map<ID,Campaignmember>([SELECT id,Campaignid,Campaign.name
                                                                                   FROM Campaignmember 
                                                                                   WHERE Campaignid = :CampaignID 
                                                                                   and id in:listIDforDel]);                        
            system.debug('Del size : '+mapCampaignmember.size());

            //Delete campaign member from temp object
            try {
                campaignName = mapCampaignmember.values().get(0).Campaign.name;//get campaign name
                delete mapCampaignmember.values();
                amountDelCampaignMember += mapCampaignmember.size();
                isDeleted = true;
            } catch (Exception e) {
                system.debug(e);
                isDeleted = false;
                Database.rollback(sp);
            }
            
            //if delete campaign member success, update del time and flag on deleted campaign member.
            if (isDeleted) {
                for (RTL_Deleted_Campaign_Member__c dl : scope) {
                    if(!dl.RTL_Deleted__c){
                        Datetime current = DateTime.now();
                        dl.RTL_Deleted__c = true;
                        dl.RTL_Deleted_Time__c = current;
                    }
                }
                
                //update deleted campaign member record
                try {
                    update scope;
                    
                } catch (Exception e) {
                    system.debug(e);
                    Database.rollback(sp);
                }
            }else{
                //if delete campaign member fail, delete record on deleted campaign member.
                try {
                    system.debug('scope del : '+scope.size());
                    delete scope;
                } catch (Exception e) {
                    system.debug(e);
                    Database.rollback(sp);
                }
            }
        }
        
        
        
        
        System.Debug('TMB: -> RTL_CampaignMemberRemoveAllBatch end of execute');
    }
    
    // Finish Job
    global void finish(Database.BatchableContext BC) {
        system.debug('Final Campaign Name : '+campaignName);
        system.debug('Final Campaign Member del : '+amountDelCampaignMember);

        Campaign cam = [Select id,name,RTL_Campaign_Code_10_digits__c FROM Campaign WHERE id = :CampaignID Limit 1 ];

        batchEndTime = datetime.now();
        recordsProcessed = recordsSuccessful + recordsFailed;
        
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        
        String subject = Label.RTL_CampaignMember_DeleteEmail_Subject;
        // string mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() +'/ui/support/servicedesk/ServiceDeskPage#/'+ CampaignID;
        string mainUrl =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + CampaignID;

        String resultTable = '<table style="border: 1px solid black;border-collapse: collapse;">'+
            '<tr style="text-align:  center;">'+
                '<td style="border: 1px solid black;">No.</td>'+
                '<td style="border: 1px solid black;">Campaign Code</td>'+
                '<td style="border: 1px solid black;">Campaign Name</td>'+
                '<td style="border: 1px solid black;">Total Process Records</td>'+
            '</tr>';

        resultTable += '<tr>'+
                '<td style="border: 1px solid black;text-align:  right;">1</td>'+
                '<td style="border: 1px solid black;">'+cam.RTL_Campaign_Code_10_digits__c+'</td>'+
                '<td style="border: 1px solid black;">'+cam.name+'</td>'+
                '<td style="border: 1px solid black;text-align:  right;">'+amountDelCampaignMember+'</td>'+
            '</tr>'+
        '</table>';

        List<String> fillers = new String[]{ mainUrl , resultTable };
        String htmlMsg = String.format( Label.RTL_CampaignMember_DeleteEmail_Content , fillers );

        // string htmlMsg =  'Campaign : '+campaignName
        //     + '<br/>Campaign Member delete : '+amountDelCampaignMember
        //     + '<br/>Campaing member delete batch processing is completed'
        //     + '<br/>Please click below url to view '
        //     + '<br/>View <a href="' + mainUrl + '"> click here</a>';

         if(amountDelCampaignMember > 0){
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { userEmail };
                message.optOutPolicy = 'FILTER';
            message.subject = subject;
            message.setHtmlBody(htmlMsg);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         }
        
        
        
        
    }
    
}