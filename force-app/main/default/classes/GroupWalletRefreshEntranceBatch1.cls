/*****************************************************************************************
*  NOTE : GroupWalletRefreshEntranceBatch 
*         สำหรับ Refresh เคสที่ยังไม่มี Account Plan
*
******************************************************************************************/

global without sharing class GroupWalletRefreshEntranceBatch1 implements Database.Batchable<sObject> ,Database.AllowsCallouts{
    
    // Account Plan Year
    public string m_year {get;set;}
    //  Support
    public Set<Id> m_accountWithAccountPlan    {get;set;}
    public Set<Id> m_accountWithoutAccountPlan {get;set;} 
    
    public id m_groupId {get;set;} 
    public id m_groupProfileId {get;set;}
    public Boolean m_isGroupWallet {get;set;}
    
    global GroupWalletRefreshEntranceBatch1 (Set<Id> accountWithAccountPlan,Set<Id> accountWithoutAccountPlan,Id groupId,string year,id groupProfileId,Boolean isGroupWallet){
        
        m_accountWithAccountPlan    =  accountWithAccountPlan ;
        m_accountWithoutAccountPlan =  accountWithoutAccountPlan;
        m_year = year;
        m_groupId = groupId;
        m_groupProfileId = groupProfileId;
        m_isGroupWallet = isGroupWallet;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Get Account to Process
        Set<Id> accountIds = m_accountWithoutAccountPlan ;
        string year = m_year ;
        return Database.getQueryLocator([
            SELECT Id, Name ,Account_Plan_Flag__c,  Group__c,Group__r.Name ,Owner.Segment__c   
            FROM Account 
            WHERE    Id IN : accountIds 
        ]);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<id> accountIds = (new Map<Id,SObject>(scope)).keySet();
        // Logic to be Executed batch wise      
        AccountPlanRefreshService.RefreshProductStrategyPort(accountIds,this.m_year,this.m_groupId);
    }
     
    global void finish(Database.BatchableContext BC){
        
       /* if(m_accountWithAccountPlan.size() > 0){
             GroupWalletRefreshSecondBatch batch = 
             new GroupWalletRefreshSecondBatch( m_accountWithAccountPlan, m_accountWithoutAccountPlan,m_groupId, m_year,m_groupProfileId);  
             Database.executeBatch(batch ,25);
        }
        else{   */

        /*
    * Here's how you can query your current Salesforce.com instance from Apex code:
    *
    * String s = System.URL.getSalesforceBaseUrl().getHost();   OR System.URL.getSalesforceBaseURL().toExternalForm()
    * system.debug(s);
    *
    * Example - email link with absolute URL from Apex Code:
    *
    * mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created<p>'+
    * ' View case <a href=https://' + System.URL.getSalesforceBaseUrl().getHost() + '/'+case.Id+'>click here</a>'); 
    */
    
             /*GroupWalletRefreshThirdBatch batch =     
             new GroupWalletRefreshThirdBatch( m_accountWithAccountPlan, m_accountWithoutAccountPlan,m_groupId, m_year,m_groupProfileId); 
             Database.executeBatch(batch ,25);
             string mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/'+'apex/AccountPlanGroupWallet?walletID=&CompanyID=&GroupID='+m_groupProfileId;

                 string htmlMsg =  'Refresh Group Wallet batch processing is completed'
                              +'<br />Please click below url to view group wallet '
                              +'<br />View <a href="'+mainUrl+'"> click here</a>';
             

             BatchEmailService.SendEmail(BC.getJobId(),'Batch Processing','Refresh Group Wallet batch processing is completed',htmlMsg);
*/
        
        /*AcctPlanGroupProfile__c groupProfile = [SELECT Id,Name,Year__c,Group__c,Group__r.Name  FROM AcctPlanGroupProfile__c WHERE Id = :this.m_groupProfileId];
            
            Set<Id> AccountWithAccountPlan = new Set<Id>();
            Set<Id> AccountWithoutAccountPlan = new Set<Id>();
            List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE AcctPlanGroup__c = :groupProfile.id
                                                                  AND isHasProdStrategy__c = TRUE];
            
            for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                AccountWithAccountPlan.add(item.Account__c);
            }
            system.debug('AccountWithAccountPlan='+AccountWithAccountPlan);
            List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                FROM Account 
                                                WHERE Group__c = :groupProfile.Group__c
                                                AND Id NOT IN : AccountWithAccountPlan ];
            for(Account item : accountListInitial){
                AccountWithoutAccountPlan.add(item.id);
            }*/
        GroupWalletRefreshEntranceBatch2 batch2 = 
                    new GroupWalletRefreshEntranceBatch2( m_accountWithAccountPlan
                                                        , m_accountWithoutAccountPlan
                                                        , m_groupId
                                                        , m_year
                                                        , m_groupProfileId,m_isGroupWallet);  
                Database.executeBatch(batch2 ,100);  
        //}
        
    }
}