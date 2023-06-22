public interface IRetailAccountService {
    Boolean UpdateTotalAccountsAndSumOfDepesite(string accountId,decimal noOfProduct , decimal sumOfTotalDepositeOutstanding);	
	Account GetAccountById(Id acctId);
}