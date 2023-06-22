global with sharing class RemoteVFClass{
   private static Blob smartQueue;
    private static Blob ivKey;

    private static String ACCOUNT_SF_ID = 'ACCOUNT_SF_ID';
    private static String LEAD_SF_ID = 'LEAD_SF_ID';
    private static String GLOBAL_SEARCH_VAL = 'GLOBAL_SEARCH_VAL';
    private static String GLOBAL_SEARCH_OBJ = 'GLOBAL_SEARCH_OBJ';


   static {
        AppConfig__c mc = AppConfig__c.getValues('ForSmartQ');
        string key = (mc == null ? 'fortestsmartqfortestsmartqfortes' : mc.Value__c);
        smartQueue = Blob.valueOf(key);

        AppConfig__c mc2 = AppConfig__c.getValues('ForSmartQIV');
        string key2 = (mc2 == null ? 'ivkeytestforsmar' : mc2.Value__c);
        ivKey = Blob.valueOf(key2);
    }



    @RemoteAction
    global static String getAccountById(String encpData) {
        String rmid = decryptText(encpData);
        
        if (rmid != null && rmid.length() > 0) {
            List<Account> accList = [SELECT Id  FROM 
                                        Account WHERE
                                         TMB_Customer_ID_PE__c = : rmid 
                                    LIMIT 1];

            if (accList != null && accList.size() > 0) {
                Account acc = accList.get(0);
                return acc.Id;
            }
        }
        

        return null;
    }

    private static Map<String,String> getKeyValueForOldVersion(String encpData) {
        String rmid = decryptText(encpData);
        DateTime startDatetime = DateTime.now();

        if (rmid != null && rmid.length() > 0) {
            Map<String,String> mapValue = new Map<String,String>();

            if (isRMIDValid(rmid)) {
                List<Account> accList = [SELECT 
                                             Id  
                                                ,Name 
                                                ,TMB_Customer_ID_PE__c
                                                ,Core_Banking_Suggested_Segment__c  
                                        FROM 
                                        Account WHERE
                                         TMB_Customer_ID_PE__c = : rmid LIMIT 1];

                if (accList != null && accList.size() > 0) {
                    Account acc = accList.get(0);
                    mapValue.put(ACCOUNT_SF_ID,acc.Id);
                    RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,null
                                                ,null
                                                ,null
                                                ,true
                                                );

                    return mapValue;
                }else {
                    //case no rmid found
                    RTL_Utility.InsertSmartQueueLog(
                                            null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.NO_FOUND
                                            ,null
                                            ,null
                                            ,null
                                            ,false
                                            );
                    mapValue.put(GLOBAL_SEARCH_VAL,rmid);
                    return mapValue;
                }
            }else {
                //Phone Number query
                mapValue.put(GLOBAL_SEARCH_VAL,rmid);
                List<Account> accList = querySOSLAccount(rmid);

                if (accList != null && accList.size() == 1) {
                    Account acc = accList.get(0);

                    if (acc != null && acc.TMB_Customer_ID_PE__c != null && acc.TMB_Customer_ID_PE__c.length() > 0) {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,null
                                                ,null
                                                ,null
                                                ,true
                                                );
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_PROSPECT
                                                ,null
                                                ,null
                                                ,null
                                                ,true
                                                );
                    }

                    mapValue.put(ACCOUNT_SF_ID,accList.get(0).Id);
                }else if (accList != null && accList.size() > 1)  {
                    RTL_Utility.InsertSmartQueueLog(
                                            null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_ACCOUNT
                                            ,null
                                            ,null
                                            ,null
                                            ,true
                                            );

                    mapValue.put(GLOBAL_SEARCH_OBJ,'001');
                }else {
                    List<Lead> leadList = querySOSLLead(rmid);

                    if (leadList != null && leadList.size() == 1) {
                        RTL_Utility.InsertSmartQueueLog(
                                            null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.FOUND_AS_LEAD
                                            ,null
                                            ,null
                                            ,null
                                            ,true
                                            );

                        mapValue.put(LEAD_SF_ID,leadList.get(0).Id);
                    }else if (leadList != null && leadList.size() > 1)  {
                        RTL_Utility.InsertSmartQueueLog(
                                            null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.FOUND_MULTIPLE_ON_LEAD
                                            ,null
                                            ,null
                                            ,null
                                            ,true
                                            );

                        mapValue.put(GLOBAL_SEARCH_OBJ,'00Q');
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                            null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.NO_FOUND
                                            ,null
                                            ,null
                                            ,null
                                            ,false
                                            );
                    }
                }

                return mapValue;
            }
            
        }
        return null;
    }

    @RemoteAction
    global static Map<String,String> getKeyValueForNewVersion(String encTMBID
                                                ,String encPhoneNo
                                                ,String queueNo
                                                ,String branchCode) {
        

        DateTime startDatetime = DateTime.now();
        
        try {
            if (encPhoneNo != null && encPhoneNo.length() > 0 
                && queueNo != null && queueNo.length() > 0 
                && branchCode != null && branchCode.length() > 0) {

                String tmbCustId = decryptText(encTMBID);
                Map<String,String> mapValue = new Map<String,String>();
                
                if (tmbCustId != null && tmbCustId.length() > 0) {
                    if (isRMIDValid(tmbCustId)) {
                        List<Account> accList = [SELECT Id  
                                                    ,Name 
                                                    ,TMB_Customer_ID_PE__c
                                                    ,Core_Banking_Suggested_Segment__c
                                                FROM 
                                                Account WHERE
                                                 TMB_Customer_ID_PE__c = : tmbCustId 
                                                 LIMIT 1];

                        if (accList != null && accList.size() > 0) {
                            Account acc = accList.get(0);
                            mapValue.put(ACCOUNT_SF_ID,acc.Id);

                            RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );

                            return mapValue;
                        }
                    }
                }

                String mobileNo  = decryptText(encPhoneNo);

                mapValue.put(GLOBAL_SEARCH_VAL,mobileNo);
                List<Account> accList = querySOSLAccount(mobileNo);

                if (accList != null && accList.size() == 1) {
                    Account acc = accList.get(0);
                    if (acc != null && acc.TMB_Customer_ID_PE__c != null && acc.TMB_Customer_ID_PE__c.length() > 0) {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_PROSPECT
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    }
                    mapValue.put(ACCOUNT_SF_ID,acc.Id);
                }else if (accList != null && accList.size() > 1)  {
                    RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_MULTIPLE_ON_ACCOUNT
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    mapValue.put(GLOBAL_SEARCH_OBJ,'001');
                }else {
                    List<Lead> leadList = querySOSLLead(mobileNo);

                    if (leadList != null && leadList.size() == 1) {
                        RTL_Utility.InsertSmartQueueLog(
                                                leadList.get(0).Name
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_LEAD
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                        mapValue.put(LEAD_SF_ID,leadList.get(0).Id);
                    }else if (leadList != null && leadList.size() > 1)  {
                        RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_MULTIPLE_ON_LEAD
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                        mapValue.put(GLOBAL_SEARCH_OBJ,'00Q');
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.NO_FOUND
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,false
                                                );
                    }
                }
                return mapValue;
            }else {
                //first version.
                return getKeyValueForOldVersion(encTMBID);
            } 
        }catch(Exception e) {
            RTL_Utility.InsertSmartQueueLog(null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.NO_FOUND
                                            ,queueNo
                                            ,branchCode
                                            ,e.getMessage()
                                            ,false
                                            );
            return null;
        }
    }

    @AuraEnabled
    global static Object getKeyValueForNewVersionLightning(String encTMBID
                                                ,String encPhoneNo
                                                ,String queueNo
                                                ,String branchCode) {
        

        DateTime startDatetime = DateTime.now();
        
        try {
            if (encPhoneNo != null && encPhoneNo.length() > 0 
                && queueNo != null && queueNo.length() > 0 
                && branchCode != null && branchCode.length() > 0) {

                String tmbCustId = decryptText(encTMBID);
                Map<String,String> mapValue = new Map<String,String>();
                
                if (tmbCustId != null && tmbCustId.length() > 0) {
                    if (isRMIDValid(tmbCustId)) {
                        List<Account> accList = [SELECT Id  
                                                    ,Name 
                                                    ,TMB_Customer_ID_PE__c
                                                    ,Core_Banking_Suggested_Segment__c
                                                FROM 
                                                Account WHERE
                                                 TMB_Customer_ID_PE__c = : tmbCustId 
                                                 LIMIT 1];

                        if (accList != null && accList.size() > 0) {
                            Account acc = accList.get(0);
                            mapValue.put(ACCOUNT_SF_ID,acc.Id);

                            RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );

                            return mapValue;
                        }
                    }
                }

                String mobileNo  = decryptText(encPhoneNo);

                mapValue.put(GLOBAL_SEARCH_VAL,mobileNo);
                List<Account> accList = querySOSLAccount(mobileNo);

                if (accList != null && accList.size() == 1) {
                    Account acc = accList.get(0);
                    if (acc != null && acc.TMB_Customer_ID_PE__c != null && acc.TMB_Customer_ID_PE__c.length() > 0) {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_CUSTOMER
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                                acc.Name 
                                                ,acc.TMB_Customer_ID_PE__c
                                                ,UserInfo.getName()
                                                ,acc.Core_Banking_Suggested_Segment__c
                                                ,acc.Id
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_PROSPECT
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    }
                    mapValue.put(ACCOUNT_SF_ID,acc.Id);
                }else if (accList != null && accList.size() > 1)  {
                    RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_MULTIPLE_ON_ACCOUNT
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                    mapValue.put(GLOBAL_SEARCH_OBJ,'001');
                }else {
                    List<Lead> leadList = querySOSLLead(mobileNo);

                    if (leadList != null && leadList.size() == 1) {
                        RTL_Utility.InsertSmartQueueLog(
                                                leadList.get(0).Name
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_AS_LEAD
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                        mapValue.put(LEAD_SF_ID,leadList.get(0).Id);
                    }else if (leadList != null && leadList.size() > 1)  {
                        RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.FOUND_MULTIPLE_ON_LEAD
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,true
                                                );
                        mapValue.put(GLOBAL_SEARCH_OBJ,'00Q');
                    }else {
                        RTL_Utility.InsertSmartQueueLog(
                                                null
                                                ,null
                                                ,UserInfo.getName()
                                                ,null
                                                ,null
                                                ,startDatetime
                                                ,RTL_Utility.NO_FOUND
                                                ,queueNo
                                                ,branchCode
                                                ,null
                                                ,false
                                                );
                    }
                }
                return mapValue;
            }else {
                //first version.
                return getKeyValueForOldVersion(encTMBID);
            } 
        }catch(Exception e) {
            RTL_Utility.InsertSmartQueueLog(null
                                            ,null
                                            ,UserInfo.getName()
                                            ,null
                                            ,null
                                            ,startDatetime
                                            ,RTL_Utility.NO_FOUND
                                            ,queueNo
                                            ,branchCode
                                            ,e.getMessage()
                                            ,false
                                            );
            return null;
        }
    }

    private static List<Account> querySOSLAccount(String phoneValue) {
        String searchquery= 'FIND {'+phoneValue+'} IN PHONE FIELDS RETURNING Account (Id,Name,TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c)';
        List<List<Account>> listofAccList = search.query(searchquery);
        return listofAccList.get(0);
    }

    private static List<Lead> querySOSLLead(String phoneValue) {
        String searchquery= 'FIND {'+phoneValue+'} IN PHONE FIELDS RETURNING Lead (Id,Name)';
        List<List<Lead>> listofLeadList = search.query(searchquery);
        return listofLeadList.get(0);
    }

    private static Boolean isRMIDValid(String rmIdValue) {
        //Valid RMID must be startwith 0011 and length is 30
        if (rmIdValue.startsWith('0011') && rmIdValue.length() == 30) {
            //valid RMID 
            return true;
        }
        return false;
    }

    
    public static String encyptText(String plainText) {
        Blob cipherText = Crypto.encrypt('AES256'
                                        ,smartQueue
                                        ,ivKey
                                        ,Blob.valueOf(plainText));

        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        return encodedCipherText;
    }

    public static String decryptText(String encodedCipherText) {
        if (String.isBlank(encodedCipherText)) return null;

        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob decryptedBlob = Crypto.decrypt('AES256'
                                            ,smartQueue
                                            , ivKey
                                            ,encodedEncryptedBlob);

        String decryptedClearText = decryptedBlob.toString();
        return decryptedClearText;
    }

    @RemoteAction
    global static List<ContentDocument>  searchDocuments(String textSearch) {
        if (textSearch != null & textSearch.length() > 0) {
            String criteriaQry = '%'+textSearch+'%';
            return [SELECT FileExtension,Id,Title FROM ContentDocument WHERE Title LIKE : criteriaQry LIMIT 50 ];
        }else {
            return [SELECT FileExtension,Id,Title FROM ContentDocument LIMIT 50 ];
        }
        
    }


    @RemoteAction
    global static List<ContentDocument> searchSOSLDocuments(String textSearch) {
        String searchquery= 'FIND {*'+textSearch+'*} IN ALL FIELDS RETURNING ContentDocument (Id,Title,FileExtension )';
        List<List<ContentDocument>> listofConList = search.query(searchquery);

        if (listofConList != null && listofConList.size() > 0) {
            List<ContentDocument> conlist  = listofConList.get(0);
            List<ContentDocument> conlist2 = searchDocuments(textSearch);
            conlist.addAll(conlist2);
            return conlist;
        }else {
            return searchDocuments(textSearch);
        }
    }
    
    /*
    @RemoteAction
    global static String sendFiles(String fileList
                                   ,String subject
                                   ,String body
                                   ,String templateID
                                   ,String emailList) {
        return ReportExportToEmailUtil.sendFiles(fileList,subject,body,templateID,emailList);
    }*/

}