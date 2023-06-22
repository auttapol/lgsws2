global class Forecast_BatchEmailService {
    private static Integer LIMIT_TO_ADDR = 20;

    
	global static void SendFinishDailyBatchSummaryEmail(List<Datetime> batchDateSet, List<Datetime> batchStartTimeSet, List<Datetime> batchEndTimeSet, List<Integer> recordsSuccessfulSet, List<Integer> recordsFailedSet ,List<String> yearSet ,List<String> monthSet, String jobDailyName, String sobjectName, List<String> emailOpsList, String mainError, String secondaryError, String successLog, String mainErrorHeader, String secondaryErrorHeader, String successLogHeader, String queryForDailyJob) {
        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            System.debug('mainErrorHeader::'+mainErrorHeader);
            System.debug('mainError::'+mainError);
        if (!String.isBlank(mainError)) {
            String Header_CSV = mainErrorHeader;
            String CSV_SUMMARY = Header_CSV + mainError;
            String content = RTL_ReportUtility.getCSVReadableReport(CSV_SUMMARY);
            //Blob csvBlob = Blob.valueOf(CSV_SUMMARY);
            Blob csvBlob = Blob.valueOf(content);
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            csvAttc.setFileName('Error_Summary_'+jobDailyName+'.csv');
            csvAttc.setBody(csvBlob);
            csvAttc.setContentType('text/csv; charset=UTF-8');
            efaList.add(csvAttc);
        }

        // if (!String.isBlank(secondaryError)) {
        //     String Header_CSV = secondaryErrorHeader; 
        //     String UPDATE_BODY_SUMMARY = Header_CSV + secondaryError;
        //     //Blob csvBlob = Blob.valueOf(UPDATE_BODY_SUMMARY);

        //     String content = RTL_ReportUtility.getCSVReadableReport(UPDATE_BODY_SUMMARY);
        //     Blob csvBlob = Blob.valueOf(content);

        //     Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

        //     csvAttc.setFileName('Error_Secondary_Summary_'+jobDailyName+'.csv');
        //     csvAttc.setBody(csvBlob);
        //     csvAttc.setContentType('text/csv; charset=UTF-8');
        //     efaList.add(csvAttc);
        // }

        // if (!String.isBlank(successLog)) {
        //     String Header_CSV = successLogHeader;
        //     String LOG_SUCCESS = Header_CSV + successLog;
        //     //Blob csvBlob = Blob.valueOf(LOG_SUCCESS);

        //     String content = RTL_ReportUtility.getCSVReadableReport(LOG_SUCCESS);
        //     Blob csvBlob = Blob.valueOf(content);

        //     Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

        //     csvAttc.setFileName('LOG_SUCCESS_'+jobDailyName+'.csv');
        //     csvAttc.setBody(csvBlob);
        //     csvAttc.setContentType('text/csv; charset=UTF-8');
        //     efaList.add(csvAttc);
        // }

        SendFinishBatchSummaryEmail(batchDateSet, batchStartTimeSet, batchEndTimeSet, recordsSuccessfulSet, recordsFailedSet , yearSet , monthSet, jobDailyName, sobjectName, emailOpsList, efaList, queryForDailyJob);
    }


    
    global static void SendFinishBatchSummaryEmail(List<Datetime> batchDateSet, List<Datetime> batchStartTimeSet, List<Datetime> batchEndTimeSet, List<Integer> recordsSuccessfulSet, List<Integer> recordsFailedSet ,List<String> yearSet ,List<String> monthSet, String jobDailyName, String sobjectName, List<String> emailOpsList, List<Messaging.Emailfileattachment> efaList, String queryForDailyJob)  {
		TimeZone tz = UserInfo.getTimeZone();
        
        
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
            
        Integer AllRecordsFailed = 0;
        for(Integer i = 0; i<recordsFailedSet.size() ; i++){
            AllRecordsFailed += recordsFailedSet[i];
        }
        if (AllRecordsFailed > 0) {
            //there are failed records
            subject = subjectJob + ' completely';
            description = purgeJobDesc + ' completely';
            status = 'Failed';
        } else {
            //there are no failed records
            subject = subjectJob + ' successfully';
            description = purgeJobDesc + ' successfully';
            status = 'Success';
        }

        string htmlMsg = description + ' <br/><br/>'
                    + 'Batch as of : ' + batchDateSet[0].format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
                    + System.Label.RTL_Purge_Email_002 + ' : ' + status + '<br/><br/>';

        if (queryForDailyJob != null && queryForDailyJob.length() > 0) {
        	htmlMsg = htmlMsg + 'SQL : '+ queryForDailyJob + '<br/><br/>';
        }


        htmlMsg = htmlMsg + '<table style="width:100%" border=1>'
               + '<tr>'
               + ' <th>No.</th>'
               + ' <th>' + 'Batch Name' + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_006 + '</th>'    
               + ' <th>' + System.Label.RTL_Purge_Email_003 + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_004 + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_005 + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_007 + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_008 + '</th>'
               + ' <th>' + System.Label.RTL_Purge_Email_009 + '</th>'
               + '</tr>';
        for (Integer i = 0 ; i < recordsSuccessfulSet.size() ; i++) {
            datetime batchDate = batchDateSet[i];
            datetime batchStartTime = batchStartTimeSet[i];
            datetime batchEndTime = batchEndTimeSet[i];
            Integer recordsSuccessful = recordsSuccessfulSet[i];
            Integer recordsFailed = recordsFailedSet[i];
            String year = yearSet[i];
            String month = monthSet[i];
            Integer recordsProcessed = recordsSuccessful + recordsFailed;
            if (recordsFailed > 0) {//there are failed records
                subject = subjectJob + ' completely';
                description = purgeJobDesc + ' completely';
                status = 'Failed';
            } else {//there are no failed records
                subject = subjectJob + ' successfully';
                description = purgeJobDesc + ' successfully';
                status = 'Success';
            }
                htmlMsg = htmlMsg + '<tr>'
                + ' <td> ' + (i+1) + '</td>' 
                + ' <td>' + jobDailyName + '('+month +'/'+ year + ')'+'</td>'  
                + ' <td>' + sobjectName + '</td>'              
                + ' <td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
                + ' <td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                + ' <td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                + ' <td>' + recordsProcessed + '</td>'
                + ' <td>' + recordsSuccessful + '</td>'
                + ' <td>' + recordsFailed + '</td>'
                + '</tr>';
        }
                    htmlMsg = htmlMsg + '</table>'
                        + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                        + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		SendEmailByUserIdsAndSingleEmail(subject, htmlMsg, emailOpsList, efaList, true);

	}


	global static void SendEmailByUserIdsAndSingleEmail( String subject ,String body ,List<String> emailOpsList ,List<Messaging.Emailfileattachment> efaList ,Boolean isUseOrgWide) {
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
    
	private static void doEmailLog(Messaging.SendEmailResult[] results,Datetime startDatetime,Set<String> userEmailSet,String subject) {

		String message = 'Subject ' + subject + ' Sent to '+String.join(new List<String>(userEmailSet), ',');
		if (results[0].success) {
		    System.debug('The purging email was sent successfully.');

           	AppConfig__c cf = AppConfig__c.getValues('IS_BATCH_EMAIL_SERVICE_SUCCESS');
            String IS_BATCH_EMAIL_SERVICE_SUCCESS = (cf == null ? 'false' : cf.Value__c);
            Boolean isEnable = IS_BATCH_EMAIL_SERVICE_SUCCESS.equalsIgnoreCase('true'); 

            if (isEnable) {
            	RTL_Utility.InsertRTOnlineLog(null ,null ,UserInfo.getName() ,null ,message ,null ,null ,startDatetime ,DateTime.now() ,'BATCH_EMAIL_SERVICE' ,true);
            }
		} else {
		    System.debug('The purging email failed to send: ' + results[0].errors[0].message);
		    RTL_Utility.InsertRTOnlineLog(null ,null ,UserInfo.getName() ,null ,message +' '+results[0].errors[0].message ,null ,null ,startDatetime ,DateTime.now() ,'BATCH_EMAIL_SERVICE' ,false);
		}
	}
}