@isTest
public class SmartBDM_BusinessTypeController_Test {
    public static final Id BDM_PROFILE_ID {
        get{
            if(BDM_PROFILE_ID == null){
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
    }

    public static final Id SYSTEM_ADMINISTRATOR_ID {
        get{
            if(SYSTEM_ADMINISTRATOR_ID == null){
                SYSTEM_ADMINISTRATOR_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            }
            return SYSTEM_ADMINISTRATOR_ID;
        }
        set;
    }

    public static String mockdata_businessType() {
        return '{"from":1,"to":3,"total":10,"data":[{"businessType":{"code":"DA020000","name":"การขายส่งหัวมันสำปะหลัง  อ้อย","isicCode":"G462090","groupCode":"8","subGroup":"8"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA030000","name":"การขายส่งฝ้าย ปอ นุ่น","isicCode":"G462090","groupCode":"3","subGroup":"3"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA070102","name":"การขายส่งปาล์มสด","isicCode":"G462020","groupCode":"8","subGroup":"8"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA100000","name":"การขายส่งไม้ดอก  ไม้ประดับ","isicCode":"G462050","groupCode":"8","subGroup":"8"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA110000","name":"การขายส่งเมล็ดพันธุ์พืช","isicCode":"G462050","groupCode":"3","subGroup":"3"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA150000","name":"การขายส่งครั่ง","isicCode":"G462090","groupCode":"3","subGroup":"3"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DA160101","name":"การขายส่งพืชน้ำมันที่ใช้ในการผลิตน้ำมันพืช","isicCode":"G462020","groupCode":"8","subGroup":"8"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DJ110102","name":"การขายส่งวัตถุดิบทางการเกษตรและสัตว์มีชีวิต โดยได้รับค่าตอบแทนหรือตามสัญญาจ้าง","isicCode":"G461010","groupCode":"8","subGroup":"8"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"DK000201","name":"การขายส่งวัตถุดิบอื่นๆ ทางการเกษตร","isicCode":"G462090","groupCode":"3","subGroup":"3"},"negative":"N","highRisk":"N","diversification":"Y","suspend":"N","highlySelectiveIndustry":"N"},{"businessType":{"code":"AA130000","name":"การจัดการเมล็ดพันธุ์เพื่อการขยายพันธุ์","isicCode":"A016400","groupCode":"5","subGroup":"5"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"AA140000","name":"การขยายพันธุ์พืช","isicCode":"A013020","groupCode":"2","subGroup":"2"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"AA190000","name":"การทำฟาร์มผสมผสาน (ปลูกพืชร่วมกับเลี้ยงสัตว์)","isicCode":"A015000","groupCode":"6","subGroup":"6"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"AD020000","name":"วนวัฒนวิทยาและกิจกรรมอื่นๆ ที่เกี่ยวกับป่าไม้","isicCode":"A021000","groupCode":"6","subGroup":"6"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"AE010101","name":"การดำเนินการเกี่ยวกับอุปกรณ์การให้น้ำและเครื่องมือชลประทานทางการเกษตร","isicCode":"A016120","groupCode":"6","subGroup":"6"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"AE010102","name":"การควบคุมแมลงและสัตว์ศัตรูพืช","isicCode":"A016110","groupCode":"5","subGroup":"5"},"negative":"N","highRisk":"N","diversification":"N","suspend":"Y","highlySelectiveIndustry":"N"},{"businessType":{"code":"CF010106","name":"ร้านตัดเย็บเสื้อผ้า","isicCode":"C141200","groupCode":"2","subGroup":"2"},"negative":"N","highRisk":"N","diversification":"N","suspend":"N","highlySelectiveIndustry":"N"}]}';
    }

    public static String mockdata_businessGroup() {
        return '{"from":1,"to":2,"total":10,"data":[{"code":"1","name":{"th":"รับเหมาก่อสร้าง","en":"Contractor"},"arDay":"40","invDay":"0","apDay":"10","incomeFactor":"20%","cogDay":"70%"},{"code":"2","name":{"th":"ธุรกิจผลิต","en":"Manufacturing"},"arDay":"50","invDay":"70","apDay":"30","incomeFactor":"15%","cogDay":"82%"},{"code":"3","name":{"th":"ขายส่ง","en":"Wholesale"},"arDay":"40","invDay":"50","apDay":"20","incomeFactor":"10%","cogDay":"87%"},{"code":"4","name":{"th":"ขายปลีก","en":"Retail"},"arDay":"0","invDay":"50","apDay":"5","incomeFactor":"17%","cogDay":"80%"},{"code":"5","name":{"th":"บริการ","en":"Services"},"arDay":"30","invDay":"10","apDay":"10","incomeFactor":"20%","cogDay":"65%"},{"code":"6","name":{"th":"ไม่มีเงินทุน","en":"NO Working Cap"},"arDay":"0","invDay":"0","apDay":"0","incomeFactor":"15%","cogDay":"80%"},{"code":"7","name":{"th":"ทำเหมือง/จัดการน้ำและของเสีย","en":"Others 1 - Mining"},"arDay":"20","invDay":"10","apDay":"0","incomeFactor":"15%","cogDay":"80%"},{"code":"8","name":{"th":"อาหารสด","en":"Others 2 - Freshfood / M&E"},"arDay":"40","invDay":"5","apDay":"25","incomeFactor":"10%","cogDay":"85%"},{"code":"9","name":{"th":"พลังงานและเชื้อเพลิง","en":"Others 3 - Fuel / Gas Station / Jobber"},"arDay":"25","invDay":"0","apDay":"15","incomeFactor":"5%","cogDay":"90%"}]}';
    }

    public static List<SmartBDMBusinessType.Response> getBusinessTypeFinal(){
        Map<String, Object> businessGroup = (Map<String, Object>)JSON.deserializeUntyped(mockdata_businessGroup());
        Map<String, Object> businessType = (Map<String, Object>)JSON.deserializeUntyped(mockdata_businessType());
        Map<String, SmartBDMBusinessType.Response> businessTypeMap = new Map<String, SmartBDMBusinessType.Response>();
        Map<String, SmartBDMBusinessType.Response> businessGroupMap = new Map<String, SmartBDMBusinessType.Response>();

        for (SmartBDMBusinessType.Response rsp : (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(businessGroup.get('data')), List<SmartBDMBusinessType.Response>.class)) {
            businessGroupMap.put(rsp.code, rsp);
        }

        for (SmartBDMBusinessType.Response rsp : (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(businessType.get('data')), List<SmartBDMBusinessType.Response>.class)) {
            SmartBDMBusinessType.Response tmp_rsp = businessGroupMap.get(rsp.businessType.groupCode);
            if(tmp_rsp != null && !businessTypeMap.containsKey(rsp.businessType.code)){
                rsp.code = tmp_rsp.code;
                rsp.name = tmp_rsp.name;
                rsp.arDay = tmp_rsp.arDay;
                rsp.invDay = tmp_rsp.invDay;
                rsp.apDay = tmp_rsp.apDay;
                rsp.incomeFactor = tmp_rsp.incomeFactor;
                rsp.cogDay = tmp_rsp.cogDay;
                businessTypeMap.put(rsp.businessType.code, rsp);
            }
        }
        return businessTypeMap.values();
    }

    @testSetup static void setup() {
		
		TestUtils.createAppConfig();
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
		
		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = SYSTEM_ADMINISTRATOR_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

        System.runAs(User01) {
            List<SmartBDMBusinessType.Response> businessTypeFinal_List = getBusinessTypeFinal();
            List<IndustryMaster__c> industryMaster_List = new List<IndustryMaster__c>();
            for(SmartBDMBusinessType.Response rsp : businessTypeFinal_List) {
                IndustryMaster__c insdusObj = new IndustryMaster__c();
                insdusObj.APday__c = rsp.apDay;
                insdusObj.ARday__c = rsp.arDay;
                insdusObj.BusinessType__c = rsp.businessType.name;
                insdusObj.COGday__c = Integer.valueOf(rsp.cogDay.replace('%', ''));
                insdusObj.Diversification__c = rsp.diversification.contains('Y') ? true : false;
                insdusObj.HighlySelectiveIndustry__c = rsp.highlySelectiveIndustry.contains('Y') ? true : false;
                insdusObj.HighRisk__c = rsp.highRisk.contains('Y') ? true : false;
                insdusObj.INVday__c = rsp.invDay;
                insdusObj.ISICCode__c = rsp.businessType.isicCode;
                insdusObj.Negative__c = rsp.negative.contains('Y') ? true : false;
                insdusObj.SubIndustry__c = rsp.businessType.subGroup;
                // insdusObj.ColorCode__c = rsp.
                insdusObj.Suspend__c = rsp.suspend.contains('Y') ? true : false;
                insdusObj.TMBCode__c = rsp.businessType.code;
                insdusObj.IncomeFactor__c = Integer.valueOf(rsp.incomeFactor.replace('%', ''));
                insdusObj.BusinessGroupCode__c = rsp.businessType.groupCode;
                insdusObj.BusinessGroupNameTH__c = rsp.name.th;
                insdusObj.BusinessGroupNameEN__c = rsp.name.en;
                industryMaster_List.add(insdusObj);
            }

            IndustryMaster__c insdusObj_temp = new IndustryMaster__c();
            insdusObj_temp.APday__c = 123;
            insdusObj_temp.ARday__c = 321;
            insdusObj_temp.BusinessType__c = 'rsp.businessType.name';
            insdusObj_temp.COGday__c = 69;
            insdusObj_temp.Diversification__c = true;
            insdusObj_temp.HighlySelectiveIndustry__c = false;
            insdusObj_temp.HighRisk__c = false;
            insdusObj_temp.INVday__c = 780;
            insdusObj_temp.ISICCode__c = 'SHAJK11';
            insdusObj_temp.Negative__c = true;
            insdusObj_temp.SubIndustry__c = 'rsp.businessType.subGroup';
            // insdusObj_temp.ColorCode__c = rsp.
            insdusObj_temp.Suspend__c = false;
            insdusObj_temp.TMBCode__c = '12HAJK11';
            insdusObj_temp.IncomeFactor__c = 34;
            insdusObj_temp.BusinessGroupCode__c = '5';
            insdusObj_temp.BusinessGroupNameTH__c = 'rsp.name.th';
            insdusObj_temp.BusinessGroupNameEN__c = 'rsp.name.en';
            industryMaster_List.add(insdusObj_temp);

            // System.debug('industryMaster_List.size() :: ' + industryMaster_List.size());
            if(industryMaster_List.size() > 0){
                insert industryMaster_List;
            }
        }
    }

    @isTest static void test_method_onInit() {
        SmartBDM_BusinessTypeController btCtrl = new SmartBDM_BusinessTypeController();
        SmartBDMBusinessType businessType = new SmartBDMBusinessType();
        SmartBDM_Service service = new SmartBDM_Service();
        
        SmartBDM_BusinessTypeController.getDeepLink();
        List<IndustryMaster__c> IndustryMaster_List = SmartBDM_BusinessTypeController.fetchIndustryMaster('D');
        IndustryMaster__c IndustryMaster_Obj = SmartBDM_BusinessTypeController.getIndustryMaster((String)IndustryMaster_List.get(0).Id);
       
    }

    @isTest static void test_method_onInit_negative() {
        List<IndustryMaster__c> IndustryMaster_List = SmartBDM_BusinessTypeController.fetchIndustryMaster('SSSSSSSSSSSSSSS');
        try {
            IndustryMaster__c IndustryMaster_Obj = SmartBDM_BusinessTypeController.getIndustryMaster((String)'a3KN00000018aaaMAE');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    @isTest static void test_method_ScheduleBusinessType() {
        // SmartBDM_BusinessTypeController
        Test.startTest();
        SmartBDM_BusinessTypeSchedule sh = new SmartBDM_BusinessTypeSchedule();
        System.schedule('Test Territory Check', '0 0 2 * * ?', sh); 
        Test.stopTest();
    }

    @isTest static void test_method_excuteBatchBusinessTypeFinal() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            String authorized = '{'+
                '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                '"token_type": "bearer",'+
                '"expires_in": 3600,'+
                '"scope": "read write",'+
                '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                '"client_id": "xxxxx",'+
                '"version": "001-20181111",'+
                '"isSuccess": true,'+
                '"errorMessage": "",'+
                '"requestBody": "",'+
                '"responseBody": ""'+
            '}';
            
            AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
            Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.SmartBDMCalToolsCreateToken');
            orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, Datetime.now(), Datetime.now());
            orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
        

            // // Use StaticResourceCalloutMock built-in class to
            // // specify fake response and include response body 
            // // in a static resource.
            // StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
            // mock1.setStaticResource('SmartBDMMockupHTTPBusinessGroup');
            // mock1.setStatusCode(200);
            // mock1.setHeader('Content-Type', 'application/json');
            // // Set the mock callout mode
            // Test.setMock(HttpCalloutMock.class, mock1);

            // StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
            // mock2.setStaticResource('SmartBDMMockupHTTPBusinessType');
            // mock2.setStatusCode(200);
            // mock2.setHeader('Content-Type', 'application/json');
            // // Set the mock callout mode
            // Test.setMock(HttpCalloutMock.class, mock2);

            StaticResourceCalloutMock mock3 = new StaticResourceCalloutMock();
            mock3.setStaticResource('SmartBDMMockupHTTPBusinessTypeGroup');
            mock3.setStatusCode(200);
            mock3.setHeader('Content-Type', 'application/json');
            // Set the mock callout mode
            Test.setMock(HttpCalloutMock.class, mock3);

            // // Call the method for the first endpoint
            // SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessGroup = SmartBDM_Service.startCallGetBusinessGroupService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);
            // // Call the method for the second endpoint
            // SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessType = SmartBDM_Service.startCallGetBusinessTypeService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);
            

            List<IndustryMaster__c> IndustryMasterList = [SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c];
            Map<String, IndustryMaster__c> IndustryMasterMap = new Map<String, IndustryMaster__c>();
            for(IndustryMaster__c item : IndustryMasterList) {
                IndustryMasterMap.put(item.TMBCode__c, item);
            }
            System.debug(IndustryMasterMap);
            SmartBDM_BusinessTypeBatch BusinessType = new SmartBDM_BusinessTypeBatch(IndustryMasterMap, 2);
            Database.executeBatch(BusinessType, 200);

            Test.stopTest();
        }
    }

    @isTest static void test_method_excuteBatchBusinessTypeGroup() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            String authorized = '{'+
                '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                '"token_type": "bearer",'+
                '"expires_in": 36000,'+
                '"scope": "read write",'+
                '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                '"client_id": "xxxxx",'+
                '"version": "001-20181111",'+
                '"isSuccess": true,'+
                '"errorMessage": "",'+
                '"requestBody": "",'+
                '"responseBody": ""'+
            '}';

            AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
            Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.SmartBDMCalToolsCreateToken');
            orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, Datetime.now(), Datetime.now());
            orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
        
