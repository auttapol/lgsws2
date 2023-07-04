global without sharing  class RTL_Distribute_CM_Batch extends RTL_AL_WebserviceAbstract implements Database.Batchable<sObject>
, Database.Stateful
, Database.AllowsCallouts {
    public List<CampaignMember> query;
    public Boolean isRetry;
    private static String ThisCampaignNo = null;
    // private static Integer COUNT_CALLOUT=0;
    private static Integer COUNT_RETRY;
    private static DateTime RefstartDate;
    private static Map<Id, CampaignMember> MapRefwithResult = new Map<Id, CampaignMember>();
    private static Boolean resCode = false;
    private static String cmlogId;

    private static Set<Id> recordAll = new Set<Id>();
    public Set<Id> passRecords;
    private static Set<Id> recordSuccess = new Set<Id>();
    private static Set<Id> recordFail = new Set<Id>();
    private static Map<Id,String> mapCampaignIdwithErrorMsg = new Map<Id,String>();
    public  String getmapEndpoint;
    public  String getkeyAPI;
    private static String mapEndpoint;
    private static String keyAPI;
    
    // private static Map<Id,String> mapCampaignIdwithErrorMsg = new Map<Id,String>();

    public Map<Id,String> mapError = new Map<Id,String>();

    private List<CampaignMember> remain_listcm = new List<CampaignMember>();
    private static Datetime batchDate = DateTime.now();
    private static Datetime batchStartTime = DateTime.now();
    public Datetime startDateTime;
    private static Datetime batchEndTime = null;
    private static String sobjectName = 'Campaign Member';
    private static String jobDailyName = 'AutoLoan-Submit App HPAP';
    private static String CSV_BODY = '';
    private static String csvHeaderStr = '';



    private static final String APPID {
        get {
            if (APPID == null) {
                APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
            }
            return APPID;
        }
        set;
    }
    private static final Integer timeout {
        get {
            if(timeout == null){
                List<App_Config__mdt> tempMetatdata = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Create refer timeout'];
                timeout = tempMetatdata != null && tempMetatdata.size() > 0 ? Integer.valueOf(tempMetatdata.get(0).Value__c) : 120000;
            }
            return timeout;
        }
        set;
    }
    private static List<OnlineServiceLog> lstLogDetail = new List<OnlineServiceLog>();

    public RTL_Distribute_CM_Batch(List<CampaignMember> query, Boolean isRetry, Map<Id,String> mapError, Set<Id> passRecords,Datetime startDateTime,String mapEndpoint,String keyAPI) {
        this.query = query;
        this.isRetry = isRetry;
        this.mapError = mapError;
        this.passRecords = passRecords;
        this.startDateTime = startDateTime;
        this.getkeyAPI = keyAPI;
        this.getmapEndpoint = mapEndpoint;
    }

    global List<CampaignMember> start(Database.BatchableContext bc){

        return this.query;
        
    }
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        List<CampaignMember> campaignmemberlist = scope;
        mapCampaignIdwithErrorMsg = mapError;
        recordAll = passRecords;
        keyAPI = getkeyAPI;
        mapEndpoint = getmapEndpoint;
        batchStartTime = startDateTime;
        String test = ('callout:' + mapEndpoint);

            if(mapCampaignIdwithErrorMsg == null){
                mapCampaignIdwithErrorMsg = new Map<Id,String>();
            }
            if(recordAll == null){
                recordAll = new Set<Id>();
            }
        List<String> retryliststatus = new List<String>{'401','500'};
        String  privateKey = (String)SCSMessageAPIUtil.getScsEncryptKey(keyAPI, SCSMessageAPIUtil.fetchUserSessionId());
            try{
                //    System.debug('Count index : ' + index);
                recordAll.add(campaignmemberlist[0].Id);
                COUNT_RETRY = 0;
                RefstartDate = Datetime.now();
    
                if(isRetry){
                    callhttpCampaignMember(campaignmemberlist[0],privateKey,false); // Batch from Drop lead
                }else{
                    callhttpCampaignMember(campaignmemberlist[0],privateKey,true); // Batch from Scheduler
                }
                }catch(Exception e){
                            //    System.debug('FAIL : ' + campaignmemberlist[index].Id + ' || '+ COUNT_RETRY+' : '+  e );
                               System.debug('Err Line: ' + e.getLineNumber());
    
                            if(isRetry){
                                if((retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')){
                                    while ((COUNT_RETRY < 2) && (retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')) {
                                           System.debug('Retry : ' + COUNT_RETRY );
                                        COUNT_RETRY++;
                                        try{
                                                // MapcmwithId.put(campaignmemberlist[index].Id,campaignmemberlist[index]);
                                                callhttpCampaignMember(campaignmemberlist[0],privateKey,false);
                                        }catch(Exception err){
                                            //    System.debug('FAIL : ' + campaignmemberlist[index].Id + ' || '+ COUNT_RETRY+' : '+  e);
                                            continue;
                                        }
                                    }
                                }
                            
                            }
    
                        }
    
        List<NamedCredential> myNamedCredential = [SELECT Id, DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName =: mapEndpoint Limit 1];   
        String nameCredentialValue = '';    
        if (myNamedCredential.size()>0) {
            nameCredentialValue = myNamedCredential[0].endpoint;
        }
        RTL_CampaignUtil.saveToOnlineLog(lstLogDetail, null, null ,cmlogId, UserInfo.getName() ,true,nameCredentialValue, null, RefstartDate, DateTime.now());
           System.debug('Mapsize ' + MapRefwithResult.size());
        updateField(MapRefwithResult);
            for(CampaignMember each : campaignmemberlist){
                if(!recordAll.contains(each.Id)){
                    remain_listcm.add(each);
                }
            }
           System.debug('remain_listcm Size : ' +remain_listcm.size());
        mapError = mapCampaignIdwithErrorMsg;
        passRecords = recordAll;
        //if(remain_listcm.size() == 0){   
        //   sendemailnotification(mapCampaignIdwithErrorMsg);
        //
        //}
        }
        global void finish(Database.BatchableContext bc){
        if(remain_listcm.size() > 0){
            RTL_Distribute_CM_Batch cmal = new RTL_Distribute_CM_Batch(remain_listcm,isRetry,mapError,passRecords,startDateTime,mapEndpoint,keyAPI);
            Database.executeBatch(cmal);     
        }
    }
    private static void sendemailnotification(Map<Id,String> mapCampaignIdwithErrorMsg){
        // System.debug('Size all records : ' + recordAll.size());
        Integer recordSuccess = recordAll.size() - mapCampaignIdwithErrorMsg.size();
        
        batchEndTime = DateTime.now();
        Integer recordsFailed = mapCampaignIdwithErrorMsg.size();
        // System.debug('Size recordsFailed : ' + recordsFailed);
        // System.debug('mapCampaignIdwithErrorMsg size : ' + mapCampaignIdwithErrorMsg.size());
        try {
                csvHeaderStr = csvHeaderStr + 
                        'CampaignMember Id' + ',' +
                        'Error Message';
                List<String> emailOpsList = new List<String>();
                for(Id ID : mapCampaignIdwithErrorMsg.keySet()){
                    
                    String errorMsg = mapCampaignIdwithErrorMsg.get(ID); 
                    
                    // System.debug(errorMsg);           

                    CSV_BODY = CSV_BODY + 
                        ID + ',' +
                        mapCampaignIdwithErrorMsg.get(ID) + ',' + '\n';
                }

            
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                                , batchStartTime
                                                                , batchEndTime
                                                                , recordSuccess
                                                                , recordsFailed
                                                                , csvHeaderStr
                                                                , jobDailyName
                                                                , sobjectName
                                                                , emailOpsList
                                                                , CSV_BODY);
            // }
        } catch (Exception e) {
            system.debug('Cannot send email' + e.getMessage());
        }
    }
    private static void callhttpCampaignMember(CampaignMember eachCampaign, String privateKey, Boolean isFromScheduler){
        System.debug('START callAPIcreateReferral !!!');
        Datetime startDate = Datetime.now();
        Uuid uuidGenerateor = new Uuid();
        String uuid = uuidGenerateor.getValue();
        cmlogId = uuid;
        // List<String> valid_product = new List<String>{'CYC','CYB','NEW','USED'};
                    
        String bodyRequestRaw = JSON.serializePretty(CmbbodyRequest(eachCampaign));
        String bodyRequestEncrypt = SCSMessageAPIUtil.encryptMessageWithKey(bodyRequestRaw, privateKey);
        // System.debug('Request body : ' + bodyRequestRaw);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuid);
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:' + mapEndpoint);
        req.setBody(bodyRequestEncrypt);
        req.setTimeout(timeout);
        String bodyResponse = null;
        try{
            HttpResponse response = http.send(req);
            if (response.getStatusCode() == 200) {
                System.debug('RTL_AL_SubmitHPAPCtrl | callAPIcreateReferral | response : ' +response.getBody());
                resCode = true;
            }
            if(isFromScheduler){
                // System.debug('Stamp Batch Retry Date');
                eachCampaign.Batch_Retry_Date__c = Date.today();
            }else{
                eachCampaign.createReferDate__c = Datetime.now();
            }
            String bodyResonseDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), privateKey);
            // System.debug('Response : ' + bodyResonseDecrypt);
            Map<String, Object> result = bodyResonseDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(bodyResonseDecrypt) : new Map<String, Object>();
            String statusCode = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseCode', result) : '999');
            String errorMsg = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseDetail', result) : AbstractCoreClass.getValuesWithRegex(response.getBody(), new List<String>{'errordesc'}));
            Boolean isSuccess = statusCode == '000';
            bodyResponse = bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt);
            if((isSuccess && response.getStatusCode() == 200)){
                String ResponseDetail = (String)result.get('ResponseDetail');
                eachCampaign.WS_Response_Detail__c = ResponseDetail;
                eachCampaign.RTL_Is_Interface_Success__c = true;
                eachCampaign.RTL_Is_Send_To_HPAP__c = true;
                eachCampaign.RTL_AL_Refer_No_1__c = (String)result.get('RefNo');
                eachCampaign.HPAP_Status_Code_1__c = (String)result.get('HPAPStatus');
                eachCampaign.RTL_Status_1__c = (String)result.get('HPAPStatusDesc');
                // eachCampaign.Details_of_Status_1__c = (String)result.get('Remark');
                eachCampaign.Corebank_Emp_Id_1__c = (String)result.get('EmpID');
                eachCampaign.Corebank_Emp_Name_1__c = (String)result.get('EmpName');
                eachCampaign.Corebank_Emp_Phone_No_1__c = (String)result.get('EmpMobileNo');
                eachCampaign.RTL_Hub_Code_1__c = (String)result.get('HubCode');
                eachCampaign.RTL_Hub_Name_1__c = (String)result.get('HubName');

                eachCampaign.RTL_Contact_Status__c = 'New';
                eachCampaign.RTL_OfferResult_Product_1__c = 'Referred';
                OnlineServiceLog createlog = new OnlineServiceLog(true,null,bodyRequestRaw, bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt),eachCampaign.RTL_Marketing_Code__c);
                lstLogDetail.add(createlog);
                // System.debug('Success!');
                ThisCampaignNo = (String)result.get('RefCode3');
                MapRefwithResult.put(eachCampaign.Id,eachCampaign);
                recordSuccess.add(eachCampaign.Id);
                //updateField(eachCampaign);
            }else{
                if(errorMsg == null){
                    errorMsg = String.valueOf(response.getStatusCode());
                }
                if(errorMsg.length() > 255){
                    errorMsg = errorMsg.left(255);
                }
                eachCampaign.WS_Response_Detail__c = errorMsg;
                MapRefwithResult.put(eachCampaign.Id,eachCampaign);
                mapCampaignIdwithErrorMsg.put(eachCampaign.Id,errorMsg);
                System.debug('Status 200 but ' + isSuccess + response.getStatusCode() + statusCode );
                // OnlineServiceLog createlog = new OnlineServiceLog(false,errorMsg,bodyRequestRaw, bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt));
                // lstLogDetail.add(createlog);
                CalloutException e = new CalloutException();
                e.setMessage(errorMsg);
                throw e;
            }
        }catch(Exception e){
            System.debug('Error message --> ' + e.getMessage() + ' Line:' +e.getLineNumber());
            System.debug('Error send Http : ' + e);
            resCode = false;
            OnlineServiceLog createlog = new OnlineServiceLog(false,e.getMessage(),bodyRequestRaw, bodyResponse,eachCampaign.RTL_Marketing_Code__c);
            lstLogDetail.add(createlog);
            System.debug('callAPIcreateReferral | getMessage : ' + e.getMessage());
            System.debug('callAPIcreateReferral | getLineNumber : ' + e.getLineNumber());

            mapCampaignIdwithErrorMsg.put(eachCampaign.Id,e.getMessage());
            throw e;    
        }

    }    
        
        public static Map<String, Object> CmbbodyRequest(CampaignMember cmb){
            String refcode2 = null;
            if(cmb.RTL_Marketing_Code__c != null){
                refcode2 = cmb.RTL_Marketing_Code__c;
            }else if(cmb.RTL_Web_Unique_ID__c != null){
                refcode2 = cmb.RTL_Web_Unique_ID__c;
            }
            String IdCardType = '';
            String IdCardNo = '';
            String FirstName = '';
            String SurName = '';

            if(cmb.Customer__c != null){
                IdCardType = cmb.Customer__r.ID_Type_PE__c;
                IdCardNo = cmb.Customer__r.ID_Number_PE__c;
                FirstName = cmb.Customer__r.First_name_PE__c;
                SurName = cmb.Customer__r.Last_name_PE__c;
            }else if(cmb.LeadId != null){
                IdCardType = cmb.Lead.RTL_ID_Type__c;
                IdCardNo = cmb.Lead.RTL_Citizen_Id__c;
                FirstName = cmb.Lead.FirstName;
                SurName = cmb.Lead.LastName;
            }
            return new Map<String, Object> {
                'RefCode'=> cmb.RTL_AL_oa_ref_code__c != null ? cmb.RTL_AL_oa_ref_code__c : '',
                'RefCode2'=> refcode2,
                'ObjectType'=>'Campaign Member',
                'LeadSource'=> cmb.LeadSource != null ? cmb.LeadSource : '',
                'CampaignSource'=> cmb.RTL_TMB_Campaign_Source__c != null ? cmb.RTL_TMB_Campaign_Source__c : '',
                'Product'=> cmb.RTL_Campaign_Product_1__c != null ? cmb.RTL_Campaign_Product_1__r.Name != null ? cmb.RTL_Campaign_Product_1__r.Name : '' : '',
                'CarTypeDesc'=> cmb.RTL_AL_car_type__c != null ? cmb.RTL_AL_car_type__c : '',
                'CarBrand'=> cmb.RTL_AL_car_brand__c != null ? cmb.RTL_AL_car_brand__c : '',
                'CarModel'=> cmb.RTL_AL_car_group__c != null ? cmb.RTL_AL_car_group__c : '',
                'CarSubModel'=> cmb.RTL_AL_car_subtype__c != null ? cmb.RTL_AL_car_subtype__c : '',
                'CarGear'=> cmb.RTL_AL_car_gear__c != null ? cmb.RTL_AL_car_gear__c : '',
                'CarYear'=> cmb.RTL_AL_car_year__c != null ? cmb.RTL_AL_car_year__c : '',
                'CarPrice'=> cmb.RTL_AL_normal_price__c != null ? cmb.RTL_AL_normal_price__c : null,
                'FinAmt'=> cmb.RTL_AL_wanted_amount__c != null ? cmb.RTL_AL_wanted_amount__c : null,
                'MaxSetupAmt'=> cmb.RTL_AL_max_set_up_amount__c != null ? cmb.RTL_AL_max_set_up_amount__c : null,
                'InstallmentPeriod'=> cmb.RTL_AL_installment_periods__c != null ? cmb.RTL_AL_installment_periods__c : '',
                'PayPerMonth'=> cmb.RTL_AL_PayPerMonth__c != null ? cmb.RTL_AL_PayPerMonth__c : null,
                'DownPercent'=> cmb.RTL_AL_DownPercent__c != null ? cmb.RTL_AL_DownPercent__c : null,
                'DownAmt'=> cmb.RTL_AL_DownAmt__c != null ? cmb.RTL_AL_DownAmt__c : null,
                'InstallmentAmt'=> cmb.RTL_AL_installment_amount__c != null ? cmb.RTL_AL_installment_amount__c : null,
                'IDCardNo'=> IdCardNo,
                'IDCardType'=> IdCardType,
                'Name'=> FirstName,
                'Surname'=> SurName,
                'MobileNo'=> cmb.RTL_CampHis_Phone__c != null ? cmb.RTL_CampHis_Phone__c : '',
                'Email'=> cmb.Customer__c != null ? cmb.Customer__r.Email_Address_PE__c != null ? cmb.Customer__r.Email_Address_PE__c : '' : '',
                'ContactPeriod'=> cmb.RTL_AL_available_time__c != null ? cmb.RTL_AL_available_time__c: '',
                'ContactZipcode'=> cmb.RTL_AL_ContactZipcode__c != null ? cmb.RTL_AL_ContactZipcode__c: '',
                'ContactProvince'=> cmb.RTL_AL_ContactProvince__c != null ? cmb.RTL_AL_ContactProvince__c : '',
                'ContactDistrict'=> cmb.RTL_AL_ContactDistrict__c != null ? cmb.RTL_AL_ContactDistrict__c : '',
                'ContactSubDistrict'=> cmb.RTL_AL_ContactSubDistrict__c!= null ? cmb.RTL_AL_ContactSubDistrict__c : '',
                'PreferService'=> cmb.RTL_AL_contact_channel__c != null ? cmb.RTL_AL_contact_channel__c : '',
                'CarBooked'=> cmb.RTL_AL_IsCarBooked__c != null ? cmb.RTL_AL_IsCarBooked__c : '',
                'Showroom'=> cmb.RTL_AL_Showroom__c != null ? cmb.RTL_AL_Showroom__c : '',
                'CarSource'=> cmb.RTL_AL_car_bought_from__c != null ? cmb.RTL_AL_car_bought_from__c : '',
                'TentName'=> cmb.RTL_AL_TentName__c != null ? cmb.RTL_AL_TentName__c : '',
                'BranchCode'=> cmb.RTL_Branch_Code__c != null ? cmb.RTL_Branch_Code__c : '',
                'BranchName' => '',
                'BranchZipcode' => '',
                'BranchProvince' => '',
                'BranchDistrict' => '',
                'EmpId'=> cmb.Assigned_Agent_ID__c != null && cmb.RTL_AL_contact_channel__c == 'BR' ? cmb.Assigned_Agent_ID__c : '',
                'RMNo'=> cmb.Customer__c != null ? cmb.Customer__r.ID_Number_PE__c != null ? cmb.Customer__r.ID_Number_PE__c : '' : '',
                'PlateNo'=> cmb.RTL_AL_car_plate_no__c != null ? cmb.RTL_AL_car_plate_no__c : '',
                'ProvincePlateNo'=> cmb.RTL_AL_province_car_plate_no__c != null ? cmb.RTL_AL_province_car_plate_no__c :'',
                'RTLComment'=> cmb.RTL_AL_comment__c != null ? cmb.RTL_AL_comment__c : '',
                'RTLComment2'=>'',
                'RTLComment3'=> '',
                // 'LGS_Refcode' => cmb.Id,
                // 'LGS_Campaign_ID' => cmb.CampaignId,
                // 'LGS_Campaign_Name' => cmb.Campaign.Name,
                // 'LGS_Source_Group' => cmb.LeadSource != null ? cmb.LeadSource : '',
                'LGS_Partner'=> cmb.LGS_Partner__c != null ? cmb.LGS_Partner__c : '',
                'LGS_Lead_Received_Time'=> cmb.LGS_Lead_Received_Time__c != null ? cmb.LGS_Lead_Received_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null,
                'LGS_Campaign_Start_Date' => cmb.LGS_Campaign_Start_Date__c  != null ? cmb.LGS_Campaign_Start_Date__c  : null,
                'LGS_Campaign_End_Date' => cmb.LGS_Campaign_End_Date__c  != null ? cmb.LGS_Campaign_End_Date__c  : null,
                'LGS_Interest' => cmb.RTL_AL_Interested_Rate__c != null ? cmb.RTL_AL_Interested_Rate__c : null,
                // 'LGS_Assign_Rule'=> cmb.LGS_Assign_Rule__c != null ? cmb.LGS_Assign_Rule__c : '',
                // 'LGS_Car_Brand_Showroom_ID'=> cmb.LGS_Car_Brand_Showroom_ID__c != null ? cmb.LGS_Car_Brand_Showroom_ID__c : '',
                // 'LGS_Dealer_Showroom_ID'=> cmb.LGS_Dealer_Showroom_ID__c != null ? cmb.LGS_Dealer_Showroom_ID__c : '',
                'LGS_001'=> cmb.LGS_001__c != null ? cmb.LGS_001__c : '',
                'LGS_002'=> cmb.LGS_002__c != null ? cmb.LGS_002__c : '',
                'LGS_003'=> cmb.LGS_003__c != null ? cmb.LGS_003__c : '',
                'LGS_004'=> cmb.LGS_004__c != null ? cmb.LGS_004__c : '',
                'LGS_005'=> cmb.LGS_005__c != null ? cmb.LGS_005__c : '',
                'LGS_006'=> cmb.LGS_006__c != null ? cmb.LGS_006__c : '',
                'LGS_007'=> cmb.LGS_007__c != null ? cmb.LGS_007__c : '',
                'LGS_008'=> cmb.LGS_008__c != null ? cmb.LGS_008__c : '',
                'LGS_009'=> cmb.LGS_009__c != null ? cmb.LGS_009__c : '',
                'LGS_010'=> cmb.LGS_010__c != null ? cmb.LGS_010__c : null,
                'LGS_011'=> cmb.LGS_011__c != null ? cmb.LGS_011__c : null,
                'LGS_012'=> cmb.LGS_012__c != null ? cmb.LGS_012__c : null,
                'LGS_013'=> cmb.LGS_013__c != null ? cmb.LGS_013__c : null,
                'LGS_014'=> cmb.LGS_014__c != null ? cmb.LGS_014__c : null,
                'LGS_015'=> cmb.LGS_015__c != null ? cmb.LGS_015__c : null,
                'LGS_016'=> cmb.LGS_016__c != null ? cmb.LGS_016__c : null,
                'LGS_017'=> cmb.LGS_017__c != null ? cmb.LGS_017__c : null,
                'LGS_018'=> cmb.LGS_018__c != null ? cmb.LGS_018__c : null,
                'LGS_019'=> cmb.LGS_019__c != null ? cmb.LGS_019__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null,
                'LGS_020'=> cmb.LGS_020__c != null ? cmb.LGS_020__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null,
                'LGS_Assignment_Code'=> cmb.LGS_Assignment_Code__c != null ? cmb.LGS_Assignment_Code__c : '',
                'LGS_LinkInfo'=> cmb.LGS_LinkInfo__c != null ? cmb.LGS_LinkInfo__c : '',
                'LGS_BrandCode'=> cmb.LGS_BrandCode__c != null ? cmb.LGS_BrandCode__c : '',
                'LGS_BrandShowroomCode'=> cmb.LGS_BrandShowroomCode__c != null ? cmb.LGS_BrandShowroomCode__c : '',
                'LGS_PartnerCode'=> cmb.LGS_PartnerCode__c != null ? cmb.LGS_PartnerCode__c : '',
                'LGS_ChildCampaignID'=> cmb.LGS_Child_Campaign_ID__c != null ? cmb.LGS_Child_Campaign_ID__c : '',
                'LGS_Campaign_Name'=> cmb.RTL_W2L_Campaign_Name__c != null ? cmb.RTL_W2L_Campaign_Name__c : '',
                'LeadScore'=> cmb.Lead_Score__c != null ? cmb.Lead_Score__c : null,
                'LeadScorelevel'=> cmb.Lead_Score_level__c != null ? cmb.Lead_Score_level__c : '',
                'LGS_VIN_No'=> cmb.LGS_VIN_No__c != null ? cmb.LGS_VIN_No__c : '',
                'LGS_WebUniqueID'=> cmb.RTL_Web_Unique_ID__c != null ? cmb.RTL_Web_Unique_ID__c : '',
                'LGS_File_Upload'=> cmb.LGS_File_Upload__c != null ? cmb.LGS_File_Upload__c : ''
        };
        
    }

    public static void updateField(Map<Id, CampaignMember> mapCM){
        if(mapCM.size() > 0){
            List<CampaignMember> updateCM = new List<CampaignMember>();
            for(CampaignMember each : mapCM.values()){
                // each.RTL_Is_Interface_Success__c = true;
                // each.RTL_Is_Send_To_HPAP__c = true;
                updateCM.add(each);
                }
            
            update updateCM;
            }
        }
}