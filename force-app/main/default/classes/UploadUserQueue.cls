public class UploadUserQueue implements Queueable{
    
    private Upload_PWA_RM_Log__c uprl ;
    // private Integer NoPerFile{
    //     get{
    //         if(NoPerFile==null){
    //              RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Line_Per_Split_File__c
    //                from RTL_Upload_Campaign_Member__mdt 
    //                where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

    //                NoPerFile = integer.valueOf(ucmMeta.RTL_Line_Per_Split_File__c);
    //         }
    //         return NoPerFile;
    //     }
    //     set;
    // }
    
    // private Integer postUpdateScheduleMin {
    // get{
    //         if(postUpdateScheduleMin==null){
    //              RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Temp_Data_Life_Time_Minute__c
    //                from RTL_Upload_Campaign_Member__mdt 
    //                where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];
    //                postUpdateScheduleMin = integer.valueOf(ucmMeta.RTL_Temp_Data_Life_Time_Minute__c);
    //             //RTL_Upload_Campaign_Member_Setting__c cmuSetting = RTL_Upload_Campaign_Member_Setting__c.getInstance();
    //             //postUpdateScheduleMin = integer.valueOf(cmuSetting.RTL_Temp_Data_Life_Time_Minute__c);
    //         }
    //         return postUpdateScheduleMin;
    //     }
    //     set;
    // }
    
    public UploadUserQueue(String logID)
    {

       uprl = [SELECT Id, File_Name__c, Total_Record__c, Total_Success__c, Total_Fail__c, Import_CSV_file_ID__c
        FROM Upload_PWA_RM_Log__c WHERE ID =:logID Limit 1 ];
            System.debug('uprl :' + uprl); 
    }
    
    public void execute(QueueableContext context) {
    	
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
            System.debug('csvEOL :' +csvEOL);
            csvdetail2.addAll( PWARMController.safeSplit(csvdetail, csvEOL) );
            System.debug('csvdetail2-1 :' +csvdetail2);
            Integer fileRowNum = csvfile.Body.tostring().countMatches(csvEOL) - 1; 
            System.debug('csvfile.Body.tostring() :' +csvfile.Body.tostring());
            System.debug('fileRowNum:' +fileRowNum);
            System.debug('csvdetail2 :' + csvdetail2.size());
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
            System.debug('contentStr1 :' +contentStr1);
        	List<String> header = headerStr.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
        	List<String> content = contentStr1.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);

            System.debug('HEAD ' + header.size() + ' \ncont ' + content.size() + PWARMController.csvColumnNo);
            for(Integer i  = 0 ;i<header.size();i++){
                System.debug('index:' + i + '//Header :'  +header[i]  );
            }
            list<Mapping_Field_Batch_User__mdt> mpList = [SELECT Id, FieldSalesforce__c, FieldHeaderCSV__c FROM Mapping_Field_Batch_User__mdt];
            map<string , string> mapFieldCSVmeta = new     map<string , string>();
            for(Mapping_Field_Batch_User__mdt each : mpList){
                mapFieldCSVmeta.put(each.FieldHeaderCSV__c, each.FieldSalesforce__c);
            }
        for(Integer i = 1 ; i < csvdetail2.size() ; i++){
            System.debug('csvdetail2:' + csvdetail2 +'//ii:'+i);
            List<String> csvRecordDataTemp = csvdetail2[i].trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
            System.debug('csvRecordDataTemp:' +csvRecordDataTemp);
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
                System.debug('CSVDATA : ' + csvRecordData + csvRecordData.size() + PWARMController.csvColumnNo);
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
                    user us = new user();
                    // us.Employee_ID__c =csvRecordData[0];
                    // us.First_Name_TH__c =csvRecordData[1];
                    // us.Last_Name_TH__c =csvRecordData[2];
                    // us.Mobile_No__c =csvRecordData[3];
                    // listUserUpdate.add(us);
                    Integer indexHeader = 0;
                    for(String dataColum : csvRecordData){
                        System.debug('dataColum :'  +dataColum);
                        System.debug('header :' + header[indexHeader]);
                        if(mapFieldCSVmeta.containsKey(header[indexHeader])){
                            System.debug('FieldSalesforce:'+mapFieldCSVmeta.get(header[indexHeader]));
                            String FieldSalesforce =  mapFieldCSVmeta.get(header[indexHeader]);
                            us.put(FieldSalesforce ,dataColum) ; //= dataColum
                        }
                        indexHeader++;
                    }
                    listUserUpdate.add(us);
                }
               
             
            


        }
        System.debug('listUserUpdate:' +listUserUpdate.size());
        if(listUserUpdate.size()>0){
            // Database.UpsertResult[] result  upsert( listUserUpdate,Employee_ID__c,  false);
                    // Database.UpsertResult [] cr = Database.upsert(toBeUpsertCases, false);
                    Database.UpsertResult [] cr = Database.upsert(listUserUpdate,User.Employee_ID__c.Employee_ID__c, false);
            // Map<Id, User> caseMap = new Map<Id, User>(listUserUpdate);
            // I want to see what was updated / created  
            integer successRecord = 0 ; 
            integer FailRecord = 0 ;
            for(Database.upsertResult result : cr){
                System.debug(result);
                if(result.isSuccess()){
                    successRecord++;
                    if(result.isCreated()){
                        // System.debug(caseMap.get(result.getId()).Employee_ID__c + ' was created');
                        System.debug('isCreate! :' + result.getId() );
                    } else {
                        // System.debug(caseMap.get(result.getId()).Employee_ID__c + ' was updated');
                        System.debug('isUpdate! :' + result.getId() );

                    }
                }
                else{
                    FailRecord++;
                    System.debug('Record fail');
                }
            }
            System.debug('successRecord :' +successRecord);
            System.debug('FailRecord :' +FailRecord);
            // uprl = [SELECT Id, File_Name__c, Total_Record__c, Total_Success__c, Total_Fail__c, Import_CSV_file_ID__c

            uprl.Total_Success__c = successRecord;
            uprl.Total_Fail__c = FailRecord;
            uprl.Total_Record__c = successRecord+FailRecord;
            uprl.upload_status__c = 'Finish';

            update uprl;
        }

        // Database.UpsertResult [] cr = Database.upsert(toBeUpsertCases, false);
        // Map<Id, Case> caseMap = new Map<Id, Case>(toBeUpsertCases);
        // // I want to see what was updated / created        
        // for(Database.upsertResult result : cr){
        //     System.debug(result);
        //     if(result.isSuccess()){
        //         if(result.isCreated()){
        //             System.debug(caseMap.get(result.getId()).Ticket_Number__c + ' was created');
        //         } else {
        //             System.debug(caseMap.get(result.getId()).Ticket_Number__c + ' was updated');
        //         }
        //     }
        // }

        // // Calculate number of files to be generated
        
        // //Decimal roundup = decimal.valueof(fileRowNum/NoPerFile);
        // //Long TotalNumberFileToSplit = roundup.round(System.RoundingMode.CEILING); 
		
        // //Header not count
		// Integer TotalNumberFileToSplit = (Integer)Math.ceil( (fileRowNum ) / double.valueof(NoPerFile) ); 

        // // System.debug( Logginglevel.ERROR ,TotalNumberFileToSplit );	

        // Integer startRow = 1;  
        // Integer endRow = startRow+NoPerFile;

		// //List<RTL_Upload_Campaign_Member_Batch__c> ucmbList = new List<RTL_Upload_Campaign_Member_Batch__c>();                       		

        // // System.debug( Logginglevel.ERROR ,'heap size4 : ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() );		

		// // Loop to create split file , each file have number of lie = NoPerFile
        // List<RTL_Upload_Campaign_Member_Batch__c> ucmbl = new List<RTL_Upload_Campaign_Member_Batch__c>();
        // for(integer i=1;i<=TotalNumberFileToSplit;i++){
        	
		// 	// For last split file , use correct number of column as end row
        // 	if( fileRowNum < endRow )
        // 	{
        //         // number of rows + header
        // 		endRow = fileRowNum + 1;
        // 	}
        		
		// 	//Create Upload_Campaign_Member_Batch__c
        //     RTL_Upload_Campaign_Member_Batch__c ucmb = new RTL_Upload_Campaign_Member_Batch__c();
        //     ucmb.RTL_Batch_No__c = i;
        //     ucmb.RTL_Status__c = 'In Queue';
        //     ucmb.RTL_Upload_Campaign_Member_Logs__c =uprl.id;
        //     ucmb.RTL_Start_at_Row_No__c = startRow;
        //     ucmb.RTL_End_at_Row_No__c = (endRow-1);
			
		// 	//ucmbList.add(ucmb);
		// 	// it need id , so add ucmb here (Maybe change later)
        //     ucmbl.add(ucmb);
        //     //insert ucmb;



        //     //step up - prepare start , end rows count to proces  next split file
        //     startRow += NoPerFile;
            
        //     if(endRow+NoPerFile<csvrowdetails.size()){
        //         endRow += NoPerFile;
        //     }else{
        //         endRow = csvrowdetails.size();
        //     }


        //     // System.debug( Logginglevel.ERROR ,'heap size6 loop: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() );		
        // }

        // insert ucmbl;

        // for( RTL_Upload_Campaign_Member_Batch__c ucmb :ucmbl )
        // {
        //     Integer startRowSplit = Integer.valueOf(ucmb.RTL_Start_at_Row_No__c);
        //     Integer endRowSplit = Integer.valueOf(ucmb.RTL_End_at_Row_No__c + 1);
        //     // Prepare string var to create split file
        //     String csvStringBody ='';
            
        //     // Add header
        //     csvStringBody += headerstring;
        //     // Add content
        //     for(integer j=startRowSplit;j<endRowSplit;j++){              
        //         csvStringBody += csvrowdetails.get(j)+'\r\n';
        //     }

        // 	// Create CSV file as attachement for splited file
        //     Blob csvFileBodypart = Blob.valueof(csvStringBody);
        //     Attachment attachmentpart = new Attachment();
        //     attachmentpart.parentId = ucmb.id;
        //     attachmentpart.name = 'Import Csv file : '+uprl.RTL_Campaign__r.Name+' part '+startRowSplit+'-'+endRowSplit+'.csv';
        //     attachmentpart.IsPrivate = true;
        //     attachmentpart.body = csvFileBodypart;
        //     csvList.add(attachmentpart);
        // }
		// // Insert split file when all sile splitted
        // insert csvList;

		
		// // Use Batch to run one by one batch CSV - each query is a batch CSV to import to log member
		// //RTL_UploadCampaignMemberImportBatch ucmbatch = new RTL_UploadCampaignMemberImportBatch(uprl);  
        // //Database.executeBatch(ucmbatch ,BatchPerUploadMember);

        // //RTL_UploadCampaignMemberImportBatch ucmbatch = new RTL_UploadCampaignMemberImportBatch(uprl);
        // //ucmbatch.process();

        // RTL_UploadCampaignMemberImportBatch importQueue = new RTL_UploadCampaignMemberImportBatch(uprl);
        // System.enqueueJob(importQueue); 

        // // Schedule to delete temp record , this will be froce execute regardless of import process
        // DateTime dt = System.now();
        // DateTime nextCleanup = dt.addMinutes(postUpdateScheduleMin);

        // String hour = String.valueOf( nextCleanup.hour() );
        // String min = String.valueOf( nextCleanup.minute()); 
        // String ss = String.valueOf( nextCleanup.second());
        
        // String day = String.valueOf( nextCleanup.day() ); 
        // String month = String.valueOf( nextCleanup.month() );
        // String year = String.valueOf( nextCleanup.format('yyyy') );
        
        // //parse to cron expression - running job in next 1 hour once
        // String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;

        // RTL_UploadCampaignMemberPostSchedule deleteUploadMemberData = new RTL_UploadCampaignMemberPostSchedule(uprl.id); 
        // System.schedule('Delete Upload Camapign Member Started At ' + String.valueOf( Datetime.now()), nextFireTime, deleteUploadMemberData );
        
		

    }
    
	
    
}