public class DeleteCaseECMController {
	public Id ecmId {get;set;}
	public boolean errorMessage{get;set;}
	public boolean displayPopUp{get;set;}
	public List<ECM_Repository__c> ecm{get;set;}
    public  List<Case> caseMaster{get;set;}
	public DeleteCaseECMController(ApexPages.StandardController stdController){
		ecmId = stdController.getRecord().id;
		system.debug(ecmId);
		displayPopUp = true;
	}
	public PageReference deleteECM(){
		
		system.debug('<-----------Delete------------>!!! ');

		errorMessage = false;
		displayPopUp = false;

		
		
		 ecm = [SELECT Customer_Firstname_EN__c, Customer_Firstname__c, Customer_Lastname_EN__c, Customer_Lastname__c,
                                    ECM_App_ID__c, ECM_Uploaded_By__c, ECM_Uploaded_Date_Time__c, E_Client_Suitability__c, File_Name__c,
                                    Is_ECM_Upload__c, Object_ID__c, Repository__c, Uploaded_By__c, Case__c,CreatedDate, Id ,CreatedById 
                                    FROM ECM_Repository__c Where Id =:ecmId];

        boolean isAllowedDelete = allowDelete(ecm[0].Case__c,ecm[0].CreatedById);
        if(!isAllowedDelete){
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ECM_Case_Delete_Permission));
			errorMessage = true;
        }
        else{
        	//system.debug('else');
        	caseMaster = [SELECT Id,CaseNumber,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: ecm[0].Case__c];

			List<Account> accList = [SELECT Id, First_Name_ENG_PE__c, Last_Name_PE_Eng__c, First_name_PE__c, 
											Last_name_PE__c,Core_Banking_Suggested_Segment__c,ID_Type_PE__c
									FROM Account where id =:caseMaster[0].AccountId];

			string caseNumber = caseMaster[0].CaseNumber;
	        string appId = caseMaster[0].CaseNumber+Datetime.now().format('YYYYMMddHHmmss');

	        system.debug(ecm[0]);
			if(ecm[0].Case__c !=null){
				String repositoryId = ecm[0].Repository__c;
				String objectId = string.valueOf(ecm[0].Object_ID__c);
				//objectId = '';
				string description=null;

	            UploadToECMController service = new UploadToECMController();
				UploadToECMController.deleteECM res = service.deleteInECM(repositoryId,objectId);
				system.debug('res.succesDelete '+res.succesDelete);
				if(res.succesDelete){
					onlineLog(true,caseNumber,appId,caseMaster,accList,res);
					deleteRepo(ecm[0].Id);
					//PageReference CasePage = new ApexPages.StandardController(caseMaster[0]).view();
		        	//CasePage.setRedirect(true);
		        	//return CasePage;
                    return null;
				}
				else{
					onlineLog(false,caseNumber,appId,caseMaster,accList,res);
					system.debug('res.errorMessage '+res.errorMessage);
					ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, res.errorMessage));
					errorMessage = true;
				}
			}
			else{
				//system.debug('tetstets '+description);
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.ECM_Case_Delete));
				errorMessage = true;
			}
        }
		return null;
	}
    
    public PageReference redirect(){
		PageReference CasePage = new ApexPages.StandardController(caseMaster[0]).view();
		CasePage.setRedirect(true);
		return CasePage;
	}

	public void deleteRepo(Id ecmId){
		ECM_Repository__c ecmRp = [select id from ECM_Repository__c where id =:ecmId ];
		delete ecmRp;
		system.debug('-----delete succes-----');
	}


	private void onlineLog(boolean deleteSuccess,String caseNumber,String appId,List<Case> caseMaster,List<Account> accList,UploadToECMController.deleteECM res){
		boolean isSuccess = deleteSuccess;
		String customerName = caseNumber;
		String errorMessageRespone = res.errorMessage;
		String msLogId = appId;
		String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		String rmId = caseMaster[0].Customer_ID_Number__c;
		String serviceName = 'Delete Case Attachment ECM';
		string requestBody=res.requestToJSON;
		string responseBody=res.responseToJSON;
		Account acc=accList[0];
		DateTime startTime = res.startTime;
		DateTime endTime = res.endTime;
		String base64Data = '';

		OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessageRespone, msLogId , userName, rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data );
	}

	private boolean allowDelete(Id caseId,Id ownerId){

		boolean isAllowedEdit = false;

		if(UserInfo.getUserId()==ownerId){
			isAllowedEdit = true;
		}
		else{
			UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = : UserInfo.getUserId()
                                                    AND RecordID = : caseId
                                                            //AND HasReadAccess = True
                                           ];
        	Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c FROM case WHERE ID = :caseId];

	        if( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
	        	isAllowedEdit = true;
	        }
	        else{
	        	isAllowedEdit = false;
	        	//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
	        }
		}
        return isAllowedEdit;
	}
}