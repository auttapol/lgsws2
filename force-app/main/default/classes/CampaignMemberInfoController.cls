public without sharing class CampaignMemberInfoController {

    private static Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt> mapConfRecordType = new Map<String,RTL_NBO_Product_Record_Type_Mapping__mdt>();
    private static Map<String,RecordType> mapRecordType = new Map<String,RecordType>();

    private static Map<String, String> prefixSobjectMap {get{
        if (prefixSobjectMap == null) {
            prefixSobjectMap = new Map<String, String>();
            Map<String, Schema.SobjectType> describe = Schema.getGlobalDescribe();
            for (String s : describe.keyset()) {
                prefixSobjectMap.put(describe.get(s).getDescribe().getKeyPrefix(), s);
            }
        }
        return prefixSobjectMap;
        } set;
    }

    private static Set<ID> userIDset {get{
        if (userIDSet == null) {
            userIDset = new Set<ID>();
        }
        return userIdSet;
        } set;
    }
    
    private static Set<ID> branchIDset {get{
        if (branchIDset == null) {
            branchIDset = new Set<ID>();
        }
        return branchIDset;
        } set;
    }
    
    private static Set<ID> contactIDset {get{
        if (contactIDset == null) {
            contactIDset = new Set<ID>();
        }
        return contactIDset;
        } set;
    }

    private static Map<ID, String> userNameMap {get{
        if (userNameMap == null) {
            userNameMap = new Map<ID, String>();
        }
        return userNameMap;
        } set;
    }
  
    private static Map<ID, String> branchNameMap {get{
        if (branchNameMap == null) {
            branchNameMap = new Map<ID, String>();
        }
        return branchNameMap;
        } set;
    }
  
    private static Map<ID, String> contactNameMap {get{
        if (contactNameMap == null) {
            contactNameMap = new Map<ID, String>();
        }
        return contactNameMap;
        } set;
    }

    private static Set<String> HLCALPrdNameSet {
        get{
            if(HLCALPrdNameSet == null){
                HLCALPrdNameSet = new Set<String>();
                List<Droplead_HLCAL_screen_Product_Name__mdt> prdHLCALlst = Droplead_HLCAL_screen_Product_Name__mdt.getAll().values();

                for (Droplead_HLCAL_screen_Product_Name__mdt prd : prdHLCALlst) {
                    HLCALPrdNameSet.add(prd.Product_Name__c);
                }
            }
            return HLCALPrdNameSet;
        }
        set;
    }
    private static Set<String> ALPrdNameSet {
        get{
            if(ALPrdNameSet == null){
                ALPrdNameSet = new Set<String>();
                List<AL_screen_Product_Name__mdt> prdHLCALlst = AL_screen_Product_Name__mdt.getAll().values();

                for (AL_screen_Product_Name__mdt prd : prdHLCALlst) {
                    ALPrdNameSet.add(prd.Product_Name__c);
                }
            }
            return ALPrdNameSet;
        }
        set;
    }

    public static List<RTL_NBO_Product_Record_Type_Mapping__mdt> getConfRecordType(){
        return [SELECT Id,DeveloperName,Default_Stage__c,RTL_Product_Group__c,RTL_Record_Type_DevName__c,Stage_List__c FROM RTL_NBO_Product_Record_Type_Mapping__mdt];
    }

    public static List<RecordType> getRecordTypeOpportunity(){
        return [SELECT Id,DeveloperName,Name FROM RecordType WHERE SObjectType = 'Opportunity'];
    }

    public class CampaignProductWrapper{
        @AuraEnabled
        public Integer numberOfProduct {get;set;}
        @AuraEnabled
        public Integer rowNum {get;set;}
        @AuraEnabled
        public String productGroup {get;set;}
        @AuraEnabled
        public String productSubGroup {get;set;}
        @AuraEnabled
        public String productId {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public String offerResult {get;set;}
        @AuraEnabled
        public String offerResultLabel {get;set;}
        @AuraEnabled
        public String reason {get;set;}
        @AuraEnabled
        public String stageLabel {get;set;}
        @AuraEnabled
        public String statusLabel {get;set;}
        @AuraEnabled
        public Opportunity objOpp {get;set;}
        @AuraEnabled
        public Boolean viewGroup {get;set;}
        @AuraEnabled
        public Boolean viewSubGroup {get;set;}
        @AuraEnabled
        public Boolean viewProductName {get;set;}
        @AuraEnabled
        public Boolean viewOfferResult {get;set;}
        @AuraEnabled
        public Boolean viewReason {get;set;}
        @AuraEnabled
        public Boolean isShowHLCALMoredetail {get;set;}
        // @AuraEnabled
        // public Boolean isValidate {get;set;}

    }
    public class CampaignMemberResponseObject
    {
        @AuraEnabled
        public String campaigncode{get;set;}
        @AuraEnabled
        public String marketingcode{get;set;}
        @AuraEnabled
        public String productofferstring{get;set;}
        @AuraEnabled
        public String campaignchannel{get;set;}
        @AuraEnabled
        public String mobilenumber{get;set;}
        @AuraEnabled
        public String updatedate{get;set;}
        @AuraEnabled
        public String resultcontact{get;set;}
        @AuraEnabled
        public String agentid{get;set;}
        @AuraEnabled
        public String resultdetail{get;set;}
        @AuraEnabled
        public String resultdetailWebText{
            get{
                return replaceSpecialChar(resultdetail);
            }
            set;
        }
        @AuraEnabled
        public String offerresult{get;set;}
        @AuraEnabled
        public String reason{get;set;}
        @AuraEnabled
        public String smsmessage{get;set;}
        @AuraEnabled
        public String smsmessageWebText{
            get{
                return replaceSpecialChar(smsmessage);
            }
            set;
        }
        @AuraEnabled
        public String smscontent{get;set;}
        @AuraEnabled
        public String smscontentWebText{
            get{
                return replaceSpecialChar(smscontent);
            }
            set;
        }
        @AuraEnabled
        public String registerdateText{get;set;}
        @AuraEnabled
        public DateTime registerdate{
            get{
                return parseDateTime(registerdateText);
            }
            set;
        }
        @AuraEnabled
        public String registerdateFormatted{
            get{
                if(  parseDateTime(registerdateText)  != null)
                {
                    return parseDateTime(registerdateText).addHours(-7).format();
                }
                else
                {
                    return '';
                }
            }
            set;
        }
        @AuraEnabled
        public String displayflagText{get;set;}

        @AuraEnabled
        public String displaydateText{get;set;}
        @AuraEnabled
        public Date displaydate{
            get{
                return parseDate(displaydateText);
            }
            set;
        }
        @AuraEnabled
        public String clickflagText{get;set;}

        @AuraEnabled
        public String clickdateText{get;set;}
        @AuraEnabled
        public Date clickdate{
            get{
                return parseDate(clickdateText);
            }
            set;
        }
        @AuraEnabled
        public String emailsenddateText{get;set;}
        @AuraEnabled
        public Date emailsenddate{
            get{
                return parseDate(emailsenddateText);
            }
            set;
        }
        @AuraEnabled
        public String emailrejectdateText{get;set;}
        @AuraEnabled
        public Date emailrejectdate{
            get{
                return parseDate(emailrejectdateText);
            }
            set;
        }
        @AuraEnabled
        public String emailopenflagText{get;set;}

        @AuraEnabled
        public String emailopendateText{get;set;}
        @AuraEnabled
        public Date emailopendate{
            get{
                return parseDate(emailopendateText);
            }
            set;
        }
        @AuraEnabled
        public String emailclickflagText{get;set;}

        @AuraEnabled
        public String emailclickdateText{get;set;}
        @AuraEnabled
        public Date emailclickdate{
            get{
                return parseDate(emailclickdateText);
            }
            set;
        }
        @AuraEnabled
        public String contactsubstatus{get;set;}
        @AuraEnabled
        public String offersubresult{get;set;}
        @AuraEnabled
        public String resultbusiness{get;set;}
        @AuraEnabled
        public String resultbusinessWebText{
            get{
                return replaceSpecialChar(resultbusiness);
            }
            set;
        }
        @AuraEnabled
        public String contactdateText{get;set;}
        @AuraEnabled
        public DateTime contactdate{
            get{
                return parseDateTime(contactdateText);
            }
            set;
        }
        @AuraEnabled
        public String contactdateFormatted{
            get{
                
                    if( parseDateTime(contactdateText) != null)
                {
                        return parseDateTime(contactdateText).addHours(-7).format();
                }
                else
                {
                    return '';
                }
                
            }
            set;
        }

        private DateTime parseDateTime(String dateTimeText)
        {
            try{
                if( dateTimeText != null && dateTimeText != '' )
                {
                    return DateTime.valueOfGMT(dateTimeText.replace('T',' '));
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }

        Private Map<String,String> escapeString = new Map<String,String>{
            '\\"' => '"',
            '\\r\\n' => '<br />',
            '\\n' => '<br />'
        };

        private String replaceSpecialChar(String content)
        {

            for( String target : escapeString.keyset() )
            {
                String replacement = escapeString.get(target);

                content = content.replace(target,replacement);
            }
         
            return content;
        }
        private Date parseDate(String dateText)
        {
            try{
                if( dateText != null && dateText != '' )
                {
                    return Date.valueOf(dateText.replace('T',' '));
                }
                else
                {
                    return null;
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }
        @AuraEnabled
        public String personalizedMessage{get;set;}//phase2 new fields
        
    }

    @AuraEnabled
    public static CampaignMemberResponseObject  campaignMemberResponse {get;set;}
    

    private Integer calloutTimeoutSecond{
        get{
            if( calloutTimeoutSecond == null )
            {
                RTL_Campaign_History_Setting__mdt chMeta = [select id,CalloutTimeoutSecond__c
                from RTL_Campaign_History_Setting__mdt 
                where DeveloperName = 'Campaign_Display_Setting'];

                calloutTimeoutSecond = (Integer)chMeta.CalloutTimeoutSecond__c;
            }
            return calloutTimeoutSecond;
        }
        set;
    }

    private static String endpointInt06{
        get{
            if( endpointInt06 == null )
            {
                RTL_Campaign_Endpoint__c endpointSetting = RTL_Campaign_Endpoint__c.getValues('Campaign TO HQ INT06');
                if( endpointSetting != null )
                {
                     endpointInt06 = endpointSetting.RTL_Endpoint__c;
                }
            }
            return endpointInt06;
        }
        set;
    }
    public class moreDetailProductwrapper{
        @AuraEnabled
        public String ALProductSet;
        @AuraEnabled
        public String HLProductSet;
    }
    @AuraEnabled
    public static List<CM_OB_Sell_Permission__mdt> getCampaignMemberOBSellPermission(){
        return [SELECT Id,MasterLabel,Allow_To_Sell__c,Profile__c FROM CM_OB_Sell_Permission__mdt WHERE Profile__c =: 'Campaign Member OB'];
    }

    @AuraEnabled
    public static Campaign getCampaign(String recordId){
        try {
            CampaignMember cmObj = [SELECT Id,CampaignId FROM CampaignMember Where Id =: recordId LIMIT 1];
            

            Campaign cp = [SELECT Id, Status, IsActive FROM Campaign WHERE Id =: cmObj.CampaignId LIMIT 1];

            return cp;
        } catch (Exception e) {
            system.debug('Error:'+e);
            return null;          
        }
    }

	@AuraEnabled
    public static CampaignMember getCampaignMember(String recordId)
    {
        try {
            CampaignMember cmObj = [SELECT Id,FirstName,LastName,ContactId,Contact.Name,Contact.FirstName,Contact.LastName,Contact.Age__c,Contact.Date_of_Birth__c,Contact.Account__c, LeadId ,Lead.Name,Lead.RTL_Age__c,Lead.RTL_Income__c,Lead.RTL_Occupation__c, Lead.RTL_W2L_Loan_Request_Type__c, Lead.RTL_W2L_Source_Collateral_Type__c, RTL_Campaign_Name_TH__c, Campaign.Name,RTL_Marketing_Code__c,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,RTL_Campaign_Channel_formula__c,Customer__r.OwnerId,
            RTL_Age__c,Customer__r.RTL_Date_Of_Birth__c,RTL_Last_Contact_Status__c,RTL_Income__c, RTL_Contact_Status__c,RTL_CampHis_Phone__c,RTL_Occupation__c,RTL_Reason__c,RTL_Segmentation__c,RTL_Product_Feature__c,RTL_Promotion__c,RTL_Personalized_Message__c,RTL_Remark__c,RTL_Campaign_Product_1__c, RTL_Campaign_Product_2__c, RTL_Campaign_Product_3__c,RTL_Sub_Group_1__c,Completion_Code_1__c, Completion_Code_2__c, Completion_Code_3__c, Completion_Code_4__c,
            Completion_Code_5__c,Avaya_Completion_Code__c,RTL_Web_Unique_ID__c,RTL_AL_car_brand__c,RTL_AL_car_bought_from__c,RTL_AL_car_gear__c,RTL_AL_car_group__c,RTL_AL_car_subtype__c,RTL_AL_car_type__c,RTL_AL_car_year__c,RTL_AL_comment__c,RTL_AL_contact_channel__c,RTL_AL_installment_amount__c,RTL_AL_installment_periods__c,RTL_AL_normal_price__c,RTL_AL_wanted_amount__c,RTL_AL_oa_ref_code__c,RTL_AL_car_plate_no__c,RTL_AL_Interested_Rate__c,RTL_AL_ContactDistrict__c,
            RTL_AL_ContactSubDistrict__c,RTL_AL_ContactZipcode__c,RTL_AL_ContactProvince__c,RTL_AL_max_set_up_amount__c,RTL_AL_ILA_AMT__c,RTL_AL_REMN_MTH__c,RTL_AL_OFFR_ILA_AMT__c,RTL_AL_OFFR_ILA_MTH__c,RTL_AL_BlueBook__c,
            LeadSource,RTL_TMB_Campaign_Source__c,RTL_TMB_Campaign_Reference__c,RTL_Lead_Group__c,Lead.RTL_Media_Source__c,Lead.RTL_Medium__c,Lead.RTL_W2L_Campaign_Name__c,Lead.RTL_W2L_Content__c,Lead.RTL_W2L_Term__c,RTL_Channel_Subsidiary__c,RTL_Product_name__c,
            RTL_OfferResult_Product_1__c, RTL_OfferResult_Product_2__c, RTL_OfferResult_Product_3__c, RTL_OfferResult_Product_4__c, RTL_OfferResult_Product_5__c, Lead_Score_Level__c, Lead_Score__c,LGS_Partner__c,RTL_Lead_Score_Flag__c,LGS_Child_Campaign_ID__c,RTL_W2L_Campaign_Name__c,LGS_Assignment_Code__c,
            LGS_LinkInfo__c,LGS_BrandCode__c,LGS_BrandShowroomCode__c,LGS_PartnerCode__c,LGS_VIN_No__c,LGS_File_Upload__c,LGS_Campaign_Start_Date__c,LGS_Campaign_End_Date__c,Car_Reference_No__c
            FROM CampaignMember Where Id =: recordId LIMIT 1];
            // System.debug(cmObj);
            if(cmObj.RTL_Last_Contact_Status__c  != null)
            {
                cmObj.RTL_Last_Contact_Status__c = RTL_Utility.transLastContactStatus(cmObj.RTL_Last_Contact_Status__c);
            }
        
            return cmObj;

        } catch (Exception e) {
            system.debug('Error:'+e);
            return null;
        }

    }

    @AuraEnabled
    public static Map<String,String> getFieldLabel(String objectName)
    {      
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        Map<String,String> fieldLabelMap = new Map<String,String>();
        
        for (String fieldName : objectFields.keySet()) 
        {           
            //System.debug('fieldName:'+objectFields.get(fieldName).getDescribe().getName());
            //System.debug(objectFields.get(fieldName).getDescribe().getLabel());
            fieldLabelMap.put(objectFields.get(fieldName).getDescribe().getName(),objectFields.get(fieldName).getDescribe().getLabel());
        }
        // System.debug('fieldLabelMap:'+fieldLabelMap);
        return fieldLabelMap;
    }
    
    @AuraEnabled        
    public static List<String> getPickListValues(String objectName,String fieldName){
        
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        List<String> pickListValuesList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = objectFields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> valueList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : valueList){
            //pickListValuesList.add(pickListVal.getLabel());
            pickListValuesList.add(pickListVal.getLabel()+','+pickListVal.getValue());
            //System.debug('pickListValues: '+pickListValuesList);
        }     
        return pickListValuesList;
    }
    // LGSWS2
    @AuraEnabled        
    public static List<Lead_Score_Level__c> getLeadScoreLevelPickListValues(){
        List<Lead_Score_Level__c> value = [SELECT Name, Score_Min__c from Lead_Score_Level__c];
        return value;
    }

    @AuraEnabled
    public static List<String> getDependentPicklistValues (String objectName,String fieldName, String contrlValue) //( Schema.sObjectField dependToken )
    {
        List<String> dependentPicklistValueList = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        //Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.DescribeFieldResult depend = objectFields.get(fieldName).getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                    //  :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getValue() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                //dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
                dependentPicklistValues.get( controlValue ).add( entry.getLabel()+','+entry.getValue() );
            }
        }
        for(Object key : dependentPicklistValues.keySet())
        {
            // System.debug('key:'+key.ToString().toUpperCase());
            // System.debug('contrlValue:'+contrlValue.toUpperCase());
            // System.debug('dependentPicklistValues:'+dependentPicklistValues.get(key));
            if(key.ToString().toUpperCase() == contrlValue.toUpperCase())
            {
                if(dependentPicklistValues.containsKey(key))
                {
                    dependentPicklistValueList = dependentPicklistValues.get(key);
                }
                
            }
            
        }
        return dependentPicklistValueList;
    }
    @AuraEnabled
    public static String checkUpperPicklistValue (String objectName,String fieldName, String contrlValue) //( Schema.sObjectField dependToken )
    {
        List<String> dependentPicklistValueList = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        //Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.DescribeFieldResult depend = objectFields.get(fieldName).getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                    //  :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getValue() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                //dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
                dependentPicklistValues.get( controlValue ).add( entry.getValue() );
            }
        }
        for(Object key : dependentPicklistValues.keySet())
        {
            // System.debug('Dependent ' + (dependentPicklistValues.get(key)));
            if(dependentPicklistValues.get(key).contains(contrlValue))
            {
               return key.ToString(); 
            }
            
        }
        return null;
    }
    public static CampaignMember getProductInCampaign(String recordId)
    {
        try {
            List<CampaignMember> cmList = [SELECT Id,RTL_Contact_Status__c, RTL_Campaign_Product_1__c, RTL_Campaign_Product_2__c, RTL_Campaign_Product_3__c, RTL_Campaign_Product_4__c, RTL_Campaign_Product_5__c, 
            RTL_OfferResult_Product_1__c, RTL_OfferResult_Product_2__c, RTL_OfferResult_Product_3__c, RTL_OfferResult_Product_4__c, RTL_OfferResult_Product_5__c, RTL_Product_Group_1__c, RTL_Product_Group_2__c, RTL_Product_Group_3__c, RTL_Product_Group_4__c, RTL_Product_Group_5__c,  Not_Interest_Reason1__c, Not_Interest_Reason2__c, Not_Interest_Reason3__c, Not_Interest_Reason4__c, Not_Interest_Reason5__c, RTL_Campaign_Product_1__r.Name,RTL_Campaign_Product_2__r.Name,RTL_Campaign_Product_3__r.Name,RTL_Campaign_Product_4__r.Name,RTL_Campaign_Product_5__r.Name,RTL_Sub_Group_1__c, RTL_Sub_Group_2__c, RTL_Sub_Group_3__c, RTL_Sub_Group_4__c, RTL_Sub_Group_5__c,RTL_RelatedOpportunity_1__c, RTL_RelatedOpportunity_2__c, RTL_RelatedOpportunity_3__c, RTL_RelatedOpportunity_4__c, RTL_RelatedOpportunity_5__c, RTL_RelatedOpportunity_1__r.Name, RTL_RelatedOpportunity_2__r.Name, RTL_RelatedOpportunity_3__r.Name, RTL_RelatedOpportunity_4__r.Name, RTL_RelatedOpportunity_5__r.Name, RTL_Opportunity_Stage_1__c, RTL_Opportunity_Stage_2__c, RTL_Opportunity_Stage_3__c, RTL_Opportunity_Stage_4__c, RTL_Opportunity_Stage_5__c, RTL_Opportunity_Status_1__c, RTL_Opportunity_Status_2__c, RTL_Opportunity_Status_3__c, RTL_Opportunity_Status_4__c, RTL_Opportunity_Status_5__c, RTL_Opportunity_Amount_1__c, RTL_Opportunity_Amount_2__c, RTL_Opportunity_Amount_3__c, RTL_Opportunity_Amount_4__c, RTL_Opportunity_Amount_5__c, RTL_Opportunity_CloseDate_1__c, RTL_Opportunity_CloseDate_2__c, RTL_Opportunity_CloseDate_3__c, RTL_Opportunity_CloseDate_4__c, RTL_Opportunity_CloseDate_5__c, Lead.RTL_W2L_Source_Collateral_Type__c 
                FROM CampaignMember WHERE Id =: recordId];
    
            return cmList[0];
        } catch (Exception e) 
        {
            system.debug('Error:'+e);
            return null;
        }

    }

    public static CampaignMember getCampaignMemberLabel(String recordId)
    {
        try {
            List<CampaignMember> cmList = [SELECT Id,toLabel(RTL_Product_Group_1__c), toLabel(RTL_Product_Group_2__c), toLabel(RTL_Product_Group_3__c), toLabel(RTL_Product_Group_4__c), toLabel(RTL_Product_Group_5__c), toLabel(RTL_Sub_Group_1__c), toLabel(RTL_Sub_Group_2__c), toLabel(RTL_Sub_Group_3__c), toLabel(RTL_Sub_Group_4__c), toLabel(RTL_Sub_Group_5__c), toLabel(RTL_OfferResult_Product_1__c), toLabel(RTL_OfferResult_Product_2__c), toLabel(RTL_OfferResult_Product_3__c), toLabel(RTL_OfferResult_Product_4__c),
            toLabel(RTL_OfferResult_Product_5__c), toLabel(RTL_RelatedOpportunity_1__r.StageName), toLabel(RTL_RelatedOpportunity_2__r.StageName), toLabel(RTL_RelatedOpportunity_3__r.StageName), toLabel(RTL_RelatedOpportunity_4__r.StageName), toLabel(RTL_RelatedOpportunity_5__r.StageName), toLabel(RTL_RelatedOpportunity_1__r.RTL_Status__c), toLabel(RTL_RelatedOpportunity_2__r.RTL_Status__c), toLabel(RTL_RelatedOpportunity_3__r.RTL_Status__c), toLabel(RTL_RelatedOpportunity_4__r.RTL_Status__c), toLabel(RTL_RelatedOpportunity_5__r.RTL_Status__c)    
            // toLabel(RTL_Opportunity_Stage_1__c),toLabel(RTL_Opportunity_Stage_2__c),toLabel(RTL_Opportunity_Stage_3__c), toLabel(RTL_Opportunity_Stage_4__c),toLabel(RTL_Opportunity_Stage_5__c),toLabel(RTL_Opportunity_Status_1__c), toLabel(RTL_Opportunity_Status_2__c),toLabel(RTL_Opportunity_Status_3__c),toLabel(RTL_Opportunity_Status_4__c), toLabel(RTL_Opportunity_Status_5__c) 
            FROM CampaignMember WHERE Id =: recordId];
    
            return cmList[0];
        } catch (Exception e) 
        {
            system.debug('Error:'+e);
            return null;
        }

    }

    @AuraEnabled
    public static List<CampaignProductWrapper> getCampaignProductWrapper(String recordId)
    {
        try 
        {   
            CampaignMember cmObj = getProductInCampaign(recordId);
            CampaignMember cmObjLabel = getCampaignMemberLabel(recordId);
            // System.debug('cmObj:'+cmObj); 
            //Mapping Product group with record type
            for(RTL_NBO_Product_Record_Type_Mapping__mdt each : getConfRecordType() )
            {
                string productgroup = each.RTL_Product_Group__c;
                productgroup = productgroup.touppercase();
                mapConfRecordType.put(productgroup,each);
            }
    
               //Get Opportunity record type
            for(RecordType each : getRecordTypeOpportunity() ){
                mapRecordType.put(each.DeveloperName,each);
            }

            Map<String,String> productNameMap = new Map<String,String>();
            productNameMap.put('RTL_Campaign_Product_1__c',cmObj.RTL_Campaign_Product_1__r.Name);
            productNameMap.put('RTL_Campaign_Product_2__c',cmObj.RTL_Campaign_Product_2__r.Name);
            productNameMap.put('RTL_Campaign_Product_3__c',cmObj.RTL_Campaign_Product_3__r.Name);
            productNameMap.put('RTL_Campaign_Product_4__c',cmObj.RTL_Campaign_Product_4__r.Name);
            productNameMap.put('RTL_Campaign_Product_5__c',cmObj.RTL_Campaign_Product_5__r.Name);

            Map<String,String> opptyNameMap = new Map<String,String>();
            opptyNameMap.put('RTL_RelatedOpportunity_1__c',cmObj.RTL_RelatedOpportunity_1__r.Name);
            opptyNameMap.put('RTL_RelatedOpportunity_2__c',cmObj.RTL_RelatedOpportunity_2__r.Name);
            opptyNameMap.put('RTL_RelatedOpportunity_3__c',cmObj.RTL_RelatedOpportunity_3__r.Name);
            opptyNameMap.put('RTL_RelatedOpportunity_4__c',cmObj.RTL_RelatedOpportunity_4__r.Name);
            opptyNameMap.put('RTL_RelatedOpportunity_5__c',cmObj.RTL_RelatedOpportunity_5__r.Name);
            opptyNameMap.put('StageName_1',cmObjLabel.RTL_RelatedOpportunity_1__r.StageName);
            opptyNameMap.put('StageName_2',cmObjLabel.RTL_RelatedOpportunity_2__r.StageName);
            opptyNameMap.put('StageName_3',cmObjLabel.RTL_RelatedOpportunity_3__r.StageName);
            opptyNameMap.put('StageName_4',cmObjLabel.RTL_RelatedOpportunity_4__r.StageName);
            opptyNameMap.put('StageName_5',cmObjLabel.RTL_RelatedOpportunity_5__r.StageName);
            opptyNameMap.put('Status_1',cmObjLabel.RTL_RelatedOpportunity_1__r.RTL_Status__c);
            opptyNameMap.put('Status_2',cmObjLabel.RTL_RelatedOpportunity_2__r.RTL_Status__c);
            opptyNameMap.put('Status_3',cmObjLabel.RTL_RelatedOpportunity_3__r.RTL_Status__c);
            opptyNameMap.put('Status_4',cmObjLabel.RTL_RelatedOpportunity_4__r.RTL_Status__c);
            opptyNameMap.put('Status_5',cmObjLabel.RTL_RelatedOpportunity_5__r.RTL_Status__c);

            List<CampaignProductWrapper> productList = new List<CampaignProductWrapper>();
            Integer count = 1;
            for( Integer i = 1 ; i <= 5 ; i++ )
            {
                Boolean viewGroup = (cmObj.get('RTL_Product_Group_'+i+'__c') == null) ? false : true;
                Boolean viewSubGroup = (cmObj.get('RTL_Sub_Group_'+i+'__c') == null) ? false : true;
                Boolean viewProductName = (cmObj.get('RTL_Campaign_Product_'+i+'__c') == null) ? false : true;
                Boolean viewOfferResult = (cmObj.get('RTL_OfferResult_Product_'+i+'__c') == null) ? false : true;
                Boolean viewReason = (cmObj.get('Not_Interest_Reason'+i+'__c') == null) ? false : true;

                // system.debug('productGroup:'+String.valueOf(cmObj.get('RTL_Product_Group_'+i+'__c')));
                // system.debug('OfferResult:'+cmObj.get('RTL_OfferResult_Product_'+i+'__c'));
                // system.debug('RTL_RelatedOpportunity_:'+cmObj.get('RTL_RelatedOpportunity_'+i+'__c'));

                if(cmObj.get('RTL_OfferResult_Product_'+i+'__c') == 'Interested' || cmObj.get('RTL_OfferResult_Product_'+i+'__c') == 'Referred')
                {
                    viewOfferResult = true;
                    viewReason = true;
                }
                else
                {
                    viewOfferResult = false;
                    viewReason = false;
                }
               
                // Now get product to create opportunities only not converted product
                if( cmObj.get('RTL_OfferResult_Product_'+i+'__c') == null 
                    && cmObj.get('RTL_RelatedOpportunity_'+i+'__c') == null 
                    && cmObj.get('RTL_Product_Group_'+i+'__c')!=null)
                {

                    Opportunity objOpp = new Opportunity();
                    String productGroup = String.valueOf(cmObj.get('RTL_Product_Group_'+i+'__c'));
                    // system.debug('productGroup'+productGroup);
                    // system.debug('mapConfRecordType'+mapConfRecordType);
                    if( mapConfRecordType.containsKey( productGroup.ToUppercase() ) )
                    {
                        String recordTypeByProductGroup = mapConfRecordType.get( productGroup.ToUppercase() ).RTL_Record_Type_DevName__c;
                        // system.debug('objOpp'+objOpp);
                        if( opptyNameMap.containsKey( 'RTL_RelatedOpportunity_'+i+'__c' ) )
                        {
                            objOpp.Name = opptyNameMap.get('RTL_RelatedOpportunity_'+i+'__c');
                        }
                        objOpp.Id = (String)cmObj.get('RTL_RelatedOpportunity_'+i+'__c');
                        objOpp.StageName = mapConfRecordType.get( productGroup.ToUppercase() ).Default_Stage__c;
                        objOpp.RTL_Status__c = 'Open';//Default Opp status
                        if( mapRecordType.containsKey( recordTypeByProductGroup ) )
                        {
                            objOpp.RecordTypeId = mapRecordType.get( recordTypeByProductGroup ).Id;                                                     
                        }                    
                    }
   
                    CampaignProductWrapper intProduct = new CampaignProductWrapper();
                    intProduct.rowNum = count++;
                    intProduct.productGroup = (String)cmObjLabel.get('RTL_Product_Group_'+i+'__c');
                    intProduct.productSubGroup = (String)cmObjLabel.get('RTL_Sub_Group_'+i+'__c');
                    intProduct.productId = (String)cmObj.get('RTL_Campaign_Product_'+i+'__c');
                    if( productNameMap.containsKey( 'RTL_Campaign_Product_'+i+'__c' ) )
                    {
                        intProduct.productName = productNameMap.get('RTL_Campaign_Product_'+i+'__c');
                    }             
                    intProduct.objOpp = objOpp;
                    intProduct.viewGroup = viewGroup;
                    intProduct.viewSubGroup = viewSubGroup;
                    intProduct.viewProductName = viewProductName;       

                    intProduct.numberOfProduct = i;
                    intProduct.isShowHLCALMoredetail = getHLCALmoreDetailVisible(intProduct.productName, cmObj.Lead.RTL_W2L_Source_Collateral_Type__c);
                    productList.add( intProduct );               
                }

                if( cmObj.get('RTL_OfferResult_Product_'+i+'__c') != null 
                    && cmObj.get('RTL_Product_Group_'+i+'__c')!=null)
                {
                    Opportunity objOpp = new Opportunity();
                    String productGroup = String.valueOf(cmObj.get('RTL_Product_Group_'+i+'__c'));
                    // system.debug('productGroup'+productGroup);
                    // system.debug('mapConfRecordType'+mapConfRecordType);
                    if( mapConfRecordType.containsKey( productGroup.ToUppercase() ) )
                    {
                        String recordTypeByProductGroup = mapConfRecordType.get( productGroup.ToUppercase() ).RTL_Record_Type_DevName__c;
                        // system.debug('objOpp'+objOpp);
                        if( opptyNameMap.containsKey( 'RTL_RelatedOpportunity_'+i+'__c' ) )
                        {
                            objOpp.Name = opptyNameMap.get('RTL_RelatedOpportunity_'+i+'__c');
                        }
                        if(cmObj.get('RTL_RelatedOpportunity_'+i+'__c') != null)
                        {
                            objOpp.Id = (String)cmObj.get('RTL_RelatedOpportunity_'+i+'__c');
                            objOpp.StageName = (String)cmObj.get('RTL_Opportunity_Stage_'+i+'__c');
                            objOpp.RTL_Status__c = (String)cmObj.get('RTL_Opportunity_Status_'+i+'__c');
                            objOpp.Amount = (Decimal)cmObj.get('RTL_Opportunity_Amount_'+i+'__c');
                            objOpp.CloseDate = (Date)cmObj.get('RTL_Opportunity_CloseDate_'+i+'__c');
                        }
                        else
                        {
                            objOpp.Id = (String)cmObj.get('RTL_RelatedOpportunity_'+i+'__c');
                            objOpp.StageName = mapConfRecordType.get( productGroup.ToUppercase() ).Default_Stage__c;
                            objOpp.RTL_Status__c = 'Open';//Default Opp status
                        }
       
                        if( mapRecordType.containsKey( recordTypeByProductGroup ) )
                        {
                            objOpp.RecordTypeId = mapRecordType.get( recordTypeByProductGroup ).Id;                                                     
                        }                    
                    }
                    
                    CampaignProductWrapper intProduct = new CampaignProductWrapper();
                    intProduct.rowNum = count++;
                    intProduct.productGroup = (String)cmObjLabel.get('RTL_Product_Group_'+i+'__c');
                    intProduct.productSubGroup = (String)cmObjLabel.get('RTL_Sub_Group_'+i+'__c');
                    intProduct.productId = (String)cmObj.get('RTL_Campaign_Product_'+i+'__c');
                    if( productNameMap.containsKey( 'RTL_Campaign_Product_'+i+'__c' ) )
                    {
                        intProduct.productName = productNameMap.get('RTL_Campaign_Product_'+i+'__c');
                    }
                    intProduct.offerResult = (String)cmObj.get('RTL_OfferResult_Product_'+i+'__c');
                    intProduct.offerResultLabel = (String)cmObjLabel.get('RTL_OfferResult_Product_'+i+'__c');
                    intProduct.reason = (String)cmObj.get('Not_Interest_Reason'+i+'__c');               
                    intProduct.objOpp = objOpp;
                    intProduct.viewGroup = viewGroup;
                    intProduct.viewSubGroup = viewSubGroup;
                    intProduct.viewProductName = viewProductName;
                    intProduct.viewOfferResult = viewOfferResult;
                    intProduct.viewReason = viewReason; 
                    if( opptyNameMap.containsKey( 'StageName_'+i ) )
                    {
                        intProduct.stageLabel = opptyNameMap.get('StageName_'+i);
                    }
                    if( opptyNameMap.containsKey( 'Status_'+i ) )
                    {
                        intProduct.statusLabel = opptyNameMap.get('Status_'+i);
                    }
                    // if(viewOfferResult)
                    // {
                    //     intProduct.isValidate = true; 
                    // }                   

                    intProduct.numberOfProduct = i;
                    intProduct.isShowHLCALMoredetail = getHLCALmoreDetailVisible(intProduct.productName, cmObj.Lead.RTL_W2L_Source_Collateral_Type__c);
                    productList.add( intProduct ); 
                }
            }
            // System.debug('productList'+productList); 
            return productList;
        } 
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<CampaignProductWrapper> getCampaignProductWrapperINT06(CampaignMember cmObj)
    {
        try 
        {   
            // System.debug('cmObj:'+cmObj); 
            //Mapping Product group with record type
            for(RTL_NBO_Product_Record_Type_Mapping__mdt each : getConfRecordType() )
            {
                string productgroup = each.RTL_Product_Group__c;
                productgroup = productgroup.touppercase();
                mapConfRecordType.put(productgroup,each);
            }
    
               //Get Opportunity record type
            for(RecordType each : getRecordTypeOpportunity() ){
                mapRecordType.put(each.DeveloperName,each);
            }

            List<CampaignProductWrapper> productList = new List<CampaignProductWrapper>();
            Integer count = 1;
            for( Integer i = 1 ; i <= 5 ; i++ )
            {
                Boolean viewGroup = (cmObj.get('RTL_Product_Group_'+i+'__c') == null) ? false : true;
                Boolean viewSubGroup = (cmObj.get('RTL_Sub_Group_'+i+'__c') == null) ? false : true;
                Boolean viewProductName = (cmObj.get('RTL_Campaign_Product_'+i+'__c') == null) ? false : true;
                Boolean viewOfferResult = (cmObj.get('RTL_OfferResult_Product_'+i+'__c') == null) ? false : true;
                Boolean viewReason = (cmObj.get('Not_Interest_Reason'+i+'__c') == null) ? false : true;

                // system.debug('productGroup:'+String.valueOf(cmObj.get('RTL_Product_Group_'+i+'__c')));
                // system.debug('OfferResult:'+cmObj.get('RTL_OfferResult_Product_'+i+'__c'));

                // Now get product to create opportunities only not converted product
                if( cmObj.get('RTL_OfferResult_Product_'+i+'__c') == null 
                    && cmObj.get('RTL_RelatedOpportunity_'+i+'__c') == null 
                    && cmObj.get('RTL_Product_Group_'+i+'__c')!=null)
                {

                    Opportunity objOpp = new Opportunity();
                    String productGroup = String.valueOf(cmObj.get('RTL_Product_Group_'+i+'__c'));

                    if( mapConfRecordType.containsKey( productGroup.ToUppercase() ) )
                    {
                        String recordTypeByProductGroup = mapConfRecordType.get( productGroup.ToUppercase() ).RTL_Record_Type_DevName__c;
                        // system.debug('objOpp'+objOpp);

                        objOpp.Id = (String)cmObj.get('RTL_RelatedOpportunity_'+i+'__c');
                        objOpp.StageName = mapConfRecordType.get( productGroup.ToUppercase() ).Default_Stage__c;
                        objOpp.RTL_Status__c = 'Open';//Default Opp status
                        if( mapRecordType.containsKey( recordTypeByProductGroup ) )
                        {
                            objOpp.RecordTypeId = mapRecordType.get( recordTypeByProductGroup ).Id;                                                     
                        }                    
                    }
   
                    CampaignProductWrapper intProduct = new CampaignProductWrapper();
                    intProduct.rowNum = count++;
                    intProduct.productGroup = (String)cmObj.get('RTL_Product_Group_'+i+'__c');
                    intProduct.productSubGroup = (String)cmObj.get('RTL_Sub_Group_'+i+'__c');
                    intProduct.productId = (String)cmObj.get('RTL_Campaign_Product_'+i+'__c');        
                    intProduct.objOpp = objOpp;
                    intProduct.viewGroup = viewGroup;
                    intProduct.viewSubGroup = viewSubGroup;
                    intProduct.viewProductName = viewProductName;       

                    intProduct.numberOfProduct = i;
                    productList.add( intProduct );               
                }            
            }
            // System.debug('productList'+productList); 
            return productList;
        } 
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
    }

    @AuraEnabled
    public static Object getCustomerSegment(String marketingCode,String tmbCustId){

        Datetime startCallINT06;
        Datetime endCallINT06;
        String requestBody = '';
        String resultBody = '';
        String rmId = marketingCode;
        String customerName = '';
        Account accountObj = new Account();

        // System.debug('==== start callout ============');
        startCallINT06 = system.now();
        

        CampaignMember campaignMemObj = new CampaignMember();

        Integer startPage = 1;
        Integer endPage =  1;

        String startDate =  Datetime.now().addYears(-2).format('yyyy-MM-dd');
        String endDate = Datetime.now().format('yyyy-MM-dd');


        Http h = new Http();
        HttpRequest req = new HttpRequest();

        requestBody = '<CampaignMemberRequest>\n'+
            '<CampaignMember>\n'+
                '<CustID>' + tmbCustId + '</CustID>\n'+
                '<CampStartDate>' + startDate + '</CampStartDate>\n'+
                '<CampEndDate>' + endDate + '</CampEndDate>\n'+
                '<MarketingCode>' + marketingCode + '</MarketingCode>\n'+
                '<StartRow>' + startPage + '</StartRow>\n'+
                '<EndRow>' + endPage + '</EndRow>\n'+
            '</CampaignMember>\n'+
        '</CampaignMemberRequest>';

        // String requestBody = '<CampaignMemberRequest>\n'+
        //     '<CampaignMember>\n'+
        //         '<CustID>001100000000000000000015615613</CustID>\n'+
        //         '<CampStartDate>2018-03-07</CampStartDate>\n'+
        //         '<CampEndDate>2021-03-07</CampEndDate>\n'+
        //         '<MarketingCode>DFFFLOC11A1354593880</MarketingCode>\n'+
        //         '<StartRow>1</StartRow>\n'+
        //         '<EndRow>1</EndRow>\n'+
        //     '</CampaignMember>\n'+
        // '</CampaignMemberRequest>';

       req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpointInt06);
        req.setBody(requestBody);

        

        try{

            HttpResponse res;

            if (!Test.isRunningTest()) {
                res = h.send(req); 
            }
            else
            {
                String body = '<CampaignMemberResponse>' +
                        '<CampaignMemberList>'+
                            '<CampaignMember>'+
                                '<CampaignCode>DFFFLOC11A</CampaignCode>'+
                                '<MarketingCode>DFFFLOC11A1354593880</MarketingCode>'+
                                '<ProductOfferString>2:Credit Cards</ProductOfferString>'+
                                '<CampaignChannel>OUTBOUND</CampaignChannel>'+
                                '<MobileNumber>0800000056</MobileNumber>'+
                                '<UpdateDate>2020-12-25T16:35:30</UpdateDate>'+
                                '<ResultContact/>'+
                                '<AgentID/>'+
                                '<ResultDetail/>'+
                                '<ResultBusiness/>'+
                                '<OfferResult/>'+
                                '<ContactDate/>'+
                                '<Reason/>'+
                                '<SmsMessage/>'+
                                '<SmsContent/>'+
                                '<RegisterDate/>'+
                                '<DisplayFlag>N/A</DisplayFlag>'+
                                '<DisplayDate/>'+
                                '<ClickFlag>N/A</ClickFlag>'+
                                '<ClickDate/>'+
                                '<EmailSendDate/>'+
                                '<EmailRejectDate/>'+
                                '<EmailOpenFlag>N/A</EmailOpenFlag>'+
                                '<EmailOpenDate/>'+
                                '<EmailClickFlag>N/A</EmailClickFlag>'+
                                '<EmailClickDate/>'+
                                '<ContactSubStatus/>'+
                                '<OfferSubResult/>'+
                                '<PersonalizedMessage>AUM เฉลี่ยย้อนหลัง 180วัน= 1,017,960.88</PersonalizedMessage>'+
                            '</CampaignMember>'+
                        '</CampaignMemberList>'+
                        '<Header>'+
                            '<ErrorStatus>success</ErrorStatus>'+
                            '<ErrorCode>00</ErrorCode>'+
                            '<ErrorDescription/>'+
                            '<TotalRecords>1</TotalRecords>'+
                        '</Header>'+
            		'</CampaignMemberResponse>';
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody(body);
                res.setStatusCode(200);
            }
            
            //con.addHttpRequest(req);
    
            // System.debug(res.getStatusCode());
            // System.debug(res.getBody());

            resultBody = res.getBody();
    
            Dom.Document doc = new Dom.Document();
            doc.load(res.getBody());
    
            Dom.XMLNode root = doc.getRootElement();
    
            Dom.XMLNode header = root.getChildElement('Header', null);
            //Dom.XMLNode errorCode = header.getChildElement('ErrorCode', null);
            //System.debug('header:'+header);
            String errorCodeText =  header.getChildElement('ErrorCode', null).getText();
            String errorDescText =  header.getChildElement('ErrorDescription', null).getText();
            String errorStatusText =  header.getChildElement('ErrorStatus', null).getText();
    
            // system.debug('errorStatusText : '+errorStatusText);
    
            if( errorStatusText == 'fail' ) 
            {
                
                    String erStatus = '';
                    erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
                    erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
                    erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
                    
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));
                    throw new AuraHandledException(erStatus.unescapeHtml4());
    
            }
            else 
            {
                errorCodeText = '';
                errorDescText = '';
  
            /*------------------------------Start edit 1 ------------------------------*/
                Dom.XMLNode cmList = root.getChildElement('CampaignMemberList', null);
                Dom.XMLNode cm = cmList.getChildElement('CampaignMember', null);
                if( cm != null )
                {
            
                    campaignMemberResponse = new CampaignMemberResponseObject();
                    campaignMemberResponse.campaigncode = cm.getChildElement('CampaignCode', null).getText().trim();
                    campaignMemberResponse.marketingcode = cm.getChildElement('MarketingCode', null).getText().trim();
                    campaignMemberResponse.productofferstring = cm.getChildElement('ProductOfferString', null).getText().trim();
                    campaignMemberResponse.campaignchannel = cm.getChildElement('CampaignChannel', null).getText().trim();
                    campaignMemberResponse.mobilenumber = cm.getChildElement('MobileNumber', null).getText().trim();
                    campaignMemberResponse.updatedate = cm.getChildElement('UpdateDate', null).getText().trim();
                    campaignMemberResponse.resultcontact = cm.getChildElement('ResultContact', null).getText().trim();
                    campaignMemberResponse.agentid = cm.getChildElement('AgentID', null).getText().trim();
                    campaignMemberResponse.resultdetail = cm.getChildElement('ResultDetail', null).getText().trim();
                    campaignMemberResponse.offerresult = cm.getChildElement('OfferResult', null).getText().trim();
                    // campaignMemberResponse.contactdate = cm.getChildElement('ContactDate', null).getText().trim();
                    campaignMemberResponse.reason = cm.getChildElement('Reason', null).getText().trim();
                    campaignMemberResponse.smsmessage = cm.getChildElement('SmsMessage', null).getText().trim();
                    campaignMemberResponse.smscontent = cm.getChildElement('SmsContent', null).getText().trim();
                    campaignMemberResponse.registerdateText = cm.getChildElement('RegisterDate', null).getText().trim();
                    campaignMemberResponse.displayflagText = cm.getChildElement('DisplayFlag', null).getText().trim();
                    campaignMemberResponse.displaydateText = cm.getChildElement('DisplayDate', null).getText().trim();
                    campaignMemberResponse.clickflagText = cm.getChildElement('ClickFlag', null).getText().trim();
                    campaignMemberResponse.clickdateText = cm.getChildElement('ClickDate', null).getText().trim();
                    campaignMemberResponse.emailsenddateText = cm.getChildElement('EmailSendDate', null).getText().trim();
                    campaignMemberResponse.emailrejectdateText = cm.getChildElement('EmailRejectDate', null).getText().trim();
                    campaignMemberResponse.emailopenflagText = cm.getChildElement('EmailOpenFlag', null).getText().trim();
                    campaignMemberResponse.emailopendateText = cm.getChildElement('EmailOpenDate', null).getText().trim();
                    campaignMemberResponse.emailclickflagText = cm.getChildElement('EmailClickFlag', null).getText().trim();
                    campaignMemberResponse.emailclickdateText = cm.getChildElement('EmailClickDate', null).getText().trim();
                    campaignMemberResponse.contactsubstatus= cm.getChildElement('ContactSubStatus', null).getText().trim();
                    campaignMemberResponse.offersubresult = cm.getChildElement('OfferSubResult', null).getText().trim();
                    
                    campaignMemberResponse.resultbusiness = cm.getChildElement('ResultBusiness', null).getText().trim();
                    campaignMemberResponse.contactdateText = cm.getChildElement('ContactDate', null).getText().trim();
                    campaignMemberResponse.personalizedMessage = cm.getChildElement('PersonalizedMessage', null).getText().trim();
    
                    //CR PersonalizedMessage
                    if(campaignMemberResponse.personalizedMessage !=null)
                    {
                        campaignMemObj.RTL_Personalized_Message__c = campaignMemberResponse.personalizedMessage;
                    }
    
                    if(campaignMemObj.id == null)
                    {
                        campaignMemObj.RTL_CampHis_Phone__c = campaignMemberResponse.mobilenumber;
                        campaignMemObj.RTL_Marketing_Code__c = campaignMemberResponse.marketingcode;
                        campaignMemObj.RTL_Contact_Status__c = campaignMemberResponse.resultcontact;                  
                        //campaignMemObj.RTL_Campaign_Channel_formula__c =  campaignMemberResponse.campaignchannel;
                        try
                        {
                            List<Campaign> campaignData = [SELECT id,name,RTL_Campaign_Code_10_digits__c,RTL_Campaign_Start_Date__c
                                    FROM Campaign WHERE RTL_Campaign_Code_10_digits__c = :campaignMemberResponse.campaigncode LIMIT 1 ];
                   
                            campaignMemObj.campaign = campaignData.get(0);
                            campaignMemObj.campaignId = campaignData.get(0).Id;  
    
                            List<Account> accountData = [SELECT id,name,TMB_Customer_ID_PE__c FROM ACCOUNT WHERE TMB_Customer_ID_PE__c =:tmbCustId ];    
                            campaignMemObj.Customer__c = accountData.get(0).Id;
                            campaignMemObj.Customer__r = accountData.get(0);
                        
                            List<Contact> contactData = [SELECT id,name,TMB_Customer_ID__c,account.name,AccountId 
                                            FROM Contact 
                                            WHERE TMB_Customer_ID__c =:tmbCustId LIMIT 1];    
            
                            campaignMemObj.ContactId = contactData.get(0).Id;
                            campaignMemObj.Contact = contactData.get(0);
    
                        }
                        catch (exception e)
                        {
                            // exception not found account
                            system.debug(e.getMessage());
                        }
                        //checkCampaignStatus();
    
    
                        Set<String> channelList = new  Set<String>();
    
                        for( String campaignChannel : campaignMemberResponse.campaignchannel.Split(',') )
                        {
                            channelList.add( campaignChannel.trim() );
                        }                
                        Set<String> objectFields = Schema.SObjectType.CampaignMember.fields.getMap().keySet();
                        
                        if(channelList.size()>0){
                            for(RTL_CAMPAIGN_CHANNEL_INT06_MAP__mdt channelValue : [select Id,RTL_CHANNEL_FIELD_NAME__c,RTL_MDM_CAMPAIGN_CHANNEL_VALUE__c
                                                FROM RTL_CAMPAIGN_CHANNEL_INT06_MAP__mdt
                                                WHERE RTL_MDM_CAMPAIGN_CHANNEL_VALUE__c IN: channelList]){
                                
                                if(objectFields.contains(channelValue.RTL_CHANNEL_FIELD_NAME__c)) {
                                    campaignMemObj.put(channelValue.RTL_CHANNEL_FIELD_NAME__c,true);
                                    // System.debug('RTL_CHANNEL_FIELD_NAME__c:'+channelValue.RTL_CHANNEL_FIELD_NAME__c);
                                }
                                
                            }                              
                        }
    
                        String productOfferString = campaignMemberResponse.productofferstring;
                        if(productOfferString!=null){
                            campaignMemObj.RTL_Products_Offer_String__c = productOfferString;
                        }
    
                        Set<String> retailProductsNameSet = new Set<String>();
                        Set<String> retailProductsSubGroupSet = new Set<String>();
    
                        List<List<String>> productsOffer = RTL_UploadCampaignMemberCreateLead.processProductOfferString(productOfferString);
    
                        for( List<String> productItem : productsOffer  )
                        {
                            if( productItem.get(0) == '3' )
                            {
                                retailProductsNameSet.add(productItem.get(1));
                            }
                            else if ( productItem.get(0) == '2' )
                            {
                                retailProductsSubGroupSet.add(productItem.get(1));
                            }                        
                        }
    
                        Map<String,String> RetailProductSubGroupMap = new  Map<String,String>();
    
                        if(retailProductsSubGroupSet.size()>0){
    
                            for(AggregateResult agResult : [select Product_Group__c,Product_Sub_group__c
                                            from RTL_product_master__c 
                                            where Active__c = true AND Product_Sub_group__c IN: retailProductsSubGroupSet 
                                            GROUP BY Product_Group__c,Product_Sub_group__c 
                                        ]){
                                String subGroupName =  (String)agResult.get('Product_Sub_group__c');
    
                                RetailProductSubGroupMap.put( subGroupName.tolowercase() ,(String)agResult.get('Product_Group__c'));
                            }
                        }
    
                        Map<String,RTL_product_master__c > RetailProductNameMap = new Map<String,RTL_product_master__c >();
                        Map<String,RTL_product_master__c > RetailProductIDMap = new Map<String,RTL_product_master__c >();
                        
                        if(retailProductsNameSet.size()>0){
                            for(RTL_product_master__c pm : [select Id,RTL_Product2_Name__c ,
                                Product_Sub_group__c,Product_Group__c,Active__c,Name
                                FROM RTL_product_master__c 
                                WHERE Active__c = true 
                                AND Name LIKE: retailProductsNameSet ]){
    
                                
                                RetailProductNameMap.put( pm.Name,pm);

                                RetailProductIDMap.put( pm.Id ,pm);
                            }
                        }
    
                        List<List<String>> productOfferResultList = RTL_UploadCampaignMemberCreateLead.generateProductOfferList(productOfferString,RetailProductNameMap,RetailProductSubGroupMap);
            
                        Integer i = 0;
                        for( List<String> offerResutl : productOfferResultList )
                        {
                            i++;
                            RTL_product_master__c prod = (RTL_product_master__c)RetailProductIDMap.get(offerResutl.get(2));
    
                            if( offerResutl.get(0) != '' )
                            {
                                campaignMemObj.put('RTL_Product_Group_'+i+'__c', offerResutl.get(0) );
                            }
    
    
                            if( offerResutl.get(1) != '' )
                            {
                                campaignMemObj.put('RTL_Sub_Group_'+i+'__c', offerResutl.get(1) );
                            }
    
    
                            if( offerResutl.get(2) != '' )
                            {
                                campaignMemObj.put('RTL_Campaign_Product_'+i+'__c', offerResutl.get(2) ); 
                            }
    
                            if( prod != null )
                            {
    
                                if( i == 1 )
                                {
                                    campaignMemObj.RTL_Campaign_Product_1__r = prod;
                                }
                                else if (i == 2)
                                {
                                    campaignMemObj.RTL_Campaign_Product_2__r = prod;
                                }
                                else if (i == 3)
                                {
                                    campaignMemObj.RTL_Campaign_Product_3__r = prod;
                                }
                                else if (i == 4)
                                {
                                    campaignMemObj.RTL_Campaign_Product_4__r = prod;
                                }
                                else if (i == 5)
                                {
                                    campaignMemObj.RTL_Campaign_Product_5__r = prod;
                                }
                            }
    
                        }
    
                    }
                }
            }    
            // System.debug('campaignMemObj:'+campaignMemObj);
            // System.debug('campaignMemberResponse:'+campaignMemberResponse);
            endCallINT06 = system.now();
    
            RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
            accountObj.id ,requestBody , resultBody  , startCallINT06 ,endCallINT06 );
    
            return campaignMemObj;
        }
        catch(Exception e) {

            endCallINT06 = system.now();

            String errorCodeText = RTL_CampaignUtil.SF_ERROR_CODE;
            String errorDescText = e.getMessage() + '(' + e.getLineNumber() + ')';

            String erStatus = '';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage2;
            erStatus += '<a onclick="refreshTab()">'+ system.Label.RTL_Campaign_History_ErrorMessage3+'</a> ';
            erStatus += system.Label.RTL_Campaign_History_ErrorMessage4;
                
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,erStatus));
   
            RTL_CampaignUtil.insertOnlineLogWithResponse( errorCodeText,errorDescText, rmId , RTL_CampaignUtil.INT06_SERVICE_NAME , 
                accountObj.id ,requestBody , resultBody  , startCallINT06 ,endCallINT06 );

            System.debug('CRM : '+e.getMessage() + ' Line:'+e.getLineNumber());

            return null;
        }
    }
    

    @AuraEnabled
    public static String saveCampaign(List<CampaignProductWrapper> productList,String extAccId,String accObj,CampaignMember campaignMemObj,Boolean isMerge,String productCrossSellList,String leadInput){
        // System.debug('productList:'+productList);
        // System.debug('extAccId:'+extAccId);
        // System.debug('accObj:'+accObj);
        // System.debug('isMerge:'+isMerge);
        // System.debug('leadInput:'+leadInput);
       
        Map<String, Object> accObjMap = new Map<String, Object>();
        Map<String, Object> leadObjMap = new Map<String, Object>();
        if(accObj!= null)
        {
            accObjMap = (Map<String, Object>)JSON.deserializeUntyped(accObj);
        }
        // System.debug('accObj'+accObjMap);

        if(leadInput != null)
        {
            leadObjMap = (Map<String, Object>)JSON.deserializeUntyped(leadInput);
        }
        // System.debug('leadObjMap:'+leadObjMap);
        String accDupId;
        if(extAccId != null)
        {
            accDupId = extAccId;
            campaignMemObj.Customer__c = extAccId;
        }
        else 
        {
            if(accObjMap != null && accObjMap.size() > 0)
            {
                accDupId = String.valueOf(accObjMap.get('Id'));
            }
        }
       
        Map<String,Business_Outcome_Mapping__c> outComeMap = getBusinessOutcomeMapping();
        List<CampaignProductWrapper> interestedProductList = new List<CampaignProductWrapper>();
        List<Object> crossSellObjs = new List<Object>();
        if(productCrossSellList!= null)
        {
            crossSellObjs = (List<Object>)JSON.deserializeUntyped(productCrossSellList);
        }  
        // System.debug('crossSellObjs : '+ crossSellObjs);
        //  System.debug('crossSellObjs size: '+ crossSellObjs.size());

        
        for(CampaignProductWrapper product : productList)
        {
            
            if(product.offerResult == 'Interested')
            {
                if(campaignMemObj.RTL_Contact_Status__c == 'Contact' || campaignMemObj.RTL_Contact_Status__c == 'Call Back')
                {
                    interestedProductList.add(product);
                }
            }
            else if(product.offerResult == 'Referred')
            {
                if(campaignMemObj.RTL_Contact_Status__c == 'Contact' || campaignMemObj.RTL_Contact_Status__c == 'Call Back')
                {
                    campaignMemObj.put('RTL_Product_Group_'+(String.valueOf(product.numberOfProduct))+'__c', (String.valueOf(product.productGroup).toUpperCase()));
                    campaignMemObj.put('RTL_Sub_Group_'+(String.valueOf(product.numberOfProduct))+'__c', (String.valueOf(product.productSubGroup).toUpperCase()));
                    campaignMemObj.put('RTL_Campaign_Product_'+(String.valueOf(product.numberOfProduct))+'__c', product.productId );
                    campaignMemObj.put('RTL_OfferResult_Product_'+(String.valueOf(product.numberOfProduct))+'__c', product.offerResult );
                    campaignMemObj.put('Not_Interest_Reason'+(String.valueOf(product.numberOfProduct))+'__c',product.reason); 
                }
            }
            else 
            {
                campaignMemObj.put('RTL_Product_Group_'+(String.valueOf(product.numberOfProduct))+'__c', (String.valueOf(product.productGroup).toUpperCase()));
                campaignMemObj.put('RTL_Sub_Group_'+(String.valueOf(product.numberOfProduct))+'__c', (String.valueOf(product.productSubGroup).toUpperCase()));
                campaignMemObj.put('RTL_Campaign_Product_'+(String.valueOf(product.numberOfProduct))+'__c', product.productId );
                campaignMemObj.put('RTL_OfferResult_Product_'+(String.valueOf(product.numberOfProduct))+'__c', product.offerResult );
                campaignMemObj.put('Not_Interest_Reason'+(String.valueOf(product.numberOfProduct))+'__c',product.reason); 
            }

            // System.debug('productGroup:'+product.productGroup.toUpperCase());
            // System.debug('offerResult:'+product.offerResult);
            // System.debug('reason:'+product.reason);
            // System.debug('outComeMap:'+outComeMap);
            // System.debug('product.productGroup.toUpperCase()+product.offerResult+product.reason:'+product.productGroup.toUpperCase()+product.offerResult+product.reason);
            //System.debug('outComeMap:'+outComeMap.get(product.productGroup+product.offerResult+product.reason).Avaya_Completion_Code__c);
            if(campaignMemObj.RTL_Contact_Status__c == 'Contact' )
            {            
                String key = '';
                if (product.reason != null) {
                    key = product.productGroup.toUpperCase()+product.offerResult+product.reason;
                } else {
                    key = product.productGroup.toUpperCase()+product.offerResult;
                }
                // System.debug('Key1 ----->' + key);
                if(outComeMap.containsKey(key))
                {
                    campaignMemObj.put('Completion_Code_'+(String.valueOf(product.rowNum))+'__c',outComeMap.get(key).Avaya_Completion_Code__c);     
                }
            }
        }
        // System.debug('interestedProductList:'+interestedProductList);

        List<Object> crossSellInterestedObj = new List<Object>();
        List<Object> crossSellReferredObj = new List<Object>();
        
        for (Integer i = 0; i < crossSellObjs.size(); i++) {
    
            Map<String, Object> product = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crossSellObjs[i]));
            // System.debug('product'+i+' :'+product);

            if(product.get('offerResult') == 'Interested' )
            {
                crossSellInterestedObj.add(crossSellObjs[i]);
            }
            else if(product.get('offerResult') == 'Referred')
            {
                crossSellReferredObj.add(crossSellObjs[i]);
            }
        }

        Id accId;
        // List<Opportunity> opptyList = new List<Opportunity>();   
        Lead leadObj = new Lead();
        Lead leadObjToUpdateScore = new Lead();

        Account accountObj = new Account();
        if(accDupId != null)
        {
            accountObj = [SELECT Id,ID_Type_PE__c,ID_Number_PE__c,Mobile_Number_PE__c, RTL_NID__c FROM Account WHERE Id =: accDupId];
        }
      
        if(campaignMemObj.LeadId != null)
        {
            leadObj = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead Where Id =: campaignMemObj.LeadId];
            leadObjToUpdateScore.Id = leadObj.Id;
        }

        // System.debug('leadObj before:'+leadObj);
        //Set Data To Lead
        if(leadObjMap != null && leadObjMap.size() > 0)
        {
            leadObj.FirstName = String.valueOf(leadObjMap.get('Name')).split(' ')[0];
            leadObj.LastName = String.valueOf(leadObjMap.get('Name')).split(' ')[1]; 
            leadObj.RTL_Mobile_Number__c = String.valueOf(leadObjMap.get('Mobile_Number_PE__c'));
            leadObj.RTL_ID_Type__c = String.valueOf(leadObjMap.get('ID_Type_PE__c'));
            leadObj.RTL_Citizen_Id__c = String.valueOf(leadObjMap.get('ID_Number_PE__c'));
        }

        // System.debug('leadObj after:'+leadObj);

        //UPDATE CAMPAIGN MEMBER
        Savepoint sp = Database.setSavepoint();

        try{          
            updateCampaignMember(campaignMemObj); 
            if(leadObjToUpdateScore.Id != null){
                leadObjToUpdateScore.Lead_Score__c = campaignMemObj.Lead_Score__c;
                leadObjToUpdateScore.Lead_Score_Level__c = campaignMemObj.Lead_Score_Level__c;
                update leadObjToUpdateScore;
            }
            if(crossSellReferredObj.size() > 0)
            {
                saveCrossSell(crossSellReferredObj, campaignMemObj, new List<String>());
            } 
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage() + ' Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage().unescapeHtml4());
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002));            
            //return null;
        }
        

        if((interestedProductList.size() > 0 || crossSellInterestedObj.size() > 0)&& campaignMemObj.ContactId == null &&
        (campaignMemObj.RTL_Contact_Status__c == 'Contact' || campaignMemObj.RTL_Contact_Status__c == 'Call Back'))
        {
            if(isMerge)
            {
                if(CheckDupAccountMerge(leadObj,accountObj))
                {
                    
                        MergeConvertLeadCAMPAIGN(campaignMemObj, accountObj ,leadObj, productList, interestedProductList, crossSellInterestedObj);
                    
                }
                else 
                {
                    throw new AuraHandledException(Label.RTL_Merge_Account_Error_Message);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.RTL_Merge_Account_Error_Message));
                    //	Customer with the same ID Type/ID Number is found on System. Unable to merge a new prospect.
                    //showErrMsgPage();
                }
            }
            else
            {          
                if(CheckDupAccount(leadObj))
                {
                
                    NewAccConvertLeadCAMPAIGN(campaignMemObj, leadObj,  productList, interestedProductList, crossSellInterestedObj);           
                    
                }
                else 
                {
                    throw new AuraHandledException(Label.RTL_Create_Account_Error_Message);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.RTL_Create_Account_Error_Message));
                    //	Customer with the same ID Type/ID Number is found on System. Unable to create a new prospect.
                    //showErrMsgPage();
                }
            }
        }
        else 
        {

            //create opp line
            Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();
            // System.debug('Customer__c:'+campaignMemObj.Customer__c);
            if(accId == null && campaignMemObj.Customer__c != null)
            {
                accId = campaignMemObj.Customer__c;
            }
            else {
                accId = accDupId;
            }
            // System.debug('Account Id :'+accId);
            // if(accId == null && campaignMemObj.Customer__c != null)
            if( interestedProductList.size() > 0 ){            
                for( CampaignProductWrapper product : interestedProductList ){
                    // System.debug('objOpp:'+product.objOpp.Id);
                    if(String.isEmpty(product.objOpp.Id) && product.offerResult == 'Interested')
                    {
                        Opportunity newOpp = new Opportunity();
                        newOpp = product.objOpp;
                        newOpp.RTL_Product_Group__c = String.valueOf(product.productGroup);
                        newOpp.RTL_Prod_SubGrp__c = String.valueOf(product.productSubGroup);
                        newOpp.RTL_Product_Name__c = String.valueOf(product.productId);                
                        newOpp.AccountId = campaignMemObj.Customer__c;    
                        newOpp.CampaignId = campaignMemObj.CampaignId;
                        newOpp.RTL_Campaign_Code__c = campaignMemObj.Campaign.RTL_Campaign_Code_10_digits__c;
                        newOpp.RTL_Campaign_Name__c = campaignMemObj.Campaign.Name;
                        newOpp.RTL_Campaign_Start_Date__c = campaignMemObj.Campaign.RTL_Campaign_Start_Date__c;     
                        newOpp.RTL_Is_Create_From_Campaign_Member__c = true; //for except validation rule when create opp
                        
                        newOpp.RTL_Campaign_Lead_Source__c = campaignMemObj.RTL_TMB_Campaign_Source__c;
                        newOpp.RTL_Campaign_Lead_Reference__c = campaignMemObj.RTL_TMB_Campaign_Reference__c;
                        newOpp.LeadSource = campaignMemObj.LeadSource;

                        //For TBank Gap
                        if(campaignMemObj.RTL_Marketing_Code__c != null)
                        {
                            newOpp.Marketing_Code__c = campaignMemObj.RTL_Marketing_Code__c;
                        }
                        else if(campaignMemObj.RTL_Web_Unique_ID__c != null)
                        {
                            newOpp.RTL_Web_Unique_ID__c = campaignMemObj.RTL_Web_Unique_ID__c;
                        }             
                        //LGS additional Fields
                        newOpp.LGS_Assignment_Code__c = campaignMemObj.LGS_Assignment_Code__c;
                        newOpp.LGS_LinkInfo__c = campaignMemObj.LGS_LinkInfo__c;
                        newOpp.LGS_BrandCode__c = campaignMemObj.LGS_BrandCode__c;
                        newOpp.LGS_BrandShowroomCode__c = campaignMemObj.LGS_BrandShowroomCode__c;
                        newOpp.LGS_PartnerCode__c = campaignMemObj.LGS_PartnerCode__c;
                        newOpp.Lead_Score__c = campaignMemObj.Lead_Score__c;
                        newOpp.Lead_Score_level__c = campaignMemObj.Lead_Score_level__c;
                        newOpp.LGS_VIN_No__c = campaignMemObj.LGS_VIN_No__c;
                        newOpp.LGS_File_Upload__c = campaignMemObj.LGS_File_Upload__c;
                        newOpp.LGS_Campaign_Start_Date__c = campaignMemObj.LGS_Campaign_Start_Date__c;
                        newOpp.LGS_Campaign_End_Date__c = campaignMemObj.LGS_Campaign_End_Date__c;
                        newOpp.LGS_Child_Campaign_ID__c = campaignMemObj.LGS_Child_Campaign_ID__c;
                        newOpp.Car_Reference_No__c = campaignMemObj.Car_Reference_No__c;
                        newOpp.RTL_W2L_Campaign_Name__c = campaignMemObj.RTL_W2L_Campaign_Name__c;
                        newOpp.LGS_Partner__c = campaignMemObj.LGS_Partner__c;

                        Integer numberOfProduct =  product.numberOfProduct;
                        productNoOpptyMap.put( numberOfProduct, newOpp );
                    }

                }
            }

            try{
                if( productNoOpptyMap.values().size() > 0 )
                {
                    // system.debug('productNoOpptyMap:'+productNoOpptyMap);
                    if (!Test.isRunningTest()) {
                        insert productNoOpptyMap.values();
                    }    
                    // oppList = productNoOpptyMap.values();
                }
                
            }catch( DMLEXception e)
            {
                Database.rollback(sp);
                System.debug('CPM : '+e.getMessage()+' Line:'+e.getLineNumber());
                System.debug('DML Message : '+e.getDmlMessage(0));
                throw new AuraHandledException(e.getDmlMessage(0).unescapeHtml4());
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
                //return null;
            }

            if( productNoOpptyMap.keySet().size() > 0 )
            {
                for( Integer i : productNoOpptyMap.keySet() )
                {
                    Opportunity opptyObj = productNoOpptyMap.get(i);

                    campaignMemObj.put('RTL_RelatedOpportunity_'+i+'__c',opptyObj.Id); 

                    // Auto add product to campaign member
                    campaignMemObj.put('RTL_Product_Group_'+i+'__c', opptyObj.RTL_Product_Group__c.toUpperCase());
                    campaignMemObj.put('RTL_Sub_Group_'+i+'__c', opptyObj.RTL_Prod_SubGrp__c.toUpperCase());
                    campaignMemObj.put('RTL_Campaign_Product_'+i+'__c', opptyObj.RTL_Product_Name__c);
                    campaignMemObj.put('RTL_OfferResult_Product_'+i+'__c', productList[i-1].offerResult );
                    campaignMemObj.put('Not_Interest_Reason'+i+'__c',productList[i-1].reason); 
                    campaignMemObj.put('RTL_Opportunity_Stage_'+i+'__c',opptyObj.StageName); 
                    campaignMemObj.put('RTL_Opportunity_Status_'+i+'__c',opptyObj.RTL_Status__c); 
                    campaignMemObj.put('RTL_Opportunity_Amount_'+i+'__c',opptyObj.Amount); 
                    campaignMemObj.put('RTL_Opportunity_CloseDate_'+i+'__c',opptyObj.CloseDate);                             
        
                }
                // System.Debug('campaignMemObj:'+campaignMemObj);
                try{
                    if(campaignMemObj.Id != null){
                        update campaignMemObj;
                    }else{
                        // system.debug('Insert Campaign member : '+campaignMemObj);
                        String store = campaignMemObj.RTL_Products_Offer_String__c;
                        campaignMemObj.RTL_Products_Offer_String__c = null;
                        insert campaignMemObj;
                        updateProductOfferString(campaignMemObj,store);
                        saveLogCampaignmember(campaignMemObj);

                    }
                    
                }catch( Exception e ){
                    Database.rollback(sp);
                    System.debug(e.getMessage()+e.getLineNumber());
                    throw new AuraHandledException(e.getMessage().unescapeHtml4());
                    //return null;
                }

            }

            if(crossSellInterestedObj.size() > 0)
            {       
                saveOpportunity(crossSellInterestedObj, campaignMemObj, accId);  
            }
        }
        return 'Success';
    }

    public static String MergeConvertLeadCAMPAIGN(CampaignMember campaignMemObj, Account accObj, Lead leadObj, List<CampaignProductWrapper> productList,
    List<CampaignProductWrapper> interestedProductList, List<Object> crossSellInterestedObj )
    {
        Savepoint sp = Database.setSavepoint();
        Id conId;
        Id accId;

        if(accObj != null)
        {
            accId = accObj.Id;
        }

        try
        {
            if( campaignMemObj.ContactId == null && leadObj.Id != null && !leadObj.IsConverted  && interestedProductList.size() > 0)             
            {
                // System.debug('Convert Lead Step (MERGE ACCOUNT LEAD DETAIL PAGE) : Lead => '+leadObj.Id);
                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';
            
                //Check if Owner is not User
                List<User> userOwner = [SELECT Id FROM User WHERE Id =: leadObj.OwnerId];

                if( userOwner.size() == 0 )
                {
                    //Set Lead Owner to  Current User
                    leadObj.OwnerId = UserInfo.getUserId();
                }

                if( !validateLead(leadObj,leadObj,campaignMemObj,interestedProductList) ){
                    Database.rollback(sp);
                    return null;
                }
                // System.debug('leadObj:'+leadObj);
                update leadObj;

                List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
                                                FROM Contact WHERE AccountID =: accId
                                                ];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;
					//contactid = conId;//for redirect page                        
				}

                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(leadObj.id);
				lc.setAccountId(accId);
				lc.setContactId(conId);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
            }
            else if(campaignMemObj.ContactId == null && leadObj.Id != null && !leadObj.IsConverted  && crossSellInterestedObj.size() > 0)
            {
                List<CampaignProductWrapper> crossSellInterestList = new List<CampaignProductWrapper>();
                for (Integer i = 0; i < crossSellInterestedObj.size(); i++) {
                    // System.debug('Object'+i+' :'+ crossSellInterestedObj[i]);
                    Map<String, Object> product = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crossSellInterestedObj[i]));
                    // System.debug('product'+i+' :'+product);
                    
                    CampaignProductWrapper crossSellWrapper = new CampaignProductWrapper();
                    
                    crossSellWrapper.productGroup = String.valueOf(AbstractCoreClass.getResult('productGroup', product));
                    crossSellWrapper.productSubGroup = String.valueOf(AbstractCoreClass.getResult('productSubGroup', product));
                    crossSellWrapper.productId = String.valueOf(AbstractCoreClass.getResult('productName_Id', product));
                    crossSellWrapper.offerResult = String.valueOf(AbstractCoreClass.getResult('offerResult', product));
                    crossSellInterestList.add(crossSellWrapper);
                }

                // System.debug('Convert Lead Step (MERGE ACCOUNT LEAD DETAIL PAGE) : Lead => '+leadObj.Id);
                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';
            
                //Check if Owner is not User
                List<User> userOwner = [SELECT Id FROM User WHERE Id =: leadObj.OwnerId];

                if( userOwner.size() == 0 )
                {
                    //Set Lead Owner to  Current User
                    leadObj.OwnerId = UserInfo.getUserId();
                }

                if( !validateLead(leadObj,leadObj,campaignMemObj,crossSellInterestList) ){
                    Database.rollback(sp);
                    return null;
                }
                // System.debug('leadObj:'+leadObj);
                update leadObj;

                List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
                                                FROM Contact WHERE AccountID =: accId
                                                ];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;				                    
				}

                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(leadObj.id);
				lc.setAccountId(accId);
				lc.setContactId(conId);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
            }
        }
        catch( Exception e )
        {
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage() + ' Line :' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage().unescapeHtml4());
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
        }

        // create opp line
        Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();

        if( interestedProductList.size() > 0 ){            
            for( CampaignProductWrapper product : interestedProductList ){
                if(product.offerResult == 'Interested')
                {
                    Opportunity newOpp = new Opportunity();
                    // System.debug('RTL_Product_Group__c'+String.valueOf(product.productGroup));
                    // System.debug('RTL_Prod_SubGrp__c'+String.valueOf(product.productSubGroup));
                    // System.debug('RTL_Product_Name__c'+String.valueOf(product.productId));
                    // System.debug('accId'+accId);
                    newOpp = product.objOpp;
                    newOpp.RTL_Product_Group__c = String.valueOf(product.productGroup);
                    newOpp.RTL_Prod_SubGrp__c = String.valueOf(product.productSubGroup);
                    newOpp.RTL_Product_Name__c = String.valueOf(product.productId);                
                    newOpp.AccountId = accId;    
                    newOpp.CampaignId = campaignMemObj.CampaignId;
                    newOpp.RTL_Campaign_Code__c = campaignMemObj.Campaign.RTL_Campaign_Code_10_digits__c;
                    newOpp.RTL_Campaign_Name__c = campaignMemObj.Campaign.Name;
                    newOpp.RTL_Campaign_Start_Date__c = campaignMemObj.Campaign.RTL_Campaign_Start_Date__c;     
                    newOpp.RTL_Is_Create_From_Campaign_Member__c = true; //for except validation rule when create opp
                    
                    newOpp.RTL_Campaign_Lead_Source__c = campaignMemObj.RTL_TMB_Campaign_Source__c;
                    newOpp.RTL_Campaign_Lead_Reference__c = campaignMemObj.RTL_TMB_Campaign_Reference__c;
                    newOpp.LeadSource = campaignMemObj.LeadSource;

                    //For TBank Gap
                    if(campaignMemObj.RTL_Marketing_Code__c != null)
                    {
                        newOpp.Marketing_Code__c = campaignMemObj.RTL_Marketing_Code__c;
                    }
                    else if(campaignMemObj.RTL_Web_Unique_ID__c != null)
                    {
                        newOpp.RTL_Web_Unique_ID__c = campaignMemObj.RTL_Web_Unique_ID__c;
                    }             
                    //LGS additional Fields
                    newOpp.LGS_Assignment_Code__c = campaignMemObj.LGS_Assignment_Code__c;
                    newOpp.LGS_LinkInfo__c = campaignMemObj.LGS_LinkInfo__c;
                    newOpp.LGS_BrandCode__c = campaignMemObj.LGS_BrandCode__c;
                    newOpp.LGS_BrandShowroomCode__c = campaignMemObj.LGS_BrandShowroomCode__c;
                    newOpp.LGS_PartnerCode__c = campaignMemObj.LGS_PartnerCode__c;
                    newOpp.Lead_Score__c = campaignMemObj.Lead_Score__c;
                    newOpp.Lead_Score_level__c = campaignMemObj.Lead_Score_level__c;
                    newOpp.LGS_VIN_No__c = campaignMemObj.LGS_VIN_No__c;
                    newOpp.LGS_File_Upload__c = campaignMemObj.LGS_File_Upload__c;
                    newOpp.LGS_Campaign_Start_Date__c = campaignMemObj.LGS_Campaign_Start_Date__c;
                    newOpp.LGS_Campaign_End_Date__c = campaignMemObj.LGS_Campaign_End_Date__c;
                    newOpp.LGS_Child_Campaign_ID__c = campaignMemObj.LGS_Child_Campaign_ID__c;
                    newOpp.Car_Reference_No__c = campaignMemObj.Car_Reference_No__c;
                    newOpp.RTL_W2L_Campaign_Name__c = campaignMemObj.RTL_W2L_Campaign_Name__c;
                    newOpp.LGS_Partner__c = campaignMemObj.LGS_Partner__c;

                    Integer numberOfProduct =  product.numberOfProduct;
                    productNoOpptyMap.put( numberOfProduct, newOpp );
                }
            }
        }

        try{
            if( productNoOpptyMap.values().size() > 0 )
            {
                // system.debug('productNoOpptyMap'+productNoOpptyMap);
                if (!Test.isRunningTest()) {
                    insert productNoOpptyMap.values();
                }              
                // oppList = productNoOpptyMap.values();
            }
            
        }catch( DMLEXception e)
        {
            Database.rollback(sp);
            System.debug('CPM : '+e.getMessage()+' Line:'+e.getLineNumber());
            System.debug('DML Message : '+e.getDmlMessage(0));
            throw new AuraHandledException(e.getDmlMessage(0).unescapeHtml4());
        }

        if( productNoOpptyMap.keySet().size() > 0 )
        {
            for( Integer i : productNoOpptyMap.keySet() )
            {
                Opportunity opptyObj = productNoOpptyMap.get(i);

                campaignMemObj.put('RTL_RelatedOpportunity_'+i+'__c',opptyObj.Id); 

                // Auto add product to campaign member
                campaignMemObj.put('RTL_Product_Group_'+i+'__c', opptyObj.RTL_Product_Group__c.toUpperCase());
                campaignMemObj.put('RTL_Sub_Group_'+i+'__c', opptyObj.RTL_Prod_SubGrp__c.toUpperCase());
                campaignMemObj.put('RTL_Campaign_Product_'+i+'__c', opptyObj.RTL_Product_Name__c );
                campaignMemObj.put('RTL_OfferResult_Product_'+i+'__c', productList[i-1].offerResult );
                campaignMemObj.put('Not_Interest_Reason'+i+'__c',productList[i-1].reason); 
                campaignMemObj.put('RTL_Opportunity_Stage_'+i+'__c',opptyObj.StageName); 
                campaignMemObj.put('RTL_Opportunity_Status_'+i+'__c',opptyObj.RTL_Status__c); 
                campaignMemObj.put('RTL_Opportunity_Amount_'+i+'__c',opptyObj.Amount); 
                campaignMemObj.put('RTL_Opportunity_CloseDate_'+i+'__c',opptyObj.CloseDate);  

                // system.debug('RTL_Product_Group__c : '+opptyObj.RTL_Product_Group__c);     
                // system.debug('RTL_Prod_SubGrp__c : '+opptyObj.RTL_Prod_SubGrp__c);     
                // system.debug('RTL_Product_Name__c : '+opptyObj.RTL_Product_Name__c);                             
            }
           
            try{
                if(campaignMemObj.Id != null){
                    update campaignMemObj;
                }else{
                    // system.debug('Insert Campaign member : '+campaignMemObj);
                    String store = campaignMemObj.RTL_Products_Offer_String__c;
                    campaignMemObj.RTL_Products_Offer_String__c = null;
                    insert campaignMemObj;
                    updateProductOfferString(campaignMemObj,store);
                    saveLogCampaignmember(campaignMemObj);

                }
                
            }catch( Exception e ){
                Database.rollback(sp);
                System.debug(e.getMessage()+' Line:'+e.getLineNumber());
                throw new AuraHandledException(e.getMessage().unescapeHtml4());
                //return null;
            }

        }

        if(crossSellInterestedObj.size() > 0)
        {       
            saveOpportunity(crossSellInterestedObj, campaignMemObj, accId);  
        }

        return 'Success';
    }

    public static String NewAccConvertLeadCAMPAIGN(CampaignMember campaignMemObj, Lead leadObj, List<CampaignProductWrapper> productList,
    List<CampaignProductWrapper> interestedProductList, List<Object> crossSellInterestedObj){
        Savepoint sp = Database.setSavepoint();
        Id conId;
        Id accId;

        try{ 
            if( campaignMemObj.ContactId == null && leadObj.Id != null && !leadObj.IsConverted  && interestedProductList.size() > 0)             
            {
                // System.debug('Convert Lead Step (NEW ACCOUNT LEAD DETAIL PAGE) : Lead => '+ leadObj.Id);

                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';

                //Check if Owner is not User
                List<User> userOwner = [SELECT Id FROM User WHERE Id =: leadObj.OwnerId];

                if( userOwner.size() == 0 )
                {
                    //Set Lead Owner to  Current User
                    leadObj.OwnerId = UserInfo.getUserId();
                }

                if( !validateLead(leadObj,leadObj,campaignMemObj,interestedProductList) ){
                    Database.rollback(sp);
                    return null;
                }
                // System.debug('leadObj:'+leadObj);
                update leadObj;


                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(leadObj.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                conId = lcr.getContactId();
                accId = lcr.getAccountId();
            }  
            else if(campaignMemObj.ContactId == null && leadObj.Id != null && !leadObj.IsConverted  && crossSellInterestedObj.size() > 0)
            {
                List<CampaignProductWrapper> crossSellInterestList = new List<CampaignProductWrapper>();
                for (Integer i = 0; i < crossSellInterestedObj.size(); i++) {
                    // System.debug('Object'+i+' :'+ crossSellInterestedObj[i]);
                    Map<String, Object> product = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crossSellInterestedObj[i]));
                    // System.debug('product'+i+' :'+product);
                    
                    CampaignProductWrapper crossSellWrapper = new CampaignProductWrapper();
                    
                    crossSellWrapper.productGroup = String.valueOf(AbstractCoreClass.getResult('productGroup', product));
                    crossSellWrapper.productSubGroup = String.valueOf(AbstractCoreClass.getResult('productSubGroup', product)).toUpperCase();
                    crossSellWrapper.productId = String.valueOf(AbstractCoreClass.getResult('productName_Id', product));
                    crossSellWrapper.offerResult = String.valueOf(AbstractCoreClass.getResult('offerResult', product));
                    crossSellInterestList.add(crossSellWrapper);
                }

                // System.debug('Convert Lead Step (NEW ACCOUNT LEAD DETAIL PAGE) : Lead => '+leadObj.Id);
                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';
            
                //Check if Owner is not User
                List<User> userOwner = [SELECT Id FROM User WHERE Id =: leadObj.OwnerId];

                if( userOwner.size() == 0 )
                {
                    //Set Lead Owner to  Current User
                    leadObj.OwnerId = UserInfo.getUserId();
                }

                if( !validateLead(leadObj,leadObj,campaignMemObj,crossSellInterestList) ){
                    Database.rollback(sp);
                    return null;
                }
                // System.debug('leadObj:'+leadObj);
                update leadObj;

                List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
                                                FROM Contact WHERE AccountID =: accId
                                                ];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;
					//contactid = conId;//for redirect page                        
				}

                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();

                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(true);                
                lc.setLeadId(leadObj.id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                conId = lcr.getContactId();
                accId = lcr.getAccountId();
            }                  
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage().unescapeHtml4());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.RTL_CampaignMemberEdit_ERR002 ));
            //Update campaign member fail.
        }		
         // create opp line
         Map<Integer,Opportunity> productNoOpptyMap = new  Map<Integer,Opportunity>();

         if( interestedProductList.size() > 0 ){            
             for( CampaignProductWrapper product : interestedProductList ){
                if(product.offerResult == 'Interested')
                {
                    Opportunity newOpp = new Opportunity();
                    newOpp = product.objOpp;
                    newOpp.RTL_Product_Group__c = String.valueOf(product.productGroup);
                    newOpp.RTL_Prod_SubGrp__c = String.valueOf(product.productSubGroup);
                    newOpp.RTL_Product_Name__c = String.valueOf(product.productId);                
                    newOpp.AccountId = accId;    
                    newOpp.CampaignId = campaignMemObj.CampaignId;
                    newOpp.RTL_Campaign_Code__c = campaignMemObj.Campaign.RTL_Campaign_Code_10_digits__c;
                    newOpp.RTL_Campaign_Name__c = campaignMemObj.Campaign.Name;
                    newOpp.RTL_Campaign_Start_Date__c = campaignMemObj.Campaign.RTL_Campaign_Start_Date__c;     
                    newOpp.RTL_Is_Create_From_Campaign_Member__c = true; //for except validation rule when create opp
                    
                    newOpp.RTL_Campaign_Lead_Source__c = campaignMemObj.RTL_TMB_Campaign_Source__c;
                    newOpp.RTL_Campaign_Lead_Reference__c = campaignMemObj.RTL_TMB_Campaign_Reference__c;
                    newOpp.LeadSource = campaignMemObj.LeadSource;
    
                    //For TBank Gap
                    if(campaignMemObj.RTL_Marketing_Code__c != null)
                    {
                        newOpp.Marketing_Code__c = campaignMemObj.RTL_Marketing_Code__c;
                    }
                    else if(campaignMemObj.RTL_Web_Unique_ID__c != null)
                    {
                        newOpp.RTL_Web_Unique_ID__c = campaignMemObj.RTL_Web_Unique_ID__c;
                    }             					
                    //LGS additional Fields
                    newOpp.LGS_Assignment_Code__c = campaignMemObj.LGS_Assignment_Code__c;
                    newOpp.LGS_LinkInfo__c = campaignMemObj.LGS_LinkInfo__c;
                    newOpp.LGS_BrandCode__c = campaignMemObj.LGS_BrandCode__c;
                    newOpp.LGS_BrandShowroomCode__c = campaignMemObj.LGS_BrandShowroomCode__c;
                    newOpp.LGS_PartnerCode__c = campaignMemObj.LGS_PartnerCode__c;
                    newOpp.Lead_Score__c = campaignMemObj.Lead_Score__c;
                    newOpp.Lead_Score_level__c = campaignMemObj.Lead_Score_level__c;
                    newOpp.LGS_VIN_No__c = campaignMemObj.LGS_VIN_No__c;
                    newOpp.LGS_File_Upload__c = campaignMemObj.LGS_File_Upload__c;
                    newOpp.LGS_Campaign_Start_Date__c = campaignMemObj.LGS_Campaign_Start_Date__c;
                    newOpp.LGS_Campaign_End_Date__c = campaignMemObj.LGS_Campaign_End_Date__c;
                    newOpp.LGS_Child_Campaign_ID__c = campaignMemObj.LGS_Child_Campaign_ID__c;
                    newOpp.Car_Reference_No__c = campaignMemObj.Car_Reference_No__c;
                    newOpp.RTL_W2L_Campaign_Name__c = campaignMemObj.RTL_W2L_Campaign_Name__c;
                    newOpp.LGS_Partner__c = campaignMemObj.LGS_Partner__c;

                    Integer numberOfProduct =  product.numberOfProduct;
                    productNoOpptyMap.put( numberOfProduct, newOpp );
                }
             }
         }
 
         try{
             if( productNoOpptyMap.values().size() > 0 )
             {
                //  system.debug('productNoOpptyMap:'+productNoOpptyMap);
                 if (!Test.isRunningTest()) {
                     insert productNoOpptyMap.values();
                 }    
                 // oppList = productNoOpptyMap.values();
             }
             
         }catch( DMLEXception e)
         {
             Database.rollback(sp);
             System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
             System.debug('DML Message : '+e.getDmlMessage(0));
             throw new AuraHandledException(e.getDmlMessage(0).unescapeHtml4());
         }
 
         if( productNoOpptyMap.keySet().size() > 0 )
         {
             for( Integer i : productNoOpptyMap.keySet() )
             {
                 Opportunity opptyObj = productNoOpptyMap.get(i);
 
                 campaignMemObj.put('RTL_RelatedOpportunity_'+i+'__c',opptyObj.Id); 
 
                 // Auto add product to campaign member
                 campaignMemObj.put('RTL_Product_Group_'+i+'__c', opptyObj.RTL_Product_Group__c.toUpperCase());
                 campaignMemObj.put('RTL_Sub_Group_'+i+'__c', opptyObj.RTL_Prod_SubGrp__c.toUpperCase() );
                 campaignMemObj.put('RTL_Campaign_Product_'+i+'__c', opptyObj.RTL_Product_Name__c );
                 campaignMemObj.put('RTL_OfferResult_Product_'+i+'__c', productList[i-1].offerResult );
                 campaignMemObj.put('Not_Interest_Reason'+i+'__c',productList[i-1].reason); 
                 campaignMemObj.put('RTL_Opportunity_Stage_'+i+'__c',opptyObj.StageName); 
                 campaignMemObj.put('RTL_Opportunity_Status_'+i+'__c',opptyObj.RTL_Status__c); 
                 campaignMemObj.put('RTL_Opportunity_Amount_'+i+'__c',opptyObj.Amount); 
                 campaignMemObj.put('RTL_Opportunity_CloseDate_'+i+'__c',opptyObj.CloseDate);                             
     
             }
 
             try{
                 if(campaignMemObj.Id != null){
                     update campaignMemObj;
                 }else{
                    //  system.debug('Insert Campaign member : '+campaignMemObj);
                     String store = campaignMemObj.RTL_Products_Offer_String__c;
                     campaignMemObj.RTL_Products_Offer_String__c = null;
                     insert campaignMemObj;
                     updateProductOfferString(campaignMemObj,store);
                     saveLogCampaignmember(campaignMemObj);
 
                 }
                 
             }catch( Exception e ){
                 Database.rollback(sp);
                 System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
                 throw new AuraHandledException(e.getMessage().unescapeHtml4());
                 //return null;
             }
 
         }
 
         if(crossSellInterestedObj.size() > 0)
         {               
            saveOpportunity(crossSellInterestedObj, campaignMemObj, accId);     
         }
        return 'Success';
    }

    public static void createDoNotContact(Id customer, String period){
        try{ 
            RTL_Do_not_Contact_Info__c doNotContact = new RTL_Do_not_Contact_Info__c();
            Date dateNow = Date.today();
            doNotContact.Product_Group__c = 'All';
            doNotContact.Channel__c = 'All';
            doNotContact.Start_Date__c = dateNow;
            doNotContact.Customer__c = customer;
            if (period == '1 Year') 
            {
                doNotContact.Period__c = '1 Year';
                doNotContact.End_Date__c = dateNow.addYears(1);
            } else if(period == '6 Months'){
                doNotContact.Period__c = '	6 Months';
                doNotContact.End_Date__c = dateNow.addMonths(6);
            }
            else if(period == 'LifeTime')
            {
                doNotContact.Period__c = 'Life Time';
                Integer maxValue = Integer.valueOf(365.2425*100);
                doNotContact.End_Date__c = dateNow.addDays(maxValue);
            }
            insert doNotContact;
        }
        catch( Exception e ){
            System.debug('CRM : '+e.getMessage());
            throw new AuraHandledException(e.getMessage().unescapeHtml4());
        }
    }

    public static Boolean updateCampaignMember(CampaignMember campaignMemObj){
        campaignMemObj.No_of_Attempts__c = (campaignMemObj.No_of_Attempts__c==null) ? 0 : campaignMemObj.No_of_Attempts__c;
        campaignMemObj.No_of_Attempts__c = ( campaignMemObj.RTL_Contact_Status__c == 'Re-attempt' ) ? campaignMemObj.No_of_Attempts__c+1 : campaignMemObj.No_of_Attempts__c;
        
        String contactStatus = (campaignMemObj.RTL_Contact_Status__c==null) ? '' : campaignMemObj.RTL_Contact_Status__c;
        String contactStatusReason = (campaignMemObj.RTL_Reason__c==null) ? '' : campaignMemObj.RTL_Reason__c;
        
        campaignMemObj.RTL_Last_Contact_Status__c = contactStatus+';'+contactStatusReason+';'+System.now().format();
        campaignMemObj.Avaya_Completion_Code__c = calculateCompletionCode(campaignMemObj);
        if(campaignMemObj.RTL_Contact_Status__c != 'New' && campaignMemObj.Id != null){
            User currentUser = getCurrentUser();
            //set contact result information 
            campaignMemObj.RTL_Contact_Staff_Name__r = (campaignMemObj.RTL_Contact_Staff_Name__r==null) ? null : currentUser;
            campaignMemObj.RTL_Contact_Staff_Name__c = currentUser.Id;
            campaignMemObj.RTL_Contact_Region_Group_Head__c = currentUser.Region__c;
            campaignMemObj.RTL_Contact_Zone_Group__c = currentUser.Zone__c;
            campaignMemObj.RTL_Contact_Branch_Team_Name_Code__c = currentUser.RTL_Branch__c;
            campaignMemObj.RTL_Contact_Channel__c = currentUser.RTL_Channel__c;
            campaignMemObj.RTL_Contact_Date_Time__c = System.now();
            campaignMemObj.RTL_Contact_Date__c = System.today();

            update campaignMemObj;
            //Do not contact 
            try {
                if (String.isNotEmpty(campaignMemObj.Customer__c) && String.isNotEmpty(campaignMemObj.ContactId)) {
                    if (contactStatus == 'Do Not Contact 1year') {
                        createDoNotContact(campaignMemObj.Customer__c, '1 Year');
                    }
                    else if (contactStatus == 'Do Not Contact 6 Months') {
                        createDoNotContact(campaignMemObj.Customer__c, '6 Months');
                    }  
                    else if (contactStatus == 'Do Not Contact LifeTime') {
                        createDoNotContact(campaignMemObj.Customer__c, 'LifeTime');
                    } 
                }
            } catch (Exception e) {
                System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            }
            //
            return true;
        }else{
            insert campaignMemObj;
                //Do not contact 
            try {
                if (String.isNotEmpty(campaignMemObj.Customer__c) && String.isNotEmpty(campaignMemObj.ContactId)) {
                    if (contactStatus == 'Do Not Contact 1year') {
                        createDoNotContact(campaignMemObj.Customer__c, '1 Year');
                    }
                    else if (contactStatus == 'Do Not Contact 6 Months') {
                        createDoNotContact(campaignMemObj.Customer__c, '6 Months');
                    }  
                    else if (contactStatus == 'Do Not Contact LifeTime') {
                        createDoNotContact(campaignMemObj.Customer__c, 'LifeTime');
                    } 
                }
            } catch (Exception e) {
                System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            }
            return false;
        }        
    }

    private static Boolean validateLead(Lead leadObj, Lead oldLeadObj,CampaignMember campaignMemObj,List<CampaignProductWrapper> productList){ 
        Boolean returnCheck = true;
        List<RTL_Interested_products_c__c> updateIntProduct = new List<RTL_Interested_products_c__c> ();
        if (oldLeadObj.Status != 'Qualified'){//check if the lead status was Qualified
            returnCheck = false;
            
        }else {
            Boolean chkPrimary = false;
            List<RTL_Interested_products_c__c> interestProduct = [SELECT Id,Product_Name__c,Is_Primary__c FROM RTL_Interested_products_c__c 
                          WHERE Lead__c = :leadObj.Id order by Is_Primary__c DESC];   
            // System.debug('interestProduct:'+interestProduct); 
            if( interestProduct.size() > 0 ){                  

                //Get product id for new opp
                // system.debug('productId:'+productList.get(0).productId);
                Id productId;
                if(productList.size() > 0)
                {
                    if(productList.get(0).productId != null)
                    {
                        productId = (Id) productList.get(0).productId;
                    }
                }
                // system.debug(interestProduct);

                //Check matching product on interested product lead
                for( RTL_Interested_products_c__c each : interestProduct ){

                    if( each.Is_Primary__c ){
                        chkPrimary = each.Is_Primary__c;
                    }
                    
                    if( !chkPrimary ){
                        if( productId != null && each.Product_Name__c == productId){
                            each.Is_Primary__c = true;
                            chkPrimary = true;
                            updateIntProduct.add(each);
                            // system.debug(each);
                            break;
                        }
                    }
                }

                if(updateIntProduct.size() > 0)
                {
                    update updateIntProduct;
                }
                //update interestProduct;

                //Not Matching in interested product lead
                if(!chkPrimary){
                    createInterestedProduct(leadObj,campaignMemObj,productList);
                    // system.debug('CPM : Create interested product when product not match.');
                }
                
            }else{
                createInterestedProduct(leadObj,campaignMemObj,productList);
                // system.debug('CPM : Create interested product when product not found.');
            }
        }
        return returnCheck;
    }


    public static void createInterestedProduct(Lead leadObj,CampaignMember campaignMemObj,List<CampaignProductWrapper> productList){

        // System.debug('productList:'+productList.size()); 
        if(productList.size() > 0){
            // System.debug('productId:'+productList.get(0).productId); 
            Id productId = (Id) productList.get(0).productId;
            // system.debug('Product for new opp id : '+productId);
            if(productId != null){
                RTL_Interested_products_c__c interestedProduct = new RTL_Interested_products_c__c();
                interestedProduct.Is_Primary__c = true;
                interestedProduct.Lead__c = campaignMemObj.LeadId;
                interestedProduct.Product_Name__c = productId;
                insert interestedProduct;
            }

        }
    }

    @AuraEnabled
    public static Map<String,Object> getStageNameSchema(String productGroup)
    {
        Map<String,Object> resultList = new Map<String,Object>();
        String recordTypeByProductGroup;
        String recordTypeId;
        for(RTL_NBO_Product_Record_Type_Mapping__mdt each : getConfRecordType() )
        {
            mapConfRecordType.put(each.RTL_Product_Group__c.ToUpperCase(),each);
        }

           //Get Opportunity record type
        for(RecordType each : getRecordTypeOpportunity() ){
            mapRecordType.put(each.DeveloperName,each);
        }

        if( mapConfRecordType.containsKey( productGroup.ToUppercase() ) )
        {
            recordTypeByProductGroup = mapConfRecordType.get( productGroup.ToUppercase() ).RTL_Record_Type_DevName__c;
            if( mapRecordType.containsKey( recordTypeByProductGroup ) )
            {
                recordTypeId = mapRecordType.get( recordTypeByProductGroup ).Id;                                                     
            }                    
        }
        resultList = callGetFieldValue(null,recordTypeId,'StageName');
        resultList.put('defaultValue',mapConfRecordType.get( productGroup.ToUppercase() ).Default_Stage__c);
        resultList.put('RTL_Record_Type_DevName__c',recordTypeByProductGroup);
 
        return resultList;
    }

    public static String retrieveValueTranformation(String IDvalue){
        String newtransfromvalue = '';
        if (IDvalue != null && IDvalue != '') {
            if(IDvalue.length() == 15 || IDvalue.length() == 18) {
            string keyprefix = IDvalue.substring(0, 3);
                if (prefixSobjectMap.containsKey(keyprefix)){
                    String prefixSobject = prefixSobjectMap.get(keyprefix);
                    if (prefixSobject == 'user'  && userNameMap.containskey(IDvalue)) {
                        newtransfromvalue = userNameMap.get(IDvalue);
                    }
                    else if (prefixSobject == 'branch_and_zone__c'  && branchNameMap.containskey(IDvalue)) {
                        newtransfromvalue = branchNameMap.get(IDvalue);
                    }
                    else if (prefixSobject == 'contact' && contactNameMap.containskey(IDvalue)) {
                        newtransfromvalue = contactNameMap.get(IDvalue);
                    }
                }
            } 
            else{
            newtransfromvalue = IDvalue;
            }
        }
        return newtransfromvalue;
    }
    
    public static void updateProductOfferString(CampaignMember camMem,String storeData){
        if(storeData != null){
            camMem.RTL_Products_Offer_String__c = storeData;
            update camMem;
        }
    }

    public static void saveLogCampaignmember(CampaignMember camMem){
        
        for (String fieldName : RTL_CampaignMemberTriggerHandler.getFieldTracking()) {
            if(camMem.get(fieldName) != null) {
                String newvalue;
                newvalue = String.valueof(camMem.get(fieldName));
                //settingValueTranformation(newvalue);

                if (newvalue != null && newvalue != '') {
                    if (newvalue.length() == 15 || newvalue.length() == 18) {
                        string keyprefix = newvalue.substring(0, 3);
                        if (prefixSobjectMap.containsKey(keyprefix)) {
                            String prefixSobject = prefixSobjectMap.get(keyprefix);
        
                            if (prefixSobject == 'user') {
                            userIDset.add(newvalue);
                            } else if (prefixSobject == 'branch_and_zone__c') {
                            branchIDset.add(newvalue);
                            } else if (prefixSobject == 'contact') {
                            contactIDset.add(newvalue);
                            }
        
                        }
                    }
                }

                if (userIDset.size() > 0) {
                    for (User us : [SELECT ID, FirstName, LastName from USER WHERE ID IN:userIDset ]) {
                        userNameMap.put(us.id, us.FirstName + ' ' + us.LastName);
                    }
                }
                if (branchIDset.size() > 0) {
                    for (Branch_and_Zone__c baz : [SELECT ID, Name from branch_and_zone__c WHERE ID IN:branchIDset]) {
                      branchNameMap.put(baz.id, baz.Name);
                    }
                }
                if (contactIDset.size() > 0) {
                    for (Contact con : [SELECT ID, FirstName, LastName from Contact WHERE ID IN:contactIDset]) {
                      contactNameMap.put(con.id, con.FirstName + ' ' + con.LastName);
                    }
                }
            }
        }

        Set<String> empIDSet = new Set<String>();
        Set<ID> campaignmemberChangedIDSet = new Set<ID>();

        RTL_Campaign_Member_History__c camh = new RTL_Campaign_Member_History__c();
        camh.RTL_Campaign_Member_ID__c = camMem.id;
        camh.RTL_Campaign__c = camMem.CampaignId;
        camh.RTL_Modified_By__c = UserInfo.getUserId();            
        camh.RTL_Date__c = System.now();

        if (camMem.LeadID != null ) {
            camh.RTL_Lead__c = camMem.LeadID;
        } else if (camMem.ContactID != null) {
            camh.RTL_Contact__c = camMem.ContactID;
        }

        campaignmemberChangedIDSet.add(camMem.id);

        insert camh;
        //END saveLogHistory

        List<RTL_Campaign_Member_History_detail__c> insertHistoryDetailList = new List<RTL_Campaign_Member_History_detail__c>();

        for (String fieldName : RTL_CampaignMemberTriggerHandler.getFieldTracking()) {
            string oldvalue = null;
            string newvalue;
            if (camMem.get(fieldName) != null) {
                RTL_Campaign_Member_History_detail__c  cmhd = new RTL_Campaign_Member_History_detail__c();
                cmhd.RTL_Campaign_Member_History__c = camh.id;
                cmhd.RTL_Field_Name__c =  fieldName;
                newvalue = String.valueof(camMem.get(fieldName));

                if(fieldName == 'RTL_Assigned_Agent__c' || fieldName == 'RTL_Contact_Staff_Name__c' || fieldName == 'RTL_Assigned_Branch__c' ){ 
                    cmhd.RTL_Field_Old_Value__c = oldvalue;
                    cmhd.RTL_Field_New_Value__c = retrieveValueTranformation(newvalue);
                }
                else{
                    
                    cmhd.RTL_Field_Old_Value__c = oldvalue;
                    cmhd.RTL_Field_New_Value__c = newvalue;
                }

                insertHistoryDetailList.add(cmhd);
            }
        }
        insert insertHistoryDetailList;
    }

    @AuraEnabled
    public static String saveCrossSell(List<Object> crossSellObjs, CampaignMember campaignMemObj, List<String> opptyIdList)
    {
        try {
            List<Cross_Sell_Product__c> createCrossSellList = new List<Cross_Sell_Product__c>();
            // List<Object> crossSellObjs = (List<Object>)JSON.deserializeUntyped(jsonList);
            // System.debug('crossSellObjs : '+ crossSellObjs);
            for (Integer i = 0; i < crossSellObjs.size(); i++) {
                // System.debug('Object'+i+' :'+ crossSellObjs[i]);
                Map<String, Object> product = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crossSellObjs[i]));
                if (opptyIdList.size() > 0) {
                    product.put('opportunityId', opptyIdList[i]);
                }
                // System.debug('product'+i+' :'+product);
                Cross_Sell_Product__c crossSell = mapCrossSell(product, campaignMemObj.Id);
                createCrossSellList.add(crossSell);
            }
            // System.debug('createCrossSellList : '+ createCrossSellList);
            insert createCrossSellList;
            return JSON.serialize(createCrossSellList);
            
        } 
        catch( DMLEXception e)
        {
            System.debug('CPM : '+e.getMessage());
            System.debug('DML Message : '+e.getDmlMessage(0));
            throw new AuraHandledException(e.getDmlMessage(0).unescapeHtml4());
        }
       
    }

    public static Cross_Sell_Product__c mapCrossSell (Map<String, Object> product, String CampaignMemberId) {
        Cross_Sell_Product__c crossSell = new Cross_Sell_Product__c();
        crossSell.Product_Group__c = String.valueOf(AbstractCoreClass.getResult('productGroup', product));
        crossSell.RTL_Sub_Group__c = String.valueOf(AbstractCoreClass.getResult('productSubGroup', product)).toUpperCase();
        crossSell.Campaign_Product__c = String.valueOf(AbstractCoreClass.getResult('productName_Id', product));
        crossSell.RTL_OfferResult_Product__c = String.valueOf(AbstractCoreClass.getResult('offerResult', product));
        crossSell.OpportunityId__c = String.valueOf(AbstractCoreClass.getResult('opportunityId', product));
        crossSell.CampaignMemberId__c = CampaignMemberId;
        // System.debug('mapCrossSell : '+ crossSell);
        return crossSell;
    }

    @AuraEnabled
    public static String saveOpportunity(List<Object> crossSellInterestedObj, CampaignMember campaignMemObj, String Customer_Id)
    {
        try {
            List<Opportunity> createOpputunityList = new List<Opportunity>();
            // List<Object> crossSellObjs = (List<Object>)JSON.deserializeUntyped(jsonList);
            List<String> opptyIdList = new List<String> ();
            // System.debug('crossSellInterestedObj : '+ crossSellInterestedObj);
            // System.debug('crossSellInterestedObj size : '+ crossSellInterestedObj.size());
            for (Integer i = 0; i < crossSellInterestedObj.size(); i++) {
                // System.debug('Object'+i+' :'+ crossSellInterestedObj[i]);
                Map<String, Object> product = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crossSellInterestedObj[i]));
                // System.debug('product'+i+' :'+product);
                String recTypeId = '';
                String RecordType_DevName = String.valueOf(AbstractCoreClass.getResult('opptyRecordType_DevName', product));
                recTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get(RecordType_DevName).getRecordTypeId();
                if(product.get('offerResult') == 'Interested')
                {
                    Opportunity oppty = mapOpportunity(product, campaignMemObj, Customer_Id, recTypeId);
                    createOpputunityList.add(oppty);
                }
            }
            if (!Test.isRunningTest()) {
                insert createOpputunityList;
            }
            if (createOpputunityList.size() > 0) {
                // System.debug('opptyIdList : '+ opptyIdList);
                for (Opportunity opportunity : createOpputunityList) {
                    opptyIdList.add(opportunity.id);
                }
                saveCrossSell(crossSellInterestedObj, campaignMemObj, opptyIdList);
            }
            return JSON.serialize(createOpputunityList);
        } 
        catch( DMLEXception e)
        {
            System.debug('CPM : '+e.getMessage());
            System.debug('DML Message : '+e.getDmlMessage(0));
            throw new AuraHandledException(e.getDmlMessage(0).unescapeHtml4());
        }
        
    }

    public static Opportunity mapOpportunity (Map<String, Object> product, CampaignMember campaignMemObj, String Customer_Id, String RecordTypeId) {
        String marketingCode = '';
        String webuniqueId = '';
        // System.debug('CampaignMemberId:'+campaignMemObj);
        if(campaignMemObj.RTL_Marketing_Code__c != null)
        {
            marketingCode = campaignMemObj.RTL_Marketing_Code__c;
        }
        else if(campaignMemObj.RTL_Web_Unique_ID__c != null)
        {
            webuniqueId = campaignMemObj.RTL_Web_Unique_ID__c;
        }
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.RTL_Product_Group__c = String.valueOf(AbstractCoreClass.getResult('productGroup', product));
        opportunityObj.RTL_Prod_SubGrp__c = String.valueOf(AbstractCoreClass.getResult('productSubGroup', product));
        opportunityObj.RTL_Product_Name__c = String.valueOf(AbstractCoreClass.getResult('productName_Id', product));
        opportunityObj.StageName = String.valueOf(AbstractCoreClass.getResult('stage', product));
        opportunityObj.RTL_Status__c = String.valueOf(AbstractCoreClass.getResult('status', product));
        opportunityObj.Amount = decimal.valueOf(String.valueOf(AbstractCoreClass.getResult('amount', product)));
        opportunityObj.CloseDate = Date.valueOf(String.valueOf(AbstractCoreClass.getResult('expectedDate', product)));
        opportunityObj.AccountId = Customer_Id; //Customer.Id
        opportunityObj.RecordTypeId = RecordTypeId; //Oppty recordTypeId
        opportunityObj.LeadSource = 'Cross Sell';
        opportunityObj.Marketing_Code__c = marketingCode;
        // System.debug('mapOpputunity : '+ opportunityObj);
        //LGS additional Fields
        opportunityObj.RTL_Web_Unique_ID__c = campaignMemObj.RTL_Web_Unique_ID__c;
        opportunityObj.LGS_Assignment_Code__c = campaignMemObj.LGS_Assignment_Code__c;
        opportunityObj.LGS_LinkInfo__c = campaignMemObj.LGS_LinkInfo__c;
        opportunityObj.LGS_BrandCode__c = campaignMemObj.LGS_BrandCode__c;
        opportunityObj.LGS_BrandShowroomCode__c = campaignMemObj.LGS_BrandShowroomCode__c;
        opportunityObj.LGS_PartnerCode__c = campaignMemObj.LGS_PartnerCode__c;
        opportunityObj.Lead_Score__c = campaignMemObj.Lead_Score__c;
        opportunityObj.Lead_Score_level__c = campaignMemObj.Lead_Score_level__c;
        opportunityObj.LGS_VIN_No__c = campaignMemObj.LGS_VIN_No__c;
        opportunityObj.LGS_File_Upload__c = campaignMemObj.LGS_File_Upload__c;
        opportunityObj.LGS_Campaign_Start_Date__c = campaignMemObj.LGS_Campaign_Start_Date__c;
        opportunityObj.LGS_Campaign_End_Date__c = campaignMemObj.LGS_Campaign_End_Date__c;
        opportunityObj.LGS_Child_Campaign_ID__c = campaignMemObj.LGS_Child_Campaign_ID__c;
        opportunityObj.Car_Reference_No__c = campaignMemObj.Car_Reference_No__c;
        opportunityObj.LGS_Partner__c = campaignMemObj.LGS_Partner__c;

        return opportunityObj;
    }

    @AuraEnabled
    public static Map <String, Object> callGetFieldValue (String recordTypeApiName,String recordTypeId,String fieldName) {
        String recTypeId = '';
        if(recordTypeId == null)
        {
            recTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeApiName).getRecordTypeId();
        }
        else 
        {
            recTypeId = recordTypeId;
        }
        // system.debug('recTypeId:'+ recTypeId);
        if (String.isNotEmpty(recTypeId)) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            //String shost = System.Url.getSalesforceBaseURL().toExternalForm();
            String shost = URL.getOrgDomainURL().toExternalForm();
            String url = shost + '/services/data/v49.0/ui-api/object-info/Opportunity/picklist-values/' + recTypeId + '/'+ fieldName;
            // String url = shost + '/services/data/v49.0/ui-api/object-info/Opportunity/picklist-values/00v1s000000iBklAAE/RTL_Status__c';
            request.setEndpoint(url);   
            request.setMethod('GET');
            // set Authorization
            if (!Test.isRunningTest()) {
                request.setHeader('Authorization', 'Bearer ' + ApiCallLightningComponent.fetchUserSessionId());                     
                response = http.send(request);
            }
            else
            {
                response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"values" : [ {"label" : "Contact","value" : "Contact"}]}');
                response.setStatusCode(200);
            }
            // system.debug('response body'+ response.getBody());
            try {
                Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped( response.getBody());
                return root;
            } catch (Exception e) {
                System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
                return null;
            }
        }
        return null;
    }   

    @AuraEnabled
    public static List<Cross_Sell_Product__c> getCrossSell(String recordId){
        List<Cross_Sell_Product__c> crossSellList = [
            SELECT Id, Name, toLabel(Product_Group__c), toLabel(RTL_Sub_Group__c), Campaign_Product__c, Campaign_Product__r.Name, toLabel(RTL_OfferResult_Product__c), CampaignMemberId__c, 
            OpportunityId__c, toLabel(OpportunityId__r.StageName), toLabel(OpportunityId__r.RTL_Status__c), OpportunityId__r.Amount, OpportunityId__r.CloseDate,OpportunityId__r.Name
            FROM Cross_Sell_Product__c 
            WHERE CampaignMemberId__c=:recordId ORDER BY OpportunityId__r.Name ASC NULLS LAST];
        return crossSellList;
    }

    @AuraEnabled
    public static List<String> getProductInBOM()
    {
        List<Business_Outcome_Mapping__c> outComeList = [SELECT Id, Name, Contact_Status__c, Uncontact_Reason__c, Reason__c, Offer_Result__c, Avaya_Completion_Code__c, IsActive__c, Retail_Product_Group__c 
        FROM Business_Outcome_Mapping__c Where IsActive__c = true];

        Set<String> productGroupSet = new Set<String>();
        List<String> productGroupList = new List<String>();
        for(Business_Outcome_Mapping__c bom : outComeList)
        {
            if(bom.Retail_Product_Group__c != null)
            {
                productGroupSet.add(bom.Retail_Product_Group__c.toUpperCase());
            }
        }
        for(String productGroup : productGroupSet)
        {
            productGroupList.add(productGroup);
        }
       
        return productGroupList;
    }

    public static Map<String,Business_Outcome_Mapping__c> getBusinessOutcomeMapping()
    {
        List<Business_Outcome_Mapping__c> outComeList = [SELECT Id, Name, Contact_Status__c, Uncontact_Reason__c, Reason__c, Offer_Result__c, Avaya_Completion_Code__c, IsActive__c, Retail_Product_Group__c 
        FROM Business_Outcome_Mapping__c Where IsActive__c = true];
        Map<String,Business_Outcome_Mapping__c> outComeMap = new Map<String,Business_Outcome_Mapping__c>();
        for(Business_Outcome_Mapping__c bom : outComeList)
        {
            String product = bom.Retail_Product_Group__c;
            String offerResult = bom.Offer_Result__c;
            String reason = bom.Reason__c;
            if(bom.Contact_Status__c == 'Contact')
            {
                if(reason == null)
                {
                    reason = '';
                }
                outComeMap.put(product.toUpperCase()+offerResult+reason,bom);
            }
            else if(bom.Contact_Status__c == 'Uncontact')
            {
                outComeMap.put(bom.Contact_Status__c+bom.Uncontact_Reason__c,bom);
            }
            else 
            {
                outComeMap.put(bom.Contact_Status__c,bom);
            }
        }
        return outComeMap;
    }

    public static String calculateCompletionCode(CampaignMember campaignMemObj)
    {
        Integer numberOfProduct = 0;
        Integer count_Of_YES_Complete_Sale = 0;
        Integer count_Of_NIN_Not_Interest = 0;
        Integer count_Of_NQF_Not_Qualify = 0;
        Integer count_Of_Not_Interest_Recall = 0;
        String completionCode;

        if(campaignMemObj.RTL_Contact_Status__c == 'Contact')
        {
            //Check Number Of Product
            for( Integer i = 1 ; i <= 5 ; i++ )
            {        
                if(campaignMemObj.get('Completion_Code_'+i+'__c') != null)
                {
                    numberOfProduct++;
                }         
            }
            if(numberOfProduct > 0)
            {
                for( Integer i = 1 ; i <= 5 ; i++ )
                { 
                    if(campaignMemObj.get('Completion_Code_'+i+'__c') == 'YES Complete Sale')
                    {
                        count_Of_YES_Complete_Sale++;
                    }
                    else if(campaignMemObj.get('Completion_Code_'+i+'__c') == 'NIN Not Interest')
                    {
                        count_Of_NIN_Not_Interest++;
                    }
                    else if(campaignMemObj.get('Completion_Code_'+i+'__c') == 'NQF Not Qualify')
                    {
                        count_Of_NQF_Not_Qualify++;
                    }
                    else if(campaignMemObj.get('Completion_Code_'+i+'__c') == 'NIN Not Interest - Recall')
                    {
                        count_Of_Not_Interest_Recall++;
                    }
                }
                // System.debug('numberOfProduct:'+numberOfProduct);
                // System.debug('count_Of_YES_Complete_Sale:'+count_Of_YES_Complete_Sale);
                // System.debug('count_Of_NIN_Not_Interest:'+count_Of_NIN_Not_Interest);
                // System.debug('count_Of_NQF_Not_Qualify:'+count_Of_NQF_Not_Qualify);
                // System.debug('count_Of_Not_Interest_Recall:'+count_Of_Not_Interest_Recall);
                if(numberOfProduct == count_Of_YES_Complete_Sale)
                {
                    completionCode = 'YES Complete Sale';
                }
                else if(numberOfProduct == count_Of_NIN_Not_Interest)
                {
                    completionCode = 'NIN Not Interest';
                }
                else if(numberOfProduct == count_Of_NQF_Not_Qualify)
                {
                    completionCode = 'NQF Not Qualify';
                }
                else if(numberOfProduct == count_Of_Not_Interest_Recall)
                {
                    completionCode = 'NIN Not Interest - Recall';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall == 0)
                {
                    completionCode = 'Yes Partial';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
                {
                    completionCode = 'Yes Partial';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'Yes - Recall';
                }
                else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
                {
                    completionCode = 'NQF Not Qualify';
                }
                else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'NIN Not Interest - Recall';
                }
                else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'NIN Not Interest - Recall';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall == 0)
                {
                    completionCode = 'Yes Partial';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify == 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'Yes - Recall';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest == 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'Yes - Recall';
                }
                else if(count_Of_YES_Complete_Sale == 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'NIN Not Interest - Recall';
                }
                else if(count_Of_YES_Complete_Sale > 0 && count_Of_NIN_Not_Interest > 0 && count_Of_NQF_Not_Qualify > 0 && count_Of_Not_Interest_Recall > 0)
                {
                    completionCode = 'Yes - Recall';
                }
            }
            else {
                completionCode = null;
            }
        }
        else
        {
            Map<String,Business_Outcome_Mapping__c> outComeMap = getBusinessOutcomeMapping();

            if(campaignMemObj.RTL_Contact_Status__c == 'Uncontact')
            {
                if(outComeMap.containsKey(campaignMemObj.RTL_Contact_Status__c+campaignMemObj.RTL_Reason__c))
                {
                    completionCode = outComeMap.get(campaignMemObj.RTL_Contact_Status__c+campaignMemObj.RTL_Reason__c).Avaya_Completion_Code__c;
                }           
            }
            else
            {
                if(outComeMap.containsKey(campaignMemObj.RTL_Contact_Status__c))
                {
                    completionCode = outComeMap.get(campaignMemObj.RTL_Contact_Status__c).Avaya_Completion_Code__c;
                }
            }
        }
        // System.debug('completionCode:'+completionCode);
        return completionCode;
    }

    @AuraEnabled
    public static List<String> getReasonNotInterestFromBOM(String productGroup,String offerResult)
    {
        try
        {
            List<Business_Outcome_Mapping__c> outComeList = [SELECT Id, Name, Contact_Status__c, Uncontact_Reason__c, Reason__c, Offer_Result__c, Avaya_Completion_Code__c, IsActive__c, Retail_Product_Group__c 
            FROM Business_Outcome_Mapping__c Where IsActive__c = true AND Retail_Product_Group__c =: productGroup AND Offer_Result__c =: offerResult];

            List<String> reasonList = new List<String>();
            Map<String,Business_Outcome_Mapping__c> outComeMap = new Map<String,Business_Outcome_Mapping__c>();
            for(Business_Outcome_Mapping__c bom : outComeList)
            {
                reasonList.add(bom.Reason__c);
            }
            return reasonList;
        }
        catch(Exception e)
        {
            System.debug('Error:'+e);
            return null;
        }

    }
     
    @AuraEnabled
    public static Task getCallBack(String recordId){
        try {
            return CampaignMemberCallBackCtrl.searchExistingCallback(recordId);
        } catch (Exception e) {
            System.debug('Error:'+e);
            return null;
        }
    }  

    public static Boolean CheckDupAccountMerge(Lead objLead, Account acc){
        if(objLead.RTL_ID_Type__c == 'Other ID'){
            Boolean IDdup = false;
            Boolean Mobdup = false;
            // for (Account acc : DupAccounts) {
            //    System.debug(acc);
                            
            if(objLead.RTL_ID_Type__c == acc.ID_Type_PE__c && objLead.RTL_Citizen_Id__c == acc.ID_Number_PE__c){
                IDdup = true;
            }
            
            if(objLead.RTL_Mobile_Number__c == acc.Mobile_Number_PE__c){
                Mobdup = true;
            }               
            // System.debug('IDdup:'+IDdup); 
            // System.debug('Mobdup:'+Mobdup); 
            // }
            if(IDdup && Mobdup){
                return false;
            }
            return true;
        }else{
            return true;
        }
    }
    
    public static Boolean CheckDupAccount(Lead objLead){
		try {
			Map<String,Account> accountSet = new Map<String,Account>();

			for(Account acct : [Select Id,ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c from Account where RTL_NID__c = :getNID(objLead.RTL_Citizen_Id__c)]){
				accountSet.put(acct.ID_Type_PE__c+acct.ID_Number_PE__c,acct);    
			}

			if(accountSet.containsKey(objLead.RTL_ID_Type__c + objLead.RTL_Citizen_Id__c)){
				return false;
			}
		} catch (Exception e) {
			System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
		}
		return true;
    }
    
    public static String getNID (String idNumber) {
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }

    @AuraEnabled
    public static User getCurrentUser()
    {
        try {
            User currentUser = [SELECT Id,Profile.Name,LanguageLocaleKey,Zone__c,RTL_Branch__c,RTL_Channel__c,Region__c FROM User WHERE Id =:UserInfo.getUserId()];
            return currentUser;
        } catch (Exception e) {
            System.debug('CRM : '+e.getMessage()+' Line:'+e.getLineNumber());
            return null;
        }
        
    }

    public static Boolean getHLCALmoreDetailVisible(String prdName, String LeadSourceCollateralType){
        Boolean prodctName = false;
        // List<String> AutoLoanproduct = new list<String>{'CYC','CYB','NEW','USED'};
        if (ALPrdNameSet.contains(prdName) || (HLCALPrdNameSet.contains(prdName) && LeadSourceCollateralType != '')){
            prodctName = true ;
        }
        else    prodctName = false;
        return prodctName;
    }         
    @AuraEnabled   
    public static moreDetailProductwrapper getMoreDetailAvailableProduct(){
        moreDetailProductwrapper productwrapper = new moreDetailProductwrapper();
        productwrapper.ALProductSet = '(\''+String.join(new List<String>(ALPrdNameSet), '\',\'')+'\')';
        productwrapper.HLProductSet = '(\''+String.join(new List<String>(HLCALPrdNameSet), '\',\'')+'\')';

        System.debug('productwrapper ' + productwrapper);
        return productwrapper;
    }            
}