public class QuickCaseController {
    
	public string quickIssue {get;set;}
	public Id costomerId {get;set;}
	public Boolean errorMessage {get;set;}
	public List<User> currentUser {
		get{
			if(currentUser==null){
				currentUser = new List<User>();
			}
			return currentUser;
		}
		set;
	}
	//public List<SelectOption> caseList {get;set;}
	public QuickCaseController(ApexPages.StandardSetController stdController){
		currentUser = [Select ID, Employee_ID__c from User where username = : userinfo.getUserName() limit 1];
		
		costomerId = apexpages.currentpage().getparameters().get('id');
		errorMessage = false;
		system.debug(costomerId);
	}
	public List<SelectOption> getCaseList()
	{
		List<SelectOption> options = new List<SelectOption>();
		List<Quick_case__c> quickCaseList = [SELECT Quick_Issue__c,Active__c FROM Quick_case__c where Active__c = true];
		string defult = '--None--';
		for( Quick_case__c value : quickCaseList)
		{
			options.add(new SelectOption(value.Quick_Issue__c,value.Quick_Issue__c));
		}
		if(options.size()>0){
			defult = options.get(0).getValue();
			options.sort();
		}
		else{
			options.add(new SelectOption(defult,defult));
			defult = options.get(0).getValue();
		}

	   	quickIssue = defult;
	   	system.debug('quickIssue'+quickIssue);
	   	return options;
	}

	public PageReference save(){
		
		system.debug('---save--- with '+quickIssue);
		

		List<Quick_case__c> quickCaseList = [SELECT Quick_Issue__c,Subject__c,Active__c,Segment__c,Category__c
											,Problem_Channel__c,Product_Service__c,Issue__c,Service_issue_EN__c,Description__c,Responsible_BU__c
											,Problem_Type__c,Journey__c,FCR_Flag__c,Status__c,Service_Type_Code__c,Close_By_BU__c,Severity__c
											,Priority__c,Channel__c,Issue_Cause__c,Issue_Cause_Detail__c,Resolution__c,Resolution_Detail__c 
											FROM Quick_case__c where Quick_Issue__c =: quickIssue LIMIT 1];

		List<Task> callTaskList = [select ID, Call_Agent_Id__c, Call_Log_ID__c, Call_Start_Datetime__c, Call_Number__c,
                                       recordtypeID, CreatedDate from Task WHERE Call_Agent_Id__c = : currentUser[0].Employee_ID__c
                                               AND CreatedDate >= : Datetime.now().addHours(-1)
                                               AND RecordType.Name  = 'Call Log Record Type' AND Call_Log_ID__c != null
                                                       ORDER BY CreatedDate DESC LIMIT 1 ];

		List<Account> customer = [SELECT Phone, Name, Id, Mobile_Number_PE__c FROM Account where Id =: costomerId];
		try{
			if(quickCaseList.size()>0){
				Case caseOb = new Case();
					caseOb.Subject = quickCaseList.get(0).Subject__c; 
					caseOb.PTA_Segment__c = quickCaseList.get(0).Segment__c; 
					caseOb.Category__c = quickCaseList.get(0).Category__c;
					caseOb.Sub_Category__c = quickCaseList.get(0).Problem_Channel__c;
					caseOb.Product_Category__c = quickCaseList.get(0).Product_Service__c;
					caseOb.Issue__c = quickCaseList.get(0).Issue__c;
					caseOb.Service_issue_EN__c = quickCaseList.get(0).Service_issue_EN__c;
					caseOb.Description = quickCaseList.get(0).Description__c;
					caseOb.Responsible_BU__c = quickCaseList.get(0).Responsible_BU__c;
					caseOb.Problem_Type__c = quickCaseList.get(0).Problem_Type__c;
					caseOb.Journey__c = quickCaseList.get(0).Journey__c;
					caseOb.FCR__c = quickCaseList.get(0).FCR_Flag__c;
					caseOb.Status = quickCaseList.get(0).Status__c;
					caseOb.Service_Type_Matrix_Code__c = quickCaseList.get(0).Service_Type_Code__c;
					caseOb.Closed_By_BU__c = quickCaseList.get(0).Close_By_BU__c;
					caseOb.Case_Severity__c = quickCaseList.get(0).Severity__c;
					caseOb.Priority = quickCaseList.get(0).Priority__c;
					caseOb.Origin = quickCaseList.get(0).Channel__c;
					caseOb.Root_Cause_List__c = quickCaseList.get(0).Issue_Cause__c;
					caseOb.Root_Cause__c = quickCaseList.get(0).Issue_Cause_Detail__c;
					caseOb.Resolution_LIst__c = quickCaseList.get(0).Resolution__c;
					caseOb.Resolution__c = quickCaseList.get(0).Resolution_Detail__c;

					caseOb.OwnerId = UserInfo.getUserId();
					caseOb.Quick_Case__c = true;
					caseOb.AccountId = costomerId;
					if (callTaskList.size() > 0) {
                		caseOb.Call_Log_ID__c = callTaskList[0].Call_Log_ID__c;
                		caseOb.Call_Number__c = callTaskList[0].Call_Number__c;
                		caseOb.Call_Start_Datetime__c = callTaskList[0].Call_Start_Datetime__c;
            		}
				insert caseOb;

				PageReference CasePage = new ApexPages.StandardController(caseOb).view();
        		CasePage.setRedirect(true);

        		return CasePage;
			}
			else{
            	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Quick_Case_ERR001));
            	errorMessage = true;
				return null;
			}
		}
		
		catch (Exception e) {
			errorMessage = true;
            ApexPages.addmessages(e);
            return null;
		}

	}

}