public without sharing class PWARMController {
    public String userId {get; set;}
    public String userFirstName {get; set;}
    public String userFirstNameTH {get; set;}
    public String userLastName {get; set;}
    public String userLastNameTH {get; set;}
    public String userName {get; set;}
    public String userNameTH {get; set;}
    public String mobileNumber {get; set;}
    public String employeeId {get; set;}
    public Boolean isValidEmployee {get; set;}
    public transient string csvAsString {get;set;} //atk
    public transient Blob csvFileBody   {get;set;} //atk
    public transient String UploadPWARMLogID {get;set;} //atk
    public static Integer csvColumnNo = 4; //atk

    public Map<String, List<String>> resultUpdateListUser = new Map<String, List<String>>();

    public Integer maxFileSize {
        get{
            if(maxFileSize == null)
            {
                maxFileSize = 5 * 1024 * 1024;
            }
            return maxFileSize;
        }
        set;
    }

    public String fileSizeError {
        get{
            if(fileSizeError == null)
            {
                fileSizeError = String.format( Label.PWARM_Upload_file_size , new String[]{ String.valueOf( maxFileSize ) }  ) ;
            }
            return fileSizeError;
        }
        set;
    }

    public PWARMController() {
        userId = UserInfo.getUserId();
        userFirstName = UserInfo.getFirstName();
        userLastName = UserInfo.getLastName();
        userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        List<User> u = [SELECT Id, UserRole.Name, First_Name_TH__c, Last_Name_TH__c, Mobile_No__c, Employee_ID__c FROM User WHERE Id =: userId LIMIT 1];

        if (u.size() > 0) {
            userFirstNameTH = u[0].First_Name_TH__c;
            userLastNameTH = u[0].Last_Name_TH__c;
            userNameTH = userFirstName + ' ' + userLastName;
            mobileNumber = u[0].Mobile_No__c;
            employeeId = u[0].Employee_ID__c;
        } else {
            userFirstNameTH = null;
            userLastNameTH = null;
            userNameTH = null;
            mobileNumber = null;
            employeeId = 'No Employee ID';
        }

        isValidEmployee = false;
        List<PWA_Admin__mdt> metadataList = [SELECT Role__c FROM PWA_Admin__mdt];
        Set<String> metadataSet = new Set<String>();
        for (PWA_Admin__mdt m : metadataList) {
            metadataSet.add(m.Role__c);
        }
        if (metadataSet.contains(u[0].UserRole.Name)) {
            isValidEmployee = true;
        }
    }

    public Boolean getIsAllowedUpload() 
	{
		// Check if any upload job still running by current user and last modify with in today 
		Upload_PWA_RM_Log__c[] activeJobs = [
											SELECT ID,Owner.id,LastModifiedDate,
                                                upload_status__c
											FROM Upload_PWA_RM_Log__c
											WHERE upload_status__c != 'Finish'
											AND Owner.Id = :UserInfo.getUserID()
											AND CreatedDate > YESTERDAY
							];
        // System.debug('TT' + activeJobs + UserInfo.getUserID());
		if(  activeJobs.size() > 0 ) {
			return false;
		} else {
        	return true;
        }
        // return true;
    }
    
    public List<Upload_PWA_RM_Log__c> getUploadLogs()
	{
		return [SELECT ID, CreatedDate, Name, File_Name__c,
                Total_Record__c, Total_Success__c, Total_Fail__c,
				(SELECT Id, Name FROM Attachments LIMIT 1) 
				FROM Upload_PWA_RM_Log__c 
				WHERE Upload_PWA_RM_Log__c.Owner.Id = :UserInfo.getUserID()
        		ORDER BY CreatedDate DESC];
	}

    public PageReference UpdateUser() {
        PageReference result = ApexPages.currentPage();

        try {
            List<User> u = [SELECT Id, First_Name_TH__c, Last_Name_TH__c, Mobile_No__c, Modified_By__c, Modified_Date__c, Allow_Update_Flag__c FROM User WHERE Id =: userId LIMIT 1];
            // System.debug('before update user: ' + u);
    
            if (u.size() > 0) {
                u[0].First_Name_TH__c = userFirstNameTH;
                u[0].Last_Name_TH__c = userLastNameTH;
                u[0].Mobile_No__c = mobileNumber;
                u[0].Modified_By__c = employeeId;
                u[0].Modified_Date__c = Date.today();
                u[0].Allow_Update_Flag__c = true;
    
                update u;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.PWARM_Update_Success));

                result.getParameters().put('tabName', 'tab-default-1__item');
                result.setRedirect(false);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<String> errorList = ex.getMessage().split(',', 2);
            if (errorList[0].contains('Invalid phone')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorList[0]));   
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorList[1].substring(0, errorList[1].length()-4)));
            }
        }

        return result;
    }

    public void Cancel() {
        List<User> u = [SELECT Id, First_Name_TH__c, Last_Name_TH__c, Mobile_No__c FROM User WHERE Id =: userId LIMIT 1];

        if (u.size() > 0) {
            userFirstNameTH = u[0].First_Name_TH__c;
            userLastNameTH = u[0].Last_Name_TH__c;
            userNameTH = userFirstName + ' ' + userLastName;
            mobileNumber = u[0].Mobile_No__c;
        } else {
            userFirstNameTH = null;
            userLastNameTH = null;
            userNameTH = null;
            mobileNumber = null;
        }
    }

    //atk start
    public PageReference importCSVFile(){
        //Boolean isUTF8 = true;
        //string csvdetail;
		System.debug('importCSVFile start');
		// Do need funtionallity to check unicode? currently is always true
        //if(isUTF8){

        String csvFileString = '';
        PageReference result = ApexPages.currentPage();
        result.getParameters().put('tabName', 'tab-default-2__item');
        result.setRedirect(false);

        try 
        {
            csvFileString = csvFileBody.tostring();
            // System.debug('csvFileString :' + csvFileString);
        } 
        catch(Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() );
            ApexPages.addmessage(errorMessage);
            // return null;
            return result;
        }
        

        String csvEOL = getEOL(csvFileString);
        System.debug('csvEOL :' +csvEOL);

        if( csvEOL == null )
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,Label.PWARM_Upload_Profile_Invalid_File);
            ApexPages.addmessage(errorMessage);
            // return null;
            return result;
        }

        // no. of line not count header
        Integer noLine = csvFileString.countMatches(csvEOL) - 1;          

        System.debug('noLine :' +noLine);
        if( noLine > maximumImportRows )
        {	
            List<String> fillers = new String[]{ String.valueOf(maximumImportRows), String.valueOf(noLine)};
            String messageInvalidRow = String.format( Label.PWARM_Upload_Profile_Invalid_Row , fillers ); 
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,messageInvalidRow);
            ApexPages.addmessage(errorMessage);
            // return null;
            return result;
        }

        Matcher m = Pattern.compile(csvEOL).matcher(csvFileString);
        String headerStr = '';
        String contentStr1 = '';

        Integer lastEnd = 0;

        if(m.find())
        {
            headerStr = csvFileString.substring(lastEnd, m.start());
            lastEnd = m.end();
        }

        if(m.find())
        {
            contentStr1 = csvFileString.substring(lastEnd, m.start());
            //lastEnd = m.end();
        }
        System.debug('headerStr :' +headerStr);
        System.debug('contentStr1 :' +contentStr1);

        // System.debug(headerStr + ' ' + contentStr1);
        //Verify number of column
        // String[] csvrowdetails = safeSplit(csvFileString, csvEOL );   

        List<String> header = headerStr.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
        List<String> content = contentStr1.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);

        System.debug('HEAD ' + header.size() + ' \ncont ' + content.size() + PWARMController.csvColumnNo);

        // if( header.size() != PWARMController.csvColumnNo 
        // 	|| content.size() != PWARMController.csvColumnNo )
        // {
        // 	List<String> fillers = new String[]{ String.valueOf(PWARMController.csvColumnNo) };
        // 	// String messageInvalidColumn = String.format( Label.PWARMController , fillers );
        // 	// ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, messageInvalidColumn );
        //     // ApexPages.addmessage(errorMessage);
        // 	return null;
        // }
        try {
            importUserToPWARM();
            return result;
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() );
            ApexPages.addmessage(errorMessage);
            // return null;
            return result;
        }

        // return result;
    }
    public static List<String> safeSplit(String inStr, String delim)
	{
	    Integer regexFindLimit = 100;
	    Integer regexFindCount = 0;
	    
	    List<String> output = new List<String>();
	    
	    Matcher m = Pattern.compile(delim).matcher(inStr);
	    
	    Integer lastEnd = 0;
	
	    while(!m.hitEnd())
	    {
	        while(regexFindCount < regexFindLimit && !m.hitEnd())
	        {
	            if(m.find())
	            {
	                output.add(inStr.substring(lastEnd, m.start()));  
	                lastEnd = m.end();
	            }
	            else
	            {
	                output.add(inStr.substring(lastEnd));
	                lastEnd = inStr.length();
	            }
	            
	            regexFindCount++;
	        }
	
	        // Note: Using region() to advance instead of substring() saves 
	        // drastically on heap size. Nonetheless, we still must reset the 
	        // (unmodified) input sequence to avoid a 'Regex too complicated' 
	        // error.
	        m.reset(inStr);        
	        m.region(lastEnd, m.regionEnd());
	        
	        regexFindCount = 0;
	    }
	    
	    return output;
	}

    public static string getEOL(String uploadCSV)
    {
        //List of EOL , \r\n must be first in order to check before \r 
        List<String> eolExpList = new List<String>{'\r\n','\r'};

        for( String eolExp : eolExpList )
        {
            System.debug('eolExp :' +eolExp);
            Matcher m = Pattern.compile(eolExp).matcher(uploadCSV);

            // \r\n contain on EOF
            // check that match is not end of file
            if( m.find() &&  m.end() < uploadCSV.length() )
            { 
                return eolExp;
            }
        }   

        return null;
    }

    private Integer maximumImportRows{
        get;
    	// get{
        //     if(maximumImportRows==null){
        //          RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Max_Upload_Line__c
        //            from RTL_Upload_Campaign_Member__mdt 
        //            where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

        //            maximumImportRows = integer.valueOf(ucmMeta.RTL_Max_Upload_Line__c);
        //     }
        //     return maximumImportRows;
        // }
        set;
    }

    private void importUserToPWARM()
	{
				// new Upload_PWA_RM_Log__c
            	Upload_PWA_RM_Log__c uprl = new Upload_PWA_RM_Log__c();
  
  				// Assign User Id to Upload_PWA_RM_Log__c 
  				
  				String batchName = '';
                Datetime dt=  datetime.now();
  				String dtStr = String.valueOf(dt);
                batchName = 'UploadUser-' + dtStr;
                System.debug('batchName:' +batchName);
                
                // uprl.RTL_IsInProgress__c = true; //atk
                // uprl.RTL_UploadStatus__c = 'Starting'; //atk
                // Insert new Upload_Campaign_Member_Logs__c
                uprl.Upload_Status__c = 'Starting';
                String filename = 'Upload PWA profile ';
                Date dtoday = date.today();
                String todayStr = string.valueOf(dtoday);
                todayStr=todayStr.replace('-','');
                                System.debug('todayStr :' +todayStr);

                uprl.File_Name__c = csvAsString;
                // uprl.Name = filename+todayStr+'.csv';
                uprl.File_Name__c = filename+todayStr+'.csv';
                uprl.Total_Fail__c = 0;
                uprl.Total_Record__c = 0;
                uprl.Total_Success__c = 0;
                insert uprl;
                
				// Create new attachement from uploaded CSV 
				
                Attachment importattachmentfile = new Attachment();
                importattachmentfile.parentId = uprl.id;
                // adjust attachment file name here
                // importattachmentfile.name = 'Import Csv file : '+batchName+'.csv';
                importattachmentfile.name = csvAsString.substring(0, csvAsString.length()-4) + '_result.csv';
                // importattachmentfile.name = 'Upload PWA profile ' + todayStr + '.csv';
                
                
                importattachmentfile.IsPrivate = true;
                importattachmentfile.body = csvFileBody;
                insert importattachmentfile;

				// Assign attacthment (CSV) to Upload_PWA_RM_Log__c
                uprl.Import_CSV_file_ID__c = importattachmentfile.id;
				
				// Update Upload_PWA_RM_Log__c (Add attachment)
                uprl.Upload_Status__c = 'In Progress';
                update uprl;

                // Get ID of  Upload_PWA_RM_Log__c 
                UploadPWARMLogID = uprl.id;

				// Change Batch ot queueable process
                // UploadCampaignMemberSplitFileBatch ucmbatch = new UploadCampaignMemberSplitFileBatch(UploadPWARMLogID);  
                // Database.executeBatch(ucmbatch ,2000);
                
                // Queueable process to async split file
                // UploadUserQueue splitFileQueue = new UploadUserQueue(uprl.id);

                // Process with no queue
                UploadUserNoQueue(uprl.id, importattachmentfile.id);
                
                if(!Test.isRunningTest()){
                //   System.enqueueJob(splitFileQueue); 
                }
	}
	
    public static String processCSVdata(String csvData)
	{
		return csvData.removeStart('\"').removeEnd('\"');
    }
    
    public void UploadUserNoQueue(String logID, String attachmentID) {

        Upload_PWA_RM_Log__c uprl = [SELECT Id, File_Name__c, Total_Record__c, Total_Success__c, Total_Fail__c, Import_CSV_file_ID__c
                                        FROM Upload_PWA_RM_Log__c WHERE ID =:logID Limit 1 ];
        System.debug('uprl :' + uprl); 

        // If can't find   Upload_PWA_RM_Log__c from   logID , return false. (Maybe do something)	
    	if( uprl == null )
    	{
    		return;
    	}
    	
    	uprl.Upload_Status__c = 'In Progress';
    	update uprl;
    		
		// Get Upload Profile User's full version attachement
   		Attachment csvfile = [SELECT ID,Body,ParentID from Attachment WHERE ParentID=:uprl.id LIMIT 1];

   		// Process string to List for each line
   		// String csvdetail = csvfile.Body.tostring();        

        // String csvEOL = PWARMController.getEOL(csvfile.Body.tostring());

   		// // String[] csvrowdetails = PWARMController.safeSplit(csvfile.Body.tostring(), csvEOL);
        // System.debug('csvEOL:' +csvEOL);
        // System.debug('csvrowdetails:' +csvrowdetails);

        // // Get total rows
		// //Integer fileRowNum = csvrowdetails.size();
        
        // //reset variable to recovery heapsize
        // csvfile = null; 
		
   		// List<Attachment> csvList = new List<Attachment>();
   		        
		// // No need to check row number , do split event file size < NoPerFile (Line per file)
        // //if(fileRowNum >=NoPerFile){
                       
        // // Get header line string, this should add in the first line of each file
        // String headerstring = csvrowdetails.get(0) + '\r\n';    
        // System.debug('headerstring:'+headerstring);           
                       
        // atk start
        // Attachment bodyfile = [SELECT ID, Body, ParentID FROM Attachment WHERE ParentID =: ucmbId LIMIT 1];	

        String csvdetail = csvfile.body.tostring();
                
        // Prepare data from split CSV
        List<String> csvdetail2 = new list<String>();

        String csvEOL = PWARMController.getEOL(csvdetail);
        // System.debug('csvEOL :' +csvEOL);
        csvdetail2.addAll( PWARMController.safeSplit(csvdetail, csvEOL) );
        // System.debug('csvdetail2-1 :' +csvdetail2);
        Integer fileRowNum = csvfile.Body.tostring().countMatches(csvEOL) - 1; 
        // System.debug('csvfile.Body.tostring() :' +csvfile.Body.tostring());
        // System.debug('fileRowNum:' +fileRowNum);
        // System.debug('csvdetail2 :' + csvdetail2.size());
        list<user> listUserUpdate = new list<user>();

        Matcher m = Pattern.compile(csvEOL).matcher(csvdetail);
        String headerStr = '';
        String contentStr1 = '';

        Integer lastEnd = 0;

        if(m.find())
        {
            headerStr = csvdetail.substring(lastEnd, m.start());
            lastEnd = m.end();
        }

        if(m.find())
        {
            contentStr1 = csvdetail.substring(lastEnd, m.start());
            //lastEnd = m.end();
        }
        System.debug('headerStr :' +headerStr);
        // System.debug('contentStr1 :' +contentStr1);
        List<String> header = headerStr.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
        List<String> content = contentStr1.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
        
        System.debug('HEAD ' + header.size() + ' \ncont ' + content.size() + PWARMController.csvColumnNo);
        Boolean isValidHeader = true;

        List<Mapping_Field_Batch_User__mdt> mpList = [SELECT Id, FieldSalesforce__c, FieldHeaderCSV__c FROM Mapping_Field_Batch_User__mdt];
        Map<String, String> mapFieldCSVmeta = new Map<String, String>();
        List<String> validHeaderList = new List<String>();

        for(Mapping_Field_Batch_User__mdt each : mpList){
            mapFieldCSVmeta.put(each.FieldSalesforce__c, each.FieldSalesforce__c);
            validHeaderList.add(each.FieldSalesforce__c);
        }

        for(Integer i = 0; i < header.size(); i++){
            if (!header[i].contains('Employee_ID__c') && header[i] != 'First_Name_TH__c' && header[i] != 'Last_Name_TH__c' && header[i] != 'Mobile_No__c') {
                System.debug('header[i]: ' + header[i]);
                System.debug('header[i].equals(\'Employee_ID__c\'): ' + header[i].equals('Employee_ID__c'));
                isValidHeader = false;
            } 
        }

        System.debug('isValidHeader: ' + isValidHeader);
        if (isValidHeader) {
            // System.debug('mapFieldCSVmeta: ' + mapFieldCSVmeta);

            Set<String> employeeIdSet = new Set<String>(); 
            for(Integer i = 1 ; i < csvdetail2.size() ; i++){
                // System.debug('csvdetail2:' + csvdetail2 +'//ii:'+i);
                // each record data
                List<String> csvRecordDataTemp = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
                // System.debug('csvRecordDataTemp:' +csvRecordDataTemp);
                List<String> csvRecordData = new List<String>();
                // boolean isAllBlank = true;
                
                for( Integer j = 0 ; j < csvRecordDataTemp.size() ; j++){
                    System.debug('j:+'+j+'--:'+csvRecordDataTemp[j]);

                    csvRecordData.add(PWARMController.processCSVdata(csvRecordDataTemp[j]));
                    // if(!isAllBlank){

                    //     for(String recorddate : csvRecordData){
                    //         if(recorddate !=null && recorddate !=''){
                    //             isAllBlank = false;
                    //         }
                    //     }
                    // // }
                    // System.debug('isAllBlank :'+isAllBlank);
                }

                System.debug('CSVDATA : ' + csvRecordData + ' size: ' + csvRecordData.size() + ' csvClumnNo: ' + PWARMController.csvColumnNo);
                boolean isAllBlank = true;
                for(String recorddate : csvRecordData){
                    if(recorddate !=null && recorddate !=''){
                        isAllBlank = false;
                    }
                }

                if(!isAllBlank){
                    System.debug('row: ' +i);
                    System.debug('csvRecordData[0]:'+ csvRecordData[0]);
                    System.debug('csvRecordData[1]:'+ csvRecordData[1]);
                    // System.debug('mapFieldCSVmeta: ' + mapFieldCSVmeta);
                    // System.debug('mapFieldCSVmeta.keySet(): ' + mapFieldCSVmeta.keySet());
                    // System.debug('mapFieldCSVmeta.containsKey(): ' + mapFieldCSVmeta.containsKey('Employee_ID__c'));
                    user us = new user();
                    // us.Employee_ID__c =csvRecordData[0];
                    // us.First_Name_TH__c =csvRecordData[1];
                    // us.Last_Name_TH__c =csvRecordData[2];
                    // us.Mobile_No__c =csvRecordData[3];
                    // listUserUpdate.add(us);
                    Integer indexHeader = 0;
                    for(String dataColum : csvRecordData){
                        System.debug('dataColum :'  +dataColum);
                        // System.debug('header['+ indexHeader + ']:' + header[indexHeader]);
                        // System.debug('header == Employee_ID__c:' + header[indexHeader].contains('Employee_ID__c'));
                        if(header[indexHeader].contains('Employee_ID__c') && !mapFieldCSVmeta.containsKey(header[indexHeader])){
                            String FieldSalesforce =  mapFieldCSVmeta.get('Employee_ID__c');
                            us.put(FieldSalesforce ,dataColum) ; //= dataColum
                            employeeIdSet.add(dataColum);
                        }
                        else if(mapFieldCSVmeta.containsKey(header[indexHeader]) && !header[indexHeader].contains('Employee_ID__c')){
                            System.debug('FieldSalesforce:'+mapFieldCSVmeta.get(header[indexHeader]));
                            String FieldSalesforce =  mapFieldCSVmeta.get(header[indexHeader]);
                            us.put(FieldSalesforce ,dataColum) ; //= dataColum
                        }
                        indexHeader++;
                    }
                    us.put('Allow_Update_Flag__c', true);
                    listUserUpdate.add(us);
                }
            }

            // System.debug('listUserUpdate: '  + listUserUpdate);
            // System.debug('listUserUpdate:' +listUserUpdate.size());
            List<User> userIdList = [SELECT Id, Employee_ID__c FROM User WHERE Employee_ID__c IN: employeeIdSet];
            Map<String, String> mapUserIdEmpId = new Map<String, String>();
            
            System.debug('userIdList: ' + userIdList);
            
            for (User u : userIdList) {
                mapUserIdEmpId.put(u.Employee_ID__c, u.Id);
            }

            List<User> listUserUpdateWithId = new List<User>();
            for (User u : listUserUpdate) {
                // System.debug('user to update: ' + u.Employee_ID__c);
                User us = new User();
                us.Employee_ID__c = u.Employee_ID__c;
                us.First_Name_TH__c = u.First_Name_TH__c;
                us.Last_Name_TH__c = u.Last_Name_TH__c;
                us.Mobile_No__c = u.Mobile_No__c;
                us.Allow_Update_Flag__c = true;

                if (mapUserIdEmpId.containsKey(u.Employee_ID__c)) {
                    // has id to update
                    us.Id = mapUserIdEmpId.get(u.Employee_ID__c);
                    listUserUpdateWithId.add(us);
                } else {
                    // has no id to update
                    listUserUpdateWithId.add(us);
                }
            }

            Integer indexListUpdateUser = 0;
            // Integer listUserUpdateSize = listUserUpdate.size();
            try {
                if(listUserUpdate.size()>0){

                    // Database.UpsertResult [] cr = Database.upsert(listUserUpdate,User.Employee_ID__c.Employee_ID__c, false);
                    Database.SaveResult [] cr = Database.update(listUserUpdateWithId, false);

                    // I want to see what was updated / created  
                    integer successRecord = 0 ; 
                    integer FailRecord = 0 ;
                    for(Database.SaveResult result : cr){
                        System.debug(result);
                        if(result.isSuccess()){
                            successRecord++;
                            System.debug('isUpdate! :' + result.getId() );
                            // if(result.isCreated()){
                            //     System.debug('isCreate! :' + result.getId() );
                            // } else {
                            //     System.debug('isUpdate! :' + result.getId() );
                            // }
                            // resultUpdateListUser.put(listUserUpdate[indexListUpdateUser].Employee_ID__c, new List<String>{'Success', ''});
                            resultUpdateListUser.put(listUserUpdateWithId[indexListUpdateUser].Employee_ID__c, new List<String>{'Success', ''});
                        } else{
                            FailRecord++;
                            System.debug('update failed');
                            List<Database.Error> err = result.getErrors();
                            // System.debug('Record fail: ' + listUserUpdateWithId[indexListUpdateUser].Employee_ID__c);
                            // System.debug('Error: ' + err[0].getMessage());

                            // resultUpdateListUser.put(listUserUpdate[indexListUpdateUser].Employee_ID__c, new List<String>{'Failed', err[0].getMessage().replace('\n', '')});

                            String errMsg = err[0].getMessage().replace('\n', '');
                            if (errMsg.contains('Id not specified')) {
                                errMsg = 'Employee Id not found.';
                            }

                            resultUpdateListUser.put(listUserUpdateWithId[indexListUpdateUser].Employee_ID__c, new List<String>{'Failed', errMsg});
                            
                        }
                        indexListUpdateUser++;
                    }

                    ApexPages.getMessages().clear();

                    // process add success fail result to csv
                    List<String> csvListDataAfter = new List<String>();
                    Map<String, List<String>> mapRecordDataAfter = new Map<String, List<String>>();

                    for(Integer i = 1 ; i < csvdetail2.size() ; i++){
                        // each record data
                        List<String> csvRecordDataTemp = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
                        // System.debug('csvRecordDataTemp:' +csvRecordDataTemp);
                        List<String> csvListDataBefore = new List<String>();
                        
                        String ext_EmpId;
                        for( Integer j = 0 ; j < csvRecordDataTemp.size() ; j++){
                            // System.debug('j:+'+j+'--:'+csvRecordDataTemp[j]);
                            if (j == 0) {
                                ext_EmpId = PWARMController.processCSVdata(csvRecordDataTemp[j]);
                                csvListDataBefore.add(PWARMController.processCSVdata(csvRecordDataTemp[j]));
                            } else {
                                csvListDataBefore.add(PWARMController.processCSVdata(csvRecordDataTemp[j]));
                            }
                        }
                        mapRecordDataAfter.put(ext_EmpId, csvListDataBefore);
                        if (resultUpdateListUser.containsKey(ext_EmpId)) {
                            csvListDataBefore.addAll(resultUpdateListUser.get(ext_EmpId));
                        }
                    }
                    // System.debug('mapRecordDataAfter: ' + mapRecordDataAfter);

                    String csvAfter = headerStr + ',Status,Status Text\r\n';

                    for (String key : mapRecordDataAfter.keySet()) {
                        // System.debug('mapRecordDataAfter.get(key): ' + mapRecordDataAfter.get(key));
                        String joinLine = String.join(mapRecordDataAfter.get(key), ',');
                        csvAfter += joinLine + '\r\n';
                    }

                    Attachment att = new Attachment();
                    att.Id = attachmentID;
                    att.Body = Blob.valueOf(csvAfter);

                    update att;

                    uprl.Total_Success__c = successRecord;
                    uprl.Total_Fail__c = FailRecord;
                    uprl.Total_Record__c = successRecord+FailRecord;
                    uprl.upload_status__c = 'Finish';

                    update uprl;

                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Label.PWARM_Upload_Profile_Success));
                }  
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage());
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Occurred. Please contact administrator.'));
                List<String> errorList = ex.getMessage().split(',');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorList[1]));
            }
        } else {
            Attachment att = [SELECT Id from Attachment WHERE Id =: attachmentID LIMIT 1];
            delete att;
            Upload_PWA_RM_Log__c uprl_del = [SELECT Id FROM Upload_PWA_RM_Log__c WHERE ID =: logID Limit 1];
            delete uprl_del;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,Label.PWARM_Upload_Profile_Invalid_Template));
            return;
        }
    }
    //atk end
}