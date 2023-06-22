/**
 * @File Name          : ReportExportToEmailUtil.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/15/2019, 1:55:29 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/15/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class ReportExportToEmailUtil{
    global static String EXCEL_TYPE = 'application/vnd.ms-excel';
    global static String CSV_TYPE = 'text/csv;charset=UTF-8;';
    global static String PDF_TYPE = 'application/pdf';
    global static String BMP_TYPE = 'image/bmp';
    global static String GIF_TYPE = 'image/gif';
    global static String JPG_TYPE = 'image/jpeg';
    global static String PNG_TYPE = 'image/png';

    @Future(callout=true)
    global static void exportFuture(String reportDevName
                              ,String emailBodyContnent
                              ,String typeReport
                              ,String filename
                              ,List<String> emailOpsList) {
        try {
            List<Report> reportList = [SELECT Id,Name,DeveloperName FROM Report where
                                        DeveloperName = :reportDevName];

            if (reportList != null && reportList.size() > 0) {
                Report report = reportList.get(0);
                String reportId = report.Id;
                String reportName = report.Name;

                ApexPages.PageReference objPage = null;
                List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();

                if (typeReport == EXCEL_TYPE) {
                    objMsgEmailAttach.setFileName(filename+'.xls');
                    objPage = new ApexPages.PageReference('/'+reportId+'?excel=1&enc=UTF-8&&isdtp=p1');

                    if(!Test.isRunningTest()) {
                        objMsgEmailAttach.setBody(objPage.getContent());
                    }

                }else {
                    objMsgEmailAttach.setFileName(filename+'.csv');
                    objPage = new ApexPages.PageReference('/'+reportId+'?csv=1&enc=UTF-8&&isdtp=p1');

                    if(!Test.isRunningTest()) {
                        try {
                            String content = RTL_ReportUtility.getCSVReadableReport(objPage.getContent().toString());
                            objMsgEmailAttach.setBody(Blob.valueOf(content));
                        }catch(Exception e) {
                            //found exception (i.e., First error: String length exceeds maximum: 12000000) the display the same
                            objMsgEmailAttach.setBody(objPage.getContent());
                        }
                    }
                }
                
                objMsgEmailAttach.setContentType(typeReport);
                efaList.add(objMsgEmailAttach);

                sendEmailAttachment(reportName,emailBodyContnent,emailOpsList,efaList);
            }
        }catch(Exception e) {
            String subject     = reportDevName;
            String description = e.getMessage() + ' '+e.getStackTraceString();
            emailOpsList.clear();
            emailOpsList.add('CRM Admin 2');

            RTL_BatchEmailService.sendSummaryAttachmentEmail(subject, description,emailOpsList,new List<Messaging.Emailfileattachment>(),'FAIL');
        }
    }

    global static void exportCSVReportFuture(String reportDevName
                                      ,String emailBodyContnent
                                      ,String filename
                                      ,String userEmail
                                      ,String noRecordMessage
                                      ,List<String> emailOpsList) {
        exportCSVReportFuture( reportDevName
                                      , emailBodyContnent
                                      , filename
                                      , userEmail
                                      , noRecordMessage
                                      , emailOpsList
                                      ,false);
    }

    @Future(callout=true)
    global static void exportCSVReportFuture(String reportDevName
                                      ,String emailBodyContnent
                                      ,String filename
                                      ,String userEmail
                                      ,String noRecordMessage
                                      ,List<String> emailOpsList
                                      ,Boolean isSentToManager) {
        List<Report> reportList = [SELECT Id,Name,DeveloperName FROM Report where
                                    DeveloperName = :reportDevName];

        if (reportList != null && reportList.size() > 0) {
            Report report = reportList.get(0);
            String reportId = report.Id;
            String reportName = report.Name;
            List<User> inactiveUsrLst = new List<User>();

            try {
                List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();

                objMsgEmailAttach.setFileName(filename+'.csv');
                ApexPages.PageReference objPage = new ApexPages.PageReference('/'+reportId+'?csv=1&enc=UTF-8&&isdtp=p1');

                String contentCSV = objPage.getContent().toString();

                String header = contentCSV.substringBefore('\n');

                List<String> csvFieldNamesLst = header.split(',');

                contentCSV    = contentCSV.substring(header.length()+1
                                                    ,contentCSV.length());

                contentCSV    =  contentCSV.substringBefore('\n\n');


                if (contentCSV != null && contentCSV.length() > 0) {
                   Map<String,List<Map<String,String>>> valListMap = RTL_ReportUtility.readCSVToMap(contentCSV
                                                                                                    ,csvFieldNamesLst
                                                                                                    ,2000);

                    List<String> empNoLst = new List<String>();
                    for (String key : valListMap.keySet()) {
                        List<Map<String,String>> empMapLst = valListMap.get(key);


                        for (Map<String,String> empMap : empMapLst) {
                            String empNo = empMap.get('\"'+userEmail+'\"');
                            if (empNo != null && empNo.length() > 0 && !empNo.equals('\"\"')){
                                empNoLst.add(empNo.replaceAll('\"',''));
                            }
                        }
                    }

                    if (empNoLst != null && empNoLst.size() > 0) {
                        String queryUser = 'SELECT Email,IsActive,Manager.Email,Manager.IsActive,Employee_ID__c,Manager.Employee_ID__c FROM User WHERE Employee_ID__c in (\'' + String.join(empNoLst,'\',\'')+'\')';
                       
                        List<User> userLst = Database.query(queryUser);

                        for (User user : userLst) {
                            //Active user only
                            if (user.IsActive) emailOpsList.add(user.Email);
                            if (isSentToManager && user.Manager.IsActive) emailOpsList.add(user.Manager.Email);
                            
                            if (!user.IsActive) inactiveUsrLst.add(user);
                            if (isSentToManager && !user.Manager.IsActive) inactiveUsrLst.add(user.Manager);

                            //emailOpsList.add(user.Email);
                            //emailOpsList.add(user.Manager.Email);
                        }
                    }

                    if(!Test.isRunningTest()) {
                        try {
                            String content = RTL_ReportUtility.getCSVReadableReport(objPage.getContent().toString());
                            objMsgEmailAttach.setBody(Blob.valueOf(content));
                        }catch(Exception e) {
                            //found exception (i.e., First error: String length exceeds maximum: 12000000) the display the same
                            objMsgEmailAttach.setBody(objPage.getContent());
                        }
                    }

                    objMsgEmailAttach.setContentType(CSV_TYPE);
                    efaList.add(objMsgEmailAttach);
                }else {
                    //No Record Message
                    emailBodyContnent = noRecordMessage;
                }

                if (noRecordMessage != null && noRecordMessage.length() > 0 || efaList.size() > 0) {
                    String subject     = reportName;
                    String description = emailBodyContnent;

                    String classicReportURL = URL.getSalesforceBaseUrl().toExternalForm() +'/console#/' + reportId;

                    AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
                    String lightReport = (lightCF == null ? classicReportURL : lightCF.Value__c + '/lightning/r/Report/'+reportId+'/view');

                    String statusMessage = ' <br/>'
                                            + 'Please click URL below to view Report on Salesforce: <br/><br/>'
                                            + 'From Sales Console: <br/>'
                                            + classicReportURL 
                                            + '<br/><br/>'
                                            + 'From Lightning Experience: <br/>'
                                            + lightReport
                                            + '<br/>';

                    RTL_BatchEmailService.sendAttachmentEmail(subject
                                                 ,description
                                                 ,emailOpsList
                                                 ,efaList
                                                 ,statusMessage
                                                    );

                }

                
                notifyInactiveUserForReportEmail(inactiveUsrLst,reportName);
            }catch(Exception e) {
                String subject     = reportName;
                String description = e.getMessage() + ' '+e.getStackTraceString();
                emailOpsList.clear();
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.sendSummaryAttachmentEmail(subject, description,emailOpsList,new List<Messaging.Emailfileattachment>(),'FAIL');
            }
        }
    }

    
    @RemoteAction
    global static String sendFiles(String fileList
                                   ,String subject
                                   ,String body
                                   ,String templateID
                                   ,String emailList) {
        Set<Id> fileIds = (Set<Id>) JSON.deserialize(fileList, Set<Id>.class);
        List<String> emailOpsList = (List<String>) JSON.deserialize(emailList, List<String>.class);

        attachmentFileFuture(fileIds,subject,body, null, emailOpsList);

        return 'Send Email';
    }

    @Future(callout=true)
    private static void attachmentFileFuture(Set<Id> fileIds
                                            ,String subject
                                            ,String body
                                            ,Id emailTemplateId
                                            ,List<String> emailOpsList) {
        if (fileIds != null && fileIds.size() > 0) {
            List<Messaging.EmailFileAttachment> objMsgEmailAttachList = new List<Messaging.EmailFileAttachment>();

            List<ContentVersion> contentVersionList = [SELECT Id
                                                    ,ContentDocument.Title
                                                    ,ContentDocument.FileExtension
                                                FROM ContentVersion where ContentDocumentId in: fileIds
                                                ];

            for (ContentVersion contentVersion : contentVersionList) {
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
                ///sfc/servlet.shepherd/version/download/0695D0000003xm2
                ApexPages.PageReference objPage = new ApexPages.PageReference('/sfc/servlet.shepherd/version/download/'+contentVersion.Id);
                String filename = contentVersion.ContentDocument.Title;
                String fileExtension = contentVersion.ContentDocument.FileExtension;

                objMsgEmailAttach.setFileName(filename+'.'+fileExtension);

                if (PDF_TYPE.contains(fileExtension)) {
                    objMsgEmailAttach.setContentType(PDF_TYPE);
                }else if (GIF_TYPE.contains(fileExtension))  {
                    objMsgEmailAttach.setContentType(GIF_TYPE);
                }else if (JPG_TYPE.contains(fileExtension))  {
                    objMsgEmailAttach.setContentType(JPG_TYPE);
                }else if (PNG_TYPE.contains(fileExtension))  {
                    objMsgEmailAttach.setContentType(PNG_TYPE);
                }

                if(!Test.isRunningTest()) {
                    objMsgEmailAttach.setBody(objPage.getContent());
                }
                
                
                objMsgEmailAttachList.add(objMsgEmailAttach);
            }


            if (objMsgEmailAttachList.size() > 0) sendEmailAttachment(subject
                                                ,body,emailOpsList
                                                ,objMsgEmailAttachList);
        }
    }

    private static void sendEmailAttachment(String reportName
                                            ,String emailBodyContnent
                                            ,List<String> emailOpsList
                                            ,List<Messaging.Emailfileattachment> efaList
                                            ) {
        String subject = reportName+' '+emailBodyContnent;
        string description = reportName+' '+emailBodyContnent;
        RTL_BatchEmailService.sendSummaryAttachmentEmail(subject, description,emailOpsList,efaList);
    }

    public static void notifyInactiveUserForReportEmail(List<User> inactiveUserLst,String serviceName) {
        if (inactiveUserLst.size() > 0) {
            List<String> emailOpsList = new List<String>();

            emailOpsList.add('CRM Admin 2');

            String CSV_BODY ='';
            for (User inactiveUser : inactiveUserLst) {
                CSV_BODY += inactiveUser.Email
                            + ','
                            +inactiveUser.Employee_ID__c
                            + ','
                            +'This Email is inactive user' 
                            +'\n';
            }
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(datetime.now()
                                                        , datetime.now()
                                                        , datetime.now()
                                                        , 0
                                                        , inactiveUserLst.size()
                                                        , serviceName+' Found Inactive User'
                                                        , 'User'
                                                        , emailOpsList
                                                        , CSV_BODY
                                                        , ''
                                                        , ''
                                                        , 'Email_Inactive_User_Found,EMP_CODE,ErrorMessage\n'
                                                        , ''
                                                        , ''
                                                        , ''
                                                        );
        }
    }

    public static void getRoleNotFoundForReportEmail(List<String> roleList,List<User> userList,String serviceName) {
        Set<String> roleFoundLst = new Set<String>();
        Set<String> roleSet = new Set<String>(roleList);

        for (User user : userList) {
            roleFoundLst.add(user.UserRole.DeveloperName);
        }

        for (String role: roleFoundLst) {
            roleSet.remove(role);
        }
         

        if (roleSet.size() > 0) {
            List<String> emailOpsList = new List<String>();

            emailOpsList.add('CRM Admin 2');

            String CSV_BODY ='';
            for (String roleMissing : roleSet) {
                CSV_BODY += roleMissing
                            + ','
                            +'Not Found Any User in the role' 
                            +'\n';
            }
            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(datetime.now()
                                                        , datetime.now()
                                                        , datetime.now()
                                                        , 0
                                                        , roleSet.size()
                                                        , serviceName+' Not Found Any User in Role'
                                                        , 'Role'
                                                        , emailOpsList
                                                        , CSV_BODY
                                                        , ''
                                                        , ''
                                                        , 'Role_Not_Found,ErrorMessage\n'
                                                        , ''
                                                        , ''
                                                        , ''
                                                        );
        }                                               
    }
}