@IsTest
public class TestForEWMService{
	private static void createAppConfigList(){     
        //Create For After Refresh Sandbox
        List<Integration_Info__c> intInfoList = new List<Integration_Info__c>(); 

        Integration_Info__c intInfo = new Integration_Info__c();
        intInfo.Name = 'EWMService';
        intInfo.Endpoint__c = 'https://xxxxx.tmbbank.com/common/EWMService/UAT/EWMService/CRMIntegrationService.svc/InvokeEWMProcess';
        intInfo.Request_Format__c = 'application/xml';
        intInfo.Response_Format__c = 'application/xml';
        intInfo.Timeout__c = Decimal.valueOf('15');

        intInfoList.add(intInfo);
        insert intInfoList;
    }

    private static void createAppConfigListForJson(){     
        //Create For After Refresh Sandbox
        List<Integration_Info__c> intInfoList = new List<Integration_Info__c>(); 

        Integration_Info__c intInfo1 = new Integration_Info__c();
        intInfo1.Name = 'EWMService';
        intInfo1.Endpoint__c = 'https://xxxxx.tmbbank.com/common/EWMService/UAT/EWMService/CRMIntegrationService.svc/InvokeEWMProcess';
        intInfo1.Request_Format__c = 'application/json';
        intInfo1.Response_Format__c = 'application/json';
        intInfo1.Timeout__c = Decimal.valueOf('15');

        intInfoList.add(intInfo1);
        insert intInfoList;
    }


