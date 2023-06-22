trigger CaseAutoCreateTrigger on AgentWork (before insert, after update) {
	System.debug('CaseAutoCreateTrigger');
	// Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true';
	// System.debug('RunTrigger: ' + RunTrigger);
	// filter all chatSession__c from AgentWork
	if (true) {
		List<Id> chatSessionIdList = new List<Id>();
		List<Id> socialPostIdList = new List<Id>();
		List<Id> caseIdList = new List<Id>();
		Map<Id, AgentWork> agentWorkMap = new Map<Id, AgentWork>();
		
		for (AgentWork agentWork : Trigger.New) {
			System.debug('agentWork: ' + agentWork);
			// acccept datetime
			Datetime workAcceptDateTime = agentWork.AcceptDateTime;
			// accecpt status == Opened
			String workStatus = agentWork.Status;
			Id OwnerId = agentWork.OwnerId;
			// workItemType == chatSession__c
			Schema.SObjectType workItemType = agentWork.WorkItemId.getSObjectType();

			if (workAcceptDateTime != null && workStatus == 'Opened') {
				Schema.SObjectType wiObjectType = agentWork.WorkItemId.getSObjectType();
				
				if (Schema.iigproduct_2__ChatSession__c.getSObjectType() == wiObjectType) {
					Id chatSessionId = agentWork.WorkItemId;
					chatSessionIdList.add(chatSessionId);
					agentWorkMap.put(chatSessionId, agentWork);
				// } else if (Schema.Social_Post__c.getSObjectType() == wiObjectType) {
				// 	Id socialPostId = agentWork.WorkItemId;
				// 	socialPostIdList.add(socialPostId);
				// 	agentWorkMap.put(socialPostId, agentWork);
				} else if (Schema.Case.getSObjectType() == wiObjectType) {
					Id caseId = agentWork.WorkItemId;
					caseIdList.add(caseId);
					agentWorkMap.put(caseId, agentWork);
				}
			}
		}

		if (chatSessionIdList.size() > 0) {
			CaseAutoCreateTriggerHandler.afterUpdate(chatSessionIdList, agentWorkMap);
		}

		// if (socialPostIdList.size() > 0) {
		// 	CaseAutoCreateTriggerHandler.afterUpdateForSocialPost(socialPostIdList, agentWorkMap);
		// }
		
		if (caseIdList.size() > 0) {
			CaseAutoCreateTriggerHandler.afterUpdateForCase(caseIdList, agentWorkMap);
		}
	}
	System.debug('EndOfCaseAutoCreateTrigger');
}