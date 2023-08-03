public with sharing class RTL_AL_SubmitHPAPCtrl extends RTL_AL_WebserviceAbstract {
    private static Integer COUNT_RETRY;
    private static String reflogId;
    private static DateTime RefstartDate;
    private static Map<Id, RTL_Referral__c> MapRefwithResult = new Map<Id, RTL_Referral__c>();
    private static final List<String> retryliststatus = new List<String>{'401','500'};
    private static List<OnlineServiceLog> lstLogDetail = new List<OnlineServiceLog>();
    private static Boolean resCode = false;

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
    private static final String OpptyLGSPartner {
        get {
            if(OpptyLGSPartner == null){
                List<App_Config__mdt> tempMetatdata = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'Opportunity LGS Partner Default'];
                OpptyLGSPartner = tempMetatdata != null && tempMetatdata.size() > 0 ? String.valueOf(tempMetatdata.get(0).Value__c) : 'Branch';
            }
            return OpptyLGSPartner;
        }
        set;
    }
    private static List<String> opptyFields {
        get {
            return new List<String>{
                'Id',
                'AccountId',
                'RTL_AL_Req_No1__c',
                'RTL_AL_Req_No2__c',
                'RTL_AL_car_type__c',
                'RTL_AL_car_brand__c',
                'RTL_AL_car_group__c',
                'RTL_AL_car_subtype__c',
                'RTL_AL_car_gear__c',
                'RTL_AL_car_year__c',
                'RTL_AL_normal_price__c',
                'RTL_AL_wanted_amount__c',
                'RTL_AL_max_set_up_amount__c',
                'RTL_AL_installment_amount__c',
                'RTL_AL_installment_periods__c',
                'RTL_AL_PayPerMonth__c',
                'RTL_AL_DownPercent__c',
                'RTL_AL_DownAmt__c',
                'RTL_AL_available_time__c',
                'RTL_AL_contact_channel__c',
                'RTL_AL_CarBooked__c',
                'RTL_AL_Showroom__c',
                'RTL_AL_car_bought_from__c',
                'RTL_AL_TentName__c',
                'RTL_AL_oa_ref_code__c',
                'LeadSource',
                'RTL_Campaign_Lead_Source__c',
                'RTL_Product_Name__c',
                'RTL_Retail_Product_Name__c',
                'RTL_Owner_Employee_ID__c',
                'RecordType.Name',
                'RTL_AL_Refer_No__c',
                'RTL_Is_Send_To_HPAP__c',
                'RTL_Branch_Code_Rpt__r.Branch_Code__c',
                'RTL_Owner_Branch_Code__c',
                'RTL_AL_ContactDistrict__c',
                'RTL_AL_ContactSubDistrict__c',
                'RTL_AL_ContactZipcode__c',
                'RTL_AL_ContactProvince__c',
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
                'RTL_Web_Unique_ID__c',
                'RTL_W2L_Campaign_Name__c',
                'LGS_Partner__c'
            };
        }
    }
   
    private static Map<String, Object> bodyRequest(Opportunity oppty, Account acct) {
        //code LGS

        String oppID = oppty.id  ;
        List<CampaignMember> cmb = [SELECT RTL_Web_Unique_ID__c,LGS_Lead_Received_Time__c,RTL_AL_Interested_Rate__c,LGS_001__c,LGS_002__c,LGS_003__c,LGS_004__c,
                                LGS_005__c,LGS_006__c,LGS_007__c,LGS_008__c,LGS_009__c,LGS_010__c,LGS_011__c,LGS_012__c,LGS_013__c,LGS_014__c,LGS_015__c,
                                LGS_016__c,LGS_017__c,LGS_018__c,LGS_019__c,LGS_020__c
                                FROM CampaignMember 
                                WHERE RTL_RelatedOpportunity_1__c =:oppID OR RTL_RelatedOpportunity_2__c =:oppID OR RTL_RelatedOpportunity_3__c =:oppID OR RTL_RelatedOpportunity_4__c =:oppID OR RTL_RelatedOpportunity_5__c =:oppID limit 1];
        return new Map<String, Object> {
            'RefCode' => oppty.RTL_AL_oa_ref_code__c,
            'RefCode2' => oppty.Id,
            'ObjectType' => 'Opportunity',
            'LeadSource' => oppty.LeadSource,
            'CampaignSource' => oppty.RTL_Campaign_Lead_Source__c,
            'Product' => oppty.RTL_Retail_Product_Name__c,
            'CarTypeDesc' => oppty.RTL_AL_car_type__c,
            'CarBrand' => oppty.RTL_AL_car_brand__c,
            'CarModel' => oppty.RTL_AL_car_group__c,
            'CarSubModel' => oppty.RTL_AL_car_subtype__c,
            'CarGear' => oppty.RTL_AL_car_gear__c,
            'CarYear' => oppty.RTL_AL_car_year__c,
            'CarPrice' => oppty.RTL_AL_normal_price__c,
            'FinAmt' => oppty.RTL_AL_wanted_amount__c,
            'MaxSetupAmt' => oppty.RTL_AL_max_set_up_amount__c,
            'InstallmentAmt' => oppty.RTL_AL_installment_amount__c,
            'InstallmentPeriod' => oppty.RTL_AL_installment_periods__c,
            'PayPerMonth' => oppty.RTL_AL_PayPerMonth__c,
            'DownPercent' => oppty.RTL_AL_DownPercent__c,
            'DownAmt' => oppty.RTL_AL_DownAmt__c,
            'IDCardNo' => acct.ID_Number_PE__c,
            'IDCardType' => acct.ID_Type_PE__c,
            'Name' => acct.First_name_PE__c,
            'Surname' => acct.Last_name_PE__c,
            'MobileNo' => acct.Mobile_Number_PE__c,
            'Email' => acct.Email_Address_PE__c,
            'ContactPeriod' => oppty.RTL_AL_available_time__c,
            'ContactZipcode' => oppty.RTL_AL_ContactZipcode__c,
            'ContactProvince' => oppty.RTL_AL_ContactProvince__c,
            'ContactDistrict' => oppty.RTL_AL_ContactDistrict__c,
            'ContactSubDistrict' => oppty.RTL_AL_ContactSubDistrict__c,
            'PreferService' => oppty.RTL_AL_contact_channel__c, // default 'BR'
            'CarBooked' => oppty.RTL_AL_CarBooked__c ? '1' : '0',
            'Showroom' => oppty.RTL_AL_Showroom__c,
            'CarSource' => oppty.RTL_AL_car_bought_from__c,
            'TentName' => oppty.RTL_AL_TentName__c,
            'BranchCode' => oppty.RTL_Owner_Branch_Code__c,
            'BranchName' => '',
            'BranchZipcode' => '',
            'BranchProvince' => '',
            'BranchDistrict' => '',
            'TcifNo' => '',
            'EmpId' => oppty.RTL_AL_contact_channel__c == 'BR' ? oppty.RTL_Owner_Employee_ID__c : '',
            // 'ECNo' => '',
            'RMNo' => acct.TMB_Customer_ID_PE__c,
            //Add from LGS
            'LGS_Partner'=>  oppty.LGS_Partner__c != null ? oppty.LGS_Partner__c : OpptyLGSPartner,
            'LGS_Lead_Received_Time'=> cmb.size() > 0 ? cmb[0].LGS_Lead_Received_Time__c != null ? cmb[0].LGS_Lead_Received_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null : null,
            'LGS_Campaign_Start_Date' => oppty.LGS_Campaign_Start_Date__c != null ? oppty.LGS_Campaign_Start_Date__c : null ,
            'LGS_Campaign_End_Date' => oppty.LGS_Campaign_End_Date__c != null ? oppty.LGS_Campaign_End_Date__c : null,
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
            'LGS_019'=> cmb.size() > 0 ? cmb[0].LGS_019__c != null ? cmb[0].LGS_019__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null : null,
            'LGS_020'=> cmb.size() > 0 ? cmb[0].LGS_020__c != null ? cmb[0].LGS_020__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'GMT+07:00') : null : null,
            
            'LGS_Assignment_Code'=> oppty.LGS_Assignment_Code__c != null ? oppty.LGS_Assignment_Code__c : '',
            'LGS_LinkInfo'=> oppty.LGS_LinkInfo__c != null ? oppty.LGS_LinkInfo__c : '',
            'LGS_BrandCode'=> oppty.LGS_BrandCode__c != null ? oppty.LGS_BrandCode__c : '',
            'LGS_BrandShowroomCode'=> oppty.LGS_BrandShowroomCode__c != null ? oppty.LGS_BrandShowroomCode__c : '',
            'LGS_PartnerCode'=> oppty.LGS_PartnerCode__c != null ? oppty.LGS_PartnerCode__c : '',
            'LGS_ChildCampaignID'=> oppty.LGS_Child_Campaign_ID__c != null ? oppty.LGS_Child_Campaign_ID__c : '',
            'LGS_Campaign_Name'=> oppty.RTL_W2L_Campaign_Name__c != null ? oppty.RTL_W2L_Campaign_Name__c : '',
            'LeadScore'=> oppty.Lead_Score__c != null ? oppty.Lead_Score__c : null,
            'LeadScorelevel'=> oppty.Lead_Score_level__c != null ? oppty.Lead_Score_level__c : '',
            'LGS_VIN_No'=> oppty.LGS_VIN_No__c != null ? oppty.LGS_VIN_No__c : '',
            'LGS_WebUniqueID'=> oppty.RTL_Web_Unique_ID__c != null ? oppty.RTL_Web_Unique_ID__c : '',
            'LGS_File_Upload'=> oppty.LGS_File_Upload__c != null ? oppty.LGS_File_Upload__c : ''

        };
    }

    @AuraEnabled
    public static Object getAppHPAPStatus(Id recordId) {
        return Database.query(String.format('SELECT {0} FROM Opportunity WHERE Id = :recordId LIMIT 1', 
            new List<String>{
                String.join(opptyFields, ',')
            }
        ));
    }

    @AuraEnabled(continuation=true)
    public static Object submitAppHPAP(Id recordId){
        Datetime startDate = Datetime.now();
        Opportunity opportunityObj = ((List<Opportunity>)getAppHPAPStatus(recordId)).get(0);
        Id accountId = (Id)opportunityObj.get('AccountId');
        Account accountObj = Database.query(String.format('SELECT {0} FROM Account WHERE Id = :accountId LIMIT 1', 
            new List<String>{
                String.join(new List<String>{
                    'Id',
                    'ID_Number_PE__c',
                    'ID_Type_PE__c',
                    'First_name_PE__c',
                    'Last_name_PE__c',
                    'Mobile_Number_PE__c',
                    'Email_Address_PE__c',
                    'Zip_Code_Primary_PE__c',
                    'Province_Primary_PE__c',
                    'Primary_Address_Line_2_PE__c',
                    'Primary_Address_Line_3_PE__c',
                    'TMB_Customer_ID_PE__c'
                }, ',')
            }    
        ));
        // checking record type is only "Retail Auto Loan"
        if(!opportunityObj.RecordType.Name.contains('Retail Auto Loan')) throw new AuraHandledException('Not allow to submit opportunity to HPAP');

        // checking status is not send
        if(opportunityObj.RTL_Is_Send_To_HPAP__c == false) {
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
            String bodyRequestRaw = JSON.serializePretty(bodyRequest(opportunityObj, accountObj));
            String bodyRequestEncrypt = SCSMessageAPIUtil.encryptMessageWithKey(bodyRequestRaw, privateKey);
            System.debug('bodyRequestRaw-->' + bodyRequestRaw);
            Uuid uuidGenerateor = new Uuid();
            String uuid = uuidGenerateor.getValue();
            
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

            Continuation con = new Continuation(timeout/1000 != 0 ? timeout/1000 : 1);
            con.state = new Map<String, Object> {
                'recordId' => recordId,
                'uuid' => uuid,
                'privateKey' => privateKey,
                'bodyRequestRaw' => bodyRequestRaw,
                'startDateTime' => Datetime.now()
            };
            con.continuationMethod = 'callbackSubmitHPAP';
            con.addHttpRequest(req);

            return con;
        } else {
            return new Map<String, Object>{
                'RTL_Is_Send_To_HPAP__c' => opportunityObj.RTL_Is_Send_To_HPAP__c,
                'RTL_AL_Refer_No__c' => opportunityObj.RTL_AL_Refer_No__c
            };
        }
    }

    @AuraEnabled
    public static Object callbackSubmitHPAP(List<String> labels, Object state){
        String recordId = (String)AbstractCoreClass.getResult('recordId', state);
        String uuid = (String)AbstractCoreClass.getResult('uuid', state);
        String privateKey = (String)AbstractCoreClass.getResult('privateKey', state);
        String bodyRequestRaw = (String)AbstractCoreClass.getResult('bodyRequestRaw', state);
        Datetime startDate = Datetime.valueofGmt(((String)AbstractCoreClass.getResult('startDateTime', state)).replace('T', ' ').replace('Z', ' '));
        
        Opportunity opportunityObj = ((List<Opportunity>)getAppHPAPStatus(recordId)).get(0);
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        // res.setBody(SCSMessageAPIUtil.encryptMessageWithKey('{"ResponseCode":"000","ResponseDetail":"OK","RefCode":"WEB","RefCode2":"OP1234","RefCode3":"20190613161923673"}', privateKey));
        System.debug('Status ' + res.getStatusCode() + ' : ' + res.getStatus());
        String bodyResonseDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
        Map<String, Object> result = bodyResonseDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(bodyResonseDecrypt) : new Map<String, Object>();
        System.debug('Body bofore decrypt-->' + res.getBody());
        System.debug('Body after decrypt-->' + bodyResonseDecrypt);
        String statusCode = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseCode', result) : '999');
        String errorMsg = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseDetail', result) : AbstractCoreClass.getValuesWithRegex(res.getBody(), new List<String>{'errordesc'}));
        Boolean isSuccess = statusCode == '000';
        try {
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                '', // customerName
                !isSuccess ? errorMsg : '', // Error message
                uuid, // msLogId
                UserInfo.getName(),
                isSuccess ? (String)result.get('RefCode3') : (String)result.get('RefCode2'),
                getServiceName(SERVICENAME.CreateRefer),
                bodyRequestRaw, // Request Body
                bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? res.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
            if(!isSuccess) {
                return new Map<String, Object>{
                    'isSuccess' => false,
                    'errorMsg' => errorMsg != null ? errorMsg : ''
                };
            }

            // Action when send AL Retail Opportunity data to HPAP system.						
            // 1. If finish is successful then update field RTL_Is_Send_To_HPAP__c = true and Stage = 'Submit App'.						
            // 2. If finish is successful then update field RTL_AL_Req_No__c RTL_AL_Refer_No__c = HPAP.req_no HPAP.refer_no.						
            // 3. If finish is successful then update field Opportunity_Amount__c = RTL_AL_wanted_amount__c						
            // 4. If error then show message error and update field RTL_Is_Send_To_HPAP__c = false.						
            Opportunity oppty = new Opportunity(
                Id = recordId,
                RTL_Is_Send_To_HPAP__c = Test.isRunningTest() ? false : isSuccess
            );
            if(oppty.RTL_Is_Send_To_HPAP__c || Test.isRunningTest()) {
                oppty.StageName = 'Submit App';
                oppty.RTL_AL_oa_ref_code__c = (String)result.get('RefCode');
                oppty.RTL_AL_Refer_No__c = (String)result.get('RefNo');
                oppty.Amount = opportunityObj.RTL_AL_wanted_amount__c;
                oppty.HPAP_Status_Code__c = (String)result.get('HPAPStatus');
                oppty.RTL_Status__c = (String)result.get('HPAPStatusDesc');
                // oppty.Details_of_Status__c = (String)result.get('Remark');
                oppty.Corebank_Emp_Id__c = (String)result.get('EmpID');
                oppty.Corebank_Emp_Name__c = (String)result.get('EmpName');
                oppty.Corebank_Emp_Phone_No__c = (String)result.get('EmpMobileNo');
                oppty.RTL_Hub_Code__c = (String)result.get('HubCode');
                oppty.RTL_Hub_Name__c = (String)result.get('HubName');
                update oppty;
            }
            return oppty;
        } catch (DmlException e) {
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                '', // customerName
                String.format('{0}\n{1}', new List<Object>{
                    e.getDmlStatusCode(0),
                    e.getDmlMessage(0)
                }), // Error message
                uuid, // msLogId
                UserInfo.getName(),
                isSuccess ? (String)result.get('RefCode3') : (String)result.get('RefCode2'),
                getServiceName(SERVICENAME.CreateRefer),
                bodyRequestRaw, // Request Body
                bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? res.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt), // Response Body
                null,
                startDate,
                Datetime.now() // End datetime
            );
            return new Map<String, Object>{
                'isSuccess' => false,
                'errorMsg' => e.getDmlMessage(0)
            };
        }
    }

    // private static List<String> refFields {
    //     get {
    //         return new List<String>{
    //             'Id',
    //             'Name',
    //             'RTL_AL_oa_ref_code__c',
    //             'RTL_Product_Name__c',
    //             'RTL_AL_car_type__c',
    //             'RTL_AL_car_brand__c',
    //             'RTL_AL_car_group__c',
    //             'RTL_AL_car_subtype__c',
    //             'RTL_AL_car_gear__c',
    //             'RTL_AL_car_year__c',
    //             'RTL_AL_normal_price__c',
    //             'RTL_AL_wanted_amount__c',
    //             'RTL_AL_max_set_up_amount__c',
    //             'RTL_AL_installment_periods__c',
    //             'RTL_AL_PayPerMonth__c',
    //             'RTL_AL_DownPercent__c',
    //             'RTL_AL_DownAmt__c',
    //             'RTL_AL_installment_amount__c',
    //             'RTL_AL_available_time__c',
    //             'RTL_AL_ContactZipcode__c',
    //             'RTL_AL_ContactProvince__c',
    //             'RTL_AL_ContactDistrict__c',
    //             'RTL_AL_ContactSubDistrict__c',
    //             'RTL_AL_contact_channel__c',
    //             'RTL_AL_CarBooked__c',
    //             'RTL_AL_Showroom__c',
    //             'RTL_AL_car_bought_from__c',
    //             'RTL_AL_TentName__c',
    //             'RTL_Preferred_Branch_Code__c',
    //             'RTL_Product_Name_Str__c',
    //             'Owner_Emp_ID__c',
    //             'RTL_Mobile1__c',
    //             'RTL_LastName__c',
    //             'RTL_FirstName__c',
    //             'RTL_Citizen_Id__c',
    //             'RTL_ID_Type__c',
    //             'RTL_Account_Name__r.Mobile_Number_PE__c',
    //             'RTL_Account_Name__r.Last_name_PE__c',
    //             'RTL_Account_Name__r.First_name_PE__c',
    //             'RTL_Account_Name__r.ID_Number_PE__c',
    //             'RTL_Account_Name__r.ID_Type_PE__c',
    //             'RTL_Account_Name__r.Email_Address_PE__c',
    //             'RTL_Preferred_Branch__c',
    //             'RTL_Preferred_Branch_Name__c',
    //             'RTL_EmployeeID__c ',
    //             'countsendHPAP__c',
    //             'Is_Update_Refer__c',
    //             'RTL_Account_Name__c',
    //             'wsUpdateFlag__c',
    //             'CheckClickSubmit__c',
    //             'RTL_Account_Name__r.TMB_Customer_ID_PE__c',
    //             'RTL_AL_Refer_No__c'
    //         };
    //     }
    // }

    // @future(callout=true)
    // public static void callAPIcreateReferral(Set<Id> refId, Boolean isUpdate){
    //     System.debug('Ref Size created : ' + refId.size());
    //     System.debug('Map Size check : ' + MapRefwithResult.size());
    //     if(MapRefwithResult.size() > 0){
    //         Set<Id> existkeys = MapRefwithResult.keySet();
    //         if(existkeys.size()>0){
    //             for(Id key : existkeys){
    //                 System.debug('Remove Exist key : ' + key);
    //                 MapRefwithResult.remove(key);

    //             }
    //         }

    //     }
    //     List<RTL_Referral__c> refList = Database.query(String.format('SELECT {0} FROM RTL_Referral__c WHERE Id IN :refId', 
    //         new List<String>{
    //             String.join(refFields, ',')
    //         }
    //     ));
    //     List<String> retryliststatus = new List<String>{'401','500'};
    //     Id accId = null;
    //     String RefName = null;
    //     for(RTL_Referral__c eachRef : refList){
    //         RefName = eachRef.Name;
    //         accId = eachRef.RTL_Account_Name__c;
    //         COUNT_RETRY = 0;
    //         try{
    //             RefstartDate = Datetime.now();
    //             callhttpReferral(eachRef); //0
    //         }catch(Exception e){
    //             System.debug('TRY FAIL : ' + COUNT_RETRY + ' : '+  e);
    //             if(resCode == false){
    //                 OnlineServiceLog createlog = new OnlineServiceLog(false,e.getMessage(),'','');
    //                 lstLogDetail.add(createlog);
    //                 eachRef.countsendHPAP__c = COUNT_RETRY;
    //                 if(e.getMessage() == '404'){
    //                     MapRefwithResult.put(eachRef.Id,eachRef);
    //                 }
    //             }
    //             if((retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')){
    //                 while ((COUNT_RETRY < 2) && (retryliststatus.contains(e.getMessage()) || e.getMessage() == 'Read timed out')) { // 0
    //                     System.debug('Retry : ' + COUNT_RETRY );
    //                     COUNT_RETRY++; //1 2
    //                     try{
    //                         callhttpReferral(eachRef); //1 2
    //                     }catch(Exception err){
    //                         System.debug('TRY FAIL : ' + COUNT_RETRY + ' : '+  err);
    //                         if(resCode == false){
    //                             OnlineServiceLog createlogRetry = new OnlineServiceLog(false,err.getMessage(),'','');
    //                             lstLogDetail.add(createlogRetry);
    //                             eachRef.countsendHPAP__c = COUNT_RETRY;
    //                             MapRefwithResult.put(eachRef.Id,eachRef);
    //                         }
    //                         continue;
    //                     }
    //                 }
    //             }
    //         }

    //     }
    //     if(accId != null){
    //         Account acc = [SELECT Id,Name,Core_Banking_Suggested_Segment__c FROM ACCOUNT WHERE Id =: accId LIMIT 1];
    //             RTL_CampaignUtil.saveToOnlineLog(lstLogDetail, acc.Name, null ,reflogId, UserInfo.getName() ,RefName, getServiceName(SERVICENAME.CreateRefer), acc, RefstartDate, DateTime.now());
    //         }else{
    //             RTL_CampaignUtil.saveToOnlineLog(lstLogDetail, null, null ,reflogId, UserInfo.getName() ,RefName, getServiceName(SERVICENAME.CreateRefer), null, RefstartDate, DateTime.now());
    //         }
    //     System.debug('Mapsize ' + MapRefwithResult.size());
    //     updateField(MapRefwithResult,isUpdate);
    // }

    // public static void callhttpReferral(RTL_Referral__c eachRef){
    //     System.debug('START callAPIcreateReferral !!!');
    //     Datetime startDate = Datetime.now();
    //     Uuid uuidGenerateor = new Uuid();
    //     String uuid = uuidGenerateor.getValue();
    //     reflogId = uuid;
    //     List<String> valid_product = new List<String>{'CYC','CYB','NEW','USED'};
    //     if(eachRef.RTL_Product_Name__c != null && eachRef.RTL_Preferred_Branch__c != null && valid_product.contains(eachRef.RTL_Product_Name_Str__c) && eachRef.RTL_Preferred_Branch_Name__c == 'AL Marketing'){
    //         if(eachRef.RTL_FirstName__c != null && eachRef.RTL_LastName__c != null && eachRef.RTL_Mobile1__c != null && eachRef.RTL_AL_ContactProvince__c != null && eachRef.RTL_AL_ContactDistrict__c != null &&
    //         eachRef.RTL_AL_ContactSubDistrict__c != null && eachRef.RTL_AL_contact_channel__c != null){
    //             String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI);
    //             String bodyRequestRaw = JSON.serializePretty(RefbodyRequest(eachRef));
    //             String bodyRequestEncrypt = SCSMessageAPIUtil.encryptMessageWithKey(bodyRequestRaw, privateKey);
    //             Http http = new Http();
    //             HttpRequest req = new HttpRequest();
    //             req.setMethod('POST');
    //             req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
    //             req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
    //             req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
    //             req.setHeader('Request-UID', uuid);
    //             req.setHeader('Request-App-ID', APPID);
    //             req.setEndpoint('callout:RTL_AL_SubmitApp_HPAP');
    //             req.setBody(bodyRequestEncrypt);
    //             req.setTimeout(timeout);
    //             System.debug('Endpoint : ' + req.getEndpoint());
    //             HttpResponse response = http.send(req);
    //             if (response.getStatusCode() == 200) {
    //                 System.debug('RTL_AL_SubmitHPAPCtrl | callAPIcreateReferral | response : ' +response.getBody());
    //                 resCode = true;
    //             }else{
    //                 resCode = false;
    //                 System.debug(response.getStatusCode());
    //                 CalloutException e = new CalloutException();
    //                 e.setMessage(String.valueOf(response.getStatusCode()));
    //                 throw e;                                        
    //             }
    //             String bodyResonseDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), privateKey);
    //             System.debug('Response Body = ' + bodyResonseDecrypt);
    //             Map<String, Object> result = bodyResonseDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(bodyResonseDecrypt) : new Map<String, Object>();
    //             String statusCode = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseCode', result) : '999');
    //             String errorMsg = String.valueOf(!result.isEmpty() ? AbstractCoreClass.getResult('ResponseDetail', result) : AbstractCoreClass.getValuesWithRegex(response.getBody(), new List<String>{'errordesc'}));
    //             Boolean isSuccess = statusCode == '000';
    //             if((isSuccess && response.getStatusCode() == 200)){
    //                 String ResponseDetail = (String)result.get('ResponseDetail');
    //                 eachRef.RTL_AL_Refer_No__c = (String)result.get('RefCode3');
    //                 System.debug('Response Detail :' + ResponseDetail);
    //                 eachRef.WS_Response_Detail__c = ResponseDetail;
    //                 eachRef.countsendHPAP__c = COUNT_RETRY;
    //                 MapRefwithResult.put(eachRef.Id,eachRef);
    //                 OnlineServiceLog createlog = new OnlineServiceLog(true,bodyRequestRaw,bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt));
    //                 lstLogDetail.add(createlog);
    //             }else{
    //                 System.debug('WS_Response_Detail__c' + errorMsg.length());
    //                 if(errorMsg.length() > 255){
    //                     errorMsg = errorMsg.left(255);
    //                 }
    //                 eachRef.WS_Response_Detail__c = errorMsg;
    //                 eachRef.countsendHPAP__c = COUNT_RETRY;
    //                 MapRefwithResult.put(eachRef.Id,eachRef);
    //                 OnlineServiceLog createlog = new OnlineServiceLog(false,errorMsg,bodyRequestRaw,bodyResonseDecrypt == null || String.isEmpty(bodyResonseDecrypt) ? response.getBody() : AbstractCoreClass.serializePrettyString(bodyResonseDecrypt));
    //                 lstLogDetail.add(createlog);
    //                 System.debug('errorMsg Response Detail :' + errorMsg);
    //                 System.debug('BodyResponse: ' + result);
    //                 System.debug('Response is not Success');
    //                 CalloutException e = new CalloutException();
    //                 e.setMessage(errorMsg);
    //                 throw e;
    //             }
    //         }else{
    //             System.debug('Error field not valid!');
    //             CalloutException e = new CalloutException();
    //             e.setMessage('Error field not valid!');
    //             throw e;
    //         }
    //     }else{
    //         System.debug('ขื่อผลิตภัณฑ์ (CYC, CYB, NEW, USED) หรือสาขาที่ลูกค้าอยากใช้บริการ (AL Marketing เท่านั้น)ไม่ถูกต้อง');
    //         CalloutException e = new CalloutException();
    //         e.setMessage('ขื่อผลิตภัณฑ์ (CYC, CYB, NEW, USED) หรือสาขาที่ลูกค้าอยากใช้บริการ (AL Marketing เท่านั้น)ไม่ถูกต้อง');
    //         throw e;
    //     }
    //     System.debug('STOP callAPIcreateReferral !!!');
    // }

    // public static Map<String, Object> RefbodyRequest(RTL_Referral__c ref) {
    //     String IdcardNo = null;
    //     String Idcardtype = null;
    //     String FName = null;
    //     String LName = null;
    //     //String mobile = null;
    //     if(ref.RTL_Account_Name__c != null){
    //         IdcardNo = ref.RTL_Account_Name__r.ID_Number_PE__c; 
    //         Idcardtype = ref.RTL_Account_Name__r.ID_Type_PE__c;
    //         FName= ref.RTL_Account_Name__r.First_name_PE__c;
    //         LName = ref.RTL_Account_Name__r.Last_name_PE__c;
    //         //mobile = ref.RTL_Account_Name__r.Mobile_Number_PE__c;
    //     } else{
    //         IdcardNo = ref.RTL_Citizen_Id__c;
    //         Idcardtype = ref.RTL_ID_Type__c;
    //         FName = ref.RTL_FirstName__c;
    //         LName = ref.RTL_LastName__c;
    //         //mobile = ref.RTL_Mobile1__c;
    //     }
    //     String CarBooked = '';
    //     if(ref.RTL_AL_CarBooked__c) { 
    //         CarBooked = '1' ; 
    //     }else{
    //         CarBooked = '0' ; 
    //     }

    //     return new Map<String, Object> {
    //         'RefCode'=> ref.RTL_AL_oa_ref_code__c != null ? ref.RTL_AL_oa_ref_code__c : '',
    //         'RefCode2'=> ref.Id != null ? ref.Id : '',
    //         'ObjectType'=>'Referral',
    //         'Channel'=> 'AL Advisory Line',
    //         'System'=> 'SALESFORCE',
    //         'Product'=> ref.RTL_Product_Name_Str__c != null ? ref.RTL_Product_Name_Str__c : '',
    //         'CarTypeDesc'=> ref.RTL_AL_car_type__c != null ? ref.RTL_AL_car_type__c : '',
    //         'CarBrand'=> ref.RTL_AL_car_brand__c != null ? ref.RTL_AL_car_brand__c : '',
    //         'CarModel'=> ref.RTL_AL_car_group__c != null ? ref.RTL_AL_car_group__c : '',
    //         'CarSubModel'=> ref.RTL_AL_car_subtype__c != null ? ref.RTL_AL_car_subtype__c : '',
    //         'CarGear'=> ref.RTL_AL_car_gear__c != null ? ref.RTL_AL_car_gear__c : '',
    //         'CarYear'=> ref.RTL_AL_car_year__c != null ? ref.RTL_AL_car_year__c : '',
    //         'CarPrice'=> ref.RTL_AL_normal_price__c != null ? ref.RTL_AL_normal_price__c : null,
    //         'FinAmt'=> ref.RTL_AL_wanted_amount__c != null ? ref.RTL_AL_wanted_amount__c : null,
    //         'MaxSetupAmt'=> ref.RTL_AL_max_set_up_amount__c != null ? ref.RTL_AL_max_set_up_amount__c : null,
    //         'InstallmentPeriod'=> ref.RTL_AL_installment_periods__c != null ? ref.RTL_AL_installment_periods__c : '',
    //         'PayPerMonth'=> ref.RTL_AL_PayPerMonth__c != null ? ref.RTL_AL_PayPerMonth__c : null,
    //         'DownPercent'=> ref.RTL_AL_DownPercent__c != null ? ref.RTL_AL_DownPercent__c : null,
    //         'DownAmt'=> ref.RTL_AL_DownAmt__c != null ? ref.RTL_AL_DownAmt__c : null,
    //         'InstallmentAmt'=> ref.RTL_AL_installment_amount__c != null ? ref.RTL_AL_installment_amount__c : null,
    //         'IDCardNo'=> IdcardNo,
    //         'IDCardType'=> Idcardtype,
    //         'Name'=> FName,
    //         'Surname'=> LName,
    //         'MobileNo'=> ref.RTL_Mobile1__c != null ? ref.RTL_Mobile1__c : null,
    //         'Email'=> ref.RTL_Account_Name__r.Email_Address_PE__c != null ? ref.RTL_Account_Name__r.Email_Address_PE__c : '',
    //         'ContactPeriod'=> ref.RTL_AL_available_time__c != null ? ref.RTL_AL_available_time__c : '',
    //         'ContactZipcode'=> ref.RTL_AL_ContactZipcode__c != null ? ref.RTL_AL_ContactZipcode__c : '',
    //         'ContactProvince'=> ref.RTL_AL_ContactProvince__c != null ? ref.RTL_AL_ContactProvince__c : '',
    //         'ContactDistrict'=> ref.RTL_AL_ContactDistrict__c != null ? ref.RTL_AL_ContactDistrict__c : '',
    //         'ContactSubDistrict'=> ref.RTL_AL_ContactSubDistrict__c != null ? ref.RTL_AL_ContactSubDistrict__c : '',
    //         'PreferService'=> ref.RTL_AL_contact_channel__c != null ? ref.RTL_AL_contact_channel__c : '',
    //         'CarBooked'=> CarBooked,
    //         'Showroom'=> ref.RTL_AL_Showroom__c != null ? ref.RTL_AL_Showroom__c : '',
    //         'CarSource'=> ref.RTL_AL_car_bought_from__c != null ? ref.RTL_AL_car_bought_from__c : '',
    //         'TentName'=> ref.RTL_AL_TentName__c != null ? ref.RTL_AL_TentName__c : '',
    //         'BranchCode'=> ref.RTL_Preferred_Branch_Code__c != null ? ref.RTL_Preferred_Branch_Code__c : '',
    //         'BranchName'=> '',
    //         'BranchZipcode'=> '',
    //         'BranchProvince'=> '',
    //         'BranchDistrict'=> '',
    //         'TcifNo'=> '',
    //         'EmpId'=> '',
    //         'ECNo'=> '',
    //         'RMNo'=> ref.RTL_Account_Name__r.TMB_Customer_ID_PE__c != null ? ref.RTL_Account_Name__r.TMB_Customer_ID_PE__c : ''
    //     };
    // }
    // public static void updateField(Map<Id, RTL_Referral__c> mapRef, Boolean isUpdate){
    //     List<RTL_Referral__c> updateRef = new List<RTL_Referral__c>();
    //     for(RTL_Referral__c each : mapRef.values()){
    //         System.debug('Update field' + each.Id + ' || '+ each.RTL_AL_Refer_No__c);
    //         if(each.RTL_AL_Refer_No__c != null){
    //             //each.RTL_AL_Refer_No__c =  mapRef.get(each);
    //             each.RTL_Is_Send_To_HPAP__c = true;
    //             each.RTL_Stage__c = 'Closed By AL System';
    //             each.countsendHPAP__c = 1;
    //             each.wsUpdateFlag__c = false;
    //             //each.WS_Response_Detail__c = '';

    //         }else{
    //             each.RTL_Is_Send_To_HPAP__c  = false;
    //             //each.countsendHPAP__c = COUNT_RETRY;
    //             each.wsUpdateFlag__c = true;
    //             each.Is_Update_Refer__c = true;
    //         }
    //         each.Is_Send_to_HPAP_Done__c = true;
    //         updateRef.add(each);
    //         }
        
    //     update updateRef;
    // }
}