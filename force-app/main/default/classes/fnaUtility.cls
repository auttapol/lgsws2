public without sharing class fnaUtility {
    public class ResponseOSC{
       @AuraEnabled
       public String accountNumber {get;set;}
       @AuraEnabled
       public String accountStatus {get;set;}
       @AuraEnabled
       public String accountTitle {get;set;}
        @AuraEnabled
       public String accountType {get;set;}
        @AuraEnabled
       public String openDate {get;set;}
        @AuraEnabled
       public String productCode {get;set;}
   }

 
    public static string getprojectFin() {

        List<Project__c> finProject = [SELECT Id, Name, Description__c FROM Project__c WHERE name = 'Fin Avatar' Limit  1];
        if(finProject.size() > 0){
            return finProject[0].Id;
        }
        return '';
    }
 
    public static Map<String, String> getImageUrl(Map<String, String> titleImage){

        List<ContentVersion> cvsList = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE Title in :titleImage.values() AND IsLatest = true ORDER BY Title, versionNumber ASC];

        Map<String, String> b64 = new Map<String, String>();
        for(String keyTiltle : titleImage.keySet()){
            for(ContentVersion cvs : cvsList){
                if(cvs.title == titleImage.get(keyTiltle)){
                    b64.put(keyTiltle, 'data:image/png;base64, ' + EncodingUtil.base64Encode(cvs.VersionData));
                    // b64.put(keyTiltle, '/fin/sfc/servlet.shepherd/version/download/' + cvs.Id);
                }
            }
        }
        
        return b64;

    }

    public static List<ContentVersion> getListContentVersion(String libraryName, String folderName, String titleName ){
        List<ContentVersion> contentList = new List<ContentVersion>();
        List<ContentFolderItem> folderList =	[SELECT Id, IsDeleted, IsFolder, ParentContentFolderId, Title  
                                                 FROM ContentFolderItem WHERE Title = :folderName 
                                                 AND ParentContentFolderId in (SELECT RootContentFolderId FROM ContentWorkspace WHERE Name = :libraryName) 
                                                 AND IsFolder = TRUE];
        if(folderList.size()>0){

            Id folderId = folderList.get(0).Id;
            
            Set<Id> contentIdInFolderList = new Set<Id>();
            map<id,ContentFolderItem> contentInFolderMap = new map<id,ContentFolderItem>([SELECT Id 
                                                            FROM ContentFolderItem 
                                                            WHERE ParentContentFolderId =:folderId
                                                            AND Title =:titleName]);
            
            contentIdInFolderList.addAll(contentInFolderMap.KeySet());

            contentList = [SELECT Id, Title, VersionData, ContentDocumentId, ContentSize 
                                            FROM ContentVersion 
                                            WHERE IsLatest = TRUE 
                                            AND ContentDocumentId in :contentIdInFolderList]; 

        }
        return contentList;
	}

    private static SMSServiceHandler smsService {get;set;}

    public static void sendSMS(FNA_Activity__c fnaForm, String serviceName){
        //smsService = new SMSServiceHandler(serviceName,'Send_SMS_Details__c'); //'SMS_link_URL'
        callSMSService(serviceName, (SObject)fnaForm, fnaForm.id, fnaForm.Send_SMS_Details__c, fnaForm.phone__c);
    }

    public static void callSMSService(String serviceName, SObject sobj, String sobjId, String sobjStatus, String sobjPhone){
        smsService = new SMSServiceHandler(serviceName,'Send_SMS_Details__c'); //'SMS_link_URL'
        string status = sobjStatus;

        if (status != null && status.length() > 0) {
			Map<String,Map<String,String>> statusMap 
							= (Map<String,Map<String,String>>)
							JSON.deserialize(status, Map<String,Map<String,String>>.class);
            List<String> statusList = new List<String>();
            statusList.addAll(statusMap.keySet());
            if(statusList.size() > 0){
                status = statusList[0];
            }            
        }else{
            status = 'New';
        }
        
        Map<String,Map<ID,String>> recordTemplateMap = new Map<String,Map<ID,String>>(); // <Status,<CaseID,SMSCode>>
        Map<Sobject,String> mapError = new Map<Sobject,String>();

        Map<Id,String> IdErrorMap = new Map<Id,String>();
        String smsServiceStatus = smsService.getEnableToSentSMS(sobj,status,false);
        System.debug(smsServiceStatus);
        if(smsServiceStatus == smsService.SMS_SERVICE_UNAVAILABLE){
            //SMS service not available
            mapError.put(sobj,Label.Case_ERR025);
            IdErrorMap.put(sobj.Id,Label.Case_ERR025); ///SMS service not available.
            
        }else if(smsServiceStatus == smsService.SMS_SENT_SUCESS){
            //เคสนี้ส่ง SMS ไปแล้ว ไม่สามารถส่งซ้ำได้
            mapError.put(sobj,Label.Case_ERR010);
            IdErrorMap.put(sobj.Id,Label.Case_ERR010); ///This case already sent SMS.
            
        }else if(smsServiceStatus != smsService.SMS_IN_PROCESS){
            
            String smsCode = '';
            List<App_Config__mdt> tempName = [SELECT Id, DeveloperName, Value__c FROM App_Config__mdt WHERE DeveloperName =:serviceName Limit 1];
            if(tempName.size() > 0 ){
                smsCode = tempName[0].Value__c;
            }
            system.debug('SMS Template : ' + smsCode);
            
            System.debug('smsCode ' + smsCode);
            if(smsServiceStatus == smsService.NOT_ALLOWED_TO_SMS ||
                sobjPhone == null){
                //เคสนี้ไม่สามารถส่ง SMS
                mapError.put(sobj,Label.Case_ERR009);
                IdErrorMap.put(sobj.Id,Label.Case_ERR009); //This case not allow to send SMS or mobile format not correct.
                
            }else{ 
                if(recordTemplateMap.containsKey(status)){
                    recordTemplateMap.get(status).put(sobjId, smsCode);
                }else{
                    recordTemplateMap.put(status,new Map<ID,String>());
                    recordTemplateMap.get(status).put(sobjId, smsCode);
                } 
            }  
        }

        if(recordTemplateMap.size() > 0){           
            system.debug('recordTemplateMap : ' + recordTemplateMap);
            smsService.sendSMS(recordTemplateMap); 
        }
     
        if(mapError.size() > 0){
            String errorMessage = '';
            for(String err: mapError.values()){
                errorMessage +=  err;
            }
            system.debug('Error : ' + errorMessage);
        } 

        smsService.endCall();

    }

    @AuraEnabled
    public static void sendSMSURL(String fnaId){
        System.debug('FNAID ' + fnaId);
        fnaId = UrlHelper.decryptParams(fnaId);
        System.debug('FNAID ' + fnaId);
        FNA_Activity__c sobj = [Select Id, Phone__c, SMS_Sponsor__c, Send_SMS_Details__c, passportUrl__c FROM FNA_Activity__c WHERE id =: fnaid LIMIT 1];
        String serviceName = 'SMS_Link_URL';
        fnaUtility.sendSMS(sobj, serviceName);
    }

    public static string meargeSmallAvatarTitle(String segment, String gender ){
        if (gender == 'ชาย'){
            gender ='_male_small';
        }else {
            gender ='_female_small';
        }

        return segment + gender;
    }    

    public static SObject functionCheckExisting(String mobileNumber){
        system.debug('CheckAccountExisting mobileNumber : ' + mobileNumber);
        List<List<SObject>> searchList = [FIND :mobileNumber IN ALL FIELDS 
                            RETURNING Account(Id, Name, LastModifiedDate order by LastModifiedDate desc)];
        //, Lead(Id, Name, LastModifiedDate order by LastModifiedDate desc)
        if(searchList.size() > 0){
            List<SObject> accList = searchList[0];
            if(accList.size() > 0){
                for(SObject sObj : accList){
                     system.debug('accList : ' + sObj);
                }
                return accList[0];
            }
        }

        return null;
    }

    public static final Id LEAD_RETAIL_BANKING_RECORDTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
    public static final String SME_SEGMENT = 'SME';
    // public static final Id LEAD_COMMERCIAL_RECORDTYPE = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
    // public static final String BRANCH = 'BRANCH';
    // public static final String RMC = 'RMC';
    

    public static void createLead(FNA_Activity__c fnaObj, Id recordTypeLead, RTL_Referral__c ref, List<FNA_Product_Offering__c> prodOfferList){
        system.debug('Function Create Lead : ');
        system.debug('fnaObj : ' + fnaObj);
        system.debug('recordTypeLead : ' + recordTypeLead);
        system.debug('ref : ' + ref);
        system.debug('prodOfferList : ' + prodOfferList);
        Lead newLead = new Lead();
            newLead.firstname = fnaObj.Person_Name__c;
            newLead.lastname = '(ไม่ระบุ)';
            newLead.Fna_Avatar_Name__c = fnaObj.Avatar_Name__c;
            newLead.Fna_Create_Date__c = fnaObj.CreatedDate;
            newLead.FNA_Activity__c = fnaObj.id;
            newLead.RecordTypeId = recordTypeLead;
            newLead.RTL_isAllowedToUpdate__c = true;
            newLead.Fna_Avatar_Url__c = getAvatarImage(fnaObj);
            system.debug('fnaObj.Product_Holding__c : ' + fnaObj.Product_Holding__c);
            newLead.Fna_Product_Holding__c = fnaObj.Product_Holding__c;
            system.debug('newLead.Fna_Product_Holding__c : ' + newLead.Fna_Product_Holding__c);
            system.debug('ref.id : ' + ref.id);

            if(ref.id != null){ 
                 
                //PROBLEM WITH CREATE REF WHILE TIMEOUT
                newLead.RTL_Referral__c = ref.id;
                system.debug('newLead.RTL_Referral__c : ' + newLead.RTL_Referral__c);
                // if(ref.Assigned_Pool__c == BRANCH || ref.Assigned_Pool__c == RMC){
                System.debug('ref.OwnerId ' + ref.OwnerId);
                newLead.OwnerId = ref.OwnerId;  
                // }
                system.debug('prodOfferList : ' + prodOfferList);  
                if(prodOfferList.size() > 0){
                   Map<String, String> productOfferingMap = new Map<String, String>();
                   productOfferingMap = splitProductOffering(prodOfferList);
                   system.debug('Interestd splitProductOffering : ' + productOfferingMap.get('Interestd'));
                    system.debug('HighlightHolding splitProductOffering : ' + productOfferingMap.get('HighlightHolding'));
                   newLead.Fna_Product_Interested__c = productOfferingMap.get('Interestd');
                   newLead.Fna_Product_Holding__c = productOfferingMap.get('HighlightHolding');
                }
            }
           
            // if(recordTypeLead == LEAD_COMMERCIAL_RECORDTYPE){
            //     newLead.Customer_Type__c = 'Individual';
            //     newLead.Company = fnaObj.Person_Name__c;
            //     newLead.Mobile_No__c = fnaObj.Phone__c;
            //     newLead.LeadSource = 'Refer from Digital Channel';
            //     newLead.Status = 'Open';

            // }else{
                newLead.Status = 'New';
                newLead.RTL_Mobile_Number__c = fnaObj.Phone__c;
                newLead.LeadSource = 'Others';
            // }
            
        insert newLead;

        system.debug('newLead : ' + newLead.id);
        // return newLead.id;
    }

    public static Map<String,String> splitProductOffering(List<FNA_Product_Offering__c> prodOfferList){
        system.debug('Splitproduct Offering : ');
        Map<String, String> productOfferingMap = new Map<String, String>();
        String productHighlightHolding = ''; 
        String productInterset = '';
        for(FNA_Product_Offering__c prodOffer : prodOfferList){
            system.debug('Splitproduct Offering : ' + prodOffer);
            if(prodOffer.Flag_Interested_Product__c){
                if(productInterset == '' || productInterset == null){
                    productInterset = prodOffer.FNA_Product_Name__r.Product__r.Name;
                }else{
                    productInterset += ',' + prodOffer.FNA_Product_Name__r.Product__r.Name;
                }
                system.debug('productInterset : ' + productInterset);
            }

            if(prodOffer.Flag_Highlight__c && !prodOffer.Flag_Offset_product_holding__c){
                if(productHighlightHolding == '' || productHighlightHolding == null){
                    productHighlightHolding = prodOffer.FNA_Product_Name__r.Product__r.Name;
                }else{
                    productHighlightHolding += ',' + prodOffer.FNA_Product_Name__r.Product__r.Name;
                }
                system.debug('productHighlightHolding : ' + productHighlightHolding);
            }
        }
        system.debug('productInterset : ' + productInterset);
        system.debug('productHighlightHolding : ' + productHighlightHolding);
        productOfferingMap.put('Interestd', productInterset);
        productOfferingMap.put('HighlightHolding', productHighlightHolding);
        return productOfferingMap;

    }

    public static FNA_Activity__c stampFieldExisting(FNA_Activity__c fna, SObject sobj){
        
        if(sObj != null){
            if(sObj.id.getSObjectType() == Account.sObjectType){
                fna.Customer__c = sObj.id;
                Account acc = new Account();
                acc.id = sObj.id;
                acc.Fna_Avatar_Name__c = fna.Avatar_Name__c;
                acc.Fna_Avatar_Url__c = getAvatarImage(fna);
                acc.Fna_Create_Date__c = fna.CreatedDate;
                acc.Fna_Have_Referral__c = false;
                acc.Fna_Product_Holding__c = fna.Product_Holding__c;
                acc.Fna_Product_Interested__c = '';
                update acc;

            }
        }else if(fna.Avatar_Master__r.Avatar_Segment__c != SME_SEGMENT){

            createLead(fna, LEAD_RETAIL_BANKING_RECORDTYPE, new RTL_Referral__c(), new List<FNA_Product_Offering__c>());

            /*if(fna.Avatar_Master__r.Avatar_Segment__c == SME_SEGMENT){
                
                createLead(fna, LEAD_COMMERCIAL_RECORDTYPE, new RTL_Referral__c(), new List<FNA_Product_Offering__c>());
            }else{
                
                createLead(fna, LEAD_RETAIL_BANKING_RECORDTYPE, new RTL_Referral__c(), new List<FNA_Product_Offering__c>());
            }*/
        }

        return fna;
    }

    public static void updateProductofLead(String fnaId){
        List<Lead> leadList = new List<Lead>();
        FNA_Activity__c fnaObj = [SELECT Id, Product_Interested__c, Product_Holding__c,
                                (SELECT id, name, FNA_Activity__c, RTL_Referral__c FROM Leads__r)
                                FROM FNA_Activity__c WHERE id =: fnaId];
        
        if(fnaObj.Leads__r.size() > 0){
            leadList.addall(fnaObj.Leads__r);
        }

        for(Lead leadObj : leadList){
            system.debug('Lead list : ' + leadObj);
            leadObj.RTL_isAllowedToUpdate__c = true;
            leadObj.Fna_Product_Holding__c = fnaObj.Product_Holding__c;
            leadObj.Fna_Product_Interested__c = fnaObj.Product_Interested__c;
        }

        if(leadList.size() > 0){
            upsert leadList;
        }
    }

    @AuraEnabled
    public static void FnaCheckExisting(String fnaId){
        fnaId = UrlHelper.decryptParams(fnaId);
        FNA_Activity__c fnaForm = [SELECT Id, Avatar_Name__c, Avatar_Downloaded__c, Phone__c, Person_Name__c, Avatar_Master__r.Avatar_Segment__c, 
                                            Avatar_Master__r.Segment__c, Customer__c, CreatedDate, Product_Holding__c,
                                            (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                            (SELECT id, name, FNA_Activity__c FROM Leads__r)
                                            FROM FNA_Activity__c WHERE id =: fnaId];

        if(fnaForm.Customer__c == null && fnaForm.Leads__r.size() == 0){  
            fnaForm = stampFieldExisting(fnaForm, functionCheckExisting(fnaForm.Phone__c));
        }
        
        update fnaForm;
    }

    @AuraEnabled
    public static void FnaCheckExistingNonEncrypt(String fnaId){
        FNA_Activity__c fnaForm = [SELECT Id, Avatar_Name__c, Avatar_Downloaded__c, Phone__c, Person_Name__c, Avatar_Master__r.Avatar_Segment__c, 
                                            Avatar_Master__r.Segment__c, Customer__c, CreatedDate, Product_Holding__c,
                                            (SELECT id, Answer__c, FNA_Activity_Name__c, Question_ID__c, Question_ID__r.Name FROM Questionnaire_Results__r WHERE Question_ID__r.Name ='Q13'),
                                            (SELECT id, name, FNA_Activity__c FROM Leads__r)
                                            FROM FNA_Activity__c WHERE id =: fnaId];

        if(fnaForm.Customer__c == null && fnaForm.Leads__r.size() == 0){  
            fnaForm = stampFieldExisting(fnaForm, functionCheckExisting(fnaForm.Phone__c));
        }
        
        update fnaForm;
    }


    @AuraEnabled
    public static void successDownload(String fnaId){
        fnaId = UrlHelper.decryptParams(fnaId);
        FNA_Activity__c fnaForm = [SELECT Id, name FROM FNA_Activity__c WHERE id =: fnaId];
        fnaForm.Avatar_Downloaded__c = true;
        update fnaForm;
    }
    
    public static String checkBusinessHour (String businessName, Datetime targetTime){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name =: businessName];
        String nextStart = BusinessHours.nextStartDate(bh.id, targetTime).addHours(7).formatGMT('YYYY-MM-dd HH:mm');
        system.debug('nextStart' + nextStart);
        return nextStart;
    }

    public static Boolean checkBusinessHourTF (String businessName, Datetime targetTime){
        BusinessHours bh = new BusinessHours();
        Boolean isWithin = false;
        try {
        	bh = [SELECT Id FROM BusinessHours WHERE name =: businessName];
            isWithin = BusinessHours.isWithin(bh.id, targetTime);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        system.debug('isWithin' + isWithin);
        return isWithin;
    }

    @AuraEnabled
    public static string checkCustomerId(String cusId, String branchCode, String branchAgentId){
        // String cusName, String mobileNo,
        // System.debug('cusName : ' + cusName);
        // System.debug('mobileNo : ' + mobileNo); 
        System.debug('cusId : ' + cusId);
        System.debug('branchCode : ' + branchCode);
        System.debug('branchAgentId : ' + branchAgentId);
        //TMB_Customer_ID_PE__c
        List<Account> acc = [SELECT id, name, Mobile_Number_PE__c FROM Account WHERE id=: cusId];
        if(acc.size() > 0){
            FNA_Activity__c fna = new FNA_Activity__c();
                fna.Customer__c = acc[0].id;
                fna.Person_Name__c = acc[0].name;
                fna.Phone__c = acc[0].Mobile_Number_PE__c;
                fna.Branch__c = branchCode;
                fna.Created_Branch_Code__c = branchCode;
                fna.Agent__c = branchAgentId;
            insert fna;
            return UrlHelper.encryptParams(fna.id);
            //return fna.id;
        }
        return null;       
    }
    
    public static List<ContentVersion> getListContentVersionAll(String libraryName, String folderName, List<String> titleName ){
            system.debug('libraryName = '+libraryName);
            system.debug('folderName = '+folderName);
            system.debug('titleName = '+titleName);
            List<ContentVersion> contentList = new List<ContentVersion>();
            List<ContentFolderItem> folderList =	[SELECT Id, IsDeleted, IsFolder, ParentContentFolderId, Title  
                                                     FROM ContentFolderItem WHERE Title = :folderName 
                                                     AND ParentContentFolderId in (SELECT RootContentFolderId FROM ContentWorkspace WHERE Name = :libraryName) 
                                                     AND IsFolder = TRUE];
            if(folderList.size()>0){
                Id folderId = folderList.get(0).Id;
                system.debug('folderId = '+folderId);
                
                Set<Id> contentIdInFolderList = new Set<Id>();
                // map<id,List<ContentFolderItem>> contentInFolderMap = new map<id,List<ContentFolderItem>>([SELECT Id 
                //                                                 FROM ContentFolderItem 
                //                                                 WHERE ParentContentFolderId =:folderId
                //                                              	AND Title IN :titleName]);

                List<ContentFolderItem> ContentFolderItemIdList = [SELECT Id, ParentContentFolderId
                                                FROM ContentFolderItem 
                                                WHERE ParentContentFolderId =:folderId
                                                AND Title IN :titleName];

                system.debug('ContentFolderItemIdList = '+ContentFolderItemIdList);

                List<Id> ContentFolderId = new List<Id>();
                                            
                for(ContentFolderItem ContentFolderItemIdObj : ContentFolderItemIdList){
                system.debug('ContentFolderItemIdObj = '+ContentFolderItemIdObj);
                    contentIdInFolderList.add(ContentFolderItemIdObj.Id);
                }


                
                // contentIdInFolderList.addAll(contentInFolderMap.KeySet());
                
                
                /*List<ContentFolderItem> contentInFolderList =	[SELECT Id 
                                                                FROM ContentFolderItem 
                                                                WHERE ParentContentFolderId =:folderId
                                                             	AND Title = :titleName ];
                
                for(ContentFolderItem con : contentInFolderList){
                    contentIdInFolderList.add(con.Id);
                }*/
                contentList = [SELECT Id, Title, VersionData, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE IsLatest = TRUE 
                                                AND ContentDocumentId IN :contentIdInFolderList]; 
                system.debug('contentList>>>>='+contentList);
                for(ContentVersion cvs : contentList){
                	system.debug('cvs.Title='+cvs.Title);
                	system.debug('cvs.VersionData='+cvs.VersionData);
                	system.debug('cvs.ContentDocumentId='+cvs.ContentDocumentId);
               		system.debug('cvs.Id='+cvs.Id);
               }
            }
            return contentList;
	}

    public static string getAvatarImage (FNA_Activity__c fnaObj){
        String imageUrl, gender, segment = '';
        segment = fnaObj.Avatar_Master__r.Segment__c;

        for(Questionnaire_Result__c result : fnaObj.Questionnaire_Results__r){
            System.debug('result :'+ result);
            if(result.Question_ID__r.Name == 'Q13'){
                gender = result.answer__c;
            }
        }

        if (gender=='ชาย'){
            gender ='_male';
        }else {
            gender ='_female';
        }
        
        if(segment.containsIgnoreCase('Default') ){
            segment = 'Default';
        }
        

        String avatartitle = segment + gender;

        system.debug('Avatar Title' + avatartitle);

        List<ContentVersion> cvs = [SELECT Id, Title, VersionData, versionNumber, ContentDocumentId FROM ContentVersion where Title = :avatartitle AND IsLatest = true ORDER BY Title, versionNumber DESC];
        if(cvs.size() > 0){
            imageUrl = cvs[0].id;
        }
        return imageUrl;
    }



    public static Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }
    //SERVICE OSC14,16
    public static String stampOffSetProductHoldingOSC14(String fnaActivityId, CaseAccountProduct response){
        system.debug('STAMP| fnaActivityId : '+ fnaActivityId);

        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 

        Integer countCheckResponse = 0;

        if(response != null){
            if(response.accounts.deposits != null){
                for(CaseAccountProduct.Deposits oscDepositsObj : response.accounts.deposits){
                    RTLProductMasterDTO objCustomerRTLProductDeposits;
                    objCustomerRTLProductDeposits = OnlyProductWithProductCode.get(oscDepositsObj.ProductCode);
                    if(objCustomerRTLProductDeposits != null){
                        // listCustomerRTLProduct.add(objCustomerRTLProductDeposits);
                        // listSFProductFromRTLProd.add(objCustomerRTLProductDeposits.SFProductKey);
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductDeposits.SFProductKey,objCustomerRTLProductDeposits);
                        system.debug('FOUND RTL PRODUCT DEPOSITS : '+ objCustomerRTLProductDeposits);
                    }
                }
                countCheckResponse++;
            }
            if(response.accounts.loans != null){
                for(CaseAccountProduct.Loans oscLoansObj : response.accounts.loans){
                    RTLProductMasterDTO objCustomerRTLProductLoans;
                    objCustomerRTLProductLoans = OnlyProductWithProductCode.get(oscLoansObj.ProductCode);
                    if(objCustomerRTLProductLoans != null){
                        // listCustomerRTLProduct.add(objCustomerRTLProductLoans);
                        // listSFProductFromRTLProd.add(objCustomerRTLProductLoans.SFProductKey);
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductLoans.SFProductKey,objCustomerRTLProductLoans);
                        system.debug('FOUND RTL PRODUCT LOANS : '+ objCustomerRTLProductLoans);
                    }
                }
                countCheckResponse++;
            }

            if(countCheckResponse == 0){
                system.debug('OSC14| PRODUCT OFFSET NOT EXIST');
                return 'OSC14| PRODUCT OFFSET NOT EXIST';
            }
        }
        else{
            system.debug('OSC14| NOT FOUND RESPONSE FROM SERVICE OS14');
            return 'OSC14| NOT FOUND RESPONSE FROM SERVICE OS14';
        }

        system.debug('OSC14| prodSFKeyToRTLProd2 : '+ prodSFKeyToRTLProd2);        

        Integer countFindProd = 0;
        List<FNA_Product_Offering__c> listProdOffset = new List<FNA_Product_Offering__c>();

        system.debug('OSC14| fnaActivityId : '+ fnaActivityId);

        List<FNA_Product_Offering__c> listProdOffer = [SELECT Id, FNA_Product_Name__r.Product__r.FNA_Product_Code__c, FNA_Product_Name__r.Product__r.Product_Code__c, FNA_Product_Name__r.Product__r.FNA_Product_Group_TH__c, FNA_Product_Name__r.Product__r.FNA_Active__c, FNA_Product_Name__r.Product__r.Name, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId];
        system.debug('OSC14| listProdOffer : '+ listProdOffer);

        if(!listProdOffer.isEmpty()){
            for(FNA_Product_Offering__c ObjProdOffer : listProdOffer){
                system.debug('OSC14| ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c : ' + ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);                  
                RTLProductMasterDTO objRTLProd2;
                objRTLProd2 = prodSFKeyToRTLProd2.get(ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);
                if(objRTLProd2 != null){
                    system.debug('OSC14| FOUND stampProductOffset : ' + objRTLProd2);                  
                    ObjProdOffer.Flag_Offset_product_holding__c = true;
                    listProdOffset.add(ObjProdOffer);
                    countFindProd++;
                }
            }
            update listProdOffset;
        }
        else{
            system.debug('OSC14| NOT FOUND FNA_ACTIVITY_ID');
            return 'OSC14| NOT FOUND FNA_ACTIVITY_ID';
        }
        system.debug('OSC14| listProdOffset : ' + listProdOffset); 

        // List<FNA_Product_Offering__c> listProdHolding = new List<FNA_Product_Offering__c>();

        List<FNA_Activity__c> listFnaActivity = [SELECT Id, Product_Holding__c, Customer__c, Customer__r.Fna_Product_Holding__c FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        if(!listFnaActivity.isEmpty()){
            system.debug('OSC14| List of stamp product holding ALL : '+ listFnaActivity[0]);
            String fnaProductOffer = '';
            String customerProductOffer ='';
            for(FNA_Product_Offering__c objProdHolding : listProdOffer){
                if(objProdHolding.Flag_Highlight__c == true && objProdHolding.Flag_Offset_product_holding__c == false){
                    system.debug('OSC14| objProdHolding.FNA_Product_Name__r.Product__r.Name : '+ objProdHolding.FNA_Product_Name__r.Product__r.Name);
                    if(fnaProductOffer == ''){
                        fnaProductOffer = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }else{
                        fnaProductOffer += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }

                    if(customerProductOffer == ''){
                        customerProductOffer = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        customerProductOffer += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                }
            }

            system.debug('OSC14| FNA Product_Holding__c  : '+ fnaProductOffer );
            system.debug('OSC14| Customer Fna_Product_Holding__c  : '+ customerProductOffer );
            
            if(fnaProductOffer != ''){
                listFnaActivity[0].Product_Holding__c = fnaProductOffer;
                update listFnaActivity;
            }
            
            if(customerProductOffer != ''){
                Account acc = new Account();
                acc.id = listFnaActivity[0].Customer__c;
                acc.Fna_Product_Holding__c = customerProductOffer;
                update acc;
            }
        }

        if(countFindProd > 0){
            return 'OSC14| UPDATE FLAG PRODUCT OFFSET HOLDER COMPLETE';
        }
        else{
            return 'OSC14| PRODUCT OFFSET HAS NOT EXIST';
        }
    }

    public static String stampOffSetProductHoldingOSC16(String fnaActivityId, CaseBAProduct response){
        system.debug('STAMP| fnaActivityId : '+ fnaActivityId);

        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 

        if(response != null){
            if(response.bancassurances != null){
                for(CaseBAProduct.Bancassurances oscBancassurancesObj : response.bancassurances){
                    RTLProductMasterDTO objCustomerRTLProductBancassurances;
                    objCustomerRTLProductBancassurances = OnlyProductWithProductCode.get(oscBancassurancesObj.insureType);
                    if(objCustomerRTLProductBancassurances != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductBancassurances.SFProductKey,objCustomerRTLProductBancassurances);
                        system.debug('FOUND RTL PRODUCT BANCASSURANCES : '+ objCustomerRTLProductBancassurances);
                    }
                }
            }
            else{
                system.debug('OSC16| PRODUCT OFFSET NOT EXIST');
                return 'OSC16| PRODUCT OFFSET NOT EXIST';
            }
        }
        else{
            system.debug('OSC16| NOT FOUND RESPONSE FROM SERVICE OS16');
            return 'OSC16| NOT FOUND RESPONSE FROM SERVICE OS16';
        }
        system.debug('OSC16| prodSFKeyToRTLProd2 : '+ prodSFKeyToRTLProd2);        

        Integer countFindProd = 0;
        List<FNA_Product_Offering__c> listProdOffset = new List<FNA_Product_Offering__c>();

        system.debug('OSC16| fnaActivityId : '+ fnaActivityId);

        List<FNA_Product_Offering__c> listProdOffer = [SELECT Id, FNA_Product_Name__r.Product__r.Name, FNA_Product_Name__r.Product__r.FNA_Product_Code__c, FNA_Product_Name__r.Product__r.Product_Code__c, FNA_Product_Name__r.Product__r.FNA_Product_Group_TH__c, FNA_Product_Name__r.Product__r.FNA_Active__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId];
        system.debug('OSC16| listProdOffer : '+ listProdOffer);

        if(!listProdOffer.isEmpty()){
            for(FNA_Product_Offering__c ObjProdOffer : listProdOffer){
                system.debug('OSC16| ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c : ' + ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);                  
                RTLProductMasterDTO objRTLProd2;
                objRTLProd2 = prodSFKeyToRTLProd2.get(ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);
                if(objRTLProd2 != null){
                    system.debug('OSC16| FOUND stampProductOffset : ' + objRTLProd2);                  
                    ObjProdOffer.Flag_Offset_product_holding__c = true;
                    listProdOffset.add(ObjProdOffer);
                    countFindProd++;
                }
            }
            update listProdOffset;
        }
        else{
            system.debug('OSC16| NOT FOUND FNA_ACTIVITY_ID');
            return 'OSC16| NOT FOUND FNA_ACTIVITY_ID';
        }
        system.debug('OSC16| listProdOffset : ' + listProdOffset);      

        List<FNA_Activity__c> listFnaActivity = [SELECT Id, Product_Holding__c, Customer__c, Customer__r.Fna_Product_Holding__c FROM FNA_Activity__c WHERE Id =: fnaActivityId];

        if(!listFnaActivity.isEmpty()){
            system.debug('OSC16| List of stamp product holding ALL : '+ listFnaActivity[0]);
            String fnaProductHolding = '';
            String customerProductHolding = '';
            for(FNA_Product_Offering__c objProdHolding : listProdOffer){
                if(objProdHolding.Flag_Highlight__c == true && objProdHolding.Flag_Offset_product_holding__c == false){
                    system.debug('OSC16| objProdHolding : '+ objProdHolding.FNA_Product_Name__r.Product__r.Name);
                    if(fnaProductHolding == ''){
                        fnaProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        fnaProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }

                    if(customerProductHolding == ''){
                        customerProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        customerProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                }
            }
            
            system.debug('OSC16| FNA Product_Holding__c  : '+ fnaProductHolding );
            system.debug('OSC16| Customer Fna_Product_Holding__c  : '+ customerProductHolding );
            
            if(fnaProductHolding != ''){
                listFnaActivity[0].Product_Holding__c = fnaProductHolding;
                update listFnaActivity;
            }
            
            if(customerProductHolding != ''){
                Account acc = new Account();
                acc.id = listFnaActivity[0].Customer__c;
                acc.Fna_Product_Holding__c = customerProductHolding;
                update acc;
            }
        }            

        if(countFindProd > 0){
            return 'OSC16| UPDATE FLAG PRODUCT OFFSET HOLDER COMPLETE';
        }
        else{
            return 'OSC16| PRODUCT OFFSET HAS NOT EXIST';
        }
    }

    public static String stampOffSetProductHoldingOSC01(String fnaActivityId, CustomerAccountResponse response){
        system.debug('STAMP| fnaActivityId : '+ fnaActivityId);

        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 

        Integer countCheckResponse = 0;

        if(response != null){
            if(response.GetCustomerAccountResponse.DepositAccounts != null && response.GetCustomerAccountResponse.DepositAccounts.DepositAccount != null){
                List<CustomerAccountResponse.DepositAccount> depositAccountList = response.GetCustomerAccountResponse.DepositAccounts.DepositAccount;
                for(CustomerAccountResponse.DepositAccount oscDepositsObj : depositAccountList){
                    RTLProductMasterDTO objCustomerRTLProductDeposits;
                    objCustomerRTLProductDeposits = OnlyProductWithProductCode.get(oscDepositsObj.ProductCode);
                    if(objCustomerRTLProductDeposits != null){
                        // listCustomerRTLProduct.add(objCustomerRTLProductDeposits);
                        // listSFProductFromRTLProd.add(objCustomerRTLProductDeposits.SFProductKey);
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductDeposits.SFProductKey,objCustomerRTLProductDeposits);
                        system.debug('FOUND RTL PRODUCT DEPOSITS : '+ objCustomerRTLProductDeposits);
                    }
                }
                countCheckResponse++;
            }
            if(response.GetCustomerAccountResponse.LoanAccounts != null && response.GetCustomerAccountResponse.LoanAccounts.LoanAccount != null){
                List<CustomerAccountResponse.LoanAccount> loanAccountList = response.GetCustomerAccountResponse.LoanAccounts.LoanAccount;
                for(CustomerAccountResponse.LoanAccount oscLoansObj : loanAccountList){
                    RTLProductMasterDTO objCustomerRTLProductLoans;
                    objCustomerRTLProductLoans = OnlyProductWithProductCode.get(oscLoansObj.ProductCode);
                    if(objCustomerRTLProductLoans != null){
                        // listCustomerRTLProduct.add(objCustomerRTLProductLoans);
                        // listSFProductFromRTLProd.add(objCustomerRTLProductLoans.SFProductKey);
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductLoans.SFProductKey,objCustomerRTLProductLoans);
                        system.debug('FOUND RTL PRODUCT LOANS : '+ objCustomerRTLProductLoans);
                    }
                }
                countCheckResponse++;
            }

            if(countCheckResponse == 0){
                system.debug('OSC01| PRODUCT OFFSET NOT EXIST');
                return 'OSC01| PRODUCT OFFSET NOT EXIST';
            }
        }
        else{
            system.debug('OSC01| NOT FOUND RESPONSE FROM SERVICE OSC01');
            return 'OSC01| NOT FOUND RESPONSE FROM SERVICE OSC01';
        }

        system.debug('OSC01| prodSFKeyToRTLProd2 : '+ prodSFKeyToRTLProd2);        

        Integer countFindProd = 0;
        List<FNA_Product_Offering__c> listProdOffset = new List<FNA_Product_Offering__c>();

        system.debug('OSC01| fnaActivityId : '+ fnaActivityId);

        List<FNA_Product_Offering__c> listProdOffer = [SELECT Id, FNA_Product_Name__r.Product__r.FNA_Product_Code__c, FNA_Product_Name__r.Product__r.Product_Code__c, FNA_Product_Name__r.Product__r.FNA_Product_Group_TH__c, FNA_Product_Name__r.Product__r.FNA_Active__c, FNA_Product_Name__r.Product__r.Name, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId];
        system.debug('OSC01| listProdOffer : '+ listProdOffer);

        if(!listProdOffer.isEmpty()){
            for(FNA_Product_Offering__c ObjProdOffer : listProdOffer){
                system.debug('OSC01| ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c : ' + ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);                  
                RTLProductMasterDTO objRTLProd2;
                objRTLProd2 = prodSFKeyToRTLProd2.get(ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);
                if(objRTLProd2 != null){
                    system.debug('OSC01| FOUND stampProductOffset : ' + objRTLProd2);                  
                    ObjProdOffer.Flag_Offset_product_holding__c = true;
                    listProdOffset.add(ObjProdOffer);
                    countFindProd++;
                }
            }
            update listProdOffset;
        }
        else{
            system.debug('OSC01| NOT FOUND FNA_ACTIVITY_ID');
            return 'OSC01| NOT FOUND FNA_ACTIVITY_ID';
        }
        system.debug('OSC01| listProdOffset : ' + listProdOffset); 

        // List<FNA_Product_Offering__c> listProdHolding = new List<FNA_Product_Offering__c>();

        List<FNA_Activity__c> listFnaActivity = [SELECT Id, Product_Holding__c, Customer__c, Customer__r.Fna_Product_Holding__c FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        if(!listFnaActivity.isEmpty()){
            system.debug('OSC01| List of stamp product holding ALL : '+ listFnaActivity[0]);
            String fnaProductOffer = '';
            String customerProductOffer ='';
            for(FNA_Product_Offering__c objProdHolding : listProdOffer){
                if(objProdHolding.Flag_Highlight__c == true && objProdHolding.Flag_Offset_product_holding__c == false){
                    system.debug('OSC01| objProdHolding.FNA_Product_Name__r.Product__r.Name : '+ objProdHolding.FNA_Product_Name__r.Product__r.Name);
                    if(fnaProductOffer == ''){
                        fnaProductOffer = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }else{
                        fnaProductOffer += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }

                    if(customerProductOffer == ''){
                        customerProductOffer = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        customerProductOffer += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                }
            }

            system.debug('OSC01| FNA Product_Holding__c  : '+ fnaProductOffer );
            system.debug('OSC01| Customer Fna_Product_Holding__c  : '+ customerProductOffer );
            
            if(fnaProductOffer != ''){
                listFnaActivity[0].Product_Holding__c = fnaProductOffer;
                update listFnaActivity;
            }
            
            if(customerProductOffer != ''){
                Account acc = new Account();
                acc.id = listFnaActivity[0].Customer__c;
                acc.Fna_Product_Holding__c = customerProductOffer;
                update acc;
            }
        }

        if(countFindProd > 0){
            return 'OSC01| UPDATE FLAG PRODUCT OFFSET HOLDER COMPLETE';
        }
        else{
            return 'OSC01| PRODUCT OFFSET HAS NOT EXIST';
        }
    }

    public static String stampOffSetProductHoldingOSC05(String fnaActivityId, BancassuranceResponse response){
        system.debug('STAMP| fnaActivityId : '+ fnaActivityId);

        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 

        if(response != null){
            if(response.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse != null &&
                response.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult != null &&
                response.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets != null){
                List<BancassuranceResponse.DataSets> insurancePolicyList = response.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets;
                for(BancassuranceResponse.DataSets oscBancassurancesObj : insurancePolicyList){
                    RTLProductMasterDTO objCustomerRTLProductBancassurances;
                    objCustomerRTLProductBancassurances = OnlyProductWithProductCode.get(oscBancassurancesObj.INSURE_TYPE);
                    if(objCustomerRTLProductBancassurances != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductBancassurances.SFProductKey,objCustomerRTLProductBancassurances);
                        system.debug('FOUND RTL PRODUCT BANCASSURANCES : '+ objCustomerRTLProductBancassurances);
                    }
                }
            }
            else{
                system.debug('OSC05| PRODUCT OFFSET NOT EXIST');
                return 'OSC05| PRODUCT OFFSET NOT EXIST';
            }
        }
        else{
            system.debug('OSC05| NOT FOUND RESPONSE FROM SERVICE OSC05');
            return 'OSC05| NOT FOUND RESPONSE FROM SERVICE OSC05';
        }
        system.debug('OSC05| prodSFKeyToRTLProd2 : '+ prodSFKeyToRTLProd2);        

        Integer countFindProd = 0;
        List<FNA_Product_Offering__c> listProdOffset = new List<FNA_Product_Offering__c>();

        system.debug('OSC05| fnaActivityId : '+ fnaActivityId);

        List<FNA_Product_Offering__c> listProdOffer = [SELECT Id, FNA_Product_Name__r.Product__r.Name, FNA_Product_Name__r.Product__r.FNA_Product_Code__c, FNA_Product_Name__r.Product__r.Product_Code__c, FNA_Product_Name__r.Product__r.FNA_Product_Group_TH__c, FNA_Product_Name__r.Product__r.FNA_Active__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId];
        system.debug('OSC05| listProdOffer : '+ listProdOffer);

        if(!listProdOffer.isEmpty()){
            for(FNA_Product_Offering__c ObjProdOffer : listProdOffer){
                system.debug('OSC05| ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c : ' + ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);                  
                RTLProductMasterDTO objRTLProd2;
                objRTLProd2 = prodSFKeyToRTLProd2.get(ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);
                if(objRTLProd2 != null){
                    system.debug('OSC05| FOUND stampProductOffset : ' + objRTLProd2);                  
                    ObjProdOffer.Flag_Offset_product_holding__c = true;
                    listProdOffset.add(ObjProdOffer);
                    countFindProd++;
                }
            }
            update listProdOffset;
        }
        else{
            system.debug('OSC05| NOT FOUND FNA_ACTIVITY_ID');
            return 'OSC05| NOT FOUND FNA_ACTIVITY_ID';
        }
        system.debug('OSC05| listProdOffset : ' + listProdOffset);      

        List<FNA_Activity__c> listFnaActivity = [SELECT Id, Product_Holding__c, Customer__c, Customer__r.Fna_Product_Holding__c FROM FNA_Activity__c WHERE Id =: fnaActivityId];

        if(!listFnaActivity.isEmpty()){
            system.debug('OSC05| List of stamp product holding ALL : '+ listFnaActivity[0]);
            String fnaProductHolding = '';
            String customerProductHolding = '';
            for(FNA_Product_Offering__c objProdHolding : listProdOffer){
                if(objProdHolding.Flag_Highlight__c == true && objProdHolding.Flag_Offset_product_holding__c == false){
                    system.debug('OSC05| objProdHolding : '+ objProdHolding.FNA_Product_Name__r.Product__r.Name);
                    if(fnaProductHolding == ''){
                        fnaProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        fnaProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }

                    if(customerProductHolding == ''){
                        customerProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        customerProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                }
            }
            
            system.debug('OSC05| FNA Product_Holding__c  : '+ fnaProductHolding );
            system.debug('OSC05| Customer Fna_Product_Holding__c  : '+ customerProductHolding );
            
            if(fnaProductHolding != ''){
                listFnaActivity[0].Product_Holding__c = fnaProductHolding;
                update listFnaActivity;
            }
            
            if(customerProductHolding != ''){
                Account acc = new Account();
                acc.id = listFnaActivity[0].Customer__c;
                acc.Fna_Product_Holding__c = customerProductHolding;
                update acc;
            }
        }            

        if(countFindProd > 0){
            return 'OSC05| UPDATE FLAG PRODUCT OFFSET HOLDER COMPLETE';
        }
        else{
            return 'OSC05| PRODUCT OFFSET HAS NOT EXIST';
        }
    }

    // Service: get-cards-balance
    public static String stampOffSetProductHoldingGetCardsBalance(String fnaActivityId, String response){
        system.debug('STAMP| fnaActivityId : '+ fnaActivityId);
    
        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
    
        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 
    
        if(response != null){
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            List<Object> creditCards = (List<Object>)result.get('credit_card');
            if(creditCards.size() > 0) {
                for (Object creditCard : creditCards) {
                    Map<String,Object> data = (Map<String,Object>)creditCard;
                    String creditCardProctId = (String)data.get('product_id');
                    RTLProductMasterDTO objCustomerRTLProductCreditCard;
                    objCustomerRTLProductCreditCard = OnlyProductWithProductCode.get(creditCardProctId);
                    if(objCustomerRTLProductCreditCard != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductCreditCard.SFProductKey,objCustomerRTLProductCreditCard);
                        system.debug('FOUND RTL PRODUCT CREDITCARD : '+ objCustomerRTLProductCreditCard);
                    }
                }
            }
            else{
                system.debug('GET-CARDS-BALANCE| PRODUCT OFFSET NOT EXIST');
                return 'GET-CARDS-BALANCE| PRODUCT OFFSET NOT EXIST';
            }
        }
        else{
            system.debug('GET-CARDS-BALANCE| NOT FOUND RESPONSE FROM SERVICE GET-CARDS-BALANCE');
            return 'GET-CARDS-BALANCE| NOT FOUND RESPONSE FROM SERVICE GET-CARDS-BALANCE';
        }
        system.debug('GET-CARDS-BALANCE| prodSFKeyToRTLProd2 : '+ prodSFKeyToRTLProd2);        
    
        Integer countFindProd = 0;
        List<FNA_Product_Offering__c> listProdOffset = new List<FNA_Product_Offering__c>();
    
        system.debug('GET-CARDS-BALANCE| fnaActivityId : '+ fnaActivityId);
    
        List<FNA_Product_Offering__c> listProdOffer = [SELECT Id, FNA_Product_Name__r.Product__r.Name, FNA_Product_Name__r.Product__r.FNA_Product_Code__c, FNA_Product_Name__r.Product__r.Product_Code__c, FNA_Product_Name__r.Product__r.FNA_Product_Group_TH__c, FNA_Product_Name__r.Product__r.FNA_Active__c, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId];
        system.debug('GET-CARDS-BALANCE| listProdOffer : '+ listProdOffer);
    
        if(!listProdOffer.isEmpty()){
            for(FNA_Product_Offering__c ObjProdOffer : listProdOffer){
                system.debug('GET-CARDS-BALANCE| ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c : ' + ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);                  
                RTLProductMasterDTO objRTLProd2;
                objRTLProd2 = prodSFKeyToRTLProd2.get(ObjProdOffer.FNA_Product_Name__r.Product__r.Product_Code__c);
                if(objRTLProd2 != null){
                    system.debug('GET-CARDS-BALANCE| FOUND stampProductOffset : ' + objRTLProd2);                  
                    ObjProdOffer.Flag_Offset_product_holding__c = true;
                    listProdOffset.add(ObjProdOffer);
                    countFindProd++;
                }
            }
            update listProdOffset;
        }
        else{
            system.debug('GET-CARDS-BALANCE| NOT FOUND FNA_ACTIVITY_ID');
            return 'GET-CARDS-BALANCE| NOT FOUND FNA_ACTIVITY_ID';
        }
        system.debug('GET-CARDS-BALANCE| listProdOffset : ' + listProdOffset);      
    
        List<FNA_Activity__c> listFnaActivity = [SELECT Id, Product_Holding__c, Customer__c, Customer__r.Fna_Product_Holding__c FROM FNA_Activity__c WHERE Id =: fnaActivityId];
    
        if(!listFnaActivity.isEmpty()){
            system.debug('GET-CARDS-BALANCE| List of stamp product holding ALL : '+ listFnaActivity[0]);
            String fnaProductHolding = '';
            String customerProductHolding = '';
            for(FNA_Product_Offering__c objProdHolding : listProdOffer){
                if(objProdHolding.Flag_Highlight__c == true && objProdHolding.Flag_Offset_product_holding__c == false){
                    system.debug('GET-CARDS-BALANCE| objProdHolding : '+ objProdHolding.FNA_Product_Name__r.Product__r.Name);
                    if(fnaProductHolding == ''){
                        fnaProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        fnaProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
    
                    if(customerProductHolding == ''){
                        customerProductHolding = objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                    else{
                        customerProductHolding += ',' + objProdHolding.FNA_Product_Name__r.Product__r.Name;
                    }
                }
            }
            
            system.debug('GET-CARDS-BALANCE| FNA Product_Holding__c  : '+ fnaProductHolding );
            system.debug('GET-CARDS-BALANCE| Customer Fna_Product_Holding__c  : '+ customerProductHolding );
            
            if(fnaProductHolding != ''){
                listFnaActivity[0].Product_Holding__c = fnaProductHolding;
                update listFnaActivity;
            }
            
            if(customerProductHolding != ''){
                Account acc = new Account();
                acc.id = listFnaActivity[0].Customer__c;
                acc.Fna_Product_Holding__c = customerProductHolding;
                update acc;
            }
        }            
    
        if(countFindProd > 0){
            return 'GET-CARDS-BALANCE| UPDATE FLAG PRODUCT OFFSET HOLDER COMPLETE';
        }
        else{
            return 'GET-CARDS-BALANCE| PRODUCT OFFSET HAS NOT EXIST';
        }
    }

    public static Map<String,RTLProductMasterDTO> splitResProductHoldingOSC14(CaseAccountProduct response){

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 
        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
        
        if(response != null){
            
            if(response.accounts.creditCards != null){
                for(CaseAccountProduct.Deposits oscCreditCardObj : response.accounts.creditCards){
                    String creditCardConditionCRE = oscCreditCardObj.productCode + 'CRE';
                    RTLProductMasterDTO objCustomerRTLProductCreditCard = OnlyProductWithProductCode.get(creditCardConditionCRE);

                    if(objCustomerRTLProductCreditCard != null){
                        
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductCreditCard.SFProductKey, objCustomerRTLProductCreditCard);
                        system.debug('FOUND RTL PRODUCT CREDITCARD : '+ objCustomerRTLProductCreditCard);
                    }
                }
            }
            if(response.accounts.deposits != null){
                for(CaseAccountProduct.Deposits oscDepositsObj : response.accounts.deposits){
                    RTLProductMasterDTO objCustomerRTLProductDeposits = OnlyProductWithProductCode.get(oscDepositsObj.productCode);

                    if(objCustomerRTLProductDeposits != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductDeposits.SFProductKey, objCustomerRTLProductDeposits);
                        system.debug('FOUND RTL PRODUCT DEPOSITS : '+ objCustomerRTLProductDeposits);
                    }
                }
            }
            if(response.accounts.loans != null){
                for(CaseAccountProduct.Loans oscLoansObj : response.accounts.loans){
                    RTLProductMasterDTO objCustomerRTLProductLoans = OnlyProductWithProductCode.get(oscLoansObj.productCode);

                    if(objCustomerRTLProductLoans != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductLoans.SFProductKey, objCustomerRTLProductLoans);
                        system.debug('FOUND RTL PRODUCT LOANS : '+ objCustomerRTLProductLoans);
                    }
                }
            }
        }

        return prodSFKeyToRTLProd2;

    }

    public static Map<String,RTLProductMasterDTO> splitResProductHoldingOSC16(CaseBAProduct response){

        Map<String,RTLProductMasterDTO> prodSFKeyToRTLProd2 = new Map<String,RTLProductMasterDTO>(); 
        OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        if(response != null){
            if(response.bancassurances != null){
                for(CaseBAProduct.Bancassurances oscBancassurancesObj : response.bancassurances){
                    RTLProductMasterDTO objCustomerRTLProductBancassurances = OnlyProductWithProductCode.get(oscBancassurancesObj.insureType);

                    if(objCustomerRTLProductBancassurances != null){
                        prodSFKeyToRTLProd2.put(objCustomerRTLProductBancassurances.SFProductKey,objCustomerRTLProductBancassurances);
                        system.debug('FOUND RTL PRODUCT BANCASSURANCES : '+ objCustomerRTLProductBancassurances);
                    }
                }
            }
        }

        return prodSFKeyToRTLProd2;
    }

    @AuraEnabled
    public static String encryptParams(String FNAId){
        FNAId = UrlHelper.encryptParams(FNAId);
        return FNAId;
    }

    @AuraEnabled
    public static String decryptParams(String FNAId){
        FNAId = UrlHelper.decryptParams(FNAId);
        return FNAId;
    }

    @AuraEnabled
    public static OTP__c fnGenerateOTP (String fnaId){
        fnaId = UrlHelper.decryptParams(fnaId);
        return fnaGenerateOTPCtrl.fnGenerateOTP(fnaId);
    }

    @AuraEnabled
    public static Integer fnVerifyOTP(string fnaId, string otpCode){
        fnaId = UrlHelper.decryptParams(fnaId);
        return fnaGenerateOTPCtrl.fnVerifyOTP(fnaId,otpCode);
    }
}