    private static void prepareDataForS2O() {
    	List<S2O_Code_Mapping__c> mappingList = new List<S2O_Code_Mapping__c>();

    	S2O_Code_Mapping__c mapping = new S2O_Code_Mapping__c();

    	mapping.CRM_Task_Key__c = 'Credit1312 Credit Repayment - H1 (1 Day)';
    	mapping.EWM_Service_EN_Type_Desc__c = '';
    	mapping.EWM_Service_TH_Type_Desc__c = '';
    	mapping.EWM_Service_Type_Code__c = '00301';
    	mapping.isActive__c = true;
    	mapping.Segment__c = '';
    	mapping.Service_Level_1__c = '';
    	mapping.Service_Level_2__c = '';
    	mapping.Service_Level_3__c = 'Credit';
    	mapping.Service_Level_4__c = '1312 Credit Repayment - H1 (1 Day)';
    	mappingList.add(mapping);

    	insert mappingList;


    	List<Integration_Mapping__c> inteMappingList = new List<Integration_Mapping__c>();

    	Integration_Mapping__c inteMap = new Integration_Mapping__c();
    	inteMap.Name = 'EWMService';
    	inteMap.Batch_SQL__c = 'SELECT Id,Main_Task__c,Sub_Task__c,WhatId,Description,What.Name FROM Task Where Id={1} AND Main_Task__c <> null AND Sub_Task__c <> null AND RecordType.DeveloperName in (\'WBG_Task\',\'Task_Record_type\')';
    	inteMap.Condition_1__c = 'equals';
    	inteMap.Condition_2__c = '';
    	inteMap.Condition_3__c = '';
    	inteMap.Field_Condition_1__c = 'WhatId';
    	inteMap.Field_Condition_2__c = '';
    	inteMap.Field_Condition_3__c = '';

    	inteMap.Field_Value_1__c	 = '001';
    	inteMap.Field_Value_2__c = '';
    	inteMap.Field_Value_3__c = '';
    	inteMap.Variable_Field_1__c = 'Id';

    	inteMappingList.add(inteMap);

    	insert inteMappingList;

    	List<EIM_Map__c> eimList = new List<EIM_Map__c>();

    	EIM_Map__c eim = new EIM_Map__c();
    	eim.Attribute__c = '';
    	eim.Attribute_value__c = '';
    	eim.Default_Value__c = '';
    	eim.External_Field__c = 'CustomerRMNo';
    	eim.Field_Order__c = Decimal.valueOf('2');
    	eim.Field_Type__c = 'Request';
    	eim.IsActive__c = true;
    	eim.Job_Type__c = 'EWMService';
    	eim.Node__c = 'S20ChildNode';

    	eim.Object__c = 'Account';
    	eim.ParentNode__c = 'S20HeadNode';
    	eim.SF_Field__c = 'TMB_Customer_ID_PE__c';

    	EIM_Map__c eim2 = new EIM_Map__c();
    	eim2.Attribute__c = '';
    	eim2.Attribute_value__c = '';
    	eim2.Default_Value__c = 'In Progress';
    	eim2.External_Field__c = 'IsSuccess';
    	eim2.Field_Order__c = Decimal.valueOf('2');
    	eim2.Field_Type__c = 'MainResponse';
    	eim2.IsActive__c = true;
    	eim2.Job_Type__c = 'EWMService';
    	eim2.Node__c = 'S20ResposeHeadNode';

    	eim2.Object__c = 'Account';
    	eim2.ParentNode__c = '';
    	eim2.SF_Field__c = 'Status';

        EIM_Map__c eim3 = new EIM_Map__c();
        eim3.Attribute__c = '';
        eim3.Attribute_value__c = '';
        eim3.Default_Value__c = '';
        eim3.External_Field__c = 'ServiceRefID';
        eim3.Field_Order__c = Decimal.valueOf('2');
        eim3.Field_Type__c = 'Response';
        eim3.IsActive__c = true;
        eim3.Job_Type__c = 'EWMService';
        eim3.Node__c = 'S20ResposeHeadNode';

        eim3.Object__c = 'Account';
        eim3.ParentNode__c = '';
        eim3.SF_Field__c = 'EWM_Id__c';

        EIM_Map__c eim4 = new EIM_Map__c();
        eim4.Attribute__c = '';
        eim4.Attribute_value__c = '';
        eim4.Default_Value__c = '';
        eim4.External_Field__c = 'ServiceType';
        eim4.Field_Order__c = Decimal.valueOf('14');
        eim4.Field_Type__c = 'Request';
        eim4.IsActive__c = true;
        eim4.Job_Type__c = 'EWMService';
        eim4.Node__c = 'S20ChildNode';

        eim4.Object__c = 'S2O_Code_Mapping__c';
        eim4.ParentNode__c = 'S20HeadNode';
        eim4.SF_Field__c = 'EWM_Service_Type_Code__c';

        EIM_Map__c eim5 = new EIM_Map__c();
        eim5.Attribute__c = '';
        eim5.Attribute_value__c = '';
        eim5.Default_Value__c = '';
        eim5.External_Field__c = 'Segment';
        eim5.Field_Order__c = Decimal.valueOf('12');
        eim5.Field_Type__c = 'Request';
        eim5.IsActive__c = true;
        eim5.Job_Type__c = 'EWMService';
        eim5.Node__c = 'S20ResposeHeadNode';

        eim5.Object__c = 'Account';
        eim5.ParentNode__c = 'S20HeadNode';
        eim5.SF_Field__c = 'Core_Banking_Suggested_Segment__c';

        EIM_Map__c eim6 = new EIM_Map__c();
        eim6.Attribute__c = '';
        eim6.Attribute_value__c = '';
        eim6.Default_Value__c = '';
        eim6.External_Field__c = 'ServiceRefID1';
        eim6.Field_Order__c = Decimal.valueOf('13');
        eim6.Field_Type__c = 'Request';
        eim6.IsActive__c = true;
        eim6.Job_Type__c = 'EWMService';
        eim6.Node__c = 'S20ChildNode';

        eim6.Object__c = 'Task';
        eim6.ParentNode__c = 'S20HeadNode';
        eim6.SF_Field__c = 'Id';

        EIM_Map__c eim7 = new EIM_Map__c();
        eim7.Attribute__c = '';
        eim7.Attribute_value__c = '';
        eim7.Default_Value__c = '';
        eim7.External_Field__c = 'BranchName';
        eim7.Field_Order__c = Decimal.valueOf('16');
        eim7.Field_Type__c = 'Request';
        eim7.IsActive__c = true;
        eim7.Job_Type__c = 'EWMService';
        eim7.Node__c = 'S20ChildNode';

        eim7.Object__c = '';
        eim7.ParentNode__c = 'S20HeadNode';
        eim7.SF_Field__c = 'Branch_and_Zone__r.Name';

        EIM_Map__c eim8 = new EIM_Map__c();
        eim8.Attribute__c = 'xmlns';
        eim8.Attribute_value__c = 'http://schemas.datacontract.org/2004/07/Kofax.TMB.S2O.Common';
        eim8.Default_Value__c = '';
        eim8.External_Field__c = 'CRMIntegrationData';
        //eim8.Field_Order__c = Decimal.valueOf('1');
        eim8.Field_Type__c = 'Request';
        eim8.IsActive__c = true;
        eim8.Job_Type__c = 'EWMService';
        eim8.Node__c = 'S20HeadNode';

        eim8.Object__c = '';
        eim8.ParentNode__c = '';
        eim8.SF_Field__c = null;

    	eimList.add(eim);
    	eimList.add(eim2);
        eimList.add(eim3);
        eimList.add(eim4);
        eimList.add(eim5);
        eimList.add(eim6);
        eimList.add(eim7);
        eimList.add(eim8);
    	insert eimList;
    }


