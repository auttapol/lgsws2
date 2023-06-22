public class CaseTriggerHandler {

    static List<Service_Type_Matrix__c> serviceMatrix = New List<Service_Type_Matrix__c>();
    static List<Case> CaseForUpdate = New List<Case>();
    static Map<String,Service_Type_Matrix__c> ServiceMatrixMap = new Map<String, Service_Type_Matrix__c>();
    static List<Service_Type_Matrix__c> allMatrix;
    static Map<String,ID> mapTeamName = New Map<String,ID>();
    static List<Group> teamName;
    static Id KYCRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('KYC System').getRecordTypeId();
    public static User currUser {
        get {
            if(currUser == null) {
                List<User> currUserLst = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
                if(currUserLst.size() > 0) {
                    currUser = currUserLst.get(0);
                }
            }
            return currUser;
        } set;
    }
    public static List<String> BDM_Profile_List {
        get {
            if(BDM_Profile_List == null) {
                if(AppConfig__c.getValues('KYC BDM Profile list') == null) {
                    BDM_Profile_List = new List<String>{'TMB BDM Profile','TMB ABDM Profile'};
                } else {
                    BDM_Profile_List = AppConfig__c.getValues('KYC BDM Profile list').Value__c.split(';');
                }
            }
            return BDM_Profile_List;
        } 
        set;
    }
    public static List<String> SEPM_Profile_List {
        get {
            if(SEPM_Profile_List == null) {
                if(AppConfig__c.getValues('KYC SEPM Profile list') == null) {
                    SEPM_Profile_List = new List<String>{'TMB SEPM Profile'};
                } else {
                    SEPM_Profile_List = AppConfig__c.getValues('KYC SEPM Profile list').Value__c.split(';');
                }
            }
            return SEPM_Profile_List;
        } 
        set;
    }
    public static String KYC_SUB_4G {
        get {
            if(KYC_SUB_4G == null && AppConfig__c.getValues('KYC_SUB_4G') != null) {
                KYC_SUB_4G = AppConfig__c.getValues('KYC_SUB_4G').Value__c;
            } 
            return KYC_SUB_4G;
        } set;
    }
    // static List<String> BDM_Profile_List = AppConfig__c.getValues('KYC BDM Profile list').Value__c.split(';');
    // static List<String> SEPM_Profile_List = AppConfig__c.getValues('KYC SEPM Profile list').Value__c.split(';');
    public static Set<String> KYCCaseAdminProfile {
        get {
            if(KYCCaseAdminProfile == null) {
                KYCCaseAdminProfile = new Set<String>();
                Map<String, KYC_Case_Admin_Profile__mdt> kycProfile = KYC_Case_Admin_Profile__mdt.getAll();
                for(KYC_Case_Admin_Profile__mdt profile : kycProfile.values()) {
                    KYCCaseAdminProfile.add(profile.Profile_Name__c);
                }
            }
            return KYCCaseAdminProfile;
        }
        set;
    }

    static boolean isAutoSMS = false;
    static boolean isAssignedSLAByHop = false;
    private static Boolean checkLoopSLAByHop = true;
    static Map<String,Schema.SObjectField> ServicefieldMaps = New Map<String,Schema.SObjectField>();
    static list<SLA_By_Hop__c> slaByHopAddList;
    static Map<ID,List<SLA_By_Hop__c>> mapSLAbyHop = new Map<ID,List<SLA_By_Hop__c>>();
    static Map<ID,List<SLA_Per_Owner__c>> mapSLAPerOwner = new Map<ID,List<SLA_Per_Owner__c>>();

    //CR Non-Voice
    static Map<String,Skill_Master__c> skillMasterMap = new Map<String, Skill_Master__c>();
    static List<Skill_Master__c> skillMasterList;
    static List<String> subjectKeyword = new List<String>();

    //Non-Voice Case Origin Mapping
    public static List<Case_Origin_Mapping__mdt> appMeta_CaseOrigin_Mapping{
    get{
        if(appMeta_CaseOrigin_Mapping==null){
            appMeta_CaseOrigin_Mapping = [SELECT Id, Label,Origin__c,Keyword__c FROM Case_Origin_Mapping__mdt ]; 
        }
        return appMeta_CaseOrigin_Mapping;
    }
    set;
    }

    public static Recordtype SErecordType {get{
        if(SErecordType==null){
            SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center'];

        }
        return SErecordType;

    }set;}
    
    static List<Entitlement> EntitlementID;
    static Map<String,ID> EntitlementMap = New Map<String, ID>();
    static Boolean FlagePrepareData = true;
    static Map<ID,String> queueMapName = New Map<ID,String>();
    static Map<ID,String> userMapName = New Map<ID,String>();
    static Boolean checkLoop = true;
    
    static Map<ID,String> userMapAdminName = New Map<ID,String>();
  
    static Boolean isUpdateCS_Service = true; //Check if Change Category = Condition_CS or Service Request _CS, not update case owner

    Static List<Case_Assignment_Round_Robin__c> list_Round_Robin = New List<Case_Assignment_Round_Robin__c>();
    Static Map<String, String> map_UW_Queue = New Map<String,String>();
    Static Map<String, Case_Assignment_Round_Robin__c> map_Round_Robin = New Map<String,Case_Assignment_Round_Robin__c>();

    //Setting Auto send SMS and Closed case
    Static List<Auto_SMS_Setting__mdt> autoSMSMetaList = New List<Auto_SMS_Setting__mdt>();
    Static Map<String,Auto_SMS_Setting__mdt> autoSMSMetaMap = New Map<String,Auto_SMS_Setting__mdt>();


    public static BusinessHours standardHoursId {get{
        if(standardHoursId==null){
            standardHoursId = [Select ID, Name from BusinessHours where name = 'Service' limit 1];

        }
        return standardHoursId;

    }set;}

    public static void prepareData(Set<String> mSegmentList, Set<String> mCategoryList){
     
        SObjectType serviceType = Schema.getGlobalDescribe().get('Service_Type_Matrix__c');
        ServicefieldMaps = serviceType.getDescribe().fields.getMap();
        DescribeSObjectResult describeResult = Service_Type_Matrix__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        
        //***** Start - Edited by Siwapongsakorn(iiG) on 31/03/2020 *****//
        String SYSTEM_FIELDS = 'ownerid,isdeleted,createddate,createdbyid,lastmodifieddate,lastmodifiedbyid,'+
                                'systemmodstamp,lastvieweddate,lastreferenceddate,uniquetext__c';
        
        List<String> mServiceTypeMatrixFieldsList = new List<String>();
        for(String mFieldItem : fieldNames)
        {
            if(!SYSTEM_FIELDS.contains(mFieldItem))
            {
                mServiceTypeMatrixFieldsList.add(mFieldItem);
            }
        }
        //***** End - Edited by Siwapongsakorn(iiG) on 31/03/2020 *****//
        String query = 'SELECT ' +
            String.join( mServiceTypeMatrixFieldsList, ',' ) + //Edited by Siwapongsakorn(iiG) on 31/03/2020
            //String.join( fieldNames, ',' ) + // << Original Before Change 30/03/2020
            ' FROM ' +
            describeResult.getName()  +
            //' Where Active__c = true limit 49999' //Original Before Change 30/03/2020
            ' Where (Active__c = true OR Display_on_OneApp__c = true) AND Segment__c IN:mSegmentList AND Service_Level1__c IN:mCategoryList LIMIT 49999' //Edited by Siwapongsakorn(iiG) on 31/03/2020
            //' Where (Active__c = true OR Display_on_OneApp__c = true) AND Segment__c = \'RBG\' AND Service_Level1__c = \'Request\' LIMIT 49999' 
            ;

        list<Service_Type_Matrix__c> serviceList = Database.query(query);
        allMatrix = serviceList;
        EntitlementID = [Select ID, Status, SLA_Day__c, recordtype.name from Entitlement where Status = 'Active' and recordtype.name = 'With Business Hours' ];

        //Mapping key service
        for(Service_Type_Matrix__c issueMatrix : allMatrix){
            String keyMap = issueMatrix.Segment__c  + issueMatrix.Service_Level1__c+ issueMatrix.Service_Level2__c + issueMatrix.Service_Level3__c + issueMatrix.Service_Level4__c;
            keyMap = EncodingUtil.urlEncode(keyMap, 'UTF-8'); 
            keyMap = keyMap.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
            keyMap = EncodingUtil.urlDecode(keyMap, 'UTF-8');            
            keyMap = keyMap.replaceAll('/', '');            
            keyMap = keyMap.replaceAll( '\\s+', ''); //Remove all space
            ServiceMatrixMap.put(keyMap,issueMatrix);
        }

        List<User> userBu = [select ID, Employee_ID__c, Name,UserProfileName__c from user where IsActive = true and Employee_ID__c != Null];

        //Query only queue that support object Case
        List<QueueSobject> QuSType = [SELECT Id,QueueId,SobjectType FROM QueueSobject where SobjectType  = 'Case'];
        Set<ID> QueueID = New Set<ID>();
        if(QuSType.size() > 0){
            for(QueueSobject qType : QuSType){
                 QueueID.add(qType.QueueId);
            }
        }
        teamName = [Select ID,DeveloperName, Name  from Group where Type = 'Queue' and ID IN: QueueID];
        //Mapping Queue in Responsible BU
        if(teamName.size() > 0){
            for(Group g: teamName){
                
                String BUname = EncodingUtil.urlEncode(g.Name, 'UTF-8'); 
                BUname = BUname.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                BUname = EncodingUtil.urlDecode(BUname, 'UTF-8');
                mapTeamName.put(BUname, g.ID);
                queueMapName.put(g.ID, BUname);
            }
        }

        //Mapping user in Responsible BU
        if(userBu.size() > 0){
            for(User user_loop : userBu){
                mapTeamName.put(user_loop.Employee_ID__c, user_loop.ID);
                userMapName.put(user_loop.ID, user_loop.Name);
                
                if(user_loop.UserProfileName__c == 'TMB System Administrator'|| user_loop.UserProfileName__c == 'System Administrator' || user_loop.UserProfileName__c == 'Retail Integration API Only'){
                    userMapAdminName.put(user_loop.ID, user_loop.Name);
                }
            }
        }

        //Mapping Entitlement for assign SLA
        if(EntitlementID.size() > 0){
            for(Entitlement en_loop : EntitlementID){
                if(en_loop.SLA_Day__c != null){
                  String keyMap = en_loop.SLA_Day__c + '';
                  EntitlementMap.put(keyMap, en_loop.ID);
                }
            }
        }

        //Manage round robin assignment for UW team
        list_Round_Robin = [Select ID,Main_Queue__c, List_Queue__c from  Case_Assignment_Round_Robin__c];
        if(list_Round_Robin != null){
            for(Case_Assignment_Round_Robin__c uw_Round_Robin :list_Round_Robin){
                map_UW_Queue.put(uw_Round_Robin.Main_Queue__c, uw_Round_Robin.List_Queue__c);
                map_Round_Robin.put(uw_Round_Robin.Main_Queue__c,uw_Round_Robin);
            }
        }
        
        //CR Non-Voice
        skillMasterList = [SELECT Id, Name, Topic__c, Skill__c  , Source__c, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c
                           ,Validate_Code__c,Problem_Type__c,Journey__c 
                           FROM Skill_Master__c];
        if(skillMasterList.size() > 0)
        {
            for(Skill_Master__c skill : skillMasterList)
            {
                if(skill.Source__c == 'Email - ME')
                {
                    skillMasterMap.put(skill.Source__c,skill);
                }
                else if(skill.Source__c == 'Email - Commercial' || skill.Source__c == 'Email - ttbweb'){
                    
                    skillMasterMap.put(skill.Source__c.toLowerCase()+skill.Topic__c,skill);
                    
                    subjectKeyword.add(skill.Topic__c);
                }
                else 
                {
                    skillMasterMap.put(skill.Topic__c+skill.Source__c,skill);
                    subjectKeyword.add(skill.Topic__c);
                }
            }
        }  
        

        //Prepare setting auto send SMS and Closed case
        autoSMSMetaList = [SELECT Id,Resolution__c,Service_Type_Matrix_Code__c,Status__c FROM Auto_SMS_Setting__mdt];
        autoSMSMetaMap = new Map<String,Auto_SMS_Setting__mdt>();
        for (Auto_SMS_Setting__mdt meta : autoSMSMetaList){
            autoSMSMetaMap.put(meta.Service_Type_Matrix_Code__c + meta.Status__c,meta);
        }
        

        FlagePrepareData = false;
    }

    public static void handleBeforeInsert(List<Case> caseList){
        System.debug('********** Handle before insert ***********');
        //*************Start Fixed Apex Heap Size***************//
        //Fixed by: Siwapongsakorn(iiG)
        //Fixed Date: 31/03/2020
        Set<String> mSegmentSet = new Set<String>();
        Set<String> mCategorySet = new Set<String>();
        for(Case mCaseItem : caseList)
        {
            mSegmentSet.add(mCaseItem.PTA_Segment__c);
            mCategorySet.add(mCaseItem.Category__c);
        }
    
        if(FlagePrepareData){
           prepareData(mSegmentSet, mCategorySet);
        }        


            //*************End Fixed Apex Heap Size***************//
        
        EncryptionCtl encrptData = New EncryptionCtl();
        boolean isCallupdateCloseByBUOwner = false;
        for(Case caseNew : caseList){
            
            if(caseNew.status == 'Resolved' || caseNew.IsClosed == true){
                isCallupdateCloseByBUOwner = true;
            }    
            
            //Service Sprint 35
            //Auto send SMS notify customer when created case in system
            if(caseNew.SMS_Code_New__c != '' && caseNew.SMS_Code_New__c != null){
                caseNew.Bulk_Send_SMS__c = true;
            }          
             // Check only record Not FCR Case
            
            if(caseNew.FCR__c == false && caseNew.Status != 'Completed'){
                isAssignedSLAByHop = false;
                autoAssign(caseNew);
            }else if(caseNew.FCR__c == true){  
                caseNew.EntitlementId = null;
                caseNew.Commit_Date__c = null;
            }
            
            //CR send encrypt credit card to DWH
            //Danudath
            if(caseNew.Card_No_Full__c != null){
               caseNew.Card_No1_Encrypted__c = encrptData.encryptedDataToHex(caseNew.Card_No_Full__c);
            }
            if(caseNew.Card_No2_Full__c != null){
               caseNew.Card_No2_Encrypted__c = encrptData.encryptedDataToHex(caseNew.Card_No2_Full__c);
            }            
            //End encrypt data
            
            //if create case by web service bypass this process
            //For improve performance
            if(caseNew.Is_web_service__c == false){


            //CR Non-Voice
            Map<String,String> caseOriginMap = new Map<String,String>();
            List<String> caseOriginList = CaseValidationRule.appMeta_CaseOrigin.Value__c.split(',');
            String caseSubject = '';
            for(String caseOrigin : caseOriginList)
            {
                caseOriginMap.put(caseOrigin,caseOrigin);

            }  

            
            
            if((CaseValidationRule.currentUser.Profile.Name == 'System Administrator' || CaseValidationRule.currentUser.Name == 'Automated Process') && caseOriginMap.containsKey(caseNew.Origin))
            {
                if(caseNew.Origin == 'Live Chat')
                {
                    caseSubject = caseNew.Subject;
                }
                else 
                {                                
                    for(String s : subjectKeyword)
                    {
                        if(caseNew.Subject != null)
                        {
                            if((caseNew.Subject).containsIgnoreCase(s))
                            {
                                caseSubject = s;
                                break;
                            }
                        }
                    }
                }

                if(caseNew.Origin == 'Email - ME' && caseNew.ParentId == null)
                {
                    caseNew.PTA_Segment__c = skillMasterMap.get(caseNew.Origin).Segment__c;
                    caseNew.Category__c = skillMasterMap.get(caseNew.Origin).Service_Level1__c;
                    caseNew.Sub_Category__c = skillMasterMap.get(caseNew.Origin).Service_Level2__c;
                    caseNew.Product_Category__c = skillMasterMap.get(caseNew.Origin).Service_Level3__c;
                    caseNew.Service_Type_Matrix_Code__c = skillMasterMap.get(caseNew.Origin).Validate_Code__c;
                    caseNew.Problem_Type__c = skillMasterMap.get(caseNew.Origin).Problem_Type__c;
                    caseNew.Journey__c = skillMasterMap.get(caseNew.Origin).Journey__c;
                    caseNew.Email_Topic__c = skillMasterMap.get(caseNew.Origin).Topic__c;
                    caseNew.Email_Source__c = 'Email - ME';
                }

                else 
                {
                    if(caseNew.Origin != 'Live Chat')
                    {
                        for(Case_Origin_Mapping__mdt caseMapping : appMeta_CaseOrigin_Mapping)
                        {
                            if(caseNew.Description != null)
                            {
                                if((caseNew.Description).containsIgnoreCase(caseMapping.Keyword__c))
                                {
                                    caseNew.Email_Source__c = caseMapping.Origin__c;
                                    break;
                                }
                                else 
                                {
                                    caseNew.Email_Source__c = 'Other';
                                }   
                            }
                            else 
                            {
                                caseNew.Email_Source__c = 'Other';
                            }                  
                        
                        }
                    }

                    if(skillMasterMap.containsKey(caseSubject+caseNew.Origin) && caseNew.ParentId == null)
                    {
                    
                        caseNew.PTA_Segment__c = skillMasterMap.get(caseSubject+caseNew.Origin).Segment__c;
                        caseNew.Category__c = skillMasterMap.get(caseSubject+caseNew.Origin).Service_Level1__c;
                        caseNew.Sub_Category__c = skillMasterMap.get(caseSubject+caseNew.Origin).Service_Level2__c;
                        caseNew.Product_Category__c = skillMasterMap.get(caseSubject+caseNew.Origin).Service_Level3__c;
                        caseNew.Service_Type_Matrix_Code__c = skillMasterMap.get(caseSubject+caseNew.Origin).Validate_Code__c;
                        caseNew.Problem_Type__c = skillMasterMap.get(caseSubject+caseNew.Origin).Problem_Type__c;
                        caseNew.Journey__c = skillMasterMap.get(caseSubject+caseNew.Origin).Journey__c;
                        if(caseNew.Origin != 'Live Chat')
                        {
                            caseNew.Email_Topic__c = skillMasterMap.get(caseSubject+caseNew.Origin).Topic__c;
                        }
                    }
                    else
                    {
                        if(caseOriginMap.containsKey(caseNew.Origin) && caseNew.ParentId == null)
                        {
                            if(caseNew.Subject.contains('QR name card'))
                            {   
                                system.debug('Record Type Name : '+caseNew.RecordTypeId);
                                
                                if(skillMasterMap.containsKey((caseNew.Origin.toLowerCase())+caseNew.Subject)){
                                    System.debug(skillMasterMap.get((caseNew.Origin.toLowerCase())+caseNew.Subject));
                                    caseNew.PTA_Segment__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Segment__c;
                                    caseNew.Category__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Service_Level1__c;
                                    caseNew.Sub_Category__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Service_Level2__c;
                                    caseNew.Product_Category__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Service_Level3__c;
                                    caseNew.Service_Type_Matrix_Code__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Validate_Code__c;
                                    caseNew.Problem_Type__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Problem_Type__c;
                                    caseNew.Journey__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Journey__c;         
                                    caseNew.Email_Topic__c = skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Segment__c + ' ' + skillMasterMap.get(caseNew.Origin.toLowerCase()+caseNew.Subject).Topic__c;
                                }  
                                
                                system.debug('Skill master Key: '+ caseNew.Origin.toLowerCase()+' '+caseNew.Subject);
                                system.debug('Email topic: '+caseNew.Email_Topic__c);
                                system.debug('Record Type Name2 : '+caseNew.RecordTypeId);
                            }
                            else
                            {

                                caseNew.Email_Topic__c = 'Not Match';
                            }
                        }
                    }
                }

            }
            else if(CaseValidationRule.currentUser.Name == 'Automated Process' && caseNew.recordTypeId == null)
            {
                Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Retail Service').getRecordTypeId();
                caseNew.RecordTypeId = caseRecordTypeId;
                caseNew.Origin = 'Live Chat';
            }              
            
            
            //Auto send SMS and Closed Case
            //SCR SCR0381041  9/09/2020
            String newKeywords = caseNew.Service_Type_Matrix_Code__c + caseNew.Status;
            Auto_SMS_Setting__mdt autoSMSMetaObj = autoSMSMetaMap.get(newKeywords);          
            if (caseNew.Auto_SMS__c == false && autoSMSMetaMap.containsKey(newKeywords) && 
            autoSMSMetaObj.Resolution__c == caseNew.Resolution_LIst__c && caseNew.SMS_Mobile_Endpoint__c != null &&
                (caseNew.SMS_Code_Resolution_1__c != null || caseNew.SMS_Code_Resolution_2__c != null || caseNew.SMS_Code_Resolved__c != null || 
                caseNew.SMS_Code_New__c != null || caseNew.SMS_Code_In_progress__c != null)){   
                    caseNew.Bulk_Send_SMS__c = true;
                    caseNew.SMS_Auto_Completed__c = true;
                    caseNew.Auto_SMS__c = true;
                    isAutoSMS = true;
            //end condition auto send SMS
            } else {
                caseNew.Bulk_Send_SMS__c = false;
            }

        } //End by pass web service
        
            //Service sprint 33
            //Date 24-03-2020
            try{
                if(caseNew.Is_Queue_Owner__c == false){
                    list<Employee__c> listEmp = [Select ID, Name, Email__c, Manager_Email__c from Employee__c where IsActive__c = true and Name =: caseNew.Owner_Employee_ID__c limit 1];
                    caseNew.Owner_Manager_Email__c = listEmp[0].Manager_Email__c;               
                } 

            }catch(exception e){
                //Do not thing
            } 

       }
        
       //Auto Assign Owner for resolve status and close by bu stamp
        if(isCallupdateCloseByBUOwner){
            updateCloseByBUOwner( null,caseList );
        }
       
    }

    public static void handleAfterInsert(List<Case> caseList){
        slaByHopAddList = new list<SLA_By_Hop__c>();

        //*************Start Fixed Apex Heap Size***************//
        //Fixed by: Siwapongsakorn(iiG)
        //Fixed Date: 31/03/2020
        Set<String> mSegmentSet = new Set<String>();
        Set<String> mCategorySet = new Set<String>();
        for(Case mCaseItem : caseList)
        {
            //By pass web service for not process
            if(mCaseItem.Is_web_service__c == false){
                mSegmentSet.add(mCaseItem.PTA_Segment__c);
                mCategorySet.add(mCaseItem.Category__c);
            }
        }

        if(FlagePrepareData){
           prepareData(mSegmentSet, mCategorySet);
        }
       

        //*************End Fixed Apex Heap Size***************//
        //Prepare data SLS by Hop
        set<ID> setCaseID = New set<ID>();
        slaByHopCtl slaByHop = new slaByHopCtl();
        setCaseID = slaByHop.setListCaseID(caseList);
        mapSLAbyHop = slaByHop.queryOldSLAByHop(setCaseID);
        mapSLAPerOwner  = slaByHop.queryOldWorkDuration(setCaseID);
      
        Boolean bypassWebservice = false;

        //Stamp owner for count SLA
        List<SLA_Per_Owner__c> list_slaPerOwner = New List<SLA_Per_Owner__c>();
        for(Case newCaseInsert : caseList){
            //By pass web service for not process
            if(newCaseInsert.Is_web_service__c == true){
                bypassWebservice = true;
            }else{
               SLA_Per_Owner__c slaPerUser = New SLA_Per_Owner__c();
               slaPerUser.Case__c = newCaseInsert.ID;
               slaPerUser.Case_Status__c = newCaseInsert.Status;

               //Check if case owner is User
               String OwnerID = newCaseInsert.OwnerId;
               if(OwnerID.startsWith('005')){
                  slaPerUser.Link_User__c = newCaseInsert.OwnerId;
                  slaPerUser.Name = userMapName.get(newCaseInsert.ownerID);
               }else{
                   slaPerUser.Queue_ID__c = newCaseInsert.ownerID;
                   slaPerUser.Name = queueMapName.get(newCaseInsert.ownerID);
               }
               slaPerUser.Start_Date_Time__c = system.now();
               list_slaPerOwner.add(slaPerUser);

            //Assign SLA by Hop after insert case
            if(newCaseInsert.FCR__c == false && newCaseInsert.Status != 'Completed'){
                String keyMap = newCaseInsert.PTA_Segment__c + newCaseInsert.Category__c + newCaseInsert.Sub_Category__c + newCaseInsert.Product_Category__c + newCaseInsert.Issue__c;
                keyMap = EncodingUtil.urlEncode(keyMap, 'UTF-8'); 
                keyMap = keyMap.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                keyMap = EncodingUtil.urlDecode(keyMap, 'UTF-8'); 
                keyMap = keyMap.replaceAll('/', '');                
                keyMap = keyMap.replaceAll( '\\s+', ''); //Remove all space       
                if(ServiceMatrixMap.containsKey(keyMap)){
                    Service_Type_Matrix__c issueMatrix = ServiceMatrixMap.get(keyMap);
                    checkLoopSLAByHop = false;
                    slaByHopAddList.addAll(slaByHop.addSLAByHop(issueMatrix, newCaseInsert, ServicefieldMaps,mapSLAbyHop,mapSLAPerOwner));
                } 
            }

            }
           
   
         }

        //By pass web service
        if(bypassWebservice == false){

            if(slaByHopAddList.size() > 0){
                Database.insert(slaByHopAddList,false);
            }
    
            if(list_slaPerOwner.size() > 0){
                Database.insert(list_slaPerOwner,false);
    
            }
    
            //Share case to creator
            sharingRecord(caseList);
        }
    }

    public static void handleBeforeUpdate(Map<Id,Case> oldMap,Map<Id,Case> newMap){
        System.debug('********** Handle before update ***********');

        slaByHopAddList = new list<SLA_By_Hop__c>();
        List<Case> caseList = new List<Case>();

          //*************Start Fixed Apex Heap Size***************//
        //Fixed by: Siwapongsakorn(iiG)
        //Fixed Date: 31/03/2020
        Set<String> mSegmentSet = new Set<String>();
        Set<String> mCategorySet = new Set<String>();
        for(Case mCaseItem : newMap.values())
        {
            mSegmentSet.add(mCaseItem.PTA_Segment__c);
            mCategorySet.add(mCaseItem.Category__c);
        }
        for(Case mCaseItem : oldMap.values())
        {
            mSegmentSet.add(mCaseItem.PTA_Segment__c);
            mCategorySet.add(mCaseItem.Category__c);
        }
         if(FlagePrepareData){
            prepareData(mSegmentSet, mCategorySet);
         }
         //*************End Fixed Apex Heap Size***************//
 
        //Prepare data SLS by Hop
        for(Id caseID : newMap.keySet()){
            caseList.add(newMap.get(caseID));
        }
        set<ID> setCaseID = New set<ID>();
        slaByHopCtl slaByHop = new slaByHopCtl();
        setCaseID = slaByHop.setListCaseID(caseList);
        mapSLAbyHop = slaByHop.queryOldSLAByHop(setCaseID);
        mapSLAPerOwner  = slaByHop.queryOldWorkDuration(setCaseID);
        

        List<Case_Assignment_Round_Robin__c> list_assign_round_robin_update = New List<Case_Assignment_Round_Robin__c>();
        String list_main_queue = '';
        String list_Round_Robin = '';
        Case_Assignment_Round_Robin__c new_Round_Robin = New Case_Assignment_Round_Robin__c();
        Map<String,Case_Assignment_Round_Robin__c> map_Round_Robin_Update = New Map<String,Case_Assignment_Round_Robin__c>();

        EncryptionCtl encrptData = New EncryptionCtl();
        boolean isCallupdateCloseByBUOwner = false;
        
        for(Id caseID : newMap.keySet()){
            Case oldCase = oldMap.get(caseID);
            Case newCase = newMap.get(caseID);
            isUpdateCS_Service = true;
            
            if(newCase.status == 'Resolved' || newCase.IsClosed == true){
                if(!System.isBatch())isCallupdateCloseByBUOwner = true;
            }
            

            //Auto Send SMS and completed case 
            //If issue matrix map with setting in custom meta data 'Auto SMS Settings'
            //Service sprint 35
            if(newCase.Bulk_Send_SMS__c &&  newCase.Auto_SMS__c){
                newCase.Bulk_Send_SMS__c = false;
            }  
                    
            String newKeywords = newCase.Service_Type_Matrix_Code__c + newCase.Status;
            Auto_SMS_Setting__mdt autoSMSMetaObj = autoSMSMetaMap.get(newKeywords);
            if (newCase.Auto_SMS__c == false && newCase.Status == 'Resolved' && (oldCase.Status != newCase.Status || oldCase.Resolution_LIst__c != newCase.Resolution_LIst__c) 
                && autoSMSMetaMap.containsKey(newKeywords) && autoSMSMetaObj.Resolution__c == newCase.Resolution_LIst__c && newCase.SMS_Mobile_Endpoint__c != null &&
                (newCase.SMS_Code_Resolution_1__c != null || newCase.SMS_Code_Resolution_2__c != null || newCase.SMS_Code_Resolved__c != null)){   

                    newCase.Bulk_Send_SMS__c = true;
                    newCase.SMS_Auto_Completed__c = true;
                    newCase.Auto_SMS__c = true;
                    isAutoSMS = true;

            //end condition auto send SMS
            }else{

            //Set auto assign if service issue type changed
            if((newCase.FCR__c == false && newCase.IsClosed == false) &&
               (oldCase.PTA_Segment__c != newCase.PTA_Segment__c  || oldCase.Category__c != newCase.Category__c
                || oldCase.Sub_Category__c != newCase.Sub_Category__c || oldCase.Product_Category__c != newCase.Product_Category__c
                || oldCase.Issue__c != newCase.Issue__c || newCase.Isclone())){
                    String oldCS_Category = '';
                    String newCS_Category = '';
                    if(oldCase.Category__c != null){
                        oldCS_Category = oldCase.Category__c.replaceAll('\\s+', '');
                    }
                    if(newCase.Category__c != null){
                        newCS_Category = newCase.Category__c.replaceAll('\\s+', '');
                    }
                    //Not update CS owner if not change Category.
                    //And Category is Condition_CS or Service Request_CS
                    if(newCase.Isclone() == False && (oldCS_Category.containsIgnoreCase('ChangeCondition_CS') || oldCS_Category.containsIgnoreCase('ServiceRequest_CS')) &&
                       (newCS_Category.containsIgnoreCase('ChangeCondition_CS') || newCS_Category.containsIgnoreCase('ServiceRequest_CS'))){
                        isUpdateCS_Service = false;
                    }
                    
                    isAssignedSLAByHop = true;
                    autoAssign(newCase);
            }

            //Auto assign round robin for UW team
            if(newCase.OwnerId != oldCase.OwnerId){
                String newOwnerName = null;
                String newOwnerID = newCase.OwnerId;
                if(newOwnerID.startsWith('005')){
                    newOwnerName = userMapName.get(newCase.OwnerId);
                }else{
                    newOwnerName = queueMapName.get(newCase.OwnerId);
                }
                if(map_UW_Queue.containsKey(newOwnerName)){
                    if(!list_main_queue.containsIgnoreCase(newOwnerName)){
                        list_Round_Robin = map_UW_Queue.get(newOwnerName);
                        new_Round_Robin = map_Round_Robin.get(newOwnerName); //get custom setting for update
                        list_main_queue = list_main_queue + newOwnerName;
                    }
                    list_Round_Robin = list_Round_Robin.replaceAll('\\s+', ''); //Remove all space
                    String[] first_Owner = list_Round_Robin.split(',');
                    if(mapTeamName.get(first_Owner[0]) != null){
                        newCase.OwnerId = mapTeamName.get(first_Owner[0]);
                        newCase.UW_Auto_Assign_Flag__c = true;
                    }
                    list_Round_Robin = list_Round_Robin.remove(first_Owner[0]+',');
                    list_Round_Robin = list_Round_Robin + ','+first_Owner[0];
                    new_Round_Robin.List_Queue__c = list_Round_Robin;
                    map_Round_Robin_Update.put(newOwnerName,new_Round_Robin);
                }
            }
            
            //CR send encrypt credit card to DWH
            //Danudath
            if(newCase.Card_No_Full__c != null && newCase.Card_No_Full__c != oldCase.Card_No_Full__c){
               newCase.Card_No1_Encrypted__c = encrptData.encryptedDataToHex(newCase.Card_No_Full__c);
            }
            if(newCase.Card_No2_Full__c != null && newCase.Card_No2_Full__c != oldCase.Card_No2_Full__c){
               newCase.Card_No2_Encrypted__c = encrptData.encryptedDataToHex(newCase.Card_No2_Full__c);
            }            
            //End encrypt data
                //Service sprint 33
                //Query manager email of case owner 
                //Date 24-03-2020
                try{
                    if(newCase.Is_Queue_Owner__c == false && oldCase.ownerid != newCase.OwnerID ){
                        list<Employee__c> listEmp = [Select ID, Name, Email__c, Manager_Email__c from Employee__c where IsActive__c = true and Name =: newCase.Owner_Employee_ID__c limit 1];
                        newCase.Owner_Manager_Email__c = listEmp[0].Manager_Email__c;
        
                    }else{
                        newCase.Owner_Manager_Email__c = '';
                    }   
                }catch(exception e){
                    //Do not thing
                }
            }
            
        }//end for
        If(slaByHopAddList.size() > 0 ){
             checkLoopSLAByHop = false;
             Database.upsert(slaByHopAddList,false);           
        }

        if(map_Round_Robin_Update.size() > 0){
            for(String keyMap : map_Round_Robin_Update.keySet()){
                list_assign_round_robin_update.add(map_Round_Robin_Update.get(keyMap));
            }
        }
        if(list_assign_round_robin_update.size() > 0){
           update list_assign_round_robin_update;
        }

        //Auto Assign Owner for resolve status and close by bu stamp
        if(!isAutoSMS && isCallupdateCloseByBUOwner){
            updateCloseByBUOwner(oldMap, newMap.values() );
        }
        //System.debug('Limits.getHeapSize() >> ' + Limits.getHeapSize());
    }


    public static void handleAfterUpdate(Map<Id,Case> oldMap,Map<Id,Case> newMap){

        //SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center'];
        List<CaseMilestone> casMileUpdate = New List<CaseMilestone>();
        Set<ID> setCaseID = New Set<ID>();
        List<SLA_Per_Owner__c> sla_Owner_insertList = New List<SLA_Per_Owner__c>();
        List<SLA_Per_Owner__c> sla_Owner_updateList = New List<SLA_Per_Owner__c>();
        Map<String, SLA_Per_Owner__c> map_slaPerOwner = New Map<String, SLA_Per_Owner__c>();
        List<SLA_Per_Owner__c> list_previous_slaPerOwner = [Select ID, Name, Link_User__c, Case__c, Start_Date_Time__c, End_Date_Time__c, Queue_ID__c from SLA_Per_Owner__c where End_Date_Time__c = null and Case__c in: newMap.keySet()];
        List<Case> unShareCaseList = New List<case>();

        //Mapping previous owner for caculate SLA per user
        if(list_previous_slaPerOwner.size() > 0){
            for(SLA_Per_Owner__c slaPerOwner : list_previous_slaPerOwner){
                //Check if previous owner is user
                if(slaPerOwner.Link_User__c != null){
                    map_slaPerOwner.put(string.valueof(slaPerOwner.Link_User__c) + string.valueof(slaPerOwner.Case__c), slaPerOwner);
                }else{
                    //Previous owner is queue
                    map_slaPerOwner.put(slaPerOwner.Queue_ID__c + string.valueof(slaPerOwner.Case__c), slaPerOwner);
                }
            }
        }

        for(ID caseID : newMap.keySet()){
            Case newCase = newMap.get(caseID);
            Case oldCase = oldMap.get(caseID);
            //Check case if closed, add list to update Milestone for auto completed only for recordtype 'SE Call Center'
            if(newCase.isClosed == true && oldCase.IsClosed == False){
               setCaseID.add(newCase.ID);
            }

            //Check for update SLA per Owner
            if(newCase.OwnerId != oldCase.OwnerId && newCase.IsClosed == false
                 && checkLoop ){

                   //Stamp new owner to monitor SLA
                   SLA_Per_Owner__c slaPerUser = New SLA_Per_Owner__c();
                   slaPerUser.Case__c = newCase.ID;

                   //Check if case owner is User
                   String OwnerID = newCase.OwnerId;
                   if(OwnerID.startsWith('005')){
                      slaPerUser.Link_User__c = newCase.OwnerId;
                      slaPerUser.Name = userMapName.get(newCase.OwnerId);
                   }else{
                      slaPerUser.Queue_ID__c = newCase.OwnerId;
                      slaPerUser.Name = queueMapName.get(newCase.OwnerId);
                   }
                   slaPerUser.Start_Date_Time__c = system.now();
                   sla_Owner_insertList.add(slaPerUser);

                    //Query previous owner to update end date
                    SLA_Per_Owner__c  old_slaPerOwner = map_slaPerOwner.get(string.valueOf(oldCase.OwnerId) + string.valueOf(oldCase.ID));
                     if(old_slaPerOwner != null){
                        old_slaPerOwner.End_Date_Time__c = system.Now();
                        old_slaPerOwner.Case_Status__c = newCase.Status;
                        sla_Owner_updateList.add(old_slaPerOwner);
                     }
                }else if(newCase.IsClosed == true && oldCase.IsClosed == false && checkLoop){

                    //Query previous owner to update end date
                    SLA_Per_Owner__c  old_slaPerOwner = map_slaPerOwner.get(string.valueOf(oldCase.OwnerId) + string.valueOf(oldCase.ID));
                    if(old_slaPerOwner != null){
                        old_slaPerOwner.End_Date_Time__c = system.Now();
                        old_slaPerOwner.Case_Status__c = newCase.Status;
                        sla_Owner_updateList.add(old_slaPerOwner);
                    }
                }

            //Remove sharing case to creator when new owner change case status from 'New' to 'In progress'
            if(oldCase.Status == 'New' && NewCase.Status != 'New' && NewCase.CreatedById != NewCase.OwnerId){
                unShareCaseList.add(NewCase);
            }

        }

        //Check all milestore that related to Closed Case and update Milestore to completed
        if(setCaseID.size() > 0){
            List<CaseMilestone> casMileList = [Select ID, CompletionDate from CaseMilestone where caseId  in: setCaseID];
            if(casMileList.size() > 0){
                for(CaseMilestone caseM : casMileList){
                    caseM.CompletionDate = system.now();
                    casMileUpdate.add(caseM);
                }
            }
        }

        //Update Case Milestone to completed
        if(casMileUpdate.size() > 0){
            try{
                update casMileUpdate;
            }catch(exception e){

            }
        }

        //Insert SLA per Case owner user
        if(!Test.isRunningTest()){
            checkLoop = false;
        }

        if(sla_Owner_insertList.size() > 0){
            //system.debug('Test Start add Work duration');
            Database.insert(sla_Owner_insertList,false);
            //system.debug('Test End add Work duration');
        }

        if(sla_Owner_updateList.size() > 0){
           update sla_Owner_updateList;
        }

        //Remove share case to creator
        if(unShareCaseList.size() > 0){
            removeSharingRecord(unShareCaseList);
        }
    }

    public static void handleBeforeDelete(List<Case> caseList){
       //Define method for future function
    }

    public static void autoAssignKYCApprover(Map<Id, Case> oldCaseMap, List<Case> KYCCaseList) {
        Set<Id> OwnerIdSet = new Set<Id>();
        Set<Id> AccountIdSet = new Set<Id>();
        for(Case KYCCase : KYCCaseList) {
            if(KYCCase.Status == 'Completed' || KYCCase.Status == 'Cancel') {
                KYCCase.Closed_by__c = currUser.Name;
            }
            if(String.valueOf(KYCCase.OwnerId).startsWith('005')){
                OwnerIdSet.add(KYCCase.OwnerId);
            }
            if(KYCCase.AccountId != null) AccountIdSet.add(KYCCase.AccountId);
        }
        Map<Id,User> CaseOwnerMap = new Map<Id,User>([SELECT Id, Profile.Name, ManagerId, Manager.Id, Manager.IsActive, Manager.Manager.Id, Manager.Manager.IsActive FROM User WHERE Id in: OwnerIdSet]);
        Map<Id,Account> KYCCustomerMap = new Map<Id,Account>([SELECT Id, Owner.Manager.Id, Owner.Manager.IsActive, Owner.Manager.Manager.Id, Owner.Manager.Manager.IsActive FROM Account WHERE Id in: AccountIdSet]);
        for(Case KYCCase : KYCCaseList) {
            Case oldCase = oldCaseMap.get(KYCCase.Id);
            if(oldCase.OwnerId != KYCCase.OwnerId) {
                assignKYCApprover(KYCCase,CaseOwnerMap.get(KYCCase.OwnerId),KYCCustomerMap.get(KYCCase.AccountId));
            }
        }
    }

    public static Case assignKYCApprover(Case KYCCase, User CaseOwner, Account Customer) {
        KYCCase.KYC_Approver__c = null;
        KYCCase.KYC_Approver2__c = null;
        if(KYCCase.KYC_Data_type__c == 'N' && CaseOwner != null && CaseOwner.ManagerId != null && String.valueOf(CaseOwner.Id).startsWith('005')){
            //  Owner is user, not queue
            if(KYCCase.KYC_Risk_Level__c == '2') {
                if(CaseOwner.Manager.IsActive && !KYCCaseAdminProfile.contains(CaseOwner.Profile.Name)) {
                    KYCCase.KYC_Approver__c = CaseOwner.Manager.Id;
                }
            } else if(KYCCase.KYC_Risk_Level__c != '1') {
                // 3,4
                if(BDM_Profile_List.contains(CaseOwner.Profile.Name)) {
                    if(CaseOwner.Manager.IsActive) {
                        KYCCase.KYC_Approver__c = CaseOwner.Manager.Id;
                    }
                    if(CaseOwner.Manager.Manager.IsActive) {
                        KYCCase.KYC_Approver2__c = CaseOwner.Manager.Manager.Id;
                    }
                } else if(SEPM_Profile_List.contains(CaseOwner.Profile.Name)) {
                    if(CaseOwner.Manager.IsActive) {
                        KYCCase.KYC_Approver__c = CaseOwner.Manager.Id;
                    }
                    if(String.valueOf(Customer.Owner.Id).startsWith('005') && Customer.Owner.Manager.Manager.IsActive) {
                        KYCCase.KYC_Approver2__c = Customer.Owner.Manager.Manager.Id;
                    }
                } else {
                    if(CaseOwner.Manager.IsActive) {
                        KYCCase.KYC_Approver__c = CaseOwner.Manager.Id;
                    }
                }
            }
        }
        return KYCCase;
    }

    public static void autoAssignKYCCaseOwner(List<Case> KYCCaseList) {

        Set<Id> AccountIdSet = new Set<Id>();
        Set<String> MatrixCodeSet = new Set<String>();
        
        for(Case KYCCase : KYCCaseList) {
            if(KYCCase.Status == 'Completed' || KYCCase.Status == 'Cancel') {
                KYCCase.Closed_by__c = currUser.Name;
            }
            if(KYCCase.Service_Type_Matrix_Code__c != null) MatrixCodeSet.add(KYCCase.Service_Type_Matrix_Code__c);
            if(KYCCase.AccountId != null) AccountIdSet.add(KYCCase.AccountId);
        }
        Map<String, Service_Type_Matrix__c> ServiceMatrixMap = new Map<String, Service_Type_Matrix__c>();
        for(Service_Type_Matrix__c ServiceMatrix : [SELECT Id, Validate_Code__c, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Service_Level4__c, Service_Template__c, Journey__c, SLA__c, TAT__c, Severity__c, Service_issue_EN__c, Guideline__c, Responsible_BU__c, Closed_By_BU__c, SMS_Code_for_Update_Progress__c, SMS_Code_New__c, SMS_Code_In_Progress__c, SMS_Code_Resolved__c, Resolution_1__c, SMS_Code_Resolution_1__c, Resolution_2__c, SMS_Code_Resolution_2__c, Issue_for_ONEAPP_TH__c, Issue_for_ONEAPP_EN__c, Display_on_OneAPP__c, Product_Service_TH__c FROM Service_Type_Matrix__c WHERE Validate_Code__c =: MatrixCodeSet]) {
            ServiceMatrixMap.put(ServiceMatrix.Validate_Code__c, ServiceMatrix);
        }

        EntitlementID = [Select ID, Status, SLA_Day__c, recordtype.name from Entitlement where Status = 'Active' and recordtype.name = 'With Business Hours' ];
        if(EntitlementID.size() > 0){
            for(Entitlement en_loop : EntitlementID){
                if(en_loop.SLA_Day__c != null){
                  String keyMap = en_loop.SLA_Day__c + '';
                  EntitlementMap.put(keyMap, en_loop.ID);
                }
            }
        }

        Set<Id> OwnerIdSet = new Set<Id>();
        GROUP SEPM_Team = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'SEPM' LIMIT 1];
        GROUP BI_Team = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'BI Team' LIMIT 1];
        Map<Id,Account> KYCCustomerMap = new Map<Id,Account>([SELECT Id, OwnerId, Owner.IsActive, Owner.Manager.Id, Owner.Manager.IsActive, Owner.Manager.Manager.Id, Owner.Manager.Manager.IsActive, Owner.Profile.Name FROM Account WHERE Id in: AccountIdSet]);
        for(Account KYCCust : KYCCustomerMap.values()) {
            OwnerIdSet.add(KYCCust.Id);
        }

        for(Case KYCCase : KYCCaseList){
            Service_Type_Matrix__c Matrix = ServiceMatrixMap.containsKey(KYCCase.Service_Type_Matrix_Code__c) ? ServiceMatrixMap.get(KYCCase.Service_Type_Matrix_Code__c) : null;
            
            if(Matrix != null) {
                KYCCase.Subject = Matrix.Service_Level4__c;
                KYCCase.PTA_Segment__c = Matrix.Segment__c;
                KYCCase.Category__c = Matrix.Service_Level1__c;
                KYCCase.Sub_Category__c = Matrix.Service_Level2__c;
                KYCCase.Product_Category__c = Matrix.Service_Level3__c;
                KYCCase.Issue__c = Matrix.Service_Level4__c;
                KYCCase.Current_Service_Template__c = Matrix.Service_Template__c;
                KYCCase.Journey__c = Matrix.Journey__c;
                
                string kMap = Matrix.SLA__c + '';
                Integer sla = Integer.valueOf(Matrix.SLA__c);
                if(EntitlementMap.get(kMap) != null){
                    KYCCase.EntitlementId = EntitlementMap.get(kMap);
                    if(KYCCase.CreatedDate != null){
                        KYCCase.Commit_Date__c = getCommitBusinessDays(KYCCase.CreatedDate,sla);
                    }else{
                        KYCCase.Commit_Date__c = getCommitBusinessDays(system.now(),sla);
                    }
                    KYCCase.SLA_Day__c = Matrix.SLA__c;
                }

                
                KYCCase.Responsible_BU__c = Matrix.Responsible_BU__c;
                KYCCase.TAT__c = Matrix.TAT__c;
                KYCCase.Case_Severity__c = Matrix.Severity__c;
                KYCCase.Service_issue_EN__c = Matrix.Service_issue_EN__c;
                KYCCase.Guideline__c = Matrix.Guideline__c;

                // SLA By Hop
                KYCCase.Responsible_BU__c = Matrix.Responsible_BU__c;
                KYCCase.Closed_By_BU__c = Matrix.Closed_By_BU__c;

                // SMS Setting
                KYCCase.SMS_Code_for_Update_Progress__c = Matrix.SMS_Code_for_Update_Progress__c;
                KYCCase.SMS_Code_New__c = Matrix.SMS_Code_New__c;
                KYCCase.SMS_Code_In_progress__c = Matrix.SMS_Code_In_Progress__c;
                KYCCase.SMS_Code_Resolved__c = Matrix.SMS_Code_Resolved__c;
                KYCCase.SMS_Resolution_1__c = Matrix.Resolution_1__c;
                KYCCase.SMS_Code_Resolution_1__c = Matrix.SMS_Code_Resolution_1__c;
                KYCCase.SMS_Resolution_2__c = Matrix.Resolution_2__c;
                KYCCase.SMS_Code_Resolution_2__c = Matrix.SMS_Code_Resolution_2__c;

                // one app
                KYCCase.Issue_New_for_OneApp__c = Matrix.Issue_for_ONEAPP_TH__c;
                KYCCase.Issue_New_for_OneApp_EN__c = Matrix.Issue_for_ONEAPP_EN__c;
                KYCCase.Display_on_OneApp__c = Matrix.Display_on_OneApp__c;
                KYCCase.Product_For_OneApp_TH__c = Matrix.Product_Service_TH__c;
            }

            if(KYCCase.AccountId != null) {
                Account Cust = KYCCustomerMap.get(KYCCase.AccountId);
                if(KYCCase.KYC_SUB_4G__c == KYC_SUB_4G) {
                    // change to SEPM queue
                    KYCCase.OwnerId = SEPM_Team.Id;
                } else if(KYCCaseAdminProfile.contains(Cust.Owner.Profile.Name)) {
                    // change to BI team
                    KYCCase.OwnerId = BI_Team.Id;
                } else {
                    // change to RM
                    if(Cust.Owner.IsActive) {
                        KYCCase.OwnerId = Cust.OwnerId;
                        assignKYCApprover(KYCCase,Cust.Owner,Cust);
                    } else {
                        KYCCase.OwnerId = BI_Team.Id;
                    }
                }
            }
        }
    }

    //This method for update auto assign CaseOwner, SLA, Severity, Closed by BU
    public static void autoAssign(Case caseNew){

        String keyMap = caseNew.PTA_Segment__c + caseNew.Category__c + caseNew.Sub_Category__c + caseNew.Product_Category__c + caseNew.Issue__c;
        keyMap = EncodingUtil.urlEncode(keyMap, 'UTF-8'); 
        keyMap = keyMap.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
        keyMap = EncodingUtil.urlDecode(keyMap, 'UTF-8'); 
        keyMap = keyMap.replaceAll('/', '');
        keyMap = keyMap.replaceAll( '\\s+', ''); //Remove all space

        if(ServiceMatrixMap.containsKey(keyMap)){
            Service_Type_Matrix__c issueMatrix = ServiceMatrixMap.get(keyMap);     
            String responseBUname = '';    
            if(issueMatrix.Responsible_BU__c != null){
                responseBUname = EncodingUtil.urlEncode(issueMatrix.Responsible_BU__c, 'UTF-8');
                responseBUname = responseBUname.replaceAll('%C2%A0', '+'); //ลบอักขระพิเศษที่มองไม่เห็นด้วยตาเปล่า 
                responseBUname = EncodingUtil.urlDecode(responseBUname, 'UTF-8');
            } 

            //Auto assign Case Owner      
            if(issueMatrix.Responsible_BU__c != null && isUpdateCS_Service == true && caseNew.Is_Cloned__c != true){
                if(mapTeamName.get(responseBUname) != null){
                    caseNew.ownerID = mapTeamName.get(responseBUname);
                    System.debug('autoAssign | mapTeamName.get('+responseBUname+'): ' + mapTeamName.get(responseBUname));
                }else if(issueMatrix.Responsible_BU__c.contains('__c')){ // oneApp
                    //Assign case to customer owner
                    // SCR SCR0385303
                    string fieldName = issueMatrix.Responsible_BU__c;
                    System.debug('autoAssign | fieldName : ' + fieldName);

                    SObject sobj = caseNew;                                      
                    String idOwner = String.valueOf(sobj.get(fieldName));

                    String serviceType = String.valueOf(issueMatrix.Validate_Code__c);
                    // JYS started modified 29/7/2021
                    String queueNameOneApp;
                    List<Group> groupAssign = new List<Group>();
                    List<OneApp_Case_Owner_mdt__mdt> queueOneApp = [SELECT Id, Service_Type_Code__c, Queue_Name__c FROM OneApp_Case_Owner_mdt__mdt WHERE Service_Type_Code__c =: serviceType];
                    if (queueOneApp.size() > 0) {
                        queueNameOneApp = String.valueOf(queueOneApp[0].Queue_Name__c);
                        groupAssign = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND DeveloperName =: queueNameOneApp];
                    }

                    Case caseDefaultOwner = [SELECT Id, OwnerID, Owner.Name FROM Case WHERE Owner.Name = 'sfextapi' LIMIT 1];
                    if(!String.isEmpty(idOwner)){
                        //check if user active and not admin user                    
                        if(userMapName.get(idOwner) != null && userMapAdminName.get(idOwner) == null){
                            caseNew.ownerID = idOwner;
                        }else{ 
                            // user inactive ,continue find manager of this user 
                            User manager = [SELECT Id, ManagerId FROM User WHERE Id =: idOwner];
                            //check if manager of this user is active and not admin user
                            if(userMapName.get(manager.ManagerId)!= null && userMapAdminName.get(manager.ManagerId) == null){ 
                                caseNew.ownerID = manager.ManagerId;
                            }else{
                                if (groupAssign.size() > 0) {
                                    caseNew.ownerID = groupAssign[0].Id;
                                }else{
                                    caseNew.ownerID = caseDefaultOwner.OwnerID;
                                }
                            }                    
                        } 
                    }else{
                        // caseNew.ownerID = groupAssign.Id;
                        if (groupAssign.size() > 0) {
                            caseNew.ownerID = groupAssign[0].Id;
                        }else{
                            caseNew.ownerID = caseDefaultOwner.OwnerID;
                        }
                    }               
                    // JYS ended modified
                }
            }

            //CR Non-Voice For Skip Auto assign Case Owner
            if(caseNew.Is_Cloned__c == true)
            {
                caseNew.Is_Cloned__c = false;
            }

            //Auto assign severity
            if(issueMatrix.Severity__c != null){
                caseNew.Case_Severity__c = issueMatrix.Severity__c;
            }else{
                caseNew.Case_Severity__c = '';
            }

            //Auto assign Closed By BU
            if(issueMatrix.Closed_By_BU__c != null){
                
                //if closed by bu is register and created user is admin, assign closed by bu to first responsible bu
                // SCR request number SCR0511234
                if( caseNew.Is_Create_by_Admin__c == true && issueMatrix.Closed_By_BU__c == 'REGISTER'){
                    caseNew.Closed_By_BU__c = caseNew.First_Owner_BU__c;
                }else{
               		caseNew.Closed_By_BU__c = issueMatrix.Closed_By_BU__c; 
                }
            }else {
               caseNew.Closed_By_BU__c = '';
            }

            //Auto assign SLA
            string kMap = issueMatrix.SLA__c + '';
            Integer sla = Integer.valueOf(issueMatrix.SLA__c);
            if(EntitlementMap.get(kMap) != null){
                caseNew.EntitlementId = EntitlementMap.get(kMap);
                    if(caseNew.CreatedDate != null){
                        caseNew.Commit_Date__c = getCommitBusinessDays(caseNew.CreatedDate,sla);
                    }else{
                         caseNew.Commit_Date__c = getCommitBusinessDays(system.now(),sla);
                    }
                    caseNew.SLA_Day__c = issueMatrix.SLA__c;
            }

            //Add SLA By Hop
            if(isAssignedSLAByHop && checkLoopSLAByHop){ 
                checkLoopSLAByHop = false;              
                slaByHopCtl slaByHop = new slaByHopCtl();
                slaByHopAddList.addAll(slaByHop.addSLAByHop(issueMatrix, caseNew, ServicefieldMaps,mapSLAbyHop,mapSLAPerOwner));
              // system.debug('Test End call SLA By Hop');
                
            } 
        }
    }

    //This method for calculate commit date without weekend and holiday, base on system Business Hours
    public static Datetime getCommitBusinessDays(datetime startdate, Integer target)
     {
                Datetime pointer = startdate;

                //If create case in weekend or holiday, set start datetime to next working 00.00
                Boolean NonWorkingDay = false;
                if(!BusinessHours.isWithin(standardHoursId.id, pointer)){
                 NonWorkingDay = true;
                 pointer = pointer.addDays(1);
                 while(!BusinessHours.isWithin(standardHoursId.id, pointer)){
                         pointer = pointer.addDays(1);
                 }
                     Integer year = pointer.year();
                     Integer month = pointer.month();
                     Integer day = pointer.day();
                     pointer = Datetime.newInstance(year, month, day, 0, 0, 0);
                 }

                for(integer i = 0; i < target; i++)
                {
                    pointer = pointer.addDays(1);
                    //Returns true if the specified target date occurs within business hours. Holidays are included in the calculation.
                    while(!BusinessHours.isWithin(standardHoursId.id, pointer)){
                        Integer countLoop = i+1;
                        if(countLoop == target && NonWorkingDay == true){
                            break;
                        }
                        pointer = pointer.addDays(1);
                    }
                }
                return pointer;
       }

    //Auto share case to creator
    public static void sharingRecord(List<Case> caseList){
        List<CaseShare> caseShareList = New List<CaseShare>();
        for(Case share_case : caseList){
           CaseShare share_record = new CaseShare();
           share_record.CaseId = share_case.id;
           share_record.CaseAccessLevel = 'Edit';
           share_record.UserOrGroupId = share_case.CreatedById;
           caseShareList.add(share_record);
        }

        if(caseShareList.size() > 0){
            //partially  insert
            Database.insert(caseShareList,false);
        }
    }

    //If case update status to In progress and change owner, not share case to creator.
    public static void removeSharingRecord(List<Case> caseList){
        Set<ID> userID_set = New Set<ID>();
        Set<ID> setCaseID = new Set<ID>();
        for(Case unShareCase : caseList){
            userID_set.add(unShareCase.CreatedById);
            setCaseID.add(unShareCase.ID);
        }

        List<CaseShare> caseUnShareList = [Select ID, UserOrGroupId , CaseId from CaseShare where UserOrGroupId in: userID_set and CaseId in: setCaseID ];
        if(caseUnShareList.size() > 0){
            //partially  delete
            Database.Delete(caseUnShareList,false);
        }
    }

    private static void updateCloseByBUOwner(Map<Id,Case> oldMap,List<Case> newMap)
    {  
        
        UserRole ceoRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        
        List<User> userlist = [SELECT Id, UserRoleId ,RTL_Branch_Code__c,
            name  FROM User WHERE isactive = true];

        Set<String> queueNameSet = new Set<String>();
        Map<String,Set<Id>> queueNameAllRoleMap = new Map<String,Set<Id>> ();

       // Map<Id,User> userIdRoleMap = new Map<Id,User>();
        Map<Id,Group> gMap = new Map<Id,Group>();
        Map<String,Group> queueNameGroupMap = new Map<String,Group>();
        Set<Id> caseCreatotIds = new Set<Id>();
        for(Case tmpCase : newMap )
        {
            if( tmpCase.Closed_By_BU__c != null && tmpCase.Closed_By_BU__c != '' )
            {
                queueNameSet.add(tmpCase.Closed_By_BU__c);
            }

            caseCreatotIds.add(tmpCase.createdById);

        }

        //Keep the list of the case creator as users
        Map<Id, User> userMap = new Map<Id, User>();
       for(User u: userlist){
            userMap.put(u.Id, u);
        }

        List<GroupMember> gmList = [SELECT group.DeveloperName,group.Name,userorgroupid
                            FROM groupmember
                            WHERE group.Name in :queueNameSet ];
        Map<String,List<GroupMember>> queueNameGroupMemberMap = new map<String,List<GroupMember>>();
        Map<Id,GroupMember> groupMemberIdMap = new Map<Id,GroupMember>();

        for( GroupMember gm : gmList )
        {
            groupMemberIdMap.put( gm.userorgroupid , gm );

            if( !queueNameGroupMemberMap.containsKey( gm.group.Name ) )
            {
                List<GroupMember> tmpGM = new List<GroupMember>();
                queueNameGroupMemberMap.put( gm.group.Name , tmpGM );
            }
            queueNameGroupMemberMap.get( gm.group.Name ).add( gm );

        }

        List<Group> groupList = [ Select Id, Name, Type, DeveloperName , RelatedId
                    FROM Group WHERE id in :groupMemberIdMap.keySet() OR (type = 'queue'
                        AND name in :queueNameSet) ];

        for( Group g : groupList )
        {  
             if(groupMemberIdMap.keySet().contains(g.id )){
                gMap.put( g.id,g );
            }
            
        }

        for( Group queue : groupList )
        {
            if(queue.type == 'queue' && queueNameSet.contains(queue.name)){
                queueNameGroupMap.put(queue.name,queue);
            }
            
        }

        // Generate Map for Queue Name with all related profile under this queue

        for( String queueName : queueNameGroupMemberMap.keySet() )
        {
            queueNameAllRoleMap.put( queueName , new Set<Id>() );

            for( GroupMember gm : queueNameGroupMemberMap.get(queueName) )
            {
                // Add Role Id when group Member are Role or Role and Subordinate
                if( gMap.containsKey( gm.userorgroupid) )
                {
                    Group g = gMap.get( gm.userorgroupid );
                    if( g.Type == 'Role' || g.Type == 'RoleAndSubordinates' )
                    {
                        queueNameAllRoleMap.get(queueName).add( g.RelatedId );
                    }
                }

                // Add role Id if Group Member are User
                if( userMap.containsKey( gm.userorgroupid ) )
                {
                    User u = userMap.get(gm.userorgroupid);
                    queueNameAllRoleMap.get(queueName).add(u.UserRoleId);
                }

            }
        }

        // After get all role , will use to generate all upper level
        User U = userMap.get(UserInfo.getUserId());

        List<CaseStatus> csList = [Select Id, MasterLabel From CaseStatus Where IsClosed = true];
        Set<String> closeCaseStatusLabel = new Set<String>();
        for( CaseStatus cs : csList )
        {
            closeCaseStatusLabel.add( cs.MasterLabel );
        }

        //get all child role of current user
        Set<Id> listofChildRoleId = CaseUtil.getAllChildrenRoleId(U.userroleId);


        for(Case tmpCase : newMap )
        {
            Case oldCase = oldMap != null ? oldMap.get(tmpCase.Id) : null;
            Boolean isStatusUpdated = false;

            if(oldCase != null && oldCase.Status != tmpCase.Status){
                isStatusUpdated = true;
            }

            if( tmpCase.status == 'Resolved' && (oldCase == null || isStatusUpdated == true))
            {

                if( tmpCase.Closed_By_BU__c == '' || tmpCase.Closed_By_BU__c == null)
                {
                    tmpCase.OwnerId = UserInfo.getUserId();
                }
                // Is close by bu is Register , stamp case owner to current owner who resolve (temp logic)
                else if ( tmpCase.Closed_By_BU__c == 'REGISTER' )
                {                   
                    tmpCase.OwnerId = tmpCase.createdById;
                	
                   }
                    // Is close by bu has balue ( Queue name ) , stamp case owner to queue
                else
                {
                    if( queueNameGroupMap.containsKey( tmpCase.Closed_By_BU__c ) )
                    {
                        Group queue = queueNameGroupMap.get(tmpCase.Closed_By_BU__c);
                        tmpCase.OwnerId = queue.Id;
                    }
                    else
                    {
                        tmpCase.OwnerId = UserInfo.getUserId();
                    }

                }
                
            }
            //validate closed by bu when close case and not a FCR case
            else if( closeCaseStatusLabel.contains(tmpCase.status) && tmpCase.FCR__c == false)
            {
                if( tmpCase.Closed_By_BU__c != '' && tmpCase.Closed_By_BU__c != null )
                {
                    if ( tmpCase.Closed_By_BU__c == 'REGISTER')
                    {
                        User createdUser = userMap.get(tmpCase.createdById);
                        
                        if(createdUser != null)
                        {
                            string createdRoleId = createdUser.userroleid;
                            
                            if( UserInfo.getUserId()  != tmpCase.createdById && !listofChildRoleId.contains(createdRoleId))
                            {
                                tmpCase.addError(Label.Case_Close_Invalid_Close_By_BU);
                                
                            } 
                        }
                    }
                    else
                    {

                        //Check if User in upper Role
                        Boolean isOnUpperRole = false;

                        Set<Id> allSubRole = new Set<Id>();
                        if ((u.UserRoleId == ceoRole.Id) || (tmpCase.isClosed && oldMap.get(tmpCase.Id).isClosed)) {
                            allSubRole.add(u.UserRoleId);
                        }else {
                            allSubRole = CaseUtil.getSubHierarchyInclusive( u.UserRoleId );
                        }
                        Set<Id> profileInQueueSet = queueNameAllRoleMap.get( tmpCase.Closed_By_BU__c );

                        if( profileInQueueSet!= null)
                        {
                            for( Id profileIdInQueue : profileInQueueSet  )
                            {
                                if( allSubRole.contains( profileIdInQueue ) )
                                {
                                    isOnUpperRole = true;
                                    break;
                                }
                            }
                        }

                        // If on Upper Role , allowed to save regardless of Queue Member or Branch
                        if( !isOnUpperRole )
                        {

                            Boolean isUserinCloseByBUBranch = false;
                            if( u.RTL_Branch_Code__c != null )
                            {
                                if( tmpCase.Closed_By_BU__c.contains(u.RTL_Branch_Code__c) )
                                {
                                    isUserinCloseByBUBranch = true;
                                }
                            }
                            //Check close by BU when close case
                            Group queue = queueNameGroupMap.get(tmpCase.Closed_By_BU__c);
                            Boolean isQueueMem = CaseUtil.isInGroupOrRole( queue , u , gMap , queueNameGroupMemberMap );

                            if( !isQueueMem && !isUserinCloseByBUBranch && tmpCase.Is_SystemAdmin_User__c == false)
                            {
                                tmpCase.addError(Label.Case_Close_Invalid_Close_By_BU);
                            }
                        }
                    }

                }
            }
        }
        //System.debug('Limits.getHeapSize() >> ' + Limits.getHeapSize());
    }

}