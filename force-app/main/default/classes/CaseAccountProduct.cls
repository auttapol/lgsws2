public class CaseAccountProduct {

	public Status status;
	public Accounts accounts;

	public class Status {
		public String code;
		public String description;
	}

	public class Accounts {
		public List<Deposits> deposits;
		public List<Deposits> creditCards;
		public List<Loans> loans;
		public List<Deposits> bancassurances;
		public List<Deposits> investments;
		public List<Deposits> treasuries;
		public List<Deposits> tradeFinances;
	}

	public class Loans {
		public String accountTitle;
		public String accountNumber;
		public String accountType;
		public String openDate;
		public String accountStatus;
		public String productCode;
	}

	public class Deposits {
		public String accountTitle;
		public String accountNumber;
		public String accountType;
		public String openDate;
		public String accountStatus;
		public String productCode;
	}

	public Request query;
	
	public class Queries {
		public String customerId;
	}

	public class Request{
		public Queries query;
		public String parseObjToJson(CaseAccountProduct.Request obj) {
			return (string) System.JSON.Serialize(obj);
		}
	}
	
	public static CaseAccountProduct parseJsonToObj(String json) {
		return (CaseAccountProduct) System.JSON.deserialize(json, CaseAccountProduct.class);
	}


}