@isTest
public without sharing class PendingServiceRoutingTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        List<Group> g = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Line' AND Type = 'Queue' LIMIT 1];
        if (g.isEmpty()) {
            Group newg = new Group(Type = 'Queue', Name = 'Chat - Line', DeveloperName = 'Chat_Line');
            insert newg;
            g.add(newg);
        }
        QueueSobject supportObj = new QueueSobject(QueueId = g.get(0).Id, SobjectType = 'iigproduct_2__ChatSession__c');
        insert supportObj;
    }
    @isTest
    public static void testSuccess() {
        iigproduct_2__ChatSession__c c = new iigproduct_2__ChatSession__c();
        insert c;
        Set<Id> chatId = new Set<Id>();
        chatId.add(c.Id);
        ServiceChannel sc = [SELECT Id, relatedEntity FROM ServiceChannel WHERE relatedEntity = :'iigproduct_2__ChatSession__c'];
        Group g = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Line' AND Type = 'Queue' LIMIT 1];
        c.OwnerId = g.Id;
        update c;
        Set<Id> psrId = new Set<Id>();
        List<PendingServiceRouting> psr = [SELECT Id, CreatedBy.Name, CreatedById FROM PendingServiceRouting];
        for (PendingServiceRouting p : psr) {
            psrId.add(p.Id);	
        }
        List<AgentWork> agentw = [SELECT Id, AcceptDateTime, OwnerId, PendingServiceRoutingId, WorkItemId, RequestDateTime FROM AgentWork];
        Test.startTest();
        PendingServiceRoutingTriggerHandler.afterUpdate(psr, chatId);
        PendingServiceRouting psr2 = new PendingServiceRouting();
        psr2.workItemId = c.Id;
        psr2.RoutingType = 'SkillsBased';
        psr2.RoutingPriority = 1;
        psr2.CapacityWeight = 0;
        psr2.ServiceChannelId = sc.Id;
        psr2.RoutingModel = 'MostAvailable';
        psr2.IsReadyForRouting = false;
        psr2.CustomRequestedDateTime = System.now();
        psr2.PushTimeout = 120;
        insert psr2;
        psr2.IsReadyForRouting = true;
        User systemUser = [SELECT Id FROM User WHERE FirstName = 'System'];
        psr2.preferredUserId = systemUser.Id;
        psr2.OwnerId = UserInfo.getUserId();
        update psr2;

        try {
            AgentWork aw = new AgentWork(
                ServiceChannelId = sc.Id
            );
            insert aw;
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    /*
    @isTest
    public static void testPostSuccess() {
        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';
        insert runtrigger;

        AppConfig__c ac = new AppConfig__c(Name = 'encrypt_CardKey', Value__c = 'TMBCRM76380f&uexjslmdka(-yjr9UAT');
        insert ac;

        Skill_Master__c skillMaster = SocialPostTriggerHandler_Test.createSkillMaster();
        insert skillMaster;

        Social_Post_Author__c socialPostAuthor = SocialPostTriggerHandler_Test.createSocialPostAuthor();

        upsert socialPostAuthor;

        Social_Post__c socialPost = SocialPostTriggerHandler_Test.createSocialPost(socialPostAuthor.id);
        insert socialPost;
        Set<Id> postId = new Set<Id>();
        postId.add(socialPost.Id);
        ServiceChannel sc = [SELECT Id, relatedEntity FROM ServiceChannel WHERE relatedEntity = :'iigproduct_2__ChatSession__c'];
        Group queue = [SELECT Id FROM Group WHERE Type = 'queue' LIMIT 1];
        socialPost.OwnerId = queue.Id;
        update socialPost;
        Set<Id> psrId = new Set<Id>();
        List<PendingServiceRouting> psr = [SELECT Id, CreatedBy.Name, CreatedById FROM PendingServiceRouting];
        for (PendingServiceRouting p : psr) {
            psrId.add(p.Id);
        }
        List<AgentWork> agentw = [SELECT Id, AcceptDateTime, OwnerId, PendingServiceRoutingId, WorkItemId, RequestDateTime FROM AgentWork];
        Test.startTest();
        PendingServiceRoutingTriggerHandler.afterUpdateForSocialPost(psr, postId);
        Test.stopTest();
    }
    */
}