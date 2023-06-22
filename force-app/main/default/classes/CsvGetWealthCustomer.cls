public class CsvGetWealthCustomer {

    public class Header{

    }

    public class CustomerInformationRequest {
		public GetCustomerWealthRequest GetCustomerWealth;
	}

    public class GetCustomerWealthRequest {
		public String CitizenID;
	}
    
    public class GetCustomerWealth {
		public CustomerInformation CustomerInformation;
        public String CustomerCreditLine;
        public List<CustomerDeposit> CustomerDeposit;
        public List<CustomerNonDeposit> CustomerNonDeposit;
        public CustomerLoan CustomerLoan;
	}

	public class CustomerInformation {
		public String Customername;
		public String TranssactionCreateDate;
		public String WealthStatus;
	}

	public class CustomerDeposit {
		public String ProductType;
		public String AccountType;
		public Decimal SumAvaiBalance;
	}

    public class CustomerNonDeposit {
		public String ProductType;
		public String AccountType;
		public Decimal SumAvaiBalance;
	}

	public class CustomerLoan {
		public Decimal TotalTermLoanLimit;
		public Decimal TotalTermLoanBalance;
        public Decimal TotalSecureLoanLimit;
        public Decimal TotalSecureLoanBalance;
        public Decimal TotalUnsecureLoanLimit;
        public Decimal TotalUnsecureLoanBalance;
	}

    public Header Header;
    public GetCustomerWealth GetCustomerWealth;

	public Request request;

	public class Request {
        public CustomerInformationRequest CustomerInformation;
		public String parseObjToJson(CsvGetWealthCustomer.Request obj) {
			return (string) System.JSON.Serialize(obj);
		}
	}

	public static CsvGetWealthCustomer parseJsonToObj(String json) {
        System.debug('json: ' + json);
		return (CsvGetWealthCustomer) System.JSON.deserialize(json, CsvGetWealthCustomer.class);
	}

}