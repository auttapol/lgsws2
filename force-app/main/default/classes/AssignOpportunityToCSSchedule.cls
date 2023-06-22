global class AssignOpportunityToCSSchedule implements Schedulable {
			
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
	

	global void execute(SchedulableContext sc) {

        List<Channel_User_Mapping__mdt> channelMapping = [SELECT Id, Label,Channel__c,Employee_ID__c,sObject__c FROM Channel_User_Mapping__mdt];
        List<String> channelList = new List<String>();
        for(Channel_User_Mapping__mdt ch : channelMapping)
        {
            channelList.add(ch.Channel__c);
        }
        String channel = '(\''+String.join(channelList, '\',\'')+'\')';
        System.debug('channel:'+channel);
        String q = 'SELECT Id, Name, LeadSource, StageName, CreatedDate '+ 
            'FROM Opportunity '+
            'Where StageName IN (\'Submit to Credit Process\') AND LeadSource IN '+ channel +' AND CreatedDate = TODAY'; 
        
        AssignOpportunityToCSBatch b = new AssignOpportunityToCSBatch(q);
        Database.executebatch(b);
	}
}