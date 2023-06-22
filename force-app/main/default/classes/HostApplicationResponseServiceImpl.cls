public class HostApplicationResponseServiceImpl implements HostApplicationResponseService.IHostApplicationResponseService  {

    public static map<string,string> mapOpportunityName {get;set;}
    public static list<opportunity> listOptySendEmail {get;set;}

    public static void HostApplicationResponseMainProcess(list<host_application_response__c> listHostApp, list<host_application_response__c> listOldHostApp)
    {
        try {
        
            set<string> listOptyID = new set<string>();
            mapOpportunityName = new map<string,string>();
            listOptySendEmail = new list<opportunity>();
            set<string> listCurrentHostAppResponseID = new set<string>();
            //list<host_application_response__c> listUpdateHostAppResponseCurrentFalse = new list<host_application_response__c>();
            list<host_product_response__c> listDeleteProductResponse = new list<host_product_response__c>();
            list<opportunity> listUpdateOpty = new list<opportunity>();
            list<host_application_response__c> listAllHostApp = new list<host_application_response__c>();
            
            map<string,host_application_response__c> mapOld = new map<string,host_application_response__c>();
            if (listOldHostApp != null){
                mapOld.putAll(listOldHostApp);
            }
            
            map<string,string> mapLatestAppRef = new map<string,string>();
            set<string> setCaNumber = new set<string>();
            for (host_application_response__c ha: listHostApp)
            {
                if (string.isNotBlank(ha.CRM_ID__c)) setCaNumber.add(ha.CRM_ID__c);
                listOptyID.add(ha.opportunity__c);
            }
            
            for (opportunity ot : [select id,name,Application_Status__c,Host_System__c,Host_Result__c 
                                              from opportunity where id in : listOptyID])
            {
                mapOpportunityName.put(ot.id, ot.name);
            }
            
            for (host_application_response__c ha : [select id, CRM_ID__c, App_Ref_Number__c
                                                    from host_application_response__c
                                                    where crm_id__c in: setCaNumber])
            {
                listAllHostApp.add(ha);
            }
            
            for (string s : setCaNumber)
            {
                string maxAppRef = '';
                string tmp1 = '';
                string tmp2 = '';
                for (host_application_response__c ha: listAllHostApp) //listHostApp)
                {
                    if (ha.CRM_ID__c == s)
                    {
                        if (string.isNotBlank(ha.App_Ref_Number__c)) tmp1 = ha.App_Ref_Number__c;
                       
                        if (tmp1 != '' && tmp2 != '' && tmp1 != tmp2){
                            if (double.valueof(tmp1.right(6)) > double.valueof(tmp2.right(6))){
                                maxAppRef = tmp1;
                            }
                        }else{
                            maxAppRef = tmp1;   
                        }
                        
                        tmp2 = maxAppRef;
                    }
                }
                if (maxAppRef != '') mapLatestAppRef.put(s,maxAppRef);
            }
            
            
            for (host_application_response__c ha: listHostApp)
            {
                listCurrentHostAppResponseID.add(ha.ID);
                if (ha.current_application_response__c == true && (ha.App_Ref_Number__c == mapLatestAppRef.get(ha.CRM_ID__c))){
                    listUpdateOpty.add(mapFieldOpportunity(ha));
                }
            }

            //list<opportunity> listUpdateOpty = new list<opportunity>();
            
            /*
            for (host_application_response__c ha: listHostApp)
            {
                listUpdateOpty.add(mapFieldOpportunity(ha));
            }
            */
           
            /* change this event to host product response trigger
            for (host_application_response__c ha: [select id,current_application_response__c 
                                                   from host_application_response__c
                                                   where id not in: listCurrentHostAppResponseID
                                                   and opportunity__c in: listOptyID
                                                   and current_application_response__c = true])
            {
                ha.current_application_response__c = false;
                listUpdateHostAppResponseCurrentFalse.add(ha);
            }
            */
            
            if (listCurrentHostAppResponseID.size() > 0){
                for (host_product_response__c hp : [select id from host_product_response__c 
                                                    where Host_Application_Response__c in: listCurrentHostAppResponseID])
                                                    //and Host_Application_Response__r.current_application_response__c = true])
                {
                    listDeleteProductResponse.add(hp);
                }
            }
            
            if (listOptySendEmail.size() > 0){
                SLOSEmailService.emailOppStageMappingNotFound(listOptySendEmail);
            }
                
            if (listDeleteProductResponse.size() > 0){
                delete listDeleteProductResponse;
            }
            /*
            if (listUpdateHostAppResponseCurrentFalse.size() > 0){
                update listUpdateHostAppResponseCurrentFalse;
            }
            */          
            if (listUpdateOpty.size() > 0){
                update listUpdateOpty;
            }

        }catch(exception ex){
            system.debug('Line number - ' + ex.getLineNumber() + ' Error - ' + ex.getMessage());
        }
    }
    
    public static map<string,string> OppstageList {
    get
    {
        if(OppstageList == null){
            OppstageList = new map<string,string>();
            for (Opportunity_Stage_Mapping__c os : [SELECT Name,Application_status__c,Opportunity_Type__c,Stage__c   
                                                    ,Host_System__c ,Result__c 
                                                    FROM Opportunity_Stage_Mapping__c
                                                    where Host_System__c = 'SLS'])
            {
                string keymap = '';
                keymap += (os.Host_System__c != null) ? os.Host_System__c : '';
                //keymap += (os.Opportunity_Type__c != null) ? os.Opportunity_Type__c : '';
                keymap += (os.Application_status__c != null) ? os.Application_status__c : '';
                keymap += (os.Result__c != null) ? os.Result__c : '';
                string stage = (os.Stage__c != null) ? os.Stage__c : '';
                
                if (keymap != '' && stage != '')
                    OppstageList.put(keymap, stage);
            }
        }
        return OppstageList;
    }
    set;}
    
    public static map<string,string> mapRecordType {
    get
    {
        if(mapRecordType == null){
            mapRecordType = new map<string,string>();
            for (recordtype rt : [select id,name from recordtype where sobjecttype = 'Opportunity' and isactive = true])
            {
                mapRecordType.put(rt.name,rt.id);
            }
        }
        return mapRecordType;
    }
    set;}
    
    public static map<string,decimal> mapOpportunityStage {
    get
    {
        if(mapOpportunityStage == null){
            mapOpportunityStage = new map<string,decimal>();
            for (opportunityStage os : [select ApiName,defaultProbability from opportunityStage where IsActive = true])
            {
                mapOpportunityStage.put(os.ApiName, os.defaultProbability);
            }
        }
        return mapOpportunityStage;
    }
    set;}
    
    public static opportunity mapFieldOpportunity(host_application_response__c hostAppResponse)
    {
        opportunity oppty = new opportunity(id = hostAppResponse.opportunity__c);
        
        oppty.Host_System__c               = hostAppResponse.Host_System__c;
        oppty.CAID__c                      = hostAppResponse.CRM_ID__c;
        oppty.App_Ref_Number__c            = hostAppResponse.App_Ref_Number__c;
        oppty.Old_App_Ref_Number__c        = hostAppResponse.Old_App_Ref_Number__c;       
        oppty.Amount                       = hostAppResponse.Request_Amt_Vol__c;
        oppty.Approved_Amount__c           = hostAppResponse.Approved_Amount__c;
        oppty.Opportunity_amount_adjust__c = hostAppResponse.Actual_Amount__c;

        oppty.Application_Status__c        = hostAppResponse.Front_End_App_Status__c;
        oppty.Host_Result__c               = hostAppResponse.Front_End_App_Result__c;
        
        oppty.CA_Prep_Start_Date__c        = hostAppResponse.CA_Prep_Start_Date__c;
        oppty.CA_Prep_End_Date__c          = hostAppResponse.CA_Prep_End_Date__c;
        oppty.Approval_Process_Date__c     = hostAppResponse.Approval_Start_Date__c;
        oppty.Approval_End_Date__c         = hostAppResponse.Approval_End_Date__c;
        oppty.Post_Approval_Date__c        = hostAppResponse.Post_Approval_Start_Date__c;
        oppty.Post_Approval_End_Date__c    = hostAppResponse.Post_Approval_End_Date__c;
        oppty.Setup_Date__c                = hostAppResponse.Setup_Date__c;
        
        oppty.RequestAmountfromHost__c     = hostAppResponse.Request_Amt_Vol__c;
        
        string keymap = '';
        keymap += (hostAppResponse.Host_System__c != null) ? hostAppResponse.Host_System__c : '';
        keymap += (hostAppResponse.Front_End_App_Status__c != null) ? hostAppResponse.Front_End_App_Status__c : '';
        keymap += (hostAppResponse.Front_End_App_Result__c != null) ? hostAppResponse.Front_End_App_Result__c : '';

        string stageResult = OppstageList.get(keymap);

        if (stageResult != null && stageResult != ''){
            oppty.stageName = stageResult;
            if (mapOpportunityStage.get(stageResult) != null){
                if (mapOpportunityStage.get(stageResult) >= 95){
                    oppty.recordTypeid = mapRecordType.get('SE Credit Product3');
                }else if (mapOpportunityStage.get(stageResult) < 95){
                    oppty.recordTypeid = mapRecordType.get('SE Credit Product2');
                }
                oppty.Reason_of_Lost__c = '';
            }
            /*
            list<opportunityStage> ops = [select defaultProbability from opportunityStage where ApiName =: stageResult and IsActive = true];
            if (ops.size() > 0){
                if (ops.get(0).defaultProbability >= 95){
                    oppty.recordTypeid = mapRecordType.get('SE Credit Product3');
                }else if (ops.get(0).defaultProbability < 95){
                    oppty.recordTypeid = mapRecordType.get('SE Credit Product2');
                }
                oppty.Reason_of_Lost__c = '';
            }
            */

        }else{
            /*
            list<opportunity> listOptyTemp = [select id,name,Application_Status__c,Host_System__c,Host_Result__c 
                                              from opportunity where id =: hostAppResponse.opportunity__c];
            oppty.name = listOptyTemp.get(0).name;
            */
            oppty.name = mapOpportunityName.get(hostAppResponse.opportunity__c);
            //SLOSEmailService.emailOppStageMappingNotFound(new list<opportunity>{oppty});
            listOptySendEmail.add(oppty);
        }
                
        /*          
        oppty.Host_System__c               = hostAppResponse.Host_System__c;
        oppty.CAID__c                      = hostAppResponse.CRM_ID__c;
        oppty.App_Ref_Number__c            = hostAppResponse.App_Ref_Number__c;
        oppty.Old_App_Ref_Number__c        = hostAppResponse.Old_App_Ref_Number__c;       
        oppty.Amount                       = hostAppResponse.Request_Amt_Vol__c;
        oppty.Approved_Amount__c           = hostAppResponse.Approved_Amount__c;
        oppty.Opportunity_amount_adjust__c = hostAppResponse.Actual_Amount__c;

        oppty.Application_Status__c        = hostAppResponse.Front_End_App_Status__c;
        oppty.Host_Result__c               = hostAppResponse.Front_End_App_Result__c;
        
        oppty.CA_Prep_Start_Date__c        = hostAppResponse.CA_Prep_Start_Date__c;
        oppty.CA_Prep_End_Date__c          = hostAppResponse.CA_Prep_End_Date__c;
        oppty.Approval_Process_Date__c     = hostAppResponse.Approval_Start_Date__c;
        oppty.Approval_End_Date__c         = hostAppResponse.Approval_End_Date__c;
        oppty.Post_Approval_Date__c        = hostAppResponse.Post_Approval_Start_Date__c;
        oppty.Post_Approval_End_Date__c    = hostAppResponse.Post_Approval_End_Date__c;
        oppty.Setup_Date__c                = hostAppResponse.Setup_Date__c;
        */
            
        return oppty;
    }

}