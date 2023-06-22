@IsTest
public class SubSendEmailBatchTest {

    Static testmethod void TestPositive1(){
        
        List<string> ListIdUser = new list<string>();
        IDMUserEmailServices callMail = new IDMUserEmailServices();
        system.debug('Yes');
        List<User> newUser = TestUtils.createUsers(3, 'F', 'L' ,'test@tmbbank.com', true);
        for(User u : newUser){
            u.IsActive = true;
            update u;
        }
        system.debug('No :' + newUser);
        for(User u: [Select Id From User Where LastModifiedDate = TODAY LIMIT 10])
        {
            ListIdUser.add(u.id);
        }
        system.debug(ListIdUser);
        //String EmailTemplateID = callMail.mapEmailTemplate.get('HCM:Email Template for New User').ID;
        //callMail.sendMailToUser(ListIdUser,'HCM:Email Template for New User');
        
        
        Test.startTest();

        //SubSendEmailBatch subEmail = new SubSendEmailBatch(ListIdUser,'HCM:Email Template for New User');
        //System.abortJob(batchID);
        //Database.executeBatch(SubSendEmailBatch(ListIdUser,'HCM:Email Template for New User'),200);
		Test.stopTest();

        
        // Create an instance of query locator
        Database.QueryLocator QL;
        // Create an instance of batchable context
        Database.BatchableContext BC;
        List<User> allUser = new List<User>();
        //AccountUpdate oAccountUpdate = new AccountUpdate('Name', 'Test');
        SubSendEmailBatch subEmail = new SubSendEmailBatch(ListIdUser,'HCM:Email Template for New User');
        // execute start method
        QL = subEmail.start(bc);       
        // Create an instance of Query Locator Iterator
        Database.QueryLocatorIterator QLI =  QL.iterator();
        while (QLI.hasNext())
        {
            User nUser = (User)QLI.next();        
            //System.debug(Acc);
            allUser.add(nUser);
        }               
        // initiate execute method
        subEmail.execute(BC, allUser);
        // execute finish method
        subEmail.finish(BC);    
        
        
        
        
    }
}