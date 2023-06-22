@isTest
public without sharing class fnaGenerateFlow_Test {

    /*@isTest
    private static void Test_checkAnswerFlow() {
        TestUtils.createAppConfig_Trigger();
        TestUtils.createAppConfig();

        List<Avatar_Result_Mapping_Temp__c> listAvatarResultMapTemp = new List<Avatar_Result_Mapping_Temp__c>();
        Avatar_Result_Mapping_Temp__c avatarResultMapTemp = new Avatar_Result_Mapping_Temp__c();
        avatarResultMapTemp.Questionnaire_Flow__c = 'test';
        avatarResultMapTemp.Answer_Flow__c = 'test';
        listAvatarResultMapTemp.add(avatarResultMapTemp);
        insert listAvatarResultMapTemp;

        List<AvatarResultMapping__c> listAvatarResultMap = new List<AvatarResultMapping__c>();
        AvatarResultMapping__c avatarResultMap = new AvatarResultMapping__c();
        avatarResultMap.Answer__c = 'test';
        avatarResultMap.isActive__c = true;
        listAvatarResultMap.add(avatarResultMap);
        insert listAvatarResultMap;

        List<Avatar_Master__c> listAvatarMaster = new List<Avatar_Master__c>();
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        listAvatarMaster.add(avatarMaster);
        insert listAvatarMaster;

        List<Avatar_Combination__c> listAvatarCom = new List<Avatar_Combination__c>();
        Avatar_Combination__c avatarCom = new Avatar_Combination__c();
        avatarCom.Avatar_Master__c = listAvatarMaster[0].Id;
        listAvatarCom.add(avatarCom);
        insert listAvatarCom;

        fnaGenerateFlow.checkAnswerFlow(listAvatarResultMapTemp);
    }*/
    
    @isTest
    private static void Test_generateFlow(){
        
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        insert avatarMaster;
        
        List<Avatar_Combination__c> listAvatarCom = new List<Avatar_Combination__c>();
        for(integer i=0; i < 2; i++){
            Avatar_Combination__c avatarCom = new Avatar_Combination__c();
                avatarCom.Avatar_Master__c = avatarMaster.Id;
                avatarCom.Question__c = 'Q' + i;
                avatarCom.Answer__c = 'A,B,C';
                avatarCom.SequenceNo__c = i;
            listAvatarCom.add(avatarCom);
        }
        insert listAvatarCom;
        
        Avatar_Result_Mapping_Temp__c temp = new Avatar_Result_Mapping_Temp__c();
        temp.Avatar_Master__c = avatarMaster.Id;
        temp.Questionnaire_Flow__c = 'Q1Q2Q3';
        temp.Answer_Flow__c = 'AXBCD';
        insert temp;
        
        Test.startTest();
        	fnaGenerateFlow.checkTemp();
        	fnaGenerateFlow.generateFlow();
        Test.stopTest();
    }
    
    @isTest
    private static void Test_confirmFlow(){
        
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        insert avatarMaster;
        
        Avatar_Result_Mapping_Temp__c temp = new Avatar_Result_Mapping_Temp__c();
        temp.Avatar_Master__c = avatarMaster.Id;
        temp.Questionnaire_Flow__c = 'Q1Q2Q3';
        temp.Answer_Flow__c = 'AXBCD';
        temp.isDuplicate__c = true;
        insert temp;
        
        Test.startTest();
        	fnaGenerateFlow.checkTemp();
        	fnaGenerateFlow.confirmFlow();
        	fnaInsertToAvatarResultMappingBatch.errLogs err = new fnaInsertToAvatarResultMappingBatch.errLogs();
        	err.id = '123456';
        	err.fieldErr = '';
        	err.statusCode = '500';
        	err.errMesg = '';
        Test.stopTest();
    }
    
    @isTest
    private static void Test_checkAnswerFlow(){
        
        Avatar_Master__c avatarMaster = new Avatar_Master__c();
        avatarMaster.Segment__c = 'Default';
        insert avatarMaster;
        
        List<Avatar_Result_Mapping_Temp__c> tempList = new List<Avatar_Result_Mapping_Temp__c>();
        for(integer i=0; i < 2; i++){
            Avatar_Result_Mapping_Temp__c temp = new Avatar_Result_Mapping_Temp__c();
            temp.Avatar_Master__c = avatarMaster.Id;
            temp.Questionnaire_Flow__c = 'Q1Q2Q' + i;
            temp.Answer_Flow__c = 'AXBCD' + i;
            temp.isDuplicate__c = true;
            tempList.add(temp);
        }
        	
        insert tempList;
        
        Test.startTest();
        	List<fnaGenerateFlow.Data_Duplicate> dataDupList = fnaGenerateFlow.checkAnswerFlow(tempList);
        
        	fnaGenerateFlow.Data data = new fnaGenerateFlow.Data();
            data.avatar = 'Avatar';
            data.question = 'question';
            data.answer = new List<String>();
        	
            
        Test.stopTest();
    }
    
    @isTest
    private static void Test_checkTemp(){
    	Test.startTest();
        	fnaGenerateFlow.checkTemp();
        Test.stopTest();
    }

    
}