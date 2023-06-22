public class CaseBAProduct {

	public class Status {
		public String code;
		public String description;
	}

	public class Bancassurances {
		public String policyNo;
		public String policyName;
		public String status;
		public String companyName;
		public String productGroup;
		public String effectiveDate;
		public String expiryDate;
		public String sumInsure;
		public String insureType;
		public String empId;
		public String paymentType;
		public String paymentTerm;
		public String nextPaymentDate;
		public String nextInterimDate;
		public String nextInterimAmount;
		public String totalPremiumPaid;
		public String paymode3;
		public String paymentDate;
		public String paymentMethod;
		public String paymentFrequencyAmount;
		public String premium;
		public String interimPayAmount;
		public String beneficiary;
		public String beneficiaryRelation;
		public String insuredAddress;
		public String insuredStreet;
		public String insuredDistrict;
		public String insuredAmphur;
		public String insuredProvince;
		public String insuredPostcode;
		public String carModel;
		public String carBrand;
		public String registerPlateNumber;
		public String yearOfManufacture;
	}

	public Status status;
	public List<Bancassurances> bancassurances;
	public Integer total;

	
	public static CaseBAProduct parseJsonToObj(String json) {
		return (CaseBAProduct) System.JSON.deserialize(json, CaseBAProduct.class);
	}

	public Request query;
	
	public class Queries {
		public String customerId;
	}

	public class Request{
		public Queries query;
		public String parseObjToJson(CaseBAProduct.Request obj) {
			return (string) System.JSON.Serialize(obj);
		}
	}

	public static List<CaseProductNumberService.CaseProductWrapper> getCustomerProductBancassuranceList(CaseBAProduct productBAs) {
        List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();

        if (productBAs != null && productBAs.total != null && productBAs.bancassurances != null) {
            system.debug('BA size : ' + productBAs.bancassurances.size());
            if (productBAs.bancassurances.size() > 0 ) {
                Integer count = 1;
                for (CaseBAProduct.Bancassurances ba : productBAs.bancassurances) {
                    CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper(
                        count,
                        ba.policyNo,
                        ba.policyNo,
                        null,
                        'Bancassurance',
                        ba.productGroup,
                        ba.policyName);
                    returnList.add(caseProd);
                    count++;
                }

            }
        }

        return returnList;
    }
}