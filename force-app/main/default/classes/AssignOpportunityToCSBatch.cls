global class AssignOpportunityToCSBatch implements Database.Batchable<sObject> , Database.Stateful
{
    public String query;
    global Integer recordsSuccessful = 0;
    global Integer recordsFailed = 0;
    global Datetime batchDate = DateTime.now();
    global Datetime batchStartTime = DateTime.now();
    global Datetime batchEndTime = null;
    
    private String sobjectName = 'Opportunity';
    private String jobDailyName = 'AssignOpportunityToCSBatch';
    private String CSV_BODY = '';
    private String csvHeaderStr = '';
    private List<String> emailOpsList = new List<String>();
    
    public Integer countAll;
    public Integer countOpptyError;
    public Integer countOpptySuccess;
    
	public Map<Id, Opportunity> opptyErrorMap;
    public Map<Id, String> opptyErrorMsgMap;
    public Map<Id, Opportunity> opptySuccessMap;
    
    public List<Channel_User_Mapping__mdt> channelMapping 
    {
        get{
            
            if(channelMapping == null)
            {
                
                channelMapping = [SELECT Id, Label,Channel__c,Employee_ID__c,sObject__c FROM Channel_User_Mapping__mdt];
            }
            
            return channelMapping;
        }
        set;
    }
    
    
    global AssignOpportunityToCSBatch(String q)
    {
        query = q; 
      
		opptyErrorMap = new Map<Id, Opportunity>();
        opptySuccessMap = new Map<Id,Opportunity>();

		countAll = 0;
		countOpptyError = 0;
        countOpptySuccess = 0;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        System.debug('Opportunity:'+scope);
        List<Opportunity> opptyList = new List<Opportunity>();
        Id opptyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
        Map<String,Channel_User_Mapping__mdt> channelMap = new Map<String,Channel_User_Mapping__mdt>();  
        
        countAll += scope.size();
        for(Channel_User_Mapping__mdt mt : channelMapping)
        {
            channelMap.put(mt.Channel__c+mt.sObject__c,mt);
        }
        
        for(Opportunity op : scope)
        {            
            Opportunity oppty = new Opportunity(Id = op.Id );            
            oppty.StageName = 'Analysis';
            oppty.RecordTypeId = opptyRecordTypeId;
            oppty.OwnerId = channelMap.get(op.LeadSource+op.getsObjectType()).Employee_ID__c;
            
            opptyList.add(oppty);
            
        }

        if(opptyList.size() > 0)
        {
            Database.UpsertResult[] upsertResult = Database.upsert(opptyList , Opportunity.Fields.Id , false);
            for (Integer i = 0; i < upsertResult.size(); i++) 
            {	               
                
                if (!upsertResult.get(i).isSuccess() ) 
                {
					countOpptyError += 1;

					opptyErrorMap.put(opptyList.get(i).Id, opptyList.get(i));
					String errormsg = '';

					for(Database.Error err : upsertResult.get(i).getErrors()) {
						errormsg += err.getStatusCode() + ':' + err.getMessage();
					}

					opptyErrorMsgMap.put(opptyList.get(i).Id, errormsg);
				}
                else 
                {

                    countOpptySuccess += 1;
                    opptySuccessMap.put(opptyList.get(i).Id, opptyList.get(i));
                    
                }
            }
        }
    }  
    global void finish(Database.BatchableContext BC)
    {
        batchEndTime = DateTime.now();
        
        recordsSuccessful = countAll - countOpptyError;
        recordsFailed = countOpptyError;

		String[] errorMsg;

		
		for(Opportunity oppty : opptyErrorMap.values()){
			System.debug(oppty);
		}

        if(opptyErrorMsgMap != null)
        {
            for(Id ID : opptyErrorMsgMap.keySet()){
                System.debug(ID + ' : ' + opptyErrorMap.get(ID) + ' : ' + opptyErrorMsgMap.get(ID));
                
                errorMsg = opptyErrorMsgMap.get(ID).split(':', 2); 
                
                System.debug(errorMsg[0] + ' : ' + errorMsg[1]);
                
                Opportunity oppty = opptyErrorMap.get(ID);
                
                CSV_BODY = CSV_BODY + 
                    oppty.Id + ',' +
                    errorMsg[1] + ',' +
                    errorMsg[0] + ',' + '\n';
            }
        }	

        emailOpsList.add('CRM Admin 2');
        if(countOpptyError > 0)
        {
            RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                              , batchStartTime
                                                              , batchEndTime
                                                              , recordsSuccessful
                                                              , recordsFailed
                                                              , csvHeaderStr
                                                              , jobDailyName
                                                              , sobjectName
                                                              , emailOpsList
                                                              , CSV_BODY);
        }

        if(countOpptySuccess > 0)
        {
            if(opptySuccessMap.size() > 0)
            {
                List<Opportunity> opptyList = [SELECT Id,Name,Owner.Email FROM Opportunity Where Id IN: opptySuccessMap.keySet()];

                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
                for(Opportunity oppty : opptyList)
                {      
                    Messaging.reserveSingleEmailCapacity(2);

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    // Strings to hold the email addresses to which you are sending the email.
                    String[] toAddresses = new String[] {oppty.Owner.Email};
                    
                    mail.setToAddresses(toAddresses);

                    mail.setSenderDisplayName('Salesforce Support');
                    mail.setSubject('Opportunity transferred to you.');

                    String link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppty.Id;
                    mail.setHtmlBody(oppty.Name + ' has been assigned to you. Please click to the link below to view the record. <br><br>' +
                        '<a href='+link+'>'+ link +'</a>');

                    mailList.add(mail);

                    // Send the email you have created.
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                Messaging.sendEmail(mailList);
            }
        }
    }
}