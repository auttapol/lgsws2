public class TestInit {
    //region
    public static Map<Id,Account> accountList {
        get
        {
            if(accountList == null){
                accountList = new Map<Id,Account>();
            }
            return accountList;
            
        }set;
    }
    
    public static Map<Id,Task> taskList {
        get
        {
            if(taskList == null){
                taskList = new Map<Id,Task>();
            }
            return taskList;
            
        }set;
    }
    
    public static Map<Id,Target__c> targetList {
        get
        {
            if(targetList == null){
                targetList = new Map<Id,Target__c>();
            }
            return targetList;
            
        }set;
    }
    
    public static User us {
        get
        {
            if(us == null){
                us = new User();
            }
            return us;
            
        }set;
    }
    public static User us2 {
        get
        {
            if(us2 == null){
                us2 = new User();
            }
            return us2;
            
        }set;
    }
    
    public static Map<Id,Call_Report__c> reportList {
        get
        {
            if(reportList == null){
                reportList = new Map<Id,Call_Report__c>();
            }
            return reportList;
            
        }set;
    }
    
    public static Map<Id,Opportunity> opportunityList {
        get
        {
            if(opportunityList == null){
                opportunityList = new Map<Id,Opportunity>();
            }
            return opportunityList;
            
        }set;
    }
    
    public static List<Contact> contactList {
        get
        {
            if(contactList == null){
                contactList = new List<Contact>();
            }
            return contactList;
            
        }set;
    }
       
    //endregion
    public static Id activitiesId;
    
    public static void createUser(Boolean SeeAllData){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'SFDC2', Email='standarduser-ii@tmbbank.com', 
                          EmailEncodingKey='UTF-8', LastName='II', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,Employee_ID__c='LA002',
                          Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                          TimeZoneSidKey='America/Los_Angeles', UserName='i2i@testorg.com');        
        User u2 = new User(Alias = 'SFDC222', Email='standarduser-ii2@tmbbank.com', 
                           EmailEncodingKey='UTF-8', LastName='II-2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,Employee_ID__c='LA004',
                           Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                           TimeZoneSidKey='America/Los_Angeles', UserName='i2i-2@testorg.com.sit');  
        us = u;
        insert u2;
        us2 = u2;
        //us2 = [select Id  from user where Id = :u2.Id];
        System.debug('::: UserId 2 : '+us2.Id +' || '+u2.Id);
        
        Prospect_Owner_Assignment__c poa = new Prospect_Owner_Assignment__c(
            Name='TEST',TMB_Staff_ID__c='LA004'
        );
        if(!SeeAllData){
            TestUtils.createAppConfig();
            createTriggerMsg();
        }
        insert poa;     
        List<RecordType> recordTypeId = [select Id from RecordType where name = 'Activities Target' limit 1];
        activitiesId = recordTypeId[0].Id;
        createCustomSettingStageApproval();
        createCustomSettingTriggerMsg();
        createCustomSettingCreatePrivilege();
    }
    
    public static void createCustomSettingStageApproval(){
        List<Stage_Approval__c> listInsert = new List<Stage_Approval__c>();
        Stage_Approval__c obj = new Stage_Approval__c(
            Name='Approval',Stage_Name__c='Approval'
        );
        Stage_Approval__c obj1 = new Stage_Approval__c(
            Name='Sent_For_Approval',Stage_Name__c='Sent_For_Approval'
        );
        listInsert.add(obj);
        listInsert.add(obj1);        
        try{
            insert listInsert;    
        }catch (DmlException e){
           
        }        
    }
    
    public static void createCustomSettingCreatePrivilege(){
        List<Account__c> triggerPrivilegeList = new List<Account__c>();
        Account__c obj = new Account__c(
            Segment__c='SS',Role__c=null
        );
        triggerPrivilegeList.add(obj);
        try{
            insert triggerPrivilegeList;    
        }catch (DmlException e){
            
        }
    }
    
    public static void createCustomSettingTriggerMsg(){
        List<Trigger_Msg__c> triggerMsgList = new List<Trigger_Msg__c>();
        Trigger_Msg__c obj = new Trigger_Msg__c(
            Name='Approval_Qualified_Prospect_Only',Description__c='error'
        );
        Trigger_Msg__c obj1 = new Trigger_Msg__c(
            Name='Duplicate_Reference_ID',Description__c='error'
        );
        Trigger_Msg__c obj2 = new Trigger_Msg__c(
            Name='Not_Found_Employee_ID',Description__c='error'
        );
        Trigger_Msg__c obj3 = new Trigger_Msg__c(
            Name='Not_Found_ID_Populated',Description__c='error'
        );
        Trigger_Msg__c obj4 = new Trigger_Msg__c(
            Name='Not_Found_RecordType',Description__c='error'
        );
        Trigger_Msg__c obj5 = new Trigger_Msg__c(
            Name='Not_Found_Segment',Description__c='error'
        );
        Trigger_Msg__c obj6 = new Trigger_Msg__c(
            Name='Not_Found_Suggested_Segment',Description__c='error'
        );
        Trigger_Msg__c obj7 = new Trigger_Msg__c(
            Name='Not_Found_Zone_Code',Description__c='error'
        );
        Trigger_Msg__c obj8 = new Trigger_Msg__c(
            Name='Permission_Create_Opportunity',Description__c='error'
        );
        Trigger_Msg__c obj9 = new Trigger_Msg__c(
            Name='Submit_Approval_Success',Description__c='error'
        );
        Trigger_Msg__c obj10 = new Trigger_Msg__c(
            Name='Reassign_Prospect',Description__c='error'
        );
        
        triggerMsgList.add(obj);
        triggerMsgList.add(obj1);
        triggerMsgList.add(obj2);
        triggerMsgList.add(obj3);
        triggerMsgList.add(obj4);
        triggerMsgList.add(obj5);
        triggerMsgList.add(obj6);
        triggerMsgList.add(obj7);
        triggerMsgList.add(obj8);
        triggerMsgList.add(obj9);
        triggerMsgList.add(obj10);
        try{
            insert triggerMsgList;    
        }catch (DmlException e){
            
        }
        
    }
    
    public static void createAccount(Integer row){
        Account a;
        recordtype prospectRec = [SELECT ID from RecordType WHERE SobjectType ='Account'
                                 AND Name ='Prospect' LIMIT 1];
        List<Account> listInsert = new List<Account>();
        for( Integer i = 0 ; i < row ; i++ ){
            a = new Account(Account_Type__c='Prospect',Name='II-ACC-'+i,Phone='5456234',RecordTypeID=prospectRec.id);
            listInsert.add(a);
        }
        
        try{
            insert listInsert;
            accountList.putAll(listInsert);
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
    }
    
    public static void createTask(List<Account> listAcc){
        Task t;
        List<Task> listTask = new List<Task>();
        ID rctypeID = [SELECT Id FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%Retail%') limit 1].Id; //Edit by : Danudath 3-11-2016
        for( Integer i = 0 ; i < listAcc.size() ; i++ ){
            t = new Task(OwnerId=UserInfo.getUserId(),
                         Subject='Call',
                         Status='Open',
                         ActivityDate = Date.today(),
                         WhatId = listAcc.get(i).Id,
                         recordtypeID = rctypeID //Edit by : Danudath 3-11-2016
                        );            
            listTask.add(t);
        }
        try{
            insert listTask;
            taskList.putAll(listTask);
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
    }
    
    public static void createTarget(List<Account> listAcc){
        User u = [select Zone__c from user where Id = :UserInfo.getUserId()];
        Target__c t;
        List<Target__c> listTarget = new List<Target__c>();
        for( Integer i = 0 ; i < 1 ; i++ ){
            t = new Target__c(OwnerId=UserInfo.getUserId(),
                              Monthly_Target_date__c = Date.today(),
                              Zone__c = u.Zone__c,
                              RecordTypeId = activitiesId
                             );            
            listTarget.add(t);            
        }
        try{
            insert listTarget;
            targetList.putAll(listTarget);
            System.debug(listTarget);
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
    }
    
    public static void createReport(List<Account> listAcc){
        Call_Report__c r;
        List<Call_Report__c> listReport = new List<Call_Report__c>();
        for( Integer i = 0 ; i < listAcc.size() ; i++ ){
            r = new Call_Report__c(OwnerId=UserInfo.getUserId(),
                                   Customer_name__c = listAcc.get(i).Id,
                                   Status__c = 'Open',
                                   Outcome__c = 'Win oppty',
                                   Date_of_Visit__c = Date.today()
                                  );    
            listReport.add(r);
        }
        try{
            insert listReport;
            reportList.putAll(listReport);
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
    }
    
    // --- Modified by Mameaw on 16 June 2016 : modified new opportunity --- //
    public static void createOpportunity(List<Account> listAcc){
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id nonCreditProduct = OpportunityRecordTypeInfo.get('Non-credit Product').getRecordTypeId();
        Id SECreditProduct = OpportunityRecordTypeInfo.get('SE Credit Product').getRecordTypeId();
        Id SENonCreditProduct = OpportunityRecordTypeInfo.get('Non-credit Product').getRecordTypeId();
        Id WBGCreditProduct = OpportunityRecordTypeInfo.get('WBG Credit Product').getRecordTypeId();
        Opportunity o;
        List<Opportunity> listOpp = new List<Opportunity>();
        for( Integer i = 0 ; i < listAcc.size() ; i++ ){
            o = new Opportunity(Name = 'opptest',RecordTypeId = SENonCreditProduct,
                                AccountId = listAcc.get(i).Id,
                                StageName = 'Analysis',
                                CloseDate = Date.today(),
                                Expected_submit_date__c = Date.today(),
                                Trigger_flag__c = true
                               );
            listOpp.add(o);
            
        }
        try{
            insert listOpp;
            opportunityList.putAll(listOpp);   
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
    }   
    public static List<AccountTeamMember> createAccountTeamMember(Integer size,Id accountId,Id userId ){
        List<AccountTeamMember> createList = new List<AccountTeamMember>();
        for( Integer i = 0 ; i < size ; i++){
            AccountTeamMember objCreate = new AccountTeamMember(
                TeamMemberRole='Leader',
                AccountId=accountId,
                UserId=userId
            );
            createList.add(objCreate);
        }
        
        try{
            insert createList;
        }catch (DmlException e){
            System.debug('error : '+e.getMessage());
        }
        return createList;
    }
    
    
    public static void createTriggerMsg(){
        List<Trigger_Msg__c> objList = new List<Trigger_Msg__c>();
        String[] stringList = new String[]{'Duplicate_Reference_ID','Permission_Create_Opportunity','Not_Found_Employee_ID','Not_Found_RecordType','Not_Found_Segment','Not_Found_Suggested_Segment','Not_Found_Zone_Code'};
            Trigger_Msg__c objMsg = new Trigger_Msg__c();
        for( Integer i = 0 ; i < stringList.size() ; i++){
            objMsg = new Trigger_Msg__c();
            objMsg.isError__c = false;
            objMsg.Name = stringList[i];
            objMsg.Description__c =  stringList[i];
            objList.add(objMsg);
        }
        insert objList;
        
    }
    
    public static List<Contact> createContacts(Integer size,ID AccountId,Boolean doInsert ){
        List<Contact> contactsToCreate = new List<Contact>();
        for(Integer i=0;i<size;i++){
            Contact cont = new Contact();
            cont.AccountId = AccountId;
            cont.Salutation = 'Mr.';
            cont.LastName = 'contact_'+i; 
            //cont.Mobile_No_Temp__c = '0813259784';
            //cont.First_Name_Temp__c = 'TestContact'+i;
            //cont.Last_Name_Temp__c = 'Test';
            //cont.Office_No_Temp__c = '02485654';
            cont.Date_of_Birth__c = Date.today();
            //cont.Fax_No_Temp__c = '05478121';
            cont.Position__c = 'position1';
            //cont.Email_Temp__c = 'testcontact@gmail.com';
            //cont.Customer_Age__c = 32;
            cont.Value_Style__c = 'Risk Awareness';
            cont.Decision_Map__c = 'User';
            cont.Product_Decision__c = '';
            cont.Description__c = 'contact description';                
            contactsToCreate.add(cont);
        }
        contactList = contactsToCreate;
        
        if(doInsert){
            insert contactsToCreate;
        }
        return contactsToCreate;
    }
    
    /*
public static void createOpportunityHistory(List<Opportunity> listOpps){
OpportunityHistory o;
List<OpportunityHistory> listOppsHis = new List<OpportunityHistory>();
for( Integer i = 0 ; i < listOpps.size() ; i++ ){
o = new OpportunityHistory();
listOppsHis.add(o);
}
try{
insert listOppsHis;
opportunityList.putAll(listOppsHis);
}catch (DmlException e){
System.debug('error : '+e.getMessage());
}
}
*/
    public static void resetData(){
        accountList = null;
        taskList = null;
        opportunityList = null;
        reportList = null;
    }
    
    
}