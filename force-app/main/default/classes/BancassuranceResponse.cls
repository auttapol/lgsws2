public class BancassuranceResponse {

	public class Status {
		public String StatusCode;
		public String StatusDesc;
	}

	public class GetBancassuranceAccountResponse {
		public InsurancePolicyListCRMInqResponse InsurancePolicyListCRMInqResponse;
		public Status Status;
	}

	public GetBancassuranceAccountResponse GetBancassuranceAccountResponse;
	public Status Status;

	public class Message {
		public String REQUEST_NO;
		public String STATUS_CODE;
		public String STATUS_NAME;
	}

	public class DataSets {
		public String POLICY_NO;
		public String POLICY_NAME;
		public String STATUS;
		public String COMPANY_NAME;
		public String PRODUCT_GROUP;
		public String EFFECTIVE_DATE;
		public String EXPIRY_DATE;
		public String SUM_INSURE;
		public String INSURE_TYPE;
		public String EMP_ID;
		public String NEXT_PAYMENT_DATE;
		public String NEXT_INTERIM_DATE;
		public String NEXT_INTERIM_AMOUNT;
		public String TOTAL_PREMIUM_PAID;
		public String PAYMODE3;
		public String PAYMENT_TYPE;
		public String PAYMENT_TERM;
		public String PAYMENT_DATE;
		public String PAYMENT_METHOD;
		public String PAYMENT_FREQUENCY_AMOUNT;
		public String PREMIUM;
		public String INTERIM_PAY_AMOUNT;
		public String BENEFICIARY;
		public String BENEFICIARY_RELATION;
		public String INSURED_ADDRESS;
		public String INSURED_STREET;
		public String INSURED_DISTRICT;
		public String INSURED_AMPHUR;
		public String INSURED_PROVINCE;
		public String INSURED_POSTCODE;
		public String CAR_MODEL;
		public String CARBRAND;
		public String REGISTERPLATENUMBER;
		public String YEAR_OF_MANUFACTURE;
	}

	public class InsurancePolicyListCRMInqResult {
		public Message Message;
		public List<DataSets> DataSets;
	}

	public class InsurancePolicyListCRMInqResponse {
		public InsurancePolicyListCRMInqResult InsurancePolicyListCRMInqResult;
	}

	
	public static BancassuranceResponse parse(String json) {
		return (BancassuranceResponse) System.JSON.deserialize(json, BancassuranceResponse.class);
	}
}