            StaticResourceCalloutMock mock3 = new StaticResourceCalloutMock();
            mock3.setStaticResource('SmartBDMMockupHTTPBusinessTypeGroup');
            mock3.setStatusCode(200);
            mock3.setHeader('Content-Type', 'application/json');
            // Set the mock callout mode
            Test.setMock(HttpCalloutMock.class, mock3);

            // Call the method for the first endpoint
            SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessGroup = SmartBDM_Service.startCallGetBusinessGroupService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);
            // Call the method for the second endpoint
            SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessType = SmartBDM_Service.startCallGetBusinessTypeService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);

            Test.stopTest();
        }
    }

    @isTest static void test_method_excuteBatchBusinessTypeGroup_negative() {
        User u = [SELECT Id FROM User WHERE Email = 'smartbdm@tmb.com.test' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            String authorized = '{'+
                '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                '"token_type": "bearer",'+
                '"expires_in": 3600,'+
                '"scope": "read write",'+
                '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                '"client_id": "xxxxx",'+
                '"version": "001-20181111",'+
                '"isSuccess": true,'+
                '"errorMessage": "",'+
                '"requestBody": "",'+
                '"responseBody": ""'+
            '}';

            AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
            Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.SmartBDMCalToolsCreateToken');
            orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, Datetime.now(), Datetime.now());
            orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
        
            // Set the mock callout mode
            Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseTokenFailed());
            // Call the method for the first endpoint
            SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessGroup = SmartBDM_Service.startCallGetBusinessGroupService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);
            // Call the method for the second endpoint
            SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper tmpBusinessType = SmartBDM_Service.startCallGetBusinessTypeService(SmartBDM_Utility.tokenKeyCalculateTools, 1, 5);

            List<IndustryMaster__c> IndustryMasterList = [SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c];
            Map<String, IndustryMaster__c> IndustryMasterMap = new Map<String, IndustryMaster__c>();
            for(IndustryMaster__c item : IndustryMasterList) {
                IndustryMasterMap.put(item.TMBCode__c, item);
            }
            System.debug(IndustryMasterMap);
            SmartBDM_BusinessTypeBatch BusinessType = new SmartBDM_BusinessTypeBatch(IndustryMasterMap, 2);
            Database.executeBatch(BusinessType, 200);
            
            Test.stopTest();
        }
    }
}