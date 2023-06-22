@isTest
public class DeleteOpptyTeamHistoryScheduledTest {
    public static String CRON_EXP = '0 0 1 5 7 ?';
    public static testMethod void ScheduleDeleteOppteamTest(){
        //--- query use for batch ---
        String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        //---create related objects ---
        TestInit.createUser(false);
        List<User> userList = TestUtils.createUsers(10, 'fn','Ln', 'test@tmbbank.com', true);
        system.debug('##---TestInit.us : '+TestInit.us);
        system.debug('##---TestInit.us2: '+TestInit.us2);
        
        List<OpportunityTeamMemberHistory__c> oppteamHisSingleList = new List<OpportunityTeamMemberHistory__c>();
        for(Integer i = 0 ; i < 200 ;i++){  
        OpportunityTeamMemberHistory__c oppteamHis = new OpportunityTeamMemberHistory__c();
            oppteamHis.OpptyTeamId__c = '1234567891011'+i;
            oppteamHis.OpptyId__c = '1234567891011'+i;
            oppteamHis.User__c = userList.get(0).Id;
            oppteamHis.Opportunity_Access__c = 'Edit';
            oppteamHis.Team_Role__c = 'Sales Rep';
            oppteamHisSingleList.add(oppteamHis);
        }
            insert oppteamHisSingleList;
            system.debug('##---oppteamHisSingleList : '+oppteamHisSingleList.size());
       
       Test.startTest();
      // Schedule the test job
      String jobId = System.schedule('DeleteOppTeam',
                        CRON_EXP, 
                        new DeleteOpptyTeamHistoryScheduled());
         System.debug('##---jobId :'+jobId);
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
        System.debug('##---cron trigger :'+ct);

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      //System.assertEquals('2559-07-05 01:00:00',String.valueOf(ct.NextFireTime));
        
      // Verify the scheduled job hasn't run yet.
      system.debug('##---oppteamHisSingleList test : '+oppteamHisSingleList);
      System.assertEquals(oppteamHisSingleList.size(),200);
        
      Test.stopTest();
    }
    
    public static testMethod void BatchDeleteOppteamTest(){
        String query = 'SELECT Id FROM OpportunityTeamMemberHistory__c';
        List<User> userList = TestUtils.createUsers(10, 'fn','Ln', 'test@tmbbank.com', true);
        List<OpportunityTeamMemberHistory__c> oppteamHisList = new List<OpportunityTeamMemberHistory__c>();
        for(Integer i = 0 ; i < 200 ;i++){  
        OpportunityTeamMemberHistory__c oppteamHis = new OpportunityTeamMemberHistory__c();
            oppteamHis.OpptyTeamId__c = '1234567891011'+i;
            oppteamHis.OpptyId__c = '1234567891011'+i;
            oppteamHis.User__c = userList.get(1).Id;
            oppteamHis.Opportunity_Access__c = 'Edit';
            oppteamHis.Team_Role__c = 'Sales Rep';
            oppteamHisList.add(oppteamHis);
        }
            insert oppteamHisList;
            system.debug('##---oppteamHisList : '+oppteamHisList.size());
        Test.startTest();
        DeleteOpptyTeamHistory del = new DeleteOpptyTeamHistory(query);
        Database.executeBatch(del);
        Test.stopTest();
        
        Integer count = [SELECT COUNT() FROM OpportunityTeamMemberHistory__c];
        System.assertEquals(count, 0);
    }

