@isTest
public class RelatedListExtensionTest {
  public static Account acct;
  public static RelatedListExtension related;
  static testMethod void validateRelatedList() {

	    TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
         Map<String,ID> addressmap = TestUtils.CreateAddress();
        
    	acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
        Contact cont = TestUtils.createContacts(1, acct.id, false).get(0);
		TestInit.createOpportunity(TestInit.accountList.values());
      	TestInit.createReport(TestInit.accountList.values());

      
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        related = new RelatedListExtension(sc);
      	related.getCont();
      	related.getCamp();
      	related.getOppt();
      	related.getVisit();
      	
      	//validateRelatedListCont();
		validateRelatedListOppt();
		System.assert(related.visit != null);
		System.assert(related.camp != null);

        
    }   
    
    public static void createOppt(){ 
        // Create a test opportunity
    	Opportunity oppty = new Opportunity( Name = 'oppty',
                              AccountId = acct.id,
                              StageName = 'Open',
                              CloseDate = System.today(),
                              Amount = 100000);

  		insert  oppty;
    }
    
        public static void validateRelatedListOppt(){ 
        
      	//System.assert(related.oppt != null);
      		for (Opportunity ar2 : related.oppt){
            //System.assertEquals(ar2.get('Position__c'),'position1'); 
            //System.assertEquals(ar2.get('Name'),'oppty'); 
      		System.assertEquals(ar2.get('CloseDate'),System.today());
			System.assertEquals(ar2.get('Amount'),0);
			}
            
        }
    
        public static void validateRelatedListCont(){ 
        
                  	//System.assert(related.cont != null);
      	for (Contact ar : related.cont){
            System.assertEquals(ar.get('StageName'),'Open'); 
            System.assertEquals(ar.get('Name'),'Mr.contact_1'); 
      		System.assertEquals(ar.get('MobilePhone'),'0813259784');
			System.assertEquals(ar.get('Decision_Map__c'),'User');
			}
            
        }

     public static void validateRelatedListVisit() {

       	for (Call_Report__c ar : related.visit){
            System.assertEquals(ar.get('Status__c '),'Open'); 
            System.assertEquals(ar.get('Date_of_Visit__c'),Date.today()); 
      		//System.assertEquals(ar.get('MobilePhone'),'0813259784');
			//System.assertEquals(ar.get('Decision_Map__c'),'User');
			}
    }  
    

}