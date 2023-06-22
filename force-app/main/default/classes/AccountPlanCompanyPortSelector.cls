public without sharing class AccountPlanCompanyPortSelector {
        
    private static string  selectAllAccountInPortfolioId(){
        return  ' SELECT Id, Account__c, Account_Plan_Portfolio__c '+
                ' FROM AcctPlanCompanyPort__c '+
                ' Where  Account_Plan_Portfolio__c  IN :  acctPlanPortFolioIds ';
    } 
    
    private static string  selectCompanyPortByPortfolioIdAndAccountId(){
        return  ' SELECT Id, Account__c, Account_Plan_Portfolio__c '+
                ' FROM AcctPlanCompanyPort__c '+
                ' Where Account_Plan_Portfolio__c =: portfolioId and Account__c =: accountId ';
    }
    
    
    
    private static string selectAllCompanyProfileUnderGroupByGroupProfolioId(){
    	//groupProfileId    
    	return   'SELECT Account__c, AccountName__c, AcctPlanGroup__c , AcctPlanGroup__r.Name   '
				+'FROM AcctPlanCompanyProfile__c                                                      '
				+'WHERE AcctPlanGroup__c  IN : groupProfileId                                         ';
   
    }
    
    
    public static  List<AcctPlanCompanyProfile__c> getAllCompanyProfileUnderGroupByGroupProfolioId(Set<Id> groupProfileId){
        
        if(groupProfileId == null || groupProfileId.size() < 1 )
            throw new AccountPlanCompanyPortSelectorException('Set of groupProfileId  Cannot be null');
        string sql = selectAllCompanyProfileUnderGroupByGroupProfolioId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);         
    } 
    
    
    
    public static  List<AcctPlanCompanyPort__c> getAllAccountInPortfolioIds(Set<Id> acctPlanPortFolioIds){
        
        if(acctPlanPortFolioIds == null || acctPlanPortFolioIds.size() < 1 )
            throw new AccountPlanCompanyPortSelectorException('Set of acctPlanPortFolioIds  Cannot be null');
        string sql = selectAllAccountInPortfolioId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyPort__c>) Database.query(sql);         
    } 
    
    public static  AcctPlanCompanyPort__c getCompanyPortByPortfolioIdAndAccountId(Id portfolioId, Id accountId){
        
        if(portfolioId == null || accountId == null )
            throw new AccountPlanCompanyPortSelectorException('Set of portfolioId or accountId Cannot be null');
        string sql = selectCompanyPortByPortfolioIdAndAccountId();
        system.debug('::: sql' + sql);
		List<AcctPlanCompanyPort__c> ret = Database.query(sql); 
		if (ret.size() > 0)
		{
			return ret[0];
		}


        return null;
    } 
    
    
    
     private static string  selectAllCompanyPortUnderGroupByGroupProfolioId(){
        return  
               '    SELECT Id, Account__c, Account_Name__c,   '
               +'    Name, Wallet__c, Target_NI_By_RM__c,  '
               +'    Account_Plan_Portfolio__c, Account_Plan_Company_Profile__c  '
               +'    FROM AcctPlanCompanyPort__c '
               +'    where Account_Plan_Company_Profile__r.AcctPlanGroup__c = : groupId ';
    } 
    
    public static  List<AcctPlanCompanyPort__c> getAllCompanyPortUnderGroupByGroupProfolioId(Id groupId){
        
        if(groupId == null  )
            throw new AccountPlanCompanyPortSelectorException('groupId Cannot be null');
        string sql = selectAllCompanyPortUnderGroupByGroupProfolioId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyPort__c>) Database.query(sql);         
    } 
    
    private static string selectTargetNIByRMById(){
        return  ' Select Id, Target_NI_By_RM__c, Account_Plan_Company_Profile__c From AcctPlanCompanyPort__c Where Account_Plan_Company_Profile__c IN :  companyProfileIds ';
    } 
    public static  List<AcctPlanCompanyPort__c> getTargetNIByRMById(Set<Id> companyProfileIds){
        
        if(companyProfileIds == null || companyProfileIds.size() < 1 )
            throw new AccountPlanCompanyPortSelectorException('Set of companyProfileIds Cannot be null');
        string sql = selectTargetNIByRMById();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyPort__c>) Database.query(sql);
        
    } 
    
    
    
    
    // Exception
    public class AccountPlanCompanyPortSelectorException extends Exception{   
    }
}