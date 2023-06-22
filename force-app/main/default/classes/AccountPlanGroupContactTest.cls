@isTest
public class AccountPlanGroupContactTest {

    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
    
    public static testmethod void myUnitTest(){
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
                  List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        List <group__c> groupList = AccountPlanTestUtilities.createGroupMaster(1,'PortMngtest', false, true);
        Group__c mastergroup = groupList.get(0);
         for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
         
         
        update AccountList;

        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;

         update comprofile;
        
                PageReference groupConpage = Page.AccountPlanGroupContact;
               groupConpage.getParameters().put('GroupID',groupprofile.id);
               groupConpage.getParameters().put('CompanyID',comprofile.id);
               Test.setCurrentPage(groupConpage);
                ApexPages.StandardController sc2 = new ApexPages.StandardController(comprofile);
             AccountPlanGroupContact grouCtrl = new AccountPlanGroupContact(sc2);
        
        List<Contact> GroupContactList = grouCtrl.GroupContactList;
        boolean hasNext = grouCtrl.hasNext;
        boolean hasPrevious = grouCtrl.hasPrevious;
        integer pageNumber = grouCtrl.pageNumber;
        grouCtrl.first();
        grouCtrl.last();
        grouCtrl.previous();
        grouCtrl.next();
        List<Contact> getChildren = grouCtrl.getChildren();

    }
}