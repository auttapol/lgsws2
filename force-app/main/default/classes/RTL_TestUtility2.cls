@isTest
public with sharing class RTL_TestUtility2 {
    public static Datetime onedayolder = Datetime.now().addDays(-1); //set a date to yesterday
    public static RecordType outboundTaskRecordType = [select Id from RecordType where developername='RTL_Retail_Outbound_Phone_Call' and SobjectType = 'Task' and IsActive = true limit 1];
    public static final Id RTL_API_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Retail Integration API Only' LIMIT 1].Id;
    
    public static void createNewLeadTask(Id leadId, Boolean doInsert) {
        Task taskObj = new Task();
        taskObj.Subject = 'test new lead task';
        taskObj.RTL_Web_ID__c = 'Test0';
        taskObj.Status='Completed';
        taskObj.RTL_Callout_Phone__c = '1111111111';
        taskObj.RTL_Success_Indicator__c = true;
        taskObj.RTL_Result_Detail__c = 'Success';
        taskObj.RTL_Result_Business__c = 'Contact-Buy';
        taskObj.RTL_Channel__c = 'Contact Center';
        taskObj.RTL_Sub_Channel__c = 'Outbound-Outbound';
        taskObj.RTL_Contact_Center_Modified_Date__c = datetime.now().addHours(-100);//earlier than RTL_NBO_History__c.RTL_Product_Branch_Latest_Modified_Date__c
        taskObj.RTL_NBO_Product_External_ID__c = '001p000000CKy8AAD' + '00';
        taskObj.RTL_Agent__c = '11111';
        taskObj.RecordTypeId = outboundTaskRecordType.id;
        if(doInsert) {
            insert taskObj;
        }
    }     
    
    public static void createConvertedLeadTask(Id leadId, Boolean doInsert) {
        Task taskObj = new Task();
        taskObj.Subject = 'test converted lead task';
        taskObj.WhoID = leadId;
        taskObj.Status='Completed';
        taskObj.RTL_Agent__c = '11111';
        taskObj.RTL_Callout_Phone__c = '2222222222';
        taskObj.RTL_Success_Indicator__c = false;
        taskObj.RTL_Result_Detail__c = 'ไม่มีสัญญาณตอบรับ';
        taskObj.RTL_Result_Business__c = 'Uncontact';
        taskObj.RTL_Channel__c = 'Contact Center';
        taskObj.RTL_Sub_Channel__c = 'Outbound-Outsource';
        taskObj.RTL_Contact_Center_Modified_Date__c = datetime.now().addHours(1);//newer than RTL_NBO_History__c.RTL_Product_Branch_Latest_Modified_Date__c
        taskObj.RTL_NBO_Product_External_ID__c = '001p000000CKy8AAD' + '11';
        if(doInsert) {
            insert taskObj;
        }
    }        
    
    public static void createAccountTask(String extAcctId, String externalNBOId, Boolean doInsert) {
        Task taskObj = new Task();
        taskObj.Subject = 'test account task';
        taskObj.RTL_TMB_Customer_ID_PE__c = extAcctId;
        taskObj.Status='Completed';
        taskObj.RTL_Callout_Phone__c = '3333333333';
        taskObj.RTL_Success_Indicator__c = false;
        taskObj.RTL_Result_Detail__c = 'Buy C2G - โปรโมชั่นน่าสนใจ';
        taskObj.RTL_Result_Business__c = 'Contact Not Buy';  
        taskObj.RTL_NBO_External_ID__c = externalNBOId;
        taskObj.RTL_Channel__c = 'Contact Center';
        taskObj.RTL_Sub_Channel__c = 'Call Me Now';
        taskObj.RTL_Contact_Center_Modified_Date__c = datetime.now().addHours(1);//newer than RTL_NBO_History__c.RTL_Product_Branch_Latest_Modified_Date__c
        taskObj.RTL_NBO_Product_External_ID__c = '001p000000CKy8AAD' + '00';
        taskObj.RTL_Sub_Reason__c = 'Others';
        taskObj.RTL_Agent__c = '11111';
        taskObj.RecordTypeId = outboundTaskRecordType.id;
            
        if(doInsert) {
            insert taskObj;
        }
    }  
    
    public static List<RTL_NBO_History__c> createNBOHistoryAndProductValid(Integer size, String externalAccctId, Boolean doInsert) {
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        RTL_NBO_History__c nboHistory = null;
        RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'Branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now(); 
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        RTL_NBO_History__c nboHis = null;
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAD%'];
        for(Integer i = 0; i<size;i++) {
            nboHis = nboHistoryList.get(i);
            nbohistoryproduct = new RTL_NBO_History_Product__c();
            nbohistoryproduct.RTL_Related_NBO__c = nboHis.Id;          
            nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
            nbohistoryproduct.RTL_Product_Group__c = 'Deposit';
            if (i == 1)  nbohistoryproduct.RTL_Product_SubGroup__c = 'Deposit TestSubgroup';
            if (i == 2) nbohistoryproduct.RTL_Product__c = 'Deposit Product';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + i;
            nbohistoryproduct.RTL_Offering_Channel__c = 'Branch';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        return nboHistoryList;
    }
    
    public static List<RTL_NBO_History__c> createNBOHistoryAndProductValid2(Integer size, String externalAccctId, Boolean doInsert) {
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        RTL_NBO_History__c nboHistory = null;
        RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'Branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now(); 
            nboHistory.RTL_Customer_Name__c = externalAccctId;
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        RTL_NBO_History__c nboHis = null;
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAD%'];
        for(Integer i = 0; i<size;i++) {
            nboHis = nboHistoryList.get(i);
            nbohistoryproduct = new RTL_NBO_History_Product__c();
            nbohistoryproduct.RTL_Related_NBO__c = nboHis.Id;          
            nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
            nbohistoryproduct.RTL_Product_Group__c = 'Deposit';
            if (i == 1)  nbohistoryproduct.RTL_Product_SubGroup__c = 'Deposit TestSubgroup';
            if (i == 2) nbohistoryproduct.RTL_Product__c = 'Deposit Product';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + i;
            nbohistoryproduct.RTL_Offering_Channel__c = 'Branch';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        return nboHistoryList;
    }
    
    public static List<RTL_NBO_History__c> createNBOHistoryAndProductValidByProductGroup(Integer size, String AccctId,String productGroup, Boolean doInsert) {
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        RTL_NBO_History__c nboHistory = null;
        RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAD' + i;
            //nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_NBO_Group__c = productGroup;
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'Branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now(); 
            nboHistory.RTL_Customer_Name__c = AccctId;
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        RTL_NBO_History__c nboHis = null;
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAD%'];
        for(Integer i = 0; i<size;i++) {
            nboHis = nboHistoryList.get(i);
            nbohistoryproduct = new RTL_NBO_History_Product__c();
            nbohistoryproduct.RTL_Related_NBO__c = nboHis.Id;          
            nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
            nbohistoryproduct.RTL_Product_Group__c = productGroup;
            if (i == 1) nbohistoryproduct.RTL_Product_SubGroup__c = productGroup+' TestSubgroup';
            if (i == 2) nbohistoryproduct.RTL_Product__c = productGroup +' Product';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + i;
            nbohistoryproduct.RTL_Offering_Channel__c = 'Branch';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        return nboHistoryList;
    } 
    
    public static List<RTL_NBO_History__c> createNBOHistoryAndProductInvalid(Integer size, String externalAccctId, Boolean doInsert) {
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
        RTL_NBO_History__c nboHistory = null;
        RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO invalid product test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAF' + i;
            nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAF' + i;
            //nboHistory.RTL_Campaign_Name__c = 'campaign' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now(); 
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now();
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAF%'];
        for(RTL_NBO_History__c nboHis: nboHistoryList){
            nbohistoryproduct = new RTL_NBO_History_Product__c();
            nbohistoryproduct.RTL_Related_NBO__c = nboHis.Id;
            nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
            nbohistoryproduct.RTL_Product_Group__c = 'invaid product group';
            nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + '0';
            nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
            insert nboHistoryProductList;
        }        
        return nboHistoryList;
    }
    
    
    
    public static List<RTL_NBO_History__c> createNBOHistoryOnly(Integer size, Id externalAccctId, Boolean doInsert) {
        List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
        RTL_NBO_History__c nboHistory = null;
        for(Integer i = 0; i<size;i++){
            nboHistory = new RTL_NBO_History__c();
            nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
            nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAE' + i;
            nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
            nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
            nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
            //nboHistory.RTL_Campaign_Name__c = 'campaign' + i;
            nboHistory.RTL_Valid_From__c = Date.today();
            nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
            nboHistory.RTL_TMB_Customer_ID_PE__c = externalAccctId;
            nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
            nboHistory.RTL_Channel__c = 'branch';
            nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
            nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now(); 
            nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now();
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
            insert nboHistoryList;
        }
        return nboHistoryList;
    }
    
    public static List<RTL_HouseHold__c> createHousehold(Integer size, Boolean doInsert,User owner) {
        List<RTL_HouseHold__c> householdList = new List<RTL_HouseHold__c>();
        RTL_HouseHold__c household = null;
        for(Integer i = 0; i<size;i++){
            household = new RTL_HouseHold__c();
            household.Name = 'Household' + i;
            household.RTL_Benefit_Package__c = 'Wealth Package 1';
            household.RTL_Remarks__c = 'Remarks';
            household.RTL_Status__c = 'New';
            household.RTL_RM__c = owner.id;
            householdList.add(household);
        }
        if(doInsert){
            insert householdList;
        }
        return householdList;
    }
    
    public static List<RTL_HouseHold__c> createHouseholdwithPrimaryMember(Integer size, Boolean doInsert,User owner,Account acct) {
        List<RTL_HouseHold__c> householdList = new List<RTL_HouseHold__c>();
        List<RTL_HouseHold_Member__c> memberList = new List<RTL_HouseHold_Member__c>();
        RTL_HouseHold__c household = null;
        RTL_HouseHold_Member__c member = null;
        
        for(Integer i = 0; i<size;i++){
            household = new RTL_HouseHold__c();
            household.Name = 'Household' + i;
            household.RTL_Benefit_Package__c = 'Wealth Package 1';
            household.RTL_Remarks__c = 'Remarks';
            household.RTL_Status__c = 'New';
            household.RTL_RM__c = owner.id;
            householdList.add(household);
        }
        if(doInsert){
            insert householdList;
        }
        for(RTL_HouseHold__c hh : householdList){
            member = new RTL_HouseHold_Member__c();
            member.RTL_HouseHold__c = hh.id;
            member.RTL_Household_Member_Name__c = acct.id;
            member.RTL_Primary__c = true;
            member.RTL_Benefit__c = true;
            member.RTL_Status__c = 'New';
            memberList.add(member);
        }
        if(doInsert){
            insert memberList;
        }
        return householdList;

    }
    
    public static RTL_HouseHold_Member__c createHouseholdMember(Boolean doInsert,Id householdId,Account acct) {
        RTL_HouseHold_Member__c member = null;
        member = new RTL_HouseHold_Member__c();
        member.RTL_HouseHold__c = householdId;
        member.RTL_Household_Member_Name__c = acct.id;
        member.RTL_Status__c = 'New';
        member.RTL_Relationship__c = 'คู่สมรส';
        member.RTL_Benefit__c = false;
        
        if(doInsert){
            insert member;
        }
        return member;

    }
    
    public static User createRetailAPITestUser(Boolean doInsert) {
        User retailUser = new User(FirstName='retail', LastName='test api user', 
                                UserName='rtl_testapiuser@tmbbank.com',
                                Email='rtl_testapiuser@tmbbank.com', Alias='APIUser',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_API_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                RTL_Branch_Code__c='001', Region_Code__c = '002', Zone_Code__c = '003',
                                Employee_ID__c='22222', RTL_Branch__c='RTLQ_001 (001)', RTL_Channel__c = 'Branch');

        
        if(doInsert) insert retailUser;
        return retailUser;
    }

    public static void createOppRecordTypeMapping(){
        Opportunity_Recordtype_Mapping__c recMapping = new Opportunity_Recordtype_Mapping__c
                                                                                (Name = 'RetailDepositStage',Product_Group__c = 'Deposit',Record_Type__c='Retail Deposit',Stage__c='Prospect');
        insert recMapping;
    }
    
    public static List<RTL_Household_Member__c> getHouseholdMember(String householdId){
        List<RTL_Household_Member__c> memberToReturn;
        memberToReturn = [SELECT ID,Name,RTL_Household_Member_Name__c,RTL_TMB_Customer_ID_PE__c,
                                 RTL_Primary__c,RTL_Benefit__c,RTL_Relationship__c,RTL_Status__c 
                                 FROM RTL_Household_Member__c WHERE RTL_Household__c =:householdId];
        return memberToReturn;
    }
    
    public static List<RTL_Household_History_and_Approval__c> getHouseholdHistoryList(String householdId){
        List<RTL_Household_History_and_Approval__c> historyToReturn;
        
        historyToReturn = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__c ,RTL_Prev_Value__c ,
                            RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                            RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c
                            FROM RTL_Household_History_and_Approval__c WHERE RTL_Household__c =:householdId];
        
        return historyToReturn;
    }
    
    public static User createRetailAPITestUser2(Boolean doInsert) {
        User retailUser = new User(FirstName='retail', LastName='test api user2', 
                                UserName='rtl_testapiuser2@tmbbank.com',
                                Email='rtl_testapiuser2@tmbbank.com', Alias='APIUser2',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_API_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                RTL_Branch_Code__c='111', Region_Code__c = '222', Zone_Code__c = '333',
                                Employee_ID__c='11111', RTL_Branch__c='RTLQ_111 (111)', RTL_Channel__c = 'Contact Center');

        
        if(doInsert) insert retailUser;
        return retailUser;
    } 
    
    public static void createOpportunityRecordTypeMapping(){
        List<Opportunity_Recordtype_Mapping__c> oppRecTypeList = new List<Opportunity_Recordtype_Mapping__c>();
        Opportunity_Recordtype_Mapping__c oppRecType1 = new Opportunity_Recordtype_Mapping__c();
        oppRecType1.Name = 'RetailBancassuranceStage';
        oppRecType1.Product_Group__c = 'Bancassurance';
        oppRecType1.Record_Type__c = 'Retail Bancassurance';
        oppRecType1.Stage__c = 'Prospect (BA)';
        oppRecTypeList.add(oppRecType1);
        Opportunity_Recordtype_Mapping__c oppRecType2 = new Opportunity_Recordtype_Mapping__c();
        oppRecType2.Name = 'RetailCardandRDCStage';
        oppRecType2.Product_Group__c = 'Credit Card & RDC';
        oppRecType2.Record_Type__c = 'Retail Card and RDC';
        oppRecType2.Stage__c = 'Prospect';
        oppRecTypeList.add(oppRecType2);
        Opportunity_Recordtype_Mapping__c oppRecType3 = new Opportunity_Recordtype_Mapping__c();
        oppRecType3.Name = 'RetailDepositStage';
        oppRecType3.Product_Group__c = 'Deposit';
        oppRecType3.Record_Type__c = 'Retail Deposit';
        oppRecType3.Stage__c = 'Prospect';
        oppRecTypeList.add(oppRecType3);
        Opportunity_Recordtype_Mapping__c oppRecType4 = new Opportunity_Recordtype_Mapping__c();
        oppRecType4.Name = 'RetailInvestmentStage';
        oppRecType4.Product_Group__c = 'Investment';
        oppRecType4.Record_Type__c = 'Retail Investment';
        oppRecType4.Stage__c = 'Prospect(Investment)';
        oppRecTypeList.add(oppRecType4);
        Opportunity_Recordtype_Mapping__c oppRecType5 = new Opportunity_Recordtype_Mapping__c();
        oppRecType5.Name = 'RetailLoansStage';
        oppRecType5.Product_Group__c = 'Loan';
        oppRecType5.Record_Type__c = 'Retail Loans';
        oppRecType5.Stage__c = 'Prospect(Loans)';
        oppRecTypeList.add(oppRecType5);
        Opportunity_Recordtype_Mapping__c oppRecType6 = new Opportunity_Recordtype_Mapping__c();
        oppRecType6.Name = 'RetailOthersStage';
        oppRecType6.Product_Group__c = 'Others';
        oppRecType6.Record_Type__c = 'Retail Others';
        oppRecType6.Stage__c = 'Prospect Others';
        oppRecTypeList.add(oppRecType6);
        Opportunity_Recordtype_Mapping__c oppRecType7 = new Opportunity_Recordtype_Mapping__c();
        oppRecType7.Name = 'RetailRetentionsStage';
        oppRecType7.Product_Group__c = 'Loan Retention';
        oppRecType7.Record_Type__c = 'Retail Retentions';
        oppRecType7.Stage__c = 'Prospect(Retention)';
        oppRecTypeList.add(oppRecType7);
        
        insert oppRecTypeList;
    }
    
}