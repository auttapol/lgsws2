public class RTL_UploadCampaignMemberSplitQueueable implements Queueable{
    
    private RTL_Upload_Campaign_Member_Logs__c ucmL ;
    private Integer NoPerFile{
        get{
            if(NoPerFile==null){
                 RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Line_Per_Split_File__c
                   from RTL_Upload_Campaign_Member__mdt 
                   where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

                   NoPerFile = integer.valueOf(ucmMeta.RTL_Line_Per_Split_File__c);
            }
            return NoPerFile;
        }
        set;
    }
    
    private Integer postUpdateScheduleMin {
    get{
            if(postUpdateScheduleMin==null){
                 RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Temp_Data_Life_Time_Minute__c
                   from RTL_Upload_Campaign_Member__mdt 
                   where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];
                   postUpdateScheduleMin = integer.valueOf(ucmMeta.RTL_Temp_Data_Life_Time_Minute__c);
                //RTL_Upload_Campaign_Member_Setting__c cmuSetting = RTL_Upload_Campaign_Member_Setting__c.getInstance();
                //postUpdateScheduleMin = integer.valueOf(cmuSetting.RTL_Temp_Data_Life_Time_Minute__c);
            }
            return postUpdateScheduleMin;
        }
        set;
    }
    
    public RTL_UploadCampaignMemberSplitQueueable(String logID)
    {

       ucmL = [SELECT ID,RTL_Campaign__c,RTL_Campaign__r.Name,
            RTL_CampaignID__c,RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,RTL_Campaign__r.RTL_Campaign_Code_9_digits__c
            FROM RTL_Upload_Campaign_Member_Logs__c WHERE ID =:logID Limit 1 ];
             
    }
    
    public void execute(QueueableContext context) {
    	
    	// If can't find   Upload_Campaign_Member_Logs__c from   logID , return false. (Maybe do something)	
    	if( ucmL == null )
    	{
    		return;
    	}
    	
    	ucmL.RTL_UploadStatus__c = 'In Progress - Split File';
    	update ucmL;
    		
		// Get Upload Campaing memeber 's full version attachement
   		Attachment csvfile = [SELECT ID,Body,ParentID from Attachment WHERE ParentID=:ucmL.id LIMIT 1];

   		// Process string to List for each line
   		// String csvdetail = csvfile.Body.tostring();        

        String csvEOL = RTL_UploadCampaignMemberService.getEOL(csvfile.Body.tostring());

   		String[] csvrowdetails = RTL_UploadCampaignMemberService.safeSplit(csvfile.Body.tostring(), csvEOL);

        // Get total rows
		//Integer fileRowNum = csvrowdetails.size();
        Integer fileRowNum = csvfile.Body.tostring().countMatches(csvEOL) - 1;   

        //reset variable to recovery heapsize
        csvfile = null; 
		
   		List<Attachment> csvList = new List<Attachment>();
   		        
		// No need to check row number , do split event file size < NoPerFile (Line per file)
        //if(fileRowNum >=NoPerFile){
                       
        // Get header line string, this should add in the first line of each file
        String headerstring = csvrowdetails.get(0) + '\r\n';               
                       
        // Calculate number of files to be generated
        
        //Decimal roundup = decimal.valueof(fileRowNum/NoPerFile);
        //Long TotalNumberFileToSplit = roundup.round(System.RoundingMode.CEILING); 
		
        //Header not count
		Integer TotalNumberFileToSplit = (Integer)Math.ceil( (fileRowNum ) / double.valueof(NoPerFile) ); 

        // System.debug( Logginglevel.ERROR ,TotalNumberFileToSplit );	

        Integer startRow = 1;  
        Integer endRow = startRow+NoPerFile;

		//List<RTL_Upload_Campaign_Member_Batch__c> ucmbList = new List<RTL_Upload_Campaign_Member_Batch__c>();                       		

        // System.debug( Logginglevel.ERROR ,'heap size4 : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() );		

		// Loop to create split file , each file have number of lie = NoPerFile
        List<RTL_Upload_Campaign_Member_Batch__c> ucmbl = new List<RTL_Upload_Campaign_Member_Batch__c>();
        for(integer i=1;i<=TotalNumberFileToSplit;i++){
        	
			// For last split file , use correct number of column as end row
        	if( fileRowNum < endRow )
        	{
                // number of rows + header
        		endRow = fileRowNum + 1;
        	}
        		
			//Create Upload_Campaign_Member_Batch__c
            RTL_Upload_Campaign_Member_Batch__c ucmb = new RTL_Upload_Campaign_Member_Batch__c();
            ucmb.RTL_Batch_No__c = i;
            ucmb.RTL_Status__c = 'In Queue';
            ucmb.RTL_Upload_Campaign_Member_Logs__c =ucml.id;
            ucmb.RTL_Start_at_Row_No__c = startRow;
            ucmb.RTL_End_at_Row_No__c = (endRow-1);
			
			//ucmbList.add(ucmb);
			// it need id , so add ucmb here (Maybe change later)
            ucmbl.add(ucmb);
            //insert ucmb;



            //step up - prepare start , end rows count to proces  next split file
            startRow += NoPerFile;
            
            if(endRow+NoPerFile<csvrowdetails.size()){
                endRow += NoPerFile;
            }else{
                endRow = csvrowdetails.size();
            }


            // System.debug( Logginglevel.ERROR ,'heap size6 loop: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() );		
        }

        insert ucmbl;

        for( RTL_Upload_Campaign_Member_Batch__c ucmb :ucmbl )
        {
            Integer startRowSplit = Integer.valueOf(ucmb.RTL_Start_at_Row_No__c);
            Integer endRowSplit = Integer.valueOf(ucmb.RTL_End_at_Row_No__c + 1);
            // Prepare string var to create split file
            String csvStringBody ='';
            
            // Add header
            csvStringBody += headerstring;
            // Add content
            for(integer j=startRowSplit;j<endRowSplit;j++){              
                csvStringBody += csvrowdetails.get(j)+'\r\n';
            }

        	// Create CSV file as attachement for splited file
            Blob csvFileBodypart = Blob.valueof(csvStringBody);
            Attachment attachmentpart = new Attachment();
            attachmentpart.parentId = ucmb.id;
            attachmentpart.name = 'Import Csv file : '+ucmL.RTL_Campaign__r.Name+' part '+startRowSplit+'-'+endRowSplit+'.csv';
            attachmentpart.IsPrivate = true;
            attachmentpart.body = csvFileBodypart;
            csvList.add(attachmentpart);
        }
		// Insert split file when all sile splitted
        insert csvList;

		
		// Use Batch to run one by one batch CSV - each query is a batch CSV to import to log member
		//RTL_UploadCampaignMemberImportBatch ucmbatch = new RTL_UploadCampaignMemberImportBatch(ucml);  
        //Database.executeBatch(ucmbatch ,BatchPerUploadMember);

        //RTL_UploadCampaignMemberImportBatch ucmbatch = new RTL_UploadCampaignMemberImportBatch(ucml);
        //ucmbatch.process();

        RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(ucml);
        System.enqueueJob(importQueue); 

        // Schedule to delete temp record , this will be froce execute regardless of import process
        DateTime dt = System.now();
        DateTime nextCleanup = dt.addMinutes(postUpdateScheduleMin);

        String hour = String.valueOf( nextCleanup.hour() );
        String min = String.valueOf( nextCleanup.minute()); 
        String ss = String.valueOf( nextCleanup.second());
        
        String day = String.valueOf( nextCleanup.day() ); 
        String month = String.valueOf( nextCleanup.month() );
        String year = String.valueOf( nextCleanup.format('yyyy') );
        
        //parse to cron expression - running job in next 1 hour once
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;

        RTL_UploadCampaignMemberPostSchedule deleteUploadMemberData = new RTL_UploadCampaignMemberPostSchedule(ucmL.id); 
        System.schedule('Delete Upload Camapign Member Started At ' + String.valueOf( Datetime.now()), nextFireTime, deleteUploadMemberData );
        
		

    }
    
	
    
}