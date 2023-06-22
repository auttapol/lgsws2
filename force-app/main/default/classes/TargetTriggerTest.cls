@IsTest
public class TargetTriggerTest {
    
       static {
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    
        Country__c bkk = new Country__c();
        bkk.Name ='Bangkok';
        bkk.Code__c ='10';
        insert bkk;
    }
    
    public static String STR_POSITIVE = 'positive';
    public static String STR_NEGATIVE = 'negative';
    
    public static testmethod void RunPositiveTestTarget(){
        System.debug(':::: RunPositiveTestTarget Start ::::');
		TestUtils.createAppConfig();        
        TestInit.createUser(false);
        
        System.runAs(TestInit.us) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            TEST.startTest();
            flowTest(STR_POSITIVE);
            TEST.stopTest();
        }
        System.debug(':::: RunPositiveTestTarget End ::::');
    }
    
    public static void flowTest(String testMode){
        
        List<RecordType> recordTypeId = [select Id from RecordType where name = 'Activities Target' and SobjectType = 'Target__c' limit 1];
        Id activitiesId = recordTypeId[0].Id;
        recordTypeId = [select Id from RecordType where name = 'Sales Target' and SobjectType = 'Target__c' limit 1];
        Id salesTargetId = recordTypeId[0].Id;
        recordTypeId = [select Id from RecordType where name = 'Pipelines Target' and SobjectType = 'Target__c' limit 1];
        Id pipeLinesId = recordTypeId[0].Id;
        List<Target__c> listTargetUpdate = new List<Target__c>();
        Integer rowNum = 3;
        for( Integer i=0;i<rowNum;i++ ){                
            Target__c target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = null,
                Opportunity_stage__c = null,
                RecordTypeId = activitiesId);
            listTargetUpdate.add(target);
            
            target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = 'Loan',
                Opportunity_stage__c = null,
                RecordTypeId = salesTargetId);
            listTargetUpdate.add(target);
            
            target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = null,
                Opportunity_stage__c = 'CA Prep',
                RecordTypeId = pipeLinesId);            
            listTargetUpdate.add(target);
            
        }
        //insert listTargetUpdate;
        Database.SaveResult[] srList = Database.insert(listTargetUpdate, false);        
        Integer countSuccess = 0;
        List<Id> idList = new List<Id>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted ID ' + sr.getId());
                idList.add(sr.getId());
                countSuccess++;
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(' fields that affected this error: ' + err.getFields());
                }
            }
        }
        System.debug('::a a a :'+countSuccess);
        System.assertEquals(rowNum * 3, countSuccess);
        Integer nextCount = 33;
        Integer count = nextCount;        
        List<Target__c> targetList_update = new List<Target__c>();
        listTargetUpdate = [ select Id,RecordTypeId,Product__c,Opportunity_stage__c from Target__c where Id = :idList  ];
        for(Target__c t : listTargetUpdate ){
            t.Monthly_Target_Date__c = Date.today()+count;
            if( t.RecordTypeId == activitiesId ){
                
            }else if( t.RecordTypeId == salesTargetId  ){
                t.Product__c = t.Product__c+count;
            }else if( t.RecordTypeId == pipeLinesId  ){
                t.Opportunity_stage__c = t.Opportunity_stage__c+count;
            }
            targetList_update.add(t);
            count+=nextCount;            
        }
        System.debug(' ::::>> '+targetList_update);
        Database.SaveResult[] srList_update = Database.update(targetList_update);
        countSuccess = 0;
        for (Database.SaveResult sr : srList_update) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully update ID ' + sr.getId());
                countSuccess++;
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(' fields that affected this error: ' + err.getFields());
                }
            }
        }
        System.assertEquals(listTargetUpdate.size(), countSuccess);
    }    
    
    
    public static testmethod void RunTargetTriggerHandlerTest(){
         List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'CertName';
        Aconfig2.Value__c = 'TMB-UAT'; 
        apps.add(Aconfig2);
        insert apps;
        
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'TargetTriggerTest', 'targetTest@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        SalesOwner.Zone_Code__c ='1001';
        SalesOwner.Employee_ID__c = '5043';
        update SalesOwner;
        System.runAs(SalesOwner){
          List<RecordType> recordTypeId = [select Id from RecordType where name = 'Activities Target' and SobjectType = 'Target__c' limit 1];
        Id activitiesId = recordTypeId[0].Id;
        recordTypeId = [select Id from RecordType where name = 'Sales Target' and SobjectType = 'Target__c' limit 1];
        Id salesTargetId = recordTypeId[0].Id;
        recordTypeId = [select Id from RecordType where name = 'Pipelines Target' and SobjectType = 'Target__c' limit 1];
        Id pipeLinesId = recordTypeId[0].Id;
        recordTypeId = [select Id from RecordType where name = 'NI Target' and SobjectType = 'Target__c' limit 1];
        Id nitargetID = recordTypeId[0].Id;
        
        List<Target__c> listTargetUpdate = new List<Target__c>();
              
            Target__c target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = null,
                Opportunity_stage__c = null,
                RecordTypeId = activitiesId);
            listTargetUpdate.add(target);
            
            target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = 'Loan',
                Opportunity_stage__c = null,
                RecordTypeId = salesTargetId);
            listTargetUpdate.add(target);
            
            target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = null,
                Opportunity_stage__c = 'CA Prep',
                RecordTypeId = pipeLinesId);            
            listTargetUpdate.add(target);
            
              target = new Target__c( 
                Monthly_Target_Date__c = Date.today(),
                Product__c = null,
                NI_Target_Monthly__c = 1000,
                Actual_NI_Monthly__c  = 1000,
                Opportunity_stage__c = 'CA Prep',
                RecordTypeId = nitargetID);            
            listTargetUpdate.add(target);
            
        
        insert listTargetUpdate;
        //Database.SaveResult[] srList = Database.insert(listTargetUpdate, false);    
 		   Target__c targetResult = [SELECT ID,Monthly_Target_Date__c,NI_Target_Monthly__c
                              FROM Target__c WHERE NI_Target_Monthly__c >0 LIMIT 1];
        	targetResult.Opportunity_stage__c = 'Close Deal';
        update targetResult;
        }
        
        
        
    }
}