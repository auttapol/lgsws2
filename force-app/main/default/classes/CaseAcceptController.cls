public class CaseAcceptController {
	public Case caseObj {get;set;}
	public Boolean isUpdateSuccess {
		get {
			if(isUpdateSuccess == null) {
				isUpdateSuccess = false;
			}
			return isUpdateSuccess;
		}
		set;
	}
	private Map<Id,UserRecordAccess> recordAccessMap;
	private List<Profile> profile;
	private User currentUser;

	public static String BRANCH_CHANNEL = 'Branch';

	public CaseAcceptController(ApexPages.StandardController std) {
		caseObj = (Case)std.getRecord();

		caseObj = [SELECT Id,Subject,OwnerId,CaseNumber,Is_My_Branch__c
                        FROM Case 
                        WHERE ID=:caseObj.id LIMIT 1 ];
		recordAccessMap = RTL_Utility.queryRecordAccess(new Set<Id>{caseObj.id},System.UserInfo.getUserId());
		profile = [SELECT Id, Name FROM Profile WHERE Id =: System.UserInfo.getProfileId()];
		currentUser = [SELECT Id,RTL_Channel__c  FROM User WHERE Id =:  System.UserInfo.getUserId() ];
			
	}

	public PageReference acceptRecord(){
		try{
			caseObj.OwnerId = System.UserInfo.getUserId();
        	update caseObj;

			// String message = '';
			// List<String> messageParam;
			// messageParam = new String[]{caseObj.CaseNumber};
			// message = String.format(Label.Case_INFO001,messageParam);
			isUpdateSuccess = true;
			return UserInfo.getUiThemeDisplayed() == 'Theme3' ? new PageReference('/'+caseObj.id) : null;

		// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
		}catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}

		
		     
	}

	public PageReference validateAcceptPermission(){
		String ownerId = String.ValueOf(caseObj.OwnerId);
		UserRecordAccess recordAccess = recordAccessMap.containsKey(caseObj.id)?recordAccessMap.get(caseObj.id):null; 

		if(ownerId == System.UserInfo.getUserId())
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR001));
			return null;
		}
		else if(OwnerId.startsWith('005'))
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR002));
			return null;
		}
		else if( currentUser.RTL_Channel__c != BRANCH_CHANNEL && recordAccess != null && recordAccess.hasTransferAccess == false)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR002));
			return null;
		}
		else if( currentUser.RTL_Channel__c == BRANCH_CHANNEL && caseObj.Is_My_Branch__c == false)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR002));
			return null;
		}
		//else if(profile[0].Name.containsIgnoreCase('Retail') == false && recordAccess != null && recordAccess.hasTransferAccess == false)
		//{
		//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR002));
		//	return null;
		//}
		//else if(profile[0].Name.containsIgnoreCase('Retail') == true && caseObj.Is_My_Branch__c == false)
		//{
		//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Case_ERR002));
		//	return null;
		//}
		else
		{
			return acceptRecord();
		}

	}
}