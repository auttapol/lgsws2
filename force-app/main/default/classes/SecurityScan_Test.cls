@isTest
public class SecurityScan_Test {

    public static final Id Channel_Sales_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;
    public static final Id RM_Cockpit_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Wealth Management RM Cockpit' LIMIT 1].Id;
    public static Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();

    @testSetup static void setup() {
        TestUtils.createAppConfig();
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        List<User> userList = new List<User>();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        //insert user for run as
        User newUser = new User(FirstName = 'Test' , LastName = 'Man', 
                UserName='testMan@tmbbank.com',
                Email='testman@gmail.com', Alias='Testtmb',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb',
                ProfileId = Channel_Sales_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM01');
        userList.add(newUser);
        User newUser2 = new User(FirstName = 'Test' , LastName = 'Man2', 
                UserName='testMan2@tmbbank.com',
                Email='testman2@gmail.com', Alias='Testtmb2',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb2',
                ProfileId = RM_Cockpit_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM02');
        userList.add(newUser2);
        insert userList;
        
        List<Data_Security_Matrix__c> dsmList = new List<Data_Security_Matrix__c>();
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Demographic (Low)';
        dsm.Profile_Name__c = 'TMB System Administrator';
        dsm.Data_Matrix_Key__c = 'TMB System AdministratorRtlCust:Customer Demographic (Low)';
        dsmList.add(dsm);
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Demographic (Low)';
        dsm2.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm2.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Customer Demographic (Low)';
        dsmList.add(dsm2);
        Data_Security_Matrix__c dsm3 = new Data_Security_Matrix__c();
        dsm3.Access_Type__c = 'All';
        dsm3.Section_Name__c = 'RtlCust:Sales Support Information';
        dsm3.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm3.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Sales Support Information';
        dsmList.add(dsm3);
        Data_Security_Matrix__c dsm4 = new Data_Security_Matrix__c();
        dsm4.Access_Type__c = 'All';
        dsm4.Section_Name__c = 'RtlCust:Contact Number and Email Address';
        dsm4.Profile_Name__c = 'TMB Retail Channel Sales';
        dsm4.Data_Matrix_Key__c = 'TMB Retail Channel SalesRtlCust:Contact Number and Email Address';
        dsmList.add(dsm4);
        Data_Security_Matrix__c dsm5 = new Data_Security_Matrix__c();
        dsm5.Access_Type__c = 'Authorize Only';
        dsm5.Section_Name__c = 'RtlCust:Sales Support Information';
        dsm5.Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit';
        dsm5.Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Sales Support Information';
        dsmList.add(dsm5);
        Data_Security_Matrix__c dsm6 = new Data_Security_Matrix__c();
        dsm6.Access_Type__c = 'No Access';
        dsm6.Section_Name__c = 'RtlCust:Contact Number and Email Address';
        dsm6.Profile_Name__c = 'TMB Retail Wealth Management RM Cockpit';
        dsm6.Data_Matrix_Key__c = 'TMB Retail Wealth Management RM CockpitRtlCust:Contact Number and Email Address';
        dsmList.add(dsm6);
        insert dsmList;
    }
    //mock custom metadata

    @IsTest static void testgetAllSection1 () {
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan@tmbbank.com'];
        
        System.runAs(u){
            String dataHidden = Label.Data_Condition_Hidden_Text;
            List<String> fields = new List<String>{ 'FATCA_Form_Completed__c', 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c', 'RecordTypeId'}; 
            List<String> fieldstranslate = new List<String>{};
            List<Account> accList = createAccounts(1, true);
            Map<String, Object> param = getDescribeFieldResultMock(accList.get(0).Id, fields, fieldstranslate);     
            //หลังจากส่ง
            Test.startTest();
            Object returnData = SecurityScan.applySecurityMatrix( param, accList.get(0).Id, fields, fieldstranslate);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnData));
            Map<String, Object> searchKeyMap = new Map<string, Object>();
            for(String key : m.keyset()){
                searchKeyMap = (Map<string,Object>) m.get(key);
                if(searchKeyMap.get('isAccessible') == false){
                    System.assertEquals(dataHidden, searchKeyMap.get('value'));
                }
            }
            Test.stopTest();
        }
    }

    @IsTest static void testgetAllSection2 () {
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan2@tmbbank.com'];
        
        System.runAs(u){
            String dataHidden = Label.Data_Condition_Hidden_Text;
            List<String> fields = new List<String>{ 'Email_Address_PE__c', 'FATCA_Form_Completed__c', 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c', 'RecordTypeId'}; 
            List<String> fieldstranslate = new List<String>{};
            List<Account> accList = createAccounts(1, true);
            Map<String, Object> param = getDescribeFieldResultMock(accList.get(0).Id, fields, fieldstranslate);     
            //หลังจากส่ง
            Test.startTest();
            Object returnData = SecurityScan.applySecurityMatrix( param, accList.get(0).Id, fields, fieldstranslate);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(returnData));
            Map<String, Object> searchKeyMap = new Map<string, Object>();
            for(String key : m.keyset()){
                searchKeyMap = (Map<string,Object>) m.get(key);
                if(searchKeyMap.get('isAccessible') == false){
                    System.assertEquals(dataHidden, searchKeyMap.get('value'));
                }
            }
            Test.stopTest();
        }
    }
    @IsTest static void testgetVerifyByField(){
        User u = [SELECT Id, UserName FROM User WHERE UserName = 'testMan@tmbbank.com'];
        System.runAs(u){
            List<Account> accList = createAccounts(1, true);
            Test.startTest();
            Object isVisible = SecurityScan.getVerifyByField('TMB_Customer_ID_PE__c', 'TMB Retail Channel Sales', accList.get(0).Id);
            Test.stopTest();
            System.assertEquals(true, isVisible);
        }
    }

    public static Map<String, Object> getDescribeFieldResultMock(String recordId, List<String> fields, List<String> fields_translate){
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
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }

    public static List<Account> createAccounts(Integer size , Boolean doInsert)
    {
        List<Account> accountsToCreate = new List<Account>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        for(Integer i =1 ; i<=size ;i++)
        {   
            Account acct = new Account(); 
            acct.Name = 'Test RTL Account '+i;
            acct.First_Name_PE__c = 'Test';
            acct.Last_name_PE__c = 'RTL Account '+i;
            acct.Phone ='1111111111';
            acct.Mobile_Number_PE__c  = '1111111111';
            acct.ID_Type_PE__c = 'Passport ID';
            acct.ID_Number_PE__c = '11111' + i;
            acct.RTL_NID__c = '1111' + i;
            acct.RecordType = recordType;
            acct.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAD' + i;
            acct.RTL_RM_Name__c = '00102';
            acct.RecordTypeId = acctRT;
            
            accountsToCreate.add(acct);    
        }
        if(doInsert){
                insert accountsToCreate;
        }
        return accountsToCreate;
    }    
}