global class RTL_UploadCampaignMemberGenerateLogBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    private String ucmLID;
    private String ucmbID;
    private RTL_Upload_Campaign_Member_Logs__c ucmL;
    private RTL_Upload_Campaign_Member_Batch__c ucmb;
    global List< String > logsData;

    private Integer itemPerSaveMember {
        get{
                if(itemPerSaveMember==null){
                 RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Line_Save_Per_Batch__c
                   from RTL_Upload_Campaign_Member__mdt 
                   where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

                   itemPerSaveMember = integer.valueOf(ucmMeta.RTL_Line_Save_Per_Batch__c);
            }
            return itemPerSaveMember;
        }
        set;
    }
    
    public RTL_UploadCampaignMemberGenerateLogBatch(RTL_Upload_Campaign_Member_Logs__c uploadCampaignMemLog,RTL_Upload_Campaign_Member_Batch__c uploadCampaignMemBatch) 
    {
        ucml = uploadCampaignMemLog;
    	ucmLID = uploadCampaignMemLog.id;

        ucmb = uploadCampaignMemBatch;
        ucmbID = uploadCampaignMemBatch.id;
    	   	
    	List< String> log = new List< String>();
    	
    	// Add log header
    	logsData = new List< String >();

        String headerCSV = 'Campaign Member Id,Lead Id,';
        headerCSV += '"TMB Cust ID ","Title","First Name","Last Name","Mobile Number","Assigned Branch Code","Assigned Employee ID ","Product Offer ","Promotion","Target/Segmentation","Product Feature","Register Date","Lead Owner ","Assigned Channel - DM","Assigned Channel - Outbound","Assigned Channel - SMS ","Assigned Channel - EDM ","Assigned Channel - Branch ","Assigned Channel - MIB ","Assigned Channel - OBD ","Assigned Channel - Other","Remark 1","Remark 2","Age","ID Type","ID Number","House No/Moo/Soi/Street","City","District","State/Province","ZIP / Postal Code","Phone Number","Income ","Occupation","Email_ ddress","Facebook ID ","Segment ","Cost Per Lead","Source","Update Date","Data Source","Rating","Lead Source","Source Reference","Campaign Lead Source","Campaign Lead Reference","Lead Group","Web Unique ID",';
        headerCSV += 'Campaign Name,Member Type,Status,Status Text';
        logsData.add(headerCSV);
    	
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){  

    	return Database.getQueryLocator([
            SELECT ID,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate,Name,RTL_CampaignID__c,
            RTL_leadOwner__c,RTL_CHANNEL_DM__c,RTL_CHANNEL_OB__c,RTL_CHANNEL_EDM__c,RTL_CHANNEL_SMS__c,
            RTL_CHANNEL_BRANCH__c,RTL_CHANNEL_MIB__c,RTL_CHANNEL_OBD__c,RTL_AssignedBranch__c,RTL_AssignedRM__c ,
            RTL_TMBCustID__c,RTL_Title__c ,RTL_FirstName__c,RTL_LastName__c ,RTL_GENDER__c ,
            RTL_AGE__c ,RTL_ID_Type__c,RTL_ADDRESS1__c ,RTL_ADDRESS2__c ,
            RTL_ADDRESS3__c ,RTL_PROVINCE__c ,RTL_ZIPCODE__c ,RTL_MOBILEPHONE__c ,RTL_HOMEPHONE__c ,
            RTL_INCOME__c ,RTL_OCCUPATION__c ,RTL_Email_Address__c ,RTL_FB_ID__c ,
            // RTL_FB_EMAIL__c ,
            RTL_Segment__c ,RTL_COST_PER_LEAD__c ,RTL_SOURCE__c ,RTL_UPDATE_DATE__c ,RTL_PRODUCT_OFFER__c ,
            RTL_REGISTER_DATE__c ,RTL_DATA_SOURCE__c ,RTL_PROMOTION__c ,RTL_TARGET__c ,RTL_PRODUCT_FEATURE__c ,
            RTL_REMARK1__c ,RTL_REMARK2__c,RTL_Rating__c,RTL_Citizen_ID__c,RTL_CHANNEL_OTHER__c,
            RTL_Upload_Campaign_Member_Logs__c,RTL_ImportStatus__c,RTL_ImportStatusDescription__c,RTL_ImportToType__c,
            RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.name,RTL_Lead__r.id,RTL_ImportToCampaignMemberID__c
            ,LeadSource__c, RTL_Source_Reference__c, RTL_TMB_Campaign_Source__c, RTL_TMB_Campaign_Reference__c, RTL_Customer_Segment__c
            ,RTL_Web_Unique_ID__c
            FROM RTL_Upload_Campaign_Members__c 
            WHERE RTL_Upload_Campaign_Member_Logs__c = : ucmLID 
            AND RTL_Upload_Campaign_Member_Batch__c = : ucmbID
            ORDER BY RTL_Row_No__c ASC
        ]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<RTL_Upload_Campaign_Members__c> scope){
     	     	
     	for( RTL_Upload_Campaign_Members__c uclm : scope )
     	{
     		List< String> logData = new List< String>();
     		
            String camMemId = (uclm.RTL_ImportToCampaignMemberID__c == null )?'':uclm.RTL_ImportToCampaignMemberID__c;
            logData.add( processDataString( camMemId ) );
            logData.add( processDataString( uclm.RTL_Lead__r.id ) );

            logData.add( processDataString( uclm.RTL_TMBCustID__c ) ); //TMB Cust ID    
            logData.add( processDataString( uclm.RTL_Title__c ) ); //Title
     		logData.add( processDataString( uclm.RTL_FirstName__c ) ); //Customer First Name
     		logData.add( processDataString( uclm.RTL_LastName__c ) ); //Customer Last Name
            logData.add( processDataString( uclm.RTL_MOBILEPHONE__c ) ); 
            logData.add( processDataString( uclm.RTL_AssignedBranch__c ) ); //Assigned Branch/Team
            logData.add( processDataString( uclm.RTL_AssignedRM__c ) ); //Assigned RM/Agent

            logData.add( processDataString( uclm.RTL_PRODUCT_OFFER__c ) ); 
            logData.add( processDataString( uclm.RTL_PROMOTION__c ) ); 
            logData.add( processDataString( uclm.RTL_TARGET__c ) ); 
            logData.add( processDataString( uclm.RTL_PRODUCT_FEATURE__c ) ); 
            logData.add( processDataString( uclm.RTL_REGISTER_DATE__c ) ); 

            logData.add( processDataString( uclm.RTL_leadOwner__c ) );	//Lead Owner/Queue   

     		logData.add( processDataString( uclm.RTL_CHANNEL_DM__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_OB__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_SMS__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_EDM__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_BRANCH__c ) );  //Assigned Channel

            logData.add( processDataString( uclm.RTL_CHANNEL_MIB__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_OBD__c ) );  //Assigned Channel
            logData.add( processDataString( uclm.RTL_CHANNEL_OTHER__c ) );  //Assigned Channel

            logData.add( processDataString( uclm.RTL_REMARK1__c ) ); 
            logData.add( processDataString( uclm.RTL_REMARK2__c ) ); 

            logData.add( processDataString( uclm.RTL_AGE__c ) ); 
     		logData.add( processDataString( uclm.RTL_ID_Type__c ) ); //ID Type
            logData.add( processDataString( uclm.RTL_Citizen_ID__c ) ); //ID Number

            logData.add( processDataString( uclm.RTL_ADDRESS1__c ) ); 
            logData.add( processDataString( uclm.RTL_ADDRESS2__c ) );
            
            //Tay start here

            logData.add( processDataString (uclm.RTL_ADDRESS3__c) );

            //Tay stop here


            logData.add( processDataString( uclm.RTL_PROVINCE__c ) ); 
            logData.add( processDataString( uclm.RTL_ZIPCODE__c ) ); 
            logData.add( processDataString( uclm.RTL_HOMEPHONE__c ) ); 
            logData.add( processDataString( uclm.RTL_INCOME__c ) ); 
            logData.add( processDataString( uclm.RTL_OCCUPATION__c ) ); 
            logData.add( processDataString( uclm.RTL_Email_Address__c ) ); 
            logData.add( processDataString( uclm.RTL_FB_ID__c ) ); 
            // logData.add( processDataString( uclm.RTL_FB_EMAIL__c ) ); 

     		logData.add( processDataString( uclm.RTL_Segment__c ) ); 
            logData.add( processDataString( uclm.RTL_COST_PER_LEAD__c ) ); 
            logData.add( processDataString( uclm.RTL_SOURCE__c ) ); 
            logData.add( processDataString( uclm.RTL_UPDATE_DATE__c ) ); 
            logData.add( processDataString( uclm.RTL_DATA_SOURCE__c ) ); 
            logData.add( processDataString( uclm.RTL_Rating__c ) ); 

            logData.add( processDataString (uclm.LeadSource__c));
            logData.add( processDataString (uclm.RTL_Source_Reference__c) );
            logData.add( processDataString (uclm.RTL_TMB_Campaign_Source__c) );
            logData.add( processDataString (uclm.RTL_TMB_Campaign_Reference__c) );
            logData.add( processDataString (uclm.RTL_Customer_Segment__c) );
            logData.add( processDataString (uclm.RTL_Web_Unique_ID__c) );
            
            logData.add( processDataString( uclm.RTL_Upload_Campaign_Member_Logs__r.RTL_Campaign__r.name ) ); //Campaign Name
            logData.add( processDataString( uclm.RTL_ImportToType__c ) ); //Member Type
     		
            logData.add( processDataString( uclm.RTL_ImportStatus__c ) ); //Status
     		logData.add( processDataString( uclm.RTL_ImportStatusDescription__c) ); //Status Text
     		
     		String csvRow = convertToCSVformat(logData);

            //**** This List can cause max heap size ******
            // This is add top CSV with 1 rows;
     		logsData.add(csvRow);
     		//recordsProcessed++;
     	}
     	
    }   
    
    global void finish(Database.BatchableContext BC){
    	
    	RTL_Upload_Campaign_Member_Import_Log__c ucmail = new RTL_Upload_Campaign_Member_Import_Log__c();
   	
    	// Record Status
        String ucmbId = ucmb.id;
    	Integer totalMember = database.countQuery('select count() FROM RTL_Upload_Campaign_Members__c WHERE RTL_Upload_Campaign_Member_Batch__c = :ucmbId AND RTL_Upload_Campaign_Member_Logs__c = :ucmLID');
    	
    	List<AggregateResult> importResult = [SELECT RTL_ImportStatus__c, COUNT(Name) countTotal
				FROM RTL_Upload_Campaign_Members__c
				WHERE RTL_Upload_Campaign_Member_Logs__c = :ucmLID
                AND RTL_Upload_Campaign_Member_Batch__c = :ucmb.id 
				GROUP BY RTL_ImportStatus__c];
		
		Integer totalSuccess = 0;
		Integer totalFail = 0;
		Integer totalIgnore = 0;
				
		for( AggregateResult totalResult : importResult)
		{
			if( totalResult.get('RTL_ImportStatus__c') == 'Success' )
			{
				totalSuccess = (Integer)totalResult.get('countTotal');
			}
			else if ( totalResult.get('RTL_ImportStatus__c') == 'Failed' )
			{
				totalFail = (Integer)totalResult.get('countTotal');
			}	
			else if ( totalResult.get('RTL_ImportStatus__c') == 'Duplicate' )
			{
				totalIgnore = (Integer)totalResult.get('countTotal');
			}
		}
    	
    	ucmail.RTL_Upload_Campaign_Member_Logs__c = ucmLID;
    	ucmail.RTL_Total_Record__c = totalMember;
    	ucmail.RTL_Total_Success__c = totalSuccess;
    	ucmail.RTL_Total_Fail__c = totalFail;
    	ucmail.RTL_Total_Ignore__c = totalIgnore;

        ucmail.RTL_Batch_No__c = ucmb.RTL_Batch_No__c;
        ucmail.RTL_Start_at_Row_No__c = ucmb.RTL_Start_at_Row_No__c;
        ucmail.RTL_End_at_Row_No__c = ucmb.RTL_End_at_Row_No__c;
    	
    	insert ucmail;
    	
    	// get original upload file name
    	Attachment bodyfile =[SELECT ID,Name,ParentID from Attachment WHERE ParentID =:ucmLID LIMIT 1];
    	String originalFileName = bodyfile.Name;
    	
    	String rawFileName = '';
    	
    	if (originalFileName.indexOf('.') > 0)
		{
		    rawFileName = originalFileName.substring(0, originalFileName.lastIndexOf('.'));
		}
		else
		{
			rawFileName = originalFileName;
		}
		
		String logFileName = rawFileName + '['+ integer.valueof(ucmb.RTL_Batch_No__c)+'-result log].csv';
		    	    	
    	 // Add header
        String csvStringBody = '';

        // Add content
        for(integer j=0;j<logsData.size();j++){             	         
            csvStringBody += logsData.get(j)+'\r\n';
        }
        
        Blob csvFileBodypart = Blob.valueof(csvStringBody);
        Attachment attachmentpart = new Attachment();
        attachmentpart.parentId = ucmail.id;
        attachmentpart.name = logFileName;
        attachmentpart.IsPrivate = true;
        attachmentpart.body = csvFileBodypart;
        
        insert attachmentpart;


        // Recursively call to create next Upload Batch
        // Call Import campaign member from CSV to temp

        RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
        System.enqueueJob(importQueue); 
        
    }
    
    
    private string processDataString(String Data)
    {
    	return (Data==null)?'': Data.escapeCsv()  ;
    }
    
    private String convertToCSVformat(List<String> listVariable)
    {
		String collegeString = String.join(listVariable, ',');
   		
   		return collegeString;
    }
}