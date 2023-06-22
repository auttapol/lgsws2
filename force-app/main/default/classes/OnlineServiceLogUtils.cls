public class OnlineServiceLogUtils {

    public static void saveToOnlineLog(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc , 
                            DateTime startTime , DateTime endTime, String base64Data )
    {

        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        
        osLog.RTL_Is_Success__c = isSuccess;  

        osLog.RTL_Customer_Name__c = customerName;
        
        osLog.RTL_Error_Message__c = errorMessage;
       
        osLog.RTL_Mulesoft_Log_Id__c = msLogId;
    
        osLog.RTL_Name_of_User__c = userName;

        osLog.RTL_RM_ID__c = rmId;
    
        osLog.RTL_Service_Name__c = serviceName;

        if( acc != null )
        {
            osLog.RTL_Account__c = acc.id;
            osLog.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
        }

        osLog.RTL_Start_DateTime__c = startTime;
        osLog.RTL_End_DateTime__c  = endTime;
        
        insert osLog;

        //List<Attachment> importattachmentfileList = new List<Attachment>();
        if( requestBody != '' && requestBody != null)
        { 
            GenerateContentVersion(osLog.id, 'requestBody.txt', false, Blob.valueOf(requestBody));
        }

        if( responseBody != '' && responseBody != null )
        { 
            GenerateContentVersion(osLog.id, 'responseBody.txt', false, Blob.valueOf(responseBody));
        }
    }

    private static void GenerateContentVersion (string parentId, string name, boolean isPrivated, Blob body) {
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //S - Salesforce
        cv.PathOnClient = name;
        cv.Origin = 'H'; //H - Chatter
        cv.Title = name;
        cv.VersionData = body;
        insert cv;
        
        // [cv] should have [Id] after [insert] command
        ContentVersion insertedCv = [SELECT Id, OwnerId, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE Id =: cv.Id];
        
        ContentDocumentLink autoInsertCl = [SELECT Id, LinkedEntityId, ContentDocumentId
                                            FROM ContentDocumentLink
                                            WHERE ContentDocumentId =: insertedCv.ContentDocumentId];
        
        ContentDocumentLink clonedCl = autoInsertCl.clone();
        clonedCl.ShareType = 'V';
        clonedCl.LinkedEntityId = parentId;
        insert clonedCl;
        delete autoInsertCl;
    }

    public static void GenerateContentVersions (String filename,String content,List<ContentVersion> cvList) {
       //insert content version for file
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //S - Salesforce
        cv.PathOnClient = filename;
        cv.Origin = 'H'; //H - Chatter
        cv.Title = filename;
        cv.VersionData = Blob.valueOf(content);
        cvList.add(cv);
    }

    //must call this functoin in finish function
    public static void GenerateContentDocumentLink (List<ContentVersion> cvList
                                                    ,List<ContentDocumentLink> allcdList
                                                    ,List<ContentDocumentLink> removeCDList
                                                    ,Id parentId) {

        List<Id> cvIds = new List<Id>();

        for (ContentVersion cv : cvList) {
            cvIds.add(cv.Id);
        }

        List<ContentVersion> insertedCvList = [SELECT Id, OwnerId, ContentDocumentId
                                                     FROM ContentVersion
                                                     WHERE Id in: cvIds
                                                  ];

        SET<Id> contentDocIds = new SET<Id>();

        Map<Id,Id> contentParentIdMap = new Map<Id,Id>();

        for (ContentVersion cv : insertedCvList) {
            contentDocIds.add(cv.ContentDocumentId);
        }

        List<ContentDocumentLink> autoInsertClList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId IN: contentDocIds
                                                          ];

        if (autoInsertClList != null && autoInsertClList.size() > 0) {
            for (ContentDocumentLink autoInsertCl : autoInsertClList) {
                ContentDocumentLink clonedCl = autoInsertCl.clone();
                clonedCl.ShareType = 'V';
                clonedCl.LinkedEntityId = parentId;
                allcdList.add(clonedCl);
            }
            
            removeCDList.addAll(autoInsertClList);
        }
        
    }

    //must call this functoin in finish function
    public static void GenerateContentDocumentLink (Map<Id,Id> cvLogIdMap
                                                    ,List<ContentDocumentLink> allcdList
                                                    ,List<ContentDocumentLink> removeCDList) {
        /*
        List<Id> cvIds = new List<Id>();

        for (ContentVersion cv : cvList) {
            cvIds.add(cv.Id);
        }*/

        List<ContentVersion> insertedCvList = [SELECT Id, OwnerId, ContentDocumentId
                                                     FROM ContentVersion
                                                     WHERE Id in: cvLogIdMap.KeySet()
                                                  ];

        //List<Id> parentIds = new List<Id>();

        Map<Id,Id> contentParentIdMap = new Map<Id,Id>();

        for (ContentVersion cv : insertedCvList) {
            //contentDocIds.add(cv.ContentDocumentId);

            Id parentId = cvLogIdMap.get(cv.Id);

            contentParentIdMap.put(cv.ContentDocumentId,parentId);

            //parentIds.add(parentId);
        }
        
        List<ContentDocumentLink> autoInsertClList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId IN : contentParentIdMap.KeySet()
                                                          ];

        if (autoInsertClList != null && autoInsertClList.size() > 0) {
                for (ContentDocumentLink autoInsertCl : autoInsertClList) {
                    ContentDocumentLink clonedCl = autoInsertCl.clone();
                    clonedCl.ShareType = 'V';
                    clonedCl.LinkedEntityId = contentParentIdMap.get(autoInsertCl.ContentDocumentId);
                    allcdList.add(clonedCl);
                }

                removeCDList.addAll(autoInsertClList);
        }
        /*
        for (Id contentDocId : contentParentIdMap.KeySet()) {
             List<ContentDocumentLink> autoInsertClList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId =: contentDocId
                                                          ];

            if (autoInsertClList != null && autoInsertClList.size() > 0) {
                for (ContentDocumentLink autoInsertCl : autoInsertClList) {
                    ContentDocumentLink clonedCl = autoInsertCl.clone();
                    clonedCl.ShareType = 'V';
                    clonedCl.LinkedEntityId = contentParentIdMap.get(contentDocId);
                    allcdList.add(clonedCl);
                }

                removeCDList.addAll(autoInsertClList);
            }
        }*/
    }
}