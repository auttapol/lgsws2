public with sharing class RTL_SubmitReferralToALAPPCtrl extends RTL_AL_WebserviceAbstract {
    public class HPAP_Response_Detail{
        @AuraEnabled public String RefNo = null;
        @AuraEnabled public String ErrMsg = null;
    }
    public class Referral_Detail{
        @AuraEnabled public String RefNo = null;
        @AuraEnabled public Boolean isSend = false;
        @AuraEnabled public Boolean isSendDone = false;
        @AuraEnabled public Boolean isAccess = true;
    }
    private static String ThisRefNo = null;
    private static Integer COUNT_RETRY;
    private static String reflogId;
    private static Boolean resCode = false;
    private static DateTime RefstartDate;
    private static List<OnlineServiceLog> lstLogDetail = new List<OnlineServiceLog>();
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
    public static User currentUser{
        get{
            if(currentUser ==null){
                currentUser = [SELECT Id,Name,Employee_ID__c ,Segment__c ,Reporting_Segment__c ,
                                        Region__c ,Region_Code__c ,Zone__c ,Zone_Code__c ,RTL_Branch_Code__c ,
                                        RTL_Branch__c ,RTL_Channel__c,UserRole.Name,Profile.Name
                                FROM User
                               WHERE Id =: System.UserInfo.getUserId()];
            }
            return currentUser;
            
        }
        set;
    }
    private static final String RefLeadSource {
        get {
            if(RefLeadSource == null){
                List<App_Config__mdt> tempMetatdata = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Referral Lead Source'];
                RefLeadSource = tempMetatdata != null && tempMetatdata.size() > 0 ? String.valueOf(tempMetatdata.get(0).Value__c) : 'ALSAL';
            }
            return RefLeadSource;
        }
        set;
    }
    private static final String RefLGSPartner {
        get {
            if(RefLGSPartner == null){
                List<App_Config__mdt> tempMetatdata = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Referral LGS Partner Default'];
                RefLGSPartner = tempMetatdata != null && tempMetatdata.size() > 0 ? String.valueOf(tempMetatdata.get(0).Value__c) : 'AL Advisory Line';
            }
            return RefLGSPartner;
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

    @AuraEnabled
    public static Referral_Detail getRecord(Id recordId){
        Referral_Detail RefDetail = new Referral_Detail();
        RTL_Referral__c ref = [SELECT Id, RTL_AL_Refer_No__c, RTL_Is_Send_To_HPAP__c,Is_Send_to_HPAP_Done__c,RTL_Is_Owner__c,RTL_From_Call_Me_Now__c FROM RTL_Referral__c WHERE Id =: recordId LIMIT 1];
        RefDetail.isSend = ref.RTL_Is_Send_To_HPAP__c;
        RefDetail.RefNo = ref.RTL_AL_Refer_No__c;
        RefDetail.isSendDone = ref.Is_Send_to_HPAP_Done__c;

        UserRecordAccess recordAccess = [SELECT RecordId,HasEditAccess, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                                     FROM UserRecordAccess
                                                     WHERE UserId =: System.UserInfo.getUserId()
                                                     AND RecordId =: recordId];

        if(currentUser.Profile.Name.containsIgnoreCase('App External API') == false )
        {
            if((currentUser.Profile.Name.containsIgnoreCase('Retail') == true || recordAccess != null && recordAccess.HasTransferAccess == false) && 
            ref.RTL_Is_Owner__c == false  && ref.RTL_From_Call_Me_Now__c == false ){
                RefDetail.isAccess = false;
            }
        }
        System.debug('Is Send ? ' + ref.RTL_Is_Send_To_HPAP__c);
        return RefDetail;
    }

    @AuraEnabled
    public static HPAP_Response_Detail submitALALPP(Id rec){
        HPAP_Response_Detail ReturnValue = new HPAP_Response_Detail();
        System.debug('RecordId ' + rec);
        List<RTL_Referral__c> referral = Database.query(String.format('SELECT {0} FROM RTL_Referral__c WHERE Id =: rec LIMIT 1', 
            new List<String>{
                String.join(refFields, ',')
            }
        ));
        System.debug('Size' + referral.size());

        String Status = null;

        if(referral.size() > 0){
            System.debug(referral);
            RTL_Referral__c eachRef = referral[0];
            Id accId = eachRef.RTL_Account_Name__c;
            String RefName = eachRef.Name;
            //List<String> retryliststatus = new List<String>{'401','500'};
                COUNT_RETRY = 0;
                try{
                    RefstartDate = Datetime.now();
                    callhttpReferral(eachRef);
                }catch(Exception e){
                    System.debug('TRY FAIL : ' + COUNT_RETRY + ' : '+  e);
                    Datetime ErrDateTime = Datetime.now();
                    //String ErrMsg = null;
                    if(e.getMessage().contains('Failed Cache.Org.put()') || e.getMessage().contains('Read timed out')){
                        OnlineServiceLog createlog = new OnlineServiceLog(false,e.getMessage(),'','');
                        lstLogDetail.add(createlog);
                    }
                    Status = e.getMessage();  

                    // if((retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')){
                    //     while ((COUNT_RETRY < 2) && (retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')) { // 0
                    //         System.debug('Retry : ' + COUNT_RETRY );
                    //         COUNT_RETRY++; //1 2 3
                    //         Datetime startDate = Datetime.now();
                    //         try{
                    //             callhttpReferral(eachRef); // 1 2 3
                    //         }catch(Exception err){
                    //             System.debug('TRY FAIL : ' + COUNT_RETRY + ' : '+  err);
                    //             // if(resCode == false){
                    //             //     OnlineServiceLog createlogRetry = new OnlineServiceLog(false,err.getMessage(),'','');
                    //             //     lstLogDetail.add(createlogRetry);
                    //             // }
                    //             //if(COUNT_RETRY == 2){
                    //                 ErrMsg = err.getMessage();
                    //                 Status = ErrMsg;
                    //             //}
                    //             continue;
                    //         }
                    //     }
                    // }
                }
                if(accId != null){
                Account acc = [SELECT Id,Name,Core_Banking_Suggested_Segment__c FROM ACCOUNT WHERE Id =: accId LIMIT 1];
                    RTL_CampaignUtil.saveToOnlineLog(lstLogDetail, acc.Name, null ,reflogId, UserInfo.getName() ,RefName, getServiceName(SERVICENAME.CreateRefer), acc, RefstartDate, DateTime.now());
                }else{
                    RTL_CampaignUtil.saveToOnlineLog(lstLogDetail, null, null ,reflogId, UserInfo.getName() ,RefName, getServiceName(SERVICENAME.CreateRefer), null, RefstartDate, DateTime.now());
                }
                 //List SeviceLog, customername, Err, msLogId, userName, refId, serviceName, acc, startTime, endTime
                if(ThisRefNo == null && Status != null){
                    System.debug('Update Field!');
                    updateField(eachRef,false,null);
                }
            }else{
                System.debug('No record Found');
                // CalloutException e = new CalloutException();
                // e.setMessage('No record Found');
                Status = 'No record Found';
            }

            ReturnValue.ErrMsg = Status;
            ReturnValue.RefNo = ThisRefNo;

            return ReturnValue;
        }

        public static void callhttpReferral(RTL_Referral__c eachRef){
            System.debug('START callAPIcreateReferral !!!');
            Datetime startDate = Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            String uuid = uuidGenerateor.getValue();
            reflogId = uuid;
            Set<String> valid_product = ALPrdNameSet;
            if(eachRef.RTL_Product_Name__c != null && eachRef.RTL_Preferred_Branch__c != null && valid_product.contains(eachRef.RTL_Product_Name_Str__c) && eachRef.RTL_Preferred_Branch_Name__c == 'AL Marketing'){
                if(eachRef.RTL_Type__c == 'Sell (เพื่อนำเสนอขาย)'){
                    if(eachRef.RTL_FirstName__c != null && eachRef.RTL_LastName__c != null && eachRef.RTL_Mobile1__c != null && eachRef.RTL_AL_ContactProvince__c != null && eachRef.RTL_AL_ContactDistrict__c != null &&
                    eachRef.RTL_AL_ContactSubDistrict__c != null && eachRef.RTL_AL_contact_channel__c != null){
                    // try{
                        String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
                        String bodyRequestRaw = JSON.serializePretty(RefbodyRequest(eachRef));
                        String bodyRequestEncrypt = SCSMessageAPIUtil.encryptMessageWithKey(bodyRequestRaw, privateKey);
                        System.debug('Request body : ' + bodyRequestRaw);

                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setMethod('POST');
                        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
                        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
                        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
                        req.setHeader('Request-UID', uuid);
                        req.setHeader('Request-App-ID', APPID);
                        req.setEndpoint('callout:RTL_AL_SubmitApp_HPAP');
                        req.setBody(bodyRequestEncrypt);
                        req.setTimeout(timeout);
                        HttpResponse response = http.send(req);
                        if (response.getStatusCode() == 200) {
                            System.debug('RTL_AL_SubmitHPAPCtrl | callAPIcreateReferral | response : ' +response.getBody());
                        }else{
                            OnlineServiceLog createlog = new OnlineServiceLog(false,String.valueOf(response.getStatusCode()),bodyRequestRaw,null);
                            lstLogDetail.add(createlog);
                            System.debug(response.getStatusCode());
                            CalloutException e = new CalloutException();
                            e.setMessage(String.valueOf(response.getStatusCode()));
                            throw e;                                        
                        }
                        String bodyResonseDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), privateKey);
                        System.debug('Response : ' + bodyResonseDecrypt);
                        Map<String, Object> result = bodyResonseDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(bodyResonseDecrypt) : new Map<String, Object>();
                        String statusCode = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseCode', result) : '999');
                        String errorMsg = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseDetail', result) : AbstractCoreClass.getValuesWithRegex(response.getBody(), new List<String>{'errordesc'}));
                        Boolean isSuccess = statusCode == '000';
                        if((isSuccess && response.getStatusCode() == 200)){
                            String ResponseDetail = (String)result.get('ResponseDetail');
                            System.debug('Response Detail :' + ResponseDetail);
                            eachRef.WS_Response_Detail__c = ResponseDetail;
                            eachRef.HPAP_Status_Code__c = (String)result.get('HPAPStatus');
                            eachRef.RTL_Status__c = (String)result.get('HPAPStatusDesc');
                            // eachRef.Details_of_Status__c = (String)result.get('Remark');
                            eachRef.Corebank_Emp_Id__c = (String)result.get('EmpID');
                            eachRef.Corebank_Emp_Name__c = (String)result.get('EmpName');
                            eachRef.Corebank_Emp_Phone_No__c = (String)result.get('EmpMobileNo');
                            eachRef.RTL_Hub_Code__c = (String)result.get('HubCode');
                            eachRef.RTL_Hub_Name__c = (String)result.get('HubName');
                            OnlineServiceLog createlog = new OnlineServiceLog(true,bodyRequestRaw, bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt));
                            lstLogDetail.add(createlog);
                            System.debug('Success!');
                            ThisRefNo = (String)result.get('RefNo');
                
                            updateField(eachRef,true,(String)result.get('RefNo'));
                        }else{
                            System.debug('WS_Response_Detail__c' + errorMsg.length());
                            if(errorMsg.length() > 255){
                                errorMsg = errorMsg.left(255);
                            }
                            eachRef.WS_Response_Detail__c = errorMsg;
                            System.debug('Status 200 but ' + isSuccess + response.getStatusCode() + COUNT_RETRY + statusCode );
                            OnlineServiceLog createlog = new OnlineServiceLog(false,errorMsg,bodyRequestRaw, bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt));
                            lstLogDetail.add(createlog);
                            CalloutException e = new CalloutException();
                            e.setMessage(errorMsg);
                            throw e;
                        }
                    }else{
                        System.debug('Error field not valid!');
                        CalloutException e = new CalloutException();
                        e.setMessage('Error field not valid!');
                        throw e;
                    }
                }else{
                    System.debug('ประเภทการ Refer ไม่เท่ากับ Sell (เพื่อนำเสนอขาย)');
                    CalloutException e = new CalloutException();
                    e.setMessage('ประเภทการ Refer ไม่เท่ากับ Sell (เพื่อนำเสนอขาย)');
                    throw e;
                }
            }else{
                System.debug('ขื่อผลิตภัณฑ์ (CYC, CYB, NEW, USED) หรือสาขาที่ลูกค้าอยากใช้บริการ (AL Marketing เท่านั้น)ไม่ถูกต้อง');
                CalloutException e = new CalloutException();
                e.setMessage('ขื่อผลิตภัณฑ์ (CYC, CYB, NEW, USED) หรือสาขาที่ลูกค้าอยากใช้บริการ (AL Marketing เท่านั้น)ไม่ถูกต้อง');
                throw e;
            }
            System.debug('STOP callAPIcreateReferral !!!');
        }
    public static Map<String, Object> RefbodyRequest(RTL_Referral__c ref) {
        String IdcardNo = null;
        String Idcardtype = null;
        String FName = null;
        String LName = null;
        //String mobile = null;
        if(ref.RTL_Account_Name__c != null){
            IdcardNo =ref.RTL_Account_Name__r.ID_Number_PE__c; 
            Idcardtype = ref.RTL_Account_Name__r.ID_Type_PE__c;
            FName= ref.RTL_Account_Name__r.First_name_PE__c;
            LName = ref.RTL_Account_Name__r.Last_name_PE__c;
            //mobile = ref.RTL_Account_Name__r.Mobile_Number_PE__c;
        } else {
            IdcardNo = ref.RTL_Citizen_Id__c;
            Idcardtype = ref.RTL_ID_Type__c;
            FName = ref.RTL_FirstName__c;
            LName = ref.RTL_LastName__c;
            //mobile = ref.RTL_Mobile1__c;
        }
        String CarBooked = '';
        if(ref.RTL_AL_CarBooked__c) { 
            CarBooked = '1' ; 
        }else{
            CarBooked = '0' ; 
        }

        String cmid = ref.RTL_Campaign_Member__c ;
        List<CampaignMember> cmb = [SELECT RTL_Web_Unique_ID__c,LGS_Partner__c,LGS_Lead_Received_Time__c,RTL_AL_Interested_Rate__c,LGS_001__c,LGS_002__c,LGS_003__c,LGS_004__c,
                            LGS_005__c,LGS_006__c,LGS_007__c,LGS_008__c,LGS_009__c,LGS_010__c,LGS_011__c,LGS_012__c,LGS_013__c,LGS_014__c,LGS_015__c,
                            LGS_016__c,LGS_017__c,LGS_018__c,LGS_019__c,LGS_020__c,RTL_W2L_Campaign_Name__c,LGS_Campaign_Start_Date__c,LGS_Campaign_End_Date__c   
                            FROM CampaignMember WHERE ID =: cmid LIMIT 1];

        return new Map<String, Object> {
            'RefCode'=> ref.RTL_AL_oa_ref_code__c != null ? ref.RTL_AL_oa_ref_code__c : '',
            'RefCode2'=> ref.Id != null ? ref.Id : '',
            'ObjectType'=>'Referral',
            // 'Channel'=> 'AL Advisory Line',
            'LeadSource'=> ref.RTL_LeadSource__c != null ? ref.RTL_LeadSource__c : RefLeadSource,
            'CampaignSource'=> ref.RTL_TMB_Campaign_Source__c != null ? ref.RTL_TMB_Campaign_Source__c : '',
            'Product'=> ref.RTL_Product_Name_Str__c != null ? ref.RTL_Product_Name_Str__c : '',
            'CarTypeDesc'=> ref.RTL_AL_car_type__c != null ? ref.RTL_AL_car_type__c : '',
            'CarBrand'=> ref.RTL_AL_car_brand__c != null ? ref.RTL_AL_car_brand__c : '',
            'CarModel'=> ref.RTL_AL_car_group__c != null ? ref.RTL_AL_car_group__c : '',
            'CarSubModel'=> ref.RTL_AL_car_subtype__c != null ? ref.RTL_AL_car_subtype__c : '',
            'CarGear'=> ref.RTL_AL_car_gear__c != null ? ref.RTL_AL_car_gear__c : '',
            'CarYear'=> ref.RTL_AL_car_year__c != null ? ref.RTL_AL_car_year__c : '',
            'CarPrice'=> ref.RTL_AL_normal_price__c != null ? ref.RTL_AL_normal_price__c : null,
            'FinAmt'=> ref.RTL_AL_wanted_amount__c != null ? ref.RTL_AL_wanted_amount__c : null,
            'MaxSetupAmt'=> ref.RTL_AL_max_set_up_amount__c != null ? ref.RTL_AL_max_set_up_amount__c : null,
            'InstallmentPeriod'=> ref.RTL_AL_installment_periods__c != null ? ref.RTL_AL_installment_periods__c : '',
            'PayPerMonth'=> ref.RTL_AL_PayPerMonth__c != null ? ref.RTL_AL_PayPerMonth__c : null,
            'DownPercent'=> ref.RTL_AL_DownPercent__c != null ? ref.RTL_AL_DownPercent__c : null,
            'DownAmt'=> ref.RTL_AL_DownAmt__c != null ? ref.RTL_AL_DownAmt__c : null,
            'InstallmentAmt'=> ref.RTL_AL_installment_amount__c != null ? ref.RTL_AL_installment_amount__c : null,
            'IDCardNo'=> IdcardNo,
            'IDCardType'=> Idcardtype,
            'Name'=> FName,
            'Surname'=> LName,
            'MobileNo'=> ref.RTL_Mobile1__c != null ? ref.RTL_Mobile1__c : null,
            'Email'=> ref.RTL_Account_Name__c != null ? ref.RTL_Account_Name__r.Email_Address_PE__c != null ? ref.RTL_Account_Name__r.Email_Address_PE__c : '' : '',
            'ContactPeriod'=> ref.RTL_AL_available_time__c != null ? ref.RTL_AL_available_time__c : '',
            'ContactZipcode'=> ref.RTL_AL_ContactZipcode__c != null ? ref.RTL_AL_ContactZipcode__c : '',
            'ContactProvince'=> ref.RTL_AL_ContactProvince__c != null ? ref.RTL_AL_ContactProvince__c : '',
            'ContactDistrict'=> ref.RTL_AL_ContactDistrict__c != null ? ref.RTL_AL_ContactDistrict__c : '',
            'ContactSubDistrict'=> ref.RTL_AL_ContactSubDistrict__c != null ? ref.RTL_AL_ContactSubDistrict__c : '',
            'PreferService'=> ref.RTL_AL_contact_channel__c != null ? ref.RTL_AL_contact_channel__c : '',
            'CarBooked'=> CarBooked,
            'Showroom'=> ref.RTL_AL_Showroom__c != null ? ref.RTL_AL_Showroom__c : '',
            'CarSource'=> ref.RTL_AL_car_bought_from__c != null ? ref.RTL_AL_car_bought_from__c : '',
            'TentName'=> ref.RTL_AL_TentName__c != null ? ref.RTL_AL_TentName__c : '',
            'BranchCode'=> ref.RTL_Preferred_Branch_Code__c != null ? ref.RTL_Preferred_Branch_Code__c : '',
            'BranchName'=> '',
            'BranchZipcode'=> '',
            'BranchProvince'=> '',
            'BranchDistrict'=> '',
            'TcifNo'=> '',
            'EmpId'=> ref.Owner_Emp_ID__c != null && ref.RTL_AL_contact_channel__c == 'BR'? ref.Owner_Emp_ID__c : '',
            // 'ECNo'=> '',
            'RMNo'=> ref.RTL_Account_Name__c != null ? ref.RTL_Account_Name__r.TMB_Customer_ID_PE__c != null ? ref.RTL_Account_Name__r.TMB_Customer_ID_PE__c  : '' : '',
            'PlateNo' => ref.RTL_AL_car_plate_no__c != null ?  ref.RTL_AL_car_plate_no__c : '',
            'ProvincePlateNo' => ref.RTL_AL_province_car_plate_no__c != null ? ref.RTL_AL_province_car_plate_no__c : '',
            'RTLComment' => ref.RTL_Comment__c != null ? ref.RTL_Comment__c : '',
            'RTLComment2' => ref.RTL_Comment2__c != null ? ref.RTL_Comment2__c : '',
            'RTLComment3' => ref.RTL_Comment3__c != null ? ref.RTL_Comment3__c : '',

            //Add from LGS
            'LGS_Partner'=> cmb.size() > 0 ? cmb[0].LGS_Partner__c != null ? cmb[0].LGS_Partner__c : RefLGSPartner : RefLGSPartner,
            'LGS_Lead_Received_Time'=> cmb.size() > 0 ? cmb[0].LGS_Lead_Received_Time__c != null ? cmb[0].LGS_Lead_Received_Time__c : null : null,
            'LGS_Campaign_Start_Date' => cmb.size() > 0 ? cmb[0].LGS_Campaign_Start_Date__c  : null,
            'LGS_Campaign_End_Date' => cmb.size() > 0 ? cmb[0].LGS_Campaign_End_Date__c  : null,
            'LGS_Interest' => cmb.size() > 0 ? cmb[0].RTL_AL_Interested_Rate__c != null ? cmb[0].RTL_AL_Interested_Rate__c : null : null,
            'LGS_001'=> cmb.size() > 0 ? cmb[0].LGS_001__c != null ? cmb[0].LGS_001__c : '' : '',
            'LGS_002'=> cmb.size() > 0 ? cmb[0].LGS_002__c != null ? cmb[0].LGS_002__c : '' : '',
            'LGS_003'=> cmb.size() > 0 ? cmb[0].LGS_003__c != null ? cmb[0].LGS_003__c : '' : '',
            'LGS_004'=> cmb.size() > 0 ? cmb[0].LGS_004__c != null ? cmb[0].LGS_004__c : '' : '',
            'LGS_005'=> cmb.size() > 0 ? cmb[0].LGS_005__c != null ? cmb[0].LGS_005__c : '' : '',
            'LGS_006'=> cmb.size() > 0 ? cmb[0].LGS_006__c != null ? cmb[0].LGS_006__c : '' : '',
            'LGS_007'=> cmb.size() > 0 ? cmb[0].LGS_007__c != null ? cmb[0].LGS_007__c : '' : '',
            'LGS_008'=> cmb.size() > 0 ? cmb[0].LGS_008__c != null ? cmb[0].LGS_008__c : '' : '',
            'LGS_009'=> cmb.size() > 0 ? cmb[0].LGS_009__c != null ? cmb[0].LGS_009__c : '' : '',
            'LGS_010'=> cmb.size() > 0 ? cmb[0].LGS_010__c != null ? cmb[0].LGS_010__c : null : null,
            'LGS_011'=> cmb.size() > 0 ? cmb[0].LGS_011__c != null ? cmb[0].LGS_011__c : null : null,
            'LGS_012'=> cmb.size() > 0 ? cmb[0].LGS_012__c != null ? cmb[0].LGS_012__c : null : null,
            'LGS_013'=> cmb.size() > 0 ? cmb[0].LGS_013__c != null ? cmb[0].LGS_013__c : null : null,
            'LGS_014'=> cmb.size() > 0 ? cmb[0].LGS_014__c != null ? cmb[0].LGS_014__c : null : null,
            'LGS_015'=> cmb.size() > 0 ? cmb[0].LGS_015__c != null ? cmb[0].LGS_015__c : null : null,
            'LGS_016'=> cmb.size() > 0 ? cmb[0].LGS_016__c != null ? cmb[0].LGS_016__c : null : null,
            'LGS_017'=> cmb.size() > 0 ? cmb[0].LGS_017__c != null ? cmb[0].LGS_017__c : null : null,
            'LGS_018'=> cmb.size() > 0 ? cmb[0].LGS_018__c != null ? cmb[0].LGS_018__c : null : null,
            'LGS_019'=> cmb.size() > 0 ? cmb[0].LGS_019__c != null ? cmb[0].LGS_019__c : null : null,
            'LGS_020'=> cmb.size() > 0 ? cmb[0].LGS_020__c != null ? cmb[0].LGS_020__c : null : null,

            'LGS_Assignment_Code'=> ref.LGS_Assignment_Code__c != null ? ref.LGS_Assignment_Code__c : '',
            'LGS_LinkInfo'=> ref.LGS_LinkInfo__c != null ? ref.LGS_LinkInfo__c : '',
            'LGS_BrandCode'=> ref.LGS_BrandCode__c != null ? ref.LGS_BrandCode__c : '',
            'LGS_BrandShowroomCode'=> ref.LGS_BrandShowroomCode__c != null ? ref.LGS_BrandShowroomCode__c : '',
            'LGS_PartnerCode'=> ref.LGS_PartnerCode__c != null ? ref.LGS_PartnerCode__c : '',
            'LGS_ChildCampaignID'=> ref.LGS_Child_Campaign_ID__c != null ? ref.LGS_Child_Campaign_ID__c : '',
            'LGS_Campaign_Name'=> cmb.size() > 0 ? cmb[0].RTL_W2L_Campaign_Name__c != null ? cmb[0].RTL_W2L_Campaign_Name__c : '' : '',
            'LeadScore'=> ref.Lead_Score__c != null ? ref.Lead_Score__c : null,
            'LeadScorelevel'=> ref.Lead_Score_level__c != null ? ref.Lead_Score_level__c : '',
            'LGS_VIN_No'=> ref.LGS_VIN_No__c != null ? ref.LGS_VIN_No__c : '',
            'LGS_WebUniqueID'=> ref.RTL_Web_Unique_ID__c != null ? ref.RTL_Web_Unique_ID__c : '',
            'LGS_File_Upload'=> ref.LGS_File_Upload__c != null ? ref.LGS_File_Upload__c : ''

        };
    }
    private static List<String> refFields {
        get {
            return new List<String>{
                'Id',
                'Name',
                'RTL_AL_oa_ref_code__c',
                'RTL_Product_Name__c',
                'RTL_AL_car_type__c',
                'RTL_AL_car_brand__c',
                'RTL_AL_car_group__c',
                'RTL_AL_car_subtype__c',
                'RTL_AL_car_gear__c',
                'RTL_AL_car_year__c',
                'RTL_AL_normal_price__c',
                'RTL_AL_wanted_amount__c',
                'RTL_AL_max_set_up_amount__c',
                'RTL_AL_installment_periods__c',
                'RTL_AL_PayPerMonth__c',
                'RTL_AL_DownPercent__c',
                'RTL_AL_DownAmt__c',
                'RTL_AL_installment_amount__c',
                'RTL_AL_available_time__c',
                'RTL_AL_ContactZipcode__c',
                'RTL_AL_ContactProvince__c',
                'RTL_AL_ContactDistrict__c',
                'RTL_AL_ContactSubDistrict__c',
                'RTL_AL_contact_channel__c',
                'RTL_AL_CarBooked__c',
                'RTL_AL_Showroom__c',
                'RTL_AL_car_bought_from__c',
                'RTL_AL_TentName__c',
                'RTL_Preferred_Branch_Code__c',
                'RTL_Product_Name_Str__c',
                'Owner_Emp_ID__c',
                'RTL_Mobile1__c',
                'RTL_LastName__c',
                'RTL_FirstName__c',
                'RTL_Citizen_Id__c',
                'RTL_ID_Type__c',
                'RTL_Account_Name__r.Mobile_Number_PE__c',
                'RTL_Account_Name__r.Last_name_PE__c',
                'RTL_Account_Name__r.First_name_PE__c',
                'RTL_Account_Name__r.ID_Number_PE__c',
                'RTL_Account_Name__r.ID_Type_PE__c',
                'RTL_Account_Name__r.Email_Address_PE__c',
                'RTL_Preferred_Branch__c',
                'RTL_Preferred_Branch_Name__c',
                'RTL_EmployeeID__c ',
                'countsendHPAP__c',
                'Is_Update_Refer__c',
                'RTL_Account_Name__c',
                'wsUpdateFlag__c',
                'CheckClickSubmit__c',
                'RTL_Account_Name__r.TMB_Customer_ID_PE__c',
                'RTL_AL_car_plate_no__c',
                'RTL_AL_province_car_plate_no__c',
                'RTL_Comment__c',
                'RTL_Comment2__c',
                'RTL_Comment3__c',
                'RTL_Type__c',
                'RTL_Campaign_Member__c',
                'RTL_LeadSource__c',
                'RTL_TMB_Campaign_Source__c',
                'LGS_Assignment_Code__c',
                'LGS_LinkInfo__c',
                'LGS_BrandCode__c',
                'LGS_BrandShowroomCode__c',
                'LGS_PartnerCode__c',
                'Lead_Score__c',
                'Lead_Score_level__c',
                'LGS_VIN_No__c',
                'LGS_File_Upload__c',
                'LGS_Campaign_Start_Date__c',
                'LGS_Campaign_End_Date__c',
                'LGS_Child_Campaign_ID__c',
                'RTL_Web_Unique_ID__c'
            };
        }
    }
    public static void updateField(RTL_Referral__c obj, Boolean status,String referNo){
        if(obj!=null){
            if(status){
                obj.RTL_AL_Refer_No__c =  referNo ; 
                obj.RTL_Is_Send_To_HPAP__c  = true;
                obj.RTL_Stage__c = 'Closed By AL System';
                obj.countsendHPAP__c = 1;
                obj.wsUpdateFlag__c = false;
            }else{
                obj.RTL_Is_Send_To_HPAP__c  = false;
                obj.countsendHPAP__c = COUNT_RETRY;
                obj.wsUpdateFlag__c = true;
                if(obj.CheckClickSubmit__c){
                    obj.CheckClickSubmit__c = false;
                }else{
                    obj.CheckClickSubmit__c = true;
                }
            }
            obj.Is_Send_to_HPAP_Done__c = true;
            update obj;
        }
    }
}