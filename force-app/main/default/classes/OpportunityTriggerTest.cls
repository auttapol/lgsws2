@IsTest


public class OpportunityTriggerTest {
    public static String STR_POSITIVE = 'positive';
    public static String STR_NEGATIVE = 'negative';
    public static final ID SE_CREDIT_PRODUCT2_ID = [Select ID from recordtype where name ='SE Credit Product2'].Id;
    
    static {

        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        TestUtils.createDisqualifiedReason();
        TestUtils.CreateOpportunityStage();
      
    }

/*    
    public static testmethod void RunPositiveTestOpportunity(){
        System.debug(':::: RunPositiveTestOpportunity Start ::::');
        
        TestInit.createUser(false);
        User u = TestInit.us;
        user u2 = TestInit.us2;
        System.runAs(u) {
            
            TestInit.createAccount( 3 );
            List<Account> accountList = TestInit.accountList.values();
            
            TestInit.createTarget( TestInit.accountList.values() ); 
            
            
           
            accountList.get(0).OwnerId = u2.Id;
            update accountList.get(0);
            TestInit.createOpportunity( TestInit.accountList.values() ); 
            List<Opportunity> opportunityList = TestInit.opportunityList.values();
            accountList.get(0).OwnerId = u.Id;
            update accountList.get(0);
            TestInit.createOpportunity( TestInit.accountList.values() ); 
            opportunityList = TestInit.opportunityList.values();
            List<String> listStageName = new List<String>();
            listStageName.add('CA-Prep');
            listStageName.add('Approval Process');
            listStageName.add('Post Approval');
            listStageName.add('Limit Setup');
            Integer sumAmount = 0;
            List<Opportunity> listOpp = [select Id,Name,StageName from Opportunity where Id IN :opportunityList order by Id asc];
            List<Target__c> listTarget = [select OwnerId,Monthly_Close_Sales_Actual__c,Monthly_Close_Sales_Amount__c,
                                          Monthly_App_In_Actual__c,Monthly_App_In_Amount__c,
                                          Monthly_Approved_Actual__c,Monthly_Approved_Amount__c,
                                          Monthly_Set_Up_Actual__c,Monthly_Set_Up_Amount__c
                                          from Target__c 
                                          where Id IN :TestInit.targetList.keySet() Order by Id asc];
             TEST.startTest();
            for(Integer i = 0 ; i < listStageName.size() ; i++){ 
               
                for( Opportunity o : listOpp ){
                    o.StageName = listStageName.get(i);
                    o.Approved_Amount__c = 10*(i+1);
                }
                //Tinnakrit Edit - Aug 1
                //update listOpp;                   
            }
           
            //Tinnakrit Add - Aug 1
            update listopp;
            
            
            //Test For CAID
            List<AccountTeamMember> accountTeamMemberList = TestInit.createAccountTeamMember(1,accountList.get(0).id,UserInfo.getUserId());
            List<Opportunity> listTest = new List<Opportunity>();
            for( Integer i = 0 ; i<1 ; i++ ){
                Opportunity o = new Opportunity();
                o.OwnerId = UserInfo.getUserId();
                o.StageName = 'Analysis';
                o.Name = 'test-'+i;
                o.CloseDate = Date.today();
                o.AccountId = accountList.get(0).Id;
                o.Trigger_flag__c = true;
                listTest.add(o);
            }
            insert listTest;
            System.debug('::::: insert ListTest is : ' + listTest.size() +' row :::::');
            
            TEST.stopTest();
        }
        System.debug(':::: RunPositiveTestOpportunity End ::::');
    }
    
    public static void flowTest(String testMode){
        //Test For T07,T08,T09,T10
        List<String> listStageName = new List<String>();
        listStageName.add('CA-Prep');
        listStageName.add('Approval Process');
        listStageName.add('Post Approval');
        listStageName.add('Limit Setup');
        Integer sumAmount = 0;
        List<Opportunity> listOpp = [select Id,Name,StageName from Opportunity where Id IN :TestInit.opportunityList.keySet() order by Id asc];
        List<Target__c> listTarget = [select OwnerId,Monthly_Close_Sales_Actual__c,Monthly_Close_Sales_Amount__c,
                                      Monthly_App_In_Actual__c,Monthly_App_In_Amount__c,
                                      Monthly_Approved_Actual__c,Monthly_Approved_Amount__c,
                                      Monthly_Set_Up_Actual__c,Monthly_Set_Up_Amount__c
                                      from Target__c 
                                      where Id IN :TestInit.targetList.keySet() Order by Id asc];
        
        Test.startTest();
        for(Integer i = 0 ; i < listStageName.size() ; i++){ 
            System.debug('oBefore : '+listOpp);
            for( Opportunity o : listOpp ){
                o.StageName = listStageName.get(i);
                o.Approved_Amount__c = 10*(i+1);
            }
            System.debug('oAfter : '+listOpp);
            //Tinnakrit Edit - Aug 1
            //update listOpp;
            
            Date currentDate = Date.today();
            Integer currentYear = currentDate.year();
            Integer currentMonth = currentDate.month();
            
            for( Target__c target : listTarget ){
               
            }      
        }
        //Tinnakrit Add - Aug 1
        update listOpp;
        
        Test.stopTest();
    }
*/

    static testmethod void TestTrigger(){
        Test.startTest();
        

        User u = TestUtils.createUsers(1, 'F', 'L' ,'test@tmbbank.com', true).get(0);
        u.Segment__c = 'MB';
        u.Zone__c = 'MB2-4';
        update u;

        System.runAs(u)
        {
            TestInit.createAccount( 3 );
            List<Account> accountList = TestInit.accountList.values();
            TestInit.createOpportunity( accountList ); 
            List<Opportunity> opportunityList = TestInit.opportunityList.values();

            update opportunityList;


            for (opportunity o : opportunityList)
            {
                o.RecordtypeID = SE_CREDIT_PRODUCT2_ID;
                o.CA_Prep_Start_Date__c = date.valueof('2016-12-05');
                o.Approval_Process_Date__c = date.valueof('2016-12-05');
                o.Post_Approval_Date__c = date.valueof('2016-12-05');
            }
            update opportunityList;


            for (opportunity o : opportunityList)
            {
                o.Application_Status__c = 'UW2';
            }
            update opportunityList;


            List<String> listStageName = new List<String>();
            listStageName.add('CA-Prep');
            listStageName.add('Approval Process');
            listStageName.add('Post Approval');
            // listStageName.add('Limit Setup');

            for (String s: listStageName)
            {
                for (opportunity o : opportunityList)
                {
                    o.Stagename = s;
                }
                update opportunityList;
            }
        }


        Test.stopTest();
    }
    
    static testmethod void testUpdateOppCampaign()
    {
        test.startTest();
        testutils.createAppConfig();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        Campaign camp2 = new Campaign();
            camp2.Name = 'Campaign_2';
            camp2.Segment__c = 'SE';
            camp2.OwnerId  = userinfo.getUserId();
        	insert camp2;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(2,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(1).campaignid = camp.id;
        	update listopp;
        list<id> listoppid = new list<id>();
        listoppid.add(listopp.get(0).id);
        listoppid.add(listopp.get(1).id);
        list<opportunity> listnewopp = [select Expected_Revenue_Input__c,This_Year_Expected_Revenue__c
                                       ,CampaignID from opportunity where id in: listoppid];
        //opportunityTriggerHandler.updateOpportunityCampaign(listnewopp,new List<Opportunity>());
        
        	listopp.get(0).campaignid = camp2.id;
        	listopp.get(1).campaignid = camp2.id;
        	update listopp;
        
        test.stopTest();
    }

}