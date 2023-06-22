@isTest
public without sharing class CaseAutoCreateTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        Skill_Master__c skill = new Skill_Master__c(
            Validate_Code__c = 'X0000',
            Source__c = 'Chat - Line',
            Topic__c = 'สอบถามเรื่องทั่วไปและข้อเสนอแนะ',
            Assign_to_Queue__c = 'Chat - Line'
        );
        insert skill;
        Skill_Master__c skill1 = new Skill_Master__c(
            Validate_Code__c = 'X0000',
            Source__c = 'Chat - Facebook',
            Topic__c = 'สอบถามเรื่องทั่วไปและข้อเสนอแนะ',
            Assign_to_Queue__c = 'Chat - Facebook'
        );
        insert skill1;
        Skill_Master__c skill2 = new Skill_Master__c(
            Validate_Code__c = 'X0000',
            Source__c = 'Chat - ttb Web',
            Topic__c = 'สอบถามเรื่องทั่วไปและข้อเสนอแนะ',
            Assign_to_Queue__c = 'Chat - Website'
        );
        insert skill2;
    }

    @isTest
    public static void testSuccess() {
        List<Id> chatSessionIdList = new List<Id>();

        iigproduct_2__SocialAccount__c socialAccount = new iigproduct_2__SocialAccount__c(
            iigproduct_2__Avatar_URL__c = 'test_avatar_url', 
            iigproduct_2__Display_Name__c = 'testSocialAccount', 
            iigproduct_2__Social_ID__c = 'U551bf1d427ed66416a5a7d5b0186962e', 
            iigproduct_2__Social_Type__c = 'Line'
        );
        insert socialAccount;
        
        iigproduct_2__ChatSession__c chatSession = new iigproduct_2__ChatSession__c(
            iigproduct_2__Social_ID__c = socialAccount.Id,
            iigproduct_2__Status__c = 'Waiting'
        );
        insert chatSession;

        iigproduct_2__SocialAccount__c socialAccount1 = new iigproduct_2__SocialAccount__c(
            iigproduct_2__Avatar_URL__c = 'test_avatar_url1', 
            iigproduct_2__Display_Name__c = 'testSocialAccount1', 
            iigproduct_2__Social_Type__c = 'ttb Website'
        );
        insert socialAccount1;
        
        iigproduct_2__ChatSession__c chatSession1 = new iigproduct_2__ChatSession__c(
            iigproduct_2__Social_ID__c = socialAccount1.Id,
            iigproduct_2__Status__c = 'Waiting'
        );
        insert chatSession1;

        iigproduct_2__SocialAccount__c socialAccount2 = new iigproduct_2__SocialAccount__c(
            iigproduct_2__Avatar_URL__c = 'test_avatar_url2', 
            iigproduct_2__Display_Name__c = 'testSocialAccount2', 
            iigproduct_2__Social_Type__c = 'Facebook'
        );
        insert socialAccount2;
        
        iigproduct_2__ChatSession__c chatSession2 = new iigproduct_2__ChatSession__c(
            iigproduct_2__Social_ID__c = socialAccount2.Id,
            iigproduct_2__Status__c = 'Waiting'
        );
        insert chatSession2;

        chatSessionIdList.add(chatSession.Id);
        chatSessionIdList.add(chatSession1.Id);
        chatSessionIdList.add(chatSession2.Id);

        Map<Id, AgentWork> chatworkMap = new Map<Id, AgentWork>();

        Test.startTest();
        CaseAutoCreateTriggerHandler.afterUpdate(chatSessionIdList, chatworkMap);
        List<iigproduct_2__ChatSession__c> testChat = [SELECT Id, iigproduct_2__Case__c FROM iigproduct_2__ChatSession__c];
        Case c = [SELECT Id, Status, Category__c FROM Case WHERE Id =: testChat[0].iigproduct_2__Case__c LIMIT 1];
        c.Category__c = 'Complaint';
        c.Status = 'Inprogress';
        c.Journey__c = 'Interest / Inquiry';
        c.Problem_Type__c = 'Quality/Suitability - ได้รับบริการ แต่ลูกค้าไม่พอใจ';
        update c;
        Test.stopTest();
    }

    @isTest
    public static void testSuccessEmail() {
        List<Id> caseIdList = new List<Id>();

        EmailMessage email = new EmailMessage();
        insert email;
        Case c = new Case(SourceId = email.Id, Contact_Person_Name__c = 'test001');
        insert c;

        caseIdList.add(c.Id);

        Map<Id, AgentWork> caseworkMap = new Map<Id, AgentWork>();

        Test.startTest();
        CaseAutoCreateTriggerHandler.afterUpdateForCase(caseIdList, caseworkMap);
        Test.stopTest();
    }
}