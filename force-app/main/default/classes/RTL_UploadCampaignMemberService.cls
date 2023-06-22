public class RTL_UploadCampaignMemberService{
    
 	public transient Blob csvFileBody                     {get;set;}
    public transient string csvAsString                   {get;set;}
    public transient String[] csvFileLines                {get;set;}
    //public transient integer rows                         {get;set;}
    public transient String UploadCampaignMemberLogID {get;set;}
    //public transient String messagefiletype             {get; set;}

    public static Integer csvColumnNo = 48;
    // Max file size 5 MB  
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
                fileSizeError = String.format( Label.RTL_Campaign_Member_Upload_File_Size , new String[]{ String.valueOf( maxFileSize ) }  ) ;
            }
            return fileSizeError;
        }
        set;
    }

    public static RecordType retailRCT {
    	get{
	    	if(retailRCT==null){
	    		retailRCT = [SELECT ID FROM RecordType WHERE DeveloperName = 'Retail_Banking' AND sObjectType = 'Lead' ];
	    	}
    		return retailRCT;
    	}
    	set;
    }

	//private Integer NoPerFile{
 //       get{
 //           if(NoPerFile==null){
 //                RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Line_Per_Split_File__c
 //                  from RTL_Upload_Campaign_Member__mdt 
 //                  where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

 //                  NoPerFile = integer.valueOf(ucmMeta.RTL_Line_Per_Split_File__c);
 //           }
 //           return NoPerFile;
 //       }
 //       set;
 //   }

    private Integer maximumImportRows{
    	get{
            if(maximumImportRows==null){
                 RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Max_Upload_Line__c
                   from RTL_Upload_Campaign_Member__mdt 
                   where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

                   maximumImportRows = integer.valueOf(ucmMeta.RTL_Max_Upload_Line__c);
            }
            return maximumImportRows;
        }
        set;
    }



    public String selectedCampaignID {get;set;}

    public CampaignMember cpmb {get;set;}
    
	private List<String> localExCampaignRecordTypeDevName {
        get{
            if( localExCampaignRecordTypeDevName == null )
            {
                localExCampaignRecordTypeDevName = new List<String>();

                localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign_Active');
                //localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign_Expired');
                localExCampaignRecordTypeDevName.add('Local_Exclusive_Campaign');   
                localExCampaignRecordTypeDevName.addAll(new List<String>{
                    'Exclusive_Campaign_Active',
                    'Exclusive_Campaign'
                });

            }
            return localExCampaignRecordTypeDevName;
        }
        set;
    }

    public List<SelectOption> CampaignSelectOptionList {get{
        if(CampaignSelectOptionList == null){

            // Set<ID> retailRecordTypeIDset = new Set<ID>();
            // for(Recordtype perRecordType :  [SELECT ID from Recordtype 
            //                          WHERE sObjectType ='Campaign'
            //                          AND (NOT DeveloperName LIKE '%Master%')
            //                          AND (NOT DeveloperName LIKE '%Commercial%')]){
            //                             retailRecordTypeIDset.add(perRecordType.id); 
            //                          }


            CampaignSelectOptionList = new List<SelectOption>();
			CampaignSelectOptionList.add(new SelectOption('','--None--'));
            for(Campaign cp : [SELECT ID,RecordTypeId,Status,isActive,Name FROM Campaign 
							   WHERE RecordType.DeveloperName IN:localExCampaignRecordTypeDevName
                               AND Status != 'Expired'
                               AND Approvedflag__c  = true
                               ORDER BY NAME ASC]){
               // if(retailRecordTypeIDset.contains(cp.RecordTypeID)){
                    CampaignSelectOptionList.add(new SelectOption(cp.id,cp.Name));
               // }
                
            }
            

        }
        return CampaignSelectOptionList;
        }set;}
    
    

    public RTL_UploadCampaignMemberService(){

		//RTL_Upload_Campaign_Member_Setting__c cmuSetting = RTL_Upload_Campaign_Member_Setting__c.getInstance();
  //      NoPerFile = integer.valueOf(cmuSetting.RTL_Line_Per_Split_File__c);
  //      maximumImportRows = integer.valueOf(cmuSetting.RTL_Max_Upload_Line__c);

        cpmb = new CampaignMember();
        csvFileLines = new String[]{};
       
        if( getIsAllowedUpload() == false )
        {
           ApexPages.Message uploadMessage = new ApexPages.Message(ApexPages.severity.INFO , Label.RTL_Campaign_Member_Upload_Notice );
           ApexPages.addmessage(uploadMessage);
        }

    }


    public PageReference importCSVFile(){
        //Boolean isUTF8 = true;
        //string csvdetail;
		
		// Do need funtionallity to check unicode? currently is always true
        //if(isUTF8){

          String csvFileString = '';
          try 
          {
             csvFileString = csvFileBody.tostring();
          } 
          catch(Exception e) 
          {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() );
            ApexPages.addmessage(errorMessage);
            return null;
          }
          

          String csvEOL = getEOL(csvFileString);

          if( csvEOL == null )
          {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,Label.RTL_Campaign_Member_Upload_Invalid_File);
            ApexPages.addmessage(errorMessage);
            return null;
          }

            // no. of line not count header
            Integer noLine = csvFileString.countMatches(csvEOL) - 1;          


        	if( noLine > maximumImportRows )
        	{	
        		List<String> fillers = new String[]{ String.valueOf(maximumImportRows), String.valueOf(noLine)};
        		String messageInvalidRow = String.format( Label.RTL_Campaign_Member_Upload_Invalid_Row , fillers );
        		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,messageInvalidRow);
                ApexPages.addmessage(errorMessage);
        		return null;
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
            // System.debug(headerStr + ' ' + contentStr1);
        	//Verify number of column
            // String[] csvrowdetails = safeSplit(csvFileString, csvEOL );   

        	List<String> header = headerStr.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);
        	List<String> content = contentStr1.trim().split((',(?=([^\"]*\"[^\"]*\")*[^\"]*$)'),-1);

            System.debug('HEAD ' + header.size() + ' \ncont ' + content.size() + RTL_UploadCampaignMemberService.csvColumnNo);

        	if( header.size() != RTL_UploadCampaignMemberService.csvColumnNo 
        		|| content.size() != RTL_UploadCampaignMemberService.csvColumnNo )
        	{
        		List<String> fillers = new String[]{ String.valueOf(RTL_UploadCampaignMemberService.csvColumnNo) };
        		String messageInvalidColumn = String.format( Label.RTL_Campaign_Member_Upload_Invalid_Column , fillers );
        		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, messageInvalidColumn );
                ApexPages.addmessage(errorMessage);
        		return null;
        	}
            importCampaignMemberToCampaign();
			
        //}      

        return ApexPages.currentPage().setRedirect(true);

        
    }

	private void importCampaignMemberToCampaign()
	{
				// new Upload_Campaign_Member_Logs__c
            	RTL_Upload_Campaign_Member_Logs__c ucmL = new RTL_Upload_Campaign_Member_Logs__c();
  
  				// Assign campaing Id to Upload_Campaign_Member_Logs__c 
  				// Also allowed none campaing Upload , this will check and upload member to lead 
  				
  				String batchName = '';
  				
  				if( selectedCampaignID != null && selectedCampaignID !='')
  				{
                	ucmL.RTL_CampaignID__c = selectedCampaignID;

					// Assign campaign object to  Upload_Campaign_Member_Logs__c
	                Campaign Campaignobj = [SELECT ID,Name from Campaign WHERE ID =:selectedCampaignID LIMIT 1];
	                ucmL.RTL_Campaign__c = Campaignobj.id;
	                
	                batchName = Campaignobj.Name;
  				}
  				else
  				{
  					batchName = 'lead import';
  				}
                
                ucmL.RTL_IsInProgress__c = true;
                ucmL.RTL_UploadStatus__c = 'Starting';
                // Insert new Upload_Campaign_Member_Logs__c
                insert ucmL;
                
				// Create new attachement from uploaded CSV 

				
                Attachment importattachmentfile = new Attachment();
                importattachmentfile.parentId = ucml.id;
                //importattachmentfile.name = 'Import Csv file : '+batchName+'.csv';
                importattachmentfile.name = csvAsString;
                
                
                importattachmentfile.IsPrivate = true;
                importattachmentfile.body = csvFileBody;
                insert importattachmentfile;

				// Assign attacthment (CSV) to Upload_Campaign_Member_Logs__c
                ucml.RTL_Import_CSV_file_ID__c = importattachmentfile.id;
				
				// Update Upload_Campaign_Member_Logs__c (Add attachment)
                update ucml;

                // Get ID of  Upload_Campaign_Member_Logs__c 
                UploadCampaignMemberLogID = ucml.id;

				// Change Batch ot queueable process
                //UploadCampaignMemberSplitFileBatch ucmbatch = new UploadCampaignMemberSplitFileBatch(UploadCampaignMemberLogID);  
                //Database.executeBatch(ucmbatch ,2000);
                
                // Queueable process to async split file
                RTL_UploadCampaignMemberSplitQueueable splitFileQueue = new RTL_UploadCampaignMemberSplitQueueable(UploadCampaignMemberLogID);
                
                if(!Test.isRunningTest()) System.enqueueJob(splitFileQueue);
	}
	
	public Boolean getIsAllowedUpload() 
	{
		// Check if any upload job still running by current user and last modify with in today 
		RTL_Upload_Campaign_Member_Logs__c[] activeJobs = [
											SELECT ID,Owner.id,LastModifiedDate,
												RTL_IsInProgress__c
											FROM RTL_Upload_Campaign_Member_Logs__c
											WHERE RTL_IsInProgress__c = true
											AND Owner.Id = :UserInfo.getUserID()
											AND CreatedDate > YESTERDAY
							];
        // System.debug('TT' + activeJobs + UserInfo.getUserID());
		if(  activeJobs.size() > 0 )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	} 
	
	public List<RTL_Upload_Campaign_Member_Import_Log__c> getUploadLogs()
	{
		
		return [SELECT ID , CreatedDate , Name,
					RTL_Total_Record__c,RTL_Total_Success__c,RTL_Total_Fail__c,RTL_Total_Ignore__c, RTL_Batch_No__c , RTL_Upload_Campaign_Member_Logs__r.Name,
				(SELECT Id, Name FROM Attachments LIMIT 1) 
				FROM RTL_Upload_Campaign_Member_Import_Log__c 
				WHERE RTL_Upload_Campaign_Member_Logs__r.Owner.Id = :UserInfo.getUserID()
				ORDER BY RTL_Upload_Campaign_Member_Logs__r.Name DESC,RTL_Batch_No__c 
				];
	}
	
	public static String processCSVdata(String csvData)
	{
		return csvData.removeStart('\"').removeEnd('\"');
	}


	/**
	* Split a string of any size, while avoiding the dreaded 'Regex too complicated'
	* error, which the String.split(String) method causes on some large inputs.
	*
	* Note that this method does not avoid other errors, such as those related to 
	* excess heap size or CPU time.
	*/
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

	public static String guid()
	{
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
	}

  public String getPageMessage() 
  {
      String message = '';
      List<Apexpages.Message> msgs = ApexPages.getMessages();
      for(Apexpages.Message msg:msgs){
          message += msg.getDetail() +'\n';
      }

      return message; 
  } 
  
  public static string getEOL(String uploadCSV)
    {
      //List of EOL , \r\n must be first in order to check before \r 
      List<String> eolExpList = new List<String>{'\r\n','\r'};

      for( String eolExp : eolExpList )
      {
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

    
}