    public static void RunSingleRecord(String query, List<User> userList){
        system.debug('##---Run Single Record---');
        List<OpportunityTeamMemberHistory__c> oppteamHisSingleList = new List<OpportunityTeamMemberHistory__c>();
            OpportunityTeamMemberHistory__c oppteamHis = new OpportunityTeamMemberHistory__c();
            oppteamHis.OpptyTeamId__c = '1234567891011121';
            oppteamHis.OpptyId__c = '1234567891011121';
            oppteamHis.User__c = userList.get(0).Id;
            oppteamHis.Opportunity_Access__c = 'Edit';
            oppteamHis.Team_Role__c = 'Sales Rep';
            oppteamHisSingleList.add(oppteamHis);
            insert oppteamHisSingleList;
            system.debug('##---oppteamHisSingleList : '+oppteamHisSingleList.size());
            Test.startTest();
            //DeleteOpptyTeamHistory del = new DeleteOpptyTeamHistory(query);
            DeleteOpptyTeamHistoryScheduled delsch = new DeleteOpptyTeamHistoryScheduled();
            //Id BatchProcessId = Database.executeBatch(del);
            Test.stopTest();

        //--- check record number ---
        List<OpportunityTeamMemberHistory__c> recCount = new List<OpportunityTeamMemberHistory__c>([SELECT Id FROM OpportunityTeamMemberHistory__c WHERE LastModifiedDate = LAST_MONTH]);
        System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }
    
    public static void Run200Records(String query, List<OpportunityTeamMember> oppteamlst , List<Opportunity> oppList , List<User> userList){
        system.debug('##---Run 200 Records---');
        List<OpportunityTeamMemberHistory__c> oppteamHisMoreRecords = new List<OpportunityTeamMemberHistory__c>();
        for(Integer i = 0 ; i < 200; i++){
            OpportunityTeamMemberHistory__c oppteamHis = new OpportunityTeamMemberHistory__c();
            oppteamHis.OpptyTeamId__c = oppteamlst.get(0).Id;
            oppteamHis.OpptyId__c = oppList.get(0).Id;
            oppteamHis.User__c = userList.get(0).Id;
            oppteamHis.Opportunity_Access__c = 'Edit';
            oppteamHis.Team_Role__c = 'Sales Rep';
            oppteamHisMoreRecords.add(oppteamHis);
        }
        insert oppteamHisMoreRecords;
        system.debug('##---oppteamHisMoreRecords : '+oppteamHisMoreRecords.size());
        DeleteOpptyTeamHistory delMore = new DeleteOpptyTeamHistory(query);
        Id BatchProcessId = Database.executeBatch(delMore);
        //--- check record number ---
        List<OpportunityTeamMemberHistory__c> recCount = new List<OpportunityTeamMemberHistory__c>([SELECT Id FROM OpportunityTeamMemberHistory__c WHERE LastModifiedDate = LAST_MONTH]);
        System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }
    
    public static void Run500Records(String query, List<OpportunityTeamMember> oppteamlst , List<Opportunity> oppList , List<User> userList){
        system.debug('##---Run 500 Records---');
        List<OpportunityTeamMemberHistory__c> oppteamHis500Records = new List<OpportunityTeamMemberHistory__c>();
        for(Integer i = 0 ; i < 500; i++){
            OpportunityTeamMemberHistory__c oppteamHis = new OpportunityTeamMemberHistory__c();
            oppteamHis.OpptyTeamId__c = oppteamlst.get(0).Id;
            oppteamHis.OpptyId__c = oppList.get(0).Id;
            oppteamHis.User__c = userList.get(0).Id;
            oppteamHis.Opportunity_Access__c = 'Edit';
            oppteamHis.Team_Role__c = 'Sales Rep';
            oppteamHis500Records.add(oppteamHis);
        }
        insert oppteamHis500Records;
        system.debug('##---oppteamHis500Records : '+oppteamHis500Records.size());
        DeleteOpptyTeamHistory delMore = new DeleteOpptyTeamHistory(query);
        Id BatchProcessId = Database.executeBatch(delMore);
        
        //--- check record number ---
        List<OpportunityTeamMemberHistory__c> recCount = new List<OpportunityTeamMemberHistory__c>([SELECT Id FROM OpportunityTeamMemberHistory__c WHERE LastModifiedDate = LAST_MONTH]);
        System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }

}