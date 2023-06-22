global class fnaAvatarResultMappingSendEmail {
	@TestVisible
	private static Integer LIMIT_TO_ADDR = 20;
	private static String BODY_TEXT_SUCCESS;
	private static String BODY_TEXT_FAILED;
	private static String BODY_TEXT_FAILED_BY_SERVER;

	//start 1st ---->
	global static void SendFinishDailyBatchSummaryEmail(Datetime batchDate		//1
												    ,Datetime batchStartTime	//2
												    ,Datetime batchEndTime		//3
													,Integer recordsSuccessful	//4
													,Integer recordsFailed		//5
													,String jobDailyName		//6
													,String sobjectName			//7
													,List<String> emailOpsList	//8
													,String mainError			//9
													,String secondaryError		//10
													,String successLog			//11
													,String mainErrorHeader		//12
													,String secondaryErrorHeader	//13
													,String successLogHeader	//14
													,String queryForDailyJob	//15
													,String bodyTextSuccess
													,String bodyTextFailed
													,String bodyTextFailedByServer
													) {
		List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();

		BODY_TEXT_SUCCESS = bodyTextSuccess;
		BODY_TEXT_FAILED = bodyTextFailed;
		BODY_TEXT_FAILED_BY_SERVER = bodyTextFailedByServer;

		system.debug('mainError : ' + mainError);
		if (!String.isBlank(mainError)) {
			String Header_CSV = mainErrorHeader;
	    	String CSV_SUMMARY = Header_CSV + mainError;
	    	Blob csvBlob = Blob.valueOf(CSV_SUMMARY);
	    	
	    	Messaging.EmailFileAttachment csvAttc 
	    					= new Messaging.EmailFileAttachment();

			csvAttc.setFileName('Error_Summary_'+jobDailyName+'.csv');
			csvAttc.setBody(csvBlob);
			csvAttc.setContentType('text/csv; charset=UTF-8');
			efaList.add(csvAttc);
		}

		if (!String.isBlank(secondaryError)) {
			String Header_CSV = secondaryErrorHeader; 
	    	String UPDATE_BODY_SUMMARY = Header_CSV + secondaryError;
	    	Blob csvBlob = Blob.valueOf(UPDATE_BODY_SUMMARY);
	    	
	    	Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

			csvAttc.setFileName('Error_Secondary_Summary_'+jobDailyName+'.csv');
			csvAttc.setBody(csvBlob);
			csvAttc.setContentType('text/csv; charset=UTF-8');
			efaList.add(csvAttc);
		}

		if (!String.isBlank(successLog)) {
			String Header_CSV = successLogHeader;
	    	String LOG_SUCCESS = Header_CSV + successLog;
	    	Blob csvBlob = Blob.valueOf(LOG_SUCCESS);
	    	
	    	Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

			csvAttc.setFileName('LOG_SUCCESS_'+jobDailyName+'.csv');
			csvAttc.setBody(csvBlob);
			csvAttc.setContentType('text/csv; charset=UTF-8');
			efaList.add(csvAttc);
		}
		
		SendFinishBatchSummaryEmail(batchDate
                                    , batchStartTime
                                    , batchEndTime
                                    , recordsSuccessful
                                    , recordsFailed
                                    , jobDailyName
                                    , sobjectName
                                    , emailOpsList
                                    , efaList
                                    , queryForDailyJob	//10
                                    );
	}

	// Start 2nd ---->
	global static void SendFinishBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,List<Messaging.Emailfileattachment> efaList
													,String queryForDailyJob	//10
													) {
		TimeZone tz = UserInfo.getTimeZone();
        Integer recordsProcessed = recordsSuccessful + recordsFailed;
        
        String subject = null;
        String description = null;
        String status = null;
		String confirmText = null;

        //Refacorting Delete Batch 27-12-2017
        List<String> fillers = new String[]{jobDailyName};
        String purgeJobDesc = String.format(System.Label.For_Daily_Batch_Desc
                                            , fillers);
        String subjectJob   = String.format(System.Label.For_Daily_Batch_Header
                                            , fillers);
        //Refacorting Delete Batch 27-12-2017

		system.debug('BODY_TEXT_FAILED_BY_SERVER : ' + BODY_TEXT_FAILED_BY_SERVER);	
		if(BODY_TEXT_FAILED_BY_SERVER != ''){
			subject = subjectJob + ' failed';
            description = purgeJobDesc + ' failed';
            status = 'Failed';
			system.debug('subjectJob--> : ' + subjectJob);	
			system.debug('purgeJobDesc--> : ' + purgeJobDesc);			
			confirmText = BODY_TEXT_FAILED_BY_SERVER;
		}
		else{
			system.debug('BODY_TEXT_FAILED_BY_SERVER : Else');	
			if (recordsFailed > 0) {//there are failed records
				subject = subjectJob + ' completely';
				description = purgeJobDesc + ' completely';
				status = 'Failed';
				system.debug('subjectJob--> : ' + subjectJob);	
				system.debug('purgeJobDesc--> : ' + purgeJobDesc);			
				confirmText = BODY_TEXT_FAILED;
			} 
			else {//there are no failed records
				subject = subjectJob + ' successfully';
				description = purgeJobDesc + ' successfully';
				status = 'Success';
				confirmText = BODY_TEXT_SUCCESS;
			}
		}
            
        string htmlMsg = description + ' <br/><br/>'
                    + 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
                    + System.Label.RTL_Purge_Email_002 + ' : ' + status + '<br/><br/>';

        if (queryForDailyJob != null && queryForDailyJob.length() > 0) {
        	htmlMsg = htmlMsg + 'SQL : '+ queryForDailyJob + '<br/><br/>';
        }


             htmlMsg = htmlMsg + '<table style="width:100%" border=1>'
                    + '<tr>'
                    + ' <th>No.</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_006 + '</th>'                  
                    + ' <th>' + System.Label.RTL_Purge_Email_003 + '</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_004 + '</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_005 + '</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_007 + '</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_008 + '</th>'
                    + ' <th>' + System.Label.RTL_Purge_Email_009 + '</th>'
                    + '</tr>'
                    + '<tr>'
                    + ' <td>1</td>' 
                    //+ '   <td>' + System.Label.RTL_Purge_Email_010 + '</td>'      
                    + ' <td>' + sobjectName + '</td>'               
                    + ' <td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
                    + ' <td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                    + ' <td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                    + ' <td>' + recordsProcessed + '</td>'
                    + ' <td>' + recordsSuccessful + '</td>'
                    + ' <td>' + recordsFailed + '</td>'
                    + '</tr>'
                    + '</table>'
					+ '<br/>' + confirmText
                    + '<br/><br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

        SendEmailByUserIdsAndSingleEmail(subject
        								, htmlMsg
        								,emailOpsList
        								,efaList
										,true);
	}

	// Start 3th ---->
	global static void SendEmailByUserIdsAndSingleEmail( String subject
														,String body
														,List<String> emailOpsList
														,List<Messaging.Emailfileattachment> efaList
														,Boolean isUseOrgWide) {
		Datetime startDatetime = Datetime.now();
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];
		// Get the list of email address from AppConfig
		Set<String> toAddressesSet = new Set<String>();

		for (String appconfigEmail : emailOpsList) {
			if (appconfigEmail == null || appconfigEmail.length() == 0) continue;
			
			if (appconfigEmail.length() >= 30 
				|| AppConfig__c.getValues(appconfigEmail) == null) {
				toAddressesSet.add(appconfigEmail);
			}else {
				String emailOps = AppConfig__c.getValues(appconfigEmail).Value__c;
				String[] emailAddrTmp = emailOps.split(';');

				for (String email : emailAddrTmp) {
					toAddressesSet.add(email);
				}
			}
		}
        system.debug('toAddressesSet='+toAddressesSet);

		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		//query user id by email
		Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Email,IsActive FROM User Where Email in: toAddressesSet]);
		
		Set<Id> userIds = userMap.keySet();
		Set<String> userEmailSet = new Set<String>();
		
		List<Set<Id>> userSentLstIds = new List<Set<Id>>();
		Set<Id> userSentIds = new Set<Id>();

		for (Id userId : userIds) {
			User user = userMap.get(userId);
			//modified 16-07-2018 in order to not send email to user who have multiple same email address.
			if (!toAddressesSet.contains(user.Email)) {
				continue;
			}
			//modified 16-07-2018 in order to not send email to user who have multiple same email address.
			if (user.IsActive) {
				userEmailSet.add(user.Email);
				userSentIds.add(user.Id);
				if (userSentIds.size() == LIMIT_TO_ADDR) {
					userSentLstIds.add(userSentIds.clone());
					userSentIds = new Set<Id>();
				}
			}
			
			//sent already then remove out from toAddressSet
			toAddressesSet.remove(user.Email);
		}

		if (userSentIds.size() > 0) userSentLstIds.add(userSentIds.clone());

		for (Set<Id> userIdsSet : userSentLstIds) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setCharset('UTF-8');
			mail.setToAddresses(new List<Id>(userIdsSet));

			mail.setSubject(subject);
			mail.setHtmlBody(body);

			//added on 09/04/2018 - to set org wide email
			if (owea != null && isUseOrgWide) {
		    	mail.setOrgWideEmailAddressId(owea.Id);
			}
			//added on 09/04/2018 - to set org wide email
			System.debug('efaList ' + efaList);
			if(!efaList.isEmpty()) mail.setFileAttachments(efaList);

			mailList.add(mail);
		}

		if (toAddressesSet != null && toAddressesSet.size() > 0) {
			List<Set<String>> userSentEmailLst = validateEmailSetAndRetList(toAddressesSet);

			userEmailSet.addAll(toAddressesSet);

			for (Set<String> toAddrSet : userSentEmailLst) {
				Messaging.SingleEmailMessage mailNotId = new Messaging.SingleEmailMessage();
                //change here---->
                mailNotId.setToAddresses(new List<String>(toAddrSet));

				mailNotId.setSubject(subject);
				mailNotId.setHtmlBody(body);
				mailNotId.setCharset('UTF-8');

				//added on 09/04/2018 - to set org wide email
				if (owea != null && isUseOrgWide) {
		    		mailNotId.setOrgWideEmailAddressId(owea.Id);
				}
				//added on 09/04/2018 - to set org wide email
				System.debug('efaList ' + efaList);
				if(!efaList.isEmpty())
	                mailNotId.setFileAttachments(efaList);

				mailList.add(mailNotId);
			}

		}
		
		if (Test.isRunningTest()) return;

		Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);

		doEmailLog(results,startDatetime,userEmailSet,subject);
		
	}  

	// Start 4th ---->
	//Add 26-03-2018 for CR CXM Monitoring and GoogleMap//
	private static void doEmailLog(Messaging.SendEmailResult[] results,Datetime startDatetime,Set<String> userEmailSet,String subject) {

		String message = 'Subject ' + subject + ' Sent to '+String.join(new List<String>(userEmailSet), ',');
		if (results[0].success) {
		    System.debug('The purging email was sent successfully.');

           	AppConfig__c cf = AppConfig__c.getValues('IS_BATCH_EMAIL_SERVICE_SUCCESS');
            String IS_BATCH_EMAIL_SERVICE_SUCCESS = (cf == null ? 'false' : cf.Value__c);
            Boolean isEnable = IS_BATCH_EMAIL_SERVICE_SUCCESS.equalsIgnoreCase('true'); 

            if (isEnable) {
            	RTL_Utility.InsertRTOnlineLog(null
                         ,null
                         ,UserInfo.getName()
                         ,null
                         ,message
                         ,null
                         ,null
                         ,startDatetime
                         ,DateTime.now()
                         ,'BATCH_EMAIL_SERVICE'
                         ,true);
            }
		} else {
		    System.debug('The purging email failed to send: ' + results[0].errors[0].message);
		    RTL_Utility.InsertRTOnlineLog(null
                         ,null
                         ,UserInfo.getName()
                         ,null
                         ,message +' '+results[0].errors[0].message
                         ,null
                         ,null
                         ,startDatetime
                         ,DateTime.now()
                         ,'BATCH_EMAIL_SERVICE'
                         ,false);
		}
	}

	// Function used 1
	private static List<Set<String>> validateEmailSetAndRetList(Set<String> emailSet) {
		List<Set<String>> emailSetLst = new List<Set<String>>();
		Set<String> validEmailSet = new Set<String>();

		for (String email : emailSet) {
			if (validateEmail(email)) {
				validEmailSet.add(email);

				if (validEmailSet.size() == LIMIT_TO_ADDR) {
					emailSetLst.add(validEmailSet.clone());
					validEmailSet = new Set<String>();
				}
			}
		}

		if (validEmailSet.size() > 0) emailSetLst.add(validEmailSet.clone());
		return emailSetLst;
	}
	// Function used 2
	public static String getDomain() { 
		system.debug(URL.getSalesforceBaseUrl().getHost()); 
		String hostname = URL.getSalesforceBaseUrl().getHost(); 
		system.debug('hostname : ' + hostname);
		String domain = 'https://' + hostname + '/one/one.app#/alohaRedirect/apex/fnaGenerateAvatarMatrix'; 
		system.debug('domain : ' + domain);
		return domain; 
	}
	// Function used 3
	private static Boolean validateEmail(String email) {
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern EamilPattern = Pattern.compile(emailRegex);
		Matcher EmailMatcher = EamilPattern.matcher(email);
		return EmailMatcher.matches();
	}
}