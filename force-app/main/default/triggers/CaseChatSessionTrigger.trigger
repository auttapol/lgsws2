trigger CaseChatSessionTrigger on Case (after update) {
	System.debug('CaseChatSessionTrigger');
	// Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true';
	if (true) {
		Set<Id> caseId = Trigger.newMap.keySet();
		List<iigproduct_2__ChatSession__c> chatSessionList = [
			SELECT Id, iigproduct_2__Case__c, iigproduct_2__Category__c
			FROM iigproduct_2__ChatSession__c
			WHERE iigproduct_2__Case__c IN :caseId
		];
		for (iigproduct_2__ChatSession__c chatSession : chatSessionList) {
			if (Trigger.isUpdate && chatSession.iigproduct_2__Case__c != null) {
				Id chatSessionCaseId = chatSession.iigproduct_2__Case__c;
				Case oldCase = null;
				Case newCase = null;
				if (Trigger.oldMap.containsKey(chatSessionCaseId)) {
					oldCase = Trigger.oldMap.get(chatSessionCaseId);
				}
				if (Trigger.newMap.containsKey(chatSessionCaseId)) {
					newCase = Trigger.newMap.get(chatSessionCaseId);
				}
				Boolean caseNotNull = (oldCase != null && newCase != null) ? true : false;
				if (oldCase.Category__c != newCase.Category__c && caseNotNull) {
					chatSession.iigproduct_2__Category__c = newCase.Category__c;
				}
			}
		}
		// if (iigproduct_2__ChatSession__c.sObjectType.getDescribe().isUpdateable()) {
		update chatSessionList;
		// }
	}
	System.debug('EndOfCaseChatSessionTrigger');
}