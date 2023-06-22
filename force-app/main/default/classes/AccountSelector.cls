/*
* Change : 
*		  Remove Account_Plan_Flag__c = \'Yes\' 
*/
public  without sharing  class AccountSelector {
	
	private static string selectSEAccountUnderPortfolioId(){
		return 
				'SELECT                                                                                                         '
				+'		Id, Name, Account_Plan_Flag__c, Group__c, Group__r.Name, Owner.Segment__c, NI_Actual__c, NI_Plan__c      '
				+'		, NI_SoW__c, NI_Wallet__c, NIIc_Actual__c, NIIc_Plan__c, NIIc_SoW__c, NIIc_Wallet__c, NIId_Actual__c     '
				+'		, NIId_Plan__c, NIId_SoW__c, NIId_Wallet__c, Fee_Actual__c, Fee_Plan__c, Fee_SoW__c, Fee_Wallet__c       '
				+'FROM                                                                                                           '
				+'		Account                                                                                                  '
				//+'WHERE 	Account_Plan_Flag__c = \'Yes\' and                                                                     '
				+'WHERE 	                                                                   '
				+'		Id IN (                                                                                                  '
				+'				SELECT                                                                                           '
				+'						Account__c                                                                               '
				+'				from 	                                                                                         '
				+'						AcctPlanCompanyPort__c                                                                   '
				+'				where                                                                                            '
				+'						Account_Plan_Portfolio__c IN : portfolioIds )                                            ';
	}
	
	private static string selectAccountUnderPortfolioId(){
		return 
				'SELECT                                                                                                         '
				+'		Id, Name, Account_Plan_Flag__c, Group__c, Group__r.Name, Owner.Segment__c, NI_Actual__c, NI_Plan__c      '
				+'		, NI_SoW__c, NI_Wallet__c, NIIc_Actual__c, NIIc_Plan__c, NIIc_SoW__c, NIIc_Wallet__c, NIId_Actual__c     '
				+'		, NIId_Plan__c, NIId_SoW__c, NIId_Wallet__c, Fee_Actual__c, Fee_Plan__c, Fee_SoW__c, Fee_Wallet__c       '
				+'FROM                                                                                                           '
				+'		Account                                                                                                  '
				//+'WHERE 	Account_Plan_Flag__c = \'Yes\' and   Owner.Segment__c =\'SE\' and                                    '
				+'WHERE Owner.Segment__c =\'SE\' and                                    '
				+'		Id IN (                                                                                                  '
				+'				SELECT                                                                                           '
				+'						Account__c                                                                               '
				+'				from 	                                                                                         '
				+'						AcctPlanCompanyPort__c                                                                   '
				+'				where                                                                                            '
				+'						Account_Plan_Portfolio__c IN : portfolioIds )                                            ';
	} 
    
     private static string  selectAccountUnderGroupByGroupProfileId(){
        return  
                 'SELECT Id, Name ,Account_Plan_Flag__c,  Group__c,Group__r.Name ,Owner.Segment__c     '
				+'  , NI_Actual__c, NI_Plan__c  '
				+'	, NI_SoW__c, NI_Wallet__c, NIIc_Actual__c '
				+'	, NIIc_Plan__c, NIIc_SoW__c, NIIc_Wallet__c '
				+'	, NIId_Actual__c, NIId_Plan__c, NIId_SoW__c '
				+'	, NIId_Wallet__c, Fee_Actual__c, Fee_Plan__c '
				+'	, Fee_SoW__c, Fee_Wallet__c '
                +'FROM Account '
               // +'WHERE   Account_Plan_Flag__c = \'Yes\' and   Group__c IN (Select Group__c '
				+'WHERE Group__c IN (Select Group__c '
                +'                  From '
                +'                      AcctPlanGroupProfile__c '
                +'                  Where '
                +'                      Id  =  :groupProfileId'
                +'                  )' ;
     }
     private static string  selectAccountWithSingleViewInfo(){
        return  
                ' SELECT Id,Name, Account_Plan_Flag__c, NI_Actual__c, NI_Plan__c ,  Group__c,Group__r.Name ,Owner.Segment__c '
            +'  , NI_SoW__c, NI_Wallet__c, NIIc_Actual__c '
            +'  , NIIc_Plan__c, NIIc_SoW__c, NIIc_Wallet__c '
            +'  , NIId_Actual__c, NIId_Plan__c, NIId_SoW__c '
            +'  , NIId_Wallet__c, Fee_Actual__c, Fee_Plan__c '
            +'  , Fee_SoW__c, Fee_Wallet__c '
            +' FROM Account '
            +' WHERE   Id IN : accountIds ';
                
    }
       // Single View Info
    public static List<Account> getSEAccountUnderPortfolioIds(Set<Id> portfolioIds){     
        if(portfolioIds== null )
            throw new AccountSelectorException('Set of accountIds Cannot be null');
        string sql = selectSEAccountUnderPortfolioId();
        return (List<Account>) Database.query(sql);        
    }
    
      // Single View Info
    public static List<Account> getAccountUnderPortfolioIds(Set<Id> portfolioIds){     
        if(portfolioIds== null )
            throw new AccountSelectorException('Set of accountIds Cannot be null');
        string sql = selectAccountUnderPortfolioId();
        return (List<Account>) Database.query(sql);        
    }
    
    
    // Single View Info
    public static List<Account> getAccountWithSingleViewInfoByIds(Set<Id> accountIds){     
        if(accountIds== null )
            throw new AccountSelectorException('Set of accountIds Cannot be null');
        string sql = selectAccountWithSingleViewInfo();
        return (List<Account>) Database.query(sql);        
    }
    
    // Return account with Id,Group Id
    public static List<Account> getAccountUnderGroupByGroupProfileId(String groupProfileId){
       
        system.debug('::: groupProfileId >> ' + groupProfileId);
        if(groupProfileId == null || groupProfileId == '' )
            throw new AccountSelectorException('Set of groupProfileId Cannot be null');

        string sql = selectAccountUnderGroupByGroupProfileId();
        system.debug('::: sql' + sql);
        
        return (List<Account>) Database.query(sql);        
    }
    
	

    
    // Exception
    public class AccountSelectorException extends Exception{   
    }
}