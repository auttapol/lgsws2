public class ProductListingRequest {
    public GetCustomerAccountRequest GetCustomerAccountRequest;
    public GetBancassuranceAccountRequest GetBancassuranceAccountRequest;
    public GetInvestmentAccountRequest GetInvestmentAccountRequest;

    public ProductListingRequest() {

    }

    public ProductListingRequest(String RMID, String FIIdent, String unitHoldNo) {

        if (RMID != null && FIIdent != null) {
            GetCustomerAccountRequest request = new GetCustomerAccountRequest();
            request.FIIdent = FIIdent;
            request.RMID = RMID;
    
            this.GetCustomerAccountRequest = request;
        } else if (RMID != null) {
            ProductListingRequest.GetBancassuranceAccountRequest request = new ProductListingRequest.GetBancassuranceAccountRequest();
            request.RMID = RMID;

            this.GetBancassuranceAccountRequest = request;
        } else if (unitHoldNo != null) {
            ProductListingRequest.GetInvestmentAccountRequest request = new ProductListingRequest.GetInvestmentAccountRequest();
            request.UnitHolderNo = unitHoldNo;

            this.GetInvestmentAccountRequest = request;
        } else {

        } 
    }

    public class GetCustomerAccountRequest {
        public String RMID;
        public String FIIdent;
    }

    public class GetBancassuranceAccountRequest {
        public String RMID;
    }

    public class GetInvestmentAccountRequest {
        public String UnitHolderNo;
    }
}