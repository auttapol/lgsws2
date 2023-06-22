public with sharing class RetailCSVLightningUtil {

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResultAndValue(String recordId, List<String> fields, List<String> fields_translate) {
        String queryString = 'SELECT ' + String.join(fields, ',') + ' FROM Account WHERE Id = :recordId LIMIT 1';
        for (string fieldTranslate : fields_translate) {
            queryString = queryString.replace( fieldTranslate, 'toLabel('+fieldTranslate+')');
        }
        Account AccountObj = Database.query(queryString);
        Map<String, Schema.SObjectField> sObjectField = Schema.SObjectType.Account.fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            if(!f.contains('__r')) {
                Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => dfr.getName(),
                    'value' => AccountObj.get(dfr.getName()) != null ? AccountObj.get(dfr.getName()) : '',
                    'label' => dfr.getLabel(),
                    'type' => dfr.getType(),
                    'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                    'isAccessible' => dfr.isAccessible()
                });
            }
            else {
                Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(AccountObj));
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => f,
                    'value' => AccountObj.get(f.substringBefore('.').replace('__r', '__c')) != null ? ((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : null
                });
            }
        }
        Object returnData =  SecurityScan.applySecurityMatrix( (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldDescribe)), recordId, fields, fields_translate );
        return returnData;
        //return JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }
    @AuraEnabled
    public static Object getVerifyByField(String field, String profileName, String recordId){
        return SecurityScan.getVerifyByField(field, profileName, recordId);
    }

    @AuraEnabled(cacheable=true)
    public static Object getReference(Id recordId)
    {
        return RTL_CSVLightningUtil.getReference(recordId);
    }
    
    @AuraEnabled
    public static Object verifyFieldSecurity(String section, String userProfile, String accountId)
    {    
        return RTL_AccountUtility.verifyFieldSecurity(section, userProfile, accountId);
    }

    @AuraEnabled(cacheable=true)
    public static Object getProfileName(Id userId)
    {    
        return [SELECT Id, Name, Profile.Name FROM User WHERE Id = :userId].Profile.Name;
    }


    @AuraEnabled(continuation=true)
    public static Object getCVSAnalyticsData(String rmId)
    {    
        return RTL_CSVLightningUtil.getCVSAnalyticsData(rmId);
    }

    @AuraEnabled
    public static Object callbackCVSAnalyticsData(List<String> labels, Object state)
    {    
        return RTL_CSVLightningUtil.callbackCVSAnalyticsData(labels, state);
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;
    }

    @AuraEnabled
    public static Object saveAssignBRC2Mainbank(String acctId)
    {    
        // CR - Mainbank Main_Bank_List_View__c
        // find Main_Bank_List_View__c
        System.debug('ID -->' + acctId);
        Account[] acct = [select Id, RTL_Assigned_BRC__c, TMB_Customer_ID_PE__c from Account where Id = :acctId];

        if(acct != null && !acct.isEmpty()) {
            String rmid = acct[0].TMB_Customer_ID_PE__c;
            System.debug('RMID -->' + rmid);
            Main_Bank_List_View__c[] mainBankListView = [select Id, Customer_ID__c, Assigned_BRC_User__c from Main_Bank_List_View__c where Customer_ID__c = :rmid];
            
            if(mainBankListView != null && !mainBankListView.isEmpty()) {
                    // account.RTL_Assigned_BRC__c --> Main_Bank_List_View__c.Assigned_BRC_User__c
                    Main_Bank_List_View__c editRecord = mainBankListView[0];
                    editRecord.Assigned_BRC_User__c = acct[0].RTL_Assigned_BRC__c;

                    System.debug('Assigned BRC User -->' + editRecord.Assigned_BRC_User__c);

                    update editRecord;
            } else {
                System.debug('Not found');
            }
        }
        return null;
    }

    @AuraEnabled
    public static Object CallCYCCampaignMappingInqAPI(String NameCredentail,Object headerParam, Object bodyParam,Object OnlineServiceLog){
        CYCCampaignMappingInqAPI CYCcampaignAPI = new CYCCampaignMappingInqAPI();
        Object result = CYCcampaignAPI.Preparedata(NameCredentail,(String)headerParam,(String) bodyParam,(String) OnlineServiceLog);
        return result;
    }

    @AuraEnabled
    public static String getSubDebtTransaction(Id accId){
        String subDebtTransDetail = '';
        String profileName = [ SELECT Name FROM profile WHERE Id = :UserInfo.getProfileId() limit 1 ].Name;
        List<Sub_Debt_Transaction__c> subDebtTran = [SELECT Id, Name,Customer__c FROM Sub_Debt_Transaction__c WHERE Customer__c =: accId];
        Object isVisible = SecurityScan.getVerifyByField('subDebtTran', profileName, accId);
        if(isVisible == true){
           subDebtTransDetail = subDebtTran.size()>0? System.Label.Sub_Debt_Transaction_Yes_Message : System.Label.Sub_Debt_Transaction_No_Message;
        }else{
           subDebtTransDetail = System.Label.Data_Condition_Hidden_Text;
        }
        return subDebtTransDetail;  
    }

    @AuraEnabled
    public static String getInstantLendingDetail(Id accId){
        String instantLendingDetail = '';
        String profileName = [ SELECT Name FROM profile WHERE Id = :UserInfo.getProfileId() limit 1 ].Name;
        System.debug('profileName : '+profileName);

        List<Retail_Instant_Lending__c> retailLending = [SELECT Id, Name, Customer__c, Instant_lending_detail__c, Expiry_Date__c FROM Retail_Instant_Lending__c WHERE Customer__c =: accId];
        Object isVisible = SecurityScan.getVerifyByField('Instant_lending_detail__c', profileName, accId);
        System.debug('isVisible : '+isVisible);
        if(isVisible == true){
            instantLendingDetail = retailLending.size()>0? retailLending[0].Instant_lending_detail__c : '';
        }else{
            instantLendingDetail = System.Label.Data_Condition_Hidden_Text;
        }
        return instantLendingDetail;

    }

    @AuraEnabled(cacheable=false)
    public static Object getDataAfterRefresh(String recordId, List<String> fields, List<String> fields_translate) {
        return EditCustomerController.getDataAfterRefresh(recordId, fields, fields_translate);
    }

    @AuraEnabled
    public static void updateCSVForBranch(Account updateFieldMap){
        try{
            update updateFieldMap;
        }catch(DmlException e) {
			throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static Map<String, String> getHobbiesValuesIntoList(){
        Map<String, String> picklistMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Hobbies__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
		return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String>  getSportValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.Favorite_Sport__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
		return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getLifeValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Lifestyle__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
		return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getOnAcValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Preferred_Activity__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getTravelValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.Favorite_Place_Travel__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getMusicValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.Favorite_Music__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getFoodValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.Favorite_Food__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getOther1ValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Other1__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getPurposeContact1ValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Purpose_for_Contact1__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getPurposeContact2ValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Purpose_of_Contact2__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getRelationContact1ValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Relationship_Contact_1__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getRelationContact2ValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Relationship_Contact_2__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getPreferContactValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Preferred_Contact_Channel__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getAlterCValuesIntoList(){
		Schema.DescribeFieldResult fieldResult = Account.RTL_Alternative_Contact_Channel__c.getDescribe();
		Map<String, String> picklistMap = new Map<String, String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  
        return picklistMap;
    }

    @AuraEnabled 
    public static String getUserLanguage(){
        String language, userLanguage = UserInfo.getLanguage();
        for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
            if(value.getValue() == userLanguage) {
                language = value.getLabel();
                break;
            }
        }
        return language;
    }

    @AuraEnabled
    public static String getSubSegmentCodeMapping(String subSegmentCode){
        // Map<String, String> subSegmentCodeMapping = new Map<String, String>();
        String subSegmentCodeDesc = '';
        if (String.isBlank(subSegmentCode)) {
            return subSegmentCodeDesc;
        }
        List<Sub_Segment_Code_Mapping__mdt> subSegmentCodeMappingList = [ SELECT Description__c, Sub_Segment_Code__c FROM Sub_Segment_Code_Mapping__mdt WHERE Sub_Segment_Code__c =: subSegmentCode ];
        
        if (subSegmentCodeMappingList.size() > 0) {
            for (Sub_Segment_Code_Mapping__mdt ss : subSegmentCodeMappingList) {
                /* if (!subSegmentCodeMapping.containsKey(ss.Sub_Segment_Code__c)) {
                    subSegmentCodeMapping.put(ss.Sub_Segment_Code__c, ss.Description__c);
                } */
                subSegmentCodeDesc = ss.Description__c;
            }
        }
        return subSegmentCodeDesc;  
    }
}