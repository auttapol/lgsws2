public class viewECMfileController {
    public String ecmFile {get;set;}
    
    private String repId;
    private String objId;   
    public String obId {get;set;}
    public string contentType{get;set;}
    public Boolean typePDF{get;set;}
    public Boolean errorMessage{get;set;}
    public Boolean isAllowedEdit{get;set;}
    
    public static AppConfig__c appCon_Endpoint {
        get
        { 
            if( appCon_Endpoint == null)
            {
                appCon_Endpoint = AppConfig__c.getValues('ECM_Endpoint');
            }
            return appCon_Endpoint;
        } 
        set; 
    }

    public static App_Config__mdt appConMeta_Timeout { 
        get
        { 
            if( appConMeta_Timeout == null)
            {
                appConMeta_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REQUEST_TIMEOUT']; 
            }
            return appConMeta_Timeout;
        } 
        set; 
    }

    public viewECMfileController()
    {
        obId = apexpages.currentpage().getparameters().get('obId');
        isAllowedEdit = true;
        typePDF = false;
    }

    public PageReference getStream()
    {
        try {
        ECM_Repository__c ecmRepo = [SELECT Customer_Firstname_EN__c, Customer_Firstname__c, Customer_Lastname_EN__c, Customer_Lastname__c,
                                    ECM_App_ID__c, ECM_Uploaded_By__c, ECM_Uploaded_Date_Time__c, E_Client_Suitability__c, File_Name__c,
                                    Is_ECM_Upload__c, Object_ID__c, Repository__c, Uploaded_By__c, Case__c,CreatedDate, Id ,CreatedById
                                    FROM ECM_Repository__c where Object_ID__c =: obId];
        //system.debug('obId zz '+obId);
        boolean allowedView = allowEdit(ecmRepo.Case__c,ecmRepo.CreatedById);
        if(!allowedView){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_Edit_NotAuthorizedMsg));
            isAllowedEdit = false;
        }
        else{
            isAllowedEdit = true;
            List<Case> caseMaster = [SELECT Id,CaseNumber,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: ecmRepo.Case__c];
            List<Account> accList = [SELECT Id, First_Name_ENG_PE__c, Last_Name_PE_Eng__c, First_name_PE__c, Last_name_PE__c,Core_Banking_Suggested_Segment__c
                                    FROM Account where id =:caseMaster[0].AccountId];
            
            string caseNumber = caseMaster[0].CaseNumber;
            string appId = caseMaster[0].CaseNumber;
            String repositoryId = ecmRepo.Repository__c;
            String objectId = string.valueOf(ecmRepo.Object_ID__c);
            system.debug('repositoryId '+repositoryId);
            system.debug('objectId '+objectId);
            
            //
            UploadToECMController serviceECM = new UploadToECMController();
            UploadToECMController.viewECM res = serviceECM.viewInECM(repositoryId,objectId);

            if(res.succesView){
                onlineLog(caseNumber,appId,caseMaster,accList,res);
                ecmFile = res.ecmFile;
                contentType = res.contentType;
                system.debug('contentType11 '+contentType);
                if(contentType.contains('application')){
                    typePDF = true;
                }
            }
            else{
                onlineLog(caseNumber,appId,caseMaster,accList,res);
                system.debug('res.errorMessage '+res.errorMessage);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, res.errorMessage));
                errorMessage = true;
            }
        }
        } catch (Exception e) {
            errorMessage = true;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }

    private void onlineLog(String caseNumber,String appId,List<Case> caseMaster,List<Account> accList,UploadToECMController.viewECM res){
        boolean isSuccess = res.succesView;
        String customerName = caseNumber;
        String errorMessageRespone = res.errorMessage;
        String msLogId = appId;
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = caseMaster[0].Customer_ID_Number__c;
        String serviceName = 'View Case Attachment ECM';
        string requestBody=res.requestToJSON;
        string responseBody=res.responseToJSON;
        Account acc=accList[0];
        DateTime startTime = res.startTime;
        DateTime endTime = res.endTime;
        String base64Data = res.base64Data;
        OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessageRespone, msLogId , userName, rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data );
    }

    private boolean allowEdit(Id caseId,Id ownerId){

        boolean isAllowedView = false;

        if(UserInfo.getUserId()==ownerId){
            isAllowedView = true;
        }
        else{
            UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess
                                            WHERE UserId = : UserInfo.getUserId()
                                                    AND RecordID = : caseId
                                                            //AND HasReadAccess = True
                                           ];
            Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c FROM case WHERE ID = :caseId];

            if( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
                isAllowedView = true;
            }
            else{
                isAllowedView = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
            }
        }
        return isAllowedView;
    }

}