public class RetailAccountServiceImpl implements IRetailAccountService {
public Boolean UpdateTotalAccountsAndSumOfDepesite(string accountId, decimal noOfProduct, decimal sumOfTotalDepositeOutstanding) {
Boolean ret = true;
if (accountId == null || accountId=='')
{
   throw new RetailAccountServiceException('Account Id cannot be null');
}
try
{
// Fast Update 
Account acc = new Account(Id = accountId, RTL_Actual_Product_Holding__c = noOfProduct, RTL_AUM__c = sumOfTotalDepositeOutstanding,  RTL_AUM_Last_Calculated_Date__c = Date.today());
update acc;
}
catch(Exception e)
{
ret = false;
            System.debug('Update AUM Error :: '+e);
// log
}
return ret;
}

public Account GetAccountById(Id acctId){
    List<Account> accs = RetailAccountSelector.getAccountByIds(new set<Id> { acctId });
if (null != accs && accs.size() > 0)
{
return accs[0];
}
   return new Account();
}

public class RetailAccountServiceException extends Exception{}
}