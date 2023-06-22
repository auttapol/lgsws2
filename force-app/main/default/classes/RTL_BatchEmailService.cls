global class RTL_BatchEmailService {
	private static Integer LIMIT_TO_ADDR = 20;

	//Add 26-03-2018 for CR CXM Monitoring and GoogleMap//
	global static void sendSummaryAttachmentEmail(String subject
												 ,String description
												 ,List<String> emailOpsList
												 ,List<Messaging.Emailfileattachment> efaList
													) {
		sendSummaryAttachmentEmail(subject
									,description
									,emailOpsList
									,efaList
									,'SUCCESS');
	}

	global static void sendSummaryAttachmentEmail(String subject
												 ,String description
												 ,List<String> emailOpsList
												 ,List<Messaging.Emailfileattachment> efaList
												 ,String statusMessage
													) {
		String status = statusMessage;
		string htmlMsg = description + ' <br/><br/>'
                    + System.Label.RTL_Purge_Email_002 + ' : ' + status + '<br/>'
                    + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		SendEmailByUserIdsAndSingleEmail(subject
        								,htmlMsg
        								,emailOpsList
        								,efaList); 
	}

	global static void sendAttachmentEmail(String subject
												 ,String description
												 ,List<String> emailOpsList
												 ,List<Messaging.Emailfileattachment> efaList
												 ,String statusMessage
													) {
		string htmlMsg = description + ' <br/><br/>'
                    + statusMessage + '<br/>'
                    + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		SendEmailByUserIdsAndSingleEmail(subject
        								,htmlMsg
        								,emailOpsList
        								,efaList); 
	}

	@future
	global static void SendFinishDailyBatchForFuture(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,String mainError
													,String secondaryError
													,String successLog
													,String mainErrorHeader
													,String secondaryErrorHeader
													,String successLogHeader
													,String queryForDailyJob
													) {
		SendFinishDailyBatchSummaryEmail( batchDate
												    , batchStartTime
												    , batchEndTime
													, recordsSuccessful
													, recordsFailed
													, jobDailyName
													, sobjectName
													, emailOpsList
													, mainError
													, secondaryError
													, successLog
													, mainErrorHeader
													, secondaryErrorHeader
													, successLogHeader
													, queryForDailyJob
                                                        );
	}

	
	global static void SendFinishDailyBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,String mainError
													,String secondaryError
													,String successLog
													,String mainErrorHeader
													,String secondaryErrorHeader
													,String successLogHeader
													,String queryForDailyJob
													) {
		List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
		
		if (!String.isBlank(mainError)) {
			String Header_CSV = mainErrorHeader;
	    	String CSV_SUMMARY = Header_CSV + mainError;

	    	String content = RTL_ReportUtility.getCSVReadableReport(CSV_SUMMARY);

	    	//Blob csvBlob = Blob.valueOf(CSV_SUMMARY);
	    	Blob csvBlob = Blob.valueOf(content);
	    	
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
	    	//Blob csvBlob = Blob.valueOf(UPDATE_BODY_SUMMARY);

	    	String content = RTL_ReportUtility.getCSVReadableReport(UPDATE_BODY_SUMMARY);
	    	Blob csvBlob = Blob.valueOf(content);
	    	
	    	Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

			csvAttc.setFileName('Error_Secondary_Summary_'+jobDailyName+'.csv');
			csvAttc.setBody(csvBlob);
			csvAttc.setContentType('text/csv; charset=UTF-8');
			efaList.add(csvAttc);
		}

		if (!String.isBlank(successLog)) {
			String Header_CSV = successLogHeader;
	    	String LOG_SUCCESS = Header_CSV + successLog;
	    	//Blob csvBlob = Blob.valueOf(LOG_SUCCESS);

	    	String content = RTL_ReportUtility.getCSVReadableReport(LOG_SUCCESS);
	    	Blob csvBlob = Blob.valueOf(content);
	    	
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
                                    , queryForDailyJob
                                    );
	}

	global static void SendFinishBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String csvHeaderStr
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,String CSV_BODY
													) {
		List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
		
		if (CSV_BODY != null && CSV_BODY.length() > 0) {
			String Header_CSV = csvHeaderStr+'\n';
	    	String CSV_SUMMARY = Header_CSV + CSV_BODY;
	    	Blob csvBlob = Blob.valueOf(CSV_SUMMARY);
	    	
	    	Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

			csvAttc.setFileName('Error_Summary_'+jobDailyName+'.csv');
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
                                    );
	}

	global static void SendFinishBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,String CSV_BODY
													) {
		String csvHeaderStr = 'RecordId,ErrorMessage,ErrorOnFields,StatusCode';

		SendFinishBatchSummaryEmail(  batchDate
									, batchStartTime
									, batchEndTime
									, recordsSuccessful
									, recordsFailed
									, csvHeaderStr
									, jobDailyName
									, sobjectName
									, emailOpsList
									, CSV_BODY
									);
	}

	global static void SendFinishBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,List<Messaging.Emailfileattachment> efaList
													,String queryForDailyJob
													) {
		TimeZone tz = UserInfo.getTimeZone();
        Integer recordsProcessed = recordsSuccessful + recordsFailed;
        
        String subject = null;
        String description = null;
        String status = null;

        //Refacorting Delete Batch 27-12-2017
        List<String> fillers = new String[]{jobDailyName};
        String purgeJobDesc = String.format(System.Label.For_Daily_Batch_Desc
                                            , fillers);
        String subjectJob   = String.format(System.Label.For_Daily_Batch_Header
                                            , fillers);
        //Refacorting Delete Batch 27-12-2017

        if (recordsFailed > 0) {//there are failed records
            subject = subjectJob + ' completely';
            description = purgeJobDesc + ' completely';
            status = 'Failed';
        } else {//there are no failed records
            subject = subjectJob + ' successfully';
            description = purgeJobDesc + ' successfully';
            status = 'Success';
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
                    + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

        SendEmailByUserIdsAndSingleEmail(subject
        								, htmlMsg
        								,emailOpsList
        								,efaList); 

	}

	global static void SendFinishBatchSummaryEmail(Datetime batchDate
												    ,Datetime batchStartTime
												    ,Datetime batchEndTime
													,Integer recordsSuccessful
													,Integer recordsFailed
													,String jobDailyName
													,String sobjectName
													,List<String> emailOpsList
													,List<Messaging.Emailfileattachment> efaList
													) {
		SendFinishBatchSummaryEmail(batchDate
                                    , batchStartTime
                                    , batchEndTime
                                    , recordsSuccessful
                                    , recordsFailed
                                    , jobDailyName
                                    , sobjectName
                                    , emailOpsList
                                    , efaList
                                    , ''
                                    );
	}
	

	global static void SendEmailByUserIdsAndSingleEmail( String subject
														,String body
														,List<String> emailOpsList
														,List<Messaging.Emailfileattachment> efaList) {

		SendEmailByUserIdsAndSingleEmail(subject
										,body
										,emailOpsList
										,efaList
										,true);
	}



	private static Boolean validateEmail(String email) {
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern EamilPattern = Pattern.compile(emailRegex);
		Matcher EmailMatcher = EamilPattern.matcher(email);
		return EmailMatcher.matches();
	}

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

		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		//query user id by email
		//Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Email,IsActive FROM User Where Email in: toAddressesSet AND IsActive = true]);
			
		Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Email,IsActive 
													FROM User Where Email in: toAddressesSet
													Order by UserRoleId asc
													]);
		
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

			if(!efaList.isEmpty()) mail.setFileAttachments(efaList);

			mailList.add(mail);
		}

		if (toAddressesSet != null && toAddressesSet.size() > 0) {
			List<Set<String>> userSentEmailLst = validateEmailSetAndRetList(toAddressesSet);

			userEmailSet.addAll(toAddressesSet);

			for (Set<String> toAddrSet : userSentEmailLst) {
				Messaging.SingleEmailMessage mailNotId = new Messaging.SingleEmailMessage();
				mailNotId.setToAddresses(new List<String>(toAddrSet));
				mailNotId.setSubject(subject);
				mailNotId.setHtmlBody(body);
				mailNotId.setCharset('UTF-8');

				//added on 09/04/2018 - to set org wide email
				if (owea != null && isUseOrgWide) {
		    		mailNotId.setOrgWideEmailAddressId(owea.Id);
				}
				//added on 09/04/2018 - to set org wide email

				if(!efaList.isEmpty())
	                mailNotId.setFileAttachments(efaList);

				mailList.add(mailNotId);
			}

		}
		
		if (Test.isRunningTest()) return;

		Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);

		doEmailLog(results,startDatetime,userEmailSet,subject);
		
	}  
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

	global static void SendEmail(Id jobId, String subject, String body) {
		if (Test.isRunningTest()) return;
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];
		// Get the list of email address from AppConfig
		String emailOpsTeamA = AppConfig__c.getValues('Operation Team A').Value__c;
		String emailOpsTeamB = AppConfig__c.getValues('Operation Team B').Value__c;
		String emailOpsTeamC = AppConfig__c.getValues('Operation Team C').Value__c;
		String emailOpsTeamD = AppConfig__c.getValues('Operation Team D').Value__c;
		String emailOpsTeamAppMon = AppConfig__c.getValues('Operation Team App monitoring').Value__c;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = mergeEmailAddr(emailOpsTeamA, emailOpsTeamB, emailOpsTeamC, emailOpsTeamD, emailOpsTeamAppMon);
		mail.setToAddresses(toAddresses);
		if (owea != null) {
    		mail.setOrgWideEmailAddressId(owea.Id);
		}			
		mail.setSubject(subject);
		mail.setHtmlBody(body);
		Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		if (results[0].success) {
		    System.debug('The purging email was sent successfully.');
		} else {
		    System.debug('The purging email failed to send: ' + results[0].errors[0].message);
		}
	}

	global static void SendEmailToRecipientList(Id jobId, String subject, String body,List<String> recipientList) {
		if (Test.isRunningTest()) return;
		
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];
		String[] recipentEmailList = new String[]{};
		// Get the list of email address from AppConfig
		for(String appConfigName : recipientList){
			AppConfig__c appConfig =  AppConfig__c.getValues(appConfigName);
			if(appConfig != null){
				String recipient = AppConfig__c.getValues(appConfigName).Value__c;
				recipentEmailList.add(recipient);
			}
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = RTL_BatchEmailService.mergeEmailAddr(recipentEmailList);
		mail.setToAddresses(toAddresses);
		if (owea != null) {
    		mail.setOrgWideEmailAddressId(owea.Id);
		}			
		mail.setSubject(subject);
		mail.setHtmlBody(body);
		Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		if (results[0].success) {
		    System.debug('The email was sent successfully.');
		} else {
		    System.debug('The email failed to send: ' + results[0].errors[0].message);
		}
	}

	public static String[] mergeEmailAddr(List<String> recipentList){
		String emailAddress = ''; //split by ';'
		for(String emailList : recipentList){
			if (emailList != null && emailList != '') {
				emailAddress += emailList + ';';
			}
		}

		if (emailAddress.endswith(';')) {
			emailAddress = emailAddress.substring(0, emailAddress.length()-1);
		}
		String[] emailAddrTmp = emailAddress.split(';');
		Set<String> emailAddrSet = new Set<String>();
		for (String email: emailAddrTmp) {
			if (email != '' && validateEmail(email)) {//filter blank or duplicate email
				emailAddrSet.add(email);
			}
		}
		List<String> emailAddrList = new List<String>();
		emailAddrList.addAll(emailAddrSet);		
		return emailAddrList;


	}   
	
	public static String[] mergeEmailAddr(String emailOpsTeamA, String emailOpsTeamB, String emailOpsTeamC, String emailOpsTeamD, String emailOpsTeamAppMon) {
		String emailAddress = ''; //split by ';'
		if (emailOpsTeamA != null && emailOpsTeamA != '') {
			emailAddress += emailOpsTeamA + ';';
		}
		if (emailOpsTeamB != null && emailOpsTeamB != '') {
			emailAddress += emailOpsTeamB + ';';
		}
		if (emailOpsTeamC != null && emailOpsTeamC != '') {
			emailAddress += emailOpsTeamC + ';';
		}	
		if (emailOpsTeamD != null && emailOpsTeamD != '') {
			emailAddress += emailOpsTeamD + ';';
		}	
		if (emailOpsTeamAppMon != null && emailOpsTeamAppMon != '') {
			emailAddress += emailOpsTeamAppMon;
		}
		if (emailAddress.endswith(';')) {
			emailAddress = emailAddress.substring(0, emailAddress.length()-1);
		}
		String[] emailAddrTmp = emailAddress.split(';');
		Set<String> emailAddrSet = new Set<String>();
		for (String email: emailAddrTmp) {
			if (email != '' && validateEmail(email)) {//filter blank or duplicate email
				emailAddrSet.add(email);
			}
		}
		List<String> emailAddrList = new List<String>();
		emailAddrList.addAll(emailAddrSet);		
		return emailAddrList;
	}
}