     //Test class for EWMService
    public static testmethod void testForEWMService(){
    	Test.startTest();
        TestUtils.createAppConfig();
    	createAppConfigList();
    	prepareDataForS2O();

    	TestInit.createAccount(3);


        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockupEWMServiceResponse());

    	//create task
        List<Task> listTask = new List<Task>();
        ID rctypeID = [SELECT Id FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%Retail%') limit 1].Id; 

        for( Integer i = 0 ; i < TestInit.accountList.size() ; i++ ){
            Task t = new Task(OwnerId=UserInfo.getUserId(),
                         Subject='Call',
                         Status='Open',
                         Main_Task__c = 'Credit',
                         Sub_Task__c  = '1312 Credit Repayment - H1 (1 Day)',
                         ActivityDate = Date.today(),
                         WhatId = TestInit.accountList.values().get(i).Id,
                         recordtypeID = rctypeID 
                        );            
            listTask.add(t);
        }
        insert listTask;

        Test.stopTest();
	}

    public static testmethod void testForEWMServiceForJson(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigListForJson();
        prepareDataForS2O();

        TestInit.createAccount(3);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockupEWMServiceResponse());

        //create task
        List<Task> listTask = new List<Task>();
        ID rctypeID = [SELECT Id FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%Retail%') limit 1].Id; 

        for( Integer i = 0 ; i < TestInit.accountList.size() ; i++ ){
            Task t = new Task(OwnerId=UserInfo.getUserId(),
                         Subject='Call',
                         Status='Open',
                         Main_Task__c = 'Credit',
                         Sub_Task__c  = '1312 Credit Repayment - H1 (1 Day)',
                         ActivityDate = Date.today(),
                         WhatId = TestInit.accountList.values().get(i).Id,
                         recordtypeID = rctypeID 
                        );            
            listTask.add(t);
        }
        insert listTask;
        Test.stopTest();
    }

    public static testmethod void testForEWMServiceNotCallout(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigListForJson();
        prepareDataForS2O();

        TestInit.createAccount(3);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockupEWMServiceResponse());

        //create task
        List<Task> listTask = new List<Task>();
        ID rctypeID = [SELECT Id FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%Retail%') limit 1].Id; 

        for( Integer i = 0 ; i < TestInit.accountList.size() ; i++ ){
            Task t = new Task(OwnerId=UserInfo.getUserId(),
                         Subject='Call',
                         Status='Open',
                         Main_Task__c = 'Credit',
                         Sub_Task__c  = '1312 Credit Repayment - H1 (1 Day)111',
                         ActivityDate = Date.today(),
                         WhatId = TestInit.accountList.values().get(i).Id,
                         recordtypeID = rctypeID 
                        );            
            listTask.add(t);
        }
        insert listTask;
        Test.stopTest();
    }



    class TaskValueMapForTest extends RestfulServiceUtil.ValueMapBase {
        public override 
            Boolean isErrorNotCallout(Map<String,String> valueMap){ return true;}

        public override 
            Map<String,String> prepareValueMap(SObject sobj,EIMManager manager){ return new Map<String,String>();}

    }

    public static testmethod void testForEWMServiceForOthercase(){
        Test.startTest();
        TestUtils.createAppConfig();
        createAppConfigListForJson();
        prepareDataForS2O();
        TestInit.createAccount(3);

        Test.setMock(HttpCalloutMock.class, new MockupEWMServiceResponse());

        List<Task> listTask = new List<Task>();
        ID rctypeID = [SELECT Id FROM RecordType where IsActive= true and SobjectType= 'Task' and (NOT Name like '%Retail%') limit 1].Id; 

        for( Integer i = 0 ; i < TestInit.accountList.size() ; i++ ){
            Task t = new Task(OwnerId=UserInfo.getUserId(),
                         Subject='Call',
                         Status='Open',
                         Main_Task__c = 'Credit',
                         Sub_Task__c  = '1312 Credit Repayment - H1 (1 Day)111',
                         ActivityDate = Date.today(),
                         WhatId = TestInit.accountList.values().get(i).Id,
                         recordtypeID = rctypeID 
                        );            
            listTask.add(t);
        }
        insert listTask;
        
        String batchSQL = 'SELECT Id From Task';
        RestfulServiceUtil restService = new RestfulServiceUtil(batchSQL,'EWMService');
                        
        restService.setValueMapImpl(new TaskValueMapForTest());
        restService.runBatch();

        Account acc = new Account();
        RTL_Online_Service_Log__c log = new RTL_Online_Service_Log__c();
        log.RTL_Customer_Name__c = 'EWMService';


        //restService.retryCallout(acc,log,'');
        Test.stopTest();

    }
}