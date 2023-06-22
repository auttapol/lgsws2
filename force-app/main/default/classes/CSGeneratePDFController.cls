public class CSGeneratePDFController {

    @AuraEnabled
    public static E_Client_Suitability__c getEclient(String eclientId)
    {
        try 
        {
            E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, 
                    CS_Customer_Survey_A__r.Status__c,CS_Customer_Survey_B__r.Status__c,
                    CS_Customer__r.TMB_Customer_ID_PE__c,CS_RM__r.Name,CS_Sales_Owner__r.Name, CS_Status__c, 
                    LastModifiedBy.Name, CreatedDate, LastModifiedDate,
                    CS_RM_TH_Approved_Date_Tme__c, CS_Sales_TH_Approved_Date_Time__c
            FROM E_Client_Suitability__c
            WHERE Id =: eclientId
            ];

            return ec;
            
        } 
        catch(Exception e) 
        {
            System.debug(e.getMessage());
            return null;
        }


    }

	@AuraEnabled
	public static void generatePDFfile(String eclientId)
	{

        try{

            E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, 
                        CS_Customer__r.TMB_Customer_ID_PE__c,CS_RM__r.Name,CS_Sales_Owner__r.Name, CS_Status__c, 
                        LastModifiedBy.Name, CreatedDate, LastModifiedDate,Sale_Submit_Date_Time__c,
                        CS_RM_TH_Approved_Date_Tme__c, CS_Sales_TH_Approved_Date_Time__c,Sales_TH_Approved_DT__c,PDF_Generated_Date_Time__c
                        FROM E_Client_Suitability__c
                        WHERE Id =: eclientId
                        ];

            User oUser = [SELECT Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
            FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];

            String createdDate = ec.CreatedDate.format('YYYYMMdd');
            String rm15digit = ec.CS_Customer__r.TMB_Customer_ID_PE__c.right(15);

            String fileName = createdDate+'_'+rm15digit+'.pdf';

            Id pendingRecordTypeId = Schema.Sobjecttype.E_Client_Suitability__c.getRecordTypeInfosByName().get('Pending Sale').getRecordTypeId();

            /*E_Client_Suitability__c ecs = new E_Client_Suitability__c( Id = ec.Id );

            ecs.PDF_Generated_Date_Time__c = DateTime.now();
            ecs.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            if( ec.CS_Status__c == 'Completed')
            {
                ecs.Sales_TH_Approved_DT__c = ec.Sales_TH_Approved_DT__c;
                // ecs.PDF_Generated_Date_Time__c = DateTime.now();
                // ecs.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            }
            else 
            {         
                ecs.CS_Status__c = 'Pending Sales';
                ecs.RecordTypeId = pendingRecordTypeId;
                // ecs.PDF_Generated_Date_Time__c = DateTime.now();
                // ecs.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            }
            
            System.debug('before:'+ecs.PDF_Generated_Date_Time__c);
            upsert ecs;*/

            // ec.PDF_Generated_Date_Time__c = DateTime.now();
            ec.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            if( ec.CS_Status__c == 'Completed')
            {
                ec.Sales_TH_Approved_DT__c = ec.Sales_TH_Approved_DT__c;
                ec.PDF_Generated_Date_Time__c = ec.Sale_Submit_Date_Time__c;
                // ecs.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            }
            else 
            {         
                ec.CS_Status__c = 'Pending Sales';
                ec.RecordTypeId = pendingRecordTypeId;
                ec.PDF_Generated_Date_Time__c = DateTime.now();
                // ecs.PDF_Generated_by__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');
            }

            update ec;

            // System.debug('after:'+ecs.PDF_Generated_Date_Time__c);

            // E_Client_Suitability__c new_ec =  [SELECT Id, OwnerId, Name, 
            //             CS_RM_TH_Approved_Date_Tme__c, CS_Sales_TH_Approved_Date_Time__c,Sales_TH_Approved_DT__c,PDF_Generated_Date_Time__c
            //             FROM E_Client_Suitability__c
            //             WHERE Id =: ecs.Id
            //             ];
            //         System.debug('newec:'+new_ec);
            //         System.debug('new:'+new_ec.PDF_Generated_Date_Time__c);
            
            
            //createPDFfile(eclientId,fileName);
            

        }
        catch (Exception e){
            system.debug( e.getMessage() + ' (' + e.getLineNumber()  +')' );
            throw new AuraHandledException( e.getMessage() + ' (' + e.getLineNumber()  +')' );
        }
    }

    @AuraEnabled
	public static void createPDFfile(String eclientId)
	{
         E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, 
                        CS_Customer__r.TMB_Customer_ID_PE__c,CS_RM__r.Name,CS_Sales_Owner__r.Name, CS_Status__c, 
                        LastModifiedBy.Name, CreatedDate, LastModifiedDate,
                        CS_RM_TH_Approved_Date_Tme__c, CS_Sales_TH_Approved_Date_Time__c,Sales_TH_Approved_DT__c,PDF_Generated_Date_Time__c
                        FROM E_Client_Suitability__c
                        WHERE Id =: eclientId
                        ];

        String createdDate = ec.CreatedDate.format('YYYYMMdd');
        String rm15digit = ec.CS_Customer__r.TMB_Customer_ID_PE__c.right(15);

        String fileName = createdDate+'_'+rm15digit+'.pdf';

        // List<Attachment> attmtList = [SELECT Id,ParentId FROM Attachment
                            // WHERE ParentId =: eclientId
                            // AND name =:fileName
                            // ];  
        // System.debug('attmtList:'+attmtList);
        // if( attmtList.size() > 0 )
        // {      
            // delete attmtList;
        // }
        // System.debug('attmtList11:'+attmtList);
		//Attachment importattachmentfileAll = new Attachment();
		//importattachmentfileAll.parentId = eclientId;
		//importattachmentfileAll.name = fileName;       
		//PageReference refMain = new PageReference('/apex/CSGeneratePDFMain');
		//refMain.getParameters().put('id', eclientId);
		//// importattachmentfileAll.IsPrivate = true;
		//if(!Test.isRunningTest()){
		//    importattachmentfileAll.body = refMain.getContentAsPdf();
		//    insert importattachmentfileAll;
		//}
		
        List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId = :eclientId AND ContentDocument.Title = :fileName
                                        ];
        if (contentDocumentList.size() > 0) {
            delete contentDocumentList;
        }
		
		ContentVersion cv = new ContentVersion();
		cv.ContentLocation = 'S'; //S - Salesforce
		cv.PathOnClient = fileName;
		cv.Origin = 'H'; //H - Chatter
        //cv.firstPublishLocationId= ec.OwnerId;
		//cv.OwnerId = ec.OwnerId;
		cv.Title = fileName;
		PageReference refMain = new PageReference('/apex/CSGeneratePDFMain');
        refMain.getParameters().put('id', eclientId);
        System.debug('Test insert ContentVersion');
		if(!Test.isRunningTest()){
            cv.VersionData = refMain.getContentAsPdf();
            System.debug('CV Result:' +cv);
            insert cv;
			
			// [cv] should have [Id] after [insert] command
			ContentVersion insertedCv = [SELECT Id, OwnerId, ContentDocumentId
                        FROM ContentVersion
                        WHERE Id =: cv.Id];
            
            ContentDocumentLink autoInsertCl = [SELECT Id, LinkedEntityId, ContentDocumentId
                        FROM ContentDocumentLink
                        WHERE ContentDocumentId =: insertedCv.ContentDocumentId];
                
			//ContentDocumentLink cl = new ContentDocumentLink();
            //cl.LinkedEntityId = eclientId;
            //cl.ContentDocumentId = insertedCv.ContentDocumentId;
            //cl.ShareType = 'V';
			//insert cl;
			
            ContentDocumentLink clonedCl = autoInsertCl.clone();
            clonedCl.ShareType = 'V';
            clonedCl.LinkedEntityId = eclientId;
            insert clonedCl;
            delete autoInsertCl;
        }
		
		
		
    }

    // To be deleted
  //      List<Attachment> attList = new List<Attachment>();

		//Attachment importattachmentfile = new Attachment();
  //      importattachmentfile.parentId = eclientId;
  //      importattachmentfile.name = 'Cover.pdf';        
  //      PageReference refCover = Page.CSSurveyCoverPagePDF;
  //      refCover.getParameters().put('id', eclientId);
  //      importattachmentfile.IsPrivate = true;
  //      importattachmentfile.body = refCover.getContentAsPdf();
  //      attList.add(importattachmentfile);
        
  //      Attachment importattachmentfileA = new Attachment();
  //      importattachmentfileA.parentId = eclientId;
  //      importattachmentfileA.name = 'FormA.pdf';
  //      PageReference A = Page.CSSurveyFormAPDF;
  //      A.getParameters().put('id', ec.CS_Customer_Survey_A__c);
  //      importattachmentfileA.IsPrivate = true;
  //      importattachmentfileA.body = A.getContentAsPdf();
  //      attList.add(importattachmentfileA);

  //      Attachment importattachmentfileB = new Attachment();
  //      importattachmentfileB.parentId = eclientId;
  //      importattachmentfileB.name = 'FormB.pdf';
  //      PageReference B = Page.CSSurveyFormBPDF;
  //      B.getParameters().put('id', ec.CS_Customer_Survey_B__c);
  //      importattachmentfileB.IsPrivate = true;
  //      importattachmentfileB.body = B.getContentAsPdf();
  //      attList.add(importattachmentfileB);
  //      insert attList;

        //system.debug(importattachmentfile);

	